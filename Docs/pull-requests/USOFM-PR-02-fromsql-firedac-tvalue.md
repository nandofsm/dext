## Summary

Improves raw SQL (`FromSql`) parameter binding for FireDAC **named** placeholders (`:id`, `:name`, …) and hardens **TValue** conversion for readers / scalars / typed parameters (PostgreSQL and mixed field types).

## Problems addressed

1. **`FromSql` + PostgreSQL / named params**  
   Iterator used `AddParam('p0', …)` while SQL contained `:UserId`-style names → **parameter not found** or wrong binding.

2. **Reader / scalar**  
   Narrow `case Field.DataType` + `FromVariant` missed several types and could throw **`EVariantTypeCastError`**.

3. **`SetParamValueWithType` + `Prop<T>`**  
   Explicit `[DbType]` paths used `AsInteger` on **`TValue`** that still held **`Prop<Integer>`** records.

4. **Phys reader + GUID on Win64**  
   **`TGUID(Data)`** with `Variant` is invalid on **dcc64** (E2089).

## Solution

- **`IDbCommand.BindSequentialParams(const AValues: TArray<TValue>)`**  
  Documented: values bind in **SQL declaration order** (index `0` → first placeholder).

- **`TFireDACCommand` / `TFireDACPhysCommand`**  
  - `BindSequentialParams`: `Prepare` (where needed), assert param count, `SetParamValue(Params[i], AValues[i])`.  
  - `SetParamValueWithType`: **`TReflection.TryUnwrapProp`** before assignment; Phys branch aligns **integer vs enum** with the main driver.

- **`FireDAC.pas`**  
  - **`FireDACFieldToTValue`**: broader `TFieldType` coverage + fallback on **`EVariantTypeCastError`**.  
  - **`TFireDACReader.GetValue`** / **`ExecuteScalar`** use it.

- **`FireDAC.Phys.pas`**  
  - **`dtGUID`**: `StringToGUID(Trim(VarToStr(Data)))` with fallback to **`FromVariant`**.

- **`Dext.Entity.DbSet.pas`**  
  - `TSqlQueryIterator.MoveNextCore` calls **`BindSequentialParams(FParams)`** instead of `AddParam('p' + …)`.

- **`Dext.Entity.Core.pas`**  
  - XML doc on **`FromSql`**: positional binding vs `p0` names.

## Files

- `Sources/Data/Dext.Entity.Drivers.Interfaces.pas`
- `Sources/Data/Dext.Entity.Drivers.FireDAC.pas`
- `Sources/Data/Dext.Entity.Drivers.FireDAC.Phys.pas`
- `Sources/Data/Dext.Entity.DbSet.pas`
- `Sources/Data/Dext.Entity.Core.pas`

## Breaking change

Custom **`IDbCommand`** implementations outside the repo must implement **`BindSequentialParams`** (can be empty if unused).

## Testing

- `FromSql('... WHERE id = :id', [TValue.From<Integer>(42)])` against PG/SQLite.
- Entity with **`IntType`** + **`PersistUpdate`** (overlaps with PR #1 if merged separately—both should apply cleanly).
