# Observability Stack: Prometheus & Grafana

**Monitoring**: Prometheus 2.55
**Visualization**: Grafana 11.3
**Tracing**: Jaeger (OpenTelemetry 1.32)
**Healthcare Context**: HIPAA audit trails, performance monitoring, SLO tracking
**Last Updated**: 2025-09-30

---

## Overview

**Observability** provides visibility into the Healthcare WASM-Elixir stack:
- **Metrics**: Prometheus (time-series data, alerts)
- **Logs**: Loki (centralized log aggregation)
- **Traces**: Jaeger (distributed tracing via OpenTelemetry)
- **Dashboards**: Grafana (visualization, alerting)

**Healthcare Requirements**:
- HIPAA 164.308(a)(1)(ii)(D): Audit controls, system activity logs
- 99.95% uptime SLO monitoring
- Performance tracking (43.9K req/sec baseline)

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│  Kubernetes Cluster                                       │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─────────────────┐      ┌──────────────────┐          │
│  │ Elixir App      │────► │ Prometheus       │          │
│  │ /metrics        │      │ (Metrics Store)  │          │
│  └─────────────────┘      └────────┬─────────┘          │
│                                     │                     │
│  ┌─────────────────┐               │                     │
│  │ PostgreSQL      │───────────────┤                     │
│  │ /metrics        │               │                     │
│  └─────────────────┘               │                     │
│                                     ▼                     │
│  ┌─────────────────┐      ┌──────────────────┐          │
│  │ Istio Sidecar   │      │ Grafana          │          │
│  │ (Envoy metrics) │      │ (Visualization)  │          │
│  └─────────────────┘      └──────────────────┘          │
│                                                            │
│  ┌─────────────────┐      ┌──────────────────┐          │
│  │ Application     │────► │ Loki             │          │
│  │ (JSON logs)     │      │ (Log Aggregation)│          │
│  └─────────────────┘      └──────────────────┘          │
│                                                            │
│  ┌─────────────────┐      ┌──────────────────┐          │
│  │ OpenTelemetry   │────► │ Jaeger           │          │
│  │ (Traces)        │      │ (Distributed     │          │
│  └─────────────────┘      │  Tracing)        │          │
│                            └──────────────────┘          │
└──────────────────────────────────────────────────────────┘
```

---

## Prometheus Setup

### Deployment

```yaml
# prometheus-deployment.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 30s
      evaluation_interval: 30s
    
    scrape_configs:
    # Elixir application metrics
    - job_name: 'healthcare-app'
      kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
          - healthcare-prod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: healthcare
      - source_labels: [__meta_kubernetes_pod_ip]
        target_label: __address__
        replacement: $1:4000
      - source_labels: [__meta_kubernetes_pod_name]
        target_label: pod
    
    # PostgreSQL metrics
    - job_name: 'postgres'
      static_configs:
      - targets: ['postgres-exporter:9187']
    
    # Node metrics
    - job_name: 'node-exporter'
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - source_labels: [__address__]
        regex: '(.*):10250'
        replacement: '${1}:9100'
        target_label: __address__
    
    # Istio metrics
    - job_name: 'istio-mesh'
      kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
          - healthcare-prod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_container_port_name]
        action: keep
        regex: '.*-envoy-prom'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:v2.55.0
        args:
        - '--config.file=/etc/prometheus/prometheus.yml'
        - '--storage.tsdb.path=/prometheus'
        - '--storage.tsdb.retention.time=30d'
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
        - name: storage
          mountPath: /prometheus
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
      volumes:
      - name: config
        configMap:
          name: prometheus-config
      - name: storage
        persistentVolumeClaim:
          claimName: prometheus-pvc
```

---

## Elixir Metrics Exporter

### Setup Prometheus.ex

```elixir
# mix.exs
defp deps do
  [
    {:prometheus_ex, "~> 3.1"},
    {:prometheus_plugs, "~> 1.1"}
  ]
end
```

### Configure Metrics

```elixir
# lib/healthcare/telemetry.ex
defmodule Healthcare.Telemetry do
  use Prometheus.Metric
  
  def setup do
    # HTTP request metrics
    Counter.declare(
      name: :http_requests_total,
      help: "Total HTTP requests",
      labels: [:method, :path, :status]
    )
    
    Histogram.declare(
      name: :http_request_duration_milliseconds,
      help: "HTTP request duration",
      labels: [:method, :path],
      buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000]
    )
    
    # Database query metrics
    Histogram.declare(
      name: :db_query_duration_milliseconds,
      help: "Database query duration",
      labels: [:query_type],
      buckets: [1, 5, 10, 25, 50, 100, 250, 500, 1000]
    )
    
    # WASM plugin metrics
    Counter.declare(
      name: :wasm_plugin_calls_total,
      help: "Total WASM plugin calls",
      labels: [:plugin_id, :function, :result]
    )
    
    Histogram.declare(
      name: :wasm_plugin_duration_microseconds,
      help: "WASM plugin execution duration",
      labels: [:plugin_id, :function],
      buckets: [100, 500, 1000, 5000, 10000, 50000, 100000]
    )
    
    # Business metrics
    Counter.declare(
      name: :patient_registrations_total,
      help: "Total patient registrations",
      labels: [:status]
    )
    
    Gauge.declare(
      name: :active_websocket_connections,
      help: "Current WebSocket connections"
    )
    
    # Attach to telemetry events
    attach_handlers()
  end
  
  defp attach_handlers do
    :telemetry.attach_many(
      "healthcare-prometheus",
      [
        [:phoenix, :endpoint, :stop],
        [:healthcare, :repo, :query],
        [:healthcare, :wasm_plugin, :call]
      ],
      &handle_event/4,
      nil
    )
  end
  
  def handle_event([:phoenix, :endpoint, :stop], measurements, metadata, _config) do
    duration = System.convert_time_unit(measurements.duration, :native, :millisecond)
    
    Counter.inc(
      name: :http_requests_total,
      labels: [metadata.method, metadata.request_path, metadata.status]
    )
    
    Histogram.observe(
      [name: :http_request_duration_milliseconds, labels: [metadata.method, metadata.request_path]],
      duration
    )
  end
  
  def handle_event([:healthcare, :repo, :query], measurements, metadata, _config) do
    duration = System.convert_time_unit(measurements.query_time, :native, :millisecond)
    
    Histogram.observe(
      [name: :db_query_duration_milliseconds, labels: [metadata.source]],
      duration
    )
  end
  
  def handle_event([:healthcare, :wasm_plugin, :call], measurements, metadata, _config) do
    duration = System.convert_time_unit(measurements.duration, :native, :microsecond)
    
    Counter.inc(
      name: :wasm_plugin_calls_total,
      labels: [metadata.plugin_id, metadata.function, metadata.result]
    )
    
    Histogram.observe(
      [name: :wasm_plugin_duration_microseconds, labels: [metadata.plugin_id, metadata.function]],
      duration
    )
  end
end

# lib/healthcare_web/endpoint.ex
defmodule HealthcareWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :healthcare
  
  # Prometheus metrics endpoint
  plug Prometheus.PlugExporter
  
  # ... other plugs
end
```

### Start Telemetry

```elixir
# lib/healthcare/application.ex
def start(_type, _args) do
  # Setup Prometheus metrics
  Healthcare.Telemetry.setup()
  
  children = [
    # ... other children
  ]
  
  Supervisor.start_link(children, strategy: :one_for_one)
end
```

---

## Grafana Dashboards

### Healthcare App Dashboard

```json
{
  "dashboard": {
    "title": "Healthcare Application",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{path}}"
          }
        ],
        "type": "graph"
      },
      {
        "title": "p95 Latency",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_milliseconds_bucket[5m]))",
            "legendFormat": "p95"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Database Query Duration",
        "targets": [
          {
            "expr": "histogram_quantile(0.99, rate(db_query_duration_milliseconds_bucket[5m]))",
            "legendFormat": "p99"
          }
        ],
        "type": "graph"
      },
      {
        "title": "WASM Plugin Performance",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(wasm_plugin_duration_microseconds_bucket[5m]))",
            "legendFormat": "{{plugin_id}}"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Active WebSocket Connections",
        "targets": [
          {
            "expr": "active_websocket_connections",
            "legendFormat": "connections"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

---

## Alerting Rules

### Prometheus Alerts

```yaml
# prometheus-alerts.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-alerts
  namespace: monitoring
data:
  alerts.yml: |
    groups:
    - name: healthcare_alerts
      interval: 30s
      rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} (threshold: 0.05)"
      
      # High latency
      - alert: HighLatency
        expr: histogram_quantile(0.99, rate(http_request_duration_milliseconds_bucket[5m])) > 500
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High p99 latency detected"
          description: "p99 latency is {{ $value }}ms (threshold: 500ms)"
      
      # Database connection pool exhaustion
      - alert: DatabasePoolExhausted
        expr: db_connection_pool_available < 2
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Database connection pool nearly exhausted"
          description: "Only {{ $value }} connections available"
      
      # WASM plugin failures
      - alert: WASMPluginHighFailureRate
        expr: rate(wasm_plugin_calls_total{result="error"}[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High WASM plugin failure rate"
          description: "Plugin {{ $labels.plugin_id }} failure rate: {{ $value }}"
      
      # Low disk space
      - alert: LowDiskSpace
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Only {{ $value | humanizePercentage }} available"
```

### Alertmanager Configuration

```yaml
# alertmanager-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
    
    route:
      group_by: ['alertname', 'cluster']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'pagerduty'
      routes:
      # Critical alerts to PagerDuty
      - match:
          severity: critical
        receiver: 'pagerduty'
      # Warnings to Slack
      - match:
          severity: warning
        receiver: 'slack'
    
    receivers:
    - name: 'pagerduty'
      pagerduty_configs:
      - service_key: '<PAGERDUTY_SERVICE_KEY>'
        description: '{{ .CommonAnnotations.summary }}'
    
    - name: 'slack'
      slack_configs:
      - api_url: '<SLACK_WEBHOOK_URL>'
        channel: '#healthcare-alerts'
        title: '{{ .CommonAnnotations.summary }}'
        text: '{{ .CommonAnnotations.description }}'
```

---

## Distributed Tracing (Jaeger)

### OpenTelemetry Setup

```elixir
# mix.exs
defp deps do
  [
    {:opentelemetry, "~> 1.5"},
    {:opentelemetry_exporter, "~> 1.8"},
    {:opentelemetry_phoenix, "~> 2.0"},
    {:opentelemetry_ecto, "~> 2.0"}
  ]
end
```

### Configuration

```elixir
# config/config.exs
config :opentelemetry, :resource,
  service: %{name: "healthcare-app", version: "1.0.0"}

config :opentelemetry, :processors,
  otel_batch_processor: %{
    exporter: {:otel_exporter_otlp, [
      endpoints: [{:http, 'jaeger-collector', 4318, []}]
    ]}
  }
```

### Instrument Code

```elixir
defmodule Healthcare.Patients do
  require OpenTelemetry.Tracer, as: Tracer
  
  def get_patient_with_records(patient_id) do
    Tracer.with_span "get_patient_with_records" do
      Tracer.set_attribute(:patient_id, patient_id)
      
      patient = Tracer.with_span "fetch_patient" do
        Repo.get!(Patient, patient_id)
      end
      
      records = Tracer.with_span "fetch_medical_records" do
        Repo.all(from r in MedicalRecord, where: r.patient_id == ^patient_id)
      end
      
      %{patient: patient, records: records}
    end
  end
end
```

---

## SLO Monitoring

### SLO Definition

```yaml
# Service Level Objectives
availability_slo: 99.95%  # 21.6 minutes downtime/month
latency_slo_p99: 100ms    # 99th percentile < 100ms
error_rate_slo: 0.1%      # < 0.1% error rate
```

### SLO Dashboard

```promql
# Availability (based on successful requests)
sum(rate(http_requests_total{status!~"5.."}[30d])) / sum(rate(http_requests_total[30d]))

# Error budget remaining (30-day window)
(1 - 0.9995) - (1 - (sum(rate(http_requests_total{status!~"5.."}[30d])) / sum(rate(http_requests_total[30d]))))

# Latency SLO compliance
histogram_quantile(0.99, rate(http_request_duration_milliseconds_bucket[5m])) < 100
```

---

## References

### Official Documentation
- [Prometheus Documentation](https://prometheus.io/docs/) (L0_CANONICAL)
- [Grafana Documentation](https://grafana.com/docs/) (L0_CANONICAL)
- [OpenTelemetry Elixir](https://opentelemetry.io/docs/languages/erlang/) (L0_CANONICAL)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/) (L0_CANONICAL)

### Books
- [Prometheus: Up & Running](https://www.oreilly.com/library/view/prometheus-up/9781492034131/) (L2_VALIDATED)

---

**DSM**: [L1:infrastructure | L2:healthcare | L3:configuration | L4:guide]
**Source**: `06-infrastructure-devops.md` (Observability sections)
**Version**: 1.0.0
**Related**:
- [Kubernetes Deployment](../kubernetes/deployment.md)
- [HIPAA Audit Controls](../../04-SECURITY-SPECIALIST/compliance/lgpd-hipaa-mapping.md)
- [ADR 004: Zero Trust Implementation](../../01-ARCHITECTURE/adrs/004-zero-trust-implementation.md)
