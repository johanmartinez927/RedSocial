# RedSocial

Se ha identificado una necesidad de mejorar la comunicación y la interacción entre los estudiantes del Pascual Bravo. Aunque se cuenta con plataformas institucionales, a menudo son formales y no facilitan la conexión casual, el intercambio de conocimientos entre pares, la formación de grupos de estudio o la organización de eventos informales.

## Red Social Pascualina - Implementación de un sistema de consultas y vistas (DML)

### Integrantes del Grupo 12

* Jonathan Montoya Machado
* Johan Darío Martínez Echeverri

### G100 (SD1006) Bases de Datos I — Tecnología en Desarrollo de Software

* **Docente:** Oralia Cortes Grajales

### Descripción del Caso

Este repositorio contiene el diseño, implementación del sistema de consultas (DML) y vistas analíticas (`VIEWS`) sobre el modelo físico de la Red Social Estudiantil Pascualina. A partir de la base de datos poblada con registros de prueba, se desarrollaron consultas orientadas a responder preguntas reales de negocio del entorno universitario, integrando las siguientes características técnicas:

* **Consultas DML de Negocio:** Implementación de uniones internas y externas (`INNER JOIN`, `LEFT JOIN` para diferencia de conjuntos), subconsultas, funciones de agregación (`COUNT`, `AVG`, `SUM`, `STRING_AGG`) y manejo de valores nulos mediante `COALESCE`.
* **Estándares de Nomenclatura (`ALIAS`):** Uso sistemático de alias descriptivos para columnas calculadas y concatenadas, facilitando la lectura e interpretación de los reportes administrativos.
* **Vistas Analíticas (`VIEWS`):** Creación de tablas virtuales (`vw_perfil_integral_estudiante` y `vw_eventos_campus_geolocalizados`) para encapsular consultas complejas, reutilizar métricas en nuevos análisis y proteger datos sensibles como contraseñas.

### 🛠️ Tecnologías y Herramientas Seleccionadas

* **PostgreSQL 17:** Motor de base de datos relacional empleado para ejecutar el esquema físico (DDL), gestionar los datos de prueba, construir las consultas DML y almacenar las vistas.
* **pgAdmin 4:** Herramienta de administración utilizada para escribir, ejecutar y validar los scripts SQL, además de generar el diagrama del modelo físico.


