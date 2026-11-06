-- =============================================================================
-- 04_vistas.sql (Actualizado)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. LIMPIEZA DE VISTAS OBSOLETAS O CAMBIADAS DE NOMBRE
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vista_ocupacion_camas CASCADE;
DROP VIEW IF EXISTS vista_insumos_stock_bajo CASCADE;

-- (Opcional por seguridad)
DROP VIEW IF EXISTS vista_ocupacion_departamento CASCADE;
DROP VIEW IF EXISTS vista_agenda_quirurgica CASCADE;
DROP VIEW IF EXISTS vista_insumos_reposicion CASCADE;
DROP VIEW IF EXISTS vista_turnos_personal CASCADE;
DROP VIEW IF EXISTS vista_interconsultas_pendientes CASCADE;
DROP VIEW IF EXISTS vista_estudios_por_estado CASCADE;
DROP VIEW IF EXISTS vista_top_diagnosticos CASCADE;
DROP VIEW IF EXISTS vista_mantenimientos_pendientes CASCADE;
DROP VIEW IF EXISTS vista_resumen_expediente_paciente CASCADE;


-- -----------------------------------------------------------------------------
-- 1. OCUPACIÓN CONSOLIDADA POR DEPARTAMENTO
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_ocupacion_departamento AS
SELECT
    d.nombre_departamento,
    COUNT(*) FILTER (WHERE c.estado = 'OCUPADA') AS camas_ocupadas,
    COUNT(*) FILTER (WHERE c.estado = 'DISPONIBLE') AS camas_disponibles,
    COUNT(*) FILTER (WHERE c.estado = 'LIMPIEZA') AS camas_limpieza,
    COUNT(*) FILTER (WHERE c.estado = 'MANTENIMIENTO') AS camas_mantenimiento,
    COUNT(*) AS total_camas,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE c.estado = 'OCUPADA') / NULLIF(COUNT(*), 0),
        2
    ) AS porcentaje_ocupacion
FROM cama c
JOIN departamento d ON d.id_departamento = c.id_departamento
GROUP BY d.nombre_departamento;


-- -----------------------------------------------------------------------------
-- 2. AGENDA QUIRÚRGICA
-- -----------------------------------------------------------------------------
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


-- -----------------------------------------------------------------------------
-- 3. INSUMOS BAJO MÍNIMO CON COSTO DE REPOSICIÓN
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_insumos_reposicion AS
SELECT
    i.id_insumo,
    i.nombre_insumo,
    ti.nombre_tipo,
    i.stock,
    i.stock_minimo,
    (i.stock_minimo - i.stock) AS unidades_faltantes,
    i.precio,
    ROUND((i.stock_minimo - i.stock) * i.precio, 2) AS costo_estimado_reposicion
FROM insumo i
JOIN tipo_insumo ti ON ti.id_tipo_insumo = i.id_tipo_insumo
WHERE i.stock <= i.stock_minimo;


-- -----------------------------------------------------------------------------
-- 4. TURNOS DEL PERSONAL (guardias)
-- -----------------------------------------------------------------------------
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


-- -----------------------------------------------------------------------------
-- 5. INTERCONSULTAS PENDIENTES CON TIEMPO DE ESPERA
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_interconsultas_pendientes AS
SELECT
    i.id_interconsulta,
    pac.primer_nombre || ' ' || pac.primer_apellido AS paciente,
    sol.primer_nombre || ' ' || sol.primer_apellido AS medico_solicitante,
    esp.nombre_especialidad AS especialidad_solicitada,
    i.prioridad,
    i.estado,
    i.fecha_hora_solicitud,
    now() - i.fecha_hora_solicitud AS tiempo_espera
FROM interconsulta i
JOIN persona pac ON pac.id_persona = i.id_paciente
JOIN persona sol ON sol.id_persona = i.id_medico_solicitante
JOIN especialidad esp ON esp.id_especialidad = i.id_especialidad_solicitada
WHERE i.estado IN ('SOLICITADA', 'EN_PROCESO');


-- -----------------------------------------------------------------------------
-- 6. ESTUDIOS DIAGNÓSTICOS POR ESTADO Y CATEGORÍA
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_estudios_por_estado AS
SELECT
    te.categoria,
    ed.estado,
    COUNT(*) AS total_estudios
FROM estudio_diagnostico ed
JOIN tipo_estudio te ON te.id_tipo_estudio = ed.id_tipo_estudio
GROUP BY te.categoria, ed.estado;


-- -----------------------------------------------------------------------------
-- 7. TOP DIAGNÓSTICOS (últimos 90 días)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_top_diagnosticos AS
SELECT
    c.diagnostico,
    COUNT(*) AS frecuencia,
    COUNT(DISTINCT c.id_paciente) AS pacientes_distintos
FROM consulta c
WHERE c.fecha_hora_consulta >= now() - INTERVAL '90 days'
  AND c.diagnostico IS NOT NULL
GROUP BY c.diagnostico;


-- -----------------------------------------------------------------------------
-- 8. MANTENIMIENTOS PENDIENTES CON TIEMPO RESTANTE
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_mantenimientos_pendientes AS
SELECT
    e.nombre_equipo,
    e.numero_serie,
    e.criticidad,
    tm.nombre AS tipo_mantenimiento,
    m.fecha_hora_programada,
    m.estado,
    m.fecha_hora_programada - now() AS tiempo_restante
FROM mantenimiento_equipo m
JOIN equipo_medico e ON e.id_equipo = m.id_equipo
JOIN tipo_mantenimiento tm ON tm.id_tipo_mantenimiento = m.id_tipo_mantenimiento
WHERE m.estado IN ('PROGRAMADO', 'EN_PROCESO');


-- -----------------------------------------------------------------------------
-- 9. HISTORIAL DE CONSULTAS POR PACIENTE
-- -----------------------------------------------------------------------------
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
LEFT JOIN persona m  ON m.id_persona = e.id_empleado;


-- =============================================================================
-- PRUEBAS DE FUNCIONAMIENTO
-- =============================================================================
SELECT * FROM vista_ocupacion_departamento;
SELECT * FROM vista_agenda_quirurgica;
SELECT * FROM vista_insumos_reposicion;
SELECT * FROM vista_turnos_personal;
SELECT * FROM vista_interconsultas_pendientes;
SELECT * FROM vista_estudios_por_estado;
SELECT * FROM vista_top_diagnosticos ORDER BY frecuencia DESC LIMIT 10;
SELECT * FROM vista_mantenimientos_pendientes;
SELECT * FROM vista_resumen_expediente_paciente;
