unit App.Context;

interface

uses
  Dext.Entity,
  Dext.Entity.Core, // Explicitly needed for IDbSet<T> if not aliased in Dext.Entity
  App.Entities;

type
  TAppDbContext = class(TDbContext)
  private
    function GetProducts: IDbSet<TProduct>;
  public
    // Use IDbSet<T> instead of TDbSet<T>
    property Products: IDbSet<TProduct> read GetProducts;
  end;

implementation

{ TAppDbContext }

function TAppDbContext.GetProducts: IDbSet<TProduct>;
begin
  // Use the Entities<T> method from TDbContext
  Result := Entities<TProduct>;
end;

end.
