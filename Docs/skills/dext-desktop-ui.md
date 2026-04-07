---
name: dext-desktop-ui
description: Build VCL desktop applications with the Dext UI framework — Navigator for Flutter-inspired view management, Magic Binding for declarative two-way data binding, and MVVM architecture patterns.
---

# Dext Desktop UI

Flutter-inspired navigation and declarative binding for VCL desktop applications.

## Core Imports

```pascal
uses
  Dext.UI;          // Facade: INavigator, TNavigator, TMessage, all Bind* attributes, OnClickMsg
  Dext.UI.Binder;   // TMVUBinder<TModel, TMsg> — use directly (not re-exported by Dext.UI)
  Dext.UI.Navigator.Interfaces; // INavigator, INavigationMiddleware (if needed explicitly)
  Dext.UI.Navigator;            // TNavigator
  Dext.UI.Message;              // TMessage (if not using Dext.UI facade)
```

> `Dext.UI` re-exports: `BindText`, `BindChecked`, `BindEnabled`, `BindVisible`, `BindItems`,
> `OnClickMsg`, `INavigator`, `TNavigator`, `TMessage`.
> `TMVUBinder` must be imported from `Dext.UI.Binder` directly.

> 📦 Example: `Desktop.MVVM.CustomerCRUD`

---

## Navigator Framework

### Setup

```pascal
uses
  Dext.UI.Navigator;            // TNavigator
  Dext.UI.Navigator.Interfaces; // INavigator, INavigatorAdapter

// Create with DI provider (views are resolved via DI):
var Navigator := TNavigator.Create(ServiceProvider);
Navigator.UseAdapter(TCustomContainerAdapter.Create(ContentPanel));
```

### Navigation Methods

```pascal
Navigator.Push(TCustomerListFrame, []);           // Push new view (ViewClass, Params)
Navigator.Push(TCustomerEditFrame, ['id', 42]);   // Push with named params
Navigator.PushNamed('/customers/edit');           // Push by registered route name
Navigator.Pop;                                    // Go back
Navigator.Replace(TNewView, []);                  // Replace current
Navigator.PopAndPush(THomeView);                  // Pop all + push new root
```

### Receive Data in Target Frame

Implement `INavigationAware`:

```pascal
type
  TCustomerEditFrame = class(TFrame, INavigationAware)
  public
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
  end;

procedure TCustomerEditFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  if Context.HasValue then
    LoadCustomer(Context.Value.AsType<TCustomer>);
end;

procedure TCustomerEditFrame.OnNavigatedFrom;
begin
  // Cleanup or save state
end;
```

### Navigation Middleware

```pascal
// Auth guard
type
  TAuthMiddleware = class(TInterfacedObject, INavigationMiddleware)
  private
    FAuthService: IAuthService;
  public
    function Execute(const Context: TNavigationContext;
      Next: TNavigationDelegate): TNavigationResult;
  end;

function TAuthMiddleware.Execute(const Ctx: TNavigationContext;
  Next: TNavigationDelegate): TNavigationResult;
begin
  if not FAuthService.IsAuthenticated then
    Result := TNavigationResult.Blocked('Not authenticated')
  else
    Result := Next(Ctx);
end;

// Register middlewares
Navigator
  .UseMiddleware(TLoggingMiddleware.Create(Logger))
  .UseMiddleware(TAuthMiddleware.Create(AuthService));
```

### Adapters

```pascal
Navigator.UseAdapter(TCustomContainerAdapter.Create(ContentPanel)); // Embed in panel
Navigator.UseAdapter(TPageControlAdapter.Create(PageControl1));     // Tabs
Navigator.UseAdapter(TMDIAdapter.Create(Application));              // MDI windows
```

### DI Integration

```pascal
// Register TNavigator (DI-based, uses ServiceProvider to create view instances):
FNavigator := TNavigator.Create(FProvider);

// Or in DI container:
FServices.AddSingleton<INavigator>(
  function(P: IServiceProvider): TObject
  begin
    Result := TNavigator.Create(P);
  end);
```

---

## Magic Binding

Declarative two-way binding between VCL controls and ViewModel properties via RTTI attributes. Controls must be in the `published` section.

### Binding Attributes

```pascal
type
  // Messages for UI actions
  TSaveMsg = class(TMessage);
  TCancelMsg = class(TMessage);

  TCustomerEditFrame = class(TFrame)
  private
    FViewModel: TCustomerViewModel;
    FBinder: TMVUBinder<TCustomerViewModel, TMessage>;
    procedure DispatchMsg(Msg: TMessage);
  published
    [BindEdit('Name')]               // TEdit ↔ ViewModel.Name (two-way)
    NameEdit: TEdit;

    [BindText('Id', 'Customer #%s')] // TLabel ← format string with ViewModel.Id
    TitleLabel: TLabel;

    [BindText('Errors.Text')]        // TLabel ← ViewModel.Errors.Text (one-way)
    ErrorsLabel: TLabel;

    [BindChecked('Active')]          // TCheckBox ↔ ViewModel.Active
    ActiveCheckBox: TCheckBox;

    [BindMemo('Notes')]              // TMemo ↔ ViewModel.Notes
    NotesMemo: TMemo;

    [BindEnabled('CanSave')]         // Control.Enabled ← ViewModel.CanSave
    [OnClickMsg(TSaveMsg)]           // Button click → dispatch TSaveMsg
    SaveButton: TButton;

    [OnClickMsg(TCancelMsg)]
    CancelButton: TButton;

    [BindVisible('Errors.Count', False)] // Panel.Visible ← Errors.Count <> 0 (inverted)
    ErrorPanel: TPanel;
  end;
```

| Attribute | Control | Direction |
|-----------|---------|-----------|
| `[BindEdit('Prop')]` | TEdit | Two-way |
| `[BindText('Prop')]` | TLabel | One-way (read) |
| `[BindText('Prop', 'fmt %s')]` | TLabel | One-way with format string |
| `[BindChecked('Prop')]` | TCheckBox | Two-way |
| `[BindMemo('Prop')]` | TMemo | Two-way |
| `[BindEnabled('Prop')]` | Any control | One-way (Enabled) |
| `[BindVisible('Prop', Invert)]` | Any control | One-way (Visible, optional invert) |
| `[OnClickMsg(TMsgClass)]` | TButton | Click → message dispatch |

> **IMPORTANT**: The attribute is `[BindChecked]` — NOT `[BindCheckBox]`.
> Controls with binding attributes must be declared as `published` fields of the Frame.

### Setup and Render

```pascal
uses
  Dext.UI.Binder;  // TMVUBinder<TModel, TMsg>

constructor TCustomerEditFrame.Create(AOwner: TComponent);
begin
  inherited;
  FViewModel := TCustomerViewModel.Create;
  // Create binder: (Frame, DispatchCallback)
  FBinder := TMVUBinder<TCustomerViewModel, TMessage>.Create(Self, DispatchMsg);
end;

destructor TCustomerEditFrame.Destroy;
begin
  FBinder.Free;
  FViewModel.Free;
  inherited;
end;

// Call after ViewModel data changes to sync controls
procedure TCustomerEditFrame.LoadCustomer(AViewModel: TCustomerViewModel);
begin
  FViewModel.Load(AViewModel.GetEntity);
  FBinder.Render(FViewModel);  // Push Model → controls
end;

// Message handler — called by binder on UI events
procedure TCustomerEditFrame.DispatchMsg(Msg: TMessage);
begin
  if Msg is TSaveMsg then
  begin
    if FViewModel.Validate then
    begin
      if Assigned(FOnSave) then
        FOnSave(FViewModel);
    end
    else
      FBinder.Render(FViewModel); // Re-render to show validation errors
  end
  else if Msg is TCancelMsg then
  begin
    if Assigned(FOnCancel) then
      FOnCancel();
  end;
end;
```

### Nested Properties (Dot Notation)

```pascal
[BindEdit('Customer.Address.City')]
CityEdit: TEdit;

[BindText('Errors.Text')]
ErrorsLabel: TLabel;
```

### Custom Type Converters

```pascal
type
  TCurrencyConverter = class(TInterfacedObject, IValueConverter)
    function Convert(const Value: TValue): TValue;
    function ConvertBack(const Value: TValue): TValue;
  end;

[BindEdit('Price', TCurrencyConverter)]
PriceEdit: TEdit;
```

---

## MVVM Architecture

### Recommended Structure

```
Features/
├── Customers/
│   ├── Customer.Entity.pas        # ORM entity
│   ├── Customer.Service.pas       # Business logic interface + impl
│   ├── Customer.Controller.pas    # Orchestrator (actions → service → view)
│   ├── Customer.ViewModel.pas     # Wraps entity, adds validation + UI state
│   ├── Customer.Rules.pas         # Pure validation logic (testable)
│   ├── Customer.List.pas          # TFrame — list view
│   └── Customer.Edit.pas          # TFrame — edit view
```

### ViewModel Pattern

```pascal
type
  TCustomerViewModel = class
  private
    FCustomer: TCustomer;
    FErrors: TStrings;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load(Customer: TCustomer; AOwnsCustomer: Boolean = False);
    procedure Clear;
    function Validate: Boolean;
    function GetEntity: TCustomer;

    // Bindable properties
    property Name: string read GetName write SetName;
    property Email: string read GetEmail write SetEmail;
    property IsNew: Boolean read GetIsNew;
    property Errors: TStrings read FErrors;
  end;

function TCustomerViewModel.Validate: Boolean;
var Errors: TArray<string>;
begin
  FErrors.Clear;
  Result := TCustomerRules.ValidateAll(FCustomer, Errors);
  for var E in Errors do
    FErrors.Add(E);
end;
```

### Controller Pattern

```pascal
type
  ICustomerController = interface
    procedure SetView(View: ICustomerView);
    procedure LoadCustomers;
    procedure SaveCustomer;
    procedure DeleteCustomer(Id: Integer);
  end;

  TCustomerController = class(TInterfacedObject, ICustomerController)
  private
    FService: ICustomerService;
    FNavigator: ISimpleNavigator;
    FView: ICustomerView;
  public
    constructor Create(Service: ICustomerService; Navigator: ISimpleNavigator);
  end;
```

### View Interface (Enables Mocking)

```pascal
type
{$M+}  // REQUIRED for Mock<ICustomerView> to work — wrap the whole block
  ICustomerView = interface
    ['{B7E206D4-A6A4-4A2D-A2A6-D2C979E9B9A6}']
    procedure RefreshList(const Customers: IList<TCustomer>);
    procedure ShowEditView(ViewModel: TCustomerViewModel);
    procedure ShowListView;
    procedure ShowMessage(const Msg: string);
  end;
{$M-}
```

> Use `{$M+}...{$M-}` around any interface you plan to mock in tests.
> Note: the method is `ShowMessage`, not `ShowError`.

### DI Registration

```pascal
FServices := TDextServices.New;
FServices.AddSingleton<ILogger>(TConsoleLogger.Create('App'));
FServices.AddDbContext<TCustomerContext>(...);
FServices.AddSingleton<ICustomerService, TCustomerService>;
FServices.AddTransient<ICustomerController, TCustomerController>;
FProvider := FServices.BuildServiceProvider;

// Navigator requires the built provider:
FNavigator := TNavigator.Create(FProvider);
```

---

## MVU Pattern

Model-View-Update: immutable state, unidirectional data flow, pure update function. Framework-independent — just Delphi.

### Model (immutable record)

```pascal
type
  TCounterModel = record
    Count: Integer;
    Step: Integer;
    History: string;

    class function Init: TCounterModel; static;

    // With* methods return a copy with one field changed:
    function WithCount(const NewCount: Integer): TCounterModel;
    function WithStep(const NewStep: Integer): TCounterModel;
  end;
```

### Messages

Two styles — enum (simple) or class-based (with data):

```pascal
// Simple enum style (Desktop.MVU.Counter):
TCounterMessage = (IncrementMsg, DecrementMsg, ResetMsg, SetStep1Msg, ...);

// Class-based style (Desktop.MVU.CounterFrame — preferred):
uses Dext.UI.Message;  // TMessage base class

type
  TIncrementMsg = class(TMessage);
  TDecrementMsg = class(TMessage);
  TResetMsg = class(TMessage);

  // Messages carrying data:
  TSetStepMsg = class(TMessage)
  public
    Step: Integer;
    constructor Create(AStep: Integer); reintroduce;
  end;
```

### Update (pure function)

```pascal
type
  TCounterUpdate = class
    class function Update(const Model: TCounterModel;
      const Msg: TCounterMessage): TCounterModel; static;
  end;

class function TCounterUpdate.Update(const Model: TCounterModel;
  const Msg: TCounterMessage): TCounterModel;
begin
  Result := Model;
  case Msg of
    IncrementMsg:
      Result := Model.WithCount(Model.Count + 1);
    DecrementMsg:
      Result := Model.WithCount(Model.Count - 1);
    ResetMsg:
      Result := TCounterModel.Init;
  end;
end;
```

### View (TFrame in IDE + Render)

```pascal
uses Dext.UI.Message;

// Dispatch callback type
TDispatchProc = reference to procedure(const Msg: TCounterMsg);

type
  TCounterViewFrame = class(TFrame)
    CountLabel: TLabel;
    IncrementButton: TButton;
    // ... designed in IDE
  private
    FDispatch: TDispatchProc;
    procedure OnIncrementClick(Sender: TObject);
    procedure WireEvents;
  public
    procedure Initialize(ADispatch: TDispatchProc);
    procedure Render(const Model: TCounterModel);
  end;

procedure TCounterViewFrame.Initialize(ADispatch: TDispatchProc);
begin
  FDispatch := ADispatch;
  WireEvents;
end;

procedure TCounterViewFrame.WireEvents;
begin
  IncrementButton.OnClick := OnIncrementClick;
end;

procedure TCounterViewFrame.OnIncrementClick(Sender: TObject);
begin
  if Assigned(FDispatch) then
    FDispatch(TIncrementMsg.Create);
end;

// Called every time model changes:
procedure TCounterViewFrame.Render(const Model: TCounterModel);
begin
  CountLabel.Caption := Model.Count.ToString;
  StepLabel.Caption := Format('Step: %d', [Model.Step]);
end;
```

### Runtime (MVU loop)

```pascal
// Generic MVU runtime (from Counter example):
TMVURuntime<TModel> = class
  private
    FModel: TModel;
    FOnModelChanged: TProc<TModel>;
  public
    constructor Create(const InitialModel: TModel; OnChanged: TProc<TModel>);
    procedure UpdateModel(const NewModel: TModel);
    property Model: TModel read FModel;
  end;

// Usage in main form:
FRuntime := TMVURuntime<TCounterModel>.Create(
  TCounterModel.Init,
  procedure(M: TCounterModel)
  begin
    FView.Render(M);  // Re-render on every state change
  end);

FView := TCounterViewFrame.Create(ContentPanel);
FView.Initialize(
  procedure(Msg: TCounterMsg)
  begin
    // Dispatch: current model + message → new model
    FRuntime.UpdateModel(TCounterUpdate.Update(FRuntime.Model, Msg));
  end);
```

---

## Examples

| Example | What it shows |
|---------|---------------|
| `Desktop.MVVM.CustomerCRUD` | Full MVVM: TMVUBinder, Navigator, TNavigator, validation, mocked tests |
| `Desktop.MVU.Counter` | MVU with enum messages, pure update, no framework deps |
| `Desktop.MVU.CounterFrame` | MVU with class-based messages (TMessage), TFrame in IDE, Render pattern |
