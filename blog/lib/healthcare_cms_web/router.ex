# DSM:PLATFORM:web_routing HEALTHCARE:phoenix_router
# DSM:SECURITY:zero_trust_routing PERFORMANCE:route_optimization
defmodule HealthcareCMSWeb.Router do
  @moduledoc """
  Healthcare CMS Router

  Sprint 0-1: Rotas essenciais para web interface foundation.

  Security:
  - Zero Trust policy enforcement em todas as rotas privadas
  - CSRF protection para mutations
  - Healthcare context injection via pipeline

  Routes:
  - Public: /, /health (monitoring)
  - Private: /dashboard (Sprint 0-2+)
  """

  use HealthcareCMSWeb, :router

  # Public pipeline (sem autenticação)
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HealthcareCMSWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # Healthcare-specific headers
    plug :put_healthcare_context
    # Assign current user from session
    plug HealthcareCMSWeb.Plugs.AssignCurrentUser
  end

  # API pipeline para medical device integrations (Sprint 0-3+)
  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    # Zero Trust context injection para API
    plug :put_zero_trust_context
  end

  # Protected pipeline (requer autenticação - Sprint 0-2)
  pipeline :authenticated do
    plug HealthcareCMSWeb.Plugs.RequireAuth
  end

  # Public routes
  scope "/", HealthcareCMSWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/health", HealthController, :check

    # Authentication routes (Sprint 0-2)
    get "/login", PageController, :login
    post "/login", PageController, :do_login
    get "/register", PageController, :register
    post "/register", PageController, :do_register
    get "/logout", PageController, :logout
  end

  # Protected routes (Sprint 0-2+)
  scope "/dashboard", HealthcareCMSWeb do
    pipe_through [:browser, :authenticated]

    get "/", PageController, :dashboard
    # Content management (Sprint 0-3)
    # live "/posts", PostLive.Index, :index
    # live "/posts/new", PostLive.Index, :new
    # live "/posts/:id/edit", PostLive.Index, :edit
    # live "/posts/:id", PostLive.Show, :show
  end

  # API routes (Sprint 0-3+)
  # scope "/api", HealthcareCMSWeb do
  #   pipe_through :api
  #
  #   post "/auth/login", AuthController, :login
  #   post "/auth/logout", AuthController, :logout
  # end

  # Development routes (Sprint 0-2+)
  # if Application.compile_env(:healthcare_cms, :dev_routes) do
  #   import Phoenix.LiveDashboard.Router
  #
  #   scope "/dev" do
  #     pipe_through :browser
  #
  #     live_dashboard "/dashboard", metrics: HealthcareCMSWeb.Telemetry
  #     forward "/mailbox", Plug.Swoosh.MailboxPreview
  #   end
  # end

  # Healthcare context injection (LGPD/ANVISA compliance tracking)
  defp put_healthcare_context(conn, _opts) do
    conn
    |> Plug.Conn.put_private(:healthcare_compliance, "LGPD-BR")
    |> Plug.Conn.put_private(:request_timestamp, System.system_time(:millisecond))
  end

  # Zero Trust context injection para API requests
  defp put_zero_trust_context(conn, _opts) do
    conn
    |> Plug.Conn.put_private(:zero_trust_enabled, true)
    |> Plug.Conn.put_private(:policy_engine, HealthcareCMS.Security.PolicyEngine)
  end
end