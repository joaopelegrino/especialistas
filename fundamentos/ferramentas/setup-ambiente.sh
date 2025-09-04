#!/bin/bash
# 🛠️ Setup Ambiente - OS Development
# Configuração automática do ambiente de desenvolvimento

set -e  # Exit on error

echo "🚀 Iniciando setup do ambiente OS Development..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções utilitárias
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se é WSL2
check_wsl() {
    if grep -q Microsoft /proc/version; then
        log_success "Rodando no WSL2"
        return 0
    else
        log_warning "Não detectado WSL2 - algumas funcionalidades podem não funcionar"
        return 1
    fi
}

# Verificar distribuição
check_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        log_info "Distribuição detectada: $NAME $VERSION"
        DISTRO=$ID
    else
        log_error "Não foi possível detectar a distribuição"
        exit 1
    fi
}

# Atualizar sistema
update_system() {
    log_info "Atualizando sistema..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt update && sudo apt upgrade -y
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm
            ;;
        *)
            log_warning "Distribuição não suportada para update automático"
            ;;
    esac
    
    log_success "Sistema atualizado"
}

# Instalar ferramentas essenciais
install_essentials() {
    log_info "Instalando ferramentas essenciais..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y \
                build-essential \
                git \
                vim \
                curl \
                wget \
                htop \
                tree \
                unzip \
                software-properties-common
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm \
                base-devel \
                git \
                vim \
                curl \
                wget \
                htop \
                tree \
                unzip
            ;;
    esac
    
    log_success "Ferramentas essenciais instaladas"
}

# Instalar toolchain de desenvolvimento
install_dev_tools() {
    log_info "Instalando toolchain de desenvolvimento..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y \
                gcc \
                g++ \
                make \
                cmake \
                nasm \
                gdb \
                valgrind \
                gcc-multilib \
                g++-multilib \
                binutils \
                pkg-config
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm \
                gcc \
                make \
                cmake \
                nasm \
                gdb \
                valgrind \
                multilib-devel \
                binutils \
                pkgconf
            ;;
    esac
    
    log_success "Toolchain de desenvolvimento instalado"
}

# Instalar QEMU
install_qemu() {
    log_info "Instalando QEMU..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y qemu-system-x86 qemu-utils
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm qemu-full
            ;;
    esac
    
    log_success "QEMU instalado"
}

# Configurar Git (se não configurado)
configure_git() {
    if [ -z "$(git config --global user.name)" ]; then
        log_info "Configurando Git..."
        echo -n "Digite seu nome para Git: "
        read git_name
        echo -n "Digite seu email para Git: "
        read git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        
        log_success "Git configurado"
    else
        log_info "Git já está configurado"
    fi
}

# Instalar Oh My Zsh (opcional)
install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        log_info "Zsh já instalado"
    else
        log_info "Instalando Zsh..."
        case $DISTRO in
            ubuntu|debian)
                sudo apt install -y zsh
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm zsh
                ;;
        esac
        log_success "Zsh instalado"
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh instalado"
    else
        log_info "Oh My Zsh já instalado"
    fi
}

# Verificar e criar estrutura de diretórios
create_structure() {
    log_info "Criando estrutura de diretórios..."
    
    BASE_DIR="$HOME/workspace/learning/os-dev"
    mkdir -p "$BASE_DIR"/{basics,projects,exercises,resources}
    
    # Estrutura específica para cada fase
    mkdir -p "$BASE_DIR/basics"/{c-fundamentals,assembly,hardware}
    mkdir -p "$BASE_DIR/projects"/{bootloader,kernel,filesystem,drivers}
    mkdir -p "$BASE_DIR/exercises"/{solved,pending,challenges}
    mkdir -p "$BASE_DIR/resources"/{docs,tools,references}
    
    log_success "Estrutura de diretórios criada em $BASE_DIR"
}

# Criar arquivo de teste
create_test_files() {
    log_info "Criando arquivos de teste..."
    
    BASE_DIR="$HOME/workspace/learning/os-dev"
    
    # Hello World em C
    cat > "$BASE_DIR/basics/c-fundamentals/hello.c" << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello, OS Development!\n");
    return 0;
}
EOF

    # Makefile simples
    cat > "$BASE_DIR/basics/c-fundamentals/Makefile" << 'EOF'
CC=gcc
CFLAGS=-Wall -Wextra -std=c99

hello: hello.c
	$(CC) $(CFLAGS) -o hello hello.c

clean:
	rm -f hello

.PHONY: clean
EOF

    # README
    cat > "$BASE_DIR/README.md" << 'EOF'
# 🚀 OS Development Learning

## Estrutura

- `basics/` - Conceitos fundamentais
- `projects/` - Projetos práticos  
- `exercises/` - Exercícios e desafios
- `resources/` - Documentação e referências

## Começando

```bash
cd basics/c-fundamentals
make hello
./hello
```

Boa sorte na jornada! 🎯
EOF

    log_success "Arquivos de teste criados"
}

# Testar instalação
test_installation() {
    log_info "Testando instalação..."
    
    # Testar compilador
    if gcc --version > /dev/null 2>&1; then
        log_success "GCC funcionando"
    else
        log_error "GCC não instalado corretamente"
    fi
    
    # Testar NASM
    if nasm -v > /dev/null 2>&1; then
        log_success "NASM funcionando"
    else
        log_error "NASM não instalado corretamente"
    fi
    
    # Testar QEMU
    if qemu-system-x86_64 --version > /dev/null 2>&1; then
        log_success "QEMU funcionando"
    else
        log_error "QEMU não instalado corretamente"
    fi
    
    # Compilar e testar hello world
    BASE_DIR="$HOME/workspace/learning/os-dev"
    if [ -f "$BASE_DIR/basics/c-fundamentals/hello.c" ]; then
        cd "$BASE_DIR/basics/c-fundamentals"
        if make hello > /dev/null 2>&1; then
            if ./hello | grep -q "Hello"; then
                log_success "Compilação de teste funcionando"
            else
                log_error "Erro na execução do teste"
            fi
        else
            log_error "Erro na compilação do teste"
        fi
    fi
}

# Mostrar resumo final
show_summary() {
    echo
    echo "════════════════════════════════════════════"
    log_success "Setup concluído com sucesso! 🎉"
    echo "════════════════════════════════════════════"
    echo
    echo "📁 Estrutura criada em: $HOME/workspace/learning/os-dev"
    echo "🛠️  Ferramentas instaladas:"
    echo "   • GCC/G++ (compiladores)"
    echo "   • NASM (assembler)"  
    echo "   • GDB (debugger)"
    echo "   • QEMU (emulador)"
    echo "   • Make/CMake (build systems)"
    echo "   • Valgrind (análise de memória)"
    echo
    echo "🚀 Próximos passos:"
    echo "   1. cd ~/workspace/learning/os-dev"
    echo "   2. Explorar estrutura criada"
    echo "   3. Testar: cd basics/c-fundamentals && make hello"
    echo "   4. Iniciar FASE 0 da trilha"
    echo
    log_info "Ambiente pronto para desenvolvimento de SO! 🎯"
}

# Menu interativo
show_menu() {
    echo "🛠️  Setup Ambiente OS Development"
    echo "═══════════════════════════════════"
    echo "1) Setup completo (recomendado)"
    echo "2) Apenas ferramentas essenciais"
    echo "3) Apenas toolchain de desenvolvimento" 
    echo "4) Apenas QEMU"
    echo "5) Apenas estrutura de diretórios"
    echo "6) Testar instalação existente"
    echo "0) Sair"
    echo
    echo -n "Escolha uma opção: "
}

# Main function
main() {
    # Verificações iniciais
    check_wsl
    check_distro
    
    # Se argumentos foram passados, executar automaticamente
    if [ $# -gt 0 ]; then
        case $1 in
            --full)
                update_system
                install_essentials
                install_dev_tools
                install_qemu
                configure_git
                install_zsh
                create_structure
                create_test_files
                test_installation
                show_summary
                ;;
            --tools)
                install_dev_tools
                install_qemu
                ;;
            --test)
                test_installation
                ;;
            *)
                echo "Uso: $0 [--full|--tools|--test]"
                exit 1
                ;;
        esac
        return
    fi
    
    # Menu interativo
    while true; do
        show_menu
        read choice
        
        case $choice in
            1)
                update_system
                install_essentials
                install_dev_tools
                install_qemu
                configure_git
                install_zsh
                create_structure
                create_test_files
                test_installation
                show_summary
                break
                ;;
            2)
                update_system
                install_essentials
                configure_git
                ;;
            3)
                install_dev_tools
                install_qemu
                ;;
            4)
                install_qemu
                ;;
            5)
                create_structure
                create_test_files
                ;;
            6)
                test_installation
                ;;
            0)
                log_info "Saindo..."
                exit 0
                ;;
            *)
                log_error "Opção inválida!"
                ;;
        esac
    done
}

# Executar main com argumentos
main "$@"