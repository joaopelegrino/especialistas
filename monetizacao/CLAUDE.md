# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Visão Geral do Projeto

Este é um projeto abrangente de documentação cobrindo **monetização Pay-Per-Crawl** - um modelo de negócio onde editores de conteúdo cobram empresas de IA por cada acesso ao seu conteúdo. O projeto analisa o mercado emergente de US$2-3,5 bilhões onde editores estão implementando paywalls para crawlers de IA como GPTBot, ClaudeBot e ChatGPT.

## Arquitetura da Documentação

O projeto segue uma **abordagem de documentação estruturada em 9 camadas** cobrindo o ecossistema completo de pay-per-crawl:

### Estrutura Central da Documentação
- **Camada 1**: `README.md` - Visão executiva com números de mercado e início rápido
- **Camadas 2-9**: Arquivos de documentação numerados (01-09) cobrindo domínios específicos:
  - Conceitos fundamentais e economia de crawlers
  - Infraestrutura técnica (Cloudflare Workers, detecção de bots)
  - Modelos de negócio e análise de acordos bilionários
  - Código de implementação pronto para produção
  - Conformidade legal (GDPR, EU AI Act, CFAA)
  - Análise de mercado e projeções de crescimento
  - Medidas de segurança e anti-fraude
  - Frameworks de decisão para editores
  - Recursos e referências técnicas

### Padrões e Normas de Conteúdo

**Referências de Preços**: Todos os valores monetários usam faixas específicas:
- Preços por requisição: US$0,001-0,05
- Acordos anuais: faixa de US$10M-250M
- Projeções de mercado: US$2-3,5 bilhões até 2030

**Implementação Técnica**: Duas abordagens arquiteturais principais:
1. **Baseada em Cloudflare**: Workers, Bot Management, processamento de borda
2. **Soluções customizadas**: Node.js, Express, integrações de pagamento

**Inteligência de Negócios**: O conteúdo inclui:
- Dados reais de transações da News Corp ($250M), Reddit ($203M), etc.
- Razões crawler-para-referência (ClaudeBot: 73.000:1)
- Métricas técnicas (46M requisições/segundo, 330+ locais de borda)

### Estilo e Tom de Escrita

**Abordagem**: Documentação empresarial de nível executivo com profundidade técnica
- Liderar com números concretos e dados de mercado
- Incluir exemplos de código prontos para produção
- Equilibrar estratégia de negócios com detalhes de implementação
- Referenciar empresas reais e valores de acordos reais

**Convenções de Formatação**:
- Usar cabeçalhos de seção com emoji (🎯, 💰, ⚙️, etc.)
- Incluir diagramas mermaid para fluxos técnicos
- Blocos de código com exemplos de implementação real
- Tabelas para análise comparativa e matrizes de decisão

## Fluxo de Desenvolvimento

**Atualizações de Conteúdo**: Ao atualizar documentação:
1. Manter precisão numérica em dados de mercado e preços
2. Manter exemplos técnicos prontos para produção e testáveis
3. Atualizar referências cruzadas entre seções relacionadas
4. Preservar a abordagem estruturada de 9 camadas

**Exemplos de Código**: Todo código deve ser:
- Pronto para produção (não pseudo-código)
- Incluir tratamento de erros e medidas de segurança
- Seguir padrões do mundo real dos ecossistemas Cloudflare/Node.js
- Incluir instruções de deploy

## Contexto de Negócio Essencial

Este projeto documenta um **mercado em rápida evolução** onde:
- 73% dos principais sites de notícias já bloqueiam crawlers de IA
- Maior acordo conhecido: News Corp + OpenAI ($250M ao longo de 5 anos)
- Desafio técnico: Processar milhões de requisições de crawlers com latência <100μs
- Complexidade legal: Conformidade GDPR com penalidades de até 7% da receita

Ao trabalhar com este conteúdo, priorize **precisão dos dados financeiros** e **implementabilidade das soluções técnicas** pois esta documentação serve tanto a tomadores de decisão empresariais quanto implementadores técnicos em um mercado de alto risco.

## Manutenção de Conteúdo

**Referências Cruzadas**: Cada arquivo numerado conecta-se aos outros através de relações empresariais e técnicas. Ao atualizar um arquivo, verifique seções relacionadas em outros.

**Dados de Mercado**: Figuras financeiras e estatísticas de crawlers mudam frequentemente. Verifique condições atuais de mercado ao atualizar conteúdo.

**Conformidade**: Seções legais referenciam regulamentações específicas. Mudanças no GDPR, CFAA ou EU AI Act podem exigir atualizações em múltiplos arquivos.

## Engenharia Agêntica e Otimização de Primitivos

### Instruções para Otimização Durante Interações

Durante cada interação com o usuário, você deve **ATIVAMENTE** elaborar propostas de otimização para as primitivas fundamentais da ferramenta Claude Code:

#### 1. Contexto (Primitive de Contexto)
**Proposta de Otimização**: Analise o contexto atual e sugira:
- Informações adicionais relevantes que poderiam melhorar a resposta
- Dados de mercado atualizados que devem ser incorporados
- Referências cruzadas entre documentos que enriquecem o contexto
- Métodos para injeção de contexto dinâmico baseado no histórico da sessão

#### 2. Modelo (Primitive de Modelo)
**Proposta de Otimização**: Avalie e recomende:
- Escolha de modelo mais adequada para a tarefa específica (Sonnet vs Opus vs Haiku)
- Estratégias de switching de modelo baseado na complexidade da requisição
- Configurações de temperatura e parâmetros para máxima eficiência
- Uso de sub-agentes especializados quando apropriado

#### 3. Prompt (Primitive de Prompt)
**Proposta de Otimização**: Refinamento contínuo de:
- Estrutura do prompt para máxima taxa de informação
- Output styles personalizados para diferentes tipos de consulta
- Injeção de instruções específicas do domínio pay-per-crawl
- Técnicas de few-shot learning com exemplos do mercado real

### Framework de Otimização Contínua

**A CADA RESPOSTA**, inclua uma seção dedicada:

```markdown
## 🔧 Otimizações Propostas para esta Sessão

### Contexto
- [Proposta específica de melhoria de contexto]

### Modelo  
- [Recomendação de ajuste de modelo]

### Prompt
- [Sugestão de refinamento de prompt]
```

### Princípios de Engenharia Agêntica

Siga os princípios fundamentais identificados na pesquisa avançada:

1. **Controle Determinístico**: Mantenha controle explícito sobre as três primitivas
2. **Flexibilidade Máxima**: Evite opiniões pré-definidas sobre uso
3. **Composição sobre Configuração**: Prefira sistemas componíveis
4. **Taxa de Informação Máxima**: Otimize para densidade informacional
5. **UI Generativa**: Considere outputs visuais quando apropriado

### Métricas de Performance

Rastre continuamente:
- **Precisão**: Dados financeiros e técnicos corretos
- **Implementabilidade**: Código pronto para produção
- **Relevância**: Alinhamento com necessidades do mercado
- **Eficiência**: Redução de tokens sem perda de qualidade
- **Composição**: Capacidade de combinar com outros agentes/tools

## Extensão de Capacidades Nativas Durante Interações

### Instruções para Identificação de Necessidades de Funcionalidades

Durante interações com usuários, **SEMPRE IDENTIFIQUE** oportunidades para expandir capacidades nativas através de:

#### 1. **Detecção de Padrões Repetitivos**
Quando identificar que o usuário:
- **Faz perguntas similares repetidamente** → Propor hook UserPromptSubmit para injeção automática de contexto
- **Precisa de dados atualizados frequentemente** → Sugerir hook que integre APIs externas
- **Valida informações manualmente** → Recomendar hook de validação automatizada

**Exemplo de Detecção**:
```
Usuário pergunta: "Qual o preço atual por crawl?"
↓
Identificar: Necessidade recorrente de dados de mercado
↓
Propor: Hook que injeta pricing atual automaticamente
```

#### 2. **Identificação de Deficiências de Output**
Quando notar que respostas padrão não atendem eficientemente:
- **Usuário executivo** precisa de métricas de negócio → Output style dashboard-executivo
- **Usuário técnico** quer código pronto → Output style implementação-técnica  
- **Consulta específica** requer estrutura particular → Output style customizado

**Exemplo de Implementação**:
```markdown
## Como Propor Output Style

**Cenário Detectado**: "Usuário sempre pergunta sobre ROI e implementação técnica juntos"

**Proposta**: "Posso criar um output style que automaticamente inclui:
- Cálculo de ROI
- Código de implementação 
- Timeline de deploy
- Métricas de monitoramento

Isso otimizaria suas consultas futuras. Quer que eu implemente?"
```

#### 3. **Reconhecimento de Necessidades de Sub-Agentes**
Identifique quando tarefas específicas se beneficiariam de especialização:
- **Pesquisa jurídica** → Sub-agente compliance especializado
- **Análise de mercado** → Sub-agente market-intelligence
- **Geração de código** → Sub-agente tech-implementation

#### 4. **Oportunidades de Status Line Enhancement**
Quando o contexto da sessão seria útil persistir:
- **Projetos longos** → Status line com progresso do projeto
- **Múltiplas instâncias** → Status line com identificação única
- **Contexto crítico** → Status line com informações de estado essencial

### Metodologia de Proposta de Funcionalidades

#### Estrutura Padrão para Propostas:

```markdown
## 🚀 Oportunidade de Otimização Detectada

**Padrão Identificado**: [Descrever o que observou]

**Limitação Atual**: [Como o fluxo atual não é ideal]

**Solução Proposta**: [Tipo de funcionalidade - Hook/Output Style/Sub-agente/Status Line]

**Implementação**: 
```python/markdown
[Código exemplo da solução]
```

**Benefícios do Workflow**:
- Redução de X% no tempo de consulta
- Automação de Y processo manual
- Melhoria Z na precisão/consistência

**Próximos Passos**:
1. [Implementar funcionalidade]
2. [Testar em cenários similares]
3. [Iterar baseado em feedback]
```

### Gatilhos de Detecção Específicos para Pay-Per-Crawl

#### Padrões que Indicam Necessidade de Hooks:
- **"Preciso dos dados mais recentes de..."** → MarketDataInjection Hook
- **"Isso está em conformidade com..."** → ComplianceValidation Hook  
- **"Qual seria o ROI de..."** → ROICalculation Hook
- **"Como implementar... de forma segura"** → SecurityValidation Hook

#### Padrões que Indicam Necessidade de Output Styles:
- **Perguntas executivas** (ROI, estratégia, mercado) → Executive-Dashboard Style
- **Perguntas técnicas** (código, arquitetura, deploy) → Technical-Implementation Style
- **Perguntas de pesquisa** (tendências, competidores) → Market-Analysis Style
- **Necessidade visual** (gráficos, dashboards) → GenUI Style

#### Padrões que Indicam Necessidade de Sub-Agentes:
- **Tarefas especializadas recorrentes** → Sub-agente dedicado
- **Pesquisa intensiva** → Research Sub-agente
- **Validações complexas** → Validation Sub-agente
- **Geração de múltiplos artefatos** → Multi-output Sub-agente

#### Padrões que Indicam Necessidade de Status Lines:
- **Múltiplas sessões simultâneas** → Identificação de contexto
- **Projetos de longo prazo** → Tracking de progresso
- **Informações críticas recorrentes** → Display persistente
- **Coordenação entre instâncias** → State sharing

### Implementação Proativa das Propostas

#### Processo de Implementação:
1. **Detectar** o padrão durante a interação
2. **Explicar** a oportunidade ao usuário  
3. **Propor** a solução específica com exemplo
4. **Implementar** se o usuário concordar
5. **Validar** funcionamento em caso de uso real
6. **Iterar** baseado no feedback

#### Princípios de Design:
- **Composabilidade**: Funcionalidades que se integram naturalmente
- **Transparência**: Usuário entende o que cada funcionalidade faz
- **Controle**: Usuário mantém controle sobre quando usar
- **Eficiência**: Redução mensurável de friction no workflow
- **Especificidade**: Otimizada para o domínio pay-per-crawl

### Exemplo de Detecção e Proposta em Ação:

```
USUÁRIO: "Me mostre como implementar rate limiting para GPTBot e também me diga qual seria o ROI esperado"

DETECÇÃO: 
- Pergunta técnica + pergunta de negócio juntas
- Padrão comum para este domínio
- Opportunity para output style híbrido

PROPOSTA AUTOMÁTICA:
"Notei que você frequentemente combina perguntas técnicas com análise de ROI. 
Posso criar um output style 'Technical-Business-Hybrid' que sempre inclui:
- Implementação técnica completa
- Cálculo de ROI automático  
- Timeline de deployment
- Métricas de monitoramento

Isso otimizaria consultas futuras similares. Implemento agora?"
```
