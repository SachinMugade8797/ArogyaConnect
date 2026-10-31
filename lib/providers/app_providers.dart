import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../repositories/doctor_repository.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/vital_repository.dart';
import '../repositories/health_record_repository.dart';
import '../repositories/doctor_consultation_repository.dart';
import '../models/profile_model.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/vital_model.dart';
import '../models/health_record_model.dart';
import 'auth_provider.dart';

// Repositories
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository();
});

final vitalRepositoryProvider = Provider<VitalRepository>((ref) {
  return VitalRepository();
});

final healthRecordRepositoryProvider = Provider<HealthRecordRepository>((ref) {
  return HealthRecordRepository();
});

final doctorConsultationRepositoryProvider = Provider<DoctorConsultationRepository>((ref) {
  return DoctorConsultationRepository();
});

// Patient State Providers
final activeProfileIdProvider = StateProvider<String>((ref) => 'profile-self');

final profilesProvider = FutureProvider<List<ProfileModel>>((ref) async {
  return ref.watch(profileRepositoryProvider).getAllProfiles();
});

final activeProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final activeId = ref.watch(activeProfileIdProvider);
  return ref.watch(profileRepositoryProvider).getProfileById(activeId);
});

final appointmentsListProvider = FutureProvider<List<AppointmentModel>>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  return ref.watch(appointmentRepositoryProvider).getAppointments(profileId: profileId);
});

final vitalsListProvider = FutureProvider<List<VitalReadingModel>>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  return ref.watch(vitalRepositoryProvider).getVitals(profileId);
});

final healthRecordsListProvider = FutureProvider<List<HealthRecordModel>>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  return ref.watch(healthRecordRepositoryProvider).getRecords(profileId);
});

final doctorSearchQueryProvider = StateProvider<String>((ref) => '');
final doctorSpecialityFilterProvider = StateProvider<String>((ref) => 'All');

final filteredDoctorsProvider = FutureProvider<List<DoctorModel>>((ref) async {
  final search = ref.watch(doctorSearchQueryProvider);
  final speciality = ref.watch(doctorSpecialityFilterProvider);
  return ref.watch(doctorRepositoryProvider).getDoctors(
        search: search,
        speciality: speciality,
      );
});

// Doctor Dashboard State Providers
final doctorAppointmentsProvider = FutureProvider<List<DoctorQueueItem>>((ref) async {
  final authState = ref.watch(authProvider);
  final doctorId = (authState.isDoctor) ? 'doc-1' : 'doc-1';
  return ref.watch(doctorConsultationRepositoryProvider).getDoctorAppointments(doctorId);
});

final patientDossierProvider = FutureProvider.family<PatientClinicalDossier, String>((ref, profileId) async {
  return ref.watch(doctorConsultationRepositoryProvider).getPatientDossier(profileId);
});
