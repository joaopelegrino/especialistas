# Security Demo WebApp - Laravel Security Portfolio

## 🎯 Visão Geral

**Security Demo WebApp** é uma aplicação Laravel simples (login/dashboard) projetada especificamente para demonstrar expertise em segurança cibernética através de implementações práticas e projetos de monitoramento paralelos.

A aplicação serve como **laboratório de segurança** onde cada aspecto demonstra competências específicas em diferentes domínios de cybersecurity.

## 🏗️ Arquitetura Simples

### Stack Básico
```
Backend: Laravel 11 + PHP 8.3
Frontend: Blade Templates + Alpine.js
Database: SQLite (para simplicidade)
Cache: File-based (desenvolvimento)
Security: Múltiplas camadas demonstrativas
```

### Estrutura da Aplicação
```
security-webapp/
├── app/
│   ├── Http/Controllers/
│   │   ├── AuthController.php
│   │   ├── DashboardController.php
│   │   └── SecurityController.php
│   ├── Models/
│   │   ├── User.php
│   │   └── SecurityEvent.php
│   └── Services/
│       └── SecurityService.php
├── resources/
│   └── views/
│       ├── auth/login.blade.php
│       ├── dashboard.blade.php
│       └── layouts/app.blade.php
├── security-monitoring/
│   ├── soc-monitoring/
│   ├── vulnerability-scanner/
│   ├── network-analysis/
│   ├── grc-compliance/
│   └── cloud-security/
└── docker-compose.yml
```

## 🔐 Features de Segurança Implementadas

### 1. Autenticação Segura
```php
// app/Http/Controllers/AuthController.php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use App\Services\SecurityService;

class AuthController extends Controller
{
    public function __construct(
        private SecurityService $securityService
    ) {}

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:8',
        ]);

        // Log tentativa de login
        $this->securityService->logAuthAttempt($request);

        // Rate limiting por IP
        if ($this->securityService->isRateLimited($request->ip())) {
            return back()->withErrors(['message' => 'Too many attempts']);
        }

        // MFA check se habilitado
        if (Auth::attempt($request->only('email', 'password'))) {
            $user = Auth::user();

            if ($user->mfa_enabled) {
                session(['pending_mfa' => $user->id]);
                return redirect()->route('mfa.verify');
            }

            // Log sucesso
            $this->securityService->logSuccessfulAuth($user, $request);

            return redirect()->route('dashboard');
        }

        // Log falha
        $this->securityService->logFailedAuth($request);

        return back()->withErrors(['message' => 'Invalid credentials']);
    }
}
```

### 2. Dashboard com Métricas de Segurança
```php
// app/Http/Controllers/DashboardController.php
<?php

namespace App\Http\Controllers;

use App\Services\SecurityService;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function __construct(
        private SecurityService $securityService
    ) {}

    public function index()
    {
        $securityMetrics = [
            'failed_logins_24h' => $this->securityService->getFailedLogins24h(),
            'security_alerts' => $this->securityService->getActiveAlerts(),
            'vulnerability_score' => $this->securityService->getVulnerabilityScore(),
            'compliance_status' => $this->securityService->getComplianceStatus(),
            'threat_level' => $this->securityService->getCurrentThreatLevel()
        ];

        return view('dashboard', compact('securityMetrics'));
    }

    public function securityEvents()
    {
        $events = $this->securityService->getRecentSecurityEvents(50);
        return response()->json($events);
    }
}
```

### 3. Service de Segurança Central
```php
// app/Services/SecurityService.php
<?php

namespace App\Services;

use App\Models\SecurityEvent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class SecurityService
{
    public function logAuthAttempt(Request $request): void
    {
        SecurityEvent::create([
            'type' => 'auth_attempt',
            'source_ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'email' => $request->input('email'),
            'metadata' => [
                'timestamp' => now(),
                'headers' => $request->headers->all()
            ]
        ]);

        // Enviar para SIEM externo
        $this->sendToSIEM('auth_attempt', $request);
    }

    public function isRateLimited(string $ip): bool
    {
        $key = "auth_attempts_{$ip}";
        $attempts = Cache::get($key, 0);

        if ($attempts >= 5) {
            // Log tentativa de brute force
            $this->logSecurityAlert('brute_force_attempt', [
                'source_ip' => $ip,
                'attempts' => $attempts
            ]);
            return true;
        }

        Cache::put($key, $attempts + 1, 900); // 15 minutos
        return false;
    }

    public function getVulnerabilityScore(): array
    {
        // Simular score baseado em scans reais
        return [
            'score' => 85,
            'critical' => 2,
            'high' => 5,
            'medium' => 12,
            'low' => 8,
            'last_scan' => now()->subHours(6)
        ];
    }

    public function getCurrentThreatLevel(): string
    {
        $failedLogins = $this->getFailedLogins24h();
        $activeAlerts = $this->getActiveAlerts();

        if ($failedLogins > 50 || $activeAlerts > 10) {
            return 'HIGH';
        } elseif ($failedLogins > 20 || $activeAlerts > 5) {
            return 'MEDIUM';
        }

        return 'LOW';
    }

    private function sendToSIEM(string $eventType, $data): void
    {
        // Integração com Wazuh/Splunk
        Log::channel('security')->info($eventType, [
            'data' => $data,
            'timestamp' => now()->toISOString()
        ]);
    }
}
```

## 📊 Templates com Segurança

### Layout Principal
```blade
{{-- resources/views/layouts/app.blade.php --}}
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';">
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <meta http-equiv="X-Frame-Options" content="DENY">
    <meta http-equiv="X-XSS-Protection" content="1; mode=block">

    <title>Security Demo WebApp</title>

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="bg-gray-100" x-data="securityApp()">
    <nav class="bg-blue-600 text-white p-4">
        <div class="container mx-auto flex justify-between items-center">
            <h1 class="text-xl font-bold">Security Demo</h1>
            <div>
                @auth
                    <span class="mr-4">{{ Auth::user()->name }}</span>
                    <span class="mr-4 px-2 py-1 bg-blue-800 rounded text-sm"
                          :class="{
                              'bg-red-600': threatLevel === 'HIGH',
                              'bg-yellow-600': threatLevel === 'MEDIUM',
                              'bg-green-600': threatLevel === 'LOW'
                          }"
                          x-text="'Threat: ' + threatLevel">
                    </span>
                    <form method="POST" action="{{ route('logout') }}" class="inline">
                        @csrf
                        <button type="submit" class="bg-red-500 px-3 py-1 rounded">Logout</button>
                    </form>
                @endauth
            </div>
        </div>
    </nav>

    <main class="container mx-auto py-6">
        @yield('content')
    </main>

    <script>
        function securityApp() {
            return {
                threatLevel: 'LOW',
                securityAlerts: 0,

                init() {
                    this.loadSecurityMetrics();
                    setInterval(() => this.loadSecurityMetrics(), 30000); // Update cada 30s
                },

                loadSecurityMetrics() {
                    fetch('/api/security/metrics')
                        .then(response => response.json())
                        .then(data => {
                            this.threatLevel = data.threat_level;
                            this.securityAlerts = data.active_alerts;
                        });
                }
            }
        }
    </script>
</body>
</html>
```

### Dashboard de Segurança
```blade
{{-- resources/views/dashboard.blade.php --}}
@extends('layouts.app')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <!-- Security Metrics Cards -->
    <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold text-gray-700">Failed Logins (24h)</h3>
        <p class="text-3xl font-bold {{ $securityMetrics['failed_logins_24h'] > 20 ? 'text-red-600' : 'text-green-600' }}">
            {{ $securityMetrics['failed_logins_24h'] }}
        </p>
    </div>

    <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold text-gray-700">Security Alerts</h3>
        <p class="text-3xl font-bold {{ $securityMetrics['security_alerts'] > 5 ? 'text-red-600' : 'text-green-600' }}">
            {{ $securityMetrics['security_alerts'] }}
        </p>
    </div>

    <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold text-gray-700">Vulnerability Score</h3>
        <p class="text-3xl font-bold {{ $securityMetrics['vulnerability_score']['score'] < 80 ? 'text-red-600' : 'text-green-600' }}">
            {{ $securityMetrics['vulnerability_score']['score'] }}/100
        </p>
    </div>

    <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold text-gray-700">Compliance Status</h3>
        <p class="text-3xl font-bold text-green-600">
            {{ $securityMetrics['compliance_status'] }}%
        </p>
    </div>
</div>

<!-- Security Events Table -->
<div class="bg-white rounded-lg shadow">
    <div class="p-6 border-b">
        <h2 class="text-xl font-semibold">Recent Security Events</h2>
    </div>
    <div class="p-6">
        <div id="security-events" x-data="securityEvents()">
            <table class="w-full">
                <thead>
                    <tr class="border-b">
                        <th class="text-left py-2">Timestamp</th>
                        <th class="text-left py-2">Type</th>
                        <th class="text-left py-2">Source IP</th>
                        <th class="text-left py-2">Severity</th>
                        <th class="text-left py-2">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <template x-for="event in events" :key="event.id">
                        <tr class="border-b">
                            <td class="py-2" x-text="event.created_at"></td>
                            <td class="py-2" x-text="event.type"></td>
                            <td class="py-2" x-text="event.source_ip"></td>
                            <td class="py-2">
                                <span class="px-2 py-1 rounded text-sm"
                                      :class="{
                                          'bg-red-100 text-red-800': event.severity === 'high',
                                          'bg-yellow-100 text-yellow-800': event.severity === 'medium',
                                          'bg-green-100 text-green-800': event.severity === 'low'
                                      }"
                                      x-text="event.severity">
                                </span>
                            </td>
                            <td class="py-2">
                                <button class="text-blue-600 hover:underline"
                                        @click="viewEvent(event.id)">
                                    View Details
                                </button>
                            </td>
                        </tr>
                    </template>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    function securityEvents() {
        return {
            events: [],

            init() {
                this.loadEvents();
                setInterval(() => this.loadEvents(), 10000); // Update cada 10s
            },

            loadEvents() {
                fetch('/dashboard/security-events')
                    .then(response => response.json())
                    .then(data => {
                        this.events = data;
                    });
            },

            viewEvent(eventId) {
                // Abrir modal com detalhes do evento
                console.log('Viewing event:', eventId);
            }
        }
    }
</script>
@endsection
```

## 🛠️ Setup Rápido

### Instalação
```bash
# 1. Clone e configure
git clone https://github.com/username/security-webapp.git
cd security-webapp

# 2. Instalar dependências
composer install
npm install

# 3. Configurar ambiente
cp .env.example .env
php artisan key:generate

# 4. Banco de dados
touch database/database.sqlite
php artisan migrate --seed

# 5. Build assets
npm run build

# 6. Executar
php artisan serve
```

### Login de Demonstração
```
Email: admin@security-demo.com
Password: SecureDemo123!
```

## 📋 Bill of Materials (BOM)

### Dependências Core
```json
{
  "name": "security-webapp",
  "require": {
    "laravel/framework": "^11.0",
    "laravel/sanctum": "^4.0",
    "laravel/telescope": "^5.0",
    "spatie/laravel-activitylog": "^4.8",
    "spatie/laravel-permission": "^6.4",
    "pragmarx/google2fa-laravel": "^2.0"
  },
  "require-dev": {
    "laravel/sail": "^1.29",
    "nunomaduro/collision": "^8.1",
    "phpunit/phpunit": "^11.0"
  }
}
```

### Frontend
```json
{
  "devDependencies": {
    "@tailwindcss/forms": "^0.5.7",
    "alpinejs": "^3.13.3",
    "axios": "^1.6.4",
    "laravel-vite-plugin": "^1.0",
    "tailwindcss": "^3.4.0",
    "vite": "^5.0"
  }
}
```

### Docker Compose para Monitoramento
```yaml
# docker-compose.monitoring.yml
version: '3.8'
services:
  webapp:
    build: .
    ports:
      - "8000:8000"
    environment:
      - APP_ENV=production
      - LOG_CHANNEL=stack
    volumes:
      - ./storage/logs:/var/www/storage/logs

  # SIEM Monitoring
  wazuh-manager:
    image: wazuh/wazuh-manager:4.7.0
    ports:
      - "1514:1514"
      - "1515:1515"
      - "55000:55000"
    environment:
      - INDEXER_URL=https://wazuh-indexer:9200
    volumes:
      - wazuh_api_configuration:/var/ossec/api/configuration
      - wazuh_etc:/var/ossec/etc
      - wazuh_logs:/var/ossec/logs
      - wazuh_queue:/var/ossec/queue
      - wazuh_var_multigroups:/var/ossec/var/multigroups
      - wazuh_integrations:/var/ossec/integrations
      - wazuh_active_response:/var/ossec/active-response/bin
      - wazuh_agentless:/var/ossec/agentless
      - wazuh_wodles:/var/ossec/wodles

  # Vulnerability Scanner
  openvas:
    image: greenbone/openvas-scanner:stable
    ports:
      - "9390:9390"
    environment:
      - GREENBONE_DEFAULT_PASSWORD=admin
    volumes:
      - openvas_data:/var/lib/openvas

  # Network Monitoring
  suricata:
    image: jasonish/suricata:latest
    network_mode: "host"
    cap_add:
      - NET_ADMIN
      - SYS_NICE
    volumes:
      - ./suricata:/etc/suricata
      - suricata_logs:/var/log/suricata

  # Log Management
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

volumes:
  wazuh_api_configuration:
  wazuh_etc:
  wazuh_logs:
  wazuh_queue:
  wazuh_var_multigroups:
  wazuh_integrations:
  wazuh_active_response:
  wazuh_agentless:
  wazuh_wodles:
  openvas_data:
  suricata_logs:
  elasticsearch_data:
```

## 🔍 Projetos de Monitoramento Paralelos

### 1. SOC Monitoring Setup
```bash
# Pasta: security-monitoring/soc-monitoring/
├── wazuh-rules/
│   ├── webapp-auth-rules.xml
│   └── webapp-security-rules.xml
├── splunk-queries/
│   ├── failed-login-detection.spl
│   └── threat-hunting.spl
└── incident-playbooks/
    ├── brute-force-response.md
    └── suspicious-activity.md
```

**Implementação**:
```xml
<!-- wazuh-rules/webapp-auth-rules.xml -->
<group name="webapp-auth">
  <rule id="100001" level="5">
    <if_sid>5716</if_sid>
    <field name="data.type">auth_attempt</field>
    <description>WebApp authentication attempt</description>
  </rule>

  <rule id="100002" level="10">
    <if_sid>100001</if_sid>
    <field name="data.type">auth_attempt</field>
    <same_source_ip />
    <frequency>5</frequency>
    <timeframe>300</timeframe>
    <description>WebApp brute force attack detected</description>
    <mitre>
      <id>T1110</id>
    </mitre>
  </rule>
</group>
```

### 2. Vulnerability Management
```bash
# Pasta: security-monitoring/vulnerability-scanner/
├── openvas-configs/
│   └── webapp-scan-config.xml
├── scripts/
│   ├── automated-scan.py
│   └── report-generator.py
└── reports/
    └── vulnerability-reports/
```

**Script Automatizado**:
```python
#!/usr/bin/env python3
# scripts/automated-scan.py
import requests
import json
from datetime import datetime

class WebAppVulnScanner:
    def __init__(self, target_url):
        self.target = target_url

    def run_security_scan(self):
        results = {
            'timestamp': datetime.now().isoformat(),
            'target': self.target,
            'findings': []
        }

        # Test security headers
        headers_test = self.check_security_headers()
        results['findings'].extend(headers_test)

        # Test authentication bypass
        auth_test = self.test_auth_bypass()
        results['findings'].extend(auth_test)

        # Test SQL injection
        sqli_test = self.test_sql_injection()
        results['findings'].extend(sqli_test)

        return results

    def check_security_headers(self):
        response = requests.get(self.target)
        findings = []

        required_headers = [
            'X-Frame-Options',
            'X-Content-Type-Options',
            'X-XSS-Protection',
            'Content-Security-Policy'
        ]

        for header in required_headers:
            if header not in response.headers:
                findings.append({
                    'type': 'Missing Security Header',
                    'severity': 'Medium',
                    'description': f'Missing {header} header',
                    'recommendation': f'Add {header} to responses'
                })

        return findings
```

### 3. Network Analysis
```bash
# Pasta: security-monitoring/network-analysis/
├── wireshark-filters/
│   └── webapp-traffic.txt
├── scripts/
│   ├── traffic-analyzer.py
│   └── anomaly-detector.py
└── pcap-analysis/
    └── suspicious-traffic/
```

### 4. GRC Compliance
```bash
# Pasta: security-monitoring/grc-compliance/
├── frameworks/
│   ├── nist-csf-mapping.json
│   └── owasp-top10-checklist.md
├── assessments/
│   ├── risk-assessment-template.xlsx
│   └── compliance-report.md
└── policies/
    ├── security-policy.md
    └── incident-response-plan.md
```

### 5. Cloud Security (se aplicável)
```bash
# Pasta: security-monitoring/cloud-security/
├── terraform/
│   └── secure-infrastructure.tf
├── scripts/
│   ├── cloud-security-scan.py
│   └── compliance-check.py
└── configs/
    ├── aws-security-config.json
    └── azure-security-baseline.json
```

## 📊 Demonstrações Práticas

### 1. Simular Ataque de Força Bruta
```bash
# Teste de segurança
for i in {1..10}; do
  curl -X POST http://localhost:8000/login \
    -d "email=admin@test.com&password=wrong$i" \
    -H "Content-Type: application/x-www-form-urlencoded"
done

# Verificar logs de segurança
tail -f storage/logs/security.log
```

### 2. Executar Scan de Vulnerabilidades
```bash
cd security-monitoring/vulnerability-scanner/
python3 scripts/automated-scan.py --target http://localhost:8000
```

### 3. Monitorar Tráfego de Rede
```bash
# Capturar tráfego da aplicação
sudo tcpdump -i lo port 8000 -w webapp-traffic.pcap

# Analisar com script customizado
python3 security-monitoring/network-analysis/scripts/traffic-analyzer.py webapp-traffic.pcap
```

## 🏆 Valor para Portfólio

### Demonstra Competências Em:
- ✅ **Secure Development**: Implementação de controles de segurança em código
- ✅ **SOC Operations**: Monitoramento e detecção de ameaças
- ✅ **Vulnerability Management**: Assessment e gestão de vulnerabilidades
- ✅ **Network Security**: Análise de tráfego e detecção de anomalias
- ✅ **GRC**: Compliance e gestão de risco
- ✅ **Incident Response**: Procedures de resposta a incidentes

### Diferencial Competitivo:
1. **Aplicação funcional** com código real de segurança
2. **Monitoramento integrado** com ferramentas enterprise
3. **Documentação profissional** com métricas e KPIs
4. **Demonstração prática** durante entrevistas técnicas
5. **Portfolio abrangente** cobrindo múltiplas disciplinas de segurança

Esta estrutura simples mas robusta demonstra expertise prática em segurança cibernética através de uma aplicação tangível e projetos de monitoramento que podem ser executados e demonstrados em tempo real.