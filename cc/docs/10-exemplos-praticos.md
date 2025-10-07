# 10. Exemplos Práticos

> **Templates prontos e casos de uso real para começar imediatamente**

## Scout-Plan-Build completo

### scout.md
```markdown
---
description: Search codebase using parallel sub-agents
---

Launch 4 parallel search agents:

Agent 1 (Gemini): Search for $ARGUMENTS
Agent 2 (Haiku): Search for $ARGUMENTS
Agent 3 (CodeQwen): Search for $ARGUMENTS
Agent 4 (Gemini): Search for $ARGUMENTS

Consolidate results into relevant_files.md with:
- File paths
- Line ranges
- Key findings

Return: "Scout complete. Found N files."
```

### plan-with-docs.md
```markdown
---
description: Create detailed implementation plan
---

Read relevant_files.md from scout phase

Fetch documentation: $DOCUMENTATION_URLS

Create detailed_plan.md with:
## Summary
## Phases
  - Phase 1: [What to change]
    - Files: [list with line ranges]
    - Changes: [specific changes]
    - Tests: [validation commands]
## Success Criteria

Enter plan mode when done.
```

### scout-plan-build.md
```markdown
---
description: Complete workflow from search to implementation
---

/scout $ARGUMENTS

/plan-with-docs $ARGUMENTS

/build
```

## Migration Workflow

### Task: Migrate to New SDK

```bash
/scout-plan-build "Migrate from old SDK to Claude Agent SDK v2" \
  --docs https://docs.claude.com/agent-sdk
```

**What happens**:
1. Scout spawns 4 agents → searches codebase
2. Plan reads scout results + docs → creates plan
3. Build implements plan → tests each phase

## Code Review Workflow

### multi-review.md
```markdown
---
description: Comprehensive review from multiple agents
---

Launch 3 parallel reviewers:

Security Agent: Review for auth, injection, data exposure
Performance Agent: Review for bottlenecks, N+1 queries
Quality Agent: Review for readability, conventions, tests

Consolidate into final_review.md with priority:
- CRITICAL (security)
- HIGH (performance)
- MEDIUM (quality)
```

## Feature Development

### feature-tdd.md
```markdown
---
description: Build feature with test-driven development
---

## Phase 1: Tests First
Create test file for $ARGUMENTS
Write failing tests covering:
- Happy path
- Edge cases
- Error handling

## Phase 2: Implementation
Implement $ARGUMENTS to make tests pass

## Phase 3: Refactor
Improve implementation while keeping tests green

## Phase 4: Integration
Add integration tests
Validate with full test suite
```

## Database Migration

### db-migrate.md
```markdown
---
description: Safe database schema migration
---

/scout "Find all database models and migrations"

Generate migration file:
- Analyze current schema
- Create migration up/down
- Add data migration if needed

Test migration:
- Backup test database
- Apply migration
- Verify schema
- Test rollback

Create commit with migration
```

## API Integration

### integrate-api.md
```markdown
---
description: Integrate external API
---

## Phase 1: Research
Fetch API documentation: $DOCUMENTATION_URL
Understand endpoints, auth, rate limits

## Phase 2: Design
Create API client interface
Define models for API responses
Plan error handling strategy

## Phase 3: Implement
Build API client with:
- Authentication
- Request/response handling
- Error handling
- Rate limiting
- Retries

## Phase 4: Test
Unit tests for client
Integration tests with API
Mock tests for edge cases
```

## Refactoring Workflow

### refactor-module.md
```markdown
---
description: Safely refactor code module
---

## Pre-refactor
Run full test suite
Create refactor branch: git checkout -b refactor/$MODULE

## Refactor
Identify code smells in $MODULE
Extract functions/classes
Improve naming
Add missing tests

## Validate
Run tests after each change
Ensure 100% pass rate
Check coverage didn't decrease

## Finalize
Run full test suite
Create PR: /create-pr "Refactor $MODULE"
```

## Documentation Generation

### doc-api.md
```markdown
---
description: Generate API documentation
---

Scan all API endpoints in $ARGUMENTS

For each endpoint, generate:
- HTTP method and path
- Parameters (query, path, body)
- Request/response examples
- Error responses
- Rate limits
- Auth requirements

Create docs/API.md with complete reference

Generate OpenAPI spec if needed
```

## Security Audit

### security-audit.md
```markdown
---
description: Comprehensive security audit
---

Launch 3 parallel security checks:

Agent 1: Authentication/Authorization
- Check auth implementations
- Verify permission checks
- Look for auth bypasses

Agent 2: Input Validation
- SQL injection risks
- XSS vulnerabilities
- Command injection

Agent 3: Data Protection
- Sensitive data exposure
- Encryption usage
- Secrets in code

Consolidate into security_report.md:
- CRITICAL issues (fix immediately)
- HIGH issues (fix this sprint)
- MEDIUM issues (plan fix)
```

## Performance Optimization

### optimize-perf.md
```markdown
---
description: Identify and fix performance issues
---

## Profile
Run performance profiling on $ARGUMENTS
Identify bottlenecks

## Analyze
/scout "Find implementations of slow operations"

Review:
- Database queries (N+1?)
- Algorithms (O(n²)?)
- Memory usage
- Network calls

## Optimize
For each bottleneck:
- Implement optimization
- Measure improvement
- Ensure tests pass

## Validate
Run performance benchmarks
Compare before/after metrics
Create performance report
```

## Continuous Integration

### ci-pipeline.md
```markdown
---
description: Set up CI/CD pipeline
---

## Create Workflow Files
Generate .github/workflows/ci.yml with:
- Lint checks
- Unit tests
- Integration tests
- Build verification

## Add Quality Gates
- Minimum test coverage: 80%
- No lint errors
- Security scan pass
- Build success

## Configure Notifications
Slack/email on:
- Build failures
- PR ready for review
- Deploy success

## Documentation
Update CONTRIBUTING.md with CI requirements
```

---

## Exemplo Completo: Sistema de Armazenamento e Coleta Otimizado

> **Caso real**: Migração de authentication system com todas as técnicas de context engineering integradas

### Contexto do Projeto

```
Project: E-commerce Platform
Task: Migrate authentication from old_jwt to new_jwt v2.0
Codebase: 50 files, ~15K lines
Complexity: Medium-High (critical authentication system)
```

### Setup Inicial: Minimal Context

#### 1. CLAUDE.md (Minimal - 500 tokens)

```markdown
# E-commerce Platform

## Essentials
- **Tech**: Python 3.11, FastAPI, PostgreSQL, React
- **Style**: PEP 8, 2-space indents
- **Tests**: pytest, 80%+ coverage required

## Commands
- Dev: `uvicorn main:app --reload`
- Test: `pytest -v`
- Build: `npm run build`

## Primes Available
- `/prime` - General understanding
- `/prime-bug` - Bug investigation
- `/prime-feature` - Feature development
- `/prime-migration` - SDK/library migrations

## Context Management
- Disable autocompact: Settings → autocompact: false
- Use context bundles for long sessions
- /clear at strategic breakpoints
```

#### 2. Prime Command para Migration

```markdown
# .claude/commands/prime-migration.md
---
description: Prime agent for SDK and library migrations
---

# Prime Migration

## JIT Load: Migration Context

Read on-demand:
1. `README.md` - Dependencies overview
2. `requirements.txt` - Current versions
3. `docs/architecture.md` - System design
4. `CHANGELOG.md` - Previous migration patterns

## JIT Load: Testing Strategy

```bash
# Test commands
pytest tests/test_auth.py -v
pytest tests/integration/ -v
pytest --cov=src/auth tests/
```

## Report

Migration context loaded:
- Current dependencies identified
- Architecture understood
- Testing strategy ready
- Ready for systematic migration

**Tokens loaded**: ~5K (migration-specific)
```

### Execução: Scout-Plan-Build com Armazenamento Otimizado

#### Fase 1: Scout (Coleta Distribuída)

```bash
# Session startup
claude

# Context inicial: 5.5K tokens (CLAUDE.md + system)

# Prime para migration
/prime-migration
# +5K tokens (JIT loaded)

# Kick off Scout
/scout "Find all usages of old_jwt library"
```

**Scout Execution**:

```
Main Agent spawns 4 sub-agents (parallel):

Sub-agent 1 (Gemini Flash - Fast):
├─ Task: "Search for old_jwt imports"
├─ Context used: 25K tokens
│   ├─ Grep "import old_jwt" → 8 matches
│   ├─ Grep "from old_jwt" → 5 matches
│   ├─ Read 8 files (with offset/limit)
│   └─ Analyze import patterns
└─ Returns: 2K summary → relevant_files_imports.md

Sub-agent 2 (Haiku - Accurate):
├─ Task: "Search for JWT encode/decode calls"
├─ Context used: 30K tokens
│   ├─ Grep "jwt.encode" → 12 matches
│   ├─ Grep "jwt.decode" → 15 matches
│   ├─ Read matching sections
│   └─ Identify usage patterns
└─ Returns: 2.5K summary → relevant_files_usage.md

Sub-agent 3 (CodeQwen - Code-focused):
├─ Task: "Search for test files covering JWT"
├─ Context used: 20K tokens
│   ├─ Glob "tests/**/test_*jwt*.py"
│   ├─ Glob "tests/**/test_auth*.py"
│   ├─ Read test structures
│   └─ Identify test coverage
└─ Returns: 1.5K summary → relevant_files_tests.md

Sub-agent 4 (Gemini Flash - Config):
├─ Task: "Search for configuration and secrets"
├─ Context used: 15K tokens
│   ├─ Grep "SECRET_KEY" → 6 matches
│   ├─ Grep "JWT_ALGORITHM" → 4 matches
│   ├─ Read config files
│   └─ Map configuration structure
└─ Returns: 2K summary → relevant_files_config.md

Consolidation (Main Agent):
├─ Read all 4 summaries: 8K tokens
├─ Merge into relevant_files.md: 10K output
└─ Main agent context: 23.5K tokens

Sub-agent contexts: DESCARTADOS (90K freed!)
```

**relevant_files.md** (Scout Output - 10K tokens):

```markdown
# Relevant Files: JWT Migration

## Summary
Found 8 core files + 12 test files requiring updates.
Total lines to migrate: ~450 lines.
Test coverage: Good (42 tests cover JWT functionality)

## Core Authentication Files

### src/auth/jwt_manager.py ⭐ CRITICAL
- **Lines**: 15-180 (165 lines)
- **Offset**: 15, **Length**: 165
- **Purpose**: Centralized JWT management
- **Key Patterns**:
  - Token creation: Lines 45-75 (`old_jwt.encode()`)
  - Token verification: Lines 90-120 (`old_jwt.decode()`)
  - Refresh tokens: Lines 135-165 (`old_jwt.encode()`)
- **Dependencies**: `old_jwt`, `datetime`, `config`
- **Used by**: login.py, api_auth.py, middleware.py
- **Tests**: tests/test_jwt_manager.py (15 tests)
- **Priority**: HIGH (central point - migrate first!)

### src/auth/login.py
- **Lines**: 80-125 (45 lines)
- **Offset**: 80, **Length**: 45
- **Purpose**: Login endpoint using JWT manager
- **Calls**: `jwt_manager.create_token()`
- **Tests**: tests/test_login.py (8 tests)
- **Priority**: MEDIUM (depends on jwt_manager)

### src/auth/middleware.py
- **Lines**: 30-95 (65 lines)
- **Offset**: 30, **Length**: 65
- **Purpose**: Authentication middleware
- **Calls**: `jwt_manager.verify_token()`
- **Tests**: tests/test_middleware.py (6 tests)
- **Priority**: MEDIUM (depends on jwt_manager)

[... more files ...]

## Configuration Files

### config/auth_settings.py
- **Lines**: 10-45 (35 lines)
- **Offset**: 10, **Length**: 35
- **Settings**:
  - `SECRET_KEY` (from env)
  - `JWT_ALGORITHM = "HS256"`
  - `ACCESS_TOKEN_EXPIRE_MINUTES = 30`
  - `REFRESH_TOKEN_EXPIRE_DAYS = 7`
- **Note**: Algorithm explicit in config (good for migration)

## Test Coverage

### tests/test_jwt_manager.py ⭐ CRITICAL
- **Tests**: 15 tests covering all JWT operations
- **Coverage**: create_token, verify_token, refresh_token
- **Status**: All passing with old_jwt
- **Update needed**: Assertions may need adjustment for new library

[... more test files ...]

## Migration Strategy Recommendation

1. **Start with**: `src/auth/jwt_manager.py` (central point)
2. **Then update**: Dependent files (login.py, middleware.py, etc.)
3. **Update tests**: After each file migration
4. **Configuration**: May need algorithm parameter adjustments

## Dependencies Graph

```
jwt_manager.py (CORE) ⭐
├─ login.py
├─ middleware.py
├─ api_auth.py
├─ refresh_handler.py
└─ password_reset.py
```

Updating jwt_manager.py will require updating all dependents.
```

**Context Status** após Scout:
```
Main Agent:
├─ Initial: 5.5K
├─ Prime-migration: 5K
├─ relevant_files.md: 10K
└─ Total: 20.5K tokens (10.25% of window)

Work done: 90K tokens processed (via sub-agents)
Efficiency: 90K → 10K (89% reduction)
```

#### Fase 2: Plan (Context Limpo + Cache)

```bash
# Read scout output
/plan-with-docs "Migrate to new_jwt v2.0" https://docs.new-jwt.com/migration
```

**Plan Execution**:

```
Main Agent (context: 20.5K):
├─ Read relevant_files.md: Already in context
├─ WebFetch docs → Save to ai_docs.md (cached): 8K
├─ Analyze dependencies
├─ Design migration strategy
├─ Create detailed_plan.md: 18K output
└─ Context used: 46.5K tokens (23% of window)

Context Status:
├─ Clean start from Scout output
├─ No re-searching (scout already did)
├─ Documentation cached locally
└─ Ready for Build phase
```

**detailed_plan.md** (Plan Output - 18K tokens):

```markdown
# Implementation Plan: JWT Migration

## Executive Summary
Migrate from `old_jwt` v1.8 to `new_jwt` v2.0.
- **Strategy**: Bottom-up (core first, then dependents)
- **Complexity**: Medium
- **Risk**: Medium (authentication is critical)
- **Estimated time**: 3-4 hours
- **Rollback**: Simple (revert + reinstall)

## Pre-Implementation

### Dependencies
```bash
pip uninstall old_jwt
pip install new_jwt==2.0.1
```

### Documentation Cached
Saved to: `ai_docs.md` (8K tokens)
- Breaking changes documented
- Migration patterns available
- Common pitfalls noted

## Phase 1: Core JWT Manager Migration

### File: src/auth/jwt_manager.py

**Priority**: CRITICAL (central point)
**Lines to modify**: 45-75, 90-120, 135-165

#### Change 1: Token Creation (lines 45-75)

**Before**:
```python
import old_jwt
from config import SECRET_KEY

def create_access_token(data: dict) -> str:
    payload = {
        **data,
        "exp": datetime.utcnow() + timedelta(minutes=30)
    }
    token = old_jwt.encode(payload, SECRET_KEY)
    return token
```

**After**:
```python
import new_jwt
from config import SECRET_KEY, JWT_ALGORITHM

def create_access_token(data: dict) -> str:
    payload = {
        **data,
        "exp": datetime.utcnow() + timedelta(minutes=30)
    }
    token = new_jwt.create(payload, SECRET_KEY, algorithm=JWT_ALGORITHM)
    return token
```

**Changes**:
1. Import: `old_jwt` → `new_jwt`
2. Method: `encode()` → `create()`
3. Parameter: Add `algorithm=JWT_ALGORITHM`
4. Import algorithm from config

**Test**:
```bash
pytest tests/test_jwt_manager.py::test_create_access_token -v
```

**Expected**: ✅ Pass

#### Change 2: Token Verification (lines 90-120)

**Before**:
```python
def verify_token(token: str) -> dict:
    try:
        payload = old_jwt.decode(token, SECRET_KEY)
        return payload
    except old_jwt.ExpiredSignatureError:
        raise TokenExpiredError()
    except old_jwt.InvalidTokenError:
        raise TokenInvalidError()
```

**After**:
```python
def verify_token(token: str) -> dict:
    try:
        payload = new_jwt.verify(token, SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except new_jwt.ExpiredSignatureError:
        raise TokenExpiredError()
    except new_jwt.InvalidTokenError:
        raise TokenInvalidError()
```

**Changes**:
1. Method: `decode()` → `verify()`
2. Parameter: Add `algorithms=[JWT_ALGORITHM]` (list!)
3. Exceptions: Same names, different module

**Test**:
```bash
pytest tests/test_jwt_manager.py::test_verify_token -v
pytest tests/test_jwt_manager.py::test_expired_token -v
pytest tests/test_jwt_manager.py::test_invalid_token -v
```

**Expected**: ✅ All pass

[... Continue for all phases ...]

## Phase 6: Integration Testing

**Full Test Suite**:
```bash
# All JWT manager tests
pytest tests/test_jwt_manager.py -v

# All auth tests
pytest tests/test_auth.py -v

# Integration tests
pytest tests/integration/test_auth_flow.py -v

# End-to-end
pytest tests/e2e/test_login_flow.py -v
```

**Success Criteria**:
- [x] Phase 1 complete (jwt_manager.py) ✅
- [ ] Phase 2 complete (dependent files)
- [ ] Phase 3 complete (tests updated)
- [ ] All tests passing (62 tests)
- [ ] No deprecation warnings
- [ ] Auth flow works end-to-end

## Context Bundle Tracking

Session ID: `20251007_jwt_migration`
Bundle: `.agents/context-bundles/20251007_jwt_migration.md`

Progress logged automatically via PostToolUse hook.

## Rollback Plan

```bash
# Immediate rollback if critical issues
git revert HEAD
pip uninstall new_jwt
pip install old_jwt==1.8.0
pytest tests/test_auth.py  # Verify rollback
```
```

**Context Status** após Plan:
```
├─ Initial from Scout: 20.5K
├─ ai_docs.md cached: 8K
├─ detailed_plan.md: 18K
└─ Total: 46.5K tokens (23% of window)

Room remaining: 153.5K (77%)
Ready for Build: ✅
```

#### Fase 3: Build (Implementação Sistemática)

```bash
# /clear recommended here to free context
# But we have room, so continue

/build
```

**Build Execution**:

```
Main Agent (context: 46.5K):
├─ Read detailed_plan.md: Already in context
├─ Execute Phase 1:
│   ├─ Read jwt_manager.py (lines 15-180): 15K
│   ├─ Edit token creation (lines 45-75): 3K
│   ├─ Edit token verification (lines 90-120): 3K
│   ├─ Edit refresh tokens (lines 135-165): 3K
│   ├─ Run tests: `pytest tests/test_jwt_manager.py -v`
│   └─ Tests: ✅ All 15 tests passing
│
├─ Context approaching 70K (35%)
├─ Continue with Phase 2...
└─ Context approaching 120K (60%)

Decision point: Context at 60%
├─ Option 1: Continue (140K left)
├─ Option 2: /clear + load bundle
└─ Choice: Continue (enough room)

Complete Phase 2-6...

Final context: 140K tokens (70% of window)
```

**Context Bundle** (Auto-logged via hook):

```markdown
# Context Bundle: 20251007_jwt_migration

**Created**: 2025-10-07 14:30:00
**Session**: 20251007_jwt_migration
**Task**: Migrate authentication from old_jwt to new_jwt v2.0

---

## Initial Context

/prime-migration loaded at startup
Documentation: https://docs.new-jwt.com/migration

---

## Tool Call Log

[14:30:25] **Task**: Scout parallel search (4 agents)
[14:32:45] **Read**: `relevant_files.md` (Scout output)
[14:33:10] **WebFetch**: https://docs.new-jwt.com/migration
[14:33:25] **Write**: `ai_docs.md` (Documentation cache)
[14:34:00] **Write**: `detailed_plan.md` (Implementation plan)
[14:35:00] **Read**: `src/auth/jwt_manager.py` (lines 15-180)
[14:35:30] **Edit**: `src/auth/jwt_manager.py` (Token creation)
[14:36:00] **Bash**: `pytest tests/test_jwt_manager.py::test_create_access_token -v`
[14:36:15] **Edit**: `src/auth/jwt_manager.py` (Token verification)
[14:36:45] **Bash**: `pytest tests/test_jwt_manager.py::test_verify_token -v`
[... more tool calls ...]

---

## Key Findings

- Central JWT management in jwt_manager.py (lines 15-180)
- 8 dependent files need updates after core migration
- 42 tests cover JWT functionality (all passing)
- Configuration uses explicit algorithm (good for migration)

---

## Progress Tracking

### Phase 1: Core Migration ✅
- [x] jwt_manager.py updated
- [x] Tests passing (15/15)

### Phase 2: Dependent Files ✅
- [x] login.py updated
- [x] middleware.py updated
- [x] api_auth.py updated
- [x] Tests passing (27/27)

### Phase 3-6: [Continue tracking...]

---

## Context Status
**Tokens used**: 140K/200K (70%)
**Remaining**: 60K
**Status**: Healthy
```

### Resultado Final: Métricas Completas

#### Context Efficiency

```
Total Work Accomplished:
├─ Scout phase (4 sub-agents): 90K tokens processed
├─ Plan phase: 46K tokens used
├─ Build phase: 94K tokens used
└─ Total: 230K tokens of work

Main Agent Context Peak: 140K/200K (70%)

Techniques Used:
├─ Context Isolation (Scout): Saved 80K tokens
├─ JIT Loading (Prime): Saved 18K tokens
├─ File-based state transfer: No re-searching
├─ Documentation caching: Saved re-fetching
└─ Context bundle: Full audit trail

Efficiency:
├─ Work done: 230K tokens
├─ Peak context: 140K tokens
├─ Savings: 90K tokens (39% more efficient)
└─ Context bundles: Recovery ready if needed
```

#### Time Savings

```
Traditional Approach (estimated):
├─ Manual file search: 30 min
├─ Read and understand files: 45 min
├─ Plan migration: 30 min
├─ Implement changes: 2 hours
├─ Debug issues: 1 hour
└─ Total: ~4.5 hours

With Optimized System:
├─ Scout (parallel): 5 min
├─ Plan (with cache): 10 min
├─ Build (systematic): 1.5 hours
├─ Debug (minimal): 15 min
└─ Total: ~2 hours

Time saved: 2.5 hours (56% faster)
```

#### Quality Improvements

```
Traditional:
├─ Might miss files: 20% risk
├─ Inconsistent changes: 30% risk
├─ Incomplete testing: 40% risk
└─ Context lost if interrupted: 100%

Optimized:
├─ Complete file discovery: 100% (Scout found all)
├─ Consistent changes: 100% (Plan followed exactly)
├─ Complete testing: 100% (All tests in plan)
└─ Context preserved: 100% (Bundle recoverable)
```

---

Todos os templates acima estão disponíveis em `/templates/` para uso imediato.

**Anterior**: [09. MCP Servers ←](09-mcp-servers.md) | **Próximo**: [11. Best Practices →](11-best-practices.md)
