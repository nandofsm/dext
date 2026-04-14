unit App.Entities;

interface

uses
  Dext.Entity, // Provides attributes via aliases (Table, Column, PK, AutoInc, Required, MaxLength, Precision)
  Dext.Core.SmartTypes; // Provides Prop<T>, StringType, etc.

type
  [Table('Products')]
  TProduct = class
  private
    FId: Int64;
    FName: StringType;
    FPrice: CurrencyType;
    FIsActive: BoolType;
  public
    [PK, AutoInc]
    property Id: Int64 read FId write FId;

    [Column('Name'), Required, MaxLength(100)]
    property Name: StringType read FName write FName;

    [Column('Price'), Precision(18, 2)]
    property Price: CurrencyType read FPrice write FPrice;

    [Column('IsActive')]
    property IsActive: BoolType read FIsActive write FIsActive;
  end;

implementation

end.
