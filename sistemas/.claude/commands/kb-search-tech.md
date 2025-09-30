# kb-search-tech

Search the Healthcare WASM-Elixir Stack knowledge base by technology, concept, or keyword.

## Usage

```
/kb-search-tech <query> [--filter <technology>] [--level <validation_level>] [--format <output_format>]
```

## Parameters

- `query` (required): Search term (technology name, concept, or keyword)
- `--filter` (optional): Filter by technology category
- `--level` (optional): Filter by validation level (L0-L3)
- `--format` (optional): Output format (summary | detailed | urls | markdown)

## Description

This command searches across the knowledge base including:
- `.claude/sources-registry.yml` - Validated references
- `.claude/dependency-matrix.yml` - Technology dependencies
- `.claude/config.yml` - Stack versions and configurations
- Documentation files (*.md) - Technical content

## Search Capabilities

### 1. Technology Search
Find all references related to a specific technology:
```bash
/kb-search-tech elixir
/kb-search-tech "Phoenix LiveView"
/kb-search-tech PostgreSQL
```

### 2. Concept Search
Search by technical concept or pattern:
```bash
/kb-search-tech "zero trust"
/kb-search-tech "post-quantum cryptography"
/kb-search-tech "WebAssembly plugins"
```

### 3. Compliance Search
Find compliance and regulatory information:
```bash
/kb-search-tech LGPD
/kb-search-tech HIPAA
/kb-search-tech "FHIR R4"
```

### 4. Version Search
Find documentation for specific versions:
```bash
/kb-search-tech "Elixir 1.17"
/kb-search-tech "OTP 27"
/kb-search-tech "Phoenix 1.8"
```

## Filtering Options

### Filter by Technology Category
```bash
/kb-search-tech authentication --filter security
/kb-search-tech "time series" --filter database
/kb-search-tech observability --filter infrastructure
```

Available categories:
- `elixir` - Elixir/Erlang/Phoenix ecosystem
- `webassembly` - WASM, Extism, plugins
- `security` - Cryptography, Zero Trust, compliance
- `healthcare` - Medical standards, regulations
- `database` - PostgreSQL, TimescaleDB, data storage
- `infrastructure` - Kubernetes, monitoring, DevOps
- `architecture` - Design patterns, DSM
- `performance` - Benchmarks, optimization

### Filter by Validation Level
```bash
# Official documentation only
/kb-search-tech Kubernetes --level L0_CANONICAL

# Academic research papers
/kb-search-tech "WASM performance" --level L1_ACADEMIC

# All levels above L2
/kb-search-tech "Elixir patterns" --level ">=L2_VALIDATED"
```

### Multiple Filters
```bash
/kb-search-tech encryption \
  --filter security \
  --level L0_CANONICAL \
  --format detailed
```

## Output Formats

### Summary (Default)
Concise list with title, URL, and validation level:
```
[L0_CANONICAL] Elixir Official Documentation
https://elixir-lang.org/docs.html

[L1_ACADEMIC] The Development of Erlang
https://dl.acm.org/doi/10.1145/1238844.1238850
```

### Detailed
Includes metadata and descriptions:
```
[L0_CANONICAL] Elixir Official Documentation
URL: https://elixir-lang.org/docs.html
Author: Elixir Core Team
Last Verified: 2025-09-30
Version: 1.17.3
Tags: L1_DOMAIN:infrastructure, L3_TECHNICAL:reference
Description: Official language documentation covering syntax, standard library, and best practices.
```

### URLs Only
Just the URLs for scripting:
```
https://elixir-lang.org/docs.html
https://erlang.org/doc
https://hexdocs.pm/phoenix/overview.html
```

### Markdown
Formatted for documentation:
```markdown
## Elixir & Erlang/OTP

### Official Documentation (L0_CANONICAL)
- [Elixir Official Documentation](https://elixir-lang.org/docs.html) - v1.17.3
- [Erlang/OTP Documentation](https://erlang.org/doc) - v27.1

### Academic Research (L1_ACADEMIC)
- [The Development of Erlang](https://dl.acm.org/doi/10.1145/1238844.1238850) - Joe Armstrong, 2007
```

## Advanced Search

### Boolean Operators
```bash
# AND (implicit)
/kb-search-tech "Elixir GenServer"

# OR
/kb-search-tech "Phoenix OR LiveView"

# NOT
/kb-search-tech "WASM NOT JavaScript"
```

### Wildcard Search
```bash
# Prefix wildcard
/kb-search-tech "Crystal*"  # Matches CRYSTALS-Kyber, CRYSTALS-Dilithium

# Fuzzy search
/kb-search-tech "kubernetis~"  # Matches kubernetes with typo tolerance
```

### Dependency Search
Find technologies that depend on or are dependencies of a given technology:
```bash
# What depends on Phoenix?
/kb-search-tech Phoenix --deps-of

# What does Phoenix depend on?
/kb-search-tech Phoenix --depends-on
```

## Search by DSM Tags

Search using DSM (Dependency Structure Matrix) tag hierarchy:

```bash
# By domain
/kb-search-tech --tag L1_DOMAIN:security

# By subdomain
/kb-search-tech --tag L2_SUBDOMAIN:healthcare

# By technical level
/kb-search-tech --tag L3_TECHNICAL:implementation

# Multiple tags (AND)
/kb-search-tech --tag L1_DOMAIN:infrastructure --tag L3_TECHNICAL:configuration
```

## Search Results Ranking

Results are ranked by relevance score:

1. **Exact match in title** (100 pts)
2. **Validation level** (L0=25, L1=20, L2=15, L3=10 pts)
3. **Recency** (< 1 year = 10, < 2 years = 5 pts)
4. **Match in description** (50 pts)
5. **Match in tags** (20 pts)
6. **Official domain** (15 pts)

## Examples

### Find All Security Standards
```bash
/kb-search-tech "NIST" --filter security --level L0_CANONICAL
```
Output:
```
[L0_CANONICAL] NIST FIPS 203 - CRYSTALS-Kyber
[L0_CANONICAL] NIST FIPS 204 - CRYSTALS-Dilithium
[L0_CANONICAL] NIST SP 800-207 - Zero Trust Architecture
```

### Find Phoenix Performance Resources
```bash
/kb-search-tech "Phoenix performance" --format markdown
```

### Find Healthcare Compliance Docs
```bash
/kb-search-tech compliance --filter healthcare --format detailed
```

### Find All Official Documentation
```bash
/kb-search-tech "*" --level L0_CANONICAL --format urls
```

## Integration Features

### Export Search Results
```bash
# Export to file
/kb-search-tech Elixir --format markdown > elixir-references.md

# Export JSON for scripting
/kb-search-tech --all --format json > knowledge-base.json
```

### Statistics
```bash
# Show knowledge base statistics
/kb-search-tech --stats
```
Output:
```
Knowledge Base Statistics:
- Total references: 127
- L0_CANONICAL: 45
- L1_ACADEMIC: 32
- L2_VALIDATED: 28
- L3_COMMUNITY: 22

By Technology:
- elixir: 23
- webassembly: 18
- security: 21
- healthcare: 19
- database: 15
- infrastructure: 20
- other: 11
```

### Find Outdated References
```bash
# References not verified in last 6 months
/kb-search-tech --outdated 6m

# References with broken links
/kb-search-tech --check-links
```

## Search Index

The command maintains a search index for fast lookups:
- **Full-text index** of titles and descriptions
- **Tag index** for DSM hierarchy
- **Dependency index** for technology relationships
- **Version index** for version-specific searches

Index is automatically rebuilt:
- When new references are added
- When `.claude/sources-registry.yml` is modified
- On demand with `--rebuild-index` flag

## Caching

Search results are cached for 5 minutes:
- Speeds up repeated searches
- Reduces file I/O operations
- Cache cleared on registry updates

## Performance

- **Small queries** (< 10 results): < 50ms
- **Medium queries** (10-50 results): < 200ms
- **Large queries** (> 50 results): < 500ms
- **Full-text search**: < 1s

## Error Handling

### No Results Found
```
No results found for "nonexistent-tech"
Suggestions:
- Check spelling
- Try broader search terms
- Use wildcards: "tech*"
```

### Ambiguous Query
```
Query "Phoenix" is ambiguous
Did you mean:
- Phoenix Framework (Elixir)
- Phoenix LiveView
- Apache Phoenix (HBase)
```

### Too Many Results
```
Found 147 results for "*"
Please refine your search:
- Add --filter to narrow by technology
- Add --level to filter by validation
- Use more specific search terms
```

## Best Practices

1. **Start broad, then narrow** - Begin with general term, add filters
2. **Use official docs first** - Filter by L0_CANONICAL for authoritative sources
3. **Check recency** - Prefer recently verified references
4. **Cross-reference** - Verify information across multiple sources
5. **Export for offline** - Save results for offline reference

## See Also

- `/kb-validate-source` - Add new validated sources
- `/kb-add-reference` - Add pre-validated references
- `.claude/sources-registry.yml` - Browse full registry
- `.claude/dependency-matrix.yml` - Technology dependencies