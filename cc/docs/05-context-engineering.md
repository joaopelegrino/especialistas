# 05. Context Engineering e R&D Framework

> **Elite context management: Reduce and Delegate para maximizar eficiência do context window**

---

## Context como Recurso Finito

> "Context is a finite resource - the 'attention budget' of large language models" - Anthropic

### O Problema

```
Context Window (200K tokens):
├─ System prompt: 5K
├─ CLAUDE.md: 2K
├─ Tool definitions: 3K
├─ Conversation: GROWS
├─ File reads: GROWS
├─ Tool results: GROWS
└─ Remaining: SHRINKS ❌
```

**Consequência**: Agent performance degrada conforme context enche.

---

## R&D Framework

> "There are only two ways to manage your context window: **Reduce** and **Delegate**"

### Reduce: Minimize Tokens

**Estratégias**:

1. **Read apenas o necessário**
```python
# ❌ Read entire 2000-line file
Read("large_file.py")  # 50K tokens!

# ✅ Read specific section
Read("large_file.py", offset=450, limit=100)  # 2.5K tokens
```

2. **Use summaries**
```markdown
# ❌ Full grep output (10K tokens)
[1000 lines of grep results]

# ✅ Condensed summary (1K tokens)
Found pattern in 5 files:
- auth.py:45 - JWT generation
- models.py:200 - User model
...
```

3. **Clear at breakpoints**
```bash
# After completing a major phase
/clear

# Start fresh for next phase
```

4. **Use /context command**
```bash
# Check context usage
/context

# See what's consuming space
# Remove unnecessary items
```

### Delegate: Offload Work

**Estratégia**: Sub-agentes com context isolado

```
Main Agent (23K tokens):
└─ Spawn Sub-agents:
    ├─ Sub-agent 1 (50K context) → 2K summary ✅
    ├─ Sub-agent 2 (30K context) → 2K summary ✅
    ├─ Sub-agent 3 (40K context) → 2K summary ✅
    └─ Sub-agent 4 (25K context) → 2K summary ✅

Main agent receives only 8K, not 145K!
```

---

## Armazenamento e Coleta de Informações

> "Understanding how information is collected, stored, and contextualized is fundamental to efficient agent operation"

### Arquitetura de Coleta Distribuída

Durante o levantamento de contexto, especialmente em workflows como Scout-Plan-Build, o sistema utiliza uma arquitetura sofisticada de coleta e armazenamento:

```
┌─────────────────────────────────────────────────────────┐
│         COLETA DISTRIBUÍDA (Scout Phase)                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Main Agent (Orchestrator)                              │
│     │                                                    │
│     ├─→ Sub-agent 1 [Context: 30K tokens]              │
│     │   ├─ Grep/Glob para buscar padrões               │
│     │   ├─ Read com offset/limit                       │
│     │   └─ Summary: 2K tokens                          │
│     │                                                    │
│     ├─→ Sub-agent 2 [Context: 25K tokens]              │
│     │   ├─ Busca específica                            │
│     │   └─ Summary: 2K tokens                          │
│     │                                                    │
│     ├─→ Sub-agent 3 [Context: 35K tokens]              │
│     │   └─ Summary: 2K tokens                          │
│     │                                                    │
│     └─→ Sub-agent 4 [Context: 20K tokens]              │
│         └─ Summary: 2K tokens                          │
│                                                          │
│  Consolidação: relevant_files.md (8K total)            │
│  Context isolado dos sub-agents: DESCARTADO ✅          │
└─────────────────────────────────────────────────────────┘

Main Agent recebe: 8K tokens (não 110K!)
```

**Key Insight**: Sub-agents processam 110K+ tokens em contexts isolados, mas main agent recebe apenas 8K condensados.

### Armazenamento Estruturado

#### 1. relevant_files.md (Scout Output)

Formato estruturado com offsets e metadata:

```markdown
# Relevant Files for [Task]

## File: src/auth/login.py
- Lines: 45-120
- Offset: 45, Length: 75 lines
- Contains: User authentication logic
- Key finding: Uses JWT tokens with refresh
- Pattern: `jwt.encode(payload, SECRET_KEY)`

## File: src/database/models.py
- Lines: 200-250
- Offset: 200, Length: 50 lines
- Contains: User model definition
- Key finding: Password hashing with bcrypt
- Dependencies: bcrypt, sqlalchemy

## File: src/api/endpoints.py
- Lines: 85-120
- Offset: 85, Length: 35 lines
- Contains: Authentication endpoints
- Routes: /login, /logout, /refresh
```

**Benefícios**:
- ✅ Main agent sabe **exatamente** onde ler (offset + length)
- ✅ Não precisa re-buscar arquivos
- ✅ Context economizado: ~40K → 5K

#### 2. detailed_plan.md (Plan Output)

```markdown
# Implementation Plan: [Task]

## Phase 1: Update Authentication
**Files to modify**:
- src/auth/login.py (lines 45-60)
  - Change: Replace old JWT library
  - Test: pytest tests/test_auth.py::test_jwt

**Before**:
```python
import old_jwt
token = old_jwt.encode(payload)
```

**After**:
```python
import new_jwt
token = new_jwt.create(payload)
```

## Phase 2: Update Models
[...]
```

#### 3. ai_docs.md (Cached Documentation)

```markdown
# Cached Documentation

## Source: https://docs.new-sdk.com/migration

### Key Changes
- Old: `jwt.encode()` → New: `jwt.create()`
- Old: `jwt.decode()` → New: `jwt.verify()`
- Breaking: SECRET_KEY now requires algorithm parameter

### Examples
[Cached examples from docs]
```

**Vantagem**: Agents futuros podem ler cache ao invés de re-fetch.

### Passagem de State Entre Agents

State NÃO passa via context window - passa via **arquivos persistidos**:

```
Agent 1 (Scout)
├─ Coleta: 80K tokens processados
├─ Armazena: relevant_files.md (5K)
└─ Output: File persistido no filesystem
      ↓
Agent 2 (Plan)
├─ Input: Read("relevant_files.md") → 5K tokens
├─ Processa: + Docs (8K)
├─ Armazena: detailed_plan.md (15K)
└─ Output: File persistido
      ↓
Agent 3 (Build)
├─ Input: Read("detailed_plan.md") → 15K tokens
├─ Implementa: Baseado no plan
└─ Output: Modified files + summary
```

**Context Usage**:
- Agent 1: 80K usado → 5K output
- Agent 2: 13K usado (clean start!)
- Agent 3: 15K usado (clean start!)

**Total work**: 108K tokens
**Max context in any agent**: 80K
**Efficiency**: State transfer via files, not context!

### Métricas de Eficiência

#### Sem Armazenamento Estruturado

```
Main Agent Context:
├─ System prompt: 5K
├─ Search results (raw): 30K ❌
├─ File previews (raw): 20K ❌
├─ Analysis: 10K
├─ Planning: 15K
└─ Total: 80K tokens (40% do context!)

Performance: Degradada
Risk: Context overflow
```

#### Com Armazenamento Estruturado

```
Main Agent Context:
├─ System prompt: 5K
├─ relevant_files.md (condensed): 5K ✅
├─ Analysis: 10K
├─ Planning: 15K
└─ Total: 35K tokens (17.5% do context!)

Files externos:
├─ relevant_files.md: 5K
├─ detailed_plan.md: 15K
└─ ai_docs.md: 8K

Performance: Otimizada ✅
Context saved: 45K tokens (22.5%)!
```

### Best Practices: Armazenamento

#### ✅ DO

**1. Use formato estruturado com metadata**
```markdown
## File: path/to/file.py
- Lines: X-Y
- Offset: X, Length: Y-X
- Finding: [concise description]
```

**2. Armazene summaries, não full content**
```python
# ✅ Condensado
summary = {
    "file": "auth.py",
    "lines": "45-120",
    "finding": "JWT token generation"
}

# ❌ Verboso
full_content = read_entire_file("auth.py")  # 2000 lines!
```

**3. Use offsets para reads eficientes**
```python
# Planner armazena offset
plan = "Read auth.py lines 45-120"

# Builder usa offset direto
Read("auth.py", offset=45, limit=75)
```

#### ❌ DON'T

**1. Não armazene full content no context**
```markdown
# ❌ Bad
Here's the entire file:
[2000 lines of code]

# ✅ Good
File: auth.py (lines 45-120)
Finding: JWT logic uses old library
```

**2. Não re-busque informação já coletada**
```python
# ❌ Scout já encontrou, não busque novamente
Grep("JWT token")  # Already in relevant_files.md!

# ✅ Read the summary
Read("relevant_files.md")
```

---

## Long-Horizon Task Techniques

### 1. Compaction

**Manual compaction** em breakpoints estratégicos:

```bash
# After scout phase
/clear
# Keep only relevant_files.md

# After plan phase
/clear
# Keep only detailed_plan.md

# After build phase
/clear
# Keep only what's needed for next task
```

### 2. Structured Note-Taking

Agents escrevem **notas persistentes** fora do context:

```markdown
# progress.md (outside context)
- [x] Phase 1: Auth migration complete
- [x] Phase 2: Database migration complete
- [ ] Phase 3: API migration (next)

Key decisions:
- Using JWT v2.0
- Backwards compatibility via /legacy endpoint
```

Agent pode re-ler `progress.md` após compaction.

### 3. Sub-Agent Architectures

**Main agent** = high-level coordinator
**Sub-agents** = deep exploration

```
Main Agent (orchestrator):
├─ Read progress.md
├─ Decide next phase
├─ Spawn sub-agent for deep work
└─ Receive condensed result

Sub-agent:
├─ Extensive exploration (50K context)
├─ Detailed implementation
└─ Return 2K summary to main
```

---

## Autocompact Feature

### O que é

Claude Code 2.0 tem **autocompact** que automatically summarizes conversation ao aproximar-se do limit.

### Problema

```json
{
  "autocompact": true  // Default
}
```

- ⚠️ Consome ~22% do context window
- ⚠️ Compacta em momentos potentially indesejados
- ⚠️ Pode perder context importante

### Solução

```json
{
  "autocompact": false  // Recomendado
}
```

**Faça compaction manual** em breakpoints estratégicos com `/clear`.

---

## Context Engineering Principles

### Principle 1: Just-in-Time Context

> Load context only when needed

```markdown
# ❌ Load everything upfront
Read all 50 files
Load all documentation
Then start planning

# ✅ Progressive discovery
Read architecture overview
Identify relevant areas
Read only those specific files
```

### Principle 2: Smallest High-Signal Set

> "Find the smallest set of high-signal tokens that maximize likelihood of desired outcome"

```markdown
# ❌ High noise
[Full file contents]
[All search results]
[Verbose tool outputs]

# ✅ High signal
[File summaries with key sections]
[Top 5 search results with context]
[Condensed tool outputs]
```

### Principle 3: Context Hierarchy

Use **CLAUDE.md hierarchy** para estruturar knowledge:

```
~/.claude/CLAUDE.md           # Global context
project/CLAUDE.md             # Project context
project/module/CLAUDE.md      # Module context
```

Mais específico = maior prioridade.

---

## Ferramentas de Context Management

### 1. /context Command

```bash
/context

# Output:
Context usage: 45%
├─ System prompt: 5K
├─ Custom agents: 3K
├─ Messages: 42K
├─ Autocompact buffer: 22K (⚠️ consider disabling)
└─ Available: 128K
```

### 2. /clear Command

```bash
# Clear conversation history
/clear

# Start fresh session
```

### 3. CLAUDE.md Files

```markdown
# .claude/CLAUDE.md

## Project Context

Tech stack: FastAPI, PostgreSQL, React
Style: PEP 8, 2-space indents
Tests: pytest with 80%+ coverage

## Important Patterns

Authentication: JWT tokens (see src/auth/)
Database: Async SQLAlchemy (see src/db/)
```

### 4. relevant_files.md Pattern

Usado no Scout-Plan-Build:

```markdown
# relevant_files.md

## Files for Authentication Migration

### src/auth/login.py
- Lines: 45-120
- Purpose: JWT token generation
- Key pattern: Uses old library

### src/models.py
- Lines: 200-250
- Purpose: User model
- Key pattern: Password hashing
```

---

## Best Practices

### ✅ DO

**1. Use offset/limit for large files**
```python
Read("huge.py", offset=500, limit=100)
```

**2. Compactar manualmente**
```bash
/clear  # At strategic breakpoints
```

**3. Delegate heavy lifting**
```markdown
# Spawn sub-agents for:
- Extensive search
- Deep analysis
- Parallel exploration
```

**4. Use structured outputs**
```markdown
# Instead of verbose tool outputs
Summary: Found X patterns in Y files
Top 3 relevant files: [list]
```

### ❌ DON'T

**1. Read entire files unnecessarily**
```python
# ❌
Read("2000_line_file.py")

# ✅
Read("2000_line_file.py", offset=450, limit=100)
```

**2. Let autocompact run wild**
```json
// ❌
{"autocompact": true}

// ✅
{"autocompact": false}
```

**3. Accumulate tool outputs**
```markdown
# ❌ Keep all bash outputs in context
# ✅ Summarize: "Tests passed, 42 tests, 0 failures"
```

---

## Elite Context Engineering

### Scout-Plan-Build Pattern

**Máxima eficiência** através de separação de fases:

```
Scout Phase (delegated):
├─ 4 sub-agents search (160K total context used)
└─ Return 8K summary to main

Plan Phase (clean context):
├─ Main agent: 5K system + 8K summary + 10K docs
└─ Create 5K plan

Build Phase (focused):
├─ Main agent: 5K system + 5K plan
└─ Implement systematically
```

**Total main agent context**: ~30K
**Total actual work**: ~195K (delegated!)

### Multi-Agent Orchestration

```
Main Agent (20K context):
└─ Orchestrates:
    ├─ Team 1: 4 scouts (160K combined)
    ├─ Team 2: 3 reviewers (120K combined)
    └─ Team 3: 2 implementers (80K combined)

Total compute: 380K
Main agent context: 20K ✅
```

---

## Referências

- [Anthropic - Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [07. Workflows Avançados](07-workflows-avancados.md) - Aplicação do R&D Framework
- [03. Sub-agentes](03-subagentes-task-tool.md) - Delegation patterns

---

**Anterior**: [04. Hooks ←](04-hooks-customizacao.md) | **Próximo**: [06. Output Styles →](06-output-styles.md)
