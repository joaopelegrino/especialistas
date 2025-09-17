# 🤖 Subagents Nativos Claude Code 2025 - Guia Completo

## 🎯 [ESSENCIAL] Nova Arquitetura Multi-Agent

### Mudança Paradigmática: Custom Agents → Native Subagents

```yaml
Sistemas_Legados_2024:
  tipo: Custom JSON configs
  contexto: Shared context window
  paralelizacao: Sequential execution only
  performance: Baseline

Sistema_Nativo_2025:
  tipo: Native .md subagents
  contexto: Isolated context per agent
  paralelizacao: Up to 10 concurrent agents
  performance: +90.2% improvement (Anthropic benchmark)
```

## 📊 [METRICA] Performance Comprovado pela Anthropic

### Benchmarks Oficiais
```yaml
Multi_Agent_vs_Single_Agent:
  performance_gain: "90.2%"
  token_usage: "15x more (but higher value)"
  parallelization: "3-5 subagents + 3+ tools simultaneously"
  context_scaling: "Separate 200k token window per agent"

Cost_Benefit_Analysis:
  ideal_for: "Complex tasks >30min development time"
  not_suitable: "Simple operations <10min"
  roi_breakeven: "Tasks requiring multiple expertise domains"
```

## 🏗️ [TEMPLATE] Estrutura de Subagent Nativo

### Anatomia de um Subagent .md
```markdown
---
name: bm-wizard-specialist
description: Phoenix LiveView wizard implementation expert with 5-step workflow specialization
tools: Read, Write, Edit, MultiEdit, Bash, Glob, Grep
model: inherit
---

# BM Wizard Specialist Agent

## Especialização Principal
Implementação de wizards Phoenix LiveView com foco em:
- Workflows multi-step (5 etapas)
- File upload functionality
- Progress tracking e validação
- Integration com authentication systems

## Contexto de Atuação
- **Target Files**: `lib/blog_web/live/wizard/`
- **Dependencies**: Phoenix.LiveView, Ecto schemas
- **Architecture**: Event-driven step validation

## Capabilities Específicas
1. **Step Transition Logic**: Implement smooth navigation between wizard steps
2. **File Processing**: Handle upload, validation e storage
3. **State Management**: Maintain wizard state across sessions
4. **Validation Gates**: Ensure data quality per step
5. **Error Handling**: Graceful fallback e user feedback

## Success Criteria
- 5-step wizard operacional
- File upload funcional
- Progress tracking visual
- Integration com auth system
- Evidence collection automated
```

### Configuração de Tools Específicos
```yaml
# Exemplo: Subagent com tools restritos para segurança
---
name: security-auditor
description: Security analysis specialist for code review
tools: Read, Grep, Bash  # Apenas leitura e análise
model: inherit
---

# Configuração para maximum security:
tools: Read, Grep  # Sem write permissions
```

## 🔄 [PASSO-A-PASSO] Migration Path: Custom JSON → Native Subagents

### Fase 1: Análise do Sistema Atual
```bash
# 1. Localizar configurações existentes
find .claude -name "*agent*" -o -name "*config*"

# 2. Analisar projeto-bm-agents-config.json
cat .claude/core/projeto-bm-agents-config.json | jq '.specialized_agents'

# 3. Identificar agents ativos
grep -r "agent" .claude/commands/
```

### Fase 2: Conversão para Subagents Nativos
```bash
# 1. Criar diretório subagents
mkdir -p .claude/subagents

# 2. Converter cada agent JSON para .md
# Exemplo: bm-wizard-agent
cat > .claude/subagents/bm-wizard-specialist.md << 'EOF'
---
name: bm-wizard-specialist
description: Phase BM-2 - 5-Step Content Wizard MVP specialist
tools: Read, Write, Edit, Bash, Glob, Grep
model: inherit
---

I am a specialized agent for implementing Phoenix LiveView content wizards.

Focus: lib/blog_web/live/wizard/ implementation
Capabilities: Multi-step forms, file uploads, progress tracking
Integration: Authentication system compatibility
EOF
```

### Fase 3: Update de Comandos para Task Tool
```bash
# Antigo: Custom slash command
/start-phase-orchestrator bm-2

# Novo: Native Task tool (Claude decide automaticamente)
# "Please implement the 5-step wizard using appropriate specialists"
# Claude automaticamente invoca bm-wizard-specialist
```

## ⚡ [OTIMIZACAO] Parallel Execution Patterns

### Pattern 1: Multi-Domain Analysis
```markdown
Task: "Analyze codebase for security, performance and quality"

Auto-delegation:
├── security-auditor.md → Security analysis
├── performance-optimizer.md → Performance bottlenecks
├── code-reviewer.md → Quality assessment
└── documentation-specialist.md → Documentation gaps

Execution: All 4 agents run in parallel with isolated contexts
```

### Pattern 2: Full-Stack Development
```markdown
Task: "Implement user authentication with frontend and backend"

Auto-delegation:
├── backend-specialist.md → API endpoints + database
├── frontend-specialist.md → UI components + forms
├── test-engineer.md → Test coverage
└── security-auditor.md → Security validation

Benefits: 4x faster implementation vs sequential
```

### Pattern 3: Evidence Collection
```markdown
Task: "Validate implementation with comprehensive testing"

Auto-delegation:
├── test-runner.md → Execute test suites
├── visual-tester.md → Screenshot collection
├── performance-monitor.md → Metrics collection
└── documentation-updater.md → Update reports

Output: Unified evidence package
```

## 🔧 [TEMPLATE] Subagents por Domínio

### Backend Specialist
```markdown
---
name: backend-specialist
description: Phoenix/Elixir backend implementation expert
tools: Read, Write, Edit, MultiEdit, Bash
model: inherit
---

# Backend Implementation Specialist

## Core Competencies
- Phoenix controllers e live views
- Ecto schemas e migrations
- Authentication systems (Guardian)
- API development (REST/GraphQL)
- Database optimization

## Target Areas
- lib/blog/
- lib/blog_web/controllers/
- priv/repo/migrations/
- test/blog/
```

### Frontend Specialist
```markdown
---
name: frontend-specialist
description: Phoenix LiveView frontend expert
tools: Read, Write, Edit, Bash, Glob
model: inherit
---

# Frontend Implementation Specialist

## Core Competencies
- LiveView components
- JavaScript interop
- CSS/Tailwind styling
- Form handling
- Real-time features

## Target Areas
- lib/blog_web/live/
- assets/js/
- assets/css/
- priv/static/
```

### Test Engineer
```markdown
---
name: test-engineer
description: Comprehensive testing specialist
tools: Read, Write, Edit, Bash
model: inherit
---

# Test Engineering Specialist

## Core Competencies
- ExUnit test suites
- Integration testing
- Performance testing
- Visual regression testing
- Test automation

## Target Areas
- test/
- .claude/tools/evidence-collector.js
- MCP validation scripts
```

## 🎯 [DECISAO] Quando Usar Subagents vs Single Agent

### Use Subagents Para:
```yaml
✅ Complex_Multi_Domain_Tasks:
  exemplo: "Full-stack feature implementation"
  razao: "Isolated expertise + parallel execution"

✅ Large_Codebase_Analysis:
  exemplo: "Security + performance + quality audit"
  razao: "Separate context windows prevent token limit"

✅ Evidence_Collection:
  exemplo: "Multi-viewport testing + documentation"
  razao: "Specialized tools per validation type"

✅ Long_Running_Workflows:
  exemplo: "Phase BM-2 wizard implementation"
  razao: "Context preservation across sessions"
```

### Use Single Agent Para:
```yaml
❌ Simple_Tasks:
  exemplo: "Fix single compilation error"
  razao: "Overhead não justifica parallelização"

❌ Sequential_Dependencies:
  exemplo: "Step-by-step tutorial following"
  razao: "Each step depends on previous context"

❌ Quick_Questions:
  exemplo: "Explain specific function"
  razao: "Single context window sufficient"
```

## 📋 [CHECKLIST] Implementação de Subagents

### Pré-Implementação
- [ ] Analisar sistema atual (custom agents JSON)
- [ ] Identificar domínios de especialização
- [ ] Mapear dependencies entre agents
- [ ] Definir tool restrictions por agent

### Conversão
- [ ] Criar .claude/subagents/ directory
- [ ] Converter agents JSON para .md format
- [ ] Configurar tool access por specialization
- [ ] Test individual subagent responses

### Validação
- [ ] Verificar Task tool auto-delegation
- [ ] Confirmar parallel execution (≥2 agents)
- [ ] Validate context isolation
- [ ] Measure performance improvement

### Otimização
- [ ] Refine agent descriptions para better matching
- [ ] Optimize tool restrictions para security
- [ ] Configure model preferences (sonnet vs opus)
- [ ] Document agent interaction patterns

## 🚀 [EXEMPLO] Migração Completa: Projeto Blog

### Estado Atual (2024 Legacy)
```json
// .claude/core/projeto-bm-agents-config.json
{
  "bm-wizard-agent": "Custom JSON config",
  "bm-validation-agent": "Sequential execution",
  "claude-code-09-09-orchestrator": "Manual coordination"
}
```

### Estado Target (2025 Native)
```bash
.claude/subagents/
├── bm-wizard-specialist.md        # Phase BM-2 implementation
├── security-auditor.md            # LGPD compliance + security
├── performance-optimizer.md       # WebAssembly optimization
├── test-engineer.md               # Evidence collection + validation
├── documentation-specialist.md     # CENTRAL-DE-CONTROLE sync
└── code-reviewer.md               # Quality assurance
```

### Migration Commands
```bash
# 1. Backup current system
cp -r .claude/core .claude/core.backup

# 2. Create native subagents
./scripts/convert-agents-to-subagents.sh

# 3. Test new system
# Claude auto-delegates: "Implement wizard step 1"
# → Automatically invokes bm-wizard-specialist.md

# 4. Validate parallel execution
# Claude processes: "Complete Phase BM-2 with full validation"
# → Invokes: wizard + security + test + documentation (parallel)
```

## 🔗 [VER-ARQUIVO] Referencias

### Anthropic Official Documentation
- **Subagents Guide**: https://docs.claude.com/en/docs/claude-code/sub-agents
- **Multi-Agent Research**: https://www.anthropic.com/engineering/multi-agent-research-system
- **Performance Benchmarks**: Research papers on 90.2% improvement

### Community Resources
- **Production Subagents**: https://github.com/VoltAgent/awesome-claude-code-subagents
- **Best Practices**: https://medium.com/@codecentrevibe/claude-code-multi-agent-parallel-coding-83271c4675fa

### Internal Cross-References
- [VER-ARQUIVO: 02-arquitetura-tecnica.md] → Multi-agent architecture
- [VER-ARQUIVO: 06-guia-implementacao.md] → Step-by-step implementation
- [VER-ARQUIVO: templates-pt-br/] → Ready-to-use templates

---

**[IMPLEMENTADO]** Este documento está pronto para uso no projeto blog
**[PENDENTE]** Conversão dos agents JSON existentes
**[METRICA]** Expected 90.2% performance improvement post-migration