# DSM:PLATFORM:session_management HEALTHCARE:user_context
# DSM:SECURITY:zero_trust_continuous_verification PERFORMANCE:optimized_queries
defmodule HealthcareCMSWeb.Plugs.AssignCurrentUser do
  @moduledoc """
  Plug para atribuir usuário atual ao conn

  Sprint 0-2: Session Management
  Carrega usuário da sessão e injeta no conn.assigns para:
  - Acesso em controllers/views via @current_user
  - Zero Trust context injection
  - Role-based navigation
  - Audit trail tracking
  """

  import Plug.Conn
  alias HealthcareCMS.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      # User already assigned (avoid double loading)
      conn.assigns[:current_user] ->
        conn

      # Load user from session
      user_id ->
        case Accounts.get_user!(user_id) do
          nil ->
            conn
            |> assign(:current_user, nil)
            |> configure_session(drop: true)

          user ->
            conn
            |> assign(:current_user, user)
            |> put_zero_trust_context(user)
        end

      # No session
      true ->
        assign(conn, :current_user, nil)
    end
  rescue
    Ecto.NoResultsError ->
      conn
      |> assign(:current_user, nil)
      |> configure_session(drop: true)
  end

  defp put_zero_trust_context(conn, user) do
    conn
    |> put_private(:user_id, user.id)
    |> put_private(:user_role, user.role)
    |> put_private(:user_trust_level, user.trust_level)
    |> put_private(:medical_professional, user.professional_registry != nil)
  end
end