# WASM Production Telemetry & Monitoring [NAVEGACAO-RAPIDA][IMPORTANT]

**Data**: 30/08/2025  
**Contexto**: Projeto Blog WebAssembly-First - Phase 3 Production Monitoring  
**Focus**: Production-grade WASM performance monitoring em client environment  
**Challenge**: Telemetry collection distributed entre server Phoenix + client WASM  
**Fontes**: Elixir Logger 1.18 + Phoenix Telemetry + WebAssembly monitoring 2025

## 🔍 Quick Navigation [ECONOMIA-TOKENS]
| Find | Line | Content | Savings |
|------|------|---------|---------|
| [ESSENCIAL] | L25 | Telemetry architecture | 80% |
| [ERRO-COMUM] | L110 | Performance bottlenecks | 85% |
| [TEMPLATE] | L190 | Ready monitoring setup | 90% |
| [ALERTS] | L290 | Production alerting | 75% |

---

## 🎯 Contexto e Motivação [ESSENCIAL]

### Problema Identificado  
- **Current**: Basic development telemetry apenas
- **Target**: Production-grade WASM performance monitoring
- **Challenge**: Distributed telemetry entre Phoenix server + WASM client
- **Complexity**: Metrics collection em environment WASM isolation

### Monitoring Objectives
```yaml
WASM Performance Monitoring:
  Bundle Metrics:
    - Load time: <2s first time, <500ms cached
    - Parse time: <300ms WASM instantiation  
    - Memory usage: <10MB heap usage
    - Bundle size: Track actual transfer size
    
  Runtime Metrics:
    - Initialization: <500ms AtomVM start
    - Operation latency: <50ms Elixir function calls
    - Memory pressure: GC frequency + duration
    - Error rates: Client crashes + exceptions
    
  Business Metrics:
    - Engagement: Time on page offline vs online
    - Feature usage: Offline feature adoption
    - Performance impact: Load time vs bounce rate  
    - Cost efficiency: CDN bandwidth vs server costs
```

### Strategic Value
- **Performance Optimization**: Data-driven WASM bundle improvements
- **User Experience**: Identify performance bottlenecks
- **Cost Management**: Monitor CDN usage vs server costs
- **Reliability**: Track offline/online transition success rates

---

## 📚 Pesquisa em Fontes Oficiais [ESSENCIAL]

### [Fonte 1]: Elixir Logger Production Configuration
**URL**: https://hexdocs.pm/logger/1.18.4/Logger.html  
**Focus**: Production logging, performance optimization, metadata

**Key Logger Features for WASM**:
```elixir
# Compile-time log purging
config :logger,
  compile_time_purge_matching: [
    [level_lower_than: :warning]  # Remove debug/info in production
  ]

# Performance protection
config :logger,
  truncate: 8192,           # Limit message size
  discard_threshold: 500,   # Overload protection (500 logs/sec)
  sync_threshold: 20        # Switch to sync mode under load
```

**Production Optimization Insights**:
- "Formats and truncates messages on client to avoid clogging Logger handlers"
- Overload protection limits to 500 logs per second by default
- Can dynamically adjust log levels for specific modules/applications
- Supports metadata capture for context (module, function, process)

### [Fonte 2]: Phoenix Telemetry Integration
**URL**: Phoenix telemetry documentation + Honeybadger blog post  
**Discovery**: Built-in telemetry events + custom metrics

**Phoenix Built-in Events**:
- Request processing: `[:phoenix, :endpoint, :start|stop]`
- LiveView events: `[:phoenix, :live_view, :mount|handle_event]`
- Channel events: `[:phoenix, :channel, :join|leave]`
- Database queries: `[:blog, :repo, :query]`

**Custom WASM Events Strategy**:
```elixir
:telemetry.execute([:blog, :wasm, :bundle_load], %{duration: load_time})
:telemetry.execute([:blog, :wasm, :operation], %{duration: op_time, type: :create_post})
```

### [Fonte 3]: AtomVM Monitoring Capabilities
**URL**: AtomVM GitHub + Smart Sensors use case  
**Focus**: Embedded monitoring, resource constraints

**AtomVM Monitoring Features**:
- Lightweight telemetry for embedded systems
- Memory usage tracking in constrained environments
- Process monitoring with minimal overhead
- Integration with environmental sensors (ESP32 example)

---

## ❌ Telemetry Antipatterns [ERRO-COMUM]

### 1. **Verbose Logging em WASM Environment**
```elixir
# ❌ ERRO: Logger verbose em production WASM
config :logger, level: :debug

# Result: Bundle bloat + performance degradation
# Impact: Slower initialization + memory pressure

# ✅ CORRETO: Minimal logging WASM
config :logger,
  level: :warning,
  compile_time_purge_matching: [
    [level_lower_than: :warning]
  ],
  backends: []  # No file logging in browser
```

### 2. **Blocking Telemetry em Client Processing**
```elixir
# ❌ ERRO: Synchronous telemetry blocking
def create_post(title, content) do
  start_time = System.monotonic_time()
  
  # Heavy telemetry call blocks operation
  result = Blog.Content.create_post(%{title: title, content: content})
  
  # Synchronous telemetry transmission
  send_telemetry_sync(%{
    operation: :create_post,
    duration: System.monotonic_time() - start_time,
    result: result
  })
  
  result
end

# ✅ CORRETO: Async telemetry
def create_post(title, content) do
  start_time = System.monotonic_time()
  result = Blog.Content.create_post(%{title: title, content: content})
  
  # Async telemetry (non-blocking)
  Task.start(fn ->
    :telemetry.execute([:blog, :wasm, :create_post], %{
      duration: System.monotonic_time() - start_time
    }, %{result: elem(result, 0)})
  end)
  
  result
end
```

### 3. **Missing Error Context em WASM**
```elixir
# ❌ ERRO: Generic error logging
Logger.error("WASM operation failed")

# ✅ CORRETO: Rich error context
Logger.error("WASM operation failed", 
  operation: :create_post,
  bundle_version: "v1.2.3",
  memory_usage: get_memory_usage(),
  user_agent: get_user_agent(),
  stack_trace: __STACKTRACE__
)
```

### 4. **No Performance Baselines**
```javascript
// ❌ ERRO: Metrics sem context
console.log(`Operation took ${duration}ms`);

// ✅ CORRETO: Baseline comparison
const baseline = 100; // ms expected
const performance_ratio = duration / baseline;

if (performance_ratio > 1.5) {
  console.warn(`Slow operation: ${duration}ms (${performance_ratio}x baseline)`);
  
  // Report performance degradation
  reportPerformanceIssue({
    operation: 'create_post',
    actual: duration,
    expected: baseline,
    ratio: performance_ratio
  });
}
```

---

## 🏗️ Production Telemetry Architecture [TEMPLATE]

### 1. **Server-Side Telemetry Handler**

```elixir
# lib/blog/telemetry.ex
defmodule Blog.Telemetry do
  @moduledoc """
  Production telemetry handler for WASM-specific metrics.
  Collects performance data from both server and client environments.
  """
  
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      # Telemetry metrics setup
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      
      # Custom metrics collector
      {Blog.Telemetry.Collector, []},
      
      # Performance aggregator  
      {Blog.Telemetry.Aggregator, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # WASM-specific metrics definitions
  def metrics do
    [
      # WASM Bundle Performance
      summary("blog.wasm.bundle.load_duration",
        unit: {:native, :millisecond},
        description: "WASM bundle load time",
        tags: [:bundle_version, :browser, :connection_type]
      ),
      
      summary("blog.wasm.runtime.init_duration", 
        unit: {:native, :millisecond},
        description: "AtomVM initialization time",
        tags: [:wasm_version, :device_type]
      ),
      
      # Client Operations
      counter("blog.wasm.operations.total",
        description: "Total WASM operations executed",
        tags: [:operation_type, :offline_mode]
      ),
      
      distribution("blog.wasm.operations.duration",
        unit: {:native, :millisecond}, 
        description: "WASM operation execution time",
        buckets: [10, 50, 100, 500, 1000, 5000],
        tags: [:operation_type, :complexity]
      ),
      
      # Memory & Resources
      last_value("blog.wasm.memory.heap_usage",
        unit: :byte,
        description: "WASM heap memory usage",
        tags: [:runtime_type]
      ),
      
      counter("blog.wasm.errors.total",
        description: "WASM runtime errors",
        tags: [:error_type, :operation, :recovery_status]
      ),
      
      # Offline-First Metrics
      counter("blog.offline.operations.total",
        description: "Operations performed offline",
        tags: [:operation_type, :sync_status]
      ),
      
      summary("blog.offline.sync.duration",
        unit: {:native, :millisecond},
        description: "Offline sync completion time", 
        tags: [:operations_count, :conflicts_resolved]
      ),
      
      # Business Metrics
      counter("blog.engagement.time_on_page",
        description: "User engagement tracking",
        tags: [:page_type, :connection_mode]
      )
    ]
  end

  # Periodic measurements
  defp periodic_measurements do
    [
      # System metrics
      {Blog.Telemetry, :dispatch_system_metrics, []},
      
      # WASM-specific metrics
      {Blog.Telemetry, :dispatch_wasm_metrics, []},
      
      # Business metrics
      {Blog.Telemetry, :dispatch_usage_metrics, []}
    ]
  end

  def dispatch_system_metrics do
    :telemetry.execute([:blog, :system], %{
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count),
      port_count: :erlang.system_info(:port_count)
    })
  end

  def dispatch_wasm_metrics do
    # Collect from WASM client via API
    case Blog.Telemetry.Client.get_current_metrics() do
      {:ok, metrics} ->
        :telemetry.execute([:blog, :wasm, :runtime], metrics.runtime)
        :telemetry.execute([:blog, :wasm, :performance], metrics.performance)
        
      {:error, _reason} ->
        # Client metrics unavailable (offline?)
        :telemetry.execute([:blog, :wasm, :client_unavailable], %{count: 1})
    end
  end
end
```

### 2. **Client-Side Metrics Collection**

```javascript
// assets/js/wasm-telemetry.js
class WasmTelemetry {
  constructor() {
    this.metrics = {
      runtime: {
        heap_usage: 0,
        initialization_time: 0,
        operation_count: 0,
        error_count: 0
      },
      performance: {
        bundle_load_time: 0,
        average_operation_time: 0,
        offline_operations: 0,
        sync_success_rate: 1.0
      },
      business: {
        time_on_page: 0,
        feature_usage: {},
        engagement_score: 0
      }
    };
    
    this.operationTimes = [];
    this.startTime = Date.now();
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Bundle loading metrics
    window.addEventListener('wasm-bundle-loaded', (event) => {
      this.metrics.performance.bundle_load_time = event.detail.duration;
      this.reportMetric('bundle_load', event.detail);
    });
    
    // Runtime initialization  
    window.addEventListener('wasm-runtime-ready', (event) => {
      this.metrics.runtime.initialization_time = event.detail.duration;
      this.reportMetric('runtime_init', event.detail);
    });
    
    // Operation tracking
    window.addEventListener('wasm-operation', (event) => {
      this.trackOperation(event.detail);
    });
    
    // Error tracking
    window.addEventListener('wasm-error', (event) => {
      this.trackError(event.detail);
    });
    
    // Memory monitoring (if available)
    if (performance.memory) {
      setInterval(() => this.trackMemoryUsage(), 5000);
    }
    
    // Page engagement
    this.setupEngagementTracking();
  }

  trackOperation(operation) {
    this.metrics.runtime.operation_count++;
    this.operationTimes.push(operation.duration);
    
    // Update average (rolling window)
    if (this.operationTimes.length > 100) {
      this.operationTimes = this.operationTimes.slice(-50);
    }
    
    this.metrics.performance.average_operation_time = 
      this.operationTimes.reduce((sum, time) => sum + time, 0) / this.operationTimes.length;
    
    // Track offline operations
    if (operation.offline) {
      this.metrics.performance.offline_operations++;
    }
    
    // Report if operation is slow
    if (operation.duration > 1000) {
      this.reportSlowOperation(operation);
    }
  }

  trackError(error) {
    this.metrics.runtime.error_count++;
    
    // Categorize error type
    const errorType = this.categorizeError(error);
    
    // Report immediately for critical errors
    if (errorType === 'critical') {
      this.reportCriticalError(error);
    }
    
    // Update error rate
    const total_ops = this.metrics.runtime.operation_count;
    const error_rate = this.metrics.runtime.error_count / total_ops;
    
    if (error_rate > 0.05) {  // 5% error rate threshold
      this.reportHighErrorRate(error_rate);
    }
  }

  trackMemoryUsage() {
    if (performance.memory) {
      const current = performance.memory.usedJSHeapSize;
      this.metrics.runtime.heap_usage = current;
      
      // Alert on high memory usage
      const maxMemory = 10 * 1024 * 1024; // 10MB
      if (current > maxMemory) {
        this.reportMemoryPressure(current);
      }
    }
  }

  setupEngagementTracking() {
    let pageStartTime = Date.now();
    let isActive = true;
    
    // Track page visibility
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        // Calculate time on page
        const timeOnPage = Date.now() - pageStartTime;
        this.metrics.business.time_on_page += timeOnPage;
        isActive = false;
      } else {
        pageStartTime = Date.now();
        isActive = true;
      }
    });
    
    // Track feature usage
    window.addEventListener('wasm-feature-used', (event) => {
      const feature = event.detail.feature;
      this.metrics.business.feature_usage[feature] = 
        (this.metrics.business.feature_usage[feature] || 0) + 1;
    });
  }

  // Error categorization
  categorizeError(error) {
    if (error.message.includes('OutOfMemory') || 
        error.message.includes('SharedArrayBuffer')) {
      return 'critical';
    }
    
    if (error.message.includes('WASM') || 
        error.message.includes('AtomVM')) {
      return 'runtime';
    }
    
    return 'application';
  }

  // Reporting methods
  async reportMetric(type, data) {
    const payload = {
      type: type,
      data: data,
      timestamp: new Date().toISOString(),
      user_agent: navigator.userAgent,
      bundle_version: window.WASM_BUNDLE_VERSION || 'unknown'
    };
    
    try {
      await fetch('/api/telemetry/wasm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
    } catch (error) {
      // Store for offline sync
      this.storeOfflineMetric(payload);
    }
  }

  async reportSlowOperation(operation) {
    await this.reportMetric('slow_operation', {
      operation_type: operation.type,
      duration: operation.duration,
      expected: operation.expected || 100,
      context: operation.context
    });
  }

  async reportCriticalError(error) {
    await this.reportMetric('critical_error', {
      message: error.message,
      stack: error.stack,
      operation: error.operation,
      memory_at_error: performance.memory?.usedJSHeapSize,
      timestamp: Date.now()
    });
  }

  async storeOfflineMetric(payload) {
    if (window.storageBridge) {
      await window.storageBridge.storePendingOperation({
        type: 'telemetry',
        payload: payload,
        timestamp: Date.now()
      });
    }
  }

  // Get current metrics for server collection
  getCurrentMetrics() {
    return {
      runtime: this.metrics.runtime,
      performance: this.metrics.performance,
      business: this.metrics.business,
      collected_at: new Date().toISOString()
    };
  }
}

// Global telemetry instance
window.wasmTelemetry = new WasmTelemetry();
```

### 3. **Server-Side Telemetry API**

```elixir
# lib/blog_web/controllers/telemetry_controller.ex
defmodule BlogWeb.TelemetryController do
  use BlogWeb, :controller
  
  alias Blog.Telemetry.Collector

  def wasm_metrics(conn, %{"type" => type, "data" => data} = params) do
    # Validate and sanitize client metrics
    with {:ok, validated_data} <- validate_telemetry_data(data),
         :ok <- Collector.store_wasm_metric(type, validated_data) do
      
      # Execute telemetry event
      :telemetry.execute(
        [:blog, :wasm, :client_metric], 
        validated_data,
        %{type: type, source: :client}
      )
      
      json(conn, %{status: :ok})
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def bulk_metrics(conn, %{"metrics" => metrics_list}) do
    # Handle bulk metrics from offline sync
    results = 
      metrics_list
      |> Enum.map(&process_bulk_metric/1)
      |> Enum.reduce(%{success: 0, errors: 0}, &aggregate_results/2)
    
    json(conn, results)
  end

  defp validate_telemetry_data(data) do
    # Sanitize and validate client-provided data
    required_fields = ["timestamp", "duration"]
    
    case Enum.all?(required_fields, &Map.has_key?(data, &1)) do
      true -> {:ok, sanitize_data(data)}
      false -> {:error, "Missing required fields"}
    end
  end

  defp sanitize_data(data) do
    %{
      timestamp: parse_timestamp(data["timestamp"]),
      duration: clamp_duration(data["duration"]),
      user_agent: sanitize_user_agent(data["user_agent"]),
      bundle_version: sanitize_version(data["bundle_version"])
    }
  end

  defp clamp_duration(duration) when is_number(duration) do
    # Clamp to reasonable bounds
    max(0, min(duration, 60_000))  # Max 60 seconds
  end
  defp clamp_duration(_), do: 0
end
```

### 4. **Performance Aggregation & Alerting**

```elixir
# lib/blog/telemetry/aggregator.ex
defmodule Blog.Telemetry.Aggregator do
  @moduledoc """
  Aggregates WASM performance metrics and triggers alerts.
  Maintains rolling windows for trend analysis.
  """
  
  use GenServer
  
  alias Blog.Telemetry.Storage

  defstruct [
    :performance_window,
    :error_rates,
    :bundle_metrics,
    :last_alert,
    :alert_cooldown
  ]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    # Attach to telemetry events
    :telemetry.attach_many(
      "wasm-aggregator",
      [
        [:blog, :wasm, :bundle_load],
        [:blog, :wasm, :operation],
        [:blog, :wasm, :error],
        [:blog, :offline, :sync]
      ],
      &handle_telemetry_event/4,
      %{}
    )
    
    state = %__MODULE__{
      performance_window: :queue.new(),
      error_rates: %{},
      bundle_metrics: %{},
      last_alert: nil,
      alert_cooldown: 300_000  # 5 minutes
    }
    
    # Schedule periodic analysis
    :timer.send_interval(60_000, self(), :analyze_metrics)
    
    {:ok, state}
  end

  def handle_telemetry_event([:blog, :wasm, :bundle_load], measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:bundle_metric, measurements, metadata})
  end

  def handle_telemetry_event([:blog, :wasm, :operation], measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:operation_metric, measurements, metadata})
  end

  def handle_telemetry_event([:blog, :wasm, :error], measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:error_metric, measurements, metadata})
  end

  def handle_cast({:bundle_metric, measurements, metadata}, state) do
    # Update bundle metrics
    bundle_key = metadata[:bundle_version] || "unknown"
    current_metrics = Map.get(state.bundle_metrics, bundle_key, [])
    
    new_metrics = [measurements.duration | current_metrics]
    |> Enum.take(100)  # Keep last 100 measurements
    
    updated_bundle_metrics = Map.put(state.bundle_metrics, bundle_key, new_metrics)
    
    # Check for performance degradation
    if measurements.duration > 5000 do  # 5s threshold
      send_alert(:slow_bundle_load, %{
        duration: measurements.duration,
        bundle_version: bundle_key,
        metadata: metadata
      })
    end
    
    {:noreply, %{state | bundle_metrics: updated_bundle_metrics}}
  end

  def handle_cast({:operation_metric, measurements, metadata}, state) do
    # Add to performance window
    metric = %{
      type: :operation,
      duration: measurements.duration,
      operation: metadata[:operation_type],
      timestamp: System.system_time(:millisecond)
    }
    
    new_window = add_to_window(state.performance_window, metric, 1000) # Keep 1000 ops
    
    {:noreply, %{state | performance_window: new_window}}
  end

  def handle_cast({:error_metric, measurements, metadata}, state) do
    error_type = metadata[:error_type] || "unknown"
    current_count = Map.get(state.error_rates, error_type, 0)
    
    updated_rates = Map.put(state.error_rates, error_type, current_count + 1)
    
    # Check error rate threshold
    total_operations = :queue.len(state.performance_window)
    error_rate = current_count / max(total_operations, 1)
    
    if error_rate > 0.05 do  # 5% error rate
      send_alert(:high_error_rate, %{
        error_type: error_type,
        rate: error_rate,
        count: current_count,
        total: total_operations
      })
    end
    
    {:noreply, %{state | error_rates: updated_rates}}
  end

  def handle_info(:analyze_metrics, state) do
    # Periodic performance analysis
    analyze_performance_trends(state)
    analyze_error_patterns(state)
    analyze_bundle_performance(state)
    
    {:noreply, state}
  end

  # Alert system
  defp send_alert(type, data) do
    # Don't spam alerts (cooldown)
    now = System.system_time(:millisecond)
    cooldown_expired = case GenServer.call(__MODULE__, :get_last_alert) do
      nil -> true
      last_alert -> (now - last_alert) > 300_000  # 5 minutes
    end
    
    if cooldown_expired do
      # Send alert (webhook, email, etc.)
      Blog.Alerts.send_alert(type, data)
      GenServer.cast(__MODULE__, {:set_last_alert, now})
    end
  end

  # Performance analysis
  defp analyze_performance_trends(state) do
    ops = :queue.to_list(state.performance_window)
    
    if length(ops) > 50 do
      recent_ops = Enum.take(ops, -50)
      old_ops = Enum.take(ops, 50)
      
      recent_avg = avg_duration(recent_ops)
      old_avg = avg_duration(old_ops)
      
      # Detect performance regression
      if recent_avg > old_avg * 1.5 do
        send_alert(:performance_regression, %{
          recent_average: recent_avg,
          baseline_average: old_avg,
          regression_factor: recent_avg / old_avg
        })
      end
    end
  end

  defp avg_duration(operations) do
    operations
    |> Enum.map(& &1.duration)
    |> Enum.sum()
    |> Kernel./(length(operations))
  end
end
```

---

## 📊 Production Monitoring Dashboard [ALERTS]

### Real-Time Metrics Dashboard

```elixir
# lib/blog_web/live/admin/telemetry_dashboard_live.ex
defmodule BlogWeb.Admin.TelemetryDashboardLive do
  use BlogWeb, :live_view
  
  alias Blog.Telemetry.Storage

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to telemetry events
      :telemetry.attach(
        "dashboard-metrics",
        [:blog, :wasm, :client_metric],
        &handle_telemetry_event/4,
        socket.assigns
      )
      
      Phoenix.PubSub.subscribe(Blog.PubSub, "telemetry:alerts")
    end
    
    socket = 
      socket
      |> assign(:bundle_metrics, get_bundle_metrics())
      |> assign(:performance_metrics, get_performance_metrics())
      |> assign(:error_summary, get_error_summary())
      |> assign(:alerts, get_recent_alerts())
    
    {:ok, socket}
  end

  def handle_info({:telemetry_event, event, measurements, metadata}, socket) do
    # Update dashboard with real-time data
    socket = 
      case event do
        [:blog, :wasm, :bundle_load] ->
          update_bundle_metrics(socket, measurements, metadata)
        [:blog, :wasm, :operation] ->
          update_performance_metrics(socket, measurements, metadata)
        [:blog, :wasm, :error] ->
          update_error_metrics(socket, measurements, metadata)
      end
    
    {:noreply, socket}
  end

  def handle_info({:alert, type, data}, socket) do
    alert = %{
      type: type,
      data: data,
      timestamp: DateTime.utc_now(),
      severity: alert_severity(type)
    }
    
    alerts = [alert | socket.assigns.alerts] |> Enum.take(50)
    
    {:noreply, assign(socket, :alerts, alerts)}
  end

  # Dashboard rendering
  def render(assigns) do
    ~H"""
    <div class="telemetry-dashboard">
      <h1>WASM Production Telemetry</h1>
      
      <!-- Real-time status -->
      <div class="status-grid">
        <div class="metric-card">
          <h3>Bundle Performance</h3>
          <div class="metric-value">
            <%= @bundle_metrics.avg_load_time %>ms
          </div>
          <div class="metric-trend <%= trend_class(@bundle_metrics.trend) %>">
            <%= @bundle_metrics.trend %>%
          </div>
        </div>
        
        <div class="metric-card">
          <h3>Operation Latency</h3>
          <div class="metric-value">
            <%= @performance_metrics.p95_duration %>ms
          </div>
          <div class="metric-detail">
            P95 across <%= @performance_metrics.sample_size %> operations
          </div>
        </div>
        
        <div class="metric-card">
          <h3>Error Rate</h3>
          <div class="metric-value <%= error_class(@error_summary.rate) %>">
            <%= Float.round(@error_summary.rate * 100, 2) %>%
          </div>
          <div class="metric-detail">
            <%= @error_summary.count %> errors / <%= @error_summary.total %> operations
          </div>
        </div>
      </div>
      
      <!-- Recent alerts -->
      <div class="alerts-section">
        <h3>Recent Alerts</h3>
        <%= for alert <- @alerts do %>
          <div class="alert alert-<%= alert.severity %>">
            <span class="alert-type"><%= alert.type %></span>
            <span class="alert-time"><%= format_time(alert.timestamp) %></span>
            <div class="alert-details">
              <%= format_alert_data(alert.data) %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper functions
  defp get_bundle_metrics do
    Storage.get_bundle_summary(last: 24, unit: :hours)
  end

  defp get_performance_metrics do
    Storage.get_performance_summary(last: 1, unit: :hours)
  end

  defp get_error_summary do
    Storage.get_error_summary(last: 24, unit: :hours)
  end

  defp alert_severity(:critical_error), do: :critical
  defp alert_severity(:high_error_rate), do: :critical  
  defp alert_severity(:performance_regression), do: :warning
  defp alert_severity(:slow_bundle_load), do: :warning
  defp alert_severity(_), do: :info
end
```

### Production Alerting Configuration

```elixir
# lib/blog/alerts.ex
defmodule Blog.Alerts do
  @moduledoc """
  Production alerting system for WASM performance issues.
  Integrates with external services for critical notifications.
  """

  require Logger

  @alert_thresholds %{
    bundle_load_time: 5000,      # 5s max
    operation_latency: 1000,     # 1s max
    error_rate: 0.05,           # 5% max
    memory_usage: 10_485_760,   # 10MB max
    offline_operations: 100      # 100 pending ops max
  }

  def send_alert(type, data) do
    alert_config = Application.get_env(:blog, :alerts, %{})
    
    # Log locally
    Logger.warning("WASM Alert triggered", 
      type: type,
      data: data,
      severity: alert_severity(type)
    )
    
    # Send to external services
    if alert_config[:webhook_url] do
      send_webhook_alert(alert_config[:webhook_url], type, data)
    end
    
    if alert_config[:email_enabled] do
      send_email_alert(type, data)
    end
    
    # Store for dashboard
    store_alert_history(type, data)
  end

  defp send_webhook_alert(url, type, data) do
    payload = %{
      alert_type: type,
      severity: alert_severity(type),
      data: data,
      timestamp: DateTime.utc_now(),
      service: "blog-wasm"
    }
    
    HTTPoison.post(url, Jason.encode!(payload), [
      {"Content-Type", "application/json"}
    ])
  end

  defp alert_severity(type) do
    case type do
      t when t in [:critical_error, :high_error_rate] -> :critical
      t when t in [:performance_regression, :memory_pressure] -> :warning
      _ -> :info
    end
  end
end
```

---

## 🔗 Referências e Links Oficiais [REFERÊNCIAS]

### Documentação Oficial
- **Elixir Logger**: https://hexdocs.pm/logger/1.18.4/Logger.html
- **Phoenix Telemetry**: https://hexdocs.pm/phoenix/telemetry.html
- **Telemetry.Metrics**: https://hexdocs.pm/telemetry_metrics/Telemetry.Metrics.html
- **Phoenix.PubSub**: https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html

### Performance Monitoring
- **Web Performance APIs**: https://developer.mozilla.org/en-US/docs/Web/API/Performance
- **WebAssembly Monitoring**: https://webassembly.org/docs/faq/
- **Browser Performance**: https://web.dev/performance/

### Production Tools
- **Honeybadger Elixir**: https://hexdocs.pm/honeybadger/readme.html
- **AppSignal Elixir**: https://hexdocs.pm/appsignal/readme.html  
- **New Relic Elixir**: https://hexdocs.pm/new_relic_agent/readme.html

### Compatibility Notes
- **Telemetry**: Elixir 1.10+ (disponível em 1.17.3)
- **Performance APIs**: Modern browsers 2025
- **Service Workers**: Universal support
- **IndexedDB**: All browsers, 2GB+ storage limit

---

**🎯 RESULTADO ESPERADO**: Production telemetry completa para WASM environment com metrics collection client/server, performance monitoring, error tracking, alerting system, e dashboard real-time. Data-driven optimization para Phase 3 success.**