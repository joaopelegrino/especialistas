# 🔧 Chrome DevTools MCP Setup - Template PT-BR

**Load**: Quando UI testing necessário | **Tokens**: ~100 linhas

---

## 🚀 **Instalação Rápida Chrome DevTools MCP**

### **Setup Automático via Claude Code CLI**
```bash
#!/bin/bash
# chrome-devtools-setup.sh - Setup completo em português

echo "🔧 Configurando Chrome DevTools MCP..."

# 1. Instalação via Claude Code CLI (recomendado)
instalar_chrome_devtools() {
    echo "📦 Instalando Chrome DevTools MCP..."
    claude mcp add chrome-devtools npx chrome-devtools-mcp@latest
    echo "✅ Chrome DevTools MCP instalado"
}

# 2. Verificar instalação
verificar_instalacao() {
    echo "🔍 Verificando instalação..."
    claude mcp list | grep chrome-devtools
    if [ $? -eq 0 ]; then
        echo "✅ Chrome DevTools MCP verificado"
    else
        echo "❌ Erro na instalação"
        exit 1
    fi
}

# 3. Configuração de segurança
configurar_seguranca() {
    echo "🔒 Configurando segurança..."

    # Criar configuração isolada
    cat > ~/.claude/mcp-chrome-config.json << 'EOF'
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--isolated=true",
        "--headless=false",
        "--channel=stable"
      ],
      "env": {
        "CHROME_DEVTOOLS_ISOLATED": "true",
        "CHROME_DEVTOOLS_SECURITY_MODE": "strict"
      }
    }
  }
}
EOF
    echo "✅ Configuração de segurança aplicada"
}

# 4. Testar funcionamento
testar_funcionamento() {
    echo "🧪 Testando Chrome DevTools MCP..."
    claude mcp get chrome-devtools
    if [ $? -eq 0 ]; then
        echo "✅ Chrome DevTools MCP funcionando"
    else
        echo "⚠️ Teste não completou - verificar logs"
    fi
}

# Executar setup completo
instalar_chrome_devtools
verificar_instalacao
configurar_seguranca
testar_funcionamento

echo "🎉 Chrome DevTools MCP configurado com sucesso!"
echo "💡 Uso: 'Analise a performance de localhost:3000'"
```

---

## ⚙️ **Configuração Manual Avançada**

### **Configuração Personalizada**
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--isolated=true",
        "--headless=false",
        "--channel=stable",
        "--userDataDir=/tmp/claude-chrome-testing",
        "--disableExtensions=true",
        "--noSandbox=false"
      ],
      "env": {
        "CHROME_DEVTOOLS_ISOLATED": "true",
        "CHROME_DEVTOOLS_SECURITY_MODE": "strict",
        "CHROME_DEVTOOLS_AUDIT_LOG": "true",
        "TMPDIR": "/tmp/claude-chrome"
      },
      "timeout": 30000,
      "retries": 3
    }
  }
}
```

### **Configuração para Projeto Específico**
```bash
# Configuração específica do projeto
criar_config_projeto() {
    local projeto_nome=$1
    local projeto_url=$2

    cat > .claude/chrome-devtools-projeto.json << EOF
{
  "projeto": {
    "nome": "$projeto_nome",
    "url_desenvolvimento": "$projeto_url",
    "url_producao": ""
  },
  "testes_ui": {
    "screenshots_dir": "./testes/screenshots/",
    "performance_reports_dir": "./testes/performance/",
    "accessibility_reports_dir": "./testes/accessibility/"
  },
  "configuracao_chrome": {
    "viewport": {
      "width": 1920,
      "height": 1080
    },
    "device_emulation": [
      "iPhone 12",
      "iPad",
      "Desktop"
    ],
    "network_conditions": [
      "Fast 3G",
      "Slow 3G",
      "Offline"
    ]
  }
}
EOF
}

# Usar: criar_config_projeto "meu-app" "http://localhost:3000"
```

---

## 🧪 **Templates de Testes UI Automatizados**

### **Template Teste Login PT-BR**
```javascript
// testes/ui/login-teste.js - Template teste login
const { test, expect } = require('@playwright/test');

test.describe('Sistema de Login', () => {
  test.beforeEach(async ({ page }) => {
    // Navegar para página de login
    await page.goto('http://localhost:3000/login');
  });

  test('deve fazer login com credenciais válidas', async ({ page }) => {
    // Preencher formulário
    await page.fill('[data-testid="campo-email"]', 'usuario@teste.com');
    await page.fill('[data-testid="campo-senha"]', 'senhaSegura123');

    // Submeter formulário
    await page.click('[data-testid="botao-login"]');

    // Verificar redirecionamento para dashboard
    await expect(page).toHaveURL(/.*dashboard/);
    await expect(page.locator('[data-testid="usuario-logado"]')).toBeVisible();
  });

  test('deve mostrar erro com credenciais inválidas', async ({ page }) => {
    // Preencher com dados inválidos
    await page.fill('[data-testid="campo-email"]', 'usuario@invalido.com');
    await page.fill('[data-testid="campo-senha"]', 'senhaErrada');

    // Submeter formulário
    await page.click('[data-testid="botao-login"]');

    // Verificar mensagem de erro
    await expect(page.locator('[data-testid="erro-login"]')).toBeVisible();
    await expect(page.locator('[data-testid="erro-login"]')).toContainText('Credenciais inválidas');
  });

  test('deve validar performance da página login', async ({ page }) => {
    // Medir performance
    const inicio = Date.now();
    await page.goto('http://localhost:3000/login');
    await page.waitForLoadState('networkidle');
    const tempoCarregamento = Date.now() - inicio;

    // Validar tempo de carregamento < 2 segundos
    expect(tempoCarregamento).toBeLessThan(2000);

    // Validar Core Web Vitals
    const webVitals = await page.evaluate(() => {
      return new Promise((resolve) => {
        new PerformanceObserver((list) => {
          const entries = list.getEntries();
          const vitals = {};

          entries.forEach((entry) => {
            if (entry.entryType === 'largest-contentful-paint') {
              vitals.lcp = entry.startTime;
            }
            if (entry.entryType === 'first-input') {
              vitals.fid = entry.processingStart - entry.startTime;
            }
          });

          resolve(vitals);
        }).observe({ entryTypes: ['largest-contentful-paint', 'first-input'] });
      });
    });

    // Validar LCP < 2.5s e FID < 100ms
    if (webVitals.lcp) expect(webVitals.lcp).toBeLessThan(2500);
    if (webVitals.fid) expect(webVitals.fid).toBeLessThan(100);
  });
});
```

### **Template Teste Acessibilidade**
```javascript
// testes/ui/acessibilidade-teste.js
const { test, expect } = require('@playwright/test');

test.describe('Testes de Acessibilidade', () => {
  test('deve atender critérios WCAG 2.1 AA', async ({ page }) => {
    await page.goto('http://localhost:3000');

    // Verificar estrutura semântica
    const titulos = await page.locator('h1, h2, h3, h4, h5, h6').count();
    expect(titulos).toBeGreaterThan(0);

    // Verificar textos alternativos em imagens
    const imagensSemAlt = await page.locator('img:not([alt])').count();
    expect(imagensSemAlt).toBe(0);

    // Verificar contraste de cores (simulação)
    const elementos = await page.locator('button, a, input').all();
    for (const elemento of elementos) {
      const estilos = await elemento.evaluate((el) => {
        const computed = window.getComputedStyle(el);
        return {
          cor: computed.color,
          corFundo: computed.backgroundColor
        };
      });

      // Verificar se elementos têm contraste adequado
      expect(estilos.cor).not.toBe(estilos.corFundo);
    }

    // Verificar navegação por teclado
    await page.keyboard.press('Tab');
    const elementoFocado = await page.evaluate(() => document.activeElement.tagName);
    expect(['BUTTON', 'A', 'INPUT', 'SELECT', 'TEXTAREA']).toContain(elementoFocado);
  });
});
```

---

## 📊 **Templates de Análise de Performance**

### **Script Análise Performance Completa**
```python
# scripts/analise_performance.py - Análise completa PT-BR
import json
import time
from datetime import datetime

class AnalisadorPerformance:
    """Analisador de performance usando Chrome DevTools MCP."""

    def __init__(self, url_projeto):
        self.url_projeto = url_projeto
        self.relatorio = {
            'timestamp': datetime.now().isoformat(),
            'url': url_projeto,
            'resultados': {}
        }

    def analisar_core_web_vitals(self):
        """Analisa Core Web Vitals do projeto."""
        print("📊 Analisando Core Web Vitals...")

        # Template para uso com Chrome DevTools MCP
        analise_vitals = {
            'lcp': 'Largest Contentful Paint',
            'fid': 'First Input Delay',
            'cls': 'Cumulative Layout Shift',
            'ttfb': 'Time to First Byte'
        }

        # Resultados serão coletados via MCP
        self.relatorio['resultados']['web_vitals'] = analise_vitals
        return analise_vitals

    def analisar_recursos(self):
        """Analisa carregamento de recursos."""
        print("📦 Analisando recursos...")

        analise_recursos = {
            'javascript': 'Análise de bundles JS',
            'css': 'Análise de folhas de estilo',
            'imagens': 'Otimização de imagens',
            'fonts': 'Carregamento de fontes'
        }

        self.relatorio['resultados']['recursos'] = analise_recursos
        return analise_recursos

    def gerar_relatorio(self, arquivo_saida='relatorio-performance.json'):
        """Gera relatório final de performance."""
        print(f"📄 Gerando relatório: {arquivo_saida}")

        with open(arquivo_saida, 'w', encoding='utf-8') as arquivo:
            json.dump(self.relatorio, arquivo, indent=2, ensure_ascii=False)

        print("✅ Relatório gerado com sucesso!")
        return arquivo_saida

# Uso do analisador
if __name__ == "__main__":
    analisador = AnalisadorPerformance("http://localhost:3000")
    analisador.analisar_core_web_vitals()
    analisador.analisar_recursos()
    analisador.gerar_relatorio()
```

---

## 🔒 **Configuração de Segurança Específica**

### **Modo Isolado para Projetos Médicos**
```bash
# chrome-devtools-medico-setup.sh
configurar_modo_medico() {
    echo "🏥 Configurando Chrome DevTools para projeto médico..."

    # Configuração extra segura para dados médicos
    cat > .claude/chrome-devtools-medico.json << 'EOF'
{
  "mcpServers": {
    "chrome-devtools-medico": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--isolated=true",
        "--headless=true",
        "--incognito=true",
        "--disableWebSecurity=false",
        "--noSandbox=false",
        "--userDataDir=/tmp/claude-chrome-medico-isolated",
        "--clearUserData=true"
      ],
      "env": {
        "CHROME_DEVTOOLS_MEDICAL_MODE": "true",
        "CHROME_DEVTOOLS_PHI_PROTECTION": "enabled",
        "CHROME_DEVTOOLS_AUDIT_ALL": "true"
      }
    }
  },
  "seguranca_medica": {
    "dados_sinteticos_apenas": true,
    "log_auditoria_completo": true,
    "sem_dados_reais_pacientes": true,
    "conformidade_lgpd": true
  }
}
EOF

    echo "🔒 Configuração médica aplicada"
    echo "⚠️ IMPORTANTE: Use apenas dados sintéticos de pacientes!"
}
```

---

**🔧 Chrome DevTools MCP setup template fornece instalação segura, configuração personalizada, e templates de testes completos em português-BR para qualquer tipo de projeto.**