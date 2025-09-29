# Projetos SOC Analyst para Portfólio Profissional

## Índice
- [Introdução](#introdução)
- [Fundamentos SOC Analyst](#fundamentos-soc-analyst)
- [Plataformas de Prática Recomendadas](#plataformas-de-prática-recomendadas)
- [Projetos Práticos Essenciais](#projetos-práticos-essenciais)
- [Laboratórios Hands-On](#laboratórios-hands-on)
- [Documentação e Apresentação](#documentação-e-apresentação)
- [Certificações Complementares](#certificações-complementares)
- [Templates de Currículo](#templates-de-currículo)

## Introdução

**SOC Analyst (Security Operations Center Analyst)** é uma das posições mais demandadas em segurança cibernética atualmente. Existe maior disponibilidade de vagas para SOC Analyst do que qualquer outra especialização em segurança cibernética.

Este documento apresenta projetos práticos específicos para desenvolver e demonstrar habilidades de **Blue Team** e análise de operações de segurança, essenciais para se destacar no mercado.

### Por que SOC Analyst?

1. **Alta Demanda**: Maior número de vagas disponíveis
2. **Generalista**: Desenvolve múltiplas habilidades em segurança
3. **Experiência Real**: Análise e resposta a ataques cibernéticos
4. **Progressão de Carreira**: Base sólida para especialização futura
5. **Aplicabilidade**: Essencial em organizações de pequeno e médio porte

## Fundamentos SOC Analyst

### Responsabilidades Principais

**Análise e Triagem:**
- Monitoramento de alertas de segurança em tempo real
- Investigação de incidentes de segurança
- Determinação entre ataque real e falso positivo
- Classificação de severidade de incidentes

**Resposta a Incidentes:**
- Contenção inicial de ameaças
- Coleta de evidências
- Documentação de incidentes
- Escalação para níveis superiores quando necessário

**Operações Diárias:**
- Monitoramento contínuo de SIEM
- Análise de logs de segurança
- Relatórios de incidentes
- Manutenção de dashboards de segurança

### Habilidades Técnicas Essenciais

```
✅ SIEM (Security Information and Event Management)
✅ Análise de logs de segurança
✅ Network traffic analysis
✅ Malware analysis (básico)
✅ Incident response procedures
✅ Digital forensics (introdução)
✅ Threat hunting (básico)
✅ Security tools (Wireshark, Splunk, ELK Stack)
```

## Plataformas de Prática Recomendadas

### 1. Let's Defend

**Características:**
- Ambiente SOC em tempo real
- Simulação de Security Operations Center real
- Investigação e resposta a incidentes
- Interface idêntica a ambientes corporativos

**O que Oferece:**
```
🔴 Alertas de segurança em tempo real
🔍 Investigação de incidentes
📋 Sistema de tickets e atribuição
📊 Dashboards de monitoramento
📝 Documentação de resposta
🎯 Cenários realistas de ataques
```

**Como Usar no Portfólio:**
```markdown
## Projeto: Live SOC Monitoring - Let's Defend
**Descrição**: Monitoramento de alertas de segurança em tempo real e investigação de incidentes em ambiente SOC simulado.

**Atividades Realizadas:**
- Triagem de 150+ alertas de segurança
- Investigação de 25+ incidentes confirmados
- Análise de malware e indicators of compromise (IOCs)
- Documentação de procedures de resposta
- Classificação de severidade de incidentes

**Tecnologias**: SIEM, Log Analysis, Incident Response, Threat Intelligence
**Resultados**: 95% accuracy na classificação de true/false positives
```

### 2. TryHackMe

**Características:**
- Ambiente livestock (simulação ao vivo)
- Laboratórios progressivos
- Community-driven content
- Gamificação do aprendizado

**Módulos Relevantes:**
```
📚 SOC Level 1 Learning Path
🔍 Digital Forensics and Incident Response
🛡️ Cyber Defense Framework
📊 Splunk fundamentals
🌐 Network Security Monitoring
🔒 Threat Hunting
```

**Como Usar no Portfólio:**
```markdown
## Projeto: SOC Operations - TryHackMe
**Descrição**: Desenvolvimento de habilidades de análise e resposta a incidentes através de laboratórios práticos interativos.

**Competências Desenvolvidas:**
- Análise de logs com Splunk
- Investigação forense digital
- Network security monitoring
- Threat hunting procedures
- MITRE ATT&CK framework application

**Métricas**:
- 50+ laboratórios completados
- SOC Level 1 pathway finalizado
- Top 5% ranking na plataforma
```

### 3. Cyber Defenders

**Características:**
- Blue Team Labs especializados
- Três níveis de dificuldade (Beginner → Advanced)
- Foco em Digital Forensics e Incident Response (DFIR)
- Cenários complexos e realistas

**Laboratórios Destacados:**
```
🟢 Beginner Labs:
   - Basic malware analysis
   - Log analysis fundamentals
   - Network forensics intro

🟡 Intermediate Labs:
   - Advanced persistent threats (APT)
   - Memory forensics
   - Timeline analysis

🔴 Advanced Labs:
   - Complex attack scenarios
   - Multi-vector investigations
   - Enterprise incident response
```

**Como Usar no Portfólio:**
```markdown
## Projeto: Advanced Digital Forensics - Cyber Defenders
**Descrição**: Investigação forense avançada e resposta a incidentes através de cenários complexos de Blue Team.

**Laboratórios Completados:**
- Malware Family Analysis (Advanced)
- APT Campaign Investigation
- Network Forensics Deep Dive
- Memory Dump Analysis
- Timeline Reconstruction

**Ferramentas Utilizadas**: Volatility, Wireshark, YARA, Autopsy, Timeline Explorer
**Impacto**: Capacidade de investigar ataques complexos end-to-end
```

## Projetos Práticos Essenciais

### Projeto 1: Home SOC Lab

**Objetivo**: Criar um laboratório SOC pessoal para prática contínua.

**Componentes:**
```
🖥️ Virtualization Environment:
   - VMware/VirtualBox
   - Windows Server 2019/2022
   - Ubuntu Server (SIEM)
   - Windows 10 (endpoints)

🔧 Security Tools:
   - ELK Stack (Elasticsearch, Logstash, Kibana)
   - Wazuh SIEM
   - pfSense Firewall
   - Suricata IDS/IPS

📊 Monitoring Setup:
   - Syslog configuration
   - Event log forwarding
   - Network monitoring
   - Custom dashboards
```

**Documentação no GitHub:**
```markdown
# Home SOC Lab

## Architecture Diagram
[Incluir diagrama da rede]

## Components
- **SIEM**: Wazuh + ELK Stack
- **Firewall**: pfSense with Suricata
- **Endpoints**: Windows 10 workstations
- **Server**: Windows Server 2019

## Installation Guide
### 1. SIEM Setup
```bash
# Wazuh Manager Installation
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
# [Detailed installation steps]
```

### 2. Agent Configuration
```xml
<!-- Wazuh agent configuration -->
<ossec_config>
  <client>
    <server>192.168.1.100</server>
  </client>
</ossec_config>
```

## Attack Simulations
- Malware execution (controlled environment)
- Brute force attacks
- Network reconnaissance
- Data exfiltration attempts

## Detection Rules Created
- Custom YARA rules for malware detection
- Behavioral analysis rules
- Network anomaly detection
- Privilege escalation monitoring
```

### Projeto 2: Incident Response Playbook

**Objetivo**: Desenvolver playbooks padronizados para resposta a incidentes.

**Estrutura:**
```
📋 Incident Classification:
   - P1: Critical (system compromise)
   - P2: High (data breach attempt)
   - P3: Medium (suspicious activity)
   - P4: Low (policy violation)

⚡ Response Procedures:
   - Initial triage (15 minutes)
   - Evidence collection (30 minutes)
   - Containment (1 hour)
   - Eradication (varies)
   - Recovery (varies)
   - Lessons learned (post-incident)

📝 Documentation Templates:
   - Incident report template
   - Timeline reconstruction
   - IOC extraction
   - Executive summary
```

**Exemplo de Playbook:**
```markdown
# Malware Incident Response Playbook

## Phase 1: Detection & Analysis (0-15 min)
### Immediate Actions
1. **Isolate** affected system (network isolation)
2. **Preserve** system state (memory dump)
3. **Document** initial observations
4. **Notify** incident response team

### Evidence Collection
```bash
# Memory dump
winpmem-2.1.post4.exe -o memory.raw

# Process list
tasklist /svc > processes.txt

# Network connections
netstat -anob > network_connections.txt

# Event logs
wevtutil epl System system_events.evtx
```

## Phase 2: Containment (15-60 min)
### Network Containment
- Block malicious IPs on firewall
- Quarantine affected systems
- Update IDS/IPS signatures

### System Containment
- Disable compromised accounts
- Change relevant passwords
- Deploy emergency patches

## Phase 3: Analysis & Investigation
### Malware Analysis
```bash
# File hash calculation
certutil -hashfile malware.exe SHA256

# YARA rule scanning
yara rules.yar malware.exe

# Sandbox analysis
# Submit to Cuckoo Sandbox or similar
```

### Timeline Reconstruction
| Time | Event | Source | Severity |
|------|-------|--------|----------|
| 09:15 | Suspicious email received | Email logs | Medium |
| 09:17 | Attachment executed | EDR | High |
| 09:18 | Network connection to C2 | Firewall | Critical |
| 09:20 | Data staging detected | DLP | Critical |
```

### Projeto 3: Threat Intelligence Integration

**Objetivo**: Implementar feeds de threat intelligence no ambiente SOC.

**Componentes:**
```
🔍 Intelligence Sources:
   - MISP (Malware Information Sharing Platform)
   - AlienVault OTX
   - VirusTotal API
   - Commercial feeds (optional)

🤖 Automation:
   - STIX/TAXII implementation
   - Automated IOC ingestion
   - Alert enrichment
   - False positive reduction

📊 Analysis:
   - IOC correlation
   - Attribution analysis
   - Campaign tracking
   - Trend identification
```

**Script de Automação:**
```python
#!/usr/bin/env python3
"""
Threat Intelligence Automation Script
Integrates multiple TI feeds with SIEM
"""

import requests
import json
from datetime import datetime

class ThreatIntelligence:
    def __init__(self):
        self.misp_url = "https://misp.local"
        self.otx_api_key = "your_otx_api_key"
        self.vt_api_key = "your_vt_api_key"

    def get_otx_indicators(self):
        """Fetch indicators from AlienVault OTX"""
        url = "https://otx.alienvault.com/api/v1/indicators/export"
        headers = {"X-OTX-API-KEY": self.otx_api_key}

        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            return response.json()
        return None

    def enrich_with_virustotal(self, hash_value):
        """Enrich IOC with VirusTotal data"""
        url = f"https://www.virustotal.com/vtapi/v2/file/report"
        params = {
            "apikey": self.vt_api_key,
            "resource": hash_value
        }

        response = requests.get(url, params=params)
        return response.json()

    def create_alert(self, ioc_data):
        """Create SIEM alert for high-confidence IOCs"""
        if ioc_data.get("confidence", 0) > 80:
            alert = {
                "timestamp": datetime.now().isoformat(),
                "severity": "high",
                "type": "threat_intelligence",
                "ioc": ioc_data
            }
            # Send to SIEM
            self.send_to_siem(alert)

    def send_to_siem(self, alert):
        """Send alert to SIEM platform"""
        siem_endpoint = "https://siem.local/api/alerts"
        response = requests.post(siem_endpoint, json=alert)
        return response.status_code == 200

if __name__ == "__main__":
    ti = ThreatIntelligence()
    indicators = ti.get_otx_indicators()

    for indicator in indicators[:10]:  # Process first 10
        enriched = ti.enrich_with_virustotal(indicator["hash"])
        ti.create_alert(enriched)
```

## Laboratórios Hands-On

### Lab 1: Malware Analysis Fundamentals

**Ambiente Seguro:**
```
🖥️ Isolated VM Environment:
   - Windows 10 (analysis machine)
   - REMnux (Linux malware analysis)
   - Network isolation (NO internet)
   - Snapshot capability

🔧 Analysis Tools:
   - Process Monitor (ProcMon)
   - Process Explorer
   - Wireshark
   - OllyDbg/x64dbg
   - IDA Free
   - YARA
```

**Fluxo de Análise:**
```markdown
## Static Analysis
1. File properties examination
2. Hash calculation and VirusTotal lookup
3. Strings analysis
4. PE header analysis
5. Import/Export table examination

## Dynamic Analysis
1. Sandbox execution (Cuckoo)
2. Behavioral monitoring
3. Network traffic analysis
4. Registry/file system changes
5. Process injection detection

## Report Generation
- Executive summary
- Technical analysis
- IOCs extracted
- Mitigation recommendations
```

### Lab 2: SIEM Rule Development

**Objetivo**: Criar regras customizadas para detecção de ameaças.

**Splunk Rules:**
```spl
# Detect suspicious PowerShell execution
index=windows EventCode=4103 OR EventCode=4104
| eval suspicious_keywords=if(match(Message, "(?i)(invoke-expression|iex|downloadstring|base64|bypass)"), 1, 0)
| where suspicious_keywords=1
| stats count by Computer, User, Message
| where count > 5

# Detect multiple failed logins
index=windows EventCode=4625
| bucket _time span=5m
| stats count by Computer, Account_Name, _time
| where count > 10
| sort -count
```

**Wazuh Rules:**
```xml
<rule id="100001" level="12">
    <if_sid>60106</if_sid>
    <field name="win.eventdata.commandLine">\.+</field>
    <regex type="pcre2">(?i)(invoke-expression|iex|downloadstring|base64)</regex>
    <description>Suspicious PowerShell command detected</description>
    <mitre>
        <id>T1059.001</id>
    </mitre>
</rule>

<rule id="100002" level="10">
    <if_sid>60122</if_sid>
    <field name="win.eventdata.targetUserName">\.+</field>
    <frequency>10</frequency>
    <timeframe>300</timeframe>
    <description>Multiple failed login attempts detected</description>
    <mitre>
        <id>T1110</id>
    </mitre>
</rule>
```

### Lab 3: Network Forensics

**Cenário**: Investigação de exfiltração de dados.

**Análise com Wireshark:**
```
🔍 Investigation Steps:
1. Traffic volume analysis
2. Protocol distribution
3. Unusual connections identification
4. Data transfer patterns
5. DNS anomalies detection

📊 Wireshark Filters:
- Large data transfers: frame.len > 1000
- DNS tunneling: dns and frame.len > 512
- Suspicious protocols: ftp or tftp or http.request.method == "POST"
- Data exfiltration: tcp.len > 1460 and tcp.flags.psh == 1

🎯 IOCs Extraction:
- Malicious IPs
- Suspicious domains
- File hashes (if available)
- Communication patterns
```

**Análise de Exemplo:**
```markdown
# Network Forensics Investigation Report

## Case Summary
**Incident ID**: INC-2024-001
**Date**: 2024-01-15
**Analyst**: [Your Name]
**Type**: Suspected data exfiltration

## Key Findings

### 1. Unusual Traffic Patterns
- **Peak Transfer**: 15:30-15:45 (500MB outbound)
- **Destination**: 185.243.115.84 (known C2 server)
- **Protocol**: HTTPS (encrypted channel)

### 2. DNS Anomalies
```wireshark
# Suspicious DNS queries
dns.qry.name contains "dnscat" or
dns.qry.name matches "^[a-f0-9]{32}\."
```

### 3. Extracted IOCs
| Type | Value | Confidence | Source |
|------|-------|------------|--------|
| IP | 185.243.115.84 | High | Traffic analysis |
| Domain | malicious-c2.com | High | DNS logs |
| Hash | a1b2c3d4e5f6... | Medium | File transfer |

### 4. Timeline Reconstruction
- 15:25: Initial compromise (malware execution)
- 15:27: C2 communication established
- 15:30: Data staging begins
- 15:32: Exfiltration starts
- 15:45: Connection terminated

## Recommendations
1. Block identified IOCs
2. Investigate affected systems
3. Implement DLP controls
4. Update detection rules
```

## Documentação e Apresentação

### Estrutura de Projeto no GitHub

```
soc-analyst-portfolio/
├── README.md
├── docs/
│   ├── lab-setup.md
│   ├── incident-response-playbooks/
│   ├── malware-analysis-reports/
│   └── network-forensics-cases/
├── scripts/
│   ├── threat-intelligence/
│   ├── log-analysis/
│   └── automation/
├── rules/
│   ├── splunk/
│   ├── wazuh/
│   └── yara/
├── reports/
│   ├── incident-reports/
│   ├── forensics-analysis/
│   └── executive-summaries/
└── screenshots/
    ├── siem-dashboards/
    ├── analysis-tools/
    └── investigation-results/
```

### README Principal do Portfólio

```markdown
# SOC Analyst Portfolio

## 👨‍💻 About Me
SOC Analyst with hands-on experience in incident response, malware analysis, and security monitoring. Specialized in Blue Team operations and threat hunting.

## 🛡️ Core Competencies
- **SIEM Platforms**: Splunk, Wazuh, ELK Stack
- **Incident Response**: NIST framework, playbook development
- **Malware Analysis**: Static/dynamic analysis, sandbox environments
- **Network Forensics**: Wireshark, packet analysis, IOC extraction
- **Threat Intelligence**: MISP, STIX/TAXII, automated enrichment

## 🔬 Practical Projects

### 1. Home SOC Laboratory
**Description**: Full-scale SOC environment for continuous learning
- **Technologies**: Wazuh, ELK Stack, pfSense, Suricata
- **Capabilities**: Real-time monitoring, automated alerting
- **GitHub**: [home-soc-lab](./home-soc-lab/)

### 2. Incident Response Automation
**Description**: Automated playbooks for faster incident response
- **Tools**: Python, SOAR integration, threat intelligence APIs
- **Metrics**: 60% reduction in response time
- **GitHub**: [ir-automation](./ir-automation/)

### 3. Advanced Malware Analysis
**Description**: Deep-dive analysis of recent malware families
- **Samples**: 50+ malware specimens analyzed
- **Techniques**: Static, dynamic, memory forensics
- **GitHub**: [malware-analysis](./malware-analysis/)

## 📊 Platform Statistics
- **Let's Defend**: 150+ incidents investigated
- **TryHackMe**: SOC Level 1 completed, Top 5% ranking
- **Cyber Defenders**: 25+ Blue Team labs completed

## 🏆 Certifications
- Certified SOC Analyst (CSA)
- GCIH (GIAC Certified Incident Handler)
- Blue Team Level 1 (BTL1)

## 📞 Contact
- **Email**: soc.analyst@email.com
- **LinkedIn**: [linkedin.com/in/soc-analyst](https://linkedin.com/in/soc-analyst)
- **Blog**: [cybersec-blog.com](https://cybersec-blog.com)
```

## Certificações Complementares

### Certificações Recomendadas

**Nível Básico:**
```
🎯 Blue Team Level 1 (BTL1)
   - Hands-on practical training
   - Real-world scenarios
   - Certificate widely recognized

🔍 Certified Cyber Defender (CCD)
   - Cyber Defenders platform
   - DFIR specialization
   - Industry-relevant skills
```

**Nível Intermediário:**
```
⚡ GCIH (GIAC Certified Incident Handler)
   - SANS training quality
   - Incident response focus
   - Industry gold standard

🛡️ GNFA (GIAC Network Forensic Analyst)
   - Network forensics specialization
   - Advanced packet analysis
   - Expert-level certification
```

**Nível Avançado:**
```
🎖️ GCFA (GIAC Certified Forensic Analyst)
   - Advanced digital forensics
   - Leadership-level skills
   - Expert recognition

👑 CISSP (Certified Information Systems Security Professional)
   - Management-level certification
   - Broad security knowledge
   - Career advancement
```

### Como Incluir no Currículo

```markdown
## Certifications & Training
- **Blue Team Level 1 (BTL1)** - SecurityBlue Team (2024)
- **Certified Cyber Defender (CCD)** - Cyber Defenders (2024)
- **GCIH** - GIAC Certified Incident Handler (In Progress)

## Continuous Learning
- **TryHackMe**: SOC Level 1 Learning Path (Completed)
- **Let's Defend**: 6+ months active SOC simulation
- **Cyber Defenders**: 25+ Blue Team laboratories completed
```

## Templates de Currículo

### Seção de Projetos Práticos

```markdown
## PRACTICAL PROJECTS

### Live SOC Monitoring | Let's Defend
Monitored real-time security alerts and performed triage in simulated SOC environment. Investigated incidents, classified threats, and documented response procedures.
- **Tools**: SIEM, Log Analysis, Incident Response
- **Achievements**: 95% accuracy in true/false positive classification

### Network Traffic Analysis | TryHackMe SOC Path
Analyzed network traffic to identify malicious activities and security threats. Performed packet analysis, protocol examination, and IOC extraction.
- **Technologies**: Wireshark, Splunk, Network Forensics
- **Results**: Completed 50+ practical scenarios

### Advanced Digital Forensics | Cyber Defenders
Conducted complex forensic investigations including malware analysis, memory forensics, and timeline reconstruction across multiple difficulty levels.
- **Specializations**: DFIR, Memory Analysis, Malware Investigation
- **Metrics**: Advanced level laboratories completed (15+)

### Home SOC Laboratory | Personal Project
Designed and implemented full-scale SOC environment for continuous learning and skill development.
- **Architecture**: Wazuh SIEM, ELK Stack, pfSense, Multiple VMs
- **Capabilities**: 24/7 monitoring, automated alerting, custom rule development
- **Impact**: Created realistic training environment replicating enterprise SOC
```

### Seção de Habilidades Técnicas

```markdown
## TECHNICAL SKILLS

### SIEM Platforms
- **Splunk**: Search, dashboard creation, alert configuration
- **Wazuh**: Agent deployment, rule development, compliance monitoring
- **ELK Stack**: Log ingestion, visualization, query optimization

### Incident Response
- **Frameworks**: NIST Cybersecurity Framework, SANS methodology
- **Tools**: Volatility, Autopsy, YARA, Timeline Explorer
- **Processes**: Triage, containment, eradication, recovery

### Malware Analysis
- **Static Analysis**: PE analysis, strings extraction, import analysis
- **Dynamic Analysis**: Sandbox execution, behavioral monitoring
- **Tools**: IDA Pro, OllyDbg, Process Monitor, Wireshark

### Network Security
- **Traffic Analysis**: Wireshark, tcpdump, network forensics
- **Monitoring**: Suricata IDS/IPS, pfSense, network segmentation
- **Protocols**: Deep packet inspection, protocol analysis

### Threat Intelligence
- **Platforms**: MISP, AlienVault OTX, VirusTotal
- **Standards**: STIX/TAXII, IOC management
- **Automation**: Python scripts, API integration
```

### Métricas de Impacto

```markdown
## ACHIEVEMENTS & METRICS

### Platform Statistics
- **Let's Defend**: 150+ incidents investigated, 95% classification accuracy
- **TryHackMe**: Top 5% global ranking, SOC Level 1 pathway completed
- **Cyber Defenders**: 25+ Blue Team labs, Advanced difficulty achieved

### Project Outcomes
- **Response Time**: 60% improvement through automation implementation
- **False Positives**: 40% reduction via tuned detection rules
- **Coverage**: 99.9% uptime on home SOC laboratory environment

### Professional Development
- **Continuous Learning**: 500+ hours hands-on practice
- **Community Contribution**: 10+ shared playbooks and scripts
- **Knowledge Sharing**: Technical blog with 5,000+ monthly readers
```

Desenvolvendo estes projetos e documentando adequadamente, você criará um portfólio SOC Analyst robusto que demonstra experiência prática real, essencial para se destacar no mercado de trabalho em segurança cibernética.

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Analisar transcri\u00e7\u00e3o do v\u00eddeo sobre projetos de seguran\u00e7a cibern\u00e9tica", "status": "completed", "activeForm": "Analisando transcri\u00e7\u00e3o do v\u00eddeo sobre projetos de seguran\u00e7a cibern\u00e9tica"}, {"content": "Criar documento sobre projetos SOC Analyst", "status": "completed", "activeForm": "Criando documento sobre projetos SOC Analyst"}, {"content": "Criar documento sobre Network Traffic Analysis e Active Directory", "status": "in_progress", "activeForm": "Criando documento sobre Network Traffic Analysis e Active Directory"}, {"content": "Criar documento sobre Vulnerability Management", "status": "pending", "activeForm": "Criando documento sobre Vulnerability Management"}, {"content": "Criar documento sobre GRC (Governance, Risk and Compliance)", "status": "pending", "activeForm": "Criando documento sobre GRC"}, {"content": "Criar documento sobre Cloud Security", "status": "pending", "activeForm": "Criando documento sobre Cloud Security"}, {"content": "Atualizar documento principal de estrat\u00e9gias com foco em seguran\u00e7a", "status": "pending", "activeForm": "Atualizando documento principal de estrat\u00e9gias com foco em seguran\u00e7a"}]