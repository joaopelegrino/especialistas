# 🚀 Warp Terminal - Quick Reference Card

**Ambiente:** WSL2 Ubuntu 24.04 + Zsh + Claude Code v1.0.113  
**Baseado no:** Ambiente configurado em `~/config/README.md`  
**Data:** 18/09/2025

---

## ⌨️ Atalhos Essenciais

### 📑 Abas (Tabs)
| Ação | Atalho | Descrição |
|------|--------|-----------|
| **Nova aba** | `CTRL+SHIFT+T` | Cria nova aba |
| **Fechar aba** | `CTRL+SHIFT+W` | Fecha aba ativa |
| **Ir para aba** | `CTRL+1` a `CTRL+9` | Navegar diretamente |
| **Reabrir aba** | `CTRL+ALT+T` | Restaurar aba fechada |
| **Renomear** | Duplo clique | Editar nome da aba |

### 🔲 Painéis (Panes)
| Ação | Atalho | Descrição |
|------|--------|-----------|
| **Dividir →** | `CTRL+SHIFT+D` | Novo painel à direita |
| **Dividir ↓** | `CTRL+SHIFT+E` | Novo painel abaixo |
| **Navegar** | `CTRL+ALT+Setas` | Entre painéis |
| **Maximizar** | `CTRL+SHIFT+ENTER` | Expandir painel |
| **Redimensionar** | `CTRL+SHIFT+Setas` | Ajustar tamanho |

### 🎮 Funcionalidades Avançadas
| Ação | Atalho | Descrição |
|------|--------|-----------|
| **Command Palette** | `CTRL+SHIFT+P` | Comandos rápidos |
| **Configurações** | `CTRL+,` | Abrir settings |
| **Busca histórico** | `CTRL+R` | Histórico comandos |
| **AI Assistant** | `CTRL+SHIFT+A` | Assistente AI |

---

## 💻 Comandos do seu Ambiente

### 🗂️ Navegação Rápida (Aliases configurados)
```bash
ws                  # cd ~/workspace
conf               # cd ~/config  
app-controle       # Ir para projeto app-controle
y                  # Abrir Yazi
yy                 # Yazi com cd integrado
```

### ⚙️ Configurações (Seus aliases)
```bash
ved                # Editar ~/.vimrc
zed                # Editar ~/.zshrc
reload             # Recarregar shell (source ~/.zshrc)
```

### 🤖 Claude Code (v1.0.113)
```bash
claude --version   # Verificar versão
claude doctor      # Diagnóstico completo
claude -p "prompt" # Usar AI para comandos
```

### 🔍 Diagnóstico (Seus scripts)
```bash
vim-diag           # Diagnóstico completo Vim
~/config/diagnostico-ambiente.sh  # Diagnóstico WSL
```

### 📦 Git Helpers (Suas funções)
```bash
remoteadd <repo>          # Adicionar remote com token
remoteadd_personal <repo> # Remote pessoal
sync_repos               # Push múltiplos remotes
```

### 🐳 Docker (Configurado)
```bash
docker ps            # Containers ativos
docker-compose up -d # Subir serviços
dps                 # docker ps formatado (alias)
```

---

## 🎯 Workflows Rápidos

### 🚀 Setup Desenvolvimento (4 abas)
```bash
# Aba 1: Workspace principal
CTRL+SHIFT+T → cd ~/workspace

# Aba 2: Editor
CTRL+SHIFT+T → cd ~/workspace/learning → vim

# Aba 3: Navegador de arquivos  
CTRL+SHIFT+T → yy ~/workspace

# Aba 4: AI Assistant
CTRL+SHIFT+T → claude doctor
```

### 🔧 Painéis Monitoramento
```bash
# Painel principal: desenvolvimento
cd ~/workspace/projeto

# Dividir à direita: sistema
CTRL+SHIFT+D → htop

# Dividir abaixo: docker
CTRL+SHIFT+E → docker stats
```

---

## ✅ Checklist Diário

### ☀️ Setup Matinal
- [ ] `claude doctor` - Verificar Claude Code
- [ ] `vim-diag` - Verificar Vim
- [ ] `docker ps` - Verificar containers
- [ ] `cd ~/workspace && git status` - Status projetos

### 🌙 Finalização
- [ ] `sync_repos` - Sincronizar repositórios
- [ ] `cd ~/config && git add . && git commit -m "Backup $(date)"` - Backup configs
- [ ] Fechar abas desnecessárias (`CTRL+SHIFT+W`)

---

## 🚨 Troubleshooting Rápido

### Warp não detecta WSL
```bash
echo $TERM_PROGRAM      # Deve ser: WarpTerminal
echo $WARP_IS_LOCAL_SHELL_SESSION  # Deve ser: 1
```

### Claude Code não funciona
```bash
claude --version        # Deve ser: 1.0.113
claude doctor          # Verificar instalação
```

### Zsh lento ou com erro
```bash
source ~/.zshrc        # Recarregar configurações
reload                 # Alias para recarregar
```

### Vim com problemas
```bash
vim-diag              # Diagnóstico completo
vim -c 'PlugStatus'   # Status plugins
```

---

## 🎓 Comandos de Aprendizado

### Explorar Ambiente
```bash
# Ver estrutura completa
tree ~/workspace -L 2

# Verificar configurações ativas
env | grep WARP

# Listar aliases disponíveis  
alias | grep -E "^(y|ved|zed|ws|conf)"

# Ver funções personalizadas
declare -f | grep -A 5 "remoteadd\|sync_repos"
```

### Claude AI para Aprendizado
```bash
# Ajuda contextual
claude -p "Explain this command: $(history | tail -1)"

# Gerar estruturas
claude -p "Generate a project structure for learning Python"

# Debugging
claude -p "Help me debug this bash script error: [error]"
```

---

## 📱 Layout de Trabalho Recomendado

### Layout 1: Desenvolvimento Full
```
┌─────────────────┬─────────────────┐
│   Aba 1: Code   │   Aba 2: Test   │
│   ~/workspace   │   npm test      │
├─────────────────┼─────────────────┤
│   Aba 3: Files │   Aba 4: AI     │
│   yazi          │   claude        │
└─────────────────┴─────────────────┘
```

### Layout 2: Monitoramento
```
┌───────────────────────────────────┐
│         Aba 1: Main Work          │
├─────────────────┬─────────────────┤
│   Painel: Logs  │ Painel: System  │
│   tail -f       │   htop/docker   │
└─────────────────┴─────────────────┘
```

---

## 🔗 Links Rápidos

### Documentação Local
- `~/config/README.md` - Manual completo ambiente
- `~/workspace/especialistas/warp/README.md` - Guia Warp completo
- `~/config/vim-README.md` - Guia completo Vim

### Scripts Úteis
- `~/workspace/especialistas/warp/examples/orchestration-script.sh` - Orquestração
- `~/config/vim-diagnostic.sh` - Diagnóstico Vim
- `~/config/sync-vim-config.sh` - Sync configs Vim

---

## 💡 Dicas Pro

### Produtividade
- Use `CTRL+1-9` para navegar abas rapidamente
- Nomeie abas com duplo-clique para organizar
- `CTRL+SHIFT+P` para acessar qualquer função
- Use painéis para monitoramento contínuo

### Performance
- Feche abas não utilizadas
- Use `reload` após mudanças no shell
- Monitor memory com `htop` em painel separado

### Automação
- Crie aliases para comandos frequentes
- Use workflows do arquivo `dev-workspace.yml`
- Configure notebooks para comandos complexos

---

**📋 Este quick reference está baseado no seu ambiente atual**  
**🔄 Última atualização:** 18/09/2025  
**⚡ Para consulta offline:** `cat ~/workspace/especialistas/warp/guides/quick-reference.md`