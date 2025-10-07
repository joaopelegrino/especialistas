# 09. MCP Servers e Custom Tools

> **Integre Claude Code com ferramentas externas via Model Context Protocol**

## O que é MCP

**Model Context Protocol** é um padrão open-source para integrar AI tools com serviços externos.

MCP servers dão ao Claude Code acesso a:
- ✅ Databases (PostgreSQL, MongoDB, etc)
- ✅ APIs (GitHub, Linear, Slack, etc)
- ✅ Search engines (Perplexity, Brave, etc)
- ✅ File systems remotos
- ✅ Custom tools que você criar

## Configuração

### Método 1: CLI (oficial)

```bash
claude mcp add github \
  --env GITHUB_TOKEN=ghp_... \
  -- npx -y @modelcontextprotocol/server-github
```

### Método 2: Direct Config (recomendado)

**~/.claude.json** ou **.claude/settings.json**:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_..."
      }
    }
  }
}
```

## Tipos de Servers

### stdio (mais comum)

```json
{
  "my-tool": {
    "type": "stdio",
    "command": "node",
    "args": ["/path/to/server.js"]
  }
}
```

### SSE (Server-Sent Events)

```json
{
  "remote-tool": {
    "type": "sse",
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer ..."
    }
  }
}
```

### HTTP

```json
{
  "http-tool": {
    "type": "http",
    "url": "https://api.example.com/mcp"
  }
}
```

## Exemplos Populares

### GitHub

```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {"GITHUB_TOKEN": "ghp_..."}
  }
}
```

**Tools available**: Get issues, create PRs, manage repos

### Perplexity Search

```json
{
  "perplexity": {
    "command": "npx",
    "args": ["-y", "perplexity-mcp"],
    "env": {"PERPLEXITY_API_KEY": "pplx_..."}
  }
}
```

### PostgreSQL

```json
{
  "postgres": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres"],
    "env": {
      "DATABASE_URL": "postgresql://localhost/mydb"
    }
  }
}
```

## Custom MCP Server

### Python Example

```python
# my_mcp_server.py
from mcp.server import Server, Tool
import asyncio

server = Server("my-custom-server")

@server.tool("calculate", "Perform calculations", {"expression": str})
async def calculate(expression: str):
    result = eval(expression)
    return {"result": result}

if __name__ == "__main__":
    asyncio.run(server.run())
```

### TypeScript Example

```typescript
// my-mcp-server.ts
import { Server } from "@modelcontextprotocol/sdk";

const server = new Server({
  name: "my-custom-server",
  version: "1.0.0"
});

server.addTool({
  name: "translate",
  description: "Translate text",
  inputSchema: {
    type: "object",
    properties: {
      text: { type: "string" },
      target: { type: "string" }
    }
  },
  handler: async ({ text, target }) => {
    // Translation logic
    return { translated: result };
  }
});

server.run();
```

### Configuration

```json
{
  "my-tool": {
    "command": "node",
    "args": ["./dist/my-mcp-server.js"]
  }
}
```

## Agent SDK - In-Process MCP

### Python SDK

```python
from claude_agent_sdk import tool, create_sdk_mcp_server, query, ClaudeAgentOptions

@tool("weather", "Get weather", {"city": str})
async def get_weather(args):
    # API call
    return {"content": [{"type": "text", "text": f"Weather in {args['city']}: Sunny"}]}

server = create_sdk_mcp_server("weather-server", tools=[get_weather])

options = ClaudeAgentOptions(
    mcp_servers={"weather": server},
    allowed_tools=["mcp__weather__weather"]
)

async for message in query("What's the weather in SF?", options=options):
    print(message)
```

## Tool Naming

MCP tools são nomeados: `mcp__<server-name>__<tool-name>`

```json
{
  "allowedTools": [
    "mcp__github__get_issue",
    "mcp__github__create_pr",
    "mcp__postgres__query"
  ]
}
```

## Scopes

| Scope | Localização | Uso |
|-------|-------------|-----|
| User | `~/.claude.json` | Personal tools across projects |
| Project | `.claude/settings.json` | Team-shared servers |
| Local | `.claude/settings.local.json` | Personal project overrides |

## Best Practices

✅ **Use environment variables** para secrets
✅ **Version control** project MCP configs
✅ **Document** custom servers para time
⚠️ **Security**: Validate all external inputs
⚠️ **Rate limiting**: Respect API limits

---

**Referências**:
- [MCP Docs](https://modelcontextprotocol.io)
- [Claude Code MCP Integration](https://docs.claude.com/en/docs/claude-code/mcp)
- [fontes.md](../fontes.md) - Agent SDK API

**Anterior**: [08. Configuração Settings ←](08-configuracao-settings.md) | **Próximo**: [10. Exemplos Práticos →](10-exemplos-praticos.md)
