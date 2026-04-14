# 🗺️ Dext Framework: Master Roadmap

This is the centralized roadmap for the Dext Framework. It tracks the progress of core features, architectural specifications, and the path to the V1.0 Stable release.

> [!TIP]
> This document is the Single Source of Truth for project status. Individual language-specific guides in the Book point here.

---

# 🇬🇧 English: Roadmap & Backlog

## 🟢 Wave 1: Quick Wins & Visibility (Immediate)
Status | Task | Spec | Description
:---: | :--- | :---: | :---
✅ | **Dynamic Port Binding** | [S08](Specs/S08-Dynamic-Ports.md) | Support for Port 0 (OS chooses free port) for Demos and CI.
✅ | **DataAPI Conventions** | [S04](Specs/S04-DataApi-Conventions.md) | Auto-discovery, 'T' prefix stripping, and Smart Attributes.
✅ | **DataAPI Observability** | - | CRUD diagnostic logs and mapping tracking.
🟡 | **Examples Roadmap** | [Ref](roadmap/EXAMPLES_ROADMAP.md) | Create high-fidelity examples for existing features.
🟡 | **Agent Guidelines** | [AI](CONTRIBUTING_AI.md) | Finalize `CONTRIBUTING_AI.md` and related Workflows.

## 🔵 Wave 2: Performance & Productivity (Foundation)
Status | Task | Spec | Description
:---: | :--- | :---: | :---
🔴 | **High-Perf Reflection** | [S07](Specs/S07-High-Perf-Reflection.md) | Type Handler Registry to eliminate RTTI/TValue overhead.
✅ | **Advanced Scaffolding** | [S01](Specs/S01-Advanced-Scaffolding.md) | New CLI template engine (`dext new`, `dext add`).
✅ | **Template Engine** | [S09](Specs/S09-Template-Engine.md) | Zero-dependency AST-based template engine (Razor-like).
🟡 | **Dext IDE Explorer** | [S05](Specs/S05-Advanced-Tooling.md) | Initial visual tool for Migrations inside the IDE.
🟡 | **Production Middleware** | - | SPA Fallback, Forwarded Headers, and Resilience.

## 🔴 Wave 3: Enterprise & Modernization (Stability)
Status | Task | Spec | Description
:---: | :--- | :---: | :---
🟡 | **gRPC & Protobuf** | [S02](Specs/S02-Modernizer-gRPC.md) | Native IOCP/EPOLL engine for high-speed binary communication.
🟡 | **OAuth2 & OIDC** | [S06](Specs/S06-Security-Identity.md) | Native support for JWT, Google, and Microsoft Login.
🔴 | **Live Tracing** | [S03](Specs/S03-Live-Observability.md) | Real-time instrumentation and observability dashboard.
🔴 | **EntityDataSet Providers** | - | Pluggable providers (REST/gRPC) for EntityDataSet.

## 🔮 Future / Post-V1
- [ ] **OData Support**: Full OData query support.
- [ ] **GraphQL**: Native layer for data graphs.
- [ ] **Microservices Mesh**: Service discovery and native Load Balancing.

---

# 🇧🇷 Português: Roadmap & Backlog

## 🟢 Onda 1: Quick Wins & Visibilidade (Imediato)
Status | Tarefa | Spec | Descrição
:---: | :--- | :---: | :---
✅ | **Portas Dinâmicas** | [S08](Specs/S08-Dynamic-Ports.md) | Suporte a Porta 0 (SO escolhe porta livre) para Demos e CI.
✅ | **Convenções DataAPI** | [S04](Specs/S04-DataApi-Conventions.md) | Auto-discovery, remover prefixo 'T' e Smart Attributes.
✅ | **Observabilidade DataAPI** | - | Logs de diagnóstico CRUD e rastreamento de mapeamento.
🟡 | **Roadmap de Exemplos** | [Ref](roadmap/EXAMPLES_ROADMAP.md) | Criar exemplos de alta fidelidade para features existentes.
🟡 | **Agent Guidelines** | [AI](CONTRIBUTING_AI.md) | Finalizar o `CONTRIBUTING_AI.md` e Workflows.

## 🔵 Onda 2: Performance & Produtividade (Fundação)
Status | Tarefa | Spec | Descrição
:---: | :--- | :---: | :---
🔴 | **High-Perf Reflection** | [S07](Specs/S07-High-Perf-Reflection.md) | Registry de Handlers para eliminar overhead de RTTI/TValue.
✅ | **Scaffolding Avançado** | [S01](Specs/S01-Advanced-Scaffolding.md) | Novo motor de templates CLI (`dext new`, `dext add`).
✅ | **Motor de Templates** | [S09](Specs/S09-Template-Engine.md) | Motor de templates baseado em AST, zero dependência (estilo Razor).
🟡 | **Dext IDE Explorer** | [S05](Specs/S05-Advanced-Tooling.md) | Ferramenta visual inicial para Migrations na IDE.
🟡 | **Middleware Pack** | - | SPA Fallback, Forwarded Headers e Resiliência.

## 🔴 Onda 3: Enterprise & Modernização (Estabilidade)
Status | Tarefa | Spec | Descrição
:---: | :--- | :---: | :---
🟡 | **gRPC & Protobuf** | [S02](Specs/S02-Modernizer-gRPC.md) | Motor nativo IOCP/EPOLL para comunicação binária.
🟡 | **OAuth2 & OIDC** | [S06](Specs/S06-Security-Identity.md) | Suporte nativo a JWT, Google/Microsoft Login.
🔴 | **Tracing Distribuído** | [S03](Specs/S03-Live-Observability.md) | Dashboard de instrumentação em tempo real.
🔴 | **Provider de EntityDataSet** | - | Providers plugáveis (REST/gRPC) para o EntityDataSet.

## 🔮 Futuro / Pós-V1
- [ ] **Suporte a OData**: Suporte completo a queries OData.
- [ ] **GraphQL**: Camada nativa para exposição de grafos de dados.
- [ ] **Microservices Mesh**: Service discovery e Load Balancing nativo.

---
*Last update: April 13, 2026*
