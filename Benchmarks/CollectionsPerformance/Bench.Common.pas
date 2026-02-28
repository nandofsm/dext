unit Bench.Common;

interface

type
  TTestRecordSmall = record
    ID: Integer;
    Value: Currency;
    Name: string[20];
  end;

  TTestRecordLarge = record
    ID: Integer;
    Data: array[0..255] of Byte;
    Description: string;
  end;

  TTestObject = class
    ID: Integer;
    Name: string;
  end;

implementation

end.
