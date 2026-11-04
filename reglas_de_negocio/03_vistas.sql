-- =============================================================================
-- SCRIPT DE VISTAS 
-- =============================================================================

-- 1. Ocupación y estado de camas hospitalarias por departamento
CREATE OR REPLACE VIEW vw_ocupacion_camas AS
SELECT 
    d.nombre_departamento,
    tc.nombre AS tipo_cama,
    c.habitacion,
    c.numero_cama,
    c.estado AS estado_cama
FROM cama c
JOIN departamento d ON c.id_departamento = d.id_departamento
JOIN tipo_cama tc ON c.id_tipo_cama = tc.id_tipo_cama;

-- 2. Historial unificado de consultas por paciente
CREATE OR REPLACE VIEW vw_resumen_expediente_paciente AS
SELECT 
    p.id_persona AS id_paciente,
    p.primer_nombre || ' ' || p.primer_apellido AS nombre_paciente,
    p.dui,
    pac.tipo_sangre,
    c.fecha_hora_consulta,
    c.motivo_consulta,
    c.diagnostico,
    m.primer_nombre || ' ' || m.primer_apellido AS medico_atendio
FROM persona p
JOIN paciente pac ON p.id_persona = pac.id_paciente
LEFT JOIN consulta c ON pac.id_paciente = c.id_paciente
LEFT JOIN empleado e ON c.id_empleado = e.id_empleado
LEFT JOIN persona m ON e.id_empleado = m.id_persona;

-- 3. Programación y estado de procedimientos quirúrgicos
CREATE OR REPLACE VIEW vw_programacion_cirugias AS
SELECT 
    c.id_cirugia,
    q.nombre_quirofano,
    tc.nombre AS tipo_cirugia,
    c.fecha_hora_programada,
    c.estado_cirugia,
    med.primer_nombre || ' ' || med.primer_apellido AS cirujano_principal
FROM cirugia c
JOIN quirofano q ON c.id_quirofano = q.id_quirofano
JOIN tipo_cirugia tc ON c.id_tipo_cirugia = tc.id_tipo_cirugia
JOIN persona med ON c.id_cirujano_principal = med.id_persona;

-- 4. Insumos médicos críticos (stock mínimo o agotados)
CREATE OR REPLACE VIEW vw_inventario_critico_insumos AS
SELECT 
    i.id_insumo,
    i.nombre_insumo,
    ti.nombre_tipo AS categoria,
    i.stock,
    i.stock_minimo,
    i.precio,
    CASE 
        WHEN i.stock = 0 THEN 'AGOTADO'
        WHEN i.stock <= i.stock_minimo THEN 'RESERVA CRÍTICA'
        ELSE 'NORMAL'
    END AS estado_alerta
FROM insumo i
JOIN tipo_insumo ti ON i.id_tipo_insumo = ti.id_tipo_insumo
WHERE i.stock <= i.stock_minimo;

-- 5. Programación de turnos del personal médico y de enfermería
CREATE OR REPLACE VIEW vw_turnos_personal AS
SELECT 
    t.id_turno,
    p.primer_nombre || ' ' || p.primer_apellido AS nombre_empleado,
    cg.nombre_cargo,
    tt.nombre AS tipo_turno,
    d.nombre_departamento,
    t.fecha_hora_inicio,
    t.fecha_hora_fin,
    t.estado
FROM turno t
JOIN empleado e ON t.id_empleado = e.id_empleado
JOIN persona p ON e.id_empleado = p.id_persona
JOIN cargo cg ON e.id_cargo = cg.id_cargo
JOIN tipo_turno tt ON t.id_tipo_turno = tt.id_tipo_turno
JOIN departamento d ON t.id_departamento = d.id_departamento;

-- 6. Interconsultas médicas pendientes de atención
CREATE OR REPLACE VIEW vw_interconsultas_pendientes AS
SELECT 
    i.id_interconsulta,
    pac.primer_nombre || ' ' || pac.primer_apellido AS paciente,
    sol.primer_nombre || ' ' || sol.primer_apellido AS medico_solicitante,
    esp.nombre_especialidad AS especialidad_solicitada,
    i.prioridad,
    i.estado,
    i.fecha_hora_solicitud
FROM interconsulta i
JOIN persona pac ON i.id_paciente = pac.id_persona
JOIN persona sol ON i.id_medico_solicitante = sol.id_persona
JOIN especialidad esp ON i.id_especialidad_solicitada = esp.id_especialidad
WHERE i.estado IN ('SOLICITADA', 'EN_PROCESO');

-- 7. Control y calendario de mantenimiento de equipos médicos
CREATE OR REPLACE VIEW vw_mantenimiento_equipos AS
SELECT 
    eq.nombre_equipo,
    eq.numero_serie,
    d.nombre_departamento,
    eq.criticidad,
    tm.nombre AS tipo_mantenimiento,
    me.fecha_hora_programada,
    me.estado AS estado_mantenimiento
FROM equipo_medico eq
JOIN departamento d ON eq.id_departamento = d.id_departamento
JOIN mantenimiento_equipo me ON eq.id_equipo = me.id_equipo
JOIN tipo_mantenimiento tm ON me.id_tipo_mantenimiento = tm.id_tipo_mantenimiento;

-- =============================================================================
-- PRUEBAS DE FUNCIONAMIENTO
-- =============================================================================
SELECT * FROM vw_ocupacion_camas;
SELECT * FROM vw_resumen_expediente_paciente;
SELECT * FROM vw_programacion_cirugias;
SELECT * FROM vw_inventario_critico_insumos;
SELECT * FROM vw_turnos_personal;
SELECT * FROM vw_interconsultas_pendientes;
SELECT * FROM vw_mantenimiento_equipos;
