# kb-add-reference

Adds a pre-validated reference to the Healthcare WASM-Elixir Stack knowledge base.

## Usage

```
/kb-add-reference <technology> <url> <validation_level> [--title "Title"] [--author "Author"] [--date "YYYY-MM-DD"]
```

## Parameters

- `technology` (required): Technology category (elixir, webassembly, security, healthcare, database, infrastructure)
- `url` (required): Full URL of the reference
- `validation_level` (required): L0_CANONICAL | L1_ACADEMIC | L2_VALIDATED | L3_COMMUNITY
- `--title` (optional): Document title (auto-extracted if not provided)
- `--author` (optional): Author or organization name
- `--date` (optional): Publication date in YYYY-MM-DD format

## Description

This command adds a reference to `.claude/sources-registry.yml` without full validation workflow. Use this when:

- Adding official documentation (L0_CANONICAL)
- Adding peer-reviewed research (L1_ACADEMIC)
- Batch-importing pre-validated references
- Updating existing references with new information

**Note**: For unknown sources, use `/kb-validate-source` instead to perform full validation.

## Technology Categories

### Available Categories
- `elixir` - Elixir/Erlang/OTP, Phoenix, BEAM VM
- `webassembly` - WASM specs, Extism, Wasmtime, Component Model
- `security` - Post-Quantum Crypto, Zero Trust, security standards
- `healthcare` - FHIR, DICOM, HIPAA, LGPD, CFM regulations
- `database` - PostgreSQL, TimescaleDB, pgvector, PostGIS
- `infrastructure` - Kubernetes, Istio, Prometheus, observability
- `architecture` - DSM, software architecture, design patterns
- `performance` - Benchmarks, Web Vitals, optimization
- `ai_ml` - RAG, embeddings, machine learning
- `standards` - RFCs, protocols, specifications

## Validation Levels

### L0_CANONICAL (Official)
Official documentation, standards, government regulations
- elixir-lang.org, NIST publications, RFCs
- **Auto-approved** without additional checks

### L1_ACADEMIC (Research)
Peer-reviewed papers, academic publications
- ACM, IEEE, arXiv papers
- Requires verification of peer-review status

### L2_VALIDATED (Industry)
Technical blogs, whitepapers with attribution
- Company engineering blogs, conference talks
- Requires cross-validation with canonical sources

### L3_COMMUNITY (Community)
Community content needing verification
- Stack Overflow, GitHub issues, forum posts
- Requires manual review and cross-checking

## Examples

### Add Official Documentation
```bash
/kb-add-reference elixir \
  https://hexdocs.pm/phoenix/Phoenix.LiveView.html \
  L0_CANONICAL \
  --title "Phoenix LiveView Documentation" \
  --author "Phoenix Framework Team" \
  --date "2024-01-15"
```

### Add Academic Paper
```bash
/kb-add-reference webassembly \
  https://dl.acm.org/doi/10.1145/3062341.3062363 \
  L1_ACADEMIC \
  --title "Bringing the Web up to Speed with WebAssembly" \
  --author "Andreas Haas et al." \
  --date "2017-06-14"
```

### Add NIST Standard
```bash
/kb-add-reference security \
  https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf \
  L0_CANONICAL \
  --title "FIPS 203 - Module-Lattice-Based Key-Encapsulation Mechanism" \
  --author "NIST" \
  --date "2024-08-13"
```

### Add Healthcare Regulation
```bash
/kb-add-reference healthcare \
  https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2022/2314 \
  L0_CANONICAL \
  --title "CFM Resolução 2.314/2022 - Telemedicina" \
  --author "Conselho Federal de Medicina" \
  --date "2022-05-04"
```

## Output Format

The reference is added to `.claude/sources-registry.yml`:

```yaml
<technology>:
  <category>:
    - title: "Document Title"
      url: "https://example.com/doc"
      validation_level: "L0_CANONICAL"
      last_verified: "2025-09-30"
      author: "Author Name"
      publication_date: "2025-01-15"
      version: "1.2.3" # if applicable
```

## Automatic Categorization

References are automatically sub-categorized:
- **official**: Official documentation and standards
- **academic**: Research papers and publications
- **validated**: Industry content with attribution
- **community**: Community-verified content

## Metadata Auto-Extraction

If `--title` or `--author` not provided, the command attempts to:
1. Fetch URL content
2. Extract `<title>` tag or `<h1>` heading
3. Extract `<meta name="author">` or GitHub repo owner
4. Use last-modified date if publication date unavailable

## Version Tracking

For official documentation, the command checks for version information:
- Phoenix: Extracts from hexdocs.pm URL
- Elixir: Checks elixir-lang.org version selector
- PostgreSQL: Extracts from docs.postgresql.org path
- Kubernetes: Extracts from kubernetes.io/docs/v* path

## Integration with DSM Tags

References are automatically tagged with DSM hierarchy:

```yaml
dsm_tags:
  L1_DOMAIN: "infrastructure"
  L2_SUBDOMAIN: "healthcare"
  L3_TECHNICAL: "architecture"
  L4_SPECIFICITY: "reference"
```

## Duplicate Handling

If reference already exists:
- **Same URL**: Updates metadata and `last_verified` timestamp
- **Same title, different URL**: Adds as separate entry with note
- **Different version**: Adds as separate entry with version tag

## Re-Validation Schedule

References are scheduled for re-validation:
- L0_CANONICAL: Quarterly
- L1_ACADEMIC: Yearly (static content)
- L2_VALIDATED: Monthly
- L3_COMMUNITY: Weekly

## Quality Checks

Even pre-validated references undergo basic checks:
- ✓ URL accessibility (HTTP 200)
- ✓ SSL certificate validity
- ✓ Domain against blocked list
- ✓ Minimal metadata present

## Error Handling

### URL Not Accessible
```
Error: URL returns 404 Not Found
Suggestion: Verify URL is correct or check if document moved
```

### Blocked Domain
```
Error: Domain 'blogspot.com' is in blocked list
Suggestion: Use /kb-validate-source for conditional approval
```

### Missing Required Metadata
```
Warning: Publication date not provided and could not be extracted
Added with last_verified date instead
```

### Duplicate Entry
```
Info: Reference already exists at webassembly.official[0]
Updated last_verified to 2025-09-30
```

## Batch Import

For multiple references, create a YAML file:

```yaml
# references-to-add.yml
- technology: elixir
  url: https://elixir-lang.org/docs.html
  validation_level: L0_CANONICAL
  title: "Elixir Documentation"

- technology: security
  url: https://csrc.nist.gov/projects/post-quantum-cryptography
  validation_level: L0_CANONICAL
  title: "NIST PQC Standardization"
```

Then import:
```bash
/kb-add-reference --batch references-to-add.yml
```

## Best Practices

1. **Use specific URLs** - Link to exact page, not homepage
2. **Include version** - Specify version for documentation
3. **Verify recency** - Check publication date is accurate
4. **Add context** - Use `--notes` for additional context
5. **Cross-reference** - Link related references together

## Advanced Options

### Add with Notes
```bash
/kb-add-reference elixir https://example.com L1_ACADEMIC \
  --title "Paper Title" \
  --notes "Introduces concept X used in module Y"
```

### Add with Version
```bash
/kb-add-reference database https://postgresql.org/docs/16/ L0_CANONICAL \
  --title "PostgreSQL Documentation" \
  --version "16.6"
```

### Add with Multiple Authors
```bash
/kb-add-reference webassembly https://example.com L1_ACADEMIC \
  --title "Paper Title" \
  --author "First Author, Second Author, et al."
```

## See Also

- `/kb-validate-source` - Full validation workflow for unknown sources
- `/kb-search-tech` - Search knowledge base by technology
- `.claude/sources-registry.yml` - Master sources registry
- `.claude/validation-rules.yml` - Validation criteria