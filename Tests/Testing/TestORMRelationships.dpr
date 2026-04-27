program TestORMRelationships;

{$APPTYPE CONSOLE}

uses
  Dext.MM,
  Dext.Utils,
  System.SysUtils,
  Dext.Testing.Attributes,
  Dext.Testing.Runner,
  Dext.Testing,
  TestManyToManyIntegration in 'TestManyToManyIntegration.pas',
  TestEntityRelationships in 'TestEntityRelationships.pas',
  TestLazyLoadingRelationships in 'TestLazyLoadingRelationships.pas';

begin
  SetConsoleCharset;
  try
    WriteLn('🧪 Dext ORM Relationship Mapping Tests');
    WriteLn('=======================================');
    WriteLn;

    TTest.SetExitCode(
      TTest
        .Configure
        .Verbose
        .RegisterFixtures([
           TManyToManyIntegrationTests,
           TEntityRelationshipTests,
           TLazyLoadingRelationshipTests
         ])
        .Run
    );

  except
    on E: Exception do
    begin
      WriteLn('FATAL ERROR: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;

  ConsolePause;
end.
