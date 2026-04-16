unit Dext.Web.DataApi.Utils;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Rtti,
  System.Character;

type
  /// <summary>
  ///   Utility for Data API naming conventions and metadata discovery.
  /// </summary>
  TDataApiNaming = class
  public
    /// <summary>
    ///   Gets the pluralized name for an entity type (e.g., TCustomer -> Customers).
    /// </summary>
    class function GetEntityTag(ATypeInfo: PTypeInfo): string; static;
    
    /// <summary>
    ///   Gets a human-readable description for an entity type.
    /// </summary>
    class function GetEntityDescription(ATypeInfo: PTypeInfo): string; static;
    
    /// <summary>
    ///   Gets the default route path for an entity type by convention (e.g., TCustomer -> /api/customer).
    /// </summary>
    class function GetDefaultPath(ATypeInfo: PTypeInfo): string; static;
  end;

implementation

uses
  Dext.Core.Reflection;

{ TDataApiNaming }

class function TDataApiNaming.GetEntityTag(ATypeInfo: PTypeInfo): string;
var
  LName: string;
begin
  if ATypeInfo = nil then
    Exit('Entity');

  LName := TReflection.NormalizeFieldName(string(ATypeInfo.Name));
  
  // Simple pluralization logic (H.3/B.2)
  if LName.EndsWith('y', True) then
    Result := LName.Substring(0, Length(LName) - 1) + 'ies'
  else if LName.EndsWith('ch', True) or LName.EndsWith('sh', True) or LName.EndsWith('x', True) or LName.EndsWith('s', True) then
    Result := LName + 'es'
  else
    Result := LName + 's';
end;

class function TDataApiNaming.GetEntityDescription(ATypeInfo: PTypeInfo): string;
begin
  if ATypeInfo = nil then
    Exit('Entity description not available.');
    
  Result := Format('Manage %s entities via standard REST operations.', [GetEntityTag(ATypeInfo).ToLower]);
end;

class function TDataApiNaming.GetDefaultPath(ATypeInfo: PTypeInfo): string;
var
  LName: string;
begin
  if ATypeInfo = nil then
    Exit('');

  LName := TReflection.NormalizeFieldName(string(ATypeInfo.Name));
  
  Result := '/api/' + LName.ToLower;
end;

end.
