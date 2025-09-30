# OTP Supervision Trees

**Framework**: OTP (Open Telecom Platform)
**Erlang/OTP**: 27.1
**Elixir**: 1.17.3
**Healthcare Context**: Fault-tolerant medical systems, 99.95% uptime
**Last Updated**: 2025-09-30

---

## Overview

**OTP Supervision Trees** are hierarchical process structures that provide automatic fault recovery. When a supervised process crashes, its supervisor automatically restarts it according to a configured strategy.

**Healthcare Criticality**:
- **Medical systems cannot fail**: Patient monitoring, EHR access, telemedicine
- **HIPAA/LGPD uptime requirements**: 99.95% availability (21.6 minutes downtime/month)
- **Fault isolation**: One plugin crash cannot bring down entire system
- **Self-healing**: Automatic recovery without human intervention

**Erlang Track Record**: 99.9999999% uptime (31.5ms downtime/year) in telecom systems.

---

## Supervisor Basics

### Supervisor Behavior

```elixir
defmodule Healthcare.ApplicationSupervisor do
  use Supervisor
  
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end
  
  @impl true
  def init(_init_arg) do
    children = [
      # Child specifications
      {Healthcare.Database, []},
      {Healthcare.Cache, []},
      {Healthcare.PluginHost, []}
    ]
    
    # Supervision strategy
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

### Child Specification

```elixir
# Full child spec
%{
  id: Healthcare.Database,           # Unique identifier
  start: {Healthcare.Database, :start_link, []},  # MFA tuple
  restart: :permanent,               # :permanent | :temporary | :transient
  shutdown: 5000,                    # Timeout in ms (or :brutal_kill)
  type: :worker                      # :worker | :supervisor
}

# Shorthand (uses default child_spec/1)
{Healthcare.Database, []}
```

---

## Restart Strategies

### 1. :one_for_one

**Behavior**: If a child crashes, only that child is restarted.

```elixir
defmodule Healthcare.PluginSupervisor do
  use Supervisor
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    children = [
      {Healthcare.Plugin1, []},
      {Healthcare.Plugin2, []},
      {Healthcare.Plugin3, []}
    ]
    
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

**Diagram**:
```
Supervisor
├── Plugin1 (crashes) ❌ → restarted ✅
├── Plugin2 (unaffected) ✓
└── Plugin3 (unaffected) ✓
```

**Use Case**: Independent WASM plugins (one plugin crash doesn't affect others).

---

### 2. :one_for_all

**Behavior**: If any child crashes, ALL children are restarted.

```elixir
defmodule Healthcare.DatabaseCluster do
  use Supervisor
  
  @impl true
  def init(_opts) do
    children = [
      {Healthcare.Database.Primary, []},
      {Healthcare.Database.Replica1, []},
      {Healthcare.Database.Replica2, []}
    ]
    
    # If primary crashes, replicas must reconnect
    Supervisor.init(children, strategy: :one_for_all)
  end
end
```

**Diagram**:
```
Supervisor
├── Primary (crashes) ❌
├── Replica1 (killed) ❌ → all restarted ✅
└── Replica2 (killed) ❌
```

**Use Case**: Database clusters where all nodes must resync.

---

### 3. :rest_for_one

**Behavior**: If a child crashes, that child and all children started AFTER it are restarted.

```elixir
defmodule Healthcare.ApplicationStack do
  use Supervisor
  
  @impl true
  def init(_opts) do
    children = [
      {Healthcare.Database, []},      # 1. Start first
      {Healthcare.Cache, []},         # 2. Depends on Database
      {Healthcare.WebServer, []}      # 3. Depends on Cache
    ]
    
    # If Cache crashes, WebServer also restarted (depends on Cache)
    Supervisor.init(children, strategy: :rest_for_one)
  end
end
```

**Diagram**:
```
Supervisor
├── Database (unaffected) ✓
├── Cache (crashes) ❌ → restarted ✅
└── WebServer (killed) ❌ → restarted ✅ (depends on Cache)
```

**Use Case**: Dependency chains (WebServer needs Cache, Cache needs Database).

---

## Restart Types

### :permanent

**Behavior**: Always restart, regardless of exit reason.

```elixir
%{
  id: Healthcare.CriticalService,
  start: {Healthcare.CriticalService, :start_link, []},
  restart: :permanent  # Always restart
}
```

**Use Case**: Critical services (database, patient monitoring).

---

### :temporary

**Behavior**: Never restart, even if crashes.

```elixir
%{
  id: Healthcare.BatchJob,
  start: {Healthcare.BatchJob, :start_link, []},
  restart: :temporary  # Never restart
}
```

**Use Case**: One-time tasks (data export, report generation).

---

### :transient

**Behavior**: Restart only if exits abnormally (not for normal exit).

```elixir
%{
  id: Healthcare.PluginWorker,
  start: {Healthcare.PluginWorker, :start_link, []},
  restart: :transient  # Restart only on crashes
}
```

**Use Case**: WASM plugins (restart on crash, but not if plugin exits cleanly).

---

## Dynamic Supervisors

**Use Case**: Start/stop children at runtime (e.g., WASM plugins loaded on demand).

```elixir
defmodule Healthcare.DynamicPluginSupervisor do
  use DynamicSupervisor
  
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end
  
  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
  
  @doc "Load WASM plugin at runtime"
  def start_plugin(wasm_binary, plugin_config) do
    child_spec = %{
      id: plugin_config.plugin_id,
      start: {Healthcare.PluginWorker, :start_link, [wasm_binary, plugin_config]},
      restart: :transient
    }
    
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
  
  @doc "Unload plugin"
  def stop_plugin(plugin_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, plugin_pid)
  end
end

# Usage
{:ok, plugin_pid} = Healthcare.DynamicPluginSupervisor.start_plugin(
  wasm_binary,
  %{plugin_id: "fhir_validator_v1.2", max_memory: 50_000_000}
)

# Later...
Healthcare.DynamicPluginSupervisor.stop_plugin(plugin_pid)
```

---

## Healthcare Application Supervision Tree

### Full Application Structure

```elixir
defmodule Healthcare.Application do
  use Application
  
  @impl true
  def start(_type, _args) do
    children = [
      # Database layer (permanent, critical)
      {Healthcare.Repo, []},
      
      # Cache layer (permanent, critical)
      {Healthcare.Cache, []},
      
      # Supervision tree for WASM plugins (one_for_one)
      {Healthcare.DynamicPluginSupervisor, []},
      
      # Telemetry and monitoring (permanent)
      {Healthcare.Telemetry, []},
      
      # Phoenix endpoint (rest_for_one, depends on above)
      {Healthcare.Endpoint, []}
    ]
    
    opts = [strategy: :one_for_one, name: Healthcare.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### Supervision Tree Diagram

```
Healthcare.Application (Supervisor)
├── Healthcare.Repo (Database)
│   └── (Ecto connection pool)
│
├── Healthcare.Cache (ETS-based)
│   └── (In-memory cache)
│
├── Healthcare.DynamicPluginSupervisor
│   ├── PluginWorker (FHIR Validator) [dynamic]
│   ├── PluginWorker (LGPD Analyzer) [dynamic]
│   └── PluginWorker (Custom Plugin) [dynamic]
│
├── Healthcare.Telemetry
│   ├── :telemetry handler (Prometheus)
│   └── :telemetry handler (OpenTelemetry)
│
└── Healthcare.Endpoint (Phoenix)
    ├── Cowboy HTTP server
    └── Phoenix.PubSub
```

---

## Fault Tolerance Example: WASM Plugin Crash

### Scenario

1. WASM plugin crashes due to OOM (Out of Memory)
2. Supervisor detects crash and restarts plugin
3. Application continues serving requests

### Implementation

```elixir
defmodule Healthcare.PluginWorker do
  use GenServer
  require Logger
  
  def start_link({wasm_binary, config}) do
    GenServer.start_link(__MODULE__, {wasm_binary, config}, name: via_tuple(config.plugin_id))
  end
  
  defp via_tuple(plugin_id) do
    {:via, Registry, {Healthcare.PluginRegistry, plugin_id}}
  end
  
  @impl true
  def init({wasm_binary, config}) do
    Logger.info("Starting plugin: #{config.plugin_id}")
    
    # Initialize Extism plugin
    case Extism.Plugin.new(wasm_binary,
      allowed_hosts: [],
      max_memory_bytes: config.max_memory,
      timeout_ms: 5000
    ) do
      {:ok, plugin} ->
        {:ok, %{plugin: plugin, config: config, crash_count: 0}}
      
      {:error, reason} ->
        {:stop, reason}
    end
  end
  
  @impl true
  def handle_call({:call_function, func_name, input}, _from, state) do
    case Extism.Plugin.call(state.plugin, func_name, input) do
      {:ok, output} ->
        {:reply, {:ok, output}, state}
      
      {:error, :out_of_memory} ->
        Logger.error("Plugin OOM: #{state.config.plugin_id}")
        
        # Increment crash counter
        new_state = %{state | crash_count: state.crash_count + 1}
        
        # If crashed too many times, stop permanently
        if new_state.crash_count >= 3 do
          Logger.error("Plugin #{state.config.plugin_id} crashed 3 times, giving up")
          {:stop, :too_many_crashes, {:error, :plugin_unstable}, new_state}
        else
          # Let supervisor restart us
          {:stop, :out_of_memory, {:error, :out_of_memory}, new_state}
        end
      
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end
  
  @impl true
  def terminate(reason, state) do
    Logger.warning("Plugin terminating: #{state.config.plugin_id}, reason: #{inspect(reason)}")
    Extism.Plugin.free(state.plugin)
    :ok
  end
end
```

### Supervisor Configuration

```elixir
defmodule Healthcare.PluginSupervisor do
  use Supervisor
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    children = [
      # Registry for plugin lookup
      {Registry, keys: :unique, name: Healthcare.PluginRegistry},
      
      # Dynamic supervisor for plugins
      {DynamicSupervisor, strategy: :one_for_one, name: Healthcare.DynamicPluginSupervisor}
    ]
    
    Supervisor.init(children, strategy: :rest_for_one)
  end
  
  def load_plugin(wasm_binary, config) do
    child_spec = %{
      id: config.plugin_id,
      start: {Healthcare.PluginWorker, :start_link, [{wasm_binary, config}]},
      restart: :transient,  # Restart on crash, not on normal exit
      shutdown: 5000
    }
    
    DynamicSupervisor.start_child(Healthcare.DynamicPluginSupervisor, child_spec)
  end
end
```

### Observability: Crash Metrics

```elixir
defmodule Healthcare.PluginMetrics do
  use GenServer
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  
  @impl true
  def init(_) do
    # Subscribe to supervisor events
    :telemetry.attach(
      "plugin-crash-handler",
      [:supervisor, :child_terminated],
      &__MODULE__.handle_event/4,
      nil
    )
    
    {:ok, %{crash_counts: %{}}}
  end
  
  def handle_event([:supervisor, :child_terminated], measurements, metadata, _config) do
    if metadata.reason != :normal do
      # Emit Prometheus metric
      :prometheus_counter.inc(
        :plugin_crashes_total,
        [plugin_id: metadata.child_id, reason: metadata.reason]
      )
      
      Logger.warning("Plugin crash detected: #{inspect(metadata)}")
    end
  end
end
```

---

## Best Practices

### 1. Fail Fast

```elixir
# ❌ DON'T: Catch all errors
def init(config) do
  try do
    {:ok, initialize_dangerous_thing(config)}
  rescue
    _ -> {:ok, %{}}  # Silent failure, supervisor won't restart
  end
end

# ✅ DO: Let it crash
def init(config) do
  # If this fails, supervisor restarts with new config
  state = initialize_dangerous_thing(config)
  {:ok, state}
end
```

### 2. Idempotent Initialization

```elixir
defmodule Healthcare.Database do
  def init(_) do
    # Safe to run multiple times
    :ok = create_tables_if_not_exist()
    :ok = run_migrations()
    
    {:ok, %{conn: connect_to_db()}}
  end
end
```

### 3. Max Restart Intensity

```elixir
# Prevent restart loops
Supervisor.init(children,
  strategy: :one_for_one,
  max_restarts: 3,        # Max 3 restarts...
  max_seconds: 5          # ...in 5 seconds
)

# If exceeded, supervisor itself crashes (escalates to parent)
```

### 4. Supervision Tree Depth

```elixir
# ✅ GOOD: Shallow tree (2-3 levels)
Application
├── CoreSupervisor
│   ├── Database
│   └── Cache
└── PluginSupervisor
    └── DynamicSupervisor

# ❌ BAD: Deep tree (5+ levels)
Application
└── Supervisor1
    └── Supervisor2
        └── Supervisor3
            └── Supervisor4
                └── Worker
```

---

## Healthcare Compliance: Audit Trail

**Requirement**: LGPD Art. 46 + HIPAA 164.312(b) require audit logs of all system events.

```elixir
defmodule Healthcare.AuditSupervisor do
  use Supervisor
  
  @impl true
  def init(_) do
    children = [
      # Audit log writer (permanent, cannot fail)
      {Healthcare.AuditLog, []},
      
      # Subscribe to all supervisor events
      {Healthcare.SupervisionAuditor, []}
    ]
    
    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Healthcare.SupervisionAuditor do
  use GenServer
  require Logger
  
  @impl true
  def init(_) do
    # Subscribe to all child events
    :telemetry.attach_many(
      "supervision-audit",
      [
        [:supervisor, :child_started],
        [:supervisor, :child_terminated]
      ],
      &__MODULE__.handle_supervision_event/4,
      nil
    )
    
    {:ok, %{}}
  end
  
  def handle_supervision_event(event_name, measurements, metadata, _config) do
    audit_entry = %{
      event: event_name,
      supervisor: metadata.supervisor,
      child_id: metadata.child_id,
      reason: metadata[:reason],
      timestamp: DateTime.utc_now(),
      compliance_tag: "LGPD_Art_46_HIPAA_164_312_b"
    }
    
    Healthcare.AuditLog.write(audit_entry)
  end
end
```

---

## References

### Official Documentation
- [Elixir Supervisor](https://hexdocs.pm/elixir/Supervisor.html) (L0_CANONICAL)
- [Erlang Supervisor Behavior](https://www.erlang.org/doc/design_principles/sup_princ.html) (L0_CANONICAL)
- [OTP Design Principles](https://www.erlang.org/doc/design_principles/des_princ.html) (L0_CANONICAL)

### Books
- [Designing for Scalability with Erlang/OTP](https://www.oreilly.com/library/view/designing-for-scalability/9781449361556/) (L2_VALIDATED)
  - Chapter 4: "Supervisors"
- [Learn You Some Erlang: Supervisors](https://learnyousomeerlang.com/supervisors) (L2_VALIDATED)

### Industry Reports
- [Ericsson AXD 301 Switch](https://www.ericsson.com/en/reports-and-papers/white-papers) - 99.9999999% uptime (L2_VALIDATED)
- [WhatsApp: 2 Million Concurrent Connections](https://blog.whatsapp.com/1-million-is-so-2011) (L2_VALIDATED)

---

**DSM**: [L1:infrastructure | L2:healthcare | L3:architecture | L4:reference]
**Source**: `01-elixir-wasm-host-platform.md` (OTP supervision sections)
**Version**: 1.0.0
**Related**:
- [Fault Tolerance Patterns](./fault-tolerance.md)
- [Distributed Erlang](./distributed-erlang.md)
- [ADR 001: Elixir Host Choice](../../01-ARCHITECTURE/adrs/001-elixir-host-choice.md)
