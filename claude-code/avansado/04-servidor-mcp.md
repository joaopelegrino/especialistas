# Servidor de Orquestração MCP - Implementação Completa

## 🎯 Visão Geral

O Servidor de Orquestração MCP (Model Context Protocol) atua como o cérebro central do sistema multi-agente, coordenando tarefas, distribuindo trabalho e agregando resultados de múltiplas instâncias do Claude Code.

## 🏗️ Arquitetura do MCP Server

```

### 3. Serviço de Gerenciamento de Agentes (src/services/AgentManager.ts)

```typescript
/**
 * Gerenciador de Agentes - Coordena múltiplas instâncias Claude Code
 */

import { EventEmitter } from 'events';
import Database from 'better-sqlite3';
import { logger } from '../utils/logger.js';

export interface Agent {
  id: string;
  name: string;
  type: 'primary' | 'subagent';
  status: 'idle' | 'active' | 'offline';
  project: string;
  capabilities: string[];
  current_task?: string;
  metrics: AgentMetrics;
  last_heartbeat: string;
}

export interface AgentMetrics {
  tasks_completed: number;
  tasks_failed: number;
  avg_completion_time_ms: number;
  tokens_used: number;
  success_rate: number;
}

export class AgentManager extends EventEmitter {
  private agents: Map<string, Agent> = new Map();
  private db: Database.Database;
  private heartbeatInterval: NodeJS.Timer;

  constructor() {
    super();
    this.db = new Database('orchestrator.db');
    this.initDatabase();
    this.startHeartbeatMonitor();
  }

  private initDatabase() {
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS agents (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        project TEXT NOT NULL,
        capabilities TEXT NOT NULL,
        current_task TEXT,
        metrics TEXT NOT NULL,
        last_heartbeat DATETIME DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS agent_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        agent_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        task_id TEXT,
        data TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (agent_id) REFERENCES agents(id)
      );
    `);
  }

  private startHeartbeatMonitor() {
    this.heartbeatInterval = setInterval(() => {
      const now = new Date();
      
      for (const [id, agent] of this.agents) {
        const lastHeartbeat = new Date(agent.last_heartbeat);
        const timeDiff = now.getTime() - lastHeartbeat.getTime();
        
        // Se não recebeu heartbeat em 30 segundos, marca como offline
        if (timeDiff > 30000 && agent.status !== 'offline') {
          this.updateAgentStatus(id, 'offline');
          logger.warn(`Agent ${id} marcado como offline (sem heartbeat)`);
        }
      }
    }, 10000); // Verifica a cada 10 segundos
  }

  async registerAgent(agent: Omit<Agent, 'metrics' | 'last_heartbeat'>): Promise<Agent> {
    const fullAgent: Agent = {
      ...agent,
      metrics: {
        tasks_completed: 0,
        tasks_failed: 0,
        avg_completion_time_ms: 0,
        tokens_used: 0,
        success_rate: 0,
      },
      last_heartbeat: new Date().toISOString(),
    };

    this.agents.set(agent.id, fullAgent);
    
    // Persiste no banco
    const stmt = this.db.prepare(`
      INSERT OR REPLACE INTO agents 
      (id, name, type, status, project, capabilities, current_task, metrics, last_heartbeat)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    
    stmt.run(
      fullAgent.id,
      fullAgent.name,
      fullAgent.type,
      fullAgent.status,
      fullAgent.project,
      JSON.stringify(fullAgent.capabilities),
      fullAgent.current_task,
      JSON.stringify(fullAgent.metrics),
      fullAgent.last_heartbeat
    );

    this.emit('agent:registered', fullAgent);
    logger.info(`Agent registrado: ${agent.id}`);
    
    return fullAgent;
  }

  async selectAgent(strategy: string, preferredAgents?: string[]): Promise<Agent | null> {
    const availableAgents = Array.from(this.agents.values())
      .filter(a => a.status === 'idle' || a.status === 'active');

    if (availableAgents.length === 0) {
      return null;
    }

    // Filtra por agentes preferidos se especificado
    if (preferredAgents && preferredAgents.length > 0) {
      const preferred = availableAgents.filter(a => preferredAgents.includes(a.id));
      if (preferred.length > 0) {
        availableAgents.splice(0, availableAgents.length, ...preferred);
      }
    }

    switch (strategy) {
      case 'round-robin':
        // Simples round-robin
        return availableAgents[0];

      case 'least-loaded':
        // Seleciona agente com menos tarefas ativas
        return availableAgents.reduce((prev, curr) => {
          const prevLoad = prev.current_task ? 1 : 0;
          const currLoad = curr.current_task ? 1 : 0;
          return currLoad < prevLoad ? curr : prev;
        });

      case 'specialized':
        // Seleciona baseado em capacidades (precisa de lógica adicional)
        return this.selectSpecializedAgent(availableAgents);

      case 'broadcast':
        // Retorna todos os agentes disponíveis
        return availableAgents[0]; // Simplificado para este exemplo

      default:
        return availableAgents[0];
    }
  }

  private selectSpecializedAgent(agents: Agent[]): Agent {
    // Lógica de especialização baseada em capacidades
    // Por exemplo, seleciona agente com mais capacidades relevantes
    return agents[0]; // Simplificado
  }

  async notifyAgent(agentId: string, notification: any): Promise<void> {
    const agent = this.agents.get(agentId);
    if (!agent) {
      throw new Error(`Agent ${agentId} não encontrado`);
    }

    // Registra notificação no histórico
    const stmt = this.db.prepare(`
      INSERT INTO agent_history (agent_id, event_type, task_id, data)
      VALUES (?, ?, ?, ?)
    `);
    
    stmt.run(
      agentId,
      notification.type,
      notification.task?.id,
      JSON.stringify(notification)
    );

    this.emit('agent:notified', { agentId, notification });
    logger.debug(`Notificação enviada para agent ${agentId}:`, notification);
  }

  async updateAgentStatus(agentId: string, status: Agent['status']): Promise<void> {
    const agent = this.agents.get(agentId);
    if (!agent) {
      return;
    }

    agent.status = status;
    agent.last_heartbeat = new Date().toISOString();

    // Atualiza no banco
    const stmt = this.db.prepare(`
      UPDATE agents SET status = ?, last_heartbeat = ? WHERE id = ?
    `);
    stmt.run(status, agent.last_heartbeat, agentId);

    this.emit('agent:status_changed', { agentId, status });
  }

  async updateAgentMetrics(agentId: string, taskResult: any): Promise<void> {
    const agent = this.agents.get(agentId);
    if (!agent) {
      return;
    }

    // Atualiza métricas
    if (taskResult.success) {
      agent.metrics.tasks_completed++;
    } else {
      agent.metrics.tasks_failed++;
    }

    agent.metrics.tokens_used += taskResult.tokens_used || 0;
    
    // Recalcula taxa de sucesso
    const total = agent.metrics.tasks_completed + agent.metrics.tasks_failed;
    agent.metrics.success_rate = total > 0 
      ? agent.metrics.tasks_completed / total 
      : 0;

    // Atualiza tempo médio
    if (taskResult.execution_time_ms) {
      const currentAvg = agent.metrics.avg_completion_time_ms;
      const newCount = agent.metrics.tasks_completed;
      agent.metrics.avg_completion_time_ms = 
        (currentAvg * (newCount - 1) + taskResult.execution_time_ms) / newCount;
    }

    // Persiste métricas
    const stmt = this.db.prepare(`
      UPDATE agents SET metrics = ? WHERE id = ?
    `);
    stmt.run(JSON.stringify(agent.metrics), agentId);

    this.emit('agent:metrics_updated', { agentId, metrics: agent.metrics });
  }

  async getAllStatus(): Promise<Agent[]> {
    return Array.from(this.agents.values());
  }

  async getMetrics(): Promise<any> {
    const agents = Array.from(this.agents.values());
    
    return {
      total_agents: agents.length,
      active_agents: agents.filter(a => a.status === 'active').length,
      idle_agents: agents.filter(a => a.status === 'idle').length,
      offline_agents: agents.filter(a => a.status === 'offline').length,
      total_tasks_completed: agents.reduce((sum, a) => sum + a.metrics.tasks_completed, 0),
      total_tasks_failed: agents.reduce((sum, a) => sum + a.metrics.tasks_failed, 0),
      total_tokens_used: agents.reduce((sum, a) => sum + a.metrics.tokens_used, 0),
      avg_success_rate: agents.reduce((sum, a) => sum + a.metrics.success_rate, 0) / agents.length,
    };
  }

  async getHistory(limit: number = 100): Promise<any[]> {
    const stmt = this.db.prepare(`
      SELECT * FROM agent_history 
      ORDER BY timestamp DESC 
      LIMIT ?
    `);
    
    return stmt.all(limit);
  }

  destroy() {
    clearInterval(this.heartbeatInterval);
    this.db.close();
  }
}
```

### 4. Serviço de Agendamento de Tarefas (src/services/TaskScheduler.ts)

```typescript
/**
 * Agendador de Tarefas com suporte a dependências
 */

import { EventEmitter } from 'events';
import { logger } from '../utils/logger.js';

export interface Task {
  id: string;
  type: string;
  description: string;
  priority: number;
  dependencies: string[];
  payload: any;
  status: 'pending' | 'running' | 'completed' | 'failed';
  assignedTo?: string;
  scheduledAt?: string;
  startedAt?: string;
  completedAt?: string;
  result?: any;
  error?: string;
}

export interface DependencyGraph {
  nodes: Map<string, Task>;
  edges: Map<string, Set<string>>;
  inDegree: Map<string, number>;
}

export class TaskScheduler extends EventEmitter {
  private queue: Task[] = [];
  private running: Map<string, Task> = new Map();
  private completed: Map<string, Task> = new Map();
  private maxConcurrent: number = 10;

  constructor() {
    super();
  }

  async scheduleTask(task: Task): Promise<Task> {
    task.status = 'pending';
    task.scheduledAt = new Date().toISOString();
    
    // Adiciona à fila com prioridade
    this.queue.push(task);
    this.queue.sort((a, b) => b.priority - a.priority);
    
    this.emit('task:scheduled', task);
    logger.info(`Tarefa ${task.id} agendada`);
    
    // Tenta executar imediatamente se houver slot
    this.processQueue();
    
    return task;
  }

  buildDependencyGraph(tasks: Task[]): DependencyGraph {
    const graph: DependencyGraph = {
      nodes: new Map(),
      edges: new Map(),
      inDegree: new Map(),
    };

    // Adiciona nós
    for (const task of tasks) {
      graph.nodes.set(task.id, task);
      graph.edges.set(task.id, new Set());
      graph.inDegree.set(task.id, 0);
    }

    // Adiciona arestas e calcula in-degree
    for (const task of tasks) {
      for (const dep of task.dependencies) {
        if (graph.nodes.has(dep)) {
          graph.edges.get(dep)!.add(task.id);
          graph.inDegree.set(task.id, graph.inDegree.get(task.id)! + 1);
        }
      }
    }

    return graph;
  }

  async executeWithDependencies(graph: DependencyGraph): Promise<any> {
    const completed: string[] = [];
    const ready: string[] = [];
    const inProgress = new Set<string>();
    const startTime = Date.now();

    // Encontra tarefas sem dependências
    for (const [taskId, degree] of graph.inDegree) {
      if (degree === 0) {
        ready.push(taskId);
      }
    }

    // Executa tarefas respeitando dependências
    while (ready.length > 0 || inProgress.size > 0) {
      // Inicia tarefas prontas
      while (ready.length > 0 && inProgress.size < this.maxConcurrent) {
        const taskId = ready.shift()!;
        const task = graph.nodes.get(taskId)!;
        
        inProgress.add(taskId);
        
        // Simula execução assíncrona
        this.executeTask(task).then(() => {
          inProgress.delete(taskId);
          completed.push(taskId);
          
          // Atualiza dependências
          for (const dependent of graph.edges.get(taskId) || []) {
            const newDegree = graph.inDegree.get(dependent)! - 1;
            graph.inDegree.set(dependent, newDegree);
            
            if (newDegree === 0) {
              ready.push(dependent);
            }
          }
        });
      }

      // Aguarda um pouco antes de verificar novamente
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    return {
      completed: completed.length,
      duration_ms: Date.now() - startTime,
      tasks: completed,
    };
  }

  private async executeTask(task: Task): Promise<void> {
    task.status = 'running';
    task.startedAt = new Date().toISOString();
    this.running.set(task.id, task);
    
    this.emit('task:started', task);
    logger.info(`Executando tarefa ${task.id}`);
    
    try {
      // Simula execução (em produção, isso delegaria para o agente)
      await new Promise(resolve => setTimeout(resolve, Math.random() * 5000));
      
      task.status = 'completed';
      task.completedAt = new Date().toISOString();
      task.result = { success: true, data: 'Task completed' };
      
      this.completed.set(task.id, task);
      this.running.delete(task.id);
      
      this.emit('task:completed', task);
      logger.info(`Tarefa ${task.id} completada`);
      
    } catch (error) {
      task.status = 'failed';
      task.completedAt = new Date().toISOString();
      task.error = error.message;
      
      this.running.delete(task.id);
      
      this.emit('task:failed', task);
      logger.error(`Tarefa ${task.id} falhou:`, error);
    }
  }

  private processQueue() {
    while (this.queue.length > 0 && this.running.size < this.maxConcurrent) {
      const task = this.queue.shift()!;
      this.executeTask(task);
    }
  }

  async getQueue(): Promise<Task[]> {
    return [...this.queue];
  }

  async getRunning(): Promise<Task[]> {
    return Array.from(this.running.values());
  }

  async getCompleted(): Promise<Task[]> {
    return Array.from(this.completed.values());
  }
}
```

## 🚀 Deployment e Configuração

### 1. Instalação

```bash
# Clone o template
git clone https://github.com/disler/claude-code-hooks-multi-agent-observability.git orchestrator-mcp
cd orchestrator-mcp

# Instale dependências
bun install

# Configure ambiente
cp .env.example .env
# Edite .env com suas configurações
```

### 2. Configuração do Claude Code

```json
// .claude/mcp-servers.json
{
  "mcpServers": {
    "orchestrator": {
      "type": "stdio",
      "command": "node",
      "args": ["/path/to/orchestrator-mcp/dist/index.js"],
      "env": {
        "NODE_ENV": "production",
        "DATABASE_PATH": "/path/to/orchestrator.db",
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

### 3. Uso com Claude Code

```markdown
<!-- .claude/commands/orchestrate.md -->
Use o MCP Server de orquestração para coordenar desenvolvimento:

1. Distribua tarefas: use a ferramenta distribute_task
2. Monitore progresso: use monitor_agents
3. Colete resultados: use collect_results
4. Execute workflows: use execute_workflow

Para desenvolvimento completo, use o prompt:
/orchestrate_development com a especificação da feature
```

## 📊 Monitoramento e Métricas

### Dashboard de Métricas

```typescript
// Endpoint para métricas Prometheus-compatible
app.get('/metrics', async (req, res) => {
  const metrics = await agentManager.getMetrics();
  
  res.type('text/plain');
  res.send(`
# HELP orchestrator_agents_total Total number of agents
# TYPE orchestrator_agents_total gauge
orchestrator_agents_total ${metrics.total_agents}

# HELP orchestrator_agents_active Active agents
# TYPE orchestrator_agents_active gauge
orchestrator_agents_active ${metrics.active_agents}

# HELP orchestrator_tasks_completed_total Total completed tasks
# TYPE orchestrator_tasks_completed_total counter
orchestrator_tasks_completed_total ${metrics.total_tasks_completed}

# HELP orchestrator_tokens_used_total Total tokens used
# TYPE orchestrator_tokens_used_total counter
orchestrator_tokens_used_total ${metrics.total_tokens_used}
  `);
});
```

## 🔗 Referências

1. **Model Context Protocol Documentation**
   - URL: https://modelcontextprotocol.io/introduction
   - Especificação oficial do protocolo MCP

2. **MCP SDK TypeScript**
   - URL: https://github.com/modelcontextprotocol/sdk-typescript
   - SDK oficial para implementação

3. **Claude Code MCP Integration**
   - URL: https://docs.anthropic.com/en/docs/claude-code/mcp-servers
   - Guia de integração com Claude Code

4. **Community MCP Servers**
   - URL: https://github.com/topics/mcp-server
   - Exemplos de implementação da comunidade

---

**Próximo**: [5. MONITORING-DASHBOARD - Dashboard de Monitoramento](./5-monitoring-dashboard.md)mermaid
graph TB
    subgraph "MCP Orchestrator"
        T[Tools]
        P[Prompts]
        R[Resources]
        
        subgraph "Core Services"
            TM[Task Manager]
            AM[Agent Manager]
            RM[Result Manager]
            MM[Metrics Manager]
        end
    end
    
    subgraph "External Connections"
        CA[Claude Agents]
        DB[(Database)]
        WS[WebSocket]
        API[REST API]
    end
    
    T --> TM
    P --> AM
    R --> RM
    
    TM <--> CA
    AM <--> CA
    RM <--> DB
    MM <--> WS & API
```

## 📦 Estrutura do Projeto MCP

```bash
orchestrator-mcp/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts                 # Entry point
│   ├── server.ts                 # MCP Server implementation
│   ├── tools/
│   │   ├── distribute-task.ts   # Distribuição de tarefas
│   │   ├── collect-results.ts   # Coleta de resultados
│   │   ├── monitor-agents.ts    # Monitoramento
│   │   └── aggregate-data.ts    # Agregação
│   ├── prompts/
│   │   ├── orchestrate.ts       # Prompt de orquestração
│   │   ├── parallel-exec.ts     # Execução paralela
│   │   └── sequential-exec.ts   # Execução sequencial
│   ├── resources/
│   │   ├── agent-status.ts      # Status dos agentes
│   │   ├── task-queue.ts        # Fila de tarefas
│   │   └── results-store.ts     # Armazenamento
│   ├── services/
│   │   ├── AgentManager.ts      # Gerenciamento de agentes
│   │   ├── TaskScheduler.ts     # Agendamento de tarefas
│   │   ├── DependencyGraph.ts   # Grafo de dependências
│   │   └── ResultAggregator.ts  # Agregador
│   └── utils/
│       ├── logger.ts
│       ├── metrics.ts
│       └── validation.ts
```

## 🔧 Implementação do MCP Server

### 1. Configuração Base (package.json)

```json
{
  "name": "orchestrator-mcp",
  "version": "1.0.0",
  "description": "MCP Server for Multi-Agent Orchestration",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsx watch src/index.ts",
    "test": "jest"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "bun": "^1.0.0",
    "sqlite3": "^5.1.6",
    "better-sqlite3": "^9.0.0",
    "ws": "^8.14.0",
    "zod": "^3.22.0",
    "winston": "^3.11.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/ws": "^8.5.0",
    "typescript": "^5.0.0",
    "tsx": "^4.0.0",
    "jest": "^29.0.0"
  }
}
```

### 2. Server Principal (src/server.ts)

```typescript
/**
 * MCP Server Principal para Orquestração Multi-Agente
 * Baseado no Model Context Protocol da Anthropic
 * Ref: https://modelcontextprotocol.io/introduction
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListPromptsRequestSchema,
  GetPromptRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';
import { AgentManager } from './services/AgentManager.js';
import { TaskScheduler } from './services/TaskScheduler.js';
import { ResultAggregator } from './services/ResultAggregator.js';
import { logger } from './utils/logger.js';

export class OrchestratorMCPServer {
  private server: Server;
  private agentManager: AgentManager;
  private taskScheduler: TaskScheduler;
  private resultAggregator: ResultAggregator;

  constructor() {
    this.server = new Server(
      {
        name: 'orchestrator-mcp',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
          prompts: {},
          resources: {},
        },
      }
    );

    this.agentManager = new AgentManager();
    this.taskScheduler = new TaskScheduler();
    this.resultAggregator = new ResultAggregator();

    this.setupHandlers();
  }

  private setupHandlers() {
    // Lista ferramentas disponíveis
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'distribute_task',
          description: 'Distribui uma tarefa para agentes disponíveis',
          inputSchema: {
            type: 'object',
            properties: {
              task: {
                type: 'object',
                properties: {
                  id: { type: 'string' },
                  type: { type: 'string' },
                  description: { type: 'string' },
                  priority: { type: 'number' },
                  dependencies: {
                    type: 'array',
                    items: { type: 'string' }
                  },
                  payload: { type: 'object' }
                },
                required: ['id', 'type', 'description']
              },
              agents: {
                type: 'array',
                items: { type: 'string' },
                description: 'IDs dos agentes específicos (opcional)'
              },
              strategy: {
                type: 'string',
                enum: ['round-robin', 'least-loaded', 'specialized', 'broadcast'],
                default: 'least-loaded'
              }
            },
            required: ['task']
          }
        },
        {
          name: 'collect_results',
          description: 'Coleta resultados de tarefas executadas',
          inputSchema: {
            type: 'object',
            properties: {
              session_id: { type: 'string' },
              task_ids: {
                type: 'array',
                items: { type: 'string' }
              },
              aggregate: { type: 'boolean', default: true }
            },
            required: ['session_id']
          }
        },
        {
          name: 'monitor_agents',
          description: 'Monitora status de agentes ativos',
          inputSchema: {
            type: 'object',
            properties: {
              include_metrics: { type: 'boolean', default: true },
              include_history: { type: 'boolean', default: false }
            }
          }
        },
        {
          name: 'execute_workflow',
          description: 'Executa workflow completo com dependências',
          inputSchema: {
            type: 'object',
            properties: {
              workflow: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  tasks: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        id: { type: 'string' },
                        type: { type: 'string' },
                        dependencies: {
                          type: 'array',
                          items: { type: 'string' }
                        }
                      }
                    }
                  }
                },
                required: ['name', 'tasks']
              }
            },
            required: ['workflow']
          }
        }
      ],
    }));

    // Handler para execução de ferramentas
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'distribute_task':
            return await this.distributeTask(args);
          
          case 'collect_results':
            return await this.collectResults(args);
          
          case 'monitor_agents':
            return await this.monitorAgents(args);
          
          case 'execute_workflow':
            return await this.executeWorkflow(args);
          
          default:
            throw new Error(`Ferramenta desconhecida: ${name}`);
        }
      } catch (error) {
        logger.error(`Erro executando ferramenta ${name}:`, error);
        return {
          content: [
            {
              type: 'text',
              text: `Erro: ${error.message}`
            }
          ]
        };
      }
    });

    // Lista prompts disponíveis
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => ({
      prompts: [
        {
          name: 'orchestrate_development',
          description: 'Orquestra desenvolvimento completo de feature',
          arguments: [
            {
              name: 'feature_spec',
              description: 'Especificação da feature',
              required: true
            },
            {
              name: 'team_size',
              description: 'Número de agentes para usar',
              required: false
            }
          ]
        },
        {
          name: 'parallel_analysis',
          description: 'Análise paralela de múltiplos aspectos',
          arguments: [
            {
              name: 'target',
              description: 'Alvo da análise',
              required: true
            },
            {
              name: 'aspects',
              description: 'Aspectos para analisar',
              required: true
            }
          ]
        },
        {
          name: 'sequential_pipeline',
          description: 'Pipeline sequencial com checkpoints',
          arguments: [
            {
              name: 'stages',
              description: 'Estágios do pipeline',
              required: true
            }
          ]
        }
      ],
    }));

    // Handler para obter prompt específico
    this.server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      const prompts = {
        orchestrate_development: this.getOrchestrateDevelopmentPrompt(args),
        parallel_analysis: this.getParallelAnalysisPrompt(args),
        sequential_pipeline: this.getSequentialPipelinePrompt(args),
      };

      const prompt = prompts[name];
      if (!prompt) {
        throw new Error(`Prompt desconhecido: ${name}`);
      }

      return prompt;
    });

    // Lista recursos disponíveis
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => ({
      resources: [
        {
          uri: 'agent://status',
          name: 'Agent Status',
          description: 'Status atual de todos os agentes',
          mimeType: 'application/json'
        },
        {
          uri: 'task://queue',
          name: 'Task Queue',
          description: 'Fila de tarefas pendentes',
          mimeType: 'application/json'
        },
        {
          uri: 'result://recent',
          name: 'Recent Results',
          description: 'Resultados recentes agregados',
          mimeType: 'application/json'
        }
      ],
    }));

    // Handler para ler recursos
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const { uri } = request.params;

      switch (uri) {
        case 'agent://status':
          return {
            contents: [
              {
                uri,
                mimeType: 'application/json',
                text: JSON.stringify(await this.agentManager.getAllStatus(), null, 2)
              }
            ]
          };

        case 'task://queue':
          return {
            contents: [
              {
                uri,
                mimeType: 'application/json',
                text: JSON.stringify(await this.taskScheduler.getQueue(), null, 2)
              }
            ]
          };

        case 'result://recent':
          return {
            contents: [
              {
                uri,
                mimeType: 'application/json',
                text: JSON.stringify(await this.resultAggregator.getRecentResults(), null, 2)
              }
            ]
          };

        default:
          throw new Error(`Recurso desconhecido: ${uri}`);
      }
    });
  }

  private async distributeTask(args: any) {
    const { task, agents, strategy } = args;
    
    // Seleciona agente baseado na estratégia
    const selectedAgent = await this.agentManager.selectAgent(strategy, agents);
    
    if (!selectedAgent) {
      throw new Error('Nenhum agente disponível');
    }

    // Adiciona tarefa à fila
    const scheduledTask = await this.taskScheduler.scheduleTask({
      ...task,
      assignedTo: selectedAgent.id,
      scheduledAt: new Date().toISOString(),
    });

    // Notifica agente
    await this.agentManager.notifyAgent(selectedAgent.id, {
      type: 'task_assigned',
      task: scheduledTask
    });

    return {
      content: [
        {
          type: 'text',
          text: `Tarefa ${task.id} distribuída para agente ${selectedAgent.id} usando estratégia ${strategy}`
        }
      ]
    };
  }

  private async collectResults(args: any) {
    const { session_id, task_ids, aggregate } = args;
    
    const results = await this.resultAggregator.collectResults(session_id, task_ids);
    
    if (aggregate) {
      const aggregated = await this.resultAggregator.aggregate(results);
      
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(aggregated, null, 2)
          }
        ]
      };
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(results, null, 2)
        }
      ]
    };
  }

  private async monitorAgents(args: any) {
    const { include_metrics, include_history } = args;
    
    const status = await this.agentManager.getAllStatus();
    
    const monitoring = {
      timestamp: new Date().toISOString(),
      total_agents: status.length,
      active_agents: status.filter(a => a.status === 'active').length,
      idle_agents: status.filter(a => a.status === 'idle').length,
      agents: status,
    };

    if (include_metrics) {
      monitoring['metrics'] = await this.agentManager.getMetrics();
    }

    if (include_history) {
      monitoring['history'] = await this.agentManager.getHistory();
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(monitoring, null, 2)
        }
      ]
    };
  }

  private async executeWorkflow(args: any) {
    const { workflow } = args;
    
    // Constrói grafo de dependências
    const graph = this.taskScheduler.buildDependencyGraph(workflow.tasks);
    
    // Executa tarefas respeitando dependências
    const execution = await this.taskScheduler.executeWithDependencies(graph);
    
    return {
      content: [
        {
          type: 'text',
          text: `Workflow ${workflow.name} executado com sucesso. 
          Tarefas completadas: ${execution.completed}
          Tempo total: ${execution.duration_ms}ms`
        }
      ]
    };
  }

  private getOrchestrateDevelopmentPrompt(args: any) {
    const { feature_spec, team_size = 4 } = args;
    
    return {
      messages: [
        {
          role: 'user',
          content: {
            type: 'text',
            text: `Você é o orquestrador central de uma equipe de ${team_size} agentes Claude Code.
            
            ESPECIFICAÇÃO DA FEATURE:
            ${feature_spec}
            
            SUAS RESPONSABILIDADES:
            1. Analisar a especificação e quebrar em tarefas menores
            2. Identificar dependências entre tarefas
            3. Distribuir tarefas para agentes especializados:
               - Frontend Agent: Componentes UI, React, CSS
               - Backend Agent: APIs, lógica de negócio, banco de dados
               - Testing Agent: Testes unitários, integração, E2E
               - DevOps Agent: CI/CD, deployment, monitoring
            
            4. Coordenar execução respeitando dependências
            5. Coletar e consolidar resultados
            6. Garantir qualidade e coesão do resultado final
            
            WORKFLOW:
            Fase 1 - Análise (Paralela):
            - Todos os agentes analisam a spec de sua perspectiva
            - Identificam requisitos e desafios
            
            Fase 2 - Planejamento (Sequencial):
            - Consolidar análises
            - Definir arquitetura
            - Criar plano de implementação
            
            Fase 3 - Implementação (Paralela com sincronização):
            - Frontend e Backend trabalham em paralelo
            - Sincronização em pontos de integração
            - Testing acompanha desenvolvimento
            
            Fase 4 - Integração (Sequencial):
            - Integrar componentes
            - Executar testes completos
            - Deploy e monitoring
            
            Use as ferramentas disponíveis:
            - distribute_task: Para distribuir tarefas
            - monitor_agents: Para acompanhar progresso
            - collect_results: Para coletar resultados
            - execute_workflow: Para workflows complexos
            
            Comece analisando a especificação e criando o plano de execução.`
          }
        }
      ]
    };
  }

  private getParallelAnalysisPrompt(args: any) {
    const { target, aspects } = args;
    
    return {
      messages: [
        {
          role: 'user',
          content: {
            type: 'text',
            text: `Execute análise paralela de ${target} nos seguintes aspectos: ${aspects}.
            
            Distribua cada aspecto para um agente diferente para análise simultânea.
            Colete e consolide os resultados em um relatório unificado.`
          }
        }
      ]
    };
  }

  private getSequentialPipelinePrompt(args: any) {
    const { stages } = args;
    
    return {
      messages: [
        {
          role: 'user',
          content: {
            type: 'text',
            text: `Execute pipeline sequencial com os estágios: ${stages}.
            
            Cada estágio deve ser completado antes do próximo iniciar.
            Implemente checkpoints e validação entre estágios.`
          }
        }
      ]
    };
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    logger.info('Orchestrator MCP Server iniciado');
  }
}

// Entry point
const server = new OrchestratorMCPServer();
server.start().catch((error) => {
  logger.error('Erro iniciando servidor:', error);
  process.exit(1);
});
