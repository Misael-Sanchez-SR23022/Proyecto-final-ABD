-- Índices únicos parciales (garantizan "uno principal" / "uno activo")
CREATE UNIQUE INDEX uq_telefono_principal ON telefono_persona (id_persona) WHERE es_principal;
CREATE UNIQUE INDEX uq_direccion_principal ON direccion_persona (id_persona) WHERE es_principal;
CREATE UNIQUE INDEX uq_contacto_principal ON persona_contacto_emergencia (id_persona) WHERE es_principal;
CREATE UNIQUE INDEX uq_correo_principal ON correo_empleado (id_empleado) WHERE es_principal;

-- Una cama solo puede tener un ingreso activo, y un paciente solo uno activo a la vez
CREATE UNIQUE INDEX uq_ingreso_cama_activa ON ingreso_hospitalario (id_cama) WHERE estado = 'ACTIVO';
CREATE UNIQUE INDEX uq_ingreso_paciente_activo ON ingreso_hospitalario (id_paciente) WHERE estado = 'ACTIVO';

-- =====================================================================
-- ÍNDICES EN LLAVES FORÁNEAS Y CAMPOS DE BÚSQUEDA
-- =====================================================================

CREATE INDEX ix_empleado_cargo ON empleado (id_cargo);
CREATE INDEX ix_empleado_especialidad ON empleado (id_especialidad);
CREATE INDEX ix_empleado_departamento ON empleado (id_departamento);
CREATE INDEX ix_departamento_jefe ON departamento (id_jefe_departamento);
CREATE INDEX ix_cama_departamento ON cama (id_departamento);
CREATE INDEX ix_cama_estado ON cama (estado);
CREATE INDEX ix_ingreso_paciente ON ingreso_hospitalario (id_paciente);
CREATE INDEX ix_ingreso_fecha ON ingreso_hospitalario (fecha_hora_ingreso);
CREATE INDEX ix_consulta_paciente ON consulta (id_paciente, fecha_hora_consulta);
CREATE INDEX ix_consulta_empleado ON consulta (id_empleado);
CREATE INDEX ix_cirugia_ingreso ON cirugia (id_ingreso_hospitalario);
CREATE INDEX ix_cirugia_quirofano ON cirugia (id_quirofano);
CREATE INDEX ix_cirugia_programada ON cirugia (fecha_hora_programada);
CREATE INDEX ix_cirugia_tipo ON cirugia (id_tipo_cirugia);
CREATE INDEX ix_cirugiaequipo_empleado ON cirugia_equipo (id_empleado);
CREATE INDEX ix_insumo_tipo ON insumo (id_tipo_insumo);
CREATE INDEX ix_movimiento_empleado ON movimiento_inventario (id_empleado);
CREATE INDEX ix_movimiento_cirugia ON movimiento_inventario (id_cirugia);
CREATE INDEX ix_detalle_insumo ON detalle_movimiento_inventario (id_insumo);
CREATE INDEX ix_turno_departamento ON turno (id_departamento, fecha_hora_inicio);
CREATE INDEX ix_interconsulta_paciente ON interconsulta (id_paciente);
CREATE INDEX ix_interconsulta_espec ON interconsulta (id_medico_especialista);
CREATE INDEX ix_equipo_departamento ON equipo_medico (id_departamento);
CREATE INDEX ix_mant_equipo ON mantenimiento_equipo (id_equipo, fecha_hora_programada);
CREATE INDEX ix_estudio_paciente ON estudio_diagnostico (id_paciente);
CREATE INDEX ix_estudio_tipo ON estudio_diagnostico (id_tipo_estudio);
CREATE INDEX ix_estudio_medico ON estudio_diagnostico (id_medico_solicitante);