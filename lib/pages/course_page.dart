import 'package:flutter/material.dart';
import '../controllers/course_controller.dart';
import '../models/course.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final _controller = CourseController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.load();
    if (mounted) setState(() {});
  }

  void _showForm({Course? course}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CourseForm(
        course: course,
        onSave: (c) async {
          if (course == null) {
            await _controller.add(c);
          } else {
            await _controller.edit(c);
          }
          if (mounted) {
            setState(() {});
            _showSnack(course == null ? 'Curso cadastrado!' : 'Curso atualizado!');
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover curso'),
        content: Text('Deseja remover "${course.name}"?'),
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
      await _controller.remove(course.courseId!);
      if (mounted) {
        setState(() {});
        _showSnack('Curso removido!');
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
    final courses = _controller.courses;

    return Scaffold(
      appBar: AppBar(title: const Text('Cursos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: courses.isEmpty
              ? _emptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (_, i) {
                    final c = courses[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(c.name[0].toUpperCase())),
                        title: Text(c.name),
                        subtitle: Text('${c.duration}  •  Coord: ${c.coordinator}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showForm(course: c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(c),
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
        Icon(Icons.menu_book_outlined, size: 72, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text('Nenhum curso cadastrado', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Toque em + para adicionar', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CourseForm extends StatefulWidget {
  final Course? course;
  final Future<void> Function(Course) onSave;

  const _CourseForm({this.course, required this.onSave});

  @override
  State<_CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<_CourseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _duration;
  late final TextEditingController _coordinator;
  late final TextEditingController _description;

  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.course?.name);
    _duration = TextEditingController(text: widget.course?.duration);
    _coordinator = TextEditingController(text: widget.course?.coordinator);
    _description = TextEditingController(text: widget.course?.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _duration.dispose();
    _coordinator.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final course = Course(
      courseId: widget.course?.courseId,
      name: _name.text.trim(),
      duration: _duration.text.trim(),
      coordinator: _coordinator.text.trim(),
      description: _description.text.trim(),
    );
    await widget.onSave(course);
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Editar Curso' : 'Novo Curso',
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
                controller: _duration,
                decoration: const InputDecoration(labelText: 'Duração * (ex: 4 anos)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a duração' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coordinator,
                decoration: const InputDecoration(labelText: 'Coordenador *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o coordenador' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Descrição *'),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
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
