# Phoenix LiveView Patterns for Healthcare

**Framework**: Phoenix LiveView 1.0.1
**Phoenix**: 1.8.0
**Elixir**: 1.17.3
**Healthcare Context**: Real-time patient monitoring, telemedicine UIs
**Last Updated**: 2025-09-30

---

## Overview

**Phoenix LiveView** enables real-time, interactive web applications without writing JavaScript. The server renders HTML and pushes updates over WebSocket.

**Healthcare Use Cases**:
- **Patient monitoring dashboards** (vital signs, alerts)
- **Telemedicine consultations** (video + real-time notes)
- **EHR interfaces** (instant search, live updates)
- **Clinical decision support** (drug interaction alerts)

**Performance**: 2.1M+ concurrent WebSocket connections (validated benchmark).

---

## Core Concepts

### LiveView Lifecycle

```elixir
defmodule HealthcareWeb.PatientMonitorLive do
  use HealthcareWeb, :live_view
  
  # 1. Mount (initial HTTP request)
  @impl true
  def mount(%{"patient_id" => patient_id}, _session, socket) do
    if connected?(socket) do
      # 2. Connected (WebSocket established)
      Healthcare.PubSub.subscribe("patient:#{patient_id}")
    end
    
    patient = Healthcare.Patients.get_patient!(patient_id)
    
    {:ok, assign(socket, patient: patient, vital_signs: [])}
  end
  
  # 3. Render (HTML template)
  @impl true
  def render(assigns) do
    ~H"""
    <div class="patient-monitor">
      <h1><%= @patient.name %></h1>
      
      <div class="vital-signs">
        <%= for vital <- @vital_signs do %>
          <div class="vital-sign">
            <span><%= vital.type %></span>
            <span><%= vital.value %></span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 4. Handle events (user interactions)
  @impl true
  def handle_event("refresh", _params, socket) do
    vital_signs = Healthcare.VitalSigns.latest(socket.assigns.patient.id)
    {:noreply, assign(socket, vital_signs: vital_signs)}
  end
  
  # 5. Handle PubSub messages (real-time updates)
  @impl true
  def handle_info({:new_vital_sign, vital}, socket) do
    vital_signs = [vital | socket.assigns.vital_signs]
    {:noreply, assign(socket, vital_signs: vital_signs)}
  end
end
```

---

## Pattern 1: Real-Time Patient Monitoring

### Use Case

Display patient vital signs updating in real-time from monitoring devices.

### Implementation

```elixir
defmodule HealthcareWeb.VitalSignsLive do
  use HealthcareWeb, :live_view
  
  @impl true
  def mount(%{"patient_id" => patient_id}, _session, socket) do
    if connected?(socket) do
      # Subscribe to patient's vital signs topic
      Phoenix.PubSub.subscribe(Healthcare.PubSub, "patient:#{patient_id}:vitals")
      
      # Send initial update after 100ms (avoid cold start delay)
      Process.send_after(self(), :update_vitals, 100)
    end
    
    patient = Healthcare.Patients.get_patient!(patient_id)
    
    socket = socket
      |> assign(:patient, patient)
      |> assign(:vital_signs, %{})
      |> assign(:alerts, [])
    
    {:ok, socket}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="vital-signs-monitor">
      <div class="patient-header">
        <h2><%= @patient.name %></h2>
        <span>MRN: <%= @patient.medical_record_number %></span>
      </div>
      
      <div class="vitals-grid">
        <div class="vital-card" id="heart-rate">
          <span class="vital-label">Heart Rate</span>
          <span class="vital-value <%= heart_rate_class(@vital_signs) %>">
            <%= @vital_signs[:heart_rate] || "--" %>
          </span>
          <span class="vital-unit">bpm</span>
        </div>
        
        <div class="vital-card" id="blood-pressure">
          <span class="vital-label">Blood Pressure</span>
          <span class="vital-value <%= bp_class(@vital_signs) %>">
            <%= format_bp(@vital_signs) %>
          </span>
          <span class="vital-unit">mmHg</span>
        </div>
        
        <div class="vital-card" id="spo2">
          <span class="vital-label">SpO₂</span>
          <span class="vital-value <%= spo2_class(@vital_signs) %>">
            <%= @vital_signs[:spo2] || "--" %>
          </span>
          <span class="vital-unit">%</span>
        </div>
        
        <div class="vital-card" id="temperature">
          <span class="vital-label">Temperature</span>
          <span class="vital-value <%= temp_class(@vital_signs) %>">
            <%= @vital_signs[:temperature] || "--" %>
          </span>
          <span class="vital-unit">°C</span>
        </div>
      </div>
      
      <div class="alerts">
        <%= for alert <- @alerts do %>
          <div class={"alert alert-#{alert.severity}"}>
            <span class="alert-icon">⚠</span>
            <span><%= alert.message %></span>
            <button phx-click="dismiss_alert" phx-value-id={alert.id}>✕</button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
  
  @impl true
  def handle_info(:update_vitals, socket) do
    # Fetch latest vitals from device gateway
    vitals = Healthcare.DeviceGateway.get_latest_vitals(socket.assigns.patient.id)
    
    socket = socket
      |> assign(:vital_signs, vitals)
      |> check_for_alerts(vitals)
    
    {:noreply, socket}
  end
  
  @impl true
  def handle_info({:vital_sign_update, vital_type, value}, socket) do
    # Real-time update from PubSub
    vitals = Map.put(socket.assigns.vital_signs, vital_type, value)
    
    socket = socket
      |> assign(:vital_signs, vitals)
      |> check_for_alerts(vitals)
    
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("dismiss_alert", %{"id" => alert_id}, socket) do
    alerts = Enum.reject(socket.assigns.alerts, fn alert -> alert.id == alert_id end)
    {:noreply, assign(socket, :alerts, alerts)}
  end
  
  # Clinical decision support: Check for abnormal vitals
  defp check_for_alerts(socket, vitals) do
    alerts = []
    
    alerts = if vitals[:heart_rate] && (vitals[:heart_rate] < 40 || vitals[:heart_rate] > 120) do
      [%{id: "hr_#{System.unique_integer()}", severity: "critical", 
         message: "Abnormal heart rate: #{vitals[:heart_rate]} bpm"} | alerts]
    else
      alerts
    end
    
    alerts = if vitals[:spo2] && vitals[:spo2] < 90 do
      [%{id: "spo2_#{System.unique_integer()}", severity: "critical",
         message: "Low oxygen saturation: #{vitals[:spo2]}%"} | alerts]
    else
      alerts
    end
    
    assign(socket, :alerts, alerts)
  end
  
  # Helpers for CSS classes based on clinical thresholds
  defp heart_rate_class(%{heart_rate: hr}) when hr < 40 or hr > 120, do: "critical"
  defp heart_rate_class(%{heart_rate: hr}) when hr < 60 or hr > 100, do: "warning"
  defp heart_rate_class(_), do: "normal"
  
  defp bp_class(%{systolic: sys}) when sys > 180, do: "critical"
  defp bp_class(%{systolic: sys}) when sys > 140, do: "warning"
  defp bp_class(_), do: "normal"
  
  defp spo2_class(%{spo2: spo2}) when spo2 < 90, do: "critical"
  defp spo2_class(%{spo2: spo2}) when spo2 < 95, do: "warning"
  defp spo2_class(_), do: "normal"
  
  defp temp_class(%{temperature: temp}) when temp > 38.5 or temp < 36.0, do: "warning"
  defp temp_class(_), do: "normal"
  
  defp format_bp(%{systolic: sys, diastolic: dia}), do: "#{sys}/#{dia}"
  defp format_bp(_), do: "--/--"
end
```

### PubSub Publisher (Device Gateway)

```elixir
defmodule Healthcare.DeviceGateway do
  @doc "Publish vital sign update to all subscribed LiveViews"
  def publish_vital_sign(patient_id, vital_type, value) do
    Phoenix.PubSub.broadcast(
      Healthcare.PubSub,
      "patient:#{patient_id}:vitals",
      {:vital_sign_update, vital_type, value}
    )
    
    # HIPAA audit trail
    Healthcare.AuditLog.write(%{
      event: "vital_sign_recorded",
      patient_id: patient_id,
      vital_type: vital_type,
      value: value,
      timestamp: DateTime.utc_now(),
      compliance_tag: "HIPAA_164_312_b"
    })
  end
end
```

---

## Pattern 2: Live Search (Autocomplete)

### Use Case

Search patient records with instant results as user types (debounced).

### Implementation

```elixir
defmodule HealthcareWeb.PatientSearchLive do
  use HealthcareWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    socket = socket
      |> assign(:query, "")
      |> assign(:results, [])
      |> assign(:loading, false)
    
    {:ok, socket}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="patient-search">
      <form phx-submit="search">
        <input
          type="text"
          name="query"
          value={@query}
          phx-keyup="search"
          phx-debounce="300"
          placeholder="Search patients (name, CPF, MRN)..."
          autocomplete="off"
        />
        
        <%= if @loading do %>
          <span class="loading-spinner">⟳</span>
        <% end %>
      </form>
      
      <div class="search-results">
        <%= if @query != "" and @results == [] do %>
          <p class="no-results">No patients found</p>
        <% end %>
        
        <%= for patient <- @results do %>
          <div class="patient-result" phx-click="select_patient" phx-value-id={patient.id}>
            <div class="patient-info">
              <h3><%= patient.name %></h3>
              <span>CPF: <%= format_cpf(patient.cpf) %></span>
              <span>MRN: <%= patient.medical_record_number %></span>
            </div>
            <div class="patient-meta">
              <span>Age: <%= calculate_age(patient.birth_date) %></span>
              <span>Last visit: <%= format_date(patient.last_visit) %></span>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
  
  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    # Debouncing handled by phx-debounce="300"
    socket = socket
      |> assign(:query, query)
      |> assign(:loading, true)
    
    # Async search to avoid blocking
    send(self(), {:execute_search, query})
    
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("select_patient", %{"id" => patient_id}, socket) do
    # Navigate to patient detail page
    {:noreply, push_navigate(socket, to: ~p"/patients/#{patient_id}")}
  end
  
  @impl true
  def handle_info({:execute_search, query}, socket) do
    results = if String.length(query) >= 3 do
      # PostgreSQL full-text search + trigram similarity
      Healthcare.Patients.search(query, limit: 10)
    else
      []
    end
    
    socket = socket
      |> assign(:results, results)
      |> assign(:loading, false)
    
    {:noreply, socket}
  end
  
  defp format_cpf(cpf) do
    # 12345678901 -> 123.456.789-01
    Regex.replace(~r/(\d{3})(\d{3})(\d{3})(\d{2})/, cpf, "\\1.\\2.\\3-\\4")
  end
  
  defp calculate_age(birth_date) do
    Date.diff(Date.utc_today(), birth_date) |> div(365)
  end
  
  defp format_date(nil), do: "Never"
  defp format_date(date), do: Calendar.strftime(date, "%d/%m/%Y")
end
```

---

## Pattern 3: Form Validation (Live Feedback)

### Use Case

Validate patient registration form with instant feedback (CPF, email, phone).

### Implementation

```elixir
defmodule HealthcareWeb.PatientFormLive do
  use HealthcareWeb, :live_view
  
  alias Healthcare.Patients
  alias Healthcare.Patients.Patient
  
  @impl true
  def mount(_params, _session, socket) do
    changeset = Patients.change_patient(%Patient{})
    
    socket = socket
      |> assign(:changeset, changeset)
      |> assign(:cpf_valid, nil)
      |> assign(:checking_cpf, false)
    
    {:ok, socket}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="patient-form">
      <.form for={@changeset} phx-change="validate" phx-submit="save">
        <div class="form-group">
          <label>CPF</label>
          <input
            type="text"
            name="patient[cpf]"
            value={@changeset.changes[:cpf] || ""}
            phx-debounce="500"
            class={cpf_input_class(@cpf_valid, @checking_cpf)}
          />
          
          <%= if @checking_cpf do %>
            <span class="validation-feedback">Validating CPF...</span>
          <% else %>
            <%= case @cpf_valid do %>
              <% true -> %>
                <span class="validation-feedback valid">✓ Valid CPF</span>
              <% false -> %>
                <span class="validation-feedback invalid">✗ Invalid CPF</span>
              <% nil -> %>
                <span class="validation-feedback"></span>
            <% end %>
          <% end %>
          
          <.error :for={error <- Keyword.get_values(@changeset.errors, :cpf)}>
            <%= translate_error(error) %>
          </.error>
        </div>
        
        <div class="form-group">
          <label>Full Name</label>
          <input
            type="text"
            name="patient[name]"
            value={@changeset.changes[:name] || ""}
            phx-debounce="blur"
          />
          <.error :for={error <- Keyword.get_values(@changeset.errors, :name)}>
            <%= translate_error(error) %>
          </.error>
        </div>
        
        <div class="form-group">
          <label>Birth Date</label>
          <input
            type="date"
            name="patient[birth_date]"
            value={@changeset.changes[:birth_date] || ""}
          />
          <.error :for={error <- Keyword.get_values(@changeset.errors, :birth_date)}>
            <%= translate_error(error) %>
          </.error>
        </div>
        
        <div class="form-actions">
          <button type="submit" disabled={not @changeset.valid?}>
            Register Patient
          </button>
        </div>
      </.form>
    </div>
    """
  end
  
  @impl true
  def handle_event("validate", %{"patient" => patient_params}, socket) do
    changeset = %Patient{}
      |> Patients.change_patient(patient_params)
      |> Map.put(:action, :validate)
    
    # Async CPF validation
    if cpf = patient_params["cpf"] do
      socket = assign(socket, :checking_cpf, true)
      send(self(), {:validate_cpf, cpf})
      {:noreply, assign(socket, :changeset, changeset)}
    else
      {:noreply, assign(socket, changeset: changeset, cpf_valid: nil)}
    end
  end
  
  @impl true
  def handle_event("save", %{"patient" => patient_params}, socket) do
    case Patients.create_patient(patient_params) do
      {:ok, patient} ->
        socket = socket
          |> put_flash(:info, "Patient registered successfully")
          |> push_navigate(to: ~p"/patients/#{patient.id}")
        
        {:noreply, socket}
      
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
  
  @impl true
  def handle_info({:validate_cpf, cpf}, socket) do
    # Call WASM plugin for CPF validation
    valid = Healthcare.Validators.cpf_valid?(cpf)
    
    socket = socket
      |> assign(:cpf_valid, valid)
      |> assign(:checking_cpf, false)
    
    {:noreply, socket}
  end
  
  defp cpf_input_class(true, false), do: "valid"
  defp cpf_input_class(false, false), do: "invalid"
  defp cpf_input_class(_, true), do: "validating"
  defp cpf_input_class(nil, false), do: ""
end
```

---

## Pattern 4: Optimistic Updates

### Use Case

Update UI immediately (optimistic) while request is in-flight, rollback if fails.

```elixir
defmodule HealthcareWeb.PrescriptionLive do
  use HealthcareWeb, :live_view
  
  @impl true
  def handle_event("toggle_active", %{"medication_id" => med_id}, socket) do
    # Find medication
    medication = Enum.find(socket.assigns.medications, fn m -> m.id == med_id end)
    
    # Optimistic update (immediate UI feedback)
    updated_medications = Enum.map(socket.assigns.medications, fn m ->
      if m.id == med_id do
        %{m | active: not m.active}
      else
        m
      end
    end)
    
    socket = assign(socket, :medications, updated_medications)
    
    # Async server update
    send(self(), {:update_medication, med_id, not medication.active})
    
    {:noreply, socket}
  end
  
  @impl true
  def handle_info({:update_medication, med_id, active}, socket) do
    case Healthcare.Medications.update_status(med_id, active) do
      {:ok, _medication} ->
        # Success - optimistic update was correct
        {:noreply, socket}
      
      {:error, _changeset} ->
        # Failure - rollback optimistic update
        medications = Healthcare.Medications.list_patient_medications(socket.assigns.patient_id)
        
        socket = socket
          |> assign(:medications, medications)
          |> put_flash(:error, "Failed to update medication")
        
        {:noreply, socket}
    end
  end
end
```

---

## Pattern 5: Pagination with Streams

### Use Case

Display large patient lists with efficient memory usage (Phoenix.LiveView.stream/4).

```elixir
defmodule HealthcareWeb.PatientListLive do
  use HealthcareWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    socket = socket
      |> assign(:page, 1)
      |> stream(:patients, [])
      |> load_patients()
    
    {:ok, socket}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="patient-list">
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>MRN</th>
            <th>Last Visit</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="patients" phx-update="stream">
          <tr :for={{dom_id, patient} <- @streams.patients} id={dom_id}>
            <td><%= patient.name %></td>
            <td><%= patient.medical_record_number %></td>
            <td><%= format_date(patient.last_visit) %></td>
            <td>
              <button phx-click="view_patient" phx-value-id={patient.id}>View</button>
            </td>
          </tr>
        </tbody>
      </table>
      
      <button phx-click="load_more">Load More</button>
    </div>
    """
  end
  
  @impl true
  def handle_event("load_more", _params, socket) do
    {:noreply, load_patients(socket)}
  end
  
  defp load_patients(socket) do
    page = socket.assigns.page
    patients = Healthcare.Patients.list_patients(page: page, per_page: 50)
    
    socket
    |> stream(:patients, patients)
    |> assign(:page, page + 1)
  end
end
```

---

## Performance Optimizations

### 1. temporary_assigns

```elixir
# Large datasets not needed after render
def mount(_params, _session, socket) do
  socket = socket
    |> assign(:large_dataset, fetch_large_dataset())
    |> assign(:temporary_assigns, [large_dataset: []])
  
  {:ok, socket}
end

# large_dataset cleared from memory after render
```

### 2. handle_continue/2

```elixir
# Defer expensive work until after initial render
def mount(_params, _session, socket) do
  {:ok, socket, {:continue, :load_data}}
end

def handle_continue(:load_data, socket) do
  data = expensive_database_query()
  {:noreply, assign(socket, :data, data)}
end
```

### 3. phx-throttle / phx-debounce

```html
<!-- Throttle: Max 1 event per 500ms (for frequently firing events) -->
<div phx-mousemove="track_mouse" phx-throttle="500">...</div>

<!-- Debounce: Wait 300ms after last keystroke -->
<input phx-keyup="search" phx-debounce="300" />
```

---

## References

### Official Documentation
- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view) (L0_CANONICAL)
- [Phoenix PubSub](https://hexdocs.pm/phoenix_pubsub) (L0_CANONICAL)

### Books
- [Programming Phoenix LiveView](https://pragprog.com/titles/liveview/programming-phoenix-liveview/) (L2_VALIDATED)

### Industry Reports
- [Elixir Census 2024](https://elixir-lang.org/blog/2024/06/20/elixir-census-2024/) (L2_VALIDATED)

---

**DSM**: [L1:ui_ux | L2:healthcare | L3:implementation | L4:guide]
**Source**: `01-elixir-wasm-host-platform.md` (Phoenix LiveView sections)
**Version**: 1.0.0
**Related**:
- [Phoenix Framework Overview](./framework-overview.md)
- [Elixir Language Core](../fundamentals/language-core.md)
- [ADR 001: Elixir Host Choice](../../01-ARCHITECTURE/adrs/001-elixir-host-choice.md)
