-- ==========================================
-- ELIMINAR ÍNDICES 
-- ==========================================
DROP INDEX IF EXISTS ix_cama_estado;
DROP INDEX IF EXISTS ix_cirugia_programada;
DROP INDEX IF EXISTS ix_ingreso_fecha;
DROP INDEX IF EXISTS ix_estudio_tipo;
DROP INDEX IF EXISTS ix_movimiento_empleado;
DROP INDEX IF EXISTS ix_cama_disponible;
DROP INDEX IF EXISTS ix_cama_ocupada;
DROP INDEX IF EXISTS ix_cirugia_programadas;
DROP INDEX IF EXISTS ix_ingreso_fecha_estado;
DROP INDEX IF EXISTS ix_estudio_tipo_estado;
DROP INDEX IF EXISTS ix_persona_apellidos;
DROP INDEX IF EXISTS ix_turno_activos;
DROP INDEX IF EXISTS ix_interconsulta_pendientes;
DROP INDEX IF EXISTS ix_mant_pendientes;
DROP INDEX IF EXISTS ix_estudio_pendientes;
DROP INDEX IF EXISTS ix_insumo_stock_bajo;


-- ===============================
-- CREAR / ACTUALIZAR LOS ÍNDICES
-- ===============================

-- Índices únicos parciales
CREATE UNIQUE INDEX IF NOT EXISTS uq_telefono_principal 
    ON telefono_persona (id_persona) WHERE es_principal;
CREATE UNIQUE INDEX IF NOT EXISTS uq_direccion_principal 
    ON direccion_persona (id_persona) WHERE es_principal;
CREATE UNIQUE INDEX IF NOT EXISTS uq_contacto_principal 
    ON persona_contacto_emergencia (id_persona) WHERE es_principal;
CREATE UNIQUE INDEX IF NOT EXISTS uq_correo_principal 
    ON correo_empleado (id_empleado) WHERE es_principal;

CREATE UNIQUE INDEX IF NOT EXISTS uq_ingreso_cama_activa 
    ON ingreso_hospitalario (id_cama) WHERE estado = 'ACTIVO';
CREATE UNIQUE INDEX IF NOT EXISTS uq_ingreso_paciente_activo 
    ON ingreso_hospitalario (id_paciente) WHERE estado = 'ACTIVO';

-- Índices en llaves foráneas y búsquedas
CREATE INDEX IF NOT EXISTS ix_empleado_cargo 
    ON empleado (id_cargo);
CREATE INDEX IF NOT EXISTS ix_empleado_especialidad 
    ON empleado (id_especialidad);
CREATE INDEX IF NOT EXISTS ix_empleado_departamento 
    ON empleado (id_departamento);
CREATE INDEX IF NOT EXISTS ix_departamento_jefe 
    ON departamento (id_jefe_departamento);
CREATE INDEX IF NOT EXISTS ix_cama_departamento 
    ON cama (id_departamento);
CREATE INDEX IF NOT EXISTS ix_ingreso_paciente 
    ON ingreso_hospitalario (id_paciente);
CREATE INDEX IF NOT EXISTS ix_consulta_paciente 
    ON consulta (id_paciente, fecha_hora_consulta);
CREATE INDEX IF NOT EXISTS ix_cirugia_ingreso 
    ON cirugia (id_ingreso_hospitalario);
CREATE INDEX IF NOT EXISTS ix_cirugia_quirofano 
    ON cirugia (id_quirofano);
CREATE INDEX IF NOT EXISTS ix_cirugia_tipo 
    ON cirugia (id_tipo_cirugia);
CREATE INDEX IF NOT EXISTS ix_cirugiaequipo_empleado 
    ON cirugia_equipo (id_empleado);
CREATE INDEX IF NOT EXISTS ix_insumo_tipo 
    ON insumo (id_tipo_insumo);
CREATE INDEX IF NOT EXISTS ix_movimiento_cirugia 
    ON movimiento_inventario (id_cirugia);
CREATE INDEX IF NOT EXISTS ix_detalle_insumo 
    ON detalle_movimiento_inventario (id_insumo);
CREATE INDEX IF NOT EXISTS ix_turno_departamento 
    ON turno (id_departamento, fecha_hora_inicio);
CREATE INDEX IF NOT EXISTS ix_interconsulta_paciente 
    ON interconsulta (id_paciente);
CREATE INDEX IF NOT EXISTS ix_interconsulta_especialista 
    ON interconsulta (id_medico_especialista);
CREATE INDEX IF NOT EXISTS ix_equipo_departamento 
    ON equipo_medico (id_departamento);
CREATE INDEX IF NOT EXISTS ix_mant_equipo 
    ON mantenimiento_equipo (id_equipo, fecha_hora_programada);
CREATE INDEX IF NOT EXISTS ix_estudio_paciente 
    ON estudio_diagnostico (id_paciente);
CREATE INDEX IF NOT EXISTS ix_estudio_medico 
    ON estudio_diagnostico (id_medico_solicitante);

-- Nuevos índices parciales y compuestos
CREATE INDEX ix_cama_disponible 
    ON cama (id_departamento) WHERE estado = 'DISPONIBLE';
CREATE INDEX ix_cama_ocupada 
    ON cama (id_departamento) WHERE estado = 'OCUPADA';
CREATE INDEX ix_cirugia_programadas 
    ON cirugia (fecha_hora_programada) WHERE estado_cirugia = 'PROGRAMADA';
CREATE INDEX ix_ingreso_fecha_estado 
    ON ingreso_hospitalario (fecha_hora_ingreso, estado);
CREATE INDEX ix_estudio_tipo_estado 
    ON estudio_diagnostico (id_tipo_estudio, estado);
CREATE INDEX ix_persona_apellidos 
    ON persona (primer_apellido, primer_nombre);
CREATE INDEX ix_turno_activos 
    ON turno (id_departamento, fecha_hora_inicio) WHERE estado IN ('PROGRAMADO', 'EN_CURSO');
CREATE INDEX ix_interconsulta_pendientes 
    ON interconsulta (prioridad, fecha_hora_solicitud) WHERE estado IN ('SOLICITADA', 'EN_PROCESO');
CREATE INDEX ix_mant_pendientes 
    ON mantenimiento_equipo (fecha_hora_programada) WHERE estado IN ('PROGRAMADO', 'EN_PROCESO');
CREATE INDEX ix_estudio_pendientes 
    ON estudio_diagnostico (fecha_hora_solicitud) WHERE estado IN ('SOLICITADO', 'PROGRAMADO');
CREATE INDEX ix_insumo_stock_bajo 
    ON insumo (id_tipo_insumo) WHERE stock <= stock_minimo;

-- ========================
-- ACTUALIZAR ESTADÍSTICAS
-- ========================
ANALYZE persona;
ANALYZE cama;
ANALYZE ingreso_hospitalario;
ANALYZE cirugia;
ANALYZE consulta;
ANALYZE turno;
ANALYZE interconsulta;
ANALYZE mantenimiento_equipo;
ANALYZE estudio_diagnostico;
ANALYZE insumo;