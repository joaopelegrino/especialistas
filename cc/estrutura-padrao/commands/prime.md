---
description: Prime agent with general codebase understanding
---

# Prime - General Codebase Understanding

Load foundational knowledge of the codebase with minimal tokens.

## Purpose

Set up agent with general understanding before specific tasks.

## Run Step

Verify project state:
```bash
# Check we're in project root
pwd

# Check dependencies
ls requirements.txt package.json
```

## Read Step

Read these files in order for general context:

### 1. README.md
- Project overview
- Tech stack
- Setup instructions

### 2. Architecture Documentation
Check and read if exists:
- `docs/architecture.md`
- `docs/ARCHITECTURE.md`
- `ARCHITECTURE.md`

### 3. CLAUDE.md
Read project conventions:
- `.claude/CLAUDE.md` (project-specific)

### 4. Entry Point
Identify and read main entry:
- Python: `src/main.py` or `app.py`
- Node: `src/index.js` or `index.ts`
- Check `package.json` "main" field

## Report Step

Provide concise summary:

```markdown
# Codebase Context Loaded

## Project
**Name**: [project name]
**Purpose**: [brief description]

## Tech Stack
- Language: [primary language + version]
- Framework: [main framework]
- Database: [if applicable]
- Other: [key technologies]

## Structure
- Entry point: [file path]
- Source: [main source directory]
- Tests: [test directory]
- Docs: [documentation location]

## Key Patterns
- [Pattern 1]
- [Pattern 2]
- [Pattern 3]

## Development Commands
- Dev: [command]
- Test: [command]
- Build: [command]

Ready for general development tasks.
```

**Tokens loaded**: ~3-4K (minimal, high-relevance)

## Next Steps

After priming, use task-specific primes if needed:
- `/prime-bug` for bug investigation
- `/prime-feature` for new features
- `/prime-migration` for SDK migrations
- `/prime-refactor` for refactoring

## Best Practices

✅ Run this at session start for general work
✅ Keep summary concise (3-4K tokens max)
✅ Focus on actionable information
✅ Skip this if using task-specific prime

❌ Don't read entire codebase
❌ Don't include full file contents
❌ Don't load irrelevant information
