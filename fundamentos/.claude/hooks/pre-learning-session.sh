#!/bin/bash
# pre-learning-session.sh - Hook executado antes de cada interação
# Otimiza criação de guias para terminal separado Arch

USER_PROMPT="$1"

# Detecta tipo de tarefa solicitada
detect_task_type() {
    local prompt="$1"
    
    if [[ "$prompt" =~ (compilar|gcc|r2|radare2|qemu|debug|bootloader|kernel|nasm|ld) ]]; then
        echo "development"
    elif [[ "$prompt" =~ (exercício|exercicio|projeto|implementar) ]]; then
        echo "hands-on"
    elif [[ "$prompt" =~ (checkpoint|validar|testar) ]]; then
        echo "validation"
    elif [[ "$prompt" =~ (iniciar|começar|comecar|FASE|fase) ]]; then
        echo "phase-start"
    else
        echo "documentation"
    fi
}

# Prepara variáveis de ambiente para o tipo de tarefa
setup_task_environment() {
    local task_type="$1"
    
    case "$task_type" in
        "development"|"hands-on")
            export OSR2_CREATE_ARCH_GUIDE="true"
            export OSR2_INCLUDE_R2_COMMANDS="true"
            export OSR2_SETUP_VALIDATION="true"
            ;;
        "validation")
            export OSR2_CREATE_CHECKLIST="true"
            export OSR2_INCLUDE_TROUBLESHOOTING="true"
            ;;
        "phase-start")
            export OSR2_CREATE_SESSION_SETUP="true"
            export OSR2_INITIALIZE_WORKSPACE="true"
            ;;
        "documentation")
            export OSR2_FOCUS_THEORY="true"
            ;;
    esac
}

# Atualiza contador de sessões
update_session_count() {
    local settings_file="/home/notebook/workspace/especialistas/fundamentos/.claude/settings.local.json"
    local current_count=$(jq -r '.env.OSR2_SESSION_COUNT' "$settings_file" 2>/dev/null || echo "0")
    local new_count=$((current_count + 1))
    
    # Atualiza timestamp da última sessão
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Note: Em production, usaria jq para atualizar JSON
    echo "# Sessão $new_count iniciada em $timestamp" >> /tmp/osr2-session.log
}

# Função principal
main() {
    local task_type=$(detect_task_type "$USER_PROMPT")
    
    setup_task_environment "$task_type"
    update_session_count
    
    echo "# OSR2 Learning Hook Activated"
    echo "# Task Type: $task_type"
    echo "# Arch Guide Mode: ${OSR2_CREATE_ARCH_GUIDE:-false}"
    echo "# Session: $(date '+%Y-%m-%d %H:%M:%S')"
}

# Executa apenas se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi