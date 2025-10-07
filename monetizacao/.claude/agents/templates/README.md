# Configuration File Templates

Este diretório contém templates prontos para uso dos arquivos de configuração gerados pelo **Publish Master Agent**.

## Templates Disponíveis

### 📄 llms.txt.template
**Propósito:** Arquivo de descoberta para LLMs (ChatGPT, Claude, Perplexity)

**Como Usar:**
1. Copie para a raiz do seu site como `llms.txt`
2. Substitua `[placeholders]` com informações reais
3. Organize conteúdo por relevância (mais importante primeiro)
4. Mantenha descrições concisas (context window limitations)

**Best Practices:**
- Atualize sempre que publicar conteúdo importante
- Priorize documentação técnica e guias
- Use URLs absolutas (https://...)
- Descrições devem ter 10-20 palavras

**Exemplo Real:**
```markdown
# PayPerCrawl Documentation

> Complete guide to monetizing AI crawler access

## Core Documentation

- [Implementation Guide](https://site.com/guide): Step-by-step setup with code examples
```

---

### 🤖 robots.txt.template
**Propósito:** Controlar acesso de crawlers (AI e tradicionais)

**Como Usar:**
1. Copie para a raiz do site como `robots.txt`
2. Configure políticas para cada bot (Allow/Disallow)
3. Defina `Crawl-delay` apropriado
4. Adicione linha `Sitemap:` apontando para sitemap.xml

**Estratégias por Tipo:**

| Bot Type | Recomendação | Motivo |
|----------|--------------|--------|
| **AI Crawlers com citação** (Perplexity, Claude) | Allow + Crawl-delay | Visibilidade AI |
| **AI Training only** (CCBot) | Disallow | Sem ROI |
| **Search Engines** (Google, Bing) | Allow | SEO essencial |
| **SEO Tools** (Ahrefs, Semrush) | Disallow | Consomem recursos |

**Pay-Per-Crawl Specific:**
```txt
# Allow AI crawlers to public content
User-agent: GPTBot
Allow: /articles/
Disallow: /premium/
Crawl-delay: 10
```

**Validação:**
- Google: https://www.google.com/webmasters/tools/robots-testing-tool
- Bing: https://www.bing.com/webmasters/
- Teste: `curl https://seu-site.com/robots.txt`

---

### 🗺️ sitemap.xml.template
**Propósito:** Ajudar search engines e AI a descobrir todo seu conteúdo

**Como Usar:**
1. Copie e customize com suas URLs
2. Atualize `lastmod` sempre que modificar conteúdo
3. Use `priority` e `changefreq` estrategicamente
4. Submeta para Google/Bing após atualizações

**Priority Guidelines:**
- `1.0` - Homepage
- `0.9` - Pillar content, guias principais
- `0.8` - Categorias/seções importantes
- `0.7` - Artigos regulares
- `0.6` - Recursos/ferramentas
- `0.5` - Conteúdo antigo

**Changefreq Guidelines:**
- `daily` - Homepage, seções ativas
- `weekly` - Blog principal
- `monthly` - Artigos, documentação
- `yearly` - Páginas estáticas

**Limits:**
- Max 50,000 URLs por arquivo
- Max 50MB descomprimido
- Se exceder, use sitemap index

**Automação:**
Script Python incluído no `publish-master.md` para geração automática.

**Validação:**
- https://www.xml-sitemaps.com/validate-xml-sitemap.html
- Google Search Console → Sitemaps
- Bing Webmaster Tools

---

### 🏷️ meta_tags.json.template
**Propósito:** Configuração centralizada de meta tags para todas as páginas

**Como Usar:**
1. Copie como `meta_tags.json` no diretório config
2. Preencha `site`, `organization`, `social`
3. Adicione entrada em `pages` para cada URL
4. Use em sistema de templates para injetar meta tags

**Estrutura de Página:**
```json
"/article-slug": {
  "title": "Article Title | Site Name",
  "description": "Compelling description 150-160 chars",
  "keywords": "primary, secondary1, secondary2",
  "author": "Author Name",
  "published": "2025-10-08",
  "modified": "2025-10-08",
  "type": "article",
  "image": "https://site.com/images/og-image.jpg",
  "canonical": "https://site.com/article-slug"
}
```

**Validação:**
- Title: 55-60 caracteres
- Description: 150-160 caracteres
- Keywords: 5-7 máximo
- Image: 1200x630px, <300KB

**Ferramentas:**
- https://metatags.io/ - Preview meta tags
- https://cards-dev.twitter.com/validator - Twitter Card validator
- https://developers.facebook.com/tools/debug/ - Facebook Open Graph

---

### 🚀 dockerfile.elixir.template
**Propósito:** Dockerfile otimizado multi-stage para aplicações Elixir Phoenix

**Como Usar:**
1. Copie para raiz do projeto como `Dockerfile`
2. Substitua `[APP_NAME]` pelo nome da sua aplicação
3. Ajuste versões Elixir/Erlang se necessário
4. Build: `docker build -t myapp:latest .`

**Características:**
- Build stage: Compile Elixir + assets
- Runtime stage: Imagem Alpine mínima (~50-80MB)
- Non-root user para segurança
- Health checks configurados
- Compatível com: Fly.io, Google Cloud Run, AWS ECS, Azure, Railway, Render

**Otimizações:**
- Multi-stage build (redução de 90% no tamanho)
- Layer caching para deps
- Assets pre-compiled
- BEAM VM tuning incluído

**Build multi-arquitetura:**
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .
```

---

### ✈️ fly.toml.template
**Propósito:** Configuração Fly.io para deploy de Phoenix com clustering

**Como Usar:**
1. Copie para raiz como `fly.toml`
2. Substitua placeholders: `[APP_NAME]`, `[PRIMARY_REGION]`, `[VM_SIZE]`
3. Deploy: `fly launch` ou `fly deploy`

**Regiões recomendadas:**
- `gru`: São Paulo, Brazil
- `iad`: Virginia, USA
- `lhr`: London, UK
- `fra`: Frankfurt, Germany

**Tamanhos de VM:**
- `shared-cpu-1x`: 256MB RAM (hobby)
- `shared-cpu-2x`: 512MB RAM (small prod)
- `dedicated-cpu-1x`: 2GB RAM (production)
- `dedicated-cpu-2x`: 4GB RAM (high-traffic)

**Features incluídos:**
- Auto-scaling configuration
- Health checks (TCP + HTTP)
- Multi-region deployment support
- Distributed Erlang clustering (DNS-based)
- Graceful shutdown (30s timeout)
- Metrics endpoint

**Comandos úteis:**
```bash
fly scale count 2 --region gru    # Scale horizontalmente
fly scale vm dedicated-cpu-1x     # Scale verticalmente
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
```

---

### 🚂 railway.json.template
**Propósito:** Configuração Railway para deploy Docker-based

**Como Usar:**
1. Copie para raiz como `railway.json`
2. Substitua `[APP_NAME]`, `[REGION]`
3. Deploy: `railway up` ou via GitHub integration

**Regiões disponíveis:**
- `us-west1`: Oregon, USA
- `us-east4`: Virginia, USA
- `europe-west4`: Netherlands
- `asia-south1`: Mumbai, India

**Setup inicial:**
```bash
npm install -g @railway/cli
railway login
railway init
railway variables set SECRET_KEY_BASE=$(mix phx.gen.secret)
railway up
```

**Features incluídos:**
- Dockerfile auto-detection
- Health check configurado (/health)
- Environment variables management
- PostgreSQL plugin integration
- Restart policies
- Dynamic PORT assignment

**Pricing:**
- Starter: $0-5/month (hobby)
- Developer: $20/month + usage
- Pro: $50/month + usage

---

### 🎨 render.yaml.template
**Propósito:** Configuração Render.com para deploy com PostgreSQL

**Como Usar:**
1. Copie para raiz como `render.yaml`
2. Substitua placeholders: `[APP_NAME]`, `[PLAN_TYPE]`, `[REGION]`, `[BRANCH]`
3. Connect GitHub repo
4. Render auto-detects render.yaml e deploy

**Plans disponíveis:**
- `free`: 512MB RAM, spin-down após 15min (hobby)
- `starter`: 512MB RAM, always-on ($7/month)
- `standard`: 2GB RAM, 1 CPU ($25/month)
- `pro`: 4GB RAM, 2 CPU ($85/month)

**Regiões:**
- `oregon`: Oregon, USA (menor latência para Brasil)
- `ohio`: Ohio, USA
- `frankfurt`: Frankfurt, Germany
- `singapore`: Singapore

**Features incluídos:**
- Auto-deploy on git push
- Health checks (/health endpoint)
- PostgreSQL managed database
- Environment variables management
- Deploy previews (PR environments)
- Zero-downtime deploys
- Automatic HTTPS

**Database plans:**
- Starter: 1GB storage ($7/month)
- Standard: 10GB storage ($20/month)
- Pro: 25GB storage ($90/month)

**Comandos úteis:**
```bash
npm install -g @render/cli
render login
render logs -s [APP_NAME] --follow
render run -s [APP_NAME] bin/myapp eval "MyApp.Release.migrate()"
```

---

## Comparação de Deployment Templates

| Template | Melhor Para | Complexidade | Pricing Inicial | Multi-Region |
|----------|-------------|--------------|-----------------|--------------|
| **fly.toml** | Produção BEAM-otimizada | Média | $2-5/mês | ✅ Excelente |
| **railway.json** | Prototipagem rápida | Baixa | $0-5/mês | ❌ Single region |
| **render.yaml** | Simplicidade + DB | Baixa | $0/mês (free) | ❌ Single region |
| **dockerfile** | Máxima flexibilidade | Alta | Varia | Depende plataforma |

**Recomendações por Caso de Uso:**

- **Hobby/Dev**: `render.yaml` (free tier) ou `railway.json` (free tier)
- **Small Production**: `fly.toml` (shared-cpu-1x, $2-5/mês) ou `nixpacks.toml` on Sevalla ($18-40/mês)
- **Medium Production**: `fly.toml` (dedicated-cpu-1x, multi-region, $30-50/mês) ou `nixpacks.toml` on Sevalla ($135-160/mês)
- **Large Production**: `fly.toml` (dedicated-cpu-2x+, 3+ regiões, $100-300/mês)
- **Brasil-focused**: `fly.toml` com região `gru` (São Paulo) ou Sevalla `southamerica-east1`
- **GCP + Cloudflare Infrastructure**: `nixpacks.toml` on Sevalla (25 global regions)

---

### 🔧 nixpacks.toml.template
**Propósito:** Configuração Nixpacks para Elixir Phoenix no Sevalla/Railway

**Como Usar:**
1. Copie para raiz como `nixpacks.toml`
2. Substitua `[APP_NAME]` pelo nome da aplicação
3. Configure environment variables no dashboard
4. Push to Git → auto-deploy

**Características:**
- Auto-detection de mix.exs (Elixir project)
- Fases: setup → install → build → start
- Asset compilation (Node.js + esbuild)
- Release build para performance
- Compatible: Sevalla, Railway, any Nixpacks PaaS

**Plataformas suportadas:**
- **Sevalla**: GCP + Cloudflare, 25 regions, $18-480/mês
- **Railway**: AWS/GCP, US only, $5+/mês
- Qualquer PaaS usando Nixpacks

**Environment Variables necessárias:**
```bash
SECRET_KEY_BASE=<mix phx.gen.secret>
DATABASE_URL=ecto://user:pass@host/db
PHX_HOST=myapp.sevalla.com
MIX_ENV=prod
LANG=en_US.UTF-8
```

**Exemplo de start command:**
```toml
[start]
cmd = "_build/prod/rel/myapp/bin/myapp start"
```

**Pay-Per-Crawl Integration:**
- Template inclui seção específica para implementar detecção de crawlers
- Adicione Plug Phoenix para User-Agent detection
- Integre com Stripe/PayPal para payments
- Use Sevalla Cloudflare backbone para edge detection

---

## Workflow de Uso com Publish Master

### Cenário: Publicar Novo Artigo

**1. Sessão de Pesquisa** (1 hora)
- WebSearch sobre tópico
- WebFetch de fontes importantes
- Coletar dados, estatísticas, quotes

**2. Invocar Publish Master**
```
Use Publish Master para consolidar pesquisa sobre [tópico].
Gerar artigo + atualizar configurações (llms.txt, robots.txt, sitemap.xml).
```

**3. Review Outputs**
Publish Master gerará:
- ✅ `ARTICLE.md` - Conteúdo otimizado
- ✅ `llms.txt` - Atualizado com novo artigo
- ✅ `robots.txt` - Revisado (se necessário)
- ✅ `sitemap.xml` - Nova URL adicionada
- ✅ `meta_tags.json` - Entry para novo artigo
- ✅ `structured_data.json` - Schemas JSON-LD
- ✅ `DEPLOYMENT_CHECKLIST.md` - Passo-a-passo
- ✅ `SOURCES.md` - Documentação de fontes
- ✅ `UPDATE_SCHEDULE.md` - Plano de atualizações
- ✅ `DEPLOYMENT_SUMMARY.md` - Executive summary

**4. Deploy**
- Seguir checklist do Publish Master
- Testar em staging
- Validar schemas (schema.org validator)
- Publicar
- Submeter sitemap atualizado

**5. Monitor**
- Day 1: Indexação
- Week 1: Rankings iniciais
- Month 1: AI citations, tráfego

---

## Ferramentas de Validação

### Schema/Structured Data
- **Schema.org Validator:** https://validator.schema.org/
- **Google Rich Results Test:** https://search.google.com/test/rich-results
- **Schema Markup Generator:** https://technicalseo.com/tools/schema-markup-generator/

### SEO/Meta Tags
- **Meta Tags Preview:** https://metatags.io/
- **Twitter Card Validator:** https://cards-dev.twitter.com/validator
- **Facebook Debugger:** https://developers.facebook.com/tools/debug/
- **LinkedIn Post Inspector:** https://www.linkedin.com/post-inspector/

### Sitemaps
- **XML Sitemap Validator:** https://www.xml-sitemaps.com/validate-xml-sitemap.html
- **Google Search Console:** Sitemaps section
- **Bing Webmaster Tools:** Submit sitemap

### Robots.txt
- **Google Robots Tester:** https://www.google.com/webmasters/tools/robots-testing-tool
- **Bing Robots Validator:** Webmaster Tools
- **Robots.txt Checker:** https://support.google.com/webmasters/answer/6062598

### AI Optimization
- **llms.txt Validator:** https://llmstxt.org/
- **AI Citation Tracking:** Otterly.ai, Semrush AI Tracking
- **Content Analysis:** Surfer SEO, Clearscope

---

## Manutenção Regular

### Semanalmente
- [ ] Verificar logs de crawlers (quem está acessando)
- [ ] Atualizar sitemap.xml se novo conteúdo publicado
- [ ] Revisar analytics (tráfego, engagement)

### Mensalmente
- [ ] Atualizar llms.txt com novos artigos importantes
- [ ] Revisar robots.txt (bots desconhecidos detectados?)
- [ ] Validar meta tags de artigos recentes
- [ ] Refresh de conteúdo top-performing

### Trimestralmente
- [ ] Audit completo de configurações
- [ ] Verificar todos os schemas (validação)
- [ ] Análise de AI citation rate
- [ ] Ajustes de estratégia baseado em dados

---

## Troubleshooting

### llms.txt não funcionando
- ✅ Arquivo está na raiz (`/llms.txt`)?
- ✅ URLs são absolutas (https://...)?
- ✅ Markdown formatado corretamente?
- ✅ Robots.txt permite acesso?

### Robots.txt bloqueando incorretamente
- ✅ Sintaxe correta (sem erros)?
- ✅ `User-agent` especificado antes de `Allow/Disallow`?
- ✅ Diretivas não conflitantes?
- ✅ Testado com validators?

### Sitemap não indexando
- ✅ XML válido (sem erros sintaxe)?
- ✅ Submetido no Search Console?
- ✅ Referenciado em robots.txt?
- ✅ Todas URLs são acessíveis (não 404)?
- ✅ Respeita limites (50k URLs, 50MB)?

### Meta tags não aparecendo
- ✅ Tags em `<head>` do HTML?
- ✅ Sintaxe correta (property vs name)?
- ✅ URLs são absolutas?
- ✅ Imagens acessíveis (não 404)?
- ✅ Testado com validators?

---

## Recursos Adicionais

### Documentação Oficial
- **Schema.org:** https://schema.org/
- **robots.txt Spec:** https://www.robotstxt.org/
- **Sitemap Protocol:** https://www.sitemaps.org/
- **Open Graph Protocol:** https://ogp.me/

### Guias Relacionados
- [Publish Master Agent](../publish-master.md) - Workflow completo
- [Content Ranking Specialist](../content-ranking-specialist.md) - SEO + LLMO
- [Document 10](../../10-seo-llm-agentes-ia.md) - SEO para LLMs guide

### Community
- Stack Overflow: Perguntas sobre implementação
- Reddit r/TechSEO: Discussões de SEO técnico
- Search Engine Land: Notícias e updates

---

## Contribuindo

Sugestões de melhoria para templates:
1. Abra issue descrevendo o caso de uso
2. Proponha mudança específica
3. Inclua exemplo prático
4. Documente benefício

---

**Templates mantidos em sincronia com Publish Master Agent**
**Última atualização:** Outubro 2025
**Versão:** 1.0.0
