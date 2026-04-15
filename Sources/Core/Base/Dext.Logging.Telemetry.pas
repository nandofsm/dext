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
{  Created: 2026-04-14                                                      }
{                                                                           }
{***************************************************************************}
unit Dext.Logging.Telemetry;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  Dext.Collections,
  Dext.Logging;

type
  /// <summary>
  ///   Represents a telemetry event payload.
  /// </summary>
  TTelemetryEvent = record
    Name: string;
    Timestamp: TDateTime;
    Data: TJSONObject;
    Category: string; // 'SQL', 'HTTP', 'AUTH', 'SYS'
    DurationMs: Int64;
    Status: string; // 'Success', 'Error'
    ErrorMessage: string;
  end;

  ITelemetryObserver = interface
    ['{30000000-0000-0000-0000-000000000001}']
    procedure OnEvent(const AEvent: TTelemetryEvent);
  end;

  /// <summary>
  ///   Bridge that routes telemetry events to the logging system.
  /// </summary>
  TLoggingTelemetryObserver = class(TInterfacedObject, ITelemetryObserver)
  private
    FLogger: ILogger;
  public
    constructor Create(const ALogger: ILogger);
    procedure OnEvent(const AEvent: TTelemetryEvent);
  end;

  /// <summary>
  ///   Centralized publisher for framework diagnostic events.
  ///   Inspired by .NET DiagnosticSource.
  /// </summary>
  TDiagnosticSource = class
  private
    class var FInstance: TDiagnosticSource;
  private
    FObservers: IList<ITelemetryObserver>;
    FEnabled: Boolean;
    constructor Create;
  public
    class destructor Destroy;
    class property Instance: TDiagnosticSource read FInstance;

    procedure Subscribe(AObserver: ITelemetryObserver);
    procedure Unsubscribe(AObserver: ITelemetryObserver);
    
    procedure Write(const AName: string; const AData: TJSONObject; const ACategory: string = 'SYS'; const ADuration: Int64 = 0; const AStatus: string = 'Success'; const AError: string = '');
    
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

implementation

{ TDiagnosticSource }

constructor TDiagnosticSource.Create;
begin
  FObservers := TCollections.CreateList<ITelemetryObserver>;
  FEnabled := True;
end;

class destructor TDiagnosticSource.Destroy;
begin
  FInstance.Free;
end;

procedure TDiagnosticSource.Subscribe(AObserver: ITelemetryObserver);
begin
  if not FObservers.Contains(AObserver) then
    FObservers.Add(AObserver);
end;

procedure TDiagnosticSource.Unsubscribe(AObserver: ITelemetryObserver);
begin
  FObservers.Remove(AObserver);
end;

procedure TDiagnosticSource.Write(const AName: string; const AData: TJSONObject;
  const ACategory: string; const ADuration: Int64; const AStatus, AError: string);
var
  Ev: TTelemetryEvent;
  Observer: ITelemetryObserver;
begin
  if not FEnabled or (FObservers.Count = 0) then
  begin
    AData.Free;
    Exit;
  end;

  Ev.Name := AName;
  Ev.Timestamp := Now;
  Ev.Data := AData;
  Ev.Category := ACategory;
  Ev.DurationMs := ADuration;
  Ev.Status := AStatus;
  Ev.ErrorMessage := AError;

  try
    for Observer in FObservers do
      Observer.OnEvent(Ev);
  finally
    Ev.Data.Free;
  end;
end;

{ TLoggingTelemetryObserver }

constructor TLoggingTelemetryObserver.Create(const ALogger: ILogger);
begin
  inherited Create;
  FLogger := ALogger;
end;

procedure TLoggingTelemetryObserver.OnEvent(const AEvent: TTelemetryEvent);
begin
  if AEvent.Category = 'SQL' then
  begin
    var SqlCmd := AEvent.Data.GetValue<string>('sql');
    if SqlCmd = '' then SqlCmd := AEvent.Name;
    
    FLogger.Info( 
      Format('[SQL] Executed in %dms (%s affected): %s', [
        AEvent.DurationMs, 
        AEvent.Status,
        SqlCmd
      ]));
  end
  else if AEvent.Category = 'HTTP' then
  begin
    FLogger.Info(
      Format('[HTTP] %s %s - %s (%dms)', [
        AEvent.Data.GetValue<string>('Method'),
        AEvent.Data.GetValue<string>('Path'),
        AEvent.Data.GetValue<string>('StatusCode'),
        AEvent.DurationMs
      ]));
  end
  else
  begin
    FLogger.Info(Format('[%s] %s', [AEvent.Category, AEvent.Name]));
  end;
end;

initialization
  TDiagnosticSource.FInstance := TDiagnosticSource.Create;

end.
