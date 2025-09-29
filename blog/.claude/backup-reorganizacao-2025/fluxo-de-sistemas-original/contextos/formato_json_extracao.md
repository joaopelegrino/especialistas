# Formato JSON para Extração de Dados - Sistema S.1.1

```json
{
  "initial_validation_agent": {
    "input_processing": {
      "transcript_metadata": {
        "id": "identificador_unico_conteudo",
        "date_received": "data_processamento",
        "content_type": "medical_advice|educational_content|patient_testimonial|professional_discussion",
        "source_type": "video_transcription|audio_transcription|text_content",
        "language": "pt-BR|en-US|es-ES",
        "duration_minutes": "duracao_se_aplicavel",
        "word_count": "numero_palavras"
      },
      "content_flags": {
        "contains_medical_or_health_advice": true,
        "contains_patient_data": false,
        "contains_prescription": true,
        "contains_controlled_substances": false,
        "contains_surgical_procedures": false,
        "urgent_review_needed": false,
        "requires_medical_disclaimer": true,
        "requires_legal_review": false
      }
    },
    "participating_professionals": [
      {
        "professional_id": "prof_001",
        "extraction_confidence": "high|medium|low",
        "identified_info": {
          "mentioned_name": "nome_exato_mencionado",
          "mentioned_title": "dr|dra|prof|mestre",
          "mentioned_specialty": "especialidade_declarada",
          "mentioned_credentials": ["crm_numero", "especializacao", "titulo"],
          "mentioned_workplace": "local_trabalho_mencionado",
          "experience_mentioned": "anos_experiencia_se_citado",
          "mentioned_contact": {
            "phone": "telefone_se_mencionado",
            "whatsapp": "whatsapp_se_mencionado",
            "website": "website_se_mencionado",
            "email": "email_se_mencionado",
            "social_media": ["@instagram", "@facebook"],
            "address": "endereco_se_mencionado"
          }
        },
        "missing_info_form": {
          "required_fields": {
            "professional_id": {
              "field_name": "Número do Registro Profissional (CRM/CRP/CRN)",
              "priority": "high",
              "reason": "Validação legal obrigatória",
              "legal_requirement": true
            },
            "full_name": {
              "field_name": "Nome Completo",
              "priority": "high",
              "reason": "Identificação oficial",
              "legal_requirement": true
            },
            "specialty_proof": {
              "field_name": "Comprovante de Especialidade",
              "priority": "medium",
              "reason": "Validação de expertise",
              "legal_requirement": false
            }
          },
          "optional_fields": {
            "additional_credentials": {
              "field_name": "Credenciais Adicionais",
              "priority": "low",
              "reason": "Fortalecer autoridade",
              "legal_requirement": false
            },
            "practice_address": {
              "field_name": "Endereço Completo do Consultório",
              "priority": "medium",
              "reason": "Verificação de atuação",
              "legal_requirement": false
            },
            "insurance_accepted": {
              "field_name": "Convênios Aceitos",
              "priority": "low",
              "reason": "Informação para pacientes",
              "legal_requirement": false
            }
          }
        }
      }
    ],
    "cited_professionals_institutions": [
      {
        "citation_id": "cite_001",
        "cited_name": "nome_instituicao_profissional_citado",
        "citation_type": "professional|institution|study|guideline",
        "citation_context": "contexto_onde_foi_citado",
        "credibility_level": "high|medium|low|unknown",
        "validation_required": true,
        "citation_purpose": "support_claim|provide_reference|establish_authority",
        "mentioned_credentials": ["credencial_1", "credencial_2"],
        "needs_verification": {
          "existence": true,
          "credentials": true,
          "current_position": false,
          "cited_information": true
        }
      }
    ],
    "patient_data_extraction": {
      "contains_patient_cases": true,
      "anonymization_level": "fully_anonymous|partially_anonymous|identifiable",
      "patient_cases": [
        {
          "case_id": "case_001",
          "demographic_data": {
            "age_mentioned": "idade_se_mencionada",
            "gender_mentioned": "genero_se_mencionado",
            "location_mentioned": "localizacao_se_mencionada",
            "occupation_mentioned": "profissao_se_mencionada"
          },
          "medical_data": {
            "conditions_mentioned": ["condicao_1", "condicao_2"],
            "treatments_mentioned": ["tratamento_1", "tratamento_2"],
            "medications_mentioned": ["medicamento_1", "medicamento_2"],
            "outcomes_mentioned": ["resultado_1", "resultado_2"]
          },
          "sensitivity_level": "critical|high|medium|low",
          "privacy_concerns": ["concern_1", "concern_2"],
          "requires_anonymization": true
        }
      ]
    },
    "prescription_protocol_extraction": {
      "contains_prescriptions": true,
      "prescription_details": [
        {
          "prescription_id": "rx_001",
          "medication_name": "nome_medicamento",
          "dosage": "dosagem_especificada",
          "frequency": "frequencia_administracao",
          "duration": "duracao_tratamento",
          "route": "via_administracao",
          "contraindications_mentioned": ["contraindicacao_1"],
          "side_effects_mentioned": ["efeito_colateral_1"],
          "controlled_substance": true,
          "requires_prescription": true,
          "monitoring_required": true
        }
      ],
      "protocols_mentioned": [
        {
          "protocol_id": "prot_001",
          "protocol_name": "nome_protocolo",
          "steps_described": ["passo_1", "passo_2"],
          "conditions_applicable": ["condicao_1"],
          "evidence_level": "high|medium|low",
          "source_mentioned": "fonte_protocolo"
        }
      ]
    },
    "commercial_information": {
      "contains_commercial_info": true,
      "contact_details": {
        "phone_numbers": ["telefone_1", "telefone_2"],
        "addresses": ["endereco_1", "endereco_2"],
        "websites": ["website_1", "website_2"],
        "social_media": ["@perfil_1", "@perfil_2"],
        "email_addresses": ["email_1", "email_2"]
      },
      "service_information": {
        "services_offered": ["servico_1", "servico_2"],
        "pricing_mentioned": ["preco_1", "preco_2"],
        "location_details": ["localizacao_1", "localizacao_2"],
        "availability": ["horario_1", "horario_2"],
        "insurance_accepted": ["convenio_1", "convenio_2"]
      }
    },
    "regulatory_compliance": {
      "required_validations": [
        {
          "validation_type": "professional_license",
          "entity": "nome_profissional",
          "urgency": "high|medium|low",
          "legal_requirement": true
        }
      ],
      "missing_disclaimers": [
        {
          "disclaimer_type": "cfm_general|crp_general|anvisa",
          "reason": "motivo_necessidade",
          "suggested_text": "texto_sugerido"
        }
      ],
      "privacy_concerns": [
        {
          "concern_type": "patient_identification|personal_data|medical_information",
          "severity": "critical|high|medium|low",
          "recommended_action": "acao_recomendada"
        }
      ]
    },
    "quality_assessment": {
      "extraction_confidence": "high|medium|low",
      "completeness_score": "0-100",
      "ambiguous_information": [
        {
          "item": "informacao_ambigua",
          "reason": "motivo_ambiguidade",
          "suggested_clarification": "esclarecimento_sugerido"
        }
      ],
      "review_recommendations": [
        {
          "item": "item_para_revisao",
          "priority": "high|medium|low",
          "action_required": "acao_necessaria"
        }
      ]
    }
  }
}
```