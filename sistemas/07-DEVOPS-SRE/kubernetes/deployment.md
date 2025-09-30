# Kubernetes Deployment for Healthcare Stack

**Platform**: Kubernetes 1.31
**Service Mesh**: Istio 1.24
**Healthcare Context**: HIPAA-compliant infrastructure, 99.95% uptime SLO
**Last Updated**: 2025-09-30

---

## Overview

**Kubernetes** provides the orchestration layer for the Healthcare WASM-Elixir stack:
- **High availability**: Multi-pod deployments with auto-healing
- **Zero-downtime updates**: Rolling deployments
- **Resource limits**: CPU/memory quotas (prevent noisy neighbors)
- **Secrets management**: Encrypted PHI credentials
- **Network policies**: Microsegmentation (Zero Trust)

**Healthcare Requirements**:
- HIPAA 164.312(a)(1): Access control, audit logs
- 99.95% uptime SLO (21.6 minutes downtime/month)
- Zero Trust network (NIST SP 800-207)

---

## Cluster Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Kubernetes Cluster (3 Nodes - HA)                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐│
│  │ Control Plane   │  │ Worker Node 1   │  │ Worker Node 2││
│  │                 │  │                 │  │              ││
│  │ - API Server    │  │ Elixir App (3x) │  │ PostgreSQL   ││
│  │ - Scheduler     │  │ WASM Plugins    │  │ TimescaleDB  ││
│  │ - etcd          │  │ Istio Sidecar   │  │              ││
│  └─────────────────┘  └─────────────────┘  └──────────────┘│
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Istio Service Mesh (mTLS, Traffic Management)           ││
│  └─────────────────────────────────────────────────────────┘│
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Observability (Prometheus, Grafana, Jaeger)             ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Namespace Configuration

```yaml
# namespaces.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: healthcare-prod
  labels:
    name: healthcare-prod
    istio-injection: enabled  # Auto-inject Istio sidecar
---
apiVersion: v1
kind: Namespace
metadata:
  name: healthcare-staging
  labels:
    name: healthcare-staging
    istio-injection: enabled
```

```bash
kubectl apply -f namespaces.yaml
```

---

## Elixir Application Deployment

### ConfigMap (Non-Sensitive Configuration)

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: healthcare-app-config
  namespace: healthcare-prod
data:
  PHX_HOST: "healthcare.example.com"
  PORT: "4000"
  POOL_SIZE: "20"
  LOG_LEVEL: "info"
  ECTO_IPV6: "false"
```

### Secret (Sensitive Configuration)

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: healthcare-app-secrets
  namespace: healthcare-prod
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:password@postgres-service:5432/healthcare"
  SECRET_KEY_BASE: "VERY_LONG_SECRET_KEY_BASE_64_CHARS_MIN"
  ENCRYPTION_KEY: "32_BYTE_HEX_KEY_FOR_PHI_ENCRYPTION"
  OPENAI_API_KEY: "sk-..."
```

**Security**: Encrypt secrets at rest with KMS (AWS KMS, Google Cloud KMS, or Vault).

```bash
# Create secret from file (not committed to git)
kubectl create secret generic healthcare-app-secrets \
  --from-env-file=.env.prod \
  --namespace healthcare-prod
```

### Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthcare-app
  namespace: healthcare-prod
  labels:
    app: healthcare
    version: v1.0.0
spec:
  replicas: 3  # High availability
  selector:
    matchLabels:
      app: healthcare
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max 1 extra pod during update
      maxUnavailable: 0  # Zero-downtime deployment
  template:
    metadata:
      labels:
        app: healthcare
        version: v1.0.0
    spec:
      # Security context (non-root user)
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      
      # Anti-affinity (spread pods across nodes)
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - healthcare
              topologyKey: kubernetes.io/hostname
      
      containers:
      - name: healthcare-app
        image: healthcare/elixir-app:v1.0.0
        imagePullPolicy: Always
        
        ports:
        - containerPort: 4000
          name: http
          protocol: TCP
        
        env:
        - name: PHX_HOST
          valueFrom:
            configMapKeyRef:
              name: healthcare-app-config
              key: PHX_HOST
        - name: PORT
          valueFrom:
            configMapKeyRef:
              name: healthcare-app-config
              key: PORT
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: healthcare-app-secrets
              key: DATABASE_URL
        - name: SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: healthcare-app-secrets
              key: SECRET_KEY_BASE
        
        # Resource limits (prevent resource exhaustion)
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
        
        # Liveness probe (restart if unhealthy)
        livenessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        # Readiness probe (remove from load balancer if not ready)
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 4000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        
        # Graceful shutdown (drain connections)
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]
```

```bash
kubectl apply -f deployment.yaml
```

---

## Service (Load Balancer)

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: healthcare-service
  namespace: healthcare-prod
  labels:
    app: healthcare
spec:
  type: ClusterIP  # Internal only (Istio Gateway handles external)
  selector:
    app: healthcare
  ports:
  - port: 80
    targetPort: 4000
    protocol: TCP
    name: http
  sessionAffinity: None  # Stateless (no sticky sessions)
```

---

## Horizontal Pod Autoscaler (HPA)

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: healthcare-app-hpa
  namespace: healthcare-prod
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
        averageUtilization: 70  # Scale up at 70% CPU
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300  # Wait 5 min before scaling down
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
```

---

## PostgreSQL StatefulSet

```yaml
# postgres-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: healthcare-prod
spec:
  serviceName: postgres-service
  replicas: 1  # Single primary (use Patroni for HA in production)
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: timescale/timescaledb:2.17.2-pg16
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_DB
          value: healthcare
        - name: POSTGRES_USER
          value: postgres
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secrets
              key: password
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        
        resources:
          requests:
            memory: "4Gi"
            cpu: "2000m"
          limits:
            memory: "8Gi"
            cpu: "4000m"
  
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd  # Use SSD for database
      resources:
        requests:
          storage: 100Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: healthcare-prod
spec:
  clusterIP: None  # Headless service for StatefulSet
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

---

## Istio Gateway (Ingress)

```yaml
# istio-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: healthcare-gateway
  namespace: healthcare-prod
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
      credentialName: healthcare-tls-cert  # TLS certificate secret
    hosts:
    - "healthcare.example.com"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: healthcare-routes
  namespace: healthcare-prod
spec:
  hosts:
  - "healthcare.example.com"
  gateways:
  - healthcare-gateway
  http:
  - match:
    - uri:
        prefix: /api
    route:
    - destination:
        host: healthcare-service
        port:
          number: 80
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s
```

---

## Network Policies (Zero Trust)

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: healthcare-app-policy
  namespace: healthcare-prod
spec:
  podSelector:
    matchLabels:
      app: healthcare
  policyTypes:
  - Ingress
  - Egress
  
  ingress:
  # Allow traffic from Istio ingress gateway
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
    ports:
    - protocol: TCP
      port: 4000
  
  egress:
  # Allow DNS queries
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  
  # Allow PostgreSQL connection
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  
  # Allow external HTTPS (OpenAI API, etc.)
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
```

---

## Rolling Updates (Zero-Downtime)

```bash
# Update deployment image
kubectl set image deployment/healthcare-app \
  healthcare-app=healthcare/elixir-app:v1.1.0 \
  -n healthcare-prod

# Monitor rollout
kubectl rollout status deployment/healthcare-app -n healthcare-prod

# Rollback if issues
kubectl rollout undo deployment/healthcare-app -n healthcare-prod
```

**Process**:
1. New pod starts (readiness probe fails initially)
2. Wait for readiness probe to pass
3. Add pod to load balancer
4. Remove old pod from load balancer
5. Wait 15 seconds (graceful shutdown)
6. Terminate old pod

**Result**: Zero dropped requests during deployment.

---

## Monitoring Integration

### ServiceMonitor (Prometheus)

```yaml
# servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: healthcare-app-metrics
  namespace: healthcare-prod
  labels:
    app: healthcare
spec:
  selector:
    matchLabels:
      app: healthcare
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
    scrapeTimeout: 10s
```

### PodMonitor (Istio Sidecar)

```yaml
# podmonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-sidecar-metrics
  namespace: healthcare-prod
spec:
  selector:
    matchLabels:
      app: healthcare
  podMetricsEndpoints:
  - port: http-envoy-prom
    path: /stats/prometheus
    interval: 30s
```

---

## Disaster Recovery

### Velero Backup

```bash
# Install Velero
velero install \
  --provider aws \
  --bucket healthcare-k8s-backups \
  --backup-location-config region=us-east-1 \
  --snapshot-location-config region=us-east-1

# Schedule daily backups
velero schedule create healthcare-daily \
  --schedule="0 2 * * *" \
  --include-namespaces healthcare-prod

# Restore from backup
velero restore create --from-backup healthcare-daily-20250930
```

---

## References

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/) (L0_CANONICAL)
- [Istio Documentation](https://istio.io/latest/docs/) (L0_CANONICAL)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (L0_CANONICAL)

### Books
- [Kubernetes in Action, 2nd Edition](https://www.manning.com/books/kubernetes-in-action-second-edition) (L2_VALIDATED)

---

**DSM**: [L1:infrastructure | L2:healthcare | L3:configuration | L4:guide]
**Source**: `06-infrastructure-devops.md` (Kubernetes sections)
**Version**: 1.0.0
**Related**:
- [Prometheus & Grafana](../observability/prometheus-grafana.md)
- [Zero Trust Implementation](../../04-SECURITY-SPECIALIST/zero-trust/nist-sp-800-207.md)
- [ADR 004: Zero Trust Implementation](../../01-ARCHITECTURE/adrs/004-zero-trust-implementation.md)
