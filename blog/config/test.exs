# DSM:PLATFORM:test_config HEALTHCARE:testing_environment
import Config

# Test database configuration (SQLite)
config :healthcare_cms, HealthcareCMS.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "priv/healthcare_cms_test.db",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1

# Test endpoint configuration
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "healthcare_test_secret_key_base",
  server: false

# Guardian test configuration
config :guardian, Guardian,
  secret_key: "healthcare_test_guardian_secret"

# Test logging (reduced verbosity)
config :logger, level: :warning

# Argon2 test configuration (faster hashing)
config :argon2_elixir, t_cost: 1, m_cost: 8

# Medical workflow test settings
config :healthcare_cms, :medical_workflows,
  s11_lgpd_analyzer: [
    enabled: true,
    debug_mode: true,
    mock_analysis: true
  ],
  s12_claims_extractor: [
    enabled: true,
    mock_cfm_validation: true
  ],
  test_mode: true,
  mock_external_apis: true

# Zero Trust test configuration
config :healthcare_cms, :zero_trust,
  policy_engine: HealthcareCMS.Security.MockPolicyEngine,
  default_deny: false,  # More permissive para testes
  trust_score_threshold: 50,
  audit_all_decisions: false

# Phoenix test configuration
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view, enable_expensive_runtime_checks: true