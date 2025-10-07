# Healthcare CMS - REST API Patterns

> **Level**: 2 (Core) | **Read Time**: 25min | **Tokens**: ~8K
> **Audience**: Backend developers, API consumers
> **Last Validated**: 2025-09-30

---

## 📋 Overview

### API Architecture

```yaml
framework: Phoenix Framework 1.8.0
routing: Phoenix.Router with pipelines
controllers: Phoenix.Controller actions
authentication: Guardian JWT (stateless)
authorization: Zero Trust Policy Engine
format: JSON (default), HTML (web interface)
versioning: URL-based (/api/v1, /api/v2)
```

### Current Implementation Status

| Feature | Status | Sprint |
|---------|--------|--------|
| **Public Routes** | ✅ Implemented | 0-1 |
| **Authentication Routes** | ✅ Implemented | 0-2 |
| **Health Check Endpoint** | ✅ Implemented | 0-1 |
| **Protected Routes** | 🔄 Partial | 0-2 |
| **REST API (/api)** | 📋 Planned | 1-2 |
| **GraphQL API** | 📋 Planned | 2+ |

---

## 🛣️ Router Architecture

### Pipeline Structure

```elixir
# lib/healthcare_cms_web/router.ex
defmodule HealthcareCMSWeb.Router do
  use HealthcareCMSWeb, :router

  # Public pipeline (no authentication)
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HealthcareCMSWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_healthcare_context
    plug HealthcareCMSWeb.Plugs.AssignCurrentUser
  end

  # API pipeline (JWT authentication)
  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_zero_trust_context
  end

  # Protected pipeline (requires authentication)
  pipeline :authenticated do
    plug HealthcareCMSWeb.Plugs.RequireAuth
  end

  # Medical professional pipeline (requires CRM validation)
  pipeline :medical_professional do
    plug HealthcareCMSWeb.Plugs.RequireMedicalProfessional
  end
end
```

---

### Route Scopes

#### 1. Public Routes

```elixir
scope "/", HealthcareCMSWeb do
  pipe_through :browser

  get "/", PageController, :home
  get "/health", HealthController, :check
  get "/about", PageController, :about

  # Authentication
  get "/login", AuthController, :new
  post "/login", AuthController, :create
  get "/register", RegistrationController, :new
  post "/register", RegistrationController, :create
  delete "/logout", AuthController, :delete
end
```

---

#### 2. Protected Routes (Dashboard)

```elixir
scope "/dashboard", HealthcareCMSWeb do
  pipe_through [:browser, :authenticated]

  get "/", DashboardController, :index

  # Content Management
  resources "/posts", PostController
  resources "/categories", CategoryController
  resources "/media", MediaController

  # User Profile
  get "/profile", ProfileController, :show
  get "/profile/edit", ProfileController, :edit
  put "/profile", ProfileController, :update
end
```

---

#### 3. API Routes (REST)

```elixir
scope "/api/v1", HealthcareCMSWeb.API.V1, as: :api_v1 do
  pipe_through :api

  # Authentication
  post "/auth/login", AuthController, :login
  post "/auth/refresh", AuthController, :refresh
  delete "/auth/logout", AuthController, :logout

  # Public endpoints
  get "/posts", PostController, :index
  get "/posts/:id", PostController, :show
  get "/categories", CategoryController, :index

  # Protected endpoints (JWT required)
  scope "/" do
    pipe_through :authenticated

    # Posts
    post "/posts", PostController, :create
    put "/posts/:id", PostController, :update
    delete "/posts/:id", PostController, :delete

    # User
    get "/me", UserController, :show
    put "/me", UserController, :update
  end

  # Medical professional endpoints
  scope "/medical" do
    pipe_through [:authenticated, :medical_professional]

    post "/posts/:id/publish", PostController, :publish
    post "/posts/:id/validate", PostController, :validate_medical_content
  end
end
```

---

## 🎯 Controller Patterns

### Standard Controller Structure

```elixir
defmodule HealthcareCMSWeb.PostController do
  use HealthcareCMSWeb, :controller

  alias HealthcareCMS.Content
  alias HealthcareCMS.Content.Post

  # Action fallback for error handling
  action_fallback HealthcareCMSWeb.FallbackController

  # GET /posts
  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "10") |> String.to_integer()

    filters = [
      status: :published,
      order_by: :newest,
      limit: per_page,
      offset: (page - 1) * per_page
    ]

    posts = Content.list_posts(filters)
    total = Content.count_posts(status: :published)

    render(conn, "index.json",
      posts: posts,
      page: page,
      per_page: per_page,
      total: total
    )
  end

  # GET /posts/:id
  def show(conn, %{"id" => id}) do
    with {:ok, post} <- Content.get_post(id),
         :ok <- authorize_access(conn, post) do
      render(conn, "show.json", post: post)
    end
  end

  # POST /posts
  def create(conn, %{"post" => post_params}) do
    user = conn.assigns.current_user

    with {:ok, post} <- Content.create_post(user, post_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/posts/#{post.id}")
      |> render("show.json", post: post)
    end
  end

  # PUT /posts/:id
  def update(conn, %{"id" => id, "post" => post_params}) do
    with {:ok, post} <- Content.get_post(id),
         :ok <- authorize_access(conn, post),
         {:ok, updated_post} <- Content.update_post(post, post_params) do
      render(conn, "show.json", post: updated_post)
    end
  end

  # DELETE /posts/:id
  def delete(conn, %{"id" => id}) do
    with {:ok, post} <- Content.get_post(id),
         :ok <- authorize_access(conn, post),
         {:ok, _post} <- Content.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end

  # Authorization helper
  defp authorize_access(conn, post) do
    user = conn.assigns.current_user

    cond do
      post.author_id == user.id -> :ok
      user.role in [:administrator, :editor] -> :ok
      true -> {:error, :forbidden}
    end
  end
end
```

---

### Fallback Controller (Error Handling)

```elixir
defmodule HealthcareCMSWeb.FallbackController do
  use HealthcareCMSWeb, :controller

  # Not found
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:"404")
  end

  # Forbidden
  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:"403")
  end

  # Unauthorized
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render(:"401")
  end

  # Changeset validation errors
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render("changeset_errors.json", changeset: changeset)
  end

  # Generic error
  def call(conn, {:error, reason}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: HealthcareCMSWeb.ErrorJSON)
    |> render("500.json", reason: reason)
  end
end
```

---

### JSON Views

```elixir
defmodule HealthcareCMSWeb.PostJSON do
  alias HealthcareCMS.Content.Post

  # Render list of posts
  def index(%{posts: posts, page: page, per_page: per_page, total: total}) do
    %{
      data: Enum.map(posts, &data/1),
      pagination: %{
        page: page,
        per_page: per_page,
        total: total,
        total_pages: ceil(total / per_page)
      }
    }
  end

  # Render single post
  def show(%{post: post}) do
    %{data: data(post)}
  end

  # Post data structure
  defp data(%Post{} = post) do
    %{
      id: post.id,
      title: post.title,
      slug: post.slug,
      content: post.content,
      excerpt: post.excerpt,
      status: post.status,
      medical_category: post.medical_category,
      compliance_level: post.compliance_level,
      published_at: post.published_at,
      author: %{
        id: post.author.id,
        name: "#{post.author.first_name} #{post.author.last_name}",
        professional_registry: post.author.professional_registry
      },
      category: if(post.category, do: %{
        id: post.category.id,
        name: post.category.name,
        slug: post.category.slug
      }, else: nil),
      meta: %{
        reading_time: calculate_reading_time(post.content),
        word_count: count_words(post.content)
      }
    }
  end

  defp calculate_reading_time(content) do
    words = count_words(content)
    minutes = ceil(words / 200)  # 200 words per minute
    "#{minutes} min"
  end

  defp count_words(nil), do: 0
  defp count_words(content) do
    content
    |> String.split(~r/\s+/)
    |> length()
  end
end
```

---

## 🔒 Authentication Patterns

### JWT Authentication Flow

#### 1. Login Controller

```elixir
defmodule HealthcareCMSWeb.API.V1.AuthController do
  use HealthcareCMSWeb, :controller

  alias HealthcareCMS.Accounts
  alias HealthcareCMS.Security.PolicyEngine
  alias HealthcareCMSWeb.Guardian

  # POST /api/v1/auth/login
  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user(email, password),
         {:ok, _} <- Accounts.update_last_login(user),
         {:ok, trust_score} <- calculate_trust_score(conn, user),
         {:ok, token, claims} <- Guardian.encode_and_sign(user, %{
           trust_score: trust_score
         }) do

      conn
      |> put_status(:ok)
      |> render("login.json",
        token: token,
        user: user,
        trust_score: trust_score,
        expires_in: 900  # 15 minutes
      )
    else
      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: "Invalid email or password")

      {:error, :user_inactive} ->
        conn
        |> put_status(:forbidden)
        |> render("error.json", message: "Account inactive")
    end
  end

  # POST /api/v1/auth/refresh
  def refresh(conn, %{"token" => token}) do
    with {:ok, _old_claims} <- Guardian.decode_and_verify(token),
         {:ok, _old_token, {new_token, new_claims}} <- Guardian.refresh(token) do
      render(conn, "token.json", token: new_token, claims: new_claims)
    else
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: "Invalid or expired token")
    end
  end

  # DELETE /api/v1/auth/logout
  def logout(conn, _params) do
    token = Guardian.Plug.current_token(conn)

    with {:ok, _claims} <- Guardian.revoke(token) do
      send_resp(conn, :no_content, "")
    end
  end

  defp calculate_trust_score(conn, user) do
    context = %{
      device_info: get_device_info(conn),
      location: get_location_info(conn),
      time_info: %{business_hours: true}
    }

    subject = %{
      id: user.id,
      auth_method: if(user.mfa_enabled, do: :mfa_enabled, else: :password_only),
      professional_data: %{
        validated: user.registry_verified,
        crm: user.professional_registry
      }
    }

    score = PolicyEngine.calculate_trust_score(subject, context)
    {:ok, score}
  end

  defp get_device_info(conn) do
    user_agent = get_req_header(conn, "user-agent") |> List.first()
    %{
      user_agent: user_agent,
      trusted: false  # Device fingerprinting TODO
    }
  end

  defp get_location_info(conn) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    %{
      ip_address: ip
    }
  end
end
```

---

### Auth Plugs

#### RequireAuth Plug

```elixir
defmodule HealthcareCMSWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias HealthcareCMSWeb.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: HealthcareCMSWeb.ErrorJSON)
        |> render(:"401")
        |> halt()

      user ->
        assign(conn, :current_user, user)
    end
  end
end
```

---

#### RequireMedicalProfessional Plug

```elixir
defmodule HealthcareCMSWeb.Plugs.RequireMedicalProfessional do
  import Plug.Conn
  import Phoenix.Controller

  alias HealthcareCMS.Accounts.User

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && User.medical_professional?(user) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> put_view(json: HealthcareCMSWeb.ErrorJSON)
      |> render(:"403")
      |> halt()
    end
  end
end
```

---

## 🏥 Health Check Endpoint

### Implementation

```elixir
defmodule HealthcareCMSWeb.HealthController do
  use HealthcareCMSWeb, :controller

  alias HealthcareCMS.Repo

  # GET /health
  def check(conn, _params) do
    checks = %{
      database: check_database(),
      policy_engine: check_policy_engine(),
      memory: check_memory()
    }

    status = if Enum.all?(checks, fn {_k, v} -> v == :ok end),
      do: "healthy",
      else: "degraded"

    json(conn, %{
      status: status,
      checks: checks,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      version: Application.spec(:healthcare_cms, :vsn) |> to_string()
    })
  end

  defp check_database do
    case Repo.query("SELECT 1", [], timeout: 5_000) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  defp check_policy_engine do
    case Process.whereis(HealthcareCMS.Security.PolicyEngine) do
      nil -> :error
      _pid -> :ok
    end
  end

  defp check_memory do
    memory = :erlang.memory()
    usage_percent = memory[:system] / memory[:total] * 100

    if usage_percent < 90, do: :ok, else: :warning
  end
end
```

### Response Format

**Healthy**:
```json
{
  "status": "healthy",
  "checks": {
    "database": "ok",
    "policy_engine": "ok",
    "memory": "ok"
  },
  "timestamp": "2025-09-30T14:30:00Z",
  "version": "0.1.0"
}
```

**Degraded**:
```json
{
  "status": "degraded",
  "checks": {
    "database": "error",
    "policy_engine": "ok",
    "memory": "warning"
  },
  "timestamp": "2025-09-30T14:30:00Z",
  "version": "0.1.0"
}
```

---

## 📊 API Response Patterns

### Success Responses

#### Single Resource
```json
{
  "data": {
    "id": "uuid",
    "title": "Como Prevenir Doenças Cardíacas",
    "slug": "como-prevenir-doencas-cardiacas",
    "content": "...",
    "status": "published",
    "published_at": "2025-09-30T14:30:00Z"
  }
}
```

#### Collection
```json
{
  "data": [
    {"id": "uuid1", "title": "Post 1", ...},
    {"id": "uuid2", "title": "Post 2", ...}
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 45,
    "total_pages": 5
  }
}
```

---

### Error Responses

#### Validation Errors (422)
```json
{
  "errors": {
    "title": ["can't be blank"],
    "content": ["can't be blank"],
    "medical_disclaimer": ["é obrigatório para conteúdo médico profissional"]
  }
}
```

#### Not Found (404)
```json
{
  "error": "Resource not found",
  "message": "Post with ID 'invalid-uuid' not found"
}
```

#### Unauthorized (401)
```json
{
  "error": "Unauthorized",
  "message": "Authentication required"
}
```

#### Forbidden (403)
```json
{
  "error": "Forbidden",
  "message": "You don't have permission to access this resource"
}
```

---

## 🧪 API Testing

### ExUnit Controller Tests

```elixir
defmodule HealthcareCMSWeb.PostControllerTest do
  use HealthcareCMSWeb.ConnCase

  import HealthcareCMS.Factory

  alias HealthcareCMS.Content

  setup %{conn: conn} do
    user = insert(:user, :medical_professional)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    conn = conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, conn: conn, user: user}
  end

  describe "GET /api/v1/posts" do
    test "lists all published posts", %{conn: conn} do
      insert_list(3, :post, status: :published)
      insert(:post, status: :draft)  # Should not appear

      conn = get(conn, ~p"/api/v1/posts")

      assert json_response(conn, 200)["data"] |> length() == 3
    end

    test "paginates results", %{conn: conn} do
      insert_list(25, :post, status: :published)

      conn = get(conn, ~p"/api/v1/posts?page=2&per_page=10")
      response = json_response(conn, 200)

      assert length(response["data"]) == 10
      assert response["pagination"]["page"] == 2
      assert response["pagination"]["total_pages"] == 3
    end
  end

  describe "POST /api/v1/posts" do
    test "creates post with valid data", %{conn: conn, user: user} do
      attrs = %{
        title: "Test Post",
        content: "Test content",
        status: "draft",
        medical_category: "cardiology",
        compliance_level: "professional",
        medical_disclaimer: "Professional content only"
      }

      conn = post(conn, ~p"/api/v1/posts", post: attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert Content.get_post!(id).title == "Test Post"
    end

    test "returns errors for invalid data", %{conn: conn} do
      attrs = %{title: "", content: ""}

      conn = post(conn, ~p"/api/v1/posts", post: attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "DELETE /api/v1/posts/:id" do
    test "deletes own post", %{conn: conn, user: user} do
      post = insert(:post, author: user)

      conn = delete(conn, ~p"/api/v1/posts/#{post.id}")

      assert response(conn, 204)
      assert Content.get_post!(post.id).status == :deleted
    end

    test "forbids deleting other's post", %{conn: conn} do
      other_user = insert(:user)
      post = insert(:post, author: other_user)

      conn = delete(conn, ~p"/api/v1/posts/#{post.id}")

      assert json_response(conn, 403)
    end
  end
end
```

---

## 🔗 Related Documentation

- **Accounts Context**: `../contexts/accounts-context.md`
- **Content Context**: `../contexts/content-context.md`
- **Security / Zero Trust**: `../security/zero-trust-implementation.md`
- **Guardian JWT Auth**: `../../architecture/decisions-adr/005-guardian-jwt-auth.md`
- **Main Workflows**: `../../layer-1-overview/main-workflows.md` (Authentication workflow)

---

## 🚧 Roadmap

### Sprint 1 (Current)
- [x] Router architecture design
- [x] Health check endpoint
- [x] Authentication patterns
- [ ] Complete REST API implementation
- [ ] API documentation (OpenAPI/Swagger)

### Sprint 2
- [ ] GraphQL API (Absinthe)
- [ ] Rate limiting (Hammer)
- [ ] API versioning strategy
- [ ] WebSocket channels (Phoenix Channels)

### Sprint 3+
- [ ] API client libraries (JavaScript, Python)
- [ ] Webhook system
- [ ] Batch operations API
- [ ] Real-time subscriptions (Phoenix PubSub)

---

**Version**: 1.0.0 | **Created**: 2025-09-30 | **Status**: 🔄 Active Development
