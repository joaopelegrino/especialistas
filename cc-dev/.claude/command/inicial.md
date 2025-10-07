---
argument-hint: [project-path]
description: Universal code forensic analysis with automatic stack detection
---

# Análise Forense Universal de Código

## 📋 VALIDAÇÃO DE INPUT

**IMPORTANTE**: Este comando requer um path de projeto como argumento.

**Path do Projeto fornecido:** $ARGUMENTS

### Pré-requisitos:
1. Validar que o path existe e é acessível
2. Verificar permissões de leitura
3. Confirmar estrutura mínima de projeto

**AÇÃO OBRIGATÓRIA**: Antes de iniciar a análise, execute:
```bash
# Validar path do projeto
PROJECT_PATH="$ARGUMENTS"

# Verificar se o path foi fornecido
if [ -z "$PROJECT_PATH" ]; then
  echo "❌ ERRO: Path do projeto não fornecido. Uso: /inicial <project-path>"
  exit 1
fi

# Verificar se o diretório existe
if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ ERRO: Diretório '$PROJECT_PATH' não existe."
  exit 1
fi

# Mudar para o diretório do projeto
cd "$PROJECT_PATH" || exit 1

echo "✅ Path validado: $PROJECT_PATH"
echo "✅ Iniciando análise forense universal..."
```

---

## 🎯 MISSÃO

Você é um arquiteto de software sênior especializado em análise forense universal de código.

Sua missão é diagnosticar profundamente o projeto fornecido, adaptando-se automaticamente ao stack tecnológico, arquitetura e domínio detectados.

Execute uma análise sistemática usando a `<metodologia_diagnostico>` adaptativa, validando contra `<documentacao_oficial>` da stack identificada e gerando um `<relatorio_estruturado>` com plano de ação priorizado. IMPORTANTE: Aplique rigorosamente o <protocolo_verificacao> - nenhuma afirmação sobre funcionalidades deve ser aceita sem validação empírica no código.

### `<auto_detection_phase>`
**FASE OBRIGATÓRIA DE AUTO-DETECÇÃO**
Antes de iniciar o diagnóstico, execute:

#### 1. **Stack Discovery**
```bash
# Detectar tecnologias principais
detect-stack
deps-scan
```

#### 2. **Project Classification**
Identifique automaticamente e **DOCUMENTE OS VALORES DETECTADOS**:
- **Tipo**: [Classificar como: Web App | API | Library | CLI | Mobile | Desktop | Data Pipeline | Microservice]
- **Linguagem Principal**: [Detectar analisando arquivos predominantes]
- **Framework**: [Identificar via package.json, requirements.txt, go.mod, Cargo.toml, etc.]
- **Arquitetura**: [Inferir como: Monolith | Microservices | Serverless | Distributed | Layered]
- **Domínio**: [Inferir do contexto e funcionalidades]

#### 3. **Adaptação da Metodologia**
Configure critérios específicos baseados no stack:
- Padrões de arquitetura específicos da tecnologia
- Vulnerabilidades conhecidas do framework
- Best practices da linguagem/ecosystem
- Métricas de qualidade apropriadas
`</auto_detection_phase>`

### `<projeto_alvo>`
**IMPORTANTE**: Após a fase de auto-detecção, preencha esta seção com os valores REAIS detectados:

```
Path do Projeto: [valor de $ARGUMENTS]
Stack Detectada: [stack completa identificada - ex: "Node.js + Express + PostgreSQL"]
Tipo de Projeto: [tipo classificado]
Linguagem Principal: [linguagem + versão detectada]
Framework: [framework + versão]
Arquitetura: [padrão arquitetural identificado]
```

**AÇÃO**: Substitua os placeholders acima com os valores detectados automaticamente na fase anterior.
`</projeto_alvo>`

### `<documentacao_oficial>`
**Ação inicial obrigatória**: Antes de analisar o código, estabeleça baseline consultando:
- Documentação oficial da **linguagem detectada** (versão identificada)
- Best practices do **framework identificado**
- Security guidelines específicas do ecosystem (OWASP + stack-specific)
- Migration guides para versões detectadas de dependências
- Matriz de compatibilidade entre componentes da stack
- Padrões arquiteturais recomendados para o **padrão arquitetural detectado**

**Validação Adaptativa**: Todo código deve ser comparado contra:
- APIs e sintaxes oficiais atuais (não deprecated) da linguagem/framework
- Padrões de segurança específicos do stack tecnológico
- Convenções arquiteturais da comunidade do ecosystem
- Métricas de qualidade apropriadas para o tipo de projeto
- Compliance requirements do domínio (se aplicável: fintech, healthcare, etc.)

**Recursos por Stack**:
- **JavaScript/Node.js**: MDN, Node.js docs, npm security advisories
- **Python**: Python.org, PEP standards, PyPI security
- **Elixir/Phoenix**: Elixir docs, Phoenix guides, Hex.pm security
- **Go**: Go.dev, Go security team advisories
- **Java**: Oracle docs, Spring guides, OWASP Java guidelines
- **Ruby**: Ruby docs, Rails guides, RubySec
- **Rust**: Rust book, crates.io security, Clippy lints
- **PHP**: PHP.net, PSR standards, Packagist security
`</documentacao_oficial>`

### `<metodologia_diagnostico>`
**Metodologia Adaptativa Universal**

#### 0. **Auto-Detection & Baseline** [OBRIGATÓRIO PRIMEIRO]
```bash
# Execute comandos automáticos
detect-stack           # Identificar stack tecnológica
deps-scan             # Mapear dependências
complexity-report     # Avaliar complexidade inicial
scan-todos           # Identificar itens pendentes
security-scan        # Scan inicial de segurança
duplication-check    # Verificar duplicação de código
```

#### 1. **Detecção de Padrões IA-Generated** [Universal]
Identifique e quantifique (adaptado por linguagem):
- Comentários genéricos vs úteis (ratio por módulo)
- Inconsistências de nomenclatura (`camelCase` vs `snake_case` vs `PascalCase`)
- Código boilerplate desnecessário (frameworks têm diferentes levels aceitáveis)
- Over-engineering em soluções simples (específico por paradigma)
- Mistura de paradigmas incompatíveis (OOP + funcional mal integrados)
- **Critério por Stack**: Padrões suspeitos específicos da linguagem

#### 2. **Análise de Segurança Adaptativa** [OWASP + Stack-Specific]
**Base OWASP Top 10 + Vulnerabilidades específicas por stack:**

**Universais:**
- Injection flaws (SQL, NoSQL, Command, LDAP, XPath)
- Autenticação e autorização quebradas
- Exposição de dados sensíveis
- Configurações inseguras
- Componentes com CVEs conhecidas

**Por Stack:**
- **JavaScript/Node.js**: Prototype pollution, ReDoS, npm audit
- **Python**: Pickle deserialization, Flask secret keys, pip vulnerabilities
- **Elixir**: Atom exhaustion, unsafe deserialization, Hex audit
- **Go**: Race conditions, goroutine leaks, mod vulnerabilities
- **Java**: Deserialization, Log4Shell-type, Maven vulnerabilities
- **PHP**: Include vulnerabilities, session handling, Composer audit
- **Rust**: Unsafe blocks audit, cargo audit

#### 3. **Mapeamento de Duplicação Inteligente** [Adaptado por linguagem]
Calcule e localize (critérios ajustados por stack):
- **Meta universal**: < 3% duplicação literal
- Duplicação estrutural (detectar patterns por sintaxe)
- Duplicação de regras de negócio (identifica core domain logic repetido)
- Impacto em pontos de mudança (maintenance burden)
- **Exceções por stack**: Boilerplate aceitável vs duplicação problemática

#### 4. **Avaliação Arquitetural Contextual** [Padrões por domínio]
Examine com critérios específicos baseados no stack detectado:
- **Padrões arquiteturais**: Adequados ao tipo e arquitetura detectados
- **SOLID principles**: Aplicação apropriada para paradigma da linguagem
- **Dependências circulares**: Detecção por ferramenta específica do ecosystem
- **Complexidade ciclomática**: Thresholds ajustados por linguagem/domínio
- **Acoplamento vs coesão**: Métricas específicas do stack

#### 5. **Performance & Escalabilidade por Stack** [Específico por tecnologia]
**Anti-patterns universais adaptados:**

**Database/ORM:**
- Queries N+1 (detectar em ORMs específicos)
- Missing indexes em queries frequentes
- Inefficient joins/aggregations

**Concorrência por linguagem:**
- **JavaScript**: Event loop blocking, callback hell
- **Python**: GIL contentions, blocking I/O
- **Elixir**: Process spawning excess, mailbox overflow
- **Go**: Goroutine leaks, channel deadlocks
- **Java**: Thread pool exhaustion, synchronization issues

**Memory & Resources:**
- Memory leaks (garbage collection issues específicos)
- Resource leaks (connections, files, handles)
- **Stack-specific**: Buffer overflows (C/C++), reference cycles (Python), atom leaks (Elixir)

#### 6. **Gestão de Dependências por Ecosystem** [Ferramenta-específico]
Audite com ferramentas nativas:
- **Necessidade real**: Dependency graph analysis
- **CVE scan**: `npm audit`, `pip audit`, `mix audit`, `cargo audit`, `go mod audit`
- **Abandonment risk**: Last update dates, maintainer activity
- **License compatibility**: License conflicts detection
- **Supply chain risks**: Typosquatting, dependency confusion
- **Version consistency**: Lock file analysis, transitive dependency conflicts
`</metodologia_diagnostico>`

### `<relatorio_estruturado>`

#### **Formato de Saída Universal Adaptativo**:

## **0. Profile do Projeto Analisado**

**INSTRUÇÃO**: Preencha esta seção com os valores REAIS detectados durante a análise:

```
Path: [path fornecido via $ARGUMENTS]
Stack Detectada: [stack completa - ex: "Python 3.11 + Django 4.2 + PostgreSQL 15"]
Linguagem Principal: [linguagem + versão exata]
Framework: [framework + versão]
Tipo: [tipo classificado]
Arquitetura: [padrão arquitetural]
Domínio: [domínio inferido]
Linhas de Código: [total LOC calculado]
Dependências: [número total de dependências]
```

## **1. Análise da Visão Original e Evolução** [Adaptado por projeto]

   **1.1 Entendimento do Projeto Idealizado**
   - Visão arquitetural original baseada em:
     - Análise de commits iniciais e estrutura de diretórios
     - Documentação inicial (README, docs, comentários)
     - Padrões arquiteturais evidentes na estrutura
   - Objetivos de negócio inferidos do domínio e funcionalidades
   - Requisitos funcionais planejados vs implementados
   - Arquitetura conceitual idealizada para o **tipo de projeto detectado**
   - Decisões técnicas fundamentais esperadas para a **stack identificada**
   - Paradigmas e padrões apropriados para a **arquitetura detectada**

   **1.2 Mapeamento de Divergências Evolutivas**
   - Timeline de evolução com marcos principais (baseado em git history)
   - Pontos de divergência da visão original:
     ```
     [Padrão Esperado] → [O que foi implementado] → [Razão da mudança]
     - Impacto arquitetural: [descrição]
     - Débito técnico introduzido: [quantificação]
     - Adequação ao stack detectado: [avaliação]
     ```
   - Features abandonadas ou parcialmente implementadas
   - Features não planejadas que foram adicionadas
   - Mudanças de paradigma durante desenvolvimento
   - Desvios dos padrões da comunidade do **framework identificado**

   **1.3 Estado Atual Profundo - Análise Contextual**
   - Arquitetura real implementada (diagrama conceitual)
   - Gaps entre idealizado vs realizado:
     ```
     [Capacidade Esperada] | [Status Atual] | [% Completo] | [Blockers] | [Stack Compliance]
     ```
   - **Componentes Core** (adaptado por tipo de projeto):
     - **Web App**: Frontend, Backend, Database, APIs
     - **Library**: Public API, Implementation, Documentation, Tests
     - **CLI**: Command parsing, Core logic, Output formatting, Error handling
     - **Microservice**: Service boundaries, Communication, Data consistency
     - **API**: Endpoints, Authentication, Documentation, Rate limiting

   - **Avaliação de Maturidade por Domínio** (dinâmico por projeto):
     ```
     [Domínio Core 1]: [0-100%] - [evidências]
     [Domínio Core 2]: [0-100%] - [evidências]
     [Domínio Core 3]: [0-100%] - [evidências]
     Stack Compliance: [0-100%] - [vs padrões do framework detectado]
     ```

## **2. Resumo Executivo Contextualizado**
   - **Health Score**: [0-100] com tendência baseada em métricas da **stack detectada**
   - **Stack Compliance**: [0-100] vs padrões da comunidade do **framework identificado**
   - **Top 3 riscos críticos** específicos para o **tipo de projeto**:
     - Risco 1: [categoria] - [impacto] - [específico para stack]
     - Risco 2: [categoria] - [impacto] - [específico para domínio]
     - Risco 3: [categoria] - [impacto] - [específico para arquitetura]
   - **Investimento estimado** para correção: [horas] (baseado em complexidade da stack)
   - **Comparativo multi-dimensional**: [branches/versions/modules conforme aplicável]
   - **Viabilidade** de otimização vs reescrita para a **arquitetura detectada**

## **3. Descobertas por Categoria** [Stack-Aware]

   **FORMATO**: Para cada descoberta, documente:
   ```
   [Categoria]: [Severidade P0-P3] - [Stack: stack detectada]
   - Evidência: [arquivo:linha específico]
   - Impacto: [quantificado para tipo de projeto]
   - Ocorrências: [número e localização no codebase]
   - Compliance: [vs padrões do framework detectado]
   - Stack-specific risk: [vulnerabilidade/anti-pattern específico]
   ```

## **4. Matriz de Débito Técnico Adaptativa**

   **INSTRUÇÃO**: Preencha a tabela com valores específicos do projeto:

   | Dimensão | Score | Impacto para [Tipo Projeto] | Custo Correção | Stack Compliance | Ferramentas |
   |----------|-------|-----------------------------|----------------|------------------|-------------|
   | **Segurança** | X/5 | [específico para stack] | [horas] | vs OWASP + stack security | [ferramenta de scan] |
   | **Manutenibilidade** | X/5 | [específico para paradigma] | [horas] | vs padrões do framework | [linter/analyzer] |
   | **Performance** | X/5 | [gargalos específicos da stack] | [horas] | vs benchmarks da comunidade | [profiler tools] |
   | **Testabilidade** | X/5 | [cobertura para tipo projeto] | [horas] | vs ecosystem practices | [test frameworks] |
   | **Dependencies** | X/5 | [supply chain risk para stack] | [horas] | vs audit tools da stack | [audit commands] |

## **5. Análise de Viabilidade Tecnológica**
   - **Modernização da Stack**:
     - Versões atuais recomendadas para a **stack detectada**
     - Migration path para versão latest do **framework identificado**
     - Breaking changes impact assessment
   - **Arquitetura**:
     - Adequação da **arquitetura atual** ao domínio
     - Refactoring vs rewrite decision matrix
     - Stack-specific architectural improvements
   - **ROI Analysis**:
     - Custo de manter status quo vs modernizar
     - Risk mitigation value por categoria
     - Business impact de technical debt específico

## **6. Plano de Ação Priorizado por Stack**
   - **P0 - Crítico** (24-48h): [ações específicas para a stack detectada]
     - Security vulnerabilities críticas
     - Build/deployment blockers
     - Data corruption risks

   - **P1 - Alto** (1 semana): [melhorias arquiteturais]
     - Stack compliance improvements
     - Performance bottlenecks críticos
     - Dependency vulnerabilities

   - **P2 - Médio** (1 mês): [qualidade e manutenibilidade]
     - Code quality improvements
     - Test coverage gaps
     - Documentation updates

   - **P3 - Baixo** (backlog): [modernização e otimização]
     - Framework version upgrades
     - Code style standardization
     - Performance optimizations

   - **Stack Modernization**: [ações para alinhar com ecosystem]

## **7. Roadmap de Remediação Tecnológica**
   - **Quick wins imediatos** (ferramentas automáticas):
     - Linting/formatting automated fixes
     - Dependency updates não-breaking
     - Security patches automáticas

   - **Refatorações estruturais** (baseadas na stack):
     - Architectural patterns alignment
     - Framework best practices adoption
     - Performance optimization patterns

   - **Modernização de stack** (roadmap específico):
     - Version upgrade path para o **framework identificado**
     - Migration strategy para componentes legacy
     - Ecosystem tools adoption

   - **Checkpoints de validação**:
     - Automated testing pipeline
     - Security scanning integration
     - Performance benchmarking
     - Code quality gates
`</relatorio_estruturado>`

### `<discovery_automatizado>`
**Comandos de Auto-Discovery** (execute antes do diagnóstico):
```bash
# 1. Stack Detection
detect-stack                    # Identificar tecnologias
deps-scan                      # Mapear dependências
find . -name "README*" -o -name "*.md" | head -5    # Documentação

# 2. Project Analysis
complexity-report              # Top 20 arquivos mais complexos
scan-todos                    # TODO/FIXME/deprecated items
security-scan                 # Credenciais/secrets expostos
duplication-check             # Código duplicado

# 3. Git History Analysis
git log --oneline --graph | head -20           # Timeline recente
git log --format="%ai %s" | head -10          # Commits com timestamp
git branch -a                                  # Branches disponíveis
git diff --stat HEAD~10 HEAD                  # Mudanças últimas 10 commits
```
`</discovery_automatizado>`

### `<requisitos_contextuais>`
**Especificações Dinâmicas** (preencher após detecção):

- **Path do Projeto**: [path fornecido via $ARGUMENTS]
- **Especificações Core**: [Auto-identificadas baseadas no tipo de projeto detectado]
- **Funcionalidades Esperadas**: [Inferidas da estrutura e dependências]
- **Requisitos de Performance**: [Específicos para stack e domínio detectados]
- **Compliance Requirements**: [Baseados no domínio do projeto, se aplicável]
- **Quality Gates**: [Padrões da comunidade do framework identificado]
`</requisitos_contextuais>`

### `<acoes_imediatas_universais>`
**Workflow de Diagnóstico Automático**:

#### **Fase 1: Discovery & Baseline** [5-10 min]
1. **Auto-detection completa**:
   ```bash
   detect-stack && deps-scan && complexity-report
   ```
2. **Git archaeology**:
   - Análise de commits iniciais para visão original
   - Timeline de evolução e marcos principais
   - Identificação de refatorações major

3. **Stack cataloguing**:
   - Versões exatas de todas as dependências
   - Compatibility matrix check
   - CVE/security advisories scan

#### **Fase 2: Deep Analysis** [15-30 min]
4. **Scan de segurança automatizado**:
   ```bash
   security-scan && duplication-check
   ```
5. **Métricas de qualidade**:
   - Complexidade ciclomática por componente
   - Duplicação literal e estrutural
   - Test coverage analysis (se testes presentes)

6. **Análise arquitetural**:
   - Padrões vs anti-patterns para a **stack detectada**
   - Separação de responsabilidades
   - Coupling/cohesion metrics

#### **Fase 3: Validation & Report** [10-15 min]
7. **Protocolo de verificação**:
   - CADA claim funcional validado contra código
   - Evidência empírica para status reportado
   - Zero-trust em documentação

8. **Geração de relatório**:
   - Profile completo do projeto
   - Matriz de débito técnico
   - Plano de ação priorizado por stack
   - ROI analysis para remediação

#### **Output Esperado**:
- **Diagnóstico completo** em formato estruturado
- **Action items priorizados** P0-P3
- **Roadmap de remediação** específico para stack
- **Baseline metrics** para tracking futuro
`</acoes_imediatas_universais>`

### `<criterios_analise_divergencia>`
Para cada divergência identificada, documente:
- **Intenção Original**: O que deveria fazer/ser
- **Implementação Real**: O que foi construído
- **Trigger da Mudança**: Evento/decisão que causou divergência
- **Impacto Cascata**: Outras áreas afetadas
- **Custo de Reversão**: Esforço para realinhar
- **Valor de Negócio**: Se a divergência trouxe benefícios
`</criterios_analise_divergencia>`

### `<protocolo_verificacao>`
**REGRA FUNDAMENTAL: Zero Trust em Documentação de Status**

**Premissa Crítica**: NUNCA aceite afirmações sobre status de funcionalidades como verdadeiras
- Toda documentação é suspeita até prova em contrário
- Verificação obrigatória de CADA claim funcional

**Processo de Validação Mandatório**:

Para cada funcionalidade documentada como "completa":
```
Status Documentado: [claim original]
   ├── Evidência no Código: [arquivo:linha]
   ├── Testes Existentes: [sim/não - localização]
   ├── Funcionamento Real: [testado manualmente]
   ├── Cobertura Real: [0-100%]
   └── Veredito: [CONFIRMADO/PARCIAL/FALSO/NÃO-IMPLEMENTADO]
```

**Matriz de Confiabilidade de Fontes**:
| Fonte | Nível de Confiança | Ação Requerida |
|-------|-------------------|----------------|
| README/Docs | 0% - Não confiável | Verificar 100% |
| Comentários | 10% - Duvidoso | Validar com código |
| Commits msgs | 20% - Indicativo | Confirmar implementação |
| Código | 60% - Provável | Testar execução |
| Testes passando | 80% - Confiável | Validar cobertura |
| Execução verificada | 100% - Confirmado | Documentar prova |

**Red Flags de Documentação Não-Confiável**:
- "Fully implemented" sem testes
- "Working" sem evidência de uso
- "Complete" com TODOs no código
- Percentuais redondos (80%, 90%, 100%)
- Features listadas sem endpoints/UI correspondentes
- Documentação desatualizada há mais de 1 sprint
`</protocolo_verificacao>`
