class SyncItemModel {
  final String id;
  final String entityType; // 'appointment', 'vital', 'profile', 'health_record'
  final String entityId;
  final String action;     // 'CREATE', 'UPDATE', 'DELETE'
  final String payload;    // JSON string
  final String status;    // 'PENDING', 'SYNCING', 'FAILED'
  final int attempts;
  final String? lastError;
  final DateTime createdAt;

  SyncItemModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payload,
    this.status = 'PENDING',
    this.attempts = 0,
    this.lastError,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'payload': payload,
      'status': status,
      'attempts': attempts,
      'last_error': lastError,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SyncItemModel.fromMap(Map<String, dynamic> map) {
    return SyncItemModel(
      id: map['id'] as String,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String,
      action: map['action'] as String,
      payload: map['payload'] as String,
      status: map['status'] as String? ?? 'PENDING',
      attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      lastError: map['last_error'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
