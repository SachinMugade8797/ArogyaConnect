import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/appointment_model.dart';

class DoctorPatientRecordsScreen extends ConsumerStatefulWidget {
  final String profileId;
  final AppointmentModel? appointment;

  const DoctorPatientRecordsScreen({
    super.key,
    required this.profileId,
    this.appointment,
  });

  @override
  ConsumerState<DoctorPatientRecordsScreen> createState() => _DoctorPatientRecordsScreenState();
}

class _DoctorPatientRecordsScreenState extends ConsumerState<DoctorPatientRecordsScreen> {
  String _activeTab = 'ALL';

  @override
  Widget build(BuildContext context) {
    final dossierAsync = ref.watch(patientDossierProvider(widget.profileId));
    final dateFormat = DateFormat('d MMM y');

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('Patient Clinical Dossier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary700),
            tooltip: 'Refresh Records',
            onPressed: () {
              ref.invalidate(patientDossierProvider(widget.profileId));
            },
          ),
        ],
      ),
      body: dossierAsync.when(
        data: (dossier) {
          final patient = dossier.patient;
          final conditions = dossier.conditions;
          final vitals = dossier.vitals;
          final records = dossier.records;
          final pastVisits = dossier.pastVisits;

          final filteredRecords = _activeTab == 'ALL'
              ? records
              : records.where((r) => r.category == _activeTab).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Patient Demographics & Profile Card
              Container(
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
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary100,
                          child: Text(
                            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primary800),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      patient.name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate900),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.primary200),
                                    ),
                                    child: Text(
                                      patient.relation,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${patient.gender ?? "Patient"} • Blood Group: ${patient.bloodGroup ?? "N/A"} • ${patient.phone ?? "No phone"}',
                                style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (patient.emergencyName != null) ...[
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.contact_phone_outlined, size: 16, color: AppColors.slate500),
                          const SizedBox(width: 6),
                          Text(
                            'Emergency Contact: ${patient.emergencyName} (${patient.emergencyRelation ?? "Kin"}) • ${patient.emergencyPhone ?? ""}',
                            style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Critical Allergies Alert (Web Parity)
              if (patient.allergies.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ALLERGIES ALERT',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF991B1B)),
                            ),
                            Text(
                              patient.allergies.join(', '),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // 3. Chronic Conditions
              const Text(
                'Chronic Conditions & Diagnoses',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate900),
              ),
              const SizedBox(height: 8),
              if (conditions.isEmpty)
                const Text('No documented chronic conditions.', style: TextStyle(fontSize: 12, color: AppColors.slate500))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: conditions.map((c) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.healing_rounded, size: 16, color: AppColors.primary600),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate800)),
                              if (c.notes != null)
                                Text(c.notes!, style: const TextStyle(fontSize: 10, color: AppColors.slate500)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // 4. Latest Vital Readings
              const Text(
                'Latest Patient Vitals',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate900),
              ),
              const SizedBox(height: 8),
              if (vitals.isEmpty)
                const Text('No vitals logged yet for this patient.', style: TextStyle(fontSize: 12, color: AppColors.slate500))
              else
                Row(
                  children: vitals.take(3).map((v) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.type.replaceAll('_', ' '), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate500)),
                            const SizedBox(height: 4),
                            Text('${v.value.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary700)),
                            Text(v.unit.split(' ').first, style: const TextStyle(fontSize: 10, color: AppColors.slate400)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),

              // 5. Patient Clinical Documents & Verification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Clinical Reports & Records',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate900),
                  ),
                  Text('${filteredRecords.length} documents', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                ],
              ),
              const SizedBox(height: 8),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'IMAGING', 'LAB_REPORT', 'PRESCRIPTION'].map((tab) {
                    final isSel = _activeTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(tab.replaceAll('_', ' ')),
                        selected: isSel,
                        selectedColor: AppColors.primary100,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? AppColors.primary800 : AppColors.slate700,
                        ),
                        onSelected: (_) => setState(() => _activeTab = tab),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              ...filteredRecords.map((r) {
                final isDoctorVerified = r.verificationStatus == 'DOCTOR_VERIFIED';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
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
                            child: Text(r.category.replaceAll('_', ' '), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDoctorVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isDoctorVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
                                  size: 12,
                                  color: isDoctorVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r.verificationStatus.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDoctorVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900)),
                      Text('Issued by ${r.issuer} • ${dateFormat.format(r.recordDate)}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                      const SizedBox(height: 10),

                      // Doctor action: verify document
                      if (!isDoctorVerified)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary700,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                            label: const Text('Verify Record as Doctor', style: TextStyle(fontSize: 12)),
                            onPressed: () async {
                              await ref.read(doctorConsultationRepositoryProvider).verifyHealthRecord(r.id);
                              ref.invalidate(patientDossierProvider(widget.profileId));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Document marked as DOCTOR_VERIFIED!')),
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // 6. Past Consultation Visits
              if (pastVisits.isNotEmpty) ...[
                const Text('Previous Consultation Visits', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate900)),
                const SizedBox(height: 8),
                ...pastVisits.map((v) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Diagnosis: ${v.diagnosis ?? "General consultation"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        if (v.notes != null) Text('Notes: ${v.notes}', style: const TextStyle(fontSize: 12, color: AppColors.slate600)),
                        if (v.testsAdvised != null) Text('Advised: ${v.testsAdvised}', style: const TextStyle(fontSize: 12, color: AppColors.primary700)),
                        Text('Recorded on ${dateFormat.format(v.createdAt)}', style: const TextStyle(fontSize: 10, color: AppColors.slate400)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // 7. CTA: Record Consultation Notes (if an appointment is associated)
              if (widget.appointment != null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Record Consultation & Diagnosis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      _showConsultationDialog(context, widget.appointment!, patient.id);
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showConsultationDialog(BuildContext context, AppointmentModel appt, String profileId) {
    final diagnosisController = TextEditingController(text: 'Hypertension Stage 1 - Stable');
    final notesController = TextEditingController(text: 'Patient responding well to current treatment. Maintain low sodium diet.');
    final testsController = TextEditingController(text: 'Repeat Lipid Profile & Fasting Blood Sugar in 3 months.');
    String followUp = 'After 3 months';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
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
                    const Text('Consultation Visit Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Clinical Diagnosis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                const SizedBox(height: 6),
                TextField(
                  controller: diagnosisController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Acute Bronchitis, Essential Hypertension...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Doctor Notes & Prescription Regimen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter clinical observations, medications, dosages...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Lab / Imaging Tests Advised', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                const SizedBox(height: 6),
                TextField(
                  controller: testsController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Lipid Profile, 2D Echo, CBC...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Recommended Follow-up', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: followUp,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: ['After 1 week', 'After 2 weeks', 'After 1 month', 'After 3 months', 'SOS / As needed']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) followUp = val;
                  },
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
                    onPressed: () async {
                      final repo = ref.read(doctorConsultationRepositoryProvider);
                      await repo.recordConsultation(
                        appointmentId: appt.id,
                        profileId: profileId,
                        doctorProfileId: appt.doctorProfileId,
                        diagnosis: diagnosisController.text.trim(),
                        notes: notesController.text.trim(),
                        testsAdvised: testsController.text.trim(),
                        followUpDate: followUp,
                      );

                      ref.invalidate(patientDossierProvider(profileId));
                      ref.invalidate(doctorAppointmentsProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Consultation recorded successfully!'),
                            backgroundColor: AppColors.primary700,
                          ),
                        );
                      }
                    },
                    child: const Text('Complete Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
