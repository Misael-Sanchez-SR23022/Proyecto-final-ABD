--01 Un "médico" es un empleado ACTIVO con especialidad y número de licencia.
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


--02 Trigger genérico: recibe como argumentos los nombres de las columnas a validar
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


--03 El anestesiólogo debe tener la especialidad de anestesiología
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