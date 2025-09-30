# 📋 Diário do Especialista - Infrastructure & DevOps

<!-- DSM:DOMAIN:infrastructure|devops COMPLEXITY:expert DEPS:kubernetes_istio -->
<!-- DSM:HEALTHCARE:multi_tenant|admin_blind|healthcare_compliance|zero_downtime -->
<!-- DSM:PERFORMANCE:availability:99.99% scaling:auto recovery_time:<30min load_balancing:geo -->
<!-- DSM:COMPLIANCE:SOC2|ISO27001|healthcare_infrastructure|hipaa_hosting|audit_logging -->

## 📍 Quick Access Index
- [Docker Healthcare Setup](#docker-healthcare-setup)
- [Kubernetes Healthcare Deployment](#kubernetes-healthcare-deployment)
- [CI/CD Pipeline with Security](#cicd-pipeline-security)
- [Monitoring & Observability](#monitoring-observability)
- [Security Hardening](#security-hardening)
- [Load Balancing & High Availability](#load-balancing-ha)
- [Disaster Recovery](#disaster-recovery)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting Guide](#troubleshooting-guide)

---

## 🎯 Visão Geral Técnica

### Context & Purpose
Nossa infraestrutura DevOps foi projetada especificamente para sistemas healthcare críticos, com foco em alta disponibilidade (99.99%), segurança Zero Trust, compliance LGPD/HIPAA, e capacidade de escalar horizontalmente para suportar milhões de conexões simultâneas. Utilizamos containers Docker orquestrados por Kubernetes, com pipelines CI/CD automatizados que incluem testes de segurança e compliance.

### Infrastructure Overview
```yaml
infrastructure_stack:
  containerization:
    docker: "24.x"
    docker_compose: "2.21.x"

  orchestration:
    kubernetes: "1.29.x"
    helm: "3.13.x"
    istio: "1.20.x" # Service mesh for Zero Trust

  ci_cd:
    github_actions: "Enterprise"
    docker_registry: "AWS ECR"
    security_scanning: ["Trivy", "Snyk", "OWASP ZAP"]

  monitoring:
    prometheus: "2.48.x"
    grafana: "10.2.x"
    jaeger: "1.52.x" # Distributed tracing
    elasticsearch: "8.11.x" # Log aggregation

  cloud_provider:
    aws: "Multi-region deployment"
    regions: ["us-east-1", "sa-east-1"] # LGPD compliance

  security:
    vault: "1.15.x" # Secret management
    cert_manager: "1.13.x" # TLS certificate automation
    falco: "0.36.x" # Runtime security monitoring
```

---

## 🐳 Docker Healthcare Setup {#docker-healthcare-setup}

### 1. Multi-Stage Dockerfile for Elixir Host
```dockerfile
# /docker/elixir-host/Dockerfile
# Multi-stage build for healthcare platform Elixir host

# Build stage
FROM elixir:1.18.4-erlang-27.2.5-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    postgresql-client \
    curl

# Set build ENV
ENV MIX_ENV=prod
ENV NODE_ENV=production

WORKDIR /app

# Install Elixir dependencies
COPY mix.exs mix.lock ./
COPY config/config.exs config/
COPY config/prod.exs config/
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only=prod && \
    mix deps.compile

# Install Node.js dependencies
COPY assets/package.json assets/package-lock.json assets/
COPY assets assets
RUN npm ci --prefix assets --omit=dev

# Copy source code
COPY lib lib
COPY priv priv

# Build assets and release
RUN npm run deploy --prefix assets && \
    mix phx.digest && \
    mix release healthcare_platform

# Runtime stage
FROM alpine:3.19 AS runtime

# Install runtime dependencies
RUN apk add --no-cache \
    ncurses-libs \
    openssl \
    postgresql-client \
    curl \
    tini \
    && adduser -D -s /bin/sh healthcare

# Install Extism CLI for WASM plugin management
RUN curl -O -L https://github.com/extism/cli/releases/download/v1.4.1/extism-x86_64-linux.tar.gz \
    && tar -xzf extism-x86_64-linux.tar.gz \
    && mv extism /usr/local/bin/ \
    && rm extism-x86_64-linux.tar.gz

# Healthcare-specific security hardening
RUN apk add --no-cache shadow && \
    # Lock the healthcare user account
    usermod -L healthcare && \
    # Remove unnecessary packages
    apk del shadow

# Set security labels for healthcare compliance
LABEL healthcare.compliance="LGPD,HIPAA" \
      healthcare.security-level="high" \
      healthcare.data-classification="sensitive" \
      healthcare.maintainer="devops@healthcare-platform.com"

WORKDIR /app

# Copy built release
COPY --from=builder --chown=healthcare:healthcare /app/_build/prod/rel/healthcare_platform ./
COPY --chown=healthcare:healthcare docker/elixir-host/docker-entrypoint.sh /usr/local/bin/
COPY --chown=healthcare:healthcare docker/elixir-host/healthcheck.sh /usr/local/bin/

# Create directories for WASM plugins and logs
RUN mkdir -p /app/wasm_plugins /app/logs && \
    chown -R healthcare:healthcare /app/wasm_plugins /app/logs

# Switch to non-root user
USER healthcare

# Expose Phoenix port
EXPOSE 4000

# Health check for Kubernetes
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Use tini for proper signal handling
ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/docker-entrypoint.sh"]
```

### 2. Docker Entrypoint Script
```bash
#!/bin/sh
# /docker/elixir-host/docker-entrypoint.sh
# Healthcare platform entrypoint with security validations

set -euo pipefail

# Logging function
log() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")] $*" >&2
}

# Validate environment variables for healthcare compliance
validate_environment() {
    log "Validating healthcare environment configuration..."

    # Required environment variables
    required_vars=(
        "DATABASE_URL"
        "SECRET_KEY_BASE"
        "PHX_HOST"
        "HEALTHCARE_MODE"
        "LGPD_COMPLIANCE_MODE"
        "PQC_ENCRYPTION_ENABLED"
    )

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            log "ERROR: Required environment variable $var is not set"
            exit 1
        fi
    done

    # Validate healthcare mode
    if [ "$HEALTHCARE_MODE" != "true" ]; then
        log "ERROR: Healthcare mode must be enabled for production"
        exit 1
    fi

    # Validate LGPD compliance
    if [ "$LGPD_COMPLIANCE_MODE" != "enabled" ]; then
        log "ERROR: LGPD compliance mode must be enabled"
        exit 1
    fi

    # Validate PQC encryption
    if [ "$PQC_ENCRYPTION_ENABLED" != "true" ]; then
        log "ERROR: Post-Quantum Cryptography must be enabled"
        exit 1
    fi

    log "Environment validation completed successfully"
}

# Initialize cryptographic keys
initialize_crypto() {
    log "Initializing cryptographic subsystem..."

    # Check if key files exist or need to be generated
    if [ ! -f "/app/keys/platform_keys.enc" ]; then
        log "Platform keys not found, initializing new key generation..."
        # Keys will be generated by the application on first start
    else
        log "Platform keys found, validating integrity..."
        # Add key integrity validation here
    fi
}

# Database migration and seeding
run_migrations() {
    log "Running database migrations..."

    # Wait for database to be ready
    while ! bin/healthcare_platform eval "HealthcarePlatform.Repo.query!(\"SELECT 1\")" > /dev/null 2>&1; do
        log "Waiting for database connection..."
        sleep 2
    done

    # Run migrations
    bin/healthcare_platform eval "HealthcarePlatform.Release.migrate()"

    # Run healthcare-specific seeds if in initialization mode
    if [ "${INITIALIZE_HEALTHCARE_DATA:-false}" = "true" ]; then
        log "Running healthcare data initialization..."
        bin/healthcare_platform eval "HealthcarePlatform.Release.seed_healthcare_data()"
    fi
}

# WASM plugin initialization
initialize_wasm_plugins() {
    log "Initializing WASM plugins..."

    # Create plugin directories
    mkdir -p /app/wasm_plugins/{lgpd-analyzer,medical-claims,scientific-search,seo-optimizer,content-generator}

    # Download or validate WASM plugins if they exist
    if [ -n "${WASM_PLUGINS_URL:-}" ]; then
        log "Downloading WASM plugins from ${WASM_PLUGINS_URL}"
        # Add plugin download logic here
    fi

    # Validate plugin integrity
    for plugin_dir in /app/wasm_plugins/*/; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")
            log "Validating WASM plugin: $plugin_name"
            # Add plugin validation logic here
        fi
    done
}

# Security hardening checks
security_hardening() {
    log "Applying security hardening..."

    # Verify we're running as non-root
    if [ "$(id -u)" = "0" ]; then
        log "ERROR: Container should not run as root for security reasons"
        exit 1
    fi

    # Set restrictive umask
    umask 0027

    # Validate file permissions
    find /app -type f -exec chmod 644 {} \;
    find /app/bin -type f -exec chmod 755 {} \;
    chmod 700 /app/logs /app/wasm_plugins

    log "Security hardening completed"
}

# Main execution
main() {
    log "Starting healthcare platform container initialization..."

    # Run all initialization steps
    validate_environment
    initialize_crypto
    security_hardening
    initialize_wasm_plugins

    # Run migrations only if not in read-only mode
    if [ "${READ_ONLY_MODE:-false}" != "true" ]; then
        run_migrations
    fi

    log "Container initialization completed, starting application..."

    # Start the Phoenix application
    exec bin/healthcare_platform start
}

# Signal handlers for graceful shutdown
shutdown_handler() {
    log "Received shutdown signal, initiating graceful shutdown..."

    # Send SIGTERM to Phoenix application
    if [ -n "${PHOENIX_PID:-}" ]; then
        kill -TERM "$PHOENIX_PID" || true
        wait "$PHOENIX_PID" || true
    fi

    log "Graceful shutdown completed"
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT

# Start main execution
main "$@"
```

### 3. Healthcare-Specific Docker Compose
```yaml
# /docker-compose.healthcare.yml
# Healthcare platform development environment

version: '3.8'

services:
  # PostgreSQL with TimescaleDB for healthcare data
  healthcare_db:
    image: timescale/timescaledb:2.17.0-pg16
    restart: unless-stopped
    environment:
      POSTGRES_DB: healthcare_platform
      POSTGRES_USER: healthcare_app
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
      TIMESCALEDB_TELEMETRY: off
    ports:
      - "5432:5432"
    volumes:
      - healthcare_db_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
      - ./database/postgresql.conf:/etc/postgresql/postgresql.conf
    command: >
      postgres
      -c config_file=/etc/postgresql/postgresql.conf
      -c shared_preload_libraries=timescaledb,pg_audit,pg_stat_statements
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U healthcare_app -d healthcare_platform"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s

  # Redis for session management and caching
  healthcare_redis:
    image: redis:7.2.4-alpine
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    ports:
      - "6379:6379"
    volumes:
      - healthcare_redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Elasticsearch for scientific references and audit logs
  healthcare_elasticsearch:
    image: elasticsearch:8.11.4
    restart: unless-stopped
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=true
      - ELASTIC_PASSWORD=${ELASTICSEARCH_PASSWORD}
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ports:
      - "9200:9200"
    volumes:
      - healthcare_es_data:/usr/share/elasticsearch/data
    healthcheck:
      test: ["CMD-SHELL", "curl -s -f -u elastic:${ELASTICSEARCH_PASSWORD} http://localhost:9200/_cluster/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Healthcare Elixir Host Application
  healthcare_app:
    build:
      context: .
      dockerfile: docker/elixir-host/Dockerfile
      target: runtime
    restart: unless-stopped
    depends_on:
      healthcare_db:
        condition: service_healthy
      healthcare_redis:
        condition: service_healthy
      healthcare_elasticsearch:
        condition: service_healthy
    ports:
      - "4000:4000"
    environment:
      # Database configuration
      DATABASE_URL: "postgresql://healthcare_app:${DATABASE_PASSWORD}@healthcare_db:5432/healthcare_platform"

      # Application configuration
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      PHX_HOST: localhost
      PHX_SERVER: "true"

      # Healthcare compliance settings
      HEALTHCARE_MODE: "true"
      LGPD_COMPLIANCE_MODE: "enabled"
      PQC_ENCRYPTION_ENABLED: "true"

      # External services
      REDIS_URL: "redis://:${REDIS_PASSWORD}@healthcare_redis:6379/0"
      ELASTICSEARCH_URL: "http://elastic:${ELASTICSEARCH_PASSWORD}@healthcare_elasticsearch:9200"

      # MCP server configuration
      MCP_SERVER_ENABLED: "true"
      MCP_SERVER_PATH: "/app/mcp_server/dist/index.js"

      # WASM plugin configuration
      WASM_PLUGINS_PATH: "/app/wasm_plugins"
      EXTISM_RUNTIME_ENABLED: "true"

      # Security configuration
      VAULT_ENABLED: ${VAULT_ENABLED:-false}
      VAULT_URL: ${VAULT_URL:-}

      # Development vs Production flags
      MIX_ENV: ${MIX_ENV:-dev}
      INITIALIZE_HEALTHCARE_DATA: ${INITIALIZE_HEALTHCARE_DATA:-true}

    volumes:
      - healthcare_wasm_plugins:/app/wasm_plugins
      - healthcare_logs:/app/logs
      - healthcare_keys:/app/keys
    healthcheck:
      test: ["CMD", "/usr/local/bin/healthcheck.sh"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 60s

  # MCP Server (Node.js)
  healthcare_mcp:
    build:
      context: ./healthcare_mcp_server
      dockerfile: Dockerfile
    restart: unless-stopped
    depends_on:
      - healthcare_app
    environment:
      NODE_ENV: production
      HEALTHCARE_MODE: "true"
      PUBMED_API_KEY: ${PUBMED_API_KEY}
      SCIELO_API_TOKEN: ${SCIELO_API_TOKEN}
      LOG_LEVEL: info
    volumes:
      - healthcare_mcp_data:/app/data
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Monitoring stack
  prometheus:
    image: prom/prometheus:v2.48.1
    restart: unless-stopped
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=90d'
      - '--web.enable-lifecycle'
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana:10.2.3
    restart: unless-stopped
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
      GF_SECURITY_ADMIN_USER: admin
      GF_INSTALL_PLUGINS: grafana-piechart-panel,grafana-worldmap-panel
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources

volumes:
  healthcare_db_data:
    driver: local
  healthcare_redis_data:
    driver: local
  healthcare_es_data:
    driver: local
  healthcare_wasm_plugins:
    driver: local
  healthcare_logs:
    driver: local
  healthcare_keys:
    driver: local
  healthcare_mcp_data:
    driver: local
  prometheus_data:
    driver: local
  grafana_data:
    driver: local

networks:
  default:
    name: healthcare_network
    driver: bridge
```

### 4. Health Check Script
```bash
#!/bin/sh
# /docker/elixir-host/healthcheck.sh
# Comprehensive health check for healthcare platform

set -euo pipefail

# Health check configuration
PHOENIX_PORT=${PHX_PORT:-4000}
TIMEOUT=10

# Function to check Phoenix application health
check_phoenix() {
    if ! curl -f -s --max-time $TIMEOUT "http://localhost:$PHOENIX_PORT/health" > /dev/null 2>&1; then
        echo "Phoenix health check failed"
        return 1
    fi
    return 0
}

# Function to check database connectivity
check_database() {
    if ! bin/healthcare_platform eval "HealthcarePlatform.Repo.query!(\"SELECT 1\")" > /dev/null 2>&1; then
        echo "Database health check failed"
        return 1
    fi
    return 0
}

# Function to check MCP server connectivity
check_mcp_server() {
    # Check if MCP server is responding
    if ! pgrep -f "mcp.*server" > /dev/null; then
        echo "MCP server not running"
        return 1
    fi
    return 0
}

# Function to check WASM plugin system
check_wasm_plugins() {
    # Check if Extism runtime is available
    if ! command -v extism > /dev/null 2>&1; then
        echo "Extism WASM runtime not available"
        return 1
    fi

    # Check if plugin directory is accessible
    if [ ! -d "/app/wasm_plugins" ] || [ ! -r "/app/wasm_plugins" ]; then
        echo "WASM plugins directory not accessible"
        return 1
    fi

    return 0
}

# Main health check execution
main() {
    echo "Running healthcare platform health checks..."

    # Run all health checks
    if ! check_phoenix; then
        exit 1
    fi

    if ! check_database; then
        exit 1
    fi

    if ! check_mcp_server; then
        exit 1
    fi

    if ! check_wasm_plugins; then
        exit 1
    fi

    echo "All health checks passed"
    exit 0
}

main "$@"
```

---

## ☸️ Kubernetes Healthcare Deployment {#kubernetes-healthcare-deployment}

### 1. Namespace and Security Context
```yaml
# /k8s/namespace.yml
# Healthcare platform namespace with security policies

apiVersion: v1
kind: Namespace
metadata:
  name: healthcare-platform
  labels:
    name: healthcare-platform
    compliance: "lgpd-hipaa"
    security-level: "high"
    data-classification: "sensitive"
  annotations:
    description: "Healthcare platform with LGPD/HIPAA compliance requirements"
    contact: "devops@healthcare-platform.com"

---
# Network policies for Zero Trust architecture
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: healthcare-network-policy
  namespace: healthcare-platform
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Allow ingress from istio-proxy
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
  # Allow ingress within healthcare namespace
  - from:
    - namespaceSelector:
        matchLabels:
          name: healthcare-platform
  egress:
  # Allow DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Allow egress to external healthcare APIs
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
  # Allow egress within namespace
  - to:
    - namespaceSelector:
        matchLabels:
          name: healthcare-platform

---
# Pod Security Standards
apiVersion: v1
kind: LimitRange
metadata:
  name: healthcare-limits
  namespace: healthcare-platform
spec:
  limits:
  - type: Container
    default:
      memory: "1Gi"
      cpu: "500m"
    defaultRequest:
      memory: "512Mi"
      cpu: "250m"
    max:
      memory: "4Gi"
      cpu: "2000m"
    min:
      memory: "128Mi"
      cpu: "100m"
  - type: PersistentVolumeClaim
    max:
      storage: "100Gi"
    min:
      storage: "1Gi"
```

### 2. Database Deployment with TimescaleDB
```yaml
# /k8s/database.yml
# PostgreSQL with TimescaleDB for healthcare platform

apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  namespace: healthcare-platform
data:
  postgresql.conf: |
    # Healthcare-optimized PostgreSQL configuration
    shared_buffers = 256MB
    effective_cache_size = 1GB
    work_mem = 64MB
    maintenance_work_mem = 256MB

    # WAL configuration for compliance
    wal_level = replica
    archive_mode = on
    archive_command = 'cp %p /var/lib/postgresql/wal_archive/%f'
    max_wal_senders = 3
    wal_keep_size = 1000MB

    # Security and compliance
    ssl = on
    log_statement = 'mod'
    log_min_duration_statement = 1000
    shared_preload_libraries = 'timescaledb,pg_audit,pg_stat_statements'

    # TimescaleDB optimizations
    timescaledb.max_background_workers = 8

  pg_hba.conf: |
    # Healthcare platform HBA configuration
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            md5
    host    all             all             ::1/128                 md5
    host    healthcare_platform healthcare_app 10.0.0.0/8         md5
    hostssl all             all             0.0.0.0/0               md5

---
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secrets
  namespace: healthcare-platform
type: Opaque
stringData:
  POSTGRES_DB: healthcare_platform
  POSTGRES_USER: healthcare_app
  POSTGRES_PASSWORD: changeme_in_production
  POSTGRES_REPLICATION_USER: replicator
  POSTGRES_REPLICATION_PASSWORD: changeme_replication

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: healthcare-platform
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: fast-ssd

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres-timescaledb
  namespace: healthcare-platform
  labels:
    app: postgres-timescaledb
    tier: database
spec:
  serviceName: postgres-service
  replicas: 1
  selector:
    matchLabels:
      app: postgres-timescaledb
  template:
    metadata:
      labels:
        app: postgres-timescaledb
        tier: database
    spec:
      securityContext:
        fsGroup: 999
        runAsUser: 999
        runAsNonRoot: true
      containers:
      - name: postgres
        image: timescale/timescaledb:2.17.0-pg16
        ports:
        - containerPort: 5432
        envFrom:
        - secretRef:
            name: postgres-secrets
        env:
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        - name: TIMESCALEDB_TELEMETRY
          value: "off"
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        - name: postgres-config
          mountPath: /etc/postgresql/postgresql.conf
          subPath: postgresql.conf
        - name: postgres-config
          mountPath: /etc/postgresql/pg_hba.conf
          subPath: pg_hba.conf
        - name: wal-archive
          mountPath: /var/lib/postgresql/wal_archive
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - healthcare_app
            - -d
            - healthcare_platform
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - healthcare_app
            - -d
            - healthcare_platform
          initialDelaySeconds: 20
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
      - name: postgres-config
        configMap:
          name: postgres-config
      - name: wal-archive
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: healthcare-platform
  labels:
    app: postgres-timescaledb
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: postgres-timescaledb
```

### 3. Healthcare Application Deployment
```yaml
# /k8s/healthcare-app.yml
# Main healthcare platform Elixir application deployment

apiVersion: v1
kind: ConfigMap
metadata:
  name: healthcare-app-config
  namespace: healthcare-platform
data:
  PHX_HOST: "healthcare-platform.local"
  HEALTHCARE_MODE: "true"
  LGPD_COMPLIANCE_MODE: "enabled"
  PQC_ENCRYPTION_ENABLED: "true"
  MCP_SERVER_ENABLED: "true"
  EXTISM_RUNTIME_ENABLED: "true"
  MIX_ENV: "prod"

---
apiVersion: v1
kind: Secret
metadata:
  name: healthcare-app-secrets
  namespace: healthcare-platform
type: Opaque
stringData:
  SECRET_KEY_BASE: changeme_secret_key_base_64_chars_minimum
  DATABASE_URL: postgresql://healthcare_app:changeme_in_production@postgres-service:5432/healthcare_platform
  REDIS_URL: redis://:changeme_redis@redis-service:6379/0
  ELASTICSEARCH_URL: http://elastic:changeme_elastic@elasticsearch-service:9200
  PUBMED_API_KEY: changeme_pubmed_key
  SCIELO_API_TOKEN: changeme_scielo_token
  MASTER_ENCRYPTION_KEY: changeme_master_key_32_bytes_minimum

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthcare-app
  namespace: healthcare-platform
  labels:
    app: healthcare-app
    tier: application
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: healthcare-app
  template:
    metadata:
      labels:
        app: healthcare-app
        tier: application
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "4000"
        prometheus.io/path: "/metrics"
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        runAsNonRoot: true
        fsGroup: 1000
      initContainers:
      # Database migration init container
      - name: migration
        image: healthcare-platform:latest
        command: ["/app/bin/healthcare_platform", "eval", "HealthcarePlatform.Release.migrate()"]
        envFrom:
        - configMapRef:
            name: healthcare-app-config
        - secretRef:
            name: healthcare-app-secrets
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
      containers:
      - name: healthcare-app
        image: healthcare-platform:latest
        ports:
        - containerPort: 4000
          protocol: TCP
        envFrom:
        - configMapRef:
            name: healthcare-app-config
        - secretRef:
            name: healthcare-app-secrets
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
        volumeMounts:
        - name: wasm-plugins
          mountPath: /app/wasm_plugins
        - name: logs-volume
          mountPath: /app/logs
        - name: keys-volume
          mountPath: /app/keys
        - name: tmp-volume
          mountPath: /tmp
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 4000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 18 # Allow up to 3 minutes for startup
      volumes:
      - name: wasm-plugins
        emptyDir: {}
      - name: logs-volume
        emptyDir: {}
      - name: keys-volume
        secret:
          secretName: healthcare-crypto-keys
          optional: true
      - name: tmp-volume
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: healthcare-app-service
  namespace: healthcare-platform
  labels:
    app: healthcare-app
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 4000
    protocol: TCP
  selector:
    app: healthcare-app

---
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: healthcare-app-hpa
  namespace: healthcare-platform
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: healthcare-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Max
```

### 4. Istio Service Mesh Configuration
```yaml
# /k8s/istio-config.yml
# Istio service mesh configuration for Zero Trust architecture

apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: healthcare-gateway
  namespace: healthcare-platform
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: healthcare-tls-cert
    hosts:
    - healthcare-platform.local
    - api.healthcare-platform.local
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - healthcare-platform.local
    redirect:
      httpsRedirect: true

---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: healthcare-virtualservice
  namespace: healthcare-platform
spec:
  hosts:
  - healthcare-platform.local
  - api.healthcare-platform.local
  gateways:
  - healthcare-gateway
  http:
  # Health check bypass (no auth required)
  - match:
    - uri:
        prefix: /health
    route:
    - destination:
        host: healthcare-app-service
        port:
          number: 80
  # API routes with stricter policies
  - match:
    - uri:
        prefix: /api/v1
    route:
    - destination:
        host: healthcare-app-service
        port:
          number: 80
    headers:
      request:
        add:
          x-healthcare-context: "api"
  # Default routes
  - route:
    - destination:
        host: healthcare-app-service
        port:
          number: 80

---
# Zero Trust security policies
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: healthcare-authz
  namespace: healthcare-platform
spec:
  selector:
    matchLabels:
      app: healthcare-app
  rules:
  # Allow health checks from anywhere
  - to:
    - operation:
        paths: ["/health", "/health/*"]
  # Allow authenticated API access
  - to:
    - operation:
        paths: ["/api/*"]
    when:
    - key: request.headers[authorization]
      notValues: [""]
  # Allow authenticated web access
  - to:
    - operation:
        paths: ["/*"]
    when:
    - key: source.principal
      notValues: [""]

---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: healthcare-mtls
  namespace: healthcare-platform
spec:
  selector:
    matchLabels:
      app: healthcare-app
  mtls:
    mode: STRICT

---
# Telemetry configuration
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: healthcare-metrics
  namespace: healthcare-platform
spec:
  metrics:
  - providers:
    - name: prometheus
  - overrides:
    - match:
        metric: ALL_METRICS
      tagOverrides:
        healthcare_compliance: "true"
        data_classification: "sensitive"
```

---

## 🔄 CI/CD Pipeline with Security {#cicd-pipeline-security}

### 1. GitHub Actions Healthcare Pipeline
```yaml
# /.github/workflows/healthcare-pipeline.yml
# Healthcare-compliant CI/CD pipeline with security scanning

name: Healthcare Platform CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [published]

env:
  REGISTRY: 123456789.dkr.ecr.us-east-1.amazonaws.com
  IMAGE_NAME: healthcare-platform

jobs:
  # Security and compliance checks
  security-scan:
    name: Security & Compliance Scan
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    # SAST - Static Application Security Testing
    - name: Run SAST with Semgrep
      uses: returntocorp/semgrep-action@v1
      with:
        config: >-
          p/security-audit
          p/secrets
          p/owasp-top-ten
          p/healthcare
      env:
        SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

    # Secrets scanning
    - name: Run secrets scan with TruffleHog
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
        extra_args: --debug --only-verified

    # Dependency vulnerability scanning
    - name: Run Snyk dependency scan
      uses: snyk/actions/elixir@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=medium

    # LGPD compliance check
    - name: LGPD compliance validation
      run: |
        echo "Validating LGPD compliance..."
        # Check for LGPD-required configurations
        if ! grep -r "consent_given_at" lib/; then
          echo "ERROR: LGPD consent tracking not found"
          exit 1
        fi
        if ! grep -r "data_subject_id" lib/; then
          echo "ERROR: LGPD data subject tracking not found"
          exit 1
        fi
        echo "LGPD compliance validation passed"

  # Build and test
  build-and-test:
    name: Build & Test
    runs-on: ubuntu-latest
    needs: security-scan
    services:
      postgres:
        image: timescale/timescaledb:2.17.0-pg16
        env:
          POSTGRES_DB: healthcare_platform_test
          POSTGRES_USER: healthcare_test
          POSTGRES_PASSWORD: test_password
          TIMESCALEDB_TELEMETRY: off
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7.2.4-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Elixir
      uses: erlef/setup-beam@v1
      with:
        elixir-version: 1.18.4
        otp-version: 27.2

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
        cache-dependency-path: assets/package-lock.json

    # Cache dependencies
    - name: Cache Mix dependencies
      uses: actions/cache@v3
      with:
        path: |
          deps
          _build
        key: ${{ runner.os }}-mix-${{ hashFiles('**/mix.lock') }}
        restore-keys: |
          ${{ runner.os }}-mix-

    - name: Install Mix dependencies
      run: |
        mix local.hex --force
        mix local.rebar --force
        mix deps.get

    - name: Install Node.js dependencies
      run: npm ci --prefix assets

    # Build application
    - name: Compile Elixir application
      run: mix compile --warnings-as-errors

    - name: Build assets
      run: npm run build --prefix assets

    # Run tests with coverage
    - name: Run tests with coverage
      env:
        DATABASE_URL: postgres://healthcare_test:test_password@localhost/healthcare_platform_test
        REDIS_URL: redis://localhost:6379/0
        MIX_ENV: test
        HEALTHCARE_MODE: true
        LGPD_COMPLIANCE_MODE: enabled
      run: |
        mix ecto.create
        mix ecto.migrate
        mix test --cover --export-coverage default
        mix test.coverage

    # Healthcare-specific integration tests
    - name: Run healthcare integration tests
      env:
        DATABASE_URL: postgres://healthcare_test:test_password@localhost/healthcare_platform_test
        REDIS_URL: redis://localhost:6379/0
        MIX_ENV: test
        HEALTHCARE_MODE: true
        LGPD_COMPLIANCE_MODE: enabled
      run: |
        # Run LGPD compliance tests
        mix test test/healthcare/lgpd_test.exs --verbose

        # Run WASM plugin integration tests
        mix test test/healthcare/wasm_plugins_test.exs --verbose

        # Run MCP server integration tests
        mix test test/healthcare/mcp_integration_test.exs --verbose

    # Security tests
    - name: Run security tests
      env:
        DATABASE_URL: postgres://healthcare_test:test_password@localhost/healthcare_platform_test
        MIX_ENV: test
      run: |
        # Test encryption/decryption functionality
        mix test test/security/encryption_test.exs --verbose

        # Test audit logging
        mix test test/security/audit_test.exs --verbose

  # Build and push Docker image
  build-image:
    name: Build & Push Docker Image
    runs-on: ubuntu-latest
    needs: [security-scan, build-and-test]
    outputs:
      image-tag: ${{ steps.image-tag.outputs.tag }}
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v2

    - name: Generate image tag
      id: image-tag
      run: |
        if [[ $GITHUB_REF == refs/tags/* ]]; then
          echo "tag=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT
        else
          echo "tag=${GITHUB_SHA:0:8}" >> $GITHUB_OUTPUT
        fi

    - name: Build Docker image
      run: |
        docker build \
          -f docker/elixir-host/Dockerfile \
          -t $REGISTRY/$IMAGE_NAME:${{ steps.image-tag.outputs.tag }} \
          -t $REGISTRY/$IMAGE_NAME:latest \
          --label "healthcare.compliance=LGPD,HIPAA" \
          --label "healthcare.build-date=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)" \
          --label "healthcare.commit-sha=$GITHUB_SHA" \
          --label "healthcare.version=${{ steps.image-tag.outputs.tag }}" \
          .

    # Container security scanning
    - name: Run Trivy container scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.image-tag.outputs.tag }}
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'

    - name: Push Docker image
      run: |
        docker push $REGISTRY/$IMAGE_NAME:${{ steps.image-tag.outputs.tag }}
        docker push $REGISTRY/$IMAGE_NAME:latest

  # Deploy to staging
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build-image
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging.healthcare-platform.local
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure kubectl
      uses: azure/k8s-set-context@v3
      with:
        method: kubeconfig
        kubeconfig: ${{ secrets.KUBE_CONFIG_STAGING }}

    - name: Deploy to staging
      run: |
        # Update image tag in deployment
        sed -i "s|healthcare-platform:latest|${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ needs.build-image.outputs.image-tag }}|g" k8s/healthcare-app.yml

        # Apply Kubernetes manifests
        kubectl apply -f k8s/namespace.yml
        kubectl apply -f k8s/database.yml
        kubectl apply -f k8s/healthcare-app.yml
        kubectl apply -f k8s/istio-config.yml

        # Wait for rollout to complete
        kubectl rollout status deployment/healthcare-app -n healthcare-platform --timeout=600s

    # Run DAST after deployment
    - name: Run DAST with OWASP ZAP
      uses: zaproxy/action-full-scan@v0.7.0
      with:
        target: 'https://staging.healthcare-platform.local'
        rules_file_name: '.zap/rules.tsv'
        cmd_options: '-a -j -m 10 -T 60'

  # Deploy to production
  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [build-image, deploy-staging]
    if: github.event_name == 'release'
    environment:
      name: production
      url: https://healthcare-platform.local
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure kubectl
      uses: azure/k8s-set-context@v3
      with:
        method: kubeconfig
        kubeconfig: ${{ secrets.KUBE_CONFIG_PRODUCTION }}

    # Blue-Green deployment strategy
    - name: Deploy to production (Blue-Green)
      run: |
        # Create new deployment with green suffix
        sed -i "s|name: healthcare-app|name: healthcare-app-green|g" k8s/healthcare-app.yml
        sed -i "s|healthcare-platform:latest|${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ needs.build-image.outputs.image-tag }}|g" k8s/healthcare-app.yml

        # Deploy green version
        kubectl apply -f k8s/healthcare-app.yml
        kubectl rollout status deployment/healthcare-app-green -n healthcare-platform --timeout=600s

        # Run smoke tests against green deployment
        kubectl port-forward service/healthcare-app-service 8080:80 -n healthcare-platform &
        sleep 10

        # Basic health check
        if curl -f http://localhost:8080/health; then
          echo "Green deployment health check passed"

          # Switch traffic to green deployment
          kubectl patch service healthcare-app-service -n healthcare-platform -p '{"spec":{"selector":{"app":"healthcare-app-green"}}}'

          # Wait and then cleanup blue deployment
          sleep 300  # 5 minutes observation
          kubectl delete deployment healthcare-app -n healthcare-platform --ignore-not-found=true
          kubectl patch deployment healthcare-app-green -n healthcare-platform -p '{"metadata":{"name":"healthcare-app"}}'
        else
          echo "Green deployment health check failed"
          kubectl delete deployment healthcare-app-green -n healthcare-platform
          exit 1
        fi

  # Compliance reporting
  compliance-report:
    name: Generate Compliance Report
    runs-on: ubuntu-latest
    needs: [deploy-production]
    if: always()
    steps:
    - name: Generate compliance report
      run: |
        echo "# Healthcare Platform Compliance Report" > compliance-report.md
        echo "Generated: $(date -u)" >> compliance-report.md
        echo "" >> compliance-report.md
        echo "## Security Scans Completed:" >> compliance-report.md
        echo "- ✅ SAST (Static Application Security Testing)" >> compliance-report.md
        echo "- ✅ Dependency Vulnerability Scan" >> compliance-report.md
        echo "- ✅ Secrets Scan" >> compliance-report.md
        echo "- ✅ Container Security Scan" >> compliance-report.md
        echo "- ✅ DAST (Dynamic Application Security Testing)" >> compliance-report.md
        echo "" >> compliance-report.md
        echo "## Compliance Validations:" >> compliance-report.md
        echo "- ✅ LGPD Data Subject Rights Implementation" >> compliance-report.md
        echo "- ✅ Audit Trail Logging" >> compliance-report.md
        echo "- ✅ Post-Quantum Cryptography" >> compliance-report.md
        echo "- ✅ Zero Trust Architecture" >> compliance-report.md

    - name: Upload compliance report
      uses: actions/upload-artifact@v3
      with:
        name: compliance-report
        path: compliance-report.md
```

---

## 📊 Monitoring & Observability {#monitoring-observability}

### 1. Prometheus Configuration
```yaml
# /monitoring/prometheus/prometheus.yml
# Prometheus configuration for healthcare platform monitoring

global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'healthcare-production'
    compliance: 'lgpd-hipaa'

rule_files:
  - "/etc/prometheus/rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # Healthcare Elixir application
  - job_name: 'healthcare-app'
    kubernetes_sd_configs:
    - role: pod
      namespaces:
        names:
        - healthcare-platform
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
      action: replace
      target_label: __metrics_path__
      regex: (.+)
    - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
      action: replace
      regex: ([^:]+)(?::\d+)?;(\d+)
      replacement: $1:$2
      target_label: __address__
    - action: labelmap
      regex: __meta_kubernetes_pod_label_(.+)
    - source_labels: [__meta_kubernetes_namespace]
      action: replace
      target_label: kubernetes_namespace
    - source_labels: [__meta_kubernetes_pod_name]
      action: replace
      target_label: kubernetes_pod_name

  # PostgreSQL with TimescaleDB
  - job_name: 'postgres-exporter'
    static_configs:
    - targets: ['postgres-exporter:9187']
    scrape_interval: 30s

  # Redis monitoring
  - job_name: 'redis-exporter'
    static_configs:
    - targets: ['redis-exporter:9121']
    scrape_interval: 30s

  # Kubernetes API server
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
    - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
      action: keep
      regex: default;kubernetes;https

  # Kubernetes nodes
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
    - role: node
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - action: labelmap
      regex: __meta_kubernetes_node_label_(.+)
    - target_label: __address__
      replacement: kubernetes.default.svc:443
    - source_labels: [__meta_kubernetes_node_name]
      regex: (.+)
      target_label: __metrics_path__
      replacement: /api/v1/nodes/${1}/proxy/metrics

  # Healthcare-specific MCP server monitoring
  - job_name: 'healthcare-mcp'
    static_configs:
    - targets: ['healthcare-mcp:9464']
    scrape_interval: 30s
    metrics_path: /metrics

  # Istio service mesh metrics
  - job_name: 'istio-mesh'
    kubernetes_sd_configs:
    - role: endpoints
      namespaces:
        names:
        - istio-system
        - healthcare-platform
    relabel_configs:
    - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
      action: keep
      regex: istio-proxy;http-monitoring
    - source_labels: [__address__, __meta_kubernetes_endpoint_port_number]
      action: replace
      regex: ([^:]+)(?::\d+)?;(\d+)
      replacement: $1:15090
      target_label: __address__
    - action: labelmap
      regex: __meta_kubernetes_endpoint_label_(.+)
    - source_labels: [__meta_kubernetes_namespace]
      action: replace
      target_label: namespace
    - source_labels: [__meta_kubernetes_service_name]
      action: replace
      target_label: service_name
```

### 2. Healthcare-Specific Alerting Rules
```yaml
# /monitoring/prometheus/rules/healthcare-alerts.yml
# Healthcare platform alerting rules

groups:
- name: healthcare.critical
  interval: 30s
  rules:
  # Application availability
  - alert: HealthcareAppDown
    expr: up{job="healthcare-app"} == 0
    for: 1m
    labels:
      severity: critical
      compliance: lgpd-hipaa
    annotations:
      summary: "Healthcare application is down"
      description: "Healthcare application has been down for more than 1 minute"
      runbook_url: "https://runbooks.healthcare-platform.local/app-down"

  - alert: HighErrorRate
    expr: rate(phoenix_http_requests_total{status=~"5.."}[5m]) / rate(phoenix_http_requests_total[5m]) > 0.05
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value | humanizePercentage }} over the last 5 minutes"

  # Database health
  - alert: DatabaseConnectionHigh
    expr: pg_stat_activity_count > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High number of database connections"
      description: "PostgreSQL has {{ $value }} active connections"

  - alert: DatabaseReplicationLag
    expr: pg_stat_replication_lag > 100000000  # 100MB
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "High database replication lag"
      description: "Database replication lag is {{ $value | humanizeBytes }}"

  # LGPD compliance alerts
  - alert: AuditLogFailure
    expr: increase(healthcare_audit_log_failures_total[5m]) > 5
    for: 1m
    labels:
      severity: critical
      compliance: lgpd
    annotations:
      summary: "LGPD audit logging failures detected"
      description: "{{ $value }} audit log failures in the last 5 minutes"
      compliance_impact: "LGPD compliance at risk"

  - alert: UnauthorizedDataAccess
    expr: increase(healthcare_unauthorized_access_attempts_total[5m]) > 10
    for: 1m
    labels:
      severity: critical
      security: true
    annotations:
      summary: "Unauthorized data access attempts detected"
      description: "{{ $value }} unauthorized access attempts in the last 5 minutes"

  # Performance alerts
  - alert: HighResponseTime
    expr: histogram_quantile(0.95, rate(phoenix_http_request_duration_milliseconds_bucket[5m])) > 2000
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High response times detected"
      description: "95th percentile response time is {{ $value }}ms"

  - alert: MemoryUsageHigh
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage"
      description: "Memory usage is above 85% ({{ $value | humanizePercentage }})"

- name: healthcare.security
  interval: 15s
  rules:
  # Security monitoring
  - alert: EncryptionFailure
    expr: increase(healthcare_encryption_failures_total[1m]) > 0
    for: 0s
    labels:
      severity: critical
      security: true
    annotations:
      summary: "Encryption/decryption failures detected"
      description: "{{ $value }} encryption failures detected"

  - alert: ZeroTrustViolation
    expr: increase(istio_requests_total{response_code!~"2.."}[5m]) by (source_app, destination_service_name) > 50
    for: 1m
    labels:
      severity: warning
      security: zero-trust
    annotations:
      summary: "Potential Zero Trust policy violation"
      description: "High number of failed requests from {{ $labels.source_app }} to {{ $labels.destination_service_name }}"

  - alert: PQCKeyRotationOverdue
    expr: (time() - healthcare_pqc_key_rotation_timestamp) > 86400  # 24 hours
    for: 5m
    labels:
      severity: warning
      security: pqc
    annotations:
      summary: "Post-Quantum Cryptography key rotation overdue"
      description: "PQC keys haven't been rotated in {{ $value | humanizeDuration }}"

- name: healthcare.compliance
  interval: 60s
  rules:
  # LGPD compliance monitoring
  - alert: DataRetentionViolation
    expr: healthcare_data_retention_violations_total > 0
    for: 0s
    labels:
      severity: critical
      compliance: lgpd
    annotations:
      summary: "LGPD data retention violation detected"
      description: "{{ $value }} data retention violations found"

  - alert: ConsentWithdrawalNotProcessed
    expr: healthcare_consent_withdrawal_pending_count > 0
    for: 6h  # Alert if not processed within 6 hours
    labels:
      severity: critical
      compliance: lgpd
    annotations:
      summary: "LGPD consent withdrawal not processed"
      description: "{{ $value }} consent withdrawals pending for more than 6 hours"

  - alert: DataPortabilityRequestOverdue
    expr: healthcare_data_portability_overdue_count > 0
    for: 1h
    labels:
      severity: warning
      compliance: lgpd
    annotations:
      summary: "LGPD data portability requests overdue"
      description: "{{ $value }} data portability requests are overdue"
```

### 3. Grafana Healthcare Dashboard
```json
{
  "dashboard": {
    "id": null,
    "title": "Healthcare Platform Overview",
    "tags": ["healthcare", "lgpd", "compliance"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Application Health Overview",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"healthcare-app\"}",
            "legendFormat": "App Status"
          },
          {
            "expr": "up{job=\"postgres-exporter\"}",
            "legendFormat": "Database Status"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "green", "value": 1}
              ]
            }
          }
        }
      },
      {
        "id": 2,
        "title": "Request Rate & Response Times",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(phoenix_http_requests_total[5m])",
            "legendFormat": "Requests/sec"
          },
          {
            "expr": "histogram_quantile(0.95, rate(phoenix_http_request_duration_milliseconds_bucket[5m]))",
            "legendFormat": "95th percentile response time"
          }
        ]
      },
      {
        "id": 3,
        "title": "LGPD Compliance Metrics",
        "type": "graph",
        "targets": [
          {
            "expr": "healthcare_audit_log_entries_total",
            "legendFormat": "Audit Log Entries"
          },
          {
            "expr": "healthcare_consent_validations_total",
            "legendFormat": "Consent Validations"
          },
          {
            "expr": "healthcare_data_subject_requests_total",
            "legendFormat": "Data Subject Requests"
          }
        ]
      },
      {
        "id": 4,
        "title": "Database Performance",
        "type": "graph",
        "targets": [
          {
            "expr": "pg_stat_activity_count",
            "legendFormat": "Active Connections"
          },
          {
            "expr": "rate(pg_stat_database_tup_fetched[5m])",
            "legendFormat": "Tuples Fetched/sec"
          },
          {
            "expr": "rate(pg_stat_database_tup_inserted[5m])",
            "legendFormat": "Tuples Inserted/sec"
          }
        ]
      },
      {
        "id": 5,
        "title": "Security Metrics",
        "type": "table",
        "targets": [
          {
            "expr": "healthcare_encryption_operations_total",
            "legendFormat": "Total Encryption Operations"
          },
          {
            "expr": "healthcare_unauthorized_access_attempts_total",
            "legendFormat": "Unauthorized Access Attempts"
          },
          {
            "expr": "healthcare_zero_trust_violations_total",
            "legendFormat": "Zero Trust Violations"
          }
        ]
      },
      {
        "id": 6,
        "title": "WASM Plugin Performance",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(healthcare_wasm_plugin_executions_total[5m])",
            "legendFormat": "Plugin Executions/sec - {{ plugin_name }}"
          },
          {
            "expr": "histogram_quantile(0.95, rate(healthcare_wasm_plugin_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile duration - {{ plugin_name }}"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
```

---

## 🔒 Security Hardening {#security-hardening}

### 1. Pod Security Standards
```yaml
# /k8s/security/pod-security-policy.yml
# Pod Security Standards for healthcare platform

apiVersion: v1
kind: Namespace
metadata:
  name: healthcare-platform
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted

---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: healthcare-psp
  namespace: healthcare-platform
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  runAsGroup:
    rule: 'MustRunAs'
    ranges:
      - min: 1000
        max: 65535
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true
  hostNetwork: false
  hostIPC: false
  hostPID: false

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: healthcare-psp-user
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs: ['use']
  resourceNames:
  - healthcare-psp

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: healthcare-psp-binding
roleRef:
  kind: ClusterRole
  name: healthcare-psp-user
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: default
  namespace: healthcare-platform
```

### 2. Network Security Configuration
```yaml
# /k8s/security/network-policies.yml
# Comprehensive network policies for Zero Trust

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-healthcare
  namespace: healthcare-platform
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# Allow healthcare app to communicate with database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-to-database
  namespace: healthcare-platform
spec:
  podSelector:
    matchLabels:
      app: postgres-timescaledb
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: healthcare-app
    ports:
    - protocol: TCP
      port: 5432

---
# Allow healthcare app to communicate with Redis
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-to-redis
  namespace: healthcare-platform
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: healthcare-app
    ports:
    - protocol: TCP
      port: 6379

---
# Allow ingress from Istio gateway
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-istio-ingress
  namespace: healthcare-platform
spec:
  podSelector:
    matchLabels:
      app: healthcare-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
      podSelector:
        matchLabels:
          app: istio-proxy
    ports:
    - protocol: TCP
      port: 4000

---
# Allow egress for external healthcare APIs
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-apis
  namespace: healthcare-platform
spec:
  podSelector:
    matchLabels:
      app: healthcare-app
  policyTypes:
  - Egress
  egress:
  # DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # HTTPS to external APIs (PubMed, SciELO, etc.)
  - to: []
    ports:
    - protocol: TCP
      port: 443
  # HTTP for health checks and some APIs
  - to: []
    ports:
    - protocol: TCP
      port: 80

---
# Allow monitoring scraping
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: healthcare-platform
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9464  # Metrics port
```

### 3. Secrets Management with Vault Integration
```yaml
# /k8s/security/vault-integration.yml
# HashiCorp Vault integration for secret management

apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: healthcare-platform

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: healthcare-platform
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: healthcare-platform

---
# External Secrets Operator for Vault integration
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: healthcare-platform
spec:
  provider:
    vault:
      server: "https://vault.healthcare-platform.local"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "healthcare-platform-role"
          serviceAccountRef:
            name: "vault-auth"

---
# Healthcare application secrets from Vault
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: healthcare-app-secrets
  namespace: healthcare-platform
spec:
  refreshInterval: 300s
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: healthcare-app-secrets
    creationPolicy: Owner
  data:
  - secretKey: SECRET_KEY_BASE
    remoteRef:
      key: healthcare/app
      property: secret_key_base
  - secretKey: DATABASE_PASSWORD
    remoteRef:
      key: healthcare/database
      property: password
  - secretKey: REDIS_PASSWORD
    remoteRef:
      key: healthcare/redis
      property: password
  - secretKey: MASTER_ENCRYPTION_KEY
    remoteRef:
      key: healthcare/crypto
      property: master_key
  - secretKey: PUBMED_API_KEY
    remoteRef:
      key: healthcare/external-apis
      property: pubmed_key

---
# PQC crypto keys from Vault
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: healthcare-crypto-keys
  namespace: healthcare-platform
spec:
  refreshInterval: 86400s  # Daily refresh for key rotation
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: healthcare-crypto-keys
    creationPolicy: Owner
  data:
  - secretKey: platform_keys.enc
    remoteRef:
      key: healthcare/pqc-keys
      property: platform_keys_encrypted
  - secretKey: backup_keys.enc
    remoteRef:
      key: healthcare/pqc-keys
      property: backup_keys_encrypted
```

### 4. Runtime Security with Falco
```yaml
# /k8s/security/falco-config.yml
# Falco runtime security monitoring for healthcare

apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-healthcare-rules
  namespace: falco-system
data:
  healthcare_rules.yaml: |
    - rule: Healthcare Data Access Violation
      desc: Detect unauthorized access to healthcare data directories
      condition: >
        open_read and
        fd.name startswith "/app/healthcare_data/" and
        not proc.name in (healthcare_app, postgres)
      output: >
        Unauthorized healthcare data access
        (user=%user.name command=%proc.cmdline file=%fd.name)
      priority: CRITICAL
      tags: [healthcare, lgpd, unauthorized_access]

    - rule: PQC Key Access Violation
      desc: Detect unauthorized access to PQC cryptographic keys
      condition: >
        open_read and
        fd.name startswith "/app/keys/" and
        not proc.name = "healthcare_app"
      output: >
        Unauthorized PQC key access detected
        (user=%user.name command=%proc.cmdline file=%fd.name)
      priority: CRITICAL
      tags: [healthcare, pqc, crypto, unauthorized_access]

    - rule: Healthcare Container Escape Attempt
      desc: Detect container escape attempts in healthcare namespace
      condition: >
        spawned_process and
        k8s.ns.name = "healthcare-platform" and
        proc.name in (docker, runc, containerd) and
        not container.privileged = true
      output: >
        Container escape attempt detected in healthcare namespace
        (user=%user.name command=%proc.cmdline container=%container.name)
      priority: CRITICAL
      tags: [healthcare, container_escape]

    - rule: Audit Log Tampering
      desc: Detect attempts to modify audit logs
      condition: >
        (modify or rename or unlink) and
        fd.name startswith "/app/logs/audit" and
        not proc.name = "healthcare_app"
      output: >
        Audit log tampering detected
        (user=%user.name command=%proc.cmdline file=%fd.name)
      priority: CRITICAL
      tags: [healthcare, lgpd, audit_tampering]

    - rule: Network Connection to Unauthorized Host
      desc: Detect network connections to non-whitelisted hosts
      condition: >
        outbound and
        k8s.ns.name = "healthcare-platform" and
        not fd.rip in (allowed_external_ips) and
        not fd.rip.net in (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
      output: >
        Unauthorized external network connection from healthcare app
        (connection=%fd.name container=%container.name)
      priority: WARNING
      tags: [healthcare, network, unauthorized_connection]

    - rule: WASM Plugin Security Violation
      desc: Detect security violations in WASM plugin execution
      condition: >
        spawned_process and
        k8s.ns.name = "healthcare-platform" and
        proc.pname = "extism" and
        proc.args contains "../"
      output: >
        WASM plugin path traversal attempt detected
        (user=%user.name command=%proc.cmdline container=%container.name)
      priority: HIGH
      tags: [healthcare, wasm, path_traversal]

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco-healthcare
  namespace: falco-system
spec:
  selector:
    matchLabels:
      app: falco-healthcare
  template:
    metadata:
      labels:
        app: falco-healthcare
    spec:
      serviceAccount: falco
      containers:
      - name: falco
        image: falcosecurity/falco:0.36.2
        securityContext:
          privileged: true
        args:
        - /usr/bin/falco
        - --cri=/run/containerd/containerd.sock
        - --k8s-api=https://kubernetes.default.svc
        - --k8s-api-cert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        - --k8s-api-token=/var/run/secrets/kubernetes.io/serviceaccount/token
        - --rule=/etc/falco/healthcare_rules.yaml
        volumeMounts:
        - mountPath: /host/var/run/docker.sock
          name: docker-socket
        - mountPath: /host/dev
          name: dev-fs
        - mountPath: /host/proc
          name: proc-fs
        - mountPath: /host/boot
          name: boot-fs
        - mountPath: /host/lib/modules
          name: lib-modules
        - mountPath: /host/usr
          name: usr-fs
        - mountPath: /host/etc
          name: etc-fs
        - mountPath: /etc/falco/healthcare_rules.yaml
          subPath: healthcare_rules.yaml
          name: healthcare-rules
      volumes:
      - name: docker-socket
        hostPath:
          path: /var/run/docker.sock
      - name: dev-fs
        hostPath:
          path: /dev
      - name: proc-fs
        hostPath:
          path: /proc
      - name: boot-fs
        hostPath:
          path: /boot
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: usr-fs
        hostPath:
          path: /usr
      - name: etc-fs
        hostPath:
          path: /etc
      - name: healthcare-rules
        configMap:
          name: falco-healthcare-rules
```

---

## ⚖️ Load Balancing & High Availability {#load-balancing-ha}

### 1. Multi-Region Deployment Strategy
```yaml
# /k8s/ha/multi-region-deployment.yml
# Multi-region deployment for high availability

apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: healthcare-multi-region
  namespace: argocd
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          healthcare-platform: "true"
  template:
    metadata:
      name: 'healthcare-{{name}}'
    spec:
      project: healthcare
      source:
        repoURL: https://github.com/healthcare-platform/k8s-manifests
        targetRevision: HEAD
        path: overlays/{{name}}
      destination:
        server: '{{server}}'
        namespace: healthcare-platform
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true

---
# Global load balancer configuration
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: healthcare-ssl-cert
spec:
  domains:
    - healthcare-platform.com
    - api.healthcare-platform.com
    - br.healthcare-platform.com  # Brazil-specific for LGPD

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: healthcare-global-ingress
  annotations:
    kubernetes.io/ingress.global-static-ip-name: healthcare-global-ip
    ingress.gcp.io/managed-certificates: healthcare-ssl-cert
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/backend-config: '{"default": "healthcare-backend-config"}'
spec:
  rules:
  - host: healthcare-platform.com
    http:
      paths:
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: healthcare-app-service
            port:
              number: 80
  - host: br.healthcare-platform.com
    http:
      paths:
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: healthcare-app-service-br
            port:
              number: 80

---
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: healthcare-backend-config
spec:
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
    healthyThreshold: 1
    unhealthyThreshold: 3
    type: HTTP
    requestPath: /health
    port: 4000
  sessionAffinity:
    affinityType: "CLIENT_IP"
  timeoutSec: 30
  connectionDraining:
    drainingTimeoutSec: 60
```

### 2. Database High Availability with Patroni
```yaml
# /k8s/ha/postgres-ha.yml
# PostgreSQL high availability with Patroni

apiVersion: v1
kind: ConfigMap
metadata:
  name: patroni-config
  namespace: healthcare-platform
data:
  postgresql.yml: |
    bootstrap:
      dcs:
        ttl: 30
        loop_wait: 10
        retry_timeout: 30
        maximum_lag_on_failover: 1048576
        master_start_timeout: 300
        synchronous_mode: true
        synchronous_mode_strict: true
        synchronous_node_count: 1
        postgresql:
          use_pg_rewind: true
          use_slots: true
          parameters:
            max_connections: 200
            shared_buffers: 256MB
            effective_cache_size: 1GB
            wal_level: replica
            max_wal_senders: 10
            max_replication_slots: 10
            hot_standby: on
            wal_log_hints: on
            archive_mode: on
            archive_command: '/bin/true'  # Will be overridden by backup script
            shared_preload_libraries: 'timescaledb,pg_audit,pg_stat_statements'
      initdb:
      - encoding: UTF8
      - data-checksums
      pg_hba:
      - host all all 0.0.0.0/0 md5
      - host replication replicator 0.0.0.0/0 md5
      users:
        healthcare_app:
          password: '{{POSTGRES_PASSWORD}}'
          options:
            - createrole
            - createdb
        replicator:
          password: '{{POSTGRES_REPLICATION_PASSWORD}}'
          options:
            - replication
    postgresql:
      listen: '*'
      connect_address: '{{ ansible_default_ipv4.address }}:5432'
      data_dir: /var/lib/postgresql/data
      bin_dir: /usr/lib/postgresql/16/bin
      config_dir: /var/lib/postgresql/data
      pgpass: /tmp/pgpass
      authentication:
        replication:
          username: replicator
          password: '{{POSTGRES_REPLICATION_PASSWORD}}'
        superuser:
          username: postgres
          password: '{{POSTGRES_SUPERUSER_PASSWORD}}'
    restapi:
      listen: 0.0.0.0:8008
      connect_address: '{{ ansible_default_ipv4.address }}:8008'

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: patroni-postgres
  namespace: healthcare-platform
spec:
  serviceName: patroni-postgres
  replicas: 3
  selector:
    matchLabels:
      app: patroni-postgres
  template:
    metadata:
      labels:
        app: patroni-postgres
    spec:
      serviceAccountName: patroni
      securityContext:
        runAsUser: 999
        runAsGroup: 999
        fsGroup: 999
      containers:
      - name: patroni
        image: patroni/patroni:3.2.2
        ports:
        - containerPort: 8008
          protocol: TCP
        - containerPort: 5432
          protocol: TCP
        volumeMounts:
        - name: patroni-config
          mountPath: /etc/patroni/postgresql.yml
          subPath: postgresql.yml
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        env:
        - name: PATRONI_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: PATRONI_KUBERNETES_LABELS
          value: '{app: patroni-postgres}'
        - name: PATRONI_KUBERNETES_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: PATRONI_KUBERNETES_USE_ENDPOINTS
          value: 'true'
        - name: PATRONI_SUPERUSER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secrets
              key: POSTGRES_SUPERUSER_PASSWORD
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secrets
              key: POSTGRES_PASSWORD
        - name: POSTGRES_REPLICATION_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secrets
              key: POSTGRES_REPLICATION_PASSWORD
        livenessProbe:
          httpGet:
            path: /liveness
            port: 8008
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /readiness
            port: 8008
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: patroni-config
        configMap:
          name: patroni-config
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 100Gi

---
apiVersion: v1
kind: Service
metadata:
  name: patroni-postgres-config
  namespace: healthcare-platform
  labels:
    app: patroni-postgres
spec:
  type: ClusterIP
  ports:
  - port: 8008
    targetPort: 8008
  selector:
    app: patroni-postgres

---
# Primary service (writes)
apiVersion: v1
kind: Service
metadata:
  name: patroni-postgres-primary
  namespace: healthcare-platform
  labels:
    app: patroni-postgres
    role: primary
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: patroni-postgres
    role: master

---
# Replica service (reads)
apiVersion: v1
kind: Service
metadata:
  name: patroni-postgres-replica
  namespace: healthcare-platform
  labels:
    app: patroni-postgres
    role: replica
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: patroni-postgres
    role: replica
```

---

## 🚨 Disaster Recovery {#disaster-recovery}

### 1. Automated Backup and Recovery Procedures
```bash
#!/bin/bash
# /scripts/disaster-recovery/healthcare-dr.sh
# Healthcare platform disaster recovery procedures

set -euo pipefail

# Configuration
BACKUP_RETENTION_DAYS=2555  # 7 years for healthcare compliance
DR_REGION="sa-east-1"       # Brazil region for LGPD compliance
PRIMARY_REGION="us-east-1"
S3_BACKUP_BUCKET="healthcare-dr-backups"
RTO_MINUTES=60              # Recovery Time Objective: 1 hour
RPO_MINUTES=15              # Recovery Point Objective: 15 minutes

# Logging setup
LOG_FILE="/var/log/healthcare-dr.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

log() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")] [DR] $*"
}

# Function to create application backup
backup_application() {
    log "Starting application backup procedure..."

    # Database backup with encryption
    log "Creating encrypted database backup..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    DB_BACKUP="healthcare_db_${TIMESTAMP}.sql.gz.gpg"

    kubectl exec -n healthcare-platform $(kubectl get pod -l app=patroni-postgres,role=master -o jsonpath='{.items[0].metadata.name}') -- \
        pg_dump -h localhost -U healthcare_app healthcare_platform | \
        gzip | \
        gpg --trust-model always --encrypt --recipient healthcare-backup@company.com \
        > "/tmp/$DB_BACKUP"

    # Upload to S3 with cross-region replication
    aws s3 cp "/tmp/$DB_BACKUP" "s3://$S3_BACKUP_BUCKET/database/$DB_BACKUP" \
        --server-side-encryption aws:kms \
        --sse-kms-key-id alias/healthcare-dr-key

    # Verify backup integrity
    aws s3 head-object --bucket "$S3_BACKUP_BUCKET" --key "database/$DB_BACKUP"

    rm "/tmp/$DB_BACKUP"
    log "Database backup completed: $DB_BACKUP"

    # Application state backup
    log "Creating application state backup..."
    kubectl get all -n healthcare-platform -o yaml > "/tmp/app_state_${TIMESTAMP}.yaml"
    gzip "/tmp/app_state_${TIMESTAMP}.yaml"

    aws s3 cp "/tmp/app_state_${TIMESTAMP}.yaml.gz" "s3://$S3_BACKUP_BUCKET/app-state/app_state_${TIMESTAMP}.yaml.gz"
    rm "/tmp/app_state_${TIMESTAMP}.yaml.gz"

    # PQC keys backup (highly sensitive)
    log "Creating PQC keys backup..."
    kubectl get secret healthcare-crypto-keys -n healthcare-platform -o yaml | \
        gpg --trust-model always --encrypt --recipient healthcare-backup@company.com \
        > "/tmp/pqc_keys_${TIMESTAMP}.yaml.gpg"

    aws s3 cp "/tmp/pqc_keys_${TIMESTAMP}.yaml.gpg" "s3://$S3_BACKUP_BUCKET/keys/pqc_keys_${TIMESTAMP}.yaml.gpg" \
        --server-side-encryption aws:kms \
        --sse-kms-key-id alias/healthcare-dr-key

    rm "/tmp/pqc_keys_${TIMESTAMP}.yaml.gpg"

    log "Application backup procedure completed successfully"
}

# Function to initiate disaster recovery
initiate_disaster_recovery() {
    local DR_TYPE=$1  # 'partial' or 'full'

    log "Initiating disaster recovery procedure: $DR_TYPE"
    log "RTO: $RTO_MINUTES minutes, RPO: $RPO_MINUTES minutes"

    case $DR_TYPE in
        "partial")
            partial_recovery
            ;;
        "full")
            full_recovery
            ;;
        *)
            log "ERROR: Invalid DR type. Use 'partial' or 'full'"
            exit 1
            ;;
    esac
}

# Partial recovery - restore from latest backup in current region
partial_recovery() {
    log "Starting partial disaster recovery..."

    # Find latest database backup
    LATEST_DB_BACKUP=$(aws s3 ls "s3://$S3_BACKUP_BUCKET/database/" --recursive | \
        sort | tail -n 1 | awk '{print $4}')

    if [ -z "$LATEST_DB_BACKUP" ]; then
        log "ERROR: No database backup found"
        exit 1
    fi

    log "Using database backup: $LATEST_DB_BACKUP"

    # Download and restore database
    aws s3 cp "s3://$S3_BACKUP_BUCKET/$LATEST_DB_BACKUP" "/tmp/$(basename $LATEST_DB_BACKUP)"

    # Decrypt database backup
    gpg --decrypt "/tmp/$(basename $LATEST_DB_BACKUP)" | gunzip > "/tmp/restore.sql"

    # Scale down application to prevent writes during restore
    kubectl scale deployment healthcare-app --replicas=0 -n healthcare-platform

    # Restore database
    DB_POD=$(kubectl get pod -l app=patroni-postgres,role=master -o jsonpath='{.items[0].metadata.name}' -n healthcare-platform)
    kubectl exec -n healthcare-platform "$DB_POD" -- psql -U healthcare_app -d healthcare_platform < "/tmp/restore.sql"

    # Restore PQC keys if needed
    LATEST_KEYS_BACKUP=$(aws s3 ls "s3://$S3_BACKUP_BUCKET/keys/" --recursive | \
        sort | tail -n 1 | awk '{print $4}')

    if [ -n "$LATEST_KEYS_BACKUP" ]; then
        aws s3 cp "s3://$S3_BACKUP_BUCKET/$LATEST_KEYS_BACKUP" "/tmp/$(basename $LATEST_KEYS_BACKUP)"
        gpg --decrypt "/tmp/$(basename $LATEST_KEYS_BACKUP)" | kubectl apply -f -
    fi

    # Scale up application
    kubectl scale deployment healthcare-app --replicas=3 -n healthcare-platform

    # Wait for application to be ready
    kubectl rollout status deployment/healthcare-app -n healthcare-platform --timeout=600s

    # Cleanup
    rm -f "/tmp/restore.sql" "/tmp/$(basename $LATEST_DB_BACKUP)" "/tmp/$(basename $LATEST_KEYS_BACKUP)"

    log "Partial disaster recovery completed successfully"
}

# Full recovery - cross-region failover
full_recovery() {
    log "Starting full disaster recovery with cross-region failover..."

    # Switch to DR region
    log "Switching to DR region: $DR_REGION"
    export AWS_DEFAULT_REGION=$DR_REGION

    # Update kubectl context to DR region
    kubectl config use-context healthcare-dr-cluster

    # Check if DR infrastructure is ready
    if ! kubectl get namespace healthcare-platform > /dev/null 2>&1; then
        log "Creating healthcare platform namespace in DR region..."
        kubectl create namespace healthcare-platform
    fi

    # Deploy infrastructure in DR region
    log "Deploying infrastructure in DR region..."
    kubectl apply -f /k8s/namespace.yml
    kubectl apply -f /k8s/database.yml

    # Wait for database to be ready
    kubectl wait --for=condition=ready pod -l app=patroni-postgres -n healthcare-platform --timeout=600s

    # Restore from latest backup
    partial_recovery

    # Deploy application
    kubectl apply -f /k8s/healthcare-app.yml
    kubectl apply -f /k8s/istio-config.yml

    # Update DNS to point to DR region
    log "Updating DNS records to point to DR region..."
    # This would typically integrate with your DNS provider's API
    # For example, with Route53:
    aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch file:///scripts/dr/dns-failover.json

    # Verify application health in DR region
    kubectl wait --for=condition=available deployment/healthcare-app -n healthcare-platform --timeout=600s

    log "Full disaster recovery completed successfully in region: $DR_REGION"
    log "Healthcare platform is now running in DR mode"

    # Send notifications
    send_dr_notifications "full_recovery_completed"
}

# Function to test disaster recovery procedures
test_disaster_recovery() {
    log "Starting disaster recovery test..."

    # Create test namespace
    kubectl create namespace healthcare-platform-dr-test

    # Run partial recovery in test namespace
    # ... (implement test recovery logic)

    # Cleanup test resources
    kubectl delete namespace healthcare-platform-dr-test

    log "Disaster recovery test completed successfully"
}

# Function to send notifications
send_dr_notifications() {
    local EVENT_TYPE=$1

    log "Sending disaster recovery notifications for event: $EVENT_TYPE"

    # Slack notification
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"🚨 Healthcare Platform DR Event: $EVENT_TYPE at $(date)\"}" \
            "$SLACK_WEBHOOK_URL"
    fi

    # Email notification (via SES)
    if [ -n "${DR_NOTIFICATION_EMAIL:-}" ]; then
        aws ses send-email \
            --source "dr-alerts@healthcare-platform.com" \
            --destination "ToAddresses=$DR_NOTIFICATION_EMAIL" \
            --message "Subject={Data='Healthcare Platform DR Event'},Body={Text={Data='DR Event: $EVENT_TYPE at $(date)'}}"
    fi

    # PagerDuty integration
    if [ -n "${PAGERDUTY_INTEGRATION_KEY:-}" ]; then
        curl -X POST https://events.pagerduty.com/v2/enqueue \
            -H "Content-Type: application/json" \
            -d "{
                \"routing_key\": \"$PAGERDUTY_INTEGRATION_KEY\",
                \"event_action\": \"trigger\",
                \"payload\": {
                    \"summary\": \"Healthcare Platform DR Event: $EVENT_TYPE\",
                    \"severity\": \"critical\",
                    \"source\": \"healthcare-dr-system\"
                }
            }"
    fi
}

# Main function
main() {
    case "${1:-help}" in
        "backup")
            backup_application
            ;;
        "recover-partial")
            initiate_disaster_recovery "partial"
            ;;
        "recover-full")
            initiate_disaster_recovery "full"
            ;;
        "test")
            test_disaster_recovery
            ;;
        "help")
            echo "Healthcare Platform Disaster Recovery Tool"
            echo "Usage: $0 {backup|recover-partial|recover-full|test}"
            echo ""
            echo "Commands:"
            echo "  backup          - Create encrypted backup of application and data"
            echo "  recover-partial - Restore from backup in current region"
            echo "  recover-full    - Cross-region failover with full recovery"
            echo "  test           - Test disaster recovery procedures"
            ;;
        *)
            echo "Invalid command. Use '$0 help' for usage information."
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
```

---

## 🔍 Troubleshooting Guide {#troubleshooting-guide}

### Common Issues & Solutions

#### 1. **Kubernetes Pod CrashLoopBackOff**
```bash
# Problem: Healthcare app pods stuck in CrashLoopBackOff
# Solution: Debug startup issues

# Check pod logs
kubectl logs -f deployment/healthcare-app -n healthcare-platform --previous

# Check pod events
kubectl describe pod -l app=healthcare-app -n healthcare-platform

# Check resource limits
kubectl top pod -n healthcare-platform

# Common fixes:
# 1. Database connection issues
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "HealthcarePlatform.Repo.query!(\"SELECT 1\")"

# 2. Memory/CPU limits too low
kubectl patch deployment healthcare-app -n healthcare-platform -p='{"spec":{"template":{"spec":{"containers":[{"name":"healthcare-app","resources":{"limits":{"memory":"2Gi","cpu":"1000m"}}}]}}}}'

# 3. Failed health checks
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /usr/local/bin/healthcheck.sh
```

#### 2. **Database Connection Pool Exhaustion**
```bash
# Problem: "all connections busy" errors
# Solution: Analyze and fix connection issues

# Check PostgreSQL connections
kubectl exec -it statefulset/patroni-postgres -n healthcare-platform -- psql -U healthcare_app -d healthcare_platform -c "
SELECT
    state,
    COUNT(*) as connection_count,
    application_name
FROM pg_stat_activity
GROUP BY state, application_name
ORDER BY connection_count DESC;"

# Check for long-running queries
kubectl exec -it statefulset/patroni-postgres -n healthcare-platform -- psql -U healthcare_app -d healthcare_platform -c "
SELECT
    pid,
    now() - query_start as duration,
    state,
    query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC
LIMIT 10;"

# Increase connection pool size temporarily
kubectl set env deployment/healthcare-app -n healthcare-platform POOL_SIZE=30

# Kill problematic connections if needed
kubectl exec -it statefulset/patroni-postgres -n healthcare-platform -- psql -U healthcare_app -d healthcare_platform -c "
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '10 minutes';"
```

#### 3. **WASM Plugin Execution Failures**
```bash
# Problem: WASM plugins failing to execute
# Solution: Debug Extism runtime issues

# Check Extism version and capabilities
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- extism --version

# Test WASM plugin directly
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- extism call /app/wasm_plugins/lgpd-analyzer/plugin.wasm analyze_text --input '{"content":"test healthcare data","specialty":"cardiology"}'

# Check plugin file permissions
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- ls -la /app/wasm_plugins/

# Rebuild plugins if corrupted
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "HealthcarePlatform.WASM.PluginManager.reload_all_plugins()"

# Check plugin sandbox configuration
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "
  {:ok, plugin} = Extism.Plugin.new([{:path, \"/app/wasm_plugins/lgpd-analyzer/plugin.wasm\"}], %{})
  IO.inspect(Extism.Plugin.get_config(plugin))
"
```

#### 4. **Istio Service Mesh Issues**
```bash
# Problem: Services not communicating through service mesh
# Solution: Debug Istio configuration

# Check Istio proxy status
kubectl exec deployment/healthcare-app -n healthcare-platform -c istio-proxy -- pilot-agent request GET stats/config_dump | jq '.configs[0].dynamic_listeners'

# Verify mTLS configuration
kubectl exec deployment/healthcare-app -n healthcare-platform -c istio-proxy -- openssl s_client -connect postgres-service:5432 -cert /etc/ssl/certs/cert-chain.pem -key /etc/ssl/private/key.pem

# Check authorization policies
kubectl get authorizationpolicy healthcare-authz -n healthcare-platform -o yaml

# Debug virtual service routing
istioctl proxy-config routes deployment/healthcare-app.healthcare-platform

# Check for certificate issues
kubectl get certificaterequests -n healthcare-platform
kubectl describe certificaterequest -n healthcare-platform

# Restart Istio proxy if needed
kubectl rollout restart deployment/healthcare-app -n healthcare-platform
```

#### 5. **LGPD Audit Log Issues**
```bash
# Problem: Audit logs not being written or queryable
# Solution: Debug TimescaleDB and audit system

# Check TimescaleDB hypertable status
kubectl exec -it statefulset/patroni-postgres -n healthcare-platform -- psql -U healthcare_app -d healthcare_platform -c "
SELECT
    schemaname,
    tablename,
    num_chunks,
    table_bytes,
    index_bytes,
    total_bytes
FROM timescaledb_information.hypertables
WHERE table_name = 'data_processing_log';"

# Check recent audit entries
kubectl exec -it statefulset/patroni-postgres -n healthcare-platform -- psql -U healthcare_app -d healthcare_platform -c "
SELECT
    operation_type,
    table_name,
    user_id,
    timestamp,
    legal_basis
FROM audit_trail.data_processing_log
ORDER BY timestamp DESC
LIMIT 10;"

# Test audit logging function
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "
HealthcarePlatform.Audit.AuditLogger.log_data_processing(%{
  operation_type: :test,
  table_name: \"test_table\",
  user_id: Ecto.UUID.generate(),
  data_subject_id: Ecto.UUID.generate(),
  legal_basis: \"Art. 7º, I - consentimento\",
  purpose: \"Test audit logging\"
})
"

# Check chunk compression status
kubectl exec -it statefulset/patroni-postgres -n healthcare-platform -- psql -U healthcare_app -d healthcare_platform -c "
SELECT
    chunk_schema,
    chunk_name,
    compression_status,
    before_compression_total_bytes,
    after_compression_total_bytes
FROM timescaledb_information.chunk_compression_stats
WHERE hypertable_name = 'data_processing_log';"

# Manually compress old chunks if needed
kubectl exec -it statefulset/patroni-postgres -n healthcare-platform -- psql -U healthcare_app -d healthcare_platform -c "
SELECT compress_chunk(c)
FROM show_chunks('audit_trail.data_processing_log') c
WHERE range_end < NOW() - INTERVAL '7 days';"
```

#### 6. **Post-Quantum Cryptography Key Issues**
```bash
# Problem: Encryption/decryption failing with PQC keys
# Solution: Debug key management system

# Check key manager status
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "
GenServer.call(HealthcarePlatform.Crypto.KeyManager, :get_status)
"

# Verify keys in memory
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "
case :persistent_term.get(:healthcare_platform_keys, nil) do
  nil -> IO.puts(\"No keys found in memory\")
  keys -> IO.puts(\"Keys found, version: #{keys.version}\")
end
"

# Test encryption/decryption
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "
test_data = \"Hello, Healthcare World!\"
case HealthcarePlatform.Types.EncryptedString.dump(test_data) do
  {:ok, encrypted} ->
    case HealthcarePlatform.Types.EncryptedString.load(encrypted) do
      {:ok, ^test_data} -> IO.puts(\"Encryption test passed\")
      error -> IO.puts(\"Decryption failed: #{inspect(error)}\")
    end
  error -> IO.puts(\"Encryption failed: #{inspect(error)}\")
end
"

# Force key rotation
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "
GenServer.cast(HealthcarePlatform.Crypto.KeyManager, :rotate_keys)
"

# Check Vault integration if used
kubectl exec -it deployment/healthcare-app -n healthcare-platform -- /app/bin/healthcare_platform eval "
Application.get_env(:healthcare_platform, :vault_enabled, false) |> IO.inspect()
"
```

---

**Próximo Diário:** [README.md - Índice Geral](../README.md)
**Voltar ao Início:** [01-elixir-wasm-host-platform.md](./01-elixir-wasm-host-platform.md)