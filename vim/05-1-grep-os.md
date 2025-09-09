# Guia completo de vimgrep e navegação quickfix para desenvolvimento avançado

O vimgrep é a ferramenta nativa do Vim para busca em múltiplos arquivos, integrada diretamente com o sistema quickfix para navegação eficiente de resultados. Este guia apresenta técnicas avançadas específicas para desenvolvimento de sistemas, kernel e assembly, com exemplos práticos testáveis.

## Vimgrep avançado: sintaxe e padrões complexos

### Sintaxe completa e flags

A sintaxe fundamental do vimgrep oferece flexibilidade através de modificadores e flags que controlam o comportamento da busca:

```vim
:vim[grep][!] /{pattern}/[g][j] {file} ...
:vim[grep][!] {pattern} {file} ...
```

O modificador **`!`** força o abandono de alterações no buffer atual, enquanto **`[g]`** encontra todas as ocorrências por linha (não apenas a primeira) e **`[j]`** previne o salto automático para o primeiro resultado. Para buscas recursivas em projetos grandes, combine esses flags:

```vim
" Busca todas ocorrências sem saltar
:vimgrep /\<TODO\>/gj **/*.c **/*.h

" Usando very magic mode para regex simplificado
:vimgrep /\v(function|class)\s+\w+/ **/*.py

" Case insensitive com palavra completa
:vimgrep /\c\<error\>/ **/*.log
```

### Modificadores e padrões avançados

O vimgrep suporta os modificadores de regex do Vim, oferecendo controle fino sobre o comportamento de busca. O modo **very magic** (`\v`) torna a sintaxe regex mais próxima do padrão Perl, enquanto **very nomagic** (`\V`) trata quase todos os caracteres como literais:

```vim
" Lookahead negativo - encontrar 'index' não seguido de '.php'
:vimgrep /index\(\.php\)\@!/ **/*.log

" Lookbehind positivo - 'Date' precedido por 'Start'
:vimgrep /\(Start\)\@<=Date/ **/*.txt

" Padrões multilinhas com \_. (qualquer caractere incluindo newline)
:vimgrep /function.*\_.*{/ **/*.c

" Delimitadores alternativos para evitar escape
:vimgrep #/home/user/# **/*.txt
```

### Performance comparada com ferramentas externas

Para projetos grandes, entender as características de performance é crucial. O vimgrep carrega arquivos na memória do Vim, oferecendo excelente suporte Unicode mas velocidade inferior a ferramentas externas otimizadas:

```vim
" Configuração para usar ripgrep quando disponível
if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --follow
    set grepformat=%f:%l:%c:%m
elseif executable('ag')
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
endif

" Comando híbrido para escolher melhor ferramenta
command! -nargs=+ Search execute system('which rg') != '' ? 
    \ 'grep <args>' : 'vimgrep /<args>/gj **/*'
```

**Benchmarks típicos** mostram ripgrep 3-10x mais rápido que vimgrep em bases grandes, mas vimgrep mantém vantagem em padrões complexos específicos do Vim e consistência com o comando `/` de busca.

## Sistema quickfix e location lists

### Comandos essenciais de navegação

O sistema quickfix oferece navegação estruturada através dos resultados de busca. Os comandos fundamentais permitem movimento eficiente:

```vim
:copen [height]     " Abre janela quickfix
:cclose             " Fecha janela quickfix
:cwindow            " Abre apenas se houver resultados
:cnext              " Próximo resultado
:cprev              " Resultado anterior
:cfirst             " Primeiro resultado
:clast              " Último resultado
:cc [n]             " Vai para resultado número n
:cnfile             " Primeiro erro no próximo arquivo
:cpfile             " Último erro no arquivo anterior
```

Para manter histórico de buscas, o Vim preserva até 10 listas quickfix:

```vim
:colder [count]     " Lista quickfix anterior
:cnewer [count]     " Lista quickfix mais recente
:chistory           " Visualiza histórico completo
```

### Location lists vs quickfix lists

Location lists são versões locais por janela do quickfix, ideais para operações isoladas:

```vim
" Location list para busca no arquivo atual
:lvimgrep /pattern/g %
:lopen              " Abre location list da janela atual
:lnext              " Navega apenas nesta janela
:lclose             " Fecha sem afetar outras janelas

" Quickfix para busca global no projeto
:vimgrep /pattern/g **/*.c
:copen              " Visível em todas as janelas
```

**Quando usar cada tipo:**
- **Location lists**: linting de arquivo único, buscas localizadas, múltiplas buscas simultâneas
- **Quickfix**: erros de compilação, buscas em projeto, operações globais

### Customização avançada da janela quickfix

Configure comportamento e aparência para workflows específicos:

```vim
" Auto-ajuste de altura baseado em conteúdo
augroup quickfix_config
    autocmd!
    autocmd FileType qf call AdjustWindowHeight(3, 15)
    " Sempre posiciona quickfix na parte inferior
    autocmd FileType qf wincmd J
augroup END

function! AdjustWindowHeight(minheight, maxheight)
    exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

" Mapeamentos customizados dentro do quickfix
function! QuickfixMappings()
    " Abre em split horizontal
    nnoremap <buffer> s <C-w><CR><C-w>K
    " Abre em nova aba
    nnoremap <buffer> t <C-w><CR><C-w>T
    " Preview sem sair do quickfix
    nnoremap <buffer> p <CR><C-w>p
endfunction

autocmd FileType qf call QuickfixMappings()
```

### Operações em lote com :cdo e :cfdo

Execute comandos em todos os resultados ou arquivos:

```vim
" Substituir em todas as ocorrências encontradas
:vimgrep /old_function/g **/*.c
:cdo s/old_function/new_function/g | update

" Operar por arquivo (mais eficiente para múltiplas mudanças)
:cfdo %s/old_pattern/new_pattern/g | update

" Adicionar comentário em todas as linhas com TODO
:vimgrep /TODO/g **/*.py
:cdo normal I# REVIEWED: 
```

## Workflows avançados para desenvolvimento

### Busca de símbolos em código C e Assembly

Para desenvolvimento de sistemas, padrões específicos facilitam navegação em código complexo:

```vim
" Definições de função C (incluindo K&R style)
:vimgrep /^\w\+\s\+\*?\w\+\s*(/g **/*.c

" System calls no kernel Linux
:vimgrep /SYSCALL_DEFINE[0-9]\(/g **/*.c

" Labels em assembly
:vimgrep /^\s*\w\+\s*:/g **/*.s **/*.S

" Instruções específicas (interrupts x86)
:vimgrep /\s*int\s\+\$0x80/g **/*.s

" Macros do kernel
:vimgrep /#define\s\+CONFIG_\w\+/g **/*.h
```

### Análise de dependências e call graphs

Construa visualizações de dependências usando vimgrep iterativo:

```vim
function! BuildCallGraph(func_name)
    " Encontra definição da função
    execute 'vimgrep /^\w\+\s\+\*?\<' . a:func_name . '\>\s*(/g **/*.c'
    
    " Salva localização
    let func_location = getqflist()[0]
    
    " Busca todas as chamadas para esta função
    execute 'vimgrep /\<' . a:func_name . '\>\s*(/g **/*.c'
    
    " Filtra para remover a própria definição
    let calls = filter(getqflist(), 'v:val.lnum != func_location.lnum')
    
    " Exibe call graph
    for call in calls
        echo printf("%s:%d calls %s", 
            \ fnamemodify(bufname(call.bufnr), ':t'),
            \ call.lnum, a:func_name)
    endfor
endfunction

" Uso: :call BuildCallGraph('malloc')
```

### Auditoria de segurança com padrões

Identifique vulnerabilidades comuns através de padrões de busca:

```vim
" Buffer overflows - funções perigosas
:vimgrep /\<\(strcpy\|strcat\|sprintf\|gets\)\s*(/g **/*.c

" Format string vulnerabilities
:vimgrep /\<printf\s*(\s*[^"]/g **/*.c

" Integer overflows em alocações
:vimgrep /malloc\s*(\s*\w\+\s*\*\s*\w\+/g **/*.c

" Race conditions - globals sem proteção
:vimgrep /^\(static\s\+\)\@!\w\+\s\+\*\?g_\w\+/g **/*.c

" Memory leaks - malloc sem free correspondente
function! FindMemoryLeaks()
    vimgrep /\<malloc\|calloc\|realloc\>/g **/*.c
    let allocs = map(getqflist(), 'v:val.text')
    
    vimgrep /\<free\>/g **/*.c
    let frees = map(getqflist(), 'v:val.text')
    
    echo "Allocations: " . len(allocs) . " | Frees: " . len(frees)
endfunction
```

### Refactoring com quickfix

Use o poder do quickfix para refactoring seguro e controlado:

```vim
" Renomeação inteligente com confirmação
function! SmartRename(old_name, new_name)
    " Backup antes de mudanças
    execute '!git add -A && git commit -m "Pre-refactor backup"'
    
    " Encontra todos os usos
    execute 'vimgrep /\<' . a:old_name . '\>/g **/*.c **/*.h'
    
    " Abre quickfix para revisão
    copen
    
    " Permite edição manual do quickfix se necessário
    setlocal modifiable
    
    " Comando para aplicar mudanças
    command! ApplyRename cdo s/\<old_name\>/new_name/gc | update
    
    echo "Review matches, edit if needed, then :ApplyRename"
endfunction
```

## Técnicas específicas para desenvolvimento de sistemas

### Navegação em código kernel

Configure mapeamentos específicos para desenvolvimento kernel:

```vim
" Mapeamentos para kernel Linux
augroup kernel_development
    autocmd!
    " Configurações de estilo do kernel
    autocmd BufRead */linux/* setlocal ts=8 sw=8 noet
    
    " Navegação rápida
    autocmd BufRead *.c nnoremap <buffer> <Leader>kd 
        \ :vimgrep /^\s*static\s\+\w\+\s\+\*\?\<\w\+_driver\>/g %<CR>
    
    autocmd BufRead *.c nnoremap <buffer> <Leader>ki 
        \ :vimgrep /^\s*static\s\+int\s\+__init\>/g %<CR>
augroup END

" Busca de subsistemas específicos
command! -nargs=1 KernelSubsystem vimgrep /\<<args>\>_\w\+/g **/*.c
" Uso: :KernelSubsystem net   (encontra net_*, netdev_*, etc)
```

### Debug com integração de ferramentas

Integre vimgrep com ferramentas de análise:

```vim
" Integração com addr2line para debugging
function! ResolveAddresses()
    " Busca endereços no formato 0xHEX
    vimgrep /0x[0-9a-fA-F]\{8,16\}/g %
    
    for item in getqflist()
        let addr = matchstr(item.text, '0x[0-9a-fA-F]\+')
        let cmd = 'addr2line -e vmlinux ' . addr
        let result = system(cmd)
        echo addr . ': ' . result
    endfor
endfunction

" Parse de kernel panic
function! ParseKernelPanic()
    " Busca padrões de panic
    vimgrep /Call Trace:\|RIP:\|Oops:/g /var/log/kern.log
    copen
    
    " Extrai símbolos mencionados
    vimgrep /\[\<\w\+\>\+0x[0-9a-f]\+/g /var/log/kern.log
endfunction
```

## Configurações e otimizações

### Configuração .vimrc otimizada

Configure seu ambiente para máxima eficiência:

```vim
" === Performance ===
set wildignore+=*.o,*.ko,*.mod.c,*.order,*.symvers
set wildignore+=*/build/*,*/output/*
set synmaxcol=200           " Limita highlighting em linhas longas
set lazyredraw              " Não redesenha durante macros

" === Quickfix automático ===
augroup quickfix_autocmds
    autocmd!
    " Auto-abre quickfix após grep/make
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
    
    " Fecha quickfix ao ser última janela
    autocmd WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
augroup END

" === Mapeamentos essenciais ===
" Navegação sem abrir quickfix
nnoremap [q :cprev<CR>zz
nnoremap ]q :cnext<CR>zz
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>

" Busca rápida da palavra sob cursor
nnoremap <Leader>* :execute "vimgrep /\\<" . expand("<cword>") . "\\>/gj **/*." . expand('%:e')<CR>:copen<CR>

" Toggle quickfix
nnoremap <F8> :call ToggleQuickfix()<CR>
function! ToggleQuickfix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        copen
    else
        cclose
    endif
endfunction
```

### Integração com ferramentas externas

Configure integração transparente com ferramentas de desenvolvimento:

```vim
" === Compilação com erro parsing ===
" GCC/Clang
set errorformat=%f:%l:%c:\ %t%*[^:]:\ %m
" Make
set errorformat+=%f:%l:\ %m
" Valgrind
set errorformat+=%E%f:%l:\ %m,%-Z%p^,%+C\ \ %m

" === Integração com ctags ===
set tags=./tags,tags;$HOME
nnoremap <Leader>tr :!ctags -R --c-kinds=+p --fields=+S .<CR>

" === Git grep ===
command! -nargs=+ Ggrep execute 'silent grep! <args> `git ls-files`' | copen

" === Integração com ripgrep para projetos grandes ===
if executable('rg')
    function! RgWithPreview(args)
        let cmd = 'rg --vimgrep --smart-case ' . a:args
        let results = systemlist(cmd)
        
        let qflist = []
        for line in results
            let parts = matchlist(line, '\([^:]\+\):\(\d\+\):\(\d\+\):\(.*\)')
            if len(parts) > 4
                call add(qflist, {
                    \ 'filename': parts[1],
                    \ 'lnum': parts[2],
                    \ 'col': parts[3],
                    \ 'text': parts[4]
                \ })
            endif
        endfor
        
        call setqflist(qflist)
        copen
    endfunction
    
    command! -nargs=+ Rg call RgWithPreview(<q-args>)
endif
```

### Performance tuning para projetos grandes

Otimize para bases de código extensas:

```vim
" Limita escopo de busca por tipo de arquivo
command! -nargs=+ GrepC execute 'vimgrep /<args>/gj **/*.c **/*.h' | copen
command! -nargs=+ GrepAsm execute 'vimgrep /<args>/gj **/*.s **/*.S' | copen
command! -nargs=+ GrepMake execute 'vimgrep /<args>/gj **/Makefile **/*.mk' | copen

" Cache de resultados frequentes
let g:search_cache = {}
function! CachedSearch(pattern)
    if has_key(g:search_cache, a:pattern)
        call setqflist(g:search_cache[a:pattern])
        copen
        echo "Loaded from cache"
    else
        execute 'vimgrep /' . a:pattern . '/gj **/*'
        let g:search_cache[a:pattern] = getqflist()
    endif
endfunction

" Busca incremental com limite
function! IncrementalSearch(pattern, max_files)
    let files = split(glob('**/*.c'), '\n')[:a:max_files]
    execute 'vimgrep /' . a:pattern . '/gj ' . join(files)
    
    if len(getqflist()) < 10
        echo "Expanding search..."
        execute 'vimgrepadd /' . a:pattern . '/gj **/*.c'
    endif
endfunction
```

## Exemplos práticos testáveis

### Workflow completo de refactoring

```vim
" 1. Identificar função para renomear
:vimgrep /\<process_packet\>/g **/*.c **/*.h
:copen

" 2. Verificar contexto de uso
:cdo normal zO  " Expande folds para ver contexto

" 3. Aplicar mudança com confirmação
:cfdo %s/\<process_packet\>/handle_packet/gc | update

" 4. Verificar mudanças
:vimgrep /\<handle_packet\>/g **/*.c **/*.h

" 5. Buscar possíveis referências em comentários
:vimgrep /process_packet/g **/*.c **/*.h
```

### Análise de segurança em projeto

```vim
" Script completo de auditoria
function! SecurityAudit()
    let issues = []
    
    " Busca funções inseguras
    vimgrep /\<gets\|strcpy\|strcat\|sprintf\>/g **/*.c
    call add(issues, "Unsafe functions: " . len(getqflist()))
    
    " Format strings suspeitos
    vimgrep /printf\s*(\s*\w\+\s*)/g **/*.c
    call add(issues, "Format string issues: " . len(getqflist()))
    
    " Comparações com signed/unsigned
    vimgrep /if\s*(\s*\w\+\s*[<>]=\?\s*0\s*)/g **/*.c
    call add(issues, "Potential signed issues: " . len(getqflist()))
    
    " Gera relatório
    new SecurityReport.txt
    call append(0, issues)
    write
endfunction

:call SecurityAudit()
```

Este guia fornece uma base sólida para uso avançado de vimgrep e navegação quickfix em ambientes de desenvolvimento complexos, com foco especial em desenvolvimento de sistemas, kernel e assembly.
# 📝 Vim Vanilla para OSR2: Guia Completo de Descoberta e Produtividade

## 🎯 Integração com o Setup OSR2

Esta seção complementa o **Setup Completo Arch Linux Minimal no WSL - Guia Detalhado OSR2** com foco específico no domínio do Vim vanilla para desenvolvimento de sistemas operacionais e análise binária com Radare2.

### Conexão com o Workflow OSR2
O Vim no contexto OSR2 não é apenas um editor - é o centro de comando para:
- **Desenvolvimento de kernels** (C + Assembly)
- **Scripts de automação** (Bash + Makefiles)
- **Análise de código** (integração com r2, gdb)
- **Documentação técnica** (Markdown + comentários)

## 🔍 Sistema de Descoberta do Vim: Wildcards e Help

### Modificadores de Pesquisa Avançados

O Vim oferece um sistema robusto de descoberta através de wildcards e padrões, similar ao que exploramos com o Pacman. O Vim possui wildcards expandidos que funcionam como padrões de expansão, permitindo pesquisar e completar comandos, opções e arquivos de forma inteligente.

#### Wildcards no Comando `:set`
```vim
" Descoberta de opções relacionadas
:set *indent*<Tab>    " Encontra: autoindent, smartindent, cindent, etc.
:set *tab*<Tab>       " Encontra: tabstop, softtabstop, tabpagemax, etc.
:set *search*<Tab>    " Encontra: hlsearch, incsearch, searchpair, etc.
:set wild*<Tab>       " Encontra: wildchar, wildcharm, wildmenu, wildmode

" Padrões mais específicos
:set *menu<Tab>       " Similar ao pacman -S *menu<Tab>
:set completion*<Tab> " Opções de autocompletar
:set fold*<Tab>       " Todas as opções de folding
```

#### Wildcards para Arquivos
```vim
" Abrir arquivos com padrões
:e *.c<Tab>           " Todos os arquivos .c
:e kernel*<Tab>       " Todos começando com "kernel"
:e **/*.h<Tab>        " Busca recursiva por headers

" Dividir janela com wildcard
:split src/*.c<Tab>   " Abre arquivo .c em split
:vsplit **/*main*<Tab>" Busca recursiva por arquivos com "main"
```

### Sistema de Help Integrado

O sistema de help do Vim organiza sua documentação em uma estrutura hierárquica acessível através do comando :help, onde cada tópico possui uma tag formatada entre asteriscos na documentação.

#### Navegação por Tags
```vim
" Comandos básicos de help
:help                 " Help principal
:help help            " Como usar o sistema de help
:help quickref        " Referência rápida
:help index           " Índice alfabético de todos os comandos

" Help por contexto (prefixos)
:help i_CTRL-W        " Insert mode: Ctrl+W
:help v_u             " Visual mode: comando u
:help c_CTRL-R        " Command mode: Ctrl+R
:help n_dd            " Normal mode: dd

" Help para opções (aspas simples obrigatórias)
:help 'tabstop'       " Documentação da opção tabstop
:help 'wildmenu'      " Documentação do wildmenu
:help 'syntax'        " Documentação de syntax highlighting
```

#### Busca na Documentação
```vim
" Busca com wildcards no help
:help *fold*<Tab>     " Todas as documentações sobre folding
:help *window*<Tab>   " Documentações sobre janelas
:help *completion*<Tab>" Documentações sobre autocompletar

" Busca full-text na documentação
:helpgrep \<window\>  " Busca exata por "window"
:helpgrep indent      " Busca por "indent" em toda documentação
:helpgrep "normal mode" " Busca por frase específica
```

### Técnicas de Descoberta Prática

#### Exploração Interativa de Comandos
```vim
" Tab completion inteligente
:col<Tab>             " Mostra: colorscheme, colo, etc.
:set<Space><Ctrl-D>   " Lista TODAS as opções disponíveis
:e<Space><Ctrl-D>     " Lista arquivos no diretório

" Descoberta por categoria
:help options         " Todas as opções categorizadas
:help option-list     " Lista alfabética completa
:help usr_toc.txt     " Manual do usuário por tópicos
```

## 🔧 Configuração .vimrc OSR2 Baseada em Pesquisa

### Fundamentação nas Fontes Oficiais

A configuração do Vim deve priorizar funcionalidades nativas que não dependam de plugins externos, mantendo compatibilidade com qualquer ambiente de desenvolvimento.

#### Seção 1: Descoberta e Navegação
```vim
" ===== DESCOBERTA E HELP SYSTEM =====
" Baseado em: :help 'wildmenu', :help completion

set wildmenu                    " Menu visual para comandos
set wildmode=longest:full,full  " Completar até comum + lista
set wildchar=<Tab>             " Tab para completion (padrão)
set wildignore=*.o,*.obj,*.exe " Ignorar binários em completion

" Configuração de help otimizada para OSR2
set helplang=en                " Help em inglês (mais completo)
set keywordprg=:help           " K abre help do Vim para palavra sob cursor

" Exemplo de uso:
" - :set wild<Tab> lista wildmenu, wildmode, etc.
" - :help wild<Tab> lista documentação sobre wildcards
" - K sobre 'tabstop' abre :help 'tabstop'
```

#### Seção 2: Busca Avançada para Desenvolvimento
```vim
" ===== BUSCA INTELIGENTE PARA CÓDIGO =====
" Baseado em: :help search-pattern, :help 'hlsearch'

set hlsearch                   " Highlight resultados busca
set incsearch                  " Busca incremental (tempo real)
set ignorecase                 " Busca case-insensitive por padrão
set smartcase                  " Se usar maiúscula, fica case-sensitive
set wrapscan                   " Busca circular (fim -> início)

" Padrões úteis para OSR2:
" /\<main\>     - busca exata por função main
" /KERNEL_.*    - busca por constantes que começam com KERNEL_
" /^#include    - busca por includes no início da linha
" /TODO\|FIXME  - busca por comentários de desenvolvimento
```

#### Seção 3: Integração com Ferramentas OSR2

```vim
" ===== INTEGRAÇÃO RADARE2 + GDB + QEMU =====
" Baseado em workflow real de desenvolvimento de OS

" MAPEAMENTOS PARA ANÁLISE BINÁRIA
nnoremap <F11> :!r2 %<<CR>
" 📖 TÓPICO: Acesso direto ao Radare2 para análise binária
" 🎯 Por que no OSR2: Ciclo desenvolvimento→análise é constante no OS dev
"    F11 abre o executável compilado diretamente no r2 sem sair do vim
" 💡 Exemplo prático: Editando kernel.c, compila com F9, F11 abre kernel no r2
"    permite ver assembly gerado e comparar com código C
" ⚡ Impacto: Análise binária integrada - não precisa lembrar nomes de arquivos
" 🔧 Funciona com: %< (nome arquivo sem extensão) expandido pelo vim
" 📚 Referência: :help filename-modifiers, radare2 book
" 🎯 Caso de uso OSR2: Debug de bootloader - ver bytes exatos gerados

nnoremap <F12> :!r2 -A %<<CR>
" 📖 TÓPICO: Análise automática completa com Radare2
" 🎯 Por que no OSR2: -A flag executa análise completa (aa, aaa, functions)
"    automatiza workflow: abrir→analisar→explorar
" 💡 Exemplo prático: F12 em kernel abre r2 com funções já detectadas
"    comando afl mostra funções imediatamente sem análise manual
" ⚡ Impacto: Análise profunda automática - economia de 5-10 comandos r2
" 🔧 Flag -A: equivale a aa + outros comandos de análise profunda
" 📚 Referência: r2 -h, radare2 analysis commands
" 🎯 Caso de uso OSR2: Análise de malware/rootkits com detecção automática

" MAPEAMENTOS PARA DEBUGGING
nnoremap <leader>gdb :!gdb %<<CR>
" 📖 TÓPICO: Debugging integrado com GDB
" 🎯 Por que no OSR2: Kernel debugging é crítico - segfaults, memory corruption
"    \gdb (leader+gdb) abre debugger sem sair do contexto de edição
" 💡 Exemplo prático: Crash em kernel.c linha 150, \gdb abre com symbols loaded
"    bt mostra stack trace no contexto do código que estava editando
" ⚡ Impacto: Debug cycle mais rápido - context switch mínimo
" 🔧 Leader key: \ por padrão, pode customizar com let mapleader=","
" 📚 Referência: :help <leader>, gdb manual
" 🎯 Caso de uso OSR2: Debug de page fault handlers com breakpoints

nnoremap <leader>objdump :!objdump -d %< \| less<CR>
" 📖 TÓPICO: Disassembly rápido com objdump
" 🎯 Por que no OSR2: Alternativa ao r2 para análise rápida de assembly
"    objdump -d mostra disassembly limpo, less permite navegação
" 💡 Exemplo prático: \objdump mostra assembly do kernel.c compilado
"    compara código C original com assembly gerado pelo compilador
" ⚡ Impacto: Análise assembly sem overhead do r2 - verificação rápida
" 🔧 Pipe |: redireciona output para less (paginação)
" 📚 Referência: man objdump, :help :!
" 🎯 Caso de uso OSR2: Verificar otimizações do gcc em funções críticas

" COMPILAÇÃO COM FLAGS ESPECÍFICAS PARA ANÁLISE
autocmd FileType c nnoremap <F9> :w<CR>:!gcc % -o %< -g -no-pie -static<CR>
" 📖 TÓPICO: Compilação otimizada para análise binária
" 🎯 Por que no OSR2: Flags específicas facilitam debug e análise reversa
"    Cada flag tem propósito específico para ferramentas (gdb, r2, objdump)
" 💡 Exemplo prático: F9 compila kernel.c com symbols + layout previsível
"    permite debugging com line numbers e análise r2 mais clara
" ⚡ Impacto: Binários ideais para aprendizado - sem otimizações que confundem
" 🔧 Flags explicadas:
"    -g: debug symbols para GDB (line numbers, variable names)
"    -no-pie: desabilita PIE (Position Independent Executable) - endereços fixos
"    -static: linking estático - todas dependências no binário
" 📚 Referência: man gcc, :help autocmd
" 🎯 Caso de uso OSR2: Bootloader com endereços absolutos previsíveis

autocmd FileType c nnoremap <F10> :!./%<<CR>
" 📖 TÓPICO: Execução imediata do binário compilado
" 🎯 Por que no OSR2: Test cycle - compilar→executar→observar behavior
"    F10 roda executável na mesma sessão terminal
" 💡 Exemplo prático: Kernel test program, F10 mostra output/crashes imediatos
"    feedback instantâneo sobre functionality
" ⚡ Impacto: Ciclo desenvolvimento ultra-rápido - compile/test em 2 teclas
" 🔧 ./%<: executa arquivo com mesmo nome base do código fonte
" 📚 Referência: :help filename-modifiers
" 🎯 Caso de uso OSR2: Test de system calls, memory allocation routines

" INTEGRAÇÃO COM QEMU PARA KERNEL TESTING
autocmd FileType asm nnoremap <F10> :!qemu-system-i386 -kernel %< -nographic<CR>
" 📖 TÓPICO: Boot direto de kernel/bootloader em QEMU
" 🎯 Por que no OSR2: Kernels não rodam no host OS - precisam emulação
"    F10 em .asm boot direto no QEMU sem setup manual
" 💡 Exemplo prático: bootloader.asm compilado, F10 boot completo no QEMU
"    ve behavior real de boot sequence
" ⚡ Impacto: Testing real de kernel code - environment isolado
" 🔧 Flags QEMU:
"    -kernel: boot direto do arquivo (pula bootloader)
"    -nographic: output no terminal (não GUI)
" 📚 Referência: qemu documentation, man qemu-system-i386
" 🎯 Caso de uso OSR2: Test de interrupt handlers, memory management

" ANÁLISE HEXADECIMAL RÁPIDA
nnoremap <leader>hex :!hexdump -C %< \| head -20<CR>
" 📖 TÓPICO: Visualização hexadecimal de binários
" 🎯 Por que no OSR2: Bootloaders têm formato binário específico - MBR signature, etc.
"    \hex mostra primeiros 20 linhas de hex dump para verificação
" 💡 Exemplo prático: bootloader deve terminar com 55 AA (boot signature)
"    hexdump mostra se signature está correta no offset 510-511
" ⚡ Impacto: Validação rápida de formato binário sem ferramentas externas
" 🔧 hexdump -C: formato canonical (offset + hex + ASCII)
" 📚 Referência: man hexdump
" 🎯 Caso de uso OSR2: Verificar magic numbers, estruturas de arquivo
```

### Configuração de Tipos de Arquivo OSR2

#### Assembly x86/x86_64
```vim
" ===== ASSEMBLY CONFIGURATION =====
" Baseado em: Intel Assembly conventions, NASM documentation

autocmd FileType asm,nasm setlocal tabstop=8 shiftwidth=8 noexpandtab
autocmd FileType asm,nasm setlocal commentstring=;\ %s
autocmd FileType asm,nasm setlocal textwidth=80

" Mapeamentos específicos para assembly
autocmd FileType asm,nasm nnoremap <buffer> <F9> :w<CR>:!nasm -f elf64 % -o %<.o<CR>
autocmd FileType asm,nasm nnoremap <buffer> <F10> :!ld %<.o -o %<<CR>
autocmd FileType asm,nasm nnoremap <buffer> <F11> :!r2 %<<CR>

" Snippets inline para instruções comuns
autocmd FileType asm,nasm inoremap <buffer> mova mov eax,
autocmd FileType asm,nasm inoremap <buffer> movb mov ebx,
```

#### Makefiles e Build Scripts
```vim
" ===== MAKEFILE CONFIGURATION =====
" CRÍTICO: Make é sensível a tabs vs espaços

autocmd FileType make setlocal tabstop=8 shiftwidth=8 noexpandtab
autocmd FileType make setlocal listchars=tab:>-,trail:~
autocmd FileType make setlocal list  " Mostra tabs visualmente

" Validação de Makefile
autocmd FileType make nnoremap <buffer> <F9> :w<CR>:!make -n<CR>  " Dry run
autocmd FileType make nnoremap <buffer> <F10> :w<CR>:!make<CR>    " Build real
```

## 🚀 Workflows de Produtividade OSR2

### Workflow 1: Desenvolvimento de Kernel

#### Estrutura de Projeto Típica
```
kernel/
├── boot/
│   ├── boot.asm        " Bootloader assembly
│   └── boot_utils.c    " Utilitários de boot
├── kernel/
│   ├── main.c          " Entry point kernel
│   ├── memory.c        " Gerenciamento memória
│   └── interrupts.asm  " Handlers de interrupção
├── lib/
│   └── string.c        " Biblioteca padrão mínima
└── Makefile           " Build system
```

#### Comandos Vim para Navegação Eficiente
```vim
" ===== NAVEGAÇÃO DE PROJETO =====

" Abrir múltiplos arquivos relacionados
:args boot/*.asm kernel/*.c lib/*.c    " Carrega todos os arquivos relevantes
:next                                  " Próximo arquivo na lista
:prev                                  " Arquivo anterior

" Divisão de tela para comparação
:vsplit boot/boot.asm     " Vertical split com bootloader
:split kernel/main.c      " Horizontal split com kernel main

" Busca em múltiplos arquivos
:vimgrep /setup_paging/g **/*.c       " Busca função em todos .c
:copen                                " Abre lista de resultados
:cnext                                " Próximo resultado
```

### Workflow 2: Análise com Radare2 Integrada

#### Ciclo Desenvolvimento -> Análise
```vim
" ===== DESENVOLVIMENTO + ANÁLISE INTEGRADA =====

" 1. Editar código
vim kernel.c

" 2. No vim: compilar otimizado para análise
<F9>  " Compila com flags -g -no-pie -static

" 3. Análise rápida sem sair do vim
<F11> " Abre no r2 em nova sessão terminal

" 4. Análise avançada com comandos r2 específicos
:!r2 -c 'aa; afl; pdf @ main' %<   " Análise + lista funções + disasm main
```

#### Integração com Scripts de Análise
```vim
" Script vim para análise automatizada
function! AnalyzeExecutable()
    write
    let exe_name = expand('%:r')
    execute '!gcc % -o ' . exe_name . ' -g -no-pie -static'
    execute '!r2 -c "aa; afl; s main; pdf" ' . exe_name . ' > ' . exe_name . '.r2'
    execute 'split ' . exe_name . '.r2'
endfunction

nnoremap <leader>analyze :call AnalyzeExecutable()<CR>
```

## 📚 Comandos de Referência Rápida OSR2

### Descoberta e Help
```vim
" WILDCARDS E DESCOBERTA
:set *search*<Tab>        " Opções de busca
:help *fold*<Tab>         " Docs sobre folding
:e **/*kernel*<Tab>       " Busca recursiva arquivos

" HELP SYSTEM
:help quickref            " Referência rápida completa
:help usr_toc             " Manual usuário por tópicos
:helpgrep pattern         " Busca full-text na documentação
:help i_CTRL-            " Help insert mode Ctrl+qualquercoisa
```

### Navegação de Código
```vim
" TAGS E SÍMBOLOS
CTRL-]                   " Vai para definição (se tags disponível)
CTRL-T                   " Volta da definição
gd                       " Vai para declaração local da variável
gD                       " Vai para declaração global da variável
*                        " Busca próxima ocorrência da palavra sob cursor
#                        " Busca ocorrência anterior da palavra sob cursor
```

### Análise e Debug
```vim
" INTEGRAÇÃO FERRAMENTAS
:!gcc % -g -o %<         " Compilar com debug info
:!objdump -d %< | less   " Disassembly em pager
:!gdb %<                 " Debug com GDB
:!r2 -A %<               " Análise completa r2
:!hexdump -C %< | head   " Análise hexadecimal
```

## 🔍 Recursos de Busca Avançada

### Padrões de Busca para C/Assembly

O Vim suporta regex avançado que pode ser usado para encontrar padrões específicos em código:

```vim
" PADRÕES ÚTEIS PARA OS DEVELOPMENT
/^#include.*<.*>$        " Headers do sistema
/^#define\s\+[A-Z_]\+    " Constantes/macros
/^\s*void\s\+\w\+(       " Declarações de função void
/\<0x[0-9a-fA-F]\+\>     " Números hexadecimais
/TODO\|FIXME\|XXX\|HACK  " Comentários de desenvolvimento

" ASSEMBLY PATTERNS
/^\s*\w\+:$              " Labels assembly
/mov\s\+e[a-z]x          " Instruções mov para registradores 32-bit
/int\s\+0x\w\+           " Interrupções de sistema
```

### Busca em Múltiplos Arquivos
```vim
" VIMGREP PARA PROJETOS OSR2
:vimgrep /setup_paging/g **/*.c        " Busca função em projeto C
:vimgrep /section\.text/g **/*.asm     " Busca seções em assembly
:vimgrep /KERNEL_/g **/*.{c,h}         " Busca constantes kernel
:vimgrep /TODO/g **/*                  " Busca TODOs em todo projeto

" NAVEGAÇÃO DOS RESULTADOS
:copen                   " Abre quickfix window
:cclose                  " Fecha quickfix window
:cnext                   " Próximo resultado
:cprev                   " Resultado anterior
:cfirst                  " Primeiro resultado
:clast                   " Último resultado
```

## 🎓 Referências e Fontes

### Documentação Oficial Vim
- **Vim Official Documentation**: `:help user-manual` - Manual completo do usuário
- **Vim Help System**: `:help helphelp` - Como usar efetivamente o sistema de help
- **Vim Options**: `:help option-list` - Lista completa de todas as opções

### Recursos Online Específicos
- **Vim Tips Wiki**: Coleção comunitária de dicas e configurações avançadas
- **Vim Adventures**: Tutorial interativo para domínio dos comandos
- **Practical Vim by Drew Neil**: Livro focado em workflows reais

### Integração com Ferramentas OSR2
- **Radare2 Book**: `https://book.rada.re/` - Documentação oficial r2
- **Intel Architecture Manual**: Referência para assembly x86/x86_64
- **Linux Kernel Coding Style**: Guidelines para código de kernel
- **GNU Make Manual**: Para automação de build eficiente

### Configurações Avançadas da Comunidade
- **GitHub vim-configs**: Repositórios com configurações específicas para desenvolvimento
- **Stack Overflow vim tag**: Soluções para problemas específicos
- **Reddit r/vim**: Discussões sobre workflows e produtividade

## 🔧 Scripts de Automação Vim

### Script de Setup Automático
```bash
#!/bin/bash
# setup-vim-osr2.sh - Configuração automática Vim para OSR2

echo "🔧 Configurando Vim para OSR2..."

# Backup da configuração existente
if [ -f ~/.vimrc ]; then
    cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup criado da configuração existente"
fi

# Criar diretórios vim necessários
mkdir -p ~/.vim/{backup,swap,undo}

# Aplicar configuração OSR2
cat > ~/.vimrc << 'EOF'
" Configuração Vim OSR2 - Gerada automaticamente
" Para modificações, edite este arquivo ou o script gerador

" === BASE CONFIGURATION ===
set nocompatible
syntax on
set number
set ruler
set showcmd
set showmode

" === DISCOVERY AND HELP ===
set wildmenu
set wildmode=longest:full,full
set wildignore=*.o,*.obj,*.exe,*.swp,*.bak
set helplang=en

" === SEARCH CONFIGURATION ===
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan

" === INDENTATION FOR OSR2 ===
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

" === FILE TYPE SPECIFIC ===
autocmd FileType asm,nasm setlocal tabstop=8 shiftwidth=8 noexpandtab
autocmd FileType make setlocal tabstop=8 shiftwidth=8 noexpandtab
autocmd FileType c setlocal tabstop=4 shiftwidth=4 expandtab

" === OSR2 INTEGRATION ===
autocmd FileType c nnoremap <F9> :w<CR>:!gcc % -o %< -g -Wall<CR>
autocmd FileType c nnoremap <F10> :!./%<<CR>
autocmd FileType c nnoremap <F11> :!r2 %<<CR>

" === PRODUCTIVITY MAPPINGS ===
nnoremap <Esc><Esc> :noh<CR>
nnoremap <leader>h :help<Space>
nnoremap <leader>s :set<Space>

" === INTERFACE ===
set laststatus=2
set statusline=%F%m%r%h%w%=%y\ %l/%L\ %p%%
EOF

echo "✅ Configuração Vim OSR2 aplicada"
echo "🎯 Para testar: vim test.c"
echo "📚 Para help: :help quickref"
```

### Validação da Configuração
```bash
#!/bin/bash
# validate-vim-osr2.sh - Valida setup Vim

echo "🧪 Validando configuração Vim OSR2..."

# Verificar vim instalado
if ! command -v vim >/dev/null 2>&1; then
    echo "❌ Vim não encontrado"
    exit 1
fi

# Verificar .vimrc existe
if [ ! -f ~/.vimrc ]; then
    echo "❌ Arquivo .vimrc não encontrado"
    exit 1
fi

# Criar arquivo teste
cat > test_vim_osr2.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Teste Vim OSR2\n");
    return 0;
}
EOF

# Testar funcionalidades básicas
echo "📝 Testando funcionalidades básicas..."

# Teste syntax highlighting
vim -c 'syntax on | write test_vim_syntax.check | quit' test_vim_osr2.c

# Teste compilação F9 (simulado)
echo "✅ Configuração .vimrc: OK"
echo "✅ Arquivo teste criado: test_vim_osr2.c"
echo "✅ Para testar interativamente:"
echo "   vim test_vim_osr2.c"
echo "   - F9: compilar"
echo "   - F10: executar"
echo "   - F11: analisar com r2"

# Cleanup
rm -f test_vim_syntax.check test_vim_osr2.c
```

Esta seção complementa perfeitamente seu guia OSR2, fornecendo o domínio completo do Vim vanilla necessário para um workflow eficiente de desenvolvimento de sistemas operacionais e análise binária.
