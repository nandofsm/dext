# Smart Properties Demo

This example demonstrates **Smart Properties** - a revolutionary feature that enables type-safe, IntelliSense-friendly database queries with automatic SQL generation.

## 🚀 Features Demonstrated

| Feature | Description |
|---------|-------------|
| **Smart Types** | `StringType`, `CurrencyType`, `BoolType` - typed wrappers with operator overloading |
| **Fluent Query** | `u.Price > 100` translates directly to SQL `WHERE Price > 100` |
| **Prototype Entity** | `Prototype.Entity<T>` creates type-safe expression builders |
| **Model Binding + DI** | `MapPost<TDbContext, TEntity, IResult>` with automatic injection |
| **ORM Attributes** | `[PK, AutoInc]`, `[Required]`, `[MaxLength]`, `[Precision]` |

## 🛠️ Getting Started

1. **Compile** `Web.SmartPropsDemo.dproj`
2. **Run** `Web.SmartPropsDemo.exe`
   - SQLite file database (`smart_props.db`) is created automatically
   - Server starts on **http://localhost:5000**
3. **Test**:
   ```powershell
   .\Test.Web.SmartPropsDemo.ps1
   ```

## 📍 Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/products` | List products where `Price > 100` |
| `POST` | `/products` | Create new product (JSON body → Entity) |

## 💡 Code Highlights

### Smart Property Entity Definition
```delphi
uses
  Dext.Core.SmartTypes;  // StringType, CurrencyType, BoolType

[Table('Products')]
TProduct = class
private
  FId: Int64;
  FName: StringType;      // Smart String
  FPrice: CurrencyType;   // Smart Currency
  FIsActive: BoolType;    // Smart Boolean
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
```

### Type-Safe Fluent Query
```delphi
uses
  Dext.Entity.Prototype;

// Create prototype for type-safe expressions
var u := Prototype.Entity<TProduct>;

// IntelliSense works! u.Price shows Currency operators
var List := Db.Products.Where(u.Price > 100).ToList;

// Generates SQL: SELECT * FROM Products WHERE Price > 100
```

### Model Binding with DI
```delphi
WebApp.MapPost<TAppDbContext, TProduct, IResult>('/products',
  function(Db: TAppDbContext; Product: TProduct): IResult
  begin
    // Db is injected from DI container
    // Product is deserialized from JSON body
    Db.Products.Add(Product);
    Db.SaveChanges;
    Result := Results.Ok(Product);
  end);
```

## 🔧 Smart Types Available

| Type | Delphi Base | Operators |
|------|-------------|-----------|
| `StringType` | `string` | `=`, `<>`, `Contains`, `StartsWith` |
| `IntType` | `Integer` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `Int64Type` | `Int64` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `CurrencyType` | `Currency` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `DoubleType` | `Double` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `BoolType` | `Boolean` | `=`, `<>` |
| `DateTimeType` | `TDateTime` | `=`, `<>`, `>`, `<`, `>=`, `<=` |

## 🔗 See Also

- [Smart Properties Guide](../../docs/smart-properties.md)
- [ORM Guide](../../docs/orm-guide.md)
- [Model Binding Guide](../../docs/model-binding.md)
