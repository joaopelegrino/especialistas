# 🚀 Setup Inicial WSL2 + Claude Code - Checklist Incremental

## 📋 Pré-requisitos (Windows)
- [ ] Windows 11 ou Windows 10 (versão 2004 ou superior)
- [ ] Virtualização habilitada na BIOS
- [ ] 8GB+ RAM recomendado
- [ ] 20GB+ espaço em disco disponível

---

## 📦 Fase 1: Instalação Base WSL2 (30 min)

### 1.1 Ativar WSL2 no Windows
```powershell
# PowerShell como Administrador
- [ ] wsl --install
- [ ] wsl --set-default-version 2
- [ ] Reiniciar o Windows
```

### 1.2 Instalar Ubuntu 24.04
```powershell
- [ ] wsl --install -d Ubuntu-24.04
- [ ] Criar usuário e senha
- [ ] wsl --set-default Ubuntu-24.04
```

### 1.3 Primeira Atualização
```bash
- [ ] sudo apt update && sudo apt upgrade -y
- [ ] sudo apt install -y curl wget git build-essential
```

---

## 🛠️ Fase 2: Configuração Shell (20 min)

### 2.1 Instalar Zsh e Oh My Zsh
```bash
- [ ] sudo apt install -y zsh
- [ ] sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
- [ ] Escolher Zsh como shell padrão quando solicitado
```

### 2.2 Instalar Powerlevel10k
```bash
- [ ] git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
- [ ] Editar ~/.zshrc: ZSH_THEME="powerlevel10k/powerlevel10k"
- [ ] source ~/.zshrc
- [ ] Seguir wizard de configuração (p10k configure)
```

### 2.3 Plugins Essenciais
```bash
# Autosugestões
- [ ] git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Syntax highlighting
- [ ] git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Editar ~/.zshrc
- [ ] plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)
- [ ] source ~/.zshrc
```

---

## 🎨 Fase 3: Configurações do Usuário (15 min)

### 3.1 Clonar Repositório de Configurações
```bash
- [ ] mkdir -p ~/workspace
- [ ] cd ~
- [ ] git clone https://github.com/joaopelegrino/config.git ~/config
```

### 3.2 Criar Links Simbólicos
```bash
# Backup de configurações existentes (se houver)
- [ ] [ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup
- [ ] [ -f ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.backup
- [ ] [ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.backup

# Criar links para configurações
- [ ] ln -sf ~/config/zshrc ~/.zshrc
- [ ] ln -sf ~/config/gitconfig ~/.gitconfig  
- [ ] ln -sf ~/config/vimrc ~/.vimrc
- [ ] ln -sf ~/config/p10k.zsh ~/.p10k.zsh

# Recarregar configurações
- [ ] source ~/.zshrc
```

### 3.3 Configurar Git
```bash
- [ ] git config --global user.name "João Pelegrino"
- [ ] git config --global user.email "seu-email@exemplo.com"
```

---

## 🔧 Fase 4: Ferramentas de Desenvolvimento (25 min)

### 4.1 Python e pip
```bash
- [ ] sudo apt install -y python3 python3-pip python3-venv
- [ ] pip3 install --user pipx
- [ ] pipx ensurepath
```

### 4.2 Node.js via NVM
```bash
# Instalar NVM
- [ ] curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
- [ ] source ~/.zshrc

# Instalar Node.js LTS
- [ ] nvm install --lts
- [ ] nvm use --lts
- [ ] npm install -g npm@latest
```

### 4.3 Ferramentas Rust (para Yazi e outras)
```bash
- [ ] curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
- [ ] source ~/.cargo/env
```

### 4.4 Instalar Yazi (Gerenciador de Arquivos)
```bash
- [ ] cargo install --locked yazi-fm yazi-cli
```

### 4.5 FZF (Fuzzy Finder)
```bash
- [ ] git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
- [ ] ~/.fzf/install --all
```

### 4.6 Ripgrep e fd-find
```bash
- [ ] sudo apt install -y ripgrep fd-find
```

---

## 📝 Fase 5: Vim Avançado (20 min)

### 5.1 Instalar Vim com Suporte Completo
```bash
- [ ] sudo apt install -y vim-gtk3
```

### 5.2 Instalar vim-plug
```bash
- [ ] curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 5.3 Copiar Configurações do Vim
```bash
# Se usar repositório config
- [ ] [ -d ~/config/vim ] && cp -r ~/config/vim/* ~/.vim/

# Instalar plugins
- [ ] vim -c 'PlugInstall' -c 'qa!'
```

### 5.4 Configurar LSP para Vim
```bash
# Python LSP
- [ ] pip3 install --user python-lsp-server

# Node/TypeScript LSP  
- [ ] npm install -g typescript typescript-language-server
```

---

## 🖥️ Fase 6: VSCode e Terminais (15 min)

### 6.1 Instalar VSCode (no Windows)
```powershell
- [ ] Baixar de https://code.visualstudio.com/
- [ ] Instalar com opção "Add to PATH"
```

### 6.2 Extensão WSL para VSCode
```bash
# No WSL
- [ ] code .  # Isso instalará o servidor VSCode no WSL automaticamente
```

### 6.3 Windows Terminal (Opcional)
```powershell
# Microsoft Store ou winget
- [ ] winget install Microsoft.WindowsTerminal
```

### 6.4 Warp Terminal (Opcional - Recomendado)
```bash
- [ ] Baixar de https://www.warp.dev/
- [ ] Configurar para usar WSL2
```

---

## 🐳 Fase 7: Docker (Opcional - 15 min)

### 7.1 Instalar Docker Desktop
```powershell
# No Windows
- [ ] Baixar de https://www.docker.com/products/docker-desktop
- [ ] Instalar com integração WSL2
- [ ] Habilitar integração com sua distro Ubuntu
```

### 7.2 Verificar Instalação
```bash
# No WSL
- [ ] docker --version
- [ ] docker-compose --version
- [ ] docker run hello-world
```

---

## 🤖 Fase 8: Claude Code (10 min)

### 8.1 Instalar Claude Desktop
```powershell
# No Windows
- [ ] Baixar de https://claude.ai/download
- [ ] Instalar Claude Desktop
```

### 8.2 Configurar Claude Code
```bash
# No WSL - criar estrutura inicial
- [ ] mkdir -p ~/.claude
- [ ] mkdir -p ~/workspace/projetos
```

### 8.3 Criar CLAUDE.md no Projeto
```bash
- [ ] cp ~/config/CLAUDE.md ~/workspace/seu-projeto/
# Ou use o template fornecido
```

---

## 🎯 Fase 9: Configurações Finais (10 min)

### 9.1 Criar Arquivo de Variáveis de Ambiente
```bash
- [ ] touch ~/.env
- [ ] chmod 600 ~/.env
# Adicionar tokens e segredos conforme necessário
```

### 9.2 Configurar SSH (se necessário)
```bash
- [ ] ssh-keygen -t ed25519 -C "seu-email@exemplo.com"
- [ ] eval "$(ssh-agent -s)"
- [ ] ssh-add ~/.ssh/id_ed25519
- [ ] cat ~/.ssh/id_ed25519.pub  # Adicionar ao GitHub/GitLab
```

### 9.3 Scripts de Diagnóstico
```bash
# Copiar do repositório config (se disponíveis)
- [ ] chmod +x ~/config/*.sh
- [ ] ~/config/diagnostico-ambiente.sh  # Verificar ambiente
```

---

## ✅ Fase 10: Validação Final (5 min)

### 10.1 Testar Comandos Essenciais
```bash
- [ ] y          # Deve abrir Yazi
- [ ] vim        # Deve abrir com plugins
- [ ] code .     # Deve abrir VSCode
- [ ] docker ps  # Deve listar containers (se Docker instalado)
```

### 10.2 Verificar Integrações
```bash
- [ ] git status      # Git configurado
- [ ] node --version  # Node.js instalado
- [ ] python3 --version # Python instalado
```

### 10.3 Performance Check
```bash
- [ ] time zsh -i -c exit  # Deve ser < 500ms
- [ ] vim --startuptime /tmp/vim-startup.log  # Verificar tempo de carga
```

---

## 📊 Tempo Total Estimado

| Fase | Tempo | Acumulado |
|------|-------|-----------|
| Fase 1 - WSL2 | 30 min | 30 min |
| Fase 2 - Shell | 20 min | 50 min |
| Fase 3 - Config Usuário | 15 min | 65 min |
| Fase 4 - Ferramentas Dev | 25 min | 90 min |
| Fase 5 - Vim | 20 min | 110 min |
| Fase 6 - VSCode | 15 min | 125 min |
| Fase 7 - Docker | 15 min | 140 min |
| Fase 8 - Claude Code | 10 min | 150 min |
| Fase 9 - Config Finais | 10 min | 160 min |
| Fase 10 - Validação | 5 min | 165 min |

**Total: ~2h45min** (sem contar downloads)

---

## 🆘 Troubleshooting Comum

### WSL não inicia
```powershell
wsl --shutdown
wsl --unregister Ubuntu-24.04
wsl --install -d Ubuntu-24.04
```

### Problemas com Vim plugins
```bash
vim -c 'PlugClean' -c 'qa!'
vim -c 'PlugInstall' -c 'qa!'
```

### Shell lento
```bash
# Desabilitar powerlevel10k temporariamente
mv ~/.p10k.zsh ~/.p10k.zsh.bak
source ~/.zshrc
```

### Docker não funciona
```powershell
# No Windows - reiniciar Docker Desktop
# Verificar integração WSL2 nas configurações
```

---

## 📚 Referências
- [Repositório Config](https://github.com/joaopelegrino/config.git)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Claude Code Docs](https://claude.ai/docs)
- [Oh My Zsh](https://ohmyz.sh/)

---

**Última Atualização**: 2025-01-28
**Mantido por**: Claude Code Assistant