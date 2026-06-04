# GUIDELINES — Regras fornecidas à IA

## Contexto geral
Este projeto segue a arquitetura em camadas apresentada em sala: AppDatabase → Repository → Controller → Page.

## Restrições arquiteturais

- Persistência obrigatória via **SQLite** usando `sqflite` + `path`
- A classe `AppDatabase` centraliza a criação e acesso ao banco
- O `Repository` é a única camada que executa SQL direto
- O `Controller` mantém lista em memória e delega operações ao Repository
- A `Page` nunca acessa banco diretamente — usa apenas o Controller
- `id` do model deve ser `int?` (nullable) para suportar AUTOINCREMENT
- Métodos obrigatórios no model: `toMap()` e `fromMap()`
- Nomes de colunas SQLite devem coincidir com as chaves do `toMap()`

## Padrão de código exigido

- Material 3 com `useMaterial3: true` e tema dark
- `ColorScheme.fromSeed` com `brightness: Brightness.dark`
- `ConstrainedBox(maxWidth: 720)` em todas as telas
- `EmptyState` quando lista vazia
- `AlertDialog` antes de remover
- `SnackBar` após cadastro, edição e remoção
- `dispose()` em todos os `TextEditingController`
- `if (mounted)` antes de usar `context` após `await`
- Getter `_isEditing` no formulário

## Nomenclatura

- Arquivos: `snake_case`
- Classes: `PascalCase`
- Variáveis/métodos privados: prefixo `_`
