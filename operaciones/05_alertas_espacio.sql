-- ============================================================================
-- MONITOREO, MÉTRICAS Y ALERTAS
-- Este script mide PostgreSQL. El espacio libre REAL del filesystem se obtiene
-- con el recolector respaldos/medir_espacio.sh (df), no con un volumen supuesto.
-- Ejecutar como rol de monitoreo con permisos de lectura de estadísticas.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS monitoreo;

CREATE TABLE IF NOT EXISTS monitoreo.medicion_bd (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medido_en TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    base_datos TEXT NOT NULL,
    tamano_bytes BIGINT NOT NULL CHECK (tamano_bytes >= 0)
);

CREATE TABLE IF NOT EXISTS monitoreo.medicion_filesystem (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medido_en TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    punto_montaje TEXT NOT NULL,
    capacidad_bytes BIGINT NOT NULL CHECK (capacidad_bytes > 0),
    usado_bytes BIGINT NOT NULL CHECK (usado_bytes >= 0),
    disponible_bytes BIGINT NOT NULL CHECK (disponible_bytes >= 0),
    porcentaje_usado NUMERIC(5,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS monitoreo.umbral_alerta (
    metrica TEXT PRIMARY KEY,
    umbral NUMERIC NOT NULL,
    operador TEXT NOT NULL CHECK (operador IN ('>', '>=', '<', '<=')),
    severidad TEXT NOT NULL CHECK (severidad IN ('INFO','ADVERTENCIA','CRITICO')),
    habilitada BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO monitoreo.umbral_alerta(metrica,umbral,operador,severidad) VALUES
 ('filesystem_pct_usado',80,'>=','ADVERTENCIA'),
 ('filesystem_pct_usado',90,'>=','CRITICO'),
 ('crecimiento_bd_7d_bytes',2147483648,'>','ADVERTENCIA'),
 ('particion_bytes',5368709120,'>','ADVERTENCIA'),
 ('consulta_segundos',5,'>','ADVERTENCIA'),
 ('bloqueo_segundos',30,'>','CRITICO'),
 ('conexiones_pct',80,'>=','ADVERTENCIA')
ON CONFLICT (metrica) DO NOTHING;

-- Ejecutar periódicamente (cron/Task Scheduler) para crear una línea base real.
CREATE OR REPLACE PROCEDURE monitoreo.registrar_medicion_bd()
LANGUAGE SQL
AS $$
    INSERT INTO monitoreo.medicion_bd(base_datos,tamano_bytes)
    VALUES (current_database(), pg_database_size(current_database()));
$$;

CREATE OR REPLACE VIEW monitoreo.v_crecimiento_bd_7d AS
WITH actual AS (
    SELECT DISTINCT ON (base_datos) base_datos, medido_en, tamano_bytes
    FROM monitoreo.medicion_bd ORDER BY base_datos, medido_en DESC
),
anterior AS (
    SELECT a.base_datos, m.medido_en, m.tamano_bytes
    FROM actual a
    LEFT JOIN LATERAL (
        SELECT medido_en,tamano_bytes
        FROM monitoreo.medicion_bd
        WHERE base_datos=a.base_datos
          AND medido_en <= a.medido_en - INTERVAL '7 days'
        ORDER BY medido_en DESC LIMIT 1
    ) m ON TRUE
)
SELECT a.base_datos, a.medido_en AS medicion_actual,
       p.medido_en AS medicion_anterior,
       a.tamano_bytes AS tamano_actual_bytes,
       p.tamano_bytes AS tamano_anterior_bytes,
       CASE WHEN p.tamano_bytes IS NULL THEN NULL
            ELSE a.tamano_bytes-p.tamano_bytes END AS crecimiento_7d_bytes,
       CASE WHEN p.tamano_bytes IS NULL THEN 'SIN_LINEA_BASE_7D'
            WHEN a.tamano_bytes-p.tamano_bytes > 2147483648 THEN 'ADVERTENCIA'
            ELSE 'OK' END AS estado
FROM actual a
LEFT JOIN anterior p USING(base_datos);

-- Alertas calculadas sobre mediciones reales del sistema operativo.
CREATE OR REPLACE VIEW monitoreo.v_alertas_filesystem AS
SELECT punto_montaje, medido_en, porcentaje_usado,
       CASE WHEN porcentaje_usado >= 90 THEN 'CRITICO'
            WHEN porcentaje_usado >= 80 THEN 'ADVERTENCIA'
            ELSE 'OK' END AS estado
FROM monitoreo.medicion_filesystem
WHERE (punto_montaje,medido_en) IN (
    SELECT punto_montaje, MAX(medido_en)
    FROM monitoreo.medicion_filesystem GROUP BY punto_montaje
);

-- Consultas activas de más de cinco segundos.
CREATE OR REPLACE VIEW monitoreo.v_consultas_lentas AS
SELECT pid, usename, application_name, state,
       clock_timestamp()-query_start AS duracion,
       LEFT(query,500) AS consulta
FROM pg_stat_activity
WHERE state='active'
  AND backend_type='client backend'
  AND query_start IS NOT NULL
  AND pid <> pg_backend_pid()
  AND clock_timestamp()-query_start > INTERVAL '5 seconds';

-- Bloqueos: sesión bloqueada y sesiones que la bloquean.
CREATE OR REPLACE VIEW monitoreo.v_bloqueos AS
SELECT a.pid AS pid_bloqueado, a.usename AS usuario_bloqueado,
       clock_timestamp()-a.query_start AS espera,
       pg_blocking_pids(a.pid) AS pids_bloqueadores,
       LEFT(a.query,300) AS consulta_bloqueada
FROM pg_stat_activity a
WHERE cardinality(pg_blocking_pids(a.pid)) > 0;

-- Uso de conexiones frente al máximo configurado.
CREATE OR REPLACE VIEW monitoreo.v_conexiones AS
SELECT current_setting('max_connections')::INT AS max_conexiones,
       COUNT(*)::INT AS conexiones_actuales,
       ROUND(100.0*COUNT(*)/NULLIF(current_setting('max_connections')::INT,0),2)
           AS porcentaje_usado
FROM pg_stat_activity;

-- Tamaño de tablas/índices y particiones.
CREATE OR REPLACE VIEW monitoreo.v_tamano_relaciones AS
SELECT n.nspname AS esquema, c.relname AS relacion,
       pg_relation_size(c.oid) AS datos_bytes,
       pg_indexes_size(c.oid) AS indices_bytes,
       pg_total_relation_size(c.oid) AS total_bytes
FROM pg_class c
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE c.relkind IN ('r','m','i')
  AND n.nspname NOT IN ('pg_catalog','information_schema','monitoreo');

CREATE OR REPLACE VIEW monitoreo.v_wal_archivado AS
SELECT archived_count,last_archived_wal,last_archived_time,
       failed_count,last_failed_wal,last_failed_time,stats_reset
FROM pg_stat_archiver;

-- Requiere pg_stat_statements en shared_preload_libraries y reinicio.
-- Ejecutar una vez como administrador:
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- SELECT query,calls,total_exec_time,mean_exec_time,rows
-- FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 20;

-- Alertas que pueden consultarse desde un job/monitor externo.
CREATE OR REPLACE VIEW monitoreo.v_alertas AS
SELECT 'filesystem_pct_usado' AS metrica, punto_montaje AS objeto,
       porcentaje_usado::NUMERIC AS valor,
       CASE WHEN porcentaje_usado >= 90 THEN 'CRITICO'
            WHEN porcentaje_usado >= 80 THEN 'ADVERTENCIA'
            ELSE 'OK' END AS severidad
FROM monitoreo.v_alertas_filesystem
UNION ALL
SELECT 'crecimiento_bd_7d_bytes',base_datos,
       crecimiento_7d_bytes::NUMERIC,estado
FROM monitoreo.v_crecimiento_bd_7d
WHERE estado <> 'OK'
UNION ALL
SELECT 'consulta_segundos',pid::TEXT,
       EXTRACT(EPOCH FROM duracion)::NUMERIC,'ADVERTENCIA'
FROM monitoreo.v_consultas_lentas
UNION ALL
SELECT 'bloqueo_segundos',pid_bloqueado::TEXT,
       EXTRACT(EPOCH FROM espera)::NUMERIC,'CRITICO'
FROM monitoreo.v_bloqueos
WHERE espera > INTERVAL '30 seconds'
UNION ALL
SELECT 'conexiones_pct','cluster',porcentaje_usado::NUMERIC,
       CASE WHEN porcentaje_usado >= 90 THEN 'CRITICO'
            WHEN porcentaje_usado >= 80 THEN 'ADVERTENCIA' ELSE 'OK' END
FROM monitoreo.v_conexiones
WHERE porcentaje_usado >= 80;

-- Comandos de operación:
-- CALL monitoreo.registrar_medicion_bd();
-- SELECT * FROM monitoreo.v_alertas;
-- SELECT * FROM monitoreo.v_tamano_relaciones ORDER BY total_bytes DESC;
-- SELECT * FROM monitoreo.v_consultas_lentas;
-- SELECT * FROM monitoreo.v_bloqueos;
-- SELECT * FROM monitoreo.v_conexiones;
-- SELECT * FROM monitoreo.v_wal_archivado;
-- NOTA: las vistas detectan estados; para notificar por correo/Slack se requiere
-- un job externo (cron/Task Scheduler/Prometheus/Alertmanager).


-- Rol mínimo para el proceso de recolección/consulta de métricas.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='rol_monitoreo') THEN
        CREATE ROLE rol_monitoreo NOLOGIN;
    END IF;
END $$;

GRANT USAGE ON SCHEMA monitoreo TO rol_monitoreo;
GRANT SELECT ON ALL TABLES IN SCHEMA monitoreo TO rol_monitoreo;
GRANT INSERT ON monitoreo.medicion_bd, monitoreo.medicion_filesystem TO rol_monitoreo;
GRANT USAGE, SELECT ON SEQUENCE
    monitoreo.medicion_bd_id_seq,
    monitoreo.medicion_filesystem_id_seq
TO rol_monitoreo;
GRANT EXECUTE ON PROCEDURE monitoreo.registrar_medicion_bd() TO rol_monitoreo;
GRANT pg_monitor TO rol_monitoreo;

-- Asignar el rol a una cuenta LOGIN creada por el administrador:
-- GRANT rol_monitoreo TO usuario_monitoreo;
-- No guardar la contraseña de esa cuenta en este repositorio.
