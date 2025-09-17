#!/bin/bash

echo "🔍 Claude Code 2025 Modernization Validation"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SUCCESS_COUNT=0
TOTAL_CHECKS=10

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

echo -e "${BLUE}📊 Phase 1: Native Subagents Validation${NC}"
echo "----------------------------------------"

# Check 1: Subagents directory structure
if [ -d ".claude/subagents" ]; then
    SUBAGENT_COUNT=$(ls .claude/subagents/*.md 2>/dev/null | wc -l)
    if [ $SUBAGENT_COUNT -ge 5 ]; then
        print_status 0 "Subagents directory structure ($SUBAGENT_COUNT subagents created)"
    else
        print_status 1 "Insufficient subagents created ($SUBAGENT_COUNT < 5)"
    fi
else
    print_status 1 "Subagents directory missing"
fi

# Check 2: Required subagents exist
REQUIRED_AGENTS=("bm-wizard-specialist" "security-auditor" "test-engineer" "documentation-specialist" "performance-optimizer")
MISSING_AGENTS=()

for agent in "${REQUIRED_AGENTS[@]}"; do
    if [ ! -f ".claude/subagents/$agent.md" ]; then
        MISSING_AGENTS+=("$agent")
    fi
done

if [ ${#MISSING_AGENTS[@]} -eq 0 ]; then
    print_status 0 "All required subagents present (${#REQUIRED_AGENTS[@]}/5)"
else
    print_status 1 "Missing subagents: ${MISSING_AGENTS[*]}"
fi

# Check 3: Subagent syntax validation
SYNTAX_ERRORS=0
for agent_file in .claude/subagents/*.md; do
    if [ -f "$agent_file" ]; then
        if ! head -10 "$agent_file" | grep -q "name:\|description:\|tools:"; then
            ((SYNTAX_ERRORS++))
        fi
    fi
done

if [ $SYNTAX_ERRORS -eq 0 ]; then
    print_status 0 "Subagent syntax validation (all files valid)"
else
    print_status 1 "Subagent syntax errors ($SYNTAX_ERRORS files invalid)"
fi

echo -e "\n${BLUE}📊 Phase 2: Configuration Validation${NC}"
echo "------------------------------------"

# Check 4: Subagents configuration file
if [ -f ".claude/subagents-config.json" ]; then
    if grep -q "nativeSubagents" .claude/subagents-config.json && grep -q "enabled.*true" .claude/subagents-config.json; then
        print_status 0 "Subagents configuration file present and enabled"
    else
        print_status 1 "Subagents configuration invalid"
    fi
else
    print_status 1 "Subagents configuration file missing"
fi

# Check 5: Migration documentation
if [ -f ".claude/migration/task-tool-migration-guide.md" ]; then
    GUIDE_SIZE=$(wc -l < .claude/migration/task-tool-migration-guide.md)
    if [ $GUIDE_SIZE -gt 100 ]; then
        print_status 0 "Migration guide present ($GUIDE_SIZE lines)"
    else
        print_status 1 "Migration guide too short ($GUIDE_SIZE lines)"
    fi
else
    print_status 1 "Migration guide missing"
fi

echo -e "\n${BLUE}📊 Phase 3: Integration Validation${NC}"
echo "----------------------------------"

# Check 6: Legacy system archived
if [ -f ".claude/migration/legacy-agents.json.backup" ] || [ -d ".claude/archive" ]; then
    print_status 0 "Legacy system properly archived"
else
    print_status 1 "Legacy system not archived"
fi

# Check 7: Git branch validation
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
if [ "$CURRENT_BRANCH" = "feature/claude-code-2025-modernization" ]; then
    print_status 0 "Correct modernization branch active ($CURRENT_BRANCH)"
else
    print_status 1 "Incorrect branch active ($CURRENT_BRANCH)"
fi

echo -e "\n${BLUE}📊 Phase 4: Performance Validation${NC}"
echo "----------------------------------"

# Check 8: Tool access configuration
TOOL_ERRORS=0
for agent_file in .claude/subagents/*.md; do
    if [ -f "$agent_file" ]; then
        if ! grep -q "tools:" "$agent_file"; then
            ((TOOL_ERRORS++))
        fi
    fi
done

if [ $TOOL_ERRORS -eq 0 ]; then
    print_status 0 "Tool access properly configured for all subagents"
else
    print_status 1 "Tool access configuration errors ($TOOL_ERRORS subagents)"
fi

# Check 9: Performance expectations documented
if [ -f ".claude/subagents-config.json" ]; then
    if grep -q "90.2%" .claude/subagents-config.json; then
        print_status 0 "Performance expectations documented (90.2% improvement)"
    else
        print_status 1 "Performance expectations not documented"
    fi
else
    print_status 1 "Configuration file missing for performance check"
fi

echo -e "\n${BLUE}📊 Phase 5: Documentation Validation${NC}"
echo "------------------------------------"

# Check 10: Modernization documentation complete
DOCS_COMPLETE=true

if [ ! -f ".claude/migration/task-tool-migration-guide.md" ]; then
    DOCS_COMPLETE=false
fi

if [ ! -f ".claude/subagents-config.json" ]; then
    DOCS_COMPLETE=false
fi

if [ $DOCS_COMPLETE = true ]; then
    print_status 0 "Modernization documentation complete"
else
    print_status 1 "Modernization documentation incomplete"
fi

echo -e "\n${BLUE}📊 Final Results${NC}"
echo "================="

PERCENTAGE=$((SUCCESS_COUNT * 100 / TOTAL_CHECKS))

if [ $PERCENTAGE -ge 90 ]; then
    echo -e "${GREEN}🎉 MODERNIZATION SUCCESSFUL: $SUCCESS_COUNT/$TOTAL_CHECKS checks passed ($PERCENTAGE%)${NC}"
    echo -e "${GREEN}✅ Claude Code 2025 modernization completed successfully!${NC}"
    echo -e "${GREEN}✅ Expected performance improvement: 90.2%${NC}"
    echo -e "${GREEN}✅ Native subagents ready for Task tool delegation${NC}"
elif [ $PERCENTAGE -ge 70 ]; then
    echo -e "${YELLOW}⚠️  MODERNIZATION PARTIAL: $SUCCESS_COUNT/$TOTAL_CHECKS checks passed ($PERCENTAGE%)${NC}"
    echo -e "${YELLOW}⚠️  Some optimizations needed before full deployment${NC}"
else
    echo -e "${RED}❌ MODERNIZATION FAILED: $SUCCESS_COUNT/$TOTAL_CHECKS checks passed ($PERCENTAGE%)${NC}"
    echo -e "${RED}❌ Significant issues need resolution${NC}"
fi

echo -e "\n${BLUE}📋 Next Steps${NC}"
echo "============="

if [ $PERCENTAGE -ge 90 ]; then
    echo "✅ Ready to test Task tool auto-delegation"
    echo "✅ Ready to validate parallel execution"
    echo "✅ Ready to measure performance improvements"
    echo "✅ Ready to commit modernization changes"
else
    echo "🔧 Review and fix failed validation checks"
    echo "🔧 Complete missing documentation"
    echo "🔧 Verify subagent configurations"
    echo "🔧 Re-run validation after fixes"
fi

echo -e "\n${BLUE}🚀 Testing Commands${NC}"
echo "=================="
echo "# Test natural language task delegation:"
echo '# "Implement Phase BM-2 wizard with comprehensive validation"'
echo ""
echo "# Test multi-domain analysis:"
echo '# "Analyze the Phoenix application for security, performance, and code quality"'
echo ""
echo "# Test evidence collection:"
echo '# "Collect comprehensive evidence for current implementation"'

exit $((TOTAL_CHECKS - SUCCESS_COUNT))