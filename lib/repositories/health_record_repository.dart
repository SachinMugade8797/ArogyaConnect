import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/health_record_model.dart';

class HealthRecordRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

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

  Future<HealthRecordModel> addRecord({
    required String patientId,
    required String title,
    String? description,
    required String fileName,
    required String verificationStatus,
    String category = 'DOCUMENT',
    String issuer = 'Self Uploaded',
  }) async {
    final db = await _db.database;
    final recordId = _uuid.v4();
    final now = DateTime.now();

    final record = HealthRecordModel(
      id: recordId,
      patientId: patientId,
      category: category,
      title: title,
      description: description,
      issuer: issuer,
      recordDate: now,
      fileName: fileName,
      verificationStatus: verificationStatus,
    );

    await db.insert('health_records', record.toMap());
    return record;
  }
}
