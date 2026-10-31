import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/appointment_model.dart';
import '../models/sync_item_model.dart';
import '../core/sync/sync_engine.dart';

class AppointmentRepository {
  final AppDatabase _db = AppDatabase.instance;
  final SyncEngine _syncEngine;
  final _uuid = const Uuid();

  AppointmentRepository(this._syncEngine);

  Future<List<AppointmentModel>> getAppointments({String? profileId}) async {
    final db = await _db.database;
    final rows = await db.query(
      'appointments',
      where: profileId != null ? 'profile_id = ?' : null,
      whereArgs: profileId != null ? [profileId] : null,
      orderBy: 'appointment_at ASC',
    );
    return rows.map((r) => AppointmentModel.fromMap(r)).toList();
  }

  /// Book an appointment offline first!
  Future<AppointmentModel> bookAppointment({
    required String patientId,
    required String profileId,
    required String doctorProfileId,
    required String doctorName,
    required String doctorSpeciality,
    required String clinicName,
    required DateTime appointmentAt,
    String? reason,
    String mode = 'IN_PERSON',
  }) async {
    final db = await _db.database;
    final appointmentId = _uuid.v4();
    final tokenNumber = (DateTime.now().millisecond % 20) + 1;

    final newAppointment = AppointmentModel(
      id: appointmentId,
      patientId: patientId,
      profileId: profileId,
      doctorProfileId: doctorProfileId,
      doctorName: doctorName,
      doctorSpeciality: doctorSpeciality,
      clinicName: clinicName,
      appointmentAt: appointmentAt,
      reason: reason,
      status: 'confirmed',
      mode: mode,
      tokenNumber: tokenNumber,
      syncStatus: 'pending_create',
      updatedAt: DateTime.now(),
    );

    // 1. Save directly into local SQLite database
    await db.insert('appointments', newAppointment.toMap());

    // 2. Queue mutation into offline sync outbox
    final syncItem = SyncItemModel(
      id: _uuid.v4(),
      entityType: 'appointment',
      entityId: appointmentId,
      action: 'CREATE',
      payload: jsonEncode({
        'id': appointmentId,
        'doctorProfileId': doctorProfileId,
        'profileId': profileId,
        'appointmentAt': appointmentAt.toIso8601String(),
        'reason': reason,
        'mode': mode,
      }),
      status: 'PENDING',
    );
    await db.insert('sync_queue', syncItem.toMap());

    // 3. Trigger opportunistic sync if online
    _syncEngine.syncAll();

    return newAppointment;
  }

  Future<void> cancelAppointment(String id) async {
    final db = await _db.database;
    await db.update(
      'appointments',
      {'status': 'cancelled', 'sync_status': 'pending_update'},
      where: 'id = ?',
      whereArgs: [id],
    );

    final syncItem = SyncItemModel(
      id: _uuid.v4(),
      entityType: 'appointment',
      entityId: id,
      action: 'UPDATE',
      payload: jsonEncode({'status': 'cancelled'}),
      status: 'PENDING',
    );
    await db.insert('sync_queue', syncItem.toMap());
    _syncEngine.syncAll();
  }
}
