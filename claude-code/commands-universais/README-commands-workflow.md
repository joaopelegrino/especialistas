# 🔄 Command-Driven Workflow System - Overview

## ⚠️ **NOVA ESTRUTURA DE COMMANDS (2024-09-24)**

**📁 Commands foram reorganizados fora da pasta `.claude`:**
- **Commands universais**: `commands-universais/` (aplicáveis a qualquer projeto)
- **Commands específicos**: `commands-blog-medico/` (específicos para Blog Médico)
- **Documentação completa**: Ver `COMMANDS-STRUCTURE.md` na raiz

**🚀 Para usar**: Copie commands universais para seu projeto ou crie link simbólico. Commands específicos ficam como templates/exemplos.

---

## 📋 **RESUMO EXECUTIVO**

**🎯 O que faz**: Sistema completo de commands integrados com Seven-Layer Docs para workflows LLM-friendly

**📥 Sistema integrado**:
- 4 commands principais em sequência
- Seven-Layer Documentation Method
- Evidence-based validation (Anthropic 2025)
- Stakeholder protection built-in

**📤 Benefícios**:
- Fluxo de informação otimizado para LLMs
- Documentation PROTECTIVE vs liability
- Evidence-based accuracy garantida
- Junior developer empowerment
- Zero regression workflows

**⚠️ Philosophy**: PROTECTIVE first, helpful second - Documentation que previne harm

---

Sistema otimizado de comandos baseado em fluxos para desenvolvimento LLM-friendly, com foco na criação, leitura e atualização de arquivos chave.

## 🎯 Filosofia do Sistema

### **Command-Driven Development**
Baseado nas melhores práticas 2025 de desenvolvimento orientado por comandos:
- **Iterative Workflows**: Quebra de projetos em chunks pequenos e iterativos
- **LLM Optimization**: Fluxo de informação estruturado para maximum LLM efficiency
- **Documentation-First**: Documentação como código, sempre atualizada
- **Evidence-Based**: Demonstrativos visuais e técnicos em cada etapa

### **Information Flow Design**
```yaml
llm_friendly_principles:
  structured_handoffs: "Contexto completo passado entre comandos"
  progressive_disclosure: "Informação em níveis apropriados de detalhe"
  reference_linking: "Links bidirecionais entre documentos"
  searchable_content: "Tags e categorização consistente"
```

## 📋 Command Chain Architecture

### **1. diagnostico-aprofundado.md**
```yaml
purpose: "Análise aprofundada de código legado vs. documentação atual + estrutura .claude completa"
inputs: ["projeto_alvo", "escopo_analise", "estrutura_claude"]
outputs: ["diagnostico_completo.md", "claude_structure_assessment.md", "plano_atualizacao.md", "matrix_dependencias.md"]
focus: "Alinhamento com ROADMAP_MASTER.md, /docs e estrutura .claude completa antes de implementação"

key_features:
  - claude_structure_validation: "Complete .claude structure assessment (CLAUDE.md + secondary docs)"
  - agents_consistency: "Validation of .claude/agents/ alignment"
  - commands_integration: "Analysis of .claude/commands/ patterns"
  - configs_completeness: "Assessment of .claude/configs/ settings"
  - hooks_implementation: "Evaluation of .claude/hooks/ scripts"
  - docs_synchronization: "Verification of .claude/docs/ accuracy"
  - contraste_com_roadmap: "Validation against strategic planning"
  - gap_identification: "Missing documentation and inconsistencies"
  - dependency_mapping: "Critical interdependency analysis"
```

### **2. planejamento-roadmap-expandido.md**
```yaml
purpose: "Roadmaps detalhados para desenvolvedores junior com matrix de dependências + plano estrutura .claude"
inputs: ["diagnostico_base", "claude_structure_assessment", "objetivos_especificos", "constraints_tecnicas"]
outputs: ["roadmap_detalhado/", "claude_structure_roadmap.md", "matrix_dependencias.md", "testing_strategy.md"]
focus: "Detalhamento extremo para execução autônoma junior developer + evolução estrutura .claude"

key_features:
  - claude_structure_planning: "Detailed plan for .claude structure evolution"
  - agents_definitions_planning: "Specification of required agents definitions"
  - commands_workflows_design: "Custom commands and workflows planning"
  - configs_requirements_definition: "MCP and settings configuration planning"
  - hooks_implementation_strategy: "Python hooks implementation roadmap"
  - docs_update_planning: "Documentation synchronization strategy"
  - junior_developer_ready: "Tarefas de 2-4h executáveis autonomamente"
  - documentation_validation: "Verification de docs internas vs. needs"
  - external_research: "Official source integration quando necessário"
  - testing_framework: "MCP browser/database validation strategy"
```

### **3. executar-roadmap-expandido.md**
```yaml
purpose: "Execução com evidência completa (logs/screenshots) + implementação estrutura .claude e relatório organizado"
inputs: ["roadmap_expandido", "claude_structure_roadmap", "environment_ready", "dependencies_resolved"]
outputs: ["execution_report/", "claude_structure_update/", "evidence/", "artifacts/"]
focus: "Entrega de funcionalidades + evolução estrutura .claude com demonstrativos completos"

key_features:
  - claude_structure_implementation: "Implementation of complete .claude structure updates"
  - agents_deployment: "Deployment and configuration of required agents"
  - commands_activation: "Custom commands and workflows implementation"
  - configs_application: "MCP and settings configuration deployment"
  - hooks_deployment: "Python hooks scripts implementation"
  - docs_updates: "Documentation synchronization with implementation"
  - evidence_collection: "Screenshots, logs, metrics automatizados"
  - continuous_validation: "Testing após cada task"
  - organized_delivery: "LLM-friendly report structure"
  - roadmap_feedback: "Quality assessment do planning process"
```

### **4. validacao-entrega.md**
```yaml
purpose: "Validação de qualidade zero-breakage + verificação estrutura .claude e atualização ROADMAP_MASTER.md"
inputs: ["execution_report", "claude_structure_update", "implementation_artifacts", "test_evidence"]
outputs: ["validation_report.md", "claude_structure_validation.md", "ROADMAP_MASTER.md updates"]
focus: "Zero regression + validação estrutura .claude completa + master roadmap evolution"

key_features:
  - claude_structure_validation: "Complete validation of .claude structure integrity"
  - agents_operational_verification: "Validation of agents definitions functionality"
  - commands_functional_testing: "Testing of custom commands execution"
  - configs_operational_validation: "Verification of MCP and settings configurations"
  - hooks_functionality_testing: "Testing of Python hooks scripts operation"
  - docs_accuracy_verification: "Validation of documentation synchronization"
  - comprehensive_testing: "Regression, integration, performance"
  - business_impact_assessment: "ROI and stakeholder satisfaction"
  - roadmap_master_updates: "Strategic learning integration"
  - continuous_improvement: "Process enhancement pipeline"
```

## 🔗 Information Flow Matrix

### **Handoff Optimization Table (Seven-Layer Docs Enhanced)**
| From Command | To Command | Information Passed | Validation Required |
|--------------|------------|-------------------|-------------------|
| diagnostico-aprofundado | planejamento-roadmap-expandido | • Estado atual VALIDADO<br>• LLM context master document<br>• Evidence-based gaps<br>• Stakeholder protection measures<br>• Dependencies críticas VERIFICADAS | ✅ Evidence validation completa<br>✅ Accuracy vs reality check<br>✅ Seven-layer assessment done |
| planejamento-roadmap-expandido | executar-roadmap-expandido | • Roadmap evidence-based<br>• Seven-layer docs plan<br>• LLM context maintenance strategy<br>• Testing + validation strategy<br>• Risk-prioritized documentation refs | ✅ Evidence-based planning<br>✅ Seven-layer integration ready<br>✅ All dependencies TESTED |
| executar-roadmap-expandido | validacao-entrega | • Implementation evidence + screenshots<br>• LLM context updates<br>• Seven-layer docs maintenance<br>• Quality metrics VALIDATED<br>• Process feedback evidence-based | ✅ Complete evidence collection<br>✅ Seven-layer docs updated<br>✅ All deliverables VALIDATED |
| validacao-entrega | [Next cycle] | • Updated ROADMAP_MASTER evidence-based<br>• Seven-layer docs effectiveness metrics<br>• Process improvements VALIDATED<br>• LLM context master updated<br>• Knowledge updates evidence-based | ✅ Zero regression TESTED<br>✅ Seven-layer docs accuracy<br>✅ Strategic alignment VALIDATED |

### **Context Preservation Strategy**
```yaml
context_management:
  structured_summaries:
    - executive_summary: "High-level context for quick understanding"
    - technical_details: "Implementation-specific information"
    - reference_materials: "Links to supporting documentation"

  dependency_tracking:
    - upstream_context: "Information received from previous command"
    - current_processing: "Transformations applied to information"
    - downstream_preparation: "Context prepared for next command"

  quality_assurance:
    - completeness_check: "All necessary information included"
    - accuracy_validation: "Information verified and consistent"
    - handoff_optimization: "Context structured for LLM efficiency"
```

## 🎯 Key File Integration Strategy

### **ROADMAP_MASTER.md as Living Document (Seven-Layer Enhanced)**
```yaml
master_roadmap_evolution:
  strategic_input: "Feeds EVIDENCE-BASED strategic direction to diagnostico-aprofundado"
  planning_validation: "Validates roadmap-expandido against REALISTIC strategy"
  execution_tracking: "Monitors progress during executar-roadmap with EVIDENCE"
  learning_integration: "Updates with VALIDATED lessons from validacao-entrega"
  seven_layer_integration: "Incorporates Seven-Layer Docs methodology results"
  llm_context_evolution: "Tracks LLM context master document updates"

update_triggers:
  - new_project_initiation: "diagnostico-aprofundado updates priorities"
  - planning_completion: "roadmap-expandido adds detailed timelines"
  - delivery_completion: "validacao-entrega adds outcomes and learnings"
  - strategic_pivots: "External strategy changes trigger updates"
```

### **/docs Integration Pattern (Seven-Layer Enhanced)**
```yaml
documentation_lifecycle:
  evidence_validation: "diagnostico-aprofundado validates claims vs implementation"
  gap_identification: "diagnostico-aprofundado identifies missing docs with EVIDENCE"
  seven_layer_planning: "roadmap-expandido plans Seven-Layer docs strategy"
  creation_planning: "roadmap-expandido plans doc creation/updates EVIDENCE-BASED"
  implementation: "executar-roadmap creates/updates docs with VALIDATION"
  validation: "validacao-entrega ensures docs are ACCURATE and evidence-based"
  continuous_maintenance: "Seven-Layer methodology ensures ongoing accuracy"

doc_categories:
  - setup_guides: "/docs/setup/ - Environment and installation VALIDATED"
  - architecture_docs: "/docs/architecture/ - System design REAL vs aspirational"
  - api_documentation: "/docs/api/ - Interface specifications TESTED"
  - testing_guides: "/docs/testing/ - Testing strategies IMPLEMENTED"
  - deployment_docs: "/docs/deployment/ - Release and operations OPERATIONAL"
  - llm_context: "/docs/07-llm-context/ - LLM initialization and continuity EVIDENCE-BASED"

seven_layer_integration:
  layer_7_llm_context: "/docs/07-llm-context/ as critical layer for LLM workflows"
  evidence_based_accuracy: "All documentation claims validated against implementation"
  stakeholder_protection: "Risk-based prioritization with protective measures"
  continuous_validation: "Weekly/monthly/quarterly accuracy reviews"
```

## 📊 LLM-Friendly Design Patterns

### **Structured Information Architecture**
```yaml
information_design:
  hierarchical_organization:
    - level_1: "Executive summaries for quick context"
    - level_2: "Detailed technical information"
    - level_3: "Implementation specifics and examples"
    - level_4: "Reference materials and troubleshooting"

  cross_referencing:
    - bidirectional_links: "Forward and backward navigation"
    - contextual_references: "Inline links to supporting information"
    - tag_based_organization: "Consistent categorization across documents"
    - search_optimization: "Keywords and metadata for easy discovery"
```

### **Progressive Disclosure Implementation**
```yaml
disclosure_strategy:
  quick_access:
    - executive_summaries: "Key points accessible immediately"
    - status_indicators: "Visual cues for completion status"
    - navigation_aids: "Table of contents and quick links"

  detailed_exploration:
    - expandable_sections: "Detailed information available on demand"
    - contextual_help: "Inline explanations and examples"
    - reference_materials: "Supporting documentation linked appropriately"

  expert_level:
    - technical_specifications: "Complete technical details"
    - troubleshooting_guides: "Comprehensive problem-solving information"
    - customization_options: "Advanced configuration and extension points"
```

## 🔍 Quality Assurance Framework (Seven-Layer Enhanced)

### **Command Template Validation**
```yaml
template_quality_criteria:
  evidence_based_accuracy:
    - claims_validation: "All technical claims validated against implementation"
    - reality_check: "Aspirational vs factual content clearly separated"
    - evidence_sources: "All claims linked to verification sources"
    - continuous_validation: "Procedures for ongoing accuracy maintenance"

  completeness:
    - all_phases_defined: "Clear phases with inputs/outputs EVIDENCE-BASED"
    - dependency_mapping: "All dependencies explicitly documented and TESTED"
    - success_criteria: "Measurable outcomes defined with VALIDATION methods"
    - seven_layer_integration: "Seven-Layer Docs methodology incorporated"

  stakeholder_protection:
    - risk_assessment: "Stakeholder risk analysis included"
    - legal_compliance: "Legal/compliance requirements identified"
    - protective_measures: "Immediate protection for high-risk stakeholders"
    - error_prevention: "Context to prevent perpetuating false claims"

  usability:
    - junior_developer_friendly: "Executable by junior developers with EVIDENCE"
    - clear_instructions: "Step-by-step procedures documented and TESTED"
    - error_handling: "Common problems and solutions included with VALIDATION"
    - llm_friendly: "LLM-optimized markup and navigation"

  integration:
    - upstream_compatibility: "Inputs match upstream outputs with EVIDENCE validation"
    - downstream_preparation: "Outputs ready for downstream consumption with ACCURACY"
    - reference_accuracy: "All links and references VERIFIED and functional"
    - seven_layer_consistency: "Consistent with Seven-Layer Docs methodology"
```

### **Continuous Improvement Mechanism**
```yaml
improvement_tracking:
  usage_analytics:
    - command_execution_frequency: "Which commands are used most"
    - success_rate_tracking: "Command completion rates"
    - time_to_completion: "Efficiency metrics per command"

  feedback_collection:
    - user_experience_feedback: "Developer satisfaction with commands"
    - process_improvement_suggestions: "Workflow optimization opportunities"
    - documentation_gap_reports: "Missing information identification"

  iterative_enhancement:
    - template_updates: "Commands improved based on feedback"
    - process_optimization: "Workflow efficiency improvements"
    - automation_expansion: "Increased automation where beneficial"
```

---

**💡 System Philosophy (Seven-Layer Enhanced)**: Os comandos formam um pipeline de transformação de informação **evidence-based** onde cada etapa adiciona valor e contexto **VALIDADO**, culminando em entregáveis de alta qualidade com zero regressão, máxima transparência para stakeholders e **proteção baseada em evidências**. Seguindo a metodologia Seven-Layer Docs, a documentação é **PROTECTIVE first, helpful second**, prevenindo harm através de accuracy e stakeholder protection, especialmente crítico para domínios sensíveis como médico/healthcare.

**🔗 Uso**: Leia este overview antes de usar qualquer command individual
**🔗 Start**: Comece sempre com `/diagnostico-aprofundado` para evidence-based foundation