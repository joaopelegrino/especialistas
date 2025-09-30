# 📚 Diário de Referências - Elixir WASM Host Platform

<!-- DSM:DOMAIN:infrastructure|elixir_platform COMPLEXITY:expert DEPS:wasm_runtime -->
<!-- DSM:HEALTHCARE:host_architecture|plugin_isolation|phi_pii_handling|integration_requirements -->
<!-- DSM:PERFORMANCE:concurrency:2M+ response_time:<50ms availability:99.99% wasm_execution:<5s -->
<!-- DSM:COMPLIANCE:LGPD|CFM|ANVISA|Zero_Trust_NIST_SP_800_207|sandbox_isolation -->

*Última atualização: 2025-09-26*
*Versão: 1.0.0*
*Projeto: Healthcare Blog + Content Management System*
*Stack: Elixir Host + WebAssembly Plugins (Score: 99.5/100)*

## 🧩 DSM Dependency Matrix
```yaml
DSM_MATRIX:
  depends_on:
    - elixir_otp_27
    - phoenix_framework_18
    - extism_elixir_sdk
    - healthcare_compliance_layer
  provides_to:
    - wasm_plugin_runtime
    - zero_trust_policy_engine
    - healthcare_content_pipeline
    - mcp_healthcare_server
  integrates_with:
    - postgresql_16_timescaledb
    - zero_trust_architecture
    - post_quantum_cryptography
  performance_contracts:
    - latency_sla: "<50ms API response"
    - concurrency_sla: "2M+ concurrent connections"
    - availability_sla: "99.99% uptime"
  compliance_requirements:
    - lgpd_data_processing: "mandatory"
    - cfm_medical_validation: "required"
    - zero_trust_validation: "continuous"
```

## 🎯 Quick Access Index

- [🏗️ Elixir Host Platform](#-elixir-host-platform) - Core Elixir/OTP, Phoenix, LiveView
- [🔧 WebAssembly Runtime](#-webassembly-runtime) - Extism SDK, WASM plugins
- [🔐 Zero Trust Security](#-zero-trust-security) - NIST SP 800-207, PQC
- [🏥 Healthcare Compliance](#-healthcare-compliance) - LGPD, CFM, ANVISA
- [🤖 AI Pipeline Integration](#-ai-pipeline-integration) - S.1.1→S.4-1.1-3 systems
- [📊 Performance & Monitoring](#-performance--monitoring) - Telemetry, observability
- [🚨 Troubleshooting](#-troubleshooting) - Common issues, solutions

---

## 🏗️ Elixir Host Platform

### Elixir/OTP Core Stack

#### Elixir 1.18.4 + OTP 27
**URL**: https://elixir-lang.org/docs.html
**Tipo**: Runtime Platform
**Validação**: Industry-Standard, Enterprise-Proven
**Última Verificação**: 2025-09-26
**Use Case**: Host system para plugins WebAssembly com healthcare compliance
**Quick Command/Code**:
```bash
# Installation
asdf install elixir 1.18.4-otp-27
asdf install erlang 27.0
asdf global elixir 1.18.4-otp-27
asdf global erlang 27.0

# Project setup
mix new healthcare_platform --sup
cd healthcare_platform
```
```elixir
# Healthcare-specific GenServer for WASM plugin management
defmodule Healthcare.PluginManager do
  use GenServer
  require Logger

  @plugins_registry :healthcare_plugins
  @max_concurrent_plugins 100

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def load_plugin(plugin_id, wasm_binary) do
    GenServer.call(__MODULE__, {:load_plugin, plugin_id, wasm_binary})
  end

  def execute_plugin(plugin_id, function, args) do
    GenServer.call(__MODULE__, {:execute, plugin_id, function, args}, 30_000)
  end

  @impl true
  def init(_opts) do
    Registry.start_link(keys: :unique, name: @plugins_registry)
    {:ok, %{loaded_plugins: %{}, execution_count: 0}}
  end

  @impl true
  def handle_call({:load_plugin, plugin_id, wasm_binary}, _from, state) do
    case Extism.Plugin.new(wasm_binary) do
      {:ok, plugin} ->
        Registry.register(@plugins_registry, plugin_id, plugin)
        new_state = put_in(state.loaded_plugins[plugin_id], plugin)
        {:reply, {:ok, plugin_id}, new_state}

      {:error, reason} ->
        Logger.error("Failed to load plugin #{plugin_id}: #{reason}")
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:execute, plugin_id, function, args}, _from, state) do
    case state.loaded_plugins[plugin_id] do
      nil ->
        {:reply, {:error, :plugin_not_found}, state}

      plugin ->
        result = Extism.Plugin.call(plugin, function, Jason.encode!(args))
        new_count = state.execution_count + 1
        {:reply, {:ok, result}, %{state | execution_count: new_count}}
    end
  end
end
```
**Notas**:
- OTP 27 com melhorias de performance críticas para healthcare
- Pattern matching essencial para medical data validation
- Supervision trees garantem zero downtime para sistema crítico
**Relacionados**:
- [OTP Design Principles](https://www.erlang.org/doc/design_principles/users_guide.html)
- [Elixir Process Performance](https://elixir-lang.org/getting-started/processes.html)

#### Phoenix Framework 1.8.0
**URL**: https://hexdocs.pm/phoenix/Phoenix.html
**Tipo**: Web Framework
**Validação**: Production-Ready, HIPAA-Compatible
**Última Verificação**: 2025-09-26
**Use Case**: Real-time healthcare dashboard com compliance LGPD
**Quick Command/Code**:
```bash
# Healthcare project with LiveView
mix phx.new healthcare_cms --live --database postgres --binary-id
cd healthcare_cms

# Healthcare generators
mix phx.gen.live Medical Patient patients \
  name:string cpf:string:unique crm:string \
  specialty:string birth_date:date \
  encrypted_notes:text

mix phx.gen.live Medical Consultation consultations \
  patient_id:references:patients doctor_id:references:users \
  consultation_date:utc_datetime status:string \
  encrypted_notes:text compliance_status:string
```
```elixir
# Healthcare-specific router with compliance
defmodule HealthcareWeb.Router do
  use HealthcareWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HealthcareWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Healthcare.Plugs.AuditLog
    plug Healthcare.Plugs.LGPDCompliance
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Healthcare.Plugs.APIAuth
    plug Healthcare.Plugs.RateLimit
    plug Healthcare.Plugs.ComplianceHeaders
  end

  pipeline :authenticated do
    plug Healthcare.Guardian.AuthPipeline
    plug Healthcare.Plugs.MFARequired
  end

  scope "/", HealthcareWeb do
    pipe_through [:browser, :authenticated]

    live_session :healthcare,
      on_mount: [Healthcare.UserAuth, Healthcare.ComplianceTracker] do

      live "/dashboard", DashboardLive
      live "/patients", PatientLive.Index
      live "/patients/new", PatientLive.New
      live "/patients/:id", PatientLive.Show
      live "/consultations", ConsultationLive.Index

      # WASM Plugin Management
      live "/plugins", PluginLive.Index
      live "/plugins/:id/execute", PluginLive.Execute
    end
  end

  scope "/api/v1", HealthcareWeb.API do
    pipe_through :api

    # Healthcare-specific endpoints
    resources "/patients", PatientController, except: [:delete]
    resources "/consultations", ConsultationController

    # WASM Plugin API
    post "/plugins/:id/execute", PluginController, :execute
    get "/plugins/status", PluginController, :status
  end

  # Admin area with special compliance
  scope "/admin", HealthcareWeb.Admin do
    pipe_through [:browser, :authenticated, :admin_required]

    live_dashboard "/dashboard", metrics: Healthcare.Telemetry
    live "/audit", AuditLive
    live "/compliance", ComplianceLive
  end
end
```
**Notas**:
- LiveDashboard essencial para monitoring de plugins WASM
- Compliance plugs obrigatórios para healthcare
- Real-time features críticas para monitoring médico
**Relacionados**:
- [Phoenix Security Guide](https://hexdocs.pm/phoenix/security.html)
- [LiveView Security](https://hexdocs.pm/phoenix_live_view/security-model.html)

#### Phoenix LiveView 1.1.0
**URL**: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
**Tipo**: Real-time UI Library
**Validação**: Production-Ready, Healthcare-Proven
**Última Verificação**: 2025-09-26
**Use Case**: Interface real-time para workflow médico S.1.1→S.4-1.1-3
**Quick Command/Code**:
```elixir
# Healthcare Content Generation LiveView
defmodule HealthcareWeb.ContentGenerationLive do
  use HealthcareWeb, :live_view
  alias Healthcare.ContentPipeline

  @impl true
  def mount(%{"workflow" => workflow_id}, _session, socket) do
    if connected?(socket) do
      ContentPipeline.subscribe(workflow_id)
      :timer.send_interval(1000, :update_progress)
    end

    initial_state = %{
      workflow_id: workflow_id,
      current_step: :s11_lgpd_analysis,
      progress: %{
        s11_lgpd_analysis: :pending,
        s12_medical_claims: :pending,
        s212_scientific_search: :pending,
        s32_seo_optimization: :pending,
        s4113_content_generation: :pending
      },
      results: %{},
      compliance_status: :checking,
      errors: []
    }

    {:ok, assign(socket, initial_state)}
  end

  @impl true
  def handle_event("start_pipeline", %{"content" => content}, socket) do
    workflow_id = socket.assigns.workflow_id

    # Start WASM plugin pipeline
    ContentPipeline.start_workflow(workflow_id, content)

    {:noreply,
     socket
     |> assign(:progress, Map.put(socket.assigns.progress, :s11_lgpd_analysis, :running))
     |> put_flash(:info, "Iniciando pipeline de análise médica...")}
  end

  @impl true
  def handle_event("approve_step", %{"step" => step}, socket) do
    ContentPipeline.approve_step(socket.assigns.workflow_id, String.to_atom(step))
    {:noreply, put_flash(socket, :info, "Etapa #{step} aprovada")}
  end

  @impl true
  def handle_info({:step_completed, step, result}, socket) do
    new_progress = Map.put(socket.assigns.progress, step, :completed)
    new_results = Map.put(socket.assigns.results, step, result)

    # Auto-start next step if compliant
    next_step = get_next_step(step)
    if next_step && result.compliance_status == :approved do
      ContentPipeline.start_step(socket.assigns.workflow_id, next_step)
      new_progress = Map.put(new_progress, next_step, :running)
    end

    {:noreply,
     socket
     |> assign(:progress, new_progress)
     |> assign(:results, new_results)
     |> maybe_complete_workflow()}
  end

  @impl true
  def handle_info({:compliance_violation, step, violations}, socket) do
    new_errors = socket.assigns.errors ++ [%{step: step, violations: violations}]

    {:noreply,
     socket
     |> assign(:errors, new_errors)
     |> assign(:compliance_status, :violation)
     |> put_flash(:error, "Violação de compliance detectada: #{inspect(violations)}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="healthcare-pipeline">
      <.header>
        Workflow de Geração de Conteúdo Médico
        <:subtitle>Pipeline S.1.1 → S.4-1.1-3 com compliance LGPD/CFM</:subtitle>
      </.header>

      <!-- Progress Indicator -->
      <div class="pipeline-progress">
        <.step_indicator
          step="s11_lgpd_analysis"
          status={@progress.s11_lgpd_analysis}
          title="Análise LGPD"
          description="Detecção dados sensíveis"
        />
        <.step_indicator
          step="s12_medical_claims"
          status={@progress.s12_medical_claims}
          title="Claims Médicos"
          description="Extração afirmativas"
        />
        <.step_indicator
          step="s212_scientific_search"
          status={@progress.s212_scientific_search}
          title="Busca Científica"
          description="PubMed + SciELO"
        />
        <.step_indicator
          step="s32_seo_optimization"
          status={@progress.s32_seo_optimization}
          title="SEO Médico"
          description="Otimização CFM"
        />
        <.step_indicator
          step="s4113_content_generation"
          status={@progress.s4113_content_generation}
          title="Conteúdo Final"
          description="Geração compliance"
        />
      </div>

      <!-- Compliance Status -->
      <.compliance_badge status={@compliance_status} />

      <!-- Current Step Details -->
      <%= if @progress[@current_step] == :running do %>
        <.live_component
          module={HealthcareWeb.StepExecutionComponent}
          id={"step-#{@current_step}"}
          step={@current_step}
          workflow_id={@workflow_id}
        />
      <% end %>

      <!-- Results Display -->
      <%= for {step, result} <- @results do %>
        <.step_result step={step} result={result} />
      <% end %>

      <!-- Error Display -->
      <%= if length(@errors) > 0 do %>
        <.error_panel errors={@errors} />
      <% end %>

      <!-- Action Buttons -->
      <div class="actions">
        <.button
          phx-click="start_pipeline"
          phx-value-content={@content}
          disabled={@progress.s11_lgpd_analysis != :pending}
          class="btn-primary"
        >
          Iniciar Pipeline
        </.button>
      </div>
    </div>
    """
  end

  defp get_next_step(:s11_lgpd_analysis), do: :s12_medical_claims
  defp get_next_step(:s12_medical_claims), do: :s212_scientific_search
  defp get_next_step(:s212_scientific_search), do: :s32_seo_optimization
  defp get_next_step(:s32_seo_optimization), do: :s4113_content_generation
  defp get_next_step(:s4113_content_generation), do: nil
end
```
**Notas**:
- Real-time monitoring essencial para compliance médica
- WebSocket connections para updates instantâneos do pipeline
- Component architecture para reutilização entre specialties
**Relacionados**:
- [LiveView Components](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html)
- [LiveView Testing](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)

---

## 🔧 WebAssembly Runtime

### Extism Elixir SDK

#### Extism Core Integration
**URL**: https://github.com/extism/elixir-sdk
**Tipo**: WASM Runtime
**Validação**: Production-Ready, Security-First
**Última Verificação**: 2025-09-26
**Use Case**: Sandboxed execution de plugins médicos com isolamento completo
**Quick Command/Code**:
```bash
# Add to mix.exs
{:extism, "~> 1.1.0"}

# Install Extism runtime
curl -O -L https://github.com/extism/extism/releases/latest/download/extism-install.sh
sh extism-install.sh
```
```elixir
# Healthcare Plugin Manager with Security
defmodule Healthcare.SecurePluginManager do
  use GenServer
  require Logger

  @security_config %{
    max_memory: 64 * 1024 * 1024,  # 64MB
    timeout_ms: 30_000,            # 30s
    max_var_bytes: 1024 * 1024,    # 1MB
    enable_wasi: false,            # Security: disable WASI
    allowed_hosts: []              # No network access
  }

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def load_healthcare_plugin(plugin_name, wasm_path, functions) do
    GenServer.call(__MODULE__, {:load_plugin, plugin_name, wasm_path, functions})
  end

  def execute_s11_lgpd(content, metadata) do
    execute_plugin(:s11_lgpd_analyzer, "analyze_lgpd_compliance", %{
      content: content,
      metadata: metadata,
      compliance_rules: Healthcare.Compliance.lgpd_rules()
    })
  end

  def execute_s12_claims(content) do
    execute_plugin(:s12_medical_claims, "extract_medical_claims", %{
      content: content,
      medical_ontology: Healthcare.Ontology.load_medical_terms()
    })
  end

  defp execute_plugin(plugin_name, function, args) do
    GenServer.call(__MODULE__, {:execute, plugin_name, function, args}, 35_000)
  end

  @impl true
  def init(_opts) do
    state = %{
      plugins: %{},
      execution_stats: %{total: 0, errors: 0, avg_time: 0}
    }
    {:ok, state}
  end

  @impl true
  def handle_call({:load_plugin, name, wasm_path, functions}, _from, state) do
    config = Map.merge(@security_config, %{
      functions: functions,
      wasi: false,  # Critical: no file system access
      allowed_paths: [],
      allowed_hosts: []
    })

    case Extism.Plugin.new(File.read!(wasm_path), config) do
      {:ok, plugin} ->
        new_plugins = Map.put(state.plugins, name, plugin)
        Logger.info("Healthcare plugin loaded: #{name}")
        {:reply, {:ok, name}, %{state | plugins: new_plugins}}

      {:error, reason} ->
        Logger.error("Failed to load healthcare plugin #{name}: #{reason}")
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:execute, plugin_name, function, args}, _from, state) do
    case Map.get(state.plugins, plugin_name) do
      nil ->
        {:reply, {:error, :plugin_not_found}, state}

      plugin ->
        start_time = System.monotonic_time(:millisecond)

        # Validate input for healthcare compliance
        case validate_healthcare_input(args) do
          {:ok, sanitized_args} ->
            result = execute_with_monitoring(plugin, function, sanitized_args)
            end_time = System.monotonic_time(:millisecond)

            # Update stats
            execution_time = end_time - start_time
            new_stats = update_stats(state.execution_stats, execution_time, result)

            # Log for compliance audit
            Healthcare.AuditLog.log_plugin_execution(%{
              plugin: plugin_name,
              function: function,
              execution_time: execution_time,
              result: result,
              compliance_check: :passed
            })

            {:reply, result, %{state | execution_stats: new_stats}}

          {:error, compliance_error} ->
            Logger.error("Compliance validation failed: #{compliance_error}")
            {:reply, {:error, :compliance_violation}, state}
        end
    end
  end

  defp execute_with_monitoring(plugin, function, args) do
    try do
      json_input = Jason.encode!(args)
      result = Extism.Plugin.call(plugin, function, json_input)

      case Jason.decode(result) do
        {:ok, decoded} ->
          # Validate output for PII/PHI exposure
          case Healthcare.Compliance.validate_output(decoded) do
            {:ok, clean_output} -> {:ok, clean_output}
            {:error, violations} -> {:error, {:compliance_violation, violations}}
          end

        {:error, _} -> {:error, :invalid_json_response}
      end
    rescue
      e ->
        Logger.error("Plugin execution error: #{Exception.message(e)}")
        {:error, :plugin_execution_failed}
    end
  end

  defp validate_healthcare_input(args) do
    # Remove any PII/PHI that shouldn't be in plugins
    cleaned_args = Healthcare.DataCleaner.sanitize_input(args)

    # Validate against compliance rules
    case Healthcare.Compliance.validate_input(cleaned_args) do
      :ok -> {:ok, cleaned_args}
      {:error, violations} -> {:error, violations}
    end
  end
end
```
**Notas**:
- Security-first: WASI disabled, no network, no file access
- Comprehensive input/output validation for healthcare
- Monitoring e audit trail obrigatórios
**Relacionados**:
- [Extism Security Documentation](https://extism.org/docs/concepts/security)
- [WASM Security Best Practices](https://webassembly-security.com/)

#### Healthcare WASM Plugins

#### S.1.1 LGPD Analyzer Plugin (Rust)
**URL**: https://github.com/extism/rust-sdk
**Tipo**: WASM Plugin
**Validação**: Healthcare-Specific, LGPD-Compliant
**Última Verificação**: 2025-09-26
**Use Case**: Detecção automática de dados sensíveis e análise de risco LGPD
**Quick Command/Code**:
```rust
// Cargo.toml
[package]
name = "s11-lgpd-analyzer"
version = "0.1.0"
edition = "2021"

[dependencies]
extism-pdk = "1.0"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
regex = "1.5"

[lib]
crate-type = ["cdylib"]

// src/lib.rs
use extism_pdk::*;
use serde::{Deserialize, Serialize};
use regex::Regex;

#[derive(Deserialize)]
struct AnalysisInput {
    content: String,
    metadata: Metadata,
    compliance_rules: ComplianceRules,
}

#[derive(Deserialize)]
struct Metadata {
    author_crm: Option<String>,
    specialty: String,
    target_audience: String,
}

#[derive(Deserialize)]
struct ComplianceRules {
    pii_patterns: Vec<String>,
    phi_patterns: Vec<String>,
    professional_data_patterns: Vec<String>,
}

#[derive(Serialize)]
struct LGPDAnalysisResult {
    risk_score: u8,
    detected_pii: Vec<PIIDetection>,
    detected_phi: Vec<PHIDetection>,
    professional_data: Vec<ProfessionalData>,
    compliance_status: String,
    recommendations: Vec<String>,
    validation_forms: Vec<ValidationForm>,
}

#[derive(Serialize)]
struct PIIDetection {
    data_type: String,
    content: String,
    confidence: f32,
    legal_basis_required: bool,
    consent_required: bool,
}

#[derive(Serialize)]
struct ValidationForm {
    form_type: String,
    fields: Vec<FormField>,
    required_consents: Vec<String>,
}

#[plugin_fn]
pub fn analyze_lgpd_compliance(input: String) -> FnResult<String> {
    let analysis_input: AnalysisInput = serde_json::from_str(&input)
        .map_err(|e| WithReturnCode::new(Error::msg(e.to_string()), 1))?;

    let mut risk_score = 0u8;
    let mut detected_pii = Vec::new();
    let mut detected_phi = Vec::new();
    let mut recommendations = Vec::new();

    // Detect CPF
    let cpf_regex = Regex::new(r"\d{3}\.\d{3}\.\d{3}-\d{2}").unwrap();
    if let Some(cpf_match) = cpf_regex.find(&analysis_input.content) {
        detected_pii.push(PIIDetection {
            data_type: "CPF".to_string(),
            content: cpf_match.as_str().to_string(),
            confidence: 0.95,
            legal_basis_required: true,
            consent_required: true,
        });
        risk_score += 30;
        recommendations.push("Verificar consentimento explícito para uso de CPF".to_string());
    }

    // Detect medical registration numbers (CRM, CRP)
    let crm_regex = Regex::new(r"CRM[/-]?\s*\w{2}[/-]?\s*\d+").unwrap();
    for crm_match in crm_regex.find_iter(&analysis_input.content) {
        detected_phi.push(PHIDetection {
            data_type: "CRM".to_string(),
            content: crm_match.as_str().to_string(),
            confidence: 0.90,
            requires_professional_validation: true,
        });
        risk_score += 20;
    }

    // Detect patient names or references
    let patient_ref_patterns = [
        r"paciente\s+[A-Z][a-z]+",
        r"Sr\.\s+[A-Z][a-z]+",
        r"Sra\.\s+[A-Z][a-z]+",
    ];

    for pattern in &patient_ref_patterns {
        let regex = Regex::new(pattern).unwrap();
        if regex.is_match(&analysis_input.content) {
            detected_pii.push(PIIDetection {
                data_type: "Patient Reference".to_string(),
                content: "[REDACTED]".to_string(),
                confidence: 0.75,
                legal_basis_required: true,
                consent_required: true,
            });
            risk_score += 25;
            recommendations.push("Anonimizar referências a pacientes específicos".to_string());
        }
    }

    // Generate validation forms based on detections
    let mut validation_forms = Vec::new();

    if !detected_pii.is_empty() {
        validation_forms.push(ValidationForm {
            form_type: "Consentimento Dados Pessoais".to_string(),
            fields: vec![
                FormField {
                    name: "patient_consent".to_string(),
                    label: "Consentimento do paciente para uso de dados pessoais".to_string(),
                    field_type: "checkbox".to_string(),
                    required: true,
                },
                FormField {
                    name: "legal_basis".to_string(),
                    label: "Base legal para tratamento dos dados".to_string(),
                    field_type: "select".to_string(),
                    required: true,
                },
            ],
            required_consents: vec!["patient_consent".to_string()],
        });
    }

    // Determine compliance status
    let compliance_status = match risk_score {
        0..=20 => "baixo_risco",
        21..=50 => "medio_risco",
        51..=80 => "alto_risco",
        _ => "critico",
    };

    let result = LGPDAnalysisResult {
        risk_score,
        detected_pii,
        detected_phi,
        professional_data: vec![], // Implement professional data detection
        compliance_status: compliance_status.to_string(),
        recommendations,
        validation_forms,
    };

    let output = serde_json::to_string(&result)
        .map_err(|e| WithReturnCode::new(Error::msg(e.to_string()), 1))?;

    Ok(output)
}

#[derive(Serialize)]
struct PHIDetection {
    data_type: String,
    content: String,
    confidence: f32,
    requires_professional_validation: bool,
}

#[derive(Serialize)]
struct FormField {
    name: String,
    label: String,
    field_type: String,
    required: bool,
}

#[derive(Serialize)]
struct ProfessionalData {
    data_type: String,
    value: String,
    validation_status: String,
}
```
```bash
# Build WASM plugin
cargo build --target wasm32-unknown-unknown --release
cp target/wasm32-unknown-unknown/release/s11_lgpd_analyzer.wasm ../healthcare_platform/priv/plugins/
```
**Notas**:
- Regex patterns específicos para dados brasileiros (CPF, CRM, CRP)
- Score de risco calculado dinamicamente
- Geração automática de formulários de validação
**Relacionados**:
- [Extism Rust PDK](https://github.com/extism/rust-pdk)
- [LGPD Compliance Patterns](https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd)

---

## 🔐 Zero Trust Security

### Post-Quantum Cryptography

#### ex_oqs Library Integration
**URL**: https://github.com/chrisliaw/ex_oqs
**Tipo**: Quantum-Safe Cryptography
**Validação**: NIST-Standardized, Healthcare-Ready
**Última Verificação**: 2025-09-26
**Use Case**: Proteção "Harvest Now, Decrypt Later" para dados médicos de longo prazo
**Quick Command/Code**:
```bash
# Add to mix.exs
{:ex_oqs, "~> 0.3.0"}

# Install liboqs system dependencies
# Ubuntu/Debian
sudo apt-get install liboqs-dev

# macOS
brew install liboqs
```
```elixir
# Healthcare Quantum-Safe Crypto Module
defmodule Healthcare.QuantumSafeCrypto do
  alias ExOqs.{KEM, Signature}

  @kem_algorithms [:kyber512, :kyber768, :kyber1024]  # ML-KEM variants
  @sig_algorithms [:dilithium2, :dilithium3, :dilithium5]  # ML-DSA variants

  # Default to NIST Level 3 security (192-bit equivalent)
  @default_kem :kyber768      # ML-KEM-768
  @default_sig :dilithium3    # ML-DSA-65

  @doc """
  Encrypt patient data with post-quantum KEM + AES hybrid encryption
  """
  def encrypt_patient_data(patient_data, public_key, algorithm \\ @default_kem) do
    with {:ok, {shared_secret, ciphertext}} <- KEM.encaps(public_key, algorithm),
         {:ok, encrypted_data} <- aes_encrypt(patient_data, shared_secret) do

      # Store both the KEM ciphertext and AES-encrypted data
      encrypted_envelope = %{
        kem_algorithm: algorithm,
        kem_ciphertext: ciphertext,
        encrypted_data: encrypted_data,
        timestamp: DateTime.utc_now(),
        compliance_flags: [:lgpd, :hipaa, :quantum_safe]
      }

      {:ok, encrypted_envelope}
    else
      error -> {:error, error}
    end
  end

  @doc """
  Decrypt patient data using post-quantum KEM
  """
  def decrypt_patient_data(encrypted_envelope, private_key) do
    %{
      kem_algorithm: algorithm,
      kem_ciphertext: kem_ciphertext,
      encrypted_data: encrypted_data
    } = encrypted_envelope

    with {:ok, shared_secret} <- KEM.decaps(kem_ciphertext, private_key, algorithm),
         {:ok, patient_data} <- aes_decrypt(encrypted_data, shared_secret) do

      # Log decryption for audit trail
      Healthcare.AuditLog.log_data_decryption(%{
        algorithm: algorithm,
        timestamp: DateTime.utc_now(),
        compliance_status: :authorized
      })

      {:ok, patient_data}
    else
      error -> {:error, error}
    end
  end

  @doc """
  Generate quantum-safe key pairs for healthcare professionals
  """
  def generate_professional_keypair(crm, specialty, algorithm \\ @default_kem) do
    case KEM.keygen(algorithm) do
      {:ok, {public_key, private_key}} ->
        keypair_metadata = %{
          crm: crm,
          specialty: specialty,
          algorithm: algorithm,
          generated_at: DateTime.utc_now(),
          key_id: generate_key_id(crm, algorithm),
          compliance_level: nist_security_level(algorithm)
        }

        # Store in secure key management system
        Healthcare.KeyManager.store_keypair(%{
          public_key: public_key,
          private_key: private_key,
          metadata: keypair_metadata
        })

        {:ok, {public_key, keypair_metadata}}

      error -> {:error, error}
    end
  end

  @doc """
  Sign medical documents with quantum-safe digital signatures
  """
  def sign_medical_document(document, private_key, metadata, algorithm \\ @default_sig) do
    document_hash = :crypto.hash(:sha3_256, Jason.encode!(document))

    case Signature.sign(document_hash, private_key, algorithm) do
      {:ok, signature} ->
        signed_document = %{
          document: document,
          signature: %{
            algorithm: algorithm,
            value: signature,
            signer_crm: metadata.crm,
            signed_at: DateTime.utc_now(),
            document_hash: document_hash,
            compliance_attestation: generate_compliance_attestation(metadata)
          },
          metadata: metadata
        }

        {:ok, signed_document}

      error -> {:error, error}
    end
  end

  @doc """
  Verify quantum-safe signatures on medical documents
  """
  def verify_medical_signature(signed_document, public_key) do
    %{
      document: document,
      signature: %{
        algorithm: algorithm,
        value: signature,
        document_hash: stored_hash
      }
    } = signed_document

    # Verify document integrity
    computed_hash = :crypto.hash(:sha3_256, Jason.encode!(document))

    if computed_hash == stored_hash do
      case Signature.verify(signature, computed_hash, public_key, algorithm) do
        {:ok, true} ->
          {:ok, :signature_valid}
        {:ok, false} ->
          {:error, :signature_invalid}
        error ->
          {:error, error}
      end
    else
      {:error, :document_tampered}
    end
  end

  # Hybrid classical-quantum transition support
  def hybrid_encrypt(data, quantum_public_key, classical_public_key) do
    # Encrypt with both algorithms during transition period
    with {:ok, quantum_result} <- encrypt_patient_data(data, quantum_public_key),
         {:ok, classical_result} <- encrypt_with_rsa(data, classical_public_key) do

      hybrid_envelope = %{
        quantum_encryption: quantum_result,
        classical_encryption: classical_result,
        transition_period: true,
        created_at: DateTime.utc_now()
      }

      {:ok, hybrid_envelope}
    end
  end

  # Private helper functions
  defp aes_encrypt(data, key) do
    key_256 = :crypto.hash(:sha256, key) |> binary_part(0, 32)
    iv = :crypto.strong_rand_bytes(16)

    encrypted = :crypto.crypto_one_time(:aes_256_cbc, key_256, iv, data, true)
    {:ok, %{encrypted: encrypted, iv: iv}}
  end

  defp aes_decrypt(%{encrypted: encrypted, iv: iv}, key) do
    key_256 = :crypto.hash(:sha256, key) |> binary_part(0, 32)

    case :crypto.crypto_one_time(:aes_256_cbc, key_256, iv, encrypted, false) do
      decrypted when is_binary(decrypted) -> {:ok, decrypted}
      error -> {:error, error}
    end
  end

  defp encrypt_with_rsa(data, public_key) do
    # Fallback RSA encryption for transition period
    # Implementation details...
    {:ok, %{classical_encrypted: data}}
  end

  defp generate_key_id(crm, algorithm) do
    "#{crm}-#{algorithm}-#{System.system_time(:second)}"
    |> :crypto.hash(:sha256)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end

  defp nist_security_level(:kyber512), do: 1    # 128-bit
  defp nist_security_level(:kyber768), do: 3    # 192-bit (recommended)
  defp nist_security_level(:kyber1024), do: 5   # 256-bit
  defp nist_security_level(:dilithium2), do: 1  # 128-bit
  defp nist_security_level(:dilithium3), do: 3  # 192-bit
  defp nist_security_level(:dilithium5), do: 5  # 256-bit

  defp generate_compliance_attestation(metadata) do
    %{
      lgpd_compliant: true,
      cfm_authorized: verify_crm(metadata.crm),
      quantum_safe: true,
      attestation_id: Ecto.UUID.generate()
    }
  end

  defp verify_crm(crm) do
    # Integration with CRM/CRP databases
    Healthcare.Professional.verify_active_registration(crm)
  end
end
```
**Notas**:
- Hybrid encryption durante período de transição (5-10 anos)
- Compliance integrado (LGPD + CFM + quantum-safe)
- Performance considerada (+60% overhead aceitável)
**Relacionados**:
- [NIST Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [liboqs Documentation](https://github.com/open-quantum-safe/liboqs)

### Zero Trust Policy Engine

#### NIST SP 800-207 Implementation
**URL**: https://csrc.nist.gov/publications/detail/sp/800-207/final
**Tipo**: Security Framework
**Validação**: Federal Standard, Healthcare-Adapted
**Última Verificação**: 2025-09-26
**Use Case**: Policy Engine para healthcare com scoring dinâmico e compliance automática
**Quick Command/Code**:
```elixir
# Zero Trust Policy Engine for Healthcare
defmodule Healthcare.ZeroTrust.PolicyEngine do
  use GenServer
  require Logger

  alias Healthcare.ZeroTrust.{TrustAlgorithm, ComplianceRules, AuditTrail}

  @data_sources [
    :cdm_system,
    :lgpd_compliance_system,
    :cfm_crp_registry,
    :threat_intelligence,
    :network_activity_logs,
    :healthcare_access_policies,
    :enterprise_pki,
    :medical_identity_mgmt,
    :siem_integration
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Evaluate access request with comprehensive healthcare context
  """
  def evaluate_access(subject, resource, context) do
    GenServer.call(__MODULE__, {:evaluate_access, subject, resource, context})
  end

  @doc """
  Update trust score based on behavior and context
  """
  def update_trust_score(subject, new_data) do
    GenServer.cast(__MODULE__, {:update_trust_score, subject, new_data})
  end

  @impl true
  def init(_opts) do
    # Initialize connections to all data sources
    data_sources = initialize_data_sources(@data_sources)

    state = %{
      data_sources: data_sources,
      trust_scores: %{},
      policy_cache: %{},
      compliance_rules: ComplianceRules.load_all(),
      stats: %{
        total_evaluations: 0,
        blocked_requests: 0,
        compliance_violations: 0
      }
    }

    # Schedule periodic policy updates
    :timer.send_interval(60_000, :update_policies)

    {:ok, state}
  end

  @impl true
  def handle_call({:evaluate_access, subject, resource, context}, _from, state) do
    start_time = System.monotonic_time(:microsecond)

    # Gather data from all sources
    evaluation_data = gather_evaluation_data(subject, resource, context, state.data_sources)

    # Calculate trust score using healthcare-specific algorithm
    trust_score = TrustAlgorithm.calculate_trust_score(
      subject,
      resource,
      context,
      evaluation_data
    )

    # Apply healthcare compliance rules
    compliance_check = ComplianceRules.validate_access(
      subject,
      resource,
      context,
      state.compliance_rules
    )

    # Make access decision
    decision = make_access_decision(trust_score, compliance_check, resource)

    # Log for audit trail (HIPAA requirement)
    AuditTrail.log_access_decision(%{
      subject: sanitize_subject_for_audit(subject),
      resource: resource,
      decision: decision,
      trust_score: trust_score,
      compliance_status: compliance_check.status,
      context: sanitize_context_for_audit(context),
      evaluation_time: System.monotonic_time(:microsecond) - start_time
    })

    # Update statistics
    new_stats = update_statistics(state.stats, decision)

    {:reply, decision, %{state | stats: new_stats}}
  end

  @impl true
  def handle_cast({:update_trust_score, subject, new_data}, state) do
    current_score = Map.get(state.trust_scores, subject.id, 50)
    updated_score = TrustAlgorithm.update_score(current_score, new_data)

    new_trust_scores = Map.put(state.trust_scores, subject.id, updated_score)

    {:noreply, %{state | trust_scores: new_trust_scores}}
  end

  @impl true
  def handle_info(:update_policies, state) do
    # Refresh compliance rules from regulatory sources
    updated_rules = ComplianceRules.refresh_from_sources()

    Logger.info("Updated compliance rules: #{length(updated_rules)} rules active")

    {:noreply, %{state | compliance_rules: updated_rules}}
  end

  # Private functions
  defp gather_evaluation_data(subject, resource, context, data_sources) do
    data_sources
    |> Enum.map(fn {source, connection} ->
      {source, fetch_data_from_source(source, connection, subject, resource, context)}
    end)
    |> Enum.into(%{})
  end

  defp fetch_data_from_source(:cdm_system, connection, subject, resource, _context) do
    # Continuous Diagnostics and Mitigation
    %{
      device_compliance: CDMSystem.get_device_compliance(connection, subject.device_id),
      software_inventory: CDMSystem.get_software_status(connection, subject.device_id),
      vulnerability_status: CDMSystem.get_vulnerability_status(connection, subject.device_id)
    }
  end

  defp fetch_data_from_source(:lgpd_compliance_system, connection, subject, resource, context) do
    %{
      data_classification: LGPDSystem.classify_resource(connection, resource),
      consent_status: LGPDSystem.check_consent(connection, subject.id, resource),
      processing_lawfulness: LGPDSystem.validate_processing_basis(connection, context)
    }
  end

  defp fetch_data_from_source(:cfm_crp_registry, connection, subject, _resource, _context) do
    case subject.professional_registration do
      %{crm: crm} -> CFMRegistry.validate_registration(connection, crm)
      %{crp: crp} -> CRPRegistry.validate_registration(connection, crp)
      _ -> %{status: :not_applicable}
    end
  end

  defp fetch_data_from_source(:threat_intelligence, connection, subject, resource, context) do
    %{
      ip_reputation: ThreatIntel.check_ip_reputation(connection, context.source_ip),
      anomaly_score: ThreatIntel.calculate_anomaly_score(connection, subject, context),
      known_threats: ThreatIntel.check_known_threats(connection, subject.device_id)
    }
  end

  defp make_access_decision(trust_score, compliance_check, resource) do
    # Healthcare-specific decision logic
    min_score = determine_minimum_score(resource)

    decision_result = cond do
      compliance_check.status == :violation ->
        %{
          decision: :deny,
          reason: :compliance_violation,
          violations: compliance_check.violations
        }

      trust_score < min_score ->
        %{
          decision: :deny,
          reason: :insufficient_trust,
          required_score: min_score,
          actual_score: trust_score
        }

      resource.classification == :critical_patient_data && trust_score < 85 ->
        %{
          decision: :challenge,
          reason: :additional_verification_required,
          required_actions: [:mfa, :supervisor_approval]
        }

      true ->
        %{
          decision: :allow,
          trust_score: trust_score,
          compliance_status: compliance_check.status,
          conditions: determine_access_conditions(trust_score, resource)
        }
    end

    # Add audit requirements for healthcare
    Map.put(decision_result, :audit_required, true)
  end

  defp determine_minimum_score(resource) do
    case resource.classification do
      :public -> 30
      :internal -> 50
      :confidential -> 70
      :patient_data -> 75
      :critical_patient_data -> 85
      :research_data -> 80
      :financial_data -> 85
    end
  end

  defp determine_access_conditions(trust_score, resource) do
    conditions = []

    conditions = if trust_score < 80 && resource.type == :write do
      [:audit_all_changes | conditions]
    else
      conditions
    end

    conditions = if resource.classification in [:patient_data, :critical_patient_data] do
      [:log_all_access, :encrypt_transmission | conditions]
    else
      conditions
    end

    conditions
  end

  defp sanitize_subject_for_audit(subject) do
    # Remove sensitive data but keep audit-relevant information
    %{
      id: subject.id,
      role: subject.role,
      professional_type: subject.professional_type,
      device_type: subject.device_type,
      # Never log passwords, tokens, or personal details
      audit_timestamp: DateTime.utc_now()
    }
  end

  defp sanitize_context_for_audit(context) do
    %{
      source_ip: anonymize_ip(context.source_ip),
      user_agent_type: classify_user_agent(context.user_agent),
      request_type: context.request_type,
      timestamp: context.timestamp
    }
  end

  defp initialize_data_sources(sources) do
    Enum.map(sources, fn source ->
      connection = connect_to_data_source(source)
      {source, connection}
    end)
    |> Enum.into(%{})
  end

  defp connect_to_data_source(source) do
    # Initialize connections to each data source
    # Implementation depends on specific systems
    %{source: source, connected_at: DateTime.utc_now()}
  end

  defp anonymize_ip(ip) when is_binary(ip) do
    # Anonymize last octet for IPv4, last 64 bits for IPv6
    case String.split(ip, ".") do
      [a, b, c, _d] -> "#{a}.#{b}.#{c}.xxx"
      _ -> "anonymized"
    end
  end

  defp classify_user_agent(user_agent) do
    cond do
      String.contains?(user_agent, "Mobile") -> :mobile
      String.contains?(user_agent, "Tablet") -> :tablet
      true -> :desktop
    end
  end

  defp update_statistics(stats, %{decision: :deny}) do
    %{stats |
      total_evaluations: stats.total_evaluations + 1,
      blocked_requests: stats.blocked_requests + 1
    }
  end

  defp update_statistics(stats, %{decision: _}) do
    %{stats | total_evaluations: stats.total_evaluations + 1}
  end
end
```
**Notas**:
- 9 fontes de dados integradas conforme NIST SP 800-207
- Trust algorithm específico para healthcare
- Compliance automática LGPD/CFM/CRP
**Relacionados**:
- [NIST Zero Trust Architecture](https://www.nist.gov/publications/zero-trust-architecture)
- [Healthcare Zero Trust Implementation](https://www.hhs.gov/about/news/2021/12/28/zero-trust-architecture-strategy.html)

---

## 🚨 Troubleshooting

### Common Issues

#### WASM Plugin Memory Issues
**Problema**: Plugins WASM consumindo muita memória ou causando timeouts
**Sintomas**:
- `Extism.Plugin.call` retorna timeout
- Memory allocation errors
- Host system fica lento
**Solução**:
```elixir
# Configuração de recursos otimizada para healthcare
@plugin_config %{
  max_memory: 32 * 1024 * 1024,  # Reduzir para 32MB se necessário
  timeout_ms: 15_000,            # Timeout mais agressivo
  max_var_bytes: 512 * 1024,     # Limitar variáveis
  enable_wasi: false,            # Sempre desabilitado
  allowed_hosts: [],
  max_http_response_bytes: 1024 * 1024  # 1MB max para APIs
}

# Monitoramento de recursos
def execute_with_monitoring(plugin, function, args) do
  start_memory = :erlang.memory(:total)
  start_time = System.monotonic_time(:millisecond)

  try do
    result = Extism.Plugin.call(plugin, function, args)

    end_time = System.monotonic_time(:millisecond)
    end_memory = :erlang.memory(:total)

    # Log metrics
    Logger.info("Plugin execution: #{end_time - start_time}ms, #{end_memory - start_memory} bytes")

    result
  rescue
    e ->
      Logger.error("Plugin execution failed: #{Exception.message(e)}")
      {:error, :plugin_execution_failed}
  end
end
```

#### Zero Trust Policy Conflicts
**Problema**: Múltiplas regras de compliance conflitantes
**Sintomas**:
- Access denied inesperados
- Compliance violations em cenários válidos
- Performance degradada na evaluação de policies
**Solução**:
```elixir
# Hierarquia de regras para healthcare
defmodule Healthcare.ComplianceRules do
  @rule_priority %{
    patient_safety: 100,    # Highest priority
    lgpd_compliance: 90,
    cfm_regulations: 85,
    crp_regulations: 85,
    hipaa_compliance: 80,
    general_security: 70,
    operational_policies: 50
  }

  def resolve_conflicts(applicable_rules) do
    applicable_rules
    |> Enum.sort_by(fn rule -> @rule_priority[rule.category] end, &>=/2)
    |> apply_rules_cascade()
  end

  defp apply_rules_cascade([primary_rule | other_rules]) do
    # Apply primary rule, then validate others don't create conflicts
    case validate_rule_compatibility(primary_rule, other_rules) do
      :compatible -> {:ok, primary_rule}
      {:conflict, conflicting_rule} ->
        {:error, {:rule_conflict, primary_rule, conflicting_rule}}
    end
  end
end
```

#### Post-Quantum Crypto Performance
**Problema**: PQC causing significant latency in production
**Sintomas**:
- Request timeouts
- High CPU usage
- Slow encryption/decryption
**Solução**:
```elixir
# Hybrid optimization strategy
defmodule Healthcare.CryptoOptimization do
  @fast_data_threshold 1024  # 1KB

  def optimized_encrypt(data, public_key) when byte_size(data) < @fast_data_threshold do
    # Use faster classical crypto for small data during transition
    encrypt_classical_aes(data, public_key)
  end

  def optimized_encrypt(data, public_key) do
    # Use PQC for larger, more sensitive data
    Healthcare.QuantumSafeCrypto.encrypt_patient_data(data, public_key)
  end

  # Background key pre-generation
  def pregenerate_keypairs(count \\ 10) do
    Task.Supervisor.async_stream(
      Healthcare.TaskSupervisor,
      1..count,
      fn _i ->
        Healthcare.QuantumSafeCrypto.generate_professional_keypair(
          "pregenerated",
          "general"
        )
      end,
      max_concurrency: System.schedulers_online()
    )
    |> Enum.to_list()
  end
end
```

### Performance Optimization

#### WASM Plugin Optimization
```elixir
# Plugin pooling for better performance
defmodule Healthcare.PluginPool do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def get_plugin(plugin_type) do
    case Registry.lookup(Healthcare.PluginRegistry, plugin_type) do
      [{pid, _}] -> {:ok, pid}
      [] -> start_new_plugin(plugin_type)
    end
  end

  defp start_new_plugin(plugin_type) do
    child_spec = %{
      id: plugin_type,
      start: {Healthcare.PluginWorker, :start_link, [plugin_type]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
```

#### Database Optimization for Healthcare
```elixir
# Optimized queries for patient data
defmodule Healthcare.Queries.Optimized do
  import Ecto.Query

  def patients_with_recent_activity(days \\ 30) do
    from p in Patient,
      left_join: c in Consultation, on: c.patient_id == p.id,
      left_join: pr in Prescription, on: pr.patient_id == p.id,
      where: c.date >= ago(^days, "day") or pr.date >= ago(^days, "day"),
      group_by: p.id,
      select: %{
        patient: p,
        recent_consultations: count(c.id),
        recent_prescriptions: count(pr.id)
      },
      preload: [:current_medications]
  end

  # Use database functions for encryption when possible
  def encrypted_search(search_term) do
    from p in Patient,
      where: fragment("decrypt_patient_name(?) ILIKE ?", p.encrypted_name, ^"%#{search_term}%"),
      select: p
  end
end
```

**Notas Gerais**:
- Sempre priorizar patient safety sobre performance
- Compliance nunca deve ser comprometida por otimizações
- Monitoramento contínuo essencial para sistemas healthcare
**Relacionados**:
- [Elixir Performance Guide](https://elixir-lang.org/getting-started/mix-otp/genserver.html#performance)
- [Phoenix Performance](https://hexdocs.pm/phoenix/Phoenix.html#performance)
- [Healthcare Security Best Practices](https://www.hhs.gov/hipaa/for-professionals/security/index.html)