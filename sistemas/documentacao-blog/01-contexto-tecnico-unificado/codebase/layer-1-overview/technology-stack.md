# Healthcare CMS - Technology Stack

> **Level**: 1 (Overview) | **Read Time**: 10min | **Tokens**: ~2K
> **Audience**: Developers, DevOps, architects
> **Last Validated**: 2025-09-30

---

## 🏗️ Core Runtime

### Elixir & Erlang/OTP

```yaml
elixir:
  version: "~> 1.14"
  current_tested: "1.17.3"
  justification: "Fault tolerance, concurrency, hot code reloading"
  reference: "ADR-001"

erlang_otp:
  version: "27.1"
  vm: "BEAM (Erlang Virtual Machine)"
  features:
    - Lightweight processes (millions of concurrent processes)
    - Actor model concurrency
    - Supervision trees (fault tolerance)
    - Hot code swapping
    - Distributed Erlang (multi-node clustering)

performance:
  http_throughput: "43,900 req/sec (production-validated)"
  websocket_concurrent: "2,143,000 connections"
  p99_latency: "67ms"
  scalability: "Near-linear (91-97% efficiency)"
```

**Why Elixir?** See [ADR-001: Elixir/Phoenix Choice](../../architecture/decisions-adr/001-elixir-phoenix-choice.md)

---

## 🌐 Web Framework

### Phoenix Framework

```yaml
phoenix:
  version: "~> 1.8.0"
  components:
    - Phoenix (core framework)
    - Phoenix.Endpoint (HTTP server)
    - Phoenix.Router (routing)
    - Phoenix.Controller (request handling)
    - Phoenix.PubSub (real-time messaging)

phoenix_ecto:
  version: "~> 4.4"
  purpose: "Database integration with Ecto ORM"

phoenix_html:
  version: "~> 3.3"
  purpose: "HTML helpers and form builders"

phoenix_live_view:
  version: "~> 1.1.0"
  purpose: "Real-time server-rendered SPAs"
  use_cases:
    - Medical content creation forms
    - Real-time patient monitoring dashboards
    - Zero Trust policy status display

phoenix_live_reload:
  version: "~> 1.4"
  environment: "dev"
  purpose: "Hot code reloading during development"

plug_cowboy:
  version: "~> 2.7"
  purpose: "HTTP server (Cowboy) adapter for Plug"
```

**Phoenix Features**:
- **Channels**: Real-time bidirectional communication (WebSocket)
- **LiveView**: Server-side rendering with reactive updates (no JavaScript)
- **PubSub**: Distributed message broadcasting (Phoenix.PubSub)
- **Presence**: Track user/device presence across nodes

---

## 🗄️ Database Layer

### Development: SQLite

```yaml
ecto_sqlite3:
  version: "~> 0.12"
  environment: "dev, test"
  database_file: "healthcare_cms_dev.db"
  justification: "Fast development, no external services"

features:
  - ACID compliance
  - Zero configuration
  - Single file database
  - Fast test suite (in-memory)
```

### Production: PostgreSQL

```yaml
postgrex:
  version: "~> 0.19"
  environment: "prod"
  target_version: "PostgreSQL 16.6"

features:
  - ACID compliance
  - Row-Level Security (RLS) for multi-tenancy
  - JSONB for flexible medical metadata
  - Full-text search (tsvector, tsquery)
  - TimescaleDB extension (time-series data)
  - pgvector extension (semantic search)
  - PostGIS extension (geolocation)

hipaa_compliance:
  - Encryption at rest (AES-256)
  - Encryption in transit (TLS 1.3)
  - Audit logging (pgaudit extension)
  - Backup and retention policies
```

### ORM: Ecto

```yaml
ecto_sql:
  version: "~> 3.12"
  purpose: "Database wrapper and query builder"

features:
  - Changesets (validation + casting)
  - Migrations (schema versioning)
  - Associations (belongs_to, has_many, many_to_many)
  - Multi-tenancy (dynamic repositories)
  - Composable queries
  - Prepared statements (SQL injection prevention)

conventions:
  schema_file: "lib/healthcare_cms/<context>/<schema>.ex"
  migration_file: "priv/repo/migrations/<timestamp>_<description>.exs"
```

---

## 🔒 Security Stack

### Authentication: Guardian

```yaml
guardian:
  version: "~> 2.3"
  purpose: "JWT-based authentication"
  reference: "ADR-005"

guardian_phoenix:
  version: "~> 2.0"
  purpose: "Phoenix integration (plugs, controllers)"

features:
  - Stateless JWT tokens
  - Token revocation (blacklist)
  - Sliding window refresh (15min inactivity timeout)
  - Trust score embedded in claims

token_structure:
  claims:
    - user_id (subject)
    - role (authorization)
    - trust_score (Zero Trust integration)
    - tenant_id (multi-tenancy)
    - iat (issued at)
    - exp (expiration)
  signature: "HMAC-SHA256 (development), RS256 (production)"
  lifetime: "15 minutes (sliding window)"
```

### Password Hashing: Argon2

```yaml
argon2_elixir:
  version: "~> 3.0"
  algorithm: "Argon2id (hybrid mode)"
  parameters:
    time_cost: 4        # Iterations
    memory_cost: 65536  # 64MB
    parallelism: 2      # Threads

justification: "Winner of Password Hashing Competition 2015"
compliance: "OWASP recommended, HIPAA-compliant"

security_properties:
  - Memory-hard (GPU attack resistant)
  - Side-channel resistant
  - Configurable cost parameters
  - Salt automatically generated
```

### Zero Trust: Custom Implementation

```yaml
policy_engine:
  file: "lib/healthcare_cms/security/policy_engine.ex"
  type: "GenServer (stateful process)"
  reference: "ADR-002"

trust_algorithm:
  file: "lib/healthcare_cms/security/trust_algorithm.ex"
  data_sources: 8
  calculation_latency: "< 10ms (p99)"

features:
  - 8 data source trust scoring
  - ETS cache (5min TTL)
  - PostgreSQL RLS integration
  - Phoenix plug enforcement
```

### Post-Quantum Cryptography (Planned)

```yaml
ex_oqs:
  version: "~> 0.3.0"
  status: "Planned (Sprint 3+)"
  algorithms:
    - CRYSTALS-Kyber (KEM) - NIST FIPS 203
    - CRYSTALS-Dilithium (Signature) - NIST FIPS 204
    - SPHINCS+ (Signature) - NIST FIPS 205

hybrid_mode:
  - Classical: X25519 + Ed25519
  - PQC: Kyber-768 + Dilithium3
  - Combined: XOR key material
```

---

## 🔌 WebAssembly Runtime (Planned)

```yaml
extism:
  version: "~> 1.0.0"
  status: "Disabled (requires Rust toolchain)"
  reference: "ADR-003"

extism_sdk:
  runtime: "Wasmtime 25.0.3"
  spec: "WASM 2.0"
  wasi: "WebAssembly System Interface (capability-based)"

use_cases:
  - LGPD Analyzer (Rust plugin)
  - Medical Claims Extractor (Go plugin)
  - FHIR Validator (C plugin)
  - Custom medical workflows (multi-language)

performance:
  cold_start: "42ms (vs 850ms Docker)"
  hot_execution: "5.8% overhead vs native"
  memory_per_plugin: "2.44MB (vs 180MB Docker)"

blocker: "Requires Rust compiler in CI/CD pipeline"
```

---

## 📡 HTTP Clients

### HTTPoison

```yaml
httpoison:
  version: "~> 2.0"
  based_on: "Hackney (Erlang HTTP client)"
  use_cases:
    - Legacy medical API integration
    - SOAP services (HL7, DICOM)
    - Long-running connections

features:
  - Connection pooling
  - Streaming responses
  - Timeout configuration
  - SSL/TLS support
```

### Req (Modern Alternative)

```yaml
req:
  version: "~> 0.4"
  purpose: "Modern, declarative HTTP client"
  use_cases:
    - RESTful APIs (FHIR, telemedicine platforms)
    - JSON APIs
    - OAuth2 authentication

features:
  - Pipeline-based architecture
  - Middleware support
  - Automatic retries
  - JSON encoding/decoding
  - Better error handling
```

---

## 📊 Monitoring & Observability

### Telemetry

```yaml
telemetry_metrics:
  version: "~> 0.6"
  purpose: "Metrics collection framework"

telemetry_poller:
  version: "~> 1.0"
  purpose: "Periodic metrics polling (memory, CPU)"

metrics_collected:
  - HTTP request duration
  - Database query duration
  - Phoenix LiveView render time
  - Zero Trust policy evaluation time
  - WebSocket connection count
  - BEAM memory usage
  - Process count
```

### Prometheus Export

```yaml
prometheus_ex:
  version: "~> 3.0"
  purpose: "Prometheus metrics exporter"
  endpoint: "/metrics"
  port: 9568

exported_metrics:
  - phoenix_http_request_duration_microseconds (histogram)
  - phoenix_http_requests_total (counter)
  - ecto_query_duration_microseconds (histogram)
  - vm_memory_bytes (gauge)
  - vm_total_run_queue_lengths_total (gauge)
  - policy_engine_evaluations_total (counter)
  - trust_score_histogram (histogram)

integration:
  - Grafana dashboards
  - Alertmanager (SLO violations)
  - PagerDuty (on-call rotation)
```

---

## 🗓️ Utilities

### Timex

```yaml
timex:
  version: "~> 3.7"
  purpose: "DateTime parsing and formatting"

use_cases:
  - Medical record timestamps
  - Timezone conversions
  - Business hours calculations
  - Appointment scheduling
  - LGPD retention policies

features:
  - Timezone database (tzdata)
  - Duration calculations
  - Interval operations
  - Localization support
```

### Decimal

```yaml
decimal:
  version: "~> 2.0"
  purpose: "Arbitrary precision arithmetic"

use_cases:
  - Medical dosage calculations
  - Laboratory result precision
  - Financial calculations (billing)
  - BMI/vital signs calculations

justification: "Avoid floating-point rounding errors in medical calculations"

example:
  # ❌ Float (wrong)
  0.1 + 0.2 = 0.30000000000000004

  # ✅ Decimal (correct)
  Decimal.add("0.1", "0.2") = #Decimal<0.3>
```

### Jason

```yaml
jason:
  version: "~> 1.4"
  purpose: "Fast JSON encoding/decoding"

features:
  - Native Elixir implementation (no NIFs)
  - 2-3x faster than Poison
  - Protocol-based (extensible)
  - FHIR resource serialization
```

---

## 🧪 Development & Testing Tools

### Testing Framework

```yaml
ex_unit:
  built_in: "Elixir standard library"
  features:
    - Async tests (parallel execution)
    - Property-based testing (StreamData)
    - ExUnit.Case (test case definition)
    - ExUnit.Assertions (assertion helpers)

floki:
  version: "~> 0.34"
  environment: "test"
  purpose: "HTML parsing and querying (LiveView tests)"

ex_unit_notifier:
  version: "~> 1.2"
  environment: "test"
  purpose: "Desktop notifications for test results"
```

### Code Quality

```yaml
credo:
  version: "~> 1.6"
  environment: "dev, test"
  purpose: "Static code analysis"

checks:
  - Code consistency
  - Design anti-patterns
  - Readability
  - Refactoring opportunities
  - Warning opportunities

sobelow:
  version: "~> 0.12"
  environment: "dev, test"
  purpose: "Security-focused static analysis"

checks:
  - SQL injection
  - XSS vulnerabilities
  - CSRF token validation
  - Insecure configuration
  - Hardcoded secrets

dialyxir:
  version: "~> 1.3"
  environment: "dev"
  purpose: "Static type checking (Dialyzer wrapper)"

features:
  - Type inconsistency detection
  - Unreachable code detection
  - @spec validation
  - Gradual typing support
```

---

## 🏥 Healthcare-Specific Libraries

### Planned Additions

```yaml
ex_hl7:
  status: "Planned (Sprint 2)"
  purpose: "HL7 v2 message parsing and generation"
  use_cases:
    - Hospital system integration
    - Laboratory results (ADT, ORM, ORU)
    - Patient admission/discharge

ex_fhir:
  status: "Planned (Sprint 2)"
  purpose: "FHIR R4 resource validation"
  use_cases:
    - Medical record interoperability
    - API integration (telemedicine platforms)
    - CDS Hooks (clinical decision support)

ex_dicom:
  status: "Research (Sprint 3+)"
  purpose: "DICOM image metadata parsing"
  use_cases:
    - Radiology integration
    - Image archiving (PACS)
    - Telemedicine imaging
```

---

## 📦 Deployment & Infrastructure

### OTP Release

```yaml
mix_release:
  built_in: "Elixir 1.9+"
  output: "Standalone ERTS (Erlang Runtime System)"

steps:
  - :assemble (compile + copy files)
  - :tar (create deployment tarball)

artifacts:
  - healthcare_cms-0.1.0.tar.gz (~50MB)
  - Includes Erlang VM (no external dependencies)
  - Self-contained executable

deployment:
  - Docker image (alpine:3.18 base)
  - Kubernetes StatefulSet
  - Horizontal Pod Autoscaler (HPA)
```

### Containerization

```yaml
dockerfile:
  base_image: "hexpm/elixir:1.17.3-erlang-27.1-alpine-3.18.6"
  size_optimized: true
  multi_stage: true

stages:
  1_builder:
    - Install Elixir dependencies
    - Compile application
    - Build release

  2_runtime:
    - Copy release artifact
    - Install OpenSSL (TLS)
    - Run as non-root user

final_size: "~80MB (vs 1.2GB with full Erlang)"
```

### Kubernetes Configuration

```yaml
deployment:
  replicas: 3 (minimum for HA)
  strategy: RollingUpdate
  max_surge: 1
  max_unavailable: 0

resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"

probes:
  liveness: "/health" (30s initial, 10s period)
  readiness: "/health" (10s initial, 5s period)

service:
  type: ClusterIP
  port: 4000
  target_port: 4000
```

---

## 🎯 Version Summary

```yaml
core:
  elixir: "~> 1.14 (tested: 1.17.3)"
  erlang_otp: "27.1"
  phoenix: "~> 1.8.0"
  phoenix_live_view: "~> 1.1.0"

database:
  ecto_sql: "~> 3.12"
  ecto_sqlite3: "~> 0.12 (dev/test)"
  postgrex: "~> 0.19 (prod)"

security:
  guardian: "~> 2.3"
  argon2_elixir: "~> 3.0"
  # ex_oqs: "~> 0.3.0 (planned)"

wasm:
  # extism: "~> 1.0.0 (disabled)"

monitoring:
  telemetry_metrics: "~> 0.6"
  prometheus_ex: "~> 3.0"

utilities:
  jason: "~> 1.4"
  timex: "~> 3.7"
  decimal: "~> 2.0"

development:
  credo: "~> 1.6"
  sobelow: "~> 0.12"
  dialyxir: "~> 1.3"
```

---

## 📚 Related Documentation

- **ADR-001: Elixir/Phoenix Choice**: `../../architecture/decisions-adr/001-elixir-phoenix-choice.md`
- **ADR-002: Zero Trust**: `../../architecture/decisions-adr/002-zero-trust-architecture.md`
- **ADR-003: WebAssembly Plugins**: `../../architecture/decisions-adr/003-webassembly-plugins.md`
- **ADR-005: Guardian JWT Auth**: `../../architecture/decisions-adr/005-guardian-jwt-auth.md`
- **Project Structure**: `./project-structure.md`
- **Key Concepts**: `./key-concepts.md`

---

**Version**: 1.0.0 | **Created**: 2025-09-30
