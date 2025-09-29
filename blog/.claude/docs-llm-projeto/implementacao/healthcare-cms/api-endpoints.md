# 🌐 API Endpoints - Healthcare CMS

<!-- DSM:DOMAIN:integration|api_design COMPLEXITY:expert DEPS:phoenix_framework -->
<!-- DSM:HEALTHCARE:api_endpoints|wordpress_compatibility PERFORMANCE:response_time:<50ms -->
<!-- DSM:COMPLIANCE:LGPD|CFM|ANVISA|zero_trust_validation -->

## 🧩 DSM API Matrix
```yaml
DSM_API_MATRIX:
  depends_on:
    - phoenix_framework_controllers
    - zero_trust_policy_engine
    - ecto_database_contexts
    - jason_json_serialization
  provides_to:
    - wordpress_rest_api_compatibility
    - healthcare_mobile_applications
    - medical_workflow_integrations
    - third_party_systems_integration
  integrates_with:
    - wordpress_rest_api_standards
    - oauth2_authentication_system
    - medical_workflow_pipeline
    - compliance_validation_engine
  performance_contracts:
    - api_response_time: "<50ms p95 for all endpoints"
    - concurrent_requests: "10K+ requests/second supported"
    - rate_limiting: "1000 requests/minute per authenticated user"
    - availability: "99.99% uptime SLA"
  compliance_requirements:
    - lgpd_data_protection: "All PHI/PII access logged and controlled"
    - cfm_professional_validation: "Medical content endpoints require validation"
    - zero_trust_verification: "Every request evaluated by policy engine"
    - audit_trail_complete: "Full audit trail for all API interactions"
```

## Visão Geral da API

O Healthcare CMS fornece uma **API RESTful completa** com **100% compatibilidade WordPress REST API** mais extensões específicas para healthcare, incluindo **Zero Trust validation** em cada request e **compliance LGPD/CFM/ANVISA** automático.

### Arquitetura da API
```yaml
# DSM:API:architecture_overview WORDPRESS_PARITY_HEALTHCARE
API_Architecture:
  base_framework: "Phoenix Framework + Plug pipeline"
  authentication: "OAuth2 + JWT tokens + device fingerprinting"
  authorization: "Zero Trust policy evaluation per request"
  serialization: "JSON (Jason library) + HAL hypermedia"

  compatibility_layers:
    wordpress_rest_api: "100% endpoint compatibility"
    medical_extensions: "Healthcare-specific endpoints"
    compliance_layer: "LGPD/CFM/ANVISA automation"

  performance_targets:
    response_time: "<50ms p95"
    throughput: "10K+ requests/second"
    concurrent_users: "2M+ healthcare professionals"
```

---

## 🔐 Authentication & Authorization

### **OAuth2 + Zero Trust Flow**
```http
# DSM:AUTH:oauth2_zero_trust NIST_SP_800_207_COMPLIANT
POST /api/v1/auth/token
Content-Type: application/json

{
  "grant_type": "password",
  "username": "dr.silva@clinica.com.br",
  "password": "SecurePassword123!",
  "device_fingerprint": {
    "user_agent": "HealthcareApp/1.0",
    "screen_resolution": "1920x1080",
    "timezone": "America/Sao_Paulo",
    "platform": "web"
  },
  "medical_context": {
    "accessing_patient_data": false,
    "emergency_access": false,
    "location": "clinic_network"
  }
}

# Response with Zero Trust evaluation
HTTP/1.1 200 OK
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "scope": "read write medical_content",
  "zero_trust": {
    "trust_score": 85,
    "policy_evaluations": [
      {"policy": "professional_validation", "result": "allow"},
      {"policy": "device_recognition", "result": "allow"},
      {"policy": "location_validation", "result": "conditional"}
    ],
    "access_restrictions": [],
    "next_evaluation": "2025-09-29T16:30:00Z"
  },
  "medical_professional": {
    "registry": "CRM-SP-123456",
    "specialty": "Cardiologia",
    "validation_status": "verified",
    "content_approval_permissions": ["medical_article", "patient_education"]
  }
}
```

### **Request Authentication Headers**
```http
# Every API request must include Zero Trust headers
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
X-Device-Fingerprint: sha256:a1b2c3d4e5f6...
X-Medical-Context: {"patient_data_access": false, "emergency": false}
X-Request-ID: uuid-for-audit-trail
```

---

## 📝 WordPress REST API Compatibility (WP-F001 a WP-F010)

### **1. Posts Management**
```http
# DSM:ENDPOINT:posts_management WP_F002_POSTS_CRUD
# 100% WordPress REST API compatible + healthcare extensions

# List posts with medical filtering
GET /wp-json/wp/v2/posts?medical_content=true&evidence_level=I
Authorization: Bearer <token>

# Response with healthcare extensions
{
  "posts": [
    {
      "id": 123,
      "date": "2025-09-29T10:00:00",
      "title": {"rendered": "Novos Tratamentos em Cardiologia"},
      "content": {"rendered": "<p>Conteúdo médico...</p>"},
      "status": "publish",
      "author": 456,

      # Healthcare extensions
      "medical_content": true,
      "evidence_level": "I",
      "medical_disclaimer": "Este conteúdo é apenas informativo...",
      "scientific_references": [
        {
          "title": "Randomized Trial of Cardiac Treatment",
          "journal": "NEJM",
          "year": 2024,
          "pubmed_id": "12345678"
        }
      ],
      "professional_approval": {
        "status": "approved",
        "approved_by": {
          "name": "Dr. Maria Santos",
          "registry": "CRM-SP-654321",
          "specialty": "Cardiologia"
        },
        "approved_at": "2025-09-29T09:30:00Z"
      },

      # LGPD compliance
      "lgpd_compliance": {
        "contains_patient_data": false,
        "anonymization_applied": false,
        "legal_basis": "legitimate_interest"
      }
    }
  ],

  # API metadata
  "_links": {
    "self": [{"href": "https://cms.healthcare.com.br/wp-json/wp/v2/posts?page=1"}]
  },

  # Zero Trust audit
  "_audit": {
    "request_id": "req-uuid-123",
    "trust_score_at_request": 85,
    "policies_evaluated": 3,
    "access_granted": true
  }
}

# Create new medical post
POST /wp-json/wp/v2/posts
Content-Type: application/json
Authorization: Bearer <token>

{
  "title": "Avanços em Medicina Preventiva",
  "content": "Conteúdo do artigo médico...",
  "status": "draft",

  # Healthcare-specific fields
  "medical_content": true,
  "evidence_level": "II",
  "medical_disclaimer": "Conteúdo para fins educacionais apenas.",
  "target_audience": "professionals",
  "scientific_references": [
    {
      "title": "Preventive Medicine Study",
      "authors": ["Dr. Smith", "Dr. Johnson"],
      "journal": "Preventive Medicine Journal",
      "year": 2024,
      "doi": "10.1000/pmj.2024.001"
    }
  ],

  # LGPD compliance
  "contains_patient_data": false,
  "consent_for_publication": true,
  "data_retention_period": "P5Y"  # 5 years ISO 8601
}
```

### **2. Users Management**
```http
# DSM:ENDPOINT:users_management WP_F005_USER_ROLES
# Enhanced with medical professional validation

# Get current user with medical profile
GET /wp-json/wp/v2/users/me
Authorization: Bearer <token>

{
  "id": 456,
  "username": "dr.silva",
  "name": "Dr. João Silva",
  "email": "dr.silva@clinica.com.br",
  "roles": ["medical_professional"],

  # Medical professional profile
  "medical_profile": {
    "registry_type": "CRM",
    "registry_number": "123456",
    "registry_state": "SP",
    "specialty": "Cardiologia",
    "subspecialty": "Hemodinâmica",
    "validation_status": "verified",
    "license_expires": "2025-12-31",
    "institution": "Hospital das Clínicas",
    "can_approve_content": true,
    "approval_scope": ["medical_article", "patient_education"]
  },

  # Zero Trust profile
  "trust_profile": {
    "current_score": 85,
    "last_evaluation": "2025-09-29T15:45:00Z",
    "trusted_devices": 3,
    "risk_factors": [],
    "access_history": {
      "last_login": "2025-09-29T08:00:00Z",
      "login_frequency": "daily",
      "unusual_activity": false
    }
  },

  # LGPD compliance
  "privacy_settings": {
    "consent_marketing": false,
    "consent_data_processing": true,
    "data_retention_until": "2030-09-29",
    "right_to_be_forgotten_requested": false
  }
}

# Update user medical profile
PUT /wp-json/wp/v2/users/456/medical-profile
Authorization: Bearer <token>

{
  "specialty": "Cardiologia Intervencionista",
  "institution": "Instituto do Coração",
  "bio": "Especialista em procedimentos hemodinâmicos...",
  "website": "https://dr-silva-cardio.com.br"
}
```

### **3. Media Library**
```http
# DSM:ENDPOINT:media_library WP_F004_MEDIA_MANAGEMENT
# Enhanced with medical content classification

# Upload medical image with compliance metadata
POST /wp-json/wp/v2/media
Content-Type: multipart/form-data
Authorization: Bearer <token>

# Form data:
# file: [medical-diagram.jpg]
# medical_content: true
# contains_patient_data: false
# usage_permission: "educational"
# source_citation: "Adaptado de Gray's Anatomy, 2024"

# Response
{
  "id": 789,
  "date": "2025-09-29T14:00:00",
  "slug": "medical-diagram-cardiac-anatomy",
  "type": "image",
  "title": {"rendered": "Diagrama Anatômico Cardíaco"},
  "description": {"rendered": "Diagrama educacional da anatomia cardíaca"},
  "source_url": "https://cms.healthcare.com.br/wp-content/uploads/2025/09/medical-diagram.jpg",

  # Medical content metadata
  "medical_metadata": {
    "content_type": "anatomical_diagram",
    "body_system": "cardiovascular",
    "educational_level": "professional",
    "contains_patient_data": false,
    "usage_rights": "educational_use_only",
    "source_citation": "Adaptado de Gray's Anatomy, 2024",
    "approval_required": false
  },

  # LGPD compliance
  "privacy_compliance": {
    "anonymization_applied": "not_applicable",
    "consent_obtained": true,
    "legal_basis": "legitimate_interest",
    "retention_period": "P10Y"
  }
}
```

---

## 🏥 Healthcare Extensions API

### **4. Medical Workflow Pipeline**
```http
# DSM:ENDPOINT:medical_workflows HL_F002_WORKFLOW_INTEGRATION
# S.1.1 → S.4-1.1-3 pipeline management

# Start medical content processing workflow
POST /api/v1/medical/workflows/content-processing
Content-Type: application/json
Authorization: Bearer <token>

{
  "input_type": "text",
  "content": "Texto médico para processamento...",
  "workflow_config": {
    "systems_enabled": ["s1_1", "s1_2", "s2_1_2", "s3_2", "s4_1_1_3"],
    "lgpd_analysis": true,
    "scientific_validation": true,
    "seo_optimization": true
  },
  "target_output": {
    "format": "blog_post",
    "audience": "professionals",
    "compliance_level": "strict"
  }
}

# Response with execution tracking
{
  "execution_id": "exec-uuid-456",
  "status": "started",
  "estimated_completion": "2025-09-29T14:35:00Z",
  "systems_queue": [
    {
      "system": "s1_1_lgpd_analyzer",
      "status": "queued",
      "estimated_duration": "5s"
    },
    {
      "system": "s1_2_medical_claims",
      "status": "pending",
      "estimated_duration": "2s"
    }
  ],
  "progress_url": "/api/v1/medical/workflows/exec-uuid-456/progress",
  "result_url": "/api/v1/medical/workflows/exec-uuid-456/result"
}

# Get workflow execution progress
GET /api/v1/medical/workflows/exec-uuid-456/progress
Authorization: Bearer <token>

{
  "execution_id": "exec-uuid-456",
  "status": "running",
  "current_system": "s1_2_medical_claims",
  "progress_percentage": 40,
  "systems_completed": [
    {
      "system": "s1_1_lgpd_analyzer",
      "status": "completed",
      "execution_time_ms": 3245,
      "result_summary": {
        "phi_pii_detected": 0,
        "risk_score": 15,
        "recommendations": ["Use more specific medical terminology"]
      }
    }
  ],
  "estimated_completion": "2025-09-29T14:33:00Z"
}

# Get workflow final result
GET /api/v1/medical/workflows/exec-uuid-456/result
Authorization: Bearer <token>

{
  "execution_id": "exec-uuid-456",
  "status": "completed",
  "total_execution_time_ms": 245000,
  "result": {
    "processed_content": {
      "title": "Avanços em Cardiologia Preventiva",
      "content": "Conteúdo processado e otimizado...",
      "seo_optimized": true,
      "medical_disclaimer": "Conteúdo aprovado por profissional médico..."
    },
    "compliance_analysis": {
      "lgpd_compliant": true,
      "cfm_guidelines_met": true,
      "risk_assessment": "low"
    },
    "scientific_validation": {
      "claims_identified": 5,
      "references_found": 8,
      "evidence_level": "II",
      "confidence_score": 92
    }
  }
}
```

### **5. Professional Validation API**
```http
# DSM:ENDPOINT:professional_validation HL_F001_REGISTRY_VERIFICATION

# Validate medical professional registry
POST /api/v1/medical/professionals/validate
Content-Type: application/json
Authorization: Bearer <token>

{
  "registry_type": "CRM",
  "registry_number": "123456",
  "registry_state": "SP",
  "full_name": "João Silva Santos",
  "specialty": "Cardiologia"
}

# Response with external validation
{
  "validation_id": "val-uuid-789",
  "status": "verified",
  "professional_data": {
    "full_name": "João Silva Santos",
    "registry": "CRM-SP-123456",
    "specialty": "Cardiologia",
    "subspecialty": "Hemodinâmica",
    "situation": "Regular",
    "license_expires": "2025-12-31"
  },
  "validation_details": {
    "external_api": "CFM_API",
    "validated_at": "2025-09-29T14:45:00Z",
    "next_validation_due": "2025-10-29T14:45:00Z",
    "confidence_level": "high"
  },
  "permissions_granted": {
    "can_publish_medical_content": true,
    "can_approve_content": false,
    "content_types_allowed": ["medical_article", "patient_education"],
    "restrictions": []
  }
}

# Get professional validation status
GET /api/v1/medical/professionals/456/validation-status
Authorization: Bearer <token>

{
  "user_id": 456,
  "validation_status": "verified",
  "last_validation": "2025-09-29T14:45:00Z",
  "expires_at": "2025-12-31T23:59:59Z",
  "registry_info": {
    "type": "CRM",
    "number": "123456",
    "state": "SP",
    "specialty": "Cardiologia"
  },
  "compliance_score": 95,
  "recommendations": []
}
```

---

## 🛡️ Security & Compliance API

### **6. Zero Trust Policy Evaluation**
```http
# DSM:ENDPOINT:zero_trust_evaluation SEC_F001_F002_POLICY_ENGINE

# Get current trust score and policies
GET /api/v1/security/trust-evaluation
Authorization: Bearer <token>

{
  "user_id": 456,
  "current_trust_score": 85,
  "last_evaluation": "2025-09-29T15:30:00Z",
  "active_policies": [
    {
      "policy_name": "medical_professional_validation",
      "status": "passed",
      "score_impact": 25,
      "last_check": "2025-09-29T08:00:00Z"
    },
    {
      "policy_name": "device_recognition",
      "status": "passed",
      "score_impact": 20,
      "last_check": "2025-09-29T15:30:00Z"
    },
    {
      "policy_name": "location_validation",
      "status": "conditional",
      "score_impact": 10,
      "conditions": ["VPN usage detected"],
      "last_check": "2025-09-29T15:30:00Z"
    }
  ],
  "risk_factors": [
    {
      "factor": "new_device_access",
      "severity": "medium",
      "mitigation": "Two-factor authentication required"
    }
  ],
  "recommendations": [
    "Enable biometric authentication for higher trust score",
    "Complete security questionnaire for device certification"
  ]
}

# Request policy re-evaluation
POST /api/v1/security/trust-evaluation/refresh
Content-Type: application/json
Authorization: Bearer <token>

{
  "context_update": {
    "location_changed": false,
    "device_state": "secure",
    "medical_context": {
      "accessing_patient_data": true,
      "emergency_situation": false
    }
  }
}
```

### **7. LGPD Compliance API**
```http
# DSM:ENDPOINT:lgpd_compliance HL_F003_F005_LGPD_AUTOMATION

# Get user's LGPD data processing summary
GET /api/v1/compliance/lgpd/data-processing/users/456
Authorization: Bearer <token>

{
  "data_subject_id": 456,
  "processing_activities": [
    {
      "activity": "medical_content_creation",
      "legal_basis": "consent",
      "purpose": "Professional medical education content",
      "data_categories": ["professional_info", "content_preferences"],
      "retention_period": "P5Y",
      "last_updated": "2025-09-29T10:00:00Z"
    },
    {
      "activity": "platform_usage_analytics",
      "legal_basis": "legitimate_interest",
      "purpose": "Platform improvement and security",
      "data_categories": ["usage_patterns", "device_info"],
      "retention_period": "P2Y",
      "anonymization_applied": true
    }
  ],
  "rights_exercised": [],
  "consent_history": [
    {
      "consent_type": "data_processing",
      "status": "given",
      "given_at": "2025-01-15T09:00:00Z",
      "method": "explicit_checkbox"
    }
  ],
  "data_portability": {
    "available": true,
    "formats": ["json", "csv"],
    "request_url": "/api/v1/compliance/lgpd/data-export/456"
  }
}

# Exercise right to data portability
POST /api/v1/compliance/lgpd/data-export/456
Content-Type: application/json
Authorization: Bearer <token>

{
  "export_format": "json",
  "data_categories": ["all"],
  "include_metadata": true
}

# Response
{
  "export_id": "export-uuid-123",
  "status": "processing",
  "estimated_completion": "2025-09-29T16:00:00Z",
  "download_url": "/api/v1/compliance/lgpd/data-export/export-uuid-123/download",
  "expires_at": "2025-10-06T16:00:00Z"
}
```

---

## 📊 Analytics & Monitoring API

### **8. Performance Metrics**
```http
# DSM:ENDPOINT:performance_monitoring HEALTHCARE_SLA_TRACKING

# Get API performance metrics
GET /api/v1/monitoring/performance/summary
Authorization: Bearer <token>

{
  "time_period": "last_24_hours",
  "metrics": {
    "api_response_times": {
      "p50": 23,
      "p95": 47,
      "p99": 68,
      "average": 28
    },
    "request_volume": {
      "total_requests": 1250000,
      "requests_per_second_peak": 8500,
      "requests_per_second_average": 867
    },
    "error_rates": {
      "4xx_errors": 0.02,
      "5xx_errors": 0.001,
      "zero_trust_denials": 0.05
    },
    "healthcare_specific": {
      "medical_workflow_executions": 1240,
      "professional_validations": 45,
      "compliance_checks_passed": 99.97
    }
  },
  "sla_compliance": {
    "response_time_target": "<50ms p95",
    "current_performance": "47ms p95",
    "status": "within_target",
    "availability": "99.99%"
  }
}
```

---

## 🧪 Development & Testing Endpoints

### **9. Health Checks**
```http
# DSM:ENDPOINT:health_checks SYSTEM_MONITORING

# Comprehensive health check
GET /api/v1/health
# Public endpoint - no authentication required

{
  "status": "healthy",
  "timestamp": "2025-09-29T15:45:00Z",
  "version": "1.0.0",
  "environment": "production",

  "checks": {
    "database": {
      "status": "healthy",
      "response_time_ms": 3,
      "connection_pool": "8/10 connections active"
    },
    "timescaledb": {
      "status": "healthy",
      "response_time_ms": 5,
      "audit_trail_lag": "0ms"
    },
    "zero_trust_engine": {
      "status": "healthy",
      "policy_evaluation_time_ms": 12,
      "active_policies": 25
    },
    "medical_workflows": {
      "status": "healthy",
      "webassembly_runtime": "operational",
      "plugin_health": "all_systems_operational"
    },
    "external_integrations": {
      "cfm_api": "healthy",
      "pubmed_api": "healthy",
      "backup_systems": "healthy"
    }
  },

  "performance": {
    "uptime_seconds": 2592000,
    "memory_usage": "68%",
    "cpu_usage": "23%",
    "requests_last_minute": 856
  }
}

# Detailed system status (authenticated)
GET /api/v1/health/detailed
Authorization: Bearer <token>
# Requires admin or monitoring role

{
  "system_status": "operational",
  "detailed_metrics": {
    "database_connections": 45,
    "active_user_sessions": 15420,
    "medical_workflows_queued": 3,
    "zero_trust_evaluations_per_second": 234,
    "compliance_violations_last_hour": 0
  },
  "alerts": [],
  "maintenance_scheduled": null
}
```

---

## 📋 Implementation Status

**Referência Principal**: `@.claude/docs-llm-projeto/requisitos/prd-healthcare-cms/prd-agnostico-stack-research.md`

### Status Atual (Healthcare CMS v1.0.0)
- ✅ **API Architecture Design**: Phoenix + Plug pipeline defined
- ✅ **WordPress Compatibility**: REST API parity specifications
- ✅ **Healthcare Extensions**: Medical workflow endpoints designed
- ✅ **Security Integration**: Zero Trust + OAuth2 flow specified
- ✅ **Compliance API**: LGPD/CFM/ANVISA endpoints planned
- 🔄 **Controller Implementation**: Phoenix controllers in development
- 🔄 **Authentication Setup**: Guardian + OAuth2 configuration pending
- 🔄 **Rate Limiting**: Hammer rate limiter integration pending

### Próximos Passos
1. **Phoenix Controllers**: Implementation of all endpoint handlers
2. **Authentication Middleware**: OAuth2 + Zero Trust integration
3. **API Documentation**: OpenAPI/Swagger specification generation
4. **Performance Testing**: Load testing to validate <50ms SLA

---

*Última atualização: 29 de Setembro de 2025*
*API endpoints prontos para Healthcare CMS v1.0.0 implementation*