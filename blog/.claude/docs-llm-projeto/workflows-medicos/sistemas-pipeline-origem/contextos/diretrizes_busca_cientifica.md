# Diretrizes de Pesquisa Científica Avançada

## 1. Estrutura de Termos de Busca

### Conceito Central
- **Definição**: Termo principal da afirmação a ser verificada
- **Exemplo**: "jejum prolongado" para afirmação sobre jejum intermitente
- **Variações**: Incluir sinônimos e termos técnicos equivalentes

### Termos-Chave Primários
- **Critério**: Termos essenciais que DEVEM aparecer nos resultados
- **Formato**: Utilizar aspas para frases exatas
- **Exemplo**: "intermittent fasting", "caloric restriction"

### Termos-Chave Secundários
- **Critério**: Termos que melhoram a precisão da busca
- **Uso**: Combinação com operadores booleanos
- **Exemplo**: "weight loss", "metabolic health", "autophagy"

### Termos de Exclusão
- **Critério**: Termos que podem gerar resultados irrelevantes
- **Operador**: Usar "-" ou "NOT"
- **Exemplo**: "-supplement" (para excluir estudos sobre suplementos)

## 2. Operadores Booleanos Avançados

### Operadores Básicos
- **AND**: Conecta termos obrigatórios
- **OR**: Conecta termos alternativos
- **NOT**: Exclui termos indesejados

### Operadores de Proximidade
- **NEAR/n**: Termos próximos (n = número de palavras)
- **ADJ/n**: Termos adjacentes
- **W/n**: Termos dentro de n palavras

### Operadores de Truncamento
- **\***: Truncamento à direita (diab* = diabetes, diabetic)
- **?**: Substitui um caractere (wom?n = woman, women)
- **#**: Substitui zero ou um caractere

## 3. Estratégias por Tipo de Afirmação

### Eficácia de Tratamento
```
Estrutura: [TRATAMENTO] AND [CONDIÇÃO] AND [OUTCOME]
Exemplo: "phototherapy" AND "acne" AND ("improvement" OR "reduction")
Filtros: Clinical trials, Systematic reviews, Meta-analyses
Timeframe: Últimos 10 anos
```

### Estatísticas de Saúde
```
Estrutura: [CONDIÇÃO] AND [POPULAÇÃO] AND ("prevalence" OR "incidence" OR "epidemiology")
Exemplo: "depression" AND "adolescents" AND "prevalence"
Filtros: Population studies, Cross-sectional studies
Timeframe: Últimos 5 anos
```

### Efeitos Colaterais
```
Estrutura: [TRATAMENTO] AND ("side effects" OR "adverse events" OR "complications")
Exemplo: "retinoids" AND ("side effects" OR "adverse events")
Filtros: Case reports, Adverse event studies
Timeframe: Todos os anos
```

### Contraindicações
```
Estrutura: [TRATAMENTO] AND ("contraindications" OR "precautions" OR "warnings")
Exemplo: "isotretinoin" AND ("contraindications" OR "pregnancy")
Filtros: Clinical guidelines, Safety reports
Timeframe: Últimos 15 anos
```

## 4. Bases de Dados Especializadas

### Primárias
- **PubMed/MEDLINE**: Medicina geral
- **Cochrane Library**: Revisões sistemáticas
- **Embase**: Biomedicina e farmacologia
- **PsycINFO**: Psicologia e psiquiatria

### Secundárias
- **SciELO**: Literatura latino-americana
- **LILACS**: Literatura científica da América Latina
- **Google Scholar**: Acesso amplo (usar com filtros)
- **ClinicalTrials.gov**: Ensaios clínicos

### Especializadas
- **Dermatology Online Journal**: Dermatologia
- **Nutrition Reviews**: Nutrição
- **Psychological Medicine**: Psicologia clínica
- **Journal of Clinical Medicine**: Medicina clínica

## 5. Filtros de Qualidade

### Tipos de Estudo (Hierarquia de Evidência)
1. **Metanálises e Revisões Sistemáticas**
2. **Ensaios Clínicos Randomizados**
3. **Estudos de Coorte**
4. **Estudos Caso-Controle**
5. **Séries de Casos**
6. **Relatos de Caso**

### Critérios de Inclusão
- **Fator de Impacto**: Journals com JIF > 1.0
- **Peer Review**: Apenas artigos revisados por pares
- **Idioma**: Inglês, português, espanhol
- **Texto Completo**: Disponível gratuitamente ou via instituição

### Critérios de Exclusão
- **Predatory Journals**: Verificar lista Beall's
- **Conflitos de Interesse**: Avaliar fontes de financiamento
- **Metodologia**: Estudos com metodologia inadequada
- **Relevância**: Estudos não relacionados ao contexto clínico

## 6. Strings de Busca Avançada

### Template Básico
```
("termo exato" OR sinônimo OR variação) AND 
("população específica" OR "grupo etário") AND 
("outcome principal" OR "desfecho secundário") AND 
("tipo de estudo"[Publication Type])
```

### Exemplo Prático: Jejum Intermitente
```
("intermittent fasting" OR "time-restricted eating" OR "periodic fasting") AND 
("weight loss" OR "metabolic health" OR "insulin sensitivity") AND 
("randomized controlled trial"[Publication Type] OR "systematic review"[Publication Type]) AND 
("humans"[MeSH Terms]) AND 
("english"[Language]) AND 
("2019/01/01"[Date - Publication] : "2024/12/31"[Date - Publication])
```

### Exemplo Prático: Tratamento Acne
```
("acne vulgaris" OR "acne treatment") AND 
("topical retinoids" OR "benzoyl peroxide" OR "antibiotics") AND 
("efficacy" OR "effectiveness" OR "treatment outcome") AND 
("clinical trial"[Publication Type] OR "comparative study"[Publication Type]) AND 
("adolescent"[MeSH Terms] OR "young adult"[MeSH Terms])
```

## 7. Estratégias de Refinamento

### Primeira Busca (Ampla)
- Usar termos gerais
- Incluir sinônimos principais
- Aplicar filtros básicos

### Segunda Busca (Específica)
- Adicionar termos específicos
- Aplicar filtros de qualidade
- Focar em tipos de estudo relevantes

### Terceira Busca (Direcionada)
- Usar termos técnicos precisos
- Aplicar filtros restritivos
- Focar em journals de alto impacto

## 8. Validação de Resultados

### Critérios de Relevância
- **Título**: Relacionado diretamente à afirmação
- **Resumo**: Confirma relevância do conteúdo
- **Metodologia**: Adequada para o tipo de afirmação
- **Resultados**: Conclusivos e significativos

### Critérios de Qualidade
- **Amostra**: Tamanho adequado e representativo
- **Método**: Rigor científico apropriado
- **Análise**: Estatística adequada
- **Conclusões**: Baseadas nos dados apresentados

### Critérios de Aplicabilidade
- **População**: Similar ao contexto da afirmação
- **Intervenção**: Comparável à mencionada
- **Contexto**: Aplicável à realidade clínica
- **Temporalidade**: Atual e relevante