---
description: Prime agent for SDK and library migrations
---

# Prime Migration - SDK/Library Migration Setup

Load context for systematic library and framework migrations.

## Purpose

Prepare agent for safe, systematic migration of dependencies.

## JIT Load: Current State

### 1. Dependencies
```bash
# Check dependency files
cat requirements.txt
cat package.json
cat Gemfile
cat go.mod
```

Identify:
- Current version of library to migrate
- All dependencies that might be affected
- Version constraints

### 2. Architecture Impact
Read if exists:
- `docs/architecture.md`
- `docs/dependencies.md`

Understand:
- How the library is used throughout codebase
- Critical paths that depend on it
- Integration points

## JIT Load: Migration History

Check for previous migration patterns:

```bash
# Check changelog for previous migrations
cat CHANGELOG.md | grep -i "migrat"
cat CHANGELOG.md | grep -i "upgrad"

# Check git history
git log --grep="migrate" --oneline
git log --grep="upgrade" --oneline
```

Learn from past migrations:
- How they were structured
- What issues were encountered
- Testing strategy used

## JIT Load: Testing Strategy

```bash
# Check test coverage of affected areas
pytest --cov=src tests/
npm run test:coverage

# Identify critical test files
ls tests/integration/
ls tests/e2e/
```

Priority:
- Integration tests for the migrating component
- End-to-end tests for critical paths
- Performance tests if relevant

## Report Step

```markdown
# Migration Context Loaded

## Current State
- Library: [name] v[current]
- Target: [name] v[target]
- Usage: [brief description of how it's used]
- Affected files: [estimated count]

## Architecture Impact
- **Critical paths**: [list]
- **Integration points**: [list]
- **Risk level**: [Low/Medium/High]

## Migration Strategy
Based on previous migrations:
1. [Pattern learned from history]
2. [Testing approach]
3. [Rollback strategy]

## Testing Coverage
- Unit tests: [coverage % for affected areas]
- Integration tests: [count and scope]
- Critical paths covered: [yes/no]

## Migration Checklist
- [ ] Backup current state
- [ ] Update dependencies
- [ ] Migrate core usage
- [ ] Update tests
- [ ] Integration testing
- [ ] Document changes
- [ ] Rollback plan ready

Ready for systematic migration with safety nets in place.
```

**Tokens loaded**: ~5-7K (migration-specific)

## Migration Process

After priming, follow systematic approach:

### Phase 1: Research
```bash
# Gather migration documentation
/scout "Find all usages of [old_library]"

# Review documentation
WebFetch([migration guide URL])
```

### Phase 2: Plan
```bash
# Create detailed plan
/plan-with-docs "Migrate from [old] to [new]" --docs [url]
```

Plan should include:
- Backwards compatibility strategy
- Incremental rollout if possible
- Rollback triggers
- Performance impact assessment

### Phase 3: Migrate
```bash
# Execute systematically
/build
```

Test after each change:
- Unit tests
- Integration tests
- Manual verification of critical paths

### Phase 4: Validate
- Full regression test suite
- Performance benchmarks
- Security scan if relevant
- Documentation updates

## Best Practices

✅ Migrate incrementally if possible
✅ Test extensively at each step
✅ Document breaking changes
✅ Keep rollback plan ready
✅ Monitor after deployment

❌ Don't migrate everything at once
❌ Don't skip regression testing
❌ Don't ignore deprecation warnings
❌ Don't forget to update documentation

## Rollback Strategy

Always have a rollback plan:

```bash
# Quick rollback
git revert [commit-hash]
[revert dependency changes]
[run tests to verify]

# Nuclear option
git reset --hard [pre-migration-commit]
```

## Safety Checklist

Before starting migration:
- [ ] All tests passing on current version
- [ ] Git branch created
- [ ] Rollback plan documented
- [ ] Team notified (if applicable)
- [ ] Backup created (if critical)

During migration:
- [ ] Test after each file changed
- [ ] Commit frequently
- [ ] Monitor for warnings
- [ ] Document issues encountered

After migration:
- [ ] Full test suite passing
- [ ] Performance verified
- [ ] Documentation updated
- [ ] Team trained on changes (if applicable)
