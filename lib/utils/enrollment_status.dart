enum EnrollmentStatus { ativa, cancelada, concluida }

extension EnrollmentStatusLabel on EnrollmentStatus {
  String get label {
    switch (this) {
      case EnrollmentStatus.ativa:
        return 'Ativa';
      case EnrollmentStatus.cancelada:
        return 'Cancelada';
      case EnrollmentStatus.concluida:
        return 'Concluída';
    }
  }
}
