# 03. Sub-agentes e Task Tool

> **Delegação inteligente: Crie agentes especializados com context isolado para escalar compute**

---

## O que são Sub-agentes

Sub-agentes são **instâncias especializadas** de Claude Code que:
- ✅ Têm seu próprio context window (isolado)
- ✅ Podem ser configurados com tools específicos
- ✅ Possuem system prompt customizado
- ✅ Rodam em paralelo (até 10x simultâneos)
- ✅ Retornam apenas summaries condensados

---

## Por que usar Sub-agentes?

### Problema: Single Agent Overload

```
Main Agent (one context):
├─ Search files (30K tokens)
├─ Read documentation (20K tokens)
├─ Analyze code (15K tokens)
├─ Plan changes (10K tokens)
├─ Implement (25K tokens)
└─ Total: 100K tokens ❌ Overwhelmed!
```

### Solução: Delegation

```
Main Agent (clean context):
└─ Spawn Sub-agents:
    ├─ Search Agent 1 → Returns summary (2K)
    ├─ Search Agent 2 → Returns summary (2K)
    ├─ Search Agent 3 → Returns summary (2K)
    └─ Search Agent 4 → Returns summary (2K)
Total in main context: 8K tokens ✅ Clean!
```

---

## Configuração

### Estrutura do Arquivo

```yaml
---
name: agent-name
description: When to use this agent
tools: Tool1, Tool2  # Optional: inherit all if omitted
model: sonnet | haiku | opus  # Optional
---

System prompt defining agent's role and behavior.
```

### Localizações

| Localização | Escopo |
|-------------|--------|
| `.claude/agents/` | Projeto (versionado) |
| `~/.claude/agents/` | Pessoal (local) |

### Exemplo: Code Reviewer

```yaml
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: Read, Grep, Glob
model: sonnet
---

You are an expert code reviewer specializing in security and performance.

When reviewing code:
1. Check for security vulnerabilities (auth, injection, data exposure)
2. Identify performance bottlenecks
3. Verify error handling
4. Check test coverage
5. Assess code readability

Provide feedback prioritized by severity:
- CRITICAL: Security issues
- HIGH: Bugs and performance problems
- MEDIUM: Code quality and maintainability
- LOW: Style and convention suggestions

Return concise, actionable feedback.
```

---

## Task Tool

### Sintaxe

```python
Task(
    description="Short description (3-5 words)",
    prompt="Detailed task for sub-agent",
    subagent_type="agent-name"  # From .claude/agents/
)
```

### Paralelismo

Claude Code suporta **até 10 agentes paralelos**. Requests além disso são enfileirados.

### Exemplo: Parallel Search

```markdown
Launch 4 search agents in parallel:

Agent 1: Search for authentication code
Agent 2: Search for database queries
Agent 3: Search for API endpoints
Agent 4: Search for configuration files

Each agent returns:
- Files found
- Key patterns
- Line ranges
```

---

## Padrões de Uso

### Pattern 1: Parallel Exploration

```markdown
Main Agent spawns 4 scouts:
├─ Scout 1 (Gemini): Fast pattern matching
├─ Scout 2 (Haiku): Cheap file discovery
├─ Scout 3 (CodeQwen): Code-specific search
└─ Scout 4 (Gemini): Documentation search

Consolidate results → relevant_files.md
```

### Pattern 2: Specialized Reviews

```markdown
Main Agent spawns 3 reviewers:
├─ Security Agent → security_review.md
├─ Performance Agent → performance_review.md
└─ Quality Agent → quality_review.md

Merge reviews → final_review.md
```

### Pattern 3: Multi-Service Implementation

```markdown
Main Agent (orchestrator):
├─ Agent 1: Implement Auth Service
├─ Agent 2: Implement User Service
├─ Agent 3: Implement Order Service
└─ Agent 4: Implement Payment Service

Each agent has isolated context and tools
```

---

## Context Isolation

### Benefit: Context Independence

```
Main Agent Context:
├─ System prompt (5K)
├─ User conversation (10K)
├─ Sub-agent summaries (8K)
└─ Total: 23K ✅

Sub-agent 1 Context (independent):
├─ System prompt (3K)
├─ Task prompt (2K)
├─ Search results (15K)
└─ Total: 20K (then disposed!)

Sub-agent 2 Context (independent):
├─ System prompt (3K)
├─ Task prompt (2K)
├─ File reads (18K)
└─ Total: 23K (then disposed!)
```

**Result**: Main agent stays clean, sub-agents do heavy lifting

---

## Armazenamento com Context Isolation

> "Sub-agents are the perfect tool for heavy data collection - isolated contexts mean collected data never pollutes main agent"

### Como Funciona o Armazenamento Isolado

```
┌──────────────────────────────────────────────────────────┐
│                   MAIN AGENT                             │
│                Context: 15K tokens                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Spawns 4 sub-agents for parallel search:               │
│                                                          │
└──────────────────────────────────────────────────────────┘
         ↓           ↓           ↓           ↓
    ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
    │ Sub-1  │  │ Sub-2  │  │ Sub-3  │  │ Sub-4  │
    │        │  │        │  │        │  │        │
    │ COLETA │  │ COLETA │  │ COLETA │  │ COLETA │
    │        │  │        │  │        │  │        │
    │ 30K    │  │ 25K    │  │ 35K    │  │ 20K    │
    │ tokens │  │ tokens │  │ tokens │  │ tokens │
    │        │  │        │  │        │  │        │
    │ Grep   │  │ Grep   │  │ Read   │  │ Read   │
    │ Read   │  │ Read   │  │ Grep   │  │ Glob   │
    │ Analyze│  │ Analyze│  │ Analyze│  │ Analyze│
    └────────┘  └────────┘  └────────┘  └────────┘
         ↓           ↓           ↓           ↓
    ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
    │Summary │  │Summary │  │Summary │  │Summary │
    │ 2K     │  │ 2K     │  │ 2K     │  │ 2K     │
    └────────┘  └────────┘  └────────┘  └────────┘
         ↓           ↓           ↓           ↓
         └───────────┴───────────┴───────────┘
                       ↓
         ┌──────────────────────────────┐
         │    Main Agent Receives       │
         │    8K tokens (summaries)     │
         │                              │
         │  NOT 110K (full collection)! │
         └──────────────────────────────┘

Sub-agent contexts DESCARTADOS após completion ✅
Main agent context: 15K + 8K = 23K total
Efficiency: 110K coletado, 8K usado!
```

### Exemplo Detalhado: Parallel Search

#### Setup: Search Agent Definition

```yaml
# .claude/agents/scout-search.yaml
---
name: scout-search
description: Fast search agent for parallel codebase exploration
model: haiku
tools: Grep, Glob, Read
---

You are a fast search agent optimizing for speed and efficiency.

## Task
Search codebase for specific patterns and return CONDENSED summaries.

## Process
1. Use Grep/Glob to find files matching search criteria
2. Read relevant sections (use offset/limit for large files!)
3. Extract key information
4. Return SUMMARY (NOT full content)

## Output Format
```markdown
## Search Results: [pattern]

Found in N files:

### File: path/to/file.py
- **Lines**: X-Y (Z lines)
- **Offset**: X, **Length**: Z
- **Pattern**: [what was found]
- **Context**: [brief description]
- **Key code**: [1-2 line excerpt if relevant]

[repeat for each file]

## Summary
Total matches: N
Most relevant: [top 3 files]
Recommended next action: [suggestion]
```

DO NOT include full file contents!
```

#### Execution: Parallel Search

```markdown
# Main Agent spawns 4 search agents

Task 1 (scout-search):
  Prompt: "Search for JWT token generation code"
  → Sub-agent 1 context:
      ├─ Grep "jwt.encode" → 5 matches
      ├─ Read auth/login.py:45-60 (15 lines)
      ├─ Read auth/tokens.py:30-45 (15 lines)
      ├─ Read utils/jwt_helper.py:10-30 (20 lines)
      └─ Context used: 30K tokens
  → Returns to main: 2K summary

Task 2 (scout-search):
  Prompt: "Search for password hashing code"
  → Sub-agent 2 context:
      ├─ Grep "bcrypt" → 3 matches
      ├─ Read models/user.py:180-200 (20 lines)
      ├─ Read utils/crypto.py:50-80 (30 lines)
      └─ Context used: 25K tokens
  → Returns to main: 2K summary

Task 3 (scout-search):
  Prompt: "Search for authentication endpoints"
  → Sub-agent 3 context:
      ├─ Grep "@app.post.*login" → 4 matches
      ├─ Read api/auth_routes.py:40-120 (80 lines)
      ├─ Read api/middleware.py:30-60 (30 lines)
      └─ Context used: 35K tokens
  → Returns to main: 2K summary

Task 4 (scout-search):
  Prompt: "Search for configuration files with SECRET_KEY"
  → Sub-agent 4 context:
      ├─ Grep "SECRET_KEY" → 6 matches
      ├─ Read config/settings.py:10-50 (40 lines)
      ├─ Read .env.example:1-20 (20 lines)
      └─ Context used: 20K tokens
  → Returns to main: 2K summary
```

**Main Agent Final Context**:
```
├─ Initial: 15K tokens
├─ Summary 1: 2K tokens
├─ Summary 2: 2K tokens
├─ Summary 3: 2K tokens
├─ Summary 4: 2K tokens
└─ Total: 23K tokens

Saved: 110K - 8K = 102K tokens! (82% reduction)
```

### Armazenamento: Summary Format

#### ❌ Bad Summary (Too Verbose)

```markdown
## Search Results: JWT token generation

Found jwt.encode in these files:

### auth/login.py
Here's the entire file:
```python
[200 lines of code...]
```

[Similar for other files...]

Total: 15K tokens in summary! ❌
```

#### ✅ Good Summary (Condensed)

```markdown
## Search Results: JWT token generation

Found 5 matches in 3 files:

### src/auth/login.py
- **Lines**: 45-60 (15 lines)
- **Offset**: 45, **Length**: 15
- **Pattern**: `old_jwt.encode(payload, SECRET_KEY)`
- **Context**: Main token generation function
- **Key code**: `token = old_jwt.encode({"user_id": id}, SECRET)`
- **Note**: Uses old library, needs migration

### src/auth/tokens.py
- **Lines**: 30-45 (15 lines)
- **Offset**: 30, **Length**: 15
- **Pattern**: `old_jwt.encode(refresh_payload, REFRESH_SECRET)`
- **Context**: Refresh token generation
- **Note**: Same pattern as login.py

### src/utils/jwt_helper.py
- **Lines**: 10-30 (20 lines)
- **Offset**: 10, **Length**: 20
- **Pattern**: Helper wrapper around `old_jwt.encode`
- **Context**: Centralized JWT utility
- **Note**: Used by both login.py and tokens.py

## Summary
- Total: 3 files with JWT generation
- Pattern: All use `old_jwt.encode()` with SECRET_KEY
- Architecture: Centralized helper + specific implementations
- Migration path: Update jwt_helper.py first (affects all)

## Recommendation
Start with src/utils/jwt_helper.py - updating this will cascade to other files.

Total: 2K tokens in summary! ✅
```

### Métricas: Context Isolation Benefits

#### Cenário 1: Sem Sub-agents (Single Agent)

```
Main Agent doing all the work:
├─ Grep "jwt.encode" → 5K tokens
├─ Read auth/login.py → 8K tokens
├─ Read auth/tokens.py → 6K tokens
├─ Read utils/jwt_helper.py → 5K tokens
├─ Grep "bcrypt" → 4K tokens
├─ Read models/user.py → 7K tokens
├─ Read utils/crypto.py → 6K tokens
├─ Grep "@app.post.*login" → 5K tokens
├─ Read api/auth_routes.py → 12K tokens
├─ Read api/middleware.py → 8K tokens
├─ Grep "SECRET_KEY" → 6K tokens
├─ Read config/settings.py → 5K tokens
└─ Read .env.example → 3K tokens

Total in context: 80K tokens
Context usage: 40% of 200K window
Risk: Medium (approaching limits)
```

#### Cenário 2: Com Sub-agents (Parallel + Isolation)

```
Main Agent (orchestrator):
├─ Initial context: 15K tokens
├─ Spawn 4 sub-agents (parallel)
└─ Receive 4 summaries: 8K tokens

Sub-agents (isolated contexts):
├─ Sub-1: 30K tokens → Descartado ✅
├─ Sub-2: 25K tokens → Descartado ✅
├─ Sub-3: 35K tokens → Descartado ✅
└─ Sub-4: 20K tokens → Descartado ✅

Main Agent final context: 23K tokens
Context usage: 11.5% of 200K window
Risk: Low (tons of room left)

Benefits:
├─ Processed: 110K tokens (vs 80K)
├─ Retained: 23K tokens (vs 80K)
├─ Saved: 57K tokens (71% reduction)
├─ Speed: 4x faster (parallel)
└─ Quality: Better (diverse models)
```

### Advanced: Multi-Model Armazenamento

Different models have different strengths para coleta:

```markdown
# Strategy: Use best model for each type of collection

Sub-agent 1 (Gemini Flash):
├─ Strength: Fast pattern matching
├─ Task: Grep-heavy search
├─ Collects: 35K tokens (fast!)
└─ Returns: 2K summary

Sub-agent 2 (Claude Haiku):
├─ Strength: Accurate code understanding
├─ Task: Complex code analysis
├─ Collects: 30K tokens (accurate!)
└─ Returns: 2K summary

Sub-agent 3 (CodeQwen):
├─ Strength: Language-specific patterns
├─ Task: Python-specific search
├─ Collects: 25K tokens (specialized!)
└─ Returns: 2K summary

Sub-agent 4 (Gemini Flash):
├─ Strength: Config file parsing
├─ Task: Quick config extraction
├─ Collects: 20K tokens (fast!)
└─ Returns: 2K summary

Total collected: 110K tokens
Total retained: 8K summaries
Models used: 4 different models
Best tool for each job! ✅
```

### Best Practices: Isolated Collection

#### ✅ DO

**1. Use sub-agents for heavy data collection**
```python
# ✅ Delegate heavy lifting
Task(
    description="Search all auth files",
    prompt="Find and summarize authentication code",
    subagent_type="scout-search"
)
# Sub-agent collects 30K, returns 2K
```

**2. Configure sub-agents for condensation**
```yaml
# System prompt emphasizes summaries
---
name: collector
---
Return CONDENSED summaries only.
Never include full file contents.
Focus on: location, pattern, key finding.
```

**3. Use appropriate models for cost/speed**
```yaml
# Fast collection → Haiku
name: fast-scout
model: haiku

# Deep analysis → Sonnet
name: deep-analyzer
model: sonnet
```

**4. Collect in parallel when possible**
```python
# Spawn 4 agents at once (not sequential)
# They run in parallel, share no context
```

#### ❌ DON'T

**1. Return full content from sub-agents**
```python
# ❌ Sub-agent returns 30K
return entire_file_contents  # Defeats isolation!

# ✅ Sub-agent returns 2K summary
return condensed_summary  # Keeps main clean
```

**2. Use sub-agents for trivial tasks**
```python
# ❌ Overhead not worth it
Task("Read single small file")

# ✅ Main agent can do this
Read("small_file.py")
```

**3. Chain sub-agents unnecessarily**
```python
# ❌ Sub-agent spawns another sub-agent
# Creates deep nesting, hard to debug

# ✅ Main agent orchestrates all sub-agents
# Flat structure, easy to understand
```

---

## Tool Inheritance

### Omit `tools` → Inherit All

```yaml
---
name: my-agent
description: Agent with all tools
# tools field omitted
---

This agent has access to ALL tools, including MCP tools
```

### Specify `tools` → Restricted Access

```yaml
---
name: read-only-agent
description: Safe read-only agent
tools: Read, Grep, Glob  # Only these tools
---

This agent cannot Write, Edit, or run Bash
```

---

## Model Selection

### Model per Agent

```yaml
# Fast, cheap scout
---
name: fast-scout
model: haiku
---

# Powerful reviewer
---
name: deep-reviewer
model: sonnet
---

# Maximum capability for complex task
---
name: architect
model: opus
---
```

### When to use each:

| Model | Use Case | Speed | Cost |
|-------|----------|-------|------|
| Haiku | Fast search, simple tasks | ⚡⚡⚡ | $ |
| Sonnet | Standard complex tasks | ⚡⚡ | $$ |
| Opus | Maximum reasoning needed | ⚡ | $$$ |

---

## Best Practices

### ✅ DO

**1. Single responsibility per agent**
```yaml
# ✅ Focused
code-reviewer → Reviews code
security-auditor → Checks security
performance-analyzer → Analyzes performance

# ❌ Too broad
do-everything-agent → ???
```

**2. Return condensed summaries**
```markdown
# ✅ Good sub-agent output
Found 5 relevant files:
- src/auth.py (lines 45-120): JWT logic
- src/models.py (lines 200-250): User model

# ❌ Bad sub-agent output
Here's the entire content of 5 files... [10K tokens]
```

**3. Use appropriate models**
```yaml
# ✅ Haiku for simple search
fast-scout: haiku

# ✅ Sonnet for complex analysis
deep-reviewer: sonnet
```

### ❌ DON'T

**1. Create redundant agents**
```yaml
# ❌ Don't create 10 similar agents
code-reviewer-1, code-reviewer-2, ...

# ✅ Create ONE good agent, use multiple times
code-reviewer (use 3x in parallel for different files)
```

**2. Give too many tools**
```yaml
# ❌ Security auditor with Bash
tools: Read, Grep, Bash

# ✅ Security auditor read-only
tools: Read, Grep
```

---

## Example: Scout Implementation

```yaml
---
name: scout-gemini
description: Fast parallel search agent using Gemini
model: haiku
tools: Grep, Glob, Read
---

You are a fast search agent. Your job:

1. Use Grep/Glob to find files matching the search criteria
2. Read relevant sections (use offset/limit for large files)
3. Return CONDENSED summary with:
   - File path
   - Line ranges
   - Key findings (1-2 sentences)

DO NOT return full file contents.
DO provide enough context for planning.

Output format:
```markdown
## File: [path]
- Lines: [range]
- Finding: [brief description]
```
```

---

## Referências

- [Docs Oficiais - Sub-agents](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [07. Workflows Avançados](07-workflows-avancados.md) - Scout-Plan-Build pattern
- [05. Context Engineering](05-context-engineering.md) - R&D Framework

---

**Anterior**: [02. Slash Commands ←](02-slash-commands-composicao.md) | **Próximo**: [04. Hooks →](04-hooks-customizacao.md)
