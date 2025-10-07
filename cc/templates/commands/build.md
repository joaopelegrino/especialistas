---
description: Implement the detailed plan systematically with testing
allowed-tools: Read, Write, Edit, MultiEdit, Bash
---

# Build Workflow - Systematic Implementation

## Purpose
Implement the plan methodically, testing after each phase.

## Input
- `detailed_plan.md`: Implementation plan from plan phase
- `relevant_files.md`: File reference (optional)
- `ai_docs.md`: Cached documentation (optional)

## Instructions

### Step 1: Load Plan
Read `detailed_plan.md` and understand all phases.

Identify:
- Total number of phases
- Dependencies between phases
- Test strategy for each phase

### Step 2: Implement Phase by Phase

For each phase in the plan:

#### A. Read Current State
- Use Read tool with specific line ranges (from plan)
- Understand current implementation
- Verify plan assumptions are still valid

#### B. Implement Changes
- Use Edit tool for surgical changes (preferred)
- Use MultiEdit for multiple changes in same file
- Only use Write if creating new file
- Follow plan exactly
- Add inline comments if needed for clarity

#### C. Test Phase
- Run test command specified in plan
- Check output carefully
- If tests fail:
  - Analyze failure
  - Fix issue
  - Re-test
  - Do NOT proceed to next phase until tests pass

#### D. Validate Phase
- Check success criteria from plan
- Ensure no regressions
- Mark phase complete

### Step 3: Integration Testing

After all phases complete:
- Run full test suite
- Check for integration issues
- Verify all success criteria
- Run any additional validation commands

### Step 4: Final Checks

- [ ] All tests passing
- [ ] No new warnings/errors
- [ ] Code follows project conventions
- [ ] Changes match plan
- [ ] No unintended side effects

### Step 5: Create Summary

Create `implementation_summary.md`:

```markdown
# Implementation Summary

Task: [Task name]
Date: [timestamp]

## Changes Made

### Phase 1: [Name]
- Modified: [files]
- Tests: ✅ Passing
- Status: Complete

[Repeat for each phase]

## Files Modified
1. `path/to/file1.py` - [brief description]
2. `path/to/file2.py` - [brief description]

## Test Results
```bash
[Test output showing all passing]
```

## Validation
- [x] All planned changes implemented
- [x] All tests passing
- [x] Success criteria met

## Next Steps
[If any follow-up needed]
```

### Step 6: Report

Report completion with:
- Summary of work done
- Test results
- Any deviations from plan (with justification)
- Recommendations for next steps

## Best Practices

✅ **Follow the plan** - Don't improvise
✅ **Use Edit tool** - Surgical changes only
✅ **Test after each phase** - Catch issues early
✅ **Validate before continuing** - Don't rush
❌ **Don't skip testing** - Even if confident
❌ **Don't rewrite entire files** - Too risky
❌ **Don't implement beyond plan** - Stick to scope
