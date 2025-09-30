# Rust WebAssembly for Healthcare Plugins

**Language**: Rust 1.81.0
**Target**: wasm32-unknown-unknown / wasm32-wasi
**Healthcare Context**: High-performance medical algorithms with memory safety
**Last Updated**: 2025-09-30

---

## Overview

**Rust** is the premier language for WebAssembly plugins due to:
- **Memory safety**: No null pointers, no buffer overflows (critical for medical code)
- **Performance**: Near-native speed (5-10% overhead vs native)
- **Ecosystem**: Excellent WASM tooling (wasm-pack, cargo-component)
- **Zero-cost abstractions**: High-level code compiles to efficient WASM

**Healthcare Use Case**: Drug interaction checkers, FHIR validators, clinical calculators requiring both safety and performance.

---

## Setup

### Install Rust

```bash
# Install rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add WASM target
rustup target add wasm32-unknown-unknown
rustup target add wasm32-wasi  # If using WASI
```

### Project Structure

```bash
cargo new --lib healthcare_plugin
cd healthcare_plugin
```

```toml
# Cargo.toml
[package]
name = "healthcare_plugin"
version = "1.0.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]  # Dynamic library for WASM

[dependencies]
extism-pdk = "1.2"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# Optional: Medical libraries
chrono = "0.4"  # Date/time handling
regex = "1.10"  # Pattern matching (CPF, CRM validation)
```

---

## Basic Extism Plugin

### Simple CPF Validator

```rust
// src/lib.rs
use extism_pdk::*;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct ValidateRequest {
    cpf: String,
}

#[derive(Serialize)]
struct ValidateResponse {
    valid: bool,
    message: String,
}

/// Validates Brazilian CPF (Cadastro de Pessoas Físicas)
#[plugin_fn]
pub fn validate_cpf(input: String) -> FnResult<Json<ValidateResponse>> {
    let req: ValidateRequest = serde_json::from_str(&input)?;
    
    // Remove non-numeric characters
    let cpf: String = req.cpf.chars().filter(|c| c.is_numeric()).collect();
    
    // Validate length
    if cpf.len() != 11 {
        return Ok(Json(ValidateResponse {
            valid: false,
            message: "CPF must have 11 digits".to_string(),
        }));
    }
    
    // Check for known invalid CPFs (all same digit)
    if cpf.chars().all(|c| c == cpf.chars().next().unwrap()) {
        return Ok(Json(ValidateResponse {
            valid: false,
            message: "Invalid CPF (repeated digits)".to_string(),
        }));
    }
    
    // Calculate verification digits
    let digits: Vec<u32> = cpf.chars().map(|c| c.to_digit(10).unwrap()).collect();
    
    let mut sum = 0;
    for i in 0..9 {
        sum += digits[i] * (10 - i as u32);
    }
    let check1 = if sum % 11 < 2 { 0 } else { 11 - (sum % 11) };
    
    sum = 0;
    for i in 0..10 {
        sum += digits[i] * (11 - i as u32);
    }
    let check2 = if sum % 11 < 2 { 0 } else { 11 - (sum % 11) };
    
    let valid = digits[9] == check1 && digits[10] == check2;
    
    Ok(Json(ValidateResponse {
        valid,
        message: if valid { "Valid CPF".to_string() } else { "Invalid CPF checksum".to_string() },
    }))
}
```

### Build & Test

```bash
# Build WASM
cargo build --target wasm32-unknown-unknown --release

# Optimize
wasm-opt -O3 \
  target/wasm32-unknown-unknown/release/healthcare_plugin.wasm \
  -o healthcare_plugin_opt.wasm

# Check size
ls -lh healthcare_plugin_opt.wasm
# ~150KB (typical size for simple plugin)

# Test with extism CLI
extism call healthcare_plugin_opt.wasm validate_cpf \
  --input '{"cpf":"12345678901"}' \
  --wasi
```

---

## Advanced: FHIR Patient Validator

### Full Implementation

```rust
// src/lib.rs
use extism_pdk::*;
use serde::{Deserialize, Serialize};
use chrono::NaiveDate;

#[derive(Deserialize)]
struct FhirPatient {
    #[serde(rename = "resourceType")]
    resource_type: String,
    id: Option<String>,
    identifier: Option<Vec<Identifier>>,
    name: Option<Vec<HumanName>>,
    #[serde(rename = "birthDate")]
    birth_date: Option<String>,
    gender: Option<String>,
}

#[derive(Deserialize)]
struct Identifier {
    system: Option<String>,
    value: String,
}

#[derive(Deserialize)]
struct HumanName {
    family: Option<String>,
    given: Option<Vec<String>>,
}

#[derive(Serialize)]
struct ValidationResult {
    valid: bool,
    errors: Vec<ValidationError>,
    warnings: Vec<String>,
}

#[derive(Serialize)]
struct ValidationError {
    field: String,
    message: String,
    severity: ErrorSeverity,
}

#[derive(Serialize)]
#[serde(rename_all = "lowercase")]
enum ErrorSeverity {
    Error,
    Fatal,
}

/// Validates FHIR R4 Patient resource
#[plugin_fn]
pub fn validate_patient(input: String) -> FnResult<Json<ValidationResult>> {
    let mut errors = Vec::new();
    let mut warnings = Vec::new();
    
    // Parse JSON
    let patient: FhirPatient = match serde_json::from_str(&input) {
        Ok(p) => p,
        Err(e) => {
            return Ok(Json(ValidationResult {
                valid: false,
                errors: vec![ValidationError {
                    field: "root".to_string(),
                    message: format!("Invalid JSON: {}", e),
                    severity: ErrorSeverity::Fatal,
                }],
                warnings,
            }));
        }
    };
    
    // 1. Validate resourceType
    if patient.resource_type != "Patient" {
        errors.push(ValidationError {
            field: "resourceType".to_string(),
            message: format!(
                "Expected 'Patient', got '{}'",
                patient.resource_type
            ),
            severity: ErrorSeverity::Fatal,
        });
    }
    
    // 2. Validate id (required in FHIR R4)
    if patient.id.is_none() {
        errors.push(ValidationError {
            field: "id".to_string(),
            message: "Patient.id is required".to_string(),
            severity: ErrorSeverity::Error,
        });
    }
    
    // 3. Validate identifier (must have at least one with CPF)
    if let Some(identifiers) = &patient.identifier {
        let has_cpf = identifiers.iter().any(|id| {
            id.system == Some("http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf".to_string())
        });
        
        if !has_cpf {
            warnings.push("Patient should have CPF identifier for Brazilian healthcare".to_string());
        }
        
        // Validate CPF format if present
        for id in identifiers {
            if id.system == Some("http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf".to_string()) {
                if !is_valid_cpf(&id.value) {
                    errors.push(ValidationError {
                        field: "identifier.value".to_string(),
                        message: format!("Invalid CPF: {}", id.value),
                        severity: ErrorSeverity::Error,
                    });
                }
            }
        }
    } else {
        errors.push(ValidationError {
            field: "identifier".to_string(),
            message: "Patient.identifier is required".to_string(),
            severity: ErrorSeverity::Error,
        });
    }
    
    // 4. Validate name
    if let Some(names) = &patient.name {
        if names.is_empty() {
            errors.push(ValidationError {
                field: "name".to_string(),
                message: "Patient.name must have at least one entry".to_string(),
                severity: ErrorSeverity::Error,
            });
        }
        
        for name in names {
            if name.family.is_none() && name.given.as_ref().map_or(true, |g| g.is_empty()) {
                errors.push(ValidationError {
                    field: "name".to_string(),
                    message: "Name must have either family or given name".to_string(),
                    severity: ErrorSeverity::Error,
                });
            }
        }
    } else {
        errors.push(ValidationError {
            field: "name".to_string(),
            message: "Patient.name is required".to_string(),
            severity: ErrorSeverity::Error,
        });
    }
    
    // 5. Validate birthDate (YYYY-MM-DD format)
    if let Some(bd) = &patient.birth_date {
        if NaiveDate::parse_from_str(bd, "%Y-%m-%d").is_err() {
            errors.push(ValidationError {
                field: "birthDate".to_string(),
                message: "Invalid date format (expected YYYY-MM-DD)".to_string(),
                severity: ErrorSeverity::Error,
            });
        } else {
            // Check for unrealistic ages
            let birth_date = NaiveDate::parse_from_str(bd, "%Y-%m-%d").unwrap();
            let today = chrono::Utc::now().date_naive();
            let age = (today - birth_date).num_days() / 365;
            
            if age < 0 {
                errors.push(ValidationError {
                    field: "birthDate".to_string(),
                    message: "Birth date cannot be in the future".to_string(),
                    severity: ErrorSeverity::Error,
                });
            } else if age > 150 {
                warnings.push(format!("Age {} seems unrealistic", age));
            }
        }
    }
    
    // 6. Validate gender
    if let Some(gender) = &patient.gender {
        let valid_genders = ["male", "female", "other", "unknown"];
        if !valid_genders.contains(&gender.as_str()) {
            errors.push(ValidationError {
                field: "gender".to_string(),
                message: format!(
                    "Invalid gender '{}' (must be male, female, other, or unknown)",
                    gender
                ),
                severity: ErrorSeverity::Error,
            });
        }
    }
    
    Ok(Json(ValidationResult {
        valid: errors.is_empty(),
        errors,
        warnings,
    }))
}

/// Helper: Validate CPF checksum
fn is_valid_cpf(cpf: &str) -> bool {
    let cpf: String = cpf.chars().filter(|c| c.is_numeric()).collect();
    
    if cpf.len() != 11 {
        return false;
    }
    
    if cpf.chars().all(|c| c == cpf.chars().next().unwrap()) {
        return false;
    }
    
    let digits: Vec<u32> = cpf.chars().map(|c| c.to_digit(10).unwrap()).collect();
    
    let mut sum = 0;
    for i in 0..9 {
        sum += digits[i] * (10 - i as u32);
    }
    let check1 = if sum % 11 < 2 { 0 } else { 11 - (sum % 11) };
    
    sum = 0;
    for i in 0..10 {
        sum += digits[i] * (11 - i as u32);
    }
    let check2 = if sum % 11 < 2 { 0 } else { 11 - (sum % 11) };
    
    digits[9] == check1 && digits[10] == check2
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_valid_cpf() {
        assert!(is_valid_cpf("12345678909"));
        assert!(is_valid_cpf("123.456.789-09"));
    }
    
    #[test]
    fn test_invalid_cpf() {
        assert!(!is_valid_cpf("11111111111"));  // Repeated digits
        assert!(!is_valid_cpf("12345678900"));  // Wrong checksum
        assert!(!is_valid_cpf("123"));          // Too short
    }
}
```

---

## Host Function Integration

### Calling Elixir from Rust

```rust
// src/lib.rs
use extism_pdk::*;

#[host_fn]
extern "ExtismHost" {
    fn get_patient(patient_id: &str) -> String;
    fn log_event(message: &str);
}

#[plugin_fn]
pub fn analyze_patient(patient_id_json: String) -> FnResult<String> {
    // Parse input
    let req: serde_json::Value = serde_json::from_str(&patient_id_json)?;
    let patient_id = req["patient_id"].as_str().unwrap();
    
    // Call host function to get patient
    let patient_json = unsafe {
        host::get_patient(patient_id)?
    };
    
    // Log event (audit trail)
    unsafe {
        host::log_event(&format!("Analyzing patient {}", patient_id))?;
    }
    
    // Parse patient data
    let patient: serde_json::Value = serde_json::from_str(&patient_json)?;
    
    // Perform analysis
    let analysis = perform_clinical_analysis(&patient);
    
    Ok(serde_json::to_string(&analysis)?)
}

fn perform_clinical_analysis(patient: &serde_json::Value) -> serde_json::Value {
    // Complex medical analysis logic
    serde_json::json!({
        "risk_score": 75,
        "recommendations": ["Monitor blood pressure", "Schedule follow-up"]
    })
}
```

---

## Performance Optimization

### 1. Use Release Build

```toml
[profile.release]
opt-level = "z"     # Optimize for size
lto = true          # Link-time optimization
codegen-units = 1   # Better optimization (slower compile)
panic = "abort"     # Smaller binaries
strip = true        # Strip symbols
```

### 2. Minimize Dependencies

```toml
# Use minimal feature flags
[dependencies]
serde = { version = "1.0", default-features = false, features = ["derive"] }
serde_json = { version = "1.0", default-features = false, features = ["alloc"] }
```

### 3. Lazy Statics

```rust
use once_cell::sync::Lazy;
use regex::Regex;

// Compile regex once, reuse across calls
static CPF_REGEX: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"^\d{11}$").unwrap()
});

fn validate_cpf_format(cpf: &str) -> bool {
    CPF_REGEX.is_match(cpf)
}
```

---

## Testing Strategies

### Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_validate_patient_success() {
        let input = r#"{
            "resourceType": "Patient",
            "id": "12345",
            "identifier": [{
                "system": "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
                "value": "12345678909"
            }],
            "name": [{"family": "Silva", "given": ["João"]}],
            "birthDate": "1985-03-15",
            "gender": "male"
        }"#;
        
        let result = validate_patient(input.to_string()).unwrap();
        assert!(result.0.valid);
        assert_eq!(result.0.errors.len(), 0);
    }
    
    #[test]
    fn test_validate_patient_missing_id() {
        let input = r#"{
            "resourceType": "Patient",
            "name": [{"family": "Silva"}]
        }"#;
        
        let result = validate_patient(input.to_string()).unwrap();
        assert!(!result.0.valid);
        assert!(result.0.errors.iter().any(|e| e.field == "id"));
    }
}
```

### Integration Tests (Elixir)

```elixir
defmodule Healthcare.FHIRValidatorTest do
  use ExUnit.Case
  
  setup do
    wasm_binary = File.read!("priv/wasm/fhir_validator.wasm")
    {:ok, plugin} = Extism.Plugin.new(%{wasm: [%{data: wasm_binary}]})
    %{plugin: plugin}
  end
  
  test "validates correct FHIR Patient", %{plugin: plugin} do
    input = Jason.encode!(%{
      resourceType: "Patient",
      id: "12345",
      identifier: [%{
        system: "http://rnds.saude.gov.br/fhir/r4/NamingSystem/cpf",
        value: "12345678909"
      }],
      name: [%{family: "Silva", given: ["João"]}],
      birthDate: "1985-03-15",
      gender: "male"
    })
    
    {:ok, output} = Extism.Plugin.call(plugin, "validate_patient", input)
    result = Jason.decode!(output)
    
    assert result["valid"] == true
    assert Enum.empty?(result["errors"])
  end
end
```

---

## Binary Size Optimization

### Before Optimization

```bash
cargo build --target wasm32-unknown-unknown --release
ls -lh target/wasm32-unknown-unknown/release/healthcare_plugin.wasm
# 1.2MB
```

### After Optimization

```bash
# 1. Use wasm-opt
wasm-opt -Oz \
  target/wasm32-unknown-unknown/release/healthcare_plugin.wasm \
  -o healthcare_plugin_opt.wasm

# 2. Strip debug info
wasm-strip healthcare_plugin_opt.wasm

# 3. Compress with gzip
gzip -9 healthcare_plugin_opt.wasm

ls -lh healthcare_plugin_opt.wasm.gz
# 180KB (85% reduction)
```

### Cargo Configuration

```toml
# .cargo/config.toml
[target.wasm32-unknown-unknown]
rustflags = [
  "-C", "link-arg=-s",                    # Strip symbols
  "-C", "opt-level=z",                    # Optimize for size
  "-C", "lto=fat",                        # Link-time optimization
  "-C", "embed-bitcode=yes",
  "-C", "codegen-units=1",
]
```

---

## References

### Official Documentation
- [Rust and WebAssembly Book](https://rustwasm.github.io/docs/book/) (L0_CANONICAL)
- [wasm-bindgen Guide](https://rustwasm.github.io/docs/wasm-bindgen/) (L0_CANONICAL)
- [Extism Rust PDK](https://github.com/extism/rust-pdk) (L0_CANONICAL)

### Tools
- [wasm-pack](https://rustwasm.github.io/wasm-pack/) (L0_CANONICAL)
- [cargo-component](https://github.com/bytecodealliance/cargo-component) (L0_CANONICAL)

---

**DSM**: [L1:infrastructure | L2:healthcare | L3:implementation | L4:guide]
**Source**: `02-webassembly-plugins-healthcare.md` (Rust WASM sections)
**Version**: 1.0.0
**Related**:
- [WASM Core Specification](../specification/wasm-core-spec.md)
- [Extism Plugin Development](../extism-platform/plugin-development.md)
- [Go WASM](./go-wasm.md)
