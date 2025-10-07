---
description: Implement the detailed plan systematically
---

# Build - Systematic Implementation

Execute the implementation plan phase by phase with testing.

## Input

Read the plan:
```
Read("detailed_plan.md")
```

## Instructions

### Step 1: Verify Pre-Implementation

Check and execute pre-implementation steps:
- Install dependencies
- Verify documentation cache exists
- Check environment setup

### Step 2: Implement Phase by Phase

For each phase in the plan:

#### a) Read Affected Files
```python
# Use specific line ranges from plan
Read("file.py", offset=X, limit=Y)
```

#### b) Make Changes
```python
# Use Edit for surgical changes (preferred)
Edit("file.py", old_string=..., new_string=...)

# Avoid Write unless creating new files
```

#### c) Test Phase
```bash
# Run test commands from plan
pytest tests/test_specific.py -v
```

**If tests fail**:
1. Review the changes
2. Check error messages
3. Fix issues
4. Re-run tests
5. Do NOT continue to next phase until tests pass

#### d) Report Progress
```markdown
Phase N: [Name] ✅
- Changes implemented
- Tests passing
- Moving to Phase N+1
```

### Step 3: Integration Testing

After all phases complete:

```bash
# Run full test suite
pytest tests/ -v

# Run integration tests
pytest tests/integration/ -v

# Check coverage if specified
pytest --cov=src tests/
```

### Step 4: Final Validation

Verify all success criteria from plan:
- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] No deprecation warnings
- [ ] Functionality works end-to-end

### Step 5: Create Summary

Generate `implementation_summary.md`:

```markdown
# Implementation Summary

## Completed
- Phase 1: [description] ✅
- Phase 2: [description] ✅
- Phase N: [description] ✅

## Files Modified
- path/to/file1.py (lines X-Y)
- path/to/file2.py (lines A-B)

## Test Results
- Unit tests: X/X passing ✅
- Integration tests: Y/Y passing ✅
- Coverage: Z%

## Notes
[Any deviations from plan or issues encountered]
```

## Best Practices

✅ Follow the plan exactly
✅ Test after each phase
✅ Use Edit (not Write) for modifications
✅ Stop and fix if tests fail
✅ Document any deviations

❌ Don't skip phases
❌ Don't continue with failing tests
❌ Don't improvise changes not in plan
