# Sistemas de Ajuda Linux e Man Pages

## Fundamentos das Man Pages

### Uso Básico
- **Formato**: `man <comando>`
- **Exemplo**: `man ls` - mostra manual do comando ls
- **Sair**: `q` para sair de qualquer man page
- **Ajuda**: `h` para ajuda de navegação dentro das man pages

### Navegação (Teclas Estilo Vim)
- **Movimento de linha**: `j` (baixo), `k` (cima)
- **Movimento de tela**: `Ctrl+f` (frente), `Ctrl+b` (trás)  
- **Pular para início**: `g` (começo), `G` (fim)
- **Números de linha**: `3j` (baixo 3 linhas), `3k` (cima 3 linhas)

### Busca em Man Pages
- **Busca para frente**: `/padrão` então `n` (próximo), `N` (anterior)
- **Busca para trás**: `?padrão` então `n` (mesma direção), `N` (inverter)
- **Repetição de busca**: `n` continua na direção da busca

## Convenções das Man Pages

### Formatação de Texto
- **Texto em negrito**: Digite exatamente como mostrado (comandos/opções literais)
- **Texto em itálico/sublinhado**: Substitua por argumento apropriado
- **Colchetes `[opção]`**: Parâmetros opcionais
- **Pipe `|`**: Opções mutuamente exclusivas (escolha uma)
- **Reticências `...`**: Pode ser repetido múltiplas vezes

### Estrutura de Comando - Exemplos
- `ls [opção]... [arquivo]...` 
  - Opções são opcionais e repetíveis
  - Arquivos são opcionais e repetíveis
  - Comando pode executar sem argumentos

### Formatos de Opção
- **Forma curta**: `-a` (traço simples, letra única)
- **Forma longa**: `--all` (traço duplo, palavra completa)
- **Equivalência**: `-a` e `--all` são idênticos
- **Argumentos**: `--width=60` (longo) = `-W 60` (curto)

## Melhores Práticas de Opções de Comando

### Combinando Opções Curtas
- **Separadas**: `ls -l -h` 
- **Combinadas**: `ls -lh` (equivalente)
- **Flexibilidade de ordem**: `ls -hl` também funciona
- **Misto**: `ls -lh --color=none` (curta + longa)

### Opções com Argumentos
- **Regra**: Opção que requer argumento deve ser última na forma combinada
- **Correto**: `ls -Fw 60` (w precisa de argumento, então é última)
- **Incorreto**: `ls -wF 60` (F seria tratado como argumento de w)
- **Espaçamento**: `ls -W60` (sem espaço necessário para opções curtas)

## Seções das Man Pages

### Números de Seção
1. **Seção 1**: Comandos do usuário (mais comum)
2. **Seção 2**: Chamadas do sistema (programação)
3. **Seção 3**: Funções de biblioteca (programação)  
4. **Seção 8**: Comandos de administração do sistema

### Múltiplas Seções
- **Padrão**: `man unlink` (mostra primeira encontrada, geralmente seção 1)
- **Específica**: `man 2 unlink` (mostra versão da seção 2)
- **Buscar todas**: `man -k padrão` (busca por palavra-chave em seções)

### POSIX vs Linux
- **Seções POSIX**: Terminam em 'P' (ex.: seção 3P)
- **Específicas do Linux**: Sem sufixo 'P'
- **Preferência**: Use seções Linux para sistemas Linux

## Built-ins do Shell

### Identificação
- **Testar tipo de comando**: `type nome_comando`
- **Resultado built-in**: Mostra "shell builtin" ou "shell keyword"
- **Resultado externo**: Mostra caminho do arquivo

### Obtendo Ajuda para Built-ins
- **Sistema de ajuda built-in**: `help nome_comando`
- **Listar todos**: `help` (mostra todos os tópicos de ajuda disponíveis)
- **Exemplo**: `help while` (sintaxe para loops while)

### Built-ins Comuns
- `help`, `type`, `cd`, `pwd`, `echo`, `while`, `for`, `if`
- Sem man pages dedicadas (construídos no shell)
- Documentação na man page do shell (ex.: `man bash`)

## Sistemas de Ajuda Alternativos

### Ajuda Built-in de Comandos
- **Padrão**: `comando --help` (mais comum)
- **Forma curta**: `comando -h` (alguns comandos)
- **Ponto de interrogação**: `comando -?` (raro)

### Exemplos
- `man --help` - mostra opções do comando man
- `ls --help` - mostra ajuda do comando ls
- `vim --help` - mostra opções de inicialização do vim

## Encontrando Documentação

### Estratégia de Busca
1. Tente `man comando` primeiro
2. Se não encontrar, tente `type comando` para verificar se é built-in
3. Se built-in, use `help comando`
4. Tente `comando --help` para referência rápida
5. Use `man -k palavra-chave` para tópicos relacionados

### Estrutura das Man Pages
- **NAME**: Descrição breve
- **SYNOPSIS**: Sintaxe de uso
- **DESCRIPTION**: Explicação detalhada
- **OPTIONS**: Flags e argumentos disponíveis
- **EXAMPLES**: Padrões de uso comum
- **SEE ALSO**: Comandos e tópicos relacionados
- **FILES**: Arquivos de configuração
- **ENVIRONMENT**: Variáveis de ambiente relevantes
- **EXIT STATUS**: Códigos de retorno para scripts

## Dicas Práticas

### Leitura Eficaz
1. Comece com SYNOPSIS para sintaxe
2. Pule para OPTIONS para flags específicas
3. Verifique EXAMPLES para padrões comuns
4. Use SEE ALSO para ferramentas relacionadas

### Referência Rápida
- Mantenha man pages usadas frequentemente marcadas
- Crie folhas de cola pessoais para comandos complexos
- Pratique teclas de navegação até ficarem automáticas
- Use completar com tab no sistema de ajuda: `:help <tab>`