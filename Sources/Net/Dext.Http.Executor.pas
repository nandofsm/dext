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
{  Author:  Cesar Romero & Antigravity                                      }
{  Created: 2026-01-22                                                      }
{                                                                           }
{  HTTP Request Executor - Executes parsed .http requests using TRestClient }
{                                                                           }
{***************************************************************************}
unit Dext.Http.Executor;

interface

uses
  System.Classes,
  System.SysUtils,
  Dext.Collections,
  Dext.Collections.Dict,
  Dext.Http.Parser,
  Dext.Http.Request,
  Dext.Net.RestClient,
  Dext.Threading.Async;

type
  /// <summary>
  ///   Resultado detalhado de uma execução HTTP, incluindo metadados da requisição.
  ///   Ideal para exibição em interfaces de depuração e logs técnicos.
  /// </summary>
  THttpExecutionResult = record
    /// <summary>Nome atribuído à requisição no arquivo .http.</summary>
    RequestName: string;
    /// <summary>Verbo HTTP utilizado (GET, POST, etc).</summary>
    RequestMethod: string;
    /// <summary>URL completa após a resolução de variáveis.</summary>
    RequestUrl: string;
    /// <summary>Código de status retornado pelo servidor.</summary>
    StatusCode: Integer;
    /// <summary>Texto descritivo do status.</summary>
    StatusText: string;
    /// <summary>Corpo da resposta em formato string.</summary>
    ResponseBody: string;
    /// <summary>Coleção de cabeçalhos retornados pelo servidor.</summary>
    ResponseHeaders: IDictionary<string, string>;
    /// <summary>Tempo total de execução em milissegundos.</summary>
    DurationMs: Int64;
    /// <summary>Indica se a requisição obteve um status de sucesso (2xx ou 3xx).</summary>
    Success: Boolean;
    /// <summary>Mensagem de erro técnica em caso de falha de conexão ou execução.</summary>
    ErrorMessage: string;
  end;

  /// <summary>
  ///   Executor especializado para requisições HTTP baseadas em THttpRequestInfo.
  ///   Atua como ponte entre o parser de arquivos .http e o TRestClient do Dext.
  /// </summary>
  THttpExecutor = class
  private
    class function MethodToEnum(const AMethod: string): TDextHttpMethod; static;
  public
    /// <summary>Executa uma requisição HTTP de forma assíncrona.</summary>
    class function ExecuteAsync(const ARequest: THttpRequestInfo): TAsyncBuilder<IRestResponse>; static;
    
    /// <summary>Executa uma requisição resolvendo variáveis dinâmicas antes do envio.</summary>
    class function ExecuteWithVariablesAsync(ARequest: THttpRequestInfo; 
      AVariables: IList<THttpVariable>): TAsyncBuilder<IRestResponse>; static;
    
    /// <summary>
    ///   Executa uma requisição de forma síncrona (blocante) e retorna um resultado detalhado.
    ///   Recomendado apenas para ferramentas de CLI ou Dashboards de monitoramento.
    /// </summary>
    class function ExecuteSync(ARequest: THttpRequestInfo; 
      AVariables: IList<THttpVariable>): THttpExecutionResult; static;
  end;

implementation

uses
  System.Diagnostics;

{ THttpExecutor }

class function THttpExecutor.MethodToEnum(const AMethod: string): TDextHttpMethod;
var
  Method: string;
begin
  Method := AMethod.ToUpper;
  if Method = 'GET' then Result := hmGET
  else if Method = 'POST' then Result := hmPOST
  else if Method = 'PUT' then Result := hmPUT
  else if Method = 'DELETE' then Result := hmDELETE
  else if Method = 'PATCH' then Result := hmPATCH
  else if Method = 'HEAD' then Result := hmHEAD
  else if Method = 'OPTIONS' then Result := hmOPTIONS
  else Result := hmGET; // Default
end;

class function THttpExecutor.ExecuteAsync(const ARequest: THttpRequestInfo): TAsyncBuilder<IRestResponse>;
var
  LClient: TRestClient;
  LBody: TStringStream;
begin
  LClient := TRestClient.Create(ARequest.Url);
  
  // Add headers
  for var LPair in ARequest.Headers do
    LClient := LClient.Header(LPair.Key, LPair.Value);
  
  // Create body stream if needed
  if ARequest.Body <> '' then
  begin
    LBody := TStringStream.Create(ARequest.Body, TEncoding.UTF8);
    Result := LClient.ExecuteAsync(MethodToEnum(ARequest.Method), '', LBody, True);
  end
  else
    Result := LClient.ExecuteAsync(MethodToEnum(ARequest.Method), '', nil, False);
end;

class function THttpExecutor.ExecuteWithVariablesAsync(ARequest: THttpRequestInfo; 
  AVariables: IList<THttpVariable>): TAsyncBuilder<IRestResponse>;
begin
  // Resolve variables first
  THttpRequestParser.ResolveRequest(ARequest, AVariables);
  Result := ExecuteAsync(ARequest);
end;

class function THttpExecutor.ExecuteSync(ARequest: THttpRequestInfo; 
  AVariables: IList<THttpVariable>): THttpExecutionResult;
var
  Stopwatch: TStopwatch;
  Response: IRestResponse;
  Client: TRestClient;
  Body: TStringStream;
begin
  // Initialize result
  Result.RequestName := ARequest.Name;
  Result.RequestMethod := ARequest.Method;
  Result.Success := False;
  Result.ErrorMessage := '';
  Result.ResponseHeaders := nil;
  
  // Resolve variables first
  THttpRequestParser.ResolveRequest(ARequest, AVariables);
  Result.RequestUrl := ARequest.Url;
  
  Stopwatch := TStopwatch.StartNew;
  
  try
    Client := TRestClient.Create(ARequest.Url);
    
    // Add headers
    for var LPair in ARequest.Headers do
      Client := Client.Header(LPair.Key, LPair.Value);
    
    // Execute request
    if ARequest.Body <> '' then
    begin
      Body := TStringStream.Create(ARequest.Body, TEncoding.UTF8);
      try
        Response := Client.ExecuteAsync(MethodToEnum(ARequest.Method), '', Body, False).Await;
      finally
        Body.Free;
      end;
    end
    else
      Response := Client.ExecuteAsync(MethodToEnum(ARequest.Method), '', nil, False).Await;
    
    Stopwatch.Stop;
    
    // Populate result
    Result.StatusCode := Response.StatusCode;
    Result.StatusText := Response.StatusText;
    Result.ResponseBody := Response.ContentString;
    Result.DurationMs := Stopwatch.ElapsedMilliseconds;
    Result.Success := (Response.StatusCode >= 200) and (Response.StatusCode < 400);
    
  except
    on E: Exception do
    begin
      Stopwatch.Stop;
      Result.StatusCode := 0;
      Result.StatusText := 'Error';
      Result.ResponseBody := '';
      Result.DurationMs := Stopwatch.ElapsedMilliseconds;
      Result.ErrorMessage := E.Message;
    end;
  end;
end;

end.
