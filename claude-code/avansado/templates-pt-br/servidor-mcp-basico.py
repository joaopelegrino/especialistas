#!/usr/bin/env python3
"""
[TEMPLATE] [PORTUGUES-BR] [MCP-SERVER]
Servidor MCP básico em Python para automação
Baseado na especificação do Model Context Protocol
"""

import json
import sys
import asyncio
from typing import Any, Dict, List

class ServidorMCPBasico:
    """Servidor MCP minimalista em português"""
    
    def __init__(self):
        self.nome = "automacao-basica"
        self.versao = "1.0.0"
        self.ferramentas = self.definir_ferramentas()
        self.prompts = self.definir_prompts()
        
    def definir_ferramentas(self) -> List[Dict]:
        """Define ferramentas disponíveis no servidor"""
        return [
            {
                "nome": "listar_arquivos",
                "descricao": "Lista arquivos em um diretório",
                "parametros": {
                    "caminho": {
                        "tipo": "string",
                        "descricao": "Caminho do diretório",
                        "obrigatorio": True
                    }
                }
            },
            {
                "nome": "criar_automacao",
                "descricao": "Cria automação para tarefa repetitiva",
                "parametros": {
                    "padrao": {
                        "tipo": "string", 
                        "descricao": "Padrão detectado",
                        "obrigatorio": True
                    },
                    "tipo": {
                        "tipo": "string",
                        "descricao": "Tipo de automação (gancho|script|mcp)",
                        "obrigatorio": True
                    }
                }
            }
        ]
    
    def definir_prompts(self) -> List[Dict]:
        """Define prompts reutilizáveis"""
        return [
            {
                "nome": "analisar_projeto",
                "descricao": "Analisa estrutura e padrões do projeto",
                "template": """
                Analise o projeto atual e identifique:
                1. Estrutura de diretórios
                2. Padrões de código utilizados
                3. Oportunidades de automação
                4. Configurações existentes
                """
            },
            {
                "nome": "sugerir_evolucao",
                "descricao": "Sugere próximas evoluções para o sistema",
                "template": """
                Baseado no uso atual, sugira:
                1. Próximos ganchos a implementar
                2. Automações que trariam benefícios
                3. Métricas importantes a coletar
                """
            }
        ]
    
    async def executar_ferramenta(self, nome: str, parametros: Dict) -> Dict:
        """Executa uma ferramenta específica"""
        
        if nome == "listar_arquivos":
            # Implementação simplificada
            from pathlib import Path
            caminho = Path(parametros["caminho"])
            
            if not caminho.exists():
                return {"erro": f"Caminho não existe: {caminho}"}
                
            arquivos = [str(f) for f in caminho.iterdir()]
            return {"arquivos": arquivos, "total": len(arquivos)}
            
        elif nome == "criar_automacao":
            # Template de criação de automação
            padrao = parametros["padrao"]
            tipo = parametros["tipo"]
            
            conteudo_automacao = self.gerar_automacao(padrao, tipo)
            
            return {
                "sucesso": True,
                "mensagem": f"Automação {tipo} criada para padrão: {padrao}",
                "conteudo": conteudo_automacao
            }
            
        return {"erro": f"Ferramenta não encontrada: {nome}"}
    
    def gerar_automacao(self, padrao: str, tipo: str) -> str:
        """Gera código de automação baseado no tipo"""
        
        if tipo == "gancho":
            return f"""
# Gancho automático para: {padrao}
import json
import sys

def processar_{padrao.replace(' ', '_')}():
    contexto = json.loads(sys.stdin.read())
    # Implementar lógica específica
    print(f"Processando {padrao}: {{contexto}}")
    
if __name__ == "__main__":
    processar_{padrao.replace(' ', '_')}()
"""
        
        elif tipo == "script":
            return f"""
#!/bin/bash
# Script automático para: {padrao}
echo "Executando automação: {padrao}"
# Adicionar comandos específicos
"""
        
        return f"# Template para {tipo}: {padrao}"
    
    def processar_mensagem(self, mensagem: Dict) -> Dict:
        """Processa mensagem do protocolo MCP"""
        
        tipo_msg = mensagem.get("type")
        
        if tipo_msg == "initialize":
            return {
                "type": "initialized",
                "serverInfo": {
                    "name": self.nome,
                    "version": self.versao
                },
                "capabilities": {
                    "tools": self.ferramentas,
                    "prompts": self.prompts
                }
            }
            
        elif tipo_msg == "tools/call":
            nome_ferramenta = mensagem.get("tool")
            parametros = mensagem.get("params", {})
            
            resultado = asyncio.run(
                self.executar_ferramenta(nome_ferramenta, parametros)
            )
            
            return {
                "type": "tools/result",
                "result": resultado
            }
            
        return {"type": "error", "message": f"Tipo não suportado: {tipo_msg}"}
    
    def executar(self):
        """Loop principal do servidor"""
        print(f"[SERVIDOR-MCP] {self.nome} v{self.versao} iniciado", file=sys.stderr)
        
        try:
            while True:
                # Lê mensagem do stdin
                linha = sys.stdin.readline()
                if not linha:
                    break
                    
                try:
                    mensagem = json.loads(linha)
                    resposta = self.processar_mensagem(mensagem)
                    
                    # Envia resposta para stdout
                    print(json.dumps(resposta))
                    sys.stdout.flush()
                    
                except json.JSONDecodeError:
                    print(json.dumps({
                        "type": "error",
                        "message": "JSON inválido"
                    }))
                    
        except KeyboardInterrupt:
            print("[SERVIDOR-MCP] Encerrando...", file=sys.stderr)

if __name__ == "__main__":
    servidor = ServidorMCPBasico()
    servidor.executar()