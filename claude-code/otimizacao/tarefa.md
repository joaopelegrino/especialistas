Crie uma nova branch 'otimizacao-claude-code-09-09' a partir da branch 'projeto-bm-dev-ccentral-fase-09-09-projeto-bm-wiki' e baseado no seu <conhecimento> e pesquisa na documentacao, site, blog da ferramenta claude code e antrhopic caso necessário, gere o planejamento para a otimização geral das <configuracoes_claude_code>, importente ter conhecimento das alteracaoes que foram realizadas em relacao aos arquivos chave e wiki de unica <fonte> da verdade 



<conhecimento>
📁 /home/notebook/workspace/especialistas/claude-code

🌳 Estrutura do diretório:
.
├── avansado
│   ├── templates-pt-br
│   ├── 00-indice-navegacao.md
│   ├── 01-visao-geral-orquestracao.md
│   ├── 02-arquitetura-tecnica.md
│   ├── 03-sistema-hooks.md
│   ├── 04-servidor-mcp.md
│   ├── 05-dashboard-monitoramento.md
│   ├── 06-guia-implementacao.md
│   └── 07-referencias-recursos.md
├── .claude
│   ├── commands
│   └── settings.local.json
├── otimizacao
│   ├── diagrama-agente-responsável-implementacao.md
│   ├── sessao.md
│   └── tarefa.md
├── templates-pt-br
│   └── claude-md-template.md
├── agente-programador-system-prompt.md
├── agentic-improvements.md
├── CLAUDE.md
├── fluxo.md
├── plano-completar-estrutura-claude-blog.md
├── proposta-orquestrador-inteligente-claude-code.md
├── relatorio-diagnostico-blog-webassembly.md
├── relatorio-diagnostico-blog-webassembly-v2.md
├── relatorio-diagnostico-blog-webassembly-v3-central-controle.md
├── relatorio-diagnostico-blog-webassembly-v4-matriz-rastreabilidade.md
├── relatorio-diagnostico-blog-webassembly-v5-central-controle-orquestrador.md
├── relatorio-diagnostico-blog-webassembly-v6-implementacao-orquestrador.md
├── setup-inicial-automatico.sh
└── setup-inicial-wsl.md

</conhecimento>

<configuracoes_claude_code>
      ~/workspace/blog/.claude     projeto-bm-dev-ccentral-fase-09-09-projeto-bm-wiki      ❯  tree                                                                  10:19:50 
.
├── bin
│   ├── claude-pwdct
│   └── claude-shell-commands
├── CLAUDE.md
├── commands
│   ├── collect-evidence.md
│   ├── dashboard-update.md
│   ├── deprecated
│   │   ├── configuracao-diagnostico.md
│   │   └── projeto-bm-delivery.md
│   ├── emergency-debug.md
│   ├── explain-context.md
│   ├── explicar-projeto.md
│   ├── iniciar-fase.md
│   ├── README.md
│   ├── start-phase-orchestrator.md
│   ├── sync-branch-state.md
│   ├── sync-documentation.md
│   └── validate-implementation.md
├── config
│   └── configuracoes.json
├── core
│   ├── artifacts
│   │   ├── guia_testes_validation-1757108050
│   │   │   ├── delivery_report.md
│   │   │   └── execution_results.json
│   │   ├── guia_testes_validation-1757108069
│   │   │   ├── delivery_report.md
│   │   │   └── execution_results.json
│   │   ├── guia_testes_validation-1757108176
│   │   │   ├── delivery_report.md
│   │   │   └── execution_results.json
│   │   ├── guia_testes_validation-1757108186
│   │   │   ├── delivery_report.md
│   │   │   └── execution_results.json
│   │   ├── guia_testes_validation-1757110540
│   │   │   ├── delivery_report.md
│   │   │   └── execution_results.json
│   │   └── guia_testes_validation-1757111206
│   │       ├── delivery_report.md
│   │       └── execution_results.json
│   ├── projeto-bm-agents-config.json
│   ├── projeto-bm-orchestrator.py.deprecated
│   ├── projeto-bm-test-suite.sh
│   ├── projeto-bm-visual-debug-integration.js
│   └── screenshots
│       ├── session-1757098189385
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757106927248
│       │   ├── delivery-report.json
│       │   └── DELIVERY-REPORT.md
│       ├── session-1757107353007
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757107492913
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757107727102
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757107998144
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757108031203
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757108049114
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757108068110
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757108173761
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757108184542
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757108187052
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757110538351
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757110540814
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757111153927
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757111204287
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       ├── session-1757111206591
│       │   ├── auth-login.png
│       │   ├── auth-registration.png
│       │   ├── auth-settings-redirect.png
│       │   ├── delivery-report.json
│       │   ├── DELIVERY-REPORT.md
│       │   ├── visual-desktop-1920x1080.png
│       │   ├── visual-mobile-390x844.png
│       │   └── visual-tablet-768x1024.png
│       └── session-1757416209324
│           ├── auth-login.png
│           ├── auth-registration.png
│           ├── auth-settings-redirect.png
│           ├── delivery-report.json
│           ├── DELIVERY-REPORT.md
│           ├── visual-desktop-1920x1080.png
│           ├── visual-mobile-390x844.png
│           └── visual-tablet-768x1024.png
├── docs
│   ├── PROMPTBASE-INICIAL.md
│   ├── README-CLAUDE-CODE-SYSTEM.md
│   ├── relatorio-05-09.md
│   └── SISTEMA-OTIMIZADO-BM.md
├── hooks
│   ├── eventos
│   ├── mcp-validator.py
│   └── pre_mix_command.py
├── logs
│   ├── mcp_validation_auth_20250907_184102.json
│   ├── mcp_validation_pwa_20250907_184049.json
│   └── network-debug-1757098206255.json
├── mcp-config.json
├── mcp-servers.json
├── metricas
│   ├── validation_auth.json
│   └── validation_pwa.json
├── projeto-bm-auth-test.js
├── projeto-bm-network-debug.js
├── screenshots
│   ├── auth-login-1757098204640.png
│   ├── auth-register-1757098204486.png
│   ├── auth-reset-1757098204789.png
│   ├── session-1757095342472
│   │   ├── auth-login.png
│   │   ├── auth-registration.png
│   │   ├── auth-settings-redirect.png
│   │   ├── delivery-report.json
│   │   ├── DELIVERY-REPORT.md
│   │   ├── visual-desktop-1920x1080.png
│   │   ├── visual-mobile-390x844.png
│   │   └── visual-tablet-768x1024.png
│   ├── session-1757096065775
│   │   ├── auth-login.png
│   │   ├── auth-registration.png
│   │   ├── auth-settings-redirect.png
│   │   ├── delivery-report.json
│   │   ├── DELIVERY-REPORT.md
│   │   ├── visual-desktop-1920x1080.png
│   │   ├── visual-mobile-390x844.png
│   │   └── visual-tablet-768x1024.png
│   └── session-1757097579054
│       ├── auth-login.png
│       ├── auth-registration.png
│       ├── auth-settings-redirect.png
│       ├── delivery-report.json
│       ├── DELIVERY-REPORT.md
│       ├── visual-desktop-1920x1080.png
│       ├── visual-mobile-390x844.png
│       └── visual-tablet-768x1024.png
├── settings.json
├── settings.local.json
├── setup-mcp.sh
├── tarefa.md
├── tools
│   ├── daily-debug-check.sh
│   ├── debug-workflow-setup.sh
│   ├── documentation-sync.py
│   ├── evidence-collector.js
│   └── __pycache__
│       └── documentation-sync.cpython-312.pyc
└── validate-mcp.sh

</configuracoes_claude_code>

<sessão>

/home/notebook/workspace/especialistas/claude-code/otimizacao/sessao.md

</sessão>

<fonte>
      ~/workspace/blog/docs     projeto-bm-dev-ccentral-fase-09-09-projeto-bm-wiki  ❯  tree                                                                           11:14:35 
.
├── archived-legacy-20250909
│   ├── aprendizados
│   │   ├── consolidado-master.md
│   │   ├── phase-bm-1-foundation.md
│   │   └── README.md
│   ├── ARQUITETURA.md
│   ├── base-conhecimento
│   │   ├── 01-documentacao-base
│   │   │   └── README.md
│   │   ├── 02-fundamentos
│   │   │   ├── 01-elixir-essencial.md
│   │   │   ├── 02-referencias-desenvolvimento.md
│   │   │   └── README.md
│   │   ├── 03-phoenix-web
│   │   │   ├── 01-phoenix-1.8-guidelines.md
│   │   │   └── README.md
│   │   ├── 05-testes-qa
│   │   │   ├── 01-estrategias-teste.md
│   │   │   └── README.md
│   │   ├── 06-devops-infra
│   │   │   ├── 01-devops-checklist.md
│   │   │   ├── README.md
│   │   │   └── wasm-telemetry-production.md
│   │   ├── 07-compliance-saude
│   │   │   ├── 01-relatorio-saude-quantum.md
│   │   │   └── README.md
│   │   ├── 09-setup-config
│   │   │   ├── 01-instalacao-inicial.md
│   │   │   ├── 02-instalacao-moderna-elixir-2025.md
│   │   │   └── README.md
│   │   └── 10-templates-recursos
│   │       ├── checklists
│   │       ├── configs-exemplo
│   │       ├── README.md
│   │       ├── scripts-automacao
│   │       │   └── upgrade-stack-phase2.sh
│   │       └── templates-pt-br
│   ├── CENTRAL-DE-CONTROLE-HL.md
│   ├── CENTRAL-DE-CONTROLE-TECH.md
│   ├── HISTORICO-MUDANCAS.md
│   ├── INDICE-CONTEXTO-RAPIDO.md
│   ├── onboarding
│   │   ├── 01_GETTING_STARTED.md
│   │   ├── 02_ARCHITECTURE_FOR_BEGINNERS.md
│   │   ├── 03_LEARNING_ROADMAP.md
│   │   ├── 05_DESENVOLVIMENTO_SUSTENTAVEL.md
│   │   ├── 06_OTIMIZACAO_AVANCADA.md
│   │   └── README.md
│   ├── ROADMAP.md
│   └── templates
│       ├── diretiva-config.md
│       └── diretiva-controller.md
├── README.md
└── wiki
    ├── apis-integracao
    ├── arquitetura
    │   ├── q
    │   └── visao-geral-projeto-bm.md
    ├── blog-core
    ├── componentes-projeto-bm
    │   ├── content-wizard-5-etapas.md
    │   └── sistema-autenticacao-roles.md
    ├── COVERAGE-PROJETO-BM.md
    ├── guias-uso
    │   ├── configuracao-inicial.md
    │   └── solucao-problemas.md
    ├── integracao-blog-sistema
    ├── README.md
    ├── referencias-tecnicas
    │   ├── coding-standards.md
    │   ├── phoenix-patterns.md
    │   └── stack-tecnologico.md
    └── roadmap-implementacao
        ├── README.md
        └── requisitos-projeto-bm
            ├── 00_VISAO_E_PRODUTO.md
            ├── 01_ARQUITETURA_FUNCIONAL.md
            ├── 02_ARQUITETURA_TECNICA
            │   ├── 01_STACK_E_FRONTEND.md
            │   ├── 02_DADOS.md
            │   ├── 03_SEGURANCA.md
            │   ├── 04_QUANTUM_READY.md
            │   └── 07_GUIA_USO_VERTEX_AI.md
            ├── 03_COMPLIANCE
            │   └── PLANO_DE_COMPLIANCE.md
            ├── 04_REQUISITOS_NAO_FUNCIONAIS.md
            ├── 06_PARIDADE_FUNCIONAL.md
            ├── ANALISE_ESTADO_ATUAL.md
            ├── arquivos-para-referenciar
            │   ├── formatos-arquivos-requisitos.md
            │   └── metodos-marcacao-codigo.md
            ├── assets
            │   ├── base-de-conhecimento-elixir
            │   │   ├── DIARIO_REFERENCIAS_DEV.md
            │   │   ├── GUIA_IMPLEMENTACAO_IA.md
            │   │   ├── README.md
            │   │   └── RELATORIO_TECNICO_SAUDE_QUANTUM.md
            │   └── PROTOTIPO_INTERFACE.jsx
            ├── FINALIZACAO-PHASE-BM-1.md
            ├── INTERFACES-PROJETO-BM.md
            ├── PLANO_DESENVOLVIMENTO.md
            └── requisitos_desenvolvimento
                ├── 00_VISAO_GERAL_E_REGRAS.md
                ├── features
                │   ├── 00_autenticacao.feature
                │   ├── 01_wizard_conteudo.feature
                │   └── 02_painel_kanban.feature
                └── ui_ux
                    ├── 00_DESIGN_SYSTEM.md
                    └── 01_WIREFRAMES.md


</fonte>
