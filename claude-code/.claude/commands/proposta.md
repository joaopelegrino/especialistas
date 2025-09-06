Seguindo as <diretrizes>, faça um diagnóstico completo do <projeto> e das
configurações atuais do <.claude> para propor melhorias de fluxos de programação
seguindo as melhores práticas de fluxos de trabalho com LLMs. É importante ter
conhecumento de 100% da estrutura para diagnóstivo aprofundado, obtenha
a estrutura usando <comandos tree>

<diretrizes>
/home/notebook/workspace/especialistas/claude-code/agente-programador-system-prompt.md
</diretrizes>
<projeto>
/home/notebook/workspace/blog/
</projeto>
<.claude>
/home/notebook/workspace/blog/.claude
</.claude>
<comandos tree>

 Comando Otimizado

  tree -L 3 --dirsfirst -F -I '.git|node_modules|deps|_build|priv/static/assets|popcor
  n_runtime_source/atomvm|*.dump|*.log|.elixir_ls|cover' /home/notebook/workspace/blog

  Explicação das Opções

  - -L 3: Limita a 3 níveis de profundidade para visão clara da arquitetura
  - --dirsfirst: Agrupa diretórios no topo para melhor organização visual
  - -F: Adiciona indicadores de tipo (/, *, @ etc.)
  - -I 'patterns': Remove elementos verbosos e desnecessários:
    - .git: Controle de versão (muito verboso)
    - node_modules: Dependências JavaScript (milhares de arquivos)
    - deps: Dependências Elixir/Hex
    - _build: Artefatos de compilação Elixir
    - priv/static/assets: Assets compilados
    - popcorn_runtime_source/atomvm: Código fonte externo volumoso
    - *.dump: Arquivos de crash dump
    - *.log: Arquivos de log
    - .elixir_ls: Cache do language server
    - cover: Relatórios de cobertura

  Alternativas Sugeridas

  1. Estrutura básica (apenas diretórios):
  tree -d -L 2 -I '.git|node_modules|deps|_build' /home/notebook/workspace/blog

  2. Foco em código Elixir/Phoenix:
  tree -L 3 --dirsfirst -P '*.ex|*.exs|*.heex' --prune -I
  '.git|node_modules|deps|_build' /home/notebook/workspace/blog/lib

  3. Visualização completa da documentação:
  tree -L 4 --dirsfirst /home/notebook/workspace/blog/docs

  4. Estrutura com contagem de arquivos:
  tree -L 2 --dirsfirst -I '.git|node_modules|deps|_build|popcorn_runtime_source'
  /home/notebook/workspace/blog | tail -1

  5. Assets e configurações PWA/WASM:
  tree -L 3 --dirsfirst /home/notebook/workspace/blog/assets
  /home/notebook/workspace/blog/priv/static

  Padrões Excluídos

  - .git: Sistema de controle de versão (centenas de objetos)
  - node_modules: Dependências NPM (potencialmente milhares de arquivos)
  - deps: Dependências Hex do Elixir
  - _build: Artefatos de compilação (dev/test/prod)
  - priv/static/assets: Assets JS/CSS compilados
  - popcorn_runtime_source/atomvm: Código fonte do AtomVM (projeto externo extenso)
  - *.dump: Crash dumps do Erlang (arquivos grandes e técnicos)
  - .elixir_ls: Cache do ElixirLS para IDEs
</comandos tree>
