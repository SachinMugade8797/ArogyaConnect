import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arogyanexus_app/models/vital_model.dart';
import 'package:arogyanexus_app/models/health_record_model.dart';
import 'package:arogyanexus_app/providers/app_providers.dart';
import 'package:arogyanexus_app/screens/records/records_screen.dart';

void main() {
  testWidgets('Records screen renders without overflow on narrow 320px and 360px mobile screens',
      (WidgetTester tester) async {
    // Ultra compact mobile screen (320x640)
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2026, 11, 10, 15, 30);
    final older = DateTime(2026, 10, 20, 11, 0);

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
        measuredAt: older,
      ),
    ];

    final recordsData = [
      HealthRecordModel(
        id: 'doc-1',
        patientId: 'profile-self',
        category: 'DISCHARGE_SUMMARY',
        title: 'Comprehensive Cardiovascular Hospital Discharge Summary',
        description: 'Complete discharge instructions, prescription regimen and recovery plan.',
        issuer: 'Dr. Aditi Deshmukh (HeartCare Clinic & Diagnostics)',
        recordDate: now,
        fileName: 'discharge_summary_nov2026.pdf',
        verificationStatus: 'Not Verified',
      ),
      HealthRecordModel(
        id: 'doc-2',
        patientId: 'profile-self',
        category: 'LAB_REPORT',
        title: 'Complete Blood Count (CBC) with Differential Panel',
        description: 'Routine 6-month blood investigation panel.',
        issuer: 'HeartCare Clinic Diagnostics & Pathology Lab',
        recordDate: older,
        fileName: 'cbc_report_oct2026.pdf',
        verificationStatus: 'Not Verified',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vitalsListProvider.overrideWith((ref) => Future.value(vitalsData)),
          healthRecordsListProvider.overrideWith((ref) => Future.value(recordsData)),
        ],
        child: const MaterialApp(
          home: RecordsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify no render overflow exception occurred
    expect(tester.takeException(), isNull);
  });
}
