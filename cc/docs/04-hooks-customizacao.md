# 04. Hooks e Customização

> **Automatize workflows com hooks que interceptam eventos do Claude Code**

## Tipos de Hooks

| Hook | Quando Executa | Use Case |
|------|----------------|----------|
| `PreToolUse` | Antes de executar tool | Validate, block, modify input |
| `PostToolUse` | Após tool executar | Format, test, notify |
| `UserPromptSubmit` | Usuário envia prompt | Enhance, validate |
| `Stop` | Agent finaliza | Cleanup, notify |
| `SubagentStop` | Sub-agent finaliza | Log, consolidate |
| `PreCompact` | Antes de compaction | Save state |
| `SessionStart` | Sessão inicia | Setup |
| `SessionEnd` | Sessão termina | Teardown |

## Configuração

### Estrutura

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-script $arg1 $arg2"
          }
        ]
      }
    ]
  }
}
```

### Exemplo: Auto-format Python

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [{
          "type": "command",
          "command": "black $file && pylint $file"
        }]
      }
    ]
  }
}
```

## Matchers

```json
"Bash"              // Exact match
"Write|Edit"        // Multiple tools
"*"                 // All tools
"Write(*.py)"       // Tool + file pattern
```

## Variáveis Disponíveis

- `$file`: File path (para Write/Edit/Read)
- `$CLAUDE_PROJECT_DIR`: Project root
- Input data via **stdin** (JSON)

## Exemplos Práticos

### 1. Pre-commit Validation

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash(git commit:*)",
      "hooks": [{
        "type": "command",
        "command": "npm run lint && npm test"
      }]
    }]
  }
}
```

### 2. Security Check

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write",
      "hooks": [{
        "type": "command",
        "command": "./scripts/check-secrets.sh $file"
      }]
    }]
  }
}
```

### 3. Documentation Auto-gen

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write(*.py)",
      "hooks": [{
        "type": "command",
        "command": "python -m pydoc-markdown $file > docs/$(basename $file .py).md"
      }]
    }]
  }
}
```

## Script Example

```bash
#!/bin/bash
# .claude/hooks/format-python.sh

# Receive JSON input via stdin
INPUT=$(cat)

# Extract file path
FILE=$(echo $INPUT | jq -r '.tool_input.file_path')

# Format with black
black "$FILE"

# Run pylint
pylint "$FILE"

# Exit 0 = success, non-zero = block action
exit 0
```

## Best Practices

✅ **Keep hooks fast** (< 5s)
✅ **Use absolute paths**
✅ **Handle errors gracefully**
✅ **Log to file, not stdout** (stdout is for Claude)
⚠️ **Security**: Validate all inputs
⚠️ **Timeout**: Default 60s

## Debugging

```bash
# Enable debug mode
claude --debug

# Logs show hook execution
```

---

**Referências**: [Docs Oficiais - Hooks](https://docs.claude.com/en/docs/claude-code/hooks)

**Anterior**: [03. Sub-agentes ←](03-subagentes-task-tool.md) | **Próximo**: [05. Context Engineering →](05-context-engineering.md)
