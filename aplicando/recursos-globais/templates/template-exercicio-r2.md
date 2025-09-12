# 🔬 [TÍTULO DO EXERCÍCIO]

## 🎯 Objetivo
[Descrição clara do que será analisado/debuggado com r2]

## 📋 Pré-requisitos
- [ ] r2 instalado e configurado
- [ ] Código/binário de teste disponível
- [ ] QEMU configurado (se aplicável)
- [ ] Conhecimento base: [listar conceitos necessários]

## 🚀 Passo a Passo

### Etapa 1: Preparação
```bash
# Comandos de setup
[comandos específicos]
```

### Etapa 2: r2 Analysis
```bash
# r2 commands específicos
r2 [binary]
[0x00000000]> comando1
[0x00000000]> comando2
```

### Etapa 3: Análise Dinâmica (se aplicável)
```bash
# QEMU + r2 remote (se necessário)
qemu-system-i386 -S -s [options]
r2 -d gdb://localhost:1234
```

## 🔍 Análise Esperada
- **Observação 1:** [O que deve encontrar]
- **Observação 2:** [Padrões esperados]  
- **Observação 3:** [Insights importantes]

## ✅ Critérios de Avaliação
- [ ] Critério 1
- [ ] Critério 2  
- [ ] Critério 3
- [ ] Documentação r2 analysis criada

## 📚 Documentação Final
Criar arquivo `[nome]-r2-analysis.md` documentando:
- r2 commands usados e resultados
- Findings importantes descobertos
- Conexões com teoria da fase
- Insights para próximos exercícios

## 🎯 Extensões Avançadas
- [Variações do exercício]
- [Exercícios relacionados]
- [Conexão com projetos da fase]