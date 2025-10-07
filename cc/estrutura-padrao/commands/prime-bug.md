---
description: Prime agent for bug investigation and fixing
---

# Prime Bug - Bug Investigation Setup

Load context specifically for debugging and fixing bugs.

## Purpose

Prepare agent with testing infrastructure and debugging knowledge.

## JIT Load: Testing Context

Read these files on-demand:

### 1. Test Infrastructure
```bash
# Check test setup
ls tests/
ls test/
```

Read if exists:
- `tests/README.md` or `test/README.md`
- `pytest.ini` or `jest.config.js`
- `.github/workflows/test.yml`

### 2. Debugging Documentation
Read if exists:
- `docs/debugging.md`
- `docs/troubleshooting.md`
- `TROUBLESHOOTING.md`

## JIT Load: Common Bug Patterns

Based on project type, load relevant patterns:

### Web/API Projects
- Authentication issues (JWT, sessions)
- Database connection/query errors
- API endpoint errors
- CORS issues

### Python Projects
- Import errors
- Type errors
- Async/await issues
- Package conflicts

### JavaScript/Node Projects
- Async callback issues
- Promise rejections
- Event loop problems
- Module resolution

## JIT Load: Debugging Tools

Document available debugging commands:

```bash
# Python debugging
python -m pdb script.py
pytest tests/ -v --pdb
pytest tests/ -v -k "test_name"

# JavaScript debugging
npm run test -- --verbose
node --inspect script.js
npm run test:debug

# Logs
tail -f logs/app.log
tail -f logs/error.log

# Coverage
pytest --cov=src tests/
npm run test:coverage
```

## Report Step

```markdown
# Bug Investigation Context Loaded

## Testing Infrastructure
- Test framework: [pytest/jest/etc]
- Test location: [path]
- Total tests: [count if known]
- Run command: [command]

## Common Bug Areas
Based on this project type:
- [Area 1]: [common patterns]
- [Area 2]: [common patterns]
- [Area 3]: [common patterns]

## Debugging Tools Ready
- [Tool 1]: [usage]
- [Tool 2]: [usage]
- [Tool 3]: [usage]

## Investigation Strategy
1. Reproduce the bug
2. Check recent changes (git log)
3. Review relevant tests
4. Add debugging statements
5. Fix and verify with tests

Ready for systematic bug investigation.
```

**Tokens loaded**: ~5-6K (debugging-focused)

## Usage

```bash
# At session start for bug fixing
/prime-bug

# Then investigate
"Investigate authentication timeout issue"
```

## Best Practices

✅ Run before starting bug investigation
✅ Check test coverage of buggy area
✅ Review recent commits for context
✅ Add tests that reproduce the bug

❌ Don't skip test infrastructure review
❌ Don't fix without tests
❌ Don't ignore related issues
