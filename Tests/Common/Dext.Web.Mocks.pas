// Dext.Web.Mocks.pas
unit Dext.Web.Mocks;



interface

uses
  System.Classes,
  System.SysUtils,
  System.Rtti,
  Dext.Collections,
  Dext.Collections.Dict,
  Dext.DI.Interfaces,
  Dext.Web.Interfaces,
  Dext.Auth.Identity,
  Dext.Mocks,
  Dext.Mocks.Matching,
  Dext.Json;

type
  { Retrocompatibility aliases, kept as pure factories around Mock<T> }
  TMockHttpRequest = class
  public
    class function CreateInternal(const AQueryString: string; ABody: TStream): IHttpRequest; static;
    class function Create(const AQueryString: string): IHttpRequest; static;
  end;

  TMockHttpResponse = class
  public
    class function Create: IHttpResponse; static;
  end;

  TMockHttpContext = class
  public
    class function Create(ARequest: IHttpRequest; AResponse: IHttpResponse; AServices: IServiceProvider = nil): IHttpContext; static;
  end;

  TMockFactory = class
  public
    class function CreateHttpContextWithHeaders(const AQueryString: string; const AHeaders: IStringDictionary): IHttpContext; overload;
    class function CreateHttpContextWithHeaders(const AQueryString: string; const AHeaders: IDictionary<string, string>): IHttpContext; overload;
    class function CreateHttpContextWithServices(const AQueryString: string; const AServices: IServiceProvider): IHttpContext; static;
    class function CreateHttpContext(const AQueryString: string): IHttpContext; static;
    class function CreateHttpContextWithRoute(const AQueryString: string; const ARouteParams: IDictionary<string, string>): IHttpContext; static;
    class function CreateHttpContextWithBody(const AQueryString: string; ABody: TStream): IHttpContext; static;
  end;

var
  SharedEmptyStream: TMemoryStream;

implementation

{ Helper }
procedure ParseQueryStringInto(const AQueryString: string; out ADict: IStringDictionary);
var
  I, PosEqual: Integer;
  ParamList: TStringList;
  Key, Value, QueryPart: string;
begin
  ADict := TCollections.CreateStringDictionary(True); // Case-insensitive
  if AQueryString = '' then Exit;

  QueryPart := AQueryString;
  var PosQuery := Pos('?', AQueryString);
  if PosQuery > 0 then
    QueryPart := Copy(AQueryString, PosQuery + 1, MaxInt);

  ParamList := TStringList.Create;
  try
    ParamList.Delimiter := '&';
    ParamList.StrictDelimiter := True;
    ParamList.DelimitedText := QueryPart;
    for I := 0 to ParamList.Count - 1 do
    begin
      PosEqual := Pos('=', ParamList[I]);
      if PosEqual > 0 then
      begin
        Key := Copy(ParamList[I], 1, PosEqual - 1);
        Value := Copy(ParamList[I], PosEqual + 1, MaxInt);
        ADict.AddOrSetValue(Key, Value);
      end
      else
        ADict.AddOrSetValue(ParamList[I], '');
    end;
  finally
    ParamList.Free;
  end;
end;

{ TMockHttpRequest }

class function TMockHttpRequest.CreateInternal(const AQueryString: string; ABody: TStream): IHttpRequest;
var
  MockReq: Mock<IHttpRequest>;
  QueryParams: IStringDictionary;
  EmptyHeaders: IStringDictionary;
  EmptyCookies: IStringDictionary;
  EmptyRoute: TRouteValueDictionary;
  BodyToUse: TStream;
begin
  MockReq := Mock<IHttpRequest>.Create;
  
  BodyToUse := ABody;
  if BodyToUse = nil then
    BodyToUse := SharedEmptyStream;

  ParseQueryStringInto(AQueryString, QueryParams);
  EmptyHeaders := TCollections.CreateStringDictionary(True);
  EmptyCookies := TCollections.CreateStringDictionary(True);
  EmptyRoute.Clear; 

  MockReq.Setup.Returns(TValue.From<IStringDictionary>(QueryParams)).When.GetQuery;
  MockReq.Setup.Returns(TValue.From<IStringDictionary>(EmptyHeaders)).When.GetHeaders;
  MockReq.Setup.Returns(TValue.From<IStringDictionary>(EmptyCookies)).When.GetCookies;
  MockReq.Setup.Returns(TValue.From<TRouteValueDictionary>(EmptyRoute)).When.GetRouteParams;
  
  // Default values
  MockReq.Setup.Returns(TValue.From<string>('GET')).When.GetMethod;
  MockReq.Setup.Returns(TValue.From<string>('/api/test')).When.GetPath;
  MockReq.Setup.Returns(TValue.From<string>('127.0.0.1')).When.GetRemoteIpAddress;
  MockReq.Setup.Returns(TValue.From<TStream>(BodyToUse)).When.GetBody;

  Result := MockReq.Instance;
end;

class function TMockHttpRequest.Create(const AQueryString: string): IHttpRequest;
begin
  Result := CreateInternal(AQueryString, nil);
end;

{ TMockHttpResponse }

class function TMockHttpResponse.Create: IHttpResponse;
var
  MockRes: Mock<IHttpResponse>;
begin
  MockRes := Mock<IHttpResponse>.Create;

  MockRes.Setup.Returns(TValue.From<Integer>(200)).When.GetStatusCode;
  MockRes.Setup.Returns(TValue.From<string>('text/plain')).When.GetContentType;
  
  // Note: Mock<T> dynamically handles unconfigured methods natively without failing 
  // (unless explicitly configured). So write methods etc just swallow calls correctly!

  Result := MockRes.Instance;
end;

{ TMockHttpContext }

class function TMockHttpContext.Create(ARequest: IHttpRequest; AResponse: IHttpResponse;
  AServices: IServiceProvider): IHttpContext;
var
  MockCtx: Mock<IHttpContext>;
  Items: IDictionary<string, TValue>;
begin
  MockCtx := Mock<IHttpContext>.Create;

  Items := TCollections.CreateDictionary<string, TValue>;

  MockCtx.Setup.Returns(TValue.From<IHttpRequest>(ARequest)).When.GetRequest;
  MockCtx.Setup.Returns(TValue.From<IHttpResponse>(AResponse)).When.GetResponse;
  MockCtx.Setup.Returns(TValue.From<IServiceProvider>(AServices)).When.GetServices;
  MockCtx.Setup.Returns(TValue.From<IDictionary<string, TValue>>(Items)).When.GetItems;

  Result := MockCtx.Instance;
end;

{ TMockFactory }

class function TMockFactory.CreateHttpContext(const AQueryString: string): IHttpContext;
begin
  Result := CreateHttpContextWithServices(AQueryString, nil);
end;

class function TMockFactory.CreateHttpContextWithServices(const AQueryString: string;
  const AServices: IServiceProvider): IHttpContext;
begin
  Result := TMockHttpContext.Create(TMockHttpRequest.Create(AQueryString), TMockHttpResponse.Create, AServices);
end;

class function TMockFactory.CreateHttpContextWithHeaders(const AQueryString: string;
  const AHeaders: IStringDictionary): IHttpContext;
var
  MockReq: Mock<IHttpRequest>;
  QueryParams: IStringDictionary;
  EmptyCookies: IStringDictionary;
  EmptyRoute: TRouteValueDictionary;
begin
  MockReq := Mock<IHttpRequest>.Create;
  
  ParseQueryStringInto(AQueryString, QueryParams);
  EmptyCookies := TCollections.CreateStringDictionary(True);
  EmptyRoute.Clear;

  MockReq.Setup.Returns(TValue.From<IStringDictionary>(QueryParams)).When.GetQuery;
  MockReq.Setup.Returns(TValue.From<IStringDictionary>(AHeaders)).When.GetHeaders;
  MockReq.Setup.Returns(TValue.From<IStringDictionary>(EmptyCookies)).When.GetCookies;
  MockReq.Setup.Returns(TValue.From<TRouteValueDictionary>(EmptyRoute)).When.GetRouteParams;
  
  MockReq.Setup.Returns(TValue.From<string>('GET')).When.GetMethod;
  MockReq.Setup.Returns(TValue.From<string>('/api/test')).When.GetPath;
  MockReq.Setup.Returns(TValue.From<string>('127.0.0.1')).When.GetRemoteIpAddress;
  MockReq.Setup.Returns(TValue.From<TStream>(SharedEmptyStream)).When.GetBody;

  Result := TMockHttpContext.Create(MockReq.Instance, TMockHttpResponse.Create, nil);
end;

class function TMockFactory.CreateHttpContextWithHeaders(const AQueryString: string;
  const AHeaders: IDictionary<string, string>): IHttpContext;
var
  NewHeaders: IStringDictionary;
  Pair: TPair<string, string>;
begin
  NewHeaders := TCollections.CreateStringDictionary(True);
  for Pair in AHeaders do
    NewHeaders.AddOrSetValue(Pair.Key, Pair.Value);
  Result := CreateHttpContextWithHeaders(AQueryString, NewHeaders);
end;

class function TMockFactory.CreateHttpContextWithRoute(const AQueryString: string;
  const ARouteParams: IDictionary<string, string>): IHttpContext;
var
  MockReq: Mock<IHttpRequest>;
  QueryParams: IStringDictionary;
  EmptyHeaders: IStringDictionary;
  EmptyCookies: IStringDictionary;
  RouteValDict: TRouteValueDictionary;
  Pair: TPair<string, string>;
begin
  MockReq := Mock<IHttpRequest>.Create;
  
  ParseQueryStringInto(AQueryString, QueryParams);
  EmptyHeaders := TCollections.CreateStringDictionary(True);
  EmptyCookies := TCollections.CreateStringDictionary(True);
  
  RouteValDict.Clear;
  for Pair in ARouteParams do
    RouteValDict.Add(Pair.Key, Pair.Value);

  // Set up standard getters
  MockReq.Setup.Returns(TValue.From<IStringDictionary>(QueryParams)).When.GetQuery;
  MockReq.Setup.Returns(TValue.From<IStringDictionary>(EmptyHeaders)).When.GetHeaders;
  MockReq.Setup.Returns(TValue.From<IStringDictionary>(EmptyCookies)).When.GetCookies;
  MockReq.Setup.Returns(TValue.From<TRouteValueDictionary>(RouteValDict)).When.GetRouteParams;
  MockReq.Setup.Returns(TValue.From<string>('GET')).When.GetMethod;
  MockReq.Setup.Returns(TValue.From<string>('/api/test')).When.GetPath;
  MockReq.Setup.Returns(TValue.From<string>('127.0.0.1')).When.GetRemoteIpAddress;
  MockReq.Setup.Returns(TValue.From<TStream>(SharedEmptyStream)).When.GetBody;

  Result := TMockHttpContext.Create(MockReq.Instance, TMockHttpResponse.Create, nil);
end;

class function TMockFactory.CreateHttpContextWithBody(const AQueryString: string; ABody: TStream): IHttpContext;
begin
  Result := TMockHttpContext.Create(TMockHttpRequest.CreateInternal(AQueryString, ABody), TMockHttpResponse.Create, nil);
end;

initialization
  SharedEmptyStream := TMemoryStream.Create;

finalization
  SharedEmptyStream.Free;

end.
