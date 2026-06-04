import 'package:flutter/material.dart';
import '../controllers/tutor_controller.dart';
import '../models/tutor.dart';

class TutorPage extends StatefulWidget {
  const TutorPage({super.key});

  @override
  State<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends State<TutorPage> {
  final _controller = TutorController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.load();
    if (mounted) setState(() {});
  }

  void _showForm({Tutor? tutor}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TutorForm(
        tutor: tutor,
        onSave: (t) async {
          if (tutor == null) {
            await _controller.add(t);
          } else {
            await _controller.edit(t);
          }
          if (mounted) {
            setState(() {});
            _showSnack(tutor == null ? 'Tutor cadastrado!' : 'Tutor atualizado!');
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Tutor tutor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover tutor'),
        content: Text('Deseja remover "${tutor.name}"?'),
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
      await _controller.remove(tutor.tutorId!);
      if (mounted) {
        setState(() {});
        _showSnack('Tutor removido!');
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
    final tutors = _controller.tutors;

    return Scaffold(
      appBar: AppBar(title: const Text('Tutores Acadêmicos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: tutors.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tutors.length,
                  itemBuilder: (_, i) {
                    final t = tutors[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(t.name[0].toUpperCase()),
                        ),
                        title: Text(t.name),
                        subtitle: Text('${t.phone}  •  ${t.email}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showForm(tutor: t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(t),
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.school_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'Nenhum tutor cadastrado',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Toque em + para adicionar',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TutorForm extends StatefulWidget {
  final Tutor? tutor;
  final Future<void> Function(Tutor) onSave;

  const _TutorForm({this.tutor, required this.onSave});

  @override
  State<_TutorForm> createState() => _TutorFormState();
}

class _TutorFormState extends State<_TutorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  bool get _isEditing => widget.tutor != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.tutor?.name);
    _phone = TextEditingController(text: widget.tutor?.phone);
    _email = TextEditingController(text: widget.tutor?.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final tutor = Tutor(
      tutorId: widget.tutor?.tutorId,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
    );

    await widget.onSave(tutor);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
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
                _isEditing ? 'Editar Tutor' : 'Novo Tutor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nome *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Telefone *'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o telefone' : null,
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
