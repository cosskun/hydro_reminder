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
import '../services/review_service.dart';

class WaterProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<WaterLog> _logs = [];
  List<AlarmSetting> _alarms = [];
  String _gender = 'Erkek';
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

  // Apple Health (HealthKit) / Google Health Connect Integration State
  bool _isAppleHealthSyncEnabled = false;
  bool _isAppleHealthAutoGoalEnabled = false;
  int _todayHealthSteps = 0;
  bool _pendingHealthPermissionFromSettings = false;
  bool _pendingNotificationPermissionFromSettings = false;

  // Ongoing Live Progress Notification State (Android & iOS)
  bool _isOngoingNotificationEnabled = false;

  // Duolingo-style Streak Freeze / Shield State
  int _streakShields = 1;
  List<String> _frozenDates = [];
  DateTime? _lastShieldRefillDate;

  // Daily Goal Celebration State (Confetti & Jingle)
  bool _shouldShowGoalCelebration = false;

  // Smart Adaptive Reminders (Pacing) State
  bool _isSmartPacingEnabled = true;

  // Custom Mascot, Widget Theme, and App Language
  String _mascotType = 'vitality';
  String _widgetTheme = 'ocean';
  String _language = 'tr';

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
      return {'emoji': '🫙', 'name': 'Şişe'};
    } else if (amountMl <= 800) {
      return {'emoji': '🫗', 'name': 'Büyük Matara'};
    } else {
      return {'emoji': '🚰', 'name': 'Sürahi'};
    }
  }

  // Unified Hydration Status (used by both DashboardScreen and Android/iOS Widgets so logos & texts are 100% in sync)
  static Map<String, String> getHydrationStatus(
    double percentage, {
    String mascotType = 'vitality',
    String lang = 'tr',
  }) {
    final isEn = lang == 'en';
    switch (mascotType) {
      case 'cat':
        if (percentage <= 0.0) {
          return {
            'emoji': '😿',
            'message': isEn
                ? 'Meow! So thirsty, could you spare a sip of water?'
                : 'Miyav! Çok susadım, bir yudum su verir misin?',
            'color': 'E11D48',
          };
        } else if (percentage < 0.35) {
          return {
            'emoji': '🐱',
            'message': isEn
                ? "Feeling refreshed! Let's keep drinking water together."
                : 'Biraz ferahladım! Birlikte su içmeye devam edelim.',
            'color': 'F59E0B',
          };
        } else if (percentage < 0.70) {
          return {
            'emoji': '😺',
            'message': isEn
                ? 'Happy purrs! Our hydration level is super.'
                : 'Harika bir mırıltı! Hidrasyon seviyemiz süper.',
            'color': '10B981',
          };
        } else if (percentage < 1.0) {
          return {
            'emoji': '😻',
            'message': isEn
                ? 'Pawsome! Just a tiny bit left to reach the goal.'
                : 'Sana bayılıyorum! Hedefe çok ama çok az kaldı.',
            'color': '06B6D4',
          };
        } else {
          return {
            'emoji': '🦁',
            'message': isEn
                ? "Roar time! You are today's hydration champion!"
                : 'Kükreme vakti! Günün şampiyon kedisi sensin!',
            'color': '8B5CF6',
          };
        }

      case 'penguin':
        if (percentage <= 0.0) {
          return {
            'emoji': '🧊',
            'message': isEn
                ? 'Ice is melting! Refresh yourself with cool water.'
                : 'Buzlar eriyor! Hemen taze suyla ferahla.',
            'color': 'E11D48',
          };
        } else if (percentage < 0.35) {
          return {
            'emoji': '🐧',
            'message': isEn
                ? 'Waddling towards the goal! First sip was great.'
                : 'Paytak adımlarla hedefe! İlk yudum harika.',
            'color': 'F59E0B',
          };
        } else if (percentage < 0.70) {
          return {
            'emoji': '🦭',
            'message': isEn
                ? 'Cool as the ocean! Gliding with the waves.'
                : 'Serin sular gibisin! Dalgalarla akıyoruz.',
            'color': '10B981',
          };
        } else if (percentage < 1.0) {
          return {
            'emoji': '🏄',
            'message': isEn
                ? 'Catching the polar wave! Summit is so close.'
                : 'Kutup dalgasını yakaladık! Zirve çok yakın.',
            'color': '06B6D4',
          };
        } else {
          return {
            'emoji': '👑',
            'message': isEn
                ? 'King of the Arctic! Daily goal accomplished!'
                : 'Kutupların Kralı! Günlük hedef tamamlandı!',
            'color': '8B5CF6',
          };
        }

      case 'plant':
        if (percentage <= 0.0) {
          return {
            'emoji': '🥀',
            'message': isEn
                ? 'Leaves are drooping! Time for some revitalizing water.'
                : 'Yapraklar boyun büktü! Biraz can suyu ver.',
            'color': 'E11D48',
          };
        } else if (percentage < 0.35) {
          return {
            'emoji': '🌱',
            'message': isEn
                ? 'First green shoot sprouted! Reviving with water.'
                : 'İlk filiz yeşerdi! Suyla yeniden canlanıyoruz.',
            'color': 'F59E0B',
          };
        } else if (percentage < 0.70) {
          return {
            'emoji': '🌿',
            'message': isEn
                ? 'Branches growing strong, freshness everywhere.'
                : 'Dallar uzuyor, tazelik her yere yayılıyor.',
            'color': '10B981',
          };
        } else if (percentage < 1.0) {
          return {
            'emoji': '🪴',
            'message': isEn
                ? 'Blooming bright! Just a little left to full bloom.'
                : 'Işıl ışıl parlıyorsun! Çiçek açmaya çok az kaldı.',
            'color': '06B6D4',
          };
        } else {
          return {
            'emoji': '🌳',
            'message': isEn
                ? 'Standing tall and vibrant! Congratulations!'
                : 'Koca bir çınar gibi dipdirisin! Tebrikler!',
            'color': '8B5CF6',
          };
        }

      case 'vitality':
      default:
        if (percentage <= 0.0) {
          return {
            'emoji': '🥱',
            'message': isEn
                ? 'Started the day dehydrated! Grab a glass of water.'
                : 'Güne susuz başladın! Hemen bir bardak su al.',
            'color': 'E11D48',
          };
        } else if (percentage < 0.35) {
          return {
            'emoji': '🙂',
            'message': isEn
                ? 'First step taken! Stepping steadily towards your goal.'
                : 'İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun.',
            'color': 'F59E0B',
          };
        } else if (percentage < 0.70) {
          return {
            'emoji': '😊',
            'message': isEn
                ? 'Going great! Your body thanks you.'
                : 'Harika gidiyorsun! Vücudun sana teşekkür ediyor.',
            'color': '10B981',
          };
        } else if (percentage < 1.0) {
          return {
            'emoji': '😎',
            'message': isEn
                ? 'Almost there! Your energy is peaking.'
                : 'Neredeyse tamamladın! Enerjin tam yerinde.',
            'color': '06B6D4',
          };
        } else {
          return {
            'emoji': '🥳',
            'message': isEn
                ? 'Congratulations! You reached your daily goal!'
                : 'Tebrikler! Günlük su hedefini tamamladın!',
            'color': '8B5CF6',
          };
        }
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

  // Calculate current consecutive streak (days goal was achieved or protected by streak shield)
  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final dateKey =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      final totalForDay = _logs
          .where((log) =>
              log.timestamp.year == checkDate.year &&
              log.timestamp.month == checkDate.month &&
              log.timestamp.day == checkDate.day)
          .fold(0, (sum, log) => sum + log.amountMl);

      final isGoalAchieved = totalForDay >= _dailyGoal;
      final isFrozen = _frozenDates.contains(dateKey);

      if (isGoalAchieved || isFrozen) {
        streak++;
      } else {
        if (i > 0) break;
      }
    }
    return streak;
  }

  // Streak Shield & Freeze Getters
  int get streakShields => _streakShields;
  List<String> get frozenDates => List.unmodifiable(_frozenDates);
  bool get shouldShowGoalCelebration => _shouldShowGoalCelebration;
  bool get isSmartPacingEnabled => _isSmartPacingEnabled;

  void clearGoalCelebration() {
    _shouldShowGoalCelebration = false;
    notifyListeners();
  }

  // Check if yesterday was missed and eligible for Streak Freeze recovery
  bool get canRecoverYesterday {
    if (_streakShields <= 0) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    if (_frozenDates.contains(yesterdayKey)) return false;

    final yesterdayTotal = _logs
        .where((log) =>
            log.timestamp.year == yesterday.year &&
            log.timestamp.month == yesterday.month &&
            log.timestamp.day == yesterday.day)
        .fold(0, (sum, log) => sum + log.amountMl);

    if (yesterdayTotal >= _dailyGoal) return false;

    // Check if there was an active streak before yesterday
    final dayBefore = DateTime.now().subtract(const Duration(days: 2));
    final dayBeforeKey =
        '${dayBefore.year}-${dayBefore.month.toString().padLeft(2, '0')}-${dayBefore.day.toString().padLeft(2, '0')}';
    final dayBeforeTotal = _logs
        .where((log) =>
            log.timestamp.year == dayBefore.year &&
            log.timestamp.month == dayBefore.month &&
            log.timestamp.day == dayBefore.day)
        .fold(0, (sum, log) => sum + log.amountMl);

    final wasDayBeforeAchieved =
        dayBeforeTotal >= _dailyGoal || _frozenDates.contains(dayBeforeKey);

    return wasDayBeforeAchieved;
  }

  // Use a Streak Shield to freeze/recover yesterday's streak
  Future<bool> useStreakShieldForYesterday() async {
    if (!canRecoverYesterday) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    _streakShields--;
    _frozenDates.add(yesterdayKey);
    await _storageService.saveStreakShields(_streakShields);
    await _storageService.saveFrozenDates(_frozenDates);

    await _syncWidgets();
    notifyListeners();
    return true;
  }

  // Toggle Smart Pacing Reminders
  Future<void> toggleSmartPacing(bool enabled) async {
    _isSmartPacingEnabled = enabled;
    await _storageService.saveSmartPacingSetting(enabled);
    await _syncSmartPacing();
    notifyListeners();
  }

  // Mascot, Theme and Language Getters
  String get mascotType => _mascotType;
  String get widgetTheme => _widgetTheme;
  String get language => _language;

  // Mascot, Theme and Language Update Methods
  Future<void> updateMascotType(String type) async {
    _mascotType = type;
    await _storageService.saveMascotType(type);
    await _syncWidgets();
    notifyListeners();
  }

  Future<void> updateWidgetTheme(String theme) async {
    _widgetTheme = theme;
    await _storageService.saveWidgetTheme(theme);
    await _syncWidgets();
    notifyListeners();
  }

  Future<void> updateLanguage(String lang) async {
    _language = lang;
    await _storageService.saveLanguage(lang);
    await _syncWidgets();
    notifyListeners();
  }

  void _checkAndRefillStreakShields() {
    final now = DateTime.now();
    if (_lastShieldRefillDate == null) {
      _lastShieldRefillDate = now;
      _storageService.saveLastShieldRefill(now.toIso8601String());
      return;
    }

    final daysSinceRefill = now.difference(_lastShieldRefillDate!).inDays;
    if (daysSinceRefill >= 7) {
      if (_streakShields < 2) {
        _streakShields++;
        _storageService.saveStreakShields(_streakShields);
      }
      _lastShieldRefillDate = now;
      _storageService.saveLastShieldRefill(now.toIso8601String());
    }
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

    // Streak Shields & Freeze State
    _streakShields = await _storageService.getStreakShields();
    _frozenDates = await _storageService.getFrozenDates();
    final lastRefill = await _storageService.getLastShieldRefill();
    if (lastRefill != null) {
      _lastShieldRefillDate = DateTime.tryParse(lastRefill);
    }
    _checkAndRefillStreakShields();

    // Smart Adaptive Reminders (Pacing)
    _isSmartPacingEnabled = await _storageService.getSmartPacingSetting();

    // Mascot, Theme and Language
    _mascotType = await _storageService.getMascotType();
    _widgetTheme = await _storageService.getWidgetTheme();
    _language = await _storageService.getLanguage();

    await _syncWidgets();
    await _syncEndOfDaySummary();
    await _syncSmartPacing();
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

  // Synchronize notification state when OS permission is revoked or granted in system settings
  Future<void> syncNotificationPermissionFromOS(bool hasOsPermission) async {
    if (!hasOsPermission) {
      if (_isNotificationsEnabled || _isOngoingNotificationEnabled) {
        _isNotificationsEnabled = false;
        _isOngoingNotificationEnabled = false;
        await _storageService.saveNotificationSettings(
          isEnabled: false,
          sound: _isSoundEnabled,
          vibration: _isVibrationEnabled,
        );
        await _storageService.saveOngoingNotificationSetting(false);
        await AlarmService().cancelAllNotifications();
        notifyListeners();
      }
    } else if (_pendingNotificationPermissionFromSettings) {
      _pendingNotificationPermissionFromSettings = false;
      _isNotificationsEnabled = true;
      await _storageService.saveNotificationSettings(
        isEnabled: true,
        sound: _isSoundEnabled,
        vibration: _isVibrationEnabled,
      );
      await AlarmService().rescheduleAllAlarms(_alarms);
      await _syncEndOfDaySummary();
      await _syncOngoingNotification();
      notifyListeners();
    }
  }

  // Synchronize both Notification and Health Connect permissions when user returns from system settings
  Future<void> syncSystemPermissionsOnResume() async {
    try {
      await _syncWidgets();
      if (_hasCompletedOnboarding) {
        final hasNotifPerm = await AlarmService().checkPermissionStatus();
        await syncNotificationPermissionFromOS(hasNotifPerm);
      }

      if (_pendingHealthPermissionFromSettings) {
        final hasHealthPerm = await HealthService().hasPermissions();
        if (hasHealthPerm == true) {
          _pendingHealthPermissionFromSettings = false;
          _isAppleHealthSyncEnabled = true;
          await _storageService.saveAppleHealthSettings(
            isEnabled: true,
            isAutoGoalEnabled: _isAppleHealthAutoGoalEnabled,
          );
          _todayHealthSteps = await HealthService().getTodaySteps();
          notifyListeners();
        }
      } else if (_isAppleHealthSyncEnabled) {
        final hasHealthPerm = await HealthService().hasPermissions();
        if (hasHealthPerm == false) {
          _isAppleHealthSyncEnabled = false;
          await _storageService.saveAppleHealthSettings(
            isEnabled: false,
            isAutoGoalEnabled: _isAppleHealthAutoGoalEnabled,
          );
          notifyListeners();
        } else {
          _todayHealthSteps = await HealthService().getTodaySteps();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  // Update Apple Health (HealthKit) / Google Health Connect Settings
  Future<bool> updateAppleHealthSettings({
    bool? isEnabled,
    bool? isAutoGoalEnabled,
  }) async {
    if (isEnabled != null) {
      if (isEnabled) {
        _pendingHealthPermissionFromSettings = true;
        final granted = await HealthService().requestAuthorization();
        if (!granted) {
          _isAppleHealthSyncEnabled = false;
          await _storageService.saveAppleHealthSettings(
            isEnabled: false,
            isAutoGoalEnabled: _isAppleHealthAutoGoalEnabled,
          );
          notifyListeners();
          return false;
        }
        _pendingHealthPermissionFromSettings = false;
      } else {
        _pendingHealthPermissionFromSettings = false;
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

  // Update Ongoing Live Progress Notification Setting (checks OS permission first if enabling)
  Future<bool> updateOngoingNotificationSetting(bool isEnabled) async {
    if (isEnabled) {
      bool hasPerm = await AlarmService().checkPermissionStatus();
      if (!hasPerm) {
        hasPerm = await AlarmService().requestPermission();
      }
      if (!hasPerm) {
        _pendingNotificationPermissionFromSettings = true;
        _isOngoingNotificationEnabled = false;
        await _storageService.saveOngoingNotificationSetting(false);
        await AlarmService().openNotificationSettings();
        notifyListeners();
        return false;
      }
      if (!_isNotificationsEnabled) {
        _isNotificationsEnabled = true;
        await _storageService.saveNotificationSettings(
          isEnabled: true,
          sound: _isSoundEnabled,
          vibration: _isVibrationEnabled,
        );
      }
    }
    _isOngoingNotificationEnabled = isEnabled;
    notifyListeners();
    await _storageService.saveOngoingNotificationSetting(isEnabled);
    await _syncOngoingNotification();
    return true;
  }

  // Sync Live Ongoing Notification in Notification Drawer
  Future<void> _syncOngoingNotification() async {
    try {
      final percentInt = (todayPercentage * 100).toInt();
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
          // Store review prompt check on new achievement unlock
          ReviewService().checkAndPromptIfEligible(streak: streak, isNewBadgeUnlocked: true);
        }
      }
    }
  }

  // Public helper to force widget synchronization after platform channels are ready
  Future<void> syncWidgetsNow() => _syncWidgets();

  // Sync data with home screen and lock screen widgets
  Future<void> _syncWidgets() async {
    try {
      final percentInt = (todayPercentage * 100).toInt();
      final now = DateTime.now();
      const shortDays = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pa'];
      final List<String> labels = [];
      final List<String> statuses = [];

      final goal = dailyGoal > 0 ? dailyGoal : 2500;
      for (int i = 4; i >= 0; i--) {
        final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        labels.add(shortDays[d.weekday - 1]);
        final dayTotal = _logs
            .where((l) =>
                l.timestamp.year == d.year &&
                l.timestamp.month == d.month &&
                l.timestamp.day == d.day)
            .fold(0, (sum, l) => sum + l.amountMl);
        if (dayTotal >= goal) {
          statuses.add('2'); // Goal completed (checkmark)
        } else if (dayTotal > 0) {
          statuses.add('1'); // Partial progress (checkmark/active)
        } else {
          statuses.add('0'); // Empty
        }
      }

      int displayStreak = currentStreak;
      if (displayStreak == 0 && todayConsumed > 0) {
        displayStreak = 1;
      }

      final status = WaterProvider.getHydrationStatus(
        todayPercentage,
        mascotType: _mascotType,
        lang: _language,
      );
      final String mascotEmoji = status['emoji']!;
      final String mascotSubtitle = status['message']!;

      final p1Emoji = WaterProvider.getPresetMeta(preset1)['emoji'] ?? '🥛';
      final p2Emoji = WaterProvider.getPresetMeta(preset2)['emoji'] ?? '🥤';
      final p3Emoji = WaterProvider.getPresetMeta(preset3)['emoji'] ?? '🫙';

      await WidgetService().updateWidgets(
        todayConsumed: todayConsumed,
        dailyGoal: dailyGoal,
        dailyRemaining: dailyRemainingMl,
        percentage: percentInt,
        preset1: preset1,
        preset2: preset2,
        preset3: preset3,
        preset1Emoji: p1Emoji,
        preset2Emoji: p2Emoji,
        preset3Emoji: p3Emoji,
        streakDays: displayStreak,
        dayLabels: labels.join(','),
        dayStatuses: statuses.join(','),
        mascotEmoji: mascotEmoji,
        mascotSubtitle: mascotSubtitle,
        widgetTheme: _widgetTheme,
        mascotType: _mascotType,
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
    if (gender == 'Kadın' || gender == 'Female') {
      multiplier = 31.0;
    } else if (gender == 'Diğer' || gender == 'Other') {
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
    final wasOnboardingCompleted = _hasCompletedOnboarding;
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
      if (!wasOnboardingCompleted) {
        final granted = await AlarmService().requestPermission();
        if (!granted) {
          _isNotificationsEnabled = false;
          _isEndOfDayEnabled = false;
          _isOngoingNotificationEnabled = false;
          await _storageService.saveNotificationSettings(
            isEnabled: false,
            sound: _isSoundEnabled,
            vibration: _isVibrationEnabled,
          );
          await _storageService.saveEndOfDaySettings(
            isEnabled: false,
            hour: _endOfDayHour,
            minute: _endOfDayMinute,
          );
          await _storageService.saveOngoingNotificationSetting(false);
          await AlarmService().cancelAllNotifications();
          notifyListeners();
        } else {
          _isNotificationsEnabled = true;
          await _storageService.saveNotificationSettings(
            isEnabled: true,
            sound: _isSoundEnabled,
            vibration: _isVibrationEnabled,
          );
          await AlarmService().rescheduleAllAlarms(_alarms);
          await _syncEndOfDaySummary();
          notifyListeners();
        }
      } else {
        await _syncEndOfDaySummary();
      }
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
    final prevPercentage = todayPercentage;

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

    final newPercentage = todayPercentage;

    // Daily Goal Reached Celebration (Crossing >= 100% threshold for the first time today)
    if (prevPercentage < 1.0 && newPercentage >= 1.0) {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final lastCelebrated = await _storageService.getLastGoalCelebratedDate();
      if (lastCelebrated != todayStr) {
        await _storageService.saveLastGoalCelebratedDate(todayStr);
        _shouldShowGoalCelebration = true;
        if (_isSoundEffectsEnabled) {
          SoundService().playGoalReachedCelebrationSound();
        }
        notifyListeners();
        ReviewService().checkAndPromptIfEligible(streak: currentStreak);
      }
    } else if (_isSoundEffectsEnabled) {
      try {
        HapticFeedback.lightImpact();
        SoundService().playWaterSipSound();
      } catch (_) {}
    }

    try {
      await _storageService.saveWaterLogs(_logs);
      await _checkAndUnlockBadges();
      await _syncEndOfDaySummary();
      await _syncSmartPacing();
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
      await _syncSmartPacing();
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

  // Sync Smart Adaptive Pacing Reminders with live progress
  Future<void> _syncSmartPacing() async {
    if (_isNotificationsEnabled && _isSmartPacingEnabled) {
      try {
        await AlarmService().scheduleSmartPacingNotifications(
          isEnabled: _isSmartPacingEnabled,
          consumedMl: todayConsumed,
          dailyGoalMl: dailyGoal,
        );
      } catch (_) {}
    }
  }

  // Send Sleep Hygiene Tip Notification directly with live calculated values
  Future<bool> sendSleepTipNotification() async {
    final sent = await AlarmService().sendSleepTipNotification(
      consumedMl: todayConsumed,
      remainingMl: dailyRemainingMl,
      dailyGoalMl: dailyGoal,
    );
    if (!sent) {
      _pendingNotificationPermissionFromSettings = true;
    }
    return sent;
  }

  // Global Notification Settings (checks OS permission first when enabling)
  Future<bool> updateNotificationSettings({
    required bool isEnabled,
    required bool sound,
    required bool vibration,
  }) async {
    if (isEnabled) {
      bool hasPerm = await AlarmService().checkPermissionStatus();
      if (!hasPerm) {
        hasPerm = await AlarmService().requestPermission();
      }
      if (!hasPerm) {
        _pendingNotificationPermissionFromSettings = true;
        _isNotificationsEnabled = false;
        _isOngoingNotificationEnabled = false;
        await _storageService.saveNotificationSettings(
          isEnabled: false,
          sound: sound,
          vibration: vibration,
        );
        await _storageService.saveOngoingNotificationSetting(false);
        await AlarmService().cancelAllNotifications();
        await AlarmService().openNotificationSettings();
        notifyListeners();
        return false;
      }
      _pendingNotificationPermissionFromSettings = false;
    } else {
      _pendingNotificationPermissionFromSettings = false;
    }

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
    return true;
  }

  // End of Day notification settings
  Future<bool> updateEndOfDaySettings({
    required bool isEnabled,
    required int hour,
    required int minute,
  }) async {
    if (isEnabled) {
      bool hasPerm = await AlarmService().checkPermissionStatus();
      if (!hasPerm) {
        hasPerm = await AlarmService().requestPermission();
      }
      if (!hasPerm) {
        _pendingNotificationPermissionFromSettings = true;
        _isEndOfDayEnabled = false;
        await _storageService.saveEndOfDaySettings(
          isEnabled: false,
          hour: hour,
          minute: minute,
        );
        await AlarmService().openNotificationSettings();
        notifyListeners();
        return false;
      }
    }

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
    return true;
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

    final now = DateTime.now();
    final alarmTimeToday = DateTime(now.year, now.month, now.day, hour, minute);
    if (now.difference(alarmTimeToday).inSeconds > 60) {
      AlarmService().markAlarmHandledForToday(alarm.id);
    }

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
      final now = DateTime.now();
      final alarmTimeToday = DateTime(now.year, now.month, now.day, hour, minute);
      if (now.difference(alarmTimeToday).inSeconds > 60) {
        AlarmService().markAlarmHandledForToday(id);
      }
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

    AlarmService().markAlarmHandledForToday(alarm.id);
    unawaited(AlarmService().cancelAlarmFollowUps(alarm.id));

    _startAlarmLoop(alarm);

    notifyListeners();
  }

  // Dismiss alarm ONLY when user confirmed they drank water
  void dismissAlarm(int amountMl) {
    final dismissedId = _activeAlarm?.id;
    _isAlarmActive = false;
    _activeAlarm = null;
    _alarmTriggeredAt = null;

    if (dismissedId != null) {
      AlarmService().markAlarmHandledForToday(dismissedId);
      unawaited(AlarmService().cancelAlarmFollowUps(dismissedId));
    }

    SoundService().stopSound();
    _stopVibrationLoop();

    addWater(amountMl);
  }

  void _startAlarmLoop(AlarmSetting alarm) {
    _vibrationTimer?.cancel();
    _pulseAlarmCycle(alarm);
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (_isAlarmActive) {
        _pulseAlarmCycle(alarm);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _pulseAlarmCycle(AlarmSetting alarm) async {
    if (!_isAlarmActive) return;

    if (_isVibrationEnabled) {
      // 1. Trigger native hardware vibration & Taptic burst BEFORE audio chime so iOS audio buffer never suppresses vibration
      await SoundService().triggerAlarmVibration();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_isAlarmActive && _isVibrationEnabled) {
          try {
            HapticFeedback.heavyImpact();
          } catch (_) {}
        }
      });
    }

    if (_isSoundEnabled && _isAlarmActive) {
      // 2. Play alarm chime after 320ms vibration window (respects Silent Switch on iOS)
      Future.delayed(Duration(milliseconds: _isVibrationEnabled ? 320 : 0), () {
        if (_isAlarmActive && _isSoundEnabled) {
          SoundService().playAlarmSound(
            soundPath: alarm.soundPath,
            isCustomSound: alarm.isCustomSound,
            loop: false,
          );
        }
      });
    }
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
    _gender = 'Erkek';
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
