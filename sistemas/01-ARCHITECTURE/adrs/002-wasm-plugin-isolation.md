# ADR 002: WebAssembly for Plugin Isolation

**Status**: Accepted
**Date**: 2025-09-30
**Tags**: [L1_DOMAIN:security | L3_TECHNICAL:architecture | LEVEL:expert]

---

## Decision

**Use WebAssembly (Extism 1.5.4) for sandboxed plugin execution.**

---

## Alternatives vs WASM

### Docker Containers
**Pros**: Mature ecosystem, full OS
**Cons**:
- Heavyweight (50MB+ vs 1MB WASM)
- Slow startup (seconds vs <50ms)
- Complex orchestration

**Benchmark**:
```
Cold start: Docker 3-5s vs WASM 50ms (60x faster)
Memory: Docker 50MB vs WASM 5MB (10x lighter)
```

### Native Plugins (.so/.dll)
**Pros**: Maximum performance, no overhead
**Cons**:
- ❌ **Security risk**: Can access all system resources
- ❌ **No isolation**: Plugin crash = host crash
- ❌ **Platform-specific**: Need compile for each OS

**Critical for Healthcare**: Native plugins can exfiltrate PHI/PII.

---

## WASM Advantages

### 1. Security Sandbox
```rust
// Plugin CANNOT:
// - Access file system
// - Make network calls
// - Read other process memory
// - Execute arbitrary syscalls

// Plugin CAN only:
// - Process input data
// - Call explicitly granted host functions
```

**Reference**: [WASM Security Model](https://webassembly.org/docs/security/) (L0_CANONICAL)

### 2. Language Agnostic
- Rust: Performance-critical algorithms
- Go: Business logic with Go libraries
- AssemblyScript: TypeScript-like syntax
- C/C++: Legacy medical algorithms

### 3. Near-Native Performance
**Overhead**: 5-10% vs native (acceptable for healthcare)

---

## When NOT to Use WASM

❌ I/O-intensive operations (WASI immature)
❌ Real-time bidirectional streaming
❌ Direct database access needed
❌ Shared state between plugins

---

## References

- [WASM Specification 2.0](https://webassembly.github.io/spec/core/) (L0_CANONICAL)
- "Bringing the Web up to Speed with WebAssembly" (ACM PLDI 2017) (L1_ACADEMIC)
- [Extism Security](https://extism.org/docs/concepts/security) (L0_CANONICAL)