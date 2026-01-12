-- =========================================
-- 02_import_catalogos.sql (VetCare)
-- Importa CSV -> tablas finales
-- Usa staging para limpiar N/E y coma decimal
-- =========================================

-- 1) País
COPY pais
FROM '/data/catalogos/pais.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 2) Especie
COPY especie
FROM '/data/catalogos/especie.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 3) Categoría (tiene descripción)
COPY categoria(id_cat, nom_cat, descripcion)
FROM '/data/catalogos/categoria.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 4) Forma farmacéutica / vía administración (tiene descripción)
COPY via_administracion(id_via, nom_via, descripcion)
FROM '/data/catalogos/forma_farmaceutica.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 5) Unidad de medida (puede traer N/E en nom_um)
-- Aquí NO lo convertimos a NULL para que no choque con NOT NULL (ya lo quitamos en la tabla)
COPY unidad_medida
FROM '/data/catalogos/unidad_medida.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 6) Compuesto
COPY compuesto
FROM '/data/catalogos/compuesto.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 7) Laboratorio (id_pais es TEXTO en tu CSV)
COPY laboratorio
FROM '/data/catalogos/laboratorio.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 8) Medicamento
COPY medicamento
FROM '/data/catalogos/medicamento.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- 9) Presentación (tiene Descripcion)
COPY presentacion(id_pres, nom_pres, descripcion)
FROM '/data/catalogos/presentacion.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- =========================================
-- 10) presentacion_medicamento (STAGING -> FINAL)
-- CSV: id_presxmed,id_pres,cantidad,id_um,id_med,id_forma
-- cantidad puede traer N/E o coma decimal
-- =========================================

-- a) cargar crudo
COPY presentacion_medicamento_raw
FROM '/data/catalogos/presentacion_medicamento.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- b) limpiar e insertar
INSERT INTO presentacion_medicamento (id_presxmed, id_pres, cantidad, id_um, id_med, id_forma)
SELECT
  NULLIF(id_presxmed,'')::INT,
  NULLIF(id_pres,'')::INT,
  CASE
    WHEN cantidad IS NULL OR cantidad = '' OR cantidad = 'N/E' THEN NULL
    ELSE REPLACE(cantidad, ',', '.')::NUMERIC
  END,
  CASE
    WHEN id_um IS NULL OR id_um = '' OR id_um = 'N/E' THEN NULL
    ELSE id_um::INT
  END,
  NULLIF(id_med,'')::INT,
  CASE
    WHEN id_forma IS NULL OR id_forma = '' OR id_forma = 'N/E' THEN NULL
    ELSE id_forma::INT
  END
FROM presentacion_medicamento_raw;

-- =========================================
-- 11) ingrediente_activo (STAGING -> FINAL)
-- CSV: id_presxmed,id_comp,cantidad,id_um,id_comxu
-- cantidad trae N/E y coma decimal (2,5)
-- =========================================

-- a) cargar crudo
COPY ingrediente_activo_raw
FROM '/data/catalogos/ingrediente_activo.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

-- b) limpiar e insertar
INSERT INTO ingrediente_activo (id_presxmed, id_comp, cantidad, id_um, id_comxu)
SELECT DISTINCT ON (id_presxmed_int, id_comp_int)
  id_presxmed_int,
  id_comp_int,
  cantidad_num,
  id_um_int,
  id_comxu_int
FROM (
  SELECT
    NULLIF(id_presxmed,'')::INT AS id_presxmed_int,
    NULLIF(id_comp,'')::INT     AS id_comp_int,

    CASE
      WHEN cantidad IS NULL OR cantidad = '' OR cantidad = 'N/E' THEN NULL
      ELSE REPLACE(cantidad, ',', '.')::NUMERIC
    END AS cantidad_num,

    CASE
      WHEN id_um IS NULL OR id_um = '' OR id_um = 'N/E' THEN NULL
      ELSE id_um::INT
    END AS id_um_int,

    CASE
      WHEN id_comxu IS NULL OR id_comxu = '' OR id_comxu = 'N/E' THEN NULL
      ELSE id_comxu::INT
    END AS id_comxu_int
  FROM ingrediente_activo_raw
) s
WHERE id_presxmed_int IS NOT NULL
  AND id_comp_int IS NOT NULL
ORDER BY id_presxmed_int, id_comp_int, cantidad_num DESC NULLS LAST;


-- (Opcional) limpiar staging para que no estorben
TRUNCATE presentacion_medicamento_raw;
TRUNCATE ingrediente_activo_raw;
