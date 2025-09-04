# ✅ CHECKLIST AMBIENTE DUAL - Ubuntu + Arch + r2

## 📋 Visão Geral
Checklist completo para validar configuração dual-environment perfeita para trilha OS Development + Radare2.

---

## 🖥️ AMBIENTE UBUNTU 24.04 (Principal)

### Sistema Base
- [ ] WSL2 Ubuntu 24.04 funcionando
- [ ] Windows Terminal configurado
- [ ] VSCode + Remote WSL extension
- [ ] Git configurado com SSH keys
- [ ] Acesso root funcional (`sudo`)

### Ferramentas Development
- [ ] **Build essentials:** `build-essential, cmake, make`
- [ ] **Version control:** `git, gh (GitHub CLI)`
- [ ] **Editors:** `vim, code (VSCode)`
- [ ] **Documentation:** `pandoc, markdown tools`

### Comandos de Verificação Ubuntu:
```bash
# Sistema
lsb_release -a
uname -a

# Ferramentas essenciais
gcc --version
make --version
git --version

# Espaço disponível
df -h
free -h
```

---

## 🏗️ AMBIENTE ARCH LINUX (Especializado)

### Sistema Arch Básico
- [ ] Arch WSL instalado e funcionando
- [ ] Usuário `osdev` criado
- [ ] Sudo configurado sem senha
- [ ] Pacman funcionando (`pacman -Syu`)
- [ ] Base-devel instalado

### Ferramentas OS Development
- [ ] **Compilation:** `gcc, nasm, make, cmake`
- [ ] **Cross-compilation:** `gcc multilib support`
- [ ] **Virtualization:** `qemu-full (qemu-system-*)`
- [ ] **Debugging:** `gdb, valgrind`
- [ ] **Binary Analysis:** `radare2, ghidra, rizin`

### Comandos de Verificação Arch:
```bash
# Sistema
cat /etc/arch-release
whoami
groups

# Ferramentas OS Dev
pacman -Q gcc nasm qemu-full radare2
r2 -v

# Cross-compilation test
echo 'int main(){return 42;}' > test.c
gcc -m32 test.c -o test32 2>/dev/null && echo "32-bit OK" || echo "Needs multilib"
```

---

## 🔬 RADARE2 CONFIGURATION

### Instalação e Setup
- [ ] r2 instalado (versão >= 5.8.8)
- [ ] Configuração inicial (`.radare2rc`)
- [ ] Syntax highlighting habilitado
- [ ] UTF-8 support configurado

### r2 Basic Tests
```bash
# Versão e features
r2 -v

# Test básico de análise
echo -e '\x48\x31\xc0\xc3' > simple.bin
r2 simple.bin
```

### r2 Configuration File (~/.radare2rc):
```bash
# Syntax highlighting
e scr.color=1
e asm.syntax=intel

# UTF-8 and visual
e scr.utf8=true
e scr.interactive=true

# Analysis settings
e anal.autoname=true
e anal.hasnext=true
```

---

## 🔄 WORKFLOW DUAL-DISTRO

### File Sharing Setup
- [ ] Shared workspace em `/mnt/c/` ou similar
- [ ] Symlinks configurados entre distros
- [ ] Backup automático funcionando

### Terminal Integration
- [ ] Windows Terminal com profiles separados:
  - Ubuntu profile
  - Arch profile  
  - Cores diferentes para identificação

### VSCode Integration
- [ ] Remote WSL funcionando com Ubuntu
- [ ] SSH extension para Arch (se necessário)
- [ ] Extensões essenciais instaladas:
  - C/C++
  - Assembly syntax
  - Hex Editor
  - Git integration

---

## 🧪 TESTES DE INTEGRAÇÃO

### Teste 1: Workflow Básico
```bash
# Ubuntu: criar código
echo 'int main(){return 42;}' > hello.c

# Arch: compilar e analisar
gcc hello.c -o hello
r2 hello
```

### Teste 2: QEMU + r2 Remote Debug
```bash
# Terminal 1 (Arch): QEMU
qemu-system-i386 -s -S -kernel hello &

# Terminal 2 (Arch): r2 remote
r2 -d gdb://localhost:1234
```

### Teste 3: Cross-compilation
```bash
# 16-bit bootloader test
echo 'bits 16\norg 0x7c00\nhlt\ntimes 510-($-$$) db 0\ndw 0xaa55' > boot.asm
nasm boot.asm -o boot.bin
r2 -b 16 boot.bin
```

---

## 📊 PERFORMANCE VALIDATION

### System Resources
```bash
# Memory available (minimum 4GB recommended)
free -h

# Disk space (minimum 50GB recommended)  
df -h

# CPU cores
nproc
```

### Expected Performance:
- **Ubuntu boot:** < 10 seconds
- **Arch boot:** < 15 seconds
- **r2 analysis:** < 2 seconds for small binaries
- **QEMU start:** < 5 seconds
- **VSCode startup:** < 10 seconds

---

## 🚨 TROUBLESHOOTING COMMON ISSUES

### WSL2 Issues
```bash
# WSL2 version check
wsl --version

# Restart WSL if needed
wsl --shutdown
wsl -d Ubuntu
```

### Arch Linux Issues
```bash
# Update keyring if packages fail
sudo pacman -S archlinux-keyring

# Fix locale if needed
sudo locale-gen en_US.UTF-8
```

### r2 Issues
```bash
# Reinstall if commands fail
sudo pacman -S radare2

# Check plugins
r2 -H
```

---

## ✅ FINAL VALIDATION SCRIPT

### Automated Test Script (`test-environment.sh`):
```bash
#!/bin/bash
echo "🧪 Testing Dual Environment Setup..."

# Test 1: Basic tools
echo "Testing basic tools..."
gcc --version >/dev/null && echo "✅ GCC OK" || echo "❌ GCC FAIL"
r2 -v >/dev/null && echo "✅ r2 OK" || echo "❌ r2 FAIL"
qemu-system-i386 --version >/dev/null && echo "✅ QEMU OK" || echo "❌ QEMU FAIL"

# Test 2: Create and analyze binary
echo "Testing workflow..."
echo 'int main(){return 42;}' > /tmp/test.c
gcc /tmp/test.c -o /tmp/test
r2 -c 'aa; pdf @ main' /tmp/test >/dev/null && echo "✅ Workflow OK" || echo "❌ Workflow FAIL"

echo "🎯 Environment validation complete!"
```

---

## 🎓 READY FOR LEARNING

### When All Checkboxes Are ✅:
```markdown
"Claude, iniciar FASE 0 - primeiro exercício r2"
```

### Expected Response:
Claude will create first guided exercise combining C programming with r2 analysis, validating the complete environment setup.

---

**Ambiente Preparado:** Ubuntu + Arch + r2  
**Status:** 🟢 Pronto para trilha OSR2  
**Próximo:** Iniciar FASE 0 com primeiro exercício prático  
**Estimativa setup:** 2-4 horas (se seguir guias existentes)**