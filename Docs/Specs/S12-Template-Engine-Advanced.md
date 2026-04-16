# S12 — Advanced Template Engine: Finalization & Feature Parity

> **Status:** 📝 Draft — April 16, 2026  
> Spec criada a partir de solicitação de usuário + análise competitiva contra TemplatePro e WebStencils.

---

## 1. Contexto & Motivação

O Dext possui um motor de templates AST-based (`Dext.Templating`) funcional mas incompleto. Ele resolve o caso de uso de **scaffolding** (geração de código via CLI), mas para SSR de HTML e geração de emails ainda faltam funcionalidades críticas que os concorrentes já possuem.

### 1.1 Concorrentes Analisados

| Produto | Sintaxe | Herança | Macros | Filtros | TDataSet | Expressões |
|---|---|---|---|---|---|---|
| **TemplatePro** (Daniele Teti) | `{{:var}}` | ✅ Multi-level | ✅ | 30+ | ✅ | ✅ Aritméticas |
| **WebStencils** (Embarcadero) | `{% %}` / `{{ }}` | ✅ | ❌ | Básicos | ✅ | Limitadas |
| **Dext.Templating** (atual) | `@var` | ❌ | ❌ | 5 (scaffolding) | ❌ | ❌ |
| **ASP.NET Razor** (référence) | `@expr` | ✅ `@section` | `@RenderPartial` | N/A | N/A | ✅ C# |

### 1.2 O Que o Usuário Pediu
- Herança de templates (layouts + blocos)
- Partials (includes reutilizáveis)
- Superar TemplatePro em features
- Feature parity com .NET Razor

### 1.3 Estado Atual do Motor
O `Dext.Templating.pas` tem:
- ✅ Parser AST com `@if`, `@foreach`, `@@` escape
- ✅ Child scope / `ITemplateContext` com parent lookup
- ✅ Filtros registráveis (`ToPascalCase`, `ToCamelCase`, `ToSnakeCase`, `Pluralize`, `Singularize`)
- ✅ Resolução RTTI de propriedades de objetos (dot-notation)
- ⚠️ `TConditionalNode.Render` — **stub vazio** (não renderiza)
- ⚠️ `TLoopNode.Render` — **stub vazio** (não itera)
- ❌ Sem herança, layouts, partials
- ❌ Sem filtros HTML (`htmlencode`, `truncate`, `datetostr`, etc.)
- ❌ Sem expressões aritméticas
- ❌ Sem `@set`, `@continue`, `@break`, `@include`
- ❌ Sem `@else` em loops (empty fallback)
- ❌ Sem pseudo-variáveis de loop (`@@index`, `@@first`, `@@last`, etc.)
- ❌ Sem whitespace control
- ❌ Sem comentários no template
- ❌ TDataSet não suportado como fonte de dados de loop

---

## 2. Objetivo

Tornar o `Dext.Templating` o **melhor motor de templates para Delphi**, superando TemplatePro e WebStencils em:
1. **Completude de features** — paridade com Razor/.NET
2. **Performance** — AST compilado, cache de parsed templates
3. **Integração nativa** — RTTI, Dext ORM Streaming, Smart Properties
4. **Developer Experience** — mensagens de erro com linha/coluna, sintaxe Razor familiar

---

## 3. Especificação Técnica por Fase

### Fase 1 — Completar o Core Existente (Blocker)

> **Prioridade: CRÍTICA** — sem isso o motor não funciona para HTML rendering.

#### 1.1 Implementar `TConditionalNode.Render`
O stub atual sempre retorna `''`. Deve:
- Chamar `EvaluateCondition(FCondition, AContext)` 
- Renderizar `FTrueNodes` se `True`, `FFalseNodes` se `False`
- Suportar `@else` como separador das duas listas

```delphi
function TConditionalNode.Render(const AContext: ITemplateContext): string;
var
  SB: TStringBuilder;
  Node: TTemplateNode;
begin
  SB := TStringBuilder.Create;
  try
    if FEngine.EvaluateCondition(FCondition, AContext) then
    begin
      for Node in FTrueNodes do
        SB.Append(Node.Render(AContext));
    end
    else
    begin
      for Node in FFalseNodes do
        SB.Append(Node.Render(AContext));
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;
```

#### 1.2 Implementar `TLoopNode.Render`
O stub atual sempre retorna `''`. Deve:
- Resolver o `FListExpr` a partir do contexto (objetos, listas, TArray)
- Criar um `child scope` por iteração com `FItemName` → item atual
- Injetar pseudo-variáveis: `@@index` (1-based), `@@first`, `@@last`, `@@odd`, `@@even`
- Suportar `FElseNodes` para coleção vazia

```
@foreach (var item in Model.Products)
  @item.Name(@item.@@index)
@else
  Nenhum produto encontrado.
@endforeach
```

#### 1.3 Implementar `TExpressionNode.Render` via contexto
O stub atual só retorna `FExpression` — o valor literal da expressão, sem resolvê-la.
O Engine deve ser injetado no nó para que possa chamar `ResolveExpression`.

**Solução:** Tornar os nós AST cientes do engine via referência fraca ou mover a rendering logic para o engine.

---

### Fase 2 — Filtros de Produção

Expandir o registry de filtros para cobrir casos de uso web e email.

#### 2.1 Filtros de String (parity TemplatePro)
| Filtro | Comportamento | Exemplo |
|---|---|---|
| `uppercase` | Tudo maiúsculo | `@Name.uppercase()` |
| `lowercase` | Tudo minúsculo | `@Name.lowercase()` |
| `capitalize` | Primeira letra maiúscula | `@Name.capitalize()` |
| `trim` | Remove espaços das bordas | `@Name.trim()` |
| `truncate(n)` | Limita a N caracteres + `...` | `@Bio.truncate(100)` |
| `truncate(n, suffix)` | Idem com sufixo customizado | `@Bio.truncate(50, '…')` |
| `lpad(n, char)` | Padding esquerdo | `@Id.lpad(5, '0')` |
| `rpad(n, char)` | Padding direito | `@Code.rpad(10)` |
| `replace(from, to)` | Substituição | `@Text.replace(' ', '_')` |
| `default(val)` | Valor fallback se vazio | `@Name.default('N/A')` |
| `htmlencode` | Escape HTML (& < > " ') | `@UserInput.htmlencode()` |
| `urlencode` | URL encoding | `@Query.urlencode()` |
| `json` | Serializa para JSON | `@Object.json()` |
| `raw` | Output sem encoding | `@HtmlContent.raw()` |

#### 2.2 Filtros de Data/Número
| Filtro | Comportamento | Exemplo |
|---|---|---|
| `datetostr(fmt)` | Formata TDateTime | `@CreatedAt.datetostr('dd/mm/yyyy')` |
| `datetimetostr(fmt)` | Idem com hora | `@UpdatedAt.datetimetostr()` |
| `formatfloat(fmt)` | Formata Double | `@Price.formatfloat('0.00')` |
| `formatint` | Formata Integer | `@Count.formatint` |
| `round(n)` | Arredonda | `@Value.round(2)` |

#### 2.3 Filtros de Comparação (para uso em `@if`)
| Filtro | Comportamento |
|---|---|
| `eq(val)` | Igualdade |
| `ne(val)` | Desigualdade |
| `gt(val)` | Maior que |
| `ge(val)` | Maior ou igual |
| `lt(val)` | Menor que |
| `le(val)` | Menor ou igual |
| `contains(s)` | Contém substring |
| `startswith(s)` | Começa com |
| `endswith(s)` | Termina com |

```
@if (Status.eq('active'))
  <span class="badge green">Ativo</span>
@else
  <span class="badge red">Inativo</span>
@endif
```

#### 2.4 Filtros Encadeados
A sintaxe de filtros deve permitir encadeamento com `.`:
```
@Product.Name.trim().truncate(50).htmlencode()
```
Internamente representado como: `resolve(expr) → filter1 → filter2 → filter3`.

#### 2.5 Filtros com Parâmetros
Suporte a parâmetros nas chamadas de filtro:
```
@Price.formatfloat('R$ #,##0.00')
@Date.datetostr('yyyy-mm-dd')
@Text.truncate(100, '…')
```

---

### Fase 3 — Herança de Templates e Partials

Este é o requisito central do usuário e o principal diferencial vs WebStencils.

#### 3.1 `@layout` — Definir Layout Base

Um template filho declara o layout que deve envolvê-lo:

**`views/products/index.html`:**
```html
@layout('_Layout')

@section('title')
  Produtos
@endsection

@section('content')
<h1>Lista de Produtos</h1>
@foreach (var item in Products)
  <div>@item.Name — @item.Price.formatfloat('0.00')</div>
@endforeach
@endsection
```

**`views/shared/_Layout.html`:**
```html
<!DOCTYPE html>
<html>
<head>
  <title>@renderSection('title') — Meu App</title>
</head>
<body>
  @renderSection('content')
</body>
</html>
```

#### 3.2 `@section` / `@renderSection` — Blocos Nomeados
- `@section('name') ... @endsection` — Define um bloco no filho
- `@renderSection('name')` — Renderiza o bloco no layout
- `@renderSection('name', required: false)` — Bloco opcional
- `@renderBody` — Renderiza todo o conteúdo do filho (layout) — equivalente ao Razor

#### 3.3 `@extends` — Herança Multi-Nível (TemplatePro parity)
Suporte a herança profunda (layout filho que herda de layout pai):

```html
@extends('_AdminLayout')

@block('sidebar')
  <!-- admin sidebar específico -->
@endblock
```

Com `@inherited` para incluir o conteúdo do bloco pai:
```html
@block('scripts')
  @inherited
  <script src="admin.js"></script>
@endblock
```

#### 3.4 `@partial` / `@include` — Partials Reutilizáveis

Inclui outro template como fragmento, com passagem de contexto local:

```html
@partial('components/_ProductCard', product: item)
```

**`views/components/_ProductCard.html`:**
```html
<div class="card">
  <h3>@product.Name</h3>
  <p>@product.Price.formatfloat('R$ 0.00')</p>
</div>
```

Suporte a inline partials (definição e uso no mesmo arquivo):

```html
@define('badge', status)
  <span class="badge @status">@status</span>
@enddefine

@> badge('active')
@> badge('inactive')
```

#### 3.5 Resolução de Nomes de Arquivo
O `ITemplateLoader` resolve templates por nome usando:
1. Caminhos relativos ao template atual
2. Caminhos relativos ao `TemplateRoot` configurado
3. Prefixos de busca (`shared/`, `components/`, `layouts/`)

---

### Fase 4 — Controle de Fluxo Avançado

#### 4.1 `@set` — Variáveis Locais
```
@set total = 0
@foreach (var item in Items)
  @set total = @total + @item.Price
@endforeach
Total: @total.formatfloat('0.00')
```

#### 4.2 `@continue` e `@break` em Loops
```
@foreach (var item in Items)
  @if (item.Hidden)
    @continue
  @endif
  <p>@item.Name</p>
@endforeach
```

#### 4.3 `@switch` / `@case`
```
@switch (Status)
  @case ('active')
    <span class="green">Ativo</span>
  @case ('suspended')
    <span class="red">Suspenso</span>
  @default
    <span>Desconhecido</span>
@endswitch
```

#### 4.4 Expressões Aritméticas `@(expr)`
Suporte a expressões matemáticas e de string inline:
```
@(Price * Quantity)
@(FirstName + ' ' + LastName)
@(Items.Count > 0)
```
Funções built-in: `length()`, `upper()`, `lower()`, `trim()`, `sqrt()`, `abs()`, `round()`, `min()`, `max()`, `left()`, `right()`.

#### 4.5 `@comment` — Comentários
Comentários que não aparecem no output:
```
@* Este trecho é um comentário e não será renderizado *@
```

---

### Fase 5 — Features de Produção

#### 5.1 Whitespace Control
Operadores `~` para remover whitespace antes/após tags:
```
@~if (IsFirst)
  , 
@endif~
```
Equivalente ao TemplatePro `{{-` / `-}}`.

#### 5.2 String Literals em Templates
Suporte a literais de string dentro de expressões:
```
@('Olá, ' + UserName + '!')
```

#### 5.3 `@raw` — Bloco de Saída Literal
```
@raw
  Este conteúdo tem @símbolos@ que não devem ser processados.
@endraw
```

#### 5.4 Templates Compilados / Cache
Compilar o AST uma vez e cachear por template name + hash do conteúdo:
```pascal
var Template := Engine.Compile(Content);  // retorna ICompiledTemplate
var Output := Template.Render(Context);   // reutilizável
```

Arquitetura:
- `ICompiledTemplate` — AST serializado/cached
- `ITemplateCompiler` — separa parse de render
- Cache LRU por `TemplateRoot` configurado

#### 5.5 Mensagens de Erro com Contexto
Em vez de exception genérica, erros devem incluir:
- Nome do arquivo
- Número de linha e coluna
- Trecho do template com o problema destacado

```
[Dext.Template] Parse error in 'views/products/index.html' at line 12, col 5:
  @if (Status.eq('active')
               ^
  Unterminated function call: missing closing parenthesis
```

#### 5.6 Modo HTML vs Modo Raw
- **HTML Mode** (default para views): auto-escapa output de `@expr` com `htmlencode`
- **Raw Mode** (default para scaffolding): output literal sem encoding
- Controle explícito: `@raw(expr)` em modo HTML, `@encoded(expr)` em modo raw

---

### Fase 6 — Integrações Nativas Dext

#### 6.1 TDataSet como Fonte de Loop (parity TemplatePro)
```
@foreach (var row in Customers)
  <tr>
    <td>@row.Id</td>
    <td>@row.Name</td>
    <td>@row.Email</td>
  </tr>
@endforeach
```
O `TLoopNode.Render` detecta se a fonte é um `TDataSet` e itera com `First`/`Next`/`Eof` em vez de índice de array.

#### 6.2 Streaming ORM (Flyweight Iterator)
Continuar o suporte existente de `TStreamingViewIterator<T>`:
- Integração com `IDbQuery<T>` sem materialização em TArray
- O loop itera "on demand" consumindo O(1) memória

#### 6.3 Smart Properties `Prop<T>`
Manter o wrapper `@(Prop(item.Name))` e adicionar suporte automático no RTTI: se a propriedade for `Prop<T>`, extrair o `.Value` automaticamente sem wrapper explícito.

#### 6.4 HTMX Auto-Detection
Detectar header `HX-Request` e suprimir o layout automaticamente:
```pascal
// No Results.View:
if Request.Headers.ContainsKey('HX-Request') then
  ViewOptions.Layout := '';  // retorna partial apenas
```

---

## 4. Comparativo Final: Dext vs Concorrentes (Pós-S12)

| Feature | TemplatePro | WebStencils | **Dext (S12)** |
|---|---|---|---|
| Sintaxe | `{{:var}}` (Jinja) | `{% %}` | `@var` (Razor) |
| Herança multi-nível | ✅ | ✅ | ✅ |
| Partials com contexto local | ❌ | ❌ | ✅ |
| Macros | ✅ | ❌ | ✅ (`@define`) |
| Filtros encadeados com params | ✅ 30+ | Básicos | ✅ 35+ |
| Expressões aritméticas | ✅ | ❌ | ✅ |
| `@set` / variáveis locais | ✅ | ❌ | ✅ |
| `@switch` / `@case` | ❌ | ❌ | ✅ |
| `@continue` / `@break` | ✅ | ❌ | ✅ |
| Whitespace control | ✅ | ❌ | ✅ |
| Comentários | ✅ | ❌ | ✅ |
| Templates compilados + cache | ✅ | ✅ (parcial) | ✅ |
| TDataSet support | ✅ | ✅ | ✅ |
| ORM Streaming O(1) | ❌ | ❌ | ✅ (exclusivo) |
| Pseudo-vars de loop | ✅ | Limitado | ✅ |
| Erros com linha/coluna | ❌ | ❌ | ✅ |
| HTMX auto-detection | ❌ | ❌ | ✅ (exclusivo) |
| Zero dependência externa | ❌ (JsonDataObjects) | ❌ (RAD Studio) | ✅ |
| Integração DI nativa | ❌ | ❌ | ✅ |

---

## 5. Plano de Implementação (Fases Sugeridas)

| Fase | Esforço | Prioridade | Bloqueio |
|---|---|---|---|
| **F1: Core (Render stubs)** | 1 dia | 🔴 Crítico | Nada funciona sem isso |
| **F2: Filtros de Produção** | 2 dias | 🔴 Alta | Necessário para HTML |
| **F3: Herança & Partials** | 3-4 dias | 🔴 Alta | User request direto |
| **F4: Fluxo Avançado** | 2 dias | 🟡 Média | Superar TemplatePro |
| **F5: Features Produção** | 3 dias | 🟡 Média | Cache + error reporting |
| **F6: Integrações Dext** | 1-2 dias | 🟢 Baixa | Já existe parcialmente |

**Total estimado:** ~2 semanas de implementação focada.

---

## 6. Decisões Arquiteturais

### 6.1 Manter Sintaxe `@` (Razor)
O Dext já usa `@` no scaffolding e na documentação. Mudar para `{{}}` quebraria código existente e confundiria usuários. A decisão é **manter `@` como delimitador primário**, adicionando `@(expr)` para expressões complexas.

### 6.2 Separar Compiler de Engine
Introduzir a interface `ITemplateCompiler`:
```pascal
ITemplateCompiler = interface
  function Compile(const ATemplate: string): ICompiledTemplate;
  function CompileFile(const ATemplateName: string): ICompiledTemplate;
end;

ICompiledTemplate = interface
  function Render(const AContext: ITemplateContext): string;
end;
```
O `TDextTemplateEngine` atual se torna o compiler. Um `TCompiledTemplate` cacheia o AST.

### 6.3 Loader Strategy Pattern
```pascal
ITemplateLoader = interface
  function Load(const AName: string): string;
  function Exists(const AName: string): Boolean;
end;
```
Implementações: `TFileSystemLoader`, `TInMemoryLoader`, `TCompositeLoader`.

### 6.4 Resolver via RTTI com Cache
As lookups de propriedades RTTI custam caro. Usar o `TTypeMetadata` do S07 para cachear handlers:
```pascal
// Usar TReflection.GetHandler em vez de TypeRtti.GetProperty a cada render
Handler := TReflection.GetMetadata(Obj.ClassInfo).GetHandler(PropName);
Result := Handler.GetStringValue(Obj);
```

---

## 7. Exemplos de Templates Completos

### 7.1 Página HTML com Layout e Partials
**`_Layout.html`:**
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>@renderSection('title') | Dext App</title>
  @renderSection('styles', required: false)
</head>
<body>
  <nav>@partial('shared/_Navbar')</nav>
  <main>
    @renderBody
  </main>
  <footer>@partial('shared/_Footer')</footer>
  @renderSection('scripts', required: false)
</body>
</html>
```

**`pages/customers.html`:**
```html
@layout('shared/_Layout')

@section('title')Clientes@endsection

@section('content')
<div class="container">
  <h1>Clientes (@Customers.Count.formatint)</h1>
  
  @if (Customers.Count.eq(0))
    <p class="empty">Nenhum cliente cadastrado.</p>
  @else
    <table class="table">
      @foreach (var customer in Customers)
        <tr class="@if (customer.@@odd)odd@else even@endif">
          <td>@customer.@@index</td>
          <td>@customer.Name.htmlencode()</td>
          <td>@customer.Email.default('—')</td>
          <td>@customer.CreatedAt.datetostr('dd/mm/yyyy')</td>
        </tr>
      @endforeach
    </table>
  @endif
</div>
@endsection
```

### 7.2 Template Email
```html
@* Template de email de boas-vindas *@
<!DOCTYPE html>
<html>
<body>
  <h1>Olá, @UserName.capitalize()!</h1>
  <p>Bem-vindo ao @AppName.</p>
  
  @if (HasTrialPeriod)
    <p>Seu período de trial termina em <strong>@TrialExpiry.datetostr('dd/mm/yyyy')</strong>.</p>
  @endif
  
  <ul>
  @foreach (var feature in Features)
    <li>@feature.Name — @feature.Description.truncate(80, '…')</li>
  @endforeach
  </ul>
</body>
</html>
```

---

*Last update: April 16, 2026*
