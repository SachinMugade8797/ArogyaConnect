import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../providers/app_providers.dart';
import 'book_appointment_sheet.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsListProvider);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary700,
          unselectedLabelColor: AppColors.slate500,
          indicatorColor: AppColors.primary600,
          tabs: const [
            Tab(text: 'Upcoming & Active'),
            Tab(text: 'Past & Cancelled'),
          ],
        ),
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          final now = DateTime.now().subtract(const Duration(hours: 1));
          final upcoming = appointments
              .where((a) => a.status != 'cancelled' && a.appointmentAt.isAfter(now))
              .toList();
          final past = appointments
              .where((a) => a.status == 'cancelled' || a.appointmentAt.isBefore(now))
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _AppointmentList(appointments: upcoming, isUpcoming: true),
              _AppointmentList(appointments: past, isUpcoming: false),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading appointments: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book Appointment'),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const BookAppointmentSheet(),
          );
        },
      ),
    );
  }
}

class _AppointmentList extends ConsumerWidget {
  final List<AppointmentModel> appointments;
  final bool isUpcoming;

  const _AppointmentList({
    required this.appointments,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_rounded, size: 64, color: AppColors.slate300),
            const SizedBox(height: 12),
            Text(
              isUpcoming ? 'No upcoming appointments.' : 'No past appointments.',
              style: const TextStyle(fontSize: 15, color: AppColors.slate600, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('EEE, d MMM y • h:mm a');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final a = appointments[index];

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
                      'Token #${a.tokenNumber ?? index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: a.status == 'cancelled' ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                          a.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: a.status == 'cancelled' ? const Color(0xFF991B1B) : const Color(0xFF166534),
                          ),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                a.doctorName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
              ),
              Text(
                '${a.doctorSpeciality} • ${a.clinicName}',
                style: const TextStyle(fontSize: 13, color: AppColors.slate600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 15, color: AppColors.primary600),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(a.appointmentAt),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slate800),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    a.mode == 'VIDEO' ? Icons.videocam_outlined : Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    a.mode == 'VIDEO' ? 'Video' : 'In-Person',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                  ),
                ],
              ),
              if (isUpcoming && a.status != 'cancelled') ...[
                const Divider(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Cancel Appointment?'),
                          content: const Text('Are you sure you want to cancel this appointment?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Cancel Appointment'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(appointmentRepositoryProvider).cancelAppointment(a.id);
                        ref.invalidate(appointmentsListProvider);
                      }
                    },
                    child: const Text('Cancel Visit'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
