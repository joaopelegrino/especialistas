# Aprofundamento em Domain-Driven Design (DDD)

## 1. O que é DDD? Foco no Coração do Negócio

Domain-Driven Design (DDD) não é uma tecnologia ou um framework, mas uma **abordagem estratégica para o design de software** que se concentra em modelar o software para corresponder a um domínio de negócio. Proposto por Eric Evans, o DDD coloca o foco principal na **complexidade do domínio de negócio**, tratando-a como o principal desafio a ser resolvido.

A premissa é que o código (a implementação) e o modelo de domínio (a compreensão do negócio) devem evoluir juntos. Para isso, o DDD promove uma colaboração intensa entre desenvolvedores e especialistas do domínio (domain experts), utilizando uma linguagem comum e onipresente.

---

## 2. Os Blocos de Construção Estratégicos

O DDD é dividido em duas partes principais: Design Estratégico e Design Tático. O Design Estratégico trata da visão macro do sistema.

#### **Linguagem Ubíqua (Ubiquitous Language)**
Este é talvez o conceito mais fundamental do DDD. É uma linguagem compartilhada, rigorosa e desenvolvida por desenvolvedores e especialistas do domínio. Essa linguagem é usada em todas as conversas, documentos, diagramas e, crucialmente, no próprio código (nomes de classes, métodos, variáveis). Isso elimina ambiguidades e garante que o software seja um reflexo fiel do domínio.

#### **Contexto Delimitado (Bounded Context)**
Um Bounded Context é uma fronteira explícita dentro da qual um modelo de domínio específico se aplica. Dentro de um contexto, cada termo da Linguagem Ubíqua tem um significado único e bem definido. Por exemplo, o termo "Cliente" pode significar uma coisa no contexto de "Vendas" (com dados sobre leads e potencial de compra) e outra completamente diferente no contexto de "Suporte" (com dados sobre tickets e histórico de atendimento). O DDD nos ensina a não criar um modelo único e gigante para "Cliente", mas sim modelos distintos para cada contexto.

#### **Mapa de Contextos (Context Map)**
Um Mapa de Contextos é um diagrama que visualiza as relações entre diferentes Bounded Contexts. Ele mostra como as equipes e os modelos interagem, definindo padrões de integração como:
*   **Shared Kernel:** Duas equipes compartilham uma parte do modelo.
*   **Customer-Supplier:** Uma equipe (downstream) consome o modelo de outra (upstream).
*   **Anticorruption Layer:** A equipe downstream cria uma camada de tradução para se proteger de mudanças no modelo upstream.

---

## 3. Os Blocos de Construção Táticos

O Design Tático foca nos detalhes de implementação dentro de um único Bounded Context.

#### **Entidades (Entities)**
São objetos que possuem uma identidade única que persiste ao longo do tempo. A identidade é mais importante do que seus atributos. Por exemplo, um `Pedido` é uma entidade; mesmo que seu status ou itens mudem, ele ainda é o mesmo pedido. Sua identidade (ex: `PedidoID`) é a chave.

#### **Objetos de Valor (Value Objects)**
São objetos definidos por seus atributos, não por sua identidade. Eles são imutáveis. Por exemplo, um `Endereço` (rua, cidade, CEP) é um Objeto de Valor. Se você mudar a rua, não está alterando o endereço, está criando um novo. Dois Objetos de Valor com os mesmos atributos são considerados iguais.

#### **Agregados (Aggregates)**
Um Agregado é um cluster de Entidades e Objetos de Valor que são tratados como uma única unidade para fins de modificação de dados. Ele possui uma raiz, chamada **Aggregate Root**, que é a única entidade do agregado acessível externamente. Qualquer referência a objetos dentro do agregado deve passar pela raiz. Isso garante a consistência e a invariância das regras de negócio. Por exemplo, um `Pedido` (Aggregate Root) pode conter uma lista de `ItensPedido` (Entidades). Para adicionar um item, você chama um método em `Pedido`, não manipula a lista de itens diretamente.

#### **Repositórios (Repositories)**
São responsáveis por persistir e recuperar Agregados. Eles fornecem a ilusão de uma coleção de objetos na memória. A lógica de acesso a dados (SQL, NoSQL) é encapsulada aqui, mantendo o modelo de domínio limpo. Ex: `orderRepository.findById(orderId)`.

#### **Fábricas (Factories)**
São responsáveis por criar objetos complexos (Agregados ou Entidades), garantindo que eles sejam criados em um estado válido e consistente.

#### **Serviços de Domínio (Domain Services)**
Quando uma operação ou lógica de negócio não pertence naturalmente a nenhuma Entidade ou Objeto de Valor, ela pode ser implementada em um Serviço de Domínio.

---

## 4. Benefícios do DDD

*   **Comunicação Melhorada:** A Linguagem Ubíqua alinha negócio e tecnologia.
*   **Software Flexível e Escalável:** Bounded Contexts promovem um design modular (base para microsserviços).
*   **Reflexo Fiel do Negócio:** O código se torna uma representação mais precisa das regras e processos de negócio.
*   **Manutenção Simplificada:** A separação clara de contextos e a encapsulação de lógica em agregados tornam o código mais fácil de entender e modificar.

---

## 5. Desafios e Quando Usar

*   **Complexidade Inicial:** DDD exige um investimento significativo em análise e colaboração antes que muito código seja escrito.
*   **Não é para Tudo:** É mais adequado para domínios complexos e de longa duração. Para problemas simples ou aplicações CRUD, pode ser um exagero.
*   **Necessidade de Especialistas:** Requer acesso contínuo a especialistas do domínio que estejam dispostos a colaborar.

O DDD brilha quando a complexidade do software reside no domínio de negócio, não nos desafios técnicos. É uma ferramenta poderosa para domar a complexidade e construir software que realmente importa para o negócio.
