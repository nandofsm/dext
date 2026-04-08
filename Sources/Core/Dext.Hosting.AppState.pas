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
{  Created: 2025-12-21                                                      }
{                                                                           }
{***************************************************************************}
unit Dext.Hosting.AppState;

interface

uses
  System.SysUtils,
  System.SyncObjs;

type
  /// <summary>Defines the high-level application lifecycle states.</summary>
  TApplicationState = (
    /// <summary>Application in startup phase and loading DI.</summary>
    asStarting,
    /// <summary>Executing pending database migrations.</summary>
    asMigrating,
    /// <summary>Populating initial data (seeding).</summary>
    asSeeding,
    /// <summary>Ready to process requests.</summary>
    asRunning,
    /// <summary>In process of graceful shutdown.</summary>
    asStopping,
    /// <summary>Application completely stopped.</summary>
    asStopped
  );

  /// <summary>Read-only interface for observing current application state.</summary>
  IAppStateObserver = interface
    ['{8A9B1C2D-3E4F-5A6B-7C8D-9E0F1A2B3C4D}']
    function GetState: TApplicationState;
    /// <summary>Returns True if the application is in the asRunning state.</summary>
    function IsReady: Boolean;
    property State: TApplicationState read GetState;
  end;

  /// <summary>
  ///   Allows changing the application state.
  /// </summary>
  IAppStateControl = interface
    ['{1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D}']
    procedure SetState(AState: TApplicationState);
  end;

  /// <summary>
  ///   Singleton service that manages application state in a thread-safe way.
  /// </summary>
  TApplicationStateManager = class(TInterfacedObject, IAppStateObserver, IAppStateControl)
  private
    FState: TApplicationState;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    function GetState: TApplicationState;
    procedure SetState(AState: TApplicationState);
    function IsReady: Boolean;
  end;

implementation

{ TApplicationStateManager }

constructor TApplicationStateManager.Create;
begin
  inherited;
  FLock := TCriticalSection.Create;
  FState := asStarting; // Default state
end;

destructor TApplicationStateManager.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TApplicationStateManager.GetState: TApplicationState;
begin
  FLock.Enter;
  try
    Result := FState;
  finally
    FLock.Leave;
  end;
end;

function TApplicationStateManager.IsReady: Boolean;
begin
  Result := GetState = asRunning;
end;

procedure TApplicationStateManager.SetState(AState: TApplicationState);
begin
  FLock.Enter;
  try
    FState := AState;
    // We could trigger events here if needed in the future
  finally
    FLock.Leave;
  end;
end;

end.
