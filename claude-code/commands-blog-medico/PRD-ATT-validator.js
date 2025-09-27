#!/usr/bin/env node

/**
 * PRD-ATT Evidence Validator
 * Automated verification system for PRD requirements using Playwright
 * Integrates with Seven-Layer Documentation Method
 */

const { chromium } = require('playwright');
const fs = require('fs').promises;
const path = require('path');

class PRDValidator {
    constructor() {
        this.evidenceDir = path.join(__dirname, '../evidence');
        this.results = {
            validated: [],
            failed: [],
            partial: [],
            blocked: []
        };
        this.timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    }

    async initialize() {
        // Ensure evidence directory exists
        await fs.mkdir(this.evidenceDir, { recursive: true });

        // Initialize Playwright
        this.browser = await chromium.launch({
            headless: false, // Visual validation important for medical platform
            slowMo: 100
        });
        this.context = await this.browser.newContext({
            viewport: { width: 1920, height: 1080 },
            recordVideo: {
                dir: path.join(this.evidenceDir, 'videos'),
                size: { width: 1920, height: 1080 }
            }
        });
    }

    async validateRequirement(id, description, testConfig) {
        const page = await this.context.newPage();
        const evidenceFile = `${id}-${this.timestamp}`;

        try {
            console.log(`🔍 Validating: ${description}`);

            // Navigate to target URL
            if (testConfig.url) {
                await page.goto(testConfig.url, { waitUntil: 'networkidle' });
            }

            // Take screenshot for visual evidence
            await page.screenshot({
                path: path.join(this.evidenceDir, `${evidenceFile}.png`),
                fullPage: true
            });

            // Run specific validation tests
            const validationResult = await this.runValidationTests(page, testConfig);

            // Collect evidence metadata
            const evidence = {
                id,
                description,
                timestamp: new Date().toISOString(),
                status: validationResult.status,
                evidence_files: [`${evidenceFile}.png`],
                test_results: validationResult.results,
                compliance_notes: validationResult.compliance || [],
                stakeholder_impact: validationResult.stakeholder_impact || 'low'
            };

            // Categorize result
            this.categorizeResult(evidence);

            await page.close();
            return evidence;

        } catch (error) {
            console.error(`❌ Validation failed for ${id}: ${error.message}`);

            const errorEvidence = {
                id,
                description,
                timestamp: new Date().toISOString(),
                status: 'blocked',
                error: error.message,
                evidence_files: [`${evidenceFile}-error.png`]
            };

            // Take error screenshot if page still exists
            try {
                await page.screenshot({
                    path: path.join(this.evidenceDir, `${evidenceFile}-error.png`),
                    fullPage: true
                });
            } catch (screenshotError) {
                console.error('Could not capture error screenshot:', screenshotError.message);
            }

            this.results.blocked.push(errorEvidence);
            await page.close();
            return errorEvidence;
        }
    }

    async runValidationTests(page, testConfig) {
        const results = [];
        let overallStatus = 'validated';

        // Test 1: Element Existence
        if (testConfig.elements) {
            for (const element of testConfig.elements) {
                const exists = await page.locator(element.selector).count() > 0;
                results.push({
                    test: 'element_existence',
                    selector: element.selector,
                    expected: element.description,
                    result: exists ? 'pass' : 'fail',
                    critical: element.critical || false
                });

                if (!exists && element.critical) {
                    overallStatus = 'failed';
                }
            }
        }

        // Test 2: Functional Flow
        if (testConfig.flow) {
            try {
                for (const step of testConfig.flow) {
                    await this.executeFlowStep(page, step);
                }
                results.push({
                    test: 'functional_flow',
                    result: 'pass',
                    steps_completed: testConfig.flow.length
                });
            } catch (flowError) {
                results.push({
                    test: 'functional_flow',
                    result: 'fail',
                    error: flowError.message
                });
                overallStatus = 'failed';
            }
        }

        // Test 3: Performance Validation
        if (testConfig.performance) {
            const performanceResult = await this.validatePerformance(page, testConfig.performance);
            results.push(performanceResult);

            if (!performanceResult.passed) {
                overallStatus = overallStatus === 'validated' ? 'partial' : 'failed';
            }
        }

        // Test 4: Compliance Validation
        if (testConfig.compliance) {
            const complianceResults = await this.validateCompliance(page, testConfig.compliance);
            results.push(...complianceResults);

            const criticalComplianceFailed = complianceResults.some(r => r.critical && r.result === 'fail');
            if (criticalComplianceFailed) {
                overallStatus = 'failed';
            }
        }

        return {
            status: overallStatus,
            results,
            compliance: testConfig.compliance_notes || [],
            stakeholder_impact: testConfig.stakeholder_impact || 'low'
        };
    }

    async executeFlowStep(page, step) {
        switch (step.action) {
            case 'click':
                await page.locator(step.selector).click();
                break;
            case 'fill':
                await page.locator(step.selector).fill(step.value);
                break;
            case 'wait':
                await page.waitForSelector(step.selector, { timeout: step.timeout || 5000 });
                break;
            case 'navigate':
                await page.goto(step.url, { waitUntil: 'networkidle' });
                break;
            default:
                throw new Error(`Unknown flow action: ${step.action}`);
        }

        // Wait for any animations/transitions
        await page.waitForTimeout(500);
    }

    async validatePerformance(page, config) {
        const navigationStart = Date.now();

        if (config.url) {
            await page.goto(config.url, { waitUntil: 'networkidle' });
        }

        const loadTime = Date.now() - navigationStart;
        const maxLoadTime = config.maxLoadTime || 2000; // 2s default

        return {
            test: 'performance',
            load_time_ms: loadTime,
            max_allowed_ms: maxLoadTime,
            result: loadTime <= maxLoadTime ? 'pass' : 'fail',
            passed: loadTime <= maxLoadTime
        };
    }

    async validateCompliance(page, complianceConfig) {
        const results = [];

        // LGPD Compliance
        if (complianceConfig.lgpd) {
            const privacyPolicy = await page.locator('text=Política de Privacidade').count() > 0;
            const cookieConsent = await page.locator('[data-cookie-consent], .cookie-consent').count() > 0;

            results.push({
                test: 'lgpd_compliance',
                privacy_policy: privacyPolicy,
                cookie_consent: cookieConsent,
                result: (privacyPolicy && cookieConsent) ? 'pass' : 'fail',
                critical: true
            });
        }

        // ANVISA RDC 657/2022 - Medical Advertising
        if (complianceConfig.anvisa_rdc657) {
            const medicalDisclaimers = await page.locator('text=Este conteúdo não substitui').count() > 0;
            const professionalInfo = await page.locator('[data-crm], .crm-info').count() > 0;

            results.push({
                test: 'anvisa_rdc657',
                medical_disclaimers: medicalDisclaimers,
                professional_credentials: professionalInfo,
                result: (medicalDisclaimers && professionalInfo) ? 'pass' : 'fail',
                critical: true
            });
        }

        // CFM/SBIS NGS2 - Medical Ethics
        if (complianceConfig.cfm_ethics) {
            const ethicalGuidelines = await page.locator('.ethical-guidelines, [data-ethics]').count() > 0;

            results.push({
                test: 'cfm_ethics',
                ethical_compliance: ethicalGuidelines,
                result: ethicalGuidelines ? 'pass' : 'fail',
                critical: true
            });
        }

        return results;
    }

    categorizeResult(evidence) {
        switch (evidence.status) {
            case 'validated':
                this.results.validated.push(evidence);
                break;
            case 'failed':
                this.results.failed.push(evidence);
                break;
            case 'partial':
                this.results.partial.push(evidence);
                break;
            default:
                this.results.blocked.push(evidence);
        }
    }

    async generateReport() {
        const reportPath = path.join(this.evidenceDir, `prd-validation-report-${this.timestamp}.md`);

        const report = `# PRD-ATT Validation Report
## Generated: ${new Date().toISOString()}

## 📊 Summary
- **✅ Validated:** ${this.results.validated.length}
- **⏳ Partial:** ${this.results.partial.length}
- **❌ Failed:** ${this.results.failed.length}
- **🚨 Blocked:** ${this.results.blocked.length}

## 🎯 Evidence-Based Results

### ✅ Fully Validated Requirements
${this.formatResultsSection(this.results.validated)}

### ⏳ Partially Implemented
${this.formatResultsSection(this.results.partial)}

### ❌ Failed Validation
${this.formatResultsSection(this.results.failed)}

### 🚨 Blocked Requirements
${this.formatResultsSection(this.results.blocked)}

## 📋 Next Steps
${this.generateNextSteps()}

---
Generated by PRD-ATT Evidence Validator
Following Seven-Layer Documentation Method with stakeholder protection principles
`;

        await fs.writeFile(reportPath, report, 'utf8');
        console.log(`📄 Report generated: ${reportPath}`);

        return reportPath;
    }

    formatResultsSection(results) {
        if (results.length === 0) {
            return '*No items in this category*\n';
        }

        return results.map(item =>
            `#### ${item.id}: ${item.description}
- **Status**: ${item.status}
- **Evidence**: ${item.evidence_files ? item.evidence_files.join(', ') : 'None'}
- **Stakeholder Impact**: ${item.stakeholder_impact}
${item.test_results ? `- **Test Results**: ${item.test_results.length} tests run` : ''}
${item.error ? `- **Error**: ${item.error}` : ''}
`
        ).join('\n');
    }

    generateNextSteps() {
        const steps = [];

        if (this.results.failed.length > 0) {
            steps.push('🚨 **CRITICAL**: Address failed requirements immediately');
        }

        if (this.results.blocked.length > 0) {
            steps.push('⚠️ **URGENT**: Resolve blocked requirements');
        }

        if (this.results.partial.length > 0) {
            steps.push('📝 **PLAN**: Complete partial implementations');
        }

        steps.push('🔄 **CONTINUOUS**: Re-run validation weekly during active development');

        return steps.join('\n- ');
    }

    async cleanup() {
        if (this.browser) {
            await this.browser.close();
        }
    }
}

// Test Configuration - Core Medical Blog Requirements
const PRD_TEST_CONFIGS = {
    'core-1.1': {
        description: 'Phoenix LiveView System Running',
        url: 'http://localhost:4000',
        elements: [
            { selector: '[phx-socket]', description: 'LiveView socket', critical: true },
            { selector: 'title', description: 'Page title', critical: false }
        ],
        performance: { maxLoadTime: 2000 },
        stakeholder_impact: 'high'
    },

    'user-2.3': {
        description: 'Content Creation Wizard (5 Steps)',
        url: 'http://localhost:4000/wizard',
        elements: [
            { selector: '.wizard-step-1', description: 'Upload step', critical: true },
            { selector: '.wizard-step-2', description: 'Validation step', critical: true },
            { selector: '.wizard-step-3', description: 'Scientific verification', critical: true },
            { selector: '.wizard-step-4', description: 'Sources validation', critical: true },
            { selector: '.wizard-step-5', description: 'Final generation', critical: true }
        ],
        flow: [
            { action: 'wait', selector: '.wizard-container' },
            { action: 'click', selector: '.start-wizard-btn' }
        ],
        stakeholder_impact: 'critical'
    },

    'kanban-4.1': {
        description: 'Kanban Approval Workflow',
        url: 'http://localhost:4000/approval-board',
        elements: [
            { selector: '.kanban-column[data-status="draft"]', description: 'Draft column', critical: true },
            { selector: '.kanban-column[data-status="technical-review"]', description: 'Technical review', critical: true },
            { selector: '.kanban-column[data-status="legal-review"]', description: 'Legal review', critical: true },
            { selector: '.kanban-column[data-status="published"]', description: 'Published column', critical: true }
        ],
        stakeholder_impact: 'critical'
    },

    'wordpress-5.1': {
        description: 'WordPress-like Dashboard',
        url: 'http://localhost:4000/admin',
        elements: [
            { selector: '.admin-sidebar', description: 'Admin sidebar navigation', critical: true },
            { selector: '.dashboard-widgets', description: 'Dashboard widgets', critical: false },
            { selector: '.quick-actions', description: 'Quick action buttons', critical: false }
        ],
        stakeholder_impact: 'high'
    },

    'compliance-6.1': {
        description: 'LGPD Compliance Features',
        url: 'http://localhost:4000',
        compliance: {
            lgpd: true,
            anvisa_rdc657: true,
            cfm_ethics: true
        },
        stakeholder_impact: 'critical',
        compliance_notes: ['Legal compliance is mandatory', 'Medical ethics validation required']
    }
};

// Main execution
async function main() {
    const validator = new PRDValidator();

    try {
        console.log('🚀 Starting PRD-ATT Evidence Validation...');
        await validator.initialize();

        // Run validation for each configured requirement
        for (const [id, config] of Object.entries(PRD_TEST_CONFIGS)) {
            await validator.validateRequirement(id, config.description, config);
        }

        // Generate comprehensive report
        const reportPath = await validator.generateReport();

        console.log('✅ PRD-ATT Validation Complete!');
        console.log(`📊 Results: ${validator.results.validated.length} validated, ${validator.results.failed.length} failed, ${validator.results.partial.length} partial, ${validator.results.blocked.length} blocked`);

        // Return path for integration with main command
        return {
            success: true,
            report: reportPath,
            summary: validator.results
        };

    } catch (error) {
        console.error('💥 Validation process failed:', error);
        return {
            success: false,
            error: error.message
        };
    } finally {
        await validator.cleanup();
    }
}

// Export for use as module or run directly
if (require.main === module) {
    main().then(result => {
        console.log('Final result:', result);
        process.exit(result.success ? 0 : 1);
    });
}

module.exports = { PRDValidator, PRD_TEST_CONFIGS, main };