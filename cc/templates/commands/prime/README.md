# Prime Commands - Context Priming Templates

> **Context Priming**: Setup agent's initial context specifically for the task type

---

## O que são Prime Commands?

Prime commands são **custom slash commands** que configuram o context window do agent **especificamente para o tipo de tarefa**, ao invés de usar um CLAUDE.md grande e estático.

### Benefícios

✅ **Context relevante**: Apenas info necessária para a task
✅ **Context limpo**: Começa com ~190K disponível (vs ~170K com CLAUDE.md grande)
✅ **Múltiplas especializações**: Diferentes primes para diferentes workflows
✅ **Controle total**: Você decide o que carregar

---

## Templates Disponíveis

### `/prime` - General Understanding
**Use quando**: Começar trabalho em qualquer área do projeto
**Carrega**: Overview geral, estrutura, convenções
**Tokens**: ~3-5K

### `/prime-bug` - Bug Investigation
**Use quando**: Investigar e fixar bugs
**Carrega**: Test suite, recent changes, troubleshooting docs
**Tokens**: ~4-6K

### `/prime-feature` - Feature Development
**Use quando**: Implementar nova feature
**Carrega**: Architecture, patterns, similar features, testing
**Tokens**: ~5-7K

### Mais templates (criar conforme necessidade):
- `/prime-refactor` - Refactoring
- `/prime-test` - Testing
- `/prime-docs` - Documentation
- `/prime-deploy` - Deployment
- `/prime-cc` - Claude Code work

---

## Como Usar

### 1. Copiar para projeto

```bash
# Copiar todos os primes
cp templates/commands/prime/* .claude/commands/

# Ou individual
cp templates/commands/prime/prime.md .claude/commands/
```

### 2. Usar antes de trabalhar

```bash
# Começo do dia - entender projeto
/prime

# Bug fixing
/prime-bug #123

# Nova feature
/prime-feature "Add dark mode toggle"
```

### 3. Customizar para seu projeto

Edite os primes para refletir **seu** projeto:
- Arquivos específicos
- Patterns específicos
- Convenções do time

---

## Estrutura de um Prime

```markdown
---
description: [Clear description for AI discovery]
argument-hint: [Optional arguments]
---

# Prime [Name]

## Purpose
[What this prime does]

## Run Step
[Initial checks/commands]

## Read Step
[Files to read, in order]

## Report Step
[What agent should report after priming]
```

### Exemplo Customizado

```markdown
---
description: Prime for Python FastAPI backend work
---

# Prime Backend

## Purpose
Setup for FastAPI backend development

## Read Step
1. backend/README.md
2. backend/app/main.py
3. backend/app/core/config.py
4. backend/tests/conftest.py
5. docs/api-design.md

## Report Step
Backend context loaded:
- FastAPI structure understood
- Config and env vars clear
- Test setup ready
- API patterns known
```

---

## Integration com CLAUDE.md

### CLAUDE.md Minimal

**Keep CLAUDE.md tiny** (<50 linhas):

```markdown
# CLAUDE.md

## Universal Essentials Only
- Tech: Python 3.11, FastAPI, PostgreSQL
- Style: PEP 8, 2-space indents
- Tests: pytest, 80%+ coverage

## Common Commands
- Run: `python -m app`
- Test: `pytest`
```

**Regra**: Só adicione ao CLAUDE.md o que é **100% universal** para **100% das tasks**.

### Tudo Mais: Prime Commands

Specific context → Prime commands:
- Backend work → `/prime-backend`
- Frontend work → `/prime-frontend`
- Database migrations → `/prime-db`
- Testing → `/prime-test`

---

## Workflow Recomendado

### Morning Routine

```bash
# 1. General understanding
/prime

# 2. Specific area focus
/prime-backend
# ou
/prime-frontend

# 3. Task-specific
/prime-bug #123
# ou
/prime-feature "new feature"
```

### Context Management

```bash
# After cada major phase
/clear

# Re-prime for next phase
/prime-[next-area]

# Fresh, focused context!
```

---

## Criando Seus Próprios Primes

### 1. Identificar Padrões

Pergunte-se:
- Quais áreas do código trabalho frequentemente?
- Que arquivos sempre leio juntos?
- Que context é sempre relevante para X task?

### 2. Criar Prime

```bash
# Create new prime
touch .claude/commands/prime-[area].md

# Follow structure
# - Purpose
# - Run Step
# - Read Step
# - Report Step
```

### 3. Testar

```bash
# Test new prime
/prime-[area]

# Verify:
# - Right files read?
# - Relevant context loaded?
# - Good starting point?
```

### 4. Refinar

Ajuste baseado no uso:
- Adicione files esquecidos
- Remova files não relevantes
- Optimize ordem de leitura

---

## Métricas

### Antes (CLAUDE.md grande)
```
Startup context: 28K tokens
Time to first response: 8s
Relevant context: 60%
```

### Depois (Prime)
```
Startup context: 8K tokens
Time to first response: 3s
Relevant context: 95%
```

**Ganho**: +20K tokens, 3x faster, mais relevante

---

## Tips

### ✅ DO

1. **Keep CLAUDE.md minimal** (<50 linhas)
2. **Create primes for common workflows**
3. **Use before cada task type**
4. **Customize for your project**
5. **Version control** (commit to git)

### ❌ DON'T

1. **Don't replicate** CLAUDE.md info in primes
2. **Don't create** generic "prime-everything"
3. **Don't forget** to actually use primes
4. **Don't make** primes too long (defeats purpose)

---

## Troubleshooting

### Prime não carrega arquivos

**Fix**: Verifique paths relativos ao project root

### Context ainda grande

**Fix**: Shrink CLAUDE.md primeiro, depois adicione prime

### Não sei qual prime usar

**Fix**: Start com `/prime` (general), depois especialize conforme necessário

---

## Referências

- **Technique Level**: B3 (Beginner)
- **Framework**: R&D (Reduce)
- **Impact**: High (immediate +20K tokens)
- **Docs**: [12. Context Priming](../../docs/12-context-priming-prime.md)
- **Advanced**: [13. 12 Técnicas Context Engineering](../../docs/13-12-tecnicas-context-engineering.md)

---

**Quick Start**: Copie os 3 primes base, shrink seu CLAUDE.md, e use `/prime` antes de trabalhar!
