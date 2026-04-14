# S09 — Motor de Templates (Dext.Templating): Arquitetura e Sintaxe

## 1. Visão Geral

O Dext Framework exige um motor de geração (scaffolding) de altíssima performance e com excelente Developer Experience (DX). 

Conforme definido na arquitetura evolutiva do framework, o mecanismo de *scaffolding* ocorre em dois níveis separados inspirados no ecossistema .NET:

1. **Project Templates (`dotnet new` style):**
   Projetos-base que são mantidos como código Delphi 100% válido (arquivos `.dpr`, `.pas`, `.dproj` que compilam isoladamente na sua pasta). São controlados por um manifesto (`dext-template.json`) que orienta substituições globais de texto (como Nomes de Projeto, Namespaces e GUIDs do sistema). É muito mais fácil para nós mantermos projetos base sem templates inline intrusivos.
   
2. **Code Scaffolding (T4 / Razor Engine style):**
   Utilizado para geração de arquivos baseados em modelos reais (ex: ler o banco de dados via `ISchemaProvider` e cuspir uma Unit de Entidade preenchida). Para essa fase, o motor precisa de abstração imperativa: laços (`for`), condições (`if`) e formatações parciais. 

---

## 2. A Sintaxe Razor-Inspired (DX-Friendly)

Concordando 100% com a visão arquitetural moderna: **rejeitamos a limitação "logic-less" do Mustache (`{{ }}`)**. Embora o Mustache sirva bem para views muito simples, o Scaffolding avançado demanda acesso a sub-nós organizados. Além disso, a sintaxe T4 (`<#= Model #>`) polui excessivamente a leitura do programador.

O Dext adota uma sintaxe similar ao **Razor** (no .NET) e ao **WebStencils**, baseada no indicador `@`, que flui naturalmente sem concorrer com a gramática rígida do Delphi (como chaves e colchetes).

### 2.1. Expressões e Variáveis

A avaliação de expressões utiliza o prefixo `@`.

```delphi
// Template Válido em Sintaxe Dext-Razor
unit @Model.Namespace.Entities;

interface

type
  [Table('@Model.TableName')]
  T@Model.EntityName = class(TEntity)
  private
    FId: Integer;
  public
    // ...
  end;
```

### 2.2. Lógica de Decisão (If/Else)

Diferente do C# no Razor, que acopla blocos estruturais em chaves `{ }`, no Delphi as chaves são meros comentários. Logo, para suportar indentação adequada sem depender do parser imperfeito do texto, adotamos delimitação clara via `@endif` ou blocos inline:

```razor
@if (Col.IsPrimaryKey)
  [PK, AutoInc]
@endif
property @Col.Name: @Col.DataType;
```

### 2.3. Lógica de Iteração (Foreach)

O motor entende a capacidade de caminhar em Generics e listas que foram registradas para a RTTI otimizada.

```razor
@foreach (Col in Model.Columns)
    F@Col.Name: @Col.DataType;
@endforeach
```

### 2.4. Funções Padrões e Mutators

String manipulations nativos acoplados por sintaxe pipe/dot na avaliação sem gerar ruído:

```razor
T@Model.TableName.ToPascalCase() = class(TDataApi)
```
Extensões Built-in fundamentais para o Scaffolding:
- `.ToPascalCase()`, `.ToCamelCase()`, `.ToSnakeCase()`
- `.Pluralize()`, `.Singularize()`

---

## 3. Arquitetura Interna (`Dext.Templating.pas`)

### 3.1. Parsing e Árvore de Sintaxe Abstrata (AST)

A implementação do motor utiliza um parser descendente recursivo para preencher uma AST:
1. `TTextNode`: Texto fonte cru.
2. `TExpressionNode`: A injeção reativa (`@EntityName.ToPascalCase()`).
3. `TConditionalNode`: Bloco em memória avaliado se a condição `@if` for Truthy.
4. `TLoopNode`: Bloco em memória repetido com base num iterável interno.

### 3.2. Sinergia de Alta Performance (Alinhado à S07)

O motor utiliza o sistema de Reflection do Delphi (RTTI), com planos futuros de migração para o `TTypeHandlerRegistry` (S07) para eliminar o overhead de TValue.

### 3.3. Segurança Contextual (HTML Escaping)

O motor suporta dois contextos de renderização:
1. **Raw Mode**: Texto puro (padrão para Scaffolding).
2. **HTML Mode**: Auto-escaping de entidades HTML (padrão para Web Views).

---

## 4. Maturidade e Posicionamento (Maturity Matrix)

Para transparência e guia futuro, o motor atual (`Dext.Templating`) situa-se no seguinte espectro tecnológico:

| Recurso | Mustache / Logic-less | **Dext (S09)** | **WebStencils** | **.NET Razor** |
| :--- | :---: | :---: | :---: | :---: |
| **Parsing** | Regex / Text Replace | **AST Parser** | AST Parser | Fully Compiled |
| **Lógica** | "Logic-less" (Apenas Tags) | **If / ForEach** | If / For / Each | Full C# Logic |
| **Segurança** | Escape Manual | **Auto-HTML Escape** | Native Escape | Contextual Escape |
| **Composição** | Apenas Partials | **Manual (Workaround)** | Layouts / Sections | Layouts / Sections |
| **Tipagem** | Dinâmica / Nenhuma | **Dinâmica (RTTI)** | Dinâmica | Strongly Typed |

### 4.1. Classificação: "Scaffolding++"
O motor atual é classificado como **"Scaffolding++"**. Ele supera os motores de geração de código tradicionais pela inteligência do parser AST e segurança nativa, mas para atingir o nível industrial de um **Full View Engine** (como o Razor), as funcionalidades de composição avançada foram movidas para a especificação [S10](S10-Advanced-View-Engine.md).

---

## 5. Próxima Ação de Execução

1.  **Limpeza**: Remover resquícios de motores antigos.
2.  **S01 Integration**: Iniciar implementação dos templates de Scaffolding (Entidade, DTO, Repository).
