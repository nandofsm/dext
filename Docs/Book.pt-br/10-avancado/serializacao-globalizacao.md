# Serialização e Globalização

O Dext Framework foi projetado para ser "seguro por padrão" ao lidar com a troca de dados entre diferentes regiões (locales) e sistemas. Este capítulo aborda como o Dext gerencia configurações de formato, serialização JSON e parsing de datas.

## Cultura Invariante por Padrão

As funções padrão do Delphi `FloatToStr` e `StrToFloat` utilizam as configurações regionais do SO (ex: usando vírgula `,` como separador decimal no Brasil). Isso pode corromper payloads JSON e consultas SQL que esperam o ponto `.` como separador.

O Dext força o uso de `TFormatSettings.Invariant` em todas as unidades de serialização principais:

- **Serialização JSON**: `Dext.Json` e `Dext.Json.Utf8` sempre usam `.` para números.
- **Headers Web**: Valores de qualidade (`q=0.8`) e datas de expiração de cookies são formatados usando configurações invariantes.
- **Conversões de Banco de Dados**: Conversores de tipo internos priorizam o parsing invariante para evitar erros de "Invalid float" em servidores com diferentes configurações regionais.

## Parsing de Data e Hora

O Dext fornece utilitários robustos para processar datas de várias fontes (headers HTTP, strings JSON, arquivos CSV) através da unidade `Dext.Core.DateUtils`.

### `TryParseCommonDate`

A função `TryParseCommonDate` tenta converter uma string usando uma sequência de formatos:
1. **ISO 8601** (ex: `2025-12-25T10:00:00Z`)
2. **Padrão do Sistema** (Formato atual do Windows/Linux)
3. **Formatos Comuns** (`dd/mm/yyyy`, `mm/dd/yyyy`, `yyyy-mm-dd`)

```pascal
uses Dext.Core.DateUtils;

var
  LDate: TDateTime;
begin
  // ISO 8601
  if TryParseCommonDate('2025-12-25T15:30:00', LDate) then ...
  
  // Específico da região (dd/mm/yyyy ou mm/dd/yyyy dependendo do SO)
  if TryParseCommonDate('25/12/2025', LDate) then ...
end;
```

### Sobrecarga com FormatSettings

A partir da Versão 1.1, você pode passar um `TFormatSettings` específico para o parser se estiver lidando com dados de uma fonte conhecida:

```pascal
var
  GermanFS: TFormatSettings;
begin
  GermanFS := TFormatSettings.Create('de-DE');
  if TryParseCommonDate('25.12.2025', LDate, GermanFS) then
    Log('Data em formato alemão processada!');
end;
```

## Hidratação JSON e Datas

No `TEntityDataSet` e no sistema de mapeamento JSON, o Dext lida automaticamente com conversões de data a partir de strings JSON. Ele utiliza `TryParseISODateTime` internamente, garantindo que:

- Propriedades `TDateTime` recebam o timestamp completo.
- Propriedades `TDate` recebam apenas a parte da data (Trunc).
- Propriedades `TTime` recebam apenas a parte da hora (Frac).

## Gerenciamento de Memória (FastMM5)

Para aplicações de alta performance, o Dext inclui suporte nativo ao **FastMM5**. Ele vem habilitado por padrão no pacote `Dext.Core` para garantir performance ideal em requisições web multi-thread e processamento de grandes volumes de JSON.

Para verificar ou alterar essa configuração, consulte `Dext.MM.pas`:

```pascal
{$DEFINE DEXT_USE_FASTMM5} // Habilitado para gerenciamento de memória de nível industrial
```

---

[← Tópicos Avançados](README.md)
