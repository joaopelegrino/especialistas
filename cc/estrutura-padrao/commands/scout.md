---
description: Search codebase using parallel sub-agents
argument-hint: <search-query>
---

# Scout - Parallel Search

Search codebase efficiently using 4 parallel sub-agents.

## Instructions

**Task**: Search for `$ARGUMENTS` across the codebase

### Step 1: Launch 4 Parallel Search Agents

Use Task tool to spawn 4 search agents in parallel:

```
Agent 1 (Gemini Flash): Fast pattern matching
Agent 2 (Claude Haiku): Accurate code understanding
Agent 3 (CodeQwen): Language-specific patterns
Agent 4 (Gemini Flash): Config and documentation search
```

Each agent should:
- Use Grep/Glob to find relevant files
- Read key sections using offset/limit for large files
- Extract critical information only
- Return CONDENSED summary (not full content)

### Step 2: Consolidate Results

Create `relevant_files.md` with format:

```markdown
# Relevant Files: [Search Query]

## Summary
Found N files matching criteria

## File: path/to/file.py
- **Lines**: X-Y (Z lines)
- **Offset**: X, **Length**: Z
- **Purpose**: [Brief description]
- **Key Pattern**: [What was found]
- **Context**: [Why it's relevant]
- **Tests**: [Related test files]
```

### Step 3: Report

Save `relevant_files.md` and report:
"Scout complete. Found N relevant files. See relevant_files.md"

## Output Format

File paths with line ranges, not full content!
Focus on actionable information for planning phase.
