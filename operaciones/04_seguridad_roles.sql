-- ============================================================================
-- SCRIPT DE ROLES, PRIVILEGIOS Y ROW LEVEL SECURITY (RLS) 
-- ============================================================================

-- Asegurar que el trigger de auditoría pueda escribir en auditoria_log
-- aunque el rol clínico (médico/recepción) no tenga acceso directo a dicha tabla
ALTER FUNCTION fn_auditoria_general() SECURITY DEFINER;

-- Limpieza previa para permitir re-ejecución sin errores
DO $$
DECLARE
    r TEXT;
BEGIN
    FOREACH r IN ARRAY ARRAY[
        'usr_medico_cardio', 'usr_medico_pediatria', 'usr_recepcion1',
        'usr_enfermeria1', 'usr_auditor1',
        'rol_medico', 'rol_enfermeria', 'rol_recepcion', 'rol_auditor'
    ]
    LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
            EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %I', r);
            EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM %I', r);
            EXECUTE format('REVOKE USAGE ON SCHEMA public FROM %I', r);
            EXECUTE format('DROP ROLE %I', r);
        END IF;
    END LOOP;
END $$;

-- ============================================================================
-- 1. CREACIÓN DE ROLES DEL SISTEMA HOSPITALARIO
-- ============================================================================
CREATE ROLE rol_medico NOLOGIN;
CREATE ROLE rol_enfermeria NOLOGIN;
CREATE ROLE rol_recepcion NOLOGIN;
CREATE ROLE rol_auditor NOLOGIN;

GRANT USAGE ON SCHEMA public TO rol_medico, rol_enfermeria, rol_recepcion, rol_auditor;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_medico, rol_recepcion;

-- ============================================================================
-- 2. ASIGNACIÓN DE PRIVILEGIOS POR ROL (PRINCIPIO DE MENOR PRIVILEGIO)
-- ============================================================================

-- 2.1 Médico: SELECT/INSERT/UPDATE en consulta y estudio_diagnostico;
--     solo SELECT en catálogos y paciente/expediente (SIN DELETE en paciente)
GRANT SELECT, INSERT, UPDATE ON consulta, estudio_diagnostico TO rol_medico;
GRANT SELECT ON paciente, expediente, persona, empleado, departamento, especialidad, tipo_estudio, ingreso_hospitalario, cama TO rol_medico;

-- 2.2 Recepción: solo INSERT y SELECT en paciente (y datos base de persona/expediente)
GRANT SELECT, INSERT ON paciente, persona, expediente TO rol_recepcion;

-- 2.3 Enfermería: solo lectura (SELECT) en tablas clínicas y hospitalarias
GRANT SELECT ON paciente, expediente, consulta, estudio_diagnostico, cama, ingreso_hospitalario, persona, departamento TO rol_enfermeria;

-- 2.4 Auditor: únicamente SELECT sobre la tabla de auditoría
GRANT SELECT ON auditoria_log TO rol_auditor;

-- ============================================================================
-- 3. ROW LEVEL SECURITY (RLS) EN TABLA EXPEDIENTE POR DEPARTAMENTO
-- ============================================================================

-- Vincular usuarios de base de datos con empleados médicos reales para la política RLS
ALTER TABLE empleado ADD COLUMN IF NOT EXISTS usuario_bd VARCHAR(60) UNIQUE;

-- Empleado 13 = Cardiólogo (Departamento 5: Cardiología)
-- Empleado 18 = Pediatra   (Departamento 4: Hospitalización Pediatría)
UPDATE empleado SET usuario_bd = 'usr_medico_cardio' WHERE id_empleado = 13;
UPDATE empleado SET usuario_bd = 'usr_medico_pediatria' WHERE id_empleado = 18;

-- Habilitar RLS en expediente
ALTER TABLE expediente ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_expediente_departamento_medico ON expediente;
CREATE POLICY pol_expediente_departamento_medico ON expediente
    FOR SELECT
    TO rol_medico
    USING (
        EXISTS (
            SELECT 1
            FROM consulta c
            JOIN empleado e ON e.id_departamento = c.id_departamento
            WHERE c.id_paciente = expediente.id_paciente
              AND e.usuario_bd = current_user
        )
        OR EXISTS (
            SELECT 1
            FROM ingreso_hospitalario ih
            JOIN cama ca ON ca.id_cama = ih.id_cama
            JOIN empleado e ON e.id_departamento = ca.id_departamento
            WHERE ih.id_paciente = expediente.id_paciente
              AND e.usuario_bd = current_user
        )
    );

-- Permitir lectura general de expediente a enfermería y recepción (sin restricción de departamento)
DROP POLICY IF EXISTS pol_expediente_otros_roles ON expediente;
CREATE POLICY pol_expediente_otros_roles ON expediente
    FOR SELECT
    TO rol_enfermeria, rol_recepcion
    USING (true);

-- ============================================================================
-- 4. USUARIOS DE PRUEBA ASOCIADOS A CADA ROL
-- ============================================================================
CREATE USER usr_medico_cardio WITH PASSWORD 'Cardio2026!';
GRANT rol_medico TO usr_medico_cardio;

CREATE USER usr_medico_pediatria WITH PASSWORD 'Pediatria2026!';
GRANT rol_medico TO usr_medico_pediatria;

CREATE USER usr_recepcion1 WITH PASSWORD 'Recepcion2026!';
GRANT rol_recepcion TO usr_recepcion1;

CREATE USER usr_enfermeria1 WITH PASSWORD 'Enfermeria2026!';
GRANT rol_enfermeria TO usr_enfermeria1;

CREATE USER usr_auditor1 WITH PASSWORD 'Auditor2026!';
GRANT rol_auditor TO usr_auditor1;