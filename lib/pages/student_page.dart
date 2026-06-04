import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import '../models/student.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _controller = StudentController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.load();
    if (mounted) setState(() {});
  }

  void _showForm({Student? student}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StudentForm(
        student: student,
        onSave: (s) async {
          if (student == null) {
            await _controller.add(s);
          } else {
            await _controller.edit(s);
          }
          if (mounted) {
            setState(() {});
            _showSnack(student == null ? 'Aluno cadastrado!' : 'Aluno atualizado!');
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover aluno'),
        content: Text('Deseja remover "${student.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.remove(student.studentId!);
      if (mounted) {
        setState(() {});
        _showSnack('Aluno removido!');
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = _controller.students;

    return Scaffold(
      appBar: AppBar(title: const Text('Alunos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: students.isEmpty
              ? _emptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (_, i) {
                    final s = students[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(s.name[0].toUpperCase())),
                        title: Text(s.name),
                        subtitle: Text('${s.registrationNumber}  •  ${s.course}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showForm(student: s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(s),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, size: 72, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text('Nenhum aluno cadastrado', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Toque em + para adicionar', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _StudentForm extends StatefulWidget {
  final Student? student;
  final Future<void> Function(Student) onSave;

  const _StudentForm({this.student, required this.onSave});

  @override
  State<_StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<_StudentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _registration;
  late final TextEditingController _email;
  late final TextEditingController _course;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.student?.name);
    _registration = TextEditingController(text: widget.student?.registrationNumber);
    _email = TextEditingController(text: widget.student?.email);
    _course = TextEditingController(text: widget.student?.course);
  }

  @override
  void dispose() {
    _name.dispose();
    _registration.dispose();
    _email.dispose();
    _course.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final student = Student(
      studentId: widget.student?.studentId,
      name: _name.text.trim(),
      registrationNumber: _registration.text.trim(),
      email: _email.text.trim(),
      course: _course.text.trim(),
    );
    await widget.onSave(student);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Editar Aluno' : 'Novo Aluno',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nome *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registration,
                decoration: const InputDecoration(labelText: 'Matrícula *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a matrícula' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail *'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _course,
                decoration: const InputDecoration(labelText: 'Curso *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o curso' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
