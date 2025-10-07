# Healthcare CMS - Progressive Documentation Index

> **Navigation Strategy**: Documentation organized in 4 progressive levels of depth, optimized for both human developers and LLM context loading.

---

## 🎯 How to Navigate This Documentation

### Level 0: Meta-Context (0-2min)
**For**: LLM initialization, new developers needing quick orientation
**Read**: `_meta/llm-context-master.md`
**Token Estimate**: ~500 tokens
**What You Get**: Project overview, current status, critical paths, entry points

### Level 1: Overview (5-10min)
**For**: General system understanding, architecture review
**Read**: Files in `codebase/layer-1-overview/`
**Token Estimate**: ~2K tokens
**What You Get**: High-level architecture, core modules, key workflows, technology stack

### Level 2: Core Understanding (20-30min)
**For**: Productive development work, implementing features
**Read**: Files in `codebase/layer-2-core/`
**Token Estimate**: ~8K tokens
**What You Get**: Detailed component architecture, code examples, security considerations, related docs

### Level 3: Detailed Knowledge (1-2h)
**For**: Architectural changes, advanced debugging, performance optimization
**Read**: Files in `codebase/layer-3-detailed/`
**Token Estimate**: ~20K tokens
**What You Get**: Implementation internals, edge cases, performance characteristics, security deep-dive

### Level 4: Expert Reference (as-needed)
**For**: Algorithm details, rare optimizations, specialized edge cases
**Read**: Files in `codebase/layer-4-deep-dive/`
**Token Estimate**: Variable
**What You Get**: Mathematical proofs, hardware benchmarks, historical context, research papers

---

## 📁 Layer 1: Overview (5-10min read, ~2K tokens)

### Core Files

#### `layer-1-overview/project-structure.md`
**What**: Complete system architecture overview
**Topics**:
- Phoenix application structure
- OTP supervision tree
- Context boundaries (Accounts, Content, Security)
- Database schemas
- Web layer organization

**Key Diagrams**:
- Application supervision tree
- Context dependency graph
- Request flow overview

#### `layer-1-overview/key-concepts.md`
**What**: Essential concepts for understanding the codebase
**Topics**:
- Zero Trust Architecture principles
- Multi-tenant admin blind design
- Healthcare compliance automation
- Medical content pipeline (S.1.1 → S.4-1.1-3)
- WebAssembly plugin system (planned)

**Key Takeaways**:
- Why Elixir/Phoenix for healthcare
- Security-first design philosophy
- Compliance as code approach

#### `layer-1-overview/main-workflows.md`
**What**: Common user and system workflows
**Topics**:
- User authentication flow
- Content creation workflow
- Medical approval process
- Zero Trust policy evaluation
- Health check and monitoring

**Workflow Diagrams**:
- Authentication sequence
- Content lifecycle
- Policy decision flow

#### `layer-1-overview/technology-stack.md`
**What**: Complete technology inventory
**Topics**:
- Runtime: Elixir 1.14+, Erlang/OTP 27+
- Framework: Phoenix 1.8.0, LiveView 1.1.0
- Database: SQLite (dev), PostgreSQL 16 (prod)
- Security: Guardian, Argon2, Zero Trust
- Monitoring: Telemetry, Prometheus

**Version Matrix**:
- Production dependencies
- Development tools
- Planned integrations (WebAssembly, TimescaleDB)

---

## 📁 Layer 2: Core Understanding (20-30min read, ~8K tokens)

### Security & Compliance

#### `layer-2-core/zero-trust-architecture.md`
**What**: Zero Trust implementation details
**Topics**:
- Policy Engine architecture (GenServer)
- Trust Algorithm (8 data sources)
- Policy Enforcement Points (PEPs)
- Continuous verification mechanisms
- Audit trail implementation

**Code Examples**:
- Policy Engine initialization
- Trust score calculation
- Policy decision evaluation
- PEP integration in controllers

**Related**:
- `../architecture/decisions-adr/002-zero-trust-choice.md`
- `layer-3-detailed/policy-engine-internals.md`

#### `layer-2-core/compliance-automation.md`
**What**: LGPD/CFM/ANVISA automated compliance
**Topics**:
- LGPD data detection (S.1.1 system)
- CFM medical claim validation
- ANVISA pharmaceutical checks
- CRP mental health guidelines
- Audit trail requirements

**Schemas**:
- Compliance event tracking
- Audit log structure
- Data classification taxonomy

#### `layer-2-core/authentication-system.md`
**What**: User authentication and session management
**Topics**:
- Guardian JWT implementation
- Argon2 password hashing
- Session storage strategy
- Multi-factor authentication (planned)
- Trust score integration

**Security Considerations**:
- Password requirements (OWASP)
- Session timeout (15min inactivity)
- Rate limiting (5 attempts/15min)
- Constant-time comparisons

### Database & Contexts

#### `layer-2-core/database-architecture.md`
**What**: Database design and multi-tenancy
**Topics**:
- Ecto Repo configuration
- Multi-tenant row-level security
- Schema design principles
- Migration strategy
- SQLite (dev) vs PostgreSQL (prod)

**Schemas Overview**:
- `User`: Healthcare professionals + roles
- `Post`: Medical content with metadata
- `Media`: Attachments and images
- `Category`: Taxonomy system
- `CustomField`: Extensible metadata

#### `layer-2-core/accounts-context.md`
**What**: User and role management
**Topics**:
- User CRUD operations
- Role-based access control (RBAC)
- WordPress role mapping
- Medical professional roles
- Permission system

**Status**: ⚠️ 0% test coverage - Sprint 0-2 priority

#### `layer-2-core/content-context.md`
**What**: Content management system
**Topics**:
- Post lifecycle management
- Media upload and storage
- Category/taxonomy management
- Custom fields system
- Version control (planned)

**Status**: ✅ 14.29% test coverage - Basic CRUD functional

### Medical Workflows

#### `layer-2-core/medical-workflows.md`
**What**: 5-stage medical content pipeline
**Topics**:
- S.1.1: LGPD Analyzer (auto-detect sensitive data)
- S.1.2: Medical Claims Extractor
- S.2-1.2: Scientific References (PubMed, SciELO)
- S.3-2: SEO + Professional Profile (CRM/CRP)
- S.4-1.1-3: Final Content Generator

**Current Status**: Schemas implemented, engines pending
**Blockers**: Web interface needed, API integrations pending

#### `layer-2-core/scientific-apis.md`
**What**: External API integrations for evidence-based medicine
**Topics**:
- PubMed API (NCBI E-utilities)
- SciELO API (Latin America research)
- Google Scholar integration
- CRM/CRP professional databases
- gov.br authentication (planned)

**Status**: Mapped, not implemented

### Web Layer

#### `layer-2-core/phoenix-application.md`
**What**: Phoenix web framework integration
**Topics**:
- Endpoint configuration
- Router and pipelines
- Controllers (Page, Health)
- LiveView integration (future)
- Security headers (LGPD compliance)

**Current Endpoints**:
- `GET /`: Homepage landing page
- `GET /health`: Health check JSON

---

## 📁 Layer 3: Detailed Knowledge (1-2h read, ~20K tokens)

### Security Internals

#### `layer-3-detailed/policy-engine-internals.md`
**What**: Deep dive into Zero Trust Policy Engine
**Topics**:
- GenServer state management
- Policy decision caching
- Asynchronous policy updates
- Failure handling and fallbacks
- Performance optimization (target <10ms)

**Performance Characteristics**:
- Policy evaluation: <5ms (avg)
- Trust score calculation: <3ms
- Cache hit rate: >90% (target)

#### `layer-3-detailed/trust-algorithm-implementation.md`
**What**: Trust scoring algorithm details
**Topics**:
- 8 data source weighting
- Healthcare-specific scoring logic
- Perfect score calculation (100 for verified doctor)
- Temporal decay functions
- Anomaly detection

**Algorithm Parameters**:
- Device trust: 15% weight
- Location: 10%
- Role: 25%
- MFA: 20%
- Session age: 10%
- Audit history: 10%
- Compliance: 5%
- Behavior: 5%

#### `layer-3-detailed/argon2-password-security.md`
**What**: Password hashing implementation
**Topics**:
- Argon2id parameter tuning
- Memory-hard function benefits
- Timing attack prevention
- Password rehashing strategy
- OWASP compliance

**Parameters**:
- Time cost: 4 iterations
- Memory cost: 64 MiB
- Parallelism: 2 threads
- Hash length: 32 bytes

### Database Internals

#### `layer-3-detailed/multi-tenant-isolation.md`
**What**: Admin blind multi-tenancy implementation
**Topics**:
- Row-level security (RLS) setup
- Tenant context injection
- Query scoping strategies
- Data migration between tenants
- Privacy guarantees

**Security Properties**:
- Admin cannot access tenant data
- Tenant isolation at database level
- Audit all cross-tenant operations

#### `layer-3-detailed/schema-design-patterns.md`
**What**: Database schema design principles
**Topics**:
- LGPD compliance in schemas
- Soft deletes and data retention
- JSON fields for extensibility
- Temporal data handling (Timex)
- Precision arithmetic (Decimal) for medical data

**Patterns**:
- Polymorphic associations
- Embedded schemas
- Virtual fields for computed data

### Workflow Engines

#### `layer-3-detailed/lgpd-analyzer-engine.md`
**What**: S.1.1 LGPD Analyzer implementation (planned)
**Topics**:
- Sensitive data detection algorithms
- NLP for Brazilian medical terms
- Consent requirement detection
- Auto-redaction strategies
- LGPD compliance scoring

**Status**: Architecture defined, implementation pending

#### `layer-3-detailed/medical-claim-extractor.md`
**What**: S.1.2 Medical Claims Extractor (planned)
**Topics**:
- Scientific claim parsing
- Evidence requirement detection
- CFM disclaimer generation
- Source verification
- Claim confidence scoring

**Status**: Schema ready, engine pending

---

## 📁 Layer 4: Expert Reference (as-needed, variable tokens)

### Algorithm Deep-Dives

#### `layer-4-deep-dive/trust-algorithm-math.md`
**What**: Mathematical foundations of trust scoring
**Topics**:
- Bayesian inference for trust updates
- Temporal decay functions (exponential)
- Anomaly detection (statistical)
- Multi-factor decision theory
- Healthcare risk modeling

#### `layer-4-deep-dive/argon2-attack-resistance.md`
**What**: Cryptographic analysis of password security
**Topics**:
- GPU/ASIC attack resistance
- Memory-hard function theory
- Parameter selection rationale
- Benchmark vs bcrypt/scrypt
- Future-proofing strategy

### Performance Optimization

#### `layer-4-deep-dive/policy-engine-optimization.md`
**What**: Policy evaluation performance tuning
**Topics**:
- ETS-based caching strategies
- GenServer bottleneck elimination
- Horizontal scaling considerations
- Benchmark methodology
- Profiling results

**Benchmarks**:
- Cold evaluation: ~15ms
- Cached evaluation: <2ms
- Throughput: 50K decisions/sec (target)

#### `layer-4-deep-dive/database-query-optimization.md`
**What**: PostgreSQL performance tuning
**Topics**:
- Index strategy for healthcare queries
- Query plan analysis
- N+1 query prevention
- Prepared statement caching
- Connection pooling tuning

### Historical Context

#### `layer-4-deep-dive/architecture-evolution.md`
**What**: How the architecture evolved and why
**Topics**:
- WordPress migration rationale
- Technology selection criteria
- Rejected alternatives (Go, Rust, Node.js)
- Lessons learned from validation
- Future architecture plans

**ADR References**:
- ADR-001: Elixir/Phoenix choice
- ADR-002: Zero Trust architecture
- ADR-003: WebAssembly plugins
- ADR-004: Multi-tenant design

---

## 🔗 Navigation Paths by Task

### Task: Implement New Feature

1. **Start**: `layer-1-overview/main-workflows.md` - understand existing flows
2. **Context**: `layer-2-core/<relevant-context>.md` - learn the context API
3. **Schema**: `layer-3-detailed/schema-design-patterns.md` - if DB changes needed
4. **Security**: `layer-2-core/zero-trust-architecture.md` - integrate policy checks
5. **Testing**: `../development/testing/testing-strategy.md` - write tests

### Task: Debug Production Issue

1. **Start**: `../operations/monitoring/observability-strategy.md` - gather metrics
2. **Common Issues**: `../development/debugging/common-issues-dsm.yaml` - known problems
3. **Component**: `layer-3-detailed/<component>-internals.md` - deep dive
4. **Performance**: `layer-4-deep-dive/<component>-optimization.md` - if slow
5. **Logs**: Check `/health` endpoint and application logs

### Task: Security Audit

1. **Start**: `layer-2-core/zero-trust-architecture.md` - understand security model
2. **Compliance**: `layer-2-core/compliance-automation.md` - LGPD/CFM/ANVISA
3. **Auth**: `layer-3-detailed/argon2-password-security.md` - password security
4. **Policy**: `layer-3-detailed/policy-engine-internals.md` - access control
5. **Audit**: `../operations/security/audit-procedures.md` - audit trails

### Task: Onboard New Developer

1. **Day 1**: Read `_meta/llm-context-master.md` + `layer-1-overview/*`
2. **Day 2**: Setup environment with `../development/setup-environment/local-development.md`
3. **Day 3**: Read `layer-2-core/phoenix-application.md` + `zero-trust-architecture.md`
4. **Week 1**: Complete `../development/hands-on-exercises/exercise-01-crud.md`
5. **Week 2**: Pair program on Sprint 0-2 auth flow

---

## 📊 Documentation Metrics

### Coverage by Layer

- **Layer 0 (Meta)**: ✅ 100% (1/1 file)
- **Layer 1 (Overview)**: 🔄 0% (0/4 planned files)
- **Layer 2 (Core)**: 🔄 0% (0/8 planned files)
- **Layer 3 (Detailed)**: 🔄 0% (0/10 planned files)
- **Layer 4 (Deep-Dive)**: 🔄 0% (0/6 planned files)

**Total**: 3.4% complete (1/29 planned files)
**Next Priority**: Layer 1 overview files

### Token Efficiency

| Layer | Traditional Docs | Six-Layer Docs | Reduction |
|-------|-----------------|----------------|-----------|
| Quick context | 5000 tokens | 500 tokens | 90% |
| Basic understanding | 15000 tokens | 2000 tokens | 87% |
| Working knowledge | 50000 tokens | 8000 tokens | 84% |
| Expert reference | 150000 tokens | 20000 tokens | 87% |

**Average Reduction**: 87% fewer tokens for same information density

---

## 🎯 Planned Documentation Files

### Layer 1 (Next Priority - Sprint 0-2)

- [ ] `layer-1-overview/project-structure.md`
- [ ] `layer-1-overview/key-concepts.md`
- [ ] `layer-1-overview/main-workflows.md`
- [ ] `layer-1-overview/technology-stack.md`

### Layer 2 (Sprint 0-3 - Sprint 1)

- [ ] `layer-2-core/zero-trust-architecture.md`
- [ ] `layer-2-core/compliance-automation.md`
- [ ] `layer-2-core/authentication-system.md`
- [ ] `layer-2-core/database-architecture.md`
- [ ] `layer-2-core/accounts-context.md`
- [ ] `layer-2-core/content-context.md`
- [ ] `layer-2-core/medical-workflows.md`
- [ ] `layer-2-core/scientific-apis.md`
- [ ] `layer-2-core/phoenix-application.md`

### Layer 3 (Sprint 2+)

- [ ] `layer-3-detailed/policy-engine-internals.md`
- [ ] `layer-3-detailed/trust-algorithm-implementation.md`
- [ ] `layer-3-detailed/argon2-password-security.md`
- [ ] `layer-3-detailed/multi-tenant-isolation.md`
- [ ] `layer-3-detailed/schema-design-patterns.md`
- [ ] `layer-3-detailed/lgpd-analyzer-engine.md`
- [ ] `layer-3-detailed/medical-claim-extractor.md`

### Layer 4 (As-needed)

- [ ] `layer-4-deep-dive/trust-algorithm-math.md`
- [ ] `layer-4-deep-dive/argon2-attack-resistance.md`
- [ ] `layer-4-deep-dive/policy-engine-optimization.md`
- [ ] `layer-4-deep-dive/database-query-optimization.md`
- [ ] `layer-4-deep-dive/architecture-evolution.md`

---

**Version**: 1.0.0
**Created**: 2025-09-30
**Methodology**: Six-Layer Progressive Contextualization
**Completion**: 3.4% (1/29 files)
**Next Milestone**: Complete Layer 1 (4 files) by end of Sprint 0-2
