# 🚀 Quick Start: Criar Imagens e Vídeos com IA no Claude Code

## ⚡ Setup Mais Rápido (5 minutos)

### Opção 1: Hugging Face (Grátis)
```bash
# 1. Acesse
https://huggingface.co/mcp/settings

# 2. Adicione estes espaços:
# - FLUX.1-Krea-dev (imagens fotorrealísticas)
# - FLUX.1-schnell (imagens rápidas)

# 3. Use no Claude Code
"Usando Krea, crie uma foto realista de um cachorro no parque"
```

**Pronto!** ✅ Zero instalação, zero custo.

---

### Opção 2: Replicate Remote (Mais Versátil)
```json
// Adicione ao .clauderc
{
  "mcp": {
    "servers": {
      "replicate": {
        "url": "mcp.replicate.com"
      }
    }
  }
}
```

```bash
# Use no Claude Code
"Gere uma imagem com Stable Diffusion XL: paisagem futurista"
```

---

## 🎬 Para Criar Vídeos

### RunwayML + Luma AI
```bash
# 1. Obter API keys
# RunwayML: https://runwayml.com/
# Luma AI: https://lumalabs.ai/

# 2. Instalar
npm install @wheattoast11/mcp-video-gen

# 3. Configurar .env
RUNWAYML_API_SECRET=sua_key
LUMAAI_API_KEY=sua_key

# 4. Usar
"Crie um vídeo de 5 segundos de uma onda quebrando na praia"
```

---

## 🎙️ Para Criar Áudio/Voz

### ElevenLabs
```bash
# 1. Obter API key
# https://elevenlabs.io/

# 2. Instalar
npm install @elevenlabs/elevenlabs-mcp

# 3. Configurar .env
ELEVENLABS_API_KEY=sua_key

# 4. Usar
"Converta este texto em áudio com voz masculina profissional"
```

---

## 📊 Qual Escolher?

### Para Imagens

| Necessidade | Solução | Custo |
|-------------|---------|-------|
| Começar rápido | Hugging Face | Grátis |
| Máxima qualidade | Midjourney via PiAPI | $$ |
| Versatilidade | Replicate | Pay-as-go |
| Controle total | ComfyUI | Grátis* |

### Para Vídeos

| Necessidade | Solução | Custo |
|-------------|---------|-------|
| Melhor qualidade | RunwayML Gen-3 | $$$ |
| Custo-benefício | Luma AI | $$ |
| Começar rápido | PixVerse | $ |

### Para Áudio

| Necessidade | Solução | Custo |
|-------------|---------|-------|
| Vozes naturais | ElevenLabs | 10k free/mês |
| Voice cloning | ElevenLabs | $ |

---

## 💰 Custos Reais

### Tier Gratuito (Teste)
- ✅ Hugging Face: Grátis
- ✅ ElevenLabs: 10k caracteres/mês
- ✅ Replicate: Credits iniciais

### Uso Casual ($10-30/mês)
- Segmind: 1000 imagens
- Luma AI: ~50 vídeos curtos
- ElevenLabs: 30k caracteres

### Uso Profissional ($50-200/mês)
- RunwayML: Vídeos ilimitados
- Replicate: 10k+ imagens
- ElevenLabs: Voice cloning

---

## 🎯 Casos de Uso Rápidos

### Social Media Posts
```
"Crie 5 variações de post Instagram 1080x1080:
- Tema: Promoção verão
- Cores: Azul e amarelo
- Texto: 'Sale 50% OFF'
- Estilo: Moderno e clean"
```

### YouTube Thumbnail
```
"Gere thumbnail YouTube 1280x720:
- Pessoa surpresa (expression: shocked)
- Fundo: Gradiente vermelho
- Texto grande: 'INCRÍVEL!'
- Estilo: Alta saturação, contraste alto"
```

### Product Mockup
```
"Crie mockup de produto:
- Item: Garrafa de água
- Fundo: Branco puro
- Iluminação: Studio light
- Ângulo: 45 graus
- Sombra: Suave"
```

### Vídeo Promocional
```
"Gere vídeo 5 seg:
- Produto: Smartphone
- Ação: Rotação 360 graus
- Fundo: Gradiente tech
- Velocidade: Smooth
- Resolução: 1080p"
```

### Voice Over
```
"Crie narração para vídeo:
- Texto: [seu script]
- Voz: Masculina, profissional
- Tom: Entusiasmado mas confiável
- Idioma: Português BR"
```

---

## 🔧 Troubleshooting Rápido

### "MCP não aparece"
```bash
# Reinicie Claude Code
# ou
# Verifique .clauderc sintaxe
cat .clauderc | jq .
```

### "API key inválida"
```bash
# Verifique .env
cat .env

# Regenere key no site do serviço
```

### "Geração muito lenta"
```
# Use modelos mais rápidos:
# - FLUX.1-schnell (imagens)
# - Luma AI (vídeos)
# - Gen-3 Turbo (RunwayML)
```

### "Resultado ruim"
```
# Melhore o prompt:
# ❌ "cachorro"
# ✅ "golden retriever correndo em campo verde,
#     fotografia profissional, luz natural, 4K"

# Use prompt enhancement:
# "Melhore este prompt para geração de imagem: [prompt]"
```

---

## 📚 Documentação Completa

- **Todos os MCPs**: Ver `06-solucoes-criacao-imagens-videos-claude-code.md`
- **Setup detalhado**: Ver `05-configuracao-mcp-guia-instalacao.md`
- **Índice completo**: Ver `README.md`

---

## ⚡ Comandos Úteis

```bash
# Listar MCPs instalados
ls -la .clauderc

# Ver configuração
cat .clauderc

# Adicionar novo MCP
claude mcp add [nome] --args [...]

# Testar MCP
npx [package-name] --help
```

---

## 🎨 Próximos Passos

1. [ ] Escolha uma opção de setup acima
2. [ ] Teste com prompt simples
3. [ ] Refine prompts para melhores resultados
4. [ ] Explore outros MCPs conforme necessidade
5. [ ] Crie workflows automatizados

---

**Dica**: Comece com Hugging Face (grátis) para aprender, depois migre para serviços pagos quando precisar de qualidade/velocidade.

**Última atualização**: Janeiro 2025
