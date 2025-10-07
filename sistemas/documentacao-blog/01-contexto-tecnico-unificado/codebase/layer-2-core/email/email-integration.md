# Email Integration - Swoosh Mailer

**DSM**: `L1_DOMAIN:integration` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:implementation`
**Layer**: 2 (Core) - Email Delivery System
**Status**: ✅ Production (Sprint 0-1)
**Read Time**: ~8 minutes
**Codebase Evidence**: `mix.exs`, `config/config.exs`, `lib/healthcare_cms/mailer.ex`

---

## Overview

Healthcare CMS uses **Swoosh** (v1.17+) for transactional email delivery with SMTP/SendGrid integration. All compliance notifications, security alerts, and user communications are sent with PHI protection and LGPD consent verification.

**Key Features**:
- **Multiple Adapters**: SMTP, SendGrid, Mailgun, AWS SES
- **Email Templates**: HEEx templates with layout support
- **PHI Protection**: Sanitize sensitive data before sending
- **LGPD Compliance**: Verify consent before sending marketing emails
- **Healthcare Notifications**: Compliance alerts, security warnings, password resets
- **Background Delivery**: Oban integration for async sending

---

## Swoosh Installation & Configuration

### 1. Dependencies

**mix.exs**:
```elixir
defp deps do
  [
    {:swoosh, "~> 1.17"},
    {:gen_smtp, "~> 1.2"},  # For SMTP adapter
    {:hackney, "~> 1.20"},  # For HTTP adapters (SendGrid, Mailgun)
    {:jason, "~> 1.4"}      # JSON encoding
  ]
end
```

### 2. Mailer Configuration

**config/config.exs**:
```elixir
# Swoosh mailer
config :healthcare_cms, HealthcareCMS.Mailer,
  adapter: Swoosh.Adapters.Local  # Development: local mailbox

# Swoosh API client (for HTTP adapters)
config :swoosh, :api_client, Swoosh.ApiClient.Hackney

# Local mailbox preview (development)
config :swoosh, local: true
```

**config/runtime.exs** (production):
```elixir
if config_env() == :prod do
  # Production: SendGrid adapter
  config :healthcare_cms, HealthcareCMS.Mailer,
    adapter: Swoosh.Adapters.Sendgrid,
    api_key: System.get_env("SENDGRID_API_KEY")

  # Alternative: SMTP adapter
  # config :healthcare_cms, HealthcareCMS.Mailer,
  #   adapter: Swoosh.Adapters.SMTP,
  #   relay: System.get_env("SMTP_RELAY"),
  #   username: System.get_env("SMTP_USERNAME"),
  #   password: System.get_env("SMTP_PASSWORD"),
  #   ssl: true,
  #   tls: :always,
  #   auth: :always,
  #   port: 587
end
```

### 3. Mailer Module

**lib/healthcare_cms/mailer.ex**:
```elixir
defmodule HealthcareCMS.Mailer do
  use Swoosh.Mailer, otp_app: :healthcare_cms
end
```

---

## Email Templates

### 1. Base Email Module

**lib/healthcare_cms/emails/base_email.ex**:
```elixir
defmodule HealthcareCMS.Emails.BaseEmail do
  @moduledoc """
  Base email module with common functionality.
  """

  import Swoosh.Email

  @from_address {"Healthcare CMS", "noreply@healthcare-cms.example.com"}

  def new do
    %Swoosh.Email{}
    |> from(@from_address)
    |> put_provider_option(:category, "transactional")  # SendGrid category
  end

  def subject(email, subject), do: Swoosh.Email.subject(email, subject)
  def to(email, recipient), do: Swoosh.Email.to(email, recipient)

  def html_body(email, template_path, assigns) do
    html = Phoenix.Template.render_to_string(template_path, assigns)
    Swoosh.Email.html_body(email, html)
  end

  def text_body(email, content), do: Swoosh.Email.text_body(email, content)

  def attach(email, file_path) do
    Swoosh.Email.attachment(email, Swoosh.Attachment.new(file_path))
  end
end
```

### 2. Compliance Alert Emails

**lib/healthcare_cms/emails/compliance_email.ex**:
```elixir
defmodule HealthcareCMS.Emails.ComplianceEmail do
  @moduledoc """
  LGPD/HIPAA compliance notification emails.
  """

  import HealthcareCMS.Emails.BaseEmail

  def unlogged_phi_access(recipient, %{post_ids: post_ids}) do
    new()
    |> to(recipient)
    |> subject("[CRITICAL] Unlogged PHI Access Detected")
    |> text_body("""
    CRITICAL SECURITY ALERT

    Unlogged PHI access detected for posts: #{Enum.join(post_ids, ", ")}

    This is a potential LGPD violation (Art. 46 - Security).
    Immediate investigation required.

    Action Required:
    1. Review audit logs: /admin/audit-logs
    2. Verify user access permissions
    3. Document incident in compliance report

    Healthcare CMS Security Team
    """)
    |> put_provider_option(:category, "security-alert")  # SendGrid category
  end

  def lgpd_consent_missing(recipient, user) do
    new()
    |> to(recipient)
    |> subject("[WARNING] LGPD Consent Missing for User ##{user.id}")
    |> html_body("""
    <h2>LGPD Compliance Warning</h2>

    <p>User <strong>#{user.email}</strong> (ID: #{user.id}) is missing LGPD consent record.</p>

    <h3>Required Actions:</h3>
    <ol>
      <li>Contact user to obtain explicit consent (LGPD Art. 8)</li>
      <li>Suspend data processing until consent is obtained</li>
      <li>Document consent in compliance system</li>
    </ol>

    <p><a href="https://healthcare-cms.example.com/admin/users/#{user.id}/consent">
      Review User Consent
    </a></p>

    <p><em>Healthcare CMS Legal Team</em></p>
    """)
  end

  def cfm_validation_required(recipient, posts) do
    new()
    |> to(recipient)
    |> subject("[NOTICE] CFM Validation Required for #{length(posts)} Posts")
    |> text_body("""
    CFM Validation Notice

    #{length(posts)} medical posts require CFM validation:

    #{Enum.map(posts, fn p -> "- Post ##{p.id}: #{p.title}" end) |> Enum.join("\n")}

    Action Required:
    1. Review medical content for compliance
    2. Run CFM validation workflow: /admin/workflows/cfm-validation
    3. Update medical category if needed

    Regulatory Deadline: 48 hours (CFM Resolução 2.314/2022)

    Healthcare CMS Compliance Team
    """)
  end
end
```

### 3. Authentication Emails

**lib/healthcare_cms/emails/auth_email.ex**:
```elixir
defmodule HealthcareCMS.Emails.AuthEmail do
  @moduledoc """
  Authentication-related emails (password reset, 2FA, etc).
  """

  import HealthcareCMS.Emails.BaseEmail

  def password_reset(recipient, reset_token) do
    reset_url = "https://healthcare-cms.example.com/reset-password/#{reset_token}"

    new()
    |> to(recipient)
    |> subject("Reset Your Password - Healthcare CMS")
    |> html_body("""
    <h2>Password Reset Request</h2>

    <p>You requested a password reset for your Healthcare CMS account.</p>

    <p>Click the link below to reset your password:</p>

    <p><a href="#{reset_url}" style="background: #0066cc; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
      Reset Password
    </a></p>

    <p><strong>This link expires in 1 hour.</strong></p>

    <p>If you didn't request this, please ignore this email or contact support if you have concerns.</p>

    <p><em>Healthcare CMS Security Team</em></p>
    """)
    |> text_body("""
    Password Reset Request

    You requested a password reset for your Healthcare CMS account.

    Reset your password here: #{reset_url}

    This link expires in 1 hour.

    If you didn't request this, please ignore this email or contact support.

    Healthcare CMS Security Team
    """)
  end

  def two_factor_code(recipient, code) do
    new()
    |> to(recipient)
    |> subject("Your Two-Factor Authentication Code")
    |> text_body("""
    Two-Factor Authentication Code

    Your authentication code is: #{code}

    This code expires in 5 minutes.

    If you didn't request this, please contact support immediately.

    Healthcare CMS Security Team
    """)
  end

  def account_locked(recipient, reason) do
    new()
    |> to(recipient)
    |> subject("Account Locked - Healthcare CMS")
    |> html_body("""
    <h2>Account Security Alert</h2>

    <p>Your Healthcare CMS account has been locked.</p>

    <p><strong>Reason:</strong> #{reason}</p>

    <h3>Next Steps:</h3>
    <ol>
      <li>Verify your identity with our support team</li>
      <li>Reset your password if needed</li>
      <li>Review recent account activity</li>
    </ol>

    <p>Contact support: <a href="mailto:support@healthcare-cms.example.com">support@healthcare-cms.example.com</a></p>

    <p><em>Healthcare CMS Security Team</em></p>
    """)
  end
end
```

### 4. User Notification Emails

**lib/healthcare_cms/emails/user_email.ex**:
```elixir
defmodule HealthcareCMS.Emails.UserEmail do
  @moduledoc """
  User-facing notification emails.
  """

  import HealthcareCMS.Emails.BaseEmail

  def welcome(user) do
    new()
    |> to({user.name, user.email})
    |> subject("Welcome to Healthcare CMS")
    |> html_body("""
    <h2>Welcome to Healthcare CMS, #{user.name}!</h2>

    <p>Your account has been created successfully.</p>

    <h3>Getting Started:</h3>
    <ul>
      <li><a href="https://healthcare-cms.example.com/dashboard">Access Your Dashboard</a></li>
      <li><a href="https://healthcare-cms.example.com/docs">Read Documentation</a></li>
      <li><a href="https://healthcare-cms.example.com/profile">Complete Your Profile</a></li>
    </ul>

    <p>Questions? Contact support: <a href="mailto:support@healthcare-cms.example.com">support@healthcare-cms.example.com</a></p>

    <p><em>Healthcare CMS Team</em></p>
    """)
  end

  def post_published(user, post) do
    new()
    |> to({user.name, user.email})
    |> subject("Your Post \"#{post.title}\" Has Been Published")
    |> html_body("""
    <h2>Post Published</h2>

    <p>Your post <strong>#{post.title}</strong> has been published successfully.</p>

    <p><a href="https://healthcare-cms.example.com/posts/#{post.slug}">View Post</a></p>

    <p>Medical Category: #{post.medical_category}</p>
    <p>Compliance Level: #{post.compliance_level}</p>

    <p><em>Healthcare CMS Team</em></p>
    """)
  end

  def cfm_validation_completed(user, post, validation_result) do
    status_color = if validation_result.valid?, do: "green", else: "red"
    status_text = if validation_result.valid?, do: "APPROVED", else: "REJECTED"

    new()
    |> to({user.name, user.email})
    |> subject("CFM Validation #{status_text}: #{post.title}")
    |> html_body("""
    <h2>CFM Validation Complete</h2>

    <p>CFM validation for your post <strong>#{post.title}</strong> is complete.</p>

    <p style="color: #{status_color}; font-weight: bold;">Status: #{status_text}</p>

    #{if validation_result.valid? do
      """
      <p>Your medical content has been approved by CFM validation.</p>
      <p><a href="https://healthcare-cms.example.com/posts/#{post.slug}">View Published Post</a></p>
      """
    else
      """
      <h3>Validation Issues:</h3>
      <ul>
        #{Enum.map(validation_result.errors, fn error -> "<li>#{error}</li>" end) |> Enum.join("\n")}
      </ul>
      <p><a href="https://healthcare-cms.example.com/posts/#{post.id}/edit">Edit Post</a></p>
      """
    end}

    <p><em>Healthcare CMS Compliance Team</em></p>
    """)
  end
end
```

---

## PHI Protection & LGPD Compliance

### 1. PHI Sanitization

**Sanitize email content** before sending:
```elixir
defmodule HealthcareCMS.Emails.Helpers do
  @moduledoc """
  Email helper functions (PHI sanitization, consent verification).
  """

  @phi_patterns [
    ~r/\b\d{3}\.\d{3}\.\d{3}-\d{2}\b/,  # CPF (Brazilian SSN)
    ~r/\b\d{11}\b/,                      # CPF (no formatting)
    ~r/\b[A-Z]{2}\d{6,8}\b/,             # RG (Brazilian ID)
    ~r/\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b/  # Credit card numbers
  ]

  def sanitize_phi(text) do
    Enum.reduce(@phi_patterns, text, fn pattern, acc ->
      String.replace(acc, pattern, "[REDACTED]")
    end)
  end

  def sanitize_email(%Swoosh.Email{} = email) do
    %{email |
      subject: sanitize_phi(email.subject),
      text_body: sanitize_phi(email.text_body || ""),
      html_body: sanitize_phi(email.html_body || "")
    }
  end
end
```

**Usage**:
```elixir
defmodule HealthcareCMS.Mailer do
  use Swoosh.Mailer, otp_app: :healthcare_cms

  alias HealthcareCMS.Emails.Helpers

  def deliver(email) do
    # Sanitize PHI before sending
    email
    |> Helpers.sanitize_email()
    |> __MODULE__.deliver()
  end
end
```

### 2. LGPD Consent Verification

**Check consent before sending marketing emails**:
```elixir
defmodule HealthcareCMS.Emails.ConsentVerifier do
  @moduledoc """
  Verify LGPD consent before sending marketing emails.
  """

  def can_send_marketing_email?(user) do
    # Check if user has consented to marketing emails (LGPD Art. 8)
    case HealthcareCMS.Accounts.get_user_consent(user.id) do
      nil -> false
      consent -> consent.marketing_emails == true
    end
  end

  def verify_and_send(email, user) do
    if can_send_marketing_email?(user) do
      HealthcareCMS.Mailer.deliver(email)
    else
      {:error, :missing_lgpd_consent}
    end
  end
end
```

---

## Background Email Delivery (Oban)

### 1. Email Worker

**lib/healthcare_cms/workers/email_worker.ex**:
```elixir
defmodule HealthcareCMS.Workers.EmailWorker do
  @moduledoc """
  Background email delivery with Oban.
  """

  use Oban.Worker,
    queue: :email,
    max_attempts: 5

  alias HealthcareCMS.Mailer
  alias HealthcareCMS.Emails

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => type, "params" => params}}) do
    email =
      case type do
        "compliance_alert" ->
          Emails.ComplianceEmail.unlogged_phi_access(params["recipient"], params["data"])

        "password_reset" ->
          Emails.AuthEmail.password_reset(params["recipient"], params["token"])

        "welcome" ->
          user = HealthcareCMS.Accounts.get_user!(params["user_id"])
          Emails.UserEmail.welcome(user)

        "post_published" ->
          user = HealthcareCMS.Accounts.get_user!(params["user_id"])
          post = HealthcareCMS.Content.get_post!(params["post_id"])
          Emails.UserEmail.post_published(user, post)

        _ ->
          {:error, :invalid_email_type}
      end

    case email do
      {:error, reason} -> {:error, reason}
      email -> Mailer.deliver(email)
    end
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)
end
```

### 2. Enqueue Email

**Async email delivery**:
```elixir
defmodule HealthcareCMS.Accounts do
  def send_password_reset_email(user, reset_token) do
    %{
      type: "password_reset",
      params: %{
        recipient: user.email,
        token: reset_token
      }
    }
    |> HealthcareCMS.Workers.EmailWorker.new()
    |> Oban.insert()
  end
end
```

---

## Email Previews (Development)

### 1. Local Mailbox

**config/dev.exs**:
```elixir
config :healthcare_cms, HealthcareCMS.Mailer,
  adapter: Swoosh.Adapters.Local

config :swoosh, local: true
```

**Router** (development routes):
```elixir
# lib/healthcare_cms_web/router.ex
if Application.compile_env(:healthcare_cms, :dev_routes) do
  scope "/dev" do
    pipe_through :browser

    forward "/mailbox", Plug.Swoosh.MailboxPreview
  end
end
```

**Access mailbox**: http://localhost:4000/dev/mailbox

### 2. Email Preview Page

**Create preview controller**:
```elixir
defmodule HealthcareCMSWeb.EmailPreviewController do
  use HealthcareCMSWeb, :controller

  alias HealthcareCMS.Emails

  def index(conn, _params) do
    render(conn, :index, emails: list_emails())
  end

  def show(conn, %{"id" => email_id}) do
    email = get_email(email_id)
    html(conn, email.html_body)
  end

  defp list_emails do
    [
      %{id: "welcome", name: "Welcome Email"},
      %{id: "password_reset", name: "Password Reset"},
      %{id: "compliance_alert", name: "Compliance Alert"}
    ]
  end

  defp get_email("welcome") do
    user = %{name: "John Doe", email: "john@example.com"}
    Emails.UserEmail.welcome(user)
  end

  defp get_email("password_reset") do
    Emails.AuthEmail.password_reset("john@example.com", "ABC123")
  end

  defp get_email("compliance_alert") do
    Emails.ComplianceEmail.unlogged_phi_access("dpo@example.com", %{post_ids: [1, 2, 3]})
  end
end
```

---

## Testing

### 1. Email Assertions

**test/support/email_helpers.ex**:
```elixir
defmodule HealthcareCMS.EmailHelpers do
  import ExUnit.Assertions
  import Swoosh.TestAssertions

  def assert_email_sent(to: recipient, subject: expected_subject) do
    assert_email_sent(%{to: [{_, ^recipient}], subject: ^expected_subject})
  end

  def assert_no_email_sent do
    assert Swoosh.Adapters.Local.Storage.all() == []
  end
end
```

**Test examples**:
```elixir
defmodule HealthcareCMS.Emails.AuthEmailTest do
  use HealthcareCMS.DataCase, async: true
  import Swoosh.TestAssertions

  alias HealthcareCMS.Emails.AuthEmail
  alias HealthcareCMS.Mailer

  test "password reset email" do
    email = AuthEmail.password_reset("user@example.com", "token123")

    assert email.to == [{"", "user@example.com"}]
    assert email.subject == "Reset Your Password - Healthcare CMS"
    assert email.text_body =~ "token123"
  end

  test "delivers password reset email" do
    email = AuthEmail.password_reset("user@example.com", "token123")
    Mailer.deliver(email)

    assert_email_sent(to: "user@example.com", subject: "Reset Your Password - Healthcare CMS")
  end
end
```

---

## Best Practices

### ✅ DO

1. **Sanitize PHI**: Always remove sensitive data before sending emails
2. **Verify LGPD consent**: Check consent before marketing emails
3. **Use background jobs**: Send emails asynchronously with Oban
4. **Include text version**: Always provide plain text alternative
5. **Set email categories**: Use SendGrid categories for tracking
6. **Test email content**: Use email previews and assertions
7. **Handle delivery failures**: Implement retry logic with exponential backoff
8. **Use templates**: Reuse email layouts and components
9. **Log email activity**: Audit all compliance-related emails (LGPD Art. 37)
10. **Provide unsubscribe link**: LGPD Art. 18 (right to revoke consent)

### ❌ DON'T

1. **Don't send PHI in email**: Emails are not encrypted end-to-end
2. **Don't skip consent verification**: LGPD fines can reach 2% of revenue
3. **Don't block requests**: Send emails asynchronously
4. **Don't hardcode email addresses**: Use environment variables
5. **Don't ignore delivery errors**: Monitor bounce rates, spam reports
6. **Don't send without HTML fallback**: Some clients block HTML
7. **Don't skip email validation**: Verify email format before sending
8. **Don't send marketing without consent**: Explicit opt-in required (LGPD Art. 8)
9. **Don't forget accessibility**: Use semantic HTML, alt text for images
10. **Don't use production emails in tests**: Use `Swoosh.Adapters.Test`

---

## References

- **[Swoosh Documentation](https://hexdocs.pm/swoosh)** (L0_CANONICAL) - Email library
- **[Swoosh.Adapters](https://hexdocs.pm/swoosh/Swoosh.Adapters.html)** (L0_CANONICAL) - SMTP, SendGrid, etc.
- **[LGPD Art. 8](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)** (L0_CANONICAL) - Consent requirements
- **[SendGrid Best Practices](https://docs.sendgrid.com/ui/sending-email/email-best-practices)** (L2_VALIDATED) - Email deliverability

---

**Status**: Production (Sprint 0-1)
**Healthcare Compliance**: PHI sanitization, LGPD consent verification, audit logging
**Adapters**: Local (dev), SMTP/SendGrid (prod)
**Email Types**: Compliance alerts, authentication, user notifications
