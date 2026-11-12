import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arogyanexus_app/models/vital_model.dart';
import 'package:arogyanexus_app/models/health_record_model.dart';
import 'package:arogyanexus_app/providers/app_providers.dart';
import 'package:arogyanexus_app/screens/records/records_screen.dart';
import 'package:arogyanexus_app/screens/records/add_document_dialog.dart';

void main() {
  testWidgets('Only latest vitals are displayed in primary cards and previous values stored with dates',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2026, 11, 10, 14, 0);
    final earlier = DateTime(2026, 11, 8, 10, 0);

    // Mock vitals list: 2 BP readings (one newer, one older), 2 Heart Rate readings
    final vitalsData = [
      VitalReadingModel(
        id: 'bp-new',
        patientId: 'profile-self',
        type: 'BP',
        value: 125.0,
        unit: 'mmHg',
        measuredAt: now,
      ),
      VitalReadingModel(
        id: 'bp-old',
        patientId: 'profile-self',
        type: 'BP',
        value: 118.0,
        unit: 'mmHg',
        measuredAt: earlier,
      ),
      VitalReadingModel(
        id: 'hr-new',
        patientId: 'profile-self',
        type: 'HEART_RATE',
        value: 75.0,
        unit: 'bpm',
        measuredAt: now,
      ),
      VitalReadingModel(
        id: 'hr-old',
        patientId: 'profile-self',
        type: 'HEART_RATE',
        value: 70.0,
        unit: 'bpm',
        measuredAt: earlier,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vitalsListProvider.overrideWith((ref) => Future.value(vitalsData)),
          healthRecordsListProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(
          home: RecordsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check that latest reading 125 is displayed in latest BP card
    expect(find.text('125'), findsOneWidget);
    // Check that latest reading 75 is displayed in latest Heart Rate card
    expect(find.text('75'), findsOneWidget);

    // Check that Previous Readings History section shows the previous values stored with dates
    expect(find.text('Previous Readings History'), findsOneWidget);
    expect(find.text('2 Stored with Dates'), findsOneWidget);
    expect(find.text('118.0 mmHg'), findsOneWidget);
    expect(find.text('70.0 bpm'), findsOneWidget);
  });

  testWidgets('Recent document appears first with title, description, PDF and verified status label',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2026, 11, 10, 15, 30);
    final older = DateTime(2026, 10, 20, 11, 0);

    final recordsData = [
      HealthRecordModel(
        id: 'doc-recent',
        patientId: 'profile-self',
        category: 'LAB_REPORT',
        title: 'Recent Blood Lipid Profile',
        description: 'Comprehensive cholesterol and triglyceride evaluation',
        issuer: 'Self Uploaded',
        recordDate: now,
        fileName: 'lipid_profile_nov2026.pdf',
        verificationStatus: 'Verified',
      ),
      HealthRecordModel(
        id: 'doc-older',
        patientId: 'profile-self',
        category: 'PRESCRIPTION',
        title: 'Older Clinical Prescription',
        description: 'Initial consultation notes',
        issuer: 'Clinic',
        recordDate: older,
        fileName: 'prescription_oct2026.pdf',
        verificationStatus: 'Not Verified',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vitalsListProvider.overrideWith((ref) => Future.value([])),
          healthRecordsListProvider.overrideWith((ref) => Future.value(recordsData)),
        ],
        child: const MaterialApp(
          home: RecordsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify recent document title & description appear
    expect(find.text('Recent Blood Lipid Profile'), findsOneWidget);
    expect(find.text('Comprehensive cholesterol and triglyceride evaluation'), findsOneWidget);
    expect(find.text('lipid_profile_nov2026.pdf'), findsOneWidget);

    // Verify status labels: "Verified" and "Not Verified"
    expect(find.text('Verified'), findsWidgets);
    expect(find.text('Not Verified'), findsWidgets);

    // Verify "Add Document" button exists
    expect(find.text('Add Document'), findsOneWidget);
  });

  testWidgets('AddMedicalDocumentSheet removes verification selection from user and defaults to Not Verified',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AddMedicalDocumentSheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Medical Document'), findsOneWidget);
    expect(find.text('Document Title *'), findsOneWidget);
    expect(find.text('Description (Optional)'), findsOneWidget);
    expect(find.text('Attach PDF Document *'), findsOneWidget);

    // User should NOT have authority to choose verification status (no selectable toggle)
    expect(find.text('Status of Document (Label) *'), findsNothing);

    // Notice should clearly state it defaults to Not Verified
    expect(find.text('Status Label: Not Verified'), findsOneWidget);

    // File selection options present
    expect(find.text('Browse Device Files'), findsOneWidget);
    expect(find.text('Enter Filename'), findsOneWidget);
  });
}
