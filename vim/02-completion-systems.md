# Desvendando os Sistemas de Completion do Vim: Do Básico ao Pro

## Por Que Este Guia Vai Mudar Sua Forma de Codificar?

Se você já se sentiu lento digitando nomes de variáveis longos ou esqueceu o nome exato de uma função, este guia é para você. O Vim possui um sistema de "autocompletar" (completion) nativo que é incrivelmente poderoso, mas muitas vezes subestimado.

Muitos acham que precisam de plugins pesados para ter um bom autocompletar. **Isso é um mito!** O Vim vanilla (sem plugins) oferece ferramentas que, quando dominadas, podem acelerar drasticamente seu fluxo de trabalho.

### O Que Você Vai Aprender

Este guia vai te ensinar, passo a passo, a usar os sistemas de completion nativos do Vim para:
- **Completar palavras, linhas e caminhos de arquivo** com atalhos simples.
- **Ativar um autocompletar "inteligente"** que entende a sua linguagem de programação.
- **Configurar o Vim** para uma experiência de completion moderna e fluida.
- **Automatizar a busca por sugestões** sem esforço manual.

### Como Usar Este Guia

**Para iniciantes:** Comece pelo "Nível 1" e só avance quando se sentir confortável. A prática é a chave!
**Para usuários intermediários:** Revise os básicos e foque nos níveis 2 e 3 para otimizar sua configuração.
**Para referência:** Use os exemplos como um ponto de partida para suas próprias personalizações.

---

## Nível 1: Seus Primeiros "Completes" - O Essencial

### O Que é o Completion Básico?

É a forma mais simples de autocompletar. O Vim olha para as palavras que já existem no seu arquivo e as sugere para você.

**Exemplo prático:**
Você digita `minha_variavel_longa` uma vez. Na próxima vez, você pode digitar `minha_` e o Vim completa o resto.

### Primeiros Passos: Completando Palavras

**Por que fazer isso?**
Para economizar tempo e evitar erros de digitação em nomes de variáveis, funções e palavras comuns.

**Comandos Essenciais (em Modo de Inserção):**
- `Ctrl+n`: **N**ext. Busca a próxima sugestão para frente (do cursor para o fim do arquivo).
- `Ctrl+p`: **P**revious. Busca a sugestão anterior para trás (do cursor para o início do arquivo).

**🎯 Exercício Prático (5 minutos):**
1. Abra um novo arquivo no Vim.
2. Digite o seguinte texto:
   ```
   function calcular_total_de_vendas() {
     // Esta função vai calcular o total.
   }
   ```
3. Em uma nova linha, digite `calc` e pressione `Ctrl+n`.
4. O Vim deve autocompletar para `calcular_total_de_vendas`.
5. Continue pressionando `Ctrl+n` e `Ctrl+p` para ver o Vim alternar entre `calcular_total_de_vendas` e `calcular`.

**💡 Dica de Aprendizado:** Force-se a usar `Ctrl+n` por um dia inteiro em vez de digitar palavras longas. Você vai se surpreender com a rapidez com que o hábito se forma.

---

## Nível 2: A Família `Ctrl+x` - Completion Especializado

### O Que é o Modo `Ctrl+x`?

Depois de digitar `Ctrl+x` no modo de inserção, o Vim entra em um "sub-modo" de completion, esperando um segundo comando para saber *que tipo* de completion você quer.

É como dizer ao Vim: "Prepare-se para completar, e agora eu vou te dizer o que completar."

### Tipos Mais Úteis de Completion Especializado

#### 1. Completion de Linha Inteira (`Ctrl+x Ctrl+l`)

**Para que serve?**
Completa uma linha inteira baseando-se em outras linhas do arquivo. Extremamente útil para código repetitivo.

**Como usar:**
1. Digite o início de uma linha que você já escreveu antes.
2. Pressione `Ctrl+x` seguido de `Ctrl+l`.

**🚀 Exemplo Prático:**
```javascript
console.log("Iniciando o processo...");
// muito código depois...
cons<Ctrl+x><Ctrl+l> 
```
O Vim completará a linha inteira para `console.log("Iniciando o processo...");`.

#### 2. Completion de Caminho de Arquivo (`Ctrl+x Ctrl+f`)

**Para que serve?**
Um dos mais úteis! Ajuda a completar caminhos de arquivos e diretórios do seu sistema. Chega de erros de digitação em imports!

**Como usar:**
1. Digite o início de um caminho (ex: `/home/us...` ou `../src/...`).
2. Pressione `Ctrl+x` seguido de `Ctrl+f`.

**🚀 Exemplo Prático:**
Em um arquivo CSS, para importar uma fonte:
```css
@font-face {
  src: url('../assets/fonts/Robo<Ctrl+x><Ctrl+f>');
}
```
O Vim abrirá um menu com `Roboto-Regular.ttf`, `Roboto-Bold.ttf`, etc.

#### 3. Completion de Dicionário (`Ctrl+x Ctrl+k`)

**Para que serve?**
Sugere palavras de um arquivo de dicionário. Ótimo para escrita técnica e comentários.

**Como configurar (adicione ao seu `~/.vimrc`):**
```vim
" Aponta para um dicionário de palavras. 
" A maioria dos sistemas Linux tem um em /usr/share/dict/words
set dictionary=/usr/share/dict/words 
```

**Como usar:**
1. Digite as primeiras letras de uma palavra em inglês.
2. Pressione `Ctrl+x` seguido de `Ctrl+k`.

#### 4. Completion de Ortografia (`Ctrl+x Ctrl+s`)

**Para que serve?**
Sugere correções para palavras com erros de ortografia.

**Como configurar (execute o comando no Vim):**
```vim
" Ativa a verificação ortográfica em português e inglês
:set spell spelllang=pt_br,en
```

**Como usar:**
1. Digite uma palavra com erro (ex: `receba`).
2. Pressione `Ctrl+x` seguido de `Ctrl+s`. O Vim sugerirá `receba`.

---

## Nível 3: Omni Completion - O Autocompletar Inteligente

### O Que é Omni Completion?

Este é o "game-changer". Omni Completion (`Ctrl+x Ctrl+o`) é um sistema de completion **sensível ao contexto da linguagem**. Ele não apenas completa palavras, mas entende a estrutura do seu código.

**Exemplo:** Em JavaScript, depois de `document.`, ele sugere `getElementById`, `querySelector`, etc. Em Python, depois de `minha_lista.`, ele sugere `append`, `sort`, etc.

### Como Ativar e Usar

O Omni Completion depende de uma configuração chamada `omnifunc`. O Vim já vem com `omnifunc` para muitas linguagens populares (JavaScript, Python, HTML, CSS, etc.).

**O comando (em Modo de Inserção):**
- `Ctrl+x Ctrl+o`: **O**mni completion.

**🎯 Exercício Prático (JavaScript):**
1. Crie um arquivo `teste.js`.
2. Digite `document.getEle` e pressione `Ctrl+x Ctrl+o`.
3. O Vim deve sugerir `getElementById`.

**🎯 Exercício Prático (Python):**
1. Crie um arquivo `teste.py`.
2. Digite:
   ```python
   import os
   os.pa<Ctrl+x><Ctrl+o>
   ```
3. O Vim deve sugerir `path`.

**Por que não funcionou?** Se não funcionou, pode ser que o `omnifunc` não esteja ativado por padrão. Adicione isso ao seu `~/.vimrc` para garantir que ele seja carregado:
```vim
" Adicione ao seu ~/.vimrc
filetype plugin on
```

---

## Nível 4: Configurando Para uma Experiência Moderna

### O Problema: O Comportamento Padrão é "Clunky"

Por padrão, quando você usa `Ctrl+n`, o Vim insere a primeira sugestão diretamente no texto, o que pode ser irritante. O ideal seria ver um menu e escolher a opção desejada.

### A Solução: `completeopt`

A configuração `completeopt` (opções de completion) transforma a experiência.

**Configuração Essencial (adicione ao seu `~/.vimrc`):**
```vim
" Configuração moderna para o menu de completion
set completeopt=menuone,noselect,longest
```

**O que cada opção faz:**
- `menuone`: Sempre mostra o menu, mesmo que haja apenas uma sugestão.
- `noselect`: Mostra o menu, mas **não insere** a primeira sugestão automaticamente. Você escolhe!
- `longest`: Insere o texto mais longo que é comum a todas as opções (opcional, mas útil).

**🚀 Teste a Diferença:**
1. Adicione a linha acima ao seu `.vimrc` e reinicie o Vim (ou use `:source ~/.vimrc`).
2. Repita o exercício do "Nível 1".
3. Agora, ao digitar `calc` e `Ctrl+n`, um menu pop-up aparecerá em vez de inserir o texto diretamente. Você pode navegar com `Ctrl+n`/`Ctrl+p` e pressionar `Enter` para confirmar.

---

## Nível 5: O Próximo Nível (Um Vislumbre do Futuro)

Agora que você domina o sistema nativo, saiba que ele é a base para ferramentas ainda mais poderosas.

#### 1. **Tags (Ctags)**
- **O que é:** Uma ferramenta externa (`ctags`) que escaneia seu projeto e cria um arquivo de "índice" (tags) de todas as suas funções, classes e variáveis.
- **Como o Vim usa:** O completion `Ctrl+x Ctrl+]` usa esse arquivo de tags para oferecer sugestões de todo o seu projeto, não apenas do arquivo atual.

#### 2. **Plugins de Completion (como MuComplete)**
- **O que fazem:** Atuam como um "gerenciador" inteligente para os sistemas nativos do Vim. Em vez de você ter que lembrar de `Ctrl+x Ctrl+l` ou `Ctrl+x Ctrl+f`, o plugin tenta adivinhar o que você quer e aciona o tipo de completion correto automaticamente.

#### 3. **Language Server Protocol (LSP)**
- **O que é:** O padrão moderno para completion em editores como o VS Code. Servidores de linguagem externos analisam seu código e fornecem diagnósticos e completions extremamente precisos.
- **Como o Vim usa:** Plugins como `vim-lsp` ou `coc.nvim` integram esses servidores ao Vim, geralmente usando o sistema de Omni Completion (`omnifunc`) como base.

---

## Sua Jornada de Aprendizado: Um Plano de 4 Semanas

### Semana 1: O Básico Absoluto
- **Meta:** Dominar `Ctrl+n` e `Ctrl+p`.
- **Exercício:** Proíba-se de digitar palavras com mais de 8 caracteres que já existem no arquivo. Use `Ctrl+n` para completá-las.

### Semana 2: Ferramentas Especializadas
- **Meta:** Internalizar `Ctrl+x Ctrl+l` (linhas) e `Ctrl+x Ctrl+f` (arquivos).
- **Exercício:** Ao escrever um `import` ou `require`, use `Ctrl+x Ctrl+f` para completar o caminho. Ao escrever uma linha de log repetida, use `Ctrl+x Ctrl+l`.

### Semana 3: A Experiência Moderna
- **Meta:** Configurar `completeopt` e se acostumar com o menu pop-up.
- **Exercício:** Ative o `completeopt` e use o menu para todas as suas necessidades de completion. Sinta a diferença.

### Semana 4: O Poder do Omni
- **Meta:** Usar `Ctrl+x Ctrl+o` como seu principal completion para código.
- **Exercício:** Em um arquivo Python ou JavaScript, explore as sugestões do Omni Completion para diferentes objetos e módulos.

## Conclusão: Você Já Tem o Superpoder

Você descobriu que o Vim, sem nenhum plugin, já possui um ecossistema de completion robusto e configurável. A produtividade não vem de instalar dezenas de plugins, mas de dominar as ferramentas que já estão ao seu alcance.

**Lembre-se:**
- Comece simples com `Ctrl+n`.
- Adicione `Ctrl+x` para tarefas específicas.
- Use `Ctrl+x Ctrl+o` para um completion inteligente.
- Configure `completeopt` para uma experiência fluida.

A prática deliberada transformará esses atalhos em memória muscular. Em pouco tempo, você estará codificando mais rápido e com mais precisão do que nunca.

**Bem-vindo à verdadeira produtividade do Vim!**
