-- =========================================
-- 01_catalogos.sql (VetCare)
-- Crea tablas de catálogos + staging (raw)
-- =========================================

-- =====================
-- Catálogos base
-- =====================

CREATE TABLE pais (
  id_pais INT PRIMARY KEY,
  nom_pais TEXT NOT NULL
);

CREATE TABLE especie (
  id_especie INT PRIMARY KEY,
  nom_especie TEXT NOT NULL
);

CREATE TABLE categoria (
  id_cat INT PRIMARY KEY,
  nom_cat TEXT NOT NULL,
  descripcion TEXT
);

-- Forma farmacéutica / vía administración (CSV trae descripción)
CREATE TABLE via_administracion (
  id_via INT PRIMARY KEY,
  nom_via TEXT NOT NULL,
  descripcion TEXT
);

-- Unidad de medida (CSV trae N/E en nom_um, por eso NO NOT NULL)
CREATE TABLE unidad_medida (
  id_um INT PRIMARY KEY,
  nom_um TEXT
);

CREATE TABLE compuesto (
  id_comp INT PRIMARY KEY,
  nom_comp TEXT NOT NULL
);

-- =====================
-- Laboratorios
-- =====================
-- OJO: tu CSV trae texto en id_pais (ej. "México (fundado...)"),
-- por eso aquí lo dejamos como TEXT y sin FK.
CREATE TABLE laboratorio (
  id_lab INT PRIMARY KEY,
  nom_lab TEXT NOT NULL,
  id_pais TEXT,
  telefono TEXT,
  email TEXT,
  sitio_web TEXT
);

-- =====================
-- Medicamentos
-- =====================
DROP TABLE IF EXISTS ingrediente_activo CASCADE;
DROP TABLE IF EXISTS presentacion_medicamento CASCADE;
DROP TABLE IF EXISTS medicamento CASCADE;

CREATE TABLE medicamento (
  id_med INT PRIMARY KEY,
  nom_med TEXT NOT NULL,
  id_lab INT,
  id_via INT,
  id_cat INT,
  id_especie INT
);

CREATE TABLE presentacion_medicamento (
  id_presxmed INT PRIMARY KEY,
  id_pres INT,
  cantidad NUMERIC,
  id_um INT,
  id_med INT,
  id_forma INT
);

CREATE TABLE ingrediente_activo (
  id_presxmed INT,
  id_comp INT,
  cantidad NUMERIC,
  id_um INT,
  id_comxu INT,
  PRIMARY KEY (id_presxmed, id_comp)
);

-- =====================
-- Presentaciones
-- =====================
CREATE TABLE presentacion (
  id_pres INT PRIMARY KEY,
  nom_pres TEXT NOT NULL,
  descripcion TEXT
);

-- Relación presentacion-medicamento (tu CSV tiene 6 columnas)




-- =========================================
-- STAGING TABLES (RAW) para limpiar CSV sucio
-- =========================================

-- Para presentacion_medicamento (por si trae N/E o decimales con coma)
CREATE TABLE presentacion_medicamento_raw (
  id_presxmed TEXT,
  id_pres TEXT,
  cantidad TEXT,
  id_um TEXT,
  id_med TEXT,
  id_forma TEXT
);

-- Para ingrediente_activo (aquí sabemos que trae "2,5" y "N/E")
CREATE TABLE ingrediente_activo_raw (
  id_presxmed TEXT,
  id_comp TEXT,
  cantidad TEXT,
  id_um TEXT,
  id_comxu TEXT
);
