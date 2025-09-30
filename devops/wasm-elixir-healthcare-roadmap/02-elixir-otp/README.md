# ⚗️ Módulo 02: Elixir/OTP Foundations for Healthcare

## 🎯 Objetivos de Aprendizado

- Entender por que Elixir é ideal para healthcare (2M+ connections concorrentes)
- Implementar GenServers para gerenciar plugins WASM
- Criar Supervisors para fault-tolerance (99.99% uptime)
- Aplicar OTP patterns em contexto médico real

**Duração**: 3-4 dias | **Pré-requisitos**: Elixir 1.18.4 + OTP 27 instalados

---

## 📚 Por que Elixir para Healthcare?

### **Caso Real: HCA Healthcare**
- **300+ hospitais** usando Elixir
- **2M+ conexões concorrentes** (pacientes, médicos, equipamentos)
- **99.999% uptime** (5.26 minutos downtime/ano)
- **Hot code swapping**: Deploy sem interrupção

### **Comparação com Outras Linguagens**

```
┌─────────────────────────────────────────────────────────┐
│  Requisito Healthcare      │ Node.js │ Python │ Elixir  │
├────────────────────────────┼─────────┼────────┼─────────┤
│  2M+ concurrent users      │    ❌   │   ❌   │   ✅    │
│  Hot code swapping         │    ❌   │   ❌   │   ✅    │
│  Fault tolerance (OTP)     │    ❌   │   ❌   │   ✅    │
│  Low latency (< 50ms)      │    ⚠️   │   ❌   │   ✅    │
│  Memory safety             │    ⚠️   │   ⚠️   │   ✅    │
│  Mature for 20+ years      │    ❌   │   ⚠️   │   ✅    │
└─────────────────────────────────────────────────────────┘
```

**Elixir == Erlang/OTP**: Elixir é sintaxe moderna sobre Erlang VM (BEAM), que roda sistemas críticos há 30+ anos (telecomunicações, WhatsApp, Discord).

---

## 🏗️ Arquitetura: Elixir Host + WASM Plugins

```
┌─────────────────────────────────────────────────────────────┐
│  Phoenix Web Application (Port 4000)                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  LiveView UI - Real-time medical dashboard           │  │
│  └───────────────────────────────────────────────────────┘  │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  PluginManager GenServer (Supervisor)                 │  │
│  │  ├─ S.1.1 LGPD Analyzer (Rust WASM)                   │  │
│  │  ├─ S.1.2 Medical Claims (AssemblyScript WASM)        │  │
│  │  ├─ S.2-1.2 Scientific Search (Go WASM)               │  │
│  │  └─ S.4-1.1-3 Content Gen (Rust WASM)                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Ecto Database Layer (PostgreSQL 16)                  │  │
│  │  - Patient records (encrypted)                        │  │
│  │  - Audit trails (immutable)                           │  │
│  │  - Plugin metadata                                    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Conteúdo do Módulo

### **Day 1: GenServer Basics**
- [ ] Lab 2.1: GenServer para gerenciar estado de paciente
- [ ] Lab 2.2: Processar requisições concorrentes (10k+)
- [ ] Lab 2.3: GenServer com timeout e cleanup

### **Day 2: Supervisors & Fault Tolerance**
- [ ] Lab 2.4: Supervisor básico `:one_for_one`
- [ ] Lab 2.5: Restart strategies para plugins WASM
- [ ] Lab 2.6: Telemetry e monitoring

### **Day 3: Plugin Management**
- [ ] Lab 2.7: PluginManager GenServer
- [ ] Lab 2.8: Carregar/descarregar WASM dinamicamente
- [ ] Lab 2.9: Health checks de plugins

### **Day 4: Production Patterns**
- [ ] Lab 2.10: Backpressure e rate limiting
- [ ] Lab 2.11: Circuit breaker para APIs externas
- [ ] Lab 2.12: Distributed Elixir (multi-node)

---

## 🧪 Lab 2.1: GenServer para Patient State

### **Conceito**: GenServer = Generic Server Pattern

Um GenServer é um processo que:
1. Mantém estado interno (ex: dados de paciente)
2. Responde a mensagens síncronas (`call`) e assíncronas (`cast`)
3. Roda isoladamente (se crashar, não afeta outros processos)

### **Implementação Básica**

Crie `lib/patient_manager.ex`:

```elixir
defmodule HealthcareStack.PatientManager do
  @moduledoc """
  GenServer para gerenciar estado de pacientes em memória.
  Em produção, isso seria persistido em PostgreSQL + cache Redis.
  """
  use GenServer
  require Logger

  # Estrutura de dados do paciente
  defmodule Patient do
    @enforce_keys [:id, :anonymous_id, :status]
    defstruct [:id, :anonymous_id, :status, :last_updated, metadata: %{}]
  end

  ## Client API (Funções públicas)

  @doc "Inicia o GenServer"
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @doc "Registra novo paciente"
  def register_patient(patient_id, anonymous_id) do
    GenServer.call(__MODULE__, {:register, patient_id, anonymous_id})
  end

  @doc "Busca paciente por ID"
  def get_patient(patient_id) do
    GenServer.call(__MODULE__, {:get, patient_id})
  end

  @doc "Atualiza status do paciente"
  def update_status(patient_id, new_status) do
    GenServer.cast(__MODULE__, {:update_status, patient_id, new_status})
  end

  @doc "Lista todos os pacientes (para admin)"
  def list_all() do
    GenServer.call(__MODULE__, :list_all)
  end

  ## Server Callbacks (Funções privadas do GenServer)

  @impl true
  def init(:ok) do
    Logger.info("🏥 PatientManager started")
    # Estado inicial: mapa vazio de pacientes
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register, patient_id, anonymous_id}, _from, state) do
    patient = %Patient{
      id: patient_id,
      anonymous_id: anonymous_id,
      status: :active,
      last_updated: DateTime.utc_now()
    }

    new_state = Map.put(state, patient_id, patient)

    Logger.info("📋 Patient registered: #{patient_id} (#{anonymous_id})")

    {:reply, {:ok, patient}, new_state}
  end

  @impl true
  def handle_call({:get, patient_id}, _from, state) do
    case Map.get(state, patient_id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      patient ->
        {:reply, {:ok, patient}, state}
    end
  end

  @impl true
  def handle_call(:list_all, _from, state) do
    patients = Map.values(state)
    {:reply, {:ok, patients}, state}
  end

  @impl true
  def handle_cast({:update_status, patient_id, new_status}, state) do
    case Map.get(state, patient_id) do
      nil ->
        Logger.warning("⚠️ Attempted to update non-existent patient: #{patient_id}")
        {:noreply, state}

      patient ->
        updated_patient = %{patient | status: new_status, last_updated: DateTime.utc_now()}
        new_state = Map.put(state, patient_id, updated_patient)

        Logger.info("✅ Patient #{patient_id} status updated: #{new_status}")
        {:noreply, new_state}
    end
  end
end
```

### **Testar no IEx**

```elixir
# Iniciar IEx
iex -S mix

# Iniciar o GenServer
{:ok, _pid} = HealthcareStack.PatientManager.start_link()

# Registrar paciente
{:ok, patient} = HealthcareStack.PatientManager.register_patient("P001", "ANON_12345")

# Buscar paciente
{:ok, patient} = HealthcareStack.PatientManager.get_patient("P001")

# Atualizar status (assíncrono)
:ok = HealthcareStack.PatientManager.update_status("P001", :discharged)

# Listar todos
{:ok, patients} = HealthcareStack.PatientManager.list_all()
```

`★ Insight ─────────────────────────────────────`
Cada `call` é **síncrono** (bloqueia até resposta). Cada `cast` é **assíncrono** (retorna imediatamente). Use `call` para operações críticas que precisam confirmação (ex: criar paciente). Use `cast` para updates não-críticos (ex: atualizar last_seen).
`─────────────────────────────────────────────────`

---

## 🔥 Conceitos Avançados

### **1. Fault Tolerance: Let It Crash**

Filosofia Elixir/OTP: **não tente prevenir todos os erros**. Deixe processos crasharem e use Supervisors para reiniciá-los.

```elixir
# Processo crashou? Supervisor reinicia automaticamente
defmodule HealthcareStack.Application do
  use Application

  def start(_type, _args) do
    children = [
      {HealthcareStack.PatientManager, []},
      # Se PatientManager crashar, supervisor reinicia
    ]

    opts = [strategy: :one_for_one, name: HealthcareStack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### **2. Concurrency: Millions of Processes**

Cada paciente pode ter seu próprio processo leve (não é OS thread!):

```elixir
# Criar 1 milhão de processos (testa em 1000 primeiro!)
Enum.each(1..1000, fn i ->
  Task.start(fn ->
    HealthcareStack.PatientManager.register_patient("P#{i}", "ANON_#{i}")
  end)
end)
```

BEAM gerencia milhões de processos com overhead mínimo (< 1KB por processo).

---

## ✅ Checkpoint de Validação

### **Checklist de Competências**
- [ ] Entendo diferença entre `call` (síncrono) e `cast` (assíncrono)
- [ ] Implementei GenServer básico para healthcare
- [ ] Compreendo "Let It Crash" philosophy
- [ ] Testei concorrência com 1000+ operações

### **Perguntas de Auto-Avaliação**

1. **Por que usar `cast` ao invés de `call` para atualizar status?**
   <details>
   <summary>Ver resposta</summary>

   Atualizar status não precisa confirmação imediata. Com `cast`, o cliente não bloqueia esperando resposta, aumentando throughput. Para operações críticas (ex: criar paciente, processar pagamento), use `call` para garantir sucesso.
   </details>

2. **O que acontece se PatientManager crashar?**
   <details>
   <summary>Ver resposta</summary>

   Se estiver supervisionado, o Supervisor reinicia o processo. Estado em memória é perdido (por isso produção usa Ecto + PostgreSQL + Redis). Outros processos não são afetados.
   </details>

---

## 🚀 Próximos Passos

Continue em: [03-extism-integration](../03-extism-integration/) para integrar WASM plugins com Elixir.

---

## 📚 Referências

- [Elixir GenServer Guide](https://elixir-lang.org/getting-started/mix-otp/genserver.html)
- [OTP Design Principles](https://www.erlang.org/doc/design_principles/des_princ.html)
- [HCA Healthcare + Elixir](https://elixir-lang.org/blog/2020/10/08/real-time-communication-at-scale-with-elixir-at-discord/)

**Healthcare References:**
- `BOM-WASM-ELIXIR-HEALTHCARE-STACK.md:14-70` - Stack architecture
- `HEALTHCARE-ENTERPRISE-DEVOPS.md` - Production patterns

---

**Status**: ✅ Módulo pronto
**Última atualização**: 29/09/2025