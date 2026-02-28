unit Bench.Dext;

interface

uses
  System.SysUtils, System.Diagnostics, Dext.Collections, Dext.Collections.Dict,
  Bench.Core, Bench.Common;

type
  TDextBench = class
  public
    class procedure RunInteger(Bench: TBenchmark; Size: Integer);
    class procedure RunString(Bench: TBenchmark; Size: Integer);
    class procedure RunObject(Bench: TBenchmark; Size: Integer);
    class procedure RunRecordSmall(Bench: TBenchmark; Size: Integer);
    class procedure RunCurrency(Bench: TBenchmark; Size: Integer);
    class procedure RunPointer(Bench: TBenchmark; Size: Integer);
  end;

implementation

{ TDextBench }

class procedure TDextBench.RunInteger(Bench: TBenchmark; Size: Integer);
var
  List: IList<Integer>;
  Dict: IDictionary<Integer, string>;
  I, Val: Integer;
  S: string;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Integer', Size);
  Stop := TStopwatch.StartNew;
  List := TCollections.CreateList<Integer>;
  try
    for I := 1 to Size do List.Add(I);
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    for Val in List do ;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Sort', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    List.Sort;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'IndexOf', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    List.IndexOf(Size div 2);
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('Dictionary', 'Add', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    Dict := TCollections.CreateDictionary<Integer, string>;
    try
      for I := 1 to Size do Dict.Add(I, 'val' + IntToStr(I));
      Stop.Stop;
      Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

      Bench.StartScenario('Dictionary', 'Lookup', 'Integer', Size);
      Stop := TStopwatch.StartNew;
      for I := 1 to Size do Dict.TryGetValue(I, S);
      Stop.Stop;
      Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);
    finally
      Dict.Clear;
    end;

    Bench.StartScenario('List', 'Remove-First', 'Integer', Size);
    Stop := TStopwatch.StartNew;
    while List.Count > 0 do List.Delete(0);
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

  finally
    List := nil;
  end;
end;

class procedure TDextBench.RunString(Bench: TBenchmark; Size: Integer);
var
  List: IList<string>;
  I: Integer;
  Val: string;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'String', Size);
  Stop := TStopwatch.StartNew;
  List := TCollections.CreateList<string>;
  try
    for I := 1 to Size do List.Add('Value' + IntToStr(I));
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'String', Size);
    Stop := TStopwatch.StartNew;
    for Val in List do ;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Sort', 'String', Size);
    Stop := TStopwatch.StartNew;
    List.Sort;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Remove-Last', 'String', Size);
    Stop := TStopwatch.StartNew;
    while List.Count > 0 do List.RemoveAt(List.Count - 1);
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);
  finally
    List := nil;
  end;
end;

class procedure TDextBench.RunRecordSmall(Bench: TBenchmark; Size: Integer);
var
  List: IList<TTestRecordSmall>;
  I: Integer;
  R: TTestRecordSmall;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'RecordSmall', Size);
  Stop := TStopwatch.StartNew;
  List := TCollections.CreateList<TTestRecordSmall>;
  try
    for I := 1 to Size do
    begin
      R.ID := I;
      R.Value := 1.23 * I;
      R.Name := 'Item';
      List.Add(R);
    end;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'RecordSmall', Size);
    Stop := TStopwatch.StartNew;
    for R in List do ;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);
  finally
    List := nil;
  end;
end;

class procedure TDextBench.RunObject(Bench: TBenchmark; Size: Integer);
var
  List: IList<TTestObject>;
  I: Integer;
  Obj: TTestObject;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Object', Size);
  Stop := TStopwatch.StartNew;
  List := TCollections.CreateObjectList<TTestObject>(True);
  try
    for I := 1 to Size do
    begin
      Obj := TTestObject.Create;
      Obj.ID := I;
      Obj.Name := 'Object';
      List.Add(Obj);
    end;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Object', Size);
    Stop := TStopwatch.StartNew;
    for Obj in List do ;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);
  finally
    List := nil;
  end;
end;

class procedure TDextBench.RunCurrency(Bench: TBenchmark; Size: Integer);
var
  List: IList<Currency>;
  I: Integer;
  Val: Currency;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Currency', Size);
  Stop := TStopwatch.StartNew;
  List := TCollections.CreateList<Currency>;
  try
    for I := 1 to Size do List.Add(I * 1.5);
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Currency', Size);
    Stop := TStopwatch.StartNew;
    for Val in List do ;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);
  finally
    List := nil;
  end;
end;

class procedure TDextBench.RunPointer(Bench: TBenchmark; Size: Integer);
var
  List: IList<Pointer>;
  I: Integer;
  P: Pointer;
  Stop: TStopwatch;
begin
  Bench.StartScenario('List', 'Add/Populate', 'Pointer', Size);
  Stop := TStopwatch.StartNew;
  List := TCollections.CreateList<Pointer>;
  try
    for I := 1 to Size do List.Add(Pointer(I));
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);

    Bench.StartScenario('List', 'Iteration', 'Pointer', Size);
    Stop := TStopwatch.StartNew;
    for P in List do ;
    Stop.Stop;
    Bench.AddResult('Dext', Stop.Elapsed.TotalMilliseconds);
  finally
    List := nil;
  end;
end;

end.
