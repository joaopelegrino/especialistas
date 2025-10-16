# Práticas Otimizadas de Zsh: Navegação, Edição e Histórico Avançado

## 📋 Índice

1. [Navegação Inteligente Entre Diretórios](#1-navegação-inteligente-entre-diretórios)
2. [Movimentação Avançada em Linha de Comando](#2-movimentação-avançada-em-linha-de-comando)
3. [Sistema de Histórico e Expansões](#3-sistema-de-histórico-e-expansões)
4. [Variáveis e Parâmetros de Comando](#4-variáveis-e-parâmetros-de-comando)
5. [Configuração Otimizada (.zshrc)](#5-configuração-otimizada-zshrc)
6. [Fluxos de Trabalho Práticos](#6-fluxos-de-trabalho-práticos)

---

## 1. Navegação Inteligente Entre Diretórios

### 1.1 Directory Stack (Pilha de Diretórios)

O Zsh oferece um sistema de pilha de diretórios extremamente poderoso que permite navegar entre múltiplos diretórios de forma eficiente.

#### Comandos Básicos

```bash
# pushd - Adiciona diretório à pilha e navega até ele
pushd /usr/local/bin              # Vai para /usr/local/bin e adiciona à pilha
pushd ~/projects/webapp           # Adiciona outro diretório

# popd - Remove topo da pilha e volta ao diretório anterior
popd                              # Volta ao diretório anterior

# dirs - Visualiza a pilha de diretórios
dirs                              # Mostra todos os diretórios na pilha
dirs -v                           # Mostra com índices numéricos
dirs -c                           # Limpa toda a pilha

# Exemplo de uso
~/projects $ pushd /var/log
/var/log ~/projects
/var/log $ pushd /etc
/etc /var/log ~/projects
/etc $ popd
/var/log ~/projects
/var/log $ popd
~/projects
```

#### Navegação Direta por Índice

```bash
# Visualizar pilha com índices
dirs -v
# 0  /etc
# 1  /var/log
# 2  ~/projects
# 3  ~/Downloads

# Navegar usando cd com índices
cd ~1                             # Vai para /var/log (índice 1)
cd ~2                             # Vai para ~/projects (índice 2)
cd +2                             # Alternativa: vai para índice 2
cd -1                             # Conta de trás para frente

# Com tab completion
cd ~<TAB>                         # Lista todos os índices disponíveis
cd +<TAB>                         # Lista com direção positiva
cd -<TAB>                         # Lista com direção negativa
```

#### Opções Avançadas de Directory Stack

```bash
# Adicionar no .zshrc para comportamento otimizado

# AUTO_PUSHD: cd automaticamente faz pushd
setopt AUTO_PUSHD                 # cd funciona como pushd

# PUSHD_IGNORE_DUPS: Evita duplicatas na pilha
setopt PUSHD_IGNORE_DUPS         # Não adiciona duplicatas

# PUSHD_MINUS: Inverte significado de +N e -N
setopt PUSHD_MINUS               # cd -1 vai para índice 1 (não -1)

# PUSHD_SILENT: Não mostra pilha após cada pushd/popd
setopt PUSHD_SILENT              # Modo silencioso

# PUSHD_TO_HOME: pushd sem argumentos vai para $HOME
setopt PUSHD_TO_HOME             # pushd == cd ~

# CDABLE_VARS: Permite cd para variáveis
setopt CDABLE_VARS               # cd var funciona se $var é diretório

# AUTO_NAME_DIRS: Nomeia diretórios automaticamente
setopt AUTO_NAME_DIRS            # Cria nomes para caminhos em variáveis

# Limitar tamanho da pilha
DIRSTACKSIZE=20                  # Máximo de 20 diretórios na pilha
```

#### Exemplos Práticos de Uso

```bash
# Configuração recomendada no .zshrc
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_MINUS
DIRSTACKSIZE=20

# Workflow típico
cd ~/projects/frontend            # AUTO_PUSHD adiciona à pilha automaticamente
cd ~/projects/backend             # Adiciona este também
cd ~/projects/database            # E mais este

# Agora você pode navegar rapidamente
cd -1                             # Volta para backend
cd -2                             # Vai para frontend
cd ~1                             # Alternativa: ~1 == backend

# Visualizar histórico de navegação
dirs -v
# 0  ~/projects/database
# 1  ~/projects/backend
# 2  ~/projects/frontend

# Voltar rapidamente
cd -                              # Alterna entre dois últimos diretórios
cd -                              # Volta novamente (toggle)
```

### 1.2 Ferramentas de Navegação Inteligente (Frecency)

Ferramentas baseadas em "frecency" (frequency + recency) aprendem seus padrões de navegação.

#### zsh-z (Recomendado)

```bash
# Instalação com oh-my-zsh
# Adicionar no .zshrc:
plugins=(... zsh-z)

# Instalação manual
git clone https://github.com/agkozak/zsh-z.git
# Adicionar no .zshrc:
source ~/path/to/zsh-z/zsh-z.plugin.zsh

# Uso básico
z projects                        # Pula para diretório mais frequente com "projects"
z web front                       # Múltiplos termos (AND logic)
z -l proj                         # Lista matches sem navegar
z -c projects                     # Pula para subdiretório de projects
z -r proj                         # Match por regex
z -t proj                         # Match por recência (time)

# Exemplos práticos
# Após visitar /home/user/projects/webapp várias vezes:
z web                             # Vai direto para /home/user/projects/webapp
z wa                              # Também funciona (fuzzy match)
z p/w                             # Match hierárquico: projects/webapp

# Combinado com outros comandos
mkdir newproject && z newproject  # Não funciona (precisa visitar primeiro)
cd newproject && z -              # Visita e depois volta com z

# Configurações avançadas no .zshrc
export ZSHZ_DATA="$HOME/.z"                    # Arquivo de dados
export ZSHZ_CASE=smart                         # Case smart (como Vim)
export ZSHZ_UNCOMMON=1                         # Não pula para prefixos comuns
export ZSHZ_TRAILING_SLASH=1                   # Mantém trailing slash
export ZSH_NO_AUTOMATIC_PUSHD=0                # Usa com directory stack
```

#### autojump (Alternativa)

```bash
# Instalação
brew install autojump              # macOS
sudo apt install autojump          # Ubuntu/Debian
sudo pacman -S autojump            # Arch Linux

# Adicionar no .zshrc
[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && source ~/.autojump/etc/profile.d/autojump.sh

# Uso
j projects                         # Pula para diretório
jo projects                        # Abre no file manager (Nautilus, Finder, etc)
jc child                           # Pula para subdiretório do diretório atual
```

#### fasd (Mais Poderoso - Arquivos + Diretórios)

```bash
# Instalação
brew install fasd                  # macOS
sudo apt install fasd              # Ubuntu/Debian

# Adicionar no .zshrc
eval "$(fasd --init auto)"

# Atalhos incluídos
alias a='fasd -a'                  # Any (arquivo ou diretório)
alias s='fasd -si'                 # Show/search/select interativo
alias d='fasd -d'                  # Directory apenas
alias f='fasd -f'                  # File apenas
alias sd='fasd -sid'               # Seleção interativa de diretório
alias sf='fasd -sif'               # Seleção interativa de arquivo
alias z='fasd_cd -d'               # cd para diretório
alias zz='fasd_cd -d -i'           # cd interativo

# Uso prático
z proj                             # Navega para diretório
f config                           # Lista arquivos que contêm "config"
vim `f config`                     # Abre arquivo mais frequente com "config"
cd `d doc`                         # cd para diretório doc mais frequente

# Completions mágicos (zsh only)
vim ,conf<TAB>                     # Completa para arquivos com "conf"
cd ,,d,proj<TAB>                   # Completa para diretórios com "proj"
```

### 1.3 Técnicas de Navegação Nativa do Zsh

#### CDPATH - Diretórios de Busca

```bash
# Define diretórios onde procurar ao usar cd
# Adicionar no .zshrc
cdpath=(
    $HOME
    $HOME/projects
    $HOME/work
    $HOME/Documents
    /usr/local
    /etc
)

# Uso
cd webapp                          # Procura em todos os cdpath automaticamente
# Encontra ~/projects/webapp mesmo estando em outro lugar

# Ver onde foi encontrado
pwd
# /home/user/projects/webapp

# Listar cdpath atual
echo $cdpath
```

#### Named Directories

```bash
# Criar atalhos para diretórios frequentes
# Adicionar no .zshrc
hash -d proj=$HOME/projects
hash -d work=$HOME/work/current
hash -d docs=$HOME/Documents
hash -d conf=$HOME/.config
hash -d log=/var/log

# Uso
cd ~proj                           # Vai para ~/projects
cd ~work                           # Vai para ~/work/current
vim ~conf/zshrc                    # Edita ~/.config/zshrc
tail -f ~log/syslog               # Monitora /var/log/syslog

# Combinado com autocomplete
cd ~<TAB>                          # Lista todos os named directories

# Criar dinamicamente
project=/home/user/project/long/path/to/somewhere
cd ~project                        # Funciona imediatamente (com CDABLE_VARS)
```

---

## 2. Movimentação Avançada em Linha de Comando

### 2.1 Keybindings Essenciais (Modo Emacs)

O Zsh usa o modo Emacs por padrão para edição de linha. Estes são os atalhos mais produtivos:

#### Movimentação de Cursor

```bash
# Movimento horizontal (caractere)
Ctrl+f                             # Forward (frente) um caractere
Ctrl+b                             # Backward (trás) um caractere

# Movimento horizontal (palavra)
Alt+f                              # Forward uma palavra
Alt+b                              # Backward uma palavra
Ctrl+Right                         # Forward uma palavra (terminal dependent)
Ctrl+Left                          # Backward uma palavra (terminal dependent)

# Movimento horizontal (linha)
Ctrl+a                             # Beginning (início) da linha
Ctrl+e                             # End (fim) da linha
Ctrl+xx                            # Toggle entre início e posição atual

# Exemplos práticos
$ sudo apt install nginx<Ctrl+a>   # Cursor vai para início
$ <Alt+f>                          # Pula palavra "sudo"
$ <Alt+f>                          # Pula palavra "apt"
```

#### Deleção e Corte

```bash
# Deleção (não salva no kill ring)
Ctrl+h                             # Delete caractere anterior (backspace)
Ctrl+d                             # Delete caractere atual
Alt+d                              # Delete palavra seguinte
Alt+Backspace                      # Delete palavra anterior
Ctrl+w                             # Delete palavra anterior (word boundary)

# Corte (salva no kill ring - pode colar depois)
Ctrl+k                             # Kill (corta) até fim da linha
Ctrl+u                             # Kill até início da linha
Alt+k                              # Kill até fim da frase
Ctrl+y                             # Yank (cola) último item cortado
Alt+y                              # Yank itens anteriores (após Ctrl+y)

# Exemplos práticos
$ sudo apt install nginx mysql<Ctrl+w>    # Remove "mysql"
$ sudo apt install nginx<Ctrl+k>          # Corta "nginx" (salvo)
$ sudo apt remove <Ctrl+y>                # Cola "nginx" aqui
```

#### Edição Avançada

```bash
# Transformação de texto
Alt+u                              # Uppercase palavra atual
Alt+l                              # Lowercase palavra atual
Alt+c                              # Capitalize palavra atual
Ctrl+t                             # Transpose (troca) últimos 2 caracteres
Alt+t                              # Transpose últimas 2 palavras
Esc+t                              # Transpose palavras (alternativo)

# Undo/Redo
Ctrl+_                             # Undo última edição
Ctrl+x Ctrl+u                      # Undo (alternativo)
Alt+r                              # Revert (desfaz todas mudanças na linha)

# Exemplos
$ mkdri temp<Ctrl+t>               # Corrige para "mkdir temp"
$ cd /TMP/FILES<Alt+l>             # Muda para "/tmp/files"
$ install nginx<Alt+c>             # Capitaliza: "Install nginx"
```

#### Edição em Editor Externo

```bash
# Abrir linha atual em $EDITOR
Ctrl+x Ctrl+e                      # Abre editor (Vim, Emacs, etc)

# Configurar no .zshrc
export EDITOR='vim'
# ou
export EDITOR='nvim'

# Workflow
$ cat longfile.txt | grep pattern | sort | uniq<Ctrl+x Ctrl+e>
# Abre no Vim para editar comando complexo
# Salva e fecha - comando é executado
```

### 2.2 Configuração de Keybindings Customizadas

#### Modo Emacs vs Modo Vi

```bash
# Ver modo atual
bindkey -l                         # Lista keymaps disponíveis
bindkey -M main                    # Mostra bindings do keymap principal

# Escolher modo no .zshrc
bindkey -e                         # Modo Emacs (padrão recomendado)
bindkey -v                         # Modo Vi

# Híbrido: Vi com alguns atalhos Emacs
bindkey -v                         # Ativa modo Vi
bindkey '^A' beginning-of-line     # Mantém Ctrl+a (Emacs)
bindkey '^E' end-of-line           # Mantém Ctrl+e (Emacs)
bindkey '^R' history-incremental-search-backward  # Mantém Ctrl+r
```

#### Bindings Personalizadas

```bash
# Adicionar no .zshrc

# Ctrl+← e Ctrl+→ para movimento por palavra
bindkey '^[[1;5D' backward-word    # Ctrl+Left
bindkey '^[[1;5C' forward-word     # Ctrl+Right

# Alt+← e Alt+→ (alternativo)
bindkey '^[[1;3D' backward-word    # Alt+Left  
bindkey '^[[1;3C' forward-word     # Alt+Right

# Descobrir código de uma tecla
# Execute e pressione a tecla:
cat -v                             # Pressione Enter, depois a tecla, depois Ctrl+D
# ou
read                               # Pressione a tecla, depois Enter

# Exemplo: descobrindo Ctrl+Left
$ cat -v
^[[1;5D                            # Resultado ao pressionar Ctrl+Left

# Criar binding para limpar tela e listar
# Ctrl+l limpa + ls
clear-and-ls() {
  clear
  ls -lah
  zle reset-prompt
}
zle -N clear-and-ls
bindkey '^L' clear-and-ls

# Ctrl+Alt+h mostra ajuda de atalhos
show-shortcuts() {
  echo "\n=== Atalhos Essenciais ==="
  echo "Ctrl+a/e: início/fim linha"
  echo "Alt+f/b: próxima/anterior palavra"  
  echo "Ctrl+k/u: cortar fim/início"
  echo "Ctrl+r: busca histórico"
  zle reset-prompt
}
zle -N show-shortcuts
bindkey '^[^h' show-shortcuts      # Alt+Ctrl+h
```

### 2.3 Autosugestões e Completions

```bash
# Instalar zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Adicionar no .zshrc
plugins=(... zsh-autosuggestions)

# Keybindings para autosugestões
# (configurar no .zshrc após carregar o plugin)
bindkey '^ ' autosuggest-accept        # Ctrl+Space aceita sugestão
bindkey '^]' autosuggest-execute       # Ctrl+] aceita e executa
bindkey '^[f' forward-word             # Alt+f aceita próxima palavra

# Configurações de autosugestão
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'           # Cor cinza
ZSH_AUTOSUGGEST_STRATEGY=(history completion)    # Estratégias de sugestão
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20               # Máximo de caracteres
```

---

## 3. Sistema de Histórico e Expansões

### 3.1 Configuração Otimizada de Histórico

```bash
# Adicionar no .zshrc

# Arquivos e tamanhos
export HISTFILE="$HOME/.zsh_history"    # Onde salvar
export HISTSIZE=50000                    # Linhas em memória
export SAVEHIST=50000                    # Linhas em arquivo

# Opções essenciais
setopt EXTENDED_HISTORY           # Salva timestamp e duração
setopt HIST_EXPIRE_DUPS_FIRST    # Expira duplicatas primeiro
setopt HIST_FIND_NO_DUPS         # Não mostra duplicatas na busca
setopt HIST_IGNORE_ALL_DUPS      # Remove duplicatas antigas
setopt HIST_IGNORE_DUPS          # Não grava duplicatas consecutivas
setopt HIST_IGNORE_SPACE         # Ignora comandos iniciados com espaço
setopt HIST_REDUCE_BLANKS        # Remove espaços em branco extras
setopt HIST_SAVE_NO_DUPS         # Não salva duplicatas
setopt HIST_VERIFY               # Mostra expansão antes de executar
setopt INC_APPEND_HISTORY        # Adiciona imediatamente (não ao fechar)
setopt SHARE_HISTORY             # Compartilha entre sessões

# Opções comportamentais
setopt BANG_HIST                 # Habilita expansão com '!'
setopt HIST_BEEP                 # Beep em erros de histórico

# Formato de timestamp (se EXTENDED_HISTORY ativo)
# : timestamp:segundos;comando
# Exemplo: : 1234567890:5;ls -la
```

### 3.2 Expansões de Histórico (Bang Commands)

#### Expansões Básicas

```bash
# Comando anterior
!!                                # Repete último comando
sudo !!                           # Adiciona sudo ao último comando

# Comando por número
!123                              # Executa comando #123 do histórico
!-2                               # Executa comando 2 posições atrás

# Comando por string
!vim                              # Último comando iniciado com "vim"
!?search                          # Último comando contendo "search"
!?search?                         # Mesmo, mas pode adicionar mais texto depois

# Exemplos práticos
$ cat arquivo.txt                 # Visualiza arquivo
$ !vi                             # Executa último comando com "vi" (se existir)
$ echo "test"
$ sudo !-2                        # sudo no comando 2 atrás (echo "test")
```

#### Seletores de Argumentos

```bash
# Argumentos individuais
!^                                # Primeiro argumento do comando anterior
!$                                # Último argumento do comando anterior
!*                                # Todos argumentos (exceto comando)
!:n                               # Argumento n (0=comando, 1=primeiro arg)

# Exemplos
$ touch file1.txt file2.txt file3.txt
$ ls !^                           # ls file1.txt
$ rm !$                           # rm file3.txt
$ chmod +x !*                     # chmod +x file1.txt file2.txt file3.txt

# Ranges de argumentos
!:1-3                             # Argumentos 1 a 3
!:2-$                             # Argumento 2 até o último
!:2*                              # Argumento 2 até o último (alternativo)
!:2-                              # Argumento 2 até o penúltimo

# Exemplos de ranges
$ echo a b c d e f
$ echo !:2-4                      # echo b c d
$ echo !:3-$                      # echo c d e f
```

#### Modificadores de Expansão

```bash
# :h - head (diretório)
$ cd /usr/local/bin/tool
$ ls !$:h                         # ls /usr/local/bin

# :t - tail (basename)
$ cat /etc/apache2/sites-available/default.conf
$ vim !$:t                        # vim default.conf

# :r - remove extensão
$ cat script.sh
$ vim !$:r.bak                    # vim script.bak

# :e - somente extensão
$ cat arquivo.tar.gz
$ echo !$:e                       # echo gz

# :s/old/new - substituição
$ echo hello world
$ !!:s/hello/goodbye              # echo goodbye world

# :gs/old/new - substituição global
$ echo hello hello world
$ !!:gs/hello/hi                  # echo hi hi world

# Combinando modificadores
$ cat /home/user/docs/file.txt
$ vim !$:h:h                      # vim /home/user (2x head)
$ cp !$:t:r.bak .                 # cp file.bak .

# Atalho rápido ^old^new
$ echo hello world
$ ^hello^goodbye                  # echo goodbye world
$ ^world^universe^:G              # substituição global
```

#### Expansões Avançadas

```bash
# !# - comando atual (parcial)
$ echo hello !#:1                 # echo hello hello

# Múltiplos comandos
$ !-3 && !-2 && !-1               # Executa 3 últimos comandos em sequência

# Em subshells
$ echo "Last command: $(!!)"      # Captura saída do último comando

# Desabilitando expansão temporariamente
$ echo '!!'                       # Não expande (aspas simples)
$ echo "!!"                       # Expande (aspas duplas)
$ echo \!!                        # Não expande (escape)
$ setopt nobanghist               # Desabilita globalmente
$ setopt banghist                 # Reabilita

# Verificar antes de executar (HIST_VERIFY)
$ !!                              # Mostra o comando expandido
$ <Enter>                         # Pressiona Enter novamente para executar
```

### 3.3 Busca de Histórico

```bash
# Busca interativa reversa
Ctrl+r                            # Inicia busca
# Digite termos de busca
# Ctrl+r novamente para resultado anterior
# Ctrl+s para próximo resultado (pode precisar de: stty -ixon)
# Enter para executar
# Ctrl+g ou Esc para cancelar

# Busca de história com fzf (requer instalação)
# Adicionar no .zshrc após instalar fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Agora Ctrl+r usa fzf automaticamente

# Comandos fc (fix command)
fc -l                             # Lista últimos 16 comandos
fc -l -20                         # Lista últimos 20 comandos
fc -l 1                           # Lista desde comando #1
fc -l 100 150                     # Lista comandos 100-150
fc -l vim                         # Lista comandos começando com "vim"

# Editar e executar
fc -e vim                         # Edita último comando no vim
fc -e vim 123                     # Edita comando #123
fc -e nano vim                    # Edita último comando "vim" no nano

# Listar com detalhes
fc -lnd -10                       # Últimos 10 sem números
fc -li 1 5                        # Comandos 1-5 com timestamps
fc -lt                            # Lista com timestamps

# Reexecutar sem editar
fc -e - 123                       # Executa comando #123
fc -e - vim                       # Executa último comando "vim"
```

### 3.4 Widgets Personalizados para Histórico

```bash
# Adicionar no .zshrc

# Busca histórico com pattern matching melhorado
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind nas setas
bindkey '^[[A' up-line-or-beginning-search      # Seta cima
bindkey '^[[B' down-line-or-beginning-search    # Seta baixo

# Agora ao digitar "vim" e pressionar seta cima,
# busca comandos que COMEÇAM com "vim"

# Widget para inserir último argumento múltiplas vezes
bindkey '^[.' insert-last-word                   # Alt+.
bindkey '^[_' insert-last-word                   # Alt+_ (alternativo)

# Uso de Alt+.
$ cat file1.txt
$ vim <Alt+.>                     # Insere "file1.txt"
$ <Alt+.>                         # Volta no histórico de últimos args
$ <Alt+.>                         # Continua voltando...

# Widget para expandir aliases antes de executar
bindkey '^[a' _expand_alias
zle -C _expand_alias complete-word _expand_alias
```

---

## 4. Variáveis e Parâmetros de Comando

### 4.1 Referências a Argumentos Anteriores

```bash
# Último argumento
!$                                # Último argumento do comando anterior
Alt+.                             # Insere último argumento (pode repetir)
Esc+.                             # Alternativo a Alt+.
$_                                # Variável com último argumento

# Exemplos
$ cat /etc/hosts
$ vim !$                          # vim /etc/hosts
$ sudo chmod +x script.sh
$ sudo chown user !$              # sudo chown user script.sh
$ echo "test"
$ echo $_                         # echo test

# Primeiro argumento
!^                                # Primeiro argumento
!:1                               # Alternativo

$ cat file1.txt file2.txt
$ vim !^                          # vim file1.txt

# Todos argumentos
!*                                # Todos exceto comando
!:1-$                             # Todos do 1 ao último

$ echo a b c d
$ printf "%s\n" !*                # printf "%s\n" a b c d

# Argumento específico por índice
!:0                               # O comando em si
!:1                               # Primeiro argumento
!:2                               # Segundo argumento
!:-2                              # Até o segundo argumento

$ touch file1.txt file2.txt file3.txt
$ rm !:2                          # rm file2.txt
```

### 4.2 Variáveis de Saída de Comandos

```bash
# Command substitution - captura saída
output=$(comando)                 # Forma moderna (recomendada)
output=`comando`                  # Forma antiga (backticks)

# Exemplos práticos
current_dir=$(pwd)
echo "Estou em: $current_dir"

# Múltiplas linhas
files=$(ls *.txt)
for file in $files; do
  echo "Processando: $file"
done

# Com pipes
num_users=$(who | wc -l)
echo "Usuários logados: $num_users"

# Comandos complexos
largest_file=$(ls -lh | tail -n +2 | sort -k5 -hr | head -n1 | awk '{print $9}')
echo "Maior arquivo: $largest_file"

# Process substitution (arquivos virtuais)
diff <(ls dir1) <(ls dir2)        # Compara saídas como arquivos
comm <(sort file1) <(sort file2)  # Compara arquivos ordenados

# Captura com array (preserve linhas)
files=($(ls *.txt))
echo "Primeiro arquivo: ${files[1]}"  # Arrays zsh começam em 1
echo "Todos: ${files[@]}"

# Captura stderr separadamente
output=$(comando 2>&1)            # Junta stdout e stderr
output=$(comando 2>/dev/null)     # Descarta stderr
stderr=$(comando 2>&1 >/dev/null) # Captura só stderr
```

### 4.3 Expansões de Parâmetros Avançadas

```bash
# Valores padrão
${var:-default}                   # Usa default se var não existe ou está vazio
${var:=default}                   # Atribui default se var não existe ou está vazio
${var:?erro}                      # Erro se var não existe ou está vazio
${var:+alternative}               # Usa alternative se var existe e não está vazio

# Exemplos
name=${USER:-"guest"}             # Usa "guest" se USER não definido
echo "Olá, $name"

config_file=${1:?"Erro: especifique arquivo de config"}
# Força argumento ou mostra erro

# Comprimento
${#var}                           # Comprimento de string
${#array[@]}                      # Tamanho de array

# Substring
${var:inicio:tamanho}             # Extrai substring

# Exemplos
path="/usr/local/bin/tool"
echo ${path:0:4}                  # /usr
echo ${path:5:5}                  # local
echo ${path: -4}                  # tool (últimos 4 caracteres)

# Substituição de padrões
${var/pattern/replacement}        # Primeira ocorrência
${var//pattern/replacement}       # Todas ocorrências
${var/#pattern/replacement}       # Início da string
${var/%pattern/replacement}       # Fim da string

# Exemplos
filename="backup_old_file.txt"
echo ${filename/old/new}          # backup_new_file.txt
echo ${filename//_/-}             # backup-old-file.txt (primeira)
echo ${filename//_/-}             # backup-old-file.txt (todas)

# Remoção de padrões
${var#pattern}                    # Remove menor match do início
${var##pattern}                   # Remove maior match do início
${var%pattern}                    # Remove menor match do fim
${var%%pattern}                   # Remove maior match do fim

# Exemplos práticos
filepath="/home/user/docs/file.txt"
echo ${filepath##*/}              # file.txt (basename)
echo ${filepath%/*}               # /home/user/docs (dirname)

filename="archive.tar.gz"
echo ${filename%.*}               # archive.tar (remove menor ext)
echo ${filename%%.*}              # archive (remove maior ext)

# Case conversion (Zsh)
${(U)var}                         # Uppercase
${(L)var}                         # Lowercase
${(C)var}                         # Capitalize

# Exemplos
name="joão silva"
echo ${(U)name}                   # JOÃO SILVA
echo ${(C)name}                   # João Silva

# Flags especiais
${(j:,:)array}                    # Join array com vírgula
${(s:,:)string}                   # Split string por vírgula
${(o)array}                       # Ordena array
${(u)array}                       # Remove duplicatas

# Exemplos
files=(file3 file1 file2)
echo ${(j:, :)files}              # file3, file1, file2
echo ${(jo:, :)files}             # file1, file2, file3 (join + order)
```

### 4.4 Arrays e Listas

```bash
# Criação de arrays (Zsh arrays começam em 1, não 0!)
array=(item1 item2 item3)
array=("com espaços" "item 2" "item 3")

# Acesso
echo $array[1]                    # Primeiro elemento
echo $array[-1]                   # Último elemento
echo $array[2,4]                  # Elementos 2-4
echo $array[@]                    # Todos elementos
echo $array[*]                    # Todos elementos (alternativo)

# Tamanho
echo ${#array}                    # Número de elementos
echo ${#array[@]}                 # Alternativo

# Adicionar elementos
array+=(novo_item)                # Adiciona ao fim
array=(novo_inicio $array)        # Adiciona ao início

# Remover elementos
array[2]=()                       # Remove segundo elemento
array=(${array:#pattern})         # Remove elementos que fazem match

# Loops
for item in $array[@]; do
  echo $item
done

# Exemplo prático: processar arquivos
files=(*.txt)
for file in $files[@]; do
  echo "Processando: $file"
  wc -l $file
done

# Array associativo (dicionário)
typeset -A config
config[database]="localhost"
config[port]=5432
config[user]="admin"

echo ${config[database]}          # localhost
echo ${(k)config}                 # Todas as chaves
echo ${(v)config}                 # Todos os valores
echo ${(kv)config}                # Pares chave-valor

# Loop em array associativo
for key val in ${(kv)config}; do
  echo "$key = $val"
done
```

---

## 5. Configuração Otimizada (.zshrc)

### 5.1 Estrutura Recomendada

```bash
# ~/.zshrc - Configuração Otimizada de Zsh

# ============================================================================
# SEÇÃO 1: VARIÁVEIS DE AMBIENTE
# ============================================================================

# Editor padrão
export EDITOR='vim'
export VISUAL='vim'

# Histórico
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

# Path otimizado
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Outros paths importantes
export CDPATH=".:$HOME:$HOME/projects:$HOME/work"

# ============================================================================
# SEÇÃO 2: OPÇÕES DO ZSH
# ============================================================================

# Histórico
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt BANG_HIST

# Directory stack
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_MINUS
export DIRSTACKSIZE=20

# Navegação
setopt AUTO_CD
setopt CDABLE_VARS
setopt AUTO_NAME_DIRS

# Completion
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
unsetopt MENU_COMPLETE

# Globbing
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt NUMERIC_GLOB_SORT

# Input/Output
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt RC_QUOTES

# ============================================================================
# SEÇÃO 3: KEYBINDINGS
# ============================================================================

# Modo Emacs
bindkey -e

# Movimento avançado
bindkey '^[[1;5C' forward-word                    # Ctrl+Right
bindkey '^[[1;5D' backward-word                   # Ctrl+Left
bindkey '^[[H' beginning-of-line                  # Home
bindkey '^[[F' end-of-line                        # End

# Histórico melhorado
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search        # Seta cima
bindkey '^[[B' down-line-or-beginning-search      # Seta baixo

# Edição
bindkey '^[.' insert-last-word                    # Alt+.

# ============================================================================
# SEÇÃO 4: COMPLETION SYSTEM
# ============================================================================

# Inicializar completion
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}     # Cores
zstyle ':completion:*' group-name ''                       # Agrupar
zstyle ':completion:*:descriptions' format '%B%d%b'        # Headers
zstyle ':completion:*:warnings' format 'Nenhum match para: %d'

# Completion para comandos específicos
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:cd:*' ignore-parents parent pwd      # Ignora . e ..

# ============================================================================
# SEÇÃO 5: ALIASES E FUNÇÕES
# ============================================================================

# Aliases básicos
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Aliases de segurança
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Aliases de produtividade
alias h='history'
alias hg='history | grep'
alias j='jobs -l'
alias path='echo $PATH | tr : \\n'
alias duh='du -h --max-depth=1'
alias tree='tree -C'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'

# Named directories
hash -d proj=$HOME/projects
hash -d work=$HOME/work
hash -d docs=$HOME/Documents
hash -d conf=$HOME/.config

# Funções úteis
# Criar diretório e entrar nele
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extrair arquivos compactados
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' não pode ser extraído" ;;
    esac
  else
    echo "'$1' não é um arquivo válido"
  fi
}

# Buscar processo
psg() {
  ps aux | grep -v grep | grep -i -e VSZ -e "$@"
}

# ============================================================================
# SEÇÃO 6: PLUGINS (Oh-My-Zsh ou manual)
# ============================================================================

# Se usar Oh-My-Zsh
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="agnoster"
# plugins=(
#   git
#   zsh-autosuggestions
#   zsh-syntax-highlighting
#   zsh-z
#   docker
#   kubectl
# )
# source $ZSH/oh-my-zsh.sh

# Plugins manuais
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ============================================================================
# SEÇÃO 7: FERRAMENTAS EXTERNAS
# ============================================================================

# FZF (fuzzy finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Zsh-z (directory jumping)
# source ~/path/to/zsh-z.plugin.zsh
# export ZSHZ_CASE=smart

# FASD
# eval "$(fasd --init auto)"

# ============================================================================
# SEÇÃO 8: PROMPT CUSTOMIZADO
# ============================================================================

# Prompt simples e eficiente
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f$ '

# ou use Starship
# eval "$(starship init zsh)"

# ============================================================================
# SEÇÃO 9: CONFIGURAÇÕES ESPECÍFICAS POR MÁQUINA
# ============================================================================

# Carregar configurações locais (não versionadas)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

### 5.2 Plugins Essenciais

```bash
# 1. zsh-autosuggestions - Sugestões baseadas no histórico
# Instalação (Oh-My-Zsh)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Configuração no .zshrc
plugins=(... zsh-autosuggestions)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
bindkey '^ ' autosuggest-accept

# 2. zsh-syntax-highlighting - Syntax highlighting em tempo real
# Instalação (Oh-My-Zsh)
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Deve ser o ÚLTIMO plugin
plugins=(... zsh-syntax-highlighting)

# 3. zsh-z - Directory jumping inteligente
# Já incluído no Oh-My-Zsh
plugins=(... zsh-z)
export ZSHZ_CASE=smart

# 4. fzf - Fuzzy finder universal
# Instalação
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Uso automático com Ctrl+R, Ctrl+T, Alt+C

# 5. zsh-completions - Completions adicionais
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

plugins=(... zsh-completions)
```

---

## 6. Fluxos de Trabalho Práticos

### 6.1 Desenvolvimento de Software

```bash
# Setup inicial do dia
# 1. Entrar no projeto
z myproject                       # Pula para projeto com zsh-z

# 2. Verificar estado
gs                                # git status (alias)
gl -5                             # últimos 5 commits

# 3. Começar feature
git checkout -b feature/new-thing
vim !$:t                          # edita "new-thing" (tail do path)

# Durante desenvolvimento
# Rodar testes rapidamente
npm test
!!                                # Reexecutar testes
sudo !!                           # Com sudo se necessário

# Editar arquivo mencionado em erro
# Error in /src/components/Button.js
vim !$                            # abre o arquivo do erro

# Commitar mudanças
ga .                              # git add all
gc -m "feat: nova funcionalidade"
# Ops, esqueci de adicionar arquivo
ga forgotten.js
gc --amend --no-edit              # Amenda commit

# Deploy
gp origin feature/new-thing
# Ops, precisa force push
git push --force origin !$:t      # usa branch name do comando anterior
```

### 6.2 Administração de Sistemas

```bash
# Navegar entre logs
cd /var/log
tail -f syslog
# Ctrl+c para parar
cd -                              # Volta ao diretório anterior

# Monitorar múltiplos logs
tail -f !$/syslog &
tail -f !$/auth.log &
# !$ expande para /var/log

# Checar configurações
cd /etc/nginx/sites-available
ls
vim default
# Testar config
nginx -t
# Ops, erro na linha X
vim !-2$                          # Volta para vim default

# Aplicar mudanças
sudo systemctl reload nginx
# Esqueceu sudo
sudo !!                           # Repete com sudo

# Backup antes de modificar
cp important.conf !$:r.backup     # important.backup (remove extensão .conf)
```

### 6.3 Processamento de Dados

```bash
# Pipeline complexo com histórico
cat data.csv | grep "pattern" | sort | uniq > result.txt
# Visualizar
less !$

# Modificar pipeline
!ca:s/cat/head -100/              # head -100 data.csv | grep "pattern" | sort | uniq > result.txt

# Salvar pipeline em variável
pipeline="cat data.csv | grep 'pattern' | sort | uniq"
eval $pipeline > output1.txt
# Modificar e usar
eval ${pipeline/pattern/other} > output2.txt

# Comparar resultados
diff output1.txt output2.txt
# Ver só diferenças
!! | grep "^<"
```

### 6.4 Multitarefa e Navegação

```bash
# Workflow típico com múltiplos projetos
cd ~/projects/frontend
npm start &                       # Inicia em background
cd ~/projects/backend
npm run dev &
cd ~/projects/database
docker-compose up &

# Navegar rapidamente
jobs                              # Ver jobs em background
cd ~frontend                      # Named directory
cd ~backend                       # Outro projeto
cd -                              # Toggle entre últimos 2

# Ou com directory stack
dirs -v
# 0  ~/projects/backend
# 1  ~/projects/frontend
# 2  ~/projects/database

cd ~2                             # Vai para database
cd ~1                             # Vai para frontend

# Parar jobs
fg %1                             # Traz job 1 para foreground
Ctrl+c                            # Mata
fg %2                             # Próximo job
Ctrl+c

# Ou matar todos de uma vez
kill %1 %2 %3
```

### 6.5 Busca e Edição em Massa

```bash
# Encontrar e editar arquivos
# Busca arquivos modificados recentemente
files=($(find . -name "*.py" -mtime -7))
echo ${(j:\n:)files}              # Lista um por linha

# Editar todos de uma vez
vim ${files[@]}
# Dentro do Vim: :next, :prev para navegar

# Ou processar um por um
for file in ${files[@]}; do
  echo "Editando: $file"
  vim $file
  read -q "REPLY?Continuar? (y/n) "
  [[ $REPLY == "y" ]] || break
done

# Substituição em massa com sed
# Testar primeiro
for file in *.txt; do
  sed -n 's/old/new/gp' $file
done

# Aplicar mudanças
for file in *.txt; do
  sed -i.bak 's/old/new/g' $file
done

# Verificar mudanças
diff {file.txt,file.txt.bak}
```

---

## 📚 Recursos Adicionais

### Documentação

```bash
# Man pages essenciais
man zshall                        # Documentação completa
man zshbuiltins                   # Built-ins do zsh
man zshexpn                       # Expansões
man zshmisc                       # Miscelânea
man zshoptions                    # Opções
man zshmodules                    # Módulos
man zshcontrib                    # Contribuições

# Help interno
run-help                          # Help de comandos
run-help git                      # Help do git
```

### Prática

```bash
# Desafios diários
# 1. Use apenas atalhos de teclado por 1 dia (sem mouse)
# 2. Tente usar !$ em vez de reescrever paths
# 3. Use z/fasd para navegar (sem cd completo)
# 4. Practice Ctrl+r para buscar histórico
# 5. Use fc para editar comandos complexos

# Checklist de produtividade
# □ Configurou AUTO_PUSHD?
# □ Instalou zsh-z ou fasd?
# □ Configurou keybindings personalizados?
# □ Aprendeu 5 expansões de histórico?
# □ Criou named directories para projetos?
# □ Configurou aliases para comandos frequentes?
# □ Instalou e configurou fzf?
```

### Links Úteis

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Awesome Zsh Plugins](https://github.com/unixorn/awesome-zsh-plugins)
- [Zsh Users Group](https://github.com/zsh-users)

---

## 🎯 Resumo Rápido

**Navegação:**
- `z <termo>` - Pula para diretório frequente
- `cd -` - Alterna entre 2 últimos diretórios
- `cd ~1` - Vai para índice 1 da directory stack
- `dirs -v` - Mostra pilha de diretórios

**Edição de Linha:**
- `Ctrl+a/e` - Início/fim da linha
- `Alt+f/b` - Próxima/anterior palavra
- `Ctrl+k/u` - Corta até fim/início
- `Ctrl+r` - Busca histórico interativa

**Histórico:**
- `!!` - Último comando
- `!$` - Último argumento
- `!*` - Todos argumentos
- `^old^new` - Substitui e reexecuta

**Variáveis:**
- `$_` - Último argumento
- `$(comando)` - Captura saída
- `${var:-default}` - Valor padrão
- `${#var}` - Comprimento

---

**Documento criado em:** 2025-10-16
**Versão:** 1.0
**Focado em:** Zsh produtividade e workflows modernos
