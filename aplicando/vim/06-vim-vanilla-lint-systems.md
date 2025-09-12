# Sistemas Nativos de Linting do Vim

## Visão Geral

O Vim vanilla possui um sistema robusto de linting e verificação de código que não requer plugins externos. Através dos recursos `makeprg`, `errorformat`, compiler plugins e quickfix list, é possível configurar análise de código profissional para diversas linguagens de programação.

## Arquitetura do Sistema de Linting

### Componentes Principais

#### 1. makeprg (Make Program)
- **Função**: Define qual programa executar com o comando `:make`
- **Padrão**: `"make"` (sistema de build tradicional)
- **Personalização**: Pode ser configurado para qualquer linter ou ferramenta de análise

#### 2. errorformat (Formato de Erro)
- **Função**: Especifica como interpretar a saída dos linters
- **Formato**: Padrões scanf-style para extrair informações de erro
- **Elementos**: Nome do arquivo, número da linha, coluna, tipo de erro, mensagem

#### 3. Quickfix List
- **Função**: Interface para navegar entre erros e avisos
- **Integração**: Recebe automaticamente a saída processada de `makeprg`
- **Comandos**: `:cnext`, `:cprev`, `:copen`, `:cclose`

## Compiler Plugins Nativos

### Linters Suportados Nativamente

O Vim inclui **96 compiler plugins** em `$VIMRUNTIME/compiler/`, incluindo:

#### Linguagens de Programação
- **Python**: `pylint`, `flake8`, `mypy`
- **JavaScript**: `eslint`, `jshint`
- **Shell Script**: `shellcheck`
- **C/C++**: `gcc`, `clang`
- **Go**: `go build`, `go vet`
- **Rust**: `cargo`, `rustc`
- **Java**: `javac`, `checkstyle`

#### Ferramentas de Build
- **Make**: `make`, `gmake`
- **CMake**: `cmake`
- **Gradle**: `gradle`
- **Maven**: `mvn`

### Uso dos Compiler Plugins

#### Configuração Automática
```vim
" Ativa compiler específico para tipo de arquivo
autocmd FileType python compiler pylint
autocmd FileType javascript compiler eslint
autocmd FileType sh compiler shellcheck
autocmd FileType go compiler go
```

#### Configuração Manual
```vim
" Definir compiler manualmente
:compiler pylint

" Executar linting
:make %
```

## Configuração de Linting Personalizado

### Exemplo: Configuração para shellcheck

```vim
" Definir makeprg para shellcheck
setlocal makeprg=shellcheck\ -f\ gcc\ %

" Definir errorformat para shellcheck
setlocal errorformat=%f:%l:%c:\ %t%*[^:]:\ %m
```

### Exemplo: Configuração para ESLint

```vim
" Configuração para JavaScript/ESLint
autocmd FileType javascript setlocal makeprg=eslint\ --format\ compact\ %
autocmd FileType javascript setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m
```

### Exemplo: Configuração para Black (Python)

```vim
" Configuração para formatação com Black
autocmd FileType python setlocal makeprg=black\ --check\ --diff\ %
autocmd FileType python setlocal errorformat=%f:%l:%c:\ %m
```

## Padrões de Errorformat

### Sintaxe Básica

```vim
" Formato: arquivo:linha:coluna: tipo: mensagem
set errorformat=%f:%l:%c:\ %t%*[^:]:\ %m

" Múltiplos formatos (separados por vírgula)
set errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,%f\ %l\ %m
```

### Tokens Principais

- `%f` - Nome do arquivo
- `%l` - Número da linha
- `%c` - Número da coluna
- `%m` - Mensagem de erro
- `%t` - Tipo de erro (E=error, W=warning, I=info)
- `%n` - Número do erro
- `%s` - Search text (para padrões grep)

### Modificadores

- `%*` - Match qualquer sequência
- `%.` - Match um caractere
- `%+` - Match uma ou mais sequências
- `%-` - Match zero ou mais sequências

## Automação de Linting

### Linting Automático ao Salvar

```vim
" Executa linting automaticamente ao salvar
autocmd BufWritePost *.py silent make! <afile> | silent redraw!
autocmd BufWritePost *.js silent make! <afile> | silent redraw!
autocmd BufWritePost *.sh silent make! <afile> | silent redraw!
```

### Linting Silencioso com Feedback Visual

```vim
" Função para linting silencioso
function! LintCurrentFile()
    let l:old_makeprg = &makeprg
    let l:old_errorformat = &errorformat
    
    " Configurar temporariamente para o linter
    compiler eslint
    
    " Executar make silencioso
    silent make! %
    
    " Restaurar configurações
    let &makeprg = l:old_makeprg
    let &errorformat = l:old_errorformat
    
    " Mostrar resultado
    if len(getqflist()) > 0
        copen
        echo "Erros encontrados! Verifique quickfix list."
    else
        cclose
        echo "Código sem erros!"
    endif
endfunction

" Mapear para tecla de atalho
nnoremap <leader>l :call LintCurrentFile()<CR>
```

## Comandos da Quickfix List

### Navegação Básica

```vim
:copen        " Abrir quickfix window
:cclose       " Fechar quickfix window
:cnext        " Próximo erro
:cprev        " Erro anterior  
:cfirst       " Primeiro erro
:clast        " Último erro
:cc [nr]      " Ir para erro número [nr]
```

### Navegação Avançada

```vim
:clist        " Listar todos os erros
:colder       " Ir para quickfix list anterior
:cnewer       " Ir para quickfix list posterior
:cgetfile     " Ler erros de arquivo
:caddfile     " Adicionar erros de arquivo
```

### Mapeamentos Úteis

```vim
" Navegação rápida na quickfix list
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprev<CR>
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>
```

## Criação de Compiler Personalizado

### Estrutura de Compiler Plugin

```vim
" ~/.vim/compiler/mycustom.vim
if exists("current_compiler")
    finish
endif
let current_compiler = "mycustom"

" Configuração específica
CompilerSet makeprg=mycustom-linter\ %
CompilerSet errorformat=%f:%l:%c:\ %m
```

### Exemplo: Compiler para Hadolint (Docker)

```vim
" ~/.vim/compiler/hadolint.vim
if exists("current_compiler")
    finish
endif
let current_compiler = "hadolint"

CompilerSet makeprg=hadolint\ --format\ gcc\ %
CompilerSet errorformat=%f:%l:%c:\ %t%*[^:]:\ %m
```

## Integração com Sistemas Externos

### Git Hooks Integration

```bash
#!/bin/bash
# pre-commit hook
vim -c "compiler eslint" -c "make! %" -c "if len(getqflist()) > 0 | cquit | else | quit | endif" "$file"
```

### CI/CD Integration

```vim
" Configuração para ambiente CI
if $CI == '1'
    set makeprg=eslint\ --format\ compact\ --max-warnings\ 0\ %
    autocmd BufWritePost *.js make! | if len(getqflist()) > 0 | cquit 1 | endif
endif
```

## Formatação e Fixing Automático

### Auto-fix com Linters

```vim
" Função para auto-fix com ESLint
function! EslintFix()
    let l:winview = winsaveview()
    silent execute "!eslint --fix " . expand("%")
    silent edit!
    call winrestview(l:winview)
    echo "ESLint fix aplicado!"
endfunction

command! EslintFix call EslintFix()
nnoremap <leader>ef :EslintFix<CR>
```

### Formatação com Prettier

```vim
" Auto-formatação com Prettier
function! PrettierFormat()
    let l:winview = winsaveview()
    silent execute "%!prettier --stdin-filepath " . expand("%")
    call winrestview(l:winview)
endfunction

command! Prettier call PrettierFormat()
nnoremap <leader>pf :Prettier<CR>
```

## Configurações Avançadas

### Multiple Linters por Filetype

```vim
" Função para executar múltiplos linters
function! RunMultipleLinters()
    " Salvar configuração atual
    let l:old_makeprg = &makeprg
    let l:old_errorformat = &errorformat
    
    " Lista de linters para Python
    let l:linters = ['pylint', 'flake8', 'mypy']
    let l:all_errors = []
    
    for linter in l:linters
        execute 'compiler ' . linter
        silent make! %
        let l:all_errors += getqflist()
    endfor
    
    " Restaurar e definir lista completa
    let &makeprg = l:old_makeprg
    let &errorformat = l:old_errorformat
    call setqflist(l:all_errors)
    
    if len(l:all_errors) > 0
        copen
    endif
endfunction

command! LintAll call RunMultipleLinters()
```

### Configuração por Projeto

```vim
" Carregamento de configuração específica do projeto
function! LoadProjectLintConfig()
    if filereadable('.vimrc.local')
        source .vimrc.local
    endif
    
    " Detectar tipo de projeto e aplicar configuração
    if filereadable('package.json')
        compiler eslint
    elseif filereadable('setup.py') || filereadable('pyproject.toml')
        compiler pylint
    elseif filereadable('Cargo.toml')
        compiler cargo
    endif
endfunction

autocmd VimEnter * call LoadProjectLintConfig()
```

## Troubleshooting Comum

### Problemas Frequentes

#### 1. Errorformat não funciona
```vim
" Debug errorformat
:set errorformat?
:echo &errorformat

" Testar manualmente
:cexpr "arquivo.py:10:5: E123: erro de teste"
```

#### 2. Makeprg não encontrado
```vim
" Verificar path
:!which eslint
:echo $PATH

" Usar path absoluto se necessário
set makeprg=/usr/local/bin/eslint\ %
```

#### 3. Encoding issues
```vim
" Configurar encoding
set encoding=utf-8
set fileencodings=utf-8,latin1
```

## Performance e Otimização

### Linting Assíncrono Simulado

```vim
" Simulação de linting assíncrono usando job control (Vim 8+)
function! AsyncLint()
    if exists("*job_start")
        let job = job_start(['eslint', '--format', 'compact', expand('%')], {
            \ 'out_cb': function('LintCallback'),
            \ 'err_cb': function('LintCallback')
            \ })
    else
        " Fallback para versões antigas
        silent make!
    endif
endfunction

function! LintCallback(channel, msg)
    " Processar resultado do linting
    echom "Lint result: " . a:msg
endfunction
```

### Cache de Resultados

```vim
" Sistema simples de cache para evitar re-linting desnecessário
let g:lint_cache = {}

function! CachedLint()
    let file_hash = getftime(expand('%')) . '_' . getfsize(expand('%'))
    
    if has_key(g:lint_cache, expand('%')) && g:lint_cache[expand('%')] == file_hash
        echo "Usando resultado de lint em cache"
        return
    endif
    
    silent make!
    let g:lint_cache[expand('%')] = file_hash
endfunction
```

## Integração com Status Line

### Exibição de Status de Lint

```vim
" Função para status de lint na statusline
function! LintStatus()
    let qf_list = getqflist()
    let error_count = 0
    let warning_count = 0
    
    for item in qf_list
        if item.type == 'E'
            let error_count += 1
        elseif item.type == 'W'
            let warning_count += 1
        endif
    endfor
    
    if error_count > 0
        return printf('E:%d W:%d', error_count, warning_count)
    elseif warning_count > 0
        return printf('W:%d', warning_count)
    else
        return 'OK'
    endif
endfunction

" Incluir na statusline
set statusline+=[%{LintStatus()}]
```

## Melhores Práticas

### 1. Organização de Configuração
- Manter configurações de linting em arquivos ftplugin específicos
- Usar compiler plugins quando disponíveis
- Criar compiler personalizado apenas quando necessário

### 2. Performance
- Evitar linting automático em arquivos muito grandes
- Usar `:make!` (com !) para evitar salto automático para erro
- Configurar timeout apropriado para linters lentos

### 3. Usabilidade
- Mapear comandos frequentes para teclas convenientes
- Usar feedback visual adequado (echom, statusline)
- Manter quickfix list organizada com `:colder`/`:cnewer`

### 4. Compatibilidade
- Testar configurações em diferentes versões do Vim
- Prover fallbacks para linters não instalados
- Documentar dependências externas necessárias

## Conclusão

O sistema nativo de linting do Vim oferece uma base sólida para análise de código profissional sem dependências externas. Através da combinação de `makeprg`, `errorformat`, compiler plugins e quickfix list, é possível criar um ambiente de desenvolvimento robusto que rivaliza com soluções baseadas em plugins mais complexos.

A flexibilidade do sistema permite desde configurações simples até integrações sofisticadas com múltiplos linters, auto-fixing e feedback visual avançado, mantendo a filosofia minimalista e eficiente que caracteriza o Vim.
