import '../models/enrollment.dart';
import '../repositories/enrollment_repository.dart';

class EnrollmentController {
  final _repository = EnrollmentRepository();

  List<Enrollment> enrollments = [];

  Future<void> load() async {
    enrollments = await _repository.getAll();
  }

  Future<void> add(Enrollment enrollment) async {
    await _repository.insert(enrollment);
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
}
