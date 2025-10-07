---
description: Complete Scout-Plan-Build workflow
argument-hint: <task> [--docs <urls>]
---

# Scout-Plan-Build - Complete Workflow

Execute full development workflow with optimized context management.

## Variables

- `$ARGUMENTS`: Task description and flags
- `$DOCUMENTATION_URLS`: Optional documentation URLs (from --docs flag)

## Workflow

### Step 1: Scout (Search Phase)

Execute scout command:
```
/scout $ARGUMENTS
```

**Purpose**: Find all relevant files using parallel sub-agents
**Output**: `relevant_files.md` (condensed file list with metadata)
**Context**: Isolated in sub-agents, then discarded

### Step 2: Plan (Planning Phase)

Execute plan command:
```
/plan-with-docs $ARGUMENTS $DOCUMENTATION_URLS
```

**Purpose**: Create detailed implementation plan
**Input**: `relevant_files.md` from scout
**Output**: `detailed_plan.md` + `ai_docs.md` (cached)
**Context**: Clean window, only scout summary loaded

### Step 3: Build (Implementation Phase)

Execute build command:
```
/build
```

**Purpose**: Implement plan systematically
**Input**: `detailed_plan.md` from plan
**Output**: Modified files + `implementation_summary.md`
**Context**: Focused on implementation

## Context Management

This workflow is optimized for context efficiency:

```
Scout Phase:
├─ 4 sub-agents: ~90K tokens (isolated)
└─ Output: ~10K summary

Plan Phase:
├─ Input: 10K (scout summary)
├─ Process: ~20K
└─ Output: ~18K plan

Build Phase:
├─ Input: 18K (plan)
├─ Process: ~60K
└─ Total peak: ~78K (39% of 200K window)

Efficiency: 170K work done, 78K peak context
```

## Usage Examples

```bash
# Simple task
/scout-plan-build "Add dark mode toggle"

# With documentation
/scout-plan-build "Migrate to new SDK" --docs https://docs.sdk.com/migration

# Complex migration
/scout-plan-build "Refactor authentication system" --docs https://docs.auth.com
```

## Report Format

```markdown
# Scout-Plan-Build Report

## Scout Results
- Found N relevant files
- See: relevant_files.md

## Plan Created
- M phases identified
- See: detailed_plan.md

## Implementation Status
- Phase 1: ✅ Complete
- Phase 2: ✅ Complete
- Phase M: ✅ Complete

## Test Results
- All tests passing ✅

## Files Modified
[List of modified files]
```

## Best Practices

✅ Use for medium-to-large tasks (3+ files)
✅ Let each phase complete before next
✅ Review plan before build phase
✅ Monitor context usage with /context

❌ Don't use for trivial single-file changes
❌ Don't skip phases
❌ Don't interrupt between phases
