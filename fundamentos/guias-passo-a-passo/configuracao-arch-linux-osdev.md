# 🎯 Configuração Arch Linux para OS Development - Guia Passo a Passo

## 📋 Visão Geral
- **Objetivo:** Configurar o Arch Linux recém-instalado como ambiente especializado para desenvolvimento de sistemas operacionais
- **Tempo estimado:** 45-60 minutos
- **Pré-requisitos:** Arch Linux instalado via WSL (✅ Completo!)
- **Resultado final:** Ambiente completo com usuário, ferramentas OS Dev e Windows Terminal configurado

## 🔍 Contexto Educativo

### Por que fazemos isso?
O Arch Linux instalado está em estado "bare minimum" - apenas root user e pacotes essenciais. Para desenvolvimento de OS, precisamos:
1. **Usuário não-root** para segurança e boas práticas
2. **Ferramentas de desenvolvimento** (GCC, NASM, QEMU, etc.)
3. **Ambiente configurado** para integração com Windows Terminal
4. **Rolling release** sempre atualizado

### Como isso se conecta com a trilha?
- **FASE 0:** Preparação completa do ambiente (estamos aqui!)
- **FASE 1-5:** Utilizaremos essas ferramentas para compilação, debug e testes

## 📊 Status Atual Identificado

**✅ Sucesso na Instalação:**
- Arch Linux funcionando
- Acesso root estabelecido
- Sistema base operacional

**⚠️ Problemas Observados:**
- `ll` não existe (precisa de aliases)
- Usuário root ativo (inseguro para desenvolvimento)
- Nenhuma ferramenta de desenvolvimento instalada
- Warning sobre VHD esparso (performance)

**🔧 WSL Config Issue:**
- Chave `wsl2.generateHosts` desconhecida no `.wslconfig`

## 🚀 Passo a Passo Detalhado

### Etapa 1: Correção do .wslconfig
**Windows PowerShell (como Administrador):**
```powershell
# Abrir .wslconfig para correção
notepad C:\Users\valor\.wslconfig

# Remover ou comentar linha 18 que causa erro:
# wsl2.generateHosts=true  # Comentar com # se existir
```

**Explicação:** A chave `generateHosts` pode não existir na sua versão do WSL, causando warnings.

### Etapa 2: Otimização de Performance (Opcional)
**Windows PowerShell:**
```powershell
# Para melhor performance (CUIDADO: experimental)
wsl.exe --manage archlinux --set-sparse --allow-unsafe
```

**⚠️ Atenção:** Só execute se performance estiver lenta. Há risco de corrupção mencionado pelo próprio WSL.

### Etapa 3: Primeira Configuração no Arch Linux
**No Arch Linux (ainda como root):**
```bash
# 1. Atualizar sistema (OBRIGATÓRIO no Arch!)
pacman -Syu

# Confirmar com 'Y' quando perguntado
```

**Explicação:** Arch é rolling release - sempre atualizar após instalação fresca.

### Etapa 4: Instalar Ferramentas Essenciais
**No Arch Linux:**
```bash
# 2. Instalar ferramentas base
pacman -S base-devel git vim sudo which

# base-devel = GCC, make, etc.
# sudo = para criar usuário não-root
# which = comando para localizar executáveis
```

### Etapa 5: Criar Usuário para OS Development
**No Arch Linux:**
```bash
# 3. Criar usuário osdev
useradd -m -G wheel -s /bin/bash osdev

# 4. Definir senha para osdev
passwd osdev
# Digite uma senha segura quando solicitado

# 5. Configurar sudo para grupo wheel
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# 6. Testar sudo
su - osdev
sudo whoami  # Deve retornar "root" se funcionou
```

**Explicação:** 
- `-m` cria diretório home
- `-G wheel` adiciona ao grupo administrativo
- `wheel` é o grupo padrão para sudo no Arch

### Etapa 6: Configurar Aliases e Ambiente
**Como usuário osdev:**
```bash
# 7. Criar aliases úteis
cat >> ~/.bashrc << 'EOF'
# Aliases úteis
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Variáveis para desenvolvimento
export EDITOR=vim
export BROWSER=
export MAKEFLAGS="-j$(nproc)"
EOF

# 8. Recarregar bashrc
source ~/.bashrc

# 9. Testar aliases
ll  # Agora deve funcionar!
```

### Etapa 7: Instalar Ferramentas OS Development
**Como usuário osdev:**
```bash
# 10. Instalar toolchain para OS Dev
sudo pacman -S nasm qemu-full gdb valgrind cmake meson ninja

# nasm = Assembler
# qemu-full = Virtualização completa
# gdb = Debugger
# valgrind = Análise de memória
# cmake/meson/ninja = Build systems modernos
```

### Etapa 8: Configurar Git
**Como usuário osdev:**
```bash
# 11. Configurar Git
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@example.com"
git config --global init.defaultBranch main

# 12. Testar Git
git --version
```

### Etapa 9: Teste de Validação Completo
**Como usuário osdev:**
```bash
# 13. Testar todas as ferramentas
echo "=== TESTE DE VALIDAÇÃO ==="
whoami                    # Deve mostrar "osdev"
gcc --version | head -1   # Versão do GCC
nasm -v                   # Versão do NASM  
qemu-system-x86_64 --version | head -1  # QEMU
gdb --version | head -1   # GDB
ll                        # Alias funcionando
pwd                       # Confirmar diretório

# 14. Criar teste simples
cat > hello.c << 'EOF'
#include <stdio.h>
int main() { 
    printf("Arch Linux OS Dev Ready!\n"); 
    return 0; 
}
EOF

# 15. Compilar e testar
gcc hello.c -o hello
./hello

# Deve imprimir: "Arch Linux OS Dev Ready!"
```

## ✅ Validação de Sucesso

### Como saber se deu certo:
- [ ] Usuário `osdev` criado e funcionando
- [ ] Comando `ll` funciona (aliases configurados)
- [ ] `sudo` funciona sem pedir senha root
- [ ] GCC compila programa C simples
- [ ] NASM disponível para assembly
- [ ] QEMU instalado para virtualização
- [ ] Git configurado corretamente

### Comandos de Validação Final:
```bash
# Como usuário osdev, executar:
whoami && echo "✅ Usuário OK"
ll ~ && echo "✅ Aliases OK" 
gcc --version && echo "✅ GCC OK"
nasm -v && echo "✅ NASM OK"
qemu-system-x86_64 --version && echo "✅ QEMU OK"
sudo whoami && echo "✅ Sudo OK"
```

## 🚨 Troubleshooting

### Problema: "pacman -Syu" falha com erro de chaves
**Sintoma:** Erro sobre assinatura de pacotes
**Causa:** Chaves GPG desatualizadas
**Solução:**
```bash
sudo pacman -S archlinux-keyring
sudo pacman-key --refresh-keys
```

### Problema: Usuário não consegue usar sudo
**Sintoma:** "osdev is not in the sudoers file"
**Causa:** Configuração sudo incorreta
**Solução:**
```bash
# Como root:
usermod -aG wheel osdev
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
```

### Problema: QEMU não funciona
**Sintoma:** Comando não encontrado
**Causa:** Pacote incompleto
**Solução:**
```bash
sudo pacman -S qemu-full qemu-utils
```

### Problema: Performance lenta
**Sintoma:** Comandos demoram muito
**Causa:** VHD não esparso
**Solução (CUIDADO):**
```powershell
# No Windows PowerShell:
wsl --shutdown
wsl.exe --manage archlinux --set-sparse --allow-unsafe
```

## 🖥️ Configuração Windows Terminal

### Etapa 10: Adicionar Perfil Arch no Windows Terminal
**Windows Terminal → Configurações → Perfis → Adicionar:**

```json
{
    "name": "Arch Linux (OS Dev)",
    "commandline": "wsl.exe -d archlinux -u osdev",
    "icon": "🏗️",
    "colorScheme": "One Half Dark",
    "startingDirectory": "/home/osdev",
    "fontSize": 11,
    "fontFace": "Cascadia Code"
}
```

### Personalização Avançada:
```json
{
    "name": "Arch Linux (OS Dev)",
    "commandline": "wsl.exe -d archlinux -u osdev",
    "guid": "{você-pode-gerar-um-guid-aqui}",
    "icon": "🏗️",
    "colorScheme": "Campbell",
    "startingDirectory": "/home/osdev",
    "fontSize": 11,
    "fontFace": "Cascadia Code",
    "backgroundImage": null,
    "useAcrylic": false,
    "acrylicOpacity": 0.8,
    "cursorShape": "bar",
    "snapOnInput": true
}
```

## ➡️ Próximos Passos

### Imediatamente Após Esta Configuração:
1. **Testar Windows Terminal** com novo perfil Arch
2. **Verificar integração** entre Ubuntu e Arch
3. **Configurar VSCode** para reconhecer Arch
4. **Criar workspace** compartilhado

### Na Próxima Sessão:
1. **Instalar AUR helper** (yay) para ferramentas avançadas
2. **Configurar cross-compilation** tools
3. **Setup QEMU** com aceleração hardware
4. **Iniciar FASE 0** da trilha OS Dev

### Conectar com Sistema de Tracking:
```markdown
"Claude, atualizar progresso - completei configuração Arch Linux"
"Claude, marcar ambiente Arch como configurado"
"Claude, registrar 1 hora de configuração de ambiente"
```

## 📚 Recursos Adicionais

### Documentação Oficial:
- [Arch Wiki - WSL](https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL)
- [Pacman Usage](https://wiki.archlinux.org/title/Pacman)
- [User Management](https://wiki.archlinux.org/title/Users_and_groups)

### Comandos de Referência Rápida:
```bash
# Arch-specific
pacman -Syu          # Atualizar sistema
pacman -S package    # Instalar pacote
pacman -Ss search    # Buscar pacote
pacman -Rs package   # Remover pacote

# Sistema
systemctl status     # Status serviços
journalctl -xe       # Logs do sistema
```

### Próximas Ferramentas (AUR):
- `yay` - AUR helper
- `osdev-toolkit` - Ferramentas específicas OS dev
- `cross-compilation` tools

---

**Guia Criado:** 2025-09-03  
**Tempo Estimado Total:** 45-60 minutos  
**Dificuldade:** ⭐⭐⭐ (Intermediário)  
**Status:** 🟢 Pronto para execução

> **Dica:** Execute uma etapa por vez e valide antes de prosseguir. O Arch Linux recompensa paciência e atenção aos detalhes!