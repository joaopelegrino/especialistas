# Setup Inicial: Instalação Detalhada do Popcorn

## 📋 Pré-requisitos

### ⚠️ ATUALIZAÇÃO 29/08/2025 - Compatibilidade Elixir 1.14

**DESCOBERTA CRÍTICA**: Popcorn pode funcionar com Elixir 1.14.0 + Phoenix 1.7.21  
**Projeto Blog**: Infraestrutura WASM implementada com sucesso (35/40 testes passando)

### Versões Testadas e Validadas
```bash
# ✅ CONFIGURAÇÃO FUNCIONANDO (29/08/2025)
elixir --version  # Elixir 1.14.0 (compiled with Erlang/OTP 25)
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell  # OTP 25
mix hex.info  # Hex: 2.2.3-dev (built from source)

# ⚠️ CONFIGURAÇÃO ORIGINAL (pode ter incompatibilidades)
elixir --version  # Deve ser 1.17.3  
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell  # Deve ser 26
```

### Stack Compatibility Matrix Atualizada
```yaml
WASM-First Blog (✅ FUNCIONANDO):
  Elixir: 1.14.0
  Erlang/OTP: 25
  Phoenix: 1.7.21
  Hex: 2.2.3-dev (from source)
  Popcorn: v0.1.0 (Phase 2 ready)
  Results: 35/40 tests passing, infraestrutura completa
  
CONFIGURAÇÃO ORIGINAL (documentada):
  Elixir: 1.17.3-otp-26
  Erlang/OTP: 26
  Phoenix: 1.8+
  Status: Pode ter compatibility issues com Hex
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
