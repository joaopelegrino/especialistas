# ADR-004: Multi-Tenant Admin Blind Design

**Status**: ✅ Accepted
**Date**: 2025-09-28
**Deciders**: Tech Lead, Compliance Officer, Legal
**Tags**: #database #privacy #lgpd #multi-tenant

---

## Context

Healthcare SaaS requires multi-tenancy where:

1. **Admin cannot access tenant data**: LGPD Art. 7 (no access without legal basis)
2. **Tenant isolation**: Cryptographic separation, not just logical
3. **Compliance auditability**: Prove admin never accessed PHI/PII
4. **Privacy marketing**: "We cannot see your data" competitive advantage

Traditional multi-tenant: Admin has database access → LGPD risk.

---

## Decision

**Implement "Admin Blind" multi-tenancy** with:

- **Row-Level Security (RLS)**: PostgreSQL policies enforce tenant isolation
- **Tenant Context Injection**: All queries scoped to `tenant_id`
- **Admin Isolation**: Admin users have `NULL` tenant_id → cannot query tenant data
- **Audit Trail**: All cross-tenant operations logged (LGPD Art. 16)

---

## Rationale

### 1. LGPD Compliance

LGPD Art. 7 requires legal basis for processing:
- ✅ Tenant data: Consent (user agreement)
- ✅ Admin access: Legitimate interest (support) - but requires explicit opt-in

**Admin Blind** = No access by default → maximum privacy.

### 2. Trust & Marketing

- "Your data is cryptographically private"
- "Even we cannot see your patient records"
- Competitive advantage for healthcare providers

### 3. Implementation

```sql
-- RLS policy
CREATE POLICY tenant_isolation ON posts
  USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Admin queries fail automatically
SELECT * FROM posts;  -- ERROR if tenant_id not set
```

---

## Consequences

### Positive

✅ **Maximum Privacy**: Admin cannot access tenant data
✅ **LGPD Compliant**: No access without consent
✅ **Marketing**: Competitive differentiation
✅ **Audit Proof**: RLS enforced at database level

### Negative

❌ **Support Complexity**: Admin can't debug tenant issues easily
❌ **Query Overhead**: +10-20% query complexity (tenant scoping)
❌ **Emergency Access**: Requires explicit tenant consent + logged audit

---

## Alternatives Considered

### Alt 1: Traditional Multi-Tenant (Admin Full Access)

**Rejected**: LGPD Art. 7 requires legal basis. Admin access = privacy risk.

### Alt 2: Encryption at Application Level

**Rejected**: Admin still has encrypted data access → not cryptographically blind.

---

## Implementation

**Files**:
- `lib/healthcare_cms/repo.ex` - Tenant context injection
- `priv/repo/migrations/*_enable_rls.exs` - RLS policies

**Status**: ✅ Schema implemented (Sprint 0-1)

---

## References

- [LGPD Art. 7](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) (L0_CANONICAL)
- [PostgreSQL RLS](https://www.postgresql.org/docs/16/ddl-rowsecurity.html) (L0_CANONICAL)

---

**Related ADRs**: ADR-002 (Zero Trust)
**Version**: 1.0.0 | **Created**: 2025-09-30
