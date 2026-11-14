-- ============================================================================
-- ROLES, PRIVILEGIOS Y ROW LEVEL SECURITY (RLS)
-- Ejecutar como administrador/propietario de la BD después del DDL y datos.
-- Crear los LOGIN por separado con contraseñas secretas (CREATE ROLE ... LOGIN)
-- y asignarles uno de estos roles NOLOGIN. No guardar contraseñas en Git.
-- ============================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_medico') THEN
        CREATE ROLE rol_medico NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_enfermeria') THEN
        CREATE ROLE rol_enfermeria NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_recepcion') THEN
        CREATE ROLE rol_recepcion NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_auditor') THEN
        CREATE ROLE rol_auditor NOLOGIN;
    END IF;
END $$;

GRANT USAGE ON SCHEMA public TO rol_medico, rol_enfermeria, rol_recepcion, rol_auditor;

-- Vinculación explícita login BD -> empleado. Completar para cada cuenta real.
ALTER TABLE empleado ADD COLUMN IF NOT EXISTS usuario_bd VARCHAR(60);
CREATE UNIQUE INDEX IF NOT EXISTS uq_empleado_usuario_bd
    ON empleado(usuario_bd) WHERE usuario_bd IS NOT NULL;

-- Mantener los ejemplos existentes, pero no crear usuarios ni contraseñas aquí.
UPDATE empleado SET usuario_bd = 'usr_medico_cardio' WHERE id_empleado = 13;
UPDATE empleado SET usuario_bd = 'usr_medico_pediatria' WHERE id_empleado = 18;

-- Funciones auxiliares SECURITY DEFINER: el propietario debe ser el propietario
-- confiable de empleado y no un rol de aplicación. search_path queda fijado.
CREATE OR REPLACE FUNCTION fn_rls_empleado_id()
RETURNS BIGINT
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
    SELECT e.id_empleado
    FROM public.empleado e
    WHERE e.usuario_bd = session_user
    LIMIT 1
$$;

CREATE OR REPLACE FUNCTION fn_rls_departamento_id()
RETURNS BIGINT
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
    SELECT e.id_departamento
    FROM public.empleado e
    WHERE e.usuario_bd = session_user
    LIMIT 1
$$;

REVOKE ALL ON FUNCTION fn_rls_empleado_id() FROM PUBLIC;
REVOKE ALL ON FUNCTION fn_rls_departamento_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION fn_rls_empleado_id(), fn_rls_departamento_id()
TO rol_medico, rol_enfermeria;

-- Privilegios mínimos: no se concede lectura clínica general a recepción.
GRANT SELECT ON persona, empleado, departamento, especialidad, tipo_estudio TO rol_medico;
GRANT SELECT, INSERT, UPDATE ON consulta, estudio_diagnostico TO rol_medico;
GRANT SELECT ON paciente, expediente, ingreso_hospitalario, cama TO rol_medico;

GRANT SELECT ON persona, empleado, departamento, cama TO rol_enfermeria;
GRANT SELECT ON paciente, expediente, consulta, estudio_diagnostico,
    ingreso_hospitalario, interconsulta TO rol_enfermeria;

GRANT SELECT, INSERT ON persona, paciente TO rol_recepcion;
GRANT SELECT, INSERT ON expediente TO rol_recepcion;

GRANT SELECT ON auditoria_log TO rol_auditor;

-- Secuencias requeridas por INSERT, si el rol las necesita.
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_medico, rol_recepcion;

-- Activar RLS en las tablas que contienen datos clínicos o identificadores.
ALTER TABLE paciente ENABLE ROW LEVEL SECURITY;
ALTER TABLE expediente ENABLE ROW LEVEL SECURITY;
ALTER TABLE consulta ENABLE ROW LEVEL SECURITY;
ALTER TABLE estudio_diagnostico ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingreso_hospitalario ENABLE ROW LEVEL SECURITY;
ALTER TABLE interconsulta ENABLE ROW LEVEL SECURITY;

-- Paciente: el médico accede si tiene consulta o ingreso asociado.
DROP POLICY IF EXISTS pol_paciente_medico ON paciente;
CREATE POLICY pol_paciente_medico ON paciente
FOR SELECT TO rol_medico
USING (
    EXISTS (
        SELECT 1 FROM public.consulta c
        WHERE c.id_paciente = paciente.id_paciente
          AND c.id_empleado = public.fn_rls_empleado_id()
    )
    OR EXISTS (
        SELECT 1 FROM public.ingreso_hospitalario ih
        WHERE ih.id_paciente = paciente.id_paciente
          AND ih.id_medico_ingreso = public.fn_rls_empleado_id()
    )
    OR EXISTS (
        SELECT 1 FROM public.estudio_diagnostico ed
        WHERE ed.id_paciente = paciente.id_paciente
          AND ed.id_medico_solicitante = public.fn_rls_empleado_id()
    )
);

DROP POLICY IF EXISTS pol_paciente_enfermeria ON paciente;
CREATE POLICY pol_paciente_enfermeria ON paciente
FOR SELECT TO rol_enfermeria
USING (
    EXISTS (
        SELECT 1 FROM public.ingreso_hospitalario ih
        JOIN public.cama ca ON ca.id_cama = ih.id_cama
        WHERE ih.id_paciente = paciente.id_paciente
          AND ca.id_departamento = public.fn_rls_departamento_id()
          AND ih.estado = 'ACTIVO'
    )
);

-- Expediente: mismo ámbito clínico que paciente.
DROP POLICY IF EXISTS pol_expediente_medico ON expediente;
CREATE POLICY pol_expediente_medico ON expediente
FOR SELECT TO rol_medico
USING (
    EXISTS (
        SELECT 1 FROM public.consulta c
        WHERE c.id_paciente = expediente.id_paciente
          AND c.id_empleado = public.fn_rls_empleado_id()
    )
    OR EXISTS (
        SELECT 1 FROM public.ingreso_hospitalario ih
        WHERE ih.id_paciente = expediente.id_paciente
          AND ih.id_medico_ingreso = public.fn_rls_empleado_id()
    )
    OR EXISTS (
        SELECT 1 FROM public.estudio_diagnostico ed
        WHERE ed.id_paciente = expediente.id_paciente
          AND ed.id_medico_solicitante = public.fn_rls_empleado_id()
    )
);

DROP POLICY IF EXISTS pol_expediente_enfermeria ON expediente;
CREATE POLICY pol_expediente_enfermeria ON expediente
FOR SELECT TO rol_enfermeria
USING (
    EXISTS (
        SELECT 1 FROM public.ingreso_hospitalario ih
        JOIN public.cama ca ON ca.id_cama = ih.id_cama
        WHERE ih.id_paciente = expediente.id_paciente
          AND ca.id_departamento = public.fn_rls_departamento_id()
          AND ih.estado = 'ACTIVO'
    )
);

-- Consulta: médico responsable o personal de enfermería del departamento
-- del encuentro (la política no habilita lectura global a toda la clínica).
DROP POLICY IF EXISTS pol_consulta_medico ON consulta;
CREATE POLICY pol_consulta_medico ON consulta
FOR SELECT TO rol_medico
USING (id_empleado = public.fn_rls_empleado_id());

DROP POLICY IF EXISTS pol_consulta_medico_insert ON consulta;
CREATE POLICY pol_consulta_medico_insert ON consulta
FOR INSERT TO rol_medico
WITH CHECK (id_empleado = public.fn_rls_empleado_id());

DROP POLICY IF EXISTS pol_consulta_medico_update ON consulta;
CREATE POLICY pol_consulta_medico_update ON consulta
FOR UPDATE TO rol_medico
USING (id_empleado = public.fn_rls_empleado_id())
WITH CHECK (id_empleado = public.fn_rls_empleado_id());

DROP POLICY IF EXISTS pol_consulta_enfermeria ON consulta;
CREATE POLICY pol_consulta_enfermeria ON consulta
FOR SELECT TO rol_enfermeria
USING (id_departamento = public.fn_rls_departamento_id());

-- Estudios: médico solicitante; enfermería de departamento solo mediante
-- solicitud vinculada a una consulta del mismo departamento no disponible
-- en el esquema, por lo que se restringe a los estudios solicitados por él.
DROP POLICY IF EXISTS pol_estudio_medico ON estudio_diagnostico;
CREATE POLICY pol_estudio_medico ON estudio_diagnostico
FOR SELECT TO rol_medico
USING (id_medico_solicitante = public.fn_rls_empleado_id());

DROP POLICY IF EXISTS pol_estudio_medico_insert ON estudio_diagnostico;
CREATE POLICY pol_estudio_medico_insert ON estudio_diagnostico
FOR INSERT TO rol_medico
WITH CHECK (id_medico_solicitante = public.fn_rls_empleado_id());

DROP POLICY IF EXISTS pol_estudio_medico_update ON estudio_diagnostico;
CREATE POLICY pol_estudio_medico_update ON estudio_diagnostico
FOR UPDATE TO rol_medico
USING (id_medico_solicitante = public.fn_rls_empleado_id())
WITH CHECK (id_medico_solicitante = public.fn_rls_empleado_id());

-- Ingresos: médico que formalizó el ingreso; enfermería del departamento de cama.
DROP POLICY IF EXISTS pol_ingreso_medico ON ingreso_hospitalario;
CREATE POLICY pol_ingreso_medico ON ingreso_hospitalario
FOR SELECT TO rol_medico
USING (id_medico_ingreso = public.fn_rls_empleado_id());

DROP POLICY IF EXISTS pol_ingreso_enfermeria ON ingreso_hospitalario;
CREATE POLICY pol_ingreso_enfermeria ON ingreso_hospitalario
FOR SELECT TO rol_enfermeria
USING (
    EXISTS (
        SELECT 1 FROM public.cama ca
        WHERE ca.id_cama = ingreso_hospitalario.id_cama
          AND ca.id_departamento = public.fn_rls_departamento_id()
    )
);

-- Interconsultas: únicamente solicitante o especialista asignado.
DROP POLICY IF EXISTS pol_interconsulta_medico ON interconsulta;
CREATE POLICY pol_interconsulta_medico ON interconsulta
FOR SELECT TO rol_medico
USING (
    id_medico_solicitante = public.fn_rls_empleado_id()
    OR id_medico_especialista = public.fn_rls_empleado_id()
);

-- Recepción no obtiene SELECT sobre consulta, estudio, ingreso ni interconsulta.
-- La identidad de las cuentas de aplicación debe coincidir con empleado.usuario_bd.
-- No otorgar BYPASSRLS, SUPERUSER ni propiedad de tablas a usuarios de aplicación.

-- Verificación administrativa:
-- SELECT c.relname, c.relrowsecurity
-- FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
-- WHERE n.nspname='public' AND c.relname IN
-- ('paciente','expediente','consulta','estudio_diagnostico','ingreso_hospitalario','interconsulta');
-- SELECT * FROM pg_policies WHERE schemaname='public';


-- Capa adicional de privacidad: persona contiene datos identificativos de
-- pacientes y empleados. No permitir a los roles clínicos una lectura global.
ALTER TABLE persona ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_persona_medico ON persona;
CREATE POLICY pol_persona_medico ON persona
FOR SELECT TO rol_medico
USING (
    id_persona = public.fn_rls_empleado_id()
    OR EXISTS (
        SELECT 1 FROM public.paciente p
        WHERE p.id_paciente = persona.id_persona
    )
);

DROP POLICY IF EXISTS pol_persona_enfermeria ON persona;
CREATE POLICY pol_persona_enfermeria ON persona
FOR SELECT TO rol_enfermeria
USING (
    id_persona = public.fn_rls_empleado_id()
    OR EXISTS (
        SELECT 1 FROM public.paciente p
        JOIN public.ingreso_hospitalario ih ON ih.id_paciente=p.id_paciente
        JOIN public.cama ca ON ca.id_cama=ih.id_cama
        WHERE p.id_paciente=persona.id_persona
          AND ca.id_departamento=public.fn_rls_departamento_id()
          AND ih.estado='ACTIVO'
    )
);

-- Recepción registra identidades, pero no obtiene un SELECT indiscriminado.
REVOKE SELECT ON persona, paciente, expediente FROM rol_recepcion;
GRANT INSERT ON persona, paciente, expediente TO rol_recepcion;

DROP POLICY IF EXISTS pol_persona_recepcion_insert ON persona;
CREATE POLICY pol_persona_recepcion_insert ON persona
FOR INSERT TO rol_recepcion WITH CHECK (true);

DROP POLICY IF EXISTS pol_paciente_recepcion_insert ON paciente;
CREATE POLICY pol_paciente_recepcion_insert ON paciente
FOR INSERT TO rol_recepcion WITH CHECK (true);

DROP POLICY IF EXISTS pol_expediente_recepcion_insert ON expediente;
CREATE POLICY pol_expediente_recepcion_insert ON expediente
FOR INSERT TO rol_recepcion WITH CHECK (true);

-- RLS para datos identificativos: no se habilita acceso público ni lectura
-- global para recepción. La aplicación debe capturar el ID generado de forma
-- segura durante el alta (por ejemplo, con una función transaccional controlada).
