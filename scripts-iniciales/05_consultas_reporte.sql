-- =====================================================================
-- 05_consultas_reporte.sql
-- =====================================================================

-- 1. Ocupación por departamento
SELECT * FROM vista_ocupacion_departamento
ORDER BY porcentaje_ocupacion DESC;


-- 2. Agenda quirúrgica del día
SELECT * FROM vista_agenda_quirurgica
WHERE fecha_hora_programada::date = CURRENT_DATE
  AND estado_cirurgia IN ('PROGRAMADA', 'EN_CURSO')
ORDER BY fecha_hora_programada, nombre_quirofano;


-- 3. Insumos bajo mínimo
SELECT * FROM vista_insumos_reposicion
ORDER BY unidades_faltantes DESC, nombre_insumo;


-- 4. Guardias activas / próximas 24 h
SELECT * FROM vista_turnos_personal
WHERE estado IN ('PROGRAMADO', 'EN_CURSO')
  AND fecha_hora_inicio BETWEEN now() - INTERVAL '1 hour'
  AND now() + INTERVAL '24 hours'
ORDER BY fecha_hora_inicio;


-- 5. Interconsultas pendientes por prioridad
SELECT * FROM vista_interconsultas_pendientes
ORDER BY
    CASE prioridad WHEN 'URGENTE' THEN 1
     WHEN 'NORMAL' THEN 2
     ELSE 3 END, fecha_hora_solicitud;


-- 6. Estudios por estado y categoría
SELECT * FROM vista_r6_estudios_por_estado
ORDER BY categoria, estado;


-- 7. Top 10 diagnósticos (últimos 90 días)
SELECT * FROM vista_r7_top_diagnosticos
ORDER BY frecuencia DESC
LIMIT 10;


-- 8. Mantenimientos pendientes (críticos primero)
SELECT * FROM vista_mantenimientos_pendientes
ORDER BY
    CASE criticidad WHEN 'CRITICA' THEN 1
    WHEN 'ALTA' THEN 2
    WHEN 'MEDIA' THEN 3
    ELSE 4 END, fecha_hora_programada;