# DSM:CONTENT:custom_fields_schema WORDPRESS:acf_compatibility
# DSM:HEALTHCARE:medical_metadata LGPD:structured_data_tracking
defmodule HealthcareCMS.Content.CustomField do
  @moduledoc """
  Custom Field Schema - ACF (Advanced Custom Fields) Compatible

  Sistema de campos customizados para posts com funcionalidades ACF:
  - Campos dinâmicos por post
  - Tipos de dados específicos para healthcare
  - Validação de dados médicos
  - Metadata estruturado para compliance
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias HealthcareCMS.Content.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "custom_fields" do
    field :meta_key, :string
    field :meta_value, :string  # JSON string para valores complexos
    field :meta_type, Ecto.Enum, values: [
      :text, :number, :boolean, :date, :datetime, :json, :url, :email,
      :medical_code, :crm_number, :medication, :dosage, :vital_signs
    ], default: :text

    # Healthcare specific fields
    field :medical_significance, Ecto.Enum, values: [
      :none, :informational, :diagnostic, :therapeutic, :administrative
    ], default: :none

    field :requires_validation, :boolean, default: false
    field :validation_rules, :map  # JSON com regras de validação
    field :is_phi, :boolean, default: false  # Protected Health Information

    # ACF compatibility fields
    field :field_group, :string  # Para agrupar campos relacionados
    field :field_order, :integer, default: 0
    field :is_required, :boolean, default: false

    # Tenant support
    field :tenant_id, :binary_id

    # Relationships
    belongs_to :post, Post

    timestamps()
  end

  @required_fields [:post_id, :meta_key, :meta_value]
  @optional_fields [
    :meta_type, :medical_significance, :requires_validation, :validation_rules,
    :is_phi, :field_group, :field_order, :is_required, :tenant_id
  ]

  @doc false
  def changeset(custom_field, attrs) do
    custom_field
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:meta_key, min: 1, max: 100)
    |> validate_meta_value()
    |> set_medical_requirements()
    |> unique_constraint([:post_id, :meta_key], name: :custom_fields_post_meta_key_index)
  end

  defp validate_meta_value(changeset) do
    meta_type = get_field(changeset, :meta_type)
    meta_value = get_field(changeset, :meta_value)

    case {meta_type, meta_value} do
      {_, nil} -> changeset
      {_, ""} -> changeset
      {:number, value} -> validate_number_format(changeset, value)
      {:boolean, value} -> validate_boolean_format(changeset, value)
      {:date, value} -> validate_date_format(changeset, value)
      {:datetime, value} -> validate_datetime_format(changeset, value)
      {:json, value} -> validate_json_format(changeset, value)
      {:url, value} -> validate_url_format(changeset, value)
      {:email, value} -> validate_email_format(changeset, value)
      {:crm_number, value} -> validate_crm_format(changeset, value)
      {:medical_code, value} -> validate_medical_code_format(changeset, value)
      _ -> changeset
    end
  end

  defp validate_number_format(changeset, value) do
    case Float.parse(value) do
      {_num, ""} -> changeset
      _ -> add_error(changeset, :meta_value, "deve ser um número válido")
    end
  end

  defp validate_boolean_format(changeset, value) do
    if value in ["true", "false", "1", "0", "yes", "no"] do
      changeset
    else
      add_error(changeset, :meta_value, "deve ser um valor booleano válido")
    end
  end

  defp validate_date_format(changeset, value) do
    case Date.from_iso8601(value) do
      {:ok, _date} -> changeset
      _ -> add_error(changeset, :meta_value, "deve ser uma data válida (YYYY-MM-DD)")
    end
  end

  defp validate_datetime_format(changeset, value) do
    case DateTime.from_iso8601(value) do
      {:ok, _datetime, _} -> changeset
      _ -> add_error(changeset, :meta_value, "deve ser um datetime válido (ISO 8601)")
    end
  end

  defp validate_json_format(changeset, value) do
    case Jason.decode(value) do
      {:ok, _json} -> changeset
      _ -> add_error(changeset, :meta_value, "deve ser um JSON válido")
    end
  end

  defp validate_url_format(changeset, value) do
    uri = URI.parse(value)
    if uri.scheme && uri.host do
      changeset
    else
      add_error(changeset, :meta_value, "deve ser uma URL válida")
    end
  end

  defp validate_email_format(changeset, value) do
    if String.match?(value, ~r/^[^\s]+@[^\s]+\.[^\s]+$/) do
      changeset
    else
      add_error(changeset, :meta_value, "deve ser um email válido")
    end
  end

  defp validate_crm_format(changeset, value) do
    # Formato: CRM/UF NÚMERO (ex: CRM/SP 123456)
    if String.match?(value, ~r/^CRM\/[A-Z]{2}\s\d{4,6}$/) do
      changeset
      |> put_change(:requires_validation, true)
      |> put_change(:medical_significance, :administrative)
    else
      add_error(changeset, :meta_value, "CRM deve estar no formato CRM/UF NUMERO")
    end
  end

  defp validate_medical_code_format(changeset, value) do
    # Validação básica para códigos médicos (CID, TUSS, etc.)
    if String.length(value) >= 3 do
      changeset
      |> put_change(:medical_significance, :diagnostic)
    else
      add_error(changeset, :meta_value, "código médico deve ter pelo menos 3 caracteres")
    end
  end

  defp set_medical_requirements(changeset) do
    medical_significance = get_field(changeset, :medical_significance)
    meta_type = get_field(changeset, :meta_type)

    changeset = if meta_type in [:crm_number, :medical_code, :vital_signs] do
      changeset
      |> put_change(:requires_validation, true)
      |> put_change(:is_phi, true)
    else
      changeset
    end

    if medical_significance in [:diagnostic, :therapeutic] do
      put_change(changeset, :is_phi, true)
    else
      changeset
    end
  end

  @doc """
  Converte meta_value para tipo apropriado baseado em meta_type
  """
  def cast_value(%__MODULE__{meta_type: :number, meta_value: value}) do
    case Float.parse(value) do
      {num, ""} -> num
      _ -> value
    end
  end

  def cast_value(%__MODULE__{meta_type: :boolean, meta_value: value}) do
    value in ["true", "1", "yes"]
  end

  def cast_value(%__MODULE__{meta_type: :date, meta_value: value}) do
    case Date.from_iso8601(value) do
      {:ok, date} -> date
      _ -> value
    end
  end

  def cast_value(%__MODULE__{meta_type: :datetime, meta_value: value}) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _} -> datetime
      _ -> value
    end
  end

  def cast_value(%__MODULE__{meta_type: :json, meta_value: value}) do
    case Jason.decode(value) do
      {:ok, json} -> json
      _ -> value
    end
  end

  def cast_value(%__MODULE__{meta_value: value}), do: value

  @doc """
  Retorna campos organizados por field_group
  """
  def group_by_field_group(custom_fields) do
    Enum.group_by(custom_fields, & &1.field_group)
  end

  @doc """
  Verifica se campo contém PHI
  """
  def contains_phi?(%__MODULE__{is_phi: true}), do: true
  def contains_phi?(%__MODULE__{medical_significance: sig}) when sig in [:diagnostic, :therapeutic], do: true
  def contains_phi?(_), do: false
end