# Plugin Vim-Org Markdown

## Visão Geral
Plugin para organizar tarefas e dados em arquivos markdown com recursos de produtividade similares ao Vim.

## Recursos

### Gerenciamento de Tarefas
- **Criação de checkbox**: `- [ ]` cria checkboxes para listas de tarefas
- **Alternar tarefas**: `cx` no modo normal alterna conclusão de tarefa
- **Operações em lote**: Modo visual + `cx` alterna múltiplas tarefas
- **Desfazer alternância**: `cx` pode desmarcar tarefas concluídas

### Operações de Tabela
- **Alinhamento automático**: `=` no modo normal alinha formatação de tabela
- **Formatos de exportação**: 
  - CSV: `:VorgMarkdownTableExport csv`
  - JSON: `:VorgMarkdownTableExport json` 
  - HTML: `:VorgMarkdownTableExport html`

### Funções de Data e Hora
- **Data atual**: `dd<espaço>` insere data atual
- **Data com hora**: `dt<espaço>` insere data e hora
- **Navegação por dias**:
  - `dn[1-7]<espaço>` - Próxima ocorrência do dia da semana (1=Segunda, 7=Domingo)
  - `dp[1-7]<espaço>` - Ocorrência anterior do dia da semana

### Exportação de Documentos
- **Integração Pandoc**: `:VorgMarkdownPandocExport`
- **Exportação completa de documento**: Exporta arquivo inteiro para PDF/HTML
- **Exportação parcial**: Seleção visual pode ser exportada separadamente
- **Requisitos**: pandoc e pacotes LaTeX para exportação PDF

### Sistema de Agenda
- **Visualizar agenda**: `??` abre visualização de agenda com tarefas agendadas
- **Agendamento de tarefas**: Combina datas com itens de tarefa para planejamento

## Resumo de Comandos Principais
| Comando | Função |
|---------|--------|
| `cx` | Alternar conclusão de tarefa |
| `=` | Alinhar tabela |
| `dd<espaço>` | Inserir data |
| `dt<espaço>` | Inserir data/hora |
| `dn[1-7]<espaço>` | Próximo dia da semana |
| `dp[1-7]<espaço>` | Dia anterior da semana |
| `??` | Abrir agenda |

## Casos de Uso
- Gerenciamento diário de tarefas
- Organização e exportação de dados
- Preparação e formatação de documentos
- Planejamento de projetos com datas e prazos