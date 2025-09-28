# DSM:SECURITY:policy_decision HEALTHCARE:access_control
# DSM:COMPLIANCE:audit_trail_support NIST:SP_800_207
defmodule HealthcareCMS.Security.PolicyDecision do
  @moduledoc """
  Estrutura de dados para Policy Decisions no Zero Trust Healthcare CMS

  Representa decisões de política de acesso com metadados completos
  para audit trail e compliance.
  """

  defstruct [
    :decision,           # :allow | :deny
    :access_level,       # :full_access | :limited_access | :read_only | :supervised_access
    :reason,             # String explaining the decision
    :trust_score,        # Integer 0-100
    :risk_level,         # :low | :medium | :high
    :compliance_status,  # :compliant | :non_compliant
    :healthcare_context, # :valid_healthcare_context | :invalid_healthcare_context
    :conditions,         # List of conditions for access
    :expires_at,         # DateTime when decision expires
    :created_at,         # Decision timestamp
    :metadata            # Additional context data
  ]

  @type t :: %__MODULE__{
    decision: :allow | :deny,
    access_level: :full_access | :limited_access | :read_only | :supervised_access | nil,
    reason: String.t(),
    trust_score: integer(),
    risk_level: :low | :medium | :high,
    compliance_status: :compliant | :non_compliant,
    healthcare_context: :valid_healthcare_context | :invalid_healthcare_context,
    conditions: list(),
    expires_at: DateTime.t() | nil,
    created_at: DateTime.t(),
    metadata: map()
  }

  @doc """
  Cria uma PolicyDecision de acesso permitido
  """
  def allow(access_level, reason, trust_score, opts \\ []) do
    %__MODULE__{
      decision: :allow,
      access_level: access_level,
      reason: reason,
      trust_score: trust_score,
      risk_level: opts[:risk_level] || :low,
      compliance_status: opts[:compliance_status] || :compliant,
      healthcare_context: opts[:healthcare_context] || :valid_healthcare_context,
      conditions: opts[:conditions] || [],
      expires_at: opts[:expires_at],
      created_at: DateTime.utc_now(),
      metadata: opts[:metadata] || %{}
    }
  end

  @doc """
  Cria uma PolicyDecision de acesso negado
  """
  def deny(reason, trust_score, opts \\ []) do
    %__MODULE__{
      decision: :deny,
      access_level: nil,
      reason: reason,
      trust_score: trust_score,
      risk_level: opts[:risk_level] || :high,
      compliance_status: opts[:compliance_status] || :non_compliant,
      healthcare_context: opts[:healthcare_context] || :invalid_healthcare_context,
      conditions: [],
      expires_at: nil,
      created_at: DateTime.utc_now(),
      metadata: opts[:metadata] || %{}
    }
  end

  @doc """
  Verifica se uma decisão ainda é válida (não expirou)
  """
  def valid?(%__MODULE__{expires_at: nil}), do: true
  def valid?(%__MODULE__{expires_at: expires_at}) do
    DateTime.compare(DateTime.utc_now(), expires_at) == :lt
  end

  @doc """
  Converte PolicyDecision para mapa para logging/audit
  """
  def to_audit_data(%__MODULE__{} = decision) do
    decision
    |> Map.from_struct()
    |> Map.update!(:created_at, &DateTime.to_iso8601/1)
    |> Map.update!(:expires_at, fn
      nil -> nil
      dt -> DateTime.to_iso8601(dt)
    end)
  end

  @doc """
  Verifica se a decisão permite determinado nível de acesso
  """
  def allows_access?(%__MODULE__{decision: :deny}), do: false
  def allows_access?(%__MODULE__{decision: :allow}), do: true

  def allows_access_level?(%__MODULE__{decision: :deny}, _level), do: false
  def allows_access_level?(%__MODULE__{access_level: :full_access}, _level), do: true
  def allows_access_level?(%__MODULE__{access_level: level}, required_level) do
    access_level_hierarchy(level) >= access_level_hierarchy(required_level)
  end

  # Private helper to define access level hierarchy
  defp access_level_hierarchy(:full_access), do: 4
  defp access_level_hierarchy(:supervised_access), do: 3
  defp access_level_hierarchy(:limited_access), do: 2
  defp access_level_hierarchy(:read_only), do: 1
  defp access_level_hierarchy(_), do: 0
end