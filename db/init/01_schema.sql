CREATE TABLE Cama (
  id_cama     SERIAL NOT NULL, 
  id_sucursal int4 NOT NULL, 
  PRIMARY KEY (id_cama));
CREATE TABLE Categoria (
  id_cat  SERIAL NOT NULL, 
  nom_cat varchar(20), 
  PRIMARY KEY (id_cat));
CREATE TABLE Citas (
  id_cita       SERIAL NOT NULL, 
  id_cliente    int4 NOT NULL, 
  id_empleado   int4 NOT NULL, 
  id_hora       int4 NOT NULL, 
  id_expediente int4 NOT NULL, 
  PRIMARY KEY (id_cita));
CREATE TABLE Cliente (
  correo              varchar(50) NOT NULL, 
  id_cliente          SERIAL NOT NULL, 
  contrasena_cliente  varchar(20) NOT NULL UNIQUE, 
  cant_mascotas       int4 NOT NULL, 
  edad_cliente        int4 NOT NULL, 
  nombre_cliente      varchar(50) NOT NULL, 
  apellidoP_cliente   varchar(50) NOT NULL, 
  apellidoM_cliente   varchar(50) NOT NULL, 
  sexo_cliente        varchar(9) NOT NULL, 
  fech_nac_cliente    timestamp NOT NULL, 
  foto_perfil_cliente bytea UNIQUE, 
  PRIMARY KEY (id_cliente));
CREATE TABLE CodigoPostal (
  codigoP       int4 NOT NULL, 
  Asentamiento  varchar(100) NOT NULL, 
  d_tipo_asenta varchar(50) NOT NULL, 
  Municipio     varchar(100) NOT NULL, 
  Estado        varchar(100) NOT NULL, 
  id_estado     int4 NOT NULL, 
  id_tipo_asem  int4 NOT NULL, 
  id_muni       int4 NOT NULL, 
  id_asen       int4 NOT NULL, 
  PRIMARY KEY (codigoP, 
  id_asen));
CREATE TABLE Compuesto (
  id_comp  SERIAL NOT NULL, 
  nom_comp varchar(50) NOT NULL, 
  PRIMARY KEY (id_comp));
CREATE TABLE Compuesto_por_unidad (
  id_compxU SERIAL NOT NULL, 
  compxU    varchar(20) NOT NULL, 
  PRIMARY KEY (id_compxU));
CREATE TABLE Consultas (
  id_consulta   SERIAL NOT NULL, 
  id_expediente int4 NOT NULL, 
  id_hora       int4 NOT NULL, 
  id_empleado   int4 NOT NULL, 
  PRIMARY KEY (id_consulta));
CREATE TABLE Departamento (
  id_Dep       SERIAL NOT NULL, 
  Departamento varchar(20) NOT NULL, 
  PRIMARY KEY (id_Dep));
CREATE TABLE DepAsig (
  id_empleado int4 NOT NULL, 
  id_Dep      int4 NOT NULL);
CREATE TABLE Diagnostico_Citas (
  id_DiagnosticoCitas SERIAL NOT NULL, 
  id_cita             int4 NOT NULL UNIQUE, 
  PRIMARY KEY (id_DiagnosticoCitas));
CREATE TABLE Diagnostico_Consultas (
  id_DiagnosticoCon SERIAL NOT NULL, 
  id_consulta       int4 NOT NULL UNIQUE, 
  PRIMARY KEY (id_DiagnosticoCon));
CREATE TABLE Domicilio (
  id_domicilio SERIAL NOT NULL, 
  calle        varchar(50) NOT NULL, 
  NumExt       int4 NOT NULL, 
  NumInt       int4, 
  codigoP      int4 NOT NULL, 
  id_asen      int4 NOT NULL, 
  PRIMARY KEY (id_domicilio));
CREATE TABLE Domicilio_Cliente (
  id_domicilio int4 NOT NULL, 
  id_cliente   int4 NOT NULL, 
  PRIMARY KEY (id_domicilio, 
  id_cliente));
CREATE TABLE Empleados (
  id_empleado        SERIAL NOT NULL, 
  RFC                int4, 
  tipo_empleado      varchar(20) NOT NULL, 
  nombre_emp         varchar(50) NOT NULL, 
  apellidoM_empleado varchar(50) NOT NULL, 
  apellidoP_empleado varchar(50) NOT NULL, 
  PRIMARY KEY (id_empleado));
CREATE TABLE EmpleadosXSucur (
  Sucursalesid_sucursal int4 NOT NULL, 
  id_empleado           int4 NOT NULL, 
  PRIMARY KEY (Sucursalesid_sucursal, 
  id_empleado));
CREATE TABLE Enfermedades (
  id_Enfermedad   int4 NOT NULL, 
  id_especie      int4 NOT NULL, 
  Enfermedad      varchar(1000) NOT NULL, 
  Agente_Causal   varchar(200), 
  id_Tipo_Enf     int4, 
  Sintomas_enf    varchar(500), 
  Transmision_enf varchar(500), 
  Tratamiento_enf varchar(500), 
  PRIMARY KEY (id_Enfermedad, 
  id_especie));
CREATE TABLE EnfermEnDiagCitas (
  id_DiagnosticoCitas int4 NOT NULL, 
  id_Enfermedad       int4 NOT NULL, 
  id_especie          int4 NOT NULL);
CREATE TABLE EnfermEnDiagnosticoConsul (
  id_Enfermedad  int4 NOT NULL, 
  id_Diagnostico int4 NOT NULL, 
  id_especie     int4 NOT NULL, 
  PRIMARY KEY (id_Enfermedad, 
  id_Diagnostico, 
  id_especie));
CREATE TABLE EnferXmascota (
  id_mascota    int4 NOT NULL, 
  id_especie    int4 NOT NULL, 
  id_Enfermedad int4 NOT NULL);
CREATE TABLE Especie (
  id_especie SERIAL NOT NULL, 
  especie    varchar(10) NOT NULL UNIQUE, 
  PRIMARY KEY (id_especie));
CREATE TABLE Expediente (
  id_expediente SERIAL NOT NULL, 
  id_mascota    int4 NOT NULL, 
  PRIMARY KEY (id_expediente));
CREATE TABLE Fecha (
  id_fecha    SERIAL NOT NULL, 
  fecha       timestamp NOT NULL, 
  id_empleado int4 NOT NULL, 
  PRIMARY KEY (id_fecha));
CREATE TABLE Forma_Farmaceutica (
  id_form  SERIAL NOT NULL, 
  nom_form varchar(30) NOT NULL, 
  PRIMARY KEY (id_form));
CREATE TABLE hora_laboral (
  id_hora     SERIAL NOT NULL, 
  hora_inicio time(7) NOT NULL, 
  hora_fin    time(7) NOT NULL, 
  id_fecha    int4 NOT NULL, 
  PRIMARY KEY (id_hora));
CREATE TABLE Hospitalizado (
  id_sucursal int4 NOT NULL, 
  id_cama     int4 NOT NULL, 
  id_mascota  int4 NOT NULL, 
  PRIMARY KEY (id_sucursal, 
  id_cama, 
  id_mascota));
CREATE TABLE Ingrediente_Activo (
  id_presXmed int4 NOT NULL, 
  cant        float4 NOT NULL, 
  id_UM       int4 NOT NULL, 
  id_compxU   int4 NOT NULL, 
  id_comp     int4 NOT NULL, 
  PRIMARY KEY (id_presXmed, 
  id_UM, 
  id_compxU, 
  id_comp));
CREATE TABLE Laboratorio (
  id_lab               SERIAL NOT NULL, 
  nom_lab              varchar(20), 
  telefono_laboratorio int4, 
  email_laboratorio    int4, 
  sitio_web            int4, 
  id_pais              int4 NOT NULL, 
  PRIMARY KEY (id_lab));
CREATE TABLE Laboratorio_Vac (
  id_LabV SERIAL NOT NULL, 
  NomLabV varchar(30) NOT NULL, 
  PRIMARY KEY (id_LabV));
CREATE TABLE LaboratorioDeVac (
  id_vacunas int4 NOT NULL, 
  id_LabV    int4 NOT NULL);
CREATE TABLE Mascota (
  id_mascota   SERIAL NOT NULL, 
  nombre       varchar(50), 
  alto         float4 NOT NULL, 
  largo        float4 NOT NULL, 
  ancho        float4 NOT NULL, 
  peso         float4 NOT NULL, 
  sexo         varchar(9) NOT NULL, 
  fech_nac     timestamp NOT NULL, 
  RUAC         varchar(13) UNIQUE, 
  esterilizado varchar(2) NOT NULL, 
  largo_pelaje float4, 
  senas_parti  varchar(255), 
  imagen       bytea UNIQUE, 
  id_cliente   int4 NOT NULL, 
  PRIMARY KEY (id_mascota));
CREATE TABLE Mascota_Especie (
  id_mascota int4 NOT NULL, 
  id_especie int4 NOT NULL, 
  PRIMARY KEY (id_mascota, 
  id_especie));
CREATE TABLE Medicamento (
  id_med     SERIAL NOT NULL, 
  nom_med    varchar(20) NOT NULL, 
  id_via     int4 NOT NULL, 
  id_lab     int4 NOT NULL, 
  id_cat     int4 NOT NULL, 
  id_especie int4 NOT NULL, 
  PRIMARY KEY (id_med));
CREATE TABLE MedicamentoXRecEnCita (
  id_RecetaCita   int4 NOT NULL, 
  id_med          int4 NOT NULL, 
  Dosis_cita      varchar(20) NOT NULL, 
  Frecuencia_cita varchar(100) NOT NULL);
CREATE TABLE MedicamentoXRecEnConsul (
  id_RecetaCon   int4 NOT NULL, 
  id_med         int4 NOT NULL, 
  Dosis_Con      int4 NOT NULL, 
  Frecuencia_Con varchar(100) NOT NULL, 
  PRIMARY KEY (id_RecetaCon, 
  id_med));
CREATE TABLE Pais_Laboratorio (
  id_pais  SERIAL NOT NULL, 
  nom_pais int4 NOT NULL UNIQUE, 
  PRIMARY KEY (id_pais));
CREATE TABLE Presentacion (
  id_pres  SERIAL NOT NULL, 
  nom_pres varchar(20) NOT NULL, 
  PRIMARY KEY (id_pres));
CREATE TABLE Presentacion_por_medicamento (
  id_presXmed SERIAL NOT NULL, 
  id_cant     float4 NOT NULL, 
  id_med      int4 NOT NULL, 
  id_pres     int4 NOT NULL, 
  id_UM       int4 NOT NULL, 
  id_form     int4 NOT NULL, 
  PRIMARY KEY (id_presXmed));
CREATE TABLE Raza (
  id_raza    int4 NOT NULL, 
  nom_raza   varchar(100) NOT NULL, 
  id_especie int4 NOT NULL, 
  PRIMARY KEY (id_raza, 
  id_especie));
CREATE TABLE Receta_Cita (
  id_RecetaCita       SERIAL NOT NULL, 
  id_DiagnosticoCitas int4 NOT NULL UNIQUE, 
  PRIMARY KEY (id_RecetaCita));
CREATE TABLE Receta_Consulta (
  id_Receta         SERIAL NOT NULL, 
  id_DiagnosticoCon int4 NOT NULL UNIQUE, 
  PRIMARY KEY (id_Receta));
CREATE TABLE Sucursales (
  id_sucursal           SERIAL NOT NULL, 
  nombre_sucursal       varchar(100) NOT NULL UNIQUE, 
  Estado_sucursal       varchar(50) NOT NULL, 
  Del_sucursal          varchar(50) NOT NULL, 
  Colonia_sucursal      varchar(50) NOT NULL, 
  calle_sucursal        varchar(50) NOT NULL, 
  NumExt_sucursal       int4 NOT NULL, 
  CodigoPostal_sucursal int4, 
  PRIMARY KEY (id_sucursal));
CREATE TABLE Telefono_sucursal (
  id_telSuc    SERIAL NOT NULL, 
  telefono_suc int4, 
  id_sucursal  int4 NOT NULL UNIQUE, 
  PRIMARY KEY (id_telSuc));
CREATE TABLE Telefonos (
  id_telefono SERIAL NOT NULL, 
  telefono    varchar(10), 
  id_cliente  int4 NOT NULL, 
  PRIMARY KEY (id_telefono));
CREATE TABLE Temperamento (
  id_Temperamento    int4 NOT NULL, 
  id_especie         int4 NOT NULL, 
  Rasgo              varchar(200), 
  Manejo_Recomendado varchar(200), 
  PRIMARY KEY (id_Temperamento, 
  id_especie));
CREATE TABLE Tipo_Enf (
  id_Tipo_Enf SERIAL NOT NULL, 
  Tipo_Enf    varchar(40) NOT NULL, 
  PRIMARY KEY (id_Tipo_Enf));
CREATE TABLE Unidad_de_Medida (
  id_UM SERIAL NOT NULL, 
  UM    varchar(20) NOT NULL, 
  PRIMARY KEY (id_UM));
CREATE TABLE Vacunas (
  id_vacunas     SERIAL NOT NULL, 
  id_especie     int4 NOT NULL, 
  nombre_vacunas varchar(50) NOT NULL, 
  Previene       varchar(255) NOT NULL, 
  PRIMARY KEY (id_vacunas));
CREATE TABLE Vacunas_Expediente (
  id_vacunas    int4 NOT NULL, 
  id_expediente int4 NOT NULL, 
  PRIMARY KEY (id_vacunas, 
  id_expediente));
CREATE TABLE ViadeA (
  id_via          SERIAL NOT NULL, 
  nom_via         varchar(20) NOT NULL, 
  Descripcion_Via varchar(255), 
  PRIMARY KEY (id_via));
ALTER TABLE LaboratorioDeVac ADD CONSTRAINT FKLaboratori11631 FOREIGN KEY (id_LabV) REFERENCES Laboratorio_Vac (id_LabV);
ALTER TABLE LaboratorioDeVac ADD CONSTRAINT FKLaboratori363109 FOREIGN KEY (id_vacunas) REFERENCES Vacunas (id_vacunas);
ALTER TABLE Enfermedades ADD CONSTRAINT FKEnfermedad653189 FOREIGN KEY (id_Tipo_Enf) REFERENCES Tipo_Enf (id_Tipo_Enf);
ALTER TABLE DepAsig ADD CONSTRAINT FKDepAsig507903 FOREIGN KEY (id_Dep) REFERENCES Departamento (id_Dep);
ALTER TABLE DepAsig ADD CONSTRAINT FKDepAsig315413 FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado);
ALTER TABLE Vacunas ADD CONSTRAINT FKVacunas744855 FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE EmpleadosXSucur ADD CONSTRAINT FKEmpleadosX263111 FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado);
ALTER TABLE EmpleadosXSucur ADD CONSTRAINT FKEmpleadosX315902 FOREIGN KEY (Sucursalesid_sucursal) REFERENCES Sucursales (id_sucursal);
ALTER TABLE Temperamento ADD CONSTRAINT FKTemperamen968105 FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE EnferXmascota ADD CONSTRAINT FKEnferXmasc897936 FOREIGN KEY (id_Enfermedad, id_especie) REFERENCES Enfermedades (id_Enfermedad, id_especie);
ALTER TABLE Enfermedades ADD CONSTRAINT FKEnfermedad13867 FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Raza ADD CONSTRAINT FKRaza672914 FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Laboratorio ADD CONSTRAINT FKLaboratori653948 FOREIGN KEY (id_pais) REFERENCES Pais_Laboratorio (id_pais);
ALTER TABLE MedicamentoXRecEnCita ADD CONSTRAINT FKMedicament3644 FOREIGN KEY (id_med) REFERENCES Medicamento (id_med);
ALTER TABLE MedicamentoXRecEnCita ADD CONSTRAINT FKMedicament131967 FOREIGN KEY (id_RecetaCita) REFERENCES Receta_Cita (id_RecetaCita);
ALTER TABLE Receta_Cita ADD CONSTRAINT FKReceta_Cit355953 FOREIGN KEY (id_DiagnosticoCitas) REFERENCES Diagnostico_Citas (id_DiagnosticoCitas);
ALTER TABLE EnfermEnDiagCitas ADD CONSTRAINT FKEnfermEnDi557417 FOREIGN KEY (id_Enfermedad, id_especie) REFERENCES Enfermedades (id_Enfermedad, id_especie);
ALTER TABLE EnfermEnDiagCitas ADD CONSTRAINT FKEnfermEnDi806685 FOREIGN KEY (id_DiagnosticoCitas) REFERENCES Diagnostico_Citas (id_DiagnosticoCitas);
ALTER TABLE Diagnostico_Citas ADD CONSTRAINT FKDiagnostic323164 FOREIGN KEY (id_cita) REFERENCES Citas (id_cita);
ALTER TABLE Domicilio ADD CONSTRAINT FKDomicilio819205 FOREIGN KEY (codigoP, id_asen) REFERENCES CodigoPostal (codigoP, id_asen);
ALTER TABLE EnferXmascota ADD CONSTRAINT FKEnferXmasc671907 FOREIGN KEY (id_mascota, id_especie) REFERENCES Mascota_Especie (id_mascota, id_especie);
ALTER TABLE Mascota_Especie ADD CONSTRAINT FKMascota_Es367587 FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Mascota_Especie ADD CONSTRAINT FKMascota_Es812134 FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota);
ALTER TABLE MedicamentoXRecEnConsul ADD CONSTRAINT FKMedicament743654 FOREIGN KEY (id_med) REFERENCES Medicamento (id_med);
ALTER TABLE MedicamentoXRecEnConsul ADD CONSTRAINT FKMedicament29900 FOREIGN KEY (id_RecetaCon) REFERENCES Receta_Consulta (id_Receta);
ALTER TABLE Receta_Consulta ADD CONSTRAINT FKReceta_Con822959 FOREIGN KEY (id_DiagnosticoCon) REFERENCES Diagnostico_Consultas (id_DiagnosticoCon);
ALTER TABLE EnfermEnDiagnosticoConsul ADD CONSTRAINT FKEnfermEnDi117321 FOREIGN KEY (id_Enfermedad, id_especie) REFERENCES Enfermedades (id_Enfermedad, id_especie);
ALTER TABLE EnfermEnDiagnosticoConsul ADD CONSTRAINT FKEnfermEnDi963791 FOREIGN KEY (id_Diagnostico) REFERENCES Diagnostico_Consultas (id_DiagnosticoCon);
ALTER TABLE Diagnostico_Consultas ADD CONSTRAINT FKDiagnostic914566 FOREIGN KEY (id_consulta) REFERENCES Consultas (id_consulta);
ALTER TABLE Vacunas_Expediente ADD CONSTRAINT FKVacunas_Ex695353 FOREIGN KEY (id_expediente) REFERENCES Expediente (id_expediente);
ALTER TABLE Vacunas_Expediente ADD CONSTRAINT FKVacunas_Ex930205 FOREIGN KEY (id_vacunas) REFERENCES Vacunas (id_vacunas);
ALTER TABLE hora_laboral ADD CONSTRAINT FKhora_labor793662 FOREIGN KEY (id_fecha) REFERENCES Fecha (id_fecha);
ALTER TABLE Fecha ADD CONSTRAINT FKFecha670970 FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado);
ALTER TABLE Domicilio_Cliente ADD CONSTRAINT FKDomicilio_403253 FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente);
ALTER TABLE Domicilio_Cliente ADD CONSTRAINT FKDomicilio_73011 FOREIGN KEY (id_domicilio) REFERENCES Domicilio (id_domicilio);
ALTER TABLE Medicamento ADD CONSTRAINT FKMedicament509840 FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);
ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIngredient846299 FOREIGN KEY (id_UM) REFERENCES Unidad_de_Medida (id_UM);
ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIngredient525095 FOREIGN KEY (id_presXmed) REFERENCES Presentacion_por_medicamento (id_presXmed);
ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIngredient232641 FOREIGN KEY (id_comp) REFERENCES Compuesto (id_comp);
ALTER TABLE Ingrediente_Activo ADD CONSTRAINT FKIngredient859970 FOREIGN KEY (id_compxU) REFERENCES Compuesto_por_unidad (id_compxU);
ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPresentaci310439 FOREIGN KEY (id_form) REFERENCES Forma_Farmaceutica (id_form);
ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPresentaci541454 FOREIGN KEY (id_UM) REFERENCES Unidad_de_Medida (id_UM);
ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPresentaci892343 FOREIGN KEY (id_med) REFERENCES Medicamento (id_med);
ALTER TABLE Presentacion_por_medicamento ADD CONSTRAINT FKPresentaci684043 FOREIGN KEY (id_pres) REFERENCES Presentacion (id_pres);
ALTER TABLE Medicamento ADD CONSTRAINT FKMedicament264080 FOREIGN KEY (id_cat) REFERENCES Categoria (id_cat);
ALTER TABLE Medicamento ADD CONSTRAINT FKMedicament445968 FOREIGN KEY (id_via) REFERENCES ViadeA (id_via);
ALTER TABLE Medicamento ADD CONSTRAINT FKMedicament467094 FOREIGN KEY (id_lab) REFERENCES Laboratorio (id_lab);
ALTER TABLE Consultas ADD CONSTRAINT FKConsultas524305 FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado);
ALTER TABLE Citas ADD CONSTRAINT FKCitas736790 FOREIGN KEY (id_expediente) REFERENCES Expediente (id_expediente);
ALTER TABLE Consultas ADD CONSTRAINT FKConsultas404260 FOREIGN KEY (id_expediente) REFERENCES Expediente (id_expediente);
ALTER TABLE Expediente ADD CONSTRAINT FKExpediente676669 FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota);
ALTER TABLE Hospitalizado ADD CONSTRAINT FKHospitaliz221496 FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota);
ALTER TABLE Hospitalizado ADD CONSTRAINT FKHospitaliz254181 FOREIGN KEY (id_cama) REFERENCES Cama (id_cama);
ALTER TABLE Cama ADD CONSTRAINT FKCama759104 FOREIGN KEY (id_sucursal) REFERENCES Sucursales (id_sucursal);
ALTER TABLE Hospitalizado ADD CONSTRAINT FKHospitaliz684645 FOREIGN KEY (id_sucursal) REFERENCES Sucursales (id_sucursal);
ALTER TABLE Citas ADD CONSTRAINT FKCitas306234 FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado);
ALTER TABLE Citas ADD CONSTRAINT FKCitas247524 FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente);
ALTER TABLE Telefono_sucursal ADD CONSTRAINT FKTelefono_s680051 FOREIGN KEY (id_sucursal) REFERENCES Sucursales (id_sucursal);
ALTER TABLE Mascota ADD CONSTRAINT FKMascota241251 FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente);
ALTER TABLE Telefonos ADD CONSTRAINT FKTelefonos698250 FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente);

