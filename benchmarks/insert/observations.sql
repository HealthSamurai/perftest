BEGIN;
INSERT into observation (id, txid, status, resource)
    SELECT (obj->>'id'), 0, 'created', obj
    FROM (
      SELECT
      format('{"resourceType": "Observation",
         "id" : %s,
         "meta": {
            "versionId": %I,
            "lastUpdated": %I
          },
         "status": "final",
         "identifier": [
           {
             "use": "official",
             "system": "http://www.bmc.nl/zorgportal/identifiers/observations",
             "value": %I
           }],
         "code": {"coding": [
           {
             "system": "loinc.org",
             "code": %I,
             "display": %I
           }]},
         "subject": {
             "id": %s,
             "resourceType": "Patient",
             "display": %I
           },
         "effective": {
             "period": {
                 "start": %I,
                 "end": %I}},
         "issued": %I,
         "performer": [
           {
             "resourceType": "Practitioner",
             "id": %I,
             "display": "Random Name"
          }],
         "value": {
           "quantity": {
             "value": 3,
             "unit": "g/dl",
             "code": "g/dl",
             "system": "http://unitsofmeasure.org"
          }},
          "interpretation": {
                              "coding": {
                                "system": "http://hl7.org/fhir/v2/0078",
                                "code": "L",
                                "display": "Low"
                             }},
          "referenceRange": [
            {
              "low": {
                "value": 234,
                "unit": "g/dl",
                "code": "g/dl",
                "system": "http://unitsofmeasure.org"
            }},
            {
              "high": {
              "value": 17,
              "unit": "g/dl",
              "code": "g/dl",
              "system": "http://unitsofmeasure.org"
           }}]
           }', nextval('observation_id'),
               gen_random_uuid(),
               CURRENT_TIMESTAMP,
               random(6320, 6329),
               1,
               'Long Name',
               1,
               'Example Name',
               random_datetime(2012, 2013),
               random_datetime(2014, 2015),
               random_datetime(2012, 2012),
               ceil(random() * 1000)
           )::json as obj) as base;
END;
