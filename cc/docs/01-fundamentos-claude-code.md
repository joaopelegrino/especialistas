# 01. Fundamentos do Claude Code

> **Conceitos essenciais, arquitetura e filosofia de uso do Claude Code**

---

## 📋 Índice

1. [O que é Claude Code](#o-que-é-claude-code)
2. [Arquitetura e Conceitos Base](#arquitetura-e-conceitos-base)
3. [Context Window e Token Management](#context-window-e-token-management)
4. [Filosofia de Uso](#filosofia-de-uso)
5. [Capacidades Principais](#capacidades-principais)
6. [Limitações e Considerações](#limitações-e-considerações)

---

## O que é Claude Code

### Definição

**Claude Code** é um assistente de coding agentic desenvolvido pela Anthropic que opera via CLI (Command Line Interface), permitindo que engenheiros automatizem tarefas complexas de desenvolvimento de software enquanto mantêm controle e qualidade.

### Diferencial Principal

> "Claude Code is intentionally low-level and unopinionated, providing close to raw model access without forcing specific workflows."

Ao contrário de outras ferramentas de AI coding:
- ✅ Acesso próximo ao modelo "cru"
- ✅ Não força workflows específicos
- ✅ Altamente customizável
- ✅ Arquitetura agentic real (não apenas autocomplete)
- ✅ Capacidade de composição e delegação avançada

### Powered by Claude 4.5 Sonnet

Claude Code é powered pelo **Claude 4.5 Sonnet**, um modelo:
- Step change improvement para agentic tool use
- Treinado especificamente para agentic coding
- Alta adherence a prompts complexos
- Excelente reasoning em contextos longos

---

## Arquitetura e Conceitos Base

### Modelo Agentic

Claude Code não é um simples autocomplete. É um **agente autônomo** que:

```
┌─────────────────────────────────────────┐
│         Claude 4.5 Sonnet Model         │
│    (Trained for Agentic Tool Use)       │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         Claude Code CLI/SDK             │
│  • Tool Execution Engine                │
│  • Context Management                   │
│  • Permission System                    │
│  • Hook System                          │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│            Built-in Tools               │
│  Read, Write, Edit, Bash, Grep, Glob    │
│  Task (sub-agents), WebFetch, etc.      │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│           MCP Integration               │
│    (Model Context Protocol)             │
│  • Custom Tools                         │
│  • External Services                    │
│  • Data Sources                         │
└─────────────────────────────────────────┘
```

### Core Components

#### 1. **Agent (Main)**
- Conversa principal
- Context window dedicado
- Orquestra todo o workflow

#### 2. **Sub-agents**
- Agentes especializados
- Context isolado
- Executados via Task tool
- Podem rodar em paralelo (até 10x)

#### 3. **Tools**
- Built-in: Read, Write, Edit, Bash, Grep, Glob, Task, etc.
- MCP tools: Integração via Model Context Protocol
- Custom tools: Criados via Agent SDK

#### 4. **Context System**
- Context window limitado (finite resource)
- Autocompact feature (summarization)
- Hierarchical memory (CLAUDE.md files)
- Progressive context discovery

#### 5. **Configuration System**
- Hierarquia de settings (managed/user/project/local)
- Permissions granulares
- Hook system para automação
- Output styles para customização

---

## Context Window e Token Management

### Context como Recurso Finito

> "Context is a finite resource - the 'attention budget' of large language models."

```
┌─────────────────────────────────────────────┐
│      Context Window (Ex: 200K tokens)       │
├─────────────────────────────────────────────┤
│                                             │
│  System Prompt                    ~5K       │
│  CLAUDE.md files                  ~2K       │
│  Built-in tools definitions       ~3K       │
│  Conversation history             VARIABLE  │
│  File contents                    VARIABLE  │
│  Tool results                     VARIABLE  │
│                                             │
│  ─────────────────────────────────────────  │
│  Total available                  ~190K     │
│                                             │
└─────────────────────────────────────────────┘
```

### Problema: Context Overflow

Conforme a conversa progride:
- ✅ Mensagens do usuário
- ✅ Respostas do Claude
- ✅ Tool calls e resultados
- ✅ Arquivos lidos
- ✅ Outputs de comandos

**Resultado**: Context window enche rapidamente!

### Solução 1: Autocompact

Claude Code 2.0 introduziu o **autocompact buffer**:

```json
{
  "autocompact": true  // Default em Claude Code 2.0
}
```

**Como funciona**:
1. Detecta aproximação do limite
2. Analisa conversa para identificar informações críticas
3. Cria summary conciso
4. Substitui mensagens antigas pelo summary
5. Continua seamlessly

**Problema do Autocompact**:
- ⚠️ Consome ~22% do context window
- ⚠️ Pode compactar no momento errado
- ⚠️ Reduz context disponível

**Recomendação**:
```json
{
  "autocompact": false  // Desligar e compactar manualmente
}
```

### Solução 2: R&D Framework

**R&D = Reduce + Delegate**

> "There are only two ways to manage your context window: Reduce and Delegate"

#### Reduce
- Minimize tokens que entram no context
- Read apenas o necessário
- Summaries em vez de full outputs
- Clear conversation em breakpoints

#### Delegate
- Offload work para sub-agentes
- Sub-agentes têm context window isolado
- Retornam apenas summaries condensados
- Preserve context do agente principal

→ **Detalhes completos**: [05-context-engineering.md](05-context-engineering.md)

---

## Filosofia de Uso

### In-the-Loop vs Out-of-Loop

#### **In-the-Loop Coding**

Você interage diretamente com o Claude:

```
You ─────┐
         │
         ▼
    ┌─────────┐
    │ Claude  │ ◄──── Real-time interaction
    └─────────┘
         │
         ▼
      Code
```

**Características**:
- ✅ Feedback imediato
- ✅ Controle fino
- ✅ Aprendizado contínuo
- ⚠️ Requer sua presença
- ⚠️ Limita paralelização

**Quando usar**: Exploração, debugging interativo, pair programming

#### **Out-of-Loop Coding (ADWs)**

Claude trabalha autonomamente em background:

```
You ──┐
      │ (Define task & go AFK)
      ▼
 ┌─────────────────┐
 │ Agent Device    │
 │  ┌───────────┐  │
 │  │  Agent 1  │  │
 │  │  Agent 2  │  │ ◄──── Autonomous work
 │  │  Agent 3  │  │
 │  └───────────┘  │
 └─────────────────┘
      │
      ▼
   Results
(git push, notification, etc)
```

**Características**:
- ✅ Trabalho assíncrono
- ✅ Paralelização máxima
- ✅ Asymmetric returns no tempo
- ⚠️ Requer setup inicial
- ⚠️ Menos controle fino

**Quando usar**: Tasks bem definidas, proof of concepts, migrations em massa

→ **Detalhes**: [07-workflows-avancados.md](07-workflows-avancados.md#out-of-loop-systems)

### Vibe Coding vs Tactical Agentic Coding

#### Vibe Coding
```
> "Can you add dark mode?"
> "Actually, make it toggleable"
> "And add keyboard shortcuts"
```
- ✅ Rápido para tasks simples
- ⚠️ Consume muito context
- ⚠️ Não escala bem
- ⚠️ Requer sua presença contínua

#### Tactical Agentic Coding
```
> /scout-plan-build "Migrate to new SDK"
   ↓
   [4 sub-agents search in parallel]
   [Planner cria migration plan]
   [Builder implementa systematically]
   [Tester valida changes]
```
- ✅ Escala para tasks complexas
- ✅ Gerenciamento inteligente de context
- ✅ Reusable workflows
- ✅ Sistema que constrói o sistema

→ **Filosofia completa**: Transcrição original em [../transcricao.md](../transcricao.md)

---

## Capacidades Principais

### 1. Tool Use Avançado

Claude Code tem acesso a tools poderosas:

| Tool | Descrição | Uso Principal |
|------|-----------|---------------|
| `Read` | Ler arquivos (texto, imagens, PDFs) | Análise de código |
| `Write` | Criar/sobrescrever arquivos | Geração de código |
| `Edit` | Substituições exatas | Refactoring preciso |
| `Bash` | Executar comandos shell | Build, test, git |
| `Grep` | Busca com regex (ripgrep) | Encontrar código |
| `Glob` | Pattern matching de arquivos | Descobrir estrutura |
| `Task` | Executar sub-agentes | Delegação |
| `WebFetch` | Buscar URLs | Documentação |
| `WebSearch` | Pesquisar na web | Pesquisa contextual |

### 2. Sub-agent Delegation

Criar agentes especializados:

```yaml
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: Read, Grep, Glob
model: sonnet
---

You are an expert code reviewer...
```

### 3. Custom Slash Commands

Criar prompts reutilizáveis:

```markdown
---
description: Create a comprehensive test suite
allowed-tools: Write, Bash(pytest:*)
---

Create unit tests for $ARGUMENTS
Ensure 80%+ coverage
Run tests and fix any failures
```

### 4. Hook System

Automatizar workflows:

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

### 5. MCP Integration

Conectar a serviços externos:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {"GITHUB_TOKEN": "..."}
    }
  }
}
```

---

## Limitações e Considerações

### 1. Context Window é Finito

**Problema**:
- Tasks complexas podem estourar context
- Autocompact reduz espaço disponível

**Solução**:
- R&D Framework (Reduce + Delegate)
- Manual compaction em breakpoints
- Scout-Plan-Build pattern

### 2. Autocompact pode Atrapalhar

**Problema**:
- Compacta em momentos indesejados
- Consome 22% do context
- Pode perder contexto importante

**Solução**:
```json
{"autocompact": false}
```

### 3. Single Agent Limitations

**Problema**:
- Um único agente não escala para tasks muito grandes
- Context se polui com details irrelevantes

**Solução**:
- Usar sub-agentes para delegação
- Scout-Plan-Build workflow
- Out-of-loop ADW systems

### 4. Tool Permissions

**Problema**:
- Acesso irrestrito pode ser perigoso
- Need for safety guardrails

**Solução**:
```json
{
  "permissions": {
    "allowedTools": ["Read", "Grep"],
    "deny": ["Read(.env)", "Bash(rm -rf *)"]
  }
}
```

### 5. Learning Curve

**Problema**:
- Muitas features avançadas
- Requer understanding de concepts

**Solução**:
- Start simple (in-the-loop)
- Gradually adopt advanced patterns
- Study documentation and examples

---

## Core 4: Os Pilares de Todo Agente

> "With every agent you spin up, you have to manage the core four: Context, Model, Prompt, and Tools."

```
┌─────────────────────────────────────────┐
│              AGENTE                     │
├─────────────────────────────────────────┤
│                                         │
│  1. CONTEXT                             │
│     ├─ Context window size              │
│     ├─ Current content                  │
│     └─ Management strategy              │
│                                         │
│  2. MODEL                               │
│     ├─ Claude 4.5 Sonnet                │
│     ├─ Haiku (fast/cheap)               │
│     └─ Opus (maximum capability)        │
│                                         │
│  3. PROMPT                              │
│     ├─ System prompt                    │
│     ├─ CLAUDE.md context                │
│     └─ Custom instructions              │
│                                         │
│  4. TOOLS                               │
│     ├─ Allowed tools                    │
│     ├─ MCP servers                      │
│     └─ Custom tools                     │
│                                         │
└─────────────────────────────────────────┘
```

**Ação**:
Para cada agente que você cria, pergunte-se:
- ✅ Qual context ele precisa?
- ✅ Qual model é apropriado?
- ✅ Qual prompt/system prompt?
- ✅ Quais tools ele precisa?

---

## Princípio Fundamental

> "Your engineering output has a direct causal link to your ability to control, build, and use agents."

### Implicações

1. **Invest in Agent Infrastructure**
   - Prompts reutilizáveis
   - Sub-agentes especializados
   - Workflows automatizados
   - Templates e primitives

2. **Build the System that Builds the System**
   - Não code manually repetitive tasks
   - Create agentic layer around codebase
   - Let agents do the building

3. **Scale Your Compute**
   - Não fique preso a single agent
   - Use parallel sub-agents
   - Out-of-loop quando possível
   - Asymmetric returns

---

## Próximos Passos

Agora que você entende os fundamentos, explore:

1. **[02. Slash Commands e Composição](02-slash-commands-composicao.md)**
   - Feature exclusiva do Claude Code 2.0
   - Compose prompts para workflows complexos

2. **[03. Sub-agentes e Task Tool](03-subagentes-task-tool.md)**
   - Delegação eficiente
   - Context isolation
   - Parallel execution

3. **[05. Context Engineering](05-context-engineering.md)**
   - R&D Framework detalhado
   - Elite context management

4. **[07. Workflows Avançados](07-workflows-avancados.md)**
   - Scout-Plan-Build pattern
   - Out-of-loop ADWs
   - Multi-agent orchestration

---

## Referências

- [Claude Code Official Docs](https://docs.claude.com/en/docs/claude-code)
- [Agent SDK Reference](../fontes.md)
- [Best Practices Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

---

**Próximo**: [02. Slash Commands e Composição →](02-slash-commands-composicao.md)
