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

unit Dext.Entity.Scaffolding.Processor;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.Collections,
  Dext.Utils,
  Dext.Entity.Scaffolding,
  Dext.Scaffolding.Models;

type
  TScaffoldingMetadataProcessor = class
  private
    FModels: TScaffoldViewModel;
    function FindTableViewModel(const ATableName: string): TTableViewModel;
    function IsPureJoinTable(const AMeta: TMetaTable): Boolean;
  public
    constructor Create(AModels: TScaffoldViewModel);
    procedure Process(const AMeta: TArray<TMetaTable>);
  end;

implementation

{ TScaffoldingMetadataProcessor }

constructor TScaffoldingMetadataProcessor.Create(AModels: TScaffoldViewModel);
begin
  FModels := AModels;
end;

function TScaffoldingMetadataProcessor.FindTableViewModel(const ATableName: string): TTableViewModel;
begin
  for var Table in FModels.Tables do
    if SameText(Table.Name, ATableName) then
      Exit(Table);
  Result := nil;
end;

function TScaffoldingMetadataProcessor.IsPureJoinTable(const AMeta: TMetaTable): Boolean;
begin
  Result := (Length(AMeta.Columns) = 2) and (Length(AMeta.ForeignKeys) = 2) and
            (AMeta.Columns[0].IsPrimaryKey) and (AMeta.Columns[1].IsPrimaryKey);
  
  if Result then
  begin
    // Double check both cols are FKs
    var FK1 := False;
    var FK2 := False;
    for var FK in AMeta.ForeignKeys do
    begin
      if SameText(FK.ColumnName, AMeta.Columns[0].Name) then FK1 := True;
      if SameText(FK.ColumnName, AMeta.Columns[1].Name) then FK2 := True;
    end;
    Result := FK1 and FK2;
  end;
end;

procedure TScaffoldingMetadataProcessor.Process(const AMeta: TArray<TMetaTable>);
begin
  for var TableMeta in AMeta do
  begin
    var TableVM := FindTableViewModel(TableMeta.Name);
    if IsPureJoinTable(TableMeta) then
    begin
      if TableVM <> nil then
        TableVM.IsJoinTable := True;

      // Identify the two sides of the relationship
      var FK1 := TableMeta.ForeignKeys[0];
      var FK2 := TableMeta.ForeignKeys[1];

      var VM1 := FindTableViewModel(FK1.ReferencedTable);
      var VM2 := FindTableViewModel(FK2.ReferencedTable);

      if (VM1 <> nil) and (VM2 <> nil) then
      begin
        // Add M2M to VM1
        var M2M1 := TManyToManyViewModel.Create;
        var BaseName := VM2.DelphiClassName.Substring(1);
        M2M1.PropertyName := BaseName;
        if not M2M1.PropertyName.EndsWith('s', True) then
          M2M1.PropertyName := M2M1.PropertyName + 's';
        
        if M2M1.PropertyName.EndsWith('ys', True) then 
          M2M1.PropertyName := M2M1.PropertyName.Substring(0, M2M1.PropertyName.Length-2) + 'ies';
        
        M2M1.TargetClass := VM2.DelphiClassName;
        M2M1.JoinTable := TableMeta.Name;
        M2M1.SourceColumn := FK1.ColumnName;
        M2M1.TargetColumn := FK2.ColumnName;
        VM1.ManyToMany.Add(M2M1);

        // Add M2M to VM2 (Bidirectional)
        var M2M2 := TManyToManyViewModel.Create;
        BaseName := VM1.DelphiClassName.Substring(1);
        M2M2.PropertyName := BaseName;
        if not M2M2.PropertyName.EndsWith('s', True) then
          M2M2.PropertyName := M2M2.PropertyName + 's';

        if M2M2.PropertyName.EndsWith('ys', True) then 
          M2M2.PropertyName := M2M2.PropertyName.Substring(0, M2M2.PropertyName.Length-2) + 'ies';
        
        M2M2.TargetClass := VM1.DelphiClassName;
        M2M2.JoinTable := TableMeta.Name;
        M2M2.SourceColumn := FK2.ColumnName;
        M2M2.TargetColumn := FK1.ColumnName;
        VM2.ManyToMany.Add(M2M2);
      end;
    end;
  end;
end;

end.
