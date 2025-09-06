#!/bin/bash
# sync-results.sh - Processa resultados do terminal Arch
# Sincroniza outputs de desenvolvimento de volta ao Ubuntu

SHARED_PATH="/mnt/c/Users/*/workspace/osr2-shared"
PROJECT_ROOT="/home/notebook/workspace/especialistas/fundamentos"

# Processa análises r2
process_r2_analysis() {
    local analysis_file="$1"
    
    if [[ -f "$analysis_file" ]]; then
        # Extrai informações importantes
        local binary_name=$(grep -o "Binary: .*" "$analysis_file" | cut -d' ' -f2)
        local functions=$(grep -c "^fcn\." "$analysis_file" || echo "0")
        
        echo "# r2 Analysis Processed"
        echo "Binary: $binary_name"
        echo "Functions found: $functions"
        echo "Analysis timestamp: $(date)"
    fi
}

# Atualiza progresso automaticamente
update_progress_tracker() {
    local completed_task="$1"
    local progress_file="$PROJECT_ROOT/PROGRESSO_TRACKER.md"
    
    if [[ -f "$progress_file" ]]; then
        echo "## $(date '+%Y-%m-%d') - $completed_task" >> "$progress_file"
        echo "- Status: Concluído via terminal Arch" >> "$progress_file"
        echo "" >> "$progress_file"
    fi
}

# Organiza outputs por fase
organize_by_phase() {
    local phase=$(echo "$OSR2_CURRENT_PHASE" | head -c1)
    local output_dir="$PROJECT_ROOT/app-aprender-osr2/FASE_${phase}_*/workspace-atual"
    
    # Cria diretório se não existir
    mkdir -p "$output_dir" 2>/dev/null
    
    # Move arquivos organizadamente
    if [[ -n "$1" ]]; then
        cp "$1" "$output_dir/" 2>/dev/null
    fi
}

# Função principal
main() {
    echo "# Sync Results from Arch Terminal"
    echo "# Checking shared path: $SHARED_PATH"
    
    # Processa arquivos de análise r2
    find "$SHARED_PATH" -name "*-r2-analysis.txt" -newer /tmp/last-sync 2>/dev/null | while read -r file; do
        process_r2_analysis "$file"
        organize_by_phase "$file"
    done
    
    # Atualiza timestamp da última sincronização  
    touch /tmp/last-sync
    
    echo "# Sync completed: $(date)"
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi