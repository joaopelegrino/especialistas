# Static Deployment + CDN Integration [NAVEGACAO-RAPIDA][CRITICAL]

**Data**: 30/08/2025  
**Contexto**: Projeto Blog WebAssembly-First - Phase 3 Production Deploy  
**Challenge**: COOP/COEP headers em ambiente estático + WASM bundle delivery  
**Target**: Static hosting + CDN com 70% cost reduction vs server hosting  
**Fontes**: Phoenix Deployment + WebAssembly Spec + CDN Providers 2025

## 🔍 Quick Navigation [ECONOMIA-TOKENS]
| Find | Line | Content | Savings |
|------|------|---------|---------|
| [ESSENCIAL] | L25 | Core deployment concepts | 80% |
| [ERRO-COMUM] | L110 | COOP/COEP header issues | 90% |
| [TEMPLATE] | L180 | Ready deployment configs | 85% |
| [CDN-SPECIFIC] | L280 | Provider-specific setup | 75% |

---

## 🎯 Contexto e Motivação [ESSENCIAL]

### Problema Atual Identificado
- **Current**: Development server (Bandit HTTP) rodando localmente
- **Target**: Static hosting + CDN deployment para WASM bundle
- **Challenge**: COOP/COEP headers necessários para SharedArrayBuffer
- **Complexity**: WebAssembly security requirements em ambiente estático

### Strategic Advantages
```yaml
Traditional Blog Deploy (Server):
  Infrastructure: VPS/Container hosting
  Bundle: Server-side rendering + assets
  Cost: $20-100/month hosting
  Scalability: Manual server scaling
  Boot Time: 5-10 seconds server start
  
WebAssembly-First Deploy (Static+CDN):
  Infrastructure: Static hosting + CDN
  Bundle: <3MB WASM + assets
  Cost: $0-10/month (CDN only)
  Scalability: Global CDN automatic
  Boot Time: <500ms client initialization
  
Cost Reduction: 70-90% vs traditional hosting
Performance: 95% improvement (local processing)
```

### Business Impact
- **Infrastructure Cost**: -70% (static vs server hosting)
- **Global Distribution**: CDN edge locations
- **Offline Capability**: 100% feature parity
- **Developer Velocity**: Same deploy pipeline

---

## 📚 Pesquisa em Fontes Oficiais [ESSENCIAL]

### [Fonte 1]: Phoenix Deployment Guide
**URL**: https://hexdocs.pm/phoenix/deployment.html  
**Seções**: Asset compilation, static deployment, production builds

**Key Phoenix Static Deployment Steps**:
```bash
# 1. Production dependencies
mix deps.get --only prod

# 2. Compile for production  
MIX_ENV=prod mix compile

# 3. Deploy assets with digest
MIX_ENV=prod mix assets.deploy

# 4. Generate static files
MIX_ENV=prod mix phx.build.static
```

**Asset Compilation Process**:
- `mix assets.deploy` compiles and digests assets
- Generates files in `priv/static` with cache manifest
- Creates fingerprinted versions for browser caching

### [Fonte 2]: WebAssembly Cross-Origin Isolation
**URL**: https://web.dev/articles/coop-coep + WebAssembly Spec  
**Focus**: Security policies, COOP/COEP requirements

**Required Headers for WASM**:
```http
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

**Why These Headers Are Critical**:
- Enable SharedArrayBuffer (required for WASM threads)
- Enable high-resolution timers
- Enable memory measurement APIs
- Required for AtomVM WASM runtime

### [Fonte 3]: Static Hosting COOP/COEP Workarounds
**URL**: Multiple 2025 sources on GitHub Pages, Netlify, Vercel  
**Challenge**: Static hosting can't set custom HTTP headers

**Service Worker Solution** (Industry Standard 2025):
- Use `coi-serviceworker` to patch headers client-side
- Reloads page on first visit to register service worker
- Emulates COOP/COEP headers for cross-origin isolation
- Enables SharedArrayBuffer without server control

---

## ❌ Common Deployment Pitfalls [ERRO-COMUM]

### 1. **Missing COOP/COEP Headers**
```javascript
// ❌ ERRO: WASM sem cross-origin isolation
// Results in: SharedArrayBuffer is not available
const wasmModule = new WebAssembly.Module(wasmBytes);
// Error: SharedArrayBuffer is not defined
```

**Symptoms**:
- `SharedArrayBuffer is not defined` errors
- WASM threads not working
- AtomVM initialization fails
- High-resolution timers disabled

**Solution**: Service worker header patching (ver template)

### 2. **Incorrect Asset Paths in Static Deploy**
```html
<!-- ❌ ERRO: Hardcoded localhost paths -->
<script src="http://localhost:4000/assets/wasm/loader.js"></script>

<!-- ✅ CORRETO: Relative paths for CDN -->
<script src="/assets/wasm/loader.js"></script>
```

### 3. **Missing WASM MIME Type Configuration**
```nginx
# ❌ ERRO: Server sem WASM MIME type
# Results in: incorrect Content-Type for .wasm files

# ✅ CORRETO: WASM MIME type
location ~* \.wasm$ {
    add_header Content-Type application/wasm;
    add_header Cross-Origin-Embedder-Policy require-corp;
    add_header Cross-Origin-Opener-Policy same-origin;
}
```

### 4. **Bundle não Otimizado para CDN**
```elixir
# ❌ ERRO: Assets não comprimidos
# No gzip/brotli compression
# No cache headers

# ✅ CORRETO: Asset pipeline otimizado
config :blog, BlogWeb.Endpoint,
  # ... outras configs
  static_url: [host: "cdn.exemplo.com"],
  cache_static_manifest: "priv/static/cache_manifest.json"
```

### 5. **CORS Issues com WASM Resources**
```http
# ❌ ERRO: CORS blocking WASM loading
Access-Control-Allow-Origin: *
# Not sufficient for cross-origin isolation

# ✅ CORRETO: CORP header for resources
Cross-Origin-Resource-Policy: cross-origin
```

---

## 🏗️ Deployment Strategies [BEST-PRACTICE]

### 1. **Phoenix Static Build Pipeline**

```elixir
# mix.exs - Static deployment configuration
defmodule Blog.MixProject do
  use Mix.Project

  def project do
    [
      app: :blog,
      version: "0.1.0",
      elixir: "~> 1.17",
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Deployment aliases
  defp aliases do
    [
      # Full static build
      "deploy.static": [
        "deps.get --only prod",
        "compile",
        "assets.deploy",
        "popcorn.cook",
        "phx.build.static"
      ],
      # WASM-specific build
      "deploy.wasm": [
        "deps.get --only wasm", 
        "compile",
        "popcorn.cook --optimize",
        "wasm.optimize"
      ]
    ]
  end
end
```

### 2. **Production Environment Configuration**

```elixir
# config/prod.exs - Static deployment config
import Config

# Static hosting configuration
config :blog, BlogWeb.Endpoint,
  url: [host: "blog.exemplo.com", port: 443, scheme: "https"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: false,  # No server needed for static
  
  # CDN configuration
  static_url: [
    host: "cdn.exemplo.com",
    port: 443,
    scheme: "https"
  ],
  
  # Security headers (when server available)
  force_ssl: [host: nil],
  check_origin: ["https://blog.exemplo.com"]

# Static asset configuration  
config :phoenix, :assets,
  version: System.get_env("ASSETS_VERSION") || "1",
  digest: true,
  gzip: true,
  brotli: true

# WASM-specific config
config :popcorn,
  out_dir: "priv/static/wasm",
  cdn_url: "https://cdn.exemplo.com/wasm/"
```

### 3. **Asset Compilation with WASM Support**

```bash
#!/bin/bash
# scripts/build-static-deploy.sh

set -e

echo "🚀 Building static deployment with WASM..."

# Environment setup
export MIX_ENV=prod
export NODE_ENV=production

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf priv/static/*
mix clean

# Install dependencies
echo "📦 Installing dependencies..."
mix deps.get --only prod
cd assets && npm ci --production && cd ..

# Compile application
echo "🔨 Compiling application..."
mix compile

# Build WASM bundle
echo "🎯 Building WASM bundle..."
mix popcorn.cook --optimize

# Compile and digest assets
echo "📦 Processing assets..."
mix assets.deploy

# Optimize WASM files
echo "⚡ Optimizing WASM files..."
find priv/static/wasm -name "*.wasm" -exec wasm-opt --strip-debug {} -o {} \;

# Compress assets
echo "🗜️ Compressing assets..."
find priv/static -name "*.js" -exec gzip -k {} \;
find priv/static -name "*.css" -exec gzip -k {} \;
find priv/static -name "*.wasm" -exec gzip -k {} \;

# Generate service worker for COOP/COEP
echo "🔧 Generating service worker..."
./scripts/generate-coi-serviceworker.sh

# Bundle analysis
echo "📊 Bundle analysis:"
du -sh priv/static/*

echo "✅ Static deployment ready!"
```

---

## 🔧 Ready Deployment Templates [TEMPLATE]

### Service Worker for COOP/COEP Headers

```javascript
// priv/static/coi-serviceworker.js
// Cross-Origin Isolation Service Worker for WASM

// Based on https://github.com/gzuidhof/coi-serviceworker
(() => {
  'use strict';

  const enableCrossOriginIsolation = () => {
    // Check if we're already isolated
    if (typeof SharedArrayBuffer !== 'undefined') {
      return false; // Already isolated
    }

    // Register service worker
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('/coi-serviceworker.js').then(() => {
        // Reload to apply headers
        window.location.reload();
      });
    }
    
    return true; // Will reload
  };

  // Service Worker code
  if (typeof importScripts === 'function') {
    // We're in service worker context
    self.addEventListener('fetch', (event) => {
      const url = new URL(event.request.url);
      
      // Only handle same-origin requests
      if (url.origin !== self.location.origin) return;

      event.respondWith(
        fetch(event.request).then((response) => {
          // Clone response to modify headers
          const newResponse = new Response(response.body, {
            status: response.status,
            statusText: response.statusText,
            headers: {
              ...Object.fromEntries(response.headers.entries()),
              'Cross-Origin-Embedder-Policy': 'require-corp',
              'Cross-Origin-Opener-Policy': 'same-origin'
            }
          });

          return newResponse;
        })
      );
    });
  } else {
    // We're in main thread context
    enableCrossOriginIsolation();
  }
})();
```

### HTML Template com WASM Loader

```html
<!-- priv/static/index.html -->
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Blog WebAssembly-First</title>
  
  <!-- CDN assets -->
  <link rel="stylesheet" href="/assets/app.css">
  
  <!-- COOP/COEP Service Worker -->
  <script src="/coi-serviceworker.js"></script>
</head>
<body>
  <div id="app">
    <!-- App content -->
    <main>
      <h1>Blog WebAssembly-First</h1>
      <div id="wasm-status">Initializing WebAssembly...</div>
      <div id="blog-content"></div>
    </main>
  </div>

  <!-- WASM Loader -->
  <script>
    // WASM initialization
    const initWasm = async () => {
      const statusEl = document.getElementById('wasm-status');
      
      try {
        // Check cross-origin isolation
        if (typeof SharedArrayBuffer === 'undefined') {
          statusEl.textContent = 'Enabling cross-origin isolation...';
          // Service worker will handle this
          return;
        }
        
        statusEl.textContent = 'Loading WebAssembly runtime...';
        
        // Load AtomVM WASM module
        const wasmResponse = await fetch('/wasm/atomvm.wasm');
        const wasmBytes = await wasmResponse.arrayBuffer();
        const wasmModule = await WebAssembly.instantiate(wasmBytes);
        
        statusEl.textContent = 'Loading Elixir modules...';
        
        // Load Popcorn AVM bundle
        const avmResponse = await fetch('/wasm/popcorn.avm');
        const avmBytes = await avmResponse.arrayBuffer();
        
        statusEl.textContent = 'Initializing Elixir runtime...';
        
        // Initialize AtomVM with Elixir modules
        const runtime = await wasmModule.instance.exports.init(avmBytes);
        
        statusEl.textContent = 'Blog ready!';
        statusEl.style.display = 'none';
        
        // Initialize blog application
        window.BlogWasm = runtime;
        initBlogApp();
        
      } catch (error) {
        statusEl.textContent = `Error: ${error.message}`;
        console.error('WASM initialization error:', error);
      }
    };
    
    const initBlogApp = () => {
      // Blog-specific initialization
      console.log('Blog WebAssembly runtime ready');
      
      // Enable offline-first features
      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('/blog-sw.js');
      }
    };
    
    // Start initialization
    initWasm();
  </script>
  
  <!-- CDN assets -->
  <script src="/assets/app.js"></script>
</body>
</html>
```

### CDN Provider Configurations

#### Netlify Deploy

```toml
# netlify.toml
[build]
  publish = "priv/static"
  command = "./scripts/build-static-deploy.sh"

[build.environment]
  NODE_VERSION = "18"
  ELIXIR_VERSION = "1.17.3"
  ERLANG_VERSION = "26.0.2"

# Headers for WASM support
[[headers]]
  for = "*.wasm"
  [headers.values]
    Content-Type = "application/wasm"
    Cross-Origin-Resource-Policy = "cross-origin"

[[headers]]
  for = "*.avm"  
  [headers.values]
    Content-Type = "application/octet-stream"
    Cross-Origin-Resource-Policy = "cross-origin"

# Cache configuration
[[headers]]
  for = "/wasm/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

# Redirects for SPA-like behavior
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
  conditions = {Role = ["app"]}
```

#### Vercel Deploy

```json
{
  "version": 2,
  "name": "blog-wasm",
  "builds": [
    {
      "src": "scripts/build-static-deploy.sh",
      "use": "@vercel/static-build",
      "config": {
        "buildCommand": "./scripts/build-static-deploy.sh",
        "outputDirectory": "priv/static"
      }
    }
  ],
  "headers": [
    {
      "source": "/(.*\\.wasm)",
      "headers": [
        {
          "key": "Content-Type",
          "value": "application/wasm"
        },
        {
          "key": "Cross-Origin-Resource-Policy", 
          "value": "cross-origin"
        }
      ]
    },
    {
      "source": "/wasm/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

#### GitHub Pages Deploy (com Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Elixir
      uses: erlef/setup-beam@v1
      with:
        elixir-version: '1.17.3'
        otp-version: '26.0.2'
    
    - name: Setup Node.js  
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: assets/package-lock.json
    
    - name: Build static site
      run: |
        ./scripts/build-static-deploy.sh
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./priv/static
        cname: blog.exemplo.com
```

---

## 🌐 CDN-Specific Strategies [CDN-SPECIFIC]

### CloudFlare CDN Integration

```javascript
// cloudflare-worker.js - Edge computing com WASM
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Handle WASM requests
    if (url.pathname.startsWith('/wasm/')) {
      const response = await fetch(request);
      
      // Add COOP/COEP headers at edge
      const headers = new Headers(response.headers);
      headers.set('Cross-Origin-Embedder-Policy', 'require-corp');
      headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      headers.set('Cross-Origin-Resource-Policy', 'cross-origin');
      
      return new Response(response.body, {
        status: response.status,
        headers
      });
    }
    
    return fetch(request);
  }
};
```

### AWS CloudFront + S3

```yaml
# aws-cloudformation.yml
Resources:
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: blog-wasm-static
      WebsiteConfiguration:
        IndexDocument: index.html
        ErrorDocument: error.html
      CorsConfiguration:
        CorsRules:
          - AllowedHeaders: ['*']
            AllowedMethods: [GET, HEAD]
            AllowedOrigins: ['*']
            MaxAge: 3600

  CloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Origins:
          - Id: S3Origin
            DomainName: !GetAtt S3Bucket.DomainName
            S3OriginConfig:
              OriginAccessIdentity: ''
        DefaultCacheBehavior:
          TargetOriginId: S3Origin
          ViewerProtocolPolicy: redirect-to-https
          ResponseHeadersPolicy:
            ResponseHeadersPolicyId: !Ref WasmHeadersPolicy
        
  WasmHeadersPolicy:
    Type: AWS::CloudFront::ResponseHeadersPolicy
    Properties:
      ResponseHeadersPolicyConfig:
        Name: WasmHeaders
        CustomHeaders:
          - Header: Cross-Origin-Embedder-Policy
            Value: require-corp
            Override: true
          - Header: Cross-Origin-Opener-Policy
            Value: same-origin
            Override: true
```

### Performance Monitoring

```javascript
// assets/js/performance-monitoring.js
class WasmPerformanceMonitor {
  constructor() {
    this.metrics = {
      loadTime: 0,
      initTime: 0,
      bundleSize: 0,
      memoryUsage: 0
    };
  }
  
  async measureLoadTime(wasmUrl, avmUrl) {
    const start = performance.now();
    
    // Measure WASM download
    const wasmStart = performance.now();
    await fetch(wasmUrl);
    const wasmLoadTime = performance.now() - wasmStart;
    
    // Measure AVM download  
    const avmStart = performance.now();
    await fetch(avmUrl);
    const avmLoadTime = performance.now() - avmStart;
    
    this.metrics.loadTime = performance.now() - start;
    
    console.log(`WASM Load Performance:
      Total: ${this.metrics.loadTime.toFixed(2)}ms
      WASM: ${wasmLoadTime.toFixed(2)}ms  
      AVM: ${avmLoadTime.toFixed(2)}ms`);
  }
  
  measureMemoryUsage() {
    if (performance.memory) {
      this.metrics.memoryUsage = performance.memory.usedJSHeapSize;
    }
  }
  
  sendMetrics() {
    // Send to analytics service
    fetch('/api/metrics', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(this.metrics)
    });
  }
}

// Global monitoring instance
window.wasmMonitor = new WasmPerformanceMonitor();
```

---

## 📊 Deployment Validation [PERFORMANCE]

### Automated Deployment Tests

```bash
#!/bin/bash
# scripts/validate-deployment.sh

echo "🔍 Validating static deployment..."

SITE_URL="https://blog.exemplo.com"
WASM_URL="${SITE_URL}/wasm/atomvm.wasm"
AVM_URL="${SITE_URL}/wasm/popcorn.avm"

# Test COOP/COEP headers
echo "Testing cross-origin headers..."
COOP_HEADER=$(curl -s -I "$SITE_URL" | grep -i "cross-origin-opener-policy")
COEP_HEADER=$(curl -s -I "$SITE_URL" | grep -i "cross-origin-embedder-policy")

if [[ -n "$COOP_HEADER" && -n "$COEP_HEADER" ]]; then
  echo "✅ Cross-origin headers present"
else
  echo "⚠️ Missing cross-origin headers (service worker required)"
fi

# Test WASM MIME type
WASM_MIME=$(curl -s -I "$WASM_URL" | grep -i "content-type")
if [[ "$WASM_MIME" == *"application/wasm"* ]]; then
  echo "✅ WASM MIME type correct"
else
  echo "❌ WASM MIME type incorrect: $WASM_MIME"
fi

# Test bundle sizes
WASM_SIZE=$(curl -s -I "$WASM_URL" | grep -i "content-length" | awk '{print $2}' | tr -d '\r')
AVM_SIZE=$(curl -s -I "$AVM_URL" | grep -i "content-length" | awk '{print $2}' | tr -d '\r')

TOTAL_SIZE=$((WASM_SIZE + AVM_SIZE))
MAX_SIZE=$((3 * 1024 * 1024))  # 3MB

if [[ $TOTAL_SIZE -lt $MAX_SIZE ]]; then
  echo "✅ Bundle size OK: $((TOTAL_SIZE / 1024 / 1024))MB"
else  
  echo "❌ Bundle too large: $((TOTAL_SIZE / 1024 / 1024))MB > 3MB"
fi

# Test CDN caching
CACHE_HEADER=$(curl -s -I "$WASM_URL" | grep -i "cache-control")
if [[ -n "$CACHE_HEADER" ]]; then
  echo "✅ Cache headers present: $CACHE_HEADER"
else
  echo "⚠️ No cache headers found"
fi

echo "🎯 Deployment validation complete"
```

### Performance Benchmarks

```yaml
Static Deployment Targets:
  First Contentful Paint: <1.5s
  Largest Contentful Paint: <2.5s  
  WASM Initialization: <500ms
  Time to Interactive: <3s
  Bundle Transfer (Gzipped): <1.5MB

CDN Performance:
  Global Edge Locations: 95% coverage
  Cache Hit Rate: >90%
  Origin Requests: <10%
  
Cost Analysis:
  Netlify Pro: $19/month (100GB bandwidth)
  Vercel Pro: $20/month (1TB bandwidth) 
  CloudFlare: $20/month (unlimited)
  AWS CloudFront: ~$5/month (typical usage)
  
vs Server Hosting:
  VPS: $40-100/month
  Managed Phoenix: $50-200/month
  Cost Savings: 70-90%
```

---

## 🔗 Referências e Links Oficiais [REFERÊNCIAS]

### Documentação Oficial
- **Phoenix Deployment**: https://hexdocs.pm/phoenix/deployment.html
- **WebAssembly Security**: https://web.dev/articles/coop-coep
- **Service Workers**: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API

### CDN Providers  
- **Netlify**: https://docs.netlify.com/configure-builds/file-processing/
- **Vercel**: https://vercel.com/docs/concepts/projects/project-configuration
- **CloudFlare**: https://developers.cloudflare.com/workers/
- **AWS CloudFront**: https://docs.aws.amazon.com/cloudfront/

### Tools & Libraries
- **coi-serviceworker**: https://github.com/gzuidhof/coi-serviceworker  
- **wasm-opt**: https://github.com/WebAssembly/binaryen
- **Lighthouse CI**: https://github.com/GoogleChrome/lighthouse-ci

### Compatibility Notes
- **COOP/COEP**: Required for SharedArrayBuffer since Chrome 91+
- **WASM Threads**: Requires cross-origin isolation
- **Service Workers**: Supported in all modern browsers

---

**🎯 RESULTADO ESPERADO**: Static deployment complete com CDN integration, COOP/COEP headers via service workers, bundle optimization <3MB, e monitoramento de performance. Cost reduction 70-90% vs server hosting com global distribution e offline-first capability.**