unit Dext.EF.Design.Metadata;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.Collections,
  Dext.Collections.Base,
  Dext.Entity.Core,
  Dext.Entity.DataProvider,
  Dext.Entity.Metadata;
  
/// <summary>
///   Design-time helper to refresh metadata from source code using the canonical parser.
/// </summary>
procedure RefreshProviderMetadata(AProvider: TEntityDataProvider);

implementation

uses
  System.IOUtils,
  System.Types,
  Winapi.Windows;

procedure RefreshProviderMetadata(AProvider: TEntityDataProvider);
var
  Parser: TEntityMetadataParser;
  ParsedList: IList<TEntityClassMetadata>;
  ParsedCollection: ICollection;
  FileName, Content: string;
  MD: TEntityClassMetadata;
begin
  if AProvider = nil then
    Exit;

  AProvider.ClearMetadata;
  Parser := TEntityMetadataParser.Create;
  try
    for FileName in AProvider.ModelUnits do
    begin

      Content := '';
      if Assigned(GOnGetSourceContent) then
        Content := GOnGetSourceContent(FileName);

      ParsedList := Parser.ParseUnit(FileName, Content);
      try
        for MD in ParsedList do
        begin
          AProvider.AddOrSetMetadata(MD);
          for var I := 0 to MD.Members.Count - 1 do
          begin
            var Member := MD.Members[I];
          end;
        end;

        if Supports(ParsedList, ICollection, ParsedCollection) then
          ParsedCollection.OwnsObjects := False;
      finally
        // ParsedList cleaned by interface
      end;
    end;
  finally
    Parser.Free;
  end;

  AProvider.UpdateRefreshSummary;
end;

end.
