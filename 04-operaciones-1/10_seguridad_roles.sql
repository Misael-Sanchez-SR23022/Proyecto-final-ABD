-- ----------------------------------------------------------------------------
-- 0. PREPARACIÓN
-- ----------------------------------------------------------------------------

-- Columna que vincula usuarios de BD con empleados reales (usada por RLS)
ALTER TABLE empleado ADD COLUMN IF NOT EXISTS usuario_bd VARCHAR(60) UNIQUE;

-- El trigger de auditoría debe poder escribir en auditoria_log aunque el rol
-- clínico no tenga acceso directo a esa tabla.
ALTER FUNCTION fn_auditoria_general()
    SECURITY DEFINER
    SET search_path = public, pg_temp;

-- Nadie (PUBLIC) puede crear objetos en el esquema public
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- ----------------------------------------------------------------------------
-- 1. LIMPIEZA PREVIA (permite re-ejecutar el script sin errores)
-- ----------------------------------------------------------------------------

-- Primero las políticas, porque dependen de los roles
DROP POLICY IF EXISTS pol_expediente_medico ON expediente;
DROP POLICY IF EXISTS pol_expediente_enfermeria ON expediente;
DROP POLICY IF EXISTS pol_expediente_recepcion_select ON expediente;
DROP POLICY IF EXISTS pol_expediente_recepcion_insert ON expediente;
-- Nombres usados en versiones anteriores
DROP POLICY IF EXISTS pol_expediente_departamento_medico ON expediente;
DROP POLICY IF EXISTS pol_expediente_otros_roles ON expediente;

DO $$
DECLARE
    r TEXT;
BEGIN
    -- Usuarios primero, luego los roles de grupo
    FOREACH r IN ARRAY ARRAY[
        'usr_medico_cardio', 'usr_medico_pediatria', 'usr_recepcion1',
        'usr_enfermeria1', 'usr_auditor1',
        'rol_medico', 'rol_enfermeria', 'rol_recepcion', 'rol_auditor'
    ]
    LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
            EXECUTE format('DROP OWNED BY %I', r);   -- revoca todos los privilegios
            EXECUTE format('DROP ROLE %I', r);
        END IF;
    END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 2. CREACIÓN DE ROLES
-- ----------------------------------------------------------------------------
CREATE ROLE rol_medico NOLOGIN;
CREATE ROLE rol_enfermeria NOLOGIN;
CREATE ROLE rol_recepcion NOLOGIN;
CREATE ROLE rol_auditor NOLOGIN;

GRANT USAGE ON SCHEMA public
    TO rol_medico, rol_enfermeria, rol_recepcion, rol_auditor;

-- ----------------------------------------------------------------------------
-- 3. PRIVILEGIOS POR ROL (PRINCIPIO DE MENOR PRIVILEGIO)
-- ----------------------------------------------------------------------------

-- 3.1 Médico: escribe en consulta y estudio_diagnostico; solo lee el resto.
--     Sin DELETE en ninguna tabla.
GRANT SELECT, INSERT, UPDATE ON consulta, estudio_diagnostico TO rol_medico;
GRANT SELECT ON paciente, expediente, persona, empleado, departamento,
                especialidad, tipo_estudio, ingreso_hospitalario, cama
    TO rol_medico;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_medico;

-- 3.2 Recepción: registra pacientes (paciente, persona, expediente)
GRANT SELECT, INSERT ON paciente, persona, expediente TO rol_recepcion;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_recepcion;

-- 3.3 Enfermería: solo lectura en tablas clínicas y hospitalarias.
GRANT SELECT ON paciente, expediente, consulta, estudio_diagnostico,
                cama, ingreso_hospitalario, persona, departamento
    TO rol_enfermeria;

-- 3.4 Auditor: únicamente lectura de la bitácora
GRANT SELECT ON auditoria_log TO rol_auditor;

-- ----------------------------------------------------------------------------
-- 4. FUNCIÓN AUXILIAR PARA RLS
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_departamento_de(p_usuario NAME)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT id_departamento
    FROM empleado
    WHERE usuario_bd = p_usuario::text
$$;

REVOKE ALL ON FUNCTION fn_departamento_de(NAME) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION fn_departamento_de(NAME)
    TO rol_medico, rol_enfermeria;

-- ----------------------------------------------------------------------------
-- 5. VINCULAR USUARIOS DE BD CON EMPLEADOS
-- ----------------------------------------------------------------------------
UPDATE empleado SET usuario_bd = 'usr_medico_cardio' WHERE id_empleado = 13;
UPDATE empleado SET usuario_bd = 'usr_medico_pediatria' WHERE id_empleado = 18;
UPDATE empleado SET usuario_bd = 'usr_enfermeria1' WHERE id_empleado = 20;

-- ----------------------------------------------------------------------------
-- 6. ROW LEVEL SECURITY EN EXPEDIENTE
-- ----------------------------------------------------------------------------
ALTER TABLE expediente ENABLE ROW LEVEL SECURITY;

-- 6.1 Médico: expedientes de pacientes atendidos o ingresados en SU departamento
CREATE POLICY pol_expediente_medico ON expediente
    FOR SELECT
    TO rol_medico
    USING (
        EXISTS (
            SELECT 1
            FROM consulta c
            WHERE c.id_paciente = expediente.id_paciente
              AND c.id_departamento = fn_departamento_de(current_user)
        )
        OR EXISTS (
            SELECT 1
            FROM ingreso_hospitalario ih
            JOIN cama ca ON ca.id_cama = ih.id_cama
            WHERE ih.id_paciente = expediente.id_paciente
              AND ca.id_departamento = fn_departamento_de(current_user)
        )
    );

-- 6.2 Enfermería: solo pacientes con ingreso ACTIVO en su departamento
CREATE POLICY pol_expediente_enfermeria ON expediente
    FOR SELECT
    TO rol_enfermeria
    USING (
        EXISTS (
            SELECT 1
            FROM ingreso_hospitalario ih
            JOIN cama ca ON ca.id_cama = ih.id_cama
            WHERE ih.id_paciente = expediente.id_paciente
              AND ca.id_departamento = fn_departamento_de(current_user)
              AND ih.estado = 'ACTIVO'
        )
    );

-- 6.3 Recepción: puede crear y consultar expedientes (registro de pacientes)
CREATE POLICY pol_expediente_recepcion_select ON expediente
    FOR SELECT
    TO rol_recepcion
    USING (true);

CREATE POLICY pol_expediente_recepcion_insert ON expediente
    FOR INSERT
    TO rol_recepcion
    WITH CHECK (true);

-- ----------------------------------------------------------------------------
-- 7. USUARIOS DE PRUEBA Y ASIGNACIÓN DE ROLES
-- ----------------------------------------------------------------------------
CREATE USER usr_medico_cardio WITH PASSWORD 'Cardio2026!';
CREATE USER usr_medico_pediatria WITH PASSWORD 'Pediatria2026!';
CREATE USER usr_recepcion1 WITH PASSWORD 'Recepcion2026!';
CREATE USER usr_enfermeria1 WITH PASSWORD 'Enfermeria2026!';
CREATE USER usr_auditor1 WITH PASSWORD 'Auditor2026!';

GRANT rol_medico TO usr_medico_cardio, usr_medico_pediatria;
GRANT rol_recepcion TO usr_recepcion1;
GRANT rol_enfermeria TO usr_enfermeria1;
GRANT rol_auditor TO usr_auditor1;

-- ----------------------------------------------------------------------------
-- 8. PRUEBAS RÁPIDAS (ejecutar manualmente)
-- ----------------------------------------------------------------------------
-- SET ROLE usr_medico_cardio; SELECT count(*) FROM expediente;  RESET ROLE;
-- SET ROLE usr_medico_pediatria; SELECT count(*) FROM expediente;  RESET ROLE;
-- SET ROLE usr_enfermeria1; SELECT count(*) FROM expediente;  RESET ROLE;
-- SET ROLE usr_auditor1; SELECT count(*) FROM auditoria_log; RESET ROLE;
-- SET ROLE usr_recepcion1; DELETE FROM paciente;  -- debe dar "permission denied"