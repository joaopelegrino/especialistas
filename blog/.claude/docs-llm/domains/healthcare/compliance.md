# 🏥 Healthcare Compliance - LGPD, ANVISA, CFM

**Trigger**: "médico", "healthcare", "paciente", "LGPD", "ANVISA" | **Tokens**: ~200 linhas

---

## 🛡️ **Stakeholder Protection Framework**

### **PROTECTIVE Primeiro, Helpful Segundo**
```yaml
Validation_Order_Healthcare:
  1. PHI_PII_Protection: "Dados de pacientes protegidos sempre"
  2. LGPD_Compliance: "Lei Geral de Proteção de Dados"
  3. ANVISA_Requirements: "Regulamentação de software médico"
  4. CFM_Ethics: "Diretrizes éticas profissionais"
  5. Implementation: "Funcionalidades após validação"
```

**REGRA ABSOLUTA**: Nunca implementar funcionalidade médica sem validação completa de compliance primeiro.

---

## ⚖️ **LGPD - Lei Geral de Proteção de Dados**

### **Princípios Fundamentais**
```yaml
LGPD_Core_Principles:
  finalidade: "Dados coletados apenas para propósito específico médico"
  adequacao: "Tratamento compatível com finalidades clínicas"
  necessidade: "Mínimo de dados necessários para atendimento"
  livre_acesso: "Paciente acessa seus dados facilmente"
  qualidade_dados: "Dados exatos, claros, relevantes, atualizados"
  transparencia: "Informações claras sobre tratamento de dados"
  seguranca: "Medidas técnicas e administrativas adequadas"
  prevencao: "Medidas preventivas para evitar danos"
  nao_discriminacao: "Tratamento não pode gerar discriminação"
  responsabilizacao: "Demonstrar cumprimento das normas"
```

### **Implementação LGPD Técnica**
```python
# lgpd_compliance.py - Framework LGPD para sistemas médicos
from datetime import datetime, timedelta
import hashlib
import json

class LGPDCompliance:
    """Framework de compliance LGPD para sistemas médicos."""

    def __init__(self):
        self.audit_log = []
        self.consent_records = {}
        self.data_retention_policy = 365  # dias

    def registrar_consentimento(self, paciente_id, finalidade, dados_coletados):
        """Registra consentimento do paciente conforme LGPD."""
        consent_record = {
            'paciente_id': self.hash_identifier(paciente_id),
            'timestamp': datetime.now().isoformat(),
            'finalidade': finalidade,
            'dados_coletados': dados_coletados,
            'consentimento_explícito': True,
            'pode_revogar': True,
            'base_legal': 'consentimento_art_7_inc_I'
        }

        self.consent_records[paciente_id] = consent_record
        self.audit_log.append({
            'acao': 'consentimento_registrado',
            'timestamp': datetime.now().isoformat(),
            'detalhes': consent_record
        })

        return consent_record

    def verificar_base_legal(self, operacao, dados_tipo):
        """Verifica base legal para operação com dados pessoais."""
        bases_legais_medicas = {
            'tratamento_saude': 'art_11_inc_II',  # Tutela da saúde
            'pesquisa_medica': 'art_13_inc_II',  # Pesquisa por órgão de pesquisa
            'emergencia_medica': 'art_7_inc_IV',  # Proteção da vida
            'prontuario_medico': 'art_11_inc_I'   # Cuidados de saúde
        }

        return bases_legais_medicas.get(operacao, 'consentimento_necessario')

    def aplicar_anonimizacao(self, dados_paciente):
        """Aplica técnicas de anonimização conforme LGPD."""
        dados_anonimizados = dados_paciente.copy()

        # Campos que devem ser anonimizados
        campos_pii = ['nome', 'cpf', 'rg', 'endereco', 'telefone', 'email']

        for campo in campos_pii:
            if campo in dados_anonimizados:
                dados_anonimizados[campo] = self.hash_identifier(
                    dados_anonimizados[campo]
                )

        return dados_anonimizados

    def hash_identifier(self, identifier):
        """Gera hash irreversível para identificadores."""
        return hashlib.sha256(str(identifier).encode()).hexdigest()[:12]

    def gerar_relatorio_compliance(self):
        """Gera relatório de compliance LGPD."""
        return {
            'total_consentimentos': len(self.consent_records),
            'audit_events': len(self.audit_log),
            'data_retention_policy': f"{self.data_retention_policy} dias",
            'last_compliance_check': datetime.now().isoformat()
        }
```

---

## 🏛️ **ANVISA - Agência Nacional de Vigilância Sanitária**

### **Classificação de Software Médico**
```yaml
ANVISA_Software_Classification:
  classe_i:
    risco: "Baixo risco"
    exemplos: "Software de agendamento, prontuário básico"
    requisitos: "Registro simplificado"

  classe_iia:
    risco: "Médio risco"
    exemplos: "Software de diagnóstico por imagem"
    requisitos: "Registro regular + documentação técnica"

  classe_iib:
    risco: "Alto risco"
    exemplos: "Software de suporte à decisão clínica"
    requisitos: "Registro + estudos clínicos"

  classe_iii:
    risco: "Muito alto risco"
    exemplos: "Software que controla dispositivos de suporte à vida"
    requisitos: "Registro + estudos clínicos extensivos"
```

### **Requisitos Técnicos ANVISA**
```python
# anvisa_compliance.py - Framework compliance ANVISA
class ANVISACompliance:
    """Framework de compliance ANVISA para software médico."""

    def __init__(self, classe_software):
        self.classe = classe_software
        self.validation_results = {}
        self.documentation = {}

    def validar_funcionalidade_clinica(self, funcionalidade):
        """Valida funcionalidade clínica conforme ANVISA."""
        validations = {
            'precisao_clinica': self.verificar_precisao_clinica(funcionalidade),
            'seguranca_paciente': self.verificar_seguranca_paciente(funcionalidade),
            'rastreabilidade': self.verificar_rastreabilidade(funcionalidade),
            'documentacao_tecnica': self.verificar_documentacao(funcionalidade)
        }

        self.validation_results[funcionalidade] = validations
        return all(validations.values())

    def verificar_precisao_clinica(self, funcionalidade):
        """Verifica precisão clínica da funcionalidade."""
        # Implementar validação específica da funcionalidade
        # Ex: algoritmos de diagnóstico devem ter precisão > 95%
        return True  # Placeholder

    def verificar_seguranca_paciente(self, funcionalidade):
        """Verifica se funcionalidade não compromete segurança do paciente."""
        checks_seguranca = [
            'validacao_entrada_dados',
            'tratamento_erros_clinicos',
            'alertas_seguranca',
            'backup_dados_criticos'
        ]

        return all(self.implementar_check(check) for check in checks_seguranca)

    def gerar_documentacao_anvisa(self):
        """Gera documentação técnica para submissão ANVISA."""
        return {
            'identificacao_software': {
                'nome': 'Sistema Médico XYZ',
                'versao': '1.0.0',
                'classe_risco': self.classe,
                'finalidade_clinica': 'Prontuário eletrônico'
            },
            'especificacoes_tecnicas': {
                'arquitetura': 'Web-based',
                'seguranca': 'Criptografia AES-256',
                'backup': 'Automático diário',
                'auditoria': 'Log completo de ações'
            },
            'validacao_clinica': self.validation_results,
            'gestao_riscos': {
                'matriz_riscos': 'Documentada',
                'plano_mitigacao': 'Implementado',
                'monitoramento_pos_mercado': 'Ativo'
            }
        }
```

---

## ⚕️ **CFM - Conselho Federal de Medicina**

### **Diretrizes Éticas CFM**
```yaml
CFM_Ethical_Guidelines:
  resolucao_2314_2022:
    telemedicina:
      - "Consentimento informado obrigatório"
      - "Prontuário médico completo"
      - "Prescrição médica eletrônica válida"
      - "Responsabilidade médica mantida"

  resolucao_2227_2018:
    prontuario_eletronico:
      - "Assinatura digital ICP-Brasil"
      - "Backup e recuperação garantidos"
      - "Auditoria de acesso completa"
      - "Integridade dos dados assegurada"

  resolucao_2217_2018:
    codigo_etica_medica:
      - "Sigilo médico absoluto"
      - "Autonomia do paciente respeitada"
      - "Beneficência e não maleficência"
      - "Justiça no acesso aos cuidados"
```

### **Implementação Compliance CFM**
```python
# cfm_compliance.py - Framework compliance CFM
import digital_signature
from datetime import datetime

class CFMCompliance:
    """Framework de compliance CFM para sistemas médicos."""

    def __init__(self):
        self.audit_trail = []
        self.ethical_validations = {}

    def validar_assinatura_digital(self, documento_medico, crm_medico):
        """Valida assinatura digital conforme CFM."""
        validations = {
            'certificado_icp_brasil': self.verificar_certificado_icp(crm_medico),
            'validade_certificado': self.verificar_validade_certificado(crm_medico),
            'integridade_documento': self.verificar_integridade(documento_medico),
            'autenticidade_medico': self.verificar_crm_ativo(crm_medico)
        }

        return all(validations.values())

    def implementar_sigilo_medico(self, dados_paciente, medico_solicitante):
        """Implementa controles de sigilo médico conforme CFM."""
        controls = {
            'acesso_autorizado': self.verificar_relacao_medico_paciente(
                medico_solicitante, dados_paciente['id']
            ),
            'log_acesso': self.registrar_acesso_dados(
                medico_solicitante, dados_paciente['id']
            ),
            'criptografia': self.aplicar_criptografia_dados(dados_paciente),
            'auditoria': self.audit_data_access(medico_solicitante, dados_paciente)
        }

        return all(controls.values())

    def validar_telemedicina(self, consulta_dados):
        """Valida consulta de telemedicina conforme Resolução CFM 2314/2022."""
        validations = {
            'consentimento_informado': consulta_dados.get('consentimento_explicito'),
            'identificacao_medico': self.verificar_crm_ativo(consulta_dados['crm_medico']),
            'identificacao_paciente': self.verificar_identidade_paciente(consulta_dados),
            'prontuario_completo': self.verificar_prontuario_atualizado(consulta_dados),
            'tecnologia_adequada': self.verificar_qualidade_conexao(consulta_dados)
        }

        if not all(validations.values()):
            return False, "Consulta não atende requisitos CFM para telemedicina"

        return True, "Consulta válida conforme CFM"

    def gerar_relatorio_etico(self):
        """Gera relatório de compliance ético CFM."""
        return {
            'total_validacoes_eticas': len(self.ethical_validations),
            'consultas_telemedicina_validadas': self.count_telemedicine_validations(),
            'assinaturas_digitais_verificadas': self.count_digital_signatures(),
            'violacoes_sigilo_detectadas': self.count_privacy_violations(),
            'conformidade_geral': self.calculate_overall_compliance()
        }
```

---

## 🔐 **Framework Integrado de Compliance**

### **Validação Integrada LGPD + ANVISA + CFM**
```python
# compliance_integrado.py - Framework compliance integrado
class ComplianceIntegrado:
    """Framework integrado de compliance para sistemas médicos."""

    def __init__(self):
        self.lgpd = LGPDCompliance()
        self.anvisa = ANVISACompliance('classe_iia')
        self.cfm = CFMCompliance()

    def validacao_completa_sistema(self, funcionalidade_medica):
        """Executa validação completa de compliance."""
        print("🔍 Iniciando validação integrada de compliance...")

        # 1. Validação LGPD (proteção de dados)
        lgpd_ok = self.validar_lgpd(funcionalidade_medica)
        print(f"📋 LGPD: {'✅ Conforme' if lgpd_ok else '❌ Não conforme'}")

        # 2. Validação ANVISA (segurança médica)
        anvisa_ok = self.validar_anvisa(funcionalidade_medica)
        print(f"🏛️ ANVISA: {'✅ Conforme' if anvisa_ok else '❌ Não conforme'}")

        # 3. Validação CFM (ética médica)
        cfm_ok = self.validar_cfm(funcionalidade_medica)
        print(f"⚕️ CFM: {'✅ Conforme' if cfm_ok else '❌ Não conforme'}")

        # Resultado final
        compliance_total = lgpd_ok and anvisa_ok and cfm_ok

        if compliance_total:
            print("🎉 Sistema TOTALMENTE CONFORME para uso médico")
            return True
        else:
            print("⚠️ Sistema NÃO CONFORME - correções necessárias")
            return False

    def gerar_certificado_compliance(self):
        """Gera certificado de compliance integrado."""
        if self.validacao_completa_sistema("sistema_completo"):
            return {
                'certificado_compliance': True,
                'timestamp': datetime.now().isoformat(),
                'frameworks_validados': ['LGPD', 'ANVISA', 'CFM'],
                'validade': '1 ano',
                'proxima_auditoria': (datetime.now() + timedelta(days=90)).isoformat()
            }
        return None
```

---

## 📋 **Checklist de Implementação Healthcare**

### **Pré-Implementação (PROTECTIVE)**
```yaml
Pre_Implementation_Checklist:
  lgpd_validation:
    - [ ] Base legal identificada e documentada
    - [ ] Consentimento explícito implementado
    - [ ] Política de retenção de dados definida
    - [ ] Anonimização/pseudonimização implementada
    - [ ] Direitos do titular implementados

  anvisa_validation:
    - [ ] Classe de risco do software identificada
    - [ ] Documentação técnica completa
    - [ ] Validação clínica (se aplicável)
    - [ ] Gestão de riscos implementada
    - [ ] Plano de vigilância pós-mercado

  cfm_validation:
    - [ ] Assinatura digital ICP-Brasil configurada
    - [ ] Controles de sigilo médico implementados
    - [ ] Auditoria de acesso configurada
    - [ ] Backup e recuperação testados
    - [ ] Conformidade ética validada
```

### **Pós-Implementação (HELPFUL)**
```yaml
Post_Implementation_Monitoring:
  continuous_compliance:
    - [ ] Monitoramento LGPD automático
    - [ ] Auditorias ANVISA programadas
    - [ ] Validação ética CFM contínua
    - [ ] Relatórios de compliance mensais
    - [ ] Training da equipe atualizado

  incident_response:
    - [ ] Plano de resposta à incidentes LGPD
    - [ ] Protocolo de notificação ANVISA
    - [ ] Procedimentos de violação ética CFM
    - [ ] Comunicação com autoridades definida
```

---

**🏥 Healthcare Compliance Framework garante PROTECTIVE validation primeiro através de LGPD, ANVISA, e CFM compliance integrado, permitindo implementação segura de sistemas médicos com proteção total dos stakeholders.**