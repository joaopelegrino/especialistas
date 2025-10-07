# Hooks - Context Bundle Logging

Hooks automáticos para logging de context bundles e outras automações.

## O que são Hooks?

Hooks são scripts que são executados automaticamente em resposta a eventos do Claude Code, como:
- `PostToolUse`: Após cada tool call
- `PreToolUse`: Antes de cada tool call
- `UserPromptSubmit`: Quando usuário submete prompt

## Arquivo: log-to-bundle.sh

### Propósito

Automaticamente loga cada tool call em um context bundle file para:
- **State preservation**: Preservar estado da sessão
- **Recovery**: Permitir reload em nova sessão
- **Audit trail**: Manter histórico de trabalho
- **Debugging**: Rastrear o que foi feito

### Como Funciona

```
Tool call ocorre
       ↓
Hook intercepta
       ↓
Extrai metadata
       ↓
Append to bundle
       ↓
Bundle file updated
```

### Estrutura do Bundle

```markdown
# Context Bundle: 20251007_143000

**Created**: 2025-10-07 14:30:00
**Session ID**: 20251007_143000

---

## Initial Context

**Working Directory**: /project/path
**Git Branch**: feature/auth-migration

---

## Tool Call Log

[14:30:25] **Read**: `src/auth.py` (lines 45-120)
[14:30:30] **Grep**: `jwt.encode` → 5 matches
[14:30:35] **Edit**: `src/auth.py`
[14:30:40] **Bash**: `pytest tests/test_auth.py -v`

---

[14:35:00] **Task**: Search for JWT usage (agent: scout-search)
[14:35:30] **Write**: `relevant_files.md`
[14:36:00] **Read**: `relevant_files.md` (lines 0-100)

---
```

## Setup

### 1. Configure Hook em settings.json

```json
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

### 2. Tornar Script Executável

```bash
chmod +x .claude/hooks/log-to-bundle.sh
```

### 3. Criar Diretório de Bundles

```bash
mkdir -p .agents/context-bundles
```

## Customização

### Filtrar Tools Específicos

Modificar o hook para logar apenas certos tools:

```bash
# Apenas Read, Write, Edit
case "$TOOL_NAME" in
  "Read"|"Write"|"Edit")
    # Log these
    ;;
  *)
    # Skip others
    exit 0
    ;;
esac
```

### Adicionar Informações Extras

```bash
# Adicionar git commit hash
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
echo "[$TIMESTAMP] **Read**: \`$FILE\` (commit: $GIT_HASH)" >> "$BUNDLE_FILE"
```

### Notificações

```bash
# Notificar após N tool calls
if [ $CALL_COUNT -eq 50 ]; then
  echo "⚠️ 50 tool calls reached - consider /clear" >> "$BUNDLE_FILE"
fi
```

## Bundle Management

### Listar Bundles Recentes

```bash
ls -lt .agents/context-bundles/ | head -10
```

### Encontrar Bundle Específico

```bash
# Por data
ls .agents/context-bundles/ | grep "20251007"

# Por conteúdo
grep -l "jwt_migration" .agents/context-bundles/*.md
```

### Arquivar Bundles Antigos

```bash
# Mover bundles > 30 dias para arquivo
mkdir -p .agents/context-bundles/archive
find .agents/context-bundles/ -name "*.md" -mtime +30 -exec mv {} .agents/context-bundles/archive/ \;
```

### Limpar Bundles

```bash
# Remover bundles > 90 dias
find .agents/context-bundles/archive/ -name "*.md" -mtime +90 -delete
```

## Usage com Commands

### Load Bundle

```bash
# Usar com /load-bundle command
/load-bundle .agents/context-bundles/20251007_143000_bundle.md
```

### Continue Session

```bash
# 1. Context ficando cheio
/context  # Check: 180K/200K

# 2. Save & reload
/clear
/load-bundle .agents/context-bundles/[current-session].md

# 3. Continue trabalho
# Context agora: 25K/200K ✅
```

## Advanced: Multiple Bundle Types

### Bundle por Task Type

```bash
# Nomear bundles descritivamente
TASK_TYPE="${TASK_TYPE:-general}"
BUNDLE_FILE="$BUNDLE_DIR/${SESSION_ID}_${TASK_TYPE}.md"

# Exemplos:
# 20251007_143000_migration.md
# 20251007_150000_bugfix.md
# 20251007_160000_feature.md
```

### Bundle Annotations

Adicionar anotações manuais:

```bash
# Adicionar nota ao bundle
echo "" >> .agents/context-bundles/current.md
echo "## Note: $(date '+%H:%M:%S')" >> .agents/context-bundles/current.md
echo "Decision made: Use JWT v2.0 for better security" >> .agents/context-bundles/current.md
```

## Troubleshooting

### Hook Não Executando

1. **Verificar permissões**:
```bash
ls -la .claude/hooks/log-to-bundle.sh
# Should show: -rwxr-xr-x
```

2. **Verificar settings.json**:
```bash
cat .claude/settings.json | grep -A 10 "PostToolUse"
```

3. **Verificar diretório existe**:
```bash
ls -la .agents/context-bundles/
```

### Bundle Muito Grande

Se bundles ficam muito grandes (>50K):

```bash
# Logar apenas summaries
echo "[$TIMESTAMP] **Read**: \`$FILE\` (summary)" >> "$BUNDLE_FILE"
# Não incluir linha completa de logs
```

### Bundle Não Criando

```bash
# Debug mode
set -x  # Adicionar no início do script
# Ver output detalhado
```

## Best Practices

### ✅ DO

- Configure logo no início do projeto
- Use nomes descritivos para session IDs
- Archive bundles periodicamente
- Review bundles para identificar padrões
- Use bundles para onboarding de time

### ❌ DON'T

- Log sensitive data (passwords, tokens)
- Create bundles sem limite de tamanho
- Commit bundles com secrets
- Forget to chmod +x o script

## Integration com Workflows

### Com Scout-Plan-Build

```bash
# Bundle captura todas as 3 fases
# Scout: Tool calls dos sub-agents
# Plan: Docs fetched, plan created
# Build: Edits, tests, progress

# Later: Reload mantém todo contexto
/load-bundle [session]
```

### Com Context Priming

```bash
# Bundle registra qual prime foi usado
# Load bundle pode re-executar o prime

# Original:
/prime-migration
[work...]

# Reload:
/load-bundle [session]
# Bundle notes: "Prime used: /prime-migration"
```

## Métricas de Eficiência

### Sem Bundles
- Session interrupted: 100% context lost
- Must restart from scratch: 150K+ tokens wasted
- No audit trail: Can't review what was done

### Com Bundles
- Session interrupted: 0% context lost
- Reload from bundle: 20K tokens (87% saved)
- Full audit trail: Complete history available
- Team collaboration: Share bundles easily

## Exemplo Completo

```bash
# 1. Setup inicial
chmod +x .claude/hooks/log-to-bundle.sh
mkdir -p .agents/context-bundles

# 2. Configure settings.json
# (add PostToolUse hook)

# 3. Start sessão
claude

# 4. Work normalmente
/prime-migration
/scout "find JWT usage"
/plan-with-docs "migrate JWT"

# 5. Context filling up (150K)
/context  # Check usage

# 6. Save & reload
/clear
/load-bundle .agents/context-bundles/[current].md

# 7. Continue com contexto preservado
/build

# 8. Depois: Review bundle
cat .agents/context-bundles/[session].md
```

---

## Recursos

- [Documentação Hooks](../docs/04-hooks-customizacao.md)
- [Context Bundles](../docs/13-12-tecnicas-context-engineering.md#adv2-use-context-bundles)
- [Load Bundle Command](../commands/load-bundle.md)
