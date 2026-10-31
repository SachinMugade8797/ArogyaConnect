import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';

class AddVitalDialog extends ConsumerStatefulWidget {
  const AddVitalDialog({super.key});

  @override
  ConsumerState<AddVitalDialog> createState() => _AddVitalDialogState();
}

class _AddVitalDialogState extends ConsumerState<AddVitalDialog> {
  String _selectedType = 'BP';
  final _valueController = TextEditingController();

  final Map<String, String> _typeUnits = {
    'BP': 'mmHg (Systolic)',
    'BLOOD_GLUCOSE': 'mg/dL (Fasting)',
    'HEART_RATE': 'bpm',
    'SPO2': '%',
    'TEMPERATURE': '°F',
    'WEIGHT': 'kg',
  };

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeId = ref.watch(activeProfileIdProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Log Health Vital', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vital Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _typeUnits.keys.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Value (${_typeUnits[_selectedType]})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'e.g. 120 or 95',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary600,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final val = double.tryParse(_valueController.text.trim());
            if (val == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid numeric value')),
              );
              return;
            }

            final scaffold = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);
            final repo = ref.read(vitalRepositoryProvider);
            await repo.addVital(
              patientId: activeId,
              type: _selectedType,
              value: val,
              unit: _typeUnits[_selectedType] ?? '',
            );

            // Invalidate to refresh UI
            ref.invalidate(vitalsListProvider);

            if (!mounted) return;
            navigator.pop();
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Vital recorded successfully!'),
                backgroundColor: AppColors.primary700,
              ),
            );
          },
          child: const Text('Save Vital'),
        ),
      ],
    );
  }
}
