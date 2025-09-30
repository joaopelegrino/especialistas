# 🚀 Módulo 08: Deployment & CI/CD - Production Pipeline

## 🎯 Objetivo
- GitLab CI/CD pipeline healthcare
- Docker + Kubernetes deployment
- Blue-green deployment
- Rollback strategies

**Duração**: 3-4 dias

---

## 🐳 Dockerfile Otimizado

```dockerfile
FROM hexpm/elixir:1.18.4-erlang-27.1.2-alpine AS builder

WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY . .
RUN mix release

FROM alpine:3.18 AS runner
RUN apk add --no-cache libstdc++ ncurses-libs
COPY --from=builder /app/_build/prod/rel/healthcare_stack ./
CMD ["./bin/healthcare_stack", "start"]
```

---

**Próximo**: [09-monitoring-observability](../09-monitoring-observability/)
