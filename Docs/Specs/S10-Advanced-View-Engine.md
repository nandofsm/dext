# S10 — Advanced View Engine (High-Level Roadmap)

## 1. Visão Geral

Esta especificação define o caminho evolutivo necessário para transformar o motor de templates básico (`S09`) em um **Full View Engine** industrial para o Dext Framework, capaz de competir com ecossistemas como .NET Razor e WebStencils.

---

## 2. Lacunas Técnicas (Gap Analysis)

Para atingir o "Nível Razor", os seguintes recursos devem ser implementados sobre a base da AST atual:

### 2.1. Composição: Layouts & Sections
Atualmente, o motor processa apenas arquivos isolados. O suporte a layouts permitirá a definição de um "template mestre".

- **Tag `@Layout`**: Define qual arquivo serve como invólucro para a renderização atual.
- **Tag `@RenderBody()`**: Onde o conteúdo da view filha será injetado.
- **Tag `@Section` / `@RenderSection()`**: Permite que a view filha injete blocos específicos (ex: Scripts, CSS) em locais pré-definidos do Layout.

### 2.2. Partials (Reuso de Fragmentos)
- **Tag `@Partial(Name, Model)`**: Renderiza um sub-template dentro do atual, passando um sub-contexto de dados.

### 2.3. Avaliador de Expressões Complexas
O parser atual é focado em caminhos de propriedades. Uma evolução para "High Level" exige suporte a:
- Operadores Lógicos (`&&`, `||`, `!`).
- Operadores Comparativos (`>`, `<`, `==`).
- Expressões Ternárias ou Inline.

---

## 3. Integração com Web Pipeline

O objetivo final da S10 é que o Dext Framework possa ser usado para criar sites SSR (Server-Side Rendering) de alta performance sem dependências externas.

- **`TDextNativeViewEngine`**: Implementação completa da interface `IViewEngine`.
- **Pre-compilação**: Cachear a AST em memória (ou serializada) para evitar re-parsing em cada Request.

---

## 4. Cronograma Estimado

Esta especificação é considerada **Wave 3 (Enterprise & Modernization)**. O foco imediato do framework permanece na produtividade de backend e geração de código (S01).
