-- ALERTAS DE ESPACIO Y CAPACIDAD
-- Reglas: 1) espacio libre < 20 %   2) crecimiento 7 días > 2 GB   3) partición > 5 GB

CREATE SCHEMA IF NOT EXISTS monitoreo;

CREATE TABLE IF NOT EXISTS monitoreo.medicion_bd (
    medido_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    base_datos TEXT NOT NULL,
    tamano_bytes BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS monitoreo.medicion_filesystem (
    medido_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    punto_montaje TEXT NOT NULL,
    capacidad_bytes BIGINT NOT NULL,
    disponible_bytes BIGINT NOT NULL
);

CREATE OR REPLACE VIEW monitoreo.v_alertas AS

-- 1. Espacio libre en disco < 20 %
SELECT 'espacio_libre_pct'::TEXT AS regla,
       f.punto_montaje AS objeto,
       ROUND(100.0 * f.disponible_bytes / f.capacidad_bytes, 2) AS valor,
       CASE WHEN 100.0 * f.disponible_bytes / f.capacidad_bytes < 20
            THEN 'CRITICO' ELSE 'OK' END AS estado
FROM (SELECT DISTINCT ON (punto_montaje) *
      FROM monitoreo.medicion_filesystem
      ORDER BY punto_montaje, medido_en DESC) f

UNION ALL

-- 2. Crecimiento de la BD en 7 días > 2 GB
SELECT 'crecimiento_7d_bytes',
       a.base_datos,
       (a.tamano_bytes - p.tamano_bytes)::NUMERIC,
       CASE WHEN p.tamano_bytes IS NULL THEN 'SIN_LINEA_BASE'
            WHEN a.tamano_bytes - p.tamano_bytes > 2147483648 THEN 'ADVERTENCIA'
            ELSE 'OK' END
FROM (SELECT DISTINCT ON (base_datos) *
      FROM monitoreo.medicion_bd
      ORDER BY base_datos, medido_en DESC) a
LEFT JOIN LATERAL (
    SELECT tamano_bytes
    FROM monitoreo.medicion_bd
    WHERE base_datos = a.base_datos
      AND medido_en <= a.medido_en - INTERVAL '7 days'
    ORDER BY medido_en DESC
    LIMIT 1
) p ON TRUE

UNION ALL

-- 3. Particiones de consulta y estudio_diagnostico > 5 GB
SELECT 'particion_bytes',
       c.relname::TEXT,
       pg_total_relation_size(c.oid)::NUMERIC,
       CASE WHEN pg_total_relation_size(c.oid) > 5368709120
            THEN 'ADVERTENCIA' ELSE 'OK' END
FROM unnest(ARRAY['consulta', 'estudio_diagnostico']) AS t(nombre),
     pg_partition_tree(t.nombre::regclass) pt
JOIN pg_class c ON c.oid = pt.relid
WHERE pt.isleaf;

-- Registrar el tamaño actual de la BD:
-- INSERT INTO monitoreo.medicion_bd(base_datos, tamano_bytes)
-- VALUES (current_database(), pg_database_size(current_database()));

-- Ver alertas:
-- SELECT * FROM monitoreo.v_alertas;

-- Limpiar para no dejar datos falsos
-- TRUNCATE monitoreo.medicion_filesystem, monitoreo.medicion_bd;