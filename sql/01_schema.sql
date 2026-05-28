-- ==========================================
-- VetCare Master Schema (Híbrido)
-- ==========================================

-- Limpieza previa para reinicio seguro
DROP TABLE IF EXISTS Cama CASCADE;
DROP TABLE IF EXISTS Categoria CASCADE;
DROP TABLE IF EXISTS Citas CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;
DROP TABLE IF EXISTS CodigoPostal CASCADE;
DROP TABLE IF EXISTS Compuesto CASCADE;
DROP TABLE IF EXISTS Compuesto_por_unidad CASCADE;
DROP TABLE IF EXISTS Consultas CASCADE;
DROP TABLE IF EXISTS Departamento CASCADE;
DROP TABLE IF EXISTS DepAsig CASCADE;
DROP TABLE IF EXISTS Diagnostico_Citas CASCADE;
DROP TABLE IF EXISTS Diagnostico_Consultas CASCADE;
DROP TABLE IF EXISTS Domicilio CASCADE;
DROP TABLE IF EXISTS Domicilio_Cliente CASCADE;
DROP TABLE IF EXISTS Empleados CASCADE;
DROP TABLE IF EXISTS EmpleadosXSucur CASCADE;
DROP TABLE IF EXISTS Enfermedades CASCADE;
DROP TABLE IF EXISTS EnfermEnDiagCitas CASCADE;
DROP TABLE IF EXISTS EnfermEnDiagnosticoConsul CASCADE;
DROP TABLE IF EXISTS EnferXmascota CASCADE;
DROP TABLE IF EXISTS Especie CASCADE;
DROP TABLE IF EXISTS Expediente CASCADE;
DROP TABLE IF EXISTS Fecha CASCADE;
DROP TABLE IF EXISTS Forma_Farmaceutica CASCADE;
DROP TABLE IF EXISTS hora_laboral CASCADE;
DROP TABLE IF EXISTS Hospitalizado CASCADE;
DROP TABLE IF EXISTS Ingrediente_Activo CASCADE;
DROP TABLE IF EXISTS Laboratorio CASCADE;
DROP TABLE IF EXISTS Laboratorio_Vac CASCADE;
DROP TABLE IF EXISTS LaboratorioDeVac CASCADE;
DROP TABLE IF EXISTS Mascota CASCADE;
DROP TABLE IF EXISTS Mascota_Especie CASCADE;
DROP TABLE IF EXISTS Medicamento CASCADE;
DROP TABLE IF EXISTS MedicamentoXRecEnCita CASCADE;
DROP TABLE IF EXISTS MedicamentoXRecEnConsul CASCADE;
DROP TABLE IF EXISTS Pais_Laboratorio CASCADE;
DROP TABLE IF EXISTS Presentacion CASCADE;
DROP TABLE IF EXISTS Presentacion_por_medicamento CASCADE;
DROP TABLE IF EXISTS Raza CASCADE;
DROP TABLE IF EXISTS Receta_Cita CASCADE;
DROP TABLE IF EXISTS Receta_Consulta CASCADE;
DROP TABLE IF EXISTS Sucursales CASCADE;
DROP TABLE IF EXISTS Telefono_sucursal CASCADE;
DROP TABLE IF EXISTS Telefonos CASCADE;
DROP TABLE IF EXISTS Temperamento CASCADE;
DROP TABLE IF EXISTS Tipo_Enf CASCADE;
DROP TABLE IF EXISTS Unidad_de_Medida CASCADE;
DROP TABLE IF EXISTS Vacunas CASCADE;
DROP TABLE IF EXISTS Vacunas_Expediente CASCADE;
DROP TABLE IF EXISTS ViadeA CASCADE;

-- Tablas de compatibilidad API
DROP TABLE IF EXISTS pais CASCADE;
DROP TABLE IF EXISTS via_administracion CASCADE;
DROP TABLE IF EXISTS unidad_medida CASCADE;
DROP TABLE IF EXISTS presentacion_medicamento CASCADE;
DROP TABLE IF EXISTS ingrediente_activo CASCADE;

-- ==========================================
-- 1. TABLAS CLÍNICAS / SISTEMA BASE
-- ==========================================

CREATE TABLE Categoria (
  id_cat SERIAL NOT NULL, 
  nom_cat VARCHAR(50) NOT NULL, 
  descripcion TEXT,
  PRIMARY KEY (id_cat)
);

CREATE TABLE Especie (
  id_especie SERIAL NOT NULL, 
  especie VARCHAR(50) NOT NULL UNIQUE, 
  nom_especie VARCHAR(50), 
  PRIMARY KEY (id_especie)
);

CREATE TABLE Pais_Laboratorio (
  id_pais SERIAL NOT NULL, 
  nom_pais VARCHAR(100) NOT NULL UNIQUE, 
  PRIMARY KEY (id_pais)
);

-- Tabla duplicada para compatibilidad directa con API
CREATE TABLE pais (
  id_pais INT NOT NULL, 
  nom_pais VARCHAR(100) NOT NULL, 
  PRIMARY KEY (id_pais)
);

CREATE TABLE Laboratorio (
  id_lab SERIAL NOT NULL, 
  nom_lab VARCHAR(100), 
  telefono VARCHAR(50), 
  email VARCHAR(100), 
  sitio_web VARCHAR(200), 
  id_pais INT NOT NULL, 
  telefono_laboratorio VARCHAR(50), 
  email_laboratorio VARCHAR(100), 
  PRIMARY KEY (id_lab)
);

CREATE TABLE ViadeA (
  id_via SERIAL NOT NULL, 
  nom_via VARCHAR(100) NOT NULL, 
  Descripcion_Via VARCHAR(500), 
  PRIMARY KEY (id_via)
);

-- Tabla duplicada para compatibilidad directa con API
CREATE TABLE via_administracion (
  id_via INT NOT NULL, 
  nom_via VARCHAR(100) NOT NULL, 
  descripcion VARCHAR(500), 
  PRIMARY KEY (id_via)
);

CREATE TABLE Forma_Farmaceutica (
  id_form SERIAL NOT NULL, 
  nom_form VARCHAR(100) NOT NULL, 
  PRIMARY KEY (id_form)
);

CREATE TABLE Presentacion (
  id_pres SERIAL NOT NULL, 
  nom_pres VARCHAR(100) NOT NULL, 
  Descripcion TEXT,
  PRIMARY KEY (id_pres)
);

CREATE TABLE Unidad_de_Medida (
  id_UM SERIAL NOT NULL, 
  UM VARCHAR(50) NOT NULL, 
  PRIMARY KEY (id_UM)
);

-- Tabla duplicada para compatibilidad directa con API
CREATE TABLE unidad_medida (
  id_um INT NOT NULL, 
  nom_um VARCHAR(50) NOT NULL, 
  PRIMARY KEY (id_um)
);

CREATE TABLE Compuesto (
  id_comp SERIAL NOT NULL, 
  nom_comp VARCHAR(100) NOT NULL, 
  PRIMARY KEY (id_comp)
);

CREATE TABLE Compuesto_por_unidad (
  id_compxU SERIAL NOT NULL, 
  compxU VARCHAR(30) NOT NULL, 
  PRIMARY KEY (id_compxU)
);

CREATE TABLE Medicamento (
  id_med SERIAL NOT NULL, 
  nom_med VARCHAR(100) NOT NULL, 
  id_via INT NOT NULL, 
  id_lab INT NOT NULL, 
  id_cat INT NOT NULL, 
  id_especie INT NOT NULL, 
  PRIMARY KEY (id_med)
);

CREATE TABLE Presentacion_por_medicamento (
  id_presXmed SERIAL NOT NULL, 
  id_cant NUMERIC NOT NULL, 
  id_med INT NOT NULL, 
  id_pres INT NOT NULL, 
  id_UM INT NOT NULL, 
  id_form INT NOT NULL, 
  PRIMARY KEY (id_presXmed)
);

-- Tabla duplicada para compatibilidad directa con API
CREATE TABLE presentacion_medicamento (
  id_presxmed INT NOT NULL, 
  id_pres INT, 
  cantidad NUMERIC, 
  id_um INT, 
  id_med INT, 
  id_forma INT, 
  PRIMARY KEY (id_presxmed)
);

CREATE TABLE Ingrediente_Activo (
  id_presXmed INT NOT NULL, 
  cant NUMERIC NOT NULL, 
  id_UM INT NOT NULL, 
  id_compxU INT NOT NULL, 
  id_comp INT NOT NULL, 
  PRIMARY KEY (id_presXmed, id_UM, id_compxU, id_comp)
);

-- Tabla duplicada para compatibilidad directa con API
CREATE TABLE ingrediente_activo (
  id_presxmed INT NOT NULL, 
  id_comp INT NOT NULL, 
  cantidad NUMERIC, 
  id_um INT, 
  id_comxu INT, 
  PRIMARY KEY (id_presxmed, id_comp)
);

CREATE TABLE Raza (
  id_raza INT NOT NULL, 
  nom_raza VARCHAR(100) NOT NULL, 
  id_especie INT NOT NULL, 
  PRIMARY KEY (id_raza, id_especie)
);

CREATE TABLE Temperamento (
  id_Temperamento INT NOT NULL, 
  id_especie INT NOT NULL, 
  Rasgo VARCHAR(500), 
  Manejo_Recomendado VARCHAR(1000), 
  PRIMARY KEY (id_Temperamento, id_especie)
);

CREATE TABLE Tipo_Enf (
  id_Tipo_Enf SERIAL NOT NULL, 
  Tipo_Enf VARCHAR(100) NOT NULL, 
  PRIMARY KEY (id_Tipo_Enf)
);

CREATE TABLE Enfermedades (
  id_Enfermedad INT NOT NULL, 
  id_especie INT NOT NULL, 
  Enfermedad VARCHAR(1000) NOT NULL, 
  Agente_Causal VARCHAR(200), 
  id_Tipo_Enf INT, 
  Sintomas_enf VARCHAR(1000), 
  Transmision_enf VARCHAR(1000), 
  Tratamiento_enf VARCHAR(1000), 
  PRIMARY KEY (id_Enfermedad, id_especie)
);

CREATE TABLE Vacunas (
  id_vacunas SERIAL NOT NULL, 
  id_especie INT NOT NULL, 
  nombre_vacunas VARCHAR(100) NOT NULL, 
  Previene VARCHAR(255) NOT NULL, 
  PRIMARY KEY (id_vacunas)
);

CREATE TABLE Laboratorio_Vac (
  id_LabV SERIAL NOT NULL, 
  NomLabV VARCHAR(100) NOT NULL, 
  PRIMARY KEY (id_LabV)
);

CREATE TABLE LaboratorioDeVac (
  id_vacunas INT NOT NULL, 
  id_LabV INT NOT NULL,
  PRIMARY KEY (id_vacunas, id_LabV)
);

CREATE TABLE Cliente (
  correo VARCHAR(100) NOT NULL, 
  id_cliente SERIAL NOT NULL, 
  contrasena_cliente VARCHAR(100) NOT NULL UNIQUE, 
  cant_mascotas INT NOT NULL, 
  edad_cliente INT NOT NULL, 
  nombre_cliente VARCHAR(50) NOT NULL, 
  apellidoP_cliente VARCHAR(50) NOT NULL, 
  apellidoM_cliente VARCHAR(50) NOT NULL, 
  sexo_cliente VARCHAR(20) NOT NULL, 
  fech_nac_cliente TIMESTAMP NOT NULL, 
  foto_perfil_cliente BYTEA UNIQUE, 
  PRIMARY KEY (id_cliente)
);

CREATE TABLE CodigoPostal (
  codigoP INT NOT NULL, 
  Asentamiento VARCHAR(100) NOT NULL, 
  d_tipo_asenta VARCHAR(50) NOT NULL, 
  Municipio VARCHAR(100) NOT NULL, 
  Estado VARCHAR(100) NOT NULL, 
  id_estado INT NOT NULL, 
  id_tipo_asem INT NOT NULL, 
  id_muni INT NOT NULL, 
  id_asen INT NOT NULL, 
  PRIMARY KEY (codigoP, id_asen)
);

CREATE TABLE Domicilio (
  id_domicilio SERIAL NOT NULL, 
  calle VARCHAR(100) NOT NULL, 
  NumExt INT NOT NULL, 
  NumInt INT, 
  codigoP INT NOT NULL, 
  id_asen INT NOT NULL, 
  PRIMARY KEY (id_domicilio)
);

CREATE TABLE Domicilio_Cliente (
  id_domicilio INT NOT NULL, 
  id_cliente INT NOT NULL, 
  PRIMARY KEY (id_domicilio, id_cliente)
);

CREATE TABLE Empleados (
  id_empleado SERIAL NOT NULL, 
  RFC VARCHAR(20), 
  tipo_empleado VARCHAR(50) NOT NULL, 
  nombre_emp VARCHAR(50) NOT NULL, 
  apellidoM_empleado VARCHAR(50) NOT NULL, 
  apellidoP_empleado VARCHAR(50) NOT NULL, 
  PRIMARY KEY (id_empleado)
);

CREATE TABLE Sucursales (
  id_sucursal SERIAL NOT NULL, 
  nombre_sucursal VARCHAR(100) NOT NULL UNIQUE, 
  Estado_sucursal VARCHAR(50) NOT NULL, 
  Del_sucursal VARCHAR(50) NOT NULL, 
  Colonia_sucursal VARCHAR(50) NOT NULL, 
  calle_sucursal VARCHAR(100) NOT NULL, 
  NumExt_sucursal INT NOT NULL, 
  CodigoPostal_sucursal INT, 
  PRIMARY KEY (id_sucursal)
);

CREATE TABLE Cama (
  id_cama SERIAL NOT NULL, 
  id_sucursal INT NOT NULL, 
  PRIMARY KEY (id_cama)
);

CREATE TABLE Citas (
  id_cita SERIAL NOT NULL, 
  id_cliente INT NOT NULL, 
  id_empleado INT NOT NULL, 
  id_hora INT NOT NULL, 
  id_expediente INT NOT NULL, 
  PRIMARY KEY (id_cita)
);

CREATE TABLE Consultas (
  id_consulta SERIAL NOT NULL, 
  id_expediente INT NOT NULL, 
  id_hora INT NOT NULL, 
  id_empleado INT NOT NULL, 
  PRIMARY KEY (id_consulta)
);

CREATE TABLE Departamento (
  id_Dep SERIAL NOT NULL, 
  Departamento VARCHAR(50) NOT NULL, 
  PRIMARY KEY (id_Dep)
);

CREATE TABLE DepAsig (
  id_empleado INT NOT NULL, 
  id_Dep INT NOT NULL,
  PRIMARY KEY (id_empleado, id_Dep)
);

CREATE TABLE Diagnostico_Citas (
  id_DiagnosticoCitas SERIAL NOT NULL, 
  id_cita INT NOT NULL UNIQUE, 
  PRIMARY KEY (id_DiagnosticoCitas)
);

CREATE TABLE Diagnostico_Consultas (
  id_DiagnosticoCon SERIAL NOT NULL, 
  id_consulta INT NOT NULL UNIQUE, 
  PRIMARY KEY (id_DiagnosticoCon)
);

CREATE TABLE EmpleadosXSucur (
  Sucursalesid_sucursal INT NOT NULL, 
  id_empleado INT NOT NULL, 
  PRIMARY KEY (Sucursalesid_sucursal, id_empleado)
);

CREATE TABLE EnfermEnDiagCitas (
  id_DiagnosticoCitas INT NOT NULL, 
  id_Enfermedad INT NOT NULL, 
  id_especie INT NOT NULL,
  PRIMARY KEY (id_DiagnosticoCitas, id_Enfermedad, id_especie)
);

CREATE TABLE EnfermEnDiagnosticoConsul (
  id_Enfermedad INT NOT NULL, 
  id_Diagnostico INT NOT NULL, 
  id_especie INT NOT NULL, 
  PRIMARY KEY (id_Enfermedad, id_Diagnostico, id_especie)
);

CREATE TABLE EnferXmascota (
  id_mascota INT NOT NULL, 
  id_especie INT NOT NULL, 
  id_Enfermedad INT NOT NULL,
  PRIMARY KEY (id_mascota, id_especie, id_Enfermedad)
);

CREATE TABLE Expediente (
  id_expediente SERIAL NOT NULL, 
  id_mascota INT NOT NULL, 
  PRIMARY KEY (id_expediente)
);

CREATE TABLE Fecha (
  id_fecha SERIAL NOT NULL, 
  fecha TIMESTAMP NOT NULL, 
  id_empleado INT NOT NULL, 
  PRIMARY KEY (id_fecha)
);

CREATE TABLE hora_laboral (
  id_hora SERIAL NOT NULL, 
  hora_inicio TIME NOT NULL, 
  hora_fin TIME NOT NULL, 
  id_fecha INT NOT NULL, 
  PRIMARY KEY (id_hora)
);

CREATE TABLE Hospitalizado (
  id_sucursal INT NOT NULL, 
  id_cama INT NOT NULL, 
  id_mascota INT NOT NULL, 
  PRIMARY KEY (id_sucursal, id_cama, id_mascota)
);

CREATE TABLE Mascota (
  id_mascota SERIAL NOT NULL, 
  nombre VARCHAR(100), 
  alto NUMERIC NOT NULL, 
  largo NUMERIC NOT NULL, 
  ancho NUMERIC NOT NULL, 
  peso NUMERIC NOT NULL, 
  sexo VARCHAR(20) NOT NULL, 
  fech_nac TIMESTAMP NOT NULL, 
  RUAC VARCHAR(20) UNIQUE, 
  esterilizado VARCHAR(5) NOT NULL, 
  largo_pelaje NUMERIC, 
  senas_parti VARCHAR(255), 
  imagen BYTEA UNIQUE, 
  id_cliente INT NOT NULL, 
  PRIMARY KEY (id_mascota)
);

CREATE TABLE Mascota_Especie (
  id_mascota INT NOT NULL, 
  id_especie INT NOT NULL, 
  PRIMARY KEY (id_mascota, id_especie)
);

CREATE TABLE MedicamentoXRecEnCita (
  id_RecetaCita INT NOT NULL, 
  id_med INT NOT NULL, 
  Dosis_cita VARCHAR(50) NOT NULL, 
  Frecuencia_cita VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_RecetaCita, id_med)
);

CREATE TABLE MedicamentoXRecEnConsul (
  id_RecetaCon INT NOT NULL, 
  id_med INT NOT NULL, 
  Dosis_Con INT NOT NULL, 
  Frecuencia_Con VARCHAR(100) NOT NULL, 
  PRIMARY KEY (id_RecetaCon, id_med)
);

CREATE TABLE Receta_Cita (
  id_RecetaCita SERIAL NOT NULL, 
  id_DiagnosticoCitas INT NOT NULL UNIQUE, 
  PRIMARY KEY (id_RecetaCita)
);

CREATE TABLE Receta_Consulta (
  id_Receta SERIAL NOT NULL, 
  id_DiagnosticoCon INT NOT NULL UNIQUE, 
  PRIMARY KEY (id_Receta)
);

CREATE TABLE Telefono_sucursal (
  id_telSuc SERIAL NOT NULL, 
  telefono_suc VARCHAR(30), 
  id_sucursal INT NOT NULL UNIQUE, 
  PRIMARY KEY (id_telSuc)
);

CREATE TABLE Telefonos (
  id_telefono SERIAL NOT NULL, 
  telefono VARCHAR(30), 
  id_cliente INT NOT NULL, 
  PRIMARY KEY (id_telefono)
);

CREATE TABLE Vacunas_Expediente (
  id_vacunas INT NOT NULL, 
  id_expediente INT NOT NULL, 
  PRIMARY KEY (id_vacunas, id_expediente)
);
