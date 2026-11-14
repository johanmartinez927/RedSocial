-- Consultas DML pgAdmin4

-- Consulta 4: Próximos eventos (Presenciales o Híbridos) con lugar asignado

SELECT ev.nombre AS Evento, 
       ev.fecha_inicio, 
       ev.modalidad,
       g.nombre AS Grupo_Organizador,
       ev.lugar
FROM evento ev
JOIN grupo g ON ev.id_grupo = g.id_grupo
WHERE ev.modalidad IN ('Presencial', 'Híbrido')
  AND ev.lugar IS NOT NULL
  AND ev.fecha_inicio >= CURRENT_TIMESTAMP
ORDER BY ev.fecha_inicio ASC;

-- Consulta 5: Top 3 estudiantes más populares (con más seguidores y reacciones)
SELECT e.nombre, e.apellido, 
       (SELECT COUNT(*) FROM seguir s WHERE s.id_seguido = e.id_estudiante) AS Num_Seguidores,
       (SELECT COUNT(*) FROM reaccion r JOIN publicacion p ON r.id_publicacion = p.id_publicacion WHERE p.id_estudiante = e.id_estudiante) AS Reacciones_Recibidas
FROM estudiante e
ORDER BY Num_Seguidores DESC, Reacciones_Recibidas DESC
LIMIT 3;

-- Consulta 6: Listar los grupos activos con más de 3 miembros

SELECT g.nombre AS Nombre_Grupo, 
       g.tipo, 
       COUNT(mg.id_estudiante) AS Total_Miembros
FROM grupo g
JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
WHERE g.estado = 'Activo'
GROUP BY g.id_grupo, g.nombre, g.tipo
HAVING COUNT(mg.id_estudiante) > 3;

-- Vistas

--Vista 1: Perfiles de Mentoría Consolidados (Estudiantes con habilidades Avanzadas o Expertas)

CREATE VIEW vista_perfiles_mentores AS
SELECT e.id_estudiante, 
       e.nombre || ' ' || e.apellido AS Nombre_Completo,
       p.programa, 
       p.semestre,
       h.nombre AS Habilidad,
       eh.nivel AS Nivel_Habilidad
FROM estudiante e
JOIN perfil p ON e.id_estudiante = p.id_estudiante
JOIN estudiante_habilidad eh ON e.id_estudiante = eh.id_estudiante
JOIN habilidad h ON eh.id_habilidad = h.id_habilidad
WHERE eh.nivel IN ('Avanzado', 'Experto');

-- Vista 2: Resumen de Actividad por Grupo (Miembros y Eventos)

CREATE VIEW vista_resumen_grupos AS
SELECT g.id_grupo,
       g.nombre AS Nombre_Grupo,
       g.tipo,
       COUNT(DISTINCT mg.id_estudiante) AS Total_Miembros,
       COUNT(DISTINCT ev.id_evento) AS Total_Eventos
FROM grupo g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
LEFT JOIN evento ev ON g.id_grupo = ev.id_grupo
GROUP BY g.id_grupo, g.nombre, g.tipo;
