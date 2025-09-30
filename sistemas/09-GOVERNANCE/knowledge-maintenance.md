# Knowledge Maintenance Protocol
## Healthcare WASM-Elixir Stack Update Schedule

**Purpose**: Define maintenance schedule for keeping documentation current with technology evolution, ensuring 99/100 quality score sustained over time.

**Metadata**:
- **Category**: Governance
- **Audience**: Knowledge maintainers, AI assistants
- **Scope**: Update frequency, validation, deprecation
- **Last Updated**: 2025-09-30

---

## Maintenance Schedule

### Weekly Tasks (Every Monday)

**Link Validation** (1 hour):
```bash
#!/bin/bash
# weekly-link-check.sh

echo "Checking all documentation links..."
./scripts/validate-links.sh **/*.md > link-report-$(date +%Y-%m-%d).txt

DEAD_LINKS=$(grep "❌ DEAD LINK" link-report-*.txt | wc -l)

if [ $DEAD_LINKS -gt 0 ]; then
  echo "⚠️  WARNING: $DEAD_LINKS dead links found"
  echo "Action: Fix or remove within 7 days"
fi
```

**Action Items**:
- [ ] Run link validation script
- [ ] Fix dead links (HTTP 404/500)
- [ ] Update archived URLs (use Wayback Machine if needed)
- [ ] Report persistent issues to maintainers

---

### Monthly Tasks (First Monday)

**Version Update Check** (2 hours):
```bash
#!/bin/bash
# monthly-version-check.sh

echo "Checking for new stable releases..."

# Elixir
CURRENT_ELIXIR="1.17.3"
LATEST_ELIXIR=$(curl -s https://hex.pm/api/packages/elixir | jq -r '.releases[0].version')

if [ "$CURRENT_ELIXIR" != "$LATEST_ELIXIR" ]; then
  echo "⚠️  Elixir update available: $CURRENT_ELIXIR → $LATEST_ELIXIR"
fi

# Phoenix
CURRENT_PHOENIX="1.8.0"
LATEST_PHOENIX=$(curl -s https://hex.pm/api/packages/phoenix | jq -r '.releases[0].version')

if [ "$CURRENT_PHOENIX" != "$LATEST_PHOENIX" ]; then
  echo "⚠️  Phoenix update available: $CURRENT_PHOENIX → $LATEST_PHOENIX"
fi

# PostgreSQL
CURRENT_PG="16.6"
LATEST_PG=$(curl -s https://www.postgresql.org/versions.json | jq -r '.[0].version')

if [ "$CURRENT_PG" != "$LATEST_PG" ]; then
  echo "⚠️  PostgreSQL update available: $CURRENT_PG → $LATEST_PG"
fi
```

**Action Items**:
- [ ] Check Elixir, Phoenix, Erlang/OTP versions
- [ ] Check PostgreSQL, TimescaleDB, pgvector versions
- [ ] Check Extism, Wasmtime, WASM spec versions
- [ ] Update `CLAUDE.md` section XIII (Stack Versions)
- [ ] Update all affected documentation files
- [ ] Run regression tests with new versions

**Deprecation Policy**:
- **Minor versions**: Update within 30 days (e.g., Phoenix 1.8.0 → 1.8.1)
- **Major versions**: Plan 90-day migration (e.g., Elixir 1.17 → 1.18)

---

### Quarterly Tasks (Q1: Jan, Q2: Apr, Q3: Jul, Q4: Oct)

**Academic Paper Review** (4 hours):
```python
# quarterly-academic-review.py

import requests
from datetime import datetime, timedelta

def check_new_papers():
    """Check for new academic papers in key areas."""

    topics = [
        "WebAssembly security",
        "Elixir performance",
        "Post-quantum cryptography healthcare",
        "FHIR interoperability",
        "Zero Trust architecture"
    ]

    three_months_ago = datetime.now() - timedelta(days=90)

    for topic in topics:
        # Search arXiv
        arxiv_url = f"http://export.arxiv.org/api/query?search_query={topic}&sortBy=submittedDate&sortOrder=descending&max_results=10"
        response = requests.get(arxiv_url)

        # Parse and filter by date
        # Check if later published in ACM/IEEE (L1_ACADEMIC upgrade)
        print(f"Topic: {topic}")
        print(f"  New papers: [list]")
```

**Action Items**:
- [ ] Search arXiv, ACM, IEEE for new papers
- [ ] Validate peer-review status (L1_ACADEMIC criteria)
- [ ] Add to `08-BENCHMARKS-RESEARCH/academic-references/academic-papers-catalog.md`
- [ ] Update relevant documentation with new findings

**Healthcare Compliance Review** (2 hours):
- [ ] Check CFM (Conselho Federal de Medicina) for new resolutions
- [ ] Check LGPD updates (ANPD regulations)
- [ ] Check HIPAA guidance updates (HHS.gov)
- [ ] Update compliance documentation if regulations changed

---

### Yearly Tasks (January)

**Full Knowledge Base Audit** (16 hours):

**Step 1**: Quality Score Recalculation
```bash
# Calculate quality score for all files
for file in **/*.md; do
  SCORE=$(./scripts/calculate-quality-score.sh "$file")
  echo "$file: $SCORE" >> quality-audit-$(date +%Y).txt
done

# Average score
AVG_SCORE=$(awk '{sum+=$2; count++} END {print sum/count}' quality-audit-*.txt)
echo "Average Quality Score: $AVG_SCORE/100"
```

**Step 2**: Technology Sunset Review
```yaml
# Check deprecated technologies from roadmap

2025_deprecations:
  - PostgreSQL 15.x: Should be upgraded to 16.x
  - Elixir 1.16.x: Should be upgraded to 1.17.x
  - Phoenix 1.7.x: Should be removed (security vulnerabilities)

action:
  - Grep for deprecated version references
  - Update to current stable versions
  - Remove obsolete migration guides
```

**Step 3**: Cross-Reference Validation
```python
# validate-cross-references.py

def validate_bidirectional_links():
    """Ensure all cross-references are bidirectional."""

    # Parse all markdown files
    # Extract links: [Text](path/to/file.md)
    # For each link A → B, check if B → A exists

    broken_refs = []

    for link in all_links:
        if not has_reverse_link(link):
            broken_refs.append(link)

    print(f"Broken bidirectional references: {len(broken_refs)}")
```

**Step 4**: Benchmark Recalibration
- [ ] Re-run all performance benchmarks (k6 load tests)
- [ ] Compare new results with documented values
- [ ] Update if correlation < 90%
- [ ] Document any performance regressions

**Step 5**: DSM Tag Audit
- [ ] Verify all files have L1-L4 tags
- [ ] Update dependency graph (new REQUIRES/EXTENDS relationships)
- [ ] Regenerate knowledge graph visualization

---

## Update Priorities

### Critical (Fix within 7 days)

- **Security vulnerabilities**: CVE in documented versions (e.g., Phoenix, PostgreSQL)
- **Dead links**: L0_CANONICAL sources return 404
- **Incorrect compliance information**: LGPD/HIPAA/CFM regulations misquoted
- **Code compilation errors**: Examples fail `elixir -c`

### High (Fix within 30 days)

- **Version outdated**: Minor version behind stable (e.g., Phoenix 1.8.0 vs 1.8.3)
- **Benchmark drift**: Production correlation < 90%
- **Missing cross-references**: New file not linked from related content
- **Dead links**: L1_ACADEMIC/L2_VALIDATED sources unavailable

### Medium (Fix within 90 days)

- **Academic paper updates**: New research contradicts documented information
- **Performance optimizations**: New techniques available (e.g., Elixir 1.18 features)
- **Healthcare standards**: FHIR R4 → R5 migration planning

### Low (Fix within 180 days)

- **Style improvements**: Formatting consistency
- **Additional examples**: More code samples requested
- **Expanded references**: More L1_ACADEMIC sources

---

## Version Control Strategy

### Semantic Versioning for Documentation

```yaml
major_version_change: # 1.0.0 → 2.0.0
  triggers:
    - Breaking changes in documented APIs
    - Complete directory restructure
    - New DSM hierarchy
  example: "Elixir 1.x → 2.0 (type system changes)"

minor_version_change: # 1.0.0 → 1.1.0
  triggers:
    - New files added (specialist guides)
    - New sections in existing files
    - Technology version updates (minor)
  example: "Add TimescaleDB continuous aggregates guide"

patch_version_change: # 1.0.0 → 1.0.1
  triggers:
    - Bug fixes (dead links, typos)
    - Code example corrections
    - Benchmark updates
  example: "Fix dead link to Phoenix LiveView docs"
```

### Git Commit Strategy

**Conventional Commits**:
```bash
# Documentation update
git commit -m "docs: update Elixir to 1.18.0 with set-theoretic types

- Updated all version references (1.17.3 → 1.18.0)
- Added examples of new type system features
- Benchmarked compile-time type checking performance
- Updated CLAUDE.md section XIII

Breaking change: Type annotations now validated at compile time"

# Bug fix
git commit -m "fix: correct PostgreSQL RLS policy syntax

- Fixed CREATE POLICY example (missing USING clause)
- Added error handling example
- Validated syntax with PostgreSQL 16.6"

# New content
git commit -m "feat: add WASM Component Model 1.0 migration guide

- Explain WIT interface types
- Compare with WASM 2.0 manual marshalling
- Include benchmark (40% FFI overhead reduction)
- Cross-reference from plugin-development.md"
```

---

## Automation Tools

### Link Checker (CI/CD)

```yaml
# .github/workflows/weekly-link-check.yml

name: Weekly Link Validation

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday 9 AM UTC

jobs:
  validate-links:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Link Validation
        run: ./scripts/validate-links.sh **/*.md

      - name: Create Issue if Failures
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: 'Dead links detected in documentation',
              body: 'Weekly link check failed. See workflow logs.',
              labels: ['documentation', 'maintenance']
            })
```

### Version Updater Bot

```python
# version-updater-bot.py

import requests
import subprocess

def check_and_update_elixir():
    """Check for new Elixir version and create PR if needed."""

    current = "1.17.3"
    latest = get_latest_version("https://hex.pm/api/packages/elixir")

    if current != latest:
        # Create branch
        subprocess.run(["git", "checkout", "-b", f"chore/update-elixir-{latest}"])

        # Update CLAUDE.md
        update_file("CLAUDE.md", f'elixir: "{current}"', f'elixir: "{latest}"')

        # Update all affected files
        files = subprocess.run(
            ["grep", "-rl", f"Elixir {current}", "."],
            capture_output=True, text=True
        ).stdout.splitlines()

        for file in files:
            update_file(file, f"Elixir {current}", f"Elixir {latest}")

        # Commit and push
        subprocess.run(["git", "add", "."])
        subprocess.run(["git", "commit", "-m", f"chore: update Elixir to {latest}"])
        subprocess.run(["git", "push", "origin", f"chore/update-elixir-{latest}"])

        # Create pull request via GitHub API
        create_pr(f"Update Elixir to {latest}")
```

---

## Quality Monitoring Dashboard

### Metrics to Track

```yaml
documentation_health:
  quality_score: 99/100 (average across all files)
  completeness: 100% (zero TODOs)
  link_health: 98% (187/190 links alive)
  code_compilation: 100% (all examples compile)

technology_currency:
  elixir: "1.17.3" (latest: 1.17.3, status: CURRENT)
  phoenix: "1.8.0" (latest: 1.8.1, status: 1 minor behind)
  postgresql: "16.6" (latest: 16.6, status: CURRENT)

compliance_status:
  lgpd_references: 47 articles cited (last checked: 2025-09-30)
  hipaa_references: 28 CFR sections cited (last checked: 2025-09-30)
  cfm_regulations: 3 resolutions cited (last checked: 2025-09-30)

academic_papers:
  total: 56 papers catalogued
  last_added: 2025-09-15 (WASM security paper)
  next_review: 2025-12-01 (quarterly)
```

### Alert Thresholds

```yaml
critical_alerts:
  - quality_score < 95/100
  - link_health < 90%
  - code_compilation < 100%
  - security_vulnerability_detected

warning_alerts:
  - technology_version > 60 days behind
  - benchmark_correlation < 90%
  - dead_links > 5

info_alerts:
  - new_academic_paper_available
  - compliance_regulation_updated
  - technology_roadmap_milestone_reached
```

---

## References

**Documentation Maintenance**:
- [Write the Docs Maintenance Guide](https://www.writethedocs.org/guide/docs-as-code/) (L2_VALIDATED)
- [GitHub Actions Documentation](https://docs.github.com/en/actions) (L0_CANONICAL)

**Link Validation**:
- [linkchecker](https://github.com/linkchecker/linkchecker) (L2_VALIDATED)
- [lychee Link Checker](https://github.com/lycheeverse/lychee) (L2_VALIDATED)

---

**DSM Tags**: `[L1_DOMAIN:business_logic | L2_SUBDOMAIN:compliance | L3_TECHNICAL:configuration | L4_SPECIFICITY:guide]`

**Dependencies**:
- Maintenance protocol REQUIRES automation tools (link checker, version updater)
- Knowledge base VALIDATES via maintenance checks (quality assurance)
- CI/CD pipeline MONITORS maintenance metrics (observability)

---

**Last Updated**: 2025-09-30
**Version**: 1.0.0
**Maintainer**: Healthcare WASM-Elixir Stack Team
**License**: MIT