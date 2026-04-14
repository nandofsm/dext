# Demo Smart Properties

Este exemplo demonstra **Smart Properties** - uma feature revolucionária que permite queries de banco de dados type-safe, com IntelliSense e geração automática de SQL.

## 🚀 Funcionalidades Demonstradas

| Funcionalidade | Descrição |
|----------------|-----------|
| **Smart Types** | `StringType`, `CurrencyType`, `BoolType` - wrappers tipados com sobrecarga de operadores |
| **Fluent Query** | `u.Price > 100` traduz diretamente para SQL `WHERE Price > 100` |
| **Prototype Entity** | `Prototype.Entity<T>` cria builders de expressão type-safe |
| **Model Binding + DI** | `MapPost<TDbContext, TEntity, IResult>` com injeção automática |
| **Atributos ORM** | `[PK, AutoInc]`, `[Required]`, `[MaxLength]`, `[Precision]` |

## 🛠️ Como Iniciar

1. **Compile** `Web.SmartPropsDemo.dproj`
2. **Execute** `Web.SmartPropsDemo.exe`
   - Banco SQLite em arquivo (`smart_props.db`) é criado automaticamente
   - Servidor inicia em **http://localhost:5000**
3. **Teste**:
   ```powershell
   .\Test.Web.SmartPropsDemo.ps1
   ```

## 📍 Endpoints

| Método | Path | Descrição |
|--------|------|-----------|
| `GET` | `/products` | Lista produtos onde `Price > 100` |
| `POST` | `/products` | Cria novo produto (JSON body → Entity) |

## 💡 Destaques do Código

### Definição de Entidade com Smart Properties
```delphi
uses
  Dext.Core.SmartTypes;  // StringType, CurrencyType, BoolType

[Table('Products')]
TProduct = class
private
  FId: Int64;
  FName: StringType;      // String Inteligente
  FPrice: CurrencyType;   // Currency Inteligente
  FIsActive: BoolType;    // Boolean Inteligente
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

### Query Fluente Type-Safe
```delphi
uses
  Dext.Entity.Prototype;

// Cria protótipo para expressões type-safe
var u := Prototype.Entity<TProduct>;

// IntelliSense funciona! u.Price mostra operadores de Currency
var List := Db.Products.Where(u.Price > 100).ToList;

// Gera SQL: SELECT * FROM Products WHERE Price > 100
```

### Model Binding com DI
```delphi
WebApp.MapPost<TAppDbContext, TProduct, IResult>('/products',
  function(Db: TAppDbContext; Product: TProduct): IResult
  begin
    // Db é injetado do container DI
    // Product é deserializado do body JSON
    Db.Products.Add(Product);
    Db.SaveChanges;
    Result := Results.Ok(Product);
  end);
```

## 🔧 Smart Types Disponíveis

| Tipo | Base Delphi | Operadores |
|------|-------------|------------|
| `StringType` | `string` | `=`, `<>`, `Contains`, `StartsWith` |
| `IntType` | `Integer` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `Int64Type` | `Int64` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `CurrencyType` | `Currency` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `DoubleType` | `Double` | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| `BoolType` | `Boolean` | `=`, `<>` |
| `DateTimeType` | `TDateTime` | `=`, `<>`, `>`, `<`, `>=`, `<=` |

## 🔗 Veja Também

- [Guia Smart Properties](../../docs/smart-properties.md)
- [Guia ORM](../../docs/orm-guide.md)
- [Guia Model Binding](../../docs/model-binding.md)
