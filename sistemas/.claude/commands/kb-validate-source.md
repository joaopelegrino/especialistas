# kb-validate-source

Validates source credibility and adds to the Healthcare WASM-Elixir Stack knowledge base registry.

## Usage

```
/kb-validate-source <url> <title>
```

## Parameters

- `url` (required): Full URL of the source to validate
- `title` (required): Title of the document/article/paper

## Description

This command performs a comprehensive validation of a source according to the validation rules defined in `.claude/validation-rules.yml`. It:

1. **Checks URL validity** against approved/blocked domain lists
2. **Extracts metadata** (author, publication date, content type)
3. **Analyzes content quality** (code examples, references, technical depth)
4. **Cross-validates** claims with canonical sources
5. **Assigns validation level** (L0-L3) and credibility score
6. **Adds to sources registry** if validation passes

## Validation Levels

- **L0_CANONICAL** (100 pts): Official docs, RFCs, NIST standards
- **L1_ACADEMIC** (90 pts): Peer-reviewed research papers
- **L2_VALIDATED** (75 pts): Industry whitepapers, verified technical blogs
- **L3_COMMUNITY** (50 pts): Community content requiring additional verification

## Examples

```bash
# Validate official Elixir documentation
/kb-validate-source https://elixir-lang.org/docs.html "Elixir Official Documentation"

# Validate academic paper
/kb-validate-source https://dl.acm.org/doi/10.1145/3062341.3062363 "Bringing the Web up to Speed with WebAssembly"

# Validate technical blog post
/kb-validate-source https://fly.io/phoenix-files/crafting-your-own-conn/ "Crafting Your Own Conn"
```

## Validation Process

### Step 1: Initial URL Check
- Extract domain from URL
- Check against approved domains list
- Check against blocked domains list
- Verify URL accessibility (HTTP 200)
- Validate SSL certificate

### Step 2: Metadata Extraction
- Title, author, organization
- Publication date or last update
- Content type identification
- Version information (if applicable)

### Step 3: Content Analysis
- Presence of code examples
- External references quality
- Technical depth assessment
- Red flag detection

### Step 4: Cross-Validation
- Compare claims with canonical sources
- Verify version compatibility
- Validate author credentials
- Confirm technical accuracy

### Step 5: Scoring & Assignment
- Calculate base score from validation level
- Apply modifiers (+/- based on quality indicators)
- Assign final validation level
- Add to `.claude/sources-registry.yml`
- Schedule re-verification date

## Scoring Modifiers

### Positive (+)
- Has code examples: +5
- Includes benchmarks: +5
- Cites official sources: +5
- Recently updated: +3
- Active maintenance: +3
- Author verified: +3

### Negative (-)
- Outdated content: -10
- Broken links: -15
- No author: -10
- No date: -10
- Generic claims: -5
- Poor technical depth: -10

## Red Flags (Auto-Reject)

- Claims of "unbreakable" security
- Proprietary crypto algorithms (for security content)
- No author attribution
- Paywalled without DOI
- Known misinformation source

## Approved Domains

### Official Documentation
- elixir-lang.org, erlang.org, hexdocs.pm
- phoenixframework.org, webassembly.org
- extism.org, postgresql.org, kubernetes.io

### Standards Bodies
- csrc.nist.gov, nvlpubs.nist.gov
- www.rfc-editor.org, w3.org, ietf.org

### Academic
- dl.acm.org, ieeexplore.ieee.org
- arxiv.org, scholar.google.com

### Healthcare
- hl7.org, fhir.org, dicomstandard.org
- hhs.gov, planalto.gov.br

## Blocked Domains
- *.blogspot.com (uncurated blogs)
- wordpress.com/* (personal blogs)
- quora.com (unvalidated Q&A)

## Output Format

```yaml
# Added to .claude/sources-registry.yml
<technology>:
  <category>:
    - title: "Document Title"
      url: "https://example.com/doc"
      validation_level: "L0_CANONICAL"
      last_verified: "2025-09-30"
      credibility_score: 105
      author: "Author Name"
      publication_date: "2025-01-15"
      notes: "Official documentation, includes code examples"
```

## Re-Validation Schedule

- **L0_CANONICAL**: Quarterly (official docs)
- **L1_ACADEMIC**: Yearly (static research)
- **L2_VALIDATED**: Monthly (updated blogs/whitepapers)
- **L3_COMMUNITY**: Weekly (fast-changing community content)

## Integration

This command integrates with:
- `.claude/config.yml` - Stack versions and validation config
- `.claude/sources-registry.yml` - Master registry of validated sources
- `.claude/validation-rules.yml` - Validation criteria and rules

## Error Handling

- **URL not accessible**: Returns error, suggests checking URL
- **Blocked domain**: Rejects with explanation
- **Low credibility score**: Warns user, requires manual approval
- **Duplicate entry**: Updates existing entry with new verification date

## Best Practices

1. **Always validate before adding** - Don't add sources without validation
2. **Check recency** - Prefer sources updated within last 2 years
3. **Cross-reference** - Validate claims against multiple sources
4. **Document provenance** - Always include author and date
5. **Update regularly** - Re-validate sources on schedule

## See Also

- `/kb-add-reference` - Add pre-validated reference
- `/kb-search-tech` - Search knowledge base
- `.claude/validation-rules.yml` - Full validation criteria