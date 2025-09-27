#!/bin/bash
# DSM Knowledge Base Validation Script
# Healthcare Knowledge Management System

set -e

echo "🔍 DSM Knowledge Base Validation"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

log_result() {
    local status=$1
    local message=$2
    local details=$3

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            if [ -n "$details" ]; then
                echo -e "   ${RED}Details${NC}: $details"
            fi
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            if [ -n "$details" ]; then
                echo -e "   ${YELLOW}Details${NC}: $details"
            fi
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            ;;
    esac
}

# Check if running in correct directory
if [ ! -f ".dsm-config.yml" ]; then
    log_result "FAIL" "DSM configuration file not found" "Run this script in the knowledge-base directory"
    exit 1
fi

echo -e "${BLUE}Checking DSM knowledge base implementation...${NC}"
echo ""

# 1. Check DSM configuration files
echo "1. DSM Configuration Validation"
echo "--------------------------------"

if [ -f ".dsm-config.yml" ]; then
    log_result "PASS" "DSM configuration file exists"

    if grep -q "healthcare_knowledge_management" ".dsm-config.yml"; then
        log_result "PASS" "Healthcare domain configured"
    else
        log_result "FAIL" "Missing healthcare domain configuration"
    fi

    if grep -q "tagging_structure:" ".dsm-config.yml"; then
        log_result "PASS" "Tagging structure defined"
    else
        log_result "FAIL" "Missing tagging structure"
    fi
else
    log_result "FAIL" "DSM configuration file missing"
fi

if [ -f "llms.txt" ]; then
    log_result "PASS" "LLM optimization file exists"

    if grep -q "Healthcare Knowledge Base" "llms.txt"; then
        log_result "PASS" "Healthcare context in llms.txt"
    else
        log_result "FAIL" "Missing healthcare context in llms.txt"
    fi
else
    log_result "FAIL" "LLM optimization file missing"
fi

echo ""

# 2. Check DSM tags in knowledge base files
echo "2. DSM Header Tags Validation"
echo "------------------------------"

md_files=$(find . -name "*.md" -not -path "./.git/*" | wc -l)
tagged_files=0
healthcare_tagged=0
compliance_tagged=0
performance_tagged=0

for file in $(find . -name "*.md" -not -path "./.git/*"); do
    if [ -f "$file" ]; then
        if grep -q "<!-- DSM:" "$file"; then
            tagged_files=$((tagged_files + 1))

            if grep -q "DSM:HEALTHCARE:" "$file"; then
                healthcare_tagged=$((healthcare_tagged + 1))
            fi

            if grep -q "DSM:PERFORMANCE:" "$file"; then
                performance_tagged=$((performance_tagged + 1))
            fi

            if grep -q "DSM:COMPLIANCE:" "$file"; then
                compliance_tagged=$((compliance_tagged + 1))
            fi
        fi
    fi
done

if [ $md_files -gt 0 ]; then
    coverage_percent=$((tagged_files * 100 / md_files))

    if [ $coverage_percent -ge 30 ]; then
        log_result "PASS" "DSM tag coverage: $coverage_percent% ($tagged_files/$md_files files)"
    elif [ $coverage_percent -ge 15 ]; then
        log_result "WARN" "DSM tag coverage: $coverage_percent% ($tagged_files/$md_files files)" "Target: 30%+"
    else
        log_result "FAIL" "DSM tag coverage: $coverage_percent% ($tagged_files/$md_files files)" "Target: 30%+"
    fi

    healthcare_percent=$((healthcare_tagged * 100 / md_files))
    if [ $healthcare_percent -ge 20 ]; then
        log_result "PASS" "Healthcare context coverage: $healthcare_percent%"
    else
        log_result "WARN" "Healthcare context coverage: $healthcare_percent%" "Target: 20%+"
    fi
else
    log_result "WARN" "No markdown files found for validation"
fi

echo ""

# 3. Check knowledge area structure
echo "3. Knowledge Area Structure Validation"
echo "---------------------------------------"

required_areas=("boas-praticas" "healthcare-systems" "security-architecture" "programming-languages" "protocols-standards")
found_areas=0

for area in "${required_areas[@]}"; do
    if [ -d "$area" ]; then
        found_areas=$((found_areas + 1))
        log_result "PASS" "Knowledge area exists: $area"
    else
        log_result "WARN" "Knowledge area missing: $area"
    fi
done

coverage_areas=$((found_areas * 100 / ${#required_areas[@]}))
if [ $coverage_areas -ge 80 ]; then
    log_result "PASS" "Knowledge area coverage: $coverage_areas%"
else
    log_result "WARN" "Knowledge area coverage: $coverage_areas%" "Target: 80%+"
fi

echo ""

# 4. Check healthcare compliance content
echo "4. Healthcare Compliance Content Validation"
echo "--------------------------------------------"

lgpd_mentions=$(grep -r "LGPD" . --include="*.md" 2>/dev/null | wc -l)
cfm_mentions=$(grep -r "CFM" . --include="*.md" 2>/dev/null | wc -l)
anvisa_mentions=$(grep -r "ANVISA" . --include="*.md" 2>/dev/null | wc -l)
fhir_mentions=$(grep -r "FHIR" . --include="*.md" 2>/dev/null | wc -l)

if [ $lgpd_mentions -ge 5 ]; then
    log_result "PASS" "LGPD compliance content present ($lgpd_mentions mentions)"
else
    log_result "WARN" "Limited LGPD compliance content ($lgpd_mentions mentions)" "Target: 5+ mentions"
fi

if [ $cfm_mentions -ge 3 ]; then
    log_result "PASS" "CFM compliance content present ($cfm_mentions mentions)"
else
    log_result "WARN" "Limited CFM compliance content ($cfm_mentions mentions)" "Target: 3+ mentions"
fi

if [ $fhir_mentions -ge 5 ]; then
    log_result "PASS" "FHIR healthcare standard content present ($fhir_mentions mentions)"
else
    log_result "WARN" "Limited FHIR content ($fhir_mentions mentions)" "Target: 5+ mentions"
fi

echo ""

# 5. Check performance and quality metrics
echo "5. Performance Context Validation"
echo "----------------------------------"

performance_sla_mentions=$(grep -r -i "50ms\|2M\|99\.99" . --include="*.md" 2>/dev/null | wc -l)
zero_trust_mentions=$(grep -r -i "zero.trust\|NIST.*800-207" . --include="*.md" 2>/dev/null | wc -l)
quantum_crypto_mentions=$(grep -r -i "quantum\|CRYSTALS\|Kyber\|Dilithium" . --include="*.md" 2>/dev/null | wc -l)

if [ $performance_sla_mentions -ge 3 ]; then
    log_result "PASS" "Healthcare SLA targets documented ($performance_sla_mentions mentions)"
else
    log_result "WARN" "Limited healthcare SLA documentation ($performance_sla_mentions mentions)" "Target: 3+ mentions"
fi

if [ $zero_trust_mentions -ge 3 ]; then
    log_result "PASS" "Zero Trust security content present ($zero_trust_mentions mentions)"
else
    log_result "WARN" "Limited Zero Trust content ($zero_trust_mentions mentions)" "Target: 3+ mentions"
fi

if [ $quantum_crypto_mentions -ge 1 ]; then
    log_result "PASS" "Post-quantum cryptography content present ($quantum_crypto_mentions mentions)"
else
    log_result "WARN" "Limited quantum cryptography content ($quantum_crypto_mentions mentions)" "Target: 1+ mentions"
fi

echo ""

# Summary
echo "6. Validation Summary"
echo "====================="

total_quality_score=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo -e "${BLUE}Total Checks${NC}: $TOTAL_CHECKS"
echo -e "${GREEN}Passed${NC}: $PASSED_CHECKS"
echo -e "${YELLOW}Warnings${NC}: $WARNING_CHECKS"
echo -e "${RED}Failed${NC}: $FAILED_CHECKS"
echo ""

if [ $total_quality_score -ge 85 ]; then
    echo -e "${GREEN}🎉 EXCELLENT${NC}: DSM knowledge base quality score: $total_quality_score%"
    echo -e "${GREEN}Knowledge base is well-structured and ready for healthcare development.${NC}"
    exit_code=0
elif [ $total_quality_score -ge 70 ]; then
    echo -e "${YELLOW}👍 GOOD${NC}: DSM knowledge base quality score: $total_quality_score%"
    echo -e "${YELLOW}Knowledge base is functional but could be improved. Address warnings.${NC}"
    exit_code=0
elif [ $total_quality_score -ge 60 ]; then
    echo -e "${YELLOW}⚠️  ACCEPTABLE${NC}: DSM knowledge base quality score: $total_quality_score%"
    echo -e "${YELLOW}Knowledge base needs improvement. Address failures and warnings.${NC}"
    exit_code=1
else
    echo -e "${RED}❌ NEEDS WORK${NC}: DSM knowledge base quality score: $total_quality_score%"
    echo -e "${RED}Knowledge base structure is incomplete. Address all issues.${NC}"
    exit_code=1
fi

echo ""
echo -e "${BLUE}Healthcare Knowledge Base Status${NC}:"
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ Ready for healthcare development use${NC}"
else
    echo -e "${RED}❌ Not ready for healthcare development - address failures first${NC}"
fi

echo ""
echo "For detailed DSM implementation guidelines, see:"
echo "- .dsm-config.yml"
echo "- llms.txt"
echo "- boas-praticas/matriz-dependencia-contextualizacao-llm-programadores.md"

exit $exit_code