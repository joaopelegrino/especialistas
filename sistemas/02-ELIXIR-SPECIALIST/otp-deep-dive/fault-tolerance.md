# Fault Tolerance in Elixir/OTP

**Framework**: OTP (Open Telecom Platform)
**Erlang/OTP**: 27.1
**Elixir**: 1.17.3
**Healthcare Context**: Mission-critical medical systems with self-healing
**Last Updated**: 2025-09-30

---

## Overview

**Fault tolerance** is OTP's philosophy: build systems that continue operating despite failures.

**Core Principles**:
1. **Let It Crash**: Don't defensively program for every error - let processes crash and supervisors restart them
2. **Process Isolation**: One process crash cannot affect other processes
3. **Supervision Trees**: Hierarchical recovery strategies
4. **No Shared State**: Immutable message passing eliminates race conditions

**Healthcare Mandate**: Medical systems require 99.95%+ uptime (HIPAA, LGPD compliance).

---

## Let It Crash Philosophy

### Traditional Approach (Defensive)

```elixir
# ❌ Defensive programming (error-prone, complex)
defmodule TraditionalApproach do
  def process_patient_data(data) do
    try do
      if is_nil(data) do
        raise "Data is nil"
      end
      
      if not Map.has_key?(data, :cpf) do
        raise "Missing CPF"
      end
      
      if String.length(data.cpf) != 11 do
        raise "Invalid CPF length"
      end
      
      # 50 more validation checks...
      
      {:ok, process(data)}
    rescue
      error1 -> handle_error1(error1)
      error2 -> handle_error2(error2)
      error3 -> handle_error3(error3)
      # 47 more error handlers...
    catch
      :exit, reason -> handle_exit(reason)
      :throw, value -> handle_throw(value)
    after
      cleanup()
    end
  end
end
```

### OTP Approach (Let It Crash)

```elixir
# ✅ Let it crash (simple, robust)
defmodule OTPApproach do
  def process_patient_data(data) do
    # If data is invalid, process crashes
    # Supervisor restarts it with new data
    cpf = data.cpf  # Pattern match - crashes if missing
    true = String.length(cpf) == 11  # Guard - crashes if false
    
    process(data)
  end
end
```

**Why This Works**:
- Supervisor restarts crashed process automatically
- No need to handle every error case manually
- Simpler code = fewer bugs
- Process crash does NOT crash application

---

## Process Isolation

### Independent Processes

```elixir
defmodule Healthcare.PatientWorker do
  use GenServer
  
  def start_link(patient_id) do
    GenServer.start_link(__MODULE__, patient_id)
  end
  
  @impl true
  def init(patient_id) do
    # Each patient processed in isolated process
    {:ok, %{patient_id: patient_id, data: load_patient(patient_id)}}
  end
  
  @impl true
  def handle_call(:process, _from, state) do
    # If this crashes, ONLY this patient's process dies
    result = risky_medical_algorithm(state.data)
    {:reply, {:ok, result}, state}
  end
  
  defp risky_medical_algorithm(data) do
    # Complex medical calculation that might fail
    # If it crashes, supervisor restarts THIS worker only
    data.weight / (data.height * data.height)  # May crash if nil
  end
end

# Start 1000 patient workers
patients = 1..1000
workers = Enum.map(patients, fn patient_id ->
  {:ok, pid} = Healthcare.PatientWorker.start_link(patient_id)
  pid
end)

# If patient 500's process crashes, patients 1-499 and 501-1000 unaffected
```

**Isolation Benefits**:
- One patient's error doesn't affect others
- System continues processing remaining patients
- Failed patient automatically retried (supervisor restart)

---

## Links and Monitors

### Process Links (Bidirectional)

```elixir
# When linked processes crash, both die
pid1 = spawn_link(fn ->
  # If pid1 crashes, current process also crashes
  Process.sleep(1000)
  raise "Crash!"
end)

# Wait for crash
Process.sleep(2000)  # This line never executes (process died)
```

**Use Case**: Supervisor links to children (if child crashes, supervisor knows to restart it).

### Process Monitors (Unidirectional)

```elixir
# Monitor doesn't crash monitored process
pid = spawn(fn ->
  Process.sleep(1000)
  raise "Crash!"
end)

ref = Process.monitor(pid)

# Current process receives message when pid crashes
receive do
  {:DOWN, ^ref, :process, ^pid, reason} ->
    IO.puts("Process crashed with reason: #{inspect(reason)}")
end

# Current process still alive
IO.puts("I survived!")
```

**Use Case**: Track child processes without dying if they crash.

---

## Healthcare Example: FHIR Validation Pipeline

### Scenario

- Receive 10,000 FHIR Patient resources
- Validate each against FHIR R4 schema
- If validation crashes, log error and continue
- Store valid resources in database

### Implementation

```elixir
defmodule Healthcare.FHIRValidationPipeline do
  use GenServer
  require Logger
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  
  @impl true
  def init(_) do
    {:ok, %{validated: 0, errors: 0}}
  end
  
  def validate_batch(fhir_resources) do
    GenServer.cast(__MODULE__, {:validate_batch, fhir_resources})
  end
  
  @impl true
  def handle_cast({:validate_batch, resources}, state) do
    # Start Task.Supervisor for parallel validation
    tasks = Enum.map(resources, fn resource ->
      Task.Supervisor.async_nolink(Healthcare.TaskSupervisor, fn ->
        validate_resource(resource)
      end)
    end)
    
    # Collect results (with timeout)
    results = Task.yield_many(tasks, 5000)
    
    {validated, errors} = Enum.reduce(results, {0, 0}, fn
      {task, {:ok, {:ok, _valid_resource}}}, {v, e} ->
        {v + 1, e}
      
      {task, {:ok, {:error, reason}}}, {v, e} ->
        Logger.warning("Validation failed: #{inspect(reason)}")
        {v, e + 1}
      
      {task, nil}, {v, e} ->
        # Task timeout - kill it
        Task.shutdown(task, :brutal_kill)
        Logger.error("Validation timeout")
        {v, e + 1}
    end)
    
    new_state = %{
      validated: state.validated + validated,
      errors: state.errors + errors
    }
    
    Logger.info("Batch complete: #{validated} validated, #{errors} errors")
    {:noreply, new_state}
  end
  
  defp validate_resource(resource) do
    # This may crash - that's OK, Task catches it
    case Healthcare.FHIR.Validator.validate(resource) do
      {:ok, valid} ->
        Healthcare.Repo.insert(valid)
        {:ok, valid}
      
      {:error, reason} ->
        {:error, reason}
    end
  end
end

# Supervisor configuration
defmodule Healthcare.Application do
  use Application
  
  def start(_type, _args) do
    children = [
      # Task supervisor for parallel validation
      {Task.Supervisor, name: Healthcare.TaskSupervisor},
      
      # Validation pipeline
      Healthcare.FHIRValidationPipeline
    ]
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

# Usage
fhir_patients = load_10000_fhir_resources()
Healthcare.FHIRValidationPipeline.validate_batch(fhir_patients)

# Even if 100 resources have invalid data and crash validation,
# remaining 9,900 are still processed successfully
```

---

## Error Kernel Pattern

**Principle**: Separate system into error kernel (critical, defensive) and application code (let it crash).

```elixir
defmodule Healthcare.ErrorKernel do
  @moduledoc """
  Critical infrastructure that MUST NOT crash.
  
  - Database connections
  - Audit logging
  - Authentication
  """
  
  use Supervisor
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    children = [
      # These are PERMANENT - never let them crash
      {Healthcare.Repo, []},
      {Healthcare.AuditLog, []},
      {Healthcare.AuthenticationService, []}
    ]
    
    Supervisor.init(children,
      strategy: :one_for_one,
      max_restarts: 10,      # Retry 10 times...
      max_seconds: 60        # ...in 60 seconds
    )
  end
end

defmodule Healthcare.ApplicationLayer do
  @moduledoc """
  Application logic that CAN crash (supervisor will restart).
  
  - WASM plugins
  - FHIR validation
  - Business logic
  """
  
  use Supervisor
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    children = [
      # These can crash - transient restart
      {Healthcare.PluginHost, []},
      {Healthcare.FHIRProcessor, []}
    ]
    
    Supervisor.init(children,
      strategy: :one_for_one,
      max_restarts: 3,       # Only retry 3 times...
      max_seconds: 5         # ...in 5 seconds
    )
  end
end
```

**Hierarchy**:
```
Application
├── ErrorKernel (MUST survive)
│   ├── Database (max 10 restarts/60s)
│   ├── AuditLog
│   └── Authentication
└── ApplicationLayer (can crash)
    ├── PluginHost (max 3 restarts/5s)
    └── FHIRProcessor
```

---

## Circuit Breaker Pattern

**Use Case**: Prevent cascading failures when external service (e.g., FHIR server) is down.

```elixir
defmodule Healthcare.CircuitBreaker do
  use GenServer
  require Logger
  
  @failure_threshold 5
  @timeout_ms 30_000
  
  defstruct [
    :state,         # :closed | :open | :half_open
    :failure_count,
    :last_failure_time
  ]
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    {:ok, %__MODULE__{state: :closed, failure_count: 0, last_failure_time: nil}}
  end
  
  def call_external_service(service_name, request) do
    GenServer.call(__MODULE__, {:call, service_name, request})
  end
  
  @impl true
  def handle_call({:call, service_name, request}, _from, state) do
    case state.state do
      :closed ->
        # Normal operation - try request
        case do_request(service_name, request) do
          {:ok, response} ->
            {:reply, {:ok, response}, reset_state(state)}
          
          {:error, reason} ->
            new_state = record_failure(state)
            {:reply, {:error, reason}, new_state}
        end
      
      :open ->
        # Circuit open - check if timeout elapsed
        if timeout_elapsed?(state) do
          # Try half-open (test request)
          new_state = %{state | state: :half_open}
          handle_call({:call, service_name, request}, self(), new_state)
        else
          # Still open - fail fast
          {:reply, {:error, :circuit_open}, state}
        end
      
      :half_open ->
        # Test request in half-open state
        case do_request(service_name, request) do
          {:ok, response} ->
            Logger.info("Circuit breaker closed: #{service_name}")
            {:reply, {:ok, response}, reset_state(state)}
          
          {:error, reason} ->
            Logger.warning("Circuit breaker reopened: #{service_name}")
            new_state = %{state | state: :open, last_failure_time: System.monotonic_time(:millisecond)}
            {:reply, {:error, reason}, new_state}
        end
    end
  end
  
  defp do_request(service_name, request) do
    # Simulate external call (with timeout)
    try do
      HTTPoison.post("https://#{service_name}/api", Jason.encode!(request), [], recv_timeout: 5000)
    rescue
      error -> {:error, error}
    catch
      :exit, reason -> {:error, reason}
    end
  end
  
  defp record_failure(state) do
    new_failure_count = state.failure_count + 1
    
    if new_failure_count >= @failure_threshold do
      Logger.error("Circuit breaker opened (#{new_failure_count} failures)")
      %{state | state: :open, failure_count: 0, last_failure_time: System.monotonic_time(:millisecond)}
    else
      %{state | failure_count: new_failure_count}
    end
  end
  
  defp reset_state(state) do
    %{state | state: :closed, failure_count: 0, last_failure_time: nil}
  end
  
  defp timeout_elapsed?(state) do
    now = System.monotonic_time(:millisecond)
    (now - state.last_failure_time) > @timeout_ms
  end
end

# Usage
case Healthcare.CircuitBreaker.call_external_service("fhir-server.example.com", patient_query) do
  {:ok, response} ->
    process_fhir_response(response)
  
  {:error, :circuit_open} ->
    Logger.warning("FHIR server unavailable, using cached data")
    fallback_to_cache()
  
  {:error, reason} ->
    Logger.error("FHIR request failed: #{inspect(reason)}")
    {:error, reason}
end
```

---

## Bulkhead Pattern

**Principle**: Isolate resource pools to prevent one subsystem from consuming all resources.

```elixir
defmodule Healthcare.Application do
  use Application
  
  def start(_type, _args) do
    children = [
      # Separate connection pools (bulkheads)
      {Healthcare.Repo, pool_size: 20, name: :main_pool},
      {Healthcare.Repo, pool_size: 5, name: :analytics_pool},    # Analytics queries isolated
      {Healthcare.Repo, pool_size: 5, name: :reporting_pool},    # Reports isolated
      
      # Separate Task.Supervisor pools
      {Task.Supervisor, name: Healthcare.CriticalTasks, max_children: 100},
      {Task.Supervisor, name: Healthcare.BackgroundTasks, max_children: 1000}
    ]
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

**Benefit**: If analytics queries overload their pool (5 connections), main application still has 20 connections available.

---

## Observability: Failure Metrics

### Telemetry Integration

```elixir
defmodule Healthcare.FailureMetrics do
  require Logger
  
  def setup do
    # Attach to supervisor events
    :telemetry.attach_many(
      "failure-metrics",
      [
        [:supervisor, :child_terminated],
        [:task, :exception]
      ],
      &__MODULE__.handle_event/4,
      nil
    )
  end
  
  def handle_event([:supervisor, :child_terminated], _measurements, metadata, _config) do
    if metadata.reason != :normal do
      # Emit Prometheus counter
      :telemetry.execute(
        [:healthcare, :process, :crash],
        %{count: 1},
        %{
          supervisor: metadata.supervisor,
          child_id: metadata.child_id,
          reason: metadata.reason
        }
      )
      
      Logger.error("Process crash: #{inspect(metadata)}")
      
      # HIPAA/LGPD audit trail
      Healthcare.AuditLog.write(%{
        event: "process_crash",
        supervisor: metadata.supervisor,
        child: metadata.child_id,
        reason: metadata.reason,
        timestamp: DateTime.utc_now(),
        compliance_tag: "HIPAA_164_308_LGPD_Art_46"
      })
    end
  end
  
  def handle_event([:task, :exception], _measurements, metadata, _config) do
    :telemetry.execute(
      [:healthcare, :task, :exception],
      %{count: 1},
      %{
        kind: metadata.kind,
        reason: metadata.reason,
        stacktrace: metadata.stacktrace
      }
    )
    
    Logger.error("Task exception: #{inspect(metadata)}")
  end
end
```

---

## Healthcare Compliance: Fault Logging

**Requirement**: HIPAA 164.308(a)(1)(ii)(D) requires incident response procedures.

```elixir
defmodule Healthcare.IncidentResponse do
  use GenServer
  require Logger
  
  @critical_failure_threshold 10  # 10 crashes in 5 minutes = critical incident
  @time_window_ms 300_000  # 5 minutes
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  
  @impl true
  def init(_) do
    Healthcare.FailureMetrics.setup()
    
    # Subscribe to crash events
    :telemetry.attach(
      "incident-response",
      [:healthcare, :process, :crash],
      &__MODULE__.handle_crash/4,
      nil
    )
    
    {:ok, %{crash_timestamps: []}}
  end
  
  def handle_crash(_event_name, _measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:crash_detected, metadata, System.monotonic_time(:millisecond)})
  end
  
  @impl true
  def handle_cast({:crash_detected, metadata, timestamp}, state) do
    # Add crash to window
    new_timestamps = [timestamp | state.crash_timestamps]
    
    # Remove crashes outside time window
    cutoff = timestamp - @time_window_ms
    recent_crashes = Enum.filter(new_timestamps, fn ts -> ts > cutoff end)
    
    # Check if critical incident
    if length(recent_crashes) >= @critical_failure_threshold do
      trigger_critical_incident_response(metadata, recent_crashes)
    end
    
    {:noreply, %{state | crash_timestamps: recent_crashes}}
  end
  
  defp trigger_critical_incident_response(metadata, crash_timestamps) do
    Logger.critical("CRITICAL INCIDENT: #{length(crash_timestamps)} crashes in 5 minutes")
    
    # HIPAA-required actions:
    # 1. Log incident
    Healthcare.AuditLog.write(%{
      event: "critical_incident",
      crash_count: length(crash_timestamps),
      metadata: metadata,
      timestamp: DateTime.utc_now(),
      compliance_tag: "HIPAA_164_308_a_1_ii_D"
    })
    
    # 2. Notify on-call engineer
    Healthcare.Alerting.page_oncall("Critical incident: multiple process crashes")
    
    # 3. Escalate to management
    Healthcare.Alerting.notify_management("System instability detected")
    
    # 4. Auto-remediation (optional)
    # Healthcare.Application.restart_application()
  end
end
```

---

## References

### Official Documentation
- [Erlang Fault Tolerance](https://www.erlang.org/doc/reference_manual/processes.html) (L0_CANONICAL)
- [Elixir Process Documentation](https://hexdocs.pm/elixir/Process.html) (L0_CANONICAL)
- [OTP Design Principles: Fault Tolerance](https://www.erlang.org/doc/design_principles/des_princ.html) (L0_CANONICAL)

### Books
- [Designing for Scalability with Erlang/OTP](https://www.oreilly.com/library/view/designing-for-scalability/9781449361556/) (L2_VALIDATED)
  - Chapter 5: "Process Design Patterns"
- [Release It! (2nd Edition)](https://pragprog.com/titles/mnee2/release-it-second-edition/) (L2_VALIDATED)
  - Circuit Breaker pattern, Bulkhead pattern

### Academic Papers
- [Making Reliable Distributed Systems in the Presence of Software Errors](http://erlang.org/download/armstrong_thesis_2003.pdf) - Joe Armstrong PhD Thesis (L1_ACADEMIC)

### Industry Reports
- [Ericsson AXD 301: 99.9999999% Uptime](https://www.ericsson.com/en/reports-and-papers/white-papers/high-availability-in-atm-networks) (L2_VALIDATED)

---

**DSM**: [L1:infrastructure | L2:healthcare | L3:architecture | L4:guide]
**Source**: `01-elixir-wasm-host-platform.md` (fault tolerance sections)
**Version**: 1.0.0
**Related**:
- [Supervision Trees](./supervision-trees.md)
- [Distributed Erlang](./distributed-erlang.md)
- [ADR 001: Elixir Host Choice](../../01-ARCHITECTURE/adrs/001-elixir-host-choice.md)
