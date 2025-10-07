# Workflow Templates

Esta pasta contém workflows completos prontos para uso.

## Como Usar

### 1. Copiar para seu projeto

```bash
# Copiar commands
cp templates/commands/* .claude/commands/

# Copiar agents
cp templates/agents/* .claude/agents/
```

### 2. Executar workflow

```bash
# Scout-Plan-Build completo
/scout-plan-build "Sua tarefa aqui"

# Ou etapas individuais
/scout "Buscar arquivos de autenticação"
/plan-with-docs "Migrar para JWT v2" --docs https://jwt.io
/build
```

## Workflows Disponíveis

### Core: Scout-Plan-Build

O workflow mais importante para tasks complexas.

**Arquivos**:
- `commands/scout.md` - Busca paralela com sub-agentes
- `commands/plan-with-docs.md` - Planejamento estratégico
- `commands/build.md` - Implementação sistemática
- `commands/scout-plan-build.md` - Workflow completo

**Agents necessários**:
- `agents/scout-agent.yaml` - Agent de busca rápida

**Quando usar**:
- Migrations
- Refactorings grandes
- Features complexas
- Tasks spanning múltiplos arquivos

**Exemplo**:
```bash
/scout-plan-build "Migrate from old SDK to Claude Agent SDK v2" \
  --docs https://docs.claude.com/agent-sdk
```

### Code Review

Review completo de código.

**Arquivos**:
- `agents/code-reviewer.yaml` - Reviewer especializado

**Como usar**:
```bash
# Via Task tool ou direct invocation
Use code-reviewer agent to review src/auth.py
```

## Customização

### Adaptar Scout

Modifique `commands/scout.md` para:
- Usar modelos diferentes (Gemini, CodeQwen, etc)
- Ajustar número de agents (2-10)
- Customizar output format

### Adaptar Plan

Modifique `commands/plan-with-docs.md` para:
- Incluir steps específicos do projeto
- Adicionar validações customizadas
- Integrar com issue trackers (GitHub, Linear)

### Adaptar Build

Modifique `commands/build.md` para:
- Adicionar quality gates
- Integrar com CI/CD
- Customizar test strategy

## Estrutura Recomendada

```
.claude/
├── commands/
│   ├── scout.md
│   ├── plan-with-docs.md
│   ├── build.md
│   ├── scout-plan-build.md
│   └── [seus custom commands]
│
├── agents/
│   ├── scout-agent.yaml
│   ├── code-reviewer.yaml
│   └── [seus custom agents]
│
├── CLAUDE.md              # Project context
└── settings.json          # Configuration
```

## Best Practices

1. **Comece com Scout-Plan-Build**
   - É o workflow mais robusto
   - Funciona para 80% dos casos

2. **Customize incrementalmente**
   - Use templates como base
   - Adicione specifics do seu projeto
   - Teste e itere

3. **Documente suas mudanças**
   - Adicione comments nos templates
   - Explique customizações no CLAUDE.md

4. **Versione seus workflows**
   - Commit .claude/ para git
   - Compartilhe com time

## Troubleshooting

### Scout não encontra arquivos

- Verifique que scout-agent.yaml existe em `.claude/agents/`
- Confirme que agent tem description
- Check tools: Deve ter Grep, Glob, Read

### Plan muito genérico

- Forneça mais context via CLAUDE.md
- Inclua documentation URLs
- Seja mais específico no prompt

### Build desvia do plan

- Review o plan antes de aprovar
- Ensure plan é detalhado (file paths, line ranges)
- Add explicit validation steps

## Contribuindo

Melhorias são bem-vindas! Se criar workflows úteis:
1. Teste thoroughly
2. Documente uso
3. Compartilhe com comunidade

---

Para mais informações, veja:
- [07. Workflows Avançados](../../docs/07-workflows-avancados.md)
- [10. Exemplos Práticos](../../docs/10-exemplos-praticos.md)
