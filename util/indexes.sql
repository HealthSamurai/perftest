CREATE EXTENSION If NOT EXISTS pg_trgm;

ALTER TABLE patient ADD PRIMARY KEY(id);
ALTER TABLE observation ADD PRIMARY KEY(id);
ALTER TABLE medicationstatement ADD PRIMARY KEY(id);

CREATE INDEX patient_resource_name_ilike_idx ON patient using gin (string_join(knife_extract_text(resource, '[["name","given"], ["name","family"]]')) gin_trgm_ops);
CREATE INDEX idx_observation_resource ON observation USING GIN ((resource) jsonb_path_ops);
-- actually previous index is better, but knife extract text is used in query =/
CREATE INDEX observation_resource_subject_id_text ON observation (knife_extract_text(observation.resource, '[["subject", "id"]]'));
CREATE INDEX idx_medicationstatement_resource ON medicationstatement USING GIN ((resource) jsonb_path_ops);

-- todo new index #> for id?122
ALTER TABLE patient SET LOGGED;
ALTER TABLE observation SET LOGGED;
ALTER TABLE medicationstatement SET LOGGED;

ANALYZE patient;
ANALYZE observation;
ANALYZE medicationstatement;
