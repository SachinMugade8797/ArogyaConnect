class PatientConditionModel {
  final String id;
  final String patientId;
  final String name;
  final String status; // 'ACTIVE' | 'RESOLVED'
  final String? since;
  final String? notes;
  final String syncStatus;

  PatientConditionModel({
    required this.id,
    required this.patientId,
    required this.name,
    this.status = 'ACTIVE',
    this.since,
    this.notes,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'status': status,
      'since': since,
      'notes': notes,
      'sync_status': syncStatus,
    };
  }

  factory PatientConditionModel.fromMap(Map<String, dynamic> map) {
    return PatientConditionModel(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      name: map['name'] as String,
      status: map['status'] as String? ?? 'ACTIVE',
      since: map['since'] as String?,
      notes: map['notes'] as String?,
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }
}
