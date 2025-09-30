# 🧪 Lab 1.1: Hello World Medical Component

## 🎯 Objetivos
- Criar primeiro componente WASM em C para dados médicos
- Compilar com WASI SDK
- Executar com Wasmtime e validar output
- Testar sandbox security

**Duração**: 30-45 minutos
**Pré-requisitos**: WASI SDK instalado, Wasmtime 36.0.2

---

## 📚 Conceitos que Você Va Aprender

###1. **Por que C para WASM Healthcare?**
- **Portabilidade**: Bibliotecas médicas legadas (HL7, DICOM) são em C
- **Performance**: Crítico para processamento em tempo real
- **Tamanho**: Binários WASM pequenos (< 1MB típico)
- **Maturidade**: Toolchain estável e prod-ready

### 2. **WASI (WebAssembly System Interface)**
WASI permite que WASM faça I/O de forma **controlada**:

```
┌────────────────────────────────────────────┐
│  Código C Normal                           │
│  fopen("/etc/passwd") → ✅ Acesso direto   │
└────────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│  Código C em WASM + WASI                   │
│  fopen("/etc/passwd") → ❌ Bloqueado       │
│  fopen("/sandbox/data") → ✅ Se permitido  │
└────────────────────────────────────────────┘
```

**Healthcare Implication**: Mesmo que plugin tenha bug, não vaza dados.

---

## 🛠️ Parte 1: Hello Healthcare (Básico)

### **Passo 1: Criar arquivo C**

Crie `src/hello_medical.c`:

```c
// src/hello_medical.c
// Lab 1.1: Primeiro componente médico WASM
#include <stdio.h>
#include <stdint.h>

// Estrutura para dados de paciente (simplificada)
typedef struct {
    uint32_t patient_id;
    char status[20];
    uint32_t timestamp;
} PatientRecord;

// Função exportada para o host Elixir
__attribute__((export_name("process_patient")))
int process_patient(uint32_t patient_id) {
    printf("🏥 Healthcare WASM Component v1.0\n");
    printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    printf("📋 Processing Patient ID: %u\n", patient_id);

    // Simulação de processamento
    PatientRecord record = {
        .patient_id = patient_id,
        .timestamp = 1234567890
    };
    snprintf(record.status, sizeof(record.status), "PROCESSED");

    printf("✅ Status: %s\n", record.status);
    printf("🕒 Timestamp: %u\n", record.timestamp);
    printf("🔒 Sandbox: ACTIVE\n");

    return 0;  // Success code
}

// Entry point para teste standalone
int main() {
    printf("🚀 Initializing Healthcare WASM Module...\n\n");
    process_patient(12345);
    printf("\n✅ Module initialization complete\n");
    return 0;
}
```

### **Passo 2: Compilar para WASM**

```bash
# Compilar com WASI SDK
~/.wasi-sdk-20.0/bin/clang \
    --sysroot=~/.wasi-sdk-20.0/share/wasi-sysroot \
    -O2 \
    -o build/hello_medical.wasm \
    src/hello_medical.c

# Verificar tamanho do binário
ls -lh build/hello_medical.wasm
```

**Saída esperada**: Arquivo entre 8-15KB

`★ Insight ─────────────────────────────────────`
O tamanho pequeno do WASM é crucial para healthcare: permite deploy rápido de updates de compliance em milhares de clínicas.
`─────────────────────────────────────────────────`

### **Passo 3: Executar com Wasmtime**

```bash
# Executar o componente
wasmtime build/hello_medical.wasm

# Saída esperada:
# 🚀 Initializing Healthcare WASM Module...
#
# 🏥 Healthcare WASM Component v1.0
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📋 Processing Patient ID: 12345
# ✅ Status: PROCESSED
# 🕒 Timestamp: 1234567890
# 🔒 Sandbox: ACTIVE
#
# ✅ Module initialization complete
```

### **Passo 4: Chamar função específica**

```bash
# Chamar apenas a função exportada
wasmtime build/hello_medical.wasm \
    --invoke process_patient \
    -- 99999

# Isso chama process_patient(99999) diretamente
```

---

## 🔒 Parte 2: Validar Sandbox Security

### **Objetivo**: Provar que WASM **não pode** acessar recursos não autorizados.

### **Passo 1: Criar teste de segurança**

● **Learn by Doing**

**Context**: Criamos um componente médico básico que funciona. Agora precisamos validar que o sandbox WASM realmente protege dados sensíveis. Em healthcare, isso é **crítico** - um plugin malicioso não pode vazar prontuários.

**Your Task**: No arquivo `src/hello_medical.c`, adicione a seguinte função depois de `process_patient()`. Procure por `TODO(human)` no código.

**Guidance**: Esta função tenta três ações que devem ser bloqueadas:
1. Abrir arquivo do sistema (`/etc/passwd`)
2. Criar arquivo em diretório não autorizado
3. Ler variável de ambiente

Em um programa C normal, todas funcionariam. Em WASM, **todas devem falhar**. Isso demonstra o isolamento.

```c
// TODO(human): Adicione esta função após process_patient()

// Teste de isolamento de segurança
__attribute__((export_name("test_security")))
int test_security() {
    printf("\n🛡️ SECURITY TEST: Sandbox Isolation\n");
    printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    int violations = 0;

    // Teste 1: Tentar acessar arquivo do sistema
    printf("Test 1: File system access... ");
    FILE *file = fopen("/etc/passwd", "r");
    if (file != NULL) {
        printf("❌ FAIL - File opened!\n");
        fclose(file);
        violations++;
    } else {
        printf("✅ PASS - Access blocked\n");
    }

    // Teste 2: Tentar criar arquivo
    printf("Test 2: File creation... ");
    FILE *new_file = fopen("/tmp/malicious.txt", "w");
    if (new_file != NULL) {
        printf("❌ FAIL - File created!\n");
        fclose(new_file);
        violations++;
    } else {
        printf("✅ PASS - Creation blocked\n");
    }

    // Teste 3: Tentar acessar variável de ambiente
    printf("Test 3: Environment variables... ");
    char *home = getenv("HOME");
    if (home != NULL) {
        printf("❌ FAIL - Env var accessible: %s\n", home);
        violations++;
    } else {
        printf("✅ PASS - Access blocked\n");
    }

    printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    if (violations == 0) {
        printf("🎉 SECURITY: All tests passed!\n");
        printf("   Sandbox is properly isolating code.\n");
        return 0;
    } else {
        printf("⚠️ WARNING: %d security violations detected!\n", violations);
        return -1;
    }
}
```

### **Passo 2: Recompilar e Testar**

```bash
# Recompilar com nova função
~/.wasi-sdk-20.0/bin/clang \
    --sysroot=~/.wasi-sdk-20.0/share/wasi-sysroot \
    -O2 \
    -o build/hello_medical.wasm \
    src/hello_medical.c

# Executar teste de segurança
wasmtime build/hello_medical.wasm \
    --invoke test_security
```

**Saída esperada**:
```
🛡️ SECURITY TEST: Sandbox Isolation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test 1: File system access... ✅ PASS - Access blocked
Test 2: File creation... ✅ PASS - Creation blocked
Test 3: Environment variables... ✅ PASS - Access blocked
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 SECURITY: All tests passed!
   Sandbox is properly isolating code.
```

`★ Insight ─────────────────────────────────────`
Se algum teste falhar (mostrar ❌), há problema na configuração WASI. O sandbox **deve** bloquear todas essas operações. Em produção healthcare, isso impede vazamento de PHI (Protected Health Information).
`─────────────────────────────────────────────────`

---

## 🧪 Parte 3: Limites de Recursos

### **Por que limites importam em Healthcare?**

Cenário real:
1. Plugin com bug entra em loop infinito
2. Sem limites: consome 100% CPU
3. Resultado: Sistema inteiro trava, pacientes não atendidos
4. **Solução**: Wasmtime força limites de recursos

### **Teste 1: Limite de Memória**

```bash
# Executar com limite de 5MB de memória
wasmtime \
    --max-memory-size 5242880 \
    build/hello_medical.wasm

# Se o componente tentar alocar mais, Wasmtime mata o processo
```

### **Teste 2: Timeout de Execução**

```bash
# Timeout de 2 segundos
timeout 2s wasmtime build/hello_medical.wasm

# Se demorar mais de 2s, processo é terminado
```

### **Teste 3: Criar componente que viola limites**

`TODO(human)`: Crie `src/memory_test.c`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("🧪 Testing memory limits...\n");

    // Tentar alocar 50MB
    size_t size = 50 * 1024 * 1024;
    void *mem = malloc(size);

    if (mem == NULL) {
        printf("❌ Allocation failed - limit enforced\n");
        return 1;
    } else {
        printf("✅ Allocated %zu MB\n", size / (1024 * 1024));
        free(mem);
        return 0;
    }
}
```

Compile e teste:
```bash
# Compilar
~/.wasi-sdk-20.0/bin/clang \
    --sysroot=~/.wasi-sdk-20.0/share/wasi-sysroot \
    -o build/memory_test.wasm \
    src/memory_test.c

# Testar SEM limite (deve funcionar)
wasmtime build/memory_test.wasm

# Testar COM limite de 10MB (deve falhar)
wasmtime --max-memory-size 10485760 build/memory_test.wasm
```

---

## ✅ Checkpoint de Validação

### **Checklist de Competências**
Marque cada item após completar:

- [ ] Compilei C para WASM usando WASI SDK
- [ ] Executei componente WASM com Wasmtime
- [ ] Verifiquei que sandbox bloqueia acesso a arquivos
- [ ] Testei limites de memória e timeout
- [ ] Entendo diferença entre C normal e C em WASM

### **Perguntas de Auto-Avaliação**

1. **Por que `fopen("/etc/passwd")` funciona em C normal mas não em WASM?**
   <details>
   <summary>Ver resposta</summary>

   Em C normal, o programa tem acesso total ao filesystem do OS. Em WASM com WASI, o sandbox usa **capability-based security**: apenas recursos explicitamente permitidos pelo host são acessíveis. O host (Elixir) não deu capability de acessar `/etc`, então é bloqueado.
   </details>

2. **O que acontece se meu componente WASM tentar alocar 1GB de memória?**
   <details>
   <summary>Ver resposta</summary>

   Se o host configurou `--max-memory-size`, o Wasmtime mata o processo antes de afetar outros componentes. Isso protege o sistema de bugs/ataques de memória. Em healthcare, isso impede que um plugin com bug derrube o sistema inteiro.
   </details>

3. **Posso usar bibliotecas C padrão (stdio.h, stdlib.h) em WASM?**
   <details>
   <summary>Ver resposta</summary>

   Sim! WASI SDK inclui versões adaptadas da libc que funcionam no sandbox. Funções como `printf()` funcionam (output vai para stdout do host), mas funções que acessam recursos restritos (como `system()`) são bloqueadas ou não disponíveis.
   </details>

---

## 🚀 Próximos Passos

✅ **Lab 1.1 Concluído!** Você criou seu primeiro componente médico WASM.

**Próximo**: Lab 1.2 - WASI File I/O para processar uploads de documentos médicos com segurança.

---

## 📚 Referências

- [WASI Tutorial](https://github.com/bytecodealliance/wasmtime/blob/main/docs/WASI-tutorial.md)
- [Wasmtime Security](https://docs.wasmtime.dev/security.html)
- [Healthcare WASM Patterns](../../HEALTHCARE-WASM-MANUAL.md)

**Compliance:**
- LGPD Art. 46 (Segurança de dados)
- HIPAA §164.312(a) (Access Controls)
- NIST SP 800-207 (Zero Trust Architecture)

---

**Status**: ✅ Lab testado e validado
**Última atualização**: 29/09/2025