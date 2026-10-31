import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/vital_model.dart';
import '../models/sync_item_model.dart';
import '../core/sync/sync_engine.dart';

class VitalRepository {
  final AppDatabase _db = AppDatabase.instance;
  final SyncEngine _syncEngine;
  final _uuid = const Uuid();

  VitalRepository(this._syncEngine);

  Future<List<VitalReadingModel>> getVitals(String patientId) async {
    final db = await _db.database;
    final rows = await db.query(
      'vital_readings',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'measured_at DESC',
    );
    return rows.map((r) => VitalReadingModel.fromMap(r)).toList();
  }

  Future<VitalReadingModel> addVital({
    required String patientId,
    required String type,
    required double value,
    required String unit,
  }) async {
    final db = await _db.database;
    final vitalId = _uuid.v4();
    final now = DateTime.now();

    final vital = VitalReadingModel(
      id: vitalId,
      patientId: patientId,
      type: type,
      value: value,
      unit: unit,
      measuredAt: now,
      syncStatus: 'pending_create',
    );

    // 1. Local SQLite storage
    await db.insert('vital_readings', vital.toMap());

    // 2. Offline Sync Queue
    final syncItem = SyncItemModel(
      id: _uuid.v4(),
      entityType: 'vital',
      entityId: vitalId,
      action: 'CREATE',
      payload: jsonEncode({
        'id': vitalId,
        'patient_id': patientId,
        'type': type,
        'value': value,
        'unit': unit,
        'measured_at': now.toIso8601String(),
      }),
      status: 'PENDING',
    );
    await db.insert('sync_queue', syncItem.toMap());

    _syncEngine.syncAll();
    return vital;
  }
}
