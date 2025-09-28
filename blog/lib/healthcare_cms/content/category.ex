# DSM:CONTENT:category_schema WORDPRESS:taxonomy_compatibility
# DSM:HEALTHCARE:medical_content_classification LGPD:content_organization
defmodule HealthcareCMS.Content.Category do
  @moduledoc """
  Category Schema - WordPress Taxonomy Compatible

  Sistema de categorização de conteúdo com extensões para healthcare:
  - Categorias hierárquicas (parent/child)
  - Slug-based URLs
  - Healthcare-specific categorization
  - Medical specialty classifications
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias HealthcareCMS.Content.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string

    # WordPress taxonomy fields
    field :count, :integer, default: 0  # Number of posts in this category

    # Hierarchy support
    field :level, :integer, default: 0

    # Healthcare specific fields
    field :medical_specialty, Ecto.Enum, values: [
      :general_medicine, :cardiology, :neurology, :pediatrics, :surgery,
      :psychiatry, :dermatology, :orthopedics, :gynecology, :urology,
      :oncology, :radiology, :anesthesiology, :emergency_medicine,
      :family_medicine, :internal_medicine, :pharmacy, :nursing,
      :physiotherapy, :nutrition, :psychology, :administration
    ]

    field :compliance_required, :boolean, default: false
    field :crm_validation_required, :boolean, default: false

    # Tenant support
    field :tenant_id, :binary_id

    # Relationships
    belongs_to :parent, __MODULE__, type: :binary_id
    has_many :children, __MODULE__, foreign_key: :parent_id
    has_many :posts, Post

    timestamps()
  end

  @required_fields [:name]
  @optional_fields [
    :slug, :description, :level, :medical_specialty,
    :compliance_required, :crm_validation_required, :tenant_id, :count
  ]

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:description, max: 500)
    |> generate_slug()
    |> validate_parent_hierarchy()
    |> set_medical_requirements()
    |> unique_constraint(:slug, name: :categories_slug_tenant_id_index)
    |> unique_constraint(:name, name: :categories_name_tenant_id_index)
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name ->
        slug = name
               |> String.downcase()
               |> String.replace(~r/[^\w\s-]/, "")
               |> String.replace(~r/\s+/, "-")
               |> String.trim("-")

        put_change(changeset, :slug, slug)
    end
  end

  defp validate_parent_hierarchy(changeset) do
    case get_change(changeset, :parent_id) do
      nil ->
        put_change(changeset, :level, 0)

      parent_id ->
        # Em uma implementação completa, verificaríamos o nível do parent
        # Por simplicidade, assumindo nível 1 para child categories
        changeset
        |> put_change(:level, 1)
        |> validate_no_circular_reference(parent_id)
    end
  end

  defp validate_no_circular_reference(changeset, parent_id) do
    # Validação básica para evitar referência circular
    current_id = get_field(changeset, :id)

    if current_id && current_id == parent_id do
      add_error(changeset, :parent_id, "não pode referenciar a si mesmo")
    else
      changeset
    end
  end

  defp set_medical_requirements(changeset) do
    case get_field(changeset, :medical_specialty) do
      nil ->
        changeset

      specialty when specialty in [:general_medicine, :administration, :pharmacy] ->
        changeset
        |> put_change(:compliance_required, false)
        |> put_change(:crm_validation_required, false)

      _medical_specialty ->
        changeset
        |> put_change(:compliance_required, true)
        |> put_change(:crm_validation_required, true)
    end
  end

  @doc """
  Incrementa contador de posts da categoria
  """
  def increment_count(category_id) do
    import Ecto.Query

    from(c in __MODULE__, where: c.id == ^category_id)
    |> HealthcareCMS.Repo.update_all(inc: [count: 1])
  end

  @doc """
  Decrementa contador de posts da categoria
  """
  def decrement_count(category_id) do
    import Ecto.Query

    from(c in __MODULE__, where: c.id == ^category_id and c.count > 0)
    |> HealthcareCMS.Repo.update_all(inc: [count: -1])
  end
end