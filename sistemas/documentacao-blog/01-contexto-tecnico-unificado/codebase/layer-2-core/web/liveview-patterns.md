# LiveView Patterns - Healthcare CMS Blog

**DSM**: `L1_DOMAIN:ui_ux` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:implementation`
**Layer**: 2 (Core) - Phoenix LiveView Real-Time Patterns
**Status**: 🚧 Planned (Sprint 0-3+)
**Read Time**: ~25 minutes
**Codebase Evidence**: `router.ex`, Phoenix LiveView 1.0.1 dependency

---

## Overview

**Phoenix LiveView** enables real-time, server-rendered interactive user interfaces without writing JavaScript. For Healthcare CMS, LiveView provides:

1. **Real-time updates**: Medical content status changes, approval workflows
2. **Zero-latency UI**: Optimistic updates with server validation
3. **Stateful connections**: WebSocket-based bidirectional communication
4. **Security by default**: CSRF protection, session validation
5. **Accessibility**: Server-rendered HTML with progressive enhancement

**Current Status**: LiveView routes are commented out in router (Sprint 0-3). Planned implementation includes Post management, Category management, and Medical workflow dashboards.

---

## LiveView Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    LiveView Lifecycle                        │
└─────────────────────────────────────────────────────────────┘

1. HTTP Request → mount/3 (disconnected mode)
   ├─ Load initial data
   ├─ Assign socket state
   └─ Render static HTML

2. WebSocket Connect → mount/3 (connected mode)
   ├─ Re-run mount with connected socket
   ├─ Subscribe to PubSub topics
   ├─ Initialize stateful processes
   └─ Render live HTML

3. User Interaction → handle_event/3
   ├─ Validate input
   ├─ Update socket assigns
   ├─ Broadcast changes (if needed)
   └─ Re-render affected parts (diff-based)

4. External Updates → handle_info/2
   ├─ Receive PubSub messages
   ├─ Update socket state
   └─ Re-render

5. Navigation → handle_params/3
   ├─ URL parameter changes
   ├─ Update assigns based on params
   └─ Re-render

6. Disconnection → terminate/2
   ├─ Clean up resources
   └─ Unsubscribe from topics
```

---

## Planned Router Configuration

From `lib/healthcare_cms_web/router.ex` (currently commented out):

```elixir
# Protected routes (Sprint 0-3+)
scope "/dashboard", HealthcareCMSWeb do
  pipe_through [:browser, :authenticated]

  get "/", PageController, :dashboard

  # Content management LiveViews
  live "/posts", PostLive.Index, :index
  live "/posts/new", PostLive.Index, :new
  live "/posts/:id/edit", PostLive.Index, :edit
  live "/posts/:id", PostLive.Show, :show

  # Category management (future)
  live "/categories", CategoryLive.Index, :index
  live "/categories/new", CategoryLive.Index, :new

  # Medical workflow dashboard (future)
  live "/workflows", WorkflowLive.Dashboard, :index
  live "/workflows/:id", WorkflowLive.Detail, :show
end
```

**Pipeline Requirements**:
- **`:browser`**: Standard Phoenix browser pipeline (CSRF, sessions, flash)
- **`:authenticated`**: `HealthcareCMSWeb.Plugs.RequireAuth` ensures logged-in user
- **`fetch_live_flash`**: Required plug for LiveView flash messages

---

## LiveView Structure Pattern

### Basic LiveView Module

```elixir
defmodule HealthcareCMSWeb.PostLive.Index do
  use HealthcareCMSWeb, :live_view

  alias HealthcareCMS.Content
  alias HealthcareCMS.Content.Post

  @impl true
  def mount(_params, session, socket) do
    # Authentication check (if not using pipeline)
    socket = assign_current_user(socket, session)

    if socket.assigns.current_user do
      # Subscribe to real-time updates
      if connected?(socket) do
        Phoenix.PubSub.subscribe(HealthcareCMS.PubSub, "posts:tenant:#{socket.assigns.current_user.tenant_id}")
      end

      # Load initial data
      posts = Content.list_posts(tenant_id: socket.assigns.current_user.tenant_id)

      {:ok, assign(socket, posts: posts, page_title: "Posts")}
    else
      {:ok, redirect(socket, to: "/login")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Content.get_post!(id, tenant_id: socket.assigns.current_user.tenant_id)

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Content.get_post!(id, tenant_id: socket.assigns.current_user.tenant_id)

    case Content.delete_post(post) do
      {:ok, _post} ->
        # Broadcast deletion to other connected users
        Phoenix.PubSub.broadcast(
          HealthcareCMS.PubSub,
          "posts:tenant:#{socket.assigns.current_user.tenant_id}",
          {:post_deleted, id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Post deleted successfully")
         |> assign(:posts, Content.list_posts(tenant_id: socket.assigns.current_user.tenant_id))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete post")}
    end
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    # Another user created a post - update list
    {:noreply, assign(socket, :posts, [post | socket.assigns.posts])}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    # Another user updated a post - refresh list
    updated_posts =
      Enum.map(socket.assigns.posts, fn p ->
        if p.id == post.id, do: post, else: p
      end)

    {:noreply, assign(socket, :posts, updated_posts)}
  end

  @impl true
  def handle_info({:post_deleted, post_id}, socket) do
    # Another user deleted a post - remove from list
    updated_posts = Enum.reject(socket.assigns.posts, fn p -> p.id == post_id end)

    {:noreply,
     socket
     |> put_flash(:info, "Post was deleted by another user")
     |> assign(:posts, updated_posts)}
  end
end
```

---

## LiveView Template Pattern (HEEx)

### index.html.heex

```heex
<div class="posts-index">
  <.header>
    Listing Posts
    <:actions>
      <.link patch={~p"/dashboard/posts/new"}>
        <.button>New Post</.button>
      </.link>
    </:actions>
  </.header>

  <.table id="posts" rows={@posts} row_click={&JS.navigate(~p"/dashboard/posts/#{&1.id}")}>
    <:col :let={post} label="Title"><%= post.title %></:col>
    <:col :let={post} label="Status">
      <.badge color={status_color(post.status)}>
        <%= humanize_status(post.status) %>
      </.badge>
    </:col>
    <:col :let={post} label="Medical Category">
      <%= if post.medical_category do %>
        <.badge color="blue"><%= humanize(post.medical_category) %></.badge>
      <% else %>
        <span class="text-gray-400">General</span>
      <% end %>
    </:col>
    <:col :let={post} label="Compliance">
      <.compliance_badge level={post.compliance_level} />
    </:col>
    <:col :let={post} label="Workflow">
      <%= post.workflow_stage || "N/A" %>
    </:col>
    <:action :let={post}>
      <.link patch={~p"/dashboard/posts/#{post.id}/edit"}>Edit</.link>
    </:action>
    <:action :let={post}>
      <.link phx-click="delete" phx-value-id={post.id} data-confirm="Are you sure?">
        Delete
      </.link>
    </:action>
  </.table>

  <.modal
    :if={@live_action in [:new, :edit]}
    id="post-modal"
    show
    on_cancel={JS.patch(~p"/dashboard/posts")}
  >
    <.live_component
      module={HealthcareCMSWeb.PostLive.FormComponent}
      id={@post.id || :new}
      title={@page_title}
      action={@live_action}
      post={@post}
      current_user={@current_user}
      patch={~p"/dashboard/posts"}
    />
  </.modal>
</div>
```

**Key HEEx Features**:
- **`<.component>`**: Function component syntax
- **`{@variable}`**: Access socket assigns
- **`phx-click`**: Trigger server-side events
- **`:if` / `:for`**: Conditional rendering / loops
- **`patch={}`**: Client-side navigation (preserves LiveView)
- **`navigate={}`**: Server-side navigation (new LiveView)

---

## LiveComponent Pattern (Reusable Stateful Components)

### FormComponent (Modal Form)

```elixir
defmodule HealthcareCMSWeb.PostLive.FormComponent do
  use HealthcareCMSWeb, :live_component

  alias HealthcareCMS.Content

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Content.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Content.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  defp save_post(socket, :edit, post_params) do
    case Content.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        # Broadcast update to other users
        Phoenix.PubSub.broadcast(
          HealthcareCMS.PubSub,
          "posts:tenant:#{socket.assigns.current_user.tenant_id}",
          {:post_updated, post}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    # Add tenant_id and author_id
    post_params =
      post_params
      |> Map.put("tenant_id", socket.assigns.current_user.tenant_id)
      |> Map.put("author_id", socket.assigns.current_user.id)

    case Content.create_post(post_params) do
      {:ok, post} ->
        # Broadcast creation to other users
        Phoenix.PubSub.broadcast(
          HealthcareCMS.PubSub,
          "posts:tenant:#{socket.assigns.current_user.tenant_id}",
          {:post_created, post}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@changeset}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@changeset[:title]} type="text" label="Title" required />
        <.input field={@changeset[:content]} type="textarea" label="Content" rows="10" required />
        <.input
          field={@changeset[:status]}
          type="select"
          label="Status"
          options={[:draft, :published, :archived]}
          required
        />
        <.input
          field={@changeset[:medical_category]}
          type="select"
          label="Medical Category"
          options={medical_category_options()}
          prompt="Select category (optional)"
        />
        <.input
          field={@changeset[:compliance_level]}
          type="select"
          label="Compliance Level"
          options={[:public, :professional, :restricted, :phi]}
          required
        />

        <%= if @changeset.changes[:medical_category] do %>
          <.input
            field={@changeset[:medical_disclaimer]}
            type="textarea"
            label="Medical Disclaimer (Required)"
            placeholder="Este conteúdo é apenas informativo..."
            required
          />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp medical_category_options do
    [
      {"General", :general},
      {"Cardiology", :cardiology},
      {"Neurology", :neurology},
      {"Pediatrics", :pediatrics},
      {"Surgery", :surgery},
      {"Pharmacy", :pharmacy},
      {"Radiology", :radiology},
      {"Laboratory", :laboratory},
      {"Emergency", :emergency},
      {"Preventive", :preventive}
    ]
  end
end
```

**LiveComponent Key Features**:
- **`phx-target={@myself}`**: Scope events to this component
- **`update/2`**: Initialize component state
- **`handle_event/3`**: Handle component-specific events
- **Isolated state**: Each component instance has separate state

---

## Real-Time PubSub Pattern

### Broadcasting Updates

```elixir
# After creating/updating/deleting a post
Phoenix.PubSub.broadcast(
  HealthcareCMS.PubSub,
  "posts:tenant:#{tenant_id}",
  {:post_created, post}
)
```

### Subscribing in mount/3

```elixir
def mount(_params, session, socket) do
  if connected?(socket) do
    # Only subscribe after WebSocket connection (not during initial HTTP render)
    Phoenix.PubSub.subscribe(
      HealthcareCMS.PubSub,
      "posts:tenant:#{socket.assigns.current_user.tenant_id}"
    )
  end

  {:ok, assign(socket, posts: load_posts())}
end
```

### Handling Broadcasts

```elixir
def handle_info({:post_created, post}, socket) do
  {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
end

def handle_info({:post_updated, updated_post}, socket) do
  {:noreply,
   update(socket, :posts, fn posts ->
     Enum.map(posts, fn p ->
       if p.id == updated_post.id, do: updated_post, else: p
     end)
   end)}
end
```

---

## Healthcare-Specific Patterns

### 1. Medical Workflow Dashboard

```elixir
defmodule HealthcareCMSWeb.WorkflowLive.Dashboard do
  use HealthcareCMSWeb, :live_view

  alias HealthcareCMS.Workflows

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to workflow updates
      Phoenix.PubSub.subscribe(
        HealthcareCMS.PubSub,
        "workflows:tenant:#{socket.assigns.current_user.tenant_id}"
      )

      # Poll for workflow status every 30 seconds
      :timer.send_interval(30_000, self(), :refresh_workflows)
    end

    workflows = Workflows.list_active_workflows(socket.assigns.current_user.tenant_id)

    {:ok,
     assign(socket,
       workflows: workflows,
       stats: calculate_stats(workflows)
     )}
  end

  @impl true
  def handle_info(:refresh_workflows, socket) do
    workflows = Workflows.list_active_workflows(socket.assigns.current_user.tenant_id)

    {:noreply,
     assign(socket,
       workflows: workflows,
       stats: calculate_stats(workflows)
     )}
  end

  @impl true
  def handle_info({:workflow_state_changed, workflow_id, new_state}, socket) do
    # Real-time workflow state update
    updated_workflows =
      Enum.map(socket.assigns.workflows, fn w ->
        if w.id == workflow_id do
          %{w | state: new_state}
        else
          w
        end
      end)

    {:noreply,
     socket
     |> assign(:workflows, updated_workflows)
     |> assign(:stats, calculate_stats(updated_workflows))
     |> put_flash(:info, "Workflow #{workflow_id} changed to #{new_state}")}
  end

  defp calculate_stats(workflows) do
    %{
      total: length(workflows),
      pending_lgpd: count_by_stage(workflows, "S.2.1"),
      pending_medical: count_by_stage(workflows, "S.3.1"),
      pending_cfm: count_by_stage(workflows, "S.4-1.1-3"),
      completed: count_by_state(workflows, :completed)
    }
  end
end
```

### 2. Zero Trust Access Control in LiveView

```elixir
defmodule HealthcareCMSWeb.PostLive.Index do
  use HealthcareCMSWeb, :live_view

  alias HealthcareCMS.Security.PolicyEngine

  @impl true
  def mount(_params, _session, socket) do
    # Evaluate Zero Trust policy for this resource
    subject = %{
      id: socket.assigns.current_user.id,
      tenant_id: socket.assigns.current_user.tenant_id,
      auth_method: socket.assigns.current_user.auth_method,
      professional_data: socket.assigns.current_user.professional_data
    }

    resource = %{
      id: "post_management",
      contains_phi: false,
      admin_function: false
    }

    context = build_request_context(socket)

    case PolicyEngine.evaluate_access_request(subject, resource, context) do
      {:allow, access_level} ->
        posts = load_posts(socket.assigns.current_user, access_level)
        {:ok, assign(socket, posts: posts, access_level: access_level)}

      {:deny, reason} ->
        {:ok,
         socket
         |> put_flash(:error, "Access denied: #{reason}")
         |> redirect(to: "/dashboard")}
    end
  end

  defp build_request_context(socket) do
    %{
      device_info: %{
        user_agent: get_connect_info(socket, :user_agent),
        ip_address: get_connect_info(socket, :peer_data).address
      },
      time_info: %{
        timestamp: System.system_time(:millisecond),
        business_hours: is_business_hours?()
      }
    }
  end
end
```

### 3. LGPD Consent Management LiveView

```elixir
defmodule HealthcareCMSWeb.ConsentLive.Manager do
  use HealthcareCMSWeb, :live_view

  alias HealthcareCMS.Accounts.Consent

  @impl true
  def mount(_params, _session, socket) do
    consents = Consent.list_user_consents(socket.assigns.current_user.id)

    {:ok,
     assign(socket,
       consents: consents,
       available_purposes: Consent.list_purposes()
     )}
  end

  @impl true
  def handle_event("grant_consent", %{"purpose" => purpose}, socket) do
    case Consent.grant_consent(socket.assigns.current_user.id, purpose) do
      {:ok, consent} ->
        # Log consent grant for LGPD audit trail
        log_consent_action(socket.assigns.current_user.id, :granted, purpose)

        {:noreply,
         socket
         |> put_flash(:info, "Consent granted for #{purpose}")
         |> update(:consents, fn consents -> [consent | consents] end)}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to grant consent")}
    end
  end

  @impl true
  def handle_event("revoke_consent", %{"id" => consent_id}, socket) do
    consent = Consent.get_consent!(consent_id)

    case Consent.revoke_consent(consent) do
      {:ok, updated_consent} ->
        # Log revocation for LGPD compliance (Art. 8)
        log_consent_action(socket.assigns.current_user.id, :revoked, consent.purpose)

        {:noreply,
         socket
         |> put_flash(:info, "Consent revoked")
         |> assign(:consents, Consent.list_user_consents(socket.assigns.current_user.id))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to revoke consent")}
    end
  end

  defp log_consent_action(user_id, action, purpose) do
    # Audit trail for LGPD compliance
    HealthcareCMS.AuditLog.log(%{
      user_id: user_id,
      action: action,
      resource_type: "consent",
      resource_id: purpose,
      timestamp: DateTime.utc_now(),
      compliance_framework: "LGPD"
    })
  end
end
```

---

## Performance Optimization Patterns

### 1. Stream Large Collections

```elixir
def mount(_params, _session, socket) do
  # For large datasets, use Phoenix.LiveView.stream/4
  {:ok,
   socket
   |> assign(:page_title, "All Posts")
   |> stream(:posts, Content.list_posts(), at: 0)}
end

# In template:
<div id="posts" phx-update="stream">
  <div
    :for={{dom_id, post} <- @streams.posts}
    id={dom_id}
    class="post-item"
  >
    <%= post.title %>
  </div>
</div>
```

**Benefits**:
- Only sends diffs over WebSocket (not entire list)
- Efficient for 1000+ items
- Automatic DOM patching

### 2. Debounce User Input

```heex
<.input
  field={@changeset[:search_query]}
  type="text"
  placeholder="Search posts..."
  phx-change="search"
  phx-debounce="300"
/>
```

**Effect**: Only triggers `handle_event("search", ...)` after 300ms of no typing.

### 3. Temporary Assigns (Memory Optimization)

```elixir
def mount(_params, _session, socket) do
  socket = assign(socket, :posts, load_posts())

  # Don't keep posts in memory after rendering
  {:ok, socket, temporary_assigns: [posts: []]}
end
```

**Use Case**: Large datasets that don't need to persist in socket state.

---

## Testing LiveView

### Example Test

```elixir
defmodule HealthcareCMSWeb.PostLive.IndexTest do
  use HealthcareCMSWeb.ConnCase

  import Phoenix.LiveViewTest
  alias HealthcareCMS.Content

  test "lists all posts", %{conn: conn} do
    # Create test data
    user = insert(:user, tenant_id: "tenant-1")
    post = insert(:post, title: "Test Post", tenant_id: "tenant-1", author_id: user.id)

    # Authenticate
    conn = log_in_user(conn, user)

    # Mount LiveView
    {:ok, _index_live, html} = live(conn, ~p"/dashboard/posts")

    assert html =~ "Listing Posts"
    assert html =~ "Test Post"
  end

  test "creates new post", %{conn: conn} do
    user = insert(:user, tenant_id: "tenant-1")
    conn = log_in_user(conn, user)

    {:ok, index_live, _html} = live(conn, ~p"/dashboard/posts")

    # Click "New Post" button
    assert index_live
           |> element("a", "New Post")
           |> render_click() =~ "New Post"

    # Fill form
    assert index_live
           |> form("#post-form", post: %{title: "Invalid"})
           |> render_change() =~ "can&#39;t be blank"

    # Submit valid form
    assert index_live
           |> form("#post-form", post: %{
             title: "My New Post",
             content: "Content here",
             status: :draft,
             compliance_level: :public
           })
           |> render_submit()

    assert_patch(index_live, ~p"/dashboard/posts")

    html = render(index_live)
    assert html =~ "Post created successfully"
    assert html =~ "My New Post"
  end
end
```

---

## Best Practices Summary

### ✅ DO

1. **Use `connected?(socket)` guard**: Only subscribe to PubSub in connected mode
2. **Debounce user input**: Reduce server load with `phx-debounce`
3. **Use streams for large lists**: Better performance with `stream/4`
4. **Validate on change**: Provide instant feedback with `phx-change="validate"`
5. **Use LiveComponents for reusable UI**: Modals, forms, cards
6. **Broadcast changes via PubSub**: Real-time collaboration
7. **Test LiveViews**: Use `Phoenix.LiveViewTest` helpers
8. **Use temporary assigns**: Optimize memory for large datasets
9. **Handle disconnections gracefully**: Show reconnection UI
10. **Implement Zero Trust checks**: Validate access in `mount/3`

### ❌ DON'T

1. **Don't subscribe in disconnected mode**: Causes memory leaks
2. **Don't store large data in assigns**: Use database queries or streams
3. **Don't skip CSRF protection**: Always use `protect_from_forgery` plug
4. **Don't bypass authentication**: Check `current_user` in mount
5. **Don't use `navigate` for same-LiveView changes**: Use `patch` instead
6. **Don't forget `phx-disable-with`**: Prevent double-submits
7. **Don't render everything on mount**: Load data progressively
8. **Don't ignore handle_info**: Handle PubSub messages properly
9. **Don't use LiveView for static pages**: Use controllers for simple pages
10. **Don't skip medical compliance checks**: Validate PHI access

---

## References

- **[Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view)** (L0_CANONICAL) - Official LiveView guide
- **[Phoenix LiveView 1.0.1](https://github.com/phoenixframework/phoenix_live_view/releases/tag/v1.0.1)** (L0_CANONICAL) - Current version
- **[LiveView Best Practices](https://hexdocs.pm/phoenix_live_view/liveview-best-practices.html)** (L0_CANONICAL)
- **[Testing LiveViews](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)** (L0_CANONICAL)
- **[PubSub Documentation](https://hexdocs.pm/phoenix_pubsub)** (L0_CANONICAL) - Real-time messaging

---

**Status**: Planned for Sprint 0-3+
**Implementation Priority**: High (real-time content management essential)
**Healthcare Compliance**: LGPD audit trails, Zero Trust enforcement, medical workflow dashboards
**Performance**: Stream optimization, debouncing, temporary assigns patterns documented
