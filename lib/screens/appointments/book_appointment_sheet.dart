import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../providers/app_providers.dart';

class BookAppointmentSheet extends ConsumerStatefulWidget {
  final DoctorModel? initialDoctor;

  const BookAppointmentSheet({super.key, this.initialDoctor});

  @override
  ConsumerState<BookAppointmentSheet> createState() => _BookAppointmentSheetState();
}

class _BookAppointmentSheetState extends ConsumerState<BookAppointmentSheet> {
  DoctorModel? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 30);
  final _reasonController = TextEditingController();
  String _mode = 'IN_PERSON';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.initialDoctor;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(filteredDoctorsProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final dateFormat = DateFormat('EEE, d MMM y');

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Select Doctor
            const Text('Doctor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate700)),
            const SizedBox(height: 6),
            doctorsAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) return const Text('No doctors available in local cache.');
                _selectedDoctor ??= doctors.first;

                return DropdownButtonFormField<DoctorModel>(
                  initialValue: _selectedDoctor,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: doctors.map((doc) {
                    return DropdownMenuItem(
                      value: doc,
                      child: Text('${doc.name} (${doc.speciality})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDoctor = val);
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, stack) => const Text('Error loading doctors.'),
            ),
            const SizedBox(height: 14),

            // Date & Time Picker
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate700)),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary600),
                        label: Text(
                          dateFormat.format(_selectedDate),
                          style: const TextStyle(fontSize: 13, color: AppColors.slate800),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate700)),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary600),
                        label: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 13, color: AppColors.slate800),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) setState(() => _selectedTime = picked);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Consultation Mode
            const Text('Consultation Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate700)),
            const SizedBox(height: 6),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('In-Person Visit'),
                  selected: _mode == 'IN_PERSON',
                  onSelected: (val) {
                    if (val) setState(() => _mode = 'IN_PERSON');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Video Call'),
                  selected: _mode == 'VIDEO',
                  onSelected: (val) {
                    if (val) setState(() => _mode = 'VIDEO');
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Reason
            const Text('Reason for Visit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate700)),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Chest discomfort, prescription renewal...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving || _selectedDoctor == null
                    ? null
                    : () async {
                        setState(() => _isSaving = true);

                        final appointmentDateTime = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        );

                        final scaffold = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        final repo = ref.read(appointmentRepositoryProvider);
                        await repo.bookAppointment(
                          patientId: 'user-demo',
                          profileId: activeId,
                          doctorProfileId: _selectedDoctor!.id,
                          doctorName: _selectedDoctor!.name,
                          doctorSpeciality: _selectedDoctor!.speciality,
                          clinicName: _selectedDoctor!.clinic,
                          appointmentAt: appointmentDateTime,
                          reason: _reasonController.text.trim().isNotEmpty
                              ? _reasonController.text.trim()
                              : 'General consultation',
                          mode: _mode,
                        );

                        ref.invalidate(appointmentsListProvider);

                        if (!mounted) return;
                        navigator.pop();
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text('Appointment booked & stored in local database!'),
                            backgroundColor: AppColors.primary700,
                          ),
                        );
                      },
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Appointment (Offline First)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
