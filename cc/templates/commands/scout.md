---
description: Search codebase for files needed to complete the task using parallel sub-agents
argument-hint: <task description>
---

# Scout Workflow - Parallel File Search

## Purpose
Use 4 parallel sub-agents to quickly find all relevant files for the task.

## Instructions

### Step 1: Parse Task
Understand what we're searching for in: $ARGUMENTS

Identify key search terms, patterns, and file types.

### Step 2: Launch 4 Parallel Scouts

Use the Task tool to spawn 4 search agents in parallel:

**Scout 1 (Gemini/Haiku)**: Search for [primary pattern]
- Use Grep with key terms
- Use Glob for file discovery
- Focus on main implementation files

**Scout 2 (Gemini/Haiku)**: Search for [secondary pattern]
- Related functionality
- Dependencies
- Configuration

**Scout 3 (CodeQwen/Haiku)**: Search for [tests/docs]
- Test files
- Documentation
- Examples

**Scout 4 (Gemini/Haiku)**: Search for [edge cases]
- Error handling
- Edge cases
- Integration points

### Step 3: Consolidate Results

Create `relevant_files.md` with this structure:

```markdown
# Relevant Files for [Task]

Generated: [timestamp]

## Summary
Found N relevant files across M directories.

## Files

### File: [path]
- Lines: [start-end]
- Purpose: [brief description]
- Offset: [line number], Length: [number of lines]
- Key pattern: [what was found]

### File: [path]
...
```

### Step 4: Report
Save `relevant_files.md` and report:
"Scout complete. Found N files. See relevant_files.md for details."

## Guidelines

✅ Return CONDENSED summaries (file path + line ranges + key findings only)
✅ Use offset/limit when reading large files
✅ Focus on HIGH-SIGNAL information
❌ Do NOT copy entire file contents
❌ Do NOT return verbose tool outputs
