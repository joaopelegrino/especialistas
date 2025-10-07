# Glossário - Termos Técnicos Claude Code

## A

**ADW (Dedicated AI Developer Workflow)**
Sistema de agentes que trabalha autonomamente em background. Você define a task e vai AFK (Away From Keyboard) enquanto os agentes executam todo o workflow.

**Agent**
Instância do Claude Code com context window, system prompt, tools e model específicos.

**Agentic Coding**
Paradigma de desenvolvimento onde agentes AI autônomos executam tasks complexas de coding com minimal human intervention.

**Agentic Prompt**
Prompt estruturado e reutilizável que orquestra workflows complexos, pode chamar outros prompts, e gerencia context eficientemente.

**Autocompact**
Feature do Claude Code 2.0 que automatically summarizes conversation quando aproxima do context limit. Recomendado desabilitar para manual compaction.

## B

**Builder Agent**
Terceiro estágio do Scout-Plan-Build que implementa o plan de forma sistemática.

## C

**CLAUDE.md**
Arquivo especial que o Claude Code lê automaticamente para obter project context, conventions, e guidelines.

**ClaudeSDKClient**
Classe Python para manter conversação contínua com Claude, suportando múltiplas exchanges no mesmo context.

**Compaction**
Processo de summarizar conversa longa para liberar context window. Pode ser manual (`/clear`) ou automática (autocompact).

**Composição de Prompts**
Feature exclusiva do Claude Code 2.0: Chamar slash commands dentro de outros slash commands para criar workflows modulares.

**Context Window**
Finite "attention budget" do modelo - quantidade total de tokens que podem estar em memória simultaneamente.

**Context Engineering**
Disciplina de managing the context window efficiently através de técnicas como R&D Framework.

**Context Isolation**
Benefício de sub-agentes: Cada um tem seu próprio context window separado do main agent.

**Core 4**
Os quatro pilares de todo agente: Context, Model, Prompt, Tools.

## D

**Delegation**
Parte do R&D Framework: Offload work para sub-agentes com context isolado.

## E

**Elite Context Engineering**
Advanced context management usando R&D Framework, Scout-Plan-Build, e multi-agent orchestration.

## H

**Hook**
Script que executa em pontos específicos do workflow (PreToolUse, PostToolUse, etc).

**Hierarchical Agents**
Pattern de organização: Main agent coordena manager agents, que coordenam worker agents.

## I

**In-the-Loop**
Modo de trabalho onde você interage diretamente com Claude em tempo real.

## J

**Just-in-Time Context**
Princípio de carregar context apenas quando necessário, não upfront.

## L

**Long-Horizon Task**
Task complexa que requer múltiplas fases e extensive context management.

## M

**MCP (Model Context Protocol)**
Open-source protocol para integrar AI tools com external services e data sources.

**MCP Server**
Serviço que expõe tools/data via MCP protocol.

## O

**Out-of-Loop**
Modo de trabalho onde agentes trabalham autonomously em background enquanto você está AFK.

**Output Style**
Customização que modifica o system prompt do Claude Code para diferentes use cases além de software engineering.

## P

**Parallel Agents**
Múltiplos sub-agentes executando simultaneously (até 10x).

**Permission Mode**
Configuração de como Claude Code pede permissão: `default`, `acceptEdits`, `plan`, `bypassPermissions`.

**Planner Agent**
Segundo estágio do Scout-Plan-Build que cria detailed implementation plan.

## Q

**query()**
Função Python SDK que cria nova session para cada interaction (stateless).

## R

**R&D Framework**
Context engineering strategy: **Reduce** (minimize tokens) + **Delegate** (offload to sub-agents).

**Reduce**
Parte do R&D Framework: Minimizar tokens que entram no context window.

**Relevant Files Pattern**
Output do Scout phase: Markdown file com lista condensada de files relevantes, line ranges, e key findings.

## S

**Scout Agent**
Primeiro estágio do Scout-Plan-Build que busca files relevantes usando parallel sub-agents.

**Scout-Plan-Build Pattern**
Workflow em 3 estágios que separa search (Scout), planning (Plan), e implementation (Build) para maximize context efficiency.

**Sequential Agents**
Pattern onde agents executam um após o outro, cada um dependendo do output do anterior.

**Slash Command**
Prompt reutilizável armazenado como `.md` file que pode ser executado com `/command-name`.

**SlashCommand Tool**
Built-in tool que permite Claude executar slash commands programmatically durante conversas.

**Sub-agent**
Specialized agent instance com seu próprio context window, system prompt, e tool access.

**System Prompt**
Instructions que definem o behavior e role do agent.

## T

**Tactical Agentic Coding**
Advanced paradigm que usa Scout-Plan-Build, composição de prompts, e ADWs para scale engineering output.

**Task Tool**
Built-in tool para spawn sub-agents e executá-los em parallel ou sequential.

**Token**
Unit of text (roughly word/subword) que consome context window.

**Tool**
Function que Claude Code pode executar (Read, Write, Bash, etc).

## V

**Vibe Coding**
Simple back-and-forth prompting com single agent. Good for simple tasks, não escala well.

## W

**Workflow Composition**
Criar complex workflows combinando multiple slash commands e sub-agents.

---

## Acrônimos Comuns

| Acrônimo | Significado |
|----------|-------------|
| ADW | Dedicated AI Developer Workflow |
| AFK | Away From Keyboard |
| CLI | Command Line Interface |
| MCP | Model Context Protocol |
| R&D | Reduce and Delegate |
| SDK | Software Development Kit |
| SPB | Scout-Plan-Build |
| TDD | Test-Driven Development |

---

## Comandos Importantes

| Comando | Descrição |
|---------|-----------|
| `/clear` | Clear conversation history |
| `/context` | Show context window usage |
| `/config` | Open configuration |
| `/help` | Show help |
| `/model` | Select model |
| `/output-style` | Change output style |

---

## Conceitos por Categoria

### Context Management
- Context Window
- Autocompact
- Compaction
- R&D Framework
- Context Isolation
- Just-in-Time Context

### Agent Architecture
- Main Agent
- Sub-agent
- Parallel Agents
- Sequential Agents
- Hierarchical Agents

### Workflows
- Scout-Plan-Build
- Vibe Coding
- Tactical Agentic Coding
- In-the-Loop
- Out-of-Loop (ADW)

### Customization
- Slash Command
- Output Style
- Hook
- CLAUDE.md
- MCP Server

---

**Última atualização**: 2025-10-06

Este glossário é mantido em `/referencias/glossario.md` e será expandido conforme novos termos surgem.
