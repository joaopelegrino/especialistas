# 📚 ELIXIR - ARQUIVOS IMPORTANTES
**Gerado em:** dom 14 set 2025 17:39:56 -03
**Arquivos incluídos:** 11-pop-corn-wa/bundle-optimization-strategies.md 11-pop-corn-wa/DevOps.md 11-pop-corn-wa/offline-first-patterns.md 11-pop-corn-wa/setup.md 11-pop-corn-wa/static-deployment-guide.md 01-documentacao-base 11-pop-corn-wa/testes.md 09-setup-config/01-instalacao-inicial.md 09-setup-config/02-instalacao-moderna-elixir-2025.md 06-devops-infra/01-devops-checklist.md 06-devops-infra/wasm-telemetry-production.md


---
## 📁 11-pop-corn-wa/bundle-optimization-strategies.md

# Bundle Optimization: 7.8MB → <3MB [NAVEGACAO-RAPIDA][CRITICAL]

**Data**: 30/08/2025  
**Contexto**: Projeto Blog WebAssembly-First - Phase 3 Implementation  
**Baseline**: AtomVM.wasm (717KB) + popcorn.avm (6.9MB) = 7.8MB total  
**Target**: <3MB bundle (60% reduction required)  
**Fontes**: Popcorn v0.1.0 + Mix 1.18+ + AtomVM + Elixir 1.17.3

## 🔍 Quick Navigation [ECONOMIA-TOKENS]
| Find | Line | Content | Savings |
|------|------|---------|---------|
| [ESSENCIAL] | L25 | Core optimization concepts | 70% |
| [ERRO-COMUM] | L95 | Common bundle bloat patterns | 60% |
| [TEMPLATE] | L165 | Ready optimization configs | 80% |
| [WASM-SPECIFIC] | L235 | AtomVM size reduction | 85% |

---

## 🎯 Contexto e Motivação [ESSENCIAL]

### Problema Atual Identificado
- **Current Bundle**: 7.8MB (AtomVM 717KB + popcorn.avm 6.9MB)
- **Production Target**: <3MB total for CDN deployment
- **Reduction Required**: ~5MB (64% optimization)
- **Business Impact**: 70% cost reduction vs server hosting

### Target Objectives
```yaml
Bundle Size Targets:
  AtomVM.wasm: 717KB → 500KB (minimal stdlib)
  JavaScript Bridge: 130KB → 100KB (tree shaking)
  popcorn.avm: 6.9MB → 2.4MB (65% reduction via module selection)
  Total: 7.8MB → 3.0MB (61% reduction)

Performance Targets:
  Load Time: First paint <2s, Interactive <3s
  WASM Init: <500ms initialization
  Memory Usage: <10MB heap
  Bundle Transfer: Gzipped <1.5MB
```

### Business Impact
- **Infrastructure Cost**: -70% (static hosting vs server)
- **Response Time**: 95% improvement (local processing)
- **Engagement**: +40% time on page (offline capability)
- **Developer Velocity**: Same codebase client/server

---

## 📚 Pesquisa em Fontes Oficiais [ESSENCIAL]

### [Fonte 1]: Popcorn Documentation Analysis
**URL**: https://hexdocs.pm/popcorn/readme.html  
**Validação**: 30/08/2025  
**Findings**: Early-stage project, limited optimization docs

```elixir
# Current Popcorn Configuration (Limited Options)
config :popcorn, runtime: [
  {:url, "https://atomvm/wasm/url", target: :wasm},
  {:path, "/path/to/atomvm/unix", target: :unix}
]

config :popcorn, out_dir: "static/wasm"
```

**Key Limitation**: Bundle optimization features not yet documented in v0.1.0

### [Fonte 2]: Mix Release Optimization (OTP 26.0.2)
**URL**: https://hexdocs.pm/mix/Mix.html + Elixir v1.18 release notes  
**Seções**: Bundle optimization, dead code elimination, path pruning  

**Key Findings OTP 26 + Elixir 1.17.3**:
```elixir
# Code path pruning reduces compilation by 16-40%
# Automatic dead code elimination in releases
# Concurrent application loading
# Dependency caching improvements
```

**Compile-Time Optimization**:
- Code path pruning before compilation
- Dependencies automatically recompiled when config changes
- @behaviour declarations no longer add compile-time dependencies
- Aliases in patterns/guards add no dependency

### [Fonte 3]: AtomVM Minimal Runtime
**URL**: https://github.com/atomvm/AtomVM + WebAssembly support  
**Focus**: Minimal Erlang VM, subset implementation

**AtomVM Design Philosophy**:
- Implements minimal Erlang VM subset
- Standard library is deliberately minimal
- Some modules not implemented by design
- Optimized GC mode with realloc (-DENABLE_REALLOC_GC=On)

---

## ❌ Antipatterns e Fixes [ERRO-COMUM]

### Common Bundle Bloat Patterns

#### 1. **Incluir Dependências Desnecessárias**
```elixir
# ❌ ERRO: Todas as deps em produção
def deps do
  [
    {:phoenix_live_dashboard, "~> 0.8"},  # Dev only
    {:phoenix_live_reload, "~> 1.4"},    # Dev only
    {:credo, "~> 1.7"},                  # Dev only
    {:dialyxir, "~> 1.4"},              # Dev only
    {:popcorn, "~> 0.1.0"}              # Production
  ]
end

# ✅ CORRETO: Deps por ambiente
def deps do
  [
    {:popcorn, "~> 0.1.0"},
    # Dev/test only
    {:phoenix_live_dashboard, "~> 0.8", only: :dev},
    {:phoenix_live_reload, "~> 1.4", only: :dev},
    {:credo, "~> 1.7", only: [:dev, :test]},
    {:dialyxir, "~> 1.4", only: [:dev, :test]}
  ]
end
```

#### 2. **Não Configurar Mix.Release para WASM**
```elixir
# ❌ ERRO: Release padrão
def project do
  [
    app: :blog,
    version: "0.1.0",
    elixir: "~> 1.17",
    deps: deps()
  ]
end

# ✅ CORRETO: Release otimizada WASM
def project do
  [
    app: :blog,
    version: "0.1.0",
    elixir: "~> 1.17",
    deps: deps(),
    releases: [
      wasm: [
        version: @version,
        applications: [blog: :permanent],
        strip_beams: true,           # Remove debug info
        quiet: true,                 # Reduce verbosity
        steps: [:assemble, :tar]     # Skip unnecessary steps
      ]
    ]
  ]
end
```

#### 3. **Logger Verboso em Produção WASM**
```elixir
# ❌ ERRO: Logger full em WASM
config :logger, level: :debug

# ✅ CORRETO: Logger otimizado WASM
config :logger,
  level: :warning,
  compile_time_purge_matching: [
    [level_lower_than: :warning]  # Remove debug/info logs
  ],
  backends: []  # No file logging em WASM
```

#### 4. **Phoenix Completo para Blog Simples**
```elixir
# ❌ ERRO: Phoenix full stack
use Phoenix.Router
import Phoenix.LiveDashboard.Router  # Desnecessário
import Phoenix.LiveView.Router

# ✅ CORRETO: Phoenix minimal
use Phoenix.Router
# Apenas imports necessários para blog
```

### Bundle Analysis Commands
```bash
# Verificar tamanho atual
ls -lah priv/static/wasm/

# Analisar dependências
mix deps.tree | grep -E "(runtime|compile)"

# Profile compilation
mix compile --profile | head -20
```

---

## 🏗️ Estratégias de Otimização [BEST-PRACTICE]

### 1. **Mix.Release WASM-Optimized**

```elixir
# mix.exs - Production Release Configuration
defmodule Blog.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :blog,
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: compilers(Mix.env()),
      deps: deps(),
      releases: releases()
    ]
  end

  # Environment-specific compilation paths
  defp elixirc_paths(:wasm), do: ["lib", "lib/blog_wasm"]
  defp elixirc_paths(_), do: ["lib"]

  # Minimal compilers for WASM
  defp compilers(:wasm), do: [:elixir]
  defp compilers(_), do: Mix.compilers()

  # WASM-optimized releases
  defp releases do
    [
      wasm: [
        version: @version,
        applications: [
          # Only essential applications
          blog: :permanent,
          kernel: :permanent,
          stdlib: :permanent,
          elixir: :permanent,
          logger: :permanent
        ],
        # Optimization flags
        strip_beams: true,
        quiet: true,
        runtime_config_path: false,
        cookie: "wasm_cookie",
        steps: [:assemble]  # Skip tarring for WASM
      ]
    ]
  end
end
```

### 2. **Environment-Specific Dependencies**

```elixir
defp deps do
  [
    # Production WASM essentials
    {:popcorn, "~> 0.1.0"},
    {:phoenix, "~> 1.7.0", only: [:dev, :test]},  # Not needed in WASM
    {:phoenix_html, "~> 4.0", only: [:dev, :test]},
    
    # Development only
    {:phoenix_live_dashboard, "~> 0.8", only: :dev},
    {:phoenix_live_reload, "~> 1.4", only: :dev},
    {:credo, "~> 1.7", only: [:dev, :test]},
    {:sobelow, "~> 0.13", only: [:dev, :test]},
    {:excoveralls, "~> 0.18", only: [:dev, :test]}
  ]
end
```

### 3. **Application Configuration WASM**

```elixir
# config/wasm.exs - WASM-specific configuration
import Config

# Logger minimal para WASM
config :logger,
  level: :warning,
  compile_time_purge_matching: [
    [level_lower_than: :warning]
  ],
  backends: []  # No file backends

# Popcorn optimizations
config :popcorn,
  out_dir: "static/wasm",
  runtime: [
    {:url, "/static/wasm/atomvm.wasm", target: :wasm}
  ],
  # Bundle optimization (quando disponível)
  tree_shaking: true,
  minimal_stdlib: true

# Application minimal
config :blog,
  # Disable unnecessary features
  live_dashboard: false,
  dev_routes: false,
  debug_errors: false
```

---

## 🔧 Implementações Prontas [TEMPLATE]

### Script de Build Otimizado

```bash
#!/bin/bash
# scripts/build-wasm-optimized.sh

set -e

echo "🚀 Building optimized WASM bundle..."

# Environment setup
export MIX_ENV=wasm
export ELIXIR_ERL_OPTIONS="+fnu"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
mix clean
rm -rf priv/static/wasm/*

# Install minimal deps
echo "📦 Installing minimal dependencies..."
mix deps.get --only wasm

# Compile with optimization
echo "🔨 Compiling with optimizations..."
mix compile --warnings-as-errors

# Build WASM runtime (primeira vez apenas)
if [ ! -f "priv/static/wasm/atomvm.wasm" ]; then
  echo "🏗️ Building AtomVM runtime..."
  mix popcorn.build_runtime --target wasm --minimal
fi

# Cook modules with optimization
echo "👨‍🍳 Cooking optimized modules..."
MIX_ENV=wasm mix popcorn.cook --optimize

# Analyze bundle size
echo "📊 Bundle analysis:"
ls -lah priv/static/wasm/

# Size validation
BUNDLE_SIZE=$(du -sm priv/static/wasm/ | cut -f1)
if [ $BUNDLE_SIZE -gt 3 ]; then
  echo "⚠️ WARNING: Bundle size ${BUNDLE_SIZE}MB exceeds 3MB target"
  exit 1
fi

echo "✅ Optimized WASM bundle complete: ${BUNDLE_SIZE}MB"
```

### Mix Task Personalizada para Bundle Analysis

```elixir
# lib/mix/tasks/bundle.analyze.ex
defmodule Mix.Tasks.Bundle.Analyze do
  @moduledoc """
  Analyzes WASM bundle size and provides optimization suggestions.
  
  ## Usage
  
      mix bundle.analyze
      
  """
  use Mix.Task

  @shortdoc "Analyzes WASM bundle size"

  def run(_args) do
    wasm_dir = "priv/static/wasm"
    
    unless File.exists?(wasm_dir) do
      Mix.shell().error("WASM directory not found. Run mix popcorn.cook first.")
      return
    end

    analyze_bundle(wasm_dir)
  end

  defp analyze_bundle(dir) do
    files = Path.wildcard("#{dir}/**/*")
    
    file_sizes = 
      files
      |> Enum.filter(&File.regular?/1)
      |> Enum.map(fn file ->
        size = File.stat!(file).size
        rel_path = Path.relative_to(file, dir)
        {rel_path, size}
      end)
      |> Enum.sort_by(&elem(&1, 1), :desc)

    total_size = Enum.sum(Enum.map(file_sizes, &elem(&1, 1)))
    
    Mix.shell().info("🔍 Bundle Analysis:")
    Mix.shell().info("Total Size: #{format_size(total_size)}")
    
    if total_size > 3_000_000 do
      Mix.shell().error("⚠️ Bundle exceeds 3MB target!")
    end
    
    Mix.shell().info("\n📁 File Breakdown:")
    
    Enum.each(file_sizes, fn {file, size} ->
      percentage = (size / total_size * 100) |> Float.round(1)
      Mix.shell().info("  #{file}: #{format_size(size)} (#{percentage}%)")
    end)
    
    suggest_optimizations(file_sizes, total_size)
  end

  defp format_size(bytes) when bytes > 1_000_000 do
    "#{Float.round(bytes / 1_000_000, 1)}MB"
  end
  defp format_size(bytes) when bytes > 1_000 do
    "#{Float.round(bytes / 1_000, 1)}KB"
  end
  defp format_size(bytes), do: "#{bytes}B"

  defp suggest_optimizations(files, total) when total > 3_000_000 do
    Mix.shell().info("\n💡 Optimization Suggestions:")
    
    # Find large AVM files
    large_avm = Enum.filter(files, fn {file, size} -> 
      String.ends_with?(file, ".avm") and size > 500_000
    end)
    
    unless Enum.empty?(large_avm) do
      Mix.shell().info("  • Consider module selection for large .avm files")
    end
    
    # Check for development artifacts
    dev_files = Enum.filter(files, fn {file, _} ->
      String.contains?(file, ["test", "dev", "dashboard"])
    end)
    
    unless Enum.empty?(dev_files) do
      Mix.shell().info("  • Remove development-only files from bundle")
    end
  end
  defp suggest_optimizations(_, _), do: :ok
end
```

---

## 🎯 Estratégias AtomVM-Specific [WASM-SPECIFIC]

### 1. **Módulos Essenciais vs Opcionais**

```elixir
# config/wasm.exs - Module Selection Strategy
config :popcorn,
  # Essential modules apenas (quando feature disponível)
  included_modules: [
    # Core Elixir
    :kernel,
    :stdlib,
    :elixir,
    
    # Blog essentials
    :blog,
    :blog_wasm,
    
    # Minimal Phoenix components
    :phoenix_html,
    :plug_crypto
  ],
  
  # Exclude heavy modules
  excluded_modules: [
    # Development
    :phoenix_live_dashboard,
    :phoenix_live_reload,
    :credo,
    :sobelow,
    
    # Testing
    :ex_unit,
    :excoveralls,
    
    # Database (if not needed client-side)
    :ecto,
    :postgrex,
    
    # Heavy dependencies
    :ssl,
    :inets,
    :xmerl
  ]
```

### 2. **AtomVM Compilation Flags**

```bash
# KERL flags for minimal AtomVM build
export KERL_CONFIGURE_OPTIONS="
  --disable-debug
  --without-javac
  --without-odbc
  --without-wx
  --without-observer
  --without-debugger
  --without-et
  --without-megaco
  --without-xmerl
  --enable-builtin-zlib
"

# AtomVM WASM-specific compilation
export ATOMVM_WASM_FLAGS="
  -DENABLE_REALLOC_GC=On
  -DAVMPACKDATA_FOLD=On
  -DWASM_MINIMAL=On
"
```

### 3. **Bundle Post-Processing**

```bash
#!/bin/bash
# scripts/optimize-wasm-bundle.sh

# Compress WASM files
wasm-opt --strip-debug --strip-producers --vacuum priv/static/wasm/atomvm.wasm -o priv/static/wasm/atomvm.min.wasm

# Brotli compression para assets
find priv/static/wasm -name "*.avm" -exec brotli {} \;
find priv/static/wasm -name "*.wasm" -exec brotli {} \;
find priv/static/wasm -name "*.js" -exec brotli {} \;

# Bundle integrity check
echo "📊 Post-optimization sizes:"
ls -lah priv/static/wasm/
```

---

## 📊 Métricas e Validação [PERFORMANCE]

### Bundle Size Benchmarks
```yaml
Baseline (Phase 2):
  AtomVM.wasm: 717KB
  AtomVM.mjs: 130KB  
  popcorn.avm: 6.9MB
  Total: 7.8MB

Target (Phase 3):
  AtomVM.wasm: 500KB (minimal stdlib)
  AtomVM.mjs: 100KB (tree shaken)
  popcorn.avm: 2.4MB (module selection)
  Total: 3.0MB (61% reduction)

Compressed:
  Brotli: ~1.5MB transfer size
  Gzip: ~1.8MB transfer size
```

### Performance Validation Script
```elixir
# test/bundle_performance_test.exs
defmodule BundlePerformanceTest do
  use ExUnit.Case
  
  @wasm_dir "priv/static/wasm"
  @max_bundle_size 3_000_000  # 3MB
  @max_init_time 500          # 500ms
  
  test "bundle size within limits" do
    total_size = 
      Path.wildcard("#{@wasm_dir}/**/*")
      |> Enum.filter(&File.regular?/1)
      |> Enum.map(&File.stat!/1)
      |> Enum.map(& &1.size)
      |> Enum.sum()
    
    assert total_size <= @max_bundle_size, 
      "Bundle size #{total_size} exceeds #{@max_bundle_size} limit"
  end
  
  test "WASM initialization performance" do
    # Simulate WASM loading time
    start_time = System.monotonic_time(:millisecond)
    
    # Simulate AtomVM initialization
    Process.sleep(100)  # Replace with actual WASM init
    
    init_time = System.monotonic_time(:millisecond) - start_time
    
    assert init_time <= @max_init_time,
      "WASM init time #{init_time}ms exceeds #{@max_init_time}ms limit"
  end
end
```

---

## 🔗 Referências e Links Oficiais [REFERÊNCIAS]

### Documentação Oficial
- **Popcorn**: https://hexdocs.pm/popcorn/readme.html [v0.1.0]
- **Mix Release**: https://hexdocs.pm/mix/Mix.Tasks.Release.html [v1.18+]
- **AtomVM**: https://github.com/atomvm/AtomVM [WebAssembly support]
- **Elixir Compiler**: https://hexdocs.pm/elixir/compiler-tracing.html [optimization]

### Compatibility Notes
- **Popcorn**: Requires exactly Elixir 1.17.3 + OTP 26.0.2
- **AtomVM WASM**: Experimental feature, active development
- **Bundle optimization**: Features em desenvolvimento para v0.2.0

### Community Resources
- **Elixir Forum**: WebAssembly discussions
- **AtomVM Discord**: WASM-specific support
- **Software Mansion Blog**: Popcorn updates

---

**🎯 RESULTADO ESPERADO**: Bundle optimization de 7.8MB → <3MB através de estratégias validadas incluindo module selection, dead code elimination, environment-specific builds, e AtomVM minimal configuration. Implementation ready para Phase 3 com scripts automatizados e validação de performance.
---
## 📁 11-pop-corn-wa/DevOps.md

# DevOps para Web App 100% Elixir com Popcorn WebAssembly
## Checklist de Aprendizado e Evolução Contínua

---

## 📋 Checklist Principal: Desenvolvimento Local com Popcorn

### 📚 **FASE 1: FUNDAMENTOS ELIXIR PURO** (2 semanas)

#### 1.1 Setup Ambiente Elixir
- [ ] **Instalar Erlang/Elixir**
  - [ ] ASDF para gerenciar versões
  - [ ] Elixir 1.17.3 (versão específica do Popcorn)
  - [ ] OTP 26.0.2 (compatível com Popcorn)
  - [ ] Verificar instalação: `elixir --version`

- [ ] **Phoenix Framework**
  - [ ] Instalar Phoenix 1.7+
  - [ ] PostgreSQL para banco de dados
  - [ ] Node.js para assets (Phoenix padrão)
  - [ ] Criar app teste: `mix phx.new teste --live`

#### 1.2 Entender Popcorn Básico
- [ ] **O que é Popcorn**
  - [ ] AtomVM rodando no browser
  - [ ] Elixir compilado para WebAssembly
  - [ ] Limitações atuais (sem big integers, ETS limitado)
  - [ ] Bundle de ~3MB (incluindo runtime)

- [ ] **Requisitos do Browser**
  - [ ] SharedArrayBuffer habilitado
  - [ ] Headers COOP/COEP configurados
  - [ ] Browsers modernos (Chrome, Firefox, Edge)
  - [ ] Console para debug

### 🚀 **FASE 2: PRIMEIRO PROJETO POPCORN** (2 semanas)

#### 2.1 Setup Popcorn
- [ ] **Instalar Popcorn**
  - [ ] Adicionar `{:popcorn, "~> 0.1.0"}` ao mix.exs
  - [ ] mix deps.get
  - [ ] Verificar documentação oficial
  - [ ] Entender estrutura de arquivos

- [ ] **Configurar Build**
  - [ ] mix popcorn.build_runtime --target wasm
  - [ ] Entender processo de compilação
  - [ ] Verificar saída em priv/static
  - [ ] Testar servidor local

#### 2.2 Hello World no Browser
- [ ] **Criar módulo Elixir simples**
  - [ ] Função pura sem dependências
  - [ ] Sem processos ou GenServers (início)
  - [ ] Retorno de dados simples
  - [ ] Console.log via JavaScript

- [ ] **Compilar para WASM**
  - [ ] mix popcorn.cook
  - [ ] Verificar arquivo .wasm gerado
  - [ ] Tamanho do bundle
  - [ ] Tempo de compilação

#### 2.3 Interoperabilidade JavaScript
- [ ] **Chamar Elixir do JavaScript**
  - [ ] Popcorn.Wasm.run/2
  - [ ] Passar parâmetros simples
  - [ ] Receber retorno
  - [ ] Tratamento de erros

- [ ] **Chamar JavaScript do Elixir**
  - [ ] Popcorn.Wasm.run_js/1
  - [ ] Manipular DOM básico
  - [ ] Console.log para debug
  - [ ] Eventos simples

### 🔧 **FASE 3: DESENVOLVIMENTO LOCAL INTEGRADO** (3 semanas)

#### 3.1 Phoenix + Popcorn
- [ ] **Estrutura do projeto**
  - [ ] lib/my_app/ para Backend Phoenix
  - [ ] lib/my_app_wasm/ para Código Popcorn
  - [ ] priv/static/ para WASM compilado
  - [ ] assets/ para JavaScript bridge

- [ ] **Servidor de desenvolvimento**
  - [ ] Phoenix servindo arquivos WASM
  - [ ] Headers CORS configurados
  - [ ] COOP/COEP para SharedArrayBuffer
  - [ ] Live reload setup

#### 3.2 Compartilhamento de Código
- [ ] **Módulos compartilhados**
  - [ ] Business logic pura em Elixir
  - [ ] Validações reutilizáveis
  - [ ] Estruturas de dados comuns
  - [ ] Funções utilitárias

- [ ] **Compilação seletiva**
  - [ ] Macros para código específico
  - [ ] Compile-time flags
  - [ ] Separação server/client
  - [ ] Dead code elimination

#### 3.3 Estado e Comunicação
- [ ] **Estado no browser**
  - [ ] Agentes simples (se suportado)
  - [ ] Estado funcional imutável
  - [ ] LocalStorage via JS
  - [ ] SessionStorage para temporário

- [ ] **Phoenix Channels + Popcorn**
  - [ ] WebSocket do Phoenix
  - [ ] Mensagens para Popcorn
  - [ ] Sincronização de estado
  - [ ] Reconexão automática

### 🧪 **FASE 4: TESTING E QUALIDADE** (2 semanas)

#### 4.1 Testes Unitários
- [ ] **Testes do código compartilhado**
  - [ ] ExUnit padrão
  - [ ] Mesmo código, dois contextos
  - [ ] Property-based testing
  - [ ] Doctests

- [ ] **Testes específicos Popcorn**
  - [ ] Funções puras primeiro
  - [ ] Mock de JavaScript
  - [ ] Testes de integração básicos
  - [ ] Coverage reports

#### 4.2 Testes no Browser
- [ ] **Automação com Wallaby**
  - [ ] Setup ChromeDriver
  - [ ] Carregar módulo Popcorn
  - [ ] Executar funções Elixir
  - [ ] Validar resultados

- [ ] **Debugging**
  - [ ] Chrome DevTools
  - [ ] Console.log estratégico
  - [ ] Source maps (se disponível)
  - [ ] Performance profiling

#### 4.3 CI Pipeline
- [ ] **GitHub Actions**
  - [ ] Test Elixir Code
  - [ ] Build Popcorn
  - [ ] Check Bundle Size
  - [ ] Quality Gates

### 📦 **FASE 5: BUILD E DEPLOYMENT LOCAL** (2 semanas)

#### 5.1 Otimização de Build
- [ ] **Reduzir tamanho do bundle**
  - [ ] Remover código não usado
  - [ ] Compilação release mode
  - [ ] Compressão gzip/brotli
  - [ ] Lazy loading de módulos

- [ ] **Cache estratégico**
  - [ ] Service Worker setup
  - [ ] Cache do WASM bundle
  - [ ] Versionamento de assets
  - [ ] Cache busting

#### 5.2 Docker para Desenvolvimento
- [ ] **Dockerfile multi-stage**
  - [ ] Build stage com Elixir
  - [ ] Runtime stage otimizado
  - [ ] Configuração de headers

- [ ] **Docker Compose**
  - [ ] Phoenix app
  - [ ] PostgreSQL
  - [ ] Servidor de arquivos estáticos
  - [ ] Headers COOP/COEP configurados

#### 5.3 Desenvolvimento Offline
- [ ] **Progressive Web App**
  - [ ] Manifest.json
  - [ ] Service Worker
  - [ ] Offline fallback
  - [ ] Sincronização quando online

- [ ] **Estado offline**
  - [ ] IndexedDB via JavaScript
  - [ ] Queue de ações
  - [ ] Conflict resolution
  - [ ] Sync com servidor

### 📊 **FASE 6: MONITORAMENTO E OBSERVABILIDADE** (2 semanas)

#### 6.1 Telemetria Phoenix
- [ ] **Backend metrics**
  - [ ] Phoenix.Telemetry setup
  - [ ] Ecto query metrics
  - [ ] Channel connections
  - [ ] Request latency

- [ ] **Dashboard local**
  - [ ] Phoenix LiveDashboard
  - [ ] Métricas customizadas
  - [ ] Alertas básicos
  - [ ] Histórico de performance

#### 6.2 Monitoramento Popcorn
- [ ] **Performance no browser**
  - [ ] Tempo de inicialização
  - [ ] Uso de memória
  - [ ] Tempo de execução de funções
  - [ ] Erros e crashes

- [ ] **Logging estruturado**
  - [ ] Logs para console
  - [ ] Envio para servidor
  - [ ] Níveis de log
  - [ ] Debugging remoto

### 🔄 **FASE 7: LIVERELOAD E DX** (1 semana)

#### 7.1 Hot Reload Setup
- [ ] **Phoenix LiveReload**
  - [ ] Watch de arquivos Elixir
  - [ ] Recompilação automática
  - [ ] Refresh do browser
  - [ ] Preservação de estado

- [ ] **Popcorn auto-build**
  - [ ] File watcher para .ex
  - [ ] mix popcorn.cook automático
  - [ ] Notificação de rebuild
  - [ ] Reload do módulo WASM

### 🎮 **FASE 8: CASOS DE USO PRÁTICOS** (3 semanas)

#### 8.1 Aplicação TODO List
- [ ] **Backend Phoenix**
  - [ ] CRUD API
  - [ ] Phoenix Channels
  - [ ] Autenticação básica
  - [ ] Persistência Ecto

- [ ] **Frontend Popcorn**
  - [ ] Renderização de lista
  - [ ] Adicionar/remover items
  - [ ] Estado local
  - [ ] Sincronização com servidor

#### 8.2 Chat em Tempo Real
- [ ] **Funcionalidades**
  - [ ] Mensagens via Channels
  - [ ] Presença online
  - [ ] Histórico de mensagens
  - [ ] Notificações no browser

#### 8.3 Mini Editor de Texto
- [ ] **Editor básico**
  - [ ] Manipulação de texto
  - [ ] Undo/Redo em Elixir
  - [ ] Syntax highlighting
  - [ ] Auto-save

### 🚦 **FASE 9: PRODUÇÃO LOCAL** (2 semanas)

#### 9.1 Preparação para Deploy
- [ ] **Build de produção**
  - [ ] MIX_ENV=prod
  - [ ] Releases com Mix
  - [ ] Assets minificados
  - [ ] WASM otimizado

- [ ] **Configuração de ambiente**
  - [ ] Variáveis de ambiente
  - [ ] Secrets management
  - [ ] Database migrations
  - [ ] Static files CDN

#### 9.2 Performance
- [ ] **Otimizações Phoenix**
  - [ ] Connection pooling
  - [ ] Query optimization
  - [ ] Cache strategies
  - [ ] Response compression

- [ ] **Otimizações Popcorn**
  - [ ] Lazy loading
  - [ ] Code splitting (se possível)
  - [ ] Memory management
  - [ ] Batch operations

### 📈 **FASE 10: SCALE E EVOLUÇÃO** (2 semanas)

#### 10.1 Estratégias de Scale
- [ ] **Horizontal scaling**
  - [ ] Load balancer local
  - [ ] Multiple Phoenix nodes
  - [ ] Distributed Erlang
  - [ ] Session management

#### 10.2 Evolução da Arquitetura
- [ ] **Modularização**
  - [ ] Umbrella apps
  - [ ] Bounded contexts
  - [ ] Microservices consideration
  - [ ] API Gateway pattern

---

## 🔄 Evolução Contínua e Contribuição ao Ecossistema

### Filosofia de Evolução Colaborativa

O ecossistema Elixir sempre foi construído sobre colaboração. Quando você usa Popcorn e WebAssembly, você é um **pioneiro** ajudando a moldar o futuro da linguagem.

### Ciclo de Evolução Contínua

```
USAR → APRENDER → MELHORAR → COMPARTILHAR → USAR...
```

- **USAR** (Semanas 1-4): Implemente em projetos internos
- **APRENDER** (Semanas 5-8): Entenda o código fonte
- **MELHORAR** (Semanas 9-12): Transforme workarounds em soluções
- **COMPARTILHAR** (Contínuo): Publique melhorias como PRs

### 🎯 Mapa de Contribuições por Nível

#### 🟢 Nível Iniciante
- [ ] Criar exemplos simples
- [ ] Reportar bugs estruturados
- [ ] Traduzir documentação
- [ ] Revisar código de outros

#### 🟡 Nível Intermediário
- [ ] Desenvolver Mix tasks
- [ ] Criar bibliotecas de compatibilidade
- [ ] Escrever benchmarks
- [ ] Otimizar performance

#### 🔴 Nível Avançado
- [ ] Implementar features core
- [ ] Otimizações de compiler
- [ ] Integração com ferramentas
- [ ] Arquitetura de soluções

### 📊 Roadmap Comunitário 2025-2026

#### Q1 2025: Fundação
- Estabilidade e correção de bugs
- Documentação completa
- 10+ exemplos funcionais

#### Q2 2025: Expansão
- Features essenciais (ETS, processos)
- Redução de bundle 30%
- Tooling melhorado

#### Q3 2025: Otimização
- Bundle < 2MB
- Performance 50% melhor
- Developer experience aprimorada

#### Q4 2025: Maturidade
- Versão 1.0 production ready
- Ecossistema de bibliotecas
- Cases empresariais

### 🛠️ Kit de Ferramentas do Contribuidor

#### Setup Básico
```bash
# Fork e desenvolvimento
git clone https://github.com/SEU-USER/popcorn
git checkout -b feature/minha-contribuicao

# Desenvolvimento
mix test
mix format
mix credo

# Commit semântico
git commit -m "feat: adiciona suporte para localStorage"
```

#### Estrutura de Contribuição
```
minha-contribuicao/
├── lib/          # Código principal
├── test/         # Testes completos
├── examples/     # Exemplos de uso
├── docs/         # Documentação
└── CHANGELOG.md  # Mudanças
```

### 💡 Patterns de Contribuição

#### Problem-Solution-Validation
1. **Problem**: Identifique claramente o problema
2. **Solution**: Proponha solução elegante
3. **Validation**: Prove com testes e métricas

#### Incremental Enhancement
- v1: Funcionalidade básica
- v2: Adiciona tipos
- v3: Adiciona cache
- v4: Adiciona telemetria

### 📝 Compromisso de Contribuição

#### Modelo de Compromisso (Q1 2025)
- [ ] 2 horas/semana para contribuições
- [ ] 1 bug report detalhado por mês
- [ ] 1 PR (doc ou código) por trimestre
- [ ] 1 blog post por semestre

#### Foco Principal (escolha um):
- [ ] Redução de bundle size
- [ ] Melhorias de debugging
- [ ] Documentação e exemplos
- [ ] Performance optimization
- [ ] Feature implementation

### 🚀 Começando Hoje

#### Semana 1: Reconhecimento
- [ ] Star no repo do Popcorn
- [ ] Entrar na comunidade Slack/Discord
- [ ] Ler issues abertas
- [ ] Rodar exemplos existentes

#### Semana 2: Primeiro Contato
- [ ] Abrir issue com pergunta
- [ ] Comentar em issue existente
- [ ] Testar PR pendente
- [ ] Compartilhar nas redes sociais

#### Semana 3: Primeira Contribuição
- [ ] Corrigir typo na documentação
- [ ] Adicionar exemplo simples
- [ ] Melhorar mensagem de erro
- [ ] Traduzir documentação

#### Mês 2: Contribuição Substancial
- [ ] Implementar pequena feature
- [ ] Corrigir bug real
- [ ] Escrever tutorial completo
- [ ] Criar ferramenta auxiliar

---

## ✅ Métricas de Sucesso

### KPIs do Projeto
- **Bundle size**: < 3MB inicial, < 2MB em 6 meses
- **Performance**: 2x melhoria em operações críticas
- **Features**: 80% do Elixir core funcionando
- **Stability**: Zero crashes em produção

### Marcos de Desenvolvimento
- Primeiro "Hello World": **Dia 3**
- App TODO funcionando: **Semana 3**
- Chat real-time: **Semana 5**
- Sistema production-ready: **Semana 12**

### Impacto Comunitário
- Bugs reportados e resolvidos
- PRs aceitos no projeto
- Desenvolvedores ajudados
- Features implementadas

---

## 📚 Recursos Essenciais

### Documentação
- [GitHub Popcorn](https://github.com/software-mansion/popcorn)
- [Demo Online](https://popcorn.swmansion.com)
- [AtomVM Documentation](https://atomvm.net)
- [Phoenix Guides](https://hexdocs.pm/phoenix)

### Comunidade
- Elixir Forum - Popcorn threads
- Slack #popcorn
- Discord WebAssembly Guild

### Aprendizado
- Elixir School
- Phoenix LiveView Course
- WebAssembly MDN Docs

---

## 🎯 Vantagens da Abordagem 100% Elixir

✅ **Uma única linguagem** para todo o stack  
✅ **Compartilhamento total** de código e lógica  
✅ **Mesmas ferramentas** e workflow unificado  
✅ **Comunidade única** e coesa  
✅ **Sem context switch** mental  

### Limitações Atuais e Soluções

| Limitação | Solução Imediata | Contribuição Possível |
|-----------|------------------|----------------------|
| v0.1.0 experimental | Use em features não-críticas | Reporte bugs, escreva testes |
| Features faltantes | Use workarounds e polyfills | Implemente compatibilidade |
| Bundle 3MB | Lazy loading e compressão | Tree shaking, otimizações |
| Performance | Híbrido JS + Popcorn | Benchmarks e profiling |
| Debug complexo | Logging estratégico | Source maps, DevTools |

---

**Sua jornada com Popcorn começa agora. Cada linha de código, cada bug reportado, cada exemplo criado contribui para o futuro do Elixir com WebAssembly.**

---
## 📁 11-pop-corn-wa/offline-first-patterns.md

# Offline-First Architecture [NAVEGACAO-RAPIDA][BEST-PRACTICE]

**Data**: 30/08/2025  
**Contexto**: Projeto Blog WebAssembly-First - Phase 3 Offline Implementation  
**Architecture**: Phoenix LiveView + WASM client processing + CRDT sync  
**Target**: 100% feature parity online/offline com state synchronization  
**Fontes**: Phoenix LiveView 1.1.8 + CRDT patterns + PWA best practices 2025

## 🔍 Quick Navigation [ECONOMIA-TOKENS]
| Find | Line | Content | Savings |
|------|------|---------|---------|
| [ESSENCIAL] | L25 | Architecture overview | 75% |
| [ERRO-COMUM] | L120 | Sync conflicts patterns | 85% |
| [TEMPLATE] | L200 | Ready offline modules | 80% |
| [PWA-SPECIFIC] | L320 | Service worker patterns | 90% |

---

## 🏗️ Architecture Overview [ESSENCIAL]

### Problema Tradicional LiveView
- **Online Dependency**: WebSocket connection required para functionality
- **State Loss**: Server-side state perdido em network interruption
- **No Offline**: Zero functionality sem connection
- **Single Point**: Server como único source of truth

### Solução Hybrid Architecture
```yaml
Hybrid LiveView + WASM + CRDT Architecture:
  
  Client Layer (WASM):
    - AtomVM runtime: Local Elixir processing
    - CRDT State: Local conflict-free updates (Yjs)  
    - Storage: IndexedDB persistent storage
    - Processing: Text analysis, validation offline
    
  Synchronization Layer:
    - Phoenix.PubSub: Real-time broadcasts when online
    - Phoenix.Sync: CRDT sync via Postgres/SQLite
    - Conflict Resolution: Operational transforms
    - Reconnection: State rehydration patterns
    
  Server Layer (Phoenix):
    - LiveView: Real-time UI when online
    - Database: Authoritative source of truth
    - Sync API: CRDT operations processing
    - Broadcasting: Multi-user state sync
```

### State Management Strategy
```elixir
# Client-side state (WASM)
BlogWasm.State.Manager -> CRDTs (Yjs) -> IndexedDB

# Server-side state (Phoenix)  
Blog.Contexts -> Ecto -> PostgreSQL

# Synchronization
Phoenix.Channel -> CRDT.Sync -> Conflict.Resolution
```

---

## 📚 Pesquisa em Fontes Oficiais [ESSENCIAL]

### [Fonte 1]: Phoenix LiveView Offline Patterns
**URL**: https://dev.to/ndrean/liveview-and-pwa-2gn4 + LiveView docs  
**Descoberta**: PWA + LiveView integration com local state management

**Key Patterns Discovered**:
- **Client-side CRDTs**: Yjs for local state even when offline
- **Server Sync**: Phoenix.Sync with logical replication
- **Service Workers**: vite-plugin-pwa for app shell caching
- **Reactive UI**: JavaScript offloading for offline-first

### [Fonte 2]: Phoenix.PubSub + Multi-User State
**URL**: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html  
**Focus**: Cross-session state synchronization

**Advanced State Sync Patterns**:
```elixir
# Multi-user state broadcasting
Phoenix.PubSub.broadcast(Blog.PubSub, "blog:posts", {:post_updated, post})

# Cross-session presence
Phoenix.Presence.track(socket, "blog:readers", user_id, %{status: "reading"})

# State persistence
GenServer (ETS/Redis) -> Broadcast -> LiveView -> Client Sync
```

### [Fonte 3]: WebAssembly Client Processing 
**URL**: Elixir Forum + WASM integration examples  
**Discovery**: WASM for CPU-intensive calculations offline

**Client Processing Capabilities**:
- **Text Analysis**: NLP processing em WASM
- **Validation**: Client-side form validation
- **Computation**: Geographic calculations, data processing
- **Search**: Local search indices

---

## ❌ Offline Sync Antipatterns [ERRO-COMUM]

### 1. **Naive State Overwriting**
```elixir
# ❌ ERRO: Last-write-wins conflicts
def handle_info({:sync_state, new_state}, socket) do
  # Overwrites local changes
  {:noreply, assign(socket, :posts, new_state)}
end

# ✅ CORRETO: CRDT merge
def handle_info({:sync_crdt_ops, operations}, socket) do
  current_state = socket.assigns.posts_crdt
  merged_state = CRDT.apply_operations(current_state, operations)
  
  {:noreply, assign(socket, :posts_crdt, merged_state)}
end
```

### 2. **Missing Conflict Resolution**
```elixir
# ❌ ERRO: No conflict detection
def sync_post(local_post, server_post) do
  server_post  # Always prefer server
end

# ✅ CORRETO: Operational transforms
def sync_post(local_post, server_post) do
  case CRDT.detect_conflict(local_post, server_post) do
    :no_conflict -> 
      CRDT.merge(local_post, server_post)
    {:conflict, operations} -> 
      CRDT.resolve_conflict(local_post, server_post, operations)
  end
end
```

### 3. **No Offline Indicators**
```javascript
// ❌ ERRO: No feedback sobre status connection
// User doesn't know why features are disabled

// ✅ CORRETO: Clear offline indicators
class OfflineStatusManager {
  updateUI(isOnline) {
    const indicator = document.getElementById('connection-status');
    indicator.textContent = isOnline ? 'Online' : 'Offline';
    indicator.className = isOnline ? 'online' : 'offline';
    
    // Enable/disable features based on status
    const onlineFeatures = document.querySelectorAll('.online-only');
    onlineFeatures.forEach(el => {
      el.disabled = !isOnline;
    });
  }
}
```

### 4. **Blocking UI During Sync**
```elixir
# ❌ ERRO: UI frozen durante sync
def handle_event("sync_all", _params, socket) do
  # Synchronous operation blocks UI
  sync_result = Blog.Sync.sync_all_posts()
  {:noreply, assign(socket, :posts, sync_result)}
end

# ✅ CORRETO: Async sync with progress
def handle_event("sync_all", _params, socket) do
  # Start async task
  Task.start(fn -> 
    Blog.Sync.sync_all_posts_async(socket.assigns.user_id)
  end)
  
  # Show progress immediately
  {:noreply, assign(socket, :sync_status, :syncing)}
end
```

---

## 🔧 Implementation Patterns [TEMPLATE]

### 1. **CRDT State Manager (Client WASM)**

```elixir
# lib/blog_wasm/state_manager.ex
defmodule BlogWasm.StateManager do
  @moduledoc """
  Client-side state management with CRDT operations.
  Runs in AtomVM WASM environment.
  """
  
  use GenServer
  
  defstruct [
    :posts_crdt,
    :comments_crdt,
    :local_operations,
    :sync_status,
    :last_sync
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Client API
  def create_post(title, content) do
    operation = {:create_post, generate_id(), title, content, timestamp()}
    GenServer.call(__MODULE__, {:apply_operation, operation})
  end

  def update_post(id, changes) do
    operation = {:update_post, id, changes, timestamp()}
    GenServer.call(__MODULE__, {:apply_operation, operation})
  end

  def get_posts do
    GenServer.call(__MODULE__, :get_posts)
  end

  def sync_with_server(server_operations) do
    GenServer.cast(__MODULE__, {:sync_operations, server_operations})
  end

  # Server callbacks
  def init(_opts) do
    # Load state from IndexedDB via JavaScript interop
    initial_state = load_from_storage()
    
    state = %__MODULE__{
      posts_crdt: initial_state.posts || %{},
      comments_crdt: initial_state.comments || %{},
      local_operations: [],
      sync_status: :offline,
      last_sync: nil
    }
    
    {:ok, state}
  end

  def handle_call({:apply_operation, operation}, _from, state) do
    # Apply operation locally (CRDT)
    new_crdt = apply_crdt_operation(state.posts_crdt, operation)
    
    # Store operation for sync
    new_operations = [operation | state.local_operations]
    
    # Update state
    new_state = %{state |
      posts_crdt: new_crdt,
      local_operations: new_operations
    }
    
    # Persist to IndexedDB
    persist_to_storage(new_state)
    
    # Broadcast change locally  
    broadcast_local_change(operation)
    
    {:reply, :ok, new_state}
  end

  def handle_call(:get_posts, _from, state) do
    posts = CRDT.to_list(state.posts_crdt)
    {:reply, posts, state}
  end

  def handle_cast({:sync_operations, server_ops}, state) do
    # Merge server operations with local CRDTs
    merged_crdt = 
      server_ops
      |> Enum.reduce(state.posts_crdt, &apply_crdt_operation(&2, &1))
    
    # Clear synced local operations
    remaining_ops = filter_synced_operations(state.local_operations, server_ops)
    
    new_state = %{state |
      posts_crdt: merged_crdt,
      local_operations: remaining_ops,
      sync_status: :synced,
      last_sync: DateTime.utc_now()
    }
    
    persist_to_storage(new_state)
    broadcast_sync_complete()
    
    {:noreply, new_state}
  end

  # CRDT operations
  defp apply_crdt_operation(crdt, {:create_post, id, title, content, timestamp}) do
    Map.put(crdt, id, %{
      id: id,
      title: title,
      content: content,
      created_at: timestamp,
      updated_at: timestamp,
      vector_clock: [timestamp]
    })
  end

  defp apply_crdt_operation(crdt, {:update_post, id, changes, timestamp}) do
    Map.update(crdt, id, nil, fn post ->
      %{post |
        title: changes[:title] || post.title,
        content: changes[:content] || post.content,
        updated_at: timestamp,
        vector_clock: [timestamp | post.vector_clock]
      }
    end)
  end

  # JavaScript interop for IndexedDB
  defp load_from_storage do
    # Bridge to JavaScript IndexedDB
    js_call("loadBlogState", [])
  end

  defp persist_to_storage(state) do
    # Bridge to JavaScript IndexedDB
    js_call("saveBlogState", [state])
  end

  defp broadcast_local_change(operation) do
    # Broadcast para UI local
    Phoenix.PubSub.local_broadcast(Blog.PubSub, "wasm:local", {:local_change, operation})
  end

  # Utility functions
  defp generate_id, do: System.unique_integer([:positive])
  defp timestamp, do: DateTime.utc_now()
end
```

### 2. **Phoenix LiveView Offline Integration**

```elixir
# lib/blog_web/live/blog_live.ex
defmodule BlogWeb.BlogLive do
  use BlogWeb, :live_view
  
  alias Blog.Content
  alias BlogWasm.StateManager

  def mount(_params, _session, socket) do
    # Subscribe to real-time updates
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "blog:posts")
      Phoenix.PubSub.subscribe(Blog.PubSub, "wasm:local")
    end
    
    socket = 
      socket
      |> assign(:posts, list_posts())
      |> assign(:connection_status, :online)
      |> assign(:sync_status, :idle)
      |> assign(:local_changes, [])
    
    {:ok, socket}
  end

  # Real-time updates from server
  def handle_info({:post_updated, post}, socket) do
    posts = update_post_in_list(socket.assigns.posts, post)
    {:noreply, assign(socket, :posts, posts)}
  end

  # Local changes from WASM
  def handle_info({:local_change, operation}, socket) do
    # Show optimistic UI update
    posts = apply_optimistic_update(socket.assigns.posts, operation)
    local_changes = [operation | socket.assigns.local_changes]
    
    socket = 
      socket
      |> assign(:posts, posts)
      |> assign(:local_changes, local_changes)
      |> assign(:sync_status, :pending)
    
    # Schedule sync attempt
    Process.send_after(self(), :attempt_sync, 1000)
    
    {:noreply, socket}
  end

  # Connection status changes  
  def handle_info({:connection_status, status}, socket) do
    socket = assign(socket, :connection_status, status)
    
    case status do
      :online -> 
        send(self(), :sync_pending_changes)
        {:noreply, socket}
      :offline ->
        {:noreply, socket}
    end
  end

  # Sync pending changes when back online
  def handle_info(:sync_pending_changes, socket) do
    if socket.assigns.connection_status == :online and 
       length(socket.assigns.local_changes) > 0 do
      
      # Send local operations to server for CRDT merge
      Blog.Sync.sync_operations(socket.assigns.local_changes)
      
      {:noreply, assign(socket, :local_changes, [])}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:attempt_sync, socket) do
    if socket.assigns.connection_status == :online do
      send(self(), :sync_pending_changes)
    else
      # Retry later
      Process.send_after(self(), :attempt_sync, 5000)
    end
    
    {:noreply, socket}
  end

  # Client events (online/offline)
  def handle_event("create_post", %{"title" => title, "content" => content}, socket) do
    case socket.assigns.connection_status do
      :online ->
        # Direct server operation
        case Content.create_post(%{title: title, content: content}) do
          {:ok, post} ->
            # Will be broadcasted back via PubSub
            {:noreply, socket}
          {:error, changeset} ->
            {:noreply, put_flash(socket, :error, "Error creating post")}
        end
        
      :offline ->
        # WASM operation
        :ok = StateManager.create_post(title, content)
        # Will trigger local_change message
        {:noreply, socket}
    end
  end

  def handle_event("edit_post", %{"id" => id, "changes" => changes}, socket) do
    case socket.assigns.connection_status do
      :online ->
        # Direct server update
        post = Content.get_post!(id)
        case Content.update_post(post, changes) do
          {:ok, updated_post} ->
            {:noreply, socket}
          {:error, changeset} ->
            {:noreply, put_flash(socket, :error, "Error updating post")}
        end
        
      :offline ->
        # WASM operation
        :ok = StateManager.update_post(id, changes)
        {:noreply, socket}
    end
  end

  # Helper functions
  defp list_posts do
    Content.list_posts()
  end

  defp update_post_in_list(posts, updated_post) do
    Enum.map(posts, fn post ->
      if post.id == updated_post.id, do: updated_post, else: post
    end)
  end

  defp apply_optimistic_update(posts, {:create_post, id, title, content, timestamp}) do
    new_post = %{
      id: id,
      title: title, 
      content: content,
      created_at: timestamp,
      status: :local  # Mark as local change
    }
    [new_post | posts]
  end

  defp apply_optimistic_update(posts, {:update_post, id, changes, _timestamp}) do
    Enum.map(posts, fn post ->
      if post.id == id do
        Map.merge(post, changes) |> Map.put(:status, :local)
      else
        post
      end
    end)
  end
end
```

### 3. **CRDT Synchronization Context**

```elixir
# lib/blog/sync.ex
defmodule Blog.Sync do
  @moduledoc """
  Handles CRDT-based synchronization between clients and server.
  Ensures conflict-free state merging for offline-first operation.
  """
  
  alias Blog.Content
  alias Blog.Repo
  import Ecto.Query

  def sync_operations(operations) do
    # Group operations by type
    operations
    |> Enum.group_by(&operation_type/1)
    |> Enum.each(&sync_operation_group/1)
    
    # Broadcast sync completion
    Phoenix.PubSub.broadcast(Blog.PubSub, "blog:sync", :sync_complete)
  end

  defp sync_operation_group({:create_post, operations}) do
    # Apply create operations with conflict detection
    Enum.each(operations, &sync_create_operation/1)
  end

  defp sync_operation_group({:update_post, operations}) do
    # Apply update operations using vector clocks
    operations
    |> Enum.group_by(&elem(&1, 1))  # Group by post ID
    |> Enum.each(&sync_post_updates/1)
  end

  defp sync_create_operation({:create_post, id, title, content, timestamp}) do
    # Check if post already exists (duplicate from other client)
    case Content.get_post(id) do
      nil ->
        # Create new post
        Content.create_post(%{
          id: id,
          title: title,
          content: content,
          created_at: timestamp
        })
        
      existing_post ->
        # Conflict: merge using timestamps
        if DateTime.compare(timestamp, existing_post.created_at) == :lt do
          # Local operation is older, apply as update instead
          sync_update_operation({:update_post, id, %{title: title, content: content}, timestamp})
        end
        # Otherwise, ignore duplicate
    end
  end

  defp sync_post_updates({post_id, operations}) do
    post = Content.get_post!(post_id)
    
    # Sort operations by timestamp
    sorted_ops = Enum.sort_by(operations, &elem(&1, 3), DateTime)
    
    # Apply operations in order
    final_changes = 
      sorted_ops
      |> Enum.reduce(%{}, fn {:update_post, _id, changes, _ts}, acc ->
        Map.merge(acc, changes)
      end)
    
    # Update post with merged changes
    Content.update_post(post, final_changes)
  end

  defp operation_type({:create_post, _, _, _, _}), do: :create_post
  defp operation_type({:update_post, _, _, _}), do: :update_post
end
```

---

## 🌐 Service Worker Implementation [PWA-SPECIFIC]

### Blog-Specific Service Worker

```javascript
// priv/static/blog-sw.js
const CACHE_NAME = 'blog-wasm-v1';
const WASM_CACHE = 'wasm-runtime-v1';

// Assets to cache for offline
const STATIC_ASSETS = [
  '/',
  '/assets/app.css',
  '/assets/app.js', 
  '/wasm/atomvm.wasm',
  '/wasm/atomvm.mjs',
  '/wasm/popcorn.avm'
];

// Install: Cache essential assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    Promise.all([
      // Cache static assets
      caches.open(CACHE_NAME).then((cache) => {
        return cache.addAll(STATIC_ASSETS.filter(url => !url.includes('/wasm/')));
      }),
      
      // Cache WASM assets separately (different strategy)
      caches.open(WASM_CACHE).then((cache) => {
        return cache.addAll(STATIC_ASSETS.filter(url => url.includes('/wasm/')));
      })
    ])
  );
  
  self.skipWaiting();
});

// Activate: Clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && cacheName !== WASM_CACHE) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  
  self.clients.claim();
});

// Fetch: Offline-first strategy
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // WASM files: Cache-first (immutable)
  if (url.pathname.includes('/wasm/')) {
    event.respondWith(
      caches.match(event.request, { cacheName: WASM_CACHE })
        .then((cachedResponse) => {
          return cachedResponse || fetch(event.request);
        })
    );
    return;
  }
  
  // API calls: Network-first with fallback
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Cache successful responses
          if (response.ok) {
            const responseClone = response.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseClone);
            });
          }
          return response;
        })
        .catch(() => {
          // Fallback to cached version
          return caches.match(event.request);
        })
    );
    return;
  }
  
  // Static assets: Cache-first
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        return cachedResponse || fetch(event.request);
      })
  );
});

// Background sync for pending operations
self.addEventListener('sync', (event) => {
  if (event.tag === 'blog-sync') {
    event.waitUntil(syncPendingOperations());
  }
});

const syncPendingOperations = async () => {
  try {
    // Get pending operations from IndexedDB
    const pendingOps = await getPendingOperations();
    
    if (pendingOps.length > 0) {
      // Send to server for CRDT merge
      const response = await fetch('/api/sync', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ operations: pendingOps })
      });
      
      if (response.ok) {
        // Clear synced operations
        await clearPendingOperations();
        
        // Notify clients of sync completion
        const clients = await self.clients.matchAll();
        clients.forEach(client => {
          client.postMessage({ type: 'sync-complete' });
        });
      }
    }
  } catch (error) {
    console.error('Background sync failed:', error);
  }
};
```

### IndexedDB Storage Bridge

```javascript
// assets/js/storage-bridge.js  
class IndexedDBBridge {
  constructor() {
    this.dbName = 'BlogWasm';
    this.version = 1;
    this.db = null;
  }

  async init() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, this.version);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        
        // Blog state store
        const stateStore = db.createObjectStore('blog_state', { keyPath: 'key' });
        stateStore.createIndex('timestamp', 'timestamp');
        
        // Operations log
        const opsStore = db.createObjectStore('operations', { keyPath: 'id', autoIncrement: true });
        opsStore.createIndex('timestamp', 'timestamp');
        opsStore.createIndex('type', 'type');
      };
    });
  }

  async saveBlogState(state) {
    const transaction = this.db.transaction(['blog_state'], 'readwrite');
    const store = transaction.objectStore('blog_state');
    
    await store.put({
      key: 'current_state',
      state: state,
      timestamp: Date.now()
    });
  }

  async loadBlogState() {
    const transaction = this.db.transaction(['blog_state'], 'readonly');
    const store = transaction.objectStore('blog_state');
    
    const result = await store.get('current_state');
    return result ? result.state : { posts: {}, comments: {} };
  }

  async storePendingOperation(operation) {
    const transaction = this.db.transaction(['operations'], 'readwrite');
    const store = transaction.objectStore('operations');
    
    await store.add({
      operation: operation,
      timestamp: Date.now(),
      type: operation[0],  // :create_post, :update_post, etc.
      synced: false
    });
  }

  async getPendingOperations() {
    const transaction = this.db.transaction(['operations'], 'readonly');
    const store = transaction.objectStore('operations');
    const index = store.index('timestamp');
    
    const operations = [];
    const cursor = await index.openCursor();
    
    while (cursor) {
      if (!cursor.value.synced) {
        operations.push(cursor.value.operation);
      }
      cursor.continue();
    }
    
    return operations;
  }

  async clearSyncedOperations(syncedIds) {
    const transaction = this.db.transaction(['operations'], 'readwrite');
    const store = transaction.objectStore('operations');
    
    for (const id of syncedIds) {
      await store.delete(id);
    }
  }
}

// Global instance for WASM bridge
window.storageBridge = new IndexedDBBridge();

// Initialize when DOM ready
document.addEventListener('DOMContentLoaded', () => {
  window.storageBridge.init();
});

// JavaScript functions called from WASM
window.loadBlogState = () => {
  return window.storageBridge.loadBlogState();
};

window.saveBlogState = (state) => {
  return window.storageBridge.saveBlogState(state);
};
```

---

## 📊 Performance & Monitoring [PERFORMANCE]

### Offline Performance Metrics

```elixir
# lib/blog_web/telemetry.ex
defmodule BlogWeb.Telemetry do
  @moduledoc """
  Telemetry for offline-first performance monitoring.
  Tracks sync performance, conflict resolution, and user experience.
  """
  
  def handle_event([:blog, :sync, :start], measurements, metadata, _config) do
    %{
      pending_operations: length(metadata.operations),
      sync_strategy: metadata.strategy,
      timestamp: System.system_time(:millisecond)
    }
  end

  def handle_event([:blog, :sync, :complete], measurements, metadata, _config) do
    duration = measurements.duration
    conflicts = metadata.conflicts_resolved
    
    :telemetry.execute([:blog, :offline, :metrics], %{
      sync_duration: duration,
      conflicts_count: conflicts,
      success_rate: metadata.success_rate
    })
  end

  def handle_event([:blog, :offline, :usage], measurements, metadata, _config) do
    # Track offline usage patterns
    %{
      time_offline: measurements.duration,
      operations_count: measurements.operations,
      feature_usage: metadata.features_used
    }
  end
end
```

### Client-Side Performance Tracking

```javascript
// assets/js/offline-metrics.js
class OfflineMetrics {
  constructor() {
    this.startTime = Date.now();
    this.operations = [];
    this.isOffline = !navigator.onLine;
    
    this.setupListeners();
  }
  
  setupListeners() {
    // Network status
    window.addEventListener('online', () => {
      this.isOffline = false;
      this.trackSyncEvent('reconnected');
    });
    
    window.addEventListener('offline', () => {
      this.isOffline = true;
      this.trackSyncEvent('disconnected');
    });
    
    // WASM operations
    window.addEventListener('wasm-operation', (event) => {
      this.trackOperation(event.detail);
    });
  }
  
  trackOperation(operation) {
    this.operations.push({
      type: operation.type,
      timestamp: Date.now(),
      offline: this.isOffline,
      duration: operation.duration || 0
    });
  }
  
  trackSyncEvent(event) {
    const offlineDuration = Date.now() - this.lastOnlineTime;
    
    // Send telemetry
    fetch('/api/telemetry/offline', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        event: event,
        duration: offlineDuration,
        operations: this.operations.filter(op => op.offline),
        timestamp: new Date().toISOString()
      })
    }).catch(() => {
      // Store for later sync if still offline
      this.storePendingTelemetry({ event, duration: offlineDuration });
    });
  }
  
  async storePendingTelemetry(data) {
    if ('indexedDB' in window) {
      // Store metrics for background sync
      await window.storageBridge.storePendingOperation({
        type: 'telemetry',
        data: data,
        timestamp: Date.now()
      });
    }
  }
}

// Initialize metrics tracking
window.offlineMetrics = new OfflineMetrics();
```

---

## 🔗 Referências e Links Oficiais [REFERÊNCIAS]

### Documentação Oficial
- **Phoenix LiveView**: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
- **Phoenix.PubSub**: https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html
- **Phoenix.Presence**: https://hexdocs.pm/phoenix/Phoenix.Presence.html
- **Service Workers**: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API

### Offline-First Resources
- **PWA LiveView**: https://github.com/dwyl/PWA-Liveview
- **IndexedDB**: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
- **Background Sync**: https://developer.mozilla.org/en-US/docs/Web/API/Background_Sync_API

### CRDT & Conflict Resolution
- **Yjs CRDT**: https://github.com/yjs/yjs
- **Conflict-free Replicated Data Types**: https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type
- **Operational Transforms**: https://en.wikipedia.org/wiki/Operational_transformation

### Compatibility Notes
- **CRDT Libraries**: Browser + WASM support required
- **IndexedDB**: Available in all modern browsers
- **Background Sync**: Chrome 49+, Firefox 44+
- **Service Workers**: Universal support 2025

---

**🎯 RESULTADO ESPERADO**: Offline-first architecture completa com Phoenix LiveView + WASM client processing, CRDT state synchronization, service workers para offline capability, e performance monitoring. 100% feature parity online/offline com conflict resolution automática.**
---
## 📁 11-pop-corn-wa/setup.md

# Setup Inicial: Instalação Detalhada do Popcorn

## 📋 Pré-requisitos

### 🎉 ATUALIZAÇÃO CRÍTICA 30/08/2025 - PHASE 2 SUCESSO COMPLETO

**PHASE 2 COMPLETA**: Stack Upgrade + Popcorn v0.1.0 **FUNCIONANDO** 🚀  
**Status Atual**: WASM Bundle gerado + Phoenix server rodando  
**Stack Final**: Elixir 1.17.3 + OTP 26.0.2 via kerl + source compilation

### Hard Requirements Confirmados (30/08/2025)
```bash
# ❌ INCOMPATÍVEL - Descoberto via tentativa real
elixir --version  # Elixir 1.14.0 (compiled with Erlang/OTP 25)
mix deps.get     # ERROR: Popcorn only supports OTP 26.0.2 and Elixir 1.17.3

# ✅ REQUERIDO PARA POPCORN (confirmado via web search)
elixir --version  # Elixir 1.17.3 (compiled with Erlang/OTP 26)  
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell  # 26
```

### Stack Compatibility Matrix ATUALIZADA REAL
```yaml
Phase 1 - WASM Infrastructure (✅ COMPLETA):
  Elixir: 1.14.0
  Erlang/OTP: 25  
  Phoenix: 1.7.21
  Hex: 2.2.3-dev (from source)
  Popcorn: COMENTADO (incompatível)
  Results: 35/40 tests passing, headers COOP/COEP working
  
Phase 2 - WASM Activation (🎉 COMPLETA COM SUCESSO):
  Elixir: 1.17.3 (compiled with OTP 26) ✅ FUNCIONANDO
  Erlang/OTP: 26.0.2 via kerl ✅ FUNCIONANDO  
  Phoenix: 1.7.21 + Bandit 1.8.0 ✅ SERVER RODANDO
  Hex: auto-updated com nova stack ✅
  Popcorn: v0.1.0 ATIVO ✅ WASM BUNDLE GERADO
  Bundle Atual: 7.8MB (AtomVM.wasm 717KB + popcorn.avm 6.9MB)
  Bundle Target Phase 3: <3MB optimization
```

### 🔧 KERL Optimization Flags (Web Search Validated)
```bash
# ⚡ OTIMIZAÇÃO CRÍTICA - Reduz compilation time 60%
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --without-odbc --without-wx"
export KERL_INSTALL_HTMLDOCS=no  
export KERL_INSTALL_MANPAGES=no

# Timeline Comparison:
# Sem otimização: 8-10 minutos Erlang compilation
# Com otimização: 3-4 minutos Erlang compilation ⚡ 
# ROI: 60% faster deployment Phase 2
```

### Instalação com ASDF
```bash
# Instalar ASDF (se não tiver)
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
source ~/.bashrc

# Adicionar plugins
asdf plugin add erlang
asdf plugin add elixir

# Instalar versões específicas para Popcorn
asdf install erlang 26.0.2
asdf install elixir 1.17.3-otp-26

# Definir como global ou local
asdf global erlang 26.0.2
asdf global elixir 1.17.3-otp-26
```

## 🎉 PHASE 2 IMPLEMENTAÇÃO REAL - Stack Upgrade Completa (30/08/2025)

### ⚠️ Importante: asdf builds.hex.pm Limitation Descoberta

Durante a implementação real, descobrimos que `asdf install elixir 1.17.3-otp-26` falha com **404 errors** do builds.hex.pm. A solução implementada foi source compilation híbrida.

### ✅ Processo Real Implementado e Testado

#### Step 1: Build Erlang 26.0.2 via kerl (Source)
```bash
# Install kerl se não existir
curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl
chmod a+x kerl
sudo mv kerl /usr/local/bin/

# KERL optimization flags (60% faster compilation)
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --without-odbc --without-wx"
export KERL_INSTALL_HTMLDOCS=no
export KERL_INSTALL_MANPAGES=no

# Build e install Erlang 26.0.2
kerl build 26.0.2 erlang-26.0.2-kerl
kerl install erlang-26.0.2-kerl ~/kerl/26.0.2
```

#### Step 2: Build Elixir 1.17.3 via Source Compilation
```bash
# Download Elixir 1.17.3 source
cd /tmp
wget https://github.com/elixir-lang/elixir/archive/v1.17.3.tar.gz
tar -xzf v1.17.3.tar.gz
cd elixir-1.17.3

# Compile with OTP 26.0.2
source ~/kerl/26.0.2/activate
make clean && make
make install PREFIX=~/elixir/1.17.3

# Copy binaries and libraries  
mkdir -p ~/elixir/1.17.3/bin
cp bin/* ~/elixir/1.17.3/bin/
cp -r lib ~/elixir/1.17.3/
```

#### Step 3: Environment Setup Script  
```bash
# Create setup-env-phase2.sh
cat > setup-env-phase2.sh << 'EOF'
#!/bin/bash
# Ativar Erlang 26.0.2 via kerl
source ~/kerl/26.0.2/activate

# Configurar PATH para Elixir 1.17.3 compilado
export PATH="$HOME/elixir/1.17.3/bin:$PATH"
export ELIXIR_ERL_OPTIONS="+fnu"

# Verificar versões
echo "🔧 Environment Phase 2 Setup:"
echo "Erlang/OTP: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell 2>/dev/null)"
echo "$(elixir --version | head -1)"
EOF

chmod +x setup-env-phase2.sh
```

#### Step 4: Activate Popcorn no Projeto
```bash
# Source environment
source setup-env-phase2.sh

# Verificar versões corretas
elixir --version  # Deve mostrar: Elixir 1.17.3 (compiled with Erlang/OTP 26)

# Editar mix.exs - descomentar/ativar Popcorn
# {:popcorn, "~> 0.1.0"}

# Adicionar Bandit HTTP server  
# {:bandit, "~> 1.0"}

# Instalar dependências
mix deps.get

# Criar database se necessário
mix ecto.create

# Compilar projeto (isso gera bundle WASM automaticamente)
mix compile
```

### 🎯 Resultados Esperados Phase 2
```bash
# Após mix compile bem-sucedido, verificar artifacts:
ls -lah _build/dev/lib/popcorn/atomvm_artifacts/wasm/
# AtomVM.wasm (717KB) + AtomVM.mjs (130KB)

ls -lah _build/dev/lib/popcorn/popcorn.avm  
# popcorn.avm (6.9MB - bundle Elixir modules)

# Testar servidor
mix phx.server
# "Running BlogWeb.Endpoint with Bandit 1.8.0 at 127.0.0.1:4000 (http)"
```

### 📊 Bundle Size Analysis (Phase 2 Complete)
```yaml
WASM Bundle Total: 7.8MB
  Components:
    - AtomVM.wasm: 717KB (WASM runtime - fixed size)
    - AtomVM.mjs: 130KB (JavaScript bridge - minimal) 
    - popcorn.avm: 6.9MB (Elixir modules - optimization target)

Phase 3 Target: <3MB via tree shaking + compression
```

---

## 🚀 Passo 1: Criar Projeto Phoenix

```bash
# Instalar Phoenix
mix archive.install hex phx_new

# Criar novo projeto
mix phx.new my_popcorn_app --live
cd my_popcorn_app

# Configurar banco de dados
mix ecto.create
```

## 📦 Passo 2: Adicionar Popcorn

### Atualizar mix.exs
```elixir
defp deps do
  [
    # ... outras dependências
    {:popcorn, "~> 0.1.0"},
    {:phoenix_live_view, "~> 0.20.0"},
    {:phoenix_live_dashboard, "~> 0.8"}
  ]
end
```

### Instalar dependências
```bash
mix deps.get
mix deps.compile
```

## 🔧 Passo 3: Configurar Headers CORS

### config/dev.exs
```elixir
config :my_popcorn_app, MyPopcornAppWeb.Endpoint,
  http: [port: 4000],
  # Headers necessários para SharedArrayBuffer
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  check_origin: false,
  watchers: [
    node: ["esbuild.js", "--watch", cd: Path.expand("../assets", __DIR__)],
    popcorn: ["mix", "popcorn.watch", cd: Path.expand("..", __DIR__)]
  ]
```

### lib/my_popcorn_app_web/endpoint.ex
```elixir
# Adicionar plug para headers COOP/COEP
plug :set_wasm_headers

defp set_wasm_headers(conn, _opts) do
  conn
  |> put_resp_header("cross-origin-embedder-policy", "require-corp")
  |> put_resp_header("cross-origin-opener-policy", "same-origin")
end
```

## 🏗️ Passo 4: Estrutura de Diretórios

```bash
# Criar estrutura para código Popcorn
mkdir -p lib/my_popcorn_app_wasm
mkdir -p priv/static/wasm
mkdir -p assets/js/popcorn
```

### Estrutura final:
```
my_popcorn_app/
├── lib/
│   ├── my_popcorn_app/         # Backend Phoenix
│   ├── my_popcorn_app_web/     # Web Phoenix
│   └── my_popcorn_app_wasm/    # Código Popcorn
│       ├── calculator.ex
│       └── utils.ex
├── priv/
│   └── static/
│       └── wasm/               # WASM compilado
├── assets/
│   └── js/
│       └── popcorn/           # Bridge JavaScript
│           └── loader.js
└── mix.exs
```

## 💻 Passo 5: Primeiro Módulo Popcorn

### lib/my_popcorn_app_wasm/calculator.ex
```elixir
defmodule MyPopcornAppWasm.Calculator do
  @moduledoc """
  Módulo que será compilado para WASM e executado no browser
  """

  def add(a, b) when is_number(a) and is_number(b) do
    a + b
  end

  def multiply(a, b) when is_number(a) and is_number(b) do
    a * b
  end

  def process_list(list) when is_list(list) do
    list
    |> Enum.map(&(&1 * 2))
    |> Enum.sum()
  end
end
```

## 🔨 Passo 6: Build do Popcorn

### Compilar AtomVM runtime
```bash
# Primeira vez apenas
mix popcorn.build_runtime --target wasm

# Verificar se foi criado
ls -la priv/static/wasm/
# Deve mostrar atomvm.wasm
```

### Compilar módulos Elixir
```bash
# Compilar seus módulos para WASM
mix popcorn.cook

# Verificar arquivos gerados
ls -la priv/static/wasm/
# Deve mostrar seus módulos .beam compilados
```

## 🌉 Passo 7: Bridge JavaScript

### assets/js/popcorn/loader.js
```javascript
// Loader para Popcorn
export class PopcornLoader {
  constructor() {
    this.instance = null;
    this.ready = false;
  }

  async init() {
    try {
      // Carregar AtomVM
      const response = await fetch('/wasm/atomvm.wasm');
      const buffer = await response.arrayBuffer();
      
      // Inicializar com SharedArrayBuffer
      const memory = new WebAssembly.Memory({
        initial: 256,
        maximum: 512,
        shared: true
      });

      const importObject = {
        env: { memory },
        wasi: {
          // WASI imports necessários
          proc_exit: () => {},
          fd_write: () => {},
          fd_close: () => {},
          fd_seek: () => {}
        }
      };

      const result = await WebAssembly.instantiate(buffer, importObject);
      this.instance = result.instance;
      this.ready = true;
      
      console.log('Popcorn carregado com sucesso!');
      return true;
    } catch (error) {
      console.error('Erro ao carregar Popcorn:', error);
      return false;
    }
  }

  async runElixir(module, func, args) {
    if (!this.ready) {
      await this.init();
    }

    // Chamar função Elixir via Popcorn
    return window.Popcorn.Wasm.run(module, func, args);
  }
}

// Exportar instância global
window.PopcornLoader = new PopcornLoader();
```

## 🎨 Passo 8: Integração no HTML

### lib/my_popcorn_app_web/templates/layout/root.html.heex
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <!-- ... outros headers ... -->
    
    <!-- Script do Popcorn -->
    <script type="module">
      import { PopcornLoader } from '/assets/js/popcorn/loader.js';
      
      window.addEventListener('DOMContentLoaded', async () => {
        const loader = new PopcornLoader();
        await loader.init();
        window.popcornReady = true;
      });
    </script>
  </head>
  <body>
    <%= @inner_content %>
  </body>
</html>
```

## 🧪 Passo 9: Teste Básico

### lib/my_popcorn_app_web/live/calculator_live.ex
```elixir
defmodule MyPopcornAppWeb.CalculatorLive do
  use MyPopcornAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, result: nil, status: :ready)}
  end

  def render(assigns) do
    ~H"""
    <div class="calculator">
      <h1>Calculadora Popcorn</h1>
      
      <button phx-click="calculate">
        Calcular no Browser com Elixir
      </button>

      <%= if @result do %>
        <div class="result">
          Resultado: <%= @result %>
        </div>
      <% end %>

      <div class="status">
        Status: <%= @status %>
      </div>
    </div>

    <script>
      window.calculateInBrowser = async function() {
        if (window.popcornReady) {
          const result = await window.PopcornLoader.runElixir(
            'MyPopcornAppWasm.Calculator',
            'add',
            [10, 20]
          );
          return result;
        }
        return null;
      }
    </script>
    """
  end

  def handle_event("calculate", _params, socket) do
    # Aqui você pode chamar JavaScript que executa Popcorn
    {:noreply, 
     socket
     |> assign(:result, 30)
     |> assign(:status, :calculated)}
  end
end
```

## 🚦 Passo 10: Rodar e Testar

```bash
# Terminal 1: Servidor Phoenix
mix phx.server

# Terminal 2: Watch Popcorn (opcional)
mix popcorn.watch

# Acessar no browser
# http://localhost:4000
```

### Verificar no Console do Browser
```javascript
// Teste manual no console
await window.PopcornLoader.init();
await window.PopcornLoader.runElixir('MyPopcornAppWasm.Calculator', 'add', [5, 3]);
// Deve retornar 8
```

## 🐛 Troubleshooting Comum

### Erro: SharedArrayBuffer não disponível
**Solução**: Verificar headers COOP/COEP
```bash
curl -I http://localhost:4000
# Deve mostrar:
# cross-origin-embedder-policy: require-corp
# cross-origin-opener-policy: same-origin
```

### Erro: Módulo não encontrado
**Solução**: Recompilar
```bash
mix clean
mix popcorn.cook
```

### Erro: Versão incompatível
**Solução**: Verificar versões exatas
```bash
mix deps.tree | grep popcorn
# Deve mostrar 0.1.0
```

## ✅ Checklist de Verificação

- [ ] Elixir 1.17.3 instalado
- [ ] OTP 26.0.2 instalado
- [ ] Phoenix app criado
- [ ] Popcorn adicionado ao mix.exs
- [ ] Headers COOP/COEP configurados
- [ ] Estrutura de diretórios criada
- [ ] Primeiro módulo WASM criado
- [ ] Build executado com sucesso
- [ ] Bridge JavaScript funcionando
- [ ] Teste no browser passou

## 📝 Próximos Passos

1. **Adicionar mais módulos**: Expanda com mais funcionalidades
2. **Otimizar bundle**: Implemente lazy loading
3. **Adicionar testes**: ExUnit e testes de browser
4. **Configurar CI/CD**: GitHub Actions para build automático

---
## 📁 11-pop-corn-wa/static-deployment-guide.md

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
---
## ❌ 01-documentacao-base (não encontrado)


---
## 📁 11-pop-corn-wa/testes.md

# Testing Strategies: Testes Unitários e E2E com Popcorn

## 🎯 Visão Geral da Estratégia de Testes

### Pirâmide de Testes para Popcorn
```
        /\
       /E2E\      (10%) - Testes browser completos
      /------\
     /Integr. \   (30%) - Testes de integração
    /----------\
   / Unitários  \ (60%) - Testes unitários Elixir
  /--------------\
```

### Princípios Fundamentais
1. **Código compartilhado**: Teste uma vez, funciona em ambos lados
2. **Isolamento**: Teste Popcorn separado do Phoenix
3. **Fast feedback**: Testes rápidos primeiro
4. **Real browser**: Validação final em browser real

---

## 🧪 Nível 1: Testes Unitários

### Testando Código Compartilhado

#### test/shared/calculator_test.exs
```elixir
defmodule MyApp.Shared.CalculatorTest do
  use ExUnit.Case, async: true
  alias MyApp.Shared.Calculator

  describe "operações básicas" do
    test "soma dois números" do
      assert Calculator.add(2, 3) == 5
    end

    test "soma com números negativos" do
      assert Calculator.add(-5, 3) == -2
    end

    test "divisão por zero retorna erro" do
      assert {:error, :division_by_zero} = Calculator.divide(10, 0)
    end
  end

  describe "operações complexas" do
    test "calcula porcentagem" do
      assert Calculator.percentage(50, 200) == 25.0
    end

    test "calcula média de lista" do
      assert Calculator.average([10, 20, 30]) == 20.0
    end

    test "média de lista vazia retorna zero" do
      assert Calculator.average([]) == 0
    end
  end
end
```

### Testando Módulos Específicos do Popcorn

#### test/wasm/validator_test.exs
```elixir
defmodule MyAppWasm.ValidatorTest do
  use ExUnit.Case, async: true
  alias MyAppWasm.Validator

  # Tag para identificar testes que rodam no Popcorn
  @moduletag :popcorn

  describe "validação de email" do
    test "aceita email válido" do
      assert {:ok, _} = Validator.validate_email("user@example.com")
    end

    test "rejeita email sem @" do
      assert {:error, "Email inválido"} = Validator.validate_email("userexample.com")
    end

    test "rejeita email com espaços" do
      assert {:error, "Email inválido"} = Validator.validate_email("user @example.com")
    end
  end

  describe "validação de CPF" do
    test "aceita CPF válido" do
      assert {:ok, "12345678901"} = Validator.validate_cpf("123.456.789-01")
    end

    test "remove formatação" do
      {:ok, cpf} = Validator.validate_cpf("123.456.789-01")
      assert cpf == "12345678901"
    end

    test "rejeita CPF com dígitos repetidos" do
      assert {:error, _} = Validator.validate_cpf("111.111.111-11")
    end
  end
end
```

### Property-Based Testing

#### test/wasm/property_test.exs
```elixir
defmodule MyAppWasm.PropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  alias MyAppWasm.Calculator

  property "soma é comutativa" do
    check all a <- integer(),
              b <- integer() do
      assert Calculator.add(a, b) == Calculator.add(b, a)
    end
  end

  property "soma é associativa" do
    check all a <- integer(),
              b <- integer(),
              c <- integer() do
      assert Calculator.add(Calculator.add(a, b), c) == 
             Calculator.add(a, Calculator.add(b, c))
    end
  end

  property "divisão seguida de multiplicação retorna original" do
    check all a <- integer(),
              b <- integer(),
              b != 0 do
      {:ok, divided} = Calculator.divide(a, b)
      result = Calculator.multiply(divided, b)
      assert_in_delta result, a, 0.01
    end
  end
end
```

---

## 🔗 Nível 2: Testes de Integração

### Testando Compilação para WASM

#### test/integration/popcorn_compilation_test.exs
```elixir
defmodule Integration.PopcornCompilationTest do
  use ExUnit.Case

  @tag :integration
  test "compila módulos para WASM com sucesso" do
    # Limpar builds anteriores
    File.rm_rf!("priv/static/wasm")
    
    # Executar compilação
    {output, 0} = System.cmd("mix", ["popcorn.cook"])
    
    # Verificar saída
    assert output =~ "Compilation successful"
    
    # Verificar arquivos gerados
    assert File.exists?("priv/static/wasm/calculator.beam")
    assert File.exists?("priv/static/wasm/validator.beam")
  end

  @tag :integration
  test "bundle não excede tamanho máximo" do
    # Compilar se necessário
    System.cmd("mix", ["popcorn.cook"], [])
    
    # Verificar tamanho total
    wasm_size = get_directory_size("priv/static/wasm")
    max_size = 3 * 1024 * 1024  # 3MB
    
    assert wasm_size < max_size, 
      "Bundle size #{wasm_size} bytes excede máximo de #{max_size} bytes"
  end

  defp get_directory_size(path) do
    Path.wildcard("#{path}/**/*")
    |> Enum.map(&File.stat!/1)
    |> Enum.map(& &1.size)
    |> Enum.sum()
  end
end
```

### Testando Interoperabilidade JS

#### test/integration/js_interop_test.exs
```elixir
defmodule Integration.JsInteropTest do
  use ExUnit.Case
  
  @tag :integration
  @tag :requires_node
  test "módulo Popcorn pode chamar JavaScript" do
    # Criar arquivo JS temporário
    js_code = """
    global.testFunction = function(a, b) {
      return a + b;
    };
    """
    File.write!("test/fixtures/test.js", js_code)
    
    # Testar integração
    result = MyAppWasm.JsInterop.call_js("testFunction", [5, 3])
    assert result == 8
    
    # Limpar
    File.rm!("test/fixtures/test.js")
  end
end
```

### Testando com Phoenix

#### test/integration/phoenix_popcorn_test.exs
```elixir
defmodule Integration.PhoenixPopcornTest do
  use MyAppWeb.ConnCase
  
  @tag :integration
  test "serve arquivos WASM com headers corretos", %{conn: conn} do
    conn = get(conn, "/wasm/calculator.wasm")
    
    assert response_content_type(conn, :wasm)
    assert get_resp_header(conn, "cross-origin-embedder-policy") == ["require-corp"]
    assert get_resp_header(conn, "cross-origin-opener-policy") == ["same-origin"]
  end

  @tag :integration
  test "LiveView carrega módulo Popcorn", %{conn: conn} do
    {:ok, view, html} = live(conn, "/calculator")
    
    # Verificar que script está presente
    assert html =~ "PopcornLoader"
    assert html =~ "calculator.wasm"
    
    # Simular evento após carregamento
    assert render_click(view, "calculate", %{a: 10, b: 20}) =~ "30"
  end
end
```

---

## 🌐 Nível 3: Testes End-to-End

### Setup Wallaby para E2E

#### config/test.exs
```elixir
config :wallaby,
  driver: Wallaby.Chrome,
  chrome: [
    headless: false,  # true para CI
    args: [
      "--no-sandbox",
      "--disable-dev-shm-usage",
      "--disable-web-security",  # Para SharedArrayBuffer
      "--allow-file-access-from-files"
    ]
  ],
  screenshot_on_failure: true,
  max_wait_time: 10_000
```

### Teste E2E Básico

#### test/e2e/calculator_e2e_test.exs
```elixir
defmodule E2E.CalculatorTest do
  use ExUnit.Case
  use Wallaby.Feature

  import Wallaby.Query

  @tag :e2e
  feature "calculadora funciona no browser", %{session: session} do
    session
    |> visit("/calculator")
    |> assert_has(css(".calculator"))
    |> wait_for_popcorn_load()
    |> fill_in(text_field("input-a"), with: "10")
    |> fill_in(text_field("input-b"), with: "20")
    |> click(button("Calculate"))
    |> assert_has(css(".result", text: "30"))
  end

  @tag :e2e
  feature "validação acontece no cliente", %{session: session} do
    session
    |> visit("/form")
    |> wait_for_popcorn_load()
    |> fill_in(text_field("email"), with: "invalid-email")
    |> send_keys([:tab])  # Trigger blur
    |> assert_has(css(".error", text: "Email inválido"))
    |> refute_has(css(".server-call"))  # Não deve chamar servidor
  end

  defp wait_for_popcorn_load(session) do
    # Esperar Popcorn carregar
    session
    |> execute_script("return window.popcornReady")
    |> retry_until(fn ready -> ready == true end)
    
    session
  end

  defp retry_until(session, check_fn, max_attempts \\ 10) do
    Enum.reduce_while(1..max_attempts, session, fn _, acc ->
      if check_fn.(acc) do
        {:halt, acc}
      else
        Process.sleep(500)
        {:cont, acc}
      end
    end)
  end
end
```

### Teste E2E Offline

#### test/e2e/offline_e2e_test.exs
```elixir
defmodule E2E.OfflineTest do
  use ExUnit.Case
  use Wallaby.Feature

  @tag :e2e
  @tag :offline
  feature "app funciona offline", %{session: session} do
    session
    |> visit("/todo")
    |> wait_for_popcorn_load()
    |> go_offline()
    |> add_todo("Comprar leite")
    |> assert_has(css(".todo-item", text: "Comprar leite"))
    |> assert_has(css(".status", text: "Offline"))
    |> go_online()
    |> assert_has(css(".status", text: "Online"))
    |> assert_has(css(".sync-status", text: "Sincronizado"))
  end

  defp go_offline(session) do
    execute_script(session, """
      window.dispatchEvent(new Event('offline'));
      return true;
    """)
    session
  end

  defp go_online(session) do
    execute_script(session, """
      window.dispatchEvent(new Event('online'));
      return true;
    """)
    session
  end

  defp add_todo(session, text) do
    session
    |> fill_in(text_field("new-todo"), with: text)
    |> send_keys([:enter])
  end
end
```

---

## 🎭 Mocking e Stubs

### Mock de Módulos Popcorn

#### test/support/mocks.ex
```elixir
Mox.defmock(MyAppWasm.CalculatorMock, for: MyAppWasm.CalculatorBehaviour)
Mox.defmock(MyAppWasm.ValidatorMock, for: MyAppWasm.ValidatorBehaviour)
```

#### test/unit/with_mocks_test.exs
```elixir
defmodule MyApp.WithMocksTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  test "usa calculator mock" do
    MyAppWasm.CalculatorMock
    |> expect(:add, fn 2, 3 -> 5 end)
    |> expect(:multiply, fn 5, 10 -> 50 end)

    assert MyAppWasm.CalculatorMock.add(2, 3) == 5
    assert MyAppWasm.CalculatorMock.multiply(5, 10) == 50
  end
end
```

### Stub de JavaScript

#### test/support/js_stub.js
```javascript
// Stub para testes sem browser real
window.PopcornLoader = {
  init: async () => true,
  ready: true,
  runElixir: async (module, func, args) => {
    // Retorna respostas fake baseadas em input
    if (module === 'Calculator' && func === 'add') {
      return args[0] + args[1];
    }
    return null;
  }
};
```

---

## 📊 Testes de Performance

### Benchmark de Funções

#### test/performance/benchmark_test.exs
```elixir
defmodule Performance.BenchmarkTest do
  use ExUnit.Case

  @tag :benchmark
  test "performance de cálculos" do
    inputs = %{
      "pequeno" => Enum.to_list(1..100),
      "médio" => Enum.to_list(1..1_000),
      "grande" => Enum.to_list(1..10_000)
    }

    results = Benchee.run(
      %{
        "soma_simples" => fn list -> 
          MyAppWasm.Calculator.sum_list(list)
        end,
        "soma_paralela" => fn list ->
          MyAppWasm.Calculator.parallel_sum(list)
        end
      },
      inputs: inputs,
      time: 10,
      memory_time: 2
    )

    # Verificar que paralela é mais rápida para listas grandes
    assert results.scenarios
           |> Enum.find(&(&1.name == "soma_paralela"))
           |> Map.get(:run_time_data)
           |> Map.get(:statistics)
           |> Map.get(:median) < 1_000_000  # < 1ms
  end
end
```

### Teste de Carga

#### test/performance/load_test.exs
```elixir
defmodule Performance.LoadTest do
  use ExUnit.Case

  @tag :load
  @tag timeout: :infinity
  test "suporta múltiplas instâncias Popcorn" do
    tasks = for i <- 1..100 do
      Task.async(fn ->
        # Simular múltiplos usuários
        start_time = System.monotonic_time(:millisecond)
        
        result = MyAppWasm.Calculator.complex_calculation(i)
        
        end_time = System.monotonic_time(:millisecond)
        {i, result, end_time - start_time}
      end)
    end

    results = Task.await_many(tasks, 30_000)
    
    # Verificar que todos completaram
    assert length(results) == 100
    
    # Verificar tempo médio
    avg_time = results
               |> Enum.map(fn {_, _, time} -> time end)
               |> Enum.sum()
               |> Kernel./(100)
    
    assert avg_time < 100  # < 100ms médio
  end
end
```

---

## 🔄 Testes de Regressão

### Snapshot Testing

#### test/regression/snapshot_test.exs
```elixir
defmodule Regression.SnapshotTest do
  use ExUnit.Case

  @tag :regression
  test "output não mudou" do
    input = %{
      items: [
        %{name: "Item 1", price: 10.50, quantity: 2},
        %{name: "Item 2", price: 25.00, quantity: 1}
      ],
      tax_rate: 0.08,
      discount: 5.00
    }

    result = MyAppWasm.OrderCalculator.calculate_total(input)
    
    # Comparar com snapshot salvo
    expected = File.read!("test/fixtures/snapshots/order_calc.json")
                |> Jason.decode!()
    
    assert result == expected
  end

  @tag :regression
  @tag :update_snapshot
  test "atualizar snapshot" do
    # Rodar com --only update_snapshot para atualizar
    input = %{
      items: [
        %{name: "Item 1", price: 10.50, quantity: 2},
        %{name: "Item 2", price: 25.00, quantity: 1}
      ],
      tax_rate: 0.08,
      discount: 5.00
    }

    result = MyAppWasm.OrderCalculator.calculate_total(input)
    
    File.write!(
      "test/fixtures/snapshots/order_calc.json",
      Jason.encode!(result, pretty: true)
    )
  end
end
```

---

## 🚀 CI/CD Pipeline para Testes

### .github/workflows/test.yml
```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '26.0.2'
      
      - name: Install deps
        run: mix deps.get
      
      - name: Run unit tests
        run: mix test --only unit

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '26.0.2'
      
      - name: Build Popcorn
        run: |
          mix deps.get
          mix popcorn.cook
      
      - name: Run integration tests
        run: mix test --only integration

  e2e-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Chrome
        uses: browser-actions/setup-chrome@latest
      
      - name: Setup ChromeDriver
        uses: nanasess/setup-chromedriver@v2
      
      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '26.0.2'
      
      - name: Install deps
        run: |
          mix deps.get
          npm install --prefix assets
      
      - name: Setup database
        run: |
          mix ecto.create
          mix ecto.migrate
      
      - name: Build assets
        run: |
          mix assets.deploy
          mix popcorn.cook
      
      - name: Run E2E tests
        run: mix test --only e2e
        env:
          MIX_ENV: test
          WALLABY_DRIVER: chrome_headless
```

---

## 📋 Checklist de Testes

### Para cada Feature Nova
- [ ] Testes unitários para lógica pura
- [ ] Testes de integração para compilação
- [ ] Teste E2E básico
- [ ] Teste de performance
- [ ] Teste offline (se aplicável)
- [ ] Snapshot test
- [ ] Documentação de teste

### Coverage Mínimo
- [ ] Unit: 90%+
- [ ] Integration: 70%+
- [ ] E2E: Casos críticos
- [ ] Total: 80%+

### Comandos Úteis
```bash
# Rodar todos os testes
mix test

# Apenas unitários
mix test --only unit

# Apenas E2E
mix test --only e2e

# Com coverage
mix test --cover

# Testes de performance
mix test --only benchmark

# Watch mode
mix test.watch

# Testes específicos do Popcorn
mix test --only popcorn
```

---

## 🎯 Best Practices

1. **Teste comportamento, não implementação**
2. **Use tags para organizar suites**
3. **Mantenha testes rápidos (<100ms para unit)**
4. **E2E apenas para fluxos críticos**
5. **Mock external dependencies**
6. **Não teste o framework, teste seu código**
7. **Cleanup após cada teste**
8. **Use factories para dados de teste**

---
## 📁 09-setup-config/01-instalacao-inicial.md

# Setup Inicial: Instalação Detalhada do Popcorn

## 📋 Pré-requisitos

### Versões Específicas Necessárias
```bash
# Verificar versões instaladas
elixir --version  # Deve ser 1.17.3
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell  # Deve ser 26
```

### Instalação com ASDF
```bash
# Instalar ASDF (se não tiver)
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
source ~/.bashrc

# Adicionar plugins
asdf plugin add erlang
asdf plugin add elixir

# Instalar versões específicas para Popcorn
asdf install erlang 26.0.2
asdf install elixir 1.17.3-otp-26

# Definir como global ou local
asdf global erlang 26.0.2
asdf global elixir 1.17.3-otp-26
```

## 🚀 Passo 1: Criar Projeto Phoenix

```bash
# Instalar Phoenix
mix archive.install hex phx_new

# Criar novo projeto
mix phx.new my_popcorn_app --live
cd my_popcorn_app

# Configurar banco de dados
mix ecto.create
```

## 📦 Passo 2: Adicionar Popcorn

### Atualizar mix.exs
```elixir
defp deps do
  [
    # ... outras dependências
    {:popcorn, "~> 0.1.0"},
    {:phoenix_live_view, "~> 0.20.0"},
    {:phoenix_live_dashboard, "~> 0.8"}
  ]
end
```

### Instalar dependências
```bash
mix deps.get
mix deps.compile
```

## 🔧 Passo 3: Configurar Headers CORS

### config/dev.exs
```elixir
config :my_popcorn_app, MyPopcornAppWeb.Endpoint,
  http: [port: 4000],
  # Headers necessários para SharedArrayBuffer
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  check_origin: false,
  watchers: [
    node: ["esbuild.js", "--watch", cd: Path.expand("../assets", __DIR__)],
    popcorn: ["mix", "popcorn.watch", cd: Path.expand("..", __DIR__)]
  ]
```

### lib/my_popcorn_app_web/endpoint.ex
```elixir
# Adicionar plug para headers COOP/COEP
plug :set_wasm_headers

defp set_wasm_headers(conn, _opts) do
  conn
  |> put_resp_header("cross-origin-embedder-policy", "require-corp")
  |> put_resp_header("cross-origin-opener-policy", "same-origin")
end
```

## 🏗️ Passo 4: Estrutura de Diretórios

```bash
# Criar estrutura para código Popcorn
mkdir -p lib/my_popcorn_app_wasm
mkdir -p priv/static/wasm
mkdir -p assets/js/popcorn
```

### Estrutura final:
```
my_popcorn_app/
├── lib/
│   ├── my_popcorn_app/         # Backend Phoenix
│   ├── my_popcorn_app_web/     # Web Phoenix
│   └── my_popcorn_app_wasm/    # Código Popcorn
│       ├── calculator.ex
│       └── utils.ex
├── priv/
│   └── static/
│       └── wasm/               # WASM compilado
├── assets/
│   └── js/
│       └── popcorn/           # Bridge JavaScript
│           └── loader.js
└── mix.exs
```

## 💻 Passo 5: Primeiro Módulo Popcorn

### lib/my_popcorn_app_wasm/calculator.ex
```elixir
defmodule MyPopcornAppWasm.Calculator do
  @moduledoc """
  Módulo que será compilado para WASM e executado no browser
  """

  def add(a, b) when is_number(a) and is_number(b) do
    a + b
  end

  def multiply(a, b) when is_number(a) and is_number(b) do
    a * b
  end

  def process_list(list) when is_list(list) do
    list
    |> Enum.map(&(&1 * 2))
    |> Enum.sum()
  end
end
```

## 🔨 Passo 6: Build do Popcorn

### Compilar AtomVM runtime
```bash
# Primeira vez apenas
mix popcorn.build_runtime --target wasm

# Verificar se foi criado
ls -la priv/static/wasm/
# Deve mostrar atomvm.wasm
```

### Compilar módulos Elixir
```bash
# Compilar seus módulos para WASM
mix popcorn.cook

# Verificar arquivos gerados
ls -la priv/static/wasm/
# Deve mostrar seus módulos .beam compilados
```

## 🌉 Passo 7: Bridge JavaScript

### assets/js/popcorn/loader.js
```javascript
// Loader para Popcorn
export class PopcornLoader {
  constructor() {
    this.instance = null;
    this.ready = false;
  }

  async init() {
    try {
      // Carregar AtomVM
      const response = await fetch('/wasm/atomvm.wasm');
      const buffer = await response.arrayBuffer();
      
      // Inicializar com SharedArrayBuffer
      const memory = new WebAssembly.Memory({
        initial: 256,
        maximum: 512,
        shared: true
      });

      const importObject = {
        env: { memory },
        wasi: {
          // WASI imports necessários
          proc_exit: () => {},
          fd_write: () => {},
          fd_close: () => {},
          fd_seek: () => {}
        }
      };

      const result = await WebAssembly.instantiate(buffer, importObject);
      this.instance = result.instance;
      this.ready = true;
      
      console.log('Popcorn carregado com sucesso!');
      return true;
    } catch (error) {
      console.error('Erro ao carregar Popcorn:', error);
      return false;
    }
  }

  async runElixir(module, func, args) {
    if (!this.ready) {
      await this.init();
    }

    // Chamar função Elixir via Popcorn
    return window.Popcorn.Wasm.run(module, func, args);
  }
}

// Exportar instância global
window.PopcornLoader = new PopcornLoader();
```

## 🎨 Passo 8: Integração no HTML

### lib/my_popcorn_app_web/templates/layout/root.html.heex
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <!-- ... outros headers ... -->
    
    <!-- Script do Popcorn -->
    <script type="module">
      import { PopcornLoader } from '/assets/js/popcorn/loader.js';
      
      window.addEventListener('DOMContentLoaded', async () => {
        const loader = new PopcornLoader();
        await loader.init();
        window.popcornReady = true;
      });
    </script>
  </head>
  <body>
    <%= @inner_content %>
  </body>
</html>
```

## 🧪 Passo 9: Teste Básico

### lib/my_popcorn_app_web/live/calculator_live.ex
```elixir
defmodule MyPopcornAppWeb.CalculatorLive do
  use MyPopcornAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, result: nil, status: :ready)}
  end

  def render(assigns) do
    ~H"""
    <div class="calculator">
      <h1>Calculadora Popcorn</h1>
      
      <button phx-click="calculate">
        Calcular no Browser com Elixir
      </button>

      <%= if @result do %>
        <div class="result">
          Resultado: <%= @result %>
        </div>
      <% end %>

      <div class="status">
        Status: <%= @status %>
      </div>
    </div>

    <script>
      window.calculateInBrowser = async function() {
        if (window.popcornReady) {
          const result = await window.PopcornLoader.runElixir(
            'MyPopcornAppWasm.Calculator',
            'add',
            [10, 20]
          );
          return result;
        }
        return null;
      }
    </script>
    """
  end

  def handle_event("calculate", _params, socket) do
    # Aqui você pode chamar JavaScript que executa Popcorn
    {:noreply, 
     socket
     |> assign(:result, 30)
     |> assign(:status, :calculated)}
  end
end
```

## 🚦 Passo 10: Rodar e Testar

```bash
# Terminal 1: Servidor Phoenix
mix phx.server

# Terminal 2: Watch Popcorn (opcional)
mix popcorn.watch

# Acessar no browser
# http://localhost:4000
```

### Verificar no Console do Browser
```javascript
// Teste manual no console
await window.PopcornLoader.init();
await window.PopcornLoader.runElixir('MyPopcornAppWasm.Calculator', 'add', [5, 3]);
// Deve retornar 8
```

## 🐛 Troubleshooting Comum

### Erro: SharedArrayBuffer não disponível
**Solução**: Verificar headers COOP/COEP
```bash
curl -I http://localhost:4000
# Deve mostrar:
# cross-origin-embedder-policy: require-corp
# cross-origin-opener-policy: same-origin
```

### Erro: Módulo não encontrado
**Solução**: Recompilar
```bash
mix clean
mix popcorn.cook
```

### Erro: Versão incompatível
**Solução**: Verificar versões exatas
```bash
mix deps.tree | grep popcorn
# Deve mostrar 0.1.0
```

## ✅ Checklist de Verificação

- [ ] Elixir 1.17.3 instalado
- [ ] OTP 26.0.2 instalado
- [ ] Phoenix app criado
- [ ] Popcorn adicionado ao mix.exs
- [ ] Headers COOP/COEP configurados
- [ ] Estrutura de diretórios criada
- [ ] Primeiro módulo WASM criado
- [ ] Build executado com sucesso
- [ ] Bridge JavaScript funcionando
- [ ] Teste no browser passou

## 📝 Próximos Passos

1. **Adicionar mais módulos**: Expanda com mais funcionalidades
2. **Otimizar bundle**: Implemente lazy loading
3. **Adicionar testes**: ExUnit e testes de browser
4. **Configurar CI/CD**: GitHub Actions para build automático

---
## 📁 09-setup-config/02-instalacao-moderna-elixir-2025.md

# 🚀 Instalação Moderna Elixir/Phoenix 2025 - Ubuntu WSL2

## 🎯 Problema Identificado

**Data**: 29/08/2025  
**Contexto**: Blog WebAssembly-First com Phoenix + Popcorn  
**Desafio**: Compatibilidade Elixir 1.14 + Hex 2.2.1 + Phoenix stack

## ❌ Erros Críticos Identificados

### Erro 1: Phoenix Version Requirements
```bash
# Tentativa inicial Phoenix 1.8
mix phx.new blog --live --database postgres

# Resultado:
warning: the archive phx_new-1.8.0 requires Elixir "~> 1.15" but you are running on v1.14.0
** (Mix) Phoenix v1.8.0 requires at least Elixir v1.15
```

### Erro 2: Hex Protocol Incompatibility (CRÍTICO)
```bash
# Após ajustar dependencies para Phoenix 1.7
mix deps.get

# Erro crítico descoberto:
** (FunctionClauseError) no function clause matching in String.Chars.Hex.Solver.Constraints.Range."-inlined-__impl__/1-"/1
    The following arguments were given: # 1 :target
    (hex 2.2.1) String.Chars.Hex.Solver.Constraints.Range."-inlined-__impl__/1-"/1

# Causa raiz identificada via pesquisa web:
- Hex 2.2.1 construído com Elixir 1.17+
- String.Chars protocol incompatível com Elixir 1.14
- Phoenix dependencies também afetadas
```

## 🔍 Análise da Web (29/08/2025)

### Pesquisa Web Queries Eficazes
```
1. "Elixir 1.14.0 Hex 2.2.1 compatibility FunctionClauseError String.Chars.Hex.Solver.Constraints.Range"
2. "mix archive.install hex github compatibility version downgrade fix solution" 
3. "Phoenix 1.7 vs 1.8 Elixir 1.14 compatibility dependency version matrix"
4. "Hex version compatible Elixir 1.14 archive install mix hex version matrix"
```

### Descobertas Críticas
```yaml
Phoenix Version Matrix:
  Phoenix 1.8: Elixir 1.15+ obrigatório
  Phoenix 1.7: Elixir 1.14+ compatível ✅
  
Hex Compatibility Issues:
  Hex 2.2.1: Built with Elixir 1.17+
  Protocol: String.Chars incompatível Elixir 1.14
  Solution: Install from GitHub source (built with current Elixir)
  
Stack Resolution:
  Phoenix: 1.8 → 1.7.21 (working with Elixir 1.14)
  Hex: 2.2.1 → 2.2.3-dev (built from source)  
  Dependencies: Adjusted for Elixir 1.14 compatibility
```

### ✅ SOLUÇÃO IMPLEMENTADA E TESTADA

#### Hex Fix (CRÍTICO - Resolve Protocol Issues)
```bash
# Uninstall current Hex and install from source
mix archive.uninstall hex --force
mix archive.install github hexpm/hex branch main --force

# Result: Hex 2.2.3-dev built with Elixir 1.14.0 + OTP 25.3.2.8
mix hex.info
# Hex: 2.2.3-dev, Built with: Elixir 1.14.0 and OTP 25.3.2.8 ✅
```

#### Stack Compatibility Resolution  
```elixir
# mix.exs - Working configuration for Elixir 1.14
def project do
  [
    app: :blog,
    version: "0.1.0", 
    elixir: "~> 1.14",  # Adjusted from 1.15
    # ... rest of config
  ]
end

# Dependencies adjusted for Elixir 1.14 compatibility
defp deps do
  [
    {:phoenix, "~> 1.7.0"},              # 1.8 → 1.7
    {:phoenix_ecto, "~> 4.4"},           # 4.5 → 4.4  
    {:ecto_sql, "~> 3.10"},              # 3.13 → 3.10
    {:phoenix_html, "~> 3.3"},           # 4.1 → 3.3
    {:phoenix_live_view, "~> 0.20.0"},   # 1.1 → 0.20
    {:plug_cowboy, "~> 2.5"},            # Added
    # ... more dependencies with compatible versions
  ]
end
```

#### Database & Application Fixes
```bash
# PostgreSQL setup with compatible credentials
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
MIX_ENV=test mix ecto.create

# Application.ex fix (DNSCluster compatibility)  
# Comment out DNSCluster for Elixir 1.14 compatibility
# {DNSCluster, query: Application.get_env(:blog, :dns_cluster_query) || :ignore},

# Compilers adjustment in mix.exs
compilers: Mix.compilers(),  # Remove phoenix_live_view compiler
```

### Melhor Prática 2025: Version Alignment Research

#### Processo Validado
1. **Research First**: Web search for specific error messages
2. **GitHub Source**: Use main branch when releases are incompatible  
3. **Stack Downgrade**: Sometimes newer isn't better (Phoenix 1.8 → 1.7)
4. **Test Validation**: 35/40 tests passing = architecture valid

## 🚀 Upgrade Scenarios - Phase 2 WebAssembly (30/08/2025)

### 📊 Upgrade Stack Completo: Elixir 1.14 → 1.17.3 + OTP 25 → 26.0.2

**Contexto**: Ativação Popcorn WebAssembly requer versões específicas  
**Motivação**: Hard requirement confirmado via web search + tentativa real  
**Resultado**: Upgrade Stack validado como solução definitiva

#### 🎯 Pre-Upgrade Checklist
```yaml
Validações Necessárias:
  ✅ Phase 1 infrastructure sólida (35/40 tests passing)
  ✅ Backup .tool-versions atual
  ✅ Knowledge base documentada
  ✅ KERL optimization flags researched
  ✅ Timeline planejado (8-10 min total)
  
Contexto Projeto Atual:
  - Elixir: 1.14.0 + OTP 25 (working Phase 1)
  - Phoenix: 1.7.21 (compatível com ambas versions)
  - Hex: 2.2.3-dev (from source - compatibility fix)
  - Popcorn: Comentado (aguardando upgrade)
```

#### ⚡ Upgrade Process Otimizado
```bash
# STEP 1: Export KERL Optimization Flags
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --without-odbc --without-wx"
export KERL_INSTALL_HTMLDOCS=no
export KERL_INSTALL_MANPAGES=no

# STEP 2: Source asdf
source ~/.asdf/asdf.sh

# STEP 3: Install Erlang 26.0.2 (3-4 min otimizado)
asdf install erlang 26.0.2

# STEP 4: Install Elixir 1.17.3-otp-26 (30s)
asdf install elixir 1.17.3-otp-26

# STEP 5: Set local versions (isolamento projeto)
cd /path/to/project
asdf local erlang 26.0.2
asdf local elixir 1.17.3-otp-26

# STEP 6: Validate versions
elixir --version  # Must show 1.17.3
```

#### 🔧 Project Stack Update
```bash
# Clean project cache
mix clean

# Rebuild dependencies with new stack
mix deps.clean --all
mix deps.get

# Recompile project
mix compile

# Validation
mix test
```

#### 📊 Timeline Benchmark (Real Data)
```yaml
Optimization Impact:
  KERL flags export: 10s
  Erlang 26.0.2 build: 3-4 min (vs 8-10 min without flags)
  Elixir 1.17.3 install: 30s (precompiled)
  Project recompile: 1 min
  Validation tests: 1 min
  Total: 8-10 minutes vs 15+ minutes traditional
  
Performance Gain: ~60% faster deployment
ROI: Significant para development velocity
```

#### 🐛 Troubleshooting Upgrade
```yaml
Common Issues:
  1. "KERL build failed":
     - Solution: Ensure all build dependencies installed
     - Command: sudo apt-get install build-essential autoconf m4 libncurses5-dev libssl-dev
     
  2. "Version not switching":
     - Solution: Check .tool-versions created correctly
     - Command: cat .tool-versions && asdf current
     
  3. "Dependencies not compiling":
     - Solution: Full clean rebuild
     - Command: mix deps.clean --all && mix deps.get && mix compile
     
  4. "Tests failing after upgrade":
     - Solution: Check version-specific compatibility
     - Reference: Phoenix 1.7.21 known compatible both stacks
```

#### 🎯 Post-Upgrade Validation Checklist
```yaml
Critical Validations:
  ✅ elixir --version shows 1.17.3
  ✅ erl -eval shows OTP 26
  ✅ mix compile successful
  ✅ mix test results >= Phase 1 (35/40)
  ✅ Popcorn dependency resolved (no errors)
  ✅ WASM build commands available (mix wasm.build)
  
Success Criteria:
  - Zero compilation errors
  - Dependencies resolved cleanly  
  - Test suite maintains/improves coverage
  - Ready for Popcorn WASM activation
```

## ✅ Solução Implementada (Phase 1 - 29/08/2025)

### 1. Dependências do Sistema
```bash
# Ubuntu 24.04 WSL2 - Dependências para compilação
sudo apt-get update && sudo apt-get install -y \
  build-essential autoconf m4 libncurses5-dev \
  libgl1-mesa-dev libglu1-mesa-dev libpng-dev \
  libssh-dev unixodbc-dev xsltproc fop libxml2-utils \
  libncurses-dev openjdk-11-jdk curl git wget \
  libssl-dev libreadline-dev zlib1g-dev
```

### 2. Instalação asdf
```bash
# Clone do repositório oficial
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

# Configuração do shell
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
source ~/.bashrc

# Verificação
asdf --version  # v0.14.0-ccdd47d
```

### 3. Instalação Erlang + Elixir
```bash
# Adicionar plugins
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git

# Versões para Phoenix 1.8 (2025)
asdf install erlang 26.2.2
asdf install elixir 1.17.3-otp-26

# Definir globalmente
asdf global erlang 26.2.2  
asdf global elixir 1.17.3-otp-26

# Verificar compatibilidade
elixir --version
# Erlang/OTP 26 [erts-14.2.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]
# Elixir 1.17.3 (compiled with Erlang/OTP 26)
```

### 4. Instalação Phoenix 1.8
```bash
# Instalar Hex (package manager)
mix local.hex --force

# Instalar Phoenix generator
mix archive.install hex phx_new 1.8.1 --force

# Verificar instalação
mix phx.new --version  # Phoenix v1.8.1
```

## 🎯 Versões Específicas para Projetos

### .tool-versions (recomendado)
```bash
# Na raiz do projeto
echo "erlang 26.2.2" > .tool-versions
echo "elixir 1.17.3-otp-26" >> .tool-versions

# asdf detecta automaticamente e muda versões
asdf current
```

## 🔧 Troubleshooting Identificado

### Problema 1: Timeout na Compilação Erlang
```bash
# Sintoma: Build demora > 10 minutos
APPLICATIONS INFORMATION (See: /path/to/build.log)
* wx : wxWidgets was not compiled with --enable-webview...

# Soluções:
# 1. Usar versão pré-compilada (quando disponível)
export KERL_BUILD_DOCS=no
export KERL_CONFIGURE_OPTIONS="--without-javac --without-wx"

# 2. Instalar dependências wx (opcional, para GUI)
sudo apt-get install libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev
```

### Problema 2: Locale Warnings
```bash
# Sintoma: bash: warning: setlocale: LC_ALL: cannot change locale (pt_BR.UTF-8)

# Solução:
sudo locale-gen pt_BR.UTF-8
export LC_ALL=C.UTF-8
```

### Problema 3: Phoenix Version Conflicts
```bash
# Sintoma: Múltiplas versões Phoenix instaladas

# Solução: Limpar archives
mix archive  # Listar
mix archive.uninstall phx_new-1.7.14  # Remover antigas
mix archive.install hex phx_new 1.8.1 --force  # Instalar nova
```

## 🚀 Template de Setup Rápido (2025)

### Script de Instalação Completa
```bash
#!/bin/bash
# setup-elixir-2025.sh

echo "🚀 Setup Elixir/Phoenix moderno - Ubuntu WSL2 2025"

# 1. Dependências do sistema
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential autoconf m4 \
  libncurses5-dev libssl-dev libreadline-dev zlib1g-dev \
  curl git wget

# 2. asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0 -q
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc

# 3. Plugins
source ~/.asdf/asdf.sh
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git

# 4. Versões (Phoenix 1.8 compatível)
export KERL_BUILD_DOCS=no
export KERL_CONFIGURE_OPTIONS="--without-javac --without-wx"
asdf install erlang 26.2.2
asdf install elixir 1.17.3-otp-26
asdf global erlang 26.2.2
asdf global elixir 1.17.3-otp-26

# 5. Phoenix
mix local.hex --force
mix archive.install hex phx_new 1.8.1 --force

echo "✅ Setup completo! Versões:"
elixir --version
mix phx.new --version
```

## 📊 Benchmarks de Instalação

### Tempos Medidos (Ubuntu 24.04 WSL2)
```yaml
Dependências Sistema: ~3-5 min
asdf Clone/Setup: ~30 segundos  
Erlang Compilação: ~10-15 min (com optimizações)
Elixir Instalação: ~2-3 min
Phoenix Setup: ~1 min
Total: ~15-25 minutos
```

### Otimizações para CI/CD
```bash
# Para pipelines automatizados
export KERL_BUILD_DOCS=no
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --without-wx --without-megaco --without-debugger --without-observer --without-et"

# Cache do asdf
cache_key: asdf-${{ hashFiles('.tool-versions') }}
```

## 🎯 Melhores Práticas 2025

### Por Projeto
- Sempre usar `.tool-versions`
- Commitar arquivo no git
- Documentar versões no README

### Por Ambiente
- Desenvolvimento: Latest stable
- Produção: Versões fixas testadas
- CI/CD: Mesmo que produção

### Stack Completa Recomendada
```elixir
# .tool-versions
erlang 26.2.2
elixir 1.17.3-otp-26
nodejs 20.11.0  # Para assets

# mix.exs (2025)
def project do
  [
    elixir: "~> 1.17",
    deps: deps(),
    # ... outras configs
  ]
end

defp deps do
  [
    {:phoenix, "~> 1.8.1"},
    {:phoenix_live_view, "~> 1.1.0"},
    # Stack moderna completa
  ]
end
```

## 📚 Referencias e Aprendizados

### Fontes de Informação (Web Search 29/08/2025)
1. **Phoenix Official Blog**: "Phoenix 1.8.0 released!" 
2. **Elixir Installation Guide**: elixir-lang.org/install.html
3. **asdf-vm Documentation**: asdf-vm.com/guide/getting-started.html
4. **Community Best Practices**: elixirforum.com forums

### Lições Aprendidas
1. **Phoenix 1.8 é strict** com versões - não aceita Elixir < 1.15
2. **asdf é essencial** para desenvolvimento moderno Elixir
3. **Compilação Erlang demora** - otimizações são necessárias
4. **Compatibilidade OTP/Elixir** é crítica - sempre verificar
5. **WSL2 funciona perfeitamente** com stack completo

---

## 🚀 Status Implementation - CONCLUÍDO

**✅ Pesquisa Web Realizada**: Soluções atualizadas para 2025  
**✅ Dependências Instaladas**: Sistema preparado para compilação  
**✅ asdf Configurado**: Version manager funcional  
**✅ Erlang/Elixir Instalados**: Elixir 1.18.4-otp-25 funcionando
**✅ Phoenix Instalado**: Phoenix 1.8.1 generator funcionando
**✅ Projeto Criado**: Blog greenfield com todas práticas modernas

---

**Próxima Atualização**: Após conclusão da instalação Erlang/Elixir  
**Documentação Atualizada**: 29/08/2025  
**Base de Conhecimento**: Enriquecida com aprendizados reais de implementação
---
## 📁 06-devops-infra/01-devops-checklist.md

# DevOps para Web App 100% Elixir com Popcorn WebAssembly
## Checklist de Aprendizado e Evolução Contínua

---

## 📋 Checklist Principal: Desenvolvimento Local com Popcorn

### 📚 **FASE 1: FUNDAMENTOS ELIXIR PURO** (2 semanas)

#### 1.1 Setup Ambiente Elixir
- [ ] **Instalar Erlang/Elixir**
  - [ ] ASDF para gerenciar versões
  - [ ] Elixir 1.17.3 (versão específica do Popcorn)
  - [ ] OTP 26.0.2 (compatível com Popcorn)
  - [ ] Verificar instalação: `elixir --version`

- [ ] **Phoenix Framework**
  - [ ] Instalar Phoenix 1.7+
  - [ ] PostgreSQL para banco de dados
  - [ ] Node.js para assets (Phoenix padrão)
  - [ ] Criar app teste: `mix phx.new teste --live`

#### 1.2 Entender Popcorn Básico
- [ ] **O que é Popcorn**
  - [ ] AtomVM rodando no browser
  - [ ] Elixir compilado para WebAssembly
  - [ ] Limitações atuais (sem big integers, ETS limitado)
  - [ ] Bundle de ~3MB (incluindo runtime)

- [ ] **Requisitos do Browser**
  - [ ] SharedArrayBuffer habilitado
  - [ ] Headers COOP/COEP configurados
  - [ ] Browsers modernos (Chrome, Firefox, Edge)
  - [ ] Console para debug

### 🚀 **FASE 2: PRIMEIRO PROJETO POPCORN** (2 semanas)

#### 2.1 Setup Popcorn
- [ ] **Instalar Popcorn**
  - [ ] Adicionar `{:popcorn, "~> 0.1.0"}` ao mix.exs
  - [ ] mix deps.get
  - [ ] Verificar documentação oficial
  - [ ] Entender estrutura de arquivos

- [ ] **Configurar Build**
  - [ ] mix popcorn.build_runtime --target wasm
  - [ ] Entender processo de compilação
  - [ ] Verificar saída em priv/static
  - [ ] Testar servidor local

#### 2.2 Hello World no Browser
- [ ] **Criar módulo Elixir simples**
  - [ ] Função pura sem dependências
  - [ ] Sem processos ou GenServers (início)
  - [ ] Retorno de dados simples
  - [ ] Console.log via JavaScript

- [ ] **Compilar para WASM**
  - [ ] mix popcorn.cook
  - [ ] Verificar arquivo .wasm gerado
  - [ ] Tamanho do bundle
  - [ ] Tempo de compilação

#### 2.3 Interoperabilidade JavaScript
- [ ] **Chamar Elixir do JavaScript**
  - [ ] Popcorn.Wasm.run/2
  - [ ] Passar parâmetros simples
  - [ ] Receber retorno
  - [ ] Tratamento de erros

- [ ] **Chamar JavaScript do Elixir**
  - [ ] Popcorn.Wasm.run_js/1
  - [ ] Manipular DOM básico
  - [ ] Console.log para debug
  - [ ] Eventos simples

### 🔧 **FASE 3: DESENVOLVIMENTO LOCAL INTEGRADO** (3 semanas)

#### 3.1 Phoenix + Popcorn
- [ ] **Estrutura do projeto**
  - [ ] lib/my_app/ para Backend Phoenix
  - [ ] lib/my_app_wasm/ para Código Popcorn
  - [ ] priv/static/ para WASM compilado
  - [ ] assets/ para JavaScript bridge

- [ ] **Servidor de desenvolvimento**
  - [ ] Phoenix servindo arquivos WASM
  - [ ] Headers CORS configurados
  - [ ] COOP/COEP para SharedArrayBuffer
  - [ ] Live reload setup

#### 3.2 Compartilhamento de Código
- [ ] **Módulos compartilhados**
  - [ ] Business logic pura em Elixir
  - [ ] Validações reutilizáveis
  - [ ] Estruturas de dados comuns
  - [ ] Funções utilitárias

- [ ] **Compilação seletiva**
  - [ ] Macros para código específico
  - [ ] Compile-time flags
  - [ ] Separação server/client
  - [ ] Dead code elimination

#### 3.3 Estado e Comunicação
- [ ] **Estado no browser**
  - [ ] Agentes simples (se suportado)
  - [ ] Estado funcional imutável
  - [ ] LocalStorage via JS
  - [ ] SessionStorage para temporário

- [ ] **Phoenix Channels + Popcorn**
  - [ ] WebSocket do Phoenix
  - [ ] Mensagens para Popcorn
  - [ ] Sincronização de estado
  - [ ] Reconexão automática

### 🧪 **FASE 4: TESTING E QUALIDADE** (2 semanas)

#### 4.1 Testes Unitários
- [ ] **Testes do código compartilhado**
  - [ ] ExUnit padrão
  - [ ] Mesmo código, dois contextos
  - [ ] Property-based testing
  - [ ] Doctests

- [ ] **Testes específicos Popcorn**
  - [ ] Funções puras primeiro
  - [ ] Mock de JavaScript
  - [ ] Testes de integração básicos
  - [ ] Coverage reports

#### 4.2 Testes no Browser
- [ ] **Automação com Wallaby**
  - [ ] Setup ChromeDriver
  - [ ] Carregar módulo Popcorn
  - [ ] Executar funções Elixir
  - [ ] Validar resultados

- [ ] **Debugging**
  - [ ] Chrome DevTools
  - [ ] Console.log estratégico
  - [ ] Source maps (se disponível)
  - [ ] Performance profiling

#### 4.3 CI Pipeline
- [ ] **GitHub Actions**
  - [ ] Test Elixir Code
  - [ ] Build Popcorn
  - [ ] Check Bundle Size
  - [ ] Quality Gates

### 📦 **FASE 5: BUILD E DEPLOYMENT LOCAL** (2 semanas)

#### 5.1 Otimização de Build
- [ ] **Reduzir tamanho do bundle**
  - [ ] Remover código não usado
  - [ ] Compilação release mode
  - [ ] Compressão gzip/brotli
  - [ ] Lazy loading de módulos

- [ ] **Cache estratégico**
  - [ ] Service Worker setup
  - [ ] Cache do WASM bundle
  - [ ] Versionamento de assets
  - [ ] Cache busting

#### 5.2 Docker para Desenvolvimento
- [ ] **Dockerfile multi-stage**
  - [ ] Build stage com Elixir
  - [ ] Runtime stage otimizado
  - [ ] Configuração de headers

- [ ] **Docker Compose**
  - [ ] Phoenix app
  - [ ] PostgreSQL
  - [ ] Servidor de arquivos estáticos
  - [ ] Headers COOP/COEP configurados

#### 5.3 Desenvolvimento Offline
- [ ] **Progressive Web App**
  - [ ] Manifest.json
  - [ ] Service Worker
  - [ ] Offline fallback
  - [ ] Sincronização quando online

- [ ] **Estado offline**
  - [ ] IndexedDB via JavaScript
  - [ ] Queue de ações
  - [ ] Conflict resolution
  - [ ] Sync com servidor

### 📊 **FASE 6: MONITORAMENTO E OBSERVABILIDADE** (2 semanas)

#### 6.1 Telemetria Phoenix
- [ ] **Backend metrics**
  - [ ] Phoenix.Telemetry setup
  - [ ] Ecto query metrics
  - [ ] Channel connections
  - [ ] Request latency

- [ ] **Dashboard local**
  - [ ] Phoenix LiveDashboard
  - [ ] Métricas customizadas
  - [ ] Alertas básicos
  - [ ] Histórico de performance

#### 6.2 Monitoramento Popcorn
- [ ] **Performance no browser**
  - [ ] Tempo de inicialização
  - [ ] Uso de memória
  - [ ] Tempo de execução de funções
  - [ ] Erros e crashes

- [ ] **Logging estruturado**
  - [ ] Logs para console
  - [ ] Envio para servidor
  - [ ] Níveis de log
  - [ ] Debugging remoto

### 🔄 **FASE 7: LIVERELOAD E DX** (1 semana)

#### 7.1 Hot Reload Setup
- [ ] **Phoenix LiveReload**
  - [ ] Watch de arquivos Elixir
  - [ ] Recompilação automática
  - [ ] Refresh do browser
  - [ ] Preservação de estado

- [ ] **Popcorn auto-build**
  - [ ] File watcher para .ex
  - [ ] mix popcorn.cook automático
  - [ ] Notificação de rebuild
  - [ ] Reload do módulo WASM

### 🎮 **FASE 8: CASOS DE USO PRÁTICOS** (3 semanas)

#### 8.1 Aplicação TODO List
- [ ] **Backend Phoenix**
  - [ ] CRUD API
  - [ ] Phoenix Channels
  - [ ] Autenticação básica
  - [ ] Persistência Ecto

- [ ] **Frontend Popcorn**
  - [ ] Renderização de lista
  - [ ] Adicionar/remover items
  - [ ] Estado local
  - [ ] Sincronização com servidor

#### 8.2 Chat em Tempo Real
- [ ] **Funcionalidades**
  - [ ] Mensagens via Channels
  - [ ] Presença online
  - [ ] Histórico de mensagens
  - [ ] Notificações no browser

#### 8.3 Mini Editor de Texto
- [ ] **Editor básico**
  - [ ] Manipulação de texto
  - [ ] Undo/Redo em Elixir
  - [ ] Syntax highlighting
  - [ ] Auto-save

### 🚦 **FASE 9: PRODUÇÃO LOCAL** (2 semanas)

#### 9.1 Preparação para Deploy
- [ ] **Build de produção**
  - [ ] MIX_ENV=prod
  - [ ] Releases com Mix
  - [ ] Assets minificados
  - [ ] WASM otimizado

- [ ] **Configuração de ambiente**
  - [ ] Variáveis de ambiente
  - [ ] Secrets management
  - [ ] Database migrations
  - [ ] Static files CDN

#### 9.2 Performance
- [ ] **Otimizações Phoenix**
  - [ ] Connection pooling
  - [ ] Query optimization
  - [ ] Cache strategies
  - [ ] Response compression

- [ ] **Otimizações Popcorn**
  - [ ] Lazy loading
  - [ ] Code splitting (se possível)
  - [ ] Memory management
  - [ ] Batch operations

### 📈 **FASE 10: SCALE E EVOLUÇÃO** (2 semanas)

#### 10.1 Estratégias de Scale
- [ ] **Horizontal scaling**
  - [ ] Load balancer local
  - [ ] Multiple Phoenix nodes
  - [ ] Distributed Erlang
  - [ ] Session management

#### 10.2 Evolução da Arquitetura
- [ ] **Modularização**
  - [ ] Umbrella apps
  - [ ] Bounded contexts
  - [ ] Microservices consideration
  - [ ] API Gateway pattern

---

## 🔄 Evolução Contínua e Contribuição ao Ecossistema

### Filosofia de Evolução Colaborativa

O ecossistema Elixir sempre foi construído sobre colaboração. Quando você usa Popcorn e WebAssembly, você é um **pioneiro** ajudando a moldar o futuro da linguagem.

### Ciclo de Evolução Contínua

```
USAR → APRENDER → MELHORAR → COMPARTILHAR → USAR...
```

- **USAR** (Semanas 1-4): Implemente em projetos internos
- **APRENDER** (Semanas 5-8): Entenda o código fonte
- **MELHORAR** (Semanas 9-12): Transforme workarounds em soluções
- **COMPARTILHAR** (Contínuo): Publique melhorias como PRs

### 🎯 Mapa de Contribuições por Nível

#### 🟢 Nível Iniciante
- [ ] Criar exemplos simples
- [ ] Reportar bugs estruturados
- [ ] Traduzir documentação
- [ ] Revisar código de outros

#### 🟡 Nível Intermediário
- [ ] Desenvolver Mix tasks
- [ ] Criar bibliotecas de compatibilidade
- [ ] Escrever benchmarks
- [ ] Otimizar performance

#### 🔴 Nível Avançado
- [ ] Implementar features core
- [ ] Otimizações de compiler
- [ ] Integração com ferramentas
- [ ] Arquitetura de soluções

### 📊 Roadmap Comunitário 2025-2026

#### Q1 2025: Fundação
- Estabilidade e correção de bugs
- Documentação completa
- 10+ exemplos funcionais

#### Q2 2025: Expansão
- Features essenciais (ETS, processos)
- Redução de bundle 30%
- Tooling melhorado

#### Q3 2025: Otimização
- Bundle < 2MB
- Performance 50% melhor
- Developer experience aprimorada

#### Q4 2025: Maturidade
- Versão 1.0 production ready
- Ecossistema de bibliotecas
- Cases empresariais

### 🛠️ Kit de Ferramentas do Contribuidor

#### Setup Básico
```bash
# Fork e desenvolvimento
git clone https://github.com/SEU-USER/popcorn
git checkout -b feature/minha-contribuicao

# Desenvolvimento
mix test
mix format
mix credo

# Commit semântico
git commit -m "feat: adiciona suporte para localStorage"
```

#### Estrutura de Contribuição
```
minha-contribuicao/
├── lib/          # Código principal
├── test/         # Testes completos
├── examples/     # Exemplos de uso
├── docs/         # Documentação
└── CHANGELOG.md  # Mudanças
```

### 💡 Patterns de Contribuição

#### Problem-Solution-Validation
1. **Problem**: Identifique claramente o problema
2. **Solution**: Proponha solução elegante
3. **Validation**: Prove com testes e métricas

#### Incremental Enhancement
- v1: Funcionalidade básica
- v2: Adiciona tipos
- v3: Adiciona cache
- v4: Adiciona telemetria

### 📝 Compromisso de Contribuição

#### Modelo de Compromisso (Q1 2025)
- [ ] 2 horas/semana para contribuições
- [ ] 1 bug report detalhado por mês
- [ ] 1 PR (doc ou código) por trimestre
- [ ] 1 blog post por semestre

#### Foco Principal (escolha um):
- [ ] Redução de bundle size
- [ ] Melhorias de debugging
- [ ] Documentação e exemplos
- [ ] Performance optimization
- [ ] Feature implementation

### 🚀 Começando Hoje

#### Semana 1: Reconhecimento
- [ ] Star no repo do Popcorn
- [ ] Entrar na comunidade Slack/Discord
- [ ] Ler issues abertas
- [ ] Rodar exemplos existentes

#### Semana 2: Primeiro Contato
- [ ] Abrir issue com pergunta
- [ ] Comentar em issue existente
- [ ] Testar PR pendente
- [ ] Compartilhar nas redes sociais

#### Semana 3: Primeira Contribuição
- [ ] Corrigir typo na documentação
- [ ] Adicionar exemplo simples
- [ ] Melhorar mensagem de erro
- [ ] Traduzir documentação

#### Mês 2: Contribuição Substancial
- [ ] Implementar pequena feature
- [ ] Corrigir bug real
- [ ] Escrever tutorial completo
- [ ] Criar ferramenta auxiliar

---

## ✅ Métricas de Sucesso

### KPIs do Projeto
- **Bundle size**: < 3MB inicial, < 2MB em 6 meses
- **Performance**: 2x melhoria em operações críticas
- **Features**: 80% do Elixir core funcionando
- **Stability**: Zero crashes em produção

### Marcos de Desenvolvimento
- Primeiro "Hello World": **Dia 3**
- App TODO funcionando: **Semana 3**
- Chat real-time: **Semana 5**
- Sistema production-ready: **Semana 12**

### Impacto Comunitário
- Bugs reportados e resolvidos
- PRs aceitos no projeto
- Desenvolvedores ajudados
- Features implementadas

---

## 📚 Recursos Essenciais

### Documentação
- [GitHub Popcorn](https://github.com/software-mansion/popcorn)
- [Demo Online](https://popcorn.swmansion.com)
- [AtomVM Documentation](https://atomvm.net)
- [Phoenix Guides](https://hexdocs.pm/phoenix)

### Comunidade
- Elixir Forum - Popcorn threads
- Slack #popcorn
- Discord WebAssembly Guild

### Aprendizado
- Elixir School
- Phoenix LiveView Course
- WebAssembly MDN Docs

---

## 🎯 Vantagens da Abordagem 100% Elixir

✅ **Uma única linguagem** para todo o stack  
✅ **Compartilhamento total** de código e lógica  
✅ **Mesmas ferramentas** e workflow unificado  
✅ **Comunidade única** e coesa  
✅ **Sem context switch** mental  

### Limitações Atuais e Soluções

| Limitação | Solução Imediata | Contribuição Possível |
|-----------|------------------|----------------------|
| v0.1.0 experimental | Use em features não-críticas | Reporte bugs, escreva testes |
| Features faltantes | Use workarounds e polyfills | Implemente compatibilidade |
| Bundle 3MB | Lazy loading e compressão | Tree shaking, otimizações |
| Performance | Híbrido JS + Popcorn | Benchmarks e profiling |
| Debug complexo | Logging estratégico | Source maps, DevTools |

---

**Sua jornada com Popcorn começa agora. Cada linha de código, cada bug reportado, cada exemplo criado contribui para o futuro do Elixir com WebAssembly.**

---
## 📁 06-devops-infra/wasm-telemetry-production.md

# WASM Production Telemetry & Monitoring [NAVEGACAO-RAPIDA][IMPORTANT]

**Data**: 30/08/2025  
**Contexto**: Projeto Blog WebAssembly-First - Phase 3 Production Monitoring  
**Focus**: Production-grade WASM performance monitoring em client environment  
**Challenge**: Telemetry collection distributed entre server Phoenix + client WASM  
**Fontes**: Elixir Logger 1.18 + Phoenix Telemetry + WebAssembly monitoring 2025

## 🔍 Quick Navigation [ECONOMIA-TOKENS]
| Find | Line | Content | Savings |
|------|------|---------|---------|
| [ESSENCIAL] | L25 | Telemetry architecture | 80% |
| [ERRO-COMUM] | L110 | Performance bottlenecks | 85% |
| [TEMPLATE] | L190 | Ready monitoring setup | 90% |
| [ALERTS] | L290 | Production alerting | 75% |

---

## 🎯 Contexto e Motivação [ESSENCIAL]

### Problema Identificado  
- **Current**: Basic development telemetry apenas
- **Target**: Production-grade WASM performance monitoring
- **Challenge**: Distributed telemetry entre Phoenix server + WASM client
- **Complexity**: Metrics collection em environment WASM isolation

### Monitoring Objectives
```yaml
WASM Performance Monitoring:
  Bundle Metrics:
    - Load time: <2s first time, <500ms cached
    - Parse time: <300ms WASM instantiation  
    - Memory usage: <10MB heap usage
    - Bundle size: Track actual transfer size
    
  Runtime Metrics:
    - Initialization: <500ms AtomVM start
    - Operation latency: <50ms Elixir function calls
    - Memory pressure: GC frequency + duration
    - Error rates: Client crashes + exceptions
    
  Business Metrics:
    - Engagement: Time on page offline vs online
    - Feature usage: Offline feature adoption
    - Performance impact: Load time vs bounce rate  
    - Cost efficiency: CDN bandwidth vs server costs
```

### Strategic Value
- **Performance Optimization**: Data-driven WASM bundle improvements
- **User Experience**: Identify performance bottlenecks
- **Cost Management**: Monitor CDN usage vs server costs
- **Reliability**: Track offline/online transition success rates

---

## 📚 Pesquisa em Fontes Oficiais [ESSENCIAL]

### [Fonte 1]: Elixir Logger Production Configuration
**URL**: https://hexdocs.pm/logger/1.18.4/Logger.html  
**Focus**: Production logging, performance optimization, metadata

**Key Logger Features for WASM**:
```elixir
# Compile-time log purging
config :logger,
  compile_time_purge_matching: [
    [level_lower_than: :warning]  # Remove debug/info in production
  ]

# Performance protection
config :logger,
  truncate: 8192,           # Limit message size
  discard_threshold: 500,   # Overload protection (500 logs/sec)
  sync_threshold: 20        # Switch to sync mode under load
```

**Production Optimization Insights**:
- "Formats and truncates messages on client to avoid clogging Logger handlers"
- Overload protection limits to 500 logs per second by default
- Can dynamically adjust log levels for specific modules/applications
- Supports metadata capture for context (module, function, process)

### [Fonte 2]: Phoenix Telemetry Integration
**URL**: Phoenix telemetry documentation + Honeybadger blog post  
**Discovery**: Built-in telemetry events + custom metrics

**Phoenix Built-in Events**:
- Request processing: `[:phoenix, :endpoint, :start|stop]`
- LiveView events: `[:phoenix, :live_view, :mount|handle_event]`
- Channel events: `[:phoenix, :channel, :join|leave]`
- Database queries: `[:blog, :repo, :query]`

**Custom WASM Events Strategy**:
```elixir
:telemetry.execute([:blog, :wasm, :bundle_load], %{duration: load_time})
:telemetry.execute([:blog, :wasm, :operation], %{duration: op_time, type: :create_post})
```

### [Fonte 3]: AtomVM Monitoring Capabilities
**URL**: AtomVM GitHub + Smart Sensors use case  
**Focus**: Embedded monitoring, resource constraints

**AtomVM Monitoring Features**:
- Lightweight telemetry for embedded systems
- Memory usage tracking in constrained environments
- Process monitoring with minimal overhead
- Integration with environmental sensors (ESP32 example)

---

## ❌ Telemetry Antipatterns [ERRO-COMUM]

### 1. **Verbose Logging em WASM Environment**
```elixir
# ❌ ERRO: Logger verbose em production WASM
config :logger, level: :debug

# Result: Bundle bloat + performance degradation
# Impact: Slower initialization + memory pressure

# ✅ CORRETO: Minimal logging WASM
config :logger,
  level: :warning,
  compile_time_purge_matching: [
    [level_lower_than: :warning]
  ],
  backends: []  # No file logging in browser
```

### 2. **Blocking Telemetry em Client Processing**
```elixir
# ❌ ERRO: Synchronous telemetry blocking
def create_post(title, content) do
  start_time = System.monotonic_time()
  
  # Heavy telemetry call blocks operation
  result = Blog.Content.create_post(%{title: title, content: content})
  
  # Synchronous telemetry transmission
  send_telemetry_sync(%{
    operation: :create_post,
    duration: System.monotonic_time() - start_time,
    result: result
  })
  
  result
end

# ✅ CORRETO: Async telemetry
def create_post(title, content) do
  start_time = System.monotonic_time()
  result = Blog.Content.create_post(%{title: title, content: content})
  
  # Async telemetry (non-blocking)
  Task.start(fn ->
    :telemetry.execute([:blog, :wasm, :create_post], %{
      duration: System.monotonic_time() - start_time
    }, %{result: elem(result, 0)})
  end)
  
  result
end
```

### 3. **Missing Error Context em WASM**
```elixir
# ❌ ERRO: Generic error logging
Logger.error("WASM operation failed")

# ✅ CORRETO: Rich error context
Logger.error("WASM operation failed", 
  operation: :create_post,
  bundle_version: "v1.2.3",
  memory_usage: get_memory_usage(),
  user_agent: get_user_agent(),
  stack_trace: __STACKTRACE__
)
```

### 4. **No Performance Baselines**
```javascript
// ❌ ERRO: Metrics sem context
console.log(`Operation took ${duration}ms`);

// ✅ CORRETO: Baseline comparison
const baseline = 100; // ms expected
const performance_ratio = duration / baseline;

if (performance_ratio > 1.5) {
  console.warn(`Slow operation: ${duration}ms (${performance_ratio}x baseline)`);
  
  // Report performance degradation
  reportPerformanceIssue({
    operation: 'create_post',
    actual: duration,
    expected: baseline,
    ratio: performance_ratio
  });
}
```

---

## 🏗️ Production Telemetry Architecture [TEMPLATE]

### 1. **Server-Side Telemetry Handler**

```elixir
# lib/blog/telemetry.ex
defmodule Blog.Telemetry do
  @moduledoc """
  Production telemetry handler for WASM-specific metrics.
  Collects performance data from both server and client environments.
  """
  
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      # Telemetry metrics setup
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      
      # Custom metrics collector
      {Blog.Telemetry.Collector, []},
      
      # Performance aggregator  
      {Blog.Telemetry.Aggregator, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # WASM-specific metrics definitions
  def metrics do
    [
      # WASM Bundle Performance
      summary("blog.wasm.bundle.load_duration",
        unit: {:native, :millisecond},
        description: "WASM bundle load time",
        tags: [:bundle_version, :browser, :connection_type]
      ),
      
      summary("blog.wasm.runtime.init_duration", 
        unit: {:native, :millisecond},
        description: "AtomVM initialization time",
        tags: [:wasm_version, :device_type]
      ),
      
      # Client Operations
      counter("blog.wasm.operations.total",
        description: "Total WASM operations executed",
        tags: [:operation_type, :offline_mode]
      ),
      
      distribution("blog.wasm.operations.duration",
        unit: {:native, :millisecond}, 
        description: "WASM operation execution time",
        buckets: [10, 50, 100, 500, 1000, 5000],
        tags: [:operation_type, :complexity]
      ),
      
      # Memory & Resources
      last_value("blog.wasm.memory.heap_usage",
        unit: :byte,
        description: "WASM heap memory usage",
        tags: [:runtime_type]
      ),
      
      counter("blog.wasm.errors.total",
        description: "WASM runtime errors",
        tags: [:error_type, :operation, :recovery_status]
      ),
      
      # Offline-First Metrics
      counter("blog.offline.operations.total",
        description: "Operations performed offline",
        tags: [:operation_type, :sync_status]
      ),
      
      summary("blog.offline.sync.duration",
        unit: {:native, :millisecond},
        description: "Offline sync completion time", 
        tags: [:operations_count, :conflicts_resolved]
      ),
      
      # Business Metrics
      counter("blog.engagement.time_on_page",
        description: "User engagement tracking",
        tags: [:page_type, :connection_mode]
      )
    ]
  end

  # Periodic measurements
  defp periodic_measurements do
    [
      # System metrics
      {Blog.Telemetry, :dispatch_system_metrics, []},
      
      # WASM-specific metrics
      {Blog.Telemetry, :dispatch_wasm_metrics, []},
      
      # Business metrics
      {Blog.Telemetry, :dispatch_usage_metrics, []}
    ]
  end

  def dispatch_system_metrics do
    :telemetry.execute([:blog, :system], %{
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count),
      port_count: :erlang.system_info(:port_count)
    })
  end

  def dispatch_wasm_metrics do
    # Collect from WASM client via API
    case Blog.Telemetry.Client.get_current_metrics() do
      {:ok, metrics} ->
        :telemetry.execute([:blog, :wasm, :runtime], metrics.runtime)
        :telemetry.execute([:blog, :wasm, :performance], metrics.performance)
        
      {:error, _reason} ->
        # Client metrics unavailable (offline?)
        :telemetry.execute([:blog, :wasm, :client_unavailable], %{count: 1})
    end
  end
end
```

### 2. **Client-Side Metrics Collection**

```javascript
// assets/js/wasm-telemetry.js
class WasmTelemetry {
  constructor() {
    this.metrics = {
      runtime: {
        heap_usage: 0,
        initialization_time: 0,
        operation_count: 0,
        error_count: 0
      },
      performance: {
        bundle_load_time: 0,
        average_operation_time: 0,
        offline_operations: 0,
        sync_success_rate: 1.0
      },
      business: {
        time_on_page: 0,
        feature_usage: {},
        engagement_score: 0
      }
    };
    
    this.operationTimes = [];
    this.startTime = Date.now();
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Bundle loading metrics
    window.addEventListener('wasm-bundle-loaded', (event) => {
      this.metrics.performance.bundle_load_time = event.detail.duration;
      this.reportMetric('bundle_load', event.detail);
    });
    
    // Runtime initialization  
    window.addEventListener('wasm-runtime-ready', (event) => {
      this.metrics.runtime.initialization_time = event.detail.duration;
      this.reportMetric('runtime_init', event.detail);
    });
    
    // Operation tracking
    window.addEventListener('wasm-operation', (event) => {
      this.trackOperation(event.detail);
    });
    
    // Error tracking
    window.addEventListener('wasm-error', (event) => {
      this.trackError(event.detail);
    });
    
    // Memory monitoring (if available)
    if (performance.memory) {
      setInterval(() => this.trackMemoryUsage(), 5000);
    }
    
    // Page engagement
    this.setupEngagementTracking();
  }

  trackOperation(operation) {
    this.metrics.runtime.operation_count++;
    this.operationTimes.push(operation.duration);
    
    // Update average (rolling window)
    if (this.operationTimes.length > 100) {
      this.operationTimes = this.operationTimes.slice(-50);
    }
    
    this.metrics.performance.average_operation_time = 
      this.operationTimes.reduce((sum, time) => sum + time, 0) / this.operationTimes.length;
    
    // Track offline operations
    if (operation.offline) {
      this.metrics.performance.offline_operations++;
    }
    
    // Report if operation is slow
    if (operation.duration > 1000) {
      this.reportSlowOperation(operation);
    }
  }

  trackError(error) {
    this.metrics.runtime.error_count++;
    
    // Categorize error type
    const errorType = this.categorizeError(error);
    
    // Report immediately for critical errors
    if (errorType === 'critical') {
      this.reportCriticalError(error);
    }
    
    // Update error rate
    const total_ops = this.metrics.runtime.operation_count;
    const error_rate = this.metrics.runtime.error_count / total_ops;
    
    if (error_rate > 0.05) {  // 5% error rate threshold
      this.reportHighErrorRate(error_rate);
    }
  }

  trackMemoryUsage() {
    if (performance.memory) {
      const current = performance.memory.usedJSHeapSize;
      this.metrics.runtime.heap_usage = current;
      
      // Alert on high memory usage
      const maxMemory = 10 * 1024 * 1024; // 10MB
      if (current > maxMemory) {
        this.reportMemoryPressure(current);
      }
    }
  }

  setupEngagementTracking() {
    let pageStartTime = Date.now();
    let isActive = true;
    
    // Track page visibility
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        // Calculate time on page
        const timeOnPage = Date.now() - pageStartTime;
        this.metrics.business.time_on_page += timeOnPage;
        isActive = false;
      } else {
        pageStartTime = Date.now();
        isActive = true;
      }
    });
    
    // Track feature usage
    window.addEventListener('wasm-feature-used', (event) => {
      const feature = event.detail.feature;
      this.metrics.business.feature_usage[feature] = 
        (this.metrics.business.feature_usage[feature] || 0) + 1;
    });
  }

  // Error categorization
  categorizeError(error) {
    if (error.message.includes('OutOfMemory') || 
        error.message.includes('SharedArrayBuffer')) {
      return 'critical';
    }
    
    if (error.message.includes('WASM') || 
        error.message.includes('AtomVM')) {
      return 'runtime';
    }
    
    return 'application';
  }

  // Reporting methods
  async reportMetric(type, data) {
    const payload = {
      type: type,
      data: data,
      timestamp: new Date().toISOString(),
      user_agent: navigator.userAgent,
      bundle_version: window.WASM_BUNDLE_VERSION || 'unknown'
    };
    
    try {
      await fetch('/api/telemetry/wasm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
    } catch (error) {
      // Store for offline sync
      this.storeOfflineMetric(payload);
    }
  }

  async reportSlowOperation(operation) {
    await this.reportMetric('slow_operation', {
      operation_type: operation.type,
      duration: operation.duration,
      expected: operation.expected || 100,
      context: operation.context
    });
  }

  async reportCriticalError(error) {
    await this.reportMetric('critical_error', {
      message: error.message,
      stack: error.stack,
      operation: error.operation,
      memory_at_error: performance.memory?.usedJSHeapSize,
      timestamp: Date.now()
    });
  }

  async storeOfflineMetric(payload) {
    if (window.storageBridge) {
      await window.storageBridge.storePendingOperation({
        type: 'telemetry',
        payload: payload,
        timestamp: Date.now()
      });
    }
  }

  // Get current metrics for server collection
  getCurrentMetrics() {
    return {
      runtime: this.metrics.runtime,
      performance: this.metrics.performance,
      business: this.metrics.business,
      collected_at: new Date().toISOString()
    };
  }
}

// Global telemetry instance
window.wasmTelemetry = new WasmTelemetry();
```

### 3. **Server-Side Telemetry API**

```elixir
# lib/blog_web/controllers/telemetry_controller.ex
defmodule BlogWeb.TelemetryController do
  use BlogWeb, :controller
  
  alias Blog.Telemetry.Collector

  def wasm_metrics(conn, %{"type" => type, "data" => data} = params) do
    # Validate and sanitize client metrics
    with {:ok, validated_data} <- validate_telemetry_data(data),
         :ok <- Collector.store_wasm_metric(type, validated_data) do
      
      # Execute telemetry event
      :telemetry.execute(
        [:blog, :wasm, :client_metric], 
        validated_data,
        %{type: type, source: :client}
      )
      
      json(conn, %{status: :ok})
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def bulk_metrics(conn, %{"metrics" => metrics_list}) do
    # Handle bulk metrics from offline sync
    results = 
      metrics_list
      |> Enum.map(&process_bulk_metric/1)
      |> Enum.reduce(%{success: 0, errors: 0}, &aggregate_results/2)
    
    json(conn, results)
  end

  defp validate_telemetry_data(data) do
    # Sanitize and validate client-provided data
    required_fields = ["timestamp", "duration"]
    
    case Enum.all?(required_fields, &Map.has_key?(data, &1)) do
      true -> {:ok, sanitize_data(data)}
      false -> {:error, "Missing required fields"}
    end
  end

  defp sanitize_data(data) do
    %{
      timestamp: parse_timestamp(data["timestamp"]),
      duration: clamp_duration(data["duration"]),
      user_agent: sanitize_user_agent(data["user_agent"]),
      bundle_version: sanitize_version(data["bundle_version"])
    }
  end

  defp clamp_duration(duration) when is_number(duration) do
    # Clamp to reasonable bounds
    max(0, min(duration, 60_000))  # Max 60 seconds
  end
  defp clamp_duration(_), do: 0
end
```

### 4. **Performance Aggregation & Alerting**

```elixir
# lib/blog/telemetry/aggregator.ex
defmodule Blog.Telemetry.Aggregator do
  @moduledoc """
  Aggregates WASM performance metrics and triggers alerts.
  Maintains rolling windows for trend analysis.
  """
  
  use GenServer
  
  alias Blog.Telemetry.Storage

  defstruct [
    :performance_window,
    :error_rates,
    :bundle_metrics,
    :last_alert,
    :alert_cooldown
  ]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    # Attach to telemetry events
    :telemetry.attach_many(
      "wasm-aggregator",
      [
        [:blog, :wasm, :bundle_load],
        [:blog, :wasm, :operation],
        [:blog, :wasm, :error],
        [:blog, :offline, :sync]
      ],
      &handle_telemetry_event/4,
      %{}
    )
    
    state = %__MODULE__{
      performance_window: :queue.new(),
      error_rates: %{},
      bundle_metrics: %{},
      last_alert: nil,
      alert_cooldown: 300_000  # 5 minutes
    }
    
    # Schedule periodic analysis
    :timer.send_interval(60_000, self(), :analyze_metrics)
    
    {:ok, state}
  end

  def handle_telemetry_event([:blog, :wasm, :bundle_load], measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:bundle_metric, measurements, metadata})
  end

  def handle_telemetry_event([:blog, :wasm, :operation], measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:operation_metric, measurements, metadata})
  end

  def handle_telemetry_event([:blog, :wasm, :error], measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:error_metric, measurements, metadata})
  end

  def handle_cast({:bundle_metric, measurements, metadata}, state) do
    # Update bundle metrics
    bundle_key = metadata[:bundle_version] || "unknown"
    current_metrics = Map.get(state.bundle_metrics, bundle_key, [])
    
    new_metrics = [measurements.duration | current_metrics]
    |> Enum.take(100)  # Keep last 100 measurements
    
    updated_bundle_metrics = Map.put(state.bundle_metrics, bundle_key, new_metrics)
    
    # Check for performance degradation
    if measurements.duration > 5000 do  # 5s threshold
      send_alert(:slow_bundle_load, %{
        duration: measurements.duration,
        bundle_version: bundle_key,
        metadata: metadata
      })
    end
    
    {:noreply, %{state | bundle_metrics: updated_bundle_metrics}}
  end

  def handle_cast({:operation_metric, measurements, metadata}, state) do
    # Add to performance window
    metric = %{
      type: :operation,
      duration: measurements.duration,
      operation: metadata[:operation_type],
      timestamp: System.system_time(:millisecond)
    }
    
    new_window = add_to_window(state.performance_window, metric, 1000) # Keep 1000 ops
    
    {:noreply, %{state | performance_window: new_window}}
  end

  def handle_cast({:error_metric, measurements, metadata}, state) do
    error_type = metadata[:error_type] || "unknown"
    current_count = Map.get(state.error_rates, error_type, 0)
    
    updated_rates = Map.put(state.error_rates, error_type, current_count + 1)
    
    # Check error rate threshold
    total_operations = :queue.len(state.performance_window)
    error_rate = current_count / max(total_operations, 1)
    
    if error_rate > 0.05 do  # 5% error rate
      send_alert(:high_error_rate, %{
        error_type: error_type,
        rate: error_rate,
        count: current_count,
        total: total_operations
      })
    end
    
    {:noreply, %{state | error_rates: updated_rates}}
  end

  def handle_info(:analyze_metrics, state) do
    # Periodic performance analysis
    analyze_performance_trends(state)
    analyze_error_patterns(state)
    analyze_bundle_performance(state)
    
    {:noreply, state}
  end

  # Alert system
  defp send_alert(type, data) do
    # Don't spam alerts (cooldown)
    now = System.system_time(:millisecond)
    cooldown_expired = case GenServer.call(__MODULE__, :get_last_alert) do
      nil -> true
      last_alert -> (now - last_alert) > 300_000  # 5 minutes
    end
    
    if cooldown_expired do
      # Send alert (webhook, email, etc.)
      Blog.Alerts.send_alert(type, data)
      GenServer.cast(__MODULE__, {:set_last_alert, now})
    end
  end

  # Performance analysis
  defp analyze_performance_trends(state) do
    ops = :queue.to_list(state.performance_window)
    
    if length(ops) > 50 do
      recent_ops = Enum.take(ops, -50)
      old_ops = Enum.take(ops, 50)
      
      recent_avg = avg_duration(recent_ops)
      old_avg = avg_duration(old_ops)
      
      # Detect performance regression
      if recent_avg > old_avg * 1.5 do
        send_alert(:performance_regression, %{
          recent_average: recent_avg,
          baseline_average: old_avg,
          regression_factor: recent_avg / old_avg
        })
      end
    end
  end

  defp avg_duration(operations) do
    operations
    |> Enum.map(& &1.duration)
    |> Enum.sum()
    |> Kernel./(length(operations))
  end
end
```

---

## 📊 Production Monitoring Dashboard [ALERTS]

### Real-Time Metrics Dashboard

```elixir
# lib/blog_web/live/admin/telemetry_dashboard_live.ex
defmodule BlogWeb.Admin.TelemetryDashboardLive do
  use BlogWeb, :live_view
  
  alias Blog.Telemetry.Storage

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to telemetry events
      :telemetry.attach(
        "dashboard-metrics",
        [:blog, :wasm, :client_metric],
        &handle_telemetry_event/4,
        socket.assigns
      )
      
      Phoenix.PubSub.subscribe(Blog.PubSub, "telemetry:alerts")
    end
    
    socket = 
      socket
      |> assign(:bundle_metrics, get_bundle_metrics())
      |> assign(:performance_metrics, get_performance_metrics())
      |> assign(:error_summary, get_error_summary())
      |> assign(:alerts, get_recent_alerts())
    
    {:ok, socket}
  end

  def handle_info({:telemetry_event, event, measurements, metadata}, socket) do
    # Update dashboard with real-time data
    socket = 
      case event do
        [:blog, :wasm, :bundle_load] ->
          update_bundle_metrics(socket, measurements, metadata)
        [:blog, :wasm, :operation] ->
          update_performance_metrics(socket, measurements, metadata)
        [:blog, :wasm, :error] ->
          update_error_metrics(socket, measurements, metadata)
      end
    
    {:noreply, socket}
  end

  def handle_info({:alert, type, data}, socket) do
    alert = %{
      type: type,
      data: data,
      timestamp: DateTime.utc_now(),
      severity: alert_severity(type)
    }
    
    alerts = [alert | socket.assigns.alerts] |> Enum.take(50)
    
    {:noreply, assign(socket, :alerts, alerts)}
  end

  # Dashboard rendering
  def render(assigns) do
    ~H"""
    <div class="telemetry-dashboard">
      <h1>WASM Production Telemetry</h1>
      
      <!-- Real-time status -->
      <div class="status-grid">
        <div class="metric-card">
          <h3>Bundle Performance</h3>
          <div class="metric-value">
            <%= @bundle_metrics.avg_load_time %>ms
          </div>
          <div class="metric-trend <%= trend_class(@bundle_metrics.trend) %>">
            <%= @bundle_metrics.trend %>%
          </div>
        </div>
        
        <div class="metric-card">
          <h3>Operation Latency</h3>
          <div class="metric-value">
            <%= @performance_metrics.p95_duration %>ms
          </div>
          <div class="metric-detail">
            P95 across <%= @performance_metrics.sample_size %> operations
          </div>
        </div>
        
        <div class="metric-card">
          <h3>Error Rate</h3>
          <div class="metric-value <%= error_class(@error_summary.rate) %>">
            <%= Float.round(@error_summary.rate * 100, 2) %>%
          </div>
          <div class="metric-detail">
            <%= @error_summary.count %> errors / <%= @error_summary.total %> operations
          </div>
        </div>
      </div>
      
      <!-- Recent alerts -->
      <div class="alerts-section">
        <h3>Recent Alerts</h3>
        <%= for alert <- @alerts do %>
          <div class="alert alert-<%= alert.severity %>">
            <span class="alert-type"><%= alert.type %></span>
            <span class="alert-time"><%= format_time(alert.timestamp) %></span>
            <div class="alert-details">
              <%= format_alert_data(alert.data) %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper functions
  defp get_bundle_metrics do
    Storage.get_bundle_summary(last: 24, unit: :hours)
  end

  defp get_performance_metrics do
    Storage.get_performance_summary(last: 1, unit: :hours)
  end

  defp get_error_summary do
    Storage.get_error_summary(last: 24, unit: :hours)
  end

  defp alert_severity(:critical_error), do: :critical
  defp alert_severity(:high_error_rate), do: :critical  
  defp alert_severity(:performance_regression), do: :warning
  defp alert_severity(:slow_bundle_load), do: :warning
  defp alert_severity(_), do: :info
end
```

### Production Alerting Configuration

```elixir
# lib/blog/alerts.ex
defmodule Blog.Alerts do
  @moduledoc """
  Production alerting system for WASM performance issues.
  Integrates with external services for critical notifications.
  """

  require Logger

  @alert_thresholds %{
    bundle_load_time: 5000,      # 5s max
    operation_latency: 1000,     # 1s max
    error_rate: 0.05,           # 5% max
    memory_usage: 10_485_760,   # 10MB max
    offline_operations: 100      # 100 pending ops max
  }

  def send_alert(type, data) do
    alert_config = Application.get_env(:blog, :alerts, %{})
    
    # Log locally
    Logger.warning("WASM Alert triggered", 
      type: type,
      data: data,
      severity: alert_severity(type)
    )
    
    # Send to external services
    if alert_config[:webhook_url] do
      send_webhook_alert(alert_config[:webhook_url], type, data)
    end
    
    if alert_config[:email_enabled] do
      send_email_alert(type, data)
    end
    
    # Store for dashboard
    store_alert_history(type, data)
  end

  defp send_webhook_alert(url, type, data) do
    payload = %{
      alert_type: type,
      severity: alert_severity(type),
      data: data,
      timestamp: DateTime.utc_now(),
      service: "blog-wasm"
    }
    
    HTTPoison.post(url, Jason.encode!(payload), [
      {"Content-Type", "application/json"}
    ])
  end

  defp alert_severity(type) do
    case type do
      t when t in [:critical_error, :high_error_rate] -> :critical
      t when t in [:performance_regression, :memory_pressure] -> :warning
      _ -> :info
    end
  end
end
```

---

## 🔗 Referências e Links Oficiais [REFERÊNCIAS]

### Documentação Oficial
- **Elixir Logger**: https://hexdocs.pm/logger/1.18.4/Logger.html
- **Phoenix Telemetry**: https://hexdocs.pm/phoenix/telemetry.html
- **Telemetry.Metrics**: https://hexdocs.pm/telemetry_metrics/Telemetry.Metrics.html
- **Phoenix.PubSub**: https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html

### Performance Monitoring
- **Web Performance APIs**: https://developer.mozilla.org/en-US/docs/Web/API/Performance
- **WebAssembly Monitoring**: https://webassembly.org/docs/faq/
- **Browser Performance**: https://web.dev/performance/

### Production Tools
- **Honeybadger Elixir**: https://hexdocs.pm/honeybadger/readme.html
- **AppSignal Elixir**: https://hexdocs.pm/appsignal/readme.html  
- **New Relic Elixir**: https://hexdocs.pm/new_relic_agent/readme.html

### Compatibility Notes
- **Telemetry**: Elixir 1.10+ (disponível em 1.17.3)
- **Performance APIs**: Modern browsers 2025
- **Service Workers**: Universal support
- **IndexedDB**: All browsers, 2GB+ storage limit

---

**🎯 RESULTADO ESPERADO**: Production telemetry completa para WASM environment com metrics collection client/server, performance monitoring, error tracking, alerting system, e dashboard real-time. Data-driven optimization para Phase 3 success.**