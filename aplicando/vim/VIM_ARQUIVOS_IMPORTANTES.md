# 📚 VIM - ARQUIVOS IMPORTANTES
**Gerado em:** qui 11 set 2025 11:22:46 -03
**Arquivos incluídos:** 05-1-grep-os.md 04-help-and-man-pages.md 02-completion-systems.md 10-regex-do-basico-ao-avansado.md 08-navegacao-help-tags.md


---
## 📁 05-1-grep-os.md

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

---
## 📁 04-help-and-man-pages.md

# Sistemas de Ajuda Linux e Man Pages

## Fundamentos das Man Pages

### Uso Básico
- **Formato**: `man <comando>`
- **Exemplo**: `man ls` - mostra manual do comando ls
- **Sair**: `q` para sair de qualquer man page
- **Ajuda**: `h` para ajuda de navegação dentro das man pages

### Navegação (Teclas Estilo Vim)
- **Movimento de linha**: `j` (baixo), `k` (cima)
- **Movimento de tela**: `Ctrl+f` (frente), `Ctrl+b` (trás)  
- **Pular para início**: `g` (começo), `G` (fim)
- **Números de linha**: `3j` (baixo 3 linhas), `3k` (cima 3 linhas)

### Busca em Man Pages
- **Busca para frente**: `/padrão` então `n` (próximo), `N` (anterior)
- **Busca para trás**: `?padrão` então `n` (mesma direção), `N` (inverter)
- **Repetição de busca**: `n` continua na direção da busca

## Convenções das Man Pages

### Formatação de Texto
- **Texto em negrito**: Digite exatamente como mostrado (comandos/opções literais)
- **Texto em itálico/sublinhado**: Substitua por argumento apropriado
- **Colchetes `[opção]`**: Parâmetros opcionais
- **Pipe `|`**: Opções mutuamente exclusivas (escolha uma)
- **Reticências `...`**: Pode ser repetido múltiplas vezes

### Estrutura de Comando - Exemplos
- `ls [opção]... [arquivo]...` 
  - Opções são opcionais e repetíveis
  - Arquivos são opcionais e repetíveis
  - Comando pode executar sem argumentos

### Formatos de Opção
- **Forma curta**: `-a` (traço simples, letra única)
- **Forma longa**: `--all` (traço duplo, palavra completa)
- **Equivalência**: `-a` e `--all` são idênticos
- **Argumentos**: `--width=60` (longo) = `-W 60` (curto)

## Melhores Práticas de Opções de Comando

### Combinando Opções Curtas
- **Separadas**: `ls -l -h` 
- **Combinadas**: `ls -lh` (equivalente)
- **Flexibilidade de ordem**: `ls -hl` também funciona
- **Misto**: `ls -lh --color=none` (curta + longa)

### Opções com Argumentos
- **Regra**: Opção que requer argumento deve ser última na forma combinada
- **Correto**: `ls -Fw 60` (w precisa de argumento, então é última)
- **Incorreto**: `ls -wF 60` (F seria tratado como argumento de w)
- **Espaçamento**: `ls -W60` (sem espaço necessário para opções curtas)

## Seções das Man Pages

### Números de Seção
1. **Seção 1**: Comandos do usuário (mais comum)
2. **Seção 2**: Chamadas do sistema (programação)
3. **Seção 3**: Funções de biblioteca (programação)  
4. **Seção 8**: Comandos de administração do sistema

### Múltiplas Seções
- **Padrão**: `man unlink` (mostra primeira encontrada, geralmente seção 1)
- **Específica**: `man 2 unlink` (mostra versão da seção 2)
- **Buscar todas**: `man -k padrão` (busca por palavra-chave em seções)

### POSIX vs Linux
- **Seções POSIX**: Terminam em 'P' (ex.: seção 3P)
- **Específicas do Linux**: Sem sufixo 'P'
- **Preferência**: Use seções Linux para sistemas Linux

## Built-ins do Shell

### Identificação
- **Testar tipo de comando**: `type nome_comando`
- **Resultado built-in**: Mostra "shell builtin" ou "shell keyword"
- **Resultado externo**: Mostra caminho do arquivo

### Obtendo Ajuda para Built-ins
- **Sistema de ajuda built-in**: `help nome_comando`
- **Listar todos**: `help` (mostra todos os tópicos de ajuda disponíveis)
- **Exemplo**: `help while` (sintaxe para loops while)

### Built-ins Comuns
- `help`, `type`, `cd`, `pwd`, `echo`, `while`, `for`, `if`
- Sem man pages dedicadas (construídos no shell)
- Documentação na man page do shell (ex.: `man bash`)

## Sistemas de Ajuda Alternativos

### Ajuda Built-in de Comandos
- **Padrão**: `comando --help` (mais comum)
- **Forma curta**: `comando -h` (alguns comandos)
- **Ponto de interrogação**: `comando -?` (raro)

### Exemplos
- `man --help` - mostra opções do comando man
- `ls --help` - mostra ajuda do comando ls
- `vim --help` - mostra opções de inicialização do vim

## Encontrando Documentação

### Estratégia de Busca
1. Tente `man comando` primeiro
2. Se não encontrar, tente `type comando` para verificar se é built-in
3. Se built-in, use `help comando`
4. Tente `comando --help` para referência rápida
5. Use `man -k palavra-chave` para tópicos relacionados

### Estrutura das Man Pages
- **NAME**: Descrição breve
- **SYNOPSIS**: Sintaxe de uso
- **DESCRIPTION**: Explicação detalhada
- **OPTIONS**: Flags e argumentos disponíveis
- **EXAMPLES**: Padrões de uso comum
- **SEE ALSO**: Comandos e tópicos relacionados
- **FILES**: Arquivos de configuração
- **ENVIRONMENT**: Variáveis de ambiente relevantes
- **EXIT STATUS**: Códigos de retorno para scripts

## Dicas Práticas

### Leitura Eficaz
1. Comece com SYNOPSIS para sintaxe
2. Pule para OPTIONS para flags específicas
3. Verifique EXAMPLES para padrões comuns
4. Use SEE ALSO para ferramentas relacionadas

### Referência Rápida
- Mantenha man pages usadas frequentemente marcadas
- Crie folhas de cola pessoais para comandos complexos
- Pratique teclas de navegação até ficarem automáticas
- Use completar com tab no sistema de ajuda: `:help <tab>`
---
## 📁 02-completion-systems.md

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
---
## 📁 10-regex-do-basico-ao-avansado.md

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
---
## 📁 08-navegacao-help-tags.md

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