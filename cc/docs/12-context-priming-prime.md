# 12. Context Priming com /prime

> **Técnica avançada: Context Priming superior ao CLAUDE.md estático**

---

## O que é Context Priming?

**Context Priming** é usar um **custom slash command dedicado** para configurar o context window inicial do agent **especificamente para o tipo de tarefa**, ao invés de depender de um CLAUDE.md estático.

### Definição

> "Context priming is when you use a dedicated reusable prompt, aka a custom slash command, to set up your agent's initial context window specifically for the task type at hand."

---

## Problema: CLAUDE.md Estático

### ❌ O Problema

```
CLAUDE.md típico:
├─ Cresce constantemente (time adiciona mais e mais)
├─ Pode chegar a 23K tokens (~10% do context!)
├─ Warning: "Large CLAUDE.md will impact performance"
├─ Sempre carregado (não dinâmico)
└─ Não controlável por task type
```

**Exemplo real**:
```markdown
# CLAUDE.md (3000 linhas!)
## Tech Stack
[500 linhas]

## API Documentation
[800 linhas]

## Database Schema
[600 linhas]

## Testing Guidelines
[400 linhas]

## Deployment Process
[700 linhas]
```

**Resultado**: 23K tokens desperdiçados em TODA conversa, mesmo quando irrelevante!

---

## Solução: Context Priming com /prime

### ✅ A Solução

**CLAUDE.md minimalista** (apenas essenciais universais):
```markdown
# CLAUDE.md (43 linhas apenas!)

## Universal Essentials
- Tech: Python 3.11, FastAPI, PostgreSQL
- Style: PEP 8, 2-space indents
- Tests: pytest, 80%+ coverage

## Commands
- Run: `python -m app`
- Test: `pytest`
- Deploy: `./deploy.sh`
```

**+ Múltiplos /prime commands especializados**:
- `/prime` - Entendimento geral da codebase
- `/prime-bug` - Preparar para bug fixing
- `/prime-feature` - Preparar para nova feature
- `/prime-chore` - Preparar para refactoring
- `/prime-cc` - Trabalhar com Claude Code files

---

## Estrutura de um Prime Command

### Template Base

```markdown
---
description: Prime agent for [specific task type]
---

# Prime [Task Type]

## Purpose
[What this prime command does]

## Run Step
[Initial commands or checks]

## Read Step
Read these essential files:
- README.md (overview)
- docs/architecture.md (structure)
- [task-specific files]

## Report Step
Report understanding of:
- Project structure
- Key patterns
- [task-specific context]
```

### Exemplo 1: /prime (General)

```markdown
---
description: Prime agent with general codebase understanding
---

# Prime - General Codebase Understanding

## Purpose
Set up agent with foundational knowledge of the codebase.

## Run Step
Verify we're in project root and dependencies are installed.

## Read Step

Read these files in order:

1. **README.md** - Project overview
2. **docs/architecture.md** - System design
3. **src/main.py** - Entry point
4. **.claude/CLAUDE.md** - Project conventions

## Report Step

Provide concise summary:
- Project purpose
- Tech stack
- Key directories
- Main entry points
- Testing approach

Ready for general development tasks.
```

### Exemplo 2: /prime-bug

```markdown
---
description: Prime agent for bug investigation and fixing
---

# Prime Bug - Bug Investigation Setup

## Purpose
Prepare agent for systematic bug investigation and fixing.

## Run Step
Check if bug report/issue exists.

## Read Step

Priority files for bug investigation:

1. **Bug report/issue** (if available)
2. **tests/** - Understand test coverage
3. **src/[affected_module]** - Buggy area
4. **docs/troubleshooting.md** - Known issues
5. **CHANGELOG.md** - Recent changes

## Report Step

Bug investigation context loaded:
- Test coverage for affected area
- Recent changes that might be related
- Known issues and workarounds
- Debugging approach ready

Ready to investigate and fix bugs systematically.
```

### Exemplo 3: /prime-feature

```markdown
---
description: Prime agent for feature development
---

# Prime Feature - New Feature Development

## Purpose
Set up agent for feature development following project patterns.

## Run Step
Ensure feature branch exists or create one.

## Read Step

Essential files for feature development:

1. **docs/architecture.md** - System design
2. **src/[related_module]** - Existing patterns
3. **tests/[related_tests]** - Testing patterns
4. **docs/api.md** - API conventions
5. **CONTRIBUTING.md** - Development guidelines

## Report Step

Feature development context loaded:
- Architecture patterns understood
- Existing similar features reviewed
- Testing approach identified
- API conventions clear

Ready to implement new feature following project standards.
```

### Exemplo 4: /prime-cc

```markdown
---
description: Prime agent for working with Claude Code configuration
---

# Prime CC - Claude Code Configuration

## Purpose
Focus agent on Claude Code setup and configuration tasks.

## Run Step
Verify .claude/ directory exists.

## Read Step

Claude Code specific files:

1. **.claude/CLAUDE.md** - Memory file
2. **.claude/settings.json** - Configuration
3. **.claude/commands/** - Custom commands
4. **.claude/agents/** - Sub-agents
5. **docs/claude-code-setup.md** - Setup guide

## Report Step

Claude Code context loaded:
- Current configuration understood
- Custom commands available
- Sub-agents defined
- MCP servers configured

Ready to work on Claude Code configuration and optimization.
```

---

## Comparação: Static vs Dynamic Context

### ❌ Static (CLAUDE.md grande)

```
Startup context:
├─ CLAUDE.md: 23K tokens (sempre!)
├─ System prompt: 5K
├─ Tools: 3K
└─ Available: 169K (de 200K)

Para qualquer task (bug, feature, docs):
└─ Carrega 23K de informação (80% irrelevante!)
```

### ✅ Dynamic (Prime)

```
Startup context (minimal CLAUDE.md):
├─ CLAUDE.md: 0.3K tokens (essenciais apenas)
├─ System prompt: 5K
├─ Tools: 3K
└─ Available: 191K (de 200K)

Depois de /prime-bug:
├─ Context específico bug: 3K
└─ Available: 188K

Depois de /prime-feature:
├─ Context específico feature: 4K
└─ Available: 187K
```

**Ganho**: 20K+ tokens salvos por usar context relevante!

---

## Workflow Recomendado

### 1. Shrink CLAUDE.md

**Antes**:
```markdown
# CLAUDE.md (3000 linhas)
[Tudo que já foi adicionado ao longo do tempo]
```

**Depois**:
```markdown
# CLAUDE.md (50 linhas)

## Universal Essentials
- Tech stack (só o essencial)
- Style guide (só o essencial)
- Common commands
```

**Regra de ouro**:
> "Your CLAUDE.md should contain only the absolute universal essentials that you're 100% sure you want loaded 100% of the time."

### 2. Criar Prime Commands

Para cada área de foco comum:
- `/prime` - General understanding
- `/prime-bug` - Bug fixing
- `/prime-feature` - Feature development
- `/prime-refactor` - Refactoring
- `/prime-test` - Testing
- `/prime-docs` - Documentation
- `/prime-deploy` - Deployment

### 3. Usar Prime Antes de Trabalhar

```bash
# Começo do dia - entender projeto
/prime

# Trabalhar em bug #123
/prime-bug

# Implementar nova feature
/prime-feature

# Refatorar módulo
/prime-refactor
```

---

## Benefícios do Context Priming

### ✅ Controle Total

**Você decide** qual context carregar para cada tipo de task.

### ✅ Context Relevante

Apenas informação **relevante** para a task atual.

### ✅ Múltiplas Especializações

Diferentes primes para diferentes workflows.

### ✅ Context Window Limpo

Começa com ~190K disponível vs ~170K com CLAUDE.md grande.

### ✅ Escala Melhor

Conforme projeto cresce, adicione novos primes (não infle CLAUDE.md).

### ✅ Team Alignment

Time pode criar primes específicos para seus workflows.

---

## Integration com R&D Framework

Context Priming é parte do **"R" (Reduce)** no R&D Framework:

```
R&D Framework:
├─ Reduce (Minimizar tokens)
│   ├─ B2: Avoid MCP servers desnecessários
│   ├─ B3: Context Priming (prime vs CLAUDE.md) ✅
│   └─ Use offset/limit para reads
│
└─ Delegate (Offload para sub-agents)
    ├─ I2: Sub-agents properly
    ├─ ADV2: Context Bundles
    └─ AGE2: Multi-agent delegation
```

---

## Best Practices

### ✅ DO

**1. Shrink CLAUDE.md drasticamente**
```markdown
# Apenas 40-50 linhas de essenciais
```

**2. Criar primes específicos**
```markdown
Um prime para cada workflow comum
```

**3. Usar estrutura consistente**
```markdown
Purpose → Run → Read → Report
```

**4. Documentar cada prime**
```markdown
Clara description no frontmatter
```

**5. Versionar primes**
```bash
# Commit .claude/commands/ para git
```

### ❌ DON'T

**1. Criar CLAUDE.md gigante**
```markdown
❌ 3000 linhas de tudo que já foi útil
```

**2. Duplicar informação**
```markdown
❌ Mesma info em CLAUDE.md e em prime
```

**3. Criar primes muito genéricos**
```markdown
❌ /prime-everything que carrega tudo
```

**4. Esquecer de usar primes**
```markdown
❌ Criar primes mas não usá-los
```

---

## Exemplo Completo: Migration Workflow

### Setup

**1. CLAUDE.md (minimal)**:
```markdown
# CLAUDE.md

## Essentials
- Python 3.11, FastAPI, PostgreSQL
- Style: PEP 8
- Tests: pytest
```

**2. /prime-migration command**:
```markdown
---
description: Prime for SDK/framework migrations
---

# Prime Migration

## Purpose
Prepare for systematic SDK or framework migration.

## Read Step
1. README.md - Current dependencies
2. requirements.txt - Package versions
3. docs/architecture.md - System design
4. CHANGELOG.md - Migration history

## Report Step
Ready for migration with understanding of:
- Current SDK versions
- Breaking changes to expect
- Testing strategy
- Rollback plan
```

### Uso

```bash
# Start clean
claude --no-mcp

# Prime for migration
/prime-migration

# Now agent has focused context
# Execute scout-plan-build
/scout-plan-build "Migrate from old SDK to new SDK v2"
```

---

## Advanced: Multiple Prime Layers

Você pode **compor** primes:

```bash
# Layer 1: General understanding
/prime

# Layer 2: Specific area
/prime-api

# Layer 3: Specific task
/prime-feature

# Now agent has layered, focused context
```

---

## Context Bundle Integration

Primes funcionam bem com **Context Bundles** (técnica avançada):

```bash
# Agent 1 (trabalhou com prime)
/prime-bug
[faz debug work]
[context overload]

# Agent 2 (reload state)
/load-bundle [bundle-path]
# Bundle já inclui qual prime foi usado
# Agent 2 está no mesmo state!
```

---

## Just-in-Time Context Loading

> "Load exactly what you need, exactly when you need it - the essence of efficient context management"

### Conceito

**Just-in-Time (JIT) Loading** é carregar informação relevante dinamicamente **durante** a execução, ao invés de pre-load todo context possível **antes** de começar.

### Problema: Pre-Loading vs JIT

#### ❌ Pre-Loading (CLAUDE.md grande)

```
Session startup:
├─ Load CLAUDE.md: 23K tokens
│   ├─ Tech stack info: 3K
│   ├─ API documentation: 8K
│   ├─ Database schema: 6K
│   ├─ Testing guidelines: 3K
│   └─ Deployment process: 3K
│
├─ Available context: 177K/200K
└─ Relevance for current task: ~20%

Example: Bug fixing task
├─ Needs: Testing guidelines (3K) ✅
├─ Doesn't need: API docs (8K) ❌
├─ Doesn't need: DB schema (6K) ❌
├─ Doesn't need: Deployment (3K) ❌
└─ Wasted: 17K tokens (74% irrelevant!)
```

#### ✅ JIT Loading (Prime commands)

```
Session startup:
├─ Load CLAUDE.md: 0.5K tokens (essentials only)
├─ Available context: 199.5K/200K
└─ Prime on-demand based on task type

Example: Bug fixing task
├─ /prime-bug (executes)
│   ├─ Load testing guidelines: 3K ✅
│   ├─ Load debugging patterns: 2K ✅
│   └─ Skip irrelevant info
│
├─ Context usage: 5.5K tokens
├─ Relevance: 100% (all needed!)
└─ Saved: 17.5K tokens
```

### Arquitetura JIT com Prime Commands

```
┌──────────────────────────────────────────────────────┐
│              CLAUDE.md (Minimal)                     │
│              0.5K tokens                             │
├──────────────────────────────────────────────────────┤
│  • Tech: Python, FastAPI, PostgreSQL                │
│  • Style: PEP 8                                      │
│  • Tests: pytest                                     │
│  • Commands: npm run dev, pytest                     │
└──────────────────────────────────────────────────────┘
                         ↓
              Task type determines prime
                         ↓
    ┌────────────┬───────────────┬────────────┐
    │            │               │            │
┌───▼────┐  ┌───▼─────┐  ┌─────▼────┐  ┌───▼──────┐
│/prime  │  │/prime-  │  │/prime-   │  │/prime-   │
│        │  │bug      │  │feature   │  │refactor  │
│3K      │  │5K       │  │6K        │  │4K        │
│        │  │         │  │          │  │          │
│General │  │Testing  │  │Design    │  │Patterns  │
│context │  │+Debug   │  │+API      │  │+Best     │
│        │  │patterns │  │docs      │  │practices │
└────────┘  └─────────┘  └──────────┘  └──────────┘

Loaded: Only what's needed
Timing: Exactly when needed
Result: Optimal context usage
```

### Exemplo Comparativo Completo

#### Task: Fix Authentication Bug

**Método 1: Pre-Loading**

```
# Startup
claude

Context loaded:
├─ CLAUDE.md (23K):
│   ├─ Tech stack: 3K
│   ├─ API docs: 8K ← Not needed for bug fix
│   ├─ Database schema: 6K ← Not needed for bug fix
│   ├─ Testing: 3K ✅ Needed
│   └─ Deployment: 3K ← Not needed for bug fix
├─ System prompt: 5K
└─ Total startup: 28K tokens

User: "Fix JWT token validation bug"

Agent works with:
├─ 28K pre-loaded context (only 3K relevant)
├─ Reads test files: 10K
├─ Debugs issue: 15K
└─ Total: 53K tokens

Efficiency: 3K relevant / 28K loaded = 11% relevance
```

**Método 2: JIT Loading**

```
# Startup
claude

Context loaded:
├─ CLAUDE.md minimal (0.5K):
│   └─ Universal essentials only
├─ System prompt: 5K
└─ Total startup: 5.5K tokens

User: "Fix JWT token validation bug"

# Agent triggers JIT loading
/prime-bug

Prime loads (JIT):
├─ Testing guidelines: 3K ✅
├─ Debugging patterns: 2K ✅
├─ Common bug areas: 1K ✅
└─ Skips: API docs, DB schema, deployment

Agent works with:
├─ 5.5K minimal startup
├─ 6K JIT loaded (prime-bug)
├─ Reads test files: 10K
├─ Debugs issue: 15K
└─ Total: 36.5K tokens

Efficiency: 6K relevant / 6K loaded = 100% relevance
Saved: 16.5K tokens (31% reduction)
```

### Implementação: JIT Loading System

#### 1. Minimal CLAUDE.md (Foundation)

```markdown
# CLAUDE.md

## Essentials (Always Loaded)
- **Tech**: Python 3.11, FastAPI, PostgreSQL
- **Style**: PEP 8, 2-space indents
- **Tests**: pytest, 80%+ coverage

## Commands
- Dev: `npm run dev`
- Test: `pytest`
- Build: `npm run build`

## Primes Available
Use task-specific primes for detailed context:
- `/prime` - General codebase understanding
- `/prime-bug` - Bug fixing context
- `/prime-feature` - Feature development context
- `/prime-refactor` - Refactoring context
```

**Size**: ~0.5K tokens
**Load time**: Session startup (always)
**Relevance**: 100% (universal essentials)

#### 2. JIT Prime Commands

**prime-bug.md** (Load on-demand para bug fixing):

```markdown
---
description: Prime agent for bug investigation and fixing
---

# Prime Bug - JIT Context Loading

## JIT Load: Testing Context

Read these files on-demand:
1. `tests/README.md` - Testing strategy
2. `docs/debugging.md` - Debugging patterns
3. `.github/workflows/test.yml` - CI test setup

## JIT Load: Common Bug Patterns

Common bug areas in this codebase:
- **Authentication**: JWT token validation (src/auth/)
- **Database**: Connection pooling (src/db/)
- **API**: Error handling (src/api/)

## JIT Load: Debugging Tools

Available debugging commands:
```bash
# Run specific test
pytest tests/test_auth.py::test_specific -v

# Debug mode
python -m pdb src/main.py

# Logs
tail -f logs/debug.log
```

## Report

Context loaded (JIT):
- Testing strategy: ✅
- Debug patterns: ✅
- Common bug areas: ✅
- Debug commands: ✅

Ready for bug investigation with focused context.

**Tokens loaded**: ~6K (only what's needed for bugs)
```

**prime-feature.md** (Load on-demand para features):

```markdown
---
description: Prime agent for feature development
---

# Prime Feature - JIT Context Loading

## JIT Load: Design Context

Read these files on-demand:
1. `docs/architecture.md` - System design
2. `docs/api-conventions.md` - API patterns
3. `examples/feature-template/` - Feature structure

## JIT Load: Development Patterns

Feature development patterns:
- **Structure**: Feature modules in `src/features/`
- **API**: RESTful conventions, OpenAPI specs
- **Database**: Migrations via Alembic
- **Tests**: Feature tests + integration tests

## JIT Load: Similar Features

Reference implementations:
- User management: `src/features/users/`
- Order processing: `src/features/orders/`
- Payment handling: `src/features/payments/`

## Report

Context loaded (JIT):
- Architecture patterns: ✅
- API conventions: ✅
- Feature examples: ✅
- Development workflow: ✅

Ready for feature development with design context.

**Tokens loaded**: ~8K (design-focused)
```

### Métricas: JIT vs Pre-Loading

#### Context Usage Over Time

```
Pre-Loading (CLAUDE.md grande):
├─ Startup: 28K tokens
├─ + User prompt: 1K
├─ + Tool calls: 30K
├─ + Responses: 20K
└─ Total: 79K tokens (39.5% of window)

JIT Loading (Prime commands):
├─ Startup: 5.5K tokens
├─ + Prime-bug JIT: 6K
├─ + User prompt: 1K
├─ + Tool calls: 30K
├─ + Responses: 20K
└─ Total: 62.5K tokens (31.25% of window)

Savings: 16.5K tokens (21% reduction)
```

#### Relevance Metrics

```
Pre-Loading:
├─ Loaded: 23K (CLAUDE.md)
├─ Relevant for task: 3K
├─ Irrelevant: 20K
└─ Relevance: 13%

JIT Loading:
├─ Minimal CLAUDE: 0.5K (all relevant)
├─ Prime-bug: 6K (all relevant)
├─ Total loaded: 6.5K
└─ Relevance: 100%

Efficiency gain: 87% improvement in relevance
```

### Advanced: Multi-Layer JIT

```
Layer 1: Universal (Always Loaded)
├─ CLAUDE.md: 0.5K
└─ System prompt: 5K

Layer 2: Task Type (JIT via /prime)
├─ /prime-bug → 6K
├─ /prime-feature → 8K
├─ /prime-refactor → 4K
└─ /prime-docs → 3K

Layer 3: Sub-Domain (JIT via custom commands)
├─ /load-auth-context → 4K
├─ /load-db-context → 5K
├─ /load-api-context → 6K
└─ /load-frontend-context → 7K

Layer 4: Specific Files (JIT via Read)
├─ Read specific files as needed
└─ Use offset/limit for precision

Example: Fix auth bug
├─ Layer 1: 5.5K (universal)
├─ Layer 2: /prime-bug → +6K
├─ Layer 3: /load-auth-context → +4K
├─ Layer 4: Read auth.py:45-120 → +2K
└─ Total: 17.5K (all highly relevant!)
```

### Best Practices: JIT Loading

#### ✅ DO

**1. Start minimal, load on-demand**
```bash
# Minimal startup
claude  # Only 5.5K tokens

# Load as needed
/prime-bug  # +6K when fixing bugs
/load-auth-context  # +4K if auth-specific
```

**2. Create domain-specific JIT commands**
```bash
# Not just task-type primes
# But also domain-specific loaders
/load-auth-context
/load-payment-context
/load-frontend-context
```

**3. Layer your JIT loading**
```markdown
Universal → Task Type → Domain → Specific Files
(always)    (on-demand)  (on-demand) (on-demand)
```

**4. Measure relevance**
```bash
# After session, check
/context

# Question: Was everything in context actually used?
# If not, reduce pre-loading, increase JIT
```

#### ❌ DON'T

**1. Pre-load "just in case"**
```markdown
# ❌ Pre-load everything
CLAUDE.md: [all possible documentation]

# ✅ Load what's needed
CLAUDE.md: [essentials only]
/prime-X: [task-specific context]
```

**2. Create overly granular JIT commands**
```bash
# ❌ Too many tiny commands
/load-auth-jwt-token-validation-context

# ✅ Balanced granularity
/load-auth-context (covers auth broadly)
```

**3. Forget to document available JIT commands**
```markdown
# ✅ Document in CLAUDE.md
## Available Primes
- /prime-bug
- /prime-feature
- /load-auth-context
```

### Integration: JIT + Other Techniques

**JIT + Context Bundles**:
```bash
# Agent 1
/prime-bug
[work until context full]
# Bundle logs which prime was used

# Agent 2
/load-bundle session.md
# Reload knows to re-run /prime-bug
```

**JIT + Scout-Plan-Build**:
```bash
# Scout phase
/prime  # General understanding

# Plan phase
/prime-feature  # Design context JIT-loaded

# Build phase
# Context focused on implementation
```

**JIT + Sub-Agents**:
```bash
# Main agent: minimal context
# Sub-agents: Load what they need
Task(
    prompt="/prime-review then review code",
    subagent_type="reviewer"
)
```

---

## Métricas de Sucesso

### Antes (CLAUDE.md grande)
```
Context usage no startup: 28K (14%)
Time to first response: 8s
Tokens wasted per session: ~20K
```

### Depois (Prime)
```
Context usage no startup: 8K (4%)
Time to first response: 3s
Tokens wasted per session: ~2K
Relevant context: 95%+
```

---

## Templates Prontos

Ver `/templates/commands/prime/` para:
- `prime.md` - General
- `prime-bug.md` - Bug fixing
- `prime-feature.md` - Feature dev
- `prime-refactor.md` - Refactoring
- `prime-test.md` - Testing
- `prime-docs.md` - Documentation
- `prime-cc.md` - Claude Code work

---

## Referências

- **Nível**: B3 (Beginner 3) - Context Engineering Levels
- **Framework**: R&D (Reduce and Delegate)
- **Categoria**: Reduce (minimizar tokens no context)
- **Vídeo**: "Levels of Context Engineering"

---

## Conclusão

> "A focused agent is a performant agent."

Context Priming é uma das técnicas mais impactantes de context engineering:
- ✅ Fácil de implementar
- ✅ Alto impacto imediato
- ✅ Escala com o projeto
- ✅ Funciona para todo o time

**Next Steps**:
1. Reduza seu CLAUDE.md para <50 linhas
2. Crie `/prime` para entendimento geral
3. Adicione primes específicos conforme necessidade
4. Use antes de cada task type

**Key Principle**: Context não é sobre carregar tudo - é sobre carregar o **certo** para a task atual.

---

**Anterior**: [11. Best Practices ←](11-best-practices.md) | **Próximo**: [13. 12 Técnicas Context Engineering →](13-context-engineering-techniques.md)
