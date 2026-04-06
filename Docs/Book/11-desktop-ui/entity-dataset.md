# Entity DataSet

The **`TEntityDataSet`** is a high-performance memory dataset designed to connect your **Dext ORM Entity Lists** directly to Delphi's classic data-aware Visual components (`TDataSource`, `TDBGrid`, `TDBEdit`) and reporting tools (`FastReport`, `ReportBuilder`).

Instead of replicating the entire memory space, **`TEntityDataSet`** uses memory offsets via `TEntityMap` maps from Dext to provide extreme performance and zero-allocation loading.

---

## 🚀 Loading Data

You can populate the dataset using an array of generic or domain objects, or loading directly from a **JSON ByteSpan** payload in memory.

### Loading from an Object List

```pascal
var
  Users: TArray<TUser>;
begin
  Users := Context.Users.ToList; // Fetch from Context
  
  DataSet.Load(Users, TUser); // Smart binding
  DataSource.DataSet := DataSet;
end;
```

### Loading directly from Utf8 JSON Buffer

```pascal
var
  JsonBytes: TBytes;
  Span: TByteSpan;
begin
  JsonBytes := TEncoding.UTF8.GetBytes(Payload);
  Span := TByteSpan.Create(JsonBytes);

  DataSet.LoadFromUtf8Json(Span, TUser);
end;
```

---

## 🔍 Filters and Searching

The dataset handles sorting and filtering purely in memory using the fast query framework of Dext.

### Expression Filtering 

You can set filtering natively using familiar string tokens:

```pascal
DataSet.Filter := 'Score > 100';
DataSet.Filtered := True;
```

### Quick Lookups

```pascal
if DataSet.Locate('Name', 'Cesar', []) then
  ShowMessage('Found!');
```

---

## 🎨 Design-Time Experience

The **`TEntityDataSet`** is tightly integrated with the Delphi IDE. By using the **`TEntityDataProvider`**, it can scan your source code and synchronize metadata without requiring full project compilation.

### Component Verbs

Right-click the component in the Form Designer to access these productivity tools:

1.  **Sync Fields (Scan + Update)**: 
    *   Adds new fields found in your entity class.
    *   Updates metadata (DisplayLabel, DisplayFormat, Visibility) from code attributes.
    *   **Preserves** your manual IDE customizations (Alignment, Font, etc.) for existing fields.
2.  **Refresh Entity (Re-Scan + Rebuild)**: 
    *   Performs a clean sweep.
    *   Deletes all current fields and rebuilds them strictly based on the current Entity metadata.
    *   Use this when you want a "Hard Reset" or when switching between unrelated entities.

### Automatic Stabilization

Dext ensures that the design-time state doesn't pollute your source files:
- **Persistence Safety:** The `Active` property is automatically handled so that it's never saved as `True` in the DFM, preventing "Connection Error" popups when opening forms.
- **Smart Cleanup:** Changing the `EntityClassName` property automatically triggers a full field rebuild to prevent metadata contamination.

---

## 🏆 Key Features

- **Zero Allocation on Value Loading:** Value reading maps to memory offsets accurately.
- **DML Memory Mode:** Append, Edit, and Delete fully operational inside the dataset structures.
- **Component Palette Ready:** Support for dropping statically at design-time for persistent `TFields`.
