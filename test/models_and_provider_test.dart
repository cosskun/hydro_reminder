import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydro_reminder/models/badge_item.dart';
import 'package:hydro_reminder/models/beverage_type.dart';
import 'package:hydro_reminder/models/water_log.dart';
import 'package:hydro_reminder/providers/water_provider.dart';
import 'package:hydro_reminder/services/review_service.dart';
import 'package:hydro_reminder/services/sound_service.dart';
import 'package:hydro_reminder/services/storage_service.dart';
import 'package:hydro_reminder/l10n/app_translations.dart';

void main() {
  group('BeverageType Tests', () {
    test('Calculates correct effective hydration for different beverages', () {
      final water = BeverageType.fromId('water');
      expect(water.hydrationFactor, 1.0);
      expect((200 * water.hydrationFactor).round(), 200);

      final coffee = BeverageType.fromId('coffee');
      expect(coffee.hydrationFactor, 0.70);
      expect((300 * coffee.hydrationFactor).round(), 210);

      final tea = BeverageType.fromId('tea');
      expect(tea.hydrationFactor, 0.85);
      expect((200 * tea.hydrationFactor).round(), 170);

      final mineralWater = BeverageType.fromId('mineral_water');
      expect(mineralWater.hydrationFactor, 1.0);
      expect((200 * mineralWater.hydrationFactor).round(), 200);
    });

    test('Falls back to default water when unknown id is passed', () {
      final unknown = BeverageType.fromId('unknown_id');
      expect(unknown.id, 'water');
      expect(unknown.hydrationFactor, 1.0);
    });
  });

  group('WaterLog Model Tests', () {
    test('Correctly serializes and deserializes with beverageId and rawAmountMl', () {
      final log = WaterLog(
        id: '12345',
        timestamp: DateTime(2026, 9, 22, 14, 30),
        amountMl: 210,
        rawAmountMl: 300,
        beverageId: 'coffee',
      );

      expect(log.beverage.name, 'Kahve');
      expect(log.beverage.emoji, '☕');
      expect(log.amountMl, 210);
      expect(log.rawAmountMl, 300);

      final json = log.toJson();
      final fromJson = WaterLog.fromJson(json);

      expect(fromJson.id, '12345');
      expect(fromJson.amountMl, 210);
      expect(fromJson.rawAmountMl, 300);
      expect(fromJson.beverageId, 'coffee');
      expect(fromJson.beverage.name, 'Kahve');
    });

    test('Backward compatibility: defaults rawAmountMl to amountMl and beverageId to water', () {
      final legacyJson = {
        'id': 'legacy_1',
        'timestamp': DateTime(2026, 9, 22, 10, 0).toIso8601String(),
        'amountMl': 250,
      };

      final log = WaterLog.fromJson(legacyJson);
      expect(log.amountMl, 250);
      expect(log.rawAmountMl, 250);
      expect(log.beverageId, 'water');
      expect(log.beverage.name, 'Su');
    });
  });

  group('BadgeItem Model Tests', () {
    test('Contains all 9 defined achievements', () {
      final definitions = BadgeItem.definitions;
      expect(definitions.length, 9);
      final ids = definitions.map((b) => b.id).toList();
      expect(ids.contains('first_drop'), isTrue);
      expect(ids.contains('streak_3'), isTrue);
      expect(ids.contains('streak_7'), isTrue);
      expect(ids.contains('streak_30'), isTrue);
      expect(ids.contains('early_bird'), isTrue);
      expect(ids.contains('night_shield'), isTrue);
      expect(ids.contains('ocean_50l'), isTrue);
      expect(ids.contains('ocean_100l'), isTrue);
      expect(ids.contains('beverage_guru'), isTrue);
    });
  });

  group('ReviewService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('shouldPromptReview returns true initially for unrated user', () async {
      final service = ReviewService();
      expect(await service.hasRated(), isFalse);
      expect(await service.shouldPromptReview(), isTrue);
    });

    test('markAsRated permanently suppresses future review prompts', () async {
      final service = ReviewService();
      await service.markAsRated();
      expect(await service.hasRated(), isTrue);
      expect(await service.shouldPromptReview(), isFalse);
    });

    test('checkAndPromptIfEligible triggers only when streak >= 3 or badge unlocked', () async {
      final service = ReviewService();
      // Streak < 3 and no badge -> not eligible
      final notEligible = await service.checkAndPromptIfEligible(streak: 2, isNewBadgeUnlocked: false);
      expect(notEligible, isFalse);

      // Streak >= 3 -> eligible
      final eligibleStreak = await service.checkAndPromptIfEligible(streak: 3, isNewBadgeUnlocked: false);
      expect(eligibleStreak, isTrue);
    });
  });

  group('Mascot & Multi-language Hydration Status Tests', () {
    test('Default vitality mascot returns expected emojis and messages', () {
      final s0 = WaterProvider.getHydrationStatus(0.0);
      expect(s0['emoji'], '🥱');
      expect(s0['message'], 'Güne susuz başladın! Hemen bir bardak su al.');

      // 1 or 2 glasses of water (e.g. 21% / 400ml) immediately switches to step 1
      final s20 = WaterProvider.getHydrationStatus(0.21);
      expect(s20['emoji'], '🙂');
      expect(s20['message'], 'İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun.');

      final s100 = WaterProvider.getHydrationStatus(1.0);
      expect(s100['emoji'], '🥳');
      expect(s100['message'], 'Tebrikler! Günlük su hedefini tamamladın!');
    });

    test('Cat mascot returns cat-specific emojis across hydration stages', () {
      expect(WaterProvider.getHydrationStatus(0.0, mascotType: 'cat')['emoji'], '😿');
      expect(WaterProvider.getHydrationStatus(0.20, mascotType: 'cat')['emoji'], '🐱');
      expect(WaterProvider.getHydrationStatus(0.50, mascotType: 'cat')['emoji'], '😺');
      expect(WaterProvider.getHydrationStatus(0.85, mascotType: 'cat')['emoji'], '😻');
      expect(WaterProvider.getHydrationStatus(1.05, mascotType: 'cat')['emoji'], '🦁');
    });

    test('Penguin mascot returns penguin-specific emojis across hydration stages', () {
      expect(WaterProvider.getHydrationStatus(0.0, mascotType: 'penguin')['emoji'], '🧊');
      expect(WaterProvider.getHydrationStatus(0.20, mascotType: 'penguin')['emoji'], '🐧');
      expect(WaterProvider.getHydrationStatus(0.50, mascotType: 'penguin')['emoji'], '🦭');
      expect(WaterProvider.getHydrationStatus(0.85, mascotType: 'penguin')['emoji'], '🏄');
      expect(WaterProvider.getHydrationStatus(1.05, mascotType: 'penguin')['emoji'], '👑');
    });

    test('Plant mascot returns plant-specific emojis across hydration stages', () {
      expect(WaterProvider.getHydrationStatus(0.0, mascotType: 'plant')['emoji'], '🥀');
      expect(WaterProvider.getHydrationStatus(0.20, mascotType: 'plant')['emoji'], '🌱');
      expect(WaterProvider.getHydrationStatus(0.50, mascotType: 'plant')['emoji'], '🌿');
      expect(WaterProvider.getHydrationStatus(0.85, mascotType: 'plant')['emoji'], '🪴');
      expect(WaterProvider.getHydrationStatus(1.05, mascotType: 'plant')['emoji'], '🌳');
    });

    test('English language returns accurate English messages for mascots', () {
      final enVitality = WaterProvider.getHydrationStatus(1.0, mascotType: 'vitality', lang: 'en');
      expect(enVitality['message'], 'Congratulations! You reached your daily goal!');

      final enCat = WaterProvider.getHydrationStatus(0.0, mascotType: 'cat', lang: 'en');
      expect(enCat['message'], 'Meow! So thirsty, could you spare a sip of water?');
    });
  });

  group('AppTranslations Tests', () {
    test('Translates keys correctly in both Turkish and English', () {
      expect(AppTranslations.get('app_name', lang: 'tr'), 'HydroSoft');
      expect(AppTranslations.get('app_name', lang: 'en'), 'HydroSoft');

      expect(AppTranslations.get('tab_dashboard', lang: 'tr'), 'Ana Sayfa');
      expect(AppTranslations.get('tab_dashboard', lang: 'en'), 'Home');

      expect(AppTranslations.get('mascot_cat', lang: 'tr'), 'Sevimli Kedi');
      expect(AppTranslations.get('mascot_cat', lang: 'en'), 'Playful Cat');

      expect(AppTranslations.get('theme_glass', lang: 'tr'), 'iOS Buzlu Cam');
      expect(AppTranslations.get('theme_glass', lang: 'en'), 'iOS Frosted Glass');
    });
  });

  group('Nature Sounds & SoundService Tests', () {
    test('Contains meditation nature presets (Gentle Rain, River Stream, Tibetan Bowl)', () {
      final names = SoundService.presetSounds.map((p) => p.name).toList();
      expect(names.contains('Huzurlu Yağmur'), isTrue);
      expect(names.contains('Nehir Akıntısı'), isTrue);
      expect(names.contains('Tibet Kasesi & Zen'), isTrue);

      final paths = SoundService.presetSounds.map((p) => p.path).toList();
      expect(paths.contains('sounds/sound_gentle_rain.wav'), isTrue);
      expect(paths.contains('sounds/sound_river_stream.wav'), isTrue);
      expect(paths.contains('sounds/sound_tibetan_bowl.wav'), isTrue);
    });
  });

  group('StorageService Mascot, Theme & Language Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService().init();
    });

    test('Saves and loads custom mascot type', () async {
      final storage = StorageService();
      expect(await storage.getMascotType(), 'vitality');
      await storage.saveMascotType('penguin');
      expect(await storage.getMascotType(), 'penguin');
    });

    test('Saves and loads custom widget theme', () async {
      final storage = StorageService();
      expect(await storage.getWidgetTheme(), 'ocean');
      await storage.saveWidgetTheme('glass');
      expect(await storage.getWidgetTheme(), 'glass');
    });

    test('Saves and loads language setting', () async {
      final storage = StorageService();
      expect(await storage.getLanguage(), 'tr');
      await storage.saveLanguage('en');
      expect(await storage.getLanguage(), 'en');
    });
  });
}
