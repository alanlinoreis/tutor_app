import 'package:flutter/material.dart';
import '../controllers/enrollment_controller.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../repositories/course_repository.dart';
import '../repositories/student_repository.dart';
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

  Future<void> _showForm({Enrollment? enrollment}) async {
    final students = await StudentRepository().getAll();
    final courses = await CourseRepository().getAll();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EnrollmentForm(
        enrollment: enrollment,
        students: students,
        courses: courses,
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
                        leading: CircleAvatar(
                          child: Text(e.studentName[0].toUpperCase()),
                        ),
                        title: Text(e.studentName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.courseName}  •  ${e.enrollmentDate}'),
                            Text(
                              e.registrationCode,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
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
        Icon(Icons.assignment_outlined, size: 72,
            color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text('Nenhuma matrícula cadastrada',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Toque em + para adicionar',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EnrollmentForm extends StatefulWidget {
  final Enrollment? enrollment;
  final List<Student> students;
  final List<Course> courses;
  final Future<void> Function(Enrollment) onSave;

  const _EnrollmentForm({
    this.enrollment,
    required this.students,
    required this.courses,
    required this.onSave,
  });

  @override
  State<_EnrollmentForm> createState() => _EnrollmentFormState();
}

class _EnrollmentFormState extends State<_EnrollmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  Student? _selectedStudent;
  Course? _selectedCourse;
  late EnrollmentStatus _status;

  bool get _isEditing => widget.enrollment != null;

  @override
  void initState() {
    super.initState();
    _dateController.text = widget.enrollment?.enrollmentDate ?? '';
    _status = widget.enrollment?.status ?? EnrollmentStatus.ativa;

    if (_isEditing) {
      // Pré-seleciona aluno e curso ao editar
      _selectedStudent = widget.students.where(
        (s) => s.name == widget.enrollment!.studentName,
      ).firstOrNull;
      _selectedCourse = widget.courses.where(
        (c) => c.name == widget.enrollment!.courseName,
      ).firstOrNull;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
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
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final enrollment = Enrollment(
      enrollmentId: widget.enrollment?.enrollmentId,
      registrationCode: widget.enrollment?.registrationCode ?? '',
      studentName: _selectedStudent!.name,
      courseName: _selectedCourse!.name,
      enrollmentDate: _dateController.text.trim(),
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

              // ── Autocomplete: Aluno ──────────────────────────────────────
              _AutocompleteField<Student>(
                label: 'Aluno *',
                initialText: widget.enrollment?.studentName,
                options: widget.students,
                displayString: (s) => s.name,
                onSelected: (s) => setState(() => _selectedStudent = s),
                onCleared: () => setState(() => _selectedStudent = null),
                validator: (_) => _selectedStudent == null
                    ? 'Selecione um aluno da lista'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Autocomplete: Curso ──────────────────────────────────────
              _AutocompleteField<Course>(
                label: 'Curso *',
                initialText: widget.enrollment?.courseName,
                options: widget.courses,
                displayString: (c) => c.name,
                onSelected: (c) => setState(() => _selectedCourse = c),
                onCleared: () => setState(() => _selectedCourse = null),
                validator: (_) => _selectedCourse == null
                    ? 'Selecione um curso da lista'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Data ─────────────────────────────────────────────────────
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Data de matrícula *',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: _pickDate,
                  ),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a data' : null,
              ),
              const SizedBox(height: 12),

              // ── Status ────────────────────────────────────────────────────
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
                child: Text(_isEditing ? 'Salvar alterações' : 'Matricular'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget genérico de autocomplete com validação integrada ao Form
// ─────────────────────────────────────────────────────────────────────────────

class _AutocompleteField<T extends Object> extends StatefulWidget {
  final String label;
  final String? initialText;
  final List<T> options;
  final String Function(T) displayString;
  final ValueChanged<T> onSelected;
  final VoidCallback onCleared;
  final FormFieldValidator<String> validator;

  const _AutocompleteField({
    required this.label,
    this.initialText,
    required this.options,
    required this.displayString,
    required this.onSelected,
    required this.onCleared,
    required this.validator,
  });

  @override
  State<_AutocompleteField<T>> createState() => _AutocompleteFieldState<T>();
}

class _AutocompleteFieldState<T extends Object>
    extends State<_AutocompleteField<T>> {
  // Controlador interno exposto ao FormField para validação
  final _textController = TextEditingController();
  bool _validSelection = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
      _validSelection = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme;

    return FormField<String>(
      validator: (_) => widget.validator(_textController.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<T>(
              initialValue: widget.initialText != null
                  ? TextEditingValue(text: widget.initialText!)
                  : null,
              displayStringForOption: widget.displayString,
              optionsBuilder: (textValue) {
                final query = textValue.text.toLowerCase();
                if (query.isEmpty) return const [];
                return widget.options.where(
                  (o) => widget.displayString(o).toLowerCase().contains(query),
                );
              },
              onSelected: (option) {
                _textController.text = widget.displayString(option);
                _validSelection = true;
                widget.onSelected(option);
                field.didChange(widget.displayString(option));
              },
              fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
                // Detecta quando o usuário apaga a seleção
                controller.addListener(() {
                  if (_validSelection &&
                      controller.text != _textController.text) {
                    _validSelection = false;
                    widget.onCleared();
                    field.didChange(controller.text);
                  }
                });

                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    errorText: field.errorText,
                    border: inputTheme.border,
                    filled: inputTheme.filled,
                  ),
                  onChanged: (_) => field.didChange(controller.text),
                );
              },
              optionsViewBuilder: (ctx, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (_, i) {
                          final option = options.elementAt(i);
                          return ListTile(
                            title: Text(widget.displayString(option)),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
