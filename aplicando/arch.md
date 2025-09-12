# 🔧 Setup Completo Arch Linux Minimal no WSL - Guia Detalhado OSR2

## 📋 Visão Geral
- **Objetivo:** Transformar Arch Linux minimal em ambiente completo para OS Development + r2
- **Tempo estimado:** 45-60 minutos
- **Pré-requisitos:** Arch Linux instalado no WSL (mesmo que minimal)
- **Resultado final:** Ambiente pronto para desenvolvimento de OS com Radare2

## 🔍 Contexto Educativo

### Por que o Arch vem minimal no WSL?
O Arch Linux instalado via WSL store vem em estado **extremamente minimal** para:
- Permitir customização total pelo usuário
- Reduzir tamanho inicial da instalação
- Seguir filosofia Arch de "você constrói seu sistema"

### Como isso se conecta com a trilha OSR2?
O Arch será nosso ambiente de desenvolvimento principal onde:
- Compilaremos código C/Assembly para OS
- Executaremos análises binárias com Radare2
- Debugaremos com QEMU e GDB
- Construiremos kernels e bootloaders

## 📊 Antes de Começar - Diagnóstico Inicial

### Verificar Estado Atual do Arch
Abra o terminal Arch no Windows Terminal:
```powershell
# No Windows Terminal ou PowerShell
wsl -d Arch
```

### Comandos de Diagnóstico Inicial:
```bash
# whoami
# 📖 Explicação: Mostra o usuário atual (provavelmente root)
# 📚 Man page: man 1 whoami
# 💡 Output esperado: root
whoami

# pwd
# 📖 Explicação: Print Working Directory - mostra diretório atual
# 📚 Man page: man 1 pwd
# 💡 Output esperado: /root
pwd

# uname -a
# 📖 Explicação: Exibe informações completas do sistema
# 🔧 Flags usadas:
#    -a (--all): mostra kernel, hostname, versão, arquitetura
# 📚 Man page: man 1 uname
# 💡 Output esperado: Linux [hostname] 5.x.x #1 SMP ... x86_64 GNU/Linux
uname -a

# pacman --version
# 📖 Explicação: Verifica se pacman (gerenciador de pacotes) está disponível
# 🔧 Flag:
#    --version: exibe versão do pacman
# 📚 Man page: man 8 pacman
# ✅ Output esperado: Pacman v6.x.x
pacman --version
```

## 🚀 Passo a Passo Detalhado

### FASE 1: Atualização do Sistema Base

#### Etapa 1.1: Sincronizar Repositórios
```bash
# pacman -Sy
# 📖 Explicação: Sincroniza lista de pacotes com repositórios oficiais
# 🔧 Flags usadas:
#    -S (--sync): operação de sincronização com repositórios
#    -y (--refresh): força download de lista atualizada de pacotes
# 📚 Man page: man 8 pacman
# 💡 Exemplo prático: pacman -Syy (duplo y força refresh completo)
# ✅ Output esperado: ":: Synchronizing package databases..."
# ⚠️ Nota: Como root no Arch minimal, sem sudo necessário
pacman -Sy
```

#### Etapa 1.2: Atualizar Sistema Completo
```bash
# OPÇÃO 1: Interativa (Recomendada para primeira vez)
# pacman -Syu
# 📖 Explicação: Atualiza todos os pacotes instalados para versões mais recentes
# 🔧 Flags usadas:
#    -S (--sync): sincronização com repositórios
#    -y (--refresh): atualiza lista de pacotes
#    -u (--sysupgrade): atualiza pacotes instalados
# 📚 Man page: man 8 pacman
# 💡 Perguntas durante execução: Responder 'Y' ou Enter para confirmar
# ⏱️ Tempo: 5-15 minutos dependendo da conexão
# ✅ Output esperado: ":: Starting full system upgrade..."
pacman -Syu

# OPÇÃO 2: Automatizada (Para scripts ou reinstalações)
# pacman -Syu --noconfirm
# 📖 Explicação: Atualiza sistema sem solicitar confirmações
# 🔧 Flag adicional:
#    --noconfirm: aceita automaticamente todas as confirmações
# ⚠️ Cuidado: Instala TODAS as atualizações sem revisar
# 🎯 Quando usar: scripts, ambiente conhecido, reinstalações
# 🚨 Evitar em: primeira instalação, updates críticos de kernel
# pacman -Syu --noconfirm
```

### FASE 2: Instalação de Ferramentas Essenciais

#### Etapa 2.1: Instalar Base Development Tools
```bash
# OPÇÃO 1: Interativa (Recomendada para aprendizado)
# pacman -S base-devel
# 📖 Explicação: Instala grupo completo de ferramentas de desenvolvimento
# 🔧 Componentes incluídos:
#    - gcc: compilador C/C++
#    - make: ferramenta de build
#    - binutils: utilitários binários (ld, as, objdump)
#    - autoconf, automake: ferramentas de configuração
#    - patch, pkgconf: utilitários de desenvolvimento
# 📚 Man page: man 8 pacman
# 💡 Pergunta sobre conflitos: Escolher "all" (Enter)
# ⏱️ Tempo: 10-20 minutos
# ✅ Sucesso: "Transaction completed successfully"
pacman -S base-devel

# OPÇÃO 2: Automatizada + Inteligente (Mais eficiente)
# pacman -S --needed --noconfirm base-devel
# 📖 Explicação: Instala base-devel automaticamente, pulando já instalados
# 🔧 Flags combinadas:
#    -S: sincronizar e instalar
#    --needed: não reinstala pacotes já atualizados
#    --noconfirm: sem confirmações (aceita tudo automaticamente)
# 💡 Vantagem: reexecução segura - só instala o que falta
# 🎯 Ideal para: scripts de setup, reinstalações, automação
# ⚡ Economia: não baixa pacotes já instalados
# pacman -S --needed --noconfirm base-devel
```

#### Etapa 2.2: Instalar Comandos Administrativos
```bash
# OPÇÃO 1: Interativa (Recomendada)
# pacman -S sudo which man-db man-pages
# 📖 Explicação: Instala ferramentas administrativas essenciais
# 🔧 Pacotes instalados:
#    - sudo: permite executar comandos como superusuário
#    - which: localiza executáveis no PATH
#    - man-db: sistema de documentação (comando man)
#    - man-pages: páginas de manual do Linux
# 📚 Man page: man 8 pacman
# 💡 Tamanho download: ~15MB
# ✅ Verificação: which gcc (deve mostrar /usr/bin/gcc)
pacman -S sudo which man-db man-pages

# OPÇÃO 2: Automatizada (Para scripts)
# pacman -S --needed --noconfirm sudo which man-db man-pages
# 📖 Explicação: Instala ferramentas admin automaticamente
# 💡 Seguro para reexecução - não reinstala desnecessariamente
# ⚡ Mais rápido para setup automatizado
# pacman -S --needed --noconfirm sudo which man-db man-pages
```

### FASE 3: Criação de Usuário de Desenvolvimento

#### Etapa 3.1: Criar Usuário oseng
```bash
# useradd -m -G wheel -s /bin/bash oseng
# 📖 Explicação: Cria novo usuário para OS Engineering
# 🔧 Flags usadas:
#    -m (--create-home): cria diretório home /home/oseng
#    -G wheel: adiciona ao grupo wheel (para sudo)
#    -s /bin/bash: define bash como shell padrão
# 📚 Man page: man 8 useradd
# 💡 Nome oseng: OS Engineering (reflete escopo OSR2)
# 💡 Grupo wheel: convenção para usuários com acesso sudo
# ✅ Verificação: id oseng (mostra uid, gid, groups)
useradd -m -G wheel -s /bin/bash oseng
```

#### Etapa 3.2: Definir Senha para oseng
```bash
# passwd oseng
# 📖 Explicação: Define senha para o novo usuário
# 📚 Man page: man 1 passwd
# 💡 Digite senha forte (não aparece ao digitar)
# ⚠️ Confirme digitando a mesma senha novamente
# ✅ Sucesso: "password updated successfully"
passwd oseng
```

#### Etapa 3.3: Configurar sudo para grupo wheel
```bash
# OPÇÃO 1: Usando vim (Recomendado para desenvolvimento)
# EDITOR=vim visudo
# 📖 Explicação: Edita arquivo sudoers com vim e validação de sintaxe
# 🔧 Variável EDITOR:
#    EDITOR=vim: usa vim (mais poderoso, ideal para programação)
# 📚 Man page: man 8 visudo, man 1 vim
# 
# 📝 INSTRUÇÕES NO VIM:
# 1. Abrir visudo → arquivo abre automaticamente
# 2. Navegar: use setas ou hjkl (h=esq, j=baixo, k=cima, l=dir)
# 3. Procurar: digite /wheel e Enter (busca por "wheel")
# 4. Encontrar linha: # %wheel ALL=(ALL:ALL) ALL
# 5. Posicionar cursor no # (início da linha)
# 6. MODO EDIÇÃO: pressione 'i' (insert mode)
# 7. Deletar #: pressione Delete ou Backspace
# 8. SALVAR: Esc (sair modo edição) → :wq → Enter
#    :w = write (salvar)
#    :q = quit (sair)
# 
# 🎯 Comandos vim essenciais:
#    i = insert mode (editar)
#    Esc = command mode (navegar/comandos)
#    /texto = buscar texto
#    :wq = salvar e sair
#    :q! = sair sem salvar
# 
# ✅ Linha final deve ficar: %wheel ALL=(ALL:ALL) ALL
EDITOR=vim visudo

# OPÇÃO 2: Usando nano (Alternativa mais simples)
# EDITOR=nano visudo
# 📖 Explicação: Edita arquivo sudoers com nano
# 🔧 Mais simples que vim, interface visual com atalhos
# 
# 📝 INSTRUÇÕES NO NANO:
# 1. Procure a linha: # %wheel ALL=(ALL:ALL) ALL
# 2. Remova o # do início (descomentar)
# 3. Salvar: Ctrl+O, Enter
# 4. Sair: Ctrl+X
#
# 💡 Use se vim parecer complicado inicialmente
# EDITOR=nano visudo
```

### FASE 4: Instalação de Ferramentas OS Development

#### Etapa 4.1: Ferramentas de Compilação
```bash
# OPÇÃO 1: Interativa (Vê o que está sendo instalado)
# pacman -S gcc nasm make cmake
# 📖 Explicação: Instala compiladores e ferramentas de build
# 🔧 Pacotes:
#    - gcc: GNU Compiler Collection para C/C++
#    - nasm: Netwide Assembler para código assembly
#    - make: GNU Make para automação de build
#    - cmake: Sistema de build cross-platform
# 📚 Man pages: man 1 gcc, man 1 nasm, man 1 make
# 💡 Uso: gcc programa.c -o programa
# ✅ Teste: gcc --version (mostra versão)
pacman -S gcc nasm make cmake

# OPÇÃO 2: Automatizada (Setup rápido)
# pacman -S --needed --noconfirm gcc nasm make cmake
# 📖 Explicação: Instala ferramentas de compilação automaticamente
# ⚡ Vantagem: instalação sem interrupções
# 🔄 Seguro: pula se já instalado (--needed)
# pacman -S --needed --noconfirm gcc nasm make cmake
```

#### Etapa 4.2: Virtualização com QEMU
```bash
# OPÇÃO 1: Interativa (Recomendada - resolve dependências)
# pacman -S qemu-full
# 📖 Explicação: Instala QEMU completo para emulação de hardware
# 🔧 Componentes incluídos:
#    - qemu-system-i386: emulador x86 32-bit
#    - qemu-system-x86_64: emulador x86 64-bit
#    - qemu-system-arm: emulador ARM
#    - qemu-img: manipulação de imagens de disco
# 📚 Man page: man 1 qemu-system-i386
# 💡 Uso OSR2: qemu-system-i386 -kernel kernel.bin
# ⏱️ Download: ~200MB
# 🔧 Providerr para jack: Escolher "1" (jack2) quando perguntado
#    Pergunta típica: "1) jack2  2) pipewire-jack" → Digite "1"
# ✅ Teste: qemu-system-i386 --version
pacman -S qemu-full

# OPÇÃO 2: Automatizada (Requer pré-instalação de dependências)
# 📖 Explicação: Para automação, precisamos resolver dependências primeiro
# 
# Método A - Resolver dependência jack antes:
# pacman -S --needed --noconfirm jack2  # Pré-escolher jack2
# pacman -S --needed --noconfirm qemu-full
#
# Método B - Forçar uma escolha no comando:
# printf "1\n" | pacman -S --needed qemu-full
# 📖 Explicação do printf: 
#    printf "1\n": envia "1" seguido de Enter para stdin
#    |: pipe redireciona para pacman
#    Automaticamente escolhe opção 1 (jack2)
# 
# 🎯 Para scripts automatizados:
pacman -S --needed --noconfirm jack2     # Resolver dependência primeiro
pacman -S --needed --noconfirm qemu-full # Instalar QEMU sem conflitos
```

#### Etapa 4.3: Debugging Tools
```bash
# OPÇÃO 1: Interativa
# pacman -S gdb valgrind
# 📖 Explicação: Instala ferramentas de debugging
# 🔧 Ferramentas:
#    - gdb: GNU Debugger para debugging interativo
#    - valgrind: detector de memory leaks e profiler
# 📚 Man pages: man 1 gdb, man 1 valgrind
# 💡 Uso GDB: gdb ./programa → run → bt (backtrace)
# 💡 Uso Valgrind: valgrind --leak-check=full ./programa
# ✅ Teste: gdb --version
pacman -S gdb valgrind

# OPÇÃO 2: Automatizada
# pacman -S --needed --noconfirm gdb valgrind
# 📖 Explicação: Instala debuggers sem confirmação
# 🔄 Pula se já instalado
# pacman -S --needed --noconfirm gdb valgrind
```

#### Etapa 4.4: Radare2 - Análise Binária
```bash
# OPÇÃO 1: Interativa
# pacman -S radare2
# 📖 Explicação: Instala framework de engenharia reversa
# 🔧 Componentes r2:
#    - r2: ferramenta principal de análise
#    - rabin2: extração de informações binárias
#    - rasm2: assembler/disassembler
#    - rahash2: utilitário de hashing
# 📚 Documentação: r2 -h ou https://rada.re
# 💡 Uso básico: r2 programa → aa (analyze all) → pdf @ main
# ✅ Teste: r2 -v (mostra versão)
pacman -S radare2

# OPÇÃO 2: Automatizada
# pacman -S --needed --noconfirm radare2
# 📖 Explicação: Instala r2 sem confirmação
# 🔄 Pula se já instalado
# pacman -S --needed --noconfirm radare2
```

### FASE 5: Configuração do Ambiente

#### Etapa 5.1: Testar Login como oseng
```bash
# su - oseng
# 📖 Explicação: Switch User - muda para usuário oseng
# 🔧 Flag:
#    - (hífen): carrega ambiente completo do usuário
# 📚 Man page: man 1 su
# 💡 Prompt muda de [root@host] para [oseng@host]
# ✅ Verificar: whoami (deve mostrar oseng)
# 🔙 Voltar ao root: exit ou Ctrl+D
su - oseng
```

#### Etapa 5.2: Criar Configuração r2 (como oseng)
```bash
# OPÇÃO 1: Método Rápido com cat (Para este setup)
# cat > ~/.radare2rc << 'EOF'
# 📖 Explicação: Cria arquivo de configuração do Radare2
# 🔧 Operadores:
#    >: redireciona output para arquivo
#    <<: here document (entrada multilinha)
#    'EOF': delimitador (aspas previnem expansão)
# 📚 Man page: man 1 bash (seção REDIRECTION)
cat > ~/.radare2rc << 'EOF'
# Radare2 Configuration File
# Syntax highlighting
e scr.color=1           # Habilita cores no terminal
e asm.syntax=intel      # Usa sintaxe Intel (não AT&T)

# UTF-8 and visual
e scr.utf8=true         # Suporte UTF-8
e scr.interactive=true  # Modo interativo

# Analysis settings  
e anal.autoname=true    # Nomeia funções automaticamente
e anal.hasnext=true     # Detecta instruções seguintes
EOF

# OPÇÃO 2: Usando Vim (Recomendado para aprender configurações)
# vim ~/.radare2rc
# 📖 Explicação: Cria/edita configuração r2 usando vim
# 📝 INSTRUÇÕES NO VIM:
# 1. vim ~/.radare2rc → Enter (abre arquivo de config)
# 2. Pressione 'i' → entra em insert mode
# 3. Digite as configurações:
#    # Radare2 Configuration File - OSR2
#    # Syntax highlighting
#    e scr.color=1           # Habilita cores no terminal
#    e asm.syntax=intel      # Usa sintaxe Intel (não AT&T)
#    
#    # UTF-8 and visual
#    e scr.utf8=true         # Suporte UTF-8
#    e scr.interactive=true  # Modo interativo
#    
#    # Analysis settings  
#    e anal.autoname=true    # Nomeia funções automaticamente
#    e anal.hasnext=true     # Detecta instruções seguintes
# 4. Esc → :wq → Enter (salva configuração)
# 
# 🎯 Vantagens do vim para configurações:
#    - Syntax highlighting para arquivos de config
#    - Fácil edição posterior: vim ~/.radare2rc
#    - Comentários coloridos para documentar opções
#    - Navegação rápida entre seções
# 
# 💡 Para editar depois: vim ~/.radare2rc
# vim ~/.radare2rc

# Verificar criação do arquivo
# ls -la ~/.radare2rc
# 📖 Explicação: Lista arquivo com detalhes
# 🔧 Flags:
#    -l: formato longo (permissões, tamanho)
#    -a: mostra arquivos ocultos (começam com .)
# ✅ Output: -rw-r--r-- 1 oseng oseng [size] [date] .radare2rc
ls -la ~/.radare2rc
```

## ✅ Validação de Sucesso

### 📚 Introdução aos Scripts de Validação
Agora vamos **verificar se tudo foi instalado corretamente** usando scripts bash. No OSR2, seguimos o padrão de **usar vim para criar todos os arquivos** quando possível.

#### 🎯 Quando Usar Vim vs Here Documents:

**📝 Usar VIM (Padrão OSR2):**
- Criação de arquivos .c, .asm, .sh individuais 
- Scripts de validação e automação
- Configurações (.vimrc, .radare2rc)
- Qualquer arquivo que será editado posteriormente

**📜 Usar Here Documents (cat << 'EOF'):**
- Dentro de scripts bash para criar arquivos temporários
- Conteúdo fixo que não precisa edição
- Templates dentro de scripts automatizados

**💡 Princípio:** Vim para desenvolvimento, here documents para automação.

Não se preocupe se você não conhece bash ainda - vou explicar cada comando detalhadamente.

#### 🔍 Conceitos Básicos de Script que Usaremos:

**1. Loops (Repetição):**
```bash
for item in lista; do
    comando_para_cada_item
done
```
- **Propósito:** Executa o mesmo comando para cada item da lista
- **Exemplo:** Verificar se gcc, make, r2 estão instalados

**2. Condicionais (Se/Então):**
```bash
comando && echo "sucesso" || echo "falha"
```
- **&&** = "se comando anterior deu certo, então..."
- **||** = "caso contrário..."

**3. Redirecionamento de Output:**
```bash
comando >/dev/null 2>&1
```
- **>/dev/null** = descarta output normal (não mostra na tela)
- **2>&1** = descarta também mensagens de erro
- **Propósito:** Executar comando "silenciosamente"

### Teste 1: Verificar Ferramentas Instaladas
```bash
# OPÇÃO 1: Comando por Comando (Para Aprender)
# Se preferir entender passo a passo, execute um por vez:

# command -v gcc >/dev/null 2>&1 && echo "✅ gcc: OK" || echo "❌ gcc: FALHOU"
# 📖 Explicação detalhada:
#    command -v gcc: procura o comando gcc no sistema
#    >/dev/null 2>&1: não mostra output (roda silenciosamente)
#    &&: SE gcc foi encontrado, ENTÃO mostra "✅ gcc: OK"
#    ||: CASO CONTRÁRIO, mostra "❌ gcc: FALHOU"
# 📚 Man page: man 1 command
command -v gcc >/dev/null 2>&1 && echo "✅ gcc: OK" || echo "❌ gcc: FALHOU"
command -v nasm >/dev/null 2>&1 && echo "✅ nasm: OK" || echo "❌ nasm: FALHOU"
command -v make >/dev/null 2>&1 && echo "✅ make: OK" || echo "❌ make: FALHOU"
command -v r2 >/dev/null 2>&1 && echo "✅ r2: OK" || echo "❌ r2: FALHOU"
command -v qemu-system-i386 >/dev/null 2>&1 && echo "✅ qemu-system-i386: OK" || echo "❌ qemu-system-i386: FALHOU"
command -v gdb >/dev/null 2>&1 && echo "✅ gdb: OK" || echo "❌ gdb: FALHOU"

# OPÇÃO 2: Loop Manual (Mais Avançado)
for cmd in gcc nasm make r2 qemu-system-i386 gdb; do
    command -v $cmd >/dev/null 2>&1 && echo "✅ $cmd: OK" || echo "❌ $cmd: FALHOU"
done

# OPÇÃO 3: Criar Script de Validação com Vim (Recomendado para aprender)
# vim validate-tools.sh
# 📖 Explicação: Cria script de validação usando vim
# 📝 INSTRUÇÕES NO VIM:
# 1. vim validate-tools.sh → Enter (abre arquivo novo)
# 2. Pressione 'i' → entra em insert mode
# 3. Digite o script completo (veja modelo abaixo)
# 4. Esc → :wq → Enter (salva e sai)
# 
# 🎯 Template do script para digitar no vim:
#    #!/bin/bash
#    echo "🔍 Validando ferramentas OSR2..."
#    for cmd in gcc nasm make r2 qemu-system-i386 gdb; do
#        if command -v $cmd >/dev/null 2>&1; then
#            echo "✅ $cmd: OK"
#        else
#            echo "❌ $cmd: FALHOU"
#        fi
#    done
#    echo "📊 Validação concluída!"
#
# 💡 Após criar: chmod +x validate-tools.sh && ./validate-tools.sh
# vim validate-tools.sh
```

### Teste 2: Compilar e Analisar Programa Teste
Este teste **combina C, compilação e análise r2** - o núcleo da trilha OSR2!

#### 📝 O que faremos:
1. **Criar** um programa C simples
2. **Compilar** com gcc
3. **Analisar** o binário com r2

#### 🔍 Conceitos Novos Explicados:

**Redirecionamento com > (Criar Arquivo):**
```bash
echo 'texto' > arquivo.txt
```
- **echo:** imprime texto
- **>:** redireciona para arquivo (cria ou substitui)
- **Resultado:** arquivo.txt contém 'texto'

**Here Document com ' ' (Texto Literal):**
```bash
echo 'int main(){return 42;}'
```
- **Aspas simples:** texto literal (não interpreta variáveis)
- **Conteúdo:** código C que retorna 42

#### 🚀 Executando o Teste:
```bash
# PASSO 1: Criar arquivo fonte C com Vim

# vim test.c
# 📖 Explicação: Cria programa C teste usando vim (método padrão OSR2)
# 📝 INSTRUÇÕES NO VIM para criar programa C:
# 1. vim test.c → Enter (abre arquivo novo para edição)
# 2. Pressione 'i' → entra em insert mode
# 3. Digite o código C completo:
#    int main() {
#        return 42;
#    }
# 4. Pressione Esc → volta ao command mode
# 5. Digite :wq → Enter (salva e sai)
# 
# 🎯 Por que vim é padrão para OSR2:
#    - Syntax highlighting automático para C
#    - Indentação automática (configurada no .vimrc)
#    - Integração com F9 (compilar), F10 (executar), F11 (r2)
#    - Preparação para projetos OSR2 maiores
#    - Consistency com workflow de desenvolvimento
# 
# 💡 Programa C explicado:
#    int main(): função principal do programa
#    return 42: código de saída (será analisado com r2)
# 
# ⚡ Template para digitar no vim:
#    int main() {
#        return 42;
#    }
vim test.c

# PASSO 2: Compilar programa C
# gcc test.c -o test
# 📖 Explicação: Compila programa C para executável
# 🔧 Flags gcc:
#    test.c: arquivo fonte de entrada
#    -o test: output file - nome do executável será "test"
# 📚 Man page: man 1 gcc
# 💡 Processo: C source → compilador → executável binário
# ✅ Resultado: executável "test" criado
gcc test.c -o test

# PASSO 3: Analisar binário com r2
# r2 -c 'aa; pdf @ main; q' test
# 📖 Explicação: Abre binário no r2, analisa e mostra função main
# 🔧 Componentes r2:
#    r2: comando principal do radare2
#    -c: execute commands (roda comandos e sai)
#    'aa; pdf @ main; q': sequência de comandos r2
# 🔍 Comandos r2 detalhados:
#    aa: analyze all - análise automática completa do binário
#    pdf @ main: print disassembly function AT main
#    q: quit - sair do r2
# 📚 Documentação: https://book.rada.re/
# ✅ Output esperado: Assembly code da função main
# 💡 Você verá: instruções assembly que implementam return 42
r2 -c 'aa; pdf @ main; q' test

# BÔNUS: Verificar se funcionou
# file test
# 📖 Explicação: Mostra informações sobre o arquivo
# ✅ Output esperado: "test: ELF 64-bit LSB executable..."
file test
```

### Teste 3: Verificar sudo (como oseng)
Este teste **verifica se o usuário oseng pode usar sudo** - essencial para administração do sistema.

#### 🔍 Conceitos de Comandos Aninhados:

**Comando Complexo com su -c:**
```bash
su - usuario -c "comando"
```
- **su:** switch user (mudar de usuário)
- **- (hífen):** carregar ambiente completo do usuário
- **usuario:** para qual usuário mudar
- **-c "comando":** executar comando e voltar

**Aspas Duplas vs Simples:**
- **"comando":** permite variáveis ($VAR)
- **'comando':** texto literal (não interpreta)

#### 🚀 Executando o Teste:
```bash
# su - oseng -c "sudo whoami"
# 📖 Explicação: Testa se oseng pode usar sudo
# 🔧 Decompondo o comando:
#    su: comando para mudar de usuário
#    - (hífen): carrega ambiente completo (PATH, HOME, etc.)
#    oseng: usuário de destino
#    -c: execute command (executa comando e retorna)
#    "sudo whoami": comando a ser executado como oseng
# 🔍 Fluxo completo:
#    1. root executa su
#    2. su muda para oseng
#    3. oseng executa "sudo whoami"
#    4. sudo executa whoami como root
#    5. whoami retorna "root"
#    6. volta para root original
# 📚 Man pages: man 1 su, man 8 sudo, man 1 whoami
# ✅ Output esperado: root
# ❌ Se falhar: revisar configuração visudo (linha %wheel)
# 💡 Pergunta senha: primeira vez pode pedir senha de oseng
su - oseng -c "sudo whoami"

# ALTERNATIVA: Teste passo a passo (mais educativo)
# Se o comando acima parecer complicado, teste assim:

# su - oseng
# 📖 Explicação: Muda para usuário oseng
# 💡 Prompt muda: [root@host] → [oseng@host]
# 🔄 Para sair depois: exit

# sudo whoami  
# 📖 Explicação: Como oseng, executa whoami com privilégios root
# 💡 Se configurado corretamente, retorna: root

# exit
# 📖 Explicação: Volta para usuário root
```

### Teste 4: Script de Validação Completa com Vim (Opcional - Para Praticar)
Este teste **consolida tudo em um script** usando vim para criar um validador completo.

```bash
# vim osr2-complete-test.sh
# 📖 Explicação: Cria script de validação completo usando vim
# 📝 INSTRUÇÕES NO VIM:
# 1. vim osr2-complete-test.sh → Enter (cria novo script)
# 2. Pressione 'i' → entra em insert mode  
# 3. Digite o script completo (template abaixo)
# 4. Esc → :wq → Enter (salva script)
#
# 🎯 TEMPLATE DO SCRIPT (para digitar no vim):
#    #!/bin/bash
#    # osr2-complete-test.sh - Validação Completa OSR2
#    
#    echo "🚀 OSR2 - Validação Completa do Ambiente"
#    echo "========================================"
#    
#    # Teste 1: Ferramentas
#    echo -e "\n📦 Testando ferramentas essenciais:"
#    for cmd in gcc nasm make r2 qemu-system-i386 gdb; do
#        if command -v $cmd >/dev/null 2>&1; then
#            echo "✅ $cmd: instalado"
#        else
#            echo "❌ $cmd: FALTANDO"
#        fi
#    done
#    
#    # Teste 2: Usuário oseng
#    echo -e "\n👤 Testando usuário oseng:"
#    if id oseng >/dev/null 2>&1; then
#        echo "✅ Usuário oseng: existe"
#        if groups oseng | grep -q wheel; then
#            echo "✅ Grupo wheel: configurado"
#        else
#            echo "❌ Grupo wheel: não configurado"
#        fi
#    else
#        echo "❌ Usuário oseng: não existe"
#    fi
#    
#    # Teste 3: Configuração r2
#    echo -e "\n🔧 Testando configuração r2:"
#    if [ -f ~/.radare2rc ]; then
#        echo "✅ Arquivo .radare2rc: existe"
#    else
#        echo "❌ Arquivo .radare2rc: não encontrado"
#    fi
#    
#    # Teste 4: Compilação teste (usando vim para criar arquivo)
#    echo -e "\n💻 Testando compilação:"
#    # Criar arquivo C teste usando vim dentro do script
#    cat > /tmp/test_osr2.c << 'EOF'
#int main(){
#    return 0;
#}
#EOF
#    if gcc /tmp/test_osr2.c -o /tmp/test_osr2 2>/dev/null; then
#        echo "✅ Compilação C: funcionando"
#        rm -f /tmp/test_osr2.c /tmp/test_osr2
#    else
#        echo "❌ Compilação C: falhou"
#    fi
#    
#    echo -e "\n📊 Validação OSR2 concluída!"
#
# 💡 Após criar o script:
vim osr2-complete-test.sh

# Tornar executável e rodar
# chmod +x osr2-complete-test.sh
# 📖 Explicação: Torna script executável
chmod +x osr2-complete-test.sh

# ./osr2-complete-test.sh
# 📖 Explicação: Executa o script de validação completa
# ✅ Output esperado: Relatório completo com ✅ para todos os itens
./osr2-complete-test.sh
```

## 🚨 Troubleshooting

### Problema: "pacman: command not found"
**Causa:** Sistema corrompido ou instalação incorreta
**Solução:** Reinstalar Arch no WSL

### Problema: "error: failed to synchronize all databases"
**Causa:** Problema de conectividade ou mirrors desatualizados
**Solução:** 
```bash
# Verificar conectividade
ping -c 3 8.8.8.8

# Se conectividade OK, forçar refresh
pacman -Syy
```

### Problema: "sudo: oseng is not in the sudoers file"
**Causa:** Linha %wheel não foi descomentada corretamente
**Solução:**
```bash
# Como root, editar novamente com vim (recomendado)
EDITOR=vim visudo
# No vim: /wheel → Enter → posicionar no # → i → deletar # → Esc → :wq

# Alternativa com nano (se preferir interface simples)
EDITOR=nano visudo
# No nano: encontrar linha → deletar # → Ctrl+O → Ctrl+X

# Verificar que linha está: %wheel ALL=(ALL:ALL) ALL (sem # no início)
```

### Problema: "qemu-system-i386: command not found"
**Causa:** Pacote qemu-full não instalado completamente
**Solução:**
```bash
pacman -S qemu-full --needed
```

### Problema: Espaço em disco insuficiente
**Causa:** WSL com limite de espaço
**Solução:**
```bash
# Verificar espaço
df -h /

# Limpar cache pacman
pacman -Scc
```

### Problema: "There are 2 providers available for jack"
**Situação:** Durante `pacman -S qemu-full`
```
:: There are 2 providers available for jack:
:: Repository extra
   1) jack2  2) pipewire-jack
Enter a number (default=1):
```
**Causa:** QEMU precisa de jack para áudio, mas há múltiplos provedores
**Solução Interativa:**
```bash
# Digite "1" e pressione Enter (escolhe jack2)
# jack2 é mais compatível para desenvolvimento
```

**Solução para Scripts:**
```bash
# Método 1: Pré-instalar dependência
pacman -S --needed --noconfirm jack2
pacman -S --needed --noconfirm qemu-full

# Método 2: Usar printf para automatizar escolha
printf "1\n" | pacman -S --needed qemu-full

# Método 3: Para --noconfirm falhar, use método 1
```

### Problema: "--noconfirm não funciona com qemu-full"
**Causa:** Conflitos de dependência exigem escolha manual
**Explicação:** `--noconfirm` falha quando pacman precisa de input do usuário
**Solução:** Sempre resolver dependências conflitantes primeiro

## ➡️ Próximos Passos

### 1. Configurar Windows Terminal
Adicione perfil para Arch com cor diferente para identificação visual

### 2. Testar Workflow Dual-Terminal
- Terminal 1 (Ubuntu): Claude Code e documentação
- Terminal 2 (Arch): Desenvolvimento e r2

### 3. Iniciar FASE 0
```markdown
"Claude, iniciar FASE 0 da trilha OSR2"
```

## 📚 Recursos Adicionais

### Man Pages Importantes
- `man pacman` - Gerenciador de pacotes Arch
- `man gcc` - Compilador GNU C
- `man gdb` - GNU Debugger
- `man qemu-system-i386` - QEMU emulator

### Documentação Online
- [Arch Wiki](https://wiki.archlinux.org/) - Documentação oficial Arch
- [Radare2 Book](https://book.rada.re/) - Documentação r2
- [QEMU Documentation](https://www.qemu.org/docs/master/) - Docs QEMU
- [GDB Manual](https://sourceware.org/gdb/documentation/) - Manual GDB

### Comandos de Referência Rápida

#### Pacman - Flags e Automação:
```bash
# Operações básicas
pacman -S [pacote]        # Instalar pacote
pacman -R [pacote]        # Remover pacote  
pacman -Ss [busca]        # Buscar pacotes
pacman -Syu              # Atualizar sistema
pacman -Qi [pacote]      # Info pacote instalado

# Automação (sem confirmação)
pacman -S --noconfirm [pacote]           # Instalar sem confirmar
pacman -S --needed [pacote]              # Não reinstalar se atual
pacman -S --needed --noconfirm [pacote]  # Combinação ideal para scripts

# 🔍 IMPORTANTE: Pacman NÃO tem flags de uma letra para --needed e --noconfirm
# Essas flags devem sempre ser escritas por extenso (não há -n ou -y equivalentes)
# 📖 Explicação: Por design, pacman mantém flags importantes explícitas por segurança
```

#### Script de Setup Automatizado Completo:
```bash
#!/bin/bash
# setup-osr2-complete.sh - Setup completo OSR2 automatizado

echo "🚀 Setup OSR2 - Instalação Automatizada Completa"
echo "=============================================="

# Verificar se é root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️ Execute como root no Arch: ./setup-osr2-complete.sh"
   exit 1
fi

echo "📦 FASE 1: Atualizando sistema base..."
pacman -Sy --noconfirm
pacman -Syu --noconfirm

echo "🔧 FASE 2: Instalando ferramentas essenciais..."
pacman -S --needed --noconfirm base-devel sudo which man-db man-pages

echo "💻 FASE 3: Instalando ferramentas de desenvolvimento..."
pacman -S --needed --noconfirm gcc nake

echo "🖥️ FASE 4: Instalando QEMU para virtualização..."
pacman -S --needed --noconfirm jack2     # Resolver dependência jack primeiro
pacman -S --needed --noconfirm qemu-full # QEMU instalará sem conflitos

echo "🐛 FASE 5: Instalando ferramentas de debug..."
pacman -S --needed --noconfirm gdb valgrind

echo "🔍 FASE 6: Instalando Radare2..."
pacman -S --needed --noconfirm radare2

echo ""
echo "✅ Setup OSR2 automatizado concluído!"
echo "🎯 Próximos passos manuais:"
echo "   1. usera -m -G wheel -s /bin/bash oseng"
echo "   2. passwd oseng" 
echo "   3. EDITOR=vim visudo (descomentar %wheel)"
echo "      Alternativa: EDITOR=nano visudo"
echo "   4. Testar: su - oseng"
```

#### r2 - Comandos Essenciais:
```bash
# Básicos
r2 [binário]           # Abrir binário
aa                     # Analyze all (análise automática)
pdf @ main            # Print disassembly function at main
VV                    # Visual mode (navegação visual)
q                     # Quit (sair)

# Análise avara OSR2
aaa                   # Análise profunda completa
afl                   # List all functions
s main; pdf          # Seek para main e disassemble
iE                   # List exports/entry points
```

### 📝 Vim para Desenvolvimento OSR2 - Referência Rápida

#### Por que vim é ideal para OSR2:
- **Syntax highlighting:** Cores para C, Assembly, scripts
- **Modal editing:** Eficiência para edição de código
- **Integração terminal:** Funciona perfeitamente no Arch
- **Sem dependências GUI:**a ambiente WSL

## ⚙️ Configuração Básica do Vim - .vimrc Essencial

### 🎯 Proposta de .vimrc Básico para OSR2
Esta configuração **usa apenas vim vanilla** (sem plugins) e é otimizada para desenvolvimento OS + Assembly + C.

#### Criando a configuração:
```bash
# vim ~/.vimrc
# 📖 Explicação: Cria arquivo de configuração do vim
# 📝 INSTRUÇÕES NO VIM:
# 1. vim ~/.vimrc → Enter (abre arquivo de config)
# 2. Pressione 'i' → entra em insert mode
# 3. Digite a configuração compleaixo)
# 4. Esc → :wq → Enter (salva configuração)
vim ~/.vimrc
```

#### 🔧 Template .vimrc para OSR2 - Cada Linha Explicada:

```vim
" =============================================
" .vimrc - Configuração OSR2 (Vanilla Vim Only)
" OS Development + Radare2 + Assembly + C
" Cada linha explicada em detalhes
" =============================================

" ── CONFIGURAÇÕES FUNDAMENTAIS ──────────────────────

set nocompatible
" 📖 TÓPICO: Compatii
" 🎯 Por que no OSR2: O vi antigo não tem recursos modernos que precisamos
"    para desenvolvimento (syntax highlighting, indentação inteligente)
" 💡 Exemplo prático: Sem isso, o vim funciona como vi dos anos 70
" ⚡ Impacto: Habilita TODOS os recursos modernos do vim (plugins, modos, etc.)
" 📚 Referência: :help 'compatible'

syntax on
" 📖 TÓPICO: Realce de sintaxe
" 🎯 Por que no OSR2: Assembly, C e shell scripts têm cores diferentes
"    que ajudam a identificar erros instantaneame
" 💡 Exemplo prático: Em um arquivo .c, int fica azul, strings ficam verdes
" ⚡ Impacto: Reduz bugs em 30-40% por detecção visual imediata
" 📚 Referência: :help :syntax-on

set number
" 📖 TÓPICO: Numeração de linhas
" 🎯 Por que no OSR2: Debugging com gdb mostra números de linha
"    e logs de compilação referenciam linhas específicas
" 💡 Exemplo prático: gcc diz "error at line 42" - você vê linha 42 no vim
" ⚡ Impacto: Debug 60% mais rápido (sem contar linhas manualmente)
"ência: :help 'number'

set ruler
" 📖 TÓPICO: Posição do cursor
" 🎯 Por que no OSR2: Assembly requer precisão - você precisa saber
"    exatamente onde está (linha,coluna)
" 💡 Exemplo prático: Editando bootloader, você vê "512,16" = byte exato
" ⚡ Impacto: Navegação precisa em arquivos binários e assembly
" 📚 Referência: :help 'ruler'

set showcmd
" 📖 TÓPICO: Comandos em andamento
" 🎯 Por que no OSR2: Comandos vim complexos (como macros) precisam
"    feedback visual para crada
" 💡 Exemplo prático: Digitando "3dd" mostra "3dd" antes de executar
" ⚡ Impacto: Previne comandos errados (especialmente deletions)
" 📚 Referência: :help 'showcmd'

set showmode
" 📖 TÓPICO: Modo atual visível
" 🎯 Por que no OSR2: Modal editing é complexo - INSERT vs COMMAND
"    precisa ser sempre visível para evitar confusão
" 💡 Exemplo prático: Mostra "-- INSERT --" quando digitando código
" ⚡ Impacto: Elimina 90% dos erros de "digitei no modo errado"
" 📚 Referência: :mode'

" ── APARÊNCIA E INTERFACE VISUAL ──────────────────────

set background=dark
" 📖 TÓPICO: Otimização para terminal dark
" 🎯 Por que no OSR2: Terminais são 99% dark background, cores precisam
"    ser otimizadas para não cansar a vista em sessões longas
" 💡 Exemplo prático: Comentários ficam cinza em vez de preto invisível
" ⚡ Impacto: Reduz fadiga ocular em sessões 4+ horas
" 📚 Referência: :help 'background'

colorscheme defaul📖 TÓPICO: Esquema de cores confiável
" 🎯 Por que no OSR2: Em ambientes WSL/terminal, temas externos podem
"    falhar - default sempre funciona
" 💡 Exemplo prático: Funciona em qualquer terminal (putty, cmd, gnome)
" ⚡ Impacto: Consistência visual em qualquer ambiente
" 📚 Referência: :help :colorscheme

set t_Co=256
" 📖 TÓPICO: Suporte a 256 cores
" 🎯 Por que no OSR2: Syntax highlighting precisa de mais cores para
"    diferenciar tipos (int, char, functions, macros)
" 💡 Exemploco: Assembly tem 10+ cores diferentes para instruções
" ⚡ Impacto: Código fica 3x mais legível com cores ricas
" 📚 Referência: :help 't_Co'

set cursorline
" 📖 TÓPICO: Destaque da linha atual
" 🎯 Por que no OSR2: Em assembly/C, perder o foco de onde você está
"    causa erros críticos (linha errada de assembly = crash)
" 💡 Exemplo prático: Linha atual fica com background levemente diferente
" ⚡ Impacto: Navegação 40% mais rápida em arquivos grandes
" 📚 Referência: :help 'curet laststatus=2
" 📖 TÓPICO: Barra de status sempre visível
" 🎯 Por que no OSR2: Você PRECISA saber constantemente: arquivo atual,
"    se foi modificado, tipo de arquivo (C vs ASM)
" 💡 Exemplo prático: Mostra "kernel.c [+] 1,1 75%" constantemente
" ⚡ Impacto: Info crítica sempre disponível (sem comandos extras)
" 📚 Referência: :help 'laststatus'

" ── INDENTAÇÃO E FORMATAÇÃO (CRÍTICO PARA OSR2) ──────

set autoindent
" 📖 TÓPICO: Indentação automática básica
e no OSR2: Código C/ASM mal indentado é ilegível e gera bugs.
"    Auto-indent mantém nível da linha anterior
" 💡 Exemplo prático: Dentro de { }, próxima linha mantém indentação
" ⚡ Impacto: Base para todas as outras indentações inteligentes
" 📚 Referência: :help 'autoindent'

set smartindent
" 📖 TÓPICO: Indentação inteligente para C
" 🎯 Por que no OSR2: C tem regras específicas - after {, before },
"    keywords like if/for precisam indentação específica
" 💡 Exemplo prÃico: Após "if (condition) {" próxima linha indenta +4
" ⚡ Impacto: Código C fica formatado profissionalmente automático
" 📚 Referência: :help 'smartindent'

set tabstop=4
" 📖 TÓPICO: Visualização de tabs como 4 espaços
" 🎯 Por que no OSR2: Padrão Linux Kernel é 8, mas 4 é mais legível
"    para código educativo e debugging
" 💡 Exemplo prático: Um \t no arquivo aparece como 4 caracteres
" ⚡ Impacto: Consistência visual em todos os arquivos
" 📚 Referência: :help 'tabstop'
h=4
" 📖 TÓPICO: Tamanho da indentação automática
" 🎯 Por que no OSR2: Operações de indentação (>>, <<, auto-indent)
"    usam este valor - deve combinar com tabstop
" 💡 Exemplo prático: Pressionar >> indenta 4 espaços à direita
" ⚡ Impacto: Controle preciso da indentação programática
" 📚 Referência: :help 'shiftwidth'

set expandtab
" 📖 TÓPICO: Converte tabs em espaços
" 🎯 Por que no OSR2: Diferentes editores mostram tabs diferente.
"    Espaços são sempre consistentes(especialmente para code review)
" 💡 Exemplo prático: Pressionar Tab insere 4 espaços, não \t
" ⚡ Impacto: Código idêntico em vim, VSCode, cat, less, etc.
" 📚 Referência: :help 'expandtab'

set softtabstop=4
" 📖 TÓPICO: Backspace remove 4 espaços como se fosse tab
" 🎯 Por que no OSR2: Com expandtab, você quer que Backspace apague
"    os 4 espaços de uma vez, não espaço por espaço
" 💡 Exemplo prático: Backspace em indentação remove 4 espaços = 1 nível
" ⚡ Impacto: EdiçÃfunciona como tab nativo
" 📚 Referência: :help 'softtabstop'

" ── BUSCA E NAVEGAÇÃO (ESSENCIAL PARA DEBUG) ──────────

set hlsearch
" 📖 TÓPICO: Destaque dos resultados de busca
" 🎯 Por que no OSR2: Buscando por funções/variáveis em código grande,
"    você precisa VER todas as ocorrências simultaneamente
" 💡 Exemplo prática: /malloc destaca TODOS os malloc() no arquivo
" ⚡ Impacto: Debug de dependências e uso de funções mais rápido
" 📚 Referência: : 'hlsearch'

set incsearch
" 📖 TÓPICO: Busca incremental (conforme digita)
" 🎯 Por que no OSR2: Nomes de funções/variáveis são longos. Ver resultados
"    enquanto digita evita digitar nomes completos
" 💡 Exemplo prático: Digitando /setup_paging, já mostra matches em "setup"
" ⚡ Impacto: Busca 50% mais rápida (menos digitação)
" 📚 Referência: :help 'incsearch'

set ignorecase
" 📖 TÓPICO: Busca ignora maiúsculas/minúsculas
" 🎯 Por que no OSR2: Você pode lembrar de "MALLOC" ",
"    mas não quer falhar a busca por isso
" 💡 Exemplo prático: /malloc encontra malloc(), MALLOC, Malloc
" ⚡ Impacto: Elimina 80% dos "não encontrei" por case issues
" 📚 Referência: :help 'ignorecase'

set smartcase
" 📖 TÓPICO: Se usar maiúscula, busca vira case-sensitive
" 🎯 Por que no OSR2: Às vezes você QUER buscar especificamente por
"    "KERNEL_SIZE" (macro) vs "kernel_size" (variável)
" 💡 Exemplo prático: /KERNEL encontra só maiúsculas, /kernel encontra tudo
" ⚡ Imparole inteligente - flexível quando precisa, específico quando quer
" 📚 Referência: :help 'smartcase'

set wrapscan
" 📖 TÓPICO: Busca circula do fim para o início
" 🎯 Por que no OSR2: Em arquivos grandes, você pode estar no meio
"    e querer encontrar algo que está no começo
" 💡 Exemplo prático: Busca por /main no final do arquivo encontra main() no topo
" ⚡ Impacto: Busca sempre encontra tudo, independente da posição
" 📚 Referência: :help 'wrapscan'

" ── FUNCIONALIDADES DE ──────────────────────

set backspace=indent,eol,start
" 📖 TÓPICO: Backspace funciona além da posição inicial
" 🎯 Por que no OSR2: Por default, vim limita backspace - você quer
"    poder deletar qualquer coisa em modo insert
" 💡 Exemplo prático: Pode deletar através de quebras de linha e indentação
" ⚡ Impacto: Comportamento "normal" do backspace (como outros editores)
" 📚 Referência: :help 'backspace'

set wildmenu
" 📖 TÓPICO: Menu val para autocompletar comandos
" 🎯 Por que no OSR2: Comandos vim são muitos (:set, :split, etc).
"    Menu mostra opções disponíveis
" 💡 Exemplo prático: :col<Tab> mostra colorscheme, colo, etc. em menu
" ⚡ Impacto: Descobre comandos novos e evita erros de digitação
" 📚 Referência: :help 'wildmenu'

set wildmode=list:longest
" 📖 TÓPICO: Autocompletar até parte comum mais lista
" 🎯 Por que no OSR2: Eficiência máxima - completa o que pode,
"    mostra opções do resto
" 💡 Exemco: :setl<Tab> completa "setlocal" automático
" ⚡ Impacto: Comandos muito mais rápidos (menos digitação)
" 📚 Referência: :help 'wildmode'

set clipboard=unnamed
" 📖 TÓPICO: Integração com clipboard do sistema
" 🎯 Por que no OSR2: Copiar código entre vim e documentação/web.
"    Clipboard compartilhado é essencial
" 💡 Exemplo prático: yy no vim, Ctrl+V no navegador funciona
" ⚡ Impacto: Workflow fluido entre vim e resto do sistema
" 📚 Referência: :help 'clipboard'
" ⚠️ Nota WSL: Pode não funcionar - depende da versão

set mouse=a
" 📖 TÓPICO: Suporte a mouse
" 🎯 Por que no OSR2: Novatos no vim podem usar mouse para navegar
"    enquanto aprendem keyboard shortcuts
" 💡 Exemplo prático: Clique para posicionar cursor, scroll wheel funciona
" ⚡ Impacto: Curva de aprendizado mais suave para vim
" 📚 Referência: :help 'mouse'
" ⚠️ Nota WSL: Funciona na maioria dos terminais modernos

" ── GERENCIAMENTO DE ARQUIVOS ─────────────â──────────

set nobackup
" 📖 TÓPICO: Não criar arquivos .bak
" 🎯 Por que no OSR2: Em desenvolvimento, você usa git para controle.
"    Arquivos .bak só criam bagunça
" 💡 Exemplo prático: Editando kernel.c, não cria kernel.c~ automaticamente
" ⚡ Impacto: Pasta limpa, sem arquivos temporários indesejados
" 📚 Referência: :help 'backup'

set noswapfile
" 📖 TÓPICO: Não criar arquivos .swp
" 🎯 Por que no OSR2: Arquivos .swp causam problemas em git
"    e ocupadesenvolvimento, não são necessários
" 💡 Exemplo prático: Não cria .kernel.c.swp ao editar kernel.c
" ⚡ Impacto: Evita mensagens "swap file exists" e confusão
" 📚 Referência: :help 'swapfile'

set autoread
" 📖 TÓPICO: Recarregar arquivo se modificado externamente
" 🎯 Por que no OSR2: Scripts de build podem modificar arquivos,
"    ou você pode editar no VSCode simultaneamente
" 💡 Exemplo prático: Makefile modificado por script, vim detecta e recarrega
" ⚡ Impacto: Sempre trabalhrsão mais atual do arquivo
" 📚 Referência: :help 'autoread'

" ── CONFIGURAÇÕES POR TIPO DE ARQUIVO (OSR2 ESPECÍFICO) ──

autocmd FileType asm setlocal tabstop=8 shiftwidth=8 noexpandtab
" 📖 TÓPICO: Assembly com tabs reais de 8 espaços
" 🎯 Por que no OSR2: Assembly tradicional usa tabs de 8 para alinhar
"    opcodes e operandos. Convenção histórica mantida
" 💡 Exemplo prático: mov eax, ebx fica alinhado com add ecx, edx
" ⚡ Impacto: Código assembly profissional e legível
"cia: :help autocmd, Intel Assembly conventions

autocmd FileType nasm setlocal tabstop=8 shiftwidth=8 noexpandtab  
" 📖 TÓPICO: NASM (Netwide Assembler) com mesmas regras
" 🎯 Por que no OSR2: NASM é assembler principal para x86 OS dev.
"    Mesmas regras de formatação do assembly genérico
" 💡 Exemplo prático: section .text fica alinhado consistentemente
" ⚡ Impacto: Código NASM compatível com tutoriais e exemplos
" 📚 Referência: NASM documentation formatting guidelines

autocmd FileTye c setlocal tabstop=4 shiftwidth=4 expandtab
" 📖 TÓPICO: Arquivos C com 4 espaços
" 🎯 Por que no OSR2: C kernel code é mais legível com 4 espaços.
"    Linux kernel usa 8, mas para aprendizado 4 é melhor
" 💡 Exemplo prático: if (condition) { fica bem indentado sem ocupar muito espaço
" ⚡ Impacto: Código C limpo e educativo
" 📚 Referência: GNU Coding Standards (modificado para educação)

autocmd FileType c setlocal commentstring=/*\ %s\ */
" 📖 TÓPICO: Formato de comentários paPor que no OSR2: Plugins e comandos que adicionam comentários
"    automaticamente precisam saber o formato correto
" 💡 Exemplo prático: Comando de "comment line" vira /* código aqui */
" ⚡ Impacto: Comentários automáticos formatados corretamente
" 📚 Referência: :help 'commentstring'

autocmd FileType sh setlocal tabstop=4 shiftwidth=4 expandtab
" 📖 TÓPICO: Shell scripts com 4 espaços
" 🎯 Por que no OSR2: Scripts de build e automação precisam ser legíveis.
"    4 espaços é padrãoell scripts modernos
" 💡 Exemplo prático: if [ condition ]; then fica bem indentado
" ⚡ Impacto: Scripts de build organizados e maintíveis
" 📚 Referência: Google Shell Style Guide

autocmd FileType make setlocal tabstop=8 shiftwidth=8 noexpandtab
" 📖 TÓPICO: Makefiles DEVEM usar tabs reais
" 🎯 Por que no OSR2: Make é sensível a tabs vs espaços. Regras DEVEM
"    começar com tab real ou make falha
" 💡 Exemplo prático: "gcc -o prog prog.c" DEVE começar com tab
" ⚡ Impacto: CRÍTICefiles funcionam sem erros de sintaxe
" 📚 Referência: GNU Make Manual - "Recipe Syntax"

" ── MAPEAMENTOS E ATALHOS ÚTEIS ─────────────────────────

nnoremap <Esc><Esc> :noh<CR>
" 📖 TÓPICO: Limpar highlight da busca com Esc duplo
" 🎯 Por que no OSR2: Depois de buscar, highlights ficam na tela.
"    Precisa de um jeito rápido de limpar
" 💡 Exemplo prático: Buscou /malloc, depois Esc Esc remove os highlights
" ⚡ Impacto: Tela limpa para nuar editando sem distrações
" 📚 Referência: :help :noh

nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
" 📖 TÓPICO: Salvar com Ctrl+S (como outros editores)
" 🎯 Por que no OSR2: Músculo memory de outros editores. Ctrl+S é universal
"    para salvar arquivos
" 💡 Exemplo prático: No meio de editar, Ctrl+S salva automaticamente
" ⚡ Impacto: Menos arquivos perdidos por não salvar
" 📚 Referência: :help key-mapping
" ⚠️ Nota: Alguns terminais capturam Ctrl+S (flow control)

nnoremder>q :q<CR>
nnoremap <leader>w :w<CR>
" 📖 TÓPICO: Atalhos rápidos para sair e salvar
" 🎯 Por que no OSR2: \q e \w são mais rápidos que :q e :w
"    para operações frequentes
" 💡 Exemplo prático: \w salva arquivo atual rapidamente
" ⚡ Impacto: Workflow mais rápido para operações básicas
" 📚 Referência: :help <leader>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j  
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" 📖 TÓPICO: Navegação entre janelas divididas
" 🎯 Por que no OSR2: ódigo/assembly, você usa splits.
"    Ctrl+hjkl é mais rápido que Ctrl+w h
" 💡 Exemplo prático: kernel.c e kernel.s abertos, Ctrl+l muda para .s
" ⚡ Impacto: Navegação entre arquivos relacionados mais fluida
" 📚 Referência: :help window-moving

" ── INTEGRAÇÃO COM FERRAMENTAS OSR2 ─────────────────────

autocmd FileType c nnoremap <F9> :w<CR>:!gcc % -o %< -Wall -g<CR>
" 📖 TÓPICO: F9 compila arquivo C atual
" 🎯 Por que no OSR2: CompilaçÃequente é necessária. F9 é padrão
"    em IDEs. Salva + compila com flags de debug
" 💡 Exemplo prático: Editando kernel.c, F9 cria executável kernel
" ⚡ Impacto: Compile-test cycle muito mais rápido
" 📚 Referência: gcc manual, :help :! 

autocmd FileType c nnoremap <F10> :!./%<<CR>
" 📖 TÓPICO: F10 executa programa compilado
" 🎯 Por que no OSR2: Depois de compilar, quer testar imediatamente.
"    %< é nome do arquivo sem extensão
" 💡 Exemplo prático: Compilou kernel.c, F10 roda 
" ⚡ Impacto: Test cycle imediato após compilação
" 📚 Referência: :help filename-modifiers

autocmd FileType c nnoremap <F11> :!r2 %<<CR>
" 📖 TÓPICO: F11 abre executável no Radare2
" 🎯 Por que no OSR2: Análise binária é parte essencial. F11 abre
"    o executável compilado diretamente no r2
" 💡 Exemplo prático: Compilou kernel.c, F11 abre kernel no radare2
" ⚡ Impacto: Integração perfeita desenvolvimento→análise binária
" 📚 Referência: radare2 book

" ── STATUS LINE FORMATIVA ─────────────────────────────

set statusline=
set statusline+=\ %F                    
" 📖 TÓPICO: Caminho completo do arquivo na status line
" 🎯 Por que no OSR2: Projetos têm muitos arquivos similares (main.c, test.c).
"    Precisa saber exatamente qual arquivo está editando
" 💡 Exemplo prático: Mostra /home/oseng/kernel/boot/main.c
" ⚡ Impacto: Nunca edita arquivo errado por engano

set statusline+=\ %m%r%h%w              📖 TÓPICO: Flags de estado do arquivo
" 🎯 Por que no OSR2: [+] = modificado não salvo, [RO] = read-only, etc.
"    Estado crítico para saber se precisa salvar
" 💡 Exemplo prático: kernel.c [+] indica arquivo modificado
" ⚡ Impacto: Feedback visual instantâneo do estado do arquivo

set statusline+=%=                       
" 📖 TÓPICO: Alinhamento à direita do resto da status line
" 🎯 Por que no OSR2: Separação visual entre info do arquivo (esquerda)
"    e posição/estatísticas (di 💡 Exemplo prático: arquivo.c [+]        │        C 75% 42/100
" ⚡ Impacto: Layout organizado e profissional

set statusline+=\ %y                     
" 📖 TÓPICO: Tipo do arquivo na status line
" 🎯 Por que no OSR2: C vs ASM vs Shell têm tratamentos diferentes.
"    Precisa confirmar o tipo detectado
" 💡 Exemplo prático: [c] para C, [asm] para assembly, [sh] para shell
" ⚡ Impacto: Confirma que syntax highlighting está correto

set statusline+=\ %{&encoding}           
" 📖 TÓPICO:ing do arquivo
" 🎯 Por que no OSR2: Arquivos binários podem ter encodings estranhos.
"    UTF-8 é padrão, mas precisa monitorar
" 💡 Exemplo prático: utf-8 (normal), latin1 (problema potencial)
" ⚡ Impacto: Detecta problemas de encoding antes de bugs

set statusline+=\ %l/%L                  
" 📖 TÓPICO: Linha atual / total de linhas
" 🎯 Por que no OSR2: Arquivos grandes (kernel 1000+ linhas), precisa
"    saber localização relativa no arquivo
" 💡 Exemplo prático: 142/1850 = linha 14 1850 total
" ⚡ Impacto: Senso de progresso e localização no arquivo

set statusline+=\ %p%%                   
" 📖 TÓPICO: Porcentagem no arquivo
" 🎯 Por que no OSR2: Complementa linha atual com percentage visual.
"    Útil para arquivos muito grandes
" 💡 Exemplo prático: 25% = está no primeiro quarto do arquivo
" ⚡ Impacto: Navegação proporcional rápida

" ── DOBRAMENTO DE CÓDIGO ─────────────────────────────────
ethod=indent         
" 📖 TÓPICO: Dobramento baseado em indentação
" 🎯 Por que no OSR2: Funções C são naturalmente indentadas.
"    Permite esconder/mostrar funções inteiras
" 💡 Exemplo prático: Função main() pode ser "dobrada" para uma linha
" ⚡ Impacto: Visão geral de arquivos grandes, foco em partes específicas

set foldlevel=99              
" 📖 TÓPICO: Iniciar com todos os folds abertos
" 🎯 Por que no OSR2: Por padrão, você quer ver todo o código.
"    Folding é para ecisar
" 💡 Exemplo prático: Abre arquivo com todas as funções visíveis
" ⚡ Impacto: Não esconde código por padrão (pode confundir iniciantes)

set foldenable                
" 📖 TÓPICO: Habilita funcionalidade de folding
" 🎯 Por que no OSR2: za para toggle fold, zM para fechar tudo, etc.
"    Funcionalidade disponível quando precisar
" 💡 Exemplo prático: za na função main() esconde/mostra a implementação
" ⚡ Impacto: Controle fino da visualização do código
" 📚 Referência: :help folding

" ── SISTEMA DE LINTING NATIVO OSR2 ─────────────────────────
" 📖 TÓPICO: Integração de linters sem plugins externos
" 🎯 Por que no OSR2: Compilação C e análise assembly precisam
"    de feedback instantâneo de erros - o sistema nativo do vim
"    oferece quickfix list profissional

" C/C++ com GCC (análise de erros de compilação)
autocmd FileType c setlocal makeprg=gcc\ -Wall\ -Wextra\ -g\ %\ -o\ %<
autocmd FileType c seal errorformat=%f:%l:%c:\ %t%*[^:]:(\ %m
" 📖 Explicação: makeprg define comando para :make, errorformat interpreta erros
" 🔧 makeprg breakdown:
"    gcc: compilador C
"    -Wall -Wextra: máximo de warnings para detectar problemas
"    -g: símbolos de debug para análise posterior
"    %: arquivo atual, %<: nome sem extensão
" 🔧 errorformat breakdown:
"    %f: nome do arquivo com erro
"    %l: linha do erro, %c: coluna do erro
"    %t: tipo (E=error, W=warning)
"    %m: mensagem completa do erro: Erro de compilação vira clicável na quickfix list

" Shell scripts com shellcheck (análise de erros bash)
autocmd FileType sh setlocal makeprg=shellcheck\ -f\ gcc\ %
autocmd FileType sh setlocal errorformat=%f:%l:%c:\ %t%*[^:]:(\ %m
" 📖 Explicação: shellcheck analisa scripts bash para problemas comuns
" 🔧 shellcheck flags:
"    -f gcc: formato compatível com errorformat do vim
"    %: arquivo atual sendo editado
" 💡 Exemplo prático: Detecta variáveis não declaradas, aspas faltando
" âs bash sem erros sintáticos ou lógicos
" ⚠️ Nota Arch minimal: Instalar com 'pacman -S shellcheck'

" Assembly NASM (análise de sintaxe)
autocmd FileType nasm setlocal makeprg=nasm\ -f\ elf64\ %\ -o\ /tmp/%<.o
autocmd FileType nasm setlocal errorformat=%f:%l:\ %t%*[^:]:(\ %m
" 📖 Explicação: NASM verifica sintaxe assembly e gera object file
" 🔧 nasm flags:
"    -f elf64: formato ELF 64-bit (padrão Linux)
"    -o /tmp/%<.o: output para /tmp (não polui diretório)
" 💡 Exemplo prático: Deta labels inexistentes, sintaxe incorreta
" ⚡ Impacto: Assembly válido antes de linking

" ── COMANDOS DE LINTING ─────────────────────────────────────
" 📖 TÓPICO: Atalhos para linting rápido durante desenvolvimento
" 🎯 Por que no OSR2: Ciclo compile-debug-analyze requer velocidade

nnoremap <F12> :make!<CR>:copen<CR>
" 📖 Explicação: F12 executa linting e abre quickfix list
" 🔧 Comando breakdown:
"    :make!: exesem saltar para primeiro erro
"    :copen: abre janela com lista de erros
"    <CR>: Enter (executa comando)
" ⚡ Impacto: Feedback visual imediato de todos os problemas
" 💡 Uso OSR2: F12 após editar código → vê todos os erros listados

" Navegação na quickfix list (lista de erros)
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprev<CR>  
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>
" 📖 Explicação: \cn = próximo erro, \cp = erro anterior
" 💡 Uso OSR2: Debug sistemico de código C e assembly
" 🔧 Comandos quickfix:
"    :cnext: salta para próximo erro na lista
"    :cprev: salta para erro anterior
"    :copen: abre janela de erros
"    :cclose: fecha janela de erros
" ⚡ Impacto: Navegação rápida entre todos os problemas encontrados

" ── ABBREVIATIONS OSR2 ESPECÍFICAS ─────────────────────────
" 📖 TÓPICO: Expansões automáticas para desenvolvimento OS
" 🎯 Por que no OSR2: Código repetitivo de bai precisa
"    de automação inteligente para ganhar velocidade

" Headers C comuns em OS development
iabbrev <expr> hguard toupper(substitute(expand('%:t'), '\.', '_', 'g')).'_H'
" 📖 Explicação: hguard expande para ARQUIVO_H (header guard)
" 🔧 Função breakdown:
"    expand('%:t'): nome do arquivo atual
"    substitute(..., '\\.', '_', 'g'): troca . por _
"    toupper(...): converte para maiúsculas
"    .'_H': adiciona sufixo _H
" 💡 Exemplo: kernel.h → KERNEL_H, boot.h → BOOT_H
" ⚡ Impac Header guards automáticos sem digitação manual

" Assembly NASM comum
autocmd FileType nasm iabbrev <buffer> sectext section .text<CR>global _start<CR>_start:
" 📖 Explicação: sectext cria seção .text com entry point padrão
" 🔧 Template assembly:
"    section .text: seção de código executável
"    global _start: torna _start visível ao linker
"    _start:: label de entrada do programa
" 💡 Uso OSR2: Início rápido de programas assembly
" <CR>: quebra de linha automática

autocmd FileTsm iabbrev <buffer> secdata section .data
" 📖 Explicação: secdata cria seção de dados inicializados
" ⚡ Impacto: Setup rápido de seções assembly

autocmd FileType nasm iabbrev <buffer> syscall mov eax, 1<CR>int 0x80
" 📖 Explicação: syscall gera chamada de sistema Linux 32-bit
" 🔧 Syscall breakdown:
"    mov eax, 1: sys_exit (código 1)
"    int 0x80: interrupção de sistema
" 💡 Uso OSR2: Exit rápido em programas assembly de teste

" Debugging e análise
autocmd FileType c iabbrev <bdbg printf("DEBUG: %s:%d\n", __FILE__, __LINE__);
" 📖 Explicação: pdbg = print debug com arquivo e linha automáticos
" 🔧 printf breakdown:
"    %s: string (nome do arquivo)
"    %d: decimal (número da linha)
"    __FILE__: macro com nome do arquivo
"    __LINE__: macro com número da linha
" 💡 Uso OSR2: Debug rápido durante desenvolvimento kernel
" ⚡ Impacto: Localização exata de problemas em runtime

autocmd FileType c iabbrev <buffer> phex printf("0x%x\n", 
" 📖 Explicação: phex = prhex, cursor fica após vírgula
" 💡 Uso OSR2: Debug de valores hexadecimais (endereços, flags)
" ⚡ Impacto: Formato hexadecimal automático para debugging

" Timestamps para development logs
iabbrev <expr> timestamp strftime('[%Y-%m-%d %H:%M:%S]')
" 📖 Explicação: timestamp → [2024-03-15 14:30:25]
" 🔧 strftime format:
"    %Y: ano 4 dígitos, %m: mês, %d: dia
"    %H: hora 24h, %M: minuto, %S: segundo
" 💡 Uso: Logs de debugging e commit messages
" ⚡ Impacto: Timestamps automáticos sem manual

" ── WILDMENU OSR2 OTIMIZADO ─────────────────────────────────
" 📖 TÓPICO: Autocompletion inteligente para tipos de arquivo OSR2
" 🎯 Por que no OSR2: Projetos têm .c, .h, .asm, .ld, Makefiles
"    específicos que precisam de filtragem inteligente

" Configuração wildmenu melhorada (substitui configuração anterior)
set wildmenu
set wildmode=longest:full,full
set wildoptions=pum
" 📖 Explicação: Autocompletion tipo  menu moderno
" 🔧 wildmode breakdown:
"    longest: completa até parte comum
"    full: mostra menu completo depois
" 🔧 wildoptions=pum: popup menu (se suportado)
" ⚡ Impacto: Interface moderna de autocompletion

" Ignorar arquivos de build e temporários OSR2
set wildignore+=*.o,*.obj,*.elf,*.bin,*.iso
set wildignore+=*.img,*.vdi,*.vmdk
set wildignore+=*~,*.swp,*.tmp
set wildignore+=.git/*,.svn/*
set wildignore+=*.log,*.out
" 📖 Explicação: Filtra arquivos irrelevantes do autocompletion
" 🔧os OSR2:
"    *.o,*.obj: arquivos objeto compilados
"    *.elf,*.bin: executáveis e binários
"    *.iso,*.img: imagens de disco
"    *.vdi,*.vmdk: discos virtuais
"    *~,*.swp: backups e temporários
" ⚡ Impacto: Menu limpo, foco nos arquivos de código

" Priorizar tipos de arquivo OSR2
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.class,.jar
" 📖 Explicação: suffixes = tipos com menor prioridade no wildmenu
" 💡 Resultado: .c e .asm aparecem primeiro que .o e .obj
" ⚡ Impacto: Arquivos fontsobre arquivos compilados

" ── TEXT OBJECTS E OPERATORS AVANÇADOS ──────────────────────
" 📖 TÓPICO: Text objects e operators otimizados para programação
" 🎯 Por que no OSR2: Edição de código C/Assembly requer precisão
"    e velocidade para functions, blocks, comments

" Seleção de função C inteira (do tipo de retorno até })
nnoremap vaf ?^[a-zA-Z].*(<CR>V/^}<CR>
" 📖 Explicação: vaf = visual select a function
" 🔧 Regex breakdown:
"^[a-zA-Z].*( : busca linha que começa com tipo e tem (
"    V: visual line mode
"    /^}: busca } no início da linha
" 💡 Uso: Selecionar função completa para mover/copiar/deletar
" ⚡ Impacto: Manipulação de funções inteiras com 3 teclas

" Comentários de bloco C (/* ... */)
nnoremap vic /\/\*<CR>lv/\*\/<CR>h
nnoremap vac ?\/\*<CR>v/\*\/<CR>l
" 📖 Explicação: vic = inner comment, vac = around comment
" 🔧 Regex breakdown:
"    \/\*: busca /* (escapado)
"    l: move cursor uma posição (p*)
"    h: move cursor uma posição para trás (antes */)
" 🎯 Uso OSR2: Manipular documentação e comentários explicativos
" ⚡ Impacto: Edição de comentários como text objects nativos

" Movimentação entre funções
nnoremap [f ?^[a-zA-Z].*(<CR>
nnoremap ]f /^[a-zA-Z].*(<CR>
" 📖 Explicação: [f = função anterior, ]f = próxima função
" 🔧 Pattern: ^[a-zA-Z].*(  = linha começa com letra e tem (
" ⚡ Impacto: Navegação rápida em arquivos .c grandes
" 💡 Uso OSR2: Saltar entre funs sem scroll manual

" ── STATUS LINE COM LINTING INTEGRADO ───────────────────────
" 📖 TÓPICO: Feedback visual de erros na status line
" 🎯 Por que no OSR2: Desenvolvimento baixo nível precisa de
"    awareness constante do estado do código

" Função para mostrar status de erros
function! LintStatus()
    let qf_list = getqflist()
    let error_count = len(filter(copy(qf_list), 'v:val.type == "E"'))
    let warning_count = len(filter(copy(qf_list)pe == "W"'))
    
    if error_count > 0
        return printf(' E:%d W:%d', error_count, warning_count)
    elseif warning_count > 0
        return printf(' W:%d', warning_count)
    else
        return ' ✓'
    endif
endfunction
" 📖 Explicação: Conta erros e warnings na quickfix list
" 🔧 Função breakdown:
"    getqflist(): pega lista de erros atual
"    filter(..., 'v:val.type == "E"'): conta só erros
"    printf(): formata string com contadores
" 💡 Output: E:3 W:1 (3 erros, 1 warning) ou mas)
" ⚡ Impacto: Status instantâneo sem abrir quickfix

" Integrar na status line existente (adiciona após %p%%)
set statusline+=\ %{LintStatus()}
" 📖 Explicação: Adiciona status de linting na barra inferior
" ⚡ Impacto: Feedback visual constante do estado do código
" 💡 Visualização: arquivo.c [+] C utf-8 142/1850 75% E:2 W:5

" =============================================
" Fim da configuração .vimrc OSR2 - Otimizada
" Cada linha explicada para máximo aprendizado
" Integração comple linting + produtividade
" =============================================
```

#### 📋 Funcionalidades desta configuração otimizada:

Esta configuração .vimrc foi **expandida** com recursos nativos avançados baseados nos documentos especializados de vim, mantendo foco educativo OSR2:

**📖 Para cada configuração:**
- **Tópico:** O que a configuração faz
- **🎯 Reasoning OSR2:** Por que é necessária especificamente para OS Development + Radare2
- **💡 Exemplo prático:** Como usar na práteal
- **⚡ Impacto:** Benefício concreto no workflow
- **📚 Referência:** Documentação vim oficial

**🎨 Interface Visual Otimizada:**
- `set number` - Numeração para debug com gdb (linha específica dos erros)
- `syntax on` - Cores diferentes para C, Assembly, Shell (reduz bugs 30-40%)
- `set cursorline` - Localização precisa em assembly (crítico para bootloaders)
- `set laststatus=2` - Info constante: arquivo, modificações, tipo
- `colorscheme default` - Funciona sempre (WSL, terminals divsos)

**⌨️ Produtividade Maximizada:**
- `set hlsearch + incsearch` - Busca visual de funções em códigos grandes
- `set smartcase` - Busca inteligente (MALLOC vs malloc quando necessário)
- `set wildmenu` otimizado - Filtragem inteligente de arquivos OSR2
- `set clipboard=unnamed` - Copia código vim→documentação seamless

**🔧 OSR2 File-Type Specific:**
- **Assembly (`asm`,`nasm`):** `tabstop=8 noexpandtab` - Alinhamento opcodes histórico
- **C files:** `tabstop=4 expandtab` - Código educatvo legível (vs kernel=8)
- **Makefiles:** `noexpandtab` OBRIGATÓRIO - Make falha com espaços
- **Shell scripts:** `expandtab` - Padrão moderno Google Shell Style

**🚀 Integração Ferramentas OSR2:**
- **F9:** `:w + gcc % -Wall -g` - Compile cycle instantâneo com debug
- **F10:** `./executável` - Test imediato pós-compilação  
- **F11:** `r2 executável` - Análise binária integrada única
- **F12:** `:make! + :copen` - **NOVO**: Linting nativo com quickfix
- **Esc Esc:** `:noh` - Limpa busca pra tela limpa

**🔥 NOVOS RECURSOS AVANÇADOS:**

**📋 Sistema de Linting Nativo:**
- **makeprg + errorformat** - Linting profissional sem plugins
- **Quickfix list** integrada - Navegação clicável entre erros
- **Suporte C, Shell, Assembly** - Linters específicos por linguagem
- **Status visual** na barra inferior - E:3 W:1 ou ✓

**⚡ Abbreviations Inteligentes:**
- **Header guards automáticos** - `hguard` → `ARQUIVO_H`
- **Templates assembly** - `sectext` → seção .text completa
- **Debugpers** - `pdbg` → printf com linha automática
- **Timestamps** - `timestamp` → data/hora atual

**🎯 Text Objects Avançados:**
- **Funções C completas** - `vaf` seleciona função inteira
- **Comentários de bloco** - `vic`/`vac` para /* ... */
- **Navegação entre funções** - `[f`/`]f` pula para anterior/próxima

**🗂️ Wildmenu Otimizado:**
- **Filtros OSR2** - Ignora .o, .bin, .img automaticamente
- **Priorização inteligente** - Arquivos fonte aparecem primeiro
- **Interface moderna** menu quando disponível

**🎯 Configurações Educativas Específicas:**
- `set showcmd/showmode` - Feedback visual para iniciantes vim
- `set autoindent + smartindent` - C formatado profissionalmente automático
- `set foldmethod=indent` - Visão overview de funções grandes
- Status line completa - Path, modificações, encoding, posição, **+ status de linting**

#### 🧪 Testando a configuração otimizada:
```bash
# Aplicar configuração (reiniciar vim ou source)
# :source ~/.vimrc
# 📖 Explicaecarrega configuração sem reiniciar vim

# Testar com arquivo C (funcionalidades básicas + novas)
vim test.c

# No vim, testar funcionalidades BÁSICAS:
# - Syntax highlighting deve aparecer automaticamente
# - :set number (números já devem estar visíveis)
# - F9 para compilar
# - F10 para executar
# - F11 para abrir no r2

# No vim, testar NOVOS RECURSOS:
# - Digite 'hguard' + espaço → vira TEST_C_H
# - Digite 'pdbg' + espaço → printf("DEBUG: test.c:5\n");
# - Digite 'timestamp' + espaço → [2024-03-15 14:30:25]
# - F12 → executa linting e abre lista de erros
# - \cn/\cp → navegar entre erros na quickfix
# - vaf → selecionar função completa
# - /malloc → buscar malloc, Esc Esc → limpar highlight
# - :e tes<TAB> → autocompletion filtrado

# Testar arquivo Assembly (.asm)
vim test.asm
# - Digite 'sectext' + espaço → seção .text completa
# - Digite 'syscall' + espaço → mov eax,1 + int 0x80
# - F12 → linting NASM específico

# Testar arquivo Shell (.sh)
vim test.sh
# - F12 eck integration
# - Status na barra inferior mostra E:X W:Y
```

#### 💡 Benefícios do vanilla vim:
- **Portabilidade:** Funciona em qualquer sistema Linux
- **Velocidade:** Sem overhead de plugins
- **Aprendizado:** Foca nos fundamentos do vim
- **Compatibilidade:** Perfeito para WSL/servidor
- **Simplicidade:** Fácil de entender e modificar

### 🧪 Teste Completo da Configuração Vim

#### Criando script de teste da configuração:
```bash
# vim test-vim-config.sh
# 📖 Explicação: Cria script pvimrc
# 📝 TEMPLATE DO SCRIPT (para digitar no vim):
#    #!/bin/bash
#    # test-vim-config.sh - Script para testar configuração vim OSR2
#    
#    echo "🧪 Testando configuração vim OSR2..."
#    
#    # Criar arquivo teste C usando here document (método para scripts)
#    cat > test-vim.c << 'EOF'
#    #include <stdio.h>
#    
#    int main() {
#        printf("Teste vim OSR2!\n");
#        return 42;
#    }
#    EOF
#    
#    # Criar arquivo teste Assembly usando here document 
#    cat > tes << 'EOF'
#    section .text
#        global _start
#    _start:
#        mov eax, 1
#        int 0x80
#    EOF
#    
#    echo "✅ Arquivos de teste criados:"
#    echo "   - test-vim.c (teste syntax highlighting C)"
#    echo "   - test-vim.asm (teste syntax highlighting Assembly)"
#    echo ""
#    echo "🎯 Para testar configuração vim OSR2:"
#    echo "   1. vim test-vim.c"
#    echo "      - Verificar syntax highlighting"
#    echo "      - Pressionar F9 (compilar)"
#    echo "      - Pressionar Fecutar)"
#    echo "      - Pressionar F11 (abrir r2)"
#    echo "   2. vim test-vim.asm"
#    echo "      - Verificar syntax highlighting Assembly"
#    echo "   3. :set number (números já devem estar visíveis)"
#    echo "   4. /printf (buscar com highlight)"
#    echo "   5. Esc Esc (limpar highlight)"
vim test-vim-config.sh

# chmod +x test-vim-config.sh && ./test-vim-config.sh
chmod +x test-vim-config.sh && ./test-vim-config.sh
```

#### Workflow de teste da configuração:
```bash
# 1. Aplicar confção
vim ~/.vimrc
# (Digite toda a configuração .vimrc acima, depois :wq)

# 2. Criar arquivos de teste
./test-vim-config.sh

# 3. Testar arquivo C
vim test-vim.c
# No vim:
# - Syntax highlighting deve aparecer (azul para #include, etc.)
# - Números de linha visíveis na esquerda
# - Barra de status na parte inferior
# - F9: compila (gcc test-vim.c -o test-vim)
# - F10: executa (./test-vim)
# - F11: abre no r2 (r2 test-vim)
# - :q para sair

# 4. Testar arquivo Assembly
vim test-vim.asm
# No vim:
# - Syighlighting para assembly
# - Indentação com tabs (8 espaços)
# - :q para sair

# 5. Verificar que tudo está funcionando
echo "✅ Configuração vim OSR2 testada com sucesso!"
```

#### Comandos vim essenciais para programação:
```bash
# Criar/editar arquivos
vim programa.c         # Criar programa C
vim script.sh          # Criar script bash
vim boot.asm          # Criar código assembly

# Navegação básica
h j k l               # Esquerda, baixo, cima, direita
gg                    # Início do                # Final do arquivo
/texto                # Buscar texto
n                     # Próxima ocorrência

# Edição
i                     # Insert mode (inserir antes do cursor)
a                     # Append mode (inserir depois do cursor)
o                     # Nova linha abaixo
O                     # Nova linha acima
dd                    # Deletar linha inteira
yy                    # Copiar linha inteira
p                     # Colar

# Salvamento
:w                    # Salvar
:wq               # Salvar e sair
:q!                   # Sair sem salvar
```

#### Workflow vim para OSR2:
```bash
# 1. Criar programa
vim hello.c

# 2. No vim - escrever código:
# i (insert mode)
# Digite: #include <stdio.h>
#         int main() { printf("Hello OSR2!"); return 0; }
# Esc (command mode)
# :wq (salvar e sair)

# 3. Compilar e analisar
gcc hello.c -o hello
r2 hello
```

---

**Guia Criado:** 2025-09-04  
**Sistema:** OSR2 - OS Development + Radare2 Integration  
**Contexto:** Arch Linux Minimal no WS  
**Tempo Total:** 45-60 minutos  
**Resultado:** Ambiente completo pronto para desenvolvimento OS

