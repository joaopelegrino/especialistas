---
argument-hint: [tópico-ou-título-do-artigo]
description: Gera pacote completo de deployment a partir da sessão atual seguindo framework Publish Master
---

# Documentar Sessão como Artigo - Gerador de Pacote de Deployment

## =Ë Validação de Entrada

**Tópico/Título Fornecido:** $ARGUMENTS

```bash
TOPIC="$ARGUMENTS"

if [ -z "$TOPIC" ]; then
  echo "L ERRO: Tópico/título do artigo obrigatório"
  echo ""
  echo "=Ö Uso:"
  echo "   /documentar <tópico ou título>"
  echo ""
  echo "=¡ Exemplos:"
  echo "   /documentar Como Usar Variáveis em Claude Code"
  echo "   /documentar Melhores Práticas para Design de APIs"
  echo "   /documentar Otimizando Consultas de Banco de Dados"
  exit 1
fi

echo " Tópico: $TOPIC"
echo " Analisando sessão atual..."
```

---

## <¯ Missão

Você é um **especialista em publicação** seguindo o **framework Publish Master Agent**. Sua tarefa é analisar TODA ESTA SESSÃO e gerar um pacote completo de deployment para um artigo.

**Tópico:** $ARGUMENTS

---

## =Ê Fase 1: Análise da Sessão e Coleta de Informações

### 1.1 Analisar Sessão Atual

Revise TODA esta conversa e extraia:

**Problema/Dor:**
- Qual problema estava sendo resolvido?
- Qual dor foi identificada?
- Quais erros/equívocos estavam sendo corrigidos?

**Solução Desenvolvida:**
- Qual solução foi implementada?
- Quais abordagens foram testadas/validadas?
- Quais melhores práticas foram estabelecidas?

**Descobertas Principais:**
- O que foi aprendido durante a sessão?
- Quais insights surgiram?
- Quais dados foram quantificados?

**Fontes Utilizadas:**
- Consultas WebSearch e resultados
- Operações WebFetch e descobertas
- Documentação consultada
- Ferramentas/comandos executados
- Arquivos criados/modificados

**Métricas e Evidências:**
- Linhas de código escritas/modificadas
- Arquivos criados/editados
- Comparações antes/depois
- Taxas de sucesso/falha
- Estimativas de tempo/esforço

### 1.2 Extrair Dados de Pesquisa

Documente todas as fontes usadas:

**Documentação Oficial:**
- [ ] Listar todos os docs oficiais referenciados
- [ ] URLs com datas de acesso
- [ ] Informações-chave extraídas
- [ ] Citações utilizadas

**Recursos da Comunidade:**
- [ ] Posts de blog, tutoriais consultados
- [ ] Repositórios GitHub referenciados
- [ ] Discussões em fóruns
- [ ] Opiniões de especialistas

**Evidências Internas:**
- [ ] Exemplos de código da sessão
- [ ] Outputs de comandos
- [ ] Mensagens de erro e correções
- [ ] Métricas coletadas

### 1.3 Identificar Público-Alvo e Palavras-Chave

**Baseado no conteúdo da sessão:**
- Quem se beneficiaria deste artigo?
- Quais problemas ele resolve?
- Quais consultas de busca levariam até aqui?

**Palavra-chave primária:** [Inferir do tópico e conteúdo]
**Palavras-chave secundárias:** [3-5 termos relacionados]
**Oportunidades long-tail:** [Frases específicas]

---

## =Ý Fase 2: Gerar Estrutura do Artigo

Criar artigo abrangente seguindo **framework Publish Master**:

### Componentes do Artigo Obrigatórios:

1. **Frontmatter (YAML)**
   ```yaml
   ---
   title: "[SEO-otimizado 55-60 chars]"
   description: "[Meta descrição 150-160 chars]"
   keywords: "[primária], [secundária1], [secundária2]"
   author: "Equipe de Desenvolvimento"
   date: "[YYYY-MM-DD]"
   updated: "[YYYY-MM-DD]"
   ---
   ```

2. **Bloco TL;DR** (50 palavras máx)
   - Conclusões principais
   - Números/resultados específicos
   - Qual problema é resolvido

3. **Bloco Resposta-Primeiro** (50 palavras máx)
   - Resposta direta à consulta principal
   - Pontos de dados específicos
   - Imediatamente acionável

4. **Índice**
   - Todas as seções principais linkadas

5. **Seções de Conteúdo Principal:**
   - **Declaração do Problema** (o que estava errado?)
   - **Visão Geral da Solução** (o que corrigiu?)
   - **Abordagens Detalhadas** (como implementar?)
   - **Estudo de Caso** (evidências DESTA sessão)
   - **Guia de Implementação** (passo a passo)
   - **Troubleshooting** (erros comuns)
   - **Framework de Decisão** (quando usar o quê?)
   - **FAQ** (10 perguntas mínimo)

6. **Principais Conclusões** (5-7 bullet points com emojis)

7. **Próximos Passos** (Imediatos, Curto prazo, Médio prazo)

8. **Recursos e Ferramentas**

9. **Fontes** (Todas 10+ documentadas)

**Meta:** 3.000-3.500 palavras

---

## =Â Fase 3: Gerar Pacote Completo de Deployment

Criar **10 arquivos** no diretório `posts/[slug]/`:

### Arquivo 1: article.md
- Artigo completo (3.000-3.500 palavras)
- Formatado em Markdown
- Exemplos de código incluídos
- Tabelas e diagramas
- FAQ com tags details
- Estruturado para SEO + LLMO

### Arquivo 2: llms.txt
- Entrada para llms.txt raiz
- Descrição otimizada para descoberta por LLM
- Palavras-chave para citação de IA
- Consultas-alvo listadas
- Política de atualização

### Arquivo 3: robots.txt
- Documento de verificação
- Configuração recomendada
- Política de acesso para crawlers de IA
- Instruções de teste
- Orientação de monitoramento

### Arquivo 4: sitemap.xml
- Entrada XML para URL do artigo
- Prioridade: 0.9 (conteúdo de alto valor)
- Changefreq: monthly
- Markup de imagem se aplicável
- Instruções de integração

### Arquivo 5: meta_tags.json
- Configuração completa de meta:
  - SEO: title (55-60 chars), description (150-160 chars), keywords
  - Open Graph: og:title, og:description, og:image, etc.
  - Twitter Cards: config completo
  - Metadata do artigo: autor, datas, tags
  - Performance: preload/prefetch
  - Analytics: config de tracking
  - Checklist de validação

### Arquivo 6: structured_data.json
- Schemas JSON-LD:
  - Schema Article (campos obrigatórios)
  - Schema FAQPage (10+ FAQs)
  - Schema HowTo (se aplicável)
  - Schema BreadcrumbList
- Notas de implementação
- Checklist de validação
- Rich results esperados

### Arquivo 7: DEPLOYMENT_CHECKLIST.md
- Pré-deployment (conteúdo, SEO, técnico)
- Passos de deployment (arquivos, config, testes)
- Pós-deployment (monitoramento, semana 1, mês 1)
- Métricas de sucesso
- Plano de rollback
- Avaliação de risco

### Arquivo 8: SOURCES.md
- Todas as fontes documentadas:
  - Docs oficiais (com URLs, datas)
  - Recursos da comunidade
  - Estudo de caso interno
  - Evidências desta sessão
- Processo de verificação
- Avaliação de qualidade
- Informações de arquivo
- Instruções de atualização

### Arquivo 9: UPDATE_SCHEDULE.md
- Frequência de atualização (mensal/trimestral/anual)
- Gatilhos para atualizações ad-hoc
- Checklist mensal
- Revisão profunda trimestral
- Plano de refresh anual
- Histórico de versões
- Configuração de monitoramento
- Responsáveis

### Arquivo 10: SUMMARY.md
- Resumo executivo:
  - Visão geral do pacote (10 arquivos)
  - Estatísticas do artigo
  - Alvos SEO/LLMO
  - Projeções de performance
  - Atualizações de configuração necessárias
  - Ações pré-deployment
  - Passos de deployment
  - Métricas de sucesso
  - Análise de ROI
  - Avaliação de risco
  - Status de aprovação final

---

## =Ê Fase 4: Gerar Dados de Suporte

### Quantificar Tudo:

Extrair da sessão:
- **Linhas de código:** [contar dos edits]
- **Arquivos modificados:** [listar todos]
- **Comandos executados:** [contar Bash, Read, Edit, Write]
- **Fontes consultadas:** [contagem WebSearch + WebFetch]
- **Tempo investido:** [estimar do tamanho da sessão]
- **Métricas antes/depois:** [se aplicável]

### Escrita Baseada em Evidências:

-  TODA afirmação respaldada por evidência da sessão
-  TODA estatística verificada e com fonte
-  TODO exemplo de código testado na sessão
-  TODA URL de fonte incluída e datada
-  ZERO afirmações sem suporte

---

##  Fase 5: Garantia de Qualidade

### Checklist de Qualidade de Conteúdo:

- [ ] **Resposta-primeiro:** Primeiras 50 palavras respondem consulta principal
- [ ] **Rico em dados:** 20+ números/métricas específicos
- [ ] **Baseado em evidências:** Todas afirmações da sessão ou fontes
- [ ] **Prático:** 10+ exemplos de código
- [ ] **Completo:** 3.000+ palavras abrangentes
- [ ] **Estruturado:** Hierarquia e fluxo claros
- [ ] **Acionável:** Guias passo a passo
- [ ] **Referenciado:** 10+ fontes documentadas

### Checklist SEO:

- [ ] Meta título 55-60 caracteres
- [ ] Meta descrição 150-160 caracteres
- [ ] Palavra-chave primária em H1, primeiras 100 palavras
- [ ] Links internos (3+ a serem adicionados)
- [ ] Texto alt de imagens (quando imagens adicionadas)
- [ ] Slug de URL limpo e rico em palavras-chave
- [ ] Dados estruturados válidos

### Checklist LLMO:

- [ ] Estrutura resposta-primeiro (imediatamente útil)
- [ ] Tabelas de comparação (extração fácil)
- [ ] Frameworks de decisão (acionáveis)
- [ ] Formato FAQ (correspondência de consulta)
- [ ] Atribuição de fonte (credibilidade)
- [ ] Pontos de dados (citabilidade)

### Checklist Técnico:

- [ ] Todos os 10 arquivos gerados
- [ ] Todos os placeholders documentados ([SEU-DOMINIO], etc.)
- [ ] Schemas validam (schema.org)
- [ ] Frontmatter YAML correto
- [ ] Exemplos de código com syntax highlight
- [ ] Todos os links formatados corretamente

---

## =Á Estrutura de Saída

Gerar arquivos nesta estrutura:

```
posts/[article-slug]/
   article.md                    # Artigo principal
   llms.txt                      # Entrada para descoberta LLM
   robots.txt                    # Verificação de crawler IA
   sitemap.xml                   # Entrada para mecanismo de busca
   meta_tags.json                # Metadata SEO/LLMO
   structured_data.json          # Schemas de rich results
   DEPLOYMENT_CHECKLIST.md       # Processo de deploy
   SOURCES.md                    # Docs de referência
   UPDATE_SCHEDULE.md            # Plano de manutenção
   SUMMARY.md                    # Resumo executivo
```

**Article slug:** Gerar de `$ARGUMENTS` (minúsculas, hífens, sem caracteres especiais)

---

## <¯ Critérios de Sucesso

### Pacote Completo Quando:

1.  Todos os 10 arquivos gerados e salvos
2.  Artigo tem 3.000-3.500 palavras
3.  10+ fontes documentadas
4.  Todas as métricas da sessão incluídas
5.  Exemplos de código testados (da sessão)
6.  SEO otimizado (meta tags corretas)
7.  LLMO otimizado (resposta-primeiro, rico em dados)
8.  Schemas válidos (4 tipos JSON-LD)
9.  Checklists completos
10.  Summary mostra status READY

### Quality Gates:

- **Precisão:** Todos os fatos verificados contra a sessão
- **Completude:** Nenhuma seção faltando
- **Acionabilidade:** Próximos passos claros
- **Evidência:** Todas afirmações respaldadas por dados
- **Profissionalismo:** Qualidade pronta para publicação

---

## =€ Instruções de Execução

### Passo 1: Analisar Esta Sessão
- Revisar conversa inteira desde o início
- Extrair problema, solução, evidências
- Documentar todas as fontes (WebSearch, WebFetch, docs)
- Quantificar todas as métricas (LOC, arquivos, comandos)

### Passo 2: Estruturar Artigo
- Criar outline com todas as 9 seções
- Escrever bloco resposta-primeiro
- Desenvolver estudo de caso da sessão
- Escrever FAQ abrangente

### Passo 3: Gerar Pacote
- Criar diretório: `posts/[slug]/`
- Gerar todos os 10 arquivos sequencialmente
- Usar ferramenta Write para cada arquivo
- Validar conforme avança

### Passo 4: Verificação de Qualidade
- Verificar contagem de palavras (3.000-3.500)
- Validar todos os schemas
- Verificar todos os checklists
- Garantir que todos os placeholders estejam documentados

### Passo 5: Relatório de Resumo
- Contar arquivos (deve ser 10)
- Reportar estatísticas do artigo
- Listar ações pré-deployment
- Fornecer status de aprovação final

---

## =Ý Instruções Especiais

### Coleta de Evidências:

Desta sessão, extrair:
- **Consultas WebSearch:** [Listar todas com resultados]
- **Operações WebFetch:** [URLs buscadas]
- **Arquivos criados:** [Listar com contagens de linhas]
- **Arquivos modificados:** [Listar com mudanças]
- **Comandos executados:** [Contar por tipo]
- **Erros encontrados:** [E como corrigidos]
- **Decisões tomadas:** [E justificativa]
- **Métricas coletadas:** [Todos os números]

### Formato de Estudo de Caso:

Usar ESTA sessão como estudo de caso:
- **Contexto:** [Qual era o projeto/tarefa?]
- **Problema:** [O que não estava funcionando?]
- **Solução:** [Qual abordagem foi escolhida?]
- **Implementação:** [Passo a passo do que foi feito]
- **Resultados:** [Resultados quantificados]
- **Lições:** [O que foi aprendido]

### Documentação de Fontes:

Para CADA fonte:
- Título completo
- Autor/Organização
- Data de publicação/acesso
- URL completa
- Que informação foi usada
- Onde foi citada
- Como foi validada

---

##   Requisitos Críticos

### Obrigatórios:

1. **Zero fabricação:** Use apenas informações desta sessão ou fontes verificadas
2. **Atribuição completa:** Toda fonte documentada
3. **Afirmações quantificadas:** Todo número respaldado por evidência
4. **Exemplos testados:** Todo código desta sessão
5. **Datas atuais:** Use data real (verifique sistema)
6. **Projeções realistas:** Baseadas em performance de conteúdo similar

### Proibições:

1. L NÃO inventar estatísticas
2. L NÃO citar fontes não usadas realmente
3. L NÃO fazer afirmações sem suporte
4. L NÃO pular etapas de validação
5. L NÃO gerar pacote parcial

---

## =Ê Entrega Final

Após gerar todos os 10 arquivos, fornecer:

**Relatório de Resumo:**

```
 PACOTE DE DEPLOYMENT GERADO

=Á Localização: posts/[slug]/
=Ä Arquivos: 10/10 completos

=Ê Estatísticas do Artigo:
- Contagem de palavras: [count]
- Seções: [count]
- Exemplos de código: [count]
- FAQs: [count]
- Fontes: [count]

<¯ Verificações de Qualidade:
- SEO otimizado: [/L]
- LLMO otimizado: [/L]
- Schemas válidos: [/L]
- Baseado em evidências: [/L]

=€ Status: [READY/NEEDS WORK]

=Ë Ações Pré-Deployment:
1. [Ação 1]
2. [Ação 2]
...

Próximo Passo: Revisar SUMMARY.md para guia completo de deployment
```

---

## <“ Aprendizado Desta Sessão

Este comando foi criado com base em aprendizados de uma sessão real sobre:
- Sintaxe correta de variáveis em Claude Code ($ARGUMENTS vs ${VARIABLE})
- Criação de pacote de deployment
- Framework Publish Master Agent
- Estratégias de otimização SEO + LLMO
- Escrita técnica baseada em evidências

**Nota Meta:** Este comando demonstra o uso correto de `$ARGUMENTS` para capturar tópico do artigo! <¯

---

**Versão do Comando:** 1.0
**Criado:** 2025-10-07
**Framework:** Publish Master Agent
**Propósito:** Automatizar criação de pacotes abrangentes de deployment de artigos a partir de sessões de desenvolvimento
