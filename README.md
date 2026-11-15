# Hospital Regional San Lucas
## Proyecto final de Administración de Bases de Datos

Repositorio académico del caso de estudio **Hospital Regional San Lucas**. El proyecto implementa una base de datos relacional en PostgreSQL para administrar información clínica y operativa, incorporando reglas de negocio, particionamiento, optimización de consultas, seguridad, auditoría, monitoreo, respaldos y replicación física primaria-secundaria.

---

## Autores

| Nombre | Carnet |
|---|---|
| Bryan Misael Sanchez Ramirez | SR23022 |
| Cesia Mariena Alfaro Hernández | AH23007 |
| Vanessa Gabriela Arévalo Elías | AE25016 |
| Liliana Melissa Cruz Henriquez | CH20014 |

---

## 1. Objetivos del proyecto

Diseñar e implementar una base de datos que centralice la operación de un hospital regional y permita:

- Gestionar pacientes, personas, expedientes y contactos.
- Administrar personal, cargos, especialidades y departamentos.
- Registrar consultas, ingresos hospitalarios, camas y altas.
- Programar quirófanos, cirugías y equipos quirúrgicos.
- Controlar inventario, movimientos y existencias de insumos.
- Administrar turnos del personal e interconsultas.
- Registrar equipos médicos y sus mantenimientos.
- Gestionar estudios diagnósticos y sus resultados.
- Aplicar reglas de integridad y validaciones operativas.
- Mejorar el acceso a la información mediante índices, vistas y particiones.
- Aplicar controles de acceso, auditoría y monitoreo.
- Generar respaldos lógicos y físicos.
- Configurar una réplica física de PostgreSQL en un servidor secundario.

## 2. Tecnologías y entorno

| Componente | Uso en el proyecto |
|---|---|
| PostgreSQL | Motor de base de datos relacional. |
| SQL y PL/pgSQL | Definición del esquema, consultas, funciones, triggers, vistas y controles. |
| pgAdmin 4 | Administración gráfica del servidor, creación de la base de datos y ejecución de los scripts SQL mediante la Query Tool. |
| `psql` | Cliente de terminal; se utiliza en la práctica de replicación y en la verificación de la conexión de replicación. |
| `btree_gist` | Soporte para restricciones de exclusión GiST, por ejemplo para evitar solapamientos de horarios. |
| `pg_stat_statements` | Estadísticas de ejecución de consultas; requiere configuración del servidor. |
| pgAudit | Auditoría de eventos del servidor, si se instala y habilita en PostgreSQL. |
| `pg_dump`, `pg_dumpall`, `pg_basebackup` | Respaldos lógicos, globales y físicos. |
| Tailscale | Conectividad privada entre los equipos primario y secundario para la práctica de replicación. |
| Linux / Windows | Se incluyen scripts de respaldo para ambos sistemas. |

### Versiones y compatibilidad

La documentación de replicación registra PostgreSQL **16.15** en el servidor secundario. El script de respaldo de Windows contiene una ruta de ejecutables correspondiente a PostgreSQL **18**. Por ello, antes de ejecutar cada script debe comprobarse la versión instalada y ajustarse la ruta de los binarios cuando corresponda.

Para una replicación física, el servidor primario y el secundario deben utilizar versiones mayores compatibles de PostgreSQL. No se debe asumir que una ruta o configuración de una máquina aplica automáticamente a la otra.

## 3. Estructura del repositorio

La estructura actual de los archivos principales es:

```text
Proyecto-final-ABD/
├── README.md
├── docs/
│   ├── comprobaciones/
│   │   └── seguridad_auditoria/
│   │       ├── 01_bloqueo_delete_paciente.png
│   │       ├── 02_rls_expediente_cardio.png
│   │       ├── 03_auditoria_log.png
│   │       └── 04_alertas_espacio.png
│   ├── diagramas/
│   │   ├── 01_hospital_san_lucas_diagrama_completo.png
│   │   ├── 02_persona_y_contacto.png
│   │   ├── 03_empleado_y_departamento.png
│   │   ├── 04_paciente_y_expediente.png
│   │   ├── 05_cama_e_ingresos.png
│   │   ├── 06_consultas.png
│   │   ├── 07_quirtofano_y_cirugia.png
│   │   ├── 08_inventario.png
│   │   ├── 09_turnos.png
│   │   ├── 10_interconsulta.png
│   │   ├── 11_equipo_y_mantenimiento.png
│   │   └── 12_estudio_y_diagnostico.png
│   └── informe_seguridad_auditoria_alertas.md
├── operaciones/
│   ├── 01_explain_analyze.sql
│   ├── 02_monitoreo.sql
│   ├── 03_auditoria.sql
│   ├── 04_seguridad_roles.sql
│   └── 05_alertas_espacio.sql
├── reglas_de_negocio/
│   ├── 01_funciones.sql
│   └── 02_triggers.sql
├── reportes/
│   └── 01_consultas_reporte.sql
├── respaldos/
│   ├── replica_secundario.sh
│   ├── respaldo_completo.bat
│   └── respaldo_completo.sh
└── scripts-iniciales/
    ├── 01_hospital_san_lucas_ddl.sql
    ├── 02_particiones.sql
    ├── 03_poblacion_de_datos.sql
    ├── 04_indices.sql
    └── 05_vistas.sql
```

## 4. Diseño de la base de datos

El modelo relacional cubre las siguientes áreas funcionales:

1. **Personas y contacto:** datos generales, teléfonos, direcciones y contactos de emergencia.
2. **Personal y departamentos:** empleados, cargos, especialidades, departamentos y correos.
3. **Pacientes y expedientes:** información del paciente y su expediente clínico.
4. **Camas e ingresos:** tipos de cama, ubicación, disponibilidad, ingresos y altas hospitalarias.
5. **Consultas:** atención médica, motivo, síntomas, diagnóstico y tratamiento.
6. **Quirófanos y cirugías:** programación quirúrgica, personal participante, anestesiólogos y duración.
7. **Inventario:** insumos, existencias, movimientos y detalle de movimientos.
8. **Turnos:** programación de jornadas y guardias por empleado y departamento.
9. **Interconsultas:** solicitudes entre profesionales y seguimiento de prioridad y estado.
10. **Equipos y mantenimiento:** inventario de equipos médicos y sus mantenimientos.
11. **Estudios diagnósticos:** solicitudes, programación, realización y resultados de laboratorio e imagenología.

El diagrama general y los diagramas por módulos se encuentran en la carpeta `docs/`.

### Integridad y reglas de negocio

El DDL utiliza claves primarias, claves foráneas, restricciones `UNIQUE`, `CHECK`, valores predeterminados e identidades. Entre las validaciones implementadas se encuentran:

- Formato de DUI, teléfono y correo electrónico.
- Valores permitidos para estados, prioridades, tipos y categorías.
- Rangos válidos para peso, estatura, fechas y cantidades.
- Relaciones entre pacientes, expedientes, empleados y departamentos.
- Prevención de ingresos activos duplicados para una misma cama o paciente mediante índices únicos parciales.
- Restricciones de exclusión para evitar traslapes de cirugías en quirófanos, cirujanos y anestesiólogos, y de turnos de un mismo empleado.

La extensión `btree_gist` se crea al inicio del DDL porque es necesaria para las restricciones de exclusión que combinan identificadores y rangos de tiempo.

## 5. Funciones y triggers

Los archivos de `reglas_de_negocio/` implementan validaciones y automatizaciones en el servidor.

### Funciones principales

En `01_funciones.sql` se incluyen funciones para:

- Comprobar si un empleado corresponde a un médico.
- Validar que los profesionales asignados a consultas, ingresos, cirugías, estudios e interconsultas cumplan las condiciones definidas.
- Gestionar la ocupación de camas asociada a ingresos.
- Actualizar existencias de inventario a partir de movimientos.
- Bloquear modificaciones no permitidas en registros que deben conservar su integridad.

### Triggers principales

En `02_triggers.sql` se crean disparadores para ejecutar automáticamente las validaciones anteriores ante operaciones de inserción o actualización en las tablas correspondientes. También se controla la inmutabilidad de determinados detalles de movimientos.

El orden recomendado es crear primero las funciones y después los triggers, porque estos últimos dependen de las funciones.

## 6. Particionamiento, índices y vistas

### Particionamiento

El archivo `scripts-iniciales/02_particiones.sql` transforma las tablas de mayor crecimiento histórico:

- `consulta`, particionada por rango de `fecha_hora_consulta`.
- `estudio_diagnostico`, particionada por rango de `fecha_hora_solicitud`.

Se definen particiones trimestrales para los periodos incluidos en el script y una partición `DEFAULT` para fechas que no coincidan con los rangos declarados. El proceso migra los registros existentes a las nuevas tablas particionadas y ajusta las secuencias de identidad. También adapta la relación de `detalle_resultado_estudio` mediante una clave foránea compuesta que incluye la fecha de solicitud.

**Consideración:** el script de particionamiento es una migración estructural. Debe ejecutarse una sola vez sobre la estructura inicial ya creada y poblada, en una base de datos de prueba o respaldada. No debe ejecutarse repetidamente sobre una base ya migrada sin revisar antes su estado.

### Índices

`scripts-iniciales/04_indices.sql` crea índices para claves foráneas, filtros y consultas frecuentes. Incluye índices compuestos y parciales para casos como:

- Camas disponibles u ocupadas.
- Cirugías programadas.
- Ingresos por fecha y estado.
- Turnos activos.
- Interconsultas pendientes.
- Mantenimientos pendientes.
- Estudios pendientes.
- Insumos cuyo stock está por debajo del mínimo.

Al final se ejecutan instrucciones `ANALYZE` sobre las tablas relevantes para actualizar las estadísticas del optimizador.

### Vistas

`scripts-iniciales/05_vistas.sql` define vistas de consulta operativa, entre ellas:

- `vista_ocupacion_departamento`
- `vista_agenda_quirurgica`
- `vista_insumos_reposicion`
- `vista_turnos_personal`
- `vista_interconsultas_pendientes`
- `vista_estudios_por_estado`
- `vista_top_diagnosticos`
- `vista_mantenimientos_pendientes`

Estas vistas consolidan información de varias tablas y facilitan la generación de reportes sin repetir manualmente las uniones.

## 7. Requisitos previos e instalación

### Requisitos

- Una instalación funcional de PostgreSQL.
- **pgAdmin 4** instalado y con una conexión registrada al servidor PostgreSQL (el servidor aparece en el árbol de objetos de pgAdmin).
- Acceso administrativo (por ejemplo, el usuario `postgres`) para crear la base de datos, extensiones, roles y usuarios.
- Espacio suficiente para los datos, índices, WAL y respaldos.
- Acceso a los archivos del repositorio (clonado o descargado en formato ZIP).

### Obtener el repositorio

Clonar el repositorio con Git o descargarlo desde GitHub (*Code → Download ZIP*) y descomprimirlo en una carpeta local:

```text
https://github.com/Misael-Sanchez-SR23022/Proyecto-final-ABD.git
```

Los archivos `.sql` se abrirán después desde pgAdmin, por lo que conviene recordar la ruta donde quedó la carpeta del proyecto.

### Crear la base de datos desde pgAdmin

1. Abrir pgAdmin 4 y conectarse al servidor PostgreSQL (se solicitará la contraseña del usuario administrador).
2. En el árbol de objetos, expandir **Servers → [nombre del servidor]**.
3. Clic derecho sobre **Databases** → **Create** → **Database…**
4. En la pestaña **General**, escribir el nombre `hospital_san_lucas` y dejar como propietario (*Owner*) al usuario `postgres` u otro usuario administrador.
5. Presionar **Save**.

Alternativamente, se puede abrir la Query Tool sobre la base `postgres` y ejecutar:

```sql
CREATE DATABASE hospital_san_lucas;
```

Una vez creada, seleccionar la base `hospital_san_lucas` en el árbol de objetos y abrir la **Query Tool** sobre ella (clic derecho → *Query Tool*). Todos los scripts de la sección siguiente se ejecutan dentro de esta base.

Los pasos siguientes asumen que la base se llama `hospital_san_lucas`. Si se utiliza otro nombre, debe ajustarse en los scripts que lo referencian.

## 8. Orden de ejecución de los scripts

Para una instalación nueva, se recomienda ejecutar los archivos en el siguiente orden. La secuencia distingue la creación inicial, la carga de datos y las configuraciones operativas.

| Orden | Archivo | Propósito |
|---:|---|---|
| 1 | `scripts-iniciales/01_hospital_san_lucas_ddl.sql` | Crea el esquema, tablas, claves, restricciones y extensión `btree_gist`. |
| 2 | `scripts-iniciales/03_poblacion_de_datos.sql` | Inserta catálogos y datos de prueba relacionados. |
| 3 | `scripts-iniciales/02_particiones.sql` | Migra `consulta` y `estudio_diagnostico` a tablas particionadas. |
| 4 | `reglas_de_negocio/01_funciones.sql` | Crea las funciones PL/pgSQL de validación y operación. |
| 5 | `reglas_de_negocio/02_triggers.sql` | Crea los triggers que invocan las funciones. |
| 6 | `scripts-iniciales/04_indices.sql` | Crea índices y actualiza estadísticas. |
| 7 | `scripts-iniciales/05_vistas.sql` | Crea las vistas operativas y de reportes. |
| 8 | `operaciones/03_auditoria.sql` | Crea la bitácora y triggers de auditoría. |
| 9 | `operaciones/04_seguridad_roles.sql` | Crea roles, usuarios de prueba, privilegios y políticas RLS. |
| 10 | `operaciones/02_monitoreo.sql` | Crea consultas y objetos de monitoreo; habilita la extensión requerida. |
| 11 | `operaciones/05_alertas_espacio.sql` | Crea el esquema, tablas y vista de alertas de almacenamiento. |
| 12 | `operaciones/01_explain_analyze.sql` | Ejecuta análisis de planes de consulta y rendimiento. |
| 13 | `reportes/01_consultas_reporte.sql` | Ejecuta consultas de reportes basadas en las vistas. |

### Ejecución desde pgAdmin

La instalación se realizó desde **pgAdmin 4**, sin usar la terminal. Para cada archivo de la tabla anterior, en el orden indicado:

1. En el árbol de objetos, seleccionar la base `hospital_san_lucas`.
2. Abrir la **Query Tool** (clic derecho sobre la base → *Query Tool*, o menú *Tools → Query Tool*).
3. Cargar el script con el botón **Open File** (icono de carpeta) de la barra de herramientas y seleccionar el archivo `.sql` correspondiente del repositorio clonado o descargado.
4. Ejecutar el script completo con el botón **Execute/Refresh** o con la tecla **F5**.
5. Revisar la pestaña **Messages** (y *Data Output*, cuando el script devuelva filas) para confirmar que terminó sin errores antes de pasar al siguiente archivo.

Se recomienda ejecutar y validar cada script de forma individual, en lugar de lanzarlos todos de una vez sin revisar los resultados. Si un script muestra un error, debe corregirse la causa antes de continuar, porque los archivos posteriores dependen de los objetos que crean los anteriores.

> **Nota:** `01_explain_analyze.sql`, `02_monitoreo.sql` y `01_consultas_reporte.sql` contienen varias consultas independientes. Si se desea ver el resultado de una en particular, seleccionar solo esa consulta en la Query Tool y presionar **F5**; de lo contrario, pgAdmin muestra únicamente el resultado de la última sentencia ejecutada.

### Consideraciones sobre el orden

- El DDL debe ejecutarse en una base vacía.
- La población de datos se carga antes del particionamiento porque el script de particiones migra los registros existentes.
- El script de particionamiento elimina y recrea vistas que dependen de las tablas afectadas; por eso las vistas finales se crean después.
- Las funciones deben existir antes de crear los triggers que las invocan.
- La auditoría se instala antes de los roles, ya que el script de seguridad ajusta la función de auditoría y concede acceso de lectura a la bitácora al rol auditor.
- El script de seguridad crea usuarios de ejemplo y elimina/recrea roles homónimos si ya existen. Revisar su contenido antes de volver a ejecutarlo.
- Los scripts de índices contienen operaciones de eliminación y creación. No deben tratarse como una migración universalmente repetible.
- Los archivos de rendimiento y reportes son de validación/consulta y se ejecutan cuando la estructura ya está instalada.

## 9. Seguridad, auditoría y monitoreo

### Roles y privilegios

`operaciones/04_seguridad_roles.sql` define roles de grupo con privilegios diferenciados:

| Rol | Función | Alcance general |
|---|---|---|
| `rol_medico` | Personal médico | Consulta y actualización de información clínica autorizada; sin permiso de eliminación de registros maestros. |
| `rol_enfermeria` | Enfermería | Lectura de información clínica y hospitalaria definida en el script. |
| `rol_recepcion` | Recepción | Registro y consulta de datos básicos de pacientes y expedientes. |
| `rol_auditor` | Auditoría | Lectura de la bitácora de auditoría. |

El script crea usuarios de prueba, los vincula a roles y agrega la columna `empleado.usuario_bd` para asociar la identidad de PostgreSQL con el empleado correspondiente. Los nombres y contraseñas de prueba incluidos en el script son únicamente datos de demostración: deben cambiarse antes de cualquier uso compartido o despliegue.

### Row Level Security (RLS)

Se habilita RLS en la tabla `expediente`. Las políticas limitan las filas visibles según el tipo de usuario y su departamento:

- Médico: expedientes de pacientes con consultas o ingresos relacionados con el departamento asignado.
- Enfermería: expedientes de pacientes con ingreso activo en su departamento.
- Recepción: lectura e inserción de expedientes conforme a las políticas definidas.

La función auxiliar `fn_departamento_de()` obtiene el departamento vinculado al usuario conectado. La carpeta `docs/` contiene evidencia visual de las pruebas de acceso y aislamiento.

### Auditoría

`operaciones/03_auditoria.sql` crea `auditoria_log`, la función `fn_auditoria_general()` y triggers sobre tablas clínicas seleccionadas. Se registran el usuario de sesión, rol activo, fecha, tabla, operación, aplicación, dirección IP y datos JSONB asociados a la operación.

Como complemento, el documento `docs/informe_seguridad_auditoria_alertas.md` describe la configuración de pgAudit a nivel del servidor. Para habilitar pgAudit se requiere instalar la extensión compatible con la versión de PostgreSQL y configurar `shared_preload_libraries` en `postgresql.conf`; después debe reiniciarse el servicio. Si también se utiliza `pg_stat_statements`, ambas bibliotecas deben declararse juntas en el parámetro, sin sobrescribir accidentalmente una configuración existente. La habilitación de pgAudit no debe darse por realizada únicamente por ejecutar el SQL de la bitácora transaccional.

### Monitoreo y alertas

- `operaciones/02_monitoreo.sql` contiene consultas para revisar sesiones, conexiones, consultas, bloqueos, WAL y estadísticas. También crea la extensión `pg_stat_statements`; esta requiere configuración previa de `shared_preload_libraries` y reinicio del servicio.
- `operaciones/05_alertas_espacio.sql` crea `monitoreo.medicion_bd`, `monitoreo.medicion_filesystem` y la vista `monitoreo.v_alertas`.

La vista de alertas contempla estos umbrales:

| Indicador | Umbral definido |
|---|---:|
| Espacio libre del sistema de archivos | Menos del 20 % |
| Crecimiento de la base de datos en siete días | Más de 2 GB |
| Tamaño de partición de consultas o estudios | Más de 5 GB |

El SQL de alertas proporciona la estructura y la lógica de evaluación. Las mediciones deben insertarse para que la vista pueda evaluar el estado; el archivo incluye ejemplos comentados para registrar el tamaño actual de la base de datos. La recolección del espacio del sistema de archivos requiere alimentar `monitoreo.medicion_filesystem` desde el sistema operativo o desde un proceso externo.

### Parámetros de servidor descritos en la documentación

El documento de seguridad y administración describe parámetros operativos para consultas lentas, rotación de logs y autovacuum. Entre ellos se encuentran `log_min_duration_statement`, `logging_collector`, `log_rotation_age`, `log_rotation_size` y ajustes de autovacuum para tablas de alto tráfico. Estos valores deben revisarse y aplicarse en el archivo `postgresql.conf` del servidor correspondiente; no todos se configuran automáticamente mediante los scripts SQL.

## 10. Replicación física primaria-secundaria

La práctica complementaria documenta una réplica física de PostgreSQL 16 mediante streaming replication entre dos equipos ubicados en redes distintas. Tailscale se utilizó como red privada para que ambos servidores pudieran comunicarse sin exponer PostgreSQL directamente a Internet.

### 10.1 Esquema de la conexión

- **Primario:** equipo que recibe las operaciones de escritura y genera WAL.
- **Secundario:** máquina virtual con PostgreSQL 16.15 configurada como standby.
- **Red privada:** Tailscale, con direcciones privadas de la red 100.x.
- **Puerto PostgreSQL:** 5432.
- **Usuario de replicación:** `replicador`.

Las direcciones IP y rutas del documento de práctica son específicas de los equipos utilizados. Deben sustituirse por las direcciones y ubicaciones reales de cada instalación; no deben copiarse sin validación.

### 10.2 Configuración del servidor primario

En `postgresql.conf` se documentaron los siguientes parámetros:

```conf
listen_addresses = '*'
wal_level = replica
max_wal_senders = 5
hot_standby = on
wal_keep_size = 512MB
```

Descripción:

- `listen_addresses`: permite que PostgreSQL escuche en las interfaces configuradas.
- `wal_level = replica`: habilita la información WAL necesaria para la replicación física.
- `max_wal_senders = 5`: establece el máximo de procesos emisores WAL simultáneos.
- `hot_standby = on`: permite consultas de solo lectura en el servidor standby.
- `wal_keep_size = 512MB`: conserva una cantidad de WAL para facilitar la recuperación de una desconexión temporal.

Se crea un usuario dedicado:

```sql
CREATE ROLE replicador WITH REPLICATION LOGIN PASSWORD '<CONTRASENA_SEGURA>';
```

La contraseña real debe entregarse por un canal seguro y nunca debe incluirse en GitHub, en capturas públicas ni en este README.

En `pg_hba.conf` del primario se agrega una regla limitada a la IP Tailscale exacta del secundario:

```conf
host    replication    replicador    <IP_TAILSCALE_SECUNDARIO>/32    scram-sha-256
```

Después se reinicia PostgreSQL y se verifica que no existan errores en las reglas:

```sql
SELECT line_number, type, database, user_name, address, auth_method, error
FROM pg_hba_file_rules
WHERE error IS NOT NULL;
```

También se comprueba que el servicio escuche en el puerto 5432 y que el equipo secundario pueda alcanzar la dirección Tailscale del primario.

### 10.3 Preparación del servidor secundario

En la máquina secundaria se instala PostgreSQL y el cliente de la misma versión mayor que el primario. Antes de iniciar la copia:

1. Se comprueba la conectividad por Tailscale.
2. Se valida que el usuario `replicador` pueda autenticarse.
3. Se verifica el espacio libre de almacenamiento.
4. Se crean los directorios de destino de los tablespaces.
5. Se asigna la propiedad de esos directorios al usuario del sistema `postgres` y permisos restrictivos.

La conexión de replicación se puede comprobar desde el secundario con:

```bash
psql "host=<IP_TAILSCALE_PRIMARIO> port=5432 user=replicador dbname=postgres replication=1" -c "IDENTIFY_SYSTEM"
```

Una respuesta correcta de `IDENTIFY_SYSTEM` confirma que el secundario puede establecer la conexión de protocolo de replicación con el primario.

### 10.4 Copia inicial con pg_basebackup

La copia inicial se realiza con `pg_basebackup`, usando la opción `-R` para preparar el standby y guardar la información de conexión. La documentación registra el uso de:

- `-D`: directorio de datos del secundario.
- `-R`: crea `standby.signal` y configura `primary_conninfo` en `postgresql.auto.conf`.
- `-X stream`: transmite WAL durante la copia.
- `-P`: muestra el progreso.
- `--tablespace-mapping`: adapta las rutas de tablespaces del primario a directorios disponibles en el secundario.

La práctica utiliza cuatro tablespaces: `Datos`, `Bitacoras`, `Historicos` e `Indices`. Las rutas de origen y destino deben coincidir con las configuradas en cada servidor.

**Advertencia crítica:** el script de preparación del secundario detiene PostgreSQL y elimina el contenido del directorio de datos de destino antes de ejecutar `pg_basebackup`. Solo debe ejecutarse en la máquina secundaria correcta, después de verificar cuidadosamente las variables `DATA`, `TS_ORIGEN`, `TS_DESTINO` y la IP del primario. Nunca debe ejecutarse en el servidor primario ni sobre un directorio que contenga datos que deban conservarse.

### 10.5 Validación de la réplica

La documentación de la práctica registra los siguientes resultados:

- `pg_basebackup` completó la transferencia indicada como **74,563/74,563 kB (100 %)** y **5/5 tablespaces**.
- Existe el archivo `standby.signal`.
- `postgresql.auto.conf` contiene la configuración `primary_conninfo` para el primario y el nombre de aplicación `replica_hospital`.
- `SELECT pg_is_in_recovery();` devolvió `t`, indicando que el servidor está en recuperación como standby.
- Una tabla de prueba creada en la base `hospital_san_lucas` del primario fue consultada y apareció en el secundario.

Consultas adicionales recomendadas para completar el diagnóstico:

En el primario:

```sql
SELECT client_addr, application_name, state, sync_state
FROM pg_stat_replication;
```

En el secundario:

```sql
SELECT status, sender_host, sender_port
FROM pg_stat_wal_receiver;
```


## 11. Respaldos y recuperación

Se incluyen dos scripts de respaldo:

- `respaldos/respaldo_completo.sh`: versión para Linux.
- `respaldos/respaldo_completo.bat`: versión para Windows.

Ambos están diseñados para generar tres tipos de respaldo:

1. **Respaldo lógico de la base de datos:** `pg_dump` en formato custom (`-F c`).
2. **Respaldo de objetos globales:** `pg_dumpall --globals-only`, para roles y otros objetos globales.
3. **Respaldo físico:** `pg_basebackup`, para obtener una copia física del clúster.

### Antes de ejecutar los scripts

- Revisar y cambiar las credenciales de ejemplo. En la versión actual del repositorio hay credenciales definidas directamente en los scripts; no deben utilizarse tal como están ni mantenerse en un repositorio compartido.
- Preferir autenticación mediante `.pgpass` con permisos restrictivos, un gestor de secretos o un mecanismo seguro equivalente.
- Verificar que el usuario tenga permisos suficientes para cada tipo de respaldo.
- Comprobar que las rutas de destino existan o puedan crearse y que haya espacio suficiente.
- Ajustar el nombre de la base, usuario, host, directorio de respaldo y ruta de los ejecutables a la instalación local.
- Proteger los archivos de respaldo, ya que pueden contener información sensible.

### Ejecución en Linux

```bash
chmod +x respaldos/respaldo_completo.sh
bash respaldos/respaldo_completo.sh
```

El script utiliza el directorio `/backups` como destino. Debe comprobarse que el usuario que ejecuta el proceso pueda crear archivos allí.

### Ejecución en Windows

Abrir CMD o PowerShell con los permisos necesarios y ejecutar:

```bat
respaldos\respaldo_completo.bat
```

El archivo utiliza `C:\respaldos_hospital` como destino y contiene una ruta de binarios PostgreSQL 18. Si la instalación local se encuentra en otra versión o ubicación, se debe editar esa ruta antes de ejecutar el script.

### Restauración lógica de referencia

Para restaurar un respaldo custom generado por `pg_dump -F c`, crear primero una base de datos vacía y utilizar `pg_restore`:

```bash
createdb -U postgres hospital_san_lucas_restauracion
pg_restore -U postgres -d hospital_san_lucas_restauracion /ruta/al/archivo.dump
```

Los roles y objetos globales se pueden recuperar desde el archivo generado por `pg_dumpall --globals-only` mediante una sesión administrativa:

```bash
psql -U postgres -f /ruta/al/archivo_roles.sql
```

La restauración física requiere un procedimiento diferente, compatible con la versión mayor de PostgreSQL y con la configuración del clúster. No se debe restaurar una copia física sobre un directorio de datos activo. Antes de considerar un respaldo válido, debe realizarse una restauración de prueba y comprobar la consistencia de los datos. Los scripts del repositorio documentan la generación de respaldos; la ejecución periódica automatizada y un simulacro completo de restauración deben configurarse y verificarse en el entorno donde se despliegue el proyecto.

## 12. Pruebas, consultas y evidencias

### Rendimiento

`operaciones/01_explain_analyze.sql` contiene consultas de análisis de planes de ejecución mediante `EXPLAIN ANALYZE`. Se utiliza para observar el comportamiento de las consultas y valorar el efecto de índices y particiones.

### Reportes funcionales

`reportes/01_consultas_reporte.sql` contiene consultas basadas en las vistas para obtener:

1. Ocupación por departamento.
2. Agenda quirúrgica del día.
3. Insumos por debajo del stock mínimo.
4. Turnos activos y próximos.
5. Interconsultas pendientes ordenadas por prioridad.
6. Estudios por estado y categoría.
7. Diagnósticos más frecuentes de los últimos 90 días.
8. Mantenimientos pendientes priorizados por criticidad.

### Evidencia visual

La carpeta `docs/` incluye el diagrama general, diagramas de módulos y capturas de pruebas de seguridad, auditoría y alertas. El archivo `docs/informe_seguridad_auditoria_alertas.md` amplía la explicación de la administración de almacenamiento, las configuraciones de auditoría y los umbrales de monitoreo.

## 13. Comprobaciones posteriores a la instalación

Después de ejecutar los scripts, se recomienda comprobar lo siguiente desde la **Query Tool** de pgAdmin conectada a la base `hospital_san_lucas`. Para ver el resultado de cada consulta por separado, selecciona únicamente esa consulta y presiona **F5**: pgAdmin ejecuta solo el texto seleccionado y muestra el resultado en la pestaña *Data Output*.

```sql
-- Confirmar la base de datos actual
SELECT current_database();

-- Listar tablas del esquema público
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Revisar vistas
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- Revisar particiones
SELECT * FROM pg_partition_tree('consulta');
SELECT * FROM pg_partition_tree('estudio_diagnostico');

-- Revisar roles
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg\_%' ORDER BY rolname;

-- Comprobar estado de recuperación (en el secundario)
SELECT pg_is_in_recovery();

-- Consultar alertas de almacenamiento
SELECT * FROM monitoreo.v_alertas;
```

Las tablas, vistas y roles también pueden verificarse de forma gráfica en el árbol de objetos de pgAdmin (*Databases → hospital_san_lucas → Schemas → public* y *Login/Group Roles*), actualizando con clic derecho → *Refresh*.

La última consulta depende de que existan mediciones en las tablas de monitoreo. Para revisar la replicación en tiempo real, utilizar además `pg_stat_replication` en el primario y `pg_stat_wal_receiver` en el secundario.


## 14. Referencias de archivos principales

| Área | Archivo |
|---|---|
| Modelo y estructura | `scripts-iniciales/01_hospital_san_lucas_ddl.sql` |
| Carga de datos | `scripts-iniciales/03_poblacion_de_datos.sql` |
| Particionamiento | `scripts-iniciales/02_particiones.sql` |
| Índices | `scripts-iniciales/04_indices.sql` |
| Vistas | `scripts-iniciales/05_vistas.sql` |
| Funciones | `reglas_de_negocio/01_funciones.sql` |
| Triggers | `reglas_de_negocio/02_triggers.sql` |
| Rendimiento | `operaciones/01_explain_analyze.sql` |
| Monitoreo | `operaciones/02_monitoreo.sql` |
| Auditoría | `operaciones/03_auditoria.sql` |
| Roles y RLS | `operaciones/04_seguridad_roles.sql` |
| Alertas | `operaciones/05_alertas_espacio.sql` |
| Reportes | `reportes/01_consultas_reporte.sql` |
| Respaldos Linux | `respaldos/respaldo_completo.sh` |
| Respaldos Windows | `respaldos/respaldo_completo.bat` |
| Documentación de seguridad | `docs/informe_seguridad_auditoria_alertas.md` |

---

## 16. Autoría y propósito

Proyecto académico desarrollado por los autores indicados al inicio de este documento para el caso de estudio **Hospital Regional San Lucas**, como parte del proyecto final de Administración de Bases de Datos.