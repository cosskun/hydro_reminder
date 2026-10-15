import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/water_log.dart';
import '../models/alarm_setting.dart';
import '../models/beverage_type.dart';
import '../models/badge_item.dart';
import '../config/app_constants.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';
import '../services/sound_service.dart';
import '../services/widget_service.dart';
import '../services/health_service.dart';

class WaterProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<WaterLog> _logs = [];
  List<AlarmSetting> _alarms = [];
  String _gender = 'Male';
  int _age = 25;
  double _weight = 70.0;
  int _dailyGoal = 2500;
  bool _hasCompletedOnboarding = false;

  // Theme Mode State
  ThemeMode _themeMode = ThemeMode.light;

  // Sound Effects & Haptics
  bool _isSoundEffectsEnabled = true;

  // Daily Dynamic Target Boosts (Workout / Hot Weather)
  bool _isWorkoutBoostActive = false;
  bool _isHotWeatherBoostActive = false;
  String _boostDate = '';

  // Badges & Gamification State
  Map<String, String> _unlockedBadges = {}; // badgeId -> ISO string
  BadgeItem? _newlyUnlockedBadge;

  // Active Alarm State
  bool _isAlarmActive = false;
  AlarmSetting? _activeAlarm;
  DateTime? _alarmTriggeredAt;
  Timer? _vibrationTimer;

  // Global Notification Settings State
  bool _isNotificationsEnabled = true;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  // End of Day Summary Notification State
  bool _isEndOfDayEnabled = true;
  int _endOfDayHour = 22;
  int _endOfDayMinute = 0;

  // iOS Specific Siri & Back Tap Integration State
  bool _isSiriShortcutsEnabled = true;
  bool _isBackTapEnabled = true;

  // Apple Health (HealthKit) Integration State
  bool _isAppleHealthSyncEnabled = false;
  bool _isAppleHealthAutoGoalEnabled = false;
  int _todayHealthSteps = 0;

  // Ongoing Live Progress Notification State (Android & iOS)
  bool _isOngoingNotificationEnabled = false;

  // Customizable Quick Add Presets
  List<int> _quickPresets = [200, 330, 500];

  // Helper to get matching smart symbol & label for any ml value
  static Map<String, String> getPresetMeta(int amountMl) {
    if (amountMl <= 120) {
      return {'emoji': '💧', 'name': 'Yudum'};
    } else if (amountMl <= 180) {
      return {'emoji': '☕', 'name': 'Fincan'};
    } else if (amountMl <= 260) {
      return {'emoji': '🥛', 'name': 'Bardak'};
    } else if (amountMl <= 380) {
      return {'emoji': '🥤', 'name': 'Küçük Şişe'};
    } else if (amountMl <= 550) {
      return {'emoji': '🍶', 'name': 'Şişe'};
    } else if (amountMl <= 800) {
      return {'emoji': '🌊', 'name': 'Büyük Matara'};
    } else {
      return {'emoji': '🚰', 'name': 'Sürahi'};
    }
  }

  // Getters
  List<WaterLog> get logs => _logs;
  List<AlarmSetting> get alarms => _alarms;
  String get gender => _gender;
  int get age => _age;
  double get weight => _weight;
  int get baseDailyGoal => _dailyGoal;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isAlarmActive => _isAlarmActive;
  AlarmSetting? get activeAlarm => _activeAlarm;
  DateTime? get alarmTriggeredAt => _alarmTriggeredAt;

  // Check if enough time has passed (min 5 seconds) for realistic water intake
  bool canDismissAlarm() {
    if (_alarmTriggeredAt == null) return true;
    return DateTime.now().difference(_alarmTriggeredAt!).inSeconds >=
        AlarmConstants.minDrinkDurationSeconds;
  }
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isEndOfDayEnabled => _isEndOfDayEnabled;
  int get endOfDayHour => _endOfDayHour;
  int get endOfDayMinute => _endOfDayMinute;
  List<int> get quickPresets => _quickPresets;
  int get preset1 => _quickPresets.isNotEmpty ? _quickPresets[0] : 200;
  int get preset2 => _quickPresets.length > 1 ? _quickPresets[1] : 330;
  int get preset3 => _quickPresets.length > 2 ? _quickPresets[2] : 500;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;
  bool get isWorkoutBoostActive => _isWorkoutBoostActive;
  bool get isHotWeatherBoostActive => _isHotWeatherBoostActive;
  BadgeItem? get newlyUnlockedBadge => _newlyUnlockedBadge;
  bool get isSiriShortcutsEnabled => _isSiriShortcutsEnabled;
  bool get isBackTapEnabled => _isBackTapEnabled;
  bool get isAppleHealthSyncEnabled => _isAppleHealthSyncEnabled;
  bool get isAppleHealthAutoGoalEnabled => _isAppleHealthAutoGoalEnabled;
  int get todayHealthSteps => _todayHealthSteps;
  bool get isOngoingNotificationEnabled => _isOngoingNotificationEnabled;

  // Effective Daily Target (Base Goal + Daily Boosts)
  int get dailyGoal {
    _checkAndResetBoostsIfNewDay();
    int goal = _dailyGoal;
    if (_isWorkoutBoostActive) goal += 500;
    if (_isHotWeatherBoostActive) goal += 300;
    return goal;
  }

  // Today's total effective water intake
  int get todayTotal {
    final now = DateTime.now();
    return _logs
        .where((log) =>
            log.timestamp.year == now.year &&
            log.timestamp.month == now.month &&
            log.timestamp.day == now.day)
        .fold(0, (sum, log) => sum + log.amountMl);
  }

  int get todayConsumed => todayTotal;

  // Remaining water to reach effective daily goal
  int get dailyRemainingMl {
    final remaining = dailyGoal - todayTotal;
    return remaining > 0 ? remaining : 0;
  }

  // Today's hydration percentage
  double get todayPercentage {
    final currentGoal = dailyGoal;
    if (currentGoal <= 0) return 0.0;
    return (todayTotal / currentGoal).clamp(0.0, 2.0);
  }

  // Total cumulative hydration (in ml)
  int get totalCumulativeMl {
    return _logs.fold(0, (sum, log) => sum + log.amountMl);
  }

  // Calculate current consecutive streak (days goal was achieved)
  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final totalForDay = _logs
          .where((log) =>
              log.timestamp.year == checkDate.year &&
              log.timestamp.month == checkDate.month &&
              log.timestamp.day == checkDate.day)
          .fold(0, (sum, log) => sum + log.amountMl);

      if (totalForDay >= _dailyGoal) {
        streak++;
      } else {
        if (i > 0) break;
      }
    }
    return streak;
  }

  // Badges list with real-time progress calculations
  List<BadgeItem> get badges {
    final streak = currentStreak;
    final totalMl = totalCumulativeMl;
    final distinctBeverages = _logs.map((e) => e.beverageId).toSet().length;

    return BadgeItem.definitions.map((def) {
      final unlockedIso = _unlockedBadges[def.id];
      final isUnlocked = unlockedIso != null;
      final unlockedAt = isUnlocked ? DateTime.tryParse(unlockedIso) : null;

      double progress = 0.0;
      String progressLabel = '';

      switch (def.id) {
        case 'first_drop':
          progress = _logs.isNotEmpty ? 1.0 : 0.0;
          progressLabel = _logs.isNotEmpty ? '1/1 Kayıt' : '0/1 Kayıt';
          break;
        case 'streak_3':
          progress = (streak / 3.0).clamp(0.0, 1.0);
          progressLabel = '$streak/3 Gün';
          break;
        case 'streak_7':
          progress = (streak / 7.0).clamp(0.0, 1.0);
          progressLabel = '$streak/7 Gün';
          break;
        case 'streak_30':
          progress = (streak / 30.0).clamp(0.0, 1.0);
          progressLabel = '$streak/30 Gün';
          break;
        case 'early_bird':
          final hasEarly = _logs.any((l) => l.timestamp.hour < 8);
          progress = hasEarly ? 1.0 : 0.0;
          progressLabel = hasEarly ? 'Tamamlandı' : '08:00 öncesi';
          break;
        case 'night_shield':
          final hasNight = _logs.any((l) => l.timestamp.hour >= 20);
          progress = hasNight ? 1.0 : 0.0;
          progressLabel = hasNight ? 'Tamamlandı' : '20:00 sonrası';
          break;
        case 'ocean_50l':
          progress = (totalMl / 50000.0).clamp(0.0, 1.0);
          progressLabel = '${(totalMl / 1000.0).toStringAsFixed(1)} / 50 L';
          break;
        case 'ocean_100l':
          progress = (totalMl / 100000.0).clamp(0.0, 1.0);
          progressLabel = '${(totalMl / 1000.0).toStringAsFixed(1)} / 100 L';
          break;
        case 'beverage_guru':
          progress = (distinctBeverages / 3.0).clamp(0.0, 1.0);
          progressLabel = '$distinctBeverages/3 İçecek';
          break;
      }

      return def.copyWith(
        isUnlocked: isUnlocked || progress >= 1.0,
        unlockedAt: unlockedAt,
        currentProgress: isUnlocked ? 1.0 : progress,
        progressLabel: progressLabel,
      );
    }).toList();
  }

  // Initialize Provider
  Future<void> init() async {
    await _storageService.init();
    _hasCompletedOnboarding = await _storageService.hasCompletedOnboarding();
    
    final profile = await _storageService.getProfile();
    _gender = profile['gender'] as String;
    _age = profile['age'] as int;
    _weight = profile['weight'] as double;
    _dailyGoal = profile['dailyGoal'] as int;

    _logs = await _storageService.getWaterLogs();
    _alarms = await _storageService.getAlarms();

    final notifSettings = await _storageService.getNotificationSettings();
    _isNotificationsEnabled = notifSettings['isEnabled']!;
    _isSoundEnabled = notifSettings['sound']!;
    _isVibrationEnabled = notifSettings['vibration']!;

    final endOfDaySettings = await _storageService.getEndOfDaySettings();
    _isEndOfDayEnabled = endOfDaySettings['isEnabled'] as bool;
    _endOfDayHour = endOfDaySettings['hour'] as int;
    _endOfDayMinute = endOfDaySettings['minute'] as int;

    _quickPresets = await _storageService.getQuickPresets();

    // Theme Mode
    final savedTheme = await _storageService.getThemeMode();
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    // Sound Effects
    _isSoundEffectsEnabled = await _storageService.getSoundEffectsEnabled();

    // Daily Boosts
    final boosts = await _storageService.getDailyBoosts();
    _boostDate = boosts['date'] as String;
    _isWorkoutBoostActive = boosts['isWorkout'] as bool;
    _isHotWeatherBoostActive = boosts['isHotWeather'] as bool;
    _checkAndResetBoostsIfNewDay();

    // Badges
    _unlockedBadges = await _storageService.getUnlockedBadges();
    await _checkAndUnlockBadges(suppressPopup: true);

    // iOS Shortcuts
    final iosShortcuts = await _storageService.getIosShortcutsSettings();
    _isSiriShortcutsEnabled = iosShortcuts['isSiriEnabled'] ?? true;
    _isBackTapEnabled = iosShortcuts['isBackTapEnabled'] ?? true;

    // Apple Health (HealthKit)
    final healthSettings = await _storageService.getAppleHealthSettings();
    _isAppleHealthSyncEnabled = healthSettings['isEnabled'] ?? false;
    _isAppleHealthAutoGoalEnabled = healthSettings['isAutoGoalEnabled'] ?? false;
    if (_isAppleHealthSyncEnabled) {
      try {
        _todayHealthSteps = await HealthService().getTodaySteps();
      } catch (_) {}
    }

    // Ongoing Live Progress Notification
    _isOngoingNotificationEnabled = await _storageService.getOngoingNotificationSetting();

    await _syncWidgets();
    await _syncEndOfDaySummary();
    await _syncOngoingNotification();
    notifyListeners();
  }

  // Update iOS Siri & Back Tap Integration Settings
  Future<void> updateIosShortcutsSettings({
    bool? isSiriEnabled,
    bool? isBackTapEnabled,
  }) async {
    if (isSiriEnabled != null) _isSiriShortcutsEnabled = isSiriEnabled;
    if (isBackTapEnabled != null) _isBackTapEnabled = isBackTapEnabled;
    notifyListeners();

    await _storageService.saveIosShortcutsSettings(
      isSiriEnabled: _isSiriShortcutsEnabled,
      isBackTapEnabled: _isBackTapEnabled,
    );
  }

  // Update Apple Health (HealthKit) Settings
  Future<bool> updateAppleHealthSettings({
    bool? isEnabled,
    bool? isAutoGoalEnabled,
  }) async {
    if (isEnabled != null) {
      if (isEnabled) {
        final granted = await HealthService().requestAuthorization();
        if (!granted) {
          _isAppleHealthSyncEnabled = false;
          notifyListeners();
          return false;
        }
      }
      _isAppleHealthSyncEnabled = isEnabled;
    }
    if (isAutoGoalEnabled != null) {
      _isAppleHealthAutoGoalEnabled = isAutoGoalEnabled;
    }
    if (_isAppleHealthSyncEnabled) {
      try {
        _todayHealthSteps = await HealthService().getTodaySteps();
      } catch (_) {}
    }
    notifyListeners();

    await _storageService.saveAppleHealthSettings(
      isEnabled: _isAppleHealthSyncEnabled,
      isAutoGoalEnabled: _isAppleHealthAutoGoalEnabled,
    );
    return true;
  }

  // Sync today's water logs to Apple Health
  Future<int> syncTodayLogsToAppleHealth() async {
    if (!_isAppleHealthSyncEnabled) return 0;
    int count = 0;
    final now = DateTime.now();
    final todayLogs = _logs.where((l) =>
      l.timestamp.year == now.year &&
      l.timestamp.month == now.month &&
      l.timestamp.day == now.day
    );
    for (final log in todayLogs) {
      final success = await HealthService().writeWaterLog(
        amountMl: log.amountMl,
        timestamp: log.timestamp,
      );
      if (success) count++;
    }
    return count;
  }

  // Refresh step count from Apple Health
  Future<void> refreshHealthSteps() async {
    if (_isAppleHealthSyncEnabled) {
      try {
        _todayHealthSteps = await HealthService().getTodaySteps();
        notifyListeners();
      } catch (_) {}
    }
  }

  // Update Ongoing Live Progress Notification Setting
  Future<void> updateOngoingNotificationSetting(bool isEnabled) async {
    _isOngoingNotificationEnabled = isEnabled;
    notifyListeners();
    await _storageService.saveOngoingNotificationSetting(isEnabled);
    await _syncOngoingNotification();
  }

  // Sync Live Ongoing Notification in Notification Drawer
  Future<void> _syncOngoingNotification() async {
    try {
      final percentInt = (todayPercentage * 100).round();
      await AlarmService().updateOngoingProgressNotification(
        isEnabled: _isOngoingNotificationEnabled && _isNotificationsEnabled,
        todayConsumed: todayConsumed,
        dailyGoal: dailyGoal,
        percentage: percentInt,
        preset1: preset1,
        preset2: preset2,
        preset3: preset3,
      );
    } catch (_) {}
  }

  void _checkAndResetBoostsIfNewDay() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    if (_boostDate != todayStr) {
      _boostDate = todayStr;
      _isWorkoutBoostActive = false;
      _isHotWeatherBoostActive = false;
      _storageService.saveDailyBoosts(
        date: _boostDate,
        isWorkout: false,
        isHotWeather: false,
      );
    }
  }

  // Toggle Workout Boost (+500 ml)
  Future<void> toggleWorkoutBoost() async {
    _isWorkoutBoostActive = !_isWorkoutBoostActive;
    notifyListeners();
    if (_isSoundEffectsEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
    await _storageService.saveDailyBoosts(
      date: _boostDate,
      isWorkout: _isWorkoutBoostActive,
      isHotWeather: _isHotWeatherBoostActive,
    );
    try {
      await _syncWidgets();
      await _syncEndOfDaySummary();
      await _syncOngoingNotification();
    } catch (_) {}
  }

  // Toggle Hot Weather Boost (+300 ml)
  Future<void> toggleHotWeatherBoost() async {
    _isHotWeatherBoostActive = !_isHotWeatherBoostActive;
    notifyListeners();
    if (_isSoundEffectsEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
    await _storageService.saveDailyBoosts(
      date: _boostDate,
      isWorkout: _isWorkoutBoostActive,
      isHotWeather: _isHotWeatherBoostActive,
    );
    try {
      await _syncWidgets();
      await _syncEndOfDaySummary();
      await _syncOngoingNotification();
    } catch (_) {}
  }

  // Update Theme Mode (Light / Dark)
  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _storageService.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }

  // Update Sound Effects Setting
  Future<void> updateSoundEffectsEnabled(bool enabled) async {
    _isSoundEffectsEnabled = enabled;
    notifyListeners();
    await _storageService.saveSoundEffectsEnabled(enabled);
  }

  // Clear newly unlocked badge after celebration dialog
  void clearNewlyUnlockedBadge() {
    _newlyUnlockedBadge = null;
    notifyListeners();
  }

  // Check and unlock new badges
  Future<void> _checkAndUnlockBadges({bool suppressPopup = false}) async {
    final streak = currentStreak;
    final totalMl = totalCumulativeMl;
    final distinctBeverages = _logs.map((e) => e.beverageId).toSet().length;
    final now = DateTime.now();

    for (final def in BadgeItem.definitions) {
      if (_unlockedBadges.containsKey(def.id)) continue;

      bool shouldUnlock = false;

      switch (def.id) {
        case 'first_drop':
          shouldUnlock = _logs.isNotEmpty;
          break;
        case 'streak_3':
          shouldUnlock = streak >= 3;
          break;
        case 'streak_7':
          shouldUnlock = streak >= 7;
          break;
        case 'streak_30':
          shouldUnlock = streak >= 30;
          break;
        case 'early_bird':
          shouldUnlock = _logs.any((l) => l.timestamp.hour < 8);
          break;
        case 'night_shield':
          shouldUnlock = _logs.any((l) => l.timestamp.hour >= 20);
          break;
        case 'ocean_50l':
          shouldUnlock = totalMl >= 50000;
          break;
        case 'ocean_100l':
          shouldUnlock = totalMl >= 100000;
          break;
        case 'beverage_guru':
          shouldUnlock = distinctBeverages >= 3;
          break;
      }

      if (shouldUnlock) {
        _unlockedBadges[def.id] = now.toIso8601String();
        await _storageService.saveUnlockedBadges(_unlockedBadges);
        if (!suppressPopup) {
          _newlyUnlockedBadge = def;
          if (_isSoundEffectsEnabled) {
            SoundService().playBadgeCelebrationSound();
            try {
              HapticFeedback.heavyImpact();
            } catch (_) {}
          }
        }
      }
    }
  }

  // Sync data with home screen and lock screen widgets
  Future<void> _syncWidgets() async {
    try {
      final percentInt = (todayPercentage * 100).round();
      await WidgetService().updateWidgets(
        todayConsumed: todayConsumed,
        dailyGoal: dailyGoal,
        dailyRemaining: dailyRemainingMl,
        percentage: percentInt,
        preset1: preset1,
        preset2: preset2,
        preset3: preset3,
      );
    } catch (_) {}
  }

  // Calculate customized daily water target (EFSA & WHO standards)
  int calculateDailyGoal({
    required String gender,
    required int age,
    required double weight,
  }) {
    // Baseline multiplier per kg:
    // Men: 35 ml/kg, Women: 31 ml/kg, Other: 33 ml/kg
    double multiplier = 35.0;
    if (gender == 'Kadın') {
      multiplier = 31.0;
    } else if (gender == 'Diğer') {
      multiplier = 33.0;
    }

    // Age factor
    if (age < 18) {
      multiplier += 4.0; // Adolescents have higher relative water turnover
    } else if (age >= 65) {
      multiplier -= 3.0; // Senior baseline
    }

    double calculated = weight * multiplier;

    // Round to nearest 50 ml for a clean, realistic target
    return ((calculated / 50.0).round() * 50).clamp(1000, 5000);
  }

  // Save profile & update target
  Future<void> updateProfile({
    required String gender,
    required int age,
    required double weight,
  }) async {
    _gender = gender;
    _age = age;
    _weight = weight;
    _dailyGoal = calculateDailyGoal(gender: gender, age: age, weight: weight);
    _hasCompletedOnboarding = true;
    notifyListeners();

    await _storageService.saveProfile(
      gender: _gender,
      age: _age,
      weight: _weight,
      dailyGoal: _dailyGoal,
    );

    try {
      await _syncEndOfDaySummary();
      await _syncWidgets();
    } catch (_) {}
  }

  // Update user-customized daily water target directly
  Future<void> updateDailyGoal(int newGoalMl) async {
    _dailyGoal = newGoalMl.clamp(500, 10000);
    notifyListeners();
    await _storageService.saveDailyGoal(_dailyGoal);
    try {
      await _syncEndOfDaySummary();
      await _syncWidgets();
      await _syncOngoingNotification();
    } catch (_) {}
  }

  // Get logs for a specific day
  List<WaterLog> getLogsForDay(DateTime date) {
    return _logs
        .where((log) =>
            log.timestamp.year == date.year &&
            log.timestamp.month == date.month &&
            log.timestamp.day == date.day)
        .toList();
  }

  // Add water intake log with optional beverage type
  Future<void> addWater(int rawAmountMl, {String beverageId = 'water'}) async {
    final beverage = BeverageType.fromId(beverageId);
    final effectiveMl = (rawAmountMl * beverage.hydrationFactor).round();

    final newLog = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      amountMl: effectiveMl,
      rawAmountMl: rawAmountMl,
      beverageId: beverageId,
    );
    _logs.add(newLog);
    notifyListeners();

    if (_isSoundEffectsEnabled) {
      try {
        HapticFeedback.lightImpact();
        SoundService().playWaterSipSound();
      } catch (_) {}
    }

    try {
      await _storageService.saveWaterLogs(_logs);
      await _checkAndUnlockBadges();
      await _syncEndOfDaySummary();
      await _syncWidgets();
      await _syncOngoingNotification();
      if (_isAppleHealthSyncEnabled) {
        unawaited(HealthService().writeWaterLog(
          amountMl: effectiveMl,
          timestamp: newLog.timestamp,
        ));
      }
    } catch (e) {
      debugPrint('Error syncing water log: $e');
    }
  }

  // Delete water log
  Future<void> deleteLog(String id) async {
    _logs.removeWhere((log) => log.id == id);
    notifyListeners();
    try {
      await _storageService.saveWaterLogs(_logs);
      await _syncEndOfDaySummary();
      await _syncWidgets();
      await _syncOngoingNotification();
    } catch (_) {}
  }

  // Sync End of Day notification with latest values
  Future<void> _syncEndOfDaySummary() async {
    if (_isNotificationsEnabled && _isEndOfDayEnabled) {
      try {
        await AlarmService().scheduleEndOfDayNotification(
          isEnabled: _isEndOfDayEnabled,
          hour: _endOfDayHour,
          minute: _endOfDayMinute,
          remainingMl: dailyRemainingMl,
          consumedMl: todayConsumed,
          dailyGoalMl: dailyGoal,
        );
      } catch (_) {}
    }
  }

  // Send Sleep Hygiene Tip Notification directly with live calculated values
  Future<void> sendSleepTipNotification() async {
    await AlarmService().sendSleepTipNotification(
      consumedMl: todayConsumed,
      remainingMl: dailyRemainingMl,
      dailyGoalMl: dailyGoal,
    );
  }

  // Global Notification Settings
  Future<void> updateNotificationSettings({
    required bool isEnabled,
    required bool sound,
    required bool vibration,
  }) async {
    _isNotificationsEnabled = isEnabled;
    _isSoundEnabled = sound;
    _isVibrationEnabled = vibration;
    notifyListeners();

    await _storageService.saveNotificationSettings(
      isEnabled: isEnabled,
      sound: sound,
      vibration: vibration,
    );

    try {
      if (!isEnabled) {
        await AlarmService().cancelAllNotifications();
      } else {
        await AlarmService().rescheduleAllAlarms(_alarms);
        await _syncEndOfDaySummary();
        await _syncOngoingNotification();
      }
    } catch (_) {}
  }

  // End of Day notification settings
  Future<void> updateEndOfDaySettings({
    required bool isEnabled,
    required int hour,
    required int minute,
  }) async {
    _isEndOfDayEnabled = isEnabled;
    _endOfDayHour = hour;
    _endOfDayMinute = minute;
    notifyListeners();

    await _storageService.saveEndOfDaySettings(
      isEnabled: isEnabled,
      hour: hour,
      minute: minute,
    );

    try {
      await _syncEndOfDaySummary();
    } catch (_) {}
  }

  // Update quick preset amounts list
  Future<void> updateQuickPresetsList(List<int> presets) async {
    _quickPresets = List<int>.from(presets);
    notifyListeners();
    try {
      await _storageService.saveQuickPresets(presets);
      await _syncWidgets();
      await _syncOngoingNotification();
    } catch (_) {}
  }

  // Add a new custom quick preset amount
  Future<void> addQuickPreset(int amount) async {
    if (!_quickPresets.contains(amount)) {
      _quickPresets.add(amount);
      _quickPresets.sort();
      notifyListeners();
      try {
        await _storageService.saveQuickPresets(_quickPresets);
        await _syncWidgets();
      } catch (_) {}
    }
  }

  // Remove a custom quick preset amount
  Future<void> removeQuickPreset(int amount) async {
    if (_quickPresets.length > 1) {
      _quickPresets.remove(amount);
      notifyListeners();
      try {
        await _storageService.saveQuickPresets(_quickPresets);
        await _syncWidgets();
      } catch (_) {}
    }
  }

  // Update 3 main presets
  Future<void> updatePresets(int p1, int p2, int p3) async {
    _quickPresets = [p1, p2, p3];
    notifyListeners();
    try {
      await _storageService.savePresets(p1, p2, p3);
      await _syncWidgets();
      await _syncOngoingNotification();
    } catch (_) {}
  }

  // Add new alarm
  Future<void> addAlarm({
    required int hour,
    required int minute,
    required String label,
    String soundName = 'Su Damlası 💧',
    String soundPath = 'assets/sounds/sound_water_drop.wav',
    bool isCustomSound = false,
  }) async {
    final id = (DateTime.now().millisecondsSinceEpoch % 100000).toString();
    final alarm = AlarmSetting(
      id: id,
      hour: hour,
      minute: minute,
      label: label,
      isEnabled: true,
      soundName: soundName,
      soundPath: soundPath,
      isCustomSound: isCustomSound,
    );

    _alarms.add(alarm);
    await _storageService.saveAlarms(_alarms);
    if (_isNotificationsEnabled) {
      await AlarmService().scheduleAlarm(alarm);
    }
    notifyListeners();
  }

  // Edit alarm
  Future<void> editAlarm({
    required String id,
    required int hour,
    required int minute,
    required String label,
    required String soundName,
    required String soundPath,
    required bool isCustomSound,
  }) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = _alarms[index].copyWith(
        hour: hour,
        minute: minute,
        label: label,
        soundName: soundName,
        soundPath: soundPath,
        isCustomSound: isCustomSound,
      );
      _alarms[index] = updated;
      await _storageService.saveAlarms(_alarms);
      if (_isNotificationsEnabled && updated.isEnabled) {
        await AlarmService().scheduleAlarm(updated);
      }
      notifyListeners();
    }
  }

  // Toggle alarm state
  Future<void> toggleAlarm(String id, bool isEnabled) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = _alarms[index].copyWith(isEnabled: isEnabled);
      _alarms[index] = updated;
      await _storageService.saveAlarms(_alarms);

      if (_isNotificationsEnabled) {
        if (isEnabled) {
          await AlarmService().scheduleAlarm(updated);
        } else {
          await AlarmService().cancelAlarm(id);
        }
      }
      notifyListeners();
    }
  }

  // Delete alarm
  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((a) => a.id == id);
    await _storageService.saveAlarms(_alarms);
    await AlarmService().cancelAlarm(id);
    notifyListeners();
  }

  // Trigger full-screen unclosable alarm UI
  void triggerAlarm(AlarmSetting alarm) {
    _isAlarmActive = true;
    _activeAlarm = alarm;
    _alarmTriggeredAt = DateTime.now();

    if (_isSoundEnabled) {
      SoundService().playAlarmSound(
        soundPath: alarm.soundPath,
        isCustomSound: alarm.isCustomSound,
        loop: true,
      );
    }

    if (_isVibrationEnabled) {
      _startVibrationLoop();
    }

    notifyListeners();
  }

  // Dismiss alarm ONLY when user confirmed they drank water
  void dismissAlarm(int amountMl) {
    _isAlarmActive = false;
    _activeAlarm = null;
    _alarmTriggeredAt = null;

    SoundService().stopSound();
    _stopVibrationLoop();

    addWater(amountMl);
  }

  void _startVibrationLoop() {
    _vibrationTimer?.cancel();
    _pulseAlarmVibration();
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (_isAlarmActive && _isVibrationEnabled) {
        _pulseAlarmVibration();
      } else {
        timer.cancel();
      }
    });
  }

  void _pulseAlarmVibration() {
    try {
      // Vibrate motor + Taptic Engine heavy impact for strong physical feedback even on silent
      HapticFeedback.vibrate();
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_isAlarmActive && _isVibrationEnabled) {
          HapticFeedback.heavyImpact();
        }
      });
    } catch (_) {}
  }

  void _stopVibrationLoop() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  // Reset all application data
  Future<void> resetAllData() async {
    _logs.clear();
    _alarms.clear();
    _quickPresets = [200, 330, 500];
    _gender = 'Male';
    _age = 25;
    _weight = 70.0;
    _dailyGoal = 2500;
    _hasCompletedOnboarding = false;
    _isNotificationsEnabled = true;
    _isSoundEnabled = true;
    _isVibrationEnabled = true;
    _isEndOfDayEnabled = true;
    _endOfDayHour = 22;
    _endOfDayMinute = 0;
    _themeMode = ThemeMode.light;
    _isSoundEffectsEnabled = true;
    _isWorkoutBoostActive = false;
    _isHotWeatherBoostActive = false;
    _alarmTriggeredAt = null;
    _unlockedBadges.clear();
    _newlyUnlockedBadge = null;

    await AlarmService().cancelAllNotifications();
    await _storageService.clearAll();
    await _syncWidgets();
    notifyListeners();
  }
}
