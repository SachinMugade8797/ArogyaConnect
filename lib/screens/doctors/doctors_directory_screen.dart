import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../providers/app_providers.dart';
import '../appointments/book_appointment_sheet.dart';

class DoctorsDirectoryScreen extends ConsumerWidget {
  const DoctorsDirectoryScreen({super.key});

  static const List<String> specialities = [
    'All',
    'General Physician',
    'Cardiologist',
    'Pediatrician',
    'Dermatologist',
    'Orthopedic',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(filteredDoctorsProvider);
    final selectedSpeciality = ref.watch(doctorSpecialityFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text(
          'Find Doctors & Clinics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor, clinic or city (e.g. Pune, Kolhapur)...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.slate400),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate500),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                filled: true,
                fillColor: AppColors.slate50,
              ),
              onChanged: (val) {
                ref.read(doctorSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Specialities Filter Horizontal List
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: specialities.length,
              itemBuilder: (context, idx) {
                final spec = specialities[idx];
                final isSelected = spec == selectedSpeciality;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    selectedColor: AppColors.primary100,
                    checkmarkColor: AppColors.primary700,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          const Divider(height: 1),

          // Doctors List
          Expanded(
            child: doctorsAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) {
                  return const Center(
                    child: Text('No doctors match your search.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, idx) {
                    final doc = doctors[idx];
                    return _DoctorCard(doctor: doc);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary100,
                child: Text(
                  doctor.name.replaceFirst('Dr. ', '')[0],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    Text(
                      doctor.speciality,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doctor.clinic} • ${doctor.city}',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        doctor.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${doctor.consultationFee.toInt()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (doctor.bio != null) ...[
            const SizedBox(height: 10),
            Text(
              doctor.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.slate600),
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (doctor.offersVideo)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.videocam_outlined, size: 12, color: AppColors.accent600),
                          SizedBox(width: 3),
                          Text('Video Consult', style: TextStyle(fontSize: 10, color: AppColors.accent600, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  Text(
                    '${doctor.experienceYears ?? 10}+ yrs exp',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                child: const Text('Book Visit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
