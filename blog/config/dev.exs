# DSM:PLATFORM:development_config HEALTHCARE:dev_environment
import Config

# Database configuration para desenvolvimento (SQLite)
config :healthcare_cms, HealthcareCMS.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "priv/healthcare_cms_dev.db",
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Phoenix endpoint para desenvolvimento
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "healthcare_dev_secret_key_base_change_in_production",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:healthcare_cms, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:healthcare_cms, ~w(--watch)]}
  ]

# LiveView configuration para desenvolvimento
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/healthcare_cms_web/(controllers|live|components)/.*(ex|heex)$",
      ~r"lib/healthcare_cms_web/templates/.*(eex)$"
    ]
  ]

# Guardian development configuration
config :guardian, Guardian,
  secret_key: "healthcare_dev_guardian_secret"

# Email configuration (temporariamente desabilitado)
# config :swoosh, :api_client, false

# Development logging
config :logger, :console, format: "[$level] $message\n"

# Phoenix stack trace configuration
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments
config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true

# Medical workflow development settings
config :healthcare_cms, :medical_workflows,
  s11_lgpd_analyzer: [
    enabled: true,
    debug_mode: true,
    log_analysis_steps: true
  ],
  development_mode: true,
  mock_external_apis: true