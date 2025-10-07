# Specialized Agents for Monetization Project

Este diretório contém agentes especializados para o projeto de monetização pay-per-crawl.

## Agentes Disponíveis

### 🎯 Content Ranking Specialist
**Arquivo:** `content-ranking-specialist.md`

**Especialização:** Criação de conteúdo otimizado para ranqueamento em:
- Buscas tradicionais (Google, Bing)
- Plataformas de IA (ChatGPT, Claude, Perplexity)
- AI Overviews e featured snippets

**Quando Usar:**
- Criar novos artigos/guias otimizados
- Atualizar conteúdo existente para melhor ranking
- Gerar content clusters estruturados
- Produzir comparações e how-tos
- Otimizar para citations em LLMs

**Capabilities:**
- Dual optimization (SEO + LLMO)
- Structured data generation (JSON-LD)
- Answer-first architecture
- Citation engineering
- Content refresh strategies

**Exemplo de Uso:**
```
Usando o Content Ranking Specialist, gere um guia completo sobre
"Implementação de Pay-Per-Crawl com Cloudflare Workers" otimizado
para Google e ChatGPT. Target: desenvolvedores e CTOs.
```

---

### 🚀 Publish Master
**Arquivo:** `publish-master.md`

**Especialização:** Finalização e publicação após sessão de pesquisa. Sintetiza research em:
- Artigo completo otimizado (SEO + LLMO)
- Arquivos de configuração (llms.txt, robots.txt, sitemap.xml)
- Structured data (JSON-LD schemas)
- Documentação de deployment (checklists, sources, schedules)

**Quando Usar:**
- **Ao final de sessão de pesquisa** (após WebSearch/WebFetch)
- Depois de alinhar estratégia e coletar fontes
- Quando pronto para produção
- Para consolidar research em outputs acionáveis

**Capabilities:**
- Article synthesis com todas as fontes
- Geração/atualização de llms.txt
- Configuração robots.txt para AI crawlers
- Sitemap.xml regeneration
- Meta tags centralizados
- Structured data completo
- Deployment package com 10 arquivos
- Source documentation
- Update schedules

**Workflow Típico:**
```
[Sessão de 1h incluindo:]
✅ WebSearch sobre tópico X (5-10 searches)
✅ WebFetch de fontes importantes (3-5 fetches)
✅ Discussão e alinhamento de estratégia
✅ Análise competitiva

[Então invocar:]
"Use Publish Master para consolidar nossa pesquisa sobre [tópico]
em artigo production-ready + todos os arquivos de configuração.
Target: [audience], [word count], keyword [primary keyword]"
```

**Output Completo:**
1. ARTICLE.md - Artigo otimizado completo
2. llms.txt - Atualizado com novo conteúdo
3. robots.txt - Revisado/atualizado
4. sitemap.xml - Regenerado
5. meta_tags.json - Configuração centralizada
6. structured_data.json - Todos schemas JSON-LD
7. DEPLOYMENT_CHECKLIST.md - Checklist passo-a-passo
8. SOURCES.md - Todas fontes documentadas
9. UPDATE_SCHEDULE.md - Plano de atualizações
10. DEPLOYMENT_SUMMARY.md - Executive summary

**Exemplo de Uso:**
```
Passamos a última hora pesquisando llms.txt, coletamos 15 fontes,
analisamos implementações da Anthropic e Zapier. Use Publish Master para:

1. Gerar artigo "Complete llms.txt Implementation Guide" (3k palavras)
2. Atualizar llms.txt do projeto
3. Revisar robots.txt para AI crawlers
4. Regenerar sitemap.xml
5. Fornecer deployment package completo

Target: Desenvolvedores/CTOs, keyword "llms.txt implementation"
```

## Como Usar Agentes Especializados

### Via Claude Code

1. **Invocar diretamente:**
```
Use o Content Ranking Specialist para criar...
```

2. **Task Tool com referência:**
```
Preciso de conteúdo sobre [topic]. Use o agente especializado
em content ranking para garantir otimização máxima.
```

### Best Practices

1. **Seja específico:** Defina topic, audience, e goals claramente
2. **Forneça contexto:** Links para conteúdo relacionado, competitor analysis
3. **Defina métricas:** Target keywords, expected traffic, citation goals
4. **Iteração:** Review output e peça ajustes baseados em checklist

## Estrutura de Agentes

Cada agente especializado contém:

- **Role & Purpose:** O que o agente faz
- **Core Expertise:** Áreas de especialização
- **Frameworks:** Metodologias e templates
- **Checklists:** Quality assurance
- **Examples:** Output samples
- **Success Criteria:** Quando considerar o trabalho completo

## Configuration Templates

**Diretório:** `.claude/agents/templates/`

Templates prontos para arquivos de configuração:

- **llms.txt.template** - Arquivo de descoberta para LLMs
- **robots.txt.template** - Controle de acesso de crawlers (AI + tradicionais)
- **sitemap.xml.template** - Mapa do site para indexação
- **meta_tags.json.template** - Configuração centralizada de meta tags

**Documentação completa:** [templates/README.md](./templates/README.md)

**Uso:**
1. Copie template desejado
2. Substitua placeholders com informações reais
3. Valide com ferramentas apropriadas
4. Deploy seguindo checklist

**Geração Automática:**
O Publish Master Agent gera/atualiza estes arquivos automaticamente após sessão de pesquisa.

## Adicionando Novos Agentes

Para criar um novo agente especializado:

1. Crie arquivo `.md` em `.claude/agents/`
2. Siga estrutura dos agentes existentes
3. Documente claramente o propósito
4. Inclua exemplos de uso
5. Atualize este README

## Agentes Futuros (Planejados)

- **Technical Implementation Specialist:** Código e arquitetura
- **Legal Compliance Specialist:** GDPR, CFAA, contratos
- **Market Analysis Specialist:** Research de mercado e competidores
- **Pricing Strategy Specialist:** Modelos de precificação
- **Data Analyst Specialist:** Análise de métricas e ROI

## Feedback

Para sugerir melhorias ou novos agentes especializados, documente:
- Caso de uso específico
- Gap atual (o que não está sendo coberto)
- Expected output
- Métricas de sucesso
