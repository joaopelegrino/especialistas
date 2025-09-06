# Plano: Completar Estrutura .claude para Blog WebAssembly-First

**Data**: 2025-01-09  
**Objetivo**: Alinhar estrutura atual `.claude/blog` com estrutura esperada pelo usuário

## 📊 Análise Estado Atual vs Esperado

### ✅ Estrutura Atual (Parcialmente Implementada)
```
/home/notebook/workspace/blog/.claude/
├── commands/           ✅ EXISTE (8 arquivos)
├── core/              ✅ EXISTE (orchestrator + artifacts)
├── hooks/             ✅ EXISTE (pre_mix_command.py)
├── config/            ✅ EXISTE (configuracoes.json criado)
├── docs/              ✅ EXISTE
├── screenshots/       ✅ EXISTE
├── logs/              ✅ EXISTE
├── tools/             ✅ EXISTE
├── metricas/          ✅ EXISTE
├── bin/               ✅ EXISTE
├── CLAUDE.md          ✅ EXISTE (recém criado)
└── diagnostico-fluxo-trabalho.md ✅ EXISTE
```

### ❌ Estrutura Esperada (Missing Components)
```
├── bin/
│   ├── claude-pwdct              ❌ MISSING
│   └── claude-shell-commands     ❌ MISSING
├── core/
│   ├── projeto-bm-agents-config.json      ❌ MISSING
│   ├── projeto-bm-test-suite.sh          ❌ MISSING  
│   └── projeto-bm-visual-debug-integration.js ❌ MISSING
├── mcp-config.json                        ❌ MISSING
├── mcp-servers.json                       ❌ MISSING
├── projeto-bm-agents-config.json          ❌ MISSING
├── projeto-bm-auth-test.js                ❌ MISSING
├── projeto-bm-network-debug.js            ❌ MISSING
├── settings.local.json                    ❌ MISSING
└── validate-mcp.sh                        ❌ MISSING
```

## 🎯 Estratégia de Implementação

### Fase 1: Componentes Críticos (30min)
1. **Scripts Executáveis** (`bin/`)
2. **Configurações MCP** (mcp-config.json, mcp-servers.json)  
3. **Validação MCP** (validate-mcp.sh)

### Fase 2: Projeto-BM Específicos (45min)
1. **Auth Testing** (projeto-bm-auth-test.js)
2. **Network Debug** (projeto-bm-network-debug.js)
3. **Test Suite** (projeto-bm-test-suite.sh)

### Fase 3: Configurações Avançadas (30min)
1. **Agent Config** (projeto-bm-agents-config.json)
2. **Visual Debug** (projeto-bm-visual-debug-integration.js)
3. **Settings Local** (settings.local.json)

## 🔧 Implementação Detalhada

### Bin Scripts
- `claude-pwdct`: Password/Credential management tool
- `claude-shell-commands`: Shell command shortcuts for project

### MCP Configuration  
- `mcp-config.json`: Model Context Protocol configuration
- `mcp-servers.json`: MCP servers registry
- `validate-mcp.sh`: MCP setup validation script

### Projeto-BM Tools
- `projeto-bm-auth-test.js`: Authentication system testing
- `projeto-bm-network-debug.js`: Network debugging utilities
- `projeto-bm-test-suite.sh`: Comprehensive test runner
- `projeto-bm-agents-config.json`: Multi-agent configuration

### Setup Integration
- Integrar comando setup no CLAUDE.md: `### 🔥 Setup Completo`
- Incluir ativação ambiente Elixir obrigatória
- Referenciar GUIA-TESTES-USUARIO.md

## 🚀 Benefícios Esperados

1. **Alinhamento**: Estrutura esperada pelo usuário 100% implementada
2. **Automação**: Tools completos para desenvolvimento Projeto-BM
3. **Debugging**: Ferramentas debug network/auth integradas
4. **Testing**: Suite testes abrangente
5. **MCP**: Suporte completo Model Context Protocol

## ✅ Critérios de Sucesso

- [ ] Estrutura .claude 100% alinhada com esperada
- [ ] Scripts executáveis funcionais  
- [ ] MCP configuration válida
- [ ] Projeto-BM tools operacionais
- [ ] Setup command integrado ao CLAUDE.md
- [ ] Validação completa via validate scripts

## 📋 Próximos Passos

1. Implementar componentes missing por ordem de prioridade
2. Testar cada ferramenta individualmente  
3. Integrar ao workflow principal
4. Atualizar CLAUDE.md com setup completo
5. Validar estrutura final vs esperada