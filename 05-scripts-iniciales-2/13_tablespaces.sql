-- =========================================================================
-- CONFIGURACIÓN DE TABLESPACES 
-- =========================================================================

-- OPCIÓN A: LINUX 
-- 1. Creación de carpetas y permisos en Linux (Ejecutar en la terminal con sudo)
/*
 sudo mkdir -p /var/lib/pgsql/tablespaces/Datos
 sudo mkdir -p /var/lib/pgsql/tablespaces/Indices
 sudo mkdir -p /var/lib/pgsql/tablespaces/Bitacoras
 sudo mkdir -p /var/lib/pgsql/tablespaces/Historicos
 sudo chown -R postgres:postgres /var/lib/pgsql/tablespaces/
 sudo chmod -R 700 /var/lib/pgsql/tablespaces/
*/
DROP TABLESPACE IF EXISTS ts_datos;
DROP TABLESPACE IF EXISTS ts_indices;
DROP TABLESPACE IF EXISTS ts_bitacoras;
DROP TABLESPACE IF EXISTS ts_historicos;

-- 2. Creación de Tablespaces en Linux
CREATE TABLESPACE ts_datos LOCATION '/var/lib/pgsql/tablespaces/Datos';
CREATE TABLESPACE ts_indices LOCATION '/var/lib/pgsql/tablespaces/Indices';
CREATE TABLESPACE ts_bitacoras LOCATION '/var/lib/pgsql/tablespaces/Bitacoras';
CREATE TABLESPACE ts_historicos LOCATION '/var/lib/pgsql/tablespaces/Historicos';


-- OPCIÓN B: WINDOWS
/*
-- 1. Asegurarse de crear previamente las carpetas en el equipo (ej. en C:\PostgreSQL\Tablespaces\)
--    y verifica que el usuario del servicio de PostgreSQL tenga permisos de control total.

DROP TABLESPACE IF EXISTS ts_datos;
DROP TABLESPACE IF EXISTS ts_indices;
DROP TABLESPACE IF EXISTS ts_bitacoras;
DROP TABLESPACE IF EXISTS ts_historicos;

-- Creación de Tablespaces en Windows
CREATE TABLESPACE ts_datos LOCATION 'C:/PostgreSQL/Tablespaces/Datos';
CREATE TABLESPACE ts_indices LOCATION 'C:/PostgreSQL/Tablespaces/Indices';
CREATE TABLESPACE ts_bitacoras LOCATION 'C:/PostgreSQL/Tablespaces/Bitacoras';
CREATE TABLESPACE ts_historicos LOCATION 'C:/PostgreSQL/Tablespaces/Historicos';
*/


-- =========================================================================
-- MIGRACIÓN DE OBJETOS A LOS TABLESPACES
-- =========================================================================

DO $$
BEGIN
    -- Mover tablas de Datos
    ALTER TABLE IF EXISTS consulta SET TABLESPACE ts_datos;
    ALTER TABLE IF EXISTS estudio_diagnostico SET TABLESPACE ts_datos;
    ALTER TABLE IF EXISTS detalle_resultado_estudio SET TABLESPACE ts_datos;
    ALTER TABLE IF EXISTS movimiento_inventario SET TABLESPACE ts_datos;
    ALTER TABLE IF EXISTS detalle_movimiento_inventario SET TABLESPACE ts_datos;

    -- Bitácoras (auditoría y mediciones de monitoreo)
    ALTER TABLE IF EXISTS auditoria_log SET TABLESPACE ts_bitacoras;
    ALTER TABLE IF EXISTS monitoreo.medicion_bd SET TABLESPACE ts_bitacoras;
    ALTER TABLE IF EXISTS monitoreo.medicion_filesystem SET TABLESPACE ts_bitacoras;

    -- Mover tablas Históricas
    ALTER TABLE IF EXISTS consulta_2026_q4 SET TABLESPACE ts_historicos;
    ALTER TABLE IF EXISTS estudio_diagnostico_2026_q4 SET TABLESPACE ts_historicos;

    -- Mover índices
    ALTER INDEX IF EXISTS ix_consulta_paciente SET TABLESPACE ts_indices;
    ALTER INDEX IF EXISTS ix_estudio_paciente SET TABLESPACE ts_indices;
    ALTER INDEX IF EXISTS ix_estudio_medico SET TABLESPACE ts_indices;
    ALTER INDEX IF EXISTS ix_estudio_tipo_estado SET TABLESPACE ts_indices;
    ALTER INDEX IF EXISTS ix_estudio_pendientes SET TABLESPACE ts_indices;
    ALTER INDEX IF EXISTS ix_ingreso_fecha_estado SET TABLESPACE ts_indices;

    RAISE NOTICE 'Tablas e índices movidos a los tablespaces correctamente.';
END $$;


-- =========================================================================
-- CONSULTA DE VERIFICACIÓN
-- =========================================================================

/*
SELECT 
    t.spcname AS tablespace,
    c.relname AS objeto,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano
FROM pg_class c
JOIN pg_tablespace t ON t.oid = c.reltablespace
WHERE t.spcname IN ('ts_datos', 'ts_indices', 'ts_historicos')
ORDER BY t.spcname, pg_total_relation_size(c.oid) DESC;
*/
