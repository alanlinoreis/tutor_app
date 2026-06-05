import '../models/enrollment.dart';
import '../repositories/enrollment_repository.dart';

class EnrollmentController {
  final _repository = EnrollmentRepository();

  List<Enrollment> enrollments = [];

  Future<void> load() async {
    enrollments = await _repository.getAll();
  }

  Future<void> add(Enrollment enrollment) async {
    // Gera o código de matrícula automaticamente no momento do cadastro
    final code = _generateCode();
    final withCode = Enrollment(
      registrationCode: code,
      studentName: enrollment.studentName,
      courseName: enrollment.courseName,
      enrollmentDate: enrollment.enrollmentDate,
      status: enrollment.status,
    );
    await _repository.insert(withCode);
    await load();
  }

  Future<void> edit(Enrollment enrollment) async {
    await _repository.update(enrollment);
    await load();
  }

  Future<void> remove(int id) async {
    await _repository.delete(id);
    await load();
  }

  /// Formato: MAT-AAAAMM-XXXX (ano + mês + 4 dígitos do timestamp)
  String _generateCode() {
    final now = DateTime.now();
    final seq = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    return 'MAT-${now.year}$month-$seq';
  }
}
