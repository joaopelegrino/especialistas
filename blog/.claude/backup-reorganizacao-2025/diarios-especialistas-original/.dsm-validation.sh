#!/bin/bash
# DSM Quality Validation Script
# Healthcare WASM-Elixir Stack - Context Preservation Validator

set -e

echo "🔍 DSM Context Preservation Validation"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Function to log results
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
    log_result "FAIL" "DSM configuration file not found" "Run this script in the diarios-especialistas directory"
    exit 1
fi

echo -e "${BLUE}Checking DSM implementation quality...${NC}"
echo ""

# 1. Check DSM configuration file
echo "1. DSM Configuration Validation"
echo "--------------------------------"

if [ -f ".dsm-config.yml" ]; then
    log_result "PASS" "DSM configuration file exists"

    # Check for required sections
    if grep -q "tagging_structure:" ".dsm-config.yml"; then
        log_result "PASS" "Tagging structure defined"
    else
        log_result "FAIL" "Missing tagging structure in DSM config"
    fi

    if grep -q "healthcare_context:" ".dsm-config.yml"; then
        log_result "PASS" "Healthcare context defined"
    else
        log_result "FAIL" "Missing healthcare context in DSM config"
    fi

    if grep -q "performance_targets:" ".dsm-config.yml"; then
        log_result "PASS" "Performance targets defined"
    else
        log_result "FAIL" "Missing performance targets in DSM config"
    fi
else
    log_result "FAIL" "DSM configuration file missing"
fi

echo ""

# 2. Check LLM optimization file
echo "2. LLM Optimization File Validation"
echo "------------------------------------"

if [ -f "llms.txt" ]; then
    log_result "PASS" "LLM optimization file exists"

    # Check content requirements
    if grep -q "SYSTEM OVERVIEW" "llms.txt"; then
        log_result "PASS" "System overview section present"
    else
        log_result "FAIL" "Missing system overview in llms.txt"
    fi

    if grep -q "HEALTHCARE DOMAIN CONTEXT" "llms.txt"; then
        log_result "PASS" "Healthcare domain context present"
    else
        log_result "FAIL" "Missing healthcare domain context in llms.txt"
    fi

    if grep -q "PERFORMANCE CONTRACTS" "llms.txt"; then
        log_result "PASS" "Performance contracts documented"
    else
        log_result "FAIL" "Missing performance contracts in llms.txt"
    fi

    # Check for healthcare compliance context
    if grep -q "LGPD" "llms.txt" && grep -q "CFM" "llms.txt"; then
        log_result "PASS" "Healthcare compliance context present"
    else
        log_result "WARN" "Healthcare compliance context may be incomplete"
    fi
else
    log_result "FAIL" "LLM optimization file missing"
fi

echo ""

# 3. Check DSM tags in markdown files
echo "3. DSM Header Tags Validation"
echo "------------------------------"

md_files=$(find . -name "*.md" -not -path "./.git/*" | wc -l)
tagged_files=0
healthcare_tagged=0
performance_tagged=0
compliance_tagged=0

for file in *.md; do
    if [ -f "$file" ]; then
        # Check for DSM header tags
        if grep -q "<!-- DSM:" "$file"; then
            tagged_files=$((tagged_files + 1))

            # Check for healthcare context
            if grep -q "DSM:HEALTHCARE:" "$file"; then
                healthcare_tagged=$((healthcare_tagged + 1))
            fi

            # Check for performance context
            if grep -q "DSM:PERFORMANCE:" "$file"; then
                performance_tagged=$((performance_tagged + 1))
            fi

            # Check for compliance context
            if grep -q "DSM:COMPLIANCE:" "$file"; then
                compliance_tagged=$((compliance_tagged + 1))
            fi
        fi
    fi
done

if [ $md_files -gt 0 ]; then
    coverage_percent=$((tagged_files * 100 / md_files))

    if [ $coverage_percent -ge 80 ]; then
        log_result "PASS" "DSM tag coverage: $coverage_percent% ($tagged_files/$md_files files)"
    elif [ $coverage_percent -ge 50 ]; then
        log_result "WARN" "DSM tag coverage: $coverage_percent% ($tagged_files/$md_files files)" "Target: 80%+"
    else
        log_result "FAIL" "DSM tag coverage: $coverage_percent% ($tagged_files/$md_files files)" "Target: 80%+"
    fi

    # Healthcare context coverage
    healthcare_percent=$((healthcare_tagged * 100 / md_files))
    if [ $healthcare_percent -ge 70 ]; then
        log_result "PASS" "Healthcare context coverage: $healthcare_percent%"
    else
        log_result "WARN" "Healthcare context coverage: $healthcare_percent%" "Target: 70%+"
    fi

    # Performance context coverage
    performance_percent=$((performance_tagged * 100 / md_files))
    if [ $performance_percent -ge 60 ]; then
        log_result "PASS" "Performance context coverage: $performance_percent%"
    else
        log_result "WARN" "Performance context coverage: $performance_percent%" "Target: 60%+"
    fi
else
    log_result "WARN" "No markdown files found for validation"
fi

echo ""

# 4. Check DSM dependency matrices
echo "4. Dependency Matrix Validation"
echo "-------------------------------"

matrix_files=0
complete_matrices=0

for file in *.md; do
    if [ -f "$file" ]; then
        if grep -q "DSM_MATRIX:" "$file"; then
            matrix_files=$((matrix_files + 1))

            # Check for complete matrix structure
            if grep -q "depends_on:" "$file" && \
               grep -q "provides_to:" "$file" && \
               grep -q "integrates_with:" "$file"; then
                complete_matrices=$((complete_matrices + 1))
            fi
        fi
    fi
done

if [ $matrix_files -gt 0 ]; then
    matrix_percent=$((complete_matrices * 100 / matrix_files))

    if [ $matrix_percent -ge 90 ]; then
        log_result "PASS" "Complete dependency matrices: $matrix_percent% ($complete_matrices/$matrix_files)"
    elif [ $matrix_percent -ge 70 ]; then
        log_result "WARN" "Complete dependency matrices: $matrix_percent% ($complete_matrices/$matrix_files)" "Target: 90%+"
    else
        log_result "FAIL" "Complete dependency matrices: $matrix_percent% ($complete_matrices/$matrix_files)" "Target: 90%+"
    fi
else
    log_result "WARN" "No dependency matrices found"
fi

echo ""

# 5. Check context preservation rules
echo "5. Context Preservation Rules Validation"
echo "-----------------------------------------"

if [ -f ".context-preservation-rules.md" ]; then
    log_result "PASS" "Context preservation rules file exists"

    # Check for mandatory sections
    if grep -q "Mandatory Context Elements" ".context-preservation-rules.md"; then
        log_result "PASS" "Mandatory context elements defined"
    else
        log_result "FAIL" "Missing mandatory context elements"
    fi

    if grep -q "Healthcare-Specific Context Requirements" ".context-preservation-rules.md"; then
        log_result "PASS" "Healthcare-specific context requirements defined"
    else
        log_result "FAIL" "Missing healthcare-specific context requirements"
    fi

    if grep -q "Quality Metrics for Context Preservation" ".context-preservation-rules.md"; then
        log_result "PASS" "Quality metrics defined"
    else
        log_result "WARN" "Missing quality metrics definition"
    fi
else
    log_result "FAIL" "Context preservation rules file missing"
fi

echo ""

# 6. Check healthcare compliance context
echo "6. Healthcare Compliance Context Validation"
echo "--------------------------------------------"

# Check for LGPD compliance context
lgpd_mentions=$(grep -r "LGPD" *.md 2>/dev/null | wc -l)
cfm_mentions=$(grep -r "CFM" *.md 2>/dev/null | wc -l)
zero_trust_mentions=$(grep -r -i "zero.trust" *.md 2>/dev/null | wc -l)

if [ $lgpd_mentions -ge 3 ]; then
    log_result "PASS" "LGPD compliance context present ($lgpd_mentions mentions)"
else
    log_result "WARN" "Limited LGPD compliance context ($lgpd_mentions mentions)" "Target: 3+ mentions"
fi

if [ $cfm_mentions -ge 2 ]; then
    log_result "PASS" "CFM compliance context present ($cfm_mentions mentions)"
else
    log_result "WARN" "Limited CFM compliance context ($cfm_mentions mentions)" "Target: 2+ mentions"
fi

if [ $zero_trust_mentions -ge 3 ]; then
    log_result "PASS" "Zero Trust security context present ($zero_trust_mentions mentions)"
else
    log_result "WARN" "Limited Zero Trust security context ($zero_trust_mentions mentions)" "Target: 3+ mentions"
fi

echo ""

# 7. Performance context validation
echo "7. Performance Context Validation"
echo "----------------------------------"

# Check for performance targets
response_time_mentions=$(grep -r -i "50ms\|response.*time" *.md 2>/dev/null | wc -l)
concurrency_mentions=$(grep -r -i "2M\|concurrent" *.md 2>/dev/null | wc -l)
availability_mentions=$(grep -r -i "99\.99\|availability" *.md 2>/dev/null | wc -l)

if [ $response_time_mentions -ge 2 ]; then
    log_result "PASS" "Response time targets documented ($response_time_mentions mentions)"
else
    log_result "WARN" "Limited response time context ($response_time_mentions mentions)" "Target: 2+ mentions"
fi

if [ $concurrency_mentions -ge 2 ]; then
    log_result "PASS" "Concurrency targets documented ($concurrency_mentions mentions)"
else
    log_result "WARN" "Limited concurrency context ($concurrency_mentions mentions)" "Target: 2+ mentions"
fi

if [ $availability_mentions -ge 1 ]; then
    log_result "PASS" "Availability targets documented ($availability_mentions mentions)"
else
    log_result "WARN" "Limited availability context ($availability_mentions mentions)" "Target: 1+ mentions"
fi

echo ""

# Summary
echo "8. Validation Summary"
echo "====================="

total_quality_score=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo -e "${BLUE}Total Checks${NC}: $TOTAL_CHECKS"
echo -e "${GREEN}Passed${NC}: $PASSED_CHECKS"
echo -e "${YELLOW}Warnings${NC}: $WARNING_CHECKS"
echo -e "${RED}Failed${NC}: $FAILED_CHECKS"
echo ""

if [ $total_quality_score -ge 90 ]; then
    echo -e "${GREEN}🎉 EXCELLENT${NC}: DSM implementation quality score: $total_quality_score%"
    echo -e "${GREEN}Context preservation is well-implemented and ready for production use.${NC}"
    exit_code=0
elif [ $total_quality_score -ge 80 ]; then
    echo -e "${YELLOW}👍 GOOD${NC}: DSM implementation quality score: $total_quality_score%"
    echo -e "${YELLOW}Context preservation is good but could be improved. Address warnings.${NC}"
    exit_code=0
elif [ $total_quality_score -ge 70 ]; then
    echo -e "${YELLOW}⚠️  ACCEPTABLE${NC}: DSM implementation quality score: $total_quality_score%"
    echo -e "${YELLOW}Context preservation needs improvement. Address failures and warnings.${NC}"
    exit_code=1
else
    echo -e "${RED}❌ NEEDS WORK${NC}: DSM implementation quality score: $total_quality_score%"
    echo -e "${RED}Context preservation implementation is incomplete. Address all issues.${NC}"
    exit_code=1
fi

echo ""
echo -e "${BLUE}Healthcare Context Preservation Status${NC}:"
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ Ready for healthcare production use${NC}"
else
    echo -e "${RED}❌ Not ready for healthcare production - address failures first${NC}"
fi

echo ""
echo "For detailed context preservation requirements, see:"
echo "- .context-preservation-rules.md"
echo "- .dsm-config.yml"
echo "- llms.txt"

exit $exit_code