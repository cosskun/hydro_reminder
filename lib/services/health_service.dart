import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  static const MethodChannel _platformChannel =
      MethodChannel('com.antigravity.hydroReminder/alarm_haptics');

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

  /// Opens native Health Connect permission screen on Android
  Future<bool> openHealthConnectSettings() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final opened = await _platformChannel
          .invokeMethod<bool>('openHealthConnectSettings');
      return opened ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request HealthKit / Health Connect authorization
  Future<bool> requestAuthorization() async {
    if (!isSupported) return false;
    try {
      await init();

      if (Platform.isAndroid) {
        final sdkStatus = await _health.getHealthConnectSdkStatus();
        if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
          await _health.installHealthConnect();
          return false;
        }
      }

      final startTime = DateTime.now();
      final authorized = await _health.requestAuthorization(
        _requestedTypes,
        permissions: _permissions,
      );
      final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;

      if (authorized) {
        return true;
      }

      // Check if water permission was granted even if optional step/calorie permission was skipped
      final waterGranted = await hasPermissions();
      if (waterGranted == true) {
        return true;
      }

      // On Android 14+, if the permission dialog was previously dismissed twice,
      // the OS silently suppresses the dialog (< 450ms). Open Health Connect permissions directly.
      if (Platform.isAndroid && elapsedMs < 450) {
        await openHealthConnectSettings();
      }

      return false;
    } catch (e) {
      debugPrint('HealthService requestAuthorization error: $e');
      if (Platform.isAndroid) {
        await openHealthConnectSettings();
      }
      return false;
    }
  }

  /// Check if core hydration permissions are already granted
  Future<bool?> hasPermissions() async {
    if (!isSupported) return false;
    try {
      await init();
      if (Platform.isAndroid) {
        final sdkStatus = await _health.getHealthConnectSdkStatus();
        if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
          return false;
        }
      }
      return await _health.hasPermissions(
        const [HealthDataType.WATER],
        permissions: const [HealthDataAccess.READ_WRITE],
      );
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
