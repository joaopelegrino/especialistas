# Healthcare CMS - Main Workflows

> **Level**: 1 (Overview) | **Read Time**: 10min | **Tokens**: ~2K
> **Audience**: Developers, QA engineers, system architects
> **Last Validated**: 2025-09-30

---

## 🔐 Workflow 1: Authentication & Authorization

### Overview

**Guardian JWT + Zero Trust** - Stateless authentication with continuous validation.

### Sequence Diagram

```
┌─────────┐     ┌─────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Browser │     │ Phoenix │     │ Guardian │     │  Policy  │     │ Database │
│         │     │ Endpoint│     │   JWT    │     │  Engine  │     │   Repo   │
└────┬────┘     └────┬────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │               │               │               │               │
     │ POST /login   │               │               │               │
     │ (email, pwd)  │               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Authenticate  │               │               │
     │               │ (Argon2)      │               │               │
     │               ├───────────────┼───────────────┼──────────────>│
     │               │               │               │               │
     │               │<──────────────┼───────────────┼───────────────┤
     │               │ User record   │               │               │
     │               │               │               │               │
     │               │ Generate JWT  │               │               │
     │               ├──────────────>│               │               │
     │               │               │               │               │
     │               │               │ Calculate     │               │
     │               │               │ Trust Score   │               │
     │               │               ├──────────────>│               │
     │               │               │               │               │
     │               │               │<───────────────┤               │
     │               │               │ Score: 95     │               │
     │               │               │               │               │
     │               │<───────────────┤               │               │
     │               │ JWT token     │               │               │
     │               │ (includes     │               │               │
     │               │  trust_score) │               │               │
     │               │               │               │               │
     │<───────────────┤               │               │               │
     │ 200 OK        │               │               │               │
     │ {token, user} │               │               │               │
     │               │               │               │               │
     │ GET /posts    │               │               │               │
     │ Authorization:│               │               │               │
     │ Bearer <token>│               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Verify JWT    │               │               │
     │               ├──────────────>│               │               │
     │               │               │               │               │
     │               │<───────────────┤               │               │
     │               │ Valid         │               │               │
     │               │ (user_id,     │               │               │
     │               │  trust_score) │               │               │
     │               │               │               │               │
     │               │ Evaluate      │               │               │
     │               │ Policy        │               │               │
     │               ├───────────────┼──────────────>│               │
     │               │               │               │               │
     │               │<──────────────┼───────────────┤               │
     │               │ Decision:     │               │               │
     │               │ ALLOW         │               │               │
     │               │               │               │               │
     │               │ Query posts   │               │               │
     │               ├───────────────┼───────────────┼──────────────>│
     │               │               │               │               │
     │               │<──────────────┼───────────────┼───────────────┤
     │               │ [posts]       │               │               │
     │               │               │               │               │
     │<───────────────┤               │               │               │
     │ 200 OK        │               │               │               │
     │ {posts: [...]}│               │               │               │
     │               │               │               │               │
```

### Key Steps

**Step 1: Login (POST /api/auth/login)**
```elixir
# lib/healthcare_cms_web/controllers/auth_controller.ex
def login(conn, %{"email" => email, "password" => password}) do
  with {:ok, user} <- Accounts.authenticate_user(email, password),
       {:ok, token, _claims} <- Guardian.encode_and_sign(user, %{
         trust_score: PolicyEngine.calculate_initial_trust(user)
       }) do
    json(conn, %{token: token, user: user})
  else
    {:error, :unauthorized} ->
      conn |> put_status(401) |> json(%{error: "Invalid credentials"})
  end
end
```

**Step 2: Token Verification (on every request)**
```elixir
# lib/healthcare_cms_web/plugs/require_auth.ex
defmodule HealthcareCMSWeb.Plugs.RequireAuth do
  def call(conn, _opts) do
    with {:ok, user, claims} <- Guardian.resource_from_token(get_token(conn)),
         {:ok, decision} <- PolicyEngine.evaluate(build_context(conn, user, claims)),
         true <- decision.allow do
      assign(conn, :current_user, user)
    else
      _ ->
        conn |> put_status(403) |> json(%{error: "Forbidden"}) |> halt()
    end
  end
end
```

**Step 3: Trust Score Refresh** (every 15 minutes)
```elixir
# lib/healthcare_cms/security/trust_refresher.ex
defmodule HealthcareCMS.Security.TrustRefresher do
  use GenServer

  def init(_) do
    schedule_refresh()
    {:ok, %{}}
  end

  def handle_info(:refresh, state) do
    # Refresh trust scores for active sessions
    PolicyEngine.refresh_all_trust_scores()
    schedule_refresh()
    {:noreply, state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, :timer.minutes(15))
  end
end
```

---

## 📝 Workflow 2: Content Creation & Publishing

### Overview

**Medical content workflow** with LGPD validation and CFM compliance.

### Sequence Diagram

```
┌─────────┐     ┌─────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Doctor │     │ Phoenix │     │  Policy  │     │   LGPD   │     │ Database │
│ (Author)│     │LiveView │     │  Engine  │     │ Analyzer │     │   Repo   │
└────┬────┘     └────┬────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │               │               │               │               │
     │ Create Post   │               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Check Auth    │               │               │
     │               │ (trust ≥ 50)  │               │               │
     │               ├──────────────>│               │               │
     │               │               │               │               │
     │               │<───────────────┤               │               │
     │               │ ALLOW         │               │               │
     │               │               │               │               │
     │               │ Render Form   │               │               │
     │<───────────────┤               │               │               │
     │ Form HTML     │               │               │               │
     │               │               │               │               │
     │ Submit Draft  │               │               │               │
     │ (title, body) │               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Validate LGPD │               │               │
     │               ├───────────────┼──────────────>│               │
     │               │               │               │               │
     │               │<──────────────┼───────────────┤               │
     │               │ PHI detected: │               │               │
     │               │ CPF, phone    │               │               │
     │               │               │               │               │
     │               │ Flag for      │               │               │
     │               │ Review        │               │               │
     │<───────────────┤               │               │               │
     │ Warning: PHI  │               │               │               │
     │ detected      │               │               │               │
     │               │               │               │               │
     │ Redact PHI    │               │               │               │
     │ (edit text)   │               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Save Draft    │               │               │
     │               ├───────────────┼───────────────┼──────────────>│
     │               │               │               │               │
     │               │<──────────────┼───────────────┼───────────────┤
     │               │ Post:456      │               │               │
     │               │               │               │               │
     │<───────────────┤               │               │               │
     │ Draft saved   │               │               │               │
     │               │               │               │               │
     │ Publish       │               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Check Auth    │               │               │
     │               │ (trust ≥ 85)  │               │               │
     │               ├──────────────>│               │               │
     │               │               │               │               │
     │               │<───────────────┤               │               │
     │               │ ALLOW         │               │               │
     │               │               │               │               │
     │               │ Update Status │               │               │
     │               ├───────────────┼───────────────┼──────────────>│
     │               │               │               │               │
     │               │<──────────────┼───────────────┼───────────────┤
     │               │ Post:456      │               │               │
     │               │ (published)   │               │               │
     │               │               │               │               │
     │<───────────────┤               │               │               │
     │ Published ✓   │               │               │               │
     │               │               │               │               │
```

### Key Steps

**Step 1: Draft Creation**
```elixir
# lib/healthcare_cms_web/live/post_live/form.ex
defmodule HealthcareCMSWeb.PostLive.Form do
  use HealthcareCMSWeb, :live_view

  def handle_event("save_draft", %{"post" => post_params}, socket) do
    user = socket.assigns.current_user

    with {:ok, analysis} <- Workflows.LGPDAnalyzer.analyze_content(post_params["body"]),
         {:ok, post} <- Content.create_post(user, post_params) do

      if analysis.has_phi do
        {:noreply, socket
          |> put_flash(:warning, "PHI detected: #{format_detections(analysis.detected)}")
          |> assign(:post, post)}
      else
        {:noreply, socket
          |> put_flash(:info, "Draft saved successfully")
          |> push_navigate(to: ~p"/posts/#{post.id}")}
      end
    end
  end
end
```

**Step 2: Publishing (Status Change)**
```elixir
# lib/healthcare_cms/content.ex
defmodule HealthcareCMS.Content do
  def publish_post(%Post{} = post, %User{} = user) do
    context = %{
      user_id: user.id,
      role: user.role,
      resource: "Post:#{post.id}:publish",
      action: "publish"
    }

    with {:ok, decision} <- PolicyEngine.evaluate(context),
         true <- decision.trust_score >= 85,
         {:ok, post} <- update_post(post, %{status: :published, published_at: DateTime.utc_now()}) do

      # Broadcast to subscribers
      Phoenix.PubSub.broadcast(HealthcareCMS.PubSub, "posts", {:post_published, post})

      {:ok, post}
    else
      {:error, :insufficient_trust} ->
        {:error, "Trust score too low for publishing (required: 85)"}
      error ->
        error
    end
  end
end
```

---

## 🛡️ Workflow 3: Policy Evaluation

### Overview

**Zero Trust policy decision** - 8 data sources, <10ms latency.

### Sequence Diagram

```
┌─────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Request │     │  Policy  │     │  Trust   │     │   ETS    │
│ Context │     │  Engine  │     │Algorithm │     │  Cache   │
└────┬────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │               │               │               │
     │ Evaluate      │               │               │
     │ (context)     │               │               │
     ├──────────────>│               │               │
     │               │               │               │
     │               │ Check Cache   │               │
     │               ├───────────────┼───────────────>│
     │               │               │               │
     │               │<──────────────┼───────────────┤
     │               │ Miss          │               │
     │               │               │               │
     │               │ Calculate     │               │
     │               │ Trust Score   │               │
     │               ├──────────────>│               │
     │               │               │               │
     │               │               │ 1. Auth Factor│
     │               │               │    (MFA: +30) │
     │               │               │               │
     │               │               │ 2. Device     │
     │               │               │    (known: +15)│
     │               │               │               │
     │               │               │ 3. Session Age│
     │               │               │    (5min: +10)│
     │               │               │               │
     │               │               │ 4. IP Repute  │
     │               │               │    (good: +10)│
     │               │               │               │
     │               │               │ 5. Behavior   │
     │               │               │    (normal: +10)│
     │               │               │               │
     │               │               │ 6. Resource   │
     │               │               │    (PHI: +15) │
     │               │               │               │
     │               │               │ 7. Time       │
     │               │               │    (day: +5)  │
     │               │               │               │
     │               │               │ 8. History    │
     │               │               │    (consistent:│
     │               │               │     +5)       │
     │               │               │               │
     │               │               │ Total: 100    │
     │               │               │ Normalized: 95│
     │               │               │               │
     │               │<───────────────┤               │
     │               │ Score: 95     │               │
     │               │               │               │
     │               │ Apply Policy  │               │
     │               │ (resource:    │               │
     │               │  Patient:456: │               │
     │               │  medical_rec) │               │
     │               │               │               │
     │               │ Required: 75  │               │
     │               │ Actual: 95    │               │
     │               │ Decision:     │               │
     │               │ ALLOW         │               │
     │               │               │               │
     │               │ Store Cache   │               │
     │               ├───────────────┼───────────────>│
     │               │               │               │
     │<───────────────┤               │               │
     │ PolicyDecision│               │               │
     │ {allow: true, │               │               │
     │  trust: 95,   │               │               │
     │  required: 75}│               │               │
     │               │               │               │
```

### Key Steps

**Step 1: Policy Engine GenServer**
```elixir
# lib/healthcare_cms/security/policy_engine.ex
defmodule HealthcareCMS.Security.PolicyEngine do
  use GenServer

  def evaluate(context) do
    GenServer.call(__MODULE__, {:evaluate, context})
  end

  def handle_call({:evaluate, context}, _from, state) do
    decision = case :ets.lookup(state.cache, context.user_id) do
      [{_key, cached_score, timestamp}] when is_recent?(timestamp) ->
        make_decision(context, cached_score)

      _ ->
        score = TrustAlgorithm.calculate_score(context)
        :ets.insert(state.cache, {context.user_id, score, DateTime.utc_now()})
        make_decision(context, score)
    end

    {:reply, {:ok, decision}, state}
  end

  defp make_decision(context, trust_score) do
    required_score = get_required_score(context.resource)

    %PolicyDecision{
      allow: trust_score >= required_score,
      trust_score: trust_score,
      required_score: required_score,
      reason: build_reason(trust_score, required_score),
      timestamp: DateTime.utc_now()
    }
  end

  defp is_recent?(timestamp) do
    DateTime.diff(DateTime.utc_now(), timestamp, :second) < 300  # 5 minutes
  end
end
```

**Step 2: Trust Score Algorithm**
```elixir
# lib/healthcare_cms/security/trust_algorithm.ex
defmodule HealthcareCMS.Security.TrustAlgorithm do
  @weights %{
    auth_factor: 30,    # MFA vs password only
    device: 15,         # Known/trusted device
    session_age: 10,    # Time since auth
    ip_reputation: 10,  # GeoIP, VPN detection
    behavior: 10,       # Typing patterns, mouse
    resource: 15,       # Resource sensitivity
    time_of_day: 5,     # Unusual hours
    history: 5          # Deviation from normal
  }

  def calculate_score(context) do
    scores = %{
      auth_factor: score_auth_factor(context.auth_method),
      device: score_device(context.device_id),
      session_age: score_session_age(context.session_started_at),
      ip_reputation: score_ip(context.ip_address),
      behavior: score_behavior(context.user_id, context.behavior_metrics),
      resource: score_resource(context.resource),
      time_of_day: score_time(context.timestamp),
      history: score_history(context.user_id, context.action)
    }

    weighted_sum = Enum.reduce(scores, 0, fn {key, score}, acc ->
      acc + (score * @weights[key] / 100)
    end)

    round(weighted_sum)
  end
end
```

---

## 🏥 Workflow 4: Health Check & Monitoring

### Overview

**Real-time health status** with Telemetry metrics and Prometheus export.

### Sequence Diagram

```
┌─────────┐     ┌─────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Monitor │     │ Phoenix │     │ Health   │     │  Repo    │     │Prometheus│
│ (k8s)   │     │ Endpoint│     │Controller│     │ (DB)     │     │  Server  │
└────┬────┘     └────┬────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │               │               │               │               │
     │ GET /health   │               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Handle        │               │               │
     │               ├──────────────>│               │               │
     │               │               │               │               │
     │               │               │ Check DB      │               │
     │               │               ├──────────────>│               │
     │               │               │               │               │
     │               │               │<───────────────┤               │
     │               │               │ Latency: 2ms  │               │
     │               │               │               │               │
     │               │               │ Check Policy  │               │
     │               │               │ Engine        │               │
     │               │               │ (ping)        │               │
     │               │               │               │               │
     │               │               │ Check Memory  │               │
     │               │               │ (BEAM stats)  │               │
     │               │               │               │               │
     │               │<───────────────┤               │               │
     │               │ Health Status │               │               │
     │               │               │               │               │
     │<───────────────┤               │               │               │
     │ 200 OK        │               │               │               │
     │ {status: ok,  │               │               │               │
     │  checks: [...]}│               │               │               │
     │               │               │               │               │
     │               │               │               │               │
     │ GET /metrics  │               │               │               │
     ├──────────────┼───────────────┼───────────────┼───────────────>│
     │               │               │               │               │
     │<──────────────┼───────────────┼───────────────┼───────────────┤
     │ Prometheus    │               │               │               │
     │ metrics text  │               │               │               │
     │               │               │               │               │
```

### Key Steps

**Step 1: Health Check Endpoint**
```elixir
# lib/healthcare_cms_web/controllers/health_controller.ex
defmodule HealthcareCMSWeb.HealthController do
  use HealthcareCMSWeb, :controller

  def index(conn, _params) do
    checks = [
      check_database(),
      check_policy_engine(),
      check_memory(),
      check_disk()
    ]

    all_healthy = Enum.all?(checks, & &1.status == :ok)

    status = if all_healthy, do: 200, else: 503

    conn
    |> put_status(status)
    |> json(%{
      status: if(all_healthy, do: "healthy", else: "unhealthy"),
      timestamp: DateTime.utc_now(),
      checks: checks
    })
  end

  defp check_database do
    case Repo.query("SELECT 1", [], timeout: 1000) do
      {:ok, _} ->
        %{name: "database", status: :ok, latency_ms: measure_db_latency()}
      {:error, reason} ->
        %{name: "database", status: :error, reason: inspect(reason)}
    end
  end

  defp check_policy_engine do
    case GenServer.call(PolicyEngine, :ping, 1000) do
      :pong ->
        %{name: "policy_engine", status: :ok}
      _ ->
        %{name: "policy_engine", status: :error, reason: "timeout"}
    end
  rescue
    _ -> %{name: "policy_engine", status: :error, reason: "unavailable"}
  end

  defp check_memory do
    memory = :erlang.memory()
    total_mb = memory[:total] / 1_024 / 1_024

    status = if total_mb < 1024, do: :ok, else: :warning

    %{name: "memory", status: status, total_mb: round(total_mb)}
  end
end
```

**Step 2: Telemetry Metrics**
```elixir
# lib/healthcare_cms/application.ex
defmodule HealthcareCMS.Application do
  def start(_type, _args) do
    # Attach Telemetry handlers
    :telemetry.attach(
      "healthcare-cms-repo",
      [:healthcare_cms, :repo, :query],
      &HealthcareCMS.Telemetry.handle_repo_event/4,
      nil
    )

    children = [
      HealthcareCMS.Repo,
      HealthcareCMS.Security.PolicyEngine,
      {Phoenix.PubSub, name: HealthcareCMS.PubSub},
      HealthcareCMSWeb.Endpoint,
      {TelemetryMetricsPrometheus, [port: 9568]}  # Prometheus exporter
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

**Step 3: Kubernetes Probe Configuration**
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthcare-cms
spec:
  template:
    spec:
      containers:
      - name: app
        livenessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3

        readinessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
```

---

## 📊 Workflow Metrics

### Performance Targets

```yaml
Authentication:
  JWT verification: < 2ms (p99)
  Trust score calculation: < 10ms (p99)
  Total auth latency: < 15ms (p99)

Content Creation:
  Draft save: < 100ms (p99)
  LGPD analysis: < 50ms (p99)
  Publish: < 200ms (p99)

Policy Evaluation:
  Cache hit: < 1ms (p99)
  Cache miss: < 10ms (p99)
  ETS lookup: < 0.5ms (p99)

Health Check:
  Response time: < 50ms (p99)
  Database ping: < 5ms (p99)
  Overall check: < 100ms (p99)
```

---

## 🔗 Related Documentation

- **Key Concepts**: `./key-concepts.md`
- **Project Structure**: `./project-structure.md`
- **Architecture Summary**: `../../architecture/_summary.md`
- **ADR-002: Zero Trust**: `../../architecture/decisions-adr/002-zero-trust-architecture.md`
- **ADR-005: Guardian JWT**: `../../architecture/decisions-adr/005-guardian-jwt-auth.md`

---

**Version**: 1.0.0 | **Created**: 2025-09-30
