# Configuration Management - Healthcare CMS Blog

**DSM**: `L1_DOMAIN:infrastructure` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:configuration`
**Layer**: 2 (Core) - Environment Configuration & Secrets
**Status**: ✅ Production (Sprint 0-1)
**Read Time**: ~10 minutes
**Codebase Evidence**: `config/config.exs`, `config/runtime.exs`, `config/prod.exs`

---

## Overview

Healthcare CMS uses **Elixir's Config** system with runtime configuration for secure, environment-specific settings. All sensitive data (secrets, API keys) are managed via environment variables with LGPD/HIPAA compliance.

**Key Features**:
- **Compile-time config**: `config/config.exs`, `config/dev.exs`, `config/test.exs`, `config/prod.exs`
- **Runtime config**: `config/runtime.exs` (loaded at application start)
- **Environment variables**: Secure secret management
- **Multi-environment support**: dev, test, prod
- **Healthcare compliance**: Audit logging, encryption, data retention

---

## Configuration File Structure

```
config/
├── config.exs          # Base configuration (compile-time)
├── dev.exs             # Development environment
├── test.exs            # Test environment
├── prod.exs            # Production environment (rarely used)
└── runtime.exs         # Runtime configuration (preferred for secrets)
```

---

## Base Configuration (config/config.exs)

From `config/config.exs`:

```elixir
import Config

# Application configuration
config :healthcare_cms,
  ecto_repos: [HealthcareCMS.Repo],
  generators: [timestamp_type: :utc_datetime]

# Phoenix Framework
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: HealthcareCMSWeb.ErrorHTML, json: HealthcareCMSWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: HealthcareCMS.PubSub,
  live_view: [signing_salt: "healthcare_secret"]

# Logging configuration (LGPD compliance)
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id, :tenant_id, :medical_context]

# Phoenix JSON library
config :phoenix, :json_library, Jason

# Guardian authentication (Zero Trust)
config :guardian, Guardian,
  issuer: "HealthcareCMS",
  ttl: {1, :day},
  secret_key: "healthcare_guardian_secret_key_to_be_replaced"

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
    evidence_level_threshold: 3,
    auto_cite_pubmed: true
  ]

# Import environment-specific config
import_config "#{config_env()}.exs"
```

---

## Development Configuration (config/dev.exs)

```elixir
import Config

# Database (SQLite for development)
config :healthcare_cms, HealthcareCMS.Repo,
  database: Path.expand("../healthcare_cms_dev.db", __DIR__),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Endpoint (dev server)
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_at_least_64_bytes_long",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:healthcare_cms, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:healthcare_cms, ~w(--watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/healthcare_cms_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Logging
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

# Development routes (LiveDashboard)
config :healthcare_cms, dev_routes: true

# Guardian (dev secret)
config :healthcare_cms, HealthcareCMS.Guardian,
  secret_key: "dev_guardian_secret_key_replace_in_production_at_least_64_bytes_long"
```

---

## Test Configuration (config/test.exs)

```elixir
import Config

# Database (in-memory SQLite for tests)
config :healthcare_cms, HealthcareCMS.Repo,
  database: ":memory:",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Endpoint (test server)
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_at_least_64_bytes_long",
  server: false

# Logging
config :logger, level: :warning

# Password hashing (fast for tests)
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

# Guardian (test secret)
config :healthcare_cms, HealthcareCMS.Guardian,
  secret_key: "test_guardian_secret_key_at_least_64_bytes_long",
  ttl: {1, :hour}
```

---

## Production Configuration (config/prod.exs)

```elixir
import Config

# Production endpoint configuration
config :healthcare_cms, HealthcareCMSWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

# Logging (production level)
config :logger, level: :info

# Note: Secrets are loaded from runtime.exs using environment variables
```

---

## Runtime Configuration (config/runtime.exs) ⭐

**IMPORTANT**: This is where production secrets are loaded from environment variables.

```elixir
import Config

# Runtime configuration (loaded at application start)
# All secrets come from environment variables in production

if config_env() == :prod do
  # Database configuration from environment
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      Environment variable DATABASE_URL is missing.
      Example: ecto://USER:PASS@HOST/DATABASE
      """

  config :healthcare_cms, HealthcareCMS.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl: true,
    ssl_opts: [
      verify: :verify_peer,
      cacertfile: System.get_env("DATABASE_CA_CERT_PATH")
    ]

  # Endpoint configuration (production)
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      Environment variable SECRET_KEY_BASE is missing.
      Generate with: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :healthcare_cms, HealthcareCMSWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true

  # Guardian JWT secrets (production)
  guardian_secret_key =
    System.get_env("GUARDIAN_SECRET_KEY") ||
      raise """
      Environment variable GUARDIAN_SECRET_KEY is missing.
      Generate with: mix guardian.gen.secret
      """

  config :healthcare_cms, HealthcareCMS.Guardian,
    secret_key: guardian_secret_key,
    ttl: {15, :minutes}  # Shorter TTL in production

  # Healthcare API keys (ANVISA, CFM, PubMed)
  config :healthcare_cms, :external_apis,
    anvisa_api_key: System.get_env("ANVISA_API_KEY"),
    cfm_api_key: System.get_env("CFM_API_KEY"),
    pubmed_api_key: System.get_env("PUBMED_API_KEY")

  # SMTP configuration (email notifications)
  config :healthcare_cms, HealthcareCMS.Mailer,
    adapter: Swoosh.Adapters.SMTP,
    relay: System.get_env("SMTP_RELAY"),
    username: System.get_env("SMTP_USERNAME"),
    password: System.get_env("SMTP_PASSWORD"),
    ssl: true,
    tls: :always,
    auth: :always,
    port: 587

  # AWS S3 configuration (media storage)
  config :ex_aws,
    access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
    region: System.get_env("AWS_REGION") || "us-east-1"

  config :ex_aws, :s3,
    bucket: System.get_env("S3_BUCKET_NAME"),
    region: System.get_env("AWS_REGION") || "us-east-1"

  # Sentry error tracking
  config :sentry,
    dsn: System.get_env("SENTRY_DSN"),
    environment_name: :prod,
    enable_source_code_context: true,
    root_source_code_paths: [File.cwd!()],
    tags: %{
      env: "production",
      compliance: "LGPD+HIPAA"
    }
end
```

---

## Environment Variables Documentation

### Required Production Variables

```bash
# Database
DATABASE_URL=ecto://postgres:password@db.example.com/healthcare_cms_prod
POOL_SIZE=20

# Phoenix
SECRET_KEY_BASE=<64+ byte secret from mix phx.gen.secret>
PHX_HOST=healthcare-cms.example.com
PORT=4000

# Guardian JWT
GUARDIAN_SECRET_KEY=<64+ byte secret from mix guardian.gen.secret>

# External APIs
ANVISA_API_KEY=<ANVISA API key>
CFM_API_KEY=<CFM API key>
PUBMED_API_KEY=<PubMed API key>

# Email (SMTP)
SMTP_RELAY=smtp.sendgrid.net
SMTP_USERNAME=apikey
SMTP_PASSWORD=<SendGrid API key>

# AWS S3 (media storage)
AWS_ACCESS_KEY_ID=<AWS access key>
AWS_SECRET_ACCESS_KEY=<AWS secret>
AWS_REGION=us-east-1
S3_BUCKET_NAME=healthcare-cms-media-prod

# Error tracking
SENTRY_DSN=<Sentry DSN>
```

### Optional Variables

```bash
# Database SSL
DATABASE_CA_CERT_PATH=/etc/ssl/certs/rds-ca-bundle.pem

# Feature flags
ENABLE_WASM_PLUGINS=true
ENABLE_POST_QUANTUM_CRYPTO=false

# Performance tuning
BEAM_SCHEDULER_THREADS=8
BEAM_ASYNC_THREADS=10
```

---

## Secret Management Strategies

### 1. Environment Variables (Production)

```bash
# .env.prod (never commit to git!)
export SECRET_KEY_BASE="..."
export GUARDIAN_SECRET_KEY="..."
export DATABASE_URL="..."
```

**Load with**:
```bash
source .env.prod
mix phx.server
```

### 2. Docker Secrets

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    image: healthcare-cms:latest
    environment:
      - DATABASE_URL
      - SECRET_KEY_BASE
      - GUARDIAN_SECRET_KEY
    secrets:
      - db_password
      - guardian_secret

secrets:
  db_password:
    external: true
  guardian_secret:
    external: true
```

### 3. Kubernetes Secrets

```yaml
# k8s-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: healthcare-cms-secrets
type: Opaque
data:
  database-url: <base64 encoded>
  secret-key-base: <base64 encoded>
  guardian-secret-key: <base64 encoded>
```

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthcare-cms
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: healthcare-cms-secrets
              key: database-url
        - name: SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: healthcare-cms-secrets
              key: secret-key-base
```

### 4. AWS Systems Manager Parameter Store

```elixir
# config/runtime.exs (AWS SSM integration)
if config_env() == :prod do
  # Fetch secrets from AWS SSM
  {:ok, secret_key_base} = ExAws.SSM.get_parameter("/healthcare-cms/secret-key-base", decrypt: true)
  {:ok, guardian_secret} = ExAws.SSM.get_parameter("/healthcare-cms/guardian-secret", decrypt: true)

  config :healthcare_cms, HealthcareCMSWeb.Endpoint,
    secret_key_base: secret_key_base

  config :healthcare_cms, HealthcareCMS.Guardian,
    secret_key: guardian_secret
end
```

---

## Generating Secrets

### Phoenix Secret Key Base

```bash
mix phx.gen.secret
# Output: 64+ byte random string
```

### Guardian Secret Key

```bash
mix guardian.gen.secret
# Output: 64+ byte random string
```

### Database Encryption Key (LGPD compliance)

```bash
openssl rand -base64 32
# Output: 32-byte base64 encoded key
```

---

## Configuration Validation

### config/runtime.exs (with validation)

```elixir
defmodule HealthcareCMS.Config do
  @moduledoc """
  Configuration validation and helpers.
  """

  def validate_required_env!(env_var) do
    System.get_env(env_var) ||
      raise """
      Environment variable #{env_var} is missing.

      This variable is required for production deployment.
      Please set it before starting the application.
      """
  end

  def validate_url!(url) do
    URI.parse(url).scheme in ["http", "https"] ||
      raise "Invalid URL: #{url}"

    url
  end

  def validate_port!(port_string) do
    case Integer.parse(port_string) do
      {port, ""} when port > 0 and port < 65536 -> port
      _ -> raise "Invalid port: #{port_string}"
    end
  end
end
```

---

## Best Practices Summary

### ✅ DO

1. **Use runtime.exs for secrets**: Never hardcode secrets in config.exs
2. **Use environment variables**: Standard 12-factor app practice
3. **Validate configuration**: Fail fast with clear error messages
4. **Rotate secrets regularly**: Guardian keys every 90 days
5. **Use different secrets per environment**: dev ≠ test ≠ prod
6. **Document all variables**: README with required env vars
7. **Use secret management tools**: AWS SSM, Vault, Kubernetes secrets
8. **Encrypt secrets at rest**: Database encryption, S3 encryption
9. **Audit configuration changes**: Git log for config files
10. **Test configuration**: Verify prod config works before deployment

### ❌ DON'T

1. **Don't commit secrets to git**: Use `.gitignore` for `.env` files
2. **Don't use default secrets**: Change all example secrets
3. **Don't share secrets**: Unique per deployment
4. **Don't log secrets**: Sanitize logs (Logger metadata)
5. **Don't use weak secrets**: Minimum 64 bytes for crypto keys
6. **Don't skip validation**: Validate all env vars on startup
7. **Don't hardcode URLs**: Use environment variables
8. **Don't use same key for multiple purposes**: Separate Guardian, Phoenix, DB keys
9. **Don't ignore deprecation warnings**: Update config format
10. **Don't skip healthcare compliance**: Audit logging, encryption required

---

## References

- **[Elixir Config](https://hexdocs.pm/elixir/Config.html)** (L0_CANONICAL) - Configuration system
- **[Phoenix Deployment](https://hexdocs.pm/phoenix/deployment.html)** (L0_CANONICAL) - Deployment guide
- **[12 Factor App](https://12factor.net/config)** (L0_CANONICAL) - Configuration best practices
- **[Guardian Configuration](https://hexdocs.pm/guardian/configuration.html)** (L0_CANONICAL) - JWT configuration

---

**Status**: Production (Sprint 0-1)
**Healthcare Compliance**: Secret encryption, audit logging, LGPD compliance
**Security**: Runtime secrets, environment isolation, validation
**Environments**: dev (SQLite), test (in-memory), prod (PostgreSQL)
