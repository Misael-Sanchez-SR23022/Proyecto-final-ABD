# Proyecto final de Administración de Bases de Datos
## Hospital Regional «San Lucas»

Repositorio académico del sistema de gestión hospitalaria implementado en PostgreSQL.

## Ejecución general

Ejecutar los scripts en una base de datos de desarrollo y en el orden correspondiente:

1. **scripts-iniciales/01_hospital_san_lucas_ddl.sql** — creación del esquema.
2. **scripts-iniciales/03_poblacion_de_datos.sql** — datos de prueba.
3. Scripts de **operaciones/** según la actividad que se vaya a validar.
4. **operaciones/03_auditoria.sql** — bitácora de operaciones.
5. **operaciones/04_seguridad_roles.sql** — roles y políticas RLS.
6. **operaciones/05_alertas_espacio.sql** — métricas y vistas de alertas.
7. **bash respaldos/medir_espacio.sh** — captura de espacio real del filesystem, después de configurar variables PostgreSQL y PGDATA.

Los scripts de seguridad deben ejecutarse con una cuenta administradora/propietaria de la base de datos. Crear los usuarios LOGIN y asignar contraseñas de forma segura fuera del repositorio; el script 04 solo define roles grupales NOLOGIN.

## Seguridad y validación

- Leer **docs/guia_pruebas_rls_auditoria_alertas.md** antes de probar RLS, auditoría o métricas.
- Las cuentas de aplicación deben asociarse con empleados mediante **empleado.usuario_bd**.
- Los pacientes se asignan a médicos mediante **asignacion_paciente**; esta relación la registra un administrador autorizado.
- No otorgar SUPERUSER, BYPASSRLS ni propiedad de tablas a cuentas de aplicación.
- Las vistas de alertas detectan condiciones; para notificaciones automáticas se requiere un planificador/monitor externo.
- La revisión de código no equivale a una prueba de ejecución. Registrar evidencias de pruebas en PostgreSQL antes de declarar los controles validados.

## Credenciales

No almacenar contraseñas, tokens ni secretos en el repositorio. Usar .pgpass con permisos restrictivos o un gestor de secretos. Si alguna clave estuvo comprometida en commits anteriores, rotarla y evaluar la limpieza del historial Git.
