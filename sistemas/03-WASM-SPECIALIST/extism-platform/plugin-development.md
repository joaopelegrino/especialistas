# Extism Plugin Development for Healthcare

**Framework**: Extism SDK 1.5.4
**Runtime**: Wasmtime 25.0.3
**Healthcare Context**: Medical algorithm plugins with host function integration
**Last Updated**: 2025-09-30

---

## Overview

**Extism** is a universal plugin system using WebAssembly, designed for embedding untrusted code in production applications.

**Key Features**:
- **Cross-language**: Plugins in Rust/Go/C, host in Elixir
- **Sandboxed**: No network, no file system, no arbitrary memory access
- **Host functions**: Controlled capabilities (database, encryption)
- **Resource limits**: Memory, CPU, timeout enforcement
- **Hot reload**: Update plugins without restarting application

**Healthcare Use Case**: Run third-party medical algorithms (FHIR validators, clinical calculators, imaging processors) safely in production.

---

## Architecture

### Plugin Lifecycle

```
┌─────────────────┐
│  Elixir Host    │
│  (Healthcare    │
│   Application)  │
└────────┬────────┘
         │
         │ 1. Load .wasm
         ▼
┌─────────────────┐
│  Extism SDK     │◄─── Configuration (memory limits, timeout)
│  (Elixir)       │
└────────┬────────┘
         │
         │ 2. Instantiate
         ▼
┌─────────────────┐
│  Wasmtime       │◄─── Host functions (get_patient, log, etc.)
│  (WASM runtime) │
└────────┬────────┘
         │
         │ 3. Execute
         ▼
┌─────────────────┐
│  WASM Plugin    │◄─── Isolated execution (no direct access)
│  (Rust/Go/C)    │
└─────────────────┘
         │
         │ 4. Return result
         ▼
┌─────────────────┐
│  Elixir Host    │
└─────────────────┘
```

---

## Elixir Host Setup

### Installation

```elixir
# mix.exs
defp deps do
  [
    {:extism, "~> 1.2"}
  ]
end
```

### Basic Plugin Execution

```elixir
defmodule Healthcare.PluginHost do
  def execute_plugin(wasm_path, function_name, input_data) do
    # Read WASM binary
    wasm_binary = File.read!(wasm_path)
    
    # Configure plugin
    manifest = %{
      wasm: [%{data: wasm_binary}],
      allowed_hosts: [],  # No network access
      config: %{
        "max_memory_bytes" => "50000000",  # 50MB limit
        "timeout_ms" => "5000"              # 5 second timeout
      }
    }
    
    # Create plugin instance
    {:ok, plugin} = Extism.Plugin.new(manifest)
    
    # Call function
    case Extism.Plugin.call(plugin, function_name, input_data) do
      {:ok, output} ->
        {:ok, output}
      
      {:error, reason} ->
        {:error, {:plugin_error, reason}}
    end
  end
end

# Usage
input = Jason.encode!(%{patient_id: "12345", cpf: "12345678901"})
{:ok, result} = Healthcare.PluginHost.execute_plugin(
  "priv/wasm/cpf_validator.wasm",
  "validate",
  input
)
```

---

## Host Functions

### Providing Capabilities to Plugins

**Scenario**: Plugin needs to read patient data from database (controlled access).

#### 1. Define Host Functions (Elixir)

```elixir
defmodule Healthcare.PluginHostFunctions do
  @moduledoc """
  Host functions exposed to WASM plugins.
  
  SECURITY: Each function must validate permissions before executing.
  """
  
  def get_patient(plugin, patient_id_json) do
    # Decode input
    %{"patient_id" => patient_id} = Jason.decode!(patient_id_json)
    
    # Authorization check
    plugin_id = Extism.Plugin.id(plugin)
    
    unless authorized?(plugin_id, patient_id) do
      error = Jason.encode!(%{error: "Unauthorized access to patient #{patient_id}"})
      return_error(plugin, error)
    end
    
    # Fetch patient (if authorized)
    case Healthcare.Patients.get_patient(patient_id) do
      {:ok, patient} ->
        patient_json = Jason.encode!(patient)
        Extism.Plugin.return_string(plugin, patient_json)
      
      {:error, :not_found} ->
        error = Jason.encode!(%{error: "Patient not found"})
        return_error(plugin, error)
    end
  end
  
  def log_event(plugin, event_json) do
    # Audit logging (LGPD Art. 46, HIPAA 164.312(b))
    event = Jason.decode!(event_json)
    plugin_id = Extism.Plugin.id(plugin)
    
    Healthcare.AuditLog.write(%{
      event: "plugin_log",
      plugin_id: plugin_id,
      message: event["message"],
      level: event["level"],
      timestamp: DateTime.utc_now(),
      compliance_tag: "LGPD_Art_46_HIPAA_164_312_b"
    })
    
    # Return success
    Extism.Plugin.return_string(plugin, "logged")
  end
  
  def encrypt_phi(plugin, phi_json) do
    # Encrypt PHI/PII before storage
    %{"data" => data} = Jason.decode!(phi_json)
    
    encrypted = Healthcare.Crypto.encrypt(data)
    
    result = Jason.encode!(%{encrypted: Base.encode64(encrypted)})
    Extism.Plugin.return_string(plugin, result)
  end
  
  defp authorized?(plugin_id, patient_id) do
    # Check plugin permissions in database
    Healthcare.PluginPermissions.can_access?(plugin_id, patient_id)
  end
  
  defp return_error(plugin, error_json) do
    Extism.Plugin.return_error(plugin, error_json)
  end
end
```

#### 2. Register Host Functions

```elixir
defmodule Healthcare.PluginHost do
  def create_plugin_with_host_functions(wasm_binary, allowed_functions \\ :all) do
    # Define all available host functions
    all_host_functions = %{
      "get_patient" => &Healthcare.PluginHostFunctions.get_patient/2,
      "log_event" => &Healthcare.PluginHostFunctions.log_event/2,
      "encrypt_phi" => &Healthcare.PluginHostFunctions.encrypt_phi/2
    }
    
    # Filter to allowed functions (principle of least privilege)
    host_functions = case allowed_functions do
      :all -> all_host_functions
      list when is_list(list) -> Map.take(all_host_functions, list)
    end
    
    manifest = %{
      wasm: [%{data: wasm_binary}],
      allowed_hosts: [],
      config: %{
        "max_memory_bytes" => "50000000",
        "timeout_ms" => "5000"
      }
    }
    
    {:ok, plugin} = Extism.Plugin.new(manifest, host_functions: host_functions)
    {:ok, plugin}
  end
end

# Usage: Plugin only gets log_event capability
{:ok, limited_plugin} = Healthcare.PluginHost.create_plugin_with_host_functions(
  wasm_binary,
  ["log_event"]  # Cannot call get_patient or encrypt_phi
)
```

---

## Plugin Development (Rust)

### PDK (Plugin Development Kit)

```toml
# Cargo.toml
[package]
name = "fhir-validator"
version = "1.0.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
extism-pdk = "1.2"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

### Plugin Implementation

```rust
// src/lib.rs
use extism_pdk::*;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct ValidateRequest {
    patient_id: String,
    cpf: String,
}

#[derive(Serialize)]
struct ValidateResponse {
    valid: bool,
    errors: Vec<String>,
}

#[plugin_fn]
pub fn validate(input: String) -> FnResult<String> {
    // Parse input
    let req: ValidateRequest = serde_json::from_str(&input)?;
    
    // Log to host (via host function)
    log_event(&format!("Validating patient {}", req.patient_id), "info")?;
    
    let mut errors = Vec::new();
    
    // Validate CPF (11 digits)
    if req.cpf.len() != 11 || !req.cpf.chars().all(|c| c.is_numeric()) {
        errors.push("CPF must be 11 digits".to_string());
    }
    
    // Get patient data from host
    match get_patient(&req.patient_id) {
        Ok(patient) => {
            // Validate patient data
            if patient.name.is_empty() {
                errors.push("Patient name is required".to_string());
            }
        }
        Err(e) => {
            errors.push(format!("Failed to fetch patient: {}", e));
        }
    }
    
    // Return result
    let response = ValidateResponse {
        valid: errors.is_empty(),
        errors,
    };
    
    Ok(serde_json::to_string(&response)?)
}

// Host function imports
#[host_fn]
extern "ExtismHost" {
    fn log_event(message: &str, level: &str) -> Result<(), Error>;
    fn get_patient(patient_id: &str) -> Result<Patient, Error>;
}

#[derive(Deserialize)]
struct Patient {
    id: String,
    name: String,
    cpf: String,
    birth_date: String,
}

// Helper to call host function
fn log_event(message: &str, level: &str) -> FnResult<()> {
    let event = serde_json::json!({
        "message": message,
        "level": level
    });
    
    unsafe {
        let result = host_fn_log_event(event.to_string().as_bytes())?;
        Ok(())
    }
}

fn get_patient(patient_id: &str) -> FnResult<Patient> {
    let request = serde_json::json!({"patient_id": patient_id});
    
    unsafe {
        let response = host_fn_get_patient(request.to_string().as_bytes())?;
        let patient: Patient = serde_json::from_slice(&response)?;
        Ok(patient)
    }
}
```

### Build Plugin

```bash
# Compile to WASM
cargo build --target wasm32-unknown-unknown --release

# Optimize (reduce size by 50-80%)
wasm-opt -O3 \
  target/wasm32-unknown-unknown/release/fhir_validator.wasm \
  -o priv/wasm/fhir_validator_opt.wasm

# Strip debug symbols
wasm-strip priv/wasm/fhir_validator_opt.wasm
```

---

## Advanced Patterns

### 1. Plugin Hot Reload

```elixir
defmodule Healthcare.PluginRegistry do
  use GenServer
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  
  @impl true
  def init(_) do
    # Watch plugin directory for changes
    :fs.start_link(:fs_watcher, Path.absname("priv/wasm"))
    :fs.subscribe(:fs_watcher)
    
    {:ok, %{plugins: %{}}}
  end
  
  def reload_plugin(plugin_id) do
    GenServer.call(__MODULE__, {:reload, plugin_id})
  end
  
  @impl true
  def handle_info({:fs, :file_event}, {path, [:modified, :closed]}, state) do
    # Plugin file changed - reload
    plugin_id = Path.basename(path, ".wasm")
    
    Logger.info("Reloading plugin: #{plugin_id}")
    
    # Unload old plugin
    if old_plugin = state.plugins[plugin_id] do
      Extism.Plugin.free(old_plugin)
    end
    
    # Load new plugin
    wasm_binary = File.read!(path)
    {:ok, new_plugin} = Healthcare.PluginHost.create_plugin_with_host_functions(wasm_binary)
    
    new_state = put_in(state.plugins[plugin_id], new_plugin)
    
    {:noreply, new_state}
  end
end
```

### 2. Plugin Versioning

```elixir
defmodule Healthcare.PluginVersioning do
  def load_plugin_version(plugin_name, version) do
    wasm_path = "priv/wasm/#{plugin_name}_#{version}.wasm"
    
    case File.read(wasm_path) do
      {:ok, wasm_binary} ->
        Healthcare.PluginHost.create_plugin_with_host_functions(wasm_binary)
      
      {:error, :enoent} ->
        {:error, :version_not_found}
    end
  end
  
  def upgrade_plugin(current_plugin_pid, new_version) do
    # Drain in-flight requests
    :sys.suspend(current_plugin_pid)
    
    # Load new version
    {:ok, new_plugin} = load_plugin_version("fhir_validator", new_version)
    
    # Swap plugins (zero-downtime upgrade)
    Healthcare.PluginRegistry.update_plugin(new_plugin)
    
    # Free old plugin
    Extism.Plugin.free(current_plugin_pid)
    
    {:ok, new_plugin}
  end
end
```

### 3. Plugin Pooling (Performance)

```elixir
defmodule Healthcare.PluginPool do
  use GenServer
  
  @pool_size 10
  
  def start_link(wasm_binary) do
    GenServer.start_link(__MODULE__, wasm_binary, name: __MODULE__)
  end
  
  @impl true
  def init(wasm_binary) do
    # Pre-instantiate plugin pool
    plugins = Enum.map(1..@pool_size, fn _ ->
      {:ok, plugin} = Healthcare.PluginHost.create_plugin_with_host_functions(wasm_binary)
      plugin
    end)
    
    {:ok, %{plugins: plugins, available: plugins, in_use: []}}
  end
  
  def call_plugin(function_name, input) do
    GenServer.call(__MODULE__, {:call, function_name, input})
  end
  
  @impl true
  def handle_call({:call, function_name, input}, from, state) do
    case state.available do
      [plugin | rest_available] ->
        # Execute in background
        Task.start(fn ->
          result = Extism.Plugin.call(plugin, function_name, input)
          GenServer.cast(__MODULE__, {:return_plugin, plugin})
          GenServer.reply(from, result)
        end)
        
        new_state = %{
          state
          | available: rest_available,
            in_use: [plugin | state.in_use]
        }
        
        {:noreply, new_state}
      
      [] ->
        # Pool exhausted - queue request
        {:reply, {:error, :pool_exhausted}, state}
    end
  end
  
  @impl true
  def handle_cast({:return_plugin, plugin}, state) do
    new_state = %{
      state
      | available: [plugin | state.available],
        in_use: List.delete(state.in_use, plugin)
    }
    
    {:noreply, new_state}
  end
end
```

---

## Error Handling & Observability

### Plugin Error Handling

```elixir
defmodule Healthcare.PluginExecutor do
  require Logger
  
  def safe_execute(plugin, function_name, input) do
    start_time = System.monotonic_time(:microsecond)
    
    result = try do
      case Extism.Plugin.call(plugin, function_name, input) do
        {:ok, output} ->
          {:ok, output}
        
        {:error, %{type: :timeout}} ->
          Logger.error("Plugin timeout: #{function_name}")
          {:error, :timeout}
        
        {:error, %{type: :out_of_memory}} ->
          Logger.error("Plugin OOM: #{function_name}")
          {:error, :out_of_memory}
        
        {:error, reason} ->
          Logger.error("Plugin error: #{inspect(reason)}")
          {:error, {:plugin_error, reason}}
      end
    rescue
      error ->
        Logger.error("Plugin crash: #{inspect(error)}")
        {:error, {:crash, error}}
    end
    
    # Emit telemetry
    duration = System.monotonic_time(:microsecond) - start_time
    
    :telemetry.execute(
      [:healthcare, :plugin, :call],
      %{duration: duration},
      %{function: function_name, result: elem(result, 0)}
    )
    
    result
  end
end
```

### Prometheus Metrics

```elixir
defmodule Healthcare.PluginMetrics do
  use Prometheus.Metric
  
  def setup do
    Counter.declare(
      name: :plugin_calls_total,
      help: "Total plugin calls",
      labels: [:plugin_id, :function, :result]
    )
    
    Histogram.declare(
      name: :plugin_duration_microseconds,
      help: "Plugin execution duration",
      labels: [:plugin_id, :function],
      buckets: [100, 500, 1_000, 5_000, 10_000, 50_000]
    )
    
    Counter.declare(
      name: :plugin_errors_total,
      help: "Plugin errors",
      labels: [:plugin_id, :error_type]
    )
    
    # Attach to telemetry
    :telemetry.attach(
      "plugin-metrics",
      [:healthcare, :plugin, :call],
      &__MODULE__.handle_event/4,
      nil
    )
  end
  
  def handle_event([:healthcare, :plugin, :call], measurements, metadata, _config) do
    Counter.inc(
      name: :plugin_calls_total,
      labels: [metadata.plugin_id, metadata.function, metadata.result]
    )
    
    Histogram.observe(
      [name: :plugin_duration_microseconds, labels: [metadata.plugin_id, metadata.function]],
      measurements.duration
    )
    
    if metadata.result == :error do
      Counter.inc(
        name: :plugin_errors_total,
        labels: [metadata.plugin_id, metadata.error_type]
      )
    end
  end
end
```

---

## Security Best Practices

### 1. Input Validation

```elixir
defmodule Healthcare.PluginSecurity do
  @max_input_size 10_000_000  # 10MB
  
  def validate_input(input) do
    cond do
      byte_size(input) > @max_input_size ->
        {:error, :input_too_large}
      
      not valid_json?(input) ->
        {:error, :invalid_json}
      
      contains_sql_injection?(input) ->
        {:error, :suspicious_input}
      
      true ->
        :ok
    end
  end
  
  defp valid_json?(input) do
    case Jason.decode(input) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
  
  defp contains_sql_injection?(input) do
    # Basic SQL injection detection
    Regex.match?(~r/(\bUNION\b|\bSELECT\b|\bDROP\b)/i, input)
  end
end
```

### 2. Resource Quotas

```elixir
defmodule Healthcare.PluginQuotas do
  use GenServer
  
  @calls_per_minute 1000
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  
  def check_quota(plugin_id) do
    GenServer.call(__MODULE__, {:check, plugin_id})
  end
  
  @impl true
  def init(_) do
    # Periodic cleanup
    :timer.send_interval(60_000, :reset_quotas)
    {:ok, %{quotas: %{}}}
  end
  
  @impl true
  def handle_call({:check, plugin_id}, _from, state) do
    current_count = Map.get(state.quotas, plugin_id, 0)
    
    if current_count < @calls_per_minute do
      new_state = put_in(state.quotas[plugin_id], current_count + 1)
      {:reply, :ok, new_state}
    else
      {:reply, {:error, :quota_exceeded}, state}
    end
  end
  
  @impl true
  def handle_info(:reset_quotas, _state) do
    {:noreply, %{quotas: %{}}}
  end
end
```

---

## References

### Official Documentation
- [Extism Documentation](https://extism.org/docs) (L0_CANONICAL)
- [Extism PDK (Rust)](https://github.com/extism/rust-pdk) (L0_CANONICAL)
- [Extism Elixir SDK](https://github.com/extism/elixir-sdk) (L0_CANONICAL)

### Examples
- [Extism Examples](https://github.com/extism/extism/tree/main/examples) (L2_VALIDATED)

---

**DSM**: [L1:infrastructure | L2:healthcare | L3:implementation | L4:guide]
**Source**: `02-webassembly-plugins-healthcare.md` (Extism sections)
**Version**: 1.0.0
**Related**:
- [WASM Core Specification](../specification/wasm-core-spec.md)
- [Rust WASM Development](../languages/rust-wasm.md)
- [ADR 002: WASM Plugin Isolation](../../01-ARCHITECTURE/adrs/002-wasm-plugin-isolation.md)
