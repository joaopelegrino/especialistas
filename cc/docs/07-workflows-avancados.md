# 07. Workflows Avançados (Scout-Plan-Build)

> **Padrões avançados de workflow para maximizar eficiência, escalar compute e construir sistemas agentic profissionais**

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Scout-Plan-Build Pattern](#scout-plan-build-pattern) ⭐
3. [Composição de Prompts Agentic](#composição-de-prompts-agentic)
4. [Multi-Agent Orchestration](#multi-agent-orchestration)
5. [Out-of-Loop Agent Systems (ADWs)](#out-of-loop-agent-systems-adws)
6. [Implementações Práticas](#implementações-práticas)
7. [Troubleshooting](#troubleshooting)

---

## Visão Geral

### O Problema

Quando você usa Claude Code de forma tradicional (single agent, in-the-loop):

```
Problem: Large Codebase Migration
   ↓
❌ Single Agent approaches:
   • Search + analyze + plan + implement (all in one context)
   • Context window fills up quickly (50%+ consumed)
   • Agent loses focus with too many details
   • Hard to track progress
   • Difficult to parallelize
```

### A Solução: Workflows Estruturados

```
✅ Scout-Plan-Build approach:
   ↓
   SCOUT (4 sub-agents parallel)
   • Fast, cheap agents search codebase
   • Return: relevant_files.md (condensed)
   • Context: Isolated, disposable
   ↓
   PLAN (main agent)
   • Clean context window
   • Read: relevant_files.md + docs
   • Output: detailed_plan.md
   • Context: Focused on planning only
   ↓
   BUILD (main agent)
   • Read: detailed_plan.md
   • Implement systematically
   • Test and validate
   • Context: Focused on implementation
```

**Benefícios**:
- ✅ Context window stays clean
- ✅ Parallel execution (10x faster scouting)
- ✅ Better reasoning (focused agents)
- ✅ Reusable pattern
- ✅ Scales to massive codebases

---

## Scout-Plan-Build Pattern

> "This three-step workflow has been really, really powerful" - Indie Devdan

### Conceito Central

**Separar responsabilidades em 3 fases distintas**:

1. **SCOUT**: Buscar informação (delegado)
2. **PLAN**: Planejar solução (contexto limpo)
3. **BUILD**: Implementar (sistemático)

### Por que funciona?

#### Problema sem Scout

```markdown
# Traditional approach

Planner Agent (single context):
  1. Search for relevant files    ← Fills context with search results
  2. Read files one by one        ← Context growing...
  3. Try to remember everything   ← Context polluted
  4. Create plan                  ← Lost in details
  5. Implement                    ← Context almost full
```

**Resultado**: 50%+ context consumed, agent overwhelmed

#### Solução com Scout

```markdown
# Scout-Plan-Build approach

Scout Phase (4 parallel sub-agents):
  Sub-agent 1 (Gemini):  Search for authentication code
  Sub-agent 2 (CodeQwen): Search for database queries
  Sub-agent 3 (Haiku):    Search for API endpoints
  Sub-agent 4 (Gemini):   Search for config files
  ↓
  Consolidate: relevant_files.md (condensed, with offsets)

Plan Phase (main agent, clean context):
  Read: relevant_files.md (summary only!)
  Read: documentation
  Think: Strategy
  Write: detailed_plan.md

Build Phase (main agent):
  Read: detailed_plan.md
  Implement step-by-step
  Test and validate
```

**Resultado**: Context efficient, better reasoning, parallel execution

### Anatomia do Scout

#### O que é o Scout?

> "If you take a look at our agent execution right now, you see something really interesting. The first thing that's happening is we're running /scout."

**Scout é um sub-prompt que**:
- Delega busca para múltiplos sub-agentes
- Usa modelos rápidos e baratos (Haiku, Gemini, CodeQwen)
- Roda em paralelo (até 10 agents)
- Retorna resultados condensados
- **Libera o context window do planner**

#### Por que usar Scout?

```
❓ "Why do we have this additional scout step?"

💡 Answer: Offload context from planning
```

**Sem Scout**:
```
Planner context:
├─ System prompt (5K)
├─ Search results (30K) ← Pollutes context!
├─ File previews (20K)  ← Takes space!
├─ Analysis (10K)
├─ Planning (15K)
└─ Total: 80K tokens used
```

**Com Scout**:
```
Scout sub-agents context (isolated):
├─ 4 agents × 20K each = 80K total
└─ Return: relevant_files.md (~5K condensed)

Planner context (clean):
├─ System prompt (5K)
├─ relevant_files.md (5K) ← Condensed!
├─ Documentation (8K)
├─ Planning (15K)
└─ Total: 33K tokens used ✅
```

#### Scout Implementation

**Exemplo de Scout command** (`.claude/commands/scout.md`):

```markdown
---
description: Search the codebase for files needed to complete the task using fast token efficient agents
---

# Scout Workflow

## Purpose
Search codebase efficiently using parallel sub-agents.

## Instructions

1. **Understand the task**
   - Parse user requirements
   - Identify key search terms
   - Determine scope

2. **Launch 4 parallel sub-agents**

   Use Task tool to create search agents:

   ```
   Agent 1 (Gemini Flash): Search for [key term 1]
   Agent 2 (Claude Haiku): Search for [key term 2]
   Agent 3 (CodeQwen): Search for [key term 3]
   Agent 4 (Gemini Flash): Search for [key term 4]
   ```

   Each agent should:
   - Use Grep/Glob to find relevant files
   - Read key sections (use offset/limit for large files)
   - Note file locations and line ranges
   - Return condensed summary

3. **Consolidate Results**

   Create `relevant_files.md`:

   ```markdown
   # Relevant Files for [Task]

   ## File: src/auth/login.py
   - Lines: 45-120
   - Contains: User authentication logic
   - Offset: 45, Length: 75 lines
   - Key finding: Uses JWT tokens

   ## File: src/database/models.py
   - Lines: 200-250
   - Contains: User model definition
   - Offset: 200, Length: 50 lines
   - Key finding: Password hashing with bcrypt

   [... more files ...]
   ```

4. **Report**

   Save relevant_files.md and inform main agent:
   "Scout complete. Found N relevant files. See relevant_files.md"
```

#### Scout Tips

✅ **Use diverse models**
- Gemini: Fast, good at pattern matching
- Haiku: Cheap, efficient for simple search
- CodeQwen: Specialized for code understanding
- Mix perspectives = better coverage

✅ **Be specific in search terms**
```python
# ❌ Vague
"Search for authentication"

# ✅ Specific
"Search for JWT token generation, password hashing, and login endpoints"
```

✅ **Use offset/limit for large files**
```python
# Don't read entire 2000-line file
# Read specific sections:
Read(file_path="large_file.py", offset=450, limit=100)
```

✅ **Consolidate, don't duplicate**
```markdown
# ❌ Bad consolidation (too verbose)
Copying entire file contents from each agent...

# ✅ Good consolidation (condensed)
File path + line ranges + key findings only
```

---

### Anatomia do Plan

#### O que é o Planner?

O planner é o **segundo estágio** que recebe context limpo e foca apenas em **criar um plano detalhado**.

#### Plan Implementation

**Exemplo de Plan command** (`.claude/commands/plan-with-docs.md`):

```markdown
---
description: Create detailed plan for the task based on scout results and documentation
---

# Plan Workflow

## Input Variables
- $ARGUMENTS: User task description
- $DOCUMENTATION_URLS: URLs to relevant docs
- relevant_files.md: Output from scout phase

## Instructions

1. **Analyze Scope**
   - Read relevant_files.md
   - Understand current implementation
   - Identify what needs to change

2. **Scrape Documentation**
   - Use WebFetch for each documentation URL
   - Save to local cache (ai_docs.md)
   - Extract key patterns and examples

3. **Design Solution**
   - Break down into phases
   - Identify dependencies
   - Plan file changes
   - Consider edge cases
   - Plan testing strategy

4. **Document Plan**

   Create `detailed_plan.md`:

   ```markdown
   # Implementation Plan: [Task Name]

   ## Summary
   [1-2 sentence overview]

   ## Scope Analysis
   - Affected files: [N files]
   - Complexity: [Low/Medium/High]
   - Estimated changes: [N lines]

   ## Phases

   ### Phase 1: [Name]
   **Files to modify**:
   - src/auth/login.py (lines 45-60)
   - src/database/models.py (lines 200-205)

   **Changes**:
   1. Update JWT token generation to use new SDK
   2. Modify User model to include new fields

   **Testing**:
   - Run auth tests: pytest tests/test_auth.py

   ### Phase 2: [Name]
   ...

   ## Dependencies
   - New SDK installation required
   - Database migration needed

   ## Risks & Mitigation
   - Risk: Breaking existing auth
   - Mitigation: Backwards compatibility layer

   ## Success Criteria
   - [ ] All tests pass
   - [ ] No regressions in auth flow
   - [ ] New functionality works
   ```

5. **Report**
   Save detailed_plan.md and exit plan mode
```

#### Planner Tips

✅ **Keep context focused**
```markdown
# Read only summaries from scout
Read("relevant_files.md")  ← Small summary

# NOT full files during planning
# ❌ Read("src/huge_file.py")  ← 2000 lines!
```

✅ **Scrape docs locally**
```markdown
# Cache documentation for later phases
WebFetch(url) → Save to ai_docs.md

# Agents in future phases can read ai_docs.md
# No need to fetch again
```

✅ **Be systematic**
```markdown
Plan structure:
1. Understand (what exists)
2. Design (what to change)
3. Document (how to change)
4. Test (how to validate)
```

---

### Anatomia do Build

#### O que é o Builder?

O builder é o **terceiro estágio** que **implementa o plano** de forma sistemática.

#### Build Implementation

**Exemplo de Build command** (`.claude/commands/build.md`):

```markdown
---
description: Implement the detailed plan systematically
allowed-tools: Read, Write, Edit, Bash
---

# Build Workflow

## Input
- detailed_plan.md: Output from plan phase
- relevant_files.md: Reference for file locations
- ai_docs.md: Cached documentation

## Instructions

1. **Load Plan**
   - Read detailed_plan.md
   - Understand all phases
   - Check dependencies

2. **Implement Phase by Phase**

   For each phase in plan:

   a. **Read affected files**
      - Use Read tool with specific line ranges
      - Cross-reference with relevant_files.md

   b. **Make changes**
      - Use Edit for modifications (not Write!)
      - Follow plan exactly
      - Add comments where needed

   c. **Test phase**
      - Run tests specified in plan
      - Check for errors
      - Fix issues if needed

   d. **Report progress**
      - Mark phase complete
      - Note any deviations from plan

3. **Final Validation**
   - Run full test suite
   - Check for regressions
   - Verify success criteria from plan

4. **Report**
   - Summarize work done
   - List all files modified
   - Report test results
```

#### Builder Tips

✅ **Follow the plan**
```python
# Plan said: "Modify lines 45-60 in login.py"
# ✅ Do exactly that
Edit("login.py", old_string=..., new_string=...)

# ❌ Don't improvise and change other parts
```

✅ **Use Edit, not Write**
```python
# ✅ Surgical changes
Edit(file_path, old_string, new_string)

# ❌ Rewriting entire files
Write(file_path, entire_file_content)  # Risky!
```

✅ **Test each phase**
```bash
# After each phase, validate
pytest tests/test_auth.py
# ✅ Tests pass → continue
# ❌ Tests fail → fix before next phase
```

---

## Armazenamento Entre Fases no Scout-Plan-Build

> "State doesn't pass through context window - it passes through persisted files"

### Como Informação Flui Entre Fases

O Scout-Plan-Build **não transfere state via context window** - usa arquivos persistidos no filesystem:

```
┌──────────────────────────────────────────────────────────────┐
│                    FASE 1: SCOUT                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Sub-agents (contexts isolados):                            │
│  ├─ Agent 1: 30K tokens processados                         │
│  ├─ Agent 2: 25K tokens processados                         │
│  ├─ Agent 3: 35K tokens processados                         │
│  └─ Agent 4: 20K tokens processados                         │
│                                                              │
│  Total processado: 110K tokens                              │
│  Contexts descartados após completion ✅                     │
│                                                              │
│  Output: relevant_files.md                                  │
│  ├─ Tamanho: 8K tokens                                      │
│  ├─ Formato: Estruturado com offsets                        │
│  └─ Persistido: Filesystem                                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
                         ↓ (File transfer)
┌──────────────────────────────────────────────────────────────┐
│                    FASE 2: PLAN                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Main Agent (context limpo!):                               │
│  ├─ System prompt: 5K                                       │
│  ├─ Read("relevant_files.md"): 8K ← From Scout             │
│  ├─ WebFetch docs + cache: 10K                             │
│  ├─ Planning: 12K                                           │
│  └─ Total: 35K tokens                                       │
│                                                              │
│  Output: detailed_plan.md                                   │
│  ├─ Tamanho: 15K tokens                                     │
│  ├─ Formato: Phases com file paths e line ranges           │
│  └─ Persistido: Filesystem                                  │
│                                                              │
│  Output: ai_docs.md (optional)                              │
│  └─ Documentation cache para reutilização                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
                         ↓ (File transfer)
┌──────────────────────────────────────────────────────────────┐
│                    FASE 3: BUILD                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Main Agent (context limpo novamente!):                     │
│  ├─ System prompt: 5K                                       │
│  ├─ Read("detailed_plan.md"): 15K ← From Plan              │
│  ├─ Read files (via offsets): 20K                          │
│  ├─ Edits + tests: 25K                                      │
│  └─ Total: 65K tokens                                       │
│                                                              │
│  Output: implementation_summary.md                          │
│  └─ Modified files + test results                           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Key Benefits**:
- ✅ Cada fase começa com context **limpo**
- ✅ Total work: 210K tokens processados
- ✅ Max context em qualquer agent: 80K (Scout sub-agents)
- ✅ Main agent nunca ultrapassa 65K

### Formato dos Arquivos de State

#### 1. relevant_files.md (Scout → Plan)

```markdown
# Relevant Files for Authentication Migration

## Summary
Found 8 files related to authentication across 3 modules.
Total lines to review: ~450 lines.

## Core Authentication

### src/auth/login.py
- **Lines**: 45-120 (75 lines)
- **Offset**: 45, **Length**: 75
- **Purpose**: Main authentication logic
- **Key Patterns**:
  - JWT token generation: `old_jwt.encode(payload, SECRET)`
  - Session management: Lines 80-95
  - Password validation: Lines 100-115
- **Dependencies**: `old_jwt`, `bcrypt`
- **Tests**: tests/test_auth.py::test_login

### src/auth/tokens.py
- **Lines**: 20-85 (65 lines)
- **Offset**: 20, **Length**: 65
- **Purpose**: Token utilities
- **Key Patterns**:
  - Token refresh: Lines 45-60
  - Token validation: Lines 65-80
- **Dependencies**: `old_jwt`

## Database Models

### src/models/user.py
- **Lines**: 150-220 (70 lines)
- **Offset**: 150, **Length**: 70
- **Purpose**: User model definition
- **Key Patterns**:
  - Password hashing: Lines 180-190
  - Authentication methods: Lines 200-215
- **Dependencies**: `sqlalchemy`, `bcrypt`
- **Tests**: tests/test_models.py::test_user

## API Endpoints

### src/api/auth_routes.py
- **Lines**: 30-120 (90 lines)
- **Offset**: 30, **Length**: 90
- **Purpose**: Authentication endpoints
- **Routes**:
  - POST /login (Lines 40-65)
  - POST /logout (Lines 70-85)
  - POST /refresh (Lines 90-110)
- **Dependencies**: `fastapi`, `old_jwt`

## Configuration

### config/auth_config.py
- **Lines**: 10-45 (35 lines)
- **Offset**: 10, **Length**: 35
- **Purpose**: Auth configuration
- **Key Settings**:
  - SECRET_KEY
  - TOKEN_EXPIRY
  - ALGORITHM (currently: HS256)

## Next Steps for Planner
1. Read documentation for new JWT library
2. Plan migration strategy (backwards compatible?)
3. Identify test coverage gaps
4. Design rollback strategy
```

**Structure Benefits**:
- Offset/Length permitem reads precisos
- Key Patterns identificam o que importa
- Dependencies revelam impacto
- Tests provêem validation path
- Next Steps guiam o planner

#### 2. detailed_plan.md (Plan → Build)

```markdown
# Implementation Plan: Migrate to New JWT Library

## Executive Summary
Migrate from `old_jwt` to `new_jwt` v2.0 across authentication system.
- **Complexity**: Medium
- **Files**: 8 files to modify
- **Estimated changes**: ~150 lines
- **Risk**: Medium (authentication system)
- **Mitigation**: Backwards compatibility layer + extensive testing

## Pre-Implementation

### Dependencies
```bash
pip uninstall old_jwt
pip install new_jwt==2.0.1
```

### Documentation Cache
Saved to: `ai_docs.md`
Key migration patterns documented.

## Phase 1: Update Token Generation

### File: src/auth/login.py

**Lines to modify**: 45-60

**Current code**:
```python
import old_jwt

def create_token(user_id: int) -> str:
    payload = {"user_id": user_id, "exp": datetime.now() + timedelta(hours=1)}
    token = old_jwt.encode(payload, SECRET_KEY)
    return token
```

**New code**:
```python
import new_jwt

def create_token(user_id: int) -> str:
    payload = {"user_id": user_id, "exp": datetime.now() + timedelta(hours=1)}
    token = new_jwt.create(payload, SECRET_KEY, algorithm="HS256")
    return token
```

**Changes**:
1. Import: `old_jwt` → `new_jwt`
2. Method: `encode()` → `create()`
3. Parameter: Add explicit `algorithm="HS256"`

**Test command**:
```bash
pytest tests/test_auth.py::test_create_token -v
```

**Expected result**: ✅ All tests pass

**If tests fail**:
1. Check SECRET_KEY format
2. Verify algorithm parameter
3. Validate payload structure

### File: src/auth/tokens.py

**Lines to modify**: 30-45, 65-80

[Similar detailed breakdown...]

## Phase 2: Update Token Validation

### File: src/auth/login.py

**Lines to modify**: 100-115

**Current code**:
```python
def validate_token(token: str) -> dict:
    try:
        payload = old_jwt.decode(token, SECRET_KEY)
        return payload
    except old_jwt.InvalidTokenError:
        raise AuthenticationError("Invalid token")
```

**New code**:
```python
def validate_token(token: str) -> dict:
    try:
        payload = new_jwt.verify(token, SECRET_KEY, algorithms=["HS256"])
        return payload
    except new_jwt.InvalidTokenError:
        raise AuthenticationError("Invalid token")
```

**Changes**:
1. Method: `decode()` → `verify()`
2. Parameter: Add `algorithms=["HS256"]`
3. Exception: `old_jwt.InvalidTokenError` → `new_jwt.InvalidTokenError`

**Test command**:
```bash
pytest tests/test_auth.py::test_validate_token -v
```

[Continue for all phases...]

## Phase 6: Integration Testing

**Commands**:
```bash
# Run full auth test suite
pytest tests/test_auth.py -v

# Run integration tests
pytest tests/integration/test_auth_flow.py -v

# Run API tests
pytest tests/api/test_auth_endpoints.py -v
```

**Success Criteria**:
- [ ] All unit tests pass (42 tests)
- [ ] All integration tests pass (12 tests)
- [ ] All API tests pass (8 tests)
- [ ] No deprecation warnings
- [ ] Auth flow works end-to-end

## Rollback Plan

If critical issues found:

1. **Immediate rollback**:
```bash
git revert HEAD
pip uninstall new_jwt
pip install old_jwt==1.8.0
```

2. **Backwards compatibility** (if partial migration):
```python
# Keep both libraries temporarily
try:
    import new_jwt as jwt
except ImportError:
    import old_jwt as jwt
```

## Post-Implementation

1. Monitor error logs for 24h
2. Check performance metrics
3. Update documentation
4. Remove old_jwt dependency after 1 week
5. Update CI/CD pipeline

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Token validation fails | Medium | High | Extensive testing + rollback plan |
| Performance regression | Low | Medium | Benchmark before/after |
| Breaking API contracts | Low | High | API versioning maintained |
```

**Structure Benefits**:
- Builder tem **exact** code changes (before/after)
- Test commands para cada phase
- Success criteria claros
- Rollback plan pronto
- Risk assessment explícito

#### 3. ai_docs.md (Documentation Cache)

```markdown
# Cached Documentation: new_jwt v2.0 Migration

**Source**: https://docs.new-jwt.com/migration-guide
**Fetched**: 2025-10-07 14:30:00
**Cached for**: All subsequent phases

---

## Breaking Changes from v1.x

### 1. Method Renames

| Old (v1.x) | New (v2.0) | Notes |
|------------|------------|-------|
| `jwt.encode()` | `jwt.create()` | Parameters unchanged |
| `jwt.decode()` | `jwt.verify()` | Now requires `algorithms` param |
| `jwt.InvalidTokenError` | Same | Exception name unchanged |

### 2. Required Parameters

**Algorithm parameter now required**:

```python
# ❌ Old (implicit algorithm)
token = old_jwt.decode(token, SECRET_KEY)

# ✅ New (explicit algorithm)
token = new_jwt.verify(token, SECRET_KEY, algorithms=["HS256"])
```

**Reason**: Security - prevent algorithm confusion attacks.

### 3. Signature Changes

**create() method**:
```python
def create(
    payload: dict,
    key: str,
    algorithm: str = "HS256",  # Now has default
    headers: dict = None
) -> str:
```

**verify() method**:
```python
def verify(
    token: str,
    key: str,
    algorithms: List[str],  # Required, no default!
    options: dict = None
) -> dict:
```

## Migration Patterns

### Pattern 1: Basic Token Creation

```python
# Before
import old_jwt
token = old_jwt.encode({"user_id": 123}, SECRET_KEY)

# After
import new_jwt
token = new_jwt.create({"user_id": 123}, SECRET_KEY, algorithm="HS256")
```

### Pattern 2: Token Validation

```python
# Before
try:
    payload = old_jwt.decode(token, SECRET_KEY)
except old_jwt.InvalidTokenError:
    # Handle invalid token

# After
try:
    payload = new_jwt.verify(token, SECRET_KEY, algorithms=["HS256"])
except new_jwt.InvalidTokenError:
    # Handle invalid token (same exception!)
```

### Pattern 3: Custom Headers

```python
# Before
token = old_jwt.encode(payload, SECRET_KEY, headers={"kid": "key-1"})

# After
token = new_jwt.create(payload, SECRET_KEY, algorithm="HS256", headers={"kid": "key-1"})
```

## Testing Recommendations

1. **Unit tests**: Test each JWT operation individually
2. **Integration tests**: Test full auth flow
3. **Compatibility tests**: Ensure old tokens still validate
4. **Performance tests**: Benchmark token operations

## Common Pitfalls

### ❌ Pitfall 1: Forgetting algorithms parameter
```python
# This will raise TypeError
payload = new_jwt.verify(token, SECRET_KEY)  # Missing algorithms!
```

### ❌ Pitfall 2: Using old exception names
```python
# This will cause ImportError
except old_jwt.InvalidTokenError:  # Wrong module!
```

### ✅ Solution: Update all references
```python
import new_jwt

try:
    payload = new_jwt.verify(token, SECRET_KEY, algorithms=["HS256"])
except new_jwt.InvalidTokenError:
    # Correct exception
```

---

**Cache expires**: 2025-10-08 14:30:00
**Re-fetch if**: Documentation updates or version changes
```

**Cache Benefits**:
- Builder não precisa re-fetch docs
- Patterns prontos para copy/paste
- Common pitfalls antecipados
- Consistent reference para toda team

### Métricas: Context Efficiency

#### Tradicional (Sem Armazenamento Estruturado)

```
Single Agent Context:
├─ Scout work: 30K (inline no context)
├─ Plan work: 25K (inline no context)
├─ Build work: 40K (inline no context)
├─ Documentation: 20K (inline no context)
└─ Total: 115K tokens em UM context

Risk: Context overflow (57% usado)
Performance: Degradada (agent overwhelmed)
```

#### Scout-Plan-Build (Com Armazenamento Estruturado)

```
Scout Phase:
├─ Sub-agents: 110K tokens processados
├─ Output: relevant_files.md (8K)
└─ Context usado: 0K no main agent! ✅

Plan Phase:
├─ Input: relevant_files.md (8K)
├─ Process: 25K tokens
├─ Output: detailed_plan.md (15K)
└─ Context usado: 33K

Build Phase:
├─ Input: detailed_plan.md (15K)
├─ Process: 40K tokens
├─ Output: summary (5K)
└─ Context usado: 55K

Total Work: 175K tokens processados
Max Context: 55K (em qualquer agent)
Efficiency: 68% reduction in peak context!
```

### Best Practices: File-Based State Transfer

#### ✅ DO

**1. Use structured formats with metadata**
```markdown
## File: path.py
- Lines: X-Y
- Offset: X, Length: Y-X
- Purpose: [what it does]
- Key patterns: [what to look for]
- Tests: [how to validate]
```

**2. Include actionable information**
```markdown
# ❌ Vague
Found JWT code in auth.py

# ✅ Actionable
src/auth.py lines 45-60: JWT token generation
Uses old_jwt.encode() - needs migration to new_jwt.create()
Test with: pytest tests/test_auth.py::test_jwt
```

**3. Cache documentation locally**
```bash
# Fetch once, use multiple times
WebFetch(docs_url) → Save to ai_docs.md
# Plan phase reads it
# Build phase reads it
# Review phase reads it
```

#### ❌ DON'T

**1. Pass large content through context**
```python
# ❌ Don't include full file content
main_agent.context += read_entire_file("large.py")  # 50K tokens!

# ✅ Write to file, pass reference
write_file("scout_output.md", summary)
main_agent.read("scout_output.md")  # 5K tokens
```

**2. Re-fetch information already collected**
```python
# ❌ Scout found it, don't search again
plan_phase: Grep("JWT token")  # Already in relevant_files.md!

# ✅ Read from Scout output
plan_phase: Read("relevant_files.md")
```

---

## Composição de Prompts Agentic

> "You can run custom slash commands inside of custom slash commands. You can compose your agentic prompts. This is huge." - Indie Devdan

### O que é Composição?

**Claude Code 2.0** permite chamar slash commands **dentro** de outros slash commands:

```markdown
# File: .claude/commands/scout-plan-build.md

---
description: Complete workflow from search to implementation
---

# Scout Plan Build Workflow

## Step 1: Scout
/scout $ARGUMENTS

## Step 2: Plan
/plan-with-docs $ARGUMENTS --docs $DOCUMENTATION_URLS

## Step 3: Build
/build
```

### Por que isso é Revolucionário?

#### Antes (Sem Composição)

```
You: "Migrate to new SDK"
Claude: [Tries to do everything in one go]
  • Searches files
  • Reads documentation
  • Creates plan
  • Implements changes
  • Tests

Result:
❌ Context window explodes (70%+ used)
❌ Lost focus halfway through
❌ Difficult to debug
❌ Not reusable
```

#### Depois (Com Composição)

```
You: "/scout-plan-build migrate to new SDK --docs https://..."

Claude:
  Phase 1: Execute /scout
    → Spawns 4 sub-agents
    → Searches in parallel
    → Returns relevant_files.md

  Phase 2: Execute /plan-with-docs
    → Clean context
    → Reads scout output
    → Fetches docs
    → Creates detailed_plan.md

  Phase 3: Execute /build
    → Reads plan
    → Implements systematically
    → Tests each phase

Result:
✅ Context stays manageable
✅ Each phase focused
✅ Easy to debug (inspect phase outputs)
✅ 100% reusable for future tasks
```

### Exemplos de Composição

#### Exemplo 1: Review-Fix-Test

```markdown
# .claude/commands/review-fix-test.md

---
description: Review code, fix issues, and run tests
---

# Review Fix Test Workflow

## Step 1: Review
/code-review $ARGUMENTS

## Step 2: Fix Issues
Read the review output and fix all HIGH and MEDIUM issues

## Step 3: Test
/run-tests

## Step 4: Commit
If tests pass, create commit with review summary
```

#### Exemplo 2: Feature-From-Issue

```markdown
# .claude/commands/feature-from-issue.md

---
description: Implement feature from issue tracker
---

# Feature From Issue Workflow

## Step 1: Fetch Issue
Use mcp__github__get_issue to fetch issue details

## Step 2: Scout
/scout implement feature: $ISSUE_DESCRIPTION

## Step 3: Design
/plan-feature $ISSUE_DESCRIPTION

## Step 4: Implement
/build

## Step 5: Create PR
/create-pr "Implements #$ISSUE_NUMBER"
```

### Composição com Sub-agents

Você pode compor **sub-agents** dentro de commands:

```markdown
# .claude/commands/multi-perspective-review.md

---
description: Get code review from multiple specialized agents
---

# Multi-Perspective Review

## Launch 3 Reviewers in Parallel

### Use Task tool:

1. **Security Reviewer** (security-agent)
   - Focus: vulnerabilities, auth, data exposure

2. **Performance Reviewer** (performance-agent)
   - Focus: bottlenecks, inefficiencies, scaling

3. **Style Reviewer** (style-agent)
   - Focus: readability, conventions, maintainability

## Consolidate Reviews

Merge findings from all 3 reviewers into final_review.md

Priority:
1. CRITICAL (security issues)
2. HIGH (performance bugs)
3. MEDIUM (style/readability)
4. LOW (nitpicks)
```

---

## Multi-Agent Orchestration

### Conceito

**Orquestrar múltiplos agentes** trabalhando em paralelo ou sequencialmente para resolver tasks complexas.

### Padrão: Parallel Agents

```
Main Agent
   │
   ├─ spawn ─→ Agent 1 (Task A) ─┐
   ├─ spawn ─→ Agent 2 (Task B) ─┤
   ├─ spawn ─→ Agent 3 (Task C) ─┤──→ Consolidate Results
   └─ spawn ─→ Agent 4 (Task D) ─┘
```

**Quando usar**:
- Tasks independentes
- Exploração em paralelo
- Múltiplas perspectivas
- Speed is critical

### Padrão: Sequential Agents

```
Main Agent
   │
   └─→ Agent 1 (Research)
         │
         └─→ Agent 2 (Design)
               │
               └─→ Agent 3 (Implement)
                     │
                     └─→ Agent 4 (Test)
```

**Quando usar**:
- Tasks dependentes
- Each phase needs previous output
- Systematic progression

### Padrão: Hierarchical Agents

```
Main Agent (Orchestrator)
   │
   ├─→ Manager Agent 1
   │     ├─→ Worker 1a
   │     └─→ Worker 1b
   │
   └─→ Manager Agent 2
         ├─→ Worker 2a
         ├─→ Worker 2b
         └─→ Worker 2c
```

**Quando usar**:
- Very large tasks
- Multiple work streams
- Complex coordination needed

### Exemplo: Microservices Migration

```markdown
# Task: Migrate monolith to microservices

## Main Agent (Orchestrator)

### Phase 1: Analysis (Parallel)
- Agent 1: Analyze API endpoints
- Agent 2: Analyze database schema
- Agent 3: Analyze business logic
- Agent 4: Analyze dependencies

### Phase 2: Design (Sequential)
- Agent 5: Design service boundaries (uses Phase 1 results)
- Agent 6: Design data migration (uses Agent 5 output)
- Agent 7: Design API contracts (uses Agent 5 output)

### Phase 3: Implementation (Parallel)
- Agent 8: Implement Auth Service
- Agent 9: Implement User Service
- Agent 10: Implement Order Service
- Agent 11: Implement Payment Service

### Phase 4: Integration (Sequential)
- Agent 12: Set up API Gateway
- Agent 13: Implement service mesh
- Agent 14: Run integration tests

### Phase 5: Validation
- Agent 15: Performance testing
- Agent 16: Security audit
- Agent 17: Documentation
```

---

## Out-of-Loop Agent Systems (ADWs)

> "This is my take on how to build with agents to scale beyond AI coding and vibe coding with advanced engineering so powerful your codebase runs itself." - Indie Devdan

### O que são ADWs?

**ADW = Dedicated AI Developer Workflow**

Sistema de agentes que trabalha **autonomamente** em background enquanto você está AFK (Away From Keyboard).

### Arquitetura de um ADW

```
┌──────────────────────────────────────────┐
│         Dedicated Agent Device           │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │      Job Queue System              │ │
│  │  • Receives jobs via API/CLI       │ │
│  │  • Spawns agent pipeline           │ │
│  │  • Monitors progress               │ │
│  │  • Reports status                  │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │      Agent Pipeline                │ │
│  │                                    │ │
│  │  [Scout] → [Plan] → [Build] → [Ship]│
│  │                                    │ │
│  │  • Each stage runs autonomously    │ │
│  │  • Outputs logged to database      │ │
│  │  • Git operations automated        │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │      Status Monitor                │ │
│  │  • Check every 60s                 │ │
│  │  • Report which agent is running   │ │
│  │  • Alert on completion/failure     │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

### Exemplo: AFK Agent Workflow

**On your main machine**:

```bash
# Kick off job to dedicated agent device
/afk-agent "Build 3 OpenAI real-time agent examples" \
  --adw plan-build-ship \
  --docs https://platform.openai.com/docs/guides/realtime
```

**On dedicated agent device** (runs automatically):

```markdown
## Job Started: 2025-10-06 14:30:00

### Agent Pipeline: plan-build-ship

#### Phase 1: Planner Agent [Running]
- Reading documentation
- Designing 3 agent examples
- Creating implementation plan

⏳ Status check (60s): Planner still analyzing...
⏳ Status check (120s): Planner creating plan...
✅ Status check (180s): Plan completed!

#### Phase 2: Builder Agent [Running]
- Implementing example 1: basic-realtime-agent.py
- Implementing example 2: function-calling-agent.py
- Implementing example 3: voice-assistant-agent.py
- Testing each implementation

⏳ Status check (240s): Builder on example 2...
⏳ Status check (300s): Builder on example 3...
✅ Status check (360s): Build completed!

#### Phase 3: Shipper Agent [Running]
- Running full test suite
- Creating git commit
- Pushing to remote
- Generating summary report

✅ Status check (420s): Ship completed!

## Job Completed: 2025-10-06 14:37:00
📊 Total duration: 7 minutes
📁 Repository: https://github.com/user/realtime-agents
✅ All tests passed
```

**On your main machine** (you were AFK drinking coffee):

```bash
# Check status
/afk-agent status

> Job "Build 3 OpenAI real-time agent examples" completed!
> Repository: https://github.com/user/realtime-agents
> Commit: abc123f - "feat: Add 3 OpenAI realtime agent examples"
> Tests: ✅ All passed
> Duration: 7 minutes
```

### Componentes de um ADW

#### 1. Job Submission Interface

```python
# CLI submission
claude afk-agent \
  --prompt "Migrate to Claude Agent SDK" \
  --workflow plan-build-ship \
  --docs https://docs.claude.com

# Or Python SDK
from adw import submit_job

submit_job(
    prompt="Migrate to Claude Agent SDK",
    workflow="plan-build-ship",
    documentation=["https://docs.claude.com"],
    notify_on_complete=True
)
```

#### 2. Agent Pipeline Definition

```yaml
# .claude/workflows/plan-build-ship.yaml

name: plan-build-ship
description: Complete workflow from planning to shipping

agents:
  - name: planner
    type: sonnet
    tools: [Read, Grep, Glob, WebFetch]
    system_prompt: |
      You are a strategic planner...

  - name: builder
    type: sonnet
    tools: [Read, Write, Edit, Bash]
    system_prompt: |
      You are a systematic builder...

  - name: shipper
    type: haiku
    tools: [Bash(git:*), Bash(npm:test)]
    system_prompt: |
      You are a careful shipper...

workflow:
  - step: plan
    agent: planner
    input: $USER_PROMPT + $DOCUMENTATION
    output: detailed_plan.md

  - step: build
    agent: builder
    input: detailed_plan.md
    output: implementation_summary.md

  - step: ship
    agent: shipper
    input: implementation_summary.md
    output: deployment_report.md
```

#### 3. Status Monitoring

```python
# Status checker (runs every 60s)

import time
from adw import get_job_status

job_id = "job_123"

while True:
    status = get_job_status(job_id)

    print(f"[{timestamp}] Current agent: {status.current_agent}")
    print(f"Phase: {status.current_phase}")
    print(f"Progress: {status.progress}%")

    if status.completed:
        print("✅ Job completed!")
        break

    time.sleep(60)  # Check every 60 seconds
```

#### 4. Result Notification

```python
# When job completes, notify via:

# Slack
send_slack_message(
    channel="#engineering",
    message=f"✅ ADW job completed: {job.title}\nRepo: {job.repo_url}"
)

# Email
send_email(
    to="engineer@company.com",
    subject=f"ADW Job Complete: {job.title}",
    body=job.summary_report
)

# Desktop notification
notify_desktop(
    title="ADW Complete",
    message=job.title
)
```

### ADW Best Practices

#### ✅ DO

**1. Well-defined tasks**
```markdown
✅ Good ADW tasks:
- "Migrate codebase from SDK v1 to v2"
- "Implement 3 proof-of-concept agents"
- "Refactor utils.js to use modern ES6+"
- "Generate API documentation from code"

❌ Bad ADW tasks:
- "Make the app better" (too vague)
- "Fix all bugs" (undefined scope)
- "Implement new features" (which features?)
```

**2. Provide documentation**
```python
# ✅ Include docs for ADW to reference
submit_job(
    prompt="Migrate to new SDK",
    docs=[
        "https://docs.new-sdk.com/migration-guide",
        "./ARCHITECTURE.md",
        "./CONVENTIONS.md"
    ]
)
```

**3. Validation steps**
```yaml
workflow:
  - step: build
    agent: builder
    validation:
      - command: "pytest tests/"
        must_pass: true
      - command: "npm run lint"
        must_pass: true
```

**4. Closed-loop feedback**
```markdown
# Build validation command into workflow

/scout-plan-build "Implement feature X"
  ↓
  [Build phase]
  ↓
  [Test phase] ← Auto-validates
     ✅ Tests pass → Continue
     ❌ Tests fail → Fix & retry
```

#### ❌ DON'T

**1. Undefined tasks**
```python
# ❌ Too open-ended for ADW
submit_job("Build something cool")
```

**2. Tasks requiring UI interaction**
```python
# ❌ ADW can't interact with browser
submit_job("Test the checkout flow in the web app")

# ✅ Use API/CLI testing instead
submit_job("Test checkout API endpoints")
```

**3. Tasks requiring human judgment**
```python
# ❌ Requires subjective decisions
submit_job("Design the new homepage")

# ✅ Provide constraints
submit_job("""
Implement homepage following design spec in design/homepage.figma
Match existing component library
""")
```

---

## Implementações Práticas

### Implementação Completa: Scout-Plan-Build

Estrutura de arquivos:

```
.claude/
├── commands/
│   ├── scout.md                    # Scout command
│   ├── plan-with-docs.md           # Plan command
│   ├── build.md                    # Build command
│   └── scout-plan-build.md         # Composed workflow
│
└── agents/
    ├── scout-gemini.yaml           # Fast search agent (Gemini)
    ├── scout-haiku.yaml            # Fast search agent (Haiku)
    └── scout-codeqwen.yaml         # Code-focused search
```

**`.claude/commands/scout-plan-build.md`**:

```markdown
---
description: Complete Scout-Plan-Build workflow for complex tasks
argument-hint: <task description>
---

# Scout Plan Build Workflow

Execute complete workflow with context optimization.

## Variables
- $ARGUMENTS: Task description
- $DOCUMENTATION_URLS: Optional documentation URLs

## Workflow

### Step 1: Scout (Search Phase)
/scout $ARGUMENTS

**Purpose**: Find all relevant files using parallel sub-agents
**Output**: relevant_files.md

### Step 2: Plan (Planning Phase)
/plan-with-docs $ARGUMENTS $DOCUMENTATION_URLS

**Purpose**: Create detailed implementation plan with clean context
**Output**: detailed_plan.md

### Step 3: Build (Implementation Phase)
/build

**Purpose**: Implement plan systematically
**Output**: implementation_summary.md + modified files

## Report

Provide summary of:
1. Files scouted (from relevant_files.md)
2. Plan phases (from detailed_plan.md)
3. Implementation results
4. Test results
```

**Usage**:

```bash
# Simple usage
/scout-plan-build "Migrate to Claude Agent SDK"

# With documentation
/scout-plan-build "Add dark mode toggle" --docs https://tailwindcss.com/docs/dark-mode
```

### Implementação: Multi-Agent Review

```markdown
# .claude/commands/multi-review.md

---
description: Get comprehensive code review from multiple specialized agents
---

# Multi-Agent Review Workflow

## Step 1: Launch Parallel Reviewers

Use Task tool to spawn 3 specialized review agents:

### Security Agent
```
Review $ARGUMENTS for:
- Authentication/authorization issues
- Data exposure risks
- Injection vulnerabilities
- Insecure dependencies
```

### Performance Agent
```
Review $ARGUMENTS for:
- Inefficient algorithms
- N+1 queries
- Memory leaks
- Unnecessary computations
```

### Code Quality Agent
```
Review $ARGUMENTS for:
- Code readability
- Naming conventions
- Error handling
- Test coverage
```

## Step 2: Consolidate Reviews

Merge all findings into final_review.md:

```markdown
# Code Review Results

## Critical Issues (Security)
1. [Issue from security agent]

## High Priority (Performance)
1. [Issue from performance agent]

## Medium Priority (Code Quality)
1. [Issue from quality agent]

## Summary
- Total issues: N
- Critical: N
- High: N
- Medium: N
- Low: N
```

## Step 3: Report
Present final_review.md to user
```

---

## Troubleshooting

### Problem: Context Window Still Full

**Symptoms**:
- Hitting context limits even with Scout-Plan-Build
- autocompact still triggering

**Solutions**:

1. **Disable autocompact**
```json
{"autocompact": false}
```

2. **Use more aggressive condensation in Scout**
```markdown
# Instead of full file previews:
File: auth.py
Lines 45-120: Authentication logic
Key pattern: JWT tokens with refresh
```

3. **Clear between phases**
```bash
# After scout completes
/clear
# Start fresh for plan phase with just relevant_files.md
```

4. **Use file offsets aggressively**
```python
# Don't read full 2000-line file
Read("large.py", offset=450, limit=100)  # Just the relevant section
```

### Problem: Sub-agents Not Returning Results

**Symptoms**:
- Task tool launches agents but returns empty
- Timeout errors

**Solutions**:

1. **Check agent definitions**
```yaml
# ❌ Missing description
name: scout-agent

# ✅ Has description (required!)
name: scout-agent
description: Fast search agent for codebase exploration
```

2. **Verify tool access**
```yaml
# ✅ Grant necessary tools
tools: Grep, Glob, Read
```

3. **Check parallelism limits**
```markdown
# Max 10 parallel agents
# ❌ Trying to launch 15 agents
# ✅ Launch 10, wait, then launch 5 more
```

### Problem: Plans Too Vague

**Symptoms**:
- Builder agent asks clarifying questions
- Implementation deviates from plan

**Solutions**:

1. **More detailed planning prompt**
```markdown
# ❌ Vague
"Create plan for task"

# ✅ Detailed
"Create detailed plan with:
- Exact file paths and line ranges
- Specific code changes (show before/after)
- Test commands for each phase
- Success criteria"
```

2. **Include examples in plan prompt**
```markdown
Example of good plan structure:

## Phase 1: Update authentication
**File**: src/auth/login.py
**Lines**: 45-60
**Change**: Replace old JWT library with new one

Before:
```python
import old_jwt
token = old_jwt.encode(payload)
```

After:
```python
import new_jwt
token = new_jwt.create(payload)
```

**Test**: pytest tests/test_auth.py::test_jwt_generation
```

### Problem: Build Phase Failing

**Symptoms**:
- Tests fail during build
- Build agent gets stuck

**Solutions**:

1. **Add validation to plan**
```markdown
Each phase must include:
1. Implementation steps
2. **Validation command**
3. **Expected result**
4. **Fix strategy if tests fail**
```

2. **Use Edit tool, not Write**
```python
# ✅ Surgical changes
Edit(file, old_string, new_string)

# ❌ Rewriting files (error-prone!)
Write(file, entire_content)
```

3. **Test after each phase**
```markdown
# Don't wait until end to test!

Phase 1: Update models
→ Run tests
→ ✅ Pass? Continue to Phase 2
→ ❌ Fail? Fix before continuing
```

---

## Próximos Passos

Agora que você entende workflows avançados:

1. **Implemente Scout-Plan-Build**
   - Copie templates de `/templates/workflows/`
   - Adapte para seu projeto
   - Teste em task simples primeiro

2. **Aprenda Composição**
   - [02. Slash Commands e Composição](02-slash-commands-composicao.md)
   - Crie seus próprios workflows compostos

3. **Otimize Context**
   - [05. Context Engineering](05-context-engineering.md)
   - R&D Framework aplicado

4. **Configure Sub-agentes**
   - [03. Sub-agentes e Task Tool](03-subagentes-task-tool.md)
   - Crie equipe especializada de agents

---

## Referências

- [Transcrição Original](../transcricao.md) - Fonte da estratégia Scout-Plan-Build
- [Claude Code Docs - Sub-agents](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Claude Code Docs - Common Workflows](https://docs.claude.com/en/docs/claude-code/common-workflows)
- [Anthropic - Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

---

**Anterior**: [06. Output Styles ←](06-output-styles.md) | **Próximo**: [08. Configuração Settings →](08-configuracao-settings.md)
