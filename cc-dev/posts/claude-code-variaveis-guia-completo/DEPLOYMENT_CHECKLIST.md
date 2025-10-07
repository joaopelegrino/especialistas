# Deployment Checklist: Claude Code Variables Guide

**Date:** 2025-10-07
**Author:** Equipe de Desenvolvimento
**Article URL:** `/posts/claude-code-variaveis-guia-completo`
**Article Title:** Como Usar Variáveis em Slash Commands do Claude Code

---

## Pre-Deployment

### Content Review
- [ ] Article reviewed for technical accuracy (all syntax examples validated)
- [ ] All internal links tested (anchors work correctly)
- [ ] All external links tested (10 source links functional)
- [ ] Code examples tested and validated
  - [ ] $ARGUMENTS examples
  - [ ] $1, $2, $3 positional examples
  - [ ] Bash validation scripts
  - [ ] Decision tree logic
- [ ] Sources properly cited (10 sources with URLs and dates)
- [ ] Grammar/spelling checked (3.547 words proofread)
- [ ] Case study metrics verified (30+ variables, 504 lines, 100% stats)

### SEO/LLMO Optimization
- [ ] Primary keyword in H1: ✓ "Claude Code" present
- [ ] Primary keyword in first 100 words: ✓ Verified
- [ ] Meta title 55-60 characters: ✓ 58 chars
- [ ] Meta description 150-160 characters: ✓ 158 chars
- [ ] Alt text for all images (when images are added)
- [ ] Internal links to 3+ pages (add relevant site links)
- [ ] Answer-first structure: ✓ 50-word answer present
- [ ] Data points specific: ✓ 20+ numeric data points
- [ ] Decision matrix present: ✓ Comparison table included
- [ ] FAQ format: ✓ 10 FAQs with structured markup

### Technical Validation
- [ ] llms.txt entry prepared: ✓
- [ ] robots.txt reviewed: ✓ No changes needed
- [ ] sitemap.xml entry generated: ✓
- [ ] meta_tags.json configured: ✓ All fields complete
- [ ] structured_data.json validated:
  - [ ] Article schema: ✓
  - [ ] FAQPage schema: ✓
  - [ ] HowTo schema: ✓
  - [ ] BreadcrumbList schema: ✓
- [ ] Schema markup validated at [schema.org/validator](https://validator.schema.org/)
- [ ] Page speed target: <3s load time (test after deployment)
- [ ] Mobile-friendly checked (test after deployment)

### Images & Media
- [ ] Featured image created: `claude-code-variables-guide.jpg` (1200x630px)
- [ ] OG image optimized: `claude-code-variables-guide-og.jpg` (1200x630px)
- [ ] Twitter card image: `claude-code-variables-guide-twitter.jpg` (1200x675px)
- [ ] Inline diagrams created (if applicable):
  - [ ] Decision tree diagram
  - [ ] Syntax comparison diagram
  - [ ] Case study flow chart
- [ ] All images compressed: <200KB each
- [ ] All images have alt text

---

## Deployment

### File Preparation
- [ ] article.md moved to production directory
- [ ] Replace [SEU-DOMINIO] with actual domain in all files
- [ ] Replace [NOME DO SEU SITE] with site name
- [ ] Replace [@SEU_HANDLE] with Twitter handle
- [ ] Verify all placeholder URLs updated

### File Uploads
- [ ] article.md uploaded to CMS/static site generator
- [ ] Images uploaded to `/images/` directory
- [ ] llms.txt entry added to root llms.txt file
- [ ] sitemap.xml entry added to root sitemap.xml
- [ ] meta_tags.json configured in page template
- [ ] structured_data.json schemas inserted in HTML `<head>`

### Configuration
- [ ] URL slug configured: `/posts/claude-code-variaveis-guia-completo`
- [ ] Publish date set: 2025-10-07
- [ ] Author assigned: Equipe de Desenvolvimento
- [ ] Categories/tags added:
  - [ ] Claude Code
  - [ ] Slash Commands
  - [ ] Variables
  - [ ] Developer Tools
  - [ ] Technical Guides
- [ ] Featured image set
- [ ] Excerpt generated (first 160 chars of description)
- [ ] Canonical URL set: `https://[DOMAIN]/posts/claude-code-variaveis-guia-completo`

### Testing in Staging
- [ ] Preview page in staging environment
- [ ] Test on mobile devices (iOS, Android)
- [ ] Test on different browsers (Chrome, Firefox, Safari, Edge)
- [ ] Verify structured data with [Rich Results Test](https://search.google.com/test/rich-results)
- [ ] Check robots.txt accessibility: `[DOMAIN]/robots.txt`
- [ ] Verify sitemap includes article: `[DOMAIN]/sitemap.xml`
- [ ] Test internal links (all clickable and go to correct pages)
- [ ] Test external links (all 10 source links open correctly)
- [ ] Verify code examples render correctly
- [ ] Test FAQ accordion functionality (if implemented)
- [ ] Verify scroll-to-anchor links work (#problema, #sintaxe, etc.)

### SEO Validation
- [ ] Test meta tags with [Facebook Debugger](https://developers.facebook.com/tools/debug/)
- [ ] Test Twitter Card with [Card Validator](https://cards-dev.twitter.com/validator)
- [ ] Test structured data with [Schema Markup Validator](https://validator.schema.org/)
- [ ] Verify Open Graph tags display correctly
- [ ] Check canonical URL is set and correct
- [ ] Confirm no duplicate content issues
- [ ] Verify breadcrumb navigation displays

---

## Post-Deployment

### Immediate Actions (Day 1)
- [ ] Submit URL to [Google Search Console](https://search.google.com/search-console)
- [ ] Submit URL to [Bing Webmaster Tools](https://www.bing.com/webmasters)
- [ ] Share on social media:
  - [ ] Twitter/X
  - [ ] LinkedIn
  - [ ] Reddit (relevant subreddits: r/ClaudeAI, r/programming)
  - [ ] Discord communities
  - [ ] Hacker News (if appropriate)
- [ ] Notify subscribers via:
  - [ ] Email newsletter (if applicable)
  - [ ] RSS feed update
- [ ] Monitor analytics for errors:
  - [ ] Check for 404s
  - [ ] Monitor server errors (500s)
  - [ ] Verify tracking codes work

### Week 1 Monitoring
- [ ] Check indexing status (Google/Bing):
  - [ ] Google: `site:[domain]/posts/claude-code-variaveis-guia-completo`
  - [ ] Bing: Same query
- [ ] Monitor AI citations:
  - [ ] Test queries in ChatGPT: "claude code variables not working"
  - [ ] Test in Perplexity: "how to use $ARGUMENTS claude code"
  - [ ] Test in Claude: "fix slash command variables"
  - [ ] Track citations manually or via [Otterly.ai](https://otterly.ai)
- [ ] Review analytics (Google Analytics/Plausible):
  - [ ] Page views
  - [ ] Traffic sources
  - [ ] Time on page (target: >5 min)
  - [ ] Bounce rate (target: <60%)
  - [ ] Scroll depth
- [ ] Check for broken links:
  - [ ] Use [Broken Link Checker](https://www.brokenlinkcheck.com/)
  - [ ] Fix any issues found
- [ ] Respond to comments/feedback:
  - [ ] Monitor comment section (if enabled)
  - [ ] Respond to social media mentions
  - [ ] Address any technical questions

### Month 1 Review
- [ ] Review SEO performance:
  - [ ] Check keyword rankings in Google Search Console
    - [ ] "claude code variáveis"
    - [ ] "slash commands argumentos"
    - [ ] "sintaxe claude code"
    - [ ] "$ARGUMENTS vs ${VARIABLE}"
  - [ ] Impressions: Target >500
  - [ ] Clicks: Target >50
  - [ ] CTR: Target >5%
  - [ ] Average position: Target <30 (aiming for first page)
- [ ] Check backlinks acquired:
  - [ ] Use Ahrefs/Semrush/Google Search Console
  - [ ] Target: 3-5 backlinks in first month
  - [ ] Quality check: Domain authority >20
- [ ] Monitor AI citation rate:
  - [ ] ChatGPT citation rate: Target 15-25%
  - [ ] Perplexity visibility: Target first page
  - [ ] Claude Code discovery: High (llms.txt optimized)
  - [ ] Document citation examples
- [ ] Review user engagement:
  - [ ] Comments count
  - [ ] Social shares
  - [ ] Time on page trend
  - [ ] Returning visitors
- [ ] Update content if needed:
  - [ ] Fix any reported errors
  - [ ] Add clarifications based on feedback
  - [ ] Update examples if better ones found
  - [ ] Refresh statistics if new data available

### Quarter 1 Analysis (3 months)
- [ ] Comprehensive performance review:
  - [ ] Total organic traffic: Target 300-500 visits/month
  - [ ] Keyword rankings: Target top 10 for primary keyword
  - [ ] Backlink profile: Target 5-10 quality backlinks
  - [ ] AI citation rate: Target 25-35%
  - [ ] Engagement metrics: Time on page >5min, bounce <50%
- [ ] Content refresh needs:
  - [ ] Any Claude Code syntax changes?
  - [ ] New official documentation released?
  - [ ] Community feedback incorporated?
  - [ ] Case study still relevant?
  - [ ] Need new FAQs based on queries?
- [ ] Technical updates:
  - [ ] Images still optimized?
  - [ ] All links still valid?
  - [ ] Structured data still valid?
  - [ ] Page load speed acceptable?
- [ ] Add to content cluster:
  - [ ] Create related articles linking to this
  - [ ] Build topic cluster around Claude Code
  - [ ] Internal linking strategy review

---

## Monitoring Metrics

### SEO Metrics (Track in Google Analytics + Search Console)
- **Organic traffic**: 300-500 visits/month (target by month 3)
- **Keyword rankings**:
  - Primary: "claude code variáveis" → Top 10 by month 2
  - Secondary: "slash commands argumentos" → Top 20 by month 3
  - Long-tail: "$ARGUMENTS syntax" → Top 5 by month 1
- **Backlinks**: 5-10 quality backlinks by month 3
- **Click-through rate**: >5% in SERPs
- **Time on page**: >5 minutes (comprehensive read)
- **Bounce rate**: <50% (engaging content)

### LLM Metrics (Track manually or via Otterly.ai)
- **AI citation rate**: 25-35% for relevant queries
- **ChatGPT mentions**: Track queries like:
  - "claude code variables not working"
  - "how to use $ARGUMENTS"
  - "fix ${VARIABLE} claude code"
- **Perplexity visibility**: First page for primary queries
- **Claude Code discovery**: High visibility (llms.txt optimized)
- **AI referral traffic**: 100-150 visits/month by month 3
- **Featured snippets**: Target 2-3 for FAQ questions

### Engagement Metrics
- **Social shares**: 20+ in first month
- **Comments/feedback**: Active discussion
- **Newsletter signups**: Track conversions
- **Code example copies**: Track if analytics configured
- **Scroll depth**: >75% readers reach case study
- **Return visitors**: >10% return rate

---

## Rollback Plan

### If Critical Issues Detected

**Critical = Site broken, security issue, massive error**

1. **Immediate Actions** (within 1 hour):
   - [ ] Revert article (unpublish or delete)
   - [ ] Restore previous llms.txt if changed
   - [ ] Remove sitemap entry if causing issues
   - [ ] Post notice if needed
   - [ ] Investigate root cause

2. **Investigation**:
   - [ ] Check server logs
   - [ ] Review error messages
   - [ ] Test in local environment
   - [ ] Identify exact issue
   - [ ] Document for future

3. **Fix and Redeploy**:
   - [ ] Correct the issue
   - [ ] Test thoroughly in staging
   - [ ] Re-run pre-deployment checklist
   - [ ] Deploy fixed version
   - [ ] Monitor closely

### If Performance Issues

**Performance = Slow load, high bounce, poor engagement**

1. **Identify Issue**:
   - [ ] Run PageSpeed Insights
   - [ ] Check image sizes
   - [ ] Verify external scripts
   - [ ] Test time to interactive

2. **Optimize**:
   - [ ] Compress images further
   - [ ] Minify code examples
   - [ ] Enable caching
   - [ ] Lazy-load images
   - [ ] Reduce external dependencies

3. **Verify Fix**:
   - [ ] Re-test page speed
   - [ ] Monitor bounce rate
   - [ ] Check time on page improved

### If SEO Issues

**SEO = De-indexed, ranking dropped, crawl errors**

1. **Check Status**:
   - [ ] Verify robots.txt not blocking
   - [ ] Check sitemap is accessible
   - [ ] Review Search Console errors
   - [ ] Verify canonical URL correct
   - [ ] Check for duplicate content

2. **Correct Issues**:
   - [ ] Fix robots.txt if needed
   - [ ] Update sitemap
   - [ ] Request recrawl in Search Console
   - [ ] Fix canonical issues
   - [ ] Resolve duplicate content

3. **Monitor Recovery**:
   - [ ] Check indexing status daily
   - [ ] Watch for ranking recovery
   - [ ] Review crawl stats

---

## Success Criteria

### Week 1
- ✅ Article indexed by Google and Bing
- ✅ No deployment errors or 404s
- ✅ Analytics tracking confirmed working
- ✅ Structured data recognized by search engines
- ✅ First social shares received

### Month 1
- ✅ 50+ organic visits
- ✅ 3-5 backlinks acquired
- ✅ 15%+ AI citation rate
- ✅ Ranking <50 for primary keyword
- ✅ 10+ social shares

### Quarter 1 (3 months)
- ✅ 300-500 organic visits/month
- ✅ Top 10 ranking for primary keyword
- ✅ 5-10 quality backlinks
- ✅ 25-35% AI citation rate
- ✅ Featured in AI Overviews
- ✅ Active community engagement

---

## Notes & Observations

**Special Considerations:**
- Este é conteúdo evergreen com atualização mensal agendada
- Case study é real (desta sessão) - métricas são verificáveis
- High technical accuracy - validado contra documentação oficial
- 10 fontes documentadas aumentam credibilidade
- FAQ structure optimizada para AI query matching

**Dependencies:**
- Claude Code CLI syntax (stable - low change risk)
- Anthropic documentation (monitored for updates)
- None external APIs or services

**Risk Assessment:** **LOW**
- Additive content (não quebra existente)
- Bem testado e validado
- Rollback plan documentado
- No breaking changes no site

---

**Deployment Prepared By:** Equipe de Desenvolvimento
**Deployment Date:** [A PREENCHER]
**Status:** [ ] Ready [ ] In Progress [ ] Deployed [ ] Issues [ ] Rolled Back

**Deployed By:** [NOME]
**Deployment Time:** [TIMESTAMP]
**Post-Deployment Validation:** [ ] Passed [ ] Failed

---

**Last Updated:** 2025-10-07
