# Monitoramento de Segurança

## Fail2ban
- Detecção automática de tentativas de invasão
- Ban temporário/permanente de IPs maliciosos
- Configuração: 2 tentativas = ban 24h

## Análise de IPs Suspeitos
```bash
# Extrair IPs únicos banidos
cat /var/log/fail2ban.log | grep "Ban" | grep -v "Restore" | \
cut -d' ' -f16 | sort | uniq > ~/banned_ips.txt
```

## Blacklist Manual
- Criar lista de IPs para bloqueio permanente
- Integração com iptables/firewall