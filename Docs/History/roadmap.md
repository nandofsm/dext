# 🗺️ Project Dext - Roadmap & Status

Bem-vindo ao documento oficial de roadmap do **Project Dext**. Este documento serve como ponto central para acompanhar o progresso do desenvolvimento, entender a visão do projeto e comparar funcionalidades com outros frameworks.

> **Visão:** Criar o "ASP.NET Core para Delphi" — um framework web moderno, modular, de alto desempenho e com uma experiência de desenvolvimento (DX) superior.

---

## 📊 Status Atual do Projeto: **Release Candidate 1.0** 🚀

O framework atingiu a maturidade necessária para produção. Esta versão consolida todas as funcionalidades planejadas, com cobertura de testes abrangente e integração nativa com ferramentas de mercado.

*Última atualização: 07 de Abril de 2026*

### 🏆 Comparativo de Funcionalidades

Abaixo, comparamos o Dext com as principais alternativas do mercado Delphi e sua inspiração direta (.NET).

| Funcionalidade | ⚡ Dext | 🐴 Horse | 📦 DMVC | 🔷 ASP.NET Core |
| :--- | :---: | :---: | :---: | :---: |
| **Arquitetura** | Modular (Microsoft.Extensions.* style) | Middleware-based (Express.js style) | MVC Clássico | Modular |
| **Real-Time (WebSockets)** | ✅ (Dext.Web.Hubs) | ⚠️ (Socket.IO externo) | ❌ | ✅ (SignalR) |
| **Injeção de Dependência** | ✅ **Nativa & First-Class** (Scoped, Transient, Singleton) | ❌ (Requer lib externa) | ⚠️ (Limitada/Externa) | ✅ Nativa |
| **Scoped Services** | ✅ **Por Requisição** (DbContext, UoW) | ❌ | ❌ | ✅ |
| **Minimal APIs** | ✅ `App.MapGet('/route', ...)` | ✅ | ❌ | ✅ |
| **Controllers** | ✅ Suporte completo (Attributes) | ❌ | ✅ | ✅ |
| **Action Filters** | ✅ **Declarativo** (OnExecuting/Executed) | ❌ | ✅ | ✅ |
| **Model Binding** | ✅ **Avançado** (Body, Query, Route, Header, Services) | ⚠️ Básico | ✅ | ✅ |
| **Validation** | ✅ **Automática** (Attributes + Minimal APIs) | ❌ | ✅ | ✅ |
| **Middleware Pipeline** | ✅ Robusto (`UseMiddleware<T>`) | ✅ Simples | ✅ | ✅ |
| **Autenticação/AuthZ** | ✅ **Nativa** (Identity, JWT, Policies) | ⚠️ (Middleware externo) | ✅ | ✅ |
| **OpenAPI / Swagger** | ✅ **Nativo** (Geração automática + Global Responses) | ✅ (Swagger-UI) | ✅ | ✅ |
| **Caching** | ✅ **Nativo** (In-Memory, Response Cache) | ❌ | ❌ | ✅ |
| **Rate Limiting** | ✅ **Avançado** (4 algoritmos, Partition Strategies) | ⚠️ (Middleware externo) | ✅ | ✅ |
| **Static Files** | ✅ Middleware nativo | ❌ | ⚠️ (Manual) | ✅ |
| **Problem Details** | ✅ RFC 7807 | ❌ | ⚠️ | ✅ |
| **HTTP Logging** | ✅ Estruturado | ❌ | ⚠️ | ✅ |
| **CORS** | ✅ Configurável | ⚠️ (Middleware externo) | ✅ | ✅ |
| **Async/Await** | ❌ (Limitação da linguagem*) | ❌ | ❌ | ✅ |

*\* O Dext utiliza Tasks e Futures para operações assíncronas onde possível.*

**Legenda:**

- ✅ = Suporte completo e nativo
- ⚠️ = Suporte parcial ou requer configuração adicional
- ❌ = Não suportado ou requer biblioteca externa

---

## 📅 Roadmaps Específicos

O desenvolvimento do Dext é dividido em áreas de especialização. Consulte os roadmaps específicos para detalhes:

1. [🌐 Web Framework Roadmap](web-roadmap.md) (APIs, MVC, Hubs)
2. [🗺️ ORM Roadmap](orm-roadmap.md) (Entity Context, Migrations, Drivers)
3. [🏗️ Infrastructure Roadmap](infra-roadmap.md) (Core, Performance, Span)
4. [🧠 AI Roadmap](ai-roadmap.md) (GenAI, semantic Kernel - *Planned*)
5. [🛠️ IDE Integration Roadmap](ide-roadmap.md) (TestInsight, Wizards)

---

## 📅 Status de Implementação (v1.0)

### 1. Core & Arquitetura (✅ Concluído)
- [x] **IHost / IWebApplication**: Abstração do ciclo de vida da aplicação.
- [x] **Dependency Injection**: Container IOC completo (Singleton, Scoped, Transient).
- [x] **Configuration**: Sistema de configuração (JSON, Environment Variables).
- [x] **Logging**: Abstração `ILogger` estruturado.
- [x] **Testing Framework**: Suíte nativa com Fluent Assertions e Mocks Dinâmicos.
- [x] **IDE Integration**: Integração nativa com **TestInsight** para execução fluida na IDE.

### 2. HTTP & Routing (✅ Concluído)
- [x] **Routing**: Árvore de rotas, parâmetros regex e constraints.
- [x] **Minimal APIs**: Sintaxe moderna estilo .NET 6+.
- [x] **Model Binding**: Vinculação inteligente de múltiplos sources (Body, Query, etc).
- [x] **Multipart/Form-Data**: Suporte a upload de arquivos e formulários.

### 3. Entity ORM (✅ Concluído - v1.0)
- [x] **Migrations System**: Evolução Code-First com Rollback.
- [x] **Fluent API**: Queries tipadas e `TypeOf` inteligente.
- [x] **Multi-Tenancy**: Suporte a Column, Schema e Database isolation.
- [x] **Multi-Dialect**: Suporte nativo a PostgreSQL, SQL Server, MySQL, SQLite e Firebird.

### 4. Middleware & Avançado (✅ Concluído)
- [x] **Swagger/OpenAPI**: Geração automática de documentação.
- [x] **Rate Limiting**: 4 algoritmos de proteção contra abuso.
- [x] **Web Hubs (Real-Time)**: Comunicação bidirecional via WebSockets/Polling.
- [x] **Action Filters**: Filtros de requisição declarativos e poderosos.

---

## 🎯 Próximos Passos (v1.1+)
1. **Performance**: Otimizações de baixo nível no pipeline de middlewares.
2. **Dext AI**: Início da implementação do módulo de orquestração de LLMs.
3. **Wizards**: Criação de assistentes na IDE para novos projetos e entidades.
4. **Cloud Connectors**: Suporte nativo a Azure/AWS/GCP Services.

---

## 🤝 Como Contribuir
O projeto é Open Source e aceita contribuições! Veja o guia de contribuição nos documentos do sistema.

---
*Última atualização: 07 de Abril de 2026*
