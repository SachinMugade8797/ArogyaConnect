import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/profile_model.dart';
import '../../models/doctor_model.dart';
import '../../models/appointment_model.dart';
import '../../models/vital_model.dart';
import '../../models/health_record_model.dart';
import '../../models/condition_model.dart';
import 'seed_doctors.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('arogyanexus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    // Verify all 201 doctors migrated from ArogyaNexus web project are populated
    final countRes = await db.rawQuery('SELECT COUNT(*) as count FROM doctors');
    final count = Sqflite.firstIntValue(countRes) ?? 0;
    if (count < 200) {
      await seedWebDoctors(db);
    }

    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Users table (Patient & Doctor authentication)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL DEFAULT 'patient',
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Doctor Profiles
    await db.execute('''
      CREATE TABLE doctor_profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT UNIQUE NOT NULL,
        speciality TEXT NOT NULL,
        registration_number TEXT UNIQUE NOT NULL,
        clinic_name TEXT NOT NULL,
        clinic_address TEXT NOT NULL,
        consultation_fee REAL NOT NULL,
        status TEXT DEFAULT 'approved',
        experience_years INTEGER DEFAULT 10,
        languages TEXT DEFAULT 'English,Hindi',
        bio TEXT,
        offers_video INTEGER DEFAULT 1,
        rating_avg REAL DEFAULT 4.8,
        rating_count INTEGER DEFAULT 0
      )
    ''');

    // 3. Profiles (Patient profiles & family members)
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        relation TEXT NOT NULL DEFAULT 'SELF',
        blood_group TEXT,
        dob TEXT,
        gender TEXT,
        phone TEXT,
        height_cm REAL,
        weight_kg REAL,
        emergency_name TEXT,
        emergency_phone TEXT,
        emergency_relation TEXT,
        allergies TEXT,
        onboarding_step INTEGER DEFAULT 3
      )
    ''');

    // 4. Doctor Directory Cache
    await db.execute('''
      CREATE TABLE doctors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        speciality TEXT NOT NULL,
        clinic TEXT NOT NULL,
        clinic_address TEXT,
        city TEXT NOT NULL,
        consultation_fee REAL NOT NULL,
        rating REAL DEFAULT 4.8,
        review_count INTEGER DEFAULT 0,
        experience_years INTEGER,
        languages TEXT,
        bio TEXT,
        offers_video INTEGER DEFAULT 1
      )
    ''');

    // 5. Appointments
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        profile_id TEXT,
        doctor_profile_id TEXT NOT NULL,
        doctor_name TEXT NOT NULL,
        doctor_speciality TEXT NOT NULL,
        clinic_name TEXT NOT NULL,
        appointment_at TEXT NOT NULL,
        reason TEXT,
        status TEXT NOT NULL,
        mode TEXT DEFAULT 'IN_PERSON',
        token_number INTEGER,
        updated_at TEXT NOT NULL
      )
    ''');

    // 6. Vital Readings
    await db.execute('''
      CREATE TABLE vital_readings (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        measured_at TEXT NOT NULL
      )
    ''');

    // 7. Patient Conditions
    await db.execute('''
      CREATE TABLE patient_conditions (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        name TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ACTIVE',
        since TEXT,
        notes TEXT
      )
    ''');

    // 8. Health Records & Documents
    await db.execute('''
      CREATE TABLE health_records (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        issuer TEXT NOT NULL,
        record_date TEXT NOT NULL,
        file_name TEXT,
        verification_status TEXT DEFAULT 'AI_VERIFIED'
      )
    ''');

    // 9. Visit Records (Consultation notes entered by doctor)
    await db.execute('''
      CREATE TABLE visit_records (
        id TEXT PRIMARY KEY,
        appointment_id TEXT UNIQUE NOT NULL,
        profile_id TEXT NOT NULL,
        doctor_profile_id TEXT NOT NULL,
        diagnosis TEXT,
        notes TEXT,
        tests_advised TEXT,
        follow_up_date TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed initial application data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();

    // 1. Seed Users (1 Patient, 1 Doctor)
    await db.insert('users', {
      'id': 'user-patient-1',
      'full_name': 'Sachin Shinde',
      'email': 'patient@arogyanexus.com',
      'password_hash': 'patient123',
      'phone': '+91 98221 00101',
      'role': 'patient',
      'created_at': now.toIso8601String(),
    });

    await db.insert('users', {
      'id': 'user-doctor-1',
      'full_name': 'Dr. Aditi Deshmukh',
      'email': 'doctor@arogyanexus.com',
      'password_hash': 'doctor123',
      'phone': '+91 98222 00202',
      'role': 'doctor',
      'created_at': now.toIso8601String(),
    });

    // 2. Seed Doctor Profile
    await db.insert('doctor_profiles', {
      'id': 'doc-1',
      'user_id': 'user-doctor-1',
      'speciality': 'Cardiologist',
      'registration_number': 'MCI-2015-84920',
      'clinic_name': 'HeartCare Clinic & Diagnostics',
      'clinic_address': 'Station Road, Shahupuri, Kolhapur',
      'consultation_fee': 700.0,
      'status': 'approved',
      'experience_years': 14,
      'languages': 'English,Marathi,Hindi',
      'bio': 'Senior Consultant Cardiologist specializing in preventive cardiology and hypertension.',
      'offers_video': 1,
      'rating_avg': 4.9,
      'rating_count': 38,
    });

    // 3. Seed Patient Profiles
    await db.insert('profiles', ProfileModel(
      id: 'profile-self',
      userId: 'user-patient-1',
      name: 'Sachin Shinde',
      relation: 'SELF',
      bloodGroup: 'B+',
      dob: '1992-04-12',
      gender: 'Male',
      phone: '+91 98221 00101',
      heightCm: 176,
      weightKg: 74,
      allergies: ['Penicillin'],
      emergencyName: 'Sunita Shinde',
      emergencyPhone: '+91 98221 00102',
      emergencyRelation: 'SPOUSE',
      onboardingStep: 3,
    ).toMap());

    await db.insert('profiles', ProfileModel(
      id: 'profile-spouse',
      userId: 'user-patient-1',
      name: 'Sunita Shinde',
      relation: 'SPOUSE',
      bloodGroup: 'O+',
      dob: '1994-08-25',
      gender: 'Female',
      phone: '+91 98221 00102',
      heightCm: 162,
      weightKg: 58,
      allergies: ['Dust'],
      emergencyName: 'Sachin Shinde',
      emergencyPhone: '+91 98221 00101',
      emergencyRelation: 'SPOUSE',
      onboardingStep: 3,
    ).toMap());

    // 4. Seed Doctors Directory
    final initialDoctors = [
      DoctorModel(
        id: 'doc-1',
        name: 'Dr. Aditi Deshmukh',
        speciality: 'Cardiologist',
        clinic: 'HeartCare Clinic & Diagnostics',
        clinicAddress: 'Station Road, Shahupuri',
        city: 'Kolhapur',
        consultationFee: 700.0,
        rating: 4.9,
        reviewCount: 38,
        experienceYears: 14,
        languages: ['English', 'Marathi', 'Hindi'],
        bio: 'Senior Consultant Cardiologist specializing in preventive cardiology and hypertension.',
        offersVideo: true,
      ),
      DoctorModel(
        id: 'doc-2',
        name: 'Dr. Rajesh Patil',
        speciality: 'General Physician',
        clinic: 'Patil Arogya Kendra',
        clinicAddress: 'Deccan Gymkhana, FC Road',
        city: 'Pune',
        consultationFee: 500.0,
        rating: 4.7,
        reviewCount: 52,
        experienceYears: 18,
        languages: ['English', 'Marathi'],
        bio: 'Family doctor experienced in diabetes management and adult lifestyle diseases.',
        offersVideo: true,
      ),
      DoctorModel(
        id: 'doc-3',
        name: 'Dr. Sunita Kulkarni',
        speciality: 'Pediatrician',
        clinic: 'Little Smiles Clinic',
        clinicAddress: 'Indiranagar 100ft Road',
        city: 'Bengaluru',
        consultationFee: 650.0,
        rating: 4.8,
        reviewCount: 29,
        experienceYears: 11,
        languages: ['English', 'Kannada', 'Hindi'],
        bio: 'Dedicated child healthcare specialist with focus on vaccinations and pediatric nutrition.',
        offersVideo: false,
      ),
    ];

    for (final doc in initialDoctors) {
      await db.insert('doctors', doc.toMap());
    }

    // 5. Seed Patient Conditions
    await db.insert('patient_conditions', PatientConditionModel(
      id: 'cond-1',
      patientId: 'profile-self',
      name: 'Essential Hypertension (Stage 1)',
      status: 'ACTIVE',
      since: '2024-02-10',
      notes: 'Controlled with daily lifestyle balance and monitoring.',
    ).toMap());

    await db.insert('patient_conditions', PatientConditionModel(
      id: 'cond-2',
      patientId: 'profile-self',
      name: 'Mild Hyperlipidemia',
      status: 'ACTIVE',
      since: '2024-06-15',
      notes: 'Advised dietary fat reduction and low cholesterol intake.',
    ).toMap());

    // 6. Seed Appointments
    final initialAppointments = [
      AppointmentModel(
        id: 'app-seed-1',
        patientId: 'user-patient-1',
        profileId: 'profile-self',
        doctorProfileId: 'doc-1',
        doctorName: 'Dr. Aditi Deshmukh',
        doctorSpeciality: 'Cardiologist',
        clinicName: 'HeartCare Clinic & Diagnostics',
        appointmentAt: now.add(const Duration(hours: 2)),
        reason: 'Routine ECG & Hypertension Checkup',
        status: 'confirmed',
        mode: 'IN_PERSON',
        tokenNumber: 3,
      ),
      AppointmentModel(
        id: 'app-seed-2',
        patientId: 'user-patient-1',
        profileId: 'profile-spouse',
        doctorProfileId: 'doc-1',
        doctorName: 'Dr. Aditi Deshmukh',
        doctorSpeciality: 'Cardiologist',
        clinicName: 'HeartCare Clinic & Diagnostics',
        appointmentAt: now.add(const Duration(days: 1, hours: 3)),
        reason: 'Cardiac Health Assessment',
        status: 'confirmed',
        mode: 'VIDEO',
        tokenNumber: 7,
      ),
    ];

    for (final appt in initialAppointments) {
      await db.insert('appointments', appt.toMap());
    }

    // 7. Seed Vitals
    final initialVitals = [
      VitalReadingModel(
        id: 'vital-1',
        patientId: 'profile-self',
        type: 'BP',
        value: 122.0,
        unit: 'mmHg (Sys)',
        measuredAt: now.subtract(const Duration(hours: 4)),
      ),
      VitalReadingModel(
        id: 'vital-2',
        patientId: 'profile-self',
        type: 'BLOOD_GLUCOSE',
        value: 96.0,
        unit: 'mg/dL (Fasting)',
        measuredAt: now.subtract(const Duration(days: 1)),
      ),
      VitalReadingModel(
        id: 'vital-3',
        patientId: 'profile-self',
        type: 'HEART_RATE',
        value: 72.0,
        unit: 'bpm',
        measuredAt: now.subtract(const Duration(hours: 4)),
      ),
      VitalReadingModel(
        id: 'vital-4',
        patientId: 'profile-self',
        type: 'WEIGHT',
        value: 74.0,
        unit: 'kg',
        measuredAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final v in initialVitals) {
      await db.insert('vital_readings', v.toMap());
    }

    // 8. Seed Health Records
    await db.insert('health_records', HealthRecordModel(
      id: 'rec-echo-1',
      patientId: 'profile-self',
      category: 'IMAGING',
      title: '12-Lead ECG & Echocardiogram Report',
      issuer: 'HeartCare Clinic Diagnostics',
      recordDate: now.subtract(const Duration(days: 3)),
      fileName: 'echocardiogram_ecg_report.pdf',
      verificationStatus: 'DOCTOR_VERIFIED',
    ).toMap());

    await db.insert('health_records', HealthRecordModel(
      id: 'rec-cbc-1',
      patientId: 'profile-self',
      category: 'LAB_REPORT',
      title: 'Complete Blood Count (CBC) with Differential',
      issuer: 'Metropolis Diagnostics Lab',
      recordDate: now.subtract(const Duration(days: 14)),
      fileName: 'cbc_report_oct2026.pdf',
      verificationStatus: 'AI_VERIFIED',
    ).toMap());

    await db.insert('health_records', HealthRecordModel(
      id: 'rec-rx-1',
      patientId: 'profile-self',
      category: 'PRESCRIPTION',
      title: 'Cardiology Prescription & Regimen',
      issuer: 'Dr. Aditi Deshmukh (HeartCare Clinic)',
      recordDate: now.subtract(const Duration(days: 28)),
      fileName: 'cardiology_prescription.pdf',
      verificationStatus: 'DOCTOR_VERIFIED',
    ).toMap());

    // Populate all 201 doctor records migrated from web project
    await seedWebDoctors(db);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
