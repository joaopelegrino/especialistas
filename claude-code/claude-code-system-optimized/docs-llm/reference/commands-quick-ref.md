# ⚡ Commands Quick Reference - September 2025

**Load**: Para referência rápida de comandos | **Tokens**: ~100 linhas

---

## 🚀 **September 2025 Enhanced Commands**

### **Context Engineering**
```bash
/context                    # Análise completa de token usage + otimização
                           # Output: Token breakdown, optimization opportunities
                           # Benefit: 15-25% token efficiency gain

# Workflow recomendado:
/context → Plan Mode "ultrathink" → Implement → /context → Validate
```

### **Memory Management**
```bash
/memory                     # Edição direta de arquivos de memória
                           # Features: Team memory sharing, versioning
                           # Enterprise: Role-based access, audit trails

# Casos de uso:
/memory  # Edit team guidance documents
/memory  # Update project-specific knowledge
/memory  # Configure shared workflows
```

### **Permission Doctor**
```bash
/doctor                     # Validação de regras de permissão
                           # Features: Syntax validation, fix suggestions
                           # Enterprise: RBAC integration, policy compliance

# Exemplos:
/doctor  # Validate permission rules syntax
/doctor  # Check wildcard configurations
/doctor  # Enterprise policy compliance
```

---

## 🔧 **Chrome DevTools MCP Commands**

### **Installation & Setup**
```bash
# Quick install
claude mcp add chrome-devtools npx chrome-devtools-mcp@latest

# Verify installation
claude mcp list

# Test functionality
claude mcp get chrome-devtools

# Remove if needed
claude mcp remove chrome-devtools
```

### **26 Available Tools by Category**
```yaml
Input_Automation (7):
  - click()           # Click elements
  - drag()            # Drag operations
  - fill()            # Fill input fields
  - fill_form()       # Complete forms
  - handle_dialog()   # Manage dialogs
  - hover()           # Mouse hover
  - upload_file()     # File uploads

Navigation (7):
  - close_page()      # Close tabs
  - list_pages()      # List open tabs
  - navigate_page()   # Go to URLs
  - navigate_page_history()  # Browser history
  - new_page()        # Open new tab
  - select_page()     # Switch tabs
  - wait_for()        # Wait conditions

Performance (3):
  - performance_analyze_insight()  # Generate reports
  - performance_start_trace()      # Start recording
  - performance_stop_trace()       # Stop + collect data

Network (2):
  - get_network_request()    # Request details
  - list_network_requests()  # All requests + filtering

Debugging (4):
  - evaluate_script()        # Execute JavaScript
  - list_console_messages()  # Console logs + filtering
  - take_screenshot()        # Capture images
  - take_snapshot()          # Page state capture

Emulation (3):
  - emulate_cpu()      # CPU performance levels
  - emulate_network()  # Network conditions
  - resize_page()      # Window dimensions
```

---

## 🌩️ **Enterprise Cloud Commands**

### **AWS Bedrock Setup**
```bash
# Environment variables
export CLAUDE_CODE_USE_BEDROCK=1
export ANTHROPIC_MODEL='us.anthropic.claude-3-7-sonnet-20250219-v1:0'

# Enterprise features
export CLAUDE_CODE_ENTERPRISE_MODE=1
export CLAUDE_CODE_SSO_PROVIDER="okta"

# With context engineering
/context  # Works natively with Bedrock
```

### **Google Vertex AI Setup**
```bash
# Environment variables
export CLOUD_ML_REGION=global
export CLAUDE_CODE_USE_VERTEX=1
export GOOGLE_CLOUD_PROJECT="${PROJECT_ID}"

# September 2025 global endpoints
echo "Global endpoints enabled"
/context  # Works natively with Vertex AI
```

### **OpenTelemetry Monitoring**
```bash
# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317

# Enterprise authentication
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer ${TOKEN}"
```

---

## 🎯 **Smart Loading Triggers**

### **Automatic Context Loading**
```yaml
Frontend_Keywords:
  triggers: ["frontend", "UI", "interface", "React", "Vue"]
  auto_loads: "docs-llm/capabilities/september-2025/chrome-devtools-mcp.md"
  tools_enabled: "26 Chrome DevTools"

Performance_Keywords:
  triggers: ["performance", "lento", "otimização", "tokens"]
  auto_loads: "docs-llm/capabilities/september-2025/context-engineering.md"
  action: "Execute /context primeiro"

Complex_Task_Keywords:
  triggers: ["complexo", "múltiplas tarefas", "orquestração"]
  auto_loads: "docs-llm/capabilities/multi-agent/orchestration.md"
  benefit: "90.2% performance improvement"

Medical_Keywords:
  triggers: ["médico", "healthcare", "paciente", "LGPD"]
  auto_loads: "docs-llm/domains/healthcare/"
  focus: "Stakeholder protection + compliance"

Enterprise_Keywords:
  triggers: ["empresa", "enterprise", "corporativo"]
  auto_loads: "docs-llm/domains/enterprise/"
  features: "Security + audit compliance"
```

---

## 📊 **Performance & Metrics Commands**

### **Token Optimization Workflow**
```bash
# 1. Baseline analysis
/context

# 2. Identify high-consumption, low-value components
# Look for optimization opportunities in output

# 3. Apply optimizations
# Use Plan Mode + "ultrathink" for complex cases

# 4. Validate improvements
/context  # Re-execute to measure gains

# 5. Document results
# Track before/after metrics
```

### **Multi-Agent Performance**
```yaml
When_to_Use_Multi_Agent:
  complexity: "3+ distinct domains"
  time_critical: "Need 75-80% time reduction"
  parallel_beneficial: "Independent subtasks available"
  token_limits: "Approaching context window limits"

Expected_Gains:
  performance: "90.2% improvement vs single-agent"
  time_reduction: "75-80% for complex tasks"
  token_capacity: "15× through context isolation"
  task_acceleration: "45min → <10min"
```

---

## 🔒 **Security & Compliance Commands**

### **Healthcare Compliance**
```yaml
LGPD_Validation:
  - registrar_consentimento()
  - verificar_base_legal()
  - aplicar_anonimizacao()
  - gerar_relatorio_compliance()

ANVISA_Validation:
  - validar_funcionalidade_clinica()
  - verificar_precisao_clinica()
  - verificar_seguranca_paciente()
  - gerar_documentacao_anvisa()

CFM_Validation:
  - validar_assinatura_digital()
  - implementar_sigilo_medico()
  - validar_telemedicina()
  - gerar_relatorio_etico()
```

### **Enterprise Security**
```bash
# SSO Integration
/doctor  # Validate SSO configuration

# RBAC Setup
/memory  # Configure role-based access

# Audit Compliance
export CLAUDE_CODE_AUDIT_ENABLED=1
export CLAUDE_CODE_AUDIT_ENDPOINT="${AUDIT_ENDPOINT}"
```

---

## 🛠️ **Development Workflow Commands**

### **Project Setup**
```bash
# 1. Initialize structure
mkdir -p .claude/{configuracoes,ganchos}

# 2. Setup observability
# Use templates from docs-llm/templates/projeto-inicial/

# 3. Configure Chrome DevTools (if UI)
# Use templates from docs-llm/templates/mcp-servers/

# 4. Enable context engineering
/context  # Establish baseline
```

### **Testing & Validation**
```bash
# UI Testing (with Chrome DevTools MCP)
# Natural language: "Teste o formulário de login"
# → Auto-generates Playwright tests

# Performance Testing
/context → Analyze → Optimize → /context → Validate

# Compliance Testing (Healthcare)
python compliance_integrado.py
```

---

## 🎨 **Portuguese-BR Conventions**

### **Naming Standards**
```yaml
Folders: /configuracoes/, /ganchos/, /servidor-mcp/
Files: validacao_entrada.py, gerenciador_agentes.ts
Functions: validar_comando(), criar_gancho_automatico()
Variables: tempo_execucao, metricas_coletadas
Classes: GerenciadorTarefas, ServidorOrquestracao
Comments: # Valida entrada do usuário

Conventions:
  snake_case: funcoes_e_variaveis
  PascalCase: ClassesEComponentes
  kebab-case: nomes-de-arquivos.md
  sem_acentos: configuracao (não configuração)
```

---

## 🔄 **Troubleshooting Quick Commands**

### **Common Issues**
```bash
# Context loading não funcionou
/context  # Verify token usage
# Check triggers keywords

# Chrome DevTools MCP não conecta
claude mcp list
claude mcp get chrome-devtools

# Performance degradation
/context  # Analyze token distribution
# Apply context engineering

# Compliance validation failed
# Check protective validation first
# Use healthcare compliance framework
```

---

**⚡ Quick Reference fornece access rápido a todos os commands September 2025 com syntax, examples, e troubleshooting para maximum productivity.**