# ADR-003: WebAssembly Plugin System Design

<!-- DSM:DOMAIN:architecture|webassembly_plugins COMPLEXITY:expert DEPS:extism_runtime -->
<!-- DSM:HEALTHCARE:medical_workflows|s1_1_to_s4_1_1_3_pipeline -->
<!-- DSM:PERFORMANCE:plugin_execution:<5s SECURITY:sandbox_isolation -->

## 🧩 DSM WebAssembly Matrix
```yaml
DSM_WEBASSEMBLY_MATRIX:
  decision_scope: "WebAssembly plugin architecture for medical workflows S.1.1→S.4-1.1-3"
  security_model: "Capability-based sandbox isolation for healthcare data"

  depends_on:
    - extism_webassembly_runtime
    - wasi_capability_security_model
    - medical_workflow_requirements
    - host_elixir_integration_patterns

  provides_to:
    - s1_1_lgpd_analyzer_plugin
    - s1_2_medical_claims_extractor
    - s2_1_2_scientific_search_engine
    - s3_2_seo_healthcare_optimizer
    - s4_1_1_3_content_generator

  integrates_with:
    - zero_trust_policy_engine
    - healthcare_cms_host_platform
    - compliance_audit_system
    - performance_monitoring_tools

  performance_contracts:
    - plugin_execution_time: "<5s per system in pipeline"
    - memory_isolation: "512MB max per plugin instance"
    - concurrent_executions: "100+ simultaneous pipeline runs"
    - failure_recovery: "Automatic rollback on plugin failure"

  security_requirements:
    - capability_based_access: "WASI-based permissions per plugin"
    - healthcare_data_isolation: "No cross-plugin data leakage"
    - audit_trail_complete: "All plugin executions logged"
    - sandboxed_execution: "No host system access beyond capabilities"
```

---

## Status

**Status**: ✅ **ACEITO**
**Data**: 25 de Janeiro de 2025
**Revisão**: 29 de Setembro de 2025 (Architecture preparada, integração pendente)

---

## Contexto

Healthcare CMS requer **pipeline de workflows médicos** (S.1.1→S.4-1.1-3) com requisitos únicos:

1. **Medical Content Processing**: LGPD analysis, claims extraction, scientific validation
2. **Security Isolation**: Healthcare data sandbox, capability control
3. **Multi-language Support**: Rust, Go, AssemblyScript para algoritmos especializados
4. **Performance Critical**: <5s execution per system, 100+ concurrent pipelines
5. **Compliance Audit**: Complete execution traceability for LGPD/CFM/ANVISA

### Problema Específico

Workflows médicos tradicionais apresentam limitações:
- **Monolithic architecture**: Dificulta evolução independente de sistemas
- **Security boundaries**: Acesso total vs granular para healthcare data
- **Language constraints**: Limitado ao host language (Elixir)
- **Scalability**: Processo coupling limita scaling independente
- **Audit complexity**: Difficult traceability em sistemas acoplados

**WebAssembly plugins** resolve com **sandbox isolation** + **capability security**.

---

## Arquitetura Plugin System

### Core Architecture: Host-Plugin Pattern

```yaml
# DSM:ARCHITECTURE:host_plugin_pattern EXTISM_BASED
Host_Plugin_Architecture:
  host_platform:
    technology: "Elixir/Phoenix Healthcare CMS"
    responsibilities:
      - "Plugin lifecycle management"
      - "Capability permission enforcement"
      - "Inter-plugin data flow orchestration"
      - "Zero Trust policy integration"
      - "Audit trail generation"

  plugin_runtime:
    technology: "Extism Universal WebAssembly Runtime"
    features:
      - "Multi-language support (Rust, Go, AssemblyScript)"
      - "WASI-based capability security"
      - "Memory isolation per plugin"
      - "Automatic sandboxing"

  communication_protocol:
    format: "JSON messages over WebAssembly imports/exports"
    security: "Capability-controlled data access"
    performance: "Direct memory transfer (no serialization overhead)"
```

---

## Plugin Implementations

### 1. **S.1.1 - LGPD Analyzer Plugin (Rust WASM)**

```rust
// DSM:PLUGIN:s1_1_lgpd_analyzer RUST_IMPLEMENTATION PRIORITY:CRITICAL
use extism_pdk::*;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct LGPDAnalysisInput {
    content: String,
    content_type: String,
    analysis_config: LGPDConfig,
}

#[derive(Serialize)]
struct LGPDAnalysisOutput {
    phi_pii_detected: Vec<PIIDetection>,
    risk_score: u8,           // 0-100 risk level
    recommendations: Vec<String>,
    legal_basis_suggestions: Vec<String>,
    anonymization_options: Vec<AnonymizationOption>,
    compliance_status: ComplianceStatus,
}

#[derive(Serialize, Deserialize)]
struct PIIDetection {
    data_type: String,        // "cpf", "email", "phone", "medical_record"
    location: TextLocation,
    confidence: f32,          // 0.0-1.0 confidence score
    lgpd_category: String,    // "personal", "sensitive", "special"
    suggested_action: String, // "anonymize", "pseudonymize", "remove", "consent_required"
}

#[plugin_fn]
pub fn analyze_lgpd_compliance(input: String) -> FnResult<String> {
    let analysis_input: LGPDAnalysisInput = Json::from_str(&input)?;

    // Core LGPD analysis algorithm
    let phi_pii_results = detect_phi_pii(&analysis_input.content);
    let risk_assessment = calculate_lgpd_risk(&phi_pii_results, &analysis_input.content_type);
    let recommendations = generate_compliance_recommendations(&phi_pii_results, &risk_assessment);

    // Legal basis analysis (LGPD Art. 7)
    let legal_basis = analyze_legal_basis_options(&analysis_input.content, &phi_pii_results);

    // Anonymization recommendations
    let anonymization_options = generate_anonymization_options(&phi_pii_results);

    // Compile results
    let output = LGPDAnalysisOutput {
        phi_pii_detected: phi_pii_results,
        risk_score: risk_assessment.overall_score,
        recommendations,
        legal_basis_suggestions: legal_basis,
        anonymization_options,
        compliance_status: determine_compliance_status(&risk_assessment),
    };

    // Audit logging
    log_audit_event("lgpd_analysis_completed", &output);

    Ok(Json::to_string(&output)?)
}

// Advanced PHI/PII detection with medical context
fn detect_phi_pii(content: &str) -> Vec<PIIDetection> {
    let mut detections = Vec::new();

    // CPF detection with validation
    if let Some(cpf_matches) = detect_cpf_patterns(content) {
        for cpf_match in cpf_matches {
            detections.push(PIIDetection {
                data_type: "cpf".to_string(),
                location: cpf_match.location,
                confidence: validate_cpf_checksum(&cpf_match.value),
                lgpd_category: "personal".to_string(),
                suggested_action: "pseudonymize".to_string(),
            });
        }
    }

    // Medical record number detection
    if let Some(medical_records) = detect_medical_record_patterns(content) {
        for record in medical_records {
            detections.push(PIIDetection {
                data_type: "medical_record".to_string(),
                location: record.location,
                confidence: 0.95,
                lgpd_category: "sensitive".to_string(),
                suggested_action: "anonymize".to_string(),
            });
        }
    }

    // Email detection with healthcare domain analysis
    if let Some(email_matches) = detect_email_patterns(content) {
        for email in email_matches {
            let healthcare_context = is_healthcare_email_domain(&email.domain);
            detections.push(PIIDetection {
                data_type: "email".to_string(),
                location: email.location,
                confidence: 0.98,
                lgpd_category: if healthcare_context { "sensitive" } else { "personal" },
                suggested_action: "pseudonymize".to_string(),
            });
        }
    }

    detections
}

// LGPD risk calculation with healthcare weights
fn calculate_lgpd_risk(detections: &[PIIDetection], content_type: &str) -> RiskAssessment {
    let mut risk_score = 0u8;

    // Base risk from detected PII types
    for detection in detections {
        let type_risk = match detection.data_type.as_str() {
            "cpf" => 20,
            "medical_record" => 30,
            "health_data" => 35,
            "email" => 10,
            "phone" => 10,
            _ => 5,
        };

        let confidence_factor = detection.confidence;
        risk_score = (risk_score + (type_risk as f32 * confidence_factor) as u8).min(100);
    }

    // Content type risk modifier
    let content_risk_modifier = match content_type {
        "medical_article" => 1.2,
        "patient_education" => 1.0,
        "professional_content" => 0.8,
        _ => 1.0,
    };

    risk_score = ((risk_score as f32) * content_risk_modifier) as u8;

    RiskAssessment {
        overall_score: risk_score.min(100),
        risk_level: determine_risk_level(risk_score),
        factors: calculate_risk_factors(detections),
    }
}

#[derive(Serialize)]
struct RiskAssessment {
    overall_score: u8,
    risk_level: String,    // "low", "medium", "high", "critical"
    factors: Vec<String>,
}

// Audit event logging with capability restriction
fn log_audit_event(event_type: &str, output: &LGPDAnalysisOutput) {
    // This function can only log through host-provided capability
    // Cannot directly access filesystem or network

    let audit_data = AuditEvent {
        plugin_id: "s1_1_lgpd_analyzer",
        event_type: event_type.to_string(),
        timestamp: get_current_timestamp(), // Host-provided function
        risk_score: output.risk_score,
        pii_count: output.phi_pii_detected.len(),
        compliance_status: output.compliance_status.clone(),
    };

    // Call host audit function through capability
    host_log_audit_event(&audit_data);
}
```

### 2. **S.1.2 - Medical Claims Extractor (AssemblyScript WASM)**

```typescript
// DSM:PLUGIN:s1_2_medical_claims ASSEMBLYSCRIPT_IMPLEMENTATION PRIORITY:HIGH
import { JSON } from "assemblyscript-json";

@external("env", "host_log_audit")
declare function hostLogAudit(ptr: usize, len: usize): void;

@external("env", "get_medical_ontology")
declare function getMedicalOntology(query_ptr: usize, query_len: usize): i32;

class MedicalClaimsInput {
  content: string = "";
  sanitized_data: string = "";
  analysis_config: ClaimsConfig = new ClaimsConfig();
}

class MedicalClaimsOutput {
  medical_claims: Array<MedicalClaim> = [];
  evidence_requirements: Array<EvidenceRequirement> = [];
  cfm_compliance_notes: Array<string> = [];
  scientific_search_strategies: Array<SearchStrategy> = [];
  confidence_score: f32 = 0.0;
}

class MedicalClaim {
  claim_text: string = "";
  claim_type: string = "";          // "treatment", "diagnosis", "prevention", "prognosis"
  medical_domain: string = "";      // "cardiology", "oncology", "psychiatry", etc.
  evidence_level_required: string = ""; // "I", "II", "III", "IV"
  confidence: f32 = 0.0;
  cfm_compliance_risk: string = ""; // "low", "medium", "high"
  suggested_search_terms: Array<string> = [];
}

class EvidenceRequirement {
  claim_id: string = "";
  required_evidence_type: string = ""; // "rct", "cohort", "case_control", "expert_opinion"
  minimum_studies: i32 = 0;
  preferred_databases: Array<string> = [];
  search_time_range: string = "";      // "5_years", "10_years", "all_time"
}

export function extract_medical_claims(input_ptr: usize, input_len: usize): usize {
  // Parse input JSON
  const input_str = String.UTF8.decode(changetype<ArrayBuffer>(input_ptr), input_len);
  const input_json = <JSON.Obj>JSON.parse(input_str);

  const claims_input = new MedicalClaimsInput();
  claims_input.content = (<JSON.Str>input_json.get("content")).valueOf();

  // Extract medical claims using NLP patterns
  const extracted_claims = performMedicalClaimsExtraction(claims_input.content);

  // Validate claims against medical ontology
  const validated_claims = validateClaimsAgainstOntology(extracted_claims);

  // Generate evidence requirements
  const evidence_reqs = generateEvidenceRequirements(validated_claims);

  // CFM compliance analysis
  const cfm_analysis = analyzeCFMCompliance(validated_claims);

  // Generate scientific search strategies
  const search_strategies = generateSearchStrategies(validated_claims);

  // Compile output
  const output = new MedicalClaimsOutput();
  output.medical_claims = validated_claims;
  output.evidence_requirements = evidence_reqs;
  output.cfm_compliance_notes = cfm_analysis;
  output.scientific_search_strategies = search_strategies;
  output.confidence_score = calculateOverallConfidence(validated_claims);

  // Audit logging
  logClaimsExtractionAudit(output);

  // Serialize output
  const output_json = JSON.stringify(output);
  const output_buffer = String.UTF8.encode(output_json);

  return changetype<usize>(output_buffer);
}

function performMedicalClaimsExtraction(content: string): Array<MedicalClaim> {
  const claims: Array<MedicalClaim> = [];

  // Pattern-based extraction for common medical claim types
  const treatment_patterns = [
    /(\w+)\s+é\s+eficaz\s+para\s+(\w+)/gi,
    /(\w+)\s+melhora\s+(\w+)/gi,
    /(\w+)\s+reduz\s+o\s+risco\s+de\s+(\w+)/gi
  ];

  for (let i = 0; i < treatment_patterns.length; i++) {
    const pattern = treatment_patterns[i];
    const matches = content.match(pattern);

    if (matches) {
      for (let j = 0; j < matches.length; j++) {
        const match = matches[j];

        const claim = new MedicalClaim();
        claim.claim_text = match;
        claim.claim_type = "treatment";
        claim.confidence = calculateClaimConfidence(match);
        claim.evidence_level_required = determineRequiredEvidenceLevel(claim.claim_type);

        claims.push(claim);
      }
    }
  }

  // Diagnostic claims extraction
  const diagnostic_patterns = [
    /(\w+)\s+indica\s+(\w+)/gi,
    /(\w+)\s+é\s+sintoma\s+de\s+(\w+)/gi
  ];

  // Similar extraction logic for diagnostic claims...

  return claims;
}

function validateClaimsAgainstOntology(claims: Array<MedicalClaim>): Array<MedicalClaim> {
  const validated_claims: Array<MedicalClaim> = [];

  for (let i = 0; i < claims.length; i++) {
    const claim = claims[i];

    // Query medical ontology through host capability
    const ontology_query = `term:${claim.claim_text}&type:${claim.claim_type}`;
    const ontology_buffer = String.UTF8.encode(ontology_query);

    const ontology_result = getMedicalOntology(
      changetype<usize>(ontology_buffer),
      ontology_buffer.byteLength
    );

    if (ontology_result > 0) {
      // Ontology validation successful
      claim.medical_domain = extractMedicalDomain(claim.claim_text);
      claim.cfm_compliance_risk = assessCFMRisk(claim);
      validated_claims.push(claim);
    }
  }

  return validated_claims;
}

function generateEvidenceRequirements(claims: Array<MedicalClaim>): Array<EvidenceRequirement> {
  const requirements: Array<EvidenceRequirement> = [];

  for (let i = 0; i < claims.length; i++) {
    const claim = claims[i];

    const requirement = new EvidenceRequirement();
    requirement.claim_id = `claim_${i}`;

    // Evidence requirements based on claim type and medical domain
    switch (claim.claim_type) {
      case "treatment":
        requirement.required_evidence_type = "rct";
        requirement.minimum_studies = 3;
        requirement.preferred_databases = ["pubmed", "cochrane", "embase"];
        break;

      case "diagnosis":
        requirement.required_evidence_type = "cohort";
        requirement.minimum_studies = 2;
        requirement.preferred_databases = ["pubmed", "medline"];
        break;

      default:
        requirement.required_evidence_type = "expert_opinion";
        requirement.minimum_studies = 1;
        requirement.preferred_databases = ["pubmed"];
    }

    requirement.search_time_range = "5_years"; // Default 5-year search
    requirements.push(requirement);
  }

  return requirements;
}

function logClaimsExtractionAudit(output: MedicalClaimsOutput): void {
  const audit_data = {
    plugin_id: "s1_2_medical_claims",
    claims_extracted: output.medical_claims.length,
    evidence_requirements: output.evidence_requirements.length,
    confidence_score: output.confidence_score,
    timestamp: Date.now()
  };

  const audit_json = JSON.stringify(audit_data);
  const audit_buffer = String.UTF8.encode(audit_json);

  hostLogAudit(changetype<usize>(audit_buffer), audit_buffer.byteLength);
}
```

### 3. **S.2-1.2 - Scientific Search Engine (Go WASM)**

```go
// DSM:PLUGIN:s2_1_2_scientific_search GO_IMPLEMENTATION PRIORITY:HIGH
package main

import (
    "encoding/json"
    "fmt"
    "strings"
    "syscall/js"
)

type ScientificSearchInput struct {
    MedicalClaims     []MedicalClaim       `json:"medical_claims"`
    EvidenceReqs      []EvidenceRequirement `json:"evidence_requirements"`
    SearchConfig      SearchConfiguration  `json:"search_config"`
}

type ScientificSearchOutput struct {
    SearchResults     []SearchResult       `json:"search_results"`
    QualityMetrics    QualityAssessment    `json:"quality_metrics"`
    EvidenceSummary   EvidenceSummary      `json:"evidence_summary"`
    ReferencesFound   []ScientificReference `json:"references_found"`
    ConfidenceScore   float64              `json:"confidence_score"`
}

type SearchResult struct {
    ClaimID           string               `json:"claim_id"`
    Query             string               `json:"query"`
    Database          string               `json:"database"`
    ResultsCount      int                  `json:"results_count"`
    TopReferences     []ScientificReference `json:"top_references"`
    EvidenceLevel     string               `json:"evidence_level"`
    SearchTime        int64                `json:"search_time_ms"`
}

type ScientificReference struct {
    Title             string               `json:"title"`
    Authors           []string             `json:"authors"`
    Journal           string               `json:"journal"`
    Year              int                  `json:"year"`
    DOI               string               `json:"doi"`
    PubMedID          string               `json:"pubmed_id"`
    EvidenceLevel     string               `json:"evidence_level"`
    RelevanceScore    float64              `json:"relevance_score"`
    QualityScore      float64              `json:"quality_score"`
    Abstract          string               `json:"abstract"`
    StudyType         string               `json:"study_type"`
    SampleSize        int                  `json:"sample_size"`
    ImpactFactor      float64              `json:"impact_factor"`
}

// Host capability imports
//go:export search_pubmed
func searchPubMed(query *byte, queryLen int) int32

//go:export search_cochrane
func searchCochrane(query *byte, queryLen int) int32

//go:export get_search_result
func getSearchResult(resultID int32) *byte

//go:export log_audit_event
func logAuditEvent(data *byte, dataLen int)

//go:export perform_scientific_search
func performScientificSearch(inputPtr *byte, inputLen int) *byte {
    // Parse input JSON
    inputBytes := make([]byte, inputLen)
    js.CopyBytesToGo(inputBytes, js.ValueOf(inputPtr))

    var input ScientificSearchInput
    if err := json.Unmarshal(inputBytes, &input); err != nil {
        return marshalError(fmt.Sprintf("Input parsing error: %v", err))
    }

    // Initialize output structure
    output := ScientificSearchOutput{
        SearchResults:   make([]SearchResult, 0),
        ReferencesFound: make([]ScientificReference, 0),
    }

    // Process each medical claim
    for _, claim := range input.MedicalClaims {
        searchResult := processClaimSearch(claim, input.EvidenceReqs, input.SearchConfig)
        output.SearchResults = append(output.SearchResults, searchResult)
        output.ReferencesFound = append(output.ReferencesFound, searchResult.TopReferences...)
    }

    // Calculate quality metrics
    output.QualityMetrics = calculateQualityMetrics(output.SearchResults)

    // Generate evidence summary
    output.EvidenceSummary = generateEvidenceSummary(output.ReferencesFound)

    // Calculate overall confidence
    output.ConfidenceScore = calculateSearchConfidence(output.SearchResults)

    // Audit logging
    logScientificSearchAudit(output)

    // Marshal output
    outputBytes, _ := json.Marshal(output)
    return bytesToWASMPtr(outputBytes)
}

func processClaimSearch(claim MedicalClaim, evidenceReqs []EvidenceRequirement, config SearchConfiguration) SearchResult {
    result := SearchResult{
        ClaimID:       claim.ClaimID,
        TopReferences: make([]ScientificReference, 0),
    }

    // Find corresponding evidence requirement
    var evidenceReq *EvidenceRequirement
    for _, req := range evidenceReqs {
        if req.ClaimID == claim.ClaimID {
            evidenceReq = &req
            break
        }
    }

    if evidenceReq == nil {
        return result
    }

    // Generate optimized search queries
    queries := generateSearchQueries(claim, *evidenceReq)

    // Search across specified databases
    allReferences := make([]ScientificReference, 0)

    for _, database := range evidenceReq.PreferredDatabases {
        for _, query := range queries {
            refs := searchDatabase(database, query, config)
            allReferences = append(allReferences, refs...)
        }
    }

    // Deduplicate and rank references
    uniqueReferences := deduplicateReferences(allReferences)
    rankedReferences := rankReferencesByQuality(uniqueReferences, claim)

    // Select top references based on evidence requirement
    topCount := evidenceReq.MinimumStudies * 2 // Get extras for selection
    if len(rankedReferences) < topCount {
        topCount = len(rankedReferences)
    }

    result.TopReferences = rankedReferences[:topCount]
    result.ResultsCount = len(allReferences)
    result.EvidenceLevel = determineEvidenceLevel(result.TopReferences)

    return result
}

func generateSearchQueries(claim MedicalClaim, evidenceReq EvidenceRequirement) []string {
    queries := make([]string, 0)

    // Base query from claim text
    baseQuery := sanitizeSearchTerm(claim.ClaimText)

    // Add evidence type filters
    switch evidenceReq.RequiredEvidenceType {
    case "rct":
        queries = append(queries, baseQuery+" AND (randomized controlled trial OR RCT)")
        queries = append(queries, baseQuery+" AND randomized AND controlled")

    case "cohort":
        queries = append(queries, baseQuery+" AND (cohort study OR longitudinal)")
        queries = append(queries, baseQuery+" AND prospective")

    case "case_control":
        queries = append(queries, baseQuery+" AND case-control")
        queries = append(queries, baseQuery+" AND retrospective")

    default:
        queries = append(queries, baseQuery)
    }

    // Add medical domain specificity
    if claim.MedicalDomain != "" {
        domainQuery := baseQuery + " AND " + claim.MedicalDomain
        queries = append(queries, domainQuery)
    }

    // Add time range filter
    if evidenceReq.SearchTimeRange != "all_time" {
        timeFilter := generateTimeRangeFilter(evidenceReq.SearchTimeRange)
        for i, query := range queries {
            queries[i] = query + " AND " + timeFilter
        }
    }

    return queries
}

func searchDatabase(database, query string, config SearchConfiguration) []ScientificReference {
    references := make([]ScientificReference, 0)

    // Call host-provided search capabilities
    switch database {
    case "pubmed":
        resultID := searchPubMed(stringToWASMPtr(query), len(query))
        if resultID > 0 {
            resultBytes := getSearchResult(resultID)
            references = parseSearchResults(resultBytes, "pubmed")
        }

    case "cochrane":
        resultID := searchCochrane(stringToWASMPtr(query), len(query))
        if resultID > 0 {
            resultBytes := getSearchResult(resultID)
            references = parseSearchResults(resultBytes, "cochrane")
        }

    // Additional databases can be added here
    }

    return references
}

func rankReferencesByQuality(references []ScientificReference, claim MedicalClaim) []ScientificReference {
    // Implement sophisticated ranking algorithm
    for i := range references {
        ref := &references[i]

        // Calculate quality score based on multiple factors
        qualityScore := 0.0

        // Impact factor weight (30%)
        if ref.ImpactFactor > 0 {
            qualityScore += (ref.ImpactFactor / 10.0) * 0.3
        }

        // Evidence level weight (25%)
        evidenceWeight := map[string]float64{
            "I":   1.0,
            "II":  0.8,
            "III": 0.6,
            "IV":  0.4,
        }
        if weight, exists := evidenceWeight[ref.EvidenceLevel]; exists {
            qualityScore += weight * 0.25
        }

        // Recency weight (20%)
        currentYear := 2025
        yearsAgo := currentYear - ref.Year
        recencyScore := 1.0 - (float64(yearsAgo) / 20.0) // Diminishes over 20 years
        if recencyScore < 0 {
            recencyScore = 0
        }
        qualityScore += recencyScore * 0.2

        // Sample size weight (15%)
        if ref.SampleSize > 0 {
            sampleScore := 1.0 - (1.0 / (1.0 + float64(ref.SampleSize)/1000.0))
            qualityScore += sampleScore * 0.15
        }

        // Relevance score weight (10%)
        qualityScore += ref.RelevanceScore * 0.1

        ref.QualityScore = qualityScore
    }

    // Sort by quality score (descending)
    sortReferencesByQuality(references)

    return references
}

func calculateQualityMetrics(searchResults []SearchResult) QualityAssessment {
    assessment := QualityAssessment{}

    totalReferences := 0
    highQualityCount := 0
    evidenceLevelCounts := make(map[string]int)

    for _, result := range searchResults {
        totalReferences += len(result.TopReferences)

        for _, ref := range result.TopReferences {
            if ref.QualityScore > 0.7 {
                highQualityCount++
            }

            evidenceLevelCounts[ref.EvidenceLevel]++
        }
    }

    if totalReferences > 0 {
        assessment.HighQualityPercentage = float64(highQualityCount) / float64(totalReferences)
    }

    assessment.EvidenceLevelDistribution = evidenceLevelCounts
    assessment.TotalReferencesFound = totalReferences
    assessment.AverageQualityScore = calculateAverageQualityScore(searchResults)

    return assessment
}

func logScientificSearchAudit(output ScientificSearchOutput) {
    auditData := map[string]interface{}{
        "plugin_id":         "s2_1_2_scientific_search",
        "claims_processed":  len(output.SearchResults),
        "references_found":  len(output.ReferencesFound),
        "confidence_score":  output.ConfidenceScore,
        "quality_metrics":   output.QualityMetrics,
        "timestamp":         getCurrentTimestamp(),
    }

    auditBytes, _ := json.Marshal(auditData)
    logAuditEvent(bytesToWASMPtr(auditBytes), len(auditBytes))
}

func main() {
    // Required for Go WASM
    select {}
}
```

---

## Security Model: Capability-Based Isolation

### WASI Capability System

```yaml
# DSM:SECURITY:capability_based_isolation WASI_COMPLIANT
Capability_Security_Model:
  principle: "Principle of least privilege for healthcare data"
  implementation: "WASI (WebAssembly System Interface) capabilities"

  plugin_capabilities:
    s1_1_lgpd_analyzer:
      allowed_capabilities:
        - "read_input_content"
        - "write_analysis_output"
        - "log_audit_events"
      denied_capabilities:
        - "network_access"
        - "filesystem_access"
        - "host_memory_access"

    s2_1_2_scientific_search:
      allowed_capabilities:
        - "read_search_queries"
        - "call_search_apis"      # Host-mediated
        - "write_search_results"
        - "log_audit_events"
      denied_capabilities:
        - "direct_internet_access"
        - "cache_write_access"
        - "user_data_access"

  host_mediated_services:
    external_api_calls:
      description: "All external API calls go through host"
      rationale: "Zero Trust network access control"
      audit: "Complete request/response logging"

    data_persistence:
      description: "Plugins cannot directly write to storage"
      rationale: "Prevents data exfiltration"
      mechanism: "Host validates and stores plugin outputs"
```

### Memory Isolation

```elixir
# DSM:SECURITY:memory_isolation_implementation HOST_CONTROLS
defmodule HealthcareCms.Plugins.MemoryManager do
  @moduledoc """
  Manages WebAssembly plugin memory isolation for healthcare data security
  """

  # Memory limits per plugin type
  @memory_limits %{
    "s1_1_lgpd_analyzer" => 256_000_000,      # 256MB
    "s1_2_medical_claims" => 128_000_000,     # 128MB
    "s2_1_2_scientific_search" => 512_000_000, # 512MB
    "s3_2_seo_optimizer" => 128_000_000,      # 128MB
    "s4_1_1_3_content_generator" => 256_000_000 # 256MB
  }

  def execute_plugin_with_isolation(plugin_type, input_data, execution_context) do
    memory_limit = @memory_limits[plugin_type]

    # Create isolated plugin instance
    {:ok, plugin_instance} = Extism.Plugin.new(
      get_plugin_wasm_path(plugin_type),
      %{
        memory: %{max_pages: memory_limit div 65536}, # 64KB pages
        capabilities: get_plugin_capabilities(plugin_type),
        timeout_ms: 30_000  # 30 second timeout
      }
    )

    try do
      # Set up capability-controlled host functions
      setup_host_functions(plugin_instance, execution_context)

      # Execute plugin with input
      result = Extism.Plugin.call(plugin_instance, "main", input_data)

      # Audit execution
      audit_plugin_execution(plugin_type, execution_context, result)

      {:ok, result}
    rescue
      error ->
        # Log security violation
        log_security_violation(plugin_type, error, execution_context)
        {:error, :security_violation}
    after
      # Always cleanup plugin instance
      Extism.Plugin.free(plugin_instance)
    end
  end

  defp setup_host_functions(plugin_instance, execution_context) do
    # Medical data access function (capability-controlled)
    Extism.Plugin.register_host_function(
      plugin_instance,
      "get_medical_data",
      fn data ->
        if authorized_medical_access?(execution_context, data) do
          get_medical_data_with_audit(data, execution_context)
        else
          {:error, "Unauthorized medical data access"}
        end
      end
    )

    # External API access function (host-mediated)
    Extism.Plugin.register_host_function(
      plugin_instance,
      "call_external_api",
      fn api_request ->
        call_external_api_with_zero_trust(api_request, execution_context)
      end
    )

    # Audit logging function
    Extism.Plugin.register_host_function(
      plugin_instance,
      "log_audit_event",
      fn audit_data ->
        log_plugin_audit_event(audit_data, execution_context)
      end
    )
  end

  defp authorized_medical_access?(execution_context, data_request) do
    # Check Zero Trust policy for medical data access
    user_id = execution_context.user_id
    trust_evaluation = HealthcareCms.Security.ZeroTrust.PolicyEngine.evaluate_request(
      user_id,
      %{type: "medical_data", sensitivity: "high"},
      execution_context
    )

    trust_evaluation.decision in [:allow, :conditional]
  end
end
```

---

## Performance Benchmarks

### Target vs Achieved Performance

```yaml
# DSM:PERFORMANCE:plugin_benchmarks VALIDATED_TARGETS
Plugin_Performance_Metrics:
  execution_time_targets:
    s1_1_lgpd_analyzer: "<5s for 10k words"
    s1_2_medical_claims: "<2s for 5k words"
    s2_1_2_scientific_search: "<30s for 10 references"
    s3_2_seo_optimizer: "<60s for optimization"
    s4_1_1_3_content_generator: "<120s for final content"

  memory_usage_targets:
    maximum_per_plugin: "512MB"
    typical_usage: "128-256MB"
    memory_isolation: "100% between plugins"

  concurrency_targets:
    simultaneous_pipelines: "100+ concurrent executions"
    plugin_instances: "Isolated per execution"
    resource_sharing: "None (security requirement)"

  # Current status: Architecture prepared, implementation pending
  implementation_status:
    extism_integration: "Pending - runtime setup needed"
    plugin_development: "Specifications complete"
    host_functions: "Interface designed"
    security_testing: "Framework prepared"
```

---

## Implementation Status

### Healthcare CMS v1.0.0 Status

```yaml
# DSM:STATUS:webassembly_implementation ARCHITECTURE_READY
Implementation_Status:
  architecture_design: "✅ Complete"
  plugin_specifications: "✅ Complete"
  security_model: "✅ Designed"
  capability_system: "✅ Planned"

  pending_implementation:
    extism_runtime_setup: "🔄 Next phase priority"
    plugin_compilation: "🔄 Rust/Go/AssemblyScript setup needed"
    host_function_integration: "🔄 Elixir host functions"
    performance_testing: "🔄 Load testing framework"

  validation_criteria:
    security_isolation: "Penetration testing required"
    performance_sla: "All targets must be met"
    healthcare_compliance: "LGPD/CFM/ANVISA validation"
    audit_trail: "Complete traceability verification"
```

### Next Implementation Steps

1. **Extism Runtime Setup**: Install and configure Extism in Elixir environment
2. **Plugin Development**: Compile Rust/Go/AssemblyScript plugins to WASM
3. **Host Integration**: Implement Elixir host functions with capability control
4. **Security Testing**: Validate sandbox isolation and capability restrictions
5. **Performance Validation**: Load testing to verify <5s execution targets

---

## Alternatives Rejected

### Why not Native Elixir Processes?
- **Language Diversity**: Medical algorithms benefit from Rust/Go performance
- **Security Isolation**: Less granular than WASM sandbox
- **Third-party Code**: WASM provides better isolation for external algorithms

### Why not Docker Containers?
- **Resource Overhead**: Higher memory/CPU usage vs WASM
- **Security Surface**: Larger attack surface than WASM sandbox
- **Performance**: Container startup time vs instant WASM execution

### Why not Microservices?
- **Network Latency**: Internal network calls vs direct memory
- **Security Complexity**: More network attack vectors
- **Resource Usage**: Higher infrastructure requirements

---

## Compliance & Audit

### LGPD Compliance
- ✅ **Data Minimization**: Plugins only receive necessary data
- ✅ **Access Control**: Capability-based permissions
- ✅ **Audit Trail**: Complete execution logging
- ✅ **Data Isolation**: No cross-plugin data sharing

### CFM Medical Standards
- ✅ **Professional Validation**: Medical content workflow integration
- ✅ **Evidence Requirements**: Scientific validation enforcement
- ✅ **Content Approval**: Professional review workflow
- ✅ **Compliance Documentation**: Complete audit documentation

---

## Monitoring & Observability

### Plugin Execution Monitoring
```elixir
# DSM:MONITORING:plugin_observability REAL_TIME_METRICS
defmodule HealthcareCms.Plugins.Metrics do
  @moduledoc """
  Real-time monitoring for WebAssembly plugin execution
  """

  def get_plugin_metrics do
    %{
      execution_metrics: %{
        total_executions_last_hour: get_execution_count(:last_hour),
        average_execution_time: get_average_execution_time(),
        success_rate: get_success_rate(),
        error_rate: get_error_rate()
      },
      performance_metrics: %{
        memory_usage_by_plugin: get_memory_usage_by_plugin(),
        cpu_usage_by_plugin: get_cpu_usage_by_plugin(),
        concurrent_executions: get_concurrent_execution_count()
      },
      security_metrics: %{
        capability_violations: get_capability_violations_count(),
        sandbox_escapes: get_sandbox_escape_attempts(),
        unauthorized_access_attempts: get_unauthorized_access_count()
      },
      healthcare_metrics: %{
        medical_workflows_completed: get_medical_workflow_count(),
        lgpd_compliance_violations: get_lgpd_violations_count(),
        audit_trail_integrity: verify_audit_integrity()
      }
    }
  end
end
```

---

## Referências

### WebAssembly Standards
- **WASI**: WebAssembly System Interface specification
- **Extism**: Universal WebAssembly runtime documentation
- **Capability Security**: Object-capability model principles

### Healthcare Compliance
- **LGPD**: Data processing and security requirements
- **CFM Resolution 2.299/2022**: Medical professional digital standards
- **ANVISA**: Medical device software requirements

### Implementation Evidence
- **Architecture Design**: Complete plugin system specification
- **Security Model**: Capability-based isolation framework
- **Performance Targets**: Evidence-based SLA definitions

---

*ADR criado: 25 de Janeiro de 2025*
*Última revisão: 29 de Setembro de 2025*
*Status: ACEITO - Architecture ready, implementation next phase*