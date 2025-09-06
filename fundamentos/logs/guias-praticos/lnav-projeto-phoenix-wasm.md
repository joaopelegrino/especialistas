# 🚀 lnav + Phoenix WebAssembly - Guia de Integração Específica

## 📋 Visão Geral
- **Objetivo:** Integrar lnav ao projeto blog Phoenix+WASM para análise eficiente de logs
- **Tempo estimado:** 30-40 minutos
- **Pré-requisitos:** lnav instalado, projeto Phoenix rodando
- **Resultado final:** Monitoramento completo multi-stack (Elixir + WASM + Claude Hooks)

## 🔍 Contexto Educativo

### Por que este projeto é único para logs?
Seu projeto **blog Phoenix+WASM** gera logs de múltiplas camadas:
- **Phoenix Server** - HTTP requests, controllers, LiveView
- **AtomVM/WASM** - Runtime WebAssembly, compilação
- **Claude Hooks** - Sistema de integração customizado
- **Erlang/OTP** - Crash dumps, processos, supervisors

### Desafios específicos:
- **Correlação temporal** entre backend e WASM
- **Formato JSON** nos hooks vs syslog Phoenix
- **Performance WASM** vs logs tradicionais
- **Debug multiplataforma** (server + browser)

## 📊 Antes de Começar - Análise do Ambiente

### Checklist de Pré-requisitos:
- [ ] Projeto Phoenix rodando (mix phx.server)
- [ ] lnav instalado e funcional
- [ ] Permissões de leitura nos diretórios do projeto
- [ ] AtomVM/WASM compilado (_build/wasm/)

### Comandos de Diagnóstico:
```bash
# cd /home/notebook/workspace/blog
# 📖 Explicação: Navega para diretório do projeto blog
# ✅ Necessário: todos comandos assumem esta localização
cd /home/notebook/workspace/blog

# find . -name "*.log" -o -name "erl_crash.dump" 2>/dev/null
# 📖 Explicação: Localiza todos arquivos de log no projeto
# 🔧 Parâmetros:
#    -name "*.log": arquivos terminados em .log
#    -o: operador OR (ou)
#    -name "erl_crash.dump": crash dumps do Erlang
#    2>/dev/null: suprime erros de permissão
# 📚 Man page: man 1 find
# 💡 Resultado esperado: ./.claude/logs/bridge.log, ./erl_crash.dump
find . -name "*.log" -o -name "erl_crash.dump" 2>/dev/null

# mix phx.server --no-deps-check > /tmp/phoenix.log 2>&1 &
# 📖 Explicação: Inicia Phoenix redirecionando logs para arquivo
# 🔧 Parâmetros:
#    --no-deps-check: pula verificação de dependências (mais rápido)
#    > /tmp/phoenix.log: redireciona stdout para arquivo
#    2>&1: redireciona stderr para stdout (mesmo arquivo)
#    &: executa em background
# 📚 Man page: man 1 bash (redirection)
# ⚠️ Parar: kill %1 ou pkill -f "mix phx.server"
mix phx.server --no-deps-check > /tmp/phoenix.log 2>&1 &
```

## 🚀 Passo a Passo Detalhado

### Etapa 1: Análise dos Logs Existentes

**Importante:** Este guia analisa o projeto **sem modificar arquivos**, apenas usando lnav para monitorar logs existentes.

#### Logs identificados no projeto:
```bash
# ls -la .claude/logs/
# 📖 Explicação: Lista logs do sistema Claude hooks
# 📁 Localização: .claude/logs/bridge.log (JSON estruturado)
# 💡 Conteúdo: Conexões HTTP, hooks, sessões Claude
# ⚠️ Formato: JSON com timestamp UTC
ls -la .claude/logs/

# file erl_crash.dump
# 📖 Explicação: Identifica tipo e conteúdo do crash dump
# 🔧 Comando: file detecta formato de arquivos
# 📚 Man page: man 1 file
# 💡 Output: "Erlang crash dump" + versão + timestamp
# 🔍 Análise: mostra se houve crashes recentes da VM
file erl_crash.dump
```

### Etapa 2: Monitoramento com lnav - Logs Claude Hooks

#### Visualizar logs JSON do Claude:
```bash
# lnav .claude/logs/bridge.log
# 📖 Explicação: Abre logs JSON do sistema Claude hooks
# 🎯 Funcionalidades:
#    - Parsing automático de JSON
#    - Highlighting de níveis (DEBUG, INFO, ERROR)
#    - Busca por sessão_id ou mensagem
# 🎮 Teclas úteis:
#    /sessao_id - buscar por sessão específica
#    :filter-in HTTP - filtrar apenas logs de HTTP
#    :filter-in ERROR - mostrar apenas erros
lnav .claude/logs/bridge.log
```

#### Análise SQL nos logs Claude:
```sql
-- Dentro do lnav (pressione ; para SQL)
-- Contar eventos por nível
SELECT json_extract(log_body, '$.nivel') as level, 
       count(*) as count
FROM all_logs 
WHERE log_body LIKE '%nivel%'
GROUP BY level 
ORDER BY count DESC;

-- Últimos 10 erros de conexão
SELECT datetime(json_extract(log_body, '$.timestamp')) as time,
       json_extract(log_body, '$.mensagem') as message
FROM all_logs 
WHERE log_body LIKE '%Connection refused%'
ORDER BY time DESC 
LIMIT 10;

-- Análise de sessões Claude
SELECT json_extract(log_body, '$.sessao_id') as session,
       count(*) as events,
       min(datetime(json_extract(log_body, '$.timestamp'))) as start_time,
       max(datetime(json_extract(log_body, '$.timestamp'))) as end_time
FROM all_logs 
WHERE log_body LIKE '%sessao_id%'
GROUP BY session 
ORDER BY events DESC;
```

### Etapa 3: Monitoramento Phoenix em Tempo Real

#### Capturar logs Phoenix com lnav:
```bash
# mix phx.server 2>&1 | lnav
# 📖 Explicação: Inicia Phoenix e envia logs diretamente para lnav
# 🔧 Redirecionamento:
#    2>&1: combina stderr com stdout
#    | (pipe): envia output para lnav
# 🎯 Vantagem: análise em tempo real
# ⚠️ Limitação: não persiste logs em arquivo
mix phx.server 2>&1 | lnav

# Alternativa com persistência:
# script -c "mix phx.server" /tmp/phoenix-session.log && lnav /tmp/phoenix-session.log
# 📖 Explicação: Grava sessão completa e depois analisa
# 🔧 Comando:
#    script: grava sessão terminal em arquivo
#    -c: executa comando específico
# 💡 Resultado: arquivo com cores e timestamps preservados
script -c "mix phx.server" /tmp/phoenix-session.log && lnav /tmp/phoenix-session.log
```

### Etapa 4: Análise de Crash Dumps do Erlang

#### Converter crash dump para texto:
```bash
# strings erl_crash.dump | head -50 | lnav
# 📖 Explicação: Extrai strings legíveis do crash dump
# 🔧 Comandos:
#    strings: extrai texto de arquivo binário
#    head -50: limita às primeiras 50 linhas
#    | lnav: visualiza com highlighting
# 📚 Man pages: man 1 strings, man 1 head
# 💡 Buscar: processos, memória, stack traces
strings erl_crash.dump | head -50 | lnav

# grep -a "Process Information" erl_crash.dump -A 20 | lnav
# 📖 Explicação: Extrai informações específicas de processos
# 🔧 Flags:
#    -a: trata arquivo binário como texto
#    "Process Information": busca seção específica
#    -A 20: mostra 20 linhas após cada match
# 💡 Foco: processos que causaram o crash
grep -a "Process Information" erl_crash.dump -A 20 | lnav
```

### Etapa 5: Monitoramento Integrado Multi-Stack

#### Correlacionar logs de diferentes fontes:
```bash
# lnav .claude/logs/bridge.log /tmp/phoenix.log /var/log/syslog
# 📖 Explicação: Abre múltiplos logs simultaneamente
# 🎯 Funcionalidade: ordena por timestamp automaticamente
# 💡 Correlação: eventos Claude + Phoenix + sistema
# 🔍 Buscar: falhas simultâneas, timeouts correlacionados
lnav .claude/logs/bridge.log /tmp/phoenix.log /var/log/syslog

# tail -f _build/dev/lib/blog/ebin/*.beam.log 2>/dev/null | lnav
# 📖 Explicação: Monitora logs de compilação Elixir em tempo real
# 🔧 Comando:
#    tail -f: segue arquivos em tempo real
#    *.beam.log: logs de módulos compilados
#    2>/dev/null: ignora erros se arquivos não existem
# 💡 Uso: debug de problemas de compilação WASM
tail -f _build/dev/lib/blog/ebin/*.beam.log 2>/dev/null | lnav
```

### Etapa 6: Configuração de Formatos Customizados para o Projeto

#### Criar formato específico para Claude hooks:
```bash
# mkdir -p ~/.config/lnav/formats
# 📖 Explicação: Cria diretório para formatos customizados
# 📁 Localização: ~/.config/lnav/formats/
mkdir -p ~/.config/lnav/formats

# cat > ~/.config/lnav/formats/claude-hooks.json << 'EOF'
# 📖 Explicação: Cria definição de formato para logs Claude
# 🔧 Método: heredoc (cat << 'EOF') para arquivo multilinhas
# 📚 Referência: lnav format documentation
cat > ~/.config/lnav/formats/claude-hooks.json << 'EOF'
{
  "claude_hooks_log": {
    "title": "Claude Hooks JSON Log",
    "description": "Logs JSON do sistema Claude hooks do blog Phoenix",
    "url": "file://.claude/logs/bridge.log",
    "json": true,
    "line-format": [
      {
        "field": "timestamp",
        "default-value": "-"
      },
      " [",
      {
        "field": "nivel",
        "default-value": "-"
      },
      "] ",
      {
        "field": "mensagem"
      }
    ],
    "timestamp-field": "timestamp",
    "level-field": "nivel",
    "level": {
      "error": "ERROR",
      "warning": "WARNING", 
      "info": "INFO",
      "debug": "DEBUG"
    }
  }
}
EOF
```

## ✅ Validação de Sucesso

### Como saber se deu certo:
- [ ] lnav reconhece logs JSON do Claude com cores apropriadas
- [ ] Phoenix logs aparecem com timestamps em tempo real
- [ ] Correlação temporal funciona entre diferentes fontes
- [ ] Consultas SQL retornam dados dos logs Claude
- [ ] Filtros por nível (ERROR, DEBUG) funcionam corretamente
- [ ] Crash dumps são legíveis quando necessário

### Comandos de Validação:
```bash
# lnav --version && echo "✅ lnav funcional"
# 📖 Explicação: Testa se lnav está instalado e operacional
# ✅ Sucesso: versão + "lnav funcional"
# ❌ Falha: command not found
lnav --version && echo "✅ lnav funcional"

# echo '{"timestamp": "2025-01-01T12:00:00Z", "nivel": "ERROR", "mensagem": "Teste"}' | lnav
# 📖 Explicação: Testa parsing de JSON similar ao Claude hooks
# 🔧 Comando: echo gera JSON + pipe para lnav
# ✅ Sucesso: lnav abre e destaca ERROR em vermelho
# 💡 Validação: formato compatível com logs reais
echo '{"timestamp": "2025-01-01T12:00:00Z", "nivel": "ERROR", "mensagem": "Teste"}' | lnav

# ls ~/.config/lnav/formats/claude-hooks.json
# 📖 Explicação: Verifica se formato customizado foi criado
# ✅ Sucesso: arquivo existe
# 💡 Uso: lnav carregará automaticamente na próxima execução
ls ~/.config/lnav/formats/claude-hooks.json
```

## 🚨 Troubleshooting

### Problema: JSON não está sendo parsed corretamente
**Causa:** Formato JSON não compatível com parser lnav
**Solução:**
```bash
# jq . .claude/logs/bridge.log | head -5
# 📖 Explicação: Valida estrutura JSON dos logs Claude
# 🔧 Ferramenta: jq (JSON processor)
# ✅ Output limpo: JSON bem formado
# ❌ Erro: JSON malformado, corrigir fonte
jq . .claude/logs/bridge.log | head -5

# Alternativa: forçar parsing
# sed 's/}{/}\n{/g' .claude/logs/bridge.log | lnav
# 📖 Explicação: Quebra JSON concatenados em linhas separadas
sed 's/}{/}\n{/g' .claude/logs/bridge.log | lnav
```

### Problema: Phoenix server não gera logs suficientes
**Causa:** Nível de log muito restritivo no ambiente dev
**Solução:**
```bash
# LOGGER_LEVEL=debug mix phx.server 2>&1 | lnav
# 📖 Explicação: Define nível DEBUG via variável de ambiente
# 🔧 Variável: LOGGER_LEVEL controla verbosidade
# 💡 Níveis: debug, info, warning, error
LOGGER_LEVEL=debug mix phx.server 2>&1 | lnav
```

### Problema: Crash dump muito grande para análise
**Causa:** erl_crash.dump com centenas de MB
**Solução:**
```bash
# head -1000 erl_crash.dump | strings | lnav
# 📖 Explicação: Analisa apenas início do crash dump
# 🔧 Limitação: head -1000 (primeiras 1000 linhas)
# 💡 Alternativa: tail -1000 (últimas linhas)
head -1000 erl_crash.dump | strings | lnav

# grep -a "^=" erl_crash.dump | lnav
# 📖 Explicação: Extrai apenas seções (linhas começando com =)
# 🔍 Seções: =memory, =processes, =atoms, etc.
grep -a "^=" erl_crash.dump | lnav
```

### Problema: Logs misturados sem correlação temporal
**Causa:** Timestamps em formatos diferentes entre fontes
**Solução:**
```bash
# lnav -t .claude/logs/bridge.log /tmp/phoenix.log
# 📖 Explicação: Força sincronização temporal
# 🔧 Flag:
#    -t: ajusta timestamps para correlação
# 💡 Resultado: ordem cronológica mesmo com formatos diferentes
lnav -t .claude/logs/bridge.log /tmp/phoenix.log
```

## 🎯 Casos de Uso Específicos para Phoenix+WASM

### 1. Debug de Falha na Inicialização WASM
```bash
# Cenário: AtomVM não carrega no browser
# Logs: Phoenix + WASM compilation + browser console

# lnav _build/wasm/lib/blog/ebin/blog.app -f /tmp/phoenix.log
# Correlacionar: build WASM + server responses + browser errors
# Buscar: WASM load failures, MIME type issues, COOP/COEP headers
```

### 2. Análise de Performance Claude Hooks
```sql
-- Dentro do lnav nos logs Claude
-- Tempo médio de resposta HTTP
SELECT avg(
  julianday(json_extract(log_body, '$.timestamp')) - 
  LAG(julianday(json_extract(log_body, '$.timestamp'))) 
  OVER (ORDER BY json_extract(log_body, '$.timestamp'))
) * 24 * 3600 as avg_response_seconds
FROM all_logs 
WHERE log_body LIKE '%HTTP%';
```

### 3. Monitoramento de Deploy WASM
```bash
# Durante deploy: build + compile + browser load
# lnav -f scripts/build-wasm-optimized.sh 2>&1 | tee /tmp/build.log | lnav
# Acompanhar: compilação + otimização + bundle size
```

### 4. Troubleshooting LiveView + WASM Integration  
```bash
# Phoenix LiveView + AtomVM coordination
# lnav /tmp/phoenix.log
# Buscar: WebSocket connections, LiveView mounts, WASM callbacks
# Filtros: :filter-in "LiveView" + :filter-in "WASM"
```

## ➡️ Próximos Passos

### Automação Avançada:
1. **Scripts de coleta** automática de logs multi-stack
2. **Alertas baseados em lnav** para falhas críticas  
3. **Dashboard web** integrando lnav SQL queries
4. **Correlação automática** Phoenix ↔ WASM events

### Integração com Workflow:
- **CI/CD monitoring** via lnav durante builds
- **Production debugging** com logs estruturados
- **Performance profiling** através de log analysis
- **Security auditing** de requests e responses

### Formatos Customizados Avançados:
- **AtomVM runtime logs** com stack traces
- **Browser performance** metrics parsing
- **Network timing** correlation com server logs

## 📚 Recursos Específicos Phoenix+WASM

### Documentação Relacionada:
- [Phoenix Logging](https://hexdocs.pm/logger/Logger.html)
- [AtomVM Documentation](https://doc.atomvm.net/)
- [lnav SQL Reference](https://lnav.readthedocs.io/en/latest/sql.html)

### Logs Típicos para Monitorar:
- **Phoenix**: Request logs, error logs, LiveView events
- **AtomVM**: Compilation logs, runtime errors, memory usage  
- **Browser**: Console errors, network timing, WASM load events
- **System**: Process crashes, memory pressure, file descriptors

### Padrões de Problemas Comuns:
- **WASM Load Fails**: COOP/COEP headers, MIME types
- **Phoenix Timeouts**: Database connections, external APIs
- **Memory Issues**: Erlang processes, WASM heap, browser limits
- **Network Issues**: WebSocket drops, CORS errors, SSL handshake

---

**Objetivo Alcançado:** Monitoramento completo Phoenix+WASM com lnav  
**Próximo Nível:** Automação de análise e alerting proativo  
**Status:** 🚀 Pronto para debug multi-stack eficiente