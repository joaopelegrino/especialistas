# DSM:SECURITY:trust_algorithm HEALTHCARE:medical_professional_scoring
# DSM:PERFORMANCE:response_time:<50ms NIST:SP_800_207_compliant
defmodule HealthcareCMS.Security.TrustAlgorithm do
  @moduledoc """
  Trust Algorithm para Zero Trust Architecture Healthcare

  Implementa algoritmo de confiança contextual específico para healthcare,
  considerando fatores médicos profissionais e compliance regulamentário.

  Baseado em NIST SP 800-207 com extensões para healthcare brasileiro:
  - CRM/CRP validation
  - Medical facility context
  - Patient data access patterns
  - Emergency access protocols
  """

  @base_trust_score 50
  @max_trust_score 100
  @min_trust_score 0

  # Authentication factors
  @mfa_bonus 25
  @certificate_bonus 30
  @password_penalty -10
  @api_key_bonus 10

  # Device factors
  @managed_device_bonus 15
  @trusted_device_bonus 10
  @unknown_device_penalty -15

  # Location factors
  @healthcare_facility_bonus 10
  @office_network_bonus 5
  @vpn_bonus 5
  @suspicious_location_penalty -20

  # Behavioral factors
  @anomalous_behavior_penalty -15
  @consistent_behavior_bonus 10
  @first_time_penalty -5

  # Medical professional factors
  @validated_medical_professional_bonus 20
  @pending_validation_bonus 5

  @doc """
  Calcula trust score baseado em subject e context

  ## Fatores considerados:
  - Método de autenticação (MFA, certificados, etc.)
  - Informações do dispositivo (gerenciado, confiável)
  - Localização (facility médica, VPN, etc.)
  - Padrões comportamentais históricos
  - Credenciais médicas profissionais

  ## Retorno:
  Integer entre 0-100 representando nível de confiança
  """
  def calculate(subject, context) do
    @base_trust_score
    |> add_authentication_score(subject[:auth_method], subject[:auth_factors])
    |> add_device_score(context[:device_info])
    |> add_location_score(context[:location])
    |> add_behavioral_score(subject[:recent_activity])
    |> add_medical_professional_score(subject[:professional_data])
    |> add_time_context_score(context[:time_info])
    |> add_emergency_context_score(context[:emergency_context])
    |> ensure_valid_range()
  end

  @doc """
  Calcula score específico para contexto médico

  Considera fatores específicos para acesso a dados de pacientes
  e workflows médicos.
  """
  def calculate_medical_context_score(subject, resource, context) do
    base_score = calculate(subject, context)

    base_score
    |> add_patient_relationship_score(subject, resource)
    |> add_medical_necessity_score(resource, context)
    |> add_specialty_match_score(subject, resource)
    |> add_emergency_override_score(context)
    |> ensure_valid_range()
  end

  # Private functions

  defp add_authentication_score(score, auth_method, auth_factors \\ []) do
    method_score = case auth_method do
      :mfa_enabled -> @mfa_bonus
      :certificate_based -> @certificate_bonus
      :password_only -> @password_penalty
      :api_key -> @api_key_bonus
      :sso -> 15
      _ -> 0
    end

    factor_bonus = calculate_auth_factor_bonus(auth_factors)

    score + method_score + factor_bonus
  end

  defp calculate_auth_factor_bonus(factors) when is_list(factors) do
    Enum.reduce(factors, 0, fn factor, acc ->
      case factor do
        :hardware_token -> acc + 10
        :biometric -> acc + 15
        :smart_card -> acc + 12
        :sms_code -> acc + 3
        :app_code -> acc + 5
        _ -> acc
      end
    end)
  end
  defp calculate_auth_factor_bonus(_), do: 0

  defp add_device_score(score, device_info) when is_map(device_info) do
    bonus = case device_info do
      %{managed: true, trusted: true, health_check: :passed} -> @managed_device_bonus + 5
      %{managed: true, trusted: true} -> @managed_device_bonus
      %{trusted: true} -> @trusted_device_bonus
      %{managed: true} -> 8
      %{unknown: true} -> @unknown_device_penalty
      %{compromised: true} -> -30
      _ -> 0
    end

    score + bonus
  end
  defp add_device_score(score, _), do: score

  defp add_location_score(score, location) when is_map(location) do
    bonus = case location do
      %{healthcare_facility: true, verified: true} -> @healthcare_facility_bonus + 5
      %{healthcare_facility: true} -> @healthcare_facility_bonus
      %{office_network: true} -> @office_network_bonus
      %{vpn: true, corporate: true} -> @vpn_bonus + 3
      %{vpn: true} -> @vpn_bonus
      %{suspicious: true} -> @suspicious_location_penalty
      %{international: true, unexpected: true} -> -10
      _ -> 0
    end

    score + bonus
  end
  defp add_location_score(score, _), do: score

  defp add_behavioral_score(score, recent_activity) when is_map(recent_activity) do
    bonus = case recent_activity do
      %{anomalous: true, severity: :high} -> @anomalous_behavior_penalty - 10
      %{anomalous: true} -> @anomalous_behavior_penalty
      %{consistent: true, long_history: true} -> @consistent_behavior_bonus + 5
      %{consistent: true} -> @consistent_behavior_bonus
      %{first_time: true, verified_identity: true} -> @first_time_penalty + 3
      %{first_time: true} -> @first_time_penalty
      %{recent_violations: true} -> -25
      _ -> 0
    end

    score + bonus
  end
  defp add_behavioral_score(score, _), do: score

  defp add_medical_professional_score(score, professional_data) when is_map(professional_data) do
    bonus = case professional_data do
      %{validated: true, type: :crm, active: true, no_violations: true} ->
        @validated_medical_professional_bonus + 5

      %{validated: true, type: :crm, active: true} ->
        @validated_medical_professional_bonus

      %{validated: true, type: :crp, active: true} ->
        @validated_medical_professional_bonus

      %{validated: true, type: :other_health_professional} ->
        @validated_medical_professional_bonus - 5

      %{pending_validation: true} ->
        @pending_validation_bonus

      %{expired_license: true} ->
        -15

      %{violations: violations} when length(violations) > 0 ->
        -20

      _ -> 0
    end

    score + bonus
  end
  defp add_medical_professional_score(score, _), do: score

  defp add_time_context_score(score, time_info) when is_map(time_info) do
    bonus = case time_info do
      %{business_hours: true} -> 5
      %{after_hours: true, authorized: true} -> 0
      %{after_hours: true, emergency: true} -> 3
      %{after_hours: true} -> -5
      %{weekend: true, emergency: true} -> 0
      %{weekend: true} -> -3
      _ -> 0
    end

    score + bonus
  end
  defp add_time_context_score(score, _), do: score

  defp add_emergency_context_score(score, emergency_context) when is_map(emergency_context) do
    bonus = case emergency_context do
      %{declared: true, verified: true, level: :critical} -> 15
      %{declared: true, verified: true} -> 10
      %{declared: true, pending_verification: true} -> 5
      %{suspected_false: true} -> -20
      _ -> 0
    end

    score + bonus
  end
  defp add_emergency_context_score(score, _), do: score

  # Medical-specific scoring functions

  defp add_patient_relationship_score(score, subject, resource) do
    case {subject[:professional_data], resource} do
      {%{assigned_patients: patients}, %{patient_id: patient_id}} when is_list(patients) ->
        if patient_id in patients, do: score + 10, else: score - 5

      {%{department: dept}, %{department: dept}} ->
        score + 5

      _ -> score
    end
  end

  defp add_medical_necessity_score(score, resource, context) do
    case {resource[:urgency], context[:clinical_context]} do
      {:emergency, _} -> score + 15
      {:urgent, %{justified: true}} -> score + 10
      {:routine, %{scheduled: true}} -> score + 5
      {:routine, %{unscheduled: true}} -> score - 3
      _ -> score
    end
  end

  defp add_specialty_match_score(score, subject, resource) do
    subject_specialty = subject[:professional_data][:specialty]
    resource_specialty = resource[:required_specialty]

    case {subject_specialty, resource_specialty} do
      {specialty, specialty} when not is_nil(specialty) -> score + 8
      {subject_spec, resource_spec} when not is_nil(subject_spec) and not is_nil(resource_spec) ->
        if related_specialties?(subject_spec, resource_spec), do: score + 3, else: score - 3
      _ -> score
    end
  end

  defp add_emergency_override_score(score, context) do
    case context[:emergency_override] do
      %{active: true, verified_by: verifier, level: level} when not is_nil(verifier) ->
        case level do
          :critical -> score + 25
          :high -> score + 20
          :medium -> score + 15
          _ -> score + 10
        end
      _ -> score
    end
  end

  defp related_specialties?(spec1, spec2) do
    # Simplified relationship checking
    # In production, this would use a comprehensive specialty relationship matrix
    related_pairs = [
      {"cardiologia", "cirurgia_cardiovascular"},
      {"pediatria", "neonatologia"},
      {"neurologia", "neurocirurgia"},
      {"oncologia", "hematologia"}
    ]

    Enum.any?(related_pairs, fn {s1, s2} ->
      (spec1 == s1 and spec2 == s2) or (spec1 == s2 and spec2 == s1)
    end)
  end

  defp ensure_valid_range(score) when score > @max_trust_score, do: @max_trust_score
  defp ensure_valid_range(score) when score < @min_trust_score, do: @min_trust_score
  defp ensure_valid_range(score), do: score
end