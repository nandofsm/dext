# SSR & View Engines

The Dext Framework provides first-class support for **Server-Side Rendering (SSR)**. This means that, in addition to being excellent for creating robust JSON APIs (whether fluent or via traditional MVC Controllers), Dext also makes it easy to build full web applications by rendering HTML on the server side.

The implemented design focuses on being **engine-agnostic**, offering ideal memory speed contours with the ability to extend to any engine, and featuring active integration for Embarcadero's new native technology: **Web Stencils**.

## The Agnostic Architecture

Dext's architecture abstracts specific details about how HTML will be validated. All state control goes through:

* **`IViewEngine`**: An interface that any third-party template engine needs to implement to serve pages.
* **`TViewData`**: A "ViewBag" dictionary where all global variables to be inserted into the HTML reside.
* **`Results.View`**: A method in the server's fluent injector that returns a compatible `IResult` and routes the web request without coupling.

You configure your engine directly in `Program.pas` / `Startup.pas` when adding services.

## Web Stencils Integration (Delphi 12.2+)

Starting with Delphi 12.2, Embarcadero introduced **Web Stencils**. Dext already includes a Provider built exclusively for it with insane data connectivity features.

### 1. Adding Support

Configure your project to use the engine in the dependency injector `Services` and activate the App-side router:

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
    // Other services...
    .AddWebStencils(
      procedure(Opts: TViewOptions)
      begin
        Opts.TemplateRoot := TPath.GetFullPath('wwwroot/views');
        Opts.DefaultLayout := '_Layout.html';
        
        {$IFDEF DEXT_ENABLE_WEB_STENCILS}
        // Whitelisting your entities is important for Web Stencils to read People, Products, etc...
        TWebStencilsProcessor.Whitelist.Configure(TCustomer, '', '', False);
        {$ENDIF}
      end);
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  App.Builder
    .UseViewEngine             // Enable fluent interpretation
    .UseStaticFiles('wwwroot') // Allow access to images, JS, and CSS
    // ... routes
end;
```

### 2. Returning a View from Routes

The `Results.View` syntax helper class can be returned by any API (Minimal or Controllers):

```pascal
    .MapGet<IResult>('/',
      function: IResult
      begin
        // Maps and renders the file "wwwroot/views/index.html"
        Result := Results.View('index');
      end)
```

Injecting Single Properties (`WithValue`):

```pascal
    .MapGet<IResult>('/dashboard',
      function: IResult
      begin
        Result := Results.View('dashboard')
            .WithValue('PageTitle', 'Sales Dashboard')
            .WithValue('Version', 1.5);
      end)
```

**Usage in HTML (`dashboard.html`):**

```html
<h1>@PageTitle</h1>
<span>v@Version</span>
```

---

## The Power of Streaming and Flyweight Iterators

The great innovative differentiator of SSR within Dext is when you connect the View system with the **ORM** persistence structure.

Almost every time we send an entire database table to render in a common Engine, people load the list in memory (e.g., `ToList`). For large tables (1,000, 10,000 results...), this consumes absurd RAM memory and burdens your API.

In Dext, if you pass the direct cursor of the **Fluent Query API** to the `View`, we create **Flyweight Iterators** `TStreamingViewIterator<T>`.

**What does this mean?** It means you can display `1,000` database results on the web using a fixed **O(1) Memory footprint** (equivalent to allocating _a single item_ on the server). The iterator interacts "on demand" as the HTML `@foreach` loop runs.

### Listing Data to the Screen

```pascal
    .MapGet<TMyDbContext, IResult>('/customers',
      function(Db: TMyDbContext): IResult
      begin
        // You send the QUERY (without ToList)! Dext engages automatic streaming.
        Result := Results.View<TCustomer>('customers', Db.Customers.QueryAll);
      end);
```

### Rendering Smart Properties `@(Prop)`

Dext's rich data engine adopts `Prop<T>` records internally in ORM classes for efficient traceability.
For the Web Views RTTI to read this native value, Dext already comes configured with a global mini-function `@(Prop(value))`. Follow the rule to always shield the property in the template based on the framework:

**`customers.html`**

```html
<table class="table">
@foreach (var item in Model) {
  <tr>
    <!-- Always encapsulate Smart properties with @(Prop( ... )) -->
    <td>@(Prop(item.Id))</td>
    <td>@(Prop(item.Name))</td>
    <td>@(Prop(item.Email))</td>
  </tr>
}
</table>

@if Model.IsEmpty {
  <p>No customers recorded.</p>
}
```

Note the naturalness of `@if Model.IsEmpty` - the API handles dynamic observations to the underlying query to validate if the screen needs to show layout or warnings.

## Integration with HTMX (And Partials)

By default, Dext assumes your main layout points to `Opts.DefaultLayout`. When sending a view like `customers.html`, that file will be perfectly injected into your portal's main body.

But for high-speed components (like HTMX Single Page Replacements) you can suppress this and return neutral layouts (Partial fragments).

```pascal
   Result := Results.View<TCustomer>('customers_list', Query).WithLayout(''); 
```

The cool thing is that Dext's internal layer already has protection to detect `HX-Requests` coming from the browser, and will suppress the global layout on endpoints that already support this automatic injection architecture! Making it the perfect pair for highly dynamic full-stack apps.
