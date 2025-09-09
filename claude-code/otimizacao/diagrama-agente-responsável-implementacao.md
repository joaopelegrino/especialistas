graph TD
    %% Início do Processo
    START[🎯 Nova Tarefa de Implementação] --> AGENT[👤 Agente Implementador Ativado]
    
    %% FASE 1: CONTEXTUALIZAÇÃO INICIAL (Destacada)
    AGENT --> PHASE1{{"📚 FASE 1: CONTEXTUALIZAÇÃO INICIAL"}}
    
    PHASE1 --> REQ[📋 Recebe Documento de Requisitos<br/>com Checklist e Especificações]
    REQ --> SEARCH1[🔍 Busca Inicial em Documentação Interna]
    
    SEARCH1 --> DOC1[📖 Consulta Wiki do Projeto]
    SEARCH1 --> DOC2[🏗️ Análise de Arquitetura]
    SEARCH1 --> DOC3[📐 Verificação de Padrões]
    SEARCH1 --> DOC4[🔌 Mapeamento de APIs]
    
    DOC1 --> CONTEXT[📦 Contexto Compilado<br/>+ Documentos Referenciados]
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
    
    CODEGEN --> IMPL[📝 Código Implementado<br/>+ Log de Decisões]
    
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
    
    %% FASE 4: CORREÇÃO (se necessário)
    CHECK -->|❌ Não| PHASE4{{"🔧 FASE 4: CORREÇÃO"}}
    
    PHASE4 --> ERRORANALYSIS[🔬 Análise Detalhada dos Erros]
    ERRORANALYSIS --> DOCSEARCH[📚 Nova Busca em Documentação<br/>Focada no Problema]
    
    DOCSEARCH --> SOLUTIONS[💡 Identificação de Soluções]
    SOLUTIONS --> FIX[🛠️ Aplicação de Correções]
    
    FIX --> RETEST[🔄 Nova Verificação via Browser]
    RETEST --> NEWLOGS[📊 Coleta de Novos Logs]
    NEWLOGS --> FIXED{Problema Resolvido?}
    
    FIXED -->|Sim| PHASE5
    FIXED -->|Não| ATTEMPTS{Tentativas < 3?}
    
    ATTEMPTS -->|Sim| STRATEGY[🎯 Nova Estratégia]
    STRATEGY --> ERRORANALYSIS
    
    ATTEMPTS -->|Não| ESCALATE[⚠️ Escalação para Revisão Humana]
    ESCALATE --> ESCALATE_REPORT[📝 Relatório de Problemas]
    ESCALATE_REPORT --> PHASE5
    
    %% FASE 5: ATUALIZAÇÃO DO DOCUMENTO DE REQUISITOS
    CHECK -->|✅ Sim| PHASE5{{"✏️ FASE 5: ATUALIZAÇÃO DO DOC DE REQUISITOS"}}
    
    PHASE5 --> OPEN_DOC[📄 Abre Documento de Requisitos Original]
    
    OPEN_DOC --> DIARY[📓 Adiciona Seção: Diário de Implementação]
    
    DIARY --> CHECK_UPDATE[☑️ Atualiza Checklist<br/>✅ Marca itens concluídos<br/>⚠️ Anota pendências]
    
    CHECK_UPDATE --> IMPL_NOTES[📝 Adiciona Notas de Implementação]
    
    IMPL_NOTES --> NOTE1[💻 Decisões Técnicas Tomadas<br/>Como foi implementado e por quê]
    IMPL_NOTES --> NOTE2[📚 Documentações Utilizadas<br/>Links e referências consultadas]
    IMPL_NOTES --> NOTE3[🔍 Dificuldades Encontradas<br/>Problemas e como foram resolvidos]
    IMPL_NOTES --> NOTE4[⏱️ Tempo Gasto<br/>Por fase/tarefa]
    
    NOTE1 --> FEEDBACK_SECTION[💭 Adiciona Seção: Feedback]
    NOTE2 --> FEEDBACK_SECTION
    NOTE3 --> FEEDBACK_SECTION
    NOTE4 --> FEEDBACK_SECTION
    
    FEEDBACK_SECTION --> FB1[✅ Docs que Ajudaram<br/>Quais foram úteis e por quê]
    FEEDBACK_SECTION --> FB2[❌ Docs que Faltaram<br/>O que seria útil ter]
    FEEDBACK_SECTION --> FB3[🔄 Docs Desatualizados<br/>O que precisa ser corrigido]
    FEEDBACK_SECTION --> FB4[💡 Sugestões<br/>Melhorias para próximas implementações]
    
    FB1 --> RECOMMENDATIONS[📋 Adiciona Seção: Recomendações]
    FB2 --> RECOMMENDATIONS
    FB3 --> RECOMMENDATIONS
    FB4 --> RECOMMENDATIONS
    
    RECOMMENDATIONS --> REC1[📚 Proposta de Nova Documentação<br/>O que deveria ser criado]
    RECOMMENDATIONS --> REC2[🔧 Melhorias em Docs Existentes<br/>O que precisa ser atualizado]
    RECOMMENDATIONS --> REC3[📐 Novos Padrões Identificados<br/>Patterns que emergiram]
    RECOMMENDATIONS --> REC4[⚠️ Alertas para Próximas Implementações<br/>Cuidados e armadilhas]
    
    REC1 --> SAVE[💾 Salva Documento Atualizado]
    REC2 --> SAVE
    REC3 --> SAVE
    REC4 --> SAVE
    
    SAVE --> NOTIFY[📢 Notifica Conclusão<br/>Doc de requisitos atualizado disponível]
    
    NOTIFY --> SUCCESS[🎉 Implementação Concluída<br/>+ Documento de Requisitos Enriquecido]
    
    %% Documento de Requisitos - Estrutura
    subgraph REQDOC["📋 DOCUMENTO DE REQUISITOS"]
        direction TB
        ORIGINAL[Seção Original:<br/>- Especificações<br/>- Checklist de Tarefas<br/>- Critérios de Aceitação]
        ADDED[Seções Adicionadas pelo Agente:<br/>- Diário de Implementação<br/>- Notas Técnicas<br/>- Feedback sobre Docs<br/>- Recomendações]
        ORIGINAL -.-> ADDED
    end
    
    %% Base de Documentação (Apenas Leitura)
    subgraph DOCS["🏛️ Base de Documentação Interna (LEITURA)"]
        direction TB
        WIKI[Wiki do Projeto]
        ARCH[Guias de Arquitetura]
        STANDARDS[Padrões de Código]
        APIS[Documentação de APIs]
        EXAMPLES[Exemplos de Implementação]
        HISTORY[Histórico de Soluções]
    end
    
    %% Ferramentas
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
    
    SEARCH1 -.->|Apenas Leitura| DOCS
    SEARCH2 -.->|Apenas Leitura| DOCS
    DOCSEARCH -.->|Apenas Leitura| DOCS
    
    REQ -.->|Recebe| REQDOC
    OPEN_DOC -.->|Atualiza| REQDOC
    
    BROWSER -.-> MCP
    RETEST -.-> MCP
    
    %% Estilos para destacar as fases
    classDef phase fill:#2196F3,stroke:#1565C0,stroke-width:3px,color:#fff,font-weight:bold
    classDef contextPhase fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    classDef implementPhase fill:#FF9800,stroke:#E65100,stroke-width:2px,color:#fff
    classDef verifyPhase fill:#9C27B0,stroke:#6A1B9A,stroke-width:2px,color:#fff
    classDef fixPhase fill:#F44336,stroke:#B71C1C,stroke-width:2px,color:#fff
    classDef updatePhase fill:#00BCD4,stroke:#00838F,stroke-width:2px,color:#fff
    classDef success fill:#8BC34A,stroke:#558B2F,stroke-width:3px,color:#fff
    classDef resource fill:#E3F2FD,stroke:#1976D2,stroke-width:1px
    classDef reqDoc fill:#FFF3E0,stroke:#FF6F00,stroke-width:2px
    
    class PHASE1 phase
    class PHASE2 phase
    class PHASE3 phase
    class PHASE4 phase
    class PHASE5 phase
    class REQ,SEARCH1,DOC1,DOC2,DOC3,DOC4,CONTEXT contextPhase
    class CODEGEN,IMPL implementPhase
    class BROWSER,VERIFY,LOGS,VISUAL,ERRORS verifyPhase
    class ERRORANALYSIS,DOCSEARCH,SOLUTIONS,FIX fixPhase
    class OPEN_DOC,DIARY,CHECK_UPDATE,IMPL_NOTES,FEEDBACK_SECTION,RECOMMENDATIONS,SAVE updatePhase
    class SUCCESS success
    class DOCS,TOOLS,MCP resource
    class REQDOC reqDoc
