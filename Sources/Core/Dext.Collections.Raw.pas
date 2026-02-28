{***************************************************************************}
{                                                                           }
{           Dext Framework                                                  }
{                                                                           }
{           Copyright (C) 2025 Cesar Romero & Dext Contributors             }
{                                                                           }
{           Licensed under the Apache License, Version 2.0 (the "License"); }
{           you may not use this file except in compliance with the License.}
{           You may obtain a copy of the License at                         }
{                                                                           }
{               http://www.apache.org/licenses/LICENSE-2.0                  }
{                                                                           }
{           Unless required by applicable law or agreed to in writing,      }
{           software distributed under the License is distributed on an     }
{           "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,    }
{           either express or implied. See the License for the specific     }
{           language governing permissions and limitations under the        }
{           License.                                                        }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Author:  Cesar Romero                                                    }
{  Created: 2026-02-23                                                      }
{                                                                           }
{  Non-generic dynamic array (list) that operates on raw memory.            }
{  This is the core backend that all generic list wrappers delegate to.     }
{  Multiple generic specializations with the same element size and          }
{  managed-type category will share this SAME compiled code (Code Folding). }
{                                                                           }
{***************************************************************************}
unit Dext.Collections.Raw;

interface

uses
  System.SysUtils,
  System.TypInfo,
  Dext.Collections.Memory;

type
  /// <summary>
  ///   Callback for comparing two raw elements.
  ///   A and B point to the raw element data.
  ///   Returns: negative if A < B, 0 if equal, positive if A > B.
  /// </summary>
  TRawCompareFunc = reference to function(A, B: Pointer): Integer;

  /// <summary>
  ///   Callback for comparing two raw elements for equality.
  ///   Returns True if A and B represent the same value.
  /// </summary>
  TRawEqualityFunc = reference to function(A, B: Pointer): Boolean;

  /// <summary>
  ///   Notification type for list changes (used by TTrackingList etc.)
  /// </summary>
  TRawCollectionNotification = (rcnAdded, rcnRemoved, rcnExtracted);

  /// <summary>
  ///   Callback for item notifications.
  ///   Item points to the raw element data.
  /// </summary>
  TRawNotifyEvent = procedure(Item: Pointer;
    Action: TRawCollectionNotification) of object;

  /// <summary>
  ///   Non-generic dynamic array that manages a contiguous block of memory.
  ///   Supports managed types (string, interface, dynamic array) safely.
  ///
  ///   This class is the backbone of Dext.Collections — all generic wrappers
  ///   (TList<T>, IList<T>) delegate their storage operations here.
  ///
  ///   KEY DESIGN: One compiled copy of TRawList serves ALL generic
  ///   instantiations. A TList<Integer> and a TList<Cardinal> both use the
  ///   same TRawList code with ElementSize=4 and TypeInfo=nil.
  /// </summary>
  TRawList = class
  private
    // Field alignment: keep pointers/native-sized first, then integers, then booleans
    // to minimize padding and maximize CPU cache line density.
    FData: PByte;
    FTypeInfo: PTypeInfo;
    FOnNotify: TRawNotifyEvent;
    FCount: Integer;
    FCapacity: Integer;
    FElementSize: Integer;
    FIsManaged: Boolean;
  protected // protected just to make compiler happy for now
    procedure SetCapacity(ACapacity: Integer);
    procedure Grow;
    procedure GrowTo(AMinCapacity: Integer);
    procedure DoNotify(Item: Pointer; Action: TRawCollectionNotification);
  public
    constructor Create(AElementSize: Integer; ATypeInfo: PTypeInfo);
    destructor Destroy; override;

    /// <returns>Index of the element</returns>
    function GetItemPtr(Index: Integer): Pointer; inline;

    /// <summary>
    ///   Appends Value to the end of the list. Returns the new index.
    /// </summary>
    function AddRaw(Value: Pointer): Integer; inline;

    /// <summary>
    ///   Fast path for TList<T> to increment count after manual Move.
    /// </summary>
    procedure FastIncrementCount; inline;

    /// <summary>
    ///   Inserts Value at the specified Index, shifting subsequent elements.
    /// </summary>
    procedure InsertRaw(Index: Integer; Value: Pointer);

    /// <summary>
    ///   Removes the element at Index, shifting subsequent elements down.
    ///   Fires rcnRemoved notification.
    /// </summary>
    procedure DeleteRaw(Index: Integer);

    /// <summary>
    ///   Removes the first element that equals Value (using EqualityFunc).
    ///   Returns the index of the removed element, or -1 if not found.
    ///   Fires rcnRemoved notification.
    /// </summary>
    function RemoveRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Integer;

    /// <summary>
    ///   Extracts the first element that equals Value (using EqualityFunc).
    ///   Same as RemoveRaw but fires rcnExtracted instead of rcnRemoved.
    ///   The caller is responsible for freeing extracted objects.
    /// </summary>
    function ExtractRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Integer;

    /// <summary>
    ///   Clears all elements, finalizing managed types.
    ///   Does NOT free memory (capacity remains).
    /// </summary>
    procedure Clear; inline;

    /// <summary>
    ///   Searches for Value using EqualityFunc.
    ///   Returns the index of the first match, or -1 if not found.
    /// </summary>
    function IndexOfRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Integer;

    /// <summary>
    ///   Returns True if Value is found in the list.
    /// </summary>
    function ContainsRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Boolean;

    /// <summary>
    ///   Copies the value at Index into Dest.
    ///   Handles managed type copy semantics correctly.
    /// </summary>
    procedure GetRawItem(Index: Integer; Dest: Pointer); inline;

    /// <summary>
    ///   Sets the value at Index from Value.
    ///   Handles managed type finalize-old + copy-new correctly.
    /// </summary>
    procedure SetRawItem(Index: Integer; Value: Pointer); inline;

    /// <summary>
    ///   Copies all elements into a preallocated destination buffer.
    ///   Dest must have at least Count * ElementSize bytes.
    ///   Handles managed type copy correctly.
    /// </summary>
    procedure GetRawData(Dest: Pointer);

    /// <summary>
    ///   Exchanges two elements by index.
    /// </summary>
    procedure ExchangeRaw(Index1, Index2: Integer);

    /// <summary>
    ///   Sorts the list using CompareFunc.
    ///   Uses an optimized QuickSort with temp buffer for swaps.
    /// </summary>
    procedure SortRaw(CompareFunc: TRawCompareFunc);

    /// <summary>
    ///   Direct pointer to the backing memory array.
    ///   Valid only while no reallocations occur.
    /// </summary>
    property Data: PByte read FData;
    property Count: Integer read FCount;
    property Capacity: Integer read FCapacity write SetCapacity;
    property ElementSize: Integer read FElementSize;
    property TypeInfo: PTypeInfo read FTypeInfo;
    property IsManaged: Boolean read FIsManaged;
    property OnNotify: TRawNotifyEvent read FOnNotify write FOnNotify;
  end;

implementation

const
  INITIAL_CAPACITY = 4;

procedure TRawList.FastIncrementCount;
begin
  Inc(FCount);
end;

{ TRawList }

constructor TRawList.Create(AElementSize: Integer; ATypeInfo: PTypeInfo);
begin
  inherited Create;
  Assert(AElementSize > 0, 'TRawList: ElementSize must be > 0');
  FElementSize := AElementSize;
  FTypeInfo := ATypeInfo;
  FIsManaged := Dext.Collections.Memory.IsManagedType(ATypeInfo);
  FData := nil;
  FCount := 0;
  FCapacity := 0;
  FOnNotify := nil;
end;

destructor TRawList.Destroy;
begin
  Clear;
  if FData <> nil then
  begin
    FreeMem(FData);
    FData := nil;
  end;
  FCapacity := 0;
  inherited;
end;

function TRawList.GetItemPtr(Index: Integer): Pointer;
begin
  {$IFDEF DEBUG}
  if (Index < 0) or (Index >= FCount) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'TRawList: Index %d out of range [0..%d]', [Index, FCount - 1]);
  {$ENDIF}
  Result := FData + (Index * FElementSize);
end;

procedure TRawList.SetCapacity(ACapacity: Integer);
var
  NewData: PByte;
begin
  if ACapacity = FCapacity then
    Exit;

  if ACapacity < FCount then
    raise EArgumentOutOfRangeException.Create(
      'TRawList: Cannot set capacity below current count');

  if ACapacity = 0 then
  begin
    if FData <> nil then
    begin
      FreeMem(FData);
      FData := nil;
    end;
    FCapacity := 0;
    Exit;
  end;

  // Allocate new block
  GetMem(NewData, ACapacity * FElementSize);

  // Move existing data
  if (FData <> nil) and (FCount > 0) then
  begin
    // Move raw bytes — we are moving ownership, not copying
    System.Move(FData^, NewData^, FCount * FElementSize);
    // Zero old data so FreeMem won't trigger double-free on managed types
    if FIsManaged then
      FillChar(FData^, FCount * FElementSize, 0);
  end;

  // Zero the new tail (slot FCount..ACapacity-1) — important for managed types
  if ACapacity > FCount then
    FillChar((NewData + FCount * FElementSize)^,
      (ACapacity - FCount) * FElementSize, 0);

  if FData <> nil then
    FreeMem(FData);

  FData := NewData;
  FCapacity := ACapacity;
end;

procedure TRawList.Grow;
begin
  if FCapacity = 0 then
    SetCapacity(INITIAL_CAPACITY)
  else if FCapacity < 64 then
    SetCapacity(FCapacity * 2)
  else
    SetCapacity(FCapacity + (FCapacity shr 2)); // 25% growth for large lists
end;

procedure TRawList.GrowTo(AMinCapacity: Integer);
var
  NewCap: Integer;
begin
  NewCap := FCapacity;
  if NewCap = 0 then
    NewCap := INITIAL_CAPACITY;

  while NewCap < AMinCapacity do
  begin
    if NewCap < 64 then
      NewCap := NewCap * 2
    else
      NewCap := NewCap + (NewCap div 4);
  end;

  SetCapacity(NewCap);
end;

procedure TRawList.DoNotify(Item: Pointer; Action: TRawCollectionNotification);
begin
  if Assigned(FOnNotify) then
    FOnNotify(Item, Action);
end;

function TRawList.AddRaw(Value: Pointer): Integer;
var
  Dest: Pointer;
begin
  if FCount >= FCapacity then
    Grow;

  Result := FCount;
  Dest := FData + (Result * FElementSize);

  if FIsManaged then
    System.CopyArray(Dest, Value, FTypeInfo, 1)
  else
  begin
    case FElementSize of
      1: PByte(Dest)^ := PByte(Value)^;
      2: PWord(Dest)^ := PWord(Value)^;
      4: PCardinal(Dest)^ := PCardinal(Value)^;
      8: PUInt64(Dest)^ := PUInt64(Value)^;
    else
      System.Move(Value^, Dest^, FElementSize);
    end;
  end;

  Inc(FCount);
  if Assigned(FOnNotify) then
    FOnNotify(Dest, rcnAdded);
end;

procedure TRawList.InsertRaw(Index: Integer; Value: Pointer);
var
  Src, Dest: Pointer;
  MoveCount: Integer;
begin
  if (Index < 0) or (Index > FCount) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'TRawList.InsertRaw: Index %d out of range [0..%d]', [Index, FCount]);

  if FCount >= FCapacity then
    Grow;

  // Shift elements after Index to the right
  MoveCount := FCount - Index;
  if MoveCount > 0 then
  begin
    Src := FData + (Index * FElementSize);
    Dest := FData + ((Index + 1) * FElementSize);
    // Move raw bytes — we're shifting, not copying references
    System.Move(Src^, Dest^, MoveCount * FElementSize);
    // Zero the slot so CopyElement doesn't try to finalize garbage
    FillChar(Src^, FElementSize, 0);
  end;

  // Copy the new element into the slot
  RawCopyElement(FData + (Index * FElementSize), Value, FElementSize, FTypeInfo);
  Inc(FCount);

  DoNotify(FData + (Index * FElementSize), rcnAdded);
end;

procedure TRawList.DeleteRaw(Index: Integer);
var
  ItemPtr, NextPtr: Pointer;
  MoveCount: Integer;
  TempBuf: array[0..255] of Byte;
  TempPtr: Pointer;
begin
  if (Index < 0) or (Index >= FCount) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'TRawList.DeleteRaw: Index %d out of range [0..%d]', [Index, FCount - 1]);

  ItemPtr := FData + (Index * FElementSize);

  // Save a copy for notification before we destroy it
  if Assigned(FOnNotify) then
  begin
    if FElementSize <= SizeOf(TempBuf) then
      TempPtr := @TempBuf[0]
    else
    begin
      GetMem(TempPtr, FElementSize);
    end;
    System.Move(ItemPtr^, TempPtr^, FElementSize);
  end
  else
    TempPtr := nil;

  // Finalize the element being removed
  RawFinalizeElement(ItemPtr, FElementSize, FTypeInfo);

  // Shift elements after Index to the left
  MoveCount := FCount - Index - 1;
  if MoveCount > 0 then
  begin
    NextPtr := FData + ((Index + 1) * FElementSize);
    System.Move(NextPtr^, ItemPtr^, MoveCount * FElementSize);
    // Zero the last slot (now a duplicate that would cause double-free)
    FillChar((FData + ((FCount - 1) * FElementSize))^, FElementSize, 0);
  end
  else
    FillChar(ItemPtr^, FElementSize, 0);

  Dec(FCount);

  // Fire notification with temp copy
  if TempPtr <> nil then
  begin
    DoNotify(TempPtr, rcnRemoved);
    if FElementSize > SizeOf(TempBuf) then
      FreeMem(TempPtr);
  end;
end;

function TRawList.RemoveRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Integer;
begin
  Result := IndexOfRaw(Value, EqualityFunc);
  if Result >= 0 then
    DeleteRaw(Result);
end;

function TRawList.ExtractRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Integer;
var
  ItemPtr, NextPtr: Pointer;
  MoveCount: Integer;
begin
  Result := IndexOfRaw(Value, EqualityFunc);
  if Result < 0 then
    Exit;

  ItemPtr := FData + (Result * FElementSize);

  // Fire notification BEFORE removing (so handler can access the item)
  DoNotify(ItemPtr, rcnExtracted);

  // For Extract: we do NOT finalize — caller takes ownership
  // But we still need to shift
  MoveCount := FCount - Result - 1;
  if MoveCount > 0 then
  begin
    NextPtr := FData + ((Result + 1) * FElementSize);
    System.Move(NextPtr^, ItemPtr^, MoveCount * FElementSize);
    FillChar((FData + ((FCount - 1) * FElementSize))^, FElementSize, 0);
  end
  else
    FillChar(ItemPtr^, FElementSize, 0);

  Dec(FCount);
end;

procedure TRawList.Clear;
var
  I: Integer;
begin
  if FCount = 0 then
    Exit;

  // Fire notifications in reverse order
  if Assigned(FOnNotify) then
  begin
    for I := FCount - 1 downto 0 do
      DoNotify(FData + (I * FElementSize), rcnRemoved);
  end;

  // Finalize all managed elements
  if FIsManaged then
    RawFinalize(FData, FCount, FElementSize, FTypeInfo)
  else
  begin
    // For unmanaged types, just reset count. No need to zero memory if not managed,
    // as it will be overwritten by future Adds.
    FCount := 0;
    Exit;
  end;

  // Zero all memory (only reached if managed)
  FillChar(FData^, FCount * FElementSize, 0);
  FCount := 0;
end;

function TRawList.IndexOfRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Integer;
var
  I: Integer;
  ItemPtr: Pointer;
begin
  for I := 0 to FCount - 1 do
  begin
    ItemPtr := FData + (I * FElementSize);
    if EqualityFunc(ItemPtr, Value) then
      Exit(I);
  end;
  Result := -1;
end;

function TRawList.ContainsRaw(Value: Pointer; EqualityFunc: TRawEqualityFunc): Boolean;
begin
  Result := IndexOfRaw(Value, EqualityFunc) >= 0;
end;

procedure TRawList.GetRawItem(Index: Integer; Dest: Pointer);
var
  Src: Pointer;
begin
  {$IFDEF DEBUG}
  if (Index < 0) or (Index >= FCount) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'TRawList.GetRawItem: Index %d out of range [0..%d]', [Index, FCount - 1]);
  {$ENDIF}
  Src := FData + (Index * FElementSize);
  RawCopyElement(Dest, Src, FElementSize, FTypeInfo);
end;

procedure TRawList.SetRawItem(Index: Integer; Value: Pointer);
var
  Dest: Pointer;
begin
  {$IFDEF DEBUG}
  if (Index < 0) or (Index >= FCount) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'TRawList.SetRawItem: Index %d out of range [0..%d]', [Index, FCount - 1]);
  {$ENDIF}
  Dest := FData + (Index * FElementSize);

  // Notify removal of old value
  DoNotify(Dest, rcnRemoved);

  // Finalize old, copy new
  if FIsManaged then
    RawFinalizeElement(Dest, FElementSize, FTypeInfo);
  RawCopyElement(Dest, Value, FElementSize, FTypeInfo);

  // Notify addition of new value
  DoNotify(Dest, rcnAdded);
end;

procedure TRawList.GetRawData(Dest: Pointer);
var
  I: Integer;
  Src, D: PByte;
begin
  if FCount = 0 then
    Exit;

  if FIsManaged then
  begin
    // Must use element-by-element copy for managed types
    Src := FData;
    D := PByte(Dest);
    for I := 0 to FCount - 1 do
    begin
      RawCopyElement(D, Src, FElementSize, FTypeInfo);
      Inc(Src, FElementSize);
      Inc(D, FElementSize);
    end;
  end
  else
  begin
    // Simple memcpy for unmanaged types
    System.Move(FData^, Dest^, FCount * FElementSize);
  end;
end;

procedure TRawList.ExchangeRaw(Index1, Index2: Integer);
var
  P1, P2: Pointer;
  TempBuf: array[0..255] of Byte;
  TempPtr: Pointer;
  NeedFree: Boolean;
  T4: Cardinal;
  T8: UInt64;
begin
  if Index1 = Index2 then
    Exit;

  {$IFDEF DEBUG}
  if (Index1 < 0) or (Index1 >= FCount) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'TRawList.ExchangeRaw: Index1 %d out of range', [Index1]);
  if (Index2 < 0) or (Index2 >= FCount) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'TRawList.ExchangeRaw: Index2 %d out of range', [Index2]);
  {$ENDIF}

  P1 := FData + (Index1 * FElementSize);
  P2 := FData + (Index2 * FElementSize);

  // Micro-optimized inline swap for primitive sizes
  case FElementSize of
    4: begin
         T4 := PCardinal(P1)^;
         PCardinal(P1)^ := PCardinal(P2)^;
         PCardinal(P2)^ := T4;
         Exit;
       end;
    8: begin
         T8 := PUInt64(P1)^;
         PUInt64(P1)^ := PUInt64(P2)^;
         PUInt64(P2)^ := T8;
         Exit;
       end;
  end;

  // Use stack buffer for medium elements, heap for very large
  NeedFree := FElementSize > SizeOf(TempBuf);
  if NeedFree then
    GetMem(TempPtr, FElementSize)
  else
    TempPtr := @TempBuf[0];

  try
    // Raw byte swap — safe because we're just swapping, not duplicating refs
    System.Move(P1^, TempPtr^, FElementSize);
    System.Move(P2^, P1^, FElementSize);
    System.Move(TempPtr^, P2^, FElementSize);
  finally
    if NeedFree then
      FreeMem(TempPtr);
  end;
end;

procedure TRawList.SortRaw(CompareFunc: TRawCompareFunc);
var
  LData: PByte;
  LElementSize: Integer;

  procedure InsertionSort(L, R: Integer);
  var
    I, J: Integer;
    TempBuf: array[0..255] of Byte;
    TempPtr: Pointer;
    NeedFree: Boolean;
    CurrentItem, PrevItem: PByte;
  begin
    NeedFree := LElementSize > SizeOf(TempBuf);
    if NeedFree then GetMem(TempPtr, LElementSize) else TempPtr := @TempBuf[0];
    try
      for I := L + 1 to R do
      begin
        CurrentItem := LData + (I * LElementSize);
        System.Move(CurrentItem^, TempPtr^, LElementSize);
        J := I - 1;
        while (J >= L) do
        begin
          PrevItem := LData + (J * LElementSize);
          if CompareFunc(PrevItem, TempPtr) <= 0 then Break;
          System.Move(PrevItem^, (PrevItem + LElementSize)^, LElementSize);
          Dec(J);
        end;
        System.Move(TempPtr^, (LData + ((J + 1) * LElementSize))^, LElementSize);
      end;
    finally
      if NeedFree then FreeMem(TempPtr);
    end;
  end;

  procedure QuickSort(L, R: Integer);
  var
    I, J, Mid: Integer;
    PivotBuf: array[0..255] of Byte;
    PivotPtr: Pointer;
    NeedFreePivot: Boolean;
    P1, P2: PByte;
    T4: Cardinal;
    T8: UInt64;
  begin
    while R - L > 16 do
    begin
      Mid := (L + R) shr 1;
      // Median-of-three 
      if CompareFunc(LData + (L * LElementSize), LData + (Mid * LElementSize)) > 0 then ExchangeRaw(L, Mid);
      if CompareFunc(LData + (L * LElementSize), LData + (R * LElementSize)) > 0 then ExchangeRaw(L, R);
      if CompareFunc(LData + (Mid * LElementSize), LData + (R * LElementSize)) > 0 then ExchangeRaw(Mid, R);

      NeedFreePivot := LElementSize > SizeOf(PivotBuf);
      if NeedFreePivot then GetMem(PivotPtr, LElementSize) else PivotPtr := @PivotBuf[0];
      try
        System.Move((LData + (Mid * LElementSize))^, PivotPtr^, LElementSize);
        I := L;
        J := R;
        repeat
          while CompareFunc(LData + (I * LElementSize), PivotPtr) < 0 do Inc(I);
          while CompareFunc(LData + (J * LElementSize), PivotPtr) > 0 do Dec(J);
          if I <= J then
          begin
            if I <> J then
            begin
              // Micro-swap inline for common sizes
              P1 := LData + (I * LElementSize);
              P2 := LData + (J * LElementSize);
              case LElementSize of
                4: begin T4 := PCardinal(P1)^; PCardinal(P1)^ := PCardinal(P2)^; PCardinal(P2)^ := T4; end;
                8: begin T8 := PUInt64(P1)^; PUInt64(P1)^ := PUInt64(P2)^; PUInt64(P2)^ := T8; end;
              else
                ExchangeRaw(I, J);
              end;
            end;
            Inc(I);
            Dec(J);
          end;
        until I > J;
      finally
        if NeedFreePivot then FreeMem(PivotPtr);
      end;

      if J - L < R - I then
      begin
        if L < J then QuickSort(L, J);
        L := I;
      end
      else
      begin
        if I < R then QuickSort(I, R);
        R := J;
      end;
    end;
    if L < R then InsertionSort(L, R);
  end;

begin
  if FCount < 2 then Exit;
  LData := FData;
  LElementSize := FElementSize;
  QuickSort(0, FCount - 1);
end;

end.
