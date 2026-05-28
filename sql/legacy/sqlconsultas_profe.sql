-- ================================
-- VetCare / Paw Hospital
-- Consultas para el profe (JOINs)
-- ================================

-- 0) Verificación rápida de carga
SELECT
  (SELECT COUNT(*) FROM categoria)             AS categorias,
  (SELECT COUNT(*) FROM especie)               AS especies,
  (SELECT COUNT(*) FROM pais)                  AS paises,
  (SELECT COUNT(*) FROM laboratorio)           AS laboratorios,
  (SELECT COUNT(*) FROM medicamento)           AS medicamentos,
  (SELECT COUNT(*) FROM presentacion)          AS presentaciones,
  (SELECT COUNT(*) FROM unidad_medida)         AS unidades_medida,
  (SELECT COUNT(*) FROM forma_farmaceutica)    AS formas_farmaceuticas,
  (SELECT COUNT(*) FROM via_administracion)    AS vias,
  (SELECT COUNT(*) FROM presentacion_medicamento) AS pres_med,
  (SELECT COUNT(*) FROM ingrediente_activo)    AS ingredientes,
  (SELECT COUNT(*) FROM vacuna)                AS vacunas,
  (SELECT COUNT(*) FROM enfermedad)            AS enfermedades;

-- 1) Medicamentos con detalle completo (catálogo “bonito”)
SELECT
  m.id_med,
  m.nom_med,
  l.nom_lab AS laboratorio,
  p.nom_pais AS pais_laboratorio,
  va.nom_via AS via,
  c.nom_cat AS categoria,
  e.nom_especie AS especie
FROM medicamento m
JOIN laboratorio l ON l.id_lab = m.id_lab
LEFT JOIN pais p ON p.id_pais = l.id_pais
JOIN via_administracion va ON va.id_via = m.id_via
JOIN categoria c ON c.id_cat = m.id_cat
JOIN especie e ON e.id_especie = m.id_especie
ORDER BY m.id_med
LIMIT 25;

-- 2) Top laboratorios por cantidad de medicamentos
SELECT
  l.id_lab,
  l.nom_lab,
  COUNT(*) AS total_medicamentos
FROM medicamento m
JOIN laboratorio l ON l.id_lab = m.id_lab
GROUP BY l.id_lab, l.nom_lab
ORDER BY total_medicamentos DESC, l.nom_lab;

-- 3) Medicamentos por especie (conteo)
SELECT
  e.nom_especie AS especie,
  COUNT(*) AS total_medicamentos
FROM medicamento m
JOIN especie e ON e.id_especie = m.id_especie
GROUP BY e.nom_especie
ORDER BY total_medicamentos DESC, especie;

-- 4) Medicamentos por categoría (conteo)
SELECT
  c.nom_cat AS categoria,
  COUNT(*) AS total_medicamentos
FROM medicamento m
JOIN categoria c ON c.id_cat = m.id_cat
GROUP BY c.nom_cat
ORDER BY total_medicamentos DESC, categoria;

-- 5) Medicamentos por vía de administración (conteo)
SELECT
  va.nom_via AS via,
  COUNT(*) AS total_medicamentos
FROM medicamento m
JOIN via_administracion va ON va.id_via = m.id_via
GROUP BY va.nom_via
ORDER BY total_medicamentos DESC, via;

-- 6) Presentaciones disponibles por medicamento (detalle)
SELECT
  m.nom_med,
  pm.id_presxmed,
  pm.cantidad,
  um.nom_um AS unidad,
  pr.nom_pres AS presentacion,
  ff.nom_form AS forma_farmaceutica
FROM presentacion_medicamento pm
JOIN medicamento m ON m.id_med = pm.id_med
JOIN unidad_medida um ON um.id_um = pm.id_um
JOIN presentacion pr ON pr.id_pres = pm.id_pres
JOIN forma_farmaceutica ff ON ff.id_form = pm.id_form
ORDER BY m.nom_med, pm.id_presxmed
LIMIT 50;

-- 7) Ingredientes activos por medicamento (con unidades)
SELECT
  m.nom_med,
  ia.id_presxmed,
  cp.compuxu AS compuesto_por_unidad,
  co.nom_comp AS compuesto,
  ia.cantidad,
  um.nom_um AS unidad
FROM ingrediente_activo ia
JOIN presentacion_medicamento pm ON pm.id_presxmed = ia.id_presxmed
JOIN medicamento m ON m.id_med = pm.id_med
JOIN compuesto co ON co.id_comp = ia.id_comp
JOIN unidad_medida um ON um.id_um = ia.id_um
JOIN compuesto_por_unidad cp ON cp.id_compxu = ia.id_compxu
ORDER BY m.nom_med, ia.id_presxmed, compuesto
LIMIT 50;

-- 8) Medicamentos que NO tienen ingredientes activos registrados (detección)
SELECT
  m.id_med,
  m.nom_med
FROM medicamento m
LEFT JOIN presentacion_medicamento pm ON pm.id_med = m.id_med
LEFT JOIN ingrediente_activo ia ON ia.id_presxmed = pm.id_presxmed
WHERE ia.id_presxmed IS NULL
GROUP BY m.id_med, m.nom_med
ORDER BY m.id_med;

-- 9) Laboratorios por país
SELECT
  p.nom_pais AS pais,
  COUNT(*) AS total_laboratorios
FROM laboratorio l
LEFT JOIN pais p ON p.id_pais = l.id_pais
GROUP BY p.nom_pais
ORDER BY total_laboratorios DESC, pais;

-- 10) Enfermedades por tipo
SELECT
  te.nom_tipo_enf AS tipo_enfermedad,
  COUNT(*) AS total_enfermedades
FROM enfermedad e
LEFT JOIN tipo_enf te ON te.id_tipo_enf = e.id_tipo_enf
GROUP BY te.nom_tipo_enf
ORDER BY total_enfermedades DESC, tipo_enfermedad;

-- 11) Búsqueda tipo “catálogo” (medicamento por texto)
-- Cambia ILIKE '%amo%' por lo que quieras (ej: 'anti', 'vac', etc.)
SELECT
  m.id_med,
  m.nom_med,
  l.nom_lab AS laboratorio,
  c.nom_cat AS categoria
FROM medicamento m
JOIN laboratorio l ON l.id_lab = m.id_lab
JOIN categoria c ON c.id_cat = m.id_cat
WHERE m.nom_med ILIKE '%amo%'
ORDER BY m.nom_med
LIMIT 30;

-- 12) Top 10 medicamentos con más presentaciones registradas
SELECT
  m.nom_med,
  COUNT(pm.id_presxmed) AS total_presentaciones
FROM medicamento m
LEFT JOIN presentacion_medicamento pm ON pm.id_med = m.id_med
GROUP BY m.nom_med
ORDER BY total_presentaciones DESC, m.nom_med
LIMIT 10;
