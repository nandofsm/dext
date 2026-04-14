unit Dext.CLI.App;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  System.Types,
  System.StrUtils,
  FireDAC.Comp.Client,
  Dext.Templating,
  Dext.Entity.Drivers.Interfaces,
  Dext.Entity.Drivers.FireDAC,
  Dext.Entity.Scaffolding,
  Dext.Entity.TemplatedScaffolding;

type
  IConsoleCommand = interface
    ['{B1B2C3D4-E5F6-4789-0123-456789ABCDEF}']
    function GetName: string;
    function GetVerb: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

  TDextCLI = class
  private
    FCommands: TList<IConsoleCommand>;
    function FindCommand(const AVerb, AName: string): IConsoleCommand;
    procedure RegisterCommands;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ShowHelp;
    function Run: Boolean;
  end;

  TScaffoldModel = class
  private
    FEntityName: string;
    FTableName: string;
  public
    property EntityName: string read FEntityName write FEntityName;
    property TableName: string read FTableName write FTableName;
  end;

  // --- Commands ---

  TAddEntityCommand = class(TInterfacedObject, IConsoleCommand)
  public
    function GetVerb: string;
    function GetName: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

  TAddControllerCommand = class(TInterfacedObject, IConsoleCommand)
  public
    function GetVerb: string;
    function GetName: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

  TAddServiceCommand = class(TInterfacedObject, IConsoleCommand)
  public
    function GetVerb: string;
    function GetName: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

  TScaffoldDbCommand = class(TInterfacedObject, IConsoleCommand)
  private
    function GetArg(const Args: TArray<string>; const Name, ShortName: string; const Default: string = ''): string;
    function ResolveTemplatePath(const ATemplateName: string): string;
  public
    function GetVerb: string;
    function GetName: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

  TNewProjectCommand = class(TInterfacedObject, IConsoleCommand)
  private
    procedure ProcessDirectory(const ASourceDir, ADestDir: string; AContext: ITemplateContext; AEngine: ITemplateEngine);
  public
    function GetVerb: string;
    function GetName: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

implementation

{ TDextCLI }

constructor TDextCLI.Create;
begin
  FCommands := TList<IConsoleCommand>.Create;
  RegisterCommands;
end;

destructor TDextCLI.Destroy;
begin
  FCommands.Free;
  inherited;
end;

function TDextCLI.FindCommand(const AVerb, AName: string): IConsoleCommand;
begin
  Result := nil;
  for var Cmd in FCommands do
  begin
    if SameText(Cmd.GetVerb, AVerb) and SameText(Cmd.GetName, AName) then
      Exit(Cmd);
  end;
end;

procedure TDextCLI.RegisterCommands;
begin
  FCommands.Add(TAddEntityCommand.Create);
  FCommands.Add(TAddControllerCommand.Create);
  FCommands.Add(TAddServiceCommand.Create);
  FCommands.Add(TScaffoldDbCommand.Create);
  FCommands.Add(TNewProjectCommand.Create);
end;

procedure TDextCLI.ShowHelp;
begin
  var Exe := ExtractFileName(ParamStr(0));
  WriteLn('Dext Framework CLI');
  WriteLn('------------------');
  WriteLn('Usage: ' + Exe + ' <verb> <command> [args]');
  WriteLn('');
  WriteLn('Available Commands:');
  for var Cmd in FCommands do
  begin
    var FullCmd := Cmd.GetVerb + ' ' + Cmd.GetName;
    WriteLn('  ' + FullCmd.PadRight(25) + Cmd.GetDescription);
  end;
  WriteLn('');
end;

function TDextCLI.Run: Boolean;
var
  Verb, Name: string;
  Args: TArray<string>;
  Cmd: IConsoleCommand;
begin
  if ParamCount < 2 then
    Exit(False);

  Verb := ParamStr(1).ToLower;
  Name := ParamStr(2).ToLower;
  
  Cmd := FindCommand(Verb, Name);
  if Assigned(Cmd) then
  begin
    SetLength(Args, ParamCount - 2);
    for var i := 3 to ParamCount do
      Args[i - 3] := ParamStr(i);
      
    Cmd.Execute(Args);
    Result := True;
  end
  else
  begin
    WriteLn('Unknown command: ' + Verb + ' ' + Name);
    ShowHelp;
    Result := True;
  end;
end;

{ TAddEntityCommand }

function TAddEntityCommand.GetDescription: string;
begin
  Result := 'Adds a new entity class using a template';
end;

function TAddEntityCommand.GetName: string;
begin
  Result := 'entity';
end;

function TAddEntityCommand.GetVerb: string;
begin
  Result := 'add';
end;

function ResolveTemplate(const ATemplateName: string): string;
begin
  // 1. Local path: .\Templates
  Result := TPath.Combine(TPath.Combine(GetCurrentDir, 'Templates'), ATemplateName);
  if TFile.Exists(Result) then Exit;
  
  // 2. User path: %USERPROFILE%\.dext\Templates
  var HomeDir := TPath.GetHomePath;
  Result := TPath.Combine(TPath.Combine(HomeDir, '.dext'), TPath.Combine('Templates', ATemplateName));
  if TFile.Exists(Result) then Exit;
  
  // 3. Framework path: $(DEXT)\Templates
  var DextRoot := GetEnvironmentVariable('DEXT');
  if DextRoot <> '' then
  begin
    Result := TPath.Combine(TPath.Combine(DextRoot, 'Templates'), ATemplateName);
    if TFile.Exists(Result) then Exit;
  end;
  
  // 4. Default fallback (relative to EXE for local dev)
  Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Templates\Basic\' + ATemplateName));
  if not TFile.Exists(Result) then
    Result := '';
end;

procedure TAddEntityCommand.Execute(const Args: TArray<string>);
var
  EntityName, TableName: string;
  TemplatePath: string;
  TemplateContent: string;
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
  OutputFile: string;
begin
  if Length(Args) = 0 then
  begin
    WriteLn('Usage: dext add entity <EntityName> [TableName]');
    Exit;
  end;

  EntityName := Args[0];
  if Length(Args) > 1 then
    TableName := Args[1]
  else
    TableName := EntityName.ToLower + 's';

  // Heuristic for template location (3-level lookup)
  TemplatePath := ResolveTemplate('entity.pas.template');

  if TemplatePath = '' then
  begin
    WriteLn('Error: Template entity.pas.template not found in any search path.');
    WriteLn('Search paths: ./Templates, ~/.dext/Templates, $(DEXT)/Templates');
    Exit;
  end;

  WriteLn('Using template: ' + TemplatePath);
  WriteLn('Generating entity ' + EntityName + '...');
  
  TemplateContent := TFile.ReadAllText(TemplatePath);
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;

  var ModelObj := TScaffoldModel.Create;
  ModelObj.EntityName := EntityName;
  ModelObj.TableName := TableName;
  
  Context.SetObject('Model', ModelObj); 

  Output := Engine.Render(TemplateContent, Context);
  
  OutputFile := EntityName + '.pas';
  TFile.WriteAllText(OutputFile, Output);
  
  WriteLn('File generated successfully: ' + OutputFile);
  ModelObj.Free;
end;

{ TAddControllerCommand }

function TAddControllerCommand.GetDescription: string;
begin
  Result := 'Adds a new Controller to the current project';
end;

function TAddControllerCommand.GetName: string;
begin
  Result := 'controller';
end;

function TAddControllerCommand.GetVerb: string;
begin
  Result := 'add';
end;

procedure TAddControllerCommand.Execute(const Args: TArray<string>);
var
  Name, EntityName, TemplatePath, OutputFile: string;
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Model: TScaffoldViewModel;
  Table: TTableViewModel;
begin
  if Length(Args) = 0 then
  begin
    WriteLn('Usage: dext add controller <Name> [--entity <EntityName>]');
    Exit;
  end;

  Name := Args[0];
  EntityName := '';
  for var i := 1 to High(Args) - 1 do
    if SameText(Args[i], '--entity') then EntityName := Args[i + 1];

  TemplatePath := ResolveTemplate('controller.pas.template');
  if TemplatePath = '' then
  begin
    WriteLn('Error: controller.pas.template not found.');
    Exit;
  end;

  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  Model := TScaffoldViewModel.Create;
  try
    Model.DelphiNamespace := 'MyProject'; // Should ideally be read from config
    Table := TTableViewModel.Create;
    Table.Name := Name;
    Table.DelphiNamespace := Model.DelphiNamespace;
    if EntityName <> '' then
    begin
       Table.DelphiUnitName := EntityName; // Simplified for now
       // Here we would ideally load the entity metadata if it matches
    end;
    Model.Tables.Add(Table);
    
    Context.SetObject('Model', Table); // For the template
    Context.SetVariable('Name', Name);
    Context.SetVariable('Namespace', Model.DelphiNamespace);

    var Output := Engine.Render(TFile.ReadAllText(TemplatePath), Context);
    OutputFile := Name + 'Controller.pas';
    TFile.WriteAllText(OutputFile, Output);
    WriteLn('Controller created: ' + OutputFile);
  finally
    Model.Free;
  end;
end;

{ TAddServiceCommand }

function TAddServiceCommand.GetDescription: string;
begin
  Result := 'Adds a new Service to the current project';
end;

function TAddServiceCommand.GetName: string;
begin
  Result := 'service';
end;

function TAddServiceCommand.GetVerb: string;
begin
  Result := 'add';
end;

procedure TAddServiceCommand.Execute(const Args: TArray<string>);
var
  Name, TemplatePath, OutputFile: string;
begin
  if Length(Args) = 0 then
  begin
    WriteLn('Usage: dext add service <Name>');
    Exit;
  end;

  Name := Args[0];
  TemplatePath := ResolveTemplate('service.pas.template');
  if TemplatePath = '' then Exit;

  var Engine := TTemplating.CreateEngine;
  var Context := TTemplating.CreateContext;
  Context.SetVariable('Name', Name);
  Context.SetVariable('Namespace', 'MyProject');
  Context.SetVariable('ProjectGUID', '{' + TGuid.NewGuid.ToString.ToUpper + '}');

  var Output := Engine.Render(TFile.ReadAllText(TemplatePath), Context);
  OutputFile := Name + 'Service.pas';
  TFile.WriteAllText(OutputFile, Output);
  WriteLn('Service created: ' + OutputFile);
end;

{ TScaffoldDbCommand }

function TScaffoldDbCommand.ResolveTemplatePath(const ATemplateName: string): string;
begin
  Result := ResolveTemplate(ATemplateName);
end;

function TScaffoldDbCommand.GetArg(const Args: TArray<string>; const Name, ShortName: string; const Default: string): string;
begin
  Result := Default;
  for var i := 0 to High(Args) - 1 do
  begin
    if SameText(Args[i], Name) or SameText(Args[i], ShortName) then
      Exit(Args[i + 1]);
  end;
end;

function TScaffoldDbCommand.GetDescription: string;
begin
  Result := 'Generates entity classes from an existing database';
end;

function TScaffoldDbCommand.GetName: string;
begin
  Result := 'db';
end;

function TScaffoldDbCommand.GetVerb: string;
begin
  Result := 'scaffold';
end;

procedure TScaffoldDbCommand.Execute(const Args: TArray<string>);
var
  ConnStr, OutDir, TemplatePath: string;
  Connection: IDbConnection;
  Provider: ISchemaProvider;
  Generator: TTemplatedEntityGenerator;
begin
  ConnStr := GetArg(Args, '--connection', '-c');
  OutDir := GetArg(Args, '--output', '-o', 'Generated');
  var UserTemplate := GetArg(Args, '--template', '-t');
  if UserTemplate <> '' then
    TemplatePath := UserTemplate
  else
    TemplatePath := ResolveTemplatePath('entity.pas.template');

  if TemplatePath = '' then
  begin
    WriteLn('Error: Template entity.pas.template not found.');
    Exit;
  end;

  WriteLn('Connecting to database...');
  try
    var FDConn := TFDConnection.Create(nil);
    FDConn.ConnectionString := ConnStr;
    Connection := TFireDACConnection.Create(FDConn);
    try
      Provider := TFireDACSchemaProvider.Create(Connection);
      Generator := TTemplatedEntityGenerator.Create;
      try
        WriteLn('Scanning schema and generating code...');
        Generator.Generate(Provider, TemplatePath, OutDir, gmMultipleFiles);
        WriteLn('Successfully generated entities in: ' + OutDir);
      finally
        Generator.Free;
      end;
    finally
      // Connection is interface, will be freed
    end;
  except
    on E: Exception do
      WriteLn('Error: ' + E.Message);
  end;
end;

{ TNewProjectCommand }

function TNewProjectCommand.GetDescription: string;
begin
  Result := 'Creates a new Dext project from a template (web, console, desktop)';
end;

function TNewProjectCommand.GetName: string;
begin
  Result := 'project';
end;

function TNewProjectCommand.GetVerb: string;
begin
  Result := 'new';
end;

procedure TNewProjectCommand.ProcessDirectory(const ASourceDir, ADestDir: string; AContext: ITemplateContext; AEngine: ITemplateEngine);
var
  FileName, TargetName: string;
begin
  if not TDirectory.Exists(ADestDir) then
    TDirectory.CreateDirectory(ADestDir);

  for FileName in TDirectory.GetFiles(ASourceDir) do
  begin
    var BaseName := TPath.GetFileName(FileName);
    if BaseName.EndsWith('.template', True) then
    begin
      TargetName := BaseName.Substring(0, BaseName.Length - 9);
      // Replace placeholder ProjectName in filename if present
      TargetName := TargetName.Replace('Project', AContext.GetVariable('ProjectName').AsString);
      
      var Content := TFile.ReadAllText(FileName);
      var Rendered := AEngine.Render(Content, AContext);
      TFile.WriteAllText(TPath.Combine(ADestDir, TargetName), Rendered);
    end
    else
    begin
      TFile.Copy(FileName, TPath.Combine(ADestDir, BaseName), True);
    end;
  end;

  for var SubDir in TDirectory.GetDirectories(ASourceDir) do
  begin
    var DirName := TPath.GetFileName(SubDir);
    ProcessDirectory(SubDir, TPath.Combine(ADestDir, DirName), AContext, AEngine);
  end;
end;

procedure TNewProjectCommand.Execute(const Args: TArray<string>);
var
  ProjType, ProjName, DestDir: string;
  SourceTemplateDir: string;
  Engine: ITemplateEngine;
  Context: ITemplateContext;
begin
  if Length(Args) < 2 then
  begin
    WriteLn('Usage: dext new project <type> <name>');
    WriteLn('Types: web, console, desktop');
    Exit;
  end;

  ProjType := Args[0].ToLower;
  ProjName := Args[1];
  DestDir := TPath.Combine(GetCurrentDir, ProjName);

  if TDirectory.Exists(DestDir) then
  begin
    WriteLn('Error: Directory ' + ProjName + ' already exists.');
    Exit;
  end;

  // Resolve Template Directory
  // 1. Framework path: $(DEXT)\Templates\Projects\<type>
  var DextRoot := GetEnvironmentVariable('DEXT');
  SourceTemplateDir := '';
  
  if DextRoot <> '' then
  begin
    var Path := TPath.Combine(TPath.Combine(DextRoot, 'Templates'), TPath.Combine('Projects', ProjType));
    if TDirectory.Exists(Path) then SourceTemplateDir := Path;
  end;

  // 2. Fallback to local dev path (relative to EXE)
  if SourceTemplateDir = '' then
  begin
     SourceTemplateDir := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Templates\Projects\' + ProjType));
  end;

  if not TDirectory.Exists(SourceTemplateDir) then
  begin
    WriteLn('Error: Template for project type "' + ProjType + '" not found in ' + SourceTemplateDir);
    Exit;
  end;

  WriteLn('Creating new ' + ProjType + ' project: ' + ProjName + '...');
  WriteLn('Using template: ' + SourceTemplateDir);

  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Context.SetVariable('ProjectName', ProjName);
  Context.SetVariable('ProjectGUID', '{' + TGuid.NewGuid.ToString.ToUpper + '}');
  Context.SetVariable('DextVersion', '1.0.0');

  try
    ProcessDirectory(SourceTemplateDir, DestDir, Context, Engine);
    WriteLn('Project ' + ProjName + ' created successfully in ' + DestDir);
  except
    on E: Exception do
      WriteLn('Error creating project: ' + E.Message);
  end;
end;

end.
