# 📊 LNAV - Log File Navigator - Guia Completo

## 📋 Visão Geral
- **Objetivo:** Dominar a ferramenta lnav para análise avançada de logs
- **Tempo estimado:** 45-60 minutos
- **Pré-requisitos:** Terminal Linux/WSL, arquivos de log para prática
- **Resultado final:** Capacidade de analisar logs complexos com eficiência

## 🔍 Contexto Educativo

### Por que o lnav é superior?
O **lnav** (Log File Navigator) vai muito além do simples `tail -f` ou `grep`. É um visualizador inteligente que:
- **Entende semântica** de logs (timestamps, níveis, formatos)
- **Correlaciona múltiplos** arquivos automaticamente
- **Oferece análise SQL** direta nos logs
- **Detecta padrões** automaticamente

### Como se conecta com análise de sistemas?
- **Troubleshooting** rápido de problemas
- **Análise de performance** através de logs
- **Detecção de anomalias** em tempo real
- **Correlação de eventos** entre serviços

## 📊 Antes de Começar - Verificações

### Checklist de Pré-requisitos:
- [ ] Sistema Linux/WSL disponível
- [ ] Acesso a arquivos de log (sistema, aplicação, ou exemplos)
- [ ] Permissões de leitura nos diretórios de log
- [ ] Conexão com internet (para instalação)

### Comandos de Diagnóstico:
```bash
# ls -la /var/log/
# 📖 Explicação: Lista arquivos de log disponíveis no sistema
# 🔧 Flags usadas:
#    -l: formato longo com detalhes
#    -a: incluir arquivos ocultos
# 📚 Man page: man 1 ls
# 💡 Exemplo prático: identificar logs disponíveis para teste
# ✅ Sucesso: Lista arquivos como syslog, auth.log, etc.
# ⚠️ Nota: Alguns logs podem exigir sudo para leitura
ls -la /var/log/

# command -v lnav
# 📖 Explicação: Verifica se lnav já está instalado
# 📚 Man page: man 1 command
# ✅ Se instalado: mostra caminho como /usr/bin/lnav
# ❌ Se não instalado: sem output (código de saída != 0)
# 🔄 Próximo passo: instalação se necessário
command -v lnav
```

## 🚀 Passo a Passo Detalhado

### Etapa 1: Instalação do lnav

**Ubuntu/Debian:**
```bash
# apt update && apt install lnav
# 📖 Explicação: Atualiza índice de pacotes e instala lnav
# 🔧 Comandos:
#    apt update: sincroniza lista de pacotes disponíveis
#    apt install: instala pacote especificado
# 📚 Man page: man 8 apt
# ⚠️ Requer: sudo ou execução como root
# 🔄 Alternativa: snapd com 'snap install lnav'
sudo apt update && sudo apt install lnav
```

**Arch Linux:**
```bash
# pacman -S lnav
# 📖 Explicação: Instala lnav do repositório oficial Arch
# 🔧 Flag:
#    -S: sincronizar e instalar do repositório
# 📚 Man page: man 8 pacman
# ⚠️ Arch minimal: executar como root sem sudo
# 💡 Alternativa: AUR com yay -S lnav
pacman -S lnav
```

**Compilação do Código Fonte:**
```bash
# wget https://github.com/tstack/lnav/releases/download/v0.11.2/lnav-0.11.2.tar.gz
# 📖 Explicação: Baixa código fonte da versão estável mais recente
# 🔧 Ferramenta: wget para download HTTP
# 📚 Man page: man 1 wget
# 💡 Verificar: versão mais atual no GitHub releases
# 🔄 Alternativa: curl -L -o lnav.tar.gz [URL]
wget https://github.com/tstack/lnav/releases/download/v0.11.2/lnav-0.11.2.tar.gz

# tar -xzf lnav-0.11.2.tar.gz
# 📖 Explicação: Extrai arquivo comprimido tar+gzip
# 🔧 Flags:
#    -x: extrair arquivos
#    -z: descomprimir gzip
#    -f: especificar arquivo
# 📚 Man page: man 1 tar
# ✅ Resultado: diretório lnav-0.11.2/ criado
tar -xzf lnav-0.11.2.tar.gz

cd lnav-0.11.2

# ./configure --prefix=/usr/local
# 📖 Explicação: Configura build para instalação local
# 🔧 Flag:
#    --prefix: define diretório de instalação
# 📚 Documentação: ./configure --help
# ⚠️ Requer: build-essential ou base-devel instalado
./configure --prefix=/usr/local

# make -j$(nproc)
# 📖 Explicação: Compila usando todos CPU cores disponíveis
# 🔧 Flag:
#    -j$(nproc): paralelização com número de cores
# 📚 Man page: man 1 make
# 💡 Exemplo: make -j4 (força 4 threads)
# ⏱️ Tempo: 5-15 minutos dependendo do hardware
make -j$(nproc)

# make install
# 📖 Explicação: Instala binários compilados no sistema
# ⚠️ Requer: sudo se instalando em /usr/local
# ✅ Resultado: lnav disponível em /usr/local/bin/lnav
sudo make install
```

### Etapa 2: Verificação da Instalação

```bash
# lnav --version
# 📖 Explicação: Verifica versão instalada e funcionalidade básica
# 🔧 Flag:
#    --version: exibe informações de versão e build
# ✅ Sucesso: lnav 0.11.2 (ou versão instalada)
# ❌ Falha: command not found - verificar PATH
lnav --version

# lnav --help | head -20
# 📖 Explicação: Mostra primeiras 20 linhas da ajuda
# 🔧 Comandos:
#    --help: exibe ajuda completa
#    head -20: limita saída às primeiras 20 linhas
# 📚 Man pages: man 1 lnav, man 1 head
# 💡 Uso: entender opções básicas disponíveis
lnav --help | head -20
```

### Etapa 3: Uso Básico - Visualização Simples

```bash
# lnav /var/log/syslog
# 📖 Explicação: Abre arquivo de log do sistema no visualizador
# 📚 Arquivo: /var/log/syslog (logs gerais do sistema)
# 🎮 Controles: q (sair), / (buscar), n (próximo), N (anterior)
# ⚠️ Permissão: pode exigir sudo para ler alguns logs
# 💡 Dica: usar sudo lnav se necessário
lnav /var/log/syslog
```

**Controles Básicos dentro do lnav:**
- `q` - Sair
- `?` - Ajuda completa
- `/padrão` - Buscar texto
- `n` / `N` - Próximo/anterior resultado
- `g` / `G` - Ir para início/fim
- `e` / `E` - Próximo/anterior erro
- `w` / `W` - Próximo/anterior warning

### Etapa 4: Funcionalidades Avançadas

#### Análise Multi-arquivo:
```bash
# lnav /var/log/*.log
# 📖 Explicação: Abre múltiplos logs simultaneamente
# 🔧 Padrão: *.log (todos arquivos terminados em .log)
# 🎯 Funcionalidade: ordena por timestamp automaticamente
# 💡 Vantagem: correlaciona eventos entre diferentes logs
# ⚠️ Performance: muitos arquivos podem ser lentos
lnav /var/log/*.log
```

#### Modo Follow (acompanhar em tempo real):
```bash
# lnav -f /var/log/syslog
# 📖 Explicação: Acompanha arquivo em tempo real (como tail -f)
# 🔧 Flag:
#    -f: modo follow, atualiza automaticamente
# 📚 Comparação: tail -f (básico) vs lnav -f (inteligente)
# 💡 Vantagem: highlighting automático de erros
# 🎮 Controle: Ctrl+C para parar
lnav -f /var/log/syslog
```

#### Filtragem com Expressões Regulares:
```bash
# lnav /var/log/auth.log
# 📖 Explicação: Analisa logs de autenticação
# 💡 Dentro do lnav:
#    :filter-in ssh     - mostra apenas linhas com 'ssh'
#    :filter-out Failed - oculta linhas com 'Failed'
#    :reset-filters     - remove todos filtros
#    :save-filters      - salva filtros atuais
lnav /var/log/auth.log
```

### Etapa 5: Análise com SQL

#### Consultas Básicas:
```sql
-- Dentro do lnav, pressionar ; para modo SQL
-- Contar logs por nível
SELECT log_level, count(*) 
FROM all_logs 
GROUP BY log_level 
ORDER BY count DESC;

-- Logs das últimas 24 horas
SELECT * 
FROM all_logs 
WHERE log_time >= datetime('now', '-1 day')
ORDER BY log_time DESC;

-- Top 10 IPs mais frequentes
SELECT log_body, count(*) as freq
FROM all_logs 
WHERE log_body REGEXP '\b\d+\.\d+\.\d+\.\d+\b'
GROUP BY log_body 
ORDER BY freq DESC 
LIMIT 10;
```

#### Análise de Performance:
```sql
-- Detectar picos de atividade
SELECT 
  strftime('%H', log_time) as hour,
  count(*) as events
FROM all_logs 
WHERE log_time >= datetime('now', '-1 day')
GROUP BY hour 
ORDER BY events DESC;

-- Análise de erros por hora
SELECT 
  strftime('%Y-%m-%d %H:00', log_time) as time_bucket,
  count(*) as error_count
FROM all_logs 
WHERE log_level = 'ERROR'
GROUP BY time_bucket 
ORDER BY time_bucket;
```

### Etapa 6: Configuração e Personalização

#### Arquivo de Configuração:
```bash
# mkdir -p ~/.config/lnav
# 📖 Explicação: Cria diretório de configuração do lnav
# 🔧 Flag:
#    -p: cria diretórios pai se não existirem
# 📚 Man page: man 1 mkdir
# 💡 Local: ~/.config/lnav/config.json
mkdir -p ~/.config/lnav

# lnav -m /var/log/syslog
# 📖 Explicação: Modo de configuração interativa
# 🔧 Flag:
#    -m: modo de configuração/setup
# 🎯 Função: ajusta preferências e formatos
# 💡 Primeira execução: cria configuração padrão
lnav -m /var/log/syslog
```

#### Definir Formatos Customizados:
```json
// ~/.config/lnav/formats/custom.json
{
  "custom_app_log": {
    "title": "Custom Application Log",
    "description": "Logs from custom application",
    "url": "http://example.com/docs",
    "regex": {
      "basic": {
        "pattern": "^(?P<timestamp>\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}) \\[(?P<level>\\w+)\\] (?P<body>.*)"
      }
    },
    "timestamp-format": [
      "%Y-%m-%d %H:%M:%S"
    ],
    "level-field": "level",
    "body-field": "body"
  }
}
```

## ✅ Validação de Sucesso

### Como saber se deu certo:
- [ ] lnav abre arquivos de log sem erros
- [ ] Navegação funciona (setas, busca, filtros)
- [ ] Modo SQL retorna resultados
- [ ] Highlighting automático de erros visível
- [ ] Multi-arquivo ordena por timestamp
- [ ] Configurações persistem entre sessões

### Comandos de Validação:
```bash
# lnav --version
# 📖 Explicação: Confirma instalação e versão
# ✅ Sucesso: lnav 0.11.x + informações de build
# ❌ Falha: comando não encontrado
lnav --version

# echo "2024-01-01 12:00:00 [ERROR] Test message" | lnav
# 📖 Explicação: Testa parsing de log via stdin
# 🔧 Comando:
#    echo: gera linha de log de teste
#    | (pipe): redireciona para lnav
# ✅ Sucesso: lnav abre e destaca [ERROR] em vermelho
# 💡 Teste: verificar se cores e parsing funcionam
echo "2024-01-01 12:00:00 [ERROR] Test message" | lnav

# ls ~/.lnav/
# 📖 Explicação: Verifica se diretório de dados foi criado
# 📁 Conteúdo esperado: archives/, formats/, crashes/
# ✅ Sucesso: diretórios de configuração presentes
# 💡 Significado: lnav criou estrutura de dados local
ls ~/.lnav/
```

## 🚨 Troubleshooting

### Problema: "Permission denied" ao ler logs
**Causa:** Arquivos de log requerem privilégios elevados
**Solução:** 
```bash
# sudo lnav /var/log/secure
# 📖 Explicação: Executa lnav com privilégios de root
# ⚠️ Cuidado: apenas para leitura, não modificação
sudo lnav /var/log/secure

# Alternativa: adicionar usuário ao grupo adm
sudo usermod -a -G adm $USER
# Logout/login necessário para efetivar
```

### Problema: Performance lenta com muitos arquivos
**Causa:** lnav indexa todos arquivos ao iniciar
**Solução:**
```bash
# lnav -n /var/log/*.log
# 📖 Explicação: Desabilita indexação automática
# 🔧 Flag:
#    -n: no auto-indexing, carregamento mais rápido
# 💡 Trade-off: menos recursos vs velocidade inicial
lnav -n /var/log/*.log
```

### Problema: Formato não reconhecido
**Causa:** Log possui formato customizado não padrão
**Solução:**
- Criar definição de formato em `~/.config/lnav/formats/`
- Usar regex para definir parsing customizado
- Consultar documentação oficial para exemplos

### Problema: Cores não aparecem
**Causa:** Terminal não suporta cores ou configuração incorreta
**Solução:**
```bash
# echo $TERM
# 📖 Explicação: Verifica tipo de terminal configurado
# ✅ Esperado: xterm-256color, screen-256color, etc.
echo $TERM

# export TERM=xterm-256color
# 📖 Explicação: Define terminal com suporte a 256 cores
# 🔧 Comando: export define variável de ambiente
# 💡 Permanente: adicionar ao ~/.bashrc
export TERM=xterm-256color
```

## 🎯 Casos de Uso Práticos

### 1. Troubleshooting de Aplicação Web
```bash
# lnav /var/log/nginx/access.log /var/log/nginx/error.log /var/log/app/app.log
# Correlacionar: requests HTTP + erros server + logs aplicação
# Buscar: códigos 5xx, timeouts, exceptions
```

### 2. Análise de Segurança
```bash
# lnav /var/log/auth.log /var/log/secure
# Buscar: tentativas de login, sudo usage, SSH connections
# SQL: agrupar por IP, detectar padrões suspeitos
```

### 3. Monitoramento de Performance
```bash
# lnav -f /var/log/performance/*.log
# Tempo real: response times, memory usage, CPU load
# Alertas: valores acima de thresholds definidos
```

### 4. Debugging de Deployment
```bash
# lnav /var/log/deploy/*.log
# Acompanhar: processo de deploy, health checks, startup
# Verificar: se todos serviços subiram corretamente
```

## ➡️ Próximos Passos

### Aprofundamento:
1. **Criar formatos** customizados para seus logs
2. **Automatizar análises** com scripts SQL
3. **Integrar com alerting** (hook com scripts externos)
4. **Configurar dashboards** baseados em queries SQL

### Recursos Avançados:
- **Timeline view** para análise temporal
- **Histogram mode** para distribuições
- **Bookmarks** para marcar pontos importantes
- **Session replay** para reproduzir problemas

### Integração com Workflow:
- Combinação com `journalctl` para logs systemd
- Integração com `grep`, `awk` em pipelines
- Scripts de automação com `lnav -c` (command mode)

## 📚 Recursos Adicionais

### Documentação:
- [Manual Oficial](https://lnav.readthedocs.io/)
- [GitHub Repository](https://github.com/tstack/lnav)
- [SQL Reference](https://lnav.readthedocs.io/en/latest/sql.html)

### Comunidade:
- Discord: Suporte da comunidade
- Google Groups: Discussões técnicas
- GitHub Issues: Bug reports e feature requests

### Alternativas para Comparação:
- **Básicas:** `tail`, `less`, `grep`
- **Avançadas:** `goaccess` (web logs), `multitail` (múltiplos arquivos)
- **Enterprise:** Splunk, ELK Stack, Fluentd

---

**Objetivo Alcançado:** Domínio completo do lnav para análise profissional de logs  
**Próximo Nível:** Automação e integração com monitoramento de sistemas  
**Status:** 📊 Pronto para análise avançada de logs