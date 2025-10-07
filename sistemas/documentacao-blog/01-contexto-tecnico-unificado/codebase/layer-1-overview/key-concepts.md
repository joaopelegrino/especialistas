# Healthcare CMS - Key Concepts

> **Level**: 1 (Overview) | **Read Time**: 10min | **Tokens**: ~2K
> **Audience**: New developers, architects, security engineers
> **Last Validated**: 2025-09-30

---

## 🎯 Core Design Principles

### 1. Zero Trust Architecture (NIST SP 800-207)

**Never trust, always verify** - every request is authenticated and authorized.

#### Architecture Components

```
┌─────────────┐
│   Request   │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ Policy Enforcement  │  ← Phoenix Plugs
│ Point (PEP)         │  ← PostgreSQL RLS
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Policy Decision     │  ← GenServer (PolicyEngine)
│ Point (PDP)         │  ← Trust Score Algorithm
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Policy Information  │  ← User metadata
│ Point (PIP)         │  ← Device fingerprint
└─────────────────────┘  ← Behavioral analytics
```

**Policy Decision Example**:
```elixir
context = %{
  user_id: 123,
  role: "doctor",
  ip_address: "203.0.113.42",
  device_trusted: true,
  session_age: 300,  # 5 minutes
  resource: "Patient:456:medical_record"
}

decision = PolicyEngine.evaluate(context)
# => %PolicyDecision{
#      allow: true,
#      trust_score: 95,
#      required_score: 75,
#      reason: "High trust: known device + recent session"
#    }
```

**Trust Score Sources** (8 data sources):
1. **Authentication factor** - password/MFA/biometric
2. **Device fingerprint** - known/trusted device
3. **Session age** - time since last auth
4. **IP reputation** - geolocation, VPN detection
5. **User behavior** - typing patterns, mouse movement
6. **Resource sensitivity** - PHI vs public data
7. **Time of day** - unusual access hours
8. **Historical pattern** - deviation from normal

**Thresholds**:
- **Public content**: 30+ trust score
- **Draft editing**: 50+ trust score
- **PHI read**: 75+ trust score
- **PHI write**: 85+ trust score
- **Admin operations**: 95+ trust score

---

### 2. Multi-Tenant Admin Blind Design

**The admin cannot see tenant data** - cryptographic privacy by design.

#### How It Works

**PostgreSQL Row-Level Security (RLS)**:
```sql
-- Enable RLS on posts table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their tenant's data
CREATE POLICY tenant_isolation ON posts
  FOR ALL
  USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Admin queries fail automatically (no tenant_id set)
SELECT * FROM posts;
-- ERROR: unrecognized configuration parameter "app.tenant_id"
```

**Tenant Context Injection** (Elixir):
```elixir
# lib/healthcare_cms_web/plugs/assign_tenant.ex
defmodule HealthcareCMSWeb.Plugs.AssignTenant do
  def call(conn, _opts) do
    tenant_id = get_tenant_from_jwt(conn)

    # Set PostgreSQL session variable
    Repo.query!("SET app.tenant_id = $1", [tenant_id])

    assign(conn, :tenant_id, tenant_id)
  end
end
```

**Admin Isolation**:
- Admins have `tenant_id = NULL` in their JWT
- PostgreSQL RLS blocks all tenant data queries
- Emergency access requires explicit tenant consent + audit log

#### LGPD Compliance

**Legal Basis** (LGPD Art. 7):
- ✅ Tenant data: Consent (user agreement)
- ✅ Admin access: Legitimate interest (support) - **requires opt-in**

**Audit Trail** (LGPD Art. 16):
```elixir
defmodule HealthcareCMS.AuditLog do
  def log_cross_tenant_access(admin_id, tenant_id, reason) do
    %AuditLog{
      actor_id: admin_id,
      action: "cross_tenant_access",
      target_tenant: tenant_id,
      reason: reason,
      timestamp: DateTime.utc_now(),
      ip_address: get_ip(),
      consent_token: get_tenant_consent_token()
    }
    |> Repo.insert!()
  end
end
```

**Marketing Advantage**: "Even we cannot see your patient records."

---

### 3. Medical Workflow Pipeline (S.1.1 → S.4-1.1-3)

Healthcare content follows strict validation workflows:

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  S.1.1   │────▶│  S.2.1   │────▶│  S.3.1   │────▶│  S.4-1.1 │
│ Content  │     │ LGPD     │     │ Medical  │     │  CFM     │
│ Creation │     │ Analyzer │     │ Claims   │     │ Validator│
└──────────┘     └──────────┘     └──────────┘     └──────────┘
     │                │                │                │
     │                │                │                │
     ▼                ▼                ▼                ▼
  Draft            PHI/PII          Medical          Compliant
  Post             Detection        Terms             Content
```

#### S.1.1: Content Creation
- **Actor**: Healthcare professional (doctor, nurse, psychologist)
- **Input**: Draft medical article
- **Validation**: Role-based access (trust score ≥ 50)
- **Output**: Post entity with metadata

#### S.2.1: LGPD Analyzer
- **Purpose**: Detect PHI/PII in content
- **Implementation**: Regex patterns + NLP (planned WASM plugin)
- **Rules**:
  - CPF (XXX.XXX.XXX-XX)
  - Phone (XX) XXXXX-XXXX
  - Email addresses
  - Patient names (contextual detection)
  - Medical record numbers
- **Action**: Flag for review or auto-redact

#### S.3.1: Medical Claims Extractor
- **Purpose**: Identify medical claims requiring evidence
- **Examples**:
  - "Drug X treats condition Y" → requires clinical trial reference
  - "Procedure Z reduces mortality by N%" → requires meta-analysis
  - "Guideline recommends..." → requires official source
- **Evidence Levels**: Oxford CEBM hierarchy (Levels 1-5)
- **Action**: Require citation or mark as "expert opinion"

#### S.4-1.1-3: CFM Compliance Validator
- **Regulations**:
  - CFM Res. 1.821/2007 (Prontuário Eletrônico)
  - CFM Res. 2.314/2022 (Telemedicina)
  - ANVISA RDC 302/2005 (Laboratórios)
- **Validations**:
  - Digital signature present
  - Author credentials verified (CRM number)
  - Conflict of interest declaration
  - Patient consent documented
- **Action**: Approve for publication or return to author

**Current Status**:
- S.1.1: ✅ Implemented (Sprint 0-1)
- S.2.1: 🔄 Partial (regex patterns, NLP pending)
- S.3.1: 📋 Planned (Sprint 2)
- S.4-1.1-3: 📋 Planned (Sprint 3)

---

### 4. WebAssembly Plugin System

**Language-agnostic, sandboxed medical workflows** via Extism SDK.

#### Architecture

```
┌─────────────────────────────────────────────────┐
│ Elixir Host (Phoenix)                           │
│                                                 │
│  ┌──────────────┐      ┌──────────────┐       │
│  │ Content      │      │ Policy       │       │
│  │ Controller   │      │ Engine       │       │
│  └──────┬───────┘      └──────┬───────┘       │
│         │                     │                │
│         └─────────┬───────────┘                │
│                   │                            │
│                   ▼                            │
│         ┌──────────────────┐                  │
│         │ PluginManager    │                  │
│         │ (Extism NIFs)    │                  │
│         └──────────┬───────┘                  │
└────────────────────┼────────────────────────────┘
                     │ FFI
                     ▼
         ┌──────────────────────┐
         │ WASM Runtime         │
         │ (Wasmtime 25.0.3)    │
         │                      │
         │  ┌────────────────┐  │
         │  │ LGPD Analyzer  │  │ ← Rust (performance)
         │  │ (Rust)         │  │
         │  └────────────────┘  │
         │                      │
         │  ┌────────────────┐  │
         │  │ Claim Extractor│  │ ← Go (concurrency)
         │  │ (Go)           │  │
         │  └────────────────┘  │
         │                      │
         │  ┌────────────────┐  │
         │  │ FHIR Validator │  │ ← C (legacy integration)
         │  │ (C)            │  │
         │  └────────────────┘  │
         └──────────────────────┘
```

#### Why WASM?

**Security**:
- ✅ **Capability-based**: No ambient authority (filesystem, network)
- ✅ **Sandboxed**: Memory isolation (linear memory model)
- ✅ **Resource limits**: CPU time, memory quotas
- ✅ **Audit trail**: All host function calls logged

**Performance**:
```yaml
Cold Start: 42ms (vs 850ms Docker) - 20x faster
Hot Execution: 5.8% overhead vs native
Memory: 2.44MB per plugin (vs 180MB Docker) - 74x efficient
```

**Language Flexibility**:
```yaml
Rust: Performance-critical (LGPD analyzer, encryption)
Go: Concurrent processing (API integrations, data pipelines)
C: Legacy medical system integration (HL7, DICOM)
AssemblyScript: TypeScript-like (web developer friendly)
```

#### Plugin Example (Rust)

**Host Function Call** (Elixir):
```elixir
defmodule HealthcareCMS.Workflows.LGPDAnalyzer do
  def analyze_content(text) do
    plugin = Extism.Plugin.new("lgpd_analyzer.wasm")

    input = Jason.encode!(%{text: text})
    output = Extism.call(plugin, "analyze", input)

    Jason.decode!(output)
    # => %{
    #      has_phi: true,
    #      detected: [
    #        %{type: "cpf", value: "123.456.789-00", position: 145},
    #        %{type: "phone", value: "(11) 98765-4321", position: 203}
    #      ]
    #    }
  end
end
```

**Plugin Implementation** (Rust):
```rust
use extism_pdk::*;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct Input {
    text: String,
}

#[derive(Serialize)]
struct Output {
    has_phi: bool,
    detected: Vec<Detection>,
}

#[plugin_fn]
pub fn analyze(input: String) -> FnResult<String> {
    let input: Input = serde_json::from_str(&input)?;

    let cpf_regex = Regex::new(r"\d{3}\.\d{3}\.\d{3}-\d{2}")?;
    let phone_regex = Regex::new(r"\(\d{2}\) \d{5}-\d{4}")?;

    let mut detected = vec![];

    for m in cpf_regex.find_iter(&input.text) {
        detected.push(Detection {
            type_: "cpf".to_string(),
            value: m.as_str().to_string(),
            position: m.start(),
        });
    }

    // ... more detection logic

    let output = Output {
        has_phi: !detected.is_empty(),
        detected,
    };

    Ok(serde_json::to_string(&output)?)
}
```

**Current Status**:
- 📋 Planned (Sprint 2+)
- ⚠️ Blocker: Requires Rust toolchain in CI/CD

---

## 🔗 Concept Relationships

### Dependency Graph

```
Zero Trust
    ├── Multi-Tenant Design (tenant isolation via RLS)
    ├── Medical Workflows (trust score gates)
    └── WebAssembly Plugins (sandboxed execution)

Multi-Tenant Design
    ├── PostgreSQL RLS (database-level enforcement)
    └── LGPD Compliance (admin blind privacy)

Medical Workflows
    ├── LGPD Analyzer (PHI/PII detection)
    ├── Claims Extractor (evidence-based medicine)
    └── CFM Validator (regulatory compliance)

WebAssembly Plugins
    ├── Language Flexibility (Rust/Go/C)
    ├── Security (capability-based sandboxing)
    └── Performance (near-native speed)
```

### Integration Points

**Zero Trust + Multi-Tenant**:
- Trust score required for cross-tenant admin access
- RLS enforces policy decisions at database level

**Zero Trust + Medical Workflows**:
- Workflow progression gated by trust score thresholds
- S.1.1 (draft) → 50+, S.4-1.1 (publish) → 85+

**Medical Workflows + WebAssembly**:
- S.2.1 LGPD Analyzer implemented as Rust WASM plugin
- S.3.1 Claims Extractor as Go WASM plugin (concurrent processing)

---

## 📚 Related Documentation

- **Architecture Summary**: `../../architecture/_summary.md`
- **ADR-002: Zero Trust**: `../../architecture/decisions-adr/002-zero-trust-architecture.md`
- **ADR-004: Multi-Tenant**: `../../architecture/decisions-adr/004-multi-tenant-design.md`
- **ADR-003: WebAssembly**: `../../architecture/decisions-adr/003-webassembly-plugins.md`
- **Project Structure**: `./project-structure.md`
- **Main Workflows**: `./main-workflows.md` (next file)

---

**Version**: 1.0.0 | **Created**: 2025-09-30
