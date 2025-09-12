# Sistemas de Completion do Vim

## Métodos Nativos de Completion

### Completion Básico
- **Completion para frente**: `Ctrl+n` - busca do cursor até o fim do arquivo
- **Completion para trás**: `Ctrl+p` - busca do cursor até o início do arquivo
- **Navegar sugestões**: `Ctrl+n`/`Ctrl+p` para alternar entre opções

### Tipos Especializados de Completion

#### Completion de Linha
- **Comando**: `Ctrl+x Ctrl+l`
- **Função**: Completa linhas inteiras

#### Completion Ortográfico
- **Configuração**: `:set spell` primeiro
- **Comando**: `Ctrl+x Ctrl+s`
- **Função**: Sugere correções ortográficas

#### Completion de Caminho de Arquivo
- **Comando**: `Ctrl+x Ctrl+f`
- **Função**: Completa caminhos de arquivos e diretórios
- **Uso**: Digite caminho parcial, depois acione completion

#### Completion de Script Vim
- **Comando**: `Ctrl+x Ctrl+v`
- **Função**: Completa comandos e funções do Vim
- **Contexto**: Útil ao escrever scripts Vim

### Omni Completion
- **Comando**: `Ctrl+x Ctrl+o`
- **Configuração**: Requer `set omnifunc=` para linguagem específica
- **Exemplo JavaScript**: `set omnifunc=javascriptcomplete#CompleteJS`
- **Função**: Completion inteligente consciente da linguagem

### Encontrando Mais Tipos de Completion
- **Referência de ajuda**: `:help ins-completion`
- **Tipos disponíveis**: Dicionário, thesaurus, tags, arquivos incluídos, palavras-chave

## Plugin MuComplete

### Visão Geral
- Wrapper em torno do completion nativo do Vim
- Fornece experiência de completion "conforme você digita"
- Encadeia múltiplos métodos de completion

### Recursos Principais
- **Cadeias de completion**: Tenta múltiplos métodos em sequência
- **Consciência de contexto**: Completion diferente para comentários vs código
- **Configurações específicas de linguagem**: Personalizar por tipo de arquivo
- **Amigável à integração**: Funciona com snippets e outros plugins

### Estrutura de Configuração
```vim
" Configurações básicas
let g:mucomplete#enable_auto_at_startup = 1
set completeopt+=menuone,noselect

" Cadeias de completion
let g:mucomplete#chains = {
    \ 'default': ['omni', 'c-n', 'dict', 'uspl'],
    \ 'vim': ['cmd', 'c-n']
    \ }
```

### Códigos de Método de Completion
- `omni` - Omni completion
- `c-n` - Completion de palavra-chave  
- `dict` - Dicionário
- `uspl` - Ortografia
- `path` - Caminhos de arquivo
- `cmd` - Comandos Vim

### Configuração Específica de Linguagem
- **HTML**: `['omni', 'c-n']`
- **Markdown**: `['dict', 'uspl', 'c-n']`
- **Linguagens de programação**: `['omni', 'c-n', 'dict']`

## Criando Completion Personalizado

### Estrutura Básica de Função
```vim
function! MyCompletion()
    let words = ['opcao1', 'opcao2', 'opcao3']
    call complete(col('.'), words)
    return ''
endfunction
```

### Componentes Principais
- `complete(start_col, matches)` - Função central de completion
- `col('.')` - Coluna atual do cursor
- Listas de palavras personalizadas ou geração dinâmica

### Integração com MuComplete
```vim
let g:mucomplete#user_mappings = {
    \ 'mycomp' : "\<c-r>=MyCompletion()\<cr>"
    \ }
```

## Integração Avançada

### Language Server Protocol (LSP)
- **Plugins**: vim-lsc, vim-lsp
- **Função**: Completion aprimorado com servidores de linguagem externos
- **Benefícios**: Melhor precisão, mais contexto, integração com linting
- **Configuração**: Combina com sistema de omni completion

### Melhores Práticas
1. Comece com completion nativo para aprender fundamentos
2. Adicione MuComplete para melhor UX
3. Configure cadeias específicas de linguagem
4. Use LSP para suporte avançado de linguagem
5. Crie completions personalizados para fluxos de trabalho específicos

## Sistemas Nativos de Completion Avançado

### Completion via Tags (Ctrl+X Ctrl+])

#### Configuração de CTags
```bash
# Instalação do Universal CTags (recomendado)
sudo apt install universal-ctags

# Geração de tags para projeto Python
ctags -R --languages=Python --python-kinds=-i .

# Geração de tags para projeto JavaScript
ctags -R --languages=JavaScript .

# Tags para C/C++
ctags -R --c++-kinds=+p --fields=+iaS --extras=+q .
```

#### Configuração no Vim
```vim
" Configurar tags files
set tags=./tags,tags,../tags,../../tags

" Auto-regenerar tags ao salvar
autocmd BufWritePost *.py,*.js,*.c,*.cpp silent! !ctags -R .

" Mapeamento para regenerar tags manualmente
nnoremap <leader>rt :!ctags -R .<CR>
```

#### Uso Prático
- `Ctrl+X Ctrl+]` em modo Insert para completion baseado em tags
- `Ctrl+]` em modo Normal para saltar para definição
- `Ctrl+T` para voltar após salto
- `:tags` para ver stack de tags

### Include File Completion (Ctrl+X Ctrl+I)

#### Configuração
```vim
" Definir padrões de arquivos include
set include=^\s*#\s*include\s*[<"]
set includeexpr=substitute(v:fname,'\\.','/','g')

" Para Python
autocmd FileType python set include=^\s*from\\|^\s*import
autocmd FileType python set includeexpr=substitute(v:fname,'\\.','/','g').'py'

" Para JavaScript/Node.js
autocmd FileType javascript set include=^\s*[a-zA-Z_].*require(\s*['\"]\zs[^'\"]*
autocmd FileType javascript set includeexpr=v:fname.'.js'
```

#### Funcionalidade
- Busca em arquivos incluídos/importados
- Completion baseado no conteúdo dos includes
- Útil para APIs de bibliotecas

### Define Completion (Ctrl+X Ctrl+D)

#### Configuração para C/C++
```vim
" Definir padrões de define/macro
set define=^\s*#\s*define

" Para outros padrões de definição
set define=^\s*\(#\s*define\|const\s\+\w\+\s*=\)
```

#### Uso Prático
- Completion de macros e constantes
- Busca em `#define`, `const`, etc.
- Útil para constantes de sistema

### Thesaurus Completion Avançado (Ctrl+X Ctrl+T)

#### Configuração de Thesaurus
```bash
# Download de thesaurus para inglês
mkdir -p ~/.vim/thesaurus
wget https://www.gutenberg.org/files/3202/files/mthesaur.txt -O ~/.vim/thesaurus/english.txt
```

```vim
" Configuração de thesaurus
set thesaurus+=~/.vim/thesaurus/english.txt
set thesaurus+=~/.vim/thesaurus/technical.txt

" Thesaurus específico por filetype
autocmd FileType markdown,text set thesaurus+=~/.vim/thesaurus/writing.txt
autocmd FileType tex set thesaurus+=~/.vim/thesaurus/academic.txt
```

#### Criação de Thesaurus Personalizado
```vim
" Função para adicionar sinônimos
function! AddSynonyms(word, ...)
    let synonyms = join([a:word] + a:000, ',')
    execute '!echo "' . synonyms . '" >> ~/.vim/thesaurus/custom.txt'
    echo 'Sinônimos adicionados: ' . synonyms
endfunction

command! -nargs=+ Syn call AddSynonyms(<f-args>)

" Uso: :Syn fast quick rapid swift
```

### Spell Completion Inteligente (Ctrl+X Ctrl+S)

#### Configuração Multi-idioma
```vim
" Configuração de spell checking
set spell spelllang=pt_br,en
set spellfile=~/.vim/spell/custom.utf-8.add

" Completion que inclui sugestões de spell
set complete+=kspell

" Função para alternar idiomas
function! ToggleSpellLang()
    if &spelllang == 'pt_br,en'
        setlocal spelllang=en
        echo 'Spell: Inglês'
    else
        setlocal spelllang=pt_br,en
        echo 'Spell: Português + Inglês'
    endif
endfunction

nnoremap <leader>sl :call ToggleSpellLang()<CR>
```

#### Completion com Correção Automática
```vim
" Função para completion com correção inteligente
function! SmartSpellComplete()
    let word = expand('<cword>')
    let suggestions = spellsuggest(word, 5)
    
    if len(suggestions) > 0
        call complete(col('.') - len(word), suggestions)
    endif
    return ''
endfunction

inoremap <C-x><C-z> <C-r>=SmartSpellComplete()<CR>
```

### Line Completion Inteligente (Ctrl+X Ctrl+L)

#### Configuração Avançada
```vim
" Completion de linhas com contexto
function! ContextualLineComplete()
    let current_line = getline('.')
    let indent = matchstr(current_line, '^\s*')
    
    " Buscar linhas com mesmo indentamento
    let pattern = '^' . indent . '[^ \t]'
    let matches = []
    
    for lnum in range(1, line('$'))
        let line = getline(lnum)
        if line =~ pattern && line != current_line
            call add(matches, substitute(line, '^\s*', '', ''))
        endif
    endfor
    
    if len(matches) > 0
        call complete(col('.'), matches)
    endif
    return ''
endfunction

inoremap <C-x><C-x> <C-r>=ContextualLineComplete()<CR>
```

### Vim Command Completion (Ctrl+X Ctrl+V)

#### Funcionalidade Nativa
- Completion de comandos Vim
- Completion de funções built-in
- Completion de variáveis Vim
- Útil ao escrever scripts Vim

#### Exemplo de Uso
```vim
" Ao digitar em um script Vim:
echo g:my_var<Ctrl+X Ctrl+V>  " Completa variáveis globais
set number<Ctrl+X Ctrl+V>     " Completa opções do Vim
```

## Configuração Completa de Sources

### Ordem Otimizada de Completion
```vim
" Configuração otimizada do complete
set complete=.,w,b,u,t,i,kspell

" Explicação:
" . = buffer atual
" w = buffers em outras janelas
" b = outros buffers carregados
" u = buffers não carregados
" t = tags
" i = arquivos incluídos
" kspell = dicionário de spell
```

### Completion Context-Aware
```vim
" Completion baseado no contexto do arquivo
function! ContextCompletion()
    let line = getline('.')
    let col = col('.')
    
    " Diferentes estratégias baseadas no contexto
    if line =~ '#include\s*[<"]*$'
        " Completion de headers
        return "\<C-x>\<C-f>"
    elseif line =~ '\w\+($' || line =~ '\w\+\s*($'
        " Completion de função via tags
        return "\<C-x>\<C-]>"
    elseif &filetype == 'vim' && line =~ ':'
        " Completion de comandos Vim
        return "\<C-x>\<C-v>"
    else
        " Completion padrão
        return "\<C-n>"
    endif
endfunction

inoremap <expr> <Tab> ContextCompletion()
```

## Criando Portfólio de Dicionários Personalizados

### Estrutura de Diretórios
```bash
~/.vim/words/
├── default.txt          # Palavras gerais
├── programming.txt      # Termos de programação
├── c.txt               # Palavras específicas de C
├── python.txt          # Palavras específicas de Python
├── javascript.txt      # Termos JavaScript/web
├── portuguese.txt      # Vocabulário português técnico
└── domain-specific/    # Dicionários por domínio
    ├── ai-ml.txt      # Machine Learning
    ├── devops.txt     # DevOps/Infrastructure
    └── web-dev.txt    # Desenvolvimento web
```

### Configuração Automática por Tipo de Arquivo
```vim
" Auto-carregar dicionários por filetype
augroup DictionarySetup
    autocmd!
    " Dicionário geral sempre disponível
    autocmd FileType * setlocal dictionary+=~/.vim/words/default.txt
    autocmd FileType * setlocal dictionary+=~/.vim/words/programming.txt
    
    " Dicionários específicos por linguagem
    autocmd FileType c,cpp setlocal dictionary+=~/.vim/words/c.txt
    autocmd FileType python setlocal dictionary+=~/.vim/words/python.txt
    autocmd FileType javascript,typescript,html,css setlocal dictionary+=~/.vim/words/javascript.txt
    
    " Dicionários por domínio (manual)
    autocmd BufRead,BufNewFile */ai/* setlocal dictionary+=~/.vim/words/domain-specific/ai-ml.txt
    autocmd BufRead,BufNewFile */devops/* setlocal dictionary+=~/.vim/words/domain-specific/devops.txt
augroup END
```

### Criação de Dicionários Eficazes

#### 1. Formato e Estrutura
```bash
# ~/.vim/words/python.txt
# Palavras uma por linha, ordenadas alfabeticamente
__init__
__name__
__main__
asyncio
dataclass
enumerate
isinstance
lambda
```

#### 2. Extração Automática de Palavras
```bash
# Script para extrair palavras de projetos
#!/bin/bash
# extract-words.sh
find . -name "*.py" -exec cat {} \; | \
grep -oE '\b[a-zA-Z_][a-zA-Z0-9_]{3,}\b' | \
sort | uniq -c | sort -nr | \
awk '$1 > 2 {print $2}' > ~/.vim/words/python-extracted.txt
```

#### 3. Integração com Spell Checker
```vim
" Usar dicionários de spell como fonte de completion
set spell spelllang=pt_br,en
set complete+=kspell

" Função para adicionar palavra ao dicionário pessoal
function! AddToDictionary()
    let word = expand('<cword>')
    exec '!echo "' . word . '" >> ~/.vim/words/custom.txt'
    exec 'setlocal dictionary+=~/.vim/words/custom.txt'
    echo 'Palavra "' . word . '" adicionada ao dicionário'
endfunction

nnoremap <leader>da :call AddToDictionary()<CR>
```

### Melhores Práticas para Dicionários

#### 1. Manutenção e Atualização
- **Frequência**: Atualize dicionários mensalmente
- **Qualidade**: Mantenha apenas palavras de 3+ caracteres relevantes
- **Organização**: Use categorias claras e consistentes

#### 2. Performance
```vim
" Otimizar busca em dicionários grandes
set complete=.,w,b,u,t,i,kspell
set infercase           " Ajustar case baseado no que já foi digitado
set completeopt=menuone,longest,noselect
```

#### 3. Dicionários por Contexto
```vim
" Dicionários condicionais baseados no contexto
function! LoadContextDictionary()
    let filepath = expand('%:p')
    if filepath =~ '/api/'
        setlocal dictionary+=~/.vim/words/api-terms.txt
    elseif filepath =~ '/frontend/'
        setlocal dictionary+=~/.vim/words/frontend.txt
    elseif filepath =~ '/database/'
        setlocal dictionary+=~/.vim/words/database.txt
    endif
endfunction

autocmd BufRead * call LoadContextDictionary()
```

## Templates e Skeletons Profissionais

### Estrutura de Templates vsnip
```bash
~/.vim/vsnip/
├── global.json         # Templates globais
├── c.json             # Templates C
├── python.json        # Templates Python
├── javascript.json    # Templates JS
└── markdown.json      # Templates Markdown
```

### Exemplos de Templates Avançados

#### 1. Template de Função Python
```json
{
  "Python Function with Docstring": {
    "prefix": "def",
    "body": [
      "def ${1:function_name}(${2:args}) -> ${3:return_type}:",
      "    \"\"\"${4:Description}",
      "    ",
      "    Args:",
      "        ${2/([^,]+),?/${1:+ }: ${2:description}\n/g}",
      "    ",
      "    Returns:",
      "        ${3}: ${5:return_description}",
      "    \"\"\"",
      "    ${6:pass}"
    ],
    "description": "Função Python com docstring completa"
  }
}
```

#### 2. Template de Classe C++
```json
{
  "C++ Class": {
    "prefix": "class",
    "body": [
      "class ${1:ClassName} {",
      "private:",
      "    ${2:// Private members}",
      "",
      "public:",
      "    ${1:ClassName}(${3:});",
      "    ~${1:ClassName}();",
      "    ",
      "    ${4:// Public methods}",
      "};"
    ],
    "description": "Template básico de classe C++"
  }
}
```

#### 3. Template de API Endpoint
```json
{
  "Express Route": {
    "prefix": "route",
    "body": [
      "router.${1|get,post,put,delete|}('/${2:path}', async (req, res) => {",
      "    try {",
      "        ${3:// Implementation}",
      "        res.status(200).json({ success: true, data: ${4:result} });",
      "    } catch (error) {",
      "        res.status(500).json({ success: false, error: error.message });",
      "    }",
      "});"
    ],
    "description": "Template para rota Express.js"
  }
}
```

### Skeletons para Novos Arquivos

#### 1. Skeleton Python
```vim
" Skeleton para arquivos Python novos
autocmd BufNewFile *.py 0put =\"#!/usr/bin/env python3\"|$
autocmd BufNewFile *.py 0put =\"# -*- coding: utf-8 -*-\"|$
autocmd BufNewFile *.py 0put =\"\"|$
autocmd BufNewFile *.py 0put =\"\"\"${1:Module description}.\"|$
autocmd BufNewFile *.py 0put =\"\"|$
autocmd BufNewFile *.py 0put =\"Author: ${2:Your Name}\"|$
autocmd BufNewFile *.py 0put =\"Date: ${3:`date +%Y-%m-%d`}\"|$
autocmd BufNewFile *.py 0put =\"\"\"\"|$
```

#### 2. Skeleton README.md
```vim
function! NewReadmeTemplate()
    call append(0, [
        \ '# ' . fnamemodify(getcwd(), ':t'),
        \ '',
        \ '## Descrição',
        \ '',
        \ '## Instalação',
        \ '',
        \ '```bash',
        \ '# Comandos de instalação',
        \ '```',
        \ '',
        \ '## Uso',
        \ '',
        \ '## Contribuição',
        \ '',
        \ '## Licença'
        \ ])
endfunction

autocmd BufNewFile README.md call NewReadmeTemplate()
```

### Templates Inteligentes por Contexto

#### 1. Template Baseado em Diretório
```vim
function! SmartTemplate()
    let dir = expand('%:p:h:t')
    let filename = expand('%:t:r')
    
    if dir == 'tests'
        " Template para arquivos de teste
        call append(0, 'import unittest')
    elseif dir == 'models'
        " Template para modelos
        call append(0, 'from sqlalchemy import Column, Integer, String')
    elseif filename =~ 'config'
        " Template para configuração
        call append(0, '# Configuration file')
    endif
endfunction

autocmd BufNewFile *.py call SmartTemplate()
```

### Práticas de Manutenção de Templates

#### 1. Versionamento
- Manter templates em repositório Git separado
- Usar branches para diferentes versões/projetos
- Sincronizar regularmente entre máquinas

#### 2. Organização
```bash
# Estrutura recomendada
~/.vim/templates/
├── languages/
│   ├── python/
│   ├── javascript/
│   └── c/
├── frameworks/
│   ├── react/
│   ├── express/
│   └── django/
└── project-types/
    ├── cli-app/
    ├── web-api/
    └── library/
```

## Configuração de Performance

### Otimização de Completion
```vim
" Configurações para melhor performance
set completeopt=menuone,longest,noselect
set pumheight=15                    " Altura máxima do popup
set complete-=i                     " Remover include files se muito lento
set complete-=t                     " Remover tags se muito lento

" Timeout para completion
set updatetime=100
```

### Completion Assíncrono Simulado
```vim
" Para Vim 8+ com job support
function! AsyncComplete()
    if exists('*job_start')
        let job = job_start(['grep', '-r', expand('<cword>'), '.'], {
            \ 'out_cb': function('CompleteCallback')
            \ })
    endif
endfunction

function! CompleteCallback(channel, msg)
    " Processar resultado assíncrono
    echo 'Completion async: ' . a:msg
endfunction
```

## Troubleshooting e Debugging

### Debugging de Completion
```vim
" Verificar configurações de completion
:set complete?
:set completeopt?
:set omnifunc?
:set dictionary?
:set thesaurus?
:set tags?

" Testar completion sources individualmente
:echo tagfiles()              " Ver arquivos de tags
:echo &omnifunc               " Ver função omnifunc atual
:echo globpath(&rtp, 'autoload/*complete.vim')  " Ver completions disponíveis
```

### Diagnóstico de Performance
```vim
" Medir tempo de completion
function! ProfileCompletion()
    let start_time = reltime()
    execute "normal! \<C-n>"
    let end_time = reltime(start_time)
    echo 'Completion time: ' . reltimestr(end_time)
endfunction

command! ProfileComp call ProfileCompletion()
```

## Solução de Problemas

### Problemas Comuns
- **Sem omni completion**: Verifique se `omnifunc` está configurado para tipo de arquivo
- **Completion lento**: Reduza fontes de completion ou ajuste timing
- **Conflitos**: Use `inoremap` em vez de `imap` para mapeamentos de tecla
- **Dicionários não carregam**: Verifique caminhos com `:set dictionary?`
- **Templates não expandem**: Confirme se vsnip está ativo com `:echo vsnip#available(1)`
- **Tags não funcionam**: Verifique se ctags está instalado e tags foram gerados
- **Include completion falha**: Configurar `includeexpr` apropriadamente para o filetype

### Configurações de Fallback
```vim
" Fallback para completion quando omnifunc falha
function! CleverTab()
    if pumvisible()
        return "\<C-n>"
    elseif strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
        return "\<Tab>"
    elseif exists('&omnifunc') && &omnifunc != ''
        return "\<C-x>\<C-o>"
    else
        return "\<C-n>"
    endif
endfunction

inoremap <expr> <Tab> CleverTab()
```