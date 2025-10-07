# Healthcare CMS - Database Schema Architecture

> **Level**: 2 (Core) | **Read Time**: 30min | **Tokens**: ~8K
> **Audience**: Database engineers, backend developers, DevOps
> **Last Validated**: 2025-09-30

---

## 📋 Overview

### Database Stack

```yaml
development:
  database: SQLite 3
  file: "healthcare_cms_dev.db"
  justification: "Fast local development, zero configuration"

production:
  database: PostgreSQL 16.6
  extensions:
    - TimescaleDB 2.17.2 (time-series data)
    - pgvector 0.8.0 (semantic search)
    - PostGIS 3.5.0 (geolocation)
    - pgaudit (compliance logging)
  justification: "ACID compliance, RLS, JSONB, Full-text search"
```

### Migrations

```
priv/repo/migrations/
├── 20250927145146_create_healthcare_foundation_tables.exs  (145 lines)
└── 20250927150616_create_wordpress_core_tables.exs         (166 lines)
```

**Total**: 2 migrations | 311 lines

---

## 🗄️ Schema Overview

### Entity Relationship Diagram

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Users   │────1:N──┤  Posts   │────N:1──┤Categories│
└──────────┘         └──────────┘         └──────────┘
     │                    │                      │
     │                    │                      │
     │                    ├────1:N───┐           │
     │                    │          │           │
     ▼                    ▼          ▼           ▼
┌──────────┐       ┌──────────┐  ┌──────────┐  (self-referencing)
│  Media   │       │ Custom   │  │  Post    │
│          │       │  Fields  │  │ Category │
└──────────┘       └──────────┘  └──────────┘
     │
     │
     ▼
┌──────────────┐
│ Workflow     │
│ States       │
└──────────────┘
         │
         ▼
┌──────────────┐
│ Audit Trail  │
└──────────────┘
```

### Tables Summary

| Table | Purpose | Rows (est.) | Growth Rate |
|-------|---------|-------------|-------------|
| `users` | Authentication, profiles | 10K | Low (monthly) |
| `posts` | Medical content | 100K | Medium (daily) |
| `categories` | Content taxonomy | 500 | Very low |
| `media` | Files, images, videos | 500K | High (daily) |
| `custom_fields` | ACF-style metadata | 500K | High (per post) |
| `workflow_states` | Medical workflows | 100K | Medium |
| `audit_trail` | Compliance logging | 10M+ | Very high (per request) |

---

## 👤 Users Table

### Schema Definition

```sql
CREATE TABLE users (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Authentication
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'subscriber',
  mfa_enabled BOOLEAN DEFAULT false,

  -- Healthcare Professional Data
  professional_registry VARCHAR(100),  -- e.g., "CRM/SP 123456"
  professional_type VARCHAR(50),       -- e.g., "medico", "psicologo"
  speciality VARCHAR(100),
  validated_at TIMESTAMP,

  -- Multi-Tenancy
  tenant_id UUID,

  -- Audit Trail
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  deleted_at TIMESTAMP,
  deleted_by UUID
);

-- Indexes
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_professional_registry ON users(professional_registry);
CREATE INDEX idx_users_role ON users(role);
```

### Key Features

**Multi-Tenancy Support**:
- `tenant_id` for tenant isolation
- Enforced via PostgreSQL RLS (Row-Level Security) in production

**Soft Delete**:
- `deleted_at` + `deleted_by` for LGPD compliance
- Preserves audit trail

**Professional Validation**:
- `professional_registry` indexed for fast CRM/CRP lookups
- `validated_at` tracks external verification timestamp

---

## 📄 Posts Table

### Schema Definition

```sql
CREATE TABLE posts (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Core WordPress Fields
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  content TEXT,
  excerpt TEXT,
  status VARCHAR(20) DEFAULT 'draft',

  -- WordPress Meta
  post_type VARCHAR(30) DEFAULT 'post',
  comment_status VARCHAR(10) DEFAULT 'open',
  ping_status VARCHAR(10) DEFAULT 'open',

  -- SEO
  meta_description VARCHAR(160),
  meta_keywords VARCHAR(255),

  -- Healthcare Specific
  medical_category VARCHAR(30),
  compliance_level VARCHAR(20),
  requires_crm_validation BOOLEAN DEFAULT false,
  medical_disclaimer TEXT,

  -- Publication
  published_at TIMESTAMP,
  scheduled_at TIMESTAMP,

  -- Audit
  version INTEGER DEFAULT 1,
  deleted_at TIMESTAMP,

  -- Foreign Keys
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  tenant_id UUID,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX posts_slug_tenant_id_index
  ON posts(slug, tenant_id);
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_category_id ON posts(category_id);
CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_post_type ON posts(post_type);
CREATE INDEX idx_posts_published_at ON posts(published_at DESC);
CREATE INDEX idx_posts_tenant_id ON posts(tenant_id);
CREATE INDEX idx_posts_medical_category ON posts(medical_category);
CREATE INDEX idx_posts_compliance_level ON posts(compliance_level);
```

### Key Features

**Slug Uniqueness per Tenant**:
```sql
CREATE UNIQUE INDEX posts_slug_tenant_id_index
  ON posts(slug, tenant_id);
```

**WordPress Compatibility**:
- `post_type` supports: `post`, `page`, custom types
- `comment_status`, `ping_status` for WordPress ecosystem integration

**Healthcare Extensions**:
- `medical_category`: 10 predefined medical categories
- `compliance_level`: `:public`, `:professional`, `:restricted`, `:phi`
- `requires_crm_validation`: Auto-set by changeset for medical content
- `medical_disclaimer`: Required for professional/restricted content

**Performance Optimizations**:
- Descending index on `published_at` (newest first queries)
- Compound index on `(slug, tenant_id)` for fast slug lookups

---

## 🏷️ Categories Table

### Schema Definition

```sql
CREATE TABLE categories (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Core Fields
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  description TEXT,
  count INTEGER DEFAULT 0,  -- Post count

  -- Hierarchy Support
  parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  level INTEGER DEFAULT 0,  -- 0 = root, 1 = child, etc.

  -- Healthcare Specific
  medical_specialty VARCHAR(50),
  compliance_required BOOLEAN DEFAULT false,
  crm_validation_required BOOLEAN DEFAULT false,

  -- Multi-Tenancy
  tenant_id UUID,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX categories_slug_tenant_id_index
  ON categories(slug, tenant_id);
CREATE UNIQUE INDEX categories_name_tenant_id_index
  ON categories(name, tenant_id);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_tenant_id ON categories(tenant_id);
CREATE INDEX idx_categories_medical_specialty ON categories(medical_specialty);
```

### Key Features

**Hierarchical Categories**:
```sql
parent_id → categories(id)  -- Self-referencing foreign key
level     → 0 (root), 1 (child), 2 (grandchild), etc.
```

**Example Query - Get Category Tree**:
```sql
-- Get all categories with their children (1 level deep)
WITH RECURSIVE category_tree AS (
  -- Root categories
  SELECT id, name, slug, parent_id, level, 0 as depth
  FROM categories
  WHERE parent_id IS NULL AND tenant_id = $1

  UNION ALL

  -- Children
  SELECT c.id, c.name, c.slug, c.parent_id, c.level, ct.depth + 1
  FROM categories c
  INNER JOIN category_tree ct ON c.parent_id = ct.id
  WHERE ct.depth < 2  -- Limit depth
)
SELECT * FROM category_tree ORDER BY depth, name;
```

**Post Counter**:
- `count` tracks number of posts in category
- Updated via `increment_count/1` and `decrement_count/1`

---

## 🖼️ Media Table

### Schema Definition

```sql
CREATE TABLE media (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- File Information
  title VARCHAR(255),
  filename VARCHAR(255) NOT NULL,
  original_filename VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  file_size BIGINT NOT NULL,  -- bytes
  file_path VARCHAR(500),
  url VARCHAR(500),

  -- Image Metadata
  width INTEGER,
  height INTEGER,
  alt_text VARCHAR(255),
  caption TEXT,
  description TEXT,

  -- WordPress Compatibility
  attachment_type VARCHAR(20),  -- image, video, document, audio

  -- Healthcare Specific
  medical_content BOOLEAN DEFAULT false,
  contains_phi BOOLEAN DEFAULT false,
  dicom_metadata TEXT,  -- JSON for DICOM medical images
  encryption_status VARCHAR(20) DEFAULT 'none',

  -- Access Control
  access_level VARCHAR(20),
  requires_crm_validation BOOLEAN DEFAULT false,

  -- Foreign Keys
  uploaded_by_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  tenant_id UUID,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX idx_media_filename ON media(filename);
CREATE INDEX idx_media_uploaded_by_id ON media(uploaded_by_id);
CREATE INDEX idx_media_post_id ON media(post_id);
CREATE INDEX idx_media_mime_type ON media(mime_type);
CREATE INDEX idx_media_attachment_type ON media(attachment_type);
CREATE INDEX idx_media_medical_content ON media(medical_content);
CREATE INDEX idx_media_contains_phi ON media(contains_phi);
CREATE INDEX idx_media_tenant_id ON media(tenant_id);
```

### Key Features

**PHI/PII Protection**:
- `contains_phi` flag for medical images (X-rays, lab results)
- `encryption_status` tracks encryption state (`:none`, `:at_rest`, `:in_transit`, `:both`)
- `access_level` determines who can access (`:public`, `:professional`, `:restricted`)

**DICOM Support** (Planned - Sprint 2):
- `dicom_metadata` stores JSON with DICOM tags
- Integration with `ex_dicom` library for medical imaging

**File Size Tracking**:
- `file_size` in bytes for quota management
- Useful for tenant billing and storage limits

---

## 🔧 Custom Fields Table

### Schema Definition

```sql
CREATE TABLE custom_fields (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- ACF-Style Fields
  meta_key VARCHAR(100) NOT NULL,
  meta_value TEXT,
  meta_type VARCHAR(20) DEFAULT 'text',

  -- Healthcare Specific
  medical_significance VARCHAR(20) DEFAULT 'none',  -- low, medium, high, critical
  requires_validation BOOLEAN DEFAULT false,
  validation_rules TEXT,  -- JSON
  is_phi BOOLEAN DEFAULT false,

  -- ACF Compatibility
  field_group VARCHAR(100),
  field_order INTEGER DEFAULT 0,
  is_required BOOLEAN DEFAULT false,

  -- Foreign Keys
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  tenant_id UUID,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX custom_fields_post_meta_key_index
  ON custom_fields(post_id, meta_key);
CREATE INDEX idx_custom_fields_meta_key ON custom_fields(meta_key);
CREATE INDEX idx_custom_fields_meta_type ON custom_fields(meta_type);
CREATE INDEX idx_custom_fields_field_group ON custom_fields(field_group);
CREATE INDEX idx_custom_fields_medical_significance ON custom_fields(medical_significance);
CREATE INDEX idx_custom_fields_is_phi ON custom_fields(is_phi);
CREATE INDEX idx_custom_fields_tenant_id ON custom_fields(tenant_id);
```

### Key Features

**Upsert-Friendly**:
```sql
CONSTRAINT custom_fields_post_meta_key_index
  UNIQUE(post_id, meta_key)
```
- Prevents duplicate keys per post
- Enables `ON CONFLICT DO UPDATE` upsert pattern

**Medical Metadata**:
```elixir
# Example medical custom fields
Content.update_custom_field(post_id, "evidence_level", "1")  # Systematic review
Content.update_custom_field(post_id, "author_crm", "CRM/SP 123456")
Content.update_custom_field(post_id, "peer_reviewed", "true")
Content.update_custom_field(post_id, "citations_count", "15")
```

**PHI Tracking**:
- `is_phi` flag for fields containing PHI (e.g., patient case studies)
- Triggers encryption requirements

---

## 🔄 Workflow States Table

### Schema Definition

```sql
CREATE TABLE workflow_states (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- References
  content_id UUID NOT NULL,

  -- Workflow Stage
  current_stage VARCHAR(50) DEFAULT 'draft',  -- S.1.1, S.2.1, S.3.1, S.4-1.1-3

  -- Healthcare Workflow Data
  lgpd_score INTEGER,  -- 0-100 compliance score
  medical_claims JSONB DEFAULT '{}',
  scientific_references JSONB DEFAULT '{}',
  compliance_validations JSONB DEFAULT '{}',

  -- Multi-Tenancy
  tenant_id UUID NOT NULL,

  -- Timestamps
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Indexes
CREATE INDEX idx_workflow_states_content_id ON workflow_states(content_id);
CREATE INDEX idx_workflow_states_tenant_id ON workflow_states(tenant_id);
CREATE INDEX idx_workflow_states_current_stage ON workflow_states(current_stage);
```

### Key Features

**Medical Workflows** (See key-concepts.md):
```
S.1.1 → Content Creation (draft)
S.2.1 → LGPD Analyzer (PHI/PII detection)
S.3.1 → Medical Claims Extractor (evidence validation)
S.4-1.1-3 → CFM Compliance Validator (final approval)
```

**JSONB Storage**:
```json
{
  "medical_claims": {
    "claim_1": {
      "text": "Drug X reduces mortality by 30%",
      "evidence_level": "1",
      "reference": "PMID:12345678",
      "validated": true
    }
  },
  "scientific_references": [
    {
      "type": "pubmed",
      "id": "12345678",
      "title": "Meta-analysis of Drug X efficacy"
    }
  ],
  "compliance_validations": {
    "lgpd_check": "passed",
    "cfm_check": "passed",
    "anvisa_check": "passed"
  }
}
```

---

## 📋 Audit Trail Table

### Schema Definition

```sql
CREATE TABLE audit_trail (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Operation Details
  operation VARCHAR(50) NOT NULL,      -- create, read, update, delete, access
  resource_type VARCHAR(50) NOT NULL,  -- post, user, media, etc.
  resource_id UUID NOT NULL,

  -- Actor Information
  tenant_id UUID NOT NULL,
  user_id UUID NOT NULL,

  -- Metadata
  metadata JSONB DEFAULT '{}',

  -- Zero Trust Integration
  trust_score INTEGER,
  policy_decision VARCHAR(50),

  -- Timestamp
  created_at TIMESTAMP NOT NULL
);

-- Indexes
CREATE INDEX idx_audit_trail_tenant_id ON audit_trail(tenant_id);
CREATE INDEX idx_audit_trail_user_id ON audit_trail(user_id);
CREATE INDEX idx_audit_trail_resource_type ON audit_trail(resource_type);
CREATE INDEX idx_audit_trail_created_at ON audit_trail(created_at);
```

### Key Features

**Immutable Log**:
- No `updated_at` or `deleted_at` columns
- Append-only table for compliance
- No foreign key constraints (preserve history even after resource deletion)

**Zero Trust Integration**:
```elixir
audit_data = %{
  operation: "read",
  resource_type: "post",
  resource_id: post_id,
  tenant_id: user.tenant_id,
  user_id: user.id,
  metadata: %{
    ip_address: "203.0.113.42",
    user_agent: "Mozilla/5.0...",
    access_level: :full_access
  },
  trust_score: 95,
  policy_decision: "allow"
}

Repo.insert(%AuditTrail{} |> AuditTrail.changeset(audit_data))
```

**Retention Policy** (LGPD Art. 16):
- Keep for 5 years (LGPD requirement)
- Keep for 6 years (HIPAA requirement) if handling US patients
- Archive to cold storage after 1 year

---

## 🔒 Multi-Tenancy (PostgreSQL RLS)

### Row-Level Security Implementation

**Enable RLS on All Tables**:
```sql
-- Posts table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_posts ON posts
  FOR ALL
  USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_users ON users
  FOR ALL
  USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Repeat for categories, media, custom_fields, workflow_states
```

**Set Tenant Context** (Phoenix Plug):
```elixir
defmodule HealthcareCMSWeb.Plugs.AssignTenant do
  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.tenant_id do
      # Set PostgreSQL session variable
      Repo.query!("SET app.tenant_id = $1", [user.tenant_id])

      assign(conn, :tenant_id, user.tenant_id)
    else
      conn
    end
  end
end
```

**Admin Blind Architecture**:
- Admin users have `tenant_id = NULL`
- RLS blocks all tenant data queries for admins
- Emergency access requires explicit tenant consent + audit log

---

## 📊 Indexing Strategy

### Index Types

**B-Tree Indexes** (Default):
```sql
CREATE INDEX idx_posts_status ON posts(status);  -- Equality, range queries
CREATE INDEX idx_users_email ON users(email);    -- Equality
```

**Unique Indexes**:
```sql
CREATE UNIQUE INDEX posts_slug_tenant_id_index ON posts(slug, tenant_id);
```

**Compound Indexes**:
```sql
CREATE INDEX idx_posts_tenant_status
  ON posts(tenant_id, status, published_at DESC);
-- Optimizes: WHERE tenant_id = X AND status = 'published' ORDER BY published_at DESC
```

**Partial Indexes** (PostgreSQL-only):
```sql
CREATE INDEX idx_posts_published
  ON posts(published_at DESC)
  WHERE status = 'published' AND deleted_at IS NULL;
-- Smaller index, faster queries for published posts
```

---

### Index Coverage Analysis

**Hot Queries** (Most Frequent):
1. **List published posts by tenant**:
   ```sql
   SELECT * FROM posts
   WHERE tenant_id = $1 AND status = 'published'
   ORDER BY published_at DESC LIMIT 10;
   ```
   **Index**: `idx_posts_tenant_status (tenant_id, status, published_at DESC)`

2. **Get post by slug**:
   ```sql
   SELECT * FROM posts
   WHERE slug = $1 AND tenant_id = $2 AND status = 'published';
   ```
   **Index**: `posts_slug_tenant_id_index (slug, tenant_id)`

3. **Get user by email**:
   ```sql
   SELECT * FROM users WHERE email = $1;
   ```
   **Index**: `idx_users_email (email)` - UNIQUE

4. **Audit trail by user and time range**:
   ```sql
   SELECT * FROM audit_trail
   WHERE user_id = $1 AND created_at BETWEEN $2 AND $3;
   ```
   **Index**: `idx_audit_trail_user_created (user_id, created_at)`

---

## 🚀 Performance Optimizations

### Prepared Statements

**Ecto automatically uses prepared statements**:
```elixir
# This query is prepared on first execution, reused after
Repo.all(
  from p in Post,
  where: p.tenant_id == ^tenant_id and p.status == :published,
  order_by: [desc: p.published_at],
  limit: ^limit
)
```

**Disable for one-off queries**:
```elixir
Repo.all(query, prepare: :unnamed)
```

---

### Connection Pooling

**DBConnection Configuration**:
```elixir
# config/config.exs
config :healthcare_cms, HealthcareCMS.Repo,
  pool_size: 10,
  queue_target: 50,      # Queue time before increasing pool
  queue_interval: 1000   # Check interval
```

**Pool Size Calculation**:
```
pool_size = (cpu_cores * 2) + disk_spindles
# Example: 4 cores + 1 SSD = 10
```

---

### Query Optimization Tips

**1. Avoid N+1 Queries**:
```elixir
# ❌ BAD - N+1 queries
posts = Repo.all(Post)
Enum.each(posts, fn post ->
  author = Repo.get(User, post.author_id)  # N queries!
end)

# ✅ GOOD - Preload
posts = Repo.all(Post) |> Repo.preload(:author)  # 2 queries total
```

**2. Use `select` to Limit Columns**:
```elixir
# ❌ BAD - Fetches all columns
Repo.all(from p in Post, where: p.status == :published)

# ✅ GOOD - Only needed columns
Repo.all(
  from p in Post,
  where: p.status == :published,
  select: [:id, :title, :slug, :published_at]
)
```

**3. Use `EXPLAIN ANALYZE`**:
```sql
EXPLAIN ANALYZE
SELECT * FROM posts
WHERE tenant_id = 'uuid' AND status = 'published'
ORDER BY published_at DESC LIMIT 10;
```

---

## 🗂️ Migration Management

### Migration Best Practices

**1. Reversible Migrations**:
```elixir
def change do
  create table(:posts) do
    add :title, :string, null: false
    # ...
  end

  create index(:posts, [:status])
end
# Automatically generates `up` and `down` functions
```

**2. Irreversible Migrations** (use `up/down`):
```elixir
def up do
  execute "ALTER TABLE posts ADD COLUMN search_vector tsvector"
  execute "CREATE INDEX idx_posts_search ON posts USING GIN(search_vector)"
end

def down do
  execute "DROP INDEX idx_posts_search"
  execute "ALTER TABLE posts DROP COLUMN search_vector"
end
```

**3. Data Migrations** (separate file):
```elixir
# priv/repo/migrations/20250930_migrate_post_slugs.exs
def change do
  # Run in transaction
  Repo.transaction(fn ->
    Repo.all(Post)
    |> Enum.each(fn post ->
      if is_nil(post.slug) do
        slug = generate_slug(post.title)
        Post.changeset(post, %{slug: slug}) |> Repo.update!()
      end
    end)
  end)
end
```

---

## 🔗 Related Documentation

- **Accounts Context**: `../contexts/accounts-context.md`
- **Content Context**: `../contexts/content-context.md`
- **Security / Zero Trust**: `../security/zero-trust-implementation.md`
- **Multi-Tenant Design**: `../../architecture/decisions-adr/004-multi-tenant-design.md`
- **Technology Stack**: `../../layer-1-overview/technology-stack.md`

---

## 🚧 Roadmap

### Sprint 1 (Current)
- [x] Core schema design (users, posts, categories)
- [x] Multi-tenancy support (tenant_id columns)
- [ ] PostgreSQL RLS policies implementation
- [ ] Index optimization analysis

### Sprint 2
- [ ] TimescaleDB hypertables (audit_trail time-series)
- [ ] pgvector for semantic search (embeddings)
- [ ] Full-text search (tsvector, tsquery)
- [ ] Automated backups (pg_dump cron)

### Sprint 3+
- [ ] Read replicas (PostgreSQL streaming replication)
- [ ] Partitioning (audit_trail by month)
- [ ] Database monitoring (pg_stat_statements)
- [ ] Query performance profiling

---

**Version**: 1.0.0 | **Created**: 2025-09-30 | **Status**: 🔄 Active Development
