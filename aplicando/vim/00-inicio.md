# Guia Completo do Vim Vanilla: Do Zero ao Domínio

## Índice

1. [Introdução e Fundamentos](#1-introdução-e-fundamentos)
2. [Conceitos Fundamentais](#2-conceitos-fundamentais)
3. [Modos de Operação](#3-modos-de-operação)
4. [Sistema de Comandos](#4-sistema-de-comandos)
5. [Navegação e Movimentação](#5-navegação-e-movimentação)
6. [Edição de Texto](#6-edição-de-texto)
7. [Busca e Substituição](#7-busca-e-substituição)
8. [Gerenciamento de Arquivos](#8-gerenciamento-de-arquivos)
9. [Navegação Visual e Exploração](#9-navegação-visual-e-exploração)
10. [Buffers, Janelas e Abas](#10-buffers-janelas-e-abas)
11. [Sistema de Busca Avançada](#11-sistema-de-busca-avançada)
12. [Configuração e Personalização](#12-configuração-e-personalização)
13. [Workflows e Produtividade](#13-workflows-e-produtividade)
14. [Resolução de Problemas](#14-resolução-de-problemas)
15. [Recursos Avançados](#15-recursos-avançados)

---

## 1. Introdução e Fundamentos

### O que é o Vim?

O Vim (Vi IMproved) é um editor de texto modal altamente configurável, descendente do editor vi original criado para sistemas Unix. O termo "modal" significa que o Vim opera em diferentes modos, cada um com comportamentos específicos para diferentes tipos de tarefas.

#### Por que Vim Vanilla?

"Vanilla" refere-se ao Vim em sua forma pura, sem plugins ou extensões externas. Este guia foca exclusivamente nas funcionalidades nativas porque:

- **Universalidade**: Funciona em qualquer sistema onde o Vim está instalado
- **Velocidade**: Sem overhead de plugins externos
- **Estabilidade**: Funcionalidades testadas e maduras
- **Aprendizado**: Base sólida antes de extensões
- **Portabilidade**: Configurações funcionam em qualquer ambiente

#### Filosofia do Design

O Vim segue princípios específicos que influenciam sua operação:

1. **Composição**: Comandos simples combinam para operações complexas
2. **Repetição**: Padrão `.` repete a última ação
3. **Eficiência**: Mãos permanecem no teclado principal
4. **Precisão**: Comandos específicos para tarefas específicas
5. **Extensibilidade**: Sistema configurável sem perder essência

#### Terminologia Essencial

Antes de prosseguir, é fundamental compreender os termos básicos:

- **Buffer**: Área de memória contendo texto de um arquivo
- **Janela**: Viewport que exibe um buffer
- **Aba**: Coleção de janelas
- **Cursor**: Posição atual no texto
- **Comando**: Instrução dada ao Vim
- **Mapeamento**: Associação de teclas a comandos
- **Registro**: Área de armazenamento temporário

---

## 2. Conceitos Fundamentais

### Estrutura de Comandos

Os comandos no Vim seguem uma gramática consistente que, uma vez compreendida, torna o editor previsível e poderoso.

#### Anatomia de um Comando

A estrutura básica é: `[count][operator][text-object]` ou `[count][operator][motion]`

**Componentes explicados:**

1. **Count (opcional)**: Número que especifica quantas vezes executar
   - Exemplo: `3` em `3dd` significa "execute 3 vezes"
   - Se omitido, assume valor 1

2. **Operator**: Ação a ser executada
   - `d` = delete (deletar)
   - `y` = yank (copiar)
   - `c` = change (alterar)
   - `>` = indent (indentar)

3. **Text-object ou Motion**: Especifica o que será afetado
   - `w` = word (palavra)
   - `l` = character to the right (caractere à direita)
   - `iw` = inner word (palavra interna)
   - `ap` = a paragraph (um parágrafo)

#### Exemplos Práticos

```vim
" Comando: d3w
" Significado: delete 3 words (deletar 3 palavras)
" d = operator (deletar)
" 3 = count (3 vezes)
" w = motion (palavra)

" Comando: c2l
" Significado: change 2 characters to the right
" c = operator (alterar)
" 2 = count (2 vezes)
" l = motion (caractere à direita)

" Comando: y5j
" Significado: yank 5 lines down
" y = operator (copiar)
" 5 = count (5 vezes)
" j = motion (linha abaixo)
```

### Operadores Fundamentais

#### Delete (d)
Remove texto e o coloca no registro padrão (clipboard interno do Vim).

```vim
dd     " Delete line (deletar linha inteira)
dw     " Delete word (deletar palavra)
d$     " Delete to end of line (deletar até fim da linha)
d0     " Delete to beginning of line (deletar até início da linha)
```

#### Yank (y)
Copia texto para o registro padrão sem removê-lo.

```vim
yy     " Yank line (copiar linha inteira)
yw     " Yank word (copiar palavra)
y$     " Yank to end of line (copiar até fim da linha)
```

#### Change (c)
Remove texto e entra em modo insert imediatamente.

```vim
cc     " Change line (alterar linha inteira)
cw     " Change word (alterar palavra)
c$     " Change to end of line (alterar até fim da linha)
```

### Text Objects

Text objects definem unidades semânticas de texto que podem ser manipuladas como entidades completas.

#### Sintaxe de Text Objects

Format: `[a|i][text-object-type]`

- **a** = "a" (around) - inclui delimitadores/espaços
- **i** = "inner" - apenas o conteúdo interno

#### Tipos de Text Objects

```vim
" Palavras
iw     " inner word (palavra sem espaços)
aw     " a word (palavra com espaços adjacentes)

" Sentenças
is     " inner sentence (sentença sem espaços)
as     " a sentence (sentença com espaços)

" Parágrafos
ip     " inner paragraph (parágrafo sem linhas vazias)
ap     " a paragraph (parágrafo com linhas vazias)

" Delimitadores
i"     " inner quotes (conteúdo entre aspas)
a"     " a quotes (conteúdo + aspas)
i(     " inner parentheses (conteúdo entre parênteses)
a(     " a parentheses (conteúdo + parênteses)
i{     " inner braces (conteúdo entre chaves)
a{     " a braces (conteúdo + chaves)
```

#### Exemplos Práticos de Text Objects

```vim
" Deletar palavra onde está o cursor
diw    " delete inner word

" Copiar conteúdo entre aspas
yi"    " yank inner quotes

" Alterar conteúdo entre parênteses
ci(    " change inner parentheses

" Deletar parágrafo inteiro
dap    " delete a paragraph
```

### Motions (Movimentos)

Motions definem como navegar pelo texto e são fundamentais para a eficiência no Vim.

#### Motions Básicos

```vim
" Caracteres
h      " left (esquerda)
j      " down (baixo)
k      " up (cima)
l      " right (direita)

" Palavras
w      " next word beginning (início próxima palavra)
b      " previous word beginning (início palavra anterior)
e      " word end (fim da palavra)
ge     " previous word end (fim palavra anterior)

" Linhas
0      " beginning of line (início da linha)
^      " first non-blank character (primeiro caractere não-espaço)
$      " end of line (fim da linha)
```

#### Motions Avançados

```vim
" Busca por caracteres na linha
f{char}    " find character forward (encontrar caractere à frente)
F{char}    " find character backward (encontrar caractere atrás)
t{char}    " till character forward (até caractere à frente)
T{char}    " till character backward (até caractere atrás)

" Repetir busca de caractere
;          " repeat last f/F/t/T forward (repetir última busca à frente)
,          " repeat last f/F/t/T backward (repetir última busca atrás)

" Parágrafos e blocos
{          " previous blank line (linha vazia anterior)
}          " next blank line (próxima linha vazia)
```

### Registers (Registros)

Os registros são áreas de armazenamento que o Vim usa para texto copiado, deletado ou manipulado.

#### Tipos de Registros

```vim
" Registro padrão
""     " default register (registro padrão)

" Registros nomeados (a-z)
"a     " named register 'a' (registro nomeado 'a')
"z     " named register 'z' (registro nomeado 'z')

" Registros especiais
"+     " system clipboard (clipboard do sistema)
"*     " primary selection (seleção primária)
"0     " yank register (registro de cópia)
"1-"9  " delete registers (registros de deleção)
".     " last inserted text (último texto inserido)
"%     " current file name (nome arquivo atual)
```

#### Usando Registros

```vim
" Copiar para registro nomeado
"ayy   " yank line to register 'a'

" Colar de registro específico
"ap    " paste from register 'a'

" Ver conteúdo dos registros
:reg   " show all registers
:reg a " show register 'a' only
```

---

## 3. Modos de Operação

O Vim opera em diferentes modos, cada um com propósito específico. Compreender os modos é fundamental para usar o Vim eficientemente.

### Normal Mode (Modo Normal)

O modo normal é o estado padrão do Vim, onde você navega e executa comandos sem inserir texto.

#### Características do Modo Normal

- **Propósito**: Navegação, comandos, manipulação de texto
- **Indicador**: Cursor geralmente em bloco sólido
- **Acesso**: Pressione `Esc` de qualquer outro modo

#### Comandos Essenciais no Modo Normal

```vim
" Navegação básica
h j k l    " left, down, up, right (esquerda, baixo, cima, direita)

" Comandos de edição
x          " delete character under cursor (deletar caractere sob cursor)
X          " delete character before cursor (deletar caractere antes cursor)
r{char}    " replace character (substituir caractere)
~          " toggle case (alternar maiúscula/minúscula)

" Comandos de linha
o          " open line below (abrir linha abaixo)
O          " open line above (abrir linha acima)
J          " join lines (juntar linhas)
```

### Insert Mode (Modo Insert)

No modo insert, o Vim se comporta como um editor tradicional onde você digita texto diretamente.

#### Entrando no Modo Insert

```vim
i          " insert before cursor (inserir antes do cursor)
I          " insert at beginning of line (inserir no início da linha)
a          " append after cursor (adicionar após cursor)
A          " append at end of line (adicionar no fim da linha)
o          " open line below (abrir linha abaixo)
O          " open line above (abrir linha acima)
```

#### Comandos Úteis no Modo Insert

```vim
" Navegação limitada
Ctrl-h     " backspace (apagar caractere anterior)
Ctrl-w     " delete word backward (deletar palavra anterior)
Ctrl-u     " delete line backward (deletar linha anterior)

" Auto-completar
Ctrl-n     " next completion (próxima sugestão)
Ctrl-p     " previous completion (sugestão anterior)
Ctrl-x Ctrl-f    " file name completion (completar nome arquivo)
Ctrl-x Ctrl-l    " line completion (completar linha)
```

#### Saindo do Modo Insert

```vim
Esc        " return to normal mode (voltar ao modo normal)
Ctrl-c     " return to normal mode (alternativa ao Esc)
Ctrl-[     " return to normal mode (outra alternativa)
```

### Visual Mode (Modo Visual)

O modo visual permite selecionar texto para aplicar comandos em blocos específicos.

#### Tipos de Seleção Visual

```vim
v          " character-wise selection (seleção por caractere)
V          " line-wise selection (seleção por linha)
Ctrl-v     " block-wise selection (seleção em bloco)
```

#### Trabalhando com Seleções

```vim
" Após selecionar texto:
d          " delete selection (deletar seleção)
y          " yank selection (copiar seleção)
c          " change selection (alterar seleção)
>          " indent selection (indentar seleção)
<          " unindent selection (desindentar seleção)
```

#### Exemplos Práticos de Modo Visual

```vim
" Selecionar palavra atual
viw        " visual inner word (selecionar palavra interna)

" Selecionar até fim da linha
v$         " visual to end of line (visual até fim da linha)

" Selecionar parágrafo
vap        " visual a paragraph (visual um parágrafo)

" Seleção em bloco para edição colunar
Ctrl-v     " start block selection (iniciar seleção em bloco)
# Mova cursor para definir área
I          " insert at beginning of all selected lines
# Digite texto que será inserido em todas as linhas
Esc        " apply to all lines (aplicar a todas as linhas)
```

### Command Mode (Modo Comando)

O modo comando permite executar comandos Ex (extended commands) que oferecem funcionalidades avançadas.

#### Entrando no Modo Comando

```vim
:          " enter command mode (entrar no modo comando)
/          " search forward (buscar à frente)
?          " search backward (buscar atrás)
```

#### Comandos Fundamentais

```vim
" Arquivo
:w         " write (salvar)
:q         " quit (sair)
:wq        " write and quit (salvar e sair)
:q!        " quit without saving (sair sem salvar)

" Navegação
:123       " go to line 123 (ir para linha 123)
:$         " go to last line (ir para última linha)

" Busca e substituição
:%s/old/new/g    " substitute all occurrences (substituir todas ocorrências)
```

### Replace Mode (Modo Replace)

O modo replace sobrescreve caracteres existentes em vez de inserir texto novo.

```vim
R          " enter replace mode (entrar no modo replace)
r{char}    " replace single character (substituir caractere único)
```

---

## 4. Sistema de Comandos

### Estrutura de Comando Ex

Os comandos Ex seguem uma sintaxe estruturada que permite operações complexas.

#### Formato Geral

```
:[range]command[!][args]
```

#### Componentes Explicados

1. **Range (opcional)**: Especifica linhas afetadas
2. **Command**: O comando a ser executado
3. **! (opcional)**: Força execução (bypass confirmações)
4. **Args (opcional)**: Argumentos para o comando

#### Exemplos de Range

```vim
:1,5       " lines 1 to 5 (linhas 1 até 5)
:%         " all lines (todas as linhas)
:.         " current line (linha atual)
:.+5       " current line plus 5 (linha atual mais 5)
:$         " last line (última linha)
:'a,'b     " from mark 'a' to mark 'b' (da marca 'a' até marca 'b')
```

### Comandos de Arquivo

#### Operações Básicas

```vim
" Salvar
:w                    " write current file (salvar arquivo atual)
:w filename          " write to specific file (salvar em arquivo específico)
:wa                  " write all files (salvar todos os arquivos)

" Abrir
:e filename          " edit file (editar arquivo)
:e!                  " reload current file (recarregar arquivo atual)

" Sair
:q                   " quit (sair)
:qa                  " quit all (sair de todos)
:q!                  " quit without saving (sair sem salvar)
```

#### Navegação entre Arquivos

```vim
" Histórico de arquivos
Ctrl-o               " go to older cursor position (posição anterior cursor)
Ctrl-i               " go to newer cursor position (posição posterior cursor)

" Arquivo alternativo
Ctrl-^               " switch to alternate file (alternar arquivo alternativo)
```

### Comandos de Busca

#### Busca Básica

```vim
/pattern             " search forward (buscar à frente)
?pattern             " search backward (buscar atrás)
n                    " next match (próxima ocorrência)
N                    " previous match (ocorrência anterior)
```

#### Busca com Modificadores

```vim
/\cpattern           " case insensitive search (busca ignorando maiúsculas)
/\Cpattern           " case sensitive search (busca sensível a maiúsculas)
/pattern\c           " case insensitive (alternativa)
```

#### Busca Incremental

O Vim oferece busca incremental que mostra resultados conforme você digita.

```vim
" No .vimrc para habilitar:
set incsearch        " incremental search (busca incremental)
set hlsearch         " highlight search results (destacar resultados)
```

### Comandos de Substituição

#### Sintaxe Básica

```vim
:s/old/new/          " substitute first occurrence in line (primeira ocorrência na linha)
:s/old/new/g         " substitute all in line (todas na linha)
:%s/old/new/g        " substitute all in file (todas no arquivo)
:%s/old/new/gc       " substitute with confirmation (com confirmação)
```

#### Flags de Substituição

```vim
g                    " global (all occurrences in line)
c                    " confirm each substitution
i                    " ignore case
I                    " don't ignore case
```

#### Exemplos Avançados

```vim
" Substituir apenas em linhas específicas
:1,10s/old/new/g     " lines 1 to 10 only

" Usar registro como replacement
:%s/old/\=@a/g       " replace with contents of register 'a'

" Substituição com regex groups
:%s/\(word\)/[\1]/g  " wrap 'word' in brackets
```

---

## 5. Navegação e Movimentação

### Navegação por Caracteres

#### Movimentos Básicos

```vim
h                    " one character left (um caractere à esquerda)
j                    " one line down (uma linha abaixo)
k                    " one line up (uma linha acima)
l                    " one character right (um caractere à direita)
```

#### Movimentos com Count

```vim
5h                   " five characters left (cinco caracteres à esquerda)
3j                   " three lines down (três linhas abaixo)
10l                  " ten characters right (dez caracteres à direita)
```

### Navegação por Palavras

#### Tipos de Palavras

O Vim distingue entre dois tipos de palavras:

1. **word**: Sequência de letras, dígitos e sublinhados
2. **WORD**: Sequência de caracteres não-brancos

```vim
" Navegação por word (palavra)
w                    " next word beginning (início próxima palavra)
b                    " previous word beginning (início palavra anterior)
e                    " word end (fim da palavra)
ge                   " previous word end (fim palavra anterior)

" Navegação por WORD (PALAVRA)
W                    " next WORD beginning (início próxima PALAVRA)
B                    " previous WORD beginning (início PALAVRA anterior)
E                    " WORD end (fim da PALAVRA)
gE                   " previous WORD end (fim PALAVRA anterior)
```

#### Exemplos Práticos

Para o texto: `hello-world test_function`

```vim
" Posicionado no 'h' de hello:
w      " move para 'w' de world (hello-world é uma palavra)
W      " move para 't' de test (hello-world é uma PALAVRA)
```

### Navegação por Linhas

#### Movimentos Horizontais

```vim
0                    " beginning of line (início da linha)
^                    " first non-blank character (primeiro caractere não-vazio)
$                    " end of line (fim da linha)
g_                   " last non-blank character (último caractere não-vazio)
```

#### Busca de Caracteres na Linha

```vim
f{char}              " find character forward (encontrar caractere à frente)
F{char}              " find character backward (encontrar caractere atrás)
t{char}              " till character forward (até caractere à frente)
T{char}              " till character backward (até caractere atrás)
;                    " repeat last f/F/t/T (repetir último f/F/t/T)
,                    " repeat last f/F/t/T reverse (repetir inverso)
```

#### Exemplo de Busca de Caracteres

Para a linha: `function(arg1, arg2, arg3)`

```vim
" Posicionado no 'f':
f(     " move para '('
t,     " move para espaço antes da primeira ','
;      " move para espaço antes da segunda ','
,      " volta para espaço antes da primeira ','
```

### Navegação por Blocos

#### Parágrafos e Seções

```vim
{                    " previous blank line (linha vazia anterior)
}                    " next blank line (próxima linha vazia)
]]                   " next section (próxima seção)
[[                   " previous section (seção anterior)
```

#### Parênteses e Chaves

```vim
%                    " matching bracket/parenthesis (parêntese/chave correspondente)
```

Para código com `if (condition) { ... }`:

```vim
" Posicionado em '(':
%      " move para ')' correspondente
" Posicionado em '{':
%      " move para '}' correspondente
```

### Navegação por Tela

#### Movimentos de Tela

```vim
H                    " top of screen (topo da tela)
M                    " middle of screen (meio da tela)
L                    " bottom of screen (fundo da tela)
```

#### Rolagem

```vim
Ctrl-u               " scroll up half page (rolar meia página para cima)
Ctrl-d               " scroll down half page (rolar meia página para baixo)
Ctrl-b               " scroll up full page (rolar página completa para cima)
Ctrl-f               " scroll down full page (rolar página completa para baixo)
```

#### Reposicionamento da Tela

```vim
zz                   " center current line (centralizar linha atual)
zt                   " move current line to top (linha atual para topo)
zb                   " move current line to bottom (linha atual para fundo)
```

### Navegação por Marcas

#### Criando Marcas

```vim
m{letter}            " set mark (definir marca)
```

Marcas locais (a-z): Funcionam apenas no arquivo atual
Marcas globais (A-Z): Funcionam entre arquivos

```vim
ma                   " set local mark 'a' (definir marca local 'a')
mA                   " set global mark 'A' (definir marca global 'A')
```

#### Navegando para Marcas

```vim
'{mark}              " go to line of mark (ir para linha da marca)
`{mark}              " go to exact position of mark (ir para posição exata da marca)
```

#### Marcas Especiais

```vim
''                   " last jump position (última posição de salto)
'.                   " last change position (última posição de alteração)
'^                   " last insert position (última posição de inserção)
```

### Jump List

O Vim mantém uma lista de posições onde você "saltou" para permitir navegação pelo histórico.

```vim
Ctrl-o               " go to older position (ir para posição anterior)
Ctrl-i               " go to newer position (ir para posição posterior)
:jumps               " show jump list (mostrar lista de saltos)
```

#### O que Constitui um "Jump"

- Comandos G, gg, %
- Busca com / ou ?
- Marcas com ' ou `
- Alguns comandos de edição

---

## 6. Edição de Texto

### Inserção de Texto

#### Comandos de Inserção

```vim
i                    " insert before cursor (inserir antes do cursor)
I                    " insert at beginning of line (inserir no início da linha)
a                    " append after cursor (adicionar após cursor)
A                    " append at end of line (adicionar no fim da linha)
o                    " open line below (abrir linha abaixo)
O                    " open line above (abrir linha acima)
```

#### Inserção com Count

```vim
5i*                  " insert 5 asterisks (inserir 5 asteriscos)
# Digite '*' e pressione Esc
# Resultado: *****
```

### Deleção de Texto

#### Deleção Básica

```vim
x                    " delete character under cursor (deletar caractere sob cursor)
X                    " delete character before cursor (deletar caractere antes cursor)
dd                   " delete line (deletar linha)
D                    " delete to end of line (deletar até fim da linha)
```

#### Deleção com Motions

```vim
dw                   " delete word (deletar palavra)
d2w                  " delete 2 words (deletar 2 palavras)
d$                   " delete to end of line (deletar até fim da linha)
d0                   " delete to beginning of line (deletar até início da linha)
dG                   " delete to end of file (deletar até fim do arquivo)
d1G                  " delete to beginning of file (deletar até início do arquivo)
```

#### Deleção com Text Objects

```vim
diw                  " delete inner word (deletar palavra interna)
daw                  " delete a word (deletar uma palavra)
di(                  " delete inner parentheses (deletar dentro parênteses)
da(                  " delete a parentheses (deletar parênteses inteiros)
di"                  " delete inner quotes (deletar dentro aspas)
da"                  " delete a quotes (deletar aspas inteiras)
```

### Cópia (Yank) de Texto

#### Comandos de Cópia

```vim
yy                   " yank line (copiar linha)
Y                    " yank line (alternativa a yy)
yw                   " yank word (copiar palavra)
y$                   " yank to end of line (copiar até fim da linha)
```

#### Cópia para Registros Específicos

```vim
"ayy                 " yank line to register 'a' (copiar linha para registro 'a')
"Ayy                 " append line to register 'a' (adicionar linha ao registro 'a')
```

### Colagem (Put) de Texto

#### Comandos de Colagem

```vim
p                    " put after cursor (colar após cursor)
P                    " put before cursor (colar antes cursor)
```

#### Colagem de Registros Específicos

```vim
"ap                  " put from register 'a' (colar do registro 'a')
"+p                  " put from system clipboard (colar do clipboard sistema)
```

### Alteração de Texto

#### Comandos de Change

O comando `c` (change) deleta texto e entra em modo insert.

```vim
cc                   " change line (alterar linha)
cw                   " change word (alterar palavra)
c$                   " change to end of line (alterar até fim da linha)
```

#### Change com Text Objects

```vim
ciw                  " change inner word (alterar palavra interna)
ci(                  " change inner parentheses (alterar dentro parênteses)
ci"                  " change inner quotes (alterar dentro aspas)
```

### Substituição de Caracteres

```vim
r{char}              " replace character (substituir caractere)
R                    " enter replace mode (entrar modo replace)
~                    " toggle case (alternar maiúscula/minúscula)
```

#### Exemplos de Substituição

```vim
" Para alterar 'hello' para 'Hello':
# Posicione cursor no 'h'
~                    " torna 'h' em 'H'

" Para substituir caractere:
# Posicione cursor no caractere desejado
ra                   " substitui por 'a'
```

### Junção de Linhas

```vim
J                    " join lines (juntar linhas)
gJ                   " join lines without space (juntar sem espaço)
```

### Indentação

```vim
>>                   " indent line (indentar linha)
<<                   " unindent line (desindentar linha)
>}                   " indent to next paragraph (indentar até próximo parágrafo)
```

#### Indentação no Modo Visual

```vim
# Selecione texto em modo visual
>                    " indent selection (indentar seleção)
<                    " unindent selection (desindentar seleção)
```

### Desfazer e Refazer

```vim
u                    " undo (desfazer)
Ctrl-r               " redo (refazer)
U                    " undo all changes in line (desfazer todas alterações na linha)
```

#### Navegação no Histórico de Desfazer

```vim
:undolist            " show undo tree (mostrar árvore de desfazer)
g-                   " go to older state (ir para estado anterior)
g+                   " go to newer state (ir para estado posterior)
```

### Repetição de Comandos

```vim
.                    " repeat last command (repetir último comando)
```

#### Exemplo Prático de Repetição

```vim
# Digite 'dd' para deletar uma linha
dd
# Mova para outra linha e pressione '.'
.                    " repete 'dd' (deleta outra linha)
```

### Macros

Macros permitem gravar sequências de comandos para repetição automática.

#### Gravando Macros

```vim
q{letter}            " start recording macro (iniciar gravação de macro)
# Execute comandos desejados
q                    " stop recording (parar gravação)
```

#### Executando Macros

```vim
@{letter}            " execute macro (executar macro)
@@                   " repeat last macro (repetir última macro)
5@a                  " execute macro 'a' 5 times (executar macro 'a' 5 vezes)
```

#### Exemplo de Macro

```vim
# Gravar macro para adicionar ponto e vírgula no fim da linha:
qa                   " start recording macro 'a'
A;                   " append ';' at end of lisc                  " return to normal mode
q                    " stop recording

# Executar macro:
@a                   " execute macro 'a'
```

---

## 7. Busca e Substituição

### Busca Básica

#### Comandos de Busca

```vim
/pattern             " search forward (buscar à frente)
?pattern             " search backward (buscar atrás)
n                    " next match (próxima ocorrência)
N                    " previous match (ocorrência anterior)
```

#### Repetindo Buscas

```vim
//             repeat last search forward (repetir última busca à frente)
??                   " repeat last search backward (repetir última busca atrás)
```

### Padrões de Busca

#### Caracteres Literais

Para buscar caracteres especiais literalmente, use escape (`\`):

```vim
/\.                  " search for literal dot (buscar ponto literal)
/\*                  " search for literal asterisk (buscar asterisco literal)
/\[                  " search for literal bracket (buscar colchete literal)
```

#### Metacarac Básicos

```vim
.                    " any character (qualquer caractere)
*                    " zero or more of previous (zero ou mais do anterior)
^                    " beginning of line (início da linha)
$                    " end of line (fim da linha)
```

#### Exemplos de Padrões

```vim
/^hello              " 'hello' at beginning of line ('hello' no início da linha)
/world$              " 'world' at end of line ('world' no fim da linha)
/h.llo               " 'hello', 'hallo', etc. ('hello', 'h', etc.)
```

### Regex Avançado

#### Classes de Caracteres

```vim
[abc]                " any of a, b, or c (qualquer: a, b, ou c)
[a-z]                " any lowercase letter (qualquer letra minúscula)
[A-Z]                " any uppercase letter (qualquer letra maiúscula)
[0-9]                " any digit (qualquer dígito)
[^abc]               " anything except a, b, or c (qualquer exceto a, b, ou c)
```

#### Quantificadores

```vim
\+                   " one or more (um ou mais)
\?                   ro or one (zero ou um)
\{n}                 " exactly n (exatamente n)
\{n,}                " n or more (n ou mais)
\{n,m}               " between n and m (entre n e m)
```

#### Grupos e Alternativas

```vim
\(pattern\)          " group (grupo)
\|                   " or (ou)
```

#### Exemplos Avançados

```vim
/\<word\>            " whole word 'word' (palavra completa 'word')
/\d\+                " one or more digits (um ou mais dígitos)
/\(cat\|dog\)        " 'cat' or 'dog' ('cat' ou 'dog')
```

### Moficadores de Busca

#### Case Sensitivity

```vim
/\cpattern           " case insensitive (ignorar maiúsculas/minúsculas)
/\Cpattern           " case sensitive (sensível a maiúsculas/minúsculas)
```

#### Magic Mode

```vim
/\vpattern           " very magic (very magic - mais metacaracteres ativos)
/\Vpattern           " very nomagic (very nomagic - menos metacaracteres ativos)
```

### Configurações de Busca

#### Opções Úteis

```vim
:set ignorecase      " ignore case in searches (ignorar maiússcas)
:set smartcase       " override ignorecase if pattern has uppercase
:set incsearch       " incremental search (busca incremental)
:set hlsearch        " highlight search results (destacar resultados)
```

#### Limpando Highlights

```vim
:noh                 " clear search highlights (limpar destaques de busca)
:nohlsearch          " versão completa do comando acima
```

### Substituição Avançada

#### Sintaxe Completa

```vim
:[range]s/pattern/replacement/flags
```

#### Flags de Substituição


g                    " global (todas ocorrências na linha)
c                    " confirm (confirmar cada substituição)
i                    " ignore case (ignorar maiúsculas/minúsculas)
I                    " don't ignore case (não ignorar maiúsculas/minúsculas)
e                    " suppress error if pattern not found (suprimir erro se padrão não encontrado)
```

#### Ranges de Substituição

```vim
:s/old/new/          " current line only (apenas linha atual)
:%s/old/new/g        " entire fiinteiro)
:1,10s/old/new/g     " lines 1 to 10 (linhas 1 a 10)
:.,$s/old/new/g      " current line to end (linha atual até fim)
:'<,'>s/old/new/g    " visual selection (seleção visual)
```

#### Usando Grupos em Substituição

```vim
:%s/\(word\)/[\1]/g  " wrap 'word' in brackets (envolver 'word' em colchetes)
:%s/\(\w\+\) \(\w\+\)/\2 \1/g  " swap two words (trocar duas palavras)
```

### Busca em Múltiplos Arquivos

#### Vimgrep

```vim
:vimgrep /pattern/ **/*.txt     " search in all .txt files recursivimgrep /pattern/g %           " search in current file
```

#### Navegando Resultados

```vim
:copen               " open quickfix window (abrir janela quickfix)
:cnext               " next match (próxima ocorrência)
:cprev               " previous match (ocorrência anterior)
:cfirst              " first match (primeira ocorrência)
:clast               " last match (última ocorrência)
```

### Histórico de Busca

#### Acessando Histórico

```vim
/{pattern}           " start search, then use arrows  busca, depois usar setas)
q/                   " open search history window (abrir janela histórico busca)
q?                   " open backward search history (abrir histórico busca reversa)
```

#### Navegando no Histórico

No modo comando, use setas ou:

```vim
Ctrl-p               " previous in history (anterior no histórico)
Ctrl-n               " next in history (próximo no histórico)
```

### Expressões de Substituição

#### Usando Expressões

```vim
:%s/pattern/\=expression/g
```

#### Exexpressões

```vim
:%s/\d\+/\=submatch(0)+1/g      " increment all numbers (incrementar todos números)
:%s/.*/\=line('.')/g            " replace with line numbers (substituir por números linha)
```

---

## 8. Gerenciamento de Arquivos

### Operações Básicas de Arquivo

#### Abrindo Arquivos

```vim
:e filename          " edit file (editar arquivo)
:e!                  " reload current file (recarregar arquivo atual)
:e .                 " browse current directory (navegar diretório atual)
```

#### S Arquivos

```vim
:w                   " write current file (salvar arquivo atual)
:w filename          " save as (salvar como)
:wa                  " write all open files (salvar todos arquivos abertos)
:w!                  " force write (forçar escrita)
```

#### Saindo do Vim

```vim
:q                   " quit (sair)
:q!                  " quit without saving (sair sem salvar)
:wq                  " save and quit (salvar e sair)
:x                   " save and quit (alternativa)
ZZ                   " ave and quit (atalho normal mode)
ZQ                   " quit without saving (atalho normal mode)
```

### Navegação de Diretórios

#### Netrw - Explorador Nativo

O Vim inclui o netrw, um explorador de arquivos nativo.

```vim
:e .                 " open netrw in current directory (abrir netrw no diretório atual)
:E                   " open netrw (alias para :e .)
:Sex                 " split horizontally and open netrw (dividir horizontalmente)
:Vex                 " split vertically and open netrw (dir verticalmente)
:Tex                 " open netrw in new tab (abrir netrw em nova aba)
```

#### Comandos no Netrw

Dentro do netrw:

```vim
Enter               " open file or enter directory (abrir arquivo ou entrar diretório)
-                   " go up one directory (subir um diretório)
o                   " open in horizontal split (abrir em divisão horizontal)
v                   " open in vertical split (abrir em divisão vertical)
t                   " open in new tab (abrir em nova aba)
p               " preview file (pré-visualizar arquivo)
i                   " cycle through view styles (alternar estilos visualização)
s                   " sort by name/time/size (ordenar por nome/tempo/tamanho)
r                   " reverse sort order (inverter ordem)
gh                  " toggle hidden files (alternar arquivos ocultos)
```

#### Configuração do Netrw

```vim
" No .vimrc:
let g:netrw_banner = 0          " remove banner (remover banner)
let g:netrw_liststyle = 3       " tree view (visualizarvore)
let g:netrw_browse_split = 4    " open in previous window (abrir janela anterior)
let g:netrw_altv = 1           " open splits to right (abrir divisões à direita)
let g:netrw_winsize = 25        " 25% width (largura 25%)
```

### Comando :find

O comando `:find` busca arquivos no path configurado.

#### Configurando Path

```vim
:set path+=**        " search recursively (buscar recursivamente)
:set path+=/usr/include    " add specific directory (adicionar diretório específico)
```

#### Usando Fi```vim
:find filename       " find and open file (encontrar e abrir arquivo)
:find *.h           " find header files (encontrar arquivos header)
```

### Wildcard e Completion

#### Tab Completion

```vim
:e fil<Tab>         " complete filename (completar nome arquivo)
:e **/*test<Tab>    " complete recursively (completar recursivamente)
```

#### Configuração de Wildcards

```vim
:set wildmenu       " enable wildmenu (habilitar wildmenu)
:set wildmode=longest:full,full  " completion mode (modo completaç
:set wildignore=*.pyc,*.o        " ignore patterns (ignorar padrões)
```

### Arquivos Recentes

#### Histórico de Arquivos

```vim
:oldfiles           " list recently opened files (listar arquivos recentes)
:browse oldfiles    " browse recent files (navegar arquivos recentes)
```

#### Reabrindo Arquivos

```vim
Ctrl-^              " switch to alternate file (alternar arquivo alternativo)
```

### Informações de Arquivo

#### Status do Arquivo

```vim
Ctrl-g              " show file info (mostrar infouivo)
g Ctrl-g            " show detailed file info (mostrar info detalhada)
:file               " show filename and status (mostrar nome e status)
```

#### Comparação de Arquivos

```vim
:diffsplit file2    " diff with another file (comparar com outro arquivo)
:diffthis           " make current window part of diff (tornar janela atual parte diff)
:diffoff            " turn off diff mode (desligar modo diff)
```

### Backup e Recuperação

#### Configuração de Backup

```vim
:set backup         " enabkup (habilitar backup)
:set backupdir=~/.vim/backup  " backup directory (diretório backup)
:set writebackup    " backup before writing (backup antes escrita)
```

#### Swap Files

```vim
:set swapfile       " enable swap files (habilitar arquivos swap)
:set directory=~/.vim/swap    " swap directory (diretório swap)
```

#### Recuperação de Crash

```vim
:recover filename   " recover from swap file (recuperar de arquivo swap)
vim -r filename     " recover from command line (recuperar da linha comando)
``## Encoding e Format

#### Configuração de Encoding

```vim
:set encoding=utf-8     " internal encoding (encoding interno)
:set fileencoding=utf-8 " file encoding (encoding arquivo)
:set fileencodings=utf-8,latin1  " encoding detection (detecção encoding)
```

#### Format de Arquivo

```vim
:set fileformat=unix    " line endings (terminações linha)
:set fileformats=unix,dos,mac  " format detection (detecção formato)
```

### Operações de Diretório

#### Mudança de Diretório

```vim
:cd directornge directory (mudar diretório)
:pwd                " show current directory (mostrar diretório atual)
:lcd directory      " local directory change (mudança diretório local)
```

#### Criação de Arquivos e Diretórios

No netrw:

```vim
%                   " create new file (criar novo arquivo)
d                   " create new directory (criar novo diretório)
```

### Gestão de Path

#### Configuração Inteligente

```vim
" Exemplo para projeto C:
:set path=.,/usr/include,**
:set suffixesadd=.c,.h
eexpr=substitute(v:fname,'\.','\/','g')
```

#### Usando gf (go to file)

```vim
gf                  " go to file under cursor (ir para arquivo sob cursor)
Ctrl-w f            " open file in new window (abrir arquivo nova janela)
Ctrl-w gf           " open file in new tab (abrir arquivo nova aba)
```

---

## 9. Navegação Visual e Exploração

### Lexplore - Explorador Lateral

O comando `:Lexplore` (ou `:Lex`) é uma funcionalidade poderosa do netrw que cria um explorador de arquivos persistente.

#### dos Lexplore

```vim
:Lex                " toggle file explorer (alternar explorador arquivos)
:Lex dirname        " open explorer in specific directory (abrir em diretório específico)
:Lex!               " open explorer on right side (abrir do lado direito)
```

#### Configuração Otimizada

```vim
" Configuração recomendada para Lexplore:
let g:netrw_banner = 0          " remove banner
let g:netrw_liststyle = 3       " tree style
let g:netrw_browse_split = 4    " open files in previous window
let g:nltv = 1           " open splits to the right
let g:netrw_winsize = 25        " 25% width
let g:netrw_keepdir = 0        " keep current directory synced

" Mapeamento para acesso rápido:
nnoremap <leader>e :Lex<CR>
```

### Variações do Explorador

#### Diferentes Tipos de Split

```vim
:Ex                 " explore current directory (explorar diretório atual)
:Sex                " split horizontally and explore (dividir horizontalmente)
:Vex                " split vertically and explore (dividir verticate)
:Tex                " open in new tab (abrir em nova aba)
:Rex                " return to/from explorer (retornar para/do explorador)
```

### Navegação Dentro do Netrw

#### Comandos de Movimento

```vim
Enter               " enter directory or open file (entrar diretório ou abrir arquivo)
-                   " go up directory (subir diretório)
u                   " go back in history (voltar no histórico)
U                   " go forward in history (avançar no histórico)
gb                  " gevious bookmark (ir marca anterior)
```

#### Comandos de Visualização

```vim
i                   " cycle listing style (alternar estilo listagem)
"                   " thin, long, wide, tree (fino, longo, largo, árvore)
s                   " select sorting style (selecionar estilo ordenação)
"                   " name, time, size (nome, tempo, tamanho)
r                   " reverse sort order (inverter ordem)
```

#### Comandos de Arquivo

```vim
o                   " open in horizontal split (abrir ão horizontal)
v                   " open in vertical split (abrir divisão vertical)
t                   " open in new tab (abrir nova aba)
p                   " preview file (pré-visualizar arquivo)
```

### Marcação e Operações em Lote

#### Sistema de Marcas

```vim
mf                  " mark file (marcar arquivo)
mF                  " unmark file (desmarcar arquivo)
mu                  " unmark all (desmarcar todos)
```

#### Operações com Arquivos Marcados

```vim
mt                  " enter tectory (entrar diretório alvo)
mc                  " copy marked files (copiar arquivos marcados)
mm                  " move marked files (mover arquivos marcados)
md                  " diff marked files (comparar arquivos marcados)
```

### Criação e Manipulação

#### Novos Arquivos e Diretórios

```vim
%                   " create new file (criar novo arquivo)
d                   " create new directory (criar novo diretório)
D                   " delete file/directory (deletar arquivo/diretório)
R           " rename file (renomear arquivo)
```

### Filtros e Ocultação

#### Arquivos Ocultos

```vim
gh                  " toggle hidden files (alternar arquivos ocultos)
a                   " toggle showing all files (alternar mostrar todos)
```

#### Filtros Personalizados

```vim
" Configuração de filtros:
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'  " hide dotfiles
```

### Configuração Avançada do Netrw

#### Personalização Completa

```vim
" Configuração avançada no .vimrc:

" Aparêtrw_banner = 0                " remove banner
let g:netrw_liststyle = 3             " tree view
let g:netrw_browse_split = 4          " open in prior window
let g:netrw_altv = 1                  " open splits to right
let g:netrw_winsize = 25              " 25% of page

" Comportamento
let g:netrw_keepdir = 0               " keep current directory synced
let g:netrw_localcopydircmd = 'cp -r' " copy command for directories

" Arquivos ignorados
let g:netrw_list_hide = netrw_gitignore#Hide()
let g:netrw_list_hide .= ',\(^\|\s\s\)\zs\.\S\+'

" Mapeamentos personalizados dentro do netrw
augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

function! NetrwMapping()
    noremap <buffer> H u        " go back in history
    noremap <buffer> h -^       " go up directory
    noremap <buffer> l <CR>     " open file/directory
    noremap <buffer> . gh       " toggle hidden files
    noremap <buffer> P <C-w>z   " close preview
endfunction
```

### Navegação por Tabs e Windows

## Gestão de Abas

```vim
:tabnew             " create new tab (criar nova aba)
:tabnew filename    " open file in new tab (abrir arquivo nova aba)
:tabclose           " close current tab (fechar aba atual)
:tabonly            " close all other tabs (fechar outras abas)
```

#### Navegação entre Abas

```vim
gt                  " next tab (próxima aba)
gT                  " previous tab (aba anterior)
{count}gt           " go to tab number (ir para aba número)
:tabn               " next tab (próxima abap               " previous tab (aba anterior)
```

#### Gestão de Janelas

```vim
Ctrl-w s            " split horizontally (dividir horizontalmente)
Ctrl-w v            " split vertically (dividir verticalmente)
Ctrl-w c            " close window (fechar janela)
Ctrl-w o            " close other windows (fechar outras janelas)
```

#### Navegação entre Janelas

```vim
Ctrl-w h            " move to left window (mover janela esquerda)
Ctrl-w j            " move to window below (mover janela abaixo)
Ctrl-w           " move to window above (mover janela acima)
Ctrl-w l            " move to right window (mover janela direita)
Ctrl-w w            " cycle through windows (circular janelas)
```

### Redimensionamento de Janelas

#### Comandos de Redimensionamento

```vim
Ctrl-w =            " equalize window sizes (equalizar tamanhos)
Ctrl-w +            " increase height (aumentar altura)
Ctrl-w -            " decrease height (diminuir altura)
Ctrl-w >            " increase width (aumentar largura)
Ctrl-w <            " decrease width (diminuir largura)
Ctrl-w _            " maximize height (maximizar altura)
Ctrl-w |            " maximize width (maximizar largura)
```

#### Redimensionamento com Numbers

```vim
10 Ctrl-w +         " increase height by 10 (aumentar altura em 10)
5 Ctrl-w >          " increase width by 5 (aumentar largura em 5)
```

### Layouts de Janela

#### Reorganização

```vim
Ctrl-w H            " move window to far left (mover janela extrema esquerda)
Ctrl-w J            " move window to boom (mover janela para baixo)
Ctrl-w K            " move window to top (mover janela para cima)
Ctrl-w L            " move window to far right (mover janela extrema direita)
```

#### Rotação

```vim
Ctrl-w r            " rotate windows downward (rotacionar janelas para baixo)
Ctrl-w R            " rotate windows upward (rotacionar janelas para cima)
```

### Integração com Sistema de Arquivos

#### Comando gf (Go to File)

```vim
gf                  " go to file under cursor (ir arquivo sob cursor)
Ctrl            " open file in new window (abrir arquivo nova janela)
Ctrl-w gf           " open file in new tab (abrir arquivo nova aba)
```

#### Configuração para gf

```vim
" Configurar suffixesadd para diferentes tipos de arquivo:
set suffixesadd=.js,.ts,.py,.c,.h,.css,.html
```

### Bookmarks Globais

#### Criando Bookmarks

```vim
mA                  " set global bookmark A (definir bookmark global A)
mB                  " set global bookmark B (definir bookmark global B)
```

#### Navegando para Bookmks

```vim
'A                  " go to line of bookmark A (ir linha bookmark A)
`A                  " go to exact position of bookmark A (ir posição exata bookmark A)
```

### Sessões de Trabalho

#### Criando Sessões

```vim
:mksession projeto.vim    " create session file (criar arquivo sessão)
:mksession! projeto.vim   " overwrite session file (sobrescrever arquivo sessão)
```

#### Carregando Sessões

```vim
:source projeto.vim       " load session (carregar sessão)
vim -S projeto.vim        " locommand line (carregar linha comando)
```

#### Configuração Automática de Sessões

```vim
" Auto-save session on exit:
autocmd VimLeave * if v:this_session != "" | exe "mksession! " . v:this_session | endif

" Function to save session per directory:
function! MakeSession()
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    if (filewritable(b:sessiondir) != 2)
        exe 'silent !mkdir -p ' . b:sessiondir
    endif
    exe "mksession! " . b:sessiondir . "/session.vim"
endfunction
```

---

0. Buffers, Janelas e Abas

### Conceito de Buffers

Um buffer é uma área de memória onde o Vim carrega o conteúdo de um arquivo. É importante entender que buffers, janelas e abas são conceitos diferentes:

- **Buffer**: O arquivo carregado na memória
- **Window**: Uma viewport que exibe um buffer
- **Tab**: Uma coleção de janelas

#### Estados dos Buffers

```vim
" Indicadores no :ls
%                   " current buffer (buffer atual)
#                   " alternate buffer (buffer alternativo)
a          " active buffer (buffer ativo)
h                   " hidden buffer (buffer oculto)
+                   " modified buffer (buffer modificado)
-                   " unmodifiable buffer (buffer não modificável)
=                   " readonly buffer (buffer somente leitura)
```

### Comandos de Buffer

#### Listando Buffers

```vim
:ls                 " list all buffers (listar todos buffers)
:buffers            " same as :ls (mesmo que :ls)
:files              " same as :ls (mesmo que :ls)
```

#### vegação entre Buffers

```vim
:b name             " switch to buffer by name (mudar para buffer por nome)
:b number           " switch to buffer by number (mudar para buffer por número)
:bn                 " next buffer (próximo buffer)
:bp                 " previous buffer (buffer anterior)
:bf                 " first buffer (primeiro buffer)
:bl                 " last buffer (último buffer)
```

#### Tab Completion para Buffers

```vim
:b <Tab>            " cycle through buffer names (alternar nomes r)
:b part<Tab>        " complete partial name (completar nome parcial)
```

#### Buffer Alternativo

```vim
Ctrl-^              " switch to alternate buffer (alternar buffer alternativo)
:b#                 " same as Ctrl-^ (mesmo que Ctrl-^)
```

### Gerenciamento de Buffers

#### Abrindo Buffers

```vim
:e filename         " edit file (creates new buffer) (editar arquivo - cria novo buffer)
:badd filename      " add file to buffer list (adicionar arquivo lista buffer)
```

#### Fechando Buffers

```vim
:bd                 " delete current buffer (deletar buffer atual)
:bd number          " delete specific buffer (deletar buffer específico)
:bd name            " delete buffer by name (deletar buffer por nome)
:bw                 " wipe buffer (remove from buffer list) (limpar buffer)
```

#### Salvando Múltiplos Buffers

```vim
:wa                 " write all buffers (salvar todos buffers)
:wall               " same as :wa (mesmo que :wa)
```

### Configuração de Buffers

#### Hidden Buffers

```vim
:sedden         " allow hidden buffers (permitir buffers ocultos)
```

Esta configuração permite ter buffers modificados em background sem precisar salvá-los.

#### Autocomandos para Buffers

```vim
" Exemplo: mostrar número de buffers na statusline
autocmd BufEnter * let &titlestring = expand('%:t') . ' (' . len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) . ' buffers)'
```

### Janelas (Windows)

#### Criando Janelas

```vim
:split              " horizontal split (divisão horizontal)
:sp            " short form (forma abreviada)
:vsplit             " vertical split (divisão vertical)
:vs                 " short form (forma abreviada)
:split filename     " split and open file (dividir e abrir arquivo)
:vsplit filename    " vertical split and open file (divisão vertical e abrir arquivo)
```

#### Navegação entre Janelas

```vim
Ctrl-w h            " move to left window (mover janela esquerda)
Ctrl-w j            " move to bottom window (mover janela inferior)
Ctrl-w k            " move to top windoover janela superior)
Ctrl-w l            " move to right window (mover janela direita)
Ctrl-w w            " cycle through windows (alternar janelas)
Ctrl-w p            " go to previous window (ir janela anterior)
```

#### Fechando Janelas

```vim
:q                  " quit current window (sair janela atual)
Ctrl-w c            " close current window (fechar janela atual)
Ctrl-w o            " close all other windows (fechar outras janelas)
:only               " same as Ctrl-w o (mesmo que Ctrl-w o)
```

### Redimensionamento de Janelas

#### Comandos Básicos

```vim
Ctrl-w =            " equalize all window sizes (equalizar tamanhos)
Ctrl-w +            " increase height (aumentar altura)
Ctrl-w -            " decrease height (diminuir altura)
Ctrl-w >            " increase width (aumentar largura)
Ctrl-w <            " decrease width (diminuir largura)
```

#### Maximização

```vim
Ctrl-w _            " maximize height (maximizar altura)
Ctrl-w |            " maximize width (maximizar largura)
```

##Redimensionamento com Count

```vim
10 Ctrl-w +         " increase height by 10 lines (aumentar altura 10 linhas)
5 Ctrl-w >          " increase width by 5 columns (aumentar largura 5 colunas)
```

### Movimentação de Janelas

#### Reorganização

```vim
Ctrl-w H            " move window to far left (mover janela extrema esquerda)
Ctrl-w J            " move window to bottom (mover janela para baixo)
Ctrl-w K            " move window to top (mover janela para cima)
Ctrl-w L            " move window to farht (mover janela extrema direita)
```

#### Rotação

```vim
Ctrl-w r            " rotate windows clockwise (rotacionar janelas sentido horário)
Ctrl-w R            " rotate windows counter-clockwise (rotacionar anti-horário)
```

#### Troca de Janelas

```vim
Ctrl-w x            " exchange current window with next (trocar janela atual com próxima)
```

### Abas (Tabs)

#### Conceito de Abas

No Vim, uma aba é uma coleção de janelas. Diferente de editores tradicionais onde abas representam arquivos, ada aba pode conter múltiplas janelas exibindo diferentes buffers.

#### Criando Abas

```vim
:tabnew             " create new empty tab (criar nova aba vazia)
:tabnew filename    " create new tab with file (criar nova aba com arquivo)
:tabe filename      " same as :tabnew filename (mesmo que :tabnew filename)
```

#### Navegação entre Abas

```vim
gt                  " next tab (próxima aba)
gT                  " previous tab (aba anterior)
{count}gt           " go to tab number (ir para aba número)
:              " next tab (próxima aba)
:tabp               " previous tab (aba anterior)
:tabfirst           " first tab (primeira aba)
:tablast            " last tab (última aba)
```

#### Gerenciamento de Abas

```vim
:tabclose           " close current tab (fechar aba atual)
:tabc               " short form (forma abreviada)
:tabonly            " close all other tabs (fechar outras abas)
:tabo               " short form (forma abreviada)
```

#### Movimentação de Abas

```vim
:tabmove            " moab to end (mover aba para fim)
:tabmove 0          " move tab to beginning (mover aba para início)
:tabmove 3          " move tab to position 3 (mover aba para posição 3)
```

#### Operações em Todas as Abas

```vim
:tabdo command      " execute command in all tabs (executar comando em todas abas)
:tabdo %s/old/new/g " substitute in all tabs (substituir em todas abas)
```

### Workflow Eficiente com Buffers

#### Mapeamentos Úteis

```vim
" Configuração recomendada no .vimrc:
nnoremap <leader>bb :lspace>        " list and select buffer
nnoremap <leader>bd :bd<CR>                 " delete buffer
nnoremap <leader>bn :bn<CR>                 " next buffer
nnoremap <leader>bp :bp<CR>                 " previous buffer
nnoremap <leader>ba :%bd|e#<CR>             " close all but current
```

#### Função para Fechar Buffers Ocultos

```vim
" Função para limpar buffers não utilizados:
function! CleanupBuffers()
    let open_buffers = []
    
    for i in range(tabpagenr('))
        call extend(open_bufferspagebuflist(i + 1))
    endfor
    
    for num in range(1, bufnr("$") + 1)
        if buflisted(num) && index(open_buffers, num) == -1
            exec "bdelete ".num
        endif
    endfor
endfunction

command! CleanupBuffers call CleanupBuffers()
```

### Configuração Avançada de Layout

#### Configurações Recomendadas

```vim
" Comportamento de splits:
set splitbelow      " new horizontal splits below (novos splits horizontais abaixo)
set splitright      " new vertical splits right (novos splits cais à direita)

" Tamanho mínimo de janelas:
set winheight=5     " minimum window height (altura mínima janela)
set winwidth=20     " minimum window width (largura mínima janela)

" Equalize janelas ao redimensionar terminal:
autocmd VimResized * wincmd =
```

#### Mapeamentos para Navegação Rápida

```vim
" Navegação intuitiva entre janelas:
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Redimensionamento rápido:
nnoremap <S-Left> :vertical resize -5<Cp <S-Right> :vertical resize +5<CR>
nnoremap <S-Up> :resize +5<CR>
nnoremap <S-Down> :resize -5<CR>
```

---

## 11. Sistema de Busca Avançada

### Vimgrep - Busca Nativa

O vimgrep é a ferramenta nativa do Vim para busca em múltiplos arquivos, integrada com o sistema quickfix.

#### Sintaxe Básica

```vim
:vim[grep][!] /{pattern}/[g][j] {file} ...
:vim[grep][!] {pattern} {file} ...
```

#### Flags do Vimgrep

```vim
g                   " find all matches in line (encontrar todas ocorrências na linha)
               " don't jump to first match (não pular para primeira ocorrência)
!                   " don't update buffer list (não atualizar lista buffers)
```

#### Exemplos Práticos

```vim
:vimgrep /TODO/ **/*.py         " buscar TODO em arquivos Python
:vimgrep /function.*main/g **/*.c   " buscar padrão em arquivos C
:vimgrep /\<error\>/j **/*.log     " buscar palavra completa sem pular
```

### Padrões de Busca Avançados

#### Metacaracteres Especiais

```vim
\<                  " beginning of nício da palavra)
\>                  " end of word (fim da palavra)
\zs                 " start match here (iniciar match aqui)
\ze                 " end match here (terminar match aqui)
\@=                 " positive lookahead (lookahead positivo)
\@!                 " negative lookahead (lookahead negativo)
\@<=                " positive lookbehind (lookbehind positivo)
\@<!                " negative lookbehind (lookbehind negativo)
```

#### Exemplos de Padrões Complexos

```vim
" Encontrar 'test' segdo de números:
/test\ze\d\+

" Encontrar palavras que não sejam 'main':
/\<\(main\)\@!\w\+\>

" Encontrar 'include' precedido de '#':
/\(#\s*\)\@<=include

" Encontrar números não seguidos de '%':
/\d\+\(%\)\@!
```

### Sistema Quickfix

#### Comandos Essenciais

```vim
:copen              " open quickfix window (abrir janela quickfix)
:cclose             " close quickfix window (fechar janela quickfix)
:cwindow            " open only if there are results (abrir apenas se há resultados)
:cnext         " next match (próxima ocorrência)
:cprev              " previous match (ocorrência anterior)
:cfirst             " first match (primeira ocorrência)
:clast              " last match (última ocorrência)
:cc [n]             " go to match number n (ir para ocorrência número n)
```

#### Navegação por Arquivos

```vim
:cnfile             " first match in next file (primeira ocorrência próximo arquivo)
:cpfile             " last match in previous file (última ocorrência arquivo anterior)
```

#### kfix

```vim
:colder             " older quickfix list (lista quickfix anterior)
:cnewer             " newer quickfix list (lista quickfix posterior)
:chistory           " show quickfix history (mostrar histórico quickfix)
```

### Location Lists

As location lists são versões locais por janela do quickfix, ideais para operações isoladas.

#### Comandos Location List

```vim
:lvimgrep /pattern/g %          " search in current file only
:lopen              " open location list window (abrir janela locatist)
:lclose             " close location list window (fechar janela location list)
:lnext              " next match in location list (próxima ocorrência)
:lprev              " previous match in location list (ocorrência anterior)
```

#### Diferenças entre Quickfix e Location List

| Aspecto | Quickfix | Location List |
|---------|----------|---------------|
| Escopo | Global | Por janela |
| Comando | :copen | :lopen |
| Navegação | :cnext/:cprev | :lnext/:lprev |
| Uso ideal | Compilação, busca p Linting, busca local |

### Integração com Ferramentas Externas

#### Configuração de Grep Externo

```vim
" Usar ripgrep se disponível:
if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --follow
    set grepformat=%f:%l:%c:%m
elseif executable('ag')
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
endif
```

#### Usando Grep Externo

```vim
:grep pattern **/*.py           " usar grep externo configurado
:grep! pattern **/*.py          " não pular para primeiro resultad
### Customização da Janela Quickfix

#### Auto-redimensionamento

```vim
augroup quickfix_config
    autocmd!
    autocmd FileType qf call AdjustWindowHeight(3, 15)
augroup END

function! AdjustWindowHeight(minheight, maxheight)
    exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction
```

#### Mapeamentos Personalizados no Quickfix

```vim
function! QuickfixMappings()
    nnoremap <buffer> <CR> <CR>         " open file
    nnoremap <buffer> o <CR><C-w>p      " open and return tquickfix
    nnoremap <buffer> s <C-w><CR><C-w>K " open in horizontal split
    nnoremap <buffer> v <C-w><CR><C-w>H<C-w>b<C-w>J<C-w>t " open in vertical split
    nnoremap <buffer> t <C-w><CR><C-w>T " open in new tab
endfunction

autocmd FileType qf call QuickfixMappings()
```

### Operações em Lote com :cdo

O comando `:cdo` executa comandos em todos os resultados da quickfix list.

#### Substituição em Múltiplos Arquivos

```vim
" Buscar e substituir em projeto:
:vimgrep /old_function/g **/*.c
:cdo sfunction/new_function/g | update

" Adicionar comentário em todas as linhas encontradas:
:vimgrep /TODO/g **/*.py
:cdo s/^/# REVIEWED: / | update
```

#### Comando :cfdo

O `:cfdo` opera por arquivo em vez de por linha:

```vim
:vimgrep /pattern/g **/*.js
:cfdo %s/old/new/g | update      " substitui em cada arquivo
```

### Filtros e Refinamento

#### Filtrando Resultados

```vim
" Filtrar quickfix list:
:cfilter pattern     " keep only matching lines (manter apenas linhas correspondentes)
:cfilter! patter    " remove matching lines (remover linhas correspondentes)
```

#### Exemplo de Workflow de Refinamento

```vim
" 1. Busca inicial ampla:
:vimgrep /function/g **/*.c

" 2. Refinar para funções main:
:cfilter main

" 3. Remover arquivos de teste:
:cfilter! test
```

### Busca com Expressões Regulares Complexas

#### Padrões para Desenvolvimento

```vim
" Encontrar definições de função C:
:vimgrep /^\w\+\s\+\*\?\w\+\s*(/g **/*.c

" Encontrar includes do sistema:
:vimgrep /#include\s*<.*>/g **/*.{c,hontrar TODOs com contexto:
:vimgrep /TODO.*:\s*.*/g **/*

" Encontrar declarações de variáveis globais:
:vimgrep /^\w\+\s\+\w\+\s*;/g **/*.h
```

### Performance e Otimização

#### Configurações para Melhor Performance

```vim
" Otimizações para vimgrep:
set maxmempattern=2000000       " increase pattern memory
set regexpengine=1              " use old regexp engine for speed

" Ignorar arquivos desnecessários:
set wildignore+=*.o,*.pyc,*.swp,*.bak
set wildignore+=*/node_modules/*,*/.git/*,*/build## Alternativas para Projetos Grandes

```vim
" Para projetos muito grandes, considere ferramentas externas:
command! -nargs=+ Rg execute 'silent grep! <args>' | copen
command! -nargs=+ Ag execute 'silent grep! <args>' | copen
```

---

## 12. Configuração e Personalização

### O Arquivo .vimrc

O arquivo .vimrc é o coração da personalização do Vim. Ele é executado toda vez que o Vim inicia.

#### Localização do .vimrc

```vim
" Unix/Linux/macOS:
~/.vimrc

" Windows:
$HOME/_vimrc
ou
$VIM/_vimrc
trutura Recomendada

```vim
" ============================================================================
" .vimrc - Configuração Vim Vanilla
" ============================================================================

" ──── CONFIGURAÇÕES BÁSICAS ────────────────────────────────────────────────
set nocompatible        " desabilita compatibilidade com vi
set encoding=utf-8      " encoding padrãoNCIA ─────────────────────────────────────────────────────────────
syntax on               " syntax highlighting
set number              " números de linha
set ruler               " mostrar posição cursor
set showcmd             " mostrar comando sendo digitado
set showmode            " mostrar modo atual

" ──── COMPORTAMENTO ────────────────â─────────────────────────────────
set hidden              " permitir buffers ocultos
set autoread            " recarregar arquivo se modificado externamente
set confirm             " confirmar antes de sair sem salvar

" ──── BUSCA ─────────────────────────────────────────────────────────────────
set hls   " destacar resultados busca
set incsearch           " busca incremental
set ignorecase          " ignorar maiúsculas/minúsculas
set smartcase           " sensível a maiúsculas se padrão contém maiúsculas

" ──── INDENTAÇÃO ────────────────────────────────────────────────────────────
set autoindent          " manter indentação
set smartindent         " indentação inttabstop=4           " largura tab
set shiftwidth=4        " largura indentação
set expandtab           " usar espaços em vez de tabs

" ──── NAVEGAÇÃO ─────────────────────────────────────────────────────────────
set wildmenu            " menu de completação
set wildmode=longest:full,full
set path+=**            " busca recursiva

" ──── MAPEAMENTOS ────────────────────────────────────────────────
let mapleader = ","     " definir leader key

" ──── AUTOCOMANDOS ──────────────────────────────────────────────────────────
" Configurações específicas por tipo de arquivo

" ──── FUNÇÕES ──────────────────â───────────────────────────────────────
" Funções personalizadas
```

### Configurações Fundamentais

#### Configurações de Compatibilidade

```vim
set nocompatible        " disable vi compatibility (desabilitar compatibilidade vi)
set encoding=utf-8      " default encoding (encoding padrão)
set fileencoding=utf-8  " file encoding (encoding arquivo)
```

#### Configurações de Interface

```vim
" Aparência básica:
syn          " enable syntax highlighting (habilitar syntax highlighting)
set number              " show line numbers (mostrar números linha)
set relativenumber      " relative line numbers (números linha relativos)
set ruler               " show cursor position (mostrar posição cursor)
set showcmd             " show partial commands (mostrar comandos parciais)
set showmode            " show current mode (mostrar modo atual)
set laststatus=2        " always show status line (sempre mostrar linha status)

"es e temas:
set background=dark     " dark background (fundo escuro)
colorscheme default     " use default colorscheme (usar tema padrão)
set t_Co=256           " 256 colors (256 cores)
```

#### Configurações de Comportamento

```vim
" Gerenciamento de arquivos:
set hidden              " allow hidden buffers (permitir buffers ocultos)
set autoread            " auto-reload changed files (recarregar arquivos alterados)
set confirm             " confirm before quitting (confirmar antes sair)
set backup           " create backup files (criar arquivos backup)
set writebackup         " backup before writing (backup antes escrita)

" Diretórios para arquivos temporários:
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//
```

### Configurações de Busca

```vim
" Busca avançada:
set hlsearch            " highlight search results (destacar resultados)
set incsearch           " incremental search (busca incremental)
set ignorecase          " ignore case (ignorar maiúsculas/mins)
set smartcase           " smart case sensitivity (sensibilidade inteligente)
set wrapscan            " wrap around when searching (busca circular)

" Configurações de substituição:
set gdefault            " global replace by default (substituição global padrão)
```

### Configurações de Indentação

```vim
" Indentação básica:
set autoindent          " maintain indent (manter indentação)
set smartindent         " smart indenting (indentação inteligente)
set cindent             " C-style denting (indentação estilo C)

" Configuração de tabs:
set tabstop=4           " tab width (largura tab)
set shiftwidth=4        " indent width (largura indentação)
set softtabstop=4       " soft tab width (largura tab soft)
set expandtab           " use spaces instead of tabs (usar espaços)

" Mostrar caracteres invisíveis:
set list                " show invisible characters (mostrar caracteres invisíveis)
set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
```

### Configurações dvegação

```vim
" Completação de arquivos:
set wildmenu            " enable wildmenu (habilitar wildmenu)
set wildmode=longest:full,full  " completion mode (modo completação)
set wildignore=*.o,*.obj,*.pyc,*.swp,*.bak
set wildignore+=*/tmp/*,*.so,*.zip

" Path para busca de arquivos:
set path+=**            " recursive search (busca recursiva)
set suffixesadd=.c,.h,.py,.js,.css,.html

" Navegação entre janelas:
set splitbelow          " horizontal splits below (splits horizontais abaixo)
set splitri     " vertical splits right (splits verticais direita)
```

### Mapeamentos (Mappings)

#### Conceitos de Mapeamento

```vim
" Sintaxe básica:
[mode]map {lhs} {rhs}

" Modos:
nmap                    " normal mode mapping (mapeamento modo normal)
imap                    " insert mode mapping (mapeamento modo insert)
vmap                    " visual mode mapping (mapeamento modo visual)
cmap                    " command mode mapping (mapeamento modo comando)

" Versões não-recursivas (recomendadas):
nnore                " non-recursive normal mode (modo normal não-recursivo)
inoremap                " non-recursive insert mode (modo insert não-recursivo)
vnoremap                " non-recursive visual mode (modo visual não-recursivo)
cnoremap                " non-recursive command mode (modo comando não-recursivo)
```

#### Leader Key

```vim
" Definir leader key:
let mapleader = ","     " usar vírgula como leader
let localleader = "\\"  " leader local para buffers específicos
```

#### Mapeamentos Esse

```vim
" Navegação melhorada:
nnoremap j gj           " move by display line (mover por linha exibição)
nnoremap k gk           " move by display line (mover por linha exibição)

" Salvamento rápido:
nnoremap <leader>w :w<CR>       " save file (salvar arquivo)
nnoremap <leader>q :q<CR>       " quit (sair)
nnoremap <leader>x :x<CR>       " save and quit (salvar e sair)

" Limpeza de highlight:
nnoremap <leader><space> :noh<CR>   " clear search highlight

" Navegação entre buffers:
nnoremap <leaderR>:b<Space>    " list and select buffer
nnoremap <leader>bn :bn<CR>             " next buffer
nnoremap <leader>bp :bp<CR>             " previous buffer

" Navegação entre janelas:
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
```

### Autocomandos (Autocmds)

Os autocomandos executam automaticamente quando eventos específicos ocorrem.

#### Sintaxe Básica

```vim
autocmd [group] {event} {pattern} {command}
```

#### Grupos de Autocomandos

```vim
" Criar grupo porganização:
augroup MyGroup
    autocmd!            " clear existing autocmds in group
    autocmd BufRead *.py set filetype=python
augroup END
```

#### Autocomandos Úteis

```vim
" Configurações por tipo de arquivo:
augroup FileTypeConfig
    autocmd!
    " Python
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
    
    " JavaScript
    autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
    
    " C/C++
    autocmd FileType c,cpp setlocal tabstop=8 shiftwidthexpandtab
    
    " Makefiles (DEVEM usar tabs)
    autocmd FileType make setlocal tabstop=8 shiftwidth=8 noexpandtab
augroup END

" Ações automáticas:
augroup AutoActions
    autocmd!
    " Remover espaços em branco no final ao salvar:
    autocmd BufWritePre * :%s/\s\+$//e
    
    " Retornar à última posição no arquivo:
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    
    " Auto-criar diretórios se não existirem:
    autocmd BufWritePreirectory(expand("<afile>:p:h")) | call mkdir(expand("<afile>:p:h"), "p") | endif
augroup END
```

### Funções Personalizadas

#### Criando Funções

```vim
" Sintaxe básica:
function! FunctionName(arg1, arg2)
    " corpo da função
    return result
endfunction
```

#### Exemplos de Funções Úteis

```vim
" Função para alternar números de linha:
function! ToggleNumber()
    if &number
        set nonumber
        set norelativenumber
    else
        set number
        set relativenumber
    endifnnoremap <leader>n :call ToggleNumber()<CR>

" Função para limpar buffers não utilizados:
function! CleanupBuffers()
    let open_buffers = []
    for i in range(tabpagenr('))
        call extend(open_buffers, tabpagebuflist(i + 1))
    endfor
    
    for num in range(1, bufnr("$") + 1)
        if buflisted(num) && index(open_buffers, num) == -1
            exec "bdelete ".num
        endif
    endfor
endfunction
command! CleanupBuffers call CleanupBuffers()

" Função para criar arquivo com template:
ion! NewFile(filename)
    execute "edit " . a:filename
    if a:filename =~ '\.py
        call append(0, ['#!/usr/bin/env python3', '# -*- coding: utf-8 -*-', '', ''])
    elseif a:filename =~ '\.c
        call append(0, ['#include <stdio.h>', '', 'int main() {', '    return 0;', '}'])
    endif
endfunction
command! -nargs=1 NewFile call NewFile(<f-args>)
```

### Comandos Personalizados

#### Criando Comandos

```vim
" Sintaxe:
command! [attributes] {name} {replacement}
```

#### Exemplos de Comandos

```vim
" Comando para salvar como root:
command! W w !sudo tee % > /dev/null

" Comando para recarregar vimrc:
command! ReloadVimrc source $MYVIMRC

" Comando para editar vimrc:
command! EditVimrc edit $MYVIMRC

" Comando para busca e substituição interativa:
command! -nargs=* Replace execute 'argdo %s/' . <f-args> . '/gc | update'
```

### Configuração de Statusline

#### Statusline Personalizada

```vim
" Função para mostrar informações do arquivo:
function! FileInfo()
    let filename = expand('%:t' filename == ''
        let filename = '[No Name]'
    endif
    return filename
endfunction

" Configuração da statusline:
set statusline=
set statusline+=\ %{FileInfo()}         " nome do arquivo
set statusline+=\ %m%r%h%w               " flags (modificado, readonly, etc)
set statusline+=%=                       " alinhamento direita
set statusline+=\ %y                     " tipo de arquivo
set statusline+=\ %{&encoding}           " encoding
set statusline+=\ %l/%L                  " linha atual/total
t statusline+=\ %p%%                   " porcentagem no arquivo
```

### Configuração por Projeto

#### Arquivos de Configuração Local

```vim
" Habilitar vimrc local:
set exrc            " enable local vimrc files (habilitar vimrc local)
set secure          " restrict commands in local vimrc (restringir comandos)
```

#### Detecção de Projeto

```vim
" Função para detectar tipo de projeto:
function! DetectProject()
    if filereadable('package.json')
        " Projeto Node.js
        setlocal tabstftwidth=2 expandtab
    elseif filereadable('Makefile')
        " Projeto C/C++
        setlocal tabstop=8 shiftwidth=8 noexpandtab
    elseif filereadable('requirements.txt') || filereadable('setup.py')
        " Projeto Python
        setlocal tabstop=4 shiftwidth=4 expandtab
    endif
endfunction

autocmd BufEnter * call DetectProject()
```

### Exemplo de .vimrc Completo

```vim
" ============================================================================
" .vimrc Completo - Vim Vanilla Otimizado
" ============================================================================

" ──── CONFIGURAÇÕES BÁSICAS ────────────────────────────────────────────────
set nocompatible
set encoding=utf-8
set fileencoding=utf-8

" ──── APARÊNCIA ───────────────────────────────────────────────────────â──
syntax on
set number
set relativenumber
set ruler
set showcmd
set showmode
set laststatus=2
set background=dark
set t_Co=256

" ──── COMPORTAMENTO ─────────────────────────────────────────────────────────
set hidden
set autoread
set confirm
set mouse=a

" ──── BUSCA ───────────────────────────────────────────────────
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan

" ──── INDENTAÇÃO ────────────────────────────────────────────────────────────
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" ──── NAVEGAÇÃO ────────────────────â──────────────────────────────────
set wildmenu
set wildmode=longest:full,full
set path+=**
set wildignore=*.o,*.pyc,*.swp
set splitbelow
set splitright

" ──── BACKUP E UNDO ─────────────────────────────────────────────────────────
set backup
set writebackup
set undofile
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" ──── MAPEAMENTOS ───────────────────────────────────────────────────────────
let mapleader = ","

" Navegação:
nnoremap j gj
nnoremap k gk

" Salvamento:
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Limpeza:
nnoremap <leader><space> :noh<CR>

" Buffers:
nnoremap <leader>bb :ls<CR>:b<Space>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>

" Janelas:
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ──── AUTOCOMANDOS ──────────────────────────────────────────────────────────
augroup FileTypeConfig
    autocmd!
    autocmd FileType python setlocal ts=4 sw=4 et
    autocmd FileType javascript setlocal ts=2 sw=2 et
    autocmd FileType c,cpp setlocal ts=8 sw=8 noet
   eType make setlocal ts=8 sw=8 noet
augroup END

augroup AutoActions
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" ──── COMANDOS PERSONALIZADOS ───────────────────────────────────────────────
command! W w !sudo tee % > /dev/null
command! ReloadVimrc source $MYVIMRC
command! EditVimrc ediIMRC

" ──── STATUSLINE ────────────────────────────────────────────────────────────
set statusline=%f%m%r%h%w%=%y\ %{&encoding}\ %l/%L\ %p%%

" ──── CRIAÇÃO DE DIRETÓRIOS ─────────────────────────────────────────────────
if !isdirectory($HOME."/.vim/backup")
    call mkdir(backup", "p")
endif
if !isdirectory($HOME."/.vim/swap")
    call mkdir($HOME."/.vim/swap", "p")
endif
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "p")
endif
```

---

## 13. Workflows e Produtividade

### Workflow para Desenvolvimento

#### Setup Inicial de Projeto

```vim
" 1. Abrir diretório raiz do projeto:
vim .

" 2. Configurar path para o projeto:
:set path=.,src/**,lib/**,tests/**

" 3. Gerar tags se for projeto C/C++:
:!ctags -R .

" 4. Configurar session:
:mksession projto.vim
```

#### Navegação Eficiente em Projetos

```vim
" Técnicas de navegação rápida:

" 1. Usar :find para abrir arquivos:
:find *main*        " encontrar arquivos com 'main' no nome

" 2. Usar gf para seguir includes:
" Posicionar cursor em #include "header.h" e pressionar gf

" 3. Usar tags para navegação de código:
Ctrl-]              " ir para definição
Ctrl-t              " voltar da definição

" 4. Usar marks globais para bookmarks:
mA                  " marcar arquivo importante com          " voltar para marca A
```

### Workflow de Edição

#### Edição Eficiente

```vim
" Técnicas de edição produtiva:

" 1. Text objects para seleção precisa:
ciw                 " change inner word (alterar palavra)
ci"                 " change inner quotes (alterar entre aspas)
da(                 " delete around parentheses (deletar parênteses)

" 2. Repetição com . (dot command):
dd                  " deletar linha
.                   " repetir deleção na próxima linha

" 3. Macros patitivas:
qa                  " gravar macro 'a'
# executar ações desejadas
q                   " parar gravação
@a                  " executar macro
@@                  " repetir última macro
```

#### Refactoring com Vim

```vim
" Workflow de refactoring:

" 1. Buscar todas as ocorrências:
:vimgrep /old_function/g **/*.c

" 2. Usar quickfix para navegar:
:copen              " abrir janela quickfix
:cnext              " próxima ocorrência

" 3. Substituir em múltiplos arquivos:
:cdo s/old_function/ion/gc | update

" 4. Verificar mudanças:
:vimgrep /new_function/g **/*.c
```

### Workflow de Debug

#### Preparação para Debug

```vim
" 1. Compilar com informações de debug:
:make DEBUG=1

" 2. Configurar quickfix para capturar erros:
:set makeprg=gcc\ -Wall\ -g\ -o\ %<\ %

" 3. Usar location list para warnings específicos:
:lvimgrep /warning/g %
```

#### Análise de Código

```vim
" Técnicas de análise:

" 1. Folding para visão geral:
zM                  " fechar todos os folds
zR            ir todos os folds
za                  " toggle fold atual

" 2. Busca por padrões específicos:
/\<TODO\>           " encontrar TODOs
/\<FIXME\>          " encontrar FIXMEs
/^\s*function       " encontrar definições de função

" 3. Navegação por símbolos:
:g/^function/       " listar todas as linhas com 'function'
```

### Workflow com Git

#### Integração Básica com Git

```vim
" Comandos Git úteis dentro do Vim:

" 1. Ver status:
:!git status

" 2. Adicionar arquivo atual:
:!git add %

" 3. Coagem:
:!git commit -m "mensagem"

" 4. Ver diff:
:!git diff %

" 5. Ver histórico do arquivo:
:!git log --oneline %
```

#### Workflow de Branch

```vim
" 1. Criar novo branch:
:!git checkout -b feature/nova-funcionalidade

" 2. Trabalhar no código...

" 3. Commit frequente:
:!git add . && git commit -m "trabalho em progresso"

" 4. Push do branch:
:!git push origin feature/nova-funcionalidade
```

### Sessions e Project Management

#### Criando Sessions Eficazes

```vim
" Função para session automátic diretório:
function! MakeSession()
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    if (filewritable(b:sessiondir) != 2)
        exe 'silent !mkdir -p ' . b:sessiondir
    endif
    exe "mksession! " . b:sessiondir . "/session.vim"
endfunction

" Função para carregar session:
function! LoadSession()
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    let b:sessionfile = b:sessiondir . "/session.vim"
    if (filereadable(b:sessionfile))
        exe 'source ' . b:sessionfile
    e
        echo "No session loaded."
    endif
endfunction

" Auto-salvar session ao sair:
autocmd VimLeave * call MakeSession()

" Comando para carregar session:
command! LoadSession call LoadSession()
```

#### Project-specific Settings

```vim
" Criar .vimrc local no projeto:
" Arquivo: .vimrc (no diretório raiz do projeto)

" Exemplo para projeto Python:
setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab
setlocal textwidth=79

" Configurar path específico:
setlocal path=.,src/**,tests/**

" Comdos específicos do projeto:
command! RunTests !python -m pytest tests/
command! Lint !flake8 src/
```

### Templates e Snippets

#### Sistema de Templates Simples

```vim
" Função para inserir templates:
function! LoadTemplate(template)
    let template_file = $HOME . "/.vim/templates/" . a:template
    if filereadable(template_file)
        execute "0r " . template_file
        $delete
    endif
endfunction

" Autocomandos para templates automáticos:
augroup templates
    autocmd!
    autocmd BufNewFilpy call LoadTemplate("python.template")
    autocmd BufNewFile *.c call LoadTemplate("c.template")
    autocmd BufNewFile *.h call LoadTemplate("header.template")
augroup END
```

#### Exemplos de Templates

```vim
" Template Python (~/.vim/templates/python.template):
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Módulo: <+MODULE+>
Descrição: <+DESCRIPTION+>
"""

def main():
    """Função principal."""
    pass

if __name__ == "__main__":
    main()

" Template C (~/.vim/templates/c.template):
#in <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    /* <+CURSOR+> */
    
    return 0;
}
```

### Automação de Tarefas

#### Build System Integration

```vim
" Configuração de makeprg para diferentes projetos:
augroup BuildSystem
    autocmd!
    " Python
    autocmd FileType python setlocal makeprg=python\ %
    
    " C
    autocmd FileType c setlocal makeprg=gcc\ -Wall\ -g\ -o\ %<\ %
    
    " JavaScript (Node.js)
    autocmd FileType javascript setlocal makeprg=node\ %
    
    kefile projects
    autocmd FileType make setlocal makeprg=make
augroup END

" Mapeamentos para build rápido:
nnoremap <F5> :w<CR>:make<CR>
nnoremap <F6> :!./%<<CR>
```

#### Testing Integration

```vim
" Comandos para diferentes frameworks de teste:

" Python pytest:
command! PyTest !python -m pytest
command! PyTestCurrent !python -m pytest %

" C com Unity framework:
command! CTest !make test
command! CTestCurrent !gcc -DTEST % -o test && ./test

" Mapeamento universal para testes:
nnoremap <leader>t :Pyest<CR>
nnoremap <leader>T :PyTestCurrent<CR>
```

### Performance Tips

#### Configurações para Performance

```vim
" Otimizações para arquivos grandes:
set lazyredraw          " não redesenhar durante macros
set ttyfast             " terminal rápido
set synmaxcol=200       " limitar syntax highlighting em linhas longas
set regexpengine=1      " usar engine regex antigo (mais rápido)

" Configurações para projetos grandes:
set maxmempattern=2000000   " aumentar memória para padrões
set updatetim    " tempo para swap file update
```

#### Técnicas de Edição Rápida

```vim
" Atalhos para operações comuns:

" Duplicar linha:
nnoremap <leader>d yyp

" Mover linhas:
nnoremap <leader>j :m+1<CR>
nnoremap <leader>k :m-2<CR>

" Selecionar tudo:
nnoremap <leader>a ggVG

" Indentação rápida:
vnoremap < <gv
vnoremap > >gv

" Juntar linhas sem espaços:
nnoremap <leader>J gJ
```

### Workflow para Diferentes Linguagens

#### Python

```vim
augroup PythonWorkflow
    autocmd!
    autocmd FileType pytho makeprg=python\ %
    autocmd FileType python nnoremap <buffer> <F5> :w<CR>:!python %<CR>
    autocmd FileType python nnoremap <buffer> <F6> :w<CR>:!python -m pdb %<CR>
    autocmd FileType python setlocal textwidth=79
    autocmd FileType python setlocal colorcolumn=80
augroup END
```

#### C/C++

```vim
augroup CWorkflow
    autocmd!
    autocmd FileType c,cpp setlocal makeprg=gcc\ -Wall\ -g\ -o\ %<\ %
    autocmd FileType c,cpp nnoremap <buffer> <F5> :w<CR>:make<CR>
    autocmd FileType c,cpp nnoremap <buffer> <F6> :!./%<<CR>
    autocmd FileType c,cpp nnoremap <buffer> <F7> :!gdb ./%<<CR>
    autocmd FileType c,cpp setlocal cindent
augroup END
```

#### Web Development

```vim
augroup WebWorkflow
    autocmd!
    autocmd FileType html,css,javascript setlocal tabstop=2 shiftwidth=2
    autocmd FileType javascript nnoremap <buffer> <F5> :w<CR>:!node %<CR>
    autocmd FileType html nnoremap <buffer> <F5> :w<CR>:!firefox %<CR>
augroup END
```

### Backup e Recovery Workflow

#### Sistema de Backup Automátic

```vim
" Configuração de backup robusta:
set backup
set writebackup
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//

" Função para backup com timestamp:
function! BackupCurrentFile()
    let backup_name = expand('%:p') . '.' . strftime('%Y%m%d_%H%M%S') . '.bak'
    execute 'write ' . backup_name
    echo 'Backup criado: ' . backup_name
endfunction

command! Backup call BackupCurrentFile()
```

#### Recovery de Emergência

```vim
" Comandos para recovery:

" Recuperar de swap file:
:recover
star swap files:
:!ls -la ~/.vim/swap/

" Comando para limpeza de emergency:
command! CleanSwap !rm -f ~/.vim/swap/*.swp
```

---

## 14. Resolução de Problemas

### Problemas Comuns de Inicialização

#### Vim Não Carrega Configuração

**Sintomas:**
- Configurações do .vimrc ignoradas
- Vim inicia em modo compatível

**Diagnóstico:**
```vim
" Verificar localização do .vimrc:
:echo $MYVIMRC

" Verificar se .vimrc está sendo carregado:
:scriptnames

" Verificar modo compatível:
:set compatible?s:**
```vim
" 1. Garantir que .vimrc existe no local correto:
" Unix: ~/.vimrc
" Windows: %USERPROFILE%\_vimrc

" 2. Verificar permissões do arquivo:
chmod 644 ~/.vimrc

" 3. Adicionar ao início do .vimrc:
set nocompatible

" 4. Testar configuração:
:source ~/.vimrc
```

#### Encoding/Caracteres Especiais

**Sintomas:**
- Caracteres estranhos na exibição
- Acentos não aparecem corretamente

**Soluções:**
```vim
" Configurar encoding no .vimrc:
set encoding=utf-8
set fileencoding=utf-8
set fileencod8,latin1,cp1252

" Forçar encoding específico:
:e ++enc=utf-8

" Converter encoding do arquivo:
:set fileencoding=utf-8
:w
```

### Problemas de Performance

#### Vim Lento ao Abrir Arquivos

**Causas Comuns:**
- Plugins desnecessários (mesmo que estejamos usando vanilla)
- Syntax highlighting em arquivos grandes
- Configurações de folding complexas

**Soluções:**
```vim
" 1. Otimizações para arquivos grandes:
set lazyredraw
set ttyfast
set synmaxcol=200

" 2. Desabilitar syntax para arquivos grandmd BufWinEnter * if line2byte(line("$") + 1) > 1000000 | syntax clear | endif

" 3. Otimizar regex engine:
set regexpengine=1

" 4. Reduzir updatetime:
set updatetime=300
```

#### Busca Lenta

**Sintomas:**
- Comando `/` demora para encontrar resultados
- Highlighting demorado

**Soluções:**
```vim
" 1. Usar regex mais eficiente:
" Em vez de: /.*word.*
" Use: /word

" 2. Limitar área de busca:
/word\%<100l        " buscar apenas nas primeiras 100 linhas

" 3. Desabilitar highlighting temporariamente:
:snohlsearch
```

### Problemas de Edição

#### Indentação Inconsistente

**Sintomas:**
- Mistura de tabs e espaços
- Indentação não alinha corretamente

**Diagnóstico:**
```vim
" Mostrar caracteres invisíveis:
:set list
:set listchars=tab:▸\ ,trail:⋅,extends:❯,precedes:❮

" Verificar configurações:
:set tabstop?
:set shiftwidth?
:set expandtab?
```

**Soluções:**
```vim
" 1. Padronizar configuração:
set tabstop=4
set shiftwidth=4
set expandtab

" 2. Converter tabs existentes:
:retab      " converter tabs para espaços (se expandtab está ativo)

" 3. Configuração por tipo de arquivo:
autocmd FileType python setlocal ts=4 sw=4 et
autocmd FileType javascript setlocal ts=2 sw=2 et
autocmd FileType make setlocal ts=8 sw=8 noet
```

#### Problema com Clipboard

**Sintomas:**
- `"+y` não funciona
- Não consegue colar do sistema

**Diagnóstico:**
```vim
" Verificar suporte a clipboard:
:echo has('clipboard')

" Verificar registros disponíveis:
:reg
```

**Soluções:**
```vim
" 1. Para sm suporte clipboard:
" Usar pipe para xclip (Linux):
vnoremap <leader>y :w !xclip -selection clipboard<CR>

" 2. Configurar clipboard no .vimrc:
set clipboard=unnamed       " usar registro * (primary selection)
set clipboard=unnamedplus   " usar registro + (clipboard)

" 3. Alternativa manual:
" Copiar: selecionar em visual mode, depois "+y
" Colar: "+p
```

### Problemas de Navegação

#### :find Não Encontra Arquivos

**Sintomas:**
- `:find filename` retorna "Pattern not found"
- Autocompletar não mostrquivos esperados

**Diagnóstico:**
```vim
" Verificar configuração do path:
:set path?

" Testar busca manual:
:echo globpath(&path, '**/filename')
```

**Soluções:**
```vim
" 1. Configurar path corretamente:
set path=.,**               " busca recursiva
set path+=src/**,lib/**     " adicionar diretórios específicos

" 2. Verificar wildignore:
:set wildignore?
set wildignore=*.o,*.pyc    " ignorar apenas necessário

" 3. Usar busca explícita:
:find **/filename           " busca recursiva explícit# Tags Não Funcionam

**Sintomas:**
- `Ctrl-]` não encontra definições
- `:tag` retorna "tag not found"

**Diagnóstico:**
```vim
" Verificar arquivo tags:
:set tags?
:echo filereadable('tags')

" Verificar conteúdo:
:!head tags
```

**Soluções:**
```vim
" 1. Gerar tags:
:!ctags -R .

" 2. Configurar path de tags:
set tags=tags;/             " buscar tags recursivamente

" 3. Para projetos C com headers:
:!ctags -R --c-kinds=+p --fields=+S .

" 4. Verificar se ctags está instalado:
:!which ctags
```blemas de Configuração

#### Configurações Não Persistem

**Sintomas:**
- Configurações são perdidas ao reiniciar Vim
- `:set` funciona mas não salva

**Soluções:**
```vim
" 1. Verificar se configurações estão no .vimrc:
:echo $MYVIMRC
:edit $MYVIMRC

" 2. Configurações devem estar no .vimrc, não no terminal:
" Errado: digitar :set number no Vim
" Correto: adicionar 'set number' no .vimrc

" 3. Recarregar .vimrc:
:source $MYVIMRC
```

#### Mapeamentos Não Funcionam

**Sintomas:**
- Teclas peadas não executam comando esperado
- Conflitos entre mapeamentos

**Diagnóstico:**
```vim
" Ver todos os mapeamentos:
:map

" Ver mapeamento específico:
:map <leader>w

" Ver mapeamentos por modo:
:nmap               " normal mode
:imap               " insert mode
:vmap               " visual mode
```

**Soluções:**
```vim
" 1. Usar mapeamentos não-recursivos:
" Errado: nmap j k
" Correto: nnoremap j k

" 2. Verificar conflicts:
:verbose map <key>

" 3. Usar leader key para evitar conflitos:
let map = ","
nnoremap <leader>w :w<CR>
```

### Problemas de Syntax Highlighting

#### Cores Incorretas ou Ausentes

**Sintomas:**
- Texto sem cores
- Cores estranhas ou incorretas

**Diagnóstico:**
```vim
" Verificar se syntax está ativo:
:syntax

" Verificar tipo de arquivo:
:set filetype?

" Verificar suporte a cores:
:echo &t_Co
```

**Soluções:**
```vim
" 1. Ativar syntax highlighting:
syntax on

" 2. Configurar cores do terminal:
set t_Co=256

" 3. Forçar tipo de arquivo:
:set filetype=python

" 4. Conar background:
set background=dark
```

### Debugging de Configuração

#### Modo Verbose

```vim
" Iniciar Vim em modo verbose:
vim -V9verbose.log

" Executar comando em modo verbose:
:verbose set option?
:verbose map <key>
```

#### Teste de Configuração Limpa

```vim
" Iniciar Vim sem configuração:
vim -u NONE

" Iniciar com configuração mínima:
vim -u ~/.vimrc-minimal
```

#### Arquivo .vimrc-minimal para Teste

```vim
" ~/.vimrc-minimal - para debugging
set nocompatible
syntax on
set number
set
set incsearch
```

### Scripts de Diagnóstico

#### Script de Health Check

```vim
" Função para verificar configuração:
function! VimHealthCheck()
    echo "=== Vim Health Check ==="
    echo "Versão: " . v:version
    echo "Compilado com: " . v:progname
    echo "VIMRC: " . $MYVIMRC
    echo "Encoding: " . &encoding
    echo "FileEncoding: " . &fileencoding
    echo "Clipboard: " . (has('clipboard') ? 'disponível' : 'não disponível')
    echo "Python: " . (has('python3') ? 'Python3 OK' : 'Pythonponível')
    echo "Tags file: " . (filereadable('tags') ? 'encontrado' : 'não encontrado')
    echo "==========================="
endfunction

command! HealthCheck call VimHealthCheck()
```

#### Script de Limpeza

```vim
" Função para limpar arquivos temporários:
function! CleanupVim()
    " Limpar swap files antigos:
    silent! execute '!find ~/.vim/swap -name "*.swp" -mtime +7 -delete'
    
    " Limpar backup files antigos:
    silent! execute '!find ~/.vim/backup -name "*~" -mtime +30 -delete'
    " Limpar undo files antigos:
    silent! execute '!find ~/.vim/undo -name "*" -mtime +90 -delete'
    
    echo "Cleanup concluído!"
endfunction

command! CleanupVim call CleanupVim()
```

### Recuperação de Emergência

#### Session de Emergência

```vim
" Salvar estado atual em emergência:
command! EmergencySave mksession! ~/.vim/emergency.vim

" Carregar session de emergência:
command! EmergencyLoad source ~/.vim/emergency.vim
```

#### Backup de Configuração

```bash
# Script shell para backu/bash
# backup-vim-config.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.vim/config-backup"

mkdir -p "$BACKUP_DIR"

# Backup .vimrc
cp "$HOME/.vimrc" "$BACKUP_DIR/vimrc_$DATE"

# Backup diretório .vim
tar -czf "$BACKUP_DIR/vim-dir_$DATE.tar.gz" -C "$HOME" .vim

echo "Backup criado em $BACKUP_DIR"
```

---

## 15. Recursos Avançados

### Registers Avançados

#### Tipos Especiais de Registers

```vim
" Registers de sistema:
"+                  " system clipboard (clipboard do sistema)
"*               " primary selection (seleção primária X11)

" Registers automáticos:
""                  " default register (registro padrão)
"0                  " yank register (último texto copiado)
"1-"9               " delete registers (textos deletados, rotativo)
"-                  " small delete register (deleções pequenas)

" Registers de informação:
".                  " last inserted text (último texto inserido)
"%                  " current file name (nome do arquivo atual)
"#                  " altename (nome do arquivo alternativo)
":                  " last command (último comando)
"/                  " last search pattern (último padrão de busca)
```

#### Operações Avançadas com Registers

```vim
" Visualizar conteúdo de todos os registers:
:registers
:reg                " forma abreviada

" Visualizar registers específicos:
:reg a b c          " mostrar apenas registers a, b, c

" Limpar register:
qaq                 " gravar macro vazia no register 'a'

" Concatenar em register (maiúscu                " copiar linha para register 'a'
"Ayy                " adicionar linha ao register 'a'

" Usar register em comandos Ex:
:put a              " colar conteúdo do register 'a'
:put +              " colar do clipboard sistema
```

#### Manipulação de Register em Insert Mode

```vim
" Em modo insert:
Ctrl-r a            " inserir conteúdo do register 'a'
Ctrl-r +            " inserir do clipboard sistema
Ctrl-r "            " inserir do register padrão
Ctrl-r /            " inserir último pde busca
```

### Expressões e Cálculos

#### Register de Expressão

```vim
" Register = para cálculos:
" Em modo insert:
Ctrl-r =            " ativar register de expressão

" Exemplos:
Ctrl-r = 2+3 <Enter>        " insere "5"
Ctrl-r = strftime("%Y-%m-%d") <Enter>  " insere data atual
```

#### Substituição com Expressões

```vim
" Usar \= em substituições para expressões:
:%s/\d\+/\=submatch(0)+1/g      " incrementar todos os números
:%s/.*/\=line('.')/g            " substituir por números de +/\=len(submatch(0))/g   " substituir palavras por seu comprimento
```

### Comandos Ex Avançados

#### Global Command (:g)

O comando `:g` executa comandos em linhas que correspondem a um padrão.

```vim
" Sintaxe:
:[range]g/pattern/command

" Exemplos:
:g/TODO/d           " deletar todas as linhas com 'TODO'
:g/^$/d             " deletar todas as linhas vazias
:g/function/p       " imprimir todas as linhas com 'function'
:g/debug/s/debug/info/g  " substituir 'debug' por 'info' em linhas que contêm 'deb

" Versão inversa (:v):
:v/pattern/command  " executar em linhas que NÃO correspondem ao padrão
:v/^#/d             " deletar linhas que não começam com '#'
```

#### Normal Command (:normal)

Executa comandos do modo normal como comando Ex.

```vim
" Sintaxe:
:[range]normal[!] commands

" Exemplos:
:%normal A;         " adicionar ';' no final de todas as linhas
:1,5normal I//      " comentar linhas 1-5 em código C
:%normal 0f=r:      " em cada linha, ir ao início, encontrar '=' e substituir por ':'r com global:
:g/function/normal A  // TODO: review  " adicionar comentário em linhas com 'function'
```

#### Arglist Commands

A arglist é uma lista de arquivos para operações em lote.

```vim
" Definir arglist:
:args **/*.py       " todos os arquivos .py recursivamente
:args src/*.c lib/*.c   " arquivos específicos

" Navegar na arglist:
:next               " próximo arquivo
:prev               " arquivo anterior
:first              " primeiro arquivo
:last               " último arquivo

" OperaÃodos os arquivos:
:argdo %s/old/new/g | update    " substituir em todos e salvar
:argdo normal gg=G              " reindentar todos os arquivos
```

### Fold (Dobramento) Avançado

#### Métodos de Folding

```vim
" Configurar método de folding:
set foldmethod=manual       " criação manual
set foldmethod=indent       " baseado em indentação
set foldmethod=syntax       " baseado em syntax highlighting
set foldmethod=expr         " baseado em expressão
set foldmethod=marker       " baseado em marcadornfigurações relacionadas:
set foldlevel=0         " nível inicial (0 = todos fechados)
set foldnestmax=3       " máximo de níveis aninhados
set foldcolumn=1        " mostrar coluna de fold
```

#### Comandos de Folding

```vim
" Criar folds (modo manual):
zf{motion}          " criar fold
zf5j                " criar fold nas próximas 5 linhas
zfa{                " criar fold do '{' correspondente

" Navegação:
zj                  " próximo fold
zk                  " fold anterior
[z                  do fold atual
]z                  " fim do fold atual

" Abertura/fechamento:
zo                  " abrir fold sob cursor
zc                  " fechar fold sob cursor
za                  " toggle fold
zO                  " abrir recursivamente
zC                  " fechar recursivamente
zM                  " fechar todos os folds
zR                  " abrir todos os folds

" Deleção:
zd                  " deletar fold sob cursor
zD                  " deletar folds recursivamente
```

#### Folding com Expssões

```vim
" Exemplo para código Python:
set foldmethod=expr
set foldexpr=GetPythonFold(v:lnum)

function! GetPythonFold(lnum)
    let line = getline(a:lnum)
    if line =~ '^class '
        return '>1'
    elseif line =~ '^def '
        return '>2'
    else
        return '='
    endif
endfunction
```

### Diff Mode

#### Ativando Diff Mode

```vim
" Comparar arquivos:
:diffsplit file2.txt    " dividir e comparar
:vert diffsplit file2.txt   " divisão vertical

" A partir da linha de comando:
vim -d f1.txt file2.txt

" Converter janela atual em diff:
:diffthis           " tornar janela atual parte do diff
:diffoff            " sair do modo diff
```

#### Navegação em Diff

```vim
]c                  " próxima diferença
[c                  " diferença anterior
do                  " diff obtain (obter alteração da outra janela)
dp                  " diff put (enviar alteração para outra janela)
:diffupdate         " atualizar diff após mudanças
```

#### Configurações de Diff

```vim
" No .viopt=filler,iwhite,vertical
" filler: mostrar linhas de preenchimento
" iwhite: ignorar diferenças de espaço em branco
" vertical: usar splits verticais por padrão
```

### Macros Avançados

#### Macros Complexos

```vim
" Gravar macro complexo:
qa                  " iniciar gravação no register 'a'
0                   " ir ao início da linha
f(                  " encontrar '('
ci(                 " alterar conteúdo entre parênteses
new_content         " digitar novo conteúdo
<Esc>               " modo normal
j                   " próxima linha
q                   " parar gravação

" Executar macro:
@a                  " executar uma vez
100@a               " executar 100 vezes
```

#### Edição de Macros

```vim
" Visualizar conteúdo do macro:
:reg a

" Editar macro existente:
:let @a = '<Ctrl-r><Ctrl-r>a'
" Edite o conteúdo na linha de comando
" Pressione Enter para salvar

" Exemplo prático:
:let @a = '0f(ci(new_content<Esc>j'
```

#### Macros Recursivos

```vim
" Macro que chama a si mesmo              " iniciar gravação
0                   " ir ao início
/pattern<CR>        " buscar padrão
cwnew_word<Esc>     " alterar palavra
@a                  " chamar macro recursivamente
q                   " parar gravação

" Executar (irá parar quando não encontrar mais o padrão):
@a
```

### Comandos de Janela Avançados

#### Layouts Complexos

```vim
" Criar layout específico:
:edit file1.txt     " abrir arquivo 1
:vsplit file2.txt   " dividir verticalmente com arquivo 2
:split file3.txtir horizontalmente com arquivo 3
Ctrl-w h            " voltar à janela esquerda
:split file4.txt    " dividir horizontalmente com arquivo 4

" Equalizar todas as janelas:
Ctrl-w =

" Redimensionamento preciso:
:resize 20          " altura específica
:vertical resize 50 " largura específica
```

#### Comandos de Janela por Buffer

```vim
" Abrir buffer em nova janela:
:sbuffer 2          " abrir buffer 2 em split horizontal
:vert sbuffer 3     " abrir buffer 3 em split vertical

" Operações em todas as as:
:windo set number   " executar comando em todas as janelas
:windo diffthis     " ativar diff em todas as janelas
```

### Completação Avançada

#### Tipos de Completação em Insert Mode

```vim
Ctrl-x Ctrl-f       " filename completion (completar nome arquivo)
Ctrl-x Ctrl-l       " line completion (completar linha)
Ctrl-x Ctrl-k       " dictionary completion (completar dicionário)
Ctrl-x Ctrl-t       " thesaurus completion (completar tesauro)
Ctrl-x Ctrl-i       " included files completion (arquivouídos)
Ctrl-x Ctrl-]       " tag completion (completar tags)
Ctrl-x Ctrl-o       " omni completion (omni completação)
Ctrl-x Ctrl-u       " user defined completion (completação definida usuário)
Ctrl-x Ctrl-v       " vim command completion (completar comandos vim)
```

#### Configuração de Completação

```vim
" Configurar completação:
set complete=.,w,b,u,t,i    " fontes de completação
set completeopt=menu,preview,longest

" Completação personalizada:
set dictionary=/usr/share/dict/words
set thesaurus=~/.vim/thesaurus.txt

" Função de completação personalizada:
function! MyComplete(findstart, base)
    if a:findstart
        " localizar início da palavra
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        return start
    else
        " retornar lista de matches
        let res = []
        for word in ['palavra1', 'palavra2', 'palavra3']
            if word =~ '^' . a:base
           call add(res, word)
            endif
        endfor
        return res
    endif
endfunction

set completefunc=MyComplete
```

### Marks Avançados

#### Marks Especiais Automáticos

```vim
''                  " posição antes do último salto
'.                  " posição da última alteração
'^                  " posição da última inserção
'[                  " início do último texto alterado/copiado
']                  " fim do último texto alterado/copiado
'<                  "nício da última seleção visual
'>                  " fim da última seleção visual
```

#### Operações com Marks

```vim
" Listar todos os marks:
:marks

" Deletar marks:
:delmarks a         " deletar mark 'a'
:delmarks!          " deletar todos os marks locais
:delmarks A-Z       " deletar marks globais A-Z

" Operações entre marks:
:'a,'bd             " deletar linhas entre marks 'a' e 'b'
:'a,'by             " copiar linhas entre marks 'a' e 'b'
```

### Formatação Avançada

#### Format ProgConfigurar programa externo para formatação:
set formatprg=indent    " usar 'indent' para código C

" Formatear seleção:
gq{motion}          " formatear usando formatprg
gq}                 " formatear parágrafo
gqG                 " formatear até fim do arquivo

" Configurações de formatação:
set textwidth=79    " largura máxima do texto
set formatoptions=tcroql
" t: quebra automática de texto
" c: quebra automática de comentários
" r: inserir líder de comentário após Enter
" o: inserir ler de comentário após 'o' ou 'O'
" q: permitir formatação de comentários com 'gq'
" l: não quebrar linhas longas em modo insert
```

#### Formatação Manual

```vim
" Juntar linhas:
J                   " juntar linha atual com próxima
gJ                  " juntar sem inserir espaço

" Quebrar linha:
r<Enter>            " quebrar linha na posição do cursor

" Centralizar texto:
:center             " centralizar linha atual
:1,5center 40       " centralizar linhas 1-5 em coluna 40
```

### Spell Ch Configuração Básica

```vim
" Ativar spell checking:
:set spell          " ativar verificação ortográfica
:set spelllang=en_us,pt_br  " configurar idiomas

" Navegação:
]s                  " próximo erro ortográfico
[s                  " erro anterior
z=                  " sugestões para palavra sob cursor
zg                  " adicionar palavra ao dicionário pessoal
zw                  " marcar palavra como incorreta
```

#### Configuração Avançada

```vim
" Configurar diretórios:
set spellfile=~/.vim/spell/personal.add

" Highlighting personalizado:
highlight SpellBad cterm=underline ctermfg=red
highlight SpellCap cterm=underline ctermfg=yellow
```

### Encryption

#### Criptografia de Arquivos

```vim
" Definir senha para arquivo:
:set key=           " define senha (será solicitada)
:X                  " atalho para definir senha

" Salvar arquivo criptografado:
:w

" Configurar método de criptografia:
:set cryptmethod=blowfish2  " usar algoritmo blowfish2
```

### Remote File Editing

## Edição via Rede

```vim
" Editar arquivo remoto via scp:
:e scp://user@host/path/file.txt

" Editar via ftp:
:e ftp://user@host/path/file.txt

" Salvar arquivo remoto:
:w

" Configurar netrw para redes:
let g:netrw_ftpmode="binary"
let g:netrw_ssh_cmd="ssh -o User=myuser"
```

### Performance Profiling

#### Profiling de Startup

```vim
" Executar vim com profiling:
vim --startuptime startup.log

" Analisar tempo de startup:
:profile start profile.log
:profile func *
:profile file *
" executar operaçõprofile pause
:noautocmd qall!
```

#### Medição de Performance

```vim
" Medir tempo de execução:
:function! TimedFunction()
:  let start = reltime()
:  " código a ser medido
:  echo 'Tempo: ' . reltimestr(reltime(start))
:endfunction
```

### Integração com Ferramentas Externas

#### Filtros Externos

```vim
" Usar comandos externos como filtros:
!{motion}command    " filtrar através de comando externo

" Exemplos:
!}sort              " ordenar parágrafo
!Gsort -n           " ordenar numericament arquivo
!5jsed 's/a/b/g'    " substituir 'a' por 'b' nas próximas 5 linhas

" No modo visual:
:'<,'>!sort         " ordenar seleção
```

#### Make Integration

```vim
" Configuração avançada de make:
set makeprg=make\ -j4\ $*   " usar 4 threads

" Capturar warnings específicos:
set errorformat+=%W%f:%l:\ warning:\ %m

" Make assíncrono (simulação):
command! AsyncMake !make & 
```

### Scripts e Automatização

#### Autoload Functions

```vim
" Criar função autoload:
" Arquivo: ~/.vim/autoload/nction! myutils#ToggleBackground()
    if &background == 'dark'
        set background=light
    else
        set background=dark
    endif
endfunction

" Usar no .vimrc:
nnoremap <leader>bg :call myutils#ToggleBackground()<CR>
```

#### Scripts Complexos

```vim
" Script para análise de projeto:
function! ProjectAnalysis()
    let total_lines = 0
    let file_count = 0
    
    for file in split(globpath('.', '**/*.py'), '\n')
        let file_count += 1
        let lines = len(readfile(file))
        lettotal_lines += lines
        echo printf('%s: %d linhas', file, lines)
    endfor
    
    echo printf('Total: %d arquivos, %d linhas', file_count, total_lines)
endfunction

command! ProjectAnalysis call ProjectAnalysis()
```

### Configuração do Terminal

#### Configurações Específicas de Terminal

```vim
" Detectar tipo de terminal:
if &term =~ "xterm"
    " configurações para xterm
    set t_Co=256
elseif &term =~ "screen"
    " configurações para screen/tmux
    set t_Co=256
    set ttymouse=xtf

" Configurar cursor por modo:
if &term =~ "xterm"
    let &t_SI = "\<Esc>[6 q"  " cursor fino em insert mode
    let &t_EI = "\<Esc>[2 q"  " cursor bloco em normal mode
endif
```

### Debugging de Scripts Vim

#### Debugging de .vimrc

```vim
" Adicionar pontos de debug:
echo "Debug: chegou aqui"
echo "Valor da variável: " . variavel

" Verificar se função existe:
if exists("*MyFunction")
    call MyFunction()
endif

" Verificar se comando existe:
if exists(":MyCommand")
    MyCommand
endif
```

#### sages e Logs

```vim
" Ver mensagens do Vim:
:messages           " mostrar histórico de mensagens
:messages clear     " limpar mensagens

" Log personalizado:
function! DebugLog(msg)
    execute 'redir >> ~/.vim/debug.log'
    echo strftime('%Y-%m-%d %H:%M:%S') . ': ' . a:msg
    redir END
endfunction
```

### Recursos de Acessibilidade

#### Configurações para Baixa Visão

```vim
" Aumentar contraste:
set background=dark
colorscheme default

" Cursor mais visível:
set cursorline
set cursorcolumn

" Foaior (depende do terminal):
set guifont=Monospace\ 14

" Destacar parênteses correspondentes:
set showmatch
set matchtime=2
```

#### Navegação por Voz

```vim
" Mapeamentos para comandos por voz:
nnoremap <leader>next ]c
nnoremap <leader>prev [c
nnoremap <leader>save :w<CR>
nnoremap <leader>quit :q<CR>
```

---

## Conclusão

Este guia completo do Vim vanilla fornece uma base sólida para dominar o editor sem dependência de plugins externos. O Vim é uma ferramenta poderosa que recompensa o investimenprendizado com produtividade significativamente aumentada.

### Próximos Passos Recomendados

1. **Prática Diária**: Use o Vim como editor principal por pelo menos 30 dias
2. **Configuração Gradual**: Adicione configurações ao .vimrc gradualmente
3. **Workflow Específico**: Adapte técnicas para seu tipo de desenvolvimento
4. **Comunidade**: Participe de fóruns e grupos sobre Vim
5. **Documentação**: Consulte `:help` regularmente para aprofundar conhecimentos

### Recursos para Continuidade

- `:nual` - Manual completo do usuário
- `:help tips` - Dicas oficiais
- `:help reference` - Referência completa de comandos
- Vim Tips Wiki - Coleção comunitária de técnicas
- Stack Overflow tag 'vim' - Soluções para problemas específicos

O domínio do Vim vanilla é uma jornada contínua. Cada funcionalidade aprendida se combina com as outras para criar workflows cada vez mais eficientes. A filosofia do Vim de composição de comandos simples para operações complexas torna-se natural com a prátic, resultando em uma produtividade de edição incomparável.
