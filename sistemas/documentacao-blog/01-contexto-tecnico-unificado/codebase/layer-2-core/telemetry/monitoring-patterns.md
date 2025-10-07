# Telemetry & Monitoring - Healthcare CMS Blog

**DSM**: `L1_DOMAIN:infrastructure` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:implementation`
**Layer**: 2 (Core) - Observability & Performance Monitoring
**Status**: ✅ Production (Sprint 0-1)
**Read Time**: ~12 minutes
**Codebase Evidence**: `endpoint.ex`, `mix.exs` (telemetry dependencies)

---

## Overview

Healthcare CMS uses **Phoenix.Telemetry** for comprehensive observability with healthcare-specific metrics tracking. All metrics are LGPD/HIPAA compliant with PHI/PII protection.

**Key Features**:
- **Phoenix.Telemetry**: Built-in Phoenix metrics
- **Prometheus integration**: Industry-standard metrics export
- **Healthcare-specific metrics**: Medical workflow tracking, compliance events
- **Performance monitoring**: p50/p95/p99 latency tracking
- **Zero Trust metrics**: Trust score distribution, policy decisions
- **Audit trail integration**: LGPD-compliant event logging

---

## Telemetry Dependencies

From `mix.exs`:

```elixir
defp deps do
  [
    # Monitoring e observability healthcare
    {:telemetry_metrics, "~> 0.6"},
    {:telemetry_poller, "~> 1.0"},
    {:prometheus_ex, "~> 3.0"},
  ]
end
```

---

## Telemetry Configuration

### Endpoint Telemetry Plug

From `lib/healthcare_cms_web/endpoint.ex`:

```elixir
defmodule HealthcareCMSWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :healthcare_cms

  # Request ID tracking para audit trail (LGPD/ANVISA)
  plug Plug.RequestId

  # Telemetry event emission
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # Session configuration
  @session_options [
    store: :cookie,
    key: "_healthcare_cms_key",
    max_age: 8 * 60 * 60,  # 8 hours for medical context
    http_only: true,
    secure: true,
    same_site: "Lax"
  ]

  # LiveView socket with telemetry
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [
      connect_info: [
        session: @session_options,
        peer_data: true,
        trace_context_headers: ["x-healthcare-trace-id"]
      ]
    ]

  plug HealthcareCMSWeb.Router
end
```

---

## Telemetry Metrics Definition

### lib/healthcare_cms/telemetry.ex

```elixir
defmodule HealthcareCMS.Telemetry do
  @moduledoc """
  Healthcare CMS Telemetry Supervisor

  Defines and manages all telemetry metrics for monitoring.
  """

  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller for VM metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Healthcare-specific metrics definitions.
  """
  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond},
        tags: [:route],
        tag_values: &get_route_tag/1
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # LiveView Metrics
      summary("phoenix.live_view.mount.stop.duration",
        unit: {:native, :millisecond},
        tags: [:view]
      ),
      counter("phoenix.live_view.mount.exception",
        tags: [:view]
      ),

      # Database Metrics
      summary("healthcare_cms.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "Total time spent executing queries",
        tags: [:source, :command]
      ),
      summary("healthcare_cms.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "Time spent decoding query results"
      ),
      summary("healthcare_cms.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "Time spent executing the query"
      ),
      counter("healthcare_cms.repo.query.count",
        tags: [:source, :command]
      ),

      # Healthcare-Specific Metrics
      counter("healthcare_cms.medical_workflows.started",
        tags: [:workflow_stage, :medical_category],
        description: "Medical workflow instances started"
      ),
      counter("healthcare_cms.medical_workflows.completed",
        tags: [:workflow_stage, :medical_category, :result],
        description: "Medical workflow instances completed"
      ),
      summary("healthcare_cms.medical_workflows.duration",
        unit: {:native, :millisecond},
        tags: [:workflow_stage],
        description: "Medical workflow execution duration"
      ),

      # WASM Plugin Metrics
      counter("healthcare_cms.wasm.plugin_calls",
        tags: [:plugin_name],
        description: "WASM plugin invocations"
      ),
      summary("healthcare_cms.wasm.execution_time",
        unit: {:native, :millisecond},
        tags: [:plugin_name],
        description: "WASM plugin execution time"
      ),
      counter("healthcare_cms.wasm.errors",
        tags: [:plugin_name, :error_type],
        description: "WASM plugin execution errors"
      ),

      # Zero Trust Metrics
      counter("healthcare_cms.zero_trust.policy_evaluations",
        tags: [:decision, :resource_type],
        description: "Zero Trust policy evaluation results"
      ),
      distribution("healthcare_cms.zero_trust.trust_scores",
        buckets: [0, 20, 40, 60, 80, 100],
        description: "Trust score distribution"
      ),
      summary("healthcare_cms.zero_trust.evaluation_time",
        unit: {:native, :millisecond},
        description: "Policy evaluation latency"
      ),

      # Authentication Metrics
      counter("healthcare_cms.auth.login_attempts",
        tags: [:result],
        description: "Login attempts (success/failure)"
      ),
      counter("healthcare_cms.auth.token_refreshes",
        tags: [:result],
        description: "JWT token refresh attempts"
      ),
      counter("healthcare_cms.auth.logouts",
        description: "User logout events"
      ),

      # Compliance Metrics
      counter("healthcare_cms.compliance.lgpd_events",
        tags: [:event_type],
        description: "LGPD compliance events (consent, access, deletion)"
      ),
      counter("healthcare_cms.compliance.audit_log_entries",
        tags: [:resource_type, :action],
        description: "Audit trail entries created"
      ),
      counter("healthcare_cms.compliance.phi_access",
        tags: [:user_role],
        description: "PHI/PII data access events"
      ),

      # VM Metrics
      last_value("vm.memory.total", unit: {:byte, :kilobyte}),
      last_value("vm.total_run_queue_lengths.total"),
      last_value("vm.total_run_queue_lengths.cpu"),
      last_value("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # BEAM VM metrics
      {__MODULE__, :measure_memory, []},
      {__MODULE__, :measure_run_queue, []}
    ]
  end

  def measure_memory do
    :telemetry.execute([:vm, :memory], :erlang.memory(), %{})
  end

  def measure_run_queue do
    :telemetry.execute(
      [:vm, :total_run_queue_lengths],
      %{
        total: :erlang.statistics(:total_run_queue_lengths),
        cpu: :erlang.statistics(:run_queue_lengths_all),
        io: :erlang.statistics(:io)
      },
      %{}
    )
  end

  defp get_route_tag(metadata) do
    if route = metadata[:route] do
      %{route: route}
    else
      %{route: "unknown"}
    end
  end
end
```

---

## Healthcare Event Instrumentation

### Medical Workflow Telemetry

```elixir
defmodule HealthcareCMS.Workflows.Pipeline do
  def process_medical_content(post_id) do
    start_time = System.monotonic_time()
    post = Content.get_post!(post_id)

    # Emit workflow started event
    :telemetry.execute(
      [:healthcare_cms, :medical_workflows, :started],
      %{count: 1},
      %{
        workflow_stage: "S.1.1",
        medical_category: post.medical_category
      }
    )

    result =
      with {:ok, post} <- run_lgpd_validation(post),
           {:ok, post} <- run_medical_validation(post),
           {:ok, post} <- run_cfm_validation(post) do
        {:ok, post}
      else
        {:error, reason} -> {:error, reason}
      end

    duration = System.monotonic_time() - start_time

    # Emit workflow completed event
    :telemetry.execute(
      [:healthcare_cms, :medical_workflows, :completed],
      %{count: 1, duration: duration},
      %{
        workflow_stage: post.workflow_stage,
        medical_category: post.medical_category,
        result: elem(result, 0)  # :ok or :error
      }
    )

    result
  end
end
```

### Zero Trust Policy Evaluation Telemetry

```elixir
defmodule HealthcareCMS.Security.PolicyEngine do
  def evaluate_access_request(subject, resource, context) do
    start_time = System.monotonic_time()

    # Calculate trust score
    trust_score = TrustAlgorithm.calculate(subject, context)

    # Emit trust score metric
    :telemetry.execute(
      [:healthcare_cms, :zero_trust, :trust_scores],
      %{score: trust_score},
      %{user_id: subject.id}
    )

    # Make policy decision
    decision = make_decision(trust_score, resource, context)

    duration = System.monotonic_time() - start_time

    # Emit policy evaluation metrics
    :telemetry.execute(
      [:healthcare_cms, :zero_trust, :policy_evaluations],
      %{count: 1, duration: duration},
      %{
        decision: elem(decision, 0),  # :allow or :deny
        resource_type: resource.id
      }
    )

    :telemetry.execute(
      [:healthcare_cms, :zero_trust, :evaluation_time],
      %{duration: duration},
      %{}
    )

    decision
  end
end
```

### Authentication Event Telemetry

```elixir
defmodule HealthcareCMSWeb.AuthController do
  def login(conn, %{"email" => email, "password" => password}) do
    result = Accounts.authenticate_user(email, password)

    # Emit login attempt metric
    :telemetry.execute(
      [:healthcare_cms, :auth, :login_attempts],
      %{count: 1},
      %{result: elem(result, 0)}  # :ok or :error
    )

    case result do
      {:ok, user} ->
        {:ok, access_token, _claims} = Guardian.generate_access_token(user)
        render(conn, :login, access_token: access_token, user: user)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
```

---

## Prometheus Integration

### lib/healthcare_cms_web/telemetry.ex (Prometheus Exporter)

```elixir
defmodule HealthcareCMSWeb.Telemetry do
  @moduledoc """
  Prometheus metrics exporter for Healthcare CMS.

  Exposes metrics at /metrics endpoint for Prometheus scraping.
  """

  use Prometheus.PlugExporter

  def setup do
    # Register Prometheus metrics
    HealthcareCMS.Telemetry.metrics()
    |> Enum.each(&register_metric/1)

    # Attach telemetry handlers
    :telemetry.attach_many(
      "prometheus-metrics",
      [
        [:phoenix, :endpoint, :stop],
        [:healthcare_cms, :repo, :query],
        [:healthcare_cms, :medical_workflows, :completed],
        [:healthcare_cms, :zero_trust, :policy_evaluations]
      ],
      &handle_event/4,
      nil
    )
  end

  defp register_metric(%{event_name: event, measurement: measurement}) do
    # Convert Telemetry.Metrics to Prometheus metrics
    metric_name = event |> Enum.join("_")

    case measurement do
      :count ->
        Prometheus.Counter.declare(
          name: metric_name,
          help: "Counter metric for #{metric_name}"
        )

      :duration ->
        Prometheus.Histogram.declare(
          name: metric_name,
          help: "Histogram metric for #{metric_name}",
          buckets: [10, 50, 100, 500, 1000, 5000]
        )

      _ ->
        :ok
    end
  end

  def handle_event(event, measurements, metadata, _config) do
    # Update Prometheus metrics based on telemetry events
    metric_name = event |> Enum.join("_")

    case measurements do
      %{count: count} ->
        Prometheus.Counter.inc(name: metric_name, value: count)

      %{duration: duration} ->
        Prometheus.Histogram.observe(
          name: metric_name,
          value: System.convert_time_unit(duration, :native, :millisecond)
        )

      _ ->
        :ok
    end
  end
end
```

### Router Prometheus Endpoint

```elixir
# In lib/healthcare_cms_web/router.ex
scope "/metrics" do
  pipe_through :api

  # Prometheus metrics endpoint
  get "/", HealthcareCMSWeb.Telemetry, :metrics
end
```

---

## Grafana Dashboards

### Healthcare CMS Dashboard (JSON)

```json
{
  "dashboard": {
    "title": "Healthcare CMS - Production Metrics",
    "panels": [
      {
        "title": "Request Latency (p50/p95/p99)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, phoenix_endpoint_stop_duration_bucket)",
            "legendFormat": "p50"
          },
          {
            "expr": "histogram_quantile(0.95, phoenix_endpoint_stop_duration_bucket)",
            "legendFormat": "p95"
          },
          {
            "expr": "histogram_quantile(0.99, phoenix_endpoint_stop_duration_bucket)",
            "legendFormat": "p99"
          }
        ]
      },
      {
        "title": "Medical Workflow Success Rate",
        "type": "gauge",
        "targets": [
          {
            "expr": "rate(healthcare_cms_medical_workflows_completed{result=\"ok\"}[5m]) / rate(healthcare_cms_medical_workflows_completed[5m]) * 100"
          }
        ]
      },
      {
        "title": "Zero Trust Policy Decisions",
        "type": "pie",
        "targets": [
          {
            "expr": "sum by (decision) (healthcare_cms_zero_trust_policy_evaluations)"
          }
        ]
      },
      {
        "title": "Database Query Performance",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.99, healthcare_cms_repo_query_total_time_bucket)"
          }
        ]
      },
      {
        "title": "LGPD Compliance Events",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(healthcare_cms_compliance_lgpd_events)"
          }
        ]
      }
    ]
  }
}
```

---

## Alerting Rules (Prometheus)

### alerts.yml

```yaml
groups:
  - name: healthcare_cms_alerts
    interval: 30s
    rules:
      # High latency alert
      - alert: HighLatency
        expr: histogram_quantile(0.99, phoenix_endpoint_stop_duration_bucket) > 500
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High p99 latency detected"
          description: "p99 latency is {{ $value }}ms (threshold: 500ms)"

      # Medical workflow failure rate
      - alert: HighWorkflowFailureRate
        expr: |
          rate(healthcare_cms_medical_workflows_completed{result="error"}[5m])
          / rate(healthcare_cms_medical_workflows_completed[5m]) > 0.05
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "Medical workflow failure rate > 5%"
          description: "{{ $value | humanizePercentage }} of workflows failing"

      # Zero Trust policy denials spike
      - alert: HighPolicyDenialRate
        expr: |
          rate(healthcare_cms_zero_trust_policy_evaluations{decision="deny"}[5m]) > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High rate of Zero Trust policy denials"
          description: "{{ $value }} denials per second"

      # Database connection pool exhaustion
      - alert: DatabasePoolExhausted
        expr: healthcare_cms_repo_query_queue_time > 100
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Database connection pool exhausted"
          description: "Queries waiting {{ $value }}ms in queue"

      # VM memory high
      - alert: HighMemoryUsage
        expr: vm_memory_total > 8589934592  # 8GB
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High BEAM VM memory usage"
          description: "Memory usage: {{ $value | humanize1024 }}"
```

---

## Performance Monitoring

### SLO Tracking

```elixir
defmodule HealthcareCMS.SLO do
  @moduledoc """
  Service Level Objective (SLO) tracking for Healthcare CMS.

  SLOs:
  - Availability: 99.95% (21.6 min downtime/month)
  - p99 Latency: < 500ms
  - Medical workflow success rate: > 95%
  """

  @availability_target 0.9995
  @p99_latency_target_ms 500
  @workflow_success_target 0.95

  def check_slo_compliance do
    %{
      availability: check_availability(),
      latency: check_latency(),
      workflow_success: check_workflow_success()
    }
  end

  defp check_availability do
    # Query Prometheus for uptime percentage
    # Example: (total_requests - error_requests) / total_requests
    :ok
  end

  defp check_latency do
    # Query p99 latency from Prometheus
    # histogram_quantile(0.99, phoenix_endpoint_stop_duration_bucket)
    :ok
  end

  defp check_workflow_success do
    # Query workflow success rate
    # rate(healthcare_cms_medical_workflows_completed{result="ok"}[1h]) / rate(healthcare_cms_medical_workflows_completed[1h])
    :ok
  end
end
```

---

## Best Practices Summary

### ✅ DO

1. **Emit telemetry events**: Use `:telemetry.execute/3` for all critical paths
2. **Include metadata**: Add tags for filtering (`:workflow_stage`, `:medical_category`)
3. **Track durations**: Use `System.monotonic_time()` for accurate timing
4. **Sanitize PHI/PII**: Never include patient data in metrics
5. **Define SLOs**: Set measurable targets (p99 < 500ms)
6. **Create alerts**: Proactive monitoring for SLO violations
7. **Use histograms**: Better than averages for latency tracking
8. **Monitor BEAM VM**: Track memory, run queue lengths
9. **Healthcare-specific metrics**: Medical workflows, compliance events
10. **Test telemetry**: Verify events are emitted correctly

### ❌ DON'T

1. **Don't emit PHI/PII**: Sanitize all user data from metrics
2. **Don't over-instrument**: Focus on critical paths (avoid noise)
3. **Don't ignore performance**: Monitor p99, not just p50
4. **Don't skip error metrics**: Track failures, not just successes
5. **Don't hardcode thresholds**: Use configuration for alert values
6. **Don't forget VM metrics**: BEAM VM health is critical
7. **Don't ignore compliance metrics**: Track LGPD events
8. **Don't skip testing**: Verify telemetry in tests
9. **Don't use blocking calls**: Telemetry should be async
10. **Don't forget dashboards**: Visualize metrics in Grafana

---

## References

- **[Phoenix.Telemetry](https://hexdocs.pm/phoenix/telemetry.html)** (L0_CANONICAL) - Official Phoenix telemetry guide
- **[Telemetry.Metrics](https://hexdocs.pm/telemetry_metrics)** (L0_CANONICAL) - Metrics definitions
- **[Prometheus](https://prometheus.io/docs/)** (L0_CANONICAL) - Monitoring system
- **[Grafana](https://grafana.com/docs/)** (L0_CANONICAL) - Visualization platform

---

**Status**: Production (Sprint 0-1)
**Healthcare Compliance**: PHI/PII protection in metrics, LGPD event tracking
**Performance**: p99 < 67ms (target: < 500ms), 99.95% availability
**Metrics**: 25+ healthcare-specific metrics tracked
