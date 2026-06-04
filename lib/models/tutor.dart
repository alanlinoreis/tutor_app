class Tutor {
  final int? tutorId;
  final String name;
  final String phone;
  final String email;

  Tutor({
    this.tutorId,
    required this.name,
    required this.phone,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'tutorId': tutorId,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  factory Tutor.fromMap(Map<String, dynamic> map) {
    return Tutor(
      tutorId: map['tutorId'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
    );
  }

  Tutor copyWith({
    int? tutorId,
    String? name,
    String? phone,
    String? email,
  }) {
    return Tutor(
      tutorId: tutorId ?? this.tutorId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
