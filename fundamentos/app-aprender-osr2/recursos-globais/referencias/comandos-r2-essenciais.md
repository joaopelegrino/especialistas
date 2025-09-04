# 🔬 Comandos r2 Essenciais por Fase - Referência Rápida

## 📋 Visão Geral
Referência completa dos comandos Radare2 organizados por nível de complexidade e fase de aprendizado.

---

## 🔧 BÁSICO (FASE 0-1): r2 Foundation

### Abertura e Navegação
```bash
r2 binary                # Abrir binário
r2 -A binary            # Abrir + análise automática
r2 -d binary            # Modo debug
r2 -b 16 binary         # Modo 16-bit
r2 -d gdb://localhost:1234  # Debug remoto
```

### Análise Inicial
```bash
> aaa                   # Analyze All Autoname
> aa                    # Analyze All
> af                    # Analyze Function
> s address             # Seek to address
> s main                # Seek to main function
```

### Informações do Binário
```bash
> iI                    # Binary info
> ie                    # Entry points
> is                    # Symbols
> ii                    # Imports
> iE                    # Exports
> iz                    # ASCII strings
> izz                   # All strings
```

### Visualização
```bash
> pdf                   # Print Disassembly Function
> pdf @ main           # Disassemble main function
> px 100               # Hex dump 100 bytes
> ps @ address         # Print string at address
> V                    # Visual mode
> VV                   # Visual graph mode
```

---

## ⚙️ INTERMEDIÁRIO (FASE 2-3): Hardware + Kernel

### Modos Específicos
```bash
> e asm.arch=x86       # Set architecture
> e asm.bits=16        # 16-bit mode
> e asm.bits=32        # 32-bit mode
> e asm.syntax=intel   # Intel syntax
> e scr.color=1        # Enable colors
```

### Análise de Funções
```bash
> afi                  # Function info
> afl                  # List functions
> ag                   # Call graph
> axt @ symbol         # Cross-references to
> axf @ symbol         # Cross-references from
```

### Debug Remoto (Kernel)
```bash
> db address           # Set breakpoint
> db main              # Breakpoint at main
> dbc address cmd      # Conditional breakpoint
> dc                   # Continue execution
> ds                   # Step instruction
> dr                   # Show registers
> dr eax               # Show specific register
> dm                   # Memory maps
> dmi                  # Memory info
```

### Memory Analysis
```bash
> px @ address         # Hex dump at address
> pxw @ address        # Hex dump as words
> ps @ address         # String at address
> pf.                  # Parse structures
> dm                   # Memory layout
```

---

## 🔄 AVANÇADO (FASE 4-5): Process + Hardware

### Process Tracing
```bash
> dp                   # List processes/threads
> dpt                  # Thread info  
> dpc                  # Process context
> dpj                  # Processes JSON format
```

### Dynamic Tracing
```bash
> e dbg.trace=true     # Enable tracing
> dt                   # Show trace
> dtd                  # Detailed disasm trace
> dts                  # System call trace
> dt+ cmd              # Trace with command
> dtr                  # Reset trace
```

### Advanced Analysis
```bash
> / pattern            # Search pattern
> /x 414141            # Search hex pattern
> /v value             # Search value
> a/ 0x41414141       # Search possible RIP
```

### Performance & Security
```bash
# Performance
> dt+                  # Detailed performance trace
> dc                   # Continue with profiling

# Security Analysis  
> ii~RELRO             # Check security features
> ii~canary            # Check stack canaries
> iz~password          # Search security strings
```

---

## 🛠️ ESPECIALIZADO: r2 Scripting & Automation

### Configuração Avançada
```bash
# ~/.radare2rc
e scr.color=1
e asm.syntax=intel
e scr.utf8=true
e anal.autoname=true
e dbg.trace=true
```

### Scripts r2
```bash
> . script.r2          # Run r2 script
> #!python             # Python scripting
> #!bash               # Bash scripting
```

### Exportação e Relatórios
```bash
> pdf > function.asm   # Export disassembly
> iz > strings.txt     # Export strings
> is > symbols.txt     # Export symbols
> dr > registers.txt   # Export registers
```

---

## 📊 COMANDOS POR CENÁRIO

### Bootloader Analysis (FASE 2)
```bash
r2 -b 16 bootloader.bin
> e asm.arch=x86
> e asm.bits=16
> s 0x7c00
> pdf
> px @ 0x1fe           # Check boot signature
> iz                   # Strings in bootloader
```

### Kernel Debug (FASE 3)
```bash
# Terminal 1: QEMU
qemu-system-i386 -kernel kernel.bin -S -s

# Terminal 2: r2
r2 -d gdb://localhost:1234
> e asm.arch=x86
> e asm.bits=32
> db 0x1000            # Kernel entry point
> dc
> dr                   # Registers
> dm                   # Memory layout
```

### Race Condition Debug (FASE 4)
```bash
r2 -d ./multithread_program
> e dbg.trace=true
> db pthread_mutex_lock
> db pthread_mutex_unlock
> dc
> dt~shared_counter    # Filter trace for shared variable
```

### Hardware Driver Analysis (FASE 5)
```bash
# PCI device analysis
sudo r2 -d /dev/mem
> s 0xc0000000         # PCI config space
> px 256               # Dump PCI config
> pf.pci_config       # Parse PCI structure
```

---

## 🎯 r2 Workflow Patterns

### Standard Analysis Workflow
```bash
1. r2 binary           # Open
2. aaa                 # Analyze
3. pdf @ main         # Disassemble main
4. iz                  # Check strings
5. is                  # Check symbols
6. ag                  # Call graph
7. Document findings
```

### Debug Workflow
```bash
1. r2 -d binary       # Open in debug mode
2. db main            # Set breakpoint
3. dc                 # Continue to breakpoint
4. ds                 # Step through
5. dr                 # Check registers
6. px @ [reg]         # Examine memory
7. Document behavior
```

### Performance Analysis Workflow
```bash
1. r2 -d binary       # Open in debug
2. e dbg.trace=true   # Enable tracing
3. dc                 # Run with trace
4. dt                 # Analyze trace
5. dt > report.txt    # Export analysis
6. Identify bottlenecks
```

---

## 🚨 Troubleshooting Common Issues

### r2 não reconhece arquitetura
```bash
> e asm.arch=x86      # Force architecture
> e asm.bits=32       # Force 32-bit
> aa                  # Re-analyze
```

### Debug remoto não conecta
```bash
# Check QEMU is running with -S -s
# Check port 1234 is available
netstat -ln | grep 1234

# Reconnect r2
r2 -d gdb://localhost:1234
```

### Análise incompleta
```bash
> aaa                 # Full analysis
> af @ address        # Analyze specific function
> /c int              # Search for calls
```

---

## 📚 Quick Reference Cards

### Navigation
- `s addr` - Seek to address
- `s+N` - Seek forward N bytes  
- `s-N` - Seek backward N bytes
- `s main` - Seek to main function

### Visual Mode
- `V` - Enter visual mode
- `p/P` - Cycle through views
- `hjkl` - Navigate (vim-like)
- `:` - Command prompt in visual
- `q` - Quit visual mode

### Analysis
- `aa` - Analyze all
- `aaa` - Analyze all + autoname
- `af` - Analyze function
- `ag` - Call graph
- `axt` - Cross-references to
- `axf` - Cross-references from

**Referência criada para uso rápido durante sessões de estudo**  
**Organize por fase e complexidade crescente**  
**Sempre documente r2 analysis findings**