---
description: Prime agent for feature development
argument-hint: [feature description]
---

# Prime Feature - New Feature Development

## Purpose
Set up agent for feature development following project patterns and best practices.

## Run Step

**Setup checks**:
- Verify feature branch exists (or needs creation)
- Check if feature requirements/spec exists
- Review recent features (for patterns)

## Read Step

Essential files for feature development:

1. **Architecture Documentation**
   - docs/architecture.md - System design
   - Understand where feature fits

2. **Similar Existing Features**
   - Find similar implementations
   - Study patterns and conventions
   - Review code structure

3. **Testing Patterns**
   - tests/ directory
   - Test utilities and fixtures
   - Coverage expectations

4. **API Conventions**
   - docs/api.md (if exists)
   - API design patterns
   - Request/response formats

5. **Development Guidelines**
   - CONTRIBUTING.md
   - Code style requirements
   - Review process

## Report Step

Feature development context loaded:

**Architecture Understanding**:
- Where feature fits: [module/layer]
- Dependencies: [what it needs]
- Integration points: [what it affects]

**Implementation Patterns**:
- Similar features: [examples]
- Code structure: [conventions]
- Testing approach: [patterns]

**Development Plan**:
1. Design feature following patterns
2. Implement with tests (TDD if appropriate)
3. Follow project conventions
4. Document API/usage
5. Create tests for edge cases

**Success Criteria**:
- [ ] Feature works as specified
- [ ] Tests pass (80%+ coverage)
- [ ] Follows project patterns
- [ ] Documentation updated

---

**Status**: ✅ Agent primed for feature development
**Context loaded**: ~5-7K tokens (feature-focused)
**Ready to**: Implement feature following project standards
