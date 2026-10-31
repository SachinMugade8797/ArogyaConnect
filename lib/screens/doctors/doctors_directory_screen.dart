import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../providers/app_providers.dart';
import '../appointments/book_appointment_sheet.dart';

class DoctorsDirectoryScreen extends ConsumerStatefulWidget {
  const DoctorsDirectoryScreen({super.key});

  @override
  ConsumerState<DoctorsDirectoryScreen> createState() => _DoctorsDirectoryScreenState();
}

class _DoctorsDirectoryScreenState extends ConsumerState<DoctorsDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> cities = [
    'All',
    'Kolhapur',
    'Pune',
    'Mumbai',
    'Sangli',
    'Satara',
    'Nashik',
    'Solapur',
    'Bengaluru',
  ];

  static const List<String> specialities = [
    'All',
    'Cardiology',
    'Dermatology',
    'Orthopedics',
    'Pediatrics',
    'General Medicine',
    'Neurology',
    'Gynecology',
    'ENT',
    'Gastroenterology',
    'Pulmonology',
    'Oncology',
    'Physiotherapy',
    'General Physician',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(doctorSearchQueryProvider.notifier).state = '';
    ref.read(doctorCityFilterProvider.notifier).state = 'All';
    ref.read(doctorSpecialityFilterProvider.notifier).state = 'All';
    ref.read(doctorVideoOnlyFilterProvider.notifier).state = false;
    ref.read(doctorSortByProvider.notifier).state = 'rating';
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(filteredDoctorsProvider);
    final selectedCity = ref.watch(doctorCityFilterProvider);
    final selectedSpeciality = ref.watch(doctorSpecialityFilterProvider);
    final isVideoOnly = ref.watch(doctorVideoOnlyFilterProvider);
    final sortBy = ref.watch(doctorSortByProvider);
    final cityCountsAsync = ref.watch(doctorCityCountsProvider);

    final hasActiveFilters = selectedCity != 'All' ||
        selectedSpeciality != 'All' ||
        isVideoOnly ||
        sortBy != 'rating' ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Doctors & Clinics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.slate900),
            ),
            Text(
              'Maharashtra & Bengaluru Healthcare Network',
              style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (hasActiveFilters)
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary600),
              label: const Text(
                'Reset',
                style: TextStyle(fontSize: 12, color: AppColors.primary600, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctor, clinic or city (e.g. Pune, Kolhapur)...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.slate400),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate500),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(doctorSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.slate50,
              ),
              onChanged: (val) {
                ref.read(doctorSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // City Filter Chips with Doctor Count
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary600),
                      const SizedBox(width: 4),
                      const Text(
                        'Browse by City:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      if (selectedCity != 'All')
                        Text(
                          'City: $selectedCity',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary700,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: cities.length,
                    itemBuilder: (context, idx) {
                      final city = cities[idx];
                      final isSelected = city == selectedCity;
                      final count = cityCountsAsync.maybeWhen(
                        data: (counts) {
                          if (city == 'All') {
                            return counts.values.fold<int>(0, (sum, c) => sum + c);
                          }
                          return counts[city] ?? 0;
                        },
                        orElse: () => null,
                      );

                      final countLabel = count != null ? ' ($count)' : '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text('$city$countLabel'),
                          selected: isSelected,
                          selectedColor: AppColors.primary600,
                          backgroundColor: AppColors.slate100,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.slate700,
                          ),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary600 : AppColors.slate200,
                            ),
                          ),
                          onSelected: (_) {
                            ref.read(doctorCityFilterProvider.notifier).state = city;
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Specialities Filter Horizontal List
          Container(
            height: 38,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: specialities.length,
              itemBuilder: (context, idx) {
                final spec = specialities[idx];
                final isSelected = spec == selectedSpeciality;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    selectedColor: AppColors.primary100,
                    checkmarkColor: AppColors.primary700,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary500 : AppColors.slate200,
                      ),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary800 : AppColors.slate700,
                    ),
                    onSelected: (_) {
                      ref.read(doctorSpecialityFilterProvider.notifier).state = spec;
                    },
                  ),
                );
              },
            ),
          ),

          // Controls Bar: Video Consultation Toggle & Sort Options
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                // Video Consult Toggle
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded, size: 14),
                      SizedBox(width: 4),
                      Text('Video Consult', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  selected: isVideoOnly,
                  selectedColor: AppColors.accent100,
                  checkmarkColor: AppColors.accent700,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isVideoOnly ? AppColors.accent500 : AppColors.slate200,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isVideoOnly ? FontWeight.bold : FontWeight.w500,
                    color: isVideoOnly ? AppColors.accent700 : AppColors.slate700,
                  ),
                  onSelected: (val) {
                    ref.read(doctorVideoOnlyFilterProvider.notifier).state = val;
                  },
                ),
                const Spacer(),

                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sortBy,
                      isDense: true,
                      icon: const Icon(Icons.sort_rounded, size: 16, color: AppColors.slate600),
                      style: const TextStyle(fontSize: 11, color: AppColors.slate800, fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'rating', child: Text('Rating: High to Low')),
                        DropdownMenuItem(value: 'experience', child: Text('Experience: Most')),
                        DropdownMenuItem(value: 'fee_low', child: Text('Fee: Low to High')),
                        DropdownMenuItem(value: 'fee_high', child: Text('Fee: High to Low')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(doctorSortByProvider.notifier).state = val;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Doctors List Header & Results
          Expanded(
            child: doctorsAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search_rounded, size: 56, color: AppColors.slate300),
                          const SizedBox(height: 12),
                          const Text(
                            'No doctors match your criteria',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            selectedCity != 'All'
                                ? 'No doctors found in $selectedCity with current filters.'
                                : 'Try clearing filters or searching another keyword or city.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: AppColors.slate500),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _clearAllFilters,
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('Reset All Filters'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: doctors.length + 1,
                  itemBuilder: (context, idx) {
                    if (idx == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 4),
                        child: Row(
                          children: [
                            Text(
                              'Showing ${doctors.length} verified doctor${doctors.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate600,
                              ),
                            ),
                            if (selectedCity != 'All') ...[
                              const SizedBox(width: 4),
                              Text(
                                'in $selectedCity',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    final doc = doctors[idx - 1];
                    return _DoctorCard(doctor: doc);
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Loading doctors...',
                      style: TextStyle(fontSize: 13, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error loading doctors: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Name, Speciality, Rating & Fee
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary100,
                    child: Text(
                      doctor.name.replaceFirst('Dr. ', '').isNotEmpty
                          ? doctor.name.replaceFirst('Dr. ', '')[0]
                          : 'D',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary800,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColors.primary600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.speciality,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Clinic & City Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary200, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 11, color: AppColors.primary700),
                              const SizedBox(width: 2),
                              Text(
                                doctor.city,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            doctor.clinic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Rating & Consultation Fee
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${doctor.consultationFee.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                  const Text(
                    'per visit',
                    style: TextStyle(fontSize: 10, color: AppColors.slate400),
                  ),
                ],
              ),
            ],
          ),

          if (doctor.clinicAddress.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business_outlined, size: 13, color: AppColors.slate400),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doctor.clinicAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                  ),
                ),
              ],
            ),
          ],

          if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              doctor.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.slate600, height: 1.3),
            ),
          ],

          const Divider(height: 18),

          // Bottom Row: Features, Experience, Languages & Book Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (doctor.offersVideo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accent200, width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_outlined, size: 12, color: AppColors.accent600),
                            SizedBox(width: 3),
                            Text(
                              'Video',
                              style: TextStyle(fontSize: 10, color: AppColors.accent700, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${doctor.experienceYears ?? 10}+ yrs exp',
                        style: const TextStyle(fontSize: 10, color: AppColors.slate600, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (doctor.languages.isNotEmpty)
                      Text(
                        doctor.languages.take(2).join(', '),
                        style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BookAppointmentSheet(initialDoctor: doctor),
                  );
                },
                child: const Text(
                  'Book Visit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
