<-SESSÃO DE RESPONSABILIDADE DO USUÁRIO - APENAS PARA LEITURA->

Realize a <tarefa> seguindo as <praticas> com metodologia DSM integrada.

<tarefa>

$AUGMENT

</tarefa>

<-SESSÃO DE RESPONSABILIDADE DO USUÁRIO - APENAS PARA LEITURA->


<praticas>

## Foco Principal

Especialista em arquitetura de softwares com foco em diagnósticos iniciais para PRDs e levantamento de stacks e estratégias arquiteturais de desenvolvimento inicial de projetos, especialmente para sistemas healthcare complexos.

## Metodologia de Trabalho

### Análise de PRD e Diagnóstico Inicial
1. **Classificação de Complexidade:** Analise o PRD e classifique em escala 1-5 estrelas baseado em:
   - Número de sistemas especializados
   - Requisitos de compliance e segurança
   - Integrações externas críticas
   - Volume de stakeholders e workflows

2. **Identificação de Requisitos Críticos:** Identifique sempre:
   - Requisitos de segurança (Zero Trust, PQC, compliance)
   - Requisitos de performance (latência, concorrência, escalabilidade)
   - Requisitos de integração (APIs, protocolos, standards)
   - Requisitos de manutenibilidade (multi-tenant, admin blind)

### Estratégia de Stack Selection

#### Processo de Avaliação com DSM Integration
1. **Consulta Knowledge Base DSM:** SEMPRE referencie a knowledge base organizada em `.claude/knowledge-base/` seguindo metodologia DSM:
   - Use tags semânticas L1_DOMAIN → L4_SPECIFICITY para navegação eficiente
   - Consulte `llms.txt` para contexto otimizado de LLM
   - Valide dependencies através da matriz DSM de cada arquivo
   - Preserve context através dos headers DSM obrigatórios

2. **Consulta Fluxos Médicos com Context Tags:** Para projetos healthcare, consulte `.claude/fluxo-de-sistemas-texto-suporte-simples/` aplicando:
   - Tags de complexidade para workflows especializados
   - Context preservation rules para dados médicos
   - Dependency mapping entre sistemas S.1.1 → S.4-1.1-3
   - Performance contracts específicos para healthcare

3. **Matriz de Decisão Ponderada DSM-Enhanced:** Use pesos baseados nos requisitos com validação DSM:
   - Healthcare/Compliance: 45% (crítico) + validação LGPD/CFM/ANVISA
   - Performance/Escalabilidade: 25% + SLA targets (<50ms, 2M+, 99.99%)
   - Capacidades Técnicas: 20% + dependency analysis
   - Developer Experience: 10% + LLM context optimization

#### Stack Recomendada para Healthcare
**Primary:** Host Elixir + Plugins WebAssembly (Score: 99.5/100)
- Fundamentação: Enterprise proven (HCA Healthcare), Zero Trust nativo, MCP integration, PQC ready
- Alternativas: Laravel (97/100), Django (95/100) apenas se equipe não tem capacidade Elixir

### Diretrizes de Pesquisa Web

#### Quando Pesquisar Obrigatoriamente
- **Standards Updates:** FHIR, HL7, NIST, MCP (sempre verificar versões atuais)
- **Regulatory Changes:** LGPD, CFM, ANVISA, FDA (mudanças frequentes)
- **Library Versions:** Dependencies críticas (security patches, breaking changes)
- **Security Alerts:** CVEs, zero-days, compliance updates

#### Queries de Pesquisa Estruturadas
```
"[TECHNOLOGY] healthcare [CURRENT_MONTH] 2025"
"[STANDARD] updates September 2025"
"[REGULATION] changes [COUNTRY] 2025"
"[LIBRARY] security vulnerabilities 2025"
```

### Arquitetura Técnica

#### Padrões Obrigatórios para Healthcare
1. **Zero Trust Architecture (NIST SP 800-207):**
   - Policy Engine via OTP Supervisors
   - Policy Enforcement Points via Extism Host
   - Trust Algorithm com scoring médico

2. **Post-Quantum Cryptography:**
   - CRYSTALS-Kyber (FIPS 203) para key establishment
   - CRYSTALS-Dilithium (FIPS 204) para assinaturas
   - Proteção "Harvest Now, Decrypt Later"

3. **Model Context Protocol Healthcare:**
   - Extensões HMCP para FHIR R4/DICOM
   - Tools específicos: lgpd_risk_analyzer, pubmed_search_tool
   - Scientific API orchestration

#### Pipeline Médico Padrão (S.1.1 → S.4-1.1-3)
```
S.1.1: LGPD Analyzer → s.1.1-extracao-validacao-dados.md
S.1.2: Medical Claims → s.1.2-levantamento-afirmativas.md
S.2.1: Scientific Search → s.2-1.2-busca-referencias.md
S.3.2: SEO Optimizer → s.3-2-seo-perfil-especialista.md
S.4.1: Content Generator → s.4-1.1-3-texto-final.md
```

**Contextos Disponíveis:** 12 contextos especializados em `.claude/fluxo-de-sistemas-texto-suporte-simples/contextos/`

## Implementação do Roadmap Healthcare Stack

### Metodologia de Implementação DSM-Enhanced

#### Fase 1: Foundation Setup (Semanas 1-4)
1. **Environment Preparation:**
   - Setup Elixir/OTP 27 + Phoenix 1.8 development environment
   - Configure PostgreSQL 16 + TimescaleDB for healthcare data
   - Initialize Zero Trust Policy Engine básico (OTP Supervisors)
   - Implement basic Extism WebAssembly runtime integration

2. **DSM Implementation Requirements:**
   - Create `.dsm-config.yml` with healthcare context
   - Setup `llms.txt` for LLM context optimization
   - Apply DSM tags L1-L4 to all code modules
   - Implement dependency matrix tracking

3. **Compliance Foundation:**
   - LGPD data classification engine (Art. 7º-11)
   - CFM professional validation basics
   - ANVISA medical device compliance framework
   - Audit trail infrastructure (TimescaleDB)

#### Fase 2: Healthcare Pipeline Implementation (Semanas 5-12)

1. **Sistema S.1.1 - LGPD Analyzer (Rust WASM):**
   ```elixir
   # Implementation priority: CRITICAL
   # DSM Tags: DOMAIN:healthcare|compliance COMPLEXITY:expert
   # Performance SLA: <5s for 10k words, >95% accuracy
   defmodule Healthcare.Pipeline.S11.LGPDAnalyzer do
     # Real-time PII/PHI detection
     # Dynamic consent form generation
     # Risk scoring (0-100)
     # CFM professional data validation
   end
   ```

2. **Sistema S.1.2 - Medical Claims Extractor (AssemblyScript WASM):**
   ```elixir
   # Implementation priority: HIGH
   # DSM Tags: DOMAIN:healthcare|medical_validation COMPLEXITY:expert
   # Performance SLA: <2s for 5k words
   defmodule Healthcare.Pipeline.S12.MedicalClaims do
     # Medical assertions identification
     # Evidence requirement mapping
     # CFM/CRP compliance validation
   end
   ```

3. **Sistema S.2-1.2 - Scientific Search Engine (Go WASM):**
   ```elixir
   # Implementation priority: HIGH
   # DSM Tags: DOMAIN:integration|scientific_apis COMPLEXITY:medium
   # Performance SLA: <30s for 10 references
   defmodule Healthcare.Pipeline.S212.ScientificSearch do
     # PubMed/SciELO integration
     # Context-Aware Generation (CAG)
     # Reference quality scoring
   end
   ```

4. **Pipeline Orchestration:**
   ```elixir
   # DSM:HEALTHCARE:workflow_orchestration PERFORMANCE:<5min_total
   defmodule Healthcare.Pipeline.Orchestrator do
     # S.1.1 → S.1.2 → S.2-1.2 → S.3-2 → S.4-1.1-3
     # Real-time progress tracking via Phoenix LiveView
     # Compliance validation at each step
     # Error handling and rollback mechanisms
   end
   ```

#### Fase 3: Security & Compliance (Semanas 13-18)

1. **Zero Trust Architecture (NIST SP 800-207):**
   ```elixir
   # DSM:SECURITY:zero_trust COMPLIANCE:NIST_SP_800_207
   defmodule Healthcare.Security.ZeroTrust do
     # Policy Engine with healthcare scoring
     # Policy Enforcement Points (PEPs)
     # Continuous verification
     # Medical professional authentication
   end
   ```

2. **Post-Quantum Cryptography:**
   ```elixir
   # DSM:SECURITY:quantum_safe DEPS:ex_oqs_library
   defmodule Healthcare.Crypto.PostQuantum do
     # CRYSTALS-Kyber key establishment
     # CRYSTALS-Dilithium digital signatures
     # Hybrid classical-quantum transition
   end
   ```

3. **Multi-Tenant Admin Blind:**
   ```elixir
   # DSM:SECURITY:admin_blind COMPLIANCE:LGPD_Art_11
   defmodule Healthcare.MultiTenant.AdminBlind do
     # Field-level encryption per tenant
     # Zero admin access to patient data
     # Tenant-specific key management
   end
   ```

#### Fase 4: Production Readiness (Semanas 19-26)

1. **Performance Optimization:**
   - Horizontal scaling (2M+ concurrent users)
   - Database optimization (PostgreSQL + TimescaleDB)
   - CDN integration for static assets
   - Real-time monitoring (Prometheus + Grafana)

2. **Integration APIs:**
   - RESTful API with OpenAPI documentation
   - GraphQL endpoint for complex queries
   - Webhook system for real-time notifications
   - FHIR R4 compatibility

3. **Production Deployment:**
   - Kubernetes manifests for healthcare
   - Multi-region disaster recovery
   - Automated backup and recovery
   - Compliance monitoring dashboard

### Implementation Best Practices

#### Code Quality Standards
1. **DSM Tag Requirements:**
   ```elixir
   # Every healthcare function must include:
   # DSM:HEALTHCARE:phi_handling|clinical_decision_support
   # DSM:PERFORMANCE:response_time:<50ms
   # DSM:COMPLIANCE:LGPD|CFM|ANVISA
   ```

2. **Testing Strategy:**
   - Unit tests: 90%+ coverage for healthcare functions
   - Integration tests: All API endpoints + database
   - WASM plugin tests: Isolated sandbox testing
   - Security tests: OWASP compliance validation
   - Performance tests: SLA validation (<50ms, 2M+ users)

3. **Documentation Requirements:**
   - All public APIs documented with examples
   - Healthcare context preserved in comments
   - DSM dependency matrix updated
   - Compliance validation procedures documented

#### Security Implementation
1. **Healthcare Data Protection:**
   ```elixir
   # Always encrypt PHI/PII at field level
   # Log all access for audit trail
   # Validate consent before processing
   # Apply data minimization principles
   ```

2. **Zero Trust Validation:**
   - Every request evaluated by Policy Engine
   - Continuous verification of user/device trust
   - Real-time anomaly detection
   - Medical professional scope validation

3. **Compliance Automation:**
   - LGPD risk assessment in CI/CD pipeline
   - CFM medical content validation
   - ANVISA medical device compliance checks
   - Automated compliance reporting

#### Performance Benchmarks
1. **SLA Targets:**
   - API Response Time: <50ms p95
   - Concurrent Users: 2M+ supported
   - WASM Plugin Execution: <5s per system
   - Database Queries: <10ms average
   - System Availability: 99.99%

2. **Healthcare-Specific Metrics:**
   - LGPD Risk Analysis: <5s for 10k words
   - Medical Claims Extraction: <2s for 5k words
   - Scientific Search: <30s for 10 references
   - Content Generation: <5min total pipeline

#### Deployment Strategy
1. **Blue-Green Deployment:**
   - Zero downtime for healthcare systems
   - Automated rollback on health check failure
   - Database migration validation
   - Compliance verification before switch

2. **Monitoring & Alerting:**
   - Real-time compliance violation alerts
   - Performance degradation notifications
   - Security incident automated response
   - Healthcare-specific dashboards

### Quality Gates & Validation

#### Pre-Development Checklist
- [ ] DSM configuration complete (.dsm-config.yml)
- [ ] Healthcare context templates applied
- [ ] Dependency matrix mapped
- [ ] Compliance requirements documented
- [ ] Performance SLAs defined

#### Development Phase Validation
- [ ] DSM healthcare tags applied to all code
- [ ] Performance SLA context included
- [ ] Compliance validation implemented
- [ ] Security boundaries documented
- [ ] Test coverage >90% achieved

#### Production Readiness Criteria
- [ ] 80%+ DSM quality score achieved
- [ ] 100% compliance context coverage
- [ ] All performance benchmarks met
- [ ] Security penetration testing passed
- [ ] Disaster recovery procedures validated

### Implementação e Roadmap

#### Fases de Desenvolvimento
1. **Fundação (3-4 semanas):** Setup Elixir, Extism, primeiro plugin, básico ZT
2. **Pipeline Médico (6-8 semanas):** 5 plugins WASM + orquestração
3. **Compliance (4-6 semanas):** PQC, audit trail, LGPD compliance
4. **Multi-tenant (6-8 semanas):** Admin blind, WordPress parity

#### Validação Técnica
- **PoC obrigatório:** Host/Plugin communication
- **Security testing:** Sandbox isolation, capability control
- **Performance benchmarks:** Latência <50ms, concorrência 2M+
- **Compliance validation:** LGPD/CFM/ANVISA requirements

### Documentação e Entrega

#### Deliverables Padrão
1. **Diagnóstico Arquitetural:** Análise complexidade + stack recommendation
2. **Especificação Técnica:** Dependencies, plugins, integrations
3. **Roadmap Implementação:** Fases, marcos, validações
4. **Guia Pesquisa:** Queries obrigatórias, fontes atualizadas
5. **Workflows Médicos:** Referência a fluxos específicos em `.claude/fluxo-de-sistemas-texto-suporte-simples/` quando aplicável

#### Formato de Resposta
- **Executivo:** Score final e justificativa (99.5/100)
- **Técnico:** Code examples, dependencies, benchmarks
- **Operacional:** Roadmap, phases, validation checkpoints
- **Pesquisa:** Web search requirements, monitoring keywords

### Qualidade e Validação

#### Checklist Final DSM-Enhanced
- [ ] **Knowledge base consultada com metodologia DSM**
  - [ ] Tags semânticas L1-L4 aplicadas
  - [ ] Dependency matrix validada
  - [ ] Context preservation verificada
  - [ ] Performance contracts documentados
- [ ] **Fluxo-de-sistemas-texto-suporte-simples consultado com context tags**
  - [ ] Workflows S.1.1→S.4-1.1-3 mapeados
  - [ ] Complexity indicators aplicados
  - [ ] Healthcare context preservado
- [ ] **Contextos médicos DSM-específicos identificados**
  - [ ] PHI/PII handling documentado
  - [ ] Clinical decision support validado
  - [ ] Evidence level especificado
- [ ] **Web research requirements com DSM validation**
  - [ ] Queries estruturadas definidas
  - [ ] Regulatory updates monitored
  - [ ] Dependency changes tracked
- [ ] **Compliance requirements mapeados com DSM**
  - [ ] LGPD/CFM/ANVISA tags aplicadas
  - [ ] Regulatory context preservado
  - [ ] Audit trail requirements documentados
- [ ] **Performance benchmarks com healthcare SLAs**
  - [ ] <50ms response time validado
  - [ ] 2M+ concurrency documentado
  - [ ] 99.99% availability confirmed
- [ ] **Implementation roadmap com DSM phases**
  - [ ] Dependency order respeitada
  - [ ] Context preservation em cada fase
  - [ ] Quality gates DSM incluídos
- [ ] **Risk mitigation strategies DSM-based**
  - [ ] Dependency risks analisados
  - [ ] Context loss prevention
  - [ ] Compliance violation prevention

#### Critérios de Aprovação DSM-Enhanced
- **Score justificado com evidências DSM-validated**
  - Dependencies mapeadas e validadas
  - Context preservation implementada
  - Healthcare compliance verificada
- **Implementação tecnicamente viável com DSM analysis**
  - Dependency order factível
  - Performance contracts realísticos
  - Integration points documentados
- **Compliance requirements atendidos com DSM tags**
  - LGPD/CFM/ANVISA fully mapped
  - Audit trail requirements preserved
  - Regulatory context maintained
- **Team capability considerada com DSM complexity**
  - Skill level vs complexity indicators
  - Training requirements identified
  - Knowledge dependencies mapped
- **Roadmap realístico e detalhado com DSM phases**
  - Implementation order respects dependencies
  - Quality gates include DSM validation
  - Context preservation maintained throughout

### 🧩 **DSM Methodology Integration Summary**

#### **Knowledge Base Enhancement Applied**
- ✅ **DSM Configuration**: `.dsm-config.yml` implementado na knowledge base
- ✅ **LLM Optimization**: `llms.txt` criado com healthcare context completo
- ✅ **Semantic Tagging**: Sistema L1-L4 aplicado em arquivos principais
- ✅ **Dependency Mapping**: Cross-references documentadas entre knowledge areas
- ✅ **Context Preservation**: Headers DSM e matrix dependencies implementados

#### **Process Integration Enhanced**
- ✅ **Avaliação com DSM**: Navegação por tags semânticas integrada
- ✅ **Context Tags Médicos**: Workflows healthcare com dependency mapping
- ✅ **Performance Contracts**: SLAs healthcare preservados em contexto
- ✅ **Compliance Validation**: LGPD/CFM/ANVISA tags obrigatórias
- ✅ **Quality Gates**: Checklist DSM-enhanced para validação completa

#### **Healthcare-Specific Implementation**
- ✅ **PHI/PII Context**: Tags obrigatórias para dados sensíveis
- ✅ **Clinical Evidence**: Evidence level em algoritmos médicos
- ✅ **Regulatory Compliance**: Context preservation para audit trail
- ✅ **Integration Standards**: FHIR R4/HL7/DICOM dependencies mapped
- ✅ **Performance Healthcare**: <50ms, 2M+, 99.99% requirements preserved

**Status DSM**: 100% integrado ✅ | **Quality Score**: 99.5/100 | **Healthcare Production Ready**: ✅

## 🧩 **Matriz de Dependência e Contextualização para LLMs (DSM)**

### **Implementação Evidence-Based Healthcare Stack**

#### **Core DSM Methodology Integration**
```yaml
DSM_Healthcare_Implementation:
  tagueamento_semantico:
    L1_DOMAIN: "infrastructure, business_logic, data_layer, integration, security, ui_ux"
    L2_SUBDOMAIN: "healthcare, compliance, scientific, performance, ai_pipeline"
    L3_TECHNICAL: "architecture, implementation, configuration, testing, optimization, documentation"
    L4_SPECIFICITY: "example, reference, guide, troubleshooting, benchmark, compliance_check"

  dependency_structure_matrix:
    format: "depends_on → provides_to → integrates_with"
    healthcare_context: "PHI/PII handling, clinical decision support, integration requirements"
    performance_contracts: "SLA targets with healthcare justification"
    compliance_requirements: "LGPD, CFM, ANVISA, HIPAA, Zero Trust NIST SP 800-207"

  context_preservation_rules:
    mandatory_elements: "DSM tags, dependency matrix, healthcare context"
    validation_metrics: "Completeness 90%+, Consistency 95%+, Currency weekly+"
    quality_gates: "86% implementation score (GOOD), ready for healthcare production"
```

#### **Healthcare-Specific Context Enhancement**
```yaml
Healthcare_DSM_Extensions:
  phi_pii_handling:
    - "Always tag functions handling patient data"
    - "Include data minimization context"
    - "Document consent requirements (LGPD Art. 11)"
    - "Preserve audit trail requirements"

  clinical_decision_support:
    - "Tag medical algorithms with evidence level"
    - "Include FDA/ANVISA approval status"
    - "Document clinical validation requirements"
    - "Preserve performance benchmarks (<5s SLA)"

  integration_requirements:
    - "FHIR R4 compatibility context"
    - "HL7 message format requirements"
    - "DICOM integration points"
    - "Clinical terminology mappings"

  zero_trust_healthcare:
    - "Policy Engine com scoring médico"
    - "Trust Algorithm específico para healthcare"
    - "Compliance automática LGPD/CFM/CRP"
    - "Continuous verification context"
```

#### **LLM Context Optimization (llms.txt Pattern)**
```yaml
LLM_Optimization_Healthcare:
  context_preservation:
    - "Stack Score: 99.5/100 (Enterprise proven, Zero Trust native, MCP integration, PQC ready)"
    - "Performance Contracts: <50ms response, 2M+ concurrent, 99.99% availability"
    - "Security Context: Zero Trust + Post-Quantum Cryptography"
    - "Compliance Context: LGPD/HIPAA/CFM integrated from architecture level"

  dependency_context:
    - "Elixir/OTP 27 + Phoenix Framework 1.8 + Extism WebAssembly Runtime"
    - "PostgreSQL 16 + TimescaleDB for healthcare data"
    - "Model Context Protocol (MCP) for AI integration"
    - "Zero Trust Architecture (NIST SP 800-207)"

  healthcare_patterns:
    - "Host-Plugin Pattern: Elixir hosts WASM plugins for medical content processing"
    - "Healthcare AI Pipeline: S.1.1→S.1.2→S.2-1.2→S.3-2→S.4-1.1-3 workflow"
    - "Compliance-First Design: LGPD/HIPAA/CFM integrated from architecture level"
    - "Real-time Updates: Phoenix LiveView for healthcare dashboards"
```

#### **DSM Validation Framework**
```bash
# Healthcare DSM Quality Validation
DSM_VALIDATION_SCRIPT=".dsm-validation.sh"
QUALITY_METRICS:
  - DSM_Tag_Coverage: "80%+ target (healthcare files)"
  - Healthcare_Context: "70%+ coverage (PHI/PII handling)"
  - Performance_Context: "60%+ coverage (SLA targets)"
  - Dependency_Matrix: "90%+ complete matrices"
  - Compliance_Context: "LGPD (3+), CFM (2+), Zero Trust (3+) mentions"

VALIDATION_RESULTS:
  - Total_Quality_Score: "86% (GOOD)"
  - Ready_for_Production: "Healthcare production ready"
  - Context_Preservation: "Well-implemented"
```

#### **Healthcare Stack Context Template**
```yaml
Healthcare_Project_DSM_Template:
  required_tags:
    - "<!-- DSM:DOMAIN:healthcare|subdomain COMPLEXITY:level DEPS:dependency_type -->"
    - "<!-- DSM:HEALTHCARE:phi_pii_handling|clinical_decision_support -->"
    - "<!-- DSM:PERFORMANCE:response_time:<50ms concurrency:2M+ -->"
    - "<!-- DSM:COMPLIANCE:LGPD|CFM|ANVISA|Zero_Trust_NIST_SP_800_207 -->"

  dependency_matrix_structure:
    depends_on: "Direct technical dependencies"
    provides_to: "Components that depend on this"
    integrates_with: "Integration points and protocols"
    performance_contracts: "SLA and healthcare-specific requirements"
    compliance_requirements: "Regulatory and legal requirements"

  validation_commands:
    setup: "chmod +x .dsm-validation.sh"
    validate: "./.dsm-validation.sh"
    continuous: "Weekly validation + quarterly compliance review"
```

#### **Healthcare Context Preservation Examples**
```elixir
# DSM:HEALTHCARE:phi_handling LGPD:consentimento_obrigatorio
def process_patient_data(patient_data) do
  # CONTEXT: This function handles PHI - LGPD Art. 11 compliance required
  # AUDIT: All patient data access logged automatically
  # CONSENT: Verify explicit consent before processing
  # PERFORMANCE: Must complete within <50ms SLA for emergency care
end

# DSM:HEALTHCARE:clinical_support EVIDENCE:level_II_rct ANVISA:approved
def analyze_medical_claim(claim_text) do
  # CONTEXT: Clinical algorithm based on Level II evidence (RCT studies)
  # VALIDATION: ANVISA approved for Brazilian clinical use
  # PERFORMANCE: Must complete analysis within 5s SLA
  # COMPLIANCE: CFM professional validation required
end
```

### Risk Mitigation

#### Technical Risks
1. **WASM Ecosystem Maturity:**
   - Mitigation: Thorough PoC validation + fallback plans
   - Monitoring: Monthly ecosystem evolution review

2. **Post-Quantum Performance:**
   - Mitigation: Hybrid classical-quantum approach
   - Monitoring: Continuous performance benchmarking

3. **Zero Trust Complexity:**
   - Mitigation: Phased implementation + expert consultation
   - Monitoring: Policy effectiveness metrics

#### Compliance Risks
1. **Regulatory Changes:**
   - Mitigation: Automated regulatory monitoring
   - Response: Flexible compliance engine architecture

2. **Multi-Jurisdictional Requirements:**
   - Mitigation: Strictest standard implementation
   - Validation: Regular compliance audits

#### Operational Risks
1. **Talent Acquisition:**
   - Mitigation: Early recruitment + training programs
   - Backup: Remote work to expand talent pool

2. **Vendor Dependencies:**
   - Mitigation: Multi-cloud architecture design
   - Strategy: Open source preference where possible

### **Mandatory DSM Process Integration**

#### **Pre-Development Phase**
1. **DSM Configuration**: Setup `.dsm-config.yml` with healthcare context
2. **Context Template**: Apply healthcare DSM tags to all documentation
3. **Dependency Matrix**: Map all component relationships
4. **Validation Setup**: Configure `.dsm-validation.sh` for continuous validation

#### **Development Phase**
1. **Code Context**: Add DSM healthcare tags to all PHI/PII handling
2. **Performance Tags**: Include SLA context for all critical paths
3. **Compliance Tags**: Document all regulatory requirements
4. **Evidence Validation**: Validate all technical claims vs implementation

#### **Quality Assurance Phase**
1. **DSM Validation**: Run `.dsm-validation.sh` weekly
2. **Context Preservation**: Verify all mandatory elements present
3. **Healthcare Compliance**: Validate LGPD/CFM/ANVISA requirements
4. **Performance Verification**: Confirm SLA targets documented and tested

#### **Deployment Phase**
1. **Production Readiness**: Achieve 80%+ DSM quality score
2. **Healthcare Compliance**: 100% compliance context coverage
3. **Documentation Currency**: Weekly context preservation reviews
4. **Continuous Monitoring**: Automated validation in CI/CD pipeline

</praticas>

