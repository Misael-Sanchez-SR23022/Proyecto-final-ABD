-- =============================================================================
-- SCRIPT DE VISTAS 
-- =============================================================================

-- 1. Ocupación actual de camas por departamento
CREATE OR REPLACE VIEW vista_ocupacion_camas AS
SELECT d.nombre_departamento,
       tc.nombre AS tipo_cama,
       c.estado,
       COUNT(*) AS total_camas
FROM cama c
JOIN departamento d ON d.id_departamento = c.id_departamento
JOIN tipo_cama tc ON tc.id_tipo_cama = c.id_tipo_cama
GROUP BY d.nombre_departamento, tc.nombre, c.estado;

-- 2. Agenda quirúrgica y programación de cirugías
CREATE OR REPLACE VIEW vista_agenda_quirurgica AS
SELECT ci.id_cirugia,
       ci.fecha_hora_programada,
       ci.estado_cirugia,
       q.nombre_quirofano,
       tci.nombre AS tipo_cirugia,
       pp.primer_nombre || ' ' || pp.primer_apellido AS paciente,
       pc.primer_nombre || ' ' || pc.primer_apellido AS cirujano_principal,
       pa.primer_nombre || ' ' || pa.primer_apellido AS anestesiologo
FROM cirugia ci
JOIN quirofano q ON q.id_quirofano = ci.id_quirofano
JOIN tipo_cirugia tci ON tci.id_tipo_cirugia = ci.id_tipo_cirugia
JOIN ingreso_hospitalario ih ON ih.id_ingreso_hospitalario = ci.id_ingreso_hospitalario
JOIN persona pp ON pp.id_persona = ih.id_paciente
JOIN persona pc ON pc.id_persona = ci.id_cirujano_principal
JOIN persona pa ON pa.id_persona = ci.id_anestesiologo;

-- 3. Insumos médicos con stock bajo o en nivel mínimo
CREATE OR REPLACE VIEW vista_insumos_stock_bajo AS
SELECT i.id_insumo,
       i.nombre_insumo,
       ti.nombre_tipo,
       i.stock,
       i.stock_minimo
FROM insumo i
JOIN tipo_insumo ti ON ti.id_tipo_insumo = i.id_tipo_insumo
WHERE i.stock <= i.stock_minimo;

-- 4. Mantenimientos de equipos médicos pendientes o en proceso
CREATE OR REPLACE VIEW vista_mantenimientos_pendientes AS
SELECT e.nombre_equipo,
       e.numero_serie,
       e.criticidad,
       tm.nombre AS tipo_mantenimiento,
       m.fecha_hora_programada,
       m.estado
FROM mantenimiento_equipo m
JOIN equipo_medico e ON e.id_equipo = m.id_equipo
JOIN tipo_mantenimiento tm ON tm.id_tipo_mantenimiento = m.id_tipo_mantenimiento
WHERE m.estado IN ('PROGRAMADO', 'EN_PROCESO')
ORDER BY m.fecha_hora_programada;

-- 5. Historial de consultas por paciente.
CREATE OR REPLACE VIEW vista_resumen_expediente_paciente AS
SELECT p.id_persona AS id_paciente,
       p.primer_nombre || ' ' || p.primer_apellido AS nombre_paciente,
       p.dui,
       pac.tipo_sangre,
       c.fecha_hora_consulta,
       c.motivo_consulta,
       c.diagnostico,
       m.primer_nombre || ' ' || m.primer_apellido AS medico_atendio
FROM persona p
JOIN paciente pac ON pac.id_paciente = p.id_persona
LEFT JOIN consulta c ON c.id_paciente = pac.id_paciente
LEFT JOIN empleado e ON e.id_empleado = c.id_empleado
LEFT JOIN persona m ON m.id_persona = e.id_empleado;

-- 6. Turnos del personal médico y de enfermería
CREATE OR REPLACE VIEW vista_turnos_personal AS
SELECT t.id_turno,
       p.primer_nombre || ' ' || p.primer_apellido AS nombre_empleado,
       cg.nombre_cargo,
       tt.nombre AS tipo_turno,
       d.nombre_departamento,
       t.fecha_hora_inicio,
       t.fecha_hora_fin,
       t.estado
FROM turno t
JOIN empleado e ON e.id_empleado = t.id_empleado
JOIN persona p ON p.id_persona = e.id_empleado
JOIN cargo cg ON cg.id_cargo = e.id_cargo
JOIN tipo_turno tt ON tt.id_tipo_turno = t.id_tipo_turno
JOIN departamento d ON d.id_departamento = t.id_departamento;

-- 7. Interconsultas pendientes de atención
CREATE OR REPLACE VIEW vista_interconsultas_pendientes AS
SELECT i.id_interconsulta,
       pac.primer_nombre || ' ' || pac.primer_apellido AS paciente,
       sol.primer_nombre || ' ' || sol.primer_apellido AS medico_solicitante,
       esp.nombre_especialidad AS especialidad_solicitada,
       i.prioridad,
       i.estado,
       i.fecha_hora_solicitud
FROM interconsulta i
JOIN persona pac ON pac.id_persona = i.id_paciente
JOIN persona sol ON sol.id_persona = i.id_medico_solicitante
JOIN especialidad esp ON esp.id_especialidad = i.id_especialidad_solicitada
WHERE i.estado IN ('SOLICITADA', 'EN_PROCESO');

-- =============================================================================
-- PRUEBAS DE FUNCIONAMIENTO
-- =============================================================================
SELECT * FROM vista_ocupacion_camas;
SELECT * FROM vista_agenda_quirurgica;
SELECT * FROM vista_insumos_stock_bajo;
SELECT * FROM vista_mantenimientos_pendientes;
SELECT * FROM vista_resumen_expediente_paciente;
SELECT * FROM vista_turnos_personal;
SELECT * FROM vista_interconsultas_pendientes;