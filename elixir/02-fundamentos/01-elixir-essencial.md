# Fundamentos Essenciais do Elixir

[ESSENCIAL] [FUNDAMENTOS]

## 🎯 Imutabilidade e Rebinding (Linhas 10-50)

[ESSENCIAL] [CONCEITO-CHAVE]
### O Problema da Imutabilidade
```elixir
# ❌ ERRO COMUM - Tentando mudar dentro do bloco
socket = %{assigns: %{value: 1}}

if connected?(socket) do
  socket = assign(socket, :value, 2)  # Rebinding local, não afeta fora
end

# socket.assigns.value ainda é 1!

# ✅ CORRETO - Capturar o resultado do bloco
socket = 
  if connected?(socket) do
    assign(socket, :value, 2)
  else
    socket
  end
  
# socket.assigns.value agora é 2 se connected? for true
```

### Padrão para Múltiplas Transformações
```elixir
# ✅ BEST PRACTICE - Pipeline de transformações
socket
|> assign(:loading, true)
|> assign(:data, nil)
|> push_event("start-fetch", %{})
```

## ⚠️ Acesso a Listas por Índice (Linhas 51-100)

[ERRO-COMUM] [IMPORTANTE]
### Nunca Use Bracket Access em Listas
```elixir
# ❌ NUNCA FAÇA ISSO - Syntax error!
list = ["a", "b", "c"]
first = list[0]  # ERRO! Listas não suportam []

# ✅ FORMAS CORRETAS
# Opção 1: Enum.at/2
first = Enum.at(list, 0)  # "a"

# Opção 2: Pattern matching
[first | _rest] = list  # first = "a"

# Opção 3: hd/1 para primeiro elemento
first = hd(list)  # "a"

# Opção 4: List.first/1
first = List.first(list)  # "a"
```

### Quando Usar Cada Abordagem
```elixir
# Para índices específicos
Enum.at(list, 2)

# Para primeiro/último
List.first(list)
List.last(list)

# Para decomposição
[head | tail] = list
[first, second | rest] = list
```

## 🎯 Pattern Matching Avançado (Linhas 101-150)

[BEST-PRACTICE] [PODEROSO]
### Matching em Funções
```elixir
defmodule UserHandler do
  # Pattern matching direto nos parâmetros
  def process({:ok, %User{} = user}), do: {:success, user}
  def process({:error, reason}), do: {:failure, reason}
  def process(_), do: {:error, :invalid_input}
  
  # Com guards
  def age_group(%User{age: age}) when age < 18, do: :minor
  def age_group(%User{age: age}) when age < 60, do: :adult
  def age_group(%User{age: _age}), do: :senior
end
```

### Matching em Case/With
```elixir
# With para múltiplas validações
with {:ok, user} <- fetch_user(id),
     {:ok, posts} <- fetch_posts(user),
     {:ok, stats} <- calculate_stats(posts) do
  {:ok, %{user: user, posts: posts, stats: stats}}
else
  {:error, :user_not_found} -> {:error, "Usuário não encontrado"}
  {:error, :posts_failed} -> {:error, "Erro ao buscar posts"}
  error -> error
end
```

## 🏗️ Structs vs Maps (Linhas 151-200)

[EXEMPLO] [DIFERENÇA-IMPORTANTE]
### Maps Não Têm Access Behaviour em Structs
```elixir
# ❌ ERRO COMUM - Usar [] em structs
defmodule User do
  defstruct [:name, :email, :age]
end

user = %User{name: "João", email: "joao@example.com"}
name = user[:name]  # ERRO! Structs não implementam Access

# ✅ CORRETO - Acesso direto
name = user.name  # "João"

# Para maps normais, [] funciona
map = %{name: "João", email: "joao@example.com"}
name = map[:name]  # OK para maps
```

### Conversão e Manipulação
```elixir
# Struct para map
user_map = Map.from_struct(user)

# Update em struct
updated_user = %{user | age: 30}

# Pattern matching em struct
%User{name: name, email: email} = user
```

## 🔄 Processos e Concorrência

[ESSENCIAL] [OTP]
### Task para Operações Simples
```elixir
# Execução assíncrona simples
task = Task.async(fn -> 
  expensive_calculation()
end)

# Aguardar resultado
result = Task.await(task, 5000)  # timeout de 5s

# Múltiplas tasks com Task.async_stream
results = 
  1..100
  |> Task.async_stream(fn n -> 
    process_item(n)
  end, timeout: :infinity, max_concurrency: 10)
  |> Enum.to_list()
```

## 📝 Guards e Validações

[BEST-PRACTICE]
### Nomeação de Predicados
```elixir
# ✅ CORRETO - Predicados terminam com ?
def valid?(user), do: user.age >= 18
def empty?(list), do: length(list) == 0
def admin?(user), do: user.role == :admin

# Guards começam com is_ (para macros)
defguard is_adult(age) when is_integer(age) and age >= 18
defguard is_valid_email(email) when is_binary(email) and email =~ "@"
```

## ⚡ Performance e Otimizações

[OTIMIZACAO]
### Evite String.to_atom com Input do Usuário
```elixir
# ❌ PERIGOSO - Memory leak!
def process_input(user_input) do
  String.to_atom(user_input)  # Atoms nunca são garbage collected
end

# ✅ SEGURO - Use atoms existentes
def process_input(user_input) do
  case user_input do
    "create" -> :create
    "update" -> :update
    "delete" -> :delete
    _ -> :unknown
  end
end

# Ou use String.to_existing_atom se necessário
try do
  String.to_existing_atom(user_input)
rescue
  ArgumentError -> :unknown
end
```

## 🎯 Pipe Operator Best Practices

[BEST-PRACTICE]
### Quando Usar e Não Usar Pipes
```elixir
# ✅ BOM - Transformações sequenciais
user
|> validate_age()
|> validate_email()
|> hash_password()
|> insert_to_database()

# ❌ EVITE - Pipes com apenas uma operação
result = data |> process()  # Desnecessário

# ✅ MELHOR
result = process(data)

# ❌ EVITE - Misturar pipes com não-pipes
data
|> process()
|> then(fn result ->
  if result.valid? do
    save(result)
  else
    handle_error(result)
  end
end)
```

## 🔍 Debugging e Inspeção

[DESENVOLVIMENTO]
### Técnicas de Debug
```elixir
# IO.inspect com label
value
|> IO.inspect(label: "Antes do processamento")
|> process()
|> IO.inspect(label: "Depois do processamento")

# dbg() macro (Elixir 1.14+)
value
|> dbg()
|> process()
|> dbg()

# IEx.pry para debugging interativo
require IEx

def complex_function(data) do
  processed = transform(data)
  IEx.pry()  # Para aqui e abre console
  final_result = finalize(processed)
end
```

---
**[NAVEGACAO]** Use as tags para encontrar conteúdo específico rapidamente!