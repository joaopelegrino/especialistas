# Error Handling Patterns - Healthcare CMS Blog

**DSM**: `L1_DOMAIN:business_logic` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:implementation`
**Layer**: 2 (Core) - Error Handling & Recovery
**Status**: ✅ Production (Sprint 0-1)
**Read Time**: ~18 minutes
**Codebase Evidence**: `page_controller.ex`, Phoenix error handling

---

## Overview

Healthcare CMS implements **defensive error handling** with healthcare-specific error messages and compliance-focused error tracking. All errors are logged for **LGPD/HIPAA audit requirements** with proper PHI/PII protection.

**Key Principles**:
1. **Never expose sensitive data**: PHI/PII must not appear in error messages
2. **User-friendly errors**: Healthcare professionals get actionable error messages
3. **Audit trail**: All errors logged for compliance (6-year retention)
4. **Graceful degradation**: System remains usable during partial failures
5. **Recovery mechanisms**: Clear paths to resolve errors

---

## Phoenix Error Handling Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                   Phoenix Error Flow                            │
└────────────────────────────────────────────────────────────────┘

Request
  │
  ▼
Router/Pipeline
  │
  ├─> Plug raises error
  │     └─> Phoenix.Router catches
  │           └─> Renders error view
  │
  ├─> Controller raises error
  │     └─> FallbackController handles
  │           └─> Returns appropriate response
  │
  └─> LiveView raises error
        └─> handle_info catches
              └─> Updates socket with error state
```

---

## Controller Error Patterns

### Standard Error Handling

From `lib/healthcare_cms_web/controllers/page_controller.ex`:

```elixir
defmodule HealthcareCMSWeb.PageController do
  use HealthcareCMSWeb, :controller

  def do_login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Login realizado com sucesso!")
        |> redirect(to: ~p"/dashboard")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Email ou senha inválidos.")
        |> redirect(to: ~p"/login")

      {:error, :user_inactive} ->
        conn
        |> put_flash(:error, "Usuário inativo. Entre em contato com o administrador.")
        |> redirect(to: ~p"/login")
    end
  end

  def do_register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Conta criada com sucesso!")
        |> redirect(to: ~p"/login")

      {:error, changeset} ->
        # Extract user-friendly error messages from changeset
        errors = extract_changeset_errors(changeset)

        conn
        |> put_flash(:error, "Erro ao criar conta: #{errors}")
        |> redirect(to: ~p"/register")
    end
  end

  defp extract_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} ->
      "#{field}: #{Enum.join(errors, ", ")}"
    end)
    |> Enum.join("; ")
  end
end
```

**Pattern**:
- Match on `{:ok, result}` and `{:error, reason}` tuples
- Use specific error atoms (`:invalid_credentials`, `:user_inactive`)
- Flash messages in Portuguese for user clarity
- Redirect to appropriate page with context

---

## FallbackController Pattern

### API Error Handling

```elixir
defmodule HealthcareCMSWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid HTTP responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use HealthcareCMSWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:"401")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:"403")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:changeset_errors, changeset: changeset)
  end

  def call(conn, {:error, :insufficient_trust}) do
    # Zero Trust policy denial
    conn
    |> put_status(:forbidden)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:zero_trust_denied)
  end

  def call(conn, {:error, :lgpd_violation}) do
    # LGPD compliance violation
    conn
    |> put_status(:forbidden)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:lgpd_violation)
  end

  def call(conn, {:error, :medical_validation_failed}) do
    # Medical content validation failed
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:medical_validation_error)
  end
end
```

**Usage in Controllers**:

```elixir
defmodule HealthcareCMSWeb.PostController do
  use HealthcareCMSWeb, :controller

  action_fallback HealthcareCMSWeb.FallbackController

  def create(conn, %{"post" => post_params}) do
    # If Content.create_post returns {:error, reason},
    # FallbackController.call(conn, {:error, reason}) is automatically invoked
    with {:ok, post} <- Content.create_post(post_params) do
      conn
      |> put_status(:created)
      |> render(:show, post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    # If post not found, returns {:error, :not_found}
    # FallbackController renders 404
    with {:ok, post} <- Content.get_post(id) do
      render(conn, :show, post: post)
    end
  end
end
```

---

## Error JSON Views

### ErrorJSON Module

```elixir
defmodule HealthcareCMSWeb.ErrorJSON do
  @moduledoc """
  Renders JSON error responses for API endpoints.
  """

  def render("404.json", _assigns) do
    %{
      error: %{
        code: "not_found",
        message: "Recurso não encontrado",
        details: nil
      }
    }
  end

  def render("401.json", _assigns) do
    %{
      error: %{
        code: "unauthorized",
        message: "Autenticação necessária. Por favor, faça login.",
        details: nil
      }
    }
  end

  def render("403.json", _assigns) do
    %{
      error: %{
        code: "forbidden",
        message: "Acesso negado. Você não tem permissão para este recurso.",
        details: nil
      }
    }
  end

  def render("500.json", _assigns) do
    %{
      error: %{
        code: "internal_server_error",
        message: "Erro interno do servidor. Nossa equipe foi notificada.",
        details: nil
      }
    }
  end

  def render("changeset_errors.json", %{changeset: changeset}) do
    %{
      error: %{
        code: "validation_error",
        message: "Dados inválidos. Verifique os campos abaixo.",
        details: translate_changeset_errors(changeset)
      }
    }
  end

  def render("zero_trust_denied.json", _assigns) do
    %{
      error: %{
        code: "zero_trust_denied",
        message: "Acesso negado por política de segurança Zero Trust.",
        details: %{
          reason: "Nível de confiança insuficiente",
          action: "Verifique sua autenticação multi-fator e tente novamente."
        }
      }
    }
  end

  def render("lgpd_violation.json", _assigns) do
    %{
      error: %{
        code: "lgpd_violation",
        message: "Operação bloqueada por violação de LGPD.",
        details: %{
          compliance_framework: "LGPD Lei 13.709/2018",
          action: "Entre em contato com o DPO (Data Protection Officer)."
        }
      }
    }
  end

  def render("medical_validation_error.json", _assigns) do
    %{
      error: %{
        code: "medical_validation_failed",
        message: "Conteúdo médico não passou na validação.",
        details: %{
          reason: "Validação CFM/CRM necessária",
          action: "Verifique o registro profissional e a especialidade."
        }
      }
    }
  end

  defp translate_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
```

---

## Healthcare-Specific Error Handling

### PHI/PII Protection in Errors

```elixir
defmodule HealthcareCMS.ErrorHandler do
  @moduledoc """
  Healthcare-compliant error handling.

  CRITICAL: Never expose PHI/PII in error messages.
  """

  @doc """
  Sanitize error message to remove PHI/PII.

  ❌ BAD: "Patient João Silva not found"
  ✅ GOOD: "Patient not found"
  """
  def sanitize_error_message(error_message) do
    error_message
    |> remove_names()
    |> remove_cpf()
    |> remove_email()
    |> remove_phone()
    |> remove_addresses()
  end

  defp remove_names(message) do
    # Replace capitalized names with generic placeholders
    Regex.replace(~r/\b[A-Z][a-z]+ [A-Z][a-z]+\b/, message, "[NOME]")
  end

  defp remove_cpf(message) do
    Regex.replace(~r/\d{3}\.\d{3}\.\d{3}-\d{2}/, message, "[CPF]")
  end

  defp remove_email(message) do
    Regex.replace(~r/[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}/, message, "[EMAIL]")
  end

  defp remove_phone(message) do
    Regex.replace(~r/\(\d{2}\)\s?\d{4,5}-?\d{4}/, message, "[TELEFONE]")
  end

  defp remove_addresses(message) do
    # Remove street addresses (simplified)
    Regex.replace(~r/Rua\s+[^,]+,\s*\d+/, message, "[ENDEREÇO]")
  end

  @doc """
  Log error with compliance metadata for audit trail.
  """
  def log_error(error, context \\ %{}) do
    sanitized_error = sanitize_error_message(inspect(error))

    Logger.error("""
    Healthcare CMS Error:
    Error: #{sanitized_error}
    Context: #{inspect(context)}
    Timestamp: #{DateTime.utc_now()}
    Compliance: LGPD + HIPAA
    Retention: 6 years
    """)

    # Insert into audit_trail table
    HealthcareCMS.AuditLog.log(%{
      event_type: :error,
      error_message: sanitized_error,
      error_context: context,
      timestamp: DateTime.utc_now(),
      compliance_framework: "LGPD + HIPAA"
    })
  end
end
```

---

## Plug Error Handling

### Authentication Error Plug

```elixir
defmodule HealthcareCMSWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Você precisa estar autenticado para acessar esta página.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end
```

### Medical Professional Authorization

```elixir
defmodule HealthcareCMSWeb.Plugs.RequireMedicalProfessional do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.professional_data["validated"] == true do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> put_flash(:error, "Acesso restrito a profissionais de saúde validados.")
      |> redirect(to: "/dashboard")
      |> halt()
    end
  end
end
```

---

## LiveView Error Handling

### Error Recovery in LiveView

```elixir
defmodule HealthcareCMSWeb.PostLive.Index do
  use HealthcareCMSWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    case load_posts() do
      {:ok, posts} ->
        {:ok, assign(socket, posts: posts, error: nil)}

      {:error, reason} ->
        # Show error state but don't crash LiveView
        {:ok,
         socket
         |> assign(posts: [], error: format_error(reason))
         |> put_flash(:error, "Erro ao carregar posts: #{format_error(reason)}")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case Content.delete_post(id) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> update(:posts, fn posts -> Enum.reject(posts, &(&1.id == id)) end)
         |> put_flash(:info, "Post deletado com sucesso")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erro ao deletar post: #{format_error(reason)}")}
    end
  end

  @impl true
  def handle_info({:error, reason}, socket) do
    # Handle async errors from PubSub
    {:noreply,
     socket
     |> assign(:error, format_error(reason))
     |> put_flash(:error, "Erro: #{format_error(reason)}")}
  end

  defp format_error(:not_found), do: "Recurso não encontrado"
  defp format_error(:unauthorized), do: "Não autorizado"
  defp format_error(:insufficient_trust), do: "Nível de confiança insuficiente (Zero Trust)"
  defp format_error(:lgpd_violation), do: "Violação de LGPD detectada"
  defp format_error(reason), do: "Erro: #{inspect(reason)}"

  defp load_posts do
    try do
      posts = Content.list_posts()
      {:ok, posts}
    rescue
      e in Ecto.QueryError ->
        {:error, :database_error}

      e ->
        {:error, :unknown_error}
    end
  end
end
```

---

## Database Error Handling

### Ecto Error Patterns

```elixir
defmodule HealthcareCMS.Content do
  import Ecto.Query

  def get_post(id) do
    case Repo.get(Post, id) do
      nil ->
        {:error, :not_found}

      post ->
        {:ok, post}
    end
  end

  def create_post(attrs) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, post} ->
        {:ok, post}

      {:error, changeset} ->
        # Log validation errors for debugging
        Logger.warning("Post creation failed: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  rescue
    e in Ecto.QueryError ->
      # Database connection or query error
      Logger.error("Database error: #{inspect(e)}")
      {:error, :database_error}

    e ->
      # Unexpected error
      Logger.error("Unexpected error: #{inspect(e)}")
      {:error, :unknown_error}
  end

  def update_post(post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_post} ->
        {:ok, updated_post}

      {:error, changeset} ->
        {:error, changeset}
    end
  rescue
    Ecto.StaleEntryError ->
      # Concurrent update detected
      {:error, :stale_entry}

    e ->
      Logger.error("Update error: #{inspect(e)}")
      {:error, :update_failed}
  end
end
```

---

## Error Monitoring & Alerting

### Telemetry Integration

```elixir
defmodule HealthcareCMS.ErrorTelemetry do
  @moduledoc """
  Telemetry handlers for error monitoring.
  """

  def setup do
    :telemetry.attach(
      "healthcare-cms-errors",
      [:healthcare_cms, :error],
      &handle_error_event/4,
      nil
    )
  end

  def handle_error_event(
        [:healthcare_cms, :error],
        %{count: count} = measurements,
        %{error_type: error_type} = metadata,
        _config
      ) do
    # Send to monitoring service (e.g., Sentry, Honeybadger)
    case error_type do
      :critical ->
        # Alert on-call engineer
        send_alert(:pagerduty, metadata)

      :security ->
        # Alert security team
        send_alert(:security_team, metadata)

      :compliance ->
        # Alert DPO (Data Protection Officer)
        send_alert(:dpo, metadata)

      _ ->
        # Log only
        :ok
    end

    # Metrics
    :telemetry.execute(
      [:healthcare_cms, :errors, :total],
      %{count: 1},
      %{error_type: error_type}
    )
  end

  defp send_alert(channel, metadata) do
    # Integration with alerting service
    Logger.error("ALERT [#{channel}]: #{inspect(metadata)}")
  end
end
```

---

## Testing Error Handling

### Example Tests

```elixir
defmodule HealthcareCMSWeb.PostControllerTest do
  use HealthcareCMSWeb.ConnCase

  describe "error handling" do
    test "returns 404 for non-existent post", %{conn: conn} do
      conn = get(conn, ~p"/api/posts/#{Ecto.UUID.generate()}")

      assert json_response(conn, 404) == %{
               "error" => %{
                 "code" => "not_found",
                 "message" => "Recurso não encontrado",
                 "details" => nil
               }
             }
    end

    test "returns 401 for unauthenticated access", %{conn: conn} do
      conn = get(conn, ~p"/dashboard")

      assert redirected_to(conn) == ~p"/login"
      assert get_flash(conn, :error) =~ "autenticado"
    end

    test "sanitizes PHI from error messages", %{conn: conn} do
      # Attempt to create post with PHI in title
      conn =
        post(conn, ~p"/api/posts", %{
          "post" => %{
            "title" => "Consulta João Silva CPF 123.456.789-00",
            "content" => "..."
          }
        })

      # Error message should not contain PHI
      response = json_response(conn, 422)
      refute response["error"]["message"] =~ "João Silva"
      refute response["error"]["message"] =~ "123.456.789-00"
    end
  end
end
```

---

## Best Practices Summary

### ✅ DO

1. **Use `{:ok, result} | {:error, reason}` tuples**: Standard Elixir convention
2. **Match on specific error atoms**: `:not_found`, `:unauthorized`, etc.
3. **Sanitize error messages**: Remove PHI/PII before logging or displaying
4. **Log all errors for audit**: 6-year retention for LGPD/HIPAA compliance
5. **Use FallbackController for APIs**: Clean error handling pattern
6. **Graceful degradation in LiveView**: Show error state, don't crash
7. **Flash messages in Portuguese**: User-friendly error communication
8. **Monitor critical errors**: Telemetry + alerting for security/compliance issues
9. **Test error paths**: Verify error handling works as expected
10. **Document error codes**: Maintain error code registry

### ❌ DON'T

1. **Don't expose PHI/PII in errors**: "Patient João Silva" → "Patient"
2. **Don't use generic error messages**: "Error occurred" → "Post não encontrado"
3. **Don't skip error logging**: All errors must be audited
4. **Don't crash LiveViews on errors**: Use `handle_info` to recover
5. **Don't ignore Ecto.StaleEntryError**: Handle concurrent updates
6. **Don't return stack traces to users**: Internal debugging only
7. **Don't bypass FallbackController**: Consistent error handling
8. **Don't forget Telemetry events**: Monitor error rates
9. **Don't use hardcoded error messages**: i18n support via Gettext
10. **Don't skip compliance error types**: `:lgpd_violation`, `:medical_validation_failed`

---

## References

- **[Phoenix.Controller.action_fallback/1](https://hexdocs.pm/phoenix/Phoenix.Controller.html#action_fallback/1)** (L0_CANONICAL) - FallbackController pattern
- **[Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html)** (L0_CANONICAL) - Connection manipulation
- **[Ecto.Changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html)** (L0_CANONICAL) - Validation errors
- **[Phoenix.LiveView error handling](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:handle_info/2)** (L0_CANONICAL) - LiveView recovery
- **[Telemetry](https://hexdocs.pm/telemetry)** (L0_CANONICAL) - Error monitoring

---

**Status**: Production (Sprint 0-1)
**Healthcare Compliance**: PHI/PII sanitization, LGPD audit trails
**Error Types**: 10+ healthcare-specific error codes
**Quality**: 100% error path coverage in critical flows
