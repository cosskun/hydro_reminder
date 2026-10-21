import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:hydro_reminder/config/app_theme.dart';
import 'package:hydro_reminder/providers/water_provider.dart';
import 'package:hydro_reminder/models/water_log.dart';
import 'package:hydro_reminder/screens/dashboard_screen.dart';
import 'package:hydro_reminder/widgets/settings/appearance_settings_card.dart';
import 'package:hydro_reminder/widgets/dialogs/alarm_edit_dialog.dart';
import 'package:hydro_reminder/widgets/liquid_progress_indicator.dart';
import 'package:hydro_reminder/services/storage_service.dart';
import 'package:hydro_reminder/services/sound_service.dart';
import 'package:hydro_reminder/services/review_service.dart';
import 'package:hydro_reminder/l10n/app_translations.dart';

Widget createTestApp({
  required WaterProvider provider,
  required Widget child,
  TargetPlatform platform = TargetPlatform.android,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ChangeNotifierProvider<WaterProvider>.value(
    value: provider,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(platform: platform),
      darkTheme: AppTheme.darkTheme.copyWith(platform: platform),
      themeMode: themeMode,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().init();
  });

  group('1. Daily Goal Celebration & Confetti Tests', () {
    testWidgets('Crossing daily goal triggers confetti celebration and once-per-day guard works',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();
      await provider.updateDailyGoal(2000);

      // Initially 0 consumed
      expect(provider.shouldShowGoalCelebration, isFalse);

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const DashboardScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Add 2000 ml to reach 100%
      await provider.addWater(2000);
      expect(provider.shouldShowGoalCelebration, isTrue);

      // Pump to trigger SnackBar and Confetti
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Harikasın! Bugünkü su hedefini başarıyla tamamladın! 🥳💧'),
        findsOneWidget,
      );
      expect(provider.shouldShowGoalCelebration, isFalse);

      // Adding more water on the same day should NOT re-trigger celebration
      await provider.addWater(300);
      expect(provider.shouldShowGoalCelebration, isFalse);
    });
  });

  group('2. Streak Freeze / Shield Recovery Tests', () {
    testWidgets('Shield recovers missed yesterday without breaking the streak',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();
      await provider.updateDailyGoal(2000);

      final now = DateTime.now();
      final twoDaysAgo = now.subtract(const Duration(days: 2));

      // Simulate active streak before yesterday
      provider.logs.clear();
      provider.logs.add(
        WaterLog(
          id: 'log_prev',
          timestamp: twoDaysAgo,
          amountMl: 2200,
          rawAmountMl: 2200,
        ),
      );

      // Yesterday was missed (0 ml)
      expect(provider.canRecoverYesterday, isTrue);
      expect(provider.streakShields, 1);

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const DashboardScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Check recovery banner is shown on Dashboard
      expect(find.text('Seri Kurtarma Kalkanı!'), findsOneWidget);
      expect(
        find.text('Dün hedefini kaçırdın. 1 kalkan kullanarak serini koru!'),
        findsOneWidget,
      );

      // Tap 'Kurtar' button
      final recoverButton = find.widgetWithText(ElevatedButton, 'Kurtar');
      expect(recoverButton, findsOneWidget);
      await tester.tap(recoverButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Shield used: count reduced to 0, yesterday is frozen, banner gone
      expect(provider.streakShields, 0);
      expect(provider.canRecoverYesterday, isFalse);
      expect(
        find.text('🛡️ Harika! Seri kalkanı kullanıldı ve seriniz korundu!'),
        findsOneWidget,
      );
      expect(find.text('Seri Kurtarma Kalkanı!'), findsNothing);
    });
  });

  group('3. Custom Mascot Selection & Realtime Synchronisation Tests', () {
    testWidgets('Switching between Vitality, Cat, Penguin, and Plant mascots updates state and UI',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const SingleChildScrollView(child: AppearanceSettingsCard()),
        ),
      );
      await tester.pumpAndSettle();

      // Check all 5 official animal mascot options are present
      expect(find.text('Luna (Kedi)'), findsOneWidget);
      expect(find.text('Neşeli Köpek'), findsOneWidget);
      expect(find.text('Kutup Pengueni'), findsOneWidget);
      expect(find.text('Tembel Panda'), findsOneWidget);
      expect(find.text('Fındık (Sincap)'), findsOneWidget);

      // 1. Switch to Dog mascot
      await tester.tap(find.text('Neşeli Köpek'));
      await tester.pumpAndSettle();
      expect(provider.mascotType, 'dog');
      expect(await StorageService().getMascotType(), 'dog');

      final dogStatus = WaterProvider.getHydrationStatus(0.0, mascotType: provider.mascotType);
      expect(dogStatus['emoji'], '🐶');

      // 2. Switch to Penguin mascot
      await tester.tap(find.text('Kutup Pengueni'));
      await tester.pumpAndSettle();
      expect(provider.mascotType, 'penguin');
      expect(await StorageService().getMascotType(), 'penguin');

      final penguinStatus = WaterProvider.getHydrationStatus(1.0, mascotType: provider.mascotType);
      expect(penguinStatus['emoji'], '👑');

      // 3. Switch to Squirrel mascot
      await tester.tap(find.text('Fındık (Sincap)'));
      await tester.pumpAndSettle();
      expect(provider.mascotType, 'squirrel');
      expect(await StorageService().getMascotType(), 'squirrel');

      final squirrelStatus = WaterProvider.getHydrationStatus(1.0, mascotType: provider.mascotType);
      expect(squirrelStatus['emoji'], '👑');

      // 4. Switch back to Cat
      await tester.tap(find.text('Luna (Kedi)'));
      await tester.pumpAndSettle();
      expect(provider.mascotType, 'cat');
      expect(await StorageService().getMascotType(), 'cat');
    });
  });

  group('4. Customizable Widget & Accent Themes Tests', () {
    testWidgets('Switching widget themes updates and persists ocean, glass, neon, and emerald',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const SingleChildScrollView(child: AppearanceSettingsCard()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Okyanus Mavisi'), findsOneWidget);
      expect(find.text('iOS Buzlu Cam'), findsOneWidget);
      expect(find.text('Neon Siber Gece'), findsOneWidget);
      expect(find.text('Zümrüt Yeşili Doğa'), findsOneWidget);

      // Select iOS Frosted Glass
      await tester.ensureVisible(find.text('iOS Buzlu Cam'));
      await tester.tap(find.text('iOS Buzlu Cam'));
      await tester.pumpAndSettle();
      expect(provider.widgetTheme, 'glass');
      expect(await StorageService().getWidgetTheme(), 'glass');

      // Select Neon Cyber
      await tester.ensureVisible(find.text('Neon Siber Gece'));
      await tester.tap(find.text('Neon Siber Gece'));
      await tester.pumpAndSettle();
      expect(provider.widgetTheme, 'neon');
      expect(await StorageService().getWidgetTheme(), 'neon');

      // Select Emerald Forest
      await tester.ensureVisible(find.text('Zümrüt Yeşili Doğa'));
      await tester.tap(find.text('Zümrüt Yeşili Doğa'));
      await tester.pumpAndSettle();
      expect(provider.widgetTheme, 'emerald');
      expect(await StorageService().getWidgetTheme(), 'emerald');

      // Select Ocean Blue
      await tester.ensureVisible(find.text('Okyanus Mavisi'));
      await tester.tap(find.text('Okyanus Mavisi'));
      await tester.pumpAndSettle();
      expect(provider.widgetTheme, 'ocean');
      expect(await StorageService().getWidgetTheme(), 'ocean');
    });
  });

  group('5. English Language Localization & Switcher Tests', () {
    testWidgets('Toggling language between Turkish and English updates strings across app and mascots',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const SingleChildScrollView(child: AppearanceSettingsCard()),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(provider.language, 'en');
      expect(await StorageService().getLanguage(), 'en');

      // Verify card content translated to English
      expect(find.text('Appearance & Effects 🎨'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);
      expect(find.text('Custom Mascot Character'), findsOneWidget);
      expect(find.text('Widget Theme'), findsOneWidget);
      expect(find.text('Luna (Cat)'), findsOneWidget);
      expect(find.text('Ocean Blue'), findsOneWidget);

      // Verify English Mascot quotes
      final enQuote = WaterProvider.getHydrationStatus(1.0, mascotType: 'vitality', lang: 'en');
      expect(enQuote['message'], 'Congratulations! You reached your daily goal!');

      // Switch back to Turkish
      await tester.tap(find.text('Türkçe'));
      await tester.pumpAndSettle();

      expect(provider.language, 'tr');
      expect(await StorageService().getLanguage(), 'tr');
      expect(find.text('Görünüm & Efektler 🎨'), findsOneWidget);
      expect(find.text('Uygulama Dili'), findsOneWidget);
    });
  });

  group('6. Nature & Meditation Alarm Sounds Tests', () {
    testWidgets('Alarm dialog lists nature sounds (Rain, Stream, Tibetan Bowl) and allows selection',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showAlarmEditDialog(ctx),
              child: const Text('Open Alarm Dialog'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open alarm dialog
      await tester.tap(find.text('Open Alarm Dialog'));
      await tester.pumpAndSettle();

      // Verify nature sounds exist in dialog
      expect(find.text('Huzurlu Yağmur'), findsOneWidget);
      expect(find.text('Nehir Akıntısı'), findsOneWidget);
      expect(find.text('Tibet Kasesi & Zen'), findsOneWidget);

      // Select Tibetan Bowl (scroll into view if needed)
      await tester.ensureVisible(find.text('Tibet Kasesi & Zen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tibet Kasesi & Zen'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('🧘'), findsWidgets);
    });
  });

  group('7. Smart Pacing & ReviewService In-App Prompt Tests', () {
    test('Smart pacing toggle updates state and storage', () async {
      final provider = WaterProvider();
      expect(provider.isSmartPacingEnabled, isTrue);

      await provider.toggleSmartPacing(false);
      expect(provider.isSmartPacingEnabled, isFalse);
      expect(await StorageService().getSmartPacingSetting(), isFalse);

      await provider.toggleSmartPacing(true);
      expect(provider.isSmartPacingEnabled, isTrue);
      expect(await StorageService().getSmartPacingSetting(), isTrue);
    });

    test('ReviewService handles 3-day streak qualification and permanent suppression when rated',
        () async {
      final service = ReviewService();

      // Unrated user with streak 2 -> no prompt
      expect(await service.checkAndPromptIfEligible(streak: 2), isFalse);

      // Streak >= 3 -> prompts
      expect(await service.checkAndPromptIfEligible(streak: 3), isTrue);

      // User submits rating
      await service.markAsRated();
      expect(await service.hasRated(), isTrue);

      // Never prompts again regardless of streak or new badges
      expect(await service.shouldPromptReview(), isFalse);
      expect(await service.checkAndPromptIfEligible(streak: 30, isNewBadgeUnlocked: true), isFalse);
    });
  });

  group('8. Liquid Fill Animation & Bubble Float Tests', () {
    testWidgets('LiquidProgressIndicator renders smooth wave and bubbles across percentages',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      // Render at 0%
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidProgressIndicator(
                progress: 0.0,
                size: 200,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // Render at 50%
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidProgressIndicator(
                progress: 0.50,
                size: 200,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // Render at 100%+
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidProgressIndicator(
                progress: 1.0,
                size: 200,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}
