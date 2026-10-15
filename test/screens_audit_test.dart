import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hydro_reminder/config/app_routes.dart';
import 'package:hydro_reminder/config/app_theme.dart';
import 'package:hydro_reminder/providers/water_provider.dart';
import 'package:hydro_reminder/screens/dashboard_screen.dart';
import 'package:hydro_reminder/screens/history_screen.dart';
import 'package:hydro_reminder/screens/alarms_screen.dart';
import 'package:hydro_reminder/screens/settings_screen.dart';
import 'package:hydro_reminder/screens/onboarding_screen.dart';
import 'package:hydro_reminder/screens/alarm_active_screen.dart';
import 'package:hydro_reminder/widgets/dashboard/hydration_quick_add_button.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hydro_reminder/services/storage_service.dart';

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

  group('Full Screen & Platform Audit Tests (Android & iOS)', () {
    testWidgets('1. Onboarding Screen renders and calculates target without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();
      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const OnboardingScreen(),
          platform: TargetPlatform.android,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HydroSoft'), findsOneWidget);
      expect(find.text('Sağlıklı bir yaşam için kişisel hidrasyon asistanınız'), findsOneWidget);
      expect(find.text('Profil Bilgileriniz'), findsOneWidget);

      // Verify Gender selector buttons
      expect(find.text('Erkek'), findsOneWidget);
      expect(find.text('Kadın'), findsOneWidget);

      // Tap Kadın (Female)
      await tester.tap(find.text('Kadın'));
      await tester.pumpAndSettle();

      // Tap Hedefimi Hesapla button
      final submitButton = find.text('Hedefimi Hesapla');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Bottom sheet with recommended goal appears
      expect(find.text('💧 Günlük Hedefiniz Belirlendi! 💧'), findsOneWidget);
      expect(find.text('Uygulamaya Başla 🚀'), findsOneWidget);

      await tester.tap(find.text('Uygulamaya Başla 🚀'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Dashboard Screen (iOS & Android) - Quick Add, Boosts, Beverage Dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 2532); // iPhone 14 / 15 viewport
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();
      // Simulate completed onboarding
      provider.updateProfile(gender: 'Erkek', age: 26, weight: 75);

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const DashboardScreen(),
          platform: TargetPlatform.iOS,
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Check header and greeting
      expect(find.text('Merhaba 👋'), findsOneWidget);
      expect(find.text('Bugün nasılsın?'), findsOneWidget);

      // Verify Boost Action Chips: Spor and Sıcak Hava
      final sportChip = find.text('Spor (+500ml)');
      final heatChip = find.text('Sıcak Hava (+300ml)');
      expect(sportChip, findsOneWidget);
      expect(heatChip, findsOneWidget);

      final initialGoal = provider.dailyGoal;
      // Tap Workout Boost chip
      await tester.tap(sportChip);
      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.isWorkoutBoostActive, isTrue);
      expect(provider.dailyGoal, initialGoal + 500);

      // Tap Hot Weather Boost chip
      await tester.tap(heatChip);
      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.isHotWeatherBoostActive, isTrue);
      expect(provider.dailyGoal, initialGoal + 800);

      // Test Quick Add (+200ml)
      final initialIntake = provider.todayTotal;
      final quickAddFinder = find.byType(HydrationQuickAddButton);
      expect(quickAddFinder, findsWidgets);

      await tester.tap(quickAddFinder.first);
      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.todayTotal, greaterThan(initialIntake));

      // Test Custom Beverage Dialog
      final customAddButton = find.byType(HydrationCustomAddButton);
      expect(customAddButton, findsOneWidget);
      await tester.tap(customAddButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Check custom beverage modal contents
      expect(find.text('İçecek & Miktar Ekle 💧'), findsOneWidget);
      expect(find.text('Kahve'), findsOneWidget);
      expect(find.text('Çay & Bitki Çayı'), findsOneWidget);
      expect(find.text('Maden Suyu'), findsOneWidget);

      // Select Coffee
      await tester.tap(find.text('Kahve'));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap quick amount preset in dialog (+200 ml)
      final chip200 = find.widgetWithText(ActionChip, '+200 ml');
      if (chip200.evaluate().isNotEmpty) {
        await tester.tap(chip200);
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Tap Ekle (Add) button
      final confirmAddBtn = find.widgetWithText(ElevatedButton, '☕ Ekle (200 ml)');
      expect(confirmAddBtn, findsOneWidget);
      await tester.tap(confirmAddBtn);
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });

    testWidgets('3. History Screen (Weekly Bar Chart, Analytics, Badges, Log list)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();
      provider.addWater(300, beverageId: 'water');
      provider.addWater(200, beverageId: 'tea');

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const HistoryScreen(),
          platform: TargetPlatform.android,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Özet & Analiz 📊'), findsOneWidget);
      expect(find.text('Son 7 Günlük Tüketim'), findsOneWidget);
      expect(find.text('Günlük Ortalama'), findsOneWidget);
      expect(find.text('Mevcut Seri'), findsOneWidget);
      expect(find.text('Başarılar & Rozetler'), findsOneWidget);

      // Verify badges section toggle
      await tester.tap(find.text('Başarılar & Rozetler'));
      await tester.pumpAndSettle();

      // Re-expand badges
      await tester.tap(find.text('Başarılar & Rozetler'));
      await tester.pumpAndSettle();

      // Verify badge detail modal on tap
      final badgeCard = find.text('İlk Yudum');
      if (badgeCard.evaluate().isNotEmpty) {
        await tester.tap(badgeCard);
        await tester.pumpAndSettle();
        // Close badge detail sheet
        final tamamBtn = find.text('Tamam');
        if (tamamBtn.evaluate().isNotEmpty) {
          await tester.tap(tamamBtn);
          await tester.pumpAndSettle();
        }
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Alarms Screen (Add/Edit Dialog, Empty View, Sound preview)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const AlarmsScreen(),
          platform: TargetPlatform.android,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hatırlatıcı Alarmlar ⏰'), findsOneWidget);
      expect(find.text('Kayıtlı alarm bulunmuyor.'), findsOneWidget);

      // Tap + button to open Add Alarm Dialog
      final addAlarmBtn = find.byIcon(Icons.add);
      expect(addAlarmBtn, findsOneWidget);
      await tester.tap(addAlarmBtn);
      await tester.pumpAndSettle();

      expect(find.text('Yeni Alarm Ekle ⏰'), findsOneWidget);
      expect(find.text('Alarm Sesi Seçin 🎵'), findsOneWidget);

      // Tap Kaydet button
      final saveBtn = find.text('Kaydet');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify that alarm was added to list
      expect(provider.alarms.length, 1);
      expect(find.text('Kayıtlı alarm bulunmuyor.'), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Settings Screen (Android features, iOS features, Goal calculation, Reset Dialog)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();

      // Test Android Settings Screen
      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const SettingsScreen(),
          platform: TargetPlatform.android,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ayarlar ⚙️'), findsOneWidget);
      expect(find.text('Görünüm & Efektler 🎨'), findsOneWidget);
      expect(find.text('Günlük Su Hedefi 🎯'), findsOneWidget);
      expect(find.text('Profil Bilgilerini Güncelle'), findsOneWidget);
      expect(find.text('Bildirim ve Alarm Ayarları'), findsOneWidget);
      expect(find.text('Gün Sonu Özet Bildirimi'), findsOneWidget);
      expect(find.text('Hızlı Su Ekleme Miktarları'), findsOneWidget);

      // Verify Android card is present
      expect(find.text('Android Hızlı Kontroller 🤖'), findsOneWidget);
      expect(find.text('⚡ Hızlı Ayarlar Kutucuğu'), findsOneWidget);
      expect(find.text('Canlı İlerleme Bildirimi'), findsOneWidget);

      // Scroll down to test danger zone
      final resetBtn = find.text('Tüm Verileri Sıfırla');
      await tester.scrollUntilVisible(
        resetBtn,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(resetBtn, findsOneWidget);
      await tester.tap(resetBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // Warning dialog appears
      expect(find.text('Verileri Sıfırla?'), findsOneWidget);
      expect(find.text('Devam Et ➡️'), findsOneWidget);
      await tester.tap(find.text('Vazgeç'));
      await tester.pump(const Duration(milliseconds: 300));

      // Test iOS Settings Screen
      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const SettingsScreen(),
          platform: TargetPlatform.iOS,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verify iOS card is present on iOS
      expect(find.text('iOS & Apple Özellikleri 🍏'), findsOneWidget);
      expect(find.text('Apple Sağlık (HealthKit)'), findsOneWidget);
      expect(find.text('Siri ile Sesli Komut'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('6. AlarmActiveScreen renders pulsating animation and actions cleanly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const AlarmActiveScreen(),
          platform: TargetPlatform.android,
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Su Zamanı'), findsOneWidget);
      expect(find.text('Su İçtim'), findsOneWidget);
      expect(find.text('+250 ml'), findsOneWidget);

      // Tap giant button (Su İçtim) within 5 seconds -> triggers anti-cheat warning
      await tester.tap(find.text('Su İçtim'));
      await tester.pump(const Duration(milliseconds: 200));

      // Assert full-screen warning UI elements appear
      expect(find.text('HIZLI ONAY KORUMASI'), findsOneWidget);
      expect(find.text('Suyu Gerçekten İçtiniz mi?'), findsOneWidget);
      expect(find.text('Sistemi geçiştirmek için suyu içmeden bastınız!'), findsOneWidget);
      expect(find.text('Lütfen suyunuzu içiniz.'), findsOneWidget);

      // Tap 'Alarm Ekranına Dön' to test navigation back
      await tester.tap(find.text('Alarm Ekranına Dön'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Su Zamanı'), findsOneWidget);
      expect(find.text('Su İçtim'), findsOneWidget);

      // Re-trigger warning
      await tester.tap(find.text('Su İçtim'));
      await tester.pump(const Duration(milliseconds: 200));

      // Advance clock by 5 seconds to complete countdown
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text('Su içme süresi tamamlandı ✅'), findsOneWidget);
      final confirmBtn = find.text('Şimdi Suyumu İçtim (+250 ml)');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('7. Main Navigation Shell switches tabs cleanly across all 4 screens in Dark Mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = WaterProvider();
      provider.updateProfile(gender: 'Erkek', age: 25, weight: 70);

      await tester.pumpWidget(
        createTestApp(
          provider: provider,
          child: const MainNavigationLayout(),
          platform: TargetPlatform.android,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Bottom bar tabs: Panel, Günlük, Alarmlar, Ayarlar
      expect(find.text('Panel'), findsOneWidget);
      expect(find.text('Günlük'), findsOneWidget);
      expect(find.text('Alarmlar'), findsOneWidget);
      expect(find.text('Ayarlar'), findsOneWidget);

      // Switch to Günlük (History) tab
      await tester.tap(find.text('Günlük'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Özet & Analiz 📊'), findsOneWidget);

      // Switch to Alarmlar (Alarms) tab
      await tester.tap(find.text('Alarmlar'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Hatırlatıcı Alarmlar ⏰'), findsOneWidget);

      // Switch to Ayarlar (Settings) tab
      await tester.tap(find.text('Ayarlar'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Ayarlar ⚙️'), findsOneWidget);

      // Switch back to Panel (Dashboard)
      await tester.tap(find.text('Panel'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Merhaba 👋'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
