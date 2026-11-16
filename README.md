# Hospital Regional San Lucas

## Proyecto final de Administración de Bases de Datos

Repositorio académico del caso de estudio **Hospital Regional San Lucas** (escenario 3). El proyecto implementa en PostgreSQL una base de datos de 35 tablas para administrar información clínica y operativa, e incorpora reglas de negocio, particionamiento, tablespaces, optimización de consultas, seguridad, auditoría, monitoreo, respaldos y una réplica física primaria-secundaria.

---

## Autores


| Nombre                         | Carnet  |
| ------------------------------ | ------- |
| Bryan Misael Sanchez Ramirez   | SR23022 |
| Cesia Mariena Alfaro Hernández | AH23007 |
| Vanessa Gabriela Arévalo Elías | AE25016 |
| Liliana Melissa Cruz Henriquez | CH20014 |


---

## 1. Objetivos del proyecto

Diseñar e implementar una base de datos que centralice la operación de un hospital regional y cubra los ocho requerimientos del escenario:

- Historial clínico electrónico unificado (personas, pacientes, expedientes y consultas).
- Programación de recursos quirúrgicos (quirófanos, cirugías y equipo quirúrgico).
- Control de camas hospitalarias e ingresos.
- Gestión de inventario médico.
- Turnos y guardias del personal médico y de enfermería.
- Coordinación de interconsultas.
- Control de equipos médicos y su mantenimiento.
- Gestión de estudios diagnósticos de laboratorio e imagenología.

Además: aplicar reglas de integridad en el servidor, mejorar el acceso con índices, vistas y particiones, administrar el espacio con tablespaces, controlar el acceso y auditar, monitorear la capacidad, generar respaldos y configurar una réplica física.

## 2. Tecnologías y entorno


| Componente                               | Uso en el proyecto                                                              |
| ---------------------------------------- | ------------------------------------------------------------------------------- |
| PostgreSQL                               | Motor relacional. Los scripts se probaron en PostgreSQL 16.                     |
| SQL y PL/pgSQL                           | Esquema, consultas, funciones, triggers, vistas y controles.                    |
| pgAdmin 4                                | Creación de la base y ejecución de los scripts con la Query Tool.               |
| `psql`                                   | Cliente de terminal; se usa en la replicación y en `respaldos/restauracion.sh`. |
| `btree_gist`                             | Restricciones de exclusión para evitar solapamientos de horarios.               |
| `pgcrypto`                               | Funciones de cifrado simétrico del DUI.                                         |
| `pg_stat_statements`                     | Estadísticas de consultas; requiere configuración del servidor.                 |
| `pg_dump`, `pg_dumpall`, `pg_basebackup` | Respaldos lógico, de globales y físico.                                         |
| Tailscale                                | Red privada entre el primario y el secundario de la réplica.                    |
| Linux / Windows                          | Hay scripts de respaldo para ambos sistemas.                                    |


### Versiones y compatibilidad

La réplica usa PostgreSQL **16.15** en el secundario, y el primario debe ser de la misma versión mayor. El script de respaldo de Windows contiene una ruta de binarios de PostgreSQL **18**; antes de ejecutarlo hay que ajustarla a la versión instalada.

## 3. Estructura del repositorio

```text
Proyecto-final-ABD/
├── README.md
├── docs/
│   ├── comprobaciones/
│   │   ├── informe_seguridad_auditoria_alertas.md
│   │   └── seguridad_auditoria/
│   │       ├── 01_bloqueo_delete_paciente.png
│   │       ├── 02_rls_expediente_cardio.png
│   │       ├── 03_auditoria_log.png
│   │       └── 04_alertas_espacio.png
│   └── diagramas/
│       ├── 01_hospital_san_lucas_diagrama_completo.png
│       └── 02_ ... 12_ (diagramas por módulo)
├── 01-scripts-iniciales-1/
│   ├── 01_hospital_san_lucas_ddl.sql
│   ├── 02_poblacion_de_datos.sql
│   ├── 03_particiones.sql
│   └── 04_ajustes_post_carga.sql
├── 02-reglas_de_negocio/
│   ├── 05_funciones.sql
│   └── 06_triggers.sql
├── 03-estructura/
│   ├── 07_indices.sql
│   └── 08_vistas.sql
├── 04-operaciones-1/
│   ├── 09_auditoria.sql
│   ├── 10_seguridad_roles.sql
│   ├── 11_monitoreo.sql
│   └── 12_alertas_espacio.sql
├── 05-scripts-iniciales-2/
│   └── 13_tablespaces.sql
├── 06-operaciones-2/
│   ├── 14_autovacuum_particiones.sql
│   └── 15_explain_analyze.sql
├── 07-reportes/
│   └── 16_consultas_reporte.sql
└── respaldos/
    ├── respaldo_completo.sh
    ├── respaldo_completo.bat
    ├── restauracion.sh
    └── replica_secundario.sh
```

## 4. Diseño de la base de datos

El modelo tiene **35 tablas**: 10 catálogos (`especialidad`, `cargo`, `departamento` y siete tablas `tipo_*`) y 25 tablas operativas. Áreas funcionales:

1. **Personas y contacto:** `persona`, teléfonos, direcciones y contactos de emergencia.
2. **Personal y departamentos:** `empleado`, `cargo`, `especialidad`, `departamento`, `correo_empleado`.
3. **Pacientes y expedientes:** `paciente` y `expediente` (un expediente por paciente).
4. **Camas e ingresos:** `tipo_cama`, `cama`, `ingreso_hospitalario`.
5. **Consultas:** `consulta`.
6. **Quirófanos y cirugías:** `tipo_quirofano`, `quirofano`, `tipo_cirugia`, `cirugia`, `cirugia_equipo`.
7. **Inventario:** `tipo_insumo`, `insumo`, `movimiento_inventario`, `detalle_movimiento_inventario`.
8. **Turnos:** `tipo_turno`, `turno`.
9. **Interconsultas:** `interconsulta`.
10. **Equipos y mantenimiento:** `equipo_medico`, `tipo_mantenimiento`, `mantenimiento_equipo`.
11. **Estudios diagnósticos:** `tipo_estudio`, `estudio_diagnostico`, `detalle_resultado_estudio`.

`persona` es el supertipo; `empleado` y `paciente` son subtipos cuya clave primaria es también clave foránea de `persona`. El diagrama general y los diagramas por módulo están en `docs/diagramas/`.

### Integridad

El DDL usa claves primarias, foráneas, `UNIQUE`, `CHECK` e identidades. Incluye:

- Formato de DUI, teléfono y correo; valores permitidos para estados, prioridades y categorías; rangos de peso, estatura, fechas y cantidades.
- Índices únicos parciales: un solo registro principal de teléfono, dirección, contacto y correo por persona, y un solo ingreso activo por cama y por paciente.
- Cuatro restricciones de exclusión con `btree_gist`: cirugías por quirófano, por cirujano y por anestesiólogo, y turnos por empleado.

## 5. Funciones y triggers

Los archivos de `02-reglas_de_negocio/` implementan las validaciones en el servidor. Ejecutar primero las funciones y después los triggers.


| Función                                      | Trigger(s)                                                                                                            | Qué hace                                                                                      |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `es_medico`, `fn_validar_medico`             | `trg_consulta_medico`, `trg_ingreso_medico`, `trg_cirugia_medicos`, `trg_interconsulta_medicos`, `trg_estudio_medico` | Exige empleado activo con especialidad y licencia en las columnas indicadas.                  |
| `fn_validar_anestesiologo`                   | `trg_cirugia_anestesiologo`                                                                                           | El anestesiólogo debe tener especialidad de anestesiología.                                   |
| `fn_validar_interconsulta`                   | `trg_interconsulta_especialidad`                                                                                      | El especialista debe tener la especialidad solicitada.                                        |
| `fn_ocupar_cama`, `fn_ingreso_gestiona_cama` | `trg_ingreso_cama`                                                                                                    | Ocupa o libera la cama en ingresos, altas, cancelaciones y traslados.                         |
| `fn_actualizar_stock`                        | `trg_detalle_stock`                                                                                                   | Suma o resta stock según el tipo de movimiento.                                               |
| `fn_bloquear_modificacion`                   | `trg_detalle_inmutable`                                                                                               | Impide modificar o borrar detalles de movimiento; las correcciones se registran como ajustes. |
| `fn_encriptar_dui`, `fn_desencriptar_dui`    | (ninguno)                                                                                                             | Funciones de cifrado del DUI; ver sección 9.5.                                                |


`06_triggers.sql` termina con pruebas: dos de ellas **deben fallar** (consulta con un empleado que no es médico y modificación de un detalle de inventario). Si la Query Tool de pgAdmin se detiene o revierte el script al llegar a ellas, ejecute primero solo los `CREATE TRIGGER` y después las pruebas seleccionándolas una por una.

## 6. Particionamiento, índices, vistas, tablespaces y autovacuum

### Particionamiento

`01-scripts-iniciales-1/03_particiones.sql` convierte en tablas particionadas por rango trimestral:

- `consulta`, por `fecha_hora_consulta`.
- `estudio_diagnostico`, por `fecha_hora_solicitud`.

Hay particiones para 4T-2026 y los cuatro trimestres de 2027, más una partición `DEFAULT`. El script migra las filas existentes, ajusta las secuencias, reemplaza las claves primarias por claves compuestas con la fecha y agrega a `detalle_resultado_estudio` la columna `fecha_hora_solicitud` con una clave foránea compuesta (un trigger la completa al insertar).

**Consideración:** es una migración estructural. Debe ejecutarse una sola vez sobre la estructura inicial ya poblada, en una base de prueba o respaldada.

**Crecimiento:** las particiones llegan hasta 4T-2027. Cada trimestre hay que crear la siguiente en ambas tablas, por ejemplo:

```sql
CREATE TABLE consulta_2028_q1 PARTITION OF consulta
  FOR VALUES FROM ('2028-01-01') TO ('2028-04-01') TABLESPACE ts_datos;
CREATE TABLE estudio_diagnostico_2028_q1 PARTITION OF estudio_diagnostico
  FOR VALUES FROM ('2028-01-01') TO ('2028-04-01') TABLESPACE ts_datos;
```

Después se vuelve a ejecutar `06-operaciones-2/14_autovacuum_particiones.sql`, se mueven o separan las particiones vencidas y se verifica que la partición `DEFAULT` siga vacía.

### Índices

`03-estructura/07_indices.sql` crea índices sobre claves foráneas y filtros frecuentes: compuestos (por ejemplo `consulta (id_paciente, fecha_hora_consulta)`), parciales (camas disponibles u ocupadas, cirugías programadas, turnos activos, interconsultas, mantenimientos y estudios pendientes, insumos bajo mínimo) y únicos parciales. Termina con `ANALYZE`.

### Vistas

`03-estructura/08_vistas.sql` define nueve vistas: `vista_ocupacion_departamento`, `vista_agenda_quirurgica`, `vista_insumos_reposicion`, `vista_turnos_personal`, `vista_interconsultas_pendientes`, `vista_estudios_por_estado`, `vista_top_diagnosticos`, `vista_mantenimientos_pendientes` y `vista_resumen_expediente_paciente`. Las dos que dependen de `consulta` se eliminan antes de particionar y se recrean aquí.

### Tablespaces

`05-scripts-iniciales-2/13_tablespaces.sql` crea cuatro tablespaces y mueve objetos a ellos:


| Tablespace | Contenido |
|---|---|
| `ts_datos` | `consulta` y `estudio_diagnostico` (destino de sus particiones nuevas), `detalle_resultado_estudio`, `movimiento_inventario`, `detalle_movimiento_inventario`. |
| `ts_indices` | `ix_consulta_paciente`, `ix_estudio_paciente`, `ix_estudio_medico`, `ix_estudio_tipo_estado`, `ix_estudio_pendientes`, `ix_ingreso_fecha_estado`. |
| `ts_bitacoras` | `auditoria_log` y las tablas de medición `monitoreo.medicion_bd` y `monitoreo.medicion_filesystem`. |
| `ts_historicos` | Las particiones de 4T-2026 de `consulta` y `estudio_diagnostico`. |


Antes de ejecutarlo hay que crear las carpetas con propietario `postgres` y permisos `700` (los comandos están comentados en el script; hay variante Linux, `/var/lib/pgsql/tablespaces/`, y Windows, `C:/PostgreSQL/Tablespaces/`) y ejecutarlo **después** de índices y auditoría, porque mueve objetos creados en esos scripts. `CREATE TABLESPACE` no puede ejecutarse dentro de una transacción: si pgAdmin lo rechaza, ejecute cada sentencia por separado o use `psql -f`. Mover una tabla particionada solo cambia el destino de sus particiones futuras; las existentes se mueven una a una.

### Autovacuum

Autovacuum actúa sobre las particiones, no sobre la tabla padre (PostgreSQL rechaza parámetros de almacenamiento en una tabla particionada). `06-operaciones-2/14_autovacuum_particiones.sql` recorre las particiones y fija `autovacuum_vacuum_scale_factor = 0.05` y `autovacuum_analyze_scale_factor = 0.02`, y en las de `consulta` también `autovacuum_vacuum_cost_limit = 1000`. Hay que volver a ejecutarlo al crear particiones nuevas.

## 7. Requisitos previos e instalación

### Requisitos

- PostgreSQL instalado y pgAdmin 4 con una conexión registrada al servidor.
- Acceso administrativo (por ejemplo, `postgres`) para crear la base, extensiones, roles y tablespaces.
- Espacio suficiente para datos, índices, WAL y respaldos.
- El repositorio clonado o descargado:

```text
https://github.com/Misael-Sanchez-SR23022/Proyecto-final-ABD.git
```

### Crear la base de datos

En pgAdmin: **Databases → Create → Database…**, nombre `hospital_san_lucas`, propietario `postgres`. O desde la Query Tool conectada a `postgres`:

```sql
CREATE DATABASE hospital_san_lucas;
```

Todos los scripts se ejecutan dentro de esa base (clic derecho sobre ella → *Query Tool*). Si usa otro nombre, ajústelo en los scripts de `respaldos/`.

## 8. Orden de ejecución de los scripts

Para una instalación nueva, ejecute los archivos en este orden, revisando la pestaña **Messages** de cada uno antes de pasar al siguiente (cargar con *Open File* y ejecutar con **F5**). El prefijo numérico de carpetas y archivos indica el orden:


| Orden | Archivo                                                | Propósito                                                                                                |
| -----: | ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| 1     | `01-scripts-iniciales-1/01_hospital_san_lucas_ddl.sql` | Crea tablas, claves, restricciones y la extensión `btree_gist`.                                          |
| 2     | `01-scripts-iniciales-1/02_poblacion_de_datos.sql`     | Inserta catálogos y datos de prueba (35 tablas).                                                         |
| 3     | `01-scripts-iniciales-1/03_particiones.sql`            | Migra `consulta` y `estudio_diagnostico` a tablas particionadas.                                         |
| 4     | `01-scripts-iniciales-1/04_ajustes_post_carga.sql`     | Sincroniza las secuencias con los IDs cargados y alinea el estado de las camas con los ingresos activos. |
| 5     | `02-reglas_de_negocio/05_funciones.sql`                | Crea funciones y la extensión `pgcrypto`.                                                                |
| 6     | `02-reglas_de_negocio/06_triggers.sql`                 | Crea los triggers (las dos pruebas finales de error son intencionales).                                  |
| 7     | `03-estructura/07_indices.sql`                         | Crea índices y actualiza estadísticas.                                                                   |
| 8     | `03-estructura/08_vistas.sql`                          | Crea las vistas.                                                                                         |
| 9     | `04-operaciones-1/09_auditoria.sql`                    | Crea `auditoria_log` y sus triggers.                                                                     |
| 10    | `04-operaciones-1/10_seguridad_roles.sql`              | Crea roles, usuarios de prueba, privilegios y RLS.                                                       |
| 11    | `04-operaciones-1/11_monitoreo.sql`                    | Consultas de monitoreo; crea `pg_stat_statements`.                                                       |
| 12    | `04-operaciones-1/12_alertas_espacio.sql`              | Esquema `monitoreo` y vista `v_alertas`.                                                                 |
| 13    | `05-scripts-iniciales-2/13_tablespaces.sql`            | Crea tablespaces y mueve objetos (ver sección 6).                                                        |
| 14    | `06-operaciones-2/14_autovacuum_particiones.sql`       | Ajusta autovacuum por partición.                                                                         |
| 15    | `06-operaciones-2/15_explain_analyze.sql`              | Planes de ejecución con y sin índices.                                                                   |
| 16    | `07-reportes/16_consultas_reporte.sql`                 | Consultas de reporte sobre las vistas.                                                                   |


### Consideraciones sobre el orden

- El DDL se ejecuta en una base vacía.
- Los datos se cargan antes de particionar, porque el script de particiones migra las filas existentes.
- Los datos se cargan antes de crear los triggers; por eso `04_ajustes_post_carga.sql` alinea las camas. Sin ese script, cualquier `INSERT` sin `id` explícito falla con *duplicate key*.
- La auditoría se instala antes de los roles, porque el script de seguridad ajusta la función de auditoría y da lectura de la bitácora al rol auditor.
- Los tablespaces van después de índices y auditoría porque mueven objetos que esos scripts crean.
- `10_seguridad_roles.sql` elimina y recrea los roles de prueba si ya existen; `07_indices.sql` elimina y crea índices. Ninguno es una migración repetible sin revisión.
- `15_explain_analyze.sql`, `11_monitoreo.sql` y `16_consultas_reporte.sql` tienen varias consultas independientes: para ver el resultado de una, selecciónela y presione **F5** (pgAdmin solo muestra el resultado de la última sentencia ejecutada).

## 9. Seguridad, auditoría y monitoreo

### 9.1 Roles y privilegios

`04-operaciones-1/10_seguridad_roles.sql` crea cuatro roles de grupo sin inicio de sesión, cinco usuarios de prueba y retira a `PUBLIC` el permiso de crear objetos en `public`:


| Rol              | Privilegios                                                                                                                                   | Restricción                                |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `rol_medico`     | `SELECT`, `INSERT`, `UPDATE` en `consulta` y `estudio_diagnostico`; `SELECT` en pacientes, expediente, personal, catálogos, ingresos y camas. | Sin `DELETE`.                              |
| `rol_enfermeria` | `SELECT` en tablas clínicas y de hospitalización.                                                                                             | Sin escritura.                             |
| `rol_recepcion`  | `SELECT` e `INSERT` en `paciente`, `persona` y `expediente`.                                                                                  | Sin acceso a `consulta` ni a diagnósticos. |
| `rol_auditor`    | `SELECT` en `auditoria_log`.                                                                                                                  | Sin acceso a datos clínicos.               |


La columna `empleado.usuario_bd` vincula cada usuario de base de datos con su empleado. **Los nombres y contraseñas de los usuarios de prueba son datos de demostración y deben cambiarse antes de cualquier uso compartido.**

### 9.2 Row Level Security

RLS está activa en `expediente`. La función `fn_departamento_de()` (`SECURITY DEFINER`) obtiene el departamento del usuario conectado. Políticas:

- Médico: expedientes de pacientes con consultas o ingresos en su departamento.
- Enfermería: pacientes con ingreso **activo** en su departamento.
- Recepción: consulta e inserción.

Evidencia en `docs/comprobaciones/seguridad_auditoria/`.

### 9.3 Auditoría

`04-operaciones-1/09_auditoria.sql` crea `auditoria_log` y la función `fn_auditoria_general()` (`SECURITY DEFINER`). Registra usuario de sesión, fecha, tabla, operación, datos en JSONB (`antes` y `despues` en las actualizaciones), aplicación e IP del cliente. Los triggers cubren `INSERT`, `UPDATE` y `DELETE` en cuatro tablas: `paciente`, `expediente`, `consulta` y `estudio_diagnostico` (en estas dos últimas se anota el nombre de la partición). Solo el rol auditor puede leer la bitácora.

**pgAudit no está implementado en este repositorio**; la auditoría es la descrita arriba, basada en triggers.

### 9.4 Monitoreo y alertas

- `04-operaciones-1/11_monitoreo.sql` contiene consultas de **espacio** por tabla y por partición, **consultas lentas** (`pg_stat_activity` para las activas por más de 5 segundos y `pg_stat_statements` para el histórico) y **WAL** (`pg_ls_waldir()`, `pg_stat_archiver` y parámetros de archivado). `pg_stat_statements` requiere agregarlo a `shared_preload_libraries` en `postgresql.conf` y reiniciar el servicio.
- `04-operaciones-1/12_alertas_espacio.sql` crea el esquema `monitoreo`, las tablas `medicion_bd` y `medicion_filesystem` y la vista `monitoreo.v_alertas`:


| Regla                                                          | Umbral         | Estado      |
| -------------------------------------------------------------- | --------------: | ----------- |
| Espacio libre del sistema de archivos                          | Menos del 20 % | CRITICO     |
| Crecimiento de la base en 7 días                               | Más de 2 GB    | ADVERTENCIA |
| Tamaño de cada partición de `consulta` y `estudio_diagnostico` | Más de 5 GB    | ADVERTENCIA |


La regla de particiones funciona sin datos adicionales. Las otras dos necesitan mediciones: el tamaño de la base se registra con el `INSERT` comentado al final del script, y el espacio del sistema de archivos debe alimentarse desde el sistema operativo o un proceso externo.

### 9.5 Cifrado del DUI

`pgcrypto` se instala con `02-reglas_de_negocio/05_funciones.sql`. `fn_encriptar_dui(dui, clave)` y `fn_desencriptar_dui(cifrado, clave)` aplican cifrado simétrico PGP con AES-256. Estado actual: **`persona.dui` se almacena en texto plano** (con validación de formato y unicidad); las funciones están disponibles, pero ninguna tabla guarda aún el DUI cifrado. Usar una columna cifrada propia queda como mejora.

### 9.6 Parámetros de servidor

Estos parámetros se configuran en `postgresql.conf` del servidor y no los aplican los scripts SQL: `shared_preload_libraries` (para `pg_stat_statements`) y, para la réplica, los de la sección 10.2.

## 10. Replicación física primaria-secundaria

Se configuró *streaming replication* entre dos equipos en redes distintas. Tailscale se usó como red privada para no exponer PostgreSQL a Internet.

### 10.1 Esquema de la conexión

- **Primario:** recibe las escrituras y genera WAL.
- **Secundario:** máquina virtual con PostgreSQL 16.15 en modo standby.
- **Red:** Tailscale (direcciones 100.x), puerto 5432.
- **Usuario de replicación:** `replicador`.

Las IP y rutas son específicas de los equipos usados y deben sustituirse en otra instalación.

### 10.2 Configuración del primario

En `postgresql.conf`:

```conf
listen_addresses = '*'
wal_level = replica
max_wal_senders = 5
hot_standby = on
wal_keep_size = 512MB
```

Rol dedicado y regla en `pg_hba.conf`, limitada a la IP Tailscale exacta del secundario:

```sql
CREATE ROLE replicador WITH REPLICATION LOGIN PASSWORD '<CONTRASENA_SEGURA>';
```

```conf
host    replication    replicador    <IP_TAILSCALE_SECUNDARIO>/32    scram-sha-256
```

La contraseña real no debe incluirse en GitHub ni en capturas públicas. Después de reiniciar, se revisan errores en las reglas:

```sql
SELECT line_number, type, database, user_name, address, auth_method, error
FROM pg_hba_file_rules WHERE error IS NOT NULL;
```

### 10.3 Preparación del secundario

Instalar PostgreSQL de la misma versión mayor, comprobar la conectividad por Tailscale, validar que `replicador` pueda autenticarse, verificar el espacio libre y crear los directorios de destino de los tablespaces (propietario `postgres`, permisos restrictivos). La conexión se prueba con:

```bash
psql "host=<IP_TAILSCALE_PRIMARIO> port=5432 user=replicador dbname=postgres replication=1" -c "IDENTIFY_SYSTEM"
```

### 10.4 Copia inicial con pg\_basebackup

`respaldos/replica_secundario.sh` detiene PostgreSQL, **vacía el directorio de datos** del secundario y ejecuta `pg_basebackup` con `-R` (crea `standby.signal` y `primary_conninfo`), `-X stream` y `-P`, más cuatro `--tablespace-mapping` que adaptan las rutas de `Datos`, `Bitacoras`, `Historicos` e `Indices` del primario a las del secundario. Luego arranca el servicio y verifica el modo de recuperación.

Las variables `PRIMARIO`, `DATA`, `TS_ORIGEN` y `TS_DESTINO` del script corresponden a los equipos del equipo de trabajo (las rutas del primario no son las de `13_tablespaces.sql`). **Solo debe ejecutarse en el secundario correcto**, después de revisar esas variables; nunca en el primario.

### 10.5 Validación de la réplica

El equipo documentó estos resultados:

- `pg_basebackup` terminó con **74,563/74,563 kB (100 %)** y **5/5 tablespaces**.
- Existe `standby.signal` y `postgresql.auto.conf` contiene `primary_conninfo` con `application_name=replica_hospital`.
- `SELECT pg_is_in_recovery();` devolvió `t`.
- Una tabla de prueba creada en `hospital_san_lucas` del primario apareció en el secundario.

Para completar el diagnóstico, en el primario `SELECT client_addr, application_name, state, sync_state FROM pg_stat_replication;` y en el secundario `SELECT status, sender_host, sender_port FROM pg_stat_wal_receiver;`.

**Alcance:** esto demuestra una réplica por streaming, no una solución completa de alta disponibilidad: no hay conmutación automática por falla.

## 11. Respaldos y recuperación

Los scripts de `respaldos/` generan tres respaldos con marca temporal en el nombre:

1. **Lógico:** `pg_dump` en formato custom (`-F c`).
2. **Objetos globales:** `pg_dumpall --globals-only` (roles y privilegios).
3. **Físico:** `pg_basebackup` en tar comprimido (`-F t -z`). Espera al siguiente checkpoint, por lo que puede tardar unos minutos.


| Script                            | Sistema | Destino                                                                  |
| --------------------------------- | ------- | ------------------------------------------------------------------------ |
| `respaldos/respaldo_completo.sh`  | Linux   | `/backups`                                                               |
| `respaldos/respaldo_completo.bat` | Windows | `C:\respaldos_hospital` (usa binarios de PostgreSQL 18; ajustar la ruta) |


### Restauración de prueba

`respaldos/restauracion.sh` toma el dump más reciente de `/backups`, recrea la base `hospital_san_lucas_restaurada`, la restaura con `pg_restore --no-owner --no-privileges` y cuenta los registros de `persona`, `consulta` y `cirugia` para verificar. Los roles se recuperan con `psql -U postgres -f roles_<fecha>.sql`. La restauración física requiere un procedimiento distinto y la misma versión mayor; no se restaura sobre un directorio de datos activo.

### Automatización y retención

La programación diaria a las 2:00 a.m. se registra en el servidor de despliegue y **no forma parte del repositorio**:

```bash
0 2 * * * /opt/hospital/respaldos/respaldo_completo.sh >> /var/log/respaldos.log 2>&1
```

```bat
schtasks /Create /TN "RespaldoHospital" /TR "C:\respaldos\respaldo_completo.bat" /SC DAILY /ST 02:00
```

Los scripts **no eliminan respaldos antiguos**: la retención requiere una tarea de limpieza adicional. Ejecute `restauracion.sh` periódicamente para confirmar que los respaldos sirven.

## 12. Pruebas, consultas y evidencias

- **Rendimiento:** `06-operaciones-2/15_explain_analyze.sql` compara cuatro casos (ocupación, agenda quirúrgica, insumos bajo mínimo e interconsultas) con `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)`, desactivando los recorridos por índice y luego con el plan normal, y consulta `pg_stat_user_indexes`. Con diez filas por tabla el optimizador suele preferir el recorrido secuencial.
- **Reportes:** `07-reportes/16_consultas_reporte.sql` consulta las vistas para ocupación por departamento, agenda quirúrgica del día, insumos bajo mínimo, guardias de las próximas 24 h, interconsultas por prioridad, estudios por estado, diagnósticos más frecuentes (90 días) y mantenimientos pendientes por criticidad.
- **Evidencia visual:** `docs/diagramas/` (modelo) y `docs/comprobaciones/seguridad_auditoria/` (bloqueo de `DELETE`, RLS, auditoría y alertas).

## 13. Comprobaciones posteriores a la instalación

Desde la Query Tool conectada a `hospital_san_lucas` (seleccione cada consulta y presione **F5**):

```sql
-- Tablas del esquema público (deben ser 36: las 35 del modelo y auditoria_log), sin contar particiones
SELECT count(*) FROM pg_class
WHERE relnamespace = 'public'::regnamespace AND relkind IN ('r','p') AND NOT relispartition;

-- Registros por tabla (count(*), no n_live_tup, que muestra 0 en tablas particionadas)
SELECT table_name,
  (xpath('/row/c/text()', query_to_xml(
     format('SELECT count(*) AS c FROM public.%I', table_name), false, true, '')))[1]::text::int AS registros
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  AND table_name NOT LIKE '%\_20%' AND table_name NOT LIKE '%\_default'
ORDER BY registros, table_name;

-- Particiones y tablespaces
SELECT * FROM pg_partition_tree('consulta');
SELECT * FROM pg_partition_tree('estudio_diagnostico');
SELECT spcname, pg_size_pretty(pg_tablespace_size(oid)) FROM pg_tablespace;

-- Vistas y roles
SELECT table_name FROM information_schema.views WHERE table_schema = 'public' ORDER BY 1;
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg\_%' ORDER BY 1;

-- Alertas (la regla de particiones responde sin mediciones)
SELECT * FROM monitoreo.v_alertas;

-- Réplica: en el secundario
SELECT pg_is_in_recovery();
```

Para vigilar la replicación en tiempo real, use `pg_stat_replication` en el primario y `pg_stat_wal_receiver` en el secundario.

## 14. Referencias de archivos principales


| Área                           | Archivo                                                             |
| ------------------------------ | ------------------------------------------------------------------- |
| Modelo y estructura            | `01-scripts-iniciales-1/01_hospital_san_lucas_ddl.sql`              |
| Carga de datos                 | `01-scripts-iniciales-1/02_poblacion_de_datos.sql`                  |
| Particionamiento               | `01-scripts-iniciales-1/03_particiones.sql`                         |
| Ajustes posteriores a la carga | `01-scripts-iniciales-1/04_ajustes_post_carga.sql`                  |
| Funciones                      | `02-reglas_de_negocio/05_funciones.sql`                             |
| Triggers                       | `02-reglas_de_negocio/06_triggers.sql`                              |
| Índices                        | `03-estructura/07_indices.sql`                                      |
| Vistas                         | `03-estructura/08_vistas.sql`                                       |
| Auditoría                      | `04-operaciones-1/09_auditoria.sql`                                 |
| Roles y RLS                    | `04-operaciones-1/10_seguridad_roles.sql`                           |
| Monitoreo                      | `04-operaciones-1/11_monitoreo.sql`                                 |
| Alertas                        | `04-operaciones-1/12_alertas_espacio.sql`                           |
| Tablespaces                    | `05-scripts-iniciales-2/13_tablespaces.sql`                         |
| Autovacuum                     | `06-operaciones-2/14_autovacuum_particiones.sql`                    |
| Rendimiento                    | `06-operaciones-2/15_explain_analyze.sql`                           |
| Reportes                       | `07-reportes/16_consultas_reporte.sql`                              |
| Respaldos                      | `respaldos/respaldo_completo.sh`, `respaldos/respaldo_completo.bat` |
| Restauración                   | `respaldos/restauracion.sh`                                         |
| Réplica                        | `respaldos/replica_secundario.sh`                                   |
| Documentación de seguridad     | `docs/comprobaciones/informe_seguridad_auditoria_alertas.md`        |


## 16. Autoría y propósito

Proyecto académico desarrollado por los autores indicados al inicio para el caso de estudio **Hospital Regional San Lucas**, como parte del proyecto final de Administración de Bases de Datos.