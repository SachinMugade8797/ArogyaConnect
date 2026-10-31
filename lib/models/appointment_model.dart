class AppointmentModel {
  final String id;
  final String patientId;
  final String? profileId;
  final String doctorProfileId;
  final String doctorName;
  final String doctorSpeciality;
  final String clinicName;
  final DateTime appointmentAt;
  final String? reason;
  final String status; // 'pending' | 'confirmed' | 'waiting' | 'in_consultation' | 'completed' | 'cancelled'
  final String mode;   // 'IN_PERSON' | 'VIDEO'
  final int? tokenNumber;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    this.profileId,
    required this.doctorProfileId,
    required this.doctorName,
    required this.doctorSpeciality,
    required this.clinicName,
    required this.appointmentAt,
    this.reason,
    this.status = 'confirmed',
    this.mode = 'IN_PERSON',
    this.tokenNumber,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'profile_id': profileId,
      'doctor_profile_id': doctorProfileId,
      'doctor_name': doctorName,
      'doctor_speciality': doctorSpeciality,
      'clinic_name': clinicName,
      'appointment_at': appointmentAt.toIso8601String(),
      'reason': reason,
      'status': status,
      'mode': mode,
      'token_number': tokenNumber,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      profileId: map['profile_id'] as String?,
      doctorProfileId: map['doctor_profile_id'] as String,
      doctorName: map['doctor_name'] as String? ?? 'Doctor',
      doctorSpeciality: map['doctor_speciality'] as String? ?? 'General Physician',
      clinicName: map['clinic_name'] as String? ?? 'Arogya Clinic',
      appointmentAt: DateTime.parse(map['appointment_at'] as String),
      reason: map['reason'] as String?,
      status: map['status'] as String? ?? 'confirmed',
      mode: map['mode'] as String? ?? 'IN_PERSON',
      tokenNumber: (map['token_number'] as num?)?.toInt(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? profileId,
    String? doctorProfileId,
    String? doctorName,
    String? doctorSpeciality,
    String? clinicName,
    DateTime? appointmentAt,
    String? reason,
    String? status,
    String? mode,
    int? tokenNumber,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      profileId: profileId ?? this.profileId,
      doctorProfileId: doctorProfileId ?? this.doctorProfileId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpeciality: doctorSpeciality ?? this.doctorSpeciality,
      clinicName: clinicName ?? this.clinicName,
      appointmentAt: appointmentAt ?? this.appointmentAt,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
