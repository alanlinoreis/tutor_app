import '../models/tutor.dart';
import '../repositories/tutor_repository.dart';

class TutorController {
  final _repository = TutorRepository();

  List<Tutor> tutors = [];

  Future<void> load() async {
    tutors = await _repository.getAll();
  }

  Future<void> add(Tutor tutor) async {
    await _repository.insert(tutor);
    await load();
  }

  Future<void> edit(Tutor tutor) async {
    await _repository.update(tutor);
    await load();
  }

  Future<void> remove(int id) async {
    await _repository.delete(id);
    await load();
  }
}
