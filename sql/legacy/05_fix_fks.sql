BEGIN;

ALTER TABLE enfermedad
  ADD CONSTRAINT fk_enf_tipo
  FOREIGN KEY (id_tipo_enf) REFERENCES tipo_enf(id_tipo_enf);

COMMIT;
