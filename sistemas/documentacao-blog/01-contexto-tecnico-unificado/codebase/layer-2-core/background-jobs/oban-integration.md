# Background Jobs - Oban Integration

**DSM**: `L1_DOMAIN:infrastructure` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:implementation`
**Layer**: 2 (Core) - Background Job Processing
**Status**: ✅ Production (Sprint 0-1)
**Read Time**: ~10 minutes
**Codebase Evidence**: `mix.exs`, `config/config.exs`, `lib/healthcare_cms/application.ex`

---

## Overview

Healthcare CMS uses **Oban** (v2.18+) for reliable background job processing with PostgreSQL-backed queues. All medical workflow validations, compliance audits, and scheduled tasks run asynchronously with retry logic and dead-letter queues.

**Key Features**:
- **Reliable Processing**: PostgreSQL-backed, transactional job enqueueing
- **Multiple Queues**: Priority-based job execution (medical_workflow, lgpd_analysis, compliance_check, default)
- **Cron Jobs**: Scheduled compliance audits, health checks, data retention
- **Error Handling**: Automatic retries with exponential backoff, dead-letter queue
- **Healthcare Compliance**: Audit logging, PHI protection, LGPD retention policies

---

## Oban Installation & Configuration

### 1. Dependencies

**mix.exs**:
```elixir
defp deps do
  [
    {:oban, "~> 2.18"},
    {:jason, "~> 1.4"}  # Required for Oban job serialization
  ]
end
```

### 2. Database Migration

**Generate migration**:
```bash
mix ecto.gen.migration add_oban_jobs_table
```

**Migration file** (`priv/repo/migrations/XXX_add_oban_jobs_table.exs`):
```elixir
defmodule HealthcareCMS.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 12)  # Latest Oban schema version
  end

  def down do
    Oban.Migration.down(version: 1)
  end
end
```

**Run migration**:
```bash
mix ecto.migrate
```

### 3. Application Configuration

**config/config.exs**:
```elixir
config :healthcare_cms, Oban,
  repo: HealthcareCMS.Repo,
  plugins: [
    # Job pruning (delete completed jobs after 7 days)
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},

    # Cron jobs (scheduled tasks)
    {Oban.Plugins.Cron,
     crontab: [
       # Daily compliance audit (3 AM UTC)
       {"0 3 * * *", HealthcareCMS.Workers.ComplianceAuditWorker},

       # Hourly LGPD retention check
       {"0 * * * *", HealthcareCMS.Workers.LGPDRetentionWorker},

       # Every 5 minutes: health check
       {"*/5 * * * *", HealthcareCMS.Workers.HealthCheckWorker},

       # Weekly report generation (Sunday 2 AM)
       {"0 2 * * 0", HealthcareCMS.Workers.WeeklyReportWorker}
     ]},

    # Stager (job scheduling optimization)
    {Oban.Plugins.Stager, interval: 1000},

    # Lifeline (rescue orphaned jobs)
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(30)}
  ],
  queues: [
    medical_workflow: 10,  # 10 concurrent workers (high priority)
    lgpd_analysis: 5,      # 5 concurrent workers (compliance)
    compliance_check: 3,   # 3 concurrent workers (CFM/ANVISA)
    email: 5,              # 5 concurrent workers (notifications)
    default: 10            # 10 concurrent workers (general tasks)
  ]

# Test environment: disable background jobs
if config_env() == :test do
  config :healthcare_cms, Oban,
    testing: :manual
end
```

### 4. Supervisor Tree

**lib/healthcare_cms/application.ex**:
```elixir
defmodule HealthcareCMS.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Database
      HealthcareCMS.Repo,

      # PubSub
      {Phoenix.PubSub, name: HealthcareCMS.PubSub},

      # Oban (background jobs)
      {Oban, Application.fetch_env!(:healthcare_cms, Oban)},

      # Endpoint
      HealthcareCMSWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: HealthcareCMS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

---

## Job Workers

### 1. Medical Workflow Worker

**lib/healthcare_cms/workers/medical_workflow_worker.ex**:
```elixir
defmodule HealthcareCMS.Workers.MedicalWorkflowWorker do
  @moduledoc """
  Process medical content through validation pipeline:
  S.1.1 → S.2.1 (LGPD) → S.3.1 (Claims) → S.4-1.1-3 (CFM).
  """

  use Oban.Worker,
    queue: :medical_workflow,
    max_attempts: 3,
    priority: 0  # Highest priority (0-3, lower = higher priority)

  alias HealthcareCMS.MedicalWorkflows

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"post_id" => post_id, "stage" => stage}}) do
    post = HealthcareCMS.Content.get_post!(post_id)

    case stage do
      "s21_lgpd_analysis" ->
        MedicalWorkflows.run_lgpd_analysis(post)

      "s31_claims_extraction" ->
        MedicalWorkflows.run_claims_extraction(post)

      "s41_cfm_validation" ->
        MedicalWorkflows.run_cfm_validation(post)

      _ ->
        {:error, :invalid_stage}
    end
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.minutes(5)  # 5 minutes timeout (WASM processing)
end
```

**Enqueue job**:
```elixir
# After post creation (S.1.1 Content Creation)
defmodule HealthcareCMS.Content do
  def create_post(attrs) do
    with {:ok, post} <- Repo.insert(changeset) do
      # Enqueue LGPD analysis (S.2.1)
      %{post_id: post.id, stage: "s21_lgpd_analysis"}
      |> HealthcareCMS.Workers.MedicalWorkflowWorker.new()
      |> Oban.insert()

      {:ok, post}
    end
  end
end
```

### 2. LGPD Retention Worker

**lib/healthcare_cms/workers/lgpd_retention_worker.ex**:
```elixir
defmodule HealthcareCMS.Workers.LGPDRetentionWorker do
  @moduledoc """
  Enforce LGPD data retention policies:
  - User data: 5 years from last activity (LGPD Art. 16)
  - Medical records: 20 years (CFM Resolução 1.821/2007)
  - Audit logs: 6 years (HIPAA 164.316(b)(2)(i))
  """

  use Oban.Worker,
    queue: :compliance_check,
    max_attempts: 5

  import Ecto.Query

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    # Soft-delete inactive users (5 years LGPD retention)
    lgpd_retention_date = DateTime.add(DateTime.utc_now(), -5 * 365, :day)

    from(u in HealthcareCMS.Accounts.User,
      where: u.last_login_at < ^lgpd_retention_date,
      where: is_nil(u.deleted_at)
    )
    |> Repo.update_all(set: [deleted_at: DateTime.utc_now()])

    # Archive old medical records (20 years CFM retention)
    cfm_retention_date = DateTime.add(DateTime.utc_now(), -20 * 365, :day)

    from(p in HealthcareCMS.Content.Post,
      where: p.inserted_at < ^cfm_retention_date,
      where: p.medical_category != "none",
      where: is_nil(p.archived_at)
    )
    |> Repo.update_all(set: [archived_at: DateTime.utc_now()])

    # Purge old audit logs (6 years HIPAA retention)
    hipaa_retention_date = DateTime.add(DateTime.utc_now(), -6 * 365, :day)

    from(a in HealthcareCMS.Audit.AuditLog,
      where: a.inserted_at < ^hipaa_retention_date
    )
    |> Repo.delete_all()

    :ok
  end
end
```

### 3. Compliance Audit Worker

**lib/healthcare_cms/workers/compliance_audit_worker.ex**:
```elixir
defmodule HealthcareCMS.Workers.ComplianceAuditWorker do
  @moduledoc """
  Daily compliance audit:
  - Verify all PHI access is logged
  - Check CFM validation status
  - Validate LGPD consent records
  """

  use Oban.Worker,
    queue: :compliance_check,
    max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    # Check for unlogged PHI access (security breach indicator)
    posts_with_phi = HealthcareCMS.Content.list_posts_with_phi()
    unlogged_access = check_audit_logs(posts_with_phi)

    if length(unlogged_access) > 0 do
      # CRITICAL: Potential LGPD violation
      HealthcareCMS.Alerts.send_security_alert(
        :unlogged_phi_access,
        unlogged_access
      )
    end

    # Check CFM validation status
    invalidated_posts = HealthcareCMS.Content.list_invalidated_medical_posts()

    if length(invalidated_posts) > 0 do
      # WARNING: Medical content requires re-validation
      HealthcareCMS.Alerts.send_compliance_alert(
        :cfm_validation_required,
        invalidated_posts
      )
    end

    # Verify LGPD consent records
    users_without_consent = HealthcareCMS.Accounts.list_users_without_consent()

    if length(users_without_consent) > 0 do
      # CRITICAL: LGPD violation (missing consent)
      HealthcareCMS.Alerts.send_legal_alert(
        :missing_lgpd_consent,
        users_without_consent
      )
    end

    :ok
  end

  defp check_audit_logs(posts_with_phi) do
    # Implementation: Check if all PHI access has corresponding audit log
    # Return list of unlogged access events
  end
end
```

### 4. Email Notification Worker

**lib/healthcare_cms/workers/email_worker.ex**:
```elixir
defmodule HealthcareCMS.Workers.EmailWorker do
  @moduledoc """
  Send transactional emails (compliance notifications, alerts).
  """

  use Oban.Worker,
    queue: :email,
    max_attempts: 5

  alias HealthcareCMS.Mailer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email_type" => type, "recipient" => recipient, "data" => data}}) do
    email =
      case type do
        "compliance_alert" ->
          HealthcareCMS.Emails.ComplianceEmail.build(recipient, data)

        "security_alert" ->
          HealthcareCMS.Emails.SecurityEmail.build(recipient, data)

        "password_reset" ->
          HealthcareCMS.Emails.AuthEmail.password_reset(recipient, data)

        _ ->
          {:error, :invalid_email_type}
      end

    case email do
      {:error, reason} -> {:error, reason}
      email -> Mailer.deliver(email)
    end
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)  # 30 seconds timeout (SMTP)
end
```

**Enqueue email**:
```elixir
%{
  email_type: "compliance_alert",
  recipient: "dpo@example.com",
  data: %{
    alert_type: "unlogged_phi_access",
    post_ids: [1, 2, 3]
  }
}
|> HealthcareCMS.Workers.EmailWorker.new()
|> Oban.insert()
```

### 5. Health Check Worker

**lib/healthcare_cms/workers/health_check_worker.ex**:
```elixir
defmodule HealthcareCMS.Workers.HealthCheckWorker do
  @moduledoc """
  Periodic health check (every 5 minutes):
  - Database connectivity
  - External API availability (ANVISA, CFM, PubMed)
  - WASM plugin health
  """

  use Oban.Worker,
    queue: :default,
    max_attempts: 1  # Don't retry health checks

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    # Database health
    case Ecto.Adapters.SQL.query(HealthcareCMS.Repo, "SELECT 1", []) do
      {:ok, _} -> :ok
      {:error, reason} ->
        HealthcareCMS.Alerts.send_infrastructure_alert(:database_down, reason)
    end

    # ANVISA API health
    case HTTPoison.get("https://consultas.anvisa.gov.br/api/health", [], timeout: 5000) do
      {:ok, %{status_code: 200}} -> :ok
      _ ->
        HealthcareCMS.Alerts.send_integration_alert(:anvisa_api_down)
    end

    # WASM plugin health (test S.2.1 LGPD analyzer)
    case HealthcareCMS.MedicalWorkflows.test_wasm_plugin(:lgpd_analyzer) do
      {:ok, _} -> :ok
      {:error, reason} ->
        HealthcareCMS.Alerts.send_infrastructure_alert(:wasm_plugin_error, reason)
    end

    :ok
  end
end
```

---

## Error Handling & Retries

### 1. Retry Strategy

**Exponential Backoff** (default Oban behavior):
```elixir
use Oban.Worker,
  max_attempts: 5

# Retry schedule:
# Attempt 1: immediate
# Attempt 2: 15 seconds later
# Attempt 3: 2 minutes later
# Attempt 4: 10 minutes later
# Attempt 5: 1 hour later
```

**Custom Backoff**:
```elixir
use Oban.Worker,
  max_attempts: 3

@impl Oban.Worker
def backoff(%Oban.Job{attempt: attempt}) do
  # Custom: 1 min, 5 min, 15 min
  case attempt do
    1 -> 60
    2 -> 300
    3 -> 900
  end
end
```

### 2. Error Handling

**Recoverable vs Non-Recoverable Errors**:
```elixir
@impl Oban.Worker
def perform(%Oban.Job{args: %{"post_id" => post_id}}) do
  case HealthcareCMS.MedicalWorkflows.run_cfm_validation(post_id) do
    {:ok, result} ->
      :ok

    {:error, :network_timeout} ->
      # Recoverable: retry
      {:error, :network_timeout}

    {:error, :invalid_medical_content} ->
      # Non-recoverable: don't retry, mark as failed
      {:discard, :invalid_medical_content}

    {:error, reason} ->
      # Unknown error: retry
      {:error, reason}
  end
end
```

**Snooze (Delay Retry)**:
```elixir
@impl Oban.Worker
def perform(%Oban.Job{args: args}) do
  case external_api_call() do
    {:error, :rate_limit_exceeded} ->
      # Snooze for 60 seconds (don't count as retry attempt)
      {:snooze, 60}

    {:ok, result} ->
      :ok
  end
end
```

### 3. Dead Letter Queue

**Capture Failed Jobs**:
```elixir
defmodule HealthcareCMS.Oban.ErrorReporter do
  @moduledoc """
  Handle jobs that exceeded max_attempts.
  """

  def handle_event([:oban, :job, :exception], measure, meta, _) do
    if meta.job.attempt >= meta.job.max_attempts do
      # Job failed permanently, log to dead letter queue
      HealthcareCMS.DeadLetterQueue.insert(%{
        worker: meta.job.worker,
        args: meta.job.args,
        error: meta.error,
        stacktrace: meta.stacktrace,
        inserted_at: DateTime.utc_now()
      })

      # Alert operations team
      HealthcareCMS.Alerts.send_ops_alert(:job_permanently_failed, meta)
    end
  end
end

# Attach telemetry handler
:telemetry.attach(
  "oban-error-reporter",
  [:oban, :job, :exception],
  &HealthcareCMS.Oban.ErrorReporter.handle_event/4,
  nil
)
```

---

## Scheduled Jobs (Cron)

### 1. Cron Configuration

**config/config.exs**:
```elixir
config :healthcare_cms, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # Format: "minute hour day month weekday"

       # Every day at 3 AM UTC
       {"0 3 * * *", HealthcareCMS.Workers.ComplianceAuditWorker},

       # Every hour (LGPD retention check)
       {"0 * * * *", HealthcareCMS.Workers.LGPDRetentionWorker},

       # Every 5 minutes (health check)
       {"*/5 * * * *", HealthcareCMS.Workers.HealthCheckWorker},

       # Every Sunday at 2 AM (weekly report)
       {"0 2 * * 0", HealthcareCMS.Workers.WeeklyReportWorker},

       # First day of month at 1 AM (monthly audit)
       {"0 1 1 * *", HealthcareCMS.Workers.MonthlyAuditWorker}
     ]}
  ]
```

### 2. Timezone Handling

**UTC Only** (recommended for healthcare compliance):
```elixir
# All cron jobs run in UTC
{"0 3 * * *", Worker}  # 3 AM UTC

# Convert to local time in worker if needed
@impl Oban.Worker
def perform(%Oban.Job{}) do
  brasilia_time = DateTime.shift_zone!(DateTime.utc_now(), "America/Sao_Paulo")
  # Use brasilia_time for reporting
end
```

---

## Queue Management

### 1. Queue Priorities

**Queue Configuration**:
```elixir
config :healthcare_cms, Oban,
  queues: [
    medical_workflow: [limit: 10, paused: false],  # High priority
    lgpd_analysis: [limit: 5, paused: false],
    compliance_check: [limit: 3, paused: false],
    email: [limit: 5, paused: false],
    default: [limit: 10, paused: false]
  ]
```

**Job Priority** (within queue):
```elixir
# Lower priority value = higher priority (0 is highest)
%{post_id: 123}
|> MedicalWorkflowWorker.new(priority: 0)  # Process first
|> Oban.insert()

%{post_id: 456}
|> MedicalWorkflowWorker.new(priority: 3)  # Process last
|> Oban.insert()
```

### 2. Pause/Resume Queues

**Runtime Control**:
```elixir
# Pause queue (during maintenance)
Oban.pause_queue(queue: :medical_workflow)

# Resume queue
Oban.resume_queue(queue: :medical_workflow)

# Scale queue (change concurrency)
Oban.scale_queue(queue: :medical_workflow, limit: 20)
```

### 3. Unique Jobs

**Prevent Duplicate Jobs**:
```elixir
use Oban.Worker,
  unique: [
    period: 60,  # 60 seconds uniqueness window
    fields: [:args],  # Uniqueness key (args must match exactly)
    states: [:available, :scheduled, :executing]  # Check these states
  ]

# Only one job with same post_id will be enqueued within 60 seconds
%{post_id: 123}
|> MedicalWorkflowWorker.new()
|> Oban.insert()
```

**Replace Existing Jobs**:
```elixir
use Oban.Worker,
  unique: [
    period: 300,
    keys: [:post_id],  # Only check post_id field
    states: [:scheduled],
    replace: [scheduled: [:scheduled_at, :args]]  # Replace with new job
  ]
```

---

## Monitoring & Observability

### 1. Telemetry Events

**Available Events**:
```elixir
# Job lifecycle
[:oban, :job, :start]       # Job execution started
[:oban, :job, :stop]        # Job completed successfully
[:oban, :job, :exception]   # Job raised exception

# Queue events
[:oban, :queue, :start]     # Queue processing started
[:oban, :queue, :stop]      # Queue processing stopped

# Plugin events
[:oban, :plugin, :start]
[:oban, :plugin, :stop]
```

**Telemetry Handler**:
```elixir
defmodule HealthcareCMSWeb.Telemetry do
  def metrics do
    [
      # Job execution duration
      summary("oban.job.stop.duration",
        unit: {:native, :millisecond},
        tags: [:worker, :queue]
      ),

      # Job exceptions
      counter("oban.job.exception.count",
        tags: [:worker, :queue]
      ),

      # Queue depth (jobs waiting)
      last_value("oban.queue.depth",
        tags: [:queue]
      )
    ]
  end
end
```

### 2. Oban Web UI

**Installation** (development only):
```elixir
# mix.exs
defp deps do
  [
    {:oban_web, "~> 2.10", only: :dev}
  ]
end

# router.ex (dev environment)
if Application.compile_env(:healthcare_cms, :dev_routes) do
  scope "/dev" do
    pipe_through :browser

    forward "/oban", Oban.Web.Router
  end
end
```

**Access**: http://localhost:4000/dev/oban

### 3. Prometheus Metrics

**Custom Exporter**:
```elixir
defmodule HealthcareCMS.Oban.PrometheusExporter do
  use Prometheus.Metric

  def setup do
    Gauge.declare(
      name: :oban_queue_depth,
      help: "Number of jobs in queue",
      labels: [:queue]
    )

    Counter.declare(
      name: :oban_jobs_processed_total,
      help: "Total jobs processed",
      labels: [:worker, :queue, :status]
    )
  end

  def export_queue_depth do
    Oban.check_queue(queue: :medical_workflow)
    |> case do
      %{limit: limit, running: running} ->
        Gauge.set([name: :oban_queue_depth, labels: [:medical_workflow]], limit - running)
    end
  end
end
```

---

## Testing

### 1. Test Configuration

**config/test.exs**:
```elixir
config :healthcare_cms, Oban,
  testing: :manual  # Don't auto-process jobs in tests
```

### 2. Job Testing

**Test Worker Logic**:
```elixir
defmodule HealthcareCMS.Workers.MedicalWorkflowWorkerTest do
  use HealthcareCMS.DataCase, async: true
  use Oban.Testing, repo: HealthcareCMS.Repo

  alias HealthcareCMS.Workers.MedicalWorkflowWorker

  test "processes LGPD analysis stage" do
    post = insert(:post, content: "Patient John Doe has diabetes")

    # Enqueue job
    assert {:ok, job} =
      %{post_id: post.id, stage: "s21_lgpd_analysis"}
      |> MedicalWorkflowWorker.new()
      |> Oban.insert()

    # Manually execute job
    assert :ok = perform_job(MedicalWorkflowWorker, job.args)

    # Assert side effects
    post = Repo.reload!(post)
    assert post.phi_detected == true
    assert post.lgpd_risk_score == 85
  end
end
```

**Test Job Enqueueing**:
```elixir
test "creates job on post creation" do
  assert {:ok, post} = Content.create_post(%{title: "Test", content: "..."})

  # Assert job was enqueued
  assert_enqueued worker: MedicalWorkflowWorker,
    args: %{post_id: post.id, stage: "s21_lgpd_analysis"}
end
```

---

## Best Practices

### ✅ DO

1. **Use idempotent workers**: Jobs may be retried, ensure they can run multiple times safely
2. **Keep jobs small**: Break large tasks into multiple smaller jobs
3. **Use unique constraints**: Prevent duplicate jobs with `unique: true`
4. **Log job context**: Include `post_id`, `user_id` in job args for debugging
5. **Set appropriate timeouts**: Medical workflows may take 1-5 minutes
6. **Use priority levels**: Critical jobs (PHI access) should have `priority: 0`
7. **Monitor queue depth**: Alert if queue depth > 1000 jobs
8. **Test job logic**: Use `Oban.Testing` helpers in tests
9. **Use cron for scheduled tasks**: Don't implement custom scheduling
10. **Handle errors gracefully**: Return `{:discard, reason}` for non-recoverable errors

### ❌ DON'T

1. **Don't block workers**: Avoid long-running synchronous operations (use Task.async)
2. **Don't store large data in args**: Use IDs and fetch from database
3. **Don't rely on job ordering**: Jobs may execute out of order
4. **Don't ignore failed jobs**: Monitor dead letter queue
5. **Don't use default queue for everything**: Separate by priority/type
6. **Don't skip error handling**: Always pattern match on `{:ok, result}` and `{:error, reason}`
7. **Don't hardcode queue limits**: Use environment variables
8. **Don't forget PHI sanitization**: Sanitize job args before logging
9. **Don't disable retries for critical jobs**: Healthcare compliance requires reliability
10. **Don't run Oban in test mode in production**: Set `testing: :manual` only in test env

---

## References

- **[Oban Documentation](https://hexdocs.pm/oban)** (L0_CANONICAL) - Background job library
- **[Oban.Plugins.Cron](https://hexdocs.pm/oban/Oban.Plugins.Cron.html)** (L0_CANONICAL) - Scheduled jobs
- **[Oban.Testing](https://hexdocs.pm/oban/Oban.Testing.html)** (L0_CANONICAL) - Testing helpers
- **[PostgreSQL LISTEN/NOTIFY](https://www.postgresql.org/docs/current/sql-notify.html)** (L0_CANONICAL) - Oban uses this

---

**Status**: Production (Sprint 0-1)
**Healthcare Compliance**: LGPD retention (5 years), CFM retention (20 years), HIPAA audit logs (6 years)
**Job Queues**: medical_workflow, lgpd_analysis, compliance_check, email, default
**Cron Jobs**: Compliance audit (daily 3 AM), LGPD retention (hourly), Health check (every 5 min)
