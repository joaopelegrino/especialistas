<-SESSÃO DE RESPONSABILIDADE DO USUÁRIO - APENAS PARA LEITURA->

Realize a <tarefa> seguindo as <praticas>.

<tarefa>

Otimize o planejamento com o foco baseado em /commands serem usado como gatilho
de fluxos comuns baseado na criacao/leitura/ataulizacao de arquivos chave sempre
se preocupando com a capacidade de fluxo de informações relevantes entre etapas
(llm friendly). Busque por referencias na web caso necessário.

Arquivos chave: 
Guia de implementacao - ROADMAP_MASTER.md
Documentacao interna - /docs 

Ideias de /commands 

diagnostico-aprofundado.md -> Foco em realizar estudo aprofundando do codigo
legado, contrastar com ROADMAP_MASTER.md e /docs para alinhamento e atualizacao
geral antes de iniciar qualquer implementacao.

planejamento-roadmap-expandido.md -> Gerar roadmaps explicativos com
direcionamentos detalhados de execucao das tarefas (detalahmento pensando que as
tarefas poderiam ser executadas por qualquer desenvoldor junior que estaria
entrando no projeto agora), com preocupacao extrema de gerar matrix de
dependicias de contextualizacao para linkar, citar as
documentacoes internas (/docs) relevantes para contextualizacao. Aqui deve haver
a preocupacao se ha documentacao necessária para fundamentar a execucao da
tarefa, se nao houver é necessário pesquisar nas fontes oficiais das
tecnologiuas utilizadas para criacao/atualiozacao dos documentos. Descricao
explicita de fluxos de testes e verficacoes de logs e UIs atraves da utilizacao
de mcps de browser/banco de dados para validacao de todas as etapas. Instrucoes
de entrega organizada dos entregáveis.

executar-roadmap-expandido.md -> foco em executar o roadmap expandido entregando
as funcionalidades, demonstrativos necessarios (logs/screenshots))e entregar
um relatorio organizado em pasta caso necessário (llm friendly) com todos os entregáveis e qualidade do
roadmap-expandido fornecido, dando o feedback das diretrizes fornecdas bem como
da necessidade ou nao de busca por documentacoes externas (web) para a entrega.
Diretrizes para atualizacao/criacao de docs pós implementacao.

validacao-entrega.md -> Validação da qualidade de entrega verificando se nao
houve quebra de nenhum tipo. Atualizar o ROADMAP-MASTER.md

</tarefa>


<-SESSÃO DE RESPONSABILIDADE DO USUÁRIO - APENAS PARA LEITURA->


<praticas>

## Foco Principal

**Especialista em Diagnóstico e Configuração para LLMs de Desenvolvimento**

Este repositório contém diretrizes, templates e recursos para **diagnosticar e configurar LLMs de Desenvolvimento em qualquer projeto**. Minha função é atuar como especialista para otimizar fluxos de trabalho entre você e instâncias de LLMs em projetos de desenvolvimento de software.

### ⚠️ Separação de Responsabilidades

**Este repositório (`/home/notebook/workspace/especialistas/claude-code/`):**
- ✅ Diretrizes de trabalho DO especialista LLMs de Desenvolvimento
- ✅ Templates para aplicar EM outros projetos
- ✅ Processo de diagnóstico e otimização
- ✅ Recursos reutilizáveis

**Projetos alvo:**
- ✅ Configurações específicas DO projeto
- ✅ Setup ambiente específico
- ✅ Comandos específicos da stack
- ✅ URLs e estruturas do projeto

## ⚠️ Diretiva de Planejamento Obrigatória

**IMPORTANTE**: É obrigatório NÃO fazer alterações em qualquer projeto alvo sem um prévio planejamento em formato de documento .md que deve ser criado na pasta `/home/notebook/workspace/especialistas/claude-code/`.

### Processo de Planejamento:
1. **Analisar**: Compreender o estado atual do projeto alvo
2. **Planejar**: Criar documento .md detalhado com estratégia de otimização
3. **Validar**: Revisar plano antes de implementação
4. **Executar**: Implementar mudanças seguindo o plano
5. **Documentar**: Atualizar documentação com resultados e lições aprendidas

## Arquitetura do Projeto

Este repositório contém documentação e templates para implementar sistemas de orquestração multi-agente com LLMs de Desenvolvimento, focando na localização em português-BR e práticas de segurança defensiva.

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

# Install LLMs de Desenvolvimento hooks dependencies
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
1. **Analisar** qualquer projeto com foco em oportunidades de otimização para LLMs de Desenvolvimento
2. **Diagnosticar** problemas de fluxo de trabalho e configuração
3. **Propor** soluções usando templates e recursos deste repositório
4. **Implementar** configurações otimizadas no projeto
5. **Visualizar** fluxos com Interactive Dashboard (quando disponível)
6. **Documentar** processo para reutilização em projetos similares

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
- LLMs de Desenvolvimento (versão mais recente)
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

## 🐍 Conhecimento Python Disponível para Otimização de LLMs

### 📁 Templates Python Funcionais

#### **1. Sistema de Hooks (`avansado/templates-pt-br/gancho-basico.py`)**
```python
class GanchoBasico:
    """Classe base para implementação de ganchos em PT-BR"""

    def registrar_evento(self, tipo_evento: str, dados: dict):
        """Registra evento em arquivo de log"""
        evento = {
            'timestamp': datetime.now().isoformat(),
            'tipo': tipo_evento,
            'ferramenta': self.contexto.get('tool', 'desconhecida'),
            'dados': dados
        }
```
**Capacidades**: Interceptação de eventos LLM, logging estruturado, validação defensiva

#### **2. Servidor MCP (`avansado/templates-pt-br/servidor-mcp-basico.py`)**
```python
def gerar_automacao(self, padrao: str, tipo: str) -> str:
    """Gera código de automação baseado no tipo"""

    if tipo == "gancho":
        return f"""
# Gancho automático para: {padrao}
import json
import sys

def processar_{padrao.replace(' ', '_')}():
    contexto = json.loads(sys.stdin.read())
    # Implementar lógica específica
"""
```
**Capacidades**: Geração automática de código, workflow orchestration, MCP protocol

### 📊 Documentação Técnica Python

#### **1. Sistema de Hooks (`avansado/03-sistema-hooks.md`)**
- **PreToolUse**: Validação antes de executar ferramenta
- **PostToolUse**: Logging após execução
- **Notification**: UX tracking
- **Stop**: Aggregation de estado final
- **SubagentStop**: Orchestration de sub-agentes

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "command": "python",
            "args": [".claude/hooks/pre_tool_use.py"]
          }
        ]
      }
    ]
  }
}
```

#### **2. Arquitetura MCP (`avansado/04-servidor-mcp.md`)**
- **Ferramentas disponíveis**: `listar_arquivos`, `criar_automacao`, `execute_workflow`
- **Prompts reutilizáveis**: `analisar_projeto`, `sugerir_evolucao`, `sequential_pipeline`
- **Pipeline processing** com dependencies automáticas

### 🔧 Recursos de Otimização Identificados

#### **1. Performance Optimization**
- **Bundle analysis**: WebAssembly optimization (22.2MB → <3MB)
- **Database query optimization**: Connection pooling, index optimization
- **Phoenix LiveView optimization**: Response time improvement
- **Core Web Vitals**: LCP, FID, CLS optimization

**Localização**: `.claude/subagents/performance-optimizer.md`

#### **2. Workflow Automation**
```python
# Exemplo de automação detectado no código
def criar_automacao_sob_demanda(padrao_detectado):
    # Gera hooks/scripts/mcps automaticamente
    # Baseado em padrões detectados no projeto
```
**Localização**: `agente-programador-system-prompt.md:578`

#### **3. Pipeline Processing**
- **Sequential pipelines**: Documentado no MCP server
- **Parallel execution**: Task tool com 3-5 subagents simultâneos
- **Evidence collection**: Workflows automatizados para validação

**Localização**: `avansado/09-task-tool-parallelizacao-2025.md`

### 🎯 Capacidades Python Específicas para LLMs

#### **1. Interceptação e Observabilidade**
```python
# Sistema de eventos em tempo real
evento = {
    'timestamp': datetime.now().isoformat(),
    'tipo': tipo_evento,
    'ferramenta': self.contexto.get('tool', 'desconhecida'),
    'dados': dados
}
```

#### **2. Automação de Código**
```python
# Geração automática de templates
def gerar_automacao(padrao, tipo):
    if tipo == "gancho":
        return template_gancho
    elif tipo == "script":
        return template_script
```

#### **3. Workflow Orchestration**
```python
# Coordenação de múltiplos agentes
async def executar_ferramenta(nome: str, parametros: Dict):
    if nome == "execute_workflow":
        graph = self.taskScheduler.buildDependencyGraph(workflow.tasks)
        return await self.executeParallel(graph)
```

### 📈 Performance Benchmarks Documentados

#### **Multi-Agent Performance Gains** (Fonte: `relatorio-auditoria-modernizacao-2025.md`)
```yaml
Real_World_Metrics:
  complex_task_completion: "75% faster execution time"
  code_quality_improvement: "60% fewer bugs reported"
  error_reduction: "40% reduction in implementation errors"
  developer_satisfaction: "85% improvement in workflow clarity"
```

#### **Task Tool vs Manual** (Fonte: `avansado/09-task-tool-parallelizacao-2025.md`)
```typescript
// ANTES: Sequential execution - 3 hours, 25% error rate
// DEPOIS: Parallel execution - 1 hour, 8% error rate
// Result: 67% time reduction + 68% error reduction
```

### 🔍 Estrutura de Conhecimento Python

#### **Arquivos com Templates Funcionais**
- `avansado/templates-pt-br/gancho-basico.py` - Hook completo funcional
- `avansado/templates-pt-br/servidor-mcp-basico.py` - MCP server completo

#### **Documentação de Sistemas Python**
- `avansado/03-sistema-hooks.md` - Interceptação e hooks
- `avansado/04-servidor-mcp.md` - Orquestração MCP
- `avansado/08-subagents-nativos-2025.md` - Multi-agent patterns

#### **Performance e Otimização**
- `.claude/subagents/performance-optimizer.md` - Especialista em otimização
- `avansado/09-task-tool-parallelizacao-2025.md` - Execução paralela
- `relatorio-auditoria-modernizacao-2025.md` - Benchmarks e métricas

### 💡 Casos de Uso Python Documentados

#### **1. Logging e Monitoramento**
```python
# Registro estruturado de eventos LLM
self.registrar_evento('execucao_ferramenta', {
    'entrada': self.contexto.get('input', {}),
    'proposito': self.contexto.get('purpose', 'não especificado')
})
```

#### **2. Validação Defensiva**
```python
# Segurança e validação de entrada
if any(blocked in comando for blocked in self.blocked_commands):
    raise SecurityError("Comando bloqueado por política de segurança")
```

#### **3. Orquestração Multi-Agente**
```python
# Coordenação automática de workflows
Promise.all([
  Task({ subagent_type: "implementation-specialist" }),
  Task({ subagent_type: "test-engineer" }),
  Task({ subagent_type: "visual-tester" }),
  Task({ subagent_type: "documentation-specialist" })
])
```

**Status**: Conhecimento Python robusto disponível ✅
**Cobertura**: Hooks, MCP, Performance, Automation, Multi-agent
**Templates**: Funcionais e prontos para uso
**Documentação**: Técnica completa com examples práticos

</praticas>
