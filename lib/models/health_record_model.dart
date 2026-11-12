class HealthRecordModel {
  final String id;
  final String patientId;
  final String category; // 'PRESCRIPTION', 'LAB_REPORT', 'DISCHARGE_SUMMARY', 'IMAGING', 'DOCUMENT'
  final String title;
  final String? description;
  final String issuer;
  final DateTime recordDate;
  final String? fileName;
  final String verificationStatus; // 'Verified', 'Not Verified', 'AI_VERIFIED', 'DOCTOR_VERIFIED', etc.

  HealthRecordModel({
    required this.id,
    required this.patientId,
    required this.category,
    required this.title,
    this.description,
    required this.issuer,
    required this.recordDate,
    this.fileName,
    this.verificationStatus = 'Verified',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'category': category,
      'title': title,
      'description': description,
      'issuer': issuer,
      'record_date': recordDate.toIso8601String(),
      'file_name': fileName,
      'verification_status': verificationStatus,
    };
  }

  factory HealthRecordModel.fromMap(Map<String, dynamic> map) {
    return HealthRecordModel(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      category: map['category'] as String? ?? 'DOCUMENT',
      title: map['title'] as String,
      description: map['description'] as String?,
      issuer: map['issuer'] as String? ?? 'Self Uploaded',
      recordDate: DateTime.parse(map['record_date'] as String),
      fileName: map['file_name'] as String?,
      verificationStatus: map['verification_status'] as String? ?? 'Not Verified',
    );
  }
}
