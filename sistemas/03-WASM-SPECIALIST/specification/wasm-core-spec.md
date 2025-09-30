# WebAssembly Core Specification

**Specification**: WebAssembly 2.0 (W3C Recommendation)
**Runtime**: Wasmtime 25.0.3
**Healthcare Context**: Sandboxed medical algorithm execution
**Last Updated**: 2025-09-30

---

## Overview

**WebAssembly (WASM)** is a binary instruction format for a stack-based virtual machine, designed as a portable compilation target for high-level languages.

**Key Properties**:
- **Fast**: Near-native performance (typically 5-10% overhead)
- **Safe**: Memory-safe, sandboxed execution (capability-based security)
- **Portable**: Runs on any platform with a WASM runtime
- **Compact**: Binary format smaller than equivalent JavaScript

**Healthcare Use Case**: Execute untrusted medical algorithms (FHIR validators, clinical calculators, drug interaction checkers) in isolated sandbox.

---

## Core Concepts

### 1. Module Structure

WASM modules are binary files (.wasm) containing:

```wasm
(module
  ;; Imports (functions from host)
  (import "env" "log" (func $log (param i32)))
  
  ;; Memory (linear memory, byte-addressable)
  (memory (export "memory") 1)  ;; 1 page = 64KB
  
  ;; Functions
  (func $calculate_bmi (param $weight f32) (param $height f32) (result f32)
    local.get $weight
    local.get $height
    local.get $height
    f32.mul
    f32.div
  )
  
  ;; Exports (functions exposed to host)
  (export "calculate_bmi" (func $calculate_bmi))
)
```

**Binary Format** (actual .wasm file):
```
00 61 73 6D  ; Magic number '\0asm'
01 00 00 00  ; Version 1
...
```

### 2. Value Types

| Type | Description | Size | Range |
|------|-------------|------|-------|
| `i32` | 32-bit integer | 4 bytes | -2³¹ to 2³¹-1 |
| `i64` | 64-bit integer | 8 bytes | -2⁶³ to 2⁶³-1 |
| `f32` | 32-bit float | 4 bytes | IEEE 754 single |
| `f64` | 64-bit float | 8 bytes | IEEE 754 double |
| `v128` | 128-bit SIMD | 16 bytes | (WASM 2.0) |
| `funcref` | Function reference | - | (reference type) |
| `externref` | External reference | - | (reference type) |

**Healthcare Example**: Use `f32` for vital signs (heart rate, temperature), `i64` for timestamps.

---

## Linear Memory

### Memory Model

```wasm
(memory (export "memory") 2 10)
;; Initial: 2 pages (128KB)
;; Maximum: 10 pages (640KB)
```

**Page Size**: 64KB (65,536 bytes)

**Growth**: `memory.grow` instruction to allocate more pages at runtime.

### Memory Safety

```wasm
(func $write_patient_data (param $offset i32) (param $value i32)
  local.get $offset
  local.get $value
  i32.store  ;; Write 4 bytes at offset
)
```

**Trap Conditions** (runtime error, execution halted):
- Out-of-bounds memory access
- Division by zero
- Integer overflow (wraps, doesn't trap)
- Unreachable instruction

**Healthcare Safety**: Plugin cannot access host memory - all data must be explicitly passed via imports/exports.

---

## Instructions

### Arithmetic

```wasm
;; Integer arithmetic
i32.add    ;; a + b
i32.sub    ;; a - b
i32.mul    ;; a * b
i32.div_s  ;; a / b (signed)
i32.div_u  ;; a / b (unsigned)
i32.rem_s  ;; a % b (signed)

;; Float arithmetic
f32.add
f32.sub
f32.mul
f32.div
f32.sqrt
f32.min
f32.max
```

### Control Flow

```wasm
;; Conditional
(if (result i32)
  (i32.gt_s (local.get $age) (i32.const 65))
  (then (i32.const 1))  ;; Senior
  (else (i32.const 0))  ;; Adult
)

;; Loop
(block $exit
  (loop $continue
    ;; Loop body
    (br_if $exit (local.get $done))
    (br $continue)
  )
)
```

### Memory Operations

```wasm
i32.load      ;; Load 4 bytes from memory
i32.load8_s   ;; Load 1 byte (sign-extend)
i32.load16_u  ;; Load 2 bytes (zero-extend)

i32.store     ;; Store 4 bytes to memory
i32.store8    ;; Store 1 byte
i32.store16   ;; Store 2 bytes
```

---

## Healthcare Example: BMI Calculator

### WebAssembly Text (WAT)

```wasm
(module
  ;; Memory for string data
  (memory (export "memory") 1)
  
  ;; Calculate BMI
  (func $calculate_bmi (param $weight f32) (param $height f32) (result f32)
    ;; BMI = weight / (height * height)
    local.get $weight
    local.get $height
    local.get $height
    f32.mul
    f32.div
  )
  
  ;; Classify BMI (WHO criteria)
  (func $classify_bmi (param $bmi f32) (result i32)
    ;; Returns: 0=underweight, 1=normal, 2=overweight, 3=obese
    (if (result i32)
      (f32.lt (local.get $bmi) (f32.const 18.5))
      (then (i32.const 0))
      (else
        (if (result i32)
          (f32.lt (local.get $bmi) (f32.const 25.0))
          (then (i32.const 1))
          (else
            (if (result i32)
              (f32.lt (local.get $bmi) (f32.const 30.0))
              (then (i32.const 2))
              (else (i32.const 3))
            )
          )
        )
      )
    )
  )
  
  ;; Export functions
  (export "calculate_bmi" (func $calculate_bmi))
  (export "classify_bmi" (func $classify_bmi))
)
```

### Compile to Binary

```bash
# Using wat2wasm (WABT - WebAssembly Binary Toolkit)
wat2wasm bmi_calculator.wat -o bmi_calculator.wasm

# Inspect binary
wasm-objdump -x bmi_calculator.wasm
```

### Call from Elixir (Wasmex)

```elixir
defmodule Healthcare.BMICalculator do
  def calculate_and_classify(weight_kg, height_m) do
    wasm_bytes = File.read!("priv/wasm/bmi_calculator.wasm")
    
    {:ok, instance} = Wasmex.start_link(%{bytes: wasm_bytes})
    
    # Calculate BMI
    {:ok, [bmi]} = Wasmex.call_function(instance, "calculate_bmi", [weight_kg, height_m])
    
    # Classify
    {:ok, [classification]} = Wasmex.call_function(instance, "classify_bmi", [bmi])
    
    category = case classification do
      0 -> "Underweight"
      1 -> "Normal"
      2 -> "Overweight"
      3 -> "Obese"
    end
    
    %{bmi: Float.round(bmi, 2), category: category}
  end
end

# Usage
Healthcare.BMICalculator.calculate_and_classify(70.0, 1.75)
# %{bmi: 22.86, category: "Normal"}
```

---

## WASM 2.0 Features

### 1. Reference Types

```wasm
(type $patient_handler (func (param externref) (result i32)))

(func $process_patient (param $patient externref)
  ;; externref holds opaque host object (Elixir struct)
  local.get $patient
  call $validate_patient
)
```

**Use Case**: Pass Elixir Patient struct directly to WASM without serialization.

### 2. Multi-Value Returns

```wasm
(func $get_blood_pressure (result i32 i32)
  ;; Returns (systolic, diastolic)
  i32.const 120
  i32.const 80
)
```

### 3. Bulk Memory Operations

```wasm
;; Copy memory region (fast memcpy)
memory.copy $dest $src $len

;; Fill memory region (fast memset)
memory.fill $dest $value $len
```

### 4. SIMD (Single Instruction, Multiple Data)

```wasm
;; Process 4 floats simultaneously
v128.load $addr
v128.const f32x4 0.5 0.5 0.5 0.5
f32x4.mul
v128.store $result_addr
```

**Healthcare Use Case**: Vectorized medical image processing (DICOM).

---

## Security Model

### Capability-Based Security

**No Ambient Authority**: WASM module cannot access:
- File system
- Network
- Environment variables
- System calls

**Explicit Grants**: Host must provide imports for each capability.

```elixir
defmodule Healthcare.SecurePluginHost do
  def run_plugin_with_limited_access(wasm_binary, patient_id) do
    # Define allowed host functions
    imports = %{
      env: %{
        # Allow: Read patient data
        get_patient: fn ->
          patient = Healthcare.Patients.get_patient!(patient_id)
          Jason.encode!(patient)
        end,
        
        # Deny: Write operations (commented out)
        # update_patient: fn data -> ... end
      }
    }
    
    {:ok, instance} = Wasmex.start_link(%{bytes: wasm_binary, imports: imports})
    
    # Plugin can only call get_patient, nothing else
    Wasmex.call_function(instance, "analyze_patient", [])
  end
end
```

### Resource Limits

```elixir
# Extism configuration
plugin_config = %{
  wasm: wasm_binary,
  allowed_hosts: [],  # No network access
  config: %{
    "max_memory_bytes" => 50_000_000,  # 50MB limit
    "timeout_ms" => 5000                # 5 second timeout
  }
}

{:ok, plugin} = Extism.Plugin.new(plugin_config)
```

**Trap on Violation**: Plugin execution halted if limits exceeded.

---

## Performance Characteristics

### Benchmark: WASM vs Native (Healthcare Algorithms)

**Methodology**: Calculate Framingham Risk Score for 100,000 patients.

```yaml
Native Rust (no sandbox): 125ms (baseline)
WASM (Wasmtime): 132ms (+5.6% overhead)
WASM (cold start): +42ms instantiation

Memory:
  Native: 8MB
  WASM: 12MB (+50% due to sandbox)

Verdict: Acceptable overhead for security benefits
```

### Compilation Strategies

| Strategy | Compile Time | Runtime Speed | Use Case |
|----------|--------------|---------------|----------|
| **Interpreter** | 0ms | Slow (10x) | Untested plugins |
| **Baseline JIT** | 50ms | Fast (1.5x) | Development |
| **Optimizing JIT** | 500ms | Near-native (1.05x) | Production |
| **AOT (Wizer)** | 2000ms | Near-native (1.02x) | Frequently-used |

**Healthcare Strategy**: Use optimizing JIT for production FHIR validators.

---

## WASM Ecosystem Tools

### Development Tools

```bash
# WABT (WebAssembly Binary Toolkit)
wat2wasm bmi.wat -o bmi.wasm      # Text to binary
wasm2wat bmi.wasm -o bmi.wat      # Binary to text
wasm-objdump -x bmi.wasm          # Inspect sections
wasm-validate bmi.wasm            # Validate spec compliance

# Binaryen (optimizer)
wasm-opt -O3 bmi.wasm -o bmi_opt.wasm
wasm-opt --strip-debug bmi.wasm   # Remove debug info

# Wasmtime (runtime)
wasmtime run bmi.wasm --invoke calculate_bmi -- 70.0 1.75
```

### Language Support

| Language | Maturity | Toolchain | Healthcare Use Case |
|----------|----------|-----------|---------------------|
| **Rust** | Excellent | wasm32-unknown-unknown | Drug interaction checker |
| **Go** | Good | TinyGo | FHIR validator |
| **C/C++** | Excellent | Emscripten | Legacy medical algorithms |
| **AssemblyScript** | Good | asc | Simple calculators |
| **Zig** | Good | zig build-lib | Performance-critical |

---

## Debugging WASM

### Source Maps

```bash
# Compile with debug info
rustc --target wasm32-unknown-unknown -g src/lib.rs

# Generate source map
wasm-sourcemap bmi.wasm -o bmi.wasm.map
```

### Logging from WASM

```wasm
(import "env" "log" (func $log (param i32 i32)))

(func $debug_print
  ;; Write string to memory
  i32.const 0      ;; Offset
  i32.const 100    ;; Length
  call $log
)
```

**Elixir Host**:
```elixir
imports = %{
  env: %{
    log: fn offset, length ->
      {:ok, memory} = Wasmex.memory(instance, :uint8, offset, length)
      IO.puts("WASM LOG: #{memory}")
    end
  }
}
```

---

## Limitations

### Current Constraints

1. **No Threads** (yet): Multi-threading proposal in progress
2. **No Direct I/O**: Must go through host imports
3. **No Exceptions**: Use error codes or result types
4. **GC Proposal**: Garbage collection support experimental

### Workarounds

```elixir
# Multi-threading: Run multiple WASM instances in parallel
tasks = Enum.map(1..10, fn i ->
  Task.async(fn ->
    {:ok, plugin} = Extism.Plugin.new(wasm_binary)
    Extism.call(plugin, "process_batch", Jason.encode!(%{batch: i}))
  end)
end)

results = Task.await_many(tasks)
```

---

## References

### Official Specifications
- [WebAssembly Core Specification 2.0](https://www.w3.org/TR/wasm-core-2/) (L0_CANONICAL)
- [WebAssembly Reference Manual](https://webassembly.github.io/spec/core/) (L0_CANONICAL)
- [WASI (WebAssembly System Interface)](https://wasi.dev/) (L0_CANONICAL)

### Tools
- [WABT (WebAssembly Binary Toolkit)](https://github.com/WebAssembly/wabt) (L0_CANONICAL)
- [Wasmtime](https://wasmtime.dev/) (L0_CANONICAL)

### Books
- [WebAssembly: The Definitive Guide](https://www.oreilly.com/library/view/webassembly-the-definitive/9781492089834/) (L2_VALIDATED)

---

**DSM**: [L1:infrastructure | L2:healthcare | L3:architecture | L4:reference]
**Source**: `02-webassembly-plugins-healthcare.md` (WASM core sections)
**Version**: 1.0.0
**Related**:
- [Component Model](./component-model.md)
- [Extism Plugin Development](../extism-platform/plugin-development.md)
- [ADR 002: WASM Plugin Isolation](../../01-ARCHITECTURE/adrs/002-wasm-plugin-isolation.md)
