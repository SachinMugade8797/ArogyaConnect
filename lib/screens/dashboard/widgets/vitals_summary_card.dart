import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';

class VitalsSummaryCard extends ConsumerWidget {
  final VoidCallback onAddVital;

  const VitalsSummaryCard({super.key, required this.onAddVital});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitalsAsync = ref.watch(vitalsListProvider);

    return Container(
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
              const Text(
                'Health Vitals',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              TextButton.icon(
                onPressed: onAddVital,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Log Vital', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary600,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          vitalsAsync.when(
            data: (vitals) {
              if (vitals.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No vitals recorded yet. Tap "Log Vital" to add.',
                      style: TextStyle(fontSize: 13, color: AppColors.slate500)),
                );
              }

              // Take last 3 vitals
              final recent = vitals.take(3).toList();
              return Row(
                children: recent.map((v) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatVitalType(v.type),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${v.value.toInt()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary700,
                            ),
                          ),
                          Text(
                            v.unit.split(' ').first,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, stack) => const Text('Failed to load vitals from local database.'),
          ),
        ],
      ),
    );
  }

  String _formatVitalType(String type) {
    switch (type) {
      case 'BP':
        return 'Blood Pressure';
      case 'BLOOD_GLUCOSE':
        return 'Glucose';
      case 'HEART_RATE':
        return 'Heart Rate';
      default:
        return type;
    }
  }
}
