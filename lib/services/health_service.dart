import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  bool _isConfigured = false;

  static final List<HealthDataType> _requestedTypes = [
    HealthDataType.WATER,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Check if HealthKit / Health Connect is supported on current platform
  bool get isSupported => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Initializes health plugin
  Future<void> init() async {
    if (!isSupported) return;
    if (_isConfigured) return;

    try {
      await _health.configure();
      _isConfigured = true;
    } catch (e) {
      debugPrint('HealthService init error: $e');
    }
  }

  /// Request HealthKit / Health Connect authorization
  Future<bool> requestAuthorization() async {
    if (!isSupported) return false;
    try {
      await init();
      final authorized = await _health.requestAuthorization(
        _requestedTypes,
        permissions: _permissions,
      );
      return authorized;
    } catch (e) {
      debugPrint('HealthService requestAuthorization error: $e');
      return false;
    }
  }

  /// Check if permissions are already granted
  Future<bool?> hasPermissions() async {
    if (!isSupported) return false;
    try {
      await init();
      return await _health.hasPermissions(_requestedTypes, permissions: _permissions);
    } catch (e) {
      debugPrint('HealthService hasPermissions error: $e');
      return false;
    }
  }

  /// Write a water log entry (in milliliters) to Apple Health / Health Connect
  Future<bool> writeWaterLog({
    required int amountMl,
    required DateTime timestamp,
  }) async {
    if (!isSupported) return false;
    try {
      await init();
      // HealthDataType.WATER is measured in Liters in HealthKit
      final liters = amountMl / 1000.0;
      final success = await _health.writeHealthData(
        value: liters,
        unit: HealthDataUnit.LITER,
        type: HealthDataType.WATER,
        startTime: timestamp,
        endTime: timestamp,
        recordingMethod: RecordingMethod.manual,
      );
      debugPrint('HealthService: Synced $amountMl ml ($liters L) to Apple Health: $success');
      return success;
    } catch (e) {
      debugPrint('HealthService writeWaterLog error: $e');
      return false;
    }
  }

  /// Get today's total steps from Apple Health
  Future<int> getTodaySteps() async {
    if (!isSupported) return 0;
    try {
      await init();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('HealthService getTodaySteps error: $e');
      return 0;
    }
  }
}
