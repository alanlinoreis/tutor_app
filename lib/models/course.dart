class Course {
  final int? courseId;
  final String name;
  final String duration;
  final String coordinator;
  final String description;

  Course({
    this.courseId,
    required this.name,
    required this.duration,
    required this.coordinator,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'name': name,
      'duration': duration,
      'coordinator': coordinator,
      'description': description,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['courseId'] as int?,
      name: map['name'] as String,
      duration: map['duration'] as String,
      coordinator: map['coordinator'] as String,
      description: map['description'] as String,
    );
  }
}
