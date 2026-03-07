unit Customer;

interface

uses
  Dext.Entity,
  Dext.Core.SmartTypes;

type
  [Table('Customers')]
  TCustomer = class
  private
    FId: IntType;
    FName: StringType;
    FEmail: StringType;
    function GetEmail: StringType;
    function GetId: IntType;
    function GetName: StringType;
  public
    [PK, AutoInc]
    property Id: IntType read GetId write FId;
    property Name: StringType read GetName write FName;
    property Email: StringType read GetEmail write FEmail;
  end;

implementation

function TCustomer.GetEmail: StringType;
begin
  Result := FEmail;
end;

function TCustomer.GetId: IntType;
begin
  Result := FId;
end;

function TCustomer.GetName: StringType;
begin
  Result := FName;
end;

end.
