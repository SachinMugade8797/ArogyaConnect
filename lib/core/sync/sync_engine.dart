import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../models/sync_item_model.dart';
import '../../models/doctor_model.dart';

enum SyncStatus {
  offline,
  syncing,
  synced,
  error,
}

class SyncEngine extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  SyncStatus _status = SyncStatus.offline;
  SyncStatus get status => _status;

  String? _lastError;
  String? get lastError => _lastError;

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  SyncEngine({
    ApiClient? apiClient,
    NetworkInfo? networkInfo,
  })  : _apiClient = apiClient ?? ApiClient(),
        _networkInfo = networkInfo ?? NetworkInfo() {
    _initListener();
  }

  void _initListener() {
    _networkInfo.onConnectivityChanged.listen((hasNet) {
      if (hasNet) {
        syncAll();
      } else {
        _status = SyncStatus.offline;
        notifyListeners();
      }
    });
    refreshPendingCount();
  }

  Future<void> refreshPendingCount() async {
    final db = await _db.database;
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue WHERE status = "PENDING"');
    _pendingCount = Sqflite.firstIntValue(res) ?? 0;
    notifyListeners();
  }

  /// Trigger full bidirectional synchronization
  Future<void> syncAll() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      _status = SyncStatus.offline;
      notifyListeners();
      return;
    }

    _status = SyncStatus.syncing;
    _lastError = null;
    notifyListeners();

    try {
      // 1. PUSH: Process pending offline mutations
      await _pushPendingMutations();

      // 2. PULL: Fetch delta updates from backend
      await _pullDeltaUpdates();

      _status = SyncStatus.synced;
      _lastSyncedAt = DateTime.now();
      await _updateLastSyncTimestamp(_lastSyncedAt!);
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
    } finally {
      await refreshPendingCount();
      notifyListeners();
    }
  }

  /// Push local changes to the remote server
  Future<void> _pushPendingMutations() async {
    final db = await _db.database;
    final rows = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'created_at ASC',
    );

    final items = rows.map((r) => SyncItemModel.fromMap(r)).toList();

    for (final item in items) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        if (item.entityType == 'appointment') {
          if (item.action == 'CREATE') {
            await _apiClient.post('/appointments', data: payload);
          } else if (item.action == 'UPDATE') {
            await _apiClient.patch('/patient/appointments/${item.entityId}', data: payload);
          }
          // Mark appointment synced locally
          await db.update(
            'appointments',
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [item.entityId],
          );
        } else if (item.entityType == 'vital') {
          if (item.action == 'CREATE') {
            await _apiClient.post('/patient/records/vitals', data: payload);
          }
          await db.update(
            'vital_readings',
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [item.entityId],
          );
        }

        // Successfully synced -> delete from queue
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [item.id]);
      } catch (err) {
        // Increment retry attempt or mark failed
        await db.update(
          'sync_queue',
          {
            'attempts': item.attempts + 1,
            'last_error': err.toString(),
            'status': item.attempts >= 3 ? 'FAILED' : 'PENDING',
          },
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }
    }
  }

  /// Pull delta updates from remote server and upsert into local database
  Future<void> _pullDeltaUpdates() async {
    final db = await _db.database;

    try {
      // Fetch public doctors list to refresh directory cache
      final doctorRes = await _apiClient.get('/public/doctors');
      if (doctorRes.statusCode == 200 && doctorRes.data != null) {
        final List doctorsData = doctorRes.data is List ? doctorRes.data : doctorRes.data['doctors'] ?? [];
        for (final raw in doctorsData) {
          final doc = DoctorModel(
            id: raw['id'] ?? '',
            name: raw['name'] ?? '',
            speciality: raw['speciality'] ?? 'General',
            clinic: raw['clinic'] ?? '',
            clinicAddress: raw['clinicAddress'] ?? '',
            city: raw['city'] ?? 'Bengaluru',
            consultationFee: (raw['consultationFee'] as num?)?.toDouble() ?? 500.0,
            rating: (raw['rating'] as num?)?.toDouble() ?? 4.8,
            reviewCount: (raw['reviewCount'] as num?)?.toInt() ?? 0,
            experienceYears: (raw['experienceYears'] as num?)?.toInt(),
            languages: (raw['languages'] as List?)?.map((e) => e.toString()).toList() ?? ['English'],
            bio: raw['bio'] as String?,
            offersVideo: raw['offersVideo'] ?? true,
          );

          await db.insert(
            'doctors',
            doc.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } catch (_) {
      // Server might be in local mode or unreachable; offline cached data remains active
    }
  }

  Future<void> _updateLastSyncTimestamp(DateTime dt) async {
    final db = await _db.database;
    await db.insert(
      'sync_metadata',
      {
        'key': 'last_synced_at',
        'value': dt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
