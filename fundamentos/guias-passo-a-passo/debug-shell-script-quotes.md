# 🐛 Debug Shell Script: Erros de Aspas - Guia Completo

## 🎯 Propósito
Resolver o erro "unexpected EOF while looking for matching quote" que ocorre quando aspas não são fechadas corretamente em scripts bash.

## 🔍 Diagnóstico do Erro

### Erro Reportado:
```bash
./script.sh: line 9: unexpected EOF while looking for matching `"'
```

### 📖 O que significa:
- **EOF**: End Of File (final do arquivo)
- **unexpected**: bash não esperava chegar ao final
- **matching quote**: bash estava procurando uma aspa de fechamento `"`
- **line 9**: o problema começou (ou foi detectado) na linha 9

## 🚀 Métodos de Diagnóstico com Vim

### Método 1: Verificação Visual no Vim
```bash
# vim script.sh
# 📖 Explicação: Abre script no vim para inspeção visual
# 📝 COMANDOS VIM PARA DEBUG:
# 1. :set number (mostra números das linhas)
# 2. /\" (busca por aspas duplas)
# 3. n (próxima ocorrência)
# 4. N (ocorrência anterior)
vim script.sh
```

**Dentro do vim:**
```vim
" Comandos para localizar aspas:
:set number          " Mostrar números das linhas
/"                   " Buscar próxima aspa dupla
:set hlsearch        " Realçar todas as ocorrências
%                    " Saltar para parênteses/aspas correspondentes
```

### Método 2: Syntax Checking no Vim
```vim
" Comando para verificar sintaxe bash:
:!bash -n %
" 📖 Explicação: Verifica sintaxe sem executar
" 🔧 Flag:
"    -n: no-execute, apenas verifica sintaxe
"    %: arquivo atual no vim
" ✅ Sucesso: nenhuma saída (arquivo correto)
" ❌ Erro: mostra linha e tipo do erro
```

### Método 3: Contagem de Aspas
```bash
# grep -o '"' script.sh | wc -l
# 📖 Explicação: Conta total de aspas duplas no arquivo
# 🔧 Flags:
#    grep -o: mostra apenas as matches, uma por linha
#    wc -l: conta número de linhas
# 💡 Resultado: número deve ser PAR (cada abertura tem fechamento)
grep -o '"' script.sh | wc -l
```

## 🔧 Problemas Comuns e Soluções

### Problema 1: Aspas não fechadas
```bash
# ❌ ERRADO:
echo "Iniciando processo
echo "Continuando...

# ✅ CORRETO:
echo "Iniciando processo"
echo "Continuando..."
```

### Problema 2: Aspas dentro de aspas
```bash
# ❌ ERRADO:
echo "O comando "ls -la" não funcionou"

# ✅ CORRETO - Método 1 (escape):
echo "O comando \"ls -la\" não funcionou"

# ✅ CORRETO - Método 2 (aspas simples):
echo 'O comando "ls -la" não funcionou'

# ✅ CORRETO - Método 3 (concatenação):
echo "O comando "'ls -la'" não funcionou"
```

### Problema 3: Quebras de linha em strings
```bash
# ❌ ERRADO:
echo "Esta é uma linha muito longa
que continua aqui"

# ✅ CORRETO - Método 1 (backslash):
echo "Esta é uma linha muito longa \
que continua aqui"

# ✅ CORRETO - Método 2 (fechamento por linha):
echo "Esta é uma linha muito longa"
echo "que continua aqui"
```

### Problema 4: Variáveis em strings
```bash
# ❌ PROBLEMÁTICO (pode gerar aspas não balanceadas):
arquivo="meu arquivo.txt"
echo "Processando $arquivo"

# ✅ CORRETO (aspas duplas para expansão):
arquivo="meu arquivo.txt"
echo "Processando \"$arquivo\""

# ✅ ALTERNATIVA (aspas simples evitam expansão):
echo 'Processando arquivo: ' "$arquivo"
```

## 🛠️ Script de Verificação Automática

### Criar verificador de aspas:
```bash
# vim check-quotes.sh
# 📝 CONTEÚDO DO SCRIPT:
vim check-quotes.sh
```

**Conteúdo do check-quotes.sh:**
```bash
#!/bin/bash
# check-quotes.sh - Verificador de aspas em scripts
# Uso: ./check-quotes.sh [arquivo.sh]

if [ $# -eq 0 ]; then
    echo "Uso: $0 <arquivo.sh>"
    exit 1
fi

arquivo="$1"

if [ ! -f "$arquivo" ]; then
    echo "Erro: Arquivo '$arquivo' não encontrado"
    exit 1
fi

echo "🔍 Verificando aspas em: $arquivo"
echo

# Contar aspas duplas
aspas_duplas=$(grep -o '"' "$arquivo" | wc -l)
echo "📊 Aspas duplas (\") encontradas: $aspas_duplas"

# Verificar se é número par
if [ $((aspas_duplas % 2)) -eq 0 ]; then
    echo "✅ Aspas duplas: OK (número par)"
else
    echo "❌ Aspas duplas: PROBLEMA (número ímpar - falta fechamento)"
fi

# Contar aspas simples
aspas_simples=$(grep -o "'" "$arquivo" | wc -l)
echo "📊 Aspas simples (') encontradas: $aspas_simples"

if [ $((aspas_simples % 2)) -eq 0 ]; then
    echo "✅ Aspas simples: OK (número par)"
else
    echo "❌ Aspas simples: PROBLEMA (número ímpar - falta fechamento)"
fi

echo
echo "🧪 Verificação de sintaxe bash:"
if bash -n "$arquivo"; then
    echo "✅ Sintaxe: OK"
else
    echo "❌ Sintaxe: ERRO DETECTADO"
fi
```

### Tornar executável e usar:
```bash
# chmod +x check-quotes.sh
chmod +x check-quotes.sh

# ./check-quotes.sh script.sh
./check-quotes.sh script.sh
```

## 🎯 Estratégia de Correção

### Passo 1: Localizar o problema
1. Use vim para abrir o script
2. Vá para a linha 9: `:9`
3. Examine aspas nesta linha e adjacentes
4. Use `/"` para buscar próximas aspas

### Passo 2: Verificar contexto
```vim
" No vim, examine linha por linha:
:set number
:9        " Ir para linha 9
:8,12p    " Mostrar linhas 8 a 12 para contexto
```

### Passo 3: Identificar o padrão
- Cada `"` de abertura tem seu fechamento `"`?
- Há quebras de linha dentro de strings?
- Variáveis estão sendo expandidas corretamente?

### Passo 4: Corrigir sistematicamente
1. Começar da linha indicada no erro
2. Verificar uma linha de cada vez
3. Testar com `bash -n script.sh` após cada correção

## ✅ Validação Final

### Comandos de teste:
```bash
# bash -n script.sh
# 📖 Explicação: Verifica sintaxe sem executar
# ✅ Sucesso: nenhuma saída
# ❌ Falha: mostra erro específico
bash -n script.sh

# shellcheck script.sh  
# 📖 Explicação: Análise avançada de scripts (se disponível)
# 🔧 Instalação no Arch: pacman -S shellcheck
# 💡 Saída: avisos e sugestões de melhoria
shellcheck script.sh
```

## 💡 Dicas de Prevenção

### 1. Use editor com highlighting:
```vim
" No ~/.vimrc:
syntax on
set number
filetype on
```

### 2. Sempre teste sintaxe antes de executar:
```bash
bash -n meu-script.sh && echo "Sintaxe OK" || echo "Erro de sintaxe"
```

### 3. Use aspas consistentemente:
- `"..."` para strings que precisam expansão de variáveis
- `'...'` para strings literais
- `\"` para aspas literais dentro de strings

### 4. Quebre linhas longas corretamente:
```bash
# Use backslash para continuar linha:
echo "Esta linha é muito longa \
e continua aqui"

# Ou separe em múltiplas linhas:
echo "Primeira parte"
echo "Segunda parte"
```

## 🎯 Próximos Passos

1. **Aplique verificação**: Use os métodos acima no seu script
2. **Identifique o problema**: Localize a aspa não fechada
3. **Corrija sistematicamente**: Uma linha de cada vez
4. **Teste regularmente**: `bash -n` após cada mudança
5. **Documente soluções**: Para referência futura

## 📚 Recursos Adicionais

- **Bash Manual**: `man bash` (seção sobre quoting)
- **Shellcheck**: Ferramenta de análise de scripts
- **Vim Syntax**: `:help syntax` para highlighting
- **Debug Bash**: `bash -x script.sh` para execução verbosa