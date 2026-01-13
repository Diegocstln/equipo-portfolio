\echo '=== Importando catálogos CSV ==='

-- OJO: estos nombres/tables vienen del Tablas1.txt del zip.
-- Los CSV están montados en /data/catalogos/

\copy Especie (id_especie, especie)
FROM '/data/catalogos/Book(Especie).csv'
WITH (FORMAT csv, HEADER true);

\copy Raza (id_raza, nom_raza, id_especie)
FROM '/data/catalogos/Book(Raza).csv'
WITH (FORMAT csv, HEADER true);

\copy Temperamento (id_Temperamento, id_especie, Rasgo, Manejo_Recomendado)
FROM '/data/catalogos/Book(Temperamento).csv'
WITH (FORMAT csv, HEADER true);

\copy Tipo_Enf (id_Tipo_Enf, Tipo_Enf)
FROM '/data/catalogos/Book(Tipo_Enf).csv'
WITH (FORMAT csv, HEADER true);

\copy Enfermedades (id_Enfermedad, id_especie, Enfermedad, Agente_Causal, id_Tipo_Enf, Sintomas_enf, Transmision_enf, Tratamiento_enf)
FROM '/data/catalogos/Book(Enfermedades).csv'
WITH (FORMAT csv, HEADER true);

\copy Vacunas (id_vacunas, id_especie, nombre_vacunas, Previene)
FROM '/data/catalogos/Book(Vacunas).csv'
WITH (FORMAT csv, HEADER true);

\copy Laboratorio_Vac (id_LabV, NomLabV)
FROM '/data/catalogos/Book(Laboratorio_Vac).csv'
WITH (FORMAT csv, HEADER true);

\copy LaboratorioDeVac (id_vacunas, id_LabV)
FROM '/data/catalogos/Book(LaboratorioDeVac).csv'
WITH (FORMAT csv, HEADER true);

\echo '=== Listo catálogos ==='
