# Contribution Guide
## Healthcare WASM-Elixir Stack Knowledge Base

**Purpose**: Guide for contributing new content, ensuring 99/100 quality standard maintained across all documentation.

**Metadata**:
- **Category**: Governance
- **Audience**: Documentation authors, external contributors
- **Scope**: Submission workflow, quality gates, review process
- **Last Updated**: 2025-09-30

---

## Quick Start

### Before You Contribute

1. **Read DSM methodology**: [dsm-methodology.md](./dsm-methodology.md) - Understand L1-L4 tagging
2. **Check quality standards**: [quality-standards.md](./quality-standards.md) - 99/100 score requirements
3. **Search existing content**: Avoid duplicates (use `grep -r "your topic" .`)

### Contribution Types

| Type | Effort | Review Time | Examples |
|------|--------|-------------|----------|
| **Bug Fix** | LOW | 1-2 days | Dead link, typo, code syntax error |
| **Content Update** | MEDIUM | 3-5 days | New Elixir version, updated benchmark |
| **New File** | HIGH | 7-10 days | New ADR, specialist guide, tutorial |
| **Major Refactor** | VERY HIGH | 14+ days | Reorganize directory, update 10+ files |

---

## Submission Workflow

### Step 1: Fork & Branch

```bash
# Fork repository on GitHub
git clone https://github.com/YOUR_USERNAME/healthcare-wasm-elixir-stack.git
cd healthcare-wasm-elixir-stack

# Create feature branch
git checkout -b feature/add-timescaledb-continuous-aggregates
```

### Step 2: Create Content

**Template for New File**:
```markdown
# [Title]
## Healthcare WASM-Elixir Stack - [Subtitle]

**Purpose**: One-sentence purpose statement.

**Metadata**:
- **Category**: [Elixir Specialist | WASM Specialist | Security | Healthcare | Database | DevOps | Benchmarks | Governance]
- **Audience**: [Developers | Architects | Security Engineers | Compliance Officers]
- **Scope**: [Scope description]
- **Last Updated**: YYYY-MM-DD

---

## Overview

[2-3 paragraph overview with analogy]

---

## [Main Section 1]

### Subsection

[Content with code examples]

```elixir
defmodule Example do
  @spec function_name(arg_type()) :: return_type()
  def function_name(arg) do
    # Implementation with error handling
    {:ok, result}
  end
end
```

---

## Benchmarks (if applicable)

| Metric | Value | Methodology |
|--------|-------|-------------|
| Latency p99 | 67ms | k6 load test, 10 min, correlation: 94% |

---

## References

- [Official Docs](https://example.com) (L0_CANONICAL)
- [Academic Paper](https://doi.org/...) (L1_ACADEMIC)

---

**DSM Tags**: `[L1_DOMAIN:... | L2_SUBDOMAIN:... | L3_TECHNICAL:... | L4_SPECIFICITY:...]`

**Dependencies**:
- Technology X REQUIRES Technology Y
- Component A INTEGRATES with Component B

---

**Last Updated**: YYYY-MM-DD
**Version**: 1.0.0
**Maintainer**: Your Name
**License**: MIT
```

### Step 3: Quality Validation

**Run Automated Checks**:
```bash
# Completeness check (no TODOs)
./scripts/completeness-check.sh your-file.md

# Link validation (HTTP 200)
./scripts/validate-links.sh your-file.md

# Code compilation (Elixir syntax)
./scripts/extract-and-compile-code.sh your-file.md

# DSM tags present (L1-L4)
./scripts/validate-dsm-tags.sh your-file.md

# Quality score calculation
./scripts/calculate-quality-score.sh your-file.md
# Target: >= 99/100
```

**Manual Checklist**:
- [ ] All code examples compile (`elixir -c`)
- [ ] All functions have `@spec` type annotations
- [ ] Error handling present (`:ok/:error` tuples, `with` statements)
- [ ] References include validation levels (L0/L1/L2/L3)
- [ ] Benchmarks include methodology
- [ ] Cross-references bidirectional (if A links to B, B links back)
- [ ] DSM tags complete (all 4 levels: L1, L2, L3, L4)
- [ ] Healthcare compliance cited (LGPD/HIPAA/CFM if applicable)

### Step 4: Submit Pull Request

```bash
# Commit with conventional commit format
git add your-file.md
git commit -m "docs: add TimescaleDB continuous aggregates guide

- Explain continuous aggregates for time-series data
- Include code examples with error handling
- Benchmark: 100x query speedup vs raw data
- References: TimescaleDB docs (L0_CANONICAL)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to fork
git push origin feature/add-timescaledb-continuous-aggregates

# Create pull request on GitHub
# Title: "Add TimescaleDB continuous aggregates guide"
# Body: Use PR template (see below)
```

**Pull Request Template**:
```markdown
## Summary

Add comprehensive guide for TimescaleDB continuous aggregates, including:
- Overview of continuous aggregates (pre-computed rollups)
- Implementation guide with Elixir code examples
- Benchmark showing 100x query speedup
- Healthcare use case (patient vital signs dashboards)

## Quality Checklist

- [x] All code examples compile
- [x] References validated (3 L0_CANONICAL, 1 L1_ACADEMIC)
- [x] DSM tags complete (L1-L4)
- [x] Quality score: 99/100
- [x] Cross-references updated (linked from hypertables.md)

## Testing

- Ran `mix test` on code examples (100% pass)
- Validated links with `validate-links.sh` (3/3 alive)
- Compiled Elixir code with `elixir -c` (syntax OK)

## Related Issues

Closes #42 (TimescaleDB continuous aggregates documentation)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Review Process

### Stage 1: Automated Validation (CI/CD)

**GitHub Actions Workflow**:
```yaml
name: Documentation Quality Check

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '27.1'

      - name: Completeness Check
        run: ./scripts/completeness-check.sh **/*.md

      - name: Link Validation
        run: ./scripts/validate-links.sh **/*.md

      - name: Code Compilation
        run: ./scripts/extract-and-compile-code.sh **/*.md

      - name: Quality Score
        run: |
          SCORE=$(./scripts/calculate-quality-score.sh **/*.md)
          if [ $SCORE -lt 90 ]; then exit 1; fi
```

**Pass Criteria**: All checks GREEN, quality score ≥ 90/100

### Stage 2: Human Review

**Reviewers**: 2 maintainers (1 technical + 1 compliance)

**Technical Review** (3-5 days):
- [ ] Code examples follow best practices
- [ ] Performance claims validated (benchmarks reproducible)
- [ ] Security considerations documented (PQC, Zero Trust)
- [ ] Cross-references accurate

**Compliance Review** (2-3 days):
- [ ] LGPD/HIPAA requirements cited correctly
- [ ] PHI/PII handling secure (if applicable)
- [ ] CFM regulations referenced (if healthcare-specific)
- [ ] Audit trail requirements documented

### Stage 3: Merge

**Criteria**:
- ✅ 2 approvals (1 technical + 1 compliance)
- ✅ All CI checks pass
- ✅ Quality score ≥ 99/100
- ✅ No merge conflicts

**Merge Commit**:
```bash
git merge --squash feature/add-timescaledb-continuous-aggregates
git commit -m "docs: add TimescaleDB continuous aggregates guide (#42)

- Comprehensive guide with code examples
- Benchmark: 100x query speedup
- Quality score: 99/100

Reviewed-by: @maintainer1, @maintainer2
Co-authored-by: Contributor Name <contributor@example.com>

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

---

## Common Rejection Reasons

### Low Quality Score (<90/100)

**Example**: Missing type specs
```elixir
# ❌ REJECTED: No @spec annotation
def calculate_bmi(weight, height) do
  weight / (height * height)
end

# ✅ APPROVED: Type spec with error handling
@spec calculate_bmi(number(), number()) :: {:ok, float()} | {:error, atom()}
def calculate_bmi(weight, height) when is_number(weight) and is_number(height) do
  if weight > 0 and height > 0 do
    {:ok, Float.round(weight / (height * height), 2)}
  else
    {:error, :invalid_input}
  end
end
```

### Missing References

**Example**: Performance claim without source
```markdown
# ❌ REJECTED: No methodology
Elixir is 3x faster than Node.js.

# ✅ APPROVED: Benchmark with methodology
Elixir achieves 43,900 req/sec vs Node.js 18,300 req/sec (2.4x faster).
**Methodology**: k6 load test, 10 minutes sustained, AWS c6i.2xlarge
**Correlation**: 94% (benchmark vs production)
**Source**: [Elixir Throughput Tests](../08-BENCHMARKS-RESEARCH/performance/elixir-throughput-tests.md) (L2_VALIDATED)
```

### Incomplete DSM Tags

**Example**: Missing L4_SPECIFICITY
```markdown
# ❌ REJECTED: Only L1-L3 tags
**DSM Tags**: `[L1_DOMAIN:data_layer | L2_SUBDOMAIN:healthcare | L3_TECHNICAL:implementation]`

# ✅ APPROVED: All L1-L4 tags
**DSM Tags**: `[L1_DOMAIN:data_layer | L2_SUBDOMAIN:healthcare | L3_TECHNICAL:implementation | L4_SPECIFICITY:example, guide]`
```

---

## Style Guide

### Writing Style

**Concise, Technical, Production-Focused**:
- Use active voice ("Configure PostgreSQL" vs "PostgreSQL should be configured")
- Quantify claims (benchmarks, SLOs, percentages)
- Provide healthcare context (LGPD, HIPAA, CFM regulations)
- Include code examples for every concept

**Analogies** (help non-experts):
```markdown
# ❌ Too abstract
Supervision trees provide fault tolerance.

# ✅ Good analogy
Supervision trees are like hospital emergency protocols: when a component "crashes" (like a plugin failure), the supervisor automatically "resuscitates" it (restarts) following predefined strategies (:one_for_one restarts only the failed component, :one_for_all restarts all siblings).
```

### Code Style

**Elixir** (follow community conventions):
- Use `mix format` (2-space indentation)
- Type specs for all public functions (`@spec`)
- Error handling with `:ok/:error` tuples
- Document modules with `@moduledoc`
- Healthcare context in variable names (`patient_id`, not `id`)

**Example**:
```elixir
defmodule Healthcare.Patients do
  @moduledoc """
  Patient management with LGPD Art. 46 compliance.

  All PHI access is logged per HIPAA 164.312(b).
  """

  @type patient_id :: String.t()
  @type patient :: %Patient{id: patient_id(), name: String.t()}

  @spec get_patient(patient_id()) :: {:ok, patient()} | {:error, :not_found}
  def get_patient(id) when is_binary(id) do
    case Repo.get(Patient, id) do
      nil -> {:error, :not_found}
      patient ->
        Healthcare.AuditLog.log_phi_access(current_user_id(), :read, patient)
        {:ok, patient}
    end
  end
end
```

---

## References

**Contribution Best Practices**:
- [Open Source Guides](https://opensource.guide/how-to-contribute/) (L2_VALIDATED)
- [Conventional Commits](https://www.conventionalcommits.org/) (L2_VALIDATED)

**Elixir Style**:
- [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide) (L2_VALIDATED)
- [Credo Linter](https://github.com/rrrene/credo) (L2_VALIDATED)

---

**DSM Tags**: `[L1_DOMAIN:business_logic | L2_SUBDOMAIN:compliance | L3_TECHNICAL:architecture | L4_SPECIFICITY:guide]`

---

**Last Updated**: 2025-09-30
**Version**: 1.0.0
**Maintainer**: Healthcare WASM-Elixir Stack Team
**License**: MIT