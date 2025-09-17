# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Foco Principal

**Especialista em Diagnóstico e Configuração Claude Code**

Este repositório contém diretrizes, templates e recursos para **diagnosticar e configurar Claude Code em outros projetos**. Minha função é atuar como especialista para otimizar fluxos de trabalho entre você e instâncias do Claude Code.

### ⚠️ Separação de Responsabilidades

**Este repositório (`/home/notebook/workspace/especialistas/claude-code/`):**
- ✅ Diretrizes de trabalho DO especialista Claude Code
- ✅ Templates para aplicar EM outros projetos  
- ✅ Processo de diagnóstico e otimização
- ✅ Recursos reutilizáveis

**Projetos alvo (ex: `/home/notebook/workspace/blog/`):**
- ✅ Configurações específicas DO projeto
- ✅ Setup ambiente específico
- ✅ Comandos específicos da stack
- ✅ URLs e estruturas do projeto

## ⚠️ Diretiva de Planejamento Obrigatória

**IMPORTANTE**: É obrigatório NÃO fazer alterações no repositório alvo sem um prévio planejamento em formato de documento .md que deve ser criado na pasta `/home/notebook/workspace/especialistas/claude-code/`.

### Processo de Planejamento:
1. **Analisar**: Compreender o estado atual do repositório
2. **Planejar**: Criar documento .md detalhado com estratégia
3. **Validar**: Revisar plano antes de implementação  
4. **Executar**: Implementar mudanças seguindo o plano
5. **Documentar**: Atualizar documentação com resultados

## Arquitetura do Projeto

Este repositório contém documentação e templates para implementar sistemas de orquestração multi-agente com Claude Code, focando na localização em português-BR e práticas de segurança defensiva.

### Estrutura de Diretórios Principal
```
./
├── avansado/                   # Guias de implementação avançada
│   ├── 00-indice-navegacao.md  # Índice de navegação com tags semânticas
│   ├── 01-visao-geral-orquestracao.md
│   ├── 02-arquitetura-tecnica.md
│   ├── 03-sistema-hooks.md     # Documentação do sistema de hooks
│   ├── 04-servidor-mcp.md      # Implementação do servidor MCP
│   ├── 05-dashboard-monitoramento.md
│   ├── 06-guia-implementacao.md
│   ├── 07-referencias-recursos.md
│   └── templates-pt-br/        # Templates em português
│       ├── gancho-basico.py    # Template básico de hook
│       ├── servidor-mcp-basico.py
│       └── configuracoes.json
├── setup-inicial-automatico.sh # Script de configuração do ambiente WSL2
└── setup-inicial-wsl.md
```

### Estratégia de Navegação
- Use `avansado/00-indice-navegacao.md` como ponto de entrada para navegação eficiente
- Siga as tags semânticas `[ESSENCIAL]`, `[TEMPLATE]`, `[EXEMPLO]` para localizar conteúdo específico
- Arquivos > 10KB devem ser lidos por seções usando o sistema de tags

## Comandos Comuns

### Configuração e Instalação
```bash
# Run automated WSL2 setup
chmod +x setup-inicial-automatico.sh
./setup-inicial-automatico.sh

# Install Claude Code hooks dependencies
cd .claude/hooks
uv pip install -r requirements.txt
```

### Fluxo de Desenvolvimento
```bash
# Navigate with Yazi file manager
y           # Open Yazi
yy          # Yazi with cd integration

# Git operations
gst         # git status
gco         # git checkout
gcm         # git commit -m

# Start development
vim         # Primary editor
code .      # Open in VSCode
```

### Sistema Multi-Agente
```bash
# Setup orchestrator MCP server
cd orchestrator-mcp
bun install
bun run dev

# Start monitoring dashboard
cd monitoring-dashboard
npm install
npm run dev

# Run hooks system
python .claude/hooks/gancho-basico.py
```

## Diretrizes de Desenvolvimento

### Convenções de Linguagem e Nomenclatura
- **Todo código, comentários e documentação em português-BR**
- **Snake_case**: `funcoes_e_variaveis`
- **PascalCase**: `ClassesEComponentes`
- **Kebab-case**: `nomes-de-arquivos.md`
- **Sem acentos**: `configuracao` (não `configuração`)

### Foco em Segurança
- Este repositório foca apenas em **práticas de segurança defensiva**
- Templates e exemplos são projetados para monitoramento, logging e medidas protetivas
- Todas as implementações de hooks incluem validações de segurança

### Otimização de Performance
- Sistema multi-agente oferece 90.2% de melhoria de performance sobre abordagem single-agent
- Uso de tokens otimizado através de isolamento de contexto
- Sistema de tags semânticas reduz overhead de leitura de arquivos
- **Interactive Workflow Visualization**: Melhoria significativa na compreensão do fluxo de trabalho
  - Redução de confusão sobre processos manuais vs automáticos
  - Visualização clara da arquitetura de documentos
  - Best practices 2025 para LLM workflow diagrams (DAG swimlanes)

## Templates e Recursos

### Templates Prontos para Uso
- `templates-pt-br/gancho-basico.py` - Implementação completa de hook em português
- `templates-pt-br/configuracoes.json` - Template de configuração
- `templates-pt-br/servidor-mcp-basico.py` - Servidor MCP básico
- **NOVO**: `templates-pt-br/claude-md-template.md` - Template base para CLAUDE.md de projetos

### Fases de Implementação
1. **Fase 1** (30 min): Configuração inicial usando `06-guia-implementacao.md`
2. **Fase 2**: Implementação do sistema de hooks
3. **Fase 3**: Deploy do servidor MCP
4. **Fase 4**: Dashboard e monitoramento
   - 4.1: Interactive Workflow Dashboard (DAG Swimlane)
   - 4.2: Real-time Observatory monitoring
   - 4.3: Document flow visualization
   - 4.4: Performance metrics integration

### Como Usar Este Especialista
1. **Analisar** projeto alvo com foco em oportunidades de otimização
2. **Diagnosticar** problemas de fluxo de trabalho
3. **Propor** soluções usando templates deste repositório
4. **Implementar** configurações no projeto alvo
5. **Visualizar** fluxos com Interactive Dashboard (quando disponível)
6. **Documentar** processo para reutilização

### Lições Aprendidas Recentes
- **Workflow Visualization** é fundamental para compreensão de sistemas complexos
- **DAG Swimlane approach** supera diagramas tradicionais para LLM workflows
- **Separação Manual/Automático** reduz significativamente confusão no desenvolvimento
- **Document Flow Integration** essencial para arquiteturas baseadas em documentação
- **Dashboard Consolidation** elimina redundância e melhora rastreabilidade stakeholder
- **System Orchestrator Alignment** crítico para manter consistência entre ferramentas

## Configuração do Ambiente

### Software Necessário
- Node.js 20.0.0+
- Python 3.8+
- Bun 1.0.0+
- Git 2.0+
- Claude Code (versão mais recente)
- Astral uv (gerenciador de pacotes Python)

### Variáveis de Ambiente
```bash
# Create .env file with:
ANTHROPIC_API_KEY=sk-ant-xxxxx
# Optional: OPENAI_API_KEY, GEMINI_API_KEY
```

## Testes e Validação

### Validação da Configuração
```bash
# Run environment diagnostics (if available)
~/config/diagnostico-ambiente.sh

# Verify tool installations
git --version
python3 --version
node --version
bun --version
```

### Teste de Hooks
```bash
# Test basic hook functionality
python .claude/hooks/gancho-basico.py

# Debug mode (create debug flag)
touch .claude/debug
```
- Sempre gere uma nova branch para realizar qualquer proposta aceita e nao se esqueça de atualizar os arquivos de .claude/docs após a implementacao
