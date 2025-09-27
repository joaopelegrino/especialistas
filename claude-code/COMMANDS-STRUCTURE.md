# 📋 Estrutura de Commands - Especialista LLM Development

## 🎯 **Nova Organização dos Commands**

Os commands foram reorganizados **fora da pasta `.claude`** para melhor separação de responsabilidades e reutilização entre projetos.

### **📁 Estrutura Atual**

```
/home/notebook/workspace/especialistas/claude-code/
├── commands-universais/           # Commands genéricos aplicáveis a qualquer projeto
│   ├── diagnostico-aprofundado.md
│   ├── executar-roadmap-expandido.md
│   ├── LLM-diretrizes.md
│   ├── LLM-main.md
│   ├── planejamento-roadmap-expandido.md
│   ├── proposta.md
│   ├── README-commands-workflow.md
│   ├── validacao-entrega.md
│   └── VALIDATION-MATRIX.md
├── commands-blog-medico/          # Commands específicos para projeto Blog Médico
│   ├── PRD-ATT.md
│   ├── PRD-ATT-validator.js
│   └── prd-checklist-generator.md
└── COMMANDS-STRUCTURE.md          # Este arquivo (documentação da estrutura)
```

---

## 🔄 **Commands Universais**

### **Core Workflow Commands**
Estes são os commands principais que seguem o **Seven-Layer Documentation Method** e devem ser usados em **todos os projetos**:

#### **1. LLM-main.md**
- **Tipo**: Hub central de execução
- **Uso**: Command principal que recebe tarefas via `$AUGMENT` e aplica as práticas do especialista
- **Aplicabilidade**: Universal - qualquer projeto

#### **2. diagnostico-aprofundado.md**
- **Tipo**: Evidence-based analysis
- **Uso**: Análise aprofundada com validação de evidências (Fase 0 obrigatória)
- **Outputs**: llm-context-master.md, diagnostico-completo.md, accuracy-correction-report.md
- **Aplicabilidade**: Universal - qualquer projeto que precise de diagnóstico

#### **3. planejamento-roadmap-expandido.md**
- **Tipo**: Strategic planning
- **Uso**: Planejamento detalhado com Seven-Layer methodology
- **Dependencies**: Deve ser executado após diagnostico-aprofundado
- **Aplicabilidade**: Universal - qualquer projeto que precise de roadmap

#### **4. executar-roadmap-expandido.md**
- **Tipo**: Implementation execution
- **Uso**: Execução com evidence collection e stakeholder protection
- **Dependencies**: Requer planejamento-roadmap-expandido
- **Aplicabilidade**: Universal - qualquer implementação

#### **5. validacao-entrega.md**
- **Tipo**: Zero-breakage validation
- **Uso**: Validação final com zero-breakage + stakeholder protection
- **Aplicabilidade**: Universal - qualquer entrega

### **Support Commands**
#### **6. LLM-diretrizes.md**
- **Tipo**: Guidelines reference
- **Uso**: Diretrizes e práticas para LLM Development
- **Aplicabilidade**: Universal - referência para todos projetos

#### **7. README-commands-workflow.md**
- **Tipo**: Workflow documentation
- **Uso**: Documentação do fluxo de trabalho dos commands
- **Aplicabilidade**: Universal - guia para uso dos commands

#### **8. VALIDATION-MATRIX.md**
- **Tipo**: Validation framework
- **Uso**: Matrix de validação para diferentes tipos de projeto
- **Aplicabilidade**: Universal - framework de validação

#### **9. proposta.md**
- **Tipo**: Proposal template
- **Uso**: Template para criação de propostas de otimização
- **Aplicabilidade**: Universal - proposals para qualquer projeto

---

## 🏥 **Commands Blog Médico**

### **Commands Específicos para Blog Médico Phoenix**
Estes commands foram desenvolvidos especificamente para o projeto Blog Médico e contêm referências diretas aos caminhos e requisitos específicos:

#### **1. PRD-ATT.md**
- **Tipo**: Product Requirements Document generator
- **Uso**: Gera PRD em formato checklist baseado em `/home/notebook/workspace/blog/docs/01-internal-tech/requirements-and-vision/`
- **Específico para**: Blog Médico Phoenix Platform
- **Outputs**: PRD_CENTRAL.md, relatórios de evidências, status de funcionalidades
- **Evidence validation**: Playwright integration para comprovação

#### **2. PRD-ATT-validator.js**
- **Tipo**: Automated validation script
- **Uso**: Script Node.js com Playwright para validação automatizada de requisitos
- **Específico para**: Blog Médico (testa URLs localhost:4000, workflows médicos)
- **Features**: Screenshot capture, performance validation, compliance testing (LGPD, ANVISA, CFM)

#### **3. prd-checklist-generator.md**
- **Tipo**: Alternative PRD generator
- **Uso**: Gerador alternativo de checklist PRD com Playwright
- **Específico para**: Blog Médico requirements
- **Similar to**: PRD-ATT.md mas com abordagem diferente

---

## 🚀 **Como Usar os Commands**

### **Fluxo Obrigatório (Seven-Layer Enhanced)**
Para **qualquer projeto**, siga sempre este fluxo usando os commands universais:

```bash
# 1. Diagnóstico Evidence-Based (FASE 0 OBRIGATÓRIA)
/diagnostico-aprofundado

# 2. Planejamento Strategic com Seven-Layer
/planejamento-roadmap-expandido

# 3. Execução com Evidence Collection
/executar-roadmap-expandido

# 4. Validação Zero-Breakage + Stakeholder Protection
/validacao-entrega
```

### **Para Projeto Blog Médico Específicamente**
Além do fluxo universal, use os commands específicos:

```bash
# Após diagnóstico e planejamento, para PRD específico:
/PRD-ATT                          # Gera PRD checklist baseado nos requirements

# Para validação automatizada:
node PRD-ATT-validator.js         # Executa testes Playwright automatizados
```

---

## 📝 **Instalação e Setup**

### **Como Usar Commands Universais em Qualquer Projeto**

#### **1. Copy Commands para Projeto Alvo**
```bash
# Copiar commands universais para projeto alvo
cp -r /home/notebook/workspace/especialistas/claude-code/commands-universais/* /seu-projeto/.claude/commands/

# Ou criar link simbólico (recomendado)
ln -s /home/notebook/workspace/especialistas/claude-code/commands-universais /seu-projeto/.claude/commands-ref
```

#### **2. Adaptar Paths nos Commands (se necessário)**
Alguns commands podem precisar ajustar paths específicos para o projeto alvo.

#### **3. Configurar CLAUDE.md**
Assegurar que o projeto alvo tem CLAUDE.md configurado corretamente para usar os commands.

### **Para Blog Médico**
```bash
# Commands específicos já estão desenvolvidos em:
/home/notebook/workspace/especialistas/claude-code/commands-blog-medico/

# Para usar no projeto blog:
cp /home/notebook/workspace/especialistas/claude-code/commands-blog-medico/* /home/notebook/workspace/blog/.claude/commands/
```

---

## 🔄 **Maintenance e Updates**

### **Commands Universais**
- **Local**: `/home/notebook/workspace/especialistas/claude-code/commands-universais/`
- **Manutenção**: Atualizações beneficiam todos os projetos
- **Versionamento**: Manter changelog para breaking changes
- **Testing**: Testar em projetos diferentes antes de commit

### **Commands Específicos**
- **Local**: `/home/notebook/workspace/especialistas/claude-code/commands-blog-medico/`
- **Manutenção**: Updates específicos para projeto Blog Médico
- **Deployment**: Copiar para projeto alvo após updates

---

## ⚠️ **Separação de Responsabilidades**

### **✅ Especialistas Repository (Este)**
- Commands universais reutilizáveis
- Templates e diretrizes
- Documentation Method e metodologias
- Commands específicos como exemplos/templates

### **✅ Projetos Alvo**
- Cópia dos commands universais adaptados
- CLAUDE.md específico do projeto
- Configurações específicas do ambiente
- Outputs dos commands executados

### **❌ O que NÃO fazer**
- ❌ Não manter commands específicos apenas no .claude/ do projeto
- ❌ Não duplicar commands universais em múltiplos projetos sem versionamento
- ❌ Não misturar lógica específica nos commands universais

---

## 📊 **Evidence-Based Performance**

### **Benefícios da Nova Estrutura**
- ✅ **Reutilização**: Commands universais aplicáveis a qualquer projeto
- ✅ **Manutenção**: Updates centralizados beneficiam todos projetos
- ✅ **Separação**: Clear separation entre generic vs specific logic
- ✅ **Escalabilidade**: Fácil adição de novos commands específicos
- ✅ **Seven-Layer Integration**: Methodology preservada e aplicável universalmente

### **Anthropic 2025 Best Practices Compliance**
- ✅ **Evidence-based validation**: Built into core workflow
- ✅ **Stakeholder protection**: PROTECTIVE first philosophy
- ✅ **Continuous validation**: Weekly/monthly accuracy reviews
- ✅ **Test-driven approach**: Playwright integration para medical compliance

---

**📋 Estrutura implementada seguindo Seven-Layer Documentation Method com evidence-based validation e stakeholder protection principles.**