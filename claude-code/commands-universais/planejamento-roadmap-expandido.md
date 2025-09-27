# 🗺️ Planejamento Roadmap Expandido - Command Template

## 📋 **RESUMO EXECUTIVO**

**🎯 O que faz**: Cria roadmaps detalhados evidence-based para desenvolvedores junior com Seven-Layer Docs integration

**📥 Inputs necessários**:
- Output do `/diagnostico-aprofundado` (diagnóstico base + LLM context master)
- Objetivos específicos da implementação
- Constraints técnicas validadas
- Timeline alvo realista

**📤 Outputs gerados**:
- `roadmap-detalhado/` - Plano completo evidence-based
- `seven-layer-docs-plan.md` - Estratégia manutenção documentação
- `llm-context-maintenance.md` - Procedimentos /docs/07-llm-context/
- `stakeholder-protection.md` - Medidas proteção baseadas em risco
- `testing-strategy.md` - Plano validação MCP + evidence

**⚠️ Critical**: Tarefas de 2-4h executáveis autonomamente com evidence validation

---

Gera roadmaps detalhados com direcionamentos específicos para desenvolvedores junior, incluindo matrix de dependências e validação completa.

## 📋 Fluxo de Execução

### **Fase 1: Recebimento e Processamento de Contextos**
```yaml
inputs_necessarios:
  - diagnostico_base: "Output do /diagnostico-aprofundado"
  - objetivos_especificos: "Metas da implementação"
  - constraints_tecnicas: "Limitações conhecidas"
  - timeline_alvo: "Prazo para entrega"

processamento_contexto:
  - validacao_completude: "Verificar se todos os contextos necessários estão disponíveis"
  - gap_identification: "Identificar documentação faltante"
  - dependency_mapping: "Mapear dependências entre tarefas"
```

### **Fase 2: Geração de Roadmap Detalhado**
```yaml
estrutura_roadmap:
  nivel_detalhamento: "Junior-developer-ready"
  granularidade: "Tarefas de 2-4 horas cada"
  documentacao_referencia: "Links explícitos para /docs relevantes"

criterios_qualidade:
  - autonomia_execucao: "Developer junior pode executar sem ajuda senior"
  - validacao_continua: "Checkpoints de validação em cada etapa"
  - recuperacao_erros: "Instruções de troubleshooting"
```

### **Fase 3: Matrix de Dependências e Documentação**
```yaml
matrix_dependencias:
  contexto_necessario: "Conhecimento prévio requerido para cada tarefa"
  docs_internas: "Referências específicas em /docs"
  docs_externas: "Fontes oficiais quando necessário"
  ordem_execucao: "Sequenciamento otimizado de tarefas"

validacao_cobertura:
  - documentacao_suficiente: "Verificar se há docs para fundamentar execução"
  - fontes_oficiais: "Identificar necessidade de pesquisa externa"
  - gaps_conhecimento: "Documentar lacunas para criação futura"
```

## 🔗 Research & Documentation Strategy

### **Verificação de Documentação Interna**
```yaml
docs_internos_check:
  documento_principal:
    - CLAUDE.md: "Configurações LLM e diretrizes gerais"

  documentos_secundarios:
    - .claude/agents/: "Definições de agentes disponíveis"
    - .claude/commands/: "Comandos customizados e workflows"
    - .claude/configs/: "Configurações MCP e settings"
    - .claude/hooks/: "Scripts Python de interceptação"
    - .claude/docs/: "Documentação específica do projeto"

  docs_projeto:
    - /docs/setup/: "Configuração inicial e ambiente"
    - /docs/architecture/: "Padrões arquiteturais"
    - /docs/api/: "Interfaces e contratos"
    - /docs/testing/: "Estratégias de teste"
    - /docs/deployment/: "Processos de deploy"

gap_handling:
  estrutura_claude_completa:
    - agents_consistency: "Verificar alinhamento .claude/agents/ com CLAUDE.md"
    - commands_integration: "Validar .claude/commands/ seguindo padrões"
    - configs_completeness: "Assegurar .claude/configs/ completo"
    - hooks_implementation: "Verificar .claude/hooks/ conforme templates"
    - docs_synchronization: "Validar .claude/docs/ atualizado"

  docs_projeto:
    - missing_internal: "Marcar para criação após pesquisa oficial"
    - outdated_internal: "Sinalizar para atualização"
    - incomplete_internal: "Complementar com fontes oficiais"
```

### **Pesquisa em Fontes Oficiais**
```yaml
official_sources_strategy:
  tecnologias_principais: "Identificar docs oficiais relevantes"
  best_practices: "Práticas recomendadas pela comunidade"
  troubleshooting: "Guias de resolução de problemas"

integration_workflow:
  - research_oficial: "Buscar informações em docs oficiais"
  - synthesize_content: "Adaptar para contexto do projeto"
  - create_internal_docs: "Gerar documentação interna atualizada"
  - reference_mapping: "Linkar com roadmap expandido"
```

## 🧪 Testing & Validation Framework

### **MCP Browser/Database Testing Strategy**
```yaml
browser_automation_tests:
  ui_validation:
    - visual_regression: "Screenshots comparativos"
    - responsive_testing: "Multi-viewport validation"
    - user_flows: "Jornadas críticas do usuário"

  functional_testing:
    - form_submissions: "Validação de formulários"
    - authentication: "Fluxos de login/logout"
    - data_manipulation: "CRUD operations"

database_validation:
  data_integrity:
    - schema_validation: "Estrutura de dados"
    - constraint_checking: "Regras de negócio"
    - performance_testing: "Query optimization"

  migration_testing:
    - backup_verification: "Integridade dos backups"
    - rollback_procedures: "Processo de reversão"
    - data_migration: "Transferência sem perdas"
```

### **Log Analysis & Monitoring**
```yaml
log_validation_strategy:
  application_logs:
    - error_tracking: "Identificação de erros"
    - performance_metrics: "Tempos de resposta"
    - user_activity: "Padrões de uso"

  infrastructure_logs:
    - resource_usage: "CPU, memória, disco"
    - network_performance: "Latência e throughput"
    - security_events: "Tentativas de acesso"

automated_verification:
  - log_parsing: "Scripts de análise automatizada"
  - alert_configuration: "Notificações de anomalias"
  - dashboard_setup: "Visualização em tempo real"
```

## 📦 Entregáveis Organization

### **Estrutura de Deliverables**
```yaml
organized_delivery:
  roadmap_master/
  ├── 01-executive-summary.md
  ├── 02-detailed-roadmap.md
  ├── 03-dependency-matrix.md
  ├── 04-testing-strategy.md
  ├── 05-evidence-validation-plan.md  # Evidence-based validation procedures
  ├── 06-seven-layer-docs-plan.md     # Seven-layer documentation maintenance
  ├── 07-llm-context-maintenance.md   # /docs/07-llm-context/ upkeep
  ├── 08-claude-structure-validation.md  # Estrutura .claude completa
  ├── 09-stakeholder-protection.md   # Risk-based stakeholder protection measures
  ├── 10-documentation-gaps.md
  ├── 11-risk-assessment.md
  └── artifacts/
      ├── templates/
      ├── scripts/
      └── references/

llm_friendly_structure:
  - clear_navigation: "Índice detalhado com links"
  - contextual_references: "Links bidirecionais"
  - progressive_disclosure: "Informação em níveis de detalhe"
  - searchable_content: "Tags e categorização"
```

### **Quality Assurance Template**
```markdown
# Roadmap Expandido - Quality Checklist

## ✅ Completude
- [ ] Todas as tarefas quebradas em unidades de 2-4h
- [ ] Developer junior pode executar autonomamente
- [ ] Documentação de referência linkada
- [ ] Matrix de dependências mapeada

## ✅ Testabilidade
- [ ] Fluxos de teste UI definidos
- [ ] Validação de database especificada
- [ ] Log analysis procedures documentados
- [ ] MCP automation scripts preparados

## ✅ Documentação (Evidence-Based + Seven-Layer)
### Estrutura .claude Completa
- [ ] Estrutura .claude completa validada (CLAUDE.md + secundários) COM TESTES
- [ ] .claude/agents/ alinhado com diretrizes principais FUNCIONAIS
- [ ] .claude/commands/ implementado conforme padrões TESTADOS
- [ ] .claude/configs/ com configurações completas OPERACIONAIS
- [ ] .claude/hooks/ seguindo templates disponíveis IMPLEMENTADOS
- [ ] .claude/docs/ sincronizado com implementações REAIS

### Seven-Layer Documentation Method
- [ ] /docs/07-llm-context/ atualizado e LLM-friendly
- [ ] Evidence-based accuracy em todas alegações técnicas
- [ ] Stakeholder protection measures implementadas
- [ ] Legal/compliance warnings adequados (se domínio sensível)
- [ ] Continuous validation procedures estabelecidos
- [ ] Error prevention context para LLMs configurado

### Documentação Projeto
- [ ] Gaps de documentação projeto identificados e PRIORIZADOS POR RISCO
- [ ] Fontes oficiais researched quando necessário COM VALIDAÇÃO
- [ ] Internal docs atualizados BASEADOS EM REALIDADE
- [ ] Reference links funcionais e VERIFICADOS

## ✅ Executabilidade
- [ ] Ordem de execução otimizada
- [ ] Troubleshooting instructions incluídas
- [ ] Rollback procedures documentados
- [ ] Success criteria definidos
```

## 🎯 LLM-Friendly Design Patterns

### **Information Handoff Optimization**
```yaml
context_preservation:
  upstream_integration:
    - diagnostico_results: "Estado atual mapeado"
    - strategic_goals: "Objetivos de alto nível"
    - technical_constraints: "Limitações conhecidas"

  downstream_preparation:
    - execution_context: "Contexto completo para implementação"
    - validation_criteria: "Critérios de sucesso claros"
    - recovery_procedures: "Instruções de contingência"

structured_handoff:
  - context_summary: "Resumo executivo dos contextos"
  - detailed_specifications: "Especificações técnicas completas"
  - reference_materials: "Materiais de apoio organizados"
```

### **Junior Developer Empowerment**
```yaml
skill_level_accommodation:
  task_granularity: "Quebrar em unidades digestíveis"
  context_provision: "Fornecer todo contexto necessário"
  learning_resources: "Links para aprendizado adicional"

autonomy_enablement:
  - step_by_step: "Instruções detalhadas passo a passo"
  - expected_outputs: "Exemplos de resultados esperados"
  - common_pitfalls: "Erros comuns e como evitar"
  - verification_methods: "Como validar o próprio trabalho"
```

## 🔄 Integration Pattern

### **Command Chain Integration**
```yaml
input_chain:
  /diagnostico-aprofundado → context_foundation
  project_requirements → specific_objectives
  timeline_constraints → realistic_planning

output_chain:
  detailed_roadmap → /executar-roadmap-expandido
  testing_strategy → validation_framework
  documentation_gaps → knowledge_management
```

### **Feedback Loop Mechanism**
```yaml
continuous_improvement:
  execution_feedback: "Learnings from implementation"
  documentation_updates: "Gaps identified during execution"
  process_optimization: "Workflow improvements"

quality_metrics:
  - execution_success_rate: "% de tarefas completadas conforme planejado"
  - documentation_accuracy: "Precisão das instruções fornecidas"
  - developer_satisfaction: "Feedback de usabilidade"
```

---

**💡 Success Pattern**: Roadmap expandido deve ser tão detalhado que um developer junior recém-chegado possa executar com 90% de autonomia, tendo acesso a todos os contextos e referências necessários.

**🔗 Command Anterior**: `/diagnostico-aprofundado` (fornece contexto base)
**🔗 Próximo Command**: `/executar-roadmap-expandido` (utiliza roadmap gerado)