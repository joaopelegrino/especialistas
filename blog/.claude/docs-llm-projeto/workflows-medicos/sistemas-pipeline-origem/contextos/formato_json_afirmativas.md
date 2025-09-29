# Formato JSON para Afirmativas - Sistema S.1.2

```json
{
  "content_extraction": {
    "metadata": {
      "content_type": "text|video|audio",
      "professional_info": {
        "name": "nome_identificado_no_conteudo",
        "specialty": "especialidade_mencionada",
        "credentials": "credenciais_citadas",
        "contact": {
          "available_info": {
            "phone": "telefone_se_mencionado",
            "email": "email_se_mencionado",
            "address": "endereco_se_mencionado"
          },
          "missing_info": ["dados_nao_encontrados"]
        }
      },
      "content_context": {
        "publication_date": "data_se_mencionada",
        "target_audience": "publico_alvo_identificado",
        "content_purpose": "proposito_do_conteudo"
      }
    },
    "claims_for_verification": [
      {
        "claim_id": "C001",
        "raw_statement": "afirmacao_exata_do_texto",
        "context": "contexto_paragrafo_onde_aparece",
        "category": "eficacia_tratamento|condicao_medica|estatistica|recomendacao|contraindicacao|efeito_colateral",
        "search_requirements": {
          "core_concept": "conceito_central_da_afirmacao",
          "key_terms": ["termo_principal_1", "termo_principal_2"],
          "related_terms": ["termo_relacionado_1", "termo_relacionado_2"],
          "exclusion_terms": ["termo_exclusao_1", "termo_exclusao_2"],
          "population_mentioned": ["populacao_especifica_se_mencionada"],
          "timeframe_mentioned": "periodo_especifico_se_mencionado",
          "dosage_mentioned": "dosagem_se_mencionada",
          "duration_mentioned": "duracao_se_mencionada"
        },
        "advanced_search_strategy": {
          "primary_search_string": "string_busca_primaria_formatada",
          "secondary_search_string": "string_busca_secundaria_alternativa",
          "boolean_operators": "operadores_booleanos_utilizados",
          "proximity_operators": "operadores_proximidade_se_aplicavel",
          "truncation_strategy": "estrategia_truncamento",
          "database_priority": ["pubmed", "cochrane", "embase"],
          "publication_types": ["randomized_controlled_trial", "systematic_review"],
          "language_filters": ["english", "portuguese", "spanish"],
          "date_range": "periodo_busca_sugerido"
        },
        "evidence_requirements": {
          "minimum_evidence_level": "metanalise|revisao_sistematica|ensaio_clinico|estudo_observacional",
          "required_study_types": ["tipo_estudo_1", "tipo_estudo_2"],
          "minimum_sample_size": "tamanho_amostra_minimo_se_aplicavel",
          "required_outcomes": ["desfecho_primario", "desfecho_secundario"],
          "quality_criteria": ["criterio_qualidade_1", "criterio_qualidade_2"]
        },
        "risk_analysis": {
          "potential_risks_mentioned": ["risco_mencionado_1", "risco_mencionado_2"],
          "safety_claims_made": ["afirmacao_seguranca_1", "afirmacao_seguranca_2"],
          "contraindications_mentioned": ["contraindicacao_1", "contraindicacao_2"],
          "priority_level": "critica|alta|media|baixa",
          "urgency_justification": "justificativa_nivel_urgencia"
        }
      }
    ],
    "recommendations_made": [
      {
        "recommendation_id": "R001",
        "statement": "recomendacao_exata_do_texto",
        "target_population": "populacao_alvo_da_recomendacao",
        "context": "contexto_onde_foi_feita",
        "requires_verification": true,
        "search_terms": ["termo_busca_1", "termo_busca_2"],
        "evidence_level_needed": "nivel_evidencia_necessario",
        "professional_scope": "area_competencia_profissional"
      }
    ]
  },
  "search_preparation": {
    "priority_claims": [
      {
        "claim_id": "C001",
        "priority_reason": "motivo_priorizacao",
        "urgency_level": "critica|alta|media|baixa"
      }
    ],
    "suggested_search_strings": [
      {
        "claim_id": "C001",
        "primary_string": "string_busca_primaria_completa",
        "alternative_strings": ["string_alternativa_1", "string_alternativa_2"],
        "database_specific": {
          "pubmed": "string_otimizada_pubmed",
          "cochrane": "string_otimizada_cochrane",
          "embase": "string_otimizada_embase"
        },
        "filters_recommended": {
          "publication_types": ["tipo_publicacao_1", "tipo_publicacao_2"],
          "study_characteristics": ["caracteristica_1", "caracteristica_2"],
          "temporal_filters": "filtros_temporais",
          "language_filters": ["idioma_1", "idioma_2"]
        }
      }
    ],
    "required_validations": [
      {
        "claim_id": "C001",
        "validation_type": "eficacia|seguranca|prevalencia|mecanismo_acao",
        "minimum_evidence_level": "nivel_evidencia_minimo",
        "expected_sources": ["fonte_esperada_1", "fonte_esperada_2"],
        "quality_thresholds": {
          "journal_impact_factor": "fator_impacto_minimo",
          "sample_size": "tamanho_amostra_minimo",
          "study_duration": "duracao_estudo_minima"
        }
      }
    ]
  },
  "disclaimer_requirements": {
    "cfm_general": true,
    "cfm_specialized": false,
    "crp_general": false,
    "crp_specialized": false,
    "anvisa": false,
    "custom_disclaimers": [
      {
        "claim_id": "C001",
        "disclaimer_type": "tipo_disclaimer_especifico",
        "disclaimer_text": "texto_disclaimer_personalizado"
      }
    ]
  },
  "quality_control": {
    "extraction_confidence": "alta|media|baixa",
    "ambiguous_claims": ["claim_id_ambiguo_1", "claim_id_ambiguo_2"],
    "missing_context": ["claim_id_contexto_insuficiente"],
    "review_recommendations": [
      {
        "item": "item_para_revisao",
        "reason": "motivo_revisao",
        "suggested_action": "acao_sugerida"
      }
    ]
  }
}
```