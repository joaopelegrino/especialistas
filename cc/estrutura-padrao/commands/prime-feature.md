---
description: Prime agent for feature development
---

# Prime Feature - Feature Development Setup

Load context for designing and implementing new features.

## Purpose

Prepare agent with architecture patterns and development guidelines.

## JIT Load: Architecture Context

Read these files on-demand:

### 1. Architecture Documentation
```bash
# Check for architecture docs
ls docs/architecture.md
ls docs/design/
ls ADR/  # Architecture Decision Records
```

Read if exists:
- `docs/architecture.md`
- `docs/design-patterns.md`
- `docs/api-conventions.md`
- `ADR/` directory (recent decisions)

### 2. Feature Examples
Identify similar existing features:
```bash
# Check feature structure
ls src/features/
ls src/modules/
```

Read 1-2 similar feature implementations as reference.

## JIT Load: Development Patterns

Based on project type:

### API/Backend Development
- RESTful conventions
- Request/response patterns
- Error handling
- Database migrations
- API versioning

### Frontend Development
- Component structure
- State management patterns
- Routing conventions
- Styling approach
- Testing strategy

### Full-Stack Features
- Frontend-backend integration
- API contracts
- Data flow
- Authentication/authorization

## JIT Load: Testing Patterns

```bash
# Check test patterns
ls tests/features/
ls tests/integration/
```

Understand:
- Unit test structure
- Integration test patterns
- Fixtures and mocks
- Test data setup

## Report Step

```markdown
# Feature Development Context Loaded

## Architecture Patterns
- Structure: [how features are organized]
- Naming: [conventions for files/functions]
- Layers: [separation of concerns]

## Development Workflow
1. [Step 1: e.g., Create feature branch]
2. [Step 2: e.g., Implement core logic]
3. [Step 3: e.g., Add tests]
4. [Step 4: e.g., Update documentation]

## Similar Features Reference
- [Feature 1]: [location] - [key pattern]
- [Feature 2]: [location] - [key pattern]

## Testing Strategy
- Unit tests: [pattern]
- Integration tests: [pattern]
- Coverage requirement: [X%]

## API Conventions (if applicable)
- Endpoints: [pattern]
- Request/Response: [format]
- Error handling: [approach]

Ready for feature development following project standards.
```

**Tokens loaded**: ~6-8K (design-focused)

## Usage

```bash
# Before implementing new feature
/prime-feature

# Then design and implement
"Add user profile editing feature"
```

## Design-First Approach

After priming, follow this process:

1. **Design Phase**
   - Sketch data models
   - Define API contracts
   - Plan component structure

2. **Implementation Phase**
   - Follow patterns from similar features
   - Implement with tests
   - Document as you go

3. **Integration Phase**
   - Test integration points
   - Update documentation
   - Verify against requirements

## Best Practices

✅ Study similar existing features first
✅ Follow established patterns
✅ Test at each layer
✅ Document new patterns if introduced

❌ Don't reinvent patterns
❌ Don't skip tests
❌ Don't deviate from conventions without reason
