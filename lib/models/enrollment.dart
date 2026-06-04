import '../utils/enrollment_status.dart';

class Enrollment {
  final int? enrollmentId;
  final String studentName;
  final String courseName;
  final String enrollmentDate;
  final EnrollmentStatus status;

  Enrollment({
    this.enrollmentId,
    required this.studentName,
    required this.courseName,
    required this.enrollmentDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'enrollmentId': enrollmentId,
      'studentName': studentName,
      'courseName': courseName,
      'enrollmentDate': enrollmentDate,
      'status': status.name,
    };
  }

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      enrollmentId: map['enrollmentId'] as int?,
      studentName: map['studentName'] as String,
      courseName: map['courseName'] as String,
      enrollmentDate: map['enrollmentDate'] as String,
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EnrollmentStatus.ativa,
      ),
    );
  }
}
