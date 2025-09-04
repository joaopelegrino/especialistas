# 🧠 Conceitos Importantes - OS Development

## 📚 Glossário de Conceitos por Fase

### 🔧 FASE 0: Preparação do Ambiente
- **WSL2**: Windows Subsystem for Linux versão 2
- **Virtualização Leve**: Container vs VM tradicional  
- **Distribuições Múltiplas**: Ubuntu, Arch Linux simultâneas
- **Cross-platform Development**: Desenvolver em Windows para Linux

### 💻 FASE 1: Fundamentos C/C++
- **Ponteiros**: Variáveis que armazenam endereços de memória
- **Alocação Dinâmica**: malloc(), calloc(), free()
- **Toolchain**: Conjunto de ferramentas (compiler, linker, debugger)
- **Cross-compilation**: Compilar para arquitetura diferente

### ⚙️ FASE 2: Hardware  
- **Bootloader**: Primeiro código executado na inicialização
- **Modo Real vs Protegido**: 16-bit vs 32-bit addressing
- **Registros x86**: EAX, EBX, ECX, EDX, etc.
- **BIOS vs UEFI**: Interfaces de firmware

### 🖥️ FASE 3: Kernel
- **VFS**: Virtual File System - abstração de arquivos
- **Kernel Space vs User Space**: Privilégios de execução
- **System Calls**: Interface kernel ↔ aplicações
- **Device Drivers**: Interfaces com hardware

### 🔄 FASE 4: Processos
- **Process Control Block**: Estrutura de controle de processo  
- **Context Switch**: Troca entre processos
- **Scheduler**: Algoritmo de escalonamento
- **IPC**: Inter-Process Communication

### 🔌 FASE 5: Extensões
- **I/O Multiplexing**: select(), poll(), epoll()
- **Pipes**: Comunicação entre processos via pipe
- **Memory Mapping**: mmap() para arquivos
- **Signals**: Comunicação assíncrona

---

## 🔗 Conceitos Transversais

### Gerenciamento de Memória
```c
// Sempre importante em OS Dev
void* malloc(size_t size);  // Aloca memória
void free(void* ptr);       // Libera memória  
void* mmap(...);            // Mapeia memória
```

### Assembly Inline
```c
// Acesso direto ao hardware
asm volatile("hlt");        // Halt CPU
asm("int $0x80");          // System call Linux
```

### Sincronização
```c
// Primitivas de sincronização
mutex_lock(&lock);         // Exclusão mútua
semaphore_wait(&sem);      // Semáforo
atomic_inc(&counter);      // Operação atômica
```

---

## ❓ Dúvidas Frequentes

### "O que é endianness?"
- **Big Endian**: Byte mais significativo primeiro
- **Little Endian**: Byte menos significativo primeiro  
- **x86 é Little Endian**

### "Diferença entre stack e heap?"
- **Stack**: Memória automática, LIFO, rápida
- **Heap**: Memória dinâmica, fragmentada, lenta

### "Como funciona virtual memory?"
- **Páginas**: Blocos fixos de memória (4KB típico)
- **MMU**: Memory Management Unit traduz endereços
- **TLB**: Translation Lookaside Buffer (cache)

---

## 📝 Notas de Estudo

### Insights Pessoais
_Espaço para suas descobertas e "aha moments"_

### Conexões Entre Conceitos  
_Como os tópicos se relacionam entre si_

### Aplicações Práticas
_Onde usar cada conceito no mundo real_

---

**Última Atualização:** 2025-09-03  
**Será atualizado:** Automaticamente conforme progresso