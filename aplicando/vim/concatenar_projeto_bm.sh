#!/bin/bash

# Script Especializado para Concatenação do Projeto BM
# Uso: ./concatenar_projeto_bm.sh [tipo_concatenacao]
# Tipos: basico, completo, hierarquico

set -e

SCRIPT_DIR="$(dirname "$0")"
TIPO="${1:-completo}"
OUTPUT_DIR="."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🚀 Concatenando Projeto BM - Tipo: $TIPO"
echo "📅 Timestamp: $TIMESTAMP"

# Função para adicionar cabeçalho
adicionar_cabecalho() {
    local output_file="$1"
    cat << EOF > "$output_file"
# 📊 PROJETO BM - DOCUMENTAÇÃO CONSOLIDADA

**Gerado automaticamente em:** $(date)
**Tipo de concatenação:** $TIPO

---

## 📑 Índice de Documentos

EOF
}

# Função para adicionar separador entre arquivos
adicionar_separador() {
    local output_file="$1"
    local arquivo="$2"
    local numero="$3"
    
    cat << EOF >> "$output_file"


---
## 📄 Documento $numero: $(basename "$arquivo")
**Arquivo fonte:** \`$arquivo\`

EOF
}

case "$TIPO" in
    "basico")
        OUTPUT_FILE="PROJETO_BM_BASICO_$TIMESTAMP.md"
        echo "📝 Gerando concatenação básica..."
        
        adicionar_cabecalho "$OUTPUT_FILE"
        
        # Arquivos principais em ordem numérica
        contador=1
        for arquivo in requisitos-projeto-bm/0*.md; do
            if [[ -f "$arquivo" ]]; then
                echo "- [$(basename "$arquivo")](#documento-$contador-$(basename "$arquivo" .md))" >> "$OUTPUT_FILE"
                ((contador++))
            fi
        done
        
        echo "" >> "$OUTPUT_FILE"
        echo "---" >> "$OUTPUT_FILE"
        
        contador=1
        for arquivo in requisitos-projeto-bm/0*.md; do
            if [[ -f "$arquivo" ]]; then
                adicionar_separador "$OUTPUT_FILE" "$arquivo" "$contador"
                cat "$arquivo" >> "$OUTPUT_FILE"
                ((contador++))
            fi
        done
        ;;
        
    "completo")
        OUTPUT_FILE="PROJETO_BM_COMPLETO_$TIMESTAMP.md"
        echo "📚 Gerando concatenação completa..."
        
        adicionar_cabecalho "$OUTPUT_FILE"
        
        # TODO(human): Implementar lógica de concatenação completa
        # Sua tarefa:
        # 1. Listar TODOS os arquivos .md recursivamente
        # 2. Criar índice organizado por diretórios
        # 3. Ordenar: primeiro numerados (0*.md), depois alfabéticos
        # 4. Incluir arquivos de subdiretórios com indicação da pasta
        # 5. Manter estrutura hierárquica no índice
        #
        # Estrutura sugerida:
        # - requisitos-projeto-bm/0*.md (ordem numérica)
        # - requisitos-projeto-bm/[outros].md (alfabética)
        # - requisitos-projeto-bm/02_ARQUITETURA_TECNICA/*.md
        # - requisitos-projeto-bm/03_COMPLIANCE/*.md
        # - requisitos-projeto-bm/requisitos_desenvolvimento/*.md
        
        echo "⚠️  TODO: Implementar concatenação completa"
        ;;
        
    "hierarquico")
        OUTPUT_FILE="PROJETO_BM_HIERARQUICO_$TIMESTAMP.md"
        echo "🗂️  Gerando concatenação hierárquica..."
        
        adicionar_cabecalho "$OUTPUT_FILE"
        
        # Estrutura hierárquica por diretórios
        echo "### 📁 Documentos Principais" >> "$OUTPUT_FILE"
        
        # Arquivos numerados primeiro
        for arquivo in requisitos-projeto-bm/0*.md; do
            if [[ -f "$arquivo" ]]; then
                echo "- [$(basename "$arquivo")](#$(basename "$arquivo" .md | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g'))" >> "$OUTPUT_FILE"
            fi
        done
        
        # Outros arquivos principais
        echo "" >> "$OUTPUT_FILE"
        echo "### 📁 Outros Documentos" >> "$OUTPUT_FILE"
        for arquivo in requisitos-projeto-bm/*.md; do
            if [[ -f "$arquivo" ]] && [[ ! "$(basename "$arquivo")" =~ ^0[0-9] ]]; then
                echo "- [$(basename "$arquivo")](#$(basename "$arquivo" .md | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g'))" >> "$OUTPUT_FILE"
            fi
        done
        
        echo "" >> "$OUTPUT_FILE"
        echo "---" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Conteúdo dos arquivos
        contador=1
        
        # Primeiro os numerados
        for arquivo in requisitos-projeto-bm/0*.md; do
            if [[ -f "$arquivo" ]]; then
                adicionar_separador "$OUTPUT_FILE" "$arquivo" "$contador"
                cat "$arquivo" >> "$OUTPUT_FILE"
                ((contador++))
            fi
        done
        
        # Depois os outros
        for arquivo in requisitos-projeto-bm/*.md; do
            if [[ -f "$arquivo" ]] && [[ ! "$(basename "$arquivo")" =~ ^0[0-9] ]]; then
                adicionar_separador "$OUTPUT_FILE" "$arquivo" "$contador"
                cat "$arquivo" >> "$OUTPUT_FILE"
                ((contador++))
            fi
        done
        ;;
        
    *)
        echo "❌ Tipo inválido. Use: basico, completo, ou hierarquico"
        exit 1
        ;;
esac

echo "✅ Arquivo gerado: $OUTPUT_FILE"
echo "📊 Estatísticas:"
wc -l "$OUTPUT_FILE"
echo ""
echo "🔍 Primeiras linhas do arquivo:"
head -20 "$OUTPUT_FILE"