# Universal Codebase Diagnostics System

Sistema universal para diagnóstico forense de código, adaptável a qualquer stack tecnológica.

## 🎯 Visão Geral

Este sistema implementa uma metodologia robusta e automatizada para análise de qualquer codebase, aplicando princípios de zero-trust e validação empírica em todas as descobertas.

### Características Principais

✅ **Universal & Agnóstico**: Funciona com qualquer linguagem/framework
✅ **Auto-Detecção**: Identifica automaticamente stack, arquitetura e padrões
✅ **Zero-Trust**: Valida empiricamente todas as afirmações sobre funcionalidades
✅ **Hooks Adaptativos**: Se ajusta automaticamente ao stack detectado
✅ **Metodologia Rigorosa**: Baseada em evidências, não em documentação

## 📁 Estrutura do Sistema

```
diagnosticos-code-base/
├── .claude/
│   ├── settings.json           # Configurações universais
│   ├── bin/                    # Scripts de discovery
│   │   ├── detect-stack        # Detecção de stack
│   │   ├── deps-scan          # Análise de dependências
│   │   └── full-discovery     # Pipeline completa
│   └── hooks/                 # Hooks adaptativos
│       ├── pre-analysis-adapter.py    # Auto-detecção e contexto
│       └── validation-protocol.py     # Protocolo de verificação
├── CLAUDE.md                  # Metodologia universal
└── README.md                  # Este arquivo
```

## 🚀 Como Usar

### Diagnóstico Rápido

```bash
# Executar discovery completa em qualquer projeto
cd /path/to/your/project
/path/to/diagnosticos-code-base/.claude/bin/full-discovery
```

### Comandos Individuais

```bash
# Detecção de stack tecnológica
detect-stack /path/to/project

# Análise de dependências
deps-scan /path/to/project

# Validação de claims funcionais
validate-claims /path/to/project
```

### Usando via Claude Code

1. **Copie as configurações para seu projeto:**
   ```bash
   cp -r diagnosticos-code-base/.claude /path/to/your/project/
   ```

2. **O sistema se ativará automaticamente** quando você mencionar "diagnóstico", "diagnostic" ou "analysis"

3. **Hooks adaptativos** executarão automaticamente:
   - Pre-analysis: Detecta stack e configura contexto
   - Post-tool: Lembra de aplicar protocolo de verificação

## 🔍 Metodologia

### Fase 1: Auto-Detecção (5-10 min)
- **Stack Discovery**: Identifica linguagens, frameworks, arquitetura
- **Project Classification**: Web app, API, library, CLI, etc.
- **Baseline Metrics**: LOC, complexidade, dependências

### Fase 2: Análise Profunda (15-30 min)
- **Security Scan**: OWASP Top 10 + vulnerabilidades específicas da stack
- **Quality Analysis**: Duplicação, complexidade, debt técnico
- **Architecture Review**: Padrões vs anti-patterns

### Fase 3: Verificação & Relatório (10-15 min)
- **Protocolo Zero-Trust**: Valida CADA claim contra código real
- **Evidence Matrix**: Constrói matriz de confiabilidade
- **Action Plan**: Gera plano priorizado P0-P3

## 🛡️ Protocolo de Verificação Zero-Trust

### Matriz de Confiabilidade

| Fonte | Confiança | Ação Requerida |
|-------|-----------|----------------|
| README/Docs | 0% | Verificar 100% |
| Comentários | 10% | Validar com código |
| Commits msgs | 20% | Confirmar implementação |
| Código | 60% | Testar execução |
| Testes passando | 80% | Validar cobertura |
| Execução verificada | 100% | Confirmado |

### Red Flags Automáticos

- "Fully implemented" sem testes
- "Working" sem evidência de uso
- "Complete" com TODOs no código
- Percentuais redondos sem dados
- Features sem endpoints/UI correspondentes

## 📊 Stack Suportadas

### Linguagens Detectadas Automaticamente
- **JavaScript/TypeScript**: React, Vue, Angular, Express, Next.js
- **Python**: Django, Flask, FastAPI, Tornado
- **Elixir**: Phoenix, GenServer patterns
- **Ruby**: Rails, Sinatra
- **Go**: Gin, Echo, Fiber
- **Rust**: Axum, Actix-web, Warp
- **Java**: Spring, Maven/Gradle
- **PHP**: Laravel, Symfony
- **C/C++**, **C#**: Estruturas básicas

### Vulnerabilidades Stack-Específicas

- **JavaScript**: Prototype pollution, ReDoS, npm audit
- **Python**: Pickle deserialization, secret keys
- **Elixir**: Atom exhaustion, unsafe deserialization
- **Go**: Race conditions, goroutine leaks
- **Rust**: Unsafe blocks audit
- **Java**: Deserialization, Log4Shell-type

## 📈 Relatório Gerado

### Seções do Diagnóstico

1. **Profile do Projeto** - Stack, métricas, contexto
2. **Resumo Executivo** - Health score, top 3 riscos
3. **Descobertas por Categoria** - Evidências específicas
4. **Matriz de Débito Técnico** - Impacto e custo por dimensão
5. **Análise de Viabilidade** - ROI, refactor vs rewrite
6. **Plano de Ação Priorizado** - P0-P3 com timeline
7. **Roadmap de Remediação** - Modernização da stack

### Métricas Automáticas

- **Health Score**: 0-100 com tendência
- **Stack Compliance**: Vs padrões da comunidade
- **Security Score**: Vulnerabilidades por categoria
- **Technical Debt**: Quantificado em horas
- **Quality Gates**: Specific para stack

## ⚙️ Configuração Avançada

### Customizar para Novo Stack

1. **Edite `detect-stack`** - Adicione patterns de detecção
2. **Atualize `CLAUDE.md`** - Inclua vulnerabilidades específicas
3. **Configure hooks** - Adapte validações para o ecosystem

### Hooks Personalizados

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": {"message": ".*custom-trigger.*"},
      "hooks": [{
        "type": "command",
        "command": ["your-custom-script.py"]
      }]
    }]
  }
}
```

## 🎯 Casos de Uso

### Para Arquitetos
- **Due diligence** técnica em aquisições
- **Health checks** periódicos de sistemas
- **Migration planning** para modernização

### Para Desenvolvedores
- **Code review** automatizado e sistemático
- **Technical debt** quantificação e priorização
- **Security audit** pré-deployment

### Para CTOs/Lideranças
- **ROI analysis** de refatorações
- **Risk assessment** de stacks legadas
- **Investment planning** em modernização

## 📝 Exemplo de Uso Real

```bash
# Análise do projeto blog (Elixir/Phoenix + JS)
cd /workspace/blog
full-discovery

# Resultado automático:
# ✅ Stack: Elixir + Phoenix + JavaScript
# ⚠️  34 TODOs, 96 WARNs identificados
# 🔒 Potenciais secrets em 4 arquivos
# 📊 Health Score: 72/100
# 🎯 P0: Resolver exposição de secrets (2h)
# 🎯 P1: Atualizar dependências outdated (4h)
# 🎯 P2: Reduzir duplicação de código (8h)
```

## 🤝 Contribuindo

1. **Adicione novos stacks** em `detect-stack`
2. **Melhore padrões** de vulnerabilidade por linguagem
3. **Expanda hooks** adaptativos para novos frameworks
4. **Reporte bugs** e casos edge descobertos

## 📄 License

Sistema interno para diagnósticos de codebase. Distribuição sob aprovação da organização.

---

**💡 Lembre-se**: Este sistema aplica zero-trust em documentação. Toda afirmação sobre funcionalidade deve ser validada empiricamente contra o código real.