# Decomposição Técnica: Regex do Básico ao Avançado

## 🎯 Comando/Conceito Analisado
```bash
# Vim: :%s/\v^(\w+)\s+(\d{4})-(\d{2})-(\d{2}).*$/\1_\2\3\4/g
# Bash: if [[ "$file" =~ ^([a-zA-Z]+)_([0-9]{4})([0-9]{2})([0-9]{2})\.txt$ ]]; then
```

## 🏗️ Classificação Geral
- **Categoria Principal**: Pattern Matching / Text Processing
- **Complexidade**: Básico → Intermediário → Avançado
- **Tecnologias Envolvidas**: Vim Regex, Bash Pattern Matching, POSIX ERE, Glob Patterns

## 📐 Anatomia Visual Completa

### Exemplo Vim Regex: `\v^(\w+)\s+(\d{4})-(\d{2})-(\d{2}).*$`

```
\v^(\w+)\s+(\d{4})-(\d{2})-(\d{2}).*$
││ │ │   │   │ │    │  │    │ │   │  │
││ │ │   │   │ │    │  │    │ │   │  └── 7. End anchor ($)
││ │ │   │   │ │    │  │    │ │   └── 6. Any characters (.*)
││ │ │   │   │ │    │  │    │ └── 5. Group 4: Two digits (\d{2})
││ │ │   │   │ │    │  │    └── 4. Literal hyphen (-)
││ │ │   │   │ │    │  └── 3. Group 3: Two digits (\d{2})
││ │ │   │   │ │    └── 2. Literal hyphen (-)
││ │ │   │   │ └── 1. Group 2: Four digits (\d{4})
││ │ │   │   └── 0. One or more whitespace (\s+)
││ │ │   └── Group 1: One or more word chars (\w+)
││ │ └── Group opening (()
││ └── Start anchor (^)
│└── Very magic mode (\v)
└── Substitution command prefix (%s/)
```

### Exemplo Bash Pattern Matching: `^([a-zA-Z]+)_([0-9]{4})([0-9]{2})([0-9]{2})\.txt$`

```
^([a-zA-Z]+)_([0-9]{4})([0-9]{2})([0-9]{2})\.txt$
│ │        │ │      │ │      │ │      │  │   │
│ │        │ │      │ │      │ │      │  │   └── 9. End anchor ($)
│ │        │ │      │ │      │ │      │  └── 8. Literal "txt"
│ │        │ │      │ │      │ │      └── 7. Escaped literal dot (\.)
│ │        │ │      │ │      │ └── 6. Group 4: Two digits ([0-9]{2})
│ │        │ │      │ └── 5. Group 3: Two digits ([0-9]{2})
│ │        │ └── 4. Group 2: Four digits ([0-9]{4})
│ └── 3. Literal underscore (_)
└── 2. Group 1: One or more letters ([a-zA-Z]+)
└── 1. Start anchor (^)
```

## 🔍 Expansão Conceitual Detalhada

### Elemento 1: Substitution Command Prefix (`%s/`)

**Conceito**: Comando de substituição global no Vim que opera em todo o buffer.

**Anatomia Técnica**:
- `%` = Range specifier (todo o arquivo, equivale a `1,$`)
- `s` = Substitute command
- `/` = Delimiter separator

**Casos de Uso**:
```vim
" Substituição básica
:%s/old/new/g          " Substitui 'old' por 'new' globalmente

" Com confirmação
:%s/pattern/replacement/gc   " Pede confirmação para cada match

" Apenas na linha atual
:s/pattern/replacement/      " Sem % = só linha atual

" Range específico
:10,20s/pattern/replacement/ " Linhas 10-20
```

**Variações de Delimitadores**:
```vim
:%s/path\/to\/file/new_path/g     " Problemático: escaping /
:%s#path/to/file#new_path#g       # Melhor: usar # como delimiter
:%s|old|new|g                     # Ou pipe |
:%s@old@new@g                     # Ou arroba @
```

### Elemento 2: Very Magic Mode (`\v`)

**Conceito**: Modo que torna a maioria dos caracteres especiais ativos sem necessidade de escape.

**Comparação entre Modos**:
```vim
" Modo padrão (magic)
/\(\w\+\)\s\+\(\d\{4}\)     " Grupos e quantificadores escapados

" Very magic (\v)
/\v(\w+)\s+(\d{4})          " Sintaxe mais limpa, parecida com ERE
```

**Tabela de Diferenças**:
```
Padrão    Magic     Very Magic    Função
+         \+        +            One or more
?         \?        ?            Zero or one
{}        \{}       {}           Quantifiers
()        \(\)      ()           Groups
|         \|        |            Alternation
```

**Quando Usar**:
```vim
" Use \v para padrões complexos
:%s/\v(\w+)@(\w+)\.com/\1_at_\2_dot_com/g

" Use modo padrão para buscas simples
/palavra
/^início
```

### Elemento 3: Start Anchor (`^`)

**Conceito**: Assertion de posição que força o match no início da linha/string.

**Comportamento Contextual**:
```vim
" No Vim - início da linha
/^palavra        " Match apenas se 'palavra' inicia a linha
/palavra         " Match 'palavra' em qualquer posição

" Exemplos práticos
/^#              " Linhas comentadas (começam com #)
/^\s*$           " Linhas vazias ou só com espaços
/^[A-Z]          " Linhas começando com maiúscula
```

**No Bash ERE**:
```bash
# Início da string completa
[[ "$email" =~ ^[a-z]+@ ]]     # Email deve começar com letras
[[ "$path" =~ ^/ ]]            # Caminho absoluto (começa com /)
[[ "$line" =~ ^[[:space:]]*# ]] # Linha comentada
```

**Pegadinhas Comuns**:
```vim
" ❌ Erro comum - ^ no meio do padrão
/word^end        " ^ aqui é literal, não âncora

" ✅ Correto - ^ no início
/^word.*end      " Linha começando com 'word' e terminando com 'end'
```

### Elemento 4: Group Opening (`(`)

**Conceito**: Inicia um grupo de captura que pode ser referenciado posteriormente.

**Tipos de Grupos**:

**1. Grupos de Captura (Capturing Groups)**:
```vim
" Vim - grupos numerados
:%s/\v(word1)(word2)/\2 \1/g    " Troca posições: \1=group1, \2=group2

" Bash - BASH_REMATCH array
if [[ "$file" =~ ([a-z]+)_([0-9]+) ]]; then
    name="${BASH_REMATCH[1]}"    # Primeiro grupo
    num="${BASH_REMATCH[2]}"     # Segundo grupo
fi
```

**2. Grupos Não-Capturantes** (Vim 8.2+):
```vim
" Agrupa sem capturar para referência
/\v%(word1|word2)+     " Agrupa alternativas sem criar \1
```

**Aninhamento de Grupos**:
```vim
:%s/\v((\w+)\s+(\d+))/[\1]/g
"      │    │   │   │
"      │    │   │   └── Grupo 3: dígitos  
"      │    │   └── Grupo 2: palavra
"      │    └── Tudo junto
"      └── Grupo 1: palavra + espaço + dígitos
```

### Elemento 5: Word Character Class (`\w+`)

**Conceito**: Casa com caracteres de "palavra": letras, dígitos e underscore, uma ou mais vezes.

**Definição Técnica**:
```vim
\w = [a-zA-Z0-9_]      " Equivalência em character class
```

**Variações por Locale**:
```bash
# Em diferentes locales
LC_ALL=C    # \w = [a-zA-Z0-9_] (apenas ASCII)
LC_ALL=pt_BR.UTF-8    # \w inclui acentos: café, João, etc.
```

**Casos de Uso Específicos**:
```vim
" Nomes de variáveis em código
/\v<\w+>              " Palavras completas (com word boundaries)
/\v\w+\ze\s*=         " Variável antes de '=' (positive lookahead)

" Extração de dados
:%s/\v(\w+)@(\w+)/\1_AT_\2/g   " user@domain -> user_AT_domain
```

**Classes Alternativas**:
```vim
\W          " Não-word characters (oposto de \w)
[a-zA-Z]+   " Apenas letras (sem dígitos/underscore)
\a+         " Caracteres alfabéticos (Vim-specific)
[[:alnum:]] " POSIX - alphanumeric
```

### Elemento 6: Whitespace Class (`\s+`)

**Conceito**: Casa com um ou mais caracteres de espaçamento.

**Componentes de `\s`**:
```vim
\s = [ \t\n\r\f]      " space, tab, newline, carriage return, form feed
```

**Padrões Comuns**:
```vim
" Normalizar espaçamento
:%s/\v\s+/ /g          " Múltiplos espaços -> um espaço
:%s/\v^\s+//g          " Remove espaços no início
:%s/\v\s+$//g          " Remove espaços no final

" Dividir dados delimitados
:%s/\v(\w+)\s+(\w+)/\1,\2/g    " space-separated -> CSV
```

**Variações Específicas**:
```vim
\t          " Apenas tabs
\n          " Apenas newlines  
\r          " Carriage returns
[ \t]       " Apenas space e tab (sem newlines)
\s\+        " Modo magic: um ou mais espaços
```

### Elemento 7: Four Digits (`\d{4}`)

**Conceito**: Quantificador exato - exatamente 4 dígitos consecutivos.

**Sintaxe de Quantificadores**:
```vim
\d{4}       " Exatamente 4 dígitos
\d{2,4}     " De 2 a 4 dígitos  
\d{4,}      " 4 ou mais dígitos
\d{,4}      " Até 4 dígitos (0-4)
```

**Casos de Uso Temporais**:
```vim
" Anos (1900-2099)
/\v(19|20)\d{2}

" Datas ISO
/\v\d{4}-\d{2}-\d{2}

" Horários
/\v\d{2}:\d{2}(:\d{2})?    " HH:MM ou HH:MM:SS
```

**Validação Numérica**:
```bash
# Bash - validar formato
validate_year() {
    [[ "$1" =~ ^[0-9]{4}$ ]]
}

# Bash - extrair ano
extract_year() {
    [[ "$1" =~ ([0-9]{4}) ]] && echo "${BASH_REMATCH[1]}"
}
```

### Elemento 8: Literal Hyphen (`-`)

**Conceito**: Hífen literal usado como separador de data.

**Contextual vs Literal**:
```vim
" Literal hyphen
/2023-05-15        " Hífen como separador de data
/\v\d{4}-\d{2}     " Hífen literal entre dígitos

" Range hyphen (dentro de [])
/[a-z]             " Hífen define range a-z
/[a\-z]            " Hífen literal (escapado)
/[-az]             " Hífen literal (primeira posição)
/[az-]             " Hífen literal (última posição)
```

**Padrões de Data/Hora**:
```vim
" Formatos diferentes
\v\d{4}-\d{2}-\d{2}           " ISO: YYYY-MM-DD  
\v\d{2}/\d{2}/\d{4}           " US: MM/DD/YYYY
\v\d{2}-\d{2}-\d{4}           " BR: DD-MM-YYYY
```

### Elemento 9: Two Digits (`\d{2}`)

**Conceito**: Exatamente dois dígitos - comum em mês/dia/hora.

**Validação com Ranges**:
```vim
" Mês válido (01-12)
\v(0[1-9]|1[0-2])

" Dia válido simplificado (01-31)
\v(0[1-9]|[12][0-9]|3[01])

" Hora (00-23)
\v([01][0-9]|2[0-3])

" Minuto/Segundo (00-59)
\v[0-5][0-9]
```

**Uso em Substituições**:
```vim
" Reformatar data
:%s/\v(\d{4})-(\d{2})-(\d{2})/\3\/\2\/\1/g

" Adicionar zeros à esquerda
:%s/\v(\d{1,2})/0\1/g | %s/\v0(\d{2})/\1/g
```

### Elemento 10: Any Characters (`.*`)

**Conceito**: Zero ou mais caracteres quaisquer (exceto newline por padrão).

**Comportamento Greedy vs Lazy**:
```vim
" Greedy (padrão) - pega o máximo possível
/\v".*"            " Em 'test "a" and "b"' pega '"a" and "b"'

" Lazy - pega o mínimo (Vim: usar \{-})
/\v".{-}"          " Em 'test "a" and "b"' pega '"a"' primeiro
```

**Com Newlines**:
```vim
" Padrão - não inclui newlines
/.*                " Até o fim da linha

" Incluir newlines
/\_.*              " Qualquer char incluindo newline (Vim)
```

**Casos Práticos**:
```vim
" Remover do padrão até fim da linha
:%s/\vFROM.*$//g

" Capturar entre delimitadores
:%s/\v\[(.*)\]/(\1)/g         " [text] -> (text)
```

### Elemento 11: End Anchor (`$`)

**Conceito**: Assertion que força match no final da linha/string.

**Uso Estratégico**:
```vim
" Operações no final da linha
:%s/\s*$//g        " Remove espaços no final
:%s/$/;/g          " Adiciona ';' no final de cada linha
:%s/\v(.*)$/[\1]/g " Envolve linha inteira em colchetes
```

**Combinações com `^`**:
```vim
/^\s*$             " Linhas vazias
/^.*pattern.*$     " Linhas contendo 'pattern'
/^$                " Linhas completamente vazias
```

## 💡 Padrões de Construção Step-by-Step

### Construindo Regex Complexo Gradualmente:

**Objetivo**: Processar entrada "João Silva 1985-03-15 documento.pdf"

**Step 1** - Elementos básicos:
```vim
/\w+               " Encontra 'João', 'Silva', etc.
```

**Step 2** - Adicionar estrutura:
```vim
/\v\w+\s+\w+       " Nome + espaço + sobrenome
```

**Step 3** - Incluir data:
```vim
/\v\w+\s+\w+\s+\d{4}-\d{2}-\d{2}
```

**Step 4** - Capturar grupos:
```vim
/\v(\w+)\s+(\w+)\s+(\d{4})-(\d{2})-(\d{2})\s+(.*)
```

**Step 5** - Aplicar transformação:
```vim
:%s/\v(\w+)\s+(\w+)\s+(\d{4})-(\d{2})-(\d{2})\s+(.*)/\2, \1 [\3-\4-\5] -> \6/g
" Resultado: "Silva, João [1985-03-15] -> documento.pdf"
```

`★ Insight ─────────────────────────────────────`
Cada elemento regex tem comportamentos específicos dependendo do contexto. O `^` no início é âncora, mas `^` dentro de `[]` é negação. Compreender essas nuances contextuais é crucial para dominar regex.
`─────────────────────────────────────────────────`

## 📖 Nomenclatura e Classificação

### Elementos Vim Regex - Modo Very Magic (\v)

| Elemento | Nome Técnico | Categoria | Função | Pesquisar |
|----------|-------------|-----------|---------|-----------|
| `\v` | Very magic modifier | Vim mode control | Ativa modo "very magic" | `:help /\v` |
| `^` | Start anchor | Position assertion | Início da linha | `:help /^` |
| `$` | End anchor | Position assertion | Final da linha | `:help /$` |
| `()` | Capturing group | Group construct | Captura para referência | `:help /\(` |
| `\w` | Word character class | Character class | Letras, dígitos, underscore | `:help /\w` |
| `\d` | Digit character class | Character class | Dígitos 0-9 | `:help /\d` |
| `\s` | Space character class | Character class | Espaços, tabs, newlines | `:help /\s` |
| `+` | One-or-more quantifier | Quantifier | 1 ou mais ocorrências | `:help /\+` |
| `*` | Zero-or-more quantifier | Quantifier | 0 ou mais ocorrências | `:help /star` |
| `{n}` | Exact quantifier | Quantifier | Exatamente n ocorrências | `:help /\{` |
| `.` | Any character | Wildcard | Qualquer char exceto newline | `:help /.` |

### Elementos Bash Pattern Matching

| Elemento | Nome Técnico | Categoria | Função | Pesquisar |
|----------|-------------|-----------|---------|-----------|
| `=~` | Regex match operator | Bash operator | Match com POSIX ERE | `man bash` → "=~" |
| `^` | Start anchor | POSIX ERE | Início da string | `man 7 regex` |
| `$` | End anchor | POSIX ERE | Final da string | `man 7 regex` |
| `()` | Capturing group | POSIX ERE | Captura substrings | `man 7 regex` |
| `[a-zA-Z]` | Character class | POSIX ERE | Range de caracteres | `man 7 regex` |
| `[0-9]` | Digit class | POSIX ERE | Dígitos numéricos | `man 7 regex` |
| `+` | One-or-more | POSIX ERE | 1 ou mais repetições | `man 7 regex` |
| `{4}` | Exact quantifier | POSIX ERE | Exatamente 4 ocorrências | `man 7 regex` |
| `\.` | Escaped literal | POSIX ERE | Ponto literal | `man 7 regex` |

### Elementos Bash Glob Patterns (Pathname Expansion)

| Elemento | Nome Técnico | Categoria | Função | Pesquisar |
|----------|-------------|-----------|---------|-----------|
| `*` | Glob wildcard | Shell glob | Qualquer string | `man bash` → "Pattern Matching" |
| `?` | Single char wildcard | Shell glob | Um caractere qualquer | `man bash` → "Pattern Matching" |
| `[...]` | Character bracket | Shell glob | Um dos caracteres listados | `man bash` → "Pattern Matching" |
| `[!...]` | Negated bracket | Shell glob | Não um dos caracteres | `man bash` → "Pattern Matching" |
| `**` | Globstar | Shell glob | Recursivo (com globstar on) | `man bash` → "globstar" |

## 🎓 Progressão de Aprendizado

### Nível 1 - Fundamentos: Elementos Básicos

#### Vim - Modo Básico (\M - nomagic)
```vim
" Literais básicos
/palavra          " Encontra "palavra" literal
/\.txt            " Encontra ".txt" (ponto escaped)
/\*               " Encontra "*" (asterisco escaped)

" Âncoras essenciais
/^início          " Palavra no início da linha
/fim$             " Palavra no final da linha
```

#### Bash - Glob Patterns Básicos
```bash
# Wildcards simples
ls *.txt          # Todos arquivos .txt
ls arquivo?.log   # arquivo1.log, arquivoA.log, etc
ls [abc]*         # Arquivos começando com a, b, ou c
```

#### POSIX ERE Básico (Bash =~)
```bash
# Âncoras e literais
[[ "$var" =~ ^test ]]     # Começa com "test"
[[ "$var" =~ \.txt$ ]]    # Termina com ".txt"
[[ "$var" =~ test ]]      # Contém "test"
```

### Nível 2 - Combinações: Quantificadores e Classes

#### Vim - Classes de Caracteres
```vim
" Com \v (very magic)
/\v\w+            " Uma ou mais letras/dígitos
/\v\d{4}          " Exatamente 4 dígitos
/\v[a-z]*         " Zero ou mais letras minúsculas
/\v\s+            " Um ou mais espaços

" Sem \v (modo padrão - magic)
/\w\+             " Uma ou mais letras/dígitos (+ escaped)
/\d\{4}           " Exatamente 4 dígitos ({ escaped)
/[a-z]*           " Zero ou mais letras (sem escape)
```

#### Bash - Quantificadores ERE
```bash
# Usando =~ com quantificadores
[[ "$email" =~ ^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$ ]]
[[ "$phone" =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
[[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
```

#### Bash - Extended Globs (com `shopt -s extglob`)
```bash
shopt -s extglob
ls *.@(txt|log)      # Arquivos .txt OU .log
ls !(*.tmp)          # Todos EXCETO .tmp
ls *.+(txt|log)      # Um ou mais .txt ou .log
```

### Nível 3 - Padrões Complexos: Grupos e Referências

#### Vim - Grupos de Captura
```vim
" Captura e referência
:%s/\v(\w+) (\w+)/\2, \1/g    " Troca nome sobrenome
:%s/\v(\d{4})-(\d{2})-(\d{2})/\3\/\2\/\1/g  " DD-MM-YYYY -> DD/MM/YYYY

" Lookahead e lookbehind (Vim 7.4+)
/\v\w+\ze\s          " Palavra antes de espaço (positive lookahead)
/\v\w+\zs\d+         " Dígitos depois de palavra (marca início match)
```

#### Bash - Captura com BASH_REMATCH
```bash
# Capturando grupos
if [[ "$filename" =~ ^([a-z]+)_([0-9]{4})\.([a-z]+)$ ]]; then
    name="${BASH_REMATCH[1]}"
    year="${BASH_REMATCH[2]}"  
    extension="${BASH_REMATCH[3]}"
    echo "Nome: $name, Ano: $year, Ext: $extension"
fi
```

### Nível 4 - Maestria: Construções Avançadas

#### Vim - Operadores de Asserção
```vim
" Zero-width assertions
/\v<word>            " Palavra completa (word boundaries)
/\vword@!            " NÃO seguido por "word"
/\vword@=            " Seguido por "word" (não consome)
/\v(word)@<=test     " "test" precedido por "word"
/\v(word)@<!test     " "test" NÃO precedido por "word"
```

#### Bash - Padrões Condicionais Complexos
```bash
# Validação complexa de email
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Case com múltiplos padrões
case "$file" in
    *.@(jpg|jpeg|png|gif) )
        echo "Imagem detectada";;
    +([0-9])?(.+([0-9])) )
        echo "Número detectado";;
    *([[:space:]])@(README|readme)?(.@(md|txt)) )
        echo "Arquivo README detectado";;
esac
```

## 📚 Recursos de Estudo por Tecnologia

### Para Vim Regex:
- `:help pattern.txt` - Documentação completa
- `:help /magic` - Modos magic/nomagic
- `:help pattern-overview` - Visão geral dos elementos
- `:help /\v` - Very magic mode
- `:help substitute` - Comando :s/

### Para Bash Pattern Matching:
- `man bash` seção "Pattern Matching" - Glob patterns
- `man bash` procurar por "=~" - Regex operator
- `man 7 regex` - POSIX ERE documentation
- `info bash` seção "Pattern Matching" - Detalhes extended

### Para POSIX ERE:
- `man 7 regex` - Manual completo regex POSIX
- `man grep` - Exemplos práticos com -E
- `man sed` - Uso em stream editing

## 🔬 Laboratório Prático

### Exercício 1 - Isolando Componentes

**Teste elementos básicos individualmente:**

```bash
# Vim - teste cada elemento
vim test.txt
# Cole este conteúdo:
# João 2023-05-15 projeto.txt
# Maria 2022-12-03 documento.doc
# Pedro 2024-01-20 arquivo.log

# Teste individualmente:
/\v\w+           # Encontra palavras
/\v\d{4}         # Encontra anos
/\v-             # Encontra hifens
```

```bash
# Bash - teste globs
mkdir -p /tmp/regex_test
cd /tmp/regex_test
touch arquivo1.txt arquivo2.log test.md documento.doc imagem.jpg

# Teste individualmente:
ls *.txt         # Glob básico
ls arquivo?.*    # Single wildcard
ls *.[tl]*       # Character class
```

### Exercício 2 - Combinações Básicas

**Combine 2-3 elementos:**

```vim
" No Vim, teste combinações:
:%s/\v(\w+)\s+(\d{4})-(\d{2})-(\d{2})/\1_\2\3\4/g

" Depois teste variações:
:%s/\v(\w+)\s+(\d+)/\2_\1/g                    " Nome + qualquer número
:%s/\v(\w+)\.(\w+)/\1_backup.\2/g               " Arquivo + extensão
```

```bash
# Bash - combine patterns
for file in *; do
    if [[ "$file" =~ ^([a-z]+)[0-9]\.([a-z]+)$ ]]; then
        echo "Arquivo: ${BASH_REMATCH[1]}, Extensão: ${BASH_REMATCH[2]}"
    fi
done
```

### Exercício 3 - Comando Completo

**Reconstrua step-by-step:**

```bash
# Objetivo: converter "João 2023-05-15 projeto.txt" para "João_20230515"
# Step 1: identifique o padrão completo
# Step 2: determine os grupos de captura
# Step 3: construa o replacement
# Step 4: teste e ajuste
```

### Exercício 4 - Variações

**Modifique para casos diferentes:**

```vim
" Variação 1: formato americano MM-DD-YYYY
:%s/\v(\w+)\s+(\d{2})-(\d{2})-(\d{4})/\1_\4\2\3/g

" Variação 2: com horário
:%s/\v(\w+)\s+(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})/\1_\2\3\4_\5\6/g
```

```bash
# Variação Bash: diferentes formatos de arquivo
validate_filename() {
    case "$1" in
        *_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].* )
            echo "Formato YYYYMMDD detectado";;
        *_[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9].* )
            echo "Formato DD-MM-YYYY detectado";;
        * )
            echo "Formato não reconhecido";;
    esac
}
```

---

**🎯 Próximos Passos de Estudo:**

1. **Pratique** cada nível antes de avançar
2. **Teste** as variações nos exercícios
3. **Consulte** a documentação oficial para casos específicos  
4. **Combine** Vim e Bash patterns em workflows reais
5. **Explore** ferramentas como `grep -E`, `sed -E` para mais prática

**📝 Dica de Produtividade:** Crie um arquivo de "regex snippets" para padrões que você usa frequentemente!