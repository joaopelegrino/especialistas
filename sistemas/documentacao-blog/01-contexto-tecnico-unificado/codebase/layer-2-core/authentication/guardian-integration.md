# Guardian JWT Authentication - Healthcare CMS Blog

**DSM**: `L1_DOMAIN:security` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:implementation`
**Layer**: 2 (Core) - Authentication & Authorization
**Status**: 🚧 Planned (Sprint 0-2+)
**Read Time**: ~15 minutes
**Codebase Evidence**: `mix.exs` (Guardian 2.3 dependency)

---

## Overview

Healthcare CMS uses **Guardian 2.3** for **stateless JWT-based authentication** with healthcare-specific claims and Zero Trust integration. Guardian provides secure token generation, validation, and session management without requiring server-side session storage.

**Key Features**:
- **JWT (JSON Web Tokens)**: Stateless authentication
- **Guardian Pipeline**: Plug-based authentication flow
- **Custom claims**: Medical professional data, tenant_id, trust_level
- **Token refresh**: Automatic token rotation for security
- **LGPD compliance**: Audit trails for authentication events

---

## Dependencies

From `mix.exs`:

```elixir
defp deps do
  [
    # Zero Trust e Security + Post-Quantum Crypto
    {:guardian, "~> 2.3"},           # JWT authentication
    {:guardian_phoenix, "~> 2.0"},   # Phoenix integration
    {:argon2_elixir, "~> 3.0"},      # Password hashing
  ]
end
```

---

## Guardian Configuration

### config/config.exs

```elixir
# Guardian JWT Authentication
config :healthcare_cms, HealthcareCMS.Guardian,
  issuer: "healthcare_cms",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY") || "dev_secret_key_change_in_production",
  ttl: {30, :minutes},  # Access token lifetime
  verify_issuer: true,
  allowed_algos: ["HS512"],  # HMAC SHA-512 for JWT signing
  serializer: HealthcareCMS.Guardian.Serializer

# Guardian Database (for refresh tokens)
config :healthcare_cms, HealthcareCMS.Guardian.DB,
  repo: HealthcareCMS.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 60  # Clean expired tokens every 60 minutes
```

### Runtime Configuration (config/runtime.exs)

```elixir
if config_env() == :prod do
  # Production Guardian secret from environment
  config :healthcare_cms, HealthcareCMS.Guardian,
    secret_key: System.fetch_env!("GUARDIAN_SECRET_KEY"),
    ttl: {15, :minutes}  # Shorter TTL in production

  # Enable token blacklisting in production
  config :healthcare_cms, HealthcareCMS.Guardian.DB,
    enabled: true,
    sweep_interval: 30
end
```

---

## Guardian Module Implementation

### lib/healthcare_cms/guardian.ex

```elixir
defmodule HealthcareCMS.Guardian do
  @moduledoc """
  Guardian implementation for Healthcare CMS.

  Provides JWT-based authentication with healthcare-specific claims:
  - tenant_id: Multi-tenant isolation
  - trust_level: Zero Trust security score
  - professional_data: Medical registry validation status
  """

  use Guardian, otp_app: :healthcare_cms

  alias HealthcareCMS.Accounts
  alias HealthcareCMS.Accounts.User

  @doc """
  Generate subject claim for JWT token.

  Subject is user ID (binary UUID).
  """
  def subject_for_token(%User{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :invalid_resource}
  end

  @doc """
  Retrieve user from subject claim.

  Called when verifying JWT token.
  """
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end

  @doc """
  Build custom claims for healthcare context.

  Includes:
  - tenant_id: For multi-tenant isolation
  - trust_level: Zero Trust security score (0-100)
  - professional_registry: CRM/CRP number (if medical professional)
  - specialty: Medical specialty (if applicable)
  """
  def build_claims(claims, %User{} = user, _opts) do
    custom_claims =
      claims
      |> Map.put("tenant_id", user.tenant_id)
      |> Map.put("trust_level", user.trust_level || 50)
      |> Map.put("email", user.email)
      |> Map.put("username", user.username)
      |> add_professional_claims(user)

    {:ok, custom_claims}
  end

  defp add_professional_claims(claims, %User{professional_data: nil}), do: claims

  defp add_professional_claims(claims, %User{professional_data: prof_data}) do
    claims
    |> Map.put("professional_registry", prof_data["registry"])
    |> Map.put("registry_verified", prof_data["validated"] || false)
    |> Map.put("specialty", prof_data["specialty"])
  end

  @doc """
  Verify custom claims during token validation.

  Ensures tenant_id and trust_level are present and valid.
  """
  def verify_claims(claims, _opts) do
    if Map.has_key?(claims, "tenant_id") && Map.has_key?(claims, "trust_level") do
      {:ok, claims}
    else
      {:error, :invalid_claims}
    end
  end

  @doc """
  Generate access token for user.

  Returns: {:ok, token, full_claims}
  """
  def generate_access_token(user) do
    encode_and_sign(user, %{}, ttl: {30, :minutes})
  end

  @doc """
  Generate refresh token for user.

  Refresh tokens have longer lifetime (7 days) and are stored in database.
  """
  def generate_refresh_token(user) do
    encode_and_sign(user, %{typ: "refresh"}, ttl: {7, :days})
  end

  @doc """
  Refresh access token using refresh token.

  Returns new access token if refresh token is valid.
  """
  def refresh_access_token(refresh_token) do
    with {:ok, claims} <- decode_and_verify(refresh_token),
         {:ok, user} <- resource_from_claims(claims),
         {:ok, _old, {new_token, _new_claims}} <- refresh(refresh_token, ttl: {30, :minutes}) do
      {:ok, new_token, user}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Revoke token (logout).

  Adds token to blacklist in database.
  """
  def revoke_token(token) do
    with {:ok, claims} <- decode_and_verify(token) do
      Guardian.revoke(token, claims)
    end
  end
end
```

---

## Guardian Pipeline (Plug Integration)

### lib/healthcare_cms_web/auth/pipeline.ex

```elixir
defmodule HealthcareCMSWeb.Auth.Pipeline do
  @moduledoc """
  Guardian pipeline for authenticating requests.

  Automatically loads user from JWT token in Authorization header.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :healthcare_cms,
    module: HealthcareCMS.Guardian,
    error_handler: HealthcareCMSWeb.Auth.ErrorHandler

  # Load token from Authorization header
  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"

  # Load token from session (for browser sessions)
  plug Guardian.Plug.VerifySession

  # Load resource (user) from token claims
  plug Guardian.Plug.LoadResource, allow_blank: true
end
```

### lib/healthcare_cms_web/auth/error_handler.ex

```elixir
defmodule HealthcareCMSWeb.Auth.ErrorHandler do
  @moduledoc """
  Handles authentication errors from Guardian pipeline.
  """

  import Plug.Conn
  import Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {:invalid_token, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      error: %{
        code: "invalid_token",
        message: "Token JWT inválido ou expirado. Faça login novamente."
      }
    })
    |> halt()
  end

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      error: %{
        code: "unauthenticated",
        message: "Autenticação necessária. Forneça um token JWT válido."
      }
    })
    |> halt()
  end

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      error: %{
        code: to_string(type),
        message: "Erro de autenticação: #{type}"
      }
    })
    |> halt()
  end
end
```

---

## Authentication Controller

### lib/healthcare_cms_web/controllers/auth_controller.ex

```elixir
defmodule HealthcareCMSWeb.AuthController do
  use HealthcareCMSWeb, :controller

  alias HealthcareCMS.Accounts
  alias HealthcareCMS.Guardian

  action_fallback HealthcareCMSWeb.FallbackController

  @doc """
  Login endpoint (POST /api/auth/login)

  Body: {"email": "user@example.com", "password": "password123"}
  Returns: {"access_token": "...", "refresh_token": "...", "user": {...}}
  """
  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user(email, password),
         {:ok, access_token, _claims} <- Guardian.generate_access_token(user),
         {:ok, refresh_token, _claims} <- Guardian.generate_refresh_token(user) do
      # Log authentication event for LGPD audit trail
      log_auth_event(user, :login, conn)

      conn
      |> put_status(:ok)
      |> render(:login, %{
        access_token: access_token,
        refresh_token: refresh_token,
        user: user
      })
    else
      {:error, :invalid_credentials} ->
        {:error, :unauthorized}

      {:error, :user_inactive} ->
        {:error, :forbidden}
    end
  end

  @doc """
  Logout endpoint (POST /api/auth/logout)

  Revokes current access token.
  """
  def logout(conn, _params) do
    token = Guardian.Plug.current_token(conn)

    with {:ok, _claims} <- Guardian.revoke_token(token) do
      user = Guardian.Plug.current_resource(conn)
      log_auth_event(user, :logout, conn)

      conn
      |> put_status(:ok)
      |> json(%{message: "Logout realizado com sucesso"})
    end
  end

  @doc """
  Refresh token endpoint (POST /api/auth/refresh)

  Body: {"refresh_token": "..."}
  Returns: {"access_token": "...", "user": {...}}
  """
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, new_access_token, user} <- Guardian.refresh_access_token(refresh_token) do
      log_auth_event(user, :token_refresh, conn)

      conn
      |> put_status(:ok)
      |> render(:refresh, %{access_token: new_access_token, user: user})
    else
      {:error, :invalid_token} ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Current user endpoint (GET /api/auth/me)

  Returns authenticated user information.
  """
  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    conn
    |> put_status(:ok)
    |> render(:user, %{user: user})
  end

  defp log_auth_event(user, event_type, conn) do
    HealthcareCMS.AuditLog.log(%{
      user_id: user.id,
      event_type: event_type,
      ip_address: conn.remote_ip |> :inet.ntoa() |> to_string(),
      user_agent: get_req_header(conn, "user-agent") |> List.first(),
      timestamp: DateTime.utc_now(),
      compliance_framework: "LGPD"
    })
  end
end
```

---

## Router Integration

### lib/healthcare_cms_web/router.ex

```elixir
defmodule HealthcareCMSWeb.Router do
  use HealthcareCMSWeb, :router

  # Public API pipeline (no authentication)
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Protected API pipeline (requires JWT authentication)
  pipeline :api_auth do
    plug :accepts, ["json"]
    plug HealthcareCMSWeb.Auth.Pipeline
    plug HealthcareCMSWeb.Plugs.EnsureAuthenticated
  end

  # Public authentication routes
  scope "/api/auth", HealthcareCMSWeb do
    pipe_through :api

    post "/login", AuthController, :login
    post "/register", AuthController, :register
    post "/refresh", AuthController, :refresh
  end

  # Protected API routes
  scope "/api", HealthcareCMSWeb do
    pipe_through :api_auth

    get "/auth/me", AuthController, :me
    post "/auth/logout", AuthController, :logout

    # Protected resources
    resources "/posts", PostController, except: [:new, :edit]
    resources "/categories", CategoryController
  end
end
```

### lib/healthcare_cms_web/plugs/ensure_authenticated.ex

```elixir
defmodule HealthcareCMSWeb.Plugs.EnsureAuthenticated do
  @moduledoc """
  Ensures user is authenticated via Guardian JWT.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias HealthcareCMS.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          error: %{
            code: "unauthenticated",
            message: "Autenticação necessária. Forneça um token JWT válido."
          }
        })
        |> halt()

      _user ->
        conn
    end
  end
end
```

---

## Zero Trust Integration

### Combining Guardian + PolicyEngine

```elixir
defmodule HealthcareCMSWeb.Plugs.ZeroTrustAuth do
  @moduledoc """
  Combines Guardian JWT authentication with Zero Trust policy evaluation.

  Flow:
  1. Guardian validates JWT token
  2. Load user from token claims
  3. PolicyEngine evaluates access request
  4. Allow/deny based on trust score + policy
  """

  import Plug.Conn
  import Phoenix.Controller

  alias HealthcareCMS.Guardian
  alias HealthcareCMS.Security.PolicyEngine

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Guardian.Plug.current_resource(conn)

    if user do
      evaluate_zero_trust_policy(conn, user)
    else
      # Not authenticated - Guardian.Plug.Pipeline already handled this
      conn
    end
  end

  defp evaluate_zero_trust_policy(conn, user) do
    subject = %{
      id: user.id,
      tenant_id: user.tenant_id,
      auth_method: get_auth_method(conn),
      professional_data: user.professional_data
    }

    resource = %{
      id: conn.request_path,
      contains_phi: requires_phi_access?(conn),
      admin_function: is_admin_function?(conn)
    }

    context = %{
      device_info: %{
        ip_address: conn.remote_ip |> :inet.ntoa() |> to_string(),
        user_agent: get_req_header(conn, "user-agent") |> List.first()
      },
      time_info: %{
        timestamp: System.system_time(:millisecond),
        business_hours: is_business_hours?()
      }
    }

    case PolicyEngine.evaluate_access_request(subject, resource, context) do
      {:allow, access_level} ->
        conn
        |> assign(:access_level, access_level)
        |> assign(:zero_trust_evaluated, true)

      {:deny, reason} ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          error: %{
            code: "zero_trust_denied",
            message: "Acesso negado por política Zero Trust",
            reason: reason
          }
        })
        |> halt()
    end
  end

  defp get_auth_method(conn) do
    # Check if MFA was used (from JWT claims)
    claims = Guardian.Plug.current_claims(conn)

    if claims["mfa_verified"] do
      :mfa_enabled
    else
      :password_only
    end
  end

  defp requires_phi_access?(conn) do
    # Check if route requires PHI access
    String.contains?(conn.request_path, ["/patients", "/medical-records"])
  end

  defp is_admin_function?(conn) do
    String.starts_with?(conn.request_path, "/api/admin")
  end

  defp is_business_hours? do
    # Brazilian business hours (9am - 6pm BRT)
    now = DateTime.now!("America/Sao_Paulo")
    hour = now.hour
    hour >= 9 && hour < 18
  end
end
```

---

## Token Storage (Refresh Tokens)

### Database Migration

```elixir
defmodule HealthcareCMS.Repo.Migrations.CreateGuardianTokens do
  use Ecto.Migration

  def change do
    create table(:guardian_tokens, primary_key: false) do
      add :jti, :string, primary_key: true
      add :typ, :string
      add :aud, :string
      add :iss, :string
      add :sub, :string
      add :exp, :bigint
      add :claims, :map

      timestamps(updated_at: false)
    end

    create index(:guardian_tokens, [:sub])
    create index(:guardian_tokens, [:jti])
  end
end
```

---

## Testing Guardian Authentication

### Example Tests

```elixir
defmodule HealthcareCMSWeb.AuthControllerTest do
  use HealthcareCMSWeb.ConnCase

  alias HealthcareCMS.Guardian

  describe "POST /api/auth/login" do
    test "returns JWT tokens for valid credentials", %{conn: conn} do
      user = insert(:user, email: "test@example.com", password: "password123")

      conn =
        post(conn, ~p"/api/auth/login", %{
          email: "test@example.com",
          password: "password123"
        })

      response = json_response(conn, 200)

      assert %{
               "access_token" => access_token,
               "refresh_token" => refresh_token,
               "user" => user_data
             } = response

      # Verify access token
      assert {:ok, claims} = Guardian.decode_and_verify(access_token)
      assert claims["sub"] == user.id
      assert claims["tenant_id"] == user.tenant_id
    end

    test "returns 401 for invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/login", %{
          email: "invalid@example.com",
          password: "wrong"
        })

      assert json_response(conn, 401)
    end
  end

  describe "GET /api/auth/me" do
    test "returns current user with valid token", %{conn: conn} do
      user = insert(:user)
      {:ok, token, _claims} = Guardian.generate_access_token(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/auth/me")

      response = json_response(conn, 200)
      assert response["user"]["id"] == user.id
    end

    test "returns 401 without token", %{conn: conn} do
      conn = get(conn, ~p"/api/auth/me")
      assert json_response(conn, 401)
    end
  end
end
```

---

## References

- **[Guardian 2.3](https://hexdocs.pm/guardian/2.3.2/readme.html)** (L0_CANONICAL) - Official Guardian documentation
- **[JWT RFC 7519](https://tools.ietf.org/html/rfc7519)** (L0_CANONICAL) - JSON Web Token standard
- **[Guardian.Plug.Pipeline](https://hexdocs.pm/guardian/Guardian.Plug.Pipeline.html)** (L0_CANONICAL) - Pipeline documentation
- **[Argon2](https://hexdocs.pm/argon2_elixir)** (L0_CANONICAL) - Password hashing library

---

**Status**: Planned (Sprint 0-2+)
**Healthcare Compliance**: LGPD audit trails, Zero Trust integration
**Security**: HMAC SHA-512, stateless JWT, refresh token rotation
**Performance**: <5ms token verification (cached), stateless authentication
