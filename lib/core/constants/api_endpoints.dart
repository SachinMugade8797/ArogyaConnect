class ApiEndpoints {
  // In development, on Android Emulator localhost is 10.0.2.2
  // On real mobile device connected to local WiFi, use your machine IP: e.g. http://192.168.1.X:3001/api
  static const String defaultBaseUrl = 'http://10.0.2.2:3001/api';

  static const String health = '/health';
  static const String login = '/auth/login';
  static const String registerPatient = '/auth/register/patient';
  static const String me = '/auth/me';

  static const String publicDoctors = '/public/doctors';
  static const String patientAppointments = '/patient/appointments';
  static const String patientVitals = '/patient/records/vitals';
  static const String patientConditions = '/patient/records/conditions';
  static const String patientRecords = '/patient/records';
  static const String syncPull = '/sync/pull';
  static const String syncPush = '/sync/push';
}
