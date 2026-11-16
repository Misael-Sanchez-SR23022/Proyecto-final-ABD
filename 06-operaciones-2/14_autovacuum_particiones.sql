-- ============================================================================
-- AUTOVACUUM POR PARTICIÓN (ejecutar una sola vez)
-- ============================================================================
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT t.nombre AS tabla, pt.relid::regclass AS particion
        FROM unnest(ARRAY['consulta', 'estudio_diagnostico']) AS t(nombre),
             pg_partition_tree(t.nombre::regclass) pt
        WHERE pt.isleaf
    LOOP
        IF r.tabla = 'consulta' THEN
            EXECUTE format(
                'ALTER TABLE %s SET (autovacuum_vacuum_scale_factor = 0.05, autovacuum_analyze_scale_factor = 0.02, autovacuum_vacuum_cost_limit = 1000)',
                r.particion);
        ELSE
            EXECUTE format(
                'ALTER TABLE %s SET (autovacuum_vacuum_scale_factor = 0.05, autovacuum_analyze_scale_factor = 0.02)',
                r.particion);
        END IF;
    END LOOP;
END $$;

-- Verificación
/*
SELECT c.relname AS particion, c.reloptions
FROM pg_class c
WHERE c.relkind = 'r'
  AND (c.relname LIKE 'consulta\_%' OR c.relname LIKE 'estudio\_diagnostico\_%')
ORDER BY c.relname;
*/