unit Dext.Json.Regression.Tests;

interface

uses
  System.SysUtils,
  System.Rtti,
  Dext.Testing.Attributes,
  Dext.Assertions,
  Dext.Json,
  Dext.Json.Types;

type
  TMyRecord = record
    IdRecord: Integer;
    Descricao: string;
  end;

  [TestFixture('JSON Regression Tests')]
  TJsonRegressionTests = class
  public
    [Test('Should produce indented JSON when TJsonSettings.Indented is used')]
    procedure TestIndentedFormatting;

    [Test('Should produce compact JSON when TJsonSettings.Default is used')]
    procedure TestCompactFormatting;

    [Test('Should produce indented JSON for arrays when TJsonSettings.Indented is used')]
    procedure TestArrayIndention;
  end;

implementation

{ TJsonRegressionTests }

procedure TJsonRegressionTests.TestIndentedFormatting;
var
  LMyRecord: TMyRecord;
  LJsonIndented: string;
begin
  LMyRecord.IdRecord := 1;
  LMyRecord.Descricao := 'Descricao';

  LJsonIndented := TDextJson.Serialize(TValue.From<TMyRecord>(LMyRecord), TJsonSettings.Indented);

  Should(LJsonIndented).NotBeEmpty;
  // Indented JSON should have line breaks. 
  // We check for presence of at least one line break (\r or \n)
  Should(LJsonIndented.Contains(#13) or LJsonIndented.Contains(#10)).BeTrue;
  Should(LJsonIndented.Contains(' "IdRecord": 1') or LJsonIndented.Contains(#9'"IdRecord": 1'));
end;

procedure TJsonRegressionTests.TestCompactFormatting;
var
  LMyRecord: TMyRecord;
  LJsonCompact: string;
begin
  LMyRecord.IdRecord := 1;
  LMyRecord.Descricao := 'Descricao';

  LJsonCompact := TDextJson.Serialize(TValue.From<TMyRecord>(LMyRecord), TJsonSettings.Default);

  Should(LJsonCompact).NotBeEmpty;
  // Compact JSON should NOT have line breaks
  Should(LJsonCompact.Contains(#13)).BeFalse;
  Should(LJsonCompact.Contains(#10)).BeFalse;
  Should(LJsonCompact).Be('{"IdRecord":1,"Descricao":"Descricao"}');
end;

procedure TJsonRegressionTests.TestArrayIndention;
var
  LArray: TArray<Integer>;
  LJson: string;
begin
  LArray := [1, 2, 3];
  LJson := TDextJson.Serialize(TValue.From<TArray<Integer>>(LArray), TJsonSettings.Indented);

  Should(LJson).NotBeEmpty;
  Should(LJson.Contains(#13) or LJson.Contains(#10)).BeTrue;
  Should(LJson).Contain('1');
  Should(LJson).Contain('2');
  Should(LJson).Contain('3');
end;

end.
