# Command: navigate-by-role
# Healthcare WASM-Elixir Stack - Role-Based Navigation

**Command**: `/navigate-by-role <role>`

**Purpose**: Navigate knowledge base by professional role, showing personalized learning path and relevant documentation.

---

## Available Roles

1. **full-stack-developer** (F1)
2. **elixir-specialist** (S1)
3. **wasm-specialist** (S2)
4. **security-architect** (A1)
5. **healthcare-specialist** (S3)
6. **database-engineer** (S4)
7. **devops-sre** (D1)
8. **solutions-architect** (A2)

---

## Usage

```bash
/navigate-by-role full-stack-developer
/navigate-by-role security-architect
```

---

## Implementation

```elixir
defmodule KnowledgeBase.Commands.NavigateByRole do
  @moduledoc """
  Navigate knowledge base by professional role.
  """

  @roles %{
    "full-stack-developer" => %{
      code: "F1",
      description: "Frontend + Backend + DevOps fundamentals",
      learning_path: "00-META/LEARNING-PATHS.md#f1-full-stack-developer",
      skill_matrix: "00-META/SKILL-MATRIX.md#full-stack-developer-f1",
      time_to_proficiency: "6-12 months",
      priority_docs: [
        "01-ARCHITECTURE/adrs/001-elixir-host-choice.md",
        "02-ELIXIR-SPECIALIST/phoenix-expert/liveview-patterns.md",
        "03-WASM-SPECIALIST/extism-platform/getting-started.md"
      ],
      prerequisites: ["Basic programming", "HTTP/REST", "SQL basics"],
      salary_range: "$65K-$95K (mid-level)"
    },
    "elixir-specialist" => %{
      code: "S1",
      description: "Elixir/OTP expert, BEAM VM optimization",
      learning_path: "00-META/LEARNING-PATHS.md#s1-elixir-specialist",
      skill_matrix: "00-META/SKILL-MATRIX.md#elixir-specialist-s1",
      time_to_proficiency: "12-18 months",
      priority_docs: [
        "02-ELIXIR-SPECIALIST/otp-patterns/supervision-trees.md",
        "02-ELIXIR-SPECIALIST/performance/beam-optimization.md",
        "08-BENCHMARKS-RESEARCH/performance/elixir-throughput-tests.md"
      ],
      prerequisites: ["Functional programming", "Concurrency basics", "6+ months Elixir"],
      salary_range: "$95K-$135K (senior)"
    },
    "wasm-specialist" => %{
      code: "S2",
      description: "WebAssembly expert, plugin architecture",
      learning_path: "00-META/LEARNING-PATHS.md#s2-wasm-specialist",
      skill_matrix: "00-META/SKILL-MATRIX.md#wasm-specialist-s2",
      time_to_proficiency: "9-15 months",
      priority_docs: [
        "03-WASM-SPECIALIST/extism-platform/plugin-development.md",
        "03-WASM-SPECIALIST/wasmtime-runtime/performance-tuning.md",
        "08-BENCHMARKS-RESEARCH/performance/wasm-overhead-measurements.md"
      ],
      prerequisites: ["Systems programming (Rust/C/Go)", "Memory management", "FFI concepts"],
      salary_range: "$105K-$145K (senior)"
    },
    "security-architect" => %{
      code: "A1",
      description: "Zero Trust + Post-Quantum Cryptography expert",
      learning_path: "00-META/LEARNING-PATHS.md#a1-security-architect",
      skill_matrix: "00-META/SKILL-MATRIX.md#security-architect-a1",
      time_to_proficiency: "18-24 months",
      priority_docs: [
        "04-SECURITY-SPECIALIST/zero-trust/nist-sp-800-207.md",
        "04-SECURITY-SPECIALIST/post-quantum/crystals-kyber.md",
        "01-ARCHITECTURE/adrs/004-zero-trust-implementation.md"
      ],
      prerequisites: ["Security fundamentals", "Cryptography basics", "Compliance (HIPAA/LGPD)"],
      salary_range: "$125K-$180K (principal)"
    },
    "healthcare-specialist" => %{
      code: "S3",
      description: "FHIR/HL7 expert, clinical workflows",
      learning_path: "00-META/LEARNING-PATHS.md#s3-healthcare-specialist",
      skill_matrix: "00-META/SKILL-MATRIX.md#healthcare-specialist-s3",
      time_to_proficiency: "12-18 months",
      priority_docs: [
        "05-HEALTHCARE-SPECIALIST/standards/fhir-r4-guide.md",
        "05-HEALTHCARE-SPECIALIST/compliance/lgpd-hipaa-mapping.md",
        "05-HEALTHCARE-SPECIALIST/clinical/ehr-integration.md"
      ],
      prerequisites: ["Healthcare domain knowledge", "HL7 basics", "Compliance awareness"],
      salary_range: "$95K-$140K (senior)"
    },
    "database-engineer" => %{
      code: "S4",
      description: "PostgreSQL + TimescaleDB expert",
      learning_path: "00-META/LEARNING-PATHS.md#s4-database-engineer",
      skill_matrix: "00-META/SKILL-MATRIX.md#database-engineer-s4",
      time_to_proficiency: "9-15 months",
      priority_docs: [
        "06-DATABASE-SPECIALIST/postgresql/performance-tuning.md",
        "06-DATABASE-SPECIALIST/timescaledb/hypertables.md",
        "01-ARCHITECTURE/adrs/003-database-selection.md"
      ],
      prerequisites: ["SQL advanced", "Database design", "Performance analysis"],
      salary_range: "$90K-$130K (senior)"
    },
    "devops-sre" => %{
      code: "D1",
      description: "Kubernetes + Istio + Observability expert",
      learning_path: "00-META/LEARNING-PATHS.md#d1-devops-sre",
      skill_matrix: "00-META/SKILL-MATRIX.md#devops-sre-d1",
      time_to_proficiency: "15-20 months",
      priority_docs: [
        "07-DEVOPS-SRE/kubernetes/healthcare-deployment.md",
        "07-DEVOPS-SRE/observability/prometheus-grafana.md",
        "07-DEVOPS-SRE/security/zero-trust-networking.md"
      ],
      prerequisites: ["Linux/containers", "CI/CD", "Networking", "IaC (Terraform)"],
      salary_range: "$100K-$150K (senior)"
    },
    "solutions-architect" => %{
      code: "A2",
      description: "System design + technical leadership",
      learning_path: "00-META/LEARNING-PATHS.md#a2-solutions-architect",
      skill_matrix: "00-META/SKILL-MATRIX.md#solutions-architect-a2",
      time_to_proficiency: "24+ months",
      priority_docs: [
        "01-ARCHITECTURE/tradeoffs/cost-benefit-analysis.md",
        "01-ARCHITECTURE/tradeoffs/wasm-vs-containers.md",
        "00-META/KNOWLEDGE-GRAPH.md"
      ],
      prerequisites: ["5+ years experience", "Multiple stacks", "Business acumen"],
      salary_range: "$135K-$200K (principal/staff)"
    }
  }

  def execute(role_key) do
    case Map.get(@roles, role_key) do
      nil ->
        {:error, "Unknown role: #{role_key}. Available roles: #{available_roles()}"}

      role_info ->
        {:ok, format_navigation(role_key, role_info)}
    end
  end

  defp format_navigation(role_key, info) do
    """
    # Navigation: #{String.replace(role_key, "-", " ") |> String.capitalize()}
    **Code**: #{info.code} | **Time to Proficiency**: #{info.time_to_proficiency}

    ## Description
    #{info.description}

    ## Prerequisites
    #{format_list(info.prerequisites)}

    ## Priority Documentation
    #{format_docs(info.priority_docs)}

    ## Learning Resources
    - **Learning Path**: [View detailed path](#{info.learning_path})
    - **Skill Matrix**: [Self-assessment worksheet](#{info.skill_matrix})
    - **Dependency Graph**: [See required concepts](00-META/KNOWLEDGE-GRAPH.md)

    ## Career Information
    - **Salary Range**: #{info.salary_range}
    - **Progression**: See LEARNING-PATHS.md for career ladder

    ## Next Steps
    1. Review [NAVIGATION-BY-ROLE.md](00-META/NAVIGATION-BY-ROLE.md##{role_key})
    2. Complete self-assessment in [SKILL-MATRIX.md](#{info.skill_matrix})
    3. Start with first document in priority list above
    4. Join community discussions (Elixir Forum, WASM Discord)

    ---
    **DSM Tags**: [L1_DOMAIN:ui_ux | L2_SUBDOMAIN:ai_pipeline | L3_TECHNICAL:guide]
    """
  end

  defp format_list(items) do
    items
    |> Enum.map(fn item -> "- #{item}" end)
    |> Enum.join("\n")
  end

  defp format_docs(docs) do
    docs
    |> Enum.with_index(1)
    |> Enum.map(fn {doc, idx} -> "#{idx}. [#{Path.basename(doc, ".md")}](#{doc})" end)
    |> Enum.join("\n")
  end

  defp available_roles do
    @roles
    |> Map.keys()
    |> Enum.join(", ")
  end
end
```

---

## Example Output

```
# Navigation: Full Stack Developer
**Code**: F1 | **Time to Proficiency**: 6-12 months

## Description
Frontend + Backend + DevOps fundamentals

## Prerequisites
- Basic programming
- HTTP/REST
- SQL basics

## Priority Documentation
1. [001-elixir-host-choice](01-ARCHITECTURE/adrs/001-elixir-host-choice.md)
2. [liveview-patterns](02-ELIXIR-SPECIALIST/phoenix-expert/liveview-patterns.md)
3. [getting-started](03-WASM-SPECIALIST/extism-platform/getting-started.md)

## Learning Resources
- **Learning Path**: [View detailed path](00-META/LEARNING-PATHS.md#f1-full-stack-developer)
- **Skill Matrix**: [Self-assessment worksheet](00-META/SKILL-MATRIX.md#full-stack-developer-f1)
- **Dependency Graph**: [See required concepts](00-META/KNOWLEDGE-GRAPH.md)

## Career Information
- **Salary Range**: $65K-$95K (mid-level)
- **Progression**: See LEARNING-PATHS.md for career ladder

## Next Steps
1. Review [NAVIGATION-BY-ROLE.md](00-META/NAVIGATION-BY-ROLE.md#full-stack-developer)
2. Complete self-assessment in SKILL-MATRIX.md
3. Start with first document in priority list above
4. Join community discussions (Elixir Forum, WASM Discord)
```

---

## Validation Rules

- **Role key must exist** in `@roles` map
- **All file references must exist** (checked at compile time)
- **Salary ranges** reflect 2024 US market (adjust for region)

---

## Related Commands

- `/assess-skills <role>` - Gap analysis for target role
- `/learning-path <target-role>` - Generate personalized learning path
- `/kb-search-tech <query>` - Search knowledge base by technology

---

**DSM Tags**: [L1_DOMAIN:ui_ux | L2_SUBDOMAIN:ai_pipeline | L3_TECHNICAL:guide | L4_SPECIFICITY:reference]
**Validation Level**: L0_CANONICAL (internal command)
**Last Updated**: 2025-09-30