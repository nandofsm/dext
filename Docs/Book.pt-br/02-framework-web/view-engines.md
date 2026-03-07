# SSR & View Engines

O Dext Framework possui suporte de primeira classe a **Server-Side Rendering (SSR)**. Isso significa que, além de ser excelente para criar APIs JSON robustas (sejam fluentes ou via Controllers MVC tradicionais), o Dext também facilita a criação de aplicações web completas renderizando HTML no lado do servidor.

O design implementado foca em ser **agnóstico de engine**, oferecendo contornos ideais de velocidade de memória com a capacidade de estender para qualquer motor, e possuindo integração ativa para a nova tecnologia nativa da Embarcadero: **Web Stencils**.

## A Arquitetura Agnóstica

A arquitetura do Dext abstrai detalhes específicos sobre como o HTML será validado. Todo o controle de estado passa por:

* **`IViewEngine`**: Interface que qualquer motor de templates de terceiros precisa implementar para servir páginas.
* **`TViewData`**: Um dicionário "ViewBag" onde residem todas as variáveis globais a serem inseridas no HTML.
* **`Results.View`**: Método do injetor fluente do servidor que retorna um `IResult` compatível e encaminha a requisição web sem acoplamentos.

Você configura a sua engine direto no `Program.pas` / `Startup.pas` ao adicionar os serviços.

## Integração com Web Stencils (Delphi 12.2+)

A partir do Delphi 12.2, a Embarcadero introduziu o **Web Stencils**. O Dext já inclui um Provider construído exclusivamente para ele com recursos insanos de conectividade de dados.

### 1. Adicionando o Suporte

Configure seu projeto para utilizar a engine no injetor de dependências `Services` e ativar o roteador do lado do `App`:

```pascal
uses
  Dext.Web.View,
  {$IFDEF DEXT_ENABLE_WEB_STENCILS}
  Web.Stencils,
  {$ENDIF}
  Dext.Web.View.WebStencils;

procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin
  Services
    // Outros serviços...
    .AddWebStencils(
      procedure(Opts: TViewOptions)
      begin
        Opts.TemplateRoot := TPath.GetFullPath('wwwroot/views');
        Opts.DefaultLayout := '_Layout.html';
        
        {$IFDEF DEXT_ENABLE_WEB_STENCILS}
        // Whitelist das suas entidades é importante para o Web Stencils ler Pessoas, Produtos etc...
        TWebStencilsProcessor.Whitelist.Configure(TCustomer, '', '', False);
        {$ENDIF}
      end);
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  App.Builder
    .UseViewEngine     // Habilitar a interpretação fluente
    .UseStaticFiles('wwwroot') // Libera acesso para imagens, JS e CSS
    // ... rotas
end;
```

### 2. Retornando uma View através das Rotas

A classe sintática helper `Results.View` pode ser retornada por qualquer API (Minimal ou Controllers):

```pascal
    .MapGet<IResult>('/',
      function: IResult
      begin
        // Mapeia e renderiza o arquivo "wwwroot/views/index.html"
        Result := Results.View('index');
      end)
```

Injetando Propriedades Avulsas (`WithValue`):

```pascal
    .MapGet<IResult>('/dashboard',
      function: IResult
      begin
        Result := Results.View('dashboard')
            .WithValue('PageTitle', 'Painel de Vendas')
            .WithValue('Version', 1.5);
      end)
```

**Uso no HTML (`dashboard.html`):**

```html
<h1>@PageTitle</h1>
<span>v@Version</span>
```

---

## O Poder do Streaming e Flyweight Iterators

O grande diferencial inovador de SSR dentro do Dext é quando você conecta o sistema de Views com a estrutura de persistência **ORM**.

Quase sempre que enviamos uma tabela inteira de banco de dados para renderizar numa Engine comum, acontece de as pessoas carregarem a lista em memória (ex: `ToList`). Para tabelas grandes (1.000, 10.000 resultados...), isso consome uma memória ram absurda e onera a sua API.

No Dext, se você passa o cursor direto do **Fluent Query API** para a `View`, nós criamos os **Flyweight Iterators** `TStreamingViewIterator<T>`.

**O que isso significa?** Significa que você pode exibir `1.000` resultados do banco de dados na web utilizando uso fixo de **Memória O(1)** (o equivalente a alocar _um único item_ no servidor). O iterador interage "sob demanda" conforme o loop `@foreach` do HTML corre.

### Listando Dados para a Tela

```pascal
    .MapGet<TMyDbContext, IResult>('/customers',
      function(Db: TMyDbContext): IResult
      begin
        // Você envia a QUERY (sem ToList)! O Dext engata o streaming automático.
        Result := Results.View<TCustomer>('customers', Db.Customers.QueryAll);
      end);
```

### Renderizando Smart Properties `@(Prop)`

A Engine de dados rica do Dext adota registros `Prop<T>` internamente nas classes ORM para rastreabilidade eficiente.
Para que a RTTI das Web Views leiam esse valor nativo, o Dext já vem configurado com uma mini-função global `@(Prop(value))`. Siga a regra de sempre blindar a propriedade no template baseada no framework:

**`customers.html`**

```html
<table class="table">
@foreach (var item in Model) {
  <tr>
    <!-- Sempre encapsule as Smart properties com @(Prop( ... )) -->
    <td>@(Prop(item.Id))</td>
    <td>@(Prop(item.Name))</td>
    <td>@(Prop(item.Email))</td>
  </tr>
}
</table>

@if Model.IsEmpty {
  <p>Nenhum cliente cadastrado.</p>
}
```

Observe a naturalidade do `@if Model.IsEmpty` - a API cuida para observar dinâmicamente a query sob debaixo dos panos validando se a tela precisa mostrar layout ou avisos.

## Integração com HTMX (E Parciais)

Como padrão o Dext assume seu layout principal apontado em `Opts.DefaultLayout`. Ao enviar uma view como `customers.html`, aquele arquivo será injetado perfeitamente no corpo principal de seu portal.

Mas para componentes de alta velocidade (Como HTMX Single Page Replacements) você pode suprimir isso e retornar layouts neutros (fragmentos Parciais).

```pascal
   Result := Results.View<TCustomer>('customers_list', Query).WithLayout(''); 
```

O legal é que a camada interna do `Dext` já possui proteção para detectar `HX-Requests` vindo do navegador, e suprimirá o layout global em endpoints que já suportem essa arquitetura de injeção automática! O que o torna o par perfeito para apps full-stack altamente dinâmicos.
