program Dext.Core.UnitTests;

{$IFNDEF TESTINSIGHT}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  Dext.MM,
  Dext.Core.Debug,
  System.SysUtils,
  Dext.Testing.Runner,
  Dext.Testing.Attributes,
  Dext.Testing.Fluent,
  Dext.Testing,
  Dext.Utils,
  Dext.Json.Refactored.Tests in 'Dext.Json.Refactored.Tests.pas',
  Dext.Configuration.Features.Tests in 'Dext.Configuration.Features.Tests.pas',
  Dext.Configuration.Hashing.Tests in 'Dext.Configuration.Hashing.Tests.pas',
  Dext.Hosting.Events.Tests in 'Dext.Hosting.Events.Tests.pas';

begin
  {$IFDEF TESTINSIGHT}
  HideConsoleIfAutocreated;
  {$ENDIF}
  SetConsoleCharSet();
  try
    SafeWriteLn;
    SafeWriteLn('🧪 Dext Core Unit Tests');
    SafeWriteLn('=======================');
    SafeWriteLn;

    RunTests(ConfigureTests
      .VeryVerbose
      {$IFDEF TESTINSIGHT}
      .UseTestInsight
      {$ENDIF}
      .RegisterFixtures([
        TJsonInterfaceListTests,
        TConfigFeaturesTests,
        TConfigurationHashingTests,
        THostingEventsTests
      ]));
  except
    on E: Exception do
    begin
      SafeWriteLn('FATAL ERROR: ' + E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
