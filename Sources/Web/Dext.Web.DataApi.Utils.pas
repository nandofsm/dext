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
  end;

implementation

{ TDataApiNaming }

class function TDataApiNaming.GetEntityTag(ATypeInfo: PTypeInfo): string;
var
  LName: string;
begin
  if ATypeInfo = nil then
    Exit('Entity');

  LName := string(ATypeInfo.Name);
  
  // Remove 'T' prefix if present
  if LName.StartsWith('T') and (Length(LName) > 1) and LName[2].IsUpper then
    LName := LName.Substring(1);

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

end.
