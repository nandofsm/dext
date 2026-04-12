unit Dext.Web.Hosting.Tests;

interface

uses
  System.SysUtils,
  Dext.Testing.Attributes,
  Dext.Assertions,
  Dext.Web,
  Dext.Web.Interfaces;

type
  [TestFixture('Web Hosting & Dynamic Ports Tests (S08)')]
  TWebHostingTests = class
  public
    [Test('Should start server on dynamic port (Port 0)')]
    procedure TestDynamicPortAssignment;
  end;

implementation

{ TWebHostingTests }

procedure TWebHostingTests.TestDynamicPortAssignment;
var
  App: IWebApplication;
begin
  App := WebApplication;
  try
    // Act: Start with Port 0
    App.Start(0);
    
    try
      // Assert: Port should be > 0 and not 0 anymore
      Should(App.Port).BeGreaterThan(0);
      Should(App.Port).NotBe(0);
    finally
      App.Stop;
    end;
  finally
    App := nil;
  end;
end;

end.
