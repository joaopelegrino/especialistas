# 🔌 Módulo 03: Extism Integration - WASM Plugin Host

## 🎯 Objetivos
- Integrar Extism Elixir SDK para carregar plugins WASM
- Implementar host functions (Elixir → WASM communication)
- Gerenciar lifecycle de plugins (load/unload/reload)
- Aplicar em contexto healthcare real (Sistema S.1.1 LGPD)

**Duração**: 2-3 dias | **Pré-requisitos**: Módulos 01 e 02 completos

---

## 📚 O que é Extism?

**Extism** = Framework para executar plugins WASM de forma segura e universal.

```
┌──────────────────────────────────────────────────┐
│  Elixir Host (trust boundary)                    │
│  ┌────────────────────────────────────────────┐  │
│  │  Extism SDK                                │  │
│  │  ├─ Plugin loader                          │  │
│  │  ├─ Memory management                      │  │
│  │  ├─ Host function registry                 │  │
│  │  └─ Security policies                      │  │
│  └────────────────────────────────────────────┘  │
│         ▲                           ▼             │
│  ┌────────────┐              ┌────────────┐      │
│  │ WASM Plugin│              │ WASM Plugin│      │
│  │ (Rust)     │              │ (Go)       │      │
│  └────────────┘              └────────────┘      │
└──────────────────────────────────────────────────┘
```

**Benefício Healthcare**: Plugins escritos em Rust, Go, C podem coexistir. Ex: S.1.1 (Rust) + S.1.2 (AssemblyScript) rodando juntos.

---

## 🛠️ Setup Extism SDK

### Adicionar ao `mix.exs`:
```elixir
defp deps do
  [
    {:extism, "~> 1.1.0"},
    {:jason, "~> 1.4"}
  ]
end
```

```bash
mix deps.get
mix compile
```

---

## 🧪 Lab 3.1: Primeiro Plugin com Extism

### Passo 1: Criar plugin WASM simples

```rust
// plugin.rs
use extism_pdi::*;

#[plugin_fn]
pub fn process_lgpd_data(input: String) -> FnResult<String> {
    let json: serde_json::Value = serde_json::from_str(&input)?;
    
    // Detectar PII/PHI
    let has_pii = json.get("has_cpf").is_some();
    
    let result = json!({
        "status": "processed",
        "contains_pii": has_pii,
        "audit_id": format!("AUDIT_{}", chrono::Utc::now().timestamp())
    });
    
    Ok(serde_json::to_string(&result)?)
}
```

### Passo 2: Carregar em Elixir

```elixir
defmodule HealthcareStack.PluginManager do
  alias Extism.Plugin
  
  def load_lgpd_plugin() do
    # Carregar WASM do filesystem
    manifest = %{
      wasm: [%{path: "plugins/lgpd_analyzer.wasm"}],
      memory: %{max_pages: 5}  # 320KB limit
    }
    
    {:ok, plugin} = Plugin.new(manifest, true)
    plugin
  end
  
  def analyze_data(plugin, patient_data) do
    input = Jason.encode!(patient_data)
    
    case Plugin.call(plugin, "process_lgpd_data", input) do
      {:ok, output} ->
        Jason.decode!(output)
        
      {:error, reason} ->
        {:error, "Plugin failed: #{reason}"}
    end
  end
end
```

---

## 🔗 Host Functions (Elixir → WASM)

Permitir que plugins WASM chamem funções Elixir:

```elixir
# Definir host function
host_functions = [
  %Extism.HostFunction{
    name: "log_audit",
    callback: fn plugin, inputs ->
      [message] = inputs
      Logger.info("[AUDIT] #{message}")
      0  # return code
    end
  }
]

{:ok, plugin} = Plugin.new(manifest, true, host_functions)
```

No plugin Rust:
```rust
extern "C" {
    fn log_audit(message: &str);
}

#[plugin_fn]
pub fn process() -> FnResult<()> {
    unsafe {
        log_audit("Processing patient data");
    }
    Ok(())
}
```

**Healthcare Use Case**: Log de auditoria para compliance LGPD.

---

## 📚 Referências
- [Extism Docs](https://extism.org/docs)
- [Extism Elixir SDK](https://github.com/extism/elixir-sdk)
- `BOM-WASM-ELIXIR-HEALTHCARE-STACK.md:36-70` - Architecture

**Próximo**: [04-cms-architecture](../04-cms-architecture/)

---
**Status**: ✅ Ready | **Updated**: 29/09/2025
