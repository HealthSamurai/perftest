-- Observation MedicationStatement AllergyIntolerance Patient
drop extension pgcrypto;
CREATE EXTENSION pgcrypto;

DROP TYPE resource_status CASCADE;
CREATE TYPE resource_status AS ENUM ('created', 'updated', 'deleted');

DROP TABLE IF EXISTS patient;
CREATE TABLE patient (
    id SERIAL PRIMARY KEY,
    txid bigint NOT NULL,
    ts timestamp with time zone DEFAULT now(),
    resource_type text DEFAULT 'Patient'::text,
    status resource_status NOT NULL,
    resource jsonb NOT NULL
);

ALTER TABLE patient OWNER TO postgres;

DROP TABLE IF EXISTS observation;
CREATE TABLE observation (
    id SERIAL PRIMARY KEY,
    txid bigint NOT NULL,
    ts timestamp with time zone DEFAULT now(),
    resource_type text DEFAULT 'Observation'::text,
    status resource_status NOT NULL,
    resource jsonb NOT NULL
);

CREATE INDEX idx_resource ON observation USING GIN ((resource) jsonb_path_ops);

ALTER TABLE observation OWNER TO postgres;

DROP TABLE IF EXISTS medicationstatement;
CREATE TABLE medicationstatement (
    id SERIAL PRIMARY KEY,
    txid bigint NOT NULL,
    ts timestamp with time zone DEFAULT now(),
    resource_type text DEFAULT 'MedicationStatement'::text,
    status resource_status NOT NULL,
    resource jsonb NOT NULL
);

CREATE INDEX idx_resource ON medicationstatement USING GIN ((resource) jsonb_path_ops);
ALTER TABLE medicationstatement OWNER TO postgres;
