# Formato JSON para Referências - Sistema S.2-1.2

```json
{
  "referencias_encontradas": [
    {
      "afirmacao_id": "af_001",
      "afirmacao_texto": "texto_da_afirmacao_original",
      "referencias_primarias": [
        {
          "titulo": "título_do_estudo",
          "autores": ["autor1", "autor2"],
          "revista": "nome_da_revista",
          "ano": 2023,
          "pmid": "numero_pmid",
          "doi": "doi_do_artigo",
          "url": "link_para_artigo",
          "nivel_evidencia": "I|II|III|IV|V",
          "tipo_estudo": "ensaio_clinico|coorte|caso_controle|revisao|metanalise",
          "resumo_relevante": "resumo_da_parte_relevante",
          "suporte_afirmacao": "total|parcial|contra|neutro"
        }
      ],
      "revisoes_sistematicas": [
        {
          "titulo": "título_da_revisao",
          "autores": ["autor1", "autor2"],
          "revista": "nome_da_revista",
          "ano": 2023,
          "pmid": "numero_pmid",
          "doi": "doi_do_artigo",
          "url": "link_para_artigo",
          "numero_estudos_incluidos": 15,
          "conclusao_principal": "conclusao_da_revisao",
          "suporte_afirmacao": "total|parcial|contra|neutro"
        }
      ],
      "consensos_sociedades": [
        {
          "sociedade": "nome_da_sociedade_medica",
          "documento": "nome_do_consenso",
          "ano": 2023,
          "url": "link_para_documento",
          "recomendacao": "texto_da_recomendacao",
          "nivel_recomendacao": "A|B|C|D",
          "suporte_afirmacao": "total|parcial|contra|neutro"
        }
      ],
      "diretrizes_clinicas": [
        {
          "organizacao": "nome_da_organizacao",
          "titulo": "titulo_da_diretriz",
          "ano": 2023,
          "url": "link_para_diretriz",
          "recomendacao_especifica": "texto_da_recomendacao",
          "grau_recomendacao": "forte|fraca|condicional",
          "suporte_afirmacao": "total|parcial|contra|neutro"
        }
      ],
      "status_validacao": {
        "suporte_geral": "total|parcial|contra|insuficiente",
        "qualidade_evidencia": "alta|moderada|baixa|muito_baixa",
        "recomendacao_uso": "aprovado|aprovado_com_ressalvas|nao_recomendado|necessita_mais_evidencia"
      }
    }
  ],
  "resumo_busca": {
    "total_afirmacoes_analisadas": 0,
    "referencias_encontradas": 0,
    "por_nivel_evidencia": {
      "nivel_I": 0,
      "nivel_II": 0,
      "nivel_III": 0,
      "nivel_IV": 0,
      "nivel_V": 0
    },
    "por_suporte": {
      "total": 0,
      "parcial": 0,
      "contra": 0,
      "neutro": 0
    },
    "bases_consultadas": ["pubmed", "cochrane", "scielo", "lilacs"]
  },
  "alertas_qualidade": [
    {
      "afirmacao_id": "af_001",
      "tipo_alerta": "evidencia_insuficiente|evidencia_contraditoria|necessita_disclaimer",
      "descricao": "descrição_do_alerta",
      "acao_recomendada": "acao_a_ser_tomada"
    }
  ],
  "proximos_passos": {
    "afirmacoes_bem_suportadas": ["af_001", "af_002"],
    "afirmacoes_necessitam_revisao": ["af_003"],
    "afirmacoes_sem_evidencia": ["af_004"],
    "consulta_especialista_necessaria": ["area1", "area2"]
  }
}
```