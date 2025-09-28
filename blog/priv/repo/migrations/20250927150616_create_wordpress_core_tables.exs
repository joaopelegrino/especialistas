# DSM:DATABASE:wordpress_core_tables HEALTHCARE:cms_content_management
defmodule HealthcareCMS.Repo.Migrations.CreateWordPressCoreTabla do
  use Ecto.Migration

  def change do
    # Categories table for content organization
    create table(:categories, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 100, null: false
      add :slug, :string, size: 100, null: false
      add :description, :text
      add :count, :integer, default: 0
      add :level, :integer, default: 0
      add :parent_id, references(:categories, type: :uuid, on_delete: :nilify_all)

      # Healthcare specific
      add :medical_specialty, :string, size: 50
      add :compliance_required, :boolean, default: false
      add :crm_validation_required, :boolean, default: false

      # Multi-tenant
      add :tenant_id, :uuid

      timestamps()
    end

    create unique_index(:categories, [:slug, :tenant_id], name: :categories_slug_tenant_id_index)
    create unique_index(:categories, [:name, :tenant_id], name: :categories_name_tenant_id_index)
    create index(:categories, [:parent_id])
    create index(:categories, [:tenant_id])
    create index(:categories, [:medical_specialty])

    # Posts table for content management
    create table(:posts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, size: 255, null: false
      add :slug, :string, size: 255, null: false
      add :content, :text
      add :excerpt, :text
      add :status, :string, size: 20, default: "draft"

      # WordPress compatibility
      add :post_type, :string, size: 30, default: "post"
      add :comment_status, :string, size: 10, default: "open"
      add :ping_status, :string, size: 10, default: "open"

      # SEO
      add :meta_description, :string, size: 160
      add :meta_keywords, :string, size: 255

      # Healthcare specific
      add :medical_category, :string, size: 30
      add :compliance_level, :string, size: 20
      add :requires_crm_validation, :boolean, default: false
      add :medical_disclaimer, :text

      # Publication
      add :published_at, :utc_datetime
      add :scheduled_at, :utc_datetime

      # Audit
      add :version, :integer, default: 1
      add :deleted_at, :utc_datetime

      # Relationships
      add :author_id, references(:users, type: :uuid, on_delete: :nilify_all), null: false
      add :category_id, references(:categories, type: :uuid, on_delete: :nilify_all)
      add :tenant_id, :uuid

      timestamps()
    end

    create unique_index(:posts, [:slug, :tenant_id], name: :posts_slug_tenant_id_index)
    create index(:posts, [:author_id])
    create index(:posts, [:category_id])
    create index(:posts, [:status])
    create index(:posts, [:post_type])
    create index(:posts, [:published_at])
    create index(:posts, [:tenant_id])
    create index(:posts, [:medical_category])
    create index(:posts, [:compliance_level])

    # Media table for file management
    create table(:media, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, size: 255
      add :filename, :string, size: 255, null: false
      add :original_filename, :string, size: 255, null: false
      add :mime_type, :string, size: 100, null: false
      add :file_size, :bigint, null: false

      # File paths
      add :file_path, :string, size: 500
      add :url, :string, size: 500

      # Image metadata
      add :width, :integer
      add :height, :integer
      add :alt_text, :string, size: 255
      add :caption, :text
      add :description, :text

      # WordPress compatibility
      add :attachment_type, :string, size: 20

      # Healthcare specific
      add :medical_content, :boolean, default: false
      add :contains_phi, :boolean, default: false
      add :dicom_metadata, :text  # JSON
      add :encryption_status, :string, size: 20, default: "none"

      # Access control
      add :access_level, :string, size: 20
      add :requires_crm_validation, :boolean, default: false

      # Relationships
      add :uploaded_by_id, references(:users, type: :uuid, on_delete: :nilify_all), null: false
      add :post_id, references(:posts, type: :uuid, on_delete: :nilify_all)
      add :tenant_id, :uuid

      timestamps()
    end

    create unique_index(:media, [:filename])
    create index(:media, [:uploaded_by_id])
    create index(:media, [:post_id])
    create index(:media, [:mime_type])
    create index(:media, [:attachment_type])
    create index(:media, [:medical_content])
    create index(:media, [:contains_phi])
    create index(:media, [:tenant_id])

    # Custom Fields table (ACF equivalent)
    create table(:custom_fields, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :meta_key, :string, size: 100, null: false
      add :meta_value, :text
      add :meta_type, :string, size: 20, default: "text"

      # Healthcare specific
      add :medical_significance, :string, size: 20, default: "none"
      add :requires_validation, :boolean, default: false
      add :validation_rules, :text  # JSON
      add :is_phi, :boolean, default: false

      # ACF compatibility
      add :field_group, :string, size: 100
      add :field_order, :integer, default: 0
      add :is_required, :boolean, default: false

      # Relationships
      add :post_id, references(:posts, type: :uuid, on_delete: :delete_all), null: false
      add :tenant_id, :uuid

      timestamps()
    end

    create unique_index(:custom_fields, [:post_id, :meta_key], name: :custom_fields_post_meta_key_index)
    create index(:custom_fields, [:meta_key])
    create index(:custom_fields, [:meta_type])
    create index(:custom_fields, [:field_group])
    create index(:custom_fields, [:medical_significance])
    create index(:custom_fields, [:is_phi])
    create index(:custom_fields, [:tenant_id])
  end
end