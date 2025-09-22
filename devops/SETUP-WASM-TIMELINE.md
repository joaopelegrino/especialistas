# Timeline de Setup WebAssembly + C

## 📋 Estado Atual
- ✅ **Wasmtime Runtime**: v36.0.2 instalado e operacional
- ✅ **WASI SDK**: v20.0 baixado e extraído
- ✅ **Ambiente de Desenvolvimento**: Funcional para C → WASM
- ✅ **Teste Hello World**: Executado com sucesso

---

## 🕐 Timeline de Instalação

### 1. Verificação Inicial do Ambiente
**Timestamp**: 09:49 UTC (19/09/2025)
**Ação**: Verificação de ferramentas existentes
```bash
which wasmtime  # ❌ wasmtime not found
which clang     # ❌ clang not found
ls ~/wasi-sdk*  # ❌ WASI SDK não encontrado
```
**Decisão**: Instalação completa necessária

### 2. Instalação do Wasmtime Runtime
**Timestamp**: 09:49 UTC
**Método**: Script oficial do Bytecode Alliance
**Comando**:
```bash
curl https://wasmtime.dev/install.sh -sSf | bash
```
**Versão Instalada**: v36.0.2
**Localização**: `~/.wasmtime/bin/wasmtime`
**PATH**: Automaticamente adicionado ao `~/.zshrc`

**Verificação**:
```bash
export PATH="$HOME/.wasmtime/bin:$PATH"
wasmtime --version  # ✅ wasmtime 36.0.2 (459dbfb33 2025-08-26)
```

### 3. Download e Instalação do WASI SDK
**Timestamp**: 09:49 UTC
**Versão Escolhida**: 20.0 (mais recente conforme guia)
**Método**: Download direto do GitHub Releases
**URL**: https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz
**Tamanho**: 76MB (79.570.956 bytes)

**Comandos**:
```bash
wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz
tar -xzf wasi-sdk-20.0-linux.tar.gz
```

**Estrutura Instalada**:
```
wasi-sdk-20.0/
├── bin/        # Contém clang e outras ferramentas
├── lib/        # Bibliotecas WASI
└── share/      # Documentação e recursos
```

### 4. Teste de Funcionalidade
**Timestamp**: 09:49 UTC
**Arquivo Teste**: `hello.c`
```c
#include <stdio.h>

int main() {
    printf("Olá, mundo do WebAssembly com C!\n");
    return 0;
}
```

**Compilação**:
```bash
./wasi-sdk-20.0/bin/clang hello.c -o hello.wasm
```

**Execução**:
```bash
wasmtime run hello.wasm
# Output: Olá, mundo do WebAssembly com C!
```

---

## ⚙️ Configurações de PATH

### PATH Atual (Temporário)
```bash
export PATH="$HOME/.wasmtime/bin:$PATH"
```

### PATH Permanente Recomendado
Adicionar ao `~/.zshrc` ou `~/.bashrc`:
```bash
# WebAssembly Tools
export PATH="$HOME/.wasmtime/bin:$PATH"
export WASI_SDK_PATH="$HOME/workspace/especialistas/devops/wasi-sdk-20.0"
export PATH="$WASI_SDK_PATH/bin:$PATH"
```

---

## 📁 Estrutura de Arquivos

```
/home/notebook/workspace/especialistas/devops/
├── wasi-sdk-20.0/                    # WASI SDK extraído
│   ├── bin/clang                     # Compilador C para WASM
│   ├── lib/                          # Bibliotecas WASI
│   └── share/                        # Recursos adicionais
├── wasi-sdk-20.0-linux.tar.gz       # Arquivo original (pode ser removido)
├── hello.c                           # Código teste
├── hello.wasm                        # Binário WebAssembly compilado
├── guia_wasm_iniciante.md           # Guia de referência
└── SETUP-WASM-TIMELINE.md          # Este arquivo
```

---

## 🔧 Comandos de Uso Diário

### Compilação C → WASM
```bash
./wasi-sdk-20.0/bin/clang arquivo.c -o saida.wasm
```

### Execução WASM
```bash
wasmtime run saida.wasm
```

### Compilação com flags otimizadas
```bash
./wasi-sdk-20.0/bin/clang -O2 arquivo.c -o saida.wasm
```

### Compilação com debugging
```bash
./wasi-sdk-20.0/bin/clang -g arquivo.c -o saida.wasm
```

---

## 🧪 Testes de Validação

### ✅ Teste 1: Hello World
- **Status**: Passou
- **Arquivo**: hello.c
- **Output**: "Olá, mundo do WebAssembly com C!"

### 🔄 Próximos Testes Sugeridos

1. **Teste com argumentos**:
```c
int main(int argc, char* argv[]) {
    printf("Argumentos: %d\n", argc);
    return 0;
}
```

2. **Teste com bibliotecas padrão**:
```c
#include <string.h>
#include <assert.h>

void test_string_functions() {
    char text[] = "teste wasm";
    assert(strlen(text) == 10);
    printf("Teste de string passou!\n");
}
```

---

## 📋 Decisões Técnicas Tomadas

### Versão do Wasmtime
- **Escolhida**: v36.0.2 (mais recente disponível)
- **Motivo**: Instalação automática via script oficial
- **Alternativas**: Poderia usar versões específicas via releases

### Versão do WASI SDK
- **Escolhida**: v20.0
- **Motivo**: Recomendação do guia + mais recente estável
- **Alternativas**: v19.0, v18.0 (versões anteriores)

### Método de Instalação
- **Wasmtime**: Script curl (oficial)
- **WASI SDK**: Download manual do GitHub
- **Motivo**: Métodos mais confiáveis e documentados

### Localização dos Arquivos
- **Wasmtime**: `~/.wasmtime/` (padrão do instalador)
- **WASI SDK**: `./wasi-sdk-20.0/` (diretório atual)
- **Motivo**: Manter organização e facilitar remoção se necessário

---

## 🚀 Próximos Passos Recomendados

1. **Configurar PATH permanente** no shell profile
2. **Testar exemplo com strtok()** conforme guia
3. **Instalar Fermyon Spin** para microsserviços
4. **Criar projetos de teste mais complexos**
5. **Explorar otimizações de compilação**

---

## 📖 Referências

- **Guia Principal**: `guia_wasm_iniciante.md`
- **Wasmtime Docs**: https://wasmtime.dev/
- **WASI SDK**: https://github.com/WebAssembly/wasi-sdk
- **WebAssembly Specs**: https://webassembly.org/

---

**Última Atualização**: 19/09/2025 09:49 UTC
**Status**: ✅ Ambiente Funcional e Testado
