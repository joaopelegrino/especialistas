#!/bin/bash

# Claude Code - Installation Validator
# Verifica se a estrutura padrão foi instalada corretamente

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHECK_DIR="${1:-.}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Claude Code - Installation Validator v1.0             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate directory
if [ ! -d "$CHECK_DIR" ]; then
    echo -e "${RED}✗ Erro: Diretório '$CHECK_DIR' não existe${NC}"
    exit 1
fi

cd "$CHECK_DIR"
echo -e "${BLUE}📁 Validando instalação em:${NC} $(pwd)"
echo ""

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Check function
check() {
    local name=$1
    local condition=$2
    local level=${3:-error}  # error, warning, info

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$level" = "warning" ]; then
            echo -e "${YELLOW}⚠${NC} $name"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        else
            echo -e "${RED}✗${NC} $name"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
        return 1
    fi
}

# Directory Structure
echo -e "${BLUE}━━━ Estrutura de Diretórios ━━━${NC}"
check "Diretório .claude existe" "[ -d .claude ]"
check "Diretório .claude/commands existe" "[ -d .claude/commands ]"
check "Diretório .claude/agents existe" "[ -d .claude/agents ]"
check "Diretório .claude/hooks existe" "[ -d .claude/hooks ]"
check "Diretório .agents existe" "[ -d .agents ]"
check "Diretório .agents/context-bundles existe" "[ -d .agents/context-bundles ]"
check "Diretório .agents/outputs existe" "[ -d .agents/outputs ]" "warning"
echo ""

# Commands
echo -e "${BLUE}━━━ Commands (Slash Commands) ━━━${NC}"
REQUIRED_COMMANDS=(
    "scout.md"
    "plan-with-docs.md"
    "build.md"
    "scout-plan-build.md"
    "prime.md"
    "prime-bug.md"
    "prime-feature.md"
    "prime-migration.md"
    "load-bundle.md"
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    check "Command: $cmd" "[ -f .claude/commands/$cmd ]"
done

# Validate command frontmatter
if [ -f .claude/commands/scout.md ]; then
    check "Command frontmatter válido (scout.md)" "head -3 .claude/commands/scout.md | grep -q '^---$'" "warning"
fi
echo ""

# Agents
echo -e "${BLUE}━━━ Agents (Sub-agents) ━━━${NC}"
REQUIRED_AGENTS=(
    "scout-search.yaml"
    "code-reviewer.yaml"
    "security-auditor.yaml"
)

for agent in "${REQUIRED_AGENTS[@]}"; do
    check "Agent: $agent" "[ -f .claude/agents/$agent ]"
done

# Validate agent YAML
if [ -f .claude/agents/scout-search.yaml ]; then
    check "Agent YAML válido (scout-search.yaml)" "head -2 .claude/agents/scout-search.yaml | grep -q '^---$'" "warning"
    check "Agent tem campo 'model'" "grep -q '^model:' .claude/agents/scout-search.yaml" "warning"
    check "Agent tem campo 'tools'" "grep -q '^tools:' .claude/agents/scout-search.yaml" "warning"
fi
echo ""

# Hooks
echo -e "${BLUE}━━━ Hooks (Automação) ━━━${NC}"
check "Hook script existe: log-to-bundle.sh" "[ -f .claude/hooks/log-to-bundle.sh ]"
check "Hook script é executável" "[ -x .claude/hooks/log-to-bundle.sh ]"
check "Hook README existe" "[ -f .claude/hooks/README.md ]" "warning"

# Validate hook script
if [ -f .claude/hooks/log-to-bundle.sh ]; then
    check "Hook tem shebang correto" "head -1 .claude/hooks/log-to-bundle.sh | grep -q '^#!/bin/bash$'" "warning"
    check "Hook cria diretório de bundles" "grep -q 'BUNDLE_DIR' .claude/hooks/log-to-bundle.sh" "warning"
fi
echo ""

# Settings
echo -e "${BLUE}━━━ Configuração (settings.json) ━━━${NC}"
check "settings.json existe" "[ -f .claude/settings.json ]"

if [ -f .claude/settings.json ]; then
    check "settings.json é válido JSON" "python3 -m json.tool .claude/settings.json > /dev/null 2>&1" "warning"
    check "settings.json tem hooks configurados" "grep -q '\"hooks\"' .claude/settings.json" "warning"
    check "settings.json tem PostToolUse hook" "grep -q 'PostToolUse' .claude/settings.json" "warning"
    check "autocompact está configurado" "grep -q '\"autocompact\"' .claude/settings.json" "warning"
else
    check "settings.json.example existe" "[ -f .claude/settings.json.example ]" "warning"
fi
echo ""

# Project Files
echo -e "${BLUE}━━━ Arquivos do Projeto ━━━${NC}"
check "CLAUDE.md existe" "[ -f CLAUDE.md ]" "warning"
check ".gitignore existe" "[ -f .gitignore ]" "warning"

if [ -f .gitignore ]; then
    check ".gitignore ignora context-bundles" "grep -q 'context-bundles' .gitignore" "warning"
    check ".gitignore ignora outputs" "grep -q '.agents/outputs' .gitignore" "warning"
fi
echo ""

# File Counts
echo -e "${BLUE}━━━ Contagem de Arquivos ━━━${NC}"
COMMANDS_COUNT=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l)
AGENTS_COUNT=$(find .claude/agents -name "*.yaml" 2>/dev/null | wc -l)
HOOKS_COUNT=$(find .claude/hooks -name "*.sh" 2>/dev/null | wc -l)

echo -e "Commands: $COMMANDS_COUNT (esperado: 9+)"
if [ "$COMMANDS_COUNT" -ge 9 ]; then
    echo -e "${GREEN}✓${NC} Contagem de commands OK"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠${NC} Poucos commands (esperado: 9+)"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo -e "Agents: $AGENTS_COUNT (esperado: 3+)"
if [ "$AGENTS_COUNT" -ge 3 ]; then
    echo -e "${GREEN}✓${NC} Contagem de agents OK"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}✗${NC} Poucos agents (esperado: 3+)"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo -e "Hooks: $HOOKS_COUNT (esperado: 1+)"
if [ "$HOOKS_COUNT" -ge 1 ]; then
    echo -e "${GREEN}✓${NC} Contagem de hooks OK"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}✗${NC} Nenhum hook executável encontrado"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
echo ""

# Permissions Check
echo -e "${BLUE}━━━ Permissões ━━━${NC}"
if [ -f .claude/hooks/log-to-bundle.sh ]; then
    PERMS=$(stat -c %a .claude/hooks/log-to-bundle.sh 2>/dev/null || stat -f %A .claude/hooks/log-to-bundle.sh 2>/dev/null)
    if [[ "$PERMS" =~ ^[0-9]*[1357]$ ]]; then
        echo -e "${GREEN}✓${NC} Hook é executável (permissões: $PERMS)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗${NC} Hook não é executável (permissões: $PERMS)"
        echo -e "${YELLOW}  Fix: chmod +x .claude/hooks/log-to-bundle.sh${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi
echo ""

# Git Check
echo -e "${BLUE}━━━ Git (Opcional) ━━━${NC}"
if [ -d .git ]; then
    check "Repositório Git inicializado" "[ -d .git ]" "info"
    check "Git ignora bundles sensíveis" "grep -q 'context-bundles/\\*.md' .gitignore 2>/dev/null" "warning"
else
    echo -e "${YELLOW}ℹ${NC}  Não é um repositório Git (opcional)"
fi
echo ""

# Summary
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Resumo da Validação                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total de verificações: $TOTAL_CHECKS"
echo -e "${GREEN}✓ Passaram: $PASSED_CHECKS${NC}"
if [ "$WARNING_CHECKS" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Avisos: $WARNING_CHECKS${NC}"
fi
if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo -e "${RED}✗ Falharam: $FAILED_CHECKS${NC}"
fi
echo ""

# Final verdict
if [ "$FAILED_CHECKS" -eq 0 ]; then
    if [ "$WARNING_CHECKS" -eq 0 ]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║              ✓ Instalação Perfeita!                      ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}🚀 Tudo pronto para usar Claude Code!${NC}"
        echo ""
        echo -e "${BLUE}Próximos passos:${NC}"
        echo -e "  1. ${YELLOW}cd $(pwd)${NC}"
        echo -e "  2. ${YELLOW}claude${NC}"
        echo -e "  3. ${YELLOW}/prime${NC} ou ${YELLOW}/scout \"your query\"${NC}"
        exit 0
    else
        echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║         ⚠ Instalação OK com Avisos                      ║${NC}"
        echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}A instalação básica está funcional, mas há avisos acima.${NC}"
        echo -e "Revise os avisos ${YELLOW}⚠${NC} para otimizar a configuração."
        exit 0
    fi
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║            ✗ Instalação Incompleta                       ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Encontrados $FAILED_CHECKS erro(s) crítico(s).${NC}"
    echo -e "Revise os erros ${RED}✗${NC} acima e corrija antes de usar."
    echo ""
    echo -e "${BLUE}Sugestão:${NC} Execute novamente o script de instalação:"
    echo -e "  ${YELLOW}./install.sh .${NC}"
    exit 1
fi
