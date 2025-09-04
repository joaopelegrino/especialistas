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