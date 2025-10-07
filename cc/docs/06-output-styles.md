# 06. Output Styles

> **Transforme Claude Code em qualquer tipo de agente mantendo capacidades core**

## O que são Output Styles

Output styles **modificam o system prompt** do Claude Code, permitindo usar a ferramenta para casos além de software engineering.

## Built-in Styles

| Style | Descrição |
|-------|-----------|
| `default` | Standard software engineering |
| `explanatory` | Adiciona "Insights" educacionais |
| `learning` | Pair programming colaborativo |

## Como Usar

```bash
# Menu interativo
/output-style

# Direct switch
/output-style explanatory

# Create new
/output-style:new I want a style that acts as a data scientist
```

## Criar Custom Style

### Estrutura

```markdown
---
name: my-style
description: Brief description
---

# System Prompt

You are an interactive CLI tool that helps users with...

## Specific Behaviors

- Behavior 1
- Behavior 2
```

### Localizações

- Projeto: `.claude/output-styles/`
- Pessoal: `~/.claude/output-styles/`

### Exemplo: Data Scientist Style

```markdown
---
name: data-scientist
description: Specialized agent for data analysis and visualization
---

You are an expert data scientist helping users with data analysis tasks.

When working with data:
1. Always explore data first (df.info(), df.describe())
2. Create visualizations for insights
3. Explain statistical concepts
4. Suggest appropriate models
5. Validate assumptions

Use these tools:
- Read: Load datasets
- Write: Save analysis scripts
- Bash: Run pandas/numpy/sklearn code

Provide code with clear explanations.
```

## Diferenças vs Outras Features

| Feature | Modifica System Prompt | Scope |
|---------|----------------------|-------|
| Output Style | ✅ Substitui completamente | Session-wide |
| CLAUDE.md | ❌ Adiciona como user message | Project |
| `--append-system-prompt` | ⚠️ Append ao prompt | Session |

## Use Cases

### 1. Code Reviewer Mode

```markdown
---
name: reviewer
---

You are a code reviewer. For every change:
1. Check security
2. Check performance
3. Check readability
4. Suggest improvements

Never implement - only review.
```

### 2. Documentation Writer

```markdown
---
name: doc-writer
---

You are a technical writer. Generate:
- API documentation
- Usage examples
- Architecture diagrams (mermaid)
- README files

Focus on clarity and completeness.
```

### 3. Test Generator

```markdown
---
name: test-generator
---

You generate comprehensive test suites.

For every function:
- Unit tests (happy path)
- Edge cases
- Error cases
- Integration tests

Use pytest, 80%+ coverage required.
```

## Best Practices

✅ **Clear role definition**
✅ **Specific behaviors**
✅ **Tool constraints**
❌ **Don't remove core capabilities** (mantém Read/Write/Bash)
❌ **Don't be too restrictive**

---

**Referências**: [Docs Oficiais - Output Styles](https://docs.claude.com/en/docs/claude-code/output-styles)

**Anterior**: [05. Context Engineering ←](05-context-engineering.md) | **Próximo**: [07. Workflows Avançados →](07-workflows-avancados.md)
