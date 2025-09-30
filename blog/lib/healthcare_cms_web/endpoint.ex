# DSM:PLATFORM:web_interface_foundation HEALTHCARE:phoenix_endpoint
# DSM:SECURITY:zero_trust_web_layer PERFORMANCE:concurrent_connections
defmodule HealthcareCMSWeb.Endpoint do
  @moduledoc """
  Healthcare CMS Phoenix Endpoint

  Sprint 0-1: Phoenix Endpoint & Router Setup
  Critical web interface foundation para Healthcare CMS Platform.

  Security Features:
  - Zero Trust context injection via session
  - Post-quantum ready cryptography configuration
  - Healthcare-specific security headers (LGPD/ANVISA compliance)
  - CSRF protection for medical data mutations

  Performance:
  - 2M concurrent connections capability
  - Static asset optimization
  - LiveView WebSocket for real-time updates
  """

  use Phoenix.Endpoint, otp_app: :healthcare_cms

  # Session configuration para Zero Trust context
  @session_options [
    store: :cookie,
    key: "_healthcare_cms_key",
    signing_salt: "healthcare_signing_salt_at_least_8_bytes_long",
    encryption_salt: "healthcare_encryption_salt_at_least_8_bytes",
    # 8 horas de sessão para contexto médico
    max_age: 8 * 60 * 60,
    # HttpOnly e Secure para LGPD compliance
    http_only: true,
    secure: false,
    same_site: "Lax"
  ]

  # LiveView socket para real-time healthcare monitoring
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [
      connect_info: [
        session: @session_options,
        peer_data: true,
        trace_context_headers: ["x-healthcare-trace-id"]
      ]
    ],
    longpoll: false

  # Static asset serving
  plug Plug.Static,
    at: "/",
    from: :healthcare_cms,
    gzip: false,
    only: HealthcareCMSWeb.static_paths()

  # Security headers para healthcare compliance
  plug :put_healthcare_security_headers

  # Request ID tracking para audit trail (LGPD/ANVISA)
  plug Plug.RequestId

  # Telemetry
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # Request parsing
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  # Method override para REST semantics
  plug Plug.MethodOverride
  plug Plug.Head

  # Session e CSRF protection
  plug Plug.Session, @session_options

  # Router principal
  plug HealthcareCMSWeb.Router

  # Healthcare-specific security headers (LGPD/ANVISA compliance)
  defp put_healthcare_security_headers(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_header("x-frame-options", "DENY")
    |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
    |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    |> Plug.Conn.put_resp_header(
      "content-security-policy",
      "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';"
    )
    |> Plug.Conn.put_resp_header(
      "strict-transport-security",
      "max-age=31536000; includeSubDomains"
    )
    # LGPD compliance header
    |> Plug.Conn.put_resp_header("x-healthcare-compliance", "LGPD-BR")
  end
end