program Web.DatabaseAsApi;

{$APPTYPE CONSOLE}

uses
  Dext.MM,
  Dext.Utils,
  System.SysUtils,
  System.Classes,
  
  // Dext Framework
  Dext,
  Dext.Entity,
  Dext.Web,
  Dext.Web.DataApi,
  Dext.Web.Results,
  Dext.Web.Interfaces,
  Dext.DI.Interfaces,

  // Smart Types (TUUID)
  Dext.Types.UUID,

  // Swagger/OpenAPI
  Dext.OpenAPI.Generator,
  Dext.Swagger.Middleware,

  // Storage
  FireDAC.Comp.Client,
  
  // Logging
  Dext.Logging,
  Dext.Logging.Extensions,
  Dext.Logging.Console;

type
  { --- ENTITY 1: Simple Integer PK (AutoInc) --- }
  [Table('Customers')]
  TCustomer = class
  private
    FId: Integer;
    FName: string;
    FEmail: string;
    FActive: Boolean;
    FCreatedAt: TDateTime;
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Email: string read FEmail write FEmail;
    property Active: Boolean read FActive write FActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

  { --- ENTITY 2: UUID PK (Manual/Auto generated) --- }
  [Table('SystemLogs')]
  TSystemLog = class
  private
    FId: TUUID;
    FMessage: string;
    FLogTime: TDateTime;
  public
    [PK]
    property Id: TUUID read FId write FId;
    property Message: string read FMessage write FMessage;
    property LogTime: TDateTime read FLogTime write FLogTime;
  end;

  TDatabaseContext = class(TDbContext)
  protected
    procedure OnModelCreating(Builder: TModelBuilder); override;
  end;

  TStartup = class(TInterfacedObject, IStartup)
  public
    procedure ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
    procedure Configure(const App: IWebApplication);
  end;

{ TDatabaseContext }

procedure TDatabaseContext.OnModelCreating(Builder: TModelBuilder);
begin
  inherited;
  Builder.Entity<TCustomer>;
  Builder.Entity<TSystemLog>;
end;

{ TStartup }

procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin
  Services.AddLogging(
    procedure(Builder: ILoggingBuilder)
    begin
        Builder
          .SetMinimumLevel(TLogLevel.Debug)
          .AddConsole
          .AddTelemetry;
    end);

  { --- Standard Dext Scoped DbContext with Physical SQLite DB --- }
  { UseSQLite is a fluent extension that creates the connection pool properly. }
  { To avoid closure capture issues (AV), we call the extension with a literal string. }
  
  Services.AddDbContext<TDatabaseContext>(
    procedure(Options: TDbContextOptions)
    begin
      Options.UseSQLite('databaseapi.db');
      Options.Pooling := True;
    end);
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  App.Builder
    {$IFDEF DEBUG}
    .UseDeveloperExceptionPage()
    {$ELSE}
    .UseHttpLogging()
    {$ENDIF}
    .UseExceptionHandler()
    .MapGet('/', 
      procedure(Ctx: IHttpContext)
      begin
        Results.Text('Database as API Example (Physical SQLite). Go to /api/customers or /api/logs').Execute(Ctx);
      end)
    
    // --- Data API for Integer PK ---
    .MapDataApi<TCustomer>('/api/customers',
      DataApiOptions
        .DbContext<TDatabaseContext>
        .UseSnakeCase
        .Tag('Customers')
        .UseSwagger)

    // --- Data API for UUID PK ---
    .MapDataApi<TSystemLog>('/api/logs',
      DataApiOptions
        .DbContext<TDatabaseContext>
        .UseSnakeCase
        .Tag('System Logs')
        .UseSwagger)

    .UseSwagger(
      Swagger
        .Title('Database as API - CRUD Examples')
        .Description('Auto-generated REST API from Dext entities with Physical SQLite support.')
        .Version('1.0.0')
        .Server('http://localhost:5000', 'Development server')
    );
end;

procedure SeedDatabase(const Provider: IServiceProvider);
var
  Scope: IServiceScope;
  Db: TDatabaseContext;
  Customer: TCustomer;
  Log: TSystemLog;
begin
  Scope := Provider.CreateScope;
  try
    Db := Scope.ServiceProvider.GetService(TDatabaseContext) as TDatabaseContext;
    if Assigned(Db) then
    begin
      Db.EnsureCreated;

      { Only seed if empty to avoid duplicates in physical DB }
      if Db.Entities<TCustomer>.QueryAll.Count = 0 then
      begin
        Writeln('Seeding database...');
        
        Customer := TCustomer.Create;
        Customer.Name := 'John Doe';
        Customer.Email := 'john@example.com';
        Customer.Active := True;
        Customer.CreatedAt := Now;
        Db.Entities<TCustomer>.Add(Customer);

        Customer := TCustomer.Create;
        Customer.Name := 'Jane Smith';
        Customer.Email := 'jane@example.com';
        Customer.Active := True;
        Customer.CreatedAt := Now;
        Db.Entities<TCustomer>.Add(Customer);
        
        Log := TSystemLog.Create;
        Log.Id := TUUID.NewV4; 
        Log.Message := 'System startup (Physical DB).';
        Log.LogTime := Now;
        Db.Entities<TSystemLog>.Add(Log);

        Db.SaveChanges;
        Writeln('Database seeded.');
      end;
    end;
  finally
    Scope := nil;
  end;
end;

var
  App: IWebApplication;
  Provider: IServiceProvider;
begin
  SetConsoleCharSet;
  try
    Writeln('Dext Database as API Example (Physical SQLite DB)');
    Writeln('==================================================');
    Writeln('');
    
    App := WebApplication;
    App.UseStartup(TStartup.Create);
    
    Provider := App.BuildServices;
    if Provider <> nil then
      SeedDatabase(Provider);
    
    Writeln('Server listening on http://localhost:5000');
    App.Run(5000);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  
  { Explicit cleanup at the very end }
  App := nil;
  Provider := nil;
  
  ConsolePause;
end.
