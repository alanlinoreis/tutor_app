class Student {
  final int? studentId;
  final String name;
  final String registrationNumber;
  final String email;
  final String course;
  final int? tutorId;       // FK → tutors.tutorId (nullable: aluno pode não ter tutor)
  final String? tutorName;  // desnormalizado para exibição rápida

  Student({
    this.studentId,
    required this.name,
    required this.registrationNumber,
    required this.email,
    required this.course,
    this.tutorId,
    this.tutorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'registrationNumber': registrationNumber,
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
      registrationNumber: map['registrationNumber'] as String,
      email: map['email'] as String,
      course: map['course'] as String,
      tutorId: map['tutorId'] as int?,
      tutorName: map['tutorName'] as String?,
    );
  }
}
