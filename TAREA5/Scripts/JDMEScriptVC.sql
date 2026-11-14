Ingresar datos:
-- 1. Insertar nuevos estudiantes
INSERT INTO estudiante (id_estudiante, nombre, apellido, correo, password, fecha_registro, ultima_actividad, estado) VALUES
(6, 'Andrés', 'Pérez', 'andres.perez@pascualbravo.edu.co', '2b10e8T...hash6', '2026-05-01 09:00:00', '2026-11-05 11:00:00', 'Activo'),
(7, 'Diana', 'Calle', 'diana.calle@pascualbravo.edu.co', '2b10e8T...hash7', '2026-05-10 14:30:00', '2026-11-05 12:15:00', 'Activo');
INSERT INTO estudiante (id_estudiante, nombre, apellido, correo, password, fecha_registro, ultima_actividad, estado) VALUES
(9, 'Diego', 'Torres', 'diego.torres@pascualbravo.edu.co', '2b10hash6', '2026-05-01 09:00:00', '2026-11-01 10:00:00', 'Activo'),
(10, 'Camila', 'Vargas', 'camila.vargas@pascualbravo.edu.co', '2b10hash7', '2026-05-10 11:30:00', '2026-11-02 14:15:00', 'Activo'),
(11, 'Santiago', 'Morales', 'santiago.morales@pascualbravo.edu.co', '$2b$10$hash8', '2026-05-15 15:00:00', '2026-11-03 16:45:00', 'Activo');

-- 2. Crear sus perfiles académicos
INSERT INTO perfil (id_estudiante, area_estudio, biografia, programa, semestre, ciudad, foto_perfil, datos_extra) VALUES
(6, 'Redes', 'Entusiasta de la infraestructura y telecomunicaciones.', 'Ingeniería de Sistemas', 5, 'Medellín', 'andres.jpg', '{}'),
(7, 'Diseño Digital', 'Apasionada por el diseño UX/UI y animación.', 'Diseño Gráfico', 3, 'Envigado', 'diana.jpg', '{}');
-- 3. Crear sus publicaciones 
INSERT INTO publicacion (id_publicacion, id_estudiante, contenido, tipo, datos_extra) VALUES
(4, 6, '¿Alguien tiene las fechas confirmadas de las parciales del bloque 2?', 'Consulta', '{}'),
(5, 7, 'Les comparto esta paleta de colores para proyectos web.', 'Recurso', '{}');

--VISTA 1:
CREATE OR REPLACE VIEW vw_perfil_integral_estudiante AS
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS nombre_completo,
    e.correo,
    e.estado AS estado_cuenta,
    COALESCE(p.programa, 'Sin perfil') AS programa_academico,
    p.semestre,
    p.ciudad,
    (SELECT COUNT(*) FROM estudiante_habilidad eh WHERE eh.id_estudiante = e.id_estudiante) AS cantidad_habilidades,
    (SELECT COUNT(*) FROM estudiante_interes ei WHERE ei.id_estudiante = e.id_estudiante) AS cantidad_intereses,
    (SELECT COUNT(*) FROM miembro_grupo mg WHERE mg.id_estudiante = e.id_estudiante) AS grupos_inscritos
FROM estudiante e
LEFT JOIN perfil p 
    ON e.id_estudiante = p.id_estudiante;

-- Consulta de prueba para la Vista 1:
SELECT * FROM vw_perfil_integral_estudiante ORDER BY cantidad_habilidades DESC;

--VISTA 2: 
CREATE OR REPLACE VIEW vw_eventos_campus_geolocalizados AS
SELECT 
    ev.id_evento,
    ev.nombre AS nombre_evento,
    g.nombre AS grupo_organizador,
    g.tipo AS categoria_grupo,
    ev.modalidad,
    ev.lugar,
    ev.fecha_inicio,
    ev.fecha_fin,
    ST_Y(ev.ubicacion::geometry) AS latitud_gps,
    ST_X(ev.ubicacion::geometry) AS longitud_gps,
    COUNT(ae.id_estudiante) AS total_asistentes_registrados
FROM evento ev
INNER JOIN grupo g 
    ON ev.id_grupo = g.id_grupo
LEFT JOIN asistente_evento ae 
    ON ev.id_evento = ae.id_evento AND ae.estado = 'Confirmado'
GROUP BY 
    ev.id_evento, ev.nombre, g.nombre, g.tipo, ev.modalidad, 
    ev.lugar, ev.fecha_inicio, ev.fecha_fin, ev.ubicacion;

-- Consulta de prueba para la Vista 2:
SELECT * FROM vw_eventos_campus_geolocalizados;

-- CONSULTA 1: 
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS nombre_completo,
    p.programa AS programa_academico,
    e.correo AS correo_institucional,
    COUNT(h.id_habilidad) AS total_habilidades_destacadas,
    STRING_AGG(h.nombre || ' (' || eh.nivel || ')', ', ' ORDER BY h.nombre) AS detalle_habilidades
FROM estudiante e
INNER JOIN perfil p 
    ON e.id_estudiante = p.id_estudiante
INNER JOIN estudiante_habilidad eh 
    ON e.id_estudiante = eh.id_estudiante
INNER JOIN habilidad h 
    ON eh.id_habilidad = h.id_habilidad
WHERE e.estado = 'Activo'
  AND eh.nivel IN ('Intermedio', 'Avanzado')
GROUP BY e.id_estudiante, e.nombre, e.apellido, p.programa, e.correo
ORDER BY total_habilidades_destacadas DESC, nombre_completo ASC;

-- CONSULTA 2: 
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante_sin_publicaciones,
    e.correo AS correo_contacto,
    COALESCE(pf.programa, 'Perfil pendiente por completar') AS programa_academico,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - e.fecha_registro))::INT AS dias_registrado
FROM estudiante e
LEFT JOIN publicacion pub 
    ON e.id_estudiante = pub.id_estudiante
LEFT JOIN perfil pf 
    ON e.id_estudiante = pf.id_estudiante
WHERE e.estado = 'Activo'
  AND pub.id_estudiante IS NULL
ORDER BY dias_registrado DESC, e.id_estudiante ASC;

-- CONSULTA 3: 
SELECT 
    v.programa_academico,
    COUNT(v.id_estudiante) AS total_estudiantes_con_perfil,
    ROUND(AVG(v.cantidad_habilidades), 2) AS promedio_habilidades,
    ROUND(AVG(v.cantidad_intereses), 2) AS promedio_intereses,
    SUM(v.grupos_inscritos) AS total_membresias_grupos
FROM vw_perfil_integral_estudiante v
WHERE v.estado_cuenta = 'Activo'
  AND v.programa_academico <> 'Sin perfil'
GROUP BY v.programa_academico
ORDER BY total_estudiantes_con_perfil DESC, promedio_habilidades DESC;



