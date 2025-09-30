# DSM:ACCOUNTS:user_management HEALTHCARE:medical_professional_auth
# DSM:SECURITY:zero_trust_user_context LGPD:user_data_protection
defmodule HealthcareCMS.Accounts do
  @moduledoc """
  Healthcare Accounts Context

  Gerenciamento de usuários com extensões específicas para healthcare:
  - Profissionais médicos com CRM/CRP validation
  - Zero Trust user context
  - LGPD compliance para dados pessoais
  - Multi-tenant user management
  """

  import Ecto.Query, warn: false
  alias HealthcareCMS.Repo

  alias HealthcareCMS.Accounts.User

  @doc """
  Lista todos os usuários
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Busca usuário por ID
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Busca usuário por email
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Cria novo usuário
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Atualiza usuário existente
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Remove usuário (soft delete para compliance)
  """
  def delete_user(%User{} = user) do
    user
    |> User.changeset(%{status: :deleted, deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Cria changeset para validação de formulário
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Autentica usuário por email e senha

  Retorna {:ok, user} se credenciais válidas
  Retorna {:error, :invalid_credentials} se email/senha incorretos
  Retorna {:error, :user_inactive} se usuário inativo
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && User.valid_password?(user, password) && user.status == :active ->
        {:ok, user}

      user && user.status != :active ->
        {:error, :user_inactive}

      true ->
        # Prevent timing attacks
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  @doc """
  Registra último login do usuário
  """
  def update_last_login(%User{} = user) do
    update_user(user, %{last_login_at: DateTime.utc_now()})
  end
end