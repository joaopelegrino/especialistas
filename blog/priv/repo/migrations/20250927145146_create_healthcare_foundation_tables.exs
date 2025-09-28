defmodule HealthcareCMS.Repo.Migrations.CreateHealthcareFoundationTables do
  use Ecto.Migration

  def change do
    # DSM:DATABASE:foundation_schema HEALTHCARE:compliance_ready
    # DSM:SECURITY:admin_blind_architecture COMPLIANCE:LGPD_ready

    # Users and Authentication (WordPress equivalent + healthcare extensions)
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :role, :string, null: false, default: "subscriber"
      add :mfa_enabled, :boolean, default: false

      # Healthcare professional data
      add :professional_registry, :string  # CRM, CRP, etc.
      add :professional_type, :string      # medico, psicologo, etc.
      add :speciality, :string
      add :validated_at, :utc_datetime

      # Multi-tenant support
      add :tenant_id, :uuid

      # Audit trail
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
      add :deleted_at, :utc_datetime
      add :deleted_by, :uuid
    end

    create unique_index(:users, [:email])
    create index(:users, [:tenant_id])
    create index(:users, [:professional_registry])
    create index(:users, [:role])

    # Content (Posts and Pages - WordPress equivalent)
    create table(:content, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, size: 500, null: false
      add :slug, :string, null: false
      add :content, :text
      add :excerpt, :text
      add :status, :string, default: "draft"
      add :content_type, :string, default: "post"
      add :author_id, :uuid, null: false
      add :parent_id, :uuid
      add :featured_image_id, :uuid
      add :tenant_id, :uuid, null: false

      # Medical workflow state
      add :workflow_stage, :string, default: "draft"
      add :lgpd_score, :integer
      add :compliance_validated, :boolean, default: false
      add :medical_reviewer_id, :uuid
      add :legal_reviewer_id, :uuid

      add :published_at, :utc_datetime
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
      add :deleted_at, :utc_datetime
      add :deleted_by, :uuid
    end

    create unique_index(:content, [:slug, :tenant_id])
    create index(:content, [:tenant_id])
    create index(:content, [:author_id])
    create index(:content, [:status])
    create index(:content, [:content_type])
    create index(:content, [:workflow_stage])

    # Custom Fields System (ACF equivalent)
    create table(:field_groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :title, :string, null: false
      add :content_types, {:array, :string}, default: ["post"]
      add :active, :boolean, default: true
      add :tenant_id, :uuid, null: false

      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end

    create index(:field_groups, [:tenant_id])
    create index(:field_groups, [:active])

    create table(:fields, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :field_group_id, :uuid, null: false
      add :name, :string, null: false
      add :label, :string, null: false
      add :type, :string, null: false
      add :config, :map, default: %{}
      add :required, :boolean, default: false
      add :order_index, :integer, default: 0

      add :created_at, :utc_datetime
    end

    create index(:fields, [:field_group_id])
    create index(:fields, [:type])

    # Healthcare Workflow States
    create table(:workflow_states, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :content_id, :uuid, null: false
      add :current_stage, :string, default: "draft"
      add :lgpd_score, :integer
      add :medical_claims, :map, default: %{}
      add :scientific_references, :map, default: %{}
      add :compliance_validations, :map, default: %{}
      add :tenant_id, :uuid, null: false

      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end

    create index(:workflow_states, [:content_id])
    create index(:workflow_states, [:tenant_id])
    create index(:workflow_states, [:current_stage])

    # Zero Trust Audit Trail
    create table(:audit_trail, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :operation, :string, null: false
      add :resource_type, :string, null: false
      add :resource_id, :uuid, null: false
      add :tenant_id, :uuid, null: false
      add :user_id, :uuid, null: false
      add :metadata, :map, default: %{}
      add :trust_score, :integer
      add :policy_decision, :string

      add :created_at, :utc_datetime
    end

    create index(:audit_trail, [:tenant_id])
    create index(:audit_trail, [:user_id])
    create index(:audit_trail, [:resource_type])
    create index(:audit_trail, [:created_at])

    # Note: Foreign key constraints will be added in PostgreSQL production environment
  end
end
