# Testing Strategies: Testes Unitários e E2E com Popcorn

## 🎯 Visão Geral da Estratégia de Testes

### Pirâmide de Testes para Popcorn
```
        /\
       /E2E\      (10%) - Testes browser completos
      /------\
     /Integr. \   (30%) - Testes de integração
    /----------\
   / Unitários  \ (60%) - Testes unitários Elixir
  /--------------\
```

### Princípios Fundamentais
1. **Código compartilhado**: Teste uma vez, funciona em ambos lados
2. **Isolamento**: Teste Popcorn separado do Phoenix
3. **Fast feedback**: Testes rápidos primeiro
4. **Real browser**: Validação final em browser real

---

## 🧪 Nível 1: Testes Unitários

### Testando Código Compartilhado

#### test/shared/calculator_test.exs
```elixir
defmodule MyApp.Shared.CalculatorTest do
  use ExUnit.Case, async: true
  alias MyApp.Shared.Calculator

  describe "operações básicas" do
    test "soma dois números" do
      assert Calculator.add(2, 3) == 5
    end

    test "soma com números negativos" do
      assert Calculator.add(-5, 3) == -2
    end

    test "divisão por zero retorna erro" do
      assert {:error, :division_by_zero} = Calculator.divide(10, 0)
    end
  end

  describe "operações complexas" do
    test "calcula porcentagem" do
      assert Calculator.percentage(50, 200) == 25.0
    end

    test "calcula média de lista" do
      assert Calculator.average([10, 20, 30]) == 20.0
    end

    test "média de lista vazia retorna zero" do
      assert Calculator.average([]) == 0
    end
  end
end
```

### Testando Módulos Específicos do Popcorn

#### test/wasm/validator_test.exs
```elixir
defmodule MyAppWasm.ValidatorTest do
  use ExUnit.Case, async: true
  alias MyAppWasm.Validator

  # Tag para identificar testes que rodam no Popcorn
  @moduletag :popcorn

  describe "validação de email" do
    test "aceita email válido" do
      assert {:ok, _} = Validator.validate_email("user@example.com")
    end

    test "rejeita email sem @" do
      assert {:error, "Email inválido"} = Validator.validate_email("userexample.com")
    end

    test "rejeita email com espaços" do
      assert {:error, "Email inválido"} = Validator.validate_email("user @example.com")
    end
  end

  describe "validação de CPF" do
    test "aceita CPF válido" do
      assert {:ok, "12345678901"} = Validator.validate_cpf("123.456.789-01")
    end

    test "remove formatação" do
      {:ok, cpf} = Validator.validate_cpf("123.456.789-01")
      assert cpf == "12345678901"
    end

    test "rejeita CPF com dígitos repetidos" do
      assert {:error, _} = Validator.validate_cpf("111.111.111-11")
    end
  end
end
```

### Property-Based Testing

#### test/wasm/property_test.exs
```elixir
defmodule MyAppWasm.PropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  alias MyAppWasm.Calculator

  property "soma é comutativa" do
    check all a <- integer(),
              b <- integer() do
      assert Calculator.add(a, b) == Calculator.add(b, a)
    end
  end

  property "soma é associativa" do
    check all a <- integer(),
              b <- integer(),
              c <- integer() do
      assert Calculator.add(Calculator.add(a, b), c) == 
             Calculator.add(a, Calculator.add(b, c))
    end
  end

  property "divisão seguida de multiplicação retorna original" do
    check all a <- integer(),
              b <- integer(),
              b != 0 do
      {:ok, divided} = Calculator.divide(a, b)
      result = Calculator.multiply(divided, b)
      assert_in_delta result, a, 0.01
    end
  end
end
```

---

## 🔗 Nível 2: Testes de Integração

### Testando Compilação para WASM

#### test/integration/popcorn_compilation_test.exs
```elixir
defmodule Integration.PopcornCompilationTest do
  use ExUnit.Case

  @tag :integration
  test "compila módulos para WASM com sucesso" do
    # Limpar builds anteriores
    File.rm_rf!("priv/static/wasm")
    
    # Executar compilação
    {output, 0} = System.cmd("mix", ["popcorn.cook"])
    
    # Verificar saída
    assert output =~ "Compilation successful"
    
    # Verificar arquivos gerados
    assert File.exists?("priv/static/wasm/calculator.beam")
    assert File.exists?("priv/static/wasm/validator.beam")
  end

  @tag :integration
  test "bundle não excede tamanho máximo" do
    # Compilar se necessário
    System.cmd("mix", ["popcorn.cook"], [])
    
    # Verificar tamanho total
    wasm_size = get_directory_size("priv/static/wasm")
    max_size = 3 * 1024 * 1024  # 3MB
    
    assert wasm_size < max_size, 
      "Bundle size #{wasm_size} bytes excede máximo de #{max_size} bytes"
  end

  defp get_directory_size(path) do
    Path.wildcard("#{path}/**/*")
    |> Enum.map(&File.stat!/1)
    |> Enum.map(& &1.size)
    |> Enum.sum()
  end
end
```

### Testando Interoperabilidade JS

#### test/integration/js_interop_test.exs
```elixir
defmodule Integration.JsInteropTest do
  use ExUnit.Case
  
  @tag :integration
  @tag :requires_node
  test "módulo Popcorn pode chamar JavaScript" do
    # Criar arquivo JS temporário
    js_code = """
    global.testFunction = function(a, b) {
      return a + b;
    };
    """
    File.write!("test/fixtures/test.js", js_code)
    
    # Testar integração
    result = MyAppWasm.JsInterop.call_js("testFunction", [5, 3])
    assert result == 8
    
    # Limpar
    File.rm!("test/fixtures/test.js")
  end
end
```

### Testando com Phoenix

#### test/integration/phoenix_popcorn_test.exs
```elixir
defmodule Integration.PhoenixPopcornTest do
  use MyAppWeb.ConnCase
  
  @tag :integration
  test "serve arquivos WASM com headers corretos", %{conn: conn} do
    conn = get(conn, "/wasm/calculator.wasm")
    
    assert response_content_type(conn, :wasm)
    assert get_resp_header(conn, "cross-origin-embedder-policy") == ["require-corp"]
    assert get_resp_header(conn, "cross-origin-opener-policy") == ["same-origin"]
  end

  @tag :integration
  test "LiveView carrega módulo Popcorn", %{conn: conn} do
    {:ok, view, html} = live(conn, "/calculator")
    
    # Verificar que script está presente
    assert html =~ "PopcornLoader"
    assert html =~ "calculator.wasm"
    
    # Simular evento após carregamento
    assert render_click(view, "calculate", %{a: 10, b: 20}) =~ "30"
  end
end
```

---

## 🌐 Nível 3: Testes End-to-End

### Setup Wallaby para E2E

#### config/test.exs
```elixir
config :wallaby,
  driver: Wallaby.Chrome,
  chrome: [
    headless: false,  # true para CI
    args: [
      "--no-sandbox",
      "--disable-dev-shm-usage",
      "--disable-web-security",  # Para SharedArrayBuffer
      "--allow-file-access-from-files"
    ]
  ],
  screenshot_on_failure: true,
  max_wait_time: 10_000
```

### Teste E2E Básico

#### test/e2e/calculator_e2e_test.exs
```elixir
defmodule E2E.CalculatorTest do
  use ExUnit.Case
  use Wallaby.Feature

  import Wallaby.Query

  @tag :e2e
  feature "calculadora funciona no browser", %{session: session} do
    session
    |> visit("/calculator")
    |> assert_has(css(".calculator"))
    |> wait_for_popcorn_load()
    |> fill_in(text_field("input-a"), with: "10")
    |> fill_in(text_field("input-b"), with: "20")
    |> click(button("Calculate"))
    |> assert_has(css(".result", text: "30"))
  end

  @tag :e2e
  feature "validação acontece no cliente", %{session: session} do
    session
    |> visit("/form")
    |> wait_for_popcorn_load()
    |> fill_in(text_field("email"), with: "invalid-email")
    |> send_keys([:tab])  # Trigger blur
    |> assert_has(css(".error", text: "Email inválido"))
    |> refute_has(css(".server-call"))  # Não deve chamar servidor
  end

  defp wait_for_popcorn_load(session) do
    # Esperar Popcorn carregar
    session
    |> execute_script("return window.popcornReady")
    |> retry_until(fn ready -> ready == true end)
    
    session
  end

  defp retry_until(session, check_fn, max_attempts \\ 10) do
    Enum.reduce_while(1..max_attempts, session, fn _, acc ->
      if check_fn.(acc) do
        {:halt, acc}
      else
        Process.sleep(500)
        {:cont, acc}
      end
    end)
  end
end
```

### Teste E2E Offline

#### test/e2e/offline_e2e_test.exs
```elixir
defmodule E2E.OfflineTest do
  use ExUnit.Case
  use Wallaby.Feature

  @tag :e2e
  @tag :offline
  feature "app funciona offline", %{session: session} do
    session
    |> visit("/todo")
    |> wait_for_popcorn_load()
    |> go_offline()
    |> add_todo("Comprar leite")
    |> assert_has(css(".todo-item", text: "Comprar leite"))
    |> assert_has(css(".status", text: "Offline"))
    |> go_online()
    |> assert_has(css(".status", text: "Online"))
    |> assert_has(css(".sync-status", text: "Sincronizado"))
  end

  defp go_offline(session) do
    execute_script(session, """
      window.dispatchEvent(new Event('offline'));
      return true;
    """)
    session
  end

  defp go_online(session) do
    execute_script(session, """
      window.dispatchEvent(new Event('online'));
      return true;
    """)
    session
  end

  defp add_todo(session, text) do
    session
    |> fill_in(text_field("new-todo"), with: text)
    |> send_keys([:enter])
  end
end
```

---

## 🎭 Mocking e Stubs

### Mock de Módulos Popcorn

#### test/support/mocks.ex
```elixir
Mox.defmock(MyAppWasm.CalculatorMock, for: MyAppWasm.CalculatorBehaviour)
Mox.defmock(MyAppWasm.ValidatorMock, for: MyAppWasm.ValidatorBehaviour)
```

#### test/unit/with_mocks_test.exs
```elixir
defmodule MyApp.WithMocksTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  test "usa calculator mock" do
    MyAppWasm.CalculatorMock
    |> expect(:add, fn 2, 3 -> 5 end)
    |> expect(:multiply, fn 5, 10 -> 50 end)

    assert MyAppWasm.CalculatorMock.add(2, 3) == 5
    assert MyAppWasm.CalculatorMock.multiply(5, 10) == 50
  end
end
```

### Stub de JavaScript

#### test/support/js_stub.js
```javascript
// Stub para testes sem browser real
window.PopcornLoader = {
  init: async () => true,
  ready: true,
  runElixir: async (module, func, args) => {
    // Retorna respostas fake baseadas em input
    if (module === 'Calculator' && func === 'add') {
      return args[0] + args[1];
    }
    return null;
  }
};
```

---

## 📊 Testes de Performance

### Benchmark de Funções

#### test/performance/benchmark_test.exs
```elixir
defmodule Performance.BenchmarkTest do
  use ExUnit.Case

  @tag :benchmark
  test "performance de cálculos" do
    inputs = %{
      "pequeno" => Enum.to_list(1..100),
      "médio" => Enum.to_list(1..1_000),
      "grande" => Enum.to_list(1..10_000)
    }

    results = Benchee.run(
      %{
        "soma_simples" => fn list -> 
          MyAppWasm.Calculator.sum_list(list)
        end,
        "soma_paralela" => fn list ->
          MyAppWasm.Calculator.parallel_sum(list)
        end
      },
      inputs: inputs,
      time: 10,
      memory_time: 2
    )

    # Verificar que paralela é mais rápida para listas grandes
    assert results.scenarios
           |> Enum.find(&(&1.name == "soma_paralela"))
           |> Map.get(:run_time_data)
           |> Map.get(:statistics)
           |> Map.get(:median) < 1_000_000  # < 1ms
  end
end
```

### Teste de Carga

#### test/performance/load_test.exs
```elixir
defmodule Performance.LoadTest do
  use ExUnit.Case

  @tag :load
  @tag timeout: :infinity
  test "suporta múltiplas instâncias Popcorn" do
    tasks = for i <- 1..100 do
      Task.async(fn ->
        # Simular múltiplos usuários
        start_time = System.monotonic_time(:millisecond)
        
        result = MyAppWasm.Calculator.complex_calculation(i)
        
        end_time = System.monotonic_time(:millisecond)
        {i, result, end_time - start_time}
      end)
    end

    results = Task.await_many(tasks, 30_000)
    
    # Verificar que todos completaram
    assert length(results) == 100
    
    # Verificar tempo médio
    avg_time = results
               |> Enum.map(fn {_, _, time} -> time end)
               |> Enum.sum()
               |> Kernel./(100)
    
    assert avg_time < 100  # < 100ms médio
  end
end
```

---

## 🔄 Testes de Regressão

### Snapshot Testing

#### test/regression/snapshot_test.exs
```elixir
defmodule Regression.SnapshotTest do
  use ExUnit.Case

  @tag :regression
  test "output não mudou" do
    input = %{
      items: [
        %{name: "Item 1", price: 10.50, quantity: 2},
        %{name: "Item 2", price: 25.00, quantity: 1}
      ],
      tax_rate: 0.08,
      discount: 5.00
    }

    result = MyAppWasm.OrderCalculator.calculate_total(input)
    
    # Comparar com snapshot salvo
    expected = File.read!("test/fixtures/snapshots/order_calc.json")
                |> Jason.decode!()
    
    assert result == expected
  end

  @tag :regression
  @tag :update_snapshot
  test "atualizar snapshot" do
    # Rodar com --only update_snapshot para atualizar
    input = %{
      items: [
        %{name: "Item 1", price: 10.50, quantity: 2},
        %{name: "Item 2", price: 25.00, quantity: 1}
      ],
      tax_rate: 0.08,
      discount: 5.00
    }

    result = MyAppWasm.OrderCalculator.calculate_total(input)
    
    File.write!(
      "test/fixtures/snapshots/order_calc.json",
      Jason.encode!(result, pretty: true)
    )
  end
end
```

---

## 🚀 CI/CD Pipeline para Testes

### .github/workflows/test.yml
```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '26.0.2'
      
      - name: Install deps
        run: mix deps.get
      
      - name: Run unit tests
        run: mix test --only unit

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '26.0.2'
      
      - name: Build Popcorn
        run: |
          mix deps.get
          mix popcorn.cook
      
      - name: Run integration tests
        run: mix test --only integration

  e2e-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Chrome
        uses: browser-actions/setup-chrome@latest
      
      - name: Setup ChromeDriver
        uses: nanasess/setup-chromedriver@v2
      
      - name: Setup Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.17.3'
          otp-version: '26.0.2'
      
      - name: Install deps
        run: |
          mix deps.get
          npm install --prefix assets
      
      - name: Setup database
        run: |
          mix ecto.create
          mix ecto.migrate
      
      - name: Build assets
        run: |
          mix assets.deploy
          mix popcorn.cook
      
      - name: Run E2E tests
        run: mix test --only e2e
        env:
          MIX_ENV: test
          WALLABY_DRIVER: chrome_headless
```

---

## 📋 Checklist de Testes

### Para cada Feature Nova
- [ ] Testes unitários para lógica pura
- [ ] Testes de integração para compilação
- [ ] Teste E2E básico
- [ ] Teste de performance
- [ ] Teste offline (se aplicável)
- [ ] Snapshot test
- [ ] Documentação de teste

### Coverage Mínimo
- [ ] Unit: 90%+
- [ ] Integration: 70%+
- [ ] E2E: Casos críticos
- [ ] Total: 80%+

### Comandos Úteis
```bash
# Rodar todos os testes
mix test

# Apenas unitários
mix test --only unit

# Apenas E2E
mix test --only e2e

# Com coverage
mix test --cover

# Testes de performance
mix test --only benchmark

# Watch mode
mix test.watch

# Testes específicos do Popcorn
mix test --only popcorn
```

---

## 🎯 Best Practices

1. **Teste comportamento, não implementação**
2. **Use tags para organizar suites**
3. **Mantenha testes rápidos (<100ms para unit)**
4. **E2E apenas para fluxos críticos**
5. **Mock external dependencies**
6. **Não teste o framework, teste seu código**
7. **Cleanup após cada teste**
8. **Use factories para dados de teste**
