# 🗂️ Estrutura Organizacional - Trilha OSR2

## 📁 Organização da Pasta `/fundamentos` - Sistema OSR2

```
/home/notebook/workspace/especialistas/fundamentos/
├── 📊 PROGRESSO_TRACKER.md          # Dashboard OSR2 central
├── 🚀 app-aprender-osr2/            # 🎯 TRILHA PRINCIPAL OSR2
│   ├── ROTEIRO_GERAL_OSR2.md        # Roadmap 420h integrado
│   ├── CHECKLIST_AMBIENTE_DUAL.md   # Ubuntu + Arch + r2 setup
│   ├── INTEGRACAO_R2_COMPLETA.md    # Metodologia r2-first
│   ├── FASE_0_AMBIENTE/             # Setup dual + r2 básico
│   │   ├── modulos/
│   │   ├── exercicios/
│   │   ├── projetos/
│   │   └── recursos/
│   ├── FASE_1_FUNDAMENTOS/          # C/C++ + análise binária
│   │   ├── modulos/
│   │   ├── exercicios/
│   │   ├── projetos/
│   │   ├── recursos/
│   │   └── r2-analysis/            # Templates análise r2
│   ├── FASE_2_HARDWARE/             # Hardware + bootloaders + r2
│   │   ├── modulos/
│   │   ├── exercicios/
│   │   ├── projetos/
│   │   ├── recursos/
│   │   ├── r2-analysis/
│   │   └── bootloaders/            # Código bootloaders
│   ├── FASE_3_KERNEL/               # Kernel + r2 remote debug
│   │   ├── modulos/
│   │   ├── exercicios/
│   │   ├── projetos/
│   │   ├── recursos/
│   │   ├── r2-analysis/
│   │   └── kernel-src/             # Código kernel
│   ├── FASE_4_PROCESSOS/            # Multitask + r2 tracing
│   │   ├── modulos/
│   │   ├── exercicios/
│   │   ├── projetos/
│   │   ├── recursos/
│   │   ├── r2-analysis/
│   │   └── scheduling/             # Algoritmos scheduling
│   ├── FASE_5_EXTENSOES/            # I/O + drivers + hardware r2
│   │   ├── modulos/
│   │   ├── exercicios/
│   │   ├── projetos/
│   │   ├── recursos/
│   │   ├── r2-analysis/
│   │   └── drivers/                # Device drivers
│   ├── radare2-integration/         # 🔬 r2 recursos centralizados
│   │   ├── tutorials/
│   │   ├── scripts/
│   │   ├── configs/
│   │   ├── analysis-templates/
│   │   ├── debugging-guides/
│   │   └── reverse-engineering/
│   ├── projetos-integrados/         # 🏗️ Projetos cross-fase
│   │   ├── bootloader-completo/
│   │   ├── kernel-minimo/
│   │   ├── shell-avancado/
│   │   ├── sistema-arquivos/
│   │   └── drivers-basicos/
│   └── recursos-globais/            # 📚 Templates + automação
│       ├── referencias/
│       ├── ferramentas/
│       ├── scripts-automacao/
│       └── templates/
├── 📚 app-aprender/                 # Trilha original (referência)
├── ⚙️ .claude/                      # 🤖 Configurações dual-terminal
│   ├── settings.json               # Permissions otimizadas
│   ├── settings.local.json         # Estado aprendizado
│   └── hooks/                      # Automação workflow
│       ├── pre-learning-session.sh
│       └── sync-results.sh
├── 📝 sessoes/                     # Logs sessões dual-terminal
├── 📝 minhas-anotacoes/            # Anotações + insights r2
├── 🧪 exercicios/                  # Exercícios + análise binária
├── 📋 checkpoints/                 # Validações OSR2
├── 🛠️ ferramentas/                # Scripts + utilitários
├── 📖 recursos/                    # Referências + comunidades
├── 🎓 CLAUDE.md                    # Diretrizes sistema
├── 📋 instrucoes-usuario.md        # Guia uso OSR2
├── 🗂️ ESTRUTURA_ORGANIZACIONAL.md  # Este documento
└── ✅ SISTEMA_PRONTO.md            # Status sistema OSR2
```

---

## 🎯 Componentes Principais OSR2

### 🚀 app-aprender-osr2/ - TRILHA PRINCIPAL
**O coração do sistema** - estrutura completa com integração Radare2:
- **6 FASES** com progressão 420h total
- **r2-analysis/** em cada fase para templates
- **radare2-integration/** com recursos centralizados
- **projetos-integrados/** spanning múltiplas fases

### ⚙️ .claude/ - CONFIGURAÇÕES INTELIGENTES
**Automação do workflow** dual-terminal:
- **settings.json**: Permissions otimizadas Ubuntu/Arch
- **hooks/**: Scripts que detectam tipo de tarefa
- **settings.local.json**: Estado atual do aprendizado

### 📊 PROGRESSO_TRACKER.md - DASHBOARD CENTRAL
**Controle total** da evolução:
- **420h tracking** com breakdown por fase
- **r2 expertise levels** progressão
- **Dual-terminal workflow** status
- **Commands OSR2** contextuais

### 📋 instrucoes-usuario.md - GUIA DEFINITIVO
**Manual completo** uso sistema:
- **Workflow dual-terminal** step-by-step
- **Comandos por tipo** de atividade
- **Windows Terminal** setup recomendado
- **Troubleshooting** comum

---

## 🔄 Workflow de Arquivos OSR2

### 📝 Durante Desenvolvimento (Arch WSL)
```bash
# Usuário executa no terminal Arch:
wsl -d Arch
cd /home/osdev/workspace
gcc programa.c -o programa
r2 programa
# ... documentar outputs r2 em .txt
```

### 📚 Durante Documentação (Ubuntu WSL)
```bash
# Claude processa no Ubuntu:
- Lê outputs r2 de shared folders
- Atualiza PROGRESSO_TRACKER.md  
- Cria próximos guias em app-aprender-osr2/
- Suggests next steps baseado em progresso
```

### 🔗 Sincronização Automática
```bash
# Hooks .claude/ fazem automaticamente:
1. Detectam tipo de tarefa (dev vs docs)
2. Preparam templates apropriados
3. Processam resultados Arch → Ubuntu
4. Atualizam tracking e métricas
```

---

## 📁 Convenções de Nomenclatura OSR2

### 📄 Arquivos de Análise r2
```bash
programa-r2-analysis.txt         # Análise static completa
bootloader-debug-session.log     # Sessão debugging r2
kernel-crash-postmortem.md       # Post-mortem analysis
```

### 📂 Estrutura de Projetos
```bash
FASE_X_NOME/projetos/projeto-Y/
├── src/                         # Código fonte
├── bin/                         # Binários compilados
├── r2-analysis/                 # Análises r2 específicas
├── docs/                        # Documentação projeto
└── README.md                    # Overview projeto
```

### 🗂️ Templates Padronizados
```bash
recursos-globais/templates/
├── template-exercicio-r2.md     # Exercícios com r2
├── template-projeto-integrado.md # Projetos com análise
├── template-sessao-dual.md       # Sessões dual-terminal
└── template-checkpoint-osr2.md  # Validações OSR2
```

---

## 🎯 Navegação Rápida OSR2

### 🚀 Iniciar Nova Fase
```markdown
"Claude, iniciar FASE X da trilha OSR2"
→ Cria workspace em app-aprender-osr2/FASE_X_NOME/
→ Prepara templates em r2-analysis/
→ Gera guia dual-terminal específico
```

### 🔍 Buscar Conteúdo
```bash
# Encontrar exercícios r2 por tópico:
find app-aprender-osr2/ -name "*r2*" -type f

# Localizar análises de fase específica:
ls app-aprender-osr2/FASE_*/r2-analysis/

# Ver templates disponíveis:
ls recursos-globais/templates/
```

### 📊 Verificar Status
```markdown
"Claude, status progresso trilha OSR2"
→ Mostra PROGRESSO_TRACKER.md atualizado
→ Lista próximos passos recomendados
→ Indica nível r2 expertise atual
```

---

## 🛠️ Manutenção e Organização

### 🧹 Limpeza Automática
- **Backup automático** após cada sessão
- **Remoção** arquivos temporários .tmp
- **Organização** outputs r2 por data/fase

### 📈 Métricas Coletadas
- **Tempo investido** por fase
- **Comandos r2** mais usados
- **Dificuldades** recorrentes  
- **Velocity** de aprendizado

### 🔄 Sincronização Cross-Platform
- **Windows Terminal** profiles
- **WSL paths** padronizados
- **Shared folders** otimizados
- **Git integration** automática

---

## 🎓 Benefícios da Organização OSR2

### ✅ **Eficiência Máxima**
- **Tudo no lugar certo** sempre
- **Templates prontos** para uso
- **Automação** reduz overhead
- **Focus** no aprendizado

### ✅ **Tracking Profissional**
- **Métricas detalhadas** progresso
- **Portfolio automático** construído
- **Skills validation** sistemática
- **Career readiness** documentada

### ✅ **Escalabilidade**
- **Adicionar fases** facilmente
- **Customizar templates** conforme necessário
- **Extend automations** conforme crescimento
- **Adapt workflow** para preferências

---

**Estrutura Criada:** 2025-09-04  
**Sistema:** OSR2 - OS Development + r2 Integration  
**Status:** 🟢 Completamente Organizacional  
**Diferencial:** Única estrutura dual-terminal otimizada**