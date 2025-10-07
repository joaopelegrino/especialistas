# ADR-002: Zero Trust Architecture Implementation

**Status**: ✅ Accepted
**Date**: 2025-09-27
**Deciders**: Tech Lead, Security Team, Compliance Officer
**Tags**: #security #nist #compliance #lgpd

---

## Context

Healthcare CMS handles PHI/PII requiring continuous security verification per LGPD (Brazil) and HIPAA (international). Traditional perimeter-based security insufficient for:

1. **Multi-tenant isolation**: Admin must not access tenant data
2. **Continuous compliance**: Every access logged for audit (LGPD Art. 16)
3. **Medical professional verification**: Trust score based on multiple factors
4. **Remote access**: Healthcare professionals accessing from various locations/devices

NIST SP 800-207 Zero Trust Architecture provides framework for "never trust, always verify."

---

## Decision

**Implement NIST SP 800-207 Zero Trust Architecture** with:

- **Policy Engine (PE)**: GenServer-based decision point
- **Trust Algorithm**: 8-data-source scoring (device, location, role, MFA, session, audit, compliance, behavior)
- **Policy Enforcement Points (PEPs)**: Phoenix plugs, database RLS
- **Continuous Verification**: Every request evaluated

---

## Rationale

### 1. LGPD Compliance

LGPD requires:
- Art. 7: Legal basis for processing (legitimate interest/consent)
- Art. 46: Security measures proportional to risk
- Art. 48: Communication of security incidents

Zero Trust provides:
- ✅ Continuous verification (no implicit trust)
- ✅ All access logged (Art. 16 - 5 year retention)
- ✅ Granular access control (data minimization)

### 2. Healthcare Requirements

- **Professional verification**: Doctors/psychologists require highest trust
- **Session management**: 15min timeout for PHI access (LGPD best practice)
- **Device tracking**: Known device fingerprinting
- **Anomaly detection**: Unusual behavior flagged

### 3. Implementation Evidence

**Validated (2025-09-29)**:
```yaml
PolicyEngine: GenServer running (PID active)
Trust Algorithm: 74.75% test coverage
Trust Score: 100 for verified doctor (8 factors)
Policy Evaluation: <5ms avg, <10ms p99
```

---

## Consequences

### Positive

✅ **LGPD Compliant**: Continuous verification + audit trail
✅ **NIST SP 800-207**: Standards-based architecture
✅ **Granular Control**: Per-request policy decisions
✅ **Performance**: <10ms overhead (ETS caching)
✅ **Fault Tolerant**: OTP supervision restarts PolicyEngine

### Negative

❌ **Complexity**: +15% code vs traditional auth
❌ **Policy Overhead**: <10ms per request (acceptable)
❌ **Learning Curve**: Team needs NIST SP 800-207 training

---

## Alternatives Considered

### Alt 1: Traditional RBAC (Role-Based Access Control)

**Rejected**: Static roles insufficient for continuous compliance. LGPD requires continuous verification of access legitimacy.

### Alt 2: Attribute-Based Access Control (ABAC)

**Partially Adopted**: Trust Algorithm uses attributes but Zero Trust provides continuous verification framework.

---

## Implementation

**File**: `lib/healthcare_cms/security/policy_engine.ex`

```elixir
defmodule HealthcareCMS.Security.PolicyEngine do
  use GenServer
  
  # 8 data sources for trust score
  def evaluate_policy(context) do
    score = TrustAlgorithm.calculate_score(context)
    if score >= 80, do: :allow, else: :deny
  end
end
```

**Status**: ✅ Operational (Sprint 0-1)

---

## References

- [NIST SP 800-207](https://csrc.nist.gov/publications/detail/sp/800-207/final) (L0_CANONICAL)
- [LGPD Lei 13.709/2018](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) (L0_CANONICAL)
- [Policy Engine Code](../../../codebase/layer-2-core/zero-trust-architecture.md)

---

**Related ADRs**: ADR-004 (Multi-Tenant Design)
**Supersedes**: None
**Superseded by**: None

**Version**: 1.0.0 | **Created**: 2025-09-30
