# Entity DataSet

O **`TEntityDataSet`** é um Dataset em memória de alto desempenho projetado para conectar suas **Listas de Entidades do Dext ORM** diretamente aos componentes visuais tradicionais do Delphi (`TDataSource`, `TDBGrid`, `TDBEdit`) e ferramentas de relatório (como `FastReport` ou `ReportBuilder`).

Em vez de replicar todo o espaço de memória de cada objeto, o **`TEntityDataSet`** usa offsets de memória via os mapas `TEntityMap` do Dext, proporcionando extrema velocidade e zero-allocation.

---

## 🚀 Carregando Dados

Você pode preencher o dataset usando um array de objetos genéricos ou de domínio, ou carregar diretamente de um buffer **JSON ByteSpan** na memória.

### Carregando de uma Lista de Objetos

```pascal
var
  Users: TArray<TUser>;
begin
  Users := Context.Users.ToList; // Busca do Context
  
  DataSet.Load(Users, TUser); // Smart binding
  DataSource.DataSet := DataSet;
end;
```

### Carregando diretamente de um Buffer Utf8 JSON

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

## 🔍 Filtros e Buscas

O dataset gerencia a ordenação e filtragem puramente em memória usando o framework de queries eficientes do Dext.

### Filtragem por Expressão

Você pode setar filtros nativamente usando tokens clássicos de String:

```pascal
DataSet.Filter := 'Score > 100';
DataSet.Filtered := True;
```

### Buscas Rápidas (Lookup)

```pascal
if DataSet.Locate('Name', 'Cesar', []) then
  ShowMessage('Encontrado!');
```

---

## 🎨 Experiência em Tempo de Design

O **`TEntityDataSet`** possui integração profunda com a IDE do Delphi. Utilizando o **`TEntityDataProvider`**, ele consegue analisar seu código-fonte e sincronizar metadados sem exigir a compilação total do projeto.

### Verbos do Componente

Clique com o botão direito no componente no Form Designer para acessar estas ferramentas de produtividade:

1.  **Sync Fields (Scan + Update)**: 
    *   Adiciona novos campos encontrados na sua classe de entidade.
    *   Atualiza metadados (DisplayLabel, DisplayFormat, Visibilidade) a partir dos atributos de código.
    *   **Preserva** suas customizações manuais na IDE (Alinhamento, Formatação, etc.) para campos já existentes.
2.  **Refresh Entity (Re-Scan + Rebuild)**: 
    *   Realiza uma limpeza completa.
    *   Deleta todos os campos atuais e os recria estritamente com base nos metadados atuais da Entidade.
    *   Use para um "Hard Reset" ou ao trocar entre entidades totalmente diferentes.

### Estabilização Automática

O Dext garante que o estado de design-time não polua seus arquivos de código:
- **Segurança na Persistência:** A propriedade `Active` é gerenciada automaticamente para que nunca seja salva como `True` no DFM, evitando popups de erro de conexão ao abrir forms.
- **Limpeza Inteligente:** Alterar a propriedade `EntityClassName` dispara automaticamente uma reconstrução total dos campos para evitar contaminação de metadados.

---

## 🏆 Recursos Principais

- **Zero Allocation na Carga de Valores:** A leitura de valores é vinculada a offsets de forma otimizada.
- **DML Memory Mode:** Append, Edit e Delete operacionais dentro da estrutura.
- **Preparado para Component Palette:** Suporte para design-time e sincronização de `TFields` persistentes.
