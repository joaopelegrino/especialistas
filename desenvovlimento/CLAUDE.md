Gostaria que você fosse o responsavel para iniciar a <implementacao> encontrando a melhor maneira para o projeto. 
Atualmente tenho um <projeto> onde as documentocoes, configurações, contextos fixos e contextos dinâmicos da LLM ficam nas <pastas>.  Atualmente penso que os arquivos chave são:
/home/notebook/workspace/blog/.claude/PROMPTBASE-INICIAL.md
/home/notebook/workspace/blog/HISTORICO-MUDANCAS.md
/home/notebook/workspace/blog/README.md
/home/notebook/workspace/blog/GUIA-TESTES-USUARIO.md
/home/notebook/workspace/blog/docs/ARQUITETURA.md
/home/notebook/workspace/blog/docs/ROADMAP.md
/home/notebook/workspace/blog/docs/aprendizados/consolidado-master.md
<implementacao>
## Diretivas de Pré-Leitura Obrigatória de documentação e código da base
Header com Dependências de Contexto
```typescript
/**
 * @before-editing-read: [
 *   "../shared/types/UserTypes.ts",        // Tipos base
 *   "../services/AuthService.ts#L45-L89",  // Lógica de autenticação
 *   "../store/userSlice.ts",               // Estado global
 *   "../../docs/auth-flow.md"              // Fluxo completo
 * ]
 * 
 * @required-context-tags: [
 *   "#auth-flow",      // Busque todas tags #auth-flow no projeto
 *   "#user-validation", // Regras de validação relacionadas
 *   "#api-contract"     // Contratos de API que impactam este componente
 * ]
 * 
 * @critical-warnings: [
 *   "NEVER modify without updating UserProfile.test.tsx",
 *   "State mutations MUST go through Redux actions only"
 * ]
 */
```
## Sistema de Tags Hierárquicas com Prioridade
Níveis de Contexto Progressivo
```javascript
// @context-level-1: CRITICAL - Read before ANY change
//   - File: ./interfaces/IUserAuth.ts
//   - Section: ./AuthContext.tsx#provider-logic
//   - Tag-search: #authentication-critical
// @context-level-2: IMPORTANT - Read for structural changes  
//   - File: ./hooks/useAuth.ts
//   - Pattern: Search all "AUTH_EVENT" constants
//   - Tag-search: #auth-middleware
// @context-level-3: RECOMMENDED - Read for optimizations
//   - File: ./utils/tokenManager.ts
//   - Documentation: ../docs/performance.md
```
## Contratos de Edição com Guards
Pré-condições Explícitas
```python
"""
@editing-contract:
  pre-conditions:
    must-understand:
      - file: "./models/user_model.py"
      - search-tag: "#user-schema-v2"
      - concept: "Event sourcing pattern used here"
    
    must-verify:
      - "All UserEvents are backward compatible"
      - "Schema migrations are additive only"
      - "Check impact on: [UserService, AuthService, ProfileService]"
    
    forbidden-changes:
      - "Do NOT modify field 'legacy_id' - production dependency"
      - "Do NOT change event ordering - breaks event replay"
"""
```
## Breadcrumbs de Navegação Contextual
Trilha de Compreensão
```tsx
/**
 * @context-trail:
 *   1. START: "../../README.md#architecture-overview"
 *   2. THEN: "../patterns/ComponentPattern.md"
 *   3. THEN: "./BaseComponent.tsx" (parent class)
 *   4. THEN: Search "#component-lifecycle" tags
 *   5. FINALLY: Read this file
 * 
 * @editing-checklist:
 *   [ ] Read all @context-trail items
 *   [ ] Run: npm run analyze:impact UserProfile
    [ ] Check: grep -r "UserProfile" --include=".test.*"
 *   [ ] Verify: No breaking changes in GraphQL schema
 */
```
## Referências Dinâmicas e Queries
Queries de Contexto para LLMs
```java
/**
 * @llm-context-queries:
 *   - SEARCH_PROJECT: "@implements PaymentGateway"
 *   - FIND_USAGES: "processPayment("
    - LOCATE_TESTS: "PaymentProcessor.(test|spec)"
    - GREP_PATTERN: "PAYMENT_._EVENT"
 *   - AST_SEARCH: "class extends PaymentProcessor"
 * 
 * @llm-instructions:
 *   - BEFORE_EDIT: "Execute all @llm-context-queries"
 *   - ANALYZE: "Check for breaking changes in found usages"
 *   - VALIDATE: "Ensure all tests still pass conceptually"
 */
```
## Metadados de Impacto em Cascata
Grafo de Dependências
```typescript
// @impact-graph:
//   direct-dependents: [
//     "./UserAvatar.tsx",
//     "./UserMenu.tsx"
//   ]
//   
//   state-consumers: [
//     "search: useSelector.*user",
//     "search: getUserProfile"
//   ]
//   
//   api-endpoints: [
//     "GET /api/user/:id",
//     "PUT /api/user/:id/profile"
//   ]
//   
//   test-files: [
//     "auto-discover: .test. containing 'UserProfile'"
//   ]
// @modification-protocol:
//   1. Read all items in @impact-graph
//   2. Understand current implementation in each
//   3. Plan changes considering all touchpoints
//   4. Update tests first, then implementation
```
## Marcadores de Sincronização
Cross-file Consistency Markers
```python
# @sync-required-with: [
#   {
#     "file": "./schemas/user.graphql",
#     "section": "type User",
#     "rule": "Fields must match 1:1"
#   },
#   {
#     "file": "./validators/user_validator.py", 
#     "section": "UserSchema class",
#     "rule": "Validation rules must be compatible"
#   }
# ]
# @version-lock: "user-schema-v3.2"  # All synced files must use same version
```
## Implementação com Ferramentas
Script de Pré-edição Automatizado
```bash
#!/bin/bash
# .hooks/pre-edit-check.sh
# Extrai e executa diretivas @before-editing-read
extract_required_reads() {
  grep -h "@before-editing-read:" $1 | \
    sed 's/.*@before-editing-read://' | \
    parse_file_list
}
# Coleta todo contexto necessário
collect_context() {
  local file=$1
  echo "=== Required Context for $file ==="
  
  # Extrai arquivos obrigatórios
  for required in $(extract_required_reads $file); do
    echo "--- Reading: $required ---"
    cat $required
  done
  
  # Busca tags relacionadas
  for tag in $(extract_required_tags $file); do
    echo "--- Tag results for: $tag ---"
    grep -r "$tag" --include="*.{ts,tsx,js,jsx}"
  done
}
```
IDE Integration (VSCode exemplo)
```json
{
  "editor.codeActions": {
    "source.showContextRequirements": true
  },
  "contextualizer": {
    "showPreEditWarnings": true,
    "autoLoadRequiredContext": true,
    "highlightSyncedSections": true
  }
}
```
## Exemplo Completo Integrado
```typescript
/**
 * @file: UserProfileComponent.tsx
 * @criticality: HIGH - Core user functionality
 * 
 * ===== MANDATORY PRE-EDIT PROTOCOL =====
 * 
 * @step-1-understand-architecture:
 *   READ: "../../docs/frontend-architecture.md#component-hierarchy"
 *   WHY: This component is part of a larger composition pattern
 * 
 * @step-2-check-dependencies:
    SEARCH: grep -r "UserProfileComponent" --include=".{tsx,ts}"
 *   EXPECT: Find ~12 imports across the application
 *   ACTION: Verify your changes won't break these imports
 * 
 * @step-3-review-state-management:
 *   READ: "../store/userSlice.ts"
 *   FOCUS: Lines 45-89 (userData reducer)
 *   CRITICAL: State shape MUST remain backward compatible
 * 
 * @step-4-understand-api-contract:
 *   READ: "../../api/openapi.yaml#/components/schemas/UserProfile"
 *   VERIFY: Any new fields exist in API response
 *   CHECK: "../services/UserService.ts#fetchUserProfile"
 * 
 * @step-5-test-impact:
 *   RUN: npm run test:related UserProfile
 *   COUNT: Should find 8 test files
 *   MANDATORY: All must still pass after changes
 * 
 * ===== CONTEXT TAGS TO SEARCH =====
 * #user-data-flow - Understand complete data lifecycle
 * #profile-validation - Business rules for profile data
 * #cache-strategy - How profile data is cached
 * 
 * ===== FORBIDDEN ACTIONS =====
 * - NEVER change prop 'userId' type (number -> string broke prod in v2.1)
 * - NEVER remove 'legacySupport' flag until v4.0
 * - NEVER modify without updating UserProfileComponent.test.tsx
 * 
 * @ai-llm-instruction: "Before suggesting ANY edit, confirm you've processed ALL sections above"
 */
import React from 'react';
// ... component code
```
Essa abordagem cria um "protocolo de entrada" que força a compreensão progressiva do contexto, reduzindo drasticamente erros de edição e melhorando a qualidade das sugestões de LLMs.
</implementacao>
<projeto>
Identifique toda estrutura do diretório "thinkharder"
/home/notebook/workspace/blog/  

</projeto>
<pastas>

/home/notebook/workspace/blog/.claude/
/home/notebook/workspace/blog/docs/

</pastas>
