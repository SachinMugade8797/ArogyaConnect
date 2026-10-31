import '../core/database/app_database.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<ProfileModel>> getAllProfiles() async {
    final db = await _db.database;
    final rows = await db.query('profiles');
    return rows.map((r) => ProfileModel.fromMap(r)).toList();
  }

  Future<ProfileModel?> getProfileById(String id) async {
    final db = await _db.database;
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ProfileModel.fromMap(rows.first);
  }
}
