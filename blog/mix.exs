defmodule HealthcareCMS.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :healthcare_cms,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      # DSM:HEALTHCARE:platform_initialization COMPLIANCE:LGPD_ready
      # DSM:PERFORMANCE:response_time:<50ms concurrency:2M+
      # DSM:SECURITY:zero_trust_architecture post_quantum_ready
      releases: releases()
    ]
  end

  def application do
    [
      mod: {HealthcareCMS.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :crypto]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix Framework - Latest stable (BOM spec)
      {:phoenix, "~> 1.8.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:plug_cowboy, "~> 2.7"},

      # Database - SQLite para desenvolvimento, PostgreSQL em produção
      {:ecto_sql, "~> 3.12"},
      {:ecto_sqlite3, "~> 0.12", only: [:dev, :test]},
      {:postgrex, "~> 0.19", only: :prod},

      # WebAssembly Runtime para medical plugins (temporariamente desabilitado - requer Rust)
      # {:extism, "~> 1.0.0"},

      # Zero Trust e Security + Post-Quantum Crypto
      {:guardian, "~> 2.3"},
      {:guardian_phoenix, "~> 2.0"},
      {:argon2_elixir, "~> 3.0"},
      # {:ex_oqs, "~> 0.3.0"}, # Post-Quantum Cryptography (adicionar quando disponível)

      # JSON e serialização
      {:jason, "~> 1.4"},

      # HTTP client para medical APIs
      {:httpoison, "~> 2.0"},
      {:req, "~> 0.4"}, # Modern HTTP client

      # Real-time e PubSub
      {:phoenix_pubsub, "~> 2.1"},

      # Monitoring e observability healthcare
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:prometheus_ex, "~> 3.0"},

      # Healthcare-specific
      {:timex, "~> 3.7"}, # DateTime handling
      {:decimal, "~> 2.0"}, # Precision arithmetic for medical calculations

      # Development e testing
      {:floki, "~> 0.34", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.12", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.2", only: :test},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],

      # Healthcare-specific commands (DSM:HEALTHCARE:compliance_automation)
      "healthcare.check_compliance": ["test --only compliance"],
      "healthcare.security_scan": ["sobelow --config .sobelow-conf"],
      "healthcare.performance_test": ["test --only performance"],
      "healthcare.lgpd_scan": ["test --only lgpd"],
      "healthcare.wasm_test": ["test --only wasm"],

      # Zero Trust validation
      "security.zero_trust_validate": ["test --only zero_trust"],
      "security.pqc_test": ["test --only post_quantum"],

      # Development quality
      "quality.check": ["format --check-formatted", "credo --strict", "dialyzer"],
      "quality.fix": ["format", "credo --strict --fix"],

      # CI/CD commands
      "ci.full_check": ["deps.get", "compile --warnings-as-errors", "quality.check", "test", "healthcare.security_scan"]
    ]
  end

  defp releases do
    [
      healthcare_cms: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent],
        steps: [:assemble, :tar]
      ]
    ]
  end
end