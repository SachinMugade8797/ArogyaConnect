import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import 'doctor_patient_records_screen.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);
    final authState = ref.watch(authProvider);
    final doctorUser = authState.user;
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Doctor Portal',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.slate900),
            ),
          ],
        ),
        actions: [
          // Switch Role Quick Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary700),
            tooltip: 'Switch Portal / Role',
            onSelected: (val) {
              if (val == 'patient') {
                ref.read(authProvider.notifier).switchDemoRole('patient');
              } else if (val == 'logout') {
                ref.read(authProvider.notifier).logout();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'patient',
                child: Row(
                  children: [
                    Icon(Icons.person_rounded, size: 18, color: AppColors.primary600),
                    SizedBox(width: 8),
                    Text('Switch to Patient View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: AppColors.errorRed),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(doctorAppointmentsProvider);
        },
        child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Doctor Profile Greeting Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary800, AppColors.primary600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: const Icon(Icons.person, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctorUser?.fullName ?? 'Dr. Aditi Deshmukh',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const Text(
                                    'Cardiologist • HeartCare Clinic & Diagnostics',
                                    style: TextStyle(color: AppColors.primary100, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'MCI Verified',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Queue KPI Counters (Matching Web)
                  appointmentsAsync.when(
                    data: (items) {
                      final waiting = items.where((i) => i.appointment.status == 'waiting' || i.appointment.status == 'confirmed').length;
                      final consult = items.where((i) => i.appointment.status == 'in_consultation').length;
                      final completed = items.where((i) => i.appointment.status == 'completed').length;

                      return Row(
                        children: [
                          _KpiCard(title: 'Waiting', count: waiting, color: const Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          _KpiCard(title: 'Consulting', count: consult, color: AppColors.accent600),
                          const SizedBox(width: 8),
                          _KpiCard(title: 'Completed', count: completed, color: const Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          _KpiCard(title: 'Total Today', count: items.length, color: AppColors.slate700),
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, stack) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // 3. Today's Patient Queue Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Patient Queue",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Refresh'),
                        onPressed: () => ref.invalidate(doctorAppointmentsProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  appointmentsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: const Center(
                            child: Text('No appointments in the queue for today.', style: TextStyle(color: AppColors.slate500)),
                          ),
                        );
                      }

                      return Column(
                        children: items.map((item) {
                          final appt = item.appointment;
                          final patient = item.patientProfile;

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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.primary200),
                                      ),
                                      child: Text(
                                        'Token #${appt.tokenNumber ?? 1}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary800, fontSize: 12),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: appt.status == 'completed'
                                            ? const Color(0xFFDCFCE7)
                                            : appt.status == 'in_consultation'
                                                ? AppColors.accent50
                                                : const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        appt.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: appt.status == 'completed'
                                              ? const Color(0xFF15803D)
                                              : appt.status == 'in_consultation'
                                                  ? AppColors.accent700
                                                  : const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Patient Name & demographics
                                Text(
                                  patient?.name ?? 'Patient (Self)',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${patient?.gender ?? "Male"} • Blood Group: ${patient?.bloodGroup ?? "B+"} • Phone: ${patient?.phone ?? "+91 98221 00101"}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                                ),
                                if (patient?.allergies.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '⚠️ Allergies: ${patient!.allergies.join(", ")}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),

                                // Reason & Time
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.slate500),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeFormat.format(appt.appointmentAt),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate800),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.medical_information_outlined, size: 14, color: AppColors.slate500),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        appt.reason ?? 'General Consultation',
                                        style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),

                                // Actions: Open Dossier & Change status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Status Change Dropdown
                                    DropdownButton<String>(
                                      value: ['pending', 'confirmed', 'waiting', 'in_consultation', 'completed', 'cancelled']
                                              .contains(appt.status.toLowerCase())
                                          ? appt.status.toLowerCase()
                                          : 'confirmed',
                                      underline: const SizedBox.shrink(),
                                      style: const TextStyle(fontSize: 12, color: AppColors.slate700, fontWeight: FontWeight.w600),
                                      items: const [
                                        DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                                        DropdownMenuItem(value: 'waiting', child: Text('Mark Waiting')),
                                        DropdownMenuItem(value: 'in_consultation', child: Text('In Consultation')),
                                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                      ],
                                      onChanged: (newStatus) async {
                                        if (newStatus != null) {
                                          await ref
                                              .read(doctorConsultationRepositoryProvider)
                                              .updateAppointmentStatus(appt.id, newStatus);
                                          ref.invalidate(doctorAppointmentsProvider);
                                        }
                                      },
                                    ),

                                    // Open Patient Dossier Button
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      icon: const Icon(Icons.folder_shared_outlined, size: 16),
                                      label: const Text('Open Dossier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DoctorPatientRecordsScreen(
                                              profileId: appt.profileId ?? 'profile-self',
                                              appointment: appt,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, stack) => Center(child: Text('Error: $e')),
                  ),
                ],
              ),
            ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _KpiCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.slate500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
