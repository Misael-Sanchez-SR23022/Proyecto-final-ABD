CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ============================================================
-- 01. VALIDACIÓN DE MÉDICOS
-- ============================================================
CREATE OR REPLACE FUNCTION es_medico(p_id_empleado BIGINT)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM empleado
        WHERE id_empleado = p_id_empleado
          AND id_especialidad IS NOT NULL
          AND numero_licencia IS NOT NULL
          AND estado = 'ACTIVO'
    );
$$ LANGUAGE sql STABLE;


-- ============================================================
-- 02. VALIDACIÓN GENÉRICA DE MÉDICOS EN TRIGGERS
-- ============================================================
CREATE OR REPLACE FUNCTION fn_validar_medico()
RETURNS trigger AS $$
DECLARE
    v_col TEXT;
    v_id  BIGINT;
BEGIN
    FOREACH v_col IN ARRAY TG_ARGV LOOP
        v_id := (to_jsonb(NEW) ->> v_col)::BIGINT;
        IF v_id IS NOT NULL AND NOT es_medico(v_id) THEN
            RAISE EXCEPTION 'El empleado % (columna %) no es un médico activo con especialidad y licencia', v_id, v_col;
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 03. VALIDACIÓN DE ANESTESIÓLOGOS
-- ============================================================
CREATE OR REPLACE FUNCTION fn_validar_anestesiologo()
RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM empleado e
        JOIN especialidad s ON s.id_especialidad = e.id_especialidad
        WHERE e.id_empleado = NEW.id_anestesiologo
          AND s.nombre_especialidad ILIKE 'anestesi%'
    ) THEN
        RAISE EXCEPTION 'El empleado % no tiene la especialidad de anestesiología', NEW.id_anestesiologo;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 04. VALIDACIÓN DE INTERCONSULTAS
-- ============================================================
CREATE OR REPLACE FUNCTION fn_validar_interconsulta()
RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM empleado
        WHERE id_empleado = NEW.id_medico_especialista
          AND id_especialidad = NEW.id_especialidad_solicitada
    ) THEN
        RAISE EXCEPTION 'El médico % no pertenece a la especialidad solicitada (%)',
            NEW.id_medico_especialista, NEW.id_especialidad_solicitada;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 05. GESTIÓN AUTOMÁTICA DEL ESTADO DE LAS CAMAS
-- ============================================================

-- Marca una cama como ocupada, siempre que esté disponible.
CREATE OR REPLACE FUNCTION fn_ocupar_cama(p_id_cama BIGINT)
RETURNS VOID AS $$
BEGIN
    IF (SELECT estado FROM cama WHERE id_cama = p_id_cama) IS DISTINCT FROM 'DISPONIBLE' THEN
        RAISE EXCEPTION 'La cama % no está disponible', p_id_cama;
    END IF;
    UPDATE cama SET estado = 'OCUPADA' WHERE id_cama = p_id_cama;
END;
$$ LANGUAGE plpgsql;

-- Sincroniza el estado de las camas con los ingresos hospitalarios.
-- Gestiona ocupaciones, altas, cancelaciones y traslados.
CREATE OR REPLACE FUNCTION fn_ingreso_gestiona_cama()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.estado = 'ACTIVO' THEN
            PERFORM fn_ocupar_cama(NEW.id_cama);
        END IF;
    ELSE  -- UPDATE
        IF OLD.estado = 'ACTIVO' AND NEW.estado <> 'ACTIVO' THEN
            UPDATE cama SET estado = 'DISPONIBLE' WHERE id_cama = OLD.id_cama;   -- alta o cancelación
        ELSIF OLD.estado = 'ACTIVO' AND NEW.estado = 'ACTIVO' AND OLD.id_cama <> NEW.id_cama THEN
            UPDATE cama SET estado = 'DISPONIBLE' WHERE id_cama = OLD.id_cama;   -- traslado de cama
            PERFORM fn_ocupar_cama(NEW.id_cama);
        ELSIF OLD.estado <> 'ACTIVO' AND NEW.estado = 'ACTIVO' THEN
            PERFORM fn_ocupar_cama(NEW.id_cama);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 06. ACTUALIZACIÓN AUTOMÁTICA DEL INVENTARIO
-- ============================================================

CREATE OR REPLACE FUNCTION fn_actualizar_stock()
RETURNS trigger AS $$
DECLARE
    v_tipo VARCHAR(20);
BEGIN
    SELECT tipo_movimiento INTO v_tipo
    FROM movimiento_inventario WHERE id_movimiento = NEW.id_movimiento;

    IF v_tipo IN ('ENTRADA', 'AJUSTE_POSITIVO') THEN
        UPDATE insumo SET stock = stock + NEW.cantidad WHERE id_insumo = NEW.id_insumo;
    ELSE
        UPDATE insumo SET stock = stock - NEW.cantidad WHERE id_insumo = NEW.id_insumo;  -- ck_insumo_stock evita negativos
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 07. PROTECCIÓN DE LOS MOVIMIENTOS DE INVENTARIO
-- ============================================================
CREATE OR REPLACE FUNCTION fn_bloquear_modificacion()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Los detalles de movimiento no se modifican ni eliminan; registre un ajuste';
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 08. ENCRIPTACIÓN Y DESENCRIPTACIÓN DEL DUI
-- ============================================================

-- Encripta el DUI utilizando el algoritmo AES-256.
CREATE OR REPLACE FUNCTION fn_encriptar_dui(p_dui TEXT, p_clave TEXT)
RETURNS BYTEA AS $$
BEGIN
    RETURN pgp_sym_encrypt(p_dui, p_clave, 'cipher-algo=aes256');
END;
$$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION fn_desencriptar_dui(p_dui_encriptado BYTEA, p_clave TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN pgp_sym_decrypt(p_dui_encriptado, p_clave);
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- ============================================================
-- 09. PRUEBAS DE ENCRIPTACIÓN Y DESENCRIPTACIÓN
-- ============================================================

-- Prueba de encriptación de un DUI.
/*
SELECT fn_encriptar_dui('01010101-1', 'MiClaveSecretaSuperSegura2026!') 
AS dui_encriptado;


-- Prueba de desencriptación del DUI.
SELECT fn_desencriptar_dui(fn_encriptar_dui('01010101-1', 'MiClaveSecretaSuperSegura2026!'),'MiClaveSecretaSuperSegura2026!') 
AS dui_original;
*/