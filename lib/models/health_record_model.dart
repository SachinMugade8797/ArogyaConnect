class HealthRecordModel {
  final String id;
  final String patientId;
  final String category; // 'PRESCRIPTION', 'LAB_REPORT', 'DISCHARGE_SUMMARY', 'VACCINE'
  final String title;
  final String issuer;
  final DateTime recordDate;
  final String? fileName;
  final String verificationStatus; // 'PENDING', 'AI_VERIFIED', 'DOCTOR_VERIFIED', 'REJECTED'
  final String syncStatus;

  HealthRecordModel({
    required this.id,
    required this.patientId,
    required this.category,
    required this.title,
    required this.issuer,
    required this.recordDate,
    this.fileName,
    this.verificationStatus = 'AI_VERIFIED',
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'category': category,
      'title': title,
      'issuer': issuer,
      'record_date': recordDate.toIso8601String(),
      'file_name': fileName,
      'verification_status': verificationStatus,
      'sync_status': syncStatus,
    };
  }

  factory HealthRecordModel.fromMap(Map<String, dynamic> map) {
    return HealthRecordModel(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      issuer: map['issuer'] as String,
      recordDate: DateTime.parse(map['record_date'] as String),
      fileName: map['file_name'] as String?,
      verificationStatus: map['verification_status'] as String? ?? 'AI_VERIFIED',
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }
}
