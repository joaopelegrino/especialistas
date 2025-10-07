# Guia de Migração - Estrutura Padrão Claude Code

## Para Projetos Existentes

Se você já tem um projeto usando Claude Code e quer migrar para esta estrutura otimizada, siga este guia.

## 🎯 Objetivos da Migração

- ✅ Reduzir uso de contexto em 70%+
- ✅ Habilitar recuperação de estado (context bundles)
- ✅ Workflows estruturados (Scout-Plan-Build)
- ✅ Context priming JIT ao invés de CLAUDE.md grande
- ✅ Audit trail completo do trabalho

## 📊 Antes vs Depois

### Antes (Estrutura Tradicional)
```
projeto/
├── .claude/
│   └── settings.json        # Configuração básica
├── CLAUDE.md               # 15K tokens de contexto estático
└── README.md
```

**Problemas**:
- CLAUDE.md muito grande (15K+ tokens sempre carregado)
- Sem structure para workflows complexos
- Context overflow frequente
- Perda total de estado ao limpar contexto
- Sem audit trail

### Depois (Estrutura Otimizada)
```
projeto/
├── .claude/
│   ├── commands/           # 9 slash commands
│   ├── agents/             # 3 sub-agents
│   ├── hooks/              # Auto-logging
│   └── settings.json       # Hooks habilitados
├── .agents/
│   ├── context-bundles/    # State recovery
│   └── outputs/            # Fase outputs
├── CLAUDE.md              # Apenas 1K tokens (mínimo)
└── README.md
```

**Benefícios**:
- CLAUDE.md reduzido para ~1K tokens
- Workflows estruturados com Scout-Plan-Build
- Context priming JIT (carrega quando precisa)
- 70% state recovery via bundles
- Full audit trail de todo trabalho

## 🚀 Passo a Passo da Migração

### Etapa 1: Backup

```bash
# Backup da configuração atual
cp -r .claude .claude.backup
cp CLAUDE.md CLAUDE.md.backup
```

### Etapa 2: Instalar Estrutura Nova

```bash
# Opção A: Script automático (recomendado)
/path/to/estrutura-padrao/install.sh .

# Opção B: Manual
cp -r /path/to/estrutura-padrao/commands .claude/
cp -r /path/to/estrutura-padrao/agents .claude/
cp -r /path/to/estrutura-padrao/hooks .claude/
chmod +x .claude/hooks/*.sh
mkdir -p .agents/context-bundles .agents/outputs
```

### Etapa 3: Migrar settings.json

```bash
# Salvar settings antigo
cp .claude/settings.json .claude/settings.json.old

# Adicionar hooks ao settings.json
nano .claude/settings.json
```

**Merge necessário** - Adicione ao seu settings.json existente:

```json
{
  "autocompact": false,
  "hooks": {
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/log-to-bundle.sh",
        "description": "Log tool calls to context bundle"
      }]
    }]
  }
}
```

### Etapa 4: Refatorar CLAUDE.md

**Princípio**: CLAUDE.md deve ter < 1K tokens (apenas essentials).

#### Antes (Exemplo Ruim):
```markdown
# My Project

## Architecture

[5000 palavras sobre arquitetura...]

## Testing Strategy

[3000 palavras sobre testes...]

## Authentication

[4000 palavras sobre auth...]

## Database Schema

[3000 palavras sobre DB...]

Total: ~15K tokens sempre carregados
```

#### Depois (Exemplo Bom):
```markdown
# My Project

## Essentials
- Tech: Python 3.11, FastAPI, PostgreSQL
- Style: PEP 8, type hints required
- Tests: pytest, 80% coverage

## Commands
- Dev: npm run dev
- Test: pytest
- Build: npm run build

## Context Management
Use /prime-* for detailed context

Total: ~1K tokens
```

**Onde foi o conteúdo detalhado?** → Movido para `/prime-*` commands!

### Etapa 5: Criar Prime Commands Customizados

Pegue o conteúdo grande do CLAUDE.md antigo e distribua em primes:

#### 5.1 Criar `/prime-architecture`

```bash
nano .claude/commands/prime-architecture.md
```

```markdown
---
description: Load detailed architecture context
---

# Architecture Context

[Seu conteúdo detalhado de arquitetura aqui]
[~4-6K tokens, carregado apenas quando necessário]
```

#### 5.2 Criar `/prime-auth`

```bash
nano .claude/commands/prime-auth.md
```

```markdown
---
description: Load authentication context
---

# Authentication Context

[Seu conteúdo detalhado de auth aqui]
[~3-5K tokens, carregado apenas quando trabalhando com auth]
```

#### 5.3 Criar `/prime-db`

```bash
nano .claude/commands/prime-db.md
```

```markdown
---
description: Load database schema context
---

# Database Context

[Seu schema detalhado aqui]
[~2-4K tokens, carregado apenas quando modificando DB]
```

**Resultado**: Contexto total disponível = ~12K tokens
- Mas carregado JIT (apenas quando precisa)
- Ao invés de 15K sempre carregado upfront

### Etapa 6: Atualizar .gitignore

```bash
# Adicionar ao .gitignore
cat >> .gitignore << 'EOF'

# Claude Code
.agents/context-bundles/*.md
.agents/outputs/*
!.agents/context-bundles/.gitkeep
!.agents/outputs/.gitkeep
.claude.backup/
CLAUDE.md.backup
EOF
```

### Etapa 7: Validar Instalação

```bash
# Validar que tudo está correto
/path/to/estrutura-padrao/validate.sh .
```

**Esperado**: Todas as verificações ✓ ou apenas ⚠ (sem ✗).

### Etapa 8: Testar

```bash
# Iniciar Claude Code
claude

# Testar comandos básicos
/prime
/scout "find main entry point"
/context  # Ver uso de contexto

# Verificar que bundles estão sendo criados
ls -la .agents/context-bundles/
```

## 📋 Checklist de Migração

- [ ] Backup criado (`.claude.backup/`, `CLAUDE.md.backup`)
- [ ] Estrutura instalada (commands, agents, hooks)
- [ ] Hooks executáveis (`chmod +x`)
- [ ] settings.json atualizado (hooks, autocompact: false)
- [ ] CLAUDE.md reduzido para < 1K tokens
- [ ] Prime commands customizados criados
- [ ] .gitignore atualizado
- [ ] Validação passou (`validate.sh`)
- [ ] Testes básicos funcionando

## 🎓 Aprendendo a Nova Estrutura

### Novo Workflow: Feature Development

**Antes** (abordagem tradicional):
```bash
claude
# Agent lê 15K tokens de CLAUDE.md upfront
"Implement JWT refresh token feature"
# Agent busca arquivos, planeja, implementa - tudo no main context
# Context usage: 150K/200K (75%) após 1 feature
```

**Depois** (abordagem otimizada):
```bash
claude

# 1. Prime apenas para auth work
/prime-auth  # Carrega 4K tokens de auth context

# 2. Scout com sub-agents paralelos
/scout "Find JWT token handling"
# 4 sub-agents buscam em paralelo
# Retorna relevant_files.md (~3K tokens, não 45K)

# 3. Plan com docs
/plan-with-docs "Add JWT refresh tokens" --docs https://pyjwt.readthedocs.io
# Cria detailed_plan.md + ai_docs.md (cached)

# 4. Build sistematicamente
/build
# Implementa fase por fase, testando

# Context usage: 78K/200K (39%) - muito melhor! ✅
```

### Novo Workflow: Bug Fix

**Antes**:
```bash
claude
# 15K tokens carregados (maioria irrelevante para bug)
"Fix login bug"
# Context enche rápido com investigação
```

**Depois**:
```bash
claude

# 1. Prime para debugging
/prime-bug  # Carrega testing/debugging context (~5K)

# 2. Scout o problema
/scout "Find login flow and error handling"

# 3. Investiga e fixa
# [trabalho...]

# 4. Se context encher (170K+)
/clear
/load-bundle .agents/context-bundles/[current].md
# 70% do estado recuperado! ✅
# Continue trabalho
```

## 🔍 Troubleshooting da Migração

### Problema: Commands não aparecem

**Causa**: Frontmatter inválido ou ausente.

**Fix**:
```bash
# Verificar frontmatter
head -5 .claude/commands/scout.md

# Deve ter:
# ---
# description: ...
# ---
```

### Problema: Hooks não executam

**Causa**: Não executável ou settings.json incorreto.

**Fix**:
```bash
# Tornar executável
chmod +x .claude/hooks/*.sh

# Verificar settings
cat .claude/settings.json | grep -A 10 "hooks"
```

### Problema: Bundles não criam

**Causa**: Diretório não existe.

**Fix**:
```bash
mkdir -p .agents/context-bundles
ls -la .agents/context-bundles/
```

### Problema: Context ainda alto após migração

**Causa**: CLAUDE.md ainda muito grande.

**Fix**:
```bash
# Verificar tamanho
wc -w CLAUDE.md
# Deve ser ~300-400 palavras (≈ 1K tokens)

# Se maior: refatore!
# Mova conteúdo detalhado para /prime-* commands
```

### Problema: Sub-agents não encontrados

**Causa**: Agent YAML com erro ou não instalado.

**Fix**:
```bash
# Verificar agents
ls .claude/agents/

# Validar YAML
cat .claude/agents/scout-search.yaml
# Deve ter frontmatter: ---\nname: ...\nmodel: ...\ntools: ...\n---
```

## 📊 Medindo o Sucesso da Migração

### Métricas para Acompanhar

#### Antes da Migração (Baseline)
```bash
# Iniciar nova sessão
claude

# Fazer task típica
"Implement feature X"

# Ao fim, medir:
/context  # Ex: 165K/200K (82.5%)
```

#### Depois da Migração (Comparação)
```bash
# Iniciar nova sessão
claude

# Mesma task, novo workflow
/prime-feature
/scout-plan-build "Implement feature X"

# Ao fim, medir:
/context  # Meta: < 80K/200K (< 40%)
```

### Targets de Sucesso

| Métrica | Antes | Meta Depois | Excelente |
|---------|-------|-------------|-----------|
| Context após 1 feature | 150K+ (75%) | < 80K (40%) | < 60K (30%) |
| Upfront CLAUDE.md | 15K tokens | < 2K tokens | < 1K tokens |
| State recovery | 0% | 70% | 80%+ |
| Audit trail | Nenhum | Completo | Completo |
| Workflow structure | Ad-hoc | Scout-Plan-Build | Custom pipelines |

## 🎯 Próximos Passos Pós-Migração

### 1. Customize para Seu Projeto

```bash
# Criar primes específicos do domínio
nano .claude/commands/prime-[seu-domínio].md

# Criar agents específicos
nano .claude/agents/[seu-agent].yaml

# Criar workflows compostos
nano .claude/commands/[seu-workflow].md
```

### 2. Treine o Time

- Compartilhe cheatsheet: `estrutura-padrao/CHEATSHEET.md`
- Demo dos novos workflows
- Explique context management strategy

### 3. Monitore e Ajuste

- Acompanhe context usage nas primeiras semanas
- Ajuste tamanho dos primes se necessário
- Refine agents baseado em feedback

### 4. Evolua

- Adicione novos commands conforme padrões emergem
- Crie agents especializados para tasks repetitivas
- Share bundles de sessões complexas como docs

## 📚 Recursos Adicionais

- **README completo**: `estrutura-padrao/README.md`
- **Cheatsheet**: `estrutura-padrao/CHEATSHEET.md`
- **Hook docs**: `estrutura-padrao/hooks/README.md`
- **Validation**: `estrutura-padrao/validate.sh`

## 🤝 Rollback (Se Necessário)

Se algo der errado, você pode voltar ao estado anterior:

```bash
# Restaurar configuração antiga
rm -rf .claude
mv .claude.backup .claude

# Restaurar CLAUDE.md antigo
mv CLAUDE.md.backup CLAUDE.md

# Limpar estrutura nova
rm -rf .agents
```

---

**Boa migração! 🚀**

Para dúvidas ou problemas, consulte o README completo ou execute `validate.sh` para diagnóstico.
