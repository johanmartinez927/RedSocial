# RedSocial — Pascualina

Se ha identificado una necesidad de mejorar la comunicación y la interacción entre los estudiantes del Pascual Bravo. Aunque se cuenta con plataformas institucionales, a menudo son formales y no facilitan la conexión casual, el intercambio de conocimientos entre pares, la formación de grupos de estudio o la organización de eventos informales.

## Red Social Pascualina — Arquitectura Híbrida (Relacional + NoSQL + IoT + Big Data)

### Integrantes del Grupo 12
* **Jonathan Montoya Machado**
* **Johan Darío Martínez Echeverri**

### G100 (SD1006) Bases de Datos I — Tecnología en Desarrollo de Software
* **Docente:** Oralia Cortés Grajales

---

### Descripción del Caso

Este repositorio contiene el diseño e implementación de una arquitectura de base de datos híbrida para la Red Social Estudiantil Pascualina. El modelo evoluciona del esquema relacional tradicional para soportar escenarios de Big Data y telemetría IoT, integrando datos semiestructurados (JSONB,JSON) y geoespaciales (PostGIS) dentro de un mismo motor.

A partir del esquema físico y datos de prueba, se desarrollaron 10 consultas analíticas orientadas a responder preguntas reales del entorno universitario, destacando las siguientes características técnicas:

* **Almacenamiento Semiestructurado (JSONB):** Uso de columnas dinámicas (datos_extra,metadatos, dispositivo) para almacenar atributos variables como redes sociales, premios de eventos, etiquetas, análisis de sentimiento y logs sin alterar el esquema rígido.
* **Analítica IoT y Particionamiento Big Data:** Implementación de tablas para sensores físicos y registros de actividad (sensor_iot,lectura_sensor, checkin_ubicacion), aplicando particionamiento mensual por rango de fechas (PARTITION BY RANGE) para optimizar el almacenamiento masivo.
* **Georreferenciación Espacial (PostGIS):** Uso del tipo de dato GEOGRAPHY(Point, 4326) junto con funciones espaciales (ST_DWithin,ST_Distance) para búsquedas por proximidad y cálculo de distancias en el campus.
* **Consultas Híbridas e Indexación Avanzada:** Extracción y cruce de datos mediante operadores JSON (->,->>,@>,?,jsonb_each_text), funciones de agregación (AVG,STDDEV, COUNT FILTER) y optimización con índices B-Tree, GIN (JSONB) y GiST (espaciales).

---

### 🛠️ Tecnologías y Herramientas Seleccionadas

* **PostgreSQL 16+ / 17:** Motor de base de datos objeto-relacional empleado para administrar el modelo híbrido, el particionamiento de tablas y las consultas sobre JSONB.
* **PostGIS 3.x:** Extensión espacial habilitada para el almacenamiento de coordenadas geográficas y ejecución de consultas de proximidad.
* **pgAdmin 4:** Herramienta de administración utilizada para escribir, ejecutar y validar los scripts DDL y DML.
