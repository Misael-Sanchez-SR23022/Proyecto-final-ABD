-- =====================================================================
-- CASO 1 — R1: OCUPACIÓN POR DEPARTAMENTO
-- =====================================================================

-- 1.1 Ejecución SIN uso de índices (Fuerza un recorrido secuencial / Seq Scan)
SET enable_indexscan = off;
SET enable_bitmapscan = off;
SET enable_indexonlyscan = off;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_ocupacion_departamento
ORDER BY porcentaje_ocupacion DESC;

-- 1.2 Ejecución CON uso de índices (Ruta normal optimizada por PostgreSQL)
RESET enable_indexscan;
RESET enable_bitmapscan;
RESET enable_indexonlyscan;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_ocupacion_departamento
ORDER BY porcentaje_ocupacion DESC;


-- =====================================================================
-- CASO 2 — R2: AGENDA QUIRÚRGICA DEL DÍA
-- =====================================================================

-- 2.1 Ejecución SIN uso de índices (Evaluando costo sin optimización de índices)
SET enable_indexscan = off;
SET enable_bitmapscan = off;
SET enable_indexonlyscan = off;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_agenda_quirurgica
WHERE fecha_hora_programada::date = CURRENT_DATE
  AND estado_cirurgia IN ('PROGRAMADA', 'EN_CURSO');

-- 2.2 Ejecución CON uso de índices (Aprovechando los índices en fechas y estados)
RESET enable_indexscan;
RESET enable_bitmapscan;
RESET enable_indexonlyscan;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_agenda_quirurgica
WHERE fecha_hora_programada::date = CURRENT_DATE
  AND estado_cirurgia IN ('PROGRAMADA', 'EN_CURSO');


-- =====================================================================
-- CASO 3 — R3: INSUMOS BAJO MÍNIMO
-- =====================================================================

-- 3.1 Ejecución SIN uso de índices (Recorrido completo de la tabla de insumos)
SET enable_indexscan = off;
SET enable_bitmapscan = off;
SET enable_indexonlyscan = off;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_insumos_reposicion
ORDER BY unidades_faltantes DESC;

-- 3.2 Ejecución CON uso de índices (Utilizando los índices parciales de stock bajo)
RESET enable_indexscan;
RESET enable_bitmapscan;
RESET enable_indexonlyscan;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_insumos_reposicion
ORDER BY unidades_faltantes DESC;


-- =====================================================================
-- CASO 4 — R5: INTERCONSULTAS PENDIENTES
-- =====================================================================

-- 4.1 Ejecución SIN uso de índices (Analizando la consulta de interconsultas sin índices)
SET enable_indexscan = off;
SET enable_bitmapscan = off;
SET enable_indexonlyscan = off;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_interconsultas_pendientes;

-- 4.2 Ejecución CON uso de índices (Aprovechando índices parciales de pendientes)
RESET enable_indexscan;
RESET enable_bitmapscan;
RESET enable_indexonlyscan;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM vista_interconsultas_pendientes;


-- =====================================================================
-- VERIFICACIÓN FINAL DE USO DE ÍNDICES
-- =====================================================================
-- Muestra cuántas veces se han escaneado y utilizado los índices creados
SELECT
    schemaname,
    relname AS tabla,
    indexrelname AS indice,
    idx_scan AS veces_usado,
    idx_tup_read AS tuplas_leidas,
    idx_tup_fetch AS tuplas_recuperadas
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;