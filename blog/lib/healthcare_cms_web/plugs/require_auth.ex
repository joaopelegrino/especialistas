# DSM:PLATFORM:authorization HEALTHCARE:protected_routes
# DSM:SECURITY:zero_trust_policy_enforcement PERFORMANCE:fast_rejection
defmodule HealthcareCMSWeb.Plugs.RequireAuth do
  @moduledoc """
  Plug para proteger rotas que requerem autenticação

  Sprint 0-2: Authorization
  Garante que usuário está autenticado antes de acessar rota protegida.
  Redireciona para /login caso não autenticado.
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Você precisa estar logado para acessar esta página.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end