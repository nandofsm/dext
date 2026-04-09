unit Dext.Core.Writers;

interface

uses
  System.Classes;

type
  IDextWriter = interface
    ['{99A70BF2-FF09-4501-B91D-3D02C9A9B835}']
    procedure SafeWriteLn(const Text: string);
    procedure SafeWrite(const Text: string);
  end;

  /// <Summary>
  ///  Use to ignore all SafeWrites
  /// </Summary>
  TNullWriter = class(TInterfacedObject, IDextWriter)
  private
    procedure SafeWriteLn(const Text: string);
    procedure SafeWrite(const Text: string);
  end;

  /// <Summary>
  ///  Use to route SafeWrites to the Console. Assumes the console is available
  ///  and will ignore any I/O errors that are generated.
  /// </Summary>
  TConsoleWriter = class(TInterfacedObject,IDextWriter)
  private
    procedure SafeWriteLn(const Text:string);
    procedure SafeWrite(const Text:string);
  end;

  {$IFDEF MSWINDOWS}
  /// <Summary>
  ///  Use to route SafeWrites to the windows debugger via OutputDebugString
  ///  There will generally be a delay, so partial writes are held in memory
  ///  until the next SafeWriteln.
  /// </Summary>
  TWindowsDebugWriter = class(TInterfacedObject, IDextWriter)
  private
    FPartial : string;
    procedure SafeWriteLn(const Text: string);
    procedure SafeWrite(const Text: string);
  public
    constructor Create;
  end;
  {$ENDIF}

  /// <Summary>
  ///  Use to route all SafeWrites to a Strings/TStringList.  A common use of
  ///  this would be to display the messages in a vcl TMemo control by calling
  ///  TStringsWriter.Create(Memo1.Lines); Just be sure to call
  ///  InitializeDextWriter(nil) or InitializeDextWriter(TStringsWriter.Create(Nil))
  ///  when destroying the form to avoid an Access Violation if SafeWrite is called
  ///  after the destruction of the FStrings
  /// </Summary>
  TStringsWriter = class(TInterfacedObject, IDextWriter)
  private
    FStrings : TStrings;
    FPartial : string;
    procedure _UpdateStrings(const Text: string; Newline: Boolean);
    procedure SafeWriteLn(const Text: string);
    procedure SafeWrite(const Text: string);
  public
    constructor Create(Strings:TStrings);
  end;

implementation

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ENDIF}
  System.SyncObjs;

{ TNullWriter }

procedure TNullWriter.SafeWrite(const Text: string);
begin
  // do nothing but eat the message
end;

procedure TNullWriter.SafeWriteLn(const Text: string);
begin
  // do nothing but eat the message
end;

{ TConsoleWriter }

procedure TConsoleWriter.SafeWrite(const Text: string);
begin
  try
    Write(Text);
  except
    // Silently ignore I/O errors
  end;
end;

procedure TConsoleWriter.SafeWriteLn(const Text: string);
begin
  try
    WriteLn(Text);
  except
    // Silently ignore I/O errors
  end;
end;

{ TWindowsDebugWriter }

{$IFDEF MSWINDOWS}
constructor TWindowsDebugWriter.Create;
begin
  Inherited create;
  FPartial := '';
end;

procedure TWindowsDebugWriter.SafeWrite(const Text: string);
begin
  TMonitor.enter(Self);
  try
    FPartial := FPartial + Text;
  finally
    TMonitor.Exit(Self);
  end;
end;

procedure TWindowsDebugWriter.SafeWriteLn(const Text: string);
begin
  TMonitor.Enter(Self);
  try
    OutputDebugString(PWideChar(FPartial + Text));
    FPartial := '';
  finally
    TMonitor.Exit(Self);
  end;
end;
{$ENDIF}

{ TStringsWriter }

constructor TStringsWriter.Create(Strings: TStrings);
begin
  Inherited Create;
  FStrings := Strings;
  FStrings.Options := FStrings.Options - [ soTrailingLineBreak ];
  FPartial := '';
end;

procedure TStringsWriter.SafeWrite(const Text: string);
begin
  if Assigned(FStrings) then
    _UpdateStrings(Text,False);
end;

procedure TStringsWriter.SafeWriteLn(const Text: string);
begin
  if Assigned(FStrings) then
    _UpdateStrings(Text,True);
  FPartial := '';
end;

procedure TStringsWriter._UpdateStrings(const Text: string; Newline: Boolean);
begin
  TMonitor.Enter(FStrings);
  try
    FStrings.BeginUpdate;
    FPartial := FPartial + Text;
    if FStrings.Count = 0 then
      FStrings.Text := FPartial
    else
      FStrings.Strings[FStrings.Count -1] := FPartial;
    if NewLine then
      FStrings.add('');
  finally
    FStrings.EndUpdate;
    TMonitor.Exit(FStrings);
  end;
end;

end.
