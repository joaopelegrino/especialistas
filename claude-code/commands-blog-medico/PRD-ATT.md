# 📋 PRD-ATT - Atualização de PRD com Checklist de Estado

## 🎯 **O que faz**
Gera e atualiza um documento central de PRD (Product Requirements Document) em formato de checklist baseado na documentação de requisitos do blog médico, com verificação automatizada do estado atual de implementação.

## 📥 **Inputs necessários**
- Estrutura de requisitos existente em `/home/notebook/workspace/blog/docs/01-internal-tech/requirements-and-vision/`
- Implementação atual do projeto para validação
- Evidências de teste (screenshots, navegação, testes automatizados via Playwright)

## 📤 **Outputs gerados**
- `PRD_CENTRAL.md` - Documento consolidado com checklist de requisitos
- Relatório de evidências de implementação por requisito
- Status de cada funcionalidade: ✅ Implementado | ⏳ Parcial | ❌ Pendente
- Links para evidências validadoras (screenshots, testes)

## ⚠️ **Critical**
- Utiliza **evidence-based validation** com Playwright para comprovação
- Segue **Seven-Layer Documentation Method** para organização
- Aplica **stakeholder protection principles** priorizando segurança/compliance
- Requer validação cruzada com múltiplas fontes antes de marcar como implementado

---

## 🔄 **Processo de Execução**

### **Fase 1: Análise da Estrutura de Requisitos**
```bash
# Mapear todos os documentos de requisitos
find /home/notebook/workspace/blog/docs/01-internal-tech/requirements-and-vision/ -name "*.md" | xargs grep -l "requisito\|funcionalidade\|implementar"

# Extrair requisitos chave dos documentos principais:
# - 00_VISAO_E_PRODUTO.md → Objetivos estratégicos
# - 01_ARQUITETURA_FUNCIONAL.md → Papéis de usuário e fluxos
# - 06_PARIDADE_FUNCIONAL.md → WordPress parity requirements
# - 04_REQUISITOS_NAO_FUNCIONAIS.md → Performance, segurança, escalabilidade
# - 02_ARQUITETURA_TECNICA/ → Especificações técnicas detalhadas
# - 03_COMPLIANCE/ → Requisitos legais (LGPD, ANVISA, CFM)
```

### **Fase 2: Evidence-Based Validation**
```bash
# Para cada requisito identificado, executar validação:
# 1. Análise de código fonte (existe a implementação?)
# 2. Testes navegacionais (funciona na interface?)
# 3. Screenshots automatizados via Playwright
# 4. Validação de compliance (atende normas?)
# 5. Testes de performance (atende requisitos não-funcionais?)
```

### **Fase 3: Geração do PRD Central**
```yaml
PRD_Structure:
  header:
    - project_overview: "Blog Médico Phoenix Platform"
    - last_validation: "Data da última verificação"
    - compliance_status: "Status geral de compliance"

  sections:
    - core_functionality: "Funcionalidades principais do sistema"
    - user_roles: "Papéis de usuário e permissões"
    - content_workflow: "Fluxo de criação e aprovação"
    - wordpress_parity: "Paridade funcional WordPress"
    - technical_requirements: "Arquitetura e stack técnica"
    - security_compliance: "Segurança e compliance legal"
    - performance_requirements: "Requisitos não-funcionais"

  checklist_format:
    - status_indicators: "✅ Implementado | ⏳ Parcial | ❌ Pendente | 🚨 Bloqueador"
    - evidence_links: "Links para screenshots/testes comprobatórios"
    - implementation_notes: "Notas técnicas sobre implementação atual"
    - compliance_validation: "Status de conformidade legal/médica"
```

### **Fase 4: Validação com Playwright**
```javascript
// Script de validação automatizada
const validation_scenarios = [
  'user_authentication_flow',
  'content_creation_wizard_5_steps',
  'approval_workflow_kanban',
  'wordpress_parity_features',
  'medical_compliance_features'
];

// Executar para cada cenário:
// 1. Screenshot da interface
// 2. Teste de funcionalidade
// 3. Validação de elementos críticos
// 4. Coleta de evidências
```

## 📋 **Template de Checklist PRD**

### **1. 🎯 Visão e Objetivos Estratégicos**

#### **1.1 Evolução Tecnológica**
- [ ] **🚨 CRITICAL** Sistema construído em Elixir/Phoenix
  - **Evidence**: `mix.exs` configurado, dependências Phoenix instaladas
  - **Test**: Servidor Phoenix iniciando corretamente
  - **Status**: ❌ Pendente
  - **Notes**: Sistema base precisa ser implementado

#### **1.2 Funcionalidade Core - WordPress Replacement**
- [ ] **🚨 CRITICAL** Editor de conteúdo flexível (substituto Elementor/ACF)
  - **Evidence**: Interface de criação equivalente ao WordPress
  - **Test**: Criação de post com campos customizados
  - **Status**: ❌ Pendente
  - **Gap**: Screenshot WordPress vs atual mostra funcionalidade ausente

- [ ] **🚨 CRITICAL** Fluxo de aprovação multi-stakeholder
  - **Evidence**: Sistema Kanban funcionando com aprovações
  - **Test**: Fluxo completo redator → especialista → jurídico → publicação
  - **Status**: ❌ Pendente
  - **Notes**: Workflow complexo não implementado

#### **1.3 Visão SaaS Longo Prazo**
- [ ] Multi-tenancy para empresas de saúde
  - **Evidence**: Arquitetura multi-tenant implementada
  - **Test**: Separação de dados entre clientes
  - **Status**: ❌ Pendente (Fase 2+)

### **2. 👥 Papéis de Usuário e Funcionalidades**

#### **2.1 Administrador**
- [ ] **ESSENTIAL** Gestão completa de usuários
  - **Evidence**: CRUD de usuários funcionando
  - **Test**: Criar/editar/remover usuários, definir permissões
  - **Status**: ⏳ Parcial
  - **Notes**: Sistema básico existe, falta refinamento

#### **2.2 Planejador de Conteúdo (Marketing/SEO)**
- [ ] **ESSENTIAL** Dashboard de planejamento de conteúdo
  - **Evidence**: Interface de planejamento implementada
  - **Test**: Criação de pautas, análise SEO, calendário
  - **Status**: ❌ Pendente

#### **2.3 Criador de Conteúdo**
- [ ] **🚨 CRITICAL** Wizard de 5 etapas para criação
  - **Evidence**: Wizard completo implementado
  - **Test**: Fluxo completo upload → configuração → validação → fontes → geração
  - **Status**: ❌ Pendente
  - **Dependencies**: Sistema de IA, validação científica, base bibliográfica

#### **2.4 Revisor Especialista (Profissional Saúde)**
- [ ] **🚨 CRITICAL** Interface de revisão técnica
  - **Evidence**: Painel de revisão médica funcionando
  - **Test**: Aprovar/reprovar conteúdo, adicionar comentários
  - **Status**: ❌ Pendente
  - **Compliance**: Essencial para validação médica CFM/SBIS

#### **2.5 Revisor Jurídico**
- [ ] **🚨 CRITICAL** Sistema de validação legal
  - **Evidence**: Fluxo jurídico implementado
  - **Test**: Validação LGPD, autorização uso imagem, disclaimers
  - **Status**: ❌ Pendente
  - **Compliance**: LGPD + ANVISA RDC 657/2022 obrigatório

#### **2.6 Leitor (Usuário Final)**
- [ ] **ESSENTIAL** Blog público acessível
  - **Evidence**: Interface pública funcionando
  - **Test**: Navegar posts, busca, categorização
  - **Status**: ⏳ Parcial
  - **Notes**: Estrutura básica existe

### **3. 🔄 Wizard Gerador de Conteúdo (Core Feature)**

#### **3.1 Etapa 1/5: Entrada e Configuração**
- [ ] **Upload múltiplos formatos** (vídeo, áudio, texto)
  - **Evidence**: Sistema de upload implementado
  - **Test**: Upload e processamento de diferentes mídias
  - **Status**: ❌ Pendente

- [ ] **Integração redes sociais** (Instagram, TikTok, YouTube)
  - **Evidence**: APIs integradas e funcionando
  - **Test**: Import de conteúdo de redes sociais
  - **Status**: ❌ Pendente (Complexo)

#### **3.2 Etapa 2/5: Validação de Dados**
- [ ] **Extração automática de entidades** (NLP)
  - **Evidence**: Sistema NLP processando texto
  - **Test**: Identificação de nomes, CRMs, locais
  - **Status**: ❌ Pendente
  - **Dependencies**: Vertex AI integration, NLP model

#### **3.3 Etapa 3/5: Verificação Científica**
- [ ] **Identificação de afirmações médicas**
  - **Evidence**: IA identificando claims científicos
  - **Test**: Detecção automática de afirmações que precisam referência
  - **Status**: ❌ Pendente
  - **Compliance**: CFM exige embasamento científico

#### **3.4 Etapa 4/5: Validação das Fontes**
- [ ] **Integração com bases científicas** (PubMed, SciELO)
  - **Evidence**: APIs científicas integradas
  - **Test**: Busca e sugestão de referências
  - **Status**: ❌ Pendente
  - **Complexity**: High - requires academic API access

#### **3.5 Etapa 5/5: Geração Final**
- [ ] **Geração automática de texto embasado**
  - **Evidence**: IA gerando artigo final formatado
  - **Test**: Artigo com referências e disclaimers
  - **Status**: ❌ Pendente
  - **Dependencies**: GPT/Claude integration, template system

### **4. 📊 Painel Kanban de Aprovação**

#### **4.1 Colunas do Workflow**
- [ ] **Sistema Kanban completo**
  - **Evidence**: Interface Kanban funcionando
  - **Test**: Drag-and-drop entre colunas, estados corretos
  - **Status**: ❌ Pendente
  - **Columns**: Draft → Technical Review → Legal Review → In Revision → Approved → Published → Archived

#### **4.2 Cards de Artigo**
- [ ] **Informações essenciais no card**
  - **Evidence**: Cards com todos campos obrigatórios
  - **Test**: Título, autor, tipo, status revisões, data, prioridade
  - **Status**: ❌ Pendente

### **5. 🔄 WordPress Parity (Gap Crítico)**

#### **5.1 Dashboard WordPress-like**
- [ ] **🚨 CRITICAL** Dashboard home equivalente
  - **Evidence**: Interface similar ao WordPress dashboard
  - **Test**: Widgets, quick actions, statistics
  - **Status**: ❌ MISSING
  - **Gap**: Sistema atual só tem wizard/kanban focus

#### **5.2 Posts Management**
- [ ] **🚨 CRITICAL** CRUD básico de posts
  - **Evidence**: Sistema de posts simples (não só Article médico)
  - **Test**: Criar/editar/listar posts básicos
  - **Status**: ❌ MISSING
  - **Gap**: Só existe Article workflow complexo

#### **5.3 Pages Management**
- [ ] **ESSENTIAL** Gestão de páginas estáticas
  - **Evidence**: CRUD de páginas implementado
  - **Test**: Criar páginas institucionais
  - **Status**: ❌ MISSING

#### **5.4 Media Library**
- [ ] **ESSENTIAL** Biblioteca de mídia centralizada
  - **Evidence**: Sistema de mídia como WordPress
  - **Test**: Upload, organização, reutilização de mídias
  - **Status**: ❌ MISSING (só upload via wizard)

#### **5.5 Team/Equipe CRUD**
- [ ] **ESSENTIAL** Gestão completa de equipe médica
  - **Evidence**: Interface equivalente à screenshot WordPress
  - **Test**: CRUD completo com campos customizados
  - **Status**: ⏳ PARTIAL (só médicos via admin/areas-atuacao)

### **6. 🔒 Segurança e Compliance**

#### **6.1 LGPD Compliance**
- [ ] **🚨 CRITICAL** Consentimento e gestão de dados
  - **Evidence**: Sistema LGPD compliant
  - **Test**: Consentimento, portabilidade, exclusão dados
  - **Status**: ❌ Pendente
  - **Legal**: Obrigatório por lei

#### **6.2 ANVISA RDC 657/2022**
- [ ] **🚨 CRITICAL** Conformidade publicitária médica
  - **Evidence**: Validação automática RDC 657
  - **Test**: Checagem automática de compliance publicitário
  - **Status**: ❌ Pendente
  - **Legal**: Obrigatório para comunicação médica

#### **6.3 CFM/SBIS NGS2**
- [ ] **🚨 CRITICAL** Normas éticas médicas
  - **Evidence**: Validação ética médica
  - **Test**: Checagem de normas CFM
  - **Status**: ❌ Pendente
  - **Professional**: Obrigatório para médicos

### **7. ⚡ Requisitos Não-Funcionais**

#### **7.1 Performance**
- [ ] **Tempo resposta < 2s** (95% requests)
  - **Evidence**: Métricas de performance coletadas
  - **Test**: Load testing, Core Web Vitals
  - **Status**: ❌ Pendente (precisa implementar primeiro)

#### **7.2 Escalabilidade**
- [ ] **Suporte 10k+ usuários simultâneos**
  - **Evidence**: Testes de carga bem-sucedidos
  - **Test**: Stress testing, database optimization
  - **Status**: ❌ Pendente

#### **7.3 Disponibilidade**
- [ ] **99.9% uptime**
  - **Evidence**: Monitoramento e alertas configurados
  - **Test**: Sistema de monitoramento ativo
  - **Status**: ❌ Pendente

### **8. 🛠️ Arquitetura Técnica**

#### **8.1 Stack Core**
- [ ] **Phoenix LiveView** funcionando
  - **Evidence**: Aplicação Phoenix rodando
  - **Test**: LiveView components responsivos
  - **Status**: ⏳ Parcial

#### **8.2 Database**
- [ ] **PostgreSQL** com schemas otimizados
  - **Evidence**: Database schema implementado
  - **Test**: Migrations executando corretamente
  - **Status**: ⏳ Parcial

#### **8.3 AI Integration**
- [ ] **Vertex AI** para processamento
  - **Evidence**: API Vertex AI integrada
  - **Test**: Processamento de texto/NLP funcionando
  - **Status**: ❌ Pendente

## 🎯 **Execução do Command**

### **Como Executar**
```bash
# No diretório do projeto especialistas
cd /home/notebook/workspace/especialistas/claude-code/

# Executar o command
/PRD-ATT

# O sistema irá:
# 1. Analisar toda estrutura de requisitos
# 2. Validar implementação atual via código/interface
# 3. Executar testes Playwright onde aplicável
# 4. Gerar PRD_CENTRAL.md atualizado
# 5. Criar evidências de validação
```

### **Outputs Gerados**
1. `PRD_CENTRAL.md` - Documento consolidado com status real
2. `evidence/` - Screenshots e evidências de teste
3. `compliance-report.md` - Status de conformidade legal
4. `gap-analysis.md` - Análise detalhada de lacunas

### **Frequência Recomendada**
- **Execução semanal** durante desenvolvimento ativo
- **Execução mensal** para validação de progresso
- **Execução obrigatória** antes de releases/entregas

---

## 📊 **Integration com Seven-Layer Method**

### **Evidence-Based Validation Cycle**
```yaml
validation_process:
  fase_0_evidence: "Validar alegações vs implementação real"
  stakeholder_protection: "Identificar riscos para grupos médicos/legais"
  risk_prioritization: "Legal/Safety > Business > UX > Convenience"
  continuous_validation: "Weekly evidence collection and verification"
```

### **PROTECTIVE First Philosophy**
- **Documentação protege** antes de ajudar
- **Compliance prioritário** sobre features
- **Evidence-based** antes de assumptions
- **Stakeholder safety** antes de user convenience

### **Integration Points**
```bash
# Usar sempre junto com outros commands
/diagnostico-aprofundado → /PRD-ATT → /planejamento-roadmap-expandido → /executar-roadmap-expandido → /validacao-entrega
```

---

**🔄 Este command implementa continuous validation com evidence-based approach para manter PRD sempre atualizado com realidade do projeto, seguindo metodologia Seven-Layer e princípios de stakeholder protection.**