# 📋 Diário do Especialista - Database Stack PostgreSQL + TimescaleDB

<!-- DSM:DOMAIN:data_layer|time_series COMPLEXITY:moderate DEPS:postgresql_timescaledb -->
<!-- DSM:HEALTHCARE:audit_trail|patient_data_storage|phi_pii_encryption|compliance_logging -->
<!-- DSM:PERFORMANCE:query_time:<100ms data_retention:7_years backup_frequency:real_time -->
<!-- DSM:COMPLIANCE:LGPD|HIPAA|audit_requirements|field_level_encryption -->

## 📍 Quick Access Index
- [PostgreSQL 16 Healthcare Setup](#postgresql-16-healthcare-setup)
- [TimescaleDB Audit Trail Configuration](#timescaledb-audit-trail-configuration)
- [Ecto Healthcare Schemas](#ecto-healthcare-schemas)
- [LGPD Compliance Database Design](#lgpd-compliance-database-design)
- [Post-Quantum Cryptography Storage](#post-quantum-cryptography-storage)
- [Performance Tuning](#performance-tuning)
- [Backup & Recovery](#backup-recovery)
- [Troubleshooting Guide](#troubleshooting-guide)

---

## 🎯 Visão Geral Técnica

### Context & Purpose
Nossa stack de database combina PostgreSQL 16 como banco principal com TimescaleDB para dados temporais de auditoria e métricas. Esta configuração foi especificamente projetada para atender aos requisitos de healthcare, incluindo LGPD compliance, auditoria completa, criptografia pós-quântica e alta disponibilidade para sistemas críticos de saúde.

### Database Architecture Overview
```yaml
database_architecture:
  primary_database:
    postgresql:
      version: "16.4"
      extensions: ["pg_crypto", "pg_audit", "uuid-ossp", "pgcrypto"]

  time_series:
    timescaledb:
      version: "2.17.0"
      chunk_interval: "7 days"
      retention_policy: "7 years" # Healthcare compliance

  connection_pooling:
    pgbouncer:
      max_client_connections: 1000
      pool_mode: "transaction"

  backup_strategy:
    primary: "Streaming replication"
    secondary: "Point-in-time recovery (PITR)"
    frequency: "Continuous WAL shipping + daily base backup"
```

---

## 🗄️ PostgreSQL 16 Healthcare Setup {#postgresql-16-healthcare-setup}

### 1. Installation & Configuration
```bash
# PostgreSQL 16 installation (Ubuntu/Debian)
sudo apt update
sudo apt install postgresql-16 postgresql-contrib-16

# Healthcare-specific extensions
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS pg_crypto;"
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS pg_audit;"

# Create healthcare database
sudo -u postgres createdb healthcare_platform
```

### 2. PostgreSQL Configuration for Healthcare
```ini
# /etc/postgresql/16/main/postgresql.conf
# Healthcare-optimized PostgreSQL configuration

# Memory Configuration
shared_buffers = 2GB                    # 25% of system RAM
effective_cache_size = 6GB              # 75% of system RAM
work_mem = 128MB                        # For complex healthcare queries
maintenance_work_mem = 512MB            # For index maintenance

# Connection Settings
max_connections = 200                   # Controlled via PgBouncer
shared_preload_libraries = 'pg_audit,pg_stat_statements'

# Write-Ahead Logging (Healthcare Compliance)
wal_level = replica                     # Required for streaming replication
archive_mode = on                       # Enable WAL archiving
archive_command = 'test ! -f /var/lib/postgresql/16/archive/%f && cp %p /var/lib/postgresql/16/archive/%f'
max_wal_senders = 3                     # For replication
wal_keep_size = 100GB                   # Retain WAL for compliance

# Checkpoint Configuration
checkpoint_timeout = 5min              # More frequent checkpoints
checkpoint_completion_target = 0.7      # Spread checkpoint I/O

# Healthcare-specific Security
ssl = on                                # Force SSL connections
ssl_cert_file = '/etc/ssl/certs/postgresql.crt'
ssl_key_file = '/etc/ssl/private/postgresql.key'
ssl_ca_file = '/etc/ssl/certs/ca-certificates.crt'

# Audit Configuration
pg_audit.log = 'ddl,write,role'         # Log DDL, writes, and role changes
pg_audit.log_catalog = off              # Don't log catalog queries
pg_audit.log_parameter = on             # Log parameters (masked for PII)

# Query Monitoring
log_statement = 'mod'                   # Log all modifications
log_min_duration_statement = 1000       # Log slow queries (1s+)
log_line_prefix = '%t [%p-%l] %q%u@%d ' # Include timestamp, user, database

# Row Security (RLS) - Critical for LGPD
row_security = on                       # Enable Row Level Security globally
```

### 3. Healthcare Database Schema Setup
```sql
-- /database/schemas/healthcare_base_schema.sql
-- Create healthcare database with proper security

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_audit";

-- Create schemas for separation of concerns
CREATE SCHEMA IF NOT EXISTS healthcare_data;
CREATE SCHEMA IF NOT EXISTS audit_trail;
CREATE SCHEMA IF NOT EXISTS security_policies;
CREATE SCHEMA IF NOT EXISTS encryption_keys;

-- Grant appropriate permissions
GRANT USAGE ON SCHEMA healthcare_data TO healthcare_app;
GRANT USAGE ON SCHEMA audit_trail TO healthcare_app;
GRANT SELECT ON SCHEMA security_policies TO healthcare_app;

-- Create roles for healthcare system
CREATE ROLE healthcare_admin;
CREATE ROLE healthcare_app;
CREATE ROLE healthcare_reader;
CREATE ROLE data_protection_officer;

-- Grant role hierarchy
GRANT healthcare_reader TO healthcare_app;
GRANT healthcare_app TO healthcare_admin;

-- LGPD-specific audit table
CREATE TABLE audit_trail.data_processing_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operation_type VARCHAR(50) NOT NULL, -- 'SELECT', 'INSERT', 'UPDATE', 'DELETE'
    table_name VARCHAR(100) NOT NULL,
    affected_columns TEXT[],
    user_id UUID,
    session_id UUID,
    ip_address INET,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    legal_basis VARCHAR(100), -- LGPD legal basis
    purpose TEXT, -- Purpose of data processing
    data_subject_id UUID, -- Subject of the data (patient, professional)
    retention_period INTERVAL, -- How long data should be kept
    encrypted_payload BYTEA -- Encrypted representation of changed data
);

-- Create index for performance
CREATE INDEX idx_data_processing_log_timestamp ON audit_trail.data_processing_log (timestamp);
CREATE INDEX idx_data_processing_log_table ON audit_trail.data_processing_log (table_name);
CREATE INDEX idx_data_processing_log_user ON audit_trail.data_processing_log (user_id);
CREATE INDEX idx_data_processing_log_subject ON audit_trail.data_processing_log (data_subject_id);
```

### 4. Ecto Healthcare Configuration
```elixir
# config/config.exs
config :healthcare_platform, HealthcarePlatform.Repo,
  database: "healthcare_platform",
  username: "healthcare_app",
  password: {:system, "DATABASE_PASSWORD"},
  hostname: "localhost",
  port: 5432,
  pool_size: 20,
  queue_target: 50,
  queue_interval: 1000,

  # Healthcare-specific configurations
  ssl: true,
  ssl_opts: [
    verify: :verify_peer,
    cacertfile: "/etc/ssl/certs/ca-certificates.crt",
    server_name_indication: 'healthcare-db.local'
  ],

  # Enable prepared statements for performance
  prepare: :named,

  # Connection parameters
  parameters: [
    search_path: "healthcare_data,public",
    application_name: "healthcare_platform_elixir",

    # LGPD compliance settings
    log_statement: "mod",
    log_min_duration_statement: "1000"
  ],

  # Enable Ecto SQL logging for audit purposes
  log: :info,

  # Configure connection pool for healthcare workload
  pool_timeout: 15_000,
  ownership_timeout: 30_000

# Configure multiple repos for separation of concerns
config :healthcare_platform, HealthcarePlatform.AuditRepo,
  database: "healthcare_platform",
  username: "healthcare_app",
  password: {:system, "DATABASE_PASSWORD"},
  hostname: "localhost",
  port: 5432,
  pool_size: 5, # Smaller pool for audit operations
  search_path: "audit_trail,public"
```

---

## ⏰ TimescaleDB Audit Trail Configuration {#timescaledb-audit-trail-configuration}

### 1. TimescaleDB Installation & Setup
```bash
# Install TimescaleDB extension
sudo apt install postgresql-16-timescaledb

# Add to PostgreSQL configuration
echo "shared_preload_libraries = 'timescaledb,pg_audit,pg_stat_statements'" >> /etc/postgresql/16/main/postgresql.conf

# Restart PostgreSQL
sudo systemctl restart postgresql

# Enable TimescaleDB in database
sudo -u postgres psql -d healthcare_platform -c "CREATE EXTENSION IF NOT EXISTS timescaledb;"

# Create hypertables for audit and metrics data
sudo -u postgres psql -d healthcare_platform -f /database/timescale_setup.sql
```

### 2. TimescaleDB Healthcare Hypertables
```sql
-- /database/timescale_setup.sql
-- TimescaleDB hypertables for healthcare audit and metrics

-- Create hypertable for audit trail (7-year retention)
SELECT create_hypertable('audit_trail.data_processing_log', 'timestamp',
  chunk_time_interval => INTERVAL '7 days',
  if_not_exists => TRUE
);

-- Create retention policy (7 years for healthcare compliance)
SELECT add_retention_policy('audit_trail.data_processing_log', INTERVAL '7 years');

-- Create compression policy (compress data older than 30 days)
ALTER TABLE audit_trail.data_processing_log SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'table_name, user_id',
  timescaledb.compress_orderby = 'timestamp DESC'
);

SELECT add_compression_policy('audit_trail.data_processing_log', INTERVAL '30 days');

-- Healthcare metrics hypertable
CREATE TABLE IF NOT EXISTS audit_trail.system_metrics (
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DOUBLE PRECISION,
    tags JSONB,
    source_system VARCHAR(50),
    environment VARCHAR(20) DEFAULT 'production'
);

SELECT create_hypertable('audit_trail.system_metrics', 'timestamp',
  chunk_time_interval => INTERVAL '1 day',
  if_not_exists => TRUE
);

-- User activity tracking hypertable
CREATE TABLE IF NOT EXISTS audit_trail.user_activity (
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID NOT NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    session_id UUID,
    success BOOLEAN DEFAULT TRUE,
    details JSONB
);

SELECT create_hypertable('audit_trail.user_activity', 'timestamp',
  chunk_time_interval => INTERVAL '7 days',
  if_not_exists => TRUE
);

-- Create materialized views for common healthcare analytics
CREATE MATERIALIZED VIEW audit_trail.daily_user_activity AS
SELECT
    time_bucket('1 day', timestamp) AS day,
    user_id,
    action,
    COUNT(*) as activity_count,
    COUNT(CASE WHEN success = false THEN 1 END) as failed_attempts
FROM audit_trail.user_activity
WHERE timestamp > NOW() - INTERVAL '30 days'
GROUP BY day, user_id, action
ORDER BY day DESC, activity_count DESC;

-- Refresh policy for materialized view
SELECT add_continuous_aggregate_policy('audit_trail.daily_user_activity',
  start_offset => INTERVAL '30 days',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour');

-- LGPD-specific data subject tracking
CREATE TABLE IF NOT EXISTS audit_trail.data_subject_access_log (
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_subject_id UUID NOT NULL,
    access_type VARCHAR(50) NOT NULL, -- 'portability', 'rectification', 'deletion'
    requested_by UUID, -- Who made the request
    processed_by UUID, -- Who processed the request
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'completed', 'rejected'
    response_data JSONB, -- Anonymized response data
    legal_notes TEXT,
    compliance_officer_review BOOLEAN DEFAULT FALSE
);

SELECT create_hypertable('audit_trail.data_subject_access_log', 'timestamp',
  chunk_time_interval => INTERVAL '30 days',
  if_not_exists => TRUE
);
```

### 3. Elixir TimescaleDB Integration
```elixir
# lib/healthcare_platform/audit/audit_logger.ex
defmodule HealthcarePlatform.Audit.AuditLogger do
  @moduledoc """
  LGPD-compliant audit logging using TimescaleDB hypertables
  """

  import Ecto.Query
  alias HealthcarePlatform.{Repo, AuditRepo}
  require Logger

  @doc """
  Log data processing activity with LGPD compliance metadata
  """
  def log_data_processing(params) do
    %{
      operation_type: operation_type,
      table_name: table_name,
      user_id: user_id,
      data_subject_id: data_subject_id,
      legal_basis: legal_basis,
      purpose: purpose
    } = params

    # Create audit entry
    audit_entry = %{
      id: Ecto.UUID.generate(),
      operation_type: to_string(operation_type),
      table_name: to_string(table_name),
      affected_columns: Map.get(params, :affected_columns, []),
      user_id: user_id,
      session_id: Map.get(params, :session_id),
      ip_address: Map.get(params, :ip_address),
      timestamp: DateTime.utc_now(),
      legal_basis: legal_basis,
      purpose: purpose,
      data_subject_id: data_subject_id,
      retention_period: calculate_retention_period(legal_basis),
      encrypted_payload: encrypt_audit_payload(params[:changed_data])
    }

    case insert_audit_log(audit_entry) do
      {:ok, _} -> :ok
      {:error, changeset} ->
        Logger.error("Failed to log audit entry: #{inspect(changeset.errors)}")
        {:error, :audit_log_failed}
    end
  end

  @doc """
  Log user activity for security monitoring
  """
  def log_user_activity(user_id, action, opts \\ []) do
    activity = %{
      timestamp: DateTime.utc_now(),
      user_id: user_id,
      action: to_string(action),
      resource_type: Keyword.get(opts, :resource_type),
      resource_id: Keyword.get(opts, :resource_id),
      ip_address: Keyword.get(opts, :ip_address),
      user_agent: Keyword.get(opts, :user_agent),
      session_id: Keyword.get(opts, :session_id),
      success: Keyword.get(opts, :success, true),
      details: Keyword.get(opts, :details, %{})
    }

    AuditRepo.insert_all("user_activity", [activity], on_conflict: :nothing)
  end

  @doc """
  Log LGPD data subject access requests
  """
  def log_data_subject_access(subject_id, access_type, opts \\ []) do
    access_log = %{
      timestamp: DateTime.utc_now(),
      data_subject_id: subject_id,
      access_type: to_string(access_type),
      requested_by: Keyword.get(opts, :requested_by),
      status: Keyword.get(opts, :status, "pending"),
      legal_notes: Keyword.get(opts, :legal_notes),
      compliance_officer_review: Keyword.get(opts, :requires_review, false)
    }

    AuditRepo.insert_all("data_subject_access_log", [access_log])
  end

  @doc """
  Query audit logs with LGPD compliance filters
  """
  def get_audit_logs(filters \\ %{}) do
    base_query =
      from log in "data_processing_log",
      select: %{
        id: log.id,
        operation_type: log.operation_type,
        table_name: log.table_name,
        user_id: log.user_id,
        timestamp: log.timestamp,
        legal_basis: log.legal_basis,
        purpose: log.purpose,
        data_subject_id: log.data_subject_id
      }

    query =
      base_query
      |> apply_date_filter(filters[:date_range])
      |> apply_user_filter(filters[:user_id])
      |> apply_table_filter(filters[:table_name])
      |> apply_data_subject_filter(filters[:data_subject_id])
      |> order_by([log], desc: log.timestamp)
      |> limit(^Map.get(filters, :limit, 1000))

    AuditRepo.all(query)
  end

  @doc """
  Generate compliance report for LGPD audits
  """
  def generate_compliance_report(start_date, end_date) do
    # Query TimescaleDB for comprehensive audit data
    query = """
    WITH audit_summary AS (
      SELECT
        table_name,
        legal_basis,
        COUNT(*) as operation_count,
        COUNT(DISTINCT user_id) as unique_users,
        COUNT(DISTINCT data_subject_id) as unique_subjects,
        MIN(timestamp) as first_access,
        MAX(timestamp) as last_access
      FROM audit_trail.data_processing_log
      WHERE timestamp BETWEEN $1 AND $2
      GROUP BY table_name, legal_basis
    ),
    subject_rights AS (
      SELECT
        access_type,
        COUNT(*) as request_count,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count,
        AVG(EXTRACT(EPOCH FROM (
          CASE WHEN status = 'completed'
          THEN timestamp
          ELSE NOW()
          END - timestamp
        )) / 86400) as avg_processing_days
      FROM audit_trail.data_subject_access_log
      WHERE timestamp BETWEEN $1 AND $2
      GROUP BY access_type
    )
    SELECT
      json_build_object(
        'period', json_build_object(
          'start', $1,
          'end', $2
        ),
        'data_processing', json_agg(
          json_build_object(
            'table', a.table_name,
            'legal_basis', a.legal_basis,
            'operations', a.operation_count,
            'unique_users', a.unique_users,
            'unique_subjects', a.unique_subjects,
            'first_access', a.first_access,
            'last_access', a.last_access
          )
        ),
        'subject_rights', (
          SELECT json_agg(
            json_build_object(
              'access_type', sr.access_type,
              'total_requests', sr.request_count,
              'completed_requests', sr.completed_count,
              'completion_rate',
                ROUND((sr.completed_count::DECIMAL / sr.request_count * 100), 2),
              'avg_processing_days', ROUND(sr.avg_processing_days, 2)
            )
          ) FROM subject_rights sr
        )
      ) as compliance_report
    FROM audit_summary a;
    """

    case AuditRepo.query(query, [start_date, end_date]) do
      {:ok, %{rows: [[report]]}} -> {:ok, report}
      {:error, error} -> {:error, error}
    end
  end

  # Private functions

  defp insert_audit_log(audit_entry) do
    AuditRepo.insert_all("data_processing_log", [audit_entry],
      on_conflict: :nothing,
      returning: [:id]
    )
  end

  defp calculate_retention_period(legal_basis) do
    case legal_basis do
      "Art. 11, I - consentimento específico" -> %Postgrex.Interval{years: 7} # Healthcare data
      "Art. 7º, II - cumprimento de obrigação legal" -> %Postgrex.Interval{years: 10} # Legal obligation
      "Art. 7º, III - execução de contrato" -> %Postgrex.Interval{years: 5} # Contract execution
      _ -> %Postgrex.Interval{years: 3} # Default retention
    end
  end

  defp encrypt_audit_payload(nil), do: nil
  defp encrypt_audit_payload(data) do
    # Use AES-256 encryption for sensitive audit data
    key = Application.get_env(:healthcare_platform, :audit_encryption_key)
    plaintext = Jason.encode!(data)

    :crypto.crypto_one_time(:aes_256_gcm, key, generate_iv(), plaintext, true)
  end

  defp generate_iv do
    :crypto.strong_rand_bytes(12) # 96-bit IV for GCM mode
  end

  # Filter helper functions
  defp apply_date_filter(query, nil), do: query
  defp apply_date_filter(query, {start_date, end_date}) do
    from log in query,
    where: log.timestamp >= ^start_date and log.timestamp <= ^end_date
  end

  defp apply_user_filter(query, nil), do: query
  defp apply_user_filter(query, user_id) do
    from log in query, where: log.user_id == ^user_id
  end

  defp apply_table_filter(query, nil), do: query
  defp apply_table_filter(query, table_name) do
    from log in query, where: log.table_name == ^table_name
  end

  defp apply_data_subject_filter(query, nil), do: query
  defp apply_data_subject_filter(query, subject_id) do
    from log in query, where: log.data_subject_id == ^subject_id
  end
end
```

---

## 🏥 Ecto Healthcare Schemas {#ecto-healthcare-schemas}

### 1. Core Healthcare Entities
```elixir
# lib/healthcare_platform/schemas/patient.ex
defmodule HealthcarePlatform.Schemas.Patient do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthcarePlatform.Audit.AuditLogger

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, only: [:id, :name, :birth_date, :gender, :status]}

  schema "patients" do
    field :cpf, HealthcarePlatform.Types.EncryptedString # Encrypted PII
    field :name, :string
    field :birth_date, :date
    field :gender, Ecto.Enum, values: [:male, :female, :other, :not_informed]
    field :status, Ecto.Enum, values: [:active, :inactive, :deceased], default: :active

    # Encrypted contact information
    field :phone, HealthcarePlatform.Types.EncryptedString
    field :email, HealthcarePlatform.Types.EncryptedString
    field :address, HealthcarePlatform.Types.EncryptedJSON

    # LGPD compliance fields
    field :consent_given_at, :utc_datetime
    field :consent_version, :string
    field :data_processing_purposes, {:array, :string}
    field :marketing_consent, :boolean, default: false
    field :research_consent, :boolean, default: false

    # Relationships
    has_many :medical_records, HealthcarePlatform.Schemas.MedicalRecord
    has_many :appointments, HealthcarePlatform.Schemas.Appointment
    has_many :prescriptions, HealthcarePlatform.Schemas.Prescription

    timestamps(type: :utc_datetime)
  end

  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [
      :cpf, :name, :birth_date, :gender, :phone, :email, :address,
      :consent_given_at, :consent_version, :data_processing_purposes,
      :marketing_consent, :research_consent, :status
    ])
    |> validate_required([:name, :birth_date, :consent_given_at, :consent_version])
    |> validate_cpf()
    |> validate_consent()
    |> unique_constraint(:cpf)
    |> prepare_changes(&log_patient_changes/1)
  end

  # LGPD compliance: Log all patient data changes
  defp log_patient_changes(%{action: action, data: patient} = changeset) when action in [:insert, :update, :delete] do
    # Extract changed fields
    changed_fields = case action do
      :insert -> Map.keys(patient.__struct__.__schema__(:fields))
      :update -> Map.keys(changeset.changes)
      :delete -> [:id] # Only log ID for deletions
    end

    # Log the change asynchronously to avoid blocking the transaction
    Task.start(fn ->
      AuditLogger.log_data_processing(%{
        operation_type: action,
        table_name: "patients",
        affected_columns: changed_fields,
        user_id: get_current_user_id(changeset),
        data_subject_id: patient.id,
        legal_basis: "Art. 11, I - consentimento específico",
        purpose: "Assistência médica e gestão de saúde",
        changed_data: sanitize_sensitive_data(changeset.changes)
      })
    end)

    changeset
  end
  defp log_patient_changes(changeset), do: changeset

  defp validate_cpf(changeset) do
    cpf = get_change(changeset, :cpf)

    if cpf && !valid_cpf?(cpf) do
      add_error(changeset, :cpf, "Invalid CPF format")
    else
      changeset
    end
  end

  defp validate_consent(changeset) do
    consent_at = get_change(changeset, :consent_given_at)
    consent_version = get_change(changeset, :consent_version)

    cond do
      is_nil(consent_at) ->
        add_error(changeset, :consent_given_at, "Consent timestamp is required for LGPD compliance")

      is_nil(consent_version) ->
        add_error(changeset, :consent_version, "Consent version is required for LGPD compliance")

      true ->
        changeset
    end
  end

  defp valid_cpf?(cpf) do
    # CPF validation logic (simplified)
    cpf_clean = String.replace(cpf, ~r/[^\d]/, "")
    String.length(cpf_clean) == 11 && !String.match?(cpf_clean, ~r/^(\d)\1{10}$/)
  end

  defp get_current_user_id(changeset) do
    # Extract user ID from changeset metadata or process dictionary
    Process.get(:current_user_id)
  end

  defp sanitize_sensitive_data(changes) do
    # Remove or mask sensitive data for audit log
    changes
    |> Map.delete(:cpf)
    |> Map.delete(:phone)
    |> Map.delete(:email)
    |> Map.put(:_note, "Sensitive fields masked for audit")
  end
end

# lib/healthcare_platform/schemas/medical_record.ex
defmodule HealthcarePlatform.Schemas.MedicalRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "medical_records" do
    field :record_number, :string
    field :chief_complaint, :string
    field :history_present_illness, :text
    field :physical_examination, :text
    field :diagnosis, :text
    field :treatment_plan, :text
    field :medications, :map # Structured medication data
    field :allergies, {:array, :string}
    field :vital_signs, :map # Structured vital signs data

    # FHIR compatibility fields
    field :fhir_resource, :map
    field :fhir_version, :string, default: "R4"

    # Encryption and security
    field :encryption_status, Ecto.Enum, values: [:encrypted, :not_encrypted], default: :encrypted
    field :access_level, Ecto.Enum, values: [:public, :restricted, :confidential], default: :confidential

    # Relationships
    belongs_to :patient, HealthcarePlatform.Schemas.Patient
    belongs_to :practitioner, HealthcarePlatform.Schemas.Practitioner
    belongs_to :healthcare_facility, HealthcarePlatform.Schemas.HealthcareFacility

    timestamps(type: :utc_datetime)
  end

  def changeset(medical_record, attrs) do
    medical_record
    |> cast(attrs, [
      :record_number, :chief_complaint, :history_present_illness,
      :physical_examination, :diagnosis, :treatment_plan, :medications,
      :allergies, :vital_signs, :fhir_resource, :fhir_version,
      :encryption_status, :access_level, :patient_id, :practitioner_id,
      :healthcare_facility_id
    ])
    |> validate_required([
      :record_number, :patient_id, :practitioner_id, :healthcare_facility_id
    ])
    |> validate_fhir_resource()
    |> foreign_key_constraint(:patient_id)
    |> foreign_key_constraint(:practitioner_id)
    |> foreign_key_constraint(:healthcare_facility_id)
    |> unique_constraint(:record_number)
  end

  defp validate_fhir_resource(changeset) do
    fhir_resource = get_change(changeset, :fhir_resource)

    if fhir_resource && not valid_fhir_resource?(fhir_resource) do
      add_error(changeset, :fhir_resource, "Invalid FHIR R4 resource structure")
    else
      changeset
    end
  end

  defp valid_fhir_resource?(resource) do
    # Basic FHIR R4 validation
    is_map(resource) &&
    Map.has_key?(resource, "resourceType") &&
    Map.has_key?(resource, "id")
  end
end
```

### 2. Post-Quantum Cryptography Encrypted Types
```elixir
# lib/healthcare_platform/types/encrypted_string.ex
defmodule HealthcarePlatform.Types.EncryptedString do
  @moduledoc """
  Custom Ecto type for PQC-encrypted strings (PII/PHI protection)
  """

  use Ecto.Type

  @impl true
  def type, do: :binary

  @impl true
  def cast(value) when is_binary(value), do: {:ok, value}
  def cast(_), do: :error

  @impl true
  def load(encrypted_data) when is_binary(encrypted_data) do
    case decrypt_with_pqc(encrypted_data) do
      {:ok, plaintext} -> {:ok, plaintext}
      {:error, _reason} -> :error
    end
  end
  def load(_), do: :error

  @impl true
  def dump(value) when is_binary(value) do
    case encrypt_with_pqc(value) do
      {:ok, encrypted} -> {:ok, encrypted}
      {:error, _reason} -> :error
    end
  end
  def dump(_), do: :error

  # Post-Quantum Cryptography encryption using CRYSTALS-Kyber + AES-256-GCM
  defp encrypt_with_pqc(plaintext) do
    try do
      # Generate ephemeral keypair for this encryption
      {:ok, {public_key, private_key}} = :pqcrypto.kyber_keypair()

      # Generate shared secret using healthcare platform's public key
      platform_public_key = get_platform_kyber_public_key()
      {:ok, shared_secret} = :pqcrypto.kyber_encapsulate(platform_public_key)

      # Derive AES key from shared secret
      aes_key = :crypto.hash(:sha256, shared_secret) |> binary_part(0, 32)

      # Encrypt with AES-256-GCM
      iv = :crypto.strong_rand_bytes(12)
      {ciphertext, auth_tag} = :crypto.crypto_one_time_aead(
        :aes_256_gcm, aes_key, iv, plaintext, "", true
      )

      # Package the encrypted result
      encrypted_package = %{
        algorithm: "CRYSTALS-Kyber-768 + AES-256-GCM",
        version: "1.0",
        public_key: Base.encode64(public_key),
        iv: Base.encode64(iv),
        ciphertext: Base.encode64(ciphertext),
        auth_tag: Base.encode64(auth_tag),
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
      }

      {:ok, :erlang.term_to_binary(encrypted_package)}
    rescue
      error -> {:error, "Encryption failed: #{inspect(error)}"}
    end
  end

  defp decrypt_with_pqc(encrypted_binary) do
    try do
      encrypted_package = :erlang.binary_to_term(encrypted_binary)

      # Extract components
      iv = Base.decode64!(encrypted_package.iv)
      ciphertext = Base.decode64!(encrypted_package.ciphertext)
      auth_tag = Base.decode64!(encrypted_package.auth_tag)

      # Reconstruct shared secret using platform's private key
      platform_private_key = get_platform_kyber_private_key()
      {:ok, shared_secret} = :pqcrypto.kyber_decapsulate(
        Base.decode64!(encrypted_package.public_key),
        platform_private_key
      )

      # Derive AES key
      aes_key = :crypto.hash(:sha256, shared_secret) |> binary_part(0, 32)

      # Decrypt with AES-256-GCM
      case :crypto.crypto_one_time_aead(:aes_256_gcm, aes_key, iv, ciphertext, "", auth_tag, false) do
        plaintext when is_binary(plaintext) -> {:ok, plaintext}
        :error -> {:error, "Decryption authentication failed"}
      end
    rescue
      error -> {:error, "Decryption failed: #{inspect(error)}"}
    end
  end

  defp get_platform_kyber_public_key do
    :persistent_term.get(:healthcare_platform_kyber_public_key) ||
    raise "Platform Kyber public key not initialized"
  end

  defp get_platform_kyber_private_key do
    :persistent_term.get(:healthcare_platform_kyber_private_key) ||
    raise "Platform Kyber private key not initialized"
  end
end

# lib/healthcare_platform/types/encrypted_json.ex
defmodule HealthcarePlatform.Types.EncryptedJSON do
  @moduledoc """
  Custom Ecto type for PQC-encrypted JSON data
  """

  use Ecto.Type

  @impl true
  def type, do: :binary

  @impl true
  def cast(value) when is_map(value), do: {:ok, value}
  def cast(value) when is_binary(value) do
    case Jason.decode(value) do
      {:ok, map} -> {:ok, map}
      {:error, _} -> :error
    end
  end
  def cast(_), do: :error

  @impl true
  def load(encrypted_data) when is_binary(encrypted_data) do
    with {:ok, json_string} <- HealthcarePlatform.Types.EncryptedString.load(encrypted_data),
         {:ok, map} <- Jason.decode(json_string) do
      {:ok, map}
    else
      _ -> :error
    end
  end
  def load(_), do: :error

  @impl true
  def dump(value) when is_map(value) do
    with {:ok, json_string} <- Jason.encode(value),
         {:ok, encrypted} <- HealthcarePlatform.Types.EncryptedString.dump(json_string) do
      {:ok, encrypted}
    else
      _ -> :error
    end
  end
  def dump(_), do: :error
end
```

---

## 🔐 LGPD Compliance Database Design {#lgpd-compliance-database-design}

### 1. Data Subject Rights Implementation
```sql
-- /database/migrations/create_data_subject_rights.sql
-- Implements LGPD data subject rights (Articles 18-22)

-- Create table for managing consent and data processing purposes
CREATE TABLE healthcare_data.consent_management (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_subject_id UUID NOT NULL, -- Reference to Patient or Practitioner
    data_subject_type VARCHAR(20) NOT NULL, -- 'patient' or 'practitioner'
    consent_version VARCHAR(10) NOT NULL,
    consent_given_at TIMESTAMPTZ NOT NULL,
    consent_withdrawn_at TIMESTAMPTZ,

    -- Specific consent for different processing purposes
    medical_treatment_consent BOOLEAN DEFAULT FALSE,
    data_portability_consent BOOLEAN DEFAULT FALSE,
    marketing_consent BOOLEAN DEFAULT FALSE,
    research_consent BOOLEAN DEFAULT FALSE,
    third_party_sharing_consent BOOLEAN DEFAULT FALSE,

    -- Legal basis for processing (LGPD Art. 7º and 11)
    legal_basis TEXT NOT NULL,
    processing_purposes TEXT[] NOT NULL,

    -- Data retention and deletion
    retention_period INTERVAL,
    automatic_deletion_date TIMESTAMPTZ,
    deletion_requested_at TIMESTAMPTZ,
    deletion_completed_at TIMESTAMPTZ,

    -- Metadata
    ip_address INET,
    user_agent TEXT,
    recorded_by UUID, -- User who recorded consent

    CONSTRAINT valid_data_subject_type CHECK (data_subject_type IN ('patient', 'practitioner')),
    CONSTRAINT consent_logic CHECK (
        (consent_withdrawn_at IS NULL) OR
        (consent_withdrawn_at > consent_given_at)
    )
);

-- Data portability support (LGPD Art. 18, II)
CREATE TABLE healthcare_data.data_portability_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_subject_id UUID NOT NULL,
    request_type VARCHAR(20) NOT NULL, -- 'export', 'transfer'
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    requested_by UUID NOT NULL, -- Who made the request

    -- Request details
    data_categories TEXT[], -- Which types of data to export
    export_format VARCHAR(10) DEFAULT 'json', -- 'json', 'fhir', 'pdf'
    include_metadata BOOLEAN DEFAULT FALSE,

    -- Processing status
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    processed_by UUID,
    completed_at TIMESTAMPTZ,

    -- Output information
    export_file_path TEXT, -- Path to generated export file
    export_file_hash VARCHAR(64), -- SHA-256 hash for integrity
    expiration_date TIMESTAMPTZ, -- When export file expires
    download_count INTEGER DEFAULT 0,
    last_downloaded_at TIMESTAMPTZ,

    -- Compliance tracking
    compliance_notes TEXT,
    legal_review_required BOOLEAN DEFAULT FALSE,
    legal_review_completed_by UUID,
    legal_review_completed_at TIMESTAMPTZ,

    CONSTRAINT valid_request_type CHECK (request_type IN ('export', 'transfer')),
    CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'expired')),
    CONSTRAINT valid_export_format CHECK (export_format IN ('json', 'fhir', 'pdf', 'xml'))
);

-- Data rectification tracking (LGPD Art. 18, III)
CREATE TABLE healthcare_data.data_rectification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_subject_id UUID NOT NULL,
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    requested_by UUID NOT NULL,

    -- What needs to be corrected
    table_name VARCHAR(100) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    current_value TEXT, -- Encrypted representation
    requested_value TEXT, -- Encrypted representation
    justification TEXT NOT NULL,

    -- Supporting documentation
    supporting_documents JSONB, -- References to uploaded documents

    -- Processing workflow
    status VARCHAR(20) DEFAULT 'pending',
    reviewed_by UUID, -- Healthcare professional who reviewed
    reviewed_at TIMESTAMPTZ,
    approved BOOLEAN,
    rejection_reason TEXT,

    -- Implementation
    implemented_by UUID,
    implemented_at TIMESTAMPTZ,
    old_value_backup TEXT, -- Encrypted backup of old value

    -- Compliance
    compliance_notes TEXT,
    notification_sent BOOLEAN DEFAULT FALSE,
    notification_sent_at TIMESTAMPTZ,

    CONSTRAINT valid_rectification_status CHECK (
        status IN ('pending', 'under_review', 'approved', 'rejected', 'implemented')
    )
);

-- Create indexes for performance
CREATE INDEX idx_consent_management_subject ON healthcare_data.consent_management (data_subject_id, data_subject_type);
CREATE INDEX idx_consent_management_active ON healthcare_data.consent_management (data_subject_id) WHERE consent_withdrawn_at IS NULL;
CREATE INDEX idx_portability_requests_status ON healthcare_data.data_portability_requests (status, requested_at);
CREATE INDEX idx_rectification_requests_status ON healthcare_data.data_rectification_requests (status, requested_at);

-- Row Level Security (RLS) policies for LGPD compliance
ALTER TABLE healthcare_data.consent_management ENABLE ROW LEVEL SECURITY;
ALTER TABLE healthcare_data.data_portability_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE healthcare_data.data_rectification_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see consent for their own data or patients they treat
CREATE POLICY consent_access_policy ON healthcare_data.consent_management
    FOR ALL
    TO healthcare_app
    USING (
        data_subject_id = current_setting('app.current_user_id')::UUID OR
        current_setting('app.user_role') = 'admin' OR
        (current_setting('app.user_role') = 'practitioner' AND
         data_subject_id IN (
             SELECT patient_id FROM patient_practitioner_relationships
             WHERE practitioner_id = current_setting('app.current_user_id')::UUID
         ))
    );

-- Policy: Data portability requests follow same access pattern
CREATE POLICY portability_access_policy ON healthcare_data.data_portability_requests
    FOR ALL
    TO healthcare_app
    USING (
        data_subject_id = current_setting('app.current_user_id')::UUID OR
        current_setting('app.user_role') IN ('admin', 'dpo') OR
        requested_by = current_setting('app.current_user_id')::UUID
    );
```

### 2. LGPD Compliance Helper Functions
```elixir
# lib/healthcare_platform/lgpd/compliance.ex
defmodule HealthcarePlatform.LGPD.Compliance do
  @moduledoc """
  LGPD compliance utilities for healthcare data processing
  """

  import Ecto.Query
  alias HealthcarePlatform.{Repo, Schemas}

  @doc """
  Process data subject access request (LGPD Art. 18, II)
  """
  def process_data_portability_request(data_subject_id, opts \\ []) do
    request_id = Ecto.UUID.generate()

    # Create portability request record
    request_attrs = %{
      id: request_id,
      data_subject_id: data_subject_id,
      request_type: Keyword.get(opts, :request_type, "export"),
      requested_by: Keyword.get(opts, :requested_by, data_subject_id),
      data_categories: Keyword.get(opts, :data_categories, ["all"]),
      export_format: Keyword.get(opts, :export_format, "json"),
      include_metadata: Keyword.get(opts, :include_metadata, false)
    }

    case Repo.insert_all("data_portability_requests", [request_attrs], returning: [:id]) do
      {1, [%{id: ^request_id}]} ->
        # Process asynchronously
        Task.start(fn ->
          generate_data_export(request_id)
        end)
        {:ok, request_id}

      error ->
        {:error, "Failed to create portability request: #{inspect(error)}"}
    end
  end

  @doc """
  Generate comprehensive data export for a data subject
  """
  def generate_data_export(request_id) do
    case get_portability_request(request_id) do
      {:ok, request} ->
        update_request_status(request_id, "processing")

        try do
          # Collect all data related to the subject
          data_export = %{
            request_id: request_id,
            generated_at: DateTime.utc_now(),
            data_subject_id: request.data_subject_id,
            export_format: request.export_format,
            data: collect_subject_data(request)
          }

          # Generate export file
          {:ok, file_path} = write_export_file(data_export, request.export_format)
          file_hash = compute_file_hash(file_path)

          # Update request with file information
          update_request_completion(request_id, file_path, file_hash)

          {:ok, file_path}
        rescue
          error ->
            update_request_status(request_id, "failed")
            {:error, "Export generation failed: #{inspect(error)}"}
        end

      error -> error
    end
  end

  @doc """
  Implement data rectification request (LGPD Art. 18, III)
  """
  def process_rectification_request(attrs) do
    changeset = %Schemas.DataRectificationRequest{}
    |> Schemas.DataRectificationRequest.changeset(attrs)

    case Repo.insert(changeset) do
      {:ok, request} ->
        # Notify relevant healthcare professionals
        notify_rectification_request(request)
        {:ok, request}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Validate consent for data processing (LGPD compliance check)
  """
  def validate_processing_consent(data_subject_id, processing_purpose) do
    query = from c in "consent_management",
      where: c.data_subject_id == ^data_subject_id,
      where: c.consent_withdrawn_at |> is_nil(),
      where: ^processing_purpose in c.processing_purposes,
      select: %{
        consent_given: true,
        consent_version: c.consent_version,
        legal_basis: c.legal_basis,
        retention_period: c.retention_period
      }

    case Repo.one(query) do
      nil ->
        {:error, :no_valid_consent,
         "No valid consent found for processing purpose: #{processing_purpose}"}

      consent_info ->
        # Check if consent is still within retention period
        if consent_still_valid?(consent_info.retention_period) do
          {:ok, consent_info}
        else
          {:error, :consent_expired,
           "Consent has expired based on retention period"}
        end
    end
  end

  @doc """
  Anonymize patient data for research purposes (LGPD Art. 7º, IV)
  """
  def anonymize_patient_data(patient_id, anonymization_level \\ :statistical) do
    case Repo.get(Schemas.Patient, patient_id) do
      nil -> {:error, :patient_not_found}
      patient ->
        anonymized_data = case anonymization_level do
          :statistical -> create_statistical_anonymization(patient)
          :research -> create_research_anonymization(patient)
          :k_anonymity -> create_k_anonymity_anonymization(patient)
        end

        {:ok, anonymized_data}
    end
  end

  # Private functions

  defp get_portability_request(request_id) do
    query = from r in "data_portability_requests",
      where: r.id == ^request_id,
      select: r

    case Repo.one(query) do
      nil -> {:error, :request_not_found}
      request -> {:ok, request}
    end
  end

  defp collect_subject_data(request) do
    data_subject_id = request.data_subject_id
    categories = request.data_categories

    collected_data = %{}

    # Collect patient data if requested
    if "all" in categories or "patient" in categories do
      collected_data = Map.put(collected_data, :patient_data,
        get_patient_data(data_subject_id))
    end

    # Collect medical records if requested
    if "all" in categories or "medical_records" in categories do
      collected_data = Map.put(collected_data, :medical_records,
        get_medical_records(data_subject_id))
    end

    # Collect appointments if requested
    if "all" in categories or "appointments" in categories do
      collected_data = Map.put(collected_data, :appointments,
        get_appointments(data_subject_id))
    end

    # Collect prescriptions if requested
    if "all" in categories or "prescriptions" in categories do
      collected_data = Map.put(collected_data, :prescriptions,
        get_prescriptions(data_subject_id))
    end

    # Add metadata if requested
    if request.include_metadata do
      collected_data = Map.put(collected_data, :metadata, %{
        collection_date: DateTime.utc_now(),
        consent_history: get_consent_history(data_subject_id),
        processing_log: get_processing_log(data_subject_id)
      })
    end

    collected_data
  end

  defp write_export_file(data_export, format) do
    filename = "data_export_#{data_export.request_id}_#{DateTime.utc_now() |> DateTime.to_unix()}.#{format}"
    file_path = Path.join([get_export_directory(), filename])

    content = case format do
      "json" -> Jason.encode!(data_export, pretty: true)
      "fhir" -> convert_to_fhir_bundle(data_export)
      "pdf" -> generate_pdf_export(data_export)
      "xml" -> convert_to_xml(data_export)
    end

    case File.write(file_path, content) do
      :ok -> {:ok, file_path}
      {:error, reason} -> {:error, "Failed to write export file: #{reason}"}
    end
  end

  defp compute_file_hash(file_path) do
    File.stream!(file_path, [:binary], 8192)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
  end

  defp update_request_status(request_id, status) do
    from(r in "data_portability_requests", where: r.id == ^request_id)
    |> Repo.update_all(set: [status: status, updated_at: DateTime.utc_now()])
  end

  defp update_request_completion(request_id, file_path, file_hash) do
    expiration_date = DateTime.utc_now() |> DateTime.add(30, :day) # 30 days to download

    from(r in "data_portability_requests", where: r.id == ^request_id)
    |> Repo.update_all(set: [
      status: "completed",
      export_file_path: file_path,
      export_file_hash: file_hash,
      expiration_date: expiration_date,
      completed_at: DateTime.utc_now()
    ])
  end

  defp consent_still_valid?(retention_period) do
    # Implementation depends on how retention_period is stored
    # This is a simplified check
    true
  end

  defp get_export_directory do
    Application.get_env(:healthcare_platform, :data_export_directory, "/tmp/healthcare_exports")
  end

  # Helper functions for data collection (simplified)
  defp get_patient_data(patient_id), do: Repo.get(Schemas.Patient, patient_id)
  defp get_medical_records(patient_id), do: Repo.all(from m in Schemas.MedicalRecord, where: m.patient_id == ^patient_id)
  defp get_appointments(patient_id), do: [] # Implementation needed
  defp get_prescriptions(patient_id), do: [] # Implementation needed
  defp get_consent_history(subject_id), do: [] # Implementation needed
  defp get_processing_log(subject_id), do: [] # Implementation needed

  # Anonymization functions (simplified)
  defp create_statistical_anonymization(patient), do: %{id: "anonymized", age_range: "30-40"}
  defp create_research_anonymization(patient), do: %{id: "research_#{:rand.uniform(10000)}"}
  defp create_k_anonymity_anonymization(patient), do: %{id: "k_anon_group_#{:rand.uniform(100)}"}

  # Format conversion functions (simplified)
  defp convert_to_fhir_bundle(data), do: Jason.encode!(%{resourceType: "Bundle", entry: []})
  defp generate_pdf_export(data), do: "PDF content placeholder"
  defp convert_to_xml(data), do: "XML content placeholder"

  defp notify_rectification_request(request) do
    # Send notification to healthcare professionals
    # Implementation needed
  end
end
```

---

## ⚡ Performance Tuning {#performance-tuning}

### 1. Healthcare-Specific Indexes
```sql
-- /database/performance/healthcare_indexes.sql
-- Optimized indexes for healthcare queries

-- Patient search optimization
CREATE INDEX CONCURRENTLY idx_patients_name_trgm ON patients USING gin (name gin_trgm_ops);
CREATE INDEX CONCURRENTLY idx_patients_cpf_hash ON patients USING btree (encode(digest(cpf, 'sha256'), 'hex'));
CREATE INDEX CONCURRENTLY idx_patients_birth_date ON patients (birth_date);
CREATE INDEX CONCURRENTLY idx_patients_active ON patients (status, updated_at) WHERE status = 'active';

-- Medical records performance
CREATE INDEX CONCURRENTLY idx_medical_records_patient_date ON medical_records (patient_id, created_at DESC);
CREATE INDEX CONCURRENTLY idx_medical_records_practitioner ON medical_records (practitioner_id, created_at DESC);
CREATE INDEX CONCURRENTLY idx_medical_records_diagnosis_trgm ON medical_records USING gin (diagnosis gin_trgm_ops);
CREATE INDEX CONCURRENTLY idx_medical_records_fhir_search ON medical_records USING gin (fhir_resource);

-- Audit trail optimization (TimescaleDB hypertables)
CREATE INDEX CONCURRENTLY idx_audit_log_user_time ON audit_trail.data_processing_log (user_id, timestamp DESC);
CREATE INDEX CONCURRENTLY idx_audit_log_table_time ON audit_trail.data_processing_log (table_name, timestamp DESC);
CREATE INDEX CONCURRENTLY idx_audit_log_subject_time ON audit_trail.data_processing_log (data_subject_id, timestamp DESC);

-- LGPD compliance indexes
CREATE INDEX CONCURRENTLY idx_consent_subject_active ON healthcare_data.consent_management (data_subject_id, consent_withdrawn_at) WHERE consent_withdrawn_at IS NULL;
CREATE INDEX CONCURRENTLY idx_portability_status_date ON healthcare_data.data_portability_requests (status, requested_at DESC);

-- Full-text search for medical content
CREATE INDEX CONCURRENTLY idx_medical_content_fts ON medical_records USING gin (to_tsvector('portuguese', coalesce(chief_complaint, '') || ' ' || coalesce(diagnosis, '') || ' ' || coalesce(treatment_plan, '')));
```

### 2. Query Optimization Examples
```elixir
# lib/healthcare_platform/queries/optimized_queries.ex
defmodule HealthcarePlatform.Queries.OptimizedQueries do
  @moduledoc """
  Optimized database queries for healthcare platform
  """

  import Ecto.Query
  alias HealthcarePlatform.{Repo, Schemas}

  @doc """
  Optimized patient search with trigram matching
  """
  def search_patients(search_term, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    include_inactive = Keyword.get(opts, :include_inactive, false)

    base_query =
      from p in Schemas.Patient,
      select: %{
        id: p.id,
        name: p.name,
        birth_date: p.birth_date,
        status: p.status,
        similarity: fragment("similarity(?, ?)", p.name, ^search_term)
      }

    query =
      base_query
      |> where([p], fragment("? % ?", p.name, ^search_term))
      |> apply_status_filter(include_inactive)
      |> order_by([p], desc: fragment("similarity(?, ?)", p.name, ^search_term))
      |> limit(^limit)
      |> offset(^offset)

    Repo.all(query)
  end

  @doc """
  Efficient medical records retrieval with preloading
  """
  def get_patient_medical_history(patient_id, opts \\ []) do
    days_back = Keyword.get(opts, :days_back, 365)
    limit = Keyword.get(opts, :limit, 100)
    cutoff_date = DateTime.utc_now() |> DateTime.add(-days_back, :day)

    query =
      from mr in Schemas.MedicalRecord,
      where: mr.patient_id == ^patient_id,
      where: mr.inserted_at >= ^cutoff_date,
      order_by: [desc: mr.inserted_at],
      limit: ^limit,
      preload: [:practitioner, :healthcare_facility]

    Repo.all(query)
  end

  @doc """
  Optimized audit log query with TimescaleDB time-bucket aggregation
  """
  def get_audit_summary(date_range, granularity \\ "1 hour") do
    {start_date, end_date} = date_range

    query = """
    SELECT
      time_bucket($3, timestamp) AS time_bucket,
      operation_type,
      table_name,
      COUNT(*) as operation_count,
      COUNT(DISTINCT user_id) as unique_users
    FROM audit_trail.data_processing_log
    WHERE timestamp BETWEEN $1 AND $2
    GROUP BY time_bucket, operation_type, table_name
    ORDER BY time_bucket DESC, operation_count DESC;
    """

    case Repo.query(query, [start_date, end_date, granularity]) do
      {:ok, %{rows: rows, columns: columns}} ->
        {:ok, Enum.map(rows, fn row ->
          columns
          |> Enum.zip(row)
          |> Map.new()
        end)}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  LGPD compliance check with efficient consent validation
  """
  def validate_data_processing_consent(data_subject_id, processing_purposes) do
    # Use a single query to check all purposes at once
    query =
      from c in "consent_management",
      where: c.data_subject_id == ^data_subject_id,
      where: is_nil(c.consent_withdrawn_at),
      where: fragment("? && ?", c.processing_purposes, ^processing_purposes),
      select: %{
        valid_purposes: fragment("? & ?", c.processing_purposes, ^processing_purposes),
        consent_version: c.consent_version,
        legal_basis: c.legal_basis,
        retention_until: fragment("? + ?", c.consent_given_at, c.retention_period)
      }

    case Repo.one(query) do
      nil -> {:error, :no_valid_consent}
      consent_info ->
        # Check if all requested purposes are covered
        valid_purposes = consent_info.valid_purposes
        if length(valid_purposes) == length(processing_purposes) do
          {:ok, consent_info}
        else
          missing_purposes = processing_purposes -- valid_purposes
          {:error, :partial_consent, missing_purposes: missing_purposes}
        end
    end
  end

  @doc """
  High-performance practitioner workload analysis
  """
  def analyze_practitioner_workload(practitioner_id, date_range) do
    {start_date, end_date} = date_range

    # Use window functions for efficient aggregation
    query = """
    WITH daily_stats AS (
      SELECT
        DATE(created_at) as date,
        COUNT(*) as records_created,
        COUNT(DISTINCT patient_id) as unique_patients,
        AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) as avg_completion_time
      FROM medical_records
      WHERE practitioner_id = $1
        AND created_at BETWEEN $2 AND $3
      GROUP BY DATE(created_at)
    ),
    workload_metrics AS (
      SELECT
        date,
        records_created,
        unique_patients,
        avg_completion_time,
        AVG(records_created) OVER (
          ORDER BY date
          ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as rolling_7day_avg,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_completion_time) OVER (
          ORDER BY date
          ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as median_completion_time
      FROM daily_stats
    )
    SELECT * FROM workload_metrics ORDER BY date DESC;
    """

    case Repo.query(query, [practitioner_id, start_date, end_date]) do
      {:ok, %{rows: rows, columns: columns}} ->
        workload_data = Enum.map(rows, fn row ->
          columns |> Enum.zip(row) |> Map.new()
        end)
        {:ok, workload_data}

      {:error, error} ->
        {:error, error}
    end
  end

  # Helper functions

  defp apply_status_filter(query, true = _include_inactive), do: query
  defp apply_status_filter(query, false) do
    where(query, [p], p.status == :active)
  end
end
```

### 3. Database Monitoring & Alerting
```elixir
# lib/healthcare_platform/monitoring/database_monitor.ex
defmodule HealthcarePlatform.Monitoring.DatabaseMonitor do
  @moduledoc """
  Database performance monitoring for healthcare platform
  """

  use GenServer
  require Logger

  @monitoring_interval 60_000 # 1 minute

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    schedule_monitoring()
    {:ok, %{last_check: DateTime.utc_now()}}
  end

  def handle_info(:monitor_database, state) do
    perform_health_checks()
    schedule_monitoring()
    {:noreply, %{state | last_check: DateTime.utc_now()}}
  end

  defp perform_health_checks do
    checks = [
      &check_connection_pool/0,
      &check_slow_queries/0,
      &check_lock_waits/0,
      &check_replication_lag/0,
      &check_disk_space/0,
      &check_audit_trail_health/0
    ]

    Enum.each(checks, fn check_fn ->
      try do
        check_fn.()
      rescue
        error ->
          Logger.error("Database health check failed: #{inspect(error)}")
      end
    end)
  end

  defp check_connection_pool do
    pool_status = DBConnection.get_conn_metadata(HealthcarePlatform.Repo, :pool)

    if pool_status.available_count < 3 do
      Logger.warn("Low database connection pool: #{pool_status.available_count} available")

      # Alert if connection pool is critically low
      if pool_status.available_count == 0 do
        send_alert(:critical, "Database connection pool exhausted")
      end
    end
  end

  defp check_slow_queries do
    slow_query_threshold = 5000 # 5 seconds

    query = """
    SELECT query, mean_exec_time, calls, total_exec_time
    FROM pg_stat_statements
    WHERE mean_exec_time > $1
    ORDER BY mean_exec_time DESC
    LIMIT 10;
    """

    case HealthcarePlatform.Repo.query(query, [slow_query_threshold]) do
      {:ok, %{rows: rows}} when length(rows) > 0 ->
        Logger.warn("Detected #{length(rows)} slow queries over #{slow_query_threshold}ms")

        Enum.each(rows, fn [query_text, mean_time, calls, total_time] ->
          Logger.warn("Slow query: #{Float.round(mean_time, 2)}ms avg, #{calls} calls - #{String.slice(query_text, 0, 100)}...")
        end)

      _ -> :ok
    end
  end

  defp check_lock_waits do
    query = """
    SELECT
      waiting.locktype,
      waiting.relation::regclass,
      waiting.mode,
      waiting.pid AS waiting_pid,
      waiting_query.query AS waiting_query,
      blocking.pid AS blocking_pid,
      blocking_query.query AS blocking_query
    FROM pg_locks waiting
    JOIN pg_stat_activity waiting_query ON waiting_query.pid = waiting.pid
    JOIN pg_locks blocking ON (
      waiting."database" = blocking."database" AND
      waiting.relation = blocking.relation OR
      waiting.transactionid = blocking.transactionid
    )
    JOIN pg_stat_activity blocking_query ON blocking_query.pid = blocking.pid
    WHERE NOT waiting.granted AND blocking.granted
      AND waiting.pid <> blocking.pid;
    """

    case HealthcarePlatform.Repo.query(query, []) do
      {:ok, %{rows: rows}} when length(rows) > 0 ->
        Logger.warn("Detected #{length(rows)} blocked queries")
        send_alert(:warning, "Database lock contention detected: #{length(rows)} blocked queries")

      _ -> :ok
    end
  end

  defp check_replication_lag do
    # Check streaming replication lag
    query = """
    SELECT
      client_addr,
      client_hostname,
      state,
      pg_wal_lsn_diff(pg_current_wal_lsn(), flush_lsn) AS flush_lag_bytes,
      pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS replay_lag_bytes
    FROM pg_stat_replication;
    """

    case HealthcarePlatform.Repo.query(query, []) do
      {:ok, %{rows: rows}} ->
        Enum.each(rows, fn [addr, hostname, state, flush_lag, replay_lag] ->
          # Alert if replication lag is over 100MB
          if flush_lag > 100_000_000 or replay_lag > 100_000_000 do
            Logger.error("High replication lag: #{addr} - Flush: #{flush_lag} bytes, Replay: #{replay_lag} bytes")
            send_alert(:critical, "High database replication lag detected")
          end
        end)

      _ -> :ok
    end
  end

  defp check_disk_space do
    query = """
    SELECT
      pg_database.datname,
      pg_size_pretty(pg_database_size(pg_database.datname)) AS size
    FROM pg_database
    WHERE datname = current_database();
    """

    case HealthcarePlatform.Repo.query(query, []) do
      {:ok, %{rows: [[_db_name, size]]}} ->
        # Basic size monitoring - implement more sophisticated disk space checking
        Logger.info("Database size: #{size}")

      _ -> :ok
    end
  end

  defp check_audit_trail_health do
    # Check TimescaleDB hypertable health
    query = """
    SELECT
      schemaname,
      tablename,
      num_chunks,
      table_bytes,
      index_bytes,
      toast_bytes,
      total_bytes
    FROM timescaledb_information.hypertables h
    JOIN timescaledb_information.chunks c ON c.hypertable_name = h.table_name
    WHERE h.table_name = 'data_processing_log'
    GROUP BY schemaname, tablename, table_bytes, index_bytes, toast_bytes, total_bytes;
    """

    case HealthcarePlatform.Repo.query(query, []) do
      {:ok, %{rows: rows}} when length(rows) > 0 ->
        Enum.each(rows, fn [schema, table, chunks, table_bytes, index_bytes, toast_bytes, total_bytes] ->
          Logger.info("Audit hypertable health: #{schema}.#{table} - #{chunks} chunks, #{total_bytes} bytes total")

          # Alert if audit table is growing too fast
          if total_bytes > 10_000_000_000 do # 10GB
            Logger.warn("Audit trail size is large: #{total_bytes} bytes")
          end
        end)

      _ ->
        Logger.error("Unable to check TimescaleDB hypertable health")
    end
  end

  defp send_alert(level, message) do
    # Integration with alerting system (Slack, email, PagerDuty, etc.)
    Logger.log(level, "DATABASE ALERT: #{message}")

    # Here you would integrate with your alerting system
    # Example: Slack notification, email, PagerDuty, etc.
  end

  defp schedule_monitoring do
    Process.send_after(self(), :monitor_database, @monitoring_interval)
  end
end
```

---

## 💾 Backup & Recovery {#backup-recovery}

### 1. Automated Backup Strategy
```bash
#!/bin/bash
# /scripts/backup/healthcare_backup.sh
# LGPD-compliant database backup with encryption

set -euo pipefail

# Configuration
DB_NAME="healthcare_platform"
DB_USER="healthcare_app"
BACKUP_DIR="/var/backups/healthcare"
S3_BUCKET="healthcare-backups-encrypted"
RETENTION_DAYS=2555 # 7 years for healthcare compliance
GPG_KEY_ID="healthcare-backup@company.com"

# Logging
exec 1> >(logger -s -t healthcare_backup)
exec 2>&1

echo "Starting healthcare database backup - $(date)"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Generate backup filename with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="healthcare_${TIMESTAMP}.sql"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"

# Create database dump
echo "Creating database dump..."
PGPASSWORD=$DATABASE_PASSWORD pg_dump \
  --host=localhost \
  --port=5432 \
  --username=$DB_USER \
  --dbname=$DB_NAME \
  --verbose \
  --no-password \
  --format=custom \
  --compress=9 \
  --file="$BACKUP_PATH" \
  --exclude-table-data='audit_trail.*' # Exclude large audit tables from main backup

# Verify backup integrity
echo "Verifying backup integrity..."
pg_restore --list "$BACKUP_PATH" > /dev/null
if [ $? -eq 0 ]; then
    echo "Backup integrity verified"
else
    echo "ERROR: Backup integrity check failed!"
    exit 1
fi

# Encrypt backup using GPG (PQC-ready)
echo "Encrypting backup..."
ENCRYPTED_FILE="${BACKUP_PATH}.gpg"
gpg --trust-model always --encrypt --recipient "$GPG_KEY_ID" --output "$ENCRYPTED_FILE" "$BACKUP_PATH"

# Remove unencrypted backup
rm "$BACKUP_PATH"

# Upload to S3 with server-side encryption
echo "Uploading to S3..."
aws s3 cp "$ENCRYPTED_FILE" "s3://$S3_BUCKET/database/$(basename $ENCRYPTED_FILE)" \
  --server-side-encryption aws:kms \
  --sse-kms-key-id alias/healthcare-backup-key \
  --storage-class STANDARD_IA

# Verify S3 upload
aws s3 head-object --bucket "$S3_BUCKET" --key "database/$(basename $ENCRYPTED_FILE)" > /dev/null
if [ $? -eq 0 ]; then
    echo "S3 upload verified"
    # Remove local encrypted file after successful upload
    rm "$ENCRYPTED_FILE"
else
    echo "ERROR: S3 upload verification failed!"
    exit 1
fi

# Separate TimescaleDB audit trail backup
echo "Backing up audit trail..."
AUDIT_BACKUP_FILE="healthcare_audit_${TIMESTAMP}.sql"
AUDIT_BACKUP_PATH="${BACKUP_DIR}/${AUDIT_BACKUP_FILE}"

PGPASSWORD=$DATABASE_PASSWORD pg_dump \
  --host=localhost \
  --port=5432 \
  --username=$DB_USER \
  --dbname=$DB_NAME \
  --verbose \
  --no-password \
  --format=custom \
  --compress=9 \
  --file="$AUDIT_BACKUP_PATH" \
  --schema=audit_trail

# Encrypt audit backup
ENCRYPTED_AUDIT_FILE="${AUDIT_BACKUP_PATH}.gpg"
gpg --trust-model always --encrypt --recipient "$GPG_KEY_ID" --output "$ENCRYPTED_AUDIT_FILE" "$AUDIT_BACKUP_PATH"
rm "$AUDIT_BACKUP_PATH"

# Upload audit backup to S3
aws s3 cp "$ENCRYPTED_AUDIT_FILE" "s3://$S3_BUCKET/audit/$(basename $ENCRYPTED_AUDIT_FILE)" \
  --server-side-encryption aws:kms \
  --sse-kms-key-id alias/healthcare-backup-key \
  --storage-class GLACIER # Cheaper for long-term audit retention

rm "$ENCRYPTED_AUDIT_FILE"

# Cleanup old backups (keep only what's needed for compliance)
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -name "healthcare_*.sql.gpg" -mtime +7 -delete

# S3 lifecycle policy handles long-term retention and deletion

echo "Healthcare database backup completed successfully - $(date)"

# Log backup completion to audit trail
echo "INSERT INTO audit_trail.system_metrics (timestamp, metric_name, metric_value, tags) VALUES (NOW(), 'backup_completed', 1, '{\"type\": \"database\", \"encrypted\": true}');" | PGPASSWORD=$DATABASE_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME
```

### 2. Point-in-Time Recovery Setup
```bash
#!/bin/bash
# /scripts/recovery/setup_pitr.sh
# Configure Point-in-Time Recovery for healthcare compliance

set -euo pipefail

# Configuration
PG_VERSION="16"
PG_DATA="/var/lib/postgresql/16/main"
WAL_ARCHIVE_DIR="/var/lib/postgresql/wal_archive"
S3_WAL_BUCKET="healthcare-wal-archive"

echo "Setting up Point-in-Time Recovery for healthcare database"

# Create WAL archive directory
mkdir -p "$WAL_ARCHIVE_DIR"
chown postgres:postgres "$WAL_ARCHIVE_DIR"
chmod 700 "$WAL_ARCHIVE_DIR"

# Configure PostgreSQL for WAL archiving
cat >> /etc/postgresql/$PG_VERSION/main/postgresql.conf << EOF

# Point-in-Time Recovery Configuration
wal_level = replica                     # Enable WAL for PITR
archive_mode = on                       # Enable WAL archiving
archive_command = '/scripts/recovery/archive_wal.sh %p %f'
archive_timeout = 300                   # Force WAL switch every 5 minutes
max_wal_senders = 5                     # Allow for replication
wal_keep_size = 1000MB                  # Keep WAL files for recovery
checkpoint_timeout = 5min              # More frequent checkpoints
checkpoint_completion_target = 0.8      # Smooth checkpoint I/O

# Recovery Configuration
restore_command = '/scripts/recovery/restore_wal.sh %f %p'
recovery_target_timeline = 'latest'

EOF

# Create WAL archive script
cat > /scripts/recovery/archive_wal.sh << 'EOF'
#!/bin/bash
# Archive WAL files to local storage and S3

WAL_FILE="$1"
WAL_FILENAME="$2"
LOCAL_ARCHIVE="/var/lib/postgresql/wal_archive"
S3_BUCKET="healthcare-wal-archive"

# Copy to local archive first (fast)
cp "$WAL_FILE" "$LOCAL_ARCHIVE/$WAL_FILENAME"

# Upload to S3 asynchronously
(
    aws s3 cp "$LOCAL_ARCHIVE/$WAL_FILENAME" "s3://$S3_BUCKET/wal/$WAL_FILENAME" \
        --server-side-encryption aws:kms \
        --sse-kms-key-id alias/healthcare-backup-key &
)

# Return success immediately (PostgreSQL needs fast archive_command)
exit 0
EOF

# Create WAL restore script
cat > /scripts/recovery/restore_wal.sh << 'EOF'
#!/bin/bash
# Restore WAL files for Point-in-Time Recovery

WAL_FILENAME="$1"
WAL_DESTINATION="$2"
LOCAL_ARCHIVE="/var/lib/postgresql/wal_archive"
S3_BUCKET="healthcare-wal-archive"

# Try local archive first
if [ -f "$LOCAL_ARCHIVE/$WAL_FILENAME" ]; then
    cp "$LOCAL_ARCHIVE/$WAL_FILENAME" "$WAL_DESTINATION"
    exit 0
fi

# Download from S3 if not found locally
aws s3 cp "s3://$S3_BUCKET/wal/$WAL_FILENAME" "$WAL_DESTINATION" 2>/dev/null
if [ $? -eq 0 ]; then
    exit 0
fi

# WAL file not found
exit 1
EOF

# Make scripts executable
chmod +x /scripts/recovery/archive_wal.sh
chmod +x /scripts/recovery/restore_wal.sh

# Create recovery script for healthcare emergencies
cat > /scripts/recovery/healthcare_emergency_recovery.sh << 'EOF'
#!/bin/bash
# Emergency recovery script for healthcare database
# Usage: ./healthcare_emergency_recovery.sh [RECOVERY_TARGET_TIME]

set -euo pipefail

RECOVERY_TARGET_TIME="$1"
PG_DATA="/var/lib/postgresql/16/main"
BACKUP_DIR="/var/backups/healthcare"

echo "HEALTHCARE EMERGENCY RECOVERY INITIATED"
echo "Target recovery time: $RECOVERY_TARGET_TIME"
echo "$(date): Starting emergency recovery procedure"

# Stop PostgreSQL
systemctl stop postgresql

# Backup current data directory (just in case)
mv "$PG_DATA" "${PG_DATA}.emergency_backup.$(date +%s)"

# Find the most recent base backup before the target time
LATEST_BACKUP=$(find "$BACKUP_DIR" -name "healthcare_*.sql.gpg" -type f -exec stat -c "%Y %n" {} \; | sort -n | tail -1 | cut -d' ' -f2-)

if [ -z "$LATEST_BACKUP" ]; then
    echo "ERROR: No base backup found!"
    exit 1
fi

echo "Using base backup: $LATEST_BACKUP"

# Decrypt and restore base backup
GPG_KEY_ID="healthcare-backup@company.com"
DECRYPTED_BACKUP="${LATEST_BACKUP%.gpg}"

gpg --decrypt "$LATEST_BACKUP" > "$DECRYPTED_BACKUP"

# Initialize new data directory
sudo -u postgres initdb "$PG_DATA"

# Create recovery.conf
cat > "$PG_DATA/recovery.conf" << RECOVERY_EOF
restore_command = '/scripts/recovery/restore_wal.sh %f %p'
recovery_target_time = '$RECOVERY_TARGET_TIME'
recovery_target_timeline = 'latest'
recovery_target_action = 'promote'
RECOVERY_EOF

chown postgres:postgres "$PG_DATA/recovery.conf"

# Restore base backup
sudo -u postgres pg_restore \
    --dbname=template1 \
    --create \
    --verbose \
    "$DECRYPTED_BACKUP"

# Start PostgreSQL in recovery mode
systemctl start postgresql

echo "Recovery initiated. Check PostgreSQL logs for recovery progress."
echo "Once recovery is complete, the server will automatically promote to primary."

# Clean up decrypted backup
rm "$DECRYPTED_BACKUP"

echo "$(date): Emergency recovery procedure completed"
EOF

chmod +x /scripts/recovery/healthcare_emergency_recovery.sh

# Restart PostgreSQL to apply new configuration
systemctl restart postgresql

echo "Point-in-Time Recovery setup completed successfully"
echo "WAL archiving is now active. Recovery scripts are available at:"
echo "  - Emergency recovery: /scripts/recovery/healthcare_emergency_recovery.sh"
echo "  - WAL archive: /scripts/recovery/archive_wal.sh"
echo "  - WAL restore: /scripts/recovery/restore_wal.sh"
```

---

## 🔍 Troubleshooting Guide {#troubleshooting-guide}

### Common Issues & Solutions

#### 1. **PostgreSQL Connection Pool Exhaustion**
```elixir
# Problem: "all connections busy" or connection timeouts
# Solution: Analyze and optimize connection usage

# Add to application.ex
defmodule HealthcarePlatform.Application do
  def start(_type, _args) do
    children = [
      # Add connection pool monitoring
      {Task.Supervisor, name: HealthcarePlatform.TaskSupervisor},
      {HealthcarePlatform.ConnectionMonitor, []},
      # ... other children
    ]

    opts = [strategy: :one_for_one, name: HealthcarePlatform.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

# lib/healthcare_platform/connection_monitor.ex
defmodule HealthcarePlatform.ConnectionMonitor do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    schedule_check()
    {:ok, %{}}
  end

  def handle_info(:check_connections, state) do
    pool_size = Application.get_env(:healthcare_platform, HealthcarePlatform.Repo)[:pool_size] || 20

    # Check current pool usage
    case DBConnection.get_connection_metrics(HealthcarePlatform.Repo) do
      %{pool_size: ^pool_size, available_count: available} when available < 3 ->
        Logger.warn("Low database connections: #{available}/#{pool_size} available")

        # Log slow queries that might be holding connections
        log_slow_queries()

      _ -> :ok
    end

    schedule_check()
    {:noreply, state}
  end

  defp schedule_check do
    Process.send_after(self(), :check_connections, 30_000) # Check every 30 seconds
  end

  defp log_slow_queries do
    query = """
    SELECT pid, now() - query_start as duration, query
    FROM pg_stat_activity
    WHERE state = 'active'
      AND now() - query_start > interval '10 seconds'
    ORDER BY duration DESC;
    """

    case HealthcarePlatform.Repo.query(query, []) do
      {:ok, %{rows: rows}} when length(rows) > 0 ->
        Logger.warn("Found #{length(rows)} long-running queries")
        Enum.each(rows, fn [pid, duration, query] ->
          Logger.warn("Long query (PID #{pid}, #{duration}): #{String.slice(query, 0, 100)}...")
        end)
      _ -> :ok
    end
  end
end
```

#### 2. **TimescaleDB Hypertable Performance Issues**
```sql
-- Problem: Slow queries on audit trail hypertables
-- Solution: Optimize chunk size and compression

-- Check hypertable statistics
SELECT
    schemaname,
    tablename,
    num_chunks,
    table_bytes,
    index_bytes,
    compressed_heap_size,
    uncompressed_heap_size
FROM timescaledb_information.hypertables h
LEFT JOIN timescaledb_information.hypertable_compression_stats cs
ON h.table_name = cs.table_name;

-- Optimize chunk interval if needed
SELECT set_chunk_time_interval('audit_trail.data_processing_log', INTERVAL '1 day');

-- Add more aggressive compression for older data
ALTER TABLE audit_trail.data_processing_log SET (
    timescaledb.compress_segmentby = 'user_id, table_name',
    timescaledb.compress_orderby = 'timestamp DESC, operation_type'
);

-- Compress all chunks older than 1 week
SELECT compress_chunk(c) FROM show_chunks('audit_trail.data_processing_log') c
WHERE range_end < NOW() - INTERVAL '7 days';

-- Create continuous aggregates for common queries
CREATE MATERIALIZED VIEW audit_trail.hourly_activity_summary AS
SELECT
    time_bucket('1 hour', timestamp) AS hour,
    user_id,
    table_name,
    operation_type,
    COUNT(*) AS operations,
    COUNT(DISTINCT data_subject_id) AS unique_subjects
FROM audit_trail.data_processing_log
GROUP BY hour, user_id, table_name, operation_type;

-- Add refresh policy
SELECT add_continuous_aggregate_policy('audit_trail.hourly_activity_summary',
    start_offset => INTERVAL '7 days',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);
```

#### 3. **LGPD Data Export Timeouts**
```elixir
# Problem: Large data exports timing out
# Solution: Implement streaming export with chunking

# lib/healthcare_platform/lgpd/streaming_export.ex
defmodule HealthcarePlatform.LGPD.StreamingExport do
  @moduledoc """
  Streaming data export to handle large LGPD data portability requests
  """

  import Ecto.Query
  alias HealthcarePlatform.Repo

  @chunk_size 1000

  def stream_patient_data_export(patient_id, export_format \\ :json) do
    export_stream =
      Stream.resource(
        fn -> initialize_export(patient_id) end,
        &next_chunk/1,
        &finalize_export/1
      )

    case export_format do
      :json -> stream_to_json(export_stream)
      :fhir -> stream_to_fhir(export_stream)
      :csv -> stream_to_csv(export_stream)
    end
  end

  defp initialize_export(patient_id) do
    %{
      patient_id: patient_id,
      current_table: :patient_data,
      offset: 0,
      tables: [:patient_data, :medical_records, :appointments, :prescriptions],
      buffer: []
    }
  end

  defp next_chunk(%{current_table: nil} = state) do
    {:halt, state}
  end

  defp next_chunk(state) do
    case fetch_table_chunk(state) do
      {[], new_state} ->
        # Move to next table
        next_table_state = advance_to_next_table(new_state)
        next_chunk(next_table_state)

      {data, new_state} ->
        {[{state.current_table, data}], new_state}
    end
  end

  defp fetch_table_chunk(%{current_table: :patient_data, patient_id: patient_id, offset: offset}) do
    # For patient data, we only need one record
    if offset == 0 do
      patient = Repo.get(HealthcarePlatform.Schemas.Patient, patient_id)
      {[patient], %{current_table: :patient_data, patient_id: patient_id, offset: 1}}
    else
      {[], %{current_table: :patient_data, patient_id: patient_id, offset: 1}}
    end
  end

  defp fetch_table_chunk(%{current_table: :medical_records, patient_id: patient_id, offset: offset}) do
    query =
      from mr in HealthcarePlatform.Schemas.MedicalRecord,
      where: mr.patient_id == ^patient_id,
      order_by: mr.inserted_at,
      limit: ^@chunk_size,
      offset: ^offset

    records = Repo.all(query)
    new_state = %{current_table: :medical_records, patient_id: patient_id, offset: offset + @chunk_size}
    {records, new_state}
  end

  defp fetch_table_chunk(%{current_table: :appointments, patient_id: patient_id, offset: offset}) do
    # Similar implementation for appointments
    {[], %{current_table: :appointments, patient_id: patient_id, offset: offset + @chunk_size}}
  end

  defp fetch_table_chunk(%{current_table: :prescriptions, patient_id: patient_id, offset: offset}) do
    # Similar implementation for prescriptions
    {[], %{current_table: :prescriptions, patient_id: patient_id, offset: offset + @chunk_size}}
  end

  defp advance_to_next_table(%{tables: [_current | remaining]} = state) do
    case remaining do
      [] -> %{state | current_table: nil}
      [next | _] -> %{state | current_table: next, offset: 0, tables: remaining}
    end
  end

  defp finalize_export(state) do
    # Cleanup any resources
    :ok
  end

  defp stream_to_json(data_stream) do
    data_stream
    |> Stream.map(fn {table, data} ->
      Jason.encode!(%{table: table, data: data})
    end)
  end

  defp stream_to_fhir(data_stream) do
    data_stream
    |> Stream.map(&convert_to_fhir_entry/1)
    |> Stream.map(&Jason.encode!/1)
  end

  defp stream_to_csv(data_stream) do
    # CSV streaming implementation
    data_stream
    |> Stream.flat_map(fn {_table, data} -> data end)
    |> CSV.encode()
  end

  defp convert_to_fhir_entry({:patient_data, [patient]}) do
    %{
      resourceType: "Patient",
      id: patient.id,
      name: [%{given: [patient.name]}],
      birthDate: patient.birth_date
      # Add more FHIR R4 fields as needed
    }
  end

  defp convert_to_fhir_entry({:medical_records, records}) do
    Enum.map(records, fn record ->
      %{
        resourceType: "DiagnosticReport",
        id: record.id,
        status: "final",
        subject: %{reference: "Patient/#{record.patient_id}"},
        # Add more FHIR R4 fields as needed
      }
    end)
  end

  defp convert_to_fhir_entry({_table, _data}), do: []
end

# Usage in LGPD compliance module:
def export_patient_data_streaming(patient_id, format \\ :json) do
  file_path = "/tmp/patient_export_#{patient_id}_#{System.system_time(:second)}.#{format}"

  file_stream = File.stream!(file_path, [:write])

  HealthcarePlatform.LGPD.StreamingExport.stream_patient_data_export(patient_id, format)
  |> Stream.into(file_stream)
  |> Stream.run()

  {:ok, file_path}
end
```

#### 4. **Encryption/Decryption Errors**
```elixir
# Problem: PQC encryption failures or key rotation issues
# Solution: Implement proper error handling and key management

# lib/healthcare_platform/crypto/key_manager.ex
defmodule HealthcarePlatform.Crypto.KeyManager do
  @moduledoc """
  Post-Quantum Cryptography key management for healthcare platform
  """

  use GenServer
  require Logger

  @key_rotation_interval 24 * 60 * 60 * 1000 # 24 hours

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    # Load or generate initial keys
    case load_platform_keys() do
      {:ok, keys} ->
        store_keys_in_memory(keys)
        schedule_key_rotation()
        {:ok, %{keys: keys, last_rotation: DateTime.utc_now()}}

      {:error, reason} ->
        Logger.error("Failed to initialize cryptographic keys: #{reason}")
        {:stop, :key_initialization_failed}
    end
  end

  def handle_info(:rotate_keys, state) do
    Logger.info("Starting scheduled key rotation")

    case rotate_platform_keys() do
      {:ok, new_keys} ->
        store_keys_in_memory(new_keys)
        schedule_key_rotation()
        {:noreply, %{state | keys: new_keys, last_rotation: DateTime.utc_now()}}

      {:error, reason} ->
        Logger.error("Key rotation failed: #{reason}")
        schedule_key_rotation() # Try again later
        {:noreply, state}
    end
  end

  def get_current_keys do
    :persistent_term.get(:healthcare_platform_keys)
  rescue
    ArgumentError ->
      Logger.error("Platform keys not found in memory")
      {:error, :keys_not_available}
  end

  defp load_platform_keys do
    key_file = Application.get_env(:healthcare_platform, :key_file_path)

    case File.read(key_file) do
      {:ok, encrypted_keys} ->
        master_key = get_master_key()
        decrypt_key_file(encrypted_keys, master_key)

      {:error, :enoent} ->
        Logger.info("Key file not found, generating new keys")
        generate_initial_keys()

      {:error, reason} ->
        {:error, "Failed to read key file: #{reason}"}
    end
  end

  defp generate_initial_keys do
    try do
      # Generate CRYSTALS-Kyber keypair for encryption
      {:ok, {kyber_public, kyber_private}} = :pqcrypto.kyber_keypair()

      # Generate CRYSTALS-Dilithium keypair for digital signatures
      {:ok, {dilithium_public, dilithium_private}} = :pqcrypto.dilithium_keypair()

      keys = %{
        kyber: %{public: kyber_public, private: kyber_private},
        dilithium: %{public: dilithium_public, private: dilithium_private},
        version: 1,
        created_at: DateTime.utc_now()
      }

      # Save keys to encrypted file
      save_keys_to_file(keys)

      {:ok, keys}
    rescue
      error ->
        {:error, "Key generation failed: #{inspect(error)}"}
    end
  end

  defp rotate_platform_keys do
    # Generate new keys but keep old ones for decryption of existing data
    case generate_initial_keys() do
      {:ok, new_keys} ->
        # Increment version for key versioning
        old_keys = get_current_keys()
        versioned_keys = %{new_keys | version: old_keys.version + 1}

        {:ok, versioned_keys}

      error -> error
    end
  end

  defp store_keys_in_memory(keys) do
    :persistent_term.put(:healthcare_platform_kyber_public_key, keys.kyber.public)
    :persistent_term.put(:healthcare_platform_kyber_private_key, keys.kyber.private)
    :persistent_term.put(:healthcare_platform_dilithium_public_key, keys.dilithium.public)
    :persistent_term.put(:healthcare_platform_dilithium_private_key, keys.dilithium.private)
    :persistent_term.put(:healthcare_platform_keys, keys)
  end

  defp save_keys_to_file(keys) do
    key_file = Application.get_env(:healthcare_platform, :key_file_path)
    master_key = get_master_key()

    encrypted_keys = encrypt_key_file(keys, master_key)
    File.write!(key_file, encrypted_keys)
  end

  defp get_master_key do
    # In production, this would come from a secure key management service
    Application.get_env(:healthcare_platform, :master_encryption_key) ||
    raise "Master encryption key not configured"
  end

  defp encrypt_key_file(keys, master_key) do
    plaintext = :erlang.term_to_binary(keys)
    iv = :crypto.strong_rand_bytes(12)

    {ciphertext, auth_tag} = :crypto.crypto_one_time_aead(
      :aes_256_gcm, master_key, iv, plaintext, "", true
    )

    Base.encode64(:erlang.term_to_binary({iv, ciphertext, auth_tag}))
  end

  defp decrypt_key_file(encrypted_data, master_key) do
    try do
      {iv, ciphertext, auth_tag} =
        encrypted_data
        |> Base.decode64!()
        |> :erlang.binary_to_term()

      case :crypto.crypto_one_time_aead(:aes_256_gcm, master_key, iv, ciphertext, "", auth_tag, false) do
        plaintext when is_binary(plaintext) ->
          keys = :erlang.binary_to_term(plaintext)
          {:ok, keys}

        :error ->
          {:error, "Key decryption failed - invalid master key or corrupted data"}
      end
    rescue
      error ->
        {:error, "Key file decryption error: #{inspect(error)}"}
    end
  end

  defp schedule_key_rotation do
    Process.send_after(self(), :rotate_keys, @key_rotation_interval)
  end
end

# Error handling for EncryptedString type
defmodule HealthcarePlatform.Types.EncryptedString do
  # ... existing code ...

  defp encrypt_with_pqc(plaintext) do
    case HealthcarePlatform.Crypto.KeyManager.get_current_keys() do
      {:error, reason} ->
        Logger.error("Encryption failed - keys not available: #{reason}")
        {:error, :encryption_keys_unavailable}

      keys ->
        try do
          # Use current keys for encryption
          {:ok, shared_secret} = :pqcrypto.kyber_encapsulate(keys.kyber.public)

          # Continue with encryption logic...
          aes_key = :crypto.hash(:sha256, shared_secret) |> binary_part(0, 32)
          iv = :crypto.strong_rand_bytes(12)

          {ciphertext, auth_tag} = :crypto.crypto_one_time_aead(
            :aes_256_gcm, aes_key, iv, plaintext, "", true
          )

          encrypted_package = %{
            algorithm: "CRYSTALS-Kyber-768 + AES-256-GCM",
            version: keys.version,
            iv: Base.encode64(iv),
            ciphertext: Base.encode64(ciphertext),
            auth_tag: Base.encode64(auth_tag),
            timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
          }

          {:ok, :erlang.term_to_binary(encrypted_package)}
        rescue
          error ->
            Logger.error("Encryption failed: #{inspect(error)}")
            {:error, :encryption_failed}
        end
    end
  end

  defp decrypt_with_pqc(encrypted_binary) do
    try do
      encrypted_package = :erlang.binary_to_term(encrypted_binary)

      # Handle different key versions for backward compatibility
      case get_decryption_keys(encrypted_package.version) do
        {:error, reason} ->
          Logger.error("Decryption failed - key version #{encrypted_package.version} not available: #{reason}")
          {:error, :decryption_keys_unavailable}

        keys ->
          # Continue with decryption logic...
          iv = Base.decode64!(encrypted_package.iv)
          ciphertext = Base.decode64!(encrypted_package.ciphertext)
          auth_tag = Base.decode64!(encrypted_package.auth_tag)

          # Reconstruct shared secret
          {:ok, shared_secret} = :pqcrypto.kyber_decapsulate(
            encrypted_package.public_key |> Base.decode64!(),
            keys.kyber.private
          )

          aes_key = :crypto.hash(:sha256, shared_secret) |> binary_part(0, 32)

          case :crypto.crypto_one_time_aead(:aes_256_gcm, aes_key, iv, ciphertext, "", auth_tag, false) do
            plaintext when is_binary(plaintext) ->
              {:ok, plaintext}
            :error ->
              Logger.error("Decryption authentication failed")
              {:error, :decryption_authentication_failed}
          end
      end
    rescue
      error ->
        Logger.error("Decryption failed: #{inspect(error)}")
        {:error, :decryption_failed}
    end
  end

  defp get_decryption_keys(version) do
    # In a real implementation, you'd maintain a key history for backward compatibility
    current_keys = HealthcarePlatform.Crypto.KeyManager.get_current_keys()

    if current_keys.version == version do
      current_keys
    else
      # Try to load historical keys for this version
      {:error, :key_version_not_found}
    end
  end
end
```

---

**Próximo Diário:** [06-infrastructure-devops.md](./06-infrastructure-devops.md)
**Índice Geral:** [README.md](../README.md)