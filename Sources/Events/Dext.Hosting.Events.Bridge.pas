{***************************************************************************}
{                                                                           }
{           Dext Framework                                                  }
{                                                                           }
{           Copyright (C) 2025 Cesar Romero & Dext Contributors             }
{                                                                           }
{***************************************************************************}
unit Dext.Hosting.Events.Bridge;

interface

uses
  System.SysUtils,
  Dext.Hosting.BackgroundService,
  Dext.Events.Interfaces;

type
  /// <summary>
  ///   Internal service that bridges Host lifecycle notifications to the Event Bus.
  ///   Inherits from TObject (not TInterfacedObject) because lifetime is managed
  ///   exclusively by the DI container (stored in FSingletons as TObject).
  ///   Using TInterfacedObject would cause premature destruction via ARC when
  ///   temporary interface references are created during DI resolution.
  /// </summary>
  THostingLifecycleEventBridge = class(TObject, IHostedService)
  private
    FEventBus: IEventBus;
  public
    constructor Create(AEventBus: IEventBus);
    destructor Destroy; override;
    procedure Start;
    procedure Stop;

    // IInterface - Manual implementation (DI container manages lifetime)
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

implementation

uses
  Dext.DI.Interfaces,
  Dext.Events,
  Dext.Hosting.Events;

{ THostingLifecycleEventBridge }

constructor THostingLifecycleEventBridge.Create(AEventBus: IEventBus);
begin
  inherited Create;
  FEventBus := AEventBus;
end;

destructor THostingLifecycleEventBridge.Destroy;
begin
  FEventBus := nil;
  inherited;
end;

procedure THostingLifecycleEventBridge.Start;
begin
  if FEventBus <> nil then
  begin
    TEventBusExtensions.Publish<TApplicationStartedEvent>(FEventBus, Default(TApplicationStartedEvent));
  end;
end;

procedure THostingLifecycleEventBridge.Stop;
begin
  if FEventBus <> nil then
  begin
    TEventBusExtensions.Publish<TApplicationStoppingEvent>(FEventBus, Default(TApplicationStoppingEvent));
  end;
end;

function THostingLifecycleEventBridge.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function THostingLifecycleEventBridge._AddRef: Integer;
begin
  Result := -1; // No-op - DI container manages lifetime
end;

function THostingLifecycleEventBridge._Release: Integer;
begin
  Result := -1; // No-op - DI container manages lifetime
end;

end.
