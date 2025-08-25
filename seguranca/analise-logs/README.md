# Análise de Logs

## Comandos Essenciais
- `cat` - Visualizar conteúdo
- `grep` - Filtrar padrões
- `cut` - Extrair campos
- `sort` - Ordenar dados
- `uniq` - Remover duplicatas
- `wc -l` - Contar linhas

## Logs Importantes
- `/var/log/auth.log` - Autenticações e SSH
- `/var/log/syslog` - Sistema geral
- `/var/log/fail2ban.log` - Tentativas bloqueadas

## Pipeline Básico
```bash
cat /var/log/auth.log | grep "Failed" | cut -d' ' -f11 | sort | uniq -c
```