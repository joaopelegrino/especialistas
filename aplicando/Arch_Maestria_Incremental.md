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
        ```
*   **Exercício Prático:**
    1.  Crie um script: `vim test.sh`.
    2.  Digite `#!/bin/bash` e `echo "Hello`.
    3.  Em uma nova linha, digite `ec` e pressione `Ctrl+P`. O Vim autocompletará para `echo`.
    4.  Adicione uma variável com erro, como `msg="hello"`, e na linha seguinte `echo $mesg`.
    5.  Salve (`:w`) e pressione `<F12>`. O `shellcheck` será executado e a "quickfix list" abrirá na parte inferior, mostrando o erro de variável. Use `:cclose` para fechá-la.

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
        ```
*   **Exercício de Workflow Integrado:**
    1.  Crie um projeto simples com `main.c` e `utils.c`/`utils.h`.
    2.  Execute `<leader>rt` (ex: `\rt`) para gerar o arquivo `tags`.
    3.  Escreva uma função em `utils.c` e sua declaração em `utils.h`.
    4.  Chame a função em `main.c`. Coloque o cursor sobre a chamada e pressione `Ctrl+]`. Você saltará para a definição. Use `Ctrl+T` para voltar.
    5.  Introduza um erro em `main.c`. Pressione `<F9>`. O Vim tentará compilar e a quickfix list mostrará o erro.
    6.  Corrija o erro, pressione `<F9>` novamente (agora compila com sucesso), `<F10>` para executar e `<F11>` para analisar com Radare2.

---

## Fase 4: Maestria em Busca e Refatoração

**Objetivo:** Utilizar as ferramentas de busca e Regex do Vim para navegar e modificar código em larga escala, uma habilidade crucial para trabalhar em kernels ou bases de código grandes.

### Habilidade 6: `vimgrep` e Regex para Código
*   **Contexto:** Seu projeto está crescendo. Como encontrar todas as vezes que uma variável específica é usada?
*   **Aprendizado (de `05-1-grep-os.md` e `10-regex-do-basico-ao-avansado.md`):**
    *   `\v` (very magic): Simplifica a sintaxe de regex no Vim.
    *   `\<word\>`: Busca pela palavra exata.
    *   Grupos de Captura `()`: Essencial para substituições.
*   **Exercício de Refatoração:**
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
    *   **Exercício de Pesquisa:** Use `:help :vimgrep`, `:help :cfdo`, `:help s/\<`, e `:help s_flags` (para a flag `c`) para entender cada parte deste workflow.

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

## Conclusão

Ao seguir este guia, você não apenas instalou um ambiente, mas construiu um sistema. Você ordenou a instalação de forma que as ferramentas aprendidas em uma etapa facilitassem a próxima. Você tem um `.vimrc` que cresceu com suas necessidades e que você entende completamente. A partir de agora, seu fluxo de trabalho para aprender qualquer nova ferramenta ou linguagem está definido: **Experimente -> Pesquise na Documentação -> Crie Notas -> Automatize -> Repita.**
