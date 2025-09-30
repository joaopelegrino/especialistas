# 🏗️ Módulo 04: CMS Architecture - WordPress Replacement

## 🎯 Objetivo
Construir arquitetura CMS que substitui WordPress com:
- Phoenix LiveView (real-time UI)
- WASM plugins para processamento
- PostgreSQL + Ecto (dados)
- S3-compatible storage (mídia)

**Duração**: 4-5 dias

---

## 📊 Comparação WordPress vs Stack WASM-Elixir

| Feature | WordPress | Nossa Stack | Benefício |
|---------|-----------|-------------|-----------|
| Concurrent users | ~1K | 2M+ | Escalabilidade |
| Plugin security | ⚠️ PHP code | ✅ WASM sandbox | LGPD compliance |
| Real-time | ❌ Polling | ✅ LiveView | UX superior |
| Hot reload | ❌ Restart | ✅ OTP | Zero downtime |

---

## 🏥 Healthcare CMS Requirements

Baseado em `BOM-WASM-ELIXIR-HEALTHCARE-STACK.md:36-104`:

1. **Content Types**
   - Blog posts (SEO otimizado)
   - Patient education materials
   - Professional profiles (médicos/psicólogos)
   - Scientific references

2. **Workflow**
   - Draft → Review → Legal Approval → Published
   - Compliance validation automática (CFM/CRP/ANVISA)
   - Audit trail completo

3. **WASM Integration**
   - S.1.1: LGPD analyzer (pre-publish)
   - S.1.2: Medical claims validation
   - S.3-2: SEO optimizer

---

## 🗄️ Database Schema (Ecto)

```elixir
# priv/repo/migrations/xxx_create_posts.exs
defmodule HealthcareStack.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :content, :text
      add :status, :string, default: "draft"
      add :author_id, references(:users, type: :binary_id)
      add :compliance_check, :map  # JSON com resultados LGPD
      add :audit_trail, :map       # Histórico de mudanças
      
      timestamps()
    end

    create index(:posts, [:author_id])
    create index(:posts, [:status])
  end
end
```

---

## 📚 Referências
- Phoenix LiveView: https://hexdocs.pm/phoenix_live_view
- Ecto Schemas: https://hexdocs.pm/ecto/Ecto.Schema.html

**Próximo**: [05-medical-workflows](../05-medical-workflows/)
