# RedSocial
Se ha identificado una necesidad de  mejorar la comunicación y la interacción entre los estudiantes del Pascual Bravo. Aunque se cuenta con plataformas institucionales, a menudo son formales y no facilitan la conexión casual, el intercambio de conocimientos entre pares, la formación de grupos de estudio o la organización de eventos informales.

# Red Social Pascualina -  Comparar la implementación de un diccionario de datos físico en diferentes SGBD

## Integrantes del Equipo
*Jonathan Montoya Machado 

*Johan Dario Martinez Echeverri

## Descripción del Caso
Este repositorio contiene la implementación y documentación del modelo físico de base de datos para la Red Social Estudiantil Pascualina. Para garantizar la interoperabilidad del modelo de la Red Social Estudiantil Pascualina, se realizó la traducción y adaptación del DDL en tres motores de bases de datos líderes, evaluando su comportamiento respecto al soporte NoSQL (JSON) y datos espaciales (IoT/GPS). El proyecto integra un diseño relacional robusto con características avanzadas:

* la Adaptación de Datos Semiestructurados (NoSQL):Incorporación de campos datos extra tipo JSONB/JSON en las tablas. Permite guardar configuraciones, hashtags, encuestas y archivos adjuntos multimedia sin modificar el esquema físico relacional.  

* Geolocalización y Coordenadas GPS (PostGIS / Spatial):Integración de campos tipo GEOGRAPHY para registrar las coordenadas exactas WGS84 (SRID 4326) donde se realizan eventos académicos o encuentros de mentoría dentro del campus. 

* Optimización de Consultas e Índices:Índices B-Tree para llaves foráneas y campos de alta frecuencia de búsqueda.Índices espaciales GIST y SPATIAL INDEX para acelerar consultas de proximidad geográfica.   

## 🛠️ Tecnologías y Herramientas Seleccionadas

* **PostgreSQL:** Es la opción más robusta para este proyecto gracias a la extensión PostGIS y el tipo JSONB, permitiendo consultas geográficas avanzadas por proximidad en el campus e indexación sobre atributos dinámicos.
* **MySQL:** Destaca por su simplicidad de despliegue en entornos web, ofreciendo soporte nativo para JSON y tipos de datos POINT orientados a sistemas de georreferenciación.
* **SQL Server:** Brinda un control de integridad sumamente estricto. Al no contar con un tipo JSON nativo único, utiliza campos de texto extenso validados mediante restricciones CHECK (ISJSON(...)) para mantener la coherencia NoSQL.


