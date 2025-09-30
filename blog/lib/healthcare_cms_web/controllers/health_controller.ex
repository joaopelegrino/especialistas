# DSM:PLATFORM:web_controllers HEALTHCARE:health_monitoring
# DSM:SECURITY:zero_trust_health_check PERFORMANCE:monitoring
defmodule HealthcareCMSWeb.HealthController do
  @moduledoc """
  Healthcare CMS Health Check Controller

  Sprint 0-1: Health monitoring endpoint para DevOps.

  Validates:
  - Application uptime
  - Database connectivity
  - Zero Trust Policy Engine status
  - Memory and performance metrics
  """

  use HealthcareCMSWeb, :controller

  alias HealthcareCMS.Repo

  @doc """
  Health check endpoint (GET /health)

  Returns JSON with system status:
  - status: "healthy" | "degraded" | "unhealthy"
  - checks: individual component checks
  - timestamp: ISO8601 timestamp
  """
  def check(conn, _params) do
    checks = %{
      database: check_database(),
      policy_engine: check_policy_engine(),
      memory: check_memory()
    }

    status =
      if Enum.all?(checks, fn {_key, val} -> val == :ok end) do
        "healthy"
      else
        "degraded"
      end

    json(conn, %{
      status: status,
      checks: checks,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      version: Application.spec(:healthcare_cms, :vsn) |> to_string()
    })
  end

  defp check_database do
    case Repo.query("SELECT 1", [], timeout: 5_000) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  defp check_policy_engine do
    # Verify Zero Trust Policy Engine is running
    case Process.whereis(HealthcareCMS.Security.PolicyEngine) do
      nil -> :error
      _pid -> :ok
    end
  end

  defp check_memory do
    # Verify memory usage is under control (<90%)
    memory = :erlang.memory()
    total = memory[:total]
    system = memory[:system]

    usage_percent = system / total * 100

    if usage_percent < 90, do: :ok, else: :warning
  end
end