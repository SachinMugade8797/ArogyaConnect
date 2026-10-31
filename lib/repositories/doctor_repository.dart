import '../core/database/app_database.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<DoctorModel>> getDoctors({
    String? search,
    String? city,
    String? speciality,
    bool? videoOnly,
    String? sortBy,
  }) async {
    final db = await _db.database;
    String? whereClause;
    final List<dynamic> whereArgs = [];

    // 1. City Filter (Matches Web CITIES: Kolhapur, Sangli, Satara, Pune, Mumbai, Nashik, Solapur, Bengaluru)
    if (city != null && city != 'All' && city.isNotEmpty) {
      whereClause = 'city = ?';
      whereArgs.add(city);
    }

    // 2. Keyword Search (Doctor name, clinic name, address, or city)
    if (search != null && search.trim().isNotEmpty) {
      final searchCondition = '(name LIKE ? OR clinic LIKE ? OR clinic_address LIKE ? OR city LIKE ?)';
      final q = '%${search.trim()}%';
      if (whereClause != null) {
        whereClause += ' AND $searchCondition';
      } else {
        whereClause = searchCondition;
      }
      whereArgs.addAll([q, q, q, q]);
    }

    // 3. Speciality Filter
    if (speciality != null && speciality != 'All' && speciality.isNotEmpty) {
      if (whereClause != null) {
        whereClause += ' AND speciality = ?';
      } else {
        whereClause = 'speciality = ?';
      }
      whereArgs.add(speciality);
    }

    // 4. Video consultation filter
    if (videoOnly == true) {
      if (whereClause != null) {
        whereClause += ' AND offers_video = 1';
      } else {
        whereClause = 'offers_video = 1';
      }
    }

    // 5. Sorting
    String orderBy = 'rating DESC';
    if (sortBy == 'fee_low') {
      orderBy = 'consultation_fee ASC';
    } else if (sortBy == 'fee_high') {
      orderBy = 'consultation_fee DESC';
    } else if (sortBy == 'experience') {
      orderBy = 'experience_years DESC';
    }

    final rows = await db.query(
      'doctors',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
    );

    return rows.map((r) => DoctorModel.fromMap(r)).toList();
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    final db = await _db.database;
    final rows = await db.query('doctors', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return DoctorModel.fromMap(rows.first);
  }

  /// Get distinct cities with doctors count for city tabs/chips
  Future<Map<String, int>> getDoctorCountsByCity() async {
    final db = await _db.database;
    final rows = await db.rawQuery('SELECT city, COUNT(*) as count FROM doctors GROUP BY city ORDER BY count DESC');
    final Map<String, int> counts = {};
    for (final r in rows) {
      counts[r['city'] as String] = (r['count'] as num).toInt();
    }
    return counts;
  }
}
