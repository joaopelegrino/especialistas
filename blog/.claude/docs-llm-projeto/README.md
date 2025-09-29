# 📚 Documentação Específica do Projeto - Healthcare CMS Blog

<!-- DSM:DOMAIN:healthcare|projeto_especifico COMPLEXITY:expert DEPS:cross_referenced -->
<!-- DSM:HEALTHCARE:cms_implementation|blog_platform DEPS:wordpress_parity -->
<!-- DSM:PERFORMANCE:knowledge_retrieval:<2s accuracy:95%+ compliance:100% -->
<!-- DSM:COMPLIANCE:LGPD|CFM|ANVISA|Zero_Trust_NIST_SP_800_207 -->

## 🧩 DSM Knowledge Matrix - Projeto Específico
```yaml
DSM_PROJETO_MATRIX:
  depends_on:
    - healthcare_cms_architecture
    - elixir_phoenix_implementation
    - zero_trust_security_patterns
    - medical_workflow_s1_1_to_s4_1_1_3
  provides_to:
    - healthcare_blog_platform
    - medical_content_management
    - professional_validation_system
    - compliance_automation_tools
  integrates_with:
    - wordpress_core_features
    - acf_custom_fields_system
    - webassembly_plugin_architecture
    - medical_professional_workflows
  performance_contracts:
    - cms_response_time: "<50ms p95 for all operations"
    - concurrent_users: "2M+ supported healthcare professionals"
    - medical_workflow: "<5min total pipeline S.1.1→S.4-1.1-3"
  compliance_requirements:
    - lgpd_data_protection: "All healthcare data handling documented"
    - cfm_medical_validation: "Professional content approval workflows"
    - anvisa_software_compliance: "Medical device software standards"
```

## Organização do Conhecimento Específico do Projeto

Esta documentação consolida todo o conhecimento específico do **Healthcare CMS Blog** seguindo a metodologia **Dependency Structure Matrix (DSM)** para consulta eficiente durante o desenvolvimento e manutenção da plataforma.

---

## 📁 Estrutura de Diretórios

### 🏥 [implementacao/](./implementacao/)
Documentação da implementação real do projeto
- **[healthcare-cms/](./implementacao/healthcare-cms/)** - Implementação do CMS Healthcare
  - [`arquitetura-sistema.md`](./implementacao/healthcare-cms/arquitetura-sistema.md) - Arquitetura geral do sistema
  - [`database-schemas.md`](./implementacao/healthcare-cms/database-schemas.md) - Esquemas de banco de dados
  - [`api-endpoints.md`](./implementacao/healthcare-cms/api-endpoints.md) - Documentação das APIs
  - [`security-implementation.md`](./implementacao/healthcare-cms/security-implementation.md) - Implementação de segurança

### 📋 [requisitos/](./requisitos/)
PRDs e especificações técnicas do projeto
- **[prd-healthcare-cms/](./requisitos/prd-healthcare-cms/)** - Product Requirements Documents
  - [`prd-agnostico-stack-research.md`](./requisitos/prd-healthcare-cms/prd-agnostico-stack-research.md) - PRD principal do projeto
  - [`requisitos-funcionais.md`](./requisitos/prd-healthcare-cms/requisitos-funcionais.md) - Requisitos funcionais detalhados
  - [`requisitos-nao-funcionais.md`](./requisitos/prd-healthcare-cms/requisitos-nao-funcionais.md) - Performance e compliance

### 🔬 [workflows-medicos/](./workflows-medicos/)
Fluxos específicos para área da saúde
- **[sistemas-pipeline/](./workflows-medicos/sistemas-pipeline/)** - Pipeline médico S.1.1→S.4-1.1-3
  - [`s1-1-extracao-validacao-dados.md`](./workflows-medicos/sistemas-pipeline/s1-1-extracao-validacao-dados.md) - Sistema de extração LGPD
  - [`s1-2-levantamento-afirmativas.md`](./workflows-medicos/sistemas-pipeline/s1-2-levantamento-afirmativas.md) - Levantamento de claims médicos
  - [`s2-1-2-busca-referencias.md`](./workflows-medicos/sistemas-pipeline/s2-1-2-busca-referencias.md) - Busca científica automatizada
  - [`s3-2-seo-perfil-especialista.md`](./workflows-medicos/sistemas-pipeline/s3-2-seo-perfil-especialista.md) - SEO para profissionais
  - [`s4-1-1-3-texto-final.md`](./workflows-medicos/sistemas-pipeline/s4-1-1-3-texto-final.md) - Geração de conteúdo final

### 📊 [relatorios/](./relatorios/)
Documentação de progresso e análises
- **[progresso-implementacao/](./relatorios/progresso-implementacao/)** - Relatórios de implementação
  - [`status-desenvolvimento.md`](./relatorios/progresso-implementacao/status-desenvolvimento.md) - Status atual do desenvolvimento
  - [`metricas-qualidade.md`](./relatorios/progresso-implementacao/metricas-qualidade.md) - Métricas de qualidade e coverage
  - [`roadmap-implementacao.md`](./relatorios/progresso-implementacao/roadmap-implementacao.md) - Roadmap detalhado

### 🛠️ [configuracoes/](./configuracoes/)
Configurações e setup do projeto
- **[ambiente-desenvolvimento/](./configuracoes/ambiente-desenvolvimento/)** - Setup de desenvolvimento
  - [`elixir-phoenix-setup.md`](./configuracoes/ambiente-desenvolvimento/elixir-phoenix-setup.md) - Configuração Elixir/Phoenix
  - [`database-configuration.md`](./configuracoes/ambiente-desenvolvimento/database-configuration.md) - Configuração de banco de dados
  - [`testing-environment.md`](./configuracoes/ambiente-desenvolvimento/testing-environment.md) - Ambiente de testes

### 🏛️ [arquitetura/](./arquitetura/)
Documentação arquitetural específica
- **[decisoes-tecnicas/](./arquitetura/decisoes-tecnicas/)** - ADRs e decisões arquiteturais
  - [`adr-001-escolha-stack.md`](./arquitetura/decisoes-tecnicas/adr-001-escolha-stack.md) - Decisão da stack tecnológica
  - [`adr-002-zero-trust-architecture.md`](./arquitetura/decisoes-tecnicas/adr-002-zero-trust-architecture.md) - Arquitetura Zero Trust
  - [`adr-003-webassembly-plugins.md`](./arquitetura/decisoes-tecnicas/adr-003-webassembly-plugins.md) - Plugins WebAssembly

---

## 🎯 Casos de Uso por Área Específica do Projeto

### Para Desenvolvimento do Healthcare CMS
1. **Implementação Base:** [`arquitetura-sistema.md`](./implementacao/healthcare-cms/arquitetura-sistema.md)
2. **Banco de Dados:** [`database-schemas.md`](./implementacao/healthcare-cms/database-schemas.md)
3. **APIs Healthcare:** [`api-endpoints.md`](./implementacao/healthcare-cms/api-endpoints.md)

### Para Workflows Médicos
1. **Pipeline Completo:** [`sistemas-pipeline/`](./workflows-medicos/sistemas-pipeline/)
2. **LGPD Compliance:** [`s1-1-extracao-validacao-dados.md`](./workflows-medicos/sistemas-pipeline/s1-1-extracao-validacao-dados.md)
3. **Validação Científica:** [`s2-1-2-busca-referencias.md`](./workflows-medicos/sistemas-pipeline/s2-1-2-busca-referencias.md)

### Para Acompanhamento de Progresso
1. **Status Atual:** [`status-desenvolvimento.md`](./relatorios/progresso-implementacao/status-desenvolvimento.md)
2. **Métricas:** [`metricas-qualidade.md`](./relatorios/progresso-implementacao/metricas-qualidade.md)
3. **Roadmap:** [`roadmap-implementacao.md`](./relatorios/progresso-implementacao/roadmap-implementacao.md)

---

## 🔍 Quick Search por Tópicos do Projeto

### WordPress Parity
- **Core Features:** WP-F001 a WP-F010 implementados
- **ACF Compatibility:** ACF-F001 a ACF-F006 com extensões healthcare
- **Admin Interface:** Phoenix LiveView dashboards

### Healthcare Extensions
- **Professional Validation:** CRM/CRP integration
- **Medical Workflows:** S.1.1→S.4-1.1-3 pipeline
- **Compliance:** LGPD/CFM/ANVISA automation

### Security Implementation
- **Zero Trust:** NIST SP 800-207 compliance
- **Post-Quantum:** CRYSTALS-Kyber/Dilithium
- **Multi-tenant:** Admin blind architecture

---

## 📈 Roadmap de Consulta Específico do Projeto

### Para Novos Desenvolvedores:
1. **Arquitetura:** Revisar [`arquitetura-sistema.md`](./implementacao/healthcare-cms/arquitetura-sistema.md)
2. **Setup:** Seguir [`elixir-phoenix-setup.md`](./configuracoes/ambiente-desenvolvimento/elixir-phoenix-setup.md)
3. **Workflows:** Entender pipeline em [`sistemas-pipeline/`](./workflows-medicos/sistemas-pipeline/)
4. **Status:** Verificar [`status-desenvolvimento.md`](./relatorios/progresso-implementacao/status-desenvolvimento.md)

### Para Manutenção e Evolução:
1. **Requisitos:** Consultar [`prd-agnostico-stack-research.md`](./requisitos/prd-healthcare-cms/prd-agnostico-stack-research.md)
2. **Decisões:** Revisar ADRs em [`decisoes-tecnicas/`](./arquitetura/decisoes-tecnicas/)
3. **Métricas:** Monitorar [`metricas-qualidade.md`](./relatorios/progresso-implementacao/metricas-qualidade.md)
4. **Roadmap:** Acompanhar [`roadmap-implementacao.md`](./relatorios/progresso-implementacao/roadmap-implementacao.md)

---

*Última atualização: 29 de Setembro de 2025*
*Organização otimizada para consulta durante desenvolvimento do Healthcare CMS Blog*