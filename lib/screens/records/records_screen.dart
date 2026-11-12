import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vital_model.dart';
import '../../models/health_record_model.dart';
import '../../providers/app_providers.dart';
import 'add_vital_dialog.dart';
import 'add_document_dialog.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  bool _showHistoricalVitals = true;
  String _documentFilter = 'ALL'; // 'ALL', 'VERIFIED', 'NOT_VERIFIED'

  final DateFormat _dateFormat = DateFormat('d MMM y • h:mm a');
  final DateFormat _shortDate = DateFormat('d MMM, h:mm a');

  void _openAddDocument(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMedicalDocumentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vitalsAsync = ref.watch(vitalsListProvider);
    final recordsAsync = ref.watch(healthRecordsListProvider);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.folder_shared_rounded, color: AppColors.primary700, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Health Records & Vitals',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.slate900),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // SECTION 1: LATEST VITALS
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Vital Signs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
                    ),
                    Text(
                      'Only latest readings displayed; previous stored with dates',
                      style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddVitalDialog(),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Vital', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          vitalsAsync.when(
            data: (vitals) {
              // Group vitals so only the latest reading per type is shown in primary view
              // and previous readings are preserved with their dates
              final Map<String, VitalReadingModel> latestVitals = {};
              final List<VitalReadingModel> previousVitals = [];

              for (final vital in vitals) {
                if (!latestVitals.containsKey(vital.type)) {
                  latestVitals[vital.type] = vital;
                } else {
                  previousVitals.add(vital);
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2x2 Grid for Core 4 Vitals (BP, Heart Rate, Blood Glucose, Weight)
                  _buildCoreVitalsGrid(latestVitals),

                  // Additional vitals if any (e.g., SpO2, Temperature)
                  ..._buildOtherLatestVitals(latestVitals),

                  const SizedBox(height: 16),

                  // Historical Vitals Header & Toggle (Stored with dates)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _showHistoricalVitals = !_showHistoricalVitals),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.history_rounded, size: 16, color: AppColors.slate600),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          const Text(
                                            'Previous Readings History',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.slate800),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary50,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${previousVitals.length} Stored with Dates',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary700),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'All previous measurements saved with timestamp archive',
                                        style: TextStyle(fontSize: 11, color: AppColors.slate400),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  _showHistoricalVitals ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.slate400,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showHistoricalVitals) ...[
                          const Divider(height: 1, color: AppColors.slate200),
                          if (previousVitals.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.slate400),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No previous readings yet. When you add a new value, the previous value will automatically be archived here with its date and time.',
                                      style: TextStyle(fontSize: 12, color: AppColors.slate500, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: previousVitals.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.slate100),
                              itemBuilder: (context, idx) {
                                final prev = previousVitals[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: _getVitalColor(prev.type).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(_getVitalIcon(prev.type), size: 14, color: _getVitalColor(prev.type)),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _formatVitalName(prev.type),
                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.slate800),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.slate400),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          _dateFormat.format(prev.measuredAt),
                                                          style: const TextStyle(fontSize: 10, color: AppColors.slate500, fontWeight: FontWeight.w500),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.slate50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.slate200),
                                        ),
                                        child: Text(
                                          '${prev.value.toStringAsFixed(1)} ${prev.unit.split(' ').first}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            color: AppColors.slate700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (e, _) => Text('Error loading vitals: $e'),
          ),

          const SizedBox(height: 28),

          // ==========================================
          // SECTION 2: MEDICAL RECORD DOCUMENTS
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Documents & Reports',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
                    ),
                    Text(
                      'Recent documents appear first with verification status',
                      style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () => _openAddDocument(context),
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('Add Document', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Document Filter Chips (All, Verified, Not Verified)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All Documents'),
                const SizedBox(width: 8),
                _buildFilterChip('VERIFIED', 'Verified'),
                const SizedBox(width: 8),
                _buildFilterChip('NOT_VERIFIED', 'Not Verified'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Document List (Recent document appears first)
          recordsAsync.when(
            data: (records) {
              // Apply filter
              final filtered = records.where((r) {
                final status = r.verificationStatus.toUpperCase();
                final isVer = status.contains('VERIFIED') && !status.contains('NOT');
                if (_documentFilter == 'VERIFIED') return isVer;
                if (_documentFilter == 'NOT_VERIFIED') return !isVer;
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined, size: 40, color: AppColors.slate300),
                      const SizedBox(height: 10),
                      const Text(
                        'No medical documents found',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.slate700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap "+ Add Document" to upload a PDF report with title, description & status.',
                        style: TextStyle(fontSize: 12, color: AppColors.slate500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent600,
                          side: const BorderSide(color: AppColors.accent600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _openAddDocument(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add First Document'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: filtered.map((r) => _buildDocumentCard(r)).toList(),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (e, _) => Text('Error loading documents: $e'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS FOR LATEST VITALS
  // ==========================================

  Widget _buildCoreVitalsGrid(Map<String, VitalReadingModel> latestVitals) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSingleVitalCard('BP', latestVitals['BP'])),
            const SizedBox(width: 10),
            Expanded(child: _buildSingleVitalCard('HEART_RATE', latestVitals['HEART_RATE'])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildSingleVitalCard('BLOOD_GLUCOSE', latestVitals['BLOOD_GLUCOSE'])),
            const SizedBox(width: 10),
            Expanded(child: _buildSingleVitalCard('WEIGHT', latestVitals['WEIGHT'])),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleVitalCard(String type, VitalReadingModel? vital) {
    final color = _getVitalColor(type);
    final icon = _getVitalIcon(type);
    final title = _formatVitalName(type);

    if (vital == null) {
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const AddVitalDialog(),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.slate200, style: BorderStyle.solid),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.slate400),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 2),
              const Text('Tap to log reading', style: TextStyle(fontSize: 10, color: AppColors.slate400)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LATEST',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate500),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                vital.value.toStringAsFixed(type == 'WEIGHT' ? 1 : 0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vital.unit.split(' ').first,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 10, color: AppColors.slate400),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  _shortDate.format(vital.measuredAt),
                  style: const TextStyle(fontSize: 9, color: AppColors.slate400, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOtherLatestVitals(Map<String, VitalReadingModel> latestVitals) {
    final otherKeys = latestVitals.keys.where((k) => !['BP', 'HEART_RATE', 'BLOOD_GLUCOSE', 'WEIGHT'].contains(k)).toList();
    if (otherKeys.isEmpty) return [];

    return [
      const SizedBox(height: 10),
      ...otherKeys.map((k) {
        final v = latestVitals[k]!;
        final color = _getVitalColor(k);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(_getVitalIcon(k), color: color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatVitalName(k), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                          Text('Latest: ${_shortDate.format(v.measuredAt)}', style: const TextStyle(fontSize: 10, color: AppColors.slate400)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${v.value.toStringAsFixed(1)} ${v.unit}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color),
              ),
            ],
          ),
        );
      }),
    ];
  }

  // ==========================================
  // HELPER WIDGETS FOR MEDICAL DOCUMENTS
  // ==========================================

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _documentFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _documentFilter = filterKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent600 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.accent600 : AppColors.slate200),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.slate600,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(HealthRecordModel record) {
    final isVerified = record.verificationStatus.toUpperCase().contains('VERIFIED') &&
        !record.verificationStatus.toUpperCase().contains('NOT');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges: Category & Status Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    record.category.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status of document as a label (Verified or Not Verified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isVerified ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      size: 12,
                      color: isVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Verified' : 'Not Verified',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            record.title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.slate900,
            ),
          ),

          // Description (if present)
          if (record.description != null && record.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              record.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate600,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 8),

          // PDF file badge
          if (record.fileName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.fileName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PDF',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Issuer & Date Row at the bottom of the document card
          Row(
            children: [
              Expanded(
                child: Text(
                  'Issued by: ${record.issuer}',
                  style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, size: 11, color: AppColors.slate400),
                  const SizedBox(width: 4),
                  Text(
                    _dateFormat.format(record.recordDate),
                    style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Formatting helpers
  String _formatVitalName(String type) {
    switch (type) {
      case 'BP':
        return 'Blood Pressure';
      case 'HEART_RATE':
        return 'Heart Rate';
      case 'BLOOD_GLUCOSE':
        return 'Blood Glucose';
      case 'WEIGHT':
        return 'Body Weight';
      case 'SPO2':
        return 'SpO2 Oxygen';
      case 'TEMPERATURE':
        return 'Temperature';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  Color _getVitalColor(String type) {
    switch (type) {
      case 'BP':
        return const Color(0xFFE11D48); // Rose red
      case 'HEART_RATE':
        return const Color(0xFFDB2777); // Pink
      case 'BLOOD_GLUCOSE':
        return AppColors.primary600; // Teal
      case 'WEIGHT':
        return const Color(0xFF2563EB); // Royal Blue
      case 'SPO2':
        return const Color(0xFF0284C7); // Cyan
      case 'TEMPERATURE':
        return const Color(0xFFD97706); // Amber
      default:
        return AppColors.primary700;
    }
  }

  IconData _getVitalIcon(String type) {
    switch (type) {
      case 'BP':
        return Icons.speed_rounded;
      case 'HEART_RATE':
        return Icons.monitor_heart_rounded;
      case 'BLOOD_GLUCOSE':
        return Icons.water_drop_rounded;
      case 'WEIGHT':
        return Icons.scale_rounded;
      case 'SPO2':
        return Icons.air_rounded;
      case 'TEMPERATURE':
        return Icons.thermostat_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }
}
