class Student {
  final int? studentId;
  final String name;
  final String registrationNumber;
  final String email;
  final String course;

  Student({
    this.studentId,
    required this.name,
    required this.registrationNumber,
    required this.email,
    required this.course,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'registrationNumber': registrationNumber,
      'email': email,
      'course': course,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['studentId'] as int?,
      name: map['name'] as String,
      registrationNumber: map['registrationNumber'] as String,
      email: map['email'] as String,
      course: map['course'] as String,
    );
  }
}
