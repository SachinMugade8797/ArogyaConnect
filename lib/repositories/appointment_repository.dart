import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

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

  /// Book an appointment
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
      updatedAt: DateTime.now(),
    );

    // Save directly into local database
    await db.insert('appointments', newAppointment.toMap());

    return newAppointment;
  }

  Future<void> cancelAppointment(String id) async {
    final db = await _db.database;
    await db.update(
      'appointments',
      {
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
