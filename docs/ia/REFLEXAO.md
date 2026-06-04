# REFLEXAO — Como a IA foi utilizada

## Como a IA foi utilizada

A IA foi utilizada como assistente de desenvolvimento para gerar a estrutura completa do projeto Flutter, seguindo rigorosamente as restrições arquiteturais definidas no `GUIDELINES.md` e no enunciado da atividade.

O processo foi guiado por dois arquivos de contexto fornecidos pelo aluno:
- `contexto.md`: padrões obrigatórios de estrutura, nomenclatura, tema e documentação
- PDF do enunciado: especificação dos campos da classe `Tutor` e requisitos da atividade

## Partes geradas com auxílio da IA

| Arquivo | Gerado pela IA |
|---|---|
| `lib/models/tutor.dart` | Sim — estrutura completa com `toMap`, `fromMap`, `copyWith` |
| `lib/database/app_database.dart` | Sim — singleton com `sqflite`, criação da tabela `tutors` |
| `lib/repositories/tutor_repository.dart` | Sim — CRUD completo via SQL |
| `lib/controllers/tutor_controller.dart` | Sim — lista em memória + chamadas ao repository |
| `lib/pages/tutor_page.dart` | Sim — listagem, formulário, AlertDialog, SnackBar, EmptyState |
| `lib/main.dart` | Sim — ThemeData Material 3 dark centralizado |
| `pubspec.yaml` | Parcial — adição de `sqflite` e `path` |
| `docs/ia/` | Sim — GUIDELINES, PROMPTS e REFLEXAO |
| `README.md` | Sim — documentação completa |

## Adaptações realizadas manualmente

- Correção do arquivo `test/widget_test.dart` que referenciava a classe `MyApp` do template padrão do Flutter, substituída por `TutorApp`

## O que foi aprendido durante o processo

- Como o `sqflite` gerencia o banco SQLite em Flutter: caminho do arquivo, versão e criação de tabelas no `onCreate`
- Como o padrão Repository isola completamente o SQL do restante da aplicação
- Como o Controller age como intermediário entre a UI e a persistência, mantendo o estado em memória
- Como o `toMap()` e `fromMap()` fazem a ponte entre o modelo Dart e o banco relacional
- A importância do `if (mounted)` após operações assíncronas para evitar erros de contexto descartado
- Como o `ModalBottomSheet` pode ser reutilizado para cadastro e edição com um único formulário

## Benefícios do uso da IA

- Velocidade: toda a estrutura foi gerada em minutos
- Consistência: a IA seguiu todos os padrões do `contexto.md` sem desvios
- Detecção de erro: a IA identificou e corrigiu automaticamente o `widget_test.dart` com referência quebrada

## Limitações do uso da IA

- A IA não consegue executar o app em um emulador/dispositivo para validação visual
- Dependência de contexto: sem o `contexto.md` e o enunciado bem descritos, o código gerado poderia não seguir os padrões exigidos
