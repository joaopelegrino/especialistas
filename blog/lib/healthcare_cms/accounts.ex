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
end