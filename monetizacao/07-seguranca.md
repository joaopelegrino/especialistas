# 🔒 Segurança e Proteção Anti-Fraude

## 🛡️ Arquitetura de Segurança: 99.9% de Proteção

### Defense in Depth - 7 Camadas de Proteção

```
┌─────────────────────────────────────────┐
│  1. DDoS Protection (Layer 3/4)        │ ← Volumetric attacks
├─────────────────────────────────────────┤
│  2. WAF Rules (Layer 7)                │ ← Application attacks
├─────────────────────────────────────────┤
│  3. Bot Management Score                │ ← ML detection
├─────────────────────────────────────────┤
│  4. Signature Verification              │ ← Cryptographic auth
├─────────────────────────────────────────┤
│  5. Payment Validation                  │ ← Business logic
├─────────────────────────────────────────┤
│  6. Rate Limiting                       │ ← Resource control
├─────────────────────────────────────────┤
│  7. Origin Shield                       │ ← Last defense
└─────────────────────────────────────────┘
```

## 🤖 Detecção de Bots com ML

### Algoritmo de Detecção Multi-Camada

```python
class AdvancedBotDetector:
    def __init__(self):
        self.models = {
            'isolation_forest': IsolationForest(contamination=0.001),
            'catboost': CatBoostClassifier(),
            'neural_network': self.load_nn_model(),
            'rule_based': RuleBasedDetector()
        }
        
    def detect(self, request):
        scores = {}
        
        # 1. Análise de Timing (30% peso)
        scores['timing'] = self.analyze_timing(request)
        
        # 2. Padrões Comportamentais (30% peso)
        scores['behavioral'] = self.analyze_behavior(request)
        
        # 3. Network Fingerprinting (20% peso)
        scores['network'] = self.analyze_network(request)
        
        # 4. ML Classification (20% peso)
        scores['ml'] = self.run_ml_models(request)
        
        # Weighted average
        final_score = (
            scores['timing'] * 0.3 +
            scores['behavioral'] * 0.3 +
            scores['network'] * 0.2 +
            scores['ml'] * 0.2
        )
        
        return {
            'is_bot': final_score > 0.7,
            'confidence': final_score,
            'breakdown': scores
        }
```

### Features de Detecção

| Categoria | Feature | Peso | Bot Indicator |
|-----------|---------|------|---------------|
| **Timing** | Request interval < 100ms | Alto | ✓ |
| **Timing** | Consistent intervals | Alto | ✓ |
| **Behavior** | No mouse movement | Médio | ✓ |
| **Behavior** | Linear navigation | Alto | ✓ |
| **Network** | Datacenter IP | Alto | ✓ |
| **Network** | No referrer | Médio | ✓ |
| **Headers** | Missing common headers | Alto | ✓ |
| **TLS** | Uncommon JA3 hash | Médio | ✓ |

## 🚦 Rate Limiting Avançado

### Implementação de Token Bucket

```javascript
class DistributedRateLimiter {
    constructor(redis) {
        this.redis = redis;
        this.configs = {
            'free': {
                capacity: 100,
                refillRate: 1,  // tokens/segundo
                cost: 1
            },
            'basic': {
                capacity: 1000,
                refillRate: 10,
                cost: 1
            },
            'premium': {
                capacity: 10000,
                refillRate: 100,
                cost: 0.5
            }
        };
    }
    
    async checkLimit(clientId, tier = 'free') {
        const config = this.configs[tier];
        const key = `ratelimit:${clientId}`;
        
        // Lua script para operação atômica
        const luaScript = `
            local key = KEYS[1]
            local capacity = tonumber(ARGV[1])
            local refill_rate = tonumber(ARGV[2])
            local cost = tonumber(ARGV[3])
            local now = tonumber(ARGV[4])
            
            local bucket = redis.call('HMGET', key, 'tokens', 'last_refill')
            local tokens = tonumber(bucket[1]) or capacity
            local last_refill = tonumber(bucket[2]) or now
            
            -- Calcular tokens a adicionar
            local elapsed = now - last_refill
            local tokens_to_add = elapsed * refill_rate / 1000
            tokens = math.min(capacity, tokens + tokens_to_add)
            
            if tokens >= cost then
                tokens = tokens - cost
                redis.call('HMSET', key, 
                    'tokens', tokens, 
                    'last_refill', now)
                redis.call('EXPIRE', key, 3600)
                return {1, tokens}
            else
                return {0, tokens}
            end
        `;
        
        const result = await this.redis.eval(
            luaScript, 1, key,
            config.capacity,
            config.refillRate,
            config.cost,
            Date.now()
        );
        
        return {
            allowed: result[0] === 1,
            remaining: result[1]
        };
    }
}
```

### Configurações por Tipo de Bot

| Bot Type | RPS Limit | Burst | Window | Action on Exceed |
|----------|-----------|-------|--------|------------------|
| **Verified Partner** | 1000 | 5000 | 1s | Log only |
| **Paid Crawler** | 100 | 500 | 1s | Throttle |
| **Free Tier** | 10 | 50 | 1s | 429 + Backoff |
| **Unknown** | 1 | 5 | 1s | 403 Block |
| **Suspicious** | 0.1 | 1 | 10s | IP Ban |

## 🔐 Prevenção de Fraudes

### Sistema de Detecção de Anomalias

```python
class FraudDetectionSystem:
    def __init__(self):
        self.isolation_forest = IsolationForest(
            n_estimators=100,
            contamination=0.001,
            random_state=42
        )
        self.threshold_rules = {
            'velocity': 1000,  # requests/minute
            'geographic_variance': 5,  # countries/hour
            'cost_spike': 10,  # x normal spending
            'pattern_deviation': 3  # standard deviations
        }
    
    def detect_anomalies(self, bot_activity):
        features = self.extract_features(bot_activity)
        
        # 1. Isolation Forest para anomalias
        anomaly_score = self.isolation_forest.decision_function([features])[0]
        
        # 2. Regras de threshold
        violations = []
        if features['requests_per_minute'] > self.threshold_rules['velocity']:
            violations.append('velocity_exceeded')
        
        if features['unique_countries'] > self.threshold_rules['geographic_variance']:
            violations.append('geographic_anomaly')
        
        # 3. Análise de padrões
        pattern_score = self.analyze_patterns(bot_activity)
        
        risk_level = self.calculate_risk_level(
            anomaly_score, violations, pattern_score
        )
        
        return {
            'risk_level': risk_level,  # low, medium, high, critical
            'anomaly_score': anomaly_score,
            'violations': violations,
            'recommended_action': self.get_recommended_action(risk_level)
        }
```

### Indicadores de Fraude

```
🔴 ALTA PROBABILIDADE DE FRAUDE
├── Múltiplas geolocalizações simultâneas
├── Padrão de requests impossível (>1000 req/s)
├── Tentativas de bypass de autenticação
├── Headers inconsistentes
└── Payment tokens reutilizados

🟡 MÉDIA PROBABILIDADE
├── Spike súbito de consumo (>10x normal)
├── Novos User-Agents frequentes
├── Requests de IPs suspeitos
└── Timing patterns artificiais

🟢 BAIXA PROBABILIDADE
├── Comportamento consistente
├── Autenticação válida
├── Pagamentos regulares
└── Padrões humanos detectados
```

## 🛑 Mitigação de Ataques DDoS

### Estratégias por Tipo de Ataque

| Tipo de Ataque | Mitigação | Eficácia |
|----------------|-----------|----------|
| **Volumetric (L3/4)** | Rate limiting + Blackholing | 99.9% |
| **Application (L7)** | WAF + Challenge pages | 99.5% |
| **Slowloris** | Connection limits + Timeouts | 98% |
| **Amplification** | IP reputation + Filtering | 99% |
| **Bot Swarm** | ML detection + Fingerprinting | 97% |

### Implementação de Proteção

```nginx
# Nginx configuration for DDoS protection
http {
    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=global:10m rate=10r/s;
    limit_req_zone $bot_identifier zone=bot:10m rate=100r/s;
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    
    # Connection limits
    limit_conn addr 10;
    
    server {
        # Apply rate limiting
        limit_req zone=global burst=20 nodelay;
        
        # Bot-specific limits
        if ($verified_bot = "1") {
            limit_req zone=bot burst=200 nodelay;
        }
        
        # Geo-blocking suspicious regions
        if ($geoip_country_code ~ "XX|YY|ZZ") {
            return 403;
        }
        
        # Challenge suspicious requests
        if ($suspicious_score > 80) {
            return 302 /challenge?return=$request_uri;
        }
    }
}
```

## 🔑 Segurança de JWT e Autenticação

### Best Practices Implementation

```javascript
class SecureJWTManager {
    constructor() {
        this.algorithm = 'RS256';  // Never use HS256
        this.keyRotationDays = 90;
        this.tokenExpiry = 900;  // 15 minutes
    }
    
    generateToken(payload) {
        const token = jwt.sign(
            {
                ...payload,
                jti: uuid.v4(),  // Unique ID
                iat: Math.floor(Date.now() / 1000),
                exp: Math.floor(Date.now() / 1000) + this.tokenExpiry,
                iss: 'pay-per-crawl-api',
                aud: payload.bot_id
            },
            this.privateKey,
            { algorithm: this.algorithm }
        );
        
        // Store token hash for revocation
        this.storeTokenHash(token);
        
        return token;
    }
    
    verifyToken(token) {
        try {
            // Check if revoked
            if (await this.isRevoked(token)) {
                throw new Error('Token revoked');
            }
            
            // Verify signature and claims
            const decoded = jwt.verify(token, this.publicKey, {
                algorithms: [this.algorithm],
                issuer: 'pay-per-crawl-api',
                maxAge: '15m'
            });
            
            // Additional checks
            if (!decoded.jti || !decoded.bot_id) {
                throw new Error('Missing required claims');
            }
            
            return decoded;
            
        } catch (error) {
            this.logSecurityEvent('jwt_verification_failed', { error });
            throw error;
        }
    }
}
```

## 📊 Monitoramento de Segurança

### Dashboard de Métricas

```javascript
const securityMetrics = {
    // Real-time metrics
    'blocked_requests': new Counter('security_blocked_total'),
    'fraud_attempts': new Counter('fraud_attempts_total'),
    'auth_failures': new Counter('auth_failures_total'),
    'ddos_mitigated': new Counter('ddos_mitigated_total'),
    
    // Histograms
    'detection_latency': new Histogram('detection_latency_ms'),
    'risk_scores': new Histogram('risk_score_distribution'),
    
    // Gauges
    'active_threats': new Gauge('active_threats_current'),
    'suspicious_ips': new Gauge('suspicious_ips_tracked')
};
```

### Alertas Críticos

```yaml
alerts:
  - name: HighFraudRate
    expr: rate(fraud_attempts_total[5m]) > 10
    severity: critical
    action: block_and_investigate
    
  - name: DDoSDetected
    expr: rate(requests_total[1m]) > 10000
    severity: critical
    action: enable_under_attack_mode
    
  - name: AuthenticationSpike
    expr: rate(auth_failures_total[5m]) > 100
    severity: warning
    action: investigate_source
    
  - name: UnusualSpending
    expr: increase(credits_consumed[1h]) > 1000
    severity: warning
    action: verify_with_customer
```

## 🎯 Resposta a Incidentes

### Playbook de Segurança

#### 1. Detecção de Fraude
```
1. Identificar padrão anômalo
2. Isolar conta/IP afetado
3. Analisar logs históricos
4. Determinar se é falso positivo
5. Se confirmado:
   - Bloquear imediatamente
   - Reverter transações
   - Notificar afetados
   - Documentar incidente
```

#### 2. Ataque DDoS
```
1. Ativar modo "Under Attack"
2. Aumentar rate limits
3. Habilitar CAPTCHA
4. Analisar origem do ataque
5. Implementar bloqueio geográfico se necessário
6. Escalar para CDN provider
7. Documentar e reportar
```

## 🔬 Testes de Segurança

### Checklist de Penetration Testing

- [ ] SQL Injection em parâmetros
- [ ] XSS em responses
- [ ] CSRF em endpoints críticos
- [ ] Rate limiting bypass
- [ ] JWT manipulation
- [ ] Payment validation bypass
- [ ] Bot detection evasion
- [ ] DDoS resistance
- [ ] API key leakage
- [ ] Privilege escalation

## Performance vs Segurança

### Trade-offs e Otimizações

| Medida de Segurança | Latência Adicional | Impacto Performance | Valor |
|---------------------|-------------------|---------------------|-------|
| **Bot Score ML** | +50μs | Mínimo | Alto |
| **Crypto Verification** | +200μs | Baixo | Crítico |
| **Rate Limiting** | +10μs | Mínimo | Alto |
| **WAF Rules** | +100μs | Baixo | Alto |
| **Full Request Logging** | +500μs | Médio | Médio |
| **Deep Packet Inspection** | +2ms | Alto | Situacional |

## Próximos Passos

Segurança implementada? Continue com:
- 🎯 [Guia de Decisão](./08-guia-decisao.md)
- 🔗 [Recursos e Referências](./09-recursos-referencias.md)

---

🔒 **Lembre-se**: Segurança não é um produto, é um processo contínuo!