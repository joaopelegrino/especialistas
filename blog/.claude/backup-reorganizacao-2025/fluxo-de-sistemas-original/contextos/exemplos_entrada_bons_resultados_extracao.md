# Exemplos de Extração de Dados - Sistema S.1.1

## Exemplo 1: Conteúdo do Dr. Felipe (Psiquiatra)

**Entrada:**
"boa noite pessoal dr felipe psiquiatra hoje vou falar de um assunto delicado que é uso combinado de medicamentos pra ansiedade e insonia muita gente sofre com os dois problemas ao mesmo tempo e uma coisa acaba piorando a outra vira ciclo vicioso nao dorme direito fica ansioso fica ansioso nao dorme primeira coisa importante fazer exames completos ver se nao tem causa organica depois comeco com protocolo que desenvolvi alprazolam 0.5mg noite pra insonia inicial tomo por 2 semanas se funciona mantenho se nao funciona subo pra 1mg mas nunca mais que isso por causa dependencia junto com alprazolam uso escitalopram 10mg manha pra ansiedade generalizada comeco dose baixa avalio resposta em 15 dias se precisa subo pra 15mg mas muita gente responde bem com 10 se ainda tem insonia resistente acrescento terceiro medicamento mirtazapina 15mg noite esse remedio é interessante porque age no sono e ansiedade mesmo tempo mas nao uso primeira escolha por causa efeito colateral de sonolencia dia seguinte tem paciente que nao tolera bem todas essas medicacoes precisam receita controlada obvio acompanhamento proximo primeira consulta retorno 15 dias depois mensalmente mas resultados sao muito bons 80 por cento dos pacientes melhoram significativamente em 2 meses importante lembrar sempre associar com terapia exercicio fisico meditacao medicacao sozinha nao resolve causa do problema."

**Resultado JSON Esperado:**
```json
{
  "initial_validation_agent": {
    "input_processing": {
      "transcript_metadata": {
        "id": "video_dr_felipe_001",
        "content_type": "medical_advice",
        "source_type": "video_transcription",
        "language": "pt-BR"
      },
      "content_flags": {
        "contains_medical_or_health_advice": true,
        "contains_patient_data": false,
        "contains_prescription": true,
        "contains_controlled_substances": true,
        "urgent_review_needed": true,
        "requires_medical_disclaimer": true
      }
    },
    "participating_professionals": [
      {
        "professional_id": "prof_001",
        "extraction_confidence": "medium",
        "identified_info": {
          "mentioned_name": "Dr. Felipe",
          "mentioned_title": "Dr.",
          "mentioned_specialty": "Psiquiatra",
          "mentioned_credentials": [],
          "mentioned_workplace": "",
          "mentioned_contact": {
            "phone": "",
            "website": "",
            "social_media": []
          }
        },
        "missing_info_form": {
          "required_fields": {
            "professional_id": {
              "field_name": "Número do CRM",
              "priority": "high",
              "reason": "Prescrição de medicamentos controlados",
              "legal_requirement": true
            },
            "full_name": {
              "field_name": "Nome Completo",
              "priority": "high",
              "reason": "Identificação oficial para prescrições",
              "legal_requirement": true
            },
            "specialty_proof": {
              "field_name": "Comprovante de Especialidade em Psiquiatria",
              "priority": "high",
              "reason": "Prescrição de psicotrópicos",
              "legal_requirement": true
            }
          }
        }
      }
    ],
    "prescription_protocol_extraction": {
      "contains_prescriptions": true,
      "prescription_details": [
        {
          "prescription_id": "rx_001",
          "medication_name": "Alprazolam",
          "dosage": "0.5mg",
          "frequency": "noite",
          "duration": "2 semanas inicial",
          "controlled_substance": true,
          "requires_prescription": true,
          "monitoring_required": true
        },
        {
          "prescription_id": "rx_002",
          "medication_name": "Escitalopram",
          "dosage": "10mg",
          "frequency": "manhã",
          "duration": "avaliação em 15 dias",
          "controlled_substance": false,
          "requires_prescription": true
        },
        {
          "prescription_id": "rx_003",
          "medication_name": "Mirtazapina",
          "dosage": "15mg",
          "frequency": "noite",
          "side_effects_mentioned": ["sonolência dia seguinte"],
          "controlled_substance": false,
          "requires_prescription": true
        }
      ],
      "protocols_mentioned": [
        {
          "protocol_id": "prot_001",
          "protocol_name": "Protocolo desenvolvido pelo Dr. Felipe",
          "steps_described": ["exames completos", "alprazolam inicial", "escitalopram", "mirtazapina se resistente"],
          "conditions_applicable": ["ansiedade", "insônia"],
          "evidence_level": "low",
          "source_mentioned": "protocolo próprio"
        }
      ]
    },
    "regulatory_compliance": {
      "required_validations": [
        {
          "validation_type": "professional_license",
          "entity": "Dr. Felipe",
          "urgency": "high",
          "legal_requirement": true
        }
      ],
      "missing_disclaimers": [
        {
          "disclaimer_type": "cfm_general",
          "reason": "Prescrição de medicamentos controlados",
          "suggested_text": "Consulte sempre um médico psiquiatra antes de iniciar qualquer tratamento"
        }
      ],
      "privacy_concerns": [
        {
          "concern_type": "medical_information",
          "severity": "medium",
          "recommended_action": "Adicionar disclaimers sobre individualização do tratamento"
        }
      ]
    }
  }
}
```

## Exemplo 2: Nutricionista com Citações

**Entrada:**
"Olá, sou a Dra. Maria Silva, nutricionista CRN 12345, atendo no consultório da Rua das Flores 123. Hoje vou falar sobre jejum intermitente baseado no protocolo do Dr. Jason Fung, autor do livro 'The Obesity Code'. Segundo estudos da Harvard Medical School, o jejum de 16 horas pode melhorar a sensibilidade à insulina. Tive uma paciente de 35 anos que perdeu 15kg em 3 meses seguindo este protocolo. Meu WhatsApp é 11 99999-9999 para consultas."

**Resultado JSON Esperado:**
```json
{
  "initial_validation_agent": {
    "participating_professionals": [
      {
        "professional_id": "prof_001",
        "extraction_confidence": "high",
        "identified_info": {
          "mentioned_name": "Dra. Maria Silva",
          "mentioned_title": "Dra.",
          "mentioned_specialty": "Nutricionista",
          "mentioned_credentials": ["CRN 12345"],
          "mentioned_workplace": "Consultório Rua das Flores 123",
          "mentioned_contact": {
            "whatsapp": "11 99999-9999",
            "address": "Rua das Flores 123"
          }
        },
        "missing_info_form": {
          "required_fields": {},
          "optional_fields": {
            "additional_credentials": {
              "field_name": "Especializações em Nutrição",
              "priority": "low",
              "reason": "Fortalecer expertise em jejum intermitente"
            }
          }
        }
      }
    ],
    "cited_professionals_institutions": [
      {
        "citation_id": "cite_001",
        "cited_name": "Dr. Jason Fung",
        "citation_type": "professional",
        "citation_context": "Protocolo de jejum intermitente",
        "credibility_level": "high",
        "validation_required": true,
        "cited_work": "The Obesity Code"
      },
      {
        "citation_id": "cite_002",
        "cited_name": "Harvard Medical School",
        "citation_type": "institution",
        "citation_context": "Estudos sobre jejum de 16 horas",
        "credibility_level": "high",
        "validation_required": true
      }
    ],
    "patient_data_extraction": {
      "contains_patient_cases": true,
      "patient_cases": [
        {
          "case_id": "case_001",
          "demographic_data": {
            "age_mentioned": "35 anos",
            "gender_mentioned": "feminino"
          },
          "medical_data": {
            "outcomes_mentioned": ["perdeu 15kg em 3 meses"]
          },
          "sensitivity_level": "medium",
          "requires_anonymization": true
        }
      ]
    },
    "commercial_information": {
      "contains_commercial_info": true,
      "contact_details": {
        "phone_numbers": ["11 99999-9999"],
        "addresses": ["Rua das Flores 123"]
      },
      "service_information": {
        "services_offered": ["consultas nutricionais"],
        "availability": ["WhatsApp para agendamentos"]
      }
    }
  }
}
```