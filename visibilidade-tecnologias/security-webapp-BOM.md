# Security WebApp - Bill of Materials (BOM)

## 📋 Visão Geral do BOM

Este documento detalha todos os componentes, dependências e ferramentas necessárias para implementar a **Security Demo WebApp** e seus projetos de monitoramento paralelos.

## 🏗️ Componentes da Aplicação Principal

### Backend - Laravel
```json
{
  "name": "security-webapp",
  "description": "Laravel security demonstration webapp",
  "version": "1.0.0",
  "require": {
    "php": "^8.3",
    "laravel/framework": "^11.0",
    "laravel/sanctum": "^4.0",
    "laravel/telescope": "^5.0",
    "spatie/laravel-activitylog": "^4.8",
    "spatie/laravel-permission": "^6.4",
    "spatie/laravel-security-headers": "^1.3",
    "pragmarx/google2fa-laravel": "^2.0",
    "league/commonmark": "^2.4",
    "predis/predis": "^2.2"
  },
  "require-dev": {
    "laravel/sail": "^1.29",
    "laravel/pint": "^1.13",
    "nunomaduro/collision": "^8.1",
    "phpunit/phpunit": "^11.0",
    "mockery/mockery": "^1.6",
    "fakerphp/faker": "^1.23"
  }
}
```

### Frontend
```json
{
  "name": "security-webapp-frontend",
  "private": true,
  "type": "module",
  "devDependencies": {
    "@tailwindcss/forms": "^0.5.7",
    "@tailwindcss/typography": "^0.5.10",
    "alpinejs": "^3.13.3",
    "axios": "^1.6.4",
    "laravel-vite-plugin": "^1.0",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.4.0",
    "vite": "^5.0",
    "chart.js": "^4.4.1",
    "chartjs-adapter-date-fns": "^3.0.0"
  },
  "dependencies": {
    "date-fns": "^3.2.0"
  }
}
```

## 🐳 Infraestrutura Docker

### Docker Compose Principal
```yaml
# docker-compose.yml
version: '3.8'

services:
  # Aplicação Principal
  webapp:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: security-webapp
    ports:
      - "8000:8000"
    environment:
      - APP_ENV=local
      - APP_DEBUG=true
      - LOG_LEVEL=debug
      - LOG_CHANNEL=stack
    volumes:
      - .:/var/www/html
      - ./storage/logs:/var/www/html/storage/logs
    depends_on:
      - database
      - redis

  # Banco de Dados
  database:
    image: postgres:15-alpine
    container_name: security-webapp-db
    environment:
      POSTGRES_DB: security_webapp
      POSTGRES_USER: security_user
      POSTGRES_PASSWORD: secure_password_123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Cache
  redis:
    image: redis:7-alpine
    container_name: security-webapp-redis
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Dockerfile da Aplicação
```dockerfile
# Dockerfile
FROM php:8.3-fpm-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    nginx \
    nodejs \
    npm \
    postgresql-dev \
    zip \
    unzip \
    git \
    curl \
    supervisor

# Instalar extensões PHP
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    bcmath \
    pcntl \
    sockets

# Instalar Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Configurar usuário
RUN addgroup -g 1000 -S www && \
    adduser -u 1000 -S www -G www

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos da aplicação
COPY --chown=www:www . .

# Instalar dependências
RUN composer install --no-dev --optimize-autoloader --no-interaction
RUN npm install && npm run build

# Configurar permissões
RUN chown -R www:www /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expor porta
EXPOSE 8000

# Comando de inicialização
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

## 🔧 Ferramentas de Monitoramento

### Stack SIEM - Wazuh
```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  # Wazuh Manager
  wazuh-manager:
    image: wazuh/wazuh-manager:4.7.0
    container_name: wazuh-manager
    hostname: wazuh-manager
    restart: always
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 655360
        hard: 655360
    ports:
      - "1514:1514"
      - "1515:1515"
      - "514:514/udp"
      - "55000:55000"
    environment:
      - INDEXER_URL=https://wazuh-indexer:9200
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - FILEBEAT_SSL_VERIFICATION_MODE=full
      - SSL_CERTIFICATE_AUTHORITIES=/etc/ssl/root-ca.pem
      - SSL_CERTIFICATE=/etc/ssl/filebeat.pem
      - SSL_KEY=/etc/ssl/filebeat.key
      - API_USERNAME=wazuh-wui
      - API_PASSWORD=MyS3cr37P450r.*-
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
      - filebeat_etc:/etc/filebeat
      - filebeat_var:/var/lib/filebeat
      - ./config/wazuh_indexer_ssl_certs/root-ca-manager.pem:/etc/ssl/root-ca.pem
      - ./config/wazuh_indexer_ssl_certs/wazuh-manager.pem:/etc/ssl/filebeat.pem
      - ./config/wazuh_indexer_ssl_certs/wazuh-manager-key.pem:/etc/ssl/filebeat.key
      - ./config/wazuh_cluster/wazuh_manager.conf:/wazuh-config-mount/etc/ossec.conf

  # Wazuh Indexer
  wazuh-indexer:
    image: wazuh/wazuh-indexer:4.7.0
    container_name: wazuh-indexer
    hostname: wazuh-indexer
    restart: always
    ports:
      - "9200:9200"
    environment:
      - "OPENSEARCH_JAVA_OPTS=-Xms1024m -Xmx1024m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - wazuh-indexer-data:/var/lib/wazuh-indexer
      - ./config/wazuh_indexer_ssl_certs/root-ca.pem:/usr/share/wazuh-indexer/certs/root-ca.pem
      - ./config/wazuh_indexer_ssl_certs/wazuh-indexer-key.pem:/usr/share/wazuh-indexer/certs/wazuh-indexer.key
      - ./config/wazuh_indexer_ssl_certs/wazuh-indexer.pem:/usr/share/wazuh-indexer/certs/wazuh-indexer.pem
      - ./config/wazuh_indexer_ssl_certs/admin.pem:/usr/share/wazuh-indexer/certs/admin.pem
      - ./config/wazuh_indexer_ssl_certs/admin-key.pem:/usr/share/wazuh-indexer/certs/admin-key.pem
      - ./config/wazuh_indexer/wazuh.indexer.yml:/usr/share/wazuh-indexer/opensearch.yml
      - ./config/wazuh_indexer/internal_users.yml:/usr/share/wazuh-indexer/opensearch-security/internal_users.yml

  # Wazuh Dashboard
  wazuh-dashboard:
    image: wazuh/wazuh-dashboard:4.7.0
    container_name: wazuh-dashboard
    hostname: wazuh-dashboard
    restart: always
    ports:
      - 443:5601
    environment:
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - WAZUH_API_URL=https://wazuh-manager
      - DASHBOARD_USERNAME=kibanaserver
      - DASHBOARD_PASSWORD=kibanaserver
      - API_USERNAME=wazuh-wui
      - API_PASSWORD=MyS3cr37P450r.*-
    volumes:
      - ./config/wazuh_indexer_ssl_certs/wazuh-dashboard.pem:/usr/share/wazuh-dashboard/certs/wazuh-dashboard.pem
      - ./config/wazuh_indexer_ssl_certs/wazuh-dashboard-key.pem:/usr/share/wazuh-dashboard/certs/wazuh-dashboard-key.pem
      - ./config/wazuh_indexer_ssl_certs/root-ca.pem:/usr/share/wazuh-dashboard/certs/root-ca.pem
      - ./config/wazuh_dashboard/opensearch_dashboards.yml:/usr/share/wazuh-dashboard/config/opensearch_dashboards.yml
      - ./config/wazuh_dashboard/wazuh.yml:/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml
    depends_on:
      - wazuh-indexer
    links:
      - wazuh-indexer:wazuh-indexer
      - wazuh-manager:wazuh-manager

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
  filebeat_etc:
  filebeat_var:
  wazuh-indexer-data:
```

### Stack ELK (Elasticsearch, Logstash, Kibana)
```yaml
# docker-compose.elk.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: elasticsearch
    environment:
      - node.name=elasticsearch
      - cluster.name=es-docker-cluster
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms2048m -Xmx2048m"
      - xpack.security.enabled=false
      - xpack.security.enrollment.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    networks:
      - elk

  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    container_name: logstash
    volumes:
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml:ro,Z
      - ./logstash/pipeline:/usr/share/logstash/pipeline:ro,Z
    ports:
      - "5044:5044"
      - "5000:5000/tcp"
      - "5000:5000/udp"
      - "9600:9600"
    environment:
      LS_JAVA_OPTS: "-Xmx1024m -Xms1024m"
    networks:
      - elk
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_URL: http://elasticsearch:9200
      ELASTICSEARCH_HOSTS: '["http://elasticsearch:9200"]'
    networks:
      - elk
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:

networks:
  elk:
    driver: bridge
```

### Vulnerability Scanner - OpenVAS
```yaml
# docker-compose.openvas.yml
version: '3.8'

services:
  openvas:
    image: greenbone/openvas-scanner:stable
    container_name: openvas-scanner
    restart: unless-stopped
    ports:
      - "9390:9390"
      - "9392:9392"
    environment:
      - GREENBONE_DEFAULT_PASSWORD=admin
      - GREENBONE_DEFAULT_USER=admin
    volumes:
      - openvas_data:/var/lib/openvas
      - openvas_plugins:/var/lib/openvas/plugins
      - openvas_cert:/var/lib/gvm/cert-data
      - openvas_scap:/var/lib/gvm/scap-data
      - openvas_dfn:/var/lib/gvm/dfn-cert-data
      - ./config/openvas:/etc/openvas

  # Alternative: Nuclei Scanner
  nuclei-scanner:
    image: projectdiscovery/nuclei:latest
    container_name: nuclei-scanner
    volumes:
      - ./nuclei-templates:/root/nuclei-templates
      - ./nuclei-results:/root/results
    command: ["sleep", "infinity"]  # Keep container running

volumes:
  openvas_data:
  openvas_plugins:
  openvas_cert:
  openvas_scap:
  openvas_dfn:
```

### Network Monitoring - Suricata
```yaml
# docker-compose.network.yml
version: '3.8'

services:
  suricata:
    image: jasonish/suricata:latest
    container_name: suricata-ids
    network_mode: "host"
    cap_add:
      - NET_ADMIN
      - SYS_NICE
    volumes:
      - ./config/suricata/suricata.yaml:/etc/suricata/suricata.yaml
      - ./config/suricata/rules:/var/lib/suricata/rules
      - suricata_logs:/var/log/suricata
    command: ["suricata", "-i", "eth0", "-c", "/etc/suricata/suricata.yaml", "-v"]

  # Network Traffic Analysis
  ntopng:
    image: ntop/ntopng:stable
    container_name: ntopng
    network_mode: "host"
    cap_add:
      - NET_ADMIN
    ports:
      - "3000:3000"
    volumes:
      - ntopng_data:/var/lib/ntopng
    command: ["--interface", "eth0", "--http-port", "3000", "--data-dir", "/var/lib/ntopng"]

volumes:
  suricata_logs:
  ntopng_data:
```

## 📊 Ferramentas de Análise e Métricas

### Prometheus + Grafana
```yaml
# docker-compose.metrics.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus:/etc/prometheus
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./config/grafana/provisioning/dashboards:/etc/grafana/provisioning/dashboards
      - ./config/grafana/provisioning/datasources:/etc/grafana/provisioning/datasources

  # Application Metrics Exporter
  app-exporter:
    build:
      context: ./monitoring/exporters/
      dockerfile: Dockerfile.app-exporter
    container_name: app-metrics-exporter
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://security_user:secure_password_123@database:5432/security_webapp
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - database
      - redis

volumes:
  prometheus_data:
  grafana_data:
```

## 🔧 Scripts de Automação

### Setup Scripts
```bash
#!/bin/bash
# scripts/setup.sh

echo "🚀 Setting up Security WebApp Environment"

# 1. Create necessary directories
mkdir -p {storage/logs,bootstrap/cache,config/{wazuh,suricata,openvas,grafana,prometheus}}
mkdir -p security-monitoring/{soc-monitoring,vulnerability-scanner,network-analysis,grc-compliance,cloud-security}

# 2. Set permissions
chmod -R 775 storage bootstrap/cache
chmod +x scripts/*.sh

# 3. Generate certificates for HTTPS
if [ ! -f "ssl/server.crt" ]; then
    mkdir -p ssl
    openssl req -x509 -newkey rsa:4096 -keyout ssl/server.key -out ssl/server.crt -days 365 -nodes -subj "/CN=security-demo.local"
fi

# 4. Create environment file
if [ ! -f ".env" ]; then
    cp .env.example .env
    php artisan key:generate
fi

# 5. Start Docker services
echo "📦 Starting Docker services..."
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml -f docker-compose.elk.yml up -d

# 6. Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# 7. Run database migrations
docker-compose exec webapp php artisan migrate --force
docker-compose exec webapp php artisan db:seed --force

# 8. Configure Wazuh rules
docker cp config/wazuh/webapp-rules.xml wazuh-manager:/var/ossec/etc/rules/
docker-compose exec wazuh-manager /var/ossec/bin/wazuh-control restart

echo "✅ Setup completed successfully!"
echo "🌐 WebApp: http://localhost:8000"
echo "📊 Wazuh: https://localhost:443"
echo "📈 Kibana: http://localhost:5601"
echo "📊 Grafana: http://localhost:3001"
```

### Monitoring Scripts
```bash
#!/bin/bash
# scripts/start-monitoring.sh

echo "🔍 Starting Security Monitoring..."

# 1. Start vulnerability scan
echo "Starting vulnerability scan..."
docker-compose exec nuclei-scanner nuclei -target http://webapp:8000 -output /root/results/webapp-scan.json

# 2. Start network monitoring
echo "Starting network monitoring..."
docker-compose exec suricata-ids suricata -i eth0 -c /etc/suricata/suricata.yaml -v &

# 3. Generate test traffic
echo "Generating test security events..."
python3 security-monitoring/scripts/generate-test-events.py

# 4. Check SIEM integration
echo "Checking SIEM integration..."
curl -X GET "http://localhost:9200/_cat/indices?v"

echo "✅ Monitoring started successfully!"
```

## 🧪 Scripts de Teste de Segurança

### Automated Security Tests
```python
#!/usr/bin/env python3
# security-monitoring/scripts/automated-security-tests.py

import requests
import json
import time
from datetime import datetime

class SecurityTester:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()

    def test_authentication_security(self):
        """Test authentication security measures"""
        print("🔐 Testing Authentication Security...")

        # Test rate limiting
        print("  Testing rate limiting...")
        for i in range(10):
            response = self.session.post(f"{self.base_url}/login", {
                "email": "attacker@test.com",
                "password": f"wrong_password_{i}"
            })
            print(f"    Attempt {i+1}: {response.status_code}")
            time.sleep(1)

    def test_security_headers(self):
        """Test security headers implementation"""
        print("🛡️ Testing Security Headers...")

        response = requests.get(self.base_url)
        headers = response.headers

        required_headers = [
            'X-Frame-Options',
            'X-Content-Type-Options',
            'X-XSS-Protection',
            'Content-Security-Policy'
        ]

        for header in required_headers:
            if header in headers:
                print(f"  ✅ {header}: {headers[header]}")
            else:
                print(f"  ❌ {header}: Missing")

    def test_sql_injection(self):
        """Test for SQL injection vulnerabilities"""
        print("💉 Testing SQL Injection...")

        payloads = [
            "' OR '1'='1",
            "admin'; DROP TABLE users; --",
            "1' UNION SELECT * FROM users --"
        ]

        for payload in payloads:
            response = self.session.post(f"{self.base_url}/login", {
                "email": payload,
                "password": "test"
            })
            print(f"  Payload: {payload[:20]}... Status: {response.status_code}")

    def generate_report(self):
        """Generate security test report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "target": self.base_url,
            "tests_performed": [
                "Authentication Security",
                "Security Headers",
                "SQL Injection"
            ],
            "status": "completed"
        }

        with open("security-test-report.json", "w") as f:
            json.dump(report, f, indent=2)

        print("📋 Report saved to security-test-report.json")

if __name__ == "__main__":
    tester = SecurityTester()
    tester.test_authentication_security()
    tester.test_security_headers()
    tester.test_sql_injection()
    tester.generate_report()
```

## 📦 Estrutura de Arquivos Completa

```
security-webapp/
├── app/
│   ├── Http/Controllers/
│   ├── Models/
│   ├── Services/
│   └── Middleware/
├── config/
│   ├── wazuh/
│   ├── suricata/
│   ├── openvas/
│   ├── grafana/
│   └── prometheus/
├── docker/
│   ├── nginx.conf
│   ├── supervisord.conf
│   └── php.ini
├── security-monitoring/
│   ├── soc-monitoring/
│   │   ├── wazuh-rules/
│   │   ├── splunk-queries/
│   │   └── playbooks/
│   ├── vulnerability-scanner/
│   │   ├── nuclei-templates/
│   │   ├── openvas-configs/
│   │   └── scripts/
│   ├── network-analysis/
│   │   ├── suricata-rules/
│   │   ├── wireshark-filters/
│   │   └── analysis-scripts/
│   ├── grc-compliance/
│   │   ├── frameworks/
│   │   ├── assessments/
│   │   └── reports/
│   └── cloud-security/
│       ├── terraform/
│       ├── scripts/
│       └── configs/
├── scripts/
│   ├── setup.sh
│   ├── start-monitoring.sh
│   └── security-tests.py
├── ssl/
│   ├── server.crt
│   └── server.key
├── docker-compose.yml
├── docker-compose.monitoring.yml
├── docker-compose.elk.yml
├── docker-compose.openvas.yml
├── docker-compose.network.yml
├── docker-compose.metrics.yml
├── Dockerfile
├── package.json
├── composer.json
└── README.md
```

## 💰 Estimativa de Custos (Desenvolvimento)

### Infraestrutura Local (Desenvolvimento)
- **Hardware Mínimo**: 16GB RAM, 4 CPU cores, 100GB storage
- **Custo**: $0 (usando Docker local)

### Cloud Deployment (Opcional para Demonstração)
- **AWS EC2**: t3.large (2 vCPU, 8GB) = ~$60/mês
- **Azure VM**: Standard_B2s = ~$50/mês
- **Google Cloud**: e2-standard-2 = ~$55/mês

### Ferramentas e Licenças
- **Wazuh**: Free (Open Source)
- **ELK Stack**: Free (Basic License)
- **OpenVAS**: Free (Open Source)
- **Grafana**: Free (Community Edition)
- **Suricata**: Free (Open Source)

**Total para Demo Local**: $0
**Total para Cloud Demo**: $50-60/mês (opcional)

## 🎯 ROI para Portfólio

### Valor Demonstrado
- **Hands-on Security Implementation**: Código real com controles de segurança
- **Enterprise Tools Integration**: Wazuh, ELK, OpenVAS, Grafana
- **Multiple Security Domains**: SOC, Vuln Mgmt, Network Analysis, GRC
- **Professional Documentation**: BOM, setup scripts, monitoring configs
- **Practical Demonstrations**: Testes reais de segurança em ambiente controlado

### Diferencial Competitivo
- Aplicação funcional vs teórica
- Monitoramento integrado vs standalone
- Multi-disciplinary vs single focus
- Production-ready vs academic
- Demonstrável em entrevistas vs apenas documentado

Este BOM garante que todos os componentes necessários estejam documentados e possam ser implementados de forma consistente e profissional.