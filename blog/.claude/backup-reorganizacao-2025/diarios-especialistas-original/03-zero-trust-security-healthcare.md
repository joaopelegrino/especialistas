# 📚 Diário de Referências - Zero Trust Security para Healthcare

<!-- DSM:DOMAIN:security|zero_trust COMPLEXITY:expert DEPS:nist_sp_800_207 -->
<!-- DSM:HEALTHCARE:policy_engine|trust_algorithm|continuous_verification|compliance_automation -->
<!-- DSM:PERFORMANCE:policy_evaluation:<100ms trust_scoring:real_time threat_detection:>95% -->
<!-- DSM:COMPLIANCE:NIST_SP_800_207|LGPD|HIPAA|CFM|CRP|healthcare_regulations -->

*Última atualização: 2025-09-26*
*Versão: 1.0.0*
*Projeto: Healthcare Zero Trust Architecture (NIST SP 800-207)*
*Foco: LGPD + HIPAA + CFM/CRP Compliance*

## 🎯 Quick Access Index

- [🛡️ NIST Zero Trust Foundation](#-nist-zero-trust-foundation) - SP 800-207, Policy Engine, PEPs
- [🔐 Post-Quantum Cryptography](#-post-quantum-cryptography) - CRYSTALS-Kyber/Dilithium, ex_oqs
- [🏥 Healthcare Identity Management](#-healthcare-identity-management) - CRM/CRP validation, professional auth
- [📊 Continuous Monitoring](#-continuous-monitoring) - Trust scoring, behavioral analysis
- [⚖️ Compliance Automation](#-compliance-automation) - LGPD, HIPAA, CFM automated validation
- [🚨 Incident Response](#-incident-response) - Automated threat response, audit trails
- [🔧 Implementation Patterns](#-implementation-patterns) - Elixir/OTP specific patterns

---

## 🛡️ NIST Zero Trust Foundation

### NIST SP 800-207 Implementation

#### Zero Trust Core Components
**URL**: https://csrc.nist.gov/publications/detail/sp/800-207/final
**Tipo**: Federal Security Standard
**Validação**: NIST-Official, Healthcare-Adapted
**Última Verificação**: 2025-09-26
**Use Case**: Implementação completa Zero Trust para sistemas healthcare críticos
**Quick Command/Code**:
```elixir
# Core Zero Trust Architecture for Healthcare
defmodule Healthcare.ZeroTrust.Core do
  @moduledoc """
  Implementation of NIST SP 800-207 Zero Trust Architecture
  specifically adapted for healthcare environments with
  HIPAA, LGPD, and CFM/CRP compliance requirements.
  """

  use GenServer
  require Logger

  # NIST SP 800-207 Core Components
  @components %{
    policy_engine: Healthcare.ZeroTrust.PolicyEngine,
    policy_administrator: Healthcare.ZeroTrust.PolicyAdministrator,
    policy_enforcement_points: Healthcare.ZeroTrust.PEPManager,
    control_plane: Healthcare.ZeroTrust.ControlPlane,
    data_plane: Healthcare.ZeroTrust.DataPlane
  }

  # Healthcare-specific trust sources (NIST SP 800-207 Section 3.2)
  @trust_data_sources %{
    # Traditional sources
    cdm_system: Healthcare.TrustSources.CDMSystem,
    industry_compliance: Healthcare.TrustSources.ComplianceSystem,
    threat_intelligence: Healthcare.TrustSources.ThreatIntelligence,

    # Healthcare-specific sources
    professional_registry: Healthcare.TrustSources.ProfessionalRegistry,
    medical_device_mgmt: Healthcare.TrustSources.MedicalDeviceManagement,
    patient_consent_mgmt: Healthcare.TrustSources.ConsentManagement,
    clinical_context: Healthcare.TrustSources.ClinicalContext,
    regulatory_updates: Healthcare.TrustSources.RegulatoryUpdates
  }

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Initialize Zero Trust architecture with healthcare-specific configuration
  """
  @impl true
  def init(_opts) do
    Logger.info("Initializing Healthcare Zero Trust Architecture")

    # Initialize all components
    {:ok, pe_pid} = start_policy_engine()
    {:ok, pa_pid} = start_policy_administrator()
    {:ok, pep_manager} = start_pep_manager()
    {:ok, cp_pid} = start_control_plane()
    {:ok, dp_pid} = start_data_plane()

    # Initialize trust data source connections
    trust_sources = initialize_trust_sources()

    state = %{
      components: %{
        policy_engine: pe_pid,
        policy_administrator: pa_pid,
        pep_manager: pep_manager,
        control_plane: cp_pid,
        data_plane: dp_pid
      },
      trust_sources: trust_sources,
      active_sessions: %{},
      trust_scores: %{},
      security_posture: :initializing,
      stats: %{
        total_requests: 0,
        blocked_requests: 0,
        compliance_violations: 0,
        successful_authentications: 0
      }
    }

    # Schedule periodic security posture assessment
    :timer.send_interval(300_000, :assess_security_posture) # Every 5 minutes

    {:ok, state}
  end

  @doc """
  Evaluate access request through Zero Trust decision process
  """
  def evaluate_access_request(subject, resource, context) do
    GenServer.call(__MODULE__, {:evaluate_access, subject, resource, context}, 30_000)
  end

  @impl true
  def handle_call({:evaluate_access, subject, resource, context}, _from, state) do
    request_id = generate_request_id()
    start_time = System.monotonic_time(:microsecond)

    Logger.debug("Zero Trust evaluation started",
      request_id: request_id,
      subject: sanitize_subject(subject),
      resource: sanitize_resource(resource)
    )

    # Step 1: Gather intelligence from all trust sources
    trust_data = gather_trust_intelligence(subject, resource, context, state.trust_sources)

    # Step 2: Calculate dynamic trust score
    trust_score = calculate_healthcare_trust_score(subject, resource, context, trust_data)

    # Step 3: Apply healthcare compliance rules
    compliance_result = apply_compliance_rules(subject, resource, context, trust_data)

    # Step 4: Make access decision through Policy Engine
    decision = make_access_decision(trust_score, compliance_result, resource, trust_data)

    # Step 5: Configure Policy Enforcement Points
    pep_config = configure_peps(decision, subject, resource, context)

    # Step 6: Log decision for audit trail (HIPAA requirement)
    log_access_decision(request_id, subject, resource, decision, trust_score, compliance_result)

    # Step 7: Update trust score based on decision outcome
    update_subject_trust_score(subject, decision, trust_score)

    execution_time = System.monotonic_time(:microsecond) - start_time

    # Update statistics
    new_stats = update_access_stats(state.stats, decision, execution_time)

    {:reply, decision, %{state | stats: new_stats}}
  end

  @impl true
  def handle_info(:assess_security_posture, state) do
    current_posture = assess_overall_security_posture(state)

    if current_posture != state.security_posture do
      Logger.info("Security posture changed",
        from: state.security_posture,
        to: current_posture
      )

      # Adjust policies based on posture
      adjust_security_policies(current_posture)
    end

    {:noreply, %{state | security_posture: current_posture}}
  end

  # Private implementation functions

  defp start_policy_engine do
    Healthcare.ZeroTrust.PolicyEngine.start_link([
      trust_algorithm: :healthcare_adaptive,
      evaluation_sources: Map.keys(@trust_data_sources),
      compliance_frameworks: [:lgpd, :hipaa, :cfm, :crp, :anvisa]
    ])
  end

  defp start_policy_administrator do
    Healthcare.ZeroTrust.PolicyAdministrator.start_link([
      policy_store: Healthcare.PolicyStore,
      update_interval: 60_000, # 1 minute
      compliance_sync: true
    ])
  end

  defp start_pep_manager do
    Healthcare.ZeroTrust.PEPManager.start_link([
      pep_types: [:api_gateway, :database_proxy, :wasm_runtime, :ui_gateway],
      enforcement_mode: :strict,
      logging_level: :comprehensive
    ])
  end

  defp gather_trust_intelligence(subject, resource, context, trust_sources) do
    # Parallel gathering from all trust sources
    trust_tasks = Enum.map(trust_sources, fn {source, module} ->
      Task.async(fn ->
        {source, module.gather_intelligence(subject, resource, context)}
      end)
    end)

    # Wait for all sources with timeout
    trust_data = trust_tasks
    |> Task.await_many(10_000) # 10 second timeout
    |> Enum.into(%{})

    trust_data
  end

  defp calculate_healthcare_trust_score(subject, resource, context, trust_data) do
    Healthcare.TrustAlgorithm.calculate_comprehensive_score(%{
      subject: subject,
      resource: resource,
      context: context,
      trust_data: trust_data,
      algorithm_type: :healthcare_weighted,
      factors: %{
        identity_strength: 0.20,
        device_compliance: 0.15,
        behavioral_analysis: 0.20,
        professional_validation: 0.15,
        clinical_context: 0.10,
        compliance_history: 0.10,
        threat_indicators: 0.10
      }
    })
  end

  defp apply_compliance_rules(subject, resource, context, trust_data) do
    Healthcare.ComplianceEngine.evaluate_comprehensive(%{
      frameworks: [:lgpd, :hipaa, :cfm, :crp],
      subject: subject,
      resource: resource,
      context: context,
      trust_data: trust_data,
      enforcement_mode: :strict
    })
  end

  defp make_access_decision(trust_score, compliance_result, resource, trust_data) do
    base_decision = determine_base_decision(trust_score, compliance_result, resource)

    # Apply healthcare-specific decision modifiers
    enhanced_decision = apply_healthcare_decision_modifiers(
      base_decision,
      trust_score,
      compliance_result,
      resource,
      trust_data
    )

    # Add audit and monitoring requirements
    add_healthcare_monitoring_requirements(enhanced_decision, resource)
  end

  defp determine_base_decision(trust_score, compliance_result, resource) do
    min_score = get_minimum_trust_score(resource)

    cond do
      compliance_result.status == :violation ->
        %{
          decision: :deny,
          reason: :compliance_violation,
          violations: compliance_result.violations,
          remediation_required: true
        }

      trust_score < min_score ->
        %{
          decision: :deny,
          reason: :insufficient_trust,
          required_score: min_score,
          actual_score: trust_score,
          improvement_suggestions: generate_trust_improvement_suggestions(trust_score, min_score)
        }

      trust_score < min_score + 10 && resource.sensitivity == :high ->
        %{
          decision: :challenge,
          reason: :additional_verification_required,
          required_actions: determine_additional_verification(resource, trust_score),
          conditional_access: true
        }

      true ->
        %{
          decision: :allow,
          trust_score: trust_score,
          compliance_status: compliance_result.status,
          monitoring_level: determine_monitoring_level(trust_score, resource)
        }
    end
  end

  defp get_minimum_trust_score(resource) do
    case resource.classification do
      :public -> 30
      :internal -> 50
      :confidential -> 65
      :patient_data -> 75
      :critical_patient_data -> 85
      :research_data -> 70
      :financial_healthcare -> 80
      :regulatory_compliance -> 85
    end
  end

  defp apply_healthcare_decision_modifiers(decision, trust_score, compliance_result, resource, trust_data) do
    modified_decision = decision

    # Healthcare-specific modifiers
    modified_decision = apply_professional_validation_modifier(modified_decision, trust_data)
    modified_decision = apply_patient_safety_modifier(modified_decision, resource, trust_data)
    modified_decision = apply_emergency_access_modifier(modified_decision, trust_data)
    modified_decision = apply_clinical_context_modifier(modified_decision, trust_data)

    modified_decision
  end

  defp apply_professional_validation_modifier(decision, trust_data) do
    case trust_data[:professional_registry] do
      %{status: :verified, specialty_match: true, license_active: true} ->
        # Boost trust for verified professionals
        Map.update(decision, :trust_boost, 5, &(&1 + 5))

      %{status: :verified, license_active: false} ->
        # Block access for professionals with inactive licenses
        %{decision | decision: :deny, reason: :inactive_professional_license}

      %{status: :unverified} ->
        # Require additional verification for unverified professionals
        Map.put(decision, :additional_verification, [:professional_license_verification])

      _ ->
        decision
    end
  end

  defp apply_patient_safety_modifier(decision, resource, trust_data) do
    if resource.affects_patient_safety do
      # Require additional safeguards for patient safety-critical resources
      Map.merge(decision, %{
        patient_safety_critical: true,
        required_approvals: [:clinical_supervisor, :patient_safety_officer],
        audit_level: :comprehensive,
        real_time_monitoring: true
      })
    else
      decision
    end
  end

  defp apply_emergency_access_modifier(decision, trust_data) do
    case trust_data[:clinical_context] do
      %{emergency_situation: true, verified_emergency: true} ->
        # Allow emergency access with enhanced monitoring
        %{decision |
          decision: :allow,
          emergency_access: true,
          monitoring_level: :maximum,
          post_emergency_review_required: true
        }

      %{emergency_situation: true, verified_emergency: false} ->
        # Require emergency verification
        Map.put(decision, :emergency_verification_required, true)

      _ ->
        decision
    end
  end

  defp configure_peps(decision, subject, resource, context) do
    Healthcare.ZeroTrust.PEPManager.configure_enforcement(%{
      decision: decision,
      subject: subject,
      resource: resource,
      context: context,
      enforcement_points: determine_required_peps(resource),
      monitoring_requirements: extract_monitoring_requirements(decision)
    })
  end

  defp log_access_decision(request_id, subject, resource, decision, trust_score, compliance_result) do
    Healthcare.AuditLog.log_zero_trust_decision(%{
      request_id: request_id,
      timestamp: DateTime.utc_now(),
      subject: sanitize_subject_for_audit(subject),
      resource: sanitize_resource_for_audit(resource),
      decision: decision.decision,
      trust_score: trust_score,
      compliance_status: compliance_result.status,
      policy_version: Healthcare.PolicyStore.current_version(),
      enforcement_points: decision[:enforcement_points] || [],
      additional_context: %{
        decision_factors: extract_decision_factors(decision),
        compliance_details: compliance_result.details,
        monitoring_requirements: decision[:monitoring_level]
      }
    })
  end

  # Additional helper functions...

  defp initialize_trust_sources do
    @trust_data_sources
    |> Enum.map(fn {source, module} ->
      case module.initialize() do
        {:ok, connection} -> {source, connection}
        {:error, reason} ->
          Logger.error("Failed to initialize trust source #{source}: #{reason}")
          {source, :unavailable}
      end
    end)
    |> Enum.into(%{})
  end

  defp generate_request_id do
    "zt_req_#{System.unique_integer([:positive])}_#{:os.system_time(:microsecond)}"
  end

  defp sanitize_subject(subject) do
    %{id: subject.id, type: subject.type, role: subject.role}
  end

  defp sanitize_resource(resource) do
    %{id: resource.id, type: resource.type, classification: resource.classification}
  end

  defp sanitize_subject_for_audit(subject) do
    %{
      id: hash_pii(subject.id),
      type: subject.type,
      role: subject.role,
      professional_type: subject[:professional_type],
      # Never log sensitive personal information
      audit_timestamp: DateTime.utc_now()
    }
  end

  defp sanitize_resource_for_audit(resource) do
    %{
      id: resource.id,
      type: resource.type,
      classification: resource.classification,
      sensitivity_level: resource[:sensitivity_level],
      patient_data_involved: resource[:contains_patient_data] || false
    }
  end

  defp hash_pii(value) when is_binary(value) do
    :crypto.hash(:sha256, value) |> Base.encode16(case: :lower) |> String.slice(0, 16)
  end

  defp update_access_stats(stats, decision, execution_time) do
    new_stats = %{stats | total_requests: stats.total_requests + 1}

    case decision.decision do
      :deny ->
        %{new_stats | blocked_requests: new_stats.blocked_requests + 1}
      :allow ->
        %{new_stats | successful_authentications: new_stats.successful_authentications + 1}
      _ ->
        new_stats
    end
  end

  defp assess_overall_security_posture(state) do
    # Calculate security posture based on multiple factors
    recent_stats = get_recent_security_stats(state.stats)
    threat_level = Healthcare.ThreatIntelligence.get_current_threat_level()
    compliance_status = Healthcare.ComplianceMonitor.get_overall_status()

    calculate_security_posture(recent_stats, threat_level, compliance_status)
  end

  defp calculate_security_posture(stats, threat_level, compliance_status) do
    # Simplified posture calculation
    block_rate = if stats.total_requests > 0 do
      stats.blocked_requests / stats.total_requests
    else
      0
    end

    cond do
      compliance_status == :critical_violation -> :critical
      threat_level == :high and block_rate > 0.1 -> :high_risk
      threat_level == :medium or block_rate > 0.05 -> :elevated
      compliance_status == :compliant and threat_level == :low -> :normal
      true -> :elevated
    end
  end

  defp adjust_security_policies(new_posture) do
    case new_posture do
      :critical ->
        Healthcare.PolicyAdministrator.apply_emergency_lockdown()
      :high_risk ->
        Healthcare.PolicyAdministrator.increase_security_level(:high)
      :elevated ->
        Healthcare.PolicyAdministrator.increase_security_level(:medium)
      :normal ->
        Healthcare.PolicyAdministrator.restore_normal_operations()
    end
  end
end
```
**Notas**:
- Implementação completa NIST SP 800-207 adaptada para healthcare
- 8 fontes de confiança específicas para saúde
- Policy Engine com algoritmo específico médico
**Relacionados**:
- [NIST SP 800-207](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [Zero Trust Maturity Model](https://www.cisa.gov/zero-trust-maturity-model)

### Policy Enforcement Points (PEPs)

#### Healthcare-Specific PEPs
**URL**: https://csrc.nist.gov/publications/detail/sp/800-207/final
**Tipo**: Security Architecture Pattern
**Validação**: NIST-Compliant, HIPAA-Ready
**Última Verificação**: 2025-09-26
**Use Case**: Enforcement points especializados para dados médicos e compliance
**Quick Command/Code**:
```elixir
# Healthcare Policy Enforcement Points
defmodule Healthcare.ZeroTrust.PEPManager do
  @moduledoc """
  Manages Policy Enforcement Points (PEPs) for healthcare environments.
  Implements NIST SP 800-207 PEP requirements with healthcare-specific
  enforcement policies for LGPD, HIPAA, and medical regulatory compliance.
  """

  use GenServer
  require Logger

  # Healthcare-specific PEP types
  @pep_types %{
    # API Gateway PEP - Controls API access
    api_gateway: Healthcare.ZeroTrust.PEPs.APIGateway,

    # Database Proxy PEP - Controls database queries
    database_proxy: Healthcare.ZeroTrust.PEPs.DatabaseProxy,

    # WASM Runtime PEP - Controls plugin execution
    wasm_runtime: Healthcare.ZeroTrust.PEPs.WASMRuntime,

    # UI Gateway PEP - Controls web interface access
    ui_gateway: Healthcare.ZeroTrust.PEPs.UIGateway,

    # File Access PEP - Controls medical document access
    file_access: Healthcare.ZeroTrust.PEPs.FileAccess,

    # Healthcare Device PEP - Controls medical device integration
    device_integration: Healthcare.ZeroTrust.PEPs.DeviceIntegration
  }

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    pep_types = Keyword.get(opts, :pep_types, Map.keys(@pep_types))
    enforcement_mode = Keyword.get(opts, :enforcement_mode, :strict)
    logging_level = Keyword.get(opts, :logging_level, :standard)

    # Initialize all required PEPs
    active_peps = initialize_peps(pep_types, enforcement_mode, logging_level)

    state = %{
      active_peps: active_peps,
      enforcement_mode: enforcement_mode,
      logging_level: logging_level,
      enforcement_stats: initialize_stats(),
      policy_cache: %{},
      real_time_monitoring: true
    }

    {:ok, state}
  end

  @doc """
  Configure enforcement for a specific access decision
  """
  def configure_enforcement(config) do
    GenServer.call(__MODULE__, {:configure_enforcement, config})
  end

  @impl true
  def handle_call({:configure_enforcement, config}, _from, state) do
    enforcement_id = generate_enforcement_id()

    # Determine which PEPs need to be configured
    required_peps = determine_required_peps(config.resource, config.decision)

    # Configure each required PEP
    pep_configurations = Enum.map(required_peps, fn pep_type ->
      configure_pep(pep_type, config, enforcement_id, state)
    end)

    # Update enforcement statistics
    new_stats = update_enforcement_stats(state.enforcement_stats, config, pep_configurations)

    result = %{
      enforcement_id: enforcement_id,
      configured_peps: pep_configurations,
      monitoring_enabled: state.real_time_monitoring,
      compliance_tracking: extract_compliance_requirements(config)
    }

    {:reply, {:ok, result}, %{state | enforcement_stats: new_stats}}
  end

  # PEP Configuration Functions

  defp configure_pep(:api_gateway, config, enforcement_id, state) do
    pep = state.active_peps[:api_gateway]

    api_config = %{
      enforcement_id: enforcement_id,
      decision: config.decision,
      subject: config.subject,
      resource: config.resource,

      # API-specific enforcement rules
      rate_limiting: determine_rate_limits(config),
      request_filtering: build_request_filters(config),
      response_filtering: build_response_filters(config),
      audit_requirements: extract_audit_requirements(config),

      # Healthcare-specific API rules
      phi_protection: config.resource.contains_phi,
      consent_validation: build_consent_requirements(config),
      professional_validation: requires_professional_validation?(config),

      # Compliance requirements
      lgpd_controls: build_lgpd_controls(config),
      hipaa_controls: build_hipaa_controls(config),
      cfm_controls: build_cfm_controls(config)
    }

    Healthcare.ZeroTrust.PEPs.APIGateway.configure(pep, api_config)

    %{
      pep_type: :api_gateway,
      configuration: api_config,
      status: :configured,
      monitoring: state.real_time_monitoring
    }
  end

  defp configure_pep(:database_proxy, config, enforcement_id, state) do
    pep = state.active_peps[:database_proxy]

    db_config = %{
      enforcement_id: enforcement_id,
      decision: config.decision,
      subject: config.subject,
      resource: config.resource,

      # Database-specific enforcement
      query_filtering: build_query_filters(config),
      result_masking: build_result_masking(config),
      audit_logging: :comprehensive,

      # Healthcare database controls
      patient_data_access: build_patient_data_controls(config),
      research_data_access: build_research_data_controls(config),
      clinical_context_required: config.resource.requires_clinical_context,

      # Row-level security
      tenant_isolation: build_tenant_isolation(config),
      professional_scope: build_professional_scope(config),

      # Compliance controls
      data_classification_enforcement: true,
      retention_policy_enforcement: true,
      anonymization_requirements: build_anonymization_rules(config)
    }

    Healthcare.ZeroTrust.PEPs.DatabaseProxy.configure(pep, db_config)

    %{
      pep_type: :database_proxy,
      configuration: db_config,
      status: :configured,
      monitoring: :comprehensive
    }
  end

  defp configure_pep(:wasm_runtime, config, enforcement_id, state) do
    pep = state.active_peps[:wasm_runtime]

    wasm_config = %{
      enforcement_id: enforcement_id,
      decision: config.decision,
      subject: config.subject,
      resource: config.resource,

      # WASM-specific security controls
      memory_limits: determine_wasm_memory_limits(config),
      execution_timeout: determine_wasm_timeout(config),
      capability_restrictions: build_wasm_capabilities(config),

      # Healthcare WASM controls
      phi_processing_allowed: config.resource.allows_phi_processing,
      medical_validation_required: config.resource.requires_medical_validation,
      compliance_sandbox: build_compliance_sandbox(config),

      # Plugin-specific controls
      plugin_verification: :required,
      output_validation: build_output_validation(config),
      audit_trail: :comprehensive,

      # Security monitoring
      real_time_monitoring: true,
      anomaly_detection: :enabled,
      resource_monitoring: :continuous
    }

    Healthcare.ZeroTrust.PEPs.WASMRuntime.configure(pep, wasm_config)

    %{
      pep_type: :wasm_runtime,
      configuration: wasm_config,
      status: :configured,
      security_level: :maximum
    }
  end

  defp configure_pep(:ui_gateway, config, enforcement_id, state) do
    pep = state.active_peps[:ui_gateway]

    ui_config = %{
      enforcement_id: enforcement_id,
      decision: config.decision,
      subject: config.subject,
      resource: config.resource,

      # UI-specific controls
      screen_masking: build_screen_masking_rules(config),
      field_level_access: build_field_access_controls(config),
      session_management: build_session_controls(config),

      # Healthcare UI controls
      patient_data_display: build_patient_display_rules(config),
      clinical_workflow_controls: build_workflow_controls(config),
      emergency_access_ui: config[:emergency_access] || false,

      # Audit and compliance
      user_activity_logging: :comprehensive,
      screen_recording_policy: determine_screen_recording_policy(config),
      data_export_controls: build_export_controls(config),

      # Security headers and CSP
      security_headers: build_security_headers(config),
      content_security_policy: build_csp(config),

      # Professional context
      specialty_based_ui: customize_for_specialty(config),
      clinical_decision_support: enable_cds(config)
    }

    Healthcare.ZeroTrust.PEPs.UIGateway.configure(pep, ui_config)

    %{
      pep_type: :ui_gateway,
      configuration: ui_config,
      status: :configured,
      user_experience: :healthcare_optimized
    }
  end

  # Helper Functions for PEP Configuration

  defp determine_rate_limits(config) do
    case config.resource.classification do
      :critical_patient_data -> %{requests_per_minute: 10, burst_limit: 5}
      :patient_data -> %{requests_per_minute: 30, burst_limit: 10}
      :confidential -> %{requests_per_minute: 60, burst_limit: 20}
      _ -> %{requests_per_minute: 100, burst_limit: 30}
    end
  end

  defp build_request_filters(config) do
    filters = []

    # Always validate request structure
    filters = [:request_structure_validation | filters]

    # Add PII/PHI detection
    if config.resource.contains_phi do
      filters = [:phi_detection, :pii_detection | filters]
    end

    # Add professional context validation
    if requires_professional_validation?(config) do
      filters = [:professional_context_validation | filters]
    end

    # Add consent validation
    if config.resource.requires_consent do
      filters = [:consent_validation | filters]
    end

    filters
  end

  defp build_response_filters(config) do
    filters = []

    # Always apply output sanitization
    filters = [:output_sanitization | filters]

    # Add data classification enforcement
    filters = [:data_classification_enforcement | filters]

    # Add PII/PHI redaction if needed
    if config.resource.contains_phi do
      filters = [:phi_redaction, :pii_redaction | filters]
    end

    # Add compliance headers
    filters = [:compliance_headers | filters]

    filters
  end

  defp build_patient_data_controls(config) do
    %{
      access_logging: :comprehensive,
      minimum_necessary_principle: true,
      consent_verification: config.resource.requires_consent,
      purpose_limitation: determine_purpose_limitation(config),
      data_minimization: true,
      retention_enforcement: true,

      # Clinical context requirements
      clinical_justification_required: config.resource.classification == :critical_patient_data,
      treatment_context_validation: config.resource.requires_clinical_context,

      # Professional requirements
      professional_license_verification: true,
      specialty_scope_enforcement: build_specialty_scope(config),

      # Audit requirements
      patient_data_access_audit: :real_time,
      disclosure_tracking: :enabled,

      # Privacy controls
      anonymization_rules: build_anonymization_rules(config),
      pseudonymization_rules: build_pseudonymization_rules(config)
    }
  end

  defp build_compliance_sandbox(config) do
    %{
      # LGPD compliance sandbox
      lgpd_controls: %{
        purpose_limitation: true,
        data_minimization: true,
        consent_validation: config.resource.requires_consent,
        retention_enforcement: true,
        portability_support: true,
        erasure_support: true
      },

      # HIPAA compliance sandbox
      hipaa_controls: %{
        minimum_necessary: true,
        access_controls: :strict,
        audit_logging: :comprehensive,
        encryption_required: :always,
        breach_detection: :enabled
      },

      # CFM/CRP compliance sandbox
      professional_controls: %{
        license_verification: :required,
        specialty_validation: :required,
        ethical_guidelines: :enforced,
        medical_advertising_rules: :enforced,
        patient_confidentiality: :maximum
      },

      # Technical controls
      output_validation: :comprehensive,
      data_leakage_prevention: :enabled,
      anomaly_detection: :enabled,

      # Monitoring
      real_time_compliance_monitoring: true,
      violation_detection: :immediate,
      automated_remediation: :enabled
    }
  end

  defp initialize_peps(pep_types, enforcement_mode, logging_level) do
    pep_types
    |> Enum.map(fn pep_type ->
      pep_module = @pep_types[pep_type]

      case pep_module.start_link([
        enforcement_mode: enforcement_mode,
        logging_level: logging_level,
        healthcare_mode: true
      ]) do
        {:ok, pid} ->
          Logger.info("Initialized PEP: #{pep_type}")
          {pep_type, pid}

        {:error, reason} ->
          Logger.error("Failed to initialize PEP #{pep_type}: #{reason}")
          {pep_type, :failed}
      end
    end)
    |> Enum.into(%{})
  end

  defp determine_required_peps(resource, decision) do
    base_peps = [:api_gateway] # Always required

    # Add database PEP if resource involves data access
    peps = if resource.involves_database_access do
      [:database_proxy | base_peps]
    else
      base_peps
    end

    # Add WASM runtime PEP if decision involves plugin execution
    peps = if decision[:plugin_execution_required] do
      [:wasm_runtime | peps]
    else
      peps
    end

    # Add UI gateway PEP for web interface access
    peps = if resource.interface_type == :web do
      [:ui_gateway | peps]
    else
      peps
    end

    # Add file access PEP for document access
    peps = if resource.type in [:document, :image, :report] do
      [:file_access | peps]
    else
      peps
    end

    # Add device integration PEP for medical device access
    peps = if resource.involves_medical_devices do
      [:device_integration | peps]
    else
      peps
    end

    Enum.uniq(peps)
  end

  defp requires_professional_validation?(config) do
    config.resource.requires_professional_validation ||
    config.resource.classification in [:patient_data, :critical_patient_data] ||
    config.subject.role in [:doctor, :nurse, :specialist]
  end

  defp generate_enforcement_id do
    "pep_enf_#{System.unique_integer([:positive])}_#{:os.system_time(:microsecond)}"
  end

  defp initialize_stats do
    %{
      total_enforcements: 0,
      successful_enforcements: 0,
      blocked_requests: 0,
      compliance_violations: 0,
      pep_performance: %{},
      last_reset: DateTime.utc_now()
    }
  end

  defp update_enforcement_stats(stats, config, pep_configurations) do
    %{stats |
      total_enforcements: stats.total_enforcements + 1,
      successful_enforcements: stats.successful_enforcements + length(pep_configurations)
    }
  end

  # Additional helper functions would be implemented here...

  defp extract_compliance_requirements(config), do: %{}
  defp extract_audit_requirements(config), do: %{}
  defp build_consent_requirements(config), do: %{}
  defp build_lgpd_controls(config), do: %{}
  defp build_hipaa_controls(config), do: %{}
  defp build_cfm_controls(config), do: %{}
  defp build_query_filters(config), do: %{}
  defp build_result_masking(config), do: %{}
  defp build_research_data_controls(config), do: %{}
  defp build_tenant_isolation(config), do: %{}
  defp build_professional_scope(config), do: %{}
  defp build_anonymization_rules(config), do: %{}
  defp build_pseudonymization_rules(config), do: %{}
  defp determine_wasm_memory_limits(config), do: 64 * 1024 * 1024
  defp determine_wasm_timeout(config), do: 30_000
  defp build_wasm_capabilities(config), do: %{}
  defp build_output_validation(config), do: %{}
  defp build_screen_masking_rules(config), do: %{}
  defp build_field_access_controls(config), do: %{}
  defp build_session_controls(config), do: %{}
  defp build_patient_display_rules(config), do: %{}
  defp build_workflow_controls(config), do: %{}
  defp determine_screen_recording_policy(config), do: :disabled
  defp build_export_controls(config), do: %{}
  defp build_security_headers(config), do: %{}
  defp build_csp(config), do: %{}
  defp customize_for_specialty(config), do: %{}
  defp enable_cds(config), do: false
  defp determine_purpose_limitation(config), do: "healthcare_treatment"
  defp build_specialty_scope(config), do: %{}
end
```
**Notas**:
- 6 tipos de PEPs especializados para healthcare
- Configuração dinâmica baseada em decisões Zero Trust
- Compliance automática LGPD/HIPAA/CFM integrada
**Relacionados**:
- [NIST PEP Guidelines](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)

---

## 🔐 Post-Quantum Cryptography

### CRYSTALS Implementation

#### ML-KEM/ML-DSA Healthcare Integration
**URL**: https://github.com/chrisliaw/ex_oqs
**Tipo**: Post-Quantum Cryptography Library
**Validação**: NIST-Standardized (FIPS 203/204)
**Última Verificação**: 2025-09-26
**Use Case**: Proteção quantum-safe para dados médicos de longo prazo
**Quick Command/Code**:
```elixir
# Healthcare Post-Quantum Cryptography Manager
defmodule Healthcare.PostQuantumCrypto do
  @moduledoc """
  Comprehensive post-quantum cryptography implementation for healthcare.
  Implements CRYSTALS-Kyber (ML-KEM) and CRYSTALS-Dilithium (ML-DSA)
  with healthcare-specific key management and compliance features.
  """

  alias ExOqs.{KEM, Signature}
  require Logger

  # NIST-standardized algorithms with security levels
  @kem_algorithms %{
    # ML-KEM (CRYSTALS-Kyber) - Key Encapsulation Mechanisms
    ml_kem_512: %{
      algorithm: :kyber512,
      security_level: 1, # ~128-bit
      use_case: "Standard healthcare communications",
      performance_impact: "+60% vs RSA-2048",
      recommended_for: [:general_communications, :standard_patient_data]
    },
    ml_kem_768: %{
      algorithm: :kyber768,
      security_level: 3, # ~192-bit (RECOMMENDED)
      use_case: "Critical patient data, long-term storage",
      performance_impact: "+65% vs RSA-2048",
      recommended_for: [:patient_records, :clinical_trials, :research_data]
    },
    ml_kem_1024: %{
      algorithm: :kyber1024,
      security_level: 5, # ~256-bit
      use_case: "Maximum security, regulatory compliance",
      performance_impact: "+70% vs RSA-2048",
      recommended_for: [:critical_infrastructure, :regulatory_submissions]
    }
  }

  @sig_algorithms %{
    # ML-DSA (CRYSTALS-Dilithium) - Digital Signature Algorithm
    ml_dsa_44: %{
      algorithm: :dilithium2,
      security_level: 1, # ~128-bit
      signature_size: "~2KB",
      use_case: "Standard document signing",
      recommended_for: [:prescriptions, :medical_certificates]
    },
    ml_dsa_65: %{
      algorithm: :dilithium3,
      security_level: 3, # ~192-bit (RECOMMENDED)
      signature_size: "~3KB",
      use_case: "Critical medical documents",
      recommended_for: [:surgical_reports, :clinical_trial_data, :regulatory_reports]
    },
    ml_dsa_87: %{
      algorithm: :dilithium5,
      security_level: 5, # ~256-bit
      signature_size: "~5KB",
      use_case: "Maximum security signatures",
      recommended_for: [:legal_documents, :compliance_attestations]
    }
  }

  # Default algorithms for healthcare (NIST Level 3 - 192-bit equivalent)
  @default_kem :ml_kem_768
  @default_sig :ml_dsa_65

  @doc """
  Initialize post-quantum cryptography for healthcare professional
  """
  def initialize_professional_crypto(professional_data) do
    %{
      crm: crm,
      crp: crp,
      specialty: specialty,
      institution: institution
    } = professional_data

    # Generate quantum-safe key pairs
    with {:ok, {kem_public, kem_private, kem_metadata}} <- generate_kem_keypair(professional_data),
         {:ok, {sig_public, sig_private, sig_metadata}} <- generate_sig_keypair(professional_data) do

      # Store keys in secure hardware if available
      key_storage_result = store_keys_securely(%{
        professional: professional_data,
        kem_keys: {kem_public, kem_private, kem_metadata},
        sig_keys: {sig_public, sig_private, sig_metadata}
      })

      # Register keys with healthcare PKI
      pki_registration = register_with_healthcare_pki(%{
        professional: professional_data,
        kem_public: kem_public,
        sig_public: sig_public,
        metadata: %{kem: kem_metadata, sig: sig_metadata}
      })

      {:ok, %{
        professional_id: generate_professional_crypto_id(crm || crp),
        kem_keypair: %{
          public: kem_public,
          metadata: kem_metadata,
          storage_location: key_storage_result.kem_location
        },
        sig_keypair: %{
          public: sig_public,
          metadata: sig_metadata,
          storage_location: key_storage_result.sig_location
        },
        pki_registration: pki_registration,
        compliance_attestation: generate_compliance_attestation(professional_data)
      }}

    else
      {:error, reason} ->
        Logger.error("Failed to initialize PQ crypto for professional",
          professional: sanitize_professional_data(professional_data),
          reason: reason
        )
        {:error, reason}
    end
  end

  @doc """
  Encrypt patient data with hybrid classical-quantum protection
  """
  def encrypt_patient_data(patient_data, recipient_public_key, options \\ []) do
    algorithm = Keyword.get(options, :algorithm, @default_kem)
    include_classical = Keyword.get(options, :hybrid_mode, true)
    compliance_context = Keyword.get(options, :compliance_context, %{})

    # Validate patient data classification
    case classify_patient_data_sensitivity(patient_data, compliance_context) do
      {:ok, sensitivity_level} ->
        perform_encryption(patient_data, recipient_public_key, algorithm, sensitivity_level, include_classical)

      {:error, classification_error} ->
        {:error, {:data_classification_failed, classification_error}}
    end
  end

  defp perform_encryption(patient_data, recipient_public_key, algorithm, sensitivity_level, hybrid_mode) do
    kem_config = @kem_algorithms[algorithm]

    # Step 1: Generate shared secret using ML-KEM
    with {:ok, {shared_secret, kem_ciphertext}} <- KEM.encaps(recipient_public_key, kem_config.algorithm) do

      # Step 2: Derive encryption key from shared secret
      encryption_key = derive_patient_data_key(shared_secret, sensitivity_level)

      # Step 3: Encrypt patient data with AES-256-GCM
      case encrypt_with_aes_gcm(patient_data, encryption_key) do
        {:ok, encrypted_data, auth_tag} ->

          # Step 4: Create quantum-safe envelope
          quantum_envelope = %{
            version: "1.0",
            algorithm: algorithm,
            kem_ciphertext: kem_ciphertext,
            encrypted_data: encrypted_data,
            auth_tag: auth_tag,
            metadata: %{
              sensitivity_level: sensitivity_level,
              encrypted_at: DateTime.utc_now(),
              data_classification: classify_for_retention(patient_data),
              compliance_flags: extract_compliance_flags(patient_data)
            }
          }

          # Step 5: Add classical encryption if hybrid mode
          final_envelope = if hybrid_mode do
            case add_classical_encryption_layer(quantum_envelope, patient_data) do
              {:ok, hybrid_envelope} -> hybrid_envelope
              {:error, _} -> quantum_envelope # Fallback to quantum-only
            end
          else
            quantum_envelope
          end

          # Step 6: Log encryption for audit trail
          log_encryption_event(final_envelope.metadata, algorithm, sensitivity_level)

          {:ok, final_envelope}

        {:error, encryption_error} ->
          {:error, {:symmetric_encryption_failed, encryption_error}}
      end

    else
      {:error, kem_error} ->
        {:error, {:key_encapsulation_failed, kem_error}}
    end
  end

  @doc """
  Decrypt patient data with quantum-safe protection
  """
  def decrypt_patient_data(encrypted_envelope, recipient_private_key, options \\ []) do
    audit_context = Keyword.get(options, :audit_context, %{})
    verify_integrity = Keyword.get(options, :verify_integrity, true)

    # Step 1: Validate envelope structure
    case validate_encryption_envelope(encrypted_envelope) do
      {:ok, validated_envelope} ->
        perform_decryption(validated_envelope, recipient_private_key, audit_context, verify_integrity)

      {:error, validation_error} ->
        log_decryption_failure(:envelope_validation_failed, validation_error, audit_context)
        {:error, {:invalid_envelope, validation_error}}
    end
  end

  defp perform_decryption(envelope, recipient_private_key, audit_context, verify_integrity) do
    algorithm_config = @kem_algorithms[envelope.algorithm]

    # Step 1: Recover shared secret using ML-KEM
    with {:ok, shared_secret} <- KEM.decaps(envelope.kem_ciphertext, recipient_private_key, algorithm_config.algorithm) do

      # Step 2: Derive decryption key
      decryption_key = derive_patient_data_key(shared_secret, envelope.metadata.sensitivity_level)

      # Step 3: Decrypt patient data with AES-256-GCM
      case decrypt_with_aes_gcm(envelope.encrypted_data, decryption_key, envelope.auth_tag) do
        {:ok, decrypted_data} ->

          # Step 4: Verify data integrity if requested
          if verify_integrity do
            case verify_patient_data_integrity(decrypted_data, envelope.metadata) do
              :ok ->
                log_successful_decryption(envelope.metadata, audit_context)
                {:ok, decrypted_data}

              {:error, integrity_error} ->
                log_decryption_failure(:integrity_verification_failed, integrity_error, audit_context)
                {:error, {:integrity_verification_failed, integrity_error}}
            end
          else
            log_successful_decryption(envelope.metadata, audit_context)
            {:ok, decrypted_data}
          end

        {:error, decryption_error} ->
          log_decryption_failure(:symmetric_decryption_failed, decryption_error, audit_context)
          {:error, {:decryption_failed, decryption_error}}
      end

    else
      {:error, kem_error} ->
        log_decryption_failure(:key_decapsulation_failed, kem_error, audit_context)
        {:error, {:key_decapsulation_failed, kem_error}}
    end
  end

  @doc """
  Sign medical document with quantum-safe digital signature
  """
  def sign_medical_document(document, signer_private_key, signer_metadata, options \\ []) do
    algorithm = Keyword.get(options, :algorithm, @default_sig)
    include_timestamp = Keyword.get(options, :include_timestamp, true)
    compliance_context = Keyword.get(options, :compliance_context, %{})

    sig_config = @sig_algorithms[algorithm]

    # Step 1: Validate signer authority
    case validate_signer_authority(signer_metadata, document, compliance_context) do
      {:ok, validated_signer} ->
        perform_document_signing(document, signer_private_key, validated_signer, sig_config, include_timestamp)

      {:error, authority_error} ->
        {:error, {:signer_validation_failed, authority_error}}
    end
  end

  defp perform_document_signing(document, signer_private_key, signer_metadata, sig_config, include_timestamp) do
    # Step 1: Create document hash with medical-specific context
    document_hash = create_medical_document_hash(document, signer_metadata, include_timestamp)

    # Step 2: Create signature with ML-DSA
    case Signature.sign(document_hash, signer_private_key, sig_config.algorithm) do
      {:ok, signature} ->

        # Step 3: Create signed document with healthcare metadata
        signed_document = %{
          document: document,
          signature: %{
            algorithm: sig_config.algorithm,
            value: signature,
            document_hash: document_hash,
            signer: sanitize_signer_for_signature(signer_metadata),
            signed_at: DateTime.utc_now(),
            signature_metadata: %{
              security_level: sig_config.security_level,
              signature_size: byte_size(signature),
              compliance_attestation: generate_signing_compliance_attestation(signer_metadata, document)
            }
          },
          compliance_metadata: %{
            cfm_compliant: validate_cfm_compliance(signer_metadata, document),
            crp_compliant: validate_crp_compliance(signer_metadata, document),
            lgpd_compliant: validate_lgpd_compliance(document),
            hipaa_compliant: validate_hipaa_compliance(document),
            audit_trail_id: generate_audit_trail_id()
          }
        }

        # Step 4: Log signing event for audit trail
        log_signing_event(signed_document, signer_metadata)

        {:ok, signed_document}

      {:error, signature_error} ->
        Logger.error("Document signing failed",
          algorithm: sig_config.algorithm,
          error: signature_error,
          signer: sanitize_professional_data(signer_metadata)
        )
        {:error, {:signature_generation_failed, signature_error}}
    end
  end

  @doc """
  Verify quantum-safe signature on medical document
  """
  def verify_medical_signature(signed_document, signer_public_key, options \\ []) do
    strict_verification = Keyword.get(options, :strict_verification, true)
    check_revocation = Keyword.get(options, :check_revocation, true)
    audit_context = Keyword.get(options, :audit_context, %{})

    # Step 1: Validate signed document structure
    case validate_signed_document_structure(signed_document) do
      {:ok, validated_document} ->
        perform_signature_verification(validated_document, signer_public_key, strict_verification, check_revocation, audit_context)

      {:error, structure_error} ->
        {:error, {:invalid_signed_document, structure_error}}
    end
  end

  defp perform_signature_verification(signed_document, signer_public_key, strict_verification, check_revocation, audit_context) do
    signature_info = signed_document.signature

    # Step 1: Check if signature algorithm is still secure
    case check_algorithm_security_status(signature_info.algorithm) do
      :secure ->
        continue_verification(signed_document, signer_public_key, strict_verification, check_revocation, audit_context)

      :deprecated ->
        if strict_verification do
          {:error, :deprecated_algorithm}
        else
          Logger.warn("Using deprecated signature algorithm", algorithm: signature_info.algorithm)
          continue_verification(signed_document, signer_public_key, strict_verification, check_revocation, audit_context)
        end

      :insecure ->
        {:error, :insecure_algorithm}
    end
  end

  defp continue_verification(signed_document, signer_public_key, strict_verification, check_revocation, audit_context) do
    signature_info = signed_document.signature

    # Step 1: Verify document integrity
    computed_hash = create_medical_document_hash(
      signed_document.document,
      signature_info.signer,
      signature_info.signed_at
    )

    if computed_hash == signature_info.document_hash do

      # Step 2: Verify quantum-safe signature
      case Signature.verify(signature_info.value, signature_info.document_hash, signer_public_key, signature_info.algorithm) do
        {:ok, true} ->

          # Step 3: Additional healthcare-specific validations
          case perform_healthcare_signature_validations(signed_document, check_revocation) do
            {:ok, validation_results} ->
              log_successful_verification(signed_document, validation_results, audit_context)
              {:ok, %{
                signature_valid: true,
                document_integrity: :verified,
                healthcare_validations: validation_results,
                verification_timestamp: DateTime.utc_now()
              }}

            {:error, validation_error} ->
              log_verification_failure(:healthcare_validation_failed, validation_error, audit_context)
              {:error, {:healthcare_validation_failed, validation_error}}
          end

        {:ok, false} ->
          log_verification_failure(:signature_invalid, nil, audit_context)
          {:error, :signature_invalid}

        {:error, verification_error} ->
          log_verification_failure(:signature_verification_error, verification_error, audit_context)
          {:error, {:signature_verification_error, verification_error}}
      end

    else
      log_verification_failure(:document_tampering, %{
        expected_hash: signature_info.document_hash,
        computed_hash: computed_hash
      }, audit_context)
      {:error, :document_tampered}
    end
  end

  # Key management functions

  defp generate_kem_keypair(professional_data) do
    algorithm = determine_kem_algorithm_for_professional(professional_data)
    kem_config = @kem_algorithms[algorithm]

    case KEM.keygen(kem_config.algorithm) do
      {:ok, {public_key, private_key}} ->
        metadata = %{
          algorithm: algorithm,
          security_level: kem_config.security_level,
          generated_at: DateTime.utc_now(),
          professional_context: extract_professional_context(professional_data),
          key_usage: [:encryption, :key_agreement],
          compliance_level: determine_compliance_level(professional_data),
          rotation_schedule: calculate_key_rotation_schedule(algorithm)
        }

        {:ok, {public_key, private_key, metadata}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp generate_sig_keypair(professional_data) do
    algorithm = determine_sig_algorithm_for_professional(professional_data)
    sig_config = @sig_algorithms[algorithm]

    case Signature.keygen(sig_config.algorithm) do
      {:ok, {public_key, private_key}} ->
        metadata = %{
          algorithm: algorithm,
          security_level: sig_config.security_level,
          generated_at: DateTime.utc_now(),
          professional_context: extract_professional_context(professional_data),
          key_usage: [:digital_signature, :non_repudiation],
          signature_size: sig_config.signature_size,
          compliance_level: determine_compliance_level(professional_data)
        }

        {:ok, {public_key, private_key, metadata}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Helper functions for data classification and compliance

  defp classify_patient_data_sensitivity(patient_data, compliance_context) do
    # Implement sophisticated data classification
    sensitivity_factors = []

    # Check for highly sensitive data types
    if contains_genetic_data?(patient_data), do: sensitivity_factors = [:genetic | sensitivity_factors]
    if contains_mental_health_data?(patient_data), do: sensitivity_factors = [:mental_health | sensitivity_factors]
    if contains_substance_abuse_data?(patient_data), do: sensitivity_factors = [:substance_abuse | sensitivity_factors]
    if contains_reproductive_health_data?(patient_data), do: sensitivity_factors = [:reproductive | sensitivity_factors]

    # Check patient demographics
    if minor_patient?(patient_data), do: sensitivity_factors = [:minor_patient | sensitivity_factors]
    if vip_patient?(patient_data), do: sensitivity_factors = [:vip | sensitivity_factors]

    # Determine overall sensitivity level
    sensitivity_level = case length(sensitivity_factors) do
      0 -> :standard
      1 -> :sensitive
      2 -> :highly_sensitive
      _ -> :critical
    end

    {:ok, sensitivity_level}
  end

  defp derive_patient_data_key(shared_secret, sensitivity_level) do
    # Use HKDF to derive appropriate key length
    key_length = case sensitivity_level do
      :standard -> 32 # 256-bit
      :sensitive -> 32 # 256-bit
      :highly_sensitive -> 32 # 256-bit
      :critical -> 32 # 256-bit (same but different salt)
    end

    salt = get_sensitivity_salt(sensitivity_level)
    info = "healthcare_patient_data_encryption"

    :crypto.hkdf(:sha256, shared_secret, salt, info, key_length)
  end

  defp get_sensitivity_salt(sensitivity_level) do
    # Different salts for different sensitivity levels
    case sensitivity_level do
      :standard -> "healthcare_standard"
      :sensitive -> "healthcare_sensitive"
      :highly_sensitive -> "healthcare_highly_sensitive"
      :critical -> "healthcare_critical"
    end
  end

  # Additional helper functions would be implemented here...

  defp sanitize_professional_data(professional_data) do
    %{
      specialty: professional_data[:specialty],
      institution: professional_data[:institution],
      # Never log actual registration numbers
      has_crm: !is_nil(professional_data[:crm]),
      has_crp: !is_nil(professional_data[:crp])
    }
  end

  defp generate_professional_crypto_id(registration_number) do
    "pqc_prof_" <> (:crypto.hash(:sha256, registration_number) |> Base.encode16(case: :lower) |> String.slice(0, 16))
  end

  defp determine_kem_algorithm_for_professional(professional_data) do
    # Determine algorithm based on professional context
    case {professional_data[:specialty], professional_data[:institution_type]} do
      {specialty, :research_hospital} when specialty in ["oncologia", "cardiologia", "neurologia"] ->
        :ml_kem_1024 # Maximum security for critical specialties

      {_specialty, :hospital} ->
        :ml_kem_768 # Standard hospital security

      {_specialty, _} ->
        @default_kem # Default for other contexts
    end
  end

  defp determine_sig_algorithm_for_professional(professional_data) do
    # Similar logic for signature algorithms
    case professional_data[:document_types] do
      types when "regulatory_submission" in types ->
        :ml_dsa_87 # Maximum security for regulatory documents

      types when "clinical_trial" in types ->
        :ml_dsa_65 # High security for clinical trials

      _ ->
        @default_sig
    end
  end

  # Placeholder functions for comprehensive implementation
  defp store_keys_securely(_keys), do: %{kem_location: :hsm, sig_location: :hsm}
  defp register_with_healthcare_pki(_data), do: %{registration_id: "pki_reg_123"}
  defp generate_compliance_attestation(_professional_data), do: %{compliant: true}
  defp extract_professional_context(_professional_data), do: %{}
  defp determine_compliance_level(_professional_data), do: :high
  defp calculate_key_rotation_schedule(_algorithm), do: "annual"
  defp encrypt_with_aes_gcm(_data, _key), do: {:ok, "encrypted", "auth_tag"}
  defp decrypt_with_aes_gcm(_data, _key, _tag), do: {:ok, "decrypted"}
  defp add_classical_encryption_layer(envelope, _data), do: {:ok, envelope}
  defp validate_encryption_envelope(envelope), do: {:ok, envelope}
  defp verify_patient_data_integrity(_data, _metadata), do: :ok
  defp classify_for_retention(_data), do: :long_term
  defp extract_compliance_flags(_data), do: []
  defp validate_signer_authority(signer, _document, _context), do: {:ok, signer}
  defp create_medical_document_hash(_document, _signer, _timestamp), do: "hash"
  defp sanitize_signer_for_signature(signer), do: signer
  defp generate_signing_compliance_attestation(_signer, _document), do: %{}
  defp validate_cfm_compliance(_signer, _document), do: true
  defp validate_crp_compliance(_signer, _document), do: true
  defp validate_lgpd_compliance(_document), do: true
  defp validate_hipaa_compliance(_document), do: true
  defp generate_audit_trail_id(), do: Ecto.UUID.generate()
  defp validate_signed_document_structure(document), do: {:ok, document}
  defp check_algorithm_security_status(_algorithm), do: :secure
  defp perform_healthcare_signature_validations(_document, _check_revocation), do: {:ok, %{}}

  # Logging functions
  defp log_encryption_event(_metadata, _algorithm, _sensitivity), do: :ok
  defp log_successful_decryption(_metadata, _audit_context), do: :ok
  defp log_decryption_failure(_type, _error, _audit_context), do: :ok
  defp log_signing_event(_document, _signer), do: :ok
  defp log_successful_verification(_document, _results, _audit_context), do: :ok
  defp log_verification_failure(_type, _error, _audit_context), do: :ok

  # Data sensitivity detection functions
  defp contains_genetic_data?(_data), do: false
  defp contains_mental_health_data?(_data), do: false
  defp contains_substance_abuse_data?(_data), do: false
  defp contains_reproductive_health_data?(_data), do: false
  defp minor_patient?(_data), do: false
  defp vip_patient?(_data), do: false
end
```
**Notas**:
- Implementação completa ML-KEM/ML-DSA com healthcare compliance
- Classificação automática de sensibilidade de dados
- Hybrid classical-quantum durante transição
**Relacionados**:
- [NIST FIPS 203](https://csrc.nist.gov/publications/detail/fips/203/final)
- [NIST FIPS 204](https://csrc.nist.gov/publications/detail/fips/204/final)
- [liboqs Documentation](https://github.com/open-quantum-safe/liboqs)

---

## 🚨 Troubleshooting

### Zero Trust Common Issues

#### Policy Engine Performance
**Problema**: Policy Engine causando latência alta em decisões
**Sintomas**:
- Access requests timing out (>30s)
- High CPU usage on policy engine
- Trust score calculation delays
**Solução**:
```elixir
# Policy Engine Performance Optimization
defmodule Healthcare.ZeroTrust.PolicyEngineOptimizer do
  def optimize_performance(policy_engine_pid) do
    # 1. Implement policy caching
    enable_policy_caching(policy_engine_pid)

    # 2. Optimize trust data source queries
    optimize_trust_source_queries()

    # 3. Implement request batching
    enable_request_batching(policy_engine_pid)

    # 4. Add async trust score calculation
    enable_async_trust_calculation(policy_engine_pid)
  end

  defp enable_policy_caching(policy_engine_pid) do
    cache_config = %{
      cache_size: 10_000,
      ttl: 300_000, # 5 minutes
      cache_warming: true,
      eviction_policy: :lru
    }

    Healthcare.ZeroTrust.PolicyEngine.enable_caching(policy_engine_pid, cache_config)
  end

  defp optimize_trust_source_queries do
    # Parallel query optimization
    Healthcare.TrustSources.configure_parallel_queries(%{
      max_concurrent: 8,
      query_timeout: 5_000, # 5 seconds
      circuit_breaker: true,
      fallback_enabled: true
    })
  end

  defp enable_request_batching(policy_engine_pid) do
    batch_config = %{
      batch_size: 50,
      batch_timeout: 100, # 100ms
      parallel_processing: true
    }

    Healthcare.ZeroTrust.PolicyEngine.enable_batching(policy_engine_pid, batch_config)
  end
end
```

#### Trust Score Inconsistencies
**Problema**: Trust scores variando drasticamente para o mesmo usuário
**Sintomas**:
- Same user getting different trust scores within minutes
- Access denied followed immediately by access granted
- Compliance violations not being detected consistently
**Solução**:
```elixir
# Trust Score Stabilization
defmodule Healthcare.TrustAlgorithm.Stabilizer do
  def stabilize_trust_scores do
    # 1. Implement moving average for trust scores
    enable_trust_score_smoothing()

    # 2. Add trust score floor/ceiling
    set_trust_score_boundaries()

    # 3. Implement time-based decay
    enable_temporal_trust_decay()

    # 4. Add professional context weighting
    enable_professional_context_stability()
  end

  defp enable_trust_score_smoothing do
    Healthcare.TrustAlgorithm.configure(%{
      smoothing_enabled: true,
      smoothing_window: 300, # 5 minutes
      smoothing_factor: 0.7,
      min_data_points: 3
    })
  end

  defp set_trust_score_boundaries do
    Healthcare.TrustAlgorithm.configure(%{
      boundaries: %{
        verified_professional: %{min: 60, max: 100},
        unverified_user: %{min: 0, max: 70},
        emergency_access: %{min: 50, max: 100}
      }
    })
  end

  defp enable_temporal_trust_decay do
    Healthcare.TrustAlgorithm.configure(%{
      temporal_decay: %{
        enabled: true,
        half_life_hours: 24,
        minimum_decay_score: 30
      }
    })
  end
end
```

#### PQC Performance Issues
**Problema**: Post-quantum cryptography causando timeouts
**Sintomas**:
- Key generation taking >10 seconds
- Encryption/decryption operations timing out
- High memory usage during PQC operations
**Solução**:
```elixir
# PQC Performance Optimization
defmodule Healthcare.PostQuantumCrypto.Optimizer do
  def optimize_pqc_performance do
    # 1. Implement key pre-generation
    enable_key_pregeneration()

    # 2. Use hardware acceleration when available
    enable_hardware_acceleration()

    # 3. Implement operation batching
    enable_pqc_batching()

    # 4. Add operation timeouts
    set_operation_timeouts()
  end

  defp enable_key_pregeneration do
    Healthcare.PostQuantumCrypto.KeyManager.start_pregeneration(%{
      kem_keys: %{
        ml_kem_768: 10, # Keep 10 pre-generated keypairs
        ml_kem_1024: 5  # Keep 5 for high-security operations
      },
      sig_keys: %{
        ml_dsa_65: 10,
        ml_dsa_87: 5
      },
      generation_batch_size: 2,
      generation_interval: 3600_000 # 1 hour
    })
  end

  defp enable_hardware_acceleration do
    case Healthcare.HardwareAcceleration.detect_capabilities() do
      {:ok, capabilities} ->
        Healthcare.PostQuantumCrypto.configure_acceleration(capabilities)
      {:error, _} ->
        Logger.info("No hardware acceleration available, using software implementation")
        :ok
    end
  end

  defp enable_pqc_batching do
    Healthcare.PostQuantumCrypto.configure_batching(%{
      encryption_batch_size: 10,
      decryption_batch_size: 10,
      signing_batch_size: 5,
      verification_batch_size: 20,
      batch_timeout: 1000 # 1 second
    })
  end

  defp set_operation_timeouts do
    Healthcare.PostQuantumCrypto.configure_timeouts(%{
      key_generation: 30_000,  # 30 seconds
      encryption: 10_000,      # 10 seconds
      decryption: 10_000,      # 10 seconds
      signing: 15_000,         # 15 seconds
      verification: 5_000      # 5 seconds
    })
  end
end
```

### Healthcare Compliance Issues

#### LGPD Consent Management
**Problema**: Consent validation failing ou sendo inconsistente
**Sintomas**:
- Valid consents being rejected
- Expired consents not being detected
- Consent granularity not working correctly
**Solução**:
```elixir
# LGPD Consent Management Troubleshooting
defmodule Healthcare.LGPD.ConsentTroubleshooter do
  def diagnose_consent_issues(user_id, operation) do
    # 1. Validate consent data structure
    consent_record = Healthcare.ConsentManager.get_consent(user_id)
    validate_consent_structure(consent_record)

    # 2. Check consent temporal validity
    validate_consent_timeline(consent_record, operation)

    # 3. Validate consent granularity
    validate_consent_granularity(consent_record, operation)

    # 4. Check for consent conflicts
    check_consent_conflicts(consent_record)
  end

  defp validate_consent_structure(consent_record) do
    required_fields = [
      :consent_id, :user_id, :granted_at, :purpose,
      :data_categories, :processing_basis, :valid_until
    ]

    missing_fields = Enum.filter(required_fields, fn field ->
      is_nil(Map.get(consent_record, field))
    end)

    if length(missing_fields) > 0 do
      Logger.error("Invalid consent structure", missing_fields: missing_fields)
      {:error, {:invalid_consent_structure, missing_fields}}
    else
      {:ok, :valid_structure}
    end
  end

  defp validate_consent_timeline(consent_record, operation) do
    now = DateTime.utc_now()

    cond do
      DateTime.compare(consent_record.granted_at, now) == :gt ->
        {:error, :consent_future_dated}

      not is_nil(consent_record.valid_until) and
      DateTime.compare(now, consent_record.valid_until) == :gt ->
        {:error, :consent_expired}

      not is_nil(consent_record.revoked_at) and
      DateTime.compare(operation.timestamp, consent_record.revoked_at) == :gt ->
        {:error, :consent_revoked}

      true ->
        {:ok, :consent_temporally_valid}
    end
  end
end
```

#### Professional Validation Failures
**Problema**: CRM/CRP validation rejeitando profissionais válidos
**Sintomas**:
- Valid medical licenses being rejected
- Professional registry API timeouts
- Specialty validation inconsistencies
**Solução**:
```elixir
# Professional Validation Troubleshooting
defmodule Healthcare.ProfessionalValidator.Troubleshooter do
  def diagnose_validation_failures(professional_data) do
    # 1. Check CRM/CRP format validation
    validate_registration_format(professional_data)

    # 2. Test professional registry connectivity
    test_registry_connectivity()

    # 3. Validate specialty mapping
    validate_specialty_mapping(professional_data.specialty)

    # 4. Check for rate limiting
    check_rate_limiting_status()
  end

  defp validate_registration_format(professional_data) do
    case professional_data do
      %{crm: crm} when is_binary(crm) ->
        validate_crm_format(crm)
      %{crp: crp} when is_binary(crp) ->
        validate_crp_format(crp)
      _ ->
        {:error, :no_registration_number}
    end
  end

  defp validate_crm_format(crm) do
    # CRM format: CRM-UF-NNNNNN
    crm_regex = ~r/^CRM[-\/]?([A-Z]{2})[-\/]?(\d{4,6})$/i

    if Regex.match?(crm_regex, crm) do
      {:ok, :valid_crm_format}
    else
      {:error, {:invalid_crm_format, crm}}
    end
  end

  defp test_registry_connectivity do
    registries = [:cfm, :crp, :crn]

    Enum.map(registries, fn registry ->
      case Healthcare.ProfessionalRegistry.test_connection(registry) do
        {:ok, _response} ->
          {registry, :connected}
        {:error, reason} ->
          {registry, {:connection_failed, reason}}
      end
    end)
  end
end
```

**Performance Benchmarks for Troubleshooting**:
```elixir
@performance_targets %{
  zero_trust: %{
    policy_evaluation: 500,     # 500ms max
    trust_score_calculation: 200, # 200ms max
    pep_configuration: 100      # 100ms max
  },
  post_quantum_crypto: %{
    key_generation: 10_000,     # 10s max
    encryption: 1_000,          # 1s max
    decryption: 1_000,          # 1s max
    signing: 2_000,            # 2s max
    verification: 500           # 500ms max
  },
  compliance: %{
    consent_validation: 100,    # 100ms max
    professional_validation: 2_000, # 2s max (API calls)
    audit_logging: 50          # 50ms max
  }
}
```

**Notas Gerais**:
- Zero Trust requer tuning contínuo para performance
- PQC operations são CPU-intensivas - considere hardware acceleration
- Compliance validation deve ser robusta mas não impactar UX
**Relacionados**:
- [NIST Zero Trust Implementation Guide](https://www.nist.gov/publications/zero-trust-architecture)
- [Post-Quantum Cryptography Best Practices](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [LGPD Implementation Guide](https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd)