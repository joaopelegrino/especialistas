---
argument-hint: [t�pico-ou-t�tulo-do-artigo]
description: Gera pacote completo de deployment a partir da sess�o atual seguindo framework Publish Master
---

# Documentar Sess�o como Artigo - Gerador de Pacote de Deployment

## =� Valida��o de Entrada

**T�pico/T�tulo Fornecido:** $ARGUMENTS

```bash
TOPIC="$ARGUMENTS"

if [ -z "$TOPIC" ]; then
  echo "L ERRO: T�pico/t�tulo do artigo obrigat�rio"
  echo ""
  echo "=� Uso:"
  echo "   /documentar <t�pico ou t�tulo>"
  echo ""
  echo "=� Exemplos:"
  echo "   /documentar Como Usar Vari�veis em Claude Code"
  echo "   /documentar Melhores Pr�ticas para Design de APIs"
  echo "   /documentar Otimizando Consultas de Banco de Dados"
  exit 1
fi

echo " T�pico: $TOPIC"
echo " Analisando sess�o atual..."
```

---

## <� Miss�o

Voc� � um **especialista em publica��o** seguindo o **framework Publish Master Agent**. Sua tarefa � analisar TODA ESTA SESS�O e gerar um pacote completo de deployment para um artigo.

**T�pico:** $ARGUMENTS

---

## =� Fase 1: An�lise da Sess�o e Coleta de Informa��es

### 1.1 Analisar Sess�o Atual

Revise TODA esta conversa e extraia:

**Problema/Dor:**
- Qual problema estava sendo resolvido?
- Qual dor foi identificada?
- Quais erros/equ�vocos estavam sendo corrigidos?

**Solu��o Desenvolvida:**
- Qual solu��o foi implementada?
- Quais abordagens foram testadas/validadas?
- Quais melhores pr�ticas foram estabelecidas?

**Descobertas Principais:**
- O que foi aprendido durante a sess�o?
- Quais insights surgiram?
- Quais dados foram quantificados?

**Fontes Utilizadas:**
- Consultas WebSearch e resultados
- Opera��es WebFetch e descobertas
- Documenta��o consultada
- Ferramentas/comandos executados
- Arquivos criados/modificados

**M�tricas e Evid�ncias:**
- Linhas de c�digo escritas/modificadas
- Arquivos criados/editados
- Compara��es antes/depois
- Taxas de sucesso/falha
- Estimativas de tempo/esfor�o

### 1.2 Extrair Dados de Pesquisa

Documente todas as fontes usadas:

**Documenta��o Oficial:**
- [ ] Listar todos os docs oficiais referenciados
- [ ] URLs com datas de acesso
- [ ] Informa��es-chave extra�das
- [ ] Cita��es utilizadas

**Recursos da Comunidade:**
- [ ] Posts de blog, tutoriais consultados
- [ ] Reposit�rios GitHub referenciados
- [ ] Discuss�es em f�runs
- [ ] Opini�es de especialistas

**Evid�ncias Internas:**
- [ ] Exemplos de c�digo da sess�o
- [ ] Outputs de comandos
- [ ] Mensagens de erro e corre��es
- [ ] M�tricas coletadas

### 1.3 Identificar P�blico-Alvo e Palavras-Chave

**Baseado no conte�do da sess�o:**
- Quem se beneficiaria deste artigo?
- Quais problemas ele resolve?
- Quais consultas de busca levariam at� aqui?

**Palavra-chave prim�ria:** [Inferir do t�pico e conte�do]
**Palavras-chave secund�rias:** [3-5 termos relacionados]
**Oportunidades long-tail:** [Frases espec�ficas]

---

## =� Fase 2: Gerar Estrutura do Artigo

Criar artigo abrangente seguindo **framework Publish Master**:

### Componentes do Artigo Obrigat�rios:

1. **Frontmatter (YAML)**
   ```yaml
   ---
   title: "[SEO-otimizado 55-60 chars]"
   description: "[Meta descri��o 150-160 chars]"
   keywords: "[prim�ria], [secund�ria1], [secund�ria2]"
   author: "Equipe de Desenvolvimento"
   date: "[YYYY-MM-DD]"
   updated: "[YYYY-MM-DD]"
   ---
   ```

2. **Bloco TL;DR** (50 palavras m�x)
   - Conclus�es principais
   - N�meros/resultados espec�ficos
   - Qual problema � resolvido

3. **Bloco Resposta-Primeiro** (50 palavras m�x)
   - Resposta direta � consulta principal
   - Pontos de dados espec�ficos
   - Imediatamente acion�vel

4. **�ndice**
   - Todas as se��es principais linkadas

5. **Se��es de Conte�do Principal:**
   - **Declara��o do Problema** (o que estava errado?)
   - **Vis�o Geral da Solu��o** (o que corrigiu?)
   - **Abordagens Detalhadas** (como implementar?)
   - **Estudo de Caso** (evid�ncias DESTA sess�o)
   - **Guia de Implementa��o** (passo a passo)
   - **Troubleshooting** (erros comuns)
   - **Framework de Decis�o** (quando usar o qu�?)
   - **FAQ** (10 perguntas m�nimo)

6. **Principais Conclus�es** (5-7 bullet points com emojis)

7. **Pr�ximos Passos** (Imediatos, Curto prazo, M�dio prazo)

8. **Recursos e Ferramentas**

9. **Fontes** (Todas 10+ documentadas)

**Meta:** 3.000-3.500 palavras

---

## =� Fase 3: Gerar Pacote Completo de Deployment

Criar **10 arquivos** no diret�rio `posts/[slug]/`:

### Arquivo 1: article.md
- Artigo completo (3.000-3.500 palavras)
- Formatado em Markdown
- Exemplos de c�digo inclu�dos
- Tabelas e diagramas
- FAQ com tags details
- Estruturado para SEO + LLMO

### Arquivo 2: llms.txt
- Entrada para llms.txt raiz
- Descri��o otimizada para descoberta por LLM
- Palavras-chave para cita��o de IA
- Consultas-alvo listadas
- Pol�tica de atualiza��o

### Arquivo 3: robots.txt
- Documento de verifica��o
- Configura��o recomendada
- Pol�tica de acesso para crawlers de IA
- Instru��es de teste
- Orienta��o de monitoramento

### Arquivo 4: sitemap.xml
- Entrada XML para URL do artigo
- Prioridade: 0.9 (conte�do de alto valor)
- Changefreq: monthly
- Markup de imagem se aplic�vel
- Instru��es de integra��o

### Arquivo 5: meta_tags.json
- Configura��o completa de meta:
  - SEO: title (55-60 chars), description (150-160 chars), keywords
  - Open Graph: og:title, og:description, og:image, etc.
  - Twitter Cards: config completo
  - Metadata do artigo: autor, datas, tags
  - Performance: preload/prefetch
  - Analytics: config de tracking
  - Checklist de valida��o

### Arquivo 6: structured_data.json
- Schemas JSON-LD:
  - Schema Article (campos obrigat�rios)
  - Schema FAQPage (10+ FAQs)
  - Schema HowTo (se aplic�vel)
  - Schema BreadcrumbList
- Notas de implementa��o
- Checklist de valida��o
- Rich results esperados

### Arquivo 7: DEPLOYMENT_CHECKLIST.md
- Pr�-deployment (conte�do, SEO, t�cnico)
- Passos de deployment (arquivos, config, testes)
- P�s-deployment (monitoramento, semana 1, m�s 1)
- M�tricas de sucesso
- Plano de rollback
- Avalia��o de risco

### Arquivo 8: SOURCES.md
- Todas as fontes documentadas:
  - Docs oficiais (com URLs, datas)
  - Recursos da comunidade
  - Estudo de caso interno
  - Evid�ncias desta sess�o
- Processo de verifica��o
- Avalia��o de qualidade
- Informa��es de arquivo
- Instru��es de atualiza��o

### Arquivo 9: UPDATE_SCHEDULE.md
- Frequ�ncia de atualiza��o (mensal/trimestral/anual)
- Gatilhos para atualiza��es ad-hoc
- Checklist mensal
- Revis�o profunda trimestral
- Plano de refresh anual
- Hist�rico de vers�es
- Configura��o de monitoramento
- Respons�veis

### Arquivo 10: SUMMARY.md
- Resumo executivo:
  - Vis�o geral do pacote (10 arquivos)
  - Estat�sticas do artigo
  - Alvos SEO/LLMO
  - Proje��es de performance
  - Atualiza��es de configura��o necess�rias
  - A��es pr�-deployment
  - Passos de deployment
  - M�tricas de sucesso
  - An�lise de ROI
  - Avalia��o de risco
  - Status de aprova��o final

---

## =� Fase 4: Gerar Dados de Suporte

### Quantificar Tudo:

Extrair da sess�o:
- **Linhas de c�digo:** [contar dos edits]
- **Arquivos modificados:** [listar todos]
- **Comandos executados:** [contar Bash, Read, Edit, Write]
- **Fontes consultadas:** [contagem WebSearch + WebFetch]
- **Tempo investido:** [estimar do tamanho da sess�o]
- **M�tricas antes/depois:** [se aplic�vel]

### Escrita Baseada em Evid�ncias:

-  TODA afirma��o respaldada por evid�ncia da sess�o
-  TODA estat�stica verificada e com fonte
-  TODO exemplo de c�digo testado na sess�o
-  TODA URL de fonte inclu�da e datada
-  ZERO afirma��es sem suporte

---

##  Fase 5: Garantia de Qualidade

### Checklist de Qualidade de Conte�do:

- [ ] **Resposta-primeiro:** Primeiras 50 palavras respondem consulta principal
- [ ] **Rico em dados:** 20+ n�meros/m�tricas espec�ficos
- [ ] **Baseado em evid�ncias:** Todas afirma��es da sess�o ou fontes
- [ ] **Pr�tico:** 10+ exemplos de c�digo
- [ ] **Completo:** 3.000+ palavras abrangentes
- [ ] **Estruturado:** Hierarquia e fluxo claros
- [ ] **Acion�vel:** Guias passo a passo
- [ ] **Referenciado:** 10+ fontes documentadas

### Checklist SEO:

- [ ] Meta t�tulo 55-60 caracteres
- [ ] Meta descri��o 150-160 caracteres
- [ ] Palavra-chave prim�ria em H1, primeiras 100 palavras
- [ ] Links internos (3+ a serem adicionados)
- [ ] Texto alt de imagens (quando imagens adicionadas)
- [ ] Slug de URL limpo e rico em palavras-chave
- [ ] Dados estruturados v�lidos

### Checklist LLMO:

- [ ] Estrutura resposta-primeiro (imediatamente �til)
- [ ] Tabelas de compara��o (extra��o f�cil)
- [ ] Frameworks de decis�o (acion�veis)
- [ ] Formato FAQ (correspond�ncia de consulta)
- [ ] Atribui��o de fonte (credibilidade)
- [ ] Pontos de dados (citabilidade)

### Checklist T�cnico:

- [ ] Todos os 10 arquivos gerados
- [ ] Todos os placeholders documentados ([SEU-DOMINIO], etc.)
- [ ] Schemas validam (schema.org)
- [ ] Frontmatter YAML correto
- [ ] Exemplos de c�digo com syntax highlight
- [ ] Todos os links formatados corretamente

---

## =� Estrutura de Sa�da

Gerar arquivos nesta estrutura:

```
posts/[article-slug]/
   article.md                    # Artigo principal
   llms.txt                      # Entrada para descoberta LLM
   robots.txt                    # Verifica��o de crawler IA
   sitemap.xml                   # Entrada para mecanismo de busca
   meta_tags.json                # Metadata SEO/LLMO
   structured_data.json          # Schemas de rich results
   DEPLOYMENT_CHECKLIST.md       # Processo de deploy
   SOURCES.md                    # Docs de refer�ncia
   UPDATE_SCHEDULE.md            # Plano de manuten��o
   SUMMARY.md                    # Resumo executivo
```

**Article slug:** Gerar de `$ARGUMENTS` (min�sculas, h�fens, sem caracteres especiais)

---

## <� Crit�rios de Sucesso

### Pacote Completo Quando:

1.  Todos os 10 arquivos gerados e salvos
2.  Artigo tem 3.000-3.500 palavras
3.  10+ fontes documentadas
4.  Todas as m�tricas da sess�o inclu�das
5.  Exemplos de c�digo testados (da sess�o)
6.  SEO otimizado (meta tags corretas)
7.  LLMO otimizado (resposta-primeiro, rico em dados)
8.  Schemas v�lidos (4 tipos JSON-LD)
9.  Checklists completos
10.  Summary mostra status READY

### Quality Gates:

- **Precis�o:** Todos os fatos verificados contra a sess�o
- **Completude:** Nenhuma se��o faltando
- **Acionabilidade:** Pr�ximos passos claros
- **Evid�ncia:** Todas afirma��es respaldadas por dados
- **Profissionalismo:** Qualidade pronta para publica��o

---

## =� Instru��es de Execu��o

### Passo 1: Analisar Esta Sess�o
- Revisar conversa inteira desde o in�cio
- Extrair problema, solu��o, evid�ncias
- Documentar todas as fontes (WebSearch, WebFetch, docs)
- Quantificar todas as m�tricas (LOC, arquivos, comandos)

### Passo 2: Estruturar Artigo
- Criar outline com todas as 9 se��es
- Escrever bloco resposta-primeiro
- Desenvolver estudo de caso da sess�o
- Escrever FAQ abrangente

### Passo 3: Gerar Pacote
- Criar diret�rio: `posts/[slug]/`
- Gerar todos os 10 arquivos sequencialmente
- Usar ferramenta Write para cada arquivo
- Validar conforme avan�a

### Passo 4: Verifica��o de Qualidade
- Verificar contagem de palavras (3.000-3.500)
- Validar todos os schemas
- Verificar todos os checklists
- Garantir que todos os placeholders estejam documentados

### Passo 5: Relat�rio de Resumo
- Contar arquivos (deve ser 10)
- Reportar estat�sticas do artigo
- Listar a��es pr�-deployment
- Fornecer status de aprova��o final

---

## =� Instru��es Especiais

### Coleta de Evid�ncias:

Desta sess�o, extrair:
- **Consultas WebSearch:** [Listar todas com resultados]
- **Opera��es WebFetch:** [URLs buscadas]
- **Arquivos criados:** [Listar com contagens de linhas]
- **Arquivos modificados:** [Listar com mudan�as]
- **Comandos executados:** [Contar por tipo]
- **Erros encontrados:** [E como corrigidos]
- **Decis�es tomadas:** [E justificativa]
- **M�tricas coletadas:** [Todos os n�meros]

### Formato de Estudo de Caso:

Usar ESTA sess�o como estudo de caso:
- **Contexto:** [Qual era o projeto/tarefa?]
- **Problema:** [O que n�o estava funcionando?]
- **Solu��o:** [Qual abordagem foi escolhida?]
- **Implementa��o:** [Passo a passo do que foi feito]
- **Resultados:** [Resultados quantificados]
- **Li��es:** [O que foi aprendido]

### Documenta��o de Fontes:

Para CADA fonte:
- T�tulo completo
- Autor/Organiza��o
- Data de publica��o/acesso
- URL completa
- Que informa��o foi usada
- Onde foi citada
- Como foi validada

---

## � Requisitos Cr�ticos

### Obrigat�rios:

1. **Zero fabrica��o:** Use apenas informa��es desta sess�o ou fontes verificadas
2. **Atribui��o completa:** Toda fonte documentada
3. **Afirma��es quantificadas:** Todo n�mero respaldado por evid�ncia
4. **Exemplos testados:** Todo c�digo desta sess�o
5. **Datas atuais:** Use data real (verifique sistema)
6. **Proje��es realistas:** Baseadas em performance de conte�do similar

### Proibi��es:

1. L N�O inventar estat�sticas
2. L N�O citar fontes n�o usadas realmente
3. L N�O fazer afirma��es sem suporte
4. L N�O pular etapas de valida��o
5. L N�O gerar pacote parcial

---

## =� Entrega Final

Ap�s gerar todos os 10 arquivos, fornecer:

**Relat�rio de Resumo:**

```
 PACOTE DE DEPLOYMENT GERADO

=� Localiza��o: posts/[slug]/
=� Arquivos: 10/10 completos

=� Estat�sticas do Artigo:
- Contagem de palavras: [count]
- Se��es: [count]
- Exemplos de c�digo: [count]
- FAQs: [count]
- Fontes: [count]

<� Verifica��es de Qualidade:
- SEO otimizado: [/L]
- LLMO otimizado: [/L]
- Schemas v�lidos: [/L]
- Baseado em evid�ncias: [/L]

=� Status: [READY/NEEDS WORK]

=� A��es Pr�-Deployment:
1. [A��o 1]
2. [A��o 2]
...

Pr�ximo Passo: Revisar SUMMARY.md para guia completo de deployment
```

---

## <� Aprendizado Desta Sess�o

Este comando foi criado com base em aprendizados de uma sess�o real sobre:
- Sintaxe correta de vari�veis em Claude Code ($ARGUMENTS vs ${VARIABLE})
- Cria��o de pacote de deployment
- Framework Publish Master Agent
- Estrat�gias de otimiza��o SEO + LLMO
- Escrita t�cnica baseada em evid�ncias

**Nota Meta:** Este comando demonstra o uso correto de `$ARGUMENTS` para capturar t�pico do artigo! <�

---

**Vers�o do Comando:** 1.0
**Criado:** 2025-10-07
**Framework:** Publish Master Agent
**Prop�sito:** Automatizar cria��o de pacotes abrangentes de deployment de artigos a partir de sess�es de desenvolvimento
