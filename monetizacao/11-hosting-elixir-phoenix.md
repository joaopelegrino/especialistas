# 11. Hospedagem para Elixir Phoenix: Guia Completo de Deployment 2025

## 🎯 Visão Executiva

O ecossistema de hospedagem para aplicações Elixir e Phoenix Framework amadureceu significativamente em 2025, oferecendo desde plataformas especializadas em BEAM até soluções containerizadas globais. Com **Fly.io processando 23 regiões globais**, **Gigalixir oferecendo clustering nativo** e **Cloudflare Containers em beta público**, desenvolvedores têm mais opções do que nunca para deploy de Phoenix LiveView, APIs e aplicações full-stack.

### Números-Chave do Mercado

- **Fly.io:** Líder de mercado, suporte oficial Phoenix, **$0/mês tier grátis**, 23+ regiões (incluindo São Paulo)
- **Gigalixir:** Único PaaS 100% Elixir/BEAM, **$10/mês** entry tier, clustering out-of-the-box
- **Railway:** **6-18x aumento** em queries de usuários no primeiro dia (experiência Perplexity)
- **Render:** Workers built-in, **pricing flat** ($7-85/mês por tier)
- **Cloudflare Containers:** Beta público **junho 2025**, containers globais com Workers integration

### Estado Atual: Brasil e América Latina

⚠️ **Realidade do mercado:**
- **Nenhum** provedor Elixir-específico com datacenter no Brasil
- Fly.io tem region **GRU (São Paulo)** mas é global, não brasileiro
- Hostinger oferece VPS em São Paulo mas **sem suporte Elixir nativo**
- Locaweb, UOL Host, KingHost: VPS genérico, **setup manual necessário**

## 📊 Matrix Comparativa Executiva

| Plataforma | Elixir Nativo | Brasil/LATAM | Pay-Per-Crawl | IA Integration | Preço Início | Recomendado Para |
|-----------|--------------|--------------|---------------|----------------|--------------|------------------|
| **Fly.io** | ✅ Suporte oficial | 🟡 Region GRU | ⚠️ Custom middleware | ✅ Claude SDK | **$0 (free tier)** | **Produção, scale** |
| **Gigalixir** | ✅ PaaS BEAM | ❌ | ⚠️ Plug middleware | ⚠️ Manual | **$10/mês** | **BEAM features** |
| **Render** | ✅ Buildpack | ❌ | ⚠️ Custom middleware | ⚠️ Manual | **$7/mês** | **Simplicidade** |
| **Railway** | ✅ Auto-detect | ❌ | ⚠️ Custom middleware | ⚠️ Manual | **$5/mês** | **Protótipos rápidos** |
| **Sevalla** | ✅ Nixpacks | ✅ Region GRU | 🟡 Via Cloudflare | ⚠️ Manual | **$18/mês** | **GCP+Cloudflare+BR** |
| **Google Cloud Run** | 🟡 Containers | 🟡 southamerica-east1 | 🟡 Cloud Armor | ✅ APIs | **Pay-per-use** | **Serverless** |
| **AWS ECS** | 🟡 Containers | 🟡 sa-east-1 (SP) | ✅ WAF + Shield | ✅ APIs | **$30+/mês** | **Enterprise** |
| **Azure Container Apps** | 🟡 Containers | 🟡 Brazil South | 🟡 App Gateway WAF | ✅ APIs | **$15+/mês** | **Microsoft stack** |
| **Cloudflare Containers** | 🟡 Beta 2025 | ✅ Global edge | ✅ Bot Management | ⚠️ Workers | **TBD** | **Edge computing** |
| **Hostinger Brasil** | ❌ VPS manual | ✅ São Paulo DC | ❌ DIY total | ❌ | **$4/mês VPS** | **Budget Brasil** |
| **Vercel** | ❌ Sem BEAM | ❌ | ❌ | ❌ | **N/A** | **❌ Incompatível** |

**Legenda:**
- ✅ Suporte nativo/completo
- 🟡 Suporte parcial/requer configuração
- ⚠️ Possível mas limitado
- ❌ Não suportado

## 💰 Capacidades Pay-Per-Crawl por Plataforma

Considerando o contexto de **monetização de crawlers de IA** (GPTBot, ClaudeBot, etc.), cada plataforma oferece diferentes níveis de suporte para implementar pay-per-crawl:

### 🎯 Tier 1: Implementação Nativa (Cloud Providers com WAF/Bot Management)

**AWS ECS + WAF + Shield:**
- ✅ **AWS WAF**: Rules customizadas para bot detection ($5/mês + $1/milhão requests)
- ✅ **AWS Shield**: DDoS protection ($3.000/mês enterprise)
- ✅ **CloudFront**: Geolocation, rate limiting, custom headers
- ✅ **Lambda@Edge**: Custom logic para crawler auth
- **Custo adicional**: ~$20-100/mês para setup básico
- **Melhor para**: Enterprise com compliance requirements

**Azure Container Apps + Application Gateway:**
- ✅ **Application Gateway WAF**: Bot protection rules
- ✅ **Azure Front Door**: Global routing, bot filtering
- ✅ **Custom Rules**: User-Agent detection, rate limiting
- **Custo adicional**: ~$15-80/mês
- **Melhor para**: Microsoft ecosystem, B2B publishers

**Google Cloud Run + Cloud Armor:**
- ✅ **Cloud Armor**: ML-based bot detection
- ✅ **reCAPTCHA Enterprise**: Advanced bot scoring
- ✅ **Custom Security Policies**: Rate limiting, geo-blocking
- **Custo adicional**: ~$10-50/mês
- **Melhor para**: Data-heavy publishers, ML workloads

**Cloudflare Containers + Bot Management:**
- ✅ **Bot Management**: Score 1-99, ML detection ($200/mês+)
- ✅ **Workers**: Edge middleware para auth
- ✅ **Rate Limiting**: Built-in, granular control
- ✅ **Web3 Auth**: Crypto payments (experimental)
- **Custo adicional**: $200-1.000/mês (Bot Management)
- **Melhor para**: Global publishers, edge-first architecture

### 🎯 Tier 2: Implementação Via Proxy/CDN (PaaS + Cloudflare)

**Sevalla (GCP + Cloudflare backbone):**
- 🟡 **Cloudflare PoPs**: 260+ locations, automatic DDoS
- 🟡 **Custom middleware**: Phoenix Plug para bot detection
- 🟡 **Cloudflare Workers**: Pode adicionar ($5/mês) para edge logic
- 🟡 **Rate limiting**: Via Phoenix Plug ou Cloudflare add-on
- **Setup**: Médio (requer Plug custom + Cloudflare config)
- **Custo adicional**: $0-200/mês (se usar Cloudflare paid features)
- **Melhor para**: Projetos médios, Brasil-focused, DX priority

**Fly.io (própria edge network):**
- ⚠️ **Custom middleware**: Phoenix Plug para bot detection
- ⚠️ **Fly Proxy**: Basic rate limiting (não bot-specific)
- ⚠️ **Distributed state**: Durable Objects via external service
- ⚠️ **Header analysis**: Custom code em Elixir
- **Setup**: Alto (full DIY em Phoenix)
- **Custo adicional**: $0 (se usar só Plug)
- **Melhor para**: Developers experientes, controle total

### 🎯 Tier 3: Implementação DIY Total (PaaS sem Bot Management)

**Gigalixir, Render, Railway:**
- ⚠️ **Phoenix Plugs**: Implementar detecção manualmente
- ⚠️ **User-Agent parsing**: Detectar GPTBot, ClaudeBot, etc.
- ⚠️ **Rate limiting**: Via `PlugAttack` ou `Hammer`
- ⚠️ **Payment integration**: Stripe/PayPal APIs
- ⚠️ **Logging**: Track crawler requests custom
- **Setup**: Alto (código Elixir completo)
- **Custo adicional**: $0 infra + tempo dev
- **Melhor para**: Startups tech-first, custom requirements

### 📦 Bibliotecas Elixir para Pay-Per-Crawl

```elixir
# deps em mix.exs
defp deps do
  [
    # Bot detection
    {:ua_parser, "~> 1.8"},           # Parse User-Agent
    {:plug_attack, "~> 0.4"},         # Rate limiting
    {:hammer, "~> 6.1"},              # Distributed rate limiting

    # Payment processing
    {:stripity_stripe, "~> 2.17"},    # Stripe integration
    {:ex_paypal, "~> 0.1"},           # PayPal REST API

    # Analytics/logging
    {:telemetry, "~> 1.0"},           # Metrics
    {:logger_json, "~> 5.1"}          # Structured logging
  ]
end
```

### 🔍 Exemplo: Detecção de AI Crawlers em Phoenix

```elixir
# lib/myapp_web/plugs/crawler_detector.ex
defmodule MyAppWeb.Plugs.CrawlerDetector do
  import Plug.Conn

  @ai_crawlers [
    "GPTBot",
    "ChatGPT-User",
    "ClaudeBot",
    "anthropic-ai",
    "CCBot",
    "PerplexityBot",
    "Google-Extended",
    "Bingbot",
    "FacebookBot"
  ]

  def init(opts), do: opts

  def call(conn, _opts) do
    user_agent = get_req_header(conn, "user-agent") |> List.first() || ""

    if is_ai_crawler?(user_agent) do
      conn
      |> assign(:is_ai_crawler, true)
      |> assign(:crawler_type, detect_crawler_type(user_agent))
      |> maybe_require_payment()
    else
      assign(conn, :is_ai_crawler, false)
    end
  end

  defp is_ai_crawler?(user_agent) do
    Enum.any?(@ai_crawlers, &String.contains?(user_agent, &1))
  end

  defp detect_crawler_type(user_agent) do
    Enum.find(@ai_crawlers, fn bot ->
      String.contains?(user_agent, bot)
    end)
  end

  defp maybe_require_payment(conn) do
    # Check if payment token exists
    case get_req_header(conn, "x-payment-token") do
      [token] when token != "" ->
        verify_payment_token(conn, token)
      _ ->
        # Return 402 Payment Required
        conn
        |> put_status(402)
        |> Phoenix.Controller.json(%{
          error: "Payment required",
          message: "AI crawler access requires payment. Visit /api/crawler-auth for details",
          pricing: "$0.01 per request",
          contact: "crawler-access@myapp.com"
        })
        |> halt()
    end
  end

  defp verify_payment_token(conn, token) do
    # Integrate with Stripe/PayPal/etc
    case MyApp.Payments.verify_crawler_token(token) do
      {:ok, account} ->
        assign(conn, :paid_crawler_account, account)
      {:error, _} ->
        conn
        |> put_status(401)
        |> Phoenix.Controller.json(%{error: "Invalid payment token"})
        |> halt()
    end
  end
end
```

### 💡 Recomendações por Caso de Uso

| Caso de Uso | Plataforma Recomendada | Justificativa |
|-------------|----------------------|---------------|
| **Enterprise publisher** (NY Times, WSJ) | AWS ECS + WAF + Shield | Compliance, SOC2, máximo controle, audit logs |
| **Tech publisher** (TechCrunch, Ars) | Cloudflare Containers + Bot Mgmt | Global edge, best bot detection, $200-1k/mês |
| **Regional publisher** (Brasil) | Sevalla + Cloudflare Workers | Brasil region (GRU), infraestrutura premium, $18-200/mês |
| **Startup publisher** (Medium-sized) | Fly.io + Custom Plug | Controle total código, $0 infra add-on, BEAM optimization |
| **Indie/small publisher** | Railway/Render + Plug | Simple setup, pay-per-use, Phoenix Plug DIY |

### ⚠️ Considerações Importantes

**Legal:**
- Implementar pay-per-crawl requer **Terms of Service** claros
- Conformidade GDPR (log de IP/User-Agent = dados pessoais potenciais)
- CFAA compliance (EUA): Explicit authorization em ToS

**Técnico:**
- **False positives**: Detecção incorreta pode bloquear tráfego legítimo
- **Bypass**: Crawlers podem mascarar User-Agent (anti-fingerprinting necessário)
- **Latência**: Verificação de payment adiciona ~10-50ms por request

**Financeiro:**
- **Processing fees**: Stripe/PayPal cobram 2,9% + $0,30 por transação
- **Micropayments**: Para $0,001-0,05 por crawl, considerar pre-payment/credits
- **Chargebacks**: Plano para disputas (1-2% típico em payments)

---

## 🏗️ Categorias de Plataformas

### Tier 1: Plataformas Elixir-Native (PaaS Especializado)

Plataformas com suporte nativo ao BEAM, configuração mínima, features Elixir-específicas.

#### 1.1 Fly.io - O Líder de Mercado

**Status:** ⭐ **Recomendação #1** para Phoenix em 2025

**Por que é o melhor:**
- Documentação oficial Phoenix aponta Fly.io como deploy primário
- Comando `fly launch` detecta Phoenix automaticamente
- Clustering distribuído global com `libcluster` built-in
- Multi-region deployment com **um comando**: `fly scale count 3 --region gru,fra,syd`

**Especificações Técnicas:**

```bash
# Deploy Phoenix em 3 minutos
mix phx.new myapp
cd myapp
fly launch  # Auto-detecta Phoenix, gera fly.toml

# Clustering automático multi-region
fly scale count 2 --region gru  # São Paulo
fly scale count 2 --region iad  # US East
# Nodes se conectam automaticamente via DNS clustering
```

**Configuração Fly.toml:**

```toml
app = "myapp"
primary_region = "gru"  # São Paulo como primary

[build]

[env]
  PHX_HOST = "myapp.fly.dev"
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1

[[vm]]
  memory = "1gb"
  cpu_kind = "shared"
  cpus = 1

[[statics]]
  guest_path = "/app/priv/static"
  url_prefix = "/assets"
```

**Pricing Fly.io 2025:**

| Tier | Memória | CPU | Preço/Mês | Use Case |
|------|---------|-----|-----------|----------|
| **Free** | 256MB × 3 VMs | Shared | **$0** | Hobby, desenvolvimento |
| **Hobby** | 1GB × 2 VMs | Shared-1x | **~$10** | Projetos pessoais |
| **Production** | 2GB × 3 VMs | Dedicated-2x | **~$50** | Produção pequena |
| **Scale** | 4GB+ × 5+ VMs | Dedicated-4x+ | **$200+** | High traffic |

**Recursos Incluídos:**
- **Bandwidth:** 100GB/mês grátis
- **Persistent volumes:** 3GB grátis
- **IPv4:** $2/mês adicional (IPv6 grátis)
- **PostgreSQL:** Via `fly postgres create` (mesmos tiers de VM)

**Regiões Disponíveis (23 totais):**

Americas:
- 🇧🇷 **GRU** - São Paulo, Brazil ⭐
- 🇺🇸 IAD - Ashburn, Virginia
- 🇺🇸 LAX - Los Angeles
- 🇺🇸 ORD - Chicago
- 🇨🇦 YYZ - Toronto
- 🇨🇱 SCL - Santiago
- 🇲🇽 QRO - Querétaro

**Claude Code Integration:**

```bash
# Fly.io tem integração oficial com Claude
# Claude knows how to deploy Phoenix to Fly automatically

# Via Claude Code:
"Deploy minha app Phoenix para Fly.io region São Paulo"
# Claude executa: fly launch --region gru --auto-confirm
```

**Vantagens:**
- ✅ **Suporte oficial Phoenix/Elixir**
- ✅ **Free tier generoso** (256MB × 3 VMs)
- ✅ **Clustering global** automático
- ✅ **23 regiões** incluindo GRU (São Paulo)
- ✅ **CLI excelente** (flyctl)
- ✅ **Deploy <5 min** primeira vez
- ✅ **Secrets management** integrado
- ✅ **Metrics & logs** built-in

**Desvantagens:**
- ⚠️ IPv4 custa $2/mês extra
- ⚠️ Free tier tem sleep após inatividade
- ⚠️ Pode ser caro em high scale ($200+/mês)

**Caso de Uso Ideal:**
- Produção Phoenix LiveView
- APIs Elixir com global distribution
- Apps que precisam clustering multi-region
- Desenvolvedores que valorizam CLI quality

---

#### 1.2 Gigalixir - O Especialista BEAM

**Status:** Único PaaS focado 100% em Elixir/Erlang/BEAM

**Por que escolher:**
- **Único provedor** que suporta 100% das features BEAM
- Hot upgrades sem downtime
- Remote observer over SSH
- Remote console (IEx) direto em produção
- Clustering distribuído out-of-the-box
- **Nenhum** restart de servers (in-memory state persistente)

**Especificações Técnicas:**

```bash
# Setup Gigalixir
pip3 install gigalixir
gigalixir signup
gigalixir login

# Deploy Phoenix
cd myapp
git init && git add . && git commit -m "Initial"
gigalixir create
git push gigalixir master

# Features BEAM nativos
gigalixir ps:remote_console  # IEx remoto
gigalixir ps:observer  # Observer GUI
gigalixir ps:distillery_replace_os_vars true  # Hot upgrades
```

**Gigalixir Config (`gigalixir.toml`):**

```toml
[app]
  cloud = "gcp"  # ou "aws"
  region = "us-central1"  # GCP regions
  stack = "gigalixir-20"

[build]
  buildpacks = ["https://github.com/HashNuke/heroku-buildpack-elixir"]

[deploy]
  mix_env = "prod"
  procfile = "Procfile"

[run]
  size = 0.5  # 0.5 = 512MB RAM
```

**Pricing Gigalixir 2025:**

| Tier | RAM | Replicas | Preço/Mês | Features |
|------|-----|----------|-----------|----------|
| **Free** | 0.2 (200MB) | 1 | **$0** | Hobby, testing |
| **Standard** | 0.5 (512MB) | 1-10 | **$10 base** | Produção light |
| **Pro** | 1.0+ (1GB+) | Ilimitado | **$25+ base** | High availability |

**Pricing por memória:** ~$0.20/GB/mês (~200MB por $1/mês)

**Recursos Únicos:**

1. **Distributed Erlang Clustering:**
```elixir
# Nodes se conectam automaticamente
config :libcluster,
  topologies: [
    gigalixir: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [
          :"myapp@10.0.0.1",
          :"myapp@10.0.0.2"
        ]
      ]
    ]
  ]
```

2. **Hot Code Upgrades:**
```bash
# Build release com Distillery/Mix Release
MIX_ENV=prod mix release

# Deploy sem downtime
git push gigalixir master
# Gigalixir faz hot upgrade automaticamente
```

3. **Remote Observer:**
```bash
gigalixir ps:observer
# Abre Observer GUI conectado ao node remoto
# Veja processes, memory, ETS tables em produção
```

**Vantagens:**
- ✅ **100% BEAM features** (único provider)
- ✅ **Hot upgrades** nativos
- ✅ **Remote console** e Observer
- ✅ **In-memory state** persistente
- ✅ **Clustering** automático
- ✅ **Free tier** disponível
- ✅ **Simple pricing** (por GB RAM)

**Desvantagens:**
- ❌ **Sem regiões Brasil/LATAM**
- ❌ **Menor número de regiões** vs Fly.io
- ⚠️ **Documentação menos extensa**
- ⚠️ **Community menor** que Fly.io
- ⚠️ **UI/UX** menos polido

**Caso de Uso Ideal:**
- Apps que usam distributed Erlang intensivamente
- Hot upgrades são requisito
- Precisa de remote observer em produção
- Quer aproveitar 100% do BEAM

---

#### 1.3 Render - Simplicidade e Workers Built-in

**Status:** Foco em developer experience, pricing previsível

**Por que escolher:**
- Background workers nativos (não precisa external queue)
- Pricing flat, sem surpresas
- Deploy via Git push
- SSL automático
- Persistent disks incluídos

**Especificações Técnicas:**

```bash
# Deploy via render.yaml
# Coloque na raiz do projeto
```

**render.yaml Example:**

```yaml
services:
  - type: web
    name: myapp
    runtime: docker
    region: oregon
    plan: starter
    branch: main
    buildCommand: mix deps.get && npm install --prefix assets && npm run deploy --prefix assets && mix phx.digest && mix release
    startCommand: _build/prod/rel/myapp/bin/myapp start
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: myapp-db
          property: connectionString
      - key: SECRET_KEY_BASE
        generateValue: true
      - key: PHX_HOST
        value: myapp.onrender.com
    healthCheckPath: /health

  # Background workers (feature exclusiva)
  - type: worker
    name: myapp-worker
    runtime: docker
    region: oregon
    plan: starter
    branch: main
    buildCommand: mix deps.get && mix release
    startCommand: _build/prod/rel/myapp/bin/myapp eval "MyApp.Worker.start()"
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: myapp-db
          property: connectionString

databases:
  - name: myapp-db
    databaseName: myapp
    user: myapp
    plan: starter
    region: oregon
```

**Pricing Render 2025:**

| Tier | RAM | CPU | Preço/Mês | Workers | Storage |
|------|-----|-----|-----------|---------|---------|
| **Free** | 512MB | 0.1 CPU | **$0** | ❌ | Ephemeral |
| **Starter** | 512MB | 0.5 CPU | **$7** | ✅ | 1GB disk |
| **Standard** | 2GB | 1 CPU | **$25** | ✅ | 10GB disk |
| **Pro** | 4GB+ | 2+ CPU | **$85+** | ✅ | 100GB+ disk |

**Vantagens:**
- ✅ **Pricing flat** previsível
- ✅ **Background workers** incluídos
- ✅ **Persistent disks** em todos tiers pagos
- ✅ **Deploy automático** via Git
- ✅ **SSL grátis** (Let's Encrypt)
- ✅ **Database backups** automáticos
- ✅ **Preview environments** para PRs

**Desvantagens:**
- ❌ **Free tier dorme** após 15 min inatividade
- ❌ **Sem regiões Brasil**
- ⚠️ **Menos features BEAM** vs Gigalixir
- ⚠️ **Pode ser caro** em scale ($85+)

**Caso de Uso Ideal:**
- Apps com background jobs (workers included)
- Projetos que valorizam pricing previsível
- Teams que não querem gerenciar infrastructure

---

#### 1.4 Railway - Deploy Rápido e GitHub Integration

**Status:** Melhor DX para protótipos e MVPs

**Por que escolher:**
- Deploy em **minutos** (connect GitHub → deploy)
- UI limpa e intuitiva
- Logs fáceis de encontrar
- Variáveis de ambiente simples
- Ideal para early-stage startups

**Especificações Técnicas:**

```bash
# Via CLI
npm i -g @railway/cli
railway login
railway init
railway up

# Ou via UI: Connect GitHub repo → Auto-deploy
```

**railway.json (opcional):**

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "mix deps.get && mix compile && npm install --prefix assets && npm run deploy --prefix assets && mix phx.digest"
  },
  "deploy": {
    "startCommand": "mix phx.server",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 100,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

**Pricing Railway 2025:**

| Uso | Preço | Descrição |
|-----|-------|-----------|
| **Hobby** | **$5/mês** | $5 de crédito incluído, pay-per-use depois |
| **Pro** | **$20/mês** | $20 crédito + descontos, recursos Pro |
| **Resources** | **Pay-per-use** | RAM: $0.000463/GB/min, CPU: variável |

**Exemplo de custo:**
- App 512MB RAM, 24/7: ~$10/mês
- App 1GB RAM, 24/7: ~$20/mês

**Vantagens:**
- ✅ **Deploy mais rápido** (GitHub → produção em min)
- ✅ **UI excelente** (melhor UX do mercado)
- ✅ **Logs limpos** e acessíveis
- ✅ **Variáveis de ambiente** fáceis
- ✅ **Templates** (Phoenix template pronto)
- ✅ **Nixpacks** detecta Elixir automaticamente

**Desvantagens:**
- ❌ **Sem free tier** (mínimo $5/mês)
- ❌ **Pricing pode crescer** rapidamente
- ⚠️ **Menos maduro** que Fly.io/Render
- ⚠️ **Features BEAM limitadas**

**Caso de Uso Ideal:**
- MVPs e protótipos
- Startups early-stage
- Desenvolvedores que valorizam DX acima de tudo
- Projects com tight timeline (deploy hoje)

---

#### 1.5 Sevalla (by Kinsta) - GCP + Cloudflare Infrastructure

**Status:** Novo PaaS moderno com presença Brasil (lançado 2024)

**Por que escolher:**
- **Infraestrutura premium**: GCP + Cloudflare (260+ PoPs)
- **Brasil Region**: São Paulo (`southamerica-east1`) disponível
- **Deploy ultra-rápido**: 14 segundos média (commit → live)
- **Pricing transparente**: Usage-based, sem surpresas
- **Suporte proativo**: Live chat monitoring, resposta imediata
- **Kinsta brand**: Confiabilidade de managed WordPress líder

**Especificações Técnicas:**

```bash
# Setup via UI (sem CLI dedicado)
# 1. Connect GitHub repository no dashboard Sevalla
# 2. Sevalla auto-detecta mix.exs via Nixpacks
# 3. Configurar environment variables
# 4. Deploy automático

# Alternativamente, use nixpacks.toml para controle fino
```

**nixpacks.toml (opcional):**

```toml
[variables]
MIX_ENV = 'prod'
LANG = 'en_US.UTF-8'

[phases.setup]
nixPkgs = ['nodejs', 'erlang']

[phases.install]
cmds = [
  'mix local.hex --force',
  'mix local.rebar --force',
  'mix deps.get --only prod'
]

[phases.build]
cmds = [
  'mix compile',
  'npm install --prefix assets',
  'npm run deploy --prefix assets',
  'mix phx.digest',
  'mix release'
]

[start]
cmd = "mix ecto.migrate && _build/prod/rel/myapp/bin/myapp start"
```

**Environment Variables requeridas:**

```bash
SECRET_KEY_BASE=<mix phx.gen.secret>
DATABASE_URL=ecto://user:pass@host/db
PHX_HOST=myapp.sevalla.com
MIX_ENV=prod
LANG=en_US.UTF-8
ECTO_IPV6=false
```

**Pricing Sevalla 2025:**

Sevalla oferece **3 séries de pods** com diferentes ratios CPU:RAM:

| Pod Type | CPU | RAM | Preço/Mês | $/hora | Uso Recomendado |
|----------|-----|-----|-----------|--------|-----------------|
| **C Series (Compute 1:1)** |
| C1 | 1 | 1GB | **$18** | $0.025 | CPU-intensive, APIs |
| C2 | 2 | 2GB | $68 | $0.093 | Compute-optimized |
| C3 | 4 | 4GB | $135 | $0.185 | Parallel processing |
| C4 | 8 | 8GB | $270 | $0.370 | High compute |
| **S Series (Standard 1:2)** |
| S2 | 1 | 2GB | **$40** | $0.055 | Web apps, APIs |
| S3 | 2 | 4GB | $80 | $0.110 | Small production |
| S4 | 4 | 8GB | $160 | $0.219 | Medium production |
| S5 | 8 | 16GB | $320 | $0.438 | High traffic |
| **M Series (Memory 1:4)** |
| M1 | 0.5 | 2GB | **$20** | $0.027 | Background jobs |
| M2 | 1 | 4GB | $70 | $0.096 | Memory-intensive |
| M3 | 2 | 8GB | $135 | $0.185 | Large datasets |
| M4 | 4 | 16GB | $250 | $0.342 | Heavy processing |
| M5 | 8 | 32GB | $480 | $0.658 | Enterprise workloads |

**Custos Adicionais:**
- **Build time**: $0.02/minuto ($0.0003333/segundo)
- **Bandwidth**: $0.10/GB (egress only, ingress free)
- **Object Storage**: $0.02/GB/mês (S3-compatible, Cloudflare R2)
- **Database Storage**: $10/mês per 10GB extra

**Free Tier:**
- ✅ **$50 free credit** para novos usuários
- ✅ **Static sites**: Unlimited (1GB limit, 100GB bandwidth, 600 build minutes/mês)
- ❌ **Sem compute tier permanente grátis**

**Managed PostgreSQL** (opcional):
- Starting **$5/mês**
- 25 regiões disponíveis (incluindo São Paulo)
- Auto daily backups
- Private network connections
- Vertical scaling on-demand

**25 Data Centers Globais:**

**Americas (10):**
- ✅ **São Paulo, Brazil** (`southamerica-east1`) ⬅️ **Brasil Region**
- Santiago, Chile (`southamerica-west1`)
- Montréal, Canada (`northamerica-northeast1`)
- 7 US locations (Iowa, S.Carolina, Virginia, Oregon, LA, Utah, Nevada)

**Europe (6):**
- London, Frankfurt, Belgium, Netherlands, Switzerland, Finland

**Asia-Pacific (9):**
- Tokyo, Osaka, Seoul, Singapore, Sydney, Hong Kong, Taiwan, Mumbai, Delhi

**Regiões "Boosted":** 8 localizações com C3D VMs (20-50% faster response times)

**Vantagens:**
- ✅ **Deploy ultra-rápido** (14s média, record do mercado)
- ✅ **Brasil region** (southamerica-east1 São Paulo)
- ✅ **88-95% latency reduction** vs US East para usuários BR
- ✅ **Infraestrutura premium** (GCP + Cloudflare global edge)
- ✅ **Pricing transparente** (dashboard real-time usage)
- ✅ **No seat-based pricing** (unlimited users/resources)
- ✅ **Suporte proativo** (live chat, monitoring)
- ✅ **Static sites grátis** (unlimited, ideal para landing pages)
- ✅ **Hibernation** (pause pods quando não usados, economize $$)
- ✅ **Unlimited parallel builds**
- ✅ **SOC II Type 2, ISO 27001** certified

**Desvantagens:**
- ❌ **Sem free tier compute** (apenas $50 credit inicial)
- ❌ **Nova plataforma** (lançado 2024, track record limitado)
- ❌ **22 reviews** no Trustpilot (pouca data pública)
- ⚠️ **Sem BEAM optimization** (é plataforma genérica K8s)
- ⚠️ **Sem distributed Erlang nativo** (clustering manual)
- ⚠️ **Hobby pods** não permitem custom domains
- ⚠️ **Sem CLI dedicado** (deploy via UI/Git push only)
- ⚠️ **Documentação Elixir limitada** (sem template Phoenix oficial)

**Caso de Uso Ideal:**
- Clientes Kinsta existentes (familiar ecosystem)
- Projetos **Brasil-focused** (região GRU critical)
- Teams que valorizam **DX moderno** (14s deploys, beautiful UI)
- Workloads com **tráfego variável** (hibernation feature)
- Projetos que precisam **GCP + Cloudflare** (sem gerenciar infra)
- Apps com landing pages estáticas (static hosting grátis)

**Não recomendado para:**
- Projetos que exigem **BEAM optimization** (use Fly.io/Gigalixir)
- Orçamento **zero permanente** (sem free tier)
- **Distributed Erlang clustering crítico** (requer setup manual complexo)
- Teams que precisam **CLI-first workflow** (Sevalla é UI-first)

**Latência Brasil (GCPing test):**
- São Paulo → southamerica-east1: **<5ms**
- São Paulo → us-east4 (Virginia): **~110ms**
- São Paulo → europe-west3 (Frankfurt): **~200ms**

**Comparação Rápida:**

| Feature | Sevalla | Fly.io | Railway | Render |
|---------|---------|--------|---------|--------|
| **Brasil Region** | ✅ GRU | ✅ GRU | ❌ | ❌ |
| **Entry Price** | $18/mês (C1) | $0 (free tier) | $5/mês | $0 (free tier) |
| **Deploy Speed** | 14s | ~30-60s | ~30-45s | ~60-120s |
| **Infrastructure** | GCP+Cloudflare | Own+Cloudflare | GCP/AWS | Own |
| **BEAM Optimization** | ❌ | ✅ | ❌ | ❌ |
| **Clustering** | Manual | ✅ DNS-based | Manual | Manual |
| **DX Score** | 8/10 | 9/10 | 8/10 | 7/10 |

**Recomendação Final:**

Sevalla é **excelente escolha** para:
- Projetos médios a grandes (**não hobbyist**)
- **Presença Brasil essencial** (região GRU)
- Teams que já usam **Kinsta** (familiar DX)
- Workloads **genéricos** (não BEAM-specific)

Para **BEAM features**, use **Fly.io** ($0 free tier + clustering nativo).
Para **budget zero**, use **Render** (free tier permanente).

---

### Tier 2: Plataformas Container-Based (Serverless/Managed)

Plataformas que rodam containers Docker, requerem containerização da app Phoenix.

#### 2.1 Google Cloud Run - Serverless Container Platform

**Status:** Melhor opção serverless para Elixir

**Por que escolher:**
- **Truly serverless:** Escala para zero, paga apenas quando usado
- **Global:** 35+ regiões incluindo `southamerica-east1` (São Paulo)
- **Billing granular:** Por 100ms de CPU time
- **Container-first:** Deploy qualquer Dockerfile

**Especificações Técnicas:**

**Dockerfile otimizado para Cloud Run:**

```dockerfile
# Build stage
FROM hexpm/elixir:1.16.0-erlang-26.2.1-alpine-3.19.0 AS build

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm python3

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV="prod"

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy application
COPY priv priv
COPY lib lib
COPY assets assets

# Compile assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# Compile app
RUN mix compile

# Build release
RUN mix release

# Runtime stage (smaller image)
FROM alpine:3.19.0

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

# Copy built application from build stage
COPY --from=build /app/_build/prod/rel/myapp ./

# Cloud Run requires app to listen on $PORT
ENV PORT=8080

CMD ["bin/myapp", "start"]
```

**Deploy para Cloud Run:**

```bash
# Build & push para Artifact Registry (suporta amd64 apenas)
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/myapp .
docker push gcr.io/PROJECT_ID/myapp

# Deploy
gcloud run deploy myapp \
  --image gcr.io/PROJECT_ID/myapp \
  --platform managed \
  --region southamerica-east1 \
  --allow-unauthenticated \
  --set-env-vars="SECRET_KEY_BASE=xxx,DATABASE_URL=yyy"

# Ou via Cloud Build (CI/CD)
gcloud builds submit --config=cloudbuild.yaml
```

**cloudbuild.yaml:**

```yaml
steps:
  # Build container
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '--platform', 'linux/amd64', '-t', 'gcr.io/$PROJECT_ID/myapp', '.']

  # Push to registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/myapp']

  # Deploy to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'myapp'
      - '--image=gcr.io/$PROJECT_ID/myapp'
      - '--region=southamerica-east1'
      - '--platform=managed'
      - '--allow-unauthenticated'

images:
  - 'gcr.io/$PROJECT_ID/myapp'
```

**Pricing Cloud Run 2025:**

| Recurso | Free Tier/Mês | Preço após free tier |
|---------|---------------|----------------------|
| **CPU** | 180k vCPU-segundos | $0.00002400/vCPU-segundo |
| **Memory** | 360k GiB-segundos | $0.00000250/GiB-segundo |
| **Requests** | 2 milhões | $0.40/milhão |
| **Networking** | 1GB egress | $0.12/GB |

**Exemplo de custo (app média):**
- 1 vCPU, 512MB RAM
- 100k requests/mês (50ms avg)
- ~**$5-10/mês** (maioria no free tier)

**Vantagens:**
- ✅ **Serverless** verdadeiro (escala para zero)
- ✅ **Billing granular** (100ms precision)
- ✅ **35+ regiões** incluindo São Paulo
- ✅ **Free tier generoso**
- ✅ **Integração GCP** (Cloud SQL, Secret Manager, etc)
- ✅ **Custom domains** grátis
- ✅ **HTTPS automático**

**Desvantagens:**
- ❌ **Cold start** (pode ser 1-3s primeira request)
- ❌ **Stateless** (não ideal para LiveView com sessions)
- ⚠️ **Containers devem ser amd64** (não arm64)
- ⚠️ **Complexity** maior (Google Cloud console)
- ⚠️ **Não ideal** para long-running connections (LiveView)

**Caso de Uso Ideal:**
- APIs Elixir serverless
- Workloads com tráfego variável (scale to zero)
- Já usa Google Cloud
- Budget-conscious (pay-per-use)

---

#### 2.2 AWS ECS/Fargate - Enterprise Container Platform

**Status:** Solução enterprise, high complexity

**Por que escolher:**
- **sa-east-1 (São Paulo)** region disponível
- Enterprise features (IAM, VPC, etc)
- Integração completa AWS ecosystem
- Compliance e security avançados

**Especificações Técnicas:**

**Task Definition (JSON):**

```json
{
  "family": "myapp",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "myapp",
      "image": "123456789.dkr.ecr.sa-east-1.amazonaws.com/myapp:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "PHX_HOST",
          "value": "myapp.example.com"
        },
        {
          "name": "PORT",
          "value": "8080"
        }
      ],
      "secrets": [
        {
          "name": "SECRET_KEY_BASE",
          "valueFrom": "arn:aws:secretsmanager:sa-east-1:123:secret:myapp-secret-key"
        },
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:sa-east-1:123:secret:myapp-db-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp",
          "awslogs-region": "sa-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

**Deploy com Terraform:**

```hcl
# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "myapp-cluster"
}

# ECS Service
resource "aws_ecs_service" "myapp" {
  name            = "myapp"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.myapp.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.myapp.arn
    container_name   = "myapp"
    container_port   = 8080
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "myapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = aws_subnet.public[*].id
}
```

**Pricing AWS ECS Fargate (sa-east-1) 2025:**

| Recurso | Preço/Hora | Mensal (24/7) |
|---------|-----------|---------------|
| **0.5 vCPU + 1GB RAM** | $0.04958 | ~$36/mês |
| **1 vCPU + 2GB RAM** | $0.09916 | ~$72/mês |
| **2 vCPU + 4GB RAM** | $0.19832 | ~$144/mês |

**+ ALB:** $18/mês + $0.008/LCU-hora
**+ RDS PostgreSQL:** $25-200+/mês

**Total típico:** **$80-300/mês** para produção básica

**Vantagens:**
- ✅ **sa-east-1 (São Paulo)** disponível
- ✅ **Enterprise features** (IAM, VPC, compliance)
- ✅ **Ecosystem AWS** completo
- ✅ **Auto-scaling** avançado
- ✅ **Blue/green deployments**
- ✅ **Service mesh** (App Mesh)

**Desvantagens:**
- ❌ **Alta complexidade** (VPC, IAM, Security Groups, etc)
- ❌ **Caro** ($80-300+/mês mínimo)
- ❌ **Curva de aprendizado** íngreme
- ⚠️ **Overhead operacional** alto
- ⚠️ **Não beginner-friendly**

**Caso de Uso Ideal:**
- Enterprise com infra AWS existente
- Compliance rigoroso necessário
- Team DevOps dedicado
- Budget $300+/mês

---

#### 2.3 Azure Container Apps - Alternativa Microsoft

**Status:** Melhor que App Service para Elixir, abstrai Kubernetes

**Deploy Example:**

```bash
# Build container
docker build -t myapp.azurecr.io/myapp .
docker push myapp.azurecr.io/myapp

# Deploy com Azure CLI
az containerapp create \
  --name myapp \
  --resource-group myapp-rg \
  --environment myapp-env \
  --image myapp.azurecr.io/myapp:latest \
  --target-port 8080 \
  --ingress external \
  --query properties.configuration.ingress.fqdn
```

**Pricing Azure Container Apps 2025:**

| Tier | vCPU | Memory | Preço/vCPU-hora | Preço/GB-hora |
|------|------|--------|-----------------|---------------|
| **Consumption** | 0.25-2 | 0.5-4GB | $0.0000024 | $0.0000004 |

**Exemplo:** 0.5 vCPU + 1GB RAM 24/7 = ~**$15/mês**

**Vantagens:**
- ✅ **Brazil South** region
- ✅ **Abstrai Kubernetes** (operational simplicity)
- ✅ **Integração Azure** (AD, Key Vault, etc)
- ✅ **Scaling automático**

**Desvantagens:**
- ⚠️ **Documentação Elixir limitada**
- ⚠️ **Community menor** vs AWS/GCP
- ⚠️ **Database connection issues** reportados

---

#### 2.4 Cloudflare Containers - Beta 2025

**Status:** 🆕 **Beta público junho 2025** - Extremamente promissor

**O que é:**
- Containers globais rodando no edge da Cloudflare
- 330+ locais de borda worldwide
- Integração tight com Workers
- **Could be game-changer** para Phoenix global

**Especificações Técnicas (Preview):**

```javascript
// Worker que controla container Phoenix
export default {
  async fetch(request, env) {
    const container = env.PHOENIX_CONTAINER;

    // Route request para container Elixir
    return await container.fetch(request);
  }
}
```

**Status Atual:**
- ✅ Beta público desde junho 2025
- ⚠️ Sem exemplos Elixir/Phoenix oficiais ainda
- ⚠️ Pricing não finalizado
- 🔮 **Potencial enorme** para edge Phoenix

**O que esperar:**
- **Global edge deployment** sem configuração
- **Latência <5ms** worldwide
- **Escala ilimitada** (Cloudflare network)
- **Pricing competitivo** (histórico Cloudflare)

**Vantagens Potenciais:**
- ✅ **330+ edge locations** (mais que qualquer outro)
- ✅ **Latência mínima** global
- ✅ **Integração Workers** poderosa
- ✅ **DDoS protection** nativa

**Desvantagens Atuais:**
- ❌ **Beta**, não production-ready ainda
- ❌ **Sem docs Elixir/Phoenix**
- ❌ **Pricing TBD**
- ⚠️ **Unknowns** técnicos (LiveView support?)

**Caso de Uso Futuro:**
- Phoenix APIs ultra-rápidas globally
- Edge computing com Elixir
- Substituir CDN + backend em um deploy

**Recomendação:** 🔮 **Watch closely** - pode revolucionar Phoenix deployment em 2026

---

### Tier 3: VPS/Manual Setup (Brasil-Specific)

Plataformas que oferecem VPS genérico, requerem setup manual completo.

#### 3.1 Hostinger Brasil - Budget VPS em São Paulo

**Status:** Única opção real para hosting **físico no Brasil** com budget baixo

**Especificações:**

**Planos VPS Hostinger (2025):**

| Plano | vCPU | RAM | Storage | Bandwidth | Preço/Mês |
|-------|------|-----|---------|-----------|-----------|
| **KVM 1** | 1 | 4GB | 50GB NVMe | 1TB | **R$ 19,99** (~$4) |
| **KVM 2** | 2 | 8GB | 100GB NVMe | 2TB | **R$ 29,99** (~$6) |
| **KVM 4** | 4 | 16GB | 200GB NVMe | 4TB | **R$ 59,99** (~$12) |

**Setup Manual Necessário:**

```bash
# SSH no VPS
ssh root@seu-vps-hostinger.com

# Install Erlang/Elixir (Ubuntu/Debian)
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
dpkg -i erlang-solutions_2.0_all.deb
apt-get update
apt-get install -y esl-erlang elixir

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Install Caddy (reverse proxy + SSL)
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" | tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install -y caddy

# Deploy app
git clone https://github.com/you/myapp
cd myapp
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

# Systemd service
cat > /etc/systemd/system/myapp.service <<EOF
[Unit]
Description=MyApp Phoenix
After=network.target

[Service]
Type=simple
User=myapp
WorkingDirectory=/home/myapp/myapp
ExecStart=/home/myapp/myapp/_build/prod/rel/myapp/bin/myapp start
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl enable myapp
systemctl start myapp

# Caddy reverse proxy
cat > /etc/caddy/Caddyfile <<EOF
myapp.com.br {
    reverse_proxy localhost:4000
}
EOF

systemctl reload caddy
```

**Vantagens:**
- ✅ **Datacenter em São Paulo** (latência local)
- ✅ **Preço imbatível** (R$ 19,99/mês = ~$4)
- ✅ **Root access** completo
- ✅ **Flexibilidade total**
- ✅ **Suporte em português**

**Desvantagens:**
- ❌ **Setup manual** complexo
- ❌ **Sem features Elixir** específicas
- ❌ **Você gerencia tudo** (OS, security, updates)
- ❌ **Sem clustering** fácil
- ⚠️ **Operational overhead** alto
- ⚠️ **Scaling** é manual

**Caso de Uso Ideal:**
- Budget extremamente limitado
- Latência local Brasil é crítica
- Equipe com expertise DevOps
- Hobby projects com audiência BR

---

#### 3.2 Locaweb, UOL Host, KingHost - Provedores Tradicionais BR

**Status:** VPS genérico, sem suporte Elixir específico

**Locaweb VPS Cloud:**
- Planos: R$ 29,90 - R$ 299/mês
- Datacenters: São Paulo
- Suporte: Português
- **Sem** buildpacks Elixir

**UOL Host Cloud VPS:**
- OpenStack-based
- Planos: R$ 39,90+/mês
- Datacenters: São Paulo
- **Sem** tooling Elixir

**KingHost VPS:**
- Planos: R$ 49,90+/mês
- Suporte renomado
- **Sem** Elixir-specific features

**Análise Geral:**
- ✅ Empresas brasileiras estabelecidas
- ✅ Suporte em português
- ✅ Billing em Reais
- ❌ **Custo maior** que Hostinger
- ❌ **Mesmas limitações** (setup manual)
- ❌ **Pior value** que Fly.io ou Railway

**Recomendação:** Use **apenas** se:
- Empresa exige fornecedor brasileiro
- Compliance requer dados no Brasil
- Já tem relacionamento com provider

**Melhor alternativa:** Fly.io region GRU oferece **latência comparável** com **muito melhor** DX e preço.

---

## 🚫 Plataformas Incompatíveis

### Vercel - JavaScript/Edge Only

**Por que não funciona:**
- Vercel Edge Functions = **JavaScript/TypeScript/WebAssembly** apenas
- Phoenix precisa **BEAM VM** (Erlang Virtual Machine)
- Arquiteturas incompatíveis (stateless vs stateful)

**Workaround teórico:**
- ❌ Não há workaround viável
- Backend Phoenix separado em Fly.io, frontend Vercel → funciona mas perde ponto do Phoenix

---

## 🧪 WebAssembly + Elixir: Estado Atual 2025

### Lumen/Firefly - Projeto Arquivado

**História:**
- **Lumen:** Implementação alternativa BEAM para WebAssembly
- **Firefly:** Rename do Lumen pela DockYard
- **Status:** Repositório arquivado **junho 2024**
- **Última atividade:** Outubro 2023

**O que era:**
```elixir
# Compilar Elixir para WASM (objetivo)
mix compile.wasm
# Output: myapp.wasm rodando no browser
```

**Por que não funcionou:**
- Complexidade enorme (reimplementar BEAM)
- Funding insuficiente
- Casos de uso limitados (LiveView usa WebSockets, não precisa WASM)

**Alternativas Atuais:**

**1. Phoenix LiveView (Já é "como WASM"):**
```elixir
# LiveView oferece interatividade sem WASM
defmodule MyAppWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @count %></h1>
      <button phx-click="inc">+</button>
    </div>
    """
  end

  def handle_event("inc", _, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end
end

# Roda no servidor, atualiza UI via WebSocket
# Sem necessidade de WASM
```

**2. Orb (Elixir DSL para WASM):**
- Projeto recente: Escrever WASM usando Elixir syntax
- **Não** compila Elixir para WASM
- **Sim** usa Elixir para **gerar** WASM
- Caso de uso: WASM modules específicos, não apps Phoenix

**Conclusão WebAssembly:**
- ❌ **Não há** solução production-ready Elixir → WASM
- ✅ **LiveView resolve** 90% dos casos de uso
- 🔮 **Orb** é interessante para WASM modules, não full apps

---

## 🤖 Integração com Claude e Ferramentas IA

### Claude Code SDK para Elixir

**Package Official:**
```elixir
# mix.exs
def deps do
  [
    {:claude_code, "~> 0.3.0"}
  ]
end
```

**Features:**
- ✅ **Native streaming** de respostas
- ✅ **Automatic conversation continuity**
- ✅ **Production-ready supervision** (GenServers fault-tolerant)
- ✅ **Drop-in compatibility** com LiveView e Phoenix

**Usage Example:**

```elixir
# Iniciar na supervision tree
children = [
  {ClaudeCode, api_key: System.get_env("ANTHROPIC_API_KEY")}
]

# Usar em qualquer lugar da app
{:ok, response} = ClaudeCode.chat("Explique o BEAM")

# LiveView integration
defmodule MyAppWeb.ChatLive do
  use Phoenix.LiveView

  def handle_event("send_message", %{"message" => msg}, socket) do
    {:ok, response} = ClaudeCode.chat(msg)
    {:noreply, assign(socket, response: response)}
  end
end
```

**Deployment Compatibility:**

| Plataforma | Claude SDK Support | Notes |
|-----------|-------------------|-------|
| **Fly.io** | ✅ Excelente | Fly knows Phoenix, deploy automático |
| **Gigalixir** | ✅ Funciona | Standard Elixir app |
| **Render** | ✅ Funciona | Via env vars |
| **Railway** | ✅ Funciona | Auto-detect |
| **Cloud Run** | ✅ Funciona | Container-based |
| **AWS ECS** | ✅ Funciona | Container-based |
| **Azure** | ✅ Funciona | Container Apps |

**MCP (Model Context Protocol) Integration:**

```elixir
# Tidewave MCP Server para Phoenix
# Claude auto-configura para projects Phoenix

# Features:
# - Phoenix-specific tools
# - Database introspection
# - Route analysis
# - LiveView helpers
```

**Deploy com Claude:**

```bash
# Claude Code entende deployment
# Prompt: "Deploy minha app Phoenix para Fly.io"

# Claude executa:
fly launch --auto-confirm
fly deploy
fly open

# Ou para Railway:
# "Deploy para Railway"
railway login
railway init
railway up
```

**Claude Best Practices para Phoenix:**
- ✅ Use `claude_code` package para AI features
- ✅ Configure MCP Tidewave para Phoenix tooling
- ✅ Deploy em Fly.io (Claude tem integration oficial)
- ✅ Use secrets management (não hardcode API keys)

---

## 🎯 Matrizes de Decisão

### Por Orçamento Mensal

| Orçamento | Recomendação | Specs | Trade-offs |
|-----------|--------------|-------|------------|
| **$0** | **Fly.io Free** | 256MB × 3 VMs | Sleep após inatividade |
| **$5-10** | **Railway Hobby** | 512MB-1GB | Pay-per-use pode crescer |
| **$10-25** | **Gigalixir Standard** | 512MB | Poucos recursos vs Fly |
| **$25-50** | **Fly.io Production** | 1-2GB × 2-3 VMs | Best value production |
| **$50-100** | **Render Standard** | 2GB + workers | Pricing previsível |
| **$100-300** | **AWS ECS** | 2-4GB + RDS | Enterprise features |
| **$300+** | **AWS/GCP/Azure** | Custom | Total controle |

### Por Nível de Expertise

| Experiência | Recomendação | Por quê |
|-------------|--------------|---------|
| **Beginner** | **Fly.io** | `fly launch` = auto-configure tudo |
| **Beginner** | **Railway** | UI mais simples, GitHub integration |
| **Intermediate** | **Render** | Balance features/complexity |
| **Intermediate** | **Gigalixir** | BEAM features, CLI amigável |
| **Advanced** | **Google Cloud Run** | Serverless, otimização custo |
| **Expert** | **AWS ECS + Terraform** | Controle total, enterprise |

### Por Casos de Uso

#### LiveView App Intensivo

**Recomendação:** 🥇 **Fly.io** ou 🥈 **Gigalixir**

**Por quê:**
- WebSocket connections persistentes
- Clustering multi-region (Fly)
- In-memory state (Gigalixir)
- ❌ **Evite:** Cloud Run (stateless, cold starts ruins LiveView UX)

#### API REST/GraphQL

**Recomendação:** 🥇 **Cloud Run** ou 🥈 **Render**

**Por quê:**
- Stateless = perfeito para serverless
- Scaling automático
- Pay-per-use (Cloud Run)
- ❌ **Evite:** Gigalixir (overkill para API stateless)

#### MVP/Protótipo Rápido

**Recomendação:** 🥇 **Railway** ou 🥈 **Fly.io**

**Por quê:**
- Deploy em minutos
- GitHub integration
- Simple DX
- Pode migrar depois se crescer

#### Background Jobs Pesados

**Recomendação:** 🥇 **Render** ou 🥈 **Fly.io**

**Por quê:**
- Render tem workers nativos
- Fly permite scaling de worker nodes separadamente
- ❌ **Evite:** Cloud Run (timeout requests, não ideal para long jobs)

#### Global Distribution

**Recomendação:** 🥇 **Fly.io** (23 regiões)

**Por quê:**
- Multi-region single command
- DNS clustering automático
- 🔮 **Futuro:** Cloudflare Containers (330+ locations)

#### Brasil-Specific Compliance

**Recomendação:** 🥇 **Hostinger VPS SP** ou 🥈 **AWS sa-east-1**

**Por quê:**
- Dados **físicamente** no Brasil
- Compliance LGPD
- ⚠️ **Trade-off:** Operational overhead alto

---

## 📋 Checklist de Deploy: Phoenix em Produção

### Pré-Deployment

- [ ] **Database:** PostgreSQL configurado? (`Ecto.Adapters.Postgres`)
- [ ] **Secrets:** `SECRET_KEY_BASE` gerado? (`mix phx.gen.secret`)
- [ ] **Environment:** `MIX_ENV=prod` configurado?
- [ ] **Assets:** Compilados? (`mix assets.deploy`)
- [ ] **Release:** Build testado? (`MIX_ENV=prod mix release`)
- [ ] **Health check:** Endpoint `/health` implementado?
- [ ] **Migrations:** Strategy definida? (manual ou automático)

### Configuração Produção

**config/runtime.exs:**

```elixir
import Config

if config_env() == :prod do
  # Database
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      """

  config :myapp, MyApp.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: [:inet6]  # Importante para Fly.io/Railway

  # Endpoint
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :myapp, MyAppWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},  # IPv6
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true  # Crítico!
end
```

### Post-Deployment

- [ ] **SSL:** HTTPS funcionando?
- [ ] **Logs:** Logging configurado?
- [ ] **Monitoring:** Métricas coletadas?
- [ ] **Alerts:** Alertas configurados?
- [ ] **Backups:** Database backup automático?
- [ ] **Rollback:** Plano de rollback testado?

---

## 🚀 Quick Start Guides

### Deploy para Fly.io (5 minutos)

```bash
# 1. Install flyctl
curl -L https://fly.io/install.sh | sh

# 2. Login
fly auth login

# 3. Na pasta do projeto Phoenix
fly launch
# Responda prompts:
# - App name: myapp
# - Region: gru (São Paulo)
# - PostgreSQL: Yes
# - Redis: No (unless needed)

# 4. Deploy
fly deploy

# 5. Open
fly open

# 6. Logs
fly logs

# 7. SSH (se precisar debug)
fly ssh console

# 8. Scale (multi-region)
fly scale count 2 --region gru
fly scale count 2 --region iad  # US East

# 9. Database console
fly postgres connect -a myapp-db

# 10. Secrets (env vars sensíveis)
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
```

### Deploy para Railway (2 minutos via UI)

1. **GitHub:** Push projeto para GitHub
2. **Railway:** https://railway.app/new
3. **Import:** Selecione repo Phoenix
4. **Variables:** Adicione `SECRET_KEY_BASE` (generate: `mix phx.gen.secret`)
5. **PostgreSQL:** Clique "Add PostgreSQL" (auto-conecta)
6. **Deploy:** Railway detecta Phoenix, faz deploy automático
7. **Domain:** Generate domain para ver app live

### Deploy para Cloud Run (Container)

```bash
# 1. Build container (certifique-se Dockerfile existe)
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/myapp .

# 2. Push
docker push gcr.io/PROJECT_ID/myapp

# 3. Deploy
gcloud run deploy myapp \
  --image gcr.io/PROJECT_ID/myapp \
  --region southamerica-east1 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars="SECRET_KEY_BASE=$(mix phx.gen.secret),DATABASE_URL=your-db-url"

# 4. Get URL
gcloud run services describe myapp --region southamerica-east1 --format="value(status.url)"
```

---

## 📊 Comparação Final: Top 3 Recomendações

### 🥇 #1: Fly.io - Melhor Geral

**Score:** 9.5/10

**Por quê:**
- Suporte oficial Phoenix
- Free tier generoso
- 23 regiões (incluindo GRU)
- Clustering fácil
- Melhor DX

**Use se:**
- Quer melhor experiência Phoenix
- Precisa multi-region
- Valoriza free tier
- Quer deploy rápido mas production-ready

**Evite se:**
- Budget $0 absoluto (free tier dorme)
- Precisa compliance Brasil estrito

**Preço típico produção:** $25-50/mês (2-3 VMs 1GB)

---

### 🥈 #2: Railway - Melhor DX

**Score:** 8.5/10

**Por quê:**
- UI incrível
- GitHub integration seamless
- Deploy mais rápido
- Templates prontos

**Use se:**
- Protótipo/MVP urgente
- Valoriza UI/UX acima de tudo
- Startup early-stage

**Evite se:**
- Budget super apertado ($5 mínimo)
- Precisa BEAM features avançados

**Preço típico produção:** $20-40/mês

---

### 🥉 #3: Gigalixir - Melhor para BEAM

**Score:** 8/10

**Por quê:**
- Único 100% BEAM-native
- Hot upgrades
- Remote observer
- Clustering nativo

**Use se:**
- Usa distributed Erlang intensivamente
- Hot upgrades são requisito
- Quer aproveitar 100% BEAM

**Evite se:**
- Budget muito limitado ($10 mínimo)
- Precisa multi-region global
- Quer features modernas (Railway/Fly DX melhor)

**Preço típico produção:** $25-50/mês

---

## 🎓 Próximos Passos

### Para Beginners

1. **Comece:** Fly.io free tier
2. **Aprenda:** Deploy básico seguindo guia oficial
3. **Pratique:** Deploy MVP, teste clustering
4. **Escale:** Quando tiver tráfego real, considere paid tier

### Para Times Estabelecidos

1. **Avalie:** Needs específicos (LiveView? API? Jobs?)
2. **Compare:** Top 3 baseado em caso de uso
3. **Teste:** Deploy staging em 2-3 plataformas
4. **Decida:** Baseado em DX, performance, custo
5. **Migrate:** Gradualmente se já tem app rodando

### Para Enterprise

1. **Compliance:** Defina requisitos (Brasil data? LGPD?)
2. **Security:** Avalie posture (VPC? SOC2?)
3. **Cost:** Projete custo 3 anos (AWS/GCP pode ser melhor long-term)
4. **Expertise:** Avalie team (DevOps expertise in-house?)
5. **Vendor:** Escolha baseado em total picture, não só price

---

## 📚 Recursos Adicionais

### Documentação Oficial

- **Fly.io Elixir:** https://fly.io/docs/elixir/
- **Gigalixir Docs:** https://gigalixir.readthedocs.io/
- **Railway Phoenix:** https://docs.railway.com/guides/phoenix
- **Render Phoenix:** https://render.com/docs/deploy-phoenix
- **Phoenix Deployment:** https://hexdocs.pm/phoenix/deployment.html

### Templates e Exemplos

- **Fly.io Phoenix Template:** https://github.com/fly-apps/hello_elixir
- **Railway Phoenix Template:** https://github.com/railwayapp-templates/phoenix
- **Docker Phoenix:** https://github.com/moosch/elixir-cloud-run

### Community

- **Elixir Forum Deployment:** https://elixirforum.com/c/help/deployment
- **Fly.io Phoenix Community:** https://community.fly.io/c/phoenix
- **Phoenix Discord:** #deployment channel

---

**Última atualização:** Outubro 2025
**Versão:** 1.0.0

---

## 🔮 Tendências Futuras

### 2026: O Ano do Edge Elixir?

**Cloudflare Containers + Phoenix:**
- Se Cloudflare Containers se consolidar, pode mudar o jogo
- 330+ edge locations vs 23 Fly.io regions
- Potencial para **<5ms latency globally**

**Fly.io vs Cloudflare:**
- Fly.io tem head start (anos de experiência Phoenix)
- Cloudflare tem network advantage (muito maior)
- **Outcome:** Competição saudável = melhores produtos

### AI-Native Deployment

**Claude Code + MCP:**
- Deploy conversational: "Deploy para produção com 3 regions"
- Rollback inteligente: "Volte deploy anterior, tráfego caiu 50%"
- Scaling automático: IA detecta patterns, sugere scaling

**Futuro Possível (2027):**
```
Developer: "Deploy Phoenix app globally, optimize for latency"

Claude: [Analisa app, detecta LiveView intensivo]
        "Deploying to Fly.io (melhor para LiveView stateful)
        Regions: GRU, IAD, FRA, SYD (coverage Americas+Europe)
        VMs: 2GB × 2 per region (baseline)
        Auto-scaling: enabled
        Estimated cost: $80-120/mês

        Deploy? [yes/no/customize]"

Developer: "yes"

Claude: [Executes deployment, sets up monitoring, configures alerts]
        "✅ Deployed. Live at: https://myapp.fly.dev
        ✅ All regions healthy
        ✅ Monitoring configured
        ✅ Alerts set for 95th percentile latency >100ms

        Next: Setup CI/CD? Add staging environment?"
```

---

**Este guia será atualizado semestralmente com novos providers e pricing.**
