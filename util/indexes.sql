CREATE EXTENSION If NOT EXISTS pg_trgm;

CREATE INDEX patient_resource_name_ilike_idx ON patient using gin (string_join(knife_extract_text(resource, '[["name","given"], ["name","family"]]')) gin_trgm_ops);

CREATE INDEX idx_observation_resource ON observation USING GIN ((resource) jsonb_path_ops);

-- actually previous index is better, but knife extract text is used in query =/
CREATE INDEX observation_resource_subject_id_text ON observation (knife_extract_text(observation.resource, '[["subject", "id"]]'));
