# Aprofundamento em Test-Driven Development (TDD)

## 1. O que é TDD? Uma Mudança de Paradigma

Test-Driven Development (TDD) não é uma técnica de teste, mas uma **disciplina de design e desenvolvimento**. A premissa fundamental é que os testes são escritos *antes* do código de produção. Isso força o desenvolvedor a pensar nos requisitos e no design da funcionalidade a partir da perspectiva de quem a consome, antes de se preocupar com os detalhes da implementação.

O TDD vai além da simples verificação de que o código funciona; ele guia a arquitetura do software de forma incremental, resultando em um design mais limpo, modular e de fácil manutenção.

---

## 2. As Três Leis do TDD

Propostas por Robert C. Martin (Uncle Bob), estas três regras simples formam o coração do TDD. Segui-las rigorosamente garante que os testes e o código sejam escritos em conjunto, em um ritmo de pequenos passos.

1.  **Primeira Lei:** Você não deve escrever nenhum código de produção a menos que seja para fazer um teste unitário que falha passar.
2.  **Segunda Lei:** Você não deve escrever mais de um teste unitário do que o suficiente para falhar. E falhas de compilação são falhas.
3.  **Terceira Lei:** Você não deve escrever mais código de produção do que o suficiente para passar no teste unitário que falha.

O resultado prático dessas leis é um ciclo de trabalho que dura minutos, ou até segundos: escrever um teste que falha, escrever o código para passar, refatorar. Este é o famoso ciclo **Red-Green-Refactor**.

---

## 3. O Ciclo Red-Green-Refactor em Detalhes

#### **Fase 1: RED (Vermelho)**
*   **Objetivo:** Definir o que você quer que o código faça.
*   **Ação:** Escreva um teste para uma funcionalidade que ainda não existe. Seja específico. O teste deve falhar. Se ele passar, você provavelmente escreveu um teste para uma funcionalidade que já existe ou o teste está incorreto.
*   **Importância Psicológica:** Esta fase remove o "medo da página em branco". Você sempre sabe o que fazer a seguir: fazer o teste passar.

#### **Fase 2: GREEN (Verde)**
*   **Objetivo:** Fazer o teste passar da forma mais rápida e simples possível.
*   **Ação:** Escreva o mínimo de código necessário. Neste ponto, não se preocupe com a qualidade do código. Soluções "feias" ou "ingênuas" são aceitáveis. O objetivo é apenas obter o feedback positivo da barra verde dos testes.
*   **Importância Psicológica:** Esta fase fornece uma sensação de progresso e conquista, reforçando o comportamento de pequenos passos.

#### **Fase 3: REFACTOR (Refatorar)**
*   **Objetivo:** Limpar o código que você acabou de escrever.
*   **Ação:** Agora que você tem uma rede de segurança (os testes que passam), você pode melhorar o design do código sem medo de quebrar a funcionalidade. Remova duplicação, melhore nomes de variáveis, extraia métodos, etc.
*   **Importância:** Esta é a fase onde o bom design emerge. Sem a refatoração, o TDD pode levar a um acúmulo de código mal escrito. A suíte de testes garante que a refatoração seja segura.

---

## 4. Benefícios do TDD

*   **Rede de Segurança:** A suíte de testes abrangente permite que os desenvolvedores façam alterações e refatorações com confiança, sabendo que se algo quebrar, um teste irá falhar.
*   **Design Emergente e Acoplamento Baixo:** O TDD naturalmente leva a um código mais modular e com baixo acoplamento, pois é difícil escrever testes para código monolítico e fortemente acoplado.
*   **Documentação Viva:** Os testes unitários servem como uma forma de documentação executável. Eles descrevem exatamente o que o código faz em diferentes cenários.
*   **Redução de Bugs:** Os bugs são encontrados muito mais cedo no ciclo de desenvolvimento, tornando sua correção mais barata e rápida.
*   **Foco e Clareza:** Força o desenvolvedor a se concentrar em um requisito de cada vez.

---

## 5. Desafios e Armadilhas Comuns

*   **Curva de Aprendizagem:** Requer uma mudança de mentalidade que pode ser difícil para desenvolvedores acostumados a escrever código primeiro.
*   **Testes Lentos:** Uma suíte de testes que demora muito para rodar quebra o ciclo rápido do TDD e desestimula os desenvolvedores.
*   **Foco Excessivo em Testes Unitários:** O TDD não substitui a necessidade de testes de integração e de ponta a ponta. É preciso uma estratégia de teste equilibrada.
*   **Testar Detalhes de Implementação:** Os testes devem focar no comportamento (o "o quê"), não na implementação (o "como"). Acoplar testes à implementação os torna frágeis e difíceis de manter.

---

## 6. Exemplo Prático: Um Carrinho de Compras Simples

Vamos desenvolver uma funcionalidade para adicionar um item a um carrinho de compras.

**RED 1:** Escrever um teste para adicionar um item.
```python
# tests/test_cart.py
import unittest
from cart import Cart

class TestCart(unittest.TestCase):
    def test_add_item(self):
        cart = Cart()
        cart.add_item("apple", 1)
        self.assertEqual(cart.get_items(), {"apple": 1})
```
*Rodar o teste: Falha (ImportError: não existe a classe Cart)*

**GREEN 1:** Criar a classe e o método mais simples.
```python
# cart.py
class Cart:
    def __init__(self):
        self._items = {}

    def add_item(self, item_name, quantity):
        self._items[item_name] = quantity

    def get_items(self):
        return self._items
```
*Rodar o teste: Passa!*

**REFACTOR 1:** O código está bom por enquanto. Nenhuma refatoração necessária.

**RED 2:** Testar a adição de um item já existente.
```python
# tests/test_cart.py (adicionar método à classe de teste)
    def test_add_existing_item_increases_quantity(self):
        cart = Cart()
        cart.add_item("apple", 1)
        cart.add_item("apple", 2)
        self.assertEqual(cart.get_items(), {"apple": 3})
```
*Rodar o teste: Falha (AssertionError: {'apple': 2} != {'apple': 3})*

**GREEN 2:** Modificar `add_item` para lidar com itens existentes.
```python
# cart.py (modificar método)
    def add_item(self, item_name, quantity):
        if item_name in self._items:
            self._items[item_name] += quantity
        else:
            self._items[item_name] = quantity
```
*Rodar todos os testes: Passam!*

**REFACTOR 2:** O código está claro. Nenhuma refatoração óbvia é necessária.

Este ciclo continua para cada nova funcionalidade (remover item, calcular total, etc.), construindo o software de forma incremental e segura.
