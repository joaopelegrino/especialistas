# 🎬 Soluções Mais Usadas para Criação de Imagens e Vídeos com Claude Code (2025)

## 📊 Resumo Executivo

Baseado em pesquisas de janeiro 2025, este documento lista as soluções **mais populares e usadas** para criar imagens e vídeos usando Claude Code através de MCPs (Model Context Protocol).

**Categorias:**
- ✅ Geração de Imagens com IA
- ✅ Geração de Vídeos com IA
- ✅ Áudio e Voz
- ✅ Workflows e Automação
- ✅ Design e Prototipação

---

## 🖼️ TOP MCPs para GERAÇÃO DE IMAGENS

### 1. **Replicate MCP** ⭐⭐⭐⭐⭐
**Status**: Oficial | **Popularidade**: Muito Alta

#### O Que É
MCP oficial do Replicate que conecta Claude a centenas de modelos de IA incluindo Stable Diffusion, FLUX, SDXL e outros.

#### Instalação
```bash
# Remote Server (recomendado)
# Adicione ao config: mcp.replicate.com

# Local Server
npx @replicate/mcp-server
```

#### Modelos Disponíveis
- ✅ Stable Diffusion (todos os checkpoints)
- ✅ FLUX.1 (Pro, Dev, Schnell)
- ✅ SDXL
- ✅ Midjourney (via API)
- ✅ 100+ outros modelos

#### Exemplo de Uso
```
Gere uma imagem fotorrealística de um gato usando FLUX.1 Pro
```

#### Links
- Docs: https://replicate.com/docs/reference/mcp
- GitHub: https://github.com/replicate/mcp-server

---

### 2. **Hugging Face MCP** ⭐⭐⭐⭐⭐
**Status**: Oficial | **Popularidade**: Muito Alta

#### O Que É
Integração oficial com Hugging Face Spaces, dá acesso a milhares de modelos de IA open-source.

#### Instalação
```bash
# Via Hugging Face Settings
# https://huggingface.co/mcp/settings

# Adicionar espaços específicos:
# - FLUX.1-Krea-dev
# - FLUX.1-schnell
# - Stable Diffusion XL
```

#### Modelos Populares
- ✅ **FLUX.1** (Black Forest Labs)
  - Schnell: 1-4 steps, ultra-rápido
  - Dev: 12B parâmetros
  - Pro: Qualidade máxima
- ✅ **Stable Diffusion XL** (SDXL)
- ✅ **Krea.ai** (realismo extremo)
- ✅ **Qwen-Image** (texto em imagens)

#### Exemplo de Uso
```
Usando Krea, crie um poster com o texto "Grand Opening"
em estilo moderno e minimalista
```

#### Links
- Blog: https://huggingface.co/blog/claude-and-mcp
- Settings: https://huggingface.co/mcp/settings

---

### 3. **Segmind MCP** ⭐⭐⭐⭐
**Status**: Community | **Popularidade**: Alta

#### O Que É
MCP que conecta à API da Segmind, fornecendo acesso a 30+ modelos de IA de imagem e vídeo.

#### Instalação
```bash
# Via Claude Code
claude mcp add segmind \
  -e SEGMIND_API_KEY=sua_api_key \
  -- npx -y @bratcliffe909/mcp-server-segmind@latest

# Global (user scope)
claude mcp add segmind -s user \
  -e SEGMIND_API_KEY=sua_api_key \
  -- npx -y @bratcliffe909/mcp-server-segmind@latest
```

#### Recursos
- ✅ 30+ modelos AI
- ✅ FLUX, Stable Diffusion, SDXL
- ✅ Imagem + Vídeo
- ✅ API unificada

#### Obter API Key
1. Acesse: https://www.segmind.com/
2. Crie conta
3. Copie API key do dashboard

#### Exemplo de Uso
```
Gere 3 variações de logo para empresa de tecnologia,
estilo moderno, cores azul e branco
```

#### Links
- npm: https://www.npmjs.com/package/@bratcliffe909/mcp-server-segmind
- GitHub: https://github.com/bratcliffe909/segmind-mcp

---

### 4. **Stability AI MCP** ⭐⭐⭐⭐
**Status**: Community | **Popularidade**: Alta

#### O Que É
MCP especializado em Stable Diffusion, conecta diretamente à API da Stability AI.

#### Instalação
```bash
npm install -g @tadasant/mcp-server-stability-ai
```

#### Funcionalidades
- ✅ Generate (criar imagens)
- ✅ Edit (editar imagens existentes)
- ✅ Upscale (aumentar resolução)
- ✅ Inpainting/Outpainting
- ✅ Image-to-Image

#### Modelos
- Stable Diffusion 3.0
- SDXL 1.0
- Stable Diffusion XL Turbo

#### Exemplo de Uso
```
Usando Stable Diffusion 3.0, crie uma paisagem de montanhas
ao pôr do sol, estilo realista
```

#### Links
- GitHub: https://github.com/tadasant/mcp-server-stability-ai

---

### 5. **ComfyUI MCP** ⭐⭐⭐⭐
**Status**: Community | **Popularidade**: Alta (entre profissionais)

#### O Que É
Conecta Claude a uma instância local do ComfyUI, permitindo workflows complexos e customizados.

#### Instalação
```bash
# Requer ComfyUI rodando localmente
# Instalar MCP server
claude mcp add-json "comfy-ui-mcp-server" \
  '{"command":"uvx","args":["comfy-ui-mcp-server"]}'
```

#### Recursos
- ✅ Workflows customizáveis
- ✅ Node-based interface
- ✅ ControlNet, LoRA, etc
- ✅ Controle total sobre geração

#### Quando Usar
- Workflows complexos e repetitivos
- Controle preciso sobre parâmetros
- Uso de modelos customizados/LoRAs
- Integração com pipeline local

#### Exemplo de Uso
```
Execute o workflow "product_photo.json" com esta imagem,
aplicando fundo branco e sombra suave
```

#### Links
- GitHub: https://github.com/jonpojonpo/comfy-ui-mcp-server

---

### 6. **Midjourney MCP** ⭐⭐⭐⭐
**Status**: Community | **Popularidade**: Muito Alta

#### O Que É
MCP não-oficial que conecta Claude ao Midjourney via APIs de terceiros (PiAPI, GPTNB).

#### Instalação
```bash
# Via PiAPI
npm install @apinetwork/piapi-mcp-server

# Via GPTNB
pip install midjourney-mcp
```

#### Funcionalidades
- ✅ Gerar imagens (imagine)
- ✅ Variações (V1-V4)
- ✅ Upscale (U1-U4)
- ✅ Remix
- ✅ Face swap
- ✅ Describe (imagem → prompt)

#### Observação
⚠️ Requer API key de serviço terceiro (PiAPI ou GPTNB), não API oficial do Midjourney.

#### Exemplo de Uso
```
Crie uma ilustração artística de um dragão usando Midjourney,
estilo fantasy art, alta qualidade --v 6
```

#### Links
- PiAPI: https://github.com/apinetwork/piapi-mcp-server
- GPTNB: https://pypi.org/project/midjourney-mcp/

---

## 🎥 TOP MCPs para GERAÇÃO DE VÍDEOS

### 1. **RunwayML + Luma AI MCP** ⭐⭐⭐⭐⭐
**Status**: Community | **Popularidade**: Muito Alta

#### O Que É
MCP que integra RunwayML Gen-3/Gen-4 e Luma AI para geração de vídeos com IA.

#### Instalação
```bash
npm install @wheattoast11/mcp-video-gen

# Configurar .env:
# RUNWAYML_API_SECRET=xxx
# LUMAAI_API_KEY=xxx
# OPENROUTER_API_KEY=xxx (opcional)
```

#### Funcionalidades

**RunwayML Gen-3:**
- ✅ Text-to-Video
- ✅ Image-to-Video
- ✅ Video-to-Video
- ✅ Até 10 segundos
- ✅ Múltiplas resoluções

**Luma AI:**
- ✅ Text-to-Video
- ✅ Image-to-Video
- ✅ Generate audio
- ✅ Generate images
- ✅ Gerenciamento de assets

#### Exemplo de Uso
```
Gere um vídeo de 5 segundos de uma onda quebrando na praia
ao pôr do sol, câmera em slow motion
```

#### Links
- GitHub: https://github.com/wheattoast11/mcp-video-gen
- RunwayML: https://runwayml.com/
- Luma AI: https://lumalabs.ai/

---

### 2. **PixVerse MCP** ⭐⭐⭐⭐
**Status**: Community | **Popularidade**: Alta

#### O Que É
Integração com PixVerse, plataforma de geração de vídeos com IA.

#### Recursos
- ✅ Text-to-Video de qualidade
- ✅ Estilos variados
- ✅ Controle de movimento
- ✅ API acessível

#### Exemplo de Uso
```
Crie vídeo de 4 segundos: pessoa caminhando em cidade futurista,
estilo cyberpunk, movimento suave de câmera
```

---

### 3. **MiniMax MCP** ⭐⭐⭐⭐
**Status**: Official | **Popularidade**: Crescendo

#### O Que É
MCP oficial da MiniMax que oferece Text-to-Speech, imagem e vídeo.

#### Funcionalidades
- ✅ Text-to-Video
- ✅ Text-to-Speech
- ✅ Image generation
- ✅ Multi-modal

#### Exemplo de Uso
```
Gere vídeo curto de animação 3D de um robô dançando
```

---

## 🎙️ TOP MCPs para ÁUDIO E VOZ

### 1. **ElevenLabs MCP** ⭐⭐⭐⭐⭐
**Status**: Official | **Popularidade**: Muito Alta

#### O Que É
MCP oficial da ElevenLabs para geração de voz, clonagem e transcrição.

#### Instalação
```bash
npm install @elevenlabs/elevenlabs-mcp

# Configurar .env:
# ELEVENLABS_API_KEY=xxx
```

#### Funcionalidades
- ✅ **Text-to-Speech** (dezenas de vozes)
- ✅ **Voice Cloning** (clone sua voz)
- ✅ **Transcription** (áudio → texto)
- ✅ **Voice Agents** (chamadas automatizadas)
- ✅ **Multi-lingual**

#### Uso Avançado
```
# Criar agente de voz
Crie um agente de voz com personalidade amigável que pode
fazer pedidos de pizza por telefone

# TTS básico
Converta este texto em áudio com voz masculina profissional
```

#### Pricing
- Free tier: 10k créditos/mês
- Planos pagos: A partir de $5/mês

#### Links
- GitHub: https://github.com/elevenlabs/elevenlabs-mcp
- Website: https://elevenlabs.io/

---

## 🎨 MCPs para DESIGN E PROTOTIPAÇÃO

### 1. **Figma MCP** ⭐⭐⭐⭐⭐
**Status**: Official | **Popularidade**: Muito Alta

#### O Que É
MCP oficial do Figma para design-to-code e design tokens.

#### Instalação
```bash
# Via npx (já configurado)
npx -y @figma/mcp-server
```

#### Funcionalidades
- ✅ Extrair design tokens
- ✅ Acessar componentes
- ✅ Design-to-code
- ✅ Sincronização de estilos

#### Exemplo de Uso
```
Extraia todos os design tokens de cores do arquivo Figma [URL]
e gere CSS variables
```

---

### 2. **Adobe Express MCP** ⭐⭐⭐⭐
**Status**: Official (Beta) | **Popularidade**: Crescendo

#### O Que É
MCP oficial da Adobe para desenvolvimento de add-ons Express.

#### Instalação
```bash
# Já instalado neste projeto
npx -y @adobe/express-add-on-dev-mcp@latest
```

#### Uso
Documentação e desenvolvimento de add-ons, não criação direta.

---

### 3. **Canva Dev MCP** ⭐⭐⭐⭐
**Status**: Official | **Popularidade**: Alta

#### O Que É
MCP oficial do Canva para desenvolvimento de apps.

#### Instalação
```bash
# Já instalado neste projeto
npm install -g @canva/cli@latest
canva mcp
```

#### Uso
Desenvolvimento de apps Canva, não criação direta.

---

## 🔧 MCPs de WORKFLOW E AUTOMAÇÃO

### 1. **Playwright MCP** ⭐⭐⭐⭐⭐
**Status**: Community | **Popularidade**: #1 (12K stars GitHub)

#### O Que É
Browser automation para AI agents, útil para scraping e screenshots.

#### Casos de Uso para Imagens
- Screenshot de websites
- Captura de UI states
- Testing visual
- Automated design QA

---

### 2. **n8n MCP** ⭐⭐⭐⭐
**Status**: Community | **Popularidade**: Alta

#### O Que É
Conecta Claude a workflows do n8n.

#### Casos de Uso
- Automatizar pipeline de geração
- Integrar com outros serviços
- Workflows complexos
- Processamento em lote

---

## 📊 RANKING POR POPULARIDADE (2025)

### Geração de Imagens
1. 🥇 **Replicate MCP** - Versatilidade
2. 🥈 **Hugging Face MCP** - Open source
3. 🥉 **Midjourney MCP** - Qualidade artística
4. **Segmind MCP** - API unificada
5. **ComfyUI MCP** - Controle profissional

### Geração de Vídeos
1. 🥇 **RunwayML + Luma MCP** - Líder de mercado
2. 🥈 **PixVerse MCP** - Custo-benefício
3. 🥉 **MiniMax MCP** - Multi-modal

### Áudio e Voz
1. 🥇 **ElevenLabs MCP** - Dominante
2. Outros MCPs de TTS menos populares

---

## 💡 GUIA DE ESCOLHA

### Para Iniciantes
✅ **Hugging Face MCP**
- Grátis e open source
- Fácil de começar
- Muitos modelos disponíveis

### Para Qualidade Máxima (Imagens)
✅ **Midjourney MCP** ou **FLUX.1 Pro via Replicate**
- Melhores resultados artísticos
- Vale o custo

### Para Qualidade Máxima (Vídeos)
✅ **RunwayML Gen-3**
- Estado da arte
- Até 10 segundos
- Realismo impressionante

### Para Áudio/Voz
✅ **ElevenLabs MCP**
- Único oficial e mais completo
- Voice cloning
- Multi-lingual

### Para Workflows Profissionais
✅ **ComfyUI MCP** + **Replicate MCP**
- Controle total
- Repetibilidade
- Customização

### Para Prototipação Rápida
✅ **Segmind MCP**
- API unificada
- 30+ modelos
- Simples de usar

---

## 🚀 SETUP RECOMENDADO

### Configuração Básica (Gratuita)
```json
{
  "mcp": {
    "servers": {
      "huggingface": {
        "command": "npx",
        "args": ["-y", "hf-mcp-server"]
      },
      "replicate-remote": {
        "url": "mcp.replicate.com"
      }
    }
  }
}
```

### Configuração Intermediária
```json
{
  "mcp": {
    "servers": {
      "replicate": {
        "command": "npx",
        "args": ["-y", "@replicate/mcp-server"]
      },
      "segmind": {
        "command": "npx",
        "args": ["-y", "@bratcliffe909/mcp-server-segmind@latest"],
        "env": {
          "SEGMIND_API_KEY": "sua_api_key"
        }
      },
      "elevenlabs": {
        "command": "npx",
        "args": ["-y", "@elevenlabs/elevenlabs-mcp"],
        "env": {
          "ELEVENLABS_API_KEY": "sua_api_key"
        }
      }
    }
  }
}
```

### Configuração Profissional
```json
{
  "mcp": {
    "servers": {
      "replicate": {...},
      "segmind": {...},
      "runway-luma": {
        "command": "npx",
        "args": ["-y", "@wheattoast11/mcp-video-gen"],
        "env": {
          "RUNWAYML_API_SECRET": "xxx",
          "LUMAAI_API_KEY": "xxx"
        }
      },
      "elevenlabs": {...},
      "comfyui": {
        "command": "uvx",
        "args": ["comfy-ui-mcp-server"]
      },
      "midjourney": {
        "command": "npx",
        "args": ["-y", "@apinetwork/piapi-mcp-server"],
        "env": {
          "PIAPI_API_KEY": "xxx"
        }
      }
    }
  }
}
```

---

## 💰 CUSTOS ESTIMADOS

### Tier Gratuito
- **Hugging Face**: Grátis (rate limits)
- **Replicate**: $0 + pay-as-you-go
- **Stability AI**: Trial credits
- **ElevenLabs**: 10k créditos/mês

### Tier Profissional (~/mês)
- **Segmind**: $10-50
- **RunwayML**: $12-76
- **Luma AI**: $30-200
- **ElevenLabs**: $5-99
- **Midjourney (via PiAPI)**: $15-60

### Custo Médio para Produção
**Imagens**: $0.01 - $0.50 por imagem
**Vídeos**: $0.50 - $5.00 por 5 segundos
**Áudio**: $0.15 - $0.30 por 1000 caracteres

---

## 🎯 CASOS DE USO POPULARES

### Social Media Content
```
Setup: Replicate MCP + ElevenLabs MCP
Workflow:
1. Gerar imagens para posts (FLUX/SDXL)
2. Criar voiceover (ElevenLabs)
3. Combinar em vídeo curto
```

### Product Marketing
```
Setup: ComfyUI MCP + RunwayML MCP
Workflow:
1. Render produto com fundo limpo (ComfyUI)
2. Criar vídeo demonstração (RunwayML)
3. Adicionar música de fundo
```

### YouTube Automation
```
Setup: Hugging Face + ElevenLabs + RunwayML
Workflow:
1. Gerar thumbnails (FLUX.1)
2. Criar B-roll (RunwayML)
3. Narração (ElevenLabs)
4. Edição automática
```

### E-learning
```
Setup: Segmind MCP + ElevenLabs MCP
Workflow:
1. Gerar ilustrações didáticas
2. Criar avatar virtual
3. Voice-over multi-lingual
4. Exports finais
```

---

## 📚 RECURSOS ADICIONAIS

### Encontrar MCPs
- **MCP Market**: https://mcpmarket.com/
- **Awesome MCP Servers**: https://mcpservers.org/
- **Glama MCP**: https://glama.ai/mcp/servers
- **GitHub**: https://github.com/modelcontextprotocol/servers

### Tutoriais
- **Claude Docs**: https://docs.claude.com/en/docs/claude-code/mcp
- **Replicate Blog**: https://replicate.com/blog
- **Hugging Face Blog**: https://huggingface.co/blog

### Comunidades
- **Discord**: Anthropic MCP Community
- **Reddit**: r/ClaudeAI
- **GitHub Discussions**: Nos repos oficiais

---

## ⚠️ CONSIDERAÇÕES IMPORTANTES

### Rate Limits
Todos os serviços têm rate limits. Para produção, considere:
- Implementar filas
- Caching de resultados
- Retry logic

### Custos
Monitore uso para evitar surpresas:
- Configure billing alerts
- Use tier gratuitos para testes
- Calcule ROI antes de escalar

### Qualidade
Nem sempre "mais caro = melhor":
- Teste múltiplos modelos
- Compare resultados
- Considere trade-offs (velocidade vs qualidade)

### Legal e Ético
- Verifique termos de uso de cada serviço
- Respeite direitos autorais
- Use IA de forma responsável

---

## 🔄 PRÓXIMAS ATUALIZAÇÕES

Tecnologias em desenvolvimento:
- **Sora (OpenAI)**: Text-to-video de longa duração
- **Runway Gen-4**: Maior controle e duração
- **Adobe Firefly MCP**: Potencial integração oficial
- **Google Imagen 4**: Competição ao DALL-E/Midjourney

---

**Última atualização**: Janeiro 2025
**Pesquisa baseada em**: Uso real, GitHub stars, menções em comunidades, documentação oficial
**Status**: As informações refletem o ecossistema MCP em janeiro de 2025
