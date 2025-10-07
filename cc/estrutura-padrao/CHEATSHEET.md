# Claude Code - Quick Reference Cheatsheet

## 🚀 Quick Install

```bash
# From estrutura-padrao directory
./install.sh /path/to/project

# Or install in current directory
cd /path/to/project
/path/to/estrutura-padrao/install.sh .
```

## 📋 Commands

### Workflow Commands

| Command | Usage | Output |
|---------|-------|--------|
| `/scout` | `/scout "Find JWT usage"` | `relevant_files.md` |
| `/plan-with-docs` | `/plan-with-docs "Migrate SDK" --docs URL` | `detailed_plan.md` + `ai_docs.md` |
| `/build` | `/build` | Modified files + summary |
| `/scout-plan-build` | `/scout-plan-build "Add feature"` | Complete workflow |

### Prime Commands (Context Loading)

| Command | Purpose | Tokens | When to Use |
|---------|---------|--------|-------------|
| `/prime` | General understanding | ~3K | Starting any work |
| `/prime-bug` | Bug investigation | ~5-6K | Debugging, fixing issues |
| `/prime-feature` | Feature development | ~6-8K | New features, enhancements |
| `/prime-migration` | Migrations & refactoring | ~5-7K | Large changes, migrations |

### Utility Commands

| Command | Usage | Purpose |
|---------|-------|---------|
| `/load-bundle` | `/load-bundle .agents/context-bundles/FILE.md` | Restore session state |

## 🤖 Agents

### scout-search (Haiku)
- **Purpose**: Fast parallel search
- **Speed**: < 30s per search
- **Output**: 2K token summary
- **Use**: In `/scout` command

### code-reviewer (Sonnet)
- **Purpose**: Code quality review
- **Focus**: Security, correctness, performance, quality
- **Output**: Prioritized feedback
- **Use**: Manual spawn with Task tool

### security-auditor (Sonnet)
- **Purpose**: Security vulnerability assessment
- **Focus**: OWASP Top 10, CVEs
- **Output**: Risk-rated report
- **Use**: Manual spawn with Task tool

## 🪝 Hooks

### log-to-bundle.sh (Auto)
- **Trigger**: PostToolUse (every tool call)
- **Output**: `.agents/context-bundles/[SESSION]_bundle.md`
- **Benefit**: 70% state recovery, full audit trail

## 📊 Context Management

### Check Usage
```bash
/context  # Check current context usage
```

### When to Clear
```
< 50%  → Keep working
50-70% → Monitor closely
70-85% → Plan to clear soon
> 85%  → Clear now! (Performance degrades)
```

### Save & Reload Pattern
```bash
# 1. Check context
/context  # Shows: 170K/200K (85%)

# 2. Save current state
/clear

# 3. Reload from bundle
/load-bundle .agents/context-bundles/[current-session].md

# 4. Continue with fresh context
# Context now: ~25K/200K ✅
```

## 🎯 Usage Patterns

### Pattern 1: New Feature
```bash
/prime-feature
/scout "Find similar features to X"
/plan-with-docs "Implement feature X" --docs [url]
/build
# If context full:
/clear
/load-bundle [session]
# Continue or review
```

### Pattern 2: Bug Fix
```bash
/prime-bug
/scout "Find code related to bug #123"
# Investigate and fix
# If context full: /clear + /load-bundle
```

### Pattern 3: Large Migration
```bash
/prime-migration
/scout-plan-build "Migrate from X to Y" --docs [guide]
# Monitor with /context
# Use /clear + /load-bundle as needed
```

### Pattern 4: Quick Search
```bash
/prime  # Or skip if trivial
/scout "Find all API endpoints"
# Review relevant_files.md
```

## 📁 File Formats

### relevant_files.md (Scout Output)
```markdown
# Priority 1: Critical Files ⭐⭐⭐

## File: src/auth/jwt_manager.py ⭐ CRITICAL
- **Lines**: 15-180 (165 lines)
- **Offset**: 15, **Length**: 165
- **Purpose**: JWT token management
- **Key Patterns**:
  - Token creation: Lines 45-75
  - Token validation: Lines 80-120
```

### detailed_plan.md (Plan Output)
```markdown
# Implementation Plan: [Task]

## Phase 1: [Name]

**Objective**: [What to accomplish]

**Files to modify**:
1. `src/file.py:45-120`
   - **Current code**:
   ```python
   # old code
   ```
   - **New code**:
   ```python
   # new code
   ```
```

### ai_docs.md (Cached Documentation)
```markdown
# AI Documentation: [Library]

**Source**: https://docs.example.com
**Fetched**: 2025-10-07

## [Section]
[Documentation content]
```

## ⚙️ Configuration

### Minimal settings.json
```json
{
  "autocompact": false,
  "model": "claude-sonnet-4-5",
  "hooks": {
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/log-to-bundle.sh"
      }]
    }]
  }
}
```

### Minimal CLAUDE.md
```markdown
# Project Name

## Essentials
- **Tech**: Python 3.11, FastAPI, PostgreSQL
- **Style**: PEP 8, type hints required
- **Tests**: pytest, 80% coverage required

## Commands
- Dev: `npm run dev`
- Test: `pytest`
- Build: `npm run build`

## Context
- Use `/prime-*` commands for task-specific context
- Context bundles enabled for state recovery
```

**Keep CLAUDE.md < 1K tokens!** Use `/prime` for detailed context.

## 📈 Efficiency Metrics

### Traditional Approach
- Context usage: 150K+ (75%)
- Wasted tokens: ~60K
- Risk: Context overflow
- Recovery: Impossible ❌

### With This Structure
- Context usage: 78K peak (39%)
- Work done: 230K tokens
- Efficiency: 3x more work ✅
- Recovery: 70% via bundles ✅

## 🐛 Quick Troubleshooting

### Commands Not Working
```bash
ls .claude/commands/
head -5 .claude/commands/scout.md  # Check frontmatter
```

### Hooks Not Running
```bash
ls -la .claude/hooks/log-to-bundle.sh  # Should be -rwxr-xr-x
chmod +x .claude/hooks/log-to-bundle.sh
```

### Bundles Not Creating
```bash
ls -la .agents/context-bundles/
mkdir -p .agents/context-bundles/
```

### Context Still High After Clear
- You likely have large CLAUDE.md → Minimize it!
- Use `/prime-*` instead of loading everything upfront

## 💡 Pro Tips

### DO ✅
- Use `/prime` commands for task-specific context (not CLAUDE.md)
- Run `/context` periodically to monitor usage
- Use `/clear` + `/load-bundle` at 70%+ context
- Test after each Build phase
- Keep CLAUDE.md < 1K tokens

### DON'T ❌
- Load everything in CLAUDE.md
- Continue when context is 90%+ (performance degrades)
- Ignore context bundles
- Use workflows for trivial single-file changes
- Skip testing between Build phases

## 🔗 Resources

- **Full Documentation**: `estrutura-padrao/README.md`
- **Hooks Guide**: `estrutura-padrao/hooks/README.md`
- **Context Bundles**: `.agents/context-bundles/`
- **Agent Outputs**: `.agents/outputs/`

## 📞 Support

For issues or questions:
1. Check `estrutura-padrao/README.md` (comprehensive guide)
2. Review troubleshooting section
3. Check hook logs in context bundles
4. Verify settings.json configuration

---

**Version**: 1.0.0
**Last Updated**: 2025-10-07
**Compatible**: Claude Code 2.0+

🚀 **Happy coding with optimized context management!**
