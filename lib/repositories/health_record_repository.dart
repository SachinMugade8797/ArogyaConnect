import '../core/database/app_database.dart';
import '../models/health_record_model.dart';

class HealthRecordRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<HealthRecordModel>> getRecords(String patientId) async {
    final db = await _db.database;
    final rows = await db.query(
      'health_records',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'record_date DESC',
    );
    return rows.map((r) => HealthRecordModel.fromMap(r)).toList();
  }
}
