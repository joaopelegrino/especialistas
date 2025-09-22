#!/bin/bash

# =============================================================================
# WARP TERMINAL ORCHESTRATION SCRIPT
# =============================================================================
# 
# Baseado no conceito de orquestração de múltiplos terminais com Claude CLI
# Fonte: Notebook "Orquestração de Múltiplos Terminais com Claude CLI"
# Data: 2025-09-18
# Ambiente: WSL2 Ubuntu 24.04 + Warp Terminal + Claude Code v1.0.113
#
# =============================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
PROJECT_NAME="warp-orchestration-demo"
WORKSPACE_DIR="$HOME/workspace/especialistas/warp/demo"
LOG_DIR="$WORKSPACE_DIR/logs"

# Função para log com timestamp
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Função para criar estrutura do projeto
setup_project() {
    log "${YELLOW}🏗️  Configurando estrutura do projeto...${NC}"
    
    mkdir -p "$WORKSPACE_DIR"/{src,docs,tests,build,logs}
    cd "$WORKSPACE_DIR" || exit 1
    
    log "${GREEN}✓${NC} Estrutura criada em: $WORKSPACE_DIR"
}

# Função para executar comando com Claude CLI em background
execute_claude_task() {
    local task_id=$1
    local task_name=$2
    local prompt=$3
    local output_file=$4
    
    log "${YELLOW}🤖 Terminal $task_id ($task_name):${NC} Executando com Claude CLI..."
    
    mkdir -p "$LOG_DIR/terminal_$task_id"
    
    # Executar Claude CLI
    if claude -p "$prompt" > "$output_file" 2> "$LOG_DIR/terminal_$task_id/error.log"; then
        log "${GREEN}✅${NC} Terminal $task_id: $task_name concluído → $output_file"
    else
        log "${RED}❌${NC} Terminal $task_id: Erro no $task_name (ver logs/terminal_$task_id/error.log)"
        return 1
    fi
}

# Função principal de orquestração
orchestrate() {
    log "${GREEN}🚀 Iniciando Orquestração Warp + Claude CLI${NC}"
    log "${CYAN}Projeto: $PROJECT_NAME${NC}"
    log "${CYAN}Workspace: $WORKSPACE_DIR${NC}"
    
    # Setup inicial
    setup_project
    
    log "${YELLOW}═══ FASE 1: Desenvolvimento Paralelo ═══${NC}"
    
    # Terminal 1: Frontend (HTML Dashboard)
    execute_claude_task 1 "Frontend" \
        "Create a complete HTML dashboard for project management with:
- Modern responsive design with CSS Grid/Flexbox
- Dark theme optimized for terminals
- Status cards showing project metrics
- Task list with interactive checkboxes
- Progress bars and charts
- Footer with real-time timestamp
- All CSS and JavaScript inline for single-file deployment
- Terminal-friendly color scheme (dark background, bright text)
- Mobile responsive design" \
        "$WORKSPACE_DIR/src/index.html" &
    PID1=$!
    
    # Terminal 2: Backend (Node.js API)
    execute_claude_task 2 "Backend" \
        "Create a Node.js API server with:
- Express.js framework setup
- RESTful API endpoints for project management
- CRUD operations for tasks and projects
- JSON file-based storage (no database required)
- CORS enabled for frontend integration
- Error handling middleware
- Logging functionality
- Environment variable support
- Port configuration (default 3000)
- Health check endpoint
- Documentation comments" \
        "$WORKSPACE_DIR/src/server.js" &
    PID2=$!
    
    # Terminal 3: Documentation (Comprehensive README)
    execute_claude_task 3 "Documentation" \
        "Create comprehensive project documentation with:
- Project overview and objectives
- Quick start guide
- Installation instructions for Ubuntu/WSL2
- API reference with example requests
- Frontend usage guide
- Configuration options
- Troubleshooting section
- Development workflow
- Contributing guidelines
- License information
- Deployment instructions
- Performance optimization tips" \
        "$WORKSPACE_DIR/docs/README.md" &
    PID3=$!
    
    # Terminal 4: Testing (Test Suite)
    execute_claude_task 4 "Testing" \
        "Create comprehensive test suite with:
- Unit tests for API endpoints
- Frontend functionality tests
- Integration test examples
- Mock data and fixtures
- Test utilities and helpers
- Performance tests
- Error handling tests
- Configuration for Jest or similar
- Test scripts for package.json
- CI/CD test pipeline example
- Coverage reporting setup" \
        "$WORKSPACE_DIR/tests/test-suite.js" &
    PID4=$!
    
    # Terminal 5: DevOps (Docker + Configuration)
    execute_claude_task 5 "DevOps" \
        "Create complete DevOps configuration with:
- Multi-stage Dockerfile for Node.js application
- docker-compose.yml for development environment
- Production-ready docker-compose.prod.yml
- .dockerignore file with appropriate exclusions
- Package.json with all necessary scripts
- Environment configuration (.env.example)
- PM2 ecosystem file for process management
- Nginx configuration for reverse proxy
- Health check scripts
- Backup and restore procedures
- Monitoring setup recommendations" \
        "$WORKSPACE_DIR/build/Dockerfile" &
    PID5=$!
    
    # Aguardar conclusão de todas as tarefas paralelas
    log "${CYAN}⏳ Aguardando conclusão de todos os terminais...${NC}"
    wait $PID1 $PID2 $PID3 $PID4 $PID5
    
    log "${YELLOW}═══ FASE 2: Integração e Validação ═══${NC}"
    
    # Verificar arquivos gerados
    log "${CYAN}📁 Arquivos gerados:${NC}"
    if ls -la "$WORKSPACE_DIR"/{src,docs,tests,build}/*.*  2>/dev/null; then
        log "${GREEN}✅ Todos os arquivos foram gerados com sucesso${NC}"
    else
        log "${RED}⚠️ Alguns arquivos podem não ter sido gerados${NC}"
    fi
    
    # Gerar relatório final
    generate_report
    
    log "${GREEN}🎉 Orquestração Concluída com Sucesso!${NC}"
    log "${CYAN}📊 Relatório disponível em: $WORKSPACE_DIR/logs/orchestration-report.md${NC}"
}

# Função para gerar relatório
generate_report() {
    local report_file="$LOG_DIR/orchestration-report.md"
    
    log "${YELLOW}📋 Gerando relatório de orquestração...${NC}"
    
    cat > "$report_file" << EOF
# Relatório de Orquestração Warp Terminal + Claude CLI

**Data de execução:** $(date '+%Y-%m-%d %H:%M:%S')  
**Projeto:** $PROJECT_NAME  
**Workspace:** $WORKSPACE_DIR  

## 📊 Resumo da Execução

### Terminais Orquestrados
- **Terminal 1:** Frontend (HTML Dashboard)
- **Terminal 2:** Backend (Node.js API Server) 
- **Terminal 3:** Documentation (README completo)
- **Terminal 4:** Testing (Test Suite completo)
- **Terminal 5:** DevOps (Docker + Config)

### 📁 Arquivos Gerados

$(ls -la "$WORKSPACE_DIR"/{src,docs,tests,build}/*.* 2>/dev/null | awk '{print "- **" $9 "** (" $5 " bytes) - " $6 " " $7 " " $8}')

### 📈 Estatísticas

- **Tempo total:** $(date '+%Y-%m-%d %H:%M:%S')
- **Terminais paralelos:** 5
- **Comandos Claude CLI:** 5
- **Status:** ✅ Concluído com sucesso

### 🚀 Próximos Passos

1. **Testar aplicação:**
   \`\`\`bash
   cd $WORKSPACE_DIR/src
   node server.js
   \`\`\`

2. **Visualizar dashboard:**
   \`\`\`bash
   cd $WORKSPACE_DIR/src
   python3 -m http.server 8080
   # Acessar: http://localhost:8080
   \`\`\`

3. **Executar testes:**
   \`\`\`bash
   cd $WORKSPACE_DIR
   npm test
   \`\`\`

4. **Deploy com Docker:**
   \`\`\`bash
   cd $WORKSPACE_DIR
   docker-compose up -d
   \`\`\`

### 🔍 Logs Detalhados

$(find "$LOG_DIR" -name "*.log" -type f | while read -r log_file; do
    echo "#### $(basename "$log_file")"
    echo "\`\`\`"
    tail -n 10 "$log_file" 2>/dev/null || echo "Log vazio"
    echo "\`\`\`"
    echo ""
done)

---
**Gerado automaticamente pelo Warp Terminal Orchestration Script**
EOF
    
    log "${GREEN}✅${NC} Relatório gerado: $report_file"
}

# Função para monitoramento em tempo real
monitor() {
    log "${YELLOW}📺 Iniciando monitoramento em tempo real...${NC}"
    
    while true; do
        clear
        echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}🎭 WARP TERMINAL ORCHESTRATION - STATUS EM TEMPO REAL${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}📊 Status dos Terminais:${NC}"
        echo "------------------------"
        
        for i in {1..5}; do
            if pgrep -f "claude.*terminal_$i" > /dev/null; then
                echo -e "Terminal $i: ${YELLOW}⏳ Executando...${NC}"
            elif [ -f "$LOG_DIR/terminal_$i/error.log" ] && [ -s "$LOG_DIR/terminal_$i/error.log" ]; then
                echo -e "Terminal $i: ${RED}❌ Erro detectado${NC}"
            else
                echo -e "Terminal $i: ${GREEN}✅ Concluído${NC}"
            fi
        done
        
        echo ""
        echo -e "${YELLOW}📁 Arquivos Gerados:${NC}"
        ls -lh "$WORKSPACE_DIR"/{src,docs,tests,build}/*.* 2>/dev/null | tail -5 || echo "Nenhum arquivo gerado ainda..."
        
        echo ""
        echo -e "${YELLOW}⏱️ Tempo decorrido:${NC} $(date '+%H:%M:%S')"
        echo ""
        echo -e "${CYAN}Pressione Ctrl+C para parar o monitoramento${NC}"
        
        sleep 5
    done
}

# Função para limpeza
cleanup() {
    log "${YELLOW}🧹 Limpando arquivos temporários...${NC}"
    # Adicionar limpeza se necessário
}

# Função de ajuda
show_help() {
    echo -e "${CYAN}🚀 Warp Terminal Orchestration Script${NC}"
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  orchestrate    - Executar orquestração completa (padrão)"
    echo "  monitor       - Monitoramento em tempo real"
    echo "  cleanup       - Limpar arquivos temporários"
    echo "  help          - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0                    # Executar orquestração"
    echo "  $0 orchestrate        # Executar orquestração"
    echo "  $0 monitor           # Monitorar em tempo real"
    echo ""
}

# Main - Processar argumentos
main() {
    case "${1:-orchestrate}" in
        "orchestrate")
            orchestrate
            ;;
        "monitor")
            monitor
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "Comando inválido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Trap para limpeza em caso de interrupção
trap cleanup EXIT

# Executar função principal
main "$@"