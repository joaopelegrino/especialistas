# Sistema S.1.1 - Extração e Validação de Dados (Tipo B)

## **Função Específica**
Extração estruturada de dados de profissionais, instituições, pacientes e informações sensíveis presentes em conteúdo médico (texto, áudio, vídeo), organizando-os para validação posterior e compliance LGPD/HIPAA.

## **Texto Base**

```markdown
Você é um sistema especializado na extração e estruturação de dados sensíveis de conteúdo médico.

Analise o seguinte conteúdo:

<conteudo_entrada>
{{documento_entrada}}
</conteudo_entrada>

Considerando as diretrizes de extração:

<diretrizes_extracao>
{{diretrizes_extracao_dados}} - ./contextos/diretrizes_protecao_dados.md
</diretrizes_extracao>

<tipos_dados_sensiveis>
{{tipos_dados_sensiveis_saude}} - ./contextos/tipos_dados_sensiveis_saude.md
</tipos_dados_sensiveis>

Sua resposta deve ser estritamente em formato JSON seguindo esta estrutura:

<formato_json>
{{formato_json_extracao}} - ./contextos/formato_json_extracao.md
</formato_json>

Baseie-se nestes exemplos de extração:

<exemplos_extracao>
{{exemplos_entrada_bons_resultados}} - ./contextos/exemplos_entrada_bons_resultados_extracao.md
</exemplos_extracao>
```

## **Entrada Esperada**
- Conteúdo médico bruto (texto, transcrição de áudio/vídeo)
- Informações de profissionais da saúde
- Dados de pacientes (anonimizados ou identificáveis)
- Prescrições e protocolos médicos

## **Saída Produzida**
- JSON estruturado com extração completa de dados
- Classificação de sensibilidade de informações
- Identificação de dados faltantes para compliance
- Alertas de conformidade regulatória
- Recomendações para validação posterior

## **Tecnologia Utilizada**
- **Tipo B**: IA + Context-Aware Generation
- **Contextos**: Diretrizes LGPD, tipos de dados sensíveis, exemplos práticos
- **Processamento**: Análise estruturada com classificação de risco
- **Compliance**: LGPD/HIPAA integrado

## **Contextos Utilizados**
1. `diretrizes_protecao_dados.md` - Diretrizes de proteção de dados LGPD/HIPAA
2. `tipos_dados_sensiveis_saude.md` - Classificação de dados sensíveis na saúde
3. `formato_json_extracao.md` - Estrutura JSON para saída do sistema
4. `exemplos_entrada_bons_resultados_extracao.md` - Exemplos práticos de extração