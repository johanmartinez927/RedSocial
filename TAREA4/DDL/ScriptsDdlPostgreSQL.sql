-- BASE DE DATOS: RED SOCIAL ESTUDIANTIL PASCUALINA
-- MOTOR: PostgreSQL 17

-- 0. ACTIVAR EXTENSIÓN ESPACIAL (POSTGIS)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. LIMPIEZA DEL ESQUEMA
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

-- 2. TABLA: ESTUDIANTE
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

-- 3. TABLA: PERFIL 
CREATE TABLE perfil (
    id_perfil SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    area_estudio VARCHAR(80),
    biografia VARCHAR(500),
    programa VARCHAR(80) NOT NULL,
    semestre INT NOT NULL,
    ciudad VARCHAR(50),
    foto_perfil VARCHAR(255),
    datos_extra JSONB DEFAULT '{}'::JSONB,--JSONB (datos semiestructurados NoSQL)
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 4. TABLA: HABILIDAD
CREATE TABLE habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

-- 5. TABLA: ESTUDIANTE_HABILIDAD
CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(20) NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_habilidad),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON DELETE CASCADE
);

-- 6. TABLA: INTERES
CREATE TABLE interes (
    id_interes SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

-- 7. TABLA: ESTUDIANTE_INTERES
CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL,
    id_interes INT NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_interes),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON DELETE CASCADE
);

-- 8. TABLA: GRUPO
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

-- 9. TABLA: MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (
    id_estudiante INT NOT NULL,
    id_grupo INT NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    rol VARCHAR(30) DEFAULT 'Miembro' NOT NULL,
    PRIMARY KEY (id_estudiante, id_grupo),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
);

-- 10. TABLA: EVENTO 
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
    ubicacion GEOGRAPHY(POINT, 4326),--Geográficos (GEOGRAPHY(POINT, 4326))
    datos_extra JSONB DEFAULT '{}'::JSONB,--JSONB (datos semiestructurados NoSQL)
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
);

-- 11. TABLA: ASISTENTE_EVENTO
CREATE TABLE asistente_evento (
    id_estudiante INT NOT NULL,
    id_evento INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Confirmado' NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_evento),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE
);

-- 12. TABLA: PUBLICACION 
CREATE TABLE publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL,
    contenido VARCHAR(1000) NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    datos_extra JSONB DEFAULT '{}'::JSONB,--JSONB (datos semiestructurados NoSQL)
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 13. TABLA: REACCION
CREATE TABLE reaccion (
    id_estudiante INT NOT NULL,
    id_publicacion INT NOT NULL,
    tipo_reaccion VARCHAR(20) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_estudiante, id_publicacion),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE
);

-- 14. TABLA: COMENTARIO
CREATE TABLE comentario (
    id_comentario SERIAL PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    comentario VARCHAR(500) NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 15. TABLA: SEGUIR
CREATE TABLE seguir (
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (id_seguidor, id_seguido),

    FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,

    CONSTRAINT chk_no_auto_seguimiento CHECK (id_seguidor <> id_seguido)
);

-- 16. TABLA: MENTORIA 
CREATE TABLE mentoria (
    id_mentor INT NOT NULL,
    id_aprendiz INT NOT NULL,
    tema VARCHAR(100) NOT NULL,
    estado VARCHAR(20) DEFAULT 'Solicitado' NOT NULL,
    fecha_mentoria TIMESTAMP NOT NULL,
    lugar VARCHAR(150),
    ubicacion GEOGRAPHY(POINT, 4326),--Geográficos (GEOGRAPHY(POINT, 4326))
    PRIMARY KEY (id_mentor, id_aprendiz),

    FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_aprendiz) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,

    CONSTRAINT chk_no_auto_mentoria CHECK (id_mentor <> id_aprendiz)
);


-- ÍNDICES DE RENDIRMIENTO Y ESPACIALES

CREATE INDEX IX_publicacion_id_estudiante ON publicacion(id_estudiante);
CREATE INDEX IX_publicacion_fecha ON publicacion(fecha_publicacion);
CREATE INDEX IX_evento_id_grupo ON evento(id_grupo);
CREATE INDEX IX_miembro_grupo_id_grupo ON miembro_grupo(id_grupo);

-- Índices Espaciales GIST para consultas GPS rápidas
CREATE INDEX idx_evento_ubicacion ON evento USING GIST(ubicacion);
CREATE INDEX idx_mentoria_ubicacion ON mentoria USING GIST(ubicacion);

