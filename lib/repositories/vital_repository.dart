import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/vital_model.dart';

class VitalRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

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
    );

    // Save directly into local database
    await db.insert('vital_readings', vital.toMap());

    return vital;
  }
}
