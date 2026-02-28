unit Bench.RTL;

interface

uses
  System.SysUtils, System.Diagnostics, System.Generics.Collections, System.Generics.Defaults,
  Bench.Core, Bench.Common;

type
  TRTLBench = class
  public
    class procedure RunInteger(Bench: TBenchmark; Size: Integer);
    class procedure RunString(Bench: TBenchmark; Size: Integer);
    class procedure RunObject(Bench: TBenchmark; Size: Integer);
    class procedure RunRecordSmall(Bench: TBenchmark; Size: Integer);
    class procedure RunCurrency(Bench: TBenchmark; Size: Integer);
    class procedure RunPointer(Bench: TBenchmark; Size: Integer);
  end;

implementation

{ TRTLBench }

class procedure TRTLBench.RunInteger(Bench: TBenchmark; Size: Integer);
var
  List: TList<Integer>;
  Dict: TDictionary<Integer, string>;
  I, Val: Integer;
  S: string;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Integer', Size);
  Stop := TStopwatch.StartNew;
  List := TList<Integer>.Create;
  try
    for I := 1 to Size do List.Add(I);
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    for Val in List do ;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Sort', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    List.Sort;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'IndexOf', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    List.IndexOf(Size div 2);
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('Dictionary', 'Add', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    Dict := TDictionary<Integer, string>.Create;
    try
      for I := 1 to Size do Dict.Add(I, 'val' + IntToStr(I));
      Stop.Stop;
      Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

      Bench.StartScenario('Dictionary', 'Lookup', 'Integer', Size);
      Stop := TStopwatch.StartNew;
      for I := 1 to Size do Dict.TryGetValue(I, S);
      Stop.Stop;
      Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);
    finally
      Dict.Free;
    end;

    Bench.StartScenario('List', 'Remove-First', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    while List.Count > 0 do List.Delete(0);
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

  finally
    List.Free;
  end;
end;

class procedure TRTLBench.RunString(Bench: TBenchmark; Size: Integer);
var
  List: TList<string>;
  I: Integer;
  Val: string;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'String', Size);
  Stop := TStopwatch.StartNew;
  List := TList<string>.Create;
  try
    for I := 1 to Size do List.Add('Value' + IntToStr(I));
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'String', Size);
    Stop := TStopwatch.StartNew;
    for Val in List do ;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Sort', 'String', Size);
    Stop := TStopwatch.StartNew;
    List.Sort;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Remove-Last', 'String', Size);
    Stop := TStopwatch.StartNew;
    while List.Count > 0 do List.Delete(List.Count - 1);
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);
  finally
    List.Free;
  end;
end;

class procedure TRTLBench.RunRecordSmall(Bench: TBenchmark; Size: Integer);
var
  List: TList<TTestRecordSmall>;
  I: Integer;
  R: TTestRecordSmall;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'RecordSmall', Size);
  Stop := TStopwatch.StartNew;
  List := TList<TTestRecordSmall>.Create;
  try
    for I := 1 to Size do
    begin
      R.ID := I;
      R.Value := 1.23 * I;
      R.Name := 'Item';
      List.Add(R);
    end;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'RecordSmall', Size);
    Stop := TStopwatch.StartNew;
    for R in List do ;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);
  finally
    List.Free;
  end;
end;

class procedure TRTLBench.RunObject(Bench: TBenchmark; Size: Integer);
var
  List: TObjectList<TTestObject>;
  I: Integer;
  Obj: TTestObject;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Object', Size);
  Stop := TStopwatch.StartNew;
  List := TObjectList<TTestObject>.Create(True);
  try
    for I := 1 to Size do
    begin
      Obj := TTestObject.Create;
      Obj.ID := I;
      Obj.Name := 'Object';
      List.Add(Obj);
    end;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Object', Size);
    Stop := TStopwatch.StartNew;
    for Obj in List do ;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);
  finally
    List.Free;
  end;
end;

class procedure TRTLBench.RunCurrency(Bench: TBenchmark; Size: Integer);
var
  List: TList<Currency>;
  I: Integer;
  Val: Currency;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Currency', Size);
  Stop := TStopwatch.StartNew;
  List := TList<Currency>.Create;
  try
    for I := 1 to Size do List.Add(I * 1.5);
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Currency', Size);
    Stop := TStopwatch.StartNew;
    for Val in List do ;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);
  finally
    List.Free;
  end;
end;

class procedure TRTLBench.RunPointer(Bench: TBenchmark; Size: Integer);
var
  List: TList<Pointer>;
  I: Integer;
  P: Pointer;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Pointer', Size);
  Stop := TStopwatch.StartNew;
  List := TList<Pointer>.Create;
  try
    for I := 1 to Size do List.Add(Pointer(I));
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Pointer', Size);
    Stop := TStopwatch.StartNew;
    for P in List do ;
    Stop.Stop;
    Bench.AddResult('RTL', Stop.Elapsed.TotalMilliseconds);
  finally
    List.Free;
  end;
end;

end.
