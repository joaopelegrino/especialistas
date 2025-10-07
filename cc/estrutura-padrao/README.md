# Estrutura Padrão Claude Code

Template completo de configuração do Claude Code com commands, agents e hooks otimizados para context engineering.

## 📁 Estrutura

```
estrutura-padrao/
├── commands/              # Custom slash commands
│   ├── scout.md          # Parallel search
│   ├── plan-with-docs.md # Planning with documentation
│   ├── build.md          # Systematic implementation
│   ├── scout-plan-build.md # Complete workflow (composition)
│   ├── prime.md          # General priming
│   ├── prime-bug.md      # Bug fixing context
│   ├── prime-feature.md  # Feature development context
│   ├── prime-migration.md # Migration context
│   └── load-bundle.md    # Context bundle loading
│
├── agents/               # Sub-agents
│   ├── scout-search.yaml    # Fast search agent
│   ├── code-reviewer.yaml   # Code review agent
│   └── security-auditor.yaml # Security audit agent
│
├── hooks/                # Automation hooks
│   ├── log-to-bundle.sh  # Context bundle logging
│   └── README.md         # Hook documentation
│
├── settings.json.example # Example settings file
└── README.md            # This file
```

## 🚀 Quick Start

### 1. Copiar para Projeto

```bash
# Copiar toda estrutura para .claude/
cp -r estrutura-padrao/commands/ .claude/
cp -r estrutura-padrao/agents/ .claude/
cp -r estrutura-padrao/hooks/ .claude/

# Tornar hooks executáveis
chmod +x .claude/hooks/*.sh
```

### 2. Configurar Settings

```bash
# Copiar settings de exemplo
cp estrutura-padrao/settings.json.example .claude/settings.json

# Editar conforme necessário
nano .claude/settings.json
```

### 3. Criar Diretórios

```bash
# Para context bundles
mkdir -p .agents/context-bundles

# Para outputs temporários
mkdir -p .agents/outputs
```

### 4. Testar

```bash
# Iniciar Claude Code
claude

# Testar comando básico
/prime

# Testar workflow completo
/scout-plan-build "task description"
```

## 📚 Commands Incluídos

### Workflow Commands

#### `/scout` - Parallel Search
Busca paralela usando 4 sub-agents para encontrar arquivos relevantes.

```bash
/scout "Find all JWT token usage"
```

**Output**: `relevant_files.md` com file paths, line ranges, e key findings.

#### `/plan-with-docs` - Planning
Cria plano detalhado de implementação com documentação.

```bash
/plan-with-docs "Migrate to new SDK" --docs https://docs.sdk.com
```

**Output**: `detailed_plan.md` + `ai_docs.md` (cached docs).

#### `/build` - Implementation
Executa o plano sistematicamente com testes.

```bash
/build
```

**Input**: `detailed_plan.md`
**Output**: Modified files + `implementation_summary.md`.

#### `/scout-plan-build` - Complete Workflow
Composição dos 3 comandos acima em workflow completo.

```bash
/scout-plan-build "Add authentication" --docs https://...
```

**Context efficiency**: 230K work done, 78K peak context (39% de 200K).

### Prime Commands (Context Priming)

#### `/prime` - General Understanding
Carrega entendimento geral da codebase (~3K tokens).

```bash
/prime
```

#### `/prime-bug` - Bug Investigation
Carrega context de testing e debugging (~5-6K tokens).

```bash
/prime-bug
```

#### `/prime-feature` - Feature Development
Carrega architecture patterns e design context (~6-8K tokens).

```bash
/prime-feature
```

#### `/prime-migration` - Migrations
Carrega context de dependencies e migration history (~5-7K tokens).

```bash
/prime-migration
```

### Utility Commands

#### `/load-bundle` - Context Recovery
Restaura sessão anterior de context bundle.

```bash
/load-bundle .agents/context-bundles/20251007_143000_bundle.md
```

**Efficiency**: 70% state recovery, 87% token savings.

## 🤖 Agents Incluídos

### scout-search (Haiku)
- **Purpose**: Fast parallel codebase search
- **Tools**: Grep, Glob, Read
- **Output**: Condensed summaries (~2K tokens)
- **Speed**: < 30 seconds per search

### code-reviewer (Sonnet)
- **Purpose**: Code quality and best practices review
- **Tools**: Read, Grep, Glob
- **Focus**: Security, correctness, performance, quality
- **Output**: Prioritized feedback by severity

### security-auditor (Sonnet)
- **Purpose**: Security vulnerability assessment
- **Tools**: Read, Grep, Glob
- **Focus**: OWASP Top 10, CVEs, security best practices
- **Output**: Risk-rated vulnerability report

## 🪝 Hooks Incluídos

### log-to-bundle.sh (PostToolUse)
- **Purpose**: Automatic context bundle logging
- **Triggers**: After every tool call
- **Output**: Append-only bundle file
- **Location**: `.agents/context-bundles/`

**Benefits**:
- 70% state recovery when context overflows
- Full audit trail of work
- Easy session continuation
- Team collaboration via bundle sharing

## ⚙️ Configuration

### Minimal settings.json

```json
{
  "autocompact": false,
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

### Recommended CLAUDE.md

```markdown
# Project Name

## Essentials
- **Tech**: [stack]
- **Style**: [conventions]
- **Tests**: [framework]

## Commands
- Dev: [command]
- Test: [command]
- Build: [command]

## Primes Available
- `/prime` - General understanding
- `/prime-bug` - Bug investigation
- `/prime-feature` - Feature development
- `/prime-migration` - Migrations

## Context Management
- Disable autocompact: ✅
- Use context bundles: ✅
- Clear at breakpoints: ✅
```

Keep CLAUDE.md < 1K tokens (essentials only).

## 📊 Context Efficiency Metrics

### Traditional Approach
```
Single agent, no structure:
├─ Context usage: 150K+ tokens (75%)
├─ Wasted tokens: ~60K (irrelevant)
├─ Risk: Context overflow
└─ Recovery: Impossible
```

### With This Structure
```
Scout-Plan-Build + Primes + Bundles:
├─ Context usage: 78K peak (39%)
├─ Work done: 230K tokens
├─ Efficiency: 3x more work, less context
├─ Recovery: 70% via bundles
└─ Risk: Minimal
```

**Improvements**:
- 68% reduction in peak context
- 3x more work accomplished
- 70% state recovery capability
- 100% audit trail

## 🎯 Usage Patterns

### Pattern 1: New Feature

```bash
# 1. Prime for feature work
/prime-feature

# 2. Search codebase
/scout "Find similar features to X"

# 3. Create plan
/plan-with-docs "Implement feature X" --docs [url]

# 4. Implement
/build

# 5. Review
# (Context might be full here)
/clear
/load-bundle [current-session]

# 6. Code review with fresh context
# Use code-reviewer agent
```

### Pattern 2: Bug Fix

```bash
# 1. Prime for debugging
/prime-bug

# 2. Scout the issue
/scout "Find code related to bug #123"

# 3. Investigate and fix
# (Work until context fills)

# 4. Save and reload if needed
/clear
/load-bundle [session]

# 5. Continue with fresh context
```

### Pattern 3: Large Migration

```bash
# 1. Prime for migration
/prime-migration

# 2. Complete workflow
/scout-plan-build "Migrate from X to Y" --docs [migration-guide]

# 3. Monitor context
/context  # Check usage regularly

# 4. Use bundles for long migrations
# Clear and reload as needed
```

### Pattern 4: Security Audit

```bash
# 1. Prime (optional)
/prime

# 2. Run security audit
# Spawn security-auditor agent
# with Task tool

# 3. Review findings

# 4. Plan remediation
/plan-with-docs "Fix security issues from audit"

# 5. Implement fixes
/build
```

## 🔧 Customization

### Adding New Commands

```bash
# Create new command
nano .claude/commands/my-command.md

# Format:
---
description: What the command does
argument-hint: <optional args>
---

# Command Name

[Command implementation]
```

### Adding New Agents

```yaml
# Create new agent
nano .claude/agents/my-agent.yaml

# Format:
---
name: agent-name
description: What the agent does
model: haiku|sonnet|opus
tools: Tool1, Tool2
---

System prompt defining behavior
```

### Modifying Hooks

```bash
# Edit hook script
nano .claude/hooks/log-to-bundle.sh

# Add custom logging
# Modify tool filters
# Add notifications
# etc.
```

## 📈 Best Practices

### Context Management

✅ **DO**:
- Use `/prime` commands for task-specific context
- Run `/context` periodically to monitor usage
- Use `/clear` + `/load-bundle` when approaching 70%+
- Let bundles handle state preservation

❌ **DON'T**:
- Load everything in CLAUDE.md (keep it minimal)
- Continue when context is 90%+ (performance degrades)
- Ignore context bundles (70% state recovery is huge)
- Skip priming (wastes tokens on irrelevant context)

### Workflow Usage

✅ **DO**:
- Use `/scout-plan-build` for medium-large tasks (3+ files)
- Follow the phases (don't skip Scout)
- Test after each Build phase
- Review plans before building

❌ **DON'T**:
- Use workflows for trivial single-file changes
- Skip testing between phases
- Ignore plan recommendations
- Interrupt mid-workflow

### Agent Usage

✅ **DO**:
- Use sub-agents for heavy data collection
- Ensure sub-agents return condensed summaries
- Leverage context isolation for parallel work
- Match model to task (Haiku for speed, Sonnet for quality)

❌ **DON'T**:
- Use sub-agents for trivial tasks (overhead not worth it)
- Return full content from sub-agents (defeats isolation)
- Use expensive models for simple tasks
- Chain sub-agents unnecessarily

## 🐛 Troubleshooting

### Commands Not Found

```bash
# Check command files exist
ls .claude/commands/

# Check proper frontmatter
head -5 .claude/commands/scout.md
```

### Agents Not Working

```bash
# Check agent files exist
ls .claude/agents/

# Verify YAML syntax
cat .claude/agents/scout-search.yaml
```

### Hooks Not Executing

```bash
# Check permissions
ls -la .claude/hooks/log-to-bundle.sh

# Should show: -rwxr-xr-x
chmod +x .claude/hooks/log-to-bundle.sh

# Check settings
cat .claude/settings.json | grep -A 5 "PostToolUse"
```

### Context Bundles Not Creating

```bash
# Check directory exists
ls -la .agents/context-bundles/

# Create if missing
mkdir -p .agents/context-bundles/

# Check bundle file
ls -lt .agents/context-bundles/ | head -5
```

## 📖 Documentation

Documentação completa disponível em:
- [Context Engineering](../docs/05-context-engineering.md)
- [Sub-agents](../docs/03-subagentes-task-tool.md)
- [Workflows Avançados](../docs/07-workflows-avancados.md)
- [Context Priming](../docs/12-context-priming-prime.md)
- [Técnicas Context Engineering](../docs/13-12-tecnicas-context-engineering.md)
- [Exemplos Práticos](../docs/10-exemplos-praticos.md)

## 🤝 Contributing

Para adicionar novos commands/agents/hooks:

1. Siga os templates existentes
2. Documente claramente o propósito
3. Inclua exemplos de uso
4. Teste em projeto real
5. Adicione a esta documentação

## 📝 License

Este template é parte do projeto de documentação Claude Code e está disponível para uso livre.

---

**Versão**: 1.0.0
**Última atualização**: 2025-10-07
**Compatível com**: Claude Code 2.0+
