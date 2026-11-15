# Monitoreo, Auditoría, Control de Accesos y Administración de Almacenamiento - Hospital Regional "San Lucas"

## 1. Monitoreo, Auditoría y Control de Accesos

### 1.1 Diseño de Roles y Principio de Menor Privilegio 
Con el objetivo de proteger la confidencialidad e integridad de los datos clínicos en la base de datos `hospital_san_lucas`, se implementó un esquema de control de acceso basado en roles (`operaciones/04_seguridad_roles.sql`) siguiendo el principio de menor privilegio:

| Rol de Base de Datos | Usuario de Prueba | Tablas Autorizadas | Privilegios Otorgados | Restricciones Críticas |
| :--- | :--- | :--- | :--- | :--- |
| `rol_medico` | `usr_medico_cardio`, `usr_medico_pediatria` | `consulta`, `estudio_diagnostico`, catálogos (`empleado`, `especialidad`, `tipo_estudio`, `persona`, `departamento`), `paciente`, `expediente`, `ingreso_hospitalario`, `cama` | `SELECT`, `INSERT`, `UPDATE` en atención clínica; `SELECT` en catálogos y pacientes | Bloqueo total de `DELETE` sobre todas las tablas clínicas |
| `rol_enfermeria` | `usr_enfermeria1` | `paciente`, `expediente`, `consulta`, `estudio_diagnostico`, `cama`, `ingreso_hospitalario`, `persona`, `departamento` | Únicamente `SELECT` | Sin permisos de escritura (`INSERT`, `UPDATE`, `DELETE`) |
| `rol_recepcion` | `usr_recepcion1` | `paciente`, `persona`, `expediente` | `SELECT`, `INSERT` | Sin acceso a diagnósticos ni modificación/borrado de registros |
| `rol_auditor` | `usr_auditor1` | `auditoria_log` | Únicamente `SELECT` | Sin acceso a datos clínicos ni alteración de la bitácora |

**Validación de restricción de borrado (`DELETE`):** Al autenticar la sesión como `usr_medico_cardio` e intentar ejecutar `DELETE FROM paciente WHERE id_paciente = 1;`, PostgreSQL rechaza la operación con el código `SQL state: 42501 (ERROR: permission denied for table paciente)`, garantizando que ningún profesional clínico pueda eliminar registros maestros de pacientes.

![Evidencia bloqueo DELETE en paciente](/docs/comprobaciones/seguridad_auditoria/01_bloqueo_delete_paciente.png)

### 1.2 Aislamiento de Expedientes mediante Row Level Security (RLS) 
Para gestionar el acceso seguro a los registros, se activó **Row Level Security** en la tabla expediente (`ALTER TABLE expediente ENABLE ROW LEVEL SECURITY`) configurando políticas específicas por rol (`operaciones/04_seguridad_roles.sql`):

- **`pol_expediente_medico`:** Evalúa dinámicamente el departamento del médico conectado mediante la función auxiliar `fn_departamento_de(current_user)` contra las tablas `consulta` o ingresos hospitalarios (`ingreso_hospitalario` y `cama`), permitiendo ver únicamente expedientes de pacientes atendidos en su área.
- **`pol_expediente_enfermeria`:** Restringe la lectura al personal de enfermería exclusivamente para pacientes con un ingreso **`ACTIVO`** en su mismo departamento.
- **`pol_expediente_recepcion_select` / `_insert`:** Permiten al personal de recepción consultar y registrar nuevos pacientes y expedientes sin restricciones departamentales.

![Evidencia aislamiento RLS en expediente](/docs/comprobaciones/seguridad_auditoria/02_rls_expediente_cardio.png)

### 1.3 Auditoría Transaccional mediante Triggers (`auditoria_log`) 
La trazabilidad forense de las operaciones críticas se implementó mediante la tabla `auditoria_log` y la función centralizada `fn_auditoria_general()` (`SECURITY DEFINER`) en `operaciones/03_auditoria.sql`. 

- **Tablas Monitoreadas:** Triggers `AFTER INSERT OR UPDATE OR DELETE` activos en **cuatro** tablas críticas: `paciente`, `expediente`, `consulta` y `estudio_diagnostico`.
- **Metadatos Registrados:** Cada registro almacena automáticamente el usuario de conexión (`session_user`), el rol activo (`current_user`), marca de tiempo, tabla afectada, tipo de operación (`INSERT`, `UPDATE`, `DELETE`), instantánea en formato `JSONB` (con valores previos `antes` y posteriores `despues`), aplicación de origen (`application_name`) y dirección IP del cliente (`inet_client_addr()`).

![Evidencia bitácora auditoria_log](/docs/comprobaciones/seguridad_auditoria/03_auditoria_log.png)

### 1.4 Métricas Vigiladas y Alertas Configuradas (`02_monitoreo.sql` y `05_alertas_espacio.sql`)
Con base en los scripts de supervisión implementados, se vigilan las siguientes dimensiones operativas y umbrales críticos de alerta mediante la vista `monitoreo.v_alertas`:

| Dimensión Vigilada | Métrica / Vista de PostgreSQL | Umbral de Alerta Configurado | Acción Preventiva / Correctiva |
| :--- | :--- | :--- | :--- |
| **Espacio en disco y particiones** | `pg_database_size()`, `pg_partition_tree()`, `pg_total_relation_size()` | Espacio libre en filesystem `< 20 %`; Particiones de `consulta` o `estudio_diagnostico` `> 5.00 GB` | Rotación/archivado de particiones históricas y ampliación de volumen |
| **Crecimiento histórico** | Histórico en `monitoreo.medicion_bd` | Crecimiento de la base de datos en 7 días `> 2.00 GB` (`2147483648` bytes) | Auditoría de volumen de inserciones y revisión de retención de logs/auditoría |
| **Consultas lentas** | `pg_stat_activity` y `pg_stat_statements` | Consultas activas con duración `> 5 segundos` (`now() - query_start > interval '5 seconds'`) | Análisis de planes de ejecución (`EXPLAIN ANALYZE`) y optimización de índices B-Tree |
| **Estado de WAL y Archivado** | `pg_ls_waldir()` y `pg_stat_archiver` | Supervisión de segmentos WAL activos, conteo y fallos de archivado (`failed_count`) | Verificación del proceso `archive_command` y espacio de almacenamiento para bitácoras de transacciones |

![Evidencia alertas de espacio y particiones](/docs/comprobaciones/seguridad_auditoria/04_alertas_espacio.png)

---

## 2. Administración de Almacenamiento y Mantenibilidad

### 2.1 Estrategia de Particionamiento y Retención
Las tablas de mayor crecimiento histórico (`consulta` y `estudio_diagnostico`) están particionadas por rango de fechas (`RANGE`) en trimestres, permitiendo consultas rápidas mediante *partition pruning* y facilitando la administración de datos históricos y el cumplimiento normativo.

### 2.2 Configuración de `autovacuum` por Tabla de Alto Tráfico
Dado que `consulta` y `estudio_diagnostico` reciben inserciones y actualizaciones constantes, se ajustaron los parámetros de `autovacuum` a nivel de tabla para ejecutar limpiezas más frecuentes y prevenir la degradación por *table bloat*:

```sql
ALTER TABLE consulta SET (
    autovacuum_vacuum_scale_factor = 0.05,
    autovacuum_analyze_scale_factor = 0.02,
    autovacuum_vacuum_cost_limit = 1000
);

ALTER TABLE estudio_diagnostico SET (
    autovacuum_vacuum_scale_factor = 0.05,
    autovacuum_analyze_scale_factor = 0.02
);