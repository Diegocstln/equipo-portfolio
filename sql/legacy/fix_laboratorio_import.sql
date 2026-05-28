DROP TABLE IF EXISTS laboratorio_raw;

CREATE TABLE laboratorio_raw (
  id_lab_txt   TEXT,
  nom_lab_txt  TEXT,
  id_pais_txt  TEXT,
  telefono_txt TEXT,
  email_txt    TEXT,
  sitio_txt    TEXT
);

TRUNCATE laboratorio_raw;

COPY laboratorio_raw
FROM '/data/catalogos/laboratorio.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ESCAPE '"');

TRUNCATE laboratorio RESTART IDENTITY CASCADE;

INSERT INTO laboratorio (id_lab, nom_lab, telefono, email, sitio_web, id_pais)
SELECT
  NULLIF(id_lab_txt,'')::INT,
  NULLIF(nom_lab_txt,''),
  NULLIF(telefono_txt,''),
  NULLIF(email_txt,''),
  NULLIF(sitio_txt,''),
  CASE WHEN id_pais_txt ~ '^[0-9]+$' THEN id_pais_txt::INT ELSE NULL END
FROM laboratorio_raw;

-- opcional: ver 5 filas
SELECT * FROM laboratorio LIMIT 5;
