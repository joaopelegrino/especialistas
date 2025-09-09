#!/bin/bash
# fix-vimrc-location.sh - Diagnosticar e corrigir localização .vimrc

echo "🔍 Diagnóstico de Localização .vimrc para OSR2"
echo "============================================="

# Função para verificar configuração atual do vim
check_vim_config() {
    echo ""
    echo "📊 Status atual das configurações vim:"
    
    # Testar se vim carrega configurações
    local test_result=$(vim -c 'echo &number' -c 'q' 2>/dev/null)
    if [[ "$test_result" == *"1"* ]]; then
        echo "✅ Vim está carregando configurações (set number ativo)"
    else
        echo "❌ Vim NÃO está carregando configurações"
    fi
    
    # Verificar qual arquivo vim está usando
    local vimrc_path=$(vim -c 'echo $MYVIMRC' -c 'q' 2>/dev/null | tr -d '\n')
    if [[ -n "$vimrc_path" ]]; then
        echo "📁 Vim está usando: $vimrc_path"
    else
        echo "❌ Vim não encontrou nenhum arquivo .vimrc"
    fi
}

# TODO(human): Implementar função fix_vimrc_location()
# Função deve:
# 1. Verificar locais possíveis do .vimrc
# 2. Determinar qual ação tomar baseado no que encontrar
# 3. Aplicar correção apropriada
# 4. Validar que correção funcionou
function fix_vimrc_location() {
    echo ""
    echo "🔧 Corrigindo localização do .vimrc..."
    
    # TODO(human): Implementar detecção e correção
    # Verificar estes locais:
    # ~/.vimrc (padrão - deixar como está)
    # ~/.vim/.vimrc (mover para ~/.vimrc)  
    # ~/.vim/vimrc (válido - deixar como está)
    # Nenhum arquivo (avisar usuário)
    
    echo "TODO: Implementar lógica de detecção e correção"
}

# Diagnóstico inicial
echo "🔍 Verificando locais possíveis do .vimrc:"
echo ""

# Verificar local padrão
if [[ -f ~/.vimrc ]]; then
    echo "✅ ~/.vimrc existe (local padrão - perfeito!)"
    ls -la ~/.vimrc
else
    echo "❌ ~/.vimrc não encontrado"
fi

# Verificar local alternativo válido  
if [[ -f ~/.vim/vimrc ]]; then
    echo "✅ ~/.vim/vimrc existe (alternativo válido)"
    ls -la ~/.vim/vimrc
else
    echo "❌ ~/.vim/vimrc não encontrado"
fi

# Verificar local problemático
if [[ -f ~/.vim/.vimrc ]]; then
    echo "⚠️  ~/.vim/.vimrc existe (local não padrão - precisa correção!)"
    ls -la ~/.vim/.vimrc
    echo "   💡 Este arquivo não é carregado automaticamente pelo vim"
else
    echo "✅ ~/.vim/.vimrc não existe (bom - evita confusão)"
fi

# Verificar pasta .vim existe
if [[ -d ~/.vim ]]; then
    echo "📁 Pasta ~/.vim existe"
    echo "   Conteúdo:"
    ls -la ~/.vim/ | head -5
else
    echo "❌ Pasta ~/.vim não existe"
fi

# Executar diagnóstico do vim
check_vim_config

echo ""
echo "🎯 Recomendações:"
echo ""

if [[ -f ~/.vimrc ]]; then
    echo "✅ Configuração OK - arquivo no local padrão"
    echo "   Nenhuma ação necessária"
elif [[ -f ~/.vim/vimrc ]]; then
    echo "✅ Configuração OK - arquivo em local alternativo válido"  
    echo "   Nenhuma ação necessária"
elif [[ -f ~/.vim/.vimrc ]]; then
    echo "🔧 AÇÃO RECOMENDADA:"
    echo "   mv ~/.vim/.vimrc ~/.vimrc"
    echo "   (mover para local padrão)"
    echo ""
    echo "🔄 Para executar automaticamente:"
    echo "   fix_vimrc_location"
else
    echo "❌ Nenhum arquivo .vimrc encontrado"
    echo "   Criar arquivo: vim ~/.vimrc"
    echo "   (seguir guia OSR2 arch-minimal-setup.md)"
fi

echo ""
echo "📚 Locais válidos para .vimrc:"
echo "   1. ~/.vimrc (padrão - recomendado)"
echo "   2. ~/.vim/vimrc (alternativo - sem ponto inicial!)"
echo "   3. ~/.vim/.vimrc via source (redirecionamento)"
echo ""
echo "🚀 Para testar após correção:"
echo "   vim test.c"
echo "   Deve mostrar: números de linha, syntax highlighting, barra status"