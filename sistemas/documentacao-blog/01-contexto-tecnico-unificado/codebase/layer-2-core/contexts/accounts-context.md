# Healthcare CMS - Accounts Context

> **Level**: 2 (Core) | **Read Time**: 20-30min | **Tokens**: ~8K
> **Audience**: Backend developers, security engineers
> **Last Validated**: 2025-09-30

---

## 📋 Context Overview

### Purpose

**Accounts Context** manages user authentication, authorization, and healthcare professional data with:

- **User management** - CRUD operations for users
- **Authentication** - Email/password with Argon2 hashing
- **Healthcare professionals** - CRM/CRP registry validation
- **Zero Trust integration** - Trust level tracking per user
- **LGPD compliance** - Soft delete, data export support
- **Multi-tenancy** - Tenant-scoped user isolation

### Files

```
lib/healthcare_cms/
├── accounts.ex                    # Public API (102 lines)
└── accounts/
    └── user.ex                    # User schema (247 lines)
```

**Total LOC**: 349 lines

---

## 🗄️ Database Schema

### Users Table

```sql
CREATE TABLE users (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Basic User Fields
  email VARCHAR(160) NOT NULL UNIQUE,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'active',
    -- Values: active, inactive, suspended, deleted

  -- Authentication Fields
  password_hash VARCHAR(255),
  confirmed_at TIMESTAMP,

  -- WordPress Compatibility
  username VARCHAR(255) UNIQUE,
  display_name VARCHAR(255),
  role VARCHAR(50) DEFAULT 'subscriber',
    -- Values: subscriber, contributor, author, editor, administrator,
    --         medical_professional, medical_admin, compliance_officer

  -- Healthcare Specific Fields
  professional_registry VARCHAR(50),    -- e.g., "CRM/SP 123456"
  registry_state CHAR(2),               -- e.g., "SP", "RJ"
  registry_verified BOOLEAN DEFAULT false,
  specialty VARCHAR(255),
  healthcare_institution VARCHAR(255),

  -- Zero Trust Context Fields
  trust_level INTEGER DEFAULT 50,       -- 0-100 score
  last_trust_evaluation TIMESTAMP,
  mfa_enabled BOOLEAN DEFAULT false,
  device_fingerprints TEXT[],           -- Array of known devices

  -- Audit Fields
  last_login_at TIMESTAMP,
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until TIMESTAMP,
  deleted_at TIMESTAMP,

  -- Multi-Tenancy
  tenant_id UUID,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_professional_registry ON users(professional_registry);
```

**Key Constraints**:
- `email` - UNIQUE, required, max 160 chars
- `username` - UNIQUE, auto-generated from email
- `status` - Enum constraint (active/inactive/suspended/deleted)
- `role` - Enum constraint (8 predefined roles)

---

## 📦 User Schema (`user.ex`)

### Schema Definition

```elixir
defmodule HealthcareCMS.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    # Basic user fields (5)
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :status, Ecto.Enum, values: [:active, :inactive, :suspended, :deleted]

    # Authentication fields (3)
    field :password_hash, :string
    field :password, :string, virtual: true  # Never persisted
    field :confirmed_at, :utc_datetime

    # WordPress compatibility (3)
    field :username, :string
    field :display_name, :string
    field :role, Ecto.Enum, values: [
      :subscriber, :contributor, :author, :editor, :administrator,
      :medical_professional, :medical_admin, :compliance_officer
    ]

    # Healthcare specific (5)
    field :professional_registry, :string   # "CRM/SP 123456"
    field :registry_state, :string          # "SP"
    field :registry_verified, :boolean
    field :specialty, :string
    field :healthcare_institution, :string

    # Zero Trust context (4)
    field :trust_level, :integer            # 0-100
    field :last_trust_evaluation, :utc_datetime
    field :mfa_enabled, :boolean
    field :device_fingerprints, {:array, :string}

    # Audit fields (4)
    field :last_login_at, :utc_datetime
    field :failed_login_attempts, :integer
    field :locked_until, :utc_datetime
    field :deleted_at, :utc_datetime

    # Multi-tenancy (1)
    field :tenant_id, :binary_id

    timestamps()
  end
end
```

**Total Fields**: 25 (excluding `inserted_at`, `updated_at`)

---

## 🔧 Changesets

### 1. Standard Changeset (`changeset/2`)

**Use Case**: Update existing user, validate form input

```elixir
def changeset(user, attrs) do
  user
  |> cast(attrs, @required_fields ++ @optional_fields ++ [:password])
  |> validate_required([:email, :first_name, :last_name])
  |> validate_email()
  |> maybe_validate_password()
  |> validate_professional_registry()
  |> generate_username()
  |> generate_display_name()
  |> unique_constraint(:email)
  |> unique_constraint(:username)
end
```

**Validations**:
1. **Email**:
   - Required
   - Format: `^[^\s]+@[^\s]+\.[^\s]+$`
   - Max length: 160 characters
   - Unique constraint

2. **Name**:
   - `first_name` required
   - `last_name` required
   - Supports `name` field split (e.g., "John Doe" → first: "John", last: "Doe")

3. **Password** (if provided):
   - Min length: 8 characters
   - Complexity requirements:
     - At least 1 lowercase letter
     - At least 1 uppercase letter
     - At least 1 digit
     - At least 1 special character
   - Hashed with Argon2 (never stored plaintext)

4. **Professional Registry** (optional):
   - Format: `CRM/UF NUMERO` (e.g., "CRM/SP 123456")
   - Valid councils: CRM, CRP, COREN, CRF, CRN, CRO
   - Valid states: 2-letter UF (e.g., SP, RJ, MG)
   - Number: 4-6 digits
   - Regex: `^(CRM|CRP|COREN|CRF|CRN|CRO)\/[A-Z]{2}\s\d{4,6}$`
   - If valid, automatically sets:
     - `role` → `:medical_professional`
     - `registry_verified` → `false` (requires external validation)

5. **Username**:
   - Auto-generated from email (before @)
   - Removes non-word characters
   - Lowercase only
   - Unique constraint

6. **Display Name**:
   - Auto-generated from `first_name` + `last_name`

---

### 2. Registration Changeset (`registration_changeset/2`)

**Use Case**: New user registration (password required)

```elixir
def registration_changeset(user, attrs) do
  user
  |> changeset(attrs)
  |> cast(attrs, [:password])
  |> validate_required([:password])
  |> validate_length(:password, min: 8)
  |> validate_password_complexity()
  |> hash_password()
end
```

**Difference from `changeset/2`**:
- Password is **required** (not optional)
- Always validates and hashes password

---

## 🔐 Password Hashing

### Argon2 Configuration

```elixir
defp hash_password(changeset) do
  case get_change(changeset, :password) do
    nil -> changeset
    password ->
      changeset
      |> put_change(:password_hash, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)  # Remove plaintext
  end
end
```

**Parameters** (configured in `config/config.exs`):
```elixir
config :argon2_elixir,
  t_cost: 4,          # Time cost (iterations)
  m_cost: 65536,      # Memory cost (64MB)
  parallelism: 2      # Number of threads
```

**Security Properties**:
- ✅ **Memory-hard**: Resistant to GPU attacks
- ✅ **Side-channel resistant**: Constant-time comparison
- ✅ **Configurable cost**: Future-proof against hardware improvements
- ✅ **Winner of Password Hashing Competition** (2015)

**OWASP Compliant**: Meets ASVS Level 2 requirements

---

## 🔍 Helper Functions

### 1. Password Validation (`valid_password?/2`)

```elixir
def valid_password?(%User{password_hash: hash}, password)
    when is_binary(hash) and byte_size(password) > 0 do
  Argon2.verify_pass(password, hash)
end

def valid_password?(_, _), do: false
```

**Usage**:
```elixir
user = Accounts.get_user_by_email("doctor@example.com")
User.valid_password?(user, "MyPassword123!")
# => true/false
```

**Security Note**: Uses constant-time comparison (timing attack resistant)

---

### 2. Medical Professional Checks

```elixir
# Check if user is medical professional
def medical_professional?(%User{role: role})
    when role in [:medical_professional, :medical_admin], do: true
def medical_professional?(_), do: false

# Check if registry is verified
def verified_professional?(%User{registry_verified: true}), do: true
def verified_professional?(_), do: false
```

**Usage**:
```elixir
if User.medical_professional?(user) do
  # Allow medical content creation
end

if User.verified_professional?(user) do
  # Allow prescription writing (requires CFM verification)
end
```

---

### 3. Full Name (`full_name/1`)

```elixir
def full_name(%User{first_name: first, last_name: last}) do
  "#{first} #{last}"
end
```

**Usage**:
```elixir
User.full_name(user)  # => "Dr. João Silva"
```

---

## 🌐 Public API (`accounts.ex`)

### CRUD Operations

#### 1. List Users (`list_users/0`)

```elixir
def list_users do
  Repo.all(User)
end
```

**Returns**: List of all users

**⚠️ Security Note**: Should be filtered by tenant in production

---

#### 2. Get User by ID (`get_user!/1`)

```elixir
def get_user!(id), do: Repo.get!(User, id)
```

**Raises**: `Ecto.NoResultsError` if user not found

---

#### 3. Get User by Email (`get_user_by_email/1`)

```elixir
def get_user_by_email(email) do
  Repo.get_by(User, email: email)
end
```

**Returns**: `%User{}` or `nil`

---

#### 4. Create User (`create_user/1`)

```elixir
def create_user(attrs \\ %{}) do
  %User{}
  |> User.changeset(attrs)
  |> Repo.insert()
end
```

**Example**:
```elixir
{:ok, user} = Accounts.create_user(%{
  email: "doctor@example.com",
  first_name: "João",
  last_name: "Silva",
  password: "MySecurePass123!",
  professional_registry: "CRM/SP 123456",
  specialty: "Cardiologia"
})
```

**Returns**: `{:ok, %User{}}` or `{:error, %Ecto.Changeset{}}`

---

#### 5. Update User (`update_user/2`)

```elixir
def update_user(%User{} = user, attrs) do
  user
  |> User.changeset(attrs)
  |> Repo.update()
end
```

**Example**:
```elixir
{:ok, user} = Accounts.update_user(user, %{
  specialty: "Cardiologia Pediátrica",
  registry_verified: true
})
```

---

#### 6. Delete User (`delete_user/1`) ⚠️

```elixir
def delete_user(%User{} = user) do
  user
  |> User.changeset(%{status: :deleted, deleted_at: DateTime.utc_now()})
  |> Repo.update()
end
```

**⚠️ LGPD Compliance**: Soft delete (status change, not `Repo.delete!`)

**Why Soft Delete?**:
- **CFM Res. 1.821/2007**: Medical records must be retained for 20 years
- **LGPD Art. 16**: Audit trail required
- **Legal**: User data may be required for litigation

**True Delete** (anonymization): Use `HealthcareCMS.LGPD.DataDeletion.delete_user_data/2`

---

### Authentication

#### `authenticate_user/2`

```elixir
def authenticate_user(email, password) do
  user = get_user_by_email(email)

  cond do
    user && User.valid_password?(user, password) && user.status == :active ->
      {:ok, user}

    user && user.status != :active ->
      {:error, :user_inactive}

    true ->
      # Prevent timing attacks
      Argon2.no_user_verify()
      {:error, :invalid_credentials}
  end
end
```

**Returns**:
- `{:ok, %User{}}` - Valid credentials, active user
- `{:error, :user_inactive}` - Valid credentials, inactive/suspended user
- `{:error, :invalid_credentials}` - Invalid email or password

**Security Features**:
1. **Timing Attack Prevention**: `Argon2.no_user_verify()` runs same computation time even for non-existent users
2. **Status Check**: Only `:active` users can authenticate
3. **Constant-Time Password Comparison**: `Argon2.verify_pass/2`

**Usage**:
```elixir
case Accounts.authenticate_user(email, password) do
  {:ok, user} ->
    # Generate JWT token
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    {:ok, token, user}

  {:error, :user_inactive} ->
    {:error, "Your account has been suspended"}

  {:error, :invalid_credentials} ->
    {:error, "Invalid email or password"}
end
```

---

#### `update_last_login/1`

```elixir
def update_last_login(%User{} = user) do
  update_user(user, %{last_login_at: DateTime.utc_now()})
end
```

**Purpose**: Track last login for audit and security monitoring

---

## 🏥 Healthcare Professional Validation

### Professional Registry Format

**Valid Formats**:
```
CRM/SP 123456    # Conselho Regional de Medicina
CRP/RJ 12345     # Conselho Regional de Psicologia
COREN/MG 1234567 # Conselho Regional de Enfermagem
CRF/BA 12345     # Conselho Regional de Farmácia
CRN/RS 12345     # Conselho Regional de Nutrição
CRO/PE 123456    # Conselho Regional de Odontologia
```

**Regex**: `^(CRM|CRP|COREN|CRF|CRN|CRO)\/[A-Z]{2}\s\d{4,6}$`

**Automatic Effects**:
- Sets `role` → `:medical_professional`
- Sets `registry_verified` → `false` (requires external verification)

---

### External Verification (Planned - Sprint 2)

**TODO**: Integrate with CFM/CRP APIs for registry validation

```elixir
# Future implementation
defmodule HealthcareCMS.Accounts.RegistryVerifier do
  def verify_crm(registry, state) do
    # Call CFM API to verify CRM number
    # https://portal.cfm.org.br/api/medicos/verificar
  end

  def verify_crp(registry, state) do
    # Call CFP API to verify CRP number
  end
end
```

---

## 🛡️ Zero Trust Integration

### Trust Level Field

```elixir
field :trust_level, :integer, default: 50  # 0-100 score
field :last_trust_evaluation, :utc_datetime
```

**Purpose**: Stores calculated trust score from `PolicyEngine`

**Score Ranges**:
- `0-30` - Low trust (new user, suspicious activity)
- `31-70` - Medium trust (normal user)
- `71-100` - High trust (verified professional, MFA enabled)

**Updated By**: `HealthcareCMS.Security.TrustAlgorithm.calculate_score/1`

---

### Device Fingerprints

```elixir
field :device_fingerprints, {:array, :string}, default: []
```

**Purpose**: Track known/trusted devices for user

**Example**:
```elixir
user.device_fingerprints
# => [
#   "fp_abc123_chrome_windows",
#   "fp_xyz789_safari_macos"
# ]
```

**Trust Score Bonus**: +15 points for known device

---

### MFA (Multi-Factor Authentication)

```elixir
field :mfa_enabled, :boolean, default: false
```

**Status**: Planned (Sprint 2)

**Trust Score Bonus**: +30 points when enabled

---

## 🔐 Security Best Practices

### 1. Password Policy

**Requirements**:
- Minimum 8 characters
- 1 lowercase letter
- 1 uppercase letter
- 1 digit
- 1 special character

**Enforced By**: `validate_password_complexity/1`

---

### 2. Account Lockout (TODO - Sprint 2)

**Planned Implementation**:
```elixir
field :failed_login_attempts, :integer, default: 0
field :locked_until, :utc_datetime
```

**Policy**:
- Lock account after 5 failed attempts
- Lockout duration: 15 minutes
- Requires email verification to unlock

---

### 3. Soft Delete for Compliance

**LGPD Art. 18, VI**: Users have right to deletion

**Implementation**:
```elixir
def delete_user(%User{} = user) do
  user
  |> User.changeset(%{
    status: :deleted,
    deleted_at: DateTime.utc_now()
  })
  |> Repo.update()
end
```

**Query Filter** (exclude deleted users):
```elixir
from(u in User, where: u.status != :deleted)
```

---

## 🧪 Testing

### Test Coverage

**Status**: ⚠️ 0% (Tests not yet implemented - Sprint 1 backlog)

**Planned Tests** (`test/healthcare_cms/accounts_test.exs`):
```elixir
defmodule HealthcareCMS.AccountsTest do
  use HealthcareCMS.DataCase

  describe "list_users/0" do
    # Test user listing
  end

  describe "create_user/1" do
    # Test user creation with valid/invalid attrs
    # Test professional registry validation
    # Test password complexity
  end

  describe "authenticate_user/2" do
    # Test valid authentication
    # Test invalid credentials
    # Test inactive user
    # Test timing attack prevention
  end

  describe "User.changeset/2" do
    # Test email validation
    # Test username generation
    # Test display_name generation
  end
end
```

**Target Coverage**: 85%+

---

## 📊 Usage Examples

### Example 1: User Registration

```elixir
# Phoenix Controller
defmodule HealthcareCMSWeb.RegistrationController do
  use HealthcareCMSWeb, :controller
  alias HealthcareCMS.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        # Send confirmation email
        Mailer.send_confirmation_email(user)

        conn
        |> put_flash(:info, "Account created successfully!")
        |> redirect(to: "/login")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
```

---

### Example 2: Medical Professional Registration

```elixir
# LiveView form
def handle_event("save", %{"user" => user_params}, socket) do
  attrs = Map.merge(user_params, %{
    "professional_registry" => "CRM/SP 123456",
    "specialty" => "Cardiologia",
    "healthcare_institution" => "Hospital das Clínicas"
  })

  case Accounts.create_user(attrs) do
    {:ok, user} ->
      # Automatically gets role: :medical_professional
      # registry_verified: false (requires CFM API check)

      {:noreply, socket
        |> put_flash(:info, "Registration successful. Awaiting registry verification.")
        |> push_navigate(to: ~p"/dashboard")}

    {:error, changeset} ->
      {:noreply, assign(socket, :changeset, changeset)}
  end
end
```

---

### Example 3: Authentication Flow

```elixir
# auth_controller.ex
def login(conn, %{"email" => email, "password" => password}) do
  case Accounts.authenticate_user(email, password) do
    {:ok, user} ->
      # Update last login
      Accounts.update_last_login(user)

      # Calculate trust score
      trust_score = PolicyEngine.calculate_initial_trust(user)

      # Generate JWT
      {:ok, token, _claims} = Guardian.encode_and_sign(user, %{
        trust_score: trust_score
      })

      json(conn, %{
        token: token,
        user: %{
          id: user.id,
          email: user.email,
          full_name: User.full_name(user),
          role: user.role
        }
      })

    {:error, reason} ->
      conn
      |> put_status(401)
      |> json(%{error: to_string(reason)})
  end
end
```

---

## 🔗 Related Documentation

- **Layer 1 Overview**: `../layer-1-overview/project-structure.md`
- **Zero Trust Architecture**: `../../architecture/decisions-adr/002-zero-trust-architecture.md`
- **Guardian JWT Auth**: `../../architecture/decisions-adr/005-guardian-jwt-auth.md`
- **Security Context**: `./security-context.md` (next)
- **LGPD Compliance**: `../../_meta/critical-warnings.md`

---

## 🚧 Roadmap

### Sprint 1 (Current)
- [ ] Implement test suite (target: 85% coverage)
- [ ] Add account lockout mechanism
- [ ] Email confirmation flow

### Sprint 2
- [ ] MFA (TOTP, SMS, biometric)
- [ ] Professional registry external verification (CFM/CRP API)
- [ ] Password reset flow
- [ ] Session management (active sessions list)

### Sprint 3+
- [ ] OAuth2 social login (Google, Apple)
- [ ] Biometric authentication (WebAuthn)
- [ ] User activity timeline
- [ ] LGPD data export automation

---

**Version**: 1.0.0 | **Created**: 2025-09-30 | **Status**: 🔄 Active Development
