class DoctorModel {
  final String id;
  final String name;
  final String speciality;
  final String clinic;
  final String clinicAddress;
  final String city;
  final double consultationFee;
  final double rating;
  final int reviewCount;
  final int? experienceYears;
  final List<String> languages;
  final String? bio;
  final bool offersVideo;

  DoctorModel({
    required this.id,
    required this.name,
    required this.speciality,
    required this.clinic,
    required this.clinicAddress,
    required this.city,
    required this.consultationFee,
    this.rating = 4.8,
    this.reviewCount = 0,
    this.experienceYears,
    this.languages = const ['English', 'Hindi'],
    this.bio,
    this.offersVideo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'speciality': speciality,
      'clinic': clinic,
      'clinic_address': clinicAddress,
      'city': city,
      'consultation_fee': consultationFee,
      'rating': rating,
      'review_count': reviewCount,
      'experience_years': experienceYears,
      'languages': languages.join(','),
      'bio': bio,
      'offers_video': offersVideo ? 1 : 0,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] as String,
      name: map['name'] as String,
      speciality: map['speciality'] as String,
      clinic: map['clinic'] as String,
      clinicAddress: map['clinic_address'] as String? ?? '',
      city: map['city'] as String? ?? 'Bengaluru',
      consultationFee: (map['consultation_fee'] as num).toDouble(),
      rating: (map['rating'] != null) ? (map['rating'] as num).toDouble() : 4.8,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      experienceYears: (map['experience_years'] as num?)?.toInt(),
      languages: map['languages'] != null && (map['languages'] as String).isNotEmpty
          ? (map['languages'] as String).split(',')
          : ['English', 'Hindi'],
      bio: map['bio'] as String?,
      offersVideo: (map['offers_video'] == 1 || map['offers_video'] == true),
    );
  }
}
