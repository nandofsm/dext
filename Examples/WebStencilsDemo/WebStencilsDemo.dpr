program WebStencilsDemo;

{$APPTYPE CONSOLE}

uses
  Dext.MM,
  System.SysUtils,
  Dext,
  Dext.Web,
  Dext.Web.Interfaces,
  Dext.Utils,
  Startup in 'Startup.pas',
  Customer in 'Models\Customer.pas';

begin
  SetConsoleCharset;
  try
    // Use the WebApplication helper for a cleaner setup
    var App: IWebApplication := WebApplication;
    
    // Register the startup class
    App.UseStartup(TStartup.Create);

    // Build services and seed database BEFORE running
    Writeln('🔧 Initializing services...');
    var Provider := App.BuildServices;

    Writeln('📦 Setting up database...');
    TStartup.SeedData(Provider);

    Writeln('🚀 Server starting on http://localhost:5000');
    
    // Run the application
    App.Run(5000);
  except
    on E: Exception do
    begin
      Writeln('❌ Error: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
  ConsolePause;
end.
