# Guia Completo de Implementação - Sistema Multi-Agente com Observabilidade

## 🎯 Objetivo do Guia

Este guia fornece instruções detalhadas para implementar um sistema completo de orquestração multi-agente com observabilidade em tempo real, do zero até produção.

## 📋 Pré-requisitos

### Software Necessário

| Software | Versão Mínima | Verificação | Instalação |
|----------|---------------|-------------|------------|
| Node.js | 20.0.0 | `node --version` | [nodejs.org](https://nodejs.org) |
| Bun | 1.0.0 | `bun --version` | [bun.sh](https://bun.sh) |
| Python | 3.8+ | `python --version` | [python.org](https://python.org) |
| Git | 2.0+ | `git --version` | [git-scm.com](https://git-scm.com) |
| Claude Code | Latest | `claude --version` | [Anthropic Docs](https://docs.anthropic.com/en/docs/claude-code) |
| Astral uv | Latest | `uv --version` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

### Chaves de API

```bash
# Crie arquivo .env na raiz do projeto
cat > .env << EOF
ANTHROPIC_API_KEY=sk-ant-xxxxx
OPENAI_API_KEY=sk-xxxxx       # Opcional
GEMINI_API_KEY=xxxxx           # Opcional
ELEVEN_API_KEY=xxxxx           # Opcional
EOF
```

## 🚀 Fase 1: Setup Inicial (30 minutos)

### Passo 1.1: Clone e Configure o Repositório Base

```bash
# Clone o repositório principal
git clone https://github.com/disler/claude-code-hooks-multi-agent-observability.git multi-agent-system
cd multi-agent-system

# Crie estrutura de diretórios
mkdir -p projects/{backend,frontend,testing,devops}
mkdir -p orchestrator-mcp
mkdir -p monitoring-dashboard
mkdir -p scripts
mkdir -p logs

# Estrutura final esperada:
tree -L 2
# multi-agent-system/
# ├── projects/
# │   ├── backend/
# │   ├── frontend/
# │   ├── testing/
# │   └── devops/
# ├── orchestrator-mcp/
# ├── monitoring-dashboard/
# ├── scripts/
# ├── logs/
# └── .env
```

### Passo 1.2: Instale Dependências Globais

```bash
# Instale Astral uv para gerenciamento Python
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc  # ou ~/.zshrc

# Instale Bun (se ainda não tiver)
curl -fsSL https://bun.sh/install | bash

# Instale dependências do servidor
cd apps/server
bun install

# Instale dependências do cliente
cd ../client
npm install

# Volte para raiz
cd ../..
```

### Passo 1.3: Configure Hooks Base

```bash
# Crie template de hooks para projetos
cat > .claude/hooks/requirements.txt << EOF
httpx==0.25.0
python-dotenv==1.0.0
pydantic==2.0.0
asyncio==3.4.3
EOF

# Instale dependências Python
cd .claude/hooks
uv pip install -r requirements.txt
cd ../..

# Teste instalação
uv run python -c "import httpx; print('Hooks dependencies OK')"
```

## 📦 Fase 2: Configuração do Sistema de Hooks (45 minutos)

### Passo 2.1: Configure Hooks para Cada Projeto

```bash
# Script para configurar hooks em múltiplos projetos
cat > scripts/setup-project-hooks.sh << 'EOF'
#!/bin/bash

PROJECT_NAME=$1
PROJECT_PATH=$2

if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_PATH" ]; then
    echo "Usage: ./setup-project-hooks.sh <project-name> <project-path>"
    exit 1
fi

echo "Setting up hooks for $PROJECT_NAME at $PROJECT_PATH"

# Cria estrutura .claude no projeto
mkdir -p "$PROJECT_PATH/.claude/hooks"
mkdir -p "$PROJECT_PATH/.claude/commands"

# Copia hooks base
cp -r .claude/hooks/* "$PROJECT_PATH/.claude/hooks/"

# Cria settings.json personalizado
cat > "$PROJECT_PATH/.claude/settings.json" << JSON
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/pre_tool_use.py"
          },
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type PreToolUse --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type PostToolUse --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/aggregate.py"
          },
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type SubagentStop --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type Stop --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ]
  },
  "project_name": "${PROJECT_NAME}",
  "orchestrator_url": "http://localhost:4000"
}
JSON

echo "✅ Project $PROJECT_NAME configured successfully!"
EOF

chmod +x scripts/setup-project-hooks.sh

# Configure cada projeto
./scripts/setup-project-hooks.sh "backend-api" "projects/backend"
./scripts/setup-project-hooks.sh "frontend-app" "projects/frontend"
./scripts/setup-project-hooks.sh "testing-suite" "projects/testing"
./scripts/setup-project-hooks.sh "devops-tools" "projects/devops"
```

### Passo 2.2: Teste os Hooks

```bash
# Script de teste de hooks
cat > scripts/test-hooks.sh << 'EOF'
#!/bin/bash

echo "🧪 Testing hook system..."

# Teste envio de evento
echo '{"tool": "test", "input": {"command": "echo test"}}' | \
  uv run .claude/hooks/send_event.py --event-type PreToolUse --source-app test-app

if [ $? -eq 0 ]; then
    echo "✅ Hook system is working!"
else
    echo "❌ Hook system failed. Check configuration."
    exit 1
fi
EOF

chmod +x scripts/test-hooks.sh
```

## 🎭 Fase 3: Setup do Servidor de Orquestração MCP (1 hora)

### Passo 3.1: Crie o Projeto MCP Server

```bash
cd orchestrator-mcp

# Inicialize projeto TypeScript
cat > package.json << 'EOF'
{
  "name": "orchestrator-mcp",
  "version": "1.0.0",
  "type": "module",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "better-sqlite3": "^9.0.0",
    "winston": "^3.11.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "tsx": "^4.0.0"
  }
}
EOF

# Instale dependências
bun install

# Configure TypeScript
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
```

### Passo 3.2: Implemente o MCP Server Básico

```bash
# Crie estrutura de código
mkdir -p src/{tools,prompts,services,utils}

# Crie servidor principal (simplificado)
cat > src/index.ts << 'EOF'
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

console.log("Starting Orchestrator MCP Server...");

const server = new Server(
  {
    name: 'orchestrator-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
      prompts: {},
    },
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.log("Orchestrator MCP Server is running!");
}

main().catch(console.error);
EOF

# Compile e teste
bun run build
node dist/index.js
```

### Passo 3.3: Configure o MCP no Claude Code

```bash
# Adicione ao ~/.claude/mcp-servers.json
cat > ~/.claude/mcp-servers.json << EOF
{
  "mcpServers": {
    "orchestrator": {
      "type": "stdio",
      "command": "node",
      "args": ["${PWD}/orchestrator-mcp/dist/index.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF

cd ..
```

## 🖥️ Fase 4: Setup do Dashboard de Monitoramento (1 hora)

### Passo 4.1: Configure o Servidor de Observabilidade

```bash
# Inicie servidor backend
cd apps/server

# Configure porta e ambiente
cat > .env << EOF
PORT=4000
NODE_ENV=development
DATABASE_PATH=./orchestrator.db
EOF

# Inicie servidor em modo dev
bun run dev &
SERVER_PID=$!

echo "Server running with PID: $SERVER_PID"
cd ../..
```

### Passo 4.2: Configure o Dashboard Vue

```bash
cd apps/client

# Configure ambiente do cliente
cat > .env << EOF
VITE_API_URL=http://localhost:4000
VITE_WS_URL=ws://localhost:4000/stream
VITE_MAX_EVENTS_TO_DISPLAY=1000
EOF

# Inicie cliente em modo dev
npm run dev &
CLIENT_PID=$!

echo "Client running with PID: $CLIENT_PID"
cd ../..
```

### Passo 4.3: Verifique Conectividade

```bash
# Teste API
curl http://localhost:4000/health

# Teste WebSocket
cat > scripts/test-websocket.js << 'EOF'
const WebSocket = require('ws');
const ws = new WebSocket('ws://localhost:4000/stream');

ws.on('open', () => {
  console.log('✅ WebSocket connected');
  ws.send(JSON.stringify({ type: 'ping' }));
});

ws.on('message', (data) => {
  console.log('📨 Received:', data.toString());
  ws.close();
});

ws.on('error', (err) => {
  console.error('❌ WebSocket error:', err);
});
EOF

node scripts/test-websocket.js
```

## 🎯 Fase 5: Teste Integrado do Sistema (30 minutos)

### Passo 5.1: Crie Projeto de Teste

```bash
# Crie projeto exemplo
mkdir -p projects/test-project
cd projects/test-project

# Configure hooks
../../scripts/setup-project-hooks.sh "test-project" "."

# Crie arquivo de teste
cat > test.js << 'EOF'
console.log("Test project initialized");

// Simula trabalho
async function doWork() {
  console.log("Starting work...");
  await new Promise(r => setTimeout(r, 1000));
  console.log("Work completed!");
}

doWork();
EOF
```

### Passo 5.2: Execute Teste com Claude Code

```bash
# Inicie Claude Code no projeto
claude

# No Claude Code, execute:
# > Execute o arquivo test.js e monitore os eventos
# > Use o comando: node test.js
```

### Passo 5.3: Verifique Dashboard

```bash
# Abra navegador
open http://localhost:5173

# Você deve ver:
# - Timeline de eventos em tempo real
# - Gráfico de atividade
# - Status dos agentes
# - Métricas do sistema
```

## 🚨 Fase 6: Troubleshooting Comum

### Problema 1: Hooks não disparam

```bash
# Verificação 1: Permissões
chmod +x .claude/hooks/*.py

# Verificação 2: Python path
which python
uv run which python

# Verificação 3: Debug mode
export DEBUG_HOOKS=1
claude
```

### Problema 2: WebSocket não conecta

```bash
# Verificação 1: Portas
lsof -i :4000
lsof -i :5173

# Verificação 2: Firewall
sudo ufw status

# Verificação 3: Logs
tail -f logs/server.log
```

### Problema 3: Dashboard vazio

```bash
# Verificação 1: API respondendo
curl http://localhost:4000/events/recent

# Verificação 2: Console do navegador
# F12 -> Console -> Verificar erros

# Verificação 3: Restart services
pkill -f "bun run dev"
pkill -f "npm run dev"
./scripts/start-all.sh
```

## 📊 Fase 7: Otimização para Produção

### Passo 7.1: Configure PM2 para Gerenciamento

```bash
# Instale PM2
npm install -g pm2

# Configure ecosystem
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'orchestrator-server',
      script: 'bun',
      args: 'run start',
      cwd: './apps/server',
      env: {
        NODE_ENV: 'production',
        PORT: 4000
      }
    },
    {
      name: 'monitoring-dashboard',
      script: 'serve',
      args: '-s dist -l 5173',
      cwd: './apps/client',
      env: {
        NODE_ENV: 'production'
      }
    }
  ]
};
EOF

# Inicie com PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Passo 7.2: Configure Nginx Reverse Proxy

```bash
# Instale Nginx
sudo apt-get install nginx

# Configure site
sudo cat > /etc/nginx/sites-available/multi-agent << 'EOF'
server {
    listen 80;
    server_name orchestrator.local;

    # Dashboard
    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # API
    location /api {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # WebSocket
    location /stream {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/multi-agent /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🎯 Fase 8: Workflows de Exemplo

### Workflow 1: Desenvolvimento Full-Stack Paralelo

```bash
# Crie comando de orquestração
cat > .claude/commands/develop-feature.md << 'EOF'
# Desenvolver Feature Completa

Execute desenvolvimento paralelo de feature completa:

## Fase 1: Análise (Paralela)
- Backend: Analise requisitos de API
- Frontend: Analise requisitos de UI
- Testing: Identifique cenários de teste
- DevOps: Planeje infraestrutura

## Fase 2: Implementação (Paralela)
- Backend: Implemente endpoints REST
- Frontend: Desenvolva componentes React
- Testing: Escreva testes unitários
- DevOps: Configure CI/CD

## Fase 3: Integração (Sequencial)
1. Integre frontend com backend
2. Execute suite de testes
3. Deploy em staging
4. Validação final

Use o orchestrator MCP para coordenar.
EOF
```

### Workflow 2: Análise de Código Multi-Aspecto

```bash
cat > .claude/commands/analyze-codebase.md << 'EOF'
# Análise Completa de Codebase

Execute análise paralela em múltiplos aspectos:

1. **Segurança**: Scan de vulnerabilidades
2. **Performance**: Identificar gargalos
3. **Qualidade**: Análise de code smells
4. **Documentação**: Verificar coverage
5. **Testes**: Avaliar cobertura

Agregue resultados em relatório unificado.
EOF
```

## 📈 Métricas de Sucesso

### KPIs para Validar Implementação

| Métrica | Target | Como Medir |
|---------|--------|------------|
| Latência de Hooks | < 100ms | Dashboard → Metrics |
| Eventos por Minuto | > 10 | Dashboard → Activity Pulse |
| Taxa de Sucesso | > 95% | Dashboard → Success Rate |
| Agentes Ativos | >= 2 | Dashboard → Agent Status |
| Tempo de Resposta API | < 200ms | `curl -w "%{time_total}"` |
| WebSocket Conectado | ✅ | Dashboard → Connection Icon |

## 🎓 Próximos Passos

1. **Adicione Mais Agentes**
   ```bash
   ./scripts/setup-project-hooks.sh "ml-agent" "projects/ml"
   ```

2. **Configure Alertas**
   ```bash
   # Integre com Slack/Discord para notificações
   ```

3. **Implemente Métricas Customizadas**
   ```typescript
   // Adicione métricas específicas do domínio
   ```

4. **Scale Horizontalmente**
   ```yaml
   # Use Docker Compose para múltiplas instâncias
   ```

## 📚 Recursos Adicionais

### Documentação Essencial

1. **Claude Code Hooks Official Guide**
   - URL: https://docs.anthropic.com/en/docs/claude-code/hooks-guide
   - Referência completa de hooks

2. **Model Context Protocol**
   - URL: https://modelcontextprotocol.io
   - Especificação do protocolo MCP

3. **Community Examples**
   - URL: https://github.com/disler/claude-code-hooks-mastery
   - Exemplos avançados

4. **Video Tutorials**
   - URL: https://www.youtube.com/@officialcluadecode
   - Tutoriais práticos (verificar canal)

5. **Discord Community**
   - URL: https://discord.gg/anthropic
   - Suporte da comunidade

## ✅ Checklist Final

- [ ] Servidor de observabilidade rodando na porta 4000
- [ ] Dashboard acessível na porta 5173
- [ ] Hooks configurados em pelo menos 2 projetos
- [ ] MCP Server registrado no Claude Code
- [ ] WebSocket conectando corretamente
- [ ] Eventos aparecendo no dashboard
- [ ] Teste de workflow multi-agente executado
- [ ] PM2 configurado para produção
- [ ] Backup do banco de dados configurado
- [ ] Documentação do projeto atualizada

## 🎉 Conclusão

Parabéns! Você implementou com sucesso um sistema completo de orquestração multi-agente com observabilidade em tempo real. 

**Benefícios alcançados:**
- ✅ Paralelização de tarefas com múltiplos agentes
- ✅ Visibilidade total de todas as operações
- ✅ Debugging simplificado com logs centralizados
- ✅ Métricas em tempo real para tomada de decisão
- ✅ Arquitetura escalável e extensível

**Suporte:**
- GitHub Issues: https://github.com/disler/claude-code-hooks-multi-agent-observability/issues
- Community Forum: https://community.anthropic.com

---

**Versão**: 1.0.0  
**Última Atualização**: Janeiro 2025  
**Autor**: DevOps Team
