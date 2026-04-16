# S07 — High-Performance Reflection: Análise e Plano de Refactoring

> **Status:** ✅ **Finalized** — April 16, 2026  
> Todas as 5 fases implementadas, testadas e integradas ao branch `main`.

## 1. Estado Atual: Inventário Completo de RTTI no Dext

### 1.1 Contextos RTTI Existentes (Duplicação)

O framework possui **4 contextos RTTI independentes**, cada um com sua instância de `TRttiContext`:

| Componente | Localização | Tipo | Escopo |
|---|---|---|---|
| `TReflection.FContext` | `Dext.Core.Reflection.pas` | `class var` | Global (singleton) |
| `TActivator.FRttiContext` | `Dext.Core.Activator.pas` | `class var` | Global (singleton) |
| `TDextTemplateEngine.FRttiCtx` | `Dext.Templating.pas` | Instance field | Per-Rendering |
| `TEventBus.FRttiCtx` | `Dext.Events.Bus.pas` | Instance field | Per-EventBus |
| `TControllerScanner.FCtx` | `Dext.Web.ControllerScanner.pas` | Instance field | Per-WebApp |

Adicionalmente, **60+ instâncias locais** de `TRttiContext.Create` são criadas e destruídas em chamadas individuais de métodos, espalhadas por:

| Módulo | Arquivos com `TRttiContext.Create` local | Contagem |
|---|---|---|
| **Data (ORM)** | DbSet, Query, Mapping, LazyLoading, LazyLoader, ProxyFactory, Prototype, TypeConverters, TypeSystem, Validator, Collections, Context, DataSet, DataProvider, Migrations.Extractor, Specifications.SQL.Generator | ~40 |
| **Web** | DataApi, OpenAPI.Generator, ModelBinding, WebStencils, Injection | ~12 |
| **Hubs** | Protocol.Json, Middleware | ~3 |
| **Testing** | Assertions, Runner, Mocks.Auto | ~5 |
| **UI** | Navigator, Binder | ~2 |

> **NOTA**: O `TRttiContext.Create` do Delphi é um *record* que compartilha o *pool* de metadata RTTI via referência contada interna. Criar/destruir repetidamente não é "caro" em si, mas **cada `GetType`, `GetProperty`, `GetField` faz lookup** no pool. A otimização real está em **cachear os resultados dessas lookups**, não em cachear o Context.

### 1.2 Caches Existentes

| Cache | O que cacheia | Thread-Safe | Localização |
|---|---|---|---|
| `TReflection.FCache` | `TTypeMetadata` (SmartProp/Nullable/Lazy info) | Sim (CriticalSection) | `Dext.Core.Reflection.pas` |
| `TModelBuilder.Instance` | `TEntityMap` (mapping de entidades) | Não (init-only) | `Dext.Entity.Mapping.pas` |
| `TPropertyInfo` | PPropInfo + PTypeInfo + Converter | N/A (imutável) | `Dext.Entity.TypeSystem.pas` |
| `GetWebSharedRttiContext` | TRttiContext compartilhado para ModelBinding | Sim | `Dext.Web.ModelBinding.pas` |

### 1.3 Hot-Paths Identificados (Impacto Direto em Performance)

Estes são os caminhos que executam **por requisição HTTP** ou **por operação CRUD**:

1. **`TDbSet<T>.PersistAdd/PersistUpdate`** — Cria `TRttiContext`, faz `GetType`, itera propriedades, aplica `TReflection.SetValue` (que faz outro GetType/GetProperty interno)
2. **`TDataApiHandler.HandleGetList/HandleGet`** — `ValueToJson` usa RTTI para serializar cada propriedade
3. **`THandlerInvoker`** — Resolve parâmetros de ação MVC via RTTI em cada request.
4. **`TDextTemplateEngine.ResolveObjectProperty`** — Faz lookups de tipo e propriedade em cada loop `{{#each}}`.
5. **`TActivator.CreateInstance`** — Enumeração de construtores e parâmetros via RTTI.
6. **`TEntityProxyFactory`** — Cria proxies de lazy loading via RTTI
7. **`TSqlGenerator`** — Gera SQL iterando propriedades via RTTI
8. **`TPropertyInfo.GetValue/SetValue`** — Cria `TRttiContext` + `GetType` + `GetProperty` **por chamada**

> **CUIDADO**: `TPropertyInfo.GetValue/SetValue` (TypeSystem.pas linhas 161-193) é o caso mais grave: cria e destrói um `TRttiContext` a cada acesso de propriedade. Isso faz lookup duplo (GetType + GetProperty) em cada Set/Get de cada propriedade de cada entidade.

### 1.4 Funcionalidades Duplicadas

| Funcionalidade | Localização A | Localização B | Observação |
|---|---|---|---|
| Resolução de tipo genérico | `TReflection.GetCollectionItemType` | `TActivator.GetListElementType` | Lógica quase idêntica de parse de `<T>` no nome |
| Instanciação de objetos | `TReflection.CreateInstance` | `TActivator.CreateInstance` | TReflection delega para TActivator, mas ambas existem |
| Mapeamento de propriedades | `TEntityMap.Properties` | `TRttiType.GetProperties` (ad-hoc) | ORM cacheia no Map, mas muitos locais refazem GetProperties |
| Normalização de nomes | `TReflection.NormalizeFieldName` | `TDataApiNaming` (DataApi.pas) | Duas implementações de normalização PascalCase |

---

## 2. Proposta: Arquitetura do Handler Registry

### 2.1 Conceito Geral

Criar um **Type Handler Registry** centralizado que pré-computa e cacheia todo o metadata RTTI **uma única vez** (no startup ou no primeiro acesso), eliminando o overhead de lookup repetitivo nos hot-paths.

```
┌──────────────────────────────────────────────────┐
│                TTypeHandlerRegistry              │
│  (Singleton Thread-Safe)                         │
│                                                  │
│  FHandlers: IDictionary<PTypeInfo, TTypeHandler> │
│                                                  │
│  ┌─────────────────────────────────────────────┐ │
│  │            TTypeHandler                     │ │
│  │  TypeInfo: PTypeInfo                        │ │
│  │  Properties: TArray<TPropertyHandler>       │ │
│  │  Constructors: TArray<TConstructorInfo>     │ │
│  │  EntityMap: TEntityMap (ref)                │ │
│  │  Metadata: TTypeMetadata (ref)              │ │
│  └─────────────────────────────────────────────┘ │
│                                                  │
│  ┌─────────────────────────────────────────────┐ │
│  │          TPropertyHandler                   │ │
│  │  Name: string                               │ │
│  │  RttiProperty: TRttiProperty (cached ref)   │ │
│  │  TypeInfo: PTypeInfo                        │ │
│  │  Converter: IValueConverter                 │ │
│  │  IsPK, IsAutoInc, IsNullable: Boolean       │ │
│  │  ColumnName: string                         │ │
│  └─────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

### 2.2 Fases de Implementação

**Fase 1: Unificação de RTTI Context (Baixo Risco)**

- Eliminar todas as 60+ instâncias locais de `TRttiContext.Create`
- Usar `TReflection.Context` como o contexto global compartilhado
- Corrigir `TPropertyInfo.GetValue/SetValue` para usar o contexto global

**Fase 2: Property Handler Cache (Médio Risco)**

- Criar `TPropertyHandler` que pré-cacheia `TRttiProperty` + metadata
- Migrar `TDbSet`, `TSqlGenerator`, `TEntityProxyFactory` para usar handlers cacheados
- Eliminar loops `GetProperties` + `GetAttributes` em hot-paths

**Fase 3: Constructor Cache (Baixo Risco)**

- Pré-cachear seleção de construtores no `TActivator`
- Cachear resultado da estratégia "Greedy" por tipo

**Fase 4: Unificação de Duplicações**

- Consolidar `GetCollectionItemType` / `GetListElementType`
- Consolidar `NormalizeFieldName` / `TDataApiNaming`
- Remover `TReflection.CreateInstance` (delegar para TActivator)

### 2.3 Impacto Esperado

| Métrica | Antes | Depois |
|---|---|---|
| `TRttiContext.Create` por requisição | 5-15 | 0 |
| `GetType` lookups por CRUD | 10-30 | 0-2 (cache hit) |
| `GetProperties` + `GetAttributes` por entidade | 4-8 por save | 0 (pré-computado) |
| Alocações temporárias por request | ~50 strings (nomes) | ~0 (cacheado) |

---

## 3. Prompt para Agente Arquiteto — Fase 1 e 2

```
Tarefa: Implementar High-Perf Reflection (S07) — Fase 1 e 2

Contexto:
O Dext Framework usa RTTI (System.Rtti) extensivamente para ORM, DI, Web e Serialização.
A análise identificou 60+ instâncias de TRttiContext.Create local sendo criadas e destruídas
em hot-paths (operações CRUD, serialização JSON, resolução de DI).

O documento de referência está em: Docs/Specs/S07-High-Perf-Reflection.md

Objetivo:
Eliminar overhead de RTTI nos hot-paths sem quebrar a API pública.

Fase 1: Unificação de RTTI Context
1. Leia Sources/Core/Dext.Core.Reflection.pas para entender TReflection.Context (class property estática)
2. Em TODOS os arquivos listados na seção 1.1 do spec, substitua Ctx := TRttiContext.Create; try ... finally Ctx.Free; end por Ctx := TReflection.Context (sem Free)
3. Priorize os arquivos em Sources/Data/ primeiro (40+ ocorrências)
4. Corrija TPropertyInfo.GetValue/SetValue em Dext.Entity.TypeSystem.pas (linhas 161-193) para usar TReflection.Context em vez de criar instância local
5. Compile com /compile-delphi e execute os testes Web.FrameworkTests

Fase 2: TPropertyHandler Cache
1. Crie TPropertyHandler em Dext.Core.Reflection.pas com: Name, RttiProperty (cached), TypeInfo, ColumnName, IsPK, IsAutoInc, Converter
2. Adicione TTypeHandler com array de TPropertyHandler pré-populado
3. Adicione class function TReflection.GetHandler(AType: PTypeInfo): TTypeHandler
4. Migre TDbSet<T>.PersistAdd e PersistUpdate para usar handlers cacheados em vez de iterar GetProperties + GetAttributes
5. Migre TPropertyInfo.GetValue/SetValue para cachear TRttiProperty na construção

Regras:
- Use o padrão lazy-init com TCriticalSection (igual ao TReflection.GetMetadata existente)
- NÃO quebre a API pública (TReflection, TActivator, TPropertyInfo)
- NÃO use prefixo L em variáveis locais
- Compile e teste após cada fase
- As mensagens de commit devem ser em inglês, sem paths locais
```

---

## 4. Prompt para Agente Arquiteto — Fase 3 e 4

```
Tarefa: Implementar High-Perf Reflection (S07) — Fase 3 e 4

Contexto:
As Fases 1 e 2 do S07 já foram implementadas (unificação de TRttiContext e
TPropertyHandler cache). Esta tarefa completa o refactoring.

O documento de referência está em: Docs/Specs/S07-High-Perf-Reflection.md

Fase 3: Constructor Cache no TActivator
1. Leia Sources/Core/Base/Dext.Core.Activator.pas
2. Crie um cache IDictionary<TClass, TConstructorInfo> onde TConstructorInfo armazena:
   - O TRttiMethod do construtor selecionado (Greedy ou [ServiceConstructor])
   - Os TRttiParameter pré-resolvidos
   - Um flag indicando se usa DI puro ou híbrido
3. No primeiro CreateInstance para uma classe, resolva e cache. Chamadas subsequentes reutilizam.
4. Adicione invalidação de cache (um ClearCache class method) para uso em testes

Fase 4: Consolidação de Duplicações
1. GetCollectionItemType vs GetListElementType: Unifique em TReflection.GetCollectionItemType.
   Faça TActivator.GetListElementType delegar para TReflection. Atualize todas as chamadas.
2. NormalizeFieldName vs TDataApiNaming: Unifique toda normalização de nomes em TReflection.NormalizeFieldName. Atualize Dext.Web.DataApi.pas para delegar.
3. TReflection.CreateInstance: Verifique se algum chamador externo usa. Se não, remova e delegue para TActivator.CreateInstance diretamente.
4. GetWebSharedRttiContext: Em Dext.Web.ModelBinding.pas, substitua por TReflection.Context.

Validação:
- Compile todos os exemplos: Scripts/build_examples.bat
- Execute testes: Scripts/run_tests.bat
- Verifique memory leaks com FastMM5 habilitado no Web.DatabaseAsApi

Regras:
- NÃO use prefixo L em variáveis locais
- Mensagens de commit em inglês, sem paths locais
- Mensagens de commit em inglês, sem paths locais
- Mantenha todos os comentários e docstrings existentes
```

---

## 5. Próxima Etapa: Fase 5 — Concorrência (Thread-Safety) nos Caches

### 5.1 O Custo do "Lazy-Loading" Desprotegido
Durante a execução do *High-Performance Reflection*, identificamos uma limitação crítica que pode comprometer aplicações e servidores Web sob estresse. As instâncias nativas de `IDictionary<K,V>` criadas com `TCollections.CreateDictionary` **não são thread-safe** para concorrência de escrita.

* **O Problema em `TTypeMetadata`:** O cache primário `TReflection.Context` utiliza um lock (`FLock`), mas o preenchimento dos dicionários `FHandlers` e `FSnakeMap` acontece sob demanda (via "Lazy-Loading") **sem bloqueios**. Múltiplas threads Web que invocam APIs e serializam a mesma entidade, pela primeira vez, esbarram no mesmo dicionário, causando `Access Violations`.
* **O Problema no `TActivator`:** As listas que governam o container de Injeção de Dependências (`FConstructorCache` e `FHybridConstructorCache`) não possuem `TMonitor` nem `TCriticalSection` em volta do `AddOrSetValue`.

### 5.2 Recomendações Implementacionais
Para erradicar qualquer possibilidade de concorrência destrutiva, as seguintes recomendações devem guiar a Fase 5:

1. **Uso de `TMREWSync` ou `TMonitor` (Delphi Native):** Integrar e inicializar travas exclusivas nos pontos exatos de `GetHandler`, bem como no registro dinâmico via Singleton ou Caches de escopo transacional. O lock `TMultiReadExclusiveWriteSynchronizer` é ideal aqui, já que teremos uma altíssima carga de leituras contra apenas algumas raras inicializações bloqueantes por Tipo.
2. **Avaliação Fina de Performance:** Executar rodadas no `Web.FrameworkTests` injetando requisições paralelas simultâneas (`TParallel.For` testando `TReflection.GetHandler`) pós-implementação dos blockings para garantir que a lentidão da trava seja mitigada.
3. **Escopo Centralizado:** Evitar instanciar `TCriticalSection` em cada Tipo se pudermos utilizar Global Locks ou `TMonitor.Enter`/`TMonitor.Exit` diretamente no objeto `TTypeMetadata`.

---

## 6. Fase 5 — Implementação Concluída

**Status:** ✅ Implementado, verificado e otimizado · *April 16, 2026*

### 6.1 Mudanças em `Dext.Core.Reflection.pas` — `TTypeMetadata`

| Ponto | Antes | Depois |
|---|---|---|
| `FHandlers` / `FSnakeMap` lazy-init | Sem proteção — AV sob carga paralela | `TMREWSync` com double-checked locking e lock-free fast path |
| `GetHandler` (steady state) | `BeginRead + TryGetValue + EndRead` | **Zero locks** — `FHandlersReady=1` → acesso direto |
| `GetHandlerBySnakeCase` | Inicialização parcial sem lock | Popula mapa inteiro em único `BeginWrite`, marca `FHandlersReady` e `FSnakeReady` via `TInterlocked` |
| `GetPropertyHandlers` | Crash se `RttiType = nil` | Guard `if RttiType <> nil` |
| `GetDefaultValue` | Stub hardcoded (retornava zero sempre) | Lê `DefaultValueAttribute` via RTTI por nome de classe, extrai `FValue: Variant`, converte via `CastFromString` |
| `CastFromString (TDateTime)` | `StrToDateTimeDef` com locale do sistema (AV em pt-BR) | Parser ISO 8601 direto com `EncodeDate`/`EncodeTime` → fallback locale |

**Padrão definitivo — Lock-Free Fast Path:**
```delphi
// Lock-free fast path (steady state — zero overhead)
if FHandlersReady = 1 then
begin
  FHandlers.TryGetValue(APropName, Result);
  Exit;
end;

// Slow path (somente no warm-up — exclusive lock + double-check)
FLock.BeginWrite;
try
  if FHandlers = nil then
    FHandlers := TCollections.CreateDictionary<string, IPropertyHandler>(True);
  if FHandlers.TryGetValue(APropName, Result) then Exit;
  // ... populate ...
  TInterlocked.Exchange(FHandlersReady, 1); // memory barrier
finally
  FLock.EndWrite;
end;
```
> `TInterlocked.Exchange` garante a barreira de memória necessária para que `FHandlersReady = 1` seja visível a todas as threads **após** o dicionário estar completo.

### 6.2 Mudanças em `Dext.Core.Activator.pas` — `TActivator`

| Cache | Leitura (steady state) | Escrita (warm-up) |
|---|---|---|
| `FConstructorCache` | `FLock.BeginRead` / `EndRead` (não-bloqueante para N leitores) | `FLock.BeginWrite` / `EndWrite` |
| `FHybridConstructorCache` | Idem | Idem |

**Mudança:** `TCriticalSection` → `TMREWSync`
- Reads concorrentes já não se bloqueiam mutuamente
- Writes exclusivos apenas durante a resolução do primeiro construtor por classe

### 6.3 Bônus: `GetDefaultValue` + ISO 8601 no ModelBinder

Dois comportamentos implementados como parte do processo de correção de regressão:

**`TReflection.GetDefaultValue`:** Antes era um stub que sempre retornava zero/vazio. Agora:
1. Itera atributos via `AMember.GetAttributes`
2. Detecta `DefaultValueAttribute` por nome de classe (sem dependência direta de `Dext.Entity.Attributes`)
3. Lê o campo `FValue: Variant` via RTTI e converte com `CastFromString`

**`CastFromString` (TDateTime):** Adicionado parser ISO 8601 locale-independente:
```delphi
// Detecta yyyy-mm-dd pelas posições do '-'
if (Length(S) >= 10) and (S[5] = '-') and (S[8] = '-') then
begin
  Y := StrToInt(Copy(S, 1, 4));
  M := StrToInt(Copy(S, 6, 2));
  D := StrToInt(Copy(S, 9, 2));
  DTVal := EncodeDate(Y, M, D);
  // + EncodeTime se componente HH:mm:ss presente
end;
```
Isso resolve o comportamento incorreto em sistemas com locale pt-BR (`dd/mm/yyyy`).

### 6.4 Resultado dos Testes

```
── TestParallelReflection (stress) ──────────────────────────────
Starting Stress Tests (Wave 8 Hardened)...
Testing Reflection (Parallel)...   ← TParallel.For x1000: GetHandler + GetHandlerBySnakeCase
Testing Activator (Parallel)...    ← TParallel.For x1000: CreateInstance<TTestEntity>
Stress Tests Passed 100%!

── Dext.Web.UnitTests ───────────────────────────────────────────
Total: 18  ✅ Passed: 18  ❌ Failed: 0   Pass Rate: 100%
Incluindo: Test_BindRecord_Hybrid_With_DefaultValue
           Test_BindQuery_Class_With_DefaultValue
           Test_BindParameter_With_DefaultValue
```

Zero `EAggregateException` ou `Access Violation` em ambos os conjuntos de testes.

