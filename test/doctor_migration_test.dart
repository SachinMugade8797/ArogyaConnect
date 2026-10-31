import 'package:flutter_test/flutter_test.dart';
import 'package:arogyanexus_app/core/database/seed_doctors.dart';
import 'package:arogyanexus_app/models/doctor_model.dart';

void main() {
  group('Doctor Migration & City Search Tests', () {
    test('Verifies 201 total doctors migrated from web project', () {
      expect(rawSeedDoctors.length, equals(201));
      expect(rawSeedDoctorProfiles.length, equals(201));
      expect(rawSeedDoctorUsers.length, equals(201));
    });

    test('Verifies city counts match Maharashtra and Bengaluru web database', () {
      final cityCounts = <String, int>{};
      for (final doc in rawSeedDoctors) {
        final city = doc['city'] as String;
        cityCounts[city] = (cityCounts[city] ?? 0) + 1;
      }

      expect(cityCounts['Kolhapur'], equals(50));
      expect(cityCounts['Pune'], equals(35));
      expect(cityCounts['Mumbai'], equals(30));
      expect(cityCounts['Sangli'], equals(30));
      expect(cityCounts['Satara'], equals(25));
      expect(cityCounts['Nashik'], equals(20));
      expect(cityCounts['Solapur'], equals(10));
      expect(cityCounts['Bengaluru'], equals(1));

      final totalFromCities = cityCounts.values.fold<int>(0, (sum, c) => sum + c);
      expect(totalFromCities, equals(201));
    });

    test('Verifies DoctorModel deserializes all 201 migrated doctor records', () {
      for (final docMap in rawSeedDoctors) {
        final model = DoctorModel.fromMap(docMap);
        expect(model.id, isNotEmpty);
        expect(model.name, startsWith('Dr.'));
        expect(model.speciality, isNotEmpty);
        expect(model.city, isNotEmpty);
        expect(model.clinic, isNotEmpty);
        expect(model.consultationFee, greaterThan(0));
        expect(model.rating, greaterThanOrEqualTo(0));
        expect(model.languages, isNotEmpty);
      }
    });

    test('Verifies unique IDs for all doctors (no duplicates or data loss)', () {
      final doctorIds = rawSeedDoctors.map((d) => d['id']).toSet();
      final profileIds = rawSeedDoctorProfiles.map((p) => p['id']).toSet();
      final userIds = rawSeedDoctorUsers.map((u) => u['id']).toSet();

      expect(doctorIds.length, equals(201));
      expect(profileIds.length, equals(201));
      expect(userIds.length, equals(201));
    });
  });
}
