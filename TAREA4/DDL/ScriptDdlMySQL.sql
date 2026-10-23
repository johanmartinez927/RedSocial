CREATE DATABASE comparacion_diccionarios_sgbd;

USE comparacion_diccionarios_sgbd;

-- 1. LIMPIEZA DEL ESQUEMA
DROP TABLE IF EXISTS mentoria;
DROP TABLE IF EXISTS seguir;
DROP TABLE IF EXISTS comentario;
DROP TABLE IF EXISTS reaccion;
DROP TABLE IF EXISTS publicacion;
DROP TABLE IF EXISTS asistente_evento;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS miembro_grupo;
DROP TABLE IF EXISTS grupo;
DROP TABLE IF EXISTS estudiante_interes;
DROP TABLE IF EXISTS interes;
DROP TABLE IF EXISTS estudiante_habilidad;
DROP TABLE IF EXISTS habilidad;
DROP TABLE IF EXISTS perfil;
DROP TABLE IF EXISTS estudiante;

-- 2. TABLA: ESTUDIANTE
CREATE TABLE estudiante (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ultima_actividad TIMESTAMP NULL DEFAULT NULL,
    estado VARCHAR(20) DEFAULT 'Activo' NOT NULL
);

-- 3. TABLA: PERFIL 
CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    area_estudio VARCHAR(80),
    biografia VARCHAR(500),
    programa VARCHAR(80) NOT NULL,
    semestre INT NOT NULL,
    ciudad VARCHAR(50),
    foto_perfil VARCHAR(255),
    datos_extra JSON DEFAULT NULL, -- MySQL usa JSON
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 4. TABLA: HABILIDAD
CREATE TABLE habilidad (
    id_habilidad INT AUTO_INCREMENT PRIMARY KEY,
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
    id_interes INT AUTO_INCREMENT PRIMARY KEY,
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
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
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
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    id_grupo INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    lugar VARCHAR(150),
    modalidad VARCHAR(30) NOT NULL,
    organizador VARCHAR(100) NOT NULL,
    ubicacion POINT SRID 4326 NOT NULL, -- MySQL Spatial Point
    datos_extra JSON DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    SPATIAL INDEX idx_evento_ubicacion (ubicacion) -- Índice espacial en MySQL
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
    id_publicacion INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    contenido VARCHAR(1000) NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    datos_extra JSON DEFAULT NULL,
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
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
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
    ubicacion POINT SRID 4326 NOT NULL, -- MySQL Spatial Point
    PRIMARY KEY (id_mentor, id_aprendiz),
    FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_aprendiz) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT chk_no_auto_mentoria CHECK (id_mentor <> id_aprendiz),
    SPATIAL INDEX idx_mentoria_ubicacion (ubicacion) -- Índice espacial en MySQL
);

-- ÍNDICES DE RENDIMIENTO (Los espaciales se definieron dentro de la tabla)
CREATE INDEX IX_publicacion_id_estudiante ON publicacion(id_estudiante);
CREATE INDEX IX_publicacion_fecha ON publicacion(fecha_publicacion);
CREATE INDEX IX_evento_id_grupo ON evento(id_grupo);
CREATE INDEX IX_miembro_grupo_id_grupo ON miembro_grupo(id_grupo);

