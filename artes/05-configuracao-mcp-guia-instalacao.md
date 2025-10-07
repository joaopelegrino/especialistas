# Guia de Instalação e Configuração - MCP Servers para Automação de Artes

## 📋 Índice
1. [Pré-requisitos](#pré-requisitos)
2. [Adobe Express MCP (Oficial)](#adobe-express-mcp)
3. [Adobe Creative Suite MCP](#adobe-creative-suite-mcp)
4. [Figma MCP](#figma-mcp)
5. [Canva MCP](#canva-mcp)
6. [Configuração Claude Desktop](#configuração-claude-desktop)
7. [Configuração Claude Code](#configuração-claude-code)
8. [Verificação e Testes](#verificação-e-testes)
9. [Troubleshooting](#troubleshooting)

---

## 🔧 Pré-requisitos

### Software Necessário

```bash
# Verificar versões instaladas
node --version  # Deve ser v18 ou superior
python --version  # Deve ser 3.10 ou superior
npm --version
git --version
```

#### Instalações Necessárias
- **Node.js 18+**: https://nodejs.org/
- **Python 3.10+**: https://python.org/
- **npm**: Vem com Node.js
- **git**: https://git-scm.com/

### Aplicações Adobe
- Adobe Creative Cloud Desktop App (última versão)
- Aplicações específicas conforme necessidade:
  - Photoshop 26.0+
  - Premiere Pro 25.3+
  - Illustrator (última versão)
  - After Effects (última versão)
  - Adobe Express (web ou desktop)

### AI Clients Suportados
- ✅ Claude Desktop
- ✅ Claude Code
- ✅ Cursor
- ✅ VS Code (com extensão Continue)
- ✅ Windsurf

---

## 🎨 Adobe Express MCP (Oficial)

### Sobre
MCP Server oficial da Adobe para desenvolvimento de add-ons do Adobe Express. Fornece documentação e TypeScript definitions diretamente para o LLM.

### Instalação

#### Método 1: Via npx (Recomendado - Não requer instalação)
```bash
# Não precisa instalar, será executado automaticamente via npx
# Configure apenas no arquivo de config do seu AI client
```

#### Método 2: Instalação Global (Opcional)
```bash
npm install -g @adobe/express-add-on-dev-mcp
```

#### Método 3: VS Code Integration
```bash
# Se estiver usando VS Code com Continue
express-mcp-install  # Instala globalmente
express-mcp-workspace  # Instala para workspace atual
express-mcp-help  # Mostra ajuda
```

### Funcionalidades
- 📚 Semantic Documentation Search
- 🔍 TypeScript definitions oficiais
- 💡 Exemplos e tutoriais contextuais
- 🚀 Respostas sem hallucination (dados oficiais)
- ⚡ Sempre atualizado (via npx)

### Quando Usar
- Desenvolvimento de Adobe Express Add-ons
- Integração com Adobe Express SDK
- Consultas sobre APIs do Express
- Debugging de add-ons

---

## 🎨 Adobe Creative Suite MCP

### Sobre
MCP Server community-driven para automação de Photoshop, Premiere Pro, Illustrator, After Effects e InDesign via IA.

### Instalação

#### 1. Clonar Repositório
```bash
cd ~/projects  # ou outro diretório de sua preferência
git clone https://github.com/david-t-martel/adobe-mcp.git
cd adobe-mcp
```

#### 2. Instalar Dependências Python
```bash
pip install -e .
# ou com virtual environment (recomendado)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows
pip install -e .
```

#### 3. Instalar Proxy Server
```bash
cd proxy-server
npm install
cd ..
```

#### 4. Instalar UXP Plugins

##### Para Photoshop
1. Abra **Adobe UXP Developer Tools**
2. Clique em **Add Plugin**
3. Navegue até `adobe-mcp/plugins/photoshop`
4. Selecione `manifest.json`
5. Clique em **Load**
6. No Photoshop, verifique se o plugin aparece em **Plugins > Adobe MCP**

##### Para Premiere Pro
1. Abra **Adobe UXP Developer Tools**
2. Clique em **Add Plugin**
3. Navegue até `adobe-mcp/plugins/premiere`
4. Selecione `manifest.json`
5. Clique em **Load**
6. No Premiere, verifique em **Extensions > Adobe MCP**

##### Para Outras Apps
Repita o processo para Illustrator, After Effects, InDesign usando os plugins correspondentes.

### Iniciar Proxy Server

#### Método 1: Via Comando
```bash
adobe-proxy
```

#### Método 2: Via npm
```bash
cd proxy-server
npm start
```

#### Verificar se está rodando
```bash
# O servidor deve iniciar na porta 3001
# Você verá: "Proxy server running on port 3001"
```

### Funcionalidades por App

#### Photoshop
- Criar/abrir/salvar documentos
- Manipular camadas
- Aplicar filtros e efeitos
- Seleções complexas
- Batch processing
- Automação de workflows

#### Premiere Pro
- Criar/modificar sequências
- Adicionar/editar clips
- Aplicar transições
- Color correction
- Normalização de áudio
- Export automation

#### Illustrator
- Criar formas vetoriais
- Path operations
- Text manipulation
- Transformações
- Export multi-formato

#### After Effects
- Criar composições
- Animação de layers
- Motion tracking
- Expressions automation
- Render settings

---

## 🎨 Figma MCP

### Sobre
MCP Server oficial do Figma para Dev Mode - design-to-code e design tokens.

### Instalação
```bash
# Via npx (recomendado)
# Não requer instalação, será executado automaticamente
```

### Configuração
- Requer **Figma account**
- Requer **Personal Access Token** do Figma
- Obtenha em: https://www.figma.com/developers/api#access-tokens

### Funcionalidades
- 🎨 Design context (metadados de componentes)
- 🖼️ Screenshots visuais
- 🎯 Variable definitions (design tokens)
- 💅 Code syntax para variáveis
- 🔄 Sincronização automática

---

## 🎨 Canva MCP

### Sobre
MCP Server do Canva para criação e edição de designs via linguagem natural.

### Instalação
```bash
# Via npx (recomendado)
# Não requer instalação prévia
```

### Configuração
- Requer **Canva account**
- Requer **API Key** do Canva
- Obtenha em: https://www.canva.dev/

### Funcionalidades
- 📝 Criar/editar designs
- 🎨 Aplicar templates
- 🔄 Redimensionar para múltiplos formatos
- 📤 Export automatizado
- 🤝 Acesso ao seu conteúdo Canva

---

## ⚙️ Configuração Claude Desktop

### Localização do Arquivo

#### Linux/Mac
```bash
~/.config/claude/claude_desktop_config.json
```

#### Windows
```bash
%APPDATA%\Claude\claude_desktop_config.json
```

### Criar/Editar Configuração

#### 1. Criar diretório se não existir
```bash
# Linux/Mac
mkdir -p ~/.config/claude

# Windows (PowerShell)
New-Item -ItemType Directory -Path "$env:APPDATA\Claude" -Force
```

#### 2. Criar/editar arquivo de configuração

Use o arquivo **config-claude-desktop.json** incluído neste diretório como template.

```bash
# Linux/Mac
cp config-claude-desktop.json ~/.config/claude/claude_desktop_config.json

# Windows (PowerShell)
Copy-Item config-claude-desktop.json "$env:APPDATA\Claude\claude_desktop_config.json"
```

#### 3. Personalizar conforme necessário

Edite o arquivo e:
- Remova servidores que não vai usar (adicione `"disabled": true`)
- Ajuste caminhos se instalou em locais diferentes
- Configure variáveis de ambiente se necessário

#### 4. Reiniciar Claude Desktop
```bash
# Feche completamente o Claude Desktop e abra novamente
```

### Verificar Configuração

1. Abra Claude Desktop
2. Inicie uma conversa
3. Digite: "Quais MCP servers estão disponíveis?"
4. Claude deve listar os servidores configurados

---

## ⚙️ Configuração Claude Code

### Localização do Arquivo

Claude Code busca configuração MCP em:
```bash
# 1. Arquivo .clauderc no diretório do projeto (recomendado)
./clauderc

# 2. Arquivo .clauderc no home directory
~/.clauderc

# 3. Variável de ambiente
$CLAUDE_CONFIG_PATH
```

### Configuração no Projeto

#### 1. Copiar arquivo de configuração
```bash
# Já criado neste diretório
cp .clauderc /seu/diretorio/projeto/.clauderc
```

#### 2. Verificar configuração
```bash
cat .clauderc
```

#### 3. Iniciar Claude Code no diretório
```bash
cd /seu/diretorio/projeto
claude-code
```

### Configuração Global

Para usar em todos os projetos:
```bash
cp .clauderc ~/.clauderc
```

### Verificar MCP Servers

No Claude Code, execute:
```
Liste os MCP servers disponíveis
```

---

## ✅ Verificação e Testes

### 1. Verificar Node.js e Python
```bash
node --version  # v18+
python --version  # 3.10+
npm --version
```

### 2. Verificar Proxy Server (Adobe MCP)
```bash
# Iniciar em terminal separado
adobe-proxy

# Em outro terminal, verificar porta
netstat -an | grep 3001  # Linux/Mac
netstat -an | findstr 3001  # Windows
```

### 3. Verificar UXP Plugins
- Abra aplicação Adobe (ex: Photoshop)
- Vá em Plugins > Adobe MCP (ou Extensions)
- Deve aparecer interface do plugin
- Status deve mostrar "Connected"

### 4. Teste Adobe Express MCP

No Claude Desktop ou Claude Code:
```
Como criar um add-on básico para Adobe Express?
```

Resposta esperada: Documentação detalhada com código TypeScript.

### 5. Teste Photoshop MCP

Com Photoshop aberto e proxy rodando:
```
Crie um novo documento Photoshop 1920x1080
com fundo gradiente azul
```

### 6. Teste Figma MCP

Com token configurado:
```
Liste os componentes do arquivo Figma [URL]
```

### 7. Teste Canva MCP

Com API key configurada:
```
Crie um post Instagram com texto "Hello World"
```

---

## 🐛 Troubleshooting

### Problema: MCP Server não aparece no Claude

**Solução:**
```bash
# 1. Verificar sintaxe do JSON
cat ~/.config/claude/claude_desktop_config.json | jq .

# 2. Reiniciar Claude Desktop completamente
# Fechar todas as janelas e reabrir

# 3. Verificar logs
# Linux/Mac: ~/.config/claude/logs/
# Windows: %APPDATA%\Claude\logs\
```

### Problema: Adobe Proxy não conecta

**Solução:**
```bash
# 1. Verificar se porta 3001 está livre
lsof -i :3001  # Linux/Mac
netstat -ano | findstr :3001  # Windows

# 2. Matar processo usando a porta
kill -9 [PID]  # Linux/Mac

# 3. Reiniciar proxy
adobe-proxy
```

### Problema: UXP Plugin não carrega

**Solução:**
1. Verificar versão da aplicação Adobe (mínimos requeridos)
2. Recarregar plugin no UXP Developer Tools
3. Verificar console para erros JavaScript
4. Limpar cache:
   - Mac: `~/Library/Application Support/Adobe/UXP/`
   - Windows: `%APPDATA%\Adobe\UXP\`

### Problema: Python MCP não funciona

**Solução:**
```bash
# 1. Reinstalar dependências
pip install -e . --force-reinstall

# 2. Verificar versão do Python
python --version  # Deve ser 3.10+

# 3. Usar virtual environment
python -m venv venv
source venv/bin/activate
pip install -e .

# 4. Testar manualmente
python -m adobe_mcp.photoshop
```

### Problema: npx não encontra pacote

**Solução:**
```bash
# 1. Limpar cache do npm
npm cache clean --force

# 2. Atualizar npm
npm install -g npm@latest

# 3. Verificar conectividade
npm ping

# 4. Instalar globalmente como fallback
npm install -g adobe-express-mcp-server
```

### Problema: Comandos não executam

**Checklist:**
- [ ] Aplicação Adobe está aberta?
- [ ] Proxy server está rodando?
- [ ] UXP plugin está carregado?
- [ ] Plugin mostra "Connected"?
- [ ] Comando é válido para a aplicação?
- [ ] Teste comando simples primeiro

### Problema: Permissões negadas

**Linux/Mac:**
```bash
# Dar permissões de execução
chmod +x proxy-server/index.js
chmod +x scripts/*.sh
```

**Windows:**
- Execute terminal como Administrador
- Ajuste políticas de execução do PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📊 Comparação de MCPs

| MCP Server | Instalação | Configuração | Apps Suportadas | Status |
|------------|------------|--------------|-----------------|--------|
| **Adobe Express** | ⚡ npx (auto) | 🟢 Fácil | Express | ✅ Oficial Beta |
| **Adobe Suite** | 🔧 Manual | 🟡 Média | PS, Pr, AI, AE, ID | ✅ Community |
| **Figma** | ⚡ npx (auto) | 🟡 Média | Figma | ✅ Oficial |
| **Canva** | ⚡ npx (auto) | 🟡 Média | Canva | ✅ Oficial |

---

## 🎯 Recomendações por Caso de Uso

### Desenvolvimento de Add-ons
✅ **Adobe Express MCP** (oficial, sempre atualizado)

### Automação de Design (Imagens)
✅ **Adobe Suite MCP** (Photoshop + Illustrator)

### Automação de Vídeo
✅ **Adobe Suite MCP** (Premiere + After Effects)

### Design-to-Code
✅ **Figma MCP** (design tokens, componentes)

### Criação Rápida de Assets
✅ **Canva MCP** (templates, multi-formato)

### Workflows Corporativos
✅ **Adobe Suite MCP** + **Figma MCP** (integração completa)

---

## 🔄 Workflow de Instalação Recomendado

### Para Designers/Editores (Não-Desenvolvedores)

```
1. Instalar Node.js 18+
   └─> https://nodejs.org/

2. Instalar Claude Desktop
   └─> https://claude.ai/download

3. Copiar config-claude-desktop.json
   └─> ~/.config/claude/claude_desktop_config.json

4. Reiniciar Claude Desktop

5. Testar com Adobe Express MCP
   └─> "Como criar um add-on Adobe Express?"

6. (Opcional) Instalar Adobe Suite MCP
   └─> Seguir seção "Adobe Creative Suite MCP"
```

### Para Desenvolvedores

```
1. Clonar todos os repos necessários
   ├─> adobe-mcp
   ├─> figma-mcp (se usar Figma)
   └─> canva-mcp (se usar Canva)

2. Setup virtual environments
   └─> python -m venv venv para cada projeto Python

3. Instalar dependências
   ├─> pip install -e . (Python)
   └─> npm install (Node.js)

4. Configurar Claude Desktop + Claude Code
   ├─> config-claude-desktop.json
   └─> .clauderc

5. Iniciar serviços
   ├─> adobe-proxy (terminal 1)
   ├─> Carregar UXP plugins
   └─> Iniciar Claude Code (terminal 2)

6. Criar scripts de automação
   └─> Ver documentos 01-04 para exemplos
```

---

## 📚 Próximos Passos

Após configuração bem-sucedida:

1. **Leia a documentação principal**: [README.md](./README.md)
2. **Explore exemplos práticos**: [03-adobe-mcp-automacao.md](./03-adobe-mcp-automacao.md)
3. **Configure workflows**: [04-creative-cloud-integracoes.md](./04-creative-cloud-integracoes.md)
4. **Crie seus próprios scripts**
5. **Compartilhe com equipe**

---

## 🔗 Links Úteis

### Documentação Oficial
- **Adobe Express MCP**: https://developer.adobe.com/express/add-ons/docs/guides/getting_started/local_development/mcp_server/
- **Figma Dev Mode MCP**: https://www.figma.com/blog/introducing-figmas-dev-mode-mcp-server/
- **Canva MCP**: https://www.canva.dev/docs/connect/mcp-server/
- **Model Context Protocol**: https://modelcontextprotocol.io/

### Repositórios GitHub
- **adobe-mcp**: https://github.com/david-t-martel/adobe-mcp
- **figma-mcp**: https://github.com/figma/mcp-server
- **MCP Servers Registry**: https://github.com/punkpeye/awesome-mcp-servers

### Comunidades
- **MCP Servers**: https://mcpservers.org/
- **Adobe Developer Forums**: https://forums.creativeclouddeveloper.com/
- **Figma Community**: https://forum.figma.com/

---

## 📝 Checklist Final

### Antes de Começar
- [ ] Node.js 18+ instalado
- [ ] Python 3.10+ instalado
- [ ] Claude Desktop/Code instalado
- [ ] Aplicações Adobe instaladas e atualizadas

### Adobe Express MCP
- [ ] Arquivo config criado
- [ ] Claude reiniciado
- [ ] Teste realizado com sucesso

### Adobe Suite MCP (Opcional)
- [ ] Repositório clonado
- [ ] Dependências Python instaladas
- [ ] Proxy server instalado
- [ ] UXP plugins carregados
- [ ] Proxy server rodando
- [ ] Teste de conexão bem-sucedido

### Figma MCP (Opcional)
- [ ] Personal Access Token obtido
- [ ] Configuração adicionada
- [ ] Teste de acesso realizado

### Canva MCP (Opcional)
- [ ] API Key obtida
- [ ] Configuração adicionada
- [ ] Teste de criação realizado

### Validação Final
- [ ] Todos os MCP servers aparecem no Claude
- [ ] Testes básicos funcionando
- [ ] Documentação revisada
- [ ] Pronto para produção! 🚀

---

**Última atualização**: Janeiro 2025
**Versão**: 1.0
**Suporte**: Consulte troubleshooting ou comunidades linkadas
