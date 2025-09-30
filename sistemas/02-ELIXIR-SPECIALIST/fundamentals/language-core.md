# Elixir Core Language Fundamentals

**Language**: Elixir 1.17.3
**Runtime**: Erlang/OTP 27.1
**Paradigm**: Functional, Concurrent, Immutable
**Healthcare Context**: Pattern matching for data validation, pipelines for workflows
**Last Updated**: 2025-09-30

---

## Overview

**Elixir** is a functional, concurrent language built on the Erlang VM (BEAM), designed for building scalable and maintainable applications.

**Healthcare Advantages**:
- **Pattern matching**: Data validation (CPF, CRM, medical codes)
- **Immutability**: Audit trails (no data mutation)
- **Pipe operator**: Medical workflows (data processing pipelines)
- **Metaprogramming**: DSLs for clinical rules

---

## Pattern Matching

### Basic Syntax
```elixir
# Variable assignment (actually pattern matching)
x = 1  # matches 1 to x

# Match operator (=)
{:ok, result} = {:ok, 42}  # result = 42
{:ok, result} = {:error, "failed"}  # MatchError

# Pin operator (^) - use existing value
x = 1
^x = 1  # OK
^x = 2  # MatchError
```

### Healthcare Example (Patient Data Validation)
```elixir
defmodule Healthcare.Patient.Validator do
  @doc "Validate patient data structure"
  def validate(%{cpf: cpf, name: name, birth_date: birth_date}) 
      when is_binary(cpf) and is_binary(name) and is_struct(birth_date, Date) do
    with :ok <- validate_cpf(cpf),
         :ok <- validate_name(name),
         :ok <- validate_age(birth_date) do
      {:ok, :valid}
    else
      {:error, reason} -> {:error, reason}
    end
  end
  
  def validate(_invalid_structure) do
    {:error, :invalid_patient_structure}
  end
  
  defp validate_cpf(cpf) when byte_size(cpf) == 11 do
    # CPF must be 11 digits
    case Regex.match?(~r/^\d{11}$/, cpf) do
      true -> :ok
      false -> {:error, :invalid_cpf_format}
    end
  end
  defp validate_cpf(_), do: {:error, :invalid_cpf_length}
  
  defp validate_name(name) when byte_size(name) >= 3, do: :ok
  defp validate_name(_), do: {:error, :name_too_short}
  
  defp validate_age(birth_date) do
    age = Date.diff(Date.utc_today(), birth_date) / 365.25
    
    if age >= 0 and age <= 150 do
      :ok
    else
      {:error, :invalid_age}
    end
  end
end
```

**Usage**:
```elixir
patient = %{
  cpf: "12345678901",
  name: "João Silva",
  birth_date: ~D[1985-03-15]
}

case Healthcare.Patient.Validator.validate(patient) do
  {:ok, :valid} -> IO.puts("Patient validated")
  {:error, reason} -> IO.puts("Validation failed: #{reason}")
end
```

---

## Immutability

### Core Principle
**All data structures in Elixir are immutable** - cannot be modified in place.

```elixir
list = [1, 2, 3]
new_list = [0 | list]  # Prepend

IO.inspect(list)      # [1, 2, 3] (unchanged)
IO.inspect(new_list)  # [0, 1, 2, 3]
```

### Healthcare Benefit (Audit Trails)
```elixir
defmodule Healthcare.AuditLog do
  @doc "Create immutable audit log entry"
  def create_entry(user_id, action, resource) do
    # Once created, this map CANNOT be modified
    %{
      id: Ecto.UUID.generate(),
      user_id: user_id,
      action: action,
      resource: resource,
      timestamp: DateTime.utc_now(),
      # LGPD Art. 46 - Immutable audit trail
      compliance_tag: "LGPD_Art_46_immutable"
    }
  end
  
  @doc "Add metadata to audit entry (creates new map)"
  def add_metadata(audit_entry, metadata) do
    # Returns NEW map, original unchanged
    Map.put(audit_entry, :metadata, metadata)
  end
end

# Usage
entry = Healthcare.AuditLog.create_entry("user123", "read", "Patient/456")
entry_with_meta = Healthcare.AuditLog.add_metadata(entry, %{ip_address: "192.168.1.1"})

# Original entry unchanged (immutability guarantees audit integrity)
IO.inspect(Map.has_key?(entry, :metadata))  # false
IO.inspect(Map.has_key?(entry_with_meta, :metadata))  # true
```

---

## Pipe Operator (|>)

### Basic Syntax
```elixir
# Without pipe (nested calls, hard to read)
result = function3(function2(function1(data)))

# With pipe (left-to-right flow, readable)
result = data
  |> function1()
  |> function2()
  |> function3()
```

### Healthcare Example (Medical Data Pipeline)
```elixir
defmodule Healthcare.MedicalDataPipeline do
  @doc "Process patient admission data"
  def process_admission(patient_data) do
    patient_data
    |> validate_cpf()
    |> encrypt_phi()
    |> transform_to_fhir()
    |> store_in_database()
    |> audit_log()
    |> notify_care_team()
  end
  
  defp validate_cpf(%{cpf: cpf} = data) do
    case Healthcare.Validators.cpf_valid?(cpf) do
      true -> {:ok, data}
      false -> {:error, :invalid_cpf}
    end
  end
  
  defp encrypt_phi({:ok, data}) do
    encrypted = %{
      data
      | medical_history: Healthcare.Crypto.encrypt(data.medical_history),
        medications: Healthcare.Crypto.encrypt(data.medications)
    }
    {:ok, encrypted}
  end
  defp encrypt_phi(error), do: error
  
  defp transform_to_fhir({:ok, data}) do
    fhir_resource = Healthcare.FHIR.Patient.from_internal(data)
    {:ok, fhir_resource}
  end
  defp transform_to_fhir(error), do: error
  
  defp store_in_database({:ok, fhir_resource}) do
    case Healthcare.Repo.insert(fhir_resource) do
      {:ok, patient} -> {:ok, patient}
      {:error, changeset} -> {:error, {:database_error, changeset}}
    end
  end
  defp store_in_database(error), do: error
  
  defp audit_log({:ok, patient} = result) do
    Healthcare.AuditLog.write("patient_created", patient.id, patient)
    result
  end
  defp audit_log(error), do: error
  
  defp notify_care_team({:ok, patient} = result) do
    Healthcare.Notifications.send_to_care_team(patient.id)
    result
  end
  defp notify_care_team(error), do: error
end
```

---

## Anonymous Functions

### Syntax
```elixir
# Anonymous function (lambda)
add = fn a, b -> a + b end
add.(2, 3)  # 5

# Shorthand syntax (capture operator)
add = &(&1 + &2)
add.(2, 3)  # 5

# Multiple clauses
handle_result = fn
  {:ok, value} -> "Success: #{value}"
  {:error, reason} -> "Error: #{reason}"
end

handle_result.({:ok, 42})     # "Success: 42"
handle_result.({:error, "fail"})  # "Error: fail"
```

### Healthcare Example (Data Transformation)
```elixir
defmodule Healthcare.DataTransform do
  @doc "Transform lab results with custom functions"
  def transform_lab_results(results, transformers) do
    Enum.map(results, fn result ->
      Enum.reduce(transformers, result, fn transformer, acc ->
        transformer.(acc)
      end)
    end)
  end
end

# Usage
lab_results = [
  %{test: "glucose", value: 180, unit: "mg/dL"},
  %{test: "cholesterol", value: 220, unit: "mg/dL"}
]

transformers = [
  # Add timestamp
  &Map.put(&1, :timestamp, DateTime.utc_now()),
  
  # Add risk level
  fn result ->
    risk = cond do
      result.test == "glucose" and result.value > 140 -> "high"
      result.test == "cholesterol" and result.value > 200 -> "high"
      true -> "normal"
    end
    Map.put(result, :risk_level, risk)
  end,
  
  # Add LOINC code
  fn result ->
    loinc = case result.test do
      "glucose" -> "2345-7"
      "cholesterol" -> "2093-3"
      _ -> nil
    end
    Map.put(result, :loinc_code, loinc)
  end
]

transformed = Healthcare.DataTransform.transform_lab_results(lab_results, transformers)
```

---

## Modules and Functions

### Module Definition
```elixir
defmodule Healthcare.Patient do
  @moduledoc """
  Patient management module with LGPD compliance.
  
  All functions maintain audit trails per LGPD Art. 46.
  """
  
  # Module attribute (compile-time constant)
  @max_age 150
  
  @doc """
  Creates a new patient with validation.
  
  ## Examples
  
      iex> Healthcare.Patient.create(%{name: "João", cpf: "12345678901"})
      {:ok, %Patient{}}
  """
  @spec create(map()) :: {:ok, Patient.t()} | {:error, atom()}
  def create(attrs) do
    # Public function (accessible outside module)
  end
  
  # Private function (only accessible within module)
  defp validate_age(birth_date) do
    age = calculate_age(birth_date)
    age >= 0 and age <= @max_age
  end
  
  defp calculate_age(birth_date) do
    Date.diff(Date.utc_today(), birth_date) / 365.25
  end
end
```

### Guards
```elixir
defmodule Healthcare.Validator do
  # Guard clause (compile-time check)
  def validate_cpf(cpf) when is_binary(cpf) and byte_size(cpf) == 11 do
    # CPF validation logic
    :ok
  end
  
  def validate_cpf(_invalid) do
    {:error, :invalid_cpf}
  end
  
  # Multiple guards
  def validate_vital_sign(type, value) 
      when type in [:heart_rate, :blood_pressure, :temperature] 
      and is_number(value) do
    # Validation logic
  end
end
```

---

## Enumerables (Collections)

### Lists
```elixir
# List (linked list)
patients = [
  %{id: 1, name: "João"},
  %{id: 2, name: "Maria"},
  %{id: 3, name: "Pedro"}
]

# Enum functions
Enum.map(patients, & &1.name)  # ["João", "Maria", "Pedro"]
Enum.filter(patients, fn p -> p.id > 1 end)  # [%{id: 2}, %{id: 3}]
Enum.reduce(patients, 0, fn _p, acc -> acc + 1 end)  # 3 (count)

# List comprehension
for patient <- patients, patient.id > 1, do: patient.name
# ["Maria", "Pedro"]
```

### Maps
```elixir
# Map (key-value pairs)
patient = %{
  id: 1,
  name: "João Silva",
  cpf: "12345678901",
  birth_date: ~D[1985-03-15]
}

# Access
patient[:name]  # "João Silva"
patient.name    # "João Silva" (only works with atom keys)

# Update (returns new map)
updated_patient = %{patient | name: "João Carlos Silva"}

# Add key
with_email = Map.put(patient, :email, "joao@example.com")

# Pattern matching
%{name: name, cpf: cpf} = patient
# name = "João Silva", cpf = "12345678901"
```

### Keyword Lists
```elixir
# Keyword list (list of 2-tuples, keys are atoms)
options = [
  validate: true,
  encrypt: true,
  audit_log: true
]

# Access
options[:validate]  # true

# Used for function options
def create_patient(attrs, opts \\ []) do
  validate? = Keyword.get(opts, :validate, true)  # default true
  encrypt? = Keyword.get(opts, :encrypt, true)
  
  # ...
end

create_patient(attrs, validate: false, encrypt: true)
```

---

## with Expression

### Error Handling Pipeline
```elixir
defmodule Healthcare.PatientService do
  def register_patient(attrs) do
    with {:ok, validated} <- validate_attrs(attrs),
         {:ok, encrypted} <- encrypt_phi(validated),
         {:ok, fhir_resource} <- to_fhir(encrypted),
         {:ok, patient} <- Healthcare.Repo.insert(fhir_resource),
         :ok <- audit_log(patient),
         :ok <- notify_care_team(patient) do
      {:ok, patient}
    else
      {:error, :invalid_cpf} ->
        {:error, "CPF inválido. Verifique o número."}
      
      {:error, {:database_error, changeset}} ->
        {:error, "Erro ao salvar: #{format_errors(changeset)}"}
      
      {:error, reason} ->
        {:error, "Erro ao registrar paciente: #{inspect(reason)}"}
    end
  end
  
  defp validate_attrs(attrs) do
    # Validation logic
  end
  
  defp encrypt_phi(data) do
    # Encryption logic
  end
  
  # ... other private functions
end
```

---

## Structs (Typed Maps)

### Definition
```elixir
defmodule Healthcare.Patient do
  @enforce_keys [:cpf, :name, :birth_date]
  
  defstruct [
    :id,
    :cpf,
    :name,
    :birth_date,
    :email,
    :phone,
    medical_history: [],
    medications: [],
    allergies: [],
    inserted_at: nil,
    updated_at: nil
  ]
  
  @type t :: %__MODULE__{
    id: String.t() | nil,
    cpf: String.t(),
    name: String.t(),
    birth_date: Date.t(),
    email: String.t() | nil,
    phone: String.t() | nil,
    medical_history: list(),
    medications: list(),
    allergies: list(),
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }
end

# Usage
patient = %Healthcare.Patient{
  cpf: "12345678901",
  name: "João Silva",
  birth_date: ~D[1985-03-15]
}

# Pattern matching on structs
%Healthcare.Patient{name: name, cpf: cpf} = patient

# Update struct
updated = %{patient | email: "joao@example.com"}
```

---

## Sigils

### Common Sigils
```elixir
# String sigils
~s(string with "quotes")  # "string with \"quotes\""
~S(no \n interpolation)   # "no \\n interpolation"

# Regex
regex = ~r/^\d{11}$/  # CPF pattern

# Date/Time
date = ~D[2025-09-30]  # Date struct
time = ~T[10:30:00]    # Time struct
datetime = ~U[2025-09-30 10:30:00Z]  # DateTime (UTC)

# Charlists
~c(hello)  # 'hello' (Erlang-style string)

# Word lists
~w(patient doctor nurse)  # ["patient", "doctor", "nurse"]
~w(patient doctor nurse)a  # [:patient, :doctor, :nurse] (atoms)
```

### Healthcare Example
```elixir
defmodule Healthcare.Validators do
  @cpf_regex ~r/^\d{11}$/
  @crm_regex ~r/^\d{4,6}$/
  @date_regex ~r/^\d{4}-\d{2}-\d{2}$/
  
  def validate_cpf(cpf), do: Regex.match?(@cpf_regex, cpf)
  def validate_crm(crm), do: Regex.match?(@crm_regex, crm)
  
  def parse_date(date_string) do
    case Regex.match?(@date_regex, date_string) do
      true -> Date.from_iso8601(date_string)
      false -> {:error, :invalid_date_format}
    end
  end
end
```

---

## References

### Official Documentation
- [Elixir Getting Started](https://elixir-lang.org/getting-started/introduction.html) (L0_CANONICAL)
- [Elixir Documentation](https://hexdocs.pm/elixir/) (L0_CANONICAL)
- [Erlang Documentation](https://www.erlang.org/doc) (L0_CANONICAL)

### Books
- [Programming Elixir](https://pragprog.com/titles/elixir16/programming-elixir-1-6/) (L2_VALIDATED)
- [Elixir in Action](https://www.manning.com/books/elixir-in-action-second-edition) (L2_VALIDATED)

---

**DSM**: [L1:infrastructure | L2:elixir_core | L3:fundamentals | L4:guide]
**Source**: `01-elixir-wasm-host-platform.md` (Elixir core sections)
**Version**: 1.0.0
**Related**:
- [Functional Programming](./functional-programming.md)
- [OTP Supervision Trees](../otp-deep-dive/supervision-trees.md)
- [ADR 001: Elixir Host Choice](../../01-ARCHITECTURE/adrs/001-elixir-host-choice.md)
