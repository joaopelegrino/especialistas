# 📚 Diário de Referências para Desenvolvimento - Elixir

*Última atualização: 2025-08-15*  
*Versão: 1.0.0*

## 🎯 Quick Access Index

- [🔮 Core BEAM Resources](#-core-beam-resources) - Documentação oficial, OTP, concorrência
- [🚀 Web & APIs](#-web--apis) - Phoenix, LiveView, GraphQL
- [🤖 AI & LLMs](#-ai--llms) - LangChain, Bumblebee, integração
- [📊 Data Processing](#-data-processing) - Broadway, Flow, GenStage
- [🔐 Security & Auth](#-security--auth) - Guardian, Cloak, crypto
- [💾 Database & Storage](#-database--storage) - Ecto, PostgreSQL, migrations
- [🛠️ Essential Libraries](#-essential-libraries) - Production-ready packages
- [💡 Patterns & Best Practices](#-patterns--best-practices) - Architecture, testing
- [🚨 Troubleshooting](#-troubleshooting) - Common issues, solutions

---

## 🔮 Core BEAM Resources

### Official Documentation

#### Elixir Documentation
**URL**: https://elixir-lang.org/docs.html  
**Tipo**: Documentação  
**Validação**: Oficial, Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Referência fundamental para sintaxe, módulos core e biblioteca padrão  
**Quick Command/Code**:
```elixir
# Pattern matching básico
case user do
  %{role: :admin} -> grant_full_access()
  %{role: :doctor} -> grant_medical_access()
  %{role: :patient} -> grant_limited_access()
  _ -> deny_access()
end

# Pipe operator para transformações
document
|> parse()
|> validate()
|> process()
|> store()
```
**Notas**: 
- Foco em Enum, Stream, GenServer, Supervisor
- Pattern matching é fundamental
- Pipes melhoram legibilidade
**Relacionados**: 
- [Elixir School](https://elixirschool.com/)
- [Elixir Forum](https://elixirforum.com/)

#### Erlang/OTP Documentation
**URL**: https://www.erlang.org/doc/  
**Tipo**: Documentação  
**Validação**: Oficial, Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Compreensão do BEAM, OTP behaviors, e funcionalidades core  
**Quick Command/Code**:
```elixir
# GenServer implementation
defmodule MyServer do
  use GenServer
  
  # Client API
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end
  
  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end
  
  # Server callbacks
  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end
  
  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
```
**Notas**: 
- OTP é a base para sistemas robustos
- Supervision trees para fault tolerance
- :observer.start() para debugging
**Relacionados**: 
- [Learn You Some Erlang](https://learnyousomeerlang.com/)
- [OTP Design Principles](https://www.erlang.org/doc/design_principles/users_guide.html)

### Concurrency & Fault Tolerance

#### Actor Model Implementation
**URL**: https://www.erlang.org/doc/getting_started/conc_prog.html  
**Tipo**: Padrão  
**Validação**: Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Concorrência massiva com processos isolados  
**Quick Command/Code**:
```elixir
# Spawning processes
defmodule ConcurrentProcessor do
  def process_batch(items) do
    items
    |> Enum.map(fn item ->
      Task.async(fn -> process_item(item) end)
    end)
    |> Enum.map(&Task.await(&1, 30_000))
  end
  
  def process_with_supervision(items) do
    children = Enum.map(items, fn item ->
      %{
        id: {:processor, item.id},
        start: {ProcessWorker, :start_link, [item]},
        restart: :transient
      }
    end)
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```
**Notas**: 
- Processos são leves (2KB)
- Message passing é assíncrono
- Let it crash philosophy
**Relacionados**: 
- [Elixir Processes](https://elixir-lang.org/getting-started/processes.html)
- [Task and Gen modules](https://hexdocs.pm/elixir/Task.html)

#### Supervision Trees
**URL**: https://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html  
**Tipo**: Padrão  
**Validação**: Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Construção de sistemas resilientes e auto-recuperáveis  
**Quick Command/Code**:
```elixir
defmodule MyApp.Supervisor do
  use Supervisor
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end
  
  @impl true
  def init(:ok) do
    children = [
      # Permanent - sempre reinicia
      {MyApp.CriticalService, []},
      
      # Temporary - nunca reinicia
      %{
        id: MyApp.TempWorker,
        start: {MyApp.TempWorker, :start_link, []},
        restart: :temporary
      },
      
      # Transient - reinicia apenas em falha anormal
      %{
        id: MyApp.Worker,
        start: {MyApp.Worker, :start_link, []},
        restart: :transient
      }
    ]
    
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```
**Notas**: 
- Estratégias: one_for_one, one_for_all, rest_for_one
- Restart strategies: permanent, temporary, transient
- Max restarts configuration
**Relacionados**: 
- [DynamicSupervisor](https://hexdocs.pm/elixir/DynamicSupervisor.html)
- [Registry](https://hexdocs.pm/elixir/Registry.html)

---

## 🚀 Web & APIs

### Phoenix Framework

#### Phoenix Documentation
**URL**: https://hexdocs.pm/phoenix/Phoenix.html  
**Tipo**: Framework  
**Validação**: Community-Endorsed, Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Aplicações web real-time de alta performance  
**Quick Command/Code**:
```bash
# Criar novo projeto
mix phx.new healthcare_app --database postgres --live

# Generators
mix phx.gen.live Medical Patient patients name:string cpf:string:unique
mix phx.gen.context Medical Consultation consultations patient_id:references:patients

# Start server
mix phx.server
```
```elixir
# Controller example
defmodule HealthcareWeb.PatientController do
  use HealthcareWeb, :controller
  
  def index(conn, params) do
    patients = Medical.list_patients(params)
    render(conn, "index.json", patients: patients)
  end
  
  def create(conn, %{"patient" => patient_params}) do
    with {:ok, patient} <- Medical.create_patient(patient_params) do
      conn
      |> put_status(:created)
      |> render("show.json", patient: patient)
    end
  end
end
```
**Notas**: 
- Channels para WebSockets
- Contexts para domain logic
- Telemetry built-in
**Relacionados**: 
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)
- [Phoenix PubSub](https://hexdocs.pm/phoenix_pubsub)

#### Phoenix LiveView
**URL**: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html  
**Tipo**: Biblioteca  
**Validação**: Community-Endorsed, Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Interfaces interativas real-time sem JavaScript  
**Quick Command/Code**:
```elixir
defmodule HealthcareWeb.ConsultationLive do
  use HealthcareWeb, :live_view
  
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Medical.subscribe_consultation(id)
      :timer.send_interval(1000, :tick)
    end
    
    {:ok,
     socket
     |> assign(:consultation, Medical.get_consultation!(id))
     |> assign(:vital_signs, %{})
     |> assign(:timer, 0)}
  end
  
  @impl true
  def handle_event("update_vitals", %{"vitals" => vitals}, socket) do
    {:ok, updated} = Medical.update_vitals(socket.assigns.consultation, vitals)
    
    {:noreply,
     socket
     |> assign(:vital_signs, updated.vital_signs)
     |> put_flash(:info, "Vitals updated")}
  end
  
  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, :timer, socket.assigns.timer + 1)}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="consultation">
      <h2>Consultation <%= @consultation.id %></h2>
      <div class="timer">Duration: <%= format_time(@timer) %></div>
      
      <.form for={@form} phx-submit="update_vitals">
        <.input field={@form[:heart_rate]} label="Heart Rate" />
        <.input field={@form[:blood_pressure]} label="Blood Pressure" />
        <.button>Update</.button>
      </.form>
      
      <div class="vital-signs">
        <%= for {key, value} <- @vital_signs do %>
          <div><%= key %>: <%= value %></div>
        <% end %>
      </div>
    </div>
    """
  end
end
```
**Notas**: 
- Server-side rendering com updates real-time
- Reduz complexidade do frontend
- Perfeito para dashboards médicos
**Relacionados**: 
- [LiveView Native](https://native.live/)
- [Surface UI](https://surface-ui.org/)

### GraphQL with Absinthe

#### Absinthe GraphQL
**URL**: https://hexdocs.pm/absinthe/Absinthe.html  
**Tipo**: Biblioteca  
**Validação**: Community-Endorsed  
**Última Verificação**: 2025-08-15  
**Use Case**: APIs GraphQL type-safe e performáticas  
**Quick Command/Code**:
```elixir
# Schema definition
defmodule HealthcareWeb.Schema do
  use Absinthe.Schema
  
  import_types HealthcareWeb.Schema.PatientTypes
  
  query do
    @desc "Get a patient by ID"
    field :patient, :patient do
      arg :id, non_null(:id)
      resolve &Resolvers.Patient.find/3
    end
    
    @desc "List all patients"
    field :patients, list_of(:patient) do
      arg :filter, :patient_filter
      arg :limit, :integer, default_value: 10
      resolve &Resolvers.Patient.list/3
    end
  end
  
  mutation do
    @desc "Create a patient"
    field :create_patient, :patient do
      arg :input, non_null(:patient_input)
      resolve &Resolvers.Patient.create/3
    end
  end
  
  subscription do
    @desc "Subscribe to patient updates"
    field :patient_updated, :patient do
      arg :patient_id, non_null(:id)
      
      config fn args, _ ->
        {:ok, topic: "patient:#{args.patient_id}"}
      end
      
      trigger :update_patient,
        topic: fn patient ->
          "patient:#{patient.id}"
        end
    end
  end
end

# Types
defmodule HealthcareWeb.Schema.PatientTypes do
  use Absinthe.Schema.Notation
  
  object :patient do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :cpf, non_null(:string)
    field :birth_date, :date
    field :consultations, list_of(:consultation) do
      resolve &Resolvers.Patient.consultations/3
    end
  end
  
  input_object :patient_input do
    field :name, non_null(:string)
    field :cpf, non_null(:string)
    field :birth_date, :date
  end
end
```
**Notas**: 
- Subscriptions para real-time
- Dataloader para N+1 queries
- Middleware para auth e logging
**Relacionados**: 
- [Absinthe Relay](https://hexdocs.pm/absinthe_relay)
- [Dataloader](https://hexdocs.pm/dataloader)

---

## 🤖 AI & LLMs

### LangChain for Elixir

#### LangChain Integration
**URL**: https://github.com/brainlid/langchain  
**Tipo**: Biblioteca  
**Validação**: Community-Endorsed  
**Última Verificação**: 2025-08-15  
**Use Case**: Orquestração de LLMs e construção de aplicações de IA  
**Quick Command/Code**:
```elixir
# mix.exs
{:langchain, "~> 0.3.3"}

# Basic usage
alias LangChain.{Chains.LLMChain, ChatModels.ChatOpenAI, Message}

# Configure LLM
{:ok, llm} = ChatOpenAI.new(%{
  model: "gpt-4-turbo",
  temperature: 0.1,
  api_key: System.get_env("OPENAI_API_KEY")
})

# Create chain
{:ok, chain} = LLMChain.new(%{
  llm: llm,
  prompt: PromptTemplate.from_template("""
    Analyze the following medical document and extract:
    1. Patient information
    2. Diagnoses
    3. Medications
    4. Recommendations
    
    Document: {document}
    """)
})

# Run chain
{:ok, result} = chain
  |> LLMChain.add_message(Message.new_user!(document_text))
  |> LLMChain.run()

# Multi-provider support
providers = [
  {:openai, ChatOpenAI.new!(model: "gpt-4")},
  {:anthropic, ChatAnthropic.new!(model: "claude-3")},
  {:google, ChatVertexAI.new!(model: "gemini-pro")}
]

results = Enum.map(providers, fn {name, llm} ->
  {name, LLMChain.run(chain_with_llm(llm))}
end)
```
**Notas**: 
- Suporte para 12+ providers
- Function calling support
- Streaming responses
**Relacionados**: 
- [ExLLM](https://github.com/uukr/ex_llm)
- [Instructor](https://github.com/uukr/instructor_ex)

### Bumblebee - Local ML

#### Bumblebee Neural Networks
**URL**: https://github.com/elixir-nx/bumblebee  
**Tipo**: Biblioteca  
**Validação**: Official Nx Team  
**Última Verificação**: 2025-08-15  
**Use Case**: Modelos de ML locais com Hugging Face  
**Quick Command/Code**:
```elixir
# Load model
{:ok, model} = Bumblebee.load_model({:hf, "bert-base-uncased"})
{:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "bert-base-uncased"})

# Create serving
serving = Bumblebee.Text.text_classification(model, tokenizer,
  compile: [batch_size: 32],
  defn_options: [compiler: EXLA]
)

# Run inference
text = "The patient shows signs of improvement"
result = Nx.Serving.run(serving, text)

# Medical image analysis
{:ok, resnet} = Bumblebee.load_model({:hf, "microsoft/resnet-50"})
{:ok, featurizer} = Bumblebee.load_featurizer({:hf, "microsoft/resnet-50"})

image_serving = Bumblebee.Vision.image_classification(
  resnet, featurizer,
  compile: [batch_size: 10],
  top_k: 5
)

# Process medical image
image = StbImage.read_file!("xray.jpg")
predictions = Nx.Serving.run(image_serving, image)
```
**Notas**: 
- GPU acceleration com EXLA
- Suporte para Vision, Text, Audio
- HuggingFace model hub
**Relacionados**: 
- [Axon](https://github.com/elixir-nx/axon)
- [Nx](https://github.com/elixir-nx/nx)

---

## 📊 Data Processing

### Broadway Pipeline

#### Broadway Documentation
**URL**: https://hexdocs.pm/broadway/Broadway.html  
**Tipo**: Biblioteca  
**Validação**: Industry-Standard, Production-Ready  
**Última Verificação**: 2025-08-15  
**Use Case**: Pipelines de processamento com backpressure e batching  
**Quick Command/Code**:
```elixir
defmodule DocumentPipeline do
  use Broadway
  
  @impl true
  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwaySQS.Producer,
          queue_url: "https://sqs.amazonaws.com/queue",
          config: [
            access_key_id: System.get_env("AWS_ACCESS_KEY"),
            secret_access_key: System.get_env("AWS_SECRET")
          ]
        },
        concurrency: 2,
        rate_limiting: [
          allowed_messages: 1000,
          interval: 1_000
        ]
      ],
      processors: [
        default: [
          concurrency: System.schedulers_online() * 2,
          min_demand: 5,
          max_demand: 10
        ]
      ],
      batchers: [
        s3: [
          concurrency: 2,
          batch_size: 100,
          batch_timeout: 1_000
        ],
        sqs: [
          concurrency: 1,
          batch_size: 10,
          batch_timeout: 2_000
        ]
      ]
    )
  end
  
  @impl true
  def handle_message(_processor, message, _context) do
    message
    |> Message.update_data(&process_document/1)
    |> Message.put_batch_key(determine_batch(&1))
  end
  
  @impl true
  def handle_batch(:s3, messages, _batch_info, _context) do
    # Batch upload to S3
    S3.upload_batch(messages)
    messages
  end
  
  @impl true
  def handle_failed(messages, _context) do
    # Handle failures with retry logic
    Enum.each(messages, &log_failure/1)
    messages
  end
end
```
**Notas**: 
- Automatic backpressure
- Built-in error handling
- Telemetry integration
**Relacionados**: 
- [Broadway Kafka](https://github.com/dashbitco/broadway_kafka)
- [Broadway RabbitMQ](https://github.com/dashbitco/broadway_rabbitmq)

### Flow - Parallel Processing

#### Flow Documentation
**URL**: https://hexdocs.pm/flow/Flow.html  
**Tipo**: Biblioteca  
**Validação**: Official, Production-Ready  
**Última Verificação**: 2025-08-15  
**Use Case**: Processamento paralelo de grandes volumes de dados  
**Quick Command/Code**:
```elixir
# Parallel document processing
documents
|> Flow.from_enumerable(max_demand: 1000)
|> Flow.partition(stages: System.schedulers_online())
|> Flow.map(&parse_document/1)
|> Flow.filter(&valid?/1)
|> Flow.flat_map(&extract_entities/1)
|> Flow.reduce(fn -> %{} end, &count_entities/2)
|> Flow.emit(:state)
|> Enum.to_list()

# Window aggregation
events
|> Flow.from_enumerable()
|> Flow.partition(window: Flow.Window.periodic(1, :minute))
|> Flow.reduce(fn -> %{} end, fn event, acc ->
  Map.update(acc, event.type, 1, &(&1 + 1))
end)
|> Flow.on_trigger(fn acc ->
  IO.inspect(acc, label: "Events per minute")
  {[acc], %{}}
end)
|> Flow.run()
```
**Notas**: 
- Automatic partitioning
- Window operations
- Back-pressure handling
**Relacionados**: 
- [GenStage](https://github.com/elixir-lang/gen_stage)
- [Task.async_stream](https://hexdocs.pm/elixir/Task.html#async_stream/3)

---

## 🔐 Security & Auth

### Guardian JWT

#### Guardian Documentation
**URL**: https://github.com/ueberauth/guardian  
**Tipo**: Biblioteca  
**Validação**: Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Autenticação JWT para APIs e aplicações web  
**Quick Command/Code**:
```elixir
# Configuration
defmodule Healthcare.Guardian do
  use Guardian, otp_app: :healthcare
  
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end
  
  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end

# Pipeline
defmodule HealthcareWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :healthcare,
    module: Healthcare.Guardian,
    error_handler: HealthcareWeb.AuthErrorHandler
  
  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end

# Controller usage
def login(conn, %{"email" => email, "password" => password}) do
  with {:ok, user} <- Accounts.authenticate(email, password),
       {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
    conn
    |> put_status(:ok)
    |> render("login.json", %{token: token, user: user})
  end
end

# Permissions
defmodule Healthcare.Permissions do
  use Guardian.Permissions.BitwiseEncoding
  
  def max_simultaneous_permissions, do: 64
  
  # Define permissions
  def permission_sets do
    %{
      medical: [:read_records, :write_records, :prescribe],
      admin: [:manage_users, :manage_system, :view_audit],
      patient: [:read_own_records, :book_appointments]
    }
  end
end
```
**Notas**: 
- Token refresh strategies
- Permission-based access
- Session management
**Relacionados**: 
- [Ueberauth](https://github.com/ueberauth/ueberauth)
- [Pow](https://github.com/danschultzer/pow)

### Cloak Encryption

#### Cloak Ecto
**URL**: https://github.com/danielberkompas/cloak  
**Tipo**: Biblioteca  
**Validação**: Production-Ready  
**Última Verificação**: 2025-08-15  
**Use Case**: Criptografia transparente de campos do banco de dados  
**Quick Command/Code**:
```elixir
# Vault configuration
defmodule Healthcare.Vault do
  use Cloak.Vault, otp_app: :healthcare
  
  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers, [
        default: {
          Cloak.Ciphers.AES.GCM,
          tag: "AES.GCM.V1",
          key: decode_env!("CLOAK_KEY"),
          iv_length: 12
        },
        legacy: {
          Cloak.Ciphers.AES.CTR,
          tag: "AES.CTR.V1",
          key: decode_env!("LEGACY_CLOAK_KEY")
        }
      ])
    
    {:ok, config}
  end
end

# Schema with encrypted fields
defmodule Healthcare.Patient do
  use Ecto.Schema
  
  schema "patients" do
    field :name, :string
    field :cpf, Healthcare.Encrypted.Binary
    field :medical_history, Healthcare.Encrypted.Map
    field :notes, Healthcare.Encrypted.Text
    
    timestamps()
  end
end

# Custom encrypted type
defmodule Healthcare.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: Healthcare.Vault
end

# Key rotation
defmodule Healthcare.KeyRotation do
  def rotate_keys do
    Healthcare.Repo.transaction(fn ->
      Healthcare.Patient
      |> Healthcare.Repo.stream()
      |> Stream.each(fn patient ->
        patient
        |> Ecto.Changeset.change(%{})
        |> Healthcare.Repo.update!()
      end)
      |> Stream.run()
    end)
  end
end
```
**Notas**: 
- Transparent encryption/decryption
- Key rotation support
- Multiple cipher support
**Relacionados**: 
- [ExCrypto](https://github.com/ntrepid8/ex_crypto)
- [Comeonin](https://github.com/riverrun/comeonin)

---

## 💾 Database & Storage

### Ecto & PostgreSQL

#### Ecto Documentation
**URL**: https://hexdocs.pm/ecto/Ecto.html  
**Tipo**: Biblioteca  
**Validação**: Industry-Standard  
**Última Verificação**: 2025-08-15  
**Use Case**: Database abstraction e query composition  
**Quick Command/Code**:
```elixir
# Schema definition
defmodule Healthcare.Medical.Patient do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  
  schema "patients" do
    field :name, :string
    field :cpf, :string
    field :birth_date, :date
    field :blood_type, Ecto.Enum, values: [:a_pos, :a_neg, :b_pos, :b_neg, :o_pos, :o_neg, :ab_pos, :ab_neg]
    
    has_many :consultations, Healthcare.Medical.Consultation
    has_many :prescriptions, Healthcare.Medical.Prescription
    
    embeds_one :address, Address do
      field :street, :string
      field :city, :string
      field :state, :string
      field :zip, :string
    end
    
    timestamps()
  end
  
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:name, :cpf, :birth_date, :blood_type])
    |> validate_required([:name, :cpf])
    |> validate_cpf()
    |> unique_constraint(:cpf)
    |> cast_embed(:address, with: &address_changeset/2)
  end
  
  defp validate_cpf(changeset) do
    validate_change(changeset, :cpf, fn :cpf, cpf ->
      if CPF.valid?(cpf) do
        []
      else
        [cpf: "invalid CPF"]
      end
    end)
  end
end

# Complex queries
import Ecto.Query

def patients_with_recent_consultations(days \\ 30) do
  from p in Patient,
    join: c in assoc(p, :consultations),
    where: c.date >= ago(^days, "day"),
    group_by: p.id,
    having: count(c.id) > 2,
    select: %{
      patient: p,
      consultation_count: count(c.id),
      last_consultation: max(c.date)
    },
    preload: [:prescriptions]
end

# Transactions
def transfer_patient(patient, from_doctor, to_doctor) do
  Repo.transaction(fn ->
    with {:ok, _} <- remove_from_doctor(patient, from_doctor),
         {:ok, _} <- add_to_doctor(patient, to_doctor),
         {:ok, _} <- log_transfer(patient, from_doctor, to_doctor) do
      {:ok, patient}
    else
      {:error, reason} -> Repo.rollback(reason)
    end
  end)
end
```
**Notas**: 
- Multi-tenancy support
- Database migrations
- Connection pooling
**Relacionados**: 
- [Ecto SQL](https://hexdocs.pm/ecto_sql)
- [Postgrex](https://hexdocs.pm/postgrex)

### PgVector for Embeddings

#### PgVector Integration
**URL**: https://github.com/pgvector/pgvector-elixir  
**Tipo**: Biblioteca  
**Validação**: Production-Ready  
**Última Verificação**: 2025-08-15  
**Use Case**: Vector search para RAG e similarity search  
**Quick Command/Code**:
```elixir
# Migration
defmodule Healthcare.Repo.Migrations.AddVectorExtension do
  use Ecto.Migration
  
  def up do
    execute "CREATE EXTENSION IF NOT EXISTS vector"
    
    create table(:document_embeddings) do
      add :document_id, references(:documents)
      add :content, :text
      add :embedding, :vector, size: 1536
      add :metadata, :map
      
      timestamps()
    end
    
    create index(:document_embeddings, ["embedding vector_cosine_ops"], using: :hnsw)
  end
end

# Schema
defmodule Healthcare.Embedding do
  use Ecto.Schema
  
  schema "document_embeddings" do
    field :content, :string
    field :embedding, Pgvector.Ecto.Vector
    field :metadata, :map
    belongs_to :document, Healthcare.Document
    
    timestamps()
  end
end

# Similarity search
def find_similar(query_embedding, limit \\ 10) do
  from e in Embedding,
    order_by: fragment("embedding <-> ?", ^query_embedding),
    limit: ^limit,
    select: %{
      content: e.content,
      similarity: fragment("1 - (embedding <-> ?)", ^query_embedding),
      metadata: e.metadata
    }
end

# Hybrid search
def hybrid_search(text_query, embedding, opts \\ []) do
  text_weight = Keyword.get(opts, :text_weight, 0.5)
  vector_weight = Keyword.get(opts, :vector_weight, 0.5)
  
  from e in Embedding,
    where: fragment("to_tsvector('portuguese', ?) @@ plainto_tsquery('portuguese', ?)", 
                   e.content, ^text_query),
    order_by: fragment(
      "(?::float * ts_rank(to_tsvector('portuguese', ?), plainto_tsquery('portuguese', ?))) + 
       (?::float * (1 - (embedding <-> ?::vector)))",
      ^text_weight, e.content, ^text_query,
      ^vector_weight, ^embedding
    ),
    limit: 20
end
```
**Notas**: 
- HNSW indexing for performance
- Cosine, L2, Inner product distance
- Hybrid text + vector search
**Relacionados**: 
- [Nx](https://github.com/elixir-nx/nx)
- [Bumblebee](https://github.com/elixir-nx/bumblebee)
