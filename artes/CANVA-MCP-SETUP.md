# 🎨 Canva - Opções para Automação de Designs

## ⚠️ ATUALIZAÇÃO IMPORTANTE

O **Canva Dev MCP** (agora instalado) é para DESENVOLVIMENTO de apps Canva, não para criar designs automaticamente.

## ✅ O Que Está Instalado
- **Canva Dev MCP**: `@canva/cli` (v1.3.0) ✅
- **Propósito**: Desenvolvimento de apps/integrações Canva
- **Não cria designs diretamente na conta**

## 🔑 Obter API Key do Canva

### Passo 1: Acessar Canva Developers
1. Acesse: https://www.canva.dev/
2. Faça login com sua conta Canva
3. Vá em "My Apps" ou "Create an App"

### Passo 2: Criar Aplicação
1. Clique em "Create an App"
2. Preencha informações básicas:
   - **App Name**: "Automação Claude Code"
   - **Description**: "Automação de designs via MCP"
   - **App Type**: Integration

### Passo 3: Obter Credenciais
1. Após criar o app, copie:
   - **Client ID**
   - **Client Secret**
   - **API Key** (se disponível)

### Passo 4: Configurar Permissões
Habilite permissões necessárias:
- ✅ Read designs
- ✅ Create designs
- ✅ Edit designs
- ✅ Export designs
- ✅ Access user library

## ⚙️ Configurar no Claude Code

### Atualizar .clauderc

```json
{
  "mcp": {
    "servers": {
      "canva": {
        "command": "npx",
        "args": ["-y", "@canva/mcp-server"],
        "description": "Canva MCP - Criação e edição de designs",
        "env": {
          "CANVA_API_KEY": "sua-api-key-aqui",
          "CANVA_CLIENT_ID": "seu-client-id-aqui",
          "CANVA_CLIENT_SECRET": "seu-client-secret-aqui"
        }
      }
    }
  }
}
```

## 🚀 Como Usar Após Configuração

### Criar Designs
```
Crie um post para Instagram 1080x1080 com:
- Fundo gradiente azul
- Texto "Promoção" em destaque
- Logo da empresa no canto
```

### Editar Designs
```
Abra meu último design do Canva e mude:
- Cor do fundo para roxo
- Fonte para mais moderna
- Adicione sombra ao texto
```

### Gerar Variações
```
Crie 5 variações do meu template de post:
- Mesma estrutura
- Cores diferentes (paleta de marca)
- Textos personalizados de planilha CSV
```

### Export Automatizado
```
Exporte todos os designs da pasta "Social Media Q1" em:
- PNG para Instagram
- PDF para impressão
- JPG otimizado para web
```

## 📊 Comparação: Adobe Express vs Canva MCP

| Recurso | Adobe Express MCP | Canva MCP |
|---------|-------------------|-----------|
| **Criar designs direto** | ❌ Não | ✅ Sim |
| **Acessa sua conta** | ❌ Não | ✅ Sim |
| **Templates** | ❌ (só doc) | ✅ Usa seus templates |
| **Export automático** | ❌ | ✅ Múltiplos formatos |
| **Propósito** | Dev add-ons | Automação de designs |
| **Setup** | ✅ Simples | 🔑 Requer API key |

## 🎯 Casos de Uso do Canva MCP

### Social Media em Massa
```python
# Conceitual
designs = []
for post_data in csv_data:
    design = canva.create_from_template(
        template_id="abc123",
        replacements={
            "title": post_data["title"],
            "date": post_data["date"],
            "image": post_data["image_url"]
        }
    )
    designs.append(design)

# Export todos
canva.export_batch(designs, format="png")
```

### A/B Testing de Designs
```
Crie 3 variações do banner de promoção:
- Variação A: CTA "Compre Agora"
- Variação B: CTA "Aproveite"
- Variação C: CTA "Garanta o Seu"
Mantenha restante igual
```

### Localização de Conteúdo
```
Para cada idioma [pt, en, es]:
- Duplique design base
- Traduza textos
- Ajuste tamanho de fonte se necessário
- Exporte com nome design_[idioma].png
```

## 🔗 Recursos Oficiais

- **Canva Developers**: https://www.canva.dev/
- **API Documentation**: https://www.canva.dev/docs/
- **MCP Server Docs**: https://www.canva.dev/docs/connect/mcp-server/
- **Templates**: https://www.canva.com/templates/

## ⚠️ Limitações

### Rate Limits
- API do Canva tem limites de requisições
- Verifique plano (Free vs Pro vs Enterprise)
- Considere delays entre requisições em batch

### Recursos Premium
- Alguns templates requerem Canva Pro
- Elementos premium não disponíveis em plano free
- Fontes especiais podem ter restrições

## 🆚 Quando Usar Cada MCP

### Use Adobe Express MCP quando:
- ✅ Desenvolver add-ons customizados
- ✅ Aprender APIs do Adobe Express
- ✅ Criar ferramentas para outros usuários
- ✅ Integração enterprise com Adobe

### Use Canva MCP quando:
- ✅ Criar designs rapidamente
- ✅ Automatizar posts para redes sociais
- ✅ Gerar variações de templates
- ✅ Workflow de design em escala

### Use Photoshop MCP quando:
- ✅ Edição avançada de imagens
- ✅ Batch processing de fotos
- ✅ Efeitos e filtros complexos
- ✅ Composições profissionais

## 📝 Próximos Passos

1. [ ] Obter API Key do Canva
2. [ ] Atualizar `.clauderc` com credenciais
3. [ ] Testar criação de design simples
4. [ ] Explorar templates disponíveis
5. [ ] Criar workflow de automação

---

**Nota**: O Canva MCP permite criação DIRETA de designs na sua conta, diferente do Adobe Express MCP que é apenas para desenvolvimento.
