# ADR-005: Guardian JWT Authentication

**Status**: 🔄 In Progress
**Date**: 2025-09-29
**Deciders**: Tech Lead, Security Team
**Tags**: #authentication #jwt #security #scalability

---

## Context

Healthcare CMS requires authentication that:

1. **Scales horizontally**: Stateless tokens enable multi-node deployment
2. **Integrates Zero Trust**: Trust score stored in session
3. **Supports mobile/SPA**: JWT standard for REST APIs
4. **Healthcare-compliant**: Secure session management (15min inactivity timeout)

---

## Decision

**Use Guardian 2.3** for JWT-based authentication with:

- **Token Type**: JWT (JSON Web Token)
- **Storage**: Stateless (no server session DB)
- **Trust Score**: Embedded in JWT claims
- **Refresh**: Sliding window (15min inactivity timeout)

---

## Rationale

### 1. Horizontal Scalability

Stateless JWT:
- ✅ No shared session store (Redis/Postgres)
- ✅ Any node validates token
- ✅ Lower infrastructure cost

### 2. Zero Trust Integration

```elixir
# JWT claims include trust score
claims = %{
  user_id: 123,
  role: "doctor",
  trust_score: 95,  # From PolicyEngine
  iat: timestamp,
  exp: timestamp + 15min
}
```

Policy Engine uses trust score from JWT → <2ms validation (vs GenServer call).

### 3. Guardian Library

- ✅ Battle-tested (7+ years production)
- ✅ Phoenix integration (guardian_phoenix)
- ✅ Token revocation support (blacklist)
- ✅ Active maintenance

---

## Consequences

### Positive

✅ **Scalable**: Stateless, horizontal scaling
✅ **Fast**: <2ms token validation (vs session DB query)
✅ **Standard**: JWT (RFC 7519) - mobile/SPA compatible
✅ **Integrated**: Guardian Phoenix plugs

### Negative

❌ **Revocation**: Requires blacklist (logout all devices)
❌ **Token Size**: ~200-300 bytes (vs 32 bytes session ID)
❌ **Secret Rotation**: Complex (requires token reissue)

---

## Alternatives Considered

### Alt 1: Session-Based (Phoenix.Token)

**Rejected**: Requires shared session store → scalability bottleneck.

### Alt 2: OAuth2/OIDC (Ueberauth)

**Deferred**: JWT sufficient for MVP. OAuth2 for external providers (Sprint 2+).

---

## Implementation

**Status**: 🔄 Sprint 0-2 (In Progress)

```elixir
# lib/healthcare_cms/guardian.ex
defmodule HealthcareCMS.Guardian do
  use Guardian, otp_app: :healthcare_cms

  def subject_for_token(user, _claims), do: {:ok, to_string(user.id)}
  def resource_from_claims(claims), do: {:ok, Accounts.get_user(claims["sub"])}
end
```

**Target**: Sprint 0-2 completion (login/logout functional)

---

## References

- [Guardian Docs](https://hexdocs.pm/guardian) (L0_CANONICAL)
- [JWT RFC 7519](https://tools.ietf.org/html/rfc7519) (L0_CANONICAL)

---

**Related ADRs**: ADR-002 (Zero Trust Integration)
**Version**: 1.0.0 | **Created**: 2025-09-30
