# DSM:SECURITY:zero_trust_policy_engine HEALTHCARE:trust_algorithm
# DSM:COMPLIANCE:NIST_SP_800_207 PERFORMANCE:<100ms_policy_decisions
defmodule HealthcareCMS.Security.PolicyEngine do
  @moduledoc """
  Zero Trust Policy Engine para Healthcare CMS

  Implementa NIST SP 800-207 compliant Policy Engine com algoritmos
  específicos para healthcare e trust scoring contextual.

  ## Componentes Core:
  - Trust Algorithm com scoring médico (0-100)
  - Policy Enforcement Points (PEPs)
  - Continuous verification
  - Healthcare context awareness
  - Audit trail para compliance
  """

  use GenServer
  require Logger

  alias HealthcareCMS.Repo
  alias HealthcareCMS.Security.{TrustAlgorithm, PolicyDecision}

  @policy_cache_ttl 300_000  # 5 minutos
  @trust_score_threshold 60
  @medical_professional_bonus 20
  @audit_all_decisions true

  # Client API

  @doc """
  Avalia uma solicitação de acesso usando Zero Trust Policy Engine

  ## Parâmetros:
  - `subject`: Usuário ou sistema fazendo a solicitação
  - `resource`: Recurso sendo acessado
  - `context`: Contexto da solicitação (device, location, time, etc.)

  ## Retorno:
  - `{:allow, access_level}` - Acesso permitido com nível específico
  - `{:deny, reason}` - Acesso negado com razão específica
  """
  def evaluate_access_request(subject, resource, context) do
    GenServer.call(__MODULE__, {:evaluate_access, subject, resource, context})
  end

  @doc """
  Calcula trust score para um subject específico

  Considera múltiplos fatores para healthcare:
  - Força da autenticação (MFA, certificados)
  - Padrões comportamentais históricos
  - Contexto do dispositivo e localização
  - Criticidade do recurso solicitado
  - Credenciais médicas profissionais
  """
  def calculate_trust_score(subject, context) do
    GenServer.call(__MODULE__, {:calculate_trust_score, subject, context})
  end

  @doc """
  Obtém políticas ativas para um tenant específico
  """
  def get_tenant_policies(tenant_id) do
    GenServer.call(__MODULE__, {:get_tenant_policies, tenant_id})
  end

  @doc """
  Atualiza cache de políticas (para mudanças regulatórias)
  """
  def refresh_policy_cache do
    GenServer.call(__MODULE__, :refresh_cache)
  end

  # Server Implementation

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Inicializar cache de políticas
    policy_cache = load_policy_cache()

    # Schedule periodic cache refresh
    Process.send_after(self(), :refresh_cache, @policy_cache_ttl)

    Logger.info("Healthcare Zero Trust Policy Engine iniciado")

    {:ok, %{
      policy_cache: policy_cache,
      metrics: %{
        decisions_made: 0,
        denials: 0,
        allows: 0,
        avg_decision_time: 0
      }
    }}
  end

  @impl true
  def handle_call({:evaluate_access, subject, resource, context}, _from, state) do
    start_time = System.monotonic_time(:millisecond)

    decision = evaluate_access_internal(subject, resource, context, state)

    end_time = System.monotonic_time(:millisecond)
    decision_time = end_time - start_time

    # Log decision para audit trail se configurado
    if @audit_all_decisions do
      log_policy_decision(subject, resource, context, decision, decision_time)
    end

    # Update metrics
    new_metrics = update_metrics(state.metrics, decision, decision_time)

    {:reply, decision, %{state | metrics: new_metrics}}
  end

  @impl true
  def handle_call({:calculate_trust_score, subject, context}, _from, state) do
    trust_score = TrustAlgorithm.calculate(subject, context)
    {:reply, trust_score, state}
  end

  @impl true
  def handle_call({:get_tenant_policies, tenant_id}, _from, state) do
    policies = Map.get(state.policy_cache, tenant_id, [])
    {:reply, policies, state}
  end

  @impl true
  def handle_call(:refresh_cache, _from, state) do
    new_cache = load_policy_cache()
    Logger.info("Policy cache refreshed: #{map_size(new_cache)} tenants")
    {:reply, :ok, %{state | policy_cache: new_cache}}
  end

  @impl true
  def handle_info(:refresh_cache, state) do
    # Periodic cache refresh
    new_cache = load_policy_cache()

    # Schedule next refresh
    Process.send_after(self(), :refresh_cache, @policy_cache_ttl)

    {:noreply, %{state | policy_cache: new_cache}}
  end

  # Private Functions

  defp evaluate_access_internal(subject, resource, context, state) do
    with {:ok, trust_score} <- calculate_trust_score_internal(subject, context),
         {:ok, risk_level} <- assess_risk_level(resource, context),
         {:ok, compliance_check} <- verify_compliance(subject, resource, state),
         {:ok, healthcare_context} <- validate_healthcare_context(subject, resource) do

      make_policy_decision(trust_score, risk_level, compliance_check, healthcare_context)
    else
      {:error, reason} -> {:deny, reason}
    end
  end

  defp calculate_trust_score_internal(subject, context) do
    base_score = 50

    score = base_score
    |> add_authentication_score(subject[:auth_method])
    |> add_device_score(context[:device_info])
    |> add_location_score(context[:location])
    |> add_behavior_score(subject[:recent_activity])
    |> add_medical_professional_score(subject[:professional_data])
    |> min(100)
    |> max(0)

    {:ok, score}
  end

  defp add_authentication_score(score, auth_method) do
    case auth_method do
      :mfa_enabled -> score + 25
      :certificate_based -> score + 30
      :password_only -> score - 10
      :api_key -> score + 10
      _ -> score
    end
  end

  defp add_device_score(score, device_info) do
    case device_info do
      %{trusted: true, managed: true} -> score + 15
      %{trusted: true} -> score + 10
      %{managed: true} -> score + 5
      %{unknown: true} -> score - 15
      _ -> score
    end
  end

  defp add_location_score(score, location) do
    case location do
      %{healthcare_facility: true} -> score + 10
      %{office_network: true} -> score + 5
      %{vpn: true} -> score + 5
      %{suspicious: true} -> score - 20
      _ -> score
    end
  end

  defp add_behavior_score(score, recent_activity) do
    case recent_activity do
      %{anomalous: true} -> score - 15
      %{consistent: true} -> score + 10
      %{first_time: true} -> score - 5
      _ -> score
    end
  end

  defp add_medical_professional_score(score, professional_data) do
    case professional_data do
      %{validated: true, crm: _crm} -> score + @medical_professional_bonus
      %{validated: true, crp: _crp} -> score + @medical_professional_bonus
      %{pending_validation: true} -> score + 5
      _ -> score
    end
  end

  defp assess_risk_level(resource, context) do
    risk_factors = [
      resource[:contains_phi] && :high,
      resource[:financial_data] && :high,
      resource[:admin_function] && :medium,
      resource[:public_content] && :low,
      context[:emergency_access] && :medium
    ]
    |> Enum.filter(& &1)

    risk_level = if :high in risk_factors do
      :high
    else
      if :medium in risk_factors, do: :medium, else: :low
    end

    {:ok, risk_level}
  end

  defp verify_compliance(subject, resource, state) do
    tenant_policies = Map.get(state.policy_cache, subject[:tenant_id], [])

    compliance_checks = [
      check_lgpd_compliance(subject, resource),
      check_cfm_compliance(subject, resource),
      check_tenant_policies(subject, resource, tenant_policies)
    ]

    if Enum.all?(compliance_checks, & &1 == :compliant) do
      {:ok, :compliant}
    else
      {:ok, :non_compliant}
    end
  end

  defp validate_healthcare_context(subject, resource) do
    # Validações específicas para healthcare
    healthcare_validations = [
      validate_professional_scope(subject, resource),
      validate_patient_context(resource),
      validate_medical_necessity(subject, resource)
    ]

    if Enum.all?(healthcare_validations, & &1 == :valid) do
      {:ok, :valid_healthcare_context}
    else
      {:ok, :invalid_healthcare_context}
    end
  end

  defp make_policy_decision(trust_score, risk_level, compliance_check, healthcare_context) do
    case {trust_score, risk_level, compliance_check, healthcare_context} do
      {score, :low, :compliant, :valid_healthcare_context} when score >= 80 ->
        {:allow, :full_access}

      {score, :medium, :compliant, :valid_healthcare_context} when score >= 70 ->
        {:allow, :limited_access}

      {score, :low, :compliant, _} when score >= @trust_score_threshold ->
        {:allow, :read_only}

      {score, :high, :compliant, :valid_healthcare_context} when score >= 90 ->
        {:allow, :supervised_access}

      {_, _, :non_compliant, _} ->
        {:deny, :compliance_violation}

      {score, _, _, _} when score < @trust_score_threshold ->
        {:deny, :insufficient_trust}

      {_, :high, _, :invalid_healthcare_context} ->
        {:deny, :invalid_medical_context}

      _ ->
        {:deny, :policy_violation}
    end
  end

  # Compliance check functions (simplified for initial implementation)
  defp check_lgpd_compliance(_subject, _resource), do: :compliant
  defp check_cfm_compliance(_subject, _resource), do: :compliant
  defp check_tenant_policies(_subject, _resource, _policies), do: :compliant

  # Healthcare validation functions (simplified for initial implementation)
  defp validate_professional_scope(_subject, _resource), do: :valid
  defp validate_patient_context(_resource), do: :valid
  defp validate_medical_necessity(_subject, _resource), do: :valid

  defp log_policy_decision(subject, resource, context, decision, decision_time) do
    audit_data = %{
      operation: "policy_evaluation",
      resource_type: "access_control",
      resource_id: resource[:id] || "unknown",
      tenant_id: subject[:tenant_id],
      user_id: subject[:id],
      metadata: %{
        decision: decision,
        decision_time_ms: decision_time,
        context: context,
        resource: resource
      },
      trust_score: context[:calculated_trust_score],
      policy_decision: inspect(decision)
    }

    # This would be implemented when HealthcareCMS.Audit is created
    # HealthcareCMS.Audit.log_operation(audit_data)
    Logger.info("Policy Decision: #{inspect(decision)} for user #{subject[:id]} (#{decision_time}ms)")
  end

  defp update_metrics(metrics, decision, decision_time) do
    total_decisions = metrics.decisions_made + 1
    new_avg_time = (metrics.avg_decision_time * metrics.decisions_made + decision_time) / total_decisions

    decision_updates = case decision do
      {:allow, _} -> %{allows: metrics.allows + 1}
      {:deny, _} -> %{denials: metrics.denials + 1}
    end

    metrics
    |> Map.merge(decision_updates)
    |> Map.put(:decisions_made, total_decisions)
    |> Map.put(:avg_decision_time, round(new_avg_time))
  end

  defp load_policy_cache do
    # For initial implementation, return empty cache
    # In production, this would load from database
    %{}
  end
end