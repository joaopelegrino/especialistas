#!/bin/bash
# test-colorschemes.sh - Testador de Colorschemes Vim OSR2

echo "🎨 Testador de Colorschemes Vim para OSR2"
echo "========================================"

# Criar arquivo de exemplo para testar syntax highlighting
cat > vim-colorscheme-test.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

// Este é um comentário para testar highlighting
/* Comentário de bloco para testar cores */

#define KERNEL_SIZE 1024    // Macro definition
#define DEBUG 1

int main() {
    // Variáveis de diferentes tipos
    int counter = 42;
    char *message = "Hello OSR2!";
    float pi = 3.14159;
    
    // Estruturas de controle
    if (DEBUG) {
        printf("Debug mode: %s\n", message);
        for (int i = 0; i < KERNEL_SIZE; i++) {
            counter += i * 2;
        }
    }
    
    // Assembly inline (para testar highlighting)
    asm volatile (
        "movl $1, %%eax\n\t"
        "movl $0, %%ebx\n\t"
        "int $0x80"
        : : : "eax", "ebx"
    );
    
    return counter;
}
EOF

# Lista de colorschemes para testar
COLORSCHEMES=("default" "elflord" "koehler" "pablo" "ron" "torte" "desert" "darkblue" "blue" "evening" "morning" "peachpuff" "shine")

echo ""
echo "📝 Arquivo de teste criado: vim-colorscheme-test.c"
echo "🎯 Este arquivo contém:"
echo "   - Diferentes tipos de syntax (keywords, strings, comments)"
echo "   - Código C com inline assembly"
echo "   - Macros e diferentes tipos de dados"
echo ""

# TODO(human): Implementar função test_colorscheme()
# Função deve:
# 1. Receber nome do colorscheme como parâmetro
# 2. Abrir vim com o colorscheme aplicado
# 3. Carregar o arquivo de teste
# 4. Permitir visualização fácil das cores
function test_colorscheme() {
    local scheme=$1
    echo "🎨 Testando colorscheme: $scheme"
    # TODO(human): Implementar aqui
    # Dica: usar vim -c "comando1 | comando2" arquivo
    # Comandos úteis: colorscheme $scheme, syntax on, set number
}

echo "🔄 Métodos de teste disponíveis:"
echo ""
echo "MÉTODO 1 - Teste Individual:"
echo "   vim -c \"colorscheme koehler\" vim-colorscheme-test.c"
echo ""
echo "MÉTODO 2 - Teste Interativo no Vim:"
echo "   vim vim-colorscheme-test.c"
echo "   Depois no vim: :colorscheme [nome] e Tab para completar"
echo ""
echo "MÉTODO 3 - Loop de Testes (implementar função acima):"
for scheme in "${COLORSCHEMES[@]}"; do
    echo "   test_colorscheme $scheme"
done
echo ""
echo "🎯 Para testar:"
echo "1. chmod +x test-colorschemes.sh"
echo "2. ./test-colorschemes.sh"
echo "3. Use um dos métodos acima"
echo ""
echo "💡 Recomendados para OSR2:"
echo "   - koehler (melhor contraste para Assembly/C)"
echo "   - desert (popular, suave)"
echo "   - elflord (cores vibrantes)"
echo ""
echo "📚 Para aplicar permanentemente:"
echo "   vim ~/.vimrc"
echo "   Alterar linha: colorscheme default"
echo "   Para: colorscheme [escolhido]"