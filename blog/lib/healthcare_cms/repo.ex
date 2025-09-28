# DSM:DATABASE:repository_pattern HEALTHCARE:timescale_integration
# DSM:SECURITY:admin_blind_queries COMPLIANCE:audit_trail_support
defmodule HealthcareCMS.Repo do
  use Ecto.Repo,
    otp_app: :healthcare_cms,
    adapter: if(Mix.env() in [:dev, :test], do: Ecto.Adapters.SQLite3, else: Ecto.Adapters.Postgres)

  @doc """
  Multi-tenant aware query execution with admin blind support

  Para healthcare compliance, todas as queries devem ser tenant-aware
  e suportar admin blind architecture onde aplicável.
  """
  def multi_tenant_all(queryable, tenant_id, opts \\ []) do
    import Ecto.Query

    queryable
    |> where([q], q.tenant_id == ^tenant_id)
    |> __MODULE__.all(opts)
  end

  @doc """
  Audit trail aware insert

  Todas as operações de escrita geram audit trail automático
  para compliance LGPD/ANVISA/CFM.
  """
  def audit_insert(struct_or_changeset, tenant_id, user_id, opts \\ []) do
    result = insert(struct_or_changeset, opts)

    case result do
      {:ok, record} ->
        HealthcareCMS.Audit.log_operation(
          :insert,
          record,
          tenant_id,
          user_id,
          %{metadata: opts[:audit_metadata]}
        )
        {:ok, record}

      error ->
        error
    end
  end

  @doc """
  Audit trail aware update
  """
  def audit_update(changeset, tenant_id, user_id, opts \\ []) do
    old_record = changeset.data
    result = update(changeset, opts)

    case result do
      {:ok, new_record} ->
        HealthcareCMS.Audit.log_operation(
          :update,
          new_record,
          tenant_id,
          user_id,
          %{
            old_record: old_record,
            changes: changeset.changes,
            metadata: opts[:audit_metadata]
          }
        )
        {:ok, new_record}

      error ->
        error
    end
  end

  @doc """
  Soft delete com audit trail para healthcare compliance

  Healthcare data nunca é deletada fisicamente, apenas marcada como inativa
  para manter integridade do histórico médico.
  """
  def soft_delete(record, tenant_id, user_id, opts \\ []) do
    changeset = Ecto.Changeset.change(record, %{
      deleted_at: DateTime.utc_now(),
      deleted_by: user_id
    })

    audit_update(changeset, tenant_id, user_id, opts)
  end

  @doc """
  Query apenas registros ativos (não soft deleted)
  """
  def active(queryable) do
    import Ecto.Query
    where(queryable, [q], is_nil(q.deleted_at))
  end

  @doc """
  Busca com full-text search otimizado para conteúdo médico

  Versão simplificada para desenvolvimento (SQLite), PostgreSQL em produção
  terá full-text search otimizado.
  """
  def medical_search(queryable, search_term, tenant_id) do
    import Ecto.Query

    if Mix.env() in [:dev, :test] do
      # SQLite version - simple LIKE search
      queryable
      |> where([q], q.tenant_id == ^tenant_id)
      |> where([q], is_nil(q.deleted_at))
      |> where([q], like(q.content, ^"%#{search_term}%"))
    else
      # PostgreSQL version with full-text search
      queryable
      |> where([q], q.tenant_id == ^tenant_id)
      |> where([q], is_nil(q.deleted_at))
      |> where([q], fragment("to_tsvector('portuguese', ?) @@ plainto_tsquery('portuguese', ?)",
                             q.content, ^search_term))
      |> order_by([q], fragment("ts_rank(to_tsvector('portuguese', ?), plainto_tsquery('portuguese', ?)) DESC",
                                q.content, ^search_term))
    end
  end
end