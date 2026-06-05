import 'package:flutter/material.dart';
import '../controllers/enrollment_controller.dart';
import '../models/enrollment.dart';
import '../utils/enrollment_status.dart';

class EnrollmentPage extends StatefulWidget {
  const EnrollmentPage({super.key});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  final _controller = EnrollmentController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.load();
    if (mounted) setState(() {});
  }

  void _showForm({Enrollment? enrollment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EnrollmentForm(
        enrollment: enrollment,
        onSave: (e) async {
          if (enrollment == null) {
            await _controller.add(e);
          } else {
            await _controller.edit(e);
          }
          if (mounted) {
            setState(() {});
            _showSnack(enrollment == null ? 'Matrícula cadastrada!' : 'Matrícula atualizada!');
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Enrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover matrícula'),
        content: Text('Deseja remover a matrícula de "${enrollment.studentName}"?'),
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
      await _controller.remove(enrollment.enrollmentId!);
      if (mounted) {
        setState(() {});
        _showSnack('Matrícula removida!');
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _statusColor(EnrollmentStatus status, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case EnrollmentStatus.ativa:
        return cs.primary;
      case EnrollmentStatus.concluida:
        return cs.tertiary;
      case EnrollmentStatus.cancelada:
        return cs.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollments = _controller.enrollments;

    return Scaffold(
      appBar: AppBar(title: const Text('Matrículas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: enrollments.isEmpty
              ? _emptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: enrollments.length,
                  itemBuilder: (_, i) {
                    final e = enrollments[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(e.studentName[0].toUpperCase())),
                        title: Text(e.studentName),
                        subtitle: Text('${e.courseName}  •  ${e.enrollmentDate}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                e.status.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _statusColor(e.status, context),
                                ),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showForm(enrollment: e),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(e),
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
        Icon(Icons.assignment_outlined, size: 72, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text('Nenhuma matrícula cadastrada', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Toque em + para adicionar', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EnrollmentForm extends StatefulWidget {
  final Enrollment? enrollment;
  final Future<void> Function(Enrollment) onSave;

  const _EnrollmentForm({this.enrollment, required this.onSave});

  @override
  State<_EnrollmentForm> createState() => _EnrollmentFormState();
}

class _EnrollmentFormState extends State<_EnrollmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentName;
  late final TextEditingController _courseName;
  late final TextEditingController _date;
  late EnrollmentStatus _status;

  bool get _isEditing => widget.enrollment != null;

  @override
  void initState() {
    super.initState();
    _studentName = TextEditingController(text: widget.enrollment?.studentName);
    _courseName = TextEditingController(text: widget.enrollment?.courseName);
    _date = TextEditingController(text: widget.enrollment?.enrollmentDate);
    _status = widget.enrollment?.status ?? EnrollmentStatus.ativa;
  }

  @override
  void dispose() {
    _studentName.dispose();
    _courseName.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _date.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final enrollment = Enrollment(
      enrollmentId: widget.enrollment?.enrollmentId,
      studentName: _studentName.text.trim(),
      courseName: _courseName.text.trim(),
      enrollmentDate: _date.text.trim(),
      status: _status,
    );
    await widget.onSave(enrollment);
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
                _isEditing ? 'Editar Matrícula' : 'Nova Matrícula',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _studentName,
                decoration: const InputDecoration(labelText: 'Nome do aluno *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome do aluno' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courseName,
                decoration: const InputDecoration(labelText: 'Nome do curso *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome do curso' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _date,
                decoration: InputDecoration(
                  labelText: 'Data de matrícula *',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: _pickDate,
                  ),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a data' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EnrollmentStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status *'),
                items: EnrollmentStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
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
