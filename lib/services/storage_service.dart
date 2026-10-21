import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_log.dart';
import '../models/alarm_setting.dart';
import '../models/user_profile.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefsSync {
    if (_prefs == null) {
      // Lazy fallback warning/safeguard
      throw StateError(
        'StorageService._prefsSync accessed before init() was called. Ensure StorageService.init() is awaited during app launch or testing.',
      );
    }
    return _prefs!;
  }

  static const String _keyGender = 'user_gender';
  static const String _keyAge = 'user_age';
  static const String _keyWeight = 'user_weight';
  static const String _keyDailyGoal = 'user_daily_goal';
  static const String _keyWaterLogs = 'water_logs_list';
  static const String _keyAlarms = 'alarms_list';
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keyIsNotificationsEnabled = 'notifications_enabled';
  static const String _keyIsSoundEnabled = 'sound_enabled';
  static const String _keyIsVibrationEnabled = 'vibration_enabled';
  static const String _keyPreset1 = 'preset_1';
  static const String _keyPreset2 = 'preset_2';
  static const String _keyPreset3 = 'preset_3';
  static const String _keyQuickPresetsList = 'custom_quick_presets_list';
  static const String _keyIsEndOfDayEnabled = 'end_of_day_enabled';
  static const String _keyEndOfDayHour = 'end_of_day_hour';
  static const String _keyEndOfDayMinute = 'end_of_day_minute';
  static const String _keyUnlockedBadges = 'unlocked_badges_map';
  static const String _keyThemeMode = 'app_theme_mode'; // 'light' or 'dark'
  static const String _keySoundEffects = 'sound_effects_enabled';
  static const String _keyBoostDate = 'daily_boost_date';
  static const String _keyWorkoutBoost = 'is_workout_boost_active';
  static const String _keyHotWeatherBoost = 'is_hot_weather_boost_active';
  static const String _keyIsSiriShortcutsEnabled = 'ios_siri_shortcuts_enabled';
  static const String _keyIsBackTapEnabled = 'ios_back_tap_enabled';
  static const String _keyAppleHealthEnabled = 'apple_health_sync_enabled';
  static const String _keyAppleHealthAutoGoal = 'apple_health_auto_goal_enabled';
  static const String _keyIsOngoingNotificationEnabled = 'ongoing_notification_enabled';
  static const String _keyStreakShields = 'streak_shields_count';
  static const String _keyFrozenDates = 'streak_frozen_dates_list';
  static const String _keyLastShieldRefill = 'last_shield_refill_date';
  static const String _keyLastGoalCelebratedDate = 'last_goal_celebrated_date';
  static const String _keyIsSmartPacingEnabled = 'smart_pacing_enabled';
  static const String _keyMascotType = 'custom_mascot_type';
  static const String _keyWidgetTheme = 'custom_widget_theme';
  static const String _keyAppLanguage = 'app_language';

  // Save profile information
  Future<void> saveProfile({
    required String gender,
    required int age,
    required double weight,
    required int dailyGoal,
  }) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyGender, gender);
    await prefs.setInt(_keyAge, age);
    await prefs.setDouble(_keyWeight, weight);
    await prefs.setInt(_keyDailyGoal, dailyGoal);
    await prefs.setBool(_keyHasCompletedOnboarding, true);
  }

  // Save custom daily goal only
  Future<void> saveDailyGoal(int dailyGoal) async {
    final prefs = _prefsSync;
    await prefs.setInt(_keyDailyGoal, dailyGoal);
  }

  // Check onboarding completion
  Future<bool> hasCompletedOnboarding() async {
    final prefs = _prefsSync;
    return prefs.getBool(_keyHasCompletedOnboarding) ?? false;
  }

  // Get profile data (legacy Map support)
  Future<Map<String, dynamic>> getProfile() async {
    final prefs = _prefsSync;
    final rawGender = prefs.getString(_keyGender) ?? 'Erkek';
    final normalizedGender = rawGender == 'Male'
        ? 'Erkek'
        : (rawGender == 'Female' ? 'Kadın' : rawGender);
    return {
      'gender': normalizedGender,
      'age': prefs.getInt(_keyAge) ?? 25,
      'weight': prefs.getDouble(_keyWeight) ?? 70.0,
      'dailyGoal': prefs.getInt(_keyDailyGoal) ?? 2500,
    };
  }

  // Get typed UserProfile object
  Future<UserProfile> getUserProfile() async {
    final prefs = _prefsSync;
    return UserProfile(
      gender: prefs.getString(_keyGender) ?? 'Erkek',
      age: prefs.getInt(_keyAge) ?? 25,
      weight: prefs.getDouble(_keyWeight) ?? 70.0,
      dailyGoal: prefs.getInt(_keyDailyGoal) ?? 2500,
    );
  }

  // Save water logs
  Future<void> saveWaterLogs(List<WaterLog> logs) async {
    final prefs = _prefsSync;
    final jsonList = logs.map((log) => jsonEncode(log.toJson())).toList();
    await prefs.setStringList(_keyWaterLogs, jsonList);
  }

  // Get water logs
  Future<List<WaterLog>> getWaterLogs() async {
    final prefs = _prefsSync;
    final stringList = prefs.getStringList(_keyWaterLogs) ?? [];
    try {
      return stringList
          .map((item) => WaterLog.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Save alarms
  Future<void> saveAlarms(List<AlarmSetting> alarms) async {
    final prefs = _prefsSync;
    final jsonList = alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList(_keyAlarms, jsonList);
  }

  // Get alarms
  Future<List<AlarmSetting>> getAlarms() async {
    final prefs = _prefsSync;
    final stringList = prefs.getStringList(_keyAlarms);
    
    if (stringList == null) {
      return [];
    }

    try {
      return stringList
          .map((item) => AlarmSetting.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Save notification settings
  Future<void> saveNotificationSettings({
    required bool isEnabled,
    required bool sound,
    required bool vibration,
  }) async {
    final prefs = _prefsSync;
    await prefs.setBool(_keyIsNotificationsEnabled, isEnabled);
    await prefs.setBool(_keyIsSoundEnabled, sound);
    await prefs.setBool(_keyIsVibrationEnabled, vibration);
  }

  // Get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = _prefsSync;
    return {
      'isEnabled': prefs.getBool(_keyIsNotificationsEnabled) ?? true,
      'sound': prefs.getBool(_keyIsSoundEnabled) ?? true,
      'vibration': prefs.getBool(_keyIsVibrationEnabled) ?? true,
    };
  }

  // Save custom preset water amounts list
  Future<void> saveQuickPresets(List<int> presets) async {
    final prefs = _prefsSync;
    final stringList = presets.map((e) => e.toString()).toList();
    await prefs.setStringList(_keyQuickPresetsList, stringList);
    if (presets.isNotEmpty) await prefs.setInt(_keyPreset1, presets[0]);
    if (presets.length > 1) await prefs.setInt(_keyPreset2, presets[1]);
    if (presets.length > 2) await prefs.setInt(_keyPreset3, presets[2]);
  }

  // Get custom preset water amounts list
  Future<List<int>> getQuickPresets() async {
    final prefs = _prefsSync;
    final stringList = prefs.getStringList(_keyQuickPresetsList);
    if (stringList != null && stringList.isNotEmpty) {
      final parsed = stringList
          .map((e) => int.tryParse(e) ?? 0)
          .where((e) => e > 0)
          .toList();
      if (parsed.isNotEmpty) return parsed;
    }
    final p1 = prefs.getInt(_keyPreset1) ?? 200;
    final p2 = prefs.getInt(_keyPreset2) ?? 330;
    final p3 = prefs.getInt(_keyPreset3) ?? 500;
    return [p1, p2, p3];
  }

  // Save custom preset water amounts (legacy 3-item)
  Future<void> savePresets(int p1, int p2, int p3) async {
    final prefs = _prefsSync;
    await prefs.setInt(_keyPreset1, p1);
    await prefs.setInt(_keyPreset2, p2);
    await prefs.setInt(_keyPreset3, p3);
    await saveQuickPresets([p1, p2, p3]);
  }

  // Get custom preset water amounts (legacy 3-item)
  Future<Map<String, int>> getPresets() async {
    final list = await getQuickPresets();
    return {
      'preset1': list.isNotEmpty ? list[0] : 200,
      'preset2': list.length > 1 ? list[1] : 330,
      'preset3': list.length > 2 ? list[2] : 500,
    };
  }

  // Save End of Day notification settings
  Future<void> saveEndOfDaySettings({
    required bool isEnabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = _prefsSync;
    await prefs.setBool(_keyIsEndOfDayEnabled, isEnabled);
    await prefs.setInt(_keyEndOfDayHour, hour);
    await prefs.setInt(_keyEndOfDayMinute, minute);
  }

  // Get End of Day notification settings (Defaults to enabled at 22:00)
  Future<Map<String, dynamic>> getEndOfDaySettings() async {
    final prefs = _prefsSync;
    return {
      'isEnabled': prefs.getBool(_keyIsEndOfDayEnabled) ?? true,
      'hour': prefs.getInt(_keyEndOfDayHour) ?? 22,
      'minute': prefs.getInt(_keyEndOfDayMinute) ?? 0,
    };
  }

  // Save unlocked badges (map of badgeId -> ISO 8601 string)
  Future<void> saveUnlockedBadges(Map<String, String> badges) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyUnlockedBadges, jsonEncode(badges));
  }

  // Get unlocked badges
  Future<Map<String, String>> getUnlockedBadges() async {
    final prefs = _prefsSync;
    final raw = prefs.getString(_keyUnlockedBadges);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  // Save Theme Mode ('light' or 'dark')
  Future<void> saveThemeMode(String mode) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyThemeMode, mode);
  }

  // Get Theme Mode
  Future<String> getThemeMode() async {
    final prefs = _prefsSync;
    return prefs.getString(_keyThemeMode) ?? 'light';
  }

  // Save Sound Effects Enabled
  Future<void> saveSoundEffectsEnabled(bool enabled) async {
    final prefs = _prefsSync;
    await prefs.setBool(_keySoundEffects, enabled);
  }

  // Get Sound Effects Enabled
  Future<bool> getSoundEffectsEnabled() async {
    final prefs = _prefsSync;
    return prefs.getBool(_keySoundEffects) ?? true;
  }

  // Save Daily Boosts
  Future<void> saveDailyBoosts({
    required String date,
    required bool isWorkout,
    required bool isHotWeather,
  }) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyBoostDate, date);
    await prefs.setBool(_keyWorkoutBoost, isWorkout);
    await prefs.setBool(_keyHotWeatherBoost, isHotWeather);
  }

  // Get Daily Boosts
  Future<Map<String, dynamic>> getDailyBoosts() async {
    final prefs = _prefsSync;
    return {
      'date': prefs.getString(_keyBoostDate) ?? '',
      'isWorkout': prefs.getBool(_keyWorkoutBoost) ?? false,
      'isHotWeather': prefs.getBool(_keyHotWeatherBoost) ?? false,
    };
  }

  // Save iOS Shortcuts & Back Tap Settings
  Future<void> saveIosShortcutsSettings({
    required bool isSiriEnabled,
    required bool isBackTapEnabled,
  }) async {
    final prefs = _prefsSync;
    await prefs.setBool(_keyIsSiriShortcutsEnabled, isSiriEnabled);
    await prefs.setBool(_keyIsBackTapEnabled, isBackTapEnabled);
  }

  // Get iOS Shortcuts & Back Tap Settings
  Future<Map<String, bool>> getIosShortcutsSettings() async {
    final prefs = _prefsSync;
    return {
      'isSiriEnabled': prefs.getBool(_keyIsSiriShortcutsEnabled) ?? true,
      'isBackTapEnabled': prefs.getBool(_keyIsBackTapEnabled) ?? true,
    };
  }

  // Save Apple Health Settings
  Future<void> saveAppleHealthSettings({
    required bool isEnabled,
    required bool isAutoGoalEnabled,
  }) async {
    final prefs = _prefsSync;
    await prefs.setBool(_keyAppleHealthEnabled, isEnabled);
    await prefs.setBool(_keyAppleHealthAutoGoal, isAutoGoalEnabled);
  }

  // Get Apple Health Settings
  Future<Map<String, bool>> getAppleHealthSettings() async {
    final prefs = _prefsSync;
    return {
      'isEnabled': prefs.getBool(_keyAppleHealthEnabled) ?? false,
      'isAutoGoalEnabled': prefs.getBool(_keyAppleHealthAutoGoal) ?? false,
    };
  }

  // Save Ongoing Notification Setting
  Future<void> saveOngoingNotificationSetting(bool isEnabled) async {
    final prefs = _prefsSync;
    await prefs.setBool(_keyIsOngoingNotificationEnabled, isEnabled);
  }

  // Get Ongoing Notification Setting
  Future<bool> getOngoingNotificationSetting() async {
    final prefs = _prefsSync;
    return prefs.getBool(_keyIsOngoingNotificationEnabled) ?? false;
  }

  // Streak Shield Storage
  Future<void> saveStreakShields(int count) async {
    final prefs = _prefsSync;
    await prefs.setInt(_keyStreakShields, count);
  }

  Future<int> getStreakShields() async {
    final prefs = _prefsSync;
    return prefs.getInt(_keyStreakShields) ?? 1; // Default 1 shield
  }

  Future<void> saveFrozenDates(List<String> dates) async {
    final prefs = _prefsSync;
    await prefs.setStringList(_keyFrozenDates, dates);
  }

  Future<List<String>> getFrozenDates() async {
    final prefs = _prefsSync;
    return prefs.getStringList(_keyFrozenDates) ?? [];
  }

  Future<void> saveLastShieldRefill(String isoDate) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyLastShieldRefill, isoDate);
  }

  Future<String?> getLastShieldRefill() async {
    final prefs = _prefsSync;
    return prefs.getString(_keyLastShieldRefill);
  }

  // Goal Celebrated Date (Prevent multi-trigger per day)
  Future<void> saveLastGoalCelebratedDate(String dateStr) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyLastGoalCelebratedDate, dateStr);
  }

  Future<String?> getLastGoalCelebratedDate() async {
    final prefs = _prefsSync;
    return prefs.getString(_keyLastGoalCelebratedDate);
  }

  // Smart Pacing Setting
  Future<void> saveSmartPacingSetting(bool isEnabled) async {
    final prefs = _prefsSync;
    await prefs.setBool(_keyIsSmartPacingEnabled, isEnabled);
  }

  Future<bool> getSmartPacingSetting() async {
    final prefs = _prefsSync;
    return prefs.getBool(_keyIsSmartPacingEnabled) ?? true;
  }

  // Custom Mascot, Widget Theme, and Language Settings
  Future<void> saveMascotType(String type) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyMascotType, type);
  }

  Future<String> getMascotType() async {
    final prefs = _prefsSync;
    final val = prefs.getString(_keyMascotType);
    if (val == null || val == 'vitality' || val == 'plant') {
      return 'cat';
    }
    if (val == 'owl') {
      return 'squirrel';
    }
    return val;
  }

  Future<void> saveWidgetTheme(String theme) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyWidgetTheme, theme);
  }

  Future<String> getWidgetTheme() async {
    final prefs = _prefsSync;
    return prefs.getString(_keyWidgetTheme) ?? 'ocean';
  }

  Future<void> saveLanguage(String lang) async {
    final prefs = _prefsSync;
    await prefs.setString(_keyAppLanguage, lang);
  }

  Future<String> getLanguage() async {
    final prefs = _prefsSync;
    return prefs.getString(_keyAppLanguage) ?? 'tr';
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = _prefsSync;
    await prefs.clear();
  }
}
