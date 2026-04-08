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
{  Created: 2025-12-08                                                      }
{                                                                           }
{***************************************************************************}
unit Dext.Hosting.BackgroundService;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.Collections,
  Dext.DI.Interfaces,
  Dext.Threading.CancellationToken; // ✅ Added

type
  /// <summary>Defines the contract for services managed by the application host.</summary>
  IHostedService = interface
    ['{8D4F5E6A-1B2C-4D3E-9F0A-7B8C9D0E1F2A}']
    /// <summary>Starts service execution.</summary>
    procedure Start;
    /// <summary>Requests graceful service shutdown.</summary>
    procedure Stop;
  end;

  // ✅ Interface for THostedServiceManager to enable ARC management
  /// <summary>Orchestrator responsible for managing startup and shutdown of all hosted services.</summary>
  IHostedServiceManager = interface
    ['{F1E2D3C4-B5A6-7890-1234-567890ABCDEF}']
    /// <summary>Registers a new service to be managed.</summary>
    procedure RegisterService(Service: IHostedService);
    /// <summary>Starts all registered services asynchronously.</summary>
    procedure StartAsync(Token: ICancellationToken = nil);
    /// <summary>Stops all registered services, respecting graceful shutdown.</summary>
    procedure StopAsync(Token: ICancellationToken = nil);
  end;

  TBackgroundService = class;

  TBackgroundServiceThread = class(TThread)
  private
    FService: TBackgroundService;
    FToken: ICancellationToken;
  protected
    procedure Execute; override;
  public
    constructor Create(Service: TBackgroundService; Token: ICancellationToken);
  end;

  /// <summary>
  ///   Base class for implementing long-running services (Workers).
  ///   Automatically manages thread creation and cancellation signal (CancellationToken).
  /// </summary>
  TBackgroundService = class(TInterfacedObject, IHostedService)
  private
    FThread: TBackgroundServiceThread;
    FCancellationTokenSource: TCancellationTokenSource;
  protected
    /// <summary>
    ///   Abstract method where worker logic should be implemented. 
    ///   Must monitor <paramref name="Token"/> to terminate execution loop.
    /// </summary>
    procedure Execute(Token: ICancellationToken); virtual; abstract;
  public
    /// <summary>Starts the background thread and cancellation management.</summary>
    procedure Start; virtual;
    /// <summary>Triggers the cancellation signal and waits for the thread to terminate (Graceful Shutdown).</summary>
    procedure Stop; virtual;
  end;

  /// <summary>
  ///   Manager that starts and stops all registered hosted services.
  /// </summary>
  THostedServiceManager = class(TInterfacedObject, IHostedServiceManager)
  private
    FServices: IList<IHostedService>;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure RegisterService(Service: IHostedService);
    procedure StartAsync(Token: ICancellationToken = nil);
    procedure StopAsync(Token: ICancellationToken = nil);
  end;

  /// <summary>Builder used to register Background Services in the Dependency Injection container.</summary>
  TBackgroundServiceBuilder = record
  private
    FServices: IServiceCollection;
    FHostedServices: IList<TClass>;
  public
    constructor Create(Services: IServiceCollection);
    /// <summary>Registers a class inheriting from TBackgroundService as a hosted service.</summary>
    function AddHostedService<T: class, constructor>: TBackgroundServiceBuilder;
    /// <summary>Consolidates registrations and injects the Service Manager into the DI container.</summary>
    procedure Build;
  end;

implementation

uses
  Dext.Utils;

{ TBackgroundServiceThread }

constructor TBackgroundServiceThread.Create(Service: TBackgroundService; Token: ICancellationToken);
begin
  inherited Create(True); // Create suspended
  FService := Service;
  FToken := Token;
  FreeOnTerminate := False;
end;

procedure TBackgroundServiceThread.Execute;
begin
  try
    FService.Execute(FToken);
  except
    on E: Exception do
      SafeWriteLn(Format('❌ Error in BackgroundService thread: %s', [E.Message]));
  end;
end;

{ TBackgroundService }

procedure TBackgroundService.Start;
begin
  FCancellationTokenSource := TCancellationTokenSource.Create;
  FThread := TBackgroundServiceThread.Create(Self, FCancellationTokenSource.Token);
  FThread.Start;
end;

procedure TBackgroundService.Stop;
begin
  if Assigned(FCancellationTokenSource) then
  begin
    FCancellationTokenSource.Cancel;
  end;

  if Assigned(FThread) then
  begin
    // We don't terminate the thread abruptly, we wait for it to finish gracefully
    // The Execute method should check the token and exit.
    FThread.WaitFor;
    FThread.Free;
    FThread := nil;
  end;
  
  if Assigned(FCancellationTokenSource) then
  begin
    FCancellationTokenSource.Free;
    FCancellationTokenSource := nil;
  end;
end;

{ THostedServiceManager }

constructor THostedServiceManager.Create;
begin
  inherited Create;
  FServices := TCollections.CreateList<IHostedService>;
end;

destructor THostedServiceManager.Destroy;
begin
  // Services are interfaces managed by ARC
  // Just free the list container, not the services themselves
  FServices := nil;
  inherited;
end;

procedure THostedServiceManager.RegisterService(Service: IHostedService);
begin
  FServices.Add(Service);
end;

procedure THostedServiceManager.StartAsync(Token: ICancellationToken);
var
  Service: IHostedService;
begin
  SafeWriteLn('🚀 Starting Hosted Services...');
  for Service in FServices do
  begin
    try
      Service.Start;
      SafeWriteLn(Format('  ✅ Started %s', [(Service as TObject).ClassName]));
    except
      on E: Exception do
        SafeWriteLn(Format('  ❌ Failed to start %s: %s', [(Service as TObject).ClassName, E.Message]));
    end;
  end;
end;

procedure THostedServiceManager.StopAsync(Token: ICancellationToken);
var
  Service: IHostedService;
begin
  SafeWriteLn('🛑 Stopping Hosted Services...');
  for Service in FServices do
  begin
    try
      Service.Stop;
      SafeWriteLn(Format('  ✅ Stopped %s', [(Service as TObject).ClassName]));
    except
      on E: Exception do
        SafeWriteLn(Format('  ❌ Failed to stop %s: %s', [(Service as TObject).ClassName, E.Message]));
    end;
  end;
end;

{ TBackgroundServiceBuilder }

constructor TBackgroundServiceBuilder.Create(Services: IServiceCollection);
begin
  FServices := Services;
  FHostedServices := TCollections.CreateList<TClass>;
end;

function TBackgroundServiceBuilder.AddHostedService<T>: TBackgroundServiceBuilder;
begin
  // Register as singleton
  FServices.AddSingleton(TServiceType.FromClass(T), T);
  
  if not FHostedServices.Contains(T) then
    FHostedServices.Add(T);
    
  Result := Self;
end;

procedure TBackgroundServiceBuilder.Build;
var
  CapturedServices: TArray<TClass>;
  LHostedServices: IList<TClass>;
begin
  LHostedServices := FHostedServices;
  CapturedServices := LHostedServices.ToArray;
  
  // ✅ Register as INTERFACE to enable ARC management
  FServices.AddSingleton(
    TServiceType.FromInterface(IHostedServiceManager),
    THostedServiceManager,
    function(Provider: IServiceProvider): TObject
    var
      Manager: THostedServiceManager;
      ServiceClass: TClass;
      ServiceObj: TObject;
      HostedService: IHostedService;
    begin
      Manager := THostedServiceManager.Create;
      
      for ServiceClass in CapturedServices do
      begin
        ServiceObj := Provider.GetService(TServiceType.FromClass(ServiceClass));
        if Supports(ServiceObj, IHostedService, HostedService) then
          Manager.RegisterService(HostedService);
      end;
      
      Result := Manager;
    end
  );
  
  // Safe to free the list now, the captured array keeps the classes
  LHostedServices := nil;
end;

end.
