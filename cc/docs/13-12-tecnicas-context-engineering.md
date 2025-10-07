# 13. As 12 Técnicas de Context Engineering

> **Framework completo: R&D (Reduce & Delegate) para maximizar performance dos agents**

---

## Visão Geral

> "There are only two ways to manage your context window: **R and D** - Reduce and Delegate"

### R&D Framework

```
┌─────────────────────────────────────────┐
│         Context Management              │
├─────────────────────────────────────────┤
│                                         │
│  R - REDUCE                             │
│  └─ Minimize tokens entering context    │
│                                         │
│  D - DELEGATE                           │
│  └─ Offload work to other agents       │
│                                         │
└─────────────────────────────────────────┘
```

**Princípio Central**:
> "A focused agent is a performant agent"

---

## Os 4 Níveis de Context Engineering

### Beginner (B1-B3)
- **B1**: [Próxima seção] Técnica fundamental
- **B2**: Avoid MCP Servers
- **B3**: Context Prime Over CLAUDE.md

### Intermediate (I1-I3)
- **I1**: [Técnica intermediária]
- **I2**: Use Sub-Agents PROPERLY
- **I3**: [Próxima técnica]

### Advanced (ADV1-ADV3)
- **ADV1**: [Técnica avançada]
- **ADV2**: Use Context Bundles
- **ADV3**: [Próxima técnica]

### Agentic (AGE1-AGE3)
- **AGE1**: [Técnica agentic]
- **AGE2**: Primary Multi-Agent Delegation
- **AGE3**: [Técnica agentic avançada]

---

## Beginner Level

### B2: Avoid MCP Servers Desnecessários

#### Problema

MCP servers consomem tokens **mesmo quando não usados**:

```bash
/context

# Output:
MCP servers: 24.1K tokens (12% do context window!)
```

**Causa**: `.mcp.json` default carrega TODOS os servers automaticamente.

#### Solução

**1. Delete `.mcp.json` default**
```bash
# Remove arquivo default
rm .mcp.json

# Context freed: +20K tokens!
```

**2. Load MCP servers on-demand**
```bash
# Apenas quando precisar
claude --mcp-config ./mcp-configs/firecrawl-4k.json

# Ou com flag
claude --strict-mcp-config ./mcp-configs/github.json
```

**3. Create specialized MCP configs**
```
mcp-configs/
├── firecrawl-4k.json (só firecrawl)
├── github.json (só GitHub)
├── postgres.json (só database)
└── full.json (todos - usar raramente)
```

#### Resultado

```
Before:
├─ MCP servers: 24K tokens
└─ Available: 176K

After:
├─ MCP servers: 6K tokens (apenas o necessário)
└─ Available: 194K ✅ +18K freed!
```

#### Best Practice

✅ **Explicitly reference** cada MCP server quando precisar
✅ **Specialized configs** para diferentes workflows
✅ **Be conscious** com state do context window
❌ **Don't preload** todos os MCP servers
❌ **Don't use default** .mcp.json

---

### B3: Context Prime Over CLAUDE.md

**Ver documento dedicado**: [12-context-priming-prime.md](12-context-priming-prime.md)

#### Summary

**Problema**: CLAUDE.md grande (23K tokens) sempre carregado

**Solução**:
- CLAUDE.md minimal (<1K tokens)
- Multiple `/prime` commands para diferentes tasks

**Benefício**: +20K tokens freed, context relevante

---

## Intermediate Level

### I2: Use Sub-Agents PROPERLY

#### Conceito

Sub-agents têm **context window isolado** do main agent.

#### Problema Comum

```markdown
❌ Using sub-agents incorrectly:
- Spawning too many sub-agents
- Not leveraging context isolation
- Returning verbose outputs
```

#### Solução: Proper Sub-Agent Usage

**1. Context Isolation**

```
Main Agent Context:
├─ System prompt: 5K
├─ User messages: 10K
├─ Sub-agent SUMMARIES: 3K ✅
└─ Total: 18K

Sub-Agent 1 Context (isolated!):
├─ System prompt: 3K
├─ Task: 2K
├─ Web scrape results: 40K
└─ Total: 45K (NOT added to main!)

Sub-Agent 2 Context (isolated!):
├─ System prompt: 3K
├─ Task: 2K
├─ File reads: 35K
└─ Total: 40K (NOT added to main!)
```

**Main agent receives**: 3K summary
**Actual work done**: 85K tokens (delegated!)

**2. Use System Prompts**

Sub-agents usam **system prompts** (não user prompts):
- ✅ Não entra diretamente no main agent context
- ✅ Mais eficiente em tokens
- ✅ Reutilizável

**3. Return Condensed Summaries**

```markdown
# ❌ Bad sub-agent output
Here's everything I found: [40K tokens of full results]

# ✅ Good sub-agent output
Summary: Found 5 relevant files
- auth.py:45-60 (JWT logic)
- models.py:200-250 (User model)
[... concise list ...]
Total: 3K tokens
```

#### Exemplo: Load AI Docs

```bash
# Main agent
/load-ai-docs

# Spawns 10 sub-agents to scrape documentation
# Each sub-agent:
  - Uses 30-40K tokens for scraping
  - Returns 2-3K summary

# Main agent receives:
  - 10 summaries × 3K = 30K
  - Instead of 10 × 40K = 400K! ✅
```

#### Best Practice

✅ **One focused task** per sub-agent
✅ **Condensed outputs** (summaries, not full data)
✅ **System prompts** for sub-agents
✅ **Leverage isolation** - heavy work in sub-agents
❌ **Don't spawn sub-agents** for trivial tasks
❌ **Don't return verbose** outputs to main agent

---

## Advanced Level

### ADV2: Use Context Bundles

#### Conceito

**Context Bundle** = Append-only log estruturado do trabalho do agent, armazenado externamente ao context window, permitindo state recovery e continuação de trabalho.

> "Context bundles enable 70% state recovery with minimal context usage - the key to long-running agent sessions"

#### Problema

```
Agent Session 1:
├─ Context: 0K → 50K → 100K → 150K → 180K
├─ Approaching limit (90% usado)
├─ Performance degrading
└─ Need to continue work... ❌ How?

Options:
❌ Continue → Context overflow
❌ Clear all → Lose all context
✅ Context Bundle → Preserve state!
```

#### Solução: Context Bundles

### Arquitetura de Context Bundles

```
┌─────────────────────────────────────────────────────────┐
│                   AGENT SESSION                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Agent trabalha normalmente:                            │
│  ├─ Read files                                          │
│  ├─ Execute tools                                       │
│  ├─ Make decisions                                      │
│  └─ Context filling up (150K/200K)                     │
│                                                         │
│  PostToolUse Hook (automatic):                          │
│  ├─ Intercepta cada tool call                          │
│  ├─ Extrai metadata relevante                          │
│  ├─ Append to bundle file                              │
│  └─ Não afeta agent performance                        │
│                                                         │
│  Bundle File (.agents/context-bundles/session.md):     │
│  ├─ Append-only log                                    │
│  ├─ Structured format                                  │
│  ├─ Condensed summaries (não full outputs)            │
│  └─ Timestamp + metadata                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                NEW AGENT SESSION                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Load bundle:                                           │
│  /load-bundle session.md                               │
│                                                         │
│  New Agent Context:                                     │
│  ├─ System prompt: 5K                                  │
│  ├─ Bundle summary: 20K ← Condensed!                   │
│  └─ Total: 25K/200K (12.5%)                           │
│                                                         │
│  State Recovered:                                       │
│  ✅ What files were read                               │
│  ✅ Key findings from each file                        │
│  ✅ Decisions made                                      │
│  ✅ Context of the task                                │
│  ✅ Ready to continue!                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Implementação Completa

#### 1. Automatic Logging via Hooks

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/log-to-bundle.sh"
      }]
    }]
  }
}
```

**Hook Script** (`.claude/hooks/log-to-bundle.sh`):

```bash
#!/bin/bash

# Context bundle logging hook
# Automatically logs tool calls to append-only bundle

BUNDLE_DIR=".agents/context-bundles"
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%Y%m%d_%H%M%S)}"
BUNDLE_FILE="$BUNDLE_DIR/${SESSION_ID}_bundle.md"

# Create bundle dir if not exists
mkdir -p "$BUNDLE_DIR"

# Initialize bundle if new
if [ ! -f "$BUNDLE_FILE" ]; then
  cat > "$BUNDLE_FILE" << EOF
# Context Bundle: $SESSION_ID
**Created**: $(date '+%Y-%m-%d %H:%M:%S')
**Session**: $SESSION_ID

---

EOF
fi

# Parse tool call from stdin
TOOL_NAME=$(echo "$TOOL_OUTPUT" | jq -r '.tool')
TOOL_ARGS=$(echo "$TOOL_OUTPUT" | jq -r '.args')
TIMESTAMP=$(date '+%H:%M:%S')

# Log based on tool type
case "$TOOL_NAME" in
  "Read")
    FILE=$(echo "$TOOL_ARGS" | jq -r '.file_path')
    LINES=$(echo "$TOOL_ARGS" | jq -r '.offset // 0')-$(echo "$TOOL_ARGS" | jq -r '(.offset // 0) + (.limit // 100)')
    echo "[$TIMESTAMP] **Read**: \`$FILE\` (lines $LINES)" >> "$BUNDLE_FILE"
    ;;

  "Grep")
    PATTERN=$(echo "$TOOL_ARGS" | jq -r '.pattern')
    RESULTS=$(echo "$TOOL_OUTPUT" | jq -r '.matches | length')
    echo "[$TIMESTAMP] **Grep**: \`$PATTERN\` → $RESULTS matches" >> "$BUNDLE_FILE"
    ;;

  "Edit")
    FILE=$(echo "$TOOL_ARGS" | jq -r '.file_path')
    echo "[$TIMESTAMP] **Edit**: \`$FILE\`" >> "$BUNDLE_FILE"
    ;;

  "Bash")
    CMD=$(echo "$TOOL_ARGS" | jq -r '.command' | head -c 50)
    echo "[$TIMESTAMP] **Bash**: \`$CMD...\`" >> "$BUNDLE_FILE"
    ;;

  "Task")
    DESC=$(echo "$TOOL_ARGS" | jq -r '.description')
    AGENT=$(echo "$TOOL_ARGS" | jq -r '.subagent_type')
    echo "[$TIMESTAMP] **Task**: $DESC (agent: $AGENT)" >> "$BUNDLE_FILE"
    ;;
esac

# Every 10 tool calls, add separator
CALL_COUNT=$(grep -c "^\[" "$BUNDLE_FILE")
if [ $((CALL_COUNT % 10)) -eq 0 ]; then
  echo "" >> "$BUNDLE_FILE"
  echo "---" >> "$BUNDLE_FILE"
  echo "" >> "$BUNDLE_FILE"
fi
```

#### 2. Bundle Structure

```markdown
# Context Bundle: 20251007_143022
**Created**: 2025-10-07 14:30:22
**Session**: 20251007_143022
**Task**: Migrate authentication to new JWT library

---

## Initial Context

### Prime Command
/prime-bug

### User Prompt
"Migrate from old_jwt to new_jwt library. Ensure backwards compatibility."

### Documentation
- https://docs.new-jwt.com/migration

---

## Tool Call Log

[14:30:25] **Read**: `.claude/CLAUDE.md` (lines 0-50)
[14:30:28] **Grep**: `old_jwt` → 8 matches
[14:30:32] **Read**: `src/auth/login.py` (lines 45-120)
[14:30:35] **Read**: `src/auth/tokens.py` (lines 20-85)
[14:30:40] **WebFetch**: https://docs.new-jwt.com/migration
[14:30:45] **Write**: `ai_docs.md` (cached documentation)
[14:30:50] **Read**: `src/models/user.py` (lines 150-220)
[14:30:55] **Grep**: `jwt.encode` → 5 matches
[14:31:00] **Read**: `src/api/auth_routes.py` (lines 30-120)
[14:31:05] **Task**: Search for JWT usage patterns (agent: scout-gemini)

---

[14:31:30] **Task**: Create migration plan (agent: planner)
[14:31:35] **Read**: `relevant_files.md` (Scout output)
[14:31:40] **Write**: `detailed_plan.md` (Plan output)
[14:31:45] **Read**: `detailed_plan.md` (lines 0-200)
[14:31:50] **Edit**: `src/auth/login.py` (JWT token creation)
[14:31:55] **Bash**: `pytest tests/test_auth.py::test_create_token`
[14:32:00] **Edit**: `src/auth/login.py` (JWT token validation)
[14:32:05] **Bash**: `pytest tests/test_auth.py::test_validate_token`
[14:32:10] **Edit**: `src/auth/tokens.py` (Token refresh)

---

## Key Findings

### Authentication Architecture
- Uses JWT tokens for session management
- Token generation in `src/auth/login.py:45-60`
- Token validation in `src/auth/login.py:100-115`
- Refresh logic in `src/auth/tokens.py:45-60`

### Migration Requirements
- Replace `old_jwt.encode()` with `new_jwt.create()`
- Replace `old_jwt.decode()` with `new_jwt.verify()`
- Add explicit `algorithm="HS256"` parameter
- Update exception handling (same exception name, different module)

### Test Coverage
- Unit tests: `tests/test_auth.py` (42 tests)
- Integration tests: `tests/integration/test_auth_flow.py` (12 tests)
- Current status: All passing with old_jwt

### Risk Assessment
- **Medium risk**: Authentication is critical system
- **Mitigation**: Backwards compatibility layer planned
- **Rollback**: Easy (revert + reinstall old_jwt)

---

## Decisions Made

1. **Migration Strategy**: Phase-by-phase (not big bang)
2. **Testing**: Test after each phase before continuing
3. **Documentation**: Cache docs locally (ai_docs.md)
4. **Compatibility**: Maintain during transition period

---

## Progress Tracking

### Phase 1: Token Generation ✅
- [x] Update login.py token creation
- [x] Tests passing

### Phase 2: Token Validation ⏳
- [x] Update login.py token validation
- [x] Tests passing
- [ ] Update tokens.py refresh logic (NEXT)

### Phase 3: Models (Pending)
- [ ] Review user model interactions

---

## Context Status
**Tokens used**: 180K/200K (90%)
**Next action**: Consider /clear or /load-bundle for fresh start
```

#### 3. Reload Bundle Command

**Custom command** (`.claude/commands/load-bundle.md`):

```markdown
---
description: Load context bundle to restore previous session state
argument-hint: <bundle-file-path>
---

# Load Context Bundle

Load a previously saved context bundle to restore agent state.

## Instructions

1. **Read bundle file**
```
Read($ARGUMENTS)
```

2. **Parse and summarize**

Extract from bundle:
- Initial context (prime, prompt, docs)
- Files that were read (with line ranges)
- Key findings and decisions
- Progress tracking
- Current phase

3. **Create condensed summary**

Do NOT include:
- ❌ Full tool call logs (too verbose)
- ❌ Exact timestamps (not relevant)
- ❌ Hook metadata (internal)

DO include:
- ✅ What files were examined
- ✅ Key findings from each file
- ✅ Decisions that were made
- ✅ Current progress/phase
- ✅ Next actions

4. **Report state**

```markdown
# Session Restored

**Original session**: [ID]
**Task**: [task description]
**Progress**: Phase X/Y complete

## Context Loaded
- Examined N files
- Key findings: [summary]
- Current phase: [phase name]

## Ready to Continue
Next action: [what to do next based on progress]
```

5. **Continue work**

Agent is now primed with context and ready to continue where previous session left off.
```

**Usage**:

```bash
# Load bundle to continue work
/load-bundle .agents/context-bundles/20251007_143022_bundle.md

# Agent response:
# Session Restored
#
# Task: Migrate to new JWT library
# Progress: Phase 2/6 complete (Token Validation)
#
# Context Loaded:
# - Examined 8 authentication files
# - Completed: Token generation migration
# - Completed: Token validation migration
# - Pending: Token refresh logic (src/auth/tokens.py)
#
# Ready to Continue
# Next: Update token refresh in src/auth/tokens.py:45-60
```

### Benefícios Quantificados

#### Sem Context Bundles

```
Agent 1 (original session):
├─ Work: 0K → 180K context used
├─ Context overflow approaching
└─ Options:
    ├─ Continue → Overflow ❌
    └─ /clear → Lose everything ❌

Start over from scratch:
├─ Re-search files (30K tokens)
├─ Re-read files (50K tokens)
├─ Re-analyze (40K tokens)
├─ Re-plan (30K tokens)
└─ Total: 150K tokens wasted! ❌
```

#### Com Context Bundles

```
Agent 1 (original session):
├─ Work: 0K → 180K context used
├─ Bundle logged automatically via hooks
└─ /clear (safe! state saved)

Agent 2 (reload):
├─ /load-bundle session.md
├─ Bundle summary: 20K tokens
├─ Ready to continue!
└─ Saved: 130K tokens! ✅

Efficiency:
├─ State recovery: 70%+
├─ Tokens saved: 87%
└─ Time saved: ~15 minutes
```

### Advanced: Bundle Analysis

Create command to analyze bundles:

```markdown
# .claude/commands/analyze-bundle.md

---
description: Analyze context bundle for insights
---

# Analyze Context Bundle

Read bundle file and provide insights:

1. **Activity Summary**
   - Total tool calls
   - Most used tools
   - Files examined
   - Time spent

2. **Efficiency Metrics**
   - Context usage progression
   - Re-reads (inefficiency indicator)
   - Sub-agent usage

3. **Recommendations**
   - Identify patterns
   - Suggest optimizations
   - Note bottlenecks
```

### Best Practices

#### ✅ DO

**1. Selective logging - Log summaries, not full outputs**
```bash
# ✅ Good logging
[14:30] Read: auth.py (lines 45-120) → Found JWT logic

# ❌ Bad logging
[14:30] Read: auth.py
[... 2000 lines of file content ...]
```

**2. Structure bundles consistently**
```markdown
- Initial Context (once)
- Tool Call Log (chronological)
- Key Findings (updated)
- Progress Tracking (checkboxes)
- Context Status (at intervals)
```

**3. Use unique session IDs**
```bash
# Timestamp-based
SESSION_ID=$(date +%Y%m%d_%H%M%S)

# Or UUID
SESSION_ID=$(uuidgen)

# Or task-based
SESSION_ID="migrate_jwt_$(date +%Y%m%d)"
```

**4. Archive bundles after task completion**
```bash
mkdir -p .agents/context-bundles/completed/
mv .agents/context-bundles/*_bundle.md .agents/context-bundles/completed/
```

**5. Share bundles with team**
```bash
# Bundle é self-contained
# Pode ser commitado ou shared
git add .agents/context-bundles/important_migration.md
git commit -m "docs: Add context bundle for JWT migration"
```

#### ❌ DON'T

**1. Log full tool outputs**
```markdown
# ❌ Don't do this
[14:30] Read: auth.py
Content:
[entire file - 5000 lines]

# ✅ Do this
[14:30] Read: auth.py (lines 45-120)
Finding: JWT token generation using old library
```

**2. Log every single action**
```markdown
# ❌ Too granular
[14:30:00] Thinking about what to do
[14:30:01] Deciding to read file
[14:30:02] Reading file...

# ✅ Action-focused
[14:30] Read: auth.py (lines 45-120)
```

**3. Include sensitive data**
```markdown
# ❌ Never log secrets
[14:30] Found SECRET_KEY: "sk_live_abc123..."

# ✅ Redact sensitive info
[14:30] Found SECRET_KEY configuration (redacted)
```

**4. Create bundle without structure**
```markdown
# ❌ Unstructured
Read file
Found something
Did thing
...

# ✅ Structured
## Tool Calls
[timestamp] Tool: description

## Findings
- Key finding 1
- Key finding 2
```

### Integration with Other Techniques

Context Bundles trabalham bem com:

**1. Context Priming**
```bash
# Agent 1
/prime-bug
[work... context fills up]

# Agent 2
/load-bundle session.md
# Bundle includes which prime was used
# Agent 2 has same primed context!
```

**2. Scout-Plan-Build**
```markdown
# Bundle tracks workflow phase
- Phase: Scout (completed)
- Phase: Plan (completed)
- Phase: Build (in progress - 60%)

# Reload knows exactly where to continue
```

**3. Multi-Agent Orchestration**
```markdown
# Main agent bundle references sub-agent results
[14:30] Task: Scout search (agent: scout-1)
        → Result: relevant_files.md
[14:35] Task: Plan creation (agent: planner)
        → Result: detailed_plan.md
```

---

## Agentic Level

### AGE2: Primary Multi-Agent Delegation

#### Conceito

**Kick off primary agents** from primary agents = True multi-agent system.

#### Diferença vs Sub-Agents

| Feature | Sub-Agents | Primary Agents |
|---------|------------|----------------|
| Context | Partially isolated | Fully isolated |
| Control | Limited | Complete |
| Workflow | Embedded | Independent |
| Use Case | Quick delegation | Complex workflows |

#### Implementação: Background Agents

**1. Simple Background Command**

```markdown
# .claude/commands/background.md
---
description: Kick off background Claude Code instance
argument-hint: <prompt> <model> <report-file>
---

# Background Agent Delegation

## Create Report File
Create: .agents/background/[task-name]-report.md

## Kick Off Agent
```xml
<primary-agent-delegation>
  <prompt>$1</prompt>
  <model>$2</model>
  <report-file>$3</report-file>
</primary-agent-delegation>
```

Boot Claude Code instance:
- Working directory: current
- Report to: $3
- Model: $2
- Task: $1

Run completely out-of-loop.
```

**2. Usage**

```bash
# Main agent (in-the-loop)
/background "Create comprehensive plan for UV SDK" "opus" ".agents/bg-plan.md"

# Background agent spawned:
  - Runs independently
  - Full context window
  - Reports to file
  - Main agent freed!
```

**3. Monitor Progress**

```bash
# Check status
cat .agents/bg-plan.md

# Background task still running...

# Later:
cat .agents/bg-plan.md-COMPLETE

# ✅ Task completed!
# Full plan ready
```

#### Advanced: Multi-Agent Pipelines

```bash
# Agent 1: Research
/background "Research new framework" "sonnet" "research.md"

# Agent 2: Design (após Agent 1)
/background "Design architecture based on research.md" "opus" "design.md"

# Agent 3: Implement (após Agent 2)
/background "Implement design.md" "sonnet" "implement.md"

# Agent 4: Test (após Agent 3)
/background "Test implementation" "haiku" "test.md"
```

#### Benefícios

✅ **True out-of-loop** - você pode AFK
✅ **Full context** para cada agent (200K cada)
✅ **Specialized models** - opus para complex, haiku para simple
✅ **Parallel or sequential** workflows
✅ **Asymmetric returns** no tempo de engineering

#### Best Practice

✅ **Clear prompts** - agent deve trabalhar autonomously
✅ **Report files** - track progress
✅ **Context bundles** - audit trail
✅ **Well-defined tasks** - não vague
❌ **Don't micromanage** - trust the process
❌ **Don't use for UI tasks** - background agents can't interact

---

## Resumo das 12 Técnicas

### R (Reduce) - 6 técnicas

| # | Técnica | Tokens Saved | Dificuldade |
|---|---------|--------------|-------------|
| B2 | Avoid MCP Servers | +20K | Fácil |
| B3 | Context Prime | +20K | Fácil |
| | Use offset/limit | +10-50K | Fácil |
| | Clear at breakpoints | Variable | Fácil |
| | Minimal CLAUDE.md | +20K | Médio |
| | Specialized configs | +5-15K | Médio |

### D (Delegate) - 6 técnicas

| # | Técnica | Impact | Dificuldade |
|---|---------|--------|-------------|
| I2 | Sub-Agents Properly | Alto | Médio |
| ADV2 | Context Bundles | Alto | Avançado |
| AGE2 | Multi-Agent Delegation | Muito Alto | Avançado |
| | Scout-Plan-Build | Muito Alto | Médio |
| | Parallel sub-agents | Alto | Médio |
| | Out-of-loop ADWs | Máximo | Avançado |

---

## Quick Wins (Implementar Hoje)

### 1. Delete .mcp.json default
```bash
rm .mcp.json
# +20K tokens freed instantly
```

### 2. Shrink CLAUDE.md
```bash
# Reduce para <50 linhas
# +15-20K tokens freed
```

### 3. Create /prime command
```bash
# One prime command
# Immediate context control
```

### 4. Use /clear at breakpoints
```bash
# After cada major phase
/clear
# Fresh start
```

---

## Advanced Implementation (Esta Semana)

### 1. Setup sub-agents properly
- Create specialized sub-agents
- System prompts com focused tasks
- Return condensed summaries

### 2. Implement context bundles
- Hook-based logging
- Session tracking
- Bundle reload workflow

### 3. Background agent workflow
- `/background` command
- Report file system
- Monitor progress

---

## Expert Level (Este Mês)

### 1. Multi-agent pipelines
- Sequential workflows
- Parallel execution
- ADW systems

### 2. Expert agents (próxima seção)
- Specialized agent experts
- TAC-level workflows
- Zero-touch execution

---

## Métricas de Sucesso

### Context Efficiency

```
Before optimization:
├─ Startup: 28K tokens used (14%)
├─ MCP: 24K
├─ CLAUDE.md: 23K
├─ Available: 149K
└─ Wasted: ~47K tokens

After optimization:
├─ Startup: 8K tokens used (4%)
├─ MCP: 0K (on-demand)
├─ CLAUDE.md: 0.3K
├─ /prime: 3K (on-demand)
├─ Available: 192K ✅
└─ Wasted: ~0K tokens
```

**Ganho**: +43K tokens (21.5% do context window!)

### Performance Metrics

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| Context Usage | 28K | 8K | -71% |
| Time to First Response | 8s | 3s | -62% |
| Tokens Wasted | 20K/session | 2K/session | -90% |
| Relevant Context | 60% | 95% | +58% |
| Agent Focus | Low | High | - |
| Error Rate | 15% | 5% | -67% |

---

## Key Principles

### 1. Measure & Manage

```bash
# Always know your context state
/context

# Track what's consuming tokens
# Optimize ruthlessly
```

### 2. Focused Agents

> "A focused agent is a performant agent"

- One task per agent
- Relevant context only
- Clear, singular purpose

### 3. Spend Tokens Wisely

**Not about saving tokens** - about **spending them properly**:
- ❌ Wasted on irrelevant MCP servers
- ❌ Wasted on huge CLAUDE.md
- ✅ Spent on relevant task context
- ✅ Spent on high-quality outputs

### 4. Reduce AND Delegate

Use **both** techniques:
- Reduce context entering main agent
- Delegate heavy work to sub-agents

### 5. Progressive Enhancement

Start simple:
```
Week 1: Delete .mcp.json + shrink CLAUDE.md
Week 2: Add /prime commands
Week 3: Proper sub-agents
Week 4: Context bundles
Week 5: Multi-agent delegation
```

---

## Referências

- **Framework**: R&D (Reduce & Delegate)
- **Princípio**: "Focused agent = Performant agent"
- **Source**: "Levels of Context Engineering" (TAC)
- **Related**:
  - [05. Context Engineering](05-context-engineering.md)
  - [12. Context Priming](12-context-priming-prime.md)

---

## Conclusão

> "Managing your context window is the name of the game for effective agent coding."

**Context engineering não é sobre**:
- ❌ Saving tokens por saving tokens
- ❌ Complexidade desnecessária

**Context engineering É sobre**:
- ✅ Focused agents
- ✅ Relevant context
- ✅ Better outputs
- ✅ Fewer corrections
- ✅ One-shot out-of-loop execution

**Start today**: Implemente B2 e B3. Ganho imediato: +40K tokens.

**Scale up**: Adicione técnicas conforme precisar.

**Master it**: All 12 techniques = Elite context engineering.

---

**Anterior**: [12. Context Priming ←](12-context-priming-prime.md)
