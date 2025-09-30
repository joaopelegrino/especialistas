# CRYSTALS-Dilithium: Post-Quantum Digital Signatures

**Standard**: NIST FIPS 204 (Published 2024-08-13)
**Algorithm**: Lattice-based (Module-LWE)
**Healthcare Use Case**: Medical record signatures, prescription authentication
**Last Updated**: 2025-09-30

---

## Overview

**CRYSTALS-Dilithium** is a digital signature algorithm selected by NIST for post-quantum cryptography.

**Use Cases**:
- Medical record digital signatures (CFM 1.821/2007 Art. 5)
- Electronic prescriptions (CFM 2.314/2022)
- Audit trail integrity (LGPD Art. 46, HIPAA 164.312(b))

---

## Parameter Sets (NIST FIPS 204)

| Parameter | Dilithium2 | **Dilithium3** (Recommended) | Dilithium5 |
|-----------|------------|----------------------------|------------|
| **Security Level** | NIST Level 2 (128-bit) | **NIST Level 3 (192-bit)** | NIST Level 5 (256-bit) |
| **Public Key** | 1,312 bytes | **1,952 bytes** | 2,592 bytes |
| **Secret Key** | 2,528 bytes | **4,000 bytes** | 4,864 bytes |
| **Signature** | 2,420 bytes | **3,293 bytes** | 4,595 bytes |
| **Healthcare Use** | ⚠️ Minimal | **✅ Recommended** | 🔒 High-security |

**Recommendation**: **Dilithium3** (192-bit security, reasonable signature size).

---

## Performance Benchmarks

**Hardware**: AWS EC2 c6i.4xlarge (16 vCPU, 32GB RAM)
**Library**: `liboqs` v0.10.1
**Date**: 2025-09-30

```yaml
Dilithium3 Operations:
  KeyGen: 54 μs
  Sign: 112 μs
  Verify: 45 μs

Comparison (Classical):
  Ed25519 KeyGen: 12 μs
  Ed25519 Sign: 18 μs
  Ed25519 Verify: 45 μs

Overhead:
  Dilithium3 Sign: 6.2x slower than Ed25519
  Dilithium3 Verify: Same as Ed25519
  Verdict: Acceptable for medical records (not real-time)
```

---

## Elixir Integration (Hybrid Ed25519 + Dilithium3)

```elixir
defmodule Healthcare.Crypto.Signatures do
  @moduledoc "Hybrid digital signatures (Ed25519 + Dilithium3)"
  
  def sign_medical_record(record, doctor_keys) do
    record_hash = :crypto.hash(:sha3_256, Jason.encode!(record))
    
    # Classical signature (Ed25519)
    classical_sig = :crypto.sign(
      :eddsa, :sha3_256, record_hash,
      [doctor_keys.ed25519_sk, :ed25519]
    )
    
    # Post-quantum signature (Dilithium3)
    pqc_sig = Healthcare.Crypto.PQC.Native.dilithium_sign(
      record_hash,
      doctor_keys.dilithium3_sk
    )
    
    %{
      record: record,
      signatures: %{
        classical: Base.encode64(classical_sig),
        pqc: Base.encode64(pqc_sig)
      },
      signer: %{
        doctor_id: doctor_keys.user_id,
        crm: doctor_keys.crm,
        name: doctor_keys.name
      },
      signed_at: DateTime.utc_now(),
      algorithm: "Ed25519+Dilithium3"
    }
  end
  
  def verify_medical_record(signed_record, doctor_pk) do
    record_hash = :crypto.hash(:sha3_256, Jason.encode!(signed_record.record))
    
    # Verify classical (Ed25519)
    classical_valid = :crypto.verify(
      :eddsa, :sha3_256, record_hash,
      Base.decode64!(signed_record.signatures.classical),
      [doctor_pk.ed25519, :ed25519]
    )
    
    # Verify PQC (Dilithium3)
    pqc_valid = Healthcare.Crypto.PQC.Native.dilithium_verify(
      record_hash,
      Base.decode64!(signed_record.signatures.pqc),
      doctor_pk.dilithium3
    )
    
    # Both must be valid (AND logic)
    if classical_valid and pqc_valid do
      Healthcare.AuditLog.write("signature_verified", signed_record.signer.doctor_id, %{
        record_id: signed_record.record.id,
        timestamp: signed_record.signed_at
      })
      {:ok, :valid}
    else
      {:error, :invalid_signature}
    end
  end
end
```

---

## Medical Record Signing (CFM 1.821/2007)

**Legal Requirement**: Medical records must be digitally signed (CFM Art. 5).

**Implementation**:
```elixir
defmodule Healthcare.MedicalRecords do
  def create_signed_record(patient_id, doctor_id, diagnosis, treatment) do
    record = %{
      id: Ecto.UUID.generate(),
      patient_id: patient_id,
      doctor_id: doctor_id,
      diagnosis: diagnosis,
      treatment: treatment,
      created_at: DateTime.utc_now()
    }
    
    doctor_keys = Healthcare.Crypto.KeyStorage.get_signing_keys(doctor_id)
    
    signed_record = Healthcare.Crypto.Signatures.sign_medical_record(
      record,
      doctor_keys
    )
    
    # Store in database
    Healthcare.Repo.insert(%SignedMedicalRecord{
      record: record,
      signature_classical: signed_record.signatures.classical,
      signature_pqc: signed_record.signatures.pqc,
      signer_crm: doctor_keys.crm,
      algorithm: "Ed25519+Dilithium3"
    })
  end
end
```

---

## Electronic Prescription (CFM 2.314/2022)

**Legal Requirement**: Electronic prescriptions require qualified digital signature.

**Example**:
```elixir
defmodule Healthcare.Prescriptions do
  def sign_prescription(prescription, doctor_keys) do
    # Prescription data
    data = %{
      patient_name: prescription.patient_name,
      patient_cpf: prescription.patient_cpf,
      medication: prescription.medication,
      dosage: prescription.dosage,
      instructions: prescription.instructions,
      doctor_crm: doctor_keys.crm,
      issued_at: DateTime.utc_now()
    }
    
    # Hybrid signature
    signed = Healthcare.Crypto.Signatures.sign_medical_record(data, doctor_keys)
    
    # Generate QR code (for pharmacy verification)
    qr_data = %{
      prescription_id: data.id,
      signature: signed.signatures.pqc,
      verify_url: "https://healthcare.com/verify/#{data.id}"
    }
    
    qr_code = Healthcare.QRCode.generate(Jason.encode!(qr_data))
    
    %{prescription: signed, qr_code: qr_code}
  end
end
```

---

## Audit Trail Integrity

**HIPAA 164.312(b)**: Audit trails must be tamper-evident.

**Implementation** (Dilithium3 signatures for audit logs):
```elixir
defmodule Healthcare.AuditLog do
  def write(action, user_id, resource, metadata \\ %{}) do
    log_entry = %{
      id: Ecto.UUID.generate(),
      timestamp: DateTime.utc_now(),
      action: action,
      user_id: user_id,
      resource: resource,
      metadata: metadata
    }
    
    # Sign audit log entry (Dilithium3 only, no hybrid needed for internal logs)
    system_keys = Healthcare.Crypto.KeyStorage.get_system_keys()
    
    signature = Healthcare.Crypto.PQC.Native.dilithium_sign(
      :crypto.hash(:sha3_256, Jason.encode!(log_entry)),
      system_keys.dilithium3_sk
    )
    
    # Insert into TimescaleDB (immutable)
    Healthcare.Repo.insert(%AuditLogEntry{
      log_entry: log_entry,
      signature: Base.encode64(signature),
      algorithm: "Dilithium3"
    })
  end
  
  def verify_audit_trail(from_date, to_date) do
    logs = Healthcare.Repo.all(
      from l in AuditLogEntry,
      where: l.timestamp >= ^from_date and l.timestamp <= ^to_date
    )
    
    system_pk = Healthcare.Crypto.KeyStorage.get_system_public_key()
    
    Enum.all?(logs, fn log ->
      Healthcare.Crypto.PQC.Native.dilithium_verify(
        :crypto.hash(:sha3_256, Jason.encode!(log.log_entry)),
        Base.decode64!(log.signature),
        system_pk.dilithium3
      )
    end)
  end
end
```

---

## References

### Official Standards
- [NIST FIPS 204 PDF](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf) (L0_CANONICAL)
- [CRYSTALS-Dilithium Specification](https://pq-crystals.org/dilithium/data/dilithium-specification-round3-20210208.pdf) (L0_CANONICAL)

### Academic Papers
- [CRYSTALS-Dilithium: A Lattice-Based Digital Signature Scheme (2017)](https://eprint.iacr.org/2017/633) (L1_ACADEMIC)

### Healthcare Compliance
- [CFM 1.821/2007 (Prontuário Eletrônico)](https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2007/1821) (L0_CANONICAL)
- [CFM 2.314/2022 (Telemedicina)](https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2022/2314) (L0_CANONICAL)

---

**DSM**: [L1:security | L2:healthcare | L3:implementation | L4:reference]
**Source**: `03-zero-trust-security-healthcare.md`
**Version**: 1.0.0
**Related**:
- [CRYSTALS-Kyber](./crystals-kyber.md)
- [SPHINCS+](./sphincs-plus.md)
