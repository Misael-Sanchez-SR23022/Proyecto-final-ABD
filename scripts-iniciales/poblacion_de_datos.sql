-- =====================================================================
-- 0. CATÁLOGOS
-- =====================================================================

INSERT INTO especialidad (id_especialidad, nombre_especialidad, descripcion, estado) VALUES
(1, 'Anestesiología', 'Manejo de anestesia y cuidado perioperatorio', 'ACTIVO'),
(2, 'Cirugía General', 'Cirugías del abdomen y tejidos blandos', 'ACTIVO'),
(3, 'Traumatología', 'Fracturas y patología del sistema osteomuscular', 'ACTIVO'),
(4, 'Cardiología', 'Patología del corazón y sistema circulatorio', 'ACTIVO'),
(5, 'Medicina Interna', 'Atención integral del adulto', 'ACTIVO'),
(6, 'Pediatría', 'Atención de niños y adolescentes', 'ACTIVO'),
(7, 'Ginecología y Obstetricia', 'Salud de la mujer y atención del embarazo', 'ACTIVO'),
(8, 'Neurología', 'Patología del sistema nervioso', 'ACTIVO'),
(9, 'Endocrinología', 'Trastornos hormonales y metabólicos', 'ACTIVO'),
(10, 'Neumología', 'Patología del sistema respiratorio', 'ACTIVO');

INSERT INTO cargo (id_cargo, nombre_cargo, descripcion, estado) VALUES
(1, 'Cirujano General', 'Médico especialista en cirugía general', 'ACTIVO'),
(2, 'Traumatólogo', 'Médico especialista en traumatología', 'ACTIVO'),
(3, 'Cardiólogo', 'Médico especialista en cardiología', 'ACTIVO'),
(4, 'Anestesiólogo', 'Médico especialista en anestesiología', 'ACTIVO'),
(5, 'Ginecólogo', 'Médico especialista en ginecología y obstetricia', 'ACTIVO'),
(6, 'Pediatra', 'Médico especialista en pediatría', 'ACTIVO'),
(7, 'Médico Internista', 'Médico especialista en medicina interna', 'ACTIVO'),
(8, 'Técnico Radiólogo', 'Operador de equipos de imagenología', 'ACTIVO'),
(9, 'Enfermera Jefe', 'Responsable de supervisión de enfermería', 'ACTIVO'),
(10, 'Enfermera Instrumentista', 'Enfermera de apoyo en cirugías', 'ACTIVO');

INSERT INTO departamento (id_departamento, id_jefe_departamento, nombre_departamento, piso, estado) VALUES
(1, NULL, 'Cirugía General', 2, 'ACTIVO'),
(2, NULL, 'Emergencias', 1, 'ACTIVO'),
(3, NULL, 'Hospitalización Adultos', 3, 'ACTIVO'),
(4, NULL, 'Hospitalización Pediatría', 4, 'ACTIVO'),
(5, NULL, 'Cardiología', 3, 'ACTIVO'),
(6, NULL, 'Quirófanos', 2, 'ACTIVO'),
(7, NULL, 'Laboratorio Clínico', 1, 'ACTIVO'),
(8, NULL, 'Radiología', 1, 'ACTIVO'),
(9, NULL, 'Mantenimiento', 1, 'ACTIVO'),
(10, NULL, 'Administración', 5, 'ACTIVO');

INSERT INTO tipo_cama (id_tipo_cama, nombre, descripcion) VALUES
(1, 'Privada', 'Habitación individual con baño'),
(2, 'Semiprivada', 'Habitación compartida para dos pacientes'),
(3, 'Compartida', 'Habitación para tres o más pacientes'),
(4, 'UCI Adultos', 'Cama de cuidados intensivos para adultos'),
(5, 'UCI Pediátrica', 'Cama de cuidados intensivos para niños'),
(6, 'Cuna', 'Cuna para recién nacidos'),
(7, 'Aislamiento', 'Cama en habitación de aislamiento infeccioso'),
(8, 'Observación', 'Camilla de observación en emergencias'),
(9, 'Recuperación', 'Cama de recuperación postoperatoria'),
(10, 'Pediatría', 'Cama adaptada para pacientes pediátricos');

INSERT INTO tipo_quirofano (id_tipo_quirofano, nombre, descripcion) VALUES
(1, 'General', 'Quirófano para cirugías generales'),
(2, 'Cardiovascular', 'Quirófano equipado para cirugía cardiaca'),
(3, 'Ortopédico', 'Quirófano con mesa ortopédica y fluoroscopio'),
(4, 'Traumatológico', 'Quirófano para cirugía de trauma'),
(5, 'Ginecológico', 'Quirófano para cirugía ginecoobstétrica'),
(6, 'Pediátrico', 'Quirófano para pacientes pediátricos'),
(7, 'Ambulatorio', 'Quirófano para cirugías de corta estancia'),
(8, 'De Urgencias', 'Quirófano reservado para trauma y urgencias'),
(9, 'Oftalmológico', 'Quirófano para cirugía ocular'),
(10, 'De Cesáreas', 'Quirófano exclusivo para cesáreas');

INSERT INTO tipo_cirugia (id_tipo_cirugia, id_especialidad, nombre, descripcion, duracion_estimada_minutos, complejidad) VALUES
(1, 2, 'Apendicectomía', 'Extracción del apéndice cecal', 60, 'MEDIA'),
(2, 2, 'Colecistectomía', 'Extracción de la vesícula biliar', 90, 'MEDIA'),
(3, 2, 'Hernioplastia', 'Reparación de hernia', 75, 'BAJA'),
(4, 3, 'Osteosíntesis de fractura', 'Fijación interna de fractura con placa', 120, 'ALTA'),
(5, 3, 'Artroscopia de rodilla', 'Cirugía mínimamente invasiva de rodilla', 90, 'MEDIA'),
(6, 7, 'Cesárea', 'Extracción del producto por vía abdominal', 60, 'ALTA'),
(7, 2, 'Laparoscopia diagnóstica', 'Exploración abdominal mínimamente invasiva', 60, 'MEDIA'),
(8, 3, 'Reducción cerrada de fractura', 'Alineación de fractura sin cirugía abierta', 45, 'MEDIA'),
(9, 7, 'Histerectomía', 'Extracción del útero', 150, 'ALTA'),
(10, NULL, 'Cirugía de catarata', 'Facoemulsificación (especialidad pendiente de catálogo)', 40, 'BAJA');

INSERT INTO tipo_insumo (id_tipo_insumo, nombre_tipo, descripcion) VALUES
(1, 'Medicamento', 'Fármacos para administración a pacientes'),
(2, 'Material de Curación', 'Gasas, vendas, apósitos y similares'),
(3, 'Insumo Quirúrgico', 'Material estéril para procedimientos quirúrgicos'),
(4, 'Reactivo de Laboratorio', 'Insumos para pruebas de laboratorio clínico'),
(5, 'Gas Médico', 'Oxígeno, óxido nitroso y aire medicinal'),
(6, 'Descartable', 'Material desechable de uso clínico general'),
(7, 'Hemoderivado', 'Derivados de sangre humana'),
(8, 'Material de Esterilización', 'Bolsas, indicadores y envolturas de esterilización'),
(9, 'Insumo de Laboratorio', 'Tubos, pipetas y contenedores de muestras'),
(10, 'Insumo Radiológico', 'Películas, contrastes y reveladores');

INSERT INTO tipo_turno (id_tipo_turno, nombre, descripcion) VALUES
(1, 'Mañana A', 'Turno de 07:00 a 15:00'),
(2, 'Tarde A', 'Turno de 15:00 a 23:00'),
(3, 'Noche A', 'Turno de 23:00 a 07:00 del día siguiente'),
(4, 'Mañana B', 'Turno de 07:00 a 15:00 (personal de apoyo)'),
(5, 'Guardia 24H', 'Guardia médica de 24 horas'),
(6, 'Noche B', 'Turno nocturno de refuerzo'),
(7, 'Tarde B', 'Turno de tarde de refuerzo'),
(8, 'Fin de Semana Mañana', 'Turno matutino de fin de semana'),
(9, 'Fin de Semana Noche', 'Turno nocturno de fin de semana'),
(10, 'Refuerzo', 'Turno extraordinario por demanda de servicio');

INSERT INTO tipo_estudio (id_tipo_estudio, nombre, categoria, descripcion) VALUES
(1, 'Hemograma Completo', 'LABORATORIO', 'Recuento y morfología de células sanguíneas'),
(2, 'Glucosa en Ayunas', 'LABORATORIO', 'Glicemia basal tras 8 horas de ayuno'),
(3, 'Perfil Lipídico', 'LABORATORIO', 'Colesterol total, HDL, LDL y triglicéridos'),
(4, 'Examen General de Orina', 'LABORATORIO', 'Análisis físico, químico y microscópico de orina'),
(5, 'Creatinina Sérica', 'LABORATORIO', 'Función renal'),
(6, 'Radiografía de Tórax', 'IMAGENOLOGIA', 'Estudio radiográfico de campo pulmonar'),
(7, 'Ecografía Abdominal', 'IMAGENOLOGIA', 'Estudio ecográfico de abdomen'),
(8, 'Tomografía Axial', 'IMAGENOLOGIA', 'Estudio tomográfico computarizado'),
(9, 'Resonancia Magnética', 'IMAGENOLOGIA', 'Estudio de imagen por resonancia'),
(10, 'Electrocardiograma', 'IMAGENOLOGIA', 'Registro de la actividad eléctrica cardiaca');

INSERT INTO tipo_mantenimiento (id_tipo_mantenimiento, nombre, descripcion) VALUES
(1, 'Preventivo', 'Mantenimiento programado periódico'),
(2, 'Correctivo', 'Reparación por falla del equipo'),
(3, 'Calibración', 'Ajuste de precisión de medición'),
(4, 'Predictivo', 'Mantenimiento basado en monitoreo de condición'),
(5, 'Eléctrico', 'Revisión de componentes eléctricos'),
(6, 'Mecánico', 'Revisión de piezas mecánicas'),
(7, 'Lubricación', 'Lubricación de partes móviles'),
(8, 'Desinfección Técnica', 'Sanitización de superficies y circuitos'),
(9, 'Actualización de Software', 'Instalación de actualizaciones del firmware'),
(10, 'Inspección de Seguridad', 'Verificación de normas de seguridad eléctrica');

-- =====================================================================
-- 1. PERSONAS Y CONTACTO
-- =====================================================================

INSERT INTO persona (id_persona, dui, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, genero) VALUES
(1, '01010101-1', 'Juan', 'Carlos', 'Hernández', 'López', '1985-03-12', 'MASCULINO'),
(2, '02020202-2', 'María', 'Elena', 'García', 'Ramírez', '1990-07-25', 'FEMENINO'),
(3, '03030303-3', 'Pedro', 'Antonio', 'Martínez', 'Flores', '1978-11-02', 'MASCULINO'),
(4, '04040404-4', 'Ana', 'Lucía', 'López', 'Cruz', '1995-01-30', 'FEMENINO'),
(5, '05050505-5', 'Luis', 'Miguel', 'Ramírez', 'Gómez', '1965-05-18', 'MASCULINO'),
(6, '06060606-6', 'Rosa', 'Amanda', 'Cruz', 'Morales', '1982-09-14', 'FEMENINO'),
(7, '07070707-7', 'José', 'Enrique', 'Morales', 'Hernández', '1970-02-08', 'MASCULINO'),
(8, NULL, 'Sofía', 'Isabel', 'Flores', 'Méndez', '2015-06-21', 'FEMENINO'),
(9, '09090909-9', 'Carlos', 'Eduardo', 'Gómez', 'Alvarado', '1958-12-03', 'MASCULINO'),
(10, '10101010-0', 'Carmen', 'Rosa', 'Alvarado', 'Pérez', '1974-04-09', 'FEMENINO'),
(11, '11111111-1', 'Ricardo', 'Alberto', 'Sánchez', 'Portillo', '1975-08-19', 'MASCULINO'),
(12, '12121212-2', 'Laura', 'Beatriz', 'Martínez', 'Herrera', '1980-04-07', 'FEMENINO'),
(13, '13131313-3', 'Fernando', 'José', 'López', 'Interiano', '1968-10-16', 'MASCULINO'),
(14, '14141414-4', 'Gabriela', 'Alejandra', 'Torres', 'Fuentes', '1983-12-01', 'FEMENINO'),
(15, '15151515-5', 'Miguel', 'Ángel', 'Renderos', 'Cárdenas', '1977-06-23', 'MASCULINO'),
(16, '16161616-6', 'Sandra', 'Elizabeth', 'Peña', 'Aguilar', '1986-02-27', 'FEMENINO'),
(17, '17171717-7', 'Óscar', 'Ernesto', 'Dubón', 'Rivera', '1972-09-05', 'MASCULINO'),
(18, '18181818-8', 'Julia', 'Marisol', 'Cáceres', 'Villalobos', '1979-03-11', 'FEMENINO'),
(19, '19191919-9', 'José', 'Rubén', 'Orellana', 'Machado', '1990-11-29', 'MASCULINO'),
(20, '20202020-0', 'Kenia', 'Yessenia', 'Núñez', 'Escobar', '1988-08-08', 'FEMENINO');

INSERT INTO telefono_persona (id_telefono, id_persona, telefono, es_principal) VALUES
(1, 1, '2234-1001', TRUE),
(2, 2, '2234-1002', TRUE),
(3, 3, '2235-1003', TRUE),
(4, 4, '2235-1004', TRUE),
(5, 5, '2236-1005', TRUE),
(6, 6, '2236-1006', TRUE),
(7, 7, '2237-1007', TRUE),
(8, 8, '2237-1008', TRUE),
(9, 9, '2238-1009', TRUE),
(10, 10, '2238-1010', TRUE);

INSERT INTO direccion (id_direccion, calle, colonia, municipio, departamento_geo, codigo_postal, pais) VALUES
(1, 'Calle La Reforma #12', 'Col. Centro', 'San Salvador', 'San Salvador', '1101', 'El Salvador'),
(2, 'Av. Roosevelt #45-3', 'Col. Escalón', 'San Salvador', 'San Salvador', '1107', 'El Salvador'),
(3, 'Calle Los Andes #8', 'Col. Miralvalle', 'San Salvador', 'San Salvador', '1121', 'El Salvador'),
(4, 'Pje. Las Magnolias #21', 'Res. Las Flores', 'Soyapango', 'San Salvador', '1109', 'El Salvador'),
(5, 'Av. Morazán #310', 'Col. La Mascota', 'San Salvador', 'San Salvador', '1112', 'El Salvador'),
(6, 'Calle El Progreso #76', 'Barrio El Calvario', 'Ilopango', 'San Salvador', '1115', 'El Salvador'),
(7, 'Km 8 1/2 Carretera a Comalapa', 'Lot. San Andrés', 'San Marcos', 'San Salvador', '1127', 'El Salvador'),
(8, 'Calle Poniente #5', 'Col. Merliot', 'Santa Tecla', 'La Libertad', '11201', 'El Salvador'),
(9, 'Av. Juan Manuel Durán #19', 'Col. San José', 'Santa Tecla', 'La Libertad', '11204', 'El Salvador'),
(10, 'Calle Conchita #88', 'Col. Las Delicias', 'Antiguo Cuscatlán', 'La Libertad', '11201', 'El Salvador');

INSERT INTO direccion_persona (id_persona, id_direccion, es_principal) VALUES
(1, 1, TRUE),
(2, 2, TRUE),
(3, 3, TRUE),
(4, 4, TRUE),
(5, 5, TRUE),
(6, 6, TRUE),
(7, 7, TRUE),
(8, 8, TRUE),
(9, 9, TRUE),
(10, 10, TRUE);

INSERT INTO contacto_emergencia (id_contacto_emergencia, primer_nombre, primer_apellido, telefono_emergencia) VALUES
(1, 'María', 'García', '2291-2001'),
(2, 'Eduardo', 'García', '2291-2002'),
(3, 'Rosa', 'Martínez', '2291-2003'),
(4, 'Miguel', 'Cruz', '2291-2004'),
(5, 'Dolores', 'Ramírez', '2291-2005'),
(6, 'Javier', 'Cruz', '2291-2006'),
(7, 'Alicia', 'Morales', '2291-2007'),
(8, 'Andrea', 'Méndez', '2291-2008'),
(9, 'Gloria', 'Gómez', '2291-2009'),
(10, 'Rafael', 'Pérez', '2291-2010');

INSERT INTO persona_contacto_emergencia (id_persona, id_contacto_emergencia, parentesco, es_principal) VALUES
(1, 1, 'Esposa', TRUE),
(2, 2, 'Hermano', TRUE),
(3, 3, 'Madre', TRUE),
(4, 4, 'Padre', TRUE),
(5, 5, 'Hija', TRUE),
(6, 6, 'Esposo', TRUE),
(7, 7, 'Hermana', TRUE),
(8, 8, 'Madre', TRUE),
(9, 9, 'Hija', TRUE),
(10, 10, 'Esposo', TRUE);

-- =====================================================================
-- 2. EMPLEADOS
-- =====================================================================

INSERT INTO empleado (id_empleado, id_cargo, id_especialidad, id_departamento, numero_licencia, fecha_ingreso, estado) VALUES
(11, 1, 2, 1, 'LIC-MED-1001', '2010-02-01', 'ACTIVO'),
(12, 2, 3, 1, 'LIC-MED-1002', '2012-08-15', 'ACTIVO'),
(13, 3, 4, 5, 'LIC-MED-1003', '2008-01-20', 'ACTIVO'),
(14, 5, 7, 6, 'LIC-MED-1004', '2015-03-09', 'ACTIVO'),
(15, 4, 1, 6, 'LIC-MED-1005', '2011-07-11', 'ACTIVO'),
(16, 4, 1, 6, 'LIC-MED-1006', '2016-10-03', 'ACTIVO'),
(17, 7, 5, 3, 'LIC-MED-1007', '2005-05-16', 'ACTIVO'),
(18, 6, 6, 4, 'LIC-MED-1008', '2014-09-22', 'ACTIVO'),
(19, 8, NULL, 8, NULL, '2018-04-02', 'ACTIVO'),
(20, 9, NULL, 1, NULL, '2009-11-30', 'ACTIVO');

UPDATE departamento SET id_jefe_departamento = 11 WHERE id_departamento = 1;
UPDATE departamento SET id_jefe_departamento = 17 WHERE id_departamento = 2;
UPDATE departamento SET id_jefe_departamento = 17 WHERE id_departamento = 3;
UPDATE departamento SET id_jefe_departamento = 18 WHERE id_departamento = 4;
UPDATE departamento SET id_jefe_departamento = 13 WHERE id_departamento = 5;
UPDATE departamento SET id_jefe_departamento = 15 WHERE id_departamento = 6;
UPDATE departamento SET id_jefe_departamento = 19 WHERE id_departamento = 7;
UPDATE departamento SET id_jefe_departamento = 20 WHERE id_departamento = 8;
UPDATE departamento SET id_jefe_departamento = 20 WHERE id_departamento = 9;
UPDATE departamento SET id_jefe_departamento = 14 WHERE id_departamento = 10;

INSERT INTO correo_empleado (id_correo, id_empleado, correo, es_principal) VALUES
(1, 11, 'ricardo.sanchez@hospitalsanlucas.gob.sv', TRUE),
(2, 12, 'laura.martinez@hospitalsanlucas.gob.sv', TRUE),
(3, 13, 'fernando.lopez@hospitalsanlucas.gob.sv', TRUE),
(4, 14, 'gabriela.torres@hospitalsanlucas.gob.sv', TRUE),
(5, 15, 'miguel.renderos@hospitalsanlucas.gob.sv', TRUE),
(6, 16, 'sandra.pena@hospitalsanlucas.gob.sv', TRUE),
(7, 17, 'oscar.dubon@hospitalsanlucas.gob.sv', TRUE),
(8, 18, 'julia.caceres@hospitalsanlucas.gob.sv', TRUE),
(9, 19, 'jose.orellana@hospitalsanlucas.gob.sv', TRUE),
(10, 20, 'kenia.nunez@hospitalsanlucas.gob.sv', TRUE);

-- =====================================================================
-- 3. PACIENTES Y EXPEDIENTES
-- =====================================================================

INSERT INTO paciente (id_paciente, tipo_sangre, estatura, peso) VALUES
(1, 'O+', 1.75, 80.50),
(2, 'A+', 1.62, 58.00),
(3, 'B+', 1.70, 74.00),
(4, 'O-', 1.58, 68.00),
(5, 'A-', 1.68, 70.20),
(6, 'AB+', 1.55, 62.40),
(7, 'O+', 1.72, 78.00),
(8, 'B-', 1.15, 22.00),
(9, 'A+', 1.65, 66.30),
(10, 'O+', 1.60, 60.10);

INSERT INTO expediente (id_expediente, id_paciente, numero_expediente, fecha_apertura) VALUES
(1, 1, 'EXP-2010-0001', '2010-03-01'),
(2, 2, 'EXP-2012-0011', '2012-09-10'),
(3, 3, 'EXP-2009-0027', '2009-01-15'),
(4, 4, 'EXP-2016-0043', '2016-02-20'),
(5, 5, 'EXP-2003-0065', '2003-06-30'),
(6, 6, 'EXP-2018-0090', '2018-07-12'),
(7, 7, 'EXP-2015-0112', '2015-05-05'),
(8, 8, 'EXP-2021-0204', '2021-06-25'),
(9, 9, 'EXP-2001-0233', '2001-10-08'),
(10, 10, 'EXP-2013-0287', '2013-11-19');

-- =====================================================================
-- 4. CAMAS E INGRESOS
-- =====================================================================

INSERT INTO cama (id_cama, id_tipo_cama, id_departamento, numero_cama, habitacion, estado) VALUES
(1, 3, 3, '01', '301', 'DISPONIBLE'),
(2, 3, 3, '02', '301', 'DISPONIBLE'),
(3, 3, 3, '03', '302', 'DISPONIBLE'),
(4, 3, 3, '04', '302', 'DISPONIBLE'),
(5, 2, 3, '01', '303', 'DISPONIBLE'),
(6, 2, 3, '02', '303', 'DISPONIBLE'),
(7, 2, 3, '01', '304', 'DISPONIBLE'),
(8, 10, 4, '01', '401', 'DISPONIBLE'),
(9, 10, 4, '02', '401', 'DISPONIBLE'),
(10, 9, 3, '01', '305', 'DISPONIBLE');

INSERT INTO ingreso_hospitalario (id_ingreso_hospitalario, id_paciente, id_medico_ingreso, id_cama, tipo_ingreso, fecha_hora_ingreso, motivo_ingreso, diagnostico_ingreso, estado) VALUES
(1, 1, 17, 1, 'URGENCIAS', '2026-10-25 07:30', 'Dolor abdominal intenso en fosa iliaca derecha con fiebre', 'Apendicitis aguda', 'ACTIVO'),
(2, 2, 17, 2, 'PROGRAMADO', '2026-10-24 08:00', 'Programada para colecistectomía electiva', 'Colecistitis crónica litiásica', 'ACTIVO'),
(3, 3, 12, 3, 'URGENCIAS', '2026-10-26 09:15', 'Caída de altura con deformidad y dolor en pierna derecha', 'Fractura cerrada de tibia y peroné', 'ACTIVO'),
(4, 4, 14, 4, 'REFERENCIA', '2026-10-27 06:45', 'Referida de unidad de salud por embarazo de 38 semanas con presentación pélvica', 'Embarazo a término con presentación pélvica', 'ACTIVO'),
(5, 5, 17, 5, 'PROGRAMADO', '2026-10-23 10:00', 'Programado para artroscopia de rodilla derecha', 'Lesión de menisco interno de rodilla derecha', 'ACTIVO'),
(6, 6, 17, 6, 'URGENCIAS', '2026-10-28 20:10', 'Dolor en ingle derecho al levantar pesos', 'Hernia inguinal derecha incarcerada', 'ACTIVO'),
(7, 7, 13, 7, 'URGENCIAS', '2026-10-29 11:20', 'Opresión precordial con sudoración', 'Síndrome coronario agudo sin elevación de ST', 'ACTIVO'),
(8, 8, 18, 8, 'URGENCIAS', '2026-10-30 03:40', 'Dolor en ingle derecha en paciente pediátrica', 'Hernia inguinal derecha pediátrica', 'ACTIVO'),
(9, 9, 12, 9, 'URGENCIAS', '2026-10-29 18:05', 'Caída en su casa con imposibilidad para caminar', 'Fractura de cadera derecha', 'ACTIVO'),
(10, 10, 14, 10, 'PROGRAMADO', '2026-10-22 09:30', 'Programada para histerectomía por miomatosis uterina', 'Mioma uterino sintomático', 'ACTIVO');

-- =====================================================================
-- 5. CONSULTAS
-- =====================================================================

INSERT INTO consulta (id_consulta, id_paciente, id_empleado, id_departamento, tipo_atencion, fecha_hora_consulta, motivo_consulta, sintomas, diagnostico, tratamiento) VALUES
(1, 1, 17, 2, 'URGENCIAS', '2026-10-25 07:00', 'Dolor abdominal de 12 horas de evolución', 'Dolor en fosa iliaca derecha, fiebre 38.5°C, náuseas', 'Apendicitis aguda', 'Hidratación, antibióticos y traslado a pabellón'),
(2, 2, 17, 2, 'URGENCIAS', '2026-10-20 15:30', 'Dolor en hipocondrio derecho tras comidas grasas', 'Cólicos biliares repetitivos', 'Colecistitis crónica litiásica', 'Programación quirúrgica electiva'),
(3, 3, 12, 2, 'URGENCIAS', '2026-10-26 09:00', 'Caída de 3 metros de altura en obra', 'Deformidad en pierna derecha, dolor intenso, edema', 'Fractura cerrada de tibia y peroné', 'Inmovilización temporal y preparación para osteosíntesis'),
(4, 4, 14, 10, 'URGENCIAS', '2026-10-27 06:30', 'Control prenatal de embarazo a término', 'Sin trabajo de parto, presentación pélvica confirmada', 'Embarazo a término con presentación pélvica', 'Programación de cesárea'),
(5, 5, 12, 1, 'EXTERNA', '2026-10-15 09:10', 'Dolor y chasquido en rodilla derecha al subir escaleras', 'Bloqueos articulares ocasionales', 'Lesión de menisco interno', 'Artroscopia programada'),
(6, 6, 17, 3, 'EXTERNA', '2026-10-28 19:30', 'Masa en ingle derecha que aumenta al toser', 'Dolor al levantar objetos', 'Hernia inguinal derecha', 'Hernioplastia programada'),
(7, 7, 13, 5, 'EXTERNA', '2026-10-28 10:00', 'Dolor precordial de reposo de 20 minutos', 'Sudoración fría, disnea leve', 'Angina inestable', 'Ingreso a Hospitalización Adultos y estudio cardiológico'),
(8, 8, 18, 4, 'URGENCIAS', '2026-10-30 03:20', 'Dolor en ingle derecha en niña de 11 años', 'Masa reductible en ingle derecha, llanto', 'Hernia inguinal derecha pediátrica', 'Valoración quirúrgica pediátrica'),
(9, 9, 12, 2, 'URGENCIAS', '2026-10-29 17:40', 'Caída en el patio de su casa', 'Dolor en cadera derecha, impotencia funcional', 'Fractura de cadera derecha', 'Estabilización y programación quirúrgica'),
(10, 10, 14, 10, 'EXTERNA', '2026-10-12 08:45', 'Sangrado uterino anormal y dolor pélvico', 'Menometrorragia de 3 meses, abdomen con tumoración', 'Miomatosis uterina sintomática', 'Histerectomía programada');

-- =====================================================================
-- 6. QUIRÓFANOS, CIRUGÍAS Y EQUIPO QUIRÚRGICO
-- =====================================================================

INSERT INTO quirofano (id_quirofano, id_tipo_quirofano, nombre_quirofano, piso, estado) VALUES
(1, 1, 'Quirófano Central 1', 2, 'DISPONIBLE'),
(2, 4, 'Quirófano de Trauma 1', 2, 'DISPONIBLE'),
(3, 1, 'Quirófano Central 2', 2, 'DISPONIBLE'),
(4, 3, 'Quirófano Ortopédico 1', 2, 'DISPONIBLE'),
(5, 10, 'Quirófano de Cesáreas 1', 1, 'DISPONIBLE'),
(6, 6, 'Quirófano Pediátrico 1', 2, 'DISPONIBLE'),
(7, 1, 'Quirófano Central 3', 2, 'DISPONIBLE'),
(8, 8, 'Quirófano de Urgencias 1', 1, 'DISPONIBLE'),
(9, 1, 'Quirófano Central 4', 2, 'MANTENIMIENTO'),
(10, 5, 'Quirófano Ginecológico 1', 2, 'FUERA_DE_SERVICIO');

INSERT INTO cirugia (id_cirugia, id_ingreso_hospitalario, id_quirofano, id_cirujano_principal, id_anestesiologo, id_tipo_cirugia, fecha_hora_programada, fecha_hora_inicio, fecha_hora_fin, diagnostico_preoperatorio, diagnostico_posoperatorio, observaciones, estado_cirugia) VALUES
(1, 1, 1, 11, 15, 1, '2026-10-26 08:00', '2026-10-26 08:10', '2026-10-26 09:30', 'Apendicitis aguda', 'Apendicectomía sin complicaciones', 'Paciente toleró bien el procedimiento', 'FINALIZADA'),
(2, 3, 2, 12, 16, 4, '2026-10-27 08:00', '2026-10-27 08:15', '2026-10-27 10:15', 'Fractura cerrada de tibia y peroné', 'Osteosíntesis con placa y tornillos', 'Hemorragia estimada 350 ml', 'FINALIZADA'),
(3, 2, 3, 11, 15, 2, '2026-11-03 08:00', NULL, NULL, 'Colecistitis crónica litiásica', NULL, 'Programada; suspensión de anticoagulantes previa', 'PROGRAMADA'),
(4, 4, 5, 14, 15, 6, '2026-11-04 08:00', NULL, NULL, 'Embarazo a término con presentación pélvica', NULL, 'Cesárea programada; banco de sangre notificado', 'PROGRAMADA'),
(5, 5, 4, 12, 16, 5, '2026-11-05 10:00', NULL, NULL, 'Lesión de menisco interno de rodilla derecha', NULL, 'Artroscopia; requiere manguito de isquemia', 'PROGRAMADA'),
(6, 6, 1, 11, 16, 3, '2026-11-06 08:00', NULL, NULL, 'Hernia inguinal derecha incarcerada', NULL, 'Se reparará con malla protésica', 'PROGRAMADA'),
(7, 7, 7, 11, 15, 7, '2026-11-10 08:00', NULL, NULL, 'Descartar lesión abdominal asociada a cuadro coronario', NULL, 'Laparoscopia diagnóstica post-estabilización cardiológica', 'PROGRAMADA'),
(8, 8, 6, 11, 16, 3, '2026-11-12 09:00', NULL, NULL, 'Hernia inguinal derecha pediátrica', NULL, 'Cirugía pediátrica; anestesia pediátrica solicitada', 'PROGRAMADA'),
(9, 9, 8, 12, 15, 8, '2026-11-13 08:00', NULL, NULL, 'Fractura de cadera derecha', NULL, 'Paciente adulto mayor; valoración de riesgo anestésico', 'PROGRAMADA'),
(10, 10, 1, 14, 16, 9, '2026-11-17 08:00', NULL, NULL, 'Miomatosis uterina sintomática', NULL, 'Histerectomía; se reserva unidad de hemoderivados', 'PROGRAMADA');

INSERT INTO cirugia_equipo (id_cirugia, id_empleado, rol) VALUES
(1, 12, 'CIRUJANO_ASISTENTE'),
(1, 20, 'ENFERMERA_INSTRUMENTISTA'),
(2, 11, 'CIRUJANO_ASISTENTE'),
(2, 20, 'ENFERMERA_CIRCULANTE'),
(3, 14, 'CIRUJANO_ASISTENTE'),
(3, 20, 'ENFERMERA_INSTRUMENTISTA'),
(5, 13, 'CIRUJANO_ASISTENTE'),
(6, 20, 'ENFERMERA_CIRCULANTE'),
(8, 20, 'ENFERMERA_INSTRUMENTISTA'),
(10, 20, 'ENFERMERA_CIRCULANTE');

-- =====================================================================
-- 7. INVENTARIO
-- =====================================================================

INSERT INTO insumo (id_insumo, id_tipo_insumo, nombre_insumo, unidad_medida, stock, stock_minimo, precio) VALUES
(1, 6, 'Guantes de nitrilo estériles (talla M)', 'CAJA', 0, 50, 15.50),
(2, 2, 'Gasas estériles 10x10 cm', 'PAQUETE', 0, 30, 4.75),
(3, 1, 'Solución salina 0.9% 500 ml', 'BOLSA', 0, 40, 6.20),
(4, 3, 'Bisturí desechable hoja 15', 'UNIDAD', 0, 45, 3.80),
(5, 1, 'Lidocaína al 2% con epinefrina', 'FRASCO', 0, 15, 22.00),
(6, 6, 'Mascarilla quirúrgica de 3 capas', 'CAJA', 0, 100, 12.00),
(7, 4, 'Reactivos para hemograma (kit 500 pruebas)', 'KIT', 0, 25, 180.00),
(8, 5, 'Cilindro de oxígeno medicinal', 'CILINDRO', 0, 5, 35.00),
(9, 3, 'Sutura de seda 3-0 con aguja', 'UNIDAD', 0, 30, 8.40),
(10, 6, 'Bata quirúrgica desechable', 'UNIDAD', 0, 25, 9.90);

INSERT INTO movimiento_inventario (id_movimiento, id_empleado, id_cirugia, id_departamento, tipo_movimiento, fecha_hora) VALUES
(1, 20, NULL, NULL, 'ENTRADA', '2026-10-20 08:30'),
(2, 20, NULL, NULL, 'ENTRADA', '2026-10-20 08:45'),
(3, 20, NULL, NULL, 'ENTRADA', '2026-10-20 09:00'),
(4, 20, NULL, NULL, 'ENTRADA', '2026-10-21 08:15'),
(5, 20, NULL, NULL, 'ENTRADA', '2026-10-22 10:20'),
(6, 11, 1, NULL, 'SALIDA', '2026-10-26 07:45'),
(7, 12, 2, NULL, 'SALIDA', '2026-10-27 07:50'),
(8, 17, NULL, 3, 'SALIDA', '2026-10-28 09:00'),
(9, 18, NULL, 4, 'SALIDA', '2026-10-29 08:30'),
(10, 20, NULL, 6, 'SALIDA', '2026-10-29 14:00');

INSERT INTO detalle_movimiento_inventario (id_detalle, id_movimiento, id_insumo, cantidad, precio_unitario) VALUES
(1, 1, 1, 200, 15.50),
(2, 2, 2, 150, 4.75),
(3, 3, 3, 100, 6.20),
(4, 4, 4, 50, 3.80),
(5, 5, 5, 40, 22.00),
(6, 6, 1, 30, 15.50),
(7, 7, 4, 10, 3.80),
(8, 8, 3, 12, 6.20),
(9, 9, 2, 10, 4.75),
(10, 10, 1, 25, 15.50);

-- =====================================================================
-- 8. TURNOS
-- =====================================================================

INSERT INTO turno (id_turno, id_empleado, id_tipo_turno, id_departamento, fecha_hora_inicio, fecha_hora_fin, estado) VALUES
(1, 11, 1, 1, '2026-10-26 07:00', '2026-10-26 15:00', 'COMPLETADO'),
(2, 12, 2, 1, '2026-10-26 15:00', '2026-10-26 23:00', 'COMPLETADO'),
(3, 15, 3, 6, '2026-10-26 23:00', '2026-10-27 07:00', 'COMPLETADO'),
(4, 17, 1, 3, '2026-10-27 07:00', '2026-10-27 15:00', 'COMPLETADO'),
(5, 18, 4, 4, '2026-10-27 07:00', '2026-10-27 15:00', 'COMPLETADO'),
(6, 13, 2, 5, '2026-10-27 15:00', '2026-10-27 23:00', 'COMPLETADO'),
(7, 16, 6, 6, '2026-10-27 23:00', '2026-10-28 07:00', 'COMPLETADO'),
(8, 19, 5, 8, '2026-11-02 07:00', '2026-11-03 07:00', 'PROGRAMADO'),
(9, 20, 1, 1, '2026-11-02 07:00', '2026-11-02 15:00', 'PROGRAMADO'),
(10, 14, 2, 10, '2026-11-03 15:00', '2026-11-03 23:00', 'PROGRAMADO');

-- =====================================================================
-- 9. INTERCONSULTAS
-- =====================================================================

INSERT INTO interconsulta (id_interconsulta, id_paciente, id_medico_solicitante, id_medico_especialista, id_especialidad_solicitada, prioridad, motivo_solicitud, diagnostico_respuesta, fecha_hora_solicitud, fecha_hora_respuesta, estado) VALUES
(1, 1, 17, 13, 4, 'URGENTE', 'Evaluar riesgo cardiovascular preoperatorio en apendicectomía urgente', 'Riesgo quirúrgico bajo-bajo; no se requiere revascularización previa', '2026-10-25 08:00', '2026-10-25 12:30', 'RESPONDIDA'),
(2, 3, 12, 13, 4, 'NORMAL', 'Evaluar función cardiaca antes de osteosíntesis en paciente hipertenso', NULL, '2026-10-26 09:30', NULL, 'SOLICITADA'),
(3, 2, 17, 11, 2, 'NORMAL', 'Confirmar indicación quirúrgica de colecistectomía electiva', 'Indicación quirúrgica confirmada; se mantiene cirugía programada', '2026-10-20 16:00', '2026-10-21 09:00', 'RESPONDIDA'),
(4, 4, 18, 14, 7, 'URGENTE', 'Valoración ginecoobstétrica por presentación pélvica a término', NULL, '2026-10-27 06:50', NULL, 'EN_PROCESO'),
(5, 5, 17, 12, 3, 'BAJA', 'Segunda opinión sobre manejo conservador de lesión de menisco', NULL, '2026-10-15 09:40', NULL, 'SOLICITADA'),
(6, 6, 17, 11, 2, 'URGENTE', 'Confirmar incarceración de hernia inguinal', 'Hernia incarcerada sin signos de estrangulación; cirugía programada', '2026-10-28 20:30', '2026-10-28 23:00', 'RESPONDIDA'),
(7, 7, 13, 17, 5, 'URGENTE', 'Valoración de medicina interna en síndrome coronario con comorbilidad diabética', 'Se ajusta esquema de insulina y antiagregación; apto para procedimiento', '2026-10-29 11:40', '2026-10-29 15:10', 'RESPONDIDA'),
(8, 8, 18, 11, 2, 'NORMAL', 'Valoración quirúrgica de hernia inguinal pediátrica', NULL, '2026-10-30 04:00', NULL, 'SOLICITADA'),
(9, 9, 17, 12, 3, 'NORMAL', 'Valoración traumatológica de fractura de cadera en adulto mayor', NULL, '2026-10-29 18:20', NULL, 'CANCELADA'),
(10, 10, 18, 14, 7, 'NORMAL', 'Confirmar indicación de histerectomía en miomatosis sintomática', NULL, '2026-10-12 09:00', NULL, 'SOLICITADA');

-- =====================================================================
-- 10. EQUIPOS MÉDICOS Y MANTENIMIENTO
-- =====================================================================

INSERT INTO equipo_medico (id_equipo, id_departamento, nombre_equipo, numero_serie, criticidad, fecha_adquisicion, estado) VALUES
(1, 8, 'Resonador magnético 1.5T', 'RM-1.5T-2018-001', 'CRITICA', '2018-05-10', 'EN_MANTENIMIENTO'),
(2, 8, 'Radiógrafo digital de tórax', 'RX-DR-2019-014', 'ALTA', '2019-02-21', 'OPERATIVO'),
(3, 8, 'Ecógrafo multipropósito', 'ECO-MP-2020-007', 'MEDIA', '2020-08-17', 'OPERATIVO'),
(4, 8, 'Tomógrafo multicorte 64 cortes', 'TAC-64-2017-002', 'CRITICA', '2017-11-03', 'OPERATIVO'),
(5, 3, 'Monitor de signos vitales', 'MSV-2021-120', 'ALTA', '2021-03-14', 'OPERATIVO'),
(6, 6, 'Máquina de anestesia Dräger', 'AN-DR-2016-003', 'CRITICA', '2016-06-27', 'EN_MANTENIMIENTO'),
(7, 7, 'Analizador de hematología', 'HEM-AN-2019-021', 'ALTA', '2019-09-09', 'OPERATIVO'),
(8, 2, 'Desfibrilador biphasic', 'DEF-BI-2020-005', 'CRITICA', '2020-01-15', 'OPERATIVO'),
(9, 6, 'Lámpara quirúrgica de LED', 'LQ-LED-2021-009', 'ALTA', '2021-07-30', 'OPERATIVO'),
(10, 7, 'Autoclave de vapor 100 litros', 'AUT-CL-2015-004', 'MEDIA', '2015-04-20', 'BAJA');

INSERT INTO mantenimiento_equipo (id_mantenimiento, id_equipo, id_tipo_mantenimiento, fecha_hora_programada, fecha_hora_realizada, responsable, costo, descripcion, estado) VALUES
(1, 1, 1, '2026-11-05 08:00', NULL, 'Ing. Roberto Mejía (proveedor Siemens)', NULL, 'Mantenimiento preventivo anual de resonador', 'PROGRAMADO'),
(2, 6, 2, '2026-10-27 13:00', '2026-10-27 17:30', 'Téc. interno Mario Salazar', 850.00, 'Corrección de fuga en circuito de gas de máquina de anestesia', 'REALIZADO'),
(3, 2, 3, '2026-10-15 09:00', '2026-10-15 12:00', 'Téc. interno Mario Salazar', 320.50, 'Calibración dosimétrica del radiógrafo', 'REALIZADO'),
(4, 4, 1, '2026-12-01 08:00', NULL, 'Proveedor GE Healthcare', NULL, 'Preventivo de fin de año del tomógrafo', 'PROGRAMADO'),
(5, 10, 2, '2026-10-10 07:30', '2026-10-10 16:00', 'Téc. interno Mario Salazar', 1250.00, 'Reparación de resistencia de calefacción del autoclave', 'REALIZADO'),
(6, 5, 4, '2026-11-20 08:00', NULL, 'Ing. Roberto Mejía', NULL, 'Predictivo por alarmas intermitentes de monitor', 'PROGRAMADO'),
(7, 8, 10, '2026-10-29 08:00', '2026-10-29 10:30', 'Téc. interno Mario Salazar', 150.00, 'Inspección de seguridad eléctrica de desfibrilador', 'REALIZADO'),
(8, 9, 6, '2026-11-11 14:00', NULL, 'Téc. interno Mario Salazar', NULL, 'Revisión mecánica de brazo de lámpara quirúrgica', 'PROGRAMADO'),
(9, 7, 3, '2026-11-08 08:00', NULL, 'Proveedor Sysmex', NULL, 'Calibración de analizador de hematología', 'EN_PROCESO'),
(10, 3, 5, '2026-10-22 09:00', '2026-10-22 11:00', 'Téc. interno Mario Salazar', 95.00, 'Revisión eléctrica de ecógrafo', 'REALIZADO');

-- =====================================================================
-- 11. ESTUDIOS DIAGNÓSTICOS Y DETALLE DE RESULTADOS
-- =====================================================================

INSERT INTO estudio_diagnostico (id_estudio, id_paciente, id_medico_solicitante, id_tipo_estudio, id_equipo, id_tecnico, fecha_hora_solicitud, fecha_hora_programada, fecha_hora_realizacion, fecha_hora_resultado, resultado, estado) VALUES
(1, 1, 17, 1, NULL, NULL, '2026-10-25 07:45', '2026-10-25 08:30', '2026-10-25 08:45', '2026-10-25 09:30', 'Leucocitosis de 14,200/uL con neutrofilia; compatible con proceso infeccioso agudo', 'CON_RESULTADO'),
(2, 2, 17, 2, NULL, NULL, '2026-10-20 16:10', '2026-10-21 07:00', '2026-10-21 07:15', '2026-10-21 08:00', 'Glucosa en ayunas de 92 mg/dL: dentro de rango normal', 'CON_RESULTADO'),
(3, 3, 12, 6, 2, 19, '2026-10-26 09:30', '2026-10-26 10:00', '2026-10-26 10:20', '2026-10-26 10:50', 'Fractura diafisiaria de tibia y peroné derechos, sin desplazamiento articular', 'CON_RESULTADO'),
(4, 4, 14, 7, 3, 19, '2026-10-27 06:55', '2026-10-27 07:30', '2026-10-27 07:50', '2026-10-27 08:15', 'Feto único vivo cefálico... presentación pélvica confirmada; líquido amniótico normal', 'CON_RESULTADO'),
(5, 5, 12, 8, 4, 19, '2026-10-15 09:30', '2026-10-18 08:00', '2026-10-18 08:40', '2026-10-18 09:10', 'Desgarro del menisco interno de rodilla derecha, grado III', 'CON_RESULTADO'),
(6, 7, 13, 10, 8, 19, '2026-10-29 11:35', '2026-10-29 12:00', '2026-10-29 12:10', '2026-10-29 12:20', 'Cambios isquémicos anterosptales; sin infradesnivel del ST', 'CON_RESULTADO'),
(7, 9, 12, 6, 2, 19, '2026-10-29 18:25', '2026-10-30 07:30', NULL, NULL, NULL, 'PROGRAMADO'),
(8, 1, 17, 5, NULL, NULL, '2026-10-25 08:00', '2026-10-26 07:00', NULL, NULL, NULL, 'SOLICITADO'),
(9, 6, 17, 3, NULL, NULL, '2026-10-28 20:40', '2026-10-29 07:00', NULL, NULL, NULL, 'SOLICITADO'),
(10, 10, 14, 5, NULL, NULL, '2026-10-12 09:10', '2026-10-13 07:30', NULL, NULL, NULL, 'CANCELADO');

INSERT INTO detalle_resultado_estudio (id_detalle, id_estudio, parametro, valor, unidad, rango_referencia) VALUES
(1, 1, 'Hemoglobina', '13.8', 'g/dL', '13.0 - 17.0'),
(2, 1, 'Leucocitos', '14200', 'uL', '4,500 - 11,000'),
(3, 2, 'Glucosa en ayunas', '92', 'mg/dL', '70 - 99'),
(4, 2, 'Hemoglobina glicosilada', '5.4', '%', '< 5.7'),
(5, 3, 'Línea de fractura', 'Presente en tibia y peroné derechos', NULL, 'Ausente'),
(6, 3, 'Alineación tibial', 'Aceptable, sin desplazamiento articular', NULL, 'Anatómica'),
(7, 4, 'Presentación fetal', 'Pélvica', NULL, 'Cefálica'),
(8, 5, 'Menisco interno', 'Desgarro grado III', NULL, 'Íntegro'),
(9, 5, 'Derrame articular', 'Mínimo', NULL, 'Ausente'),
(10, 6, 'Ritmo sinusal', 'Presente con cambios isquémicos anteroseptales', NULL, 'Ritmo sinusal normal');