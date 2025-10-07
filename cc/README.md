# 🎯 Sistema Especialista em Configuração Claude Code

> **Repositório completo de conhecimento para dominar configurações avançadas do Claude Code**

Este repositório consolida documentação oficial, best practices e estratégias avançadas para configurar e utilizar o Claude Code em projetos profissionais, com foco especial em **workflows compostos**, **sub-agentes**, **context engineering** e **automação avançada**.

---

## 📚 Índice de Conteúdo

### 🏗️ Fundamentos

- **[01. Fundamentos do Claude Code](docs/01-fundamentos-claude-code.md)**
  - Arquitetura e conceitos base
  - Context window e token management
  - Filosofia in-the-loop vs out-of-loop
  - Visão geral das capacidades

### 🔧 Customização e Composição

- **[02. Slash Commands e Composição de Prompts](docs/02-slash-commands-composicao.md)**
  - Criação de custom commands
  - **Composição de prompts** (feature exclusiva)
  - Chaining de commands
  - SlashCommand tool e argumentos
  - Exemplos práticos

- **[03. Sub-agentes e Task Tool](docs/03-subagentes-task-tool.md)**
  - Configuração de sub-agentes especializados
  - Task tool e execução paralela
  - Delegação e isolamento de contexto
  - Padrões de especialização

- **[04. Hooks e Customização](docs/04-hooks-customizacao.md)**
  - Tipos de hooks (PreToolUse, PostToolUse, etc)
  - Automação de workflows
  - Integração com ferramentas externas
  - Security considerations

- **[06. Output Styles](docs/06-output-styles.md)**
  - Criação de estilos personalizados
  - Diferenças vs CLAUDE.md
  - Casos de uso especializados

### 🧠 Context Engineering

- **[05. Context Engineering e R&D Framework](docs/05-context-engineering.md)**
  - **Reduce and Delegate (R&D Framework)**
  - Autocompact e buffer management
  - Estratégias de compaction
  - Long-horizon task techniques
  - Elite context management

### 🚀 Workflows Avançados

- **[07. Workflows Avançados (Scout-Plan-Build)](docs/07-workflows-avancados.md)** ⭐
  - **Scout-Plan-Build pattern** (estratégia central)
  - Delegation workflows
  - Multi-agent orchestration
  - Out-of-loop agent systems (ADWs)
  - Agentic prompt engineering

### ⚙️ Configuração e Integração

- **[08. Configuração Settings.json](docs/08-configuracao-settings.md)**
  - Hierarquia completa de configuração
  - Managed/User/Project/Local settings
  - Permissions e security
  - Exemplos de configuração

- **[09. MCP Servers e Custom Tools](docs/09-mcp-servers.md)**
  - Integração com Model Context Protocol
  - Configuração de MCP servers
  - Custom tools com Agent SDK
  - Exemplos práticos de integração

### 📖 Referências Práticas

- **[10. Exemplos Práticos](docs/10-exemplos-praticos.md)**
  - Templates prontos para uso
  - Scout-Plan-Build implementations
  - Workflows completos comentados
  - Real-world use cases

- **[11. Best Practices Consolidadas](docs/11-best-practices.md)**
  - Best practices oficiais Anthropic
  - Context management strategies
  - Workflow optimization
  - Team collaboration patterns

- **[12. Context Priming com /prime](docs/12-context-priming-prime.md)** ⭐
  - **Slash command /prime** explicado
  - Context Priming vs CLAUDE.md estático
  - Múltiplos primes especializados
  - Templates prontos (prime-bug, prime-feature)
  - +20K tokens freed imediatamente

- **[13. As 12 Técnicas de Context Engineering](docs/13-12-tecnicas-context-engineering.md)** ⭐
  - **R&D Framework** completo (Reduce & Delegate)
  - 4 níveis: Beginner, Intermediate, Advanced, Agentic
  - B2: Avoid MCP Servers (+20K tokens)
  - B3: Context Prime (+20K tokens)
  - I2: Sub-Agents Properly
  - ADV2: Context Bundles
  - AGE2: Multi-Agent Delegation
  - Métricas: +43K tokens freed (21.5%!)

---

## 🎨 Templates Prontos para Uso

### `/templates/commands` - Slash Commands
- Scout workflow command
- Plan with docs command
- Build command
- Scout-Plan-Build complete workflow
- **Prime commands** ⭐
  - `/prime` - General understanding
  - `/prime-bug` - Bug investigation
  - `/prime-feature` - Feature development

### `/templates/agents` - Sub-agentes
- Code reviewer agent
- Debugger agent
- Data scientist agent
- Security auditor agent
- Documentation writer agent

### `/templates/hooks` - Hook Scripts
- Pre-commit formatter hook
- Post-tool logger hook
- User prompt enhancer hook
- Security validation hook

### `/templates/output-styles` - Output Styles
- Learning mode style
- Pair programming style
- Code review style
- Documentation style

### `/templates/workflows` - Workflows Completos
- Scout-Plan-Build implementation
- Multi-agent delegation example
- Out-of-loop ADW setup
- CI/CD integration example

---

## 📎 Referências

### Documentação Base

- **[fontes.md](fontes.md)** - Agent SDK Python API Reference completa
- **[transcricao.md](transcricao.md)** - Transcrição do devlog original com estratégias avançadas
- **[referencias/urls-oficiais.md](referencias/urls-oficiais.md)** - Links para documentação oficial
- **[referencias/glossario.md](referencias/glossario.md)** - Glossário de termos técnicos

### Fontes Oficiais

- [Claude Code Official Docs](https://docs.claude.com/en/docs/claude-code)
- [Claude Agent SDK](https://docs.claude.com/en/api/agent-sdk)
- [Anthropic Engineering Blog](https://www.anthropic.com/engineering)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

---

## 🎯 Destaques

### ⭐ Scout-Plan-Build Pattern

Workflow em 3 etapas que separa:
1. **Scout**: Busca de arquivos relevantes (delegado a sub-agentes rápidos)
2. **Plan**: Planejamento detalhado com contexto limpo
3. **Build**: Implementação focada

→ Veja implementação completa em [07-workflows-avancados.md](docs/07-workflows-avancados.md)

### ⭐ Composição de Prompts

Feature exclusiva do Claude Code 2.0 que permite:
- Chamar slash commands dentro de outros slash commands
- Criar workflows complexos modularizados
- Reutilizar primitivas de prompt
- Escalar compute de forma inteligente

→ Veja detalhes em [02-slash-commands-composicao.md](docs/02-slash-commands-composicao.md)

### ⭐ R&D Framework (Reduce & Delegate)

Estratégia de elite context engineering:
- **Reduce**: Minimizar tokens no context window
- **Delegate**: Offload work para sub-agentes com contexto isolado
- Preservar context window do agente principal

→ Veja implementação em [05-context-engineering.md](docs/05-context-engineering.md)

### ⭐ Out-of-Loop Agent Systems (ADWs)

Dedicated AI Developer Workflows:
- Agentes que rodam em background
- Sistema que constrói o sistema
- Asymmetric returns no tempo de engenharia

→ Veja conceitos em [07-workflows-avancados.md](docs/07-workflows-avancados.md)

---

## 🚀 Quick Start

### 1. Entenda os Fundamentos
```bash
# Leia primeiro
docs/01-fundamentos-claude-code.md
```

### 2. Configure seu Ambiente
```bash
# Setup básico
docs/08-configuracao-settings.md

# Adicione MCP servers
docs/09-mcp-servers.md
```

### 3. Implemente Scout-Plan-Build
```bash
# Copie templates
cp -r templates/commands/.claude/commands/
cp -r templates/agents/.claude/agents/

# Leia implementação
docs/07-workflows-avancados.md
```

### 4. Otimize Context
```bash
# Configure autocompact
docs/05-context-engineering.md

# Implemente R&D framework
docs/03-subagentes-task-tool.md
```

---

## 📊 Estrutura do Repositório

```
cc/
├── README.md (este arquivo)
├── transcricao.md (fonte original)
├── fontes.md (API reference)
│
├── docs/
│   ├── 01-fundamentos-claude-code.md
│   ├── 02-slash-commands-composicao.md
│   ├── 03-subagentes-task-tool.md
│   ├── 04-hooks-customizacao.md
│   ├── 05-context-engineering.md
│   ├── 06-output-styles.md
│   ├── 07-workflows-avancados.md ⭐
│   ├── 08-configuracao-settings.md
│   ├── 09-mcp-servers.md
│   ├── 10-exemplos-praticos.md
│   └── 11-best-practices.md
│
├── templates/
│   ├── commands/ (slash commands prontos)
│   ├── agents/ (sub-agentes prontos)
│   ├── hooks/ (hook scripts prontos)
│   ├── output-styles/ (estilos prontos)
│   └── workflows/ (workflows completos)
│
└── referencias/
    ├── urls-oficiais.md
    └── glossario.md
```

---

## 🎓 Como Usar Este Repositório

### Para Iniciantes
1. Leia [01-fundamentos-claude-code.md](docs/01-fundamentos-claude-code.md)
2. Configure usando [08-configuracao-settings.md](docs/08-configuracao-settings.md)
3. Teste os [exemplos práticos](docs/10-exemplos-praticos.md)

### Para Intermediários
1. Implemente [sub-agentes](docs/03-subagentes-task-tool.md)
2. Configure [hooks](docs/04-hooks-customizacao.md)
3. Optimize [context management](docs/05-context-engineering.md)

### Para Avançados
1. Domine o [Scout-Plan-Build](docs/07-workflows-avancados.md)
2. Implemente [composição de prompts](docs/02-slash-commands-composicao.md)
3. Crie [ADWs out-of-loop](docs/07-workflows-avancados.md#out-of-loop-systems)

---

## 🤝 Contribuindo

Este é um repositório de conhecimento vivo. Contribuições são bem-vindas:

- 📝 Melhorias na documentação
- 🎨 Novos templates
- 💡 Exemplos práticos
- 🔗 Links úteis
- 🐛 Correções

---

## 📜 Licença

Este repositório consolida documentação oficial pública da Anthropic e conhecimento da comunidade.

---

## 🙏 Créditos

- **Documentação oficial**: [Anthropic Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- **Inspiração**: Indie Devdan - Agentic Coding Devlog (transcrito em `transcricao.md`)
- **Comunidade**: Claude Code community e contributors

---

**💡 Dica**: Marque este README com ⭐ e explore os documentos em ordem sequencial para melhor compreensão!
