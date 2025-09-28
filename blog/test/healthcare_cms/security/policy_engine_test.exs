# DSM:TESTING:policy_engine_validation HEALTHCARE:zero_trust_testing
# DSM:COMPLIANCE:audit_trail_validation SECURITY:trust_algorithm_testing
defmodule HealthcareCMS.Security.PolicyEngineTest do
  use ExUnit.Case, async: false

  alias HealthcareCMS.Security.{PolicyEngine, TrustAlgorithm}

  @moduletag :zero_trust

  setup do
    # PolicyEngine já está iniciado na aplicação supervisor
    # Apenas garantir que está funcionando
    case GenServer.whereis(PolicyEngine) do
      nil -> start_supervised!(PolicyEngine)
      _pid -> :ok
    end
    :ok
  end

  describe "trust algorithm" do
    test "calculates basic trust score correctly" do
      subject = %{
        id: "user-123",
        tenant_id: "tenant-1",
        auth_method: :mfa_enabled,
        professional_data: %{validated: true, type: :crm, active: true}
      }

      context = %{
        device_info: %{trusted: true, managed: true},
        location: %{healthcare_facility: true}
      }

      trust_score = TrustAlgorithm.calculate(subject, context)

      # Base (50) + MFA (25) + Professional (20) + Device (15) + Location (10) = 120 -> capped at 100
      assert trust_score == 100
    end

    test "penalizes suspicious activity" do
      subject = %{
        auth_method: :password_only,
        recent_activity: %{anomalous: true}
      }

      context = %{
        device_info: %{unknown: true},
        location: %{suspicious: true}
      }

      trust_score = TrustAlgorithm.calculate(subject, context)

      # Base (50) + Password (-10) + Anomalous (-15) + Unknown device (-15) + Suspicious location (-20) = -10 -> capped at 0
      assert trust_score == 0
    end
  end

  describe "policy engine access evaluation" do
    test "allows access for high trust medical professional" do
      subject = %{
        id: "doctor-123",
        tenant_id: "hospital-1",
        auth_method: :mfa_enabled,
        professional_data: %{validated: true, type: :crm, active: true, no_violations: true}
      }

      resource = %{
        id: "patient-record-456",
        contains_phi: false,
        admin_function: false,
        public_content: true
      }

      context = %{
        device_info: %{trusted: true, managed: true},
        location: %{healthcare_facility: true},
        time_info: %{business_hours: true}
      }

      assert {:allow, access_level} = PolicyEngine.evaluate_access_request(subject, resource, context)
      assert access_level in [:full_access, :limited_access]
    end

    test "denies access for non-compliant requests" do
      subject = %{
        id: "user-123",
        tenant_id: "tenant-1",
        auth_method: :password_only
      }

      resource = %{
        id: "admin-function",
        contains_phi: true,
        admin_function: true
      }

      context = %{
        device_info: %{unknown: true},
        location: %{suspicious: true}
      }

      assert {:deny, reason} = PolicyEngine.evaluate_access_request(subject, resource, context)
      assert reason in [:insufficient_trust, :policy_violation, :compliance_violation]
    end

    test "applies emergency access protocols" do
      subject = %{
        id: "doctor-emergency",
        tenant_id: "hospital-1",
        auth_method: :mfa_enabled,
        professional_data: %{validated: true, type: :crm, active: true}
      }

      resource = %{
        id: "critical-patient-data",
        contains_phi: true,
        urgency: :emergency
      }

      context = %{
        device_info: %{trusted: true},
        location: %{healthcare_facility: true},
        emergency_context: %{declared: true, verified: true, level: :critical},
        clinical_context: %{justified: true}
      }

      assert {:allow, access_level} = PolicyEngine.evaluate_access_request(subject, resource, context)
      assert access_level in [:full_access, :supervised_access]
    end
  end

  describe "healthcare context validation" do
    test "validates medical professional scope" do
      subject = %{
        professional_data: %{
          specialty: "cardiologia",
          assigned_patients: ["patient-1", "patient-2"]
        }
      }

      resource = %{
        patient_id: "patient-1",
        required_specialty: "cardiologia"
      }

      context = %{
        clinical_context: %{justified: true}
      }

      medical_score = TrustAlgorithm.calculate_medical_context_score(subject, resource, context)

      # Should have bonus for patient relationship and specialty match
      base_score = TrustAlgorithm.calculate(subject, context)
      assert medical_score > base_score
    end
  end

  describe "policy caching and refresh" do
    test "refreshes policy cache" do
      assert :ok = PolicyEngine.refresh_policy_cache()
    end

    test "gets tenant policies" do
      policies = PolicyEngine.get_tenant_policies("tenant-1")
      assert is_list(policies)
    end
  end
end