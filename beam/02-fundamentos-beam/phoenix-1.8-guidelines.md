# Phoenix 1.8 Guidelines - Boas Práticas Essenciais

[ESSENCIAL] [PHOENIX-18]

## 🎯 Layouts.app e Sistema de Flash (Linhas 10-40)

[ESSENCIAL] [SEMPRE-USE]
### Estrutura Correta de LiveView Templates
```elixir
# ✅ SEMPRE comece templates LiveView com Layouts.app
def render(assigns) do
  ~H"""
  <Layouts.app flash={@flash} current_scope={@current_scope}>
    <div class="container">
      <!-- Seu conteúdo aqui -->
    </div>
  </Layouts.app>
  """
end

# ❌ NUNCA omita o Layouts.app
def render(assigns) do
  ~H"""
  <div class="container">
    <!-- Isso vai causar problemas com flash e layout -->
  </div>
  """
end
```

### Flash Messages no Phoenix 1.8
```elixir
# ✅ Flash group está em Layouts, NÃO em core_components
# Em lib/app_web/components/layouts.ex
def app(assigns) do
  ~H"""
  <main>
    <.flash_group flash={@flash} />
    <%= @inner_content %>
  </main>
  """
end

# ❌ NUNCA chame flash_group fora de layouts.ex
```

## ⚠️ current_scope vs current_user (Linhas 41-80)

[ERRO-COMUM] [CRITICO]
### O Erro Mais Comum em Phoenix 1.8
```elixir
# ❌ ERRO COMUM - NÃO existe @current_user
<%= @current_user.name %>  # ERRO! Undefined assign

# ✅ CORRETO - Use @current_scope.user
<%= @current_scope.user.name %>

# No LiveView mount
def mount(_params, session, socket) do
  # current_scope vem do plug :fetch_current_user
  socket = assign(socket, :current_scope, session["current_scope"])
  {:ok, socket}
end
```

### Verificação de Autenticação
```elixir
# ✅ Pattern correto para verificar se usuário está logado
<%= if @current_scope do %>
  <div>Olá, <%= @current_scope.user.name %></div>
  <.link href={~p"/logout"} method="delete">Sair</.link>
<% else %>
  <.link href={~p"/login"}>Entrar</.link>
<% end %>
```

## 🔐 Rotas Autenticadas (Linhas 81-120)

[BEST-PRACTICE] [SEGURANCA]
### Organização Correta de Rotas
```elixir
# router.ex
defmodule AppWeb.Router do
  use AppWeb, :router

  import AppWeb.UserAuth  # phx.gen.auth cria isso

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user  # Sempre presente
  end

  # Rotas públicas
  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/products", ProductLive.Index, :index
  end

  # Rotas que requerem autenticação
  scope "/", AppWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/dashboard", DashboardLive, :index
    live "/profile", ProfileLive, :edit
  end

  # Rotas apenas para não-autenticados
  scope "/", AppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/register", UserRegistrationController, :new
    post "/register", UserRegistrationController, :create
    get "/login", UserSessionController, :new
    post "/login", UserSessionController, :create
  end
end
```

## 📦 LiveSession para LiveViews (Linhas 121-180)

[TEMPLATE] [LIVE-SESSION]
### Configuração de live_session
```elixir
# ✅ MELHOR PRÁTICA - Agrupar LiveViews em live_session
scope "/", AppWeb do
  pipe_through [:browser, :require_authenticated_user]

  live_session :authenticated,
    on_mount: [{AppWeb.UserAuth, :ensure_authenticated}] do
    
    live "/dashboard", DashboardLive, :index
    live "/settings", SettingsLive, :index
    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Form, :new
    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/edit", PostLive.Form, :edit
  end
end

# No UserAuth
def on_mount(:ensure_authenticated, _params, session, socket) do
  socket = assign_current_user(socket, session)
  
  if socket.assigns.current_scope do
    {:cont, socket}
  else
    socket =
      socket
      |> Phoenix.LiveView.put_flash(:error, "Você precisa estar logado")
      |> Phoenix.LiveView.redirect(to: "/login")
    
    {:halt, socket}
  end
end
```

## 🎨 Componentes e Icons (Linhas 181-220)

[BEST-PRACTICE] [COMPONENTES]
### Uso Correto de Icons
```elixir
# ✅ SEMPRE use o componente <.icon> do core_components
<.icon name="hero-x-mark" class="w-5 h-5" />
<.icon name="hero-arrow-left" class="w-6 h-6 text-gray-500" />

# ❌ NUNCA importe ou use módulos Heroicons diretamente
<Heroicons.x_mark />  # NÃO FAÇA ISSO!
```

### Input Components
```elixir
# ✅ SEMPRE use <.input> do core_components
<.form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} type="text" label="Nome" />
  <.input field={@form[:email]} type="email" label="Email" />
  <.input field={@form[:age]} type="number" label="Idade" />
  <.button>Salvar</.button>
</.form>

# ❌ EVITE HTML direto quando componente existe
<input type="text" name="user[name]" />  # Evite
```

## 🔄 Navegação em LiveView

[IMPORTANTE] [NAVEGACAO]
### Métodos Atualizados de Navegação
```elixir
# ❌ DEPRECATED - Não use mais
<%= live_redirect "Link", to: "/path" %>
<%= live_patch "Link", to: "/path" %>

# ✅ NOVO em Phoenix 1.8
# Em templates
<.link navigate={~p"/products"}>Ver Produtos</.link>
<.link patch={~p"/products/#{@product}/edit"}>Editar</.link>

# Em LiveView handlers
def handle_event("save", params, socket) do
  socket
  |> put_flash(:info, "Salvo com sucesso!")
  |> push_navigate(to: ~p"/products")  # Navegação completa
  
  # ou
  
  |> push_patch(to: ~p"/products/#{product}")  # Atualiza URL sem recarregar
end
```

## 🏗️ Scopes e Aliases no Router

[ERRO-COMUM] [ROUTER]
### Entenda os Aliases Automáticos
```elixir
# ✅ CORRETO - Scope adiciona prefixo automaticamente
scope "/admin", AppWeb.Admin do
  pipe_through [:browser, :require_admin]
  
  live "/users", UserLive, :index  # Aponta para AppWeb.Admin.UserLive
  live "/posts", PostLive, :index  # Aponta para AppWeb.Admin.PostLive
end

# ❌ ERRO COMUM - Alias duplicado
scope "/admin", AppWeb.Admin do
  pipe_through :browser
  
  # NÃO FAÇA ISSO - resulta em AppWeb.Admin.Admin.UserLive
  alias AppWeb.Admin
  live "/users", Admin.UserLive, :index  
end
```

## 📝 Mix Tasks e Generators

[DESENVOLVIMENTO] [TOOLS]
### Generators Úteis do Phoenix 1.8
```bash
# Gerar autenticação completa
mix phx.gen.auth Accounts User users

# Gerar LiveView CRUD
mix phx.gen.live Blog Post posts title:string body:text user_id:references:users

# Gerar contexto com schema
mix phx.gen.context Blog Category categories name:string slug:unique

# Gerar componente
mix phx.gen.component Button
```

## 🐛 Troubleshooting Comum

[DEBUG] [SOLUCOES]
### Erro: No current_scope assign
```elixir
# CAUSA: Rota no scope errado ou plug não aplicado

# SOLUÇÃO 1: Verificar pipeline
pipe_through [:browser, :require_authenticated_user]

# SOLUÇÃO 2: Passar current_scope para Layouts.app
<Layouts.app current_scope={@current_scope} flash={@flash}>

# SOLUÇÃO 3: Verificar on_mount no live_session
live_session :authenticated,
  on_mount: [{AppWeb.UserAuth, :ensure_authenticated}] do
```

### Erro: Phoenix.HTML.Form deprecated
```elixir
# ❌ ANTIGO - Phoenix < 1.7
<%= form_for @changeset, "#", fn f -> %>
  <%= text_input f, :name %>
<% end %>

# ✅ NOVO - Phoenix 1.8
<.form for={@form} phx-submit="save">
  <.input field={@form[:name]} />
</.form>
```

## 📊 Performance Tips

[OTIMIZACAO]
### LiveView Otimizado
```elixir
# Use temporary assigns para dados grandes
def mount(_params, _session, socket) do
  socket =
    socket
    |> assign(:large_list, load_data())
    |> temporary_assigns(large_list: [])
  
  {:ok, socket}
end

# Use streams para coleções
socket
|> stream(:messages, messages)
|> stream_insert(:messages, new_message, at: 0)
```

---
**[NAVEGACAO]** Use CTRL+F com as tags para encontrar soluções rápidas!