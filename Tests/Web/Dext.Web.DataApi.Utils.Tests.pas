unit Dext.Web.DataApi.Utils.Tests;

interface

uses
  Dext.Testing,
//  Dext.Assertions,
  Dext.Web.DataApi.Utils,
  System.TypInfo;

type
  TCustomer = class;
  TCategory = class;
  TAddress = class;
  TBus = class;
  TMatch = class;

  [TestFixture]
  TDataApiNamingTests = class
  public
    [Test]
    procedure Test_Pluralization_Rules;
  end;

  TCustomer = class end;
  TCategory = class end;
  TAddress = class end;
  TBus = class end;
  TMatch = class end;

implementation

{ TDataApiNamingTests }

procedure TDataApiNamingTests.Test_Pluralization_Rules;
begin
  // Standard plural
  Should('Customers').Be(TDataApiNaming.GetEntityTag(TypeInfo(TCustomer)));
  
  // -y -> -ies
  Should('Categories').Be(TDataApiNaming.GetEntityTag(TypeInfo(TCategory)));

  // -ss -> -sses
  Should('Addresses').Be(TDataApiNaming.GetEntityTag(TypeInfo(TAddress)));

  // -s -> -ses
  Should('Buses').Be(TDataApiNaming.GetEntityTag(TypeInfo(TBus)));

  // -ch -> -ches
  Should('Matches').Be(TDataApiNaming.GetEntityTag(TypeInfo(TMatch)));
end;

end.
