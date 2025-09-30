# ADR 004: Zero Trust Architecture with Post-Quantum Cryptography

**Status**: ACCEPTED | **Date**: 2025-09-26 | **Updated**: 2025-09-30

## Context

Healthcare system requires **Zero Trust security** for:
1. **HIPAA 164.312(e)(1)**: Transmission security (encryption)
2. **LGPD Art. 46**: Data processing security (PHI/PII protection)
3. **CFM 2.314/2022 Art. 5**: End-to-end encryption (telemedicine)
4. **50+ Year Records**: Post-quantum cryptography (quantum threat mitigation)

### Threat Model

1. **External Attackers**: Ransomware, data exfiltration
2. **Insider Threats**: Malicious employees accessing PHI
3. **Quantum Computers**: Harvest-now-decrypt-later attacks (medical records 50+ years)

## Decision

**Implement Zero Trust Architecture (NIST SP 800-207) with Post-Quantum Cryptography**

**Components**:
1. **Service Mesh**: Istio 1.24 (mTLS, microsegmentation)
2. **Policy Engine**: Open Policy Agent (OPA)
3. **Post-Quantum Cryptography**:
   - KEM: CRYSTALS-Kyber-768 (NIST FIPS 203)
   - Signatures: CRYSTALS-Dilithium3 (NIST FIPS 204)
   - Long-Term: SPHINCS+ (NIST FIPS 205)
4. **Identity**: Keycloak + OAuth2 + OIDC

**Rationale**:
1. **NIST-Approved**: SP 800-207 compliance (federal/healthcare standard)
2. **Quantum-Resistant**: Kyber + Dilithium protect 50+ year records
3. **Microsegmentation**: Istio enforces network policies (no east-west traffic by default)
4. **Continuous Verification**: Every request authenticated + authorized

## Alternatives

### Traditional Perimeter Security (Firewall + VPN)
**Cons**:
- ❌ **Single Point of Failure**: Firewall breach = full network access
- ❌ **No microsegmentation**: Lateral movement after breach
- ❌ **VPN complexity**: Client software, key management
- ❌ **Not NIST SP 800-207 compliant**

**Decision**: Perimeter security rejected (does not meet Zero Trust principles).

---

### Classical Cryptography Only (RSA + ECDSA)
**Cons**:
- ❌ **Quantum Vulnerable**: Shor's algorithm breaks RSA-2048 in hours (future quantum computers)
- ❌ **50+ Year Records**: Medical records vulnerable after ~2040
- ❌ **NIST Recommendation**: Migrate to PQC by 2030

**Decision**: Classical-only rejected due to quantum threat timeline.

---

## Zero Trust Principles (NIST SP 800-207)

### 1. Verify Explicitly
**Principle**: Never trust, always verify (even inside network)

**Implementation** (Istio + OPA):
```yaml
# Istio AuthorizationPolicy (deny by default)
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: fhir-api-access
  namespace: healthcare
spec:
  selector:
    matchLabels:
      app: fhir-api
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/healthcare/sa/elixir-host"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/fhir/Patient/*", "/fhir/Observation/*"]
    when:
    - key: request.auth.claims[role]
      values: ["doctor", "nurse"]
```

**OPA Policy** (fine-grained authorization):
```rego
package healthcare.fhir

# Allow doctors to read patients they're assigned to
allow {
  input.method == "GET"
  input.path == ["fhir", "Patient", patient_id]
  input.user.role == "doctor"
  input.user.assigned_patients[_] == patient_id
}

# Deny by default
default allow = false
```

---

### 2. Least Privilege Access
**Principle**: Minimal access required for function

**Implementation** (PostgreSQL Row-Level Security):
```sql
-- Enable RLS
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- Doctors see only assigned patients
CREATE POLICY doctor_patients ON patients
  FOR SELECT
  TO doctor_role
  USING (id IN (
    SELECT patient_id FROM doctor_assignments
    WHERE doctor_id = current_setting('app.current_user_id')::UUID
  ));

-- Nurses see patients in their ward
CREATE POLICY nurse_ward ON patients
  FOR SELECT
  TO nurse_role
  USING (ward_id = current_setting('app.current_ward_id')::UUID);
```

---

### 3. Assume Breach
**Principle**: Design assuming attackers are already inside

**Implementation** (Microsegmentation):
- **Network Policies**: Deny all by default, explicit allow rules
- **Audit Logging**: Every access logged (LGPD Art. 46, HIPAA 164.312(b))
- **Anomaly Detection**: Prometheus alerts on unusual access patterns

---

## Post-Quantum Cryptography

### Hybrid Approach (Classical + PQC)

**Rationale**: Provides security against both classical and quantum attackers

**TLS 1.3 Hybrid**:
```
KEM: X25519 (classical) + CRYSTALS-Kyber-768 (PQC)
Signature: Ed25519 (classical) + CRYSTALS-Dilithium3 (PQC)
```

**Key Sizes**:
| Algorithm | Public Key | Secret Key | Ciphertext/Signature |
|-----------|------------|------------|----------------------|
| RSA-2048 | 256 bytes | 256 bytes | 256 bytes |
| X25519 | 32 bytes | 32 bytes | 32 bytes |
| **Kyber-768** | **1,184 bytes** | **2,400 bytes** | **1,088 bytes** |
| Ed25519 | 32 bytes | 32 bytes | 64 bytes |
| **Dilithium3** | **1,952 bytes** | **4,000 bytes** | **3,293 bytes** |

**Trade-off**: Larger key sizes (~10x) acceptable for 50+ year security.

---

### CRYSTALS-Kyber (Key Encapsulation)

**Use Case**: TLS handshake, symmetric key exchange

**Elixir Implementation** (via Rust NIF):
```elixir
defmodule Healthcare.Crypto.PQC do
  @moduledoc "Post-Quantum Cryptography (NIST FIPS 203)"

  def generate_kyber_keypair() do
    # Call Rust NIF (pqcrypto crate)
    Healthcare.Native.kyber_keypair()
  end

  def encapsulate(public_key) do
    # Returns {shared_secret, ciphertext}
    Healthcare.Native.kyber_encapsulate(public_key)
  end

  def decapsulate(secret_key, ciphertext) do
    # Returns shared_secret
    Healthcare.Native.kyber_decapsulate(secret_key, ciphertext)
  end
end
```

---

### CRYSTALS-Dilithium (Digital Signatures)

**Use Case**: Medical record signatures, prescription authentication

**Example** (Sign medical record):
```elixir
defmodule Healthcare.MedicalRecords do
  def sign_record(record, doctor_private_key) do
    record_hash = :crypto.hash(:sha3_256, Jason.encode!(record))
    
    # Hybrid signature (Ed25519 + Dilithium3)
    classical_sig = :crypto.sign(:eddsa, :sha3_256, record_hash, [doctor_private_key.ed25519, :ed25519])
    pqc_sig = Healthcare.Native.dilithium_sign(record_hash, doctor_private_key.dilithium3)
    
    %{
      record: record,
      signatures: %{
        classical: Base.encode64(classical_sig),
        pqc: Base.encode64(pqc_sig)
      },
      signed_at: DateTime.utc_now(),
      algorithm: "Ed25519+Dilithium3"
    }
  end
  
  def verify_record(signed_record, doctor_public_key) do
    record_hash = :crypto.hash(:sha3_256, Jason.encode!(signed_record.record))
    
    # Verify both signatures (AND logic)
    classical_valid = :crypto.verify(
      :eddsa, :sha3_256, record_hash,
      Base.decode64!(signed_record.signatures.classical),
      [doctor_public_key.ed25519, :ed25519]
    )
    
    pqc_valid = Healthcare.Native.dilithium_verify(
      record_hash,
      Base.decode64!(signed_record.signatures.pqc),
      doctor_public_key.dilithium3
    )
    
    classical_valid and pqc_valid
  end
end
```

---

### SPHINCS+ (Long-Term Signatures)

**Use Case**: Medical records requiring 50+ year integrity (archival)

**Properties**:
- **Stateless**: No key state management (vs XMSS)
- **Slow**: ~10ms sign, ~1ms verify (acceptable for archival)
- **Large Signatures**: ~8KB (trade-off for statelessness)

---

## Consequences

### Positive
1. **NIST Compliance**: SP 800-207 (Zero Trust), FIPS 203/204/205 (PQC)
2. **Quantum-Resistant**: 50+ year medical records protected
3. **Microsegmentation**: Istio enforces network policies
4. **Audit Trail**: Every access logged (LGPD/HIPAA)

### Negative
1. **Complexity**: Istio + OPA + PQC = steep learning curve
2. **Key Sizes**: 10x larger (1KB vs 10KB certificates)
3. **Performance**: PQC ~10% slower (acceptable overhead)

### Neutral
1. **Transition Period**: 2025-2030 (hybrid classical+PQC)

---

## Mitigation Strategies

### Complexity
- **Training**: $10K/year for Istio + OPA certification
- **Managed Service**: AWS EKS + Istio addon

### Performance
- **Hardware Acceleration**: AES-NI for symmetric crypto
- **Caching**: Certificate caching (reduce handshakes)

---

## References

### Official Standards
- [NIST SP 800-207 (Zero Trust)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) (L0_CANONICAL)
- [NIST FIPS 203 (Kyber)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf) (L0_CANONICAL)
- [NIST FIPS 204 (Dilithium)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf) (L0_CANONICAL)
- [NIST FIPS 205 (SPHINCS+)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.205.pdf) (L0_CANONICAL)

### Healthcare Compliance
- [HIPAA 164.312](https://www.hhs.gov/hipaa/for-professionals/security/index.html) (L0_CANONICAL)
- [CFM 2.314/2022](https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2022/2314) (L0_CANONICAL)

---

**DSM**: [L1:security | L2:healthcare | L3:architecture | L4:reference]
**Source**: `03-zero-trust-security-healthcare.md`
**Version**: 1.0.0
**Related ADRs**:
- [ADR 001: Elixir Host Choice](./001-elixir-host-choice.md)
- [ADR 002: WASM Plugin Isolation](./002-wasm-plugin-isolation.md)
