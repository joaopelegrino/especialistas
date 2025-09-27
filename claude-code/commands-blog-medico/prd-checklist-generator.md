# 📋 PRD Checklist Generator - Command Template

## 📋 **RESUMO EXECUTIVO**

**🎯 O que faz**: Gera e atualiza documento central de PRD em formato checklist baseado nos requirements originais, com verificação evidence-based via Playwright

**📥 Inputs necessários**:
- /docs/01-internal-tech/requirements-and-vision/ (especificações originais)
- Configuração Playwright (playwright.config.js)
- Estado atual do projeto via navegação automatizada
- Screenshots e evidências de funcionalidades

**📤 Outputs gerados**:
- `prd-checklist-master.md` - Documento central PRD com status de cada requirement
- `verification-evidence/` - Pasta com screenshots e evidências coletadas
- `implementation-gaps-report.md` - Relatório de gaps entre especificado e implementado
- `playwright-test-results.json` - Resultados detalhados dos testes automatizados

**⚠️ Critical**: Utiliza Playwright para verificação automatizada de funcionalidades e coleta de evidências visuais

---

Este comando cria/atualiza um PRD centralizado em formato checklist, marcando cada requirement com seu estado de implementação atual após verificação automatizada.

## 📋 Fluxo de Execução

### **Fase 0: CRÍTICA - Setup e Preparação (OBRIGATÓRIA)**
```yaml
environment_setup:
  - verificar_playwright_config: "Validar configuração Playwright existente"
  - preparar_servidor_phoenix: "Garantir que mix phx.server está rodando"
  - validar_estrutura_requirements: "Verificar pasta requirements-and-vision/ completa"
  - setup_evidence_collection: "Criar estrutura para screenshots e logs"

requirements_parsing:
  - scan_visao_produto: "Extrair objetivos estratégicos de 00_VISAO_E_PRODUTO.md"
  - parse_arquitetura_funcional: "Extrair papéis de usuário de 01_ARQUITETURA_FUNCIONAL.md"
  - extract_technical_specs: "Processar especificações técnicas de 02_ARQUITETURA_TECNICA/"
  - compliance_requirements: "Extrair requisitos de 03_COMPLIANCE/"
  - performance_requirements: "Processar 04_REQUISITOS_NAO_FUNCIONAIS.md"
  - wordpress_parity: "Analisar paridade WordPress de 06_PARIDADE_FUNCIONAL.md"
```

### **Fase 1: Geração de Checklist PRD**
```yaml
inputs_necessarios:
  - requirements_source: "📁 /docs/01-internal-tech/requirements-and-vision/ completa"
  - playwright_config: "playwright.config.js configurado para testes E2E"
  - server_endpoint: "URL do servidor Phoenix (ex: http://localhost:4000)"
  - test_credentials: "Credenciais de teste para diferentes papéis de usuário"

checklist_generation:
  - strategic_objectives: "Converter objetivos estratégicos em checkboxes verificáveis"
  - functional_architecture: "Mapear papéis de usuário em testes de acesso"
  - technical_requirements: "Traduzir specs técnicas em testes automatizados"
  - compliance_checklist: "Criar verificações LGPD/ANVISA/SBIS-CFM"
  - performance_benchmarks: "Definir métricas mensuráveis de performance"
  - wordpress_parity_items: "Listar funcionalidades WordPress para verificação"

outputs_gerados:
  - prd_checklist_structured: "PRD estruturado com requirements categorizados"
  - playwright_test_suite: "Suite de testes automatizados para cada requirement"
  - verification_matrix: "Matrix de verificação requirement → teste → evidência"
```

### **Fase 2: Verificação Automatizada com Playwright**
```yaml
automated_verification:
  - server_health_check: "Verificar se Phoenix server está acessível"
  - authentication_flow: "Testar login/logout para diferentes papéis"
  - interface_navigation: "Navegar e capturar screenshots das principais interfaces"
  - functionality_verification: "Executar testes específicos para cada feature"
  - performance_measurement: "Medir Core Web Vitals e tempos de resposta"
  - compliance_validation: "Verificar elementos de conformidade LGPD"

evidence_collection:
  - screenshot_capture: "Capturar evidências visuais de cada funcionalidade"
  - console_logs: "Coletar logs do navegador para debugging"
  - network_analysis: "Analisar requests/responses para APIs"
  - accessibility_audit: "Verificar conformidade com padrões de acessibilidade"
  - mobile_responsive: "Testar responsividade em diferentes viewports"

outputs_gerados:
  - verification_evidence: "📁 Pasta organizada com screenshots e logs"
  - test_execution_log: "Log detalhado da execução dos testes"
  - performance_metrics: "Métricas coletadas de performance"
  - accessibility_report: "Relatório de acessibilidade"
```

### **Fase 3: Geração do PRD Final com Status**
```yaml
status_classification:
  requirement_states:
    - "✅ IMPLEMENTED": "Funcionalidade implementada e testada com sucesso"
    - "⚠️ PARTIAL": "Implementação parcial identificada"
    - "❌ NOT_IMPLEMENTED": "Funcionalidade não encontrada/não funcional"
    - "🔄 IN_PROGRESS": "Implementação em progresso (evidências parciais)"
    - "🚫 BLOCKED": "Bloqueado por dependências ou problemas técnicos"
    - "📋 NEEDS_VERIFICATION": "Requer verificação manual adicional"

evidence_linking:
  - screenshot_references: "Linkear cada status com evidências visuais"
  - test_case_mapping: "Mapear requirements com casos de teste específicos"
  - gap_analysis: "Identificar discrepâncias entre especificado e implementado"

entregas_finais:
  - prd_checklist_master.md: "📋 PRD central com status atualizado de todos requirements"
  - implementation_gaps_report.md: "📊 Relatório de gaps e próximos passos"
  - verification_evidence/: "📁 Evidências organizadas (screenshots, logs, métricas)"
  - playwright_test_results.json: "🧪 Resultados detalhados dos testes automatizados"
  - compliance_status_report.md: "⚖️ Status de conformidade LGPD/ANVISA"
```

## 🔗 Dependências de Contexto

### **Pré-requisitos**
- ✅ Pasta /docs/01-internal-tech/requirements-and-vision/ completa
- ✅ Playwright configurado (playwright.config.js)
- ✅ Phoenix server rodando (mix phx.server)
- ✅ Credenciais de teste para diferentes usuários
- ✅ Node.js e dependências Playwright instaladas

### **Contextos Necessários**
- 🔍 **Requirements originais**: Especificações completas em requirements-and-vision/
- 🌐 **Interface funcionando**: Phoenix server acessível para testes
- 🧪 **Ambiente de teste**: Configuração Playwright para E2E testing
- 📊 **Baseline metrics**: Métricas de performance para comparação
- 👥 **User scenarios**: Cenários de teste para diferentes papéis

## 📊 Template de Saída

### **prd_checklist_master.md Structure**
```markdown
# 📋 PRD Master Checklist - Blog Médico - [DATA]
<!-- @prd-checklist: central requirements tracking -->

## 🎯 **VISÃO E PRODUTO** - Status Geral: [X/Y Implementado]

### Objetivos Estratégicos
- [ ] ✅ **Evolução Tecnológica**: Sistema Elixir/Phoenix eliminando dependência de plugins
  - **Evidence**: screenshots/tech-stack-evidence.png
  - **Test**: playwright-tests/tech-stack-verification.spec.js
  - **Status**: IMPLEMENTED
  - **Last Verified**: [DATA]

- [ ] ⚠️ **Funcionalidade Core**: Flexibilidade de construção de conteúdo (Elementor/ACF equivalence)
  - **Evidence**: screenshots/content-builder-partial.png
  - **Test**: playwright-tests/content-builder.spec.js
  - **Status**: PARTIAL - Wizard implementado, builder visual missing
  - **Gap**: Visual page builder não implementado
  - **Last Verified**: [DATA]

### Papéis de Usuário
- [ ] ✅ **Administrador**: Superusuário com acesso total
  - **Evidence**: screenshots/admin-interface.png
  - **Test**: playwright-tests/admin-access.spec.js
  - **Status**: IMPLEMENTED
  - **Verified Features**: User management, global settings, content access
  - **Last Verified**: [DATA]

- [ ] ❌ **Planejador de Conteúdo**: Marketing/SEO role
  - **Evidence**: N/A
  - **Test**: playwright-tests/content-planner.spec.js
  - **Status**: NOT_IMPLEMENTED
  - **Gap**: Role não implementado no sistema
  - **Last Verified**: [DATA]

## 🏗️ **ARQUITETURA TÉCNICA** - Status Geral: [X/Y Implementado]

### Stack e Frontend
- [ ] ✅ **Phoenix LiveView**: Interface 100% nativa
  - **Evidence**: screenshots/liveview-implementation.png
  - **Test**: playwright-tests/liveview-functionality.spec.js
  - **Status**: IMPLEMENTED
  - **Performance**: Core Web Vitals [metrics]
  - **Last Verified**: [DATA]

### Segurança
- [ ] ⚠️ **Zero Trust Model**: Implementação de arquitetura Zero Trust
  - **Evidence**: screenshots/security-features.png
  - **Test**: playwright-tests/security-audit.spec.js
  - **Status**: PARTIAL
  - **Implemented**: Basic authentication, role-based access
  - **Missing**: MFA, advanced authorization policies
  - **Last Verified**: [DATA]

## ⚖️ **COMPLIANCE** - Status Geral: [X/Y Implementado]

### LGPD
- [ ] 🚫 **Privacy by Design**: Conformidade LGPD
  - **Evidence**: screenshots/privacy-violations.png
  - **Test**: playwright-tests/lgpd-compliance.spec.js
  - **Status**: BLOCKED
  - **Critical Issues**: Potential fines up to R$50M identified
  - **Gap**: 49% LGPD compliance only
  - **Last Verified**: [DATA]

## 📈 **PERFORMANCE** - Status Geral: [X/Y Implementado]

### WebAssembly Optimization
- [ ] 🔄 **Bundle Size**: 22.2MB → <3MB target
  - **Evidence**: performance/bundle-analysis.json
  - **Test**: playwright-tests/performance-metrics.spec.js
  - **Status**: IN_PROGRESS
  - **Current**: 22.2MB bundle size
  - **Target**: <3MB optimized
  - **Last Verified**: [DATA]

## 🔄 **WORDPRESS PARITY** - Status Geral: [X/Y Implementado]

### Basic CMS Features
- [ ] ❌ **Dashboard WordPress**: Equivalent to WP admin dashboard
  - **Evidence**: screenshots/missing-wp-dashboard.png
  - **Test**: playwright-tests/wordpress-parity.spec.js
  - **Status**: NOT_IMPLEMENTED
  - **Gap**: Only wizard available, missing basic CMS interface
  - **WordPress Features Missing**: Sidebar navigation, dashboard widgets, quick actions
  - **Last Verified**: [DATA]

---

## 📊 **SUMMARY STATISTICS**
- **Total Requirements**: [TOTAL]
- **✅ Implemented**: [COUNT] ([PERCENTAGE]%)
- **⚠️ Partial**: [COUNT] ([PERCENTAGE]%)
- **❌ Not Implemented**: [COUNT] ([PERCENTAGE]%)
- **🔄 In Progress**: [COUNT] ([PERCENTAGE]%)
- **🚫 Blocked**: [COUNT] ([PERCENTAGE]%)

## 🚨 **CRITICAL GAPS IDENTIFIED**
1. **LGPD Compliance**: 49% only - Legal risk up to R$50M
2. **WordPress Parity**: 42% only - Missing basic CMS features
3. **User Roles**: Content Planner and other roles not implemented
4. **Performance**: Bundle optimization in progress (22.2MB → <3MB target)

## 📁 **EVIDENCE FILES**
- `verification-evidence/screenshots/` - Visual evidence of features
- `verification-evidence/performance/` - Performance metrics and logs
- `verification-evidence/compliance/` - LGPD/ANVISA compliance evidence
- `playwright-test-results.json` - Detailed test execution results

## 🔄 **NEXT VERIFICATION**
- **Scheduled**: [DATE]
- **Focus Areas**: Critical gaps and blocked items
- **Test Suite Updates**: Based on new implementations
```

## 🎯 Critérios de Sucesso

### **Qualidade da Verificação**
- ✅ Todos requirements verificados via Playwright
- ✅ Screenshots capturados para evidência visual
- ✅ Estados de implementação precisos e atualizados
- ✅ Gaps críticos identificados com detalhamento

### **Utilidade do PRD**
- ✅ Checklist utilizável pela equipe de produto
- ✅ Evidências linkadas para cada requirement
- ✅ Gaps priorizados por risco e impacto
- ✅ Roadmap de próximas implementações

## 🔄 Integration com Outros Commands

### **Fluxo Upstream** (inputs recebidos)
- `/diagnostico-aprofundado` ← fornece análise de estado atual
- Requirements originais da pasta requirements-and-vision/
- Configurações de teste e credenciais

### **Fluxo Downstream** (outputs para próximos commands)
- `/planejamento-roadmap-expandido` ← recebe gaps identificados
- `/executar-roadmap-expandido` ← usa priorização de requirements
- Stakeholders ← recebem status transparente do projeto

## 🧠 LLM-Friendly Design

### **Structured Information Flow**
```yaml
information_packaging:
  requirements_parsing: "Extração estruturada de todos documentos originais"
  evidence_collection: "Screenshots e logs organizados sistematicamente"
  status_tracking: "Estados padronizados com timestamps e evidências"

automation_integration:
  playwright_tests: "Suite automatizada para cada categoria de requirement"
  screenshot_automation: "Captura sistemática de evidências visuais"
  performance_monitoring: "Coleta automatizada de métricas Core Web Vitals"
```

### **Error Handling & Recovery**
```yaml
fallback_strategies:
  server_unavailable: "Documentar impossibilidade de verificação com timestamp"
  test_failures: "Capturar screenshots de erro para debugging"
  missing_features: "Marcar como NOT_IMPLEMENTED com evidência clara"
```

---

**💡 Dica de Uso**: Execute este command regularmente para manter PRD atualizado com status real de implementação

**🔗 Próximo Command**: `/planejamento-roadmap-expandido` (utiliza gaps identificados para priorização)