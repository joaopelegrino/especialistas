# 🔧 Guia de Setup OSR2: Arch Linux com Maestria Incremental em Vim

## 🎯 Filosofia: Instalar é Aprender

Este guia reimagina a instalação de um ambiente de desenvolvimento. Em vez de uma lista de comandos a serem copiados, cada etapa da configuração do nosso sistema Arch Linux é uma oportunidade para aprender uma nova habilidade essencial em **Vim** e em **pesquisa de documentação**.

O objetivo não é terminar rápido, mas terminar **autossuficiente**. Ao final, você não terá apenas um ambiente pronto para desenvolvimento de sistemas operacionais (a Trilha OSR2), mas também o domínio sobre suas ferramentas, sabendo como encontrar respostas por conta própria.

**Metodologia:**
1.  **Just-in-Time Learning:** Habilidades de Vim e pesquisa são introduzidas no momento exato em que são necessárias.
2.  **Documentação como Fonte Primária:** Você será guiado a usar `man` e `:help` para validar e aprofundar seu conhecimento.
3.  **Configuração Progressiva:** Seu arquivo `.vimrc` será construído incrementalmente, e cada linha adicionada terá um propósito claro e imediato.

---

## Fase 0: As Ferramentas de Aprendizado

Antes de instalar qualquer pacote, vamos dominar as ferramentas para aprender sobre todos os outros.

### Habilidade 1: `man` - O Manual do Universo Linux

Todo comando que instalaremos possui um manual. Aprender a lê-lo é o primeiro passo para a independência.

1.  **Ação Prática:** Abra o terminal e execute `man pacman`.
2.  **Navegação Essencial:**
    *   Use as **setas**, `PageUp`/`PageDown` para rolar.
    *   Para buscar, digite `/` seguido de um termo (ex: `/-S`) e pressione `Enter`.
    *   Pressione `n` para a próxima ocorrência, `N` para a anterior.
    *   Pressione `q` para sair.
3.  **Estrutura de uma Man Page:**
    *   **NAME:** O que o comando faz.
    *   **SYNOPSIS:** Como usar o comando (sintaxe).
    *   **DESCRIPTION:** Explicação detalhada.
    *   **OPTIONS:** A lista de todas as flags (como `-S`, `-y`, `--noconfirm`).

### Habilidade 2: `vim` e `:help` - Seu Editor e o Manual Embutido

O Vim será nosso centro de comando. Sua documentação interna é uma das melhores já criadas.

1.  **Ação Prática:** Execute `pacman -S vim --noconfirm` para garantir que o Vim esteja instalado. Em seguida, abra-o com `vim`.
2.  **Navegação Essencial no `:help`:**
    *   Digite `:help` e pressione `Enter`. Bem-vindo ao manual do Vim.
    *   **Tags (Links):** Texto entre `|barras|` é um link. Mova o cursor até ele e pressione `Ctrl+]` (Control + Colchete Direito) para saltar. Use `Ctrl+T` para voltar.
    *   **Pesquisa Direcionada:**
        *   `:help :command` -> Ajuda para um comando específico (ex: `:help :write`).
        *   `:help 'option'` -> Ajuda para uma opção de configuração (ex: `:help 'number'`).
        *   `:help mode_key` -> Ajuda para uma tecla em um modo (ex: `:help n_dd` para a tecla `dd` no modo Normal, ou `:help i_CTRL-P` para `Ctrl+P` no modo de Inserção).

**🎯 Tarefa da Fase 0:** Passe 15 minutos em `man pacman` e 15 minutos no `:help` do Vim. Apenas navegue e se familiarize com a busca.

---

## Fase 1: Sistema Base e o Primeiro `.vimrc`

**Objetivo:** Instalar o sistema base e criar um `.vimrc` mínimo que já melhore nossa produtividade para as próximas etapas.

### Etapa 1.1: Atualização do Sistema
*   **Comando:** `pacman -Syu`
*   **Exercício de Pesquisa:** Use `man pacman` para descobrir o que a combinação `Syu` realmente faz. Verifique o significado de "Sync", "Refresh" e "SysUpgrade".

### Etapa 1.2: Instalação das Ferramentas Essenciais
*   **Comando:** `pacman -S --needed --noconfirm base-devel sudo which man-db man-pages git`
*   **Justificativa:** Instalamos `git` agora, pois usaremos versionamento para nossos arquivos de configuração (`dotfiles`) desde o início.

### Etapa 1.3: Criando o `.vimrc` Incremental
Vamos criar e editar nosso primeiro arquivo. Cada configuração adicionada resolverá um problema ou melhorará o próximo passo.

*   **Ação:** Execute `vim ~/.vimrc`.
*   **Habilidade 3: Edição Fundamental no Vim**
    1.  Pressione `i` para entrar no **Modo de Inserção**.
    2.  Adicione as seguintes linhas:
        ```vim
        " FASE 1: Configuração Mínima para Edição de Arquivos de Configuração
        syntax on
        set number
        set ruler
        set showcmd
        set showmode
        set wildmenu
        set wildmode=longest:full,full
        set hlsearch
        set incsearch
        set ignorecase
        set smartcase
        ```
    3.  Pressione `Esc` para voltar ao **Modo Normal**.
    4.  Digite `:wq` para salvar e sair.
*   **Exercício de Pesquisa:** Investigue o propósito de cada linha adicionada.
    *   **Dentro do Vim:** Use o comando `:help 'option'` (por exemplo, `:help 'hlsearch'`) para ler a documentação oficial.
    *   **Direto do Terminal:** Para uma consulta ainda mais rápida, execute `vim -c "help 'hlsearch'"`. Este comando abre o Vim diretamente na página de ajuda desejada, uma técnica extremamente eficiente para sanar dúvidas pontuais.
*   **Aplicação Imediata:** As configurações de busca que você acabou de adicionar (`hlsearch`, `incsearch`, `ignorecase`, `smartcase`) serão cruciais na próxima fase, quando precisarmos encontrar e modificar texto em arquivos de configuração.

---

## Fase 2: Usuário, Permissões e Shell Inteligente

**Objetivo:** Criar nosso usuário de desenvolvimento e configurar o Vim para nos ajudar a escrever scripts de shell e editar arquivos de sistema com mais eficiência.

### Etapa 2.1: Criar Usuário e Configurar `sudo`
Siga os passos de `useradd`, `passwd` e `EDITOR=vim visudo` do guia `arch.md`.
*   **Aplicação da Habilidade:** Use a busca (`/wheel`) e a edição (`x` para deletar `#`) que você aprendeu para modificar o arquivo `sudoers`. As configurações de `hlsearch` e `incsearch` no seu `.vimrc` tornarão a busca mais visual e rápida.

### Etapa 2.2: Login e Preparação do Shell
*   **Ação:** Faça login como seu novo usuário (`su - oseng`).
*   **Contexto:** Vamos criar scripts de validação e automação. Precisamos que o Vim nos ajude com a sintaxe do shell.
*   **Habilidade 4: Linting e Completion para Shell**
    1.  **Instale o Linter:** `sudo pacman -S --noconfirm shellcheck`
    2.  **Configure o Vim:** Adicione ao seu `~/.vimrc`:
        ```vim
        " FASE 2: Configurações para Shell Scripting e Edição de Dotfiles
        " Integração com o linter shellcheck para scripts de shell
        autocmd FileType sh setlocal makeprg=shellcheck\ \-f\ \gcc\ \%
        autocmd FileType sh setlocal errorformat=%f:%l:%c:\ \%t%*[^:]:\ \%m,%f:%l:\ \%m

        " Habilita completion de palavras-chave de qualquer buffer aberto
        set complete=.,w,b,u,t

        " Mapeamento universal para compilar/verificar e abrir a lista de erros
        nnoremap <F12> :make!<CR>:copen<CR>
        
        " === CAMADA INSTRUTIVA: SISTEMAS DE COMPLETION ===
        " Completion básico: Ctrl+n (próxima) e Ctrl+p (anterior)
        " Para ativar completion especializado: Ctrl+x seguido de:
        "   Ctrl+f = arquivos/caminhos    (ex: /home/user<C-x><C-f>)
        "   Ctrl+l = linhas inteiras      (ex: def func<C-x><C-l>)  
        "   Ctrl+o = omni (inteligente)   (ex: import <C-x><C-o>)
        "   Ctrl+] = tags                 (ex: função<C-x><C-]>)
        " Configurações de UI para melhor experiência visual:
        set pumheight=10                    " Altura máxima do menu popup
        set completeopt=menu,menuone,noselect " Opções do menu completion
        ```
*   **Exercício Prático - Completion Systems:**
    1.  Crie um script: `vim test.sh`.
    2.  Digite `#!/bin/bash` e `echo "Hello`.
    3.  **Teste Completion Básico:** Em uma nova linha, digite `ec` e pressione `Ctrl+P`. O Vim autocompletará para `echo`.
    4.  **Teste File Completion:** Digite `/home/` e pressione `Ctrl+x Ctrl+f` para completar caminhos.
    5.  **Teste Line Completion:** Após digitar uma linha, em nova linha digite as primeiras palavras e use `Ctrl+x Ctrl+l` para completar linhas similares.
    6.  Adicione uma variável com erro, como `msg="hello"`, e na linha seguinte `echo $mesg`.
    7.  **Teste Linting:** Salve (`:w`) e pressione `<F12>`. O `shellcheck` será executado e a "quickfix list" abrirá na parte inferior, mostrando o erro de variável. Use `:cclose` para fechá-la.

---

## Fase 3: O Ambiente de Desenvolvimento C e Assembly

**Objetivo:** Instalar as ferramentas de compilação e transformar o Vim em uma IDE para C e Assembly, com compilação, linting e navegação de código integrados.

### Etapa 3.1: Instalar Ferramentas de Desenvolvimento e Análise
*   **Comando:** `sudo pacman -S --needed --noconfirm gcc nasm make qemu-full gdb radare2 ctags`

### Etapa 3.2: Configurando o Vim como uma IDE
*   **Contexto:** Agora que temos `gcc` e `ctags`, podemos integrar a compilação e a navegação de código diretamente no editor.
*   **Habilidade 5: Integração com Compilador e Navegação por Tags**
    *   **Ação:** Adicione ao seu `~/.vimrc`:
        ```vim
        " FASE 3: Configuração como IDE para C e Assembly
        " Linting e Compilação para C
        autocmd FileType c setlocal makeprg=gcc\ \-Wall\ \-Wextra\ \-g\ \%\ \-\o\ \%<
        autocmd FileType c setlocal errorformat=%f:%l:%c:\ \%t%*[^:]:\ \%m,%f:%l:\ \%m

        " Mapeamentos para Produtividade (Compilar, Executar, Analisar)
        nnoremap <F9>  :w<CR>:make!<CR>
        nnoremap <F10> :!./%<<CR>
        nnoremap <F11> :!r2 %<<CR>
        nnoremap <F12> :make!<CR>:copen<CR>

        " Navegação por Tags
        set tags=./tags,tags;
        nnoremap <leader>rt :!ctags -R .<CR>
        
        " === CAMADA INSTRUTIVA: COMANDOS READ EXTERNAL ===
        " Inserir output de comandos externos no buffer:
        " :r !comando               - insere saída do comando
        " :r !man curl | head -10   - manual resumido  
        " :r !date                  - data atual
        " :r !ls -la | grep ".c"    - listagem filtrada
        " Pipelines complexos com grep e regex:
        " :r !man gcc | grep -E "^\s*-[a-zA-Z]" | head -15
        nnoremap <leader>rh :r !man<Space>
        nnoremap <leader>rd :r !date<CR>
        ```
*   **Exercício de Workflow Integrado:**
    1.  Crie um projeto simples com `main.c` e `utils.c`/`utils.h`.
    2.  **Teste Read External:** Use `<leader>rh gcc` para inserir opções do gcc no buffer atual.
    3.  Execute `<leader>rt` (ex: `\rt`) para gerar o arquivo `tags`.
    4.  Escreva uma função em `utils.c` e sua declaração em `utils.h`.
    5.  **Teste Tag Navigation:** Chame a função em `main.c`. Coloque o cursor sobre a chamada e pressione `Ctrl+]`. Você saltará para a definição. Use `Ctrl+T` para voltar.
    6.  **Teste Documentation Integration:** Use `:r !man printf | head -5` para inserir documentação da função printf.
    7.  Introduza um erro em `main.c`. Pressione `<F9>`. O Vim tentará compilar e a quickfix list mostrará o erro.
    8.  Corrija o erro, pressione `<F9>` novamente (agora compila com sucesso), `<F10>` para executar e `<F11>` para analisar com Radare2.

---

## Fase 4: Maestria em Busca e Refatoração

**Objetivo:** Utilizar as ferramentas de busca e Regex do Vim para navegar e modificar código em larga escala, uma habilidade crucial para trabalhar em kernels ou bases de código grandes.

### Habilidade 6: `find`, `vimgrep` e Regex para Código
*   **Contexto:** Seu projeto está crescendo. Como encontrar arquivos por nome E conteúdo dentro deles?
*   **Conceitos Fundamentais:**
    *   **`:find`** localiza ARQUIVOS por nome (usa 'path')  
    *   **`:vimgrep`** busca CONTEÚDO dentro de arquivos (popula quickfix)
    *   **Quickfix System:** Lista unificada de resultados navegável
*   **Aprendizado Técnico:**
    *   `\v` (very magic): Simplifica a sintaxe de regex no Vim.
    *   `\<word\>`: Busca pela palavra exata.
    *   Grupos de Captura `()`: Essencial para substituições.
    *   `**/*.ext`: Padrão glob recursivo para extensões específicas.
*   **Exercício Prático de Find vs Vimgrep:**
    1.  **Configurar Path:** `:set path=.,src/**,include/**` (adiciona diretórios)
    2.  **Encontrar Arquivo:** `:find utils.h` (localiza arquivo por nome)  
    3.  **Buscar Conteúdo:** `:vimgrep /\v\<user_count\>/ **/*.c` (busca variável)
    4.  **Navegar Resultados:** `:copen` → `:cnext` → `:cprev` → `:cclose`

*   **Exercício de Refatoração Avançada:**
    1.  Suponha que você tem uma variável `int user_count = 0;` usada em vários lugares.
    2.  Para encontrar todos os usos, execute: `:vimgrep /\v\<user_count\>/ **/*.c`.
    3.  Abra a quickfix list com `:copen` para revisar todos os locais.
    4.  Para renomear para `userCount`, execute um comando de substituição em todos os arquivos da quickfix list:
        ```vim
        :cfdo %s/\<user_count\>/userCount/g | update
        ```
    *   **Dica de Refatoração Segura:** O comando acima é poderoso, mas substitui tudo automaticamente. Para revisar cada mudança antes de confirmá-la, adicione a flag `c` ao final do comando de substituição:
        ```vim
        :cfdo %s/\<user_count\>/userCount/gc | update
        ```
        O Vim irá parar em cada ocorrência e perguntar `replace with userCount (y/n/a/q/l/^E/^Y)?`. Isso lhe dá controle total sobre a refatoração.
    *   **Mapeamentos para Workflow:** Adicione ao `.vimrc`:
        ```vim
        " === CAMADA INSTRUTIVA: FIND E VIMGREP INTEGRATION ===
        " Configurações para busca eficiente
        set path=.,src/**,include/**,/usr/include,,  " Paths de busca  
        set wildmenu wildmode=list:longest           " Menu completion
        " Mapeamentos para workflows de busca
        nnoremap <leader>f :find<Space>              " Find arquivo
        nnoremap <leader>g :vimgrep //<Space>**/*<Left><Left><Left><Left><Left>  " Vimgrep
        nnoremap <leader>cn :cnext<CR>               " Próximo resultado  
        nnoremap <leader>cp :cprev<CR>               " Resultado anterior
        nnoremap <leader>co :copen<CR>               " Abrir quickfix
        nnoremap <leader>cc :cclose<CR>              " Fechar quickfix
        ```
    *   **Exercício de Pesquisa:** Use `:help :find`, `:help :vimgrep`, `:help :cfdo`, `:help s/\<`, e `:help s_flags` para entender cada parte deste workflow.

---

## Fase 5: Configuração Final e Validação

**Objetivo:** Finalizar as configurações do ambiente e validar todo o setup com um teste prático.

### Etapa 5.1: Configuração do Radare2
*   **Ação:** Como seu usuário `oseng`, crie o arquivo `~/.radare2rc` com o conteúdo do guia `arch.md` para padronizar a sintaxe Intel e as cores. Use o Vim para isso, praticando suas habilidades de edição.

### Etapa 5.2: Script de Validação Final
*   **Ação:** Crie um script `validate_environment.sh`. Use o Vim.
*   **Conteúdo do Script:**
    ```bash
    #!/bin/bash
    # Adiciona um 'trap' para garantir que os arquivos de teste sejam removidos
    # ao final da execução, independentemente de sucesso ou falha.
    trap 'rm -f test.c test' EXIT

    echo "--- Validando Ferramentas ---"
    for cmd in gcc nasm make git r2 gdb qemu-system-i386 ctags; do
        command -v $cmd >/dev/null 2>&1 && echo "✅ $cmd: OK" || echo "❌ $cmd: FALHOU"
    done

    echo -e "\n--- Validando Workflow Vim ---"
    cat > test.c <<EOF
    #include <stdio.h> 
    int main() { printf("Setup OSR2 Validado!\n"); return 0; }
    EOF

    # A saída do Vim é redirecionada para /dev/null para manter o output limpo
    vim -c ":w" -c ":!gcc % -o test" -c ":q!" test.c &> /dev/null

    if [ -f "test" ]; then
        echo "✅ Compilação via Vim: OK"
        RESULT=$(./test)
        if [[ "$RESULT" == "Setup OSR2 Validado!" ]]; then
            echo "✅ Execução e Output: OK"
        else
            echo "❌ Execução e Output: FALHOU"
        fi
    else
        echo "❌ Compilação via Vim: FALHOU"
    fi
    ```

*   **Ação Final:** Torne o script executável (`chmod +x validate_environment.sh`) e rode-o. Se todos os testes passarem, seu ambiente está pronto e, mais importante, você entende cada componente dele.

---

## 🎯 Síntese das Camadas Instrucionais Adicionadas

### **Completion Systems (Fase 2)**
- **Completion Básico:** `Ctrl+n/p` para navegação em palavras
- **Completion Especializado:** `Ctrl+x` + tipo (`Ctrl+f` arquivos, `Ctrl+l` linhas, `Ctrl+o` omni)
- **Configurações UI:** `pumheight`, `completeopt` para melhor experiência visual

### **Read External Commands (Fase 3)**  
- **Inserção Dinâmica:** `:r !comando` para inserir output de comandos
- **Documentation Integration:** `:r !man comando | head -N` para documentação inline
- **Mapeamentos Eficientes:** `<leader>rh` para man pages, `<leader>rd` para data

### **Find e Vimgrep Integration (Fase 4)**
- **Dual Search Philosophy:** `:find` para arquivos vs `:vimgrep` para conteúdo  
- **Quickfix Mastery:** Navegação com `:cnext/:cprev`, gerenciamento com `:copen/:cclose`
- **Path Configuration:** `set path=` para controlar onde `:find` busca
- **Refactoring Workflows:** `:cfdo` para operações em massa nos resultados

### **Mapeamentos Unificados**
```vim
" Completion shortcuts
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

" External documentation  
nnoremap <leader>rh :r !man<Space>

" Search workflows
nnoremap <leader>f :find<Space>
nnoremap <leader>g :vimgrep //<Space>**/*<Left><Left><Left><Left><Left>
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>co :copen<CR>
```

## Conclusão

Ao seguir este guia, você não apenas instalou um ambiente, mas construiu um **sistema de aprendizado integrado**. Cada ferramenta introduzida se conecta às anteriores, criando um workflow onde:

1. **Read External** integra documentação diretamente no código
2. **Completion Systems** aceleram a escrita com context-awareness  
3. **Find/Vimgrep** unificam descoberta de arquivos e conteúdo
4. **Quickfix** centraliza navegação em resultados de todas as operações

Você tem um `.vimrc` que cresceu organicamente com suas necessidades e que você entende completamente. A partir de agora, seu fluxo de trabalho para aprender qualquer nova ferramenta ou linguagem está definido: **Experimente -> Pesquise na Documentação -> Crie Notas -> Automatize -> Repita.**

**🔍 Próximos Passos:** Use `:help usr_toc` para explorar outros sistemas do Vim que seguem os mesmos padrões de decomposição técnica que você acabou de dominar.
