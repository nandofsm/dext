program Orm.EntityStyles;

{$APPTYPE CONSOLE}

uses
  Dext.MM,
  Dext.Utils,
  EntityStyles.Demo in 'EntityStyles.Demo.pas';

begin
  SetConsoleCharSet;
  RunDemo;
  ConsolePause;
end.
