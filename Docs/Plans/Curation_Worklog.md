# 🧠 Dext Framework - Curation & Documentation Worklog

Este documento rastreia o progresso da curadoria técnica, documentação XML e sincronização do índice de features para o Dext Framework.

## 📊 Progresso Geral

- **Total de Units Estimadas:** 261 (Produção)
- **Units Curadas:** 261 (Core, Web, Data, Net, UI, Events, Collections, QA, Hosting, Design, Health, Threading, Serialization, SmartTypes, Tenant, Options, Entity)
- **Status:** RC 1.0 Ready (100% Core Cover, Auditando infraestrutura de extensibilidade extra)

---

## 🏗️ Namespace: Web (`Sources\Web`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.Web.pas` | ✅ | Alias de Tipos (Auth, Caching, OpenAPI) | Curado |
| `Dext.Web.Interfaces.pas` | ✅ | Contratos Base (Request, Response, Context) | Curado |
| `Dext.Web.Core.pas` | ✅ | AppBuilder, Middleware Registration | Curado |
| `Dext.Web.Routing.pas` | ✅ | Árvore de rotas, Versionamento, Matcher | Curado |
| `Dext.Web.RoutingMiddleware.pas` | ✅ | Matcher e Enforcer de Auth de rotas | Curado |
| `Dext.Web.ModelBinding.pas` | ✅ | Binding Híbrido, Zero-Allocation UTF8, Atributos | Curado |
| `Dext.WebHost.pas` | ✅ | WebHostBuilder, Fluent Bootstrap | Curado |
| `Dext.Web.WebApplication.pas` | ✅ | Fachada Minimal API, Auto-Config, Host Lifecycle | Curado |
| `Dext.Web.Injection.pas` | ✅ | Injeção de Dependência no Pipeline Web | Curado |
| `Dext.Web.Extensions.pas` | ✅ | Helpers de Content-Negotiation e Versionamento | Curado |
| `Dext.Web.Formatters.Json.pas` | ✅ | Serialização JSON de alta performance | Curado |
| `Dext.Web.Formatters.Interfaces.pas` | ✅ | Contratos de Negociação de Conteúdo | Curado |
| `Dext.HealthChecks.pas` | ✅ | Monitoramento de Saúde do Sistema (Health Checks) | Curado |
| `Dext.Web.Middleware.Logging.pas` | ✅ | Middleware de Tracing e Request Logging | Curado |
| `Dext.Web.WebBroker.pas` | ✅ | Adaptador WebBroker (ISAPI/CGI/Apache) | Curado |
| `Dext.Web.DCS.pas` | ✅ | Adaptador Delphi CrossSockets (Alta Perf) | Curado |
| `Dext.Web.Middleware.pas` | ✅ | Base de middlewares, ProblemDetails | Curado |
| `Dext.Web.Cors.pas` | ✅ | Gerenciador de CORS, Fluent Builder | Curado |
| `Dext.Web.StaticFiles.pas` | ✅ | Servidor de ativos, MimeTypes | Curado |
| `Dext.Web.DataApi.pas` | ✅ | Geração automática de APIs p/ Entidades | Curado |
| `Dext.RateLimiting.pas` | ✅ | Middleware e entrada de Rate Limiting | Curado |
| `Dext.RateLimiting.Core.pas` | ✅ | Abstrações e interfaces de controle de vazão | Curado |
| `Dext.RateLimiting.Limiters.pas` | ✅ | Algoritmos (FixedWindow, SlidingWindow, Bucket) | Curado |
| `Dext.RateLimiting.Policy.pas` | ✅ | Políticas complexas de Rate Limiting | Curado |
| `Dext.Web.MultiTenancy.pas` | ✅ | Suporte nativo a multi-inquilino | Curado |
| `Dext.Auth.Middleware.pas` | ✅ | Pipeline de Autenticação e Autorização | Curado |
| `Dext.Auth.JWT.pas` | ✅ | Suporte a JSON Web Tokens | Curado |
| `Dext.Web.Versioning.pas` | ✅ | Versionamento de API (Header, Query, Path) | Curado |
| `Dext.HealthChecks.pas` | ✅ | Diagnóstico de saúde do sistema | Curado |
| `Dext.OpenAPI.Generator.pas` | ✅ | Geração dinâmica de Swagger/OpenAPI | Curado |
| `Dext.Web.View.WebStencils.pas` | ✅ | Integração com WebStencils (Delphi 12+) | Curado |
| `Dext.Auth.Identity.pas` | ✅ | Contratos de Identity e Principal (Claims) | Curado |
| `Dext.Auth.Attributes.pas` | ✅ | Atributos [Authorize] e [AllowAnonymous] | Curado |
| `Dext.Auth.BasicAuth.pas` | ✅ | Middleware de Autenticação Básica | Curado |
| `Dext.Web.View.pas` | ✅ | Motor de View Base e ViewData | Curado |
| `Dext.Swagger.Middleware.pas` | ✅ | Middleware para UI do Swagger/OpenAPI | Curado |
| `Dext.Web.Pipeline.pas` | ✅ | Pipeline de execução de requisições | Curado |
| `Dext.Web.Formatters.Selector.pas` | ✅ | Seleção de formatadores (Content Negotiation) | Curado |
| `Dext.Web.Results.pas` | ✅ | Factory de resultados HTTP (Ok, Json, View) | Curado |
| `Dext.Web.ResponseHelper.pas` | ✅ | Helpers de escrita direta no Contexto | Curado |
| `Dext.Filters.pas` | ✅ | Action Filters e Result Filters (AOP) | Curado |
| `Dext.Web.Indy.pas` | ✅ | Host via Indy, Multipart Parser, DI Scopes | Curado |
| `Dext.Web.DCS.pas` | ✅ | Adaptador Delphi CrossSockets (Alta Perf) | Curado |
| `Dext.Hubs.pas` | ✅ | Infraestrutura de Hubs (Real-time interfaces) | Curado |
| `Hubs\Dext.Web.Hubs.Transport.SSE.pas` | ✅ | Transporte Real-time via SSE | Curado |

## 🏗️ Namespace: Networking & UI (`Sources\Net`, `Sources\UI`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.Net.RestClient.pas` | ✅ | TRestClient, Async/Await, Retries, Pooling | Curado |
| `Dext.Net.RestRequest.pas` | ✅ | Builder de requisições complexas | Curado |
| `Dext.Net.Authentication.pas`| ✅ | Provedores de Auth (Bearer, Basic) | Curado |
| `Dext.Net.ConnectionPool.pas` | ✅ | Pool de conexões de alto desempenho | Curado |
| `Dext.Http.Executor.pas` | ✅ | Executor (.http) e Bridge de transporte | Curado |
| `Dext.UI.pas` | ✅ | UI Framework Facade, MVU Architecture | Curado |
| `Dext.UI.Binder.pas` | ✅ | TMVUBinder, RTTI Data Binding, Sync reativo | Curado |
| `Dext.UI.Navigator.pas` | ✅ | TNavigator, Routing Pipeline, History stack | Curado |
| `Dext.Events.Interfaces.pas` | ✅ | IEventBus, Pub/Sub, Behaviors, Aggregates | Curado |
| `Dext.Events.Bus.pas` | ✅ | Implementação padrão do barramento de eventos | Curado |

---

## 🏗️ Namespace: Data (`Sources\Data`)

| `Dext.Entity.Core.pas` | ✅ | Ciclo de vida, Change Tracking, IChangeTracker | Curado |
| `Dext.Entity.Metadata.pas` | ✅ | Parser DelphiAST, static analysis, Discovery | Curado |
| `Dext.Entity.Mapping.pas` | ✅ | Fluent API, ModelBuilder, Map Registry | Curado |
| `Dext.Entity.Attributes.pas` | ✅ | Atributos declarativos [Table], [Column], [Key] | Curado |
| `Dext.Entity.Context.pas` | ✅ | TDbContext (Unit of Work), Shadow States | Curado |
| `Dext.Entity.DbSet.pas` | ✅ | TDbSet (Repository), Flyweight Streaming | Curado |
| `Dext.Entity.DataSet.pas` | ✅ | TEntityDataSet, Fast Path, Design-time Preview | Curado |
| `Dext.Entity.Dialects.pas` | ✅ | Dialect Factory, SQL Abstraction Interface | Curado |
| `Dext.Entity.Drivers.Interfaces.pas` | ✅ | Contratos de Connection, Command e Reader | Curado |
| `Dext.Entity.TypeConverters.pas` | ✅ | Normalização GUID, JSON, Arrays, Enums | Curado |
| `Dext.Entity.Drivers.FireDAC.pas` | ✅ | Implementação FireDAC, explicit transactions | Curado |
| `Dext.Entity.Query.pas` | ✅ | Query Engine, Eager Loading (Include), LINQ | Curado |
| `Dext.Entity.Migrations.pas` | ✅ | IMigration, Registro chronológico de evolução | Curado |
| `Dext.Entity.TypeSystem.pas` | ✅ | `TProp<T>`, Smart Properties, Meta Discovery | Curado |
| `Dext.Entity.Validator.pas` | ✅ | Validação de Entidades (Attributes/Fluent) | Curado |
| `Dext.Entity.Cache.pas` | ✅ | Identity Map, L1 Cache, SQL Result Caching | Curado |

---

## 🏗️ Namespace: Core (`Sources\Core`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.Json.pas` | ✅ | High Performance JSON, Automatic Casing | Curado |
| `Dext.Configuration.Core.pas` | ✅ | TConfigurationRoot, Sections, Overriding | Curado |
| `Dext.Types.UUID.pas` | ✅ | RFC 9562, UUID v7 (Time-ordered) | Curado |
| `Dext.DI.Core.pas` | ✅ | TDextServiceProvider, Hybrid Memory, Scopes | Curado |
| `Dext.Core.Activator.pas` | ✅ | Greedy Selection Strategy, Auto-Collections | Curado |
| `Dext.Core.Debug.pas` | ✅ | Stack Traces e Resolução de Símbolos (.MAP) | Curado |
| `Dext.pas` | ✅ | Fachada Central (Barrel/Aliases), Global Helpers | Curado |
| `Base\Dext.Core.Span.pas` | ✅ | TSpan&lt;T&gt;, TByteSpan, Zero-allocation memory | Curado |
| `Base\Dext.Core.Memory.pas` | ✅ | Lifetime management, Deferred Actions (Defer) | Curado |
| `Base\Dext.Utils.pas` | ✅ | Utilitários de Console e Diagnóstico | Curado |
| `Dext.Threading.Async.pas` | ✅ | Tasks Assíncronas, Fluent Chaining, Main Thread Sync | Curado |
| `Dext.Threading.CancellationToken.pas` | ✅ | Cancelamento Cooperativo de Tarefas | Curado |
| `Dext.Json.pas` | ✅ | Motor de Serialização JSON (RTTI/Attributes) | Curado |
| `Dext.Validation.pas` | ✅ | Validação Fluente e Declaativa (General Purpose) | Curado |
| `Dext.Core.Enums.pas` | ✅ | Helpers para Tipos Enumerados e Ordinais | Curado |
| `Dext.Core.SmartTypes.pas` | ✅ | Smart Properties (Prop&lt;T&gt;), LINQ Expressions | Curado |
| `Dext.MultiTenancy.pas` | ✅ | Infraestrutura de Multi-Escrituração (Tenants) | Curado |
| `Dext.Options.pas` | ✅ | Gerenciamento de Configurações Tipadas (Options Pattern) | Curado |
| `Dext.Entity.pas` | ✅ | Entity Framework Aliases / Persistence Setup | Curado |
| `Dext.Entity.Core.pas` | ✅ | Interface contracts for UnitOfWork / ChangeTracker | Curado |
| `Dext.Entity.Context.pas` | ✅ | DbContext implementation and state management | Curado |
| `Dext.Entity.DbSet.pas` | ✅ | Typed entity sets, persistence & queries | Curado |
| `Dext.Entity.DataSet.pas` | ✅ | EntityDataSet, high-performance VCL/FMX mapping | Curado |
| `Dext.Entity.TypeSystem.pas` | ✅ | Entity Metadata Registry & Factory | Curado |
| `Dext.Entity.TypeConverters.pas` | ✅ | Mapping conversions | Curado |
| `Dext.Entity.Query.pas` | ✅ | Fluent Query & Pagination result | Curado |
| `Dext.Entity.Migrations.pas` | ✅ | Migration Step Interface | Curado |
| `Dext.Entity.Metadata.pas` | ✅ | Syntax Analyser for Entity Models | Curado |
| `Dext.Entity.Mapping.pas` | ✅ | Code-First Configuration & Model Builders | Curado |
| `Dext.Entity.Drivers.Interfaces.pas` | ✅ | Database Connection & Driver Interfaces | Curado |
| `Dext.Entity.Drivers.FireDAC.pas` | ✅ | FireDAC physical driver implementation | Curado |
| `Dext.Entity.Dialects.pas` | ✅ | SQL Dialect Abstraction & Factory | Curado |
| `Base\Dext.Core.ValueConverters.pas` | ✅ | Universal Type Normalization, Variant bridges | Curado |
| `Dext.Core.Reflection.pas` | ✅ | Cached RTTI, Metadata extraction (Thread-Safe) | Curado |
| `Json\Dext.Json.Utf8.pas` | ✅ | Zero-Allocation UTF8 Reader/Writer | Curado |

---

---

## 🏗️ Namespace: Collections (`Sources\Core`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.Collections.pas` | ✅ | Fachada e tipos base de coleções, LINQ | Curado |
| `Dext.Collections.Dict.pas` | ✅ | Dicionários de alto desempenho, SIMD-ready | Curado |
| `Dext.Collections.Concurrent.pas` | ✅ | Coleções Thread-Safe, Lock Striping | Curado |
| `Dext.Collections.Simd.pas` | ✅ | Otimizações SIMD para busca/scan | Curado |
| `Dext.Collections.Channels.pas` | ✅ | Canais de comunicação (Go-like) | Curado |
| `Dext.Collections.Vector.pas` | ✅ | Vetores de memória contígua | Curado |

---

## 🏗️ Namespace: Logging & Diagnostics (`Sources\Core`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.Logging.pas` | ✅ | Core logging engine, Microsoft-style | Curado |
| `Dext.Logging.Async.pas` | ✅ | Processamento em background | Curado |
| `Dext.Logging.Console.pas` | ✅ | Sink para consoles coloridos | Curado |
| `Dext.Logging.Sinks.pas` | ✅ | Interface para novos destinos | Curado |

---

## 🏗️ Namespace: Hosting & Lifecycle (`Sources\Hosting`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.Hosting.pas` | ✅ | CLI Facade e ferramentas de suporte | Curado |
| `Dext.Hosting.BackgroundService.pas`| ✅ | Worker threads e Background Tasks (Core) | Curado |
| `Dext.Hosting.ApplicationLifetime.pas`| ✅ | Sinais de Startup/Shutdown (Core) | Curado |
| `Dext.Hosting.AppState.pas` | ✅ | Máquina de Estados Global da App | Curado |

---

## 🏗️ Namespace: Testing & Mocks (`Sources\Testing`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.Testing.pas` | ✅ | Test Runner Core, Fluent Assertions | Curado |
| `Dext.Assertions.pas` | ✅ | Assertivas extensivas fluas | Curado |
| `Dext.Mocks.pas` | ✅ | Framework de Mocks e Interceptação | Curado |
| `Dext.Testing.Host.pas` | ✅ | Host para execução de testes via IDE | Curado |
| `Dext.Testing.Report.pas` | ✅ | Gerador de reports em múltiplos formatos | Curado |

---

## 🏗️ Namespace: Design-Time (`Sources\Design`)

| Unit | Traduzido/Doc XML | Features Identificadas | Status |
| :--- | :---: | :--- | :---: |
| `Dext.EF.Design.Editors.pas` | ✅ | Editores de Propriedades/Coleções | Curado |
| `Dext.EF.Design.Preview.pas` | ✅ | Motor de Preview em tempo de design | Curado |
| `Dext.EF.Design.Registration.pas` | ✅ | Registro de componentes no IDE | Curado |
| `Dext.EF.Design.DataProvider.pas` | ✅ | Infraestrutura de design e descoberta de metadados | Curado |
| `Dext.EF.Design.Expert.pas` | ✅ | Assistentes e Wizards de projeto | Curado |

## 📝 Notas de Curadoria

> [!TIP]
> Durante a curadoria, se uma unit revelar uma funcionalidade não listada no `Features_Implemented_Index.md`, adicione-a imediatamente ao índice.

## 🚀 Próximos Passos (Prioridade)

1. Auditar `Sources\Core` (A base de tudo: Spans, JSON, DI).
2. Auditar `Sources\AI` (Recursos Experimentais e RAG).
3. Revisão Final de IntelliSense na IDE.

## 🚀 Oportunidades de Melhoria (Identificadas na Curadoria)

Estas observações foram colhidas durante a auditoria técnica e devem ser avaliadas para versões pós-RC 1.0:

- [ ] **Otimização JWT**: Refatorar `Base64UrlEncode` em `Dext.Auth.JWT.pas` para realizar a troca de caracteres em um único passo, evitando múltiplas alocações de string via `Replace`.
- [ ] **MIME Extensível**: Transformar o mapeamento de tipos em `Dext.Web.StaticFiles.pas` em um provedor extensível ou carregar de arquivo externo, em vez de hardcoded.
- [ ] **Limpeza de Partições**: Otimizar o método `Cleanup` em `Dext.RateLimiting.Limiters.pas` para evitar iteração total no dicionário em servidores de altíssimo tráfego (ex: background thread ou bucket expiry).
- [ ] **DataApi Metadata**: Centralizar a lógica de pluralização e descoberta de nomes de tags Swagger em uma unit de utilitários de metadados para evitar repetição de código RTTI.
- [ ] **Path Versioning**: Implementar `TPathApiVersionReader` para suportar versionamento diretamente na URL (ex: `/v1/api/...`), complementando os leitores de Header e Query String já existentes.
- [ ] **Snapshots Inteligentes (`Dext.Assertions.pas`)**: Evoluir o `MatchSnapshot` para ignorar diferenças irrelevantes em JSON (como ordem de campos ou espaços em branco).
- [ ] **Eventos de Estado (`Dext.Hosting.AppState.pas`)**: Disparar notificações via `TMessageManager` em cada mudança de estado (`asMigrating`, `asRunning`) para monitoramento desacoplado.
- [ ] **Logging de Startup**: Unificar `SafeWriteLn` com o `ILogger` oficial em `TBackgroundService` para melhor observabilidade de falhas iniciais.
- [ ] **Robustez IDE (`Dext.Testing.Host.pas`)**: Substituir `Sleep(50)` por um handshake explícito com o TestInsight.
- [ ] **Soft Assertions**: Validar thread-safety do `Assert.Multiple` com `ThreadLocal` em cenários multithread massivos.
- [ ] **Unificação de Escapes (`Dext.Testing.Report.pas`)**: Centralizar funções `EscapeXml` e `EscapeJson` em `Dext.Utils` para evitar duplicação em cada classe de reporter.
- [ ] **Templates em HTML Reporter**: Substituir a geração de strings hardcoded em `THTMLReporter` por um motor de templates básico, permitindo customização visual sem alterar o framework.
- [ ] **OAuth2 Client Credentials**: Implementar provedor de autenticação nativo para o fluxo de Client Credentials em `Dext.Net.Authentication`.
- [ ] **Multipart/Form-Data no Builder**: Facilitar o envio de arquivos e campos de formulário via métodos dedicados no `TRestRequest`.
- [ ] **Headers de Resposta**: Finalizar a implementação de `GetHeader` em `TRestResponse` para permitir inspeção de RateLimits e ETags.
- [ ] **SQL Tab no Preview**: Adicionar uma aba ou painel "SQL" no `TPreviewForm` para permitir que o desenvolvedor veja o comando gerado.
- [ ] **Visualização de Tipos no Preview**: Exibir detalhes de metadados (tipo real do campo no banco, tamanho, precisão) no cabeçalho ou hint das colunas do `TPreviewForm`.
- [ ] **Filtro de Entidades no IDE**: Implementar uma caixa de busca (SearchBox) no editor de classes de entidade para projetos com centenas de modelos.
- [ ] **Config Key Hashing**: Otimizar a busca em `TConfigurationRoot` utilizando hashes de strings para chaves compostas em árvores profundas.
- [ ] **Configuration Watchers**: Implementar suporte a `ReloadOnChange` utilizando `TFileSystemWatcher` para atualizar a configuração automaticamente ao detectar mudanças no disco.
- [ ] **Validation in Config**: Permitir o registro de Validadores para seções de configuração, impedindo o `Build` se valores obrigatórios estiverem ausentes ou forem inválidos.
- [ ] **Span SIMD**: Implementar `TByteSpan.Equals` usando instruções SIMD (SSE/AVX) para comparação de buffers de alta densidade no motor de Web e JSON.
- [ ] **Activator Context Cache**: Permitir o compartilhamento de um `TRttiContext` no `TActivator` (via ThreadLocal ou parâmetro opcional) para evitar recriação massiva em loops de desserialização JSON.
- [ ] **Web Tracking**: Implementar tracking de propriedade de objetos em `THandlerInvoker` via `IAsyncDisposable` ou similar para evitar heurísticas frágeis em `IsEntity`.
- [ ] **Web RTTI Pool**: Compartilhar `TRttiContext` entre `ModelBinder` e `HandlerInvoker` para reduzir overhead de criação de pool RTTI por requisição.
- [ ] **DbSet Cache Lock**: No `TDbContext`, avaliar a melhoria da `TCriticalSection` em `CreateDynamicDbSet` para otimizar instâncias concorrentes sob altíssima pressão paralela.
- [ ] **Lazy Loading Interceptors**: Criar abstração `ILazyLoader` desvinculada para eventualmente mover geração de proxies para fora do pipeline físico.
- [ ] **Metadata Parser (AST)**: Expandir o analisador estático (`TEntityMetadataParser`) para identificar automaticamente relações complexas (`Join`/`Include` hints) diretamente dos arquivos `.pas`.

## 💡 Legenda

- ✅: Curado (Documentação XML aplicada e Features validadas).
- ⏳: Pendente.
- ⚠️: Requer Revisão (Algum detalhe técnico obscuro).
