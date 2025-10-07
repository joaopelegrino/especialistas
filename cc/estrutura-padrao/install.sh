#!/bin/bash

# Claude Code - Estrutura Padrão Installer
# Instala commands, agents, hooks e configurações em um projeto

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${1:-.}"
ESTRUTURA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Claude Code - Estrutura Padrão Installer v1.0         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate installation directory
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}✗ Erro: Diretório '$INSTALL_DIR' não existe${NC}"
    exit 1
fi

cd "$INSTALL_DIR"
echo -e "${GREEN}📁 Instalando em:${NC} $(pwd)"
echo ""

# Function to create directory
create_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${GREEN}✓${NC} Criado: $dir"
    else
        echo -e "${YELLOW}→${NC} Existe: $dir"
    fi
}

# Function to copy file
copy_file() {
    local src=$1
    local dst=$2
    local force=${3:-false}

    if [ -f "$dst" ] && [ "$force" = false ]; then
        echo -e "${YELLOW}→${NC} Existe: $dst (pulando)"
        return 0
    fi

    cp "$src" "$dst"
    echo -e "${GREEN}✓${NC} Copiado: $dst"
}

# Function to copy executable
copy_executable() {
    local src=$1
    local dst=$2

    copy_file "$src" "$dst"
    chmod +x "$dst"
    echo -e "${GREEN}✓${NC} Executável: $dst"
}

# Create directory structure
echo -e "${BLUE}━━━ Criando estrutura de diretórios ━━━${NC}"
create_dir ".claude"
create_dir ".claude/commands"
create_dir ".claude/agents"
create_dir ".claude/hooks"
create_dir ".agents"
create_dir ".agents/context-bundles"
create_dir ".agents/outputs"
echo ""

# Install commands
echo -e "${BLUE}━━━ Instalando commands ━━━${NC}"
for cmd in "$ESTRUTURA_DIR/commands"/*.md; do
    if [ -f "$cmd" ]; then
        filename=$(basename "$cmd")
        copy_file "$cmd" ".claude/commands/$filename"
    fi
done
echo ""

# Install agents
echo -e "${BLUE}━━━ Instalando agents ━━━${NC}"
for agent in "$ESTRUTURA_DIR/agents"/*.yaml; do
    if [ -f "$agent" ]; then
        filename=$(basename "$agent")
        copy_file "$agent" ".claude/agents/$filename"
    fi
done
echo ""

# Install hooks
echo -e "${BLUE}━━━ Instalando hooks ━━━${NC}"
for hook in "$ESTRUTURA_DIR/hooks"/*.sh; do
    if [ -f "$hook" ]; then
        filename=$(basename "$hook")
        copy_executable "$hook" ".claude/hooks/$filename"
    fi
done

# Copy hook README
if [ -f "$ESTRUTURA_DIR/hooks/README.md" ]; then
    copy_file "$ESTRUTURA_DIR/hooks/README.md" ".claude/hooks/README.md"
fi
echo ""

# Install settings
echo -e "${BLUE}━━━ Configurando settings ━━━${NC}"
if [ -f ".claude/settings.json" ]; then
    echo -e "${YELLOW}→${NC} .claude/settings.json já existe"
    echo -e "${YELLOW}  ${NC} Exemplo disponível em: .claude/settings.json.example"
    copy_file "$ESTRUTURA_DIR/settings.json.example" ".claude/settings.json.example"
else
    echo -e "${GREEN}✓${NC} Criando .claude/settings.json"
    cp "$ESTRUTURA_DIR/settings.json.example" ".claude/settings.json"
fi
echo ""

# Create .gitignore if needed
echo -e "${BLUE}━━━ Configurando .gitignore ━━━${NC}"
GITIGNORE_ENTRIES=(
    ".agents/context-bundles/*.md"
    ".agents/outputs/*"
    "!.agents/context-bundles/.gitkeep"
    "!.agents/outputs/.gitkeep"
)

if [ -f ".gitignore" ]; then
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -q "^$entry$" .gitignore; then
            echo "$entry" >> .gitignore
            echo -e "${GREEN}✓${NC} Adicionado ao .gitignore: $entry"
        else
            echo -e "${YELLOW}→${NC} Já existe no .gitignore: $entry"
        fi
    done
else
    echo -e "${GREEN}✓${NC} Criando .gitignore"
    printf "%s\n" "${GITIGNORE_ENTRIES[@]}" > .gitignore
fi
echo ""

# Create .gitkeep files
touch .agents/context-bundles/.gitkeep
touch .agents/outputs/.gitkeep

# Verify installation
echo -e "${BLUE}━━━ Verificando instalação ━━━${NC}"
COMMANDS_COUNT=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l)
AGENTS_COUNT=$(find .claude/agents -name "*.yaml" 2>/dev/null | wc -l)
HOOKS_COUNT=$(find .claude/hooks -name "*.sh" -executable 2>/dev/null | wc -l)

echo -e "${GREEN}✓${NC} Commands instalados: $COMMANDS_COUNT"
echo -e "${GREEN}✓${NC} Agents instalados: $AGENTS_COUNT"
echo -e "${GREEN}✓${NC} Hooks instalados: $HOOKS_COUNT"
echo ""

# Success summary
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ Instalação Completa!                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📚 Próximos passos:${NC}"
echo ""
echo -e "  1. ${YELLOW}Editar configurações (se necessário):${NC}"
echo -e "     nano .claude/settings.json"
echo ""
echo -e "  2. ${YELLOW}Criar/atualizar CLAUDE.md (mínimo):${NC}"
echo -e "     - Tech stack"
echo -e "     - Comandos de dev/test/build"
echo -e "     - Convenções do projeto"
echo ""
echo -e "  3. ${YELLOW}Testar comandos:${NC}"
echo -e "     claude"
echo -e "     /prime"
echo -e "     /scout \"search query\""
echo ""
echo -e "  4. ${YELLOW}Ver documentação completa:${NC}"
echo -e "     cat $ESTRUTURA_DIR/README.md"
echo ""
echo -e "${GREEN}✓${NC} Commands disponíveis:"
echo -e "   /scout, /plan-with-docs, /build, /scout-plan-build"
echo -e "   /prime, /prime-bug, /prime-feature, /prime-migration"
echo -e "   /load-bundle"
echo ""
echo -e "${GREEN}✓${NC} Agents disponíveis:"
echo -e "   scout-search (Haiku), code-reviewer (Sonnet)"
echo -e "   security-auditor (Sonnet)"
echo ""
echo -e "${GREEN}✓${NC} Hooks ativos:"
echo -e "   PostToolUse → log-to-bundle.sh"
echo -e "   (Context bundles em: .agents/context-bundles/)"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Happy coding with Claude! 🚀${NC}"
echo ""
