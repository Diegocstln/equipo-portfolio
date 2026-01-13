
-- ============================================================
-- 0) Parser CSV (respeta comillas y comas dentro de "...")
-- ============================================================
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
      -- Doble comilla escapada dentro de comillas: ""
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


-- ============================================================
-- Util: carga CSV a raw_lines (1 columna) y quita header
-- ============================================================
-- Uso: crea temp table raw_lines; COPY raw_lines FROM 'archivo' FORMAT text;
--      borra primera fila (header) y luego parsea con vetcare_csv_split(line)

-- ============================================================
-- 1) CATEGORIA  (categoria.csv)
--   Esperado en CSV: id_cat, nom_cat, (posibles extras: descripcion...)
-- ============================================================
CREATE TEMP TABLE raw_lines (n BIGSERIAL, line TEXT) ON COMMIT DROP;
COPY raw_lines(line) FROM '/data/catalogos/categoria.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO categoria (id_cat, nom_cat)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (
  SELECT vetcare_csv_split(line) AS v
  FROM raw_lines
) s
ON CONFLICT (id_cat) DO UPDATE SET nom_cat = EXCLUDED.nom_cat;

TRUNCATE raw_lines;


-- ============================================================
-- 2) ESPECIE (especie.csv)
--   CSV: id_especie, especie
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/especie.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO especie (id_especie, nom_especie)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_especie) DO UPDATE
SET nom_especie = EXCLUDED.nom_especie;


TRUNCATE raw_lines;


-- ============================================================
-- 3) PAIS (pais.csv)
--   CSV: id_pais, nom_pais
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/pais.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO pais (id_pais, nom_pais)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_pais) DO UPDATE SET nom_pais = EXCLUDED.nom_pais;

TRUNCATE raw_lines;


-- ============================================================
-- 4) LABORATORIO (laboratorio.csv)
--   CSV típico: id_lab, nom_lab, telefono, email, sitio_web, id_pais, (extras...)
--   Tu tabla: laboratorio(id_lab, nom_lab, telefono_laboratorio, email_laboratorio, sitio_web, id_pais_raw?, id_pais INT)
--   NOTA: si tu laboratorio tiene id_pais_raw (text) y id_pais (int), metemos en id_pais si se puede.
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/laboratorio.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

-- Inserta usando id_pais como INT si viene numérico; si no, lo deja NULL (y luego puedes mapear)
INSERT INTO laboratorio (id_lab, nom_lab, telefono_laboratorio, email_laboratorio, sitio_web, id_pais)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],''),
  NULLIF(v[3],''),
  NULLIF(v[4],''),
  NULLIF(v[5],''),
  CASE WHEN v[6] ~ '^[0-9]+$' THEN v[6]::INT ELSE NULL END
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_lab) DO UPDATE SET
  nom_lab = EXCLUDED.nom_lab,
  telefono_laboratorio = EXCLUDED.telefono_laboratorio,
  email_laboratorio = EXCLUDED.email_laboratorio,
  sitio_web = EXCLUDED.sitio_web,
  id_pais = COALESCE(EXCLUDED.id_pais, laboratorio.id_pais);

TRUNCATE raw_lines;


-- ============================================================
-- 5) PRESENTACION (presentacion.csv)
--   CSV: id_pres, nom_pres
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/presentacion.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO presentacion (id_pres, nom_pres)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_pres) DO UPDATE SET nom_pres = EXCLUDED.nom_pres;

TRUNCATE raw_lines;


-- ============================================================
-- 6) UNIDAD_MEDIDA (unidad_medida.csv)
--   CSV: id_um, um
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/unidad_medida.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO unidad_medida (id_um, um)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_um) DO UPDATE SET um = EXCLUDED.um;

TRUNCATE raw_lines;


-- ============================================================
-- 7) FORMA_FARMACEUTICA (forma_farmaceutica.csv)
--   CSV: id_form, nom_form, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/forma_farmaceutica.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO forma_farmaceutica (id_form, nom_form)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_form) DO UPDATE SET nom_form = EXCLUDED.nom_form;

TRUNCATE raw_lines;


-- ============================================================
-- 8) COMPUESTO (compuesto.csv)
--   CSV: id_comp, nom_comp, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/compuesto.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO compuesto (id_comp, nom_comp)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_comp) DO UPDATE SET nom_comp = EXCLUDED.nom_comp;

TRUNCATE raw_lines;


-- ============================================================
-- 9) COMPUESTO_POR_UNIDAD (unidad_compuesto.csv)
--   En tu BD el catálogo “unidad_compuesto” lo estás manejando como compuesto_por_unidad(id_compxu, compxu)
--   CSV: id_compxu, compxu, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/unidad_compuesto.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO compuesto_por_unidad (id_compxu, compxu)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_compxu) DO UPDATE SET compxu = EXCLUDED.compxu;

TRUNCATE raw_lines;


-- ============================================================
-- 10) MEDICAMENTO (medicamento.csv)
--   CSV típico: id_med, nom_med, id_lab, id_via, id_cat, id_especie, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/medicamento.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO medicamento (id_med, nom_med, id_lab, id_via, id_cat, id_especie)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],''),
  NULLIF(v[3],'')::INT,
  NULLIF(v[4],'')::INT,
  NULLIF(v[5],'')::INT,
  NULLIF(v[6],'')::INT
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_med) DO UPDATE SET
  nom_med = EXCLUDED.nom_med,
  id_lab = EXCLUDED.id_lab,
  id_via = EXCLUDED.id_via,
  id_cat = EXCLUDED.id_cat,
  id_especie = EXCLUDED.id_especie;

TRUNCATE raw_lines;


-- ============================================================
-- 11) PRESENTACION_MEDICAMENTO (presentacion_medicamento.csv)
--   CSV típico: id_presxmed, cantidad, id_med, id_pres, id_um, id_form, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/presentacion_medicamento.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO presentacion_medicamento (id_presxmed, cantidad, id_med, id_pres, id_um, id_form)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')::NUMERIC,
  NULLIF(v[3],'')::INT,
  NULLIF(v[4],'')::INT,
  NULLIF(v[5],'')::INT,
  NULLIF(v[6],'')::INT
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_presxmed) DO UPDATE SET
  cantidad = EXCLUDED.cantidad,
  id_med = EXCLUDED.id_med,
  id_pres = EXCLUDED.id_pres,
  id_um = EXCLUDED.id_um,
  id_form = EXCLUDED.id_form;

TRUNCATE raw_lines;


-- ============================================================
-- 12) INGREDIENTE_ACTIVO (ingrediente_activo.csv)
--   OJO: tu tabla ingrediente_activo tiene columnas:
--     id_presxmed, id_comp, cantidad, id_um, id_compxu
--   CSV típico: id_presxmed, id_comp, cantidad, id_um, id_compxu, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/ingrediente_activo.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

-- Si tu PK real es (id_presxmed,id_comp) como vimos, hacemos UPSERT por esas 2.
INSERT INTO ingrediente_activo (id_presxmed, id_comp, cantidad, id_um, id_compxu)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')::INT,
  NULLIF(v[3],'')::NUMERIC,
  NULLIF(v[4],'')::INT,
  NULLIF(v[5],'')::INT
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_presxmed, id_comp) DO UPDATE SET
  cantidad = EXCLUDED.cantidad,
  id_um = EXCLUDED.id_um,
  id_compxu = EXCLUDED.id_compxu;

TRUNCATE raw_lines;


-- ============================================================
-- 13) RAZA (raza.csv)
--   CSV: id_raza, nom_raza, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/raza.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO raza (id_raza, nom_raza)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_raza) DO UPDATE SET nom_raza = EXCLUDED.nom_raza;

TRUNCATE raw_lines;


-- ============================================================
-- 14) TEMPERAMENTO (temperamento.csv)
--   CSV: id_temp, nom_temp, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/temperamento.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO temperamento (id_temp, nom_temp)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_temp) DO UPDATE SET nom_temp = EXCLUDED.nom_temp;

TRUNCATE raw_lines;


-- ============================================================
-- 15) TIPO_ENF (tipo_Enf.csv)
--   CSV: id_tipo_enf, nom_tipo_enf, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/tipo_Enf.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO tipo_enf (id_tipo_enf, nom_tipo_enf)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_tipo_enf) DO UPDATE SET nom_tipo_enf = EXCLUDED.nom_tipo_enf;

TRUNCATE raw_lines;


-- ============================================================
-- 16) ENFERMEDAD (enfermedades.csv)
--   CSV típico: id_enf, nom_enf, (desc...), id_tipo_enf, (extras...)
--   Como no sabemos cuántas columnas exactas trae, tomamos:
--     v[1]=id_enf, v[2]=nom_enf, y buscamos id_tipo_enf al final si existe.
--   Si el CSV lo tiene en v[3], úsalo; si lo tiene en v[4], también sirve.
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/enfermedades.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO enfermedad (id_enf, nom_enf, id_tipo_enf)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],''),
  CASE
    WHEN array_length(v,1) >= 4 AND v[4] ~ '^[0-9]+$' THEN v[4]::INT
    WHEN array_length(v,1) >= 3 AND v[3] ~ '^[0-9]+$' THEN v[3]::INT
    ELSE NULL
  END
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_enf) DO UPDATE SET
  nom_enf = EXCLUDED.nom_enf,
  id_tipo_enf = COALESCE(EXCLUDED.id_tipo_enf, enfermedad.id_tipo_enf);

TRUNCATE raw_lines;


-- ============================================================
-- 17) VACUNA (vacunas.csv)
--   CSV: id_vacuna, nom_vacuna, (extras...)
-- ============================================================
COPY raw_lines(line) FROM '/data/catalogos/vacunas.csv' WITH (FORMAT text);
DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);

INSERT INTO vacuna (id_vacuna, nom_vacuna)
SELECT
  NULLIF(v[1],'')::INT,
  NULLIF(v[2],'')
FROM (SELECT vetcare_csv_split(line) AS v FROM raw_lines) s
ON CONFLICT (id_vacuna) DO UPDATE SET nom_vacuna = EXCLUDED.nom_vacuna;

TRUNCATE raw_lines;


-- ============================================================
-- 18) Tablas “de vacunas por laboratorio” (si son catálogos puente)
--   Como no sabemos estructura exacta, las cargamos a tablas RAW (si existen).
--   Si tus tablas no existen, puedes ignorar estas partes o crear las tablas.
-- ============================================================

-- laboratorio_Vac.csv -> si tienes tabla laboratorio_vac (ajusta si no)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='laboratorio_vac') THEN
    COPY raw_lines(line) FROM '/data/catalogos/laboratorio_Vac.csv' WITH (FORMAT text);
    DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);
    -- aquí mete tu INSERT real cuando definas columnas
    TRUNCATE raw_lines;
  END IF;
END$$;

-- laboratorioDeVac.csv -> si tienes tabla laboratoriodevac (ajusta si no)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='laboratoriodevac') THEN
    COPY raw_lines(line) FROM '/data/catalogos/laboratorioDeVac.csv' WITH (FORMAT text);
    DELETE FROM raw_lines WHERE n = (SELECT min(n) FROM raw_lines);
    -- aquí mete tu INSERT real cuando definas columnas
    TRUNCATE raw_lines;
  END IF;
END$$;



