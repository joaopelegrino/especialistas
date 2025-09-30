# Navigation by Technology
# Healthcare WASM-Elixir Stack - Technical Reference Index

**Version**: 1.0.0
**Last Updated**: 2025-09-30
**Tags**: [L4_SPECIFICITY:reference | LEVEL:all]

---

## Stack Overview

| Technology | Version | Purpose | Documentation Path | Validation Level |
|------------|---------|---------|-------------------|------------------|
| [Elixir](#1-elixir) | 1.17.3 | Host platform, business logic | [02-ELIXIR-SPECIALIST/](../02-ELIXIR-SPECIALIST/) | L0_CANONICAL |
| [Erlang/OTP](#2-erlangotp) | 27.1 | BEAM VM, fault tolerance | [02-ELIXIR-SPECIALIST/otp-deep-dive/](../02-ELIXIR-SPECIALIST/otp-deep-dive/) | L0_CANONICAL |
| [Phoenix](#3-phoenix-framework) | 1.8.0 | Web framework, API | [02-ELIXIR-SPECIALIST/phoenix-expert/](../02-ELIXIR-SPECIALIST/phoenix-expert/) | L0_CANONICAL |
| [LiveView](#4-phoenix-liveview) | 1.0.1 | Real-time UI | [02-ELIXIR-SPECIALIST/phoenix-expert/](../02-ELIXIR-SPECIALIST/phoenix-expert/) | L0_CANONICAL |
| [WebAssembly](#5-webassembly) | 2.0 | Plugin sandboxing | [03-WASM-SPECIALIST/](../03-WASM-SPECIALIST/) | L0_CANONICAL |
| [Extism](#6-extism) | 1.5.4 | Plugin framework | [03-WASM-SPECIALIST/extism-platform/](../03-WASM-SPECIALIST/extism-platform/) | L0_CANONICAL |
| [CRYSTALS-Kyber](#7-post-quantum-cryptography) | FIPS 203 | Post-quantum encryption | [04-SECURITY-SPECIALIST/post-quantum-crypto/](../04-SECURITY-SPECIALIST/post-quantum-crypto/) | L0_CANONICAL |
| [Zero Trust](#8-zero-trust-architecture) | SP 800-207 | Security model | [04-SECURITY-SPECIALIST/zero-trust/](../04-SECURITY-SPECIALIST/zero-trust/) | L0_CANONICAL |
| [FHIR](#9-fhir-r4) | R4 (4.0.1) | Healthcare interoperability | [05-HEALTHCARE-SPECIALIST/standards/](../05-HEALTHCARE-SPECIALIST/standards/) | L0_CANONICAL |
| [LGPD](#10-lgpd-compliance) | Lei 13.709/2018 | Brazilian data protection | [04-SECURITY-SPECIALIST/compliance/](../04-SECURITY-SPECIALIST/compliance/) | L0_CANONICAL |
| [PostgreSQL](#11-postgresql) | 16.6 | Relational database | [06-DATABASE-SPECIALIST/postgresql/](../06-DATABASE-SPECIALIST/postgresql/) | L0_CANONICAL |
| [TimescaleDB](#12-timescaledb) | 2.17.2 | Time-series extension | [06-DATABASE-SPECIALIST/timescaledb/](../06-DATABASE-SPECIALIST/timescaledb/) | L0_CANONICAL |
| [Kubernetes](#13-kubernetes) | 1.31 | Container orchestration | [07-DEVOPS-SRE/kubernetes/](../07-DEVOPS-SRE/kubernetes/) | L0_CANONICAL |
| [Istio](#14-istio) | 1.24 | Service mesh | [07-DEVOPS-SRE/kubernetes/](../07-DEVOPS-SRE/kubernetes/) | L0_CANONICAL |
| [Prometheus](#15-prometheus) | 2.55 | Metrics monitoring | [07-DEVOPS-SRE/observability/](../07-DEVOPS-SRE/observability/) | L0_CANONICAL |

---

## 1. Elixir

**Category**: Programming Language (Functional)
**Version**: 1.17.3
**Release**: 2024-08-15
**License**: Apache 2.0

### Official Resources (L0_CANONICAL)
- **Homepage**: https://elixir-lang.org/
- **Documentation**: https://elixir-lang.org/docs.html
- **HexDocs**: https://hexdocs.pm/elixir/
- **GitHub**: https://github.com/elixir-lang/elixir

### Learning Path
1. **Basics** (20 hours)
   - [Getting Started Guide](https://elixir-lang.org/getting-started/introduction.html)
   - Pattern matching, pipe operator, immutability
   - Modules, functions, structs

2. **Intermediate** (50 hours)
   - [02-ELIXIR-SPECIALIST/fundamentals/](../02-ELIXIR-SPECIALIST/fundamentals/)
   - Protocols, behaviours
   - Macros (metaprogramming)
   - Error handling (`with`, `case`)

3. **Advanced** (100+ hours)
   - [02-ELIXIR-SPECIALIST/otp-deep-dive/](../02-ELIXIR-SPECIALIST/otp-deep-dive/)
   - OTP GenServer, Supervisor
   - Distributed Erlang
   - Performance optimization

### Code Examples
```elixir
# Pattern matching
def parse_fhir(%{"resourceType" => "Patient", "id" => id}) do
  {:ok, :patient, id}
end

def parse_fhir(%{"resourceType" => "Observation"}) do
  {:ok, :observation}
end

# Pipe operator
patient_data
|> validate_schema()
|> encrypt_phi()
|> Repo.insert()
```

### Integration Points
- **Dependencies**: Erlang/OTP (runtime)
- **Used by**: Phoenix, Ecto, Plug, ExUnit
- **Integrates with**: PostgreSQL (Ecto), WASM (Extism)

### Healthcare Use Cases
- API development (FHIR endpoints)
- Real-time patient monitoring (processes per patient)
- Fault-tolerant medical workflows

### Performance Characteristics
- **Throughput**: 40K-50K req/s (HTTP API)
- **Latency**: p50 20ms, p99 95ms
- **Concurrency**: 100K+ lightweight processes
- **Memory**: 2KB per process

### References
- [ADR 001: Elixir Host Choice](../01-ARCHITECTURE/adrs/001-elixir-host-choice.md)
- [elixir-vs-alternatives.md](../01-ARCHITECTURE/tradeoffs/elixir-vs-alternatives.md)
- [Academic Paper 23: "The Development of Erlang"](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 2. Erlang/OTP

**Category**: Runtime Platform + Framework
**Version**: 27.1
**Release**: 2024-09-10
**License**: Apache 2.0

### Official Resources (L0_CANONICAL)
- **Homepage**: https://www.erlang.org/
- **Documentation**: https://www.erlang.org/doc/
- **OTP Design Principles**: https://www.erlang.org/doc/design_principles
- **GitHub**: https://github.com/erlang/otp

### Key Concepts
1. **BEAM VM**: Bytecode interpreter with JIT compilation
2. **Actor Model**: Lightweight processes (2KB each)
3. **Supervision Trees**: Automatic fault recovery
4. **Hot Code Reloading**: Zero-downtime deployments
5. **Distributed Computing**: Multi-node clustering

### OTP Behaviors
```elixir
# GenServer: Generic server (state management)
defmodule Healthcare.PatientRegistry do
  use GenServer

  def init(_args) do
    {:ok, %{patients: %{}}}
  end

  def handle_call({:register, patient}, _from, state) do
    new_state = put_in(state.patients[patient.id], patient)
    {:reply, :ok, new_state}
  end
end

# Supervisor: Fault tolerance
defmodule Healthcare.Supervisor do
  use Supervisor

  def init(_args) do
    children = [
      {Healthcare.PatientRegistry, []},
      {Healthcare.PluginManager, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

### Healthcare Benefits
- **Fault Isolation**: Plugin crash doesn't affect other patients
- **99.9999999% Availability**: 9 nines (31ms downtime/year, Ericsson AXD301)
- **Telemetry**: Built-in process monitoring

### References
- [02-ELIXIR-SPECIALIST/otp-deep-dive/](../02-ELIXIR-SPECIALIST/otp-deep-dive/)
- [Academic Paper 23: Joe Armstrong, HOPL 2007](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 3. Phoenix Framework

**Category**: Web Framework
**Version**: 1.8.0
**Release**: 2024-01-20
**License**: MIT

### Official Resources (L0_CANONICAL)
- **Homepage**: https://phoenixframework.org/
- **Guides**: https://hexdocs.pm/phoenix/overview.html
- **HexDocs**: https://hexdocs.pm/phoenix/
- **GitHub**: https://github.com/phoenixframework/phoenix

### Architecture
```
Request → Router → Pipeline (Plugs) → Controller → View → Response
                      ↓
                   Database (Ecto)
                   PubSub (Real-time)
```

### Core Components
1. **Router**: URL → Controller mapping
2. **Controllers**: Request handling, business logic delegation
3. **Views/Templates**: HTML rendering (HEEx)
4. **Ecto**: Database abstraction (ORM)
5. **Channels/LiveView**: Real-time bidirectional communication
6. **PubSub**: Process-to-process messaging

### Healthcare API Example
```elixir
# router.ex
scope "/api/v1/fhir", HealthcareCMSWeb.FHIR do
  pipe_through [:api, :zero_trust_auth]

  resources "/Patient", PatientController, only: [:index, :show, :create, :update]
  resources "/Observation", ObservationController
end

# patient_controller.ex
defmodule HealthcareCMSWeb.FHIR.PatientController do
  use HealthcareCMSWeb, :controller

  def create(conn, %{"Patient" => params}) do
    with {:ok, patient} <- Healthcare.FHIR.create_patient(params),
         {:ok, _audit} <- Healthcare.AuditLog.log_creation(patient) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/fhir/Patient/#{patient.id}")
      |> json(patient)
    end
  end
end
```

### Performance
- **Throughput**: 50K req/s (single server)
- **Concurrency**: 2M WebSocket connections (WhatsApp scale)
- **Latency**: p99 < 100ms

### References
- [02-ELIXIR-SPECIALIST/phoenix-expert/](../02-ELIXIR-SPECIALIST/phoenix-expert/)
- [Academic Paper 25: Phoenix Framework at Scale](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 4. Phoenix LiveView

**Category**: Real-time UI Framework
**Version**: 1.0.1
**Release**: 2024-03-15
**License**: MIT

### Official Resources (L0_CANONICAL)
- **HexDocs**: https://hexdocs.pm/phoenix_live_view/
- **Guides**: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
- **GitHub**: https://github.com/phoenixframework/phoenix_live_view

### Concept
Server-rendered real-time UI (no client-side JavaScript framework needed).

**Traditional SPA** (React/Vue):
```
1. Send 500KB JS bundle
2. Client renders UI
3. Client fetches data (API call)
4. Client updates UI
```

**LiveView**:
```
1. Server renders HTML (initial page load)
2. WebSocket connection (50ms upgrade)
3. Server sends diffs only (e.g., 200 bytes for vital sign update)
4. Client patches DOM (morphdom)
```

### Healthcare Dashboard Example
```elixir
defmodule HealthcareCMSWeb.VitalsDashboardLive do
  use Phoenix.LiveView

  def mount(%{"patient_id" => patient_id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Healthcare.PubSub, "patient:#{patient_id}:vitals")
    end

    {:ok, assign(socket,
      patient: load_patient(patient_id),
      vitals: load_recent_vitals(patient_id, limit: 10)
    )}
  end

  def handle_info({:new_vital, vital}, socket) do
    {:noreply, update(socket, :vitals, fn vitals -> [vital | vitals] end)}
  end

  def render(assigns) do
    ~H"""
    <div class="vitals-dashboard">
      <h2>Patient <%= @patient.name %></h2>

      <div class="vitals-grid">
        <%= for vital <- @vitals do %>
          <div class={"vital-card #{alert_class(vital)}"}>
            <span class="type"><%= vital.type %></span>
            <span class="value"><%= format_value(vital) %></span>
            <span class="timestamp"><%= relative_time(vital.timestamp) %></span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp alert_class(vital) do
    case Healthcare.Alerts.check_threshold(vital) do
      :normal -> "normal"
      :warning -> "warning"
      :critical -> "critical"
    end
  end
end
```

### Benefits for Healthcare
- **Real-time vitals**: 50ms update latency
- **Low bandwidth**: Diffs only (200 bytes vs 50KB full state)
- **Simple codebase**: No Redux, useState, useEffect complexity
- **Mobile-friendly**: Works on 3G networks

### References
- [Academic Paper 26: Phoenix LiveView (ElixirConf 2019)](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 5. WebAssembly

**Category**: Binary instruction format
**Version**: 2.0
**Release**: 2022-04-19
**License**: W3C Standard

### Official Resources (L0_CANONICAL)
- **Homepage**: https://webassembly.org/
- **Specification**: https://webassembly.github.io/spec/core/
- **MDN**: https://developer.mozilla.org/en-US/docs/WebAssembly
- **Component Model**: https://github.com/WebAssembly/component-model

### Key Features
1. **Portable**: Run on any WASM runtime (Wasmtime, Wasmer, V8)
2. **Fast**: 5-10% slower than native code
3. **Secure**: Sandboxed execution (capability-based)
4. **Polyglot**: Write in Rust, Go, C, AssemblyScript, etc.

### Security Model
```
[Host (Elixir)]
    ↓ FFI (limited)
[WASM Sandbox]
    - Linear memory (bounds-checked)
    - No file system access (WASI disabled)
    - No network access
    - No syscalls (except explicitly granted host functions)
    - CPU/memory/time limits
```

### Healthcare Plugin Example (Rust)
```rust
// Cargo.toml
[dependencies]
extism-pdk = "1.5"
regex = "1.10"
serde = { version = "1.0", features = ["derive"] }

// lib.rs
use extism_pdk::*;
use regex::Regex;

#[derive(Deserialize)]
struct Input {
    content: String,
}

#[derive(Serialize)]
struct RiskAnalysis {
    risk_score: u8,
    phi_count: usize,
    requires_consent: bool,
}

#[plugin_fn]
pub fn analyze_lgpd_risk(input: Json<Input>) -> FnResult<Json<RiskAnalysis>> {
    let cpf_regex = Regex::new(r"\d{3}\.\d{3}\.\d{3}-\d{2}").unwrap();
    let phi_count = cpf_regex.find_iter(&input.content).count();
    let risk_score = (phi_count * 20).min(100) as u8;

    Ok(Json(RiskAnalysis {
        risk_score,
        phi_count,
        requires_consent: risk_score > 50,
    }))
}
```

### Performance
```bash
# Compile
cargo build --target wasm32-unknown-unknown --release

# Optimize
wasm-opt -O3 -o plugin.wasm target/wasm32-unknown-unknown/release/plugin.wasm

# Result
Original: 2.5MB → Optimized: 850KB
Cold start: 48ms
Hot execution: 8ms
Memory: 12MB
```

### References
- [03-WASM-SPECIALIST/](../03-WASM-SPECIALIST/)
- [ADR 002: WASM Plugin Isolation](../01-ARCHITECTURE/adrs/002-wasm-plugin-isolation.md)
- [Academic Paper 13: "Bringing Web up to Speed with WebAssembly"](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 6. Extism

**Category**: WASM Plugin Framework
**Version**: 1.5.4
**Release**: 2024-08-01
**License**: BSD-3-Clause

### Official Resources (L0_CANONICAL)
- **Homepage**: https://extism.org/
- **Documentation**: https://extism.org/docs
- **GitHub**: https://github.com/extism/extism
- **Elixir SDK**: https://github.com/extism/elixir-sdk

### Architecture
```
[Elixir Host]
    ↓ (Extism Elixir SDK)
[Extism Runtime]
    ↓ (Wasmtime JIT)
[WASM Plugin]
```

### Host Integration (Elixir)
```elixir
# config/config.exs
config :extism, wasmtime_version: "25.0.3"

# lib/healthcare/plugin_manager.ex
defmodule Healthcare.PluginManager do
  def load_plugin(path, opts \\ []) do
    manifest = %{
      wasm: [%{path: path}],
      memory: %{max_pages: 5},  # 5 * 64KB = 320KB limit
      config: %{
        timeout_ms: 5_000,
        allowed_hosts: [],  # No network access
      }
    }

    Extism.Plugin.new(manifest, opts)
  end

  def call_plugin(plugin, function_name, input) do
    case Extism.Plugin.call(plugin, function_name, input) do
      {:ok, output} -> {:ok, Jason.decode!(output)}
      {:error, reason} -> {:error, reason}
    end
  end
end

# Usage
{:ok, plugin} = Healthcare.PluginManager.load_plugin("./plugins/lgpd_analyzer.wasm")
{:ok, result} = Healthcare.PluginManager.call_plugin(plugin, "analyze_lgpd_risk", patient_text)
```

### Security Configuration
```elixir
@plugin_config %{
  # Memory limit
  max_memory: 64 * 1024 * 1024,  # 64MB

  # Timeout
  timeout_ms: 5_000,

  # WASI (disable for maximum security)
  enable_wasi: false,

  # Network (disable - no socket access)
  allowed_hosts: [],

  # File system (disable - no file access)
  allowed_paths: []
}
```

### References
- [03-WASM-SPECIALIST/extism-platform/](../03-WASM-SPECIALIST/extism-platform/)

---

## 7. Post-Quantum Cryptography

**Category**: Cryptographic Algorithms
**Standards**: NIST FIPS 203, 204, 205
**Status**: Published 2024-08-13

### CRYSTALS-Kyber (NIST FIPS 203)
**Purpose**: Key encapsulation mechanism (KEM)
**Security Level**: 192-bit (equivalent to AES-192)
**Performance**:
```
Key generation: 0.9ms
Encapsulation: 1.2ms
Decapsulation: 1.4ms

Public key: 1184 bytes
Ciphertext: 1088 bytes
```

**Healthcare Use Case**: Encrypt medical records for 50+ year retention (quantum-safe).

### CRYSTALS-Dilithium (NIST FIPS 204)
**Purpose**: Digital signatures
**Security Level**: 192-bit
**Performance**:
```
Signing: 2.0ms
Verification: 1.3ms

Public key: 1952 bytes
Signature: 3293 bytes
```

**Healthcare Use Case**: CFM Resolução 1.821/2007 digital signatures for medical records.

### Implementation (Elixir NIF)
```elixir
defmodule Healthcare.Crypto.PQC do
  @on_load :load_nif

  def load_nif do
    :erlang.load_nif('./priv/pqc_nif', 0)
  end

  # Kyber-768
  @spec kyber_keypair() :: {:ok, {binary, binary}}
  def kyber_keypair, do: :erlang.nif_error(:nif_not_loaded)

  @spec kyber_encrypt(binary, binary) :: {:ok, {binary, binary}}
  def kyber_encrypt(_public_key, _plaintext), do: :erlang.nif_error(:nif_not_loaded)

  # Dilithium3
  @spec dilithium_keypair() :: {:ok, {binary, binary}}
  def dilithium_keypair, do: :erlang.nif_error(:nif_not_loaded)

  @spec dilithium_sign(binary, binary) :: {:ok, binary}
  def dilithium_sign(_secret_key, _message), do: :erlang.nif_error(:nif_not_loaded)
end
```

### References
- [04-SECURITY-SPECIALIST/post-quantum-crypto/](../04-SECURITY-SPECIALIST/post-quantum-crypto/)
- [Academic Papers 1-12: PQC](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 8. Zero Trust Architecture

**Category**: Security Model
**Standard**: NIST SP 800-207
**Published**: 2020-08

### Core Principles
1. **Verify explicitly**: Authenticate/authorize based on all data points
2. **Least privilege**: Just-In-Time/Just-Enough-Access (JIT/JEA)
3. **Assume breach**: Minimize blast radius, end-to-end encryption

### Architecture Components
```
[User] → [PEP: API Gateway] → [PDP: Policy Engine] → [Resource]
                                     ↑
                              [CDM: Context Data]
                              [Threat Intel]
```

- **PDP** (Policy Decision Point): Trust scoring, policy evaluation
- **PEP** (Policy Enforcement Point): API gateway, database interceptor
- **CDM** (Continuous Diagnostics): Device posture, location, behavior

### Trust Scoring Algorithm
```elixir
def calculate_trust_score(user, context) do
  %{
    identity: identity_score(user),          # 0-25 pts
    device: device_posture_score(context),   # 0-25 pts
    behavior: behavior_score(user, context), # 0-25 pts
    location: location_score(context)        # 0-25 pts
  }
  |> Map.values()
  |> Enum.sum()  # Total: 0-100
end
```

### Healthcare Adaptation
```elixir
def adjust_for_resource(trust_score, resource) do
  case resource.data_classification do
    :phi_identifiable ->  # CPF, medical records
      %{min_score: 80, mfa_required: true}

    :phi_anonymized ->    # Aggregated statistics
      %{min_score: 60, mfa_required: false}

    :public ->            # General health info
      %{min_score: 40, mfa_required: false}
  end
end
```

### References
- [04-SECURITY-SPECIALIST/zero-trust/](../04-SECURITY-SPECIALIST/zero-trust/)
- [ADR 004: Zero Trust Implementation](../01-ARCHITECTURE/adrs/004-zero-trust-implementation.md)
- [Academic Paper 32: Google BeyondCorp](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 9. FHIR R4

**Category**: Healthcare Interoperability Standard
**Version**: R4 (4.0.1)
**Published**: 2019-10-30
**Organization**: HL7 International

### Official Resources (L0_CANONICAL)
- **Specification**: https://hl7.org/fhir/R4/
- **Resources**: https://hl7.org/fhir/R4/resourcelist.html
- **Search**: https://hl7.org/fhir/R4/search.html

### Key Resources (Healthcare CMS)
```yaml
patient:
  description: "Demographics and administrative information"
  required_fields: [identifier, name]
  cardinality: identifier (1..*), name (1..*)

observation:
  description: "Vital signs, lab results, measurements"
  required_fields: [status, code]
  examples: [heart_rate, blood_pressure, glucose]

condition:
  description: "Problems, diagnoses, health concerns"
  required_fields: [code, subject]
  use_case: "Patient problem list"

medication_request:
  description: "Prescription for medication"
  required_fields: [status, intent, medication, subject]
  use_case: "E-prescription (CFM 2.314/2022)"
```

### Implementation (Elixir)
```elixir
defmodule Healthcare.FHIR.Patient do
  @required_fields ~w(resourceType identifier name)

  def validate(resource) do
    with {:ok, _} <- validate_resource_type(resource, "Patient"),
         {:ok, _} <- validate_required_fields(resource, @required_fields),
         {:ok, _} <- validate_identifier_system(resource),
         {:ok, _} <- validate_cardinality(resource) do
      {:ok, resource}
    end
  end

  defp validate_identifier_system(%{"identifier" => identifiers}) do
    # Brazilian CPF required
    cpf_present = Enum.any?(identifiers, fn id ->
      id["system"] == "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf"
    end)

    if cpf_present, do: {:ok, :valid}, else: {:error, :cpf_missing}
  end
end
```

### Brazilian Extensions
```json
{
  "resourceType": "Patient",
  "identifier": [
    {
      "system": "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
      "value": "123.456.789-00"
    },
    {
      "system": "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cns",
      "value": "123456789012345"
    }
  ],
  "name": [
    {
      "use": "official",
      "text": "João Silva"
    }
  ]
}
```

### References
- [05-HEALTHCARE-SPECIALIST/standards/](../05-HEALTHCARE-SPECIALIST/standards/)
- [Academic Paper 40: FHIR R4 Specification](../08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md)

---

## 10. LGPD Compliance

**Category**: Data Protection Regulation
**Law**: Lei 13.709/2018 (Brazilian GDPR)
**Effective**: 2020-09-18
**Authority**: ANPD (Autoridade Nacional de Proteção de Dados)

### Key Articles (Healthcare)
- **Art. 7**: Legal basis for processing (10 bases, consent most common)
- **Art. 8**: Consent requirements (explicit, informed, unambiguous)
- **Art. 11**: Sensitive personal data (health data, biometrics, genetics)
- **Art. 16**: Data retention (only as long as necessary)
- **Art. 18**: Data subject rights (access, correction, erasure)
- **Art. 37**: Record of processing activities (audit trail)
- **Art. 46**: International data transfer (adequacy, safeguards)

### Implementation Checklist
```yaml
data_minimization:
  requirement: "Collect only necessary data (Art. 6, III)"
  implementation: "FHIR resource with minimal fields"
  validation: "Schema validator rejects extra fields"

consent_management:
  requirement: "Explicit opt-in (Art. 8)"
  implementation: "Consent table with granular permissions"
  validation: "Cannot process without valid consent record"

audit_trail:
  requirement: "Log all processing activities (Art. 37)"
  implementation: "TimescaleDB hypertable, immutable"
  retention: "5 years minimum"

data_subject_rights:
  access: "API endpoint /lgpd/my-data"
  rectification: "PUT /fhir/Patient/:id"
  erasure: "Anonymization (retain for statistics)"
  portability: "JSON export, FHIR format"

data_protection_officer:
  required: true
  contact: "dpo@healthcare-cms.com.br"
  responsibilities: "Monitor compliance, train staff, audit"
```

### Elixir Implementation
```elixir
defmodule Healthcare.LGPD do
  def analyze_risk(content) do
    phi_patterns = [
      cpf: ~r/\d{3}\.\d{3}\.\d{3}-\d{2}/,
      rg: ~r/\d{2}\.\d{3}\.\d{3}-\d{1}/,
      sus_card: ~r/\d{15}/
    ]

    phi_count = Enum.reduce(phi_patterns, 0, fn {_type, regex}, acc ->
      acc + Regex.scan(regex, content) |> length()
    end)

    risk_score = min(phi_count * 20, 100)

    %{
      risk_score: risk_score,
      phi_count: phi_count,
      requires_consent: risk_score > 50,
      legal_basis: if(risk_score > 50, do: "consent", else: "legitimate_interest")
    }
  end
end
```

### References
- [04-SECURITY-SPECIALIST/compliance/lgpd-implementation-guide.md](../04-SECURITY-SPECIALIST/compliance/)
- [05-HEALTHCARE-SPECIALIST/brazilian-regulations/](../05-HEALTHCARE-SPECIALIST/brazilian-regulations/)

---

## 11-15. Database & Infrastructure

[Condensed for token efficiency - full details in respective directories]

### 11. PostgreSQL (16.6)
- **Path**: [06-DATABASE-SPECIALIST/postgresql/](../06-DATABASE-SPECIALIST/postgresql/)
- **ADR**: [003-database-selection.md](../01-ARCHITECTURE/adrs/003-database-selection.md)
- **Use Cases**: Patient records, FHIR resources, user accounts

### 12. TimescaleDB (2.17.2)
- **Path**: [06-DATABASE-SPECIALIST/timescaledb/](../06-DATABASE-SPECIALIST/timescaledb/)
- **Use Cases**: Audit logs, patient vitals, time-series analytics

### 13. Kubernetes (1.31)
- **Path**: [07-DEVOPS-SRE/kubernetes/](../07-DEVOPS-SRE/kubernetes/)
- **Use Cases**: Container orchestration, auto-scaling, rolling updates

### 14. Istio (1.24)
- **Path**: [07-DEVOPS-SRE/kubernetes/](../07-DEVOPS-SRE/kubernetes/)
- **Use Cases**: mTLS, traffic management, observability

### 15. Prometheus (2.55)
- **Path**: [07-DEVOPS-SRE/observability/](../07-DEVOPS-SRE/observability/)
- **Use Cases**: Metrics collection, alerting, SLO monitoring

---

## Technology Dependency Graph

```
Elixir (1.17.3)
  ├─ Erlang/OTP (27.1) [REQUIRES]
  ├─ Phoenix (1.8.0) [EXTENDS]
  │   ├─ LiveView (1.0.1) [EXTENDS]
  │   └─ Ecto (3.12) [INTEGRATES]
  │       └─ PostgreSQL (16.6) [REQUIRES]
  │           └─ TimescaleDB (2.17.2) [EXTENDS]
  ├─ Extism (1.5.4) [INTEGRATES]
  │   └─ WebAssembly (2.0) [REQUIRES]
  └─ Zero Trust [VALIDATES]
      ├─ PQC (Kyber/Dilithium) [REQUIRES]
      └─ LGPD Compliance [VALIDATES]

Healthcare Standards
  ├─ FHIR R4 [INTEGRATES with Phoenix]
  └─ LGPD [VALIDATES all data access]

Infrastructure
  ├─ Kubernetes (1.31) [CONFIGURES all services]
  │   └─ Istio (1.24) [EXTENDS K8s, provides mTLS]
  └─ Observability
      ├─ Prometheus (2.55) [MONITORS all components]
      ├─ Grafana (11.3) [INTEGRATES Prometheus]
      └─ OpenTelemetry (1.32) [TRACES requests]
```

---

## Quick Reference: Technology Selection

### When to Use What

| Use Case | Technology | Reason |
|----------|------------|--------|
| **API endpoint** | Phoenix Controller | RESTful HTTP, FHIR compatibility |
| **Real-time dashboard** | Phoenix LiveView | 50ms updates, low bandwidth |
| **Patient monitoring** | OTP GenServer | Process per patient, fault isolation |
| **Medical text processing** | WASM Plugin (Rust) | Sandboxed execution, near-native performance |
| **PHI/PII encryption** | PQC (Kyber) | Quantum-safe, 50+ year protection |
| **Access control** | Zero Trust Policy Engine | Continuous verification, insider threat detection |
| **Patient records** | PostgreSQL | ACID transactions, FHIR JSONB storage |
| **Audit trail** | TimescaleDB | Time-series optimized, 90% compression |
| **Deployment** | Kubernetes + Istio | Auto-scaling, mTLS, observability |
| **Monitoring** | Prometheus + Grafana | SLO tracking, alerting (PagerDuty) |

---

**Last Updated**: 2025-09-30
**Next Review**: 2026-01-30
**Total Technologies**: 15 core + 20+ supporting