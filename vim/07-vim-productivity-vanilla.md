# Recursos de Produtividade Vanilla do Vim: Guia Completo Para Iniciantes

## Por Que Este Guia É Importante?

Se você está começando no Vim, pode parecer que o editor "básico" é limitado comparado aos editores modernos. **Isso é um equívoco!** O Vim vanilla (sem plugins) possui recursos nativos extremamente poderosos que, uma vez compreendidos, transformam completamente sua experiência de edição.

### O Que Você Vai Aprender

Este guia ensina, passo a passo, como usar recursos nativos do Vim que:
- **Economizam centenas de teclas por dia** através de abbreviations inteligentes
- **Aceleram navegação** com text objects e operators  
- **Automatizam tarefas repetitivas** sem plugins externos
- **Criam um ambiente de trabalho personalizado** usando apenas configurações nativas

### Como Usar Este Guia

**Para iniciantes:** Comece com "Primeiros Passos" e pratique cada seção antes de avançar.
**Para usuários intermediários:** Foque nas seções "Técnicas Avançadas" para expandir seu conhecimento.
**Para referência:** Use os exemplos práticos como templates para suas próprias configurações.

## 1. Sistema de Abbreviations: Seu Primeiro Grande Ganho de Produtividade

### O Que São Abbreviations?

**Abbreviations** são "atalhos de texto" que o Vim expande automaticamente. É como ter um assistente que digita para você!

**Exemplo prático:** 
Você digita `teh` + espaço → Vim automaticamente corrige para `the`

### Primeiros Passos: Correções Automáticas

**Por que fazer isso?** 
Todos cometemos erros de digitação. Em vez de corrigir manualmente cada vez, deixe o Vim fazer isso automaticamente.

**Como configurar:**
```vim
" Cole estas linhas no seu ~/.vimrc
:iabbrev teh the
:iabbrev adn and  
:iabbrev recieve receive
:iabbrev seperate separate
:iabbrev definately definitely
```

**Como testar:**
1. Abra o Vim
2. Entre em modo Insert (`i`)
3. Digite `teh` seguido de espaço
4. Observe a correção automática!

### Expandindo para Produtividade

**Próximo nível:** Use abbreviations para termos que você digita frequentemente.

```vim
" Expansões para programação (adicione ao ~/.vimrc)
:iabbrev funciton function
:iabbrev reutrn return
:iabbrev lenght length
:iabbrev widht width

" Expansões para escrita técnica
:iabbrev eg e.g.,
:iabbrev ie i.e.,
:iabbrev etc et cetera
```

**💡 Dica de Aprendizado:** Comece com 3-5 abbreviations. Adicione mais gradualmente conforme se acostuma.

### Técnica Avançada: Abbreviations Dinâmicas

**O que torna isso poderoso?**
Até agora, nossas abbreviations eram estáticas (sempre expandiam para o mesmo texto). Mas e se pudéssemos criar abbreviations que mudam baseado no contexto?

#### Data e Hora Automática

**Cenário real:** Você mantém logs, commit messages, ou anotações com timestamps.

**Solução inteligente:**
```vim
" Adicione ao ~/.vimrc
:iabbrev <expr> ddate strftime('%Y-%m-%d')
:iabbrev <expr> dtime strftime('%H:%M:%S')
:iabbrev <expr> ddatetime strftime('%Y-%m-%d %H:%M:%S')
```

**Como usar:**
1. Digite `ddate` + espaço → `2024-03-15` (data atual)
2. Digite `dtime` + espaço → `14:30:25` (hora atual)
3. Digite `ddatetime` + espaço → `2024-03-15 14:30:25` (data e hora)

**🎯 Exercício Prático:** 
Crie um arquivo de log pessoal e use essas abbreviations para timestamp suas anotações.

#### Informações Automáticas do Arquivo

**Por que é útil?**
Ao escrever documentação, comentários de código, ou logs, frequentemente precisamos referenciar o arquivo atual.

**Configuração inteligente:**
```vim
" Adicione ao ~/.vimrc
:iabbrev <expr> fname expand('%:t')     " Nome do arquivo
:iabbrev <expr> fpath expand('%:p')     " Caminho completo
:iabbrev <expr> fdir expand('%:p:h')    " Diretório do arquivo
:iabbrev <expr> myname $USER            " Seu nome de usuário
```

**Exemplo prático:**
Em um comentário Python:
```python
# Arquivo: myname - fname
# Localização: fdir
```
Se torna automaticamente:
```python
# Arquivo: joao - script.py
# Localização: /home/joao/projeto
```

**🚀 Dica Profissional:** Use isso em templates de header para seus arquivos de código!

### Técnica Avançada: Abbreviations Multi-linha

**Desafio comum:** Como criar "snippets" de código sem plugins?

**Solução nativa:** Abbreviations podem incluir quebras de linha e até comandos do Vim!

**⚠️ Aviso para Iniciantes:** Esta seção é mais complexa. Se você é novo no Vim, foque primeiro nas técnicas anteriores.

#### Criando Templates de Código

**O que vamos construir:** Um template de função Python completo.

**Versão simples (recomendada para iniciantes):**
```vim
" Template básico de função Python
:iabbrev pydef def function_name():<CR>    """Docstring"""<CR>    pass
```

**Como usar:**
1. Digite `pydef` + espaço
2. Vim cria automaticamente:
```python
def function_name():
    """Docstring"""
    pass
```
3. Use `Ctrl+W` para navegar entre os campos e customize

**Versão avançada (para usuários experientes):**
```vim
" Template com posicionamento automático do cursor
:iabbrev pydef def <C-o>:call cursor(line('.'), col('.')-1)<CR>function_name():<CR>    \"\"\"Docstring\"\"\"<CR>    pass<C-o>3k<C-o>f_
```
Esta versão posiciona automaticamente o cursor no nome da função para edição rápida.

### Abbreviations Específicas por Linguagem

**Problema:** Abbreviations globais podem conflitar entre linguagens diferentes.
**Solução:** Abbreviations específicas por tipo de arquivo (`filetype`).

#### Como Funciona

O Vim pode detectar automaticamente o tipo de arquivo (Python, JavaScript, HTML) e ativar abbreviations específicas.

#### Configuração Passo a Passo

**Para Python:**
```vim
" Adicione ao ~/.vimrc
autocmd FileType python :iabbrev <buffer> pprint import pprint; pprint.pprint()
autocmd FileType python :iabbrev <buffer> ipdb import ipdb; ipdb.set_trace()
autocmd FileType python :iabbrev <buffer> utf # -*- coding: utf-8 -*-
```

**Para JavaScript:**
```vim
autocmd FileType javascript :iabbrev <buffer> cl console.log();<Left><Left>
autocmd FileType javascript :iabbrev <buffer> fun function() {}<Left><Left><Left>
```

**Para HTML:**
```vim
autocmd FileType html :iabbrev <buffer> html5 <!DOCTYPE html><CR><html lang=\"pt-BR\"><CR><head><CR><meta charset=\"UTF-8\"><CR><title></title><CR></head><CR><body><CR></body><CR></html>
```

**🔍 Como Testar:**
1. Crie um arquivo `test.py` 
2. Digite `pprint` + espaço → Veja a expansão Python
3. Crie um arquivo `test.js`
4. Digite `cl` + espaço → Veja a expansão JavaScript

**💡 Entendendo a Sintaxe:**
- `autocmd FileType python` = "Quando abrir arquivo Python"
- `:iabbrev <buffer>` = "Criar abbreviation apenas neste buffer"
- `<Left><Left>` = "Mover cursor para posição útil"

## 2. Wildmenu: Transformando a Linha de Comando

### O Que É e Por Que Importa?

**Problema comum:** Digitar comandos longos no Vim é tedioso e propenso a erros.
**Solução nativa:** O Wildmenu oferece autocompletion inteligente na linha de comando.

**Exemplo visual:**
Sem wildmenu: `:colorscheme` + TAB = nada acontece 😞
Com wildmenu: `:colorscheme` + TAB = menu com todas as opções! 🎉

### Configuração Essencial (Faça Agora!)

**Adicione estas linhas ao seu ~/.vimrc:**
```vim
" Ativar wildmenu (ESSENCIAL)
set wildmenu

" Como o menu se comporta
set wildmode=longest:full,full

" Menu estilo popup (se seu Vim suporta)
set wildoptions=pum
```

**O que cada linha faz:**
- `set wildmenu` → Liga o sistema de menu
- `set wildmode=longest:full,full` → Primeiro TAB completa o máximo possível, segundo TAB mostra menu
- `set wildoptions=pum` → Menu em estilo popup (mais bonito)

**🎯 Teste Imediato:**
1. Reinicie o Vim ou execute `:source ~/.vimrc`
2. Digite `:color` e pressione TAB
3. Veja a mágica acontecer!

### Configuração Profissional

**Próximo nível:** Filtrar arquivos irrelevantes e tornar busca case-insensitive.

**Por que fazer isso?**
Sem filtros, o wildmenu mostra TODOS os arquivos, incluindo:
- Arquivos compilados (`.pyc`, `.o`)
- Diretórios de controle de versão (`.git/`)
- Arquivos de sistema (`.DS_Store`)
- Imagens e documentos quando você quer código

**Configuração inteligente:**
```vim
" Adicione ao ~/.vimrc
set wildmenu
set wildmode=list:longest,full

" Ignorar arquivos irrelevantes
set wildignore=*.o,*.obj,*.pyc,*.class,*.jar
set wildignore+=*.git/*,*.hg/*,*.svn/*
set wildignore+=*.DS_Store,*.orig
set wildignore+=*.jpg,*.jpeg,*.png,*.gif,*.bmp
set wildignore+=*.pdf,*.doc,*.docx,*.ppt,*.pptx

" Busca case-insensitive
set wildignorecase
```

**🔍 Teste a Diferença:**
1. Abra um projeto com muitos arquivos
2. Digite `:e ` (edit) + TAB
3. Compare antes/depois da configuração

## 3. Text Objects e Operators: A Linguagem Secreta do Vim

### Por Que Isso Vai Revolucionar Sua Edição

**Text Objects** e **Operators** são o "superpoder" do Vim que outros editores não têm.

**Analogia:** É como ter uma linguagem para falar com o editor:
- "Delete inside parentheses" → `di(`
- "Change around word" → `caw`
- "Yank inner quotes" → `yi"`

### Como Funciona a "Gramática" do Vim

**Fórmula mágica:** `[Operator] + [Text Object]`

**Operators (Verbos):**
- `d` = delete (deletar)
- `c` = change (mudar)
- `y` = yank (copiar)
- `v` = visual select (selecionar)

**Text Objects (Substantivos):**
- `w` = word (palavra)
- `s` = sentence (sentença)  
- `p` = paragraph (parágrafo)
- `(` = parentheses (parênteses)
- `"` = quotes (aspas)

**💡 Mnemônicos para Lembrar:**
- `diw` = "Delete Inner Word"
- `cap` = "Change A Paragraph"
- `yi"` = "Yank Inner Quotes"

### Primeiros Text Objects: Dominando Palavras

**Comece aqui!** Pratique com palavras antes de avançar.

#### Diferença entre "inner" (i) e "around" (a)

**Exemplo prático:** Na palavra `hello`
- `iw` (inner word) = seleciona `hello`  
- `aw` (a word) = seleciona `hello ` (inclui espaço após)

**🎯 Exercício Prático:**
1. Escreva: `This is a test sentence with words.`
2. Posicione cursor em qualquer palavra
3. Teste:
   - `diw` → deleta palavra
   - `daw` → deleta palavra + espaço
   - `ciw` → deleta palavra e entra em insert
   - `yiw` → copia palavra

#### Expandindo para Sentenças e Parágrafos

**Após dominar palavras, pratique:**

```vim
" Sentenças (terminam com . ! ?)
is - inner sentence (só o texto)
as - a sentence (com pontuação e espaços)

" Parágrafos (separados por linha vazia)
ip - inner paragraph (só o texto)  
ap - a paragraph (inclui linhas vazias)
```

**📝 Dica de Aprendizado:** 
Pratique um tipo por vez. Só avance quando se sentir confortável.

### Text Objects para Programação

**Aqui é onde o Vim brilha!** Editar código fica extremamente eficiente.

#### Parênteses, Chaves e Colchetes

```vim
" Parênteses () 
i( ou i) - dentro dos parênteses
a( ou a) - incluindo os parênteses

" Chaves {}
i{ ou i} - dentro das chaves  
a{ ou a} - incluindo as chaves

" Colchetes []
i[ ou i] - dentro dos colchetes
a[ ou a] - incluindo os colchetes
```

**🎯 Exercício com Código:**
```python
print("Hello World")
data = {"name": "João", "age": 30}
list = [1, 2, 3, 4, 5]
```

1. Posicione cursor dentro de `("Hello World")`
2. `di(` → deleta `"Hello World"`
3. `da(` → deleta `("Hello World")`

#### Aspas e Strings

```vim
" Aspas duplas "
i" - dentro das aspas duplas
a" - incluindo as aspas duplas

" Aspas simples '
i' - dentro das aspas simples  
a' - incluindo as aspas simples

" Backticks ` (template strings)
i` - dentro dos backticks
a` - incluindo os backticks
```

**🚀 Exemplo Prático:**
```javascript
const message = "Hello, world!"
```

Cursor dentro da string:
- `di"` → deleta `Hello, world!`
- `ci"` → deleta conteúdo e entra em insert
- `yi"` → copia conteúdo da string

#### Text Objects para HTML/XML

**Cenário:** Editando HTML ou XML

```vim
" Tags HTML/XML
it - inner tag (conteúdo entre tags)
at - a tag (incluindo as próprias tags)
```

**Exemplo prático:**
```html
<p>Este é um parágrafo.</p>
<div>Conteúdo do div</div>
```

Cursor dentro da tag `<p>`:
- `dit` → deleta `Este é um parágrafo.`
- `dat` → deleta `<p>Este é um parágrafo.</p>`
- `cit` → apaga conteúdo e entra em insert
- `yit` → copia o conteúdo

**🎯 Exercício HTML:**
1. Crie um arquivo HTML simples
2. Pratique `dit`, `dat`, `cit` em diferentes tags
3. Observe como o Vim "entende" a estrutura HTML

### Dominando os Operators

**Agora que você conhece Text Objects, vamos aos Operators (verbos).**

#### Os "Big 4" Operators Essenciais

**Comece com estes 4:**

```vim
d - delete (deletar)
c - change (mudar = delete + insert)
y - yank (copiar)
v - visual select (selecionar visualmente)
```

**🎯 Exercício de Fixação:**
Com o texto: `function calculateSum(a, b) { return a + b; }`

1. Cursor no `calculateSum`:
   - `diw` → deleta nome da função
   - `ciw` → muda nome da função
   - `yiw` → copia nome da função
   - `viw` → seleciona nome da função

2. Cursor dentro dos parênteses `(a, b)`:
   - `di(` → deleta parâmetros
   - `ci(` → muda parâmetros
   - `yi(` → copia parâmetros

#### Operators de Formatação

**Para código limpo e organizado:**

```vim
= - indent/format (usa configuração do Vim)
> - indent right (adiciona indentação)
< - indent left (remove indentação)
```

**Exemplos práticos:**
- `=ip` → formatar parágrafo atual
- `>i{` → indentar dentro das chaves
`<ap` → des-indentar parágrafo

#### Operators de Capitalização

**Para transformar texto:**

```vim
gu - lowercase (minúsculas)
gU - uppercase (maiúsculas)  
g~ - toggle case (alternar)
```

**🎯 Experimente:**
- `guiw` → palavra em minúsculas
- `gUiw` → palavra em maiúsculas
- `g~iw` → alternar capitalização

#### Combinações Que Vão Mudar Sua Vida

**Agora a mágica acontece!** Combine operators + text objects:

**Para Palavras:**
```vim
diw - delete inner word (apagar palavra)
ciw - change inner word (trocar palavra)
yiw - yank inner word (copiar palavra)
viw - visual select inner word (selecionar palavra)
```

**Para Código:**
```vim
di( - delete everything inside parentheses
ci{ - change everything inside braces  
yi" - yank everything inside double quotes
```

ap**Para Texto:**
```vim
dap - delete a paragraph
cap - change a paragraph
yip - yank inner paragraph
```

**🚀 Cenários Reais de Uso:**

**Cenário 1:** Trocar nome de variável
```python
old_variable_name = teste
```
Cursor na variável → `ciw` → digite novo nome → ESC

**Cenário 2:** Deletar conteúdo de função
```javascript
function test() {
    // muito código aqui
    console.log("test");
}
```
Cursor dentro das chaves → `di{` → apaga todo o conteúdo

**Cenário 3:** Copiar string
```python
message = "Esta é uma mensagem importante"
```
Cursor na string → `yi"` → copia o texto das aspas

**💡 Dica Pro:** 
Essas combinações funcionam de qualquer lugar dentro do text object. O cursor não precisa estar no início!

## 4. Digraphs: Caracteres Especiais Sem Complicação

### O Problema dos Caracteres Especiais

**Situação comum:** Você precisa digitar:
- Acentos: á, é, ç, ã
- Símbolos: ©, ®, €, ±
- Matemática: ≤, ≥, ≠, ×

**Métodos complicados:**
- Memorizar códigos ASCII ❌
- Alt + números no Windows ❌  
- Configurar teclado internacional ❌

**Solução do Vim:** Digraphs - dois caracteres simples que viram um especial!

### Como Usar Digraphs (Passo a Passo)

**Fórmula:** `Ctrl+K` + `dois caracteres` = `caractere especial`

#### Acentos em Português

**Lógica intuitiva:** `letra` + `acento`

```vim
" Em modo Insert:
Ctrl+K a' → á (a + acento agudo)
Ctrl+K a` → à (a + acento grave)  
Ctrl+K a~ → ã (a + til)
Ctrl+K a^ → â (a + circunflexo)
Ctrl+K c, → ç (c + cedilha)
Ctrl+K e' → é (e + acento agudo)
Ctrl+K o^ → ô (o + circunflexo)
```

**🎯 Exercício Prático:**
1. Entre em modo Insert (`i`)
2. Digite `Ctrl+K a'` → veja o `á`
3. Digite `Ctrl+K c,` → veja o `ç`
4. Escreva "São Paulo" usando digraphs

#### Símbolos Úteis

**Para matemática e programação:**

```vim
Ctrl+K +- → ± (mais ou menos)
Ctrl+K *X → × (multiplicação)
Ctrl+K -: → ÷ (divisão)
Ctrl+K != → ≠ (diferente)
Ctrl+K <= → ≤ (menor ou igual)
Ctrl+K >= → ≥ (maior ou igual)
```

**Para símbolos comerciais:**

```vim
Ctrl+K Ct → ¢ (centavos)
Ctrl+K Pd → £ (libra)
Ctrl+K EU → € (euro)
Ctrl+K Co → © (copyright)
Ctrl+K Rg → ® (registered)
```

### Descobrindo Digraphs Disponíveis

**Comando mágico:** `:digraphs`

Este comando mostra TODOS os digraphs disponíveis no seu Vim.

**Como ler a saída:**
```
a'  225  á    e'  233  é    o'  243  ó
```
- `a'` = combinação de teclas
- `225` = código ASCII
- `á` = resultado

**🔍 Buscar Digraphs Específicos:**
```vim
:digraphs | grep -E '^[aeiou]'  " Vogais com acentos
:digraphs | grep '€\|£\|¥'      " Símbolos de moeda
```

**💡 Dica:** Use `:digraphs` como referência rápida quando esquecer uma combinação.

### Criando Seus Próprios Digraphs

**Por que personalizar?**
Os digraphs padrão podem não cobrir símbolos que você usa frequentemente.

**Sintaxe:** `digraph [dois_chars] [código_unicode]`

#### Digraphs Úteis para Programadores

```vim
" Adicione ao ~/.vimrc
digraph \|> 8594   " → (seta direita)
digraph <\| 8592   " ← (seta esquerda)  
digraph /\ 8593    " ↑ (seta cima)
digraph \/ 8595    " ↓ (seta baixo)

" Para documentação técnica
digraph != 8800    " ≠ (não igual)
digraph ~= 8776    " ≈ (aproximadamente igual)
digraph ** 8729    " ∗ (operador)
```

**Como usar:**
1. Adicione ao `.vimrc`
2. Reinicie Vim ou `:source ~/.vimrc`
3. Em Insert mode: `Ctrl+K |>` → `→`

#### Digraphs para Símbolos Gregos

**Útil para matemática/física:**

```vim
digraph al 945     " α (alpha)
digraph bt 946     " β (beta)
digraph gm 947     " γ (gamma)
digraph dl 948     " δ (delta)
digraph pi 960     " π (pi)
```

**🎯 Caso de Uso:**
Escrevendo documentação científica ou fórmulas matemáticas.

#### Digraphs Divertidos

```vim
" Para comunicação casual
digraph :) 9786    " ☺
digraph :( 9785    " ☹
digraph <3 9829    " ♥
digraph !! 8252    " ‼
```

**⚠️ Dica:** Use códigos Unicode que você consegue lembrar. `al` para alpha, `bt` para beta, etc.

## 5. Técnicas de Edição que Vão Impressionar

### Por Que Essas Técnicas Importam

**Cenário:** Você tem tarefas repetitivas de edição:
- Incrementar números em sequência
- Formatar blocos de texto  
- Juntar múltiplas linhas
- Criar listas numeradas

**Resultado:** Com as técnicas a seguir, tarefas de 10 minutos viram 10 segundos.

### Incremento/Decremento: Matemática Instantânea

#### Básico: Um Número por Vez

**Comandos essenciais:**
```vim
Ctrl+A " incrementar número sob o cursor (+1)
Ctrl+X " decrementar número sob o cursor (-1)
```

**🎯 Teste Rápido:**
1. Digite: `Versão 4`
2. Posicione cursor no `5`  
3. Pressione `Ctrl+A` → `Versão 6`
4. Pressione `Ctrl+X` → `Versão 5`

#### Incremento com Valores Específicos

**Sintaxe:** `[número]Ctrl+A` ou `[número]Ctrl+X`

```vim
5<Ctrl+A>  " incrementar 5
10<Ctrl+X> " decrementar 10
100<Ctrl+A> " incrementar 100
```

**Exemplo prático:**
- Texto: `count = 0`
- Cursor no `0`
- `50<Ctrl+A>` → `count = 50`

#### Técnica Avançada: Sequências Automáticas

**Cenário:** Você tem uma lista que precisa ser numerada:
```
item1
item1  
item1
item1
```

**Objetivo:** Transformar em:
```
item1
item2
item3
item4
```

**Solução mágica:**
1. Posicione cursor no primeiro `1`
2. `Ctrl+V` (visual block mode)
3. Selecione coluna dos números (`j` para descer)
4. `g<Ctrl+A>` → incrementa sequencialmente!

**🎯 Exercício Prático:**
1. Crie 5 linhas: `task1`
2. Use visual block para selecionar os números
3. `g<Ctrl+A>` para criar sequência
4. Resultado: `task1`, `task2`, `task3`, `task4`, `task5`

**🚀 Aplicação Real:**
- Numeração de itens em documentação
- IDs sequenciais em código
- Listas ordenadas

### Formatação Automática de Texto

#### O Problema da Formatação Manual

**Situação comum:** Você tem um parágrafo com linhas muito longas ou muito curtas:

```
Este é um parágrafo muito longo que precisa ser formatado porque está numa linha só e fica difícil de ler no editor.

Ou você tem
um parágrafo
com linhas
muito curtas
que também
fica ruim.
```

#### Solução Automática

**Configuração necessária:**
```vim
" Adicione ao ~/.vimrc
set textwidth=78  " Largura máxima da linha
```

**Comandos de formatação:**
```vim
gq     " formatar usando textwidth
gw     " formatar preservando posição do cursor
=      " indentar automaticamente
```

**🎯 Teste Prático:**
1. Configure `set textwidth=50`
2. Escreva uma linha muito longa
3. Posicione cursor no parágrafo
4. `gqap` → veja a mágica!

#### Formatação Específica

```vim
gqap   " formatar parágrafo atual (a paragraph)
gqip   " formatar inner paragraph
gq}    " formatar até próximo parágrafo vazio
```

**💡 Dica:** `gw` é melhor que `gq` porque mantém o cursor na posição original.

### Join: Juntando Linhas com Inteligência

#### O Problema das Linhas Quebradas

**Situação:** Você tem texto quebrado incorretamente:
```
Esta é uma frase
que foi quebrada
no lugar errado.
```

**Objetivo:** `Esta é uma frase que foi quebrada no lugar errado.`

#### Comandos de Join

```vim
J      " join linha seguinte (com espaço automático)
gJ     " join linha seguinte (sem adicionar espaço)
```

**🎯 Teste os Dois:**
1. Texto de exemplo:
   ```
   Linha1
   Linha2
   ```
2. Cursor na primeira linha
3. `J` → `Linha1 Linha2` (com espaço)
4. `u` (undo), depois `gJ` → `Linha1Linha2` (sem espaço)

#### Join Múltiplas Linhas

**Para juntar várias linhas de uma vez:**
```vim
3J     " juntar próximas 3 linhas
5J     " juntar próximas 5 linhas
```

**Exemplo prático:**
```
Código:
função
que estava
em linhas
separadas
```
Cursor na primeira linha + `4J` → `Código: função que estava em linhas separadas`

## 6. Configuração Completa: Juntando Tudo

### Seu Primeiro .vimrc de Produtividade

**Chegou a hora!** Vamos criar um `.vimrc` que implementa tudo que aprendemos.

**Por que isso importa:**
- Você não quer reconfigurar tudo sempre
- Configuração padronizada entre máquinas  
- Base sólida para crescer

### O ~/.vimrc Definitivo (Para Iniciantes)

**Cole este conteúdo no seu `~/.vimrc`:**

```vim
" ====================================================
" CONFIGURAÇÃO DE PRODUTIVIDADE VIM VANILLA
" Baseada no guia de recursos nativos do Vim
" ====================================================

" ---- CONFIGURAÇÕES BÁSICAS ----
" Números de linha
set number relativenumber

" Mouse funcional
set mouse=a

" Clipboard do sistema
set clipboard=unnamedplus

" Histórico de undo persistente
set undofile
set undodir=~/.vim/undo

" ---- WILDMENU (AUTOCOMPLETION NA LINHA DE COMANDO) ----
set wildmenu
set wildmode=list:longest,full
set wildoptions=pum
" Ignorar arquivos irrelevantes
set wildignore=*.o,*.pyc,*.jpg,*.png,*.pdf,*.exe
set wildignore+=*.git/*,*.DS_Store
set wildignorecase

" ---- COMPLETION (AUTOCOMPLETION NO TEXTO) ----
set complete=.,w,b,u,t,i,kspell
set completeopt=menuone,longest,noselect
set pumheight=15

" ---- BUSCA INTELIGENTE ----
set ignorecase smartcase
set incsearch hlsearch

" ---- INDENTAÇÃO E FORMATAÇÃO ----
set autoindent smartindent
set expandtab
set tabstop=4 shiftwidth=4
set textwidth=78

" ---- ABBREVIATIONS ÚTEIS ----
" Correções de digitação
iabbrev teh the
iabbrev adn and
iabbrev recieve receive

" Data e hora dinâmica
iabbrev <expr> ddate strftime('%Y-%m-%d')
iabbrev <expr> dtime strftime('%H:%M')
iabbrev <expr> fname expand('%:t')

" ---- ABBREVIATIONS POR LINGUAGEM ----
autocmd FileType python iabbrev <buffer> ipdb import ipdb; ipdb.set_trace()
autocmd FileType python iabbrev <buffer> utf # -*- coding: utf-8 -*-
autocmd FileType javascript iabbrev <buffer> cl console.log();<Left><Left>
autocmd FileType html iabbrev <buffer> html5 <!DOCTYPE html><CR><html><CR><head><CR><title></title><CR></head><CR><body><CR></body><CR></html>

" ---- DIGRAPHS PERSONALIZADOS ----
digraph -> 8594  " →
digraph <- 8592  " ←
digraph != 8800  " ≠

" ---- MAPEAMENTOS DE PRODUTIVIDADE ----
" Salvar e sair rapidamente
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" Navegação entre janelas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ---- CRIAR DIRETÓRIOS NECESSÁRIOS ----
if !isdirectory($HOME.'/.vim/undo')
    call mkdir($HOME.'/.vim/undo', 'p')
endif
```

**🚀 Como usar esta configuração:**

1. **Backup atual:** `cp ~/.vimrc ~/.vimrc.backup` (se existir)
2. **Criar novo:** Abra `~/.vimrc` no Vim
3. **Colar configuração:** Use `Ctrl+Shift+V` para colar
4. **Salvar:** `:w`
5. **Recarregar:** `:source ~/.vimrc` ou reiniciar Vim
6. **Testar:** Digite `teh ` e veja a correção automática!

## 7. Jornada de Aprendizado: Próximos Passos

### Semana 1: Fundamentos Sólidos

**🎯 Meta:** Dominar o básico sem sobrecarga

**Foco desta semana:**
1. **Abbreviations básicas:** Configure 5 correções de digitação
2. **Text objects essenciais:** Pratique `iw`, `aw`, `i(`, `a(`
3. **Operators básicos:** Domine `d`, `c`, `y`, `v`
4. **Wildmenu:** Configure e use para comandos `:e`, `:color`

**📝 Exercício diário (10 minutos):**
- Abra um arquivo de texto qualquer
- Pratique `diw`, `ciw`, `di(`, `yi"`
- Use uma abbreviation diferente a cada dia

### Semana 2: Combinações Poderosas

**🎯 Meta:** Fluência em operator + text object

**Expansão do conhecimento:**
1. **Text objects avançados:** `ip`, `ap`, `it`, `at`
2. **Digraphs úteis:** Acentos em português
3. **Abbreviations por filetype:** Configure para sua linguagem principal
4. **Incremento/decremento:** `Ctrl+A`, `Ctrl+X`

**🚀 Desafio da semana:**
Edite um arquivo HTML usando apenas text objects e operators (sem usar mouse).

### Semana 3: Personalização Avançada

**🎯 Meta:** Vim personalizado para SEU workflow

**Personalize seu ambiente:**
1. **Abbreviations dinâmicas:** Data, nome do arquivo
2. **Digraphs personalizados:** Símbolos que você usa
3. **Text objects customizados:** Para seu tipo de trabalho
4. **Wildmenu otimizado:** Para seus tipos de arquivo

### Semana 4: Maestria e Automação

**🎯 Meta:** Vim como extensão do seu pensamento

**Técnicas avançadas:**
1. **Macros complexos:** Automatizar tarefas repetitivas
2. **Registers estratégicos:** Múltiplos clipboards
3. **Marks para navegação:** Entre arquivos e projetos
4. **Join e formatação:** Manipulação de texto avançada

### Medindo Seu Progresso

**Sinais de que você está dominando:**

✅ **Semana 1:** Você para de usar mouse para edição básica
✅ **Semana 2:** Text objects se tornam naturais
✅ **Semana 3:** Você cria suas próprias abbreviations
✅ **Semana 4:** Colegas perguntam "como você fez isso tão rápido?"

### Dicas para Não Desistir

**💡 Mentalidade correta:**
- **Início:** Você será mais lento (é normal!)
- **Frustração:** É sinal de que está aprendendo
- **Progresso:** Vem em ondas, não linear
- **Persistência:** 21 dias para formar hábito

**🎯 Micro-hábitos:**
- Use UMA nova técnica por dia
- Pratique 5 minutos antes de trabalhar
- Comemore pequenas vitórias
- Mantenha cheat sheet visível

### Recursos de Apoio

**Para tirar dúvidas:**
```vim
:help text-objects    " Ajuda sobre text objects
:help operator        " Ajuda sobre operators
:help abbreviations   " Ajuda sobre abbreviations
:help digraph-table   " Lista de digraphs
```

**Comunidades:**
- r/vim (Reddit)
- #vim (IRC)
- Stack Overflow (tag vim)

### Mantendo a Motivação

**🏆 Metas de longo prazo:**
- **1 mês:** Edição básica fluente
- **3 meses:** Vim mais rápido que editor anterior  
- **6 meses:** Ajudando outros com Vim
- **1 ano:** Configuração Vim personalizada e poderosa

**💪 Lembre-se:**
Cada técnica que você domina é uma habilidade permanente. Investimento em Vim é investimento para a vida toda como programador/escritor.

## Conclusão: Você Tem Tudo Para Ser Produtivo

### O Que Você Descobriu

Este guia revelou que o "Vim simples" na verdade é um **editor extremamente sofisticado** disfarçado de minimalista. Você agora sabe que:

**✨ Abbreviations:** Transformam digitação repetitiva em automação inteligente
**🎯 Text Objects + Operators:** Criam uma "linguagem" para falar com o editor
**🚀 Wildmenu:** Torna linha de comando tão eficiente quanto GUI moderna
**🔤 Digraphs:** Resolvem caracteres especiais sem complicação
**⚡ Técnicas de edição:** Automatizam tarefas que outros editores fazem manualmente

### A Verdade Sobre Produtividade

**Mito:** "Vim é produtivo só com plugins"
**Realidade:** Vim vanilla já é mais poderoso que a maioria dos editores modernos

**Mito:** "Curva de aprendizado é impossível"
**Realidade:** Com método e prática gradual, em 1 mês você já é fluente

**Mito:** "Precisa memorizar centenas de comandos"
**Realidade:** 20-30 combinações resolvem 80% das tarefas

### Seu Próximo Passo

**Não deixe este conhecimento parado!**

1. **Hoje:** Implemente a configuração base do ~/.vimrc
2. **Esta semana:** Pratique text objects 10 minutos por dia  
3. **Este mês:** Adicione uma abbreviation nova semanalmente
4. **Sempre:** Quando fizer algo repetitivo, pense "há uma maneira Vim de fazer isso"

### Uma Última Reflexão

O Vim não é apenas um editor - é uma **filosofia de eficiência**. Cada minuto investido aprendendo retorna em **horas economizadas** ao longo da carreira.

Você agora tem as ferramentas. **O próximo nível depende só da sua prática.**

**Bem-vindo à produtividade vanilla do Vim! 🎉**
