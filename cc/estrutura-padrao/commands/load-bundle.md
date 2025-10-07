---
description: Load context bundle to restore previous session state
argument-hint: <bundle-file-path>
---

# Load Context Bundle

Restore agent state from a previous session using context bundle.

## Purpose

Enable continuation of work after:
- Context overflow
- Session interruption
- Switching to fresh agent

## Instructions

### Step 1: Read Bundle File

```
Read($ARGUMENTS)
```

Bundle file location: `.agents/context-bundles/`

### Step 2: Parse Bundle Contents

Extract and understand:

#### Initial Context
- Which prime command was used
- Original task description
- Documentation sources

#### Tool Calls Summary
- Files that were read (with line ranges)
- Key searches performed
- Modifications made
- Tests run

#### Key Findings
- Important discoveries from the session
- Architectural insights
- Decisions made

#### Progress Tracking
- Which phases were completed
- Current phase and status
- Next actions

### Step 3: Create Condensed Summary

**DO NOT include**:
- ❌ Full tool call logs (too verbose)
- ❌ Exact timestamps (not relevant for continuation)
- ❌ Hook metadata (internal)
- ❌ Complete file contents

**DO include**:
- ✅ Files examined (paths + line ranges)
- ✅ Key findings from each area
- ✅ Decisions made and rationale
- ✅ Current progress and phase
- ✅ Next actions to take

### Step 4: Report Restored State

```markdown
# Session Restored from Bundle

**Original Session**: [session-id]
**Started**: [date/time]
**Task**: [task description]

## Context Recovered

### Prime Used
[which prime command was used]

### Files Examined
- [file1]: [lines X-Y] - [finding]
- [file2]: [lines A-B] - [finding]
- [fileN]: [lines M-N] - [finding]

Total: N files examined

### Key Findings
1. [Finding 1]
2. [Finding 2]
3. [Finding N]

### Decisions Made
1. [Decision 1]: [rationale]
2. [Decision 2]: [rationale]

### Work Completed
- [✅] Phase 1: [description]
- [✅] Phase 2: [description]
- [⏳] Phase 3: [current phase - in progress]
- [ ] Phase 4: [pending]

## Current State

**Progress**: Phase 3/N ([percentage]%)

**Current Focus**: [what was being worked on]

**Next Actions**:
1. [Next immediate action]
2. [Then what]
3. [After that]

## Ready to Continue

Agent is now primed with session context.
Context usage: [X]K tokens ([Y]% of window)

Ready to continue where previous session left off.
```

### Step 5: Continue Work

Agent is now ready to:
- Continue from current phase
- Make informed decisions based on previous work
- Maintain consistency with earlier choices

## Usage Examples

```bash
# Simple restore
/load-bundle .agents/context-bundles/20251007_jwt_migration.md

# After restore, continue work
"Continue with Phase 3 of the migration"
```

## Context Efficiency

```
Without Bundle:
├─ Start from scratch: 150K+ tokens to rebuild context
├─ Re-search files: 30K
├─ Re-read files: 50K
├─ Re-analyze: 40K
└─ Total: 150K wasted tokens

With Bundle:
├─ Load bundle summary: 20K tokens
├─ Immediate continuation: Ready
└─ Saved: 130K tokens (87% reduction)

State Recovery: 70%+ of previous session context
```

## Best Practices

### ✅ DO

**1. Load bundle when context is full**
```bash
# Check context
/context

# If approaching 80%+
/clear
/load-bundle [session-file]
```

**2. Use bundle for interrupted sessions**
```bash
# Session interrupted yesterday
# Today, resume:
/load-bundle .agents/context-bundles/[yesterday-session].md
```

**3. Keep bundle summaries concise**
- Focus on actionable information
- Emphasize decisions and findings
- Include next actions

### ❌ DON'T

**1. Load very old bundles without verification**
```bash
# ❌ Code may have changed significantly
/load-bundle .agents/context-bundles/6_months_ago.md

# ✅ Recent bundles are safe
/load-bundle .agents/context-bundles/yesterday.md
```

**2. Include full tool outputs in summary**
```markdown
# ❌ Too verbose
[14:30] Read file:
[2000 lines of code...]

# ✅ Condensed
[14:30] Read auth.py (lines 45-120): JWT logic
```

**3. Forget which prime was used**
```markdown
# ✅ Bundle should note the prime
Initial Context: /prime-migration loaded
# This helps restore the same mindset
```

## Integration with Workflows

### With Scout-Plan-Build
```bash
# Phase 1: Scout
/scout "search query"

# Phase 2: Plan (context filling up)
/plan-with-docs "task" --docs [url]

# Context at 150K - save and reload
/clear
/load-bundle [current-session]

# Phase 3: Build (fresh context!)
/build
```

### With Prime Commands
```bash
# Original session
/prime-bug
[work... context fills]

# New session
/load-bundle [session]
# Bundle notes prime-bug was used
# Continue with same debugging mindset
```

## Bundle File Locations

Default: `.agents/context-bundles/`

Naming convention:
```
YYYYMMDD_HHMMSS_description.md
20251007_143000_jwt_migration.md
20251007_150000_add_dark_mode.md
```

Recent bundles:
```bash
# List recent bundles
ls -lt .agents/context-bundles/ | head -5

# Find specific bundle
ls .agents/context-bundles/ | grep "jwt"
```

## Troubleshooting

**Bundle file not found**:
```bash
# Check if hooks are configured
cat .claude/settings.json | grep PostToolUse

# Check bundle directory exists
ls .agents/context-bundles/
```

**Bundle too large**:
- Bundles should be summaries, not full logs
- Check if hook script is logging too verbosely
- Consider adjusting hook script

**Can't find relevant bundle**:
```bash
# Use descriptive session IDs
# Or add notes to bundle files manually
```
