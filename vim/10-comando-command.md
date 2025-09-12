# Decomposição Técnica: :command!

## 🎯 Comando/Conceito Analisado
```vim
:command! -nargs=+ -range -bang -complete=file MyCommand echo <q-args>
```

## 🏗️ Classificação Geral
- **Categoria Principal**: Vim Ex Commands / User-Defined Commands
- **Complexidade**: Intermediário/Avançado  
- **Tecnologias Envolvidas**: Vim Script, Ex Command Line, Argument Processing

## 📐 Anatomia Visual Completa

### Decomposição Elemento por Elemento
```
:command! -nargs=+ -range -bang -complete=file MyCommand echo <q-args>
│     │    │        │      │     │             │         │    │
│     │    │        │      │     │             │         │    └── Placeholder: argumentos quotados
│     │    │        │      │     │             │         └── Implementação: comando a executar
│     │    │        │      │     │             └── Nome: identificador do comando criado
│     │    │        │      │     └── Atributo: tipo de autocompletar
│     │    │        │      └── Atributo: aceita ! (bang) ao ser chamado
│     │    │        └── Atributo: aceita seleção de range/linhas
│     │    └── Atributo: número e tipo de argumentos aceitos
│     └── Modificador: força redefinição se comando já existe
└── Prefixo: indica modo comando Ex do Vim
```

## 📖 Nomenclatura e Classificação

### Elementos do Vim Ex Command

| Elemento | Nome Técnico | Categoria | Função | Pesquisar |
|----------|-------------|-----------|---------|-----------|
| `:` | Command-line indicator | Vim mode | Indica modo comando Ex | `:help :` |
| `command` | Command definition builtin | Vim builtin | Define comandos customizados | `:help :command` |
| `!` | Force/Bang modifier | Vim operator | Força redefinição de comando | `:help :command!` |

### Atributos de Comando (-flags)

| Elemento | Nome Técnico | Categoria | Função | Pesquisar |
|----------|-------------|-----------|---------|-----------|
| `-nargs=+` | Argument specification | Command attribute | Controla argumentos aceitos | `:help :command-nargs` |
| `-range` | Range specification | Command attribute | Permite seleção de linhas | `:help :command-range` |
| `-bang` | Bang attribute | Command attribute | Aceita ! no comando criado | `:help :command-bang` |
| `-complete=file` | Completion specification | Command attribute | Define tipo de autocompletar | `:help :command-complete` |

### Elementos de Implementação

| Elemento | Nome Técnico | Categoria | Função | Pesquisar |
|----------|-------------|-----------|---------|-----------|
| `MyCommand` | User command name | Identifier | Nome do novo comando | `:help user-commands` |
| `echo` | Built-in command | Vim builtin | Comando a ser executado | `:help :echo` |
| `<q-args>` | Argument placeholder | Special variable | Representa argumentos quotados | `:help <q-args>` |

## 🎓 Progressão de Aprendizado

### Nível 1 - Fundamentos
**Comando básico sem atributos:**
```vim
:command Hello echo "Olá mundo!"
```
- Entender `:command` vs `:command!`
- Nomenclatura obrigatória (primeira letra maiúscula)
- Redefinição e conflitos

### Nível 2 - Argumentos
**Adicionando capacidade de argumentos:**
```vim
:command! -nargs=1 Greet echo "Olá" <args>
:command! -nargs=* Show echo <f-args>
:command! -nargs=+ Say echo <q-args>
```
- Diferentes tipos `-nargs` (0, 1, *, ?, +)
- Placeholders `<args>`, `<f-args>`, `<q-args>`
- Tratamento de espaços e quotes

### Nível 3 - Atributos Avançados
**Comando com múltiplos atributos:**
```vim
:command! -nargs=* -range -bang -complete=file Edit
    \ if <bang>0 | edit! <args> | else | edit <args> | endif
```
- Ranges e contadores
- Bang (!) handling
- Autocompletar personalizado
- Comandos multilinhas

### Nível 4 - Maestria
**Comando complexo com lógica condicional:**
```vim
:command! -nargs=+ -range=% -complete=customlist,MyComplete 
    \ MyAdvanced call MyFunction(<line1>, <line2>, <f-args>, <bang>0)
```
- Custom completion functions
- Integração com funções Vim Script
- Manipulação de ranges complexos
- Variáveis especiais completas

## 📚 Recursos de Estudo por Tecnologia

### Para Vim Ex Commands:
- `:help user-commands` - Manual completo
- `:help :command` - Sintaxe básica
- `:help command-completion` - Autocompletar

### Para Atributos Específicos:
- `:help :command-nargs` - Controle de argumentos
- `:help :command-range` - Seleção de linhas
- `:help :command-bang` - Modificador bang
- `:help :command-complete` - Tipos de completion

### Para Placeholders e Variáveis:
- `:help <args>` - Argumentos brutos
- `:help <q-args>` - Argumentos quotados
- `:help <f-args>` - Argumentos como lista de função
- `:help <line1>` e `:help <line2>` - Range variables

### Documentação Oficial:
- https://vimdoc.sourceforge.net/htmldoc/map.html#user-commands
- Section 40.2 do Vim User Manual
- `:help usr_40.txt` - Definindo novos comandos

## 🔬 Laboratório Prático

### Exercício 1 - Isolando Componentes
```bash
# Testar comando básico
:command TestBasic echo "funcionou"
:TestBasic

# Testar redefinição
:command TestBasic echo "versão 1"
:command! TestBasic echo "versão 2"
:TestBasic

# Testar argumentos
:command! -nargs=1 TestArgs echo "Argumento:" <args>
:TestArgs hello
```

### Exercício 2 - Combinações Básicas
```bash
# Comando com argumentos múltiplos
:command! -nargs=* MultiArgs echo len([<f-args>]) "argumentos recebidos"
:MultiArgs um dois três

# Comando com range
:command! -range ShowRange echo "Linhas" <line1> "a" <line2>
:1,5ShowRange

# Comando com bang
:command! -bang TestBang echo <bang>0 ? "com !" : "sem !"
:TestBang
:TestBang!
```

### Exercício 3 - Comando Completo
```bash
# Reconstruir o comando original step-by-step
:command MyCommand echo "passo 1"
:command! MyCommand echo "passo 2" 
:command! -nargs=+ MyCommand echo <q-args>
:command! -nargs=+ -range MyCommand echo "range:" <line1>-<line2> "args:" <q-args>
:command! -nargs=+ -range -bang MyCommand echo (<bang>0?"!":"") <line1>-<line2> <q-args>
:command! -nargs=+ -range -bang -complete=file MyCommand echo (<bang>0?"!":"") <line1>-<line2> <q-args>
```

### Exercício 4 - Variações Práticas
```bash
# Criar comando de backup
:command! -nargs=1 -complete=file Backup !cp <args> <args>.backup

# Comando para busca em arquivos
:command! -nargs=+ Find grep -r <f-args> .

# Comando para salvar com timestamp
:command! SaveTime execute 'w' strftime('%Y%m%d_%H%M%S') . '_' . expand('%:t')

# Comando que aceita range para comentários
:command! -range Comment <line1>,<line2>s/^/# /
```

## 🔍 Detalhes Técnicos Específicos

### Tipos de -nargs Explicados
| Valor | Significado | Exemplo de Uso |
|-------|-------------|----------------|
| `0` | Nenhum argumento (padrão) | `:command Save w` |
| `1` | Exatamente um argumento (pode conter espaços) | `:command -nargs=1 Edit edit <args>` |
| `*` | Zero ou mais argumentos | `:command -nargs=* Show echo <f-args>` |
| `?` | Zero ou um argumento | `:command -nargs=? Load edit <args>` |
| `+` | Um ou mais argumentos (obrigatório) | `:command -nargs=+ Say echo <q-args>` |

### Placeholders de Argumentos
| Placeholder | Função | Quando Usar |
|-------------|--------|-------------|
| `<args>` | Argumentos como string bruta | Passar para comandos Ex |
| `<q-args>` | Argumentos com quotes apropriadas | Proteção contra espaços |
| `<f-args>` | Argumentos como parâmetros de função | Chamar funções Vim Script |

### Atributos de Range
| Atributo | Comportamento | Variáveis Disponíveis |
|----------|---------------|----------------------|
| `-range` | Aceita range, padrão linha atual | `<line1>`, `<line2>` |
| `-range=%` | Aceita range, padrão arquivo inteiro | `<line1>`, `<line2>` |
| `-range=N` | Contador na posição de linha | `<count>` |
| `-count=N` | Contador como argumento ou linha | `<count>` |

### Tipos de Completion Úteis
| Tipo | Completa | Exemplo de Uso |
|------|----------|----------------|
| `file` | Nomes de arquivo | Comandos de edição |
| `buffer` | Nomes de buffer | Navegação entre buffers |
| `command` | Comandos Ex | Meta-comandos |
| `function` | Nomes de função | Debugging/testing |
| `customlist,Func` | Lista personalizada | Completion específico |

`★ Insight ─────────────────────────────────────`
O `:command!` é uma das funcionalidades mais poderosas do Vim para automação. Diferente de aliases shell, comandos customizados do Vim têm acesso completo ao contexto do editor (buffers, linhas, seleções) e podem implementar lógica complexa através de Vim Script.
`─────────────────────────────────────────────────`