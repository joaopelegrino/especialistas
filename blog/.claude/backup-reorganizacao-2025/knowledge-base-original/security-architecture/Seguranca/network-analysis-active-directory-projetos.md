# Network Traffic Analysis e Active Directory - Projetos Avançados

## Índice
- [Introdução](#introdução)
- [Network Traffic Analysis](#network-traffic-analysis)
- [Active Directory Security](#active-directory-security)
- [Windows Event Logs e Finding Evil](#windows-event-logs-e-finding-evil)
- [Projetos Práticos Avançados](#projetos-práticos-avançados)
- [Hack The Box Academy Labs](#hack-the-box-academy-labs)
- [Ferramentas e Tecnologias](#ferramentas-e-tecnologias)
- [Documentação de Projetos](#documentação-de-projetos)

## Introdução

A análise de tráfego de rede e segurança do Active Directory são competências fundamentais para qualquer profissional de segurança cibernética. Este documento apresenta projetos práticos avançados baseados na metodologia **Hack The Box Academy**, conhecida por sua abordagem desafiadora e orientada pela perspectiva do atacante.

### Por que esta Abordagem?

**Perspectiva Ofensiva para Defesa:**
- Compreender como os atacantes operam
- Identificar técnicas de evasão
- Desenvolver detecções mais eficazes
- Aprender através de cenários desafiadores

**Relevância Profissional:**
- Network traffic analysis é fundamental para SOC analysts
- Active Directory está presente em 95% das organizações enterprise
- Windows event logs são a principal fonte de evidências forenses

## Network Traffic Analysis

### Fundamentos da Análise de Tráfego

**Objetivos de Aprendizado:**
```
🔍 Distinção entre tráfego legítimo e malicioso
📊 Análise de protocolos de rede
🚨 Detecção de comunicação C2 (Command & Control)
🕵️ Identificação de data exfiltration
⚡ Análise de ataques em tempo real
```

**Cenários Práticos:**
- Detecção de beaconing C2
- Análise de DNS tunneling
- Identificação de lateral movement
- Investigação de data exfiltration
- Análise de encrypted traffic

### Projeto 1: C2 Communication Detection

**Objetivo**: Identificar comunicação Command & Control em tráfego de rede.

**Ambiente de Laboratório:**
```
🖥️ Lab Setup:
   - Victim machine (Windows 10)
   - Attacker machine (Kali Linux)
   - Network monitoring (pfSense + Suricata)
   - Packet capture (Wireshark/tcpdump)

🎯 Attack Scenarios:
   - Cobalt Strike beacons
   - Metasploit C2 channels
   - DNS-based communication
   - HTTPS encrypted channels
```

**Análise com Wireshark:**
```python
# Python script para automação de análise
import pyshark
import pandas as pd
from collections import Counter
import matplotlib.pyplot as plt

class C2Detector:
    def __init__(self, pcap_file):
        self.capture = pyshark.FileCapture(pcap_file)
        self.suspicious_patterns = []

    def detect_beaconing(self):
        """Detecta padrões de beaconing C2"""
        timestamps = []
        destinations = []

        for packet in self.capture:
            if hasattr(packet, 'ip'):
                timestamps.append(float(packet.sniff_timestamp))
                destinations.append(packet.ip.dst)

        # Análise de intervalo regular (beaconing)
        intervals = []
        for i in range(1, len(timestamps)):
            interval = timestamps[i] - timestamps[i-1]
            intervals.append(interval)

        # Detectar intervalos regulares
        interval_counts = Counter([round(x) for x in intervals])
        regular_intervals = {k: v for k, v in interval_counts.items() if v > 10}

        return regular_intervals

    def detect_dns_tunneling(self):
        """Detecta DNS tunneling"""
        dns_queries = []

        for packet in self.capture:
            if hasattr(packet, 'dns') and hasattr(packet.dns, 'qry_name'):
                query = packet.dns.qry_name
                if len(query) > 50:  # Queries suspeitas longas
                    dns_queries.append(query)

        return dns_queries

    def analyze_payload_entropy(self):
        """Analisa entropia do payload para detectar encrypted data"""
        import math

        def calculate_entropy(data):
            if len(data) == 0:
                return 0

            counts = Counter(data)
            probs = [count/len(data) for count in counts.values()]
            return -sum(p * math.log2(p) for p in probs)

        high_entropy_packets = []

        for packet in self.capture:
            if hasattr(packet, 'data'):
                payload = packet.data.data
                entropy = calculate_entropy(payload)
                if entropy > 7.5:  # High entropy indicates encryption
                    high_entropy_packets.append({
                        'timestamp': packet.sniff_timestamp,
                        'src': packet.ip.src,
                        'dst': packet.ip.dst,
                        'entropy': entropy
                    })

        return high_entropy_packets

# Uso do detector
detector = C2Detector('suspicious_traffic.pcap')
beacons = detector.detect_beaconing()
dns_tunnels = detector.detect_dns_tunneling()
encrypted_traffic = detector.analyze_payload_entropy()

print(f"Potential C2 beacons: {beacons}")
print(f"DNS tunneling attempts: {len(dns_tunnels)}")
print(f"High entropy packets: {len(encrypted_traffic)}")
```

**Relatório de Análise:**
```markdown
# Network Traffic Analysis Report: C2 Detection

## Executive Summary
Analysis of network traffic captured during suspected C2 communication revealed multiple indicators of compromise including beaconing patterns, DNS tunneling, and encrypted data channels.

## Key Findings

### 1. C2 Beaconing Detection
**Pattern Identified**: Regular communication every 60 seconds
- **Source**: 192.168.1.105 (compromised workstation)
- **Destination**: 185.243.115.84 (known C2 server)
- **Protocol**: HTTPS (port 443)
- **Confidence**: High (95%)

### 2. DNS Tunneling Activity
**Suspicious Queries Detected**: 247 abnormal DNS requests
```wireshark
# Wireshark filter for long DNS queries
dns.qry.name && frame.len > 100
```
**Example Suspicious Query**:
```
a1b2c3d4e5f6789012345678901234567890123456789012345.malicious-domain.com
```

### 3. Encrypted Channel Analysis
**High Entropy Traffic**: 15% of analyzed packets
- Average entropy: 7.8 (threshold: 7.5)
- Likely encrypted C2 communication
- Evasion of content-based detection

## IOCs Extracted
| Type | Value | Confidence | Context |
|------|-------|------------|---------|
| IP | 185.243.115.84 | High | C2 server |
| Domain | malicious-domain.com | High | DNS tunneling |
| User-Agent | "Mozilla/5.0 Custom" | Medium | Suspicious browser |
| Cert Hash | sha256:abc123... | High | Malicious SSL cert |

## Defensive Recommendations
1. **Block identified C2 infrastructure**
2. **Implement DNS monitoring for long queries**
3. **Deploy entropy-based detection rules**
4. **Monitor for regular beaconing patterns**
5. **SSL/TLS inspection for encrypted channels**
```

### Projeto 2: Data Exfiltration Investigation

**Cenário**: Investigar suspeita de exfiltração de dados corporativos.

**Metodologia de Investigação:**
```
📊 Baseline Establishment:
   - Normal traffic patterns
   - Typical data transfer volumes
   - Standard protocol usage
   - Business hours activity

🚨 Anomaly Detection:
   - Unusual outbound traffic volumes
   - Off-hours data transfers
   - Non-standard protocols
   - Encrypted channels to external IPs

🔍 Deep Packet Inspection:
   - File transfer analysis
   - Protocol encapsulation
   - Data staging identification
   - Compression/encryption detection
```

**Script de Análise Avançada:**
```python
#!/usr/bin/env python3
"""
Data Exfiltration Detection Script
Analyzes network traffic for signs of data theft
"""

import pyshark
import numpy as np
from datetime import datetime, timedelta
import pandas as pd

class ExfiltrationDetector:
    def __init__(self, pcap_file, baseline_period_hours=24):
        self.capture = pyshark.FileCapture(pcap_file)
        self.baseline_period = baseline_period_hours
        self.alerts = []

    def analyze_transfer_volumes(self):
        """Analyze data transfer volumes for anomalies"""
        transfers = []

        for packet in self.capture:
            if hasattr(packet, 'ip') and hasattr(packet, 'tcp'):
                timestamp = datetime.fromtimestamp(float(packet.sniff_timestamp))
                size = int(packet.length)

                transfers.append({
                    'timestamp': timestamp,
                    'src_ip': packet.ip.src,
                    'dst_ip': packet.ip.dst,
                    'size': size,
                    'protocol': packet.highest_layer
                })

        df = pd.DataFrame(transfers)

        # Group by hour and calculate transfer volumes
        df['hour'] = df['timestamp'].dt.floor('H')
        hourly_volumes = df.groupby(['hour', 'dst_ip'])['size'].sum().reset_index()

        # Detect anomalies (transfers > 3 standard deviations)
        mean_volume = hourly_volumes['size'].mean()
        std_volume = hourly_volumes['size'].std()
        threshold = mean_volume + (3 * std_volume)

        anomalies = hourly_volumes[hourly_volumes['size'] > threshold]
        return anomalies

    def detect_off_hours_activity(self):
        """Detect data transfers during off-business hours"""
        off_hours_transfers = []

        for packet in self.capture:
            if hasattr(packet, 'ip'):
                timestamp = datetime.fromtimestamp(float(packet.sniff_timestamp))
                hour = timestamp.hour

                # Define business hours (9 AM to 6 PM)
                if hour < 9 or hour > 18:
                    if int(packet.length) > 1000:  # Large packets only
                        off_hours_transfers.append({
                            'timestamp': timestamp,
                            'src': packet.ip.src,
                            'dst': packet.ip.dst,
                            'size': packet.length
                        })

        return off_hours_transfers

    def identify_staging_behavior(self):
        """Identify potential data staging activities"""
        staging_indicators = []

        # Look for patterns indicating data collection/staging
        internal_ips = set()
        external_transfers = []

        for packet in self.capture:
            if hasattr(packet, 'ip'):
                src_ip = packet.ip.src
                dst_ip = packet.ip.dst

                # Identify internal vs external IPs
                if src_ip.startswith('192.168.') or src_ip.startswith('10.'):
                    internal_ips.add(src_ip)
                elif not dst_ip.startswith('192.168.') and not dst_ip.startswith('10.'):
                    external_transfers.append({
                        'src': src_ip,
                        'dst': dst_ip,
                        'timestamp': packet.sniff_timestamp,
                        'size': packet.length
                    })

        # Analyze external transfer patterns
        df_ext = pd.DataFrame(external_transfers)
        if not df_ext.empty:
            # Group by source and destination
            transfer_summary = df_ext.groupby(['src', 'dst']).agg({
                'size': ['sum', 'count'],
                'timestamp': ['min', 'max']
            }).reset_index()

            # Flag high-volume transfers to single destinations
            suspicious = transfer_summary[
                transfer_summary[('size', 'sum')] > 10_000_000  # 10MB threshold
            ]

            return suspicious.to_dict('records')

        return []

    def generate_report(self):
        """Generate comprehensive exfiltration analysis report"""
        volume_anomalies = self.analyze_transfer_volumes()
        off_hours = self.detect_off_hours_activity()
        staging = self.identify_staging_behavior()

        report = {
            'analysis_timestamp': datetime.now().isoformat(),
            'volume_anomalies': len(volume_anomalies),
            'off_hours_transfers': len(off_hours),
            'staging_behaviors': len(staging),
            'risk_score': self.calculate_risk_score(volume_anomalies, off_hours, staging)
        }

        return report

    def calculate_risk_score(self, volumes, off_hours, staging):
        """Calculate overall risk score for data exfiltration"""
        score = 0

        # Volume anomalies contribute to risk
        score += min(len(volumes) * 10, 40)

        # Off-hours activity increases risk
        score += min(len(off_hours) * 5, 30)

        # Staging behavior is high risk
        score += min(len(staging) * 20, 30)

        return min(score, 100)  # Cap at 100

# Usage example
detector = ExfiltrationDetector('network_traffic.pcap')
report = detector.generate_report()

print(f"Data Exfiltration Risk Score: {report['risk_score']}/100")
print(f"Volume Anomalies: {report['volume_anomalies']}")
print(f"Off-Hours Transfers: {report['off_hours_transfers']}")
print(f"Staging Behaviors: {report['staging_behaviors']}")
```

## Active Directory Security

### Importância do Active Directory

**Presença Universal:**
- 95% das organizações enterprise utilizam AD
- Controle centralizado de identidades
- Target principal de atacantes
- Persistência e lateral movement

**Ataques Comuns:**
```
🎯 Principais Vetores de Ataque:
   - Kerberoasting
   - ASREPRoasting
   - Golden/Silver Ticket attacks
   - DCSync attacks
   - Pass-the-Hash/Pass-the-Ticket
   - Privilege escalation
```

### Projeto 3: AD Attack Detection Lab

**Ambiente de Laboratório:**
```
🏢 Active Directory Lab Setup:
   - Domain Controller (Windows Server 2019)
   - Member servers (2x Windows Server)
   - Workstations (3x Windows 10)
   - Security monitoring (Splunk/Wazuh)

👥 Test Accounts:
   - Domain Admin (high privileges)
   - Service Accounts (SPNs configured)
   - Regular users (various OUs)
   - Honey pot accounts (decoy)
```

**Attack Simulation Framework:**
```powershell
# PowerShell script para simulação de ataques AD
# AD_Attack_Simulation.ps1

# Kerberoasting Attack Simulation
function Simulate-Kerberoasting {
    Write-Host "[+] Simulating Kerberoasting Attack"

    # Enumerate service accounts with SPNs
    $SPNs = Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName

    foreach ($account in $SPNs) {
        Write-Host "    [>] Found SPN: $($account.SamAccountName) - $($account.ServicePrincipalName)"

        # Request service ticket (this generates event 4769)
        try {
            Add-Type -AssemblyName System.IdentityModel
            $ticket = New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList $account.ServicePrincipalName
            Write-Host "    [✓] Ticket requested for $($account.ServicePrincipalName)"
        }
        catch {
            Write-Host "    [✗] Failed to request ticket: $($_.Exception.Message)"
        }
    }
}

# ASREPRoasting Attack Simulation
function Simulate-ASREPRoasting {
    Write-Host "[+] Simulating ASREPRoasting Attack"

    # Find accounts with "Do not require Kerberos preauthentication"
    $NoPreauth = Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true}

    foreach ($account in $NoPreauth) {
        Write-Host "    [>] Found vulnerable account: $($account.SamAccountName)"

        # Simulate AS-REP request (this would generate logs)
        $username = $account.SamAccountName
        $domain = (Get-ADDomain).DNSRoot

        Write-Host "    [>] Simulating AS-REP request for $username@$domain"
    }
}

# Privilege Escalation Detection
function Simulate-PrivEsc {
    Write-Host "[+] Simulating Privilege Escalation Attempts"

    # Attempt to read sensitive registry keys
    $sensitiveKeys = @(
        "HKLM:\SAM\SAM\Domains\Account\Users",
        "HKLM:\SECURITY\Policy\Secrets",
        "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
    )

    foreach ($key in $sensitiveKeys) {
        try {
            Get-ItemProperty -Path $key -ErrorAction Stop
            Write-Host "    [!] Successfully accessed: $key"
        }
        catch {
            Write-Host "    [✓] Access denied to: $key (expected behavior)"
        }
    }
}

# Lateral Movement Simulation
function Simulate-LateralMovement {
    Write-Host "[+] Simulating Lateral Movement"

    # Get list of domain computers
    $computers = Get-ADComputer -Filter * | Select-Object -First 5

    foreach ($computer in $computers) {
        $computerName = $computer.Name
        Write-Host "    [>] Attempting connection to $computerName"

        # Test WMI access (generates authentication logs)
        try {
            $wmi = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName -ErrorAction Stop
            Write-Host "    [✓] WMI access successful to $computerName"
        }
        catch {
            Write-Host "    [✗] WMI access failed to $computerName"
        }

        # Test SMB access
        try {
            $smb = Test-Path "\\$computerName\C$" -ErrorAction Stop
            if ($smb) {
                Write-Host "    [✓] SMB access successful to $computerName"
            }
        }
        catch {
            Write-Host "    [✗] SMB access failed to $computerName"
        }
    }
}

# Main execution
Write-Host "=== Active Directory Attack Simulation ==="
Write-Host "Timestamp: $(Get-Date)"
Write-Host "Domain: $((Get-ADDomain).DNSRoot)"
Write-Host "Running User: $($env:USERNAME)"
Write-Host ""

Simulate-Kerberoasting
Write-Host ""
Simulate-ASREPRoasting
Write-Host ""
Simulate-PrivEsc
Write-Host ""
Simulate-LateralMovement

Write-Host ""
Write-Host "=== Simulation Complete ==="
Write-Host "Check security logs for generated events:"
Write-Host "- Event ID 4769 (Kerberos service ticket requests)"
Write-Host "- Event ID 4768 (Kerberos authentication tickets)"
Write-Host "- Event ID 4624/4625 (Logon success/failure)"
Write-Host "- Event ID 4648 (Explicit credential use)"
```

**Detection Rules (Splunk):**
```spl
# Kerberoasting Detection
index=windows EventCode=4769
| eval service_name=lower(Service_Name)
| where NOT (service_name LIKE "%$" OR service_name LIKE "krbtgt%")
| stats count by Account_Name, service_name, src_ip
| where count > 5
| sort -count

# ASREPRoasting Detection
index=windows EventCode=4768 Result_Code=0x17
| stats count by Account_Name, src_ip, _time
| where count > 3

# Lateral Movement Detection
index=windows (EventCode=4624 OR EventCode=4648)
| eval hour=strftime(_time, "%H")
| where (hour < 6 OR hour > 22)
| stats dc(Computer) as unique_computers by Account_Name
| where unique_computers > 5

# Privilege Escalation Detection
index=windows EventCode=4672
| where Privileges LIKE "%SeDebugPrivilege%" OR Privileges LIKE "%SeTakeOwnershipPrivilege%"
| stats count by Account_Name, Computer
| sort -count
```

## Windows Event Logs e Finding Evil

### Metodologia "Finding Evil"

**Abordagem Sistemática:**
```
📊 Event Log Analysis:
   - Security logs (authentication, privilege use)
   - System logs (service changes, boot events)
   - Application logs (software-specific events)
   - Custom logs (SIEM, security tools)

🕵️ Hunting Techniques:
   - Baseline establishment
   - Anomaly detection
   - IOC correlation
   - Timeline analysis
   - Behavioral analysis
```

### Projeto 4: Advanced Windows Log Analysis

**Log Collection Architecture:**
```powershell
# PowerShell script para coleta avançada de logs
# Windows_Log_Collector.ps1

function Collect-SecurityLogs {
    param(
        [string]$OutputPath = "C:\LogAnalysis",
        [int]$DaysBack = 7
    )

    Write-Host "[+] Collecting Windows Security Logs"

    # Create output directory
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

    # Calculate date range
    $StartTime = (Get-Date).AddDays(-$DaysBack)
    $EndTime = Get-Date

    # Export Security Event Log
    Write-Host "    [>] Exporting Security logs..."
    wevtutil epl Security "$OutputPath\Security_$(Get-Date -Format 'yyyyMMdd').evtx" "/q:*[System[TimeCreated[@SystemTime>='$($StartTime.ToString('yyyy-MM-ddTHH:mm:ss.fffZ'))']]]"

    # Export System Event Log
    Write-Host "    [>] Exporting System logs..."
    wevtutil epl System "$OutputPath\System_$(Get-Date -Format 'yyyyMMdd').evtx"

    # Export Application Event Log
    Write-Host "    [>] Exporting Application logs..."
    wevtutil epl Application "$OutputPath\Application_$(Get-Date -Format 'yyyyMMdd').evtx"

    # Export PowerShell logs
    Write-Host "    [>] Exporting PowerShell logs..."
    wevtutil epl "Microsoft-Windows-PowerShell/Operational" "$OutputPath\PowerShell_$(Get-Date -Format 'yyyyMMdd').evtx"

    # Export Sysmon logs (if available)
    try {
        wevtutil epl "Microsoft-Windows-Sysmon/Operational" "$OutputPath\Sysmon_$(Get-Date -Format 'yyyyMMdd').evtx"
        Write-Host "    [✓] Sysmon logs exported"
    }
    catch {
        Write-Host "    [!] Sysmon logs not available"
    }

    Write-Host "[✓] Log collection complete: $OutputPath"
}

function Parse-AuthenticationEvents {
    param([string]$LogPath)

    Write-Host "[+] Parsing Authentication Events"

    # Get logon events (successful and failed)
    $LogonEvents = Get-WinEvent -FilterHashtable @{
        Path = $LogPath
        ID = 4624, 4625, 4648, 4672
    } -ErrorAction SilentlyContinue

    $ParsedEvents = foreach ($event in $LogonEvents) {
        $eventXML = [xml]$event.ToXml()
        $eventData = @{}

        foreach ($data in $eventXML.Event.EventData.Data) {
            $eventData[$data.Name] = $data.'#text'
        }

        [PSCustomObject]@{
            TimeCreated = $event.TimeCreated
            EventID = $event.Id
            Computer = $event.MachineName
            AccountName = $eventData.TargetUserName
            AccountDomain = $eventData.TargetDomainName
            LogonType = $eventData.LogonType
            SourceIP = $eventData.IpAddress
            SourceHost = $eventData.WorkstationName
            ProcessName = $eventData.ProcessName
            AuthenticationPackage = $eventData.AuthenticationPackageName
        }
    }

    return $ParsedEvents
}

function Detect-SuspiciousActivity {
    param([array]$Events)

    Write-Host "[+] Analyzing for Suspicious Activity"

    # Multiple failed logins
    $FailedLogins = $Events | Where-Object {$_.EventID -eq 4625} |
        Group-Object AccountName, SourceIP |
        Where-Object {$_.Count -gt 10}

    if ($FailedLogins) {
        Write-Host "    [!] Potential brute force attacks detected:"
        foreach ($attack in $FailedLogins) {
            Write-Host "        - Account: $($attack.Name) - Failed attempts: $($attack.Count)"
        }
    }

    # Privilege use events
    $PrivilegeUse = $Events | Where-Object {$_.EventID -eq 4672} |
        Group-Object AccountName |
        Where-Object {$_.Count -gt 5}

    if ($PrivilegeUse) {
        Write-Host "    [!] Excessive privilege use detected:"
        foreach ($user in $PrivilegeUse) {
            Write-Host "        - Account: $($user.Name) - Privilege events: $($user.Count)"
        }
    }

    # Off-hours logons
    $OffHoursLogons = $Events | Where-Object {
        $_.EventID -eq 4624 -and
        ($_.TimeCreated.Hour -lt 6 -or $_.TimeCreated.Hour -gt 22)
    }

    if ($OffHoursLogons) {
        Write-Host "    [!] Off-hours logons detected: $($OffHoursLogons.Count) events"
    }

    # Service account interactive logons
    $ServiceAccountLogons = $Events | Where-Object {
        $_.EventID -eq 4624 -and
        $_.LogonType -eq 2 -and
        $_.AccountName -like "*svc*"
    }

    if ($ServiceAccountLogons) {
        Write-Host "    [!] Service account interactive logons detected:"
        $ServiceAccountLogons | ForEach-Object {
            Write-Host "        - Account: $($_.AccountName) - Time: $($_.TimeCreated)"
        }
    }
}

# Main execution
$LogPath = "C:\LogAnalysis"
Collect-SecurityLogs -OutputPath $LogPath -DaysBack 7

$SecurityLogPath = "$LogPath\Security_$(Get-Date -Format 'yyyyMMdd').evtx"
$AuthEvents = Parse-AuthenticationEvents -LogPath $SecurityLogPath
Detect-SuspiciousActivity -Events $AuthEvents

Write-Host "[✓] Windows log analysis complete"
```

**Timeline Analysis Script:**
```python
#!/usr/bin/env python3
"""
Windows Event Log Timeline Analysis
Creates comprehensive timeline for incident investigation
"""

import xml.etree.ElementTree as ET
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
import argparse

class WindowsLogAnalyzer:
    def __init__(self, evtx_file):
        self.evtx_file = evtx_file
        self.events = []

    def parse_evtx(self):
        """Parse EVTX file and extract relevant events"""
        # Note: In real implementation, use python-evtx library
        # This is a simplified example

        high_value_events = {
            4624: "Successful Logon",
            4625: "Failed Logon",
            4648: "Explicit Credential Use",
            4672: "Special Privileges Assigned",
            4769: "Kerberos Service Ticket",
            4776: "NTLM Authentication",
            1102: "Audit Log Cleared",
            7045: "Service Installation"
        }

        # Simulate parsing (replace with actual EVTX parsing)
        sample_events = [
            {
                'timestamp': '2024-01-15 09:15:23',
                'event_id': 4624,
                'description': 'Successful Logon',
                'account': 'admin_user',
                'source_ip': '192.168.1.100',
                'computer': 'DC01'
            },
            {
                'timestamp': '2024-01-15 09:16:45',
                'event_id': 4769,
                'description': 'Kerberos Service Ticket',
                'account': 'admin_user',
                'service': 'HTTP/web-server',
                'computer': 'DC01'
            }
        ]

        return sample_events

    def create_timeline(self, events):
        """Create chronological timeline of events"""
        df = pd.DataFrame(events)
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        df = df.sort_values('timestamp')

        return df

    def detect_attack_patterns(self, timeline):
        """Detect common attack patterns in timeline"""
        patterns = {
            'kerberoasting': [],
            'lateral_movement': [],
            'privilege_escalation': [],
            'persistence': []
        }

        # Kerberoasting pattern
        kerberos_events = timeline[timeline['event_id'] == 4769]
        if len(kerberos_events) > 10:
            patterns['kerberoasting'] = kerberos_events.to_dict('records')

        # Lateral movement pattern
        logon_events = timeline[timeline['event_id'] == 4624]
        unique_computers = logon_events['computer'].nunique()
        if unique_computers > 5:
            patterns['lateral_movement'] = logon_events.to_dict('records')

        return patterns

    def generate_report(self):
        """Generate comprehensive analysis report"""
        events = self.parse_evtx()
        timeline = self.create_timeline(events)
        patterns = self.detect_attack_patterns(timeline)

        report = {
            'analysis_summary': {
                'total_events': len(events),
                'time_range': {
                    'start': timeline['timestamp'].min(),
                    'end': timeline['timestamp'].max()
                },
                'unique_accounts': timeline['account'].nunique(),
                'unique_computers': timeline['computer'].nunique()
            },
            'detected_patterns': patterns,
            'timeline': timeline.to_dict('records')
        }

        return report

    def visualize_timeline(self, timeline):
        """Create visual timeline of events"""
        plt.figure(figsize=(15, 8))

        event_types = timeline['event_id'].unique()
        colors = plt.cm.Set1(range(len(event_types)))

        for i, event_type in enumerate(event_types):
            event_data = timeline[timeline['event_id'] == event_type]
            plt.scatter(event_data['timestamp'], [event_type] * len(event_data),
                       c=[colors[i]], label=f'Event {event_type}', alpha=0.7, s=50)

        plt.xlabel('Timeline')
        plt.ylabel('Event ID')
        plt.title('Windows Event Timeline Analysis')
        plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig('event_timeline.png', dpi=300, bbox_inches='tight')
        plt.show()

# Usage
if __name__ == "__main__":
    analyzer = WindowsLogAnalyzer('security.evtx')
    report = analyzer.generate_report()

    print("Windows Event Log Analysis Report")
    print("=" * 40)
    print(f"Total Events: {report['analysis_summary']['total_events']}")
    print(f"Unique Accounts: {report['analysis_summary']['unique_accounts']}")
    print(f"Unique Computers: {report['analysis_summary']['unique_computers']}")

    if report['detected_patterns']['kerberoasting']:
        print("\n[!] Kerberoasting activity detected")

    if report['detected_patterns']['lateral_movement']:
        print("[!] Lateral movement detected")
```

## Hack The Box Academy Labs

### Lab 1: Introduction to Network Traffic Analysis

**Objetivos de Aprendizado:**
```
🎯 Competências Desenvolvidas:
   - Análise de protocolos de rede
   - Identificação de tráfego malicioso
   - Extração de IOCs
   - Correlação de eventos
   - Investigação forense de rede
```

**Exercícios Práticos:**
1. **Protocol Analysis**: Análise detalhada de HTTP, DNS, SMTP
2. **Malware Communication**: Identificação de C2 channels
3. **Data Exfiltration**: Detecção de data theft
4. **Encrypted Traffic**: Análise de tráfego cifrado
5. **IOC Extraction**: Extração de indicators of compromise

### Lab 2: Introduction to Active Directory

**Conceitos Fundamentais:**
```
🏢 Active Directory Components:
   - Domain Controllers
   - Organizational Units (OUs)
   - Group Policy Objects (GPOs)
   - Service Principal Names (SPNs)
   - Kerberos Authentication
   - LDAP Directory Services
```

**Hands-on Activities:**
1. **AD Enumeration**: Descoberta de estrutura e objetos
2. **Authentication Analysis**: Compreensão do Kerberos
3. **Privilege Mapping**: Identificação de contas privilegiadas
4. **Security Assessment**: Auditoria de configurações
5. **Attack Simulation**: Simulação de ataques comuns

### Lab 3: Windows Event Logs and Finding Evil

**Metodologia de Investigação:**
```
🔍 Hunting Methodology:
   - Event log collection
   - Baseline establishment
   - Anomaly identification
   - Pattern recognition
   - IOC correlation
   - Timeline reconstruction
```

**Exercícios Avançados:**
1. **APT Investigation**: Investigação de ameaça persistente
2. **Insider Threat**: Detecção de ameaças internas
3. **Malware Analysis**: Análise de comportamento via logs
4. **Lateral Movement**: Rastreamento de movimentação lateral
5. **Data Exfiltration**: Investigação de roubo de dados

## Ferramentas e Tecnologias

### Network Analysis Tools

**Wireshark:**
```bash
# Filtros avançados para análise
# Tráfego HTTP suspeito
http.request.method == "POST" and frame.len > 1000

# DNS tunneling
dns and frame.len > 512

# Beaconing detection
tcp.flags.push == 1 and tcp.len > 0

# Encrypted traffic analysis
ssl.handshake.type == 1
```

**Zeek (Bro):**
```zeek
# Script personalizado para detecção C2
# c2_detection.zeek

@load base/protocols/http
@load base/protocols/dns

module C2Detection;

# Track beaconing patterns
global beacon_intervals: table[addr] of vector of interval;

event http_request(c: connection, method: string, original_URI: string, unescaped_URI: string, version: string) {
    local src = c$id$orig_h;
    local now = network_time();

    # Track request timing for beaconing
    if (src in beacon_intervals) {
        local last_time = |beacon_intervals[src]| > 0 ? beacon_intervals[src][|beacon_intervals[src]|-1] : 0sec;
        local interval = now - last_time;
        beacon_intervals[src] += interval;
    } else {
        beacon_intervals[src] = vector();
    }

    # Detect regular intervals (potential beaconing)
    if (|beacon_intervals[src]| > 10) {
        local avg_interval = 0sec;
        for (i in beacon_intervals[src]) {
            avg_interval += beacon_intervals[src][i];
        }
        avg_interval = avg_interval / |beacon_intervals[src]|;

        # Check for regularity (variance < 20%)
        local variance = 0.0;
        for (i in beacon_intervals[src]) {
            local diff = beacon_intervals[src][i] - avg_interval;
            variance += diff * diff;
        }
        variance = variance / |beacon_intervals[src]|;

        if (sqrt(variance) < avg_interval * 0.2) {
            print fmt("Potential C2 beaconing detected from %s (avg interval: %s)", src, avg_interval);
        }
    }
}
```

### Active Directory Tools

**PowerView:**
```powershell
# AD reconnaissance with PowerView
Import-Module PowerView

# Enumerate domain information
Get-NetDomain
Get-NetDomainController

# Find service accounts with SPNs
Get-NetUser -SPN

# Enumerate high-privilege groups
Get-NetGroupMember "Domain Admins"
Get-NetGroupMember "Enterprise Admins"

# Find computers with unconstrained delegation
Get-NetComputer -UnconstrainedDelegation

# Enumerate GPOs
Get-NetGPO

# Find interesting ACLs
Find-InterestingDomainAcl
```

**BloodHound:**
```cypher
// Neo4j queries for BloodHound analysis

// Find shortest path to Domain Admins
MATCH (u:User {name:"USER@DOMAIN.COM"}), (g:Group {name:"DOMAIN ADMINS@DOMAIN.COM"}), p=shortestPath((u)-[*1..]->(g)) RETURN p

// Find users with DCSync privileges
MATCH (u:User)-[:MemberOf*1..]->(g:Group)-[:GetChanges|GetChangesAll*1..]->(d:Domain) RETURN u

// Find computers with unconstrained delegation
MATCH (c:Computer {unconstraineddelegation:true}) RETURN c

// Find users with most local admin rights
MATCH (u:User)-[:AdminTo]->(c:Computer) RETURN u.name, count(c) ORDER BY count(c) DESC

// Find kerberoastable users
MATCH (u:User) WHERE u.hasspn=true RETURN u
```

## Documentação de Projetos

### Template de Projeto GitHub

```markdown
# Advanced Network & AD Security Analysis

## 🎯 Project Overview
Comprehensive analysis of network traffic and Active Directory security using advanced techniques and tools based on Hack The Box Academy methodology.

## 🏗️ Architecture

### Lab Environment
```
🌐 Network Topology:
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Attacker VM   │    │   Network       │    │  Target Network │
│   (Kali Linux)  │<-->│   Monitor       │<-->│   (AD Domain)   │
│                 │    │  (pfSense +     │    │                 │
└─────────────────┘    │   Suricata)     │    └─────────────────┘
                       └─────────────────┘
```

### Components
- **Domain Controller**: Windows Server 2019 (DC01)
- **Member Servers**: 2x Windows Server 2016
- **Workstations**: 3x Windows 10 Pro
- **Security Monitoring**: Splunk Enterprise + Sysmon
- **Network Analysis**: Wireshark + Zeek IDS

## 🔬 Analysis Projects

### 1. C2 Communication Detection
**Objective**: Identify and analyze command & control traffic patterns

**Key Findings**:
- Detected 15 unique beaconing patterns
- Identified DNS tunneling attempts (247 suspicious queries)
- Extracted 23 IOCs from encrypted channels

**Technologies**: Wireshark, Python, Zeek, Splunk

### 2. Kerberoasting Attack Analysis
**Objective**: Simulate and detect Kerberoasting attacks in AD environment

**Attack Simulation**:
```powershell
# Automated Kerberoasting simulation
Get-NetUser -SPN | Get-NetUser | ForEach-Object {
    Request-SPNTicket -SPN $_.ServicePrincipalName
}
```

**Detection Rules**:
```spl
# Splunk detection for Kerberoasting
index=windows EventCode=4769 Service_Name!="*$" Service_Name!="krbtgt"
| stats count by Account_Name, Service_Name
| where count > 5
```

**Results**:
- Successfully detected all simulated Kerberoasting attempts
- Average detection time: 2.3 minutes
- False positive rate: < 1%

### 3. Lateral Movement Investigation
**Scenario**: Investigation of suspected lateral movement across AD environment

**Investigation Timeline**:
```
09:15:23 - Initial compromise (Workstation-01)
09:17:45 - Credential dumping detected
09:19:12 - First lateral movement (Server-01)
09:22:33 - Privilege escalation attempt
09:25:17 - Domain Admin compromise
```

**Evidence Collected**:
- 347 Windows event logs analyzed
- 12 affected systems identified
- Complete attack path reconstructed
- 28 IOCs extracted and verified

## 📊 Key Metrics
- **Detection Accuracy**: 94.7%
- **False Positive Rate**: 2.3%
- **Mean Time to Detection**: 4.2 minutes
- **Investigation Time**: 45 minutes average

## 🛠️ Tools & Technologies

### Network Analysis
- **Wireshark**: Deep packet inspection
- **Zeek**: Network security monitoring
- **Python**: Custom analysis scripts
- **Splunk**: Log correlation and analysis

### Active Directory
- **PowerView**: AD enumeration
- **BloodHound**: Attack path analysis
- **Mimikatz**: Credential extraction simulation
- **Rubeus**: Kerberos attack toolkit

### Windows Forensics
- **Event Log Analysis**: PowerShell scripts
- **Sysmon**: Enhanced logging
- **Timeline Explorer**: Timeline reconstruction
- **Volatility**: Memory analysis (when applicable)

## 📁 Repository Structure
```
network-ad-security-analysis/
├── docs/
│   ├── lab-setup.md
│   ├── attack-scenarios.md
│   └── detection-rules.md
├── scripts/
│   ├── network-analysis/
│   ├── ad-enumeration/
│   └── log-analysis/
├── reports/
│   ├── c2-detection-report.md
│   ├── kerberoasting-analysis.md
│   └── lateral-movement-investigation.md
├── configs/
│   ├── splunk-searches.txt
│   ├── zeek-scripts/
│   └── sysmon-config.xml
└── evidence/
    ├── pcap-files/
    ├── event-logs/
    └── screenshots/
```

## 🎓 Learning Outcomes
- Advanced network traffic analysis techniques
- Deep understanding of Active Directory security
- Practical experience with Windows event log analysis
- Hands-on incident response capabilities
- Proficiency with industry-standard security tools

## 🏆 Certifications Alignment
This project aligns with the following certification objectives:
- **GCIH** (GIAC Certified Incident Handler)
- **GNFA** (GIAC Network Forensic Analyst)
- **GCFA** (GIAC Certified Forensic Analyst)
- **Blue Team Level 1** (BTL1)

## 📞 Contact
For questions about this project or collaboration opportunities:
- **Email**: security.analyst@example.com
- **LinkedIn**: [linkedin.com/in/security-analyst](https://linkedin.com/in/security-analyst)
```

### Adição ao Currículo

```markdown
## PRACTICAL PROJECTS

### Advanced Network Traffic Analysis | Hack The Box Academy
Conducted comprehensive network traffic analysis to identify malicious communications, C2 channels, and data exfiltration attempts using industry-standard tools and methodologies.
- **Tools**: Wireshark, Zeek, Python, Splunk
- **Achievements**: 94.7% detection accuracy, 2.3% false positive rate

### Active Directory Security Assessment | Laboratory Environment
Simulated and detected common AD attacks including Kerberoasting, ASREPRoasting, and lateral movement in enterprise domain environment.
- **Technologies**: PowerView, BloodHound, Mimikatz, Windows Event Logs
- **Results**: Complete attack path reconstruction, 28 IOCs extracted

### Windows Event Log Analysis | Finding Evil Methodology
Implemented advanced log analysis techniques to identify malicious activities, privilege escalation, and persistent threats through Windows event correlation.
- **Frameworks**: MITRE ATT&CK, NIST Incident Response
- **Impact**: Reduced investigation time by 60% through automated analysis
```

Estes projetos avançados de Network Traffic Analysis e Active Directory Security fornecem experiência prática fundamental para qualquer profissional de segurança cibernética, combinando conhecimento teórico com habilidades técnicas aplicáveis no mundo real.

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Analisar transcri\u00e7\u00e3o do v\u00eddeo sobre projetos de seguran\u00e7a cibern\u00e9tica", "status": "completed", "activeForm": "Analisando transcri\u00e7\u00e3o do v\u00eddeo sobre projetos de seguran\u00e7a cibern\u00e9tica"}, {"content": "Criar documento sobre projetos SOC Analyst", "status": "completed", "activeForm": "Criando documento sobre projetos SOC Analyst"}, {"content": "Criar documento sobre Network Traffic Analysis e Active Directory", "status": "completed", "activeForm": "Criando documento sobre Network Traffic Analysis e Active Directory"}, {"content": "Criar documento sobre Vulnerability Management", "status": "in_progress", "activeForm": "Criando documento sobre Vulnerability Management"}, {"content": "Criar documento sobre GRC (Governance, Risk and Compliance)", "status": "pending", "activeForm": "Criando documento sobre GRC"}, {"content": "Criar documento sobre Cloud Security", "status": "pending", "activeForm": "Criando documento sobre Cloud Security"}, {"content": "Atualizar documento principal de estrat\u00e9gias com foco em seguran\u00e7a", "status": "pending", "activeForm": "Atualizando documento principal de estrat\u00e9gias com foco em seguran\u00e7a"}]