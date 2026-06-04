# PROMPTS — Histórico de interação com a IA

## Prompt inicial

> "A partir do contexto presente nessa pasta e o enunciado do exercício que está no pdf faça o que é pedido. No pdf, só precisa fazer o caso de estudo de Alan Lino dos Reis, porque ali está mostrando vários."

**Contexto fornecido:** arquivo `contexto.md` com padrões de desenvolvimento + PDF com o enunciado da atividade bônus.

**Enunciado identificado:** Alan Lino Dos Reis — Classe `Tutor`  
Campos: `tutorId`, `name`, `phone`, `email`

---

## Prompt de autorização completa

> "Quero que você faça tudo, pode mandar bala, até executar o git para subir todos os arquivos."

A IA foi autorizada a criar todos os arquivos, rodar `flutter pub get`, `flutter analyze`, inicializar o repositório git e realizar o commit inicial.

---

## Solicitações realizadas pela IA ao longo do processo

1. Criação do projeto com `flutter create tutor_app`
2. Geração de `lib/models/tutor.dart`
3. Geração de `lib/database/app_database.dart`
4. Geração de `lib/repositories/tutor_repository.dart`
5. Geração de `lib/controllers/tutor_controller.dart`
6. Geração de `lib/pages/tutor_page.dart`
7. Reescrita de `lib/main.dart` com `ThemeData` centralizado e Material 3 dark
8. Adição de `sqflite` e `path` no `pubspec.yaml`
9. Correção do `test/widget_test.dart` (referência à `MyApp` → `TutorApp`)
10. Geração de `README.md` e `docs/ia/`
