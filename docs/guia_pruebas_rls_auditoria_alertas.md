# Guía de despliegue y pruebas: RLS, auditoría y monitoreo

## Alcance y advertencias

Los scripts de operaciones 03, 04 y 05 endurecen el acceso y registran métricas. Son scripts SQL de despliegue; no sustituyen una prueba en una instancia PostgreSQL. Ejecutarlos primero en una base de datos de desarrollo con respaldo reciente.

Orden recomendado:
1. DDL y datos iniciales.
2. operaciones/03_auditoria.sql.
3. operaciones/04_seguridad_roles.sql.
4. operaciones/05_alertas_espacio.sql.
5. Configurar el recolector respaldos/medir_espacio.sh.

## 1. Crear cuentas sin contraseñas en Git

El script de roles crea roles grupales NOLOGIN; no crea cuentas LOGIN ni guarda claves. Como administrador:

~~~sql
CREATE ROLE usr_medico_cardio LOGIN;
GRANT rol_medico TO usr_medico_cardio;

CREATE ROLE usr_medico_pediatria LOGIN;
GRANT rol_medico TO usr_medico_pediatria;

CREATE ROLE usr_enfermeria1 LOGIN;
GRANT rol_enfermeria TO usr_enfermeria1;

CREATE ROLE usr_recepcion1 LOGIN;
GRANT rol_recepcion TO usr_recepcion1;

CREATE ROLE usr_auditor1 LOGIN;
GRANT rol_auditor TO usr_auditor1;
~~~

Luego, desde psql, asignar las contraseñas de forma interactiva con \password nombre_usuario. No reutilizar contraseñas de demostración ni guardarlas en archivos del repositorio. Configurar .pgpass con permisos restringidos o un gestor de secretos.

**Importante:** session_user identifica el login original de PostgreSQL. Para probar el mapeo de usuario hay que abrir una conexión real con cada cuenta; SET ROLE desde una sesión de administrador no simula ese login.

## 2. Asociar logins con empleados

El RLS de médicos y enfermería consulta empleado.usuario_bd. El script conserva dos asociaciones de ejemplo (empleados 13 y 18). Revisar que correspondan realmente a los profesionales correctos y completar las demás asociaciones:

~~~sql
SELECT id_empleado, id_departamento, usuario_bd
FROM empleado
ORDER BY id_empleado;

-- Ejemplo: sustituir IDs y logins por los datos reales.
UPDATE empleado
SET usuario_bd = 'usr_medico_cardio'
WHERE id_empleado = 13;
~~~

Cada login debe estar asociado a un único empleado. Si la consulta devuelve NULL para el empleado, las políticas de ese usuario no concederán acceso a filas clínicas.

## 3. Pruebas de aislamiento RLS

Conectar por separado como usr_medico_cardio, usr_medico_pediatria y usr_enfermeria1. Ejecutar:

~~~sql
SELECT current_user, session_user;
SELECT id_paciente FROM paciente ORDER BY id_paciente;
SELECT id_expediente, id_paciente FROM expediente ORDER BY id_expediente;
SELECT id_consulta, id_paciente, id_empleado
FROM consulta ORDER BY id_consulta;
SELECT id_estudio, id_paciente, id_medico_solicitante
FROM estudio_diagnostico ORDER BY id_estudio;
SELECT id_ingreso_hospitalario, id_paciente, id_medico_ingreso
FROM ingreso_hospitalario ORDER BY id_ingreso_hospitalario;
SELECT id_interconsulta, id_paciente,
       id_medico_solicitante, id_medico_especialista
FROM interconsulta ORDER BY id_interconsulta;
~~~

Criterios:
- El médico solo ve consultas y estudios que solicitó, expedientes/pacientes con relación clínica y los ingresos que formalizó.
- Enfermería solo ve ingresos activos de camas de su departamento y las filas clínicas derivadas de ese ámbito.
- Recepción puede insertar persona, paciente y expediente; no tiene SELECT global sobre esos datos ni acceso a consultas/estudios.
- Un login sin asociación en empleado.usuario_bd no debe ver filas clínicas por estas políticas.
- Confirmar que ningún usuario de aplicación tenga SUPERUSER, BYPASSRLS ni sea propietario de las tablas.

Verificar políticas instaladas como administrador:

~~~sql
SELECT schemaname, tablename, policyname, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

SELECT relname, relrowsecurity, relforcerowsecurity
FROM pg_class
WHERE relname IN ('persona','paciente','expediente','consulta',
                  'estudio_diagnostico','ingreso_hospitalario','interconsulta');
~~~

**Nota de diseño:** el esquema actual no modela asignaciones formales de enfermería a pacientes ni un registro de acceso/atención por episodio. Por eso, el alcance de enfermería se aproxima mediante departamento de cama e ingreso activo. Para producción, conviene incorporar una tabla de asignación asistencial por paciente/episodio y basar RLS en esa relación explícita.

## 4. Prueba de auditoría

Conectar como login de prueba y ejecutar una operación controlada:

~~~sql
UPDATE paciente SET peso = peso WHERE id_paciente = 1;

SELECT usuario, rol_activo, fecha, tabla, operacion, aplicacion, ip_cliente
FROM auditoria_log
ORDER BY id_auditoria DESC
LIMIT 10;
~~~

usuario debe mostrar el login original (session_user), incluso si la escritura pasó por la función SECURITY DEFINER. rol_activo guarda current_user, es decir, el contexto efectivo al ejecutarse el trigger. No confundir el login técnico de la aplicación con la persona humana: si varios profesionales comparten un mismo login de servicio, PostgreSQL no puede distinguirlos de forma fiable. En ese escenario se necesita autenticación individual o un contexto de identidad validado por una capa de aplicación confiable.

## 5. Métricas y alertas

Después de crear las tablas y vistas:

~~~sql
CALL monitoreo.registrar_medicion_bd();

SELECT * FROM monitoreo.v_crecimiento_bd_7d;
SELECT * FROM monitoreo.v_alertas;
SELECT * FROM monitoreo.v_consultas_lentas;
SELECT * FROM monitoreo.v_bloqueos;
SELECT * FROM monitoreo.v_conexiones;
SELECT * FROM monitoreo.v_tamano_relaciones
ORDER BY total_bytes DESC;
SELECT * FROM monitoreo.v_wal_archivado;
~~~

El crecimiento semanal solo será válido cuando existan dos mediciones separadas por al menos siete días. Antes de ello la vista informa SIN_LINEA_BASE_7D; no inventa una medición histórica.

### Espacio real del filesystem

La consulta SQL no puede inferir el espacio libre del volumen a partir del tamaño de la base de datos. El recolector respaldos/medir_espacio.sh usa df sobre el directorio PGDATA y guarda capacidad, uso y disponibilidad reales.

Ejemplo Linux:

~~~bash
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=hospital_san_lucas
export PGUSER=usuario_monitoreo
export PGDATA=/var/lib/pgsql/data
bash respaldos/medir_espacio.sh
~~~

Programar el script con cron o el programador de tareas del sistema operativo. Proteger las credenciales con .pgpass o un gestor de secretos. Dar al usuario recolector solo permisos INSERT sobre monitoreo.medicion_filesystem.

### Notificaciones

Las vistas SQL detectan condiciones y devuelven estados; no envían correos ni mensajes. Para notificaciones automáticas se necesita un proceso externo (por ejemplo, cron/Task Scheduler que consulte monitoreo.v_alertas, o Prometheus y Alertmanager). Documentar destinatarios, frecuencia, escalamiento y pruebas de entrega.

## 6. Pendientes antes de declarar el control validado

- Ejecutar scripts en PostgreSQL de la versión objetivo y guardar salida de ejecución.
- Probar cada rol con conexión independiente y demostrar acceso permitido/denegado.
- Confirmar asociación real entre cada login y empleado.
- Revisar las políticas con el equipo clínico: el modelo no contiene asignación formal enfermera-paciente.
- Probar auditoría para INSERT, UPDATE y DELETE; proteger la bitácora frente a modificación/borrado por usuarios de aplicación.
- Programar mediciones de BD y filesystem y esperar una línea base real de siete días.
- Probar alerta de disco lleno, consultas lentas, bloqueos y umbral de conexiones en entorno controlado.
- Configurar notificaciones externas y verificar su entrega.
- Rotar cualquier contraseña que haya estado previamente en el repositorio y limpiar el historial Git si corresponde.
