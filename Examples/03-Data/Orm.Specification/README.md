# 📋 Orm.SpecificationDemo - Specification Pattern

Demonstrates the **Specification Pattern** for building reusable, composable query criteria in the Dext ORM.

---

## ✨ What This Demo Shows

### Creating Reusable Specifications

```pascal
// Domain Entity
TProduct = class
  Id: Integer;
  Name: string;
  Price: Currency;
  IsActive: Boolean;
  Category: string;
end;

// Specification: "Expensive Active Products"
TExpensiveProductsSpec = class(TSpecification<TProduct>)
public
  constructor Create(MinPrice: Currency);
end;

constructor TExpensiveProductsSpec.Create(MinPrice: Currency);
begin
  inherited Create;
  // ✨ The Magic Syntax!
  Where( (Prop('Price') > MinPrice) and (Prop('IsActive') = True) );
end;
```

### Using Specifications

```pascal
// Create specification with parameters
var Spec := TExpensiveProductsSpec.Create(100.00);

// Use with DbSet
var Products := Context.Entities<TProduct>.Where(Spec);

// Or generate SQL directly
var SQL := Generator.Generate(Spec.GetExpression);
// Result: WHERE (("Price" > :p1) AND ("IsActive" = :p2))
```

---

## 🚀 Getting Started

### Prerequisites
- Delphi 11+ (Alexandria or later)
- Dext Framework in Library Path

### Running the Demo

1. Open `Orm.SpecificationDemo.dproj` in Delphi
2. Build the project (F9)
3. Run the executable

### Expected Output

```
🚀 Dext Specifications Demo
===========================

1. Building "Expensive Active Products" Spec (Price > 100)...
   Criteria Tree: ((Price 2 100) AND (IsActive 0 True))
   Generated SQL (SQLite): WHERE (("Price" > :p1) AND ("IsActive" = :p2))
   Parameters:
     :p2 = True
     :p1 = 100

2. Building "Electronics" Category Spec...
   Criteria Tree: (Category 0 Electronics)
   Generated SQL (SQLite): WHERE ("Category" = :p1)
   Parameters:
     :p1 = Electronics

✨ Success! The expression tree was translated to SQL correctly.
```

---

## 💡 Key Concepts

### Why Specification Pattern?

| Problem | Solution |
|---------|----------|
| Duplicated query logic | Encapsulate in reusable Specification class |
| Complex WHERE clauses | Compose using `and` / `or` operators |
| Testability | Specifications are unit-testable without DB |
| Domain language | Name specs after business concepts |

### Expression Building

```pascal
// Simple condition
Where( Prop('Name') = 'Product A' );

// Compound conditions
Where( (Prop('Price') > 100) and (Prop('IsActive') = True) );

// Chained Where (implicit AND)
Where( Prop('Category') = 'Electronics' );
Where( Prop('InStock') = True );
```

### SQL Generation

The framework translates expression trees to dialect-specific SQL:

| Dialect | Example Output |
|---------|----------------|
| SQLite | `WHERE ("Price" > :p1)` |
| PostgreSQL | `WHERE "Price" > $1` |
| SQL Server | `WHERE [Price] > @p1` |

---

## 🔧 Composing Specifications

```pascal
// Combine specifications
var ExpensiveSpec := TExpensiveProductsSpec.Create(100);
var CategorySpec := TProductsByCategorySpec.Create('Electronics');

// Combine using And/Or
var CombinedSpec := ExpensiveSpec.And(CategorySpec);

// Use combined spec
var Products := Context.Entities<TProduct>.Where(CombinedSpec);
```

---

## 📁 Project Structure

```
Orm.Specification/
├── Orm.SpecificationDemo.dpr   # Main program with examples
└── README.md                   # This file
```

---

## 📚 Related Examples

- **[Orm.EntityDemo](../Orm.EntityDemo)** - Comprehensive ORM showcase
- **[Orm.EntityStyles](../Orm.EntityStyles)** - Classic vs Smart entities

---

## 📄 License

This example is part of the Dext Framework and is licensed under the Apache License 2.0.

---

*Build queries that speak your domain language! 🚀*
