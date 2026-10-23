
-- BASE DE DATOS: RED SOCIAL ESTUDIANTIL PASCUALINA
-- MOTOR: Microsoft SQL Server 2022(OneCompiler)


-- 1. LIMPIEZA DEL ESQUEMA
IF OBJECT_ID('mentoria', 'U') IS NOT NULL DROP TABLE mentoria;
IF OBJECT_ID('seguir', 'U') IS NOT NULL DROP TABLE seguir;
IF OBJECT_ID('comentario', 'U') IS NOT NULL DROP TABLE comentario;
IF OBJECT_ID('reaccion', 'U') IS NOT NULL DROP TABLE reaccion;
IF OBJECT_ID('publicacion', 'U') IS NOT NULL DROP TABLE publicacion;
IF OBJECT_ID('asistente_evento', 'U') IS NOT NULL DROP TABLE asistente_evento;
IF OBJECT_ID('evento', 'U') IS NOT NULL DROP TABLE evento;
IF OBJECT_ID('miembro_grupo', 'U') IS NOT NULL DROP TABLE miembro_grupo;
IF OBJECT_ID('grupo', 'U') IS NOT NULL DROP TABLE grupo;
IF OBJECT_ID('estudiante_interes', 'U') IS NOT NULL DROP TABLE estudiante_interes;
IF OBJECT_ID('interes', 'U') IS NOT NULL DROP TABLE interes;
IF OBJECT_ID('estudiante_habilidad', 'U') IS NOT NULL DROP TABLE estudiante_habilidad;
IF OBJECT_ID('habilidad', 'U') IS NOT NULL DROP TABLE habilidad;
IF OBJECT_ID('perfil', 'U') IS NOT NULL DROP TABLE perfil;
IF OBJECT_ID('estudiante', 'U') IS NOT NULL DROP TABLE estudiante;


-- 2. TABLA: ESTUDIANTE
CREATE TABLE estudiante (
    id_estudiante INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fecha_registro DATETIME2 DEFAULT GETDATE() NOT NULL,
    ultima_actividad DATETIME2,
    estado VARCHAR(20) DEFAULT 'Activo' NOT NULL
);

-- 3. TABLA: PERFIL (Con JSON)
CREATE TABLE perfil (
    id_perfil INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    area_estudio VARCHAR(80),
    biografia VARCHAR(500),
    programa VARCHAR(80) NOT NULL,
    semestre INT NOT NULL,
    ciudad VARCHAR(50),
    foto_perfil VARCHAR(255),
    datos_extra NVARCHAR(MAX) DEFAULT '{}',-- <--- TIPO JSON (NoSQL)
    fecha_actualizacion DATETIME2 DEFAULT GETDATE() NOT NULL,

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT chk_perfil_datos_extra_json CHECK (datos_extra IS NULL OR ISJSON(datos_extra) > 0)-- <--- TIPO JSON (NoSQL)
);

-- 4. TABLA: HABILIDAD
CREATE TABLE habilidad (
    id_habilidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

-- 5. TABLA: ESTUDIANTE_HABILIDAD
CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(20) NOT NULL,
    fecha_agregado DATETIME2 DEFAULT GETDATE() NOT NULL,
    PRIMARY KEY (id_estudiante, id_habilidad),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON DELETE CASCADE
);

-- 6. TABLA: INTERES
CREATE TABLE interes (
    id_interes INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

-- 7. TABLA: ESTUDIANTE_INTERES
CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL,
    id_interes INT NOT NULL,
    fecha_agregado DATETIME2 DEFAULT GETDATE() NOT NULL,
    PRIMARY KEY (id_estudiante, id_interes),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON DELETE CASCADE
);

-- 8. TABLA: GRUPO
CREATE TABLE grupo (
    id_grupo INT IDENTITY(1,1) PRIMARY KEY,
    creador_id INT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(500),
    tipo VARCHAR(30) NOT NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE() NOT NULL,
    estado VARCHAR(20) DEFAULT 'Activo' NOT NULL,

    FOREIGN KEY (creador_id) REFERENCES estudiante(id_estudiante) ON DELETE NO ACTION
);

-- 9. TABLA: MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (
    id_estudiante INT NOT NULL,
    id_grupo INT NOT NULL,
    fecha_ingreso DATETIME2 DEFAULT GETDATE() NOT NULL,
    rol VARCHAR(30) DEFAULT 'Miembro' NOT NULL,
    PRIMARY KEY (id_estudiante, id_grupo),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
);

-- 10. TABLA: EVENTO (Con GPS y JSON)
CREATE TABLE evento (
    id_evento INT IDENTITY(1,1) PRIMARY KEY,
    id_grupo INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    fecha_inicio DATETIME2 NOT NULL,
    fecha_fin DATETIME2 NOT NULL,
    lugar VARCHAR(150),
    modalidad VARCHAR(30) NOT NULL,
    organizador VARCHAR(100) NOT NULL,
    ubicacion GEOGRAPHY,-- <--- TIPO GEOGRÁFICO (GPS)
    datos_extra NVARCHAR(MAX) DEFAULT '{}',-- <--- TIPO JSON (NoSQL)
    fecha_creacion DATETIME2 DEFAULT GETDATE() NOT NULL,

    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    CONSTRAINT chk_evento_datos_extra_json CHECK (datos_extra IS NULL OR ISJSON(datos_extra) > 0)-- <--- TIPO JSON (NoSQL)
);

-- 11. TABLA: ASISTENTE_EVENTO
CREATE TABLE asistente_evento (
    id_estudiante INT NOT NULL,
    id_evento INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Confirmado' NOT NULL,
    fecha_registro DATETIME2 DEFAULT GETDATE() NOT NULL,
    PRIMARY KEY (id_estudiante, id_evento),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE
);

-- 12. TABLA: PUBLICACION (Con JSON)
CREATE TABLE publicacion (
    id_publicacion INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL,
    contenido VARCHAR(1000) NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    datos_extra NVARCHAR(MAX) DEFAULT '{}',-- <--- TIPO JSON (NoSQL)
    fecha_publicacion DATETIME2 DEFAULT GETDATE() NOT NULL,

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT chk_publicacion_datos_extra_json CHECK (datos_extra IS NULL OR ISJSON(datos_extra) > 0)-- <--- TIPO JSON (NoSQL)
);

-- 13. TABLA: REACCION
-- CORRECCIÓN: ON DELETE NO ACTION en id_estudiante para resolver el Msg 1785
CREATE TABLE reaccion (
    id_estudiante INT NOT NULL,
    id_publicacion INT NOT NULL,
    tipo_reaccion VARCHAR(20) NOT NULL,
    fecha DATETIME2 DEFAULT GETDATE() NOT NULL,
    PRIMARY KEY (id_estudiante, id_publicacion),

    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE NO ACTION,
    FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE
);

-- 14. TABLA: COMENTARIO
CREATE TABLE comentario (
    id_comentario INT IDENTITY(1,1) PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    comentario VARCHAR(500) NOT NULL,
    fecha_comentario DATETIME2 DEFAULT GETDATE() NOT NULL,

    FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE NO ACTION
);

-- 15. TABLA: SEGUIR
CREATE TABLE seguir (
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento DATETIME2 DEFAULT GETDATE() NOT NULL,
    PRIMARY KEY (id_seguidor, id_seguido),

    FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON DELETE NO ACTION,
    FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON DELETE NO ACTION,

    CONSTRAINT chk_no_auto_seguimiento CHECK (id_seguidor <> id_seguido)
);

-- 16. TABLA: MENTORIA
CREATE TABLE mentoria (
    id_mentor INT NOT NULL,
    id_aprendiz INT NOT NULL,
    tema VARCHAR(100) NOT NULL,
    estado VARCHAR(20) DEFAULT 'Solicitado' NOT NULL,
    fecha_mentoria DATETIME2 NOT NULL,
    lugar VARCHAR(150),
    ubicacion GEOGRAPHY,-- <--- TIPO GEOGRÁFICO (GPS)
    PRIMARY KEY (id_mentor, id_aprendiz),

    FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON DELETE NO ACTION,
    FOREIGN KEY (id_aprendiz) REFERENCES estudiante(id_estudiante) ON DELETE NO ACTION,

    CONSTRAINT chk_no_auto_mentoria CHECK (id_mentor <> id_aprendiz)
);

-- ============================================================
-- ÍNDICES DE RENDIMIENTO
-- ============================================================

CREATE INDEX IX_publicacion_id_estudiante ON publicacion(id_estudiante);
CREATE INDEX IX_publicacion_fecha ON publicacion(fecha_publicacion);
CREATE INDEX IX_evento_id_grupo ON evento(id_grupo);
CREATE INDEX IX_miembro_grupo_id_grupo ON miembro_grupo(id_grupo);

-- CONSULTA PARA PROBAR LA EJECUCIÓN
SELECT 'Base de datos creada exitosamente' AS Resultado;
