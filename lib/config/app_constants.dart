class HydrationConstants {
  // Boost values
  static const int workoutBoostMl = 500;
  static const int hotWeatherBoostMl = 300;

  // Formula multipliers
  static const double baseMultiplierMen = 35.0;
  static const double baseMultiplierWomen = 31.0;
  static const double baseMultiplierOther = 33.0;

  // Age modifiers
  static const double ageModifierYoung = 4.0;
  static const double ageModifierSenior = -3.0;

  // Clamp bounds
  static const int minGoalCalcClamp = 1000;
  static const int maxGoalCalcClamp = 5000;
  static const int minDailyGoalClamp = 500;
  static const int maxDailyGoalClamp = 10000;

  // Preset thresholds
  static const int presetThresholdYudum = 120;
  static const int presetThresholdFincan = 180;
  static const int presetThresholdBardak = 260;
  static const int presetThresholdKucukSise = 380;
  static const int presetThresholdSise = 550;
  static const int presetThresholdBuyukMatara = 800;
}

class BadgeConstants {
  // Streak thresholds
  static const int streak3 = 3;
  static const int streak7 = 7;
  static const int streak30 = 30;

  // Volume thresholds
  static const int ocean50L = 50000;
  static const int ocean100L = 100000;

  // Rules
  static const int streakLookbackDays = 60;
}

class UIConstants {
  // Status thresholds
  static const double statusThresholdVeryLow = 0.25;
  static const double statusThresholdLow = 0.50;
  static const double statusThresholdGood = 0.75;
  static const double statusThresholdPerfect = 1.0;

  // Status colors
  static const String statusColorVeryLow = 'E11D48';
  static const String statusColorLow = 'F59E0B';
  static const String statusColorGood = '10B981';
  static const String statusColorPerfect = '06B6D4';
  static const String statusColorGoalReached = '8B5CF6';

  // Bubble size
  static const double bubbleSizeMin = 175.0;
  static const double bubbleSizeMax = 225.0;

  // Stepper values
  static const int stepperStepSmall = 50;
  static const int stepperStepLarge = 100;

  // Chart dimensions
  static const double chartHeight = 140.0;
  static const double chartMaxBarHeight = 90.0;

  // Grid delegate
  static const int gridCrossAxisCount = 3;
  static const double gridChildAspectRatio = 0.82;
  static const double gridCrossAxisSpacing = 8.0;
  static const double gridMainAxisSpacing = 8.0;

  // Animation params
  static const int alarmPulseDurationMs = 1000;
  static const double alarmScaleBegin = 0.95;
  static const double alarmScaleEnd = 1.05;
  static const double alarmGlowBegin = 10.0;
  static const double alarmGlowEnd = 30.0;
}

class PresetConstants {
  // Chips
  static const List<int> quickAddChips = [50, 100, 150, 200, 250, 330, 500];
  static const List<int> goalQuickChips = [2000, 2500, 3000, 3500];
  
  // Defaults
  static const List<int> defaultQuickPresets = [200, 330, 500];
  static const int dismissAmountMl = 250;
}

class DefaultValues {
  static const String gender = 'Erkek';
  static const int age = 25;
  static const double weight = 70.0;
  static const int dailyGoal = 2500;
}

class NotificationConstants {
  // Polling / Intervals
  static const int alarmPollingIntervalSeconds = 15;
  static const int vibrationIntervalMs = 1500;

  // Channel IDs
  static const String channelAlarmsId = 'hydro_reminder_alarms';
  static const String channelSummaryId = 'hydro_summary_channel';
  static const String channelTipsId = 'hydro_tips_channel';
}

class WidgetConstants {
  static const String appGroupId = 'group.com.antigravity.hydroReminder';

  // Provider Names Android
  static const String androidProgressWidget = 'WaterProgressWidgetProvider';
  static const String androidQuickLogWidget = 'WaterQuickLogWidgetProvider';
  static const String androidMiniWidget = 'WaterMiniWidgetProvider';

  // Provider Names iOS
  static const String iosProgressWidget = 'WaterProgressWidget';
  static const String iosQuickLogWidget = 'WaterQuickLogWidget';
  static const String iosMiniWidget = 'WaterMiniWidget';
}

class AlarmConstants {
  static const int minDrinkDurationSeconds = 5;
  static const int defaultDismissAmountMl = 250;
  static const String cheatWarningTitle = 'Suyu Gerçekten İçtiniz mi?';
  static const String cheatWarningMessage = 'Sistemi geçiştirmek için suyu içmeden bastınız!';
  static const String cheatWarningAction = 'Lütfen suyunuzu içiniz.';
  static const String cheatWarningExplanation =
      'Bir bardak (250 ml) suyu sağlıklı bir şekilde tüketmek en az 5 saniye sürer. Vücudunuzun hidrasyon sağlığı için lütfen acele etmeyin ve suyunuzu yudumlayarak için.';
}
