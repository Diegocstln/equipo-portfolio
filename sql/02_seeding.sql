-- ==========================================
-- VetCare CSV Data Seeding & Cleanup
-- ==========================================

\echo '=== Iniciando importación y limpieza de catálogos ==='

-- ==========================================
-- 1. Especie
-- ==========================================
CREATE TEMP TABLE staging_especie (
  id_especie TEXT,
  nom_especie TEXT
) ON COMMIT DROP;

COPY staging_especie FROM '/data/catalogos/especie.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Especie (id_especie, especie, nom_especie)
SELECT 
  id_especie::INT, 
  nom_especie, 
  nom_especie
FROM staging_especie
ON CONFLICT (id_especie) DO NOTHING;

-- ==========================================
-- 2. Raza
-- ==========================================
CREATE TEMP TABLE staging_raza (
  id_raza TEXT,
  nom_raza TEXT,
  id_especie TEXT
) ON COMMIT DROP;

COPY staging_raza FROM '/data/catalogos/raza.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Raza (id_raza, nom_raza, id_especie)
SELECT 
  id_raza::INT, 
  nom_raza, 
  id_especie::INT
FROM staging_raza
ON CONFLICT (id_raza, id_especie) DO NOTHING;

-- ==========================================
-- 3. Categoría
-- ==========================================
CREATE TEMP TABLE staging_categoria (
  id_cat TEXT,
  nom_cat TEXT,
  descripcion TEXT
) ON COMMIT DROP;

COPY staging_categoria FROM '/data/catalogos/categoria.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Categoria (id_cat, nom_cat, descripcion)
SELECT 
  id_cat::INT, 
  nom_cat, 
  NULLIF(descripcion, '')
FROM staging_categoria
ON CONFLICT (id_cat) DO NOTHING;

-- ==========================================
-- 4. Vías / Forma Farmacéutica
-- ==========================================
CREATE TEMP TABLE staging_forma (
  id_forma TEXT,
  nom_forma TEXT,
  descripcion TEXT
) ON COMMIT DROP;

COPY staging_forma FROM '/data/catalogos/forma_farmaceutica.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO ViadeA (id_via, nom_via, Descripcion_Via)
SELECT 
  id_forma::INT, 
  nom_forma, 
  NULLIF(descripcion, '')
FROM staging_forma
ON CONFLICT (id_via) DO NOTHING;

INSERT INTO via_administracion (id_via, nom_via, descripcion)
SELECT 
  id_forma::INT, 
  nom_forma, 
  NULLIF(descripcion, '')
FROM staging_forma
ON CONFLICT (id_via) DO NOTHING;

INSERT INTO Forma_Farmaceutica (id_form, nom_form)
SELECT 
  id_forma::INT, 
  nom_forma
FROM staging_forma
ON CONFLICT (id_form) DO NOTHING;

-- ==========================================
-- 5. Unidad de Medida
-- ==========================================
CREATE TEMP TABLE staging_um (
  id_um TEXT,
  nom_um TEXT
) ON COMMIT DROP;

COPY staging_um FROM '/data/catalogos/unidad_medida.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Unidad_de_Medida (id_UM, UM)
SELECT 
  id_um::INT, 
  COALESCE(NULLIF(nom_um, ''), 'N/E')
FROM staging_um
ON CONFLICT (id_UM) DO NOTHING;

INSERT INTO unidad_medida (id_um, nom_um)
SELECT 
  id_um::INT, 
  COALESCE(NULLIF(nom_um, ''), 'N/E')
FROM staging_um
ON CONFLICT (id_um) DO NOTHING;

-- ==========================================
-- 6. Compuestos & Unidades de Compuesto
-- ==========================================
CREATE TEMP TABLE staging_comp (
  id_comp TEXT,
  nom_comp TEXT
) ON COMMIT DROP;

COPY staging_comp FROM '/data/catalogos/compuesto.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Compuesto (id_comp, nom_comp)
SELECT 
  id_comp::INT, 
  nom_comp
FROM staging_comp
ON CONFLICT (id_comp) DO NOTHING;


CREATE TEMP TABLE staging_compxu (
  id_compxu TEXT,
  compxu TEXT
) ON COMMIT DROP;

COPY staging_compxu FROM '/data/catalogos/unidad_compuesto.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Compuesto_por_unidad (id_compxU, compxU)
SELECT 
  id_compxu::INT, 
  compxu
FROM staging_compxu
ON CONFLICT (id_compxU) DO NOTHING;

-- ==========================================
-- 7. Países
-- ==========================================
CREATE TEMP TABLE staging_pais (
  id_pais TEXT,
  nom_pais TEXT
) ON COMMIT DROP;

COPY staging_pais FROM '/data/catalogos/pais.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Pais_Laboratorio (id_pais, nom_pais)
SELECT 
  id_pais::INT, 
  nom_pais
FROM staging_pais
ON CONFLICT (id_pais) DO NOTHING;

INSERT INTO pais (id_pais, nom_pais)
SELECT 
  id_pais::INT, 
  nom_pais
FROM staging_pais
ON CONFLICT (id_pais) DO NOTHING;

-- ==========================================
-- 8. Laboratorios (Mapeo e Importación Robusta)
-- ==========================================
CREATE TEMP TABLE staging_lab (
  id_lab TEXT,
  nom_lab TEXT,
  id_pais TEXT,
  telefono TEXT,
  email TEXT,
  sitio_web TEXT
) ON COMMIT DROP;

COPY staging_lab FROM '/data/catalogos/laboratorio.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Laboratorio (id_lab, nom_lab, telefono, email, sitio_web, id_pais, telefono_laboratorio, email_laboratorio)
SELECT 
  id_lab::INT, 
  nom_lab, 
  NULLIF(telefono, 'N/D'), 
  NULLIF(email, 'N/D'), 
  NULLIF(sitio_web, 'N/D'), 
  CASE 
    WHEN id_pais ~ '^[0-9]+$' THEN id_pais::INT
    WHEN id_pais LIKE '%México%' THEN 1
    WHEN id_pais LIKE '%Estados Unidos%' THEN 2
    WHEN id_pais LIKE '%Dinamarca%' THEN 3
    WHEN id_pais LIKE '%Alemania%' THEN 4
    WHEN id_pais LIKE '%Francia%' THEN 5
    WHEN id_pais LIKE '%Reino Unido%' THEN 7
    WHEN id_pais LIKE '%Irlanda%' THEN 8
    WHEN id_pais LIKE '%Italia%' THEN 9
    ELSE 1 -- default México
  END,
  NULLIF(telefono, 'N/D'),
  NULLIF(email, 'N/D')
FROM staging_lab
ON CONFLICT (id_lab) DO NOTHING;

-- ==========================================
-- 9. Medicamento
-- ==========================================
CREATE TEMP TABLE staging_med (
  id_med TEXT,
  nom_med TEXT,
  id_lab TEXT,
  id_via TEXT,
  id_cat TEXT,
  id_especie TEXT
) ON COMMIT DROP;

COPY staging_med FROM '/data/catalogos/medicamento.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Medicamento (id_med, nom_med, id_via, id_lab, id_cat, id_especie)
SELECT 
  id_med::INT, 
  nom_med, 
  id_via::INT, 
  id_lab::INT, 
  id_cat::INT, 
  id_especie::INT
FROM staging_med
ON CONFLICT (id_med) DO NOTHING;

-- ==========================================
-- 10. Presentación
-- ==========================================
CREATE TEMP TABLE staging_pres (
  id_pres TEXT,
  nom_pres TEXT,
  descripcion TEXT
) ON COMMIT DROP;

COPY staging_pres FROM '/data/catalogos/presentacion.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Presentacion (id_pres, nom_pres, Descripcion)
SELECT 
  id_pres::INT, 
  nom_pres, 
  NULLIF(descripcion, '')
FROM staging_pres
ON CONFLICT (id_pres) DO NOTHING;

-- ==========================================
-- 11. Presentación por Medicamento (Híbrida)
-- ==========================================
CREATE TEMP TABLE staging_pres_med (
  id_presxmed TEXT,
  id_pres TEXT,
  cantidad TEXT,
  id_um TEXT,
  id_med TEXT,
  id_forma TEXT
) ON COMMIT DROP;

COPY staging_pres_med FROM '/data/catalogos/presentacion_medicamento.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Presentacion_por_medicamento (id_presXmed, id_cant, id_med, id_pres, id_UM, id_form)
SELECT 
  id_presxmed::INT, 
  CASE 
    WHEN cantidad IS NULL OR cantidad = '' OR cantidad = 'N/E' THEN 0
    ELSE REPLACE(cantidad, ',', '.')::NUMERIC 
  END,
  id_med::INT, 
  id_pres::INT, 
  CASE WHEN id_um ~ '^[0-9]+$' THEN id_um::INT ELSE 1 END,
  CASE WHEN id_forma ~ '^[0-9]+$' THEN id_forma::INT ELSE 1 END
FROM staging_pres_med
ON CONFLICT (id_presXmed) DO NOTHING;

INSERT INTO presentacion_medicamento (id_presxmed, id_pres, cantidad, id_um, id_med, id_forma)
SELECT 
  id_presxmed::INT, 
  id_pres::INT, 
  CASE 
    WHEN cantidad IS NULL OR cantidad = '' OR cantidad = 'N/E' THEN NULL 
    ELSE REPLACE(cantidad, ',', '.')::NUMERIC 
  END,
  CASE WHEN id_um ~ '^[0-9]+$' THEN id_um::INT ELSE NULL END,
  id_med::INT, 
  CASE WHEN id_forma ~ '^[0-9]+$' THEN id_forma::INT ELSE NULL END
FROM staging_pres_med
ON CONFLICT (id_presxmed) DO NOTHING;

-- ==========================================
-- 12. Ingrediente Activo (Híbrida)
-- ==========================================
CREATE TEMP TABLE staging_ing_act (
  id_presxmed TEXT,
  id_comp TEXT,
  cantidad TEXT,
  id_um TEXT,
  id_comxu TEXT
) ON COMMIT DROP;

COPY staging_ing_act FROM '/data/catalogos/ingrediente_activo.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Filtramos duplicados que violen llave primaria antes de insertar
INSERT INTO Ingrediente_Activo (id_presXmed, cant, id_UM, id_compxU, id_comp)
SELECT DISTINCT ON (id_presxmed_int, id_comp_int)
  id_presxmed_int,
  cantidad_val,
  id_um_int,
  id_comxu_int,
  id_comp_int
FROM (
  SELECT 
    id_presxmed::INT AS id_presxmed_int,
    id_comp::INT AS id_comp_int,
    CASE 
      WHEN cantidad IS NULL OR cantidad = '' OR cantidad = 'N/E' THEN 0 
      ELSE REPLACE(cantidad, ',', '.')::NUMERIC 
    END AS cantidad_val,
    CASE WHEN id_um ~ '^[0-9]+$' THEN id_um::INT ELSE 1 END AS id_um_int,
    CASE WHEN id_comxu ~ '^[0-9]+$' THEN id_comxu::INT ELSE 1 END AS id_comxu_int
  FROM staging_ing_act
) sub
ON CONFLICT (id_presXmed, id_UM, id_compxU, id_comp) DO NOTHING;

INSERT INTO ingrediente_activo (id_presxmed, id_comp, cantidad, id_um, id_comxu)
SELECT DISTINCT ON (id_presxmed_int, id_comp_int)
  id_presxmed_int,
  id_comp_int,
  cantidad_val,
  id_um_int,
  id_comxu_int
FROM (
  SELECT 
    id_presxmed::INT AS id_presxmed_int,
    id_comp::INT AS id_comp_int,
    CASE 
      WHEN cantidad IS NULL OR cantidad = '' OR cantidad = 'N/E' THEN NULL 
      ELSE REPLACE(cantidad, ',', '.')::NUMERIC 
    END AS cantidad_val,
    CASE WHEN id_um ~ '^[0-9]+$' THEN id_um::INT ELSE NULL END AS id_um_int,
    CASE WHEN id_comxu ~ '^[0-9]+$' THEN id_comxu::INT ELSE NULL END AS id_comxu_int
  FROM staging_ing_act
) sub
ON CONFLICT (id_presxmed, id_comp) DO NOTHING;

-- ==========================================
-- 13. Temperamento
-- ==========================================
CREATE TEMP TABLE staging_temp (
  id_temperamento TEXT,
  id_especie TEXT,
  rasgo TEXT,
  manejo TEXT
) ON COMMIT DROP;

COPY staging_temp FROM '/data/catalogos/temperamento.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Temperamento (id_Temperamento, id_especie, Rasgo, Manejo_Recomendado)
SELECT 
  id_temperamento::INT, 
  id_especie::INT, 
  rasgo, 
  manejo
FROM staging_temp
ON CONFLICT (id_Temperamento, id_especie) DO NOTHING;

-- ==========================================
-- 14. Tipo Enfermedad
-- ==========================================
CREATE TEMP TABLE staging_tipo_enf (
  id_tipo_enf TEXT,
  tipo_enf TEXT
) ON COMMIT DROP;

COPY staging_tipo_enf FROM '/data/catalogos/tipo_Enf.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Tipo_Enf (id_Tipo_Enf, Tipo_Enf)
SELECT 
  id_tipo_enf::INT, 
  tipo_enf
FROM staging_tipo_enf
ON CONFLICT (id_Tipo_Enf) DO NOTHING;

-- ==========================================
-- 15. Enfermedades
-- ==========================================
CREATE TEMP TABLE staging_enf (
  id_enfermedad TEXT,
  id_especie TEXT,
  enfermedad TEXT,
  agente TEXT,
  tipo_enf TEXT,
  sintomas TEXT,
  transmision TEXT,
  tratamiento TEXT
) ON COMMIT DROP;

COPY staging_enf FROM '/data/catalogos/enfermedades.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Enfermedades (id_Enfermedad, id_especie, Enfermedad, Agente_Causal, id_Tipo_Enf, Sintomas_enf, Transmision_enf, Tratamiento_enf)
SELECT 
  id_enfermedad::INT, 
  id_especie::INT, 
  enfermedad, 
  NULLIF(agente, 'NULL'), 
  CASE WHEN tipo_enf ~ '^[0-9]+$' THEN tipo_enf::INT ELSE NULL END, 
  NULLIF(sintomas, 'NULL'), 
  NULLIF(transmision, 'NULL'), 
  NULLIF(tratamiento, 'NULL')
FROM staging_enf
ON CONFLICT (id_Enfermedad, id_especie) DO NOTHING;

-- ==========================================
-- 16. Vacunas
-- ==========================================
CREATE TEMP TABLE staging_vac (
  id_vacunas TEXT,
  id_especie TEXT,
  nombre_vacunas TEXT,
  previene TEXT
) ON COMMIT DROP;

COPY staging_vac FROM '/data/catalogos/vacunas.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Vacunas (id_vacunas, id_especie, nombre_vacunas, Previene)
SELECT 
  id_vacunas::INT, 
  id_especie::INT, 
  nombre_vacunas, 
  previene
FROM staging_vac
ON CONFLICT (id_vacunas) DO NOTHING;

-- ==========================================
-- 17. Laboratorio de Vacunas
-- ==========================================
CREATE TEMP TABLE staging_lab_vac (
  id_labv TEXT,
  nom_labv TEXT
) ON COMMIT DROP;

COPY staging_lab_vac FROM '/data/catalogos/laboratorio_Vac.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO Laboratorio_Vac (id_LabV, NomLabV)
SELECT 
  id_labv::INT, 
  nom_labv
FROM staging_lab_vac
ON CONFLICT (id_LabV) DO NOTHING;


CREATE TEMP TABLE staging_lab_de_vac (
  id_vacunas TEXT,
  id_labv TEXT
) ON COMMIT DROP;

COPY staging_lab_de_vac FROM '/data/catalogos/laboratorioDeVac.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO LaboratorioDeVac (id_vacunas, id_LabV)
SELECT 
  id_vacunas::INT, 
  id_labv::INT
FROM staging_lab_de_vac
ON CONFLICT (id_vacunas, id_LabV) DO NOTHING;

-- ==========================================
-- 18. APLICACIÓN DE LLAVES FORÁNEAS (Post-Seeding)
-- ==========================================
\echo '=== Aplicando restricciones de llaves foráneas ==='

ALTER TABLE Raza ADD CONSTRAINT FKRaza_Especie FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Laboratorio ADD CONSTRAINT FKLab_Pais FOREIGN KEY (id_pais) REFERENCES Pais_Laboratorio (id_pais);
ALTER TABLE Medicamento ADD CONSTRAINT FKMed_Especie FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Medicamento ADD CONSTRAINT FKMed_Cat FOREIGN KEY (id_cat) REFERENCES Categoria (id_cat);
ALTER TABLE Medicamento ADD CONSTRAINT FKMed_Via FOREIGN KEY (id_via) REFERENCES ViadeA (id_via);
ALTER TABLE Medicamento ADD CONSTRAINT FKMed_Lab FOREIGN KEY (id_lab) REFERENCES Laboratorio (id_lab);

ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPpm_Med FOREIGN KEY (id_med) REFERENCES Medicamento (id_med);
ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPpm_Pres FOREIGN KEY (id_pres) REFERENCES Presentacion (id_pres);
ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPpm_UM FOREIGN KEY (id_UM) REFERENCES Unidad_de_Medida (id_UM);
ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPpm_Form FOREIGN KEY (id_form) REFERENCES Forma_Farmaceutica (id_form);

ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIa_PresXmed FOREIGN KEY (id_presXmed) REFERENCES Presentacion_por_medicamento (id_presXmed);
ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIa_UM FOREIGN KEY (id_UM) REFERENCES Unidad_de_Medida (id_UM);
ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIa_CompXU FOREIGN KEY (id_compxU) REFERENCES Compuesto_por_unidad (id_compxU);
ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIa_Comp FOREIGN KEY (id_comp) REFERENCES Compuesto (id_comp);

ALTER TABLE Temperamento ADD CONSTRAINT FKTemp_Especie FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Enfermedades ADD CONSTRAINT FKEnf_Tipo FOREIGN KEY (id_Tipo_Enf) REFERENCES Tipo_Enf (id_Tipo_Enf);
ALTER TABLE Enfermedades ADD CONSTRAINT FKEnf_Especie FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Vacunas ADD CONSTRAINT FKVac_Especie FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);

ALTER TABLE LaboratorioDeVac ADD CONSTRAINT FKLabDeVac_LabV FOREIGN KEY (id_LabV) REFERENCES Laboratorio_Vac (id_LabV);
ALTER TABLE LaboratorioDeVac ADD CONSTRAINT FKLabDeVac_Vac FOREIGN KEY (id_vacunas) REFERENCES Vacunas (id_vacunas);

\echo '=== Importación y seeding completados con éxito ==='
