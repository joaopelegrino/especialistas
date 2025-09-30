# 🔐 Módulo 06: Security & Compliance - Zero Trust + LGPD

## 🎯 Objetivo
Implementar segurança healthcare-grade:
- Post-Quantum Cryptography (PQC)
- Zero Trust Architecture (NIST SP 800-207)
- LGPD/HIPAA compliance automation
- Audit trail imutável

**Duração**: 4-5 dias

---

## 🛡️ Post-Quantum Crypto (ex_oqs)

```elixir
# mix.exs
{:ex_oqs, "~> 0.3.0"}

# Usar ML-KEM (Kyber) para key encapsulation
defmodule HealthcareStack.Crypto do
  alias ExOqs.Kem
  
  def encrypt_patient_data(data) do
    {:ok, public_key, secret_key} = Kem.keypair("ML-KEM-768")
    {:ok, ciphertext, shared_secret} = Kem.encapsulate(public_key)
    
    # Usar shared_secret para AES-256
    encrypted = :crypto.crypto_one_time(:aes_256_gcm, shared_secret, iv, data, aad, true)
    
    {ciphertext, encrypted}
  end
end
```

**Por que PQC?**: Proteger dados médicos contra "Harvest Now, Decrypt Later" attacks.

---

## 📚 Referências
- `BOM-WASM-ELIXIR-HEALTHCARE-STACK.md:112-138` - PQC Architecture
- NIST SP 800-207 - Zero Trust

**Próximo**: [07-performance-tuning](../07-performance-tuning/)
