-- 1. Sincronizar las secuencias de identidad con los IDs insertados
--    manualmente en la poblacion de datos. Sin esto, cualquier INSERT
--    sin id explicito falla con "duplicate key".
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT c.table_name, c.column_name
        FROM information_schema.columns c
        JOIN information_schema.tables t
          ON t.table_schema = c.table_schema AND t.table_name = c.table_name
        WHERE c.table_schema = 'public'
          AND c.is_identity = 'YES'
          AND t.table_type = 'BASE TABLE'
    LOOP
        EXECUTE format(
            'SELECT setval(pg_get_serial_sequence(%L, %L),
                           COALESCE((SELECT MAX(%I) FROM public.%I), 1),
                           (SELECT MAX(%I) IS NOT NULL FROM public.%I))',
            'public.' || r.table_name, r.column_name,
            r.column_name, r.table_name, r.column_name, r.table_name);
    END LOOP;
END $$;

-- 2. Alinear el estado de las camas con los ingresos activos cargados
--    antes de crear los triggers.
UPDATE cama
SET estado = 'OCUPADA'
WHERE id_cama IN (SELECT id_cama FROM ingreso_hospitalario WHERE estado = 'ACTIVO')
  AND estado <> 'OCUPADA';

-- Verificacion
SELECT estado, COUNT(*) FROM cama GROUP BY estado ORDER BY estado;