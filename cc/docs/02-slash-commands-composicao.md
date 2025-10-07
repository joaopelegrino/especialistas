# 02. Slash Commands e Composição de Prompts

> **Feature exclusiva do Claude Code 2.0: Criar workflows reutilizáveis e compor prompts para escalar compute**

---

## O que são Slash Commands

Slash commands são **prompts reutilizáveis** armazenados como arquivos Markdown que podem ser executados com `/command-name`.

### Estrutura Básica

```markdown
---
description: Brief description (used for AI discovery)
allowed-tools: Tool1, Tool2
argument-hint: <what arguments to provide>
model: sonnet | haiku | opus
---

# Command Instructions

Your natural language prompt here.
Use $ARGUMENTS to capture arguments.
Use $1, $2, $3 for specific arguments.
```

### Localizações

| Localização | Escopo | Versionado |
|-------------|--------|------------|
| `.claude/commands/` | Projeto | ✅ Sim (git) |
| `~/.claude/commands/` | Pessoal | ❌ Não |

---

## Composição de Prompts

> "You can run custom slash commands inside of custom slash commands. You can compose your agentic prompts. This is huge!" - Indie Devdan

### Por que é Revolucionário?

**Claude Code 2.0** permite chamar slash commands **dentro** de outros commands, criando workflows complexos modulares.

#### Exemplo Simples

```markdown
# .claude/commands/test-and-commit.md
---
description: Run tests and commit if passing
---

## Step 1: Test
/run-tests

## Step 2: Commit
If all tests passed, create git commit
```

#### Exemplo Avançado: Scout-Plan-Build

```markdown
# .claude/commands/scout-plan-build.md
---
description: Complete workflow from search to implementation
---

# Step 1: Scout
/scout $ARGUMENTS

# Step 2: Plan
/plan-with-docs $ARGUMENTS

# Step 3: Build
/build
```

### Benefícios da Composição

✅ **Modularidade**: Cada command faz uma coisa bem
✅ **Reusabilidade**: Combine commands de formas diferentes
✅ **Manutenção**: Update um command, todos os workflows se beneficiam
✅ **Context Management**: Cada command pode ter context isolado via sub-agents
✅ **Escalabilidade**: Adicione compute via composição, não via single prompt

---

## Exemplos Práticos

### Example 1: Review → Fix → Test

```markdown
# .claude/commands/review-fix-test.md
---
description: Complete code review cycle
---

/code-review $ARGUMENTS

Read review results and fix HIGH/MEDIUM issues

/run-tests

If tests pass, create commit with review summary
```

### Example 2: Feature from Issue

```markdown
# .claude/commands/feature-from-issue.md
---
description: Implement feature from GitHub issue
---

Fetch issue #$1 from GitHub

/scout implement: $ISSUE_DESCRIPTION

/plan-feature $ISSUE_DESCRIPTION

/build

/create-pr "Closes #$1"
```

---

## Argumentos

### Capturar todos argumentos

```markdown
Use $ARGUMENTS to capture all: $ARGUMENTS
```

### Argumentos específicos

```markdown
File: $1
Function: $2
Test: $3
```

### Uso

```bash
/refactor-function src/utils.py calculate_total test_calculate_total

# $1 = src/utils.py
# $2 = calculate_total
# $3 = test_calculate_total
```

---

## SlashCommand Tool

Claude pode executar slash commands programaticamente durante conversas usando o **SlashCommand tool**.

```python
# Claude internamente:
SlashCommand(
    command="/review",
    args=["src/auth.py"]
)
```

**Requisito**: Command deve ter `description` no frontmatter.

---

## Best Practices

### ✅ DO

**1. Single Responsibility**
```markdown
# ✅ Good
/run-tests → Only runs tests
/create-commit → Only creates commit

# ❌ Bad
/test-commit-push → Does too much
```

**2. Clear descriptions**
```markdown
---
description: Run pytest with coverage report
---
```

**3. Use composition**
```markdown
# Instead of one huge command
/deploy:
  → /run-tests
  → /build-docker
  → /push-to-registry
  → /update-k8s
```

### ❌ DON'T

**1. Hardcode values**
```markdown
# ❌ Bad
Run tests in /home/user/project

# ✅ Good
Run tests in $ARGUMENTS or current directory
```

**2. Duplicate logic**
```markdown
# ❌ Bad: Copy-pasting test logic in multiple commands

# ✅ Good: Create /run-tests, reuse everywhere
```

---

## Referências

- [Docs Oficiais - Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [07. Workflows Avançados](07-workflows-avancados.md) - Scout-Plan-Build implementation

---

**Anterior**: [01. Fundamentos ←](01-fundamentos-claude-code.md) | **Próximo**: [03. Sub-agentes →](03-subagentes-task-tool.md)
