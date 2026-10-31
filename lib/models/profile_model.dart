class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final String relation;
  final String? bloodGroup;
  final String? dob;
  final String? gender;
  final String? phone;
  final double? heightCm;
  final double? weightKg;
  final String? emergencyName;
  final String? emergencyPhone;
  final String? emergencyRelation;
  final List<String> allergies;
  final int onboardingStep;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    this.relation = 'SELF',
    this.bloodGroup,
    this.dob,
    this.gender,
    this.phone,
    this.heightCm,
    this.weightKg,
    this.emergencyName,
    this.emergencyPhone,
    this.emergencyRelation,
    this.allergies = const [],
    this.onboardingStep = 3,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'relation': relation,
      'blood_group': bloodGroup,
      'dob': dob,
      'gender': gender,
      'phone': phone,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'emergency_name': emergencyName,
      'emergency_phone': emergencyPhone,
      'emergency_relation': emergencyRelation,
      'allergies': allergies.join(','),
      'onboarding_step': onboardingStep,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'user-patient-1',
      name: map['name'] as String,
      relation: map['relation'] as String? ?? 'SELF',
      bloodGroup: map['blood_group'] as String?,
      dob: map['dob'] as String?,
      gender: map['gender'] as String?,
      phone: map['phone'] as String?,
      heightCm: (map['height_cm'] != null) ? (map['height_cm'] as num).toDouble() : null,
      weightKg: (map['weight_kg'] != null) ? (map['weight_kg'] as num).toDouble() : null,
      emergencyName: map['emergency_name'] as String?,
      emergencyPhone: map['emergency_phone'] as String?,
      emergencyRelation: map['emergency_relation'] as String?,
      allergies: map['allergies'] != null && (map['allergies'] as String).isNotEmpty
          ? (map['allergies'] as String).split(',')
          : [],
      onboardingStep: (map['onboarding_step'] as num?)?.toInt() ?? 3,
    );
  }
}
