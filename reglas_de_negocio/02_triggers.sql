-- =====================================================================
-- PERSONA 3: TRIGGERS
-- =====================================================================

-- 1. trg_consulta_medico
CREATE TRIGGER trg_consulta_medico
BEFORE INSERT OR UPDATE ON consulta
FOR EACH ROW
EXECUTE FUNCTION fn_validar_medico('id_empleado');

-- 2. trg_ingreso_medico
CREATE TRIGGER trg_ingreso_medico
BEFORE INSERT OR UPDATE ON ingreso_hospitalario
FOR EACH ROW
EXECUTE FUNCTION fn_validar_medico('id_medico_ingreso');

-- 3. trg_cirugia_medicos
CREATE TRIGGER trg_cirugia_medicos
BEFORE INSERT OR UPDATE ON cirugia
FOR EACH ROW
EXECUTE FUNCTION fn_validar_medico('id_cirujano_principal', 'id_anestesiologo');

-- 4. trg_interconsulta_medicos
CREATE TRIGGER trg_interconsulta_medicos
BEFORE INSERT OR UPDATE ON interconsulta
FOR EACH ROW
EXECUTE FUNCTION fn_validar_medico('id_medico_solicitante', 'id_medico_especialista');

-- 5. trg_estudio_medico
CREATE TRIGGER trg_estudio_medico
BEFORE INSERT OR UPDATE ON estudio_diagnostico
FOR EACH ROW
EXECUTE FUNCTION fn_validar_medico('id_medico_solicitante');

-- 6. trg_cirugia_anestesiologo
CREATE TRIGGER trg_cirugia_anestesiologo
BEFORE INSERT OR UPDATE OF id_anestesiologo ON cirugia
FOR EACH ROW
EXECUTE FUNCTION fn_validar_anestesiologo();

-- 7. trg_interconsulta_especialidad
CREATE TRIGGER trg_interconsulta_especialidad
BEFORE INSERT OR UPDATE ON interconsulta
FOR EACH ROW
EXECUTE FUNCTION fn_validar_interconsulta();

-- 8. trg_ingreso_cama
CREATE TRIGGER trg_ingreso_cama
BEFORE INSERT OR UPDATE ON ingreso_hospitalario
FOR EACH ROW
EXECUTE FUNCTION fn_ingreso_gestiona_cama();

-- 9. trg_detalle_stock
CREATE TRIGGER trg_detalle_stock
AFTER INSERT ON detalle_movimiento_inventario
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_stock();

-- 10. trg_detalle_inmutable
CREATE TRIGGER trg_detalle_inmutable
BEFORE UPDATE OR DELETE ON detalle_movimiento_inventario
FOR EACH ROW
EXECUTE FUNCTION fn_bloquear_modificacion();

-- =====================================================================
-- Pruebas de funcionamiento.
-- =====================================================================

-- Esto DEBE FALLAR con el mensaje de excepción del trigger:
INSERT INTO consulta (id_paciente, id_empleado, id_departamento, tipo_atencion, motivo_consulta)
VALUES (1, 19, 2, 'EXTERNA', 'Prueba de validación de médico');

-- Esto DEBE FALLAR porque los detalles son inmutables:
UPDATE detalle_movimiento_inventario 
SET cantidad = 500 
WHERE id_detalle = 1;

-- consulta para sincronizar el ultimo ID existente
SELECT setval('detalle_movimiento_inventario_id_detalle_seq', (SELECT MAX(id_detalle) FROM detalle_movimiento_inventario));

-- 1. Ver el stock inicial del insumo 1 "Guantes de nitrilo"
SELECT id_insumo, nombre_insumo, stock FROM insumo WHERE id_insumo = 1;

-- 2. Registrar un movimiento de inventario de tipo 'ENTRADA'
INSERT INTO movimiento_inventario (id_movimiento, id_empleado, tipo_movimiento)
VALUES (99, 20, 'ENTRADA');

-- 3. Insertar el detalle de ese movimiento, esto disparará el trigger trg_detalle_stock
INSERT INTO detalle_movimiento_inventario (id_movimiento, id_insumo, cantidad, precio_unitario)
VALUES (99, 1, 100, 15.50);

-- 4. Volver a consultar el stock del insumo 1, debe haber aumentado 100 unidades automáticamente
SELECT id_insumo, nombre_insumo, stock FROM insumo WHERE id_insumo = 1;