# DSM:PLATFORM:configuration|base_setup HEALTHCARE:compliance_ready
# DSM:SECURITY:zero_trust_foundation PERFORMANCE:<50ms_target

import Config

# Configuração base da aplicação
config :healthcare_cms,
  ecto_repos: [HealthcareCMS.Repo],
  generators: [timestamp_type: :utc_datetime]

# Phoenix Framework configuration
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: HealthcareCMSWeb.ErrorHTML, json: HealthcareCMSWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: HealthcareCMS.PubSub,
  live_view: [signing_salt: "healthcare_secret"]

# Configuração de logging para compliance
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id, :tenant_id, :medical_context]

# Phoenix LiveView configuration
config :phoenix, :json_library, Jason

# Guardian authentication para Zero Trust
config :guardian, Guardian,
  issuer: "HealthcareCMS",
  ttl: {1, :day},
  secret_key: "healthcare_guardian_secret_key_to_be_replaced"

# Extism WebAssembly configuration (temporariamente desabilitado)
# config :extism,
#   default_timeout: 30_000,
#   max_memory: 64 * 1024 * 1024,  # 64MB limit per plugin
#   allowed_hosts: [
#     "api.anvisa.gov.br",
#     "portal.cfm.org.br",
#     "pubmed.ncbi.nlm.nih.gov",
#     "www.scielo.br"
#   ]

# Oban background jobs (temporariamente desabilitado)
# config :healthcare_cms, Oban,
#   repo: HealthcareCMS.Repo,
#   plugins: [
#     Oban.Plugins.Pruner,
#     {Oban.Plugins.Cron,
#      crontab: [
#        {"0 2 * * *", HealthcareCMS.Workers.ComplianceAudit},
#        {"*/15 * * * *", HealthcareCMS.Workers.HealthCheck}
#      ]}
#   ],
#   queues: [
#     medical_workflow: 10,
#     lgpd_analysis: 5,
#     compliance_check: 3,
#     audit_trail: 2
#   ]

# Prometheus monitoring
config :prometheus, HealthcareCMS.PrometheusExporter,
  path: "/metrics",
  format: :text,
  registry: :default,
  auth: false

# Healthcare-specific configurations
config :healthcare_cms, :medical_workflows,
  s11_lgpd_analyzer: [
    enabled: true,
    risk_threshold: 70,
    auto_generate_forms: true
  ],
  s12_claims_extractor: [
    enabled: true,
    cfm_validation: true,
    evidence_required: true
  ],
  s212_research_engine: [
    enabled: true,
    max_references: 20,
    quality_threshold: 0.8
  ]

# Zero Trust Policy Engine configuration
config :healthcare_cms, :zero_trust,
  policy_engine: HealthcareCMS.Security.PolicyEngine,
  default_deny: true,
  trust_score_threshold: 60,
  medical_professional_bonus: 20,
  audit_all_decisions: true

# Import environment specific config
import_config "#{config_env()}.exs"