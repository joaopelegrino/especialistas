# Documentação Especializada de Fundamentos do Vim

Este repositório contém documentação técnica para uso avançado do Vim e técnicas de produtividade.

## Estrutura da Documentação

### [01-markdown-organization.md](01-markdown-organization.md)
**Plugin Vim-Org Markdown**
- Gerenciamento de tarefas com checkboxes
- Operações de tabela e funcionalidade de exportação  
- Inserção e navegação de data/hora
- Exportação de documentos via Pandoc
- Sistema de agenda para planejamento

### [02-completion-systems.md](02-completion-systems.md) 
**Sistemas de Completion do Vim**
- Métodos nativos de completion (Ctrl+n, combinações Ctrl+x)
- Omni completion para sugestões conscientes da linguagem
- Plugin MuComplete para UX aprimorada
- Criação de funções de completion personalizadas
- Estratégias de integração LSP

### [03-vim-manual-highlights.md](03-vim-manual-highlights.md)
**Páginas Essenciais do Manual do Vim**
- Top 5 seções mais valiosas do manual
- Referência de comandos santo graal (`:help holy-grail`)
- Árvore de desfazer e comandos de viagem no tempo
- Tips.txt para melhorias de produtividade
- Abordagem estratégica de leitura do manual

### [04-help-and-man-pages.md](04-help-and-man-pages.md)
**Sistemas de Ajuda Linux e Man Pages**
- Navegação em man pages com teclas do Vim
- Compreensão das convenções de documentação
- Formatos e combinações de opções de comando
- Built-ins do shell vs comandos externos
- Sistemas de ajuda alternativos

## Referência Rápida

### Teclas Essenciais de Completion do Vim
- `Ctrl+n/Ctrl+p` - Completion básico de palavras
- `Ctrl+x Ctrl+l` - Completion de linha
- `Ctrl+x Ctrl+f` - Completion de caminho de arquivo
- `Ctrl+x Ctrl+o` - Omni completion
- `Ctrl+x Ctrl+s` - Completion de ortografia

### Seções Principais do Manual
- `:help holy-grail` - Todos os comandos de dois pontos
- `:help tips.txt` - Dicas de edição
- `:help undo-tree` - Desfazer avançado
- `:help digraphs` - Caracteres especiais
- `:help marks` - Marcadores de posição

### Navegação em Man Pages
- `j/k` - Movimento de linha
- `Ctrl+f/Ctrl+b` - Movimento de página  
- `/padrão` - Busca para frente
- `?padrão` - Busca para trás
- `g/G` - Pular para início/fim

## Caminho de Aprendizado

1. **Comece com sistemas de completion** - Ganhos imediatos de produtividade
2. **Explore os destaques do manual** - Descubra recursos poderosos
3. **Domine os sistemas de ajuda** - Autossuficiência no aprendizado
4. **Adicione plugins de produtividade** - Ferramentas de fluxo de trabalho aprimoradas

## Dicas de Integração

- Pratique uma seção por vez
- Crie folhas de cola pessoais para comandos usados frequentemente
- Configure cadeias de completion para suas linguagens mais utilizadas
- Integre gradualmente com sua configuração existente do Vim