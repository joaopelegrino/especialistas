# Workflow Eficiente para Edição de Tags `<>` em Markdown

**Documento:** 11-workflow-edicao-tags-markdown.md
**Data:** 2025-09-30
**Contexto:** Otimização de edição de tags XML/HTML em arquivos Markdown usando vim-surround

---

## 📋 Sumário Executivo

Este documento apresenta uma análise completa das ferramentas disponíveis e propõe melhorias específicas para otimizar a edição de tags `<>` em arquivos Markdown, uma tarefa frequente no workflow de documentação.

**Ganhos de Eficiência Esperados:**
- **70-90%** redução de digitação comparado ao método manual
- **40-60%** redução comparado ao vim-surround básico
- Operações de 2-3 teclas para tarefas que levavam 20+ teclas

---

## ✅ Ferramentas Atuais Disponíveis

### 1. vim-surround (Instalado - vimrc:34)

Plugin poderoso para manipulação de pares (parênteses, aspas, tags XML/HTML).

#### Comandos Nativos Básicos

**IMPORTANTE - Sintaxe Correta:**
- Digite o comando COMPLETO em sequência contínua, SEM pressionar Enter no meio
- Exemplo: `ysiw<tarefa>` deve ser digitado como: y-s-i-w-<-t-a-r-e-f-a->(Enter)
- Se pressionar Enter antes de fechar `>`, insere `^M` literal ao invés da tag

**Adicionar Tags em Palavras/Frases:**
```vim
ysiw<tag>           " Adiciona <tag> em palavra sob cursor
                    " Digite: y s i w < t a g > (Enter)

ys3aw<tarefa>       " Adiciona <tarefa> em 3 palavras
                    " Digite: y s 3 a w < t a r e f a > (Enter)

yss<praticas>       " Adiciona <praticas> em linha inteira
                    " Digite: y s s < p r a t i c a s > (Enter)

vS<conceito>        " Em visual mode, envolve seleção com <conceito>
                    " Digite: v (selecione) S < c o n c e i t o > (Enter)
```

**Mudar Tags Existentes:**
```vim
cst<novo>           " Change Surrounding Tag para <novo>
                    " Digite: c s t < n o v o > (Enter)
                    " Cursor pode estar em qualquer lugar dentro da tag

cst                 " Remove tag, mantém conteúdo
                    " Digite: c s t (sem tag, apenas Enter)

cs<antigo><novo>    " Muda delimitador específico (não comum para tags)
```

**Deletar Tags:**
```vim
dst                 " Delete Surrounding Tag (mantém conteúdo)
                    " Digite: d s t
                    " Remove par de tags mais interno

ds<                 " Remove apenas delimitadores <> (não tags completas)
```

**Recurso Avançado - Preservação de Atributos:**
```vim
" De: <tarefa status="pending">item</tarefa>
cst<conceito>       " Para: <conceito status="pending">item</conceito>
                    " Digite: c s t < c o n c e i t o > (Enter)
```

**NOTA CRÍTICA:** vim-surround preserva atributos automaticamente quando você muda tags. Não há opção especial - funciona sempre.

### 2. Emmet-vim (Instalado - vimrc:41)

**Configuração Atual (vimrc:128):**
```vim
autocmd FileType html,css,javascript,jsx,vue EmmetInstall
```

**Status:** Configurado para HTML/CSS/JavaScript, mas **não ativo para markdown**.

**Potencial:** Emmet pode acelerar drasticamente criação de estruturas de tags.

### 3. Visual Mode + Text Objects (Nativo Vim)

Seleção eficiente de conteúdo dentro/ao redor de tags.

```vim
vit                 " Visual Inner Tag (seleciona conteúdo)
vat                 " Visual Around Tag (seleciona tag + conteúdo)
cit                 " Change Inner Tag
dit                 " Delete Inner Tag
```

---

## 🚀 Workflows Otimizados por Cenário

### Cenário 1: Adicionar Tags em Palavras/Frases Existentes

#### Método Operator (Rápido)
```vim
# Cursor em "importante"
ysiw<critical>      " Resultado: <critical>importante</critical>
                    " DIGITE: y s i w < c r i t i c a l > Enter
                    " NÃO pressione Enter antes de fechar >

# Para múltiplas palavras
ys3w<conceito>      " Envolve 3 palavras com <conceito>
                    " DIGITE: y s 3 w < c o n c e i t o > Enter

# Para linha inteira
yss<tarefa>         " Envolve linha com <tarefa>
                    " DIGITE: y s s < t a r e f a > Enter
```

#### Método Visual (Intuitivo)
```vim
# Selecione texto visualmente primeiro
viw                 " Seleciona palavra
V                   " Seleciona linha
S<tag>              " Envolve seleção com <tag>
                    " DIGITE: S < t a g > Enter (após seleção visual)
```

**Recomendação:** Método visual é mais intuitivo para iniciantes, pois você VÊ o que está selecionando antes de aplicar a tag. Método operator é mais rápido quando você domina os text objects.

**ARMADILHA COMUM:** Se você digitar `ysiw<tag` e pressionar Enter antes do `>`, o vim insere literalmente o caractere ^M (carriage return) ao invés da tag. A sequência COMPLETA deve ser digitada antes de pressionar Enter final.

### Cenário 2: Editar Tags Existentes

#### Workflow Extremamente Eficiente
```vim
# Cursor em qualquer lugar dentro de <old>texto</old>
cst<new>            " Muda para <new>texto</new>
                    " DIGITE: c s t < n e w > Enter

# Preservar atributos (automático)
# De: <tarefa status="pending">item</tarefa>
cst<conceito>       " Para: <conceito status="pending">item</conceito>
                    " DIGITE: c s t < c o n c e i t o > Enter
                    " Atributos são SEMPRE preservados automaticamente
```

**Insight:** O comando `cst` (change surrounding tag) funciona de qualquer posição dentro da tag - não precisa estar exatamente no início ou fim.

**CORREÇÃO:** Ao contrário do que foi afirmado anteriormente, NÃO há sintaxe especial para preservar atributos. O vim-surround SEMPRE preserva atributos quando você muda tags - é o comportamento padrão.

### Cenário 3: Remover Tags Mantendo Conteúdo

```vim
# De: <tag>conteúdo importante</tag>
dst                 " Para: conteúdo importante
```

### Cenário 4: Edição em Massa de Tags

**Usando Macros + vim-surround:**
```vim
qa                  " Inicia gravação de macro no registro 'a'
cst<nova>           " Muda tag
/\<old\><CR>        " Busca próxima ocorrência
q                   " Para gravação
100@a               " Executa macro 100 vezes
```

---

## 💡 Melhorias Propostas

### Melhoria 1: Ativar Emmet para Markdown

**Mudança no vimrc:128**

**Antes:**
```vim
autocmd FileType html,css,javascript,jsx,vue EmmetInstall
```

**Depois:**
```vim
autocmd FileType html,css,javascript,jsx,vue,markdown EmmetInstall
```

**Benefícios:**
- Criação rápida de estruturas de tags
- Expansão automática de abreviações

**Uso no Insert Mode:**
```vim
tarefa>conteudo<C-e>,    " Expande para: <tarefa>conteudo</tarefa>
praticas<C-e>,           " Expande para: <praticas></praticas>
```

### Melhoria 2: Adicionar vim-repeat

**Adicionar ao vimrc na seção de plugins:**
```vim
Plug 'tpope/vim-repeat'
```

**Benefício:** Permite usar `.` (repeat) com comandos do vim-surround.

**Uso:**
```vim
cst<nova>           " Muda primeira tag
.                   " Repete operação na próxima tag
.                   " Repete novamente
```

**Impacto:** Transforma edição de múltiplas tags de processo tedioso em sequência rápida de `.` (ponto).

### Melhoria 3: Key Bindings Personalizados para Tags Comuns

**Adicionar ao vimrc (após linha 300):**

```vim
" ========================================
" Tag Editing Shortcuts for Markdown
" ========================================

" Normal mode - adiciona tags em palavra sob cursor
nnoremap <leader>tt ysiw<tarefa><Esc>
nnoremap <leader>tp ysiw<praticas><Esc>
nnoremap <leader>tc ysiw<conceito><Esc>
nnoremap <leader>tn ysiw<nota><Esc>

" Visual mode - adiciona tags em seleção
vnoremap <leader>tt S<tarefa><Esc>
vnoremap <leader>tp S<praticas><Esc>
vnoremap <leader>tc S<conceito><Esc>
vnoremap <leader>tn S<nota><Esc>

" Remoção rápida de tag
nnoremap <leader>td dst

" Trocar tag interativamente (usa função)
nnoremap <leader>ct :call ChangeTagInteractive()<CR>
```

**Uso Prático:**
```vim
" Cursor em "importante"
<leader>tc          " Resultado: <conceito>importante</conceito>

" Selecione 3 palavras visualmente
v3w<leader>tt       " Envolve seleção com <tarefa>
```

### Melhoria 4: Função para Trocar Tags Rapidamente

**Adicionar ao vimrc (após linha 400):**

```vim
" ========================================
" Interactive Tag Change Function
" ========================================
function! ChangeTagInteractive()
    let new_tag = input('Nova tag: ')
    if !empty(new_tag)
        execute 'normal cst<' . new_tag . '>'
    endif
endfunction
```

**Uso:**
```vim
# Cursor dentro de <antiga>texto</antiga>
<leader>ct          " Abre prompt
[Digite: nova]      " Nova tag: nova
[Enter]             " Resultado: <nova>texto</nova>
```

**Benefício:** Evita digitar comandos longos quando você precisa trocar tags frequentemente.

### Melhoria 5: Snippets para Tags Estruturadas

**Adicionar ao `/home/notebook/config/vim/vsnip/markdown.json`:**

```json
{
  "existing_snippets": "...",

  "tarefa_tag": {
    "prefix": "<tar",
    "body": "<tarefa>$1</tarefa>$0",
    "description": "Tag tarefa completa"
  },
  "praticas_tag": {
    "prefix": "<pra",
    "body": "<praticas>$1</praticas>$0",
    "description": "Tag praticas completa"
  },
  "conceito_tag": {
    "prefix": "<con",
    "body": "<conceito>$1</conceito>$0",
    "description": "Tag conceito completa"
  },
  "nota_tag": {
    "prefix": "<not",
    "body": "<nota>$1</nota>$0",
    "description": "Tag nota completa"
  },
  "sessao_tag": {
    "prefix": "<ses",
    "body": "<sessao>\n\n$1\n\n</sessao>$0",
    "description": "Tag sessao com quebras de linha"
  }
}
```

**Uso no Insert Mode:**
```vim
<tar<Tab>           " Expande para: <tarefa>|</tarefa>
                    " (cursor no |, use Tab para pular para final)
```

---

## 📊 Comparativo de Eficiência

| Tarefa | Método Manual | vim-surround | Com Melhorias |
|--------|---------------|--------------|---------------|
| **Adicionar tag em palavra** | `i<tag>Esc ea</tag>Esc` (18 teclas) | `ysiw<tag>` (10 teclas) | `<leader>tt` (2 teclas) |
| **Mudar tag existente** | Delete manual + redigitar (25+ teclas) | `cst<novo>` (9 teclas) | `<leader>ct` + nome (5+ teclas) |
| **Remover tag** | Delete manual (20+ teclas) | `dst` (3 teclas) | `<leader>td` (2 teclas) |
| **Tag em 5 palavras** | Manual + contagem (30+ teclas) | `ys5w<tag>` (11 teclas) | `v5w<leader>tt` (6 teclas) |
| **10 tags iguais** | Manual repetido (180+ teclas) | `cst<nova>` + 9x busca (60+ teclas) | `cst<nova>` + 9x `.` (12 teclas) |

**Conclusão:** As melhorias propostas reduzem digitação em:
- **70-90%** comparado ao método manual
- **40-60%** comparado ao vim-surround puro

---

## 🎯 Plano de Implementação

### Fase 1: Melhorias Imediatas (5 minutos)

1. **Ativar Emmet para Markdown** (Melhoria 1)
   - Editar vimrc:128
   - Adicionar `markdown` à lista de filetypes

2. **Key Bindings Básicos** (Parte da Melhoria 3)
   - Adicionar atalhos `<leader>tt`, `<leader>tp`, `<leader>tc`
   - Testar em arquivo markdown

### Fase 2: Funcionalidades Avançadas (10 minutos)

3. **Adicionar vim-repeat** (Melhoria 2)
   - Adicionar linha no vimrc plugins
   - Executar `:PlugInstall`

4. **Função Interativa** (Melhoria 4)
   - Adicionar função `ChangeTagInteractive()`
   - Testar com `<leader>ct`

### Fase 3: Snippets Especializados (5 minutos)

5. **Snippets de Tags** (Melhoria 5)
   - Editar `/home/notebook/config/vim/vsnip/markdown.json`
   - Adicionar snippets `<tar`, `<pra`, `<con`, etc.

**Tempo Total:** ~20 minutos
**Impacto:** Transformação completa do workflow de edição de tags

---

## 📚 Comandos de Referência Rápida

### vim-surround Essenciais

```vim
" ADICIONAR
ysiw<tag>           " Tag em palavra
ys3w<tag>           " Tag em 3 palavras
yss<tag>            " Tag em linha inteira
vS<tag>             " Tag em seleção visual

" MUDAR
cst<novo>           " Trocar tag
cst                 " Remover tag (mantém conteúdo)

" DELETAR
dst                 " Remover tag
ds<                 " Remover delimitadores <>

" COM MELHORIAS
<leader>tt          " Tag <tarefa> rápida
<leader>tp          " Tag <praticas> rápida
<leader>tc          " Tag <conceito> rápida
<leader>ct          " Trocar tag interativamente
<leader>td          " Remover tag rápida
.                   " Repetir última operação (requer vim-repeat)
```

### Text Objects Úteis

```vim
it                  " Inner Tag (conteúdo da tag)
at                  " Around Tag (tag + conteúdo)
iw                  " Inner Word
aw                  " Around Word
i"                  " Inner Quotes
a"                  " Around Quotes
```

### Emmet em Markdown

```vim
" No Insert Mode
tarefa<C-e>,        " Expande: <tarefa></tarefa>
tarefa>texto<C-e>,  " Expande: <tarefa>texto</tarefa>
```

### Snippets

```vim
" No Insert Mode
<tar<Tab>           " <tarefa>|</tarefa>
<pra<Tab>           " <praticas>|</praticas>
<con<Tab>           " <conceito>|</conceito>
```

---

## 🔍 Troubleshooting

### Problema: vim-surround não funciona

**Solução:**
```vim
:PlugStatus         " Verificar se plugin está instalado
:PlugInstall        " Instalar se necessário
```

### Problema: Emmet não funciona em Markdown

**Causa:** FileType não configurado para markdown
**Solução:** Verificar se melhoria 1 foi aplicada no vimrc:128

### Problema: Snippets não expandem

**Causa:** Caminho do vsnip incorreto
**Verificar vimrc:146:**
```vim
let g:vsnip_snippet_dir = expand('/home/notebook/config/vim/vsnip')
```

### Problema: Key bindings não funcionam

**Causa:** Conflito com outros mappings
**Debug:**
```vim
:verbose map <leader>tt    " Mostra quem mapeou a tecla
```

---

## 📖 Recursos Adicionais

### Documentação Oficial

- **vim-surround:** `:help surround`
- **Emmet:** `:help emmet`
- **vim-vsnip:** `:help vsnip`
- **Text Objects:** `:help text-objects`

### Arquivos de Configuração

- **vimrc principal:** `/home/notebook/config/vimrc`
- **Snippets markdown:** `/home/notebook/config/vim/vsnip/markdown.json`
- **Plugins instalados:** `~/.vim/plugged/`

### Comandos Úteis

```vim
:PlugStatus         " Status dos plugins
:PlugUpdate         " Atualizar plugins
:source ~/.vimrc    " Recarregar configuração
:VsnipOpen          " Editar snippets do filetype atual
```

---

## 🎓 Curva de Aprendizado

### Nível 1: Iniciante (Dia 1-3)

**Foco:** Comandos básicos do vim-surround
- Pratique `ysiw<tag>` e `dst` até se tornar automático
- Use método visual (`viwS<tag>`) enquanto aprende
- Memorize 3 atalhos: `<leader>tt`, `<leader>tp`, `<leader>tc`

### Nível 2: Intermediário (Semana 1-2)

**Foco:** Text objects e edição avançada
- Domine `cst<novo>` para trocar tags rapidamente
- Aprenda contadores: `ys3w<tag>`, `ys$<tag>`
- Combine com busca: `/palavra` → `ysiw<tag>` → `n.n.n.`

### Nível 3: Avançado (Mês 1+)

**Foco:** Macros e automação
- Crie macros para padrões repetitivos
- Combine com vim-repeat para eficiência máxima
- Personalize snippets para suas tags mais comuns

---

## ✅ Checklist de Implementação

Marque conforme implementa as melhorias:

```markdown
- [ ] Melhoria 1: Emmet ativado para Markdown
- [ ] Melhoria 2: vim-repeat instalado e testado
- [ ] Melhoria 3: Key bindings adicionados ao vimrc
- [ ] Melhoria 4: Função ChangeTagInteractive() implementada
- [ ] Melhoria 5: Snippets de tags criados em markdown.json
- [ ] Teste: Adicionar tag em palavra com <leader>tt
- [ ] Teste: Trocar tag com cst<novo>
- [ ] Teste: Remover tag com dst
- [ ] Teste: Repetir operação com . (requer vim-repeat)
- [ ] Teste: Expandir snippet <tar<Tab>
- [ ] Documentação: Adicionar anotações pessoais de uso
```

---

## 📝 Conclusão

Este documento apresenta um sistema completo para edição eficiente de tags em Markdown, aproveitando ferramentas já instaladas (vim-surround) e propondo melhorias incrementais que multiplicam a produtividade.

**Principais Benefícios:**
1. ✅ Redução de 70-90% na digitação para operações comuns
2. ✅ Workflows intuitivos para todos os níveis de experiência
3. ✅ Melhorias implementáveis em ~20 minutos
4. ✅ Escalável para padrões específicos do projeto

**Próximos Passos:**
1. Implementar Fase 1 (melhorias imediatas)
2. Praticar comandos básicos por 3 dias
3. Implementar Fases 2 e 3 conforme ganhar confiança
4. Personalizar snippets para tags específicas do seu workflow

---

**Autor:** Claude Code
**Versão:** 1.0
**Última Atualização:** 2025-09-30