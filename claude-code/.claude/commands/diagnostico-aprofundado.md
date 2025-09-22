# 🔍 Diagnóstico Aprofundado - Command Template

## 📋 **RESUMO EXECUTIVO**

**🎯 O que faz**: Análise aprofundada evidence-based do projeto, validando documentação vs realidade

**📥 Inputs necessários**:
- Caminho do projeto alvo
- ROADMAP_MASTER.md (direcionamento estratégico)
- Estrutura .claude completa (CLAUDE.md + secundários)
- /docs/ (documentação interna)

**📤 Outputs gerados**:
- `llm-context-master.md` - Documento completo para inicialização LLM
- `diagnostico-completo.md` - Análise consolidada evidence-based
- `accuracy-correction-report.md` - Log alegado vs real
- `protective-measures.md` - Medidas stakeholder protection
- `seven-layer-assessment.md` - Avaliação camadas documentação

**⚠️ Critical**: Inclui Fase 0 obrigatória de evidence validation e stakeholder protection

---

Este comando realiza análise aprofundada do código legado, contrastando com ROADMAP_MASTER.md e /docs para alinhamento antes de implementações.

## 📋 Fluxo de Execução

### **Fase 0: CRÍTICA - Validação de Evidências (OBRIGATÓRIA)**
```yaml
evidence_validation:
  - realidade_vs_documentacao: "Validar TODAS alegações técnicas vs implementação real"
  - teste_funcionalidade: "Testar features alegadas com screenshots/análise código"
  - identificar_aspiracional: "Separar conteúdo factual vs aspiracional"
  - metodologia_validacao: "Documentar fontes de evidência e testes"
  - riscos_legais: "Sinalizar potenciais problemas de documentação imprecisa"

stakeholder_risk_analysis:
  - stakeholders_prejudicados: "Identificar quem pode ser afetado por info imprecisa"
  - conformidade_legal: "Avaliar requisitos LGPD/compliance específicos"
  - informacoes_criticas: "Determinar info que deve ser imediatamente acessível"
  - niveis_risco: "Mapear Crítico(legal/segurança) > Alto(negócio) > Médio(UX) > Baixo(conveniência)"
```

### **Fase 1: Análise de Estado Atual com Validação**
```yaml
inputs_necessarios:
  - projeto_alvo: "Caminho do projeto para análise"
  - escopo_analise: "Modulos/areas específicas ou 'completo'"
  - validation_evidence: "Evidências coletadas na Fase 0"

outputs_gerados:
  - analise_codebase: "Estado atual VALIDADO com evidências"
  - accuracy_correction_log: "Log de correções (alegado vs real)"
  - gap_analysis: "Diferenças vs documentação com nível de precisão"
  - protective_measures: "Medidas imediatas para stakeholders alto risco"
  - mapa_dependencias: "Interdependências críticas VERIFICADAS"
```

### **Fase 2: Contraste com Documentação + Seven-Layer Docs Method**
```yaml
arquivos_chave_referencia:
  - ROADMAP_MASTER.md: "Direcionamento estratégico VALIDADO"
  - /docs/: "Documentação interna com verificação de precisão"
  - /docs/07-llm-context/: "Contexto LLM baseado em evidências"
  - CLAUDE.md: "Configurações LLM principais"

estrutura_claude_completa:
  documento_principal:
    - CLAUDE.md: "Configuração base e diretrizes gerais"

  documentos_secundarios:
    - .claude/: "Diretório de configurações específicas"
    - .claude/agents/: "Definições de agentes e subagents"
    - .claude/commands/: "Comandos customizados e workflows"
    - .claude/configs/: "Arquivos de configuração (settings, MCP)"
    - .claude/hooks/: "Scripts de interceptação Python"
    - .claude/docs/: "Documentação específica do projeto"

validacoes_expandidas:
  seven_layer_docs_validation:
    - evidence_based_accuracy: "Todas alegações validadas vs implementação real"
    - stakeholder_protection: "Documentação protege vs prejudica stakeholders"
    - llm_context_layer: "/docs/07-llm-context/ com contexto baseado evidências"
    - legal_compliance_layer: "Avisos legais críticos identificados e prominentes"
    - medical_domain_accuracy: "Precisão específica do domínio médico/compliance"
    - continuous_validation: "Procedimentos de manutenção de precisão contínua"

  configuracao_principal:
    - alinhamento_roadmap: "CLAUDE.md vs planejamento estratégico VALIDADO"
    - consistencia_diretrizes: "Diretrizes baseadas em evidências reais"
    - accuracy_vs_aspirational: "Separação clara entre real vs planejado"

  estrutura_secundaria:
    - agents_consistency: ".claude/agents/ alinhado com CLAUDE.md VALIDADO"
    - commands_integration: ".claude/commands/ seguindo padrões TESTADOS"
    - configs_completeness: ".claude/configs/ com configurações FUNCIONAIS"
    - hooks_implementation: ".claude/hooks/ implementado conforme templates TESTADOS"
    - docs_synchronization: ".claude/docs/ atualizado com implementações REAIS"

  integracao_documentos:
    - cross_references: "Referências bidirecionais VERIFICADAS entre docs"
    - version_consistency: "Versões sincronizadas com EVIDÊNCIAS"
    - dependency_mapping: "Dependências explícitas TESTADAS entre configurações"
    - error_prevention_context: "Contexto para evitar perpetuar alegações falsas"
```

### **Fase 3: Relatório Evidence-Based + LLM Context Master Document**
```yaml
entregas_finais:
  - diagnostico_completo.md: "Análise consolidada BASEADA EM EVIDÊNCIAS"
  - accuracy_correction_report.md: "Log de correções alegado vs real"
  - llm_context_master.md: "Documento COMPLETO para inicialização LLM no projeto"
  - protective_measures.md: "Medidas imediatas para stakeholders alto risco"
  - seven_layer_assessment.md: "Avaliação das 7 camadas de documentação necessárias"
  - plano_atualizacao.md: "Próximos passos PRIORIZADOS POR RISCO"
  - matrix_dependencias.md: "Mapeamento contextos VALIDADOS"
```

## 🔗 Dependências de Contexto

### **Pré-requisitos**
- ✅ Acesso ao projeto alvo configurado
- ✅ ROADMAP_MASTER.md disponível e atualizado
- ✅ Documentação /docs estruturada
- ✅ Ferramentas de análise (Grep, Read, Bash) funcionais

### **Contextos Necessários**
- 🔍 **Arquitetura atual**: Estrutura de diretórios e módulos
- 📚 **Stack tecnológica**: Linguagens, frameworks, dependências
- 🎯 **Objetivos roadmap**: Metas e prioridades estabelecidas
- 📖 **Padrões estabelecidos**: Convenções de código e documentação

## 📊 Template de Saída

### **llm_context_master.md Structure (NOVO - Documento Completo para Inicialização LLM)**
```markdown
# LLM Context Master Document - [PROJETO] - [DATA]
<!-- @llm-context: critical project-initialization -->

## 🎆 **PROJETO OVERVIEW - EVIDENCE-BASED**
### Project Identity & Reality Check
- **Nome do Projeto**: [Nome exato validado]
- **Domínio**: [Domínio específico com compliance requirements]
- **Stack Tecnológica Real**: [Tecnologias REALMENTE implementadas]
- **Status Atual Validado**: [Estado real vs alegado com evidências]
- **Funcionalidades Core Operacionais**: [Features TESTADAS e funcionando]
- **Gaps Críticos Identificados**: [Features alegadas mas quebradas/ausentes]

### ⚠️ **CRITICAL WARNINGS FOR LLMs**
- **Legal/Compliance Restrictions**: [Domínio médico/financeiro warnings]
- **Accuracy Requirements**: [Claims devem ser validados vs implementação]
- **Stakeholder Protection**: [Grupos que podem ser prejudicados por info incorreta]
- **Evidence Sources**: [Onde encontrar validação de claims técnicos]
```

### **diagnostico_completo.md Structure (Atualizado)**
```markdown
# Diagnóstico Evidence-Based - [PROJETO] - [DATA]

## 0. CRITICAL EVIDENCE VALIDATION RESULTS
### Reality vs Documentation Accuracy Assessment
- **Validation Methodology**: [Métodos de teste e verificação utilizados]
- **Evidence Sources**: [Screenshots, tests, code analysis realizados]
- **Accuracy Score**: [% precisão documentação existente vs realidade]
- **Critical Corrections**: [Alegações incorretas identificadas e corrigidas]

### Stakeholder Risk Analysis
- **High-Risk Stakeholders**: [Grupos que precisam proteção imediata]
- **Legal/Compliance Gaps**: [Requisitos legais não atendidos]
- **Immediate Protective Measures**: [Ações urgentes para proteção]

## 1. Executive Summary (Evidence-Based)
- Estado geral do codebase VALIDADO com testes
- Principais gaps identificados na estrutura .claude completa COM EVIDÊNCIAS
- Recomendações críticas PRIORIZADAS POR RISCO

## 2. Análise Técnica Detalhada
### 2.1 Arquitetura Atual
- Estrutura de módulos do projeto
- Padrões arquiteturais implementados
- Pontos de integração identificados

### 2.2 Qualidade do Código
- Métricas de complexidade
- Cobertura de testes
- Technical debt acumulado

### 2.3 Alinhamento com Roadmap
- Funcionalidades implementadas vs planejadas
- Desvios identificados do plano estratégico
- Impacto nas metas estabelecidas

## 3. Análise Estrutura .claude Completa + Seven-Layer Docs
### 3.1 Documento Principal (CLAUDE.md) - Evidence-Based
- Configurações LLM principais VALIDADAS vs implementação
- Diretrizes gerais BASEADAS EM REALIDADE do projeto
- Alinhamento com objetivos estratégicos REALISTAS
- **Accuracy Score**: [% de alinha com implementação real]

### 3.1.1 Seven-Layer Documentation Assessment
- **Layer 7 (LLM Context)**: /docs/07-llm-context/ analysis
- **Evidence-Based Claims**: Verificação se alegações são suportadas por testes
- **Stakeholder Protection Level**: Assessment de proteção vs risco
- **Continuous Validation Readiness**: Procedimentos para manutenção precisão

### 3.2 Documentos Secundários
#### 3.2.1 .claude/agents/
- Definições de agentes existentes
- Consistência com diretrizes principais
- Gap analysis vs necessidades identificadas

#### 3.2.2 .claude/commands/
- Comandos customizados implementados
- Workflow patterns seguidos
- Integração com sistema principal

#### 3.2.3 .claude/configs/
- Settings e configurações MCP
- Completude das configurações necessárias
- Consistency across environments

#### 3.2.4 .claude/hooks/
- Scripts Python implementados
- Aderência aos templates disponíveis
- Integration com sistema de eventos

#### 3.2.5 .claude/docs/ + Seven-Layer Integration
- Documentação específica do projeto VERIFICADA
- Sincronização com implementações REAIS (não aspiracionais)
- Coverage de funcionalidades críticas TESTADAS
- **Integration with /docs/07-llm-context/**: Connection assessment
- **Evidence Validation**: Links para fontes de validação de claims
- **LLM Context Optimization**: Markup e navegação para LLMs
- **Error Prevention**: Contexto para evitar perpetuar alegações falsas

## 4. Gap Analysis Estrutural
### 4.1 Configuração Principal
- Lacunas em CLAUDE.md
- Inconsistências com implementação
- Missing strategic alignment

### 4.2 Estrutura Secundária
- Agents missing ou desatualizados
- Commands não implementados
- Configurations incompletas
- Hooks not following templates
- Docs desatualizados ou missing

### 4.3 Integração Entre Documentos
- Cross-references quebradas
- Version inconsistencies
- Dependency mapping incompleto

## 5. Plano de Ação Estrutural
### 5.1 Prioridade CRÍTICA
- CLAUDE.md alignment com roadmap
- .claude/configs/ completude
- .claude/agents/ consistency

### 5.2 Prioridade ALTA
- .claude/commands/ implementation
- .claude/hooks/ template adherence
- Cross-document referencing

### 5.3 Prioridade MÉDIA
- .claude/docs/ synchronization
- Performance optimizations
- Workflow improvements

## 6. Matrix de Dependências Estrutural
### 6.1 Documento Principal → Secundários
- CLAUDE.md configurations → .claude/configs/
- CLAUDE.md agents → .claude/agents/
- CLAUDE.md workflows → .claude/commands/

### 6.2 Interdependências Secundárias
- .claude/agents/ ← → .claude/commands/
- .claude/hooks/ ← → .claude/configs/
- .claude/docs/ ← → All secondary docs

### 6.3 Sequenciamento Recomendado
1. Fix CLAUDE.md strategic alignment
2. Update .claude/configs/ completeness
3. Sync .claude/agents/ definitions
4. Implement missing .claude/commands/
5. Deploy .claude/hooks/ per templates
6. Update .claude/docs/ synchronization
```

## 🎯 Critérios de Sucesso

### **Qualidade da Análise**
- ✅ Cobertura completa do escopo definido
- ✅ Identificação precisa de gaps críticos
- ✅ Alinhamento validado com roadmap
- ✅ Recomendações acionáveis e priorizadas

### **Utilidade para Próximas Etapas**
- ✅ Contextos mapeados para planejamento
- ✅ Dependências identificadas claramente
- ✅ Base sólida para roadmap expandido
- ✅ Documentação de referência atualizada

## 🔄 Integration com Outros Commands

### **Fluxo Upstream** (inputs recebidos)
- Configurações iniciais do projeto
- Escopo de análise definido
- Prioridades estratégicas

### **Fluxo Downstream** (outputs para próximos commands)
- `/planejamento-roadmap-expandido` ← recebe diagnóstico completo
- `/executar-roadmap-expandido` ← usa contextos mapeados
- `/validacao-entrega` ← referencia baseline estabelecido

## 🧠 LLM-Friendly Design

### **Structured Information Flow**
```yaml
information_packaging:
  context_preservation: "Todos os contextos mapeados explicitamente"
  dependency_tracking: "Matrix clara de interdependências"
  handoff_optimization: "Outputs estruturados para próximo command"

llm_optimization:
  chunk_size: "Seções digestíveis para processamento"
  reference_links: "Links explícitos para documentação"
  decision_points: "Critérios claros para escolhas"
```

### **Error Handling & Recovery**
```yaml
fallback_strategies:
  missing_docs: "Pesquisa em fontes oficiais da tecnologia"
  incomplete_analysis: "Documentação de limitações encontradas"
  conflicting_info: "Registrar inconsistências para resolução"
```

---

**💡 Dica de Uso**: Este command deve ser sempre o primeiro passo antes de qualquer implementação significativa, garantindo alinhamento completo com a estratégia estabelecida e evidence-based accuracy.

**🔗 Próximo Command**: `/planejamento-roadmap-expandido` (utiliza outputs deste diagnóstico)