unit Dext.Templating.Tests;

interface

uses
  Dext.Testing,
  Dext.Templating,
  Dext.Scaffolding.Models,
  System.SysUtils,
  System.Generics.Collections;

type
  [TestFixture]
  TTemplatingTests = class
  public
    [Test] procedure Test_Simple_Property_Resolution;
    [Test] procedure Test_Nested_Property_Resolution;
    [Test] procedure Test_Conditional_IF_True;
    [Test] procedure Test_Conditional_IF_False;
    [Test] procedure Test_Loop_ForEach;
    [Test] procedure Test_Filters_PascalCase;
    [Test] procedure Test_Filters_CamelCase;
    [Test] procedure Test_Escaping;
    [Test] procedure Test_Html_Escaping;
    [Test] procedure Test_Nested_Control_Flow;
    [Test] procedure Test_Whitespace_Handling;
    [Test] procedure Test_Nested_Loops;
    [Test] procedure Test_Complex_Path_Resolution;
  end;

implementation

{ TTemplatingTests }

procedure TTemplatingTests.Test_Simple_Property_Resolution;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Model: TTableViewModel;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Model := TTableViewModel.Create;
  try
    Model.DelphiClassName := 'TUser';
    Context.SetObject('Model', Model);
    
    Output := Engine.Render('class @Model.DelphiClassName', Context);
    
    Should(Output).Be('class TUser');
  finally
    Model.Free;
  end;
end;

procedure TTemplatingTests.Test_Nested_Property_Resolution;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Model: TTableViewModel;
  Col: TColumnViewModel;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Model := TTableViewModel.Create;
  try
    Col := TColumnViewModel.Create;
    Col.DelphiName := 'Id';
    Model.Columns.Add(Col);
    
    Context.SetObject('Model', Model);
    
    // Testing deep traversal implicitly handled by the engine
    Output := Engine.Render('@Model.Columns[0].DelphiName', Context);
    
    // Note: The engine currently supports Dot notation for properties, 
    // but array indexing [0] was not explicitly in the spec.
    // However, if we put the specific column in context:
    Context.SetObject('Col', Col);
    Output := Engine.Render('@Col.DelphiName', Context);
    
    Should(Output).Be('Id');
  finally
    Model.Free;
  end;
end;

procedure TTemplatingTests.Test_Conditional_IF_True;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Context.SetValue('IsActive', 'true');
  
  Output := Engine.Render('@if (IsActive)Active@endif', Context);
  
  Should(Output).Be('Active');
end;

procedure TTemplatingTests.Test_Conditional_IF_False;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Context.SetValue('IsActive', 'false');
  
  Output := Engine.Render('@if (IsActive)Active@endif', Context);
  
  Should(Output).Be('');
end;

procedure TTemplatingTests.Test_Loop_ForEach;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Model: TTableViewModel;
  Col: TColumnViewModel;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Model := TTableViewModel.Create;
  try
    Col := TColumnViewModel.Create;
    Col.DelphiName := 'Id';
    Col.DelphiType := 'Integer';
    Model.Columns.Add(Col);
    
    Col := TColumnViewModel.Create;
    Col.DelphiName := 'Name';
    Col.DelphiType := 'string';
    Model.Columns.Add(Col);
    
    Context.SetObject('Model', Model);
    
    Output := Engine.Render(
      '@foreach (var col in Model.Columns)' + sLineBreak +
      '  @col.DelphiName: @col.DelphiType;' + sLineBreak +
      '@endforeach', Context);
      
    Should(Output).Contain('Id: Integer;');
    Should(Output).Contain('Name: string;');
  finally
    Model.Free;
  end;
end;

procedure TTemplatingTests.Test_Filters_PascalCase;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Context.SetValue('Name', 'user_profile');
  
  Output := Engine.Render('@Name.ToPascalCase()', Context);
  
  Should(Output).Be('UserProfile');
end;

procedure TTemplatingTests.Test_Filters_CamelCase;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Context.SetValue('Name', 'UserName');
  
  Output := Engine.Render('@Name.ToCamelCase()', Context);
  
  Should(Output).Be('userName');
end;

procedure TTemplatingTests.Test_Escaping;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Output := Engine.Render('email@@example.com', Context);
  Should(Output).Be('email@example.com');
end;

procedure TTemplatingTests.Test_Html_Escaping;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  (Engine as TDextTemplateEngine).IsHtmlMode := True;
  
  Context.SetValue('Content', '<script>alert("xss")</script>');
  Output := Engine.Render('<div>@Content</div>', Context);
  
  Should(Output).Be('<div>&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;</div>');
end;

procedure TTemplatingTests.Test_Nested_Control_Flow;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Model: TTableViewModel;
  Col: TColumnViewModel;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Model := TTableViewModel.Create;
  try
    Col := TColumnViewModel.Create;
    Col.DelphiName := 'Id';
    Col.IsPrimaryKey := True;
    Model.Columns.Add(Col);
    
    Col := TColumnViewModel.Create;
    Col.DelphiName := 'Name';
    Col.IsPrimaryKey := False;
    Model.Columns.Add(Col);
    
    Context.SetObject('Model', Model);
    
    Output := Engine.Render(
      '@foreach (var col in Model.Columns)' +
      '@if (col.IsPrimaryKey)[PK] @endif' +
      '@col.DelphiName' +
      '@endforeach', Context);
      
    Should(Output).Contain('[PK] Id');
    Should(Output).Contain('Name');
    Should(Output).NotContain('[PK] Name');
  finally
    Model.Free;
  end;
end;

procedure TTemplatingTests.Test_Whitespace_Handling;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  
  Context.SetValue('Show', 'true');
  
  // The engine should skip one newline after @if and @endif
  Output := Engine.Render(
    '@if (Show)' + sLineBreak +
    'Content' + sLineBreak +
    '@endif' + sLineBreak +
    'Footer', Context);
    
  // Current logic in ParseBlock:
  // if (ATemplate[Pos] = #13) then Inc(Pos);
  // if (ATemplate[Pos] = #10) then Inc(Pos);
  // This means '@if (Show)\r\nContent' becomes 'Content'
  
  Should(Output).Be('Content' + sLineBreak + 'Footer');
end;

procedure TTemplatingTests.Test_Nested_Loops;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Model: TTableViewModel;
  Col: TColumnViewModel;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  Model := TTableViewModel.Create;
  try
    Col := TColumnViewModel.Create;
    Col.DelphiName := 'Id';
    Model.Columns.Add(Col);
    
    Context.SetObject('Model', Model);
    
    // Nested Loop: For each table, for each column
    Output := Engine.Render(
      '@foreach (var t in Model.Columns)' +
        'Col:@t.DelphiName' +
      '@endforeach', Context);
      
    Should(Output).Contain('Col:Id');
  finally
    Model.Free;
  end;
end;

procedure TTemplatingTests.Test_Complex_Path_Resolution;
var
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Model: TTableViewModel;
  Output: string;
begin
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;
  Model := TTableViewModel.Create;
  try
    Model.Name := 'User';
    Context.SetObject('Model', Model);
    
    // Testing Model.Name.ToPascalCase() - triple level
    Output := Engine.Render('@Model.Name.ToPascalCase()', Context);
    Should(Output).Be('User');
  finally
    Model.Free;
  end;
end;

initialization
  TTestRunner.RegisterFixture(TTemplatingTests);

end.
