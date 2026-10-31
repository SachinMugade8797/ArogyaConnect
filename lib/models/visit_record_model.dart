class VisitRecordModel {
  final String id;
  final String appointmentId;
  final String profileId;
  final String doctorProfileId;
  final String? diagnosis;
  final String? notes;
  final String? testsAdvised;
  final String? followUpDate;
  final DateTime createdAt;

  VisitRecordModel({
    required this.id,
    required this.appointmentId,
    required this.profileId,
    required this.doctorProfileId,
    this.diagnosis,
    this.notes,
    this.testsAdvised,
    this.followUpDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'profile_id': profileId,
      'doctor_profile_id': doctorProfileId,
      'diagnosis': diagnosis,
      'notes': notes,
      'tests_advised': testsAdvised,
      'follow_up_date': followUpDate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VisitRecordModel.fromMap(Map<String, dynamic> map) {
    return VisitRecordModel(
      id: map['id'] as String,
      appointmentId: map['appointment_id'] as String,
      profileId: map['profile_id'] as String,
      doctorProfileId: map['doctor_profile_id'] as String,
      diagnosis: map['diagnosis'] as String?,
      notes: map['notes'] as String?,
      testsAdvised: map['tests_advised'] as String?,
      followUpDate: map['follow_up_date'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
