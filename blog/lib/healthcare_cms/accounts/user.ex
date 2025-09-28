# DSM:ACCOUNTS:user_schema HEALTHCARE:medical_professional_data
# DSM:SECURITY:user_authentication LGPD:personal_data_protection
defmodule HealthcareCMS.Accounts.User do
  @moduledoc """
  User Schema - Healthcare Medical Professional

  Representa usuários do sistema com extensões específicas para healthcare:
  - Profissionais médicos (CRM, CRP, etc.)
  - Dados de autenticação e autorização
  - Context para Zero Trust Policy Engine
  - Compliance LGPD para dados pessoais
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    # Basic user fields
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :status, Ecto.Enum, values: [:active, :inactive, :suspended, :deleted], default: :active

    # Authentication fields
    field :password_hash, :string
    field :password, :string, virtual: true
    field :confirmed_at, :utc_datetime

    # WordPress compatibility
    field :username, :string
    field :display_name, :string
    field :role, Ecto.Enum, values: [
      :subscriber, :contributor, :author, :editor, :administrator,
      :medical_professional, :medical_admin, :compliance_officer
    ], default: :subscriber

    # Healthcare specific fields
    field :professional_registry, :string  # CRM, CRP, etc.
    field :registry_state, :string         # UF do registro
    field :registry_verified, :boolean, default: false
    field :specialty, :string
    field :healthcare_institution, :string

    # Zero Trust context fields
    field :trust_level, :integer, default: 50
    field :last_trust_evaluation, :utc_datetime
    field :mfa_enabled, :boolean, default: false
    field :device_fingerprints, {:array, :string}, default: []

    # Audit fields
    field :last_login_at, :utc_datetime
    field :failed_login_attempts, :integer, default: 0
    field :locked_until, :utc_datetime
    field :deleted_at, :utc_datetime

    # Tenant support
    field :tenant_id, :binary_id

    timestamps()
  end

  @required_fields [:email, :first_name, :last_name]
  @optional_fields [
    :username, :display_name, :role, :professional_registry, :registry_state,
    :registry_verified, :specialty, :healthcare_institution, :trust_level,
    :mfa_enabled, :confirmed_at, :last_login_at, :failed_login_attempts,
    :locked_until, :tenant_id, :status
  ]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_email()
    |> validate_professional_registry()
    |> generate_username()
    |> generate_display_name()
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  @doc """
  Changeset para criação de usuário com senha
  """
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_password_complexity()
    |> hash_password()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, HealthcareCMS.Repo)
  end

  defp validate_professional_registry(changeset) do
    case get_field(changeset, :professional_registry) do
      nil ->
        changeset

      registry when is_binary(registry) ->
        if String.match?(registry, ~r/^(CRM|CRP|COREN|CRF|CRN|CRO)\/[A-Z]{2}\s\d{4,6}$/) do
          changeset
          |> put_change(:role, :medical_professional)
          |> put_change(:registry_verified, false)  # Requires external validation
        else
          add_error(changeset, :professional_registry,
            "deve estar no formato CRM/UF NUMERO (ex: CRM/SP 123456)")
        end
    end
  end

  defp generate_username(changeset) do
    case get_field(changeset, :username) do
      nil ->
        email = get_field(changeset, :email)
        if email do
          username = email
                     |> String.split("@")
                     |> List.first()
                     |> String.replace(~r/[^\w]/, "")
                     |> String.downcase()

          put_change(changeset, :username, username)
        else
          changeset
        end
      _ -> changeset
    end
  end

  defp generate_display_name(changeset) do
    case get_field(changeset, :display_name) do
      nil ->
        first_name = get_field(changeset, :first_name)
        last_name = get_field(changeset, :last_name)

        if first_name && last_name do
          display_name = "#{first_name} #{last_name}"
          put_change(changeset, :display_name, display_name)
        else
          changeset
        end
      _ -> changeset
    end
  end

  defp validate_password_complexity(changeset) do
    password = get_change(changeset, :password)

    if password do
      cond do
        not String.match?(password, ~r/[a-z]/) ->
          add_error(changeset, :password, "deve conter pelo menos uma letra minúscula")

        not String.match?(password, ~r/[A-Z]/) ->
          add_error(changeset, :password, "deve conter pelo menos uma letra maiúscula")

        not String.match?(password, ~r/[0-9]/) ->
          add_error(changeset, :password, "deve conter pelo menos um número")

        not String.match?(password, ~r/[^a-zA-Z0-9]/) ->
          add_error(changeset, :password, "deve conter pelo menos um caractere especial")

        true -> changeset
      end
    else
      changeset
    end
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        changeset
        |> put_change(:password_hash, Argon2.hash_pwd_salt(password))
        |> delete_change(:password)
    end
  end

  @doc """
  Verifica se usuário é profissional médico
  """
  def medical_professional?(%__MODULE__{role: role}) when role in [:medical_professional, :medical_admin], do: true
  def medical_professional?(_), do: false

  @doc """
  Verifica se usuário tem registry médico verificado
  """
  def verified_professional?(%__MODULE__{registry_verified: true}), do: true
  def verified_professional?(_), do: false

  @doc """
  Retorna nome completo do usuário
  """
  def full_name(%__MODULE__{first_name: first, last_name: last}) do
    "#{first} #{last}"
  end
end