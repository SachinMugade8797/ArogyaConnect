import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/appointment_model.dart';
import '../models/profile_model.dart';
import '../models/vital_model.dart';
import '../models/condition_model.dart';
import '../models/health_record_model.dart';
import '../models/visit_record_model.dart';

class PatientClinicalDossier {
  final ProfileModel patient;
  final List<PatientConditionModel> conditions;
  final List<VitalReadingModel> vitals;
  final List<HealthRecordModel> records;
  final List<VisitRecordModel> pastVisits;

  PatientClinicalDossier({
    required this.patient,
    required this.conditions,
    required this.vitals,
    required this.records,
    required this.pastVisits,
  });
}

class DoctorQueueItem {
  final AppointmentModel appointment;
  final ProfileModel? patientProfile;

  DoctorQueueItem({
    required this.appointment,
    this.patientProfile,
  });
}

class DoctorConsultationRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  /// Fetch today's patient queue for the doctor
  Future<List<DoctorQueueItem>> getDoctorAppointments(String doctorProfileId) async {
    final db = await _db.database;

    final apptRows = await db.query(
      'appointments',
      where: 'doctor_profile_id = ?',
      whereArgs: [doctorProfileId],
      orderBy: 'appointment_at ASC',
    );

    final List<DoctorQueueItem> items = [];
    for (final row in apptRows) {
      final appt = AppointmentModel.fromMap(row);
      ProfileModel? profile;

      if (appt.profileId != null) {
        final profRows = await db.query(
          'profiles',
          where: 'id = ?',
          whereArgs: [appt.profileId],
          limit: 1,
        );
        if (profRows.isNotEmpty) {
          profile = ProfileModel.fromMap(profRows.first);
        }
      }

      items.add(DoctorQueueItem(appointment: appt, patientProfile: profile));
    }

    return items;
  }

  /// Get comprehensive clinical dossier for a patient
  Future<PatientClinicalDossier> getPatientDossier(String patientProfileId) async {
    final db = await _db.database;

    // 1. Profile
    final profRows = await db.query('profiles', where: 'id = ?', whereArgs: [patientProfileId], limit: 1);
    final patient = profRows.isNotEmpty
        ? ProfileModel.fromMap(profRows.first)
        : ProfileModel(id: patientProfileId, userId: 'unknown', name: 'Patient');

    // 2. Conditions
    final condRows = await db.query('patient_conditions', where: 'patient_id = ?', whereArgs: [patientProfileId]);
    final conditions = condRows.map((r) => PatientConditionModel.fromMap(r)).toList();

    // 3. Vitals
    final vitalRows = await db.query(
      'vital_readings',
      where: 'patient_id = ?',
      whereArgs: [patientProfileId],
      orderBy: 'measured_at DESC',
    );
    final vitals = vitalRows.map((r) => VitalReadingModel.fromMap(r)).toList();

    // 4. Health Records
    final recRows = await db.query(
      'health_records',
      where: 'patient_id = ?',
      whereArgs: [patientProfileId],
      orderBy: 'record_date DESC',
    );
    final records = recRows.map((r) => HealthRecordModel.fromMap(r)).toList();

    // 5. Past Visits
    final visitRows = await db.query(
      'visit_records',
      where: 'profile_id = ?',
      whereArgs: [patientProfileId],
      orderBy: 'created_at DESC',
    );
    final visits = visitRows.map((r) => VisitRecordModel.fromMap(r)).toList();

    return PatientClinicalDossier(
      patient: patient,
      conditions: conditions,
      vitals: vitals,
      records: records,
      pastVisits: visits,
    );
  }

  /// Change appointment status (e.g. WAITING -> IN_CONSULTATION -> COMPLETED)
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    final db = await _db.database;
    await db.update(
      'appointments',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  /// Record doctor consultation diagnosis, notes and advise tests
  Future<VisitRecordModel> recordConsultation({
    required String appointmentId,
    required String profileId,
    required String doctorProfileId,
    required String diagnosis,
    required String notes,
    required String testsAdvised,
    String? followUpDate,
  }) async {
    final db = await _db.database;
    final visitId = _uuid.v4();
    final now = DateTime.now();

    final visit = VisitRecordModel(
      id: visitId,
      appointmentId: appointmentId,
      profileId: profileId,
      doctorProfileId: doctorProfileId,
      diagnosis: diagnosis,
      notes: notes,
      testsAdvised: testsAdvised,
      followUpDate: followUpDate,
      createdAt: now,
    );

    // 1. Insert Visit Record
    await db.insert('visit_records', visit.toMap());

    // 2. Mark Appointment as COMPLETED
    await updateAppointmentStatus(appointmentId, 'COMPLETED');

    return visit;
  }

  /// Verify a clinical record by doctor
  Future<void> verifyHealthRecord(String recordId) async {
    final db = await _db.database;
    await db.update(
      'health_records',
      {
        'verification_status': 'DOCTOR_VERIFIED',
      },
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }
}
