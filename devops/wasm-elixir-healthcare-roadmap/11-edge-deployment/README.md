# 🌐 Módulo 11: Edge Deployment - Global Content Delivery

## 🎯 Objetivo
- Deploy em edge locations (Cloudflare, Fastly)
- WASM at the edge
- Multi-region database replication
- Low-latency para pacientes globais

**Duração**: 3-4 days

---

## 🗺️ Architecture

```
┌─────────────────────────────────────────┐
│  Patient (São Paulo)                    │
└────────┬────────────────────────────────┘
         │ < 20ms latency
         ▼
┌─────────────────────────────────────────┐
│  Edge Node (sa-east-1)                  │
│  ├─ WASM plugins cached                 │
│  ├─ Static content (CDN)                │
│  └─ PostgreSQL read replica             │
└────────┬────────────────────────────────┘
         │ Sync
         ▼
┌─────────────────────────────────────────┐
│  Primary Region (us-east-1)             │
│  - Master database                      │
│  - Long-term storage                    │
└─────────────────────────────────────────┘
```

---

**Próximo**: [12-saas-evolution](../12-saas-evolution/)
