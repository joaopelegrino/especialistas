# 🎯 PLANO DE OTIMIZAÇÃO GERAL - CLAUDE CODE v6.3
**Data**: 09/09/2025  
**Branch**: `otimizacao-claude-code-09-09`  
**Contexto**: Consolidação pós-dashboard único + análise Anthropic best practices  

---

## 📊 ANÁLISE DO ESTADO ATUAL

### ✅ **Pontos Fortes Identificados (Sistema Observatory v6)**
1. **Sistema Observatory Maduro**: 202 arquivos .claude/, estrutura robusta implementada
2. **Dashboard Consolidado**: CENTRAL-DE-CONTROLE.md como fonte única verdade stakeholders
3. **Interactive Workflow Dashboard**: DAG Swimlane com visualização tempo real (http://localhost:4000/claude/dashboard)
4. **Wiki Estruturada**: docs/wiki/ com coverage completo projeto-BM + PLANO_DESENVOLVIMENTO.md
5. **MCP Integration v6**: Auto-debug com retry recursivo, validation.py implementado
6. **Visual Evidence Collection v6**: Screenshots automáticos multi-viewport, evidence-collector.js operacional
7. **Agent System v6**: projeto-bm-agents-config.json com 5 agentes especializados
8. **Orquestrador Inteligente v6**: /start-phase-orchestrator implementado e operacional
9. **PROMPTBASE-INICIAL.md**: 633 linhas de contexto específico consolidado
10. **Hooks System v6**: pre_mix_command.py + mcp-validator.py com auto-debug

### 🔍 **Gaps Identificados vs Anthropic Best Practices**

#### **1. CLAUDE.md Optimization**
**Estado Atual**: Básico, foco em setup
**Best Practice**: Documentar bash commands, code style, testing instructions, repository etiquette
**Gap**: Falta de comandos customizados e diretrizes específicas do projeto

#### **2. Custom Slash Commands**
**Estado Atual**: Não implementado
**Best Practice**: Comandos /start-phase, /validate-all customizados
**Gap**: Sistema de comandos não integrado com workflow projeto-BM

#### **3. MCP Advanced Usage**
**Estado Atual**: Básico (validation)  
**Best Practice**: External data sourcing, advanced integrations
**Gap**: Não explora todo potencial MCP para APIs externas (PubMed, Cochrane)

#### **4. Subagent Orchestration**
**Estado Atual**: Configurado mas sem automação
**Best Practice**: Parallel execution, specialized context injection
**Gap**: Orquestração manual, sem dynamic context

#### **5. Plan Mode Integration**
**Estado Atual**: Não usado sistematicamente
**Best Practice**: Safe code analysis antes de implementações
**Gap**: Falta workflow "explore, plan, code, commit"

#### **6. Extended Context Management**
**Estado Atual**: Fragmentado entre arquivos
**Best Practice**: Focused context with /clear, targeted references
**Gap**: Context overflow em sessões longas

---

## 🚀 ESTRATÉGIA DE OTIMIZAÇÃO

### **FASE 1: CLAUDE.md Enhancement (2h)** ✅ **IMPLEMENTADO (09/09/2025)**

#### **1.1 Expansão Completa CLAUDE.md** ✅ **COMPLETA**
**Status**: ✅ CLAUDE.md expandido de 82 → 335+ linhas com todas seções identificadas

**Implementado**:
```markdown
## 🎯 Contexto Rápido              ✅ Mantido (estrutura existente sólida)
## 🔥 Setup Crítico                ✅ Mantido (comandos validados)
## 📋 Comandos Customizados do Projeto  ✅ **NOVO** - 15+ comandos específicos
### Desenvolvimento                    ✅ **IMPLEMENTADO**
- `debug-projeto-bm-complete`         ✅ Full stack debug with evidence
- `validate-phase-bm-[1-4]`          ✅ Phase-specific validation
- `sync-wiki-planning`               ✅ Sync docs/wiki/ with PLANO_DESENVOLVIMENTO.md
- `start-intelligent-orchestrator`   ✅ Auto phase setup + context injection

### Testing & Quality                  ✅ **IMPLEMENTADO**  
- `test-wizard-flow`                 ✅ End-to-end wizard validation
- `performance-check-complete`        ✅ Bundle size + Core Vitals + recommendations
- `security-audit-health`            ✅ Security scan + compliance + WCAG

### Documentation & Evidence           ✅ **IMPLEMENTADO**
- `update-stakeholder-dashboard`      ✅ Auto-update CENTRAL-DE-CONTROLE.md
- `generate-evidence-report`         ✅ Consolidate visual evidence + metrics + delivery
- `sync-architecture-docs`           ✅ Wiki ↔ Implementation + cross-reference validation

## 🎨 Code Style Guidelines Projeto-BM  ✅ **IMPLEMENTADO**
### Elixir/Phoenix Standards           ✅ **COMPLETAS**
- ✅ Snake_case para funções e variáveis com exemplos
- ✅ PascalCase para módulos com estrutura
- ✅ LiveView components organizados por feature `/lib/blog_web/live/content_wizard/`
- ✅ Pattern matching preferido sobre condicionais

### Estrutura de Arquivos             ✅ **COMPLETA**
- ✅ Feature-based organization detalhada: `/lib/blog_web/live/wizard/`
- ✅ Business logic separada: `/lib/blog/content/`
- ✅ Tests mirror implementation structure

### Database/Schema                   ✅ **COMPLETA**
- ✅ Always use `Ecto.Schema` with comprehensive changesets
- ✅ Migrations backward-compatible + seeds obrigatório
- ✅ Validation examples with Ecto.Changeset

## 🧪 Testing Instructions             ✅ **IMPLEMENTADAS**
### Test Suites                      ✅ **COMPLETAS**
1. ✅ **Unit**: `mix test test/blog/` + coverage details
2. ✅ **Integration**: `mix test test/blog_web/live/` + LiveView
3. ✅ **E2E**: `.claude/core/projeto-bm-test-suite.sh` + visual validation
4. ✅ **Visual**: `evidence-collector.js --all-viewports` + automation

### Quality Gates                    ✅ **OBRIGATÓRIAS**
- ✅ Coverage obrigatório >80% com `mix coveralls.html`
- ✅ Zero console errors + browser validation
- ✅ Core Web Vitals <2.5s LCP + performance monitoring
- ✅ WCAG 2.1 AA compliance + accessibility audit

### Test Environment + Debug         ✅ **COMPLETO**
- ✅ Database test setup + seeds específicos
- ✅ Observatory test mode com debug flags
- ✅ Debugging failed tests com trace + network analysis

## 📚 Repository Etiquette           ✅ **IMPLEMENTADA**
### Branch Strategy                  ✅ **COMPLETA**
- ✅ `main` - Production ready - NUNCA push direto
- ✅ `projeto-bm-dev-*` - Feature branches específicas por fase
- ✅ `otimizacao-*` - Infrastructure improvements
- ✅ Workflow obrigatório detalhado

### Commit Messages                  ✅ **COMPLETAS**
- ✅ Emojis obrigatórios: 🔧 FIX, ✨ FEAT, 📝 DOCS, 🚀 PERF, 🧪 TEST
- ✅ Reference issues: `#BM-123` format
- ✅ Evidence links obrigatórios para features visuais

### Documentation Update Protocol     ✅ **COMPLETO**
- ✅ CENTRAL-DE-CONTROLE.md sempre após major features
- ✅ Wiki sync + evidence obrigatórias
- ✅ Sincronização automática commands disponíveis

### Quality Standards Zero Tolerance  ✅ **IMPLEMENTADOS**
- ✅ PRE-COMMIT hooks obrigatórios (tests + format + visual + MCP)
- ✅ PRE-PUSH validation (full stack health + performance + evidence)
- ✅ Delivery criteria detalhados (zero failures + evidence + dashboard)
```

**Gap Analysis vs Estado Original**:
- ❌ **ANTES**: CLAUDE.md básico (82 linhas) - foco apenas em setup
- ✅ **DEPOIS**: CLAUDE.md completo (335+ linhas) - documentação comprehensive

**Resultados Quantitativos**:
- **Comandos documentados**: 0 → 15+ comandos específicos projeto  
- **Code style guidelines**: 0 → 4 seções detalhadas (Elixir/Phoenix/Database/Files)
- **Testing instructions**: básicas → 4 test suites + quality gates + debug
- **Repository etiquette**: 0 → branch strategy + commit standards + protocols

#### **1.2 Custom Slash Commands Implementation**
**Localização**: `.claude/commands/custom-slash-commands.md`

```bash
# Phase Management
/start-phase-bm-2      # Auto-expand PLANO_DESENVOLVIMENTO.md + setup context
/validate-phase-bm-1   # Complete phase validation with evidence
/complete-phase-bm-X   # Mark phase complete + update dashboard

# Development Workflow  
/debug-wizard-step-N   # Debug specific wizard step with screenshots
/test-auth-system      # Full authentication flow test
/performance-audit     # Bundle + Core Vitals + recommendations

# Documentation & Sync
/sync-wiki-docs        # Bi-directional sync wiki ↔ implementation
/update-dashboard      # Auto-update CENTRAL-DE-CONTROLE.md
/generate-evidence     # Collect all evidence + generate report
```

### **FASE 2: Intelligent Orchestrator Engine (4h)**

#### **2.1 Dynamic Phase Expansion System**
**Arquivo**: `.claude/tools/intelligent-orchestrator.py`

```python
class IntelligentOrchestrator:
    def __init__(self):
        self.plano_path = "docs/wiki/roadmap-implementacao/requisitos-projeto-bm/PLANO_DESENVOLVIMENTO.md"
        self.central_path = "CENTRAL-DE-CONTROLE.md"
        self.wiki_path = "docs/wiki/"
        
    def start_phase_orchestration(self, phase_id):
        """
        1. Git analysis (current state vs roadmap)
        2. Dynamic expansion do PLANO_DESENVOLVIMENTO.md com sessao.md template
        3. Context injection específico baseado no estado atual
        4. Agent preparation com contexto consolidado
        """
        
    def expand_plano_development_phase(self, phase_data):
        """
        Expande seção específica no PLANO_DESENVOLVIMENTO.md:
        - Contexto dinâmico baseado em git state
        - Checklist detalhado seguindo sessao.md
        - Requisitos funcionais/não-funcionais
        - Links para wiki relevante
        - Espaço para diário do agente
        """
        
    def sync_wiki_with_planning(self):
        """
        Bi-directional sync:
        - docs/wiki/ → PLANO_DESENVOLVIMENTO.md (requirements)
        - PLANO_DESENVOLVIMENTO.md → wiki (implementation status)
        """
```

#### **2.2 Context Management & Plan Mode**
**Padrão**: Sempre usar "explore, plan, code, commit"

```python
class ContextManager:
    def explore_phase(self, phase_id):
        # Read all relevant wiki docs
        # Analyze current implementation state  
        # Identify dependencies and blockers
        
    def plan_implementation(self, exploration_results):
        # Generate detailed implementation plan
        # Expand PLANO_DESENVOLVIMENTO.md section
        # Prepare agent context
        
    def execute_with_monitoring(self, plan):
        # Monitor implementation progress
        # Collect evidence automatically
        # Update dashboard in real-time
        
    def commit_and_document(self, results):
        # Commit changes with proper messaging
        # Update wiki documentation
        # Generate stakeholder report
```

### **FASE 3: MCP Advanced Integration (3h)**

#### **3.1 External APIs MCP Servers**
**Configuração**: `.claude/mcp-servers-advanced.json`

```json
{
  "mcpServers": {
    "pubmed-integration": {
      "command": "python",
      "args": [".claude/mcp-servers/pubmed-server.py"],
      "env": {
        "PUBMED_API_KEY": "${PUBMED_API_KEY}"
      }
    },
    "cochrane-integration": {
      "command": "python", 
      "args": [".claude/mcp-servers/cochrane-server.py"]
    },
    "cms-integration": {
      "command": "node",
      "args": [".claude/mcp-servers/cms-bridge.js"]
    }
  }
}
```

#### **3.2 Scientific Reference MCP Server**
**Arquivo**: `.claude/mcp-servers/scientific-references-server.py`

```python
class ScientificReferencesMCP:
    """
    MCP Server para integração com APIs científicas:
    - PubMed search and retrieval
    - Cochrane Library integration
    - Citation formatting
    - Validation workflows
    """
    
    def search_pubmed(self, query, limit=10):
        # Search PubMed with query
        # Return formatted results
        
    def validate_citation(self, citation):
        # Validate citation format
        # Check availability  
        # Return validation status
        
    def format_reference(self, citation, style="apa"):
        # Format citation in specified style
        # Include DOI/PMID when available
```

### **FASE 4: Subagent Orchestration System (3h)**

#### **4.1 Parallel Agent Execution**
**Arquivo**: `.claude/core/subagent-orchestrator.py`

```python
class SubagentOrchestrator:
    def __init__(self):
        self.agents_config = self.load_agents_config()
        self.active_sessions = {}
        
    def orchestrate_phase_bm_2(self):
        """
        Parallel execution:
        1. bm-wizard-agent (step 1-2 implementation)
        2. bm-validation-agent (step 3-4 validation logic)
        3. bm-integration-agent (external APIs preparation)
        """
        
    def inject_dynamic_context(self, agent_type, current_state):
        """
        Context injection specific per agent:
        - Current git state
        - Completed dependencies
        - Available components
        - Specific documentation links
        """
        
    def monitor_agent_progress(self):
        """
        Real-time monitoring:
        - Progress tracking
        - Error detection
        - Cross-agent coordination
        """
```

#### **4.2 Enhanced Agents Configuration**
**Update**: `.claude/core/projeto-bm-agents-config.json`

```json
{
  "specialized_agents": {
    "bm-wizard-agent-v2": {
      "dynamic_context_injection": true,
      "parallel_capable": true,
      "context_sources": [
        "docs/wiki/componentes-projeto-bm/content-wizard-5-etapas.md",
        "lib/blog_web/live/content_wizard_live.ex",
        "PLANO_DESENVOLVIMENTO.md#phase-bm-2"
      ],
      "evidence_integration": {
        "screenshots": true,
        "logs": true,
        "performance_metrics": true
      }
    }
  }
}
```

### **FASE 5: Evidence & Documentation Enhancement (2h)**

#### **5.1 Automated Evidence Pipeline**
**Arquivo**: `.claude/tools/evidence-pipeline.py`

```python
class EvidencePipeline:
    def collect_comprehensive_evidence(self, feature_name):
        """
        1. Multi-viewport screenshots
        2. Performance metrics collection  
        3. Console logs analysis
        4. Network requests validation
        5. Accessibility audit
        6. Integration with CENTRAL-DE-CONTROLE.md
        """
        
    def generate_stakeholder_report(self):
        """
        Automated report generation:
        - Visual evidence compilation
        - Progress metrics
        - Quality gates status
        - Next phase preparation
        """
```

#### **5.2 Wiki Synchronization System**
**Arquivo**: `.claude/tools/wiki-sync-engine.py`

```python
class WikiSyncEngine:
    def bi_directional_sync(self):
        """
        docs/wiki/ ↔ PLANO_DESENVOLVIMENTO.md ↔ CENTRAL-DE-CONTROLE.md
        - Requirements tracking
        - Implementation status
        - Evidence linking
        """
        
    def validate_documentation_consistency(self):
        """
        Cross-reference validation:
        - Wiki coverage vs implementation
        - PLANO_DESENVOLVIMENTO status vs code state
        - Evidence availability vs requirements
        """
```

---

## 🎯 IMPLEMENTATION ROADMAP

### **Week 1: Foundation Enhancement**
- **Day 1**: CLAUDE.md enhancement + custom commands
- **Day 2**: Intelligent orchestrator core engine
- **Day 3**: Dynamic phase expansion system

### **Week 2: Advanced Integration**
- **Day 1**: MCP advanced servers (scientific APIs)
- **Day 2**: Subagent orchestration system  
- **Day 3**: Evidence pipeline + wiki sync

### **Week 3: Testing & Refinement**
- **Day 1**: End-to-end testing with Phase BM-2
- **Day 2**: Performance optimization + bug fixes
- **Day 3**: Documentation finalization + stakeholder demo

---

## 🏆 SUCCESS CRITERIA

### **Technical Metrics**
1. **Setup Time**: Reduction 90% (30min → 3min for new phase start)
2. **Context Accuracy**: 95% relevant context injection
3. **Evidence Automation**: 100% automatic collection
4. **Documentation Sync**: <5min lag between implementation ↔ docs

### **Workflow Metrics**  
1. **Phase Transition**: Fully automated phase BM-1 → BM-2
2. **Agent Orchestration**: Parallel execution working
3. **Stakeholder Communication**: Real-time dashboard updates
4. **Quality Gates**: Zero manual verification needed

### **Integration Metrics**
1. **MCP Advanced**: External APIs fully integrated
2. **Wiki Synchronization**: Bi-directional sync functional
3. **Evidence Pipeline**: Multi-source evidence consolidation
4. **Custom Commands**: All slash commands operational

---

## 📚 APPENDIX: Best Practices Integration

### **From Anthropic Research**
- ✅ CLAUDE.md comprehensive documentation
- ✅ Plan Mode integration ("explore, plan, code, commit")  
- ✅ Custom slash commands for project-specific workflows
- ✅ Advanced MCP usage for external integrations
- ✅ Subagent orchestration for parallel processing
- ✅ Visual evidence for iterative development
- ✅ Context management with focused scope

### **Projeto-BM Specific Enhancements**
- ✅ Dynamic PLANO_DESENVOLVIMENTO.md expansion
- ✅ Wiki ↔ Planning bi-directional sync
- ✅ Scientific API integration via MCP
- ✅ Multi-agent coordination for complex phases
- ✅ Stakeholder-focused evidence pipeline
- ✅ Interactive dashboard real-time updates

**Resultado Final**: Sistema Claude Code otimizado alinhado com best practices da Anthropic, customizado para as necessidades específicas do Projeto-BM, com automação end-to-end desde o planejamento até a entrega final para stakeholders.