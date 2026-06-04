import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseController {
  final _repository = CourseRepository();

  List<Course> courses = [];

  Future<void> load() async {
    courses = await _repository.getAll();
  }

  Future<void> add(Course course) async {
    await _repository.insert(course);
    await load();
  }

  Future<void> edit(Course course) async {
    await _repository.update(course);
    await load();
  }

  Future<void> remove(int id) async {
    await _repository.delete(id);
    await load();
  }
}
