BEGIN;
INSERT into medicationstatement (id, txid, status, resource)
    SELECT (obj->>'id'), 0, 'created', obj
    FROM (
      SELECT format('{
  "resourceType": "MedicationStatement",
  "id": %I,
  "meta": {
     "versionId": %I,
     "lastUpdated": %I
  },
  "contained": [
    {
      "resourceType": "Medication",
      "id": "med0309",
      "code": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/sid/ndc",
            "code": "50580-506-02",
            "display": "Tylenol PM"
          }
        ]
      },
      "isBrand": true,
      "form": {
        "coding": [
          {
            "system": "http://snomed.info/sct",
            "code": "385057009",
            "display": "Film-coated tablet (qualifier value)"
          }
        ]
      },
      "ingredient": [
        {
          "itemCodeableConcept": {
            "coding": [
              {
                "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
                "code": "315266",
                "display": "Acetaminophen 500 MG"
              }
            ]
          },
          "amount": {
            "numerator": {
              "value": 500,
              "system": "http://unitsofmeasure.org",
              "code": "mg"
            },
            "denominator": {
              "value": 1,
              "system": "http://hl7.org/fhir/v3/orderableDrugForm",
              "code": "Tab"
            }
          }
        },
        {
          "itemCodeableConcept": {
            "coding": [
              {
                "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
                "code": "901813",
                "display": "Diphenhydramine Hydrochloride 25 mg"
              }
            ]
          },
          "amount": {
            "numerator": {
              "value": 25,
              "system": "http://unitsofmeasure.org",
              "code": "mg"
            },
            "denominator": {
              "value": 1,
              "system": "http://hl7.org/fhir/v3/orderableDrugForm",
              "code": "Tab"
            }
          }
        }
      ],
      "package": {
        "batch": [
          {
            "lotNumber": "9494788",
            "expirationDate": "2017-05-22"
          }
        ]
      }
    }
  ],
  "identifier": [
    {
      "use": "official",
      "system": "http://www.bmc.nl/portal/medstatements",
      "value": "12345689"
    }
  ],
  "status": "active",
  "category": {
    "coding": [
      {
        "system": "http://hl7.org/fhir/medication-statement-category",
        "code": "inpatient",
        "display": "Inpatient"
      }
    ]
  },
  "medication": {
     "reference": {
        "reference": "#med0309",
        "effectiveDateTime": "2015-01-23",
        "dateAsserted": "2015-02-22"
   }
  },
  "informationSource": {
    "id": %I,
    "resourceType": "Patient",
    "display": %I
  },
  "subject": {
    "id": %I,
    "resourceType": "Patient",
    "display": %I
  },
  "derivedFrom": [
    {
      "reference": "MedicationRequest/medrx002"
    }
  ],
  "taken": "n",
  "reasonCode": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "32914008",
          "display": "Restless Legs"
        }
      ]
    }
  ],
  "note": [
    {
      "text": "Patient indicates they miss the occasional dose"
    }
  ],
  "dosage": [
    {
      "sequence": 1,
      "text": "1-2 tablets once daily at bedtime as needed for restless legs",
      "additionalInstruction": [
        {
          "text": "Taking at bedtime"
        }
      ],
      "timing": {
        "repeat": {
          "frequency": 1,
          "period": 1,
          "periodUnit": "d"
        }
      },
      "asNeededCodeableConcept": {
        "coding": [
          {
            "system": "http://snomed.info/sct",
            "code": "32914008",
            "display": "Restless Legs"
          }
        ]
      },
      "route": {
        "coding": [
          {
            "system": "http://snomed.info/sct",
            "code": "26643006",
            "display": "Oral Route"
          }
        ]
      },
      "doseRange": {
        "low": {
          "value": 1,
          "unit": "TAB",
          "system": "http://hl7.org/fhir/v3/orderableDrugForm",
          "code": "TAB"
        },
        "high": {
          "value": 2,
          "unit": "TAB",
          "system": "http://hl7.org/fhir/v3/orderableDrugForm",
          "code": "TAB"
        }
      }
    }
  ]
}', nextval('medicationstatement_id'),
    gen_random_uuid(),
    CURRENT_TIMESTAMP,
    1,
    'Example Name',
    1,
    'Example Name'
    )::json as obj) as base;
END;
