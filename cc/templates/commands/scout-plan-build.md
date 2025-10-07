---
description: Complete Scout-Plan-Build workflow for complex tasks
argument-hint: <task description> [--docs <url>]
---

# Scout-Plan-Build Workflow

Complete workflow that separates search, planning, and implementation for maximum context efficiency.

## What This Does

1. **Scout**: Parallel search for relevant files (delegated to sub-agents)
2. **Plan**: Create detailed implementation plan (clean context)
3. **Build**: Implement plan systematically (focused execution)

## Arguments
- `$ARGUMENTS`: Task description
- `$DOCUMENTATION_URLS`: Optional documentation URLs (use --docs flag)

## Workflow

### Phase 1: Scout (File Discovery)

Execute the scout command to find all relevant files:

```
/scout $ARGUMENTS
```

**What happens**:
- Spawns 4 parallel sub-agents
- Fast, cheap models (Gemini/Haiku/CodeQwen)
- Searches codebase comprehensively
- Returns condensed `relevant_files.md`

**Output**: `relevant_files.md` (~5K tokens vs ~50K if done manually)

---

### Phase 2: Plan (Strategic Design)

Execute the plan command with clean context:

```
/plan-with-docs $ARGUMENTS $DOCUMENTATION_URLS
```

**What happens**:
- Reads scout results (condensed!)
- Fetches documentation if provided
- Creates detailed implementation plan
- Enters plan mode for review

**Output**: `detailed_plan.md` with phases, file changes, tests

---

### Phase 3: Build (Implementation)

After plan approval, execute build:

```
/build
```

**What happens**:
- Reads plan
- Implements phase by phase
- Tests after each phase
- Creates implementation summary

**Output**:
- Modified files
- `implementation_summary.md`
- Test results

---

## Context Efficiency

### Without Scout-Plan-Build
```
Main Agent Context:
├─ Search results: 30K
├─ File reads: 40K
├─ Documentation: 15K
├─ Planning: 10K
├─ Implementation: 25K
└─ Total: 120K tokens ❌
```

### With Scout-Plan-Build
```
Scout Phase (sub-agents): 160K tokens → 5K summary
Plan Phase: 5K + 10K docs + 10K planning = 25K
Build Phase: 5K plan + 20K implementation = 25K
Main agent max: 25K tokens ✅
Total compute: 210K (delegated efficiently!)
```

## Usage Examples

### Simple task
```bash
/scout-plan-build "Add dark mode toggle to settings"
```

### With documentation
```bash
/scout-plan-build "Migrate authentication to JWT v2" \
  --docs https://jwt.io/introduction
```

### Complex migration
```bash
/scout-plan-build "Refactor database layer to use async SQLAlchemy" \
  --docs https://docs.sqlalchemy.org/en/14/orm/extensions/asyncio.html
```

## Tips for Best Results

✅ **Be specific**: "Add JWT authentication" vs "Improve security"
✅ **Provide docs**: Especially for migrations and new patterns
✅ **Review plan**: Check the plan before approving build
✅ **Trust the process**: Let each phase complete fully

❌ **Don't rush**: Each phase needs proper completion
❌ **Don't skip scout**: Even if you "know" the files
❌ **Don't improvise in build**: Follow the plan

## When to Use

✅ **Complex tasks**: Multiple files, careful planning needed
✅ **Migrations**: SDK updates, framework upgrades
✅ **Refactoring**: Large-scale code improvements
✅ **Feature additions**: Spanning multiple modules
✅ **Bug fixes**: When root cause isn't obvious

❌ **Simple edits**: Overkill for single-file changes
❌ **Trivial tasks**: Use direct prompting instead

## Expected Timeline

- **Scout**: 1-2 minutes (parallel execution)
- **Plan**: 2-4 minutes (thorough analysis)
- **Build**: 5-15 minutes (systematic implementation)

**Total**: ~10-20 minutes for complex tasks that would take hours manually.

---

This is the **core workflow** of elite Claude Code usage. Master this pattern and you'll 10x your engineering output.
