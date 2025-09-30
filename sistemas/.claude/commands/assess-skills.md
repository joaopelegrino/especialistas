# Command: assess-skills
# Healthcare WASM-Elixir Stack - Skills Gap Analysis

**Command**: `/assess-skills <role>`

**Purpose**: Perform gap analysis comparing current skills to target role requirements, generating personalized learning plan.

---

## Usage

```bash
/assess-skills elixir-specialist
/assess-skills security-architect
```

---

## Assessment Criteria

**Scoring**: 0-5 scale per competency
- **0**: No knowledge
- **1**: Aware (read docs)
- **2**: Beginner (can follow tutorials)
- **3**: Intermediate (can solve problems independently)
- **4**: Advanced (can optimize and teach others)
- **5**: Expert (contribute to core, write authoritative content)

---

## Implementation

```elixir
defmodule KnowledgeBase.Commands.AssessSkills do
  @moduledoc """
  Skills gap analysis for target role.
  """

  @role_competencies %{
    "full-stack-developer" => %{
      required_score: 3.0,
      competencies: [
        %{category: "Elixir/Phoenix", skills: ["Phoenix basics", "LiveView", "Ecto", "Mix"], weight: 0.30},
        %{category: "Frontend", skills: ["HTML/CSS", "JavaScript", "TailwindCSS", "Alpine.js"], weight: 0.20},
        %{category: "Database", skills: ["PostgreSQL basics", "SQL queries", "Migrations"], weight: 0.15},
        %{category: "WASM", skills: ["WASM concepts", "Extism basics", "Plugin usage"], weight: 0.15},
        %{category: "DevOps", skills: ["Docker", "Git", "CI/CD basics"], weight: 0.10},
        %{category: "Healthcare", skills: ["HIPAA basics", "PHI handling"], weight: 0.10}
      ]
    },
    "elixir-specialist" => %{
      required_score: 4.0,
      competencies: [
        %{category: "Elixir Core", skills: ["Pattern matching", "Protocols", "Metaprogramming", "Behaviours"], weight: 0.25},
        %{category: "OTP", skills: ["GenServer", "Supervisors", "Fault tolerance", "Hot code reloading"], weight: 0.25},
        %{category: "Phoenix", skills: ["Channels", "PubSub", "LiveView advanced", "Presence"], weight: 0.20},
        %{category: "BEAM VM", skills: ["Process model", "Schedulers", "Memory management", "Profiling"], weight: 0.15},
        %{category: "Performance", skills: ["Benchmarking", "Optimization", "NIFs", ":ets/:dets"], weight: 0.15}
      ]
    },
    "wasm-specialist" => %{
      required_score: 4.0,
      competencies: [
        %{category: "WASM Core", skills: ["WASM spec", "WAT format", "Component model", "WASI"], weight: 0.25},
        %{category: "Extism", skills: ["Plugin development", "Host functions", "PDKs (Rust/Go)", "Memory management"], weight: 0.25},
        %{category: "Systems Programming", skills: ["Rust/Go/C", "FFI", "Memory safety", "Concurrency"], weight: 0.20},
        %{category: "Performance", skills: ["wasm-opt", "Profiling", "AOT compilation", "Size optimization"], weight: 0.15},
        %{category: "Security", skills: ["Sandboxing", "Capabilities", "Resource limits"], weight: 0.15}
      ]
    },
    "security-architect" => %{
      required_score: 4.5,
      competencies: [
        %{category: "Zero Trust", skills: ["NIST SP 800-207", "Microsegmentation", "mTLS", "Policy enforcement"], weight: 0.25},
        %{category: "Post-Quantum Crypto", skills: ["CRYSTALS-Kyber", "CRYSTALS-Dilithium", "SPHINCS+", "Hybrid schemes"], weight: 0.25},
        %{category: "Healthcare Compliance", skills: ["HIPAA", "LGPD", "CFM regulations", "Audit logging"], weight: 0.20},
        %{category: "Application Security", skills: ["OWASP Top 10", "Threat modeling", "Pen testing", "Secure SDLC"], weight: 0.15},
        %{category: "Infrastructure Security", skills: ["Istio", "Network policies", "Secrets management", "PKI"], weight: 0.15}
      ]
    },
    "healthcare-specialist" => %{
      required_score: 4.0,
      competencies: [
        %{category: "FHIR/HL7", skills: ["FHIR R4", "Resources", "ValueSets", "HL7 v2 messages"], weight: 0.30},
        %{category: "Clinical Standards", skills: ["DICOM", "IHE profiles", "SNOMED CT", "LOINC"], weight: 0.25},
        %{category: "Compliance", skills: ["HIPAA", "LGPD", "CFM 2.314/2022", "Consent management"], weight: 0.20},
        %{category: "EHR Integration", skills: ["Epic FHIR", "Cerner", "SMART on FHIR", "CDS Hooks"], weight: 0.15},
        %{category: "Medical Workflows", skills: ["Clinical decision support", "Order entry", "Results reporting"], weight: 0.10}
      ]
    },
    "database-engineer" => %{
      required_score: 4.0,
      competencies: [
        %{category: "PostgreSQL", skills: ["Query optimization", "Indexes (B-tree/GiST/GIN)", "EXPLAIN plans", "Vacuuming"], weight: 0.30},
        %{category: "TimescaleDB", skills: ["Hypertables", "Compression", "Continuous aggregates", "Retention policies"], weight: 0.25},
        %{category: "Performance", skills: ["Connection pooling", "Partitioning", "Replication", "Caching strategies"], weight: 0.20},
        %{category: "Healthcare Data", skills: ["PHI storage", "FHIR queries", "Time-series medical data", "Backup/recovery"], weight: 0.15},
        %{category: "Extensions", skills: ["pgvector", "PostGIS", "pg_stat_statements"], weight: 0.10}
      ]
    },
    "devops-sre" => %{
      required_score: 4.0,
      competencies: [
        %{category: "Kubernetes", skills: ["Deployments", "StatefulSets", "Services", "Helm", "Operators"], weight: 0.25},
        %{category: "Service Mesh", skills: ["Istio", "mTLS", "Traffic management", "Observability"], weight: 0.20},
        %{category: "Observability", skills: ["Prometheus", "Grafana", "OpenTelemetry", "Distributed tracing", "Log aggregation"], weight: 0.20},
        %{category: "CI/CD", skills: ["GitHub Actions", "ArgoCD", "GitOps", "Canary deployments"], weight: 0.15},
        %{category: "Infrastructure as Code", skills: ["Terraform", "AWS/GCP", "Security groups", "Cost optimization"], weight: 0.10},
        %{category: "SRE Practices", skills: ["SLO/SLI/SLA", "Incident response", "Postmortems", "Capacity planning"], weight: 0.10}
      ]
    },
    "solutions-architect" => %{
      required_score: 4.5,
      competencies: [
        %{category: "System Design", skills: ["Architecture patterns", "Trade-off analysis", "Scalability", "Resilience"], weight: 0.25},
        %{category: "Technology Evaluation", skills: ["Benchmarking", "TCO analysis", "Risk assessment", "POC execution"], weight: 0.20},
        %{category: "Healthcare Domain", skills: ["Regulatory landscape", "Clinical workflows", "EHR ecosystems", "Interoperability"], weight: 0.20},
        %{category: "Technical Leadership", skills: ["ADRs", "RFC process", "Mentoring", "Cross-team collaboration"], weight: 0.15},
        %{category: "Business Acumen", skills: ["ROI calculation", "Stakeholder communication", "Roadmap planning"], weight: 0.10},
        %{category: "Multi-Stack Expertise", skills: ["Elixir", "WASM", "Databases", "Cloud platforms", "Security"], weight: 0.10}
      ]
    }
  }

  def execute(role_key) do
    case Map.get(@role_competencies, role_key) do
      nil ->
        {:error, "Unknown role: #{role_key}"}

      role_data ->
        assessment = generate_assessment(role_key, role_data)
        {:ok, format_assessment(role_key, assessment)}
    end
  end

  defp generate_assessment(role_key, role_data) do
    %{
      role: role_key,
      required_score: role_data.required_score,
      competencies: role_data.competencies,
      assessment_worksheet: generate_worksheet(role_data.competencies),
      scoring_instructions: scoring_instructions(),
      gap_analysis_template: gap_analysis_template(),
      recommended_resources: get_recommended_resources(role_key)
    }
  end

  defp generate_worksheet(competencies) do
    """
    ## Self-Assessment Worksheet

    **Instructions**: Rate yourself 0-5 for each skill (0=no knowledge, 5=expert).

    #{Enum.map_join(competencies, "\n\n", fn comp ->
      """
      ### #{comp.category} (Weight: #{trunc(comp.weight * 100)}%)
      #{Enum.map_join(comp.skills, "\n", fn skill -> "- [ ] #{skill}: ___/5" end)}
      """
    end)}

    ## Calculate Your Score

    1. Fill in your self-ratings (0-5) for each skill
    2. Calculate category average: (sum of skills) / (number of skills)
    3. Calculate weighted score: Σ(category_average × weight)
    4. Compare to required score

    **Formula**:
    ```
    weighted_score = Σ(category_avg × weight)
    gap = required_score - weighted_score
    ```
    """
  end

  defp scoring_instructions do
    """
    ## Scoring Guide

    **0 - No Knowledge**: Never heard of this concept
    - Action: Start with introductory resources
    - Time to level 3: 2-4 months (depends on prerequisites)

    **1 - Aware**: Read documentation, understand what it does
    - Action: Follow tutorials, build small projects
    - Time to level 3: 1-3 months

    **2 - Beginner**: Can follow tutorials, modify examples
    - Action: Build real features, solve problems independently
    - Time to level 3: 4-8 weeks

    **3 - Intermediate**: Can solve problems independently
    - Action: Optimize solutions, teach others, contribute to OSS
    - Time to level 4: 3-6 months

    **4 - Advanced**: Can optimize, teach, debug complex issues
    - Action: Write authoritative content, mentor, architecture decisions
    - Time to level 5: 6-12 months

    **5 - Expert**: Contribute to core, write RFCs, industry recognition
    - Action: Thought leadership, conference speaking, book writing
    - Maintenance: Continuous learning, mentoring next experts
    """
  end

  defp gap_analysis_template do
    """
    ## Gap Analysis Template

    After completing self-assessment, analyze gaps:

    ### Priority 1: Critical Gaps (score < 2)
    - **Skills**: [list skills with score < 2]
    - **Action**: Intensive learning (bootcamp, courses, mentorship)
    - **Timeline**: 2-4 months before job search
    - **Resources**: See "Recommended Resources" section

    ### Priority 2: Moderate Gaps (score 2-3)
    - **Skills**: [list skills with score 2-3]
    - **Action**: Deliberate practice (side projects, OSS contributions)
    - **Timeline**: 1-3 months concurrent with job search
    - **Resources**: Build real-world projects

    ### Priority 3: Advanced Skills (score 3-4)
    - **Skills**: [list skills with score 3-4]
    - **Action**: Refinement (code reviews, teaching, blogging)
    - **Timeline**: Ongoing after employment
    - **Resources**: Mentorship, conference talks

    ### Strengths (score ≥ 4)
    - **Skills**: [list skills with score ≥ 4]
    - **Leverage**: Highlight in resume/interviews
    - **Action**: Maintain currency, mentor others
    """
  end

  defp get_recommended_resources(role_key) do
    resources = %{
      "full-stack-developer" => [
        "[Elixir Getting Started](https://elixir-lang.org/getting-started/introduction.html) (L0_CANONICAL)",
        "[Phoenix Framework Guides](https://hexdocs.pm/phoenix/overview.html) (L0_CANONICAL)",
        "[Real-Time Phoenix (Book)](https://pragprog.com/titles/sbsockets/real-time-phoenix/) (L2_VALIDATED)",
        "01-ARCHITECTURE/adrs/001-elixir-host-choice.md (internal)",
        "00-META/LEARNING-PATHS.md#f1-full-stack-developer (internal)"
      ],
      "elixir-specialist" => [
        "[Elixir in Action (Book)](https://www.manning.com/books/elixir-in-action-second-edition) (L2_VALIDATED)",
        "[Designing Elixir Systems with OTP (Book)](https://pragprog.com/titles/jgotp/designing-elixir-systems-with-otp/) (L2_VALIDATED)",
        "[The BEAM Book](https://blog.stenmans.org/theBeamBook/) (L2_VALIDATED)",
        "02-ELIXIR-SPECIALIST/otp-patterns/supervision-trees.md (internal)",
        "08-BENCHMARKS-RESEARCH/performance/elixir-throughput-tests.md (internal)"
      ],
      "wasm-specialist" => [
        "[WebAssembly Specification](https://webassembly.github.io/spec/core/) (L0_CANONICAL)",
        "[Extism Documentation](https://extism.org/docs) (L0_CANONICAL)",
        "[Programming WebAssembly with Rust (Book)](https://pragprog.com/titles/khrust/programming-webassembly-with-rust/) (L2_VALIDATED)",
        "03-WASM-SPECIALIST/extism-platform/plugin-development.md (internal)",
        "08-BENCHMARKS-RESEARCH/performance/wasm-overhead-measurements.md (internal)"
      ],
      "security-architect" => [
        "[NIST SP 800-207 - Zero Trust Architecture](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) (L0_CANONICAL)",
        "[NIST PQC Standards](https://csrc.nist.gov/projects/post-quantum-cryptography) (L0_CANONICAL)",
        "[HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html) (L0_CANONICAL)",
        "04-SECURITY-SPECIALIST/zero-trust/nist-sp-800-207.md (internal)",
        "01-ARCHITECTURE/adrs/004-zero-trust-implementation.md (internal)"
      ],
      "healthcare-specialist" => [
        "[FHIR R4 Specification](https://hl7.org/fhir/R4/) (L0_CANONICAL)",
        "[SMART on FHIR](https://docs.smarthealthit.org/) (L0_CANONICAL)",
        "[DICOM Standard](https://www.dicomstandard.org/) (L0_CANONICAL)",
        "05-HEALTHCARE-SPECIALIST/standards/fhir-r4-guide.md (internal)",
        "05-HEALTHCARE-SPECIALIST/compliance/lgpd-hipaa-mapping.md (internal)"
      ],
      "database-engineer" => [
        "[PostgreSQL Performance Tuning (Book)](https://www.oreilly.com/library/view/postgresql-up-and/9781491963401/) (L2_VALIDATED)",
        "[TimescaleDB Documentation](https://docs.timescale.com/) (L0_CANONICAL)",
        "[The Art of PostgreSQL (Book)](https://theartofpostgresql.com/) (L2_VALIDATED)",
        "06-DATABASE-SPECIALIST/postgresql/performance-tuning.md (internal)",
        "01-ARCHITECTURE/adrs/003-database-selection.md (internal)"
      ],
      "devops-sre" => [
        "[Kubernetes Documentation](https://kubernetes.io/docs/) (L0_CANONICAL)",
        "[Istio Documentation](https://istio.io/latest/docs/) (L0_CANONICAL)",
        "[Site Reliability Engineering (Book)](https://sre.google/books/) (L2_VALIDATED)",
        "07-DEVOPS-SRE/kubernetes/healthcare-deployment.md (internal)",
        "07-DEVOPS-SRE/observability/prometheus-grafana.md (internal)"
      ],
      "solutions-architect" => [
        "[Designing Data-Intensive Applications (Book)](https://dataintensive.net/) (L2_VALIDATED)",
        "[Software Architecture: The Hard Parts (Book)](https://www.oreilly.com/library/view/software-architecture-the/9781492086888/) (L2_VALIDATED)",
        "01-ARCHITECTURE/tradeoffs/cost-benefit-analysis.md (internal)",
        "00-META/KNOWLEDGE-GRAPH.md (internal)",
        "All ADRs in 01-ARCHITECTURE/adrs/ (internal)"
      ]
    }

    Map.get(resources, role_key, [])
  end

  defp format_assessment(role_key, assessment) do
    """
    # Skills Assessment: #{String.replace(role_key, "-", " ") |> String.capitalize()}

    **Required Average Score**: #{assessment.required_score}/5.0
    **Assessment Method**: Self-assessment with scoring guide

    ---

    #{assessment.assessment_worksheet}

    ---

    #{assessment.scoring_instructions}

    ---

    #{assessment.gap_analysis_template}

    ---

    ## Recommended Resources

    #{Enum.map_join(assessment.recommended_resources, "\n", fn res -> "- #{res}" end)}

    ---

    ## Next Steps After Assessment

    1. **Calculate your weighted score** using the formula above
    2. **Identify gaps** (focus on skills scoring < 3)
    3. **Create learning plan** (see [LEARNING-PATHS.md](00-META/LEARNING-PATHS.md))
    4. **Track progress** (re-assess quarterly)
    5. **Join community** (Elixir Forum, WASM Discord, Healthcare IT Slack)

    ---

    ## Validation

    **Practice Challenges**: See [SKILL-MATRIX.md](00-META/SKILL-MATRIX.md##{role_key}) for code challenges to validate self-assessment.

    **Interview Preparation**: Typical interview questions for this role are documented in SKILL-MATRIX.md.

    ---

    **DSM Tags**: [L1_DOMAIN:ui_ux | L2_SUBDOMAIN:ai_pipeline | L3_TECHNICAL:guide | L4_SPECIFICITY:example]
    **Last Updated**: 2025-09-30
    """
  end
end
```

---

## Example Usage

**Input**: `/assess-skills elixir-specialist`

**Output**: 30+ page assessment worksheet with:
- 25 skills across 5 categories (Elixir Core, OTP, Phoenix, BEAM VM, Performance)
- Self-rating worksheet (0-5 scale per skill)
- Weighted scoring formula
- Gap analysis template
- 5+ recommended resources with validation levels
- Code challenges to validate ratings

---

**DSM Tags**: [L1_DOMAIN:ui_ux | L2_SUBDOMAIN:ai_pipeline | L3_TECHNICAL:guide | L4_SPECIFICITY:reference]
**Validation Level**: L0_CANONICAL (internal command)
**Last Updated**: 2025-09-30