# PostgreSQL Core Features for Healthcare

**Database**: PostgreSQL 16.6
**Healthcare Context**: ACID-compliant medical records storage
**Compliance**: LGPD Art. 46, HIPAA 164.312(a)(1)
**Last Updated**: 2025-09-30

---

## Overview

**PostgreSQL** is the foundation of the Healthcare WASM-Elixir stack due to:
- **ACID compliance**: Critical for medical records integrity
- **Row-level security**: PHI/PII access control per LGPD/HIPAA
- **JSON support**: Store FHIR resources natively
- **Extensions**: TimescaleDB (time-series), pgvector (embeddings), PostGIS (geospatial)
- **Audit logging**: Built-in transaction tracking

**Healthcare Requirements**:
- Medical records must be tamper-proof (ACID)
- Audit trail for all PHI access (LGPD Art. 46, HIPAA 164.312(b))
- Row-level security (RLS) for patient data isolation

---

## ACID Guarantees

### Atomicity

**All-or-nothing transactions** - critical for medical data consistency.

```sql
-- Example: Patient admission (all-or-nothing)
BEGIN;

-- 1. Insert patient
INSERT INTO patients (id, name, cpf, birth_date)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'João Silva', '12345678901', '1985-03-15');

-- 2. Create medical record
INSERT INTO medical_records (patient_id, admission_date, chief_complaint)
VALUES ('550e8400-e29b-41d4-a716-446655440000', NOW(), 'Chest pain');

-- 3. Assign bed
INSERT INTO bed_assignments (patient_id, bed_number, ward)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'A-101', 'Cardiology');

-- If ANY step fails, ALL changes are rolled back
COMMIT;
```

**Elixir Integration**:
```elixir
defmodule Healthcare.Admissions do
  alias Healthcare.Repo
  alias Ecto.Multi
  
  def admit_patient(patient_attrs, record_attrs, bed_attrs) do
    Multi.new()
    |> Multi.insert(:patient, Patient.changeset(%Patient{}, patient_attrs))
    |> Multi.insert(:medical_record, fn %{patient: patient} ->
      MedicalRecord.changeset(%MedicalRecord{patient_id: patient.id}, record_attrs)
    end)
    |> Multi.insert(:bed_assignment, fn %{patient: patient} ->
      BedAssignment.changeset(%BedAssignment{patient_id: patient.id}, bed_attrs)
    end)
    |> Repo.transaction()
  end
end
```

### Consistency

**Constraints enforce business rules** - prevent invalid medical data.

```sql
-- Patient table with constraints
CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL CHECK (LENGTH(name) >= 3),
  cpf CHAR(11) UNIQUE NOT NULL CHECK (cpf ~ '^\d{11}$'),
  birth_date DATE NOT NULL CHECK (birth_date <= CURRENT_DATE),
  gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other', 'unknown')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Medication orders with dosage limits
CREATE TABLE medication_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  medication_code VARCHAR(50) NOT NULL,
  dosage NUMERIC(10, 2) NOT NULL CHECK (dosage > 0),
  unit VARCHAR(20) NOT NULL,
  frequency VARCHAR(50) NOT NULL,
  prescriber_id UUID NOT NULL REFERENCES practitioners(id),
  status VARCHAR(20) NOT NULL DEFAULT 'pending' 
    CHECK (status IN ('pending', 'approved', 'dispensed', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Isolation

**MVCC (Multi-Version Concurrency Control)** - readers don't block writers.

```sql
-- Transaction isolation levels
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- Default (most common)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;  -- Prevent non-repeatable reads
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;     -- Strictest (prevent anomalies)

-- Example: Concurrent lab result updates don't block each other
-- Session 1
BEGIN;
UPDATE lab_results SET status = 'reviewed' WHERE id = 'lab-123';
-- Not committed yet

-- Session 2 (can still read old version)
SELECT status FROM lab_results WHERE id = 'lab-123';
-- Returns old status until Session 1 commits
```

### Durability

**WAL (Write-Ahead Logging)** - changes survive crashes.

```sql
-- Check WAL settings
SHOW wal_level;  -- 'replica' or 'logical'
SHOW fsync;      -- 'on' (critical - ensures disk writes)
SHOW synchronous_commit;  -- 'on' (wait for WAL write before COMMIT returns)

-- Force WAL checkpoint (for testing)
CHECKPOINT;
```

---

## Row-Level Security (LGPD/HIPAA)

### Enable RLS

```sql
-- Enable RLS on patients table
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own organization's patients
CREATE POLICY patient_org_isolation ON patients
  FOR ALL
  USING (organization_id = current_setting('app.current_org_id')::UUID);

-- Policy: Doctors can only see patients they're treating
CREATE POLICY patient_care_team ON patients
  FOR SELECT
  USING (
    id IN (
      SELECT patient_id 
      FROM care_team_members 
      WHERE practitioner_id = current_setting('app.current_user_id')::UUID
    )
  );

-- Policy: Read-only for archived records (compliance)
CREATE POLICY archived_readonly ON medical_records
  FOR UPDATE
  USING (archived_at IS NULL);
```

### Elixir Integration

```elixir
defmodule Healthcare.Repo do
  use Ecto.Repo,
    otp_app: :healthcare,
    adapter: Ecto.Adapters.Postgres
  
  @doc "Set session variables for RLS"
  def set_user_context(user_id, org_id) do
    query("SET LOCAL app.current_user_id = $1", [user_id])
    query("SET LOCAL app.current_org_id = $1", [org_id])
  end
end

defmodule Healthcare.Patients do
  def list_patients_for_user(user) do
    # Set RLS context
    Healthcare.Repo.transaction(fn ->
      Healthcare.Repo.set_user_context(user.id, user.organization_id)
      
      # Query automatically filtered by RLS policies
      Healthcare.Repo.all(Patient)
    end)
  end
end
```

---

## JSON/JSONB for FHIR

### Store FHIR Resources

```sql
-- FHIR Patient resource storage
CREATE TABLE fhir_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_type VARCHAR(50) NOT NULL,
  resource_id VARCHAR(255) NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE (resource_type, resource_id)
);

-- GIN index for fast JSON queries
CREATE INDEX idx_fhir_data_gin ON fhir_resources USING GIN (data);

-- Specific indexes for common queries
CREATE INDEX idx_fhir_patient_cpf ON fhir_resources 
  USING BTREE ((data->'identifier'->0->>'value'))
  WHERE resource_type = 'Patient';
```

### Query FHIR Resources

```sql
-- Insert FHIR Patient
INSERT INTO fhir_resources (resource_type, resource_id, data)
VALUES (
  'Patient',
  'patient-123',
  '{
    "resourceType": "Patient",
    "id": "patient-123",
    "identifier": [{
      "system": "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
      "value": "12345678901"
    }],
    "name": [{"family": "Silva", "given": ["João"]}],
    "birthDate": "1985-03-15",
    "gender": "male"
  }'::JSONB
);

-- Query by CPF (using GIN index)
SELECT data 
FROM fhir_resources 
WHERE resource_type = 'Patient'
  AND data @> '{"identifier": [{"value": "12345678901"}]}';

-- Query by nested field
SELECT 
  data->>'id' AS patient_id,
  data->'name'->0->>'family' AS family_name,
  data->'name'->0->'given'->>0 AS given_name
FROM fhir_resources
WHERE resource_type = 'Patient'
  AND data->>'gender' = 'male';

-- Update nested field (keep history with versioning)
UPDATE fhir_resources
SET 
  data = jsonb_set(data, '{name,0,family}', '"Silva Santos"'),
  version = version + 1,
  updated_at = NOW()
WHERE resource_type = 'Patient' AND resource_id = 'patient-123';
```

**Elixir Integration**:
```elixir
defmodule Healthcare.FHIR do
  def create_patient_resource(patient) do
    fhir_json = %{
      "resourceType" => "Patient",
      "id" => patient.id,
      "identifier" => [
        %{
          "system" => "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
          "value" => patient.cpf
        }
      ],
      "name" => [%{"family" => patient.last_name, "given" => [patient.first_name]}],
      "birthDate" => Date.to_iso8601(patient.birth_date),
      "gender" => patient.gender
    }
    
    %FhirResource{}
    |> FhirResource.changeset(%{
      resource_type: "Patient",
      resource_id: patient.id,
      data: fhir_json
    })
    |> Repo.insert()
  end
  
  def search_by_cpf(cpf) do
    query = from f in FhirResource,
      where: f.resource_type == "Patient",
      where: fragment("data @> ?", ^%{"identifier" => [%{"value" => cpf}]})
    
    Repo.all(query)
  end
end
```

---

## Full-Text Search

### tsvector + GIN Index

```sql
-- Add tsvector column for full-text search
ALTER TABLE medical_records 
  ADD COLUMN search_vector tsvector;

-- Create GIN index
CREATE INDEX idx_medical_records_search 
  ON medical_records USING GIN (search_vector);

-- Update search vector (trigger)
CREATE OR REPLACE FUNCTION update_search_vector() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('portuguese', COALESCE(NEW.chief_complaint, '')), 'A') ||
    setweight(to_tsvector('portuguese', COALESCE(NEW.diagnosis, '')), 'B') ||
    setweight(to_tsvector('portuguese', COALESCE(NEW.notes, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvector_update 
  BEFORE INSERT OR UPDATE ON medical_records
  FOR EACH ROW 
  EXECUTE FUNCTION update_search_vector();

-- Search medical records
SELECT 
  id,
  chief_complaint,
  diagnosis,
  ts_rank(search_vector, query) AS rank
FROM medical_records, 
     to_tsquery('portuguese', 'diabetes & hipertensão') query
WHERE search_vector @@ query
ORDER BY rank DESC
LIMIT 10;
```

---

## Audit Logging (LGPD/HIPAA)

### Trigger-Based Audit

```sql
-- Audit log table
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  table_name VARCHAR(255) NOT NULL,
  record_id UUID NOT NULL,
  operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data JSONB,
  new_data JSONB,
  changed_by UUID NOT NULL,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  compliance_tag VARCHAR(100) NOT NULL DEFAULT 'LGPD_Art_46_HIPAA_164_312_b'
);

-- Partition by month (performance)
CREATE TABLE audit_log_2025_01 PARTITION OF audit_log
  FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- GIN index for fast JSON queries
CREATE INDEX idx_audit_log_old_data ON audit_log USING GIN (old_data);
CREATE INDEX idx_audit_log_new_data ON audit_log USING GIN (new_data);

-- Generic audit trigger
CREATE OR REPLACE FUNCTION audit_trigger_func() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_data, changed_by)
    VALUES (TG_TABLE_NAME, OLD.id, TG_OP, row_to_json(OLD), 
            COALESCE(current_setting('app.current_user_id', true)::UUID, '00000000-0000-0000-0000-000000000000'));
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(OLD), row_to_json(NEW),
            COALESCE(current_setting('app.current_user_id', true)::UUID, '00000000-0000-0000-0000-000000000000'));
    RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_log (table_name, record_id, operation, new_data, changed_by)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(NEW),
            COALESCE(current_setting('app.current_user_id', true)::UUID, '00000000-0000-0000-0000-000000000000'));
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Attach to patients table
CREATE TRIGGER audit_patients
  AFTER INSERT OR UPDATE OR DELETE ON patients
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- Query audit log
SELECT 
  table_name,
  operation,
  old_data->>'name' AS old_name,
  new_data->>'name' AS new_name,
  changed_at,
  changed_by
FROM audit_log
WHERE table_name = 'patients' AND record_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY changed_at DESC;
```

---

## Performance Tuning

### Connection Pooling (Ecto)

```elixir
# config/config.exs
config :healthcare, Healthcare.Repo,
  pool_size: 20,           # Default connections
  queue_target: 5000,      # Target queue time (ms)
  queue_interval: 1000,    # Check interval (ms)
  timeout: 15_000,         # Query timeout (ms)
  ownership_timeout: 60_000,
  migration_lock: nil      # Disable migration lock for parallel tests
```

### Indexes

```sql
-- B-tree index (default, for equality and range queries)
CREATE INDEX idx_patients_cpf ON patients (cpf);
CREATE INDEX idx_medical_records_date ON medical_records (admission_date);

-- Partial index (smaller, faster)
CREATE INDEX idx_active_patients ON patients (id) WHERE status = 'active';

-- Composite index (multi-column queries)
CREATE INDEX idx_lab_results_composite ON lab_results (patient_id, test_date);

-- BRIN index (large tables with natural ordering)
CREATE INDEX idx_vital_signs_timestamp_brin ON vital_signs USING BRIN (timestamp);
```

### Query Optimization

```sql
-- EXPLAIN ANALYZE for query plans
EXPLAIN ANALYZE
SELECT p.name, m.diagnosis 
FROM patients p
JOIN medical_records m ON p.id = m.patient_id
WHERE p.cpf = '12345678901';

-- Use CTEs for complex queries
WITH active_patients AS (
  SELECT id, name FROM patients WHERE status = 'active'
),
recent_records AS (
  SELECT patient_id, diagnosis 
  FROM medical_records 
  WHERE admission_date >= NOW() - INTERVAL '30 days'
)
SELECT ap.name, rr.diagnosis
FROM active_patients ap
JOIN recent_records rr ON ap.id = rr.patient_id;
```

---

## Backup & Recovery

### pg_dump

```bash
# Full database backup
pg_dump -U postgres -Fc healthcare > healthcare_backup.dump

# Schema-only backup
pg_dump -U postgres -s -Fc healthcare > healthcare_schema.dump

# Restore
pg_restore -U postgres -d healthcare healthcare_backup.dump

# Point-in-time recovery (PITR)
# 1. Enable WAL archiving
# postgresql.conf:
# wal_level = replica
# archive_mode = on
# archive_command = 'cp %p /var/lib/postgresql/wal_archive/%f'

# 2. Base backup
pg_basebackup -D /var/lib/postgresql/backup -Ft -z -P

# 3. Restore to specific timestamp
# recovery.conf:
# restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'
# recovery_target_time = '2025-09-30 14:30:00'
```

---

## References

### Official Documentation
- [PostgreSQL 16 Documentation](https://www.postgresql.org/docs/16/) (L0_CANONICAL)
- [PostgreSQL Security](https://www.postgresql.org/docs/16/ddl-rowsecurity.html) (L0_CANONICAL)
- [PostgreSQL JSON Functions](https://www.postgresql.org/docs/16/functions-json.html) (L0_CANONICAL)

### Books
- [PostgreSQL: Up and Running, 4th Edition](https://www.oreilly.com/library/view/postgresql-up-and/9781098151539/) (L2_VALIDATED)

---

**DSM**: [L1:data_layer | L2:healthcare | L3:architecture | L4:reference]
**Source**: `03-database-postgresql-timescale.md` (PostgreSQL sections)
**Version**: 1.0.0
**Related**:
- [TimescaleDB Hypertables](../timescaledb/hypertables.md)
- [pgvector Embeddings](../pgvector/embeddings.md)
- [ADR 003: Database Selection](../../01-ARCHITECTURE/adrs/003-database-selection.md)
