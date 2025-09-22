# 📚 Manual de Trabalho - Projeto Especialistas DevOps

**Projeto:** `/home/notebook/workspace/especialistas/devops`
**Foco:** WebAssembly (WASM) + DevOps
**Última atualização:** 21/09/2025
**Sistema:** WSL2 Ubuntu 24.04.3 LTS + Vim modernizado

---

## 🎯 Visão Geral do Projeto

### 📋 Estrutura Detectada
```
/home/notebook/workspace/especialistas/devops/
├── 🛠️ wasi-sdk-20.0/           # WASI SDK completo instalado
│   ├── bin/                    # Ferramentas de compilação
│   ├── lib/                    # Bibliotecas WASI
│   └── share/                  # Documentação e recursos
├── 📖 guia_wasm_iniciante.md   # Guia de aprendizado WASM
├── 🧪 hello.c                  # Código exemplo C
├── ✅ hello.wasm               # WebAssembly compilado
├── 🔍 pesquisa.md              # Anotações de pesquisa
├── 📅 SETUP-WASM-TIMELINE.md   # Timeline de configuração
├── 🧪 tes.c                    # Arquivo de teste
├── 📝 transcricao.md           # Transcrições de estudos
└── 📦 wasi-sdk-20.0-linux.tar.gz # SDK original
```

`★ Insight ─────────────────────────────────────`
- **SDK Completo**: WASI SDK 20.0 totalmente funcional instalado
- **Workflow Ativo**: Exemplos C → WASM já testados (hello.c → hello.wasm)
- **Documentação Rica**: 5 arquivos MD com conhecimento estruturado
`─────────────────────────────────────────────────`

---

## 🚀 Workflow de Desenvolvimento WASM

### 🎮 Comandos Essenciais (Vim Integrado)

**1. Navegação do Projeto**
```bash
# Ir para o projeto
cd ~/workspace/especialistas/devops

# Abrir com Vim modernizado
,ev                           # Editar vimrc se precisar de config
,t                           # Terminal tela cheia para comandos
vim guia_wasm_iniciante.md   # Documentação principal (nova aba)
```

**2. Compilação WASM**
```bash
# No terminal integrado (,t)
./wasi-sdk-20.0/bin/clang --target=wasm32-wasi hello.c -o hello.wasm

# Verificar resultado
ls -la *.wasm
file hello.wasm
```

**3. Execução e Teste**
```bash
# Executar WASM (se runtime disponível)
wasmtime hello.wasm
# ou
node --experimental-wasi-unstable-preview1 hello.wasm
```

### 📋 Tab-First Development Workflow

**Organização em Abas (configuração automática)**:
```vim
:e guia_wasm_iniciante.md     " → Aba 1: Documentação principal
:e hello.c                   " → Aba 2: Código C
:e pesquisa.md               " → Aba 3: Anotações
,t                           " → Terminal dedicado (tela cheia)
```

**Navegação entre Abas**:
```vim
,t,          " Próxima aba
gt / gT      " Navegar abas (padrão Vim)
:tabc        " Fechar aba atual
:tabo        " Fechar todas exceto atual
```

---

## 🛠️ Configurações Específicas para WASM

### 📁 Configuração de Path para WASI SDK
```bash
# Adicionar ao ~/.zshrc (ou usar ,ev para editar vimrc)
export WASI_SDK_PATH="$HOME/workspace/especialistas/devops/wasi-sdk-20.0"
export PATH="$WASI_SDK_PATH/bin:$PATH"

# Recarregar configurações
reload                       # Alias personalizado
```

### 🎯 Aliases Específicos do Projeto
```bash
# Adicionar ao ~/.zshrc
alias devops="cd ~/workspace/especialistas/devops"
alias wasm-compile="$WASI_SDK_PATH/bin/clang --target=wasm32-wasi"
alias wasm-info="file *.wasm && ls -la *.wasm"
```

### 📝 Templates Vim para WASM Development

**Snippet para arquivos C (vsnip)**:
```c
// WASM C Template
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Hello WebAssembly from C!\n");
    return 0;
}
```

---

## 📖 Workflow de Documentação

### 🎓 Método de Aprendizado Estruturado

**1. Captura de Conhecimento**
```vim
# Usar folding inteligente (código sempre expandido)
vim pesquisa.md              # Anotações de pesquisa
# Folding automático expandido - sem surpresas

# Estrutura recomendada:
## [DATA] - Sessão de Estudo
### Conceitos Aprendidos
### Código Testado
### Próximos Passos
### Referências
```

**2. Documentação Técnica**
```vim
vim guia_wasm_iniciante.md    # Guia principal
# Usar mapeamentos de edição rápida:
,w                           # Salvar
,rv                          # Recarregar vimrc se precisar
```

**3. Timeline de Progresso**
```vim
vim SETUP-WASM-TIMELINE.md   # Controle de progresso
# Estrutura sugerida:
- [x] WASI SDK instalado
- [x] Primeiro hello.wasm compilado
- [ ] Runtime WASM configurado
- [ ] Projeto DevOps integrado
```

---

## 🧪 Testes e Experimentação

### 🔬 Ambiente de Desenvolvimento

**1. Compilação Iterativa**
```bash
# Terminal integrado (,t)
cd ~/workspace/especialistas/devops

# Ciclo de desenvolvimento
vim novo_exemplo.c           # Nova aba automática
# Editar código...
# Esc Esc para sair do modo terminal quando precisar
wasm-compile novo_exemplo.c -o novo_exemplo.wasm
wasm-info                    # Verificar resultado
```

**2. Debug e Análise**
```bash
# Análise de arquivos WASM
hexdump -C hello.wasm | head -20
wasm-objdump -h hello.wasm   # Se disponível

# Verificação de dependências
ldd hello.wasm 2>/dev/null || echo "WASM standalone"
```

### 🎯 Integração com LSP (Language Server)

**C Language Server (já configurado)**:
```vim
# Funcionalidades disponíveis:
gd              # Ir para definição
K               # Documentação de função
,rn             # Renomear variável/função
[g / ]g         # Navegar entre erros de sintaxe
```

---

## 📊 DevOps Pipeline para WASM

### 🔄 Workflow de CI/CD Sugerido

**1. Estrutura de Build**
```yaml
# .github/workflows/wasm-build.yml (sugestão)
name: WASM Build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup WASI SDK
        run: |
          wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz
          tar xvf wasi-sdk-20.0-linux.tar.gz
      - name: Build WASM
        run: |
          ./wasi-sdk-20.0/bin/clang --target=wasm32-wasi src/*.c -o dist/app.wasm
```

**2. Docker para WASM Development**
```dockerfile
# Dockerfile.wasm-dev
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    wget gcc build-essential wasmtime \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY wasi-sdk-20.0-linux.tar.gz .
RUN tar xf wasi-sdk-20.0-linux.tar.gz

ENV PATH="/workspace/wasi-sdk-20.0/bin:$PATH"
CMD ["bash"]
```

### 🐳 Docker Compose para Desenvolvimento

```yaml
# docker-compose.wasm.yml
version: '3.8'
services:
  wasm-dev:
    build:
      context: .
      dockerfile: Dockerfile.wasm-dev
    volumes:
      - .:/workspace/project
    tty: true
    stdin_open: true

  wasm-runtime:
    image: wasmtime/wasmtime
    volumes:
      - .:/workspace
    command: wasmtime /workspace/hello.wasm
```

---

## 🎯 Comandos de Produtividade

### 🚀 Atalhos de Desenvolvimento

**Vim + Terminal Integrado**:
```vim
,t                  # Terminal tela cheia para build
,ev                 # Editar vimrc para customizações
:Vimrc              # Comando direto para configurações
,h                  # Histórico FZF
Ctrl+P              # Buscar arquivos no projeto
Ctrl+F              # Buscar texto (ripgrep)
```

**Build & Test Cycle**:
```bash
# Macro sugerida para Vim
qa                  # Gravar macro 'a'
:w<CR>             # Salvar arquivo
,t                 # Ir para terminal
wasm-compile %<.c -o %<.wasm<CR>
<Esc><Esc>         # Voltar ao editor
q                  # Parar gravação

# Usar: @a para repetir ciclo build
```

### 📋 Checklist de Sessão de Desenvolvimento

**Início da Sessão**:
- [ ] `devops` - Navegar para projeto
- [ ] `vim guia_wasm_iniciante.md` - Revisar documentação
- [ ] `,t` - Terminal dedicado disponível
- [ ] `git status` - Verificar estado do projeto

**Durante Desenvolvimento**:
- [ ] Usar tab-first workflow para organização
- [ ] Documentar descobertas em `pesquisa.md`
- [ ] Testar compilação após cada mudança significativa
- [ ] Usar LSP para verificação de sintaxe C

**Fim da Sessão**:
- [ ] Atualizar `SETUP-WASM-TIMELINE.md`
- [ ] Commit das mudanças importantes
- [ ] Backup de arquivos `.wasm` gerados

---

## 🔍 Troubleshooting e Dicas

### ⚠️ Problemas Comuns

**1. WASI SDK não encontrado**
```bash
# Verificar path
echo $WASI_SDK_PATH
ls $WASI_SDK_PATH/bin/clang

# Reconfigurar se necessário
export WASI_SDK_PATH="$HOME/workspace/especialistas/devops/wasi-sdk-20.0"
```

**2. Compilação falha**
```bash
# Debug verbose
./wasi-sdk-20.0/bin/clang --target=wasm32-wasi -v hello.c -o hello.wasm

# Verificar dependências
./wasi-sdk-20.0/bin/clang --version
```

**3. Arquivo WASM corrompido**
```bash
# Verificar integridade
file hello.wasm
hexdump -C hello.wasm | head -5
```

### 💡 Dicas de Produtividade

**1. Use o terminal integrado (`,t`) para builds rápidos**
**2. Aproveite o tab-first workflow para organizar arquivos**
**3. Configure aliases para comandos frequentes**
**4. Use o LSP para C para detectar erros antes da compilação**
**5. Documente experimentos em tempo real**

---

## 📚 Recursos e Referências

### 🌐 Links Úteis (para adicionar aos arquivos MD)
- **WASI Spec**: https://github.com/WebAssembly/WASI
- **WASI SDK**: https://github.com/WebAssembly/wasi-sdk
- **Wasmtime**: https://wasmtime.dev/
- **WASM DevTools**: https://developer.mozilla.org/en-US/docs/WebAssembly

### 📖 Arquivos de Estudo Recomendados
1. **`guia_wasm_iniciante.md`** - Conceitos fundamentais
2. **`pesquisa.md`** - Anotações experimentais
3. **`SETUP-WASM-TIMELINE.md`** - Progresso e roadmap
4. **`transcricao.md`** - Registros de sessões de estudo

Este manual aproveita todas as otimizações do ambiente (terminal integrado, tab-first workflow, folding expandido, LSP) para criar um workflow eficiente de desenvolvimento WebAssembly com foco em DevOps.