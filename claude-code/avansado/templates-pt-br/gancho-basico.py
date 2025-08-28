#!/usr/bin/env python3
"""
[TEMPLATE] [PORTUGUES-BR]
Gancho básico para logging de operações do Claude Code
Adapte este template para suas necessidades específicas
"""

import json
import sys
from datetime import datetime
from pathlib import Path

class GanchoBasico:
    """Classe base para implementação de ganchos em PT-BR"""
    
    def __init__(self):
        self.contexto = self.carregar_contexto()
        self.diretorio_logs = Path('.claude/logs')
        self.diretorio_logs.mkdir(parents=True, exist_ok=True)
        
    def carregar_contexto(self) -> dict:
        """Carrega contexto do stdin"""
        try:
            entrada = sys.stdin.read()
            return json.loads(entrada) if entrada else {}
        except json.JSONDecodeError:
            return {}
    
    def registrar_evento(self, tipo_evento: str, dados: dict):
        """Registra evento em arquivo de log"""
        evento = {
            'timestamp': datetime.now().isoformat(),
            'tipo': tipo_evento,
            'ferramenta': self.contexto.get('tool', 'desconhecida'),
            'dados': dados
        }
        
        # Salva em arquivo diário
        arquivo_log = self.diretorio_logs / f"eventos_{datetime.now().strftime('%Y-%m-%d')}.jsonl"
        
        with open(arquivo_log, 'a', encoding='utf-8') as f:
            f.write(json.dumps(evento, ensure_ascii=False) + '\n')
        
        return evento
    
    def executar(self):
        """Método principal do gancho"""
        # Registra o evento
        evento = self.registrar_evento(
            tipo_evento='execucao_ferramenta',
            dados={
                'entrada': self.contexto.get('input', {}),
                'proposito': self.contexto.get('purpose', 'não especificado')
            }
        )
        
        # Log para debug (remova em produção)
        if Path('.claude/debug').exists():
            print(f"[GANCHO] Evento registrado: {evento['tipo']}", file=sys.stderr)
        
        # Sempre retorna sucesso para não bloquear execução
        sys.exit(0)

if __name__ == "__main__":
    gancho = GanchoBasico()
    gancho.executar()