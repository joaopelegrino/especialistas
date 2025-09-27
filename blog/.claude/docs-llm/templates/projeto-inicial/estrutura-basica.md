# 🏗️ Estrutura Básica de Projeto - Template PT-BR

**Load**: Quando implementação inicial necessária | **Tokens**: ~100 linhas

---

## 📁 **Estrutura Claude Code - Universal para Qualquer Stack**

### **Pasta .claude/ - Configuração Claude Code Otimizado**
```
qualquer-projeto/                     # Funciona com: React, WordPress, Laravel, Django, etc.
├── .claude/                          # Sistema Claude Code Otimizado (Universal)
│   ├── configuracoes.json            # Config principal PT-BR
│   ├── ganchos/                      # Hooks de observabilidade
│   │   ├── pre_execucao.py          # Validação entrada
│   │   ├── pos_execucao.py          # Logging saída
│   │   └── monitoramento.py         # Métricas tempo real
│   ├── EVOLUCAO.md                   # Log de expansões
│   ├── docs-llm/                     # Sistema de Documentação LLM
│   │   ├── core/                     # Fundamentos do sistema
│   │   │   ├── identidade.md         # Identidade e personalidade
│   │   │   ├── principios.md         # Princípios fundamentais
│   │   │   └── workflow-basico.md    # Fluxo de trabalho básico
│   │   ├── capabilities/             # Capacidades avançadas
│   │   │   ├── multi-agent/          # Orquestração multi-agente
│   │   │   │   └── orchestration.md  # Estratégias de orquestração
│   │   │   ├── observability/        # Observabilidade e métricas
│   │   │   └── september-2025/       # Recursos mais recentes
│   │   │       ├── chrome-devtools-mcp.md    # Chrome DevTools MCP
│   │   │       ├── context-engineering.md    # Engenharia de contexto
│   │   │       └── enterprise-features.md    # Funcionalidades enterprise
│   │   ├── domains/                  # Domínios específicos
│   │   │   ├── enterprise/           # Soluções empresariais
│   │   │   ├── healthcare/           # Soluções de saúde
│   │   │   │   └── compliance.md     # Conformidade regulatória
│   │   │   └── web-development/      # Desenvolvimento web
│   │   ├── reference/                # Referências rápidas
│   │   │   └── commands-quick-ref.md # Comandos essenciais
│   │   └── templates/                # Templates e estruturas
│   │       ├── mcp-servers/          # Servidores MCP
│   │       │   └── chrome-devtools-setup.md # Setup Chrome DevTools
│   │       ├── projeto-inicial/      # Templates de projeto
│   │       │   └── estrutura-basica.md # Esta estrutura
│   │       └── workflows/            # Fluxos de trabalho
│   ├── prompt-central.md             # Prompt central do sistema
│   └── README.md                     # Documentação principal
└── [estrutura do seu projeto...]     # WordPress, React, Laravel, Django, etc.
```

> **💡 Nota**: A estrutura `.claude/` é **universal** e funciona com qualquer stack tecnológico:
> - **WordPress**: `wp-content/themes/`, `wp-content/plugins/`
> - **React/Next.js**: `src/`, `components/`, `pages/`
> - **Laravel**: `app/`, `resources/`, `routes/`
> - **Django**: `apps/`, `templates/`, `static/`
> - **E qualquer outro framework**

---

## ⚙️ **Arquivo de Configuração Principal**

### **`.claude/configuracoes.json`**
```json
{
  "projeto": {
    "nome": "meu-projeto",
    "versao": "1.0.0",
    "tipo": "web-fullstack",
    "linguagens": ["javascript", "typescript", "python"],
    "frameworks": ["react", "node", "express"]
  },
  "ambiente": {
    "desenvolvimento": {
      "url_frontend": "http://localhost:3000",
      "url_backend": "http://localhost:8000",
      "banco_dados": "postgresql://localhost:5432/projeto_dev"
    },
    "producao": {
      "url_frontend": "https://meuapp.com",
      "url_backend": "https://api.meuapp.com"
    }
  },
  "observabilidade": {
    "ganchos_habilitados": true,
    "metricas_tempo_real": true,
    "logs_detalhados": true
  },
  "seguranca": {
    "autenticacao": "jwt",
    "criptografia": "bcrypt",
    "cors_habilitado": true,
    "rate_limiting": true
  },
  "desenvolvimento": {
    "hot_reload": true,
    "debug_mode": true,
    "auto_tests": true
  }
}
```

---

## 🔧 **Scripts de Automação PT-BR**

### **`scripts/desenvolvimento/inicializar.sh`**
```bash
#!/bin/bash
# inicializar.sh - Setup inicial do projeto em português

echo "🚀 Inicializando projeto Claude Code..."

# Verificar dependências
verificar_dependencias() {
    echo "🔍 Verificando dependências..."
    command -v node >/dev/null 2>&1 || { echo "❌ Node.js não encontrado"; exit 1; }
    command -v python >/dev/null 2>&1 || { echo "❌ Python não encontrado"; exit 1; }
    echo "✅ Dependências verificadas"
}

# Instalar dependências frontend
instalar_frontend() {
    echo "📦 Instalando dependências frontend..."
    cd src/frontend
    npm install
    echo "✅ Frontend configurado"
}

# Instalar dependências backend
instalar_backend() {
    echo "📦 Instalando dependências backend..."
    cd ../../src/backend
    pip install -r requirements.txt
    echo "✅ Backend configurado"
}

# Configurar banco de dados
configurar_banco() {
    echo "🗄️ Configurando banco de dados..."
    # Criar database se não existir
    createdb projeto_dev 2>/dev/null || echo "Database já existe"
    echo "✅ Banco configurado"
}

# Executar setup
verificar_dependencias
instalar_frontend
instalar_backend
configurar_banco

echo "🎉 Projeto inicializado com sucesso!"
echo "🔧 Execute 'npm run dev' para iniciar desenvolvimento"
```

### **`scripts/desenvolvimento/executar.sh`**
```bash
#!/bin/bash
# executar.sh - Executar ambiente de desenvolvimento

echo "🏃 Iniciando ambiente de desenvolvimento..."

# Função para executar em background com logs
executar_com_logs() {
    local servico=$1
    local comando=$2
    local log_file=$3

    echo "🔄 Iniciando $servico..."
    $comando > $log_file 2>&1 &
    local pid=$!
    echo "$pid" > "${servico}.pid"
    echo "✅ $servico iniciado (PID: $pid)"
}

# Criar diretório para logs
mkdir -p logs

# Iniciar backend
cd src/backend
executar_com_logs "backend" "python app.py" "../../logs/backend.log"

# Iniciar frontend
cd ../frontend
executar_com_logs "frontend" "npm start" "../../logs/frontend.log"

# Iniciar monitoramento
cd ../../
executar_com_logs "monitoramento" "python .claude/ganchos/monitoramento.py" "logs/monitoramento.log"

echo "🎉 Ambiente de desenvolvimento ativo!"
echo "📱 Frontend: http://localhost:3000"
echo "⚡ Backend: http://localhost:8000"
echo "📊 Logs em: ./logs/"
echo "🛑 Para parar: ./scripts/desenvolvimento/parar.sh"
```

---

## 🧪 **Template de Testes PT-BR**

### **`testes/unitarios/exemplo_teste.py`**
```python
# exemplo_teste.py - Template de teste unitário PT-BR
import unittest
from src.backend.servicos.usuario_servico import UsuarioServico

class TesteUsuarioServico(unittest.TestCase):
    """Testes para o serviço de usuário."""

    def setUp(self):
        """Configuração inicial para cada teste."""
        self.usuario_servico = UsuarioServico()
        self.dados_usuario_valido = {
            'nome': 'João Silva',
            'email': 'joao@exemplo.com',
            'senha': 'senhaSegura123'
        }

    def teste_criar_usuario_valido(self):
        """Teste criação de usuário com dados válidos."""
        resultado = self.usuario_servico.criar_usuario(self.dados_usuario_valido)

        self.assertTrue(resultado['sucesso'])
        self.assertIsNotNone(resultado['usuario_id'])
        self.assertEqual(resultado['usuario']['email'], 'joao@exemplo.com')

    def teste_criar_usuario_email_invalido(self):
        """Teste criação de usuário com email inválido."""
        dados_invalidos = self.dados_usuario_valido.copy()
        dados_invalidos['email'] = 'email_invalido'

        resultado = self.usuario_servico.criar_usuario(dados_invalidos)

        self.assertFalse(resultado['sucesso'])
        self.assertIn('email', resultado['erros'])

    def teste_validar_senha_forte(self):
        """Teste validação de senha forte."""
        senhas_teste = [
            ('123', False),          # Muito simples
            ('senhafraca', False),   # Sem números/símbolos
            ('SenhaForte123!', True) # Senha adequada
        ]

        for senha, esperado in senhas_teste:
            with self.subTest(senha=senha):
                resultado = self.usuario_servico.validar_senha(senha)
                self.assertEqual(resultado, esperado)

    def tearDown(self):
        """Limpeza após cada teste."""
        # Limpar dados de teste se necessário
        pass

if __name__ == '__main__':
    unittest.main()
```

---

## 📋 **Package.json Template PT-BR**

### **`src/frontend/package.json`**
```json
{
  "name": "meu-projeto-frontend",
  "version": "1.0.0",
  "description": "Frontend do projeto em React",
  "main": "src/index.js",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "test:coverage": "npm test -- --coverage",
    "analyze": "npm run build && npx webpack-bundle-analyzer build/static/js/*.js"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",
    "axios": "^1.3.0",
    "@mui/material": "^5.11.0",
    "@emotion/react": "^11.10.0",
    "@emotion/styled": "^11.10.0"
  },
  "devDependencies": {
    "react-scripts": "5.0.1",
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.0",
    "@testing-library/user-event": "^14.4.0",
    "eslint": "^8.34.0",
    "prettier": "^2.8.0"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
```

---

## 🔒 **Template de Segurança**

### **Configuração Básica de Segurança**
```python
# src/backend/config/seguranca.py
import os
from datetime import timedelta

class ConfiguracaoSeguranca:
    """Configurações de segurança do sistema."""

    # JWT Configuration
    SECRET_KEY = os.environ.get('SECRET_KEY', 'chave-secreta-desenvolvimento')
    JWT_EXPIRATION_DELTA = timedelta(hours=24)
    JWT_REFRESH_EXPIRATION_DELTA = timedelta(days=7)

    # Password Security
    BCRYPT_LOG_ROUNDS = 12
    PASSWORD_MIN_LENGTH = 8
    PASSWORD_REQUIRE_SPECIAL_CHARS = True

    # Rate Limiting
    RATE_LIMIT_ENABLED = True
    RATE_LIMIT_DEFAULT = "100 per hour"
    RATE_LIMIT_LOGIN = "5 per minute"

    # CORS Configuration
    CORS_ORIGINS = [
        "http://localhost:3000",  # Frontend dev
        "https://meuapp.com"      # Production
    ]

    # Security Headers
    SECURITY_HEADERS = {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains'
    }

    # Data Protection (LGPD Compliance)
    DATA_RETENTION_DAYS = 365
    PERSONAL_DATA_ENCRYPTION = True
    AUDIT_LOG_ENABLED = True
```

---

**🏗️ Este template fornece estrutura completa em português-BR com segurança, observabilidade, e automação integradas para qualquer tipo de projeto.**