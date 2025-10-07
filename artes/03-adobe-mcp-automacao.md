# Adobe MCP - Model Context Protocol para Automação Criativa

## 🤖 O QUE É MCP?

O **Model Context Protocol (MCP)** é um padrão aberto desenvolvido pela Anthropic que permite que sistemas de IA se conectem de forma segura às ferramentas e dados que as empresas já usam.

### Analogia
MCP funciona como um "adaptador universal" para IA, permitindo que diferentes sistemas trabalhem juntos sem necessidade de integrações caras e específicas.

---

## 🎨 ADOBE MCP - VISÃO GERAL

Adobe MCP é uma implementação do Model Context Protocol que permite automação AI-powered de aplicações Adobe Creative Suite através de linguagem natural.

### Aplicações Suportadas
- ✅ Adobe Photoshop (26.0+)
- ✅ Adobe Premiere Pro (25.3+)
- ✅ Adobe Illustrator
- ✅ Adobe InDesign
- ✅ Adobe After Effects
- ✅ Adobe Lightroom
- ✅ **Adobe Express (MCP Oficial Beta)** ⭐

### Destaque: Adobe Express MCP Server
O **Adobe Express Add-on MCP Server** é a implementação oficial da Adobe (Beta) que fornece:
- 📚 Documentação oficial do Adobe Express Add-ons
- 🔍 TypeScript definitions atualizadas
- 💡 Semantic search de exemplos e guias
- ⚡ Zero instalação necessária (via npx)
- 🎯 Respostas precisas sem hallucination

**Ideal para**: Desenvolvimento de add-ons, integração com Adobe Express SDK

---

## 🏗️ ARQUITETURA DO SISTEMA

### Estrutura de 3 Camadas

```
┌─────────────────────────────────────────┐
│   AI Clients (Claude, ChatGPT, etc)    │
│                                         │
└────────────────┬────────────────────────┘
                 │ MCP Protocol
┌────────────────▼────────────────────────┐
│        MCP Servers (Python)             │
│   - Expõe ferramentas para AI clients  │
│   - Processa comandos em linguagem     │
│     natural                             │
└────────────────┬────────────────────────┘
                 │ WebSocket
┌────────────────▼────────────────────────┐
│      Proxy Server (Node.js)             │
│   - Bridge WebSocket entre MCP e UXP   │
│   - Porta 3001                          │
└────────────────┬────────────────────────┘
                 │ WebSocket
┌────────────────▼────────────────────────┐
│        UXP Plugins (JavaScript)         │
│   - Executam comandos nas apps Adobe   │
│   - Interface direta com aplicações    │
└─────────────────────────────────────────┘
```

---

## 📦 INSTALAÇÃO E CONFIGURAÇÃO

### Requisitos de Sistema

#### Software Necessário
- Python 3.10+
- Node.js 18+
- npm
- git
- Adobe UXP Developer Tools
- Aplicações Adobe Creative Suite

#### Sistemas Operacionais
- ✅ Windows
- ✅ macOS
- ⚠️ Linux (limitado)

### Passo a Passo de Instalação

#### 1. Clonar Repositório
```bash
git clone https://github.com/david-t-martel/adobe-mcp.git
cd adobe-mcp
```

#### 2. Instalar Dependências Python
```bash
pip install -e .
```

#### 3. Instalar Proxy Server
```bash
cd proxy-server
npm install
```

#### 4. Iniciar Proxy Server
```bash
adobe-proxy
# Ou diretamente:
npm start
```

#### 5. Instalar UXP Plugins
1. Abra Adobe UXP Developer Tools
2. Carregue plugin da pasta correspondente à aplicação
3. Verifique conexão WebSocket (porta 3001)

### Configuração em AI Clients

#### Claude Desktop
```json
// ~/.config/claude/claude_desktop_config.json (Linux/Mac)
// %APPDATA%\Claude\claude_desktop_config.json (Windows)
{
  "mcpServers": {
    "adobe-photoshop": {
      "command": "python",
      "args": ["-m", "adobe_mcp.photoshop"]
    },
    "adobe-premiere": {
      "command": "python",
      "args": ["-m", "adobe_mcp.premiere"]
    }
  }
}
```

#### Cursor
```json
// .cursor/mcp.json
{
  "servers": {
    "adobe": {
      "command": "python",
      "args": ["-m", "adobe_mcp"]
    }
  }
}
```

---

## 💡 EXEMPLOS DE USO

### Photoshop via MCP

#### Comandos Básicos
```
"Crie um novo documento Photoshop com 1920x1080 pixels"

"Adicione um gradiente azul de fundo"

"Crie uma camada de texto dizendo 'Hello World' em Helvetica 48pt"

"Aplique filtro Gaussian Blur na camada atual"
```

#### Workflows Complexos
```
"Crie um efeito de dupla exposição usando essas duas imagens"

"Gere um mockup de telefone com esta screenshot"

"Automatize o processo de:
1. Abrir imagem
2. Redimensionar para 800x600
3. Aplicar filtro de sharpen
4. Salvar como JPEG qualidade 90"
```

### Premiere Pro via MCP

#### Edição Básica
```
"Adicione transições cross-fade entre todos os clips"

"Normalize o áudio de todas as tracks"

"Crie uma sequência de 1080p 24fps"

"Adicione lower third com nome e título"
```

#### Automação de Workflow
```
"Para cada clipe na timeline:
1. Aplique color grade 'warm'
2. Adicione fade in/out de 0.5s
3. Normalize áudio"

"Exporte em 3 formatos:
- YouTube (1080p H.264)
- Instagram (1080x1080)
- TikTok (1080x1920)"
```

### Illustrator via MCP

#### Criação Vetorial
```
"Crie um logo circular com as iniciais 'AB'"

"Gere um ícone de casa minimalista em 64x64px"

"Trace esta imagem e converta para vetor"

"Crie padrão geométrico repetível"
```

### After Effects via MCP

#### Motion Graphics
```
"Crie animação de lower third com:
- Nome: João Silva
- Título: Designer
- Duração: 3 segundos
- Estilo: moderno e clean"

"Adicione tracking de movimento neste clip"

"Crie composição 1080p com background animado"
```

---

## 🔧 FUNCIONALIDADES DISPONÍVEIS

### Photoshop MCP

#### Gerenciamento de Documentos
- Criar/abrir/salvar documentos
- Configurar dimensões e resolução
- Gerenciar artboards

#### Camadas (Layers)
- Criar/duplicar/mesclar camadas
- Organizar em grupos
- Aplicar blend modes
- Ajustar opacidade

#### Seleções
- Criar seleções (retangular, elíptica, polígono)
- Modificar seleções (expand, contract, feather)
- Salvar/carregar seleções

#### Filtros e Efeitos
- Gaussian Blur
- Sharpen
- Motion Blur
- Distortion effects
- Stylize effects

#### Texto
- Adicionar/editar texto
- Configurar fonte, tamanho, cor
- Alinhamento e espaçamento
- Text effects

### Premiere Pro MCP

#### Timeline
- Criar/modificar sequências
- Adicionar/remover clips
- Ajustar timing
- Aplicar transições

#### Efeitos
- Color correction
- Lumetri Color
- Effects presets
- Keyframe animation

#### Áudio
- Normalização automática
- Ducking
- Audio effects
- Mix multitrack

#### Export
- Presets personalizados
- Múltiplos formatos
- Batch export
- Media Encoder integration

### Illustrator MCP

#### Formas Vetoriais
- Criar primitivas (círculo, retângulo, polígono)
- Path operations (unite, subtract, intersect)
- Modificadores (offset, simplify)

#### Texto e Tipografia
- Text frames
- Text on path
- Character/paragraph styles

#### Transformações
- Scale, rotate, skew
- Align e distribute
- Transform patterns

---

## 🚀 CASOS DE USO AVANÇADOS

### 1. Automação de Thumbnails para YouTube

```python
# Exemplo de workflow automatizado
"""
1. Abra template base
2. Importe screenshot do vídeo
3. Adicione título com texto fornecido
4. Aplique efeitos padrão
5. Exporte em 1280x720 JPEG
"""

prompt = """
Use o template 'youtube_thumb.psd':
- Substitua layer 'screenshot' com 'video_01.jpg'
- Mude texto do layer 'titulo' para 'Como usar Adobe MCP'
- Aplique filtro sharpen
- Exporte como 'thumb_final.jpg' qualidade 95
"""
```

### 2. Batch Processing de Imagens

```
"Para cada imagem na pasta 'input/':
1. Redimensione para max 2000px mantendo aspect ratio
2. Aplique auto color correction
3. Adicione watermark no canto inferior direito
4. Salve na pasta 'output/' como JPG qualidade 85"
```

### 3. Criação de Variações de Design

```
"Gere 5 variações do logo atual com:
- Diferentes paletas de cores (warm, cool, monochrome, etc)
- Mantenha estrutura e proporções
- Exporte cada variação como SVG e PNG"
```

### 4. Video Templates Dinâmicos

```
"No Premiere Pro, usando template 'promo_video.prproj':
- Substitua 'clip_01' a 'clip_05' com arquivos da pasta 'footage/'
- Atualize textos conforme planilha 'dados.csv'
- Renderize uma versão para cada linha da planilha
- Nomeie arquivos como 'promo_[nome_cliente].mp4'"
```

---

## 📊 INTEGRAÇÕES COM CREATIVE CLOUD

### Creative Cloud Libraries MCP

#### Funcionalidades
- Acesse cores, character styles, logos salvos
- Compartilhe assets entre aplicações
- Sincronize com equipe
- Versionamento de assets

#### Configuração
```bash
npm install @adobe/creative-cloud-libraries-mcp
```

#### Uso
```
"Importe a paleta de cores da library 'Brand Colors'"

"Adicione este logo à library 'Client Assets'"

"Sincronize paragraph style 'Body Text' da library compartilhada"
```

### Adobe Stock Integration

```
"Busque imagens de 'workspace moderno' no Adobe Stock"

"Licencie e insira a imagem #12345 no documento"

"Mostre previews de vetores relacionados a 'tecnologia'"
```

### Adobe Fonts

```
"Liste todas as fontes Adobe Fonts disponíveis com 'sans' no nome"

"Ative a fonte 'Proxima Nova' do Adobe Fonts"

"Aplique fonte Adobe 'Bebas Neue' ao texto selecionado"
```

---

## 🔐 SEGURANÇA E PRIVACIDADE

### Execução Local
- ✅ MCP server roda localmente no dispositivo
- ✅ Nenhum código ou prompt é transmitido externamente
- ✅ Dados permanecem no computador do usuário

### Controle de Acesso
- Autenticação via Adobe Creative Cloud
- Permissões granulares por aplicação
- Logs de atividades auditáveis

### Boas Práticas
- Não compartilhe credenciais
- Revise comandos antes de executar ações destrutivas
- Faça backup antes de automações em lote
- Use versionamento (git) para projetos importantes

---

## 🐛 TROUBLESHOOTING

### Problemas Comuns

#### 1. Proxy Server Não Conecta
```bash
# Verifique se porta 3001 está disponível
netstat -an | grep 3001

# Reinicie proxy server
pkill -f adobe-proxy
adobe-proxy
```

#### 2. UXP Plugin Não Carrega
- Verifique versão da aplicação Adobe (mínimos requeridos)
- Recarregue plugin no UXP Developer Tools
- Verifique console para erros JavaScript

#### 3. MCP Server Não Responde
```bash
# Reinstale dependências Python
pip install -e . --force-reinstall

# Verifique versão do Python
python --version  # Deve ser 3.10+
```

#### 4. Comandos Não Executam
- Verifique se aplicação Adobe está aberta
- Confirme que plugin está conectado (indicator no app)
- Teste comando simples primeiro
- Revise logs do proxy server

### Logs e Debugging

#### Habilitar Logs Detalhados
```bash
# Proxy server
DEBUG=* npm start

# Python MCP
export ADOBE_MCP_DEBUG=1
python -m adobe_mcp.photoshop
```

#### Locais de Log
```
Windows: %APPDATA%\adobe-mcp\logs\
Mac: ~/Library/Logs/adobe-mcp/
Linux: ~/.local/share/adobe-mcp/logs/
```

---

## 📚 RECURSOS ADICIONAIS

### Repositórios GitHub

#### Principais Implementações
```
david-t-martel/adobe-mcp
- Unified MCP para Creative Suite

mikechambers/adb-mcp
- Adobe Creative Suite MCP alternativo

loonghao/photoshop-python-api-mcp-server
- Python API para Photoshop

spencerhhubert/illustrator-mcp-server
- Específico para Illustrator

helloprkr/mcp-adobe-cloud
- Suporte para Lightroom, Premiere, After Effects, Aero
```

### Documentação Oficial

```
Adobe Express MCP (Beta):
https://developer.adobe.com/express/add-ons/docs/guides/getting_started/local_development/mcp_server/

Creative Cloud Developer Platform:
https://developer.adobe.com/creative-cloud/

UXP Developer Documentation:
https://developer.adobe.com/photoshop/uxp/
```

### Comunidade

- **Adobe Creative Cloud Developer Forums**
- **MCP Servers Registry**: mcpservers.org
- **GitHub Discussions** nos repos principais
- **Discord**: Anthropic MCP Community

---

## 🎯 ROADMAP E FUTURO

### Em Desenvolvimento
- [ ] Suporte completo para InDesign
- [ ] After Effects motion tracking via MCP
- [ ] Integration com Adobe Firefly generative AI
- [ ] Substance 3D integration
- [ ] Adobe XD revival via MCP

### Melhorias Planejadas
- [ ] Performance optimization
- [ ] Error handling aprimorado
- [ ] Mais exemplos e templates
- [ ] UI dashboard para gerenciamento
- [ ] Marketplace de scripts MCP

---

## 💻 EXEMPLOS DE SCRIPTS COMPLETOS

### Script 1: Processamento em Lote de Fotos

```python
"""
Photoshop MCP - Batch Photo Processing
"""

workflow = """
Para cada arquivo .jpg na pasta '/photos/raw':
1. Abrir arquivo
2. Auto tone (Image > Auto Tone)
3. Redimensionar para largura máxima 2000px
4. Sharpen (Filter > Sharpen > Smart Sharpen, amount: 50%, radius: 1.0)
5. Salvar como JPEG qualidade 90 em '/photos/processed/'
6. Fechar documento
"""

# Execute via Claude Desktop ou outro AI client
# O MCP processará automaticamente todos os arquivos
```

### Script 2: Template de Lower Third Animado

```javascript
// After Effects via MCP
// Criar lower third template

const lowerThirdConfig = {
  name: "João Silva",
  title: "Designer Gráfico",
  duration: 3,
  style: {
    backgroundColor: "#2563eb",
    textColor: "#ffffff",
    accentColor: "#f59e0b"
  },
  animation: {
    slideIn: 0.5,
    holdTime: 2.0,
    slideOut: 0.5
  }
};

// Prompt para MCP:
"Crie composição After Effects de lower third com configurações acima"
```

### Script 3: Geração de Posts para Redes Sociais

```
"Usando o template 'social_media.psd':

Crie 3 variações do post:
1. Instagram Post (1080x1080):
   - Background: gradiente azul-roxo
   - Título: 'Dica do Dia'
   - Texto: [conteúdo fornecido]
   - Logo: canto superior esquerdo

2. Instagram Story (1080x1920):
   - Mesmo estilo, adaptado verticalmente
   - Adicionar CTA button na parte inferior

3. LinkedIn Post (1200x627):
   - Versão mais profissional
   - Sem gradiente intenso
   - Background branco com elementos azuis

Exporte todos em PNG e salve na pasta '/exports/social/'"
```

---

## 📈 MÉTRICAS DE PERFORMANCE

### Comparação: Manual vs MCP Automation

| Tarefa | Tempo Manual | Tempo com MCP | Economia |
|--------|--------------|---------------|----------|
| Resize batch 100 imagens | 45 min | 5 min | 89% |
| Aplicar watermark em 50 fotos | 30 min | 3 min | 90% |
| Criar 10 variações de cor logo | 60 min | 8 min | 87% |
| Lower thirds personalizados (5x) | 90 min | 12 min | 87% |
| Export multi-formato vídeo | 25 min | 8 min | 68% |
| Atualizar template com novos dados | 40 min | 4 min | 90% |

### ROI Estimado
- **Pequenas equipes (1-5 pessoas)**: 15-25 horas/semana economizadas
- **Médias equipes (6-20 pessoas)**: 40-80 horas/semana economizadas
- **Grandes estúdios (20+ pessoas)**: 100+ horas/semana economizadas

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### Fase 1: Setup Inicial
- [ ] Instalar requisitos (Python, Node.js, etc)
- [ ] Clonar repositórios necessários
- [ ] Configurar proxy server
- [ ] Instalar UXP plugins
- [ ] Testar conexão básica

### Fase 2: Configuração de AI Clients
- [ ] Configurar Claude Desktop/Cursor
- [ ] Adicionar MCP servers ao config
- [ ] Testar comandos simples
- [ ] Validar integrações

### Fase 3: Criação de Workflows
- [ ] Identificar tarefas repetitivas
- [ ] Documentar workflows atuais
- [ ] Criar templates e presets
- [ ] Escrever scripts de automação
- [ ] Testar em ambiente seguro

### Fase 4: Produção
- [ ] Deploy em máquinas de produção
- [ ] Treinar equipe
- [ ] Monitorar performance
- [ ] Coletar feedback
- [ ] Iterar e melhorar

### Fase 5: Otimização
- [ ] Analisar métricas de uso
- [ ] Identificar gargalos
- [ ] Criar biblioteca de scripts
- [ ] Documentar best practices
- [ ] Compartilhar com equipe

---

## 🌟 CASOS DE SUCESSO

### Estúdio de Design
- **Desafio**: 200+ banners por semana para diferentes clientes
- **Solução**: MCP automation com templates dinâmicos
- **Resultado**: 75% redução de tempo, zero erros humanos

### Agência de Vídeo Marketing
- **Desafio**: Personalizar vídeos promocionais para 50+ clientes
- **Solução**: Premiere Pro MCP com data-driven editing
- **Resultado**: 10x aumento em produção, mesma equipe

### Freelancer E-commerce
- **Desafio**: Processar 1000+ fotos de produtos/mês
- **Solução**: Photoshop MCP batch processing
- **Resultado**: 80% redução de tempo, capacidade de aceitar mais clientes

---

**Última atualização**: Janeiro 2025
**Versão do Documento**: 1.0
**Licença**: MIT (repositories open source)
