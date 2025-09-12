#!/bin/bash
# setup-phase.sh - Setup automático para iniciar nova fase
# Usage: ./setup-phase.sh [fase_number]

set -e

FASE_NUM=$1
BASE_DIR="/home/notebook/workspace/especialistas/fundamentos/app-aprender-osr2"

if [ -z "$FASE_NUM" ]; then
    echo "❌ Usage: $0 [fase_number]"
    echo "   Example: $0 1"
    exit 1
fi

# Define phase info
case $FASE_NUM in
    0)
        FASE_NAME="AMBIENTE"
        FASE_EMOJI="🔧"
        FASE_DESCRIPTION="Ambiente Dual + r2 Setup"
        ;;
    1)
        FASE_NAME="FUNDAMENTOS"
        FASE_EMOJI="💻"
        FASE_DESCRIPTION="C/C++ + Análise Binária"
        ;;
    2)
        FASE_NAME="HARDWARE"
        FASE_EMOJI="⚙️"
        FASE_DESCRIPTION="Hardware x86 + Bootloaders"
        ;;
    3)
        FASE_NAME="KERNEL"
        FASE_EMOJI="🖥️"
        FASE_DESCRIPTION="Kernel Development + r2 Debug"
        ;;
    4)
        FASE_NAME="PROCESSOS"
        FASE_EMOJI="🔄"
        FASE_DESCRIPTION="Multitasking + Process Tracing"
        ;;
    5)
        FASE_NAME="EXTENSOES"
        FASE_EMOJI="🔌"
        FASE_DESCRIPTION="I/O + Drivers + Hardware Analysis"
        ;;
    *)
        echo "❌ Fase inválida: $FASE_NUM (use 0-5)"
        exit 1
        ;;
esac

FASE_DIR="${BASE_DIR}/FASE_${FASE_NUM}_${FASE_NAME}"

echo "🚀 Iniciando setup FASE ${FASE_NUM}: ${FASE_EMOJI} ${FASE_DESCRIPTION}"

# Check if phase directory exists
if [ ! -d "$FASE_DIR" ]; then
    echo "❌ Diretório da fase não encontrado: $FASE_DIR"
    exit 1
fi

# Create workspace directory for current session
WORKSPACE_DIR="${FASE_DIR}/workspace-atual"
mkdir -p "$WORKSPACE_DIR"

# Create session log
SESSION_LOG="${WORKSPACE_DIR}/session-$(date +%Y%m%d-%H%M).md"

cat > "$SESSION_LOG" << EOF
# 📚 Sessão de Estudo - FASE ${FASE_NUM}

**Data:** $(date +"%Y-%m-%d %H:%M")  
**Fase:** ${FASE_EMOJI} FASE ${FASE_NUM} - ${FASE_DESCRIPTION}  
**Status:** Iniciada  

## 🎯 Objetivos da Sessão
- [ ] Objetivo 1
- [ ] Objetivo 2
- [ ] Objetivo 3

## 📝 Notas de Estudo

### Conceitos Aprendidos


### Problemas Encontrados


### r2 Commands Úteis


## ✅ Conquistas da Sessão
- [ ] 

## ➡️ Próximos Passos


---
**Sessão criada automaticamente pelo setup-phase.sh**
EOF

# Setup development environment based on phase
case $FASE_NUM in
    0|1)
        # Setup for basic development
        echo "🔧 Configurando ambiente básico..."
        cd "$WORKSPACE_DIR"
        mkdir -p {src,bin,tests,docs}
        ;;
    2|3)
        # Setup for kernel/bootloader development
        echo "🔧 Configurando ambiente kernel/bootloader..."
        cd "$WORKSPACE_DIR"
        mkdir -p {src,bin,qemu-tests,r2-analysis}
        
        # Create basic kernel development files
        cat > "src/Makefile.template" << 'EOF'
# Template Makefile for kernel development
CC=gcc
LD=ld
NASM=nasm

CFLAGS=-g -ffreestanding -Wall -Wextra
LDFLAGS=-Ttext 0x1000 --oformat binary

# Add your targets here
all:
	@echo "Configure your Makefile targets"

clean:
	rm -f *.o *.bin *.img

.PHONY: all clean
EOF
        ;;
    4|5)
        # Setup for advanced development
        echo "🔧 Configurando ambiente avançado..."
        cd "$WORKSPACE_DIR"
        mkdir -p {src,bin,tests,drivers,network,r2-analysis}
        ;;
esac

# Create r2 analysis template for the session
R2_TEMPLATE="${WORKSPACE_DIR}/r2-analysis-template.md"
cat > "$R2_TEMPLATE" << EOF
# 🔬 r2 Analysis - FASE ${FASE_NUM} Session

## Binary Analyzed
- **File:** 
- **Architecture:** 
- **Compilation:** 

## Static Analysis
\`\`\`bash
r2 [binary]
> aaa
> pdf @ main
\`\`\`

### Findings
- 

## Dynamic Analysis (if applicable)
\`\`\`bash
r2 -d [binary] / r2 -d gdb://localhost:1234
\`\`\`

### Execution Trace
- 

## Insights & Learning
- 
- 
- 

## Next Steps
- 
EOF

# Create quick reference for current phase
QUICK_REF="${WORKSPACE_DIR}/commands-reference.md"
case $FASE_NUM in
    0)
        cat > "$QUICK_REF" << 'EOF'
# 🔧 FASE 0 - Comandos Essenciais

## r2 Basic Commands
```bash
r2 binary                # Open binary
> aaa                    # Analyze all
> V                      # Visual mode  
> pdf @ main            # Disassemble function
> iz                     # List strings
> iI                     # Binary info
```

## Environment Setup
```bash
# Test Arch Linux
whoami
pacman -Q gcc nasm radare2

# Test r2
r2 -v
```
EOF
        ;;
    1)
        cat > "$QUICK_REF" << 'EOF'
# 💻 FASE 1 - Comandos r2 + C/C++

## r2 Static Analysis
```bash
r2 binary
> aaa                    # Analyze all
> af                     # Analyze function
> afi                    # Function info
> axt @ symbol          # Cross-references to
> ag                     # Call graph
```

## Compilation + Analysis
```bash
gcc -g program.c -o program
r2 program
> pdf @ main            # Disassemble main
> dr                     # Show registers (debug mode)
```
EOF
        ;;
    2)
        cat > "$QUICK_REF" << 'EOF'
# ⚙️ FASE 2 - r2 Hardware + Bootloader

## 16-bit Analysis
```bash
r2 -b 16 bootloader.bin
> e asm.arch=x86
> e asm.bits=16
> pd 20                  # Disassemble 20 instructions
```

## Remote Debugging
```bash
# Terminal 1: QEMU
qemu-system-i386 -drive format=raw,file=boot.bin -S -s

# Terminal 2: r2
r2 -d gdb://localhost:1234
> db 0x7c00             # Breakpoint at boot sector
> dc                     # Continue
```
EOF
        ;;
    3)
        cat > "$QUICK_REF" << 'EOF'
# 🖥️ FASE 3 - r2 Kernel Debug

## Kernel Remote Debug
```bash
qemu-system-i386 -kernel kernel.bin -S -s
r2 -d gdb://localhost:1234
> e asm.arch=x86
> e asm.bits=32
```

## Memory Analysis
```bash
> dm                     # Memory maps
> dmi                    # Memory info  
> px @ address          # Hex dump
> dbt                    # Backtrace (crash analysis)
```
EOF
        ;;
    4)
        cat > "$QUICK_REF" << 'EOF'
# 🔄 FASE 4 - r2 Process Tracing

## Process Analysis
```bash
r2 -d ./multithread_program
> dp                     # List processes/threads
> dpt                    # Thread info
> dt                     # Trace execution
```

## Concurrency Debug
```bash
> e dbg.trace=true
> dc                     # Continue with trace
> dt~shared_var         # Filter trace
```
EOF
        ;;
    5)
        cat > "$QUICK_REF" << 'EOF'
# 🔌 FASE 5 - r2 Hardware Analysis

## Hardware Probing
```bash
r2 -d /dev/mem
> s 0xc0000000          # PCI config space
> px 256                 # Config dump
```

## Performance Profiling
```bash
> dt+                    # Detailed trace
> dc                     # Run system
> dt                     # Analyze performance
```
EOF
        ;;
esac

# Update progress tracker
PROGRESS_FILE="${BASE_DIR}/../PROGRESSO_TRACKER.md"
if [ -f "$PROGRESS_FILE" ]; then
    # Add session start to progress tracker
    echo "## 📅 $(date +%Y-%m-%d) - FASE ${FASE_NUM} Iniciada" >> "$PROGRESS_FILE"
    echo "- **Sessão:** ${SESSION_LOG##*/}" >> "$PROGRESS_FILE"
    echo "- **Workspace:** ${WORKSPACE_DIR##*/}" >> "$PROGRESS_FILE"
    echo "" >> "$PROGRESS_FILE"
fi

echo "✅ Setup FASE ${FASE_NUM} completo!"
echo ""
echo "📂 Workspace criado: $WORKSPACE_DIR"
echo "📝 Session log: $SESSION_LOG"
echo "🔍 Quick reference: $QUICK_REF"
echo "🔬 r2 template: $R2_TEMPLATE"
echo ""
echo "🚀 Para começar:"
echo "   cd $WORKSPACE_DIR"
echo "   vim $SESSION_LOG"
echo ""
echo "💡 Next commands:"
echo "   'Claude, iniciar exercício [nome] da FASE ${FASE_NUM}'"
echo "   'Claude, criar projeto [nome] para FASE ${FASE_NUM}'"