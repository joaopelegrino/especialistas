# DSM:PLATFORM:web_foundation HEALTHCARE:phoenix_helpers
# DSM:SECURITY:zero_trust_web_helpers PERFORMANCE:compile_optimization
defmodule HealthcareCMSWeb do
  @moduledoc """
  Healthcare CMS Web Foundation Module

  Sprint 0-1: Base module para Phoenix web layer.
  Provides import shortcuts and configuration for:
  - Controllers
  - LiveViews
  - Components
  - Layouts
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: HealthcareCMSWeb.Layouts]

      import Plug.Conn
      import HealthcareCMSWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {HealthcareCMSWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      import Phoenix.HTML
      import HealthcareCMSWeb.CoreComponents
      import HealthcareCMSWeb.Gettext

      alias Phoenix.LiveView.JS

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: HealthcareCMSWeb.Endpoint,
        router: HealthcareCMSWeb.Router,
        statics: HealthcareCMSWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end