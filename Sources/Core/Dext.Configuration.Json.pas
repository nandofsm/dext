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
unit Dext.Configuration.Json;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Dext.Configuration.Interfaces,
  Dext.Configuration.Core,
  Dext.Json,
  Dext.Json.Types;

type
  TJsonConfigurationProvider = class(TConfigurationProvider, IConfigurationChangeTracker)
  private
    FPath: string;
    FOptional: Boolean;
    FReloadOnChange: Boolean;
    FLastWriteUtc: TDateTime;
    FResolvedPath: string;
    function ResolveFilePath: string;
    function HasChanged: Boolean;
    
    procedure ProcessNode(const Prefix: string; Node: IDextJsonNode);
    procedure ProcessObject(const Prefix: string; Obj: IDextJsonObject);
    procedure ProcessArray(const Prefix: string; Arr: IDextJsonArray);
  public
    constructor Create(const Path: string; Optional: Boolean; ReloadOnChange: Boolean = False);
    procedure Load; override;
  end;

  TJsonConfigurationSource = class(TInterfacedObject, IConfigurationSource)
  private
    FPath: string;
    FOptional: Boolean;
    FReloadOnChange: Boolean;
  public
    constructor Create(const Path: string; Optional: Boolean = False;
      ReloadOnChange: Boolean = False);
    function Build(Builder: IConfigurationBuilder): IConfigurationProvider;
  end;

  /// <summary>
  ///   Fluent builder for JSON configuration.
  /// </summary>
  TJsonConfigurationBuilder = record
  public
    class function Create: TDextConfiguration; static;
  end;

  /// <summary>
  ///   Extensions for TDextConfiguration to support JSON.
  /// </summary>
  TDextConfigurationJsonExtensions = record helper for TDextConfiguration
  public
    function AddJsonFile(const Path: string; Optional: Boolean = False;
      ReloadOnChange: Boolean = False): TDextConfiguration;
  end;

implementation

{ TJsonConfigurationSource }

constructor TJsonConfigurationSource.Create(const Path: string; Optional: Boolean;
  ReloadOnChange: Boolean);
begin
  inherited Create;
  FPath := Path;
  FOptional := Optional;
  FReloadOnChange := ReloadOnChange;
end;

function TJsonConfigurationSource.Build(Builder: IConfigurationBuilder): IConfigurationProvider;
begin
  Result := TJsonConfigurationProvider.Create(FPath, FOptional, FReloadOnChange);
end;

{ TJsonConfigurationProvider }

constructor TJsonConfigurationProvider.Create(const Path: string; Optional: Boolean;
  ReloadOnChange: Boolean);
begin
  inherited Create;
  FPath := Path;
  FOptional := Optional;
  FReloadOnChange := ReloadOnChange;
  FLastWriteUtc := 0;
  FResolvedPath := '';
end;

procedure TJsonConfigurationProvider.Load;
var
  JsonContent: string;
  RootNode: IDextJsonNode;
  ResolvedPath: string;
begin
  ResolvedPath := ResolveFilePath;
  FResolvedPath := ResolvedPath;

  if ResolvedPath = '' then
  begin
    if FOptional then
      Exit;
    raise EFileNotFoundException.CreateFmt('Configuration file not found: %s', [FPath]);
  end;

  try
    JsonContent := TFile.ReadAllText(ResolvedPath, TEncoding.UTF8);
    try
      FLastWriteUtc := TFile.GetLastWriteTimeUtc(ResolvedPath);
    except
      FLastWriteUtc := 0;
    end;
    if JsonContent.Trim = '' then
      Exit;

    RootNode := TDextJson.Provider.Parse(JsonContent);

    ClearData;
    ProcessNode('', RootNode);
  except
    on E: Exception do
      raise EConfigurationException.CreateFmt('Error loading JSON configuration from %s: %s', [FPath, E.Message]);
  end;
end;

function TJsonConfigurationProvider.HasChanged: Boolean;
var
  CurrentWrite: TDateTime;
  Path: string;
begin
  Result := False;
  if not FReloadOnChange then
    Exit;

  Path := FResolvedPath;
  if Path = '' then
    Path := ResolveFilePath;
  if (Path = '') or not FileExists(Path) then
    Exit;

  try
    CurrentWrite := TFile.GetLastWriteTimeUtc(Path);
    Result := (FLastWriteUtc > 0) and (CurrentWrite > FLastWriteUtc);
  except
    Result := False;
  end;
end;

function TJsonConfigurationProvider.ResolveFilePath: string;
begin
  if FileExists(FPath) then
    Exit(FPath);

  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), FPath);
  if FileExists(Result) then
    Exit;

  Result := '';
end;

procedure TJsonConfigurationProvider.ProcessNode(const Prefix: string; Node: IDextJsonNode);
begin
  case Node.GetNodeType of
    jntObject:
      ProcessObject(Prefix, Node as IDextJsonObject);
      
    jntArray:
      ProcessArray(Prefix, Node as IDextJsonArray);
      
    jntString, jntNumber, jntBoolean:
      begin
        // Leaf node
        if Prefix <> '' then
          Set_(Prefix, Node.AsString);
      end;
      
    jntNull:
      begin
        if Prefix <> '' then
          Set_(Prefix, ''); // Treat null as empty string? Or skip? .NET treats as empty usually.
      end;
  end;
end;

procedure TJsonConfigurationProvider.ProcessObject(const Prefix: string; Obj: IDextJsonObject);
var
  I: Integer;
  Key: string;
  ChildPrefix: string;
  ChildNode: IDextJsonNode;
begin
  for I := 0 to Obj.GetCount - 1 do
  begin
    Key := Obj.GetName(I);
    ChildNode := Obj.GetNode(Key);
    
    if Prefix = '' then
      ChildPrefix := Key
    else
      ChildPrefix := Prefix + TConfigurationPath.KeyDelimiter + Key;
      
    ProcessNode(ChildPrefix, ChildNode);
  end;
end;

procedure TJsonConfigurationProvider.ProcessArray(const Prefix: string; Arr: IDextJsonArray);
var
  I: Integer;
  ChildPrefix: string;
  ChildNode: IDextJsonNode;
begin
  for I := 0 to Arr.GetCount - 1 do
  begin
    ChildNode := Arr.GetNode(I);
    
    if Prefix = '' then
      ChildPrefix := IntToStr(I) // Should not happen for root array usually
    else
      ChildPrefix := Prefix + TConfigurationPath.KeyDelimiter + IntToStr(I);
      
    ProcessNode(ChildPrefix, ChildNode);
  end;
end;

{ TJsonConfigurationBuilder }

class function TJsonConfigurationBuilder.Create: TDextConfiguration;
begin
  Result := TDextConfiguration.New;
end;

{ TDextConfigurationJsonExtensions }

function TDextConfigurationJsonExtensions.AddJsonFile(const Path: string; Optional: Boolean;
  ReloadOnChange: Boolean): TDextConfiguration;
begin
  Result := Add(TJsonConfigurationSource.Create(Path, Optional, ReloadOnChange));
end;

end.

