# 📋 INSTRUÇÕES DE USO - Sistema Claude Code + Trilha OSR2

## 🎯 Visão Geral do Workflow

Este sistema foi configurado para **aprendizado dual-terminal**:
- **Claude Code (Ubuntu WSL):** Cria guias detalhados, mantém documentação
- **Terminal Separado (Arch WSL):** Execução prática, desenvolvimento, análises r2

---

## 🚀 Como Iniciar uma Sessão de Estudo

### 1. Comando de Início
```markdown
"Claude, iniciar FASE [número] da trilha OSR2"
```

**Exemplo:**
```markdown
"Claude, iniciar FASE 0 da trilha OSR2"
```

### 2. O que Acontece Automaticamente
- ✅ Claude detecta que é tarefa de desenvolvimento
- ✅ Cria guia detalhado para execução no Arch
- ✅ Prepara templates para documentar resultados
- ✅ Atualiza contador de sessões
- ✅ Configura ambiente de aprendizado

---

## 💻 Workflow de Desenvolvimento

### Passo 1: Claude Code Cria Guia
Claude gerará um guia similar a este:

```markdown
# 🔧 FASE 1: Análise r2 de Programa C - Guia Terminal Arch

## Para Executar no Terminal Arch WSL

### Abrir Arch WSL
```bash
# No Windows Terminal
wsl -d Arch
cd /home/osdev/workspace
```

### Comandos para Executar
```bash
# 1. Criar programa
echo 'int main(){return 42;}' > hello.c

# 2. Compilar
gcc -g hello.c -o hello

# 3. Análise r2
r2 hello
```

### Comandos r2 Específicos
```bash
# Dentro do r2:
> aaa
> pdf @ main
> iz
```

### Documentar Resultados
Salvar em: `hello-r2-analysis.txt`
```

### Passo 2: Você Executa no Terminal Arch
1. **Abra Windows Terminal**
2. **Selecione perfil Arch WSL** 
3. **Execute comandos** do guia step-by-step
4. **Documente resultados** conforme orientações

### Passo 3: Sincronização Automática
- Claude monitora shared folders
- Processa seus resultados automaticamente
- Atualiza PROGRESSO_TRACKER.md
- Sugere próximos passos

---

## 📝 Tipos de Comandos Disponíveis

### Comandos de Fase
```markdown
"Claude, iniciar FASE [0-5] da trilha OSR2"
"Claude, checkpoint FASE [número].[sub-número]"
"Claude, resumo progresso FASE [número]"
```

### Comandos de Exercício
```markdown
"Claude, criar exercício sobre [tópico] com r2"
"Claude, exercício debugging [problema específico]"
"Claude, exercício análise [tipo de binário]"
```

### Comandos de Projeto
```markdown
"Claude, projeto bootloader básico com r2 analysis"
"Claude, projeto kernel mínimo com debugging"
"Claude, projeto final FASE [número]"
```

### Comandos de Suporte
```markdown
"Claude, explicar conceito [X] com exemplos r2"
"Claude, troubleshooting [problema] no Arch"
"Claude, validar ambiente para FASE [número]"
```

---

## 🔧 Configuração dos Terminais

### Windows Terminal Setup Recomendado

#### Perfil Ubuntu (Documentação)
```json
{
  "name": "Ubuntu - OSR2 Docs",
  "commandline": "wsl.exe -d Ubuntu",
  "startingDirectory": "//wsl$/Ubuntu/home/notebook/workspace/especialistas/fundamentos",
  "colorScheme": "Campbell Powershell"
}
```

#### Perfil Arch (Desenvolvimento) 
```json
{
  "name": "Arch - OSR2 Dev",
  "commandline": "wsl.exe -d Arch",
  "startingDirectory": "//wsl$/Arch/home/osdev/workspace", 
  "colorScheme": "One Half Dark"
}
```

### Workflow Recomendado
1. **Tela dividida:** Ubuntu (esquerda) + Arch (direita)
2. **Claude Code no Ubuntu:** Para interação e documentação
3. **Terminal Arch:** Para execução de comandos práticos

---

## 📊 Sistema de Progresso

### Tracking Automático
- **Sessões:** Contador automático de sessões
- **Tempo:** Estimativa baseada em atividades
- **Checkpoints:** Validação automática de conclusão
- **Dificuldades:** Identificação de áreas problemáticas

### Arquivos de Progresso
- `PROGRESSO_TRACKER.md` - Status geral atualizado automaticamente
- `.claude/settings.local.json` - Estado atual da trilha
- `sessoes/` - Logs detalhados de cada sessão

---

## 🔍 Sistema de Validação

### Checkpoints Automáticos
Cada fase tem 3 checkpoints principais:
- **Teórico:** Conceitos compreendidos
- **Prático:** Projeto funcional
- **r2 Analysis:** Documentação técnica completa

### Comando de Validação
```markdown
"Claude, validar checkpoint FASE [X].[Y]"
```

Claude verificará:
- ✅ Arquivos necessários criados
- ✅ Documentação r2 completa
- ✅ Critérios funcionais atendidos
- ✅ Próximos passos preparados

---

## 🚨 Troubleshooting Comum

### Problema: "Comando não funciona no Ubuntu"
**Solução:** Comandos de desenvolvimento (gcc, r2, qemu) devem ser executados no **Arch WSL**, não no Ubuntu.

### Problema: "Não encontro os arquivos"
**Solução:** Verificar paths compartilhados:
- Ubuntu: `/mnt/c/Users/*/workspace/`
- Arch: `/mnt/c/Users/*/workspace/`

### Problema: "r2 analysis não aparece"
**Solução:** 
1. Salvar resultados r2 em arquivo `.txt`
2. Copiar para shared folder
3. Claude sincronizará automaticamente

### Problema: "Perdeu progresso de sessão"
**Solução:** Estado mantido em `.claude/settings.local.json` - sempre preservado entre reinicializações.

---

## 🎯 Comandos de Exemplo Completos

### Exemplo 1: Primeira Sessão
```markdown
Você: "Claude, iniciar FASE 0 da trilha OSR2"

Claude: [Cria guia detalhado para setup Arch + primeiro r2 test]

Você: [Executa no terminal Arch, documenta resultados]

Você: "Claude, concluí o exercício, próximo passo?"

Claude: [Processa resultados, sugere próxima atividade]
```

### Exemplo 2: Debugging
```markdown
Você: "Claude, meu bootloader não está bootando no QEMU"

Claude: [Cria guia troubleshooting específico com:]
- Verificações step-by-step
- Comandos r2 para debug
- Soluções comuns
- Validation checklist
```

### Exemplo 3: Checkpoint
```markdown
Você: "Claude, validar checkpoint FASE 2.1"

Claude: [Verifica automaticamente:]
- Bootloader.bin existe e funciona?
- Análise r2 documentada?
- QEMU test executado?
- Próxima etapa preparada?
```

---

## 🏆 Maximizando o Aprendizado

### Dicas de Eficiência
1. **Sempre documente** saídas r2 em arquivos `.txt`
2. **Use nomes descritivos** para projetos e análises  
3. **Execute checkpoints** regularmente para validar progresso
4. **Mantenha terminal dividido** para workflow fluido

### Comandos de Produtividade
```markdown
"Claude, resumir sessão atual"           # Status atual
"Claude, backup progresso"               # Salvar estado
"Claude, estimativa tempo restante"      # Planning
"Claude, áreas de dificuldade"           # Foco estudo
```

---

## ✅ Checklist de Setup Completo

Antes de começar, verificar:
- [ ] Windows Terminal com perfis Ubuntu e Arch configurados
- [ ] Arch WSL com usuário `osdev` funcional  
- [ ] r2, gcc, nasm, qemu instalados no Arch
- [ ] Shared folders acessíveis em ambos WSL
- [ ] Claude Code funcionando no Ubuntu
- [ ] Estrutura app-aprender-osr2 criada

### Comando de Verificação
```markdown
"Claude, validar ambiente completo para trilha OSR2"
```

---

**Sistema Configurado:** Claude Code + Arch WSL Development  
**Workflow:** Dual-terminal otimizado  
**Foco:** Aprendizado guiado com prática intensiva  
**Objetivo:** Expert OS Development + r2 Mastery**