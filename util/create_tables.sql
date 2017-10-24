DROP TABLE IF EXISTS first_names;
DROP TABLE IF EXISTS last_names;
DROP TABLE IF EXISTS languages;
DROP TABLE IF EXISTS street_names;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS organization_names;
DROP TABLE IF EXISTS common_observations;

CREATE TABLE first_names (
  id SERIAL PRIMARY KEY,
  sex text,
  first_name text
);

CREATE TABLE last_names (
  id SERIAL PRIMARY KEY,
  last_name text
);

CREATE TABLE languages (
  code text,
  name text
);

CREATE TABLE street_names (
  street_name text
);

CREATE TABLE cities (
  zip text,
  state text,
  city text,
  latitude float,
  longitude float
);

CREATE TABLE organization_names (
  organization_name text
);

CREATE TABLE common_observations (
  id text,
  long_name text,
  short_name text,
  class_name text,
  rank int
);

\echo 'Create loading fake date function: "load_dummy_data(_directory_ TEXT)".'
DROP FUNCTION IF EXISTS load_dummy_data(_directory_ TEXT) CASCADE;
CREATE OR REPLACE FUNCTION load_dummy_data(_directory_ TEXT)
RETURNS void AS $$
  BEGIN
    -- RAISE NOTICE 'Load fake "first_names".';
    EXECUTE 'COPY first_names (sex, first_name) FROM ''' || _directory_ || '/first_names.csv''';

    -- RAISE NOTICE 'Load fake "last_names".';
    EXECUTE 'COPY last_names (last_name) FROM ''' || _directory_ || '/last_names.csv''';

    -- RAISE NOTICE 'Load fake "languages".';
    EXECUTE 'COPY languages (code, name) FROM ''' || _directory_ || '/language-codes-iso-639-1-alpha-2.csv'' WITH csv';

    -- RAISE NOTICE 'Load fake "street_names".';
    EXECUTE 'COPY street_names (street_name) FROM ''' || _directory_ || '/street_names.csv''';

    -- RAISE NOTICE 'Load fake "cities".';
    EXECUTE 'COPY cities (zip, state, city, latitude, longitude) FROM ''' || _directory_ || '/cities.csv'' WITH csv';

    -- RAISE NOTICE 'Load fake "organization_names".';
    EXECUTE 'COPY organization_names (organization_name) FROM ''' || _directory_ || '/organization_names.csv''';

    -- RAISE NOTICE 'Load fake "common_observations".';
    EXECUTE 'COPY common_observations (id, long_name, short_name, class_name, rank) FROM ''' || _directory_ || '/loinc_top2000.csv''  CSV HEADER';
  END
$$ LANGUAGE plpgsql;

SELECT load_dummy_data('/seed-data');

CREATE TABLE IF NOT EXISTS db_sizes (
       relation text,
       sizes jsonb,
       run bigint,
       ts timestamp with time zone DEFAULT now(),
       UNIQUE (relation, run)
);

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS jsonknife;

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
