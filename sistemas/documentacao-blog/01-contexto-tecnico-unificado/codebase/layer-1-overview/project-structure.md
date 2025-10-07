# Healthcare CMS - Project Structure

> **Level**: 1 (Overview) | **Read Time**: 10min | **Tokens**: ~2K
> **Audience**: New developers, architects
> **Last Validated**: 2025-09-30

---

## 📁 Directory Structure

```
healthcare_cms/
├── lib/
│   ├── healthcare_cms/              # Business logic (contexts)
│   │   ├── application.ex           # OTP Application entry
│   │   ├── repo.ex                  # Ecto database repository
│   │   ├── accounts/                # User & authentication
│   │   │   ├── user.ex             # User schema
│   │   │   └── role.ex             # Role schema
│   │   ├── content/                 # Content management
│   │   │   ├── post.ex             # Post schema
│   │   │   ├── media.ex            # Media attachments
│   │   │   ├── category.ex         # Taxonomy
│   │   │   └── custom_field.ex     # Extensible metadata
│   │   ├── security/                # Zero Trust components
│   │   │   ├── policy_engine.ex    # GenServer policy decisions
│   │   │   ├── trust_algorithm.ex  # Trust score calculation
│   │   │   └── policy_decision.ex  # Decision struct
│   │   └── workflows/               # Medical workflows (planned)
│   │       ├── lgpd_analyzer.ex    # S.1.1 LGPD detection
│   │       └── claim_extractor.ex  # S.1.2 Claims validation
│   │
│   └── healthcare_cms_web/          # Web layer
│       ├── endpoint.ex              # HTTP endpoint
│       ├── router.ex                # Routes definition
│       ├── gettext.ex               # I18n
│       ├── controllers/             # HTTP controllers
│       │   ├── page_controller.ex  # Homepage
│       │   └── health_controller.ex # Health check
│       └── plugs/                   # Request middleware
│           ├── require_auth.ex     # Authentication plug
│           └── assign_current_user.ex # Session user
│
├── test/                            # Test suite
│   ├── healthcare_cms/
│   │   ├── security/               # Security tests (74.75% coverage)
│   │   ├── accounts/               # Accounts tests (0% - Sprint 0-2)
│   │   └── content/                # Content tests (14.29%)
│   ├── healthcare_cms_web/
│   └── support/                    # Test helpers
│
├── priv/
│   └── repo/
│       ├── migrations/             # Database migrations
│       └── seeds.exs               # Seed data
│
├── config/                         # Configuration
│   ├── config.exs                 # Shared config
│   ├── dev.exs                    # Development
│   ├── test.exs                   # Test
│   └── runtime.exs                # Runtime (prod secrets)
│
├── mix.exs                        # Project definition
└── mix.lock                       # Dependency lock file
```

---

## 🏗️ OTP Application Supervision Tree

```elixir
HealthcareCMS.Application (Supervisor)
├── HealthcareCMS.Repo
│   └── DBConnection.Poolboy (10 connections)
│
├── HealthcareCMS.Security.PolicyEngine (GenServer)
│   ├── Trust Score Cache (ETS)
│   └── Policy Decision Cache (ETS)
│
├── Phoenix.PubSub.PG2
│   └── Real-time subscriptions
│
└── HealthcareCMSWeb.Endpoint (Supervisor)
    ├── Cowboy.HTTP (port 4000)
    ├── Phoenix.LiveReloader (dev only)
    └── Phoenix.CodeReloader (dev only)
```

**Restart Strategy**: `:one_for_one`
- Each child restarts independently
- Critical children (Repo, PolicyEngine) crash entire app
- Phoenix Endpoint restarts without affecting DB/security

---

## 🎯 Context Boundaries (DDD)

### Accounts Context

**Responsibility**: User management, authentication, authorization

**Schemas**:
- `User`: Healthcare professionals, admins
- `Role`: WordPress-compatible roles + medical roles

**Public API**:
```elixir
Accounts.list_users()
Accounts.get_user!(id)
Accounts.create_user(attrs)
Accounts.authenticate_user(email, password)
```

**Status**: ✅ Schemas complete, 🔄 CRUD in progress (Sprint 0-2)

### Content Context

**Responsibility**: Post, media, category, custom fields management

**Schemas**:
- `Post`: Medical articles with metadata
- `Media`: File attachments (images, PDFs)
- `Category`: Hierarchical taxonomy
- `CustomField`: Key-value extensible metadata

**Public API**:
```elixir
Content.list_posts()
Content.create_post(attrs)
Content.publish_post(post)
Content.upload_media(file)
```

**Status**: ✅ Schemas complete, ✅ Basic CRUD (14.29% coverage)

### Security Context

**Responsibility**: Zero Trust policy enforcement

**Modules**:
- `PolicyEngine`: GenServer decision point (74.75% coverage)
- `TrustAlgorithm`: 8-data-source scoring (85% coverage)
- `PolicyDecision`: Struct for decisions

**Public API**:
```elixir
PolicyEngine.evaluate(context)
TrustAlgorithm.calculate_score(context)
```

**Status**: ✅ Complete, operational since Sprint 0-1

---

## 🔌 Web Layer Architecture

### Phoenix Endpoint

**File**: `lib/healthcare_cms_web/endpoint.ex`

**Responsibilities**:
- HTTP server (Cowboy)
- Static file serving
- WebSocket upgrades
- Security headers (LGPD)

**Pipelines**:
```elixir
plug Plug.Static          # /assets, /images
plug Phoenix.LiveDashboard.RequestLogger
plug Plug.RequestId       # X-Request-ID
plug Plug.Telemetry       # Metrics
plug Plug.Parsers         # JSON body parsing
plug Plug.Session         # Session cookies
plug HealthcareCMSWeb.Router  # Route dispatch
```

### Router

**File**: `lib/healthcare_cms_web/router.ex`

**Pipelines**:
- `:browser` - HTML requests, CSRF protection
- `:api` - JSON API, Guardian JWT
- `:authenticated` - Requires login

**Routes** (Sprint 0-1):
```elixir
scope "/", HealthcareCMSWeb do
  pipe_through :browser
  
  get "/", PageController, :index        # Homepage
  get "/health", HealthController, :index # Health check JSON
end
```

---

## 🗄️ Database Layer

### Ecto Repository

**File**: `lib/healthcare_cms/repo.ex`

**Configuration**:
```elixir
config :healthcare_cms, HealthcareCMS.Repo,
  database: "healthcare_cms_dev.db",  # SQLite (dev)
  pool_size: 10,                      # Connection pool
  timeout: 60_000                     # 60s query timeout
```

**Multi-Tenant**: Tenant context injected via `put_dynamic_repo`

### Schemas

**Convention**: `lib/healthcare_cms/<context>/<schema>.ex`

**Example** (`User`):
```elixir
defmodule HealthcareCMS.Accounts.User do
  use Ecto.Schema
  
  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :role, Ecto.Enum, values: [:admin, :editor, :author]
    field :tenant_id, :binary_id  # Multi-tenant isolation
    field :verified_at, :naive_datetime
    
    timestamps()
  end
end
```

---

## 📊 File Count & LOC

```yaml
Total Files: ~45
Total LOC: ~2,800

Breakdown:
  lib/healthcare_cms/: ~1,200 LOC
  lib/healthcare_cms_web/: ~600 LOC
  test/: ~1,000 LOC
  config/: ~150 LOC
```

---

## 🔗 Related Documentation

- **Architecture Summary**: `../../architecture/_summary.md`
- **Dependency Matrix**: `../../dependencies/dependency-matrix.yaml`
- **Key Concepts**: `./key-concepts.md` (planned)
- **Main Workflows**: `./main-workflows.md` (planned)

---

**Version**: 1.0.0 | **Created**: 2025-09-30
