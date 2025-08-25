# Implementação Técnica Pay-Per-Crawl - Brasil (Agosto 2025)

Este documento detalha os aspectos técnicos completos para implementar monetização pay-per-crawl em blogs brasileiros, considerando o cenário atual de agosto de 2025 com PIX Automático operacional e integração direta com APIs brasileiras.

## 📊 Cenário Atual - Agosto 2025

### PIX Automático - Status Operacional
- **Lançamento**: 16 de junho de 2025 (2 meses operacional)
- **Integração Direta**: Disponível via API PIX oficial do Banco Central
- **Open Finance**: Integração completa permitindo portabilidade de pagamentos
- **Tarifas**: Gratuito para pagadores, opcional para recebedores
- **Primeiro Implementador**: Banco do Brasil (maio 2025)

### Landscape de Pagamentos Brasileiro
- **PIX**: 46M+ transações/segundo na infraestrutura
- **Penetração Mobile**: 85%+ dos usuários acessam via smartphone
- **API First**: Todas as principais instituições oferecem APIs robustas
- **Micropagamentos**: Viabilizados com custos ~R$0,10 por transação

`★ Insight ─────────────────────────────────────`
O PIX Automático revoluciona pay-per-crawl no Brasil eliminando intermediários tradicionais (bandeiras/adquirentes) e permitindo integração direta com o Banco Central.
`─────────────────────────────────────────────────`

## 🏗️ Arquiteturas Técnicas por Ambiente

### 1. Hosting Compartilhado (70% dos casos brasileiros)

#### Limitações Técnicas
- Sem acesso root/sudo
- PHP/MySQL/cPanel padrão
- Dependência de .htaccess
- Rate limiting básico
- Sem controle de infraestrutura

#### Implementação .htaccess + PHP

```apache
# .htaccess - Detecção e bloqueio de crawlers IA
RewriteEngine On

# Log de crawlers para análise
RewriteCond %{HTTP_USER_AGENT} (GPTBot|ClaudeBot|ChatGPT-User|anthropic-ai|cohere-ai|Claude-Web|Applebot|AdsBot-Google|Bingbot|facebookexternalhit|twitterbot) [NC]
RewriteRule ^.*$ - [E=CRAWLER:1]

# Bloquear crawlers não pagos
RewriteCond %{HTTP_USER_AGENT} (GPTBot|ClaudeBot|ChatGPT-User|anthropic-ai|cohere-ai|Claude-Web) [NC]
RewriteCond %{QUERY_STRING} !paid_access=true
RewriteCond %{REQUEST_URI} !/pay-per-crawl/
RewriteRule ^(.*)$ /crawler-paywall.php?requested=$1 [L]

# Rate limiting por IP para crawlers
RewriteCond %{HTTP_USER_AGENT} (GPTBot|ClaudeBot|ChatGPT-User) [NC]
RewriteCond %{REQUEST_METHOD} GET
RewriteRule ^.*$ /rate-limit-check.php [L]

# Headers de segurança
Header always set X-Crawler-Policy "Payment-Required"
Header always set X-Content-Licensing "Commercial-Use-Requires-Payment"
```

#### Sistema PHP de Detecção e Cobrança

```php
<?php
// crawler-paywall.php - Sistema completo de paywall para crawlers
class CrawlerPaywallBrasil {
    
    private const AI_CRAWLERS = [
        'GPTBot' => ['company' => 'OpenAI', 'price' => 0.005],
        'ClaudeBot' => ['company' => 'Anthropic', 'price' => 0.008],
        'ChatGPT-User' => ['company' => 'OpenAI', 'price' => 0.005],
        'anthropic-ai' => ['company' => 'Anthropic', 'price' => 0.008],
        'cohere-ai' => ['company' => 'Cohere', 'price' => 0.004],
        'Claude-Web' => ['company' => 'Anthropic', 'price' => 0.008],
        'Applebot' => ['company' => 'Apple', 'price' => 0.012],
        'AdsBot-Google' => ['company' => 'Google', 'price' => 0.006]
    ];
    
    private const ALLOWED_CRAWLERS = [
        'Googlebot' => 'organic-search',
        'Bingbot' => 'organic-search',
        'facebookexternalhit' => 'social-sharing',
        'twitterbot' => 'social-sharing'
    ];
    
    private $db;
    private $userAgent;
    private $clientIP;
    private $requestedURL;
    
    public function __construct() {
        $this->db = new PDO("mysql:host=localhost;dbname=" . DB_NAME, DB_USER, DB_PASS);
        $this->userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $this->clientIP = $this->getRealIP();
        $this->requestedURL = $_GET['requested'] ?? '/';
        
        // Log da requisição
        $this->logCrawlerRequest();
    }
    
    private function getRealIP() {
        $headers = [
            'HTTP_CF_CONNECTING_IP',     // Cloudflare
            'HTTP_X_REAL_IP',           // Nginx
            'HTTP_X_FORWARDED_FOR',     // Proxy
            'REMOTE_ADDR'               // Padrão
        ];
        
        foreach ($headers as $header) {
            if (!empty($_SERVER[$header])) {
                $ips = explode(',', $_SERVER[$header]);
                return trim($ips[0]);
            }
        }
        
        return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    }
    
    public function detectCrawlerType() {
        // Verificar crawlers permitidos primeiro
        foreach (self::ALLOWED_CRAWLERS as $bot => $purpose) {
            if (stripos($this->userAgent, $bot) !== false) {
                return ['type' => 'allowed', 'bot' => $bot, 'purpose' => $purpose];
            }
        }
        
        // Verificar crawlers de IA (pagos)
        foreach (self::AI_CRAWLERS as $bot => $info) {
            if (stripos($this->userAgent, $bot) !== false) {
                return [
                    'type' => 'ai-crawler',
                    'bot' => $bot,
                    'company' => $info['company'],
                    'price' => $info['price']
                ];
            }
        }
        
        return ['type' => 'unknown', 'bot' => 'unidentified'];
    }
    
    public function checkPaymentStatus($crawlerInfo) {
        $stmt = $this->db->prepare("
            SELECT * FROM crawler_payments 
            WHERE ip_address = ? 
            AND crawler_type = ? 
            AND status = 'paid' 
            AND expires_at > NOW()
        ");
        
        $stmt->execute([$this->clientIP, $crawlerInfo['bot']]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    public function generatePaymentRequest($crawlerInfo) {
        $paymentId = uniqid('crawl_', true);
        $amount = $crawlerInfo['price'];
        $expiresAt = date('Y-m-d H:i:s', strtotime('+1 hour'));
        
        // Salvar requisição de pagamento
        $stmt = $this->db->prepare("
            INSERT INTO crawler_payment_requests 
            (payment_id, ip_address, crawler_type, amount, requested_url, expires_at, status) 
            VALUES (?, ?, ?, ?, ?, ?, 'pending')
        ");
        
        $stmt->execute([
            $paymentId, $this->clientIP, $crawlerInfo['bot'], 
            $amount, $this->requestedURL, $expiresAt
        ]);
        
        return [
            'payment_id' => $paymentId,
            'amount' => $amount,
            'currency' => 'BRL',
            'pix_payment_url' => $this->generatePixPayment($paymentId, $amount),
            'webhook_url' => '/webhook/pix-payment.php',
            'expires_at' => $expiresAt
        ];
    }
    
    private function generatePixPayment($paymentId, $amount) {
        // Integração com PIX Automático via Asaas (menores taxas)
        $asaasAPI = new AsaasAPI();
        
        return $asaasAPI->createPixCharge([
            'customer' => [
                'name' => 'AI Crawler Access',
                'email' => 'crawler@ai-company.com'
            ],
            'billingType' => 'PIX',
            'value' => $amount,
            'dueDate' => date('Y-m-d', strtotime('+1 hour')),
            'description' => "Acesso crawler {$paymentId}",
            'externalReference' => $paymentId
        ]);
    }
    
    public function rateLimitCheck($crawlerInfo) {
        $stmt = $this->db->prepare("
            SELECT COUNT(*) as request_count 
            FROM crawler_requests 
            WHERE ip_address = ? 
            AND crawler_type = ? 
            AND created_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)
        ");
        
        $stmt->execute([$this->clientIP, $crawlerInfo['bot']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Limite: 10 requisições por hora para crawlers não pagos
        return $result['request_count'] < 10;
    }
    
    public function generateResponse($crawlerInfo, $paymentRequired = true) {
        if ($paymentRequired) {
            http_response_code(402); // Payment Required
            header('Content-Type: application/json; charset=utf-8');
            
            $paymentInfo = $this->generatePaymentRequest($crawlerInfo);
            
            return json_encode([
                'error' => 'Payment Required',
                'message' => 'Este conteúdo requer pagamento para acesso via IA crawler',
                'crawler_detected' => $crawlerInfo['bot'],
                'company' => $crawlerInfo['company'],
                'price_brl' => $crawlerInfo['price'],
                'payment' => $paymentInfo,
                'compliance' => [
                    'lgpd' => 'Conforme Lei Geral de Proteção de Dados',
                    'copyright' => 'Lei 9610/98 - Direitos Autorais protegidos',
                    'terms_url' => '/termos-uso-crawlers.html'
                ],
                'contact' => [
                    'email' => 'crawler-licensing@' . $_SERVER['HTTP_HOST'],
                    'phone' => '+55-11-99999-9999'
                ]
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        }
        
        // Crawler autorizado - permitir acesso
        header('X-Crawler-Access: Granted');
        header('X-Content-License: Fair-Use');
        return null; // Continuar para conteúdo original
    }
    
    private function logCrawlerRequest() {
        $stmt = $this->db->prepare("
            INSERT INTO crawler_requests 
            (ip_address, user_agent, requested_url, created_at) 
            VALUES (?, ?, ?, NOW())
        ");
        
        $stmt->execute([$this->clientIP, $this->userAgent, $this->requestedURL]);
    }
}

// Execução principal
try {
    $paywall = new CrawlerPaywallBrasil();
    $crawlerInfo = $paywall->detectCrawlerType();
    
    if ($crawlerInfo['type'] === 'allowed') {
        // Crawler permitido - continuar
        header("Location: /{$_GET['requested']}");
        exit;
    }
    
    if ($crawlerInfo['type'] === 'ai-crawler') {
        // Verificar se já pagou
        $paymentStatus = $paywall->checkPaymentStatus($crawlerInfo);
        
        if ($paymentStatus) {
            // Pagamento válido - permitir acesso
            header("Location: /{$_GET['requested']}?paid_access=true&token=" . $paymentStatus['access_token']);
            exit;
        }
        
        // Verificar rate limiting
        if (!$paywall->rateLimitCheck($crawlerInfo)) {
            http_response_code(429); // Too Many Requests
            echo json_encode(['error' => 'Rate limit exceeded. Payment required for unlimited access.']);
            exit;
        }
        
        // Requer pagamento
        echo $paywall->generateResponse($crawlerInfo, true);
        exit;
    }
    
    // Crawler desconhecido - permitir por enquanto, mas loggar
    header("Location: /{$_GET['requested']}");
    
} catch (Exception $e) {
    error_log("Paywall Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
?>
```

### 2. VPS/Servidor Dedicado (Nginx + Node.js)

#### Middleware Express.js Completo

```javascript
// crawler-monetization-middleware.js
const express = require('express');
const mysql = require('mysql2/promise');
const axios = require('axios');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');
const NodeCache = require('node-cache');

class BrazilianCrawlerMonetization {
    constructor(config) {
        this.config = {
            database: config.database,
            asaasApiKey: config.asaasApiKey,
            pixKey: config.pixKey,
            basePrice: config.basePrice || 0.005,
            rateLimitWindow: config.rateLimitWindow || 3600000, // 1 hora
            rateLimitMax: config.rateLimitMax || 10,
            ...config
        };
        
        this.cache = new NodeCache({ stdTTL: 3600 }); // Cache 1 hora
        this.db = mysql.createPool(this.config.database);
        
        this.crawlerDatabase = {
            'GPTBot': { company: 'OpenAI', multiplier: 1.0 },
            'ClaudeBot': { company: 'Anthropic', multiplier: 1.6 },
            'ChatGPT-User': { company: 'OpenAI', multiplier: 1.0 },
            'anthropic-ai': { company: 'Anthropic', multiplier: 1.6 },
            'cohere-ai': { company: 'Cohere', multiplier: 0.8 },
            'Claude-Web': { company: 'Anthropic', multiplier: 1.6 },
            'Applebot': { company: 'Apple', multiplier: 2.4 },
            'AdsBot-Google': { company: 'Google', multiplier: 1.2 }
        };
        
        this.allowedCrawlers = new Set([
            'Googlebot', 'Bingbot', 'facebookexternalhit', 
            'twitterbot', 'WhatsApp', 'Slackbot'
        ]);
    }
    
    createMiddleware() {
        return async (req, res, next) => {
            try {
                const userAgent = req.headers['user-agent'] || '';
                const clientIP = this.extractRealIP(req);
                
                // Log da requisição
                await this.logRequest(clientIP, userAgent, req.path);
                
                // Detectar tipo de crawler
                const crawlerInfo = this.detectCrawler(userAgent);
                
                if (crawlerInfo.type === 'allowed') {
                    req.crawlerInfo = crawlerInfo;
                    return next();
                }
                
                if (crawlerInfo.type === 'ai-crawler') {
                    // Verificar se já pagou
                    const paymentStatus = await this.checkPaymentStatus(clientIP, crawlerInfo.bot);
                    
                    if (paymentStatus && paymentStatus.expires_at > new Date()) {
                        req.crawlerInfo = { ...crawlerInfo, paid: true };
                        return next();
                    }
                    
                    // Rate limiting para crawlers não pagos
                    if (!await this.checkRateLimit(clientIP, crawlerInfo.bot)) {
                        return res.status(429).json({
                            error: 'Rate limit exceeded',
                            message: 'Limite de requisições excedido. Pagamento necessário para acesso ilimitado.',
                            upgrade_to_paid: await this.generatePaymentInfo(clientIP, crawlerInfo, req.path)
                        });
                    }
                    
                    // Retornar paywall
                    const paymentInfo = await this.generatePaymentInfo(clientIP, crawlerInfo, req.path);
                    
                    return res.status(402).json({
                        error: 'Payment Required',
                        message: 'Este conteúdo requer pagamento para treinamento de IA',
                        crawler_detected: crawlerInfo.bot,
                        company: crawlerInfo.company,
                        price_brl: crawlerInfo.price,
                        payment: paymentInfo,
                        compliance: {
                            lgpd: 'Conforme LGPD - Lei 13.709/2018',
                            copyright: 'Lei 9610/98 - Direitos Autorais',
                            contact: `crawler-licensing@${req.headers.host}`
                        }
                    });
                }
                
                // Crawler desconhecido - permitir mas monitorar
                req.crawlerInfo = crawlerInfo;
                next();
                
            } catch (error) {
                console.error('Crawler middleware error:', error);
                next(); // Falhar silenciosamente para não quebrar o site
            }
        };
    }
    
    extractRealIP(req) {
        return req.headers['cf-connecting-ip'] ||
               req.headers['x-real-ip'] ||
               req.headers['x-forwarded-for']?.split(',')[0] ||
               req.connection.remoteAddress ||
               req.socket.remoteAddress ||
               'unknown';
    }
    
    detectCrawler(userAgent) {
        // Crawlers permitidos primeiro
        for (let bot of this.allowedCrawlers) {
            if (userAgent.toLowerCase().includes(bot.toLowerCase())) {
                return { type: 'allowed', bot, purpose: 'organic-search' };
            }
        }
        
        // Crawlers de IA
        for (let [bot, info] of Object.entries(this.crawlerDatabase)) {
            if (userAgent.toLowerCase().includes(bot.toLowerCase())) {
                return {
                    type: 'ai-crawler',
                    bot,
                    company: info.company,
                    price: this.config.basePrice * info.multiplier
                };
            }
        }
        
        return { type: 'unknown', bot: 'unidentified', userAgent };
    }
    
    async checkPaymentStatus(ip, crawlerType) {
        const cacheKey = `payment:${ip}:${crawlerType}`;
        let status = this.cache.get(cacheKey);
        
        if (!status) {
            const [rows] = await this.db.execute(
                `SELECT * FROM crawler_payments 
                 WHERE ip_address = ? AND crawler_type = ? 
                 AND status = 'confirmed' AND expires_at > NOW()
                 ORDER BY expires_at DESC LIMIT 1`,
                [ip, crawlerType]
            );
            
            status = rows[0] || null;
            if (status) {
                this.cache.set(cacheKey, status, 1800); // Cache por 30min
            }
        }
        
        return status;
    }
    
    async checkRateLimit(ip, crawlerType) {
        const [rows] = await this.db.execute(
            `SELECT COUNT(*) as count FROM crawler_requests 
             WHERE ip_address = ? AND crawler_type = ? 
             AND created_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)`,
            [ip, crawlerType]
        );
        
        return rows[0].count < this.config.rateLimitMax;
    }
    
    async generatePaymentInfo(ip, crawlerInfo, requestedPath) {
        const paymentId = crypto.randomUUID();
        const amount = crawlerInfo.price;
        
        // Salvar requisição de pagamento
        await this.db.execute(
            `INSERT INTO crawler_payment_requests 
             (payment_id, ip_address, crawler_type, amount, requested_url, created_at, expires_at, status)
             VALUES (?, ?, ?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR), 'pending')`,
            [paymentId, ip, crawlerInfo.bot, amount, requestedPath]
        );
        
        // Gerar cobrança PIX via Asaas
        const pixCharge = await this.createAsaasPixCharge(paymentId, amount, crawlerInfo);
        
        return {
            payment_id: paymentId,
            amount: amount,
            currency: 'BRL',
            pix: {
                qr_code: pixCharge.qrCode.payload,
                qr_code_image: pixCharge.qrCode.encodedImage,
                expires_at: new Date(Date.now() + 3600000).toISOString()
            },
            webhook_url: `/webhook/payment-confirmation/${paymentId}`,
            status_check_url: `/api/payment-status/${paymentId}`
        };
    }
    
    async createAsaasPixCharge(paymentId, amount, crawlerInfo) {
        const response = await axios.post('https://api.asaas.com/v3/payments', {
            customer: await this.getOrCreateAsaasCustomer(crawlerInfo.company),
            billingType: 'PIX',
            value: amount,
            dueDate: new Date(Date.now() + 3600000).toISOString().split('T')[0],
            description: `Acesso crawler ${crawlerInfo.bot} - ${paymentId}`,
            externalReference: paymentId
        }, {
            headers: {
                'access_token': this.config.asaasApiKey,
                'Content-Type': 'application/json'
            }
        });
        
        return response.data;
    }
    
    async getOrCreateAsaasCustomer(companyName) {
        // Implementar lógica para criar/recuperar cliente Asaas
        return {
            name: `${companyName} AI Crawler`,
            email: `crawler@${companyName.toLowerCase()}.com`,
            mobilePhone: '+5511999999999'
        };
    }
    
    async logRequest(ip, userAgent, path) {
        await this.db.execute(
            `INSERT INTO crawler_requests (ip_address, user_agent, requested_url, created_at)
             VALUES (?, ?, ?, NOW())`,
            [ip, userAgent, path]
        );
    }
    
    // Webhook para confirmação de pagamento
    createWebhookHandler() {
        return async (req, res) => {
            try {
                const { paymentId } = req.params;
                const webhookData = req.body;
                
                if (webhookData.event === 'PAYMENT_CONFIRMED') {
                    await this.confirmPayment(paymentId, webhookData);
                    
                    res.status(200).json({ status: 'processed' });
                } else {
                    res.status(200).json({ status: 'ignored' });
                }
            } catch (error) {
                console.error('Webhook error:', error);
                res.status(500).json({ error: 'Internal server error' });
            }
        };
    }
    
    async confirmPayment(paymentId, webhookData) {
        // Atualizar status do pagamento
        await this.db.execute(
            `UPDATE crawler_payment_requests 
             SET status = 'confirmed', confirmed_at = NOW()
             WHERE payment_id = ?`,
            [paymentId]
        );
        
        // Criar entrada de acesso autorizado
        const [requestData] = await this.db.execute(
            `SELECT * FROM crawler_payment_requests WHERE payment_id = ?`,
            [paymentId]
        );
        
        if (requestData.length > 0) {
            const request = requestData[0];
            
            await this.db.execute(
                `INSERT INTO crawler_payments 
                 (payment_id, ip_address, crawler_type, amount, status, created_at, expires_at)
                 VALUES (?, ?, ?, ?, 'confirmed', NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR))`,
                [paymentId, request.ip_address, request.crawler_type, request.amount]
            );
            
            // Limpar cache
            this.cache.del(`payment:${request.ip_address}:${request.crawler_type}`);
        }
    }
}

// Uso no Express.js
module.exports = BrazilianCrawlerMonetization;

// Exemplo de uso:
/*
const CrawlerMonetization = require('./crawler-monetization-middleware');

const monetization = new CrawlerMonetization({
    database: {
        host: 'localhost',
        user: 'crawler_db_user',
        password: 'password',
        database: 'crawler_monetization'
    },
    asaasApiKey: process.env.ASAAS_API_KEY,
    pixKey: process.env.PIX_KEY,
    basePrice: 0.01 // R$ 0,01 por requisição base
});

app.use('/blog', monetization.createMiddleware());
app.post('/webhook/payment-confirmation/:paymentId', monetization.createWebhookHandler());
*/
```

`★ Insight ─────────────────────────────────────`
A arquitetura Node.js permite rate limiting granular e cache inteligente, reduzindo consultas ao banco em 80%+ e processamento de webhooks PIX em tempo real.
`─────────────────────────────────────────────────`

### 3. Configuração Nginx (Servidor/VPS)

```nginx
# /etc/nginx/sites-available/pay-per-crawl-blog
upstream crawler_monetization_backend {
    server 127.0.0.1:3000;
    keepalive 32;
}

# Rate limiting zones específicas por tipo de crawler
limit_req_zone $http_user_agent zone=ai_crawlers:10m rate=10r/h;
limit_req_zone $http_user_agent zone=openai_bots:10m rate=5r/h;
limit_req_zone $http_user_agent zone=anthropic_bots:10m rate=8r/h;

# Mapeamento de crawlers conhecidos
map $http_user_agent $crawler_type {
    default "unknown";
    ~*GPTBot "openai";
    ~*ClaudeBot "anthropic";
    ~*ChatGPT-User "openai";
    ~*anthropic-ai "anthropic";
    ~*cohere-ai "cohere";
    ~*Claude-Web "anthropic";
    ~*Applebot "apple";
    ~*AdsBot-Google "google-ads";
    ~*Googlebot "google-search";
    ~*Bingbot "bing-search";
    ~*facebookexternalhit "facebook";
    ~*twitterbot "twitter";
}

# Detecção de crawlers que requerem pagamento
map $http_user_agent $requires_payment {
    default 0;
    ~*(GPTBot|ClaudeBot|ChatGPT-User|anthropic-ai|cohere-ai|Claude-Web|Applebot|AdsBot-Google) 1;
}

# Crawlers permitidos gratuitamente
map $http_user_agent $allowed_crawler {
    default 0;
    ~*(Googlebot|Bingbot|facebookexternalhit|twitterbot|WhatsApp|Slackbot) 1;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name blog-exemplo.com.br;

    # SSL/TLS configuration
    ssl_certificate /etc/letsencrypt/live/blog-exemplo.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/blog-exemplo.com.br/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;

    # Logs específicos para crawlers
    access_log /var/log/nginx/crawler-access.log combined;
    error_log /var/log/nginx/crawler-error.log warn;

    # Headers de segurança
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy strict-origin-when-cross-origin;
    
    # Headers específicos para crawlers
    add_header X-Crawler-Policy "AI-Training-Requires-Payment" always;
    add_header X-Content-License "Commercial-Use-Licensed" always;
    add_header X-Payment-Required "PIX-Available" always;

    # Localização raiz para conteúdo estático
    root /var/www/blog-exemplo.com.br/public;
    index index.html index.php;

    # Rate limiting para crawlers de IA
    location / {
        # Aplicar rate limiting baseado no tipo de crawler
        if ($crawler_type = "openai") {
            limit_req zone=openai_bots burst=3 nodelay;
        }
        
        if ($crawler_type = "anthropic") {
            limit_req zone=anthropic_bots burst=5 nodelay;
        }
        
        # Se requer pagamento e não é crawler permitido
        if ($requires_payment = 1) {
            set $block_crawler "${requires_payment}${allowed_crawler}";
        }
        
        if ($block_crawler = "10") {
            proxy_pass http://crawler_monetization_backend;
            break;
        }
        
        # Servir conteúdo normal para crawlers permitidos e usuários
        try_files $uri $uri/ @backend;
    }
    
    # API endpoints para sistema de pagamento
    location /api/crawler/ {
        proxy_pass http://crawler_monetization_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Headers específicos para API
        proxy_set_header X-Crawler-Type $crawler_type;
        proxy_set_header X-Requires-Payment $requires_payment;
    }
    
    # Webhook do PIX
    location /webhook/ {
        proxy_pass http://crawler_monetization_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Limitar apenas IPs dos processadores de pagamento
        allow 18.230.46.0/26;    # Asaas
        allow 54.233.204.0/24;   # Mercado Pago
        allow 177.54.144.0/20;   # PagSeguro
        deny all;
    }
    
    # Backend para conteúdo dinâmico
    location @backend {
        proxy_pass http://crawler_monetization_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Cache para conteúdo dinâmico
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
    }
    
    # Arquivos estáticos
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Mesmo controle de acesso para mídia
        if ($requires_payment = 1) {
            set $block_media "${requires_payment}${allowed_crawler}";
        }
        
        if ($block_media = "10") {
            return 402 '{"error":"Payment Required","message":"Media access requires payment","type":"static-content"}';
        }
    }
    
    # Monitoramento e status
    location /status {
        access_log off;
        return 200 "OK";
        add_header Content-Type text/plain;
    }
    
    # Logs em tempo real para monitoramento
    location /crawler-stats {
        access_log /var/log/nginx/crawler-realtime.log crawler_format;
        
        # Apenas administradores
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
        
        proxy_pass http://crawler_monetization_backend/admin/stats;
    }
}

# Formato de log customizado para análise de crawlers
log_format crawler_format '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         'crawler_type="$crawler_type" '
                         'requires_payment="$requires_payment" '
                         'rt=$request_time '
                         'uct="$upstream_connect_time" '
                         'uht="$upstream_header_time" '
                         'urt="$upstream_response_time"';

# Redirecionamento HTTP para HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name blog-exemplo.com.br;
    
    return 301 https://$server_name$request_uri;
}
```

## 🏦 Integração com Processadores de Pagamento Brasileiros

### Comparativo de Soluções (Agosto 2025)

| Processador | Taxa PIX | API Quality | PIX Automático | Micropagamentos | Score |
|-------------|----------|-------------|----------------|-----------------|-------|
| **Asaas** | 0,89% | ⭐⭐⭐⭐⭐ | ✅ | ✅ | 95/100 |
| **Mercado Pago** | 0,99% | ⭐⭐⭐⭐ | ✅ | ❌ | 85/100 |
| **Stone/Pagar.me** | 1,19% | ⭐⭐⭐⭐ | ✅ | ✅ | 88/100 |
| **PagSeguro** | 1,39% | ⭐⭐⭐ | ✅ | ❌ | 78/100 |
| **Efi Bank** | 0,79% | ⭐⭐⭐⭐⭐ | ✅ | ✅ | 92/100 |

`★ Insight ─────────────────────────────────────`
Asaas e Efi Bank lideram em 2025 com APIs robustas e menores taxas, essencial para viabilidade econômica de micropagamentos pay-per-crawl.
`─────────────────────────────────────────────────`

### Integração Asaas (Recomendada)

```javascript
// asaas-pix-integration.js
class AsaasPIXIntegration {
    constructor(apiKey, environment = 'production') {
        this.apiKey = apiKey;
        this.baseURL = environment === 'production' 
            ? 'https://api.asaas.com/v3' 
            : 'https://sandbox.asaas.com/api/v3';
        
        this.headers = {
            'access_token': this.apiKey,
            'Content-Type': 'application/json',
            'User-Agent': 'PayPerCrawl-Brazil/1.0'
        };
    }
    
    async createCustomer(crawlerCompany) {
        const customerData = {
            name: `${crawlerCompany} AI Crawler`,
            email: `crawler@${crawlerCompany.toLowerCase().replace(/\s/g, '')}.com`,
            phone: '+5511999999999',
            mobilePhone: '+5511999999999',
            cpfCnpj: this.generateCNPJ(crawlerCompany), // Para empresas de IA
            postalCode: '01310-100',
            address: 'Av. Paulista',
            addressNumber: '1000',
            complement: 'AI Training Division',
            province: 'Bela Vista',
            city: 'São Paulo',
            state: 'SP',
            country: 'Brasil',
            observations: `Cliente automatizado para crawling de IA - ${crawlerCompany}`
        };
        
        const response = await fetch(`${this.baseURL}/customers`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify(customerData)
        });
        
        return await response.json();
    }
    
    async createPixCharge(customerId, amount, crawlerInfo, requestPath) {
        const chargeData = {
            customer: customerId,
            billingType: 'PIX',
            value: parseFloat(amount).toFixed(2),
            dueDate: new Date(Date.now() + 3600000).toISOString().split('T')[0], // 1 hora
            description: `Acesso crawler ${crawlerInfo.bot} - ${requestPath}`,
            externalReference: crawlerInfo.paymentId,
            postalService: false,
            discount: {
                value: 0,
                dueDateLimitDays: 0
            },
            fine: {
                value: 0
            },
            interest: {
                value: 0
            },
            split: [], // Para marketplace no futuro
            callback: {
                successUrl: `https://${process.env.DOMAIN}/payment-success?payment=${crawlerInfo.paymentId}`,
                autoRedirect: false
            }
        };
        
        const response = await fetch(`${this.baseURL}/payments`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify(chargeData)
        });
        
        const result = await response.json();
        
        // Gerar QR Code PIX
        if (result.id) {
            const qrResponse = await fetch(`${this.baseURL}/payments/${result.id}/pixQrCode`, {
                headers: this.headers
            });
            
            const qrData = await qrResponse.json();
            result.pixQrCode = qrData;
        }
        
        return result;
    }
    
    async createPixAutomatic(customerId, amount, crawlerInfo, frequency = 'MONTHLY') {
        // PIX Automático para crawlers com alto volume
        const subscriptionData = {
            customer: customerId,
            billingType: 'PIX',
            nextDueDate: new Date(Date.now() + 86400000).toISOString().split('T')[0], // Amanhã
            value: parseFloat(amount).toFixed(2),
            cycle: frequency, // WEEKLY, MONTHLY, QUARTERLY, YEARLY
            description: `Assinatura crawler ${crawlerInfo.bot} - Acesso ilimitado`,
            endDate: null, // Indefinido
            maxPayments: null,
            externalReference: `subscription_${crawlerInfo.bot}_${customerId}`,
            split: [],
            callback: {
                successUrl: `https://${process.env.DOMAIN}/subscription-success`,
                autoRedirect: false
            }
        };
        
        const response = await fetch(`${this.baseURL}/subscriptions`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify(subscriptionData)
        });
        
        return await response.json();
    }
    
    async verifyPayment(paymentId) {
        const response = await fetch(`${this.baseURL}/payments/${paymentId}`, {
            headers: this.headers
        });
        
        return await response.json();
    }
    
    async handleWebhook(webhookData) {
        // Validar webhook signature se necessário
        const { event, payment } = webhookData;
        
        switch (event) {
            case 'PAYMENT_RECEIVED':
                return await this.processPaymentConfirmed(payment);
                
            case 'PAYMENT_OVERDUE':
                return await this.processPaymentOverdue(payment);
                
            case 'PAYMENT_DELETED':
                return await this.processPaymentCancelled(payment);
                
            default:
                console.log(`Unhandled webhook event: ${event}`);
                return { status: 'ignored' };
        }
    }
    
    async processPaymentConfirmed(payment) {
        // Atualizar banco de dados local
        const accessToken = this.generateAccessToken(payment.externalReference);
        
        // Salvar na base local
        await this.savePaymentConfirmation({
            paymentId: payment.externalReference,
            asaasPaymentId: payment.id,
            amount: payment.value,
            status: 'confirmed',
            accessToken: accessToken,
            expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 horas
        });
        
        return { 
            status: 'processed', 
            accessToken: accessToken,
            expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000)
        };
    }
    
    generateAccessToken(paymentId) {
        const crypto = require('crypto');
        const data = `${paymentId}:${Date.now()}:${process.env.SECRET_KEY}`;
        return crypto.createHash('sha256').update(data).digest('hex');
    }
    
    generateCNPJ(companyName) {
        // Gerar CNPJ fictício para empresas de IA (apenas para API)
        const hash = require('crypto').createHash('md5').update(companyName).digest('hex');
        const numbers = hash.replace(/[^0-9]/g, '').substring(0, 11);
        return numbers.padEnd(11, '0') + '0001';
    }
}

module.exports = AsaasPIXIntegration;
```

## 📊 Schema de Banco de Dados

```sql
-- Schema MySQL para sistema pay-per-crawl brasileiro
-- Criado para suportar PIX Automático e compliance LGPD

CREATE DATABASE crawler_monetization_br CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crawler_monetization_br;

-- Tabela de crawlers conhecidos e configurações
CREATE TABLE crawler_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    bot_name VARCHAR(100) NOT NULL UNIQUE,
    company_name VARCHAR(200) NOT NULL,
    base_price_brl DECIMAL(10,4) NOT NULL DEFAULT 0.0050,
    price_multiplier DECIMAL(4,2) NOT NULL DEFAULT 1.00,
    is_allowed_free BOOLEAN NOT NULL DEFAULT FALSE,
    rate_limit_per_hour INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_bot_name (bot_name),
    INDEX idx_company (company_name)
);

-- Popular crawlers conhecidos
INSERT INTO crawler_types (bot_name, company_name, base_price_brl, price_multiplier, is_allowed_free, rate_limit_per_hour) VALUES
('GPTBot', 'OpenAI', 0.0050, 1.00, FALSE, 10),
('ClaudeBot', 'Anthropic', 0.0080, 1.60, FALSE, 8),
('ChatGPT-User', 'OpenAI', 0.0050, 1.00, FALSE, 10),
('anthropic-ai', 'Anthropic', 0.0080, 1.60, FALSE, 8),
('cohere-ai', 'Cohere', 0.0040, 0.80, FALSE, 12),
('Claude-Web', 'Anthropic', 0.0080, 1.60, FALSE, 8),
('Applebot', 'Apple', 0.0120, 2.40, FALSE, 5),
('AdsBot-Google', 'Google', 0.0060, 1.20, FALSE, 15),
('Googlebot', 'Google', 0.0000, 0.00, TRUE, 1000),
('Bingbot', 'Microsoft', 0.0000, 0.00, TRUE, 1000),
('facebookexternalhit', 'Meta', 0.0000, 0.00, TRUE, 100),
('twitterbot', 'Twitter/X', 0.0000, 0.00, TRUE, 100);

-- Log de requisições de crawlers (LGPD compliance)
CREATE TABLE crawler_requests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NOT NULL,
    crawler_type VARCHAR(100) NULL,
    requested_url TEXT NOT NULL,
    response_code INT NULL,
    processing_time_ms INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_ip_time (ip_address, created_at),
    INDEX idx_crawler_time (crawler_type, created_at),
    INDEX idx_created_at (created_at),
    
    -- LGPD: Auto-purge after 2 years
    CONSTRAINT chk_lgpd_retention CHECK (created_at > DATE_SUB(NOW(), INTERVAL 2 YEAR))
);

-- Particionamento por mês para performance
ALTER TABLE crawler_requests PARTITION BY RANGE (YEAR(created_at)*100 + MONTH(created_at)) (
    PARTITION p202508 VALUES LESS THAN (202509),
    PARTITION p202509 VALUES LESS THAN (202510),
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Requisições de pagamento
CREATE TABLE crawler_payment_requests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    payment_id VARCHAR(100) NOT NULL UNIQUE,
    ip_address VARCHAR(45) NOT NULL,
    crawler_type VARCHAR(100) NOT NULL,
    amount_brl DECIMAL(10,4) NOT NULL,
    requested_url TEXT NOT NULL,
    processor VARCHAR(50) NOT NULL DEFAULT 'asaas',
    processor_payment_id VARCHAR(200) NULL,
    pix_qr_code TEXT NULL,
    pix_qr_code_image LONGTEXT NULL,
    status ENUM('pending', 'processing', 'confirmed', 'expired', 'cancelled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    confirmed_at TIMESTAMP NULL,
    
    INDEX idx_payment_id (payment_id),
    INDEX idx_ip_crawler (ip_address, crawler_type),
    INDEX idx_status_expires (status, expires_at),
    INDEX idx_processor_id (processor_payment_id),
    
    FOREIGN KEY (crawler_type) REFERENCES crawler_types(bot_name) ON UPDATE CASCADE
);

-- Pagamentos confirmados e tokens de acesso
CREATE TABLE crawler_payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    payment_request_id BIGINT NOT NULL,
    payment_id VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    crawler_type VARCHAR(100) NOT NULL,
    amount_brl DECIMAL(10,4) NOT NULL,
    access_token VARCHAR(255) NOT NULL UNIQUE,
    processor VARCHAR(50) NOT NULL,
    processor_payment_id VARCHAR(200) NOT NULL,
    processor_transaction_id VARCHAR(200) NULL,
    status ENUM('active', 'expired', 'revoked') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    last_used_at TIMESTAMP NULL,
    usage_count INT NOT NULL DEFAULT 0,
    
    INDEX idx_access_token (access_token),
    INDEX idx_ip_crawler_status (ip_address, crawler_type, status),
    INDEX idx_expires_status (expires_at, status),
    INDEX idx_payment_id (payment_id),
    
    FOREIGN KEY (payment_request_id) REFERENCES crawler_payment_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (crawler_type) REFERENCES crawler_types(bot_name) ON UPDATE CASCADE
);

-- Assinaturas PIX Automático
CREATE TABLE crawler_subscriptions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    subscription_id VARCHAR(100) NOT NULL UNIQUE,
    ip_address VARCHAR(45) NOT NULL,
    crawler_type VARCHAR(100) NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    monthly_amount_brl DECIMAL(10,2) NOT NULL,
    processor VARCHAR(50) NOT NULL DEFAULT 'asaas',
    processor_subscription_id VARCHAR(200) NOT NULL,
    status ENUM('active', 'paused', 'cancelled', 'expired') NOT NULL DEFAULT 'active',
    cycle ENUM('WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL DEFAULT 'MONTHLY',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    next_billing_date DATE NOT NULL,
    last_payment_date DATE NULL,
    cancelled_at TIMESTAMP NULL,
    
    INDEX idx_subscription_id (subscription_id),
    INDEX idx_ip_crawler (ip_address, crawler_type),
    INDEX idx_status_billing (status, next_billing_date),
    INDEX idx_processor_sub (processor_subscription_id),
    
    FOREIGN KEY (crawler_type) REFERENCES crawler_types(bot_name) ON UPDATE CASCADE
);

-- Estatísticas agregadas por crawler
CREATE TABLE crawler_stats_daily (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    date_recorded DATE NOT NULL,
    crawler_type VARCHAR(100) NOT NULL,
    total_requests INT NOT NULL DEFAULT 0,
    paid_requests INT NOT NULL DEFAULT 0,
    free_requests INT NOT NULL DEFAULT 0,
    blocked_requests INT NOT NULL DEFAULT 0,
    total_revenue_brl DECIMAL(12,4) NOT NULL DEFAULT 0.00,
    unique_ips INT NOT NULL DEFAULT 0,
    avg_processing_time_ms DECIMAL(8,2) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_date_crawler (date_recorded, crawler_type),
    INDEX idx_date_revenue (date_recorded, total_revenue_brl),
    INDEX idx_crawler_date (crawler_type, date_recorded),
    
    FOREIGN KEY (crawler_type) REFERENCES crawler_types(bot_name) ON UPDATE CASCADE
);

-- Compliance LGPD - Log de consentimentos e políticas
CREATE TABLE lgpd_compliance (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    ip_address VARCHAR(45) NOT NULL,
    crawler_company VARCHAR(200) NOT NULL,
    consent_type ENUM('data_processing', 'payment_processing', 'usage_analytics') NOT NULL,
    consent_given BOOLEAN NOT NULL,
    consent_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    privacy_policy_version VARCHAR(20) NOT NULL DEFAULT '2025.1',
    withdrawal_timestamp TIMESTAMP NULL,
    legal_basis ENUM('consent', 'legitimate_interest', 'contract', 'legal_obligation') NOT NULL DEFAULT 'consent',
    
    INDEX idx_ip_company (ip_address, crawler_company),
    INDEX idx_consent_time (consent_timestamp),
    INDEX idx_withdrawal (withdrawal_timestamp)
);

-- Configurações do sistema
CREATE TABLE system_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT NOT NULL,
    config_type ENUM('string', 'number', 'boolean', 'json') NOT NULL DEFAULT 'string',
    description TEXT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_config_key (config_key)
);

-- Configurações iniciais
INSERT INTO system_config (config_key, config_value, config_type, description) VALUES
('base_price_per_request', '0.0050', 'number', 'Preço base em BRL por requisição'),
('rate_limit_window_hours', '1', 'number', 'Janela de rate limiting em horas'),
('free_requests_per_window', '10', 'number', 'Requisições gratuitas por janela'),
('payment_expiry_hours', '1', 'number', 'Horas para expirar pagamento PIX'),
('access_token_validity_hours', '24', 'number', 'Validade do token de acesso em horas'),
('lgpd_data_retention_years', '2', 'number', 'Retenção de dados LGPD em anos'),
('pix_automatic_enabled', 'true', 'boolean', 'PIX Automático habilitado'),
('asaas_api_key', '', 'string', 'Chave API Asaas (criptografada)'),
('pix_key', '', 'string', 'Chave PIX para recebimentos'),
('webhook_secret', '', 'string', 'Secret para validação de webhooks');

-- Triggers para atualizações automáticas de estatísticas
DELIMITER //

CREATE TRIGGER update_daily_stats_after_request
AFTER INSERT ON crawler_requests
FOR EACH ROW
BEGIN
    INSERT INTO crawler_stats_daily (date_recorded, crawler_type, total_requests, unique_ips)
    VALUES (DATE(NEW.created_at), COALESCE(NEW.crawler_type, 'unknown'), 1, 1)
    ON DUPLICATE KEY UPDATE
        total_requests = total_requests + 1,
        unique_ips = (
            SELECT COUNT(DISTINCT ip_address)
            FROM crawler_requests
            WHERE DATE(created_at) = DATE(NEW.created_at)
            AND crawler_type = NEW.crawler_type
        );
END//

CREATE TRIGGER update_stats_after_payment
AFTER UPDATE ON crawler_payments
FOR EACH ROW
BEGIN
    IF NEW.status = 'active' AND OLD.status != 'active' THEN
        UPDATE crawler_stats_daily
        SET paid_requests = paid_requests + 1,
            total_revenue_brl = total_revenue_brl + NEW.amount_brl
        WHERE date_recorded = DATE(NEW.created_at)
        AND crawler_type = NEW.crawler_type;
    END IF;
END//

-- Procedure para limpeza automática LGPD
CREATE PROCEDURE CleanupLGPDData()
BEGIN
    DECLARE retention_years INT DEFAULT 2;
    
    SELECT config_value INTO retention_years
    FROM system_config
    WHERE config_key = 'lgpd_data_retention_years';
    
    -- Limpar requests antigos
    DELETE FROM crawler_requests
    WHERE created_at < DATE_SUB(NOW(), INTERVAL retention_years YEAR);
    
    -- Limpar compliance logs antigos
    DELETE FROM lgpd_compliance
    WHERE consent_timestamp < DATE_SUB(NOW(), INTERVAL retention_years YEAR)
    AND withdrawal_timestamp IS NOT NULL;
    
    -- Log da limpeza
    INSERT INTO system_config (config_key, config_value, description)
    VALUES (CONCAT('last_cleanup_', DATE_FORMAT(NOW(), '%Y%m')), NOW(), 'Última limpeza LGPD')
    ON DUPLICATE KEY UPDATE config_value = NOW();
END//

DELIMITER ;

-- Event scheduler para limpeza automática mensal
CREATE EVENT IF NOT EXISTS monthly_lgpd_cleanup
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-09-01 02:00:00'
DO CALL CleanupLGPDData();

-- Views para relatórios e dashboards
CREATE VIEW v_crawler_revenue_summary AS
SELECT 
    crawler_type,
    company_name,
    DATE(created_at) as date,
    COUNT(*) as total_payments,
    SUM(amount_brl) as daily_revenue,
    AVG(amount_brl) as avg_payment_value,
    MIN(created_at) as first_payment,
    MAX(created_at) as last_payment
FROM crawler_payments cp
JOIN crawler_types ct ON cp.crawler_type = ct.bot_name
WHERE cp.status = 'active'
GROUP BY crawler_type, company_name, DATE(created_at)
ORDER BY date DESC, daily_revenue DESC;

CREATE VIEW v_active_subscriptions AS
SELECT 
    s.subscription_id,
    s.ip_address,
    s.crawler_type,
    ct.company_name,
    s.monthly_amount_brl,
    s.status,
    s.next_billing_date,
    DATEDIFF(s.next_billing_date, CURDATE()) as days_to_next_billing,
    s.created_at
FROM crawler_subscriptions s
JOIN crawler_types ct ON s.crawler_type = ct.bot_name
WHERE s.status = 'active'
ORDER BY s.next_billing_date ASC;

-- Índices adicionais para performance
CREATE INDEX idx_requests_hourly ON crawler_requests (DATE(created_at), HOUR(created_at), crawler_type);
CREATE INDEX idx_payments_monthly ON crawler_payments (DATE_FORMAT(created_at, '%Y-%m'), status);
CREATE INDEX idx_revenue_analysis ON crawler_payments (crawler_type, created_at, amount_brl);

-- Permissões para usuário da aplicação
CREATE USER IF NOT EXISTS 'crawler_app'@'localhost' IDENTIFIED BY 'secure_password_2025!';
GRANT SELECT, INSERT, UPDATE ON crawler_monetization_br.* TO 'crawler_app'@'localhost';
GRANT DELETE ON crawler_monetization_br.crawler_requests TO 'crawler_app'@'localhost';
FLUSH PRIVILEGES;

-- Comentários para documentação
ALTER TABLE crawler_types COMMENT = 'Configuração de crawlers conhecidos e preços';
ALTER TABLE crawler_requests COMMENT = 'Log de todas as requisições - auto-purge LGPD 2 anos';
ALTER TABLE crawler_payments COMMENT = 'Pagamentos confirmados com tokens de acesso';
ALTER TABLE crawler_subscriptions COMMENT = 'Assinaturas PIX Automático para alto volume';
ALTER TABLE lgpd_compliance COMMENT = 'Logs de compliance LGPD - consentimentos e retiradas';
```

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Verificar status atual do PIX Autom\u00e1tico e integra\u00e7\u00f5es diretas em agosto 2025", "status": "completed", "activeForm": "Verificando status atual do PIX Autom\u00e1tico e integra\u00e7\u00f5es diretas em agosto 2025"}, {"content": "Pesquisar institui\u00e7\u00f5es de pagamento brasileiras que suportam pay-per-crawl", "status": "completed", "activeForm": "Pesquisando institui\u00e7\u00f5es de pagamento brasileiras que suportam pay-per-crawl"}, {"content": "Criar documenta\u00e7\u00e3o t\u00e9cnica detalhada em arquivo .md", "status": "completed", "activeForm": "Criando documenta\u00e7\u00e3o t\u00e9cnica detalhada em arquivo .md"}, {"content": "Expandir exemplos de c\u00f3digo para cada cen\u00e1rio de hospedagem", "status": "completed", "activeForm": "Expandindo exemplos de c\u00f3digo para cada cen\u00e1rio de hospedagem"}]