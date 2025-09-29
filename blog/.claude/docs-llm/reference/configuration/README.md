# Configuration Reference - Healthcare CMS Pipeline

<!-- DSM:REFERENCE:configuration L4:meta_documentation HEALTHCARE:pipeline_setup -->

## 📁 **Configuration Files Structure**

Esta pasta contém os arquivos de configuração centrais para o pipeline de desenvolvimento Healthcare CMS.

### **requirement-lifecycle-config.yml**
```yaml
Purpose: "Pipeline de 4 fases: IMPLEMENTADO → TESTADO LLM → TESTADO HUMANO → DOCUMENTADO"
Scope: "Definição completa do lifecycle de requirements"
Usage: "Referência para quality gates e evidence requirements"
```

### **prd-config.yml**
```yaml
Purpose: "Configuração de integração PRD como fonte central de status"
Scope: "Quick access sections, navigation shortcuts, status breakdown"
Usage: "Otimização do uso do PRD como single source of truth"
```

## 🔗 **Related Documentation**

### **Process Documentation**
- `../processes/human-validation-process.md` - Stage 3 validation process
- `../requirement-progress-report.md` - Current status breakdown

### **Implementation Guides**
- `../../PIPELINE-4-FASES-README.md` - Complete pipeline overview
- `../../PRD-INTEGRATION-README.md` - PRD integration setup

### **Commands**
- `../../commands/prd-status.md` - Quick status check
- `../../commands/llm.md` - Updated LLM guidelines

## 🎯 **Quick References**

### **Pipeline Status Check**
```bash
# Primary PRD reference
@PRD_AGNOSTICO_STACK_RESEARCH.md

# Quick status overview
@.claude/commands/prd-status.md

# Detailed progress breakdown
@.claude/docs-llm/reference/requirement-progress-report.md
```

### **Configuration Usage**
```bash
# Lifecycle configuration
@.claude/docs-llm/reference/configuration/requirement-lifecycle-config.yml

# PRD integration setup
@.claude/docs-llm/reference/configuration/prd-config.yml

# Human validation process
@.claude/docs-llm/processes/human-validation-process.md
```

---

**Maintained by**: Healthcare CMS Pipeline Team
**Last Updated**: September 2025
**Version**: 4-Stage Pipeline v1.0