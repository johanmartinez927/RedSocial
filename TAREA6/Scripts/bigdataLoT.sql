-- ==============================================================================
-- TAREA 6 — ARQUITECTURA HÍBRIDA (RELACIONAL + NoSQL + IoT + GEOGRAFÍA)
-- BD: RED SOCIAL ESTUDIANTIL PASCUALINA
-- MOTOR: PostgreSQL 16+ con extensión PostGIS
-- ==============================================================================

-- Habilitar PostGIS para el manejo avanzado de datos espaciales (Big Data / IoT geográfico)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. LIMPIEZA DE TABLAS
DROP TABLE IF EXISTS checkin_ubicacion CASCADE;
DROP TABLE IF EXISTS log_actividad CASCADE;
DROP TABLE IF EXISTS lectura_sensor CASCADE;
DROP TABLE IF EXISTS sensor_iot CASCADE;
DROP TABLE IF EXISTS mentoria CASCADE;
DROP TABLE IF EXISTS seguir CASCADE;
DROP TABLE IF EXISTS comentario CASCADE;
DROP TABLE IF EXISTS reaccion CASCADE;
DROP TABLE IF EXISTS publicacion CASCADE;
DROP TABLE IF EXISTS asistente_evento CASCADE;
DROP TABLE IF EXISTS evento CASCADE;
DROP TABLE IF EXISTS miembro_grupo CASCADE;
DROP TABLE IF EXISTS grupo CASCADE;
DROP TABLE IF EXISTS estudiante_interes CASCADE;
DROP TABLE IF EXISTS interes CASCADE;
DROP TABLE IF EXISTS estudiante_habilidad CASCADE;
DROP TABLE IF EXISTS habilidad CASCADE;
DROP TABLE IF EXISTS perfil CASCADE;
DROP TABLE IF EXISTS estudiante CASCADE;

-- ==============================================================================
-- BLOQUE 1: MODELO RELACIONAL BASE Y TABLAS HÍBRIDAS
-- ==============================================================================

-- 2. ESTUDIANTE (Tabla relacional estricta)
CREATE TABLE estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ultima_actividad TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'Activo' NOT NULL
);

-- ==============================================================================
-- 3. PERFIL (Arquitectura Híbrida)
-- Justificación: El campo "datos_extra" (JSONB) permite almacenar atributos 
-- dinámicos del estudiante (redes sociales, preferencias, intereses personalizados) 
-- sin tener que realizar un ALTER TABLE cada vez que se requiera un nuevo campo.
-- ==============================================================================
CREATE TABLE perfil (
    id_perfil SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    area_estudio VARCHAR(80),
    biografia VARCHAR(500),
    programa VARCHAR(80) NOT NULL,
    semestre INT NOT NULL,
    ciudad VARCHAR(50),
    foto_perfil VARCHAR(255),
    datos_extra JSONB DEFAULT '{}'::JSONB,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 4. HABILIDAD
CREATE TABLE habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

-- 5. ESTUDIANTE_HABILIDAD
CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(20) NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_habilidad),
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON DELETE CASCADE
);

-- 6. INTERES
CREATE TABLE interes (
    id_interes SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

-- 7. ESTUDIANTE_INTERES
CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL,
    id_interes INT NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_interes),
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON DELETE CASCADE
);

-- 8. GRUPO
CREATE TABLE grupo (
    id_grupo SERIAL PRIMARY KEY,
    creador_id INT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(500),
    tipo VARCHAR(30) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado VARCHAR(20) DEFAULT 'Activo' NOT NULL,
    FOREIGN KEY (creador_id) REFERENCES estudiante(id_estudiante) ON DELETE RESTRICT
);

-- 9. MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (
    id_estudiante INT NOT NULL,
    id_grupo INT NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    rol VARCHAR(30) DEFAULT 'Miembro' NOT NULL,
    PRIMARY KEY (id_estudiante, id_grupo),
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
);

-- ==============================================================================
-- 10. EVENTO (Híbrida + PostGIS)
-- Integración de PostGIS mediante el tipo GEOGRAPHY(Point, 4326) para búsquedas
-- por radio de distancia. Adicionalmente usa JSONB para aforos y premios dinámicos.
-- ==============================================================================
CREATE TABLE evento (
    id_evento SERIAL PRIMARY KEY,
    id_grupo INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    lugar VARCHAR(150),
    modalidad VARCHAR(30) NOT NULL,
    organizador VARCHAR(100) NOT NULL,
    ubicacion GEOGRAPHY(Point, 4326), -- Dato Espacial PostGIS (Longitud, Latitud)
    datos_extra JSONB DEFAULT '{}'::JSONB,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
);

-- 11. ASISTENTE_EVENTO
CREATE TABLE asistente_evento (
    id_estudiante INT NOT NULL,
    id_evento INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Confirmado' NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_evento),
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE
);

-- 12. PUBLICACION (Con JSONB)
CREATE TABLE publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL,
    contenido VARCHAR(1000) NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    datos_extra JSONB DEFAULT '{}'::JSONB, -- Guarda multimedia, hashtags, sentimiento
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 13. REACCION
CREATE TABLE reaccion (
    id_estudiante INT NOT NULL,
    id_publicacion INT NOT NULL,
    tipo_reaccion VARCHAR(20) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_publicacion),
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE
);

-- 14. COMENTARIO
CREATE TABLE comentario (
    id_comentario SERIAL PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    comentario VARCHAR(500) NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 15. SEGUIR
CREATE TABLE seguir (
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_seguidor, id_seguido),
    FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT chk_no_auto_seguimiento CHECK (id_seguidor <> id_seguido)
);

-- 16. MENTORIA (Con PostGIS)
CREATE TABLE mentoria (
    id_mentor INT NOT NULL,
    id_aprendiz INT NOT NULL,
    tema VARCHAR(100) NOT NULL,
    estado VARCHAR(20) DEFAULT 'Solicitado' NOT NULL,
    fecha_mentoria TIMESTAMP NOT NULL,
    lugar VARCHAR(150),
    ubicacion GEOGRAPHY(Point, 4326),
    PRIMARY KEY (id_mentor, id_aprendiz),
    FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_aprendiz) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT chk_no_auto_mentoria CHECK (id_mentor <> id_aprendiz)
);

-- ==============================================================================
-- BLOQUE 2: EXTENSIONES IoT Y BIG DATA
-- ==============================================================================

-- 17. SENSOR_IOT (Con PostGIS para ubicación en campus)
CREATE TABLE sensor_iot (
    id_sensor SERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    tipo VARCHAR(30) NOT NULL,
    ubicacion GEOGRAPHY(Point, 4326),
    edificio VARCHAR(80),
    salon VARCHAR(20),
    estado VARCHAR(20) DEFAULT 'Activo' NOT NULL,
    fecha_instalacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 18. LECTURA_SENSOR (Particionada por fecha - Big Data)
-- Justificación: Almacena millones de telemetrías. El particionamiento RANGE 
-- (por mes) asegura que las consultas temporales sean rápidas y la purga de datos
-- históricos no bloquee la tabla principal. Metadatos en JSONB para métricas variables.
-- ==============================================================================
CREATE TABLE lectura_sensor (
    id_lectura BIGSERIAL,
    id_sensor INT NOT NULL,
    fecha_lectura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor NUMERIC(10,2) NOT NULL,
    unidad VARCHAR(10),
    metadatos JSONB DEFAULT '{}'::JSONB,
    PRIMARY KEY (id_lectura, fecha_lectura),
    FOREIGN KEY (id_sensor) REFERENCES sensor_iot(id_sensor) ON DELETE CASCADE
) PARTITION BY RANGE (fecha_lectura);

-- Particiones mensuales para LECTURA_SENSOR
CREATE TABLE lectura_sensor_2025_01 PARTITION OF lectura_sensor
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE lectura_sensor_2025_02 PARTITION OF lectura_sensor
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE lectura_sensor_2025_03 PARTITION OF lectura_sensor
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

-- 19. LOG_ACTIVIDAD
CREATE TABLE log_actividad (
    id_log BIGSERIAL PRIMARY KEY,
    id_estudiante INT,
    accion VARCHAR(50) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip INET,
    dispositivo JSONB DEFAULT '{}'::JSONB,
    contexto JSONB DEFAULT '{}'::JSONB,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE SET NULL
);

-- 20. CHECKIN_UBICACION (IoT + PostGIS + JSONB)
CREATE TABLE checkin_ubicacion (
    id_checkin BIGSERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_evento INT,
    ubicacion GEOGRAPHY(Point, 4326),
    fecha_checkin TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    beacon_id VARCHAR(50),
    confianza NUMERIC(5,2),
    metadatos JSONB DEFAULT '{}'::JSONB,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE SET NULL
);

-- ==============================================================================
-- BLOQUE 3: ÍNDICES DE RENDIMIENTO (B-TREE, GIN Y GIST)
-- ==============================================================================

-- Índices B-Tree (Relacionales tradicionales)
CREATE INDEX IX_publicacion_id_estudiante ON publicacion(id_estudiante);
CREATE INDEX IX_publicacion_fecha ON publicacion(fecha_publicacion);
CREATE INDEX IX_evento_id_grupo ON evento(id_grupo);

-- Índices GIN (Inverted Index) optimizados para lectura rápida de JSONB
CREATE INDEX idx_perfil_datos_extra_gin ON perfil USING GIN (datos_extra);
CREATE INDEX idx_evento_datos_extra_gin ON evento USING GIN (datos_extra);
CREATE INDEX idx_publicacion_datos_extra_gin ON publicacion USING GIN (datos_extra);
CREATE INDEX idx_lectura_metadatos_gin ON lectura_sensor USING GIN (metadatos);
CREATE INDEX idx_log_dispositivo_gin ON log_actividad USING GIN (dispositivo);

-- Índices GIST para PostGIS (Acelera búsquedas espaciales y de proximidad)
CREATE INDEX idx_evento_ubicacion_gist ON evento USING GIST (ubicacion);
CREATE INDEX idx_mentoria_ubicacion_gist ON mentoria USING GIST (ubicacion);
CREATE INDEX idx_sensor_ubicacion_gist ON sensor_iot USING GIST (ubicacion);
CREATE INDEX idx_checkin_ubicacion_gist ON checkin_ubicacion USING GIST (ubicacion);

-- Índices Temporales para IoT (Búsquedas rápidas en series de tiempo)
CREATE INDEX idx_lectura_sensor_id ON lectura_sensor(id_sensor);
CREATE INDEX idx_lectura_sensor_fecha ON lectura_sensor(fecha_lectura DESC);
CREATE INDEX idx_log_fecha ON log_actividad(fecha DESC);


-- ==============================================================================
-- ==============================================================================
-- DML: INSERCIÓN DE DATOS DE PRUEBA CON JSONB Y POSTGIS
-- ==============================================================================
-- ==============================================================================

-- Estudiantes
INSERT INTO estudiante (nombre, apellido, correo, password) VALUES
 ('Ana','Gómez','ana@uni.edu','hash1'),
 ('Luis','Pérez','luis@uni.edu','hash2'),
 ('María','Rodríguez','maria@uni.edu','hash3');

-- Perfiles con JSONB
INSERT INTO perfil (id_estudiante, programa, semestre, area_estudio, datos_extra) VALUES
 (1,'Ing. Sistemas',6,'Tecnología', '{"redes":{"github":"ana"},"preferencias":{"idioma":"es"},"intereses_libres":["IA","blockchain"]}'::JSONB),
 (2,'Ing. Civil',4,'Ingeniería', '{"redes":{"linkedin":"luis"},"preferencias":{"idioma":"es"},"intereses_libres":["estructuras"]}'::JSONB),
 (3,'Diseño',3,'Artes', '{"redes":{},"preferencias":{"idioma":"en"},"intereses_libres":["IA","UX"]}'::JSONB);

-- Grupos
INSERT INTO grupo (creador_id, nombre, tipo) VALUES
 (1,'Grupo IA','Académico'),
 (2,'Grupo Estructuras','Académico');

-- Eventos con JSONB + PostGIS (ST_GeogFromText) OJO: Primero longitud, luego latitud.
INSERT INTO evento (id_grupo, nombre, fecha_inicio, fecha_fin, modalidad, organizador, ubicacion, datos_extra) VALUES
 (1,'Hackathon IA 2025','2025-03-15 08:00','2025-03-16 20:00','Presencial','Grupo IA',
  ST_GeogFromText('SRID=4326;POINT(-74.0431 4.7110)'),
  '{"aforo_maximo":120,"premios":{"primero":500000,"segundo":250000},"tags":["IA","hackathon"]}'::JSONB),
 (2,'Charla Estructuras','2025-03-20 14:00','2025-03-20 16:00','Híbrido','Grupo Estructuras',
  ST_GeogFromText('SRID=4326;POINT(-74.0500 4.7150)'),
  '{"aforo_maximo":50,"premios":{},"tags":["estructuras"]}'::JSONB);

-- Publicaciones con JSONB
INSERT INTO publicacion (id_estudiante, contenido, tipo, datos_extra) VALUES
 (1,'Mi proyecto de IA','multimedia', '{"media":[{"tipo":"imagen","url":"https://cdn/p1.jpg"}],"hashtags":["#IA","#proyecto"],"sentimiento":{"score":0.85,"label":"positivo"}}'::JSONB),
 (3,'Diseño UX de la app','texto', '{"hashtags":["#IA","#UX"],"sentimiento":{"score":0.72,"label":"positivo"}}'::JSONB);

-- Sensores IoT (Ubicación PostGIS)
INSERT INTO sensor_iot (codigo, tipo, edificio, salon, ubicacion) VALUES
 ('SENS-AULA-101','ocupacion','Bloque A','101', ST_GeogFromText('SRID=4326;POINT(-74.0431 4.7110)')),
 ('SENS-AULA-102','ocupacion','Bloque A','102', ST_GeogFromText('SRID=4326;POINT(-74.0435 4.7112)'));

-- Lecturas IoT (Cargando datos a la partición correspondiente a marzo 2025)
INSERT INTO lectura_sensor (id_sensor, fecha_lectura, valor, unidad, metadatos) VALUES
 (1,'2025-03-10 10:00:00',27,'personas','{"precision":0.95,"bateria":87}'::JSONB),
 (1,'2025-03-10 11:00:00',32,'personas','{"precision":0.93,"bateria":86}'::JSONB),
 (2,'2025-03-10 10:00:00',12,'personas','{"precision":0.97,"bateria":92}'::JSONB);

-- Logs de actividad (Analítica JSONB)
INSERT INTO log_actividad (id_estudiante, accion, dispositivo, contexto) VALUES
 (1,'login','{"so":"Android","app_version":"2.1.0"}'::JSONB,'{"exito":true}'::JSONB),
 (3,'login','{"so":"iOS","app_version":"2.1.0"}'::JSONB,'{"exito":true}'::JSONB);

-- Check-in GPS (Ubicación PostGIS)
INSERT INTO checkin_ubicacion (id_estudiante, id_evento, ubicacion, beacon_id, confianza, metadatos) VALUES
 (1,1, ST_GeogFromText('SRID=4326;POINT(-74.0431 4.7110)'), 'BLE-01', 95.5, '{"fuente":"beacon"}'::JSONB);


-- ==============================================================================
-- ==============================================================================
-- DML: CONSULTAS CON DATOS SEMIESTRUCTURADOS (JSONB) Y POSTGIS
-- ==============================================================================
-- ==============================================================================

-- ==============================================================================
-- C1. BÚSQUEDA DENTRO DE ARREGLOS JSONB
-- Objetivo: Encontrar estudiantes interesados en "IA".
-- Técnica: El operador '@>' comprueba si el array JSON original contiene "IA". 
-- Se apoya en el índice GIN para no tener que escanear la tabla secuencialmente.
-- ==============================================================================
SELECT e.nombre, e.apellido, p.datos_extra->'intereses_libres' AS intereses
FROM estudiante e
JOIN perfil p ON p.id_estudiante = e.id_estudiante
WHERE p.datos_extra->'intereses_libres' @> '["IA"]'::JSONB;

-- ==============================================================================
-- C2. EXTRACCIÓN Y CASTEO DE CAMPOS SEMIESTRUCTURADOS
-- Objetivo: Mostrar eventos con aforo máximo mayor a 100 y su primer premio.
-- Técnica: "->>" extrae el valor como texto plano. Luego se usa (::INT) para 
-- castearlo a entero y permitir la evaluación matemática (> 100).
-- ==============================================================================
SELECT nombre,
       (datos_extra->>'aforo_maximo')::INT AS aforo,
       datos_extra->'premios'->>'primero' AS premio_1
FROM evento
WHERE (datos_extra->>'aforo_maximo')::INT > 100;

-- ==============================================================================
-- C3. CRUCE DE ESTRUCTURAS COMPLEJAS JSONB
-- Objetivo: Buscar publicaciones con el hashtag #IA y extraer el puntaje de sentimiento.
-- Técnica: Mezcla el filtro de contención (@>) en un nodo y la navegación de llave (->>) 
-- en el nodo anidado "sentimiento".
-- ==============================================================================
SELECT contenido,
       datos_extra->'hashtags' AS tags,
       (datos_extra->'sentimiento'->>'score')::NUMERIC AS sentimiento
FROM publicacion
WHERE datos_extra->'hashtags' @> '["#IA"]'::JSONB
ORDER BY fecha_publicacion DESC;

-- ==============================================================================
-- C4. AGREGACIÓN SQL CON DATOS JSONB
-- Objetivo: Promediar el puntaje de sentimiento (analítica de datos extraídos).
-- Técnica: El operador '?' verifica si la llave 'sentimiento' existe en el JSON.
-- Luego, extrae el valor, lo castea a NUMERIC y le aplica AVG() relacional.
-- ==============================================================================
SELECT e.nombre,
       COUNT(*) AS posts,
       ROUND(AVG((p.datos_extra->'sentimiento'->>'score')::NUMERIC),3) AS sent_prom
FROM estudiante e
JOIN publicacion p ON p.id_estudiante = e.id_estudiante
WHERE p.datos_extra ? 'sentimiento'
GROUP BY e.id_estudiante, e.nombre
ORDER BY sent_prom DESC;

-- C5. Aforo promedio por edificio (IoT - Agrupación clásica)
SELECT s.edificio, s.salon,
       ROUND(AVG(l.valor),2) AS ocup_prom,
       MAX(l.valor) AS pico,
       COUNT(*) AS n_lecturas
FROM sensor_iot s
JOIN lectura_sensor l ON l.id_sensor = s.id_sensor
WHERE s.tipo = 'ocupacion'
GROUP BY s.edificio, s.salon
ORDER BY ocup_prom DESC;

-- C6. Eventos con ocupación real vs. aforo declarado (SQL + JSON)
SELECT ev.nombre,
       (ev.datos_extra->>'aforo_maximo')::INT AS aforo_declarado,
       COUNT(DISTINCT c.id_estudiante) AS asistentes_reales,
       ROUND(100.0*COUNT(DISTINCT c.id_estudiante)
             / NULLIF((ev.datos_extra->>'aforo_maximo')::INT,0),2) AS pct_ocup
FROM evento ev
LEFT JOIN checkin_ubicacion c ON c.id_evento = ev.id_evento
GROUP BY ev.id_evento, ev.nombre, ev.datos_extra
ORDER BY pct_ocup DESC NULLS LAST;

-- C7. Login por SO (Extracción JSONB en un GROUP BY)
SELECT dispositivo->>'so' AS so,
       COUNT(*) AS total,
       COUNT(DISTINCT id_estudiante) AS usuarios
FROM log_actividad
WHERE accion = 'login'
GROUP BY dispositivo->>'so'
ORDER BY total DESC;

-- ==============================================================================
-- C8. BÚSQUEDA ESPACIAL CON POSTGIS (ST_DWithin)
-- Objetivo: Encontrar eventos a menos de 2 km (2000 metros) de un punto central.
-- Técnica: Se usa 'ST_DWithin' en lugar de fórmulas trigonométricas complejas.
-- Esto aprovecha el índice espacial GIST para un filtrado geográfico ultra rápido.
-- ST_Y y ST_X extraen la latitud y longitud visualmente.
-- ==============================================================================
SELECT nombre, modalidad, 
       ST_Y(ubicacion::geometry) AS latitud, 
       ST_X(ubicacion::geometry) AS longitud,
       ROUND((ST_Distance(ubicacion, ST_GeogFromText('SRID=4326;POINT(-74.0431 4.7110)')) / 1000)::numeric, 2) AS distancia_km
FROM evento
WHERE ST_DWithin(
    ubicacion, 
    ST_GeogFromText('SRID=4326;POINT(-74.0431 4.7110)'), 
    2000 
)
ORDER BY distancia_km;

-- ==============================================================================
-- C9. DESCOMPOSICIÓN DE JSONB EN FILAS (FLATTENING)
-- Objetivo: Listar los premios disponibles de forma vertical.
-- Técnica: La función 'jsonb_each_text' toma el objeto JSON 'premios' y lo 
-- divide convirtiendo cada par de clave/valor en una fila real de la tabla.
-- ==============================================================================
SELECT ev.nombre, p.key AS posicion, p.value AS valor
FROM evento ev,
     jsonb_each_text(ev.datos_extra->'premios') AS p
ORDER BY ev.nombre;

-- C10. Top edificios con mayor variación de ocupación (Analítica avanzada IoT)
SELECT s.edificio,
       ROUND(AVG(l.valor),2) AS prom,
       ROUND(STDDEV(l.valor),2) AS desv,
       COUNT(*) FILTER (WHERE l.valor > 40) AS alertas
FROM sensor_iot s
JOIN lectura_sensor l ON l.id_sensor = s.id_sensor
GROUP BY s.edificio
ORDER BY desv DESC
LIMIT 5;
