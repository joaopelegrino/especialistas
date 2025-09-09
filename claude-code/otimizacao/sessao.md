# 📋 Guia de Boas Práticas para Sessão de Requisitos do Agente no Documento
central de Planejamento

## 1. 🎯 Estrutura Base do Documento

### 1.1 Cabeçalho Identificador
```markdown
---
task_id: TASK-2025-001
priority: HIGH | MEDIUM | LOW
estimated_effort: 4h
created_date: 2025-01-09
created_by: [nome/role]
agent_assigned: implementation_agent_v1
status: PENDING | IN_PROGRESS | COMPLETED | BLOCKED
---
```

**Boas Práticas:**
- Use IDs únicos e rastreáveis
- Defina claramente a prioridade para ordenação de backlog
- Estime esforço para planejamento de capacidade
- Mantenha metadados atualizados

### 1.2 Contexto e Objetivo
```markdown
## 📌 Contexto
[Breve descrição do problema/necessidade que originou a tarefa]

## 🎯 Objetivo
[Descrição clara e mensurável do que deve ser alcançado]

## 💼 Valor de Negócio
[Por que isso é importante? Qual impacto esperado?]
```

**Boas Práticas:**
- Seja específico sobre o "porquê" da tarefa
- Conecte com objetivos de negócio maiores
- Facilite a tomada de decisão do agente

## 2. ✅ Checklist de Implementação

### 2.1 Estrutura de Checklist Acionável
```markdown
## ✅ Checklist de Tarefas

### Preparação
- [ ] Analisar componentes existentes relacionados
- [ ] Verificar dependências necessárias
- [ ] Identificar padrões de código aplicáveis

### Implementação Core
- [ ] Criar estrutura base do componente
  - Localização: `/src/components/NewFeature/`
  - Arquivo principal: `index.tsx`
- [ ] Implementar lógica de negócio
  - Requisito: Deve processar dados em menos de 100ms
- [ ] Adicionar tratamento de erros
  - Cobrir casos: [lista de edge cases]

### Integração
- [ ] Conectar com API existente
  - Endpoint: `GET /api/v1/data`
  - Headers necessários: `Authorization`, `Content-Type`
- [ ] Atualizar state management
  - Store: `useDataStore`
  - Actions: `fetchData`, `updateData`

### Validação
- [ ] Testes unitários passando (mínimo 80% cobertura)
- [ ] Verificação visual no browser
- [ ] Console sem erros ou warnings
- [ ] Performance dentro dos limites (LCP < 2.5s)
```

**Boas Práticas:**
- **Granularidade adequada**: Não muito genérico nem excessivamente detalhado
- **Critérios verificáveis**: Cada item deve ter um critério claro de "feito"
- **Agrupamento lógico**: Organize por fases ou áreas de trabalho
- **Detalhes inline**: Inclua especificações diretamente no item quando relevante

## 3. 📝 Especificações Técnicas

### 3.1 Requisitos Funcionais
```markdown
## 📐 Requisitos Funcionais

### RF-001: Validação de Entrada
**Como** usuário
**Quero** que o sistema valide meus dados antes de enviar
**Para** evitar erros e retrabalho

**Critérios de Aceitação:**
1. Campo email deve validar formato (regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/)
2. Campo telefone aceita apenas números e formatação (XX) XXXXX-XXXX
3. Mensagem de erro aparece em até 300ms após perder foco
4. Erros são destacados em vermelho (#DC2626)

### RF-002: Persistência de Dados
[...]
```

**Boas Práticas:**
- Use formato User Story quando apropriado
- Numere requisitos para referência fácil
- Inclua critérios de aceitação específicos e testáveis
- Forneça valores exatos (cores, timeouts, formatos)

### 3.2 Requisitos Não-Funcionais
```markdown
## ⚙️ Requisitos Não-Funcionais

### Performance
- Tempo de carregamento inicial: < 1s
- Tempo de resposta para interações: < 100ms
- Bundle size máximo: 50KB gzipped

### Acessibilidade
- WCAG 2.1 Level AA compliance
- Navegação completa via teclado
- Screen reader compatible
- Contraste mínimo 4.5:1 para texto

### Compatibilidade
- Browsers: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- Resoluções: 320px até 2560px (responsive)
- Orientações: Portrait e Landscape
```

## 4. 🔗 Referências e Dependências

### 4.1 Links para Documentação Interna
```markdown
## 📚 Documentação Relevante

### Arquitetura
- [Sistema de Componentes](/wiki/architecture/components) - v2.3
- [Padrões de Estado](/wiki/patterns/state-management) - última atualização: 2025-01-05
- [Guia de Estilo](/wiki/style-guide) - DEVE seguir seção 3.2

### APIs e Integrações
- [API Documentation](/api/docs/v1) - endpoints relevantes: /users, /data
- [Webhooks Guide](/wiki/webhooks) - eventos: data.created, data.updated

### Exemplos Similares
- [Componente UserForm](/code/components/UserForm) - referência para validação
- [DataTable Implementation](/code/components/DataTable) - padrão de listagem

⚠️ **Atenção**: Documentação de autenticação pode estar desatualizada, validar com implementação atual em `/src/auth/`
```

**Boas Práticas:**
- **Links diretos e funcionais**: Evite referências vagas
- **Versioning**: Indique versões quando relevante
- **Alertas**: Sinalize documentação potencialmente desatualizada
- **Exemplos práticos**: Referencie código existente similar

### 4.2 Dependências Externas
```markdown
## 🔧 Dependências

### Bibliotecas Necessárias
```json
{
  "react": "^18.2.0",
  "zustand": "^4.4.0",
  "zod": "^3.22.0",
  "react-hook-form": "^7.48.0"
}
```

### Configurações Especiais
- Variável de ambiente: `VITE_API_URL` deve estar configurada
- Feature flag: `ENABLE_NEW_VALIDATION` deve estar true
```

## 5. 🎨 Mockups e Exemplos

### 5.1 Interface Visual
```markdown
## 🎨 Design e Interface

### Mockup
[Link para Figma/Screenshot]

### Comportamento Esperado
1. **Estado Inicial**: Formulário vazio com placeholder texts
2. **Durante Digitação**: Validação em tempo real após 500ms de pausa
3. **Erro**: Border vermelha + mensagem abaixo do campo
4. **Sucesso**: Ícone de check verde + border verde
5. **Loading**: Spinner sobreposto com opacity 0.7

### Estrutura de Dados
```typescript
interface UserData {
  id: string;
  email: string;
  phone?: string;
  preferences: {
    notifications: boolean;
    theme: 'light' | 'dark';
  };
  createdAt: Date;
  updatedAt: Date;
}
```
```

## 6. 📊 Seções para Preenchimento pelo Agente

### 6.1 Template de Diário
```markdown
## 📓 Diário de Implementação
<!-- SEÇÃO PREENCHIDA PELO AGENTE -->

### 🕐 Timeline
- **Início**: [timestamp]
- **Fim**: [timestamp]
- **Tempo Total**: [duração]
- **Interrupções/Bloqueios**: [descrever se houver]

### 💻 Decisões Técnicas
#### Decisão 1: [Título]
- **Contexto**: [Por que a decisão foi necessária]
- **Opções Consideradas**: 
  1. Opção A - Prós/Contras
  2. Opção B - Prós/Contras
- **Escolha Final**: [Qual e por quê]
- **Impacto**: [Consequências da decisão]

### 🔍 Dificuldades Encontradas
#### Problema 1: [Descrição]
- **Sintoma**: [O que estava acontecendo]
- **Causa Raiz**: [Por que aconteceu]
- **Solução**: [Como foi resolvido]
- **Tempo Gasto**: [duração]
- **Documentação Consultada**: [links]

### 📚 Feedback sobre Documentação
#### Documentos Úteis
- [Link Doc 1]: Ajudou com [específico]
- [Link Doc 2]: Exemplo claro de [específico]

#### Documentos Problemáticos
- [Link Doc X]: Desatualizado - mostra versão antiga da API
- [Link Doc Y]: Confuso - falta exemplo prático

#### Documentação Faltante
- Precisava de: Guia sobre [tópico específico]
- Tive que descobrir: [O que teve que inferir/testar]
```

### 6.2 Template de Recomendações
```markdown
## 💡 Recomendações para Melhoria
<!-- SEÇÃO PREENCHIDA PELO AGENTE -->

### 🚨 Alertas Críticos
- ⚠️ [Descrição do problema que pode afetar outros]

### 📐 Padrões Emergentes
- Identificado padrão repetitivo em [área]
- Sugestão: Criar componente/função reutilizável

### 📚 Sugestões de Documentação
1. **Criar**: Guia sobre [tópico]
   - Público: [quem precisa]
   - Conteúdo essencial: [o que incluir]
   
2. **Atualizar**: [Doc existente]
   - Problema: [o que está errado/faltando]
   - Correção sugerida: [específico]

### 🔄 Melhorias no Processo
- Checklist poderia incluir: [item faltante]
- Ordem sugerida diferente: [justificativa]
```

## 7. 🚀 Boas Práticas Gerais

### 7.1 Clareza e Precisão
- **Evite ambiguidades**: "Melhorar performance" ❌ vs "Reduzir LCP para < 2.5s" ✅
- **Use valores específicos**: "Rápido" ❌ vs "< 100ms" ✅
- **Defina termos**: Glossário se necessário

### 7.2 Rastreabilidade
- **IDs únicos** para requisitos, tarefas, decisões
- **Timestamps** em todas as atualizações
- **Versionamento** do próprio documento

### 7.3 Formato Consistente
- **Markdown estruturado** para parsing automático
- **Convenções de nomenclatura** consistentes
- **Templates reutilizáveis** para seções comuns

### 7.4 Informação Acionável
- **Cada item deve ter uma ação clara**
- **Critérios de sucesso objetivos**
- **Links diretos** para recursos necessários

### 7.5 Feedback Loop
- **Espaço dedicado** para feedback do agente
- **Estrutura para capturar aprendizados**
- **Mecanismo para propagar melhorias**

## 8. ⚡ Exemplo de Documento Completo

```markdown
---
task_id: TASK-2025-001
priority: HIGH
estimated_effort: 4h
created_date: 2025-01-09
created_by: tech_lead
agent_assigned: implementation_agent_v1
status: PENDING
---

# Implementação: Formulário de Validação de Usuário

## 📌 Contexto
Sistema atual não valida dados antes de enviar para API, causando 30% de erros em produção.

## 🎯 Objetivo
Implementar validação client-side robusta no formulário de usuário, reduzindo erros em 90%.

## ✅ Checklist de Tarefas

### Preparação
- [ ] Analisar UserForm existente em `/src/components/UserForm`
- [ ] Verificar schema de validação no backend `/api/schemas/user`
- [ ] Revisar padrão de validação em `/wiki/patterns/form-validation`

### Implementação
- [ ] Criar hook `useUserValidation` com Zod
  - Schema deve espelhar backend
  - Mensagens de erro i18n ready
- [ ] Integrar react-hook-form no componente
  - Mode: "onBlur" para melhor UX
  - Debounce: 500ms para validações assíncronas
- [ ] Adicionar feedback visual
  - Estados: idle, validating, error, success
  - Cores conforme design system

### Testes
- [ ] Unit tests com 80% cobertura
- [ ] E2E test do fluxo completo
- [ ] Verificação manual em Chrome, Firefox, Safari

## 📐 Requisitos Funcionais

### RF-001: Validação de Email
**Critérios:**
1. Formato válido (RFC 5322 simplified)
2. Verificação de unicidade via API
3. Mostrar erro em < 300ms

[... resto do documento ...]

---
<!-- ABAIXO PREENCHIDO PELO AGENTE APÓS IMPLEMENTAÇÃO -->

## 📓 Diário de Implementação
[Agente preenche aqui]

## 💡 Recomendações
[Agente preenche aqui]
```

## 9. 🎯 Checklist de Qualidade do Documento

Antes de enviar o documento para o agente, verifique:

- [ ] **Objetivo está claro e mensurável?**
- [ ] **Checklist é específico e acionável?**
- [ ] **Critérios de aceitação são testáveis?**
- [ ] **Links para documentação estão funcionando?**
- [ ] **Exemplos de código/referências incluídos?**
- [ ] **Dependências claramente listadas?**
- [ ] **Espaço para feedback do agente preparado?**
- [ ] **Metadados do cabeçalho completos?**
- [ ] **Possíveis edge cases mencionados?**
- [ ] **Restrições e limitações documentadas?**

## 10. 🔄 Evolução Contínua

### Como Melhorar com Base no Feedback

1. **Analise padrões** nos diários de implementação
2. **Identifique gaps** recorrentes na documentação
3. **Refine templates** baseado em sucessos e falhas
4. **Automatize** verificações que o agente sempre faz
5. **Propague aprendizados** para novos documentos

### Métricas de Sucesso

- **Taxa de conclusão** sem escalação humana
- **Tempo médio** de implementação
- **Quantidade de iterações** necessárias
- **Qualidade do feedback** fornecido
- **Reusabilidade** das soluções documentadas
