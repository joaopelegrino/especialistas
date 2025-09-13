# CLAUDE.md

Este arquivo fornece orientações para Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Visão Geral do Repositório

Este repositório contém documentação técnica abrangente sobre o Model Context Protocol (MCP) na área da saúde, focando especificamente em sua implementação, contexto do mercado brasileiro e cenário regulatório. O repositório está estruturado como um hub de pesquisa e documentação para aplicações de MCP em saúde.

## Função Principal do Repositório

**Objetivo:** Organizar arquivos relevantes sobre MCP para apoiar diagnóstico e proposição de melhorias sobre a tecnologia MCP em projetos de saúde, sempre priorizando:

- **Pesquisa baseada em evidências** com foco exclusivo em documentações oficiais
- **Rigor científico** apropriado para o setor de saúde
- **Conformidade regulatória** com normas brasileiras e internacionais
- **Segurança e privacidade** de dados de pacientes
- **Análise crítica** de implementações e casos de uso reais

## Estrutura do Repositório

O repositório consiste em dois arquivos de documentação principais:

- **`mcp-saude.md`** - Relatório técnico abrangente (15 seções, ~15.000 palavras) cobrindo implementação de MCP em saúde, incluindo arquitetura técnica, padrões de segurança, padrões de integração, estudos de caso e contexto regulatório brasileiro
- **`fontes-oficiais.md`** - Contém links da documentação oficial da Anthropic para conectores remotos MCP

## Arquitetura do Conteúdo

O documento principal (`mcp-saude.md`) segue uma abordagem estruturada cobrindo:

1. **Implementação Técnica** (Seções 1-7): Arquitetura MCP, extensões HMCP, integração FHIR/HL7/DICOM, frameworks de segurança e padrões de implementação
2. **Estudos de Caso e Aplicações** (Seções 8-11): Implementações do mundo real, análise de ROI, aplicações farmacêuticas e estratégias de implantação
3. **Contexto de Mercado e Regulatório** (Seções 12-15): Análise de mercado global, frameworks de conformidade e regulamentações brasileiras abrangentes de saúde, incluindo LGPD, ANVISA, diretrizes CFM, integração SUS e dinâmicas do mercado de healthtechs

## Foco em Saúde Brasileira

A documentação cobre extensivamente regulamentações e condições do mercado brasileiro de saúde:

- **LGPD (Lei Geral de Proteção de Dados)** conformidade para IA em saúde
- **ANVISA** regulamentações para software de dispositivos médicos (RDC 657/2022, RDC 848/2024)
- **CFM (Conselho Federal de Medicina)** regulamentações de IA e diretrizes de telemedicina
- **SUS (Sistema Único de Saúde)** estratégia de saúde digital e interoperabilidade FHIR através da RNDS
- Análise do mercado brasileiro de healthtechs com R$ 2,1 bilhões em investimentos em 2024
- Cenário de sistemas EHR dominado pela MV com certificações HIMSS

## Trabalhando com Este Repositório

### Critérios de Qualidade e Confiabilidade

Para manter a excelência técnica e científica:

- **Validação de fontes**: Apenas documentações oficiais, papers peer-reviewed e regulamentações governamentais
- **Rastreabilidade**: Todas as afirmações devem ter fontes verificáveis e atualizadas
- **Análise crítica**: Avaliar riscos, limitações e considerações éticas de cada implementação
- **Conformidade regulatória**: Priorizar sempre aspectos de segurança, privacidade e conformidade legal

### Atualizações de Documentação

Ao atualizar conteúdo técnico:
- Manter o formato estruturado de 15 seções
- Incluir terminologia em português e inglês quando aplicável
- Garantir que informações regulatórias reflitam a legislação brasileira atual
- Adicionar fontes à seção de referências abrangente no final
- **Verificar credibilidade** de todas as novas fontes antes da inclusão

### Padrões de Conteúdo

- Todas as implementações técnicas devem incluir considerações de segurança e conformidade
- Regulamentações brasileiras têm precedência para orientações de implementação local
- Incluir benefícios quantificados e dados de ROI quando disponíveis
- Manter foco em aplicações MCP específicas para saúde ao invés de uso geral de MCP
- **Análise de risco-benefício** para cada solução proposta

### Fontes de Pesquisa

A documentação baseia-se em fontes oficiais incluindo:
- Documentação oficial MCP da Anthropic
- Sites regulatórios do governo brasileiro (ANVISA, Ministério da Saúde)
- Relatórios da indústria de saúde e análise de mercado
- Publicações acadêmicas sobre regulamentação de IA em saúde
- Diretrizes de conselhos médicos profissionais (CFM)
- **Normas técnicas** ABNT, ISO e IEC relevantes para saúde digital

## Conceitos Técnicos Principais

O repositório foca em implementações MCP específicas para saúde incluindo:
- Extensões Healthcare Model Context Protocol (HMCP) pela Innovaccer
- Padrões de integração com FHIR R4, HL7 v2/v3 e DICOM
- Frameworks de segurança com conformidade HIPAA e requisitos LGPD brasileiros
- Padrões de implantação Edge AI para ambientes de saúde
- Sistemas de suporte à decisão clínica em tempo real
- **Certificações e padrões** de qualidade específicos para dispositivos médicos

## Metodologia de Análise e Diagnóstico

Para análise e proposição de melhorias em projetos MCP:

1. **Avaliação técnica**: Arquitetura, performance, escalabilidade e interoperabilidade
2. **Análise regulatória**: Conformidade com LGPD, ANVISA, CFM e padrões internacionais
3. **Avaliação de segurança**: Criptografia, controle de acesso, auditoria e privacidade
4. **Análise de viabilidade**: ROI, custos de implementação e manutenção
5. **Impacto clínico**: Benefícios para pacientes, profissionais e sistema de saúde
6. **Sustentabilidade**: Manutenibilidade, evolução tecnológica e suporte a longo prazo

Este repositório serve como um recurso abrangente para compreender a implementação de MCP em contextos de saúde, com ênfase particular no ambiente regulatório e de mercado brasileiro, sempre mantendo os mais altos padrões de rigor científico e conformidade regulatória necessários para o setor de saúde.