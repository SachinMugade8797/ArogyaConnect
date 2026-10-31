class VitalReadingModel {
  final String id;
  final String patientId;
  final String type; // 'BP', 'BLOOD_GLUCOSE', 'HEART_RATE', 'SPO2', 'TEMPERATURE', 'WEIGHT'
  final double value;
  final String unit;
  final DateTime measuredAt;
  final String syncStatus;

  VitalReadingModel({
    required this.id,
    required this.patientId,
    required this.type,
    required this.value,
    required this.unit,
    required this.measuredAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'type': type,
      'value': value,
      'unit': unit,
      'measured_at': measuredAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory VitalReadingModel.fromMap(Map<String, dynamic> map) {
    return VitalReadingModel(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      type: map['type'] as String,
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String,
      measuredAt: DateTime.parse(map['measured_at'] as String),
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }
}
