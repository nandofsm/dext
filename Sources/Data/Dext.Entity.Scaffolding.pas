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
unit Dext.Entity.Scaffolding;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Comp.Client,
  Dext.Collections.Base,
  Dext.Collections.Dict,
  Dext.Collections,
  Dext.Entity.Drivers.Interfaces,
  Dext.Utils;

type
  TMetaColumn = record
    Name: string;
    DataType: string; // SQL Type
    Length: Integer;
    Precision: Integer;
    Scale: Integer;
    IsNullable: Boolean;
    IsPrimaryKey: Boolean;
    IsAutoInc: Boolean;
  end;

  TMetaForeignKey = record
    Name: string;
    ColumnName: string;
    ReferencedTable: string;
    ReferencedColumn: string;
    OnDelete: string; // CASCADE, SET NULL, etc.
    OnUpdate: string;
  end;

  TMetaTable = record
    Name: string;
    Columns: TArray<TMetaColumn>;
    ForeignKeys: TArray<TMetaForeignKey>;
  end;

  ISchemaProvider = interface
    ['{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}']
    function GetTables: TArray<string>;
    function GetTableMetadata(const ATableName: string): TMetaTable;
  end;

  TMappingStyle = (msAttributes, msFluent);
  TPropertyStyle = (psPOCO, psSmart);

  IEntityGenerator = interface
    ['{B1C2D3E4-F5A6-7890-1234-567890ABCDEF}']
    function GenerateUnit(const AUnitName: string; const ATables: TArray<TMetaTable>; 
      AMappingStyle: TMappingStyle = msAttributes;
      APropertyStyle: TPropertyStyle = psPOCO;
      AGenerateMetadata: Boolean = True): string;
  end;

  // FireDAC Implementation
  TFireDACSchemaProvider = class(TInterfacedObject, ISchemaProvider)
  private
    FConnection: IDbConnection;
    FMetaQuery: TFDMetaInfoQuery;
    FCache: Dext.Collections.Dict.IDictionary<string, TMetaTable>;
    FIsCached: Boolean;
    procedure EnsureCache;
    function GetMetaQuery: TFDMetaInfoQuery;
  public
    constructor Create(AConnection: IDbConnection);
    destructor Destroy; override;
    function GetTables: TArray<string>;
    function GetTableMetadata(const ATableName: string): TMetaTable;
  end;

  // Delphi Generator Implementation
  TDelphiEntityGenerator = class(TInterfacedObject, IEntityGenerator)
  private
    function SQLTypeToDelphiType(const ASQLType: string; AScale: Integer; APropertyStyle: TPropertyStyle = psPOCO): string;
    function CleanName(const AName: string): string;
    function EscapeIdentifier(const AIdentifier: string): string;
    function IsKeyword(const AName: string): Boolean;
    function CleanMappingName(const AName: string): string;
  public
    function GenerateUnit(const AUnitName: string; const ATables: TArray<TMetaTable>; 
      AMappingStyle: TMappingStyle = msAttributes;
      APropertyStyle: TPropertyStyle = psPOCO;
      AGenerateMetadata: Boolean = True): string;
  end;

implementation

uses
  Data.DB,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Intf,
  System.Diagnostics,
  System.StrUtils,
  Dext.Core.Reflection,
  Dext.Entity.Context,
  Dext.Entity.Drivers.FireDAC,
  Dext.Types.Lazy,
  Dext.Types.Nullable;

{ TFireDACSchemaProvider }

constructor TFireDACSchemaProvider.Create(AConnection: IDbConnection);
begin
  FConnection := AConnection;
  FCache := TCollections.CreateDictionary<string, TMetaTable>;
  FIsCached := False;
end;

destructor TFireDACSchemaProvider.Destroy;
begin
  FMetaQuery.Free;
  FCache := nil;
  inherited;
end;

function TFireDACSchemaProvider.GetMetaQuery: TFDMetaInfoQuery;
begin
  if FMetaQuery = nil then
  begin
    if not (FConnection is TFireDACConnection) then
      raise Exception.Create('Connection is not a FireDAC connection');
      
    FMetaQuery := TFDMetaInfoQuery.Create(nil);
    FMetaQuery.Connection := TFireDACConnection(FConnection).Connection;
  end;
  Result := FMetaQuery;
end;

procedure TFireDACSchemaProvider.EnsureCache;
var
  Meta: TFDMetaInfoQuery;
  LTable: TMetaTable;
  LCol: TMetaColumn;
  LFK: TMetaForeignKey;
  LTableName: string;
  LDriver: string;
begin
  if FIsCached then Exit;

  var FDConn := TFireDACConnection(FConnection).Connection;
  LDriver := FDConn.DriverName;
  
  var LSchema := FDConn.Params.Values['MetaCurSchema'];
  if LSchema = '' then LSchema := FDConn.Params.Values['Schema'];
  if LSchema = '' then LSchema := FDConn.Params.Values['MetaDefSchema'];

  if Assigned(FConnection.OnLog) then
    FConnection.OnLog('Starting bulk metadata extraction for schema: ' + LSchema + ' (Driver: ' + LDriver + ')');

  var SWTotal := TStopwatch.StartNew;

  // Use Native SQL for PostgreSQL
  if SameText(LDriver, 'PG') then
  begin
    var Qry := TFDQuery.Create(nil);
    try
      Qry.Connection := FDConn;
      
      // 1. Fetch all columns for the schema
      Qry.SQL.Text := 
        'SELECT table_name, column_name, data_type, character_maximum_length, ' +
        '       numeric_precision, numeric_scale, is_nullable, column_default ' +
        'FROM information_schema.columns ' +
        'WHERE table_schema = :schema ' +
        'ORDER BY table_name, ordinal_position';
      Qry.ParamByName('schema').AsString := LSchema;
      Qry.Open;
      
      while not Qry.Eof do
      begin
        LTableName := Qry.FieldByName('table_name').AsString;
        if not (FCache.TryGetValue(LTableName, LTable)) then
        begin
          LTable.Name := LTableName;
          LTable.Columns := [];
          LTable.ForeignKeys := [];
        end;

        LCol.Name := Qry.FieldByName('column_name').AsString;
        LCol.DataType := Qry.FieldByName('data_type').AsString;
        LCol.Length := Qry.FieldByName('character_maximum_length').AsInteger;
        LCol.Precision := Qry.FieldByName('numeric_precision').AsInteger;
        LCol.Scale := Qry.FieldByName('numeric_scale').AsInteger;
        LCol.IsNullable := SameText(Qry.FieldByName('is_nullable').AsString, 'YES');
        LCol.IsPrimaryKey := False;
        LCol.IsAutoInc := Qry.FieldByName('column_default').AsString.Contains('nextval');

        LTable.Columns := LTable.Columns + [LCol];
        FCache.AddOrSetValue(LTableName, LTable);
        Qry.Next;
      end;
      Qry.Close;

      // 2. Fetch Primary Keys
      Qry.SQL.Text := 
        'SELECT rel.relname AS table_name, att.attname AS column_name ' +
        'FROM pg_index idx ' +
        'JOIN pg_class rel ON rel.oid = idx.indrelid ' +
        'JOIN pg_attribute att ON att.attrelid = rel.oid AND att.attnum = ANY(idx.indkey) ' +
        'JOIN pg_namespace ns ON ns.oid = rel.relnamespace ' +
        'WHERE ns.nspname = :schema AND idx.indisprimary';
      Qry.ParamByName('schema').AsString := LSchema;
      Qry.Open;
      while not Qry.Eof do
      begin
        LTableName := Qry.FieldByName('table_name').AsString;
        var LColName := Qry.FieldByName('column_name').AsString;
        if (FCache.TryGetValue(LTableName, LTable)) then
        begin
          for var i := 0 to High(LTable.Columns) do
            if SameText(LTable.Columns[i].Name, LColName) then
            begin
              LTable.Columns[i].IsPrimaryKey := True;
              FCache.AddOrSetValue(LTableName, LTable);
              Break;
            end;
        end;
        Qry.Next;
      end;
      Qry.Close;

      // 3. Fetch Foreign Keys
      Qry.SQL.Text := 
        'SELECT con.conname AS constraint_name, rel.relname AS table_name, att.attname AS column_name, ' +
        '       frel.relname AS foreign_table_name, fatt.attname AS foreign_column_name ' +
        'FROM pg_constraint con ' +
        'JOIN pg_class rel ON rel.oid = con.conrelid ' +
        'JOIN pg_class frel ON frel.oid = con.confrelid ' +
        'JOIN pg_attribute att ON att.attrelid = rel.oid AND att.attnum = ANY(con.conkey) ' +
        'JOIN pg_attribute fatt ON fatt.attrelid = frel.oid AND fatt.attnum = ANY(con.confkey) ' +
        'JOIN pg_namespace ns ON ns.oid = rel.relnamespace ' +
        'WHERE ns.nspname = :schema AND con.contype = ''f''';
      Qry.ParamByName('schema').AsString := LSchema;
      Qry.Open;
      while not Qry.Eof do
      begin
        LTableName := Qry.FieldByName('table_name').AsString;
        if (FCache.TryGetValue(LTableName, LTable)) then
        begin
          LFK.Name := Qry.FieldByName('constraint_name').AsString;
          LFK.ColumnName := Qry.FieldByName('column_name').AsString;
          LFK.ReferencedTable := Qry.FieldByName('foreign_table_name').AsString;
          LFK.ReferencedColumn := Qry.FieldByName('foreign_column_name').AsString;
          LTable.ForeignKeys := LTable.ForeignKeys + [LFK];
          FCache.AddOrSetValue(LTableName, LTable);
        end;
        Qry.Next;
      end;
    finally
      Qry.Free;
    end;
  end
  else
  begin
    // Fallback to FireDAC MetaInfo
    var TableList := GetTables;
    Meta := GetMetaQuery;
    for var TName in TableList do
    begin
      LTable.Name := TName;
      LTable.Columns := [];
      LTable.ForeignKeys := [];
      
      Meta.Close;
      Meta.MetaInfoKind := mkTableFields;
      Meta.ObjectName := TName;
      Meta.Open;
      while not Meta.Eof do
      begin
        LCol.Name := Meta.FieldByName('COLUMN_NAME').AsString;
        LCol.DataType := Meta.FieldByName('COLUMN_TYPENAME').AsString;
        LCol.Length := Meta.FieldByName('COLUMN_LENGTH').AsInteger;
        LCol.Precision := Meta.FieldByName('COLUMN_PRECISION').AsInteger;
        LCol.Scale := Meta.FieldByName('COLUMN_SCALE').AsInteger;
        LCol.IsNullable := True;
        if Meta.FindField('IS_NULLABLE') <> nil then LCol.IsNullable := Meta.FieldByName('IS_NULLABLE').AsString = 'YES'
        else if Meta.FindField('NULLABLE') <> nil then LCol.IsNullable := Meta.FieldByName('NULLABLE').AsInteger = 1;
        
        LCol.IsPrimaryKey := False;
        if Meta.FindField('PRIMARY_KEY') <> nil then LCol.IsPrimaryKey := Meta.FieldByName('PRIMARY_KEY').AsBoolean;
        
        LCol.IsAutoInc := False;
        LTable.Columns := LTable.Columns + [LCol];
        Meta.Next;
      end;
      
      // Fetch FKs for this table
      Meta.Close;
      Meta.MetaInfoKind := mkForeignKeys;
      Meta.ObjectName := TName;
      try
        Meta.Open;
        while not Meta.Eof do
        begin
          // SQLite uses different field names or might not have CONSTRAINT_NAME
          if Meta.FindField('CONSTRAINT_NAME') <> nil then
            LFK.Name := Meta.FieldByName('CONSTRAINT_NAME').AsString
          else if Meta.FindField('FKEY_NAME') <> nil then
            LFK.Name := Meta.FieldByName('FKEY_NAME').AsString
          else
            LFK.Name := 'FK_' + TName + '_' + (FCache.Count + 1).ToString;

          if Meta.FindField('COLUMN_NAME') <> nil then
            LFK.ColumnName := Meta.FieldByName('COLUMN_NAME').AsString
          else if Meta.FindField('FK_COLUMN_NAME') <> nil then
            LFK.ColumnName := Meta.FieldByName('FK_COLUMN_NAME').AsString;

          if Meta.FindField('REF_TABLE_NAME') <> nil then
            LFK.ReferencedTable := Meta.FieldByName('REF_TABLE_NAME').AsString
          else if Meta.FindField('PK_TABLE_NAME') <> nil then
            LFK.ReferencedTable := Meta.FieldByName('PK_TABLE_NAME').AsString;

          if Meta.FindField('REF_COLUMN_NAME') <> nil then
            LFK.ReferencedColumn := Meta.FieldByName('REF_COLUMN_NAME').AsString
          else if Meta.FindField('PK_COLUMN_NAME') <> nil then
            LFK.ReferencedColumn := Meta.FieldByName('PK_COLUMN_NAME').AsString;

          LTable.ForeignKeys := LTable.ForeignKeys + [LFK];
          Meta.Next;
        end;
      except
        // Some drivers might fail mkForeignKeys, ignore and continue
      end;

      FCache.AddOrSetValue(TName, LTable);
    end;
  end;

  if Assigned(FConnection.OnLog) then
    FConnection.OnLog(Format('Bulk metadata extraction completed in %d ms for %d tables', 
      [SWTotal.ElapsedMilliseconds, FCache.Count]));

  FIsCached := True;
end;
function TFireDACSchemaProvider.GetTables: TArray<string>;
var
  FDConn: TFDConnection;
  List: TStringList;
begin
  if not (FConnection is TFireDACConnection) then
    raise Exception.Create('Connection is not a FireDAC connection');

  FDConn := TFireDACConnection(FConnection).Connection;
  List := TStringList.Create;
  try
    var LCatalog := FDConn.Params.Values['Database'];
    var LSchema := FDConn.Params.Values['MetaCurSchema'];
    if LSchema = '' then
      LSchema := FDConn.Params.Values['Schema'];
    if LSchema = '' then
      LSchema := FDConn.Params.Values['MetaDefSchema'];

    // SQLite doesn't use Catalog/Schema in the same way, and file paths with colons break GetTableNames
    if SameText(FDConn.DriverName, 'SQLite') then
    begin
       LCatalog := '';
       LSchema := '';
    end;
      
    // Added [osOther] to see tables from different owners in the same schema
    FDConn.GetTableNames(LCatalog, LSchema, '', List, [osMy, osOther], [tkTable, tkView], True);
    
    if Assigned(FConnection.OnLog) then
      FConnection.OnLog(Format('Found %d tables in schema "%s"', [List.Count, LSchema]));

    // Filter out system tables
    for var i := List.Count - 1 downto 0 do
    begin
       if List[i].StartsWith('pg_catalog.', True) or 
          List[i].StartsWith('information_schema.', True) or
          List[i].StartsWith('sys.', True) then
          List.Delete(i);
    end;

    Result := List.ToStringArray;
  finally
    List.Free;
  end;
end;

function TFireDACSchemaProvider.GetTableMetadata(const ATableName: string): TMetaTable;
begin
  EnsureCache;
  if not (FCache.TryGetValue(ATableName, Result)) then
  begin
     // Fallback if table wasn't found in bulk (unlikely but safe)
     Result.Name := ATableName;
     Result.Columns := [];
     Result.ForeignKeys := [];
  end;
end;

{ TDelphiEntityGenerator }

function TDelphiEntityGenerator.IsKeyword(const AName: string): Boolean;
const
  KEYWORDS: array[0..68] of string = (
    'AND', 'ARRAY', 'AS', 'ASM', 'BEGIN', 'CASE', 'CLASS', 'CONST', 'CONSTRUCTOR',
    'DESTRUCTOR', 'DIV', 'DO', 'DOWNTO', 'ELSE', 'END', 'EXCEPT', 'FILE', 'FOR',
    'FUNCTION', 'GOTO', 'IF', 'IMPLEMENTATION', 'IN', 'INHERITED', 'INITIALIZATION',
    'INTERFACE', 'IS', 'LABEL', 'LIBRARY', 'MOD', 'NIL', 'NOT', 'OBJECT', 'OF',
    'OR', 'OUT', 'PACKED', 'PROCEDURE', 'PROGRAM', 'PROPERTY', 'RAISE', 'RECORD',
    'REPEAT', 'SET', 'SHL', 'SHR', 'STRING', 'THEN', 'THREADVAR', 'TO', 'TRY',
    'TYPE', 'UNIT', 'UNTIL', 'USES', 'VAR', 'WHILE', 'WITH', 'XOR', 'PRIVATE',
    'PROTECTED', 'PUBLIC', 'PUBLISHED', 'STRICT', 'HELPER', 'SEALED', 'FINAL',
    'VIRTUAL', 'OVERRIDE'
  );
var
  K: string;
begin
  Result := False;
  for K in KEYWORDS do
    if SameText(AName, K) then Exit(True);
end;

function TDelphiEntityGenerator.CleanName(const AName: string): string;
var
  Parts: TArray<string>;
  S: string;
  CleanedName: string;
begin
  Result := '';
  // Remove quotes and brackets
  CleanedName := AName.Replace('"', '').Replace('''', '').Replace('[', '').Replace(']', '');
  
  // Handle dot notation (Catalog.Schema.Table or Schema.Table)
  // Take the last part as the table name
  if CleanedName.Contains('.') then
  begin
    Parts := CleanedName.Split(['.']);
    if Length(Parts) > 0 then
      CleanedName := Parts[High(Parts)];
  end;
  
  // Split by common delimiters
  Parts := CleanedName.Split(['_', '-', ' '], TStringSplitOptions.ExcludeEmpty);
  for S in Parts do
  begin
    if S.Length > 0 then
      // Capitalize first letter, lowercase the rest (PascalCase)
      Result := Result + UpperCase(S.Chars[0]) + S.Substring(1).ToLower;
  end;
end;

function TDelphiEntityGenerator.EscapeIdentifier(const AIdentifier: string): string;
begin
  if IsKeyword(AIdentifier) then
    Result := '&' + AIdentifier
  else
    Result := AIdentifier;
end;

function TDelphiEntityGenerator.SQLTypeToDelphiType(const ASQLType: string; AScale: Integer; APropertyStyle: TPropertyStyle = psPOCO): string;
var
  LType: string;
begin
  LType := ASQLType.ToUpper;
  
  if APropertyStyle = psSmart then
  begin
    if LType.Contains('CHAR') or LType.Contains('TEXT') or LType.Contains('STRING') or LType.Contains('UUID') or LType.Contains('GUID') then Exit('StringType');
    if LType.Contains('INT') or LType.Contains('SERIAL') or LType.Contains('COUNTER') then
    begin
       if LType.Contains('64') or LType.Contains('BIG') then Exit('Int64Type');
       Exit('IntType');
    end;
    if LType.Contains('BOOL') or LType.Contains('BIT') or LType.Contains('LOGICAL') then Exit('BoolType');
    if LType.Contains('DECIMAL') or LType.Contains('NUMERIC') or LType.Contains('MONEY') or LType.Contains('CURRENCY') then Exit('CurrencyType');
    if LType.Contains('FLOAT') or LType.Contains('DOUBLE') or LType.Contains('REAL') then Exit('FloatType');
    if LType.Contains('DATE') and LType.Contains('TIME') then Exit('DateTimeType');
    if LType.Contains('DATE') then Exit('DateType');
    if LType.Contains('TIME') then Exit('TimeType');
    if LType.Contains('BLOB') or LType.Contains('BYTEA') or LType.Contains('BINARY') or LType.Contains('IMAGE') then Exit('TBytes');
    Exit('StringType');
  end;

  if LType.Contains('CHAR') or LType.Contains('TEXT') or LType.Contains('STRING') or LType.Contains('UUID') or LType.Contains('GUID') then Exit('string');
  if LType.Contains('INT') or LType.Contains('SERIAL') or LType.Contains('COUNTER') then
  begin
     if LType.Contains('64') or LType.Contains('BIG') then Exit('Int64');
     Exit('Integer');
  end;
  if LType.Contains('BOOL') or LType.Contains('BIT') or LType.Contains('LOGICAL') then Exit('Boolean');
  if LType.Contains('DECIMAL') or LType.Contains('NUMERIC') or LType.Contains('MONEY') or LType.Contains('CURRENCY') then
  begin
    if AScale = 0 then Exit('Int64');
    Exit('Currency');
  end;
  if LType.Contains('FLOAT') or LType.Contains('DOUBLE') or LType.Contains('REAL') then Exit('Double');
  if LType.Contains('DATE') or LType.Contains('TIME') then Exit('TDateTime');
  if LType.Contains('BLOB') or LType.Contains('BYTEA') or LType.Contains('BINARY') or LType.Contains('IMAGE') then Exit('TBytes');
  
  Result := 'string';
end;

function TDelphiEntityGenerator.CleanMappingName(const AName: string): string;
begin
  Result := AName.Replace('"', '').Replace('''', '').Replace('[', '').Replace(']', '').Replace('..', '.');
end;

function TDelphiEntityGenerator.GenerateUnit(const AUnitName: string; const ATables: TArray<TMetaTable>; 
  AMappingStyle: TMappingStyle = msAttributes; APropertyStyle: TPropertyStyle = psPOCO;
  AGenerateMetadata: Boolean = True): string;
var
  SB: TStringBuilder;
  Table: TMetaTable;
  Col: TMetaColumn;
  FK: TMetaForeignKey;
  ClassName, PropName, FieldName, DelphiType: string;
  RefClass, NavPropName, FinalNavName: string;
  LActualUnitName: string;
  KnownClasses: IDictionary<string, Boolean>;
begin
  // MANDATORY: Unit identifier must match file name in Delphi
  LActualUnitName := ExtractFileName(AUnitName);
  if LActualUnitName.EndsWith('.pas', True) then
     LActualUnitName := LActualUnitName.Substring(0, LActualUnitName.Length - 4);
  
  LActualUnitName := LActualUnitName.Replace(' ', '_');

  KnownClasses := TCollections.CreateDictionary<string, Boolean>;
  for Table in ATables do
    KnownClasses.AddOrSetValue('T' + CleanName(Table.Name), True);

  SB := TStringBuilder.Create;
  try
    SB.AppendLine('unit ' + LActualUnitName + ';');
    SB.AppendLine('');
    SB.AppendLine('interface');
    SB.AppendLine('');
    SB.AppendLine('uses');
    SB.AppendLine('  Dext.Entity,');
    SB.AppendLine('  Dext.Entity.Mapping,');
    if APropertyStyle = psSmart then
       SB.AppendLine('  Dext.Core.SmartTypes,');
    SB.AppendLine('  Dext.Types.Nullable,');
    SB.AppendLine('  Dext.Types.Lazy,');
    if AGenerateMetadata then
    begin
      SB.AppendLine('  Dext.Entity.TypeSystem,');
      SB.AppendLine('  Dext.Specifications.Types,');
    end;
    SB.AppendLine('  System.SysUtils,');
    SB.AppendLine('  System.Classes;');
    SB.AppendLine('');
    SB.AppendLine('type');
    SB.AppendLine('');

    for Table in ATables do
      SB.AppendLine('  T' + CleanName(Table.Name) + ' = class;');
    SB.AppendLine('');

  var TableNavMap := TCollections.CreateDictionary<string, IList<TPair<TMetaForeignKey, string>>>;
  try
    for Table in ATables do
    begin
      ClassName := 'T' + CleanName(Table.Name);
      if AMappingStyle = msAttributes then
         SB.AppendLine('  [Table(''' + CleanMappingName(Table.Name) + ''')]');
         
      SB.AppendLine('  ' + ClassName + ' = class');
      SB.AppendLine('  private');
      
      var ClassUsedNames := TCollections.CreateDictionary<string, Boolean>;
      var NavInfoList := TCollections.CreateList<TPair<TMetaForeignKey, string>>;
      TableNavMap.Add(Table.Name, NavInfoList);

      // 1. Generate Fields for Columns (MUST BE FIRST)
      for Col in Table.Columns do
      begin
        PropName := CleanName(Col.Name);
        FieldName := 'F' + PropName;
        DelphiType := SQLTypeToDelphiType(Col.DataType, Col.Scale, APropertyStyle);
        if (APropertyStyle = psPOCO) and Col.IsNullable and (DelphiType <> 'string') and (DelphiType <> 'TBytes') then
          DelphiType := 'Nullable<' + DelphiType + '>';
        SB.AppendLine('    ' + FieldName + ': ' + DelphiType + ';');
        ClassUsedNames.AddOrSetValue(PropName.ToUpper, True);
        ClassUsedNames.AddOrSetValue(FieldName.ToUpper, True);
      end;
      
      // 2. Generate Fields for Navigation (STILL FIELDS, SO STILL FIRST)
      for FK in Table.ForeignKeys do
      begin
        RefClass := 'T' + CleanName(FK.ReferencedTable);
        if not KnownClasses.ContainsKey(RefClass) then Continue;

        NavPropName := CleanName(FK.ColumnName);
        if NavPropName.EndsWith('Id', True) then NavPropName := NavPropName.Substring(0, NavPropName.Length - 2);
        if (NavPropName = '') or SameText(NavPropName, 'Id') then NavPropName := CleanName(FK.ReferencedTable);

        FinalNavName := NavPropName;
        var Suffix := 1;
        while ClassUsedNames.ContainsKey(FinalNavName.ToUpper) or 
              ClassUsedNames.ContainsKey(('FNAV' + FinalNavName).ToUpper) do
        begin
          Inc(Suffix);
          FinalNavName := NavPropName + Suffix.ToString;
        end;
        ClassUsedNames.AddOrSetValue(FinalNavName.ToUpper, True);
        ClassUsedNames.AddOrSetValue(('FNAV' + FinalNavName).ToUpper, True);
        
        NavInfoList.Add(TPair<TMetaForeignKey, string>.Create(FK, FinalNavName));
        SB.AppendLine('    FNav' + FinalNavName + ': Lazy<' + RefClass + '>;');
      end;
      
      SB.AppendLine('  public');
      
      // 3. Generate Properties for Columns
      for Col in Table.Columns do
      begin
        PropName := CleanName(Col.Name);
        var EscapedPropName := EscapeIdentifier(PropName);
        FieldName := 'F' + PropName;
        DelphiType := SQLTypeToDelphiType(Col.DataType, Col.Scale, APropertyStyle);
        if (APropertyStyle = psPOCO) and Col.IsNullable and (DelphiType <> 'string') and (DelphiType <> 'TBytes') then
          DelphiType := 'Nullable<' + DelphiType + '>';

        if AMappingStyle = msAttributes then
        begin
            var Attrs := TCollections.CreateList<string>;
            if Col.IsPrimaryKey then Attrs.Add('PK');
            if Col.IsAutoInc then Attrs.Add('AutoInc');
            if not Col.IsNullable then Attrs.Add('Required');
            if (Col.Length > 0) and (DelphiType = 'string') then Attrs.Add('MaxLength(' + Col.Length.ToString + ')');
            if (Col.Precision > 0) and ((DelphiType = 'Double') or (DelphiType = 'Currency')) then Attrs.Add(Format('Precision(%d, %d)', [Col.Precision, Col.Scale]));
            if Col.Name <> PropName then Attrs.Add('Column(''' + Col.Name + ''')');
            if Attrs.Count > 0 then SB.AppendLine('    [' + string.Join(', ', Attrs.ToArray) + ']');
        end;
        SB.AppendLine('    property ' + EscapedPropName + ': ' + DelphiType + ' read ' + FieldName + ' write ' + FieldName + ';');
      end;
      
      // 4. Generate Properties for Navigation
      for var NavInfo in NavInfoList do
      begin
        RefClass := 'T' + CleanName(NavInfo.Key.ReferencedTable);
        FinalNavName := NavInfo.Value;

         var EscapedNavName := EscapeIdentifier(FinalNavName);
         if AMappingStyle = msAttributes then
            SB.AppendLine('    [ForeignKey(''' + NavInfo.Key.ColumnName + ''')]');
         SB.AppendLine('    property ' + EscapedNavName + ': Lazy<' + RefClass + '> read FNav' + FinalNavName + ' write FNav' + FinalNavName + ';'); 
      end;
      
      SB.AppendLine('  end;');
      SB.AppendLine('');
    end;
    
    // Metadata Classes
    if AGenerateMetadata then
    begin
      for Table in ATables do
      begin
         var EntityClassName := CleanName(Table.Name) + 'Entity';
         SB.AppendLine('  ' + EntityClassName + ' = class(TEntityType<T' + CleanName(Table.Name) + '>)');
         SB.AppendLine('  public');
         for Col in Table.Columns do
            SB.AppendLine('    class var ' + EscapeIdentifier(CleanName(Col.Name)) + ': TPropExpression;');
         
         if TableNavMap.ContainsKey(Table.Name) then
         begin
           for var NavInfo in TableNavMap[Table.Name] do
              SB.AppendLine('    class var ' + EscapeIdentifier(NavInfo.Value) + ': TPropExpression;');
         end;

         SB.AppendLine('');
         SB.AppendLine('    class constructor Create;');
         SB.AppendLine('  end;');
         SB.AppendLine('');
      end;
    end;

    if (AMappingStyle = msFluent) then 
      SB.AppendLine('procedure RegisterMappings(ModelBuilder: TModelBuilder);' + sLineBreak);
    
    SB.AppendLine('implementation' + sLineBreak);
    
    if (AMappingStyle = msFluent) then
    begin
       SB.AppendLine('procedure RegisterMappings(ModelBuilder: TModelBuilder);' + sLineBreak + 'begin');
       for Table in ATables do
       begin
          ClassName := 'T' + CleanName(Table.Name);
          SB.AppendLine('  ModelBuilder.Entity<' + ClassName + '>.Table(''' + CleanMappingName(Table.Name) + ''')');
          for Col in Table.Columns do
          begin
             PropName := CleanName(Col.Name);
             if Col.IsPrimaryKey then SB.AppendLine('    .HasKey(''' + PropName + ''')');
             if not SameText(Col.Name, PropName) then SB.AppendLine('    .Prop(''' + PropName + ''').Column(''' + Col.Name + ''')');
             if not Col.IsNullable then SB.AppendLine('    .Prop(''' + PropName + ''').IsRequired');
             if (Col.Length > 0) and (CleanName(Col.DataType).Contains('CHAR') or CleanName(Col.DataType).Contains('TEXT')) then SB.AppendLine('    .Prop(''' + PropName + ''').MaxLength(' + Col.Length.ToString + ')');
             if (Col.Precision > 0) then SB.AppendLine(Format('    .Prop(''%s'').Precision(%d, %d)', [PropName, Col.Precision, Col.Scale]));
          end;
          
          if TableNavMap.ContainsKey(Table.Name) then
          begin
            for var NavInfo in TableNavMap[Table.Name] do
               SB.AppendLine('    .Prop(''' + NavInfo.Value + ''').HasForeignKey(''' + NavInfo.Key.ColumnName + ''')');
          end;
          SB.AppendLine('    ;');
       end;
       SB.AppendLine('end;' + sLineBreak);
    end;
    
    if AGenerateMetadata then
    begin
      for Table in ATables do
      begin
         var EntityClassName := CleanName(Table.Name) + 'Entity';
         SB.AppendLine('class constructor ' + EntityClassName + '.Create;' + sLineBreak + 'begin');
         for Col in Table.Columns do SB.AppendLine('  ' + EscapeIdentifier(CleanName(Col.Name)) + ' := TPropExpression.Create(''' + CleanName(Col.Name) + ''');');
         
         if TableNavMap.ContainsKey(Table.Name) then
         begin
           for var NavInfo in TableNavMap[Table.Name] do
              SB.AppendLine('  ' + EscapeIdentifier(NavInfo.Value) + ' := TPropExpression.Create(''' + NavInfo.Value + ''');');
         end;
         SB.AppendLine('end;');
         SB.AppendLine('');
      end;
    end;
    
    SB.AppendLine('end.');
    Result := SB.ToString;
  finally
    TableNavMap := nil;
  end;
finally
  SB.Free;
end;
end;

end.
