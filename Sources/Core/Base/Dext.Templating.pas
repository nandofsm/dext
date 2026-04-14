// ***************************************************************************
//
//           Dext Framework
//
//           Copyright (C) 2025 Cesar Romero & Dext Contributors
//
//           Licensed under the Apache License, Version 2.0 (the "License");
//           you may not use this file except in compliance with the License.
//           You may obtain a copy of the License at
//
//               http://www.apache.org/licenses/LICENSE-2.0
//
//           Unless required by applicable law or agreed to in writing,
//           software distributed under the License is distributed on an
//           "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//           either express or implied. See the License for the specific
//           language governing permissions and limitations under the
//           License.
//
// ***************************************************************************
//
//  Author:  Cesar Romero
//  Created: 2026-04-10
//
//  Dext.Templating - Generic Template Engine Contracts & Implementation
//
// ***************************************************************************

unit Dext.Templating;

interface

uses
  System.NetEncoding,
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  System.TypInfo,
  System.Character,
  System.Generics.Collections,
  Dext.Collections,
  Dext.Collections.Dict,
  Dext.Text.Escaping;

type
  ITemplateContext = interface
    ['{1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D}']
    procedure SetValue(const AKey: string; const AValue: string);
    function GetValue(const AKey: string): string;
    function TryGetValue(const AKey: string; out AValue: string): Boolean;
    function HasValue(const AKey: string): Boolean;

    procedure SetObject(const AKey: string; AObject: TObject);
    function GetObject(const AKey: string): TObject;

    procedure SetList(const AKey: string; const AItems: TArray<TObject>);
    function GetList(const AKey: string): TArray<TObject>;

    function CreateChildScope: ITemplateContext;
  end;

  ITemplateEngine = interface
    ['{2B3C4D5E-6F7A-8B9C-0D1E-2F3A4B5C6D7E}']
    function Render(const ATemplate: string; const AContext: ITemplateContext): string;
  end;

  ITemplateLoader = interface
    ['{5C6D7E8F-9A0B-1C2D-3E4F-5A6B7C8D9E0F}']
    function Load(const ATemplateName: string): string;
  end;

  ITemplateFilterRegistry = interface
    ['{6D7E8F9A-0B1C-2D3E-4F5A-6B7C8D9E0F1A}']
    procedure RegisterFilter(const AName: string; const AFilter: System.SysUtils.TFunc<string, string>);
    function ApplyFilter(const AName: string; const AValue: string): string;
  end;

  TTemplateContext = class(TInterfacedObject, ITemplateContext)
  private
    FValues: IDictionary<string, string>;
    FObjects: IDictionary<string, TObject>;
    FLists: IDictionary<string, TArray<TObject>>;
    FParent: ITemplateContext;
  public
    constructor Create; overload;
    constructor Create(const AParent: ITemplateContext); overload;
    destructor Destroy; override;

    procedure SetValue(const AKey: string; const AValue: string);
    function GetValue(const AKey: string): string;
    function TryGetValue(const AKey: string; out AValue: string): Boolean;
    function HasValue(const AKey: string): Boolean;

    procedure SetObject(const AKey: string; AObject: TObject);
    function GetObject(const AKey: string): TObject;

    procedure SetList(const AKey: string; const AItems: TArray<TObject>);
    function GetList(const AKey: string): TArray<TObject>;

    function CreateChildScope: ITemplateContext;
  end;

  // --- Razor-style AST Nodes ---

  TTemplateNode = class
  public
    function Render(const AContext: ITemplateContext): string; virtual; abstract;
  end;

  TTextNode = class(TTemplateNode)
  private
    FText: string;
  public
    constructor Create(const AText: string);
    function Render(const AContext: ITemplateContext): string; override;
  end;

  TExpressionNode = class(TTemplateNode)
  private
    FExpression: string;
    FIsRaw: Boolean;
  public
    constructor Create(const AExpression: string; AIsRaw: Boolean);
    function Render(const AContext: ITemplateContext): string; override;
  end;

  TConditionalNode = class(TTemplateNode)
  private
    FCondition: string;
    FTrueNodes: System.Generics.Collections.TObjectList<TTemplateNode>;
    FFalseNodes: System.Generics.Collections.TObjectList<TTemplateNode>;
  public
    constructor Create(const ACondition: string);
    destructor Destroy; override;
    function Render(const AContext: ITemplateContext): string; override;
    property TrueNodes: System.Generics.Collections.TObjectList<TTemplateNode> read FTrueNodes;
    property FalseNodes: System.Generics.Collections.TObjectList<TTemplateNode> read FFalseNodes;
  end;

  TLoopNode = class(TTemplateNode)
  private
    FItemName: string;
    FListExpr: string;
    FNodes: System.Generics.Collections.TObjectList<TTemplateNode>;
  public
    constructor Create(const AItemName, AListExpr: string);
    destructor Destroy; override;
    function Render(const AContext: ITemplateContext): string; override;
    property Nodes: System.Generics.Collections.TObjectList<TTemplateNode> read FNodes;
  end;
  
  TTemplateNodeList = System.Generics.Collections.TObjectList<TTemplateNode>;

  TDextTemplateEngine = class(TInterfacedObject, ITemplateEngine, ITemplateFilterRegistry)
  private
    FFilters: IDictionary<string, System.SysUtils.TFunc<string, string>>;
    FRttiCtx: TRttiContext;
    FIsHtmlMode: Boolean;

    function ResolveExpression(const AExpr: string; const AContext: ITemplateContext): string;
    function ResolveObjectValue(AObj: TObject; const APropPath: string): TValue;
    function ResolveObjectProperty(AObj: TObject; const APropPath: string): string;
    function Parse(const ATemplate: string): TTemplateNodeList;
    function EvaluateCondition(const ACond: string; const AContext: ITemplateContext): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function Render(const ATemplate: string; const AContext: ITemplateContext): string;

    procedure RegisterFilter(const AName: string; const AFilter: System.SysUtils.TFunc<string, string>);
    function ApplyFilter(const AName: string; const AValue: string): string;

    property IsHtmlMode: Boolean read FIsHtmlMode write FIsHtmlMode;
  end;

  TTemplating = record
  public
    class function CreateContext: ITemplateContext; static;
    class function CreateEngine: ITemplateEngine; static;
  end;

implementation

uses
  Dext.Collections.Comparers;

{ TTextNode }

constructor TTextNode.Create(const AText: string);
begin
  inherited Create;
  FText := AText;
end;

function TTextNode.Render(const AContext: ITemplateContext): string;
begin
  Result := FText;
end;

{ TExpressionNode }

constructor TExpressionNode.Create(const AExpression: string; AIsRaw: Boolean);
begin
  inherited Create;
  FExpression := AExpression;
  FIsRaw := AIsRaw;
end;

function TExpressionNode.Render(const AContext: ITemplateContext): string;
begin
  Result := FExpression;
end;

{ TConditionalNode }

constructor TConditionalNode.Create(const ACondition: string);
begin
  inherited Create;
  FCondition := ACondition;
  FTrueNodes := TObjectList<TTemplateNode>.Create(True);
  FFalseNodes := TObjectList<TTemplateNode>.Create(True);
end;

destructor TConditionalNode.Destroy;
begin
  FTrueNodes.Free;
  FFalseNodes.Free;
  inherited;
end;

function TConditionalNode.Render(const AContext: ITemplateContext): string;
begin
  Result := ''; 
end;

{ TLoopNode }

constructor TLoopNode.Create(const AItemName, AListExpr: string);
begin
  inherited Create;
  FItemName := AItemName;
  FListExpr := AListExpr;
  FNodes := TObjectList<TTemplateNode>.Create(True);
end;

destructor TLoopNode.Destroy;
begin
  FNodes.Free;
  inherited;
end;

function TLoopNode.Render(const AContext: ITemplateContext): string;
begin
  Result := '';
end;

{ TTemplateContext }

constructor TTemplateContext.Create;
begin
  inherited Create;
  FValues := TCollections.CreateDictionaryIgnoreCase<string, string>;
  FObjects := TCollections.CreateDictionaryIgnoreCase<string, TObject>;
  FLists := TCollections.CreateDictionaryIgnoreCase<string, TArray<TObject>>;
end;

constructor TTemplateContext.Create(const AParent: ITemplateContext);
begin
  Create;
  FParent := AParent;
end;

destructor TTemplateContext.Destroy;
begin
  FValues := nil;
  FObjects := nil;
  FLists := nil;
  inherited;
end;

function TTemplateContext.GetValue(const AKey: string): string;
begin
  if not TryGetValue(AKey, Result) then
    Result := '';
end;

function TTemplateContext.HasValue(const AKey: string): Boolean;
var
  Dummy: string;
begin
  Result := TryGetValue(AKey, Dummy);
end;

procedure TTemplateContext.SetValue(const AKey: string; const AValue: string);
begin
  FValues.AddOrSetValue(AKey, AValue);
end;

function TTemplateContext.TryGetValue(const AKey: string; out AValue: string): Boolean;
begin
  Result := FValues.TryGetValue(AKey, AValue);
  if not Result and Assigned(FParent) then
    Result := FParent.TryGetValue(AKey, AValue);
end;

function TTemplateContext.GetObject(const AKey: string): TObject;
begin
  if not FObjects.TryGetValue(AKey, Result) and Assigned(FParent) then
    Result := FParent.GetObject(AKey);
end;

procedure TTemplateContext.SetObject(const AKey: string; AObject: TObject);
begin
  FObjects.AddOrSetValue(AKey, AObject);
end;

function TTemplateContext.GetList(const AKey: string): TArray<TObject>;
begin
  if not FLists.TryGetValue(AKey, Result) and Assigned(FParent) then
    Result := FParent.GetList(AKey);
end;

procedure TTemplateContext.SetList(const AKey: string; const AItems: TArray<TObject>);
begin
  FLists.AddOrSetValue(AKey, AItems);
end;

function TTemplateContext.CreateChildScope: ITemplateContext;
begin
  Result := TTemplateContext.Create(Self);
end;

{ TDextTemplateEngine }

constructor TDextTemplateEngine.Create;
begin
  inherited Create;
  FFilters := TCollections.CreateDictionaryIgnoreCase<string, System.SysUtils.TFunc<string, string>>;
  FRttiCtx := TRttiContext.Create;
  FIsHtmlMode := False;

  RegisterFilter('ToPascalCase', 
    function(S: string): string 
    var
      Parts: TArray<string>;
      I: Integer;
    begin
      Result := S.DeQuotedString;
      Parts := Result.Split(['_', ' ', '-'], TStringSplitOptions.ExcludeEmpty);
      if Length(Parts) > 1 then
      begin
        Result := '';
        for I := 0 to High(Parts) do
          Result := Result + UpperCase(Copy(Parts[I], 1, 1)) + LowerCase(Copy(Parts[I], 2, MaxInt));
      end
      else
        Result := UpperCase(Copy(Result, 1, 1)) + Copy(Result, 2, MaxInt);
    end);

  RegisterFilter('ToCamelCase', 
    function(S: string): string 
    var
      Pascal: string;
    begin
      Pascal := ApplyFilter('ToPascalCase', S);
      if Pascal = '' then
        Result := ''
      else
        Result := LowerCase(Copy(Pascal, 1, 1)) + Copy(Pascal, 2, MaxInt);
    end);
end;

destructor TDextTemplateEngine.Destroy;
begin
  FFilters := nil;
  FRttiCtx.Free;
  inherited;
end;

procedure TDextTemplateEngine.RegisterFilter(const AName: string;
  const AFilter: System.SysUtils.TFunc<string, string>);
begin
  FFilters.AddOrSetValue(AName, AFilter);
end;

function TDextTemplateEngine.ApplyFilter(const AName: string;
  const AValue: string): string;
var
  Filter: System.SysUtils.TFunc<string, string>;
begin
  if FFilters.TryGetValue(System.SysUtils.Trim(AName), Filter) and Assigned(Filter) then
    Result := Filter(AValue)
  else
    Result := AValue;
end;

function TDextTemplateEngine.ResolveObjectValue(AObj: TObject;
  const APropPath: string): TValue;
var
  TypeRtti: TRttiType;
  PropRtti: TRttiProperty;
  Parts: TArray<string>;
  Current: TObject;
  I: Integer;
begin
  Result := TValue.Empty;
  if not Assigned(AObj) then
    Exit;

  Parts := System.StrUtils.SplitString(APropPath, '.');
  Current := AObj;

  for I := 0 to High(Parts) do
  begin
    TypeRtti := FRttiCtx.GetType(Current.ClassInfo);
    if not Assigned(TypeRtti) then Exit;

    PropRtti := TypeRtti.GetProperty(System.SysUtils.Trim(Parts[I]));
    if not Assigned(PropRtti) then Exit;

    Result := PropRtti.GetValue(Current);

    if I = High(Parts) then
      Exit;

    if Result.Kind = tkClass then
    begin
      Current := Result.AsObject;
      if not Assigned(Current) then Exit;
    end
    else
      Exit;
  end;
end;

function TDextTemplateEngine.ResolveObjectProperty(AObj: TObject;
  const APropPath: string): string;
var
  Val: TValue;
begin
  Val := ResolveObjectValue(AObj, APropPath);
  if Val.IsEmpty then
    Result := ''
  else if (Val.Kind = tkClass) then
  begin
    if Val.AsObject <> nil then
      Result := Val.AsObject.ToString
    else
      Result := '';
  end
  else
    Result := Val.ToString;
end;

function TDextTemplateEngine.ResolveExpression(const AExpr: string;
  const AContext: ITemplateContext): string;
var
  Expr: string;
  DotPos: Integer;
  Obj: TObject;
  ObjKey, PropPath: string;
begin
  Expr := System.SysUtils.Trim(AExpr);

  if Expr.EndsWith('.ToPascalCase()', True) then
  begin
    Result := ApplyFilter('ToPascalCase', ResolveExpression(Expr.Substring(0, Expr.Length - 15), AContext));
    Exit;
  end;
  
  if Expr.EndsWith('.ToCamelCase()', True) then
  begin
    Result := ApplyFilter('ToCamelCase', ResolveExpression(Expr.Substring(0, Expr.Length - 14), AContext));
    Exit;
  end;

  DotPos := System.Pos('.', Expr);
  if DotPos > 0 then
  begin
    ObjKey := System.Copy(Expr, 1, DotPos - 1);
    PropPath := System.Copy(Expr, DotPos + 1, MaxInt);
    
    Obj := AContext.GetObject(ObjKey);
    if Assigned(Obj) then
      Result := ResolveObjectProperty(Obj, PropPath)
    else
    begin
      if not AContext.TryGetValue(Expr, Result) then
        Result := '';
    end;
    Exit;
  end;

  Result := AContext.GetValue(Expr);
end;

function TDextTemplateEngine.EvaluateCondition(const ACond: string;
  const AContext: ITemplateContext): Boolean;
var
  Val: string;
begin
  Val := ResolveExpression(ACond, AContext);
  Val := Val.ToLower;
  if Val = 'true' then
    Exit(True);
    
  if (Val = '') or (Val = 'false') or (Val = '0') or (Val = 'null') then
    Exit(False);
    
  Result := True;
end;

function TDextTemplateEngine.Parse(const ATemplate: string): TTemplateNodeList;
var
  Pos, NextAt, EndTagPos: Integer;
  TagContent: string;

  procedure ParseBlock(TargetNodes: TTemplateNodeList; const AEndMarkers: TArray<string>; AStopOnBrace: Boolean = False);
  var
    M: string;
    FoundMarker: Boolean;
  begin
    while Pos <= Length(ATemplate) do
    begin
      FoundMarker := False;
      for M in AEndMarkers do
        if System.StrUtils.StartsText(M, System.Copy(ATemplate, Pos, Length(M))) then
        begin
          Inc(Pos, Length(M));
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #13) then Inc(Pos);
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #10) then Inc(Pos);
          FoundMarker := True;
          Break;
        end;

      if FoundMarker then Break;

      if AStopOnBrace and (ATemplate[Pos] = '}') then
      begin
        Inc(Pos);
        if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #13) then Inc(Pos);
        if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #10) then Inc(Pos);
        Break;
      end;

      NextAt := System.Pos('@', ATemplate, Pos);
      
      if AStopOnBrace then
      begin
        var NextBrace := Pos;
        while (NextBrace <= Length(ATemplate)) and (ATemplate[NextBrace] <> '}') do Inc(NextBrace);
        if (NextBrace <= Length(ATemplate)) and ((NextAt = 0) or (NextBrace < NextAt)) then
        begin
          if NextBrace > Pos then
            TargetNodes.Add(TTextNode.Create(System.Copy(ATemplate, Pos, NextBrace - Pos)));
          Pos := NextBrace + 1;
          // Skip one newline if exists
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #13) then Inc(Pos);
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #10) then Inc(Pos);
          Exit;
        end;
      end;

      for M in AEndMarkers do
      begin
        var MPos := System.Pos('@' + M, ATemplate, Pos);
        if (MPos > 0) and ((NextAt = 0) or (MPos <= NextAt)) then
        begin
          if MPos > Pos then
            TargetNodes.Add(TTextNode.Create(System.Copy(ATemplate, Pos, MPos - Pos)));
          Pos := MPos + Length(M) + 1;
          // Skip one newline if exists
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #13) then Inc(Pos);
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #10) then Inc(Pos);
          Exit;
        end;
      end;

      if NextAt = 0 then
      begin
        TargetNodes.Add(TTextNode.Create(System.Copy(ATemplate, Pos, MaxInt)));
        Pos := Length(ATemplate) + 1;
        Exit;
      end;

      if NextAt > Pos then
        TargetNodes.Add(TTextNode.Create(System.Copy(ATemplate, Pos, NextAt - Pos)));

      Pos := NextAt + 1;

      if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = '@') then
      begin
        TargetNodes.Add(TTextNode.Create('@'));
        Inc(Pos);
        Continue;
      end;

      if System.StrUtils.StartsText('if', System.Copy(ATemplate, Pos, MaxInt)) then
      begin
        Inc(Pos, 2); 
        while (Pos <= Length(ATemplate)) and System.Character.TCharacter.IsWhiteSpace(ATemplate[Pos]) do
          Inc(Pos);
          
        if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = '(') then
        begin
          var Depth := 1;
          var StartPos := Pos + 1;
          Inc(Pos);
          while (Pos <= Length(ATemplate)) and (Depth > 0) do
          begin
            if ATemplate[Pos] = '(' then Inc(Depth)
            else if ATemplate[Pos] = ')' then Dec(Depth);
            if Depth > 0 then Inc(Pos);
          end;
          
          TagContent := System.SysUtils.Trim(System.Copy(ATemplate, StartPos, Pos - StartPos));
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = ')') then Inc(Pos);
        end
        else
        begin
          EndTagPos := Pos;
          while (EndTagPos <= Length(ATemplate)) and (ATemplate[EndTagPos] <> #13) and (ATemplate[EndTagPos] <> #10) do
            Inc(EndTagPos);
          TagContent := System.SysUtils.Trim(System.Copy(ATemplate, Pos, EndTagPos - Pos));
          Pos := EndTagPos;
        end;
        
        while (Pos <= Length(ATemplate)) and (ATemplate[Pos] <= ' ') do
          Inc(Pos);
        
        var IfNode := TConditionalNode.Create(TagContent);
        TargetNodes.Add(IfNode);
        
        var UseBrace := (Pos <= Length(ATemplate)) and (ATemplate[Pos] = '{');
        if UseBrace then
        begin
          Inc(Pos);
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #13) then Inc(Pos);
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #10) then Inc(Pos);
          ParseBlock(IfNode.TrueNodes, [], True);
        end
        else
          ParseBlock(IfNode.TrueNodes, ['endif']);
        Continue;
      end;

      if System.StrUtils.StartsText('endif', System.Copy(ATemplate, Pos, MaxInt)) then
      begin
        Inc(Pos, 5);
        Continue; 
      end;

      if System.StrUtils.StartsText('foreach', System.Copy(ATemplate, Pos, MaxInt)) then
      begin
        Inc(Pos, 7);
        while (Pos <= Length(ATemplate)) and System.Character.TCharacter.IsWhiteSpace(ATemplate[Pos]) do
          Inc(Pos);

        if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = '(') then
        begin
          var Depth := 1;
          var StartPos := Pos + 1;
          Inc(Pos);
          while (Pos <= Length(ATemplate)) and (Depth > 0) do
          begin
            if ATemplate[Pos] = '(' then Inc(Depth)
            else if ATemplate[Pos] = ')' then Dec(Depth);
            if Depth > 0 then Inc(Pos);
          end;
          
          TagContent := System.SysUtils.Trim(System.Copy(ATemplate, StartPos, Pos - StartPos));
          if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = ')') then Inc(Pos);
        end
        else
        begin
          EndTagPos := Pos;
          while (EndTagPos <= Length(ATemplate)) and (ATemplate[EndTagPos] <> #13) and (ATemplate[EndTagPos] <> #10) do
            Inc(EndTagPos);
          TagContent := System.SysUtils.Trim(System.Copy(ATemplate, Pos, EndTagPos - Pos));
          Pos := EndTagPos;
        end;
        
        var CleanExpr := TagContent;
        var PartsArray := CleanExpr.Split([' '], TStringSplitOptions.ExcludeEmpty);
        
        if Length(PartsArray) >= 3 then
        begin
          var ItemName := '';
          var ListExpr := '';
          
          if (Length(PartsArray) >= 4) and (PartsArray[0] = 'var') then
          begin
            ItemName := PartsArray[1];
            ListExpr := PartsArray[3];
          end
          else
          begin
            ItemName := PartsArray[0];
            ListExpr := PartsArray[2];
          end;
          
          var ForNode := TLoopNode.Create(ItemName, ListExpr);
          TargetNodes.Add(ForNode);
          
          while (Pos <= Length(ATemplate)) and (ATemplate[Pos] <= ' ') do
            Inc(Pos);
          
          var UseBrace := (Pos <= Length(ATemplate)) and (ATemplate[Pos] = '{');
          if UseBrace then
          begin
            Inc(Pos);
            if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #13) then Inc(Pos);
            if (Pos <= Length(ATemplate)) and (ATemplate[Pos] = #10) then Inc(Pos);
            ParseBlock(ForNode.Nodes, [], True);
          end
          else
            ParseBlock(ForNode.Nodes, ['endforeach']);
        end;
        Continue;
      end;

      if System.StrUtils.StartsText('endforeach', System.Copy(ATemplate, Pos, MaxInt)) then
      begin
        Inc(Pos, 10);
        Continue;
      end;

      EndTagPos := Pos;
      while (EndTagPos <= Length(ATemplate)) and 
            (ATemplate[EndTagPos] <> '@') and
            (not System.Character.TCharacter.IsWhiteSpace(ATemplate[EndTagPos])) and
            (not System.SysUtils.CharInSet(ATemplate[EndTagPos], [';', ':', ',', '{', '}', '<', '>', '/', '\', '[', ']', '''', '"', '=', '+', '-', '*', '!', '?', '|', '&'])) do
      begin
        if ATemplate[EndTagPos] = '(' then
        begin
          var Depth := 1;
          Inc(EndTagPos);
          while (EndTagPos <= Length(ATemplate)) and (Depth > 0) do
          begin
             if ATemplate[EndTagPos] = '(' then Inc(Depth)
             else if ATemplate[EndTagPos] = ')' then Dec(Depth);
             Inc(EndTagPos);
          end;
        end
        else
          Inc(EndTagPos);
      end;
      
      TagContent := System.Copy(ATemplate, Pos, EndTagPos - Pos);
      TargetNodes.Add(TExpressionNode.Create(TagContent, False));
      Pos := EndTagPos;
    end;
  end;

begin
  Result := TTemplateNodeList.Create(True);
  Pos := 1;
  ParseBlock(Result, []);
end;

function TDextTemplateEngine.Render(const ATemplate: string;
  const AContext: ITemplateContext): string;
var
  Nodes: TTemplateNodeList;
  SB: TStringBuilder;

  procedure RenderNodeList(ANodes: TTemplateNodeList; AContext: ITemplateContext);
  begin
    for var Node in ANodes do
    begin
      if Node is TTextNode then
        SB.Append(TTextNode(Node).FText)
      else if Node is TExpressionNode then
      begin
        var ExprNode := TExpressionNode(Node);
        var Val := ResolveExpression(ExprNode.FExpression, AContext);
        if FIsHtmlMode and (not ExprNode.FIsRaw) then
          SB.Append(TDextEscaping.Html(Val))
        else
          SB.Append(Val);
      end
      else if Node is TConditionalNode then
      begin
        var IfNode := TConditionalNode(Node);
        if EvaluateCondition(IfNode.FCondition, AContext) then
          RenderNodeList(IfNode.TrueNodes, AContext)
        else
          RenderNodeList(IfNode.FalseNodes, AContext);
      end
      else if Node is TLoopNode then
      begin
        var ForNode := TLoopNode(Node);
        var Items: TArray<TObject> := [];
        
        var ListExprStr := ForNode.FListExpr;
        var DotPos := System.Pos('.', ListExprStr);
        if DotPos > 0 then
        begin
          var ObjKey := System.Copy(ListExprStr, 1, DotPos - 1);
          var PropPath := System.Copy(ListExprStr, DotPos + 1, MaxInt);
          var RootObj := AContext.GetObject(ObjKey);
          if Assigned(RootObj) then
          begin
            var Val := ResolveObjectValue(RootObj, PropPath);
            if not Val.IsEmpty then
            begin
              if Val.Kind = tkInterface then
              begin
                var ObjList: IObjectList;
                if Supports(Val.AsInterface, IObjectList, ObjList) then
                begin
                  var Count := ObjList.Count;
                  SetLength(Items, Count);
                  for var J := 0 to Count - 1 do
                    Items[J] := ObjList.Items[J];
                end;
              end
              else if Val.Kind = tkClass then
              begin
                var ListObj := Val.AsObject;
                if Assigned(ListObj) then
                begin
                  var ListType := FRttiCtx.GetType(ListObj.ClassInfo);
                  var CountProp := ListType.GetProperty('Count');
                  var ItemsProp := ListType.GetIndexedProperty('Items');
                  
                  if Assigned(CountProp) and Assigned(ItemsProp) then
                  begin
                    var Count := CountProp.GetValue(ListObj).AsInteger;
                    SetLength(Items, Count);
                    for var J := 0 to Count - 1 do
                      Items[J] := ItemsProp.GetValue(ListObj, [J]).AsObject;
                  end;
                end;
              end;
            end;
          end;
        end
        else
          Items := AContext.GetList(ForNode.FListExpr);
        
        for var I := 0 to High(Items) do
        begin
          var ChildScope := AContext.CreateChildScope;
          ChildScope.SetObject(ForNode.FItemName, Items[I]);
          RenderNodeList(ForNode.Nodes, ChildScope);
        end;
      end;
    end;
  end;

begin
  Nodes := Parse(ATemplate);
  try
    SB := TStringBuilder.Create;
    try
      RenderNodeList(Nodes, AContext);
      Result := SB.ToString;
    finally
      SB.Free;
    end;
  finally
    Nodes.Free;
  end;
end;

{ TTemplating }

class function TTemplating.CreateContext: ITemplateContext;
begin
  Result := TTemplateContext.Create;
end;

class function TTemplating.CreateEngine: ITemplateEngine;
begin
  Result := TDextTemplateEngine.Create;
end;

end.
