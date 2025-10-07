# 08. Configuração Settings.json

> **Hierarquia completa de configuração e permissions do Claude Code**

## Hierarquia de Settings

**Precedência** (maior para menor):

```
1. Enterprise Managed Settings (highest)
   /Library/Application Support/ClaudeCode/managed-settings.json (macOS)
   /etc/claude-code/managed-settings.json (Linux)

2. Local Project Settings
   .claude/settings.local.json (gitignored)

3. Project Settings
   .claude/settings.json (versioned)

4. User Settings
   ~/.claude/settings.json

5. Default Settings (lowest)
```

## Estrutura Básica

```json
{
  "model": "claude-sonnet-4-20250514",
  "maxTokens": 4096,
  "autocompact": false,
  "permissions": {
    "allowedTools": ["Read", "Write", "Edit", "Bash"],
    "deny": ["Read(.env)", "Write(/system/*)"]
  },
  "hooks": {},
  "mcpServers": {}
}
```

## Configurações Principais

### Model & Tokens

```json
{
  "model": "claude-sonnet-4-20250514",
  "maxTokens": 4096
}
```

### Autocompact

```json
{
  "autocompact": false  // Recomendado: manual compaction
}
```

### Permissions

```json
{
  "permissions": {
    "allowedTools": [
      "Read",
      "Write",
      "Edit",
      "Bash(git *)",
      "Bash(npm *)",
      "Grep",
      "Glob"
    ],
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(secrets.*)",
      "Write(/system/*)",
      "Bash(rm -rf *)"
    ]
  }
}
```

### Permission Modes

```json
{
  "permissionMode": "default"  // default | acceptEdits | plan | bypassPermissions
}
```

| Mode | Descrição |
|------|-----------|
| `default` | Ask for confirmation |
| `acceptEdits` | Auto-accept file edits |
| `plan` | Read-only (no execution) |
| `bypassPermissions` | YOLO mode (dangerous!) |

## Exemplo Completo

```json
{
  "model": "claude-sonnet-4-20250514",
  "maxTokens": 8192,
  "autocompact": false,

  "permissions": {
    "allowedTools": [
      "Read",
      "Write",
      "Edit",
      "MultiEdit",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(pytest *)",
      "Grep",
      "Glob",
      "Task"
    ],
    "deny": [
      "Read(.env*)",
      "Read(secrets/*)",
      "Write(/etc/*)",
      "Write(/system/*)",
      "Bash(rm -rf *)"
    ]
  },

  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [{
          "type": "command",
          "command": "black $file"
        }]
      }
    ]
  },

  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_..."
      }
    }
  }
}
```

## Security Best Practices

### 1. Deny Sensitive Files

```json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(credentials.*)",
      "Read(secrets/*)",
      "Read(*.pem)",
      "Read(*.key)"
    ]
  }
}
```

### 2. Restrict Bash

```json
{
  "permissions": {
    "allowedTools": [
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(pytest *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(chmod *)",
      "Bash(curl * | bash)"
    ]
  }
}
```

### 3. Environment Variables

```json
{
  "env": {
    "NODE_ENV": "development",
    "DATABASE_URL": "postgresql://localhost/dev_db"
  }
}
```

**⚠️ Não coloque secrets no settings.json versionado!**

Use `.claude/settings.local.json` (gitignored).

## Team Settings

### Project Settings (versioned)

`.claude/settings.json`:
```json
{
  "permissions": {
    "allowedTools": ["Read", "Write", "Edit", "Bash(git *)"]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write(*.py)",
      "hooks": [{"type": "command", "command": "black $file"}]
    }]
  }
}
```

### Local Overrides (personal)

`.claude/settings.local.json`:
```json
{
  "env": {
    "DATABASE_URL": "postgresql://localhost/my_dev_db"
  },
  "mcpServers": {
    "github": {
      "env": {"GITHUB_TOKEN": "ghp_my_personal_token"}
    }
  }
}
```

---

**Referências**: [Docs Oficiais - Settings](https://docs.claude.com/en/docs/claude-code/settings)

**Anterior**: [07. Workflows Avançados ←](07-workflows-avancados.md) | **Próximo**: [09. MCP Servers →](09-mcp-servers.md)
