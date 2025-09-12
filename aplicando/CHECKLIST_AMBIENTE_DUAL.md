# ✅ CHECKLIST AMBIENTE DUAL - Ubuntu + Arch Minimal + r2

## 📋 Visão Geral
Checklist completo para validar configuração dual-environment perfeita para trilha OSR2 (OS Development + Radare2), considerando o **Arch Linux em estado minimal** no WSL.

---

## 🚨 AVISO IMPORTANTE - Arch Linux Minimal

### Estado Inicial do Arch WSL:
O Arch Linux instalado via WSL vem **extremamente minimal**:
- ❌ **Sem sudo** - todos comandos executados como root inicialmente
- ❌ **Sem which, locate, man** - comandos básicos ausentes
- ❌ **Sem systemctl/systemd** - não usar comandos de serviço
- ❌ **Sem base-devel** - sem gcc, make, etc.
- ❌ **Apenas root** configurado
- ✅ **Apenas pacman** disponível (precisa sincronização)

### Primeiro Setup OBRIGATÓRIO no Arch:
```bash
# Executar como root (estado inicial)
pacman -Sy                                    # Sincronizar repositórios
pacman -Syu                                  # Atualizar sistema
pacman -S base-devel sudo which man-db man-pages  # Ferramentas essenciais
```

---

## 🖥️ AMBIENTE UBUNTU 24.04 (Principal)

### Sistema Base
- [x] WSL2 Ubuntu 24.04 funcionando
- [ ] Windows Terminal configurado
- [ ] VSCode + Remote WSL extension
- [ ] Git configurado com SSH keys
- [x] Acesso root funcional (`sudo`)

### Ferramentas Development
- [x] **Build essentials:** `build-essential, cmake, make`
- [x] **Version control:** `git, gh (GitHub CLI)`
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

## 🏗️ AMBIENTE ARCH LINUX (Minimal → Completo)

### 🔴 FASE 1: Setup Básico do Arch Minimal
- [ ] Arch WSL instalado e acessível
- [ ] Repositórios sincronizados (`pacman -Sy`)
- [ ] Sistema atualizado (`pacman -Syu`)
- [ ] Base-devel instalado (`pacman -S base-devel`)
- [ ] Sudo instalado (`pacman -S sudo`)
- [ ] Comandos básicos (`pacman -S which man-db man-pages`)

### 🟡 FASE 2: Criação de Usuário
- [ ] Usuário `oseng` criado (`useradd -m -G wheel oseng`)
- [ ] Senha definida (`passwd oseng`)
- [ ] Sudo configurado (`visudo` - descomentar %wheel)
- [ ] Login testado (`su - oseng`)

### 🟢 FASE 3: Ferramentas OS Development
- [ ] **Compilation:** `gcc, nasm, make, cmake`
- [ ] **Cross-compilation:** `gcc multilib support`
- [ ] **Virtualization:** `qemu-full (qemu-system-*)`
- [ ] **Debugging:** `gdb, valgrind`
- [ ] **Binary Analysis:** `radare2, rizin`

### Comandos de Instalação Arch (como root):
```bash
# FASE 1 - Básico
pacman -Sy
pacman -Syu
pacman -S base-devel sudo which man-db man-pages

# FASE 2 - Usuário
useradd -m -G wheel oseng
passwd oseng
# Editar /etc/sudoers com visudo

# FASE 3 - Ferramentas Development
pacman -S gcc nasm make cmake
pacman -S qemu-full
pacman -S gdb valgrind
pacman -S radare2
```

### Verificação Estado Arch:
```bash
# Verificar se comando existe antes de usar
command -v gcc >/dev/null 2>&1 && echo "✅ gcc instalado" || echo "❌ gcc faltando"
command -v r2 >/dev/null 2>&1 && echo "✅ r2 instalado" || echo "❌ r2 faltando"
command -v qemu-system-i386 >/dev/null 2>&1 && echo "✅ QEMU instalado" || echo "❌ QEMU faltando"
```

---

## 🔬 RADARE2 CONFIGURATION

### Instalação no Arch Minimal
```bash
# Como root (se sudo não configurado ainda)
pacman -S radare2

# Verificar instalação
r2 -v
```

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
# Criar arquivo de configuração
cat > ~/.radare2rc << 'EOF'
# Syntax highlighting
e scr.color=1
e asm.syntax=intel

# UTF-8 and visual
e scr.utf8=true
e scr.interactive=true

# Analysis settings
e anal.autoname=true
e anal.hasnext=true
EOF
```

---

## 🔄 WORKFLOW DUAL-DISTRO

### File Sharing Setup
- [ ] Shared workspace configurado
- [ ] Acesso entre Ubuntu e Arch funcionando
- [ ] Permissões corretas nos arquivos

### Terminal Integration
- [ ] Windows Terminal com profiles:
  ```json
  {
    "name": "Ubuntu OSR2",
    "commandline": "wsl.exe -d Ubuntu",
    "colorScheme": "Campbell Powershell"
  },
  {
    "name": "Arch OSR2",
    "commandline": "wsl.exe -d Arch",
    "colorScheme": "One Half Dark"
  }
  ```

### Acesso Entre Distros
```bash
# Do Ubuntu, acessar Arch
cd /mnt/wsl/distro/Arch/

# Do Arch, acessar Ubuntu  
cd /mnt/wsl/distro/Ubuntu/
```

---

## 🧪 TESTES DE INTEGRAÇÃO

### Teste 1: Verificar Ferramentas Básicas
```bash
#!/bin/bash
# Script para testar ferramentas (Arch)

echo "🔍 Verificando ferramentas no Arch..."

# Array de comandos para testar
commands=("gcc" "make" "nasm" "r2" "qemu-system-i386" "gdb")

for cmd in "${commands[@]}"; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "✅ $cmd: instalado"
    else
        echo "❌ $cmd: NÃO instalado - instalar com: pacman -S [pacote]"
    fi
done
```

### Teste 2: Workflow Compilação + r2
```bash
# Criar programa teste
cat > test.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello OSR2!\n");
    return 42;
}
EOF

# Compilar (verificar gcc primeiro)
command -v gcc >/dev/null 2>&1 || { echo "gcc não instalado"; exit 1; }
gcc test.c -o test

# Analisar com r2 (verificar r2 primeiro)
command -v r2 >/dev/null 2>&1 || { echo "r2 não instalado"; exit 1; }
r2 -c 'aa; pdf @ main' test
```

---

## 📊 VALIDAÇÃO DE RECURSOS

### System Resources Check
```bash
# Memory (funciona no Arch minimal)
cat /proc/meminfo | grep MemTotal

# Disk space (funciona no Arch minimal)
df -h /

# CPU cores (funciona no Arch minimal)
cat /proc/cpuinfo | grep processor | wc -l
```

### Recursos Mínimos Recomendados:
- **RAM:** 4GB+ disponível
- **Disco:** 50GB+ livre
- **CPU:** 2+ cores

---

## 🚨 TROUBLESHOOTING ARCH MINIMAL

### Problema: "sudo: command not found"
```bash
# Como root
pacman -S sudo
# Configurar sudoers com visudo
```

### Problema: "which: command not found"
```bash
# Como root
pacman -S which
```

### Problema: "systemctl: command not found"
```bash
# Arch WSL não tem systemd por padrão
# Usar alternativas ou scripts diretos
# NÃO tentar instalar systemd no WSL
```

### Problema: Pacman key errors
```bash
# Como root
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring
```

---

## ✅ SCRIPT VALIDAÇÃO COMPLETA

### Script Automático (`validate-osr2-env.sh`):
```bash
#!/bin/bash
# Script para validar ambiente OSR2 completo

echo "🔍 Validando Ambiente OSR2..."
echo "================================"

# Função helper para testar comandos
check_command() {
    if command -v $1 >/dev/null 2>&1; then
        echo "✅ $1: OK"
        return 0
    else
        echo "❌ $1: FALTANDO"
        return 1
    fi
}

# Testar ferramentas essenciais
echo -e "\n📦 Ferramentas Essenciais:"
check_command gcc
check_command make
check_command nasm
check_command r2
check_command qemu-system-i386

# Testar ambiente
echo -e "\n🖥️ Ambiente:"
if [ -f /etc/arch-release ]; then
    echo "✅ Arch Linux detectado"
else
    echo "⚠️ Não está no Arch Linux"
fi

# Testar compilação básica
echo -e "\n🔨 Teste de Compilação:"
echo 'int main(){return 42;}' > /tmp/test.c
if gcc /tmp/test.c -o /tmp/test 2>/dev/null; then
    echo "✅ Compilação C: OK"
else
    echo "❌ Compilação C: FALHOU"
fi

# Testar r2
echo -e "\n🔬 Teste Radare2:"
if command -v r2 >/dev/null 2>&1; then
    r2 -v | head -1
    echo "✅ r2: Funcionando"
else
    echo "❌ r2: Não instalado"
fi

echo -e "\n================================"
echo "📊 Validação Completa!"
```

---

## 🎓 PRÓXIMOS PASSOS

### Quando Setup Básico Estiver Pronto:
```markdown
"Claude, criar guia arch-minimal-setup.md"
```

### Quando Ambiente Completo Estiver OK:
```markdown
"Claude, iniciar FASE 0 da trilha OSR2"
```

---

**Checklist Atualizado:** 2025-09-04  
**Considera:** Arch Linux Minimal (sem sudo, systemd, comandos básicos)  
**Status:** 🟡 Requer setup inicial do Arch  
**Próximo:** Seguir guia arch-minimal-setup.md para configuração completa