<!-- DSM:DOMAIN:capabilities L2:mcp_integration L3:validation_plan L4:healthcare_cms -->
<!-- DSM:DEPENDENCY_MATRIX:
depends_on: "Chrome DevTools MCP v0.4.0, Healthcare CMS Sprint 0-2, Phoenix server running"
provides_to: "Visual validation evidence, UI/UX compliance testing, Performance analysis"
integrates_with: "Sprint 0-2 validation, Evidence-based testing, Compliance verification"
performance_contracts: "Complete UI coverage, <2s page load, WCAG 2.1 compliance"
compliance_requirements: "No PHI/PII in screenshots, synthetic data only, LGPD audit trail"
-->

# 🔬 Chrome DevTools MCP - Plano de Validação Visual Healthcare CMS

**Data**: 29 Setembro 2025 | **Status**: ⚠️ **PLANEJADO - Aguardando Chrome Browser**
**Healthcare CMS**: v0.1.0 Sprint 0-2 | **MCP Version**: 0.4.0

---

## 🎯 **OBJETIVO DA VALIDAÇÃO MCP**

Complementar a validação evidence-based (HTTP inspection) com validação visual completa usando Chrome DevTools MCP para:
- ✅ Confirmar renderização correta das interfaces
- ✅ Validar acessibilidade (WCAG 2.1 AA)
- ✅ Medir Core Web Vitals reais
- ✅ Testar interações JavaScript
- ✅ Capturar evidências visuais para documentação

---

## 📋 **SEQUÊNCIA DE NAVEGAÇÕES MCP PLANEJADAS**

### **1. Inicialização e Setup**

```typescript
// MCP Tool: list_pages
// Objetivo: Verificar páginas abertas antes de iniciar testes
await mcp__chrome_devtools__list_pages()
// Resultado esperado: [] (nenhuma página aberta inicialmente)
```

**Evidência gerada**: Lista de páginas abertas no Chrome DevTools

---

### **2. Homepage Validation (GET /)**

```typescript
// MCP Tool: new_page + navigate_page
// Objetivo: Abrir Healthcare CMS homepage e validar renderização
await mcp__chrome_devtools__new_page({
  url: "http://localhost:4000/"
})

// MCP Tool: take_snapshot
// Objetivo: Capturar estrutura HTML completa da página
await mcp__chrome_devtools__take_snapshot()

// MCP Tool: take_screenshot
// Objetivo: Capturar evidência visual da homepage
await mcp__chrome_devtools__take_screenshot({
  fullPage: true,
  format: "png"
})

// MCP Tool: list_console_messages
// Objetivo: Verificar se há erros JavaScript
await mcp__chrome_devtools__list_console_messages()

// MCP Tool: performance_start_trace
// Objetivo: Iniciar gravação de performance
await mcp__chrome_devtools__performance_start_trace({
  reload: true,
  autoStop: true
})

// Aguardar carregamento completo...

// MCP Tool: performance_stop_trace
// Objetivo: Obter métricas de performance
await mcp__chrome_devtools__performance_stop_trace()
```

**Evidências esperadas**:
- ✅ Screenshot da homepage renderizada
- ✅ HTML snapshot com estrutura completa
- ✅ Console sem erros críticos
- ✅ Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1
- ✅ Performance trace com métricas detalhadas

**Validações**:
- Status cards visíveis (Web Interface, Zero Trust, Database, Compliance)
- Badges "Sprint 0-1" e "ONLINE" renderizados
- Links funcionais (navegação futura)
- Gradient background aplicado corretamente
- Footer com informações técnicas

---

### **3. Login Page Validation (GET /login)**

```typescript
// MCP Tool: navigate_page
// Objetivo: Navegar para página de login
await mcp__chrome_devtools__navigate_page({
  url: "http://localhost:4000/login"
})

// MCP Tool: take_snapshot
// Objetivo: Capturar estrutura do formulário
await mcp__chrome_devtools__take_snapshot()

// MCP Tool: take_screenshot
// Objetivo: Evidência visual do formulário de login
await mcp__chrome_devtools__take_screenshot({
  fullPage: true,
  format: "png"
})

// MCP Tool: evaluate_script
// Objetivo: Validar presença de CSRF token
await mcp__chrome_devtools__evaluate_script({
  function: `() => {
    const csrfInput = document.querySelector('input[name="_csrf_token"]');
    return {
      csrfPresent: !!csrfInput,
      csrfValue: csrfInput ? csrfInput.value.substring(0, 10) + '...' : null,
      formAction: document.querySelector('form')?.action,
      emailFieldType: document.querySelector('#email')?.type,
      passwordFieldType: document.querySelector('#password')?.type
    }
  }`
})

// MCP Tool: list_network_requests
// Objetivo: Verificar requisições de assets
await mcp__chrome_devtools__list_network_requests({
  resourceTypes: ["stylesheet", "script", "image"]
})
```

**Evidências esperadas**:
- ✅ Formulário de login renderizado corretamente
- ✅ CSRF token presente e único
- ✅ Campos email e password com tipos corretos
- ✅ Placeholder text visível
- ✅ Botão "Entrar" estilizado
- ✅ Link "Criar conta" funcional
- ✅ Footer com badges de segurança
- ✅ Assets CSS/JS carregados sem erros

**Validações de Acessibilidade**:
- Labels associados aos inputs (for/id)
- Atributos required presentes
- Contrast ratio adequado (WCAG 2.1 AA)
- Focus indicators visíveis

---

### **4. Register Page Validation (GET /register)**

```typescript
// MCP Tool: navigate_page
await mcp__chrome_devtools__navigate_page({
  url: "http://localhost:4000/register"
})

// MCP Tool: take_snapshot
await mcp__chrome_devtools__take_snapshot()

// MCP Tool: take_screenshot
await mcp__chrome_devtools__take_screenshot({
  fullPage: true,
  format: "png"
})

// MCP Tool: evaluate_script
// Objetivo: Validar estrutura do formulário de registro
await mcp__chrome_devtools__evaluate_script({
  function: `() => {
    const form = document.querySelector('form');
    const roleSelect = document.querySelector('#role');
    const termsCheckbox = document.querySelector('#terms');

    return {
      formFields: {
        name: !!document.querySelector('#name'),
        email: !!document.querySelector('#email'),
        password: !!document.querySelector('#password'),
        role: !!roleSelect,
        terms: !!termsCheckbox
      },
      roleOptions: Array.from(roleSelect?.options || []).map(opt => ({
        value: opt.value,
        text: opt.text
      })),
      termsRequired: termsCheckbox?.required,
      csrfPresent: !!document.querySelector('input[name="_csrf_token"]')
    }
  }`
})

// MCP Tool: hover
// Objetivo: Testar hover states em campos
await mcp__chrome_devtools__hover({
  uid: "email_input_uid" // UID do snapshot
})

// MCP Tool: click
// Objetivo: Testar checkbox de termos
await mcp__chrome_devtools__click({
  uid: "terms_checkbox_uid"
})
```

**Evidências esperadas**:
- ✅ 5 campos do formulário renderizados (name, email, password, role, terms)
- ✅ Select com 4 opções de role (subscriber, contributor, author, editor)
- ✅ Checkbox de termos LGPD obrigatório
- ✅ Placeholder text em todos os campos
- ✅ Hover states funcionando
- ✅ Link para login visível

**Validações Healthcare**:
- Roles compatíveis com WordPress
- Menção explícita a LGPD no checkbox
- Placeholder "Dr. João Silva" como exemplo médico
- Email placeholder com domínio brasileiro (.com.br)

---

### **5. Dashboard Protection Validation (GET /dashboard)**

```typescript
// MCP Tool: navigate_page
// Objetivo: Testar proteção de autenticação
await mcp__chrome_devtools__navigate_page({
  url: "http://localhost:4000/dashboard"
})

// MCP Tool: wait_for
// Objetivo: Aguardar redirect para /login
await mcp__chrome_devtools__wait_for({
  text: "Healthcare CMS"
})

// MCP Tool: evaluate_script
// Objetivo: Confirmar que estamos em /login após redirect
await mcp__chrome_devtools__evaluate_script({
  function: `() => {
    return {
      currentUrl: window.location.href,
      pageTitle: document.title,
      isLoginPage: window.location.pathname === '/login'
    }
  }`
})

// MCP Tool: take_screenshot
// Objetivo: Evidência do redirect funcionando
await mcp__chrome_devtools__take_screenshot({
  fullPage: true,
  format: "png"
})

// MCP Tool: list_network_requests
// Objetivo: Verificar se houve redirect 302
await mcp__chrome_devtools__list_network_requests({
  resourceTypes: ["document"]
})

// MCP Tool: get_network_request
// Objetivo: Detalhar o redirect
await mcp__chrome_devtools__get_network_request({
  url: "http://localhost:4000/dashboard"
})
```

**Evidências esperadas**:
- ✅ Redirect 302 de /dashboard → /login
- ✅ Header Location presente na resposta
- ✅ Usuário não autenticado não acessa dashboard
- ✅ RequireAuth plug funcional
- ✅ Flash message (se implementada) informando necessidade de login

---

### **6. Health Check JSON Validation (GET /health)**

```typescript
// MCP Tool: navigate_page
await mcp__chrome_devtools__navigate_page({
  url: "http://localhost:4000/health"
})

// MCP Tool: evaluate_script
// Objetivo: Extrair e validar JSON response
await mcp__chrome_devtools__evaluate_script({
  function: `() => {
    const preElement = document.querySelector('pre');
    if (preElement) {
      try {
        const json = JSON.parse(preElement.textContent);
        return {
          validJson: true,
          status: json.status,
          checks: json.checks,
          hasTimestamp: !!json.timestamp,
          hasVersion: !!json.version,
          allChecksOk: Object.values(json.checks).every(v => v === 'ok')
        }
      } catch (e) {
        return { validJson: false, error: e.message }
      }
    }
    return { error: 'No pre element found' }
  }`
})

// MCP Tool: take_screenshot
await mcp__chrome_devtools__take_screenshot({
  format: "png"
})

// MCP Tool: list_network_requests
await mcp__chrome_devtools__list_network_requests()

// MCP Tool: get_network_request
// Objetivo: Validar Content-Type JSON
await mcp__chrome_devtools__get_network_request({
  url: "http://localhost:4000/health"
})
```

**Evidências esperadas**:
- ✅ JSON válido renderizado
- ✅ Content-Type: application/json
- ✅ status: "healthy"
- ✅ checks.database: "ok"
- ✅ checks.memory: "ok"
- ✅ checks.policy_engine: "ok"
- ✅ timestamp ISO 8601
- ✅ version: "0.1.0"

---

### **7. Performance Analysis - Core Web Vitals**

```typescript
// MCP Tool: performance_start_trace
// Objetivo: Análise de performance da homepage
await mcp__chrome_devtools__performance_start_trace({
  reload: true,
  autoStop: true
})

// Aguardar carregamento completo...

// MCP Tool: performance_stop_trace
const performanceResults = await mcp__chrome_devtools__performance_stop_trace()

// MCP Tool: performance_analyze_insight
// Objetivo: Detalhar insights de performance
await mcp__chrome_devtools__performance_analyze_insight({
  insightName: "LCPBreakdown"
})

await mcp__chrome_devtools__performance_analyze_insight({
  insightName: "DocumentLatency"
})
```

**Métricas esperadas (Healthcare SLA)**:
- ✅ **LCP (Largest Contentful Paint)**: < 2.5s (target: < 2s healthcare)
- ✅ **FID (First Input Delay)**: < 100ms (target: < 50ms emergency workflows)
- ✅ **CLS (Cumulative Layout Shift)**: < 0.1 (target: 0 para forms médicos)
- ✅ **TTFB (Time to First Byte)**: < 200ms (target: < 50ms)
- ✅ **Total Blocking Time**: < 300ms
- ✅ **Speed Index**: < 3.4s

**Insights esperados**:
- Identificar recursos bloqueantes
- Analisar tamanho de assets (CSS, JS)
- Verificar render-blocking resources
- Validar cache headers

---

### **8. Network Analysis - Security Headers**

```typescript
// MCP Tool: list_network_requests
// Objetivo: Listar todas as requisições
const allRequests = await mcp__chrome_devtools__list_network_requests({
  pageSize: 100,
  pageIdx: 0
})

// MCP Tool: get_network_request
// Objetivo: Analisar headers de segurança da homepage
const homepageRequest = await mcp__chrome_devtools__get_network_request({
  url: "http://localhost:4000/"
})

// Validar headers obrigatórios:
// - strict-transport-security
// - x-content-type-options
// - x-frame-options
// - x-healthcare-compliance
// - x-xss-protection
// - x-permitted-cross-domain-policies
```

**Headers esperados (LGPD/ANVISA/CFM)**:
```http
strict-transport-security: max-age=31536000; includeSubDomains
x-content-type-options: nosniff
x-frame-options: DENY
x-healthcare-compliance: LGPD-BR
x-xss-protection: 1; mode=block
x-permitted-cross-domain-policies: none
content-security-policy: [policy string]
```

---

### **9. Console Messages & Error Detection**

```typescript
// MCP Tool: list_console_messages
// Objetivo: Capturar todos os console logs/errors/warnings
const consoleMessages = await mcp__chrome_devtools__list_console_messages()

// Categorizar por severidade:
// - error: Erros críticos que quebram funcionalidade
// - warning: Avisos não-críticos
// - info: Mensagens informativas
// - log: Debug logs
```

**Validações**:
- ✅ Zero erros JavaScript críticos
- ✅ Nenhum erro de carregamento de assets
- ✅ Nenhum erro de CORS
- ✅ Warnings aceitáveis (desenvolvimento)

---

### **10. Accessibility Testing**

```typescript
// MCP Tool: evaluate_script
// Objetivo: Executar auditoria de acessibilidade
await mcp__chrome_devtools__evaluate_script({
  function: `() => {
    // Verificar estrutura HTML semântica
    const checks = {
      hasHeadings: document.querySelectorAll('h1, h2, h3').length > 0,
      hasLandmarks: document.querySelectorAll('main, header, footer, nav').length > 0,
      formsHaveLabels: Array.from(document.querySelectorAll('input')).every(input => {
        return input.labels && input.labels.length > 0 || input.getAttribute('aria-label');
      }),
      imagesHaveAlt: Array.from(document.querySelectorAll('img')).every(img => {
        return img.alt !== undefined;
      }),
      buttonsHaveText: Array.from(document.querySelectorAll('button')).every(btn => {
        return btn.textContent.trim().length > 0 || btn.getAttribute('aria-label');
      }),
      focusableElementsVisible: true // Verificar programaticamente
    };

    return {
      wcagCompliance: {
        level: 'AA',
        checks: checks,
        passing: Object.values(checks).every(v => v === true)
      }
    };
  }`
})
```

**WCAG 2.1 AA Requirements**:
- ✅ Estrutura HTML semântica (h1, h2, main, etc.)
- ✅ Labels associados a inputs
- ✅ Contrast ratio adequado (4.5:1 texto normal)
- ✅ Focus indicators visíveis
- ✅ Navegação por teclado funcional
- ✅ Textos alternativos em imagens

---

### **11. Form Interaction Testing**

```typescript
// MCP Tool: navigate_page
await mcp__chrome_devtools__navigate_page({
  url: "http://localhost:4000/register"
})

// MCP Tool: fill_form
// Objetivo: Preencher formulário de registro com dados sintéticos
await mcp__chrome_devtools__fill_form({
  elements: [
    { uid: "name_input_uid", value: "Dr. João Silva" },
    { uid: "email_input_uid", value: "teste@exemplo.com.br" },
    { uid: "password_input_uid", value: "SenhaSegura123!" },
    { uid: "role_select_uid", value: "author" },
    { uid: "terms_checkbox_uid", value: "checked" }
  ]
})

// MCP Tool: take_screenshot
// Objetivo: Evidência do formulário preenchido
await mcp__chrome_devtools__take_screenshot({
  fullPage: true,
  format: "png"
})

// MCP Tool: evaluate_script
// Objetivo: Validar que campos foram preenchidos
await mcp__chrome_devtools__evaluate_script({
  function: `() => {
    return {
      nameValue: document.querySelector('#name')?.value,
      emailValue: document.querySelector('#email')?.value,
      passwordFilled: !!document.querySelector('#password')?.value,
      roleSelected: document.querySelector('#role')?.value,
      termsChecked: document.querySelector('#terms')?.checked
    }
  }`
})

// NOTA: NÃO SUBMETER O FORMULÁRIO (apenas teste de UI)
// Não executar: await mcp__chrome_devtools__click({ uid: "submit_button_uid" })
```

**Validações**:
- ✅ Campos aceitam input corretamente
- ✅ Select permite seleção de roles
- ✅ Checkbox pode ser marcado/desmarcado
- ✅ Validação HTML5 funciona (required, email type)
- ✅ Password field oculta caracteres

---

### **12. Responsive Design Testing**

```typescript
// MCP Tool: resize_page
// Objetivo: Testar responsividade em diferentes resoluções

// Desktop (1920x1080)
await mcp__chrome_devtools__resize_page({
  width: 1920,
  height: 1080
})
await mcp__chrome_devtools__take_screenshot({ fullPage: false, format: "png" })

// Tablet (768x1024)
await mcp__chrome_devtools__resize_page({
  width: 768,
  height: 1024
})
await mcp__chrome_devtools__take_screenshot({ fullPage: false, format: "png" })

// Mobile (375x667 - iPhone SE)
await mcp__chrome_devtools__resize_page({
  width: 375,
  height: 667
})
await mcp__chrome_devtools__take_screenshot({ fullPage: false, format: "png" })
```

**Validações Responsive**:
- ✅ Layout adapta corretamente em todas as resoluções
- ✅ Formulários permanecem usáveis em mobile
- ✅ Botões e links têm área de toque adequada (min 44x44px)
- ✅ Texto legível sem zoom
- ✅ Sem scroll horizontal

---

### **13. Network Throttling - Rural Clinics Simulation**

```typescript
// MCP Tool: emulate_network
// Objetivo: Simular conectividade ruim (clínicas rurais)
await mcp__chrome_devtools__emulate_network({
  throttlingOption: "Slow 3G"
})

// MCP Tool: navigate_page
await mcp__chrome_devtools__navigate_page({
  url: "http://localhost:4000/"
})

// MCP Tool: performance_start_trace
await mcp__chrome_devtools__performance_start_trace({
  reload: true,
  autoStop: true
})

// Aguardar carregamento...

// MCP Tool: performance_stop_trace
const slowNetworkPerf = await mcp__chrome_devtools__performance_stop_trace()

// Validar que página permanece funcional mesmo em rede lenta
```

**Validações**:
- ✅ Página carrega completamente (pode demorar mais)
- ✅ Funcionalidade core preservada
- ✅ Fallbacks apropriados para assets pesados
- ✅ Loading indicators (se implementados)

---

### **14. CPU Throttling - Old Clinical Workstations**

```typescript
// MCP Tool: emulate_cpu
// Objetivo: Simular computadores antigos de consultório
await mcp__chrome_devtools__emulate_cpu({
  throttlingRate: 4 // 4x slowdown
})

// MCP Tool: navigate_page
await mcp__chrome_devtools__navigate_page({
  url: "http://localhost:4000/register"
})

// MCP Tool: performance_start_trace
await mcp__chrome_devtools__performance_start_trace({
  reload: true,
  autoStop: true
})

// MCP Tool: performance_stop_trace
const slowCpuPerf = await mcp__chrome_devtools__performance_stop_trace()

// Restaurar configurações
await mcp__chrome_devtools__emulate_cpu({ throttlingRate: 1 })
await mcp__chrome_devtools__emulate_network({ throttlingOption: "No emulation" })
```

**Validações**:
- ✅ Interface permanece responsiva
- ✅ JavaScript não trava a UI
- ✅ Formulários permanecem usáveis

---

### **15. Final Cleanup**

```typescript
// MCP Tool: list_pages
const allPages = await mcp__chrome_devtools__list_pages()

// MCP Tool: close_page
// Objetivo: Fechar todas as páginas abertas
for (const page of allPages) {
  await mcp__chrome_devtools__close_page({ pageIdx: page.index })
}
```

---

## 📊 **RESUMO DE EVIDÊNCIAS GERADAS**

### **Screenshots Capturados**
1. ✅ Homepage desktop (1920x1080)
2. ✅ Homepage tablet (768x1024)
3. ✅ Homepage mobile (375x667)
4. ✅ Login page completa
5. ✅ Register page completa
6. ✅ Register page com formulário preenchido
7. ✅ Dashboard redirect para login
8. ✅ Health check JSON

### **Performance Traces**
1. ✅ Homepage performance (network normal)
2. ✅ Homepage performance (Slow 3G)
3. ✅ Register page performance (CPU throttled 4x)
4. ✅ Core Web Vitals detalhados
5. ✅ LCP breakdown analysis
6. ✅ DocumentLatency insights

### **Network Analysis**
1. ✅ Lista completa de requests por página
2. ✅ Security headers de todas as rotas
3. ✅ Asset loading (CSS, JS, images)
4. ✅ Redirect chains (dashboard → login)

### **Accessibility Reports**
1. ✅ WCAG 2.1 AA compliance checklist
2. ✅ Form labels validation
3. ✅ Semantic HTML structure
4. ✅ Keyboard navigation paths

### **Console Messages**
1. ✅ JavaScript errors (devem ser zero)
2. ✅ Network errors
3. ✅ Warnings e info logs

---

## 🏥 **VALIDAÇÕES HEALTHCARE-SPECIFIC**

### **LGPD Compliance**
- ✅ Checkbox de termos LGPD obrigatório
- ✅ Headers x-healthcare-compliance presentes
- ✅ Dados sintéticos apenas (NO REAL PHI/PII)
- ✅ Session cookies HttpOnly

### **CFM/CRP Compliance**
- ✅ Roles médicos disponíveis (author, editor)
- ✅ Placeholders sugerem uso profissional
- ✅ Interface profissional (sem frivolidades)

### **ANVISA SaMD Readiness**
- ✅ Health monitoring endpoint funcional
- ✅ Version tracking (v0.1.0)
- ✅ Performance SLA compliance (<2s emergency)

---

## ⚠️ **LIMITAÇÃO ATUAL - WSL2 ENVIRONMENT**

**Status**: ⚠️ **MCP CONFIGURADO MAS CHROME NÃO DISPONÍVEL**

### **Problema**
- WSL2 não possui display server (X11/Wayland)
- Chrome/Chromium requer interface gráfica
- Permissões insuficientes para instalação

### **Workarounds Disponíveis**

#### **Opção 1: Remote Debugging (Recomendado)**
```bash
# No Windows (PowerShell)
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="C:\temp\chrome-debug"

# Configurar MCP para conectar ao Windows Chrome
# (Requer atualização do chrome-devtools-mcp config)
```

#### **Opção 2: X11 Forwarding**
```bash
# Instalar VcXsrv ou X410 no Windows
# Configurar DISPLAY no WSL
export DISPLAY=:0

# Instalar Chromium no WSL
sudo apt-get install chromium-browser
```

#### **Opção 3: Docker com Display Forwarding**
```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  chromium-browser
```

---

## 🎯 **PRÓXIMOS PASSOS**

### **Quando Chrome Disponível**
1. ✅ Executar todas as 15 sequências de navegação
2. ✅ Capturar screenshots e traces
3. ✅ Gerar relatório visual completo
4. ✅ Atualizar PRD_AGNOSTICO_STACK_RESEARCH.md com evidências MCP

### **Alternativa Atual**
1. ✅ Continuar com evidence-based validation (curl + HTTP)
2. ✅ Validar HTML structure via parsing
3. ✅ Análise de headers completa
4. ✅ Documentar MCP validation plan (este arquivo)

---

## 📋 **CHECKLIST DE VALIDAÇÃO MCP**

### **Funcional**
- [ ] Homepage renderiza corretamente
- [ ] Login form funcional
- [ ] Register form funcional
- [ ] Dashboard protegido por auth
- [ ] Health check retorna JSON válido
- [ ] Logout funciona

### **Performance**
- [ ] LCP < 2.5s (healthcare: < 2s)
- [ ] FID < 100ms (healthcare: < 50ms)
- [ ] CLS < 0.1 (healthcare: 0)
- [ ] TTFB < 200ms (healthcare: < 50ms)
- [ ] Total page size otimizado

### **Segurança**
- [ ] CSRF tokens presentes
- [ ] Security headers corretos
- [ ] Session cookies HttpOnly
- [ ] HTTPS ready (Strict-Transport-Security)
- [ ] No sensitive data in console

### **Acessibilidade**
- [ ] WCAG 2.1 AA compliant
- [ ] Forms têm labels
- [ ] Keyboard navigation funcional
- [ ] Focus indicators visíveis
- [ ] Contrast ratio adequado

### **Healthcare Compliance**
- [ ] LGPD disclaimer presente
- [ ] Roles médicos disponíveis
- [ ] x-healthcare-compliance header
- [ ] No PHI/PII em screenshots
- [ ] Audit trail completo

---

**✅ PLANO DE VALIDAÇÃO MCP COMPLETO E DOCUMENTADO**

**🔄 Executar quando Chrome browser disponível em ambiente com display gráfico**

---

**Última Atualização**: 29 Setembro 2025
**Status**: Planejado - Aguardando Chrome browser
**Healthcare CMS**: v0.1.0 Sprint 0-2
**Método Atual**: Evidence-based validation via HTTP inspection