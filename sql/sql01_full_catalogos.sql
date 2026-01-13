-- ============================================================
-- VetCare - Import TOTAL de catálogos (blindado)
-- ============================================================

-- 1) TABLAS (todas)
CREATE TABLE IF NOT EXISTS categoria (
  id_cat INT PRIMARY KEY,
  nom_cat TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS especie (
  id_especie INT PRIMARY KEY,
  nom_especie TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS pais (
  id_pais INT PRIMARY KEY,
  nom_pais TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS laboratorio (
  id_lab INT PRIMARY KEY,
  nom_lab TEXT NOT NULL,
  telefono TEXT,
  email TEXT,
  sitio_web TEXT,
  id_pais INT
);

CREATE TABLE IF NOT EXISTS via_administracion (
  id_via INT PRIMARY KEY,
  nom_via TEXT NOT NULL,
  descripcion TEXT
);

CREATE TABLE IF NOT EXISTS presentacion (
  id_pres INT PRIMARY KEY,
  nom_pres TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS unidad_medida (
  id_um INT PRIMARY KEY,
  nom_um TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS forma_farmaceutica (
  id_form INT PRIMARY KEY,
  nom_form TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS compuesto (
  id_comp INT PRIMARY KEY,
  nom_comp TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS compuesto_por_unidad (
  id_compxu INT PRIMARY KEY,
  compxu TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS medicamento (
  id_med INT PRIMARY KEY,
  nom_med TEXT NOT NULL,
  id_lab INT NOT NULL,
  id_via INT NOT NULL,
  id_cat INT NOT NULL,
  id_especie INT NOT NULL
);

CREATE TABLE IF NOT EXISTS presentacion_medicamento (
  id_presxmed INT PRIMARY KEY,
  cantidad NUMERIC NOT NULL,
  id_med INT NOT NULL,
  id_pres INT NOT NULL,
  id_um INT NOT NULL,
  id_form INT NOT NULL
);

CREATE TABLE IF NOT EXISTS ingrediente_activo (
  id_presxmed INT NOT NULL,
  id_comp INT NOT NULL,
  cantidad NUMERIC NOT NULL,
  id_um INT NOT NULL,
  id_compxu INT NOT NULL,
  PRIMARY KEY (id_presxmed, id_comp)
);

CREATE TABLE IF NOT EXISTS raza (
  id_raza INT PRIMARY KEY,
  nom_raza TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS temperamento (
  id_temp INT PRIMARY KEY,
  nom_temp TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tipo_enf (
  id_tipo_enf INT PRIMARY KEY,
  nom_tipo_enf TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS enfermedad (
  id_enf INT PRIMARY KEY,
  nom_enf TEXT NOT NULL,
  id_tipo_enf INT
);

CREATE TABLE IF NOT EXISTS vacuna (
  id_vacuna INT PRIMARY KEY,
  nom_vacuna TEXT NOT NULL
);

-- 2) TABLA RAW permanente
DROP TABLE IF EXISTS raw_lines;
CREATE TABLE raw_lines (n BIGSERIAL PRIMARY KEY, line TEXT);

-- 3) Parser CSV
CREATE OR REPLACE FUNCTION vetcare_csv_split(line TEXT)
RETURNS TEXT[]
LANGUAGE plpgsql
AS $$
DECLARE
  i INT := 1;
  ch TEXT;
  in_quotes BOOLEAN := FALSE;
  field TEXT := '';
  out TEXT[] := ARRAY[]::TEXT[];
BEGIN
  IF line IS NULL THEN
    RETURN ARRAY[]::TEXT[];
  END IF;

  WHILE i <= length(line) LOOP
    ch := substr(line, i, 1);

    IF ch = '"' THEN
      IF in_quotes AND i < length(line) AND substr(line, i+1, 1) = '"' THEN
        field := field || '"';
        i := i + 1;
      ELSE
        in_quotes := NOT in_quotes;
      END IF;

    ELSIF ch = ',' AND NOT in_quotes THEN
      out := out || field;
      field := '';
    ELSE
      field := field || ch;
    END IF;

    i := i + 1;
  END LOOP;

  out := out || field;
  RETURN out;
END;
$$;

-- Helper: carga archivo a raw_lines y quita header
CREATE OR REPLACE PROCEDURE load_csv_to_raw(path TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE raw_lines;
  EXECUTE format('COPY raw_lines(line) FROM %L WITH (FORMAT text)', path);
  DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);
END;
$$;

-- 4) IMPORTS (todos)

-- categoria.csv: id_cat, nom_cat, (desc extra)
CALL load_csv_to_raw('/data/catalogos/categoria.csv');
INSERT INTO categoria(id_cat, nom_cat)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- especie.csv: id_especie, nom_especie
CALL load_csv_to_raw('/data/catalogos/especie.csv');
INSERT INTO especie(id_especie, nom_especie)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- pais.csv: id_pais, nom_pais
CALL load_csv_to_raw('/data/catalogos/pais.csv');
INSERT INTO pais(id_pais, nom_pais)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- laboratorio.csv: id_lab, nom_lab, telefono, email, sitio_web, id_pais
CALL load_csv_to_raw('/data/catalogos/laboratorio.csv');
INSERT INTO laboratorio(id_lab, nom_lab, telefono, email, sitio_web, id_pais)
SELECT (v[1])::INT, v[2], NULLIF(v[3],''), NULLIF(v[4],''), NULLIF(v[5],''), NULLIF(v[6],'')::INT
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- via_administracion.csv (si no existe, comenta)
-- Si NO tienes ese archivo, borra este bloque
CALL load_csv_to_raw('/data/catalogos/via_administracion.csv');
INSERT INTO via_administracion(id_via, nom_via, descripcion)
SELECT (v[1])::INT, v[2], NULLIF(v[3],'')
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- presentacion.csv: id_pres, nom_pres
CALL load_csv_to_raw('/data/catalogos/presentacion.csv');
INSERT INTO presentacion(id_pres, nom_pres)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- unidad_medida.csv: id_um, nom_um
CALL load_csv_to_raw('/data/catalogos/unidad_medida.csv');
INSERT INTO unidad_medida(id_um, nom_um)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- forma_farmaceutica.csv: id_form, nom_form
CALL load_csv_to_raw('/data/catalogos/forma_farmaceutica.csv');
INSERT INTO forma_farmaceutica(id_form, nom_form)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- compuesto.csv: id_comp, nom_comp
CALL load_csv_to_raw('/data/catalogos/compuesto.csv');
INSERT INTO compuesto(id_comp, nom_comp)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- unidad_compuesto.csv -> compuesto_por_unidad: id_compxu, compxu
CALL load_csv_to_raw('/data/catalogos/unidad_compuesto.csv');
INSERT INTO compuesto_por_unidad(id_compxu, compxu)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- medicamento.csv: id_med, nom_med, id_lab, id_via, id_cat, id_especie
CALL load_csv_to_raw('/data/catalogos/medicamento.csv');
INSERT INTO medicamento(id_med, nom_med, id_lab, id_via, id_cat, id_especie)
SELECT (v[1])::INT, v[2], (v[3])::INT, (v[4])::INT, (v[5])::INT, (v[6])::INT
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- presentacion_medicamento.csv: id_presxmed,cantidad,id_med,id_pres,id_um,id_form
CALL load_csv_to_raw('/data/catalogos/presentacion_medicamento.csv');
INSERT INTO presentacion_medicamento(id_presxmed,cantidad,id_med,id_pres,id_um,id_form)
SELECT (v[1])::INT, (v[2])::NUMERIC, (v[3])::INT, (v[4])::INT, (v[5])::INT, (v[6])::INT
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- ingrediente_activo.csv: id_presxmed,id_comp,cantidad,id_um,id_compxu
CALL load_csv_to_raw('/data/catalogos/ingrediente_activo.csv');
INSERT INTO ingrediente_activo(id_presxmed,id_comp,cantidad,id_um,id_compxu)
SELECT (v[1])::INT, (v[2])::INT, (v[3])::NUMERIC, (v[4])::INT, (v[5])::INT
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- raza.csv
CALL load_csv_to_raw('/data/catalogos/raza.csv');
INSERT INTO raza(id_raza, nom_raza)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- temperamento.csv
CALL load_csv_to_raw('/data/catalogos/temperamento.csv');
INSERT INTO temperamento(id_temp, nom_temp)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- tipo_Enf.csv
CALL load_csv_to_raw('/data/catalogos/tipo_Enf.csv');
INSERT INTO tipo_enf(id_tipo_enf, nom_tipo_enf)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- enfermedades.csv: id_enf, nom_enf, ... , id_tipo_enf (al final o en 3/4)
CALL load_csv_to_raw('/data/catalogos/enfermedades.csv');
INSERT INTO enfermedad(id_enf, nom_enf, id_tipo_enf)
SELECT
  (v[1])::INT,
  v[2],
  CASE
    WHEN array_length(v,1) >= 4 AND v[4] ~ '^[0-9]+$' THEN v[4]::INT
    WHEN array_length(v,1) >= 3 AND v[3] ~ '^[0-9]+$' THEN v[3]::INT
    ELSE NULL
  END
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- vacunas.csv
CALL load_csv_to_raw('/data/catalogos/vacunas.csv');
INSERT INTO vacuna(id_vacuna, nom_vacuna)
SELECT (v[1])::INT, v[2]
FROM (SELECT vetcare_csv_split(line) v FROM raw_lines) s;

-- 5) FOREIGN KEYS (al final)
ALTER TABLE laboratorio
  ADD CONSTRAINT fk_lab_pais FOREIGN KEY (id_pais) REFERENCES pais(id_pais);

ALTER TABLE medicamento
  ADD CONSTRAINT fk_med_lab FOREIGN KEY (id_lab) REFERENCES laboratorio(id_lab),
  ADD CONSTRAINT fk_med_via FOREIGN KEY (id_via) REFERENCES via_administracion(id_via),
  ADD CONSTRAINT fk_med_cat FOREIGN KEY (id_cat) REFERENCES categoria(id_cat),
  ADD CONSTRAINT fk_med_esp FOREIGN KEY (id_especie) REFERENCES especie(id_especie);

ALTER TABLE presentacion_medicamento
  ADD CONSTRAINT fk_pm_med FOREIGN KEY (id_med) REFERENCES medicamento(id_med),
  ADD CONSTRAINT fk_pm_pres FOREIGN KEY (id_pres) REFERENCES presentacion(id_pres),
  ADD CONSTRAINT fk_pm_um FOREIGN KEY (id_um) REFERENCES unidad_medida(id_um),
  ADD CONSTRAINT fk_pm_form FOREIGN KEY (id_form) REFERENCES forma_farmaceutica(id_form);

ALTER TABLE ingrediente_activo
  ADD CONSTRAINT fk_ia_pm FOREIGN KEY (id_presxmed) REFERENCES presentacion_medicamento(id_presxmed),
  ADD CONSTRAINT fk_ia_um FOREIGN KEY (id_um) REFERENCES unidad_medida(id_um),
  ADD CONSTRAINT fk_ia_comp FOREIGN KEY (id_comp) REFERENCES compuesto(id_comp),
  ADD CONSTRAINT fk_ia_compxu FOREIGN KEY (id_compxu) REFERENCES compuesto_por_unidad(id_compxu);

ALTER TABLE enfermedad
  ADD CONSTRAINT fk_enf_tipo FOREIGN KEY (id_tipo_enf) REFERENCES tipo_enf(id_tipo_enf);

-- Limpieza
DROP TABLE IF EXISTS raw_lines;
DROP FUNCTION IF EXISTS vetcare_csv_split(TEXT);
DROP PROCEDURE IF EXISTS load_csv_to_raw(TEXT);
