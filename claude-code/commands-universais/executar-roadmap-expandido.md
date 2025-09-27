# ⚡ Executar Roadmap Expandido - Command Template

## 📋 **RESUMO EXECUTIVO**

**🎯 O que faz**: Executa roadmap com evidence collection completa + Seven-Layer Docs maintenance

**📥 Inputs necessários**:
- Output do `/planejamento-roadmap-expandido` (roadmap detalhado)
- Ambiente configurado e validado
- Dependências resolvidas
- Estrutura .claude completa verificada

**📤 Outputs gerados**:
- `execution-report/` - Relatório LLM-friendly organizado
- `claude-structure-update/` - Evidências atualizações .claude
- `evidence/` - Screenshots, logs, métricas (before/during/after)
- `artifacts/` - Código, configs, documentação
- `roadmap-feedback.md` - Assessment qualidade planning process

**⚠️ Critical**: Evidence collection obrigatória (Anthropic 2025 TDD) + stakeholder protection

---

Executa roadmap detalhado entregando funcionalidades, demonstrativos (logs/screenshots) e relatório organizado com todos os entregáveis.

## 📋 Fluxo de Execução

### **Fase 1: Preparação e Validação**
```yaml
inputs_necessarios:
  - roadmap_expandido: "Output do /planejamento-roadmap-expandido"
  - environment_ready: "Ambiente configurado e validado"
  - dependencies_resolved: "Dependências instaladas"
  - documentation_accessible: "Docs internas e externas disponíveis"
  - claude_structure_validated: "Estrutura .claude completa verificada"

pre_execution_validation:
  estrutura_claude_completa:
    - claude_md_alignment: "CLAUDE.md alinhado com roadmap"
    - agents_definitions: ".claude/agents/ com definições necessárias"
    - commands_availability: ".claude/commands/ com workflows requeridos"
    - configs_completeness: ".claude/configs/ com configurações MCP"
    - hooks_implementation: ".claude/hooks/ scripts Python prontos"
    - docs_synchronization: ".claude/docs/ atualizado com projeto"

  ambiente_execucao:
    - roadmap_completeness: "Verificar se roadmap tem detalhes suficientes"
    - resource_availability: "Confirmar recursos necessários disponíveis"
    - testing_environment: "MCP browser/database funcionando"
    - backup_procedures: "Sistema de backup validado"
```

### **Fase 2: Execução Iterativa com Evidência**
```yaml
execution_pattern:
  granularidade: "Tarefas de 2-4h executadas individualmente"
  validation_continuous: "Validação após cada tarefa"
  evidence_collection: "Screenshots + logs + outputs"
  rollback_ready: "Ponto de restore sempre disponível"

evidence_framework:
  visual_proof:
    - before_screenshots: "Estado inicial das UIs"
    - during_implementation: "Progresso visual"
    - after_screenshots: "Estado final validado"
    - error_captures: "Screenshots de erros encontrados"

  technical_proof:
    - application_logs: "Logs estruturados da aplicação"
    - database_changes: "Scripts e resultados de migrations"
    - performance_metrics: "Tempos de resposta e recursos"
    - test_results: "Output de testes automatizados"
```

### **Fase 3: Validação e Relatório Organizado**
```yaml
comprehensive_validation:
  functional_testing:
    - mcp_browser_automation: "Fluxos críticos validados"
    - database_integrity: "Consistência de dados"
    - api_endpoints: "Contratos de interface"
    - integration_points: "Comunicação entre sistemas"

  quality_assurance:
    - code_review_automated: "Linting e análise estática"
    - security_scanning: "Verificação de vulnerabilidades"
    - performance_benchmarking: "Comparação com baseline"
    - documentation_sync: "Docs atualizados"
```

## 📊 LLM-Friendly Reporting Structure

### **Organized Deliverables Folder**
```yaml
execution_report_structure:
  /execution-report-YYYY-MM-DD/
  ├── 00-executive-summary.md
  ├── 01-implementation-log.md
  ├── 02-quality-assessment.md
  ├── 03-claude-structure-update.md  # Atualizações na estrutura .claude
  ├── 04-roadmap-feedback.md
  ├── 05-documentation-updates.md
  └── evidence/
      ├── screenshots/
      │   ├── before/
      │   ├── during/
      │   └── after/
      ├── logs/
      │   ├── application/
      │   ├── database/
      │   └── infrastructure/
      ├── test-results/
      │   ├── automated/
      │   ├── manual/
      │   └── performance/
      └── artifacts/
          ├── code-changes/
          ├── database-scripts/
          └── configuration-files/
```

### **Executive Summary Template**
```markdown
# Execution Report - Executive Summary

## 🎯 Objetivos Alcançados
- ✅ Funcionalidade X implementada com sucesso
- ✅ Performance target atingido (X ms → Y ms)
- ✅ Testes automatizados passando (XX/XX)

## 📊 Métricas de Qualidade
- **Code Coverage**: XX% (target: 80%)
- **Performance Improvement**: XX% faster
- **Bug Count**: X critical, Y minor
- **Documentation Updated**: XX files

## 🔍 Evidências Coletadas
- Screenshots: XX files in evidence/screenshots/
- Logs Analysis: XX entries processed
- Test Results: XX automated tests executed
- Performance Metrics: XX benchmarks collected

## 📋 Roadmap Feedback
### ✅ O que funcionou bem
- Detalhamento adequado para execução autônoma
- Documentação interna suficiente
- Testing strategy efetiva

### ⚠️ Gaps identificados durante execução
- Documentação missing: [específicas áreas]
- External research needed: [tecnologias específicas]
- Process improvements: [sugestões]

## 🎯 Next Steps Recomendados
- Priority 1: [ação crítica]
- Priority 2: [melhoria importante]
- Priority 3: [enhancement futuro]
```

## 🧪 Automated Testing & Validation

### **MCP Browser Automation Strategy**
```yaml
browser_testing_implementation:
  setup_validation:
    - viewport_configurations: "Desktop, tablet, mobile"
    - browser_compatibility: "Chrome, Firefox, Safari"
    - authentication_states: "Anonymous, user, admin"

  functional_flows:
    - user_registration: "Complete signup flow"
    - login_logout: "Authentication cycles"
    - crud_operations: "Create, read, update, delete"
    - form_submissions: "All form types in application"

  visual_validation:
    - screenshot_comparison: "Before/after implementation"
    - responsive_behavior: "Layout em diferentes viewports"
    - error_states: "Error messages e fallbacks"
    - loading_states: "Spinners e progressos"

automation_scripts:
  playwright_templates:
    - test-user-flows.js: "Jornadas críticas do usuário"
    - test-admin-functions.js: "Funcionalidades administrativas"
    - test-responsive-design.js: "Validação multi-device"
    - capture-evidence.js: "Coleta automatizada de evidências"
```

### **Database Validation Framework**
```yaml
database_testing_strategy:
  schema_validation:
    - migration_integrity: "Aplicação correta de migrations"
    - constraint_verification: "Foreign keys e validações"
    - index_optimization: "Performance de queries"
    - data_consistency: "Integridade referencial"

  performance_testing:
    - query_benchmarking: "Tempo de execução de queries críticas"
    - connection_pooling: "Eficiência de conexões"
    - transaction_handling: "Atomicidade de operações"
    - concurrent_access: "Comportamento sob carga"

  backup_recovery:
    - backup_creation: "Processo automatizado de backup"
    - recovery_testing: "Validação de restore procedures"
    - data_migration: "Transferência entre ambientes"
```

## 📈 Performance Monitoring & Metrics

### **Real-time Performance Tracking**
```yaml
metrics_collection:
  claude_structure_performance:
    - agents_efficiency: "Performance de agentes definidos"
    - commands_execution: "Tempo de execução de commands customizados"
    - hooks_overhead: "Impact de hooks Python na performance"
    - mcp_integration: "Eficiência integração MCP"

  application_performance:
    - response_times: "API endpoints performance"
    - memory_usage: "Heap e garbage collection"
    - cpu_utilization: "Processing efficiency"
    - database_performance: "Query execution times"

  user_experience_metrics:
    - page_load_times: "First contentful paint"
    - interaction_responsiveness: "Time to interactive"
    - error_rates: "Client-side e server-side errors"
    - conversion_funnels: "User flow completion rates"

automated_monitoring:
  - performance_dashboard: "Real-time metrics visualization"
  - alert_configuration: "Thresholds para notificações"
  - trend_analysis: "Historical performance data"
  - capacity_planning: "Resource usage projections"
```

## 🔄 Continuous Feedback Loop

### **Roadmap Quality Assessment**
```yaml
roadmap_effectiveness_metrics:
  execution_accuracy:
    - task_completion_rate: "% tarefas completadas conforme planejado"
    - time_estimation_accuracy: "Desvio de estimativas temporais"
    - dependency_prediction: "Precisão de mapeamento dependências"
    - documentation_sufficiency: "% tarefas executáveis sem help adicional"

  quality_outcomes:
    - bug_introduction_rate: "Defeitos por feature implementada"
    - rework_percentage: "% código que precisou ser refeito"
    - testing_coverage: "Cobertura de testes alcançada"
    - documentation_updates: "Docs criados/atualizados"

improvement_recommendations:
  process_optimization:
    - better_task_breakdown: "Granularidade mais efetiva"
    - improved_documentation: "Gaps específicos identificados"
    - enhanced_testing: "Strategy adjustments needed"
    - tooling_improvements: "Automação adicional requerida"
```

### **External Documentation Integration**
```yaml
external_research_feedback:
  sources_utilized:
    - official_documentation: "Docs oficiais consultados"
    - community_resources: "Stack Overflow, GitHub issues"
    - best_practices_guides: "Industry standards applied"
    - troubleshooting_resources: "Problem resolution sources"

  knowledge_gaps_filled:
    - technology_specifics: "Aspectos técnicos não documentados"
    - integration_patterns: "Padrões de integração descobertos"
    - performance_optimization: "Técnicas de otimização aplicadas"
    - security_considerations: "Práticas de segurança implementadas"

documentation_update_plan:
    - internal_docs_creation: "Novos documentos necessários"
    - existing_docs_updates: "Melhorias em docs existentes"
    - knowledge_base_expansion: "Adições ao knowledge base"
    - reference_links_update: "Atualização de links externos"
```

## 🎯 Success Criteria & Validation

### **Implementation Success Metrics**
```yaml
functional_success:
  - feature_completeness: "100% funcionalidades implementadas"
  - test_coverage: "≥80% automated test coverage"
  - performance_targets: "Response times within SLA"
  - security_compliance: "Security scans passing"

quality_success:
  - code_review_approval: "Peer review completed"
  - documentation_updated: "All relevant docs current"
  - deployment_readiness: "Production deployment validated"
  - rollback_tested: "Recovery procedures verified"

process_success:
  - roadmap_adherence: "≥90% tasks completed as planned"
  - timeline_accuracy: "Delivery within estimated timeframe"
  - resource_efficiency: "Budget e resource utilization optimal"
  - stakeholder_satisfaction: "Requirements met satisfactorily"
```

---

**💡 Execution Philosophy**: Cada tarefa deve ser executada com máxima transparência, coletando evidências suficientes para demonstrar qualidade e fornecer feedback valioso para melhorias futuras do processo.

**🔗 Command Anterior**: `/planejamento-roadmap-expandido` (fornece roadmap para execução)
**🔗 Próximo Command**: `/validacao-entrega` (valida resultados da execução)