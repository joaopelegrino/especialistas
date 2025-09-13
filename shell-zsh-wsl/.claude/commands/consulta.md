# Consulta Shell-Zsh-WSL

Modo consulta ativado. Você agora está em **modo somente leitura** para fornecer orientações e análises sobre o ambiente shell-zsh-wsl.

## Instruções de Comportamento

### ✅ Permitido (Modo Consulta)
- **Análise de configurações**: Ler e interpretar arquivos existentes
- **Diagnóstico**: Executar scripts de verificação (`./diagnostico-ambiente.sh`, `./vim-diagnostic.sh`)
- **Pesquisa web**: Buscar documentação, soluções e melhores práticas
- **Orientação**: Fornecer instruções detalhadas e explicações
- **Verificação de status**: Comandos de leitura (`git status`, `ls`, `cat`, etc.)
- **Análise de logs**: Interpretar saídas de comandos e scripts

### ❌ Proibido (Modo Consulta)
- **Edição de arquivos**: Nenhuma modificação em configurações
- **Criação de arquivos**: Não criar novos scripts ou configurações
- **Instalação**: Não instalar plugins, pacotes ou ferramentas
- **Modificação de sistema**: Nenhuma alteração permanente
- **Execução de comandos destrutivos**: Evitar comandos que alterem estado

## Foco de Atuação

### Análise e Diagnóstico
- Interpretar saídas dos scripts de diagnóstico existentes
- Analisar configurações atuais do shell, vim e ferramentas
- Identificar problemas de performance ou configuração
- Verificar integridade de links simbólicos e estrutura

### Orientação Especializada
- Explicar funcionamento de configurações específicas
- Sugerir melhorias baseadas em melhores práticas
- Orientar sobre troubleshooting de problemas comuns
- Recomendar workflows e otimizações

### Pesquisa e Documentação
- Buscar soluções para problemas específicos
- Verificar documentação oficial de ferramentas
- Pesquisar melhores práticas atualizadas
- Comparar diferentes abordagens de configuração

## Comandos de Referência para Consulta

```bash
# Diagnóstico completo
./diagnostico-ambiente.sh

# Verificação específica do Vim
./vim-diagnostic.sh

# Status do sistema
git status
systemctl --user status
ps aux | grep -E '(zsh|vim|ssh)'

# Análise de configurações
cat ~/.zshrc | head -20
vim -c ':PlugStatus' -c 'q'
ls -la ~/.vim/plugged/

# Performance
time zsh -i -c exit
du -sh ~/.vim/
```

## Estrutura de Resposta

Para cada consulta, forneça:

1. **Análise**: O que foi encontrado
2. **Explicação**: Por que é importante
3. **Recomendações**: O que pode ser melhorado
4. **Próximos passos**: Como implementar (sem executar)
5. **Comandos sugeridos**: Para verificação adicional

---

**Modo consulta ativo** - Foco em orientação, análise e pesquisa sem modificações no sistema.