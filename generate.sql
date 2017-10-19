\echo 'Create generation function: "random(a numeric, b numeric)".'
DROP FUNCTION IF EXISTS random(a numeric, b numeric) CASCADE;
CREATE OR REPLACE FUNCTION random(a numeric, b numeric)
RETURNS numeric AS $$
  SELECT ceil(a + (b - a) * random())::numeric;
$$ LANGUAGE SQL;

\echo 'Create generation function: "random_elem(a anyarray)".'
DROP FUNCTION IF EXISTS random_elem(a anyarray) CASCADE;
CREATE OR REPLACE FUNCTION random_elem(a anyarray)
RETURNS anyelement AS $$
  SELECT a[1 + floor(RANDOM() * array_length(a, 1))];
$$ LANGUAGE SQL;

\echo 'Create generation function: "random_date()".'
DROP FUNCTION IF EXISTS random_date() CASCADE;
CREATE OR REPLACE FUNCTION random_date()
RETURNS text AS $$
  SELECT random(1960, 2016)::text
           || '-'
           || lpad(random(1, 12)::text, 2, '0')
           || '-'
           || lpad(random(1, 28)::text, 2, '0');
$$ LANGUAGE SQL;

\echo 'Create generation function: "random_datetime(f)".'
DROP FUNCTION IF EXISTS random_datetime(start_year numeric, end_year numeric) CASCADE;
CREATE OR REPLACE FUNCTION random_datetime(start_year numeric, end_year numeric)
RETURNS text AS $$
SELECT random(start_year, end_year)::text
           || '-'
           || lpad(random(1, 12)::text, 2, '0')
           || '-'
           || lpad(random(1, 28)::text, 2, '0')
           || 'T'
           || random(10,23)
           || ':00:00-07:00';
$$ LANGUAGE SQL;

\echo 'Create generation function: "random_phone()".'
DROP FUNCTION IF EXISTS random_phone() CASCADE;
CREATE OR REPLACE FUNCTION random_phone()
RETURNS text AS $$
  SELECT '+' || random(1, 12)::text ||
         ' (' || random(1, 999)::text || ') ' ||
         lpad(random(1, 999)::text, 3, '0') ||
         '-' ||
         lpad(random(1, 99)::text, 2, '0') ||
         '-' ||
         lpad(random(1, 99)::text, 2, '0')
$$ LANGUAGE SQL;

\echo 'Create generation function: "make_address(_street_name_ text, _zip_ text, _city_ text, _state_ text)".'
DROP FUNCTION IF EXISTS make_address(_street_name_ text, _zip_ text, _city_ text, _state_ text) CASCADE;
CREATE OR REPLACE FUNCTION make_address(_street_name_ text, _zip_ text, _city_ text, _state_ text)
RETURNS jsonb AS $$
  select array_to_json(ARRAY[
    json_build_object(
      'use', 'home',
      'line', ARRAY[_street_name_ || ' ' || random(0, 100)::text],
      'city', _city_,
      'postalCode', _zip_::text,
      'state', _state_,
      'country', 'US'
    )
  ])::jsonb;
$$ LANGUAGE SQL;

\echo 'Create generation function: "insert_patients(_total_count_ integer)".'
DROP FUNCTION IF EXISTS insert_patients(_total_count_ integer) CASCADE;
CREATE OR REPLACE FUNCTION insert_patients(_total_count_ integer)
RETURNS bigint AS $$
  with first_names_source as (
    select CASE WHEN sex = 'M' THEN 'male' ELSE 'female' END as sex,
           first_name,
           row_number() over ()
    from first_names
    cross join generate_series(0, ceil(_total_count_::float
                                       / (select count(*)
                                          from first_names)::float)::integer)
    order by random()
  ), last_names_source as (
    select last_name, row_number() over ()
    from last_names
    cross join generate_series(0, ceil(_total_count_::float
                                       / (select count(*)
                                          from last_names)::float)::integer)
    order by random()
  ), street_names_source as (
    select street_name, row_number() over ()
    from street_names
    cross join generate_series(0, ceil(_total_count_::float
                                       / (select count(*)
                                          from street_names)::float)::integer)
    order by random()
  ), cities_source as (
    select city, zip, state, row_number() over ()
    from cities
    cross join generate_series(0, ceil(_total_count_::float
                                       / (select count(*)
                                          from cities)::float)::integer)
    order by random()
  ), languages_source as (
    select code as language_code,
           name as language_name,
           row_number() over ()
    from languages
    cross join generate_series(0, ceil(_total_count_::float
                                       / (select count(*)
                                          from languages)::float)::integer)
    order by random()
  ), organizations_source as (
    select
           -- row_number() as organization_id,
            organization_name,
           row_number() over ()
    from organization_names
    cross join generate_series(0, ceil(_total_count_::float
                                       / (select count(*)
                                          from organization_names)::float)::integer)
    order by random()
  ), patient_data as (
    select
      *,
      random_date() as birth_date,
      random_phone() as phone
    from first_names_source
    join last_names_source using (row_number)
    join street_names_source using (row_number)
    join cities_source using (row_number)
    join languages_source using (row_number)
    join organizations_source using (row_number)
  ), inserted as (
    INSERT into patient (id, txid, status, resource)
    SELECT (obj->>'id'), 0, 'created', obj
    FROM (
      SELECT
        json_build_object(
         'resourceType', 'Patient',
         'id', nextval('patient_id')::text,
         'meta', json_build_object(
            'versionId', gen_random_uuid(),
            'lastUpdated', CURRENT_TIMESTAMP
          ),
         'gender', sex,
         'birthDate', birth_date,
         'active', TRUE,
         'deceasedBoolean', FALSE,
         'name', ARRAY[
           json_build_object(
            'given', ARRAY[first_name],
            'family', ARRAY[last_name]
           )
         ],
         'telecom', ARRAY[
           json_build_object(
            'system', 'phone',
            'value', phone,
            'use', 'home'
           )
         ],
         'address', make_address(street_name, zip, city, state),
         'communication', ARRAY[
           json_build_object(
             'language',
             json_build_object(
               'coding', ARRAY[
                 json_build_object(
                   'system', 'urn:ietf:bcp:47',
                   'code', language_code,
                   'display', language_name
                 )
               ],
               'text', language_name
             ),
             'preferred', TRUE
           )
         ],
         'identifier', ARRAY[
           json_build_object(
             'use', 'usual',
             'system', 'http://hl7.org/fhir/sid/us-ssn',
             'value', random(100000000, 999999999)::text,
             'label', 'SSN'
           ),
           json_build_object(
             'use', 'usual',
             'system', 'urn:oid:1.2.36.146.595.217.0.1',
             'value', random(6000000, 100000000)::text,
             'label', 'MRN'
           )
         ],
         'managingOrganization', json_build_object(
           -- 'reference', 'Organization/' || organization_id,
           'id', ceil(random() * 1000),
           'resourceType', 'Organization',
           'display', organization_name
         )
        )::jsonb as obj
        FROM patient_data
        LIMIT _total_count_
    ) _
    RETURNING id
  )
  select count(*) inserted;
$$ LANGUAGE SQL;

\echo 'Create generation function: "insert_observations(_total_count_ integer)".'
DROP FUNCTION IF EXISTS insert_observations(_total_count_ integer) CASCADE;
CREATE OR REPLACE FUNCTION insert_observations(_total_count_ integer)
RETURNS bigint AS $$
with observations_source as (
  select id as loinc_code,
         short_name as loinc_name,
         row_number() over ()
    from common_observations
    cross join generate_series(0, ceil(_total_count_::float
                                       / (select count(*)
                                          from common_observations)::float)::integer)
    order by random()
  ), patients_source as (
  select id as patient_id,
         (resource#>>'{name,0,given,0}') as patient_name,
         (resource#>>'{name,0,family,0}') as patient_family,
         row_number() over ()
      from patient
      cross join generate_series(0, ceil(_total_count_::float
                                      / (select count(*)
                                      from patient)::float)::integer)
      order by random()
  ), observation_data as (
    select
      *
      from observations_source
      join patients_source using (row_number)
  ), inserted as (
    INSERT into observation (id, txid, status, resource)
    SELECT (obj->>'id'), 0, 'created', obj
    FROM (
      SELECT
        json_build_object(
         'resourceType', 'Observation',
         'id', nextval('observation_id')::text,
         'meta', json_build_object(
            'versionId', gen_random_uuid(),
            'lastUpdated', CURRENT_TIMESTAMP
          ),
         'status', 'final',
         'identifier', ARRAY[
           json_build_object(
             'use', 'official',
             'system', 'http://www.bmc.nl/zorgportal/identifiers/observations',
             'value', random(6320, 6329)::text
           )],
         'code', json_build_object('coding', ARRAY[
           json_build_object(
           'system', 'loinc.org',
           'code', loinc_code,
           'display', loinc_name)]),
         'subject', json_build_object(
             'id', patient_id,
             'resourceType', 'Patient',
             'display', patient_name || ' '::text || patient_family),
         'effective', json_build_object(
                          'period', json_build_object(
                                    'start', random_datetime(2012, 2013),
                                    'end', random_datetime(2014, 2015))),
         'issued', random_datetime(2012, 2012),
         'performer', ARRAY[
           json_build_object(
             'resourceType', 'Practitioner',
             'id', ceil(random() * 1000),
             'display', 'Random Name'
          )],
         'value', json_build_object(
           'quantity', json_build_object(
             'value', random(1,10),
             'unit', 'g/dl',
             'code', 'g/dl',
             'system', 'http://unitsofmeasure.org'
          )),
          'interpretation', json_build_object(
                              'coding', ARRAY[
                                'system', 'http://hl7.org/fhir/v2/0078',
                                'code', 'L',
                                'display', 'Low'
                             ]),
          'referenceRange', ARRAY[
            json_build_object(
              'low', json_build_object(
                'value', random(10,14),
                'unit', 'g/dl',
                'code', 'g/dl',
                'system', 'http://unitsofmeasure.org'
            )),
            json_build_object(
              'high', json_build_object(
              'value', random(15,20),
              'unit', 'g/dl',
              'code', 'g/dl',
              'system', 'http://unitsofmeasure.org'
           ))]
        )::jsonb as obj
        FROM observation_data
        LIMIT _total_count_
    ) _
    RETURNING id
  )
  select count(*) inserted;
$$ LANGUAGE SQL;

\echo 'Create generation function: "insert_medicationstatements(_total_count_ integer)".'
DROP FUNCTION IF EXISTS insert_medicationstatements(_total_count_ integer) CASCADE;
CREATE OR REPLACE FUNCTION insert_medicationstatements(_total_count_ integer)
RETURNS bigint AS $$
with observations_source as (
  select id as loinc_code,
         short_name as loinc_name,
         row_number() over ()
    from common_observations
           cross join generate_series(0, ceil(_total_count_::float
                                              / (select count(*)
                                                   from common_observations)::float)::integer)
    order by random()
  ), patients_source as (
  select id as patient_id,
         (resource#>>'{name,0,given,0}') as patient_name,
         (resource#>>'{name,0,family,0}') as patient_family,
         row_number() over ()
      from patient
      cross join generate_series(0, ceil(_total_count_::float
                                      / (select count(*)
                                      from patient)::float)::integer)
      order by random()
  ), medicationstatement_data as (
    select
      *
      from observations_source
      join patients_source using (row_number)
  ), inserted as (
    INSERT into medicationstatement (id, txid, status, resource)
    SELECT (obj->>'id'), 0, 'created', obj
    FROM (
      SELECT
        json_build_object(
         'resourceType', 'MedicationStatement',
         'id', nextval('medicationstatement_id'),
         'meta', json_build_object(
            'versionId', gen_random_uuid(),
            'lastUpdated', CURRENT_TIMESTAMP
          ),
         'identifier', ARRAY[
           json_build_object(
            'use', 'official',
            'system', 'http://www.bmc.nl/portal/medstatements',
            'value', random(11111111111, 9999999999)
          )],
         'status', 'active',
         'category', json_build_object('coding', ARRAY[
           json_build_object(
             'system', 'http://hl7.org/fhir/medication-statement-category',
             'code', 'inpatient',
             'display', 'Inpatient')]),
         'medication', json_build_object(
           'reference', json_build_object(
             'reference', '#med' || random(1, 1000)::text),
             'effectiveDateTime', random_date(),
             'dateAsserted', random_date()),
         'subject', json_build_object(
            'id', patient_id,
            'resourceType', 'Patient',
            'display', patient_name || ' '::text || patient_family),
         'informationSource', json_build_object(
            'id', patient_id,
            'resourceType', 'Patient',
            'display', patient_name || ' '::text || patient_family),
         'taken', 'y',
         'reasonCode', ARRAY[
           json_build_object('coding',
             ARRAY[
               json_build_object(
                 'system', 'http://snomed.info/sct',
                 'code', random(11111111, 9999999),
                 'display', 'Restless Legs')])],
          'dosage', ARRAY[
            json_build_object(
              'sequence', 1,
              'text', '1-2 tablets once daily',
              'timing', json_build_object(
                          'repeat', json_build_object(
                            'frequency', 1,
                            'period', 1,
                            'periodUnit', 'd')),
           'asNeededCodeableConcept', json_build_object(
             'coding', ARRAY[
               json_build_object(
                 'system', 'http://snomed.info/sct',
                  'code', random(1111111,9999999),
                  'display', 'Restless Legs')]),
           'route', json_build_object(
             'coding', ARRAY[
               json_build_object(
                 'system', 'http://snomed.info/sct',
                 'code', random(1111111,9999999),
                 'display', 'Oral Route')]),
            'doseRange', json_build_object(
              'low', json_build_object(
                'value', 1,
                'unit', 'TAB',
                'code', 'TAB',
                'system', 'http://hl7.org/fhir/v3/orderableDrugForm'),
              'high', json_build_object(
                'value', 2,
                'unit', 'TAB',
                'code', 'TAB',
                'system', 'http://hl7.org/fhir/v3/orderableDrugForm')))
        ])::jsonb as obj
        FROM medicationstatement_data
        LIMIT _total_count_
    ) _
    RETURNING id
  )
  select count(*) inserted;
$$ LANGUAGE SQL;

select insert_patients(:patients_count);
select insert_observations(1000 * :patients_count);
select insert_medicationstatements(100 * :patients_count);
