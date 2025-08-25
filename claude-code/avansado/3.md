# Sistema de Hooks e Interceptação - Implementação Completa

## 🎣 Visão Geral dos Hooks

O sistema de hooks permite interceptar e observar eventos críticos do Claude Code em tempo real, possibilitando validação, logging, e orquestração de múltiplos agentes.

## 📋 Tipos de Hooks Disponíveis

### Hooks Oficiais do Claude Code

| Hook | Trigger | Uso Principal | Dados Capturados |
|------|---------|---------------|------------------|
| **PreToolUse** | Antes de executar ferramenta | Validação, bloqueio | Tool name, inputs, context |
| **PostToolUse** | Após execução de ferramenta | Logging, métricas | Results, execution time |
| **Notification** | Interação com usuário | UX tracking | Message type, content |
| **Stop** | Fim de resposta | Aggregation | Final state, tokens used |
| **SubagentStop** | Fim de sub-agente | Orchestration | Sub-agent results |

*Fonte: [Anthropic Hooks Reference](https://docs.anthropic.com/en/docs/claude-code/hooks)*

## 🔧 Configuração Base

### 1. Estrutura de Diretórios

```bash
project-root/
├── .claude/
│   ├── settings.json          # Configuração principal
│   ├── hooks/
│   │   ├── __init__.py
│   │   ├── pre_tool_use.py    # Validação pré-execução
│   │   ├── post_tool_use.py   # Logging pós-execução
│   │   ├── send_event.py      # Envio para observability
│   │   ├── aggregate.py       # Agregação de resultados
│   │   └── requirements.txt   # Dependências Python
│   └── commands/
│       ├── orchestrate.md     # Comando de orquestração
│       └── status.md          # Comando de status
```

### 2. Configuração Principal (settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/pre_tool_use.py"
          },
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type PreToolUse --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/post_tool_use.py"
          },
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type PostToolUse --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/aggregate.py"
          },
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type SubagentStop --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "uv run .claude/hooks/send_event.py --event-type Stop --source-app ${PROJECT_NAME}"
          }
        ]
      }
    ]
  },
  "orchestration": {
    "enabled": true,
    "orchestrator_url": "http://localhost:4000",
    "session_tracking": true,
    "aggregate_results": true
  }
}
```

## 📝 Implementação dos Hooks

### Hook 1: Validação Pré-Execução (pre_tool_use.py)

```python
#!/usr/bin/env python3
"""
Hook de validação pré-execução de ferramentas.
Bloqueia comandos perigosos e valida inputs.
"""

import json
import sys
import re
from typing import Dict, Any, List
from pathlib import Path

# Padrões de comandos perigosos
DANGEROUS_PATTERNS = [
    r'rm\s+-rf\s+/',           # Remove recursivo da raiz
    r':(){ :|:& };:',          # Fork bomb
    r'dd\s+if=/dev/zero',      # Disk destroyer
    r'chmod\s+777\s+/',        # Permissões perigosas
    r'curl.*\|\s*bash',        # Script execution remoto
    r'wget.*\|\s*sh',          # Script execution remoto
]

# Comandos que requerem confirmação
CONFIRM_REQUIRED = [
    'npm install',
    'pip install',
    'apt-get install',
    'brew install',
]

class PreToolUseValidator:
    def __init__(self):
        self.context = self.load_context()
        
    def load_context(self) -> Dict[str, Any]:
        """Carrega contexto do stdin"""
        try:
            return json.loads(sys.stdin.read())
        except json.JSONDecodeError:
            return {}
    
    def validate_command(self, command: str) -> tuple[bool, str]:
        """Valida comando para segurança"""
        # Check dangerous patterns
        for pattern in DANGEROUS_PATTERNS:
            if re.search(pattern, command, re.IGNORECASE):
                return False, f"Comando bloqueado por segurança: {pattern}"
        
        # Check if confirmation needed
        for confirm_cmd in CONFIRM_REQUIRED:
            if confirm_cmd in command.lower():
                # Em produção, implementar confirmação interativa
                return True, f"Comando requer confirmação: {command}"
        
        return True, "Comando validado"
    
    def validate_tool_use(self) -> Dict[str, Any]:
        """Valida uso da ferramenta"""
        tool_name = self.context.get('tool', '')
        tool_input = self.context.get('input', {})
        
        # Validação específica por ferramenta
        if tool_name == 'execute_command':
            command = tool_input.get('command', '')
            is_valid, message = self.validate_command(command)
            
            if not is_valid:
                return {
                    'action': 'block',
                    'reason': message,
                    'alternative': self.suggest_alternative(command)
                }
        
        elif tool_name == 'write_file':
            path = tool_input.get('path', '')
            if self.is_sensitive_file(path):
                return {
                    'action': 'block',
                    'reason': f'Arquivo sensível: {path}',
                    'alternative': 'Use arquivo em diretório seguro'
                }
        
        return {'action': 'allow', 'validated': True}
    
    def is_sensitive_file(self, path: str) -> bool:
        """Verifica se é arquivo sensível"""
        sensitive_paths = [
            '/etc/passwd',
            '/etc/shadow',
            '.env',
            '.aws/credentials',
            '.ssh/id_rsa',
            'settings.json',
        ]
        
        path_obj = Path(path)
        for sensitive in sensitive_paths:
            if sensitive in str(path_obj):
                return True
        return False
    
    def suggest_alternative(self, command: str) -> str:
        """Sugere alternativa segura"""
        if 'rm -rf' in command:
            return "Use 'rm -i' para confirmação interativa"
        elif 'chmod 777' in command:
            return "Use permissões mais restritivas (ex: 755)"
        return "Revise o comando para garantir segurança"
    
    def run(self):
        """Executa validação"""
        result = self.validate_tool_use()
        
        # Log para observability
        self.log_validation(result)
        
        # Retorna resultado
        if result['action'] == 'block':
            print(json.dumps(result))
            sys.exit(1)  # Bloqueia execução
        else:
            sys.exit(0)  # Permite execução
    
    def log_validation(self, result: Dict[str, Any]):
        """Registra validação para auditoria"""
        log_entry = {
            'timestamp': self.get_timestamp(),
            'tool': self.context.get('tool'),
            'validation_result': result,
            'session_id': self.context.get('session_id'),
            'agent_id': self.context.get('agent_id'),
        }
        
        # Enviar para sistema de observability
        # Implementar envio async para não bloquear
        pass
    
    def get_timestamp(self) -> str:
        from datetime import datetime
        return datetime.utcnow().isoformat()

if __name__ == "__main__":
    validator = PreToolUseValidator()
    validator.run()
```

### Hook 2: Envio de Eventos (send_event.py)

```python
#!/usr/bin/env python3
"""
Hook universal para envio de eventos ao servidor de observabilidade.
Compatível com todos os tipos de eventos do Claude Code.
"""

import json
import sys
import argparse
import asyncio
import httpx
from datetime import datetime
from typing import Dict, Any, Optional
import os
import hashlib

class EventSender:
    def __init__(self, event_type: str, source_app: str):
        self.event_type = event_type
        self.source_app = source_app
        self.server_url = os.getenv('ORCHESTRATOR_URL', 'http://localhost:4000')
        self.session_id = self.get_or_create_session_id()
        self.context = self.load_context()
    
    def load_context(self) -> Dict[str, Any]:
        """Carrega contexto do stdin"""
        try:
            input_data = sys.stdin.read()
            if input_data:
                return json.loads(input_data)
            return {}
        except json.JSONDecodeError:
            return {}
    
    def get_or_create_session_id(self) -> str:
        """Obtém ou cria ID de sessão único"""
        session_file = Path('.claude/.session_id')
        
        if session_file.exists():
            return session_file.read_text().strip()
        
        # Gera novo session ID
        session_id = hashlib.sha256(
            f"{datetime.utcnow().isoformat()}-{os.getpid()}".encode()
        ).hexdigest()[:16]
        
        session_file.parent.mkdir(exist_ok=True)
        session_file.write_text(session_id)
        
        return session_id
    
    def build_event(self) -> Dict[str, Any]:
        """Constrói evento completo"""
        event = {
            'type': self.event_type,
            'timestamp': datetime.utcnow().isoformat(),
            'session_id': self.session_id,
            'source_app': self.source_app,
            'agent_id': self.context.get('agent_id', 'unknown'),
            'data': {}
        }
        
        # Adiciona dados específicos por tipo de evento
        if self.event_type == 'PreToolUse':
            event['data'] = {
                'tool': self.context.get('tool'),
                'input': self.context.get('input'),
                'purpose': self.context.get('purpose'),
            }
        
        elif self.event_type == 'PostToolUse':
            event['data'] = {
                'tool': self.context.get('tool'),
                'output': self.context.get('output'),
                'success': self.context.get('success', True),
                'execution_time_ms': self.context.get('execution_time_ms'),
            }
        
        elif self.event_type == 'SubagentStop':
            event['data'] = {
                'subagent_id': self.context.get('subagent_id'),
                'task': self.context.get('task'),
                'result': self.context.get('result'),
                'tokens_used': self.context.get('tokens_used'),
            }
        
        elif self.event_type == 'Stop':
            event['data'] = {
                'final_output': self.context.get('final_output'),
                'total_tokens': self.context.get('total_tokens'),
                'duration_ms': self.context.get('duration_ms'),
            }
        
        elif self.event_type == 'Notification':
            event['data'] = {
                'message': self.context.get('message'),
                'level': self.context.get('level', 'info'),
            }
        
        # Adiciona metadados
        event['metadata'] = {
            'hostname': os.uname().nodename,
            'pid': os.getpid(),
            'python_version': sys.version.split()[0],
            'hook_version': '1.0.0',
        }
        
        return event
    
    async def send_event_async(self, event: Dict[str, Any]) -> bool:
        """Envia evento de forma assíncrona"""
        async with httpx.AsyncClient(timeout=5.0) as client:
            try:
                response = await client.post(
                    f"{self.server_url}/events",
                    json=event,
                    headers={'Content-Type': 'application/json'}
                )
                
                if response.status_code == 200:
                    return True
                else:
                    print(f"Erro ao enviar evento: {response.status_code}", 
                          file=sys.stderr)
                    return False
                    
            except httpx.RequestError as e:
                print(f"Erro de conexão: {e}", file=sys.stderr)
                return False
            except Exception as e:
                print(f"Erro inesperado: {e}", file=sys.stderr)
                return False
    
    def run(self):
        """Executa envio do evento"""
        event = self.build_event()
        
        # Log local para debug
        if os.getenv('DEBUG_HOOKS'):
            print(f"Evento construído: {json.dumps(event, indent=2)}", 
                  file=sys.stderr)
        
        # Envia evento
        success = asyncio.run(self.send_event_async(event))
        
        # Não bloqueia execução mesmo se falhar
        sys.exit(0)

def main():
    parser = argparse.ArgumentParser(description='Envia eventos para observability')
    parser.add_argument('--event-type', required=True, 
                       choices=['PreToolUse', 'PostToolUse', 'SubagentStop', 
                               'Stop', 'Notification'],
                       help='Tipo do evento')
    parser.add_argument('--source-app', required=True,
                       help='Identificador da aplicação/projeto')
    
    args = parser.parse_args()
    
    sender = EventSender(args.event_type, args.source_app)
    sender.run()

if __name__ == "__main__":
    main()
```

### Hook 3: Agregação de Resultados (aggregate.py)

```python
#!/usr/bin/env python3
"""
Hook para agregação de resultados de sub-agentes.
Consolida informações quando múltiplos agentes completam tarefas.
"""

import json
import sys
import asyncio
import httpx
from pathlib import Path
from typing import Dict, Any, List
from datetime import datetime

class ResultAggregator:
    def __init__(self):
        self.context = self.load_context()
        self.results_dir = Path('.claude/results')
        self.results_dir.mkdir(exist_ok=True)
        self.server_url = os.getenv('ORCHESTRATOR_URL', 'http://localhost:4000')
    
    def load_context(self) -> Dict[str, Any]:
        """Carrega contexto do stdin"""
        try:
            return json.loads(sys.stdin.read())
        except json.JSONDecodeError:
            return {}
    
    async def aggregate_subagent_results(self):
        """Agrega resultados de sub-agentes"""
        session_id = self.context.get('session_id')
        subagent_id = self.context.get('subagent_id')
        
        # Salva resultado individual
        result_file = self.results_dir / f"{session_id}_{subagent_id}.json"
        result_file.write_text(json.dumps({
            'subagent_id': subagent_id,
            'timestamp': datetime.utcnow().isoformat(),
            'result': self.context.get('result'),
            'metrics': self.extract_metrics()
        }, indent=2))
        
        # Verifica se todos os sub-agentes completaram
        all_results = await self.check_completion_status(session_id)
        
        if all_results:
            # Agrega todos os resultados
            aggregated = self.perform_aggregation(all_results)
            
            # Envia agregação para servidor
            await self.send_aggregation(aggregated)
            
            # Notifica orquestrador
            await self.notify_orchestrator(aggregated)
    
    def extract_metrics(self) -> Dict[str, Any]:
        """Extrai métricas do resultado"""
        return {
            'tokens_used': self.context.get('tokens_used', 0),
            'execution_time_ms': self.context.get('execution_time_ms', 0),
            'success': self.context.get('success', True),
            'error_count': len(self.context.get('errors', [])),
        }
    
    async def check_completion_status(self, session_id: str) -> Optional[List[Dict]]:
        """Verifica se todos os sub-agentes completaram"""
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.server_url}/aggregations/status",
                params={'session_id': session_id}
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('all_complete'):
                    return data.get('results', [])
        
        return None
    
    def perform_aggregation(self, results: List[Dict]) -> Dict[str, Any]:
        """Realiza agregação dos resultados"""
        aggregated = {
            'session_id': self.context.get('session_id'),
            'timestamp': datetime.utcnow().isoformat(),
            'total_subagents': len(results),
            'successful': sum(1 for r in results if r.get('metrics', {}).get('success')),
            'failed': sum(1 for r in results if not r.get('metrics', {}).get('success')),
            'total_tokens': sum(r.get('metrics', {}).get('tokens_used', 0) for r in results),
            'total_time_ms': sum(r.get('metrics', {}).get('execution_time_ms', 0) for r in results),
            'results': results,
            'summary': self.generate_summary(results)
        }
        
        return aggregated
    
    def generate_summary(self, results: List[Dict]) -> str:
        """Gera resumo dos resultados"""
        summaries = []
        for result in results:
            subagent_id = result.get('subagent_id', 'unknown')
            status = 'SUCCESS' if result.get('metrics', {}).get('success') else 'FAILED'
            summaries.append(f"- {subagent_id}: {status}")
        
        return "\n".join(summaries)
    
    async def send_aggregation(self, aggregated: Dict[str, Any]):
        """Envia agregação para servidor"""
        async with httpx.AsyncClient() as client:
            await client.post(
                f"{self.server_url}/aggregations",
                json=aggregated
            )
    
    async def notify_orchestrator(self, aggregated: Dict[str, Any]):
        """Notifica orquestrador sobre conclusão"""
        notification = {
            'type': 'aggregation_complete',
            'session_id': aggregated['session_id'],
            'summary': aggregated['summary'],
            'metrics': {
                'total_tokens': aggregated['total_tokens'],
                'total_time_ms': aggregated['total_time_ms'],
                'success_rate': aggregated['successful'] / aggregated['total_subagents']
            }
        }
        
        async with httpx.AsyncClient() as client:
            await client.post(
                f"{self.server_url}/orchestrator/notify",
                json=notification
            )
    
    def run(self):
        """Executa agregação"""
        asyncio.run(self.aggregate_subagent_results())

if __name__ == "__main__":
    aggregator = ResultAggregator()
    aggregator.run()
```

## 📦 Dependências (requirements.txt)

```txt
httpx==0.25.0
asyncio==3.4.3
python-dotenv==1.0.0
pydantic==2.0.0
```

## 🚀 Instalação e Setup

### 1. Instalação do Astral uv

```bash
# Linux/macOS
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. Setup do Projeto

```bash
# Clone o repositório base
git clone https://github.com/disler/claude-code-hooks-multi-agent-observability.git
cd claude-code-hooks-multi-agent-observability

# Copie hooks para seu projeto
cp -r .claude /path/to/your/project/

# Instale dependências
cd /path/to/your/project/.claude/hooks
uv pip install -r requirements.txt

# Configure variáveis de ambiente
export ORCHESTRATOR_URL="http://localhost:4000"
export ANTHROPIC_API_KEY="your-key-here"
```

### 3. Teste dos Hooks

```bash
# Teste hook de validação
echo '{"tool": "execute_command", "input": {"command": "ls -la"}}' | \
  uv run .claude/hooks/pre_tool_use.py

# Teste envio de evento
echo '{"tool": "test", "result": "success"}' | \
  uv run .claude/hooks/send_event.py --event-type PostToolUse --source-app test-app
```

## 🎯 Casos de Uso Avançados

### 1. Validação Contextual

```python
# Validação baseada em contexto do projeto
class ContextualValidator(PreToolUseValidator):
    def validate_based_on_project_type(self):
        project_type = self.detect_project_type()
        
        if project_type == 'production':
            # Regras mais rígidas para produção
            self.DANGEROUS_PATTERNS.extend([
                r'DROP\s+DATABASE',
                r'TRUNCATE\s+TABLE',
            ])
        
        elif project_type == 'development':
            # Mais permissivo em dev
            self.CONFIRM_REQUIRED = []
```

### 2. Rate Limiting

```python
# Previne sobrecarga do sistema
class RateLimitedHook:
    def __init__(self, max_events_per_minute=60):
        self.max_events = max_events_per_minute
        self.event_times = []
    
    def check_rate_limit(self) -> bool:
        now = datetime.now()
        # Remove eventos antigos
        self.event_times = [t for t in self.event_times 
                           if (now - t).seconds < 60]
        
        if len(self.event_times) >= self.max_events:
            return False
        
        self.event_times.append(now)
        return True
```

## 📊 Monitoramento de Hooks

### Métricas para Dashboard

```python
# Coleta de métricas dos hooks
HOOK_METRICS = {
    'pre_tool_use_blocks': 0,
    'pre_tool_use_allows': 0,
    'events_sent': 0,
    'events_failed': 0,
    'aggregations_completed': 0,
    'average_latency_ms': 0,
}
```

## 🔗 Referências

1. **Claude Code Hooks Guide**
   - URL: https://docs.anthropic.com/en/docs/claude-code/hooks-guide
   - Tutorial oficial de implementação

2. **Hooks Reference Documentation**
   - URL: https://docs.anthropic.com/en/docs/claude-code/hooks
   - Referência completa da API

3. **Community Examples - @disler**
   - URL: https://github.com/disler/claude-code-hooks-mastery
   - Exemplos avançados da comunidade

4. **Python AsyncIO Best Practices**
   - URL: https://docs.python.org/3/library/asyncio-task.html
   - Patterns assíncronos para hooks

---

**Próximo**: [4. ORCHESTRATION-SERVER - Servidor de Orquestração](./4-orchestration-server.md)
