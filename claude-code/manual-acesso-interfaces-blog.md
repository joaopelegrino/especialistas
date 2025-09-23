# 📖 Manual de Acesso - Interfaces e Capacidades do Projeto Blog

## 🎯 **RESUMO EXECUTIVO**
**Projeto**: Blog Médico (Phoenix/Elixir + PostgreSQL + LiveView)
**Domínio**: Healthcare/Medical platform (LGPD compliance CRITICAL)
**Status Atual**: 42% WordPress parity (evidence-based validation)
**Arquitetura**: WebAssembly-First Phoenix application

## ⚠️ **AVISOS CRÍTICOS ANTES DO ACESSO**
- **LGPD Compliance**: Platform NOT ready for real patient data (potential fines up to R$50M)
- **Medical Domain**: Accuracy critical for professional safety
- **Evidence-Based Status**: 42% WordPress parity, not 90% as previously claimed
- **Investment Required**: ~R$130,000 over 2-3 months for full compliance + WordPress parity

---

## 🌐 **INTERFACES WEB PRINCIPAIS**

### **1. Interface Pública (Sem Autenticação)**

#### 🏠 **Homepage**
- **URL**: `/`
- **Controller**: `PageController.home`
- **Propósito**: Landing page principal
- **Acesso Manual**: Navegar diretamente para a URL raiz

#### 🏥 **Páginas de Especialidade**
- **URL**: `/especialidade/:slug`
- **LiveView**: `EspecialidadeLive.show`
- **Propósito**: Exibir detalhes de especialidades médicas
- **Acesso Manual**:
  ```
  Exemplo: /especialidade/cardiologia
  Exemplo: /especialidade/neurologia
  ```

#### ⚡ **PWA Endpoints**
- **Manifest**: `/manifest.json` - Configuração Progressive Web App
- **Service Worker**: `/sw.js` - Cache e funcionalidade offline
- **Assets Offline**: `/assets/js/offline/:file` - Resources para modo offline

---

### **2. Interface de Autenticação**

#### 🔐 **Sistema de Login/Registro**
- **Registro**: `/users/register` - Criar nova conta
- **Login**: `/users/log_in` - Fazer login
- **Reset Password**: `/users/reset_password` - Recuperar senha
- **Logout**: `/users/log_out` - Encerrar sessão

#### ✅ **Confirmação de Email**
- **URL**: `/users/confirm/:token`
- **Propósito**: Validar email após registro

---

### **3. Interface Autenticada (Dashboard Principal)**

#### 📊 **Dashboard Principal**
- **URL**: `/dashboard`
- **LiveView**: `DashboardLive.index`
- **Security**: Enhanced security pipeline
- **Acesso Manual**: Login → navegar para /dashboard

#### ⚙️ **Configurações de Usuário**
- **URL**: `/users/settings`
- **Controller**: `UserSettingsController`
- **Funcionalidades**: Editar perfil, alterar senha, confirmar email

---

### **4. Interface do Projeto-BM (Funcionalidades Principais)**

#### 🧙‍♂️ **Content Wizard (Phase BM-2)**
- **URL**: `/wizard`
- **LiveView**: `ContentWizardLive.index`
- **Security**: Enhanced security + medical_context_required
- **Propósito**: Assistente de criação de conteúdo médico
- **Status**: 5-step wizard implementation
- **Acesso Manual**: Login → navegar para /wizard

#### 📋 **Kanban Panel (Phase BM-3)**
- **URL**: `/kanban`
- **LiveView**: `KanbanLive.index`
- **Security**: Enhanced security
- **Propósito**: Gerenciamento de projetos estilo Kanban
- **Acesso Manual**: Login → navegar para /kanban

---

### **5. Interface Administrativa (Admin Panel)**

#### 🏥 **Gestão de Áreas de Atuação**
- **URL**: `/admin/areas-atuacao`
- **LiveView**: `Admin.AreaAtuacaoLive.Index`
- **Security**: Medical security pipeline
- **Funcionalidades**: CRUD de especialidades médicas
- **Acesso Manual**: Login como admin → /admin/areas-atuacao

#### 📝 **WordPress Basic CMS**
- **Posts Básicos**: `/admin/basic-posts` - Gestão de posts simples
- **Páginas Básicas**: `/admin/basic-pages` - Gestão de páginas estáticas
- **Team**: `/admin/team` - Gestão de equipe médica
- **Media**: `/admin/media` - Gestão de arquivos de mídia

#### 📚 **WordPress Advanced CMS**
- **Posts Avançados**: `/admin/posts` - Sistema completo de posts
- **Categorias**: `/admin/categories` - Gestão de categorias

---

### **6. Interface de Desenvolvimento**

#### 📊 **Claude Code Observatory Dashboard**
- **URL**: `/claude/dashboard`
- **LiveView**: `ClaudeDashboardLive.index`
- **Propósito**: Monitoramento de desenvolvimento e métricas Claude Code
- **Acesso Manual**: Navegar diretamente para /claude/dashboard

#### 🩺 **Phoenix LiveDashboard (Dev Only)**
- **URL**: `/dev/dashboard`
- **Disponível**: Apenas em ambiente de desenvolvimento
- **Propósito**: Métricas Phoenix, Telemetry, performance

#### 📧 **Mailbox Preview (Dev Only)**
- **URL**: `/dev/mailbox`
- **Propósito**: Preview de emails em desenvolvimento

---

## 🔌 **API ENDPOINTS**

### **1. Health Check**
- **URL**: `/api/health` ou `/health`
- **Method**: GET
- **Propósito**: Status da aplicação
- **Response**: JSON com status do sistema

### **2. Telemetria**
- **WASM Metrics**: `POST /api/telemetry/wasm`
- **Bulk Metrics**: `POST /api/telemetry/bulk`

### **3. Claude Code Hooks**
- **Create Hook**: `POST /api/claude/hooks`
- **Metrics**: `GET /api/claude/hooks/metrics`
- **Health**: `GET /api/claude/hooks/health`

---

## 🛠️ **COMANDOS DE ACESSO LOCAL**

### **Iniciar Servidor**
```bash
# Ambiente de desenvolvimento
mix phx.server

# Ambiente WASM
MIX_ENV=wasm mix wasm.server

# Com headers WASM (COOP/COEP)
mix wasm.server
```

### **Portas Padrão**
- **Desenvolvimento**: `http://localhost:4000`
- **WASM**: `http://localhost:4000` (com headers especiais)

---

## 🏗️ **ESTRUTURA TÉCNICA**

### **Pipelines de Segurança**
1. **browser**: Pipeline padrão para interface web
2. **medical_security**: Security extra para conteúdo médico
3. **enhanced_security**: Security moderada para interfaces autenticadas
4. **api**: Pipeline para endpoints JSON
5. **pwa**: Pipeline para Progressive Web App

### **LiveView Components**
- **EspecialidadeLive**: Exibição de especialidades médicas
- **DashboardLive**: Dashboard principal autenticado
- **ContentWizardLive**: Assistente de conteúdo (5 etapas)
- **KanbanLive**: Painel Kanban para projetos
- **ClaudeDashboardLive**: Observatory para desenvolvimento

### **Controllers Principais**
- **PageController**: Páginas estáticas e PWA
- **UserSessionController**: Autenticação
- **HealthController**: Health checks
- **TelemetryController**: Métricas e telemetria
- **ClaudeHookController**: Integração Claude Code

---

## 📁 **ARQUIVOS DE CONFIGURAÇÃO**

### **Rotas**
- **Arquivo**: `lib/blog_web/router.ex`
- **Configurações**: Definição de todas as rotas e pipelines

### **Endpoint**
- **Arquivo**: `lib/blog_web/endpoint.ex`
- **Headers WASM**: Configurações COOP/COEP para WebAssembly

### **Mix Project**
- **Arquivo**: `mix.exs`
- **Dependências**: Stack completo Phoenix + WASM + Security

---

## 🎯 **FLUXOS DE NAVEGAÇÃO TÍPICOS**

### **1. Usuário Visitante**
```
Homepage (/) → Especialidade (/especialidade/:slug) → Registro (/users/register)
```

### **2. Usuário Logado**
```
Login (/users/log_in) → Dashboard (/dashboard) → Wizard (/wizard) ou Kanban (/kanban)
```

### **3. Administrador**
```
Login → Dashboard → Admin Panel (/admin/*) → Gestão de Conteúdo
```

### **4. Desenvolvedor**
```
Claude Dashboard (/claude/dashboard) → LiveDashboard (/dev/dashboard) → API Endpoints
```

---

## ⚠️ **LIMITAÇÕES CONHECIDAS**

### **WordPress Parity**
- **Status**: 42% implementado (evidence-based)
- **Missing**: 58% das funcionalidades WordPress padrão
- **Impact**: Platform não adequada para substituir WordPress completo

### **Medical Compliance**
- **LGPD**: Implementação incompleta (49% compliance)
- **Patient Data**: Platform NOT ready for real patient data
- **Legal Risk**: Potential fines up to R$50M for violations

### **Performance**
- **WASM Bundle**: 22.2MB atual (target <3MB)
- **Optimization**: Phase 2 em andamento

---

## 🔧 **TESTING E VALIDAÇÃO**

### **Automated Testing**
```bash
# Testes unitários
mix test

# Testes com coverage
mix coveralls.html

# Testes de integração (Playwright)
npm test
```

### **Manual Testing Checklist**
- [ ] Login/logout funcionando
- [ ] Dashboard carregando sem erros
- [ ] Content Wizard 5 etapas funcionais
- [ ] Admin panel acessível
- [ ] API health check respondendo
- [ ] PWA manifest válido

---

## 📊 **MÉTRICAS E MONITORAMENTO**

### **Live Metrics**
- **Phoenix LiveDashboard**: `/dev/dashboard`
- **Claude Observatory**: `/claude/dashboard`
- **API Health**: `/api/health`

### **Telemetry Endpoints**
- **WASM Performance**: `/api/telemetry/wasm`
- **Bulk Metrics**: `/api/telemetry/bulk`

---

## 🚨 **COMPLIANCE E SEGURANÇA**

### **Medical Security Pipeline**
- Rate limiting ativado
- Enhanced CSRF protection
- Audit logging para todas as ações médicas
- Medical context validation obrigatória

### **LGPD Warnings**
- Platform requires significant compliance work
- Patient data processing NOT APPROVED
- Legal review required before production use

---

**📝 Documento criado para integração com `/diagnostico-aprofundado`**
**🔄 Status**: Evidence-based validation completed
**📅 Última Atualização**: September 2025
**🎯 Uso**: Manual access reference for LLM context