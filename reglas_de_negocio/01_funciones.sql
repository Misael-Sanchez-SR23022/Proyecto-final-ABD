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