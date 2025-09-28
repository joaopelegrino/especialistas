# DSM:CONTENT:post_schema WORDPRESS:core_compatibility
# DSM:AUDIT:versioning_tracking HEALTHCARE:medical_content_compliance
defmodule HealthcareCMS.Content.Post do
  @moduledoc """
  Post Schema - WordPress Core Compatible

  Representa posts/artigos com funcionalidades WordPress core:
  - Títulos, conteúdo, excerpts
  - Status de publicação (draft, published, private, etc.)
  - Categories e tags
  - Custom fields support
  - Audit trail para compliance
  - Medical content classification
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias HealthcareCMS.Accounts.User
  alias HealthcareCMS.Content.{Category, CustomField}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :excerpt, :string
    field :status, Ecto.Enum, values: [:draft, :published, :private, :trash, :deleted]

    # WordPress meta fields
    field :post_type, :string, default: "post"  # post, page, custom_post_type
    field :comment_status, Ecto.Enum, values: [:open, :closed], default: :open
    field :ping_status, Ecto.Enum, values: [:open, :closed], default: :open

    # SEO fields
    field :meta_description, :string
    field :meta_keywords, :string

    # Healthcare specific fields
    field :medical_category, Ecto.Enum, values: [
      :general, :cardiology, :neurology, :pediatrics, :surgery,
      :pharmacy, :radiology, :laboratory, :emergency, :preventive
    ]
    field :compliance_level, Ecto.Enum, values: [:public, :professional, :restricted, :phi]
    field :requires_crm_validation, :boolean, default: false
    field :medical_disclaimer, :string

    # Publication fields
    field :published_at, :utc_datetime
    field :scheduled_at, :utc_datetime

    # Audit fields
    field :version, :integer, default: 1
    field :deleted_at, :utc_datetime

    # Tenant support
    field :tenant_id, :binary_id

    # Relationships
    belongs_to :author, User, foreign_key: :author_id
    belongs_to :category, Category
    has_many :custom_fields, CustomField

    timestamps()
  end

  @required_fields [:title, :content, :status, :author_id]
  @optional_fields [
    :slug, :excerpt, :post_type, :comment_status, :ping_status,
    :meta_description, :meta_keywords, :medical_category, :compliance_level,
    :requires_crm_validation, :medical_disclaimer, :published_at, :scheduled_at,
    :category_id, :tenant_id, :version
  ]

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:excerpt, max: 500)
    |> validate_length(:meta_description, max: 160)
    |> generate_slug()
    |> set_published_at()
    |> validate_medical_content()
    |> unique_constraint(:slug, name: :posts_slug_tenant_id_index)
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :title) do
      nil -> changeset
      title ->
        slug = title
               |> String.downcase()
               |> String.replace(~r/[^\w\s-]/, "")
               |> String.replace(~r/\s+/, "-")
               |> String.trim("-")

        put_change(changeset, :slug, slug)
    end
  end

  defp set_published_at(changeset) do
    case get_change(changeset, :status) do
      :published ->
        if get_field(changeset, :published_at) == nil do
          put_change(changeset, :published_at, DateTime.utc_now())
        else
          changeset
        end
      _ -> changeset
    end
  end

  defp validate_medical_content(changeset) do
    compliance_level = get_field(changeset, :compliance_level)
    medical_category = get_field(changeset, :medical_category)

    changeset
    |> validate_medical_disclaimer(compliance_level)
    |> validate_crm_requirement(medical_category, compliance_level)
  end

  defp validate_medical_disclaimer(changeset, compliance_level)
    when compliance_level in [:professional, :restricted, :phi] do

    case get_field(changeset, :medical_disclaimer) do
      nil ->
        add_error(changeset, :medical_disclaimer,
          "é obrigatório para conteúdo médico profissional")
      _ -> changeset
    end
  end
  defp validate_medical_disclaimer(changeset, _), do: changeset

  defp validate_crm_requirement(changeset, medical_category, compliance_level)
    when medical_category != :general and compliance_level in [:professional, :restricted] do

    case get_field(changeset, :requires_crm_validation) do
      false ->
        put_change(changeset, :requires_crm_validation, true)
      _ -> changeset
    end
  end
  defp validate_crm_requirement(changeset, _, _), do: changeset
end