# 📋 Diário do Especialista - MCP Healthcare Protocol

<!-- DSM:DOMAIN:integration|ai_protocol COMPLEXITY:expert DEPS:mcp_server -->
<!-- DSM:HEALTHCARE:clinical_decision_support|fhir_integration|mcp_tools|scientific_validation -->
<!-- DSM:PERFORMANCE:api_response:<50ms tool_execution:<30s healthcare_sla:real_time -->
<!-- DSM:COMPLIANCE:HIPAA|LGPD|FHIR_R4|clinical_validation|cfm_crp_integration -->

## 🧩 DSM Dependency Matrix
```yaml
DSM_MATRIX:
  depends_on:
    - mcp_sdk_typescript
    - elixir_host_platform
    - pubmed_eutils_api
    - fhir_r4_validator
    - lgpd_compliance_engine
  provides_to:
    - healthcare_content_pipeline
    - scientific_research_tools
    - compliance_validation_system
    - medical_knowledge_base
  integrates_with:
    - extism_wasm_plugins
    - zero_trust_policy_engine
    - postgresql_healthcare_schemas
  performance_contracts:
    - mcp_cycle_latency: "<100ms"
    - concurrent_tools: "10+ simultaneous"
    - throughput: "1000 requests/min"
  compliance_requirements:
    - fhir_r4_validation: "mandatory"
    - lgpd_risk_analysis: "real_time"
    - scientific_citation: "evidence_based"
```

## 📍 Quick Access Index
- [Configuração MCP Server](#configuracao-mcp-server)
- [Healthcare Tools Específicos](#healthcare-tools-especificos)
- [Integração FHIR R4](#integracao-fhir-r4)
- [LGPD Risk Analyzer Tool](#lgpd-risk-analyzer-tool)
- [Scientific Search Integration](#scientific-search-integration)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Performance Benchmarks](#performance-benchmarks)

---

## 🎯 Visão Geral Técnica

### Context & Purpose
O Model Context Protocol (MCP) é um protocolo aberto padronizado pela Anthropic que permite que sistemas de IA acessem fontes de dados externas através de uma interface padrão. Na nossa stack WASM-Elixir Healthcare, o MCP serve como ponte entre o Elixir host e os dados médicos especializados, científicos e de compliance.

### Core Architecture
```elixir
# config/config.exs
config :healthcare_platform, HealthcareWeb.MCP,
  server_uri: "stdio://healthcare_mcp_server",
  tools: [
    "lgpd_risk_analyzer",
    "pubmed_search_tool",
    "fhir_validator",
    "medical_claims_extractor",
    "scientific_reference_manager"
  ],
  security_mode: :zero_trust,
  encryption: :pqc_enabled
```

---

## 🔧 Configuração MCP Server {#configuracao-mcp-server}

### 1. Healthcare MCP Server Setup
```typescript
// healthcare_mcp_server/src/index.ts
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool
} from '@modelcontextprotocol/sdk/types.js';

class HealthcareMCPServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: 'healthcare-mcp-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
          resources: {
            subscribe: true,
            listChanged: true
          }
        },
      }
    );

    this.setupHealthcareTools();
    this.setupSecurityMiddleware();
  }

  private setupHealthcareTools() {
    // LGPD Risk Analyzer Tool
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'lgpd_risk_analyzer',
            description: 'Analyzes text for LGPD compliance risks and PII/PHI detection',
            inputSchema: {
              type: 'object',
              properties: {
                content: {
                  type: 'string',
                  description: 'Medical content to analyze for LGPD risks'
                },
                specialty: {
                  type: 'string',
                  description: 'Medical specialty context for risk assessment'
                },
                patient_context: {
                  type: 'boolean',
                  description: 'Whether content contains potential patient data'
                }
              },
              required: ['content']
            }
          },
          {
            name: 'pubmed_search_tool',
            description: 'Searches PubMed for scientific references with healthcare-specific filters',
            inputSchema: {
              type: 'object',
              properties: {
                query: { type: 'string' },
                filters: {
                  type: 'object',
                  properties: {
                    publication_types: { type: 'array', items: { type: 'string' } },
                    years: { type: 'string' },
                    languages: { type: 'array', items: { type: 'string' } }
                  }
                },
                max_results: { type: 'number', default: 20 }
              },
              required: ['query']
            }
          }
        ]
      };
    });
  }

  private setupSecurityMiddleware() {
    // Zero Trust validation middleware
    this.server.use(async (req, res, next) => {
      const securityHeaders = {
        'X-Healthcare-Context': 'true',
        'X-LGPD-Compliant': 'true',
        'X-Zero-Trust-Validated': 'true'
      };

      // Validate request source and apply PQC encryption
      const isValid = await this.validateZeroTrustAccess(req);
      if (!isValid) {
        throw new Error('Zero Trust validation failed');
      }

      next();
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Healthcare MCP Server started');
  }
}

const server = new HealthcareMCPServer();
server.start().catch(console.error);
```

### 2. Elixir Client Integration
```elixir
# lib/healthcare_web/mcp/client.ex
defmodule HealthcareWeb.MCP.Client do
  use GenServer
  require Logger

  @mcp_server_path "healthcare_mcp_server/dist/index.js"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, pid} = :exec.run_link(~c"node #{@mcp_server_path}", [
      :stdin, :stdout, :stderr,
      {:env, [{'NODE_ENV', 'production'}, {'HEALTHCARE_MODE', 'true'}]}
    ])

    state = %{
      mcp_pid: pid,
      request_id: 0,
      pending_requests: %{}
    }

    {:ok, state}
  end

  def analyze_lgpd_risks(content, specialty \\ nil) do
    request = %{
      "jsonrpc" => "2.0",
      "id" => generate_request_id(),
      "method" => "tools/call",
      "params" => %{
        "name" => "lgpd_risk_analyzer",
        "arguments" => %{
          "content" => content,
          "specialty" => specialty,
          "patient_context" => contains_patient_indicators?(content)
        }
      }
    }

    GenServer.call(__MODULE__, {:mcp_request, request}, 30_000)
  end

  def search_pubmed(query, filters \\ %{}) do
    request = %{
      "jsonrpc" => "2.0",
      "id" => generate_request_id(),
      "method" => "tools/call",
      "params" => %{
        "name" => "pubmed_search_tool",
        "arguments" => %{
          "query" => query,
          "filters" => filters,
          "max_results" => 20
        }
      }
    }

    GenServer.call(__MODULE__, {:mcp_request, request}, 60_000)
  end

  def handle_call({:mcp_request, request}, from, state) do
    request_json = Jason.encode!(request)

    # Send request to MCP server via stdin
    :exec.send(state.mcp_pid, request_json <> "\n")

    # Store pending request
    new_state = %{
      state |
      pending_requests: Map.put(state.pending_requests, request["id"], from)
    }

    {:noreply, new_state}
  end

  def handle_info({:stdout, _pid, data}, state) do
    # Parse MCP response and handle accordingly
    case Jason.decode(data) do
      {:ok, %{"id" => request_id, "result" => result}} ->
        case Map.pop(state.pending_requests, request_id) do
          {nil, _} ->
            Logger.warn("Received response for unknown request: #{request_id}")
            {:noreply, state}
          {from, pending} ->
            GenServer.reply(from, {:ok, result})
            {:noreply, %{state | pending_requests: pending}}
        end

      {:ok, %{"error" => error}} ->
        Logger.error("MCP error: #{inspect(error)}")
        {:noreply, state}

      {:error, _} ->
        Logger.error("Failed to parse MCP response: #{data}")
        {:noreply, state}
    end
  end

  defp contains_patient_indicators?(content) do
    patient_indicators = [
      ~r/paciente/i,
      ~r/prontuário/i,
      ~r/cpf/i,
      ~r/rg\s+\d/i,
      ~r/data\s+nascimento/i,
      ~r/endereço/i,
      ~r/telefone/i
    ]

    Enum.any?(patient_indicators, &Regex.match?(&1, content))
  end

  defp generate_request_id, do: System.system_time(:nanosecond)
end
```

---

## 🏥 Healthcare Tools Específicos {#healthcare-tools-especificos}

### 1. LGPD Risk Analyzer Tool Implementation
```typescript
// healthcare_mcp_server/src/tools/lgpd-analyzer.ts
import { Tool } from '@modelcontextprotocol/sdk/types.js';

export class LGPDRiskAnalyzer implements Tool {
  async execute(params: any) {
    const { content, specialty, patient_context } = params;

    // PII/PHI Detection Patterns
    const piiPatterns = {
      cpf: /\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b/g,
      rg: /\b\d{1,2}\.?\d{3}\.?\d{3}-?[\dX]\b/g,
      phone: /\b\(?[1-9]{2}\)?\s?9?\d{4}-?\d{4}\b/g,
      email: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g,
      medical_record: /\bprontu[aá]rio\s*n?[º°]?\s*\d+/gi,
      birth_date: /\b\d{1,2}\/\d{1,2}\/\d{4}\b/g
    };

    // Professional Data Patterns
    const professionalPatterns = {
      crm: /\bcrm\s*[a-z]{2}\s*\d+/gi,
      specialization: this.getSpecializationPatterns(specialty),
      institution: /hospital|clínica|consultório|upa|sus/gi
    };

    const riskAssessment = {
      pii_detected: {},
      phi_detected: {},
      professional_data: {},
      risk_score: 0,
      recommendations: [],
      lgpd_compliance_issues: []
    };

    // Scan for PII
    for (const [type, pattern] of Object.entries(piiPatterns)) {
      const matches = content.match(pattern);
      if (matches) {
        riskAssessment.pii_detected[type] = {
          count: matches.length,
          examples: matches.slice(0, 3).map(m => this.maskSensitiveData(m))
        };
        riskAssessment.risk_score += this.getRiskWeight(type);
      }
    }

    // Healthcare-specific risk analysis
    if (patient_context) {
      riskAssessment.risk_score += 30; // Patient context increases base risk
      riskAssessment.recommendations.push(
        "Conteúdo contém contexto de paciente - aplicar anonimização obrigatória"
      );
    }

    // LGPD Compliance Validation
    const complianceIssues = this.validateLGPDCompliance(content, riskAssessment);
    riskAssessment.lgpd_compliance_issues = complianceIssues;

    // Generate dynamic form suggestions for data collection consent
    riskAssessment.consent_form_suggestions = this.generateConsentFormFields(
      riskAssessment.pii_detected
    );

    return {
      ...riskAssessment,
      risk_level: this.calculateRiskLevel(riskAssessment.risk_score),
      processing_timestamp: new Date().toISOString(),
      compliance_status: complianceIssues.length === 0 ? 'COMPLIANT' : 'REQUIRES_ACTION'
    };
  }

  private getSpecializationPatterns(specialty?: string) {
    const patterns = {
      cardiology: /cardiolog|coração|pressão|hipertensão/gi,
      dermatology: /dermatolog|pele|acne|melanoma/gi,
      pediatrics: /pediatr|criança|infantil|vacina/gi,
      general: /clínic[ao]\s+geral|médic[ao]\s+família/gi
    };

    return specialty ? patterns[specialty] || patterns.general : patterns.general;
  }

  private maskSensitiveData(data: string): string {
    return data.replace(/\d/g, '*');
  }

  private getRiskWeight(dataType: string): number {
    const weights = {
      cpf: 25,
      rg: 20,
      phone: 15,
      email: 10,
      medical_record: 30,
      birth_date: 20
    };

    return weights[dataType] || 5;
  }

  private calculateRiskLevel(score: number): string {
    if (score >= 80) return 'CRITICAL';
    if (score >= 60) return 'HIGH';
    if (score >= 40) return 'MEDIUM';
    if (score >= 20) return 'LOW';
    return 'MINIMAL';
  }

  private validateLGPDCompliance(content: string, assessment: any): string[] {
    const issues = [];

    // Check for consent indicators
    if (Object.keys(assessment.pii_detected).length > 0) {
      const hasConsent = /consentimento|autorizo|concordo/i.test(content);
      if (!hasConsent) {
        issues.push("Dados pessoais identificados sem indicação de consentimento explícito");
      }
    }

    // Check for data minimization
    if (assessment.risk_score > 50) {
      issues.push("Volume excessivo de dados sensíveis - revisar necessidade de coleta");
    }

    // Professional ethics compliance
    if (/diagnóstico|tratamento|prescrição/i.test(content)) {
      issues.push("Conteúdo médico requer validação CFM/CRP para publicação");
    }

    return issues;
  }

  private generateConsentFormFields(piiDetected: any): any[] {
    const fields = [];

    if (piiDetected.cpf) {
      fields.push({
        type: 'checkbox',
        name: 'consent_cpf',
        label: 'Autorizo o uso do meu CPF para identificação e comunicação',
        required: true,
        lgpd_basis: 'Art. 7º, I - consentimento do titular'
      });
    }

    if (piiDetected.phone || piiDetected.email) {
      fields.push({
        type: 'checkbox',
        name: 'consent_contact',
        label: 'Autorizo o contato através dos dados fornecidos para comunicação sobre saúde',
        required: true,
        lgpd_basis: 'Art. 7º, I - consentimento do titular'
      });
    }

    if (piiDetected.medical_record) {
      fields.push({
        type: 'checkbox',
        name: 'consent_medical_data',
        label: 'Autorizo o processamento de dados médicos para finalidades assistenciais',
        required: true,
        lgpd_basis: 'Art. 11, I - consentimento específico e destacado'
      });
    }

    return fields;
  }
}
```

### 2. Scientific Search Integration
```typescript
// healthcare_mcp_server/src/tools/pubmed-search.ts
export class PubMedSearchTool implements Tool {
  private readonly PUBMED_BASE_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
  private readonly API_KEY = process.env.PUBMED_API_KEY;

  async execute(params: any) {
    const { query, filters = {}, max_results = 20 } = params;

    try {
      // Build search query with healthcare-specific filters
      const searchQuery = this.buildHealthcareQuery(query, filters);

      // Search PubMed
      const searchResults = await this.searchPubMed(searchQuery, max_results);

      // Fetch detailed article information
      const articles = await this.fetchArticleDetails(searchResults.idlist);

      // Apply healthcare-specific ranking and filtering
      const rankedArticles = this.rankByHealthcareRelevance(articles, query);

      return {
        query: searchQuery,
        total_found: searchResults.count,
        returned_count: articles.length,
        articles: rankedArticles,
        search_timestamp: new Date().toISOString(),
        filters_applied: filters
      };

    } catch (error) {
      throw new Error(`PubMed search failed: ${error.message}`);
    }
  }

  private buildHealthcareQuery(query: string, filters: any): string {
    let searchTerms = [query];

    // Add publication type filters
    if (filters.publication_types?.length > 0) {
      const pubTypes = filters.publication_types
        .map(type => `"${type}"[Publication Type]`)
        .join(' OR ');
      searchTerms.push(`(${pubTypes})`);
    }

    // Add year filters
    if (filters.years) {
      searchTerms.push(`"${filters.years}"[Date - Publication]`);
    }

    // Add language filters
    if (filters.languages?.length > 0) {
      const languages = filters.languages
        .map(lang => `"${lang}"[Language]`)
        .join(' OR ');
      searchTerms.push(`(${languages})`);
    }

    // Add healthcare-specific filters
    searchTerms.push('("humans"[MeSH Terms] OR "clinical trial"[Publication Type])');

    return searchTerms.join(' AND ');
  }

  private async searchPubMed(query: string, maxResults: number) {
    const searchUrl = new URL(`${this.PUBMED_BASE_URL}esearch.fcgi`);
    searchUrl.searchParams.append('db', 'pubmed');
    searchUrl.searchParams.append('term', query);
    searchUrl.searchParams.append('retmax', maxResults.toString());
    searchUrl.searchParams.append('retmode', 'json');
    searchUrl.searchParams.append('sort', 'relevance');

    if (this.API_KEY) {
      searchUrl.searchParams.append('api_key', this.API_KEY);
    }

    const response = await fetch(searchUrl.toString());
    const data = await response.json();

    return data.esearchresult;
  }

  private async fetchArticleDetails(pmids: string[]) {
    if (!pmids || pmids.length === 0) return [];

    const summaryUrl = new URL(`${this.PUBMED_BASE_URL}esummary.fcgi`);
    summaryUrl.searchParams.append('db', 'pubmed');
    summaryUrl.searchParams.append('id', pmids.join(','));
    summaryUrl.searchParams.append('retmode', 'json');

    if (this.API_KEY) {
      summaryUrl.searchParams.append('api_key', this.API_KEY);
    }

    const response = await fetch(summaryUrl.toString());
    const data = await response.json();

    return Object.values(data.result).filter(item => typeof item === 'object' && item.uid);
  }

  private rankByHealthcareRelevance(articles: any[], originalQuery: string): any[] {
    return articles
      .map(article => ({
        pmid: article.uid,
        title: article.title,
        authors: article.authors?.map(author => author.name).join(', ') || 'N/A',
        journal: article.fulljournalname || article.source,
        pub_date: article.pubdate,
        abstract: article.abstract || 'Abstract not available',
        doi: article.elocationid?.startsWith('doi:') ? article.elocationid.substring(4) : null,
        publication_types: article.pubtypes,
        keywords: article.keywords || [],
        relevance_score: this.calculateHealthcareRelevance(article, originalQuery),
        evidence_level: this.determineEvidenceLevel(article),
        pubmed_url: `https://pubmed.ncbi.nlm.nih.gov/${article.uid}/`,
        citation_mla: this.generateMLACitation(article),
        citation_abnt: this.generateABNTCitation(article)
      }))
      .sort((a, b) => b.relevance_score - a.relevance_score);
  }

  private calculateHealthcareRelevance(article: any, query: string): number {
    let score = 0;

    const title = article.title?.toLowerCase() || '';
    const abstract = article.abstract?.toLowerCase() || '';
    const queryLower = query.toLowerCase();

    // Title relevance (highest weight)
    if (title.includes(queryLower)) score += 10;

    // Abstract relevance
    if (abstract.includes(queryLower)) score += 5;

    // Publication type scoring
    const highValueTypes = ['clinical trial', 'systematic review', 'meta-analysis'];
    if (article.pubtypes?.some(type =>
        highValueTypes.some(hvt => type.toLowerCase().includes(hvt.toLowerCase()))
    )) {
      score += 8;
    }

    // Recent publication bonus (last 5 years)
    const pubYear = parseInt(article.pubdate?.split(' ')[0]) || 0;
    const currentYear = new Date().getFullYear();
    if (pubYear >= currentYear - 5) score += 3;

    // High-impact journal bonus (simplified)
    const highImpactJournals = ['nature', 'science', 'lancet', 'nejm', 'jama'];
    const journal = article.fulljournalname?.toLowerCase() || '';
    if (highImpactJournals.some(hij => journal.includes(hij))) {
      score += 5;
    }

    return score;
  }

  private determineEvidenceLevel(article: any): string {
    const pubTypes = article.pubtypes?.map(type => type.toLowerCase()) || [];

    if (pubTypes.some(type => type.includes('meta-analysis'))) return 'Level I - Meta-analysis';
    if (pubTypes.some(type => type.includes('systematic review'))) return 'Level I - Systematic Review';
    if (pubTypes.some(type => type.includes('randomized controlled trial'))) return 'Level II - RCT';
    if (pubTypes.some(type => type.includes('clinical trial'))) return 'Level III - Clinical Trial';
    if (pubTypes.some(type => type.includes('cohort studies'))) return 'Level IV - Cohort Study';
    if (pubTypes.some(type => type.includes('case reports'))) return 'Level V - Case Report';

    return 'Level VI - Expert Opinion/Other';
  }

  private generateMLACitation(article: any): string {
    const authors = article.authors?.map(a => a.name).join(', ') || 'N/A';
    const title = article.title || 'N/A';
    const journal = article.fulljournalname || article.source || 'N/A';
    const year = article.pubdate?.split(' ')[0] || 'N/A';

    return `${authors}. "${title}" ${journal}, ${year}.`;
  }

  private generateABNTCitation(article: any): string {
    const authors = article.authors?.map(a => a.name.toUpperCase()).join('; ') || 'N/A';
    const title = article.title || 'N/A';
    const journal = article.fulljournalname || article.source || 'N/A';
    const year = article.pubdate?.split(' ')[0] || 'N/A';

    return `${authors}. ${title}. ${journal}, ${year}.`;
  }
}
```

---

## 🔗 Integração FHIR R4 {#integracao-fhir-r4}

### FHIR Resource Validator Tool
```typescript
// healthcare_mcp_server/src/tools/fhir-validator.ts
export class FHIRValidator implements Tool {
  async execute(params: any) {
    const { resource_type, resource_data, validation_level = 'strict' } = params;

    const validationResult = {
      resource_type,
      is_valid: false,
      errors: [],
      warnings: [],
      fhir_version: 'R4',
      validation_timestamp: new Date().toISOString(),
      lgpd_compliance: {
        compliant: false,
        issues: [],
        recommendations: []
      }
    };

    try {
      // Validate FHIR R4 structure
      const structureValidation = this.validateFHIRStructure(resource_type, resource_data);
      validationResult.errors.push(...structureValidation.errors);
      validationResult.warnings.push(...structureValidation.warnings);

      // Healthcare-specific validations
      const healthcareValidation = this.validateHealthcareRequirements(resource_type, resource_data);
      validationResult.errors.push(...healthcareValidation.errors);

      // LGPD compliance validation for healthcare data
      const lgpdValidation = this.validateLGPDComplianceFHIR(resource_data);
      validationResult.lgpd_compliance = lgpdValidation;

      validationResult.is_valid = validationResult.errors.length === 0;

      return validationResult;

    } catch (error) {
      validationResult.errors.push(`Validation failed: ${error.message}`);
      return validationResult;
    }
  }

  private validateFHIRStructure(resourceType: string, data: any) {
    const errors = [];
    const warnings = [];

    // Required fields validation based on FHIR R4 specs
    const requiredFields = this.getFHIRRequiredFields(resourceType);

    for (const field of requiredFields) {
      if (!this.hasNestedProperty(data, field)) {
        errors.push(`Required field missing: ${field}`);
      }
    }

    // Data type validation
    const typeValidation = this.validateDataTypes(resourceType, data);
    errors.push(...typeValidation.errors);
    warnings.push(...typeValidation.warnings);

    return { errors, warnings };
  }

  private validateHealthcareRequirements(resourceType: string, data: any) {
    const errors = [];

    switch (resourceType) {
      case 'Patient':
        return this.validatePatientResource(data);
      case 'Practitioner':
        return this.validatePractitionerResource(data);
      case 'Observation':
        return this.validateObservationResource(data);
      default:
        return { errors: [] };
    }
  }

  private validatePatientResource(data: any) {
    const errors = [];

    // Brazilian-specific validations
    if (data.identifier) {
      const cpfIdentifier = data.identifier.find(id =>
        id.type?.coding?.some(c => c.code === 'CPF')
      );

      if (cpfIdentifier && !this.isValidCPF(cpfIdentifier.value)) {
        errors.push('Invalid CPF format in patient identifier');
      }
    }

    // Healthcare context validations
    if (!data.name || data.name.length === 0) {
      errors.push('Patient must have at least one name');
    }

    return { errors };
  }

  private validatePractitionerResource(data: any) {
    const errors = [];

    // CRM validation for Brazilian practitioners
    if (data.identifier) {
      const crmIdentifier = data.identifier.find(id =>
        id.type?.coding?.some(c => c.code === 'CRM')
      );

      if (crmIdentifier && !this.isValidCRM(crmIdentifier.value)) {
        errors.push('Invalid CRM format in practitioner identifier');
      }
    }

    return { errors };
  }

  private validateLGPDComplianceFHIR(data: any) {
    const result = {
      compliant: true,
      issues: [],
      recommendations: []
    };

    // Check for sensitive data without proper consent indicators
    const sensitiveFields = this.extractSensitiveFields(data);

    if (sensitiveFields.length > 0) {
      const hasConsent = data.consent || data.authorization;

      if (!hasConsent) {
        result.compliant = false;
        result.issues.push('Sensitive healthcare data present without consent record');
        result.recommendations.push('Add consent resource reference or authorization element');
      }
    }

    // Check for data minimization compliance
    const unnecessaryFields = this.checkDataMinimization(data);
    if (unnecessaryFields.length > 0) {
      result.recommendations.push(
        `Consider removing unnecessary fields for data minimization: ${unnecessaryFields.join(', ')}`
      );
    }

    return result;
  }

  private getFHIRRequiredFields(resourceType: string): string[] {
    const requiredFieldsMap = {
      'Patient': ['resourceType', 'id'],
      'Practitioner': ['resourceType', 'id', 'name'],
      'Observation': ['resourceType', 'id', 'status', 'code', 'subject'],
      'Medication': ['resourceType', 'id', 'code'],
      'DiagnosticReport': ['resourceType', 'id', 'status', 'code', 'subject']
    };

    return requiredFieldsMap[resourceType] || ['resourceType', 'id'];
  }

  private isValidCPF(cpf: string): boolean {
    // Brazilian CPF validation algorithm
    const cleanCPF = cpf.replace(/[^\d]/g, '');

    if (cleanCPF.length !== 11) return false;
    if (/^(\d)\1{10}$/.test(cleanCPF)) return false; // All same digits

    // Validate check digits
    let sum = 0;
    for (let i = 0; i < 9; i++) {
      sum += parseInt(cleanCPF.charAt(i)) * (10 - i);
    }

    let digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;

    if (parseInt(cleanCPF.charAt(9)) !== digit1) return false;

    sum = 0;
    for (let i = 0; i < 10; i++) {
      sum += parseInt(cleanCPF.charAt(i)) * (11 - i);
    }

    let digit2 = 11 - (sum % 11);
    if (digit2 >= 10) digit2 = 0;

    return parseInt(cleanCPF.charAt(10)) === digit2;
  }

  private isValidCRM(crm: string): boolean {
    // Brazilian CRM validation (simplified)
    const crmPattern = /^CRM\/[A-Z]{2}\s+\d{4,6}$/i;
    return crmPattern.test(crm);
  }

  private hasNestedProperty(obj: any, path: string): boolean {
    return path.split('.').reduce((current, key) =>
      current && current[key] !== undefined, obj
    ) !== undefined;
  }

  private extractSensitiveFields(data: any): string[] {
    const sensitive = [];
    const sensitivePatterns = [
      'telecom', 'address', 'birthDate', 'maritalStatus',
      'contact', 'identifier', 'photo'
    ];

    for (const field of sensitivePatterns) {
      if (this.hasNestedProperty(data, field)) {
        sensitive.push(field);
      }
    }

    return sensitive;
  }

  private checkDataMinimization(data: any): string[] {
    const unnecessary = [];
    const optionalFields = ['photo', 'animal', 'communication.preferred'];

    for (const field of optionalFields) {
      if (this.hasNestedProperty(data, field)) {
        unnecessary.push(field);
      }
    }

    return unnecessary;
  }

  private validateDataTypes(resourceType: string, data: any) {
    const errors = [];
    const warnings = [];

    // Basic type checking for common FHIR data types
    if (data.id && typeof data.id !== 'string') {
      errors.push('Resource ID must be a string');
    }

    if (data.identifier && !Array.isArray(data.identifier)) {
      errors.push('Identifier must be an array');
    }

    return { errors, warnings };
  }
}
```

---

## 🔍 Troubleshooting Guide {#troubleshooting-guide}

### Common Issues & Solutions

#### 1. **MCP Server Connection Issues**
```bash
# Problem: "MCP server failed to start"
# Solution: Check Node.js version and dependencies

node --version  # Should be >= 18.0.0
npm install     # Reinstall dependencies
npm run build   # Rebuild TypeScript

# Check MCP server logs
tail -f /var/log/healthcare-mcp-server.log
```

#### 2. **LGPD Tool Memory Errors**
```elixir
# Problem: Large content causing memory issues
# Solution: Implement content chunking

defmodule HealthcareWeb.MCP.LGPDHelper do
  def analyze_large_content(content) when byte_size(content) > 1_000_000 do
    content
    |> chunk_content(100_000)  # 100KB chunks
    |> Enum.map(&HealthcareWeb.MCP.Client.analyze_lgpd_risks/1)
    |> merge_risk_results()
  end

  defp chunk_content(content, size) do
    content
    |> String.graphemes()
    |> Enum.chunk_every(size)
    |> Enum.map(&Enum.join/1)
  end

  defp merge_risk_results(results) do
    # Merge logic for combining multiple risk assessments
    %{
      risk_score: results |> Enum.map(& &1.risk_score) |> Enum.max(),
      pii_detected: results |> Enum.flat_map(& &1.pii_detected) |> Enum.uniq(),
      recommendations: results |> Enum.flat_map(& &1.recommendations) |> Enum.uniq()
    }
  end
end
```

#### 3. **PubMed API Rate Limiting**
```typescript
// Problem: Hitting PubMed rate limits
// Solution: Implement intelligent retry with exponential backoff

class PubMedRateLimiter {
  private requestQueue: Array<() => Promise<any>> = [];
  private isProcessing = false;
  private lastRequestTime = 0;
  private minInterval = 100; // ms between requests

  async execute(requestFn: () => Promise<any>): Promise<any> {
    return new Promise((resolve, reject) => {
      this.requestQueue.push(async () => {
        try {
          const result = await requestFn();
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });

      this.processQueue();
    });
  }

  private async processQueue() {
    if (this.isProcessing || this.requestQueue.length === 0) return;

    this.isProcessing = true;

    while (this.requestQueue.length > 0) {
      const timeSinceLastRequest = Date.now() - this.lastRequestTime;

      if (timeSinceLastRequest < this.minInterval) {
        await this.delay(this.minInterval - timeSinceLastRequest);
      }

      const request = this.requestQueue.shift();
      if (request) {
        try {
          await request();
          this.lastRequestTime = Date.now();
        } catch (error) {
          if (error.status === 429) { // Too Many Requests
            // Exponential backoff
            await this.delay(Math.min(30000, this.minInterval * 2));
            this.minInterval *= 1.5; // Increase interval
          }
        }
      }
    }

    this.isProcessing = false;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

#### 4. **FHIR Validation Performance Issues**
```elixir
# Problem: Slow FHIR validation for large datasets
# Solution: Implement caching and parallel processing

defmodule HealthcareWeb.MCP.FHIRCache do
  use GenServer

  # Cache validation results for identical resources
  def validate_with_cache(resource_type, resource_data) do
    cache_key = generate_cache_key(resource_type, resource_data)

    case get_cached_result(cache_key) do
      nil ->
        result = HealthcareWeb.MCP.Client.validate_fhir(resource_type, resource_data)
        cache_result(cache_key, result)
        result

      cached_result ->
        cached_result
    end
  end

  def validate_batch(resources) when is_list(resources) do
    resources
    |> Task.async_stream(
      fn {type, data} -> validate_with_cache(type, data) end,
      max_concurrency: 10,
      timeout: 30_000
    )
    |> Enum.map(fn {:ok, result} -> result end)
  end

  defp generate_cache_key(resource_type, resource_data) do
    :crypto.hash(:sha256, "#{resource_type}:#{Jason.encode!(resource_data)}")
    |> Base.encode16()
  end

  defp get_cached_result(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  defp cache_result(key, result) do
    GenServer.cast(__MODULE__, {:put, key, result})
  end
end
```

---

## ⚡ Performance Benchmarks {#performance-benchmarks}

### Expected Performance Metrics

| Tool | Operation | Target Latency | Memory Usage | Throughput |
|------|-----------|----------------|--------------|------------|
| LGPD Analyzer | 10K words analysis | < 5s | < 128MB | 200 docs/min |
| PubMed Search | 20 results fetch | < 30s | < 64MB | 100 queries/hour |
| FHIR Validator | Single resource | < 2s | < 32MB | 500 resources/min |
| MCP Request/Response | Full cycle | < 100ms | < 16MB | 1000 req/min |

### Performance Testing Script
```elixir
# test/performance/mcp_performance_test.exs
defmodule HealthcareWeb.MCPPerformanceTest do
  use ExUnit.Case

  @moduletag :performance

  describe "LGPD Analyzer Performance" do
    test "handles large medical content within SLA" do
      large_content = generate_medical_content(10_000) # 10K words

      {time_microseconds, result} = :timer.tc(fn ->
        HealthcareWeb.MCP.Client.analyze_lgpd_risks(large_content, "cardiology")
      end)

      time_seconds = time_microseconds / 1_000_000

      assert time_seconds < 5.0, "LGPD analysis took #{time_seconds}s (SLA: < 5s)"
      assert result.risk_score >= 0, "Valid risk score returned"
      assert is_list(result.recommendations), "Recommendations provided"
    end

    test "memory usage stays within limits" do
      content = generate_medical_content(5_000)

      memory_before = :erlang.memory(:total)
      _result = HealthcareWeb.MCP.Client.analyze_lgpd_risks(content)
      memory_after = :erlang.memory(:total)

      memory_used = memory_after - memory_before
      memory_mb = memory_used / (1024 * 1024)

      assert memory_mb < 128, "Memory usage: #{memory_mb}MB (SLA: < 128MB)"
    end
  end

  describe "PubMed Search Performance" do
    test "scientific search completes within SLA" do
      {time_microseconds, result} = :timer.tc(fn ->
        HealthcareWeb.MCP.Client.search_pubmed("diabetes treatment", %{
          publication_types: ["Clinical Trial"],
          max_results: 20
        })
      end)

      time_seconds = time_microseconds / 1_000_000

      assert time_seconds < 30.0, "PubMed search took #{time_seconds}s (SLA: < 30s)"
      assert length(result.articles) <= 20, "Result count within limit"
      assert Enum.all?(result.articles, &Map.has_key?(&1, :pmid)), "All articles have PMID"
    end
  end

  describe "MCP Server Concurrent Performance" do
    test "handles concurrent requests efficiently" do
      concurrent_requests = 50

      tasks = for i <- 1..concurrent_requests do
        Task.async(fn ->
          content = "Sample medical content #{i}"
          HealthcareWeb.MCP.Client.analyze_lgpd_risks(content)
        end)
      end

      {time_microseconds, results} = :timer.tc(fn ->
        Task.await_many(tasks, 30_000)
      end)

      time_seconds = time_microseconds / 1_000_000
      throughput = concurrent_requests / time_seconds

      assert length(results) == concurrent_requests, "All requests completed"
      assert throughput > 10, "Throughput: #{throughput} req/s (target: > 10 req/s)"
    end
  end

  defp generate_medical_content(word_count) do
    medical_terms = [
      "diagnóstico", "tratamento", "prescrição", "medicamento",
      "paciente", "sintoma", "exame", "resultado", "terapia",
      "cardiologia", "diabetes", "hipertensão", "medicação"
    ]

    1..word_count
    |> Enum.map(fn _ -> Enum.random(medical_terms) end)
    |> Enum.join(" ")
  end
end
```

---

## 📚 Related References

### MCP Protocol Documentation
- [MCP Specification](https://spec.modelcontextprotocol.io/) - Official MCP protocol specification
- [Anthropic MCP SDK](https://github.com/anthropics/mcp) - Official TypeScript SDK
- [Healthcare MCP Extensions](https://github.com/healthcare-mcp/extensions) - Healthcare-specific MCP tools

### Healthcare Integration Standards
- [FHIR R4 Implementation Guide](https://www.hl7.org/fhir/R4/) - Official FHIR R4 documentation
- [Brazilian FHIR Profiles](https://simplifier.net/BR-Core) - Brazilian healthcare FHIR profiles
- [PubMed E-utilities API](https://www.ncbi.nlm.nih.gov/books/NBK25501/) - Official PubMed API documentation

### Security & Compliance
- [LGPD Healthcare Guidelines](https://www.gov.br/anpd/pt-br) - Brazilian data protection authority
- [NIST Healthcare Security Framework](https://www.nist.gov/healthcare) - Healthcare security standards
- [Zero Trust Healthcare Architecture](https://www.cisa.gov/zero-trust-maturity-model) - Zero trust implementation guide

---

**Próximo Diário:** [05-database-stack-postgresql-timescaledb.md](./05-database-stack-postgresql-timescaledb.md)
**Índice Geral:** [README.md](../README.md)