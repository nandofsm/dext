# Serialization & Globalization

The Dext Framework is designed to be "safe by default" when handling data exchange across different locales and systems. This chapter covers how Dext manages format settings, JSON serialization, and date parsing.

## Invariant Culture by Default

Delphi's standard `FloatToStr` and `StrToFloat` functions use the OS's regional settings (e.g., using a comma `,` as a decimal separator in Brazil or Germany). This can break JSON payloads and database queries that expect a dot `.` separator.

Dext forces the use of `TFormatSettings.Invariant` in all core serialization units:

- **JSON Serialization**: `Dext.Json` and `Dext.Json.Utf8` always use `.` for numbers.
- **Web Headers**: Quality values (`q=0.8`) and cookie expiry dates are formatted using invariant settings.
- **Database Conversions**: Internal type converters prioritize invariant parsing to avoid "Invalid float" errors on servers.

## Date & Time Parsing

Dext provides a robust utility for parsing dates from various sources (HTTP headers, JSON strings, CSV files) via the `Dext.Core.DateUtils` unit.

### `TryParseCommonDate`

The `TryParseCommonDate` function attempts to parse a string using a sequence of formats:
1. **ISO 8601** (e.g., `2025-12-25T10:00:00Z`)
2. **System Default** (Current OS format)
3. **Common Formats** (`dd/mm/yyyy`, `mm/dd/yyyy`, `yyyy-mm-dd`)

```pascal
uses Dext.Core.DateUtils;

var
  LDate: TDateTime;
begin
  // ISO 8601
  if TryParseCommonDate('2025-12-25T15:30:00', LDate) then ...
  
  // Locale-specific (dd/mm/yyyy or mm/dd/yyyy depending on OS)
  if TryParseCommonDate('25/12/2025', LDate) then ...
end;
```

### Overloading with FormatSettings

Since Version 1.1, you can pass specific `TFormatSettings` to the parser if you are handling data from a specific known source:

```pascal
var
  GermanFS: TFormatSettings;
begin
  GermanFS := TFormatSettings.Create('de-DE');
  if TryParseCommonDate('25.12.2025', LDate, GermanFS) then
    Log('Parsed German date!');
end;
```

## JSON Hydration and Dates

In the `TEntityDataSet` and JSON mapping system, Dext automatically handles date conversions from JSON strings. It uses `TryParseISODateTime` internally, ensuring that:

- `TDateTime` properties get the full timestamp.
- `TDate` properties get the truncated date part.
- `TTime` properties get the fractional time part.

## Memory Management (FastMM5)

For high-performance applications, Dext includes native support for **FastMM5**. It is enabled by default in the `Dext.Core` package to ensure optimal performance with multi-threaded web requests and large JSON processing.

To check or toggle this setting, see `Dext.MM.pas`:

```pascal
{$DEFINE DEXT_USE_FASTMM5} // Enabled for production-grade memory management
```

---

[← Advanced Topics](README.md)
