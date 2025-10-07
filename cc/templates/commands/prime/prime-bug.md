---
description: Prime agent for bug investigation and fixing
argument-hint: [bug-id or description]
---

# Prime Bug - Systematic Bug Investigation

## Purpose
Prepare agent for systematic bug investigation, root cause analysis, and fixing.

## Run Step

**Initial checks**:
- Check if bug report/issue exists (GitHub, Linear, etc)
- Verify test suite exists
- Check recent commits (might be related)

## Read Step

Priority files for bug investigation:

1. **Bug Report/Issue** (if ID provided)
   - Reproduction steps
   - Expected vs actual behavior
   - Environment details

2. **Test Suite**
   - tests/ directory structure
   - Test coverage for affected area
   - Existing tests that might catch the bug

3. **Recent Changes**
   - CHANGELOG.md
   - git log --oneline -10
   - Recent PRs that might be related

4. **Affected Module**
   - src/[module-name]/ (if known)
   - Related files and dependencies

5. **Troubleshooting Docs**
   - docs/troubleshooting.md (if exists)
   - Known issues and workarounds

## Report Step

Bug investigation context loaded:

**Bug Understanding**:
- Bug description: [summary]
- Affected area: [module/file]
- Reproduction steps: [if available]

**Investigation Context**:
- Test coverage: [status]
- Recent changes: [relevant commits]
- Known issues: [if any]

**Debugging Approach**:
1. Reproduce bug with test
2. Investigate root cause
3. Implement minimal fix
4. Verify fix with tests
5. Check for regressions

---

**Status**: ✅ Agent primed for bug investigation
**Context loaded**: ~4-6K tokens (bug-specific)
**Ready to**: Systematically investigate and fix bug
