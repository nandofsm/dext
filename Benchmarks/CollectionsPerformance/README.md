# Benchmark de Performance: Dext.Collections vs RTL

Este benchmark visa medir a performance em tempo de execução (Runtime) da biblioteca `Dext.Collections` em comparação com a `System.Generics.Collections` da RTL original do Delphi.

## 🎯 Objetivos

- Comparar a eficiência de gerenciamento de memória em diferentes volumes de dados.
- Medir o overhead de abstração das interfaces do Dext em loops de alta frequência.
- Validar algoritmos de ordenação e busca (hashes).
- Identificar gargalos em tipos gerenciados (Strings/Records) em ambientes cross-platform (Windows/Linux).

## 🧪 Metodologia

### 1. Volumes de Dados

- **Small**: 100 itens (foco em latência de criação/destruição).
- **Medium**: 10,000 itens (uso típico de memória).
- **Large**: 1,000,000 itens (estresse de escalabilidade e cache de CPU).

### 2. Tipos de Dados Testados

- `Integer` (Tipo primitivo, comparativo puro).
- `Currency` (Ponto fixo, 8-bytes).
- `String` (Tipo gerenciado, impacto de ARC).
- `Record` (Pequeno: 16 bytes e Grande: 256 bytes).
- `Object` (Alocações no heap, herança).

### 3. Operações Medidas

- **Populate (Add)**: Adicionar itens em sequência.
- **Populate (Pre-allocated)**: Definindo `Capacity` antes de inserir.
- **Sort**: Ordenação de dados aleatórios.
- **Search (IndexOf)**: Localizar item no meio da lista.
- **Dictionary Lookup**: Performance de `TryGetValue` (Hash).
- **Iteration (for-in)**: Custo do enumerador interfaceado vs vanilla.
- **Removal (First)**: `Delete(0)` (O pior caso de movimentação de memória).
- **Removal (Last)**: `RemoveLast` (O melhor caso de remoção).

## 📊 Relatório de Saída

O benchmark gerará uma tabela comparativa no console e salvará os resultados em um arquivo `performance_results.md`.

## 🛠️ Execução

O projeto de benchmark será um aplicativo Console autônomo localizado em `Benchmarks\CollectionsPerformance\`.
