class Student {
  final int? studentId;
  final String name;
  final String email;
  final String course;
  final int? tutorId;
  final String? tutorName;

  Student({
    this.studentId,
    required this.name,
    required this.email,
    required this.course,
    this.tutorId,
    this.tutorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'email': email,
      'course': course,
      'tutorId': tutorId,
      'tutorName': tutorName,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['studentId'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      course: map['course'] as String,
      tutorId: map['tutorId'] as int?,
      tutorName: map['tutorName'] as String?,
    );
  }
}
