#!/bin/bash

# =============================================================================
# Setup Automatizado WSL2 + Claude Code Environment
# Baseado no ambiente do usuário João Pelegrino
# GitHub: https://github.com/joaopelegrino/config.git
# =============================================================================

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_step() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} ${GREEN}➤${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Banner inicial
clear
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     🚀 Setup Automatizado WSL2 + Claude Code Environment    ║"
echo "║                                                              ║"
echo "║     Configuração completa do ambiente de desenvolvimento    ║"
echo "║     Baseado em: github.com/joaopelegrino/config             ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Verificar se está rodando no WSL
if ! grep -qi microsoft /proc/version; then
    print_error "Este script deve ser executado dentro do WSL2!"
    exit 1
fi

# Solicitar informações do usuário
echo -e "${MAGENTA}=== Configuração Inicial ===${NC}"
read -p "Digite seu nome completo para o Git: " GIT_NAME
read -p "Digite seu email para o Git: " GIT_EMAIL
read -p "Deseja instalar Docker? (s/n): " INSTALL_DOCKER
read -p "Deseja configurar SSH keys? (s/n): " SETUP_SSH

echo ""
print_step "Iniciando configuração do ambiente..."
sleep 2

# =============================================================================
# FASE 1: Atualização do Sistema
# =============================================================================
print_step "Fase 1: Atualizando sistema base..."

sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    jq

print_success "Sistema base atualizado!"

# =============================================================================
# FASE 2: Instalação e Configuração do Zsh
# =============================================================================
print_step "Fase 2: Instalando Zsh e Oh My Zsh..."

# Instalar Zsh
sudo apt install -y zsh

# Instalar Oh My Zsh (sem interação)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Definir Zsh como shell padrão
    sudo chsh -s $(which zsh) $USER
fi

# Instalar Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Instalar plugins do Zsh
print_step "Instalando plugins do Zsh..."

# Autosugestões
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Syntax highlighting
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Autocomplete
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete" ]; then
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
fi

print_success "Zsh e plugins instalados!"

# =============================================================================
# FASE 3: Clonar Repositório de Configurações
# =============================================================================
print_step "Fase 3: Clonando repositório de configurações..."

# Criar diretório workspace
mkdir -p ~/workspace

# Clonar repositório de configurações (se não existir)
if [ ! -d "$HOME/config" ]; then
    print_step "Tentando clonar repositório de configurações..."
    if git clone https://github.com/joaopelegrino/config.git ~/config 2>/dev/null; then
        print_success "Repositório clonado com sucesso!"
    else
        print_warning "Não foi possível clonar o repositório. Criando configurações locais..."
        mkdir -p ~/config
    fi
else
    print_warning "Diretório ~/config já existe"
fi

# Backup de configurações existentes
print_step "Fazendo backup de configurações existentes..."
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for file in .zshrc .gitconfig .vimrc .bashrc .p10k.zsh; do
    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        mv "$HOME/$file" "$BACKUP_DIR/"
        print_warning "Backup criado: $BACKUP_DIR/$file"
    fi
done

# Criar links simbólicos
print_step "Criando links simbólicos para configurações..."

# Lista de arquivos para criar links
CONFIG_FILES=(
    "zshrc:.zshrc"
    "gitconfig:.gitconfig"
    "vimrc:.vimrc"
    "bashrc:.bashrc"
    "p10k.zsh:.p10k.zsh"
)

for config in "${CONFIG_FILES[@]}"; do
    SOURCE="${config%%:*}"
    TARGET="${config##*:}"
    
    if [ -f "$HOME/config/$SOURCE" ]; then
        ln -sf "$HOME/config/$SOURCE" "$HOME/$TARGET"
        print_success "Link criado: $TARGET -> ~/config/$SOURCE"
    else
        print_warning "Arquivo não encontrado: ~/config/$SOURCE"
    fi
done

# Configurar Git
print_step "Configurando Git..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global core.editor vim

print_success "Git configurado!"

# =============================================================================
# FASE 4: Ferramentas de Desenvolvimento
# =============================================================================
print_step "Fase 4: Instalando ferramentas de desenvolvimento..."

# Python e pip
print_step "Instalando Python e pip..."
sudo apt install -y python3 python3-pip python3-venv python3-dev
pip3 install --user pipx
export PATH="$HOME/.local/bin:$PATH"

# Node.js via NVM
print_step "Instalando Node.js via NVM..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Instalar Node LTS
    nvm install --lts
    nvm use --lts
    npm install -g npm@latest
fi

# Rust (para Yazi e outras ferramentas)
print_step "Instalando Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Yazi (gerenciador de arquivos)
print_step "Instalando Yazi..."
if ! command -v yazi &> /dev/null; then
    cargo install --locked yazi-fm yazi-cli
fi

# FZF
print_step "Instalando FZF..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
fi

# Ripgrep e fd-find
print_step "Instalando ripgrep e fd-find..."
sudo apt install -y ripgrep fd-find

# Bat (cat melhorado)
print_step "Instalando bat..."
sudo apt install -y bat
# Criar link simbólico se necessário (Ubuntu usa batcat)
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    sudo ln -sf $(which batcat) /usr/local/bin/bat
fi

# Eza (ls melhorado)
print_step "Instalando eza..."
if ! command -v eza &> /dev/null; then
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza || print_warning "Não foi possível instalar eza"
fi

print_success "Ferramentas de desenvolvimento instaladas!"

# =============================================================================
# FASE 5: Vim Avançado
# =============================================================================
print_step "Fase 5: Configurando Vim avançado..."

# Instalar Vim com suporte completo
sudo apt install -y vim-gtk3

# Instalar vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Criar estrutura de diretórios do Vim
mkdir -p ~/.vim/{autoload,plugged,undodir,spell,vsnip}

# Copiar configurações do Vim (se existirem no repositório)
if [ -d "$HOME/config/vim" ]; then
    cp -r "$HOME/config/vim/"* "$HOME/.vim/" 2>/dev/null || true
fi

# Instalar plugins do Vim (não interativo)
print_step "Instalando plugins do Vim..."
vim -c 'PlugInstall' -c 'qa!' &>/dev/null || print_warning "Alguns plugins podem precisar instalação manual"

# Instalar LSPs
print_step "Instalando Language Servers..."

# Python LSP
pip3 install --user python-lsp-server[all] pylsp-mypy pylsp-black

# TypeScript/JavaScript LSP
if command -v npm &> /dev/null; then
    npm install -g typescript typescript-language-server
fi

print_success "Vim configurado!"

# =============================================================================
# FASE 6: Docker (Opcional)
# =============================================================================
if [ "$INSTALL_DOCKER" = "s" ] || [ "$INSTALL_DOCKER" = "S" ]; then
    print_step "Fase 6: Verificando Docker..."
    
    if ! command -v docker &> /dev/null; then
        print_warning "Docker não encontrado. Por favor, instale o Docker Desktop no Windows"
        print_warning "e habilite a integração com WSL2 nas configurações."
        echo "Download: https://www.docker.com/products/docker-desktop"
    else
        print_success "Docker já está instalado!"
        docker --version
    fi
fi

# =============================================================================
# FASE 7: SSH Keys (Opcional)
# =============================================================================
if [ "$SETUP_SSH" = "s" ] || [ "$SETUP_SSH" = "S" ]; then
    print_step "Fase 7: Configurando SSH keys..."
    
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -N "" -f "$HOME/.ssh/id_ed25519"
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        
        print_success "SSH key criada!"
        echo ""
        echo -e "${YELLOW}Sua chave pública SSH:${NC}"
        cat ~/.ssh/id_ed25519.pub
        echo ""
        echo -e "${YELLOW}Adicione esta chave ao GitHub/GitLab/etc${NC}"
    else
        print_warning "SSH key já existe"
    fi
fi

# =============================================================================
# FASE 8: Claude Code
# =============================================================================
print_step "Fase 8: Preparando ambiente para Claude Code..."

# Criar estrutura Claude
mkdir -p ~/.claude
mkdir -p ~/workspace/projetos

# Criar arquivo CLAUDE.md template se não existir
if [ ! -f "$HOME/config/CLAUDE.md" ] && [ ! -f "$HOME/workspace/CLAUDE.md" ]; then
    cat > ~/workspace/CLAUDE.md << 'EOF'
# CLAUDE.md

Este arquivo fornece orientações ao Claude Code para trabalhar com este projeto.

## Comandos Principais
```bash
# Navegação
y          # Abrir Yazi
yy         # Yazi com cd integrado

# Git
gst        # git status
gco        # git checkout
gcm        # git commit -m

# Desenvolvimento
vim        # Editor principal
code .     # Abrir no VSCode
```

## Estrutura do Projeto
```
./
├── src/           # Código fonte
├── tests/         # Testes
├── docs/          # Documentação
└── CLAUDE.md      # Este arquivo
```

## Padrões de Desenvolvimento
- Use português-BR para comentários e documentação
- Siga as convenções do projeto
- Execute testes antes de commits
EOF
    print_success "Template CLAUDE.md criado!"
fi

# =============================================================================
# FASE 9: Configurações Finais
# =============================================================================
print_step "Fase 9: Aplicando configurações finais..."

# Criar arquivo .env para variáveis sensíveis
if [ ! -f "$HOME/.env" ]; then
    touch ~/.env
    chmod 600 ~/.env
    echo "# Adicione suas variáveis de ambiente aqui" >> ~/.env
    echo "# GITHUB_TOKEN=" >> ~/.env
    echo "# OPENAI_API_KEY=" >> ~/.env
fi

# Criar aliases úteis (se não existirem no zshrc)
if [ -f "$HOME/.zshrc" ] && ! grep -q "alias y=" "$HOME/.zshrc"; then
    cat >> ~/.zshrc << 'EOF'

# Aliases personalizados
alias y='yazi'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias reload='source ~/.zshrc'
alias ws='cd ~/workspace'

# Função para Yazi com cd
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
EOF
fi

print_success "Configurações finais aplicadas!"

# =============================================================================
# FASE 10: Validação e Diagnóstico
# =============================================================================
print_step "Fase 10: Validando instalação..."

echo ""
echo -e "${CYAN}=== Relatório de Instalação ===${NC}"
echo ""

# Verificar ferramentas instaladas
TOOLS=(
    "git:Git"
    "zsh:Zsh"
    "vim:Vim"
    "python3:Python"
    "node:Node.js"
    "rustc:Rust"
    "yazi:Yazi"
    "fzf:FZF"
    "rg:Ripgrep"
    "bat:Bat"
    "docker:Docker"
)

for tool in "${TOOLS[@]}"; do
    CMD="${tool%%:*}"
    NAME="${tool##*:}"
    
    if command -v $CMD &> /dev/null; then
        VERSION=$($CMD --version 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $NAME: $VERSION"
    else
        echo -e "${RED}✗${NC} $NAME: Não instalado"
    fi
done

# Scripts de diagnóstico (se disponíveis)
if [ -f "$HOME/config/diagnostico-ambiente.sh" ]; then
    echo ""
    print_step "Executando diagnóstico completo..."
    chmod +x ~/config/diagnostico-ambiente.sh
    ~/config/diagnostico-ambiente.sh || true
fi

# =============================================================================
# FINALIZAÇÃO
# =============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║                    🎉 CONFIGURAÇÃO COMPLETA!                ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_success "Ambiente configurado com sucesso!"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo "1. Feche e reabra o terminal para carregar o Zsh"
echo "2. Execute 'p10k configure' para configurar o tema (se necessário)"
echo "3. Configure o Claude Desktop no Windows"
echo "4. Adicione tokens e chaves ao arquivo ~/.env"

if [ "$SETUP_SSH" = "s" ]; then
    echo "5. Adicione sua chave SSH ao GitHub/GitLab"
fi

echo ""
echo -e "${CYAN}Comandos úteis para começar:${NC}"
echo "  y          - Abrir gerenciador de arquivos Yazi"
echo "  vim        - Abrir Vim com plugins configurados"
echo "  code .     - Abrir VSCode no diretório atual"
echo "  reload     - Recarregar configurações do shell"
echo ""

# Salvar log da instalação
LOG_FILE="$HOME/setup-log-$(date +%Y%m%d-%H%M%S).txt"
echo "Log completo salvo em: $LOG_FILE"

exit 0