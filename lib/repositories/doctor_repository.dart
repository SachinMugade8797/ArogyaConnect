import '../core/database/app_database.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<DoctorModel>> getDoctors({String? search, String? speciality}) async {
    final db = await _db.database;
    String? whereClause;
    List<dynamic> whereArgs = [];

    if (search != null && search.trim().isNotEmpty) {
      whereClause = '(name LIKE ? OR clinic LIKE ? OR city LIKE ?)';
      final q = '%${search.trim()}%';
      whereArgs = [q, q, q];
    }

    if (speciality != null && speciality != 'All') {
      if (whereClause != null) {
        whereClause += ' AND speciality = ?';
      } else {
        whereClause = 'speciality = ?';
      }
      whereArgs.add(speciality);
    }

    final rows = await db.query(
      'doctors',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'rating DESC',
    );

    return rows.map((r) => DoctorModel.fromMap(r)).toList();
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    final db = await _db.database;
    final rows = await db.query('doctors', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return DoctorModel.fromMap(rows.first);
  }
}
