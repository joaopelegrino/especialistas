# 11. Best Practices Consolidadas

> **Práticas comprovadas da documentação oficial Anthropic e comunidade**

## Context Management

### ✅ DO

**Disable autocompact**
```json
{"autocompact": false}
```
→ Compacte manualmente em breakpoints estratégicos

**Use R&D Framework**
- **Reduce**: Read apenas o necessário (offset/limit)
- **Delegate**: Offload para sub-agents

**Clear at breakpoints**
```bash
# Após completar fase
/clear
```

**Scout-Plan-Build pattern**
→ Separa search, planning, implementation

### ❌ DON'T

❌ Read arquivos inteiros desnecessariamente
❌ Deixar autocompact consumir 22% do context
❌ Acumular tool outputs no context
❌ Single agent para tasks complexas

---

## Workflow Design

### ✅ DO

**Use Plan Mode para exploration**
```bash
claude --permission-mode plan
```
→ Safe read-only exploration

**Test-driven development**
```markdown
1. Write tests first
2. Implement to pass tests
3. Refactor while green
```

**Incremental validation**
```markdown
Phase 1 → Test → ✅
Phase 2 → Test → ✅
Phase 3 → Test → ✅
```

**Visual targets for UI**
→ Provide screenshots para iteration

### ❌ DON'T

❌ Implement tudo before testing
❌ Skip planning for complex tasks
❌ Ignore failing tests
❌ Code without validation strategy

---

## Prompt Engineering

### ✅ DO

**Be specific**
```markdown
✅ "Use 2-space indentation, PEP 8, pytest for tests"
❌ "Write good code"
```

**Provide context via CLAUDE.md**
```markdown
# .claude/CLAUDE.md
Tech stack: FastAPI, PostgreSQL, React
Style: PEP 8, 2-space indents
Tests: pytest, 80%+ coverage
```

**Structure complex prompts**
```markdown
## Goal
[What to achieve]

## Constraints
[Limitations]

## Success Criteria
[How to validate]

## Context
[@file.py for relevant files]
```

**Use composition**
```markdown
# Modular, reusable
/scout → /plan → /build

# Instead of one huge prompt
```

### ❌ DON'T

❌ Vague instructions ("make it better")
❌ No validation criteria
❌ Missing context
❌ Duplicate logic across prompts

---

## Sub-agent Strategy

### ✅ DO

**Single responsibility**
```yaml
code-reviewer: Review only
security-auditor: Security only
```

**Use appropriate models**
- Haiku: Fast search
- Sonnet: Complex tasks
- Opus: Maximum reasoning

**Return condensed summaries**
```markdown
✅ "Found 5 files, see summary"
❌ "Here's 50K tokens of results"
```

**Parallel for independent tasks**
```markdown
Launch 4 scouts in parallel ✅
```

### ❌ DON'T

❌ Create redundant agents
❌ Give too many tools
❌ Return verbose outputs
❌ Single agent quando parallelism helps

---

## Security

### ✅ DO

**Deny sensitive files**
```json
{
  "permissions": {
    "deny": [
      "Read(.env*)",
      "Read(secrets/*)",
      "Write(/system/*)"
    ]
  }
}
```

**Restrict dangerous commands**
```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  }
}
```

**Use settings.local.json for secrets**
→ Gitignored, personal only

**Validate inputs in hooks**
```bash
#!/bin/bash
# Validate before execution
if [[ "$INPUT" =~ "rm -rf" ]]; then
  exit 1  # Block
fi
```

### ❌ DON'T

❌ Commit secrets to git
❌ Use bypassPermissions by default
❌ Give unrestricted Bash access
❌ Trust external inputs without validation

---

## Team Collaboration

### ✅ DO

**Version control configs**
```
.claude/
├── settings.json      ← Versioned
├── commands/          ← Versioned
├── agents/            ← Versioned
└── settings.local.json ← Gitignored
```

**Document custom agents**
```yaml
---
name: team-reviewer
description: Our team's code review standards
# Document what it checks
---
```

**Shared CLAUDE.md**
```markdown
# .claude/CLAUDE.md
## Team Conventions
- Style: PEP 8
- Tests: pytest, 80%+ coverage
- Review: Required before merge
```

**Consistent naming**
```markdown
/scout-plan-build  ← Clear, predictable
/spb               ← Avoid abbreviations
```

### ❌ DON'T

❌ Personal configs in versioned files
❌ Undocumented custom agents
❌ Inconsistent command naming
❌ Skip team alignment on conventions

---

## Performance

### ✅ DO

**Profile before optimizing**
```bash
# Find actual bottlenecks first
```

**Use appropriate models**
- Haiku for simple tasks (faster, cheaper)
- Sonnet for standard (balanced)
- Opus when max capability needed

**Parallel execution**
```markdown
4 scouts in parallel > 4 scouts sequential
```

**Cache documentation locally**
```markdown
WebFetch(docs) → Save to ai_docs.md
Reuse in future phases
```

### ❌ DON'T

❌ Premature optimization
❌ Always use Opus (expensive!)
❌ Sequential quando parallel works
❌ Re-fetch same documentation

---

## Testing & Validation

### ✅ DO

**Test after each phase**
```markdown
Phase 1 → pytest → ✅ Pass → Phase 2
```

**Automated validation**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write(*.py)",
      "hooks": [{"command": "pytest $file"}]
    }]
  }
}
```

**Coverage requirements**
```markdown
Require 80%+ coverage
Run coverage report after tests
```

**Integration tests**
```markdown
Unit tests → Integration tests → E2E tests
```

### ❌ DON'T

❌ Skip testing
❌ Only test at end
❌ Ignore failing tests
❌ No coverage tracking

---

## Debugging

### ✅ DO

**Enable debug mode**
```bash
claude --debug
```

**Check context usage**
```bash
/context
```

**Inspect agent outputs**
```markdown
# Save sub-agent outputs
relevant_files.md
detailed_plan.md
implementation_summary.md
```

**Use hooks for logging**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{"command": "echo $(date) $tool_name >> claude.log"}]
    }]
  }
}
```

### ❌ DON'T

❌ Debug sem logs
❌ Ignore context warnings
❌ Skip verification steps
❌ No visibility into sub-agents

---

## Key Principles

### 1. Build the System that Builds the System

> Invest in reusable agentic infrastructure

- Custom commands
- Specialized agents
- Automated workflows
- Templates

### 2. Scale Your Compute

> Don't be limited by single agent

- Parallel sub-agents
- Out-of-loop ADWs
- Multi-perspective reviews

### 3. Manage Context Religiously

> Context is your most precious resource

- R&D Framework
- Scout-Plan-Build
- Manual compaction
- Delegation

### 4. Start Simple, Add Complexity

> Progressive enhancement

```
Week 1: Learn in-the-loop basics
Week 2: Add custom commands
Week 3: Create sub-agents
Week 4: Implement Scout-Plan-Build
Week 5: Build ADW system
```

---

## Referências

- [Anthropic Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Transcrição Original](../transcricao.md)

---

**Anterior**: [10. Exemplos Práticos ←](10-exemplos-praticos.md)
