unit Dext.Scaffolding.Models;

interface

uses
  System.SysUtils,
  Dext.Collections;

type
  TColumnViewModel = class
  private
    FName: string;
    FDelphiName: string;
    FDataType: string;
    FDelphiType: string;
    FIsPrimaryKey: Boolean;
    FIsAutoInc: Boolean;
    FIsNullable: Boolean;
    FLength: Integer;
    FPrecision: Integer;
    FScale: Integer;
  public
    property Name: string read FName write FName;
    property DelphiName: string read FDelphiName write FDelphiName;
    property DataType: string read FDataType write FDataType;
    property DelphiType: string read FDelphiType write FDelphiType;
    property IsPrimaryKey: Boolean read FIsPrimaryKey write FIsPrimaryKey;
    property IsAutoInc: Boolean read FIsAutoInc write FIsAutoInc;
    property IsNullable: Boolean read FIsNullable write FIsNullable;
    property Length: Integer read FLength write FLength;
    property Precision: Integer read FPrecision write FPrecision;
    property Scale: Integer read FScale write FScale;
    
    function GetAttributeString: string;
  end;

  TManyToManyViewModel = class
  private
    FPropertyName: string;
    FTargetClass: string;
    FJoinTable: string;
    FSourceColumn: string;
    FTargetColumn: string;
  public
    property PropertyName: string read FPropertyName write FPropertyName;
    property TargetClass: string read FTargetClass write FTargetClass;
    property JoinTable: string read FJoinTable write FJoinTable;
    property SourceColumn: string read FSourceColumn write FSourceColumn;
    property TargetColumn: string read FTargetColumn write FTargetColumn;
  end;

  TFKViewModel = class
  private
    FName: string;
    FColumnName: string;
    FReferencedTable: string;
    FReferencedClass: string;
    FPropertyName: string;
  public
    property Name: string read FName write FName;
    property ColumnName: string read FColumnName write FColumnName;
    property ReferencedTable: string read FReferencedTable write FReferencedTable;
    property ReferencedClass: string read FReferencedClass write FReferencedClass;
    property PropertyName: string read FPropertyName write FPropertyName;
  end;

  TTableViewModel = class
  private
    FName: string;
    FDelphiClassName: string;
    FDelphiNamespace: string;
    FDelphiUnitName: string;
    FColumns: IList<TColumnViewModel>;
    FForeignKeys: IList<TFKViewModel>;
    FManyToMany: IList<TManyToManyViewModel>;
    FIsJoinTable: Boolean;
  public
    constructor Create;
    
    property Name: string read FName write FName;
    property DelphiClassName: string read FDelphiClassName write FDelphiClassName;
    property DelphiNamespace: string read FDelphiNamespace write FDelphiNamespace;
    property DelphiUnitName: string read FDelphiUnitName write FDelphiUnitName;
    property Columns: IList<TColumnViewModel> read FColumns;
    property ForeignKeys: IList<TFKViewModel> read FForeignKeys;
    property ManyToMany: IList<TManyToManyViewModel> read FManyToMany;
    property IsJoinTable: Boolean read FIsJoinTable write FIsJoinTable;
  end;

  TScaffoldViewModel = class
  private
    FDelphiProjectName: string;
    FDelphiNamespace: string;
    FTables: IList<TTableViewModel>;
  public
    constructor Create;
    
    property DelphiProjectName: string read FDelphiProjectName write FDelphiProjectName;
    property DelphiNamespace: string read FDelphiNamespace write FDelphiNamespace;
    property Tables: IList<TTableViewModel> read FTables;
  end;

implementation

{ TColumnViewModel }

function TColumnViewModel.GetAttributeString: string;
var
  Attrs: IList<string>;
begin
  Attrs := TCollections.CreateList<string>;
  if FIsPrimaryKey then Attrs.Add('PK');
  if FIsAutoInc then Attrs.Add('AutoInc');
  if not FIsNullable then Attrs.Add('Required');
  if (FLength > 0) and (FDelphiType = 'string') then
    Attrs.Add('MaxLength(' + FLength.ToString + ')');
  if FPrecision > 0 then
    Attrs.Add(Format('Precision(%d, %d)', [FPrecision, FScale]));
  
  if Attrs.Count = 0 then
    Exit('');
    
  Result := '[' + string.Join(', ', Attrs.ToArray) + ']';
end;

{ TTableViewModel }

constructor TTableViewModel.Create;
begin
  FColumns := TCollections.CreateList<TColumnViewModel>(True);
  FForeignKeys := TCollections.CreateList<TFKViewModel>(True);
  FManyToMany := TCollections.CreateList<TManyToManyViewModel>(True);
  FIsJoinTable := False;
end;

{ TScaffoldViewModel }

constructor TScaffoldViewModel.Create;
begin
  FTables := TCollections.CreateList<TTableViewModel>(True);
end;

end.
