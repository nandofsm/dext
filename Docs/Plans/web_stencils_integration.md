# Plano Técnico: Dext View Engine & Integração Web Stencils

## Visão Geral

Implementar uma infraestrutura de **View Engine** agnóstica no Dext, permitindo Server Side Rendering (SSR) de alta performance. O objetivo é fornecer suporte imediato ao **Web Stencils** (Delphi 12.2+), mas mantendo o core do framework neutro para futuros motores de templates (incluindo um possível motor nativo).

---

## 1. Camada de Abstração (Dext.Web.View)

Para evitar o acoplamento direto, o Dext utilizará interfaces e nomes genéricos:

- **`IViewEngine`**: Interface que define o método `Render(const ViewName: string; ViewData: TViewData): string`.
- **`TViewResult`**: Implementação de `IResult` que solicita a renderização a uma `IViewEngine` registrada.
- **`TViewData`**: Dicionário inteligente (ViewBag) que encapsula os dados passados para a View.

### Configuração no AppBuilder

```pascal
App.UseViewEngine<TWebStencilsEngine>(
  procedure(Options: TViewOptions)
  begin
    Options.TemplateRoot := 'wwwroot/views';
    Options.AutoReload := True;
  end
);
```

---

## 2. O Motor de Streaming (Flyweight Iterator)

O grande diferencial do Dext será como ele entrega os dados às Engines, independentemente de qual motor seja usado:

- **`TStreamingViewIterator<T>`**: Um enumerador "falso" de alta performance.
- **Conceito Flyweight:** Mantém apenas uma instância da entidade. O `MoveNext` carrega os dados do banco no mesmo objeto.
- **Versatilidade:** Desenvolvido para que qualquer engine que suporte `GetEnumerator` (como o Web Stencils) possa renderizar milhões de linhas com uso de memória fixo O(1).

---

## 3. Implementação: Provedor Web Stencils

A unidade `Dext.Web.View.WebStencils.pas` será a ponte específica (Bridge):

- Traduzirá o `TViewData` para o dicionário léxico do Stencils.
- Implementará o hook `OnValue` para resolver **Smart Types** (`Prop<T>`, `Nullable<T>`).
- Gerenciará o **Auto-Whitelist** de RTTI para as entidades do Dext.

---

## 4. Integração com Dext DSL (Fluent API)

O desenvolvedor usará uma sintaxe limpa e previsível:

```pascal
[Route('/dashboard')]
function TDashboard.Index: IResult;
begin
  // O Framework escolhe a Engine registrada automaticamente
  Result := Results.View('admin/index.html', Db.Users.Query)
    .WithValue('PageTitle', 'Painel Administrativo')
    .WithValue('ServerInfo', GetSystemStatus);
end;
```

---

## 5. Web Moderna & HTMX

### Renderização de Partials (Fragmentos)

Suporte para renderizar apenas pedaços de templates:

- `Results.ViewPart('partials/user_table.html', Query)`: Renderiza sem layouts mestre.
- Detecção automática de requisições HTMX para alternar entre View Completa e Partial.

---

## 6. Etapas Finais & Entrega

### Benchmarks e Validação

- [ ] Executar benchmark de consumo de RAM: **Flyweight Streaming** vs **Materialized List (ToList)** para renderização de 100k+ registros.
- [ ] Validar segurança XSS em **Smart Properties** e propriedades dinâmicas.

### SEO & Metadata

- [ ] Implementar helpers em `TViewData` para injeção automática de tags SEO (`Title`, `MetaDescription`, `OG Tags`) no layout mestre.

### Exemplos e Demos

- [ ] **Dashboard Admin (HTMX)**: Exemplo mostrando lazy loading de cards e paginação sem refresh usando fragmentos de visualização.
- [ ] **Relatórios de Grande Porte**: Exemplo de exportação HTML de tabelas massivas via streaming puro.

### Documentação & Suporte

- [x] **Dext Book**: Adicionar o capítulo "SSR & View Engines", detalhando a arquitetura agnóstica.
- [x] **Skill IA**: Criar `dext-view-engine.md` na pasta de skills para guiar assistentes de IA no desenvolvimento de interfaces com Dext.
- [x] Atualizar `README.md` e `Roadmap.md` marcando a feature como completa.

---

## 7. Roteiro de Implementação (Checklist)

- [x] **Core Abstraction**: Criar `Dext.Web.View.pas` (Contratos e `TViewResult`).
- [x] **Streaming Engine**: Implementar `TStreamingViewIterator<T>` (O "Pulo do Gato" Flyweight).
- [x] **Web Stencils Provider**: Implementar o bridge oficial para Delphi 12.2+.
- [x] **Fluent API**: Estender `Results.View` e resolver injeção de dependência via `App.UseViewEngine`.
- [x] **HTMX Middleware**: Autodetectar headers HTMX para renderização de parciais.

---
*Plano consolidado em: 06/03/2026 - Versão Final para Implementação.*

### Ciclo de Vida e Segurança

- **Connection Lifetime**: Implementação de um `TStencilContextManager` para garantir que o `DbContext` e sua conexão permaneçam ativos até o último byte do HTML ser enviado.
- **Data Scoping**: Proteção automática contra vazamento de dados entre requests.

## 4. Diferenciais Técnicos

### Backpressure e Buffering

Controle de fluxo para evitar que a geração de HTML rápido demais sobrecarregue o buffer de rede em conexões lentas, aproveitando o design não-bloqueante do **DCS (Cross-Socket)**.

### Custom Value Adapters

Suporte transparente para os tipos especiais do Dext no motor de templates:

- `Prop<T>`: Extração automática do valor interno.
- `Nullable<T>`: Tratamento de valores vazios/nulos no HTML sem quebras.

## 5. Compatibilidade

O recurso requer **Delphi 12.2 (Athens)** ou superior.

```pascal
{$IF CompilerVersion >= 36.0} // RAD Studio 12.2+
  {$DEFINE DEXT_HAS_STENCILS}
{$IFEND}
```

*Em versões anteriores, as chamadas a `Results.Stencil` lançarão um erro informativo de incompatibilidade.*

## 6. Dificuldades e Desafios

1. **Mapeamento RTTI**: Manter a performance do motor original do Web Stencils ao injetar objetos dinâmicos.
2. **Streaming em Pipelines**: Garantir que middlewares de compressão (Gzip) funcionem corretamente com o streaming de HTML.

## 7. Próximos Passos

1. [x] **Fase 1**: Criar `Dext.Web.Stencils.pas` com a infraestrutura básica e `Results.Stencil`.
2. [x] **Fase 2**: Implementar o `TStreamingStencilIterator<T>` (Flyweight).
3. [x] **Fase 3**: Adicionar suporte a `ViewBag` e Fluent Methods (`WithData`).
4. [x] **Fase 4**: Criar helpers para injeção de scripts e integração com **HTMX**.
5. [x] **Fase 5**: Documentação e Exemplo de "Admin Dashboard" com 100k registros.

---
**Data de Atualização**: 2026-03-07
**Versão Alvo Delphi**: 12.2+
**Status**: Concluído
