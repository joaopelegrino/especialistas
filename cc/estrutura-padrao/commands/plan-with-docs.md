---
description: Create detailed implementation plan with documentation
argument-hint: <task> --docs <urls>
---

# Plan with Documentation

Create comprehensive implementation plan using Scout output and documentation.

## Input Variables

- `$ARGUMENTS`: Task description
- `$DOCUMENTATION_URLS`: URLs to relevant documentation

## Instructions

### Step 1: Analyze Scope

Read Scout output:
```
Read("relevant_files.md")
```

Understand:
- What files need modification
- Current implementation patterns
- Dependencies and relationships

### Step 2: Fetch Documentation

For each documentation URL:
```
WebFetch($DOCUMENTATION_URL)
```

Save to `ai_docs.md` for caching:
```markdown
# Cached Documentation

## Source: [URL]
**Fetched**: [timestamp]

### Key Information
[Condensed important sections]

### Migration Patterns
[Before/After examples]

### Common Pitfalls
[Known issues to avoid]
```

### Step 3: Design Solution

Create `detailed_plan.md` with structure:

```markdown
# Implementation Plan: [Task]

## Executive Summary
- Strategy: [approach]
- Complexity: [Low/Medium/High]
- Risk: [assessment]
- Estimated time: [duration]

## Pre-Implementation
- Dependencies to install
- Documentation cache location

## Phase 1: [Name]
### File: path/to/file.py
**Lines to modify**: X-Y

**Before**:
```[code]```

**After**:
```[code]```

**Changes**:
1. [Specific change]
2. [Specific change]

**Test**:
```bash
[test command]
```

**Expected**: ✅ [result]

## Phase 2-N: [Continue...]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Rollback Plan
[Steps to revert if needed]
```

### Step 4: Enter Plan Mode

After creating detailed_plan.md, enter plan mode for user review.

## Best Practices

- Be specific with file paths and line ranges
- Include before/after code examples
- Provide test commands for each phase
- Document rollback strategy
- Cache documentation locally
