# 🔄 Workflow Básico - Claude Code

**Load**: Sob demanda via trigger "workflow" | **Tokens**: ~150 linhas

---

## 📋 **Protocolo de Execução Padrão**

### **1. 🔍 ANÁLISE DO CONTEXTO** [SEMPRE]

```yaml
Detectar_Automaticamente:
  tipo_projeto:
    - frontend: React, Vue, Angular, HTML/CSS/JS
    - backend: Node.js, Python, API, servidor
    - fullstack: Frontend + Backend + database
    - mobile: React Native, Flutter, iOS, Android

  dominio_especifico:
    - healthcare: "médico", "paciente", "PHI", "LGPD"
    - enterprise: "empresa", "corporativo", "compliance"
    - web_development: "website", "webapp", "performance"

  complexidade:
    - simples: Tarefa única, implementation direta
    - medio: Multiple components, some integration
    - complexo: "múltiplas tarefas", "orquestração", "arquitetura"

  necessidades_especificas:
    - performance: "lento", "otimização", "performance"
    - testing: "teste", "testing", "validação"
    - monitoring: "observabilidade", "métricas", "logs"
```

### **2. 📥 CARREGAMENTO INTELIGENTE**

```yaml
Triggers_Automaticos:

  # Frontend/UI Work
  SE (frontend_detected OR ui_keywords):
    CARREGAR docs-llm/capabilities/september-2025/chrome-devtools-mcp.md
    HABILITAR 26 Chrome DevTools (Input, Navigation, Performance, etc.)

  # Performance Issues
  SE (performance_keywords OR slow_app):
    EXECUTAR /context primeiro para token analysis
    CARREGAR docs-llm/capabilities/september-2025/context-engineering.md
    APLICAR workflow: /context → Analyze → Optimize

  # Complex Tasks
  SE (complex_keywords OR multiple_tasks):
    CARREGAR docs-llm/capabilities/multi-agent/orchestration.md
    ATIVAR 90.2% performance improvement capability

  # Medical/Healthcare
  SE (medical_keywords OR healthcare_context):
    CARREGAR docs-llm/domains/healthcare/
    ATIVAR stakeholder protection + compliance frameworks

  # Enterprise Context
  SE (enterprise_keywords OR corporate_environment):
    CARREGAR docs-llm/domains/enterprise/
    ATIVAR security frameworks + audit compliance

  # Implementation Needed
  SE (implementation_keywords OR setup_required):
    CARREGAR docs-llm/templates/ (appropriate category)
    USAR templates em Portuguese-BR
```

---

## ⚡ **Execução Otimizada**

### **3. 🛡️ PROTECTIVE VALIDATION**

```yaml
Ordem_de_Validacao:

  1. Security_Check:
     - Vulnerabilidades conhecidas?
     - Exposição de dados sensíveis?
     - Injection attacks possible?
     - Authentication/Authorization adequate?

  2. Compliance_Check:
     SE projeto_medico:
       - LGPD compliance verificada?
       - ANVISA requirements atendidos?
       - CFM ethical guidelines seguidas?
       - PHI/PII adequadamente protegida?

     SE projeto_enterprise:
       - SOC2/ISO27001 compliance?
       - GDPR requirements atendidos?
       - Audit trails configurados?
       - Access controls implementados?

  3. Stakeholder_Protection:
     - Usuários finais protegidos?
     - Business continuity garantida?
     - Performance SLA atendida?
     - Error handling adequado?
```

### **4. 🔨 IMPLEMENTATION**

```yaml
Evidence_Based_Implementation:

  # Use Real Data When Available
  SE chrome_devtools_mcp_disponivel:
    - Capture real browser behavior
    - Measure actual performance metrics
    - Test real user interactions
    - Validate UI across devices

  SE context_engineering_ativo:
    - Analyze token usage patterns
    - Optimize context loading
    - Measure efficiency gains
    - Document optimization results

  # Portuguese-BR Always
  - Todas as variáveis em português
  - Comentários em português
  - Documentação em português
  - Error messages em português

  # Templates When Implementing
  SE setup_inicial_necessario:
    USAR docs-llm/templates/projeto-inicial/

  SE mcp_server_necessario:
    USAR docs-llm/templates/mcp-servers/

  SE workflow_automation_necessario:
    USAR docs-llm/templates/workflows/
```

---

## 📊 **Validação e Otimização**

### **5. ✅ EVIDENCE-BASED VALIDATION**

```yaml
Validation_Methods:

  # Real Browser Testing (when available)
  chrome_devtools_validation:
    - Screenshot comparisons
    - Performance trace analysis
    - Console error checking
    - Network request validation
    - Accessibility compliance testing

  # Performance Validation
  context_engineering_validation:
    - Token efficiency measurement
    - Response time analysis
    - Memory usage optimization
    - Context loading efficiency

  # Code Quality Validation
  static_analysis:
    - Security vulnerability scanning
    - Code pattern analysis
    - Dependency vulnerability checking
    - Performance bottleneck identification
```

### **6. 📈 CONTINUOUS OPTIMIZATION**

```yaml
Optimization_Workflow:

  # Context Engineering Cycle
  context_optimization:
    - Execute /context before major operations
    - Analyze token distribution
    - Identify high-consumption, low-value components
    - Apply optimization strategies
    - Re-validate with /context
    - Document efficiency gains

  # Multi-Agent When Beneficial
  complex_task_optimization:
    - Identify parallelizable subtasks
    - Delegate to specialized agents
    - Aggregate results efficiently
    - Achieve 90.2% performance improvement

  # Evidence-Based Iteration
  continuous_improvement:
    - Collect real usage metrics
    - Identify patterns and bottlenecks
    - Implement evidence-based optimizations
    - Measure and document improvements
```

---

## 🎯 **Context-Specific Workflows**

### **Frontend/UI Development**
```yaml
Workflow_UI:
  1. /context analysis primeiro
  2. Load Chrome DevTools MCP
  3. Natural language → test generation
  4. Real browser validation
  5. Performance optimization
  6. Accessibility compliance check
```

### **Performance Optimization**
```yaml
Workflow_Performance:
  1. /context command execution
  2. Load context-engineering docs
  3. Identify bottlenecks via real metrics
  4. Apply optimization strategies
  5. Measure improvements
  6. Document efficiency gains
```

### **Healthcare/Medical Projects**
```yaml
Workflow_Healthcare:
  1. Load healthcare compliance docs
  2. PROTECTIVE validation primeiro
  3. LGPD/ANVISA/CFM compliance check
  4. PHI/PII protection implementation
  5. Audit trail configuration
  6. Synthetic data for testing
```

---

## 📝 **Documentação Obrigatória**

```yaml
Sempre_Documentar:

  # Implementation Log
  - Decisões técnicas tomadas
  - Razões para escolhas arquiteturais
  - Security considerations aplicadas
  - Performance optimizations implementadas

  # Evidence Record
  - Real metrics coletadas
  - Browser testing results
  - Performance benchmarks
  - Security validation results

  # Evolution Tracking
  SE nova_capability_implementada:
    DOCUMENTAR em .claude/EVOLUCAO.md:
      - Data de implementação
      - Trigger que causou implementação
      - Benefits alcançados
      - Metrics de impacto
```

---

**🔄 Este workflow garante execução sistemática, evidence-based validation, stakeholder protection, e continuous optimization em todos os tipos de projeto.**