# Gestão Acadêmica

Sistema de gestão acadêmica com 4 funcionalidades completas: Tutores, Alunos, Cursos e Matrículas.

## Descrição

Aplicativo Flutter para gerenciar dados de uma instituição de ensino. Cada módulo possui CRUD completo com persistência local via SQLite.

**Atividade 1 (obrigatória):** Tutores Acadêmicos  
**Atividade 2 (bônus):** Alunos, Cursos e Matrículas

## Modelos de negócio

### Tutor
| Campo | Tipo Dart | Coluna SQLite | Descrição |
|---|---|---|---|
| `tutorId` | `int?` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Identificador único |
| `name` | `String` | `TEXT NOT NULL` | Nome completo |
| `phone` | `String` | `TEXT NOT NULL` | Telefone de contato |
| `email` | `String` | `TEXT NOT NULL` | E-mail institucional |

### Student
| Campo | Tipo Dart | Coluna SQLite | Descrição |
|---|---|---|---|
| `studentId` | `int?` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Identificador único |
| `name` | `String` | `TEXT NOT NULL` | Nome completo |
| `registrationNumber` | `String` | `TEXT NOT NULL` | Número de matrícula |
| `email` | `String` | `TEXT NOT NULL` | E-mail |
| `course` | `String` | `TEXT NOT NULL` | Curso do aluno |

### Course
| Campo | Tipo Dart | Coluna SQLite | Descrição |
|---|---|---|---|
| `courseId` | `int?` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Identificador único |
| `name` | `String` | `TEXT NOT NULL` | Nome do curso |
| `duration` | `String` | `TEXT NOT NULL` | Duração (ex: 4 anos) |
| `coordinator` | `String` | `TEXT NOT NULL` | Nome do coordenador |
| `description` | `String` | `TEXT NOT NULL` | Descrição do curso |

### Enrollment
| Campo | Tipo Dart | Coluna SQLite | Descrição |
|---|---|---|---|
| `enrollmentId` | `int?` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Identificador único |
| `studentName` | `String` | `TEXT NOT NULL` | Nome do aluno |
| `courseName` | `String` | `TEXT NOT NULL` | Nome do curso |
| `enrollmentDate` | `String` | `TEXT NOT NULL` | Data da matrícula |
| `status` | `EnrollmentStatus` | `TEXT NOT NULL` | Ativa / Cancelada / Concluída |

## Funcionalidades implementadas

- Cadastro, listagem, edição e remoção de Tutores
- Cadastro, listagem, edição e remoção de Alunos
- Cadastro, listagem, edição e remoção de Cursos
- Cadastro, listagem, edição e remoção de Matrículas (com DatePicker e status via enum)
- Confirmação de remoção via `AlertDialog`
- Feedback via `SnackBar`
- Persistência local com SQLite (`sqflite`)
- Estado vazio com mensagem orientativa em todos os módulos
- Navegação por `NavigationBar` com 4 abas

## Tecnologias utilizadas

- Flutter 3.x / Dart 3.x
- Material 3 com tema dark
- SQLite via [`sqflite`](https://pub.dev/packages/sqflite)
- [`path`](https://pub.dev/packages/path)

## Arquitetura utilizada

```
AppDatabase → Repository → Controller → Page
```

| Camada | Responsabilidade |
|---|---|
| **Model** | Representa o dado; `toMap()` e `fromMap()` fazem a ponte com o SQLite |
| **AppDatabase** | Singleton que cria/abre o banco e define todas as tabelas |
| **Repository** | Única camada com SQL; métodos `insert`, `getAll`, `update`, `delete` |
| **Controller** | Mantém lista em memória; delega operações ao Repository |
| **Page** | Interface do usuário; usa somente o Controller |

**Fluxo de persistência:**
1. Usuário preenche o formulário e salva
2. `Page` chama `Controller.add(objeto)`
3. `Controller` chama `Repository.insert(objeto)`
4. `Repository` converte via `objeto.toMap()` e executa `db.insert('tabela', map)`
5. `Controller` recarrega a lista via `getAll()` e a `Page` chama `setState`

## Estrutura de pastas

```
lib/
├── database/
│   └── app_database.dart            # Singleton SQLite, 4 tabelas
├── models/
│   ├── tutor.dart
│   ├── student.dart
│   ├── course.dart
│   └── enrollment.dart
├── repositories/
│   ├── tutor_repository.dart
│   ├── student_repository.dart
│   ├── course_repository.dart
│   └── enrollment_repository.dart
├── controllers/
│   ├── tutor_controller.dart
│   ├── student_controller.dart
│   ├── course_controller.dart
│   └── enrollment_controller.dart
├── pages/
│   ├── tutor_page.dart
│   ├── student_page.dart
│   ├── course_page.dart
│   └── enrollment_page.dart
├── utils/
│   └── enrollment_status.dart       # Enum com extension label
└── main.dart                        # ThemeData + NavigationBar

docs/
└── ia/
    ├── GUIDELINES.md
    ├── PROMPTS.md
    └── REFLEXAO.md
```

## Como clonar o projeto

```bash
git clone https://github.com/alanlinoreis/tutor_app.git
cd tutor_app
```

## Como executar

```bash
flutter pub get
flutter run
```

## Autor

Alan Lino Dos Reis

---

> Documentação de uso de IA disponível em [`docs/ia/`](docs/ia/)
