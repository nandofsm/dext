# 🎓 Dext Master Training: Roadmap de Exemplos Didáticos

Este documento define a jornada oficial de aprendizado do Dext Framework. O objetivo é transformar a experiência de desenvolvimento Delphi, saindo do modelo tradicional e entrando na era da **Programação Moderna, Clean Architecture e Alta Performance**.

## 🎯 Filosofia do Treinamento

O treinamento é estruturado no conceito de **"Pit of Success"** (Poço do Sucesso): o framework é desenhado para que o caminho mais fácil de seguir seja também o caminho com as melhores práticas arquiteturais.

---

## 🗺️ O Mapa da Jornada (7 Estágios)

### Estágio 01: A Fundação Moderna (Core)
*Foco: Sair do acoplamento rígido para a flexibilidade total.*
- **Objetivos de Aprendizagem**: Compreender por que `var`, `interfaces` e `DI` são os pilares da produtividade. Entender o ciclo de vida de objetos em um container IOC.
- **Talking Points**:
    - O custo do acoplamento (o problema do `TService.Create`).
    - Padrão Options: Por que não usar variáveis globais para configuração.
    - Async/Await: O fim do "bloqueio de UI" e o uso correto de `CancellationToken`.
- **Exemplo Proposto**: `01-Core.ConsoleScanner`
    - Uma aplicação console que lê configurações de um JSON, aplica injeção de dependência para diferentes provedores de lógica e executa tarefas assíncronas com cancelamento cooperativo.

### Estágio 02: A Web Moderna (Minimal APIs)
*Foco: Construir serviços leves, rápidos e tipadamente seguros.*
- **Objetivos de Aprendizagem**: Entender o conceito de "Pipeline de Middlewares". Diferença entre Routing e Action Logic. O poder do Model Binding automático.
- **Talking Points**:
    - Minimal APIs vs Controllers: Quando usar cada um.
    - DTOs (Records): Otimização de memória e imutabilidade no transporte de dados.
    - Error Handling: Por que parar de usar `try..except` e começar a usar `ProblemDetails`.
- **Exemplo Proposto**: `02-Web.UrlShortener`
    - Um encurtador de URLs que demonstra roteamento fluente, validação de entrada e retorno de respostas padronizadas (ProblemDetails).

### Estágio 03: O Motor de Dados (ORM Avançado)
*Foco: Modelagem de domínio e persistência sem "Strings Mágicas".*
- **Objetivos de Aprendizagem**: Entender o `Unit of Work` e como o `DbContext` gerencia transações. Diferença entre Lazy e Eager loading.
- **Talking Points**:
    - Smart Properties: O fim das queries baseadas em strings que quebram no refactor.
    - Migrations: Tratando o banco de dados como código vivo.
    - Performance: Quando usar `Phys Drivers` do FireDAC para bypassar overhead.
- **Exemplo Proposto**: `03-Data.StockManager`
    - Um sistema de controle de estoque com consultas complexas tipadas, relacionamentos (Lazy/Eager) e evolução automática do banco de dados.

### Estágio 04: Excelência em Engenharia (QA & Testing)
*Foco: Garantia de qualidade e código testável.*
- **Objetivos de Aprendizagem**: Entender "Fakes vs Mocks". Como escrever testes que não quebram ao mudar a implementação (Testing Behavior, not implementation).
- **Talking Points**:
    - O custo da falta de testes: Dívida técnica e medo de refatorar.
    - `TAutoMocker`: Como ele remove o boilerplate da criação de mocks manuais.
    - Snapshot Testing: Como validar objetos JSON gigantes com apenas uma linha.
- **Exemplo Proposto**: `04-Testing.DiscountEngine`
    - Uma suite de testes unitários e de integração para um motor de descontos complexo, usando mocks para isolar serviços externos.

### Estágio 05: Padrões Enterprise (SaaS & Resiliência)
*Foco: Aplicações escaláveis, seguras e prontas para nuvem.*
- **Objetivos de Aprendizagem**: Como desenhar aplicações Multi-Tenant sem vazar dados. Entender o conceito de "Rate Limiting" para proteção de infraestrutura.
- **Talking Points**:
    - JWT: Autenticação stateless e por que ela é essencial para microserviços.
    - Tenant Isolation: Por que usar schemas separados é o "padrão ouro" para performance e segurança.
    - Redis Caching: Reduzindo latência e carga no banco de dados.
- **Exemplo Proposto**: `05-Enterprise.MultiTenantSaaS`
    - Uma API de gestão de assinaturas que muda o banco de dados/schema conforme o tenant e protege rotas via JWT.

### Estágio 06: User Experience Moderna (Real-time & UI)
*Foco: Interfaces que reagem ao usuário e ao servidor.*
- **Objetivos de Aprendizagem**: Dominar a comunicação bidirecional. Entender por que o MVVM é o padrão superior para desktop Delphi.
- **Talking Points**:
    - SignalR Hubs: O fim do "Pooling" (F5) constante para novas informações.
    - WebStencils: O poder do Razor-like em Delphi para builds de sites rápidos.
    - MVVM + Navigator: Navegação desacoplada (sem `Form.Show`).
- **Exemplo Proposto**: `06-UX.LiveTracking`
    - Painel em tempo real que mostra atualizações do servidor via Hubs e um cliente Desktop VCL usando MVVM e Navegação moderna.

### Estágio 07: O Desafio Final (Clean Architecture)
*Foco: Orquestração total de todos os módulos.*
- **Objetivos de Aprendizagem**: Separar a "Regra de Negócio" da "Infraestrutura". Aplicar tudo o que foi aprendido em um sistema produtivo.
- **Talking Points**:
    - Clean Architecture: Por que o seu banco de dados e sua UI não devem mandar no seu código.
    - Hexagonal Architecture: A importância das interfaces (Portas e Adaptadores).
    - O Caminho para v1.0: Revisão de todos os padrões aplicados.
- **Exemplo Proposto**: `07-Final.TicketSales`
    - Um sistema completo de venda de ingressos (Ticket Sales) com checkout assíncrono, notificações em tempo real, persistência multi-banco e cobertura total de testes.

---

## 📚 Cruzamento com O Livro do Dext (Docs\Book)

| Estágio | Capítulos Referenciados |
| :--- | :--- |
| **01** | Cap 1 (Getting Started), Cap 10 (Advanced DI) |
| **02** | Cap 2 (Web Framework), Cap 4 (API Features) |
| **03** | Cap 5 (ORM), Cap 6 (Database as API) |
| **04** | Cap 8 (Testing) |
| **05** | Cap 3 (Authentication), Cap 4 (Rate Limiting/Cache) |
| **06** | Cap 7 (Real-time), Cap 9 (CLI), Cap 11 (Desktop UI) |
| **07** | Arquitetura Global e Integração |

---

## 🛠️ Próximos Passos para o Roadmap

1.  **Criação da Pasta `Examples\MasterTraining`**: Estrutura física para os novos exemplos.
2.  **Scaffolding dos Templates**: Criar os esqueletos dos projetos para que cada estágio possa ser seguido como um tutorial.
3.  **Documentação Guia**: Cada exemplo terá seu próprio `README.md` explicando o "Porquê" por trás do código.

> *"O Dext não é apenas um framework; é um novo mindset de desenvolvimento para a plataforma Delphi."*
