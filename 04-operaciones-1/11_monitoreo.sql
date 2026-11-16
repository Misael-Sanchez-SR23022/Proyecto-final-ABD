-- ============================================================================
-- 1. ESPACIO EN DISCO POR TABLA
-- ============================================================================
-- 1.1 Tamaño de una tabla específica
SELECT
    'paciente' AS tabla,
    pg_size_pretty(pg_total_relation_size('paciente')) AS tamano_total,
    pg_size_pretty(pg_relation_size('paciente')) AS tamano_solo_datos,
    pg_size_pretty(pg_indexes_size('paciente')) AS tamano_indices;

-- 1.2 Ranking de todas las tablas por tamaño (de mayor a menor)
SELECT
    n.nspname AS esquema,
    c.relname AS tabla,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano_total,
    pg_size_pretty(pg_relation_size(c.oid)) AS tamano_datos,
    pg_size_pretty(pg_indexes_size(c.oid)) AS tamano_indices,
    pg_total_relation_size(c.oid) AS bytes_totales
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'             
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(c.oid) DESC;

-- ============================================================================
-- 2. ESPACIO POR PARTICIÓN
-- ============================================================================
-- 2.1 Tamaño de cada partición de la tabla consulta
SELECT
    pt.relname                          AS particion,
    pg_size_pretty(pg_total_relation_size(pt.oid)) AS tamano_total,
    pg_get_expr(pt.relpartbound, pt.oid) AS rango
FROM pg_partition_tree('consulta') t
JOIN pg_class pt ON pt.oid = t.relid;

-- 2.2 Ranking de particiones de las tablas particionadas
SELECT
    parent.relname AS tabla_particionada,
    child.relname  AS particion,
    pg_size_pretty(pg_total_relation_size(child.oid)) AS tamano_total
FROM pg_partition_tree('consulta') t
JOIN pg_class parent ON parent.oid = t.parentrelid
JOIN pg_class child  ON child.oid  = t.relid
UNION ALL
SELECT
    parent.relname,
    child.relname,
    pg_size_pretty(pg_total_relation_size(child.oid))
FROM pg_partition_tree('estudio_diagnostico') t
JOIN pg_class parent ON parent.oid = t.parentrelid
JOIN pg_class child  ON child.oid  = t.relid
ORDER BY tabla_particionada, tamano_total DESC;


-- ============================================================================
-- 3. CONSULTAS LENTAS
-- ============================================================================
-- 3.1 Consultas activas con más de 5 segundos de ejecución (pg_stat_activity)

-- Para probar, abrir una nueva sesion y ejecutar:
-- SELECT pg_sleep(15);
-- En simultaneo ejecutar:
SELECT
    pid,
    usename,
    now() - query_start AS duracion,
    state,
    LEFT(query, 120) AS consulta
FROM pg_stat_activity
WHERE state = 'active'
  AND backend_type = 'client backend'
  AND now() - query_start > interval '5 seconds'
ORDER BY duracion DESC;

-- 3.2 Ranking histórico de consultas más costosas.
-- Para habilitar 'pg_stat_statements' se debe cambiar desde el archivo postgresql.conf
-- Windows: C:\Program Files\PostgreSQL\<versión>\data\postgresql.conf - shared_preload_libraries = 'pg_stat_statements'
-- Linux: sudo nano pgsql/data/postgresql.conf - shared_preload_libraries = 'pg_stat_statements'
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT
    calls,
    round(total_exec_time::numeric, 2) AS tiempo_total_ms,
    round(mean_exec_time::numeric, 2) AS tiempo_promedio_ms,
    rows,
    LEFT(query, 100) AS consulta
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- ============================================================================
-- 4. TAMAÑO DE WAL Y ESTADO DEL ARCHIVADO
-- ============================================================================
-- 4.1 Segmentos WAL presentes en pg_wal/
SELECT
    name,
    pg_size_pretty(size) AS tamano,
    modification
FROM pg_ls_waldir()
ORDER BY modification DESC;

-- Resumen del espacio usado por WAL
SELECT
    COUNT(*) AS segmentos,
    pg_size_pretty(SUM(size)) AS tamano_total_wal
FROM pg_ls_waldir();

-- 4.2 Estado del archivador (último archivo archivado y fallos)
SELECT
    archived_count,
    last_archived_wal,
    last_archived_time,
    failed_count,
    last_failed_wal,
    last_failed_time,
    stats_reset
FROM pg_stat_archiver;

-- 4.3 Parámetros actuales de archivado
SELECT name, setting FROM pg_settings
WHERE name IN ('wal_level', 'archive_mode', 'archive_command', 'archive_timeout');
