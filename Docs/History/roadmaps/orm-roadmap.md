# 🗺️ Dext Entity ORM - Roadmap

Este documento centraliza a visão, funcionalidades e progresso do sistema de mapeamento objeto-relacional (ORM) do Dext.

> **Visão:** Um ORM de alta performance, code-first, altamente produtivo e com suporte a múltiplos dialetos SQL, inspirado no Entity Framework Core.

---

## 📊 Status Atual: **Release Candidate 1.0** 🚀

O núcleo do ORM atingiu maturidade de produção, suportando operações complexas, multi-tenancy avançado e migrações code-first para todos os bancos suportados.

*Última atualização: 07 de Abril de 2026*

---

## ✅ Funcionalidades Implementadas

### 1. Core Persistence & Context
- [x] **TDbContext**: Unidade de trabalho que gerencia sessões e transações.
- [x] **DbSet<T>**: Abstração de coleção para entidades tipadas.
- [x] **Change Tracker**: Detecção automática de mudanças para `Update` inteligente (apenas colunas afetadas).
- [x] **Identity Map**: Garantia de unicidade de instâncias por chave primária no contexto.

### 2. Fluent Mapping & Attributes
- [x] **Attribute Mapping**: `[Table]`, `[Column]`, `[Key]`, `[ForeignKey]`, `[Index]`.
- [x] **Fluent API**: Configuração avançada via `OnModelCreating`.
- [x] **Value Converters**: Mapeamento de Tipos Complexos (JSON, Enums, Nullables).

### 3. Query Engine
- [x] **Fluent Queries**: `DbSet.Where(...).OrderBy(...).Skip(10).Take(20).ToList()`.
- [x] **SQL Predicate Generator**: Geração inteligente de SQL parametrizado.
- [x] **Command Cache**: Cache de planos de execução SQL para máxima performance.

### 4. Relacionamentos
- [x] **One-to-One**: Relacionamentos exclusivos entre entidades.
- [x] **One-to-Many**: Mapeamento de coleções e chaves estrangeiras.
- [x] **Many-to-Many**: Tabelas de junção automáticas e gerenciadas.
- [x] **Lazy Loading**: Carregamento sob demanda via Virtual Proxies.
- [x] **Eager Loading**: Uso de `.Include(x => x.Relation)` para carregar dependências em um único SQL.

### 5. Advanced Features
- [x] **Multi-Tenancy**: Filtros globais de segurança por Tenant.
- [x] **Soft Delete**: Marcação de registros como excluídos sem remoção física.
- [x] **Optimistic Concurrency**: Controle via `[VersionAttribute]`.
- [x] **Migrations**: Sistema de evolução de esquema code-first automático.

### 6. Dialetos Suportados (FireDAC)
- [x] **PostgreSQL** (Nativo)
- [x] **SQL Server** (Nativo)
- [x] **MySQL / MariaDB** (Nativo)
- [x] **SQLite** (Nativo)
- [x] **Firebird** (Nativo)

---

## 🎯 Próximos Passos (v1.1+)

1. **Native Batch Updates**: Suporte a `UpdateRange` e `DeleteRange` via SQL direto.
2. **Compiled Queries**: Pré-compilação de queries complexas para performance crítica.
3. **Multi-Database Support**: Capacidade de um único `DbContext` gerenciar múltiplos bancos simultaneamente.

---
*Dext Entity ORM - Powering high-performance data access in Delphi.*
