# DSM:PLATFORM:production_config HEALTHCARE:enterprise_ready
# DSM:SECURITY:zero_trust_production COMPLIANCE:LGPD_ANVISA_CFM
import Config

# Production database configuration com SSL
config :healthcare_cms, HealthcareCMS.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true,
  ssl_opts: [
    verify: :verify_peer,
    cacerts: :public_key.cacerts_get(),
    server_name_indication: :disable,
    customize_hostname_check: [
      match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    ]
  ]

# Production endpoint configuration
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  # HTTPS obrigatório para healthcare compliance
  https: [
    port: String.to_integer(System.get_env("PORT") || "443"),
    cipher_suite: :strong,
    otp_app: :healthcare_cms,
    keyfile: System.get_env("SSL_KEY_PATH"),
    certfile: System.get_env("SSL_CERT_PATH"),
    cacertfile: System.get_env("SSL_CA_PATH")
  ],
  # Security headers para healthcare compliance
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  check_origin: [
    "https://healthcare-cms.com",
    "https://app.healthcare-cms.com"
  ]

# Production logging com audit trail
config :logger,
  level: :info,
  backends: [{LoggerFileBackend, :info_log}, {LoggerFileBackend, :error_log}]

config :logger, :info_log,
  path: "/var/log/healthcare_cms/info.log",
  level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id, :tenant_id, :medical_context, :compliance_data]

config :logger, :error_log,
  path: "/var/log/healthcare_cms/error.log",
  level: :error

# Guardian production configuration
config :guardian, Guardian,
  secret_key: {System, :get_env, ["GUARDIAN_SECRET_KEY"]},
  ttl: {8, :hours},  # Shorter TTL para healthcare security
  verify_issuer: true,
  verify_module: Guardian.JWT

# Zero Trust production settings
config :healthcare_cms, :zero_trust,
  policy_engine: HealthcareCMS.Security.PolicyEngine,
  default_deny: true,
  trust_score_threshold: 80,  # Higher threshold em produção
  enable_geo_blocking: true,
  audit_all_decisions: true,
  threat_detection: true

# Medical workflow production settings
config :healthcare_cms, :medical_workflows,
  s11_lgpd_analyzer: [
    enabled: true,
    risk_threshold: 60,  # More restrictive em produção
    auto_generate_forms: true,
    audit_all_analysis: true
  ],
  s12_claims_extractor: [
    enabled: true,
    cfm_validation: true,
    evidence_required: true,
    professional_validation: :mandatory
  ],
  production_mode: true,
  mock_external_apis: false

# Observability production configuration
config :healthcare_cms, :telemetry,
  prometheus_enabled: true,
  grafana_integration: true,
  alert_manager: true,
  healthcare_metrics: true

# Multi-tenant production settings
config :healthcare_cms, :multi_tenant,
  admin_blind_enabled: true,
  tenant_isolation: :strict,
  encryption_at_rest: true,
  key_rotation_interval: 86400  # 24 hours

# Production security headers
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  extra_headers: [
    {"X-Frame-Options", "DENY"},
    {"X-Content-Type-Options", "nosniff"},
    {"X-XSS-Protection", "1; mode=block"},
    {"Strict-Transport-Security", "max-age=31536000; includeSubDomains"},
    {"Content-Security-Policy", "default-src 'self'"},
    {"Referrer-Policy", "strict-origin-when-cross-origin"},
    {"Permissions-Policy", "geolocation=(), microphone=(), camera=()"}
  ]