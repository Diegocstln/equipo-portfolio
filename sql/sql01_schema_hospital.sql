BEGIN;

-- =========================
-- CATÁLOGOS
-- =========================

CREATE TABLE IF NOT EXISTS categoria (
  id_cat SERIAL PRIMARY KEY,
  nom_cat VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS especie (
  id_especie SERIAL PRIMARY KEY,
  especie VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS pais (
  id_pais SERIAL PRIMARY KEY,
  nom_pais VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS laboratorio (
  id_lab SERIAL PRIMARY KEY,
  nom_lab VARCHAR(80),
  telefono_laboratorio VARCHAR(30),
  email_laboratorio VARCHAR(120),
  sitio_web VARCHAR(200),
  id_pais INT NOT NULL
);

CREATE TABLE IF NOT EXISTS via_administracion (
  id_via SERIAL PRIMARY KEY,
  nom_via VARCHAR(60) NOT NULL,
  descripcion_via VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS presentacion (
  id_pres SERIAL PRIMARY KEY,
  nom_pres VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS unidad_medida (
  id_um SERIAL PRIMARY KEY,
  um VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS forma_farmaceutica (
  id_form SERIAL PRIMARY KEY,
  nom_form VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS compuesto (
  id_comp SERIAL PRIMARY KEY,
  nom_comp VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS compuesto_por_unidad (
  id_compxu SERIAL PRIMARY KEY,
  compxu VARCHAR(30) NOT NULL
);

-- =========================
-- MEDICAMENTOS
-- =========================

CREATE TABLE IF NOT EXISTS medicamento (
  id_med SERIAL PRIMARY KEY,
  nom_med VARCHAR(80) NOT NULL,
  id_lab INT NOT NULL,
  id_via INT NOT NULL,
  id_cat INT NOT NULL,
  id_especie INT NOT NULL
);

CREATE TABLE IF NOT EXISTS presentacion_medicamento (
  id_presxmed SERIAL PRIMARY KEY,
  cantidad FLOAT NOT NULL,
  id_med INT NOT NULL,
  id_pres INT NOT NULL,
  id_um INT NOT NULL,
  id_form INT NOT NULL
);

CREATE TABLE IF NOT EXISTS ingrediente_activo (
  id_presxmed INT NOT NULL,
  cantidad FLOAT NOT NULL,
  id_um INT NOT NULL,
  id_compxu INT NOT NULL,
  id_comp INT NOT NULL,
  PRIMARY KEY (id_presxmed, id_um, id_compxu, id_comp)
);

-- =========================
-- FOREIGN KEYS
-- =========================

ALTER TABLE laboratorio
  ADD CONSTRAINT fk_laboratorio_pais
  FOREIGN KEY (id_pais) REFERENCES pais(id_pais);

ALTER TABLE medicamento
  ADD CONSTRAINT fk_med_lab FOREIGN KEY (id_lab) REFERENCES laboratorio(id_lab),
  ADD CONSTRAINT fk_med_via FOREIGN KEY (id_via) REFERENCES via_administracion(id_via),
  ADD CONSTRAINT fk_med_cat FOREIGN KEY (id_cat) REFERENCES categoria(id_cat),
  ADD CONSTRAINT fk_med_especie FOREIGN KEY (id_especie) REFERENCES especie(id_especie);

ALTER TABLE presentacion_medicamento
  ADD CONSTRAINT fk_pm_med FOREIGN KEY (id_med) REFERENCES medicamento(id_med),
  ADD CONSTRAINT fk_pm_pres FOREIGN KEY (id_pres) REFERENCES presentacion(id_pres),
  ADD CONSTRAINT fk_pm_um FOREIGN KEY (id_um) REFERENCES unidad_medida(id_um);
-- ADD CONSTRAINT fk_pm_form FOREIGN KEY (id_form) REFERENCES forma_farmaceutica(id_form);

ALTER TABLE ingrediente_activo
  ADD CONSTRAINT fk_ia_presxmed FOREIGN KEY (id_presxmed) REFERENCES presentacion_medicamento(id_presxmed),
  ADD CONSTRAINT fk_ia_um FOREIGN KEY (id_um) REFERENCES unidad_medida(id_um),
  ADD CONSTRAINT fk_ia_comp FOREIGN KEY (id_comp) REFERENCES compuesto(id_comp),
  ADD CONSTRAINT fk_ia_compxu FOREIGN KEY (id_compxu) REFERENCES compuesto_por_unidad(id_compxu);

COMMIT;
