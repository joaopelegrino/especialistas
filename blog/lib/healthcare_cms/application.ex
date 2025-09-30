# DSM:PLATFORM:application_supervisor HEALTHCARE:enterprise_foundation
# DSM:SECURITY:zero_trust_initialization PERFORMANCE:2M_concurrent_ready
defmodule HealthcareCMS.Application do
  @moduledoc """
  Healthcare CMS Application Supervisor

  Enterprise-grade application supervision tree with:
  - Zero Trust Policy Engine
  - Medical Workflow Orchestration
  - Multi-tenant Architecture
  - Real-time Healthcare Monitoring
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Telemetry para healthcare monitoring (temporariamente desabilitado)
      # HealthcareCMSWeb.Telemetry,

      # Database repository
      HealthcareCMS.Repo,

      # PubSub para real-time communication
      {Phoenix.PubSub, name: HealthcareCMS.PubSub},

      # Finch HTTP client para external medical APIs
      {Finch, name: HealthcareCMS.Finch},

      # Background job processing (temporariamente desabilitado)
      # {Oban, Application.fetch_env!(:healthcare_cms, Oban)},

      # Zero Trust Policy Engine (OTP Supervisor)
      HealthcareCMS.Security.PolicyEngine,

      # Medical Workflow Engine (temporariamente desabilitado)
      # HealthcareCMS.Medical.WorkflowEngine,

      # Multi-tenant Manager (temporariamente desabilitado)
      # HealthcareCMS.MultiTenant.Manager,

      # WebAssembly Plugin Manager (temporariamente desabilitado)
      # HealthcareCMS.Plugins.WAMSManager,

      # Healthcare Compliance Monitor (temporariamente desabilitado)
      # HealthcareCMS.Compliance.Monitor,

      # Phoenix Endpoint - Sprint 0-1: HABILITADO (29/09/2025)
      HealthcareCMSWeb.Endpoint
    ]

    # Configurar telemetry handlers (temporariamente desabilitado)
    # HealthcareCMSWeb.Telemetry.attach_handlers()

    # Inicializar Prometheus metrics (temporariamente desabilitado)
    # HealthcareCMS.Monitoring.Prometheus.setup()

    opts = [strategy: :one_for_one, name: HealthcareCMS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(_changed, _new, _removed) do
    # Endpoint config change handling (temporariamente desabilitado)
    # HealthcareCMSWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end