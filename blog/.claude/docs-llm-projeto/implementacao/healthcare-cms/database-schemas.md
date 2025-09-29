# 🗄️ Database Schemas - Healthcare CMS

<!-- DSM:DOMAIN:data_layer|healthcare_cms COMPLEXITY:expert DEPS:postgresql_timescaledb -->
<!-- DSM:HEALTHCARE:database_design|wordpress_parity PERFORMANCE:queries:<10ms -->
<!-- DSM:COMPLIANCE:LGPD|CFM|ANVISA|audit_trail_requirements -->

## 🧩 DSM Database Matrix
```yaml
DSM_DATABASE_MATRIX:
  depends_on:
    - postgresql_16_core_engine
    - timescaledb_healthcare_audit
    - ecto_elixir_orm_layer
    - zero_trust_field_encryption
  provides_to:
    - wordpress_core_features
    - acf_custom_fields_system
    - healthcare_compliance_engine
    - medical_workflow_pipeline
  integrates_with:
    - multi_tenant_architecture
    - admin_blind_encryption
    - audit_trail_immutable
    - backup_disaster_recovery
  performance_contracts:
    - query_response_time: "<10ms average for CMS operations"
    - concurrent_connections: "2M+ healthcare professionals supported"
    - audit_retention: "7 years healthcare data (TimescaleDB)"
    - backup_rto: "<4 hours recovery time objective"
  compliance_requirements:
    - lgpd_data_protection: "Field-level encryption for PHI/PII"
    - cfm_professional_validation: "Medical professional registry integration"
    - anvisa_audit_trail: "Immutable audit trail for medical device compliance"
    - hipaa_technical_safeguards: "Administrative blind access controls"
```

## Visão Geral da Arquitetura de Dados

O Healthcare CMS utiliza uma **arquitetura de dados híbrida** com **PostgreSQL 16** para operações CMS e **TimescaleDB** para audit trails healthcare, garantindo **100% compatibilidade WordPress** com extensões de compliance médico.

### Estratégia de Banco de Dados
```yaml
# DSM:DATABASE:hybrid_strategy WORDPRESS_PARITY_HEALTHCARE
Database_Strategy:
  development:
    primary: "SQLite (fast local development)"
    benefits: "Zero setup, file-based, perfect for testing"

  production:
    primary: "PostgreSQL 16 (enterprise grade)"
    timescale: "TimescaleDB extension for healthcare audit trails"
    benefits: "ACID compliance, JSON support, horizontal scaling"

  compliance_layer:
    encryption: "Field-level encryption per tenant (admin blind)"
    audit_trail: "Immutable time-series data (7-year retention)"
    backup_strategy: "Multi-region with healthcare compliance"
```

---

## 📋 WordPress Core Tables (WP-F001 a WP-F010)

### **1. Users & Authentication**
```sql
-- DSM:TABLE:users_authentication WP_F005_USER_MANAGEMENT
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  encrypted_password VARCHAR(255) NOT NULL,

  -- WordPress parity fields
  username VARCHAR(60) UNIQUE NOT NULL,
  display_name VARCHAR(250) NOT NULL DEFAULT '',
  user_nicename VARCHAR(50) NOT NULL DEFAULT '',
  user_url VARCHAR(100) NOT NULL DEFAULT '',
  user_status INTEGER NOT NULL DEFAULT 0,

  -- Healthcare extensions
  professional_registry VARCHAR(20), -- CRM/CRP number
  professional_type VARCHAR(50),     -- médico, nutricionista, psicólogo
  specialty VARCHAR(100),            -- especialidade médica
  license_state VARCHAR(2),          -- estado do registro profissional
  license_verified BOOLEAN DEFAULT FALSE,
  license_verified_at TIMESTAMP,

  -- LGPD compliance
  consent_marketing BOOLEAN DEFAULT FALSE,
  consent_data_processing BOOLEAN NOT NULL DEFAULT TRUE,
  consent_given_at TIMESTAMP NOT NULL DEFAULT NOW(),
  data_retention_until TIMESTAMP,

  -- Zero Trust scoring
  trust_score INTEGER DEFAULT 50,    -- 0-100 trust algorithm
  last_trust_evaluation TIMESTAMP,
  device_fingerprint JSONB,

  -- Audit & compliance
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMP,
  failed_login_attempts INTEGER DEFAULT 0,
  account_locked_until TIMESTAMP
);

-- Performance indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_professional_registry ON users(professional_registry);
CREATE INDEX idx_users_trust_score ON users(trust_score);
CREATE INDEX idx_users_created_at ON users(created_at);

-- LGPD compliance indexes
CREATE INDEX idx_users_consent_data_processing ON users(consent_data_processing);
CREATE INDEX idx_users_data_retention ON users(data_retention_until);
```

### **2. User Metadata & Capabilities**
```sql
-- DSM:TABLE:user_metadata WP_F005_ROLES_CAPABILITIES
CREATE TABLE user_meta (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  meta_key VARCHAR(255) NOT NULL,
  meta_value TEXT,

  -- Healthcare-specific metadata encryption
  encrypted_value BYTEA,              -- Field-level encryption for PHI
  encryption_key_id VARCHAR(50),      -- Key reference for admin blind

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_meta_user_id ON user_meta(user_id);
CREATE INDEX idx_user_meta_key ON user_meta(meta_key);
CREATE INDEX idx_user_meta_key_value ON user_meta(meta_key, meta_value(50));

-- WordPress capability system
CREATE TABLE user_roles (
  id BIGSERIAL PRIMARY KEY,
  role_name VARCHAR(50) UNIQUE NOT NULL,
  capabilities JSONB NOT NULL,

  -- Healthcare role extensions
  medical_scope JSONB,               -- Permitted medical content types
  compliance_level VARCHAR(20),      -- basic, professional, admin
  audit_required BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Default healthcare roles
INSERT INTO user_roles (role_name, capabilities, medical_scope, compliance_level) VALUES
('medical_professional', '{"read": true, "edit_posts": true, "publish_posts": true}',
 '{"content_types": ["medical_article", "patient_education"], "review_required": true}', 'professional'),
('content_reviewer', '{"read": true, "edit_others_posts": true, "approve_medical_content": true}',
 '{"content_types": ["all"], "final_approval": true}', 'professional'),
('compliance_officer', '{"read": true, "view_audit_trail": true, "manage_compliance": true}',
 '{"content_types": ["all"], "compliance_oversight": true}', 'admin');
```

### **3. Posts & Content Management**
```sql
-- DSM:TABLE:posts_content WP_F002_F003_POSTS_PAGES
CREATE TABLE posts (
  id BIGSERIAL PRIMARY KEY,
  author_id BIGINT NOT NULL REFERENCES users(id),

  -- WordPress core fields
  post_date TIMESTAMP NOT NULL DEFAULT NOW(),
  post_date_gmt TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
  post_content TEXT NOT NULL DEFAULT '',
  post_title TEXT NOT NULL DEFAULT '',
  post_excerpt TEXT NOT NULL DEFAULT '',
  post_status VARCHAR(20) NOT NULL DEFAULT 'draft',
  comment_status VARCHAR(20) NOT NULL DEFAULT 'open',
  ping_status VARCHAR(20) NOT NULL DEFAULT 'open',
  post_password VARCHAR(255) NOT NULL DEFAULT '',
  post_name VARCHAR(200) NOT NULL DEFAULT '',
  to_ping TEXT NOT NULL DEFAULT '',
  pinged TEXT NOT NULL DEFAULT '',
  post_modified TIMESTAMP NOT NULL DEFAULT NOW(),
  post_modified_gmt TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
  post_content_filtered LONGTEXT NOT NULL DEFAULT '',
  post_parent BIGINT DEFAULT 0,
  guid VARCHAR(255) NOT NULL DEFAULT '',
  menu_order INTEGER NOT NULL DEFAULT 0,
  post_type VARCHAR(20) NOT NULL DEFAULT 'post',
  post_mime_type VARCHAR(100) NOT NULL DEFAULT '',
  comment_count BIGINT NOT NULL DEFAULT 0,

  -- Healthcare extensions
  medical_content BOOLEAN DEFAULT FALSE,
  medical_disclaimer TEXT,
  evidence_level VARCHAR(20),         -- I, II, III, IV (evidence-based medicine)
  scientific_references JSONB,
  professional_review_required BOOLEAN DEFAULT FALSE,
  professional_reviewer_id BIGINT REFERENCES users(id),
  medical_approval_status VARCHAR(20) DEFAULT 'pending',
  medical_approved_at TIMESTAMP,

  -- LGPD compliance for content
  contains_patient_data BOOLEAN DEFAULT FALSE,
  anonymization_applied BOOLEAN DEFAULT FALSE,
  consent_for_publication BOOLEAN DEFAULT FALSE,

  -- SEO & healthcare optimization
  seo_title VARCHAR(160),
  seo_description VARCHAR(320),
  medical_keywords JSONB,
  target_audience VARCHAR(50),        -- professionals, patients, general

  -- Audit & versioning
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  version_number INTEGER DEFAULT 1,
  last_editor_id BIGINT REFERENCES users(id)
);

-- Performance indexes
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_post_date ON posts(post_date);
CREATE INDEX idx_posts_post_status ON posts(post_status);
CREATE INDEX idx_posts_post_type ON posts(post_type);
CREATE INDEX idx_posts_post_name ON posts(post_name);

-- Healthcare-specific indexes
CREATE INDEX idx_posts_medical_content ON posts(medical_content);
CREATE INDEX idx_posts_medical_approval ON posts(medical_approval_status);
CREATE INDEX idx_posts_professional_review ON posts(professional_review_required);
CREATE INDEX idx_posts_evidence_level ON posts(evidence_level);
```

### **4. Post Metadata & Custom Fields**
```sql
-- DSM:TABLE:post_metadata ACF_F001_to_ACF_F006
CREATE TABLE post_meta (
  id BIGSERIAL PRIMARY KEY,
  post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  meta_key VARCHAR(255) NOT NULL,
  meta_value LONGTEXT,

  -- ACF enhancements
  field_type VARCHAR(50),             -- text, textarea, number, select, repeater, etc.
  field_group_id BIGINT,             -- Reference to field group
  field_order INTEGER DEFAULT 0,

  -- Healthcare field encryption
  encrypted_value BYTEA,              -- For sensitive medical data
  encryption_key_id VARCHAR(50),

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_post_meta_post_id ON post_meta(post_id);
CREATE INDEX idx_post_meta_key ON post_meta(meta_key);
CREATE INDEX idx_post_meta_key_value ON post_meta(meta_key, meta_value(50));

-- ACF Field Groups (replaces ACF plugin functionality)
CREATE TABLE custom_field_groups (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  key VARCHAR(255) UNIQUE NOT NULL,   -- acf_field_group_key
  fields JSONB NOT NULL,              -- Complete field configuration
  location_rules JSONB NOT NULL,      -- Where to show (post types, templates, etc.)

  -- Healthcare field group extensions
  medical_context BOOLEAN DEFAULT FALSE,
  compliance_level VARCHAR(20),       -- basic, professional, sensitive
  audit_changes BOOLEAN DEFAULT TRUE,

  -- WordPress parity
  menu_order INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Default healthcare field groups
INSERT INTO custom_field_groups (title, key, fields, location_rules, medical_context, compliance_level) VALUES
('Medical Article Fields', 'group_medical_article',
 '[{"key": "field_evidence_level", "label": "Evidence Level", "type": "select", "choices": {"I": "Level I - RCT", "II": "Level II - Cohort", "III": "Level III - Case-control", "IV": "Level IV - Case series"}}]',
 '[{"param": "post_type", "operator": "==", "value": "medical_article"}]',
 true, 'professional');
```

---

## 🏥 Healthcare Extensions Tables (HL-F001 a HL-F010)

### **5. Medical Professional Validation**
```sql
-- DSM:TABLE:medical_professionals HL_F001_PROFESSIONAL_VALIDATION
CREATE TABLE medical_professionals (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Professional registry validation
  registry_type VARCHAR(10) NOT NULL, -- CRM, CRP, CRMV, etc.
  registry_number VARCHAR(20) NOT NULL,
  registry_state VARCHAR(2) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  specialty VARCHAR(100),
  subspecialty VARCHAR(100),

  -- Validation status
  validation_status VARCHAR(20) DEFAULT 'pending', -- pending, verified, expired, revoked
  validated_at TIMESTAMP,
  expires_at TIMESTAMP,
  last_validation_check TIMESTAMP,

  -- External validation data
  external_validation_response JSONB,
  validation_api_used VARCHAR(50),    -- CFM API, CRP API, etc.

  -- Professional profile
  institution VARCHAR(255),
  position VARCHAR(100),
  bio TEXT,
  profile_photo_url VARCHAR(500),
  website VARCHAR(255),

  -- Content approval permissions
  can_approve_medical_content BOOLEAN DEFAULT FALSE,
  approval_scope JSONB,              -- Types of content they can approve

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_medical_professionals_registry ON medical_professionals(registry_type, registry_number, registry_state);
CREATE INDEX idx_medical_professionals_validation_status ON medical_professionals(validation_status);
CREATE INDEX idx_medical_professionals_expires_at ON medical_professionals(expires_at);
```

### **6. Medical Workflow Pipeline**
```sql
-- DSM:TABLE:medical_workflows HL_F002_WORKFLOW_INTEGRATION
CREATE TABLE medical_workflow_executions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),

  -- Workflow identification
  workflow_type VARCHAR(50) NOT NULL, -- s1_1_lgpd, s1_2_claims, etc.
  execution_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

  -- Input/Output data
  input_data JSONB NOT NULL,
  output_data JSONB,
  intermediate_data JSONB,            -- Data between systems

  -- Execution status
  status VARCHAR(20) DEFAULT 'pending', -- pending, running, completed, failed
  current_system VARCHAR(10),         -- S.1.1, S.1.2, S.2-1.2, S.3-2, S.4-1.1-3
  progress_percentage INTEGER DEFAULT 0,

  -- Performance metrics
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  total_execution_time_ms INTEGER,
  system_execution_times JSONB,      -- Time per system

  -- Error handling
  error_message TEXT,
  error_system VARCHAR(10),
  retry_count INTEGER DEFAULT 0,

  -- Compliance tracking
  lgpd_analysis_result JSONB,
  medical_claims_identified JSONB,
  scientific_references_found JSONB,

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_workflow_executions_user_id ON medical_workflow_executions(user_id);
CREATE INDEX idx_workflow_executions_status ON medical_workflow_executions(status);
CREATE INDEX idx_workflow_executions_workflow_type ON medical_workflow_executions(workflow_type);
CREATE INDEX idx_workflow_executions_created_at ON medical_workflow_executions(created_at);
```

---

## 🛡️ Security & Compliance Tables (SEC-F001 a SEC-F008)

### **7. Zero Trust Policy Engine**
```sql
-- DSM:TABLE:zero_trust_policies SEC_F001_SEC_F002_ZERO_TRUST
CREATE TABLE zero_trust_policies (
  id BIGSERIAL PRIMARY KEY,
  policy_name VARCHAR(100) UNIQUE NOT NULL,
  policy_type VARCHAR(50) NOT NULL,   -- user, device, resource, medical_context

  -- Policy configuration
  conditions JSONB NOT NULL,          -- Conditions for policy evaluation
  actions JSONB NOT NULL,             -- Actions when policy matches
  priority INTEGER DEFAULT 100,
  active BOOLEAN DEFAULT TRUE,

  -- Healthcare-specific policies
  medical_context_required BOOLEAN DEFAULT FALSE,
  minimum_trust_score INTEGER DEFAULT 50,
  professional_validation_required BOOLEAN DEFAULT FALSE,

  -- Policy effectiveness
  evaluation_count BIGINT DEFAULT 0,
  allow_count BIGINT DEFAULT 0,
  deny_count BIGINT DEFAULT 0,
  last_evaluation TIMESTAMP,

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Policy evaluation logs
CREATE TABLE zero_trust_evaluations (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id),
  policy_id BIGINT NOT NULL REFERENCES zero_trust_policies(id),

  -- Evaluation context
  resource_requested VARCHAR(255),
  action_requested VARCHAR(50),
  device_info JSONB,
  location_info JSONB,

  -- Evaluation result
  decision VARCHAR(10) NOT NULL,      -- allow, deny, conditional
  trust_score_at_evaluation INTEGER,
  risk_factors JSONB,

  -- Performance
  evaluation_time_ms INTEGER,

  evaluated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_zt_evaluations_user_id ON zero_trust_evaluations(user_id);
CREATE INDEX idx_zt_evaluations_decision ON zero_trust_evaluations(decision);
CREATE INDEX idx_zt_evaluations_evaluated_at ON zero_trust_evaluations(evaluated_at);
```

### **8. Multi-Tenant Admin Blind**
```sql
-- DSM:TABLE:tenant_encryption SEC_F004_ADMIN_BLIND
CREATE TABLE tenant_encryption_keys (
  id BIGSERIAL PRIMARY KEY,
  tenant_id VARCHAR(50) NOT NULL,     -- Organization identifier
  key_purpose VARCHAR(50) NOT NULL,   -- field_encryption, backup, communication

  -- Key management
  key_id VARCHAR(100) UNIQUE NOT NULL,
  key_version INTEGER DEFAULT 1,
  encryption_algorithm VARCHAR(50) DEFAULT 'AES-256-GCM',

  -- Key lifecycle
  status VARCHAR(20) DEFAULT 'active', -- active, rotating, revoked
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  activated_at TIMESTAMP,
  expires_at TIMESTAMP,
  rotated_to_key_id VARCHAR(100),

  -- Healthcare compliance
  purpose_description TEXT,
  compliance_requirements JSONB,      -- LGPD, HIPAA requirements

  -- Admin blind enforcement
  admin_accessible BOOLEAN DEFAULT FALSE,
  emergency_access_protocol JSONB
);

CREATE INDEX idx_tenant_keys_tenant_id ON tenant_encryption_keys(tenant_id);
CREATE INDEX idx_tenant_keys_status ON tenant_encryption_keys(status);
CREATE INDEX idx_tenant_keys_expires_at ON tenant_encryption_keys(expires_at);
```

---

## ⏰ TimescaleDB Audit Trail (LGPD/ANVISA Compliance)

### **9. Immutable Audit Trail**
```sql
-- DSM:TABLE:audit_trail_timescale HL_F004_AUDIT_IMMUTABLE
-- This table uses TimescaleDB for time-series data optimization
CREATE TABLE audit_trail (
  id BIGSERIAL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Event identification
  event_type VARCHAR(50) NOT NULL,    -- login, content_access, data_modification, etc.
  resource_type VARCHAR(50),          -- user, post, patient_data, etc.
  resource_id BIGINT,

  -- Actor information
  actor_id BIGINT REFERENCES users(id),
  actor_ip INET,
  actor_user_agent TEXT,
  actor_device_fingerprint JSONB,

  -- Event details
  action VARCHAR(100) NOT NULL,       -- CREATE, READ, UPDATE, DELETE, APPROVE, etc.
  event_data JSONB,                   -- Detailed event information
  before_state JSONB,                 -- State before change
  after_state JSONB,                  -- State after change

  -- Compliance tracking
  lgpd_basis VARCHAR(50),             -- Legal basis for data processing
  consent_reference VARCHAR(100),     -- Reference to consent record
  data_subject_id BIGINT,             -- Patient/user whose data was accessed

  -- Risk assessment
  risk_level VARCHAR(20) DEFAULT 'low', -- low, medium, high, critical
  automated_flags JSONB,              -- Automated compliance/security flags

  -- Immutability guarantee
  record_hash VARCHAR(64),            -- SHA-256 hash for integrity verification
  previous_record_hash VARCHAR(64),   -- Hash chain for tamper detection

  PRIMARY KEY (timestamp, id)
);

-- TimescaleDB hypertable configuration (time-series optimization)
SELECT create_hypertable('audit_trail', 'timestamp', chunk_time_interval => INTERVAL '1 day');

-- Indexes for healthcare audit requirements
CREATE INDEX idx_audit_trail_actor_id ON audit_trail(actor_id, timestamp DESC);
CREATE INDEX idx_audit_trail_resource ON audit_trail(resource_type, resource_id, timestamp DESC);
CREATE INDEX idx_audit_trail_event_type ON audit_trail(event_type, timestamp DESC);
CREATE INDEX idx_audit_trail_data_subject ON audit_trail(data_subject_id, timestamp DESC);
CREATE INDEX idx_audit_trail_risk_level ON audit_trail(risk_level, timestamp DESC);

-- Retention policy for 7-year healthcare compliance
SELECT add_retention_policy('audit_trail', INTERVAL '7 years');
```

### **10. LGPD Compliance Tracking**
```sql
-- DSM:TABLE:lgpd_compliance HL_F003_F005_LGPD_TRACKING
CREATE TABLE lgpd_data_processing_records (
  id BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Data processing identification
  processing_activity VARCHAR(100) NOT NULL,
  data_controller VARCHAR(100),
  data_processor VARCHAR(100),

  -- Legal basis (LGPD Art. 7)
  legal_basis VARCHAR(50) NOT NULL,   -- consent, contract, legal_obligation, etc.
  legal_basis_description TEXT,

  -- Data subject information
  data_subject_id BIGINT,
  data_subject_category VARCHAR(50),  -- patient, professional, visitor

  -- Personal data categories
  personal_data_categories JSONB,     -- Types of personal data processed
  sensitive_data_involved BOOLEAN DEFAULT FALSE,
  special_categories JSONB,           -- Health, genetic, biometric data

  -- Processing purpose
  processing_purpose TEXT NOT NULL,
  purpose_category VARCHAR(50),       -- medical_care, research, marketing, etc.
  retention_period INTERVAL,

  -- Data sharing and transfers
  data_shared BOOLEAN DEFAULT FALSE,
  shared_with JSONB,                  -- Third parties
  international_transfer BOOLEAN DEFAULT FALSE,
  transfer_safeguards JSONB,

  -- Technical and organizational measures
  security_measures JSONB,
  encryption_applied BOOLEAN DEFAULT FALSE,
  anonymization_applied BOOLEAN DEFAULT FALSE,

  -- Compliance status
  compliance_status VARCHAR(20) DEFAULT 'compliant',
  risk_assessment_score INTEGER,      -- 0-100 risk score
  last_review_date DATE,
  next_review_due DATE,

  -- Audit and documentation
  documentation_reference VARCHAR(255),
  dpia_required BOOLEAN DEFAULT FALSE, -- Data Protection Impact Assessment
  dpia_reference VARCHAR(255),

  PRIMARY KEY (timestamp, id)
);

-- TimescaleDB configuration for LGPD compliance monitoring
SELECT create_hypertable('lgpd_data_processing_records', 'timestamp', chunk_time_interval => INTERVAL '1 month');

CREATE INDEX idx_lgpd_legal_basis ON lgpd_data_processing_records(legal_basis, timestamp DESC);
CREATE INDEX idx_lgpd_data_subject ON lgpd_data_processing_records(data_subject_id, timestamp DESC);
CREATE INDEX idx_lgpd_sensitive_data ON lgpd_data_processing_records(sensitive_data_involved, timestamp DESC);
CREATE INDEX idx_lgpd_compliance_status ON lgpd_data_processing_records(compliance_status, timestamp DESC);
```

---

## 📊 Performance Optimization

### **Query Performance Standards**
```sql
-- DSM:PERFORMANCE:query_optimization TARGET_10MS_AVERAGE
-- All CMS queries must complete within 10ms average

-- Materialized views for dashboard performance
CREATE MATERIALIZED VIEW dashboard_stats AS
SELECT
  COUNT(*) FILTER (WHERE post_type = 'post' AND post_status = 'publish') as published_posts,
  COUNT(*) FILTER (WHERE post_type = 'post' AND medical_content = true) as medical_posts,
  COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '30 days') as posts_last_30_days,
  COUNT(DISTINCT author_id) as active_authors,
  AVG(trust_score) FILTER (WHERE trust_score IS NOT NULL) as avg_trust_score
FROM posts
JOIN users ON posts.author_id = users.id;

-- Refresh strategy for real-time dashboards
CREATE OR REPLACE FUNCTION refresh_dashboard_stats()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW dashboard_stats;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Auto-refresh on relevant changes
CREATE TRIGGER trigger_refresh_dashboard
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_dashboard_stats();
```

### **Healthcare-Specific Indexes**
```sql
-- Composite indexes for healthcare queries
CREATE INDEX idx_posts_medical_approval_date ON posts(medical_content, medical_approval_status, medical_approved_at DESC)
WHERE medical_content = true;

CREATE INDEX idx_users_professional_trust ON users(professional_registry, trust_score DESC, license_verified)
WHERE professional_registry IS NOT NULL;

CREATE INDEX idx_workflow_performance ON medical_workflow_executions(workflow_type, status, total_execution_time_ms)
WHERE status = 'completed';

-- Partial indexes for compliance queries
CREATE INDEX idx_audit_high_risk ON audit_trail(timestamp DESC, event_type, actor_id)
WHERE risk_level IN ('high', 'critical');

CREATE INDEX idx_lgpd_sensitive_processing ON lgpd_data_processing_records(timestamp DESC, processing_activity)
WHERE sensitive_data_involved = true;
```

---

## 🔄 Database Migrations Strategy

### **Migration Versioning**
```elixir
# DSM:MIGRATION:versioning_strategy HEALTHCARE_ZERO_DOWNTIME
# All migrations must be backward compatible and zero-downtime

defmodule HealthcareCms.Repo.Migrations.CreateHealthcareFoundation do
  use Ecto.Migration

  def up do
    # WordPress core tables first
    create_users_table()
    create_posts_table()
    create_meta_tables()

    # Healthcare extensions
    create_medical_professionals_table()
    create_workflow_executions_table()

    # Security and compliance
    create_zero_trust_tables()
    create_audit_trail_table()
    create_lgpd_compliance_table()

    # Performance optimization
    create_performance_indexes()
    create_materialized_views()
  end

  def down do
    # Careful rollback strategy to preserve data
    # Healthcare data should never be lost
    raise "Healthcare data migrations cannot be rolled back. Use forward-only migrations."
  end
end
```

---

## 🎯 Implementation Status

**Referência Principal**: `@.claude/docs-llm-projeto/requisitos/prd-healthcare-cms/prd-agnostico-stack-research.md`

### Status Atual (Healthcare CMS v1.0.0)
- ✅ **Core Schema Design**: WordPress parity + healthcare extensions
- ✅ **LGPD Compliance**: Field-level encryption, audit trail, consent tracking
- ✅ **Zero Trust Integration**: Policy engine, trust scoring, device tracking
- ✅ **TimescaleDB Setup**: Audit trail, compliance monitoring, 7-year retention
- 🔄 **Migration Implementation**: Ecto migrations in development
- 🔄 **Performance Testing**: Query optimization validation pending

### Próximos Passos
1. **Ecto Schema Implementation**: Elixir schemas matching database design
2. **Migration Scripts**: Complete Ecto migration files
3. **Performance Testing**: Validate <10ms query performance
4. **Compliance Validation**: LGPD/CFM/ANVISA requirements testing

---

*Última atualização: 29 de Setembro de 2025*
*Database schemas prontos para Healthcare CMS v1.0.0 implementation*