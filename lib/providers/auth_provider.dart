import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../models/doctor_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool hasCompletedOnboarding;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.hasCompletedOnboarding = true,
  });

  bool get isAuthenticated => user != null;
  bool get isDoctor => user?.role == 'doctor';
  bool get isPatient => user?.role == 'patient';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? hasCompletedOnboarding,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('auth_user_id');

    if (userId != null) {
      try {
        final db = await _db.database;
        final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
        if (rows.isNotEmpty) {
          state = state.copyWith(
            user: UserModel.fromMap(rows.first),
            isLoading: false,
          );
          return;
        }
      } catch (_) {}
    }

    // Unauthenticated on start so user sees Role-Based Login Screen directly
    state = state.copyWith(isLoading: false, clearUser: true);
  }

  /// Direct 1-tap role-based login (Doctor or Patient/User) - Fast UI Login
  Future<bool> loginDirectlyWithRole(String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final db = await _db.database;
      final rows = await db.query('users', where: 'role = ?', whereArgs: [role], limit: 1);
      if (rows.isNotEmpty) {
        final u = UserModel.fromMap(rows.first);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_id', u.id);
        state = state.copyWith(user: u, isLoading: false, error: null);
        return true;
      }
    } catch (_) {}

    // Fallback fast UI user model
    final fallbackUser = UserModel(
      id: role == 'doctor' ? 'user-doctor-1' : 'user-patient-1',
      fullName: role == 'doctor' ? 'Dr. Aditi Deshmukh' : 'Sachin Shinde',
      email: role == 'doctor' ? 'doctor@arogyanexus.com' : 'patient@arogyanexus.com',
      phone: role == 'doctor' ? '+91 98222 00202' : '+91 98221 00101',
      role: role,
      createdAt: DateTime.now(),
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', fallbackUser.id);
    } catch (_) {}

    state = state.copyWith(user: fallbackUser, isLoading: false, error: null);
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final cleanEmail = email.trim().toLowerCase();

    try {
      final db = await _db.database;
      final rows = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [cleanEmail],
      );

      if (rows.isNotEmpty) {
        final user = UserModel.fromMap(rows.first);
        if (user.role != role) {
          state = state.copyWith(
            isLoading: false,
            error: 'This account is registered as ${user.role == "doctor" ? "Doctor" : "Patient/User"}, not as $role.',
          );
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_id', user.id);

        state = state.copyWith(user: user, isLoading: false, error: null);
        return true;
      }
    } catch (_) {}

    // Fast UI fallback: direct login with role
    return await loginDirectlyWithRole(role);
  }

  Future<bool> registerPatient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final db = await _db.database;
    final userId = _uuid.v4();
    final profileId = _uuid.v4();

    // Check email uniqueness
    final existing = await db.query('users', where: 'email = ?', whereArgs: [email.trim().toLowerCase()]);
    if (existing.isNotEmpty) {
      state = state.copyWith(isLoading: false, error: 'Email already registered.');
      return false;
    }

    final newUser = UserModel(
      id: userId,
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      role: 'patient',
    );

    await db.insert('users', {
      ...newUser.toMap(),
      'password_hash': password,
    });

    // Create self patient profile
    await db.insert('profiles', ProfileModel(
      id: profileId,
      userId: userId,
      name: fullName.trim(),
      relation: 'SELF',
      phone: phone.trim(),
    ).toMap());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_id', userId);

    state = state.copyWith(user: newUser, isLoading: false, error: null);
    return true;
  }

  Future<bool> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String speciality,
    required String registrationNumber,
    required String clinicName,
    required String clinicAddress,
    required double consultationFee,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final db = await _db.database;
    final userId = _uuid.v4();
    final doctorProfileId = _uuid.v4();

    final existing = await db.query('users', where: 'email = ?', whereArgs: [email.trim().toLowerCase()]);
    if (existing.isNotEmpty) {
      state = state.copyWith(isLoading: false, error: 'Email already registered.');
      return false;
    }

    final newUser = UserModel(
      id: userId,
      fullName: fullName.startsWith('Dr.') ? fullName.trim() : 'Dr. ${fullName.trim()}',
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      role: 'doctor',
    );

    await db.insert('users', {
      ...newUser.toMap(),
      'password_hash': password,
    });

    await db.insert('doctor_profiles', {
      'id': doctorProfileId,
      'user_id': userId,
      'speciality': speciality,
      'registration_number': registrationNumber,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'consultation_fee': consultationFee,
      'status': 'approved',
      'experience_years': 8,
      'languages': 'English,Hindi',
      'bio': 'Specialist at $clinicName',
      'offers_video': 1,
      'rating_avg': 5.0,
      'rating_count': 1,
    });

    // Also add to doctors directory cache
    await db.insert('doctors', DoctorModel(
      id: doctorProfileId,
      name: newUser.fullName,
      speciality: speciality,
      clinic: clinicName,
      clinicAddress: clinicAddress,
      city: 'Pune',
      consultationFee: consultationFee,
    ).toMap());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_id', userId);

    state = state.copyWith(user: newUser, isLoading: false, error: null);
    return true;
  }

  /// Switch between demo accounts instantly
  Future<void> switchDemoRole(String role) async {
    final db = await _db.database;
    final rows = await db.query('users', where: 'role = ?', whereArgs: [role], limit: 1);
    if (rows.isNotEmpty) {
      final u = UserModel.fromMap(rows.first);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', u.id);
      state = state.copyWith(user: u, error: null);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user_id');
    state = state.copyWith(clearUser: true, error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
