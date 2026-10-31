import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../sync/sync_status_bar.dart';
import 'add_vital_dialog.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitalsAsync = ref.watch(vitalsListProvider);
    final recordsAsync = ref.watch(healthRecordsListProvider);
    final dateFormat = DateFormat('d MMM y • h:mm a');

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text(
          'Health Records & Vitals',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SyncStatusBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Vitals Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vital Signs History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AddVitalDialog(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Vital'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Vitals list
                vitalsAsync.when(
                  data: (vitals) {
                    if (vitals.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: const Text('No vitals recorded yet. Tap "+ Add Vital" to record offline.'),
                      );
                    }

                    return Column(
                      children: vitals.map((v) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.favorite_rounded, color: AppColors.primary700, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.type.replaceAll('_', ' '),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        dateFormat.format(v.measuredAt),
                                        style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${v.value.toStringAsFixed(1)} ${v.unit.split(' ').first}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.primary700,
                                    ),
                                  ),
                                  if (v.syncStatus != 'synced') ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.cloud_upload_outlined, size: 16, color: Color(0xFFB45309)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 24),

                // Clinical Records Section Header
                const Text(
                  'Clinical Documents & Reports',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate900),
                ),
                const SizedBox(height: 10),

                recordsAsync.when(
                  data: (records) {
                    if (records.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: const Text('No medical documents found in local database.'),
                      );
                    }

                    return Column(
                      children: records.map((r) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.slate100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      r.category.replaceAll('_', ' '),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.slate700),
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
                              const SizedBox(height: 8),
                              Text(
                                r.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slate900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Issued by ${r.issuer} • ${DateFormat('d MMM y').format(r.recordDate)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                              ),
                              if (r.fileName != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf_outlined, size: 14, color: AppColors.errorRed),
                                    const SizedBox(width: 4),
                                    Text(
                                      r.fileName!,
                                      style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
