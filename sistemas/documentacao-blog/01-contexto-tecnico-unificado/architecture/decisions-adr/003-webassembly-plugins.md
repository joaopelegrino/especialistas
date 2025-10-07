# ADR-003: WebAssembly Plugin System

**Status**: 🔄 Proposed
**Date**: 2025-09-27
**Deciders**: Tech Lead, Architecture Team
**Tags**: #extensibility #wasm #security #performance

---

## Context

Medical workflow engines (S.1.1 → S.4-1.1-3) require:

1. **Language flexibility**: Rust for performance, Go for concurrency, Python for AI/ML
2. **Sandboxed execution**: Untrusted partner code cannot access system resources
3. **Near-native performance**: <10% overhead vs native code
4. **Versioned updates**: Update workflows without redeploying host

Current: All workflows in Elixir → limits language choice, no sandboxing.

---

## Decision

**Use Extism SDK 1.5.4** for WebAssembly plugin system via Wasmtime 25.0.3.

**Architecture**:
```
Elixir Host (Phoenix)
    ↓ FFI (NIFs)
Extism SDK
    ↓ WebAssembly Interface
WASM Plugins (Rust/Go/C/AssemblyScript)
```

---

## Rationale

### 1. Security (Capability-Based)

WASI (WebAssembly System Interface):
- ✅ No ambient authority (explicit permissions)
- ✅ Sandboxed execution (no file/network access by default)
- ✅ Memory isolation (linear memory)
- ✅ Resource limits (CPU, memory quotas)

**Healthcare Benefit**: Partner plugins cannot exfiltrate PHI/PII.

### 2. Performance

**Benchmarks** (Healthcare Stack):
```yaml
Cold Start: 42ms (vs 850ms Docker) - 20x faster
Hot Execution: 5.8% overhead vs native
Memory: 2.44MB per plugin (vs 180MB Docker) - 74x efficient
```

### 3. Multi-Language Support

Extism supports:
- **Rust**: Performance-critical (LGPD analyzer)
- **Go**: Concurrent processing (API integrations)
- **C**: Legacy medical systems integration
- **AssemblyScript**: TypeScript-like for web developers

---

## Consequences

### Positive

✅ **Security**: Sandboxed, capability-based
✅ **Performance**: 20x faster cold start vs Docker
✅ **Efficiency**: 74x memory savings vs containers
✅ **Flexibility**: Multi-language plugins

### Negative

❌ **Rust Dependency**: Requires Rust toolchain (deployment blocker)
❌ **FFI Overhead**: 3.9μs per call (acceptable)
❌ **Debugging**: More complex than native code
❌ **WASI Limitations**: No threads yet (roadmap)

---

## Alternatives Considered

### Alt 1: Docker Containers

**Rejected**: 850ms cold start, 180MB memory per container → too slow/expensive for medical workflows.

### Alt 2: Native Dynamic Libraries (.so/.dylib)

**Rejected**: No sandboxing → security risk for untrusted partner code.

---

## Implementation

**Status**: 📋 Planned (Sprint 2+)
**Blocker**: Requires Rust toolchain in CI/CD

```elixir
# lib/healthcare_cms/workflows/plugin_manager.ex
defmodule HealthcareCMS.Workflows.PluginManager do
  def execute_plugin(name, input) do
    plugin = Extism.Plugin.new(name)
    Extism.call(plugin, "process", input)
  end
end
```

---

## References

- [Extism Docs](https://extism.org/) (L0_CANONICAL)
- [WASM Spec 2.0](https://webassembly.github.io/spec/core/) (L0_CANONICAL)
- [Benchmarks](../../../08-BENCHMARKS-RESEARCH/performance/wasm-overhead-measurements.md)

---

**Related ADRs**: ADR-001 (CPU-bound mitigation)
**Version**: 1.0.0 | **Created**: 2025-09-30
