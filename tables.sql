CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE extension IF NOT EXISTS jsonknife;
CREATE EXTENSION If NOT EXISTS pg_trgm;

-- hack to make array_to_string immutble
CREATE OR REPLACE FUNCTION string_join(a text[])
RETURNS text AS $$
  SELECT ' ' || array_to_string(a, ' ');
$$ LANGUAGE sql IMMUTABLE
COST 1;

DROP TYPE resource_status CASCADE;
CREATE TYPE resource_status AS ENUM ('created', 'updated', 'deleted');

DROP TABLE IF EXISTS patient;
CREATE TABLE patient (
    id text PRIMARY KEY,
    txid bigint NOT NULL,
    ts timestamp with time zone DEFAULT now(),
    resource_type text DEFAULT 'Patient'::text,
    status resource_status NOT NULL,
    resource jsonb NOT NULL
);

DROP SEQUENCE patient_id;
CREATE SEQUENCE patient_id;

CREATE INDEX patient_resource_name_ilike_idx ON patient using gin (string_join(knife_extract_text(resource, '[["name","given"], ["name","family"]]')) gin_trgm_ops);

ALTER TABLE patient OWNER TO postgres;

DROP TABLE IF EXISTS observation;
CREATE TABLE observation (
    id text PRIMARY KEY,
    txid bigint NOT NULL,
    ts timestamp with time zone DEFAULT now(),
    resource_type text DEFAULT 'Observation'::text,
    status resource_status NOT NULL,
    resource jsonb NOT NULL
);

DROP SEQUENCE observation_id;
CREATE SEQUENCE observation_id;

CREATE INDEX idx_observation_resource ON observation USING GIN ((resource) jsonb_path_ops);

-- actually previous index is better, but knife extract text is used in query =/
CREATE INDEX observation_resource_subject_id_text ON observation USING btree (knife_extract_text(observation.resource, '[["subject", "id"]]'));

ALTER TABLE observation OWNER TO postgres;

DROP TABLE IF EXISTS medicationstatement;
CREATE TABLE medicationstatement (
    id text PRIMARY KEY,
    txid bigint NOT NULL,
    ts timestamp with time zone DEFAULT now(),
    resource_type text DEFAULT 'MedicationStatement'::text,
    status resource_status NOT NULL,
    resource jsonb NOT NULL
);

DROP SEQUENCE medicationstatement_id;
CREATE SEQUENCE medicationstatement_id;

CREATE INDEX idx_medicationstatement_resource ON medicationstatement USING GIN ((resource) jsonb_path_ops);
ALTER TABLE medicationstatement OWNER TO postgres;
