# CLI: Scaffolding (Reverse Engineering)

The Dext CLI features a powerful reverse engineering engine that automates entity creation by mapping tables from a live database. It is designed to generate clean, modern, production-ready Delphi code.

> [!TIP]
> The official CLI executable is `dext.exe`. It is built from the `Apps\CLI\DextTool.dproj` Delphi project. When building from source, use this project to generate the latest version of the utility.

---

## Generation Styles

Dext currently supports two primary property styles, catering to both high-performance needs and traditional native type preferences.

### 1. Smart Properties (Default)
Uses Dext's intelligent types (`IntType`, `StringType`, etc.).
- **Advantage**: Encapsulates Lazy Loading and Dirty Checking logic directly within the type, resulting in cleaner and more performant entities.
- **Metadata**: By default, it **does not generate** `TEntityType` metadata classes (Expressions), as Smart Properties are self-describing to the query engine.

```bash
dext scaffold -c "Server=localhost;Database=vendas" -d pg
```

### 2. POCO Style
Uses standard Delphi native types (`Integer`, `string`, `Nullable<T>`).
- **Advantage**: Full compatibility with 3rd-party libraries and frameworks that expect primitive types.
- **Metadata**: Automatically generates metadata classes (`TEntityType`) to enable Fluent API and Strongly Typed Expressions.

```bash
dext scaffold -c "Server=localhost;Database=vendas" -d pg --poco
```

---

## Command Line Options

| Option | Description |
|--------|-------------|
| `--connection`, `-c` | FireDAC connection string or file path (SQLite). |
| `--driver`, `-d` | Database driver: `pg` (Postgres), `sqlite`, `mssql`, `oracle`, `firebird`. |
| `--output`, `-o` | Output filename (e.g., `Entities.pas`). |
| `--schema`, `-s` | Database schema name (highly recommended for Postgres). |
| `--tables`, `-t` | Comma-separated list of tables to include. |
| `--fluent` | Generates `RegisterMappings` procedure for Fluent Mapping instead of Attributes. |
| `--smart` | (Default) Use Dext Smart Properties. |
| `--poco` | Use Native Delphi types + Metadata Classes. |
| `--no-metadata` | Explicitly skip `TEntityType` class generation. |
| `--with-metadata`| Explicitly include `TEntityType` class generation. |

---

## Practical Examples

### PostgreSQL with Custom Schema
If your Postgres database uses a schema other than `public`, use the `-s` flag:
```bash
dext scaffold -c "Server=localhost;Port=5432;Database=mydb;User_Name=postgres;Password=123" -d pg -s "finance" -o Entities.pas
```

### SQL Server (SQL Authentication)
```bash
dext scaffold -c "Server=localhost;Database=vendas;User_Id=sa;Password=123" -d mssql --fluent
```

### SQLite (Local Database)
Perfect for rapid prototyping:
```bash
dext scaffold -c "C:\data\system.db" -d sqlite --smart
```

---

## Robustness and Edge Cases

### Reserved Keywords
The Dext CLI automatically detects if a database column shares a name with a Delphi reserved keyword (such as `Class`, `Begin`, `End`, `Unit`). It automatically applies the identifier escape (`&`):

```pascal
property &Class: string read FClass write FClass;
```

### Case Sensitivity
Many databases (like Postgres) are case-insensitive but store names in lowercase or uppercase. The Dext CLI ensures the `[Column('REAL_NAME')]` attribute is generated whenever the PascalCase property name differs from the physical name in the database, preventing "column not found" errors at runtime.

### Fluent Mapping
If you prefer to keep your entity classes 100% pure (POCO) without any framework-specific attributes, use the `--fluent` flag:

```bash
dext scaffold -c "mydb.db" -d sqlite --poco --fluent
```
This will generate a `RegisterMappings` procedure containing all the configuration required for the `TModelBuilder`.

---

## Troubleshooting

### Error: "Unit X was compiled with a different version of Unit Y"
This is a common Delphi compiler error when stale or duplicate `.dcu` files exist in your search path.
**Solution**:
1. Delete all `__recovery`, `Win32`, and `Win64` folders from your project.
2. In Delphi, use the **Clean** option and then **Build All**.
3. Ensure there are no multiple versions of Dext in your Library Path.

---

[← Commands](commands.md) | [Next: Testing →](testing.md)
