# CLI: Scaffolding (Engenharia Reversa)

O Dext CLI possui um poderoso motor de engenharia reversa que automatiza a criação de entidades mapeando tabelas de um banco de dados real. Ele foi projetado para gerar código limpo, moderno e pronto para produção.

> [!TIP]
> O executável oficial do CLI é o `dext.exe`. Ele é gerado a partir do projeto Delphi `Apps\CLI\DextTool.dproj`. Se você estiver compilando a partir do fonte, use este projeto para obter a versão mais recente do utilitário.

---

## Estilos de Geração

Hoje o Dext suporta dois estilos principais de propriedades, atendendo tanto a quem busca performance máxima quanto a quem prefere tipos nativos tradicionais.

### 1. Smart Properties (Padrão)
Usa os tipos inteligentes do Dext (`IntType`, `StringType`, etc.). 
- **Vantagem**: Encapsula lógica de Lazy Loading e Dirty Check diretamente no tipo, resultando em entidades mais limpas e performáticas.
- **Metadados**: Por padrão, **não gera** as classes `TEntityType` (Expressões), pois as Smart Properties já são auto-descritivas para o motor de consulta.

```bash
dext scaffold -c "servidor=localhost;database=vendas" -d pg
```

### 2. POCO Style
Usa tipos nativos do Delphi (`Integer`, `string`, `Nullable<T>`).
- **Vantagem**: Compatibilidade total com bibliotecas de terceiros que esperam tipos primitivos.
- **Metadados**: Gera automaticamente as classes de metadados (`TEntityType`) para permitir o uso de Fluent API e Expressões Fortemente Tipadas.

```bash
dext scaffold -c "servidor=localhost;database=vendas" -d pg --poco
```

---

## Opções de Linha de Comando

| Opção | Descrição |
|--------|-------------|
| `--connection`, `-c` | String de conexão FireDAC ou caminho do arquivo (SQLite). |
| `--driver`, `-d` | Driver do banco: `pg` (Postgres), `sqlite`, `mssql`, `oracle`, `firebird`. |
| `--output`, `-o` | Nome do arquivo de saída (ex: `Entities.pas`). |
| `--schema`, `-s` | Schema do banco de dados (muito usado em Postgres). |
| `--tables`, `-t` | Lista de tabelas separadas por vírgula. Ex: `usuarios,pedidos`. |
| `--fluent` | Gera a procedure `RegisterMappings` para Fluent Mapping em vez de Atributos. |
| `--smart` | (Padrão) Usa Dext Smart Properties. |
| `--poco` | Usa tipos nativos Delphi + Classes de Metadados. |
| `--no-metadata` | Força a omissão das classes `TEntityType`. |
| `--with-metadata`| Força a inclusão das classes `TEntityType`. |

---

## Exemplos Práticos

### PostgreSQL com Schema Específico
Se o seu banco Postgres usa um schema que não seja o `public`, use a flag `-s`:
```bash
dext scaffold -c "Server=localhost;Port=5432;Database=meubanco;User_Name=postgres;Password=123" -d pg -s "financeiro" -o Entities.pas
```

### SQL Server (Autenticação SQL)
```bash
dext scaffold -c "Server=localhost;Database=vendas;User_Id=sa;Password=123" -d mssql --fluent
```

### SQLite (Banco Local)
Perfeito para prototipagem rápida:
```bash
dext scaffold -c "C:\dados\sistema.db" -d sqlite --smart
```

---

## Robustez e Casos Especiais

### Palavras Reservadas
O Dext CLI detecta automaticamente se uma coluna do seu banco possui o mesmo nome de uma palavra reservada do Delphi (como `Class`, `Begin`, `End`, `Unit`) e aplica automaticamente o escape de identificador (`&`):

```pascal
property &Class: string read FClass write FClass;
```

### Case Sensitivity
Muitos bancos (como Postgres) são case-insensitive mas armazenam nomes em minúsculo ou maiúsculo. O Dext CLI garante que o atributo `[Column('NOME_REAL')]` seja gerado sempre que houver divergência entre o nome PascalCase da propriedade e o nome físico no banco, evitando erros de "coluna não encontrada" em runtime.

### Mapeamento Fluente
Se você prefere manter suas classes de entidade 100% puras (POCO) sem nenhum atributo do framework, use a flag `--fluent`:

```bash
dext scaffold -c "meubanco.db" -d sqlite --poco --fluent
```
Isso gerará uma procedure `RegisterMappings` contendo toda a configuração necessária para o `TModelBuilder`.

---

## Resolução de Problemas

### Erro: "Unit X was compiled with a different version of Unit Y"
Este é um erro comum do compilador Delphi quando existem arquivos `.dcu` antigos ou duplicados no seu path. 
**Solução**: 
1. Apague todas as pastas `__recovery`, `Win32` e `Win64` do seu projeto.
2. No Delphi, use a opção **Clean** e depois **Build All**.
3. Certifique-se de que não há múltiplas versões do Dext no seu Library Path.

---

[← Migrations](migrations.md) | [Próximo: Testes →](testes.md)
