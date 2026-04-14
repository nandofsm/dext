# 📋 Orm.SpecificationDemo - Padrão Specification

Demonstra o **Padrão Specification** para construir critérios de query reutilizáveis e combináveis no Dext ORM.

---

## ✨ O Que Esta Demo Mostra

### Criando Specifications Reutilizáveis

```pascal
// Entidade de Domínio
TProduct = class
  Id: Integer;
  Name: string;
  Price: Currency;
  IsActive: Boolean;
  Category: string;
end;

// Specification: "Produtos Caros Ativos"
TExpensiveProductsSpec = class(TSpecification<TProduct>)
public
  constructor Create(MinPrice: Currency);
end;

constructor TExpensiveProductsSpec.Create(MinPrice: Currency);
begin
  inherited Create;
  // ✨ A Sintaxe Mágica!
  Where( (Prop('Price') > MinPrice) and (Prop('IsActive') = True) );
end;
```

### Usando Specifications

```pascal
// Criar specification com parâmetros
var Spec := TExpensiveProductsSpec.Create(100.00);

// Usar com DbSet
var Products := Context.Entities<TProduct>.Where(Spec);

// Ou gerar SQL diretamente
var SQL := Generator.Generate(Spec.GetExpression);
// Resultado: WHERE (("Price" > :p1) AND ("IsActive" = :p2))
```

---

## 🚀 Começando

### Pré-requisitos
- Delphi 11+ (Alexandria ou posterior)
- Dext Framework no Library Path

### Executando a Demo

1. Abra `Orm.SpecificationDemo.dproj` no Delphi
2. Compile o projeto (F9)
3. Execute o binário

### Saída Esperada

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

## 💡 Conceitos Chave

### Por Que o Padrão Specification?

| Problema | Solução |
|----------|---------|
| Lógica de query duplicada | Encapsular em classe Specification reutilizável |
| Cláusulas WHERE complexas | Compor usando operadores `and` / `or` |
| Testabilidade | Specifications são testáveis sem banco |
| Linguagem de domínio | Nomear specs com conceitos de negócio |

### Construindo Expressões

```pascal
// Condição simples
Where( Prop('Name') = 'Product A' );

// Condições compostas
Where( (Prop('Price') > 100) and (Prop('IsActive') = True) );

// Where encadeado (AND implícito)
Where( Prop('Category') = 'Electronics' );
Where( Prop('InStock') = True );
```

### Geração de SQL

O framework traduz árvores de expressão para SQL específico de cada dialeto:

| Dialeto | Exemplo de Saída |
|---------|------------------|
| SQLite | `WHERE ("Price" > :p1)` |
| PostgreSQL | `WHERE "Price" > $1` |
| SQL Server | `WHERE [Price] > @p1` |

---

## 🔧 Combinando Specifications

```pascal
// Combinar specifications
var ExpensiveSpec := TExpensiveProductsSpec.Create(100);
var CategorySpec := TProductsByCategorySpec.Create('Electronics');

// Combinar usando And/Or
var CombinedSpec := ExpensiveSpec.And(CategorySpec);

// Usar spec combinada
var Products := Context.Entities<TProduct>.Where(CombinedSpec);
```

---

## 📁 Estrutura do Projeto

```
Orm.Specification/
├── Orm.SpecificationDemo.dpr   # Programa principal com exemplos
└── README.md                   # Este arquivo
```

---

## 📚 Exemplos Relacionados

- **[Orm.EntityDemo](../Orm.EntityDemo)** - Showcase completo do ORM
- **[Orm.EntityStyles](../Orm.EntityStyles)** - Entidades Classic vs Smart

---

## 📄 Licença

Este exemplo faz parte do Dext Framework e está licenciado sob a Apache License 2.0.

---

*Construa queries que falam a linguagem do seu domínio! 🚀*
