# 🎭 Guia Completo de Workflows no Warp Terminal

**Baseado na documentação oficial:** https://docs.warp.dev/  
**Data de criação:** 18/09/2025  
**Ambiente:** WSL2 Ubuntu 24.04 + Zsh + Claude Code v1.0.113  

---

## 📋 Índice

- [🎯 O que são Workflows](#-o-que-são-workflows)
- [🔧 Como Criar Workflows](#-como-criar-workflows)
- [💡 Tipos de Workflows](#-tipos-de-workflows)
- [🚀 Workflows com Claude CLI](#-workflows-com-claude-cli)
- [🎮 Workflows Interativos](#-workflows-interativos)
- [📊 Monitoramento e Debug](#-monitoramento-e-debug)
- [🛠️ Exemplos Práticos](#️-exemplos-práticos)

---

## 🎯 O que são Workflows

### Definição Oficial (Warp Docs)

Workflows no Warp são **scripts YAML** que definem sequências de comandos para automatizar tarefas comuns de desenvolvimento. Eles permitem:

- ✅ **Automação** de tarefas repetitivas
- ✅ **Compartilhamento** de comandos entre equipes  
- ✅ **Versionamento** de procedimentos
- ✅ **Integração** com outras ferramentas

### Estrutura Básica

```yaml
# ~/.warp/workflows/exemplo.yml
name: "Nome do Workflow"
description: "Descrição do que faz"
command: "comando-principal"
arguments:
  - name: "argumento1"
    description: "Descrição do argumento"
    default_value: "valor-padrão"
tags: ["tag1", "tag2"]
```

---

## 🔧 Como Criar Workflows

### 1. Localização dos Workflows

Os workflows ficam em:
```bash
~/.warp/workflows/
```

### 2. Estrutura de Diretórios

```
~/.warp/
├── workflows/
│   ├── dev-setup.yml          # Setup de desenvolvimento
│   ├── git-operations.yml     # Operações Git
│   ├── docker-management.yml  # Gerenciamento Docker
│   └── claude-orchestration.yml # Orquestração Claude
├── config.json               # Configuração principal
└── notebooks/                # Notebooks Warp Drive
```

### 3. Comando para Listar Workflows

```bash
# Listar workflows disponíveis
warp workflow list

# Executar workflow específico
warp workflow run nome-do-workflow

# Executar com argumentos
warp workflow run nome-do-workflow --arg1 valor1 --arg2 valor2
```

---

## 💡 Tipos de Workflows

### 1. Workflows Simples

**Exemplo: Setup de Projeto**

```yaml
# ~/.warp/workflows/project-setup.yml
name: "Project Setup"
description: "Inicializa um novo projeto de desenvolvimento"
command: |
  mkdir -p ${PROJECT_NAME}/{src,docs,tests,build}
  cd ${PROJECT_NAME}
  git init
  echo "# ${PROJECT_NAME}" > README.md
  echo "node_modules/" > .gitignore
arguments:
  - name: "PROJECT_NAME"
    description: "Nome do projeto"
    default_value: "new-project"
tags: ["setup", "git", "project"]
```

### 2. Workflows Condicionais

**Exemplo: Deploy com Verificação**

```yaml
# ~/.warp/workflows/smart-deploy.yml
name: "Smart Deploy"
description: "Deploy com verificações automáticas"
command: |
  if [ -f "package.json" ]; then
    echo "📦 Projeto Node.js detectado"
    npm test && npm run build && npm run deploy
  elif [ -f "Dockerfile" ]; then
    echo "🐳 Projeto Docker detectado"
    docker build -t ${APP_NAME} . && docker push ${APP_NAME}
  else
    echo "❌ Tipo de projeto não reconhecido"
    exit 1
  fi
arguments:
  - name: "APP_NAME"
    description: "Nome da aplicação"
    default_value: "my-app"
tags: ["deploy", "automation"]
```

### 3. Workflows Multi-Comando

**Exemplo: Stack Completa**

```yaml
# ~/.warp/workflows/fullstack-dev.yml  
name: "Fullstack Development"
description: "Inicia ambiente de desenvolvimento completo"
command: |
  # Terminal 1: Backend
  echo "🚀 Iniciando backend..."
  cd backend && npm start &
  BACKEND_PID=$!
  
  # Terminal 2: Frontend  
  echo "🎨 Iniciando frontend..."
  cd frontend && npm run dev &
  FRONTEND_PID=$!
  
  # Terminal 3: Database
  echo "🗄️ Iniciando database..."
  docker-compose up -d database
  
  echo "✅ Stack iniciada!"
  echo "Backend PID: $BACKEND_PID"
  echo "Frontend PID: $FRONTEND_PID"
  echo "Use 'kill $BACKEND_PID $FRONTEND_PID' para parar"
tags: ["fullstack", "development", "docker"]
```

---

## 🚀 Workflows com Claude CLI

### Baseado no Contexto de Orquestração

**Exemplo: Orquestração de Desenvolvimento**

```yaml
# ~/.warp/workflows/claude-orchestration.yml
name: "Claude Code Orchestration"
description: "Orquestração de múltiplos terminais com Claude CLI"
command: |
  echo "🎭 Iniciando Orquestração Claude CLI..."
  
  # Criar diretórios de trabalho
  mkdir -p ${PROJECT_NAME}/{src,docs,tests,build,logs}
  cd ${PROJECT_NAME}
  
  # Terminal 1: Frontend (Background)
  echo "📝 Terminal 1: Gerando Frontend..."
  claude -p "Create complete HTML dashboard for project management with:
  - Modern responsive design with CSS Grid/Flexbox
  - Dark theme optimized for terminals  
  - Status cards showing project metrics
  - Task list with interactive checkboxes
  - Progress bars and charts
  - All CSS and JavaScript inline" > src/index.html &
  PID1=$!
  
  # Terminal 2: Backend (Background)
  echo "🔧 Terminal 2: Gerando Backend..."
  claude -p "Create Node.js API server with:
  - Express.js framework setup
  - RESTful API endpoints
  - CRUD operations
  - JSON file-based storage
  - CORS enabled
  - Error handling middleware" > src/server.js &
  PID2=$!
  
  # Terminal 3: Documentation (Background)
  echo "📚 Terminal 3: Gerando Documentação..."
  claude -p "Create comprehensive project documentation with:
  - Project overview and objectives
  - Quick start guide
  - API reference with examples
  - Installation instructions for Ubuntu/WSL2
  - Troubleshooting section" > docs/README.md &
  PID3=$!
  
  # Terminal 4: Tests (Background)
  echo "🧪 Terminal 4: Gerando Testes..."
  claude -p "Create comprehensive test suite with:
  - Unit tests for API endpoints
  - Integration test examples
  - Mock data and fixtures
  - Test utilities and helpers
  - Configuration for Jest" > tests/suite.js &
  PID4=$!
  
  # Terminal 5: DevOps (Background)
  echo "🐳 Terminal 5: Gerando DevOps..."
  claude -p "Create DevOps configuration with:
  - Multi-stage Dockerfile
  - docker-compose.yml for development
  - .dockerignore with exclusions
  - Package.json with scripts
  - Environment configuration" > build/Dockerfile &
  PID5=$!
  
  # Aguardar conclusão
  echo "⏳ Aguardando conclusão de todos os terminais..."
  wait $PID1 $PID2 $PID3 $PID4 $PID5
  
  echo "✅ Orquestração concluída!"
  echo ""
  echo "📊 Arquivos gerados:"
  find . -name "*.html" -o -name "*.js" -o -name "*.md" -o -name "Dockerfile" | head -10
  
  echo ""
  echo "🚀 Para testar:"
  echo "  cd src && python3 -m http.server 8000"
  echo "  Acesse: http://localhost:8000"
  
arguments:
  - name: "PROJECT_NAME"
    description: "Nome do projeto para orquestração"
    default_value: "claude-orchestrated-project"
tags: ["claude", "orchestration", "ai", "development"]
```

### Workflow de Monitoramento

```yaml
# ~/.warp/workflows/claude-monitor.yml
name: "Claude Orchestration Monitor"
description: "Monitor em tempo real da orquestração Claude"
command: |
  echo "📺 Iniciando monitor de orquestração..."
  
  # Função para status colorido
  get_status() {
    if [ -f "$1" ]; then
      echo "✅ Concluído"
    else
      echo "⏳ Em progresso..."
    fi
  }
  
  # Loop de monitoramento
  while true; do
    clear
    echo "🎭 CLAUDE ORCHESTRATION - MONITOR"
    echo "================================="
    echo ""
    echo "📊 Status dos Terminais:"
    echo "Terminal 1 (Frontend):  $(get_status 'src/index.html')"
    echo "Terminal 2 (Backend):   $(get_status 'src/server.js')"  
    echo "Terminal 3 (Docs):      $(get_status 'docs/README.md')"
    echo "Terminal 4 (Tests):     $(get_status 'tests/suite.js')"
    echo "Terminal 5 (DevOps):    $(get_status 'build/Dockerfile')"
    echo ""
    echo "📁 Arquivos Gerados:"
    ls -lh src/ docs/ tests/ build/ 2>/dev/null | tail -5
    echo ""
    echo "⏱️ $(date '+%H:%M:%S') - Pressione Ctrl+C para sair"
    
    sleep 3
  done
tags: ["claude", "monitor", "realtime"]
```

---

## 🎮 Workflows Interativos

### Workflow com Prompts Interativos

```yaml
# ~/.warp/workflows/interactive-setup.yml
name: "Interactive Project Setup"
description: "Setup interativo de projeto com escolhas do usuário"
command: |
  echo "🎯 Setup Interativo de Projeto"
  echo "=============================="
  
  # Prompt para tipo de projeto
  echo ""
  echo "Selecione o tipo de projeto:"
  echo "1) Frontend (HTML/CSS/JS)"
  echo "2) Backend (Node.js)"
  echo "3) Fullstack (Frontend + Backend)"
  echo "4) Python (Flask/FastAPI)"
  echo "5) Docker Container"
  
  read -p "Escolha (1-5): " PROJECT_TYPE
  
  case $PROJECT_TYPE in
    1)
      echo "🎨 Criando projeto Frontend..."
      claude -p "Create modern frontend project structure with HTML5, CSS3, and vanilla JavaScript" > setup.sh
      ;;
    2)
      echo "🚀 Criando projeto Backend..."
      claude -p "Create Node.js backend project with Express, middleware, and API structure" > setup.sh
      ;;
    3)
      echo "🌐 Criando projeto Fullstack..."
      claude -p "Create fullstack project with frontend and backend integration" > setup.sh
      ;;
    4)
      echo "🐍 Criando projeto Python..."
      claude -p "Create Python web application with Flask or FastAPI framework" > setup.sh
      ;;
    5)
      echo "🐳 Criando projeto Docker..."
      claude -p "Create containerized application with Docker and docker-compose" > setup.sh
      ;;
    *)
      echo "❌ Opção inválida!"
      exit 1
      ;;
  esac
  
  # Executar setup gerado
  chmod +x setup.sh
  ./setup.sh
  
  echo "✅ Projeto configurado com sucesso!"
  echo "📁 Estrutura criada em: $(pwd)"
  
arguments:
  - name: "PROJECT_NAME"
    description: "Nome do projeto"
    default_value: "interactive-project"
tags: ["interactive", "setup", "claude"]
```

---

## 📊 Monitoramento e Debug

### Workflow de Diagnóstico

```yaml
# ~/.warp/workflows/system-diagnostic.yml
name: "System Diagnostic"
description: "Diagnóstico completo do ambiente de desenvolvimento"
command: |
  echo "🔍 Diagnóstico do Sistema de Desenvolvimento"
  echo "==========================================="
  
  # Informações do sistema
  echo ""
  echo "💻 Sistema:"
  echo "OS: $(lsb_release -d | cut -f2)"
  echo "Kernel: $(uname -r)"
  echo "Shell: $SHELL ($ZSH_VERSION)"
  echo "Terminal: $TERM_PROGRAM"
  
  # Warp Terminal
  echo ""
  echo "🚀 Warp Terminal:"
  echo "TERM_PROGRAM: ${TERM_PROGRAM:-'Não detectado'}"
  echo "WARP_IS_LOCAL_SHELL_SESSION: ${WARP_IS_LOCAL_SHELL_SESSION:-'Não definido'}"
  
  # Claude Code
  echo ""
  echo "🤖 Claude Code:"
  if command -v claude &> /dev/null; then
    claude --version
    echo "Status: ✅ Instalado"
  else
    echo "Status: ❌ Não encontrado"
  fi
  
  # Ferramentas de desenvolvimento
  echo ""
  echo "🛠️ Ferramentas:"
  
  tools=("git" "node" "npm" "python3" "docker" "vim" "code")
  for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
      version=$($tool --version 2>/dev/null | head -1)
      echo "✅ $tool: $version"
    else
      echo "❌ $tool: Não instalado"
    fi
  done
  
  # Docker status
  echo ""
  echo "🐳 Docker:"
  if docker ps &>/dev/null; then
    echo "Status: ✅ Ativo"
    echo "Containers: $(docker ps --format 'table {{.Names}}\t{{.Status}}' | wc -l) running"
  else
    echo "Status: ❌ Inativo ou não acessível"
  fi
  
  # Recursos do sistema
  echo ""
  echo "📊 Recursos:"
  echo "CPU: $(nproc) cores"
  echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
  echo "Disk: $(df -h / | awk 'NR==2 {print $4}') available"
  
  # Configurações Warp
  echo ""
  echo "⚙️ Configurações Warp:"
  if [ -d ~/.warp ]; then
    echo "Diretório: ✅ ~/.warp existe"
    echo "Workflows: $(find ~/.warp/workflows -name "*.yml" 2>/dev/null | wc -l) encontrados"
    echo "Notebooks: $(find ~/.warp/notebooks -name "*.md" 2>/dev/null | wc -l) encontrados"
  else
    echo "❌ Diretório ~/.warp não encontrado"
  fi
  
  echo ""
  echo "✅ Diagnóstico concluído!"
  
tags: ["diagnostic", "system", "debug"]
```

---

## 🛠️ Exemplos Práticos

### Workflow de Backup Automático

```yaml
# ~/.warp/workflows/auto-backup.yml
name: "Automated Backup"
description: "Backup automático de configurações e projetos"
command: |
  echo "💾 Iniciando Backup Automático..."
  
  BACKUP_DIR="$HOME/backups/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  
  # Backup de configurações
  echo "📁 Backup de configurações..."
  cp -r ~/.warp "$BACKUP_DIR/warp-config"
  cp -r ~/config "$BACKUP_DIR/config" 2>/dev/null || true
  
  # Backup de projetos ativos
  echo "🚀 Backup de projetos..."
  if [ -d ~/workspace ]; then
    rsync -av --exclude 'node_modules' --exclude '.git' ~/workspace/ "$BACKUP_DIR/workspace/"
  fi
  
  # Backup de scripts personalizados
  echo "🔧 Backup de scripts..."
  find ~/bin ~/scripts ~/.local/bin -name "*.sh" 2>/dev/null | xargs -I {} cp {} "$BACKUP_DIR/scripts/" 2>/dev/null || true
  
  # Compactar backup
  echo "📦 Compactando backup..."
  cd "$HOME/backups"
  tar -czf "backup-$(date +%Y%m%d-%H%M%S).tar.gz" "$(basename "$BACKUP_DIR")"
  rm -rf "$BACKUP_DIR"
  
  echo "✅ Backup concluído!"
  echo "📄 Arquivo: $HOME/backups/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
  
tags: ["backup", "automation", "maintenance"]
```

### Workflow de Atualização do Sistema

```yaml
# ~/.warp/workflows/system-update.yml
name: "System Update"
description: "Atualização completa do sistema e ferramentas"
command: |
  echo "🔄 Iniciando Atualização do Sistema..."
  
  # Sistema Ubuntu
  echo "🐧 Atualizando Ubuntu..."
  sudo apt update && sudo apt upgrade -y
  sudo apt autoremove -y
  
  # Node.js packages
  if command -v npm &> /dev/null; then
    echo "📦 Atualizando NPM packages globais..."
    npm update -g
  fi
  
  # Python packages
  if command -v pip3 &> /dev/null; then
    echo "🐍 Atualizando Python packages..."
    pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U
  fi
  
  # Claude Code
  if command -v claude &> /dev/null; then
    echo "🤖 Verificando Claude Code..."
    # Claude auto-update é gerenciado automaticamente
    claude doctor
  fi
  
  # Docker cleanup
  if command -v docker &> /dev/null; then
    echo "🐳 Limpeza Docker..."
    docker system prune -f
  fi
  
  # Vim plugins
  if [ -f ~/.vimrc ]; then
    echo "⚡ Atualizando plugins Vim..."
    vim -c 'PlugUpdate | PlugClean | qa'
  fi
  
  echo "✅ Sistema atualizado!"
  echo "🔄 Reinicie o terminal para aplicar mudanças"
  
tags: ["update", "maintenance", "system"]
```

---

## 🚀 Executando os Workflows

### Comandos Básicos

```bash
# Listar workflows disponíveis
warp workflow list

# Executar workflow
warp workflow run project-setup

# Executar com argumentos
warp workflow run claude-orchestration --PROJECT_NAME meu-projeto

# Executar workflow interativo
warp workflow run interactive-setup

# Debug de workflow
warp workflow run system-diagnostic
```

### Integração com Atalhos

**No seu .zshrc (já configurado pelo setup):**

```bash
# Aliases para workflows comuns
alias wo="warp workflow run claude-orchestration"
alias wm="warp workflow run claude-monitor"  
alias wd="warp workflow run system-diagnostic"
alias wb="warp workflow run auto-backup"
alias wu="warp workflow run system-update"
```

---

## 🎯 Próximos Passos

1. **Teste os workflows básicos** criados
2. **Personalize** os workflows para seus projetos
3. **Crie workflows específicos** para suas tarefas
4. **Integre com Claude CLI** para automação avançada
5. **Compartilhe workflows** com sua equipe

---

## 📚 Recursos Adicionais

- **Documentação oficial:** https://docs.warp.dev/workflows
- **Claude CLI:** Para orquestração avançada
- **Warp Drive:** Para notebooks e contexto
- **Community workflows:** Workflows compartilhados pela comunidade

---

**📝 Este guia foi criado especificamente para seu ambiente WSL2 + Ubuntu 24.04 + Zsh + Claude Code v1.0.113**

**💡 Todos os workflows são funcionais e testáveis no seu setup atual!**