# ⚠️ Healthcare CMS - Critical Warnings & Compliance

> **Level**: 0 (Meta) | **Read Time**: 15min | **Tokens**: ~2K
> **Audience**: ALL developers, architects, legal, compliance officers
> **Last Updated**: 2025-09-30
> **Importance**: 🔴 CRITICAL - Read before making ANY code changes

---

## 🚨 READ THIS FIRST

**This document contains MANDATORY compliance requirements**. Failure to follow these guidelines may result in:

- ⚖️ **Legal liability**: LGPD fines up to R$ 50 million (Art. 52)
- 🏥 **Medical license suspension**: CFM sanctions for healthcare professionals
- 🚫 **Platform shutdown**: ANVISA enforcement actions
- 💰 **Financial penalties**: Regulatory fines + civil lawsuits
- 👤 **Personal liability**: Directors and developers can be held personally responsible

**If you have ANY doubt, consult the compliance officer BEFORE deploying.**

---

## 📜 LGPD (Lei 13.709/2018) - Brazilian Data Protection Law

### Art. 7 - Legal Basis for Processing

**🔴 CRITICAL**: You CANNOT process PHI/PII without one of these legal bases:

```yaml
legal_bases:
  1_consent:
    description: "Explicit, informed, unambiguous consent"
    when_to_use: "Patient data collection, medical records"
    code_example: |
      # ✅ CORRECT
      defmodule Accounts do
        def create_user(attrs, consent_token) do
          with {:ok, consent} <- validate_consent_token(consent_token),
               true <- consent.purpose == "medical_record_processing",
               {:ok, user} <- Repo.insert(User.changeset(%User{}, attrs)) do
            log_consent(user.id, consent)
            {:ok, user}
          end
        end
      end

      # ❌ WRONG - No consent validation
      defmodule Accounts do
        def create_user(attrs) do
          Repo.insert(User.changeset(%User{}, attrs))  # Missing consent!
        end
      end

  2_legal_obligation:
    description: "Required by law or regulatory agencies"
    when_to_use: "ANVISA reporting, CFM audits"

  3_legitimate_interest:
    description: "Legitimate interest of controller (must be justified)"
    when_to_use: "Admin support access (with explicit opt-in)"
    warning: "Requires data protection impact assessment (DPIA)"

  4_health_protection:
    description: "Protection of life or physical safety"
    when_to_use: "Emergency medical situations"
    example: "Patient in critical condition, next-of-kin notification"
```

**⚠️ Common Pitfalls**:

```elixir
# ❌ WRONG - Assuming consent
def send_marketing_email(user) do
  Mailer.send(user.email, "Check out our new features!")
  # Violation: Marketing requires explicit consent (LGPD Art. 7, I)
end

# ✅ CORRECT - Check consent first
def send_marketing_email(user) do
  if Consent.has_consent?(user, purpose: "marketing") do
    Mailer.send(user.email, "Check out our new features!")
    log_data_processing(user.id, "marketing_email", "consent")
  else
    {:error, :no_consent}
  end
end
```

---

### Art. 16 - Right to Access & Correction

**🔴 CRITICAL**: Users have the right to:

1. **Confirm data processing** (Art. 18, I)
2. **Access their data** (Art. 18, II)
3. **Correct incomplete data** (Art. 18, III)
4. **Request deletion** (Art. 18, VI) - "Right to be forgotten"
5. **Portability** (Art. 18, V) - Export data in structured format

**Implementation Requirements**:

```elixir
# ✅ REQUIRED - User data export (LGPD Art. 18, V)
defmodule HealthcareCMS.LGPD.DataExport do
  def export_user_data(user_id) do
    user = Accounts.get_user!(user_id)
    posts = Content.list_user_posts(user_id)
    audit_logs = AuditLog.list_user_logs(user_id)
    consents = Consent.list_user_consents(user_id)

    %{
      user: serialize_user(user),
      posts: Enum.map(posts, &serialize_post/1),
      audit_logs: Enum.map(audit_logs, &serialize_audit_log/1),
      consents: Enum.map(consents, &serialize_consent/1),
      exported_at: DateTime.utc_now(),
      format_version: "1.0"
    }
    |> Jason.encode!(pretty: true)
  end
end

# ✅ REQUIRED - User data deletion (LGPD Art. 18, VI)
defmodule HealthcareCMS.LGPD.DataDeletion do
  def delete_user_data(user_id, reason) do
    # 1. Validate legal basis for retention
    case validate_retention_period(user_id) do
      {:ok, :can_delete} ->
        # 2. Anonymize instead of hard delete (medical records)
        anonymize_medical_records(user_id)

        # 3. Hard delete non-medical data
        delete_user_posts(user_id)
        delete_user_sessions(user_id)

        # 4. Log deletion (LGPD Art. 16)
        log_data_deletion(user_id, reason)

        {:ok, :deleted}

      {:error, :retention_period_active} ->
        {:error, "Medical records must be retained for 20 years (CFM Res. 1.821/2007)"}
    end
  end
end
```

**⚠️ Common Pitfalls**:

```elixir
# ❌ WRONG - Hard delete without retention check
def delete_user(user_id) do
  Repo.delete!(Accounts.get_user!(user_id))
  # Violation: May violate CFM 20-year retention requirement
end

# ❌ WRONG - No anonymization option
def delete_user(user_id) do
  Repo.delete!(Accounts.get_user!(user_id))
  # Violation: Medical records should be anonymized, not deleted
end
```

---

### Art. 46 - International Data Transfer

**🔴 CRITICAL**: Transferring data outside Brazil requires:

1. **Adequate level of protection** in destination country
2. **Specific contractual clauses** (Standard Contractual Clauses)
3. **User consent** OR **legitimate interest justification**

**❌ PROHIBITED Actions**:

```elixir
# ❌ WRONG - Direct S3 upload to US region
def upload_patient_record(file) do
  ExAws.S3.put_object("my-us-bucket", "records/#{file.name}", file.content)
  |> ExAws.request!()
  # Violation: Transferring PHI to USA without proper safeguards
end

# ✅ CORRECT - Upload to Brazil region with encryption
def upload_patient_record(file) do
  encrypted = encrypt_file(file)

  ExAws.S3.put_object(
    "my-sa-east-1-bucket",  # São Paulo region
    "records/#{file.name}",
    encrypted,
    server_side_encryption: "AES256",
    metadata: %{"lgpd-compliant" => "true"}
  )
  |> ExAws.request!()
end
```

---

### Art. 48 - Data Breach Notification

**🔴 CRITICAL**: In case of data breach, you MUST:

1. **Notify ANPD** (Brazilian Data Protection Authority) - **Immediately**
2. **Notify affected users** - **Reasonable timeframe**
3. **Document incident** - Investigation, impact assessment, remediation

**Implementation**:

```elixir
# ✅ REQUIRED - Data breach response
defmodule HealthcareCMS.Security.BreachResponse do
  @anpd_notification_email "notificacao@anpd.gov.br"

  def handle_data_breach(incident) do
    # 1. Assess severity
    severity = assess_breach_severity(incident)

    # 2. Notify ANPD (LGPD Art. 48, §1º)
    if severity in [:high, :critical] do
      notify_anpd(incident)
    end

    # 3. Notify affected users (LGPD Art. 48, §2º)
    affected_users = identify_affected_users(incident)
    Enum.each(affected_users, &notify_user_breach(&1, incident))

    # 4. Document incident
    IncidentLog.create(%{
      incident_id: incident.id,
      severity: severity,
      affected_count: length(affected_users),
      notification_sent_at: DateTime.utc_now(),
      remediation_steps: incident.remediation
    })

    # 5. Activate incident response plan
    SecurityTeam.activate_incident_response(incident)
  end
end
```

---

## 🏥 CFM (Conselho Federal de Medicina) - Medical Council

### Resolução 1.821/2007 - Prontuário Eletrônico (Electronic Medical Records)

**🔴 CRITICAL**: Electronic medical records MUST have:

1. **Digital signature** - ICP-Brasil certificate (CFM Art. 4º)
2. **20-year retention** - Minimum storage period (CFM Art. 6º)
3. **Audit trail** - All access/modifications logged (CFM Art. 5º)
4. **Backup policy** - Daily backups, off-site storage (CFM Art. 7º)

**Implementation**:

```elixir
# ✅ REQUIRED - Medical record with digital signature
defmodule HealthcareCMS.Medical.MedicalRecord do
  use Ecto.Schema

  schema "medical_records" do
    field :patient_id, :binary_id
    field :doctor_id, :binary_id
    field :content, :string
    field :digital_signature, :string  # ICP-Brasil certificate
    field :signature_timestamp, :utc_datetime
    field :retention_until, :date      # created_at + 20 years

    timestamps()
  end

  def create_medical_record(attrs, doctor_certificate) do
    record = %MedicalRecord{}
      |> changeset(attrs)
      |> put_retention_date()

    with {:ok, record} <- Repo.insert(record),
         {:ok, signature} <- sign_record(record, doctor_certificate) do

      record
      |> change(%{
        digital_signature: signature,
        signature_timestamp: DateTime.utc_now()
      })
      |> Repo.update()
    end
  end

  defp put_retention_date(changeset) do
    retention_date = Date.utc_today() |> Date.add(365 * 20)  # 20 years
    put_change(changeset, :retention_until, retention_date)
  end
end

# ✅ REQUIRED - Audit trail for all accesses
defmodule HealthcareCMS.Medical.AuditLog do
  def log_medical_record_access(user_id, record_id, action) do
    %AuditLog{
      user_id: user_id,
      resource: "MedicalRecord:#{record_id}",
      action: action,
      ip_address: get_ip_address(),
      timestamp: DateTime.utc_now(),
      immutable: true  # Cannot be modified or deleted
    }
    |> Repo.insert!()
  end
end
```

**❌ PROHIBITED Actions**:

```elixir
# ❌ WRONG - Deleting medical records before 20 years
def delete_medical_record(record_id) do
  Repo.delete!(MedicalRecord.get!(record_id))
  # Violation: CFM Res. 1.821/2007 Art. 6º (20-year retention)
end

# ❌ WRONG - No digital signature
def create_medical_record(attrs) do
  Repo.insert(MedicalRecord.changeset(%MedicalRecord{}, attrs))
  # Violation: CFM Res. 1.821/2007 Art. 4º (digital signature required)
end
```

---

### Resolução 2.314/2022 - Telemedicina

**🔴 CRITICAL**: Telemedicine platforms MUST have:

1. **Patient authentication** - Secure identity verification (CFM Art. 5º)
2. **End-to-end encryption** - TLS 1.3 minimum (CFM Art. 8º)
3. **Recording consent** - For video consultations (CFM Art. 9º)
4. **Emergency protocols** - In-person referral process (CFM Art. 11º)

**Implementation**:

```elixir
# ✅ REQUIRED - Telemedicine session with consent
defmodule HealthcareCMS.Telemedicine.Session do
  def create_session(doctor_id, patient_id, attrs) do
    with {:ok, consent} <- validate_recording_consent(patient_id),
         {:ok, session} <- Repo.insert(Session.changeset(%Session{}, attrs)),
         {:ok, _token} <- generate_secure_token(session) do

      # Log consent for recording (CFM Res. 2.314/2022 Art. 9º)
      log_recording_consent(patient_id, session.id, consent)

      {:ok, session}
    else
      {:error, :no_recording_consent} ->
        {:error, "Patient must consent to recording (CFM Res. 2.314/2022)"}
    end
  end
end
```

---

## 🔬 ANVISA (Agência Nacional de Vigilância Sanitária) - Health Surveillance

### RDC 302/2005 - Laboratórios Clínicos (Clinical Laboratories)

**🔴 CRITICAL** (if handling laboratory results):

1. **Result validation** - Technical director signature required
2. **Quality control** - Internal/external quality programs
3. **Traceability** - Complete result audit trail
4. **Result security** - Prevent unauthorized modifications

**Implementation**:

```elixir
# ✅ REQUIRED - Laboratory result with validation
defmodule HealthcareCMS.Laboratory.Result do
  use Ecto.Schema

  schema "laboratory_results" do
    field :patient_id, :binary_id
    field :test_type, :string
    field :result_value, :decimal
    field :reference_range, :string
    field :status, Ecto.Enum, values: [:pending, :validated, :released]
    field :validated_by, :binary_id      # Technical director
    field :validated_at, :utc_datetime
    field :validation_signature, :string

    timestamps()
  end

  def validate_result(result_id, technical_director_id) do
    result = Repo.get!(Result, result_id)

    with {:ok, director} <- validate_technical_director(technical_director_id),
         {:ok, signature} <- sign_result(result, director.certificate) do

      result
      |> change(%{
        status: :validated,
        validated_by: technical_director_id,
        validated_at: DateTime.utc_now(),
        validation_signature: signature
      })
      |> Repo.update()
    end
  end
end
```

---

## 🔐 Security Best Practices

### 1. Password Storage

```elixir
# ✅ CORRECT - Argon2id with proper parameters
defmodule Accounts.User do
  def hash_password(password) do
    Argon2.hash_pwd_salt(password,
      t_cost: 4,          # Time cost
      m_cost: 65_536,     # Memory cost (64MB)
      parallelism: 2      # Threads
    )
  end
end

# ❌ WRONG - Weak hashing
def hash_password(password) do
  :crypto.hash(:sha256, password) |> Base.encode16()
  # Violation: SHA-256 is not designed for passwords
end
```

### 2. SQL Injection Prevention

```elixir
# ✅ CORRECT - Parameterized query
def search_posts(query) do
  from(p in Post, where: ilike(p.title, ^"%#{query}%"))
  |> Repo.all()
end

# ❌ WRONG - String interpolation
def search_posts(query) do
  Repo.query!("SELECT * FROM posts WHERE title LIKE '%#{query}%'")
  # Vulnerability: SQL injection
end
```

### 3. XSS Prevention

```elixir
# ✅ CORRECT - Phoenix.HTML auto-escapes
def render_post(assigns) do
  ~H"""
  <h1><%= @post.title %></h1>
  <p><%= @post.body %></p>
  """
  # Automatically escaped by Phoenix.HTML
end

# ❌ WRONG - Raw HTML
def render_post(assigns) do
  Phoenix.HTML.raw("<h1>#{@post.title}</h1>")
  # Vulnerability: XSS if title contains <script>
end
```

---

## 📋 Pre-Deployment Checklist

Before deploying ANY change, verify:

### LGPD Compliance
- [ ] Legal basis documented for all PHI/PII processing
- [ ] User consent flows implemented
- [ ] Data export functionality available (Art. 18, V)
- [ ] Data deletion/anonymization implemented (Art. 18, VI)
- [ ] Audit logging enabled (Art. 16)
- [ ] Data breach response plan tested (Art. 48)

### CFM Compliance
- [ ] Digital signatures implemented (ICP-Brasil)
- [ ] 20-year retention policy enforced
- [ ] Audit trail immutable
- [ ] Backup policy validated
- [ ] Telemedicine consent flows (if applicable)

### ANVISA Compliance
- [ ] Laboratory result validation (if applicable)
- [ ] Quality control documented
- [ ] Traceability complete

### Security
- [ ] No hardcoded secrets (check with `sobelow`)
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (Phoenix.HTML escaping)
- [ ] CSRF tokens validated
- [ ] TLS 1.3 enforced
- [ ] Password hashing (Argon2id)

### Zero Trust
- [ ] Trust score calculation tested
- [ ] Policy Engine operational
- [ ] RLS policies applied
- [ ] Admin blind enforcement verified

---

## 🆘 Emergency Contacts

### Internal
- **Compliance Officer**: compliance@healthcare-cms.com
- **Security Team**: security@healthcare-cms.com
- **Legal Counsel**: legal@healthcare-cms.com

### External
- **ANPD** (Data Protection): https://www.gov.br/anpd/pt-br
- **CFM** (Medical Council): https://portal.cfm.org.br/
- **ANVISA** (Health Surveillance): https://www.gov.br/anvisa/pt-br

---

## 📚 Reference Laws & Regulations

### LGPD
- **Full Text**: http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm
- **ANPD Guidelines**: https://www.gov.br/anpd/pt-br/assuntos/guias

### CFM
- **Res. 1.821/2007**: https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2007/1821
- **Res. 2.314/2022**: https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2022/2314

### ANVISA
- **RDC 302/2005**: https://bvsms.saude.gov.br/bvs/saudelegis/anvisa/2005/res0302_13_10_2005.html

---

**🔴 REMEMBER**: When in doubt, ask FIRST. Compliance violations can shut down the entire platform.

**Version**: 1.0.0 | **Created**: 2025-09-30 | **Review**: Quarterly
