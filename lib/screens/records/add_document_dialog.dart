import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';

/// Modal bottom sheet & dialog for adding a patient medical document.
/// Verification status is automatically set to 'Not Verified' since users
/// do not have authority to verify their own clinical records.
class AddMedicalDocumentSheet extends ConsumerStatefulWidget {
  const AddMedicalDocumentSheet({super.key});

  @override
  ConsumerState<AddMedicalDocumentSheet> createState() => _AddMedicalDocumentSheetState();
}

class _AddMedicalDocumentSheetState extends ConsumerState<AddMedicalDocumentSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customFileController = TextEditingController();

  String? _selectedFileName;
  int? _selectedFileSize;
  bool _showCustomFileInput = false;
  String _selectedCategory = 'LAB_REPORT';
  bool _isSaving = false;

  final List<String> _categories = [
    'LAB_REPORT',
    'PRESCRIPTION',
    'DISCHARGE_SUMMARY',
    'IMAGING',
    'DOCUMENT',
  ];

  final List<Map<String, dynamic>> _presetPdfs = [
    {
      'name': 'CBC_Blood_Investigation.pdf',
      'title': 'Complete Blood Count (CBC) Report',
      'category': 'LAB_REPORT',
      'icon': Icons.bloodtype_rounded,
    },
    {
      'name': 'Cardiology_Prescription.pdf',
      'title': 'Cardiology Prescription & Regimen',
      'category': 'PRESCRIPTION',
      'icon': Icons.medication_rounded,
    },
    {
      'name': 'Chest_XRay_Imaging.pdf',
      'title': 'Chest X-Ray Diagnostic Scan',
      'category': 'IMAGING',
      'icon': Icons.biotech_rounded,
    },
    {
      'name': 'Hospital_Discharge_Summary.pdf',
      'title': 'Clinical Discharge Summary',
      'category': 'DISCHARGE_SUMMARY',
      'icon': Icons.local_hospital_rounded,
    },
    {
      'name': 'Blood_Sugar_Fasting_Report.pdf',
      'title': 'Fasting Blood Glucose Lab Panel',
      'category': 'LAB_REPORT',
      'icon': Icons.water_drop_rounded,
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customFileController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFromDevice() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final fileSize = file.lengthSync() ?? await file.length();
        setState(() {
          _selectedFileName = file.name;
          _selectedFileSize = fileSize;
          if (_titleController.text.trim().isEmpty) {
            final cleanName = file.name.replaceAll('.pdf', '').replaceAll('_', ' ');
            _titleController.text = cleanName;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker notice: $e. You can also select a preset below or type a file name.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _selectedFileName = preset['name'] as String;
      _selectedFileSize = 1024 * 380; // ~380 KB
      _selectedCategory = preset['category'] as String;
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = preset['title'] as String;
      }
      _showCustomFileInput = false;
    });
  }

  void _applyCustomFileName() {
    final name = _customFileController.text.trim();
    if (name.isEmpty) return;

    final fileName = name.toLowerCase().endsWith('.pdf') ? name : '$name.pdf';
    setState(() {
      _selectedFileName = fileName;
      _selectedFileSize = 1024 * 250;
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = name.replaceAll('.pdf', '').replaceAll('_', ' ');
      }
      _showCustomFileInput = false;
    });
  }

  Future<void> _saveDocument() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a document title')),
      );
      return;
    }

    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or specify a PDF document file')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final activeProfileId = ref.read(activeProfileIdProvider);
      final desc = _descriptionController.text.trim();

      // User does NOT have authority to choose verification status;
      // It is automatically saved as 'Not Verified' pending doctor/admin review.
      await ref.read(healthRecordRepositoryProvider).addRecord(
            patientId: activeProfileId,
            title: title,
            description: desc.isNotEmpty ? desc : null,
            fileName: _selectedFileName!,
            verificationStatus: 'Not Verified',
            category: _selectedCategory,
            issuer: 'Self Uploaded',
          );

      // Invalidate provider so recent document appears first immediately
      ref.invalidate(healthRecordsListProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Document "$title" added successfully (Status: Not Verified)!')),
              ],
            ),
            backgroundColor: AppColors.primary700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.note_add_rounded, color: AppColors.accent600, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Medical Document',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                          ),
                        ),
                        Text(
                          'Upload medical records, prescriptions & lab reports',
                          style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.slate400, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.slate200),

              // 1. ATTACH PDF FILE SECTION
              const Text(
                'Attach PDF Document *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700),
              ),
              const SizedBox(height: 6),

              if (_selectedFileName != null)
                // Selected PDF Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName!,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.slate900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.successGreen),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedFileSize != null
                                      ? '${(_selectedFileSize! / 1024).toStringAsFixed(1)} KB • PDF Document Ready'
                                      : 'PDF Document Ready',
                                  style: const TextStyle(fontSize: 10, color: AppColors.slate600, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedFileName = null),
                        child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                      ),
                    ],
                  ),
                )
              else ...[
                // In-Form File Selector (Direct & Safe, No Win32 z-order popup issues)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                side: const BorderSide(color: AppColors.accent600),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                foregroundColor: AppColors.accent600,
                              ),
                              onPressed: _pickPdfFromDevice,
                              icon: const Icon(Icons.file_open_rounded, size: 16),
                              label: const Text('Browse Device Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                side: BorderSide(color: _showCustomFileInput ? AppColors.primary600 : AppColors.slate300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                foregroundColor: _showCustomFileInput ? AppColors.primary700 : AppColors.slate700,
                              ),
                              onPressed: () => setState(() => _showCustomFileInput = !_showCustomFileInput),
                              icon: const Icon(Icons.edit_note_rounded, size: 16),
                              label: const Text('Enter Filename', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),

                      if (_showCustomFileInput) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customFileController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'e.g. prescription_nov2026.pdf',
                                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.slate400),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: _applyCustomFileName,
                              child: const Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Text(
                        'Or choose a preset report with 1-tap:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.slate600),
                      ),
                      const SizedBox(height: 6),

                      // One-tap PDF presets
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _presetPdfs.map((preset) {
                          return InkWell(
                            onTap: () => _selectPreset(preset),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.slate200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(preset['icon'] as IconData, size: 13, color: AppColors.accent600),
                                  const SizedBox(width: 4),
                                  Text(
                                    preset['name'] as String,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate800),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 2. DOCUMENT TITLE
              const Text(
                'Document Title *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 13, color: AppColors.slate900),
                decoration: InputDecoration(
                  hintText: 'e.g. Complete Blood Count (CBC) Report',
                  hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13),
                  prefixIcon: const Icon(Icons.title_rounded, color: AppColors.slate400, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. DESCRIPTION (OPTIONAL)
              const Text(
                'Description (Optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, color: AppColors.slate900),
                decoration: InputDecoration(
                  hintText: 'e.g. Routine blood investigation report advised by Dr. Deshmukh',
                  hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. CATEGORY DROPDOWN
              const Text(
                'Document Category',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                style: const TextStyle(fontSize: 13, color: AppColors.slate900),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // 5. READ-ONLY VERIFICATION STATUS NOTICE (No user selection authority)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pending_actions_rounded, size: 18, color: Color(0xFFB45309)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Label: Not Verified',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                          Text(
                            'Patient uploads are marked "Not Verified" by default until reviewed and verified by a licensed doctor or clinic.',
                            style: TextStyle(fontSize: 10, color: Color(0xFF92400E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 6. ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: AppColors.slate300),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.slate600, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : _saveDocument,
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Save Document',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible Dialog alias
class AddMedicalDocumentDialog extends StatelessWidget {
  const AddMedicalDocumentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: const AddMedicalDocumentSheet(),
    );
  }
}
