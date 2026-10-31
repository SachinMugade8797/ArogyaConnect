import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../sync/sync_status_bar.dart';
import 'widgets/active_profile_bar.dart';
import 'widgets/vitals_summary_card.dart';
import 'widgets/upcoming_appointment_card.dart';
import '../records/add_vital_dialog.dart';
import '../appointments/book_appointment_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsListProvider);
    final recordsAsync = ref.watch(healthRecordsListProvider);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'ArogyaNexus',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary700),
            tooltip: 'Switch Portal / Role',
            onSelected: (val) {
              if (val == 'doctor') {
                ref.read(authProvider.notifier).switchDemoRole('doctor');
              } else if (val == 'logout') {
                ref.read(authProvider.notifier).logout();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'doctor',
                child: Row(
                  children: [
                    Icon(Icons.medical_services_rounded, size: 18, color: AppColors.primary600),
                    SizedBox(width: 8),
                    Text('Switch to Doctor Portal'),
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
      body: Column(
        children: [
          const SyncStatusBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(syncEngineProvider).syncAll();
                ref.invalidate(appointmentsListProvider);
                ref.invalidate(vitalsListProvider);
                ref.invalidate(healthRecordsListProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Active Family Profile Switcher
                  const ActiveProfileBar(),
                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.calendar_today_rounded,
                          label: 'Book Visit',
                          color: AppColors.primary600,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const BookAppointmentSheet(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.favorite_rounded,
                          label: 'Log Vitals',
                          color: const Color(0xFFE11D48),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => const AddVitalDialog(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.people_outline_rounded,
                          label: 'Directory',
                          color: AppColors.accent600,
                          onTap: () => onTabChange(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Next Upcoming Appointment Section
                  const Text(
                    'Upcoming Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  appointmentsAsync.when(
                    data: (appointments) {
                      final upcoming = appointments
                          .where((a) => a.status != 'cancelled' && a.appointmentAt.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
                          .toList();

                      if (upcoming.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_available_rounded, color: AppColors.slate400, size: 28),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'No pending appointments scheduled.',
                                  style: TextStyle(fontSize: 13, color: AppColors.slate600),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const BookAppointmentSheet(),
                                  );
                                },
                                child: const Text('Book Now'),
                              ),
                            ],
                          ),
                        );
                      }

                      return UpcomingAppointmentCard(
                        appointment: upcoming.first,
                        onTap: () => onTabChange(1),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, stack) => const Text('Unable to load appointments from local database'),
                  ),
                  const SizedBox(height: 16),

                  // Vitals Snapshot (Offline)
                  VitalsSummaryCard(
                    onAddVital: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddVitalDialog(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Health Documents Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Health Records',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onTabChange(3),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  recordsAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const Text('No records found in local database.');
                      }
                      return Column(
                        children: records.take(2).map((r) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.description_outlined, color: AppColors.primary700, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.title,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                      ),
                                      Text(
                                        '${r.issuer} • ${r.category}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    r.verificationStatus.replaceAll('_', ' '),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: LinearProgressIndicator()),
                    error: (e, stack) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
