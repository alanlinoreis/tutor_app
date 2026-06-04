import '../models/student.dart';
import '../repositories/student_repository.dart';

class StudentController {
  final _repository = StudentRepository();

  List<Student> students = [];

  Future<void> load() async {
    students = await _repository.getAll();
  }

  Future<void> add(Student student) async {
    await _repository.insert(student);
    await load();
  }

  Future<void> edit(Student student) async {
    await _repository.update(student);
    await load();
  }

  Future<void> remove(int id) async {
    await _repository.delete(id);
    await load();
  }
}
