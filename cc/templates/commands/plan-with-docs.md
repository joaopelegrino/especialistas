---
description: Create detailed implementation plan based on scout results and documentation
argument-hint: <task description>
---

# Plan Workflow - Strategic Planning

## Purpose
Create a detailed, actionable implementation plan with clean context.

## Input Variables
- $ARGUMENTS: Task description
- $DOCUMENTATION_URLS: Optional documentation URLs
- relevant_files.md: Output from scout phase (if available)

## Instructions

### Step 1: Load Context

If relevant_files.md exists:
- Read relevant_files.md
- Understand current implementation
- Identify affected areas

Otherwise:
- Do quick grep/glob to identify scope
- Read key files identified

### Step 2: Gather Documentation

If $DOCUMENTATION_URLS provided:
- Use WebFetch to get documentation
- Extract key patterns, examples, migration guides
- Save locally as `ai_docs.md` for future reference

### Step 3: Analyze Scope

Determine:
- Files that need changes
- Dependencies and impacts
- Breaking changes potential
- Testing requirements
- Rollback strategy

### Step 4: Design Solution

Break down into phases:
- Phase 1: Setup/preparation
- Phase 2: Core changes
- Phase 3: Integration
- Phase 4: Testing
- Phase 5: Validation

For each phase, specify:
- Exact files and line ranges
- Specific changes (before/after code snippets)
- Test commands
- Success criteria

### Step 5: Create detailed_plan.md

```markdown
# Implementation Plan: [Task Name]

Generated: [timestamp]

## Summary
[1-2 sentence overview of the task]

## Scope Analysis
- **Affected files**: [N files]
- **Complexity**: [Low/Medium/High]
- **Estimated changes**: [~N lines]
- **Breaking changes**: [Yes/No - explanation]

## Dependencies
- [List external dependencies, tools, libraries needed]
- [Database migrations if needed]
- [Configuration changes if needed]

## Phase Breakdown

### Phase 1: [Name]
**Goal**: [What this phase achieves]

**Files to modify**:
- `path/to/file1.py` (lines X-Y)
- `path/to/file2.py` (lines A-B)

**Changes**:
1. Change 1 description
   ```python
   # Before
   old_code()

   # After
   new_code()
   ```

2. Change 2 description
   [...]

**Testing**:
```bash
pytest tests/test_file.py
```

**Success Criteria**:
- [ ] Tests pass
- [ ] No regressions
- [ ] Feature X works

---

[Repeat for each phase]

## Risks & Mitigation
- **Risk**: [Description]
  - **Mitigation**: [How to handle]

## Rollback Plan
If something goes wrong:
1. [Step 1]
2. [Step 2]

## Final Validation
- [ ] All tests pass
- [ ] No performance regression
- [ ] Documentation updated
- [ ] CHANGELOG updated
```

### Step 6: Exit Plan Mode

Enter plan mode (read-only) and present the plan to user for approval.
