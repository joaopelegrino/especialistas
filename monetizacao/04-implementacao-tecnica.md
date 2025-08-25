# ⚙️ Guia de Implementação Técnica

## 🚀 Quick Start - 15 Minutos para Produção

### Opção 1: Cloudflare (Mais Rápido)

```bash
# 1. Instalar Wrangler CLI
npm install -g wrangler

# 2. Criar Worker
wrangler init pay-per-crawl-worker

# 3. Deploy do código abaixo
wrangler deploy
```

```javascript
// worker.js - Implementação mínima funcional
export default {
  async fetch(request, env) {
    const botScore = request.cf?.botManagement?.score || 0;
    
    // É um bot?
    if (botScore > 30) {
      const userAgent = request.headers.get('User-Agent');
      const isKnownBot = /GPTBot|ClaudeBot|ChatGPT/.test(userAgent);
      
      if (isKnownBot) {
        // Retornar 402 Payment Required
        return new Response(JSON.stringify({
          error: 'payment_required',
          price: 0.01,
          currency: 'USD',
          payment_url: 'https://pay.example.com/bot-payment'
        }), {
          status: 402,
          headers: { 'Content-Type': 'application/json' }
        });
      }
    }
    
    // Continuar para origin
    return fetch(request);
  }
};
```

### Opção 2: Node.js com Express

```bash
# 1. Instalar dependências
npm init -y
npm install express express-rate-limit redis ioredis
npm install @botwall/middleware  # Fictício, use seu próprio

# 2. Criar servidor
touch server.js
```

```javascript
// server.js - Servidor Express completo
const express = require('express');
const rateLimit = require('express-rate-limit');
const Redis = require('ioredis');

const app = express();
const redis = new Redis();

// Detecção de bots
const botDetector = (req) => {
  const ua = req.headers['user-agent'] || '';
  const knownBots = {
    'GPTBot': { price: 0.02, verified: false },
    'ClaudeBot': { price: 0.015, verified: false },
    'ChatGPT-User': { price: 0.01, verified: true }
  };
  
  for (const [bot, config] of Object.entries(knownBots)) {
    if (ua.includes(bot)) {
      return { isBot: true, name: bot, ...config };
    }
  }
  return { isBot: false };
};

// Middleware de pay-per-crawl
const payPerCrawlMiddleware = async (req, res, next) => {
  const bot = botDetector(req);
  
  if (bot.isBot) {
    // Verificar se já pagou (cache Redis)
    const paymentKey = `payment:${bot.name}:${req.ip}:${Date.now() / 3600000 | 0}`;
    const paid = await redis.get(paymentKey);
    
    if (!paid) {
      return res.status(402).json({
        error: 'Payment Required',
        bot: bot.name,
        price: bot.price,
        currency: 'USD',
        payment_methods: ['stripe', 'credits'],
        instructions: 'Include Payment-Token header after payment'
      });
    }
  }
  
  next();
};

// Rate limiting
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minuto
  max: 100, // 100 requests por minuto
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => !botDetector(req).isBot
});

// Aplicar middlewares
app.use(limiter);
app.use(payPerCrawlMiddleware);

// Rota de exemplo
app.get('/api/content/:id', async (req, res) => {
  // Seu conteúdo aqui
  res.json({
    id: req.params.id,
    content: 'Premium content here',
    timestamp: new Date()
  });
});

// Webhook de pagamento
app.post('/webhook/payment', express.json(), async (req, res) => {
  const { bot_name, ip, amount, token } = req.body;
  
  // Validar pagamento com processor
  if (validatePayment(token)) {
    // Marcar como pago no Redis (1 hora)
    const paymentKey = `payment:${bot_name}:${ip}:${Date.now() / 3600000 | 0}`;
    await redis.setex(paymentKey, 3600, amount);
    
    res.json({ success: true });
  } else {
    res.status(400).json({ error: 'Invalid payment' });
  }
});

app.listen(3000, () => {
  console.log('Pay-per-crawl server running on port 3000');
});
```

## 🏭 Implementação Completa com BotWall

### Arquitetura do Sistema

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Crawler   │────▶│   BotWall   │────▶│   Origin    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                    │                    │
       │                    ▼                    │
       │            ┌─────────────┐             │
       │            │   Database  │             │
       │            └─────────────┘             │
       │                    │                    │
       ▼                    ▼                    ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Payment   │     │   Analytics │     │    Logs     │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Instalação e Configuração

```bash
# Clone o repositório
git clone https://github.com/yourusername/botwall-implementation
cd botwall-implementation

# Instalar dependências
npm install

# Configurar ambiente
cp .env.example .env
# Editar .env com suas credenciais

# Inicializar banco de dados
npm run db:migrate
npm run db:seed

# Iniciar servidor
npm run start
```

### Estrutura do Projeto

```
botwall-implementation/
├── src/
│   ├── middleware/
│   │   ├── auth.js           # Autenticação de bots
│   │   ├── payment.js        # Processamento de pagamento
│   │   └── rateLimit.js      # Rate limiting
│   ├── services/
│   │   ├── botDetection.js   # ML para detecção
│   │   ├── pricing.js        # Engine de preços
│   │   └── analytics.js      # Coleta de métricas
│   ├── database/
│   │   ├── models/           # Modelos Sequelize
│   │   ├── migrations/       # Migrações
│   │   └── seeds/            # Dados iniciais
│   └── routes/
│       ├── content.js        # Rotas de conteúdo
│       ├── payment.js        # Webhooks de pagamento
│       └── admin.js          # Dashboard admin
├── tests/
├── config/
└── package.json
```

## 🔐 Autenticação Criptográfica

### Implementação Ed25519

```javascript
// crypto-auth.js
const crypto = require('crypto');
const fs = require('fs').promises;

class CryptoAuth {
  constructor() {
    this.trustedKeys = new Map();
    this.loadTrustedKeys();
  }
  
  async loadTrustedKeys() {
    // Carregar chaves públicas conhecidas
    const keys = {
      'GPTBot': 'https://openai.com/.well-known/bot-auth.json',
      'ClaudeBot': 'https://anthropic.com/.well-known/bot-auth.json'
    };
    
    for (const [bot, url] of Object.entries(keys)) {
      try {
        const response = await fetch(url);
        const data = await response.json();
        this.trustedKeys.set(bot, data.public_key);
      } catch (err) {
        console.error(`Failed to load key for ${bot}:`, err);
      }
    }
  }
  
  verifySignature(request) {
    const signature = request.headers['signature'];
    const signatureInput = request.headers['signature-input'];
    
    if (!signature || !signatureInput) {
      return { valid: false, reason: 'Missing signature headers' };
    }
    
    // Parse signature input
    const parsed = this.parseSignatureInput(signatureInput);
    
    // Verificar timestamp (prevenir replay)
    const now = Math.floor(Date.now() / 1000);
    if (Math.abs(now - parsed.created) > 300) { // 5 minutos
      return { valid: false, reason: 'Timestamp out of range' };
    }
    
    // Construir string para verificação
    const signatureBase = this.buildSignatureBase(request, parsed.fields);
    
    // Verificar com chave pública
    const botName = this.identifyBot(request.headers['user-agent']);
    const publicKey = this.trustedKeys.get(botName);
    
    if (!publicKey) {
      return { valid: false, reason: 'Unknown bot' };
    }
    
    const verify = crypto.createVerify('Ed25519');
    verify.update(signatureBase);
    
    const isValid = verify.verify(
      publicKey, 
      Buffer.from(signature, 'base64')
    );
    
    return { 
      valid: isValid, 
      bot: botName,
      timestamp: parsed.created 
    };
  }
  
  buildSignatureBase(request, fields) {
    const components = [];
    
    for (const field of fields) {
      switch(field) {
        case '@method':
          components.push(`"@method": ${request.method}`);
          break;
        case '@target-uri':
          components.push(`"@target-uri": ${request.url}`);
          break;
        case 'date':
          components.push(`"date": ${request.headers.date}`);
          break;
        default:
          if (request.headers[field]) {
            components.push(`"${field}": ${request.headers[field]}`);
          }
      }
    }
    
    return components.join('\n');
  }
}

module.exports = CryptoAuth;
```

## 💳 Integração de Pagamentos

### Stripe - Usage-Based Billing

```javascript
// stripe-integration.js
const Stripe = require('stripe');
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

class StripePaymentProcessor {
  async createCustomer(botInfo) {
    const customer = await stripe.customers.create({
      email: `${botInfo.name}@bot.ai`,
      metadata: {
        bot_name: botInfo.name,
        bot_company: botInfo.company
      }
    });
    
    // Criar subscription com metered billing
    const subscription = await stripe.subscriptions.create({
      customer: customer.id,
      items: [{
        price: process.env.STRIPE_METERED_PRICE_ID, // Price com usage_type: 'metered'
      }],
      expand: ['latest_invoice.payment_intent']
    });
    
    return { customer, subscription };
  }
  
  async recordUsage(customerId, quantity) {
    const subscriptions = await stripe.subscriptions.list({
      customer: customerId,
      limit: 1
    });
    
    if (subscriptions.data.length === 0) {
      throw new Error('No subscription found');
    }
    
    const subscription = subscriptions.data[0];
    const subscriptionItem = subscription.items.data[0];
    
    // Registrar uso
    const usageRecord = await stripe.subscriptionItems.createUsageRecord(
      subscriptionItem.id,
      {
        quantity: quantity,
        timestamp: Math.floor(Date.now() / 1000),
        action: 'increment' // ou 'set' para valor absoluto
      }
    );
    
    return usageRecord;
  }
  
  // Webhook handler
  async handleWebhook(event) {
    switch(event.type) {
      case 'invoice.payment_succeeded':
        await this.handlePaymentSuccess(event.data.object);
        break;
      
      case 'invoice.payment_failed':
        await this.handlePaymentFailure(event.data.object);
        break;
      
      case 'customer.subscription.deleted':
        await this.handleSubscriptionCanceled(event.data.object);
        break;
    }
  }
  
  async handlePaymentSuccess(invoice) {
    // Atualizar créditos do bot
    const customerId = invoice.customer;
    const amount = invoice.amount_paid / 100; // Centavos para dólares
    
    await this.addCredits(customerId, amount);
  }
}
```

### Lightning Network - Micropagamentos

```javascript
// lightning-payments.js
const lightning = require('lightning');
const lnService = require('ln-service');

class LightningPayments {
  constructor() {
    this.lnd = lnService.authenticatedLndGrpc({
      cert: process.env.LND_CERT,
      macaroon: process.env.LND_MACAROON,
      socket: process.env.LND_SOCKET
    }).lnd;
  }
  
  async createInvoice(amount, botId) {
    const invoice = await lnService.createInvoice({
      lnd: this.lnd,
      tokens: Math.ceil(amount * 100000000), // Converter para satoshis
      description: `Pay-per-crawl: ${botId}`,
      expires_at: new Date(Date.now() + 3600000).toISOString() // 1 hora
    });
    
    return {
      payment_request: invoice.request,
      payment_hash: invoice.id,
      amount_sats: invoice.tokens,
      expires_at: invoice.expires_at
    };
  }
  
  async verifyPayment(paymentHash) {
    try {
      const invoice = await lnService.getInvoice({
        lnd: this.lnd,
        id: paymentHash
      });
      
      return {
        paid: invoice.is_confirmed,
        amount: invoice.received,
        paid_at: invoice.confirmed_at
      };
    } catch (err) {
      return { paid: false };
    }
  }
  
  // Monitorar pagamentos em tempo real
  subscribeToInvoices() {
    const sub = lnService.subscribeToInvoices({ lnd: this.lnd });
    
    sub.on('invoice_updated', async (invoice) => {
      if (invoice.is_confirmed) {
        // Pagamento recebido!
        await this.handleLightningPayment(invoice);
      }
    });
  }
}
```

## 📊 Sistema de Créditos

### Schema do Banco de Dados

```sql
-- PostgreSQL schema
CREATE TABLE bot_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_name VARCHAR(100) UNIQUE NOT NULL,
    company VARCHAR(100),
    credits DECIMAL(10, 2) DEFAULT 0,
    tier VARCHAR(20) DEFAULT 'free',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_account_id UUID REFERENCES bot_accounts(id),
    type VARCHAR(20) NOT NULL, -- 'purchase', 'consumption', 'refund'
    amount DECIMAL(10, 2) NOT NULL,
    balance_after DECIMAL(10, 2) NOT NULL,
    description TEXT,
    reference_id VARCHAR(100), -- payment_id ou request_id
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE crawl_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_account_id UUID REFERENCES bot_accounts(id),
    url TEXT NOT NULL,
    method VARCHAR(10) DEFAULT 'GET',
    status_code INTEGER,
    credits_charged DECIMAL(10, 4),
    response_time_ms INTEGER,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_bot_accounts_bot_name ON bot_accounts(bot_name);
CREATE INDEX idx_credit_transactions_bot_account ON credit_transactions(bot_account_id);
CREATE INDEX idx_crawl_requests_created_at ON crawl_requests(created_at);
CREATE INDEX idx_crawl_requests_bot_account ON crawl_requests(bot_account_id);
```

### Gerenciamento de Créditos

```javascript
// credit-manager.js
class CreditManager {
  constructor(db) {
    this.db = db;
  }
  
  async consumeCredit(botId, amount, requestId) {
    const client = await this.db.connect();
    
    try {
      await client.query('BEGIN');
      
      // Verificar saldo com lock
      const { rows } = await client.query(
        'SELECT credits FROM bot_accounts WHERE id = $1 FOR UPDATE',
        [botId]
      );
      
      if (rows.length === 0) {
        throw new Error('Bot account not found');
      }
      
      const currentBalance = parseFloat(rows[0].credits);
      
      if (currentBalance < amount) {
        throw new Error('Insufficient credits');
      }
      
      // Deduzir créditos
      const newBalance = currentBalance - amount;
      
      await client.query(
        'UPDATE bot_accounts SET credits = $1, updated_at = NOW() WHERE id = $2',
        [newBalance, botId]
      );
      
      // Registrar transação
      await client.query(
        `INSERT INTO credit_transactions 
         (bot_account_id, type, amount, balance_after, reference_id, description)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [botId, 'consumption', -amount, newBalance, requestId, 'API request']
      );
      
      await client.query('COMMIT');
      
      return { success: true, new_balance: newBalance };
      
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
  
  async addCredits(botId, amount, paymentId) {
    // Similar ao consumeCredit, mas adiciona ao invés de subtrair
    const client = await this.db.connect();
    
    try {
      await client.query('BEGIN');
      
      const { rows } = await client.query(
        'SELECT credits FROM bot_accounts WHERE id = $1 FOR UPDATE',
        [botId]
      );
      
      const currentBalance = parseFloat(rows[0].credits);
      const newBalance = currentBalance + amount;
      
      await client.query(
        'UPDATE bot_accounts SET credits = $1, updated_at = NOW() WHERE id = $2',
        [newBalance, botId]
      );
      
      await client.query(
        `INSERT INTO credit_transactions 
         (bot_account_id, type, amount, balance_after, reference_id, description)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [botId, 'purchase', amount, newBalance, paymentId, 'Credit purchase']
      );
      
      await client.query('COMMIT');
      
      return { success: true, new_balance: newBalance };
      
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
}
```

## 🚦 Rate Limiting Avançado

### Token Bucket Algorithm

```javascript
// token-bucket.js
class TokenBucket {
  constructor(redis, capacity, refillRate) {
    this.redis = redis;
    this.capacity = capacity;
    this.refillRate = refillRate; // tokens por segundo
  }
  
  async consume(key, tokens = 1) {
    const now = Date.now();
    const bucketKey = `bucket:${key}`;
    
    // Lua script para operação atômica
    const luaScript = `
      local key = KEYS[1]
      local capacity = tonumber(ARGV[1])
      local refill_rate = tonumber(ARGV[2])
      local now = tonumber(ARGV[3])
      local tokens_requested = tonumber(ARGV[4])
      
      local bucket = redis.call('HMGET', key, 'tokens', 'last_refill')
      local current_tokens = tonumber(bucket[1]) or capacity
      local last_refill = tonumber(bucket[2]) or now
      
      -- Calculate tokens to add
      local time_passed = (now - last_refill) / 1000
      local tokens_to_add = time_passed * refill_rate
      current_tokens = math.min(capacity, current_tokens + tokens_to_add)
      
      if current_tokens >= tokens_requested then
        current_tokens = current_tokens - tokens_requested
        redis.call('HMSET', key, 'tokens', current_tokens, 'last_refill', now)
        redis.call('EXPIRE', key, 3600)
        return 1
      else
        redis.call('HMSET', key, 'tokens', current_tokens, 'last_refill', now)
        redis.call('EXPIRE', key, 3600)
        return 0
      end
    `;
    
    const result = await this.redis.eval(
      luaScript,
      1,
      bucketKey,
      this.capacity,
      this.refillRate,
      now,
      tokens
    );
    
    return result === 1;
  }
}

// Uso
const bucket = new TokenBucket(redis, 100, 10); // 100 tokens, 10/seg
const allowed = await bucket.consume('bot:GPTBot:123.456.789.0');
```

## 🔍 Detecção de Bots com ML

### Implementação com TensorFlow.js

```javascript
// ml-bot-detection.js
const tf = require('@tensorflow/tfjs-node');

class MLBotDetector {
  constructor() {
    this.model = null;
    this.loadModel();
  }
  
  async loadModel() {
    // Carregar modelo pré-treinado
    this.model = await tf.loadLayersModel('file://./models/bot-detector/model.json');
  }
  
  extractFeatures(request) {
    return {
      // Features de timing
      request_interval: this.getRequestInterval(request),
      time_of_day: new Date(request.timestamp).getHours(),
      
      // Features de comportamento
      pages_per_session: this.getPagesPerSession(request),
      avg_time_on_page: 0, // Bots geralmente = 0
      
      // Features de rede
      ip_reputation: this.getIPReputation(request.ip),
      asn_type: this.getASNType(request.ip),
      
      // Features de header
      has_referer: request.headers.referer ? 1 : 0,
      accepts_cookies: request.headers.cookie ? 1 : 0,
      user_agent_length: request.headers['user-agent']?.length || 0,
      
      // Features de navegação
      follows_robots_txt: this.checksRobotsTxt(request) ? 1 : 0,
      crawl_depth: this.getCrawlDepth(request),
      
      // TLS Fingerprint
      ja3_hash: this.getJA3Hash(request)
    };
  }
  
  async predict(request) {
    if (!this.model) {
      throw new Error('Model not loaded');
    }
    
    const features = this.extractFeatures(request);
    const input = tf.tensor2d([Object.values(features)]);
    
    const prediction = await this.model.predict(input);
    const score = await prediction.data();
    
    input.dispose();
    prediction.dispose();
    
    return {
      isBot: score[0] > 0.5,
      confidence: score[0],
      features
    };
  }
}
```

## 📈 Dashboard de Analytics

### API de Métricas

```javascript
// analytics-api.js
class AnalyticsAPI {
  async getMetrics(timeRange = '24h') {
    const query = `
      SELECT 
        COUNT(*) as total_requests,
        COUNT(DISTINCT bot_account_id) as unique_bots,
        SUM(credits_charged) as total_revenue,
        AVG(response_time_ms) as avg_response_time,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY response_time_ms) as p95_response_time,
        COUNT(CASE WHEN status_code = 402 THEN 1 END) as payment_required_count,
        COUNT(CASE WHEN status_code = 200 THEN 1 END) as success_count,
        DATE_TRUNC('hour', created_at) as hour
      FROM crawl_requests
      WHERE created_at >= NOW() - INTERVAL '${timeRange}'
      GROUP BY hour
      ORDER BY hour DESC
    `;
    
    const results = await this.db.query(query);
    
    return results.rows.map(row => ({
      timestamp: row.hour,
      requests: parseInt(row.total_requests),
      uniqueBots: parseInt(row.unique_bots),
      revenue: parseFloat(row.total_revenue),
      avgResponseTime: parseFloat(row.avg_response_time),
      p95ResponseTime: parseFloat(row.p95_response_time),
      paymentRequests: parseInt(row.payment_required_count),
      successfulRequests: parseInt(row.success_count),
      conversionRate: row.success_count / row.total_requests
    }));
  }
  
  async getBotBreakdown() {
    const query = `
      SELECT 
        ba.bot_name,
        ba.tier,
        ba.credits as current_balance,
        COUNT(cr.id) as request_count,
        SUM(cr.credits_charged) as total_spent,
        AVG(cr.response_time_ms) as avg_response_time,
        MAX(cr.created_at) as last_request
      FROM bot_accounts ba
      LEFT JOIN crawl_requests cr ON ba.id = cr.bot_account_id
      WHERE cr.created_at >= NOW() - INTERVAL '7 days'
      GROUP BY ba.id, ba.bot_name, ba.tier, ba.credits
      ORDER BY total_spent DESC
    `;
    
    return await this.db.query(query);
  }
}
```

### Frontend Dashboard (React)

```jsx
// Dashboard.jsx
import React, { useState, useEffect } from 'react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip } from 'recharts';

function Dashboard() {
  const [metrics, setMetrics] = useState([]);
  const [bots, setBots] = useState([]);
  
  useEffect(() => {
    fetchMetrics();
    fetchBots();
    const interval = setInterval(fetchMetrics, 5000); // Atualizar a cada 5s
    return () => clearInterval(interval);
  }, []);
  
  const fetchMetrics = async () => {
    const response = await fetch('/api/analytics/metrics');
    const data = await response.json();
    setMetrics(data);
  };
  
  const fetchBots = async () => {
    const response = await fetch('/api/analytics/bots');
    const data = await response.json();
    setBots(data);
  };
  
  const totalRevenue = metrics.reduce((sum, m) => sum + m.revenue, 0);
  const totalRequests = metrics.reduce((sum, m) => sum + m.requests, 0);
  
  return (
    <div className="dashboard">
      <div className="stats-grid">
        <div className="stat-card">
          <h3>Receita Total (24h)</h3>
          <p className="value">${totalRevenue.toFixed(2)}</p>
        </div>
        
        <div className="stat-card">
          <h3>Requisições</h3>
          <p className="value">{totalRequests.toLocaleString()}</p>
        </div>
        
        <div className="stat-card">
          <h3>Bots Ativos</h3>
          <p className="value">{bots.length}</p>
        </div>
        
        <div className="stat-card">
          <h3>RPR (Revenue per Request)</h3>
          <p className="value">${(totalRevenue / totalRequests).toFixed(4)}</p>
        </div>
      </div>
      
      <div className="charts">
        <div className="chart-container">
          <h3>Receita por Hora</h3>
          <LineChart width={600} height={300} data={metrics}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="timestamp" />
            <YAxis />
            <Tooltip />
            <Line type="monotone" dataKey="revenue" stroke="#8884d8" />
          </LineChart>
        </div>
        
        <div className="chart-container">
          <h3>Top Bots por Gasto</h3>
          <BarChart width={600} height={300} data={bots.slice(0, 10)}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="bot_name" />
            <YAxis />
            <Tooltip />
            <Bar dataKey="total_spent" fill="#82ca9d" />
          </BarChart>
        </div>
      </div>
    </div>
  );
}
```

## 🐳 Docker e Kubernetes

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://user:pass@postgres:5432/botwall
    depends_on:
      - redis
      - postgres
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes
  
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=botwall
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app

volumes:
  redis-data:
  postgres-data:
```

### Kubernetes Deployment

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: botwall
spec:
  replicas: 3
  selector:
    matchLabels:
      app: botwall
  template:
    metadata:
      labels:
        app: botwall
    spec:
      containers:
      - name: botwall
        image: your-registry/botwall:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: botwall-secrets
              key: redis-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: botwall-service
spec:
  selector:
    app: botwall
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: botwall-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: botwall
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🧪 Testes

### Testes de Integração

```javascript
// tests/integration/pay-per-crawl.test.js
const request = require('supertest');
const app = require('../../src/app');

describe('Pay-Per-Crawl Integration', () => {
  test('Should return 402 for known bot without payment', async () => {
    const response = await request(app)
      .get('/api/content/123')
      .set('User-Agent', 'GPTBot/1.0')
      .expect(402);
    
    expect(response.body).toHaveProperty('price');
    expect(response.body.price).toBe(0.02);
  });
  
  test('Should allow access after payment', async () => {
    // Simular pagamento
    await request(app)
      .post('/webhook/payment')
      .send({
        bot_name: 'GPTBot',
        ip: '127.0.0.1',
        amount: 0.02,
        token: 'valid-payment-token'
      })
      .expect(200);
    
    // Tentar acessar novamente
    const response = await request(app)
      .get('/api/content/123')
      .set('User-Agent', 'GPTBot/1.0')
      .set('X-Forwarded-For', '127.0.0.1')
      .expect(200);
    
    expect(response.body).toHaveProperty('content');
  });
});
```

## Próximos Passos

✅ **Implementação dominada?** 
Agora estude os [Aspectos Legais](./05-aspectos-legais.md) para garantir compliance.

---

**💡 Dica Final**: Comece simples com Cloudflare, colete dados por 30 dias, depois migre para solução própria se o volume justificar!