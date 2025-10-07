# Hosting Comparison Matrix: Elixir Phoenix Platforms 2025

Matriz comparativa detalhada de **14 plataformas** de hospedagem para aplicações Elixir e Phoenix Framework, incluindo capacidades de **pay-per-crawl** para monetização de AI crawlers.

## Tabela Mestra: Comparação Completa

| Platform | Type | Elixir Native | Pricing Start | Free Tier | Brasil/LATAM | Pay-Per-Crawl | Clustering | LiveView | Score |
|----------|------|---------------|---------------|-----------|--------------|---------------|------------|----------|-------|
| **Fly.io** | PaaS | ✅ Buildpack | $0/mo | ✅ 256MB×3 | 🟡 GRU region | ⚠️ Custom Plug | ✅ DNS | ✅ Excellent | **9.5** |
| **Gigalixir** | PaaS | ✅ Native BEAM | $10/mo | ✅ 200MB×1 | ❌ | ⚠️ Plug middleware | ✅ Native | ✅ Good | **9.0** |
| **Railway** | PaaS | ✅ Auto-detect | $5/mo | ❌ | ❌ | ⚠️ Custom Plug | ⚠️ Manual | ✅ Good | **8.0** |
| **Render** | PaaS | ✅ Buildpack | $7/mo | ✅ Sleep | ❌ | ⚠️ Custom Plug | ⚠️ Manual | ✅ Good | **8.5** |
| **Sevalla** | PaaS | ✅ Nixpacks | $18/mo | $50 credit | ✅ GRU region | 🟡 Cloudflare edge | ⚠️ Manual | ✅ Good | **8.0** |
| **Google Cloud Run** | Serverless | 🟡 Container | Pay-per-use | ✅ Generous | 🟡 southamerica-east1 | 🟡 Cloud Armor | ❌ | ⚠️ Limited | **7.5** |
| **AWS ECS** | Container | 🟡 Fargate | $30+/mo | ❌ | 🟡 sa-east-1 | ✅ WAF + Shield | ⚠️ Complex | ✅ | **7.0** |
| **Azure Container Apps** | Container | 🟡 Container | $15+/mo | ❌ | 🟡 Brazil South | 🟡 App Gateway WAF | ⚠️ Complex | ✅ | **6.5** |
| **Cloudflare Containers** | Edge | 🟡 Beta | TBD | ❓ | ✅ Global edge | ✅ Bot Management | ❓ | ❓ | **7.0?** |
| **Hostinger BR** | VPS | ❌ Manual | R$20/mo | ❌ | ✅ São Paulo DC | ❌ DIY total | ❌ | ✅ Manual | **5.0** |
| **Locaweb** | VPS | ❌ Manual | R$30+/mo | ❌ | ✅ São Paulo | ❌ DIY | ❌ | ✅ Manual | **4.5** |
| **UOL Host** | VPS | ❌ Manual | R$40+/mo | ❌ | ✅ São Paulo | ❌ DIY | ❌ | ✅ Manual | **4.5** |
| **KingHost** | VPS | ❌ Manual | R$50+/mo | ❌ | ✅ São Paulo | ❌ DIY | ❌ | ✅ Manual | **4.0** |
| **Vercel** | Edge | ❌ Incompatível | N/A | ❌ | ❌ | ❌ | ❌ | ❌ | **0.0** |

**Pay-Per-Crawl Legend:**
- ✅ Native bot management/WAF with ML detection
- 🟡 Infraestrutura suporta (Cloudflare/Cloud Armor) mas requer configuração
- ⚠️ DIY via Phoenix Plug (user-agent detection, rate limiting)
- ❌ Sem suporte (VPS manual total)

---

## Matriz de Pricing Detalhado (USD/mês)

### Tier Hobby/Development

| Platform | Specs | Monthly Cost | Annual Cost | Notes |
|----------|-------|--------------|-------------|-------|
| **Fly.io Free** | 256MB × 3 VMs | **$0** | **$0** | Sleeps after inactivity |
| **Gigalixir Free** | 200MB × 1 VM | **$0** | **$0** | Single instance only |
| **Render Free** | 512MB × 1 VM | **$0** | **$0** | Sleeps after 15min |
| **Railway Hobby** | Pay-per-use | **$5 minimum** | **$60** | $5 credit/month |
| **Sevalla Credit** | Initial credit | **$0** (+ $50 credit) | **$0** | $50 one-time, then pay-per-use |
| **Cloud Run Free** | 180k vCPU-sec | **$0-5** | **$0-60** | Pay actual use |
| **Hostinger VPS** | 1 vCPU 4GB | **$4** (R$20) | **$48** | Manual setup |

### Tier Production Small (1-2GB RAM)

| Platform | Specs | Monthly Cost | Annual Cost | Cost per GB RAM |
|----------|-------|--------------|-------------|-----------------|
| **Fly.io** | 1GB × 2 VMs | **$12-15** | **$144-180** | **$6-7.50** |
| **Gigalixir** | 1GB × 2 VMs | **$25-30** | **$300-360** | **$12.50-15** |
| **Railway** | 1GB 24/7 | **$20-25** | **$240-300** | **$20-25** |
| **Render Standard** | 2GB × 1 VM | **$25** | **$300** | **$12.50** |
| **Sevalla M1** | 0.5 CPU 2GB | **$20** | **$240** | **$10** |
| **Sevalla S2** | 1 CPU 2GB | **$40** | **$480** | **$20** |
| **Cloud Run** | 1GB avg usage | **$10-15** | **$120-180** | **$10-15** |
| **AWS ECS** | 1 vCPU 2GB | **$72 + ALB** | **$900+** | **$36** |
| **Azure** | 0.5 vCPU 1GB | **$15-20** | **$180-240** | **$15-20** |
| **Hostinger VPS** | 2 vCPU 8GB | **$6** (R$30) | **$72** | **$0.75** |

### Tier Production Medium (4-8GB RAM)

| Platform | Specs | Monthly Cost | Annual Cost | Notes |
|----------|-------|--------------|-------------|-------|
| **Fly.io** | 4GB × 3 VMs | **$90-120** | **$1080-1440** | Multi-region |
| **Gigalixir** | 4GB × 3 VMs | **$150-180** | **$1800-2160** | Full BEAM features |
| **Render Pro** | 4GB × 2 VMs | **$170** | **$2040** | Workers included |
| **Sevalla M3** | 2 CPU 8GB | **$135** | **$1620** | GCP + Cloudflare |
| **Sevalla S4** | 4 CPU 8GB | **$160** | **$1920** | Standard tier |
| **Cloud Run** | 4GB avg | **$40-80** | **$480-960** | Serverless |
| **AWS ECS** | 2 vCPU 4GB × 2 | **$300+** | **$3600+** | + RDS + ALB |
| **Hostinger VPS** | 4 vCPU 16GB | **$12** (R$60) | **$144** | Manual |

**Key Insights:**
- **Melhor custo/benefício hobby:** Fly.io (free tier + $0-15/mês small prod)
- **Melhor custo absoluto Brasil:** Hostinger ($4-12/mês mas manual)
- **Mais caro:** AWS ECS ($300+/mês production média)
- **Mais previsível:** Render (flat tiers)
- **Mais variável:** Railway, Cloud Run (pay-per-use)

---

## Matriz de Regiões e Latência

### Americas Coverage

| Platform | Regions | Brasil | LATAM | North America | Latency BR (est) |
|----------|---------|--------|-------|---------------|------------------|
| **Fly.io** | 7 Americas | GRU (São Paulo) | SCL, QRO | IAD, LAX, ORD, YYZ, EWR | **<10ms local** |
| **Sevalla** | 10 Americas | southamerica-east1 (SP) | Santiago, Chile | 7 US locations + Montréal | **<5ms local** |
| **Google Cloud** | 6 Americas | southamerica-east1 | Santiago | 5 US regions | **<15ms local** |
| **AWS** | 5 Americas | sa-east-1 (SP) | - | 4 US regions | **<20ms local** |
| **Azure** | 4 Americas | Brazil South | - | 3 US regions | **<25ms local** |
| **Cloudflare** | **330+** global | **All** (edge) | **All** | **All** | **<5ms edge** |
| **Gigalixir** | 2 (GCP/AWS) | ❌ Use US | ❌ | us-central1, us-east1 | **150-200ms** |
| **Railway** | US only | ❌ | ❌ | US East | **150-200ms** |
| **Render** | Oregon only | ❌ | ❌ | US West | **200-250ms** |
| **Hostinger** | 1 BR | ✅ São Paulo | ❌ | ❌ | **<5ms local** |

**Latency Estimates para usuário em São Paulo:**

| Platform | BR User Latency | Global Average | Best For |
|----------|-----------------|----------------|----------|
| **Sevalla GRU** | <5ms | 50-150ms | GCP + Cloudflare BR |
| **Fly.io GRU** | <10ms | 50-150ms | Global + BR |
| **Cloud Run SA** | <15ms | 80-200ms | Serverless BR |
| **AWS sa-east-1** | <20ms | 100-250ms | Enterprise BR |
| **Hostinger SP** | <5ms | N/A | BR-only |
| **Cloudflare Edge** | <5ms | <50ms | Ultra-low latency |
| **Railway US** | 150-200ms | 50-150ms | US-focused |

---

## Matriz de Features Elixir/BEAM

| Feature | Fly.io | Gigalixir | Railway | Render | Cloud Run | AWS ECS | Hostinger |
|---------|--------|-----------|---------|--------|-----------|---------|-----------|
| **Buildpack Elixir** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Auto-detect Phoenix** | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| **Distributed Erlang** | ✅ | ✅ | ⚠️ | ⚠️ | ❌ | ⚠️ | ⚠️ |
| **DNS Clustering** | ✅ | ✅ | ❌ | ❌ | ❌ | ⚠️ | ❌ |
| **Hot Code Upgrades** | ⚠️ | ✅ | ❌ | ❌ | ❌ | ⚠️ | ✅ |
| **Remote Observer** | ⚠️ | ✅ | ❌ | ❌ | ❌ | ⚠️ | ✅ |
| **Remote Console** | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ✅ |
| **Persistent Connections** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ |
| **LiveView Optimized** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Ecto Migrations Auto** | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ❌ | ❌ |
| **Mix Tasks Remote** | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ✅ |

**Legend:**
- ✅ Natively supported / Out-of-box
- ⚠️ Possible with configuration
- ❌ Not supported / Very difficult

**BEAM Feature Score (0-10):**

1. **Gigalixir:** 10/10 (100% BEAM features)
2. **Fly.io:** 9/10 (Most features, excellent docs)
3. **Hostinger VPS:** 8/10 (Manual but full control)
4. **Railway/Render:** 6/10 (Basic support)
5. **AWS/GCP/Azure:** 5/10 (Container-based, manual)
6. **Cloud Run:** 3/10 (Stateless limitations)

---

## Matriz de DX (Developer Experience)

| Aspect | Fly.io | Railway | Gigalixir | Render | Cloud Run | AWS | Hostinger |
|--------|--------|---------|-----------|--------|-----------|-----|-----------|
| **First Deploy Time** | 5 min | **2 min** | 8 min | 10 min | 15 min | 60+ min | 120+ min |
| **CLI Quality** | **10/10** | 9/10 | 7/10 | 8/10 | 8/10 | 6/10 | N/A |
| **UI Quality** | 8/10 | **10/10** | 6/10 | 9/10 | 7/10 | 5/10 | 6/10 |
| **Documentation** | **10/10** | 8/10 | 7/10 | 9/10 | 8/10 | 9/10 | 5/10 |
| **Phoenix-Specific Docs** | **10/10** | 8/10 | 9/10 | 8/10 | 5/10 | 4/10 | 2/10 |
| **Error Messages** | **10/10** | 8/10 | 6/10 | 8/10 | 7/10 | 5/10 | N/A |
| **Logs Access** | **10/10** | **10/10** | 7/10 | 9/10 | 8/10 | 7/10 | 8/10 |
| **Metrics/Monitoring** | 9/10 | 7/10 | 5/10 | 8/10 | **10/10** | **10/10** | 4/10 |
| **Secrets Management** | **10/10** | 9/10 | 7/10 | 9/10 | 9/10 | **10/10** | Manual |
| **Git Integration** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ❌ |
| **CI/CD Built-in** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ❌ |
| **Rollback Ease** | **1-click** | **1-click** | CLI | **1-click** | CLI | Complex | Manual |

**Overall DX Score:**

1. **Fly.io:** 9.5/10 (Best CLI, great docs)
2. **Railway:** 9/10 (Best UI, fastest deploy)
3. **Render:** 8.5/10 (Balanced, predictable)
4. **Gigalixir:** 7/10 (BEAM-focused, simpler than cloud)
5. **Cloud Run:** 7/10 (Good for GCP users)
6. **AWS:** 5/10 (Powerful but complex)
7. **Hostinger:** 3/10 (Manual everything)

---

## Matriz de Casos de Uso

### Use Case: LiveView-Heavy Application

| Platform | Score | Why | Monthly Cost (prod) |
|----------|-------|-----|---------------------|
| **Fly.io** | **10/10** | Persistent connections, clustering, docs | $25-50 |
| **Gigalixir** | **9/10** | Native BEAM, in-memory state | $25-50 |
| **Railway** | 7/10 | Works, simple setup | $20-40 |
| **Render** | 7/10 | Works, persistent disks | $25-85 |
| **AWS ECS** | 6/10 | Works but overkill | $100+ |
| **Cloud Run** | **3/10** | Cold starts ruin UX | $10-30 |
| **Hostinger** | 5/10 | Manual but workable | $6-12 |

### Use Case: REST/GraphQL API

| Platform | Score | Why | Monthly Cost |
|----------|-------|-----|--------------|
| **Cloud Run** | **10/10** | Serverless, pay-per-use, perfect fit | $5-20 |
| **Fly.io** | 9/10 | Overkill but excellent | $10-30 |
| **Railway** | 9/10 | Simple, fast deploy | $15-30 |
| **Render** | 8/10 | Predictable pricing | $7-25 |
| **Gigalixir** | 6/10 | Overkill for stateless | $10-30 |
| **AWS ECS** | 7/10 | Enterprise features | $50+ |

### Use Case: Background Jobs Heavy

| Platform | Score | Why | Cost |
|----------|-------|-----|------|
| **Render** | **10/10** | Native workers included | $25-85 |
| **Fly.io** | 9/10 | Separate worker VMs easy | $20-60 |
| **Railway** | 8/10 | Simple worker setup | $20-50 |
| **Gigalixir** | 8/10 | BEAM processes native | $25-50 |
| **Cloud Run** | **3/10** | 15min timeout | $10+ |
| **AWS ECS** | 9/10 | ECS tasks for jobs | $80+ |

### Use Case: Global Multi-Region

| Platform | Score | Regions | Cost |
|----------|-------|---------|------|
| **Fly.io** | **10/10** | 23, easy multi-region | $50-150 |
| **Cloudflare** | **10/10?** | 330+ (when mature) | TBD |
| **AWS** | 9/10 | All regions, complex | $200+ |
| **GCP** | 9/10 | All regions, complex | $150+ |
| **Azure** | 8/10 | All regions, complex | $150+ |
| **Others** | 2/10 | Single/limited regions | N/A |

### Use Case: Brasil-Only Compliance

| Platform | Score | Why | Cost |
|----------|-------|-----|------|
| **Hostinger BR** | **9/10** | Physical Brazil, cheapest | $4-12 |
| **AWS sa-east-1** | 8/10 | Enterprise, compliant | $100+ |
| **GCP SA** | 7/10 | Good but complex | $80+ |
| **Azure BR** | 7/10 | Good but limited docs | $80+ |
| **Fly.io GRU** | **6/10** | Global company, GRU region | $15+ |
| **Others** | 2/10 | No Brazil presence | N/A |

---

## Matriz de Limitações e Trade-offs

### Fly.io

**Pros:**
- ✅ Best Phoenix DX
- ✅ Free tier generous
- ✅ 23 regions
- ✅ Excellent clustering

**Cons:**
- ⚠️ IPv4 costs $2/mo extra
- ⚠️ Free tier sleeps
- ⚠️ Can get expensive at scale

**Best For:** Production Phoenix, global apps
**Avoid If:** Need $0 absolute, Brasil compliance strict

---

### Gigalixir

**Pros:**
- ✅ 100% BEAM features
- ✅ Hot upgrades
- ✅ Remote observer
- ✅ In-memory state preserved

**Cons:**
- ❌ No Brasil/LATAM regions
- ⚠️ Fewer regions than Fly
- ⚠️ Less polished UI/UX

**Best For:** BEAM-heavy apps, distributed Erlang
**Avoid If:** Need multi-region global, Brasil latency critical

---

### Railway

**Pros:**
- ✅ Best UI/UX
- ✅ Fastest deploy (2min)
- ✅ GitHub integration seamless
- ✅ Simple pricing

**Cons:**
- ❌ No free tier ($5 minimum)
- ❌ Single region (US)
- ⚠️ Pay-per-use can grow

**Best For:** MVPs, prototypes, early-stage startups
**Avoid If:** Need free tier, multi-region, Brasil users

---

### Render

**Pros:**
- ✅ Workers built-in
- ✅ Flat predictable pricing
- ✅ Persistent disks included
- ✅ Good balance features/simplicity

**Cons:**
- ❌ Free tier sleeps (15min)
- ❌ Single region (Oregon)
- ⚠️ Can be pricey ($85+ pro)

**Best For:** Production apps with jobs, predictable costs
**Avoid If:** Need multi-region, Brasil latency

---

### Cloud Run

**Pros:**
- ✅ True serverless (scale to zero)
- ✅ Pay-per-100ms (granular billing)
- ✅ 35+ regions (southamerica-east1)
- ✅ Generous free tier

**Cons:**
- ❌ Cold starts (1-3s)
- ❌ Not ideal for LiveView
- ⚠️ Stateless architecture

**Best For:** APIs, serverless workloads, variable traffic
**Avoid If:** LiveView-heavy, need persistent connections

---

### AWS ECS

**Pros:**
- ✅ sa-east-1 (São Paulo)
- ✅ Enterprise features
- ✅ Full AWS ecosystem
- ✅ Compliance ready

**Cons:**
- ❌ High complexity
- ❌ Expensive ($100+/mo minimum)
- ⚠️ Steep learning curve

**Best For:** Enterprise, AWS shops, compliance needs
**Avoid If:** Small team, limited budget, beginners

---

### Hostinger Brasil

**Pros:**
- ✅ Physical São Paulo DC
- ✅ Cheapest ($4/mo)
- ✅ Full root access
- ✅ Suporte português

**Cons:**
- ❌ Manual everything
- ❌ No Elixir tooling
- ❌ High operational overhead

**Best For:** Budget Brasil projects, DevOps expertise in-house
**Avoid If:** Want managed service, no DevOps team

---

## Decision Matrix: Quick Selector

### If You Value...

#### Speed of Deployment
1. **Railway** (2 min)
2. **Fly.io** (5 min)
3. **Render** (10 min)

#### Cost Optimization
1. **Fly.io free tier** ($0)
2. **Hostinger** ($4/mo)
3. **Cloud Run** ($5-15/mo)

#### Elixir/BEAM Features
1. **Gigalixir** (10/10)
2. **Fly.io** (9/10)
3. **Hostinger VPS** (8/10 with manual setup)

#### Global Performance
1. **Cloudflare** (330+ edge, future)
2. **Fly.io** (23 regions, now)
3. **AWS/GCP/Azure** (complex)

#### Brasil-Specific
1. **Hostinger** (São Paulo DC, cheap)
2. **AWS sa-east-1** (enterprise)
3. **Fly.io GRU** (best DX with Brasil region)

#### Simplicity/DX
1. **Railway** (best UI)
2. **Fly.io** (best CLI)
3. **Render** (balanced)

---

## Migration Paths

### From Heroku

**Best Target:** Railway ou Fly.io

**Why:**
- Similar workflow (git push deploy)
- Buildpacks compatible
- Smooth migration path

**Steps:**
1. Railway: Connect GitHub, auto-deploy
2. Fly.io: `fly launch`, migrate DB, cutover DNS

---

### From Custom VPS

**Best Target:** Fly.io ou Render

**Why:**
- Reduce operational overhead
- Keep control/flexibility
- Better DX

**Steps:**
1. Containerize app (Dockerfile)
2. Setup Fly.io/Render
3. Migrate DB
4. Gradual cutover (DNS)

---

### From AWS/GCP

**Best Target:** Depends on reason

**Why Migrate:**
- Cost: → Fly.io, Render
- Simplicity: → Railway
- BEAM features: → Gigalixir

**Steps:**
1. Evaluate costs (often AWS/GCP cheaper at huge scale)
2. Test target platform (staging)
3. Compare bills projections
4. Decide based on TCO + DX

---

## Final Recommendations Summary

### Best Overall: Fly.io
- Score: 9.5/10
- Why: Phoenix-optimized, 23 regions, free tier, clustering
- Cost: $0-50/mo typical

### Best DX: Railway
- Score: 9/10
- Why: 2-min deploy, beautiful UI, GitHub integration
- Cost: $5-40/mo typical

### Best for BEAM: Gigalixir
- Score: 8/10
- Why: Hot upgrades, remote observer, 100% BEAM
- Cost: $10-50/mo typical

### Best Serverless: Google Cloud Run
- Score: 7.5/10
- Why: Pay-per-use, 35 regions, free tier
- Cost: $5-30/mo typical

### Best Brasil Budget: Hostinger
- Score: 5/10
- Why: $4/mo, São Paulo DC, full control
- Cost: $4-12/mo typical

---

**Atualizado:** Outubro 2025
**Próxima revisão:** Abril 2026 (pricing updates, new platforms)
