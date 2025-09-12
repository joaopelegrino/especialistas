# Navegação entre Páginas de Help do Vim

## Comandos de Navegação: `g]`, `g<C-]>` e `:tselect`

Este guia explica como usar os três principais comandos para navegar entre páginas de help e tags no Vim.

### 🎯 Os Três Comandos Explicados

#### 1. `g]` - Sempre Lista Opções
```vim
g]                  " No cursor sobre uma palavra
{Visual}g]          " Com texto selecionado
```
- **Comportamento**: Sempre usa `:tselect` internamente
- **Quando usar**: Quando você quer **ver todas as opções** disponíveis para uma tag
- **Resultado**: Lista numerada de todas as tags que correspondem à palavra

#### 2. `g<C-]>` - Navegação Inteligente
```vim
g<C-]>              " No cursor sobre uma palavra  
{Visual}g<C-]>      " Com texto selecionado
```
- **Comportamento**: Usa `:tjump` internamente
- **Lógica inteligente**:
  - Se **1 tag**: pula direto (como `CTRL-]`)
  - Se **múltiplas tags**: mostra lista para escolher (como `g]`)
- **Quando usar**: Comportamento **adaptativo** - eficiente para navegação geral

#### 3. `:tselect` - Comando Direto
```vim
:tselect palavra          " Busca específica
:tselect                  " Usa última tag da tag stack  
:tselect /^write_         " Com padrão regexp
```
- **Comportamento**: Lista sempre todas as tags correspondentes
- **Vantagens**: Aceita **padrões regexp** e busca por nome específico

## 🔍 Detalhamento Completo do `:tselect`

### 📊 Interface Interativa Detalhada

O `:tselect` oferece uma interface rica e colorizada para navegação:

```
  # pri kind tag               file
  1 F   f    mch_init          os_amiga.c
  2 F   f    mch_init          os_unix.c  
  3 F   f    mch_init          os_win32.c
Type number and <Enter> (empty cancels): _
```

**Recursos da Interface**:
- **Colorização**: Tags e nomes de arquivos têm highlighting diferenciado
- **Numeração**: Cada tag tem um número para seleção rápida
- **Informações contextuais**: Mostra tipo da tag e arquivo de origem
- **Cancelamento**: Enter vazio ou `q` cancela a operação

### 🎛️ Controles Interativos Avançados

O `:tselect` suporta várias formas de interação:

**Métodos de Seleção**:
```vim
" Na interface do :tselect:
3<Enter>        " Seleciona tag número 3
<Enter>         " Cancela (entrada vazia)
q               " Cancela durante more-prompt
```

**More-Prompt Inteligente**:
- Para listas longas, aparece o more-prompt automático
- Digite `q` para sair completamente
- Digite número da tag diretamente no more-prompt (funcionalidade futura)

### 🔤 Padrões de Busca Avançados

O `:tselect` aceita padrões regexp sofisticados:

```vim
" Busca literal (padrão)
:tselect function_name

" Padrões com expressões regulares (iniciam com /)
:tselect /^init         " Tags que começam com 'init'
:tselect /.*_free$      " Tags que terminam com '_free'
:tselect /set.*option   " Tags contendo 'set' seguido de 'option'
:tselect /\cERROR       " Busca case-insensitive por 'ERROR'

" Padrões complexos
:tselect /\v^(get|set)_\w+$  " get_* ou set_* functions
:tselect /vim_\w*\ze_       " vim_* antes de underscore
```

### 📊 Análise das Colunas de Informação

```
  # pri kind tag               file
  1 FSC  f    init_function    current.c
  2 F C  f    init_function    utils.c  
  3 F    f    init_function    external.c
  4  SC  v    init_value       current.c
```

**Decodificação da Coluna `pri` (Prioridade)**:

| Código | Significado | Prioridade |
|--------|-------------|------------|
| `FSC` | Full + Static + Current file | Máxima (1) |
| `F C` | Full + Global + Current file | Alta (2) |
| `F  ` | Full + Global + Other file | Média-Alta (3) |
| `FS ` | Full + Static + Other file | Média (4) |
| ` SC` | Case-insensitive + Static + Current | Média-Baixa (5) |
| `  C` | Case-insensitive + Global + Current | Baixa (6) |
| `   ` | Case-insensitive + Global + Other | Muito Baixa (7) |
| ` S ` | Case-insensitive + Static + Other | Mínima (8) |

**Tipos de Tag Comuns (`kind`)**:
- `f` = function (função)
- `c` = class (classe)  
- `v` = variable (variável)
- `m` = member (membro de classe)
- `s` = struct (estrutura)
- `t` = typedef (definição de tipo)
- `d` = define (macro/define)
- `e` = enumerator (valor de enum)

### 🚀 Fluxo de Navegação Recomendado

#### Para Exploração (quando não conhece as opções):
1. Use `g]` sobre palavra/conceito
2. Examine lista de opções disponíveis  
3. Digite número + Enter para ir à tag específica
4. Use `CTRL-T` para voltar

#### Para Navegação Eficiente (uso geral):
1. Use `g<C-]>` - comportamento adaptativo
2. Se uma tag: vai direto
3. Se múltiplas: escolhe da lista
4. Use `CTRL-T` para voltar

#### Para Busca Específica:
```vim
:tselect function_name      " Busca literal
:tselect /^get_            " Funções que começam com 'get_'
:tselect /.*_init$         " Funções que terminam com '_init'  
```

### ⚡ Comandos Relacionados

| Comando | Função | Quando Usar |
|---------|---------|-------------|
| `CTRL-]` | Pula para primeira tag | Navegação rápida, uma tag |
| `g]` | Lista sempre (`:tselect`) | Exploração, múltiplas opções |  
| `g<C-]>` | Inteligente (`:tjump`) | Uso geral eficiente |
| `:tag nome` | Pula direto para tag | Busca específica |
| `CTRL-T` | Volta na tag stack | Navegação de retorno |
| `:tags` | Mostra pilha de tags | Verificar histórico |

### 💼 Casos de Uso Específicos do `:tselect`

#### 🔍 Exploração de APIs e Bibliotecas
```vim
" Descobrir todas as funções relacionadas a string
:tselect /str       " Encontra str*, *str*, etc.

" Explorar padrões de nomenclatura
:tselect /^vim_     " Todas as funções que começam com vim_
:tselect /_init$    " Todas as funções de inicialização

" Buscar por categoria de função
:tselect /\v(create|destroy|new|delete)  " Funções de lifecycle
```

#### 🚀 Navegação em Codebases Grandes
```vim
" Em projetos com múltiplas implementações
:tselect malloc     " Lista malloc de diferentes libs (libc, custom, etc.)

" Encontrar sobrecarga de funções (C++)
:tselect /operator  " Todos os operadores sobrecarregados

" Buscar definições em diferentes contextos
:tselect /^test_    " Todas as funções de teste
```

#### 🔧 Debug e Análise de Código
```vim
" Encontrar pontos de erro
:tselect /\c(error|fail|except)  " Case-insensitive para error handling

" Localizar callbacks e handlers
:tselect /\v(callback|handler|on_\w+)  " Padrões de callback

" Buscar configuração e setup
:tselect /\v(config|setup|init|settings)  " Funções de configuração
```

### 🎯 Casos Práticos Comparativos

#### Cenário 1 - Explorando uma API nova:
```vim
" Método tradicional:
g]                  " Lista todas as ocorrências de strlen
" Escolha entre implementação padrão, versões seguras, etc.

" Método avançado com :tselect:
:tselect /str.*len  " Encontra strlen, strnlen, wcslen, etc.
:tselect /\c.*safe  " Versões "safe" case-insensitive
```

#### Cenário 2 - Navegação rápida:
```vim  
" Para navegação geral:
g<C-]>              " Vai direto se única, ou pergunta se múltipla

" Para controle total:
:tselect function_name  " Sempre mostra todas as opções
```

#### Cenário 3 - Análise de arquitetura:
```vim
" Encontrar todos os pontos de entrada
:tselect /^main$    " Função main exata
:tselect /\v^(init|setup|start)_  " Funções de inicialização

" Mapear interfaces públicas
:tselect /^api_     " APIs públicas
:tselect /^_        " Funções privates (convenção underscore)
```

### 🔧 Comandos de Janela Split

Para trabalhar com múltiplas janelas:

```vim
CTRL-W g]           " g] em nova janela split
CTRL-W g<C-]>       " g<C-]> em nova janela split
:stselect palavra   " :tselect em nova janela split
:stjump palavra     " :tjump em nova janela split
```

### 📚 Tags de Prioridade

O Vim usa um sistema de prioridades para ordenar tags quando há múltiplas correspondências:

1. **FSC** - Full match, Static, Current file (máxima prioridade)
2. **F C** - Full match, Global, Current file  
3. **F  ** - Full match, Global, Other file
4. **FS ** - Full match, Static, Other file
5. ** SC** - Case-insensitive, Static, Current file
6. **  C** - Case-insensitive, Global, Current file
7. **   ** - Case-insensitive, Global, Other file
8. ** S ** - Case-insensitive, Static, Other file (menor prioridade)

### ⚙️ Configurações e Opções do `:tselect`

O comportamento do `:tselect` pode ser customizado através de várias opções:

#### Opções de Case Sensitivity
```vim
" Configurar comportamento de maiúscula/minúscula
:set tagcase=followic    " Segue 'ignorecase'
:set tagcase=followscs   " Segue 'ignorecase' e 'smartcase'  
:set tagcase=ignore      " Sempre ignora case
:set tagcase=match       " Sempre considera case
:set tagcase=smart       " Smart case (padrão recomendado)

" Exemplos práticos:
:set tagcase=smart
:tselect ERROR          " Case-sensitive (tem maiúscula)
:tselect error          " Case-insensitive (só minúsculas)
```

#### Controle de Performance  
```vim
" Para arquivos de tags grandes
:set tagbsearch          " Usa busca binária (mais rápido)
:set notagbsearch        " Busca linear (mais lento, mas funciona sempre)

" Limite de tempo para busca
:set tagstack           " Habilita tag stack (padrão)
:set notagstack         " Desabilita tag stack (útil para mapeamentos)
```

#### Configuração de Highlighting
```vim
" As cores do :tselect são controladas por highlight groups
:highlight TaglistTagName ctermfg=Blue guifg=Blue
:highlight TaglistFileName ctermfg=Green guifg=Green  
:highlight TaglistComment ctermfg=Gray guifg=Gray
```

### 🐛 Troubleshooting e Dicas Avançadas

#### Problemas Comuns
```vim
" Problema: Tags não encontradas
:set tags=./tags,tags,~/.vim/tags  " Define caminhos de busca

" Problema: Muitas tags irrelevantes
:tselect !/pattern/     " Busca negativa (não documentada oficialmente)

" Problema: Performance lenta
:set tagbsearch         " Força busca binária
```

#### Truques de Produtividade
```vim
" Mapear teclas para :tselect rápido
nnoremap <F3> :tselect <C-R><C-W><CR>    " F3 = tselect da palavra atual
nnoremap <F4> :tselect /^<C-R><C-W><CR>  " F4 = tselect prefixo da palavra

" Criar comandos personalizados
command! -nargs=1 Tsel tselect <args>    " :Tsel function_name
command! -nargs=1 TselPrefix tselect /^<args>  " :TselPrefix init
```

#### Debug de Tags
```vim
" Verificar arquivos de tags carregados
:set tags?

" Debug verbose de busca de tags  
:set verbosefile=debug.log
:set verbose=15
:tselect function_name
:set verbose=0
:set verbosefile=
```

### 💡 Dicas Importantes e Melhores Práticas

- **Tag Stack**: Todos os pulos de tag são salvos na tag stack, acessível com `:tags`
- **Retorno**: Use `CTRL-T` para voltar na tag stack
- **Regexp**: Use `/` no início para busca com expressões regulares
- **Case Sensitivity**: Controlada pelas opções `'tagcase'`, `'ignorecase'` e `'smartcase'`
- **More-Prompt**: Em listas longas, use `q` para cancelar ou `<Space>` para continuar
- **Performance**: Para projetos grandes, mantenha `tagbsearch` ativado
- **Organização**: Use `:tselect` para exploração, `g<C-]>` para navegação eficiente

### 🎓 Resumo de Uso

- **`g]`**: "Quero ver todas as opções sempre"
- **`g<C-]>`**: "Seja inteligente - direto se uma, lista se múltiplas"  
- **`:tselect`**: "Busca específica com controle total"

Esse sistema oferece controle total sobre como navegar pela documentação e código, desde exploração ampla até navegação direcionada e eficiente.