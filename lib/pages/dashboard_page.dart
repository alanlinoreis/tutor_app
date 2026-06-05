import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../models/tutor.dart';
import '../repositories/course_repository.dart';
import '../repositories/enrollment_repository.dart';
import '../repositories/student_repository.dart';
import '../repositories/tutor_repository.dart';
import '../utils/enrollment_status.dart';

// Agrupa todos os dados de uma matrícula num único objeto para exibição
class _EnrollmentDetail {
  final Enrollment enrollment;
  final Student? student;
  final Course? course;
  final Tutor? tutor;

  const _EnrollmentDetail({
    required this.enrollment,
    this.student,
    this.course,
    this.tutor,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<_EnrollmentDetail> _all = [];
  List<_EnrollmentDetail> _filtered = [];
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final enrollments = await EnrollmentRepository().getAll();
    final students = await StudentRepository().getAll();
    final courses = await CourseRepository().getAll();
    final tutors = await TutorRepository().getAll();

    // Monta mapa para join O(1)
    final studentMap = {for (final s in students) s.name: s};
    final courseMap = {for (final c in courses) c.name: c};
    final tutorMap = {for (final t in tutors) t.tutorId: t};

    final details = enrollments.map((e) {
      final student = studentMap[e.studentName];
      return _EnrollmentDetail(
        enrollment: e,
        student: student,
        course: courseMap[e.courseName],
        tutor: student?.tutorId != null ? tutorMap[student!.tutorId] : null,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _all = details;
        _loading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? List.of(_all)
          : _all
              .where((d) =>
                  d.enrollment.studentName.toLowerCase().contains(query))
              .toList();
    });
  }

  void _openDetail(_EnrollmentDetail detail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DetailSheet(detail: detail),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome do aluno…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: _filtered.isEmpty ? _emptyState() : _list(),
                ),
              ),
            ),
    );
  }

  Widget _list() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final d = _filtered[i];
        final e = d.enrollment;
        return Card(
          child: ListTile(
            onTap: () => _openDetail(d),
            leading: CircleAvatar(
              child: Text(e.studentName[0].toUpperCase()),
            ),
            title: Text(e.studentName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.courseName),
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
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
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
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    final searching = _searchController.text.isNotEmpty;
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(
          searching ? Icons.search_off : Icons.assignment_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            searching
                ? 'Nenhum resultado para "${_searchController.text}"'
                : 'Nenhuma matrícula cadastrada',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        if (!searching) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Cadastre alunos, cursos e matrículas para visualizar aqui',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet de detalhe
// ─────────────────────────────────────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  final _EnrollmentDetail detail;

  const _DetailSheet({required this.detail});

  @override
  Widget build(BuildContext context) {
    final e = detail.enrollment;
    final s = detail.student;
    final c = detail.course;
    final t = detail.tutor;
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alça de arraste
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar + nome
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      e.studentName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.studentName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          e.registrationCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.outline,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: e.status),
                ],
              ),

              const SizedBox(height: 24),
              _Section(
                icon: Icons.person_outline,
                title: 'Aluno',
                children: [
                  _InfoRow('E-mail', s?.email ?? e.studentName),
                  _InfoRow('Curso informado', s?.course ?? e.courseName),
                ],
              ),

              const SizedBox(height: 16),
              _Section(
                icon: Icons.school_outlined,
                title: 'Tutor responsável',
                children: t != null
                    ? [
                        _InfoRow('Nome', t.name),
                        _InfoRow('Telefone', t.phone),
                        _InfoRow('E-mail', t.email),
                      ]
                    : [
                        _InfoRow('', 'Nenhum tutor vinculado a este aluno'),
                      ],
              ),

              const SizedBox(height: 16),
              _Section(
                icon: Icons.menu_book_outlined,
                title: 'Curso',
                children: c != null
                    ? [
                        _InfoRow('Nome', c.name),
                        _InfoRow('Duração', c.duration),
                        _InfoRow('Coordenador', c.coordinator),
                        _InfoRow('Descrição', c.description),
                      ]
                    : [
                        _InfoRow('', e.courseName),
                      ],
              ),

              const SizedBox(height: 16),
              _Section(
                icon: Icons.assignment_outlined,
                title: 'Matrícula',
                children: [
                  _InfoRow('Código', e.registrationCode),
                  _InfoRow('Data', e.enrollmentDate),
                  _InfoRow('Status', e.status.label),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: label.isEmpty
          ? Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final EnrollmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color color;
    switch (status) {
      case EnrollmentStatus.ativa:
        color = cs.primary;
      case EnrollmentStatus.concluida:
        color = cs.tertiary;
      case EnrollmentStatus.cancelada:
        color = cs.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
