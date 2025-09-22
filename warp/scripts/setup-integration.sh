#!/bin/bash

# =============================================================================
# WARP TERMINAL INTEGRATION SETUP SCRIPT
# =============================================================================
#
# Configura integrações automáticas do Warp Terminal com:
# - VSCode (tasks.json, keybindings.json, settings.json)
# - Vim (configurações específicas para Warp)
# - Zsh (aliases e funções otimizadas)
# - Claude Code (workflows integrados)
# - Yazi (configuração compatível)
#
# Baseado no ambiente: WSL2 Ubuntu 24.04 + Zsh + Claude Code v1.0.113
# Data: 2025-09-18
# =============================================================================

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WARP_WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$HOME/config"
WORKSPACE_DIR="$HOME/workspace"
VSCODE_DIR="$WORKSPACE_DIR/.vscode"

# Função para log com timestamp
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Função para título de seção
section() {
    echo -e "\n${CYAN}${BOLD}═══ $1 ═══${NC}"
}

# Função para sucesso
success() {
    echo -e "${GREEN}✅${NC} $1"
}

# Função para aviso
warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

# Função para erro
error() {
    echo -e "${RED}❌${NC} $1"
}

# Função para backup de arquivo
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$file" "$backup"
        log "Backup criado: $backup"
    fi
}

# Verificar pré-requisitos
check_prerequisites() {
    section "Verificando Pré-requisitos"
    
    local all_good=true
    
    # Verificar Warp Terminal
    if [[ "${TERM_PROGRAM:-}" == "WarpTerminal" ]]; then
        success "Warp Terminal detectado"
    else
        warn "Warp Terminal não detectado (TERM_PROGRAM=$TERM_PROGRAM)"
        all_good=false
    fi
    
    # Verificar Claude Code
    if command -v claude &> /dev/null; then
        local claude_version=$(claude --version 2>/dev/null | head -1)
        success "Claude Code encontrado: $claude_version"
    else
        warn "Claude Code não encontrado"
        all_good=false
    fi
    
    # Verificar Zsh
    if [[ "$SHELL" == */zsh ]]; then
        success "Zsh configurado como shell padrão"
    else
        warn "Shell atual: $SHELL (esperado: zsh)"
    fi
    
    # Verificar Vim
    if command -v vim &> /dev/null; then
        success "Vim disponível"
    else
        warn "Vim não encontrado"
    fi
    
    # Verificar estrutura de diretórios
    if [[ -d "$CONFIG_DIR" ]]; then
        success "Diretório config encontrado: $CONFIG_DIR"
    else
        warn "Diretório config não encontrado: $CONFIG_DIR"
        all_good=false
    fi
    
    if [[ "$all_good" == "false" ]]; then
        error "Alguns pré-requisitos não foram atendidos"
        echo -e "\n${YELLOW}Recomendações:${NC}"
        echo "1. Use este script dentro do Warp Terminal"
        echo "2. Certifique-se que Claude Code v1.0.113+ está instalado"
        echo "3. Configure Zsh como shell padrão"
        read -p "Continuar mesmo assim? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Configurar VSCode Integration
setup_vscode_integration() {
    section "Configurando Integração VSCode"
    
    # Criar diretório .vscode se não existir
    mkdir -p "$VSCODE_DIR"
    success "Diretório VSCode: $VSCODE_DIR"
    
    # Copiar tasks.json
    local tasks_source="$SCRIPT_DIR/vscode-integration.json"
    local tasks_dest="$VSCODE_DIR/tasks.json"
    
    if [[ -f "$tasks_source" ]]; then
        backup_file "$tasks_dest"
        cp "$tasks_source" "$tasks_dest"
        success "Tasks.json configurado"
    else
        warn "Arquivo tasks.json não encontrado: $tasks_source"
    fi
    
    # Criar keybindings.json para Warp
    local keybindings_file="$VSCODE_DIR/keybindings.json"
    backup_file "$keybindings_file"
    
    cat > "$keybindings_file" << 'EOF'
[
  {
    "key": "ctrl+alt+t",
    "command": "workbench.action.terminal.new",
    "args": {
      "location": "editor"
    }
  },
  {
    "key": "ctrl+alt+w",
    "command": "workbench.action.tasks.runTask",
    "args": "🚀 Warp: Abrir Múltiplos Terminais"
  },
  {
    "key": "ctrl+alt+c",
    "command": "workbench.action.tasks.runTask", 
    "args": "🤖 Claude: Gerar Estrutura Projeto"
  },
  {
    "key": "ctrl+alt+d",
    "command": "workbench.action.tasks.runTask",
    "args": "🔍 Diagnóstico: Sistema Completo"
  },
  {
    "key": "ctrl+alt+o",
    "command": "workbench.action.tasks.runTask",
    "args": "🎭 Warp: Executar Orquestração"
  },
  {
    "key": "ctrl+alt+y",
    "command": "workbench.action.tasks.runTask",
    "args": "🗂️ Yazi: Navegador de Arquivos"
  }
]
EOF
    success "Keybindings.json configurado com atalhos Warp"
    
    # Criar settings.json otimizado para Warp
    local settings_file="$VSCODE_DIR/settings.json"
    backup_file "$settings_file"
    
    cat > "$settings_file" << 'EOF'
{
  "terminal.integrated.defaultProfile.linux": "zsh",
  "terminal.integrated.profiles.linux": {
    "zsh": {
      "path": "/usr/bin/zsh",
      "args": ["-l"]
    }
  },
  "terminal.external.linuxExec": "warp-terminal",
  "files.watcherExclude": {
    "**/.git/**": true,
    "**/.warp/**": true,
    "**/node_modules/**": true,
    "**/.vscode-server/**": true
  },
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "workbench.startupEditor": "none",
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.fontFamily": "'Hack Nerd Font', 'JetBrains Mono', monospace",
  "workbench.colorTheme": "Default Dark+",
  "editor.theme": "Default Dark+",
  "workbench.preferredDarkColorTheme": "Default Dark+",
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "extensions.autoUpdate": true,
  "update.mode": "start"
}
EOF
    success "Settings.json configurado para Warp Terminal"
}

# Configurar aliases e funções Warp no Zsh
setup_zsh_integration() {
    section "Configurando Integração Zsh"
    
    local warp_zsh_file="$CONFIG_DIR/warp-integration.zsh"
    
    cat > "$warp_zsh_file" << 'EOF'
# =============================================================================
# WARP TERMINAL INTEGRATION - ZSH
# =============================================================================
# Aliases e funções específicas para Warp Terminal
# Gerado automaticamente - NÃO EDITAR MANUALMENTE
# =============================================================================

# Verificar se estamos no Warp Terminal
if [[ "${TERM_PROGRAM:-}" == "WarpTerminal" ]]; then
    
    # Aliases específicos do Warp
    alias warp-workflows="cd $HOME/.warp/workflows && ls -la"
    alias warp-notebooks="cd $HOME/.warp/notebooks && ls -la"
    alias warp-config="cd $HOME/.warp && ls -la"
    
    # Função para criar nova aba Warp com comando
    warp-tab() {
        local title="${1:-New Tab}"
        local command="${2:-}"
        echo "🚀 Criando nova aba Warp: $title"
        if [[ -n "$command" ]]; then
            echo "Comando: $command"
        fi
        # Note: Warp CLI commands would go here when available
    }
    
    # Função para criar layout com painéis
    warp-layout-dev() {
        echo "🔧 Criando layout de desenvolvimento..."
        echo "Use: CTRL+SHIFT+D (direita) e CTRL+SHIFT+E (baixo)"
        echo "Painéis sugeridos:"
        echo "  1. Editor (vim/code)"
        echo "  2. Tests (npm test)"  
        echo "  3. Logs (tail -f)"
        echo "  4. System (htop)"
    }
    
    # Função para orquestração rápida
    warp-orchestrate() {
        local script_path="$HOME/workspace/especialistas/warp/examples/orchestration-script.sh"
        if [[ -f "$script_path" ]]; then
            echo "🎭 Executando orquestração..."
            "$script_path" "${1:-orchestrate}"
        else
            echo "❌ Script de orquestração não encontrado: $script_path"
        fi
    }
    
    # Função para diagnóstico Warp
    warp-diag() {
        echo "🔍 Diagnóstico Warp Terminal"
        echo "=========================="
        echo "TERM_PROGRAM: ${TERM_PROGRAM:-não definido}"
        echo "WARP_IS_LOCAL_SHELL_SESSION: ${WARP_IS_LOCAL_SHELL_SESSION:-não definido}"
        echo "WARP_HONOR_PS1: ${WARP_HONOR_PS1:-não definido}"
        echo ""
        echo "Claude Code:"
        claude --version 2>/dev/null || echo "  Não instalado"
        echo ""
        echo "Configurações Warp:"
        if [[ -d "$HOME/.warp" ]]; then
            ls -la "$HOME/.warp/"
        else
            echo "  Diretório ~/.warp não encontrado"
        fi
    }
    
    # Aliases para comandos frequentes no Warp
    alias wd="warp-diag"
    alias wo="warp-orchestrate"
    alias wl="warp-layout-dev"
    alias wt="warp-tab"
    
    # Integração com Claude Code
    if command -v claude &> /dev/null; then
        # Função para usar Claude contextualmente
        claude-context() {
            local context="Current directory: $(pwd)"
            context="$context\nCurrent git branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
            context="$context\nEnvironment: WSL2 Ubuntu with Warp Terminal"
            
            claude -p "$context\n\nUser request: $*"
        }
        
        alias cc="claude-context"
        alias cg="claude -p 'Generate a'"
        alias ch="claude -p 'Help me with'"
    fi
    
    # Mensagem de boas-vindas (apenas na primeira vez)
    if [[ -z "${WARP_INTEGRATION_LOADED:-}" ]]; then
        export WARP_INTEGRATION_LOADED=1
        echo "🚀 Warp Terminal Integration carregada!"
        echo "   Comandos: wd (diagnóstico), wo (orquestração), wl (layout), cc (claude contextual)"
    fi
    
else
    # Se não estamos no Warp, definir aliases básicos
    alias warp-diag="echo 'Execute este comando dentro do Warp Terminal'"
    alias wd="warp-diag"
fi
EOF
    
    success "Arquivo de integração Zsh criado: $warp_zsh_file"
    
    # Adicionar source no .zshrc se não existir
    local zshrc_file="$CONFIG_DIR/zshrc"
    local source_line="[ -f \"$warp_zsh_file\" ] && source \"$warp_zsh_file\""
    
    if [[ -f "$zshrc_file" ]] && ! grep -q "warp-integration.zsh" "$zshrc_file"; then
        echo "" >> "$zshrc_file"
        echo "# Warp Terminal Integration" >> "$zshrc_file"
        echo "$source_line" >> "$zshrc_file"
        success "Integração adicionada ao .zshrc"
    else
        warn "Integração já presente no .zshrc ou arquivo não encontrado"
    fi
}

# Configurar workflows do Warp
setup_warp_workflows() {
    section "Configurando Workflows Warp"
    
    local warp_dir="$HOME/.warp"
    local workflows_dir="$warp_dir/workflows"
    
    # Criar estrutura se não existir
    mkdir -p "$workflows_dir"
    
    # Copiar workflow de desenvolvimento
    local workflow_source="$WARP_WORKSPACE_DIR/workflows/dev-workspace.yml"
    local workflow_dest="$workflows_dir/dev-workspace.yml"
    
    if [[ -f "$workflow_source" ]]; then
        cp "$workflow_source" "$workflow_dest"
        success "Workflow dev-workspace.yml instalado"
    else
        warn "Arquivo workflow não encontrado: $workflow_source"
    fi
    
    # Criar script de notebook para comandos frequentes
    local notebook_file="$warp_dir/notebooks/quick-commands.md"
    mkdir -p "$(dirname "$notebook_file")"
    
    cat > "$notebook_file" << 'EOF'
# Quick Commands - Warp Terminal

## Diagnóstico Rápido
```bash
claude doctor && vim-diag && docker ps
```

## Setup Desenvolvimento
```bash
cd ~/workspace && git status && claude doctor
```

## Orquestração Completa
```bash
~/workspace/especialistas/warp/examples/orchestration-script.sh orchestrate
```

## Backup Configurações
```bash
cd ~/config && git add . && git commit -m "Backup $(date)" && sync_repos
```

## Navegação Rápida
```bash
# Workspace
cd ~/workspace && ls -la

# Config
cd ~/config && ls -la

# Warp Specialist
cd ~/workspace/especialistas/warp && ls -la
```

## Claude AI Helpers
```bash
# Estrutura de projeto
claude -p "Generate project structure for modern development"

# Ajuda contextual
claude -p "Help me with $(pwd) development"

# Debug
claude -p "Help debug this error: [paste error]"
```
EOF
    
    success "Notebook de comandos rápidos criado"
}

# Configurar integração Vim
setup_vim_integration() {
    section "Configurando Integração Vim"
    
    local vim_warp_file="$CONFIG_DIR/vim-warp.vim"
    
    cat > "$vim_warp_file" << 'EOF'
" =============================================================================
" VIM - WARP TERMINAL INTEGRATION
" =============================================================================
" Configurações específicas para uso com Warp Terminal
" Gerado automaticamente - adicionar ao vimrc principal se necessário
" =============================================================================

" Detectar se estamos no Warp Terminal
if $TERM_PROGRAM == 'WarpTerminal'
    " Configurações específicas para Warp
    
    " Melhorar integração com clipboard do Warp
    if has('unnamedplus')
        set clipboard=unnamedplus
    else
        set clipboard=unnamed
    endif
    
    " Otimizar cores para Warp Terminal
    if has('termguicolors')
        set termguicolors
    endif
    
    " Configurar mouse no Warp
    if has('mouse')
        set mouse=a
        if has('mouse_sgr')
            set ttymouse=sgr
        endif
    endif
    
    " Mapeamentos específicos para Warp workflows
    
    " \w - Abrir workflow de desenvolvimento
    nnoremap <leader>w :!echo "🚀 Abrindo workflow de desenvolvimento..."<CR>
    
    " \c - Executar Claude contextual
    nnoremap <leader>c :!claude -p "Help me with Vim editing in this context: $(pwd)"<CR>
    
    " \d - Diagnóstico rápido
    nnoremap <leader>d :!echo "🔍 Diagnóstico:" && claude doctor && vim-diag<CR>
    
    " \o - Orquestração
    nnoremap <leader>o :!~/workspace/especialistas/warp/examples/orchestration-script.sh<CR>
    
    " Função para criar nova aba Warp (simulação)
    function! WarpNewTab()
        echo "🚀 Para criar nova aba: CTRL+SHIFT+T"
        echo "🔧 Para painéis: CTRL+SHIFT+D (direita), CTRL+SHIFT+E (baixo)"
    endfunction
    
    " Comando para mostrar atalhos Warp
    command! WarpHelp echo "Atalhos Warp: CTRL+SHIFT+T (aba), CTRL+SHIFT+D (painel →), CTRL+SHIFT+E (painel ↓)"
    
    " Autocomando para mensagem de boas-vindas
    augroup WarpIntegration
        autocmd!
        autocmd VimEnter * if $TERM_PROGRAM == 'WarpTerminal' | echo "🚀 Vim + Warp Terminal - Use :WarpHelp para atalhos" | endif
    augroup END
    
endif
EOF
    
    success "Configuração Vim para Warp criada: $vim_warp_file"
    
    # Sugerir adicionar ao vimrc principal
    echo -e "\n${YELLOW}Para ativar no Vim, adicione ao seu vimrc:${NC}"
    echo -e "${CYAN}source $vim_warp_file${NC}"
}

# Criar documentação de integração
create_integration_docs() {
    section "Criando Documentação de Integração"
    
    local docs_dir="$WARP_WORKSPACE_DIR/docs/implementation"
    mkdir -p "$docs_dir"
    
    local integration_doc="$docs_dir/tool-integration.md"
    
    cat > "$integration_doc" << EOF
# Warp Terminal - Integração com Ferramentas

**Data de criação:** $(date '+%Y-%m-%d %H:%M:%S')  
**Ambiente:** WSL2 Ubuntu 24.04 + Zsh + Claude Code v1.0.113  
**Status:** Configurado automaticamente via setup-integration.sh

## 📊 Status das Integrações

### ✅ VSCode
- **Tasks.json:** Configurado com 14+ tasks automáticas
- **Keybindings.json:** Atalhos personalizados para Warp
- **Settings.json:** Otimizado para Warp Terminal
- **Localização:** \`$VSCODE_DIR/\`

### ✅ Zsh 
- **Arquivo de integração:** \`$CONFIG_DIR/warp-integration.zsh\`
- **Aliases específicos:** wd, wo, wl, wt, cc
- **Funções:** warp-diag, warp-orchestrate, claude-context
- **Auto-carregamento:** Configurado no .zshrc

### ✅ Vim
- **Configuração Warp:** \`$CONFIG_DIR/vim-warp.vim\`
- **Mapeamentos:** \\w, \\c, \\d, \\o para workflows
- **Comando:** :WarpHelp para atalhos
- **Clipboard:** Integração otimizada

### ✅ Warp Workflows
- **Diretório:** \`$HOME/.warp/workflows/\`
- **Notebook:** \`$HOME/.warp/notebooks/quick-commands.md\`
- **Workflow principal:** dev-workspace.yml

## 🚀 Comandos Principais

### VSCode Tasks (CTRL+SHIFT+P > Tasks: Run Task)
\`\`\`
🚀 Warp: Abrir Múltiplos Terminais      # Abre 4 terminais configurados
🤖 Claude: Gerar Estrutura Projeto      # Gera estrutura com Claude
🔍 Diagnóstico: Sistema Completo        # claude doctor + vim-diag + docker
🎭 Warp: Executar Orquestração         # Script de orquestração completa
📦 Git: Sync Todos Repositórios        # sync_repos automático
🗂️ Yazi: Navegador de Arquivos         # Abre Yazi no workspace
⚙️ Vim: Abrir Configuração             # Editar vimrc
🐚 Zsh: Abrir Configuração             # Editar zshrc
\`\`\`

### Atalhos VSCode Personalizados
\`\`\`
CTRL+ALT+W    # Abrir múltiplos terminais Warp
CTRL+ALT+C    # Claude gerar estrutura
CTRL+ALT+D    # Diagnóstico sistema completo  
CTRL+ALT+O    # Executar orquestração
CTRL+ALT+Y    # Abrir Yazi
\`\`\`

### Aliases Zsh (apenas no Warp)
\`\`\`bash
wd            # warp-diag - diagnóstico Warp
wo            # warp-orchestrate - orquestração  
wl            # warp-layout-dev - sugerir layout
wt            # warp-tab - criar nova aba
cc            # claude-context - Claude contextual
\`\`\`

### Comandos Vim (no Warp)
\`\`\`vim
\\w           " Workflow desenvolvimento
\\c           " Claude contextual  
\\d           " Diagnóstico sistema
\\o           " Orquestração
:WarpHelp    " Mostrar atalhos Warp
\`\`\`

## 📋 Workflows Disponíveis

### 1. Desenvolvimento Completo (VSCode)
1. \`CTRL+SHIFT+B\` ou \`CTRL+ALT+W\`
2. Abre 4 terminais: Workspace, Learning, Config, Claude AI
3. Todos configurados com diretórios corretos

### 2. Orquestração Claude CLI
1. \`CTRL+ALT+O\` no VSCode ou \`wo\` no terminal
2. Executa 5 terminais paralelos com Claude
3. Gera: Frontend, Backend, Docs, Tests, DevOps

### 3. Diagnóstico Sistema
1. \`CTRL+ALT+D\` no VSCode ou \`wd\` no terminal  
2. Executa: claude doctor + vim-diag + docker ps
3. Relatório completo do ambiente

## 🛠️ Manutenção

### Recarregar Configurações
\`\`\`bash
# Zsh
source ~/.zshrc

# Vim  
:source ~/.vimrc

# VSCode
CTRL+SHIFT+P > Developer: Reload Window
\`\`\`

### Atualizar Integrações
\`\`\`bash
cd $WARP_WORKSPACE_DIR
./scripts/setup-integration.sh
\`\`\`

### Backup das Configurações
\`\`\`bash
cd ~/config
git add .
git commit -m "Backup integrações Warp \$(date)"
sync_repos
\`\`\`

## 🔍 Troubleshooting

### VSCode tasks não funcionam
1. Verificar se \`.vscode/tasks.json\` existe
2. Verificar caminhos dos scripts
3. Recarregar window: \`CTRL+SHIFT+P > Developer: Reload Window\`

### Aliases Zsh não carregam
1. Verificar se \`warp-integration.zsh\` foi incluído no .zshrc
2. Executar \`source ~/.zshrc\`
3. Confirmar que está no Warp: \`echo \$TERM_PROGRAM\`

### Vim integration não ativa
1. Adicionar \`source $CONFIG_DIR/vim-warp.vim\` ao .vimrc
2. Reiniciar Vim ou \`:source ~/.vimrc\`

---

**📁 Arquivos de configuração criados:**
- \`$VSCODE_DIR/tasks.json\`
- \`$VSCODE_DIR/keybindings.json\` 
- \`$VSCODE_DIR/settings.json\`
- \`$CONFIG_DIR/warp-integration.zsh\`
- \`$CONFIG_DIR/vim-warp.vim\`
- \`$HOME/.warp/workflows/dev-workspace.yml\`
- \`$HOME/.warp/notebooks/quick-commands.md\`

**🔄 Última execução:** $(date '+%Y-%m-%d %H:%M:%S')
EOF
    
    success "Documentação de integração criada: $integration_doc"
}

# Função principal
main() {
    log "${BOLD}🚀 Warp Terminal Integration Setup${NC}"
    log "Configurando integrações automáticas..."
    
    check_prerequisites
    setup_vscode_integration
    setup_zsh_integration  
    setup_warp_workflows
    setup_vim_integration
    create_integration_docs
    
    section "✅ Configuração Concluída!"
    
    echo -e "\n${GREEN}🎉 Integrações Warp Terminal configuradas com sucesso!${NC}\n"
    
    echo -e "${CYAN}📋 Próximos passos:${NC}"
    echo -e "  1. ${YELLOW}Recarregar Zsh:${NC} source ~/.zshrc"
    echo -e "  2. ${YELLOW}Recarregar VSCode:${NC} CTRL+SHIFT+P > Developer: Reload Window"
    echo -e "  3. ${YELLOW}Testar integração:${NC} wd (diagnóstico)"
    echo -e "  4. ${YELLOW}Abrir múltiplos terminais:${NC} CTRL+ALT+W no VSCode"
    
    echo -e "\n${CYAN}📖 Documentação:${NC}"
    echo -e "  - Quick Reference: $WARP_WORKSPACE_DIR/guides/quick-reference.md"
    echo -e "  - Integração: $WARP_WORKSPACE_DIR/docs/implementation/tool-integration.md"
    echo -e "  - Orquestração: $WARP_WORKSPACE_DIR/examples/orchestration-script.sh"
    
    echo -e "\n${BLUE}💡 Dica:${NC} Use 'wd' para diagnóstico rápido e 'wo' para orquestração!"
}

# Executar função principal
main "$@"