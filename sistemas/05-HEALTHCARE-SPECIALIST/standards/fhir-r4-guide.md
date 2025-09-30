# FHIR R4 Implementation Guide for Healthcare Systems

**Standard**: HL7 FHIR R4 (v4.0.1)
**Official Specification**: https://hl7.org/fhir/R4/
**Healthcare Context**: Brazilian LGPD + HIPAA compliance
**Last Updated**: 2025-09-30

---

## Overview

**FHIR** (Fast Healthcare Interoperability Resources) is the HL7 standard for exchanging healthcare information electronically.

**R4** (Release 4) is the first normative version (2019), widely adopted globally.

**Use Cases**:
- Electronic Health Records (EHR) integration
- Patient data exchange (Epic, Cerner, Teladoc)
- Clinical decision support (CDS Hooks)
- Telemedicine platforms (CFM 2.314/2022 compliance)

---

## Core Concepts

### Resources
**Definition**: Structured data objects representing healthcare entities.

**Base Resources** (most common):
```yaml
Patient: Demographics (name, CPF, birthdate)
Practitioner: Healthcare professionals (CRM, specialty)
Organization: Healthcare facilities (CNES, address)
Observation: Vital signs, lab results (LOINC codes)
Condition: Diagnoses (ICD-10, SNOMED CT)
Procedure: Medical procedures (TUSS, CBHPM)
MedicationRequest: Prescriptions (Anvisa drug codes)
AllergyIntolerance: Known allergies
DiagnosticReport: Lab/imaging reports
ImagingStudy: DICOM imaging metadata
```

**Example** (Patient Resource):
```json
{
  "resourceType": "Patient",
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2025-09-30T10:30:00Z",
    "profile": ["http://hl7.org/fhir/StructureDefinition/Patient"]
  },
  "identifier": [
    {
      "system": "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
      "value": "12345678901"
    }
  ],
  "name": [
    {
      "use": "official",
      "family": "Silva",
      "given": ["João", "Carlos"]
    }
  ],
  "gender": "male",
  "birthDate": "1985-03-15",
  "address": [
    {
      "use": "home",
      "line": ["Rua das Flores, 123"],
      "city": "São Paulo",
      "state": "SP",
      "postalCode": "01234-567",
      "country": "BR"
    }
  ],
  "telecom": [
    {
      "system": "phone",
      "value": "+55-11-98765-4321",
      "use": "mobile"
    }
  ]
}
```

---

### RESTful API

**HTTP Methods**:
- `GET /fhir/Patient/123` - Read single patient
- `GET /fhir/Patient?name=Silva` - Search patients
- `POST /fhir/Patient` - Create new patient
- `PUT /fhir/Patient/123` - Update patient
- `DELETE /fhir/Patient/123` - Delete patient (soft delete recommended)

**Search Parameters**:
```
GET /fhir/Patient?
  name=Silva&
  birthdate=1985-03-15&
  gender=male&
  _count=20&
  _sort=-_lastUpdated
```

**Response** (Bundle):
```json
{
  "resourceType": "Bundle",
  "type": "searchset",
  "total": 1,
  "entry": [
    {
      "fullUrl": "https://api.healthcare.com/fhir/Patient/123",
      "resource": { /* Patient resource */ }
    }
  ]
}
```

---

## Elixir Implementation

### FHIR Client (ExFHIR Library)

**Installation**:
```elixir
# mix.exs
def deps do
  [
    {:ex_fhir, "~> 0.3.0"},
    {:jason, "~> 1.4"},
    {:req, "~> 0.4"}
  ]
end
```

**Configuration**:
```elixir
# config/config.exs
config :ex_fhir,
  base_url: "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4",
  auth: %{
    type: :oauth2,
    client_id: System.get_env("EPIC_CLIENT_ID"),
    client_secret: System.get_env("EPIC_CLIENT_SECRET")
  }
```

**Patient Search**:
```elixir
defmodule Healthcare.FHIR.Client do
  @moduledoc "FHIR R4 client for EHR integration"
  
  def search_patients(name) do
    case ExFHIR.search("Patient", name: name) do
      {:ok, %{"resourceType" => "Bundle", "entry" => entries}} ->
        patients = Enum.map(entries, & &1["resource"])
        {:ok, patients}
      
      {:error, reason} ->
        Logger.error("FHIR search failed: #{inspect(reason)}")
        {:error, :search_failed}
    end
  end
  
  def get_patient(patient_id) do
    case ExFHIR.read("Patient", patient_id) do
      {:ok, patient} ->
        {:ok, patient}
      
      {:error, %{"issue" => [%{"severity" => "error", "diagnostics" => msg}]}} ->
        Logger.error("FHIR read failed: #{msg}")
        {:error, :not_found}
    end
  end
  
  def create_patient(patient_data) do
    patient_resource = %{
      "resourceType" => "Patient",
      "identifier" => [
        %{
          "system" => "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
          "value" => patient_data.cpf
        }
      ],
      "name" => [
        %{
          "use" => "official",
          "family" => patient_data.last_name,
          "given" => [patient_data.first_name]
        }
      ],
      "gender" => patient_data.gender,
      "birthDate" => Date.to_iso8601(patient_data.birth_date)
    }
    
    case ExFHIR.create("Patient", patient_resource) do
      {:ok, created_patient} ->
        Healthcare.AuditLog.write("fhir_patient_created", :system, created_patient, %{
          compliance: "CFM_1_821_2007"
        })
        {:ok, created_patient}
      
      {:error, reason} ->
        {:error, reason}
    end
  end
end
```

---

### FHIR Server (Phoenix + Ecto)

**Schema** (Patient):
```elixir
defmodule Healthcare.FHIR.Patient do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "fhir_patients" do
    field :resource_type, :string, default: "Patient"
    field :identifier_cpf, :string
    field :family_name, :string
    field :given_names, {:array, :string}
    field :gender, :string
    field :birth_date, :date
    field :address_line, {:array, :string}
    field :address_city, :string
    field :address_state, :string
    field :address_postal_code, :string
    field :telecom_phone, :string
    
    # FHIR metadata
    field :version_id, :integer, default: 1
    field :last_updated, :utc_datetime
    
    timestamps()
  end
  
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:identifier_cpf, :family_name, :given_names, :gender, :birth_date])
    |> validate_required([:identifier_cpf, :family_name, :gender, :birth_date])
    |> validate_format(:identifier_cpf, ~r/^\d{11}$/)
    |> validate_inclusion(:gender, ["male", "female", "other", "unknown"])
    |> unique_constraint(:identifier_cpf)
  end
  
  def to_fhir_resource(patient) do
    %{
      "resourceType" => "Patient",
      "id" => patient.id,
      "meta" => %{
        "versionId" => to_string(patient.version_id),
        "lastUpdated" => DateTime.to_iso8601(patient.last_updated)
      },
      "identifier" => [
        %{
          "system" => "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
          "value" => patient.identifier_cpf
        }
      ],
      "name" => [
        %{
          "use" => "official",
          "family" => patient.family_name,
          "given" => patient.given_names
        }
      ],
      "gender" => patient.gender,
      "birthDate" => Date.to_iso8601(patient.birth_date)
    }
  end
end
```

**Controller**:
```elixir
defmodule HealthcareWeb.FHIR.PatientController do
  use HealthcareWeb, :controller
  
  # GET /fhir/Patient/:id
  def show(conn, %{"id" => id}) do
    case Healthcare.FHIR.get_patient(id) do
      {:ok, patient} ->
        json(conn, Healthcare.FHIR.Patient.to_fhir_resource(patient))
      
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{
          "resourceType" => "OperationOutcome",
          "issue" => [
            %{
              "severity" => "error",
              "code" => "not-found",
              "diagnostics" => "Patient with ID #{id} not found"
            }
          ]
        })
    end
  end
  
  # GET /fhir/Patient?name=Silva
  def search(conn, params) do
    patients = Healthcare.FHIR.search_patients(params)
    
    bundle = %{
      "resourceType" => "Bundle",
      "type" => "searchset",
      "total" => length(patients),
      "entry" => Enum.map(patients, fn patient ->
        %{
          "fullUrl" => HealthcareWeb.Endpoint.url() <> "/fhir/Patient/#{patient.id}",
          "resource" => Healthcare.FHIR.Patient.to_fhir_resource(patient)
        }
      end)
    }
    
    json(conn, bundle)
  end
  
  # POST /fhir/Patient
  def create(conn, patient_resource) do
    case Healthcare.FHIR.create_patient(patient_resource) do
      {:ok, patient} ->
        conn
        |> put_status(201)
        |> put_resp_header("location", "/fhir/Patient/#{patient.id}")
        |> json(Healthcare.FHIR.Patient.to_fhir_resource(patient))
      
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{
          "resourceType" => "OperationOutcome",
          "issue" => format_errors(changeset)
        })
    end
  end
end
```

---

## Brazilian Adaptations

### RNDS (Rede Nacional de Dados em Saúde)

**Official Profile**: http://rnds.saude.gov.br/fhir/r4/

**Required Identifiers**:
- **CPF**: Patient (http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf)
- **CNS**: National Health Card (http://rnds.saude.gov.br/fhir/r4/NamingSystem/cns)
- **CNES**: Healthcare facility (http://cnes.datasus.gov.br)

**Example** (RNDS Patient):
```json
{
  "resourceType": "Patient",
  "identifier": [
    {
      "system": "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
      "value": "12345678901"
    },
    {
      "system": "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cns",
      "value": "123456789012345"
    }
  ],
  "name": [{"family": "Silva", "given": ["João"]}],
  "birthDate": "1985-03-15"
}
```

---

### TUSS/CBHPM Codes (Procedures)

**TUSS**: Brazilian healthcare procedures (ANS standardization)
**CBHPM**: Medical procedure fees (AMB/CFM)

**Example** (Procedure Resource):
```json
{
  "resourceType": "Procedure",
  "status": "completed",
  "code": {
    "coding": [
      {
        "system": "http://www.ans.gov.br/fhir/CodeSystem/tuss",
        "code": "40101010",
        "display": "Consulta médica"
      }
    ]
  },
  "subject": {"reference": "Patient/123"},
  "performedDateTime": "2025-09-30T10:00:00Z",
  "performer": [
    {
      "actor": {"reference": "Practitioner/456"}
    }
  ]
}
```

---

## Compliance

### LGPD (Art. 18 - Data Subject Rights)

**FHIR Support**:
- **Access**: `GET /fhir/Patient/123` (read patient data)
- **Portability**: Export Bundle (JSON format)
- **Deletion**: `DELETE /fhir/Patient/123` (soft delete with retention policy)

**Implementation**:
```elixir
defmodule Healthcare.FHIR.DataSubjectRights do
  def export_patient_data(patient_id) do
    # LGPD Art. 18, II (portability)
    patient = Healthcare.FHIR.get_patient!(patient_id)
    observations = Healthcare.FHIR.search_observations(patient_id)
    conditions = Healthcare.FHIR.search_conditions(patient_id)
    
    bundle = %{
      "resourceType" => "Bundle",
      "type" => "collection",
      "entry" => [
        %{"resource" => Healthcare.FHIR.Patient.to_fhir_resource(patient)},
        Enum.map(observations, &%{"resource" => &1}),
        Enum.map(conditions, &%{"resource" => &1})
      ] |> List.flatten()
    }
    
    {:ok, Jason.encode!(bundle, pretty: true)}
  end
  
  def delete_patient_data(patient_id, justification) do
    # LGPD Art. 18, VI (deletion)
    # HIPAA requires 6-year retention (conflict resolution in ADR 003)
    patient = Healthcare.FHIR.get_patient!(patient_id)
    
    Healthcare.Repo.update(Ecto.Changeset.change(patient,
      identifier_cpf: nil, # Anonymize
      family_name: "ANONYMIZED",
      given_names: [],
      deletion_requested_at: DateTime.utc_now(),
      deletion_justification: justification
    ))
    
    Healthcare.AuditLog.write("patient_data_deleted", patient_id, patient, %{
      compliance: "LGPD_Art_18_VI",
      justification: justification
    })
  end
end
```

---

### CFM 1.821/2007 (Digital Signatures)

**Requirement**: Medical records must be digitally signed.

**Implementation** (Provenance Resource):
```json
{
  "resourceType": "Provenance",
  "target": [{"reference": "Observation/789"}],
  "recorded": "2025-09-30T10:30:00Z",
  "agent": [
    {
      "type": {
        "coding": [{"system": "http://terminology.hl7.org/CodeSystem/provenance-participant-type", "code": "author"}]
      },
      "who": {"reference": "Practitioner/456"}
    }
  ],
  "signature": [
    {
      "type": [{"system": "urn:iso-astm:E1762-95:2013", "code": "1.2.840.10065.1.12.1.5"}],
      "when": "2025-09-30T10:30:00Z",
      "who": {"reference": "Practitioner/456"},
      "sigFormat": "application/jose",
      "data": "eyJhbGciOiJFZERTQSJ9..." // Ed25519+Dilithium3 signature
    }
  ]
}
```

---

## Performance Optimization

### Caching Strategy
```elixir
defmodule Healthcare.FHIR.Cache do
  use Nebulex.Cache,
    otp_app: :healthcare,
    adapter: Nebulex.Adapters.Local
  
  def get_patient_with_cache(patient_id) do
    case get(patient_id) do
      nil ->
        patient = Healthcare.FHIR.get_patient!(patient_id)
        put(patient_id, patient, ttl: :timer.minutes(15))
        patient
      
      cached_patient ->
        cached_patient
    end
  end
end
```

### Database Indexes
```sql
-- Optimize FHIR searches
CREATE INDEX idx_patients_cpf ON fhir_patients(identifier_cpf);
CREATE INDEX idx_patients_family_name ON fhir_patients(family_name);
CREATE INDEX idx_patients_birth_date ON fhir_patients(birth_date);
CREATE INDEX idx_patients_last_updated ON fhir_patients(last_updated DESC);
```

---

## References

### Official Documentation
- [HL7 FHIR R4 Specification](https://hl7.org/fhir/R4/) (L0_CANONICAL)
- [RNDS (Brazil)](http://rnds.saude.gov.br/fhir/r4/) (L0_CANONICAL)
- [FHIR RESTful API](https://hl7.org/fhir/R4/http.html) (L0_CANONICAL)

### Brazilian Standards
- [TUSS (ANS)](http://www.ans.gov.br/prestadores/tiss-troca-de-informacao-de-saude-suplementar) (L0_CANONICAL)
- [CFM 1.821/2007](https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2007/1821) (L0_CANONICAL)

### Implementation Guides
- [SMART on FHIR](https://docs.smarthealthit.org/) (L0_CANONICAL)
- [Epic FHIR API](https://fhir.epic.com/) (L2_VALIDATED)

---

**DSM**: [L1:integration | L2:healthcare | L3:implementation | L4:guide]
**Source**: New (FHIR R4 official spec + RNDS adaptations)
**Version**: 1.0.0
**Related**:
- [MCP Protocol](./mcp-protocol.md)
- [LGPD-HIPAA Mapping](../../04-SECURITY-SPECIALIST/compliance/lgpd-hipaa-mapping.md)
