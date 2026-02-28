{***************************************************************************}
{                                                                           }
{           Dext Framework                                                  }
{                                                                           }
{           Copyright (c) 2024 Dext Framework                               }
{                                                                           }
{           https://github.com/dext-framework/dext                          }
{                                                                           }
{***************************************************************************}

unit Dext.Collections.HashSet;

interface

uses
  System.SysUtils,
  System.TypInfo,
  Dext.Collections.Base,
  Dext.Collections.Memory,
  Dext.Collections.RawDict,
  Dext.Collections;

type
  /// <summary>High-performance record-based enumerator for THashSet<T></summary>
  THashSetRecordEnumerator<T> = record
  private
    FCore: TRawDictionary;
    FIndex: Integer;
    FCapacity: Integer;
  public
    constructor Create(ACore: TRawDictionary);
    function MoveNext: Boolean; inline;
    function GetCurrent: T; inline;
    property Current: T read GetCurrent;
  end;

  /// <summary>Base class avoiding Delphi explicit interface method mapping bug</summary>
  THashSetBase<T> = class(TInterfacedObject, IEnumerable<T>)
  public
    function GetInterfaceEnumerator: IEnumerator<T>; virtual; abstract;
    function GetEnumerator: IEnumerator<T>;
  end;


  /// <summary>HashSet implementation backed by TRawDictionary</summary>
  THashSet<T> = class(THashSetBase<T>, IHashSet<T>)
  private
    FCore: TRawDictionary;
    function GetCount: Integer; inline;
  public
    function GetInterfaceEnumerator: IEnumerator<T>; override;

    constructor Create(ACapacity: Integer = 0);
    destructor Destroy; override;

    function Add(const Value: T): Boolean; inline;
    function Remove(const Value: T): Boolean; inline;
    procedure Clear; inline;
    function Contains(const Value: T): Boolean; inline;
    function ToArray: TArray<T>;

    function GetEnumerator: THashSetRecordEnumerator<T>; reintroduce; inline;
  end;

  /// <summary>HashSet enumerator (Class-based for interface compatibility)</summary>
  THashSetEnumerator<T> = class(TInterfacedObject, IEnumerator<T>)
  private
    FCore: TRawDictionary;
    FIndex: Integer;
    FCapacity: Integer;
  public
    constructor Create(ACore: TRawDictionary);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ THashSetBase<T> }

function THashSetBase<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := GetInterfaceEnumerator;
end;

{ THashSet<T> }

constructor THashSet<T>.Create(ACapacity: Integer);
var
  HashFunc: TRawHashFunc;
  EqualFunc: TRawEqualFunc;
  TInfo: PTypeInfo;
begin
  inherited Create;
  TInfo := TypeInfo(T);
  
  if TInfo^.Kind = tkUString then
  begin
    HashFunc := StringRawHash;
    EqualFunc := StringRawEqual;
  end
  else
  begin
    HashFunc := DefaultRawHash;
    EqualFunc := DefaultRawEqual;
  end;

  FCore := TRawDictionary.Create(SizeOf(T), 1, TInfo, nil, HashFunc, EqualFunc, ACapacity);
end;

destructor THashSet<T>.Destroy;
begin
  FCore.Free;
  inherited;
end;

function THashSet<T>.Add(const Value: T): Boolean;
var
  Dummy: Byte;
begin
  if FCore.ContainsKeyRaw(@Value) then
    Exit(False);
    
  Dummy := 1;
  FCore.AddRaw(@Value, @Dummy);
  Result := True;
end;

procedure THashSet<T>.Clear;
begin
  FCore.Clear;
end;

function THashSet<T>.Contains(const Value: T): Boolean;
begin
  Result := FCore.ContainsKeyRaw(@Value);
end;

function THashSet<T>.GetCount: Integer;
begin
  Result := FCore.Count;
end;

function THashSet<T>.GetEnumerator: THashSetRecordEnumerator<T>;
begin
  Result := THashSetRecordEnumerator<T>.Create(FCore);
end;

function THashSet<T>.GetInterfaceEnumerator: IEnumerator<T>;
begin
  Result := THashSetEnumerator<T>.Create(FCore);
end;

function THashSet<T>.Remove(const Value: T): Boolean;
begin
  Result := FCore.RemoveRaw(@Value);
end;

function THashSet<T>.ToArray: TArray<T>;
var
  Arr: TArray<T>;
  Idx: Integer;
begin
  SetLength(Arr, FCore.Count);
  Idx := 0;
  FCore.ForEachRaw(
    function(K, V: Pointer): Boolean
    begin
      RawCopyElement(@Arr[Idx], K, SizeOf(T), TypeInfo(T));
      Inc(Idx);
      Result := True;
    end);
  Result := Arr;
end;

{ THashSetRecordEnumerator<T> }

constructor THashSetRecordEnumerator<T>.Create(ACore: TRawDictionary);
begin
  FCore := ACore;
  FCapacity := FCore.Capacity;
  FIndex := -1;
end;

function THashSetRecordEnumerator<T>.GetCurrent: T;
begin
  RawCopyElement(@Result, FCore.GetKeyPtrAtIndex(FIndex), SizeOf(T), TypeInfo(T));
end;

function THashSetRecordEnumerator<T>.MoveNext: Boolean;
begin
  repeat
    Inc(FIndex);
  until (FIndex >= FCapacity) or FCore.IsSlotOccupied(FIndex);
  
  Result := FIndex < FCapacity;
end;

{ THashSetEnumerator<T> }

constructor THashSetEnumerator<T>.Create(ACore: TRawDictionary);
begin
  inherited Create;
  FCore := ACore;
  FCapacity := FCore.Capacity;
  FIndex := -1;
end;

function THashSetEnumerator<T>.GetCurrent: T;
begin
  RawCopyElement(@Result, FCore.GetKeyPtrAtIndex(FIndex), SizeOf(T), TypeInfo(T));
end;

function THashSetEnumerator<T>.MoveNext: Boolean;
begin
  repeat
    Inc(FIndex);
  until (FIndex >= FCapacity) or FCore.IsSlotOccupied(FIndex);
  
  Result := FIndex < FCapacity;
end;

procedure THashSetEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

end.
