# Functional Programming in Elixir

**Paradigm**: Functional, Declarative, Immutable
**Language**: Elixir 1.17.3
**Healthcare Context**: Pure functions for medical calculations, immutable audit trails
**Last Updated**: 2025-09-30

---

## Overview

Elixir is a **purely functional language** - all functions are pure (deterministic, no side effects) and data is immutable. This paradigm provides critical benefits for healthcare systems:

- **Auditability**: Immutable data = tamper-proof audit trails (LGPD Art. 46, HIPAA 164.312(b))
- **Testability**: Pure functions always produce same output for same input
- **Concurrency Safety**: No race conditions (no shared mutable state)
- **Reasoning**: Easier to verify correctness (critical for medical algorithms)

---

## Core Principles

### 1. Immutability

**Rule**: Once created, data structures CANNOT be modified.

```elixir
# Example: Updating patient record creates NEW record
patient = %{id: 1, name: "João Silva", age: 40}

# This creates a NEW map, original unchanged
updated_patient = %{patient | age: 41}

IO.inspect(patient)         # %{id: 1, name: "João Silva", age: 40}
IO.inspect(updated_patient) # %{id: 1, name: "João Silva", age: 41}
```

#### Healthcare Benefit: Audit Trails

```elixir
defmodule Healthcare.PatientHistory do
  @doc """
  Maintains immutable patient history - every change creates new version.
  
  LGPD Art. 46: Audit logs must be tamper-proof.
  """
  def create_patient(attrs) do
    %{
      id: Ecto.UUID.generate(),
      data: attrs,
      version: 1,
      created_at: DateTime.utc_now(),
      modified_at: DateTime.utc_now(),
      history: []
    }
  end
  
  def update_patient(patient, new_attrs) do
    # Create snapshot of CURRENT state before updating
    snapshot = %{
      version: patient.version,
      data: patient.data,
      modified_at: patient.modified_at
    }
    
    # Return NEW patient with updated data + history
    %{
      patient
      | data: Map.merge(patient.data, new_attrs),
        version: patient.version + 1,
        modified_at: DateTime.utc_now(),
        history: [snapshot | patient.history]  # Prepend to history
    }
  end
  
  @doc "Retrieve any historical version (immutability guarantees integrity)"
  def get_version(patient, version_number) do
    cond do
      version_number == patient.version ->
        {:ok, patient.data}
      
      version_number < patient.version ->
        case Enum.find(patient.history, fn snapshot -> 
          snapshot.version == version_number 
        end) do
          nil -> {:error, :version_not_found}
          snapshot -> {:ok, snapshot.data}
        end
      
      true ->
        {:error, :future_version}
    end
  end
end

# Usage
patient = Healthcare.PatientHistory.create_patient(%{name: "João", cpf: "12345678901"})
# version: 1, history: []

patient = Healthcare.PatientHistory.update_patient(patient, %{phone: "+5511999999999"})
# version: 2, history: [version 1 snapshot]

patient = Healthcare.PatientHistory.update_patient(patient, %{email: "joao@example.com"})
# version: 3, history: [version 2 snapshot, version 1 snapshot]

# Audit: Retrieve any historical version
{:ok, original_data} = Healthcare.PatientHistory.get_version(patient, 1)
# Returns original data (name + cpf only, no phone/email)
```

---

### 2. Pure Functions

**Definition**: Function output depends ONLY on input parameters (no hidden state, no side effects).

#### Impure vs Pure

```elixir
# ❌ IMPURE: Depends on external state (current time)
defmodule Impure do
  def calculate_age(birth_date) do
    # Bad: Uses DateTime.utc_now() - not deterministic
    Date.diff(DateTime.utc_today(), birth_date) / 365.25
  end
end

# ✅ PURE: All inputs explicit
defmodule Pure do
  def calculate_age(birth_date, current_date) do
    # Good: Both inputs explicit - deterministic
    Date.diff(current_date, birth_date) / 365.25
  end
end

# Testing
birth_date = ~D[1985-03-15]

# Impure: Result changes every day (not testable)
Impure.calculate_age(birth_date)  # 40.8 today, 40.9 tomorrow

# Pure: Result always same for same inputs (testable)
Pure.calculate_age(birth_date, ~D[2025-09-30])  # Always 40.54
Pure.calculate_age(birth_date, ~D[2024-01-01])  # Always 38.80
```

#### Healthcare Example: BMI Calculation

```elixir
defmodule Healthcare.Metrics do
  @doc """
  Pure function - calculates BMI from explicit inputs.
  
  Formula: BMI = weight (kg) / height (m)^2
  WHO Classification:
  - < 18.5: Underweight
  - 18.5-24.9: Normal
  - 25.0-29.9: Overweight
  - ≥ 30.0: Obese
  """
  @spec calculate_bmi(number(), number()) :: {:ok, float()} | {:error, atom()}
  def calculate_bmi(weight_kg, height_m) 
      when is_number(weight_kg) and is_number(height_m) 
      and weight_kg > 0 and height_m > 0 do
    bmi = weight_kg / (height_m * height_m)
    {:ok, Float.round(bmi, 2)}
  end
  
  def calculate_bmi(_, _), do: {:error, :invalid_input}
  
  @spec classify_bmi(float()) :: String.t()
  def classify_bmi(bmi) do
    cond do
      bmi < 18.5 -> "Underweight"
      bmi < 25.0 -> "Normal"
      bmi < 30.0 -> "Overweight"
      true -> "Obese"
    end
  end
  
  @doc "Compose pure functions"
  def analyze_patient(weight_kg, height_m) do
    with {:ok, bmi} <- calculate_bmi(weight_kg, height_m) do
      %{
        bmi: bmi,
        classification: classify_bmi(bmi),
        healthy: bmi >= 18.5 and bmi < 25.0
      }
    end
  end
end

# Testing is trivial (pure functions)
ExUnit.start()

defmodule Healthcare.MetricsTest do
  use ExUnit.Case
  
  test "BMI calculation is deterministic" do
    # Same inputs ALWAYS produce same output
    assert Healthcare.Metrics.calculate_bmi(70, 1.75) == {:ok, 22.86}
    assert Healthcare.Metrics.calculate_bmi(70, 1.75) == {:ok, 22.86}
    assert Healthcare.Metrics.calculate_bmi(70, 1.75) == {:ok, 22.86}
  end
  
  test "BMI classification" do
    assert Healthcare.Metrics.classify_bmi(17.0) == "Underweight"
    assert Healthcare.Metrics.classify_bmi(22.0) == "Normal"
    assert Healthcare.Metrics.classify_bmi(27.0) == "Overweight"
    assert Healthcare.Metrics.classify_bmi(32.0) == "Obese"
  end
end
```

---

### 3. Higher-Order Functions

**Definition**: Functions that take other functions as arguments or return functions.

#### Built-in Higher-Order Functions

```elixir
# Enum.map/2 - transform each element
patients = [
  %{name: "João", age: 40},
  %{name: "Maria", age: 35},
  %{name: "Pedro", age: 50}
]

# Extract names
names = Enum.map(patients, fn patient -> patient.name end)
# ["João", "Maria", "Pedro"]

# Shorthand with capture operator
names = Enum.map(patients, & &1.name)

# Enum.filter/2 - select elements matching predicate
seniors = Enum.filter(patients, fn patient -> patient.age >= 50 end)
# [%{name: "Pedro", age: 50}]

# Enum.reduce/3 - accumulate values
total_age = Enum.reduce(patients, 0, fn patient, acc -> acc + patient.age end)
# 125

average_age = total_age / length(patients)
# 41.67
```

#### Healthcare Example: Lab Results Analysis

```elixir
defmodule Healthcare.LabResults do
  @doc """
  Analyze lab results using higher-order functions.
  
  Example dataset:
  [
    %{test: "glucose", value: 180, unit: "mg/dL", date: ~D[2025-09-30]},
    %{test: "cholesterol", value: 220, unit: "mg/dL", date: ~D[2025-09-25]}
  ]
  """
  
  def filter_abnormal_results(results) do
    Enum.filter(results, &is_abnormal?/1)
  end
  
  defp is_abnormal?(%{test: "glucose", value: value}), do: value > 140
  defp is_abnormal?(%{test: "cholesterol", value: value}), do: value > 200
  defp is_abnormal?(%{test: "triglycerides", value: value}), do: value > 150
  defp is_abnormal?(_), do: false
  
  def group_by_test(results) do
    Enum.group_by(results, & &1.test)
  end
  
  def calculate_trends(results) do
    results
    |> group_by_test()
    |> Enum.map(fn {test_name, test_results} ->
      sorted = Enum.sort_by(test_results, & &1.date, Date)
      
      %{
        test: test_name,
        count: length(sorted),
        first_value: List.first(sorted).value,
        last_value: List.last(sorted).value,
        trend: trend_direction(List.first(sorted).value, List.last(sorted).value)
      }
    end)
  end
  
  defp trend_direction(first, last) when last > first, do: :increasing
  defp trend_direction(first, last) when last < first, do: :decreasing
  defp trend_direction(_, _), do: :stable
  
  def generate_summary(results) do
    %{
      total_tests: length(results),
      abnormal_count: length(filter_abnormal_results(results)),
      tests_performed: results |> Enum.map(& &1.test) |> Enum.uniq() |> length(),
      trends: calculate_trends(results)
    }
  end
end

# Usage
lab_results = [
  %{test: "glucose", value: 95, unit: "mg/dL", date: ~D[2025-08-01]},
  %{test: "glucose", value: 110, unit: "mg/dL", date: ~D[2025-08-15]},
  %{test: "glucose", value: 180, unit: "mg/dL", date: ~D[2025-09-01]},
  %{test: "cholesterol", value: 190, unit: "mg/dL", date: ~D[2025-08-01]},
  %{test: "cholesterol", value: 220, unit: "mg/dL", date: ~D[2025-09-01]}
]

summary = Healthcare.LabResults.generate_summary(lab_results)
# %{
#   total_tests: 5,
#   abnormal_count: 2,
#   tests_performed: 2,
#   trends: [
#     %{test: "glucose", count: 3, first_value: 95, last_value: 180, trend: :increasing},
#     %{test: "cholesterol", count: 2, first_value: 190, last_value: 220, trend: :increasing}
#   ]
# }
```

---

### 4. Recursion

**Principle**: Functions call themselves to process data structures (Elixir has no loops).

#### Tail-Call Optimization

```elixir
# ❌ NOT tail-recursive (accumulates stack frames)
def factorial(0), do: 1
def factorial(n), do: n * factorial(n - 1)

# factorial(5) = 5 * factorial(4)
#              = 5 * (4 * factorial(3))
#              = 5 * (4 * (3 * factorial(2)))
#              = 5 * (4 * (3 * (2 * factorial(1))))
#              = 5 * (4 * (3 * (2 * 1)))

# ✅ Tail-recursive (constant stack space)
def factorial(n), do: factorial(n, 1)

defp factorial(0, acc), do: acc
defp factorial(n, acc), do: factorial(n - 1, n * acc)

# factorial(5, 1) -> factorial(4, 5)
#                 -> factorial(3, 20)
#                 -> factorial(2, 60)
#                 -> factorial(1, 120)
#                 -> factorial(0, 120)
#                 -> 120
```

#### Healthcare Example: Medical Record Traversal

```elixir
defmodule Healthcare.RecordSearch do
  @doc """
  Search nested medical records recursively.
  
  Example structure:
  %{
    patient_id: 1,
    consultations: [
      %{date: ~D[2025-01-01], diagnosis: "Hypertension", prescriptions: [...]},
      %{date: ~D[2025-02-15], diagnosis: "Diabetes", prescriptions: [...]}
    ]
  }
  """
  
  @spec find_all_diagnoses(map() | list()) :: [String.t()]
  def find_all_diagnoses(record) do
    find_all_diagnoses(record, [])
  end
  
  # Base cases
  defp find_all_diagnoses(nil, acc), do: acc
  defp find_all_diagnoses([], acc), do: acc
  
  # Recursive cases
  defp find_all_diagnoses([head | tail], acc) do
    # Process head, then tail
    new_acc = find_all_diagnoses(head, acc)
    find_all_diagnoses(tail, new_acc)
  end
  
  defp find_all_diagnoses(%{diagnosis: diagnosis} = map, acc) do
    # Found diagnosis, add to accumulator
    new_acc = [diagnosis | acc]
    
    # Continue searching in map values
    map
    |> Map.delete(:diagnosis)
    |> Map.values()
    |> find_all_diagnoses(new_acc)
  end
  
  defp find_all_diagnoses(map, acc) when is_map(map) do
    # No diagnosis at this level, search nested values
    map
    |> Map.values()
    |> find_all_diagnoses(acc)
  end
  
  defp find_all_diagnoses(_other, acc), do: acc
end

# Usage
medical_record = %{
  patient_id: 1,
  consultations: [
    %{
      date: ~D[2025-01-01],
      diagnosis: "Hypertension",
      prescriptions: [
        %{medication: "Losartan", dosage: "50mg"}
      ]
    },
    %{
      date: ~D[2025-02-15],
      diagnosis: "Type 2 Diabetes",
      exams: [
        %{type: "HbA1c", result: 7.2, diagnosis: "Uncontrolled diabetes"}
      ]
    }
  ]
}

diagnoses = Healthcare.RecordSearch.find_all_diagnoses(medical_record)
# ["Uncontrolled diabetes", "Type 2 Diabetes", "Hypertension"]
```

---

## Function Composition

**Principle**: Combine small, pure functions to build complex logic.

### Pipe Operator (|>)

```elixir
# Without pipes (nested, hard to read)
result = function3(function2(function1(data)))

# With pipes (left-to-right, readable)
result = data
  |> function1()
  |> function2()
  |> function3()
```

### Healthcare Example: Clinical Decision Support

```elixir
defmodule Healthcare.ClinicalDecision do
  @doc """
  Calculate cardiovascular risk score using Framingham Risk Score.
  
  Composed pipeline:
  1. Validate patient data
  2. Calculate individual risk factors
  3. Compute total score
  4. Classify risk level
  5. Generate recommendations
  """
  
  def assess_cardiovascular_risk(patient_data) do
    patient_data
    |> validate_inputs()
    |> calculate_age_points()
    |> calculate_cholesterol_points()
    |> calculate_blood_pressure_points()
    |> calculate_smoking_points()
    |> sum_risk_score()
    |> classify_risk()
    |> generate_recommendations()
  end
  
  defp validate_inputs(%{age: age, cholesterol: chol, systolic_bp: bp} = data) 
       when is_number(age) and is_number(chol) and is_number(bp) do
    {:ok, data}
  end
  defp validate_inputs(_), do: {:error, :invalid_patient_data}
  
  defp calculate_age_points({:ok, %{age: age} = data}) do
    points = cond do
      age < 35 -> 0
      age < 45 -> 3
      age < 55 -> 6
      age < 65 -> 8
      true -> 10
    end
    {:ok, Map.put(data, :age_points, points)}
  end
  defp calculate_age_points(error), do: error
  
  defp calculate_cholesterol_points({:ok, %{cholesterol: chol} = data}) do
    points = cond do
      chol < 160 -> 0
      chol < 200 -> 3
      chol < 240 -> 5
      chol < 280 -> 7
      true -> 9
    end
    {:ok, Map.put(data, :cholesterol_points, points)}
  end
  defp calculate_cholesterol_points(error), do: error
  
  defp calculate_blood_pressure_points({:ok, %{systolic_bp: bp} = data}) do
    points = cond do
      bp < 120 -> 0
      bp < 130 -> 1
      bp < 140 -> 2
      bp < 160 -> 3
      true -> 4
    end
    {:ok, Map.put(data, :bp_points, points)}
  end
  defp calculate_blood_pressure_points(error), do: error
  
  defp calculate_smoking_points({:ok, %{smoker: true} = data}) do
    {:ok, Map.put(data, :smoking_points, 4)}
  end
  defp calculate_smoking_points({:ok, data}) do
    {:ok, Map.put(data, :smoking_points, 0)}
  end
  defp calculate_smoking_points(error), do: error
  
  defp sum_risk_score({:ok, data}) do
    total = (data[:age_points] || 0) +
            (data[:cholesterol_points] || 0) +
            (data[:bp_points] || 0) +
            (data[:smoking_points] || 0)
    {:ok, Map.put(data, :total_score, total)}
  end
  defp sum_risk_score(error), do: error
  
  defp classify_risk({:ok, %{total_score: score} = data}) do
    risk_level = cond do
      score < 10 -> :low
      score < 15 -> :moderate
      score < 20 -> :high
      true -> :very_high
    end
    {:ok, Map.put(data, :risk_level, risk_level)}
  end
  defp classify_risk(error), do: error
  
  defp generate_recommendations({:ok, %{risk_level: risk} = data}) do
    recommendations = case risk do
      :low -> ["Maintain healthy lifestyle", "Annual checkup"]
      :moderate -> ["Lifestyle modifications", "Monitor cholesterol", "Biannual checkup"]
      :high -> ["Statin therapy", "Lifestyle changes", "Quarterly monitoring"]
      :very_high -> ["Aggressive treatment", "Cardiology referral", "Monthly monitoring"]
    end
    {:ok, Map.put(data, :recommendations, recommendations)}
  end
  defp generate_recommendations(error), do: error
end

# Usage
patient = %{
  age: 58,
  cholesterol: 240,
  systolic_bp: 145,
  smoker: true
}

{:ok, assessment} = Healthcare.ClinicalDecision.assess_cardiovascular_risk(patient)
# %{
#   age: 58,
#   cholesterol: 240,
#   systolic_bp: 145,
#   smoker: true,
#   age_points: 8,
#   cholesterol_points: 5,
#   bp_points: 3,
#   smoking_points: 4,
#   total_score: 20,
#   risk_level: :very_high,
#   recommendations: ["Aggressive treatment", "Cardiology referral", "Monthly monitoring"]
# }
```

---

## Referential Transparency

**Definition**: An expression can be replaced by its value without changing program behavior.

```elixir
# Referentially transparent
def add(a, b), do: a + b

x = add(2, 3)  # 5
y = add(2, 3)  # 5

# We can replace add(2, 3) with 5 anywhere
x = 5
y = 5
```

**Healthcare Benefit**: Medical algorithms can be mathematically verified.

```elixir
defmodule Healthcare.DrugDosage do
  @doc """
  Calculate drug dosage - referentially transparent (safe to verify).
  
  Formula: Dose (mg) = Weight (kg) × Dose per kg
  """
  @spec calculate_dose(float(), float()) :: float()
  def calculate_dose(weight_kg, dose_per_kg) do
    weight_kg * dose_per_kg
  end
  
  # Verification: Prove correctness for all inputs
  # calculate_dose(70, 5) = 70 * 5 = 350 (always true)
  # No hidden state, no side effects, mathematically verifiable
end
```

---

## References

### Official Documentation
- [Elixir Getting Started - Recursion](https://elixir-lang.org/getting-started/recursion.html) (L0_CANONICAL)
- [Elixir Enum Module](https://hexdocs.pm/elixir/Enum.html) (L0_CANONICAL)

### Books
- [Elixir in Action, 3rd Edition](https://www.manning.com/books/elixir-in-action-third-edition) (L2_VALIDATED)
  - Chapter 3: "Control Flow" (Pattern matching, recursion)
  - Chapter 4: "Data Abstractions" (Higher-order functions, Enum)
- [Programming Elixir ≥ 1.6](https://pragprog.com/titles/elixir16/programming-elixir-1-6/) (L2_VALIDATED)

### Academic Papers
- [Why Functional Programming Matters](https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf) - John Hughes (L1_ACADEMIC)
- [Functional Programming for the Real World](https://dl.acm.org/doi/10.1145/1592761.1592779) - ACM SIGPLAN (L1_ACADEMIC)

---

**DSM**: [L1:business_logic | L2:healthcare | L3:implementation | L4:guide]
**Source**: `01-elixir-wasm-host-platform.md` (functional programming sections)
**Version**: 1.0.0
**Related**:
- [Elixir Language Core](./language-core.md)
- [OTP Supervision Trees](../otp-deep-dive/supervision-trees.md)
- [ADR 001: Elixir Host Choice](../../01-ARCHITECTURE/adrs/001-elixir-host-choice.md)
