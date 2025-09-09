graph TD
    %% Início do Processo
    START[🎯 Nova Tarefa de Implementação] --> AGENT[👤 Agente Implementador Ativado]
    
    %% FASE 1: CONTEXTUALIZAÇÃO INICIAL (Destacada)
    AGENT --> PHASE1{{"📚 FASE 1: CONTEXTUALIZAÇÃO INICIAL"}}
    
    PHASE1 --> REQ[📋 Análise de Requisitos]
    REQ --> SEARCH1[🔍 Busca Inicial em Documentação Interna]
    
    SEARCH1 --> DOC1[📖 Consulta Wiki do Projeto]
    SEARCH1 --> DOC2[🏗️ Análise de Arquitetura]
    SEARCH1 --> DOC3[📐 Verificação de Padrões]
    SEARCH1 --> DOC4[🔌 Mapeamento de APIs]
    
    DOC1 --> CONTEXT[📦 Contexto Compilado]
    DOC2 --> CONTEXT
    DOC3 --> CONTEXT
    DOC4 --> CONTEXT
    
    CONTEXT --> READY{Contexto Suficiente?}
    READY -->|Não| SEARCH2[🔎 Busca Adicional]
    SEARCH2 --> SEARCH1
    READY -->|Sim| PHASE2
    
    %% FASE 2: IMPLEMENTAÇÃO
    PHASE2{{"💻 FASE 2: IMPLEMENTAÇÃO"}}
    PHASE2 --> CODEGEN[⚙️ Geração do Código Inicial<br/>Com Base no Contexto]
    
    CODEGEN --> IMPL[📝 Código Implementado]
    
    %% FASE 3: VERIFICAÇÃO
    IMPL --> PHASE3{{"🔬 FASE 3: VERIFICAÇÃO"}}
    
    PHASE3 --> BROWSER[🌐 MCP Browser: Acesso Localhost]
    BROWSER --> VERIFY[✔️ Verificação da Implementação]
    
    VERIFY --> LOGS[📊 Coleta de Logs do Console]
    VERIFY --> VISUAL[👁️ Validação Visual]
    VERIFY --> ERRORS[⚠️ Análise de Erros JS]
    
    LOGS --> ANALYSIS[🔍 Análise de Resultados]
    VISUAL --> ANALYSIS
    ERRORS --> ANALYSIS
    
    ANALYSIS --> CHECK{Implementação OK?}
    
    %% Caminho de Sucesso
    CHECK -->|✅ Sim| SUCCESS[🎉 Implementação Concluída]
    
    %% FASE 4: CORREÇÃO (se necessário)
    CHECK -->|❌ Não| PHASE4{{"🔧 FASE 4: CORREÇÃO"}}
    
    PHASE4 --> ERRORANALYSIS[🔬 Análise Detalhada dos Erros]
    ERRORANALYSIS --> DOCSEARCH[📚 Nova Busca em Documentação<br/>Focada no Problema]
    
    DOCSEARCH --> SOLUTIONS[💡 Identificação de Soluções]
    SOLUTIONS --> FIX[🛠️ Aplicação de Correções]
    
    FIX --> RETEST[🔄 Nova Verificação via Browser]
    RETEST --> NEWLOGS[📊 Coleta de Novos Logs]
    NEWLOGS --> FIXED{Problema Resolvido?}
    
    FIXED -->|Sim| SUCCESS
    FIXED -->|Não| ATTEMPTS{Tentativas < 3?}
    
    ATTEMPTS -->|Sim| STRATEGY[🎯 Nova Estratégia]
    STRATEGY --> ERRORANALYSIS
    
    ATTEMPTS -->|Não| ESCALATE[⚠️ Escalação para Revisão Humana]
    ESCALATE --> REPORT[📝 Relatório Detalhado]
    REPORT --> END[🏁 Processo Finalizado com Pendências]
    
    %% Subgraphs para recursos
    subgraph DOCS["🏛️ Base de Documentação Interna"]
        direction TB
        WIKI[Wiki do Projeto]
        ARCH[Guias de Arquitetura]
        STANDARDS[Padrões de Código]
        APIS[Documentação de APIs]
        EXAMPLES[Exemplos de Implementação]
        HISTORY[Histórico de Soluções]
    end
    
    subgraph TOOLS["🔧 Ferramentas de Busca"]
        direction TB
        ENGINE[Search Engine Interno]
        FETCH[URL Fetch de Docs]
        SEMANTIC[Busca Semântica]
        INDEX[Indexação de Conteúdo]
    end
    
    subgraph MCP["🌐 MCP Browser Features"]
        direction TB
        LOCAL[Acesso ao Localhost]
        CONSOLE[Captura de Console Logs]
        SCREEN[Screenshot da Interface]
        RUNTIME[Análise de Erros Runtime]
        PERF[Verificação de Performance]
        NETWORK[Monitoramento de Network]
    end
    
    %% Conexões com recursos
    SEARCH1 -.-> TOOLS
    SEARCH2 -.-> TOOLS
    DOCSEARCH -.-> TOOLS
    
    SEARCH1 -.-> DOCS
    SEARCH2 -.-> DOCS
    DOCSEARCH -.-> DOCS
    
    BROWSER -.-> MCP
    RETEST -.-> MCP
    
    %% Estilos para destacar as fases
    classDef phase fill:#2196F3,stroke:#1565C0,stroke-width:3px,color:#fff,font-weight:bold
    classDef contextPhase fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    classDef implementPhase fill:#FF9800,stroke:#E65100,stroke-width:2px,color:#fff
    classDef verifyPhase fill:#9C27B0,stroke:#6A1B9A,stroke-width:2px,color:#fff
    classDef fixPhase fill:#F44336,stroke:#B71C1C,stroke-width:2px,color:#fff
    classDef success fill:#8BC34A,stroke:#558B2F,stroke-width:2px,color:#fff
    classDef resource fill:#E3F2FD,stroke:#1976D2,stroke-width:1px
    
    class PHASE1 phase
    class PHASE2 phase
    class PHASE3 phase
    class PHASE4 phase
    class REQ,SEARCH1,DOC1,DOC2,DOC3,DOC4,CONTEXT contextPhase
    class CODEGEN,IMPL implementPhase
    class BROWSER,VERIFY,LOGS,VISUAL,ERRORS verifyPhase
    class ERRORANALYSIS,DOCSEARCH,SOLUTIONS,FIX fixPhase
    class SUCCESS success
    class DOCS,TOOLS,MCP resource
