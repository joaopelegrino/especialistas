# LGPD-HIPAA Compliance Mapping for Healthcare Systems

**Brazilian Law**: LGPD (Lei 13.709/2018)
**US Law**: HIPAA (45 CFR Parts 160, 162, 164)
**Healthcare Standards**: CFM 1.821/2007, CFM 2.314/2022
**Last Updated**: 2025-09-30

---

## Executive Summary

**LGPD** (Lei Geral de Proteção de Dados) and **HIPAA** (Health Insurance Portability and Accountability Act) share similar principles but differ in implementation details.

**Key Similarities**:
- ✅ Both require audit logging
- ✅ Both mandate encryption (transmission + at rest)
- ✅ Both require data breach notification
- ✅ Both enforce access controls

**Key Differences**:
- ⚠️ LGPD: Explicit consent required (opt-in)
- ⚠️ HIPAA: Implicit consent for treatment (opt-out)
- ⚠️ LGPD: Right to data deletion (Art. 18)
- ⚠️ HIPAA: Retention requirements (6 years)

---

## Side-by-Side Comparison

| Requirement | LGPD | HIPAA | Implementation |
|-------------|------|-------|----------------|
| **Audit Logging** | Art. 46 (security safeguards) | 164.312(b) (audit controls) | PostgreSQL + TimescaleDB (immutable logs) |
| **Encryption (Transit)** | Art. 46 (security) | 164.312(e)(1) | TLS 1.3 + PQC (Kyber-768) |
| **Encryption (Rest)** | Art. 46 (security) | 164.312(a)(2)(iv) | AES-256-GCM (PostgreSQL pgcrypto) |
| **Access Control** | Art. 46 (least privilege) | 164.312(a)(1) | PostgreSQL RLS + OPA policies |
| **Data Breach Notification** | Art. 48 (72 hours) | 164.408 (60 days) | Automated alerting (Prometheus) |
| **Data Retention** | Art. 16 (deletion) | 164.530(j) (6 years) | Conflicting (see resolution below) |
| **Consent** | Art. 8 (explicit opt-in) | 164.508 (implicit for treatment) | Granular consent (patient portal) |

---

## Detailed Mapping

### 1. Audit Logging

#### LGPD Art. 46 (Security Safeguards)
> "Os agentes de tratamento devem adotar medidas de segurança, técnicas e administrativas aptas a proteger os dados pessoais de acessos não autorizados."

**Requirements**:
- Log all PHI/PII access
- Logs must be tamper-evident
- Retention: Not specified (recommended 5 years)

#### HIPAA 164.312(b) (Audit Controls)
> "Implement hardware, software, and/or procedural mechanisms that record and examine activity in information systems that contain or use electronic protected health information."

**Requirements**:
- Log access, modification, deletion of PHI
- Logs must be immutable
- Retention: 6 years

#### Combined Implementation
```elixir
defmodule Healthcare.AuditLog do
  @moduledoc "LGPD Art. 46 + HIPAA 164.312(b) compliant audit logging"
  
  def write(action, user_id, resource, metadata \\ %{}) do
    log_entry = %{
      id: Ecto.UUID.generate(),
      timestamp: DateTime.utc_now(),
      action: action,
      user_id: user_id,
      resource_type: resource.__struct__,
      resource_id: resource.id,
      metadata: metadata,
      compliance_tags: ["LGPD_Art_46", "HIPAA_164_312_b"]
    }
    
    # Sign with Dilithium3 (tamper-evident)
    signature = Healthcare.Crypto.PQC.Native.dilithium_sign(
      :crypto.hash(:sha3_256, Jason.encode!(log_entry)),
      Healthcare.Crypto.KeyStorage.get_system_keys().dilithium3_sk
    )
    
    # Insert into TimescaleDB (immutable, 6-year retention)
    Healthcare.Repo.insert(%AuditLogEntry{
      log_entry: log_entry,
      signature: Base.encode64(signature),
      algorithm: "Dilithium3"
    })
  end
end
```

**TimescaleDB Retention Policy**:
```sql
-- HIPAA requires 6 years, LGPD recommends 5 years
-- Use 6 years to satisfy both
SELECT add_retention_policy('audit_logs', INTERVAL '6 years');
```

---

### 2. Encryption

#### LGPD Art. 46 (Technical Safeguards)
**Requirements**:
- Encryption in transit (TLS)
- Encryption at rest (database)
- No specific algorithm mandated

#### HIPAA 164.312(e)(1) (Transmission Security)
**Requirements**:
- Encryption of PHI in motion
- NIST-approved algorithms (AES-256, RSA-2048+)

#### HIPAA 164.312(a)(2)(iv) (Encryption and Decryption)
**Requirements**:
- Encryption of PHI at rest
- Addressable (not required, but strongly recommended)

#### Combined Implementation

**TLS 1.3 + PQC** (Transit):
```nginx
# Nginx configuration
ssl_protocols TLSv1.3;
ssl_ecdh_curve X25519:kyber768;
ssl_ciphers TLS_KYBER768_WITH_AES_256_GCM_SHA384:TLS_AES_256_GCM_SHA384;
```

**Database Encryption** (At Rest):
```sql
-- PostgreSQL pgcrypto (HIPAA 164.312(a)(2)(iv))
CREATE EXTENSION pgcrypto;

-- Encrypt PHI columns
CREATE TABLE patients (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  cpf TEXT UNIQUE NOT NULL,
  
  -- Encrypted fields (LGPD Art. 46 + HIPAA 164.312)
  medical_history BYTEA NOT NULL, -- encrypted with AES-256-GCM
  medications BYTEA, -- encrypted
  allergies BYTEA, -- encrypted
  
  encryption_algorithm TEXT DEFAULT 'AES-256-GCM',
  created_at TIMESTAMPTZ NOT NULL
);

-- Encryption function
CREATE OR REPLACE FUNCTION encrypt_phi(plaintext TEXT, key BYTEA)
RETURNS BYTEA AS $$
BEGIN
  RETURN pgp_sym_encrypt(plaintext, key, 'cipher-algo=aes256');
END;
$$ LANGUAGE plpgsql;
```

---

### 3. Data Breach Notification

#### LGPD Art. 48 (Data Breach Notification)
> "O controlador deverá comunicar à autoridade nacional e ao titular a ocorrência de incidente de segurança que possa acarretar risco ou dano relevante aos titulares."

**Timeline**: "Reasonable timeframe" (interpreted as 72 hours by ANPD)

#### HIPAA 164.408 (Breach Notification)
**Timeline**:
- Individuals: 60 days
- Media (500+ affected): 60 days
- HHS: 60 days

#### Combined Implementation
```elixir
defmodule Healthcare.BreachNotification do
  @lgpd_deadline 72 * 60 * 60 # 72 hours (LGPD Art. 48)
  @hipaa_deadline 60 * 24 * 60 * 60 # 60 days (HIPAA 164.408)
  
  def detect_breach(event) do
    case classify_breach(event) do
      :phi_exposure ->
        # Immediate notification (most restrictive: 72 hours)
        notify_lgpd_anpd(event, deadline: @lgpd_deadline)
        notify_hipaa_hhs(event, deadline: @hipaa_deadline)
        notify_affected_individuals(event, deadline: @lgpd_deadline)
        
        Healthcare.AuditLog.write("data_breach_detected", :system, event, %{
          compliance: ["LGPD_Art_48", "HIPAA_164_408"],
          severity: "critical"
        })
        
      :non_phi ->
        # LGPD only (no HIPAA requirement)
        notify_lgpd_anpd(event, deadline: @lgpd_deadline)
    end
  end
end
```

---

### 4. Consent Management

#### LGPD Art. 8 (Explicit Consent)
> "O consentimento previsto no inciso I do art. 7º desta Lei deverá ser fornecido por escrito ou por outro meio que demonstre a manifestação de vontade do titular."

**Requirements**:
- **Explicit opt-in** (cannot be implied)
- Granular consent (per purpose)
- Right to revoke (Art. 18, VIII)

#### HIPAA 164.508 (Authorization)
**Requirements**:
- **Implicit consent for treatment** (no authorization required)
- Authorization required for non-treatment purposes (marketing, research)

#### Resolution Strategy
**Most Restrictive Compliance**: Use LGPD explicit consent for ALL purposes.

**Implementation**:
```elixir
defmodule Healthcare.Consent do
  @moduledoc "LGPD Art. 8 + HIPAA 164.508 compliant consent"
  
  def request_consent(patient_id, purposes) do
    Enum.map(purposes, fn purpose ->
      %Consent{
        patient_id: patient_id,
        purpose: purpose,
        granted_at: nil, # Explicit opt-in required
        revoked_at: nil,
        compliance_standard: "LGPD_Art_8_HIPAA_164_508"
      }
    end)
  end
  
  def grant_consent(patient_id, purpose) do
    case Healthcare.Repo.get_by(Consent, patient_id: patient_id, purpose: purpose) do
      nil ->
        Healthcare.Repo.insert(%Consent{
          patient_id: patient_id,
          purpose: purpose,
          granted_at: DateTime.utc_now(),
          consent_method: "explicit_web_portal", # LGPD Art. 8
          ip_address: get_ip_address(),
          compliance_standard: "LGPD_Art_8"
        })
      
      consent ->
        Healthcare.Repo.update(Ecto.Changeset.change(consent, 
          granted_at: DateTime.utc_now(),
          revoked_at: nil
        ))
    end
  end
  
  def revoke_consent(patient_id, purpose) do
    # LGPD Art. 18, VIII (Right to revoke)
    consent = Healthcare.Repo.get_by!(Consent, patient_id: patient_id, purpose: purpose)
    
    Healthcare.Repo.update(Ecto.Changeset.change(consent,
      revoked_at: DateTime.utc_now()
    ))
    
    Healthcare.AuditLog.write("consent_revoked", patient_id, consent, %{
      compliance: "LGPD_Art_18_VIII"
    })
  end
end
```

---

### 5. Data Retention vs Right to Deletion

**Conflict**: LGPD Art. 18 (right to deletion) vs HIPAA 164.530(j) (6-year retention).

#### LGPD Art. 18 (Data Subject Rights)
> "XVI - eliminação dos dados pessoais tratados com o consentimento do titular"

**Right to Deletion**: Patient can request data deletion.

#### HIPAA 164.530(j) (Documentation)
> "Maintain the policies and procedures... for 6 years from the date of its creation or the date when it last was in effect, whichever is later."

**Retention**: Medical records must be kept for 6 years.

#### Resolution Strategy
**Soft Delete + Compliance Flag**:
```elixir
defmodule Healthcare.Patients do
  def request_deletion(patient_id) do
    patient = Healthcare.Repo.get!(Patient, patient_id)
    
    # Check if retention period expired (6 years from last visit)
    last_visit = Healthcare.Visits.get_last_visit(patient_id)
    retention_deadline = DateTime.add(last_visit.date, 6 * 365, :day)
    
    if DateTime.compare(DateTime.utc_now(), retention_deadline) == :gt do
      # HIPAA retention expired, safe to delete (LGPD Art. 18)
      Healthcare.Repo.delete(patient)
      
      Healthcare.AuditLog.write("patient_data_deleted", patient_id, patient, %{
        compliance: "LGPD_Art_18_after_HIPAA_retention",
        retention_deadline: retention_deadline
      })
    else
      # HIPAA retention active, soft delete with anonymization
      Healthcare.Repo.update(Ecto.Changeset.change(patient,
        name: "ANONYMIZED_#{patient.id}",
        cpf: nil, # Remove PII
        deletion_requested_at: DateTime.utc_now(),
        deletion_reason: "LGPD_Art_18_request",
        hipaa_retention_until: retention_deadline
      ))
      
      Healthcare.AuditLog.write("patient_data_anonymized", patient_id, patient, %{
        compliance: "LGPD_Art_18_with_HIPAA_retention_pending",
        full_deletion_after: retention_deadline
      })
    end
  end
end
```

---

## CFM Resolutions (Brazilian Medical Council)

### CFM 1.821/2007 (Electronic Medical Records)
**Requirements**:
- Digital signature (Art. 5)
- Backup and disaster recovery (Art. 7)
- Data integrity guarantees

**Implementation**: Dilithium3 signatures (see [CRYSTALS-Dilithium](../post-quantum-crypto/crystals-dilithium.md))

### CFM 2.314/2022 (Telemedicine)
**Requirements**:
- Patient authentication (Art. 3)
- End-to-end encryption (Art. 5)
- Digital signature for prescriptions (Art. 7)

**Implementation**: Zero Trust + PQC (see [ADR 004](../../01-ARCHITECTURE/adrs/004-zero-trust-implementation.md))

---

## Compliance Checklist

### LGPD Compliance
- [ ] **Art. 8**: Explicit consent mechanism implemented
- [ ] **Art. 18**: Data subject rights portal (access, deletion, portability)
- [ ] **Art. 46**: Security safeguards (encryption, access control, audit logs)
- [ ] **Art. 48**: Breach notification process (72 hours)

### HIPAA Compliance
- [ ] **164.312(a)(1)**: Access control (unique user IDs, emergency access)
- [ ] **164.312(b)**: Audit controls (immutable logs, 6-year retention)
- [ ] **164.312(e)(1)**: Transmission security (TLS 1.3 + PQC)
- [ ] **164.408**: Breach notification (60 days)

### CFM Compliance
- [ ] **CFM 1.821/2007 Art. 5**: Digital signatures (Dilithium3)
- [ ] **CFM 2.314/2022 Art. 3**: Patient authentication (MFA)
- [ ] **CFM 2.314/2022 Art. 5**: E2E encryption (Kyber-768)

---

## References

### Legal Documents
- [LGPD - Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) (L0_CANONICAL)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html) (L0_CANONICAL)
- [CFM 1.821/2007](https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2007/1821) (L0_CANONICAL)
- [CFM 2.314/2022](https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2022/2314) (L0_CANONICAL)

### Implementation Guides
- [NIST SP 800-66 (HIPAA Implementation Guide)](https://csrc.nist.gov/publications/detail/sp/800-66/rev-2/final) (L0_CANONICAL)
- [ANPD LGPD Implementation Guide](https://www.gov.br/anpd/pt-br/assuntos/noticias) (L0_CANONICAL)

---

**DSM**: [L1:security | L2:healthcare | L3:compliance | L4:reference]
**Source**: `03-zero-trust-security-healthcare.md` (compliance sections)
**Version**: 1.0.0
**Related**:
- [ADR 004: Zero Trust Implementation](../../01-ARCHITECTURE/adrs/004-zero-trust-implementation.md)
- [NIST SP 800-207](../zero-trust/nist-sp-800-207.md)
