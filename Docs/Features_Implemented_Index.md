# 📑 Dext Framework - Features Implemented Index

Este documento serve como um índice mestre de todas as funcionalidades implementadas no Dext Framework. Ele deve ser usado como referência para auditorias de qualidade, documentação e cobertura de testes.

> [!IMPORTANT]
> Este índice foi gerado via "Raio-X" técnico nos fontes direto. Se uma feature está aqui, ela possui implementação validada no `Sources/`.

---

## 🧩 1. Dext Core Foundation (Sources\Core)

Fundação de baixo nível e utilitários de alto desempenho.

- [x] **Dext.Core.Reflection**:
  - [x] **Smart Properties**: Resolução recursiva de caminhos (ex: `User.Address.Street`).
  - [x] **Metadata Engine**: Cache global de tipos (`TTypeMetadata`) e scanning de atributos.
- [x] **Dext.DI (Dependency Injection)**:
  - [x] **Hybrid Model**: Suporte a ARC (Interfaces) e Não-ARC (Classes) simultaneamente.
  - [x] **Lifecycles**: Singleton, Transient e Scoped (Request-bound).
- [x] **Dext.Json (High Performance)**:
  - [x] **UTF-8 Engine**: Driver-based com suporte a buffers `IDataReader`.
  - [x] **Automatic Casing**: Conversão nativa para PascalCase, camelCase e **snake_case**.
- [x] **Dext.Configuration**:
  - [x] **Hierarchical Config**: Chaves delimitadas estilo .NET (`Server:App:Port`).
  - [x] **Multi-Provider**: Precedência garantida entre JSON, EnvVars e CLI.
- [x] **Dext.Types.UUID**:
  - [x] **RFC 9562 Compliance**: Suporte nativo a **UUID v7 (Time-ordered)**.
  - [x] **Network Byte Order**: Armazenamento Big-Endian para interop direta com PostgreSQL.
- [x] **Dext.Core.Activator**:
  - [x] **Greedy Strategy**: Resolução "gulosa" de construtores otimizada para DI.
  - [x] **Auto-Collections**: Instanciação automática de `TList\<T\>` para `IList\<T\>`.

---

## 🌐 2. Dext Web Framework (Interfaces & Hosting)

- **Status**: RC 1.0 (Curadoria concluída)
- **Pipeline de Middlewares**: Arquitetura baseada em "Chain of Responsibility" (estilo .NET). Suporta middlewares funcionais (delegates) e baseados em classe com injeção de dependência via construtor.
- **Minimal API & Bootstrapping**: Classe `TWebApplication` para inicialização fluente. Inclui carregamento automático de configurações (`appsettings.json`, `appsettings.yaml`, Environment Variables), registro de serviços e build do pipeline em uma única fachada.
- **Roteamento Avançado**: Motor de rotas com suporte a parâmetros dinâmicos (ex: `{id}`), restrições de rota e versionamento nativo de API via cabeçalho, query ou path.
- **Model Binding Inteligente**:
  - Atributos para vinculação explícita: `[FromBody]`, `[FromQuery]`, `[FromRoute]`, `[FromHeader]`, `[FromServices]`.
  - Suporte a **Hybrid Binding**: Um único record pode receber dados de múltiplas fontes HTTP simultaneamente.
  - Otimização **Zero-Allocation**: Deserialização UTF-8 direta para recordes, minimizando o uso de memória em requisições de alta frequência.
- **Hosting Foundation**:
  - Abstrações de `IWebHost`, `IWebHostBuilder` e `IHttpContext`.
  - Servidor padrão baseado em **Indy** (`TDextIndyWebServer`) com suporte a **OpenSSL** e **Taurus SSL**.
  - Suporte a `IHostedService` para tarefas de background integradas ao ciclo de vida do servidor.
  - Sincronização automática de schema (Auto-Migrations) durante o startup do host.
- **Segurança & Identidade**: Abstração de `IClaimsPrincipal` integrada ao `IHttpContext.User` para suporte a autenticação JWT e baseada em cookies.
- **Middleware Pipeline**: Logger, Compression (GZip/Brotli), Exception Handling (ProblemDetails), DeveloperExceptionPage, CORS e StartupLock.
- **Rate Limiting**: Políticas de Fixed/Sliding Window, Token Bucket e Concurrency.
- **Response Caching**: Suporte a In-Memory e **Redis**.
- **API Documentation**: Geração automática de **OpenAPI / Swagger** com atributos ricos.
- **Observability**: **Health Checks** com suporte a serviços externos e status detalhado.
- **View Engines**: Suporte a **Web Stencils** para Server-Side Rendering (SSR).
- **Real-time & Hubs**: 
  - [x] **SSE (Server-Sent Events)**: Suporte nativo para streaming unidirecional em tempo real.
  - [x] **Hubs Infrastructure**: Abstração inspirada no SignalR com `IHubContext` e `IHub`.
  - [x] **Protocols**: Suporte a JSON para mensagens de hub.
  - [ ] **WebSockets**: Suporte planejado (apenas interfaces e infraestrutura base no momento).
- **Event Bus & Messaging**:
  - [x] **Decoupled Events**: Sistema de Event Bus in-memory para comunicação entre camadas.
  - [x] **Event Behaviors**: Suporte a interceptores e comportamentos customizados no processamento de eventos.
  - [x] **DI Integration**: Registro e resolução automática de Event Handlers via Container DI.
- **Advanced Hosting Adapters**:
  - [x] **WebBroker Integration**: Permite rodar Dext em IIS (ISAPI), Apache (CGI) ou Standalone WebBroker.
  - [x] **Delphi CrossSockets (DCS)**: Adaptador de ultra-alta performance para Linux/Windows (requer DCS de terceiros).

---

## 📊 3. Dext ORM (Entity Framework style)

Persistência poliglota e produtividade.

- [x] **Core Persistence**: `TDbContext` (Unit of Work) e `DbSet<T>` (Repository).
- [x] **Change Tracking**: Monitoramento automático de estado (`Added`, `Modified`, `Deleted`, `Unchanged`).
- [x] **Identity Map**: Garantia de unicidade de instâncias por sessão.
- [x] **Fluent API & Mapping**: Configuração via `OnModelCreating` e Atributos ricos (`[Table]`, `[Column]`, `[Key]`).
- [x] **Relacionamentos & Loading**: One-to-One, One-to-Many, Many-to-Many, **Lazy Loading** e **Eager Loading** (`Include`/`ThenInclude`).
- **Query Engine (LINQ-like)**: Query fluída com Projeção (`Select`), Paging, Aggregates e SQL Cache.
- [x] **Performance**: **Streaming Iterators** (Flyweight pattern) para leitura de grandes volumes com baixo GC.
- [x] **Dataset & UI**: **EntityDataSet** especializado para mapear listas de objetos na VCL/FMX, com suporte nativo a **Design-Time Data Preview** em tempo real sem precisar compilar, Sorting e Filtering inline.
- [x] **Type System**: Suporte nativo a **Smart Properties** (`Prop\<T\>`), **Nullable\<T\>** e **UUID v7 (RFC 9562)**.
- [x] **JSON Support**: Mapeamento transparente de colunas **JSON/JSONB**.
- [x] **Migrations System**: Evolução Code-First automatizada com snapshots cronológicos.
- [x] **Poliglota (Dialetos)**: PostgreSQL, SQL Server, MySQL, SQLite, Oracle e Firebird.
- [x] **Multi-Tenancy**: Filtro global de tenant isolado automaticamente (`ITenantAware`).
- [x] **Data Normalization**: Conversores de tipo para GUID, Enums (String/Int) e Arrays.

---

## 🧪 4. Dext Testing Framework

Qualidade garantida com ferramentas nativas.

- [x] **Test Runner**: CLI e Host interno de alta velocidade.
- [x] **Assertions**: Fluent Assertions para legibilidade.
- [x] **Mocking Framework**: Criação dinâmica de Mocks via Proxy.
- [x] **IDE Integration**: Integração nativa com **TestInsight**.
- [x] **Reporting**: Relatórios HTML e JSON para CI/CD.

---

## 📦 5. Dext Networking & Connectivity

- [x] **Dext.Net.RestClient**: Cliente HTTP moderno e fluente com suporte nativo a JSON e tratamento de erros.
- [x] **Connection Pooling**: Gerenciamento de conexões de rede para alto rendimento e reuso de sockets.
- [x] **Dext.Net.Authentication**: Suporte extensível a autenticação para consumo de APIs (Bearer, Basic, Custom).

---

## 🖥️ 6. Dext UI Framework (VCL/FMX)

- [x] **MVU Architecture**: Implementação do padrão *Model-View-Update* para interfaces reativas e previsíveis.
- [x] **UI Navigator**: Sistema de navegação centralizado com suporte a **Middlewares** e **Adaptações** para diferentes plataformas.
- [x] **State Management**: Gerenciamento de estado de UI desacoplado e imutável.
- [x] **UI Data Binding**: Vinculação de dados poderosa entre ViewModels/State e componentes visuais.

---

---

*Dext Framework - Index updated after full Sources sweep on April 08, 2026.*
