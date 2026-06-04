# Tutores Acadêmicos

Funcionalidade implementada: **Cadastro de Tutores** (`Tutor`)

## Descrição

Aplicativo Flutter para gerenciar tutores acadêmicos de uma instituição de ensino. Um tutor é um professor ou orientador responsável por acompanhar estudantes durante sua trajetória acadêmica.

O app permite cadastrar, listar, editar e remover tutores, com persistência local usando SQLite.

## Modelo de negócio

| Campo | Tipo Dart | Coluna SQLite | Descrição |
|---|---|---|---|
| `tutorId` | `int?` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Identificador único |
| `name` | `String` | `TEXT NOT NULL` | Nome completo do tutor |
| `phone` | `String` | `TEXT NOT NULL` | Telefone de contato |
| `email` | `String` | `TEXT NOT NULL` | E-mail institucional |

## Funcionalidades implementadas

- Cadastro de tutores
- Listagem com nome, telefone e e-mail
- Edição de registros existentes
- Remoção com confirmação via `AlertDialog`
- Feedback ao usuário via `SnackBar`
- Persistência local com SQLite (`sqflite`)
- Estado vazio com mensagem orientativa

## Tecnologias utilizadas

- Flutter 3.x
- Dart 3.x
- SQLite via [`sqflite`](https://pub.dev/packages/sqflite)
- [`path`](https://pub.dev/packages/path)
- Material 3 com tema dark

## Arquitetura utilizada

O projeto segue a arquitetura em camadas:

```
AppDatabase → TutorRepository → TutorController → TutorPage
```

| Camada | Responsabilidade |
|---|---|
| **Model** (`Tutor`) | Representa o dado; converte para/de `Map` via `toMap()` e `fromMap()` |
| **AppDatabase** | Singleton que cria e abre o banco SQLite; define a tabela `tutors` |
| **TutorRepository** | Executa os comandos SQL (insert, query, update, delete) |
| **TutorController** | Mantém a lista em memória; chama o repository; nunca acessa SQL |
| **TutorPage** | Interface do usuário; usa somente o Controller |

**Fluxo de persistência:**
1. Usuário preenche o formulário e salva
2. `TutorPage` chama `TutorController.add(tutor)`
3. Controller chama `TutorRepository.insert(tutor)`
4. Repository converte via `tutor.toMap()` e executa `db.insert('tutors', map)`
5. Controller recarrega a lista com `getAll()` e atualiza a UI

## Estrutura de pastas

```
lib/
├── database/
│   └── app_database.dart       # Singleton SQLite, criação da tabela
├── models/
│   └── tutor.dart              # Classe Tutor com toMap/fromMap
├── repositories/
│   └── tutor_repository.dart   # CRUD via sqflite
├── controllers/
│   └── tutor_controller.dart   # Lista em memória + lógica
├── pages/
│   └── tutor_page.dart         # Tela de listagem e formulário
└── main.dart                   # ThemeData Material 3 dark

docs/
└── ia/
    ├── GUIDELINES.md           # Regras fornecidas à IA
    ├── PROMPTS.md              # Histórico de prompts
    └── REFLEXAO.md             # Reflexão sobre uso da IA
```

## Como clonar o projeto

```bash
git clone <URL_DO_REPOSITORIO>
cd tutor_app
```

## Como executar

```bash
# Instalar dependências
flutter pub get

# Executar
flutter run
```

## Autor

Alan Lino Dos Reis

---

> Documentação de uso de IA disponível em [`docs/ia/`](docs/ia/)
