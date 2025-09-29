# Sistema S.3-2 - SEO + Perfil Especialista (Tipo B)

## **Função Específica**
Otimização do conteúdo para SEO especializado na área da saúde, incorporando perfil profissional, palavras-chave específicas e estrutura otimizada para motores de busca.

## **Texto Base**

```markdown
Você é um sistema especializado em otimização SEO para conteúdo médico e de saúde.

Recebeu o seguinte conteúdo validado cientificamente:

<conteudo_validado>
{{texto_com_referencias}}
</conteudo_validado>

Perfil do profissional:

<perfil_profissional>
{{perfil_especialista}} - ./contextos/perfil_especialista.md
</perfil_profissional>

Palavras-chave do nicho:

<palavras_chave_nicho>
{{keywords_especializadas}} - ./contextos/keywords_especializadas.md
</palavras_chave_nicho>

Sua função é otimizar o conteúdo para SEO, mantendo:
1. Autoridade médica do profissional
2. Densidade adequada de palavras-chave
3. Estrutura otimizada (títulos, subtítulos, listas)
4. Meta descriptions e tags apropriadas
5. Schema markup para conteúdo médico
6. Links internos e externos estratégicos

Retorne o resultado em formato JSON seguindo esta estrutura:

<formato_json>
{{formato_json_seo}} - ./contextos/formato_json_seo.md
</formato_json>
```

## **Entrada Esperada**
- Conteúdo validado cientificamente do Sistema S.2-1.2
- Referências científicas incorporadas
- Dados do profissional estruturados

## **Saída Produzida**
- JSON com conteúdo otimizado para SEO
- Estrutura HTML com tags apropriadas
- Schema markup para conteúdo médico
- Links estratégicos internos e externos
- Métricas de otimização esperadas

## **Tecnologia Utilizada**
- **Tipo B**: IA + Context-Aware Generation
- **Contextos**: Perfil profissional, palavras-chave especializadas
- **Otimização**: SEO local + autoridade médica
- **Estrutura**: HTML semântico + schema markup

## **Contextos Utilizados**
1. `perfil_especialista.md` - Template dinâmico do perfil profissional
2. `keywords_especializadas.md` - Palavras-chave especializadas por área médica
3. `formato_json_seo.md` - Estrutura JSON para conteúdo otimizado SEO