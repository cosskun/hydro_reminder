import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydro_reminder/models/badge_item.dart';
import 'package:hydro_reminder/models/beverage_type.dart';
import 'package:hydro_reminder/models/mascot_model.dart';
import 'package:hydro_reminder/models/water_log.dart';
import 'package:hydro_reminder/providers/water_provider.dart';
import 'package:hydro_reminder/services/review_service.dart';
import 'package:hydro_reminder/services/sound_service.dart';
import 'package:hydro_reminder/services/storage_service.dart';
import 'package:hydro_reminder/l10n/app_translations.dart';
import 'package:hydro_reminder/config/app_theme.dart';

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
      final s0 = WaterProvider.getHydrationStatus(0.0, mascotType: 'vitality');
      expect(s0['emoji'], '🥱');
      expect(s0['message'], 'Güne susuz başladın! Hemen bir bardak su al.');

      // 1 or 2 glasses of water (e.g. 21% / 400ml) immediately switches to step 1
      final s20 = WaterProvider.getHydrationStatus(0.21, mascotType: 'vitality');
      expect(s20['emoji'], '🙂');
      expect(s20['message'], 'İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun.');

      final s100 = WaterProvider.getHydrationStatus(1.0, mascotType: 'vitality');
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
      expect(enCat['message'], 'Purrr... Glass is empty, feeling so drained!');
      expect(enCat['routineMessage'], 'Meow! So thirsty, could you spare a sip of water?');
    });
  });

  group('AppTranslations Tests', () {
    test('Translates keys correctly in both Turkish and English', () {
      expect(AppTranslations.get('app_name', lang: 'tr'), 'HydroSoft');
      expect(AppTranslations.get('app_name', lang: 'en'), 'HydroSoft');

      expect(AppTranslations.get('tab_dashboard', lang: 'tr'), 'Ana Sayfa');
      expect(AppTranslations.get('tab_dashboard', lang: 'en'), 'Home');

      expect(AppTranslations.get('mascot_cat', lang: 'tr'), 'Luna (Kedi)');
      expect(AppTranslations.get('mascot_cat', lang: 'en'), 'Luna (Cat)');

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
      expect(await storage.getMascotType(), 'cat');
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

    test('Saves and loads useMascotTheme and customThemePreset', () async {
      final storage = StorageService();
      expect(await storage.getUseMascotTheme(), isTrue);
      await storage.saveUseMascotTheme(false);
      expect(await storage.getUseMascotTheme(), isFalse);

      expect(await storage.getCustomThemePreset(), 'ocean');
      await storage.saveCustomThemePreset('panda');
      expect(await storage.getCustomThemePreset(), 'panda');
    });
  });

  group('Mascot Color Themes & Dynamic Theming Tests', () {
    test('AppTheme defines palettes for all 5 mascots and original ocean', () {
      expect(AppTheme.palettes.containsKey('ocean'), isTrue);
      expect(AppTheme.palettes.containsKey('cat'), isTrue);
      expect(AppTheme.palettes.containsKey('dog'), isTrue);
      expect(AppTheme.palettes.containsKey('penguin'), isTrue);
      expect(AppTheme.palettes.containsKey('panda'), isTrue);
      expect(AppTheme.palettes.containsKey('squirrel'), isTrue);

      for (final palette in AppTheme.palettes.values) {
        expect(palette.nameTr.isNotEmpty, isTrue);
        expect(palette.nameEn.isNotEmpty, isTrue);
        expect(palette.emoji.isNotEmpty, isTrue);
        expect(palette.waterGradientLight.length, greaterThanOrEqualTo(2));
        expect(palette.waterGradientDark.length, greaterThanOrEqualTo(2));
      }
    });

    test('AppTheme.getTheme generates valid light and dark ThemeData with expected colors', () {
      final pandaLight = AppTheme.getTheme('panda', isDark: false);
      expect(pandaLight.brightness, Brightness.light);
      expect(pandaLight.colorScheme.primary, AppTheme.palettes['panda']!.primary);

      final catDark = AppTheme.getTheme('cat', isDark: true);
      expect(catDark.brightness, Brightness.dark);
      expect(catDark.colorScheme.primary, AppTheme.palettes['cat']!.primaryDark);

      final fallback = AppTheme.getTheme('unknown_preset', isDark: false);
      expect(fallback.colorScheme.primary, AppTheme.palettes['ocean']!.primary);
    });

    test('WaterProvider effectiveThemePreset reflects active mascot when useMascotTheme is true', () async {
      SharedPreferences.setMockInitialValues({});
      await StorageService().init();
      final provider = WaterProvider();
      await provider.init();

      expect(provider.useMascotTheme, isTrue);

      await provider.updateMascotType('cat');
      expect(provider.effectiveThemePreset, 'cat');

      await provider.updateMascotType('dog');
      expect(provider.effectiveThemePreset, 'dog');

      await provider.updateMascotType('penguin');
      expect(provider.effectiveThemePreset, 'penguin');

      await provider.updateMascotType('panda');
      expect(provider.effectiveThemePreset, 'panda');

      await provider.updateMascotType('squirrel');
      expect(provider.effectiveThemePreset, 'squirrel');
    });

    test('WaterProvider effectiveThemePreset preserves custom theme when useMascotTheme is false', () async {
      SharedPreferences.setMockInitialValues({});
      await StorageService().init();
      final provider = WaterProvider();
      await provider.init();

      await provider.updateUseMascotTheme(false);
      await provider.updateCustomThemePreset('ocean');

      // Mascot is panda, but theme is locked to ocean
      await provider.updateMascotType('panda');
      expect(provider.useMascotTheme, isFalse);
      expect(provider.effectiveThemePreset, 'ocean');

      // Changing mascot does not affect theme when auto-theme is off
      await provider.updateMascotType('cat');
      expect(provider.effectiveThemePreset, 'ocean');

      // Re-enabling auto theme immediately syncs to current mascot (cat)
      await provider.updateUseMascotTheme(true);
      expect(provider.effectiveThemePreset, 'cat');
    });
  });

  group('Luna (Cat) Mascot 10 States & Asset Tests', () {
    test('All 10 states resolve to valid cat assets that exist on disk', () {
      final expectedAssets = {
        MascotState.morning: 'assets/mascots/cat_morning.png',
        MascotState.workFocus: 'assets/mascots/cat_work_focus.png',
        MascotState.lunch: 'assets/mascots/cat_lunch.png',
        MascotState.afternoonSlump: 'assets/mascots/cat_afternoon_slump.png',
        MascotState.workout: 'assets/mascots/cat_workout.png',
        MascotState.evening: 'assets/mascots/cat_evening.png',
        MascotState.bedtime: 'assets/mascots/cat_bedtime.png',
        MascotState.goalReached: 'assets/mascots/cat_goal_reached.png',
        MascotState.thirsty: 'assets/mascots/cat_thirsty.png',
        MascotState.streakFire: 'assets/mascots/cat_streak_fire.png',
      };

      for (final state in MascotState.values) {
        final expected = expectedAssets[state]!;
        final actual = 'assets/mascots/cat_${state.assetSuffix}.png';
        expect(actual, expected);
        expect(File(actual).existsSync(), isTrue, reason: '$actual should exist on disk');
      }
    });

    test('resolveCurrentState maps dynamic energy ladder and contextual triggers', () {
      // 1. Initial Morning Energy (< 25%)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.20,
          now: DateTime(2026, 1, 1, 10, 0),
        ),
        MascotState.morning,
      );
      // 2. Focused Desk Work Energy (25% - 50%)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.35,
          now: DateTime(2026, 1, 1, 10, 0),
        ),
        MascotState.workFocus,
      );
      // 3. Balanced Midday Freshness (50% - 70%)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.60,
          now: DateTime(2026, 1, 1, 12, 30),
        ),
        MascotState.lunch,
      );
      // 4. Afternoon Slump when hydration is behind (< 50% between 14:00-16:30)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.30,
          now: DateTime(2026, 1, 1, 15, 0),
        ),
        MascotState.afternoonSlump,
      );
      // 5. High Workout Stamina (70% - 88%)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.75,
          now: DateTime(2026, 1, 1, 17, 30),
        ),
        MascotState.workout,
      );
      // 6. Evening Wind Down (88% - 99%)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.90,
          now: DateTime(2026, 1, 1, 20, 0),
        ),
        MascotState.evening,
      );
      // 7. Bedtime wrap up (21:30+)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.50,
          now: DateTime(2026, 1, 1, 22, 30),
        ),
        MascotState.bedtime,
      );
      // 8. Goal Reached (100%+)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 1.0,
          now: DateTime(2026, 1, 1, 15, 0),
        ),
        MascotState.goalReached,
      );
      // 9. Zero thirst
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.0,
          now: DateTime(2026, 1, 1, 15, 0),
        ),
        MascotState.thirsty,
      );
      // 10. Superhero Streak Fire (Streak >= 3 and 75%+)
      expect(
        MascotResolver.resolveCurrentState(
          percentage: 0.80,
          streakDays: 4,
          now: DateTime(2026, 1, 1, 12, 0),
        ),
        MascotState.streakFire,
      );
    });
  });

  group('Buddy (Brown Poodle Dog) 10 States & Asset Tests', () {
    test('All 10 states resolve to valid dog assets that exist on disk', () {
      final expectedAssets = {
        MascotState.morning: 'assets/mascots/dog_morning.png',
        MascotState.workFocus: 'assets/mascots/dog_work_focus.png',
        MascotState.lunch: 'assets/mascots/dog_lunch.png',
        MascotState.afternoonSlump: 'assets/mascots/dog_afternoon_slump.png',
        MascotState.workout: 'assets/mascots/dog_workout.png',
        MascotState.evening: 'assets/mascots/dog_evening.png',
        MascotState.bedtime: 'assets/mascots/dog_bedtime.png',
        MascotState.goalReached: 'assets/mascots/dog_goal_reached.png',
        MascotState.thirsty: 'assets/mascots/dog_thirsty.png',
        MascotState.streakFire: 'assets/mascots/dog_streak_fire.png',
      };

      for (final state in MascotState.values) {
        final expected = expectedAssets[state]!;
        final actual = 'assets/mascots/dog_${state.assetSuffix}.png';
        expect(actual, expected);
        expect(File(actual).existsSync(), isTrue, reason: '$actual should exist on disk');
      }
    });
  });

  group('Pip (Polar Penguin) 10 States & Asset Tests', () {
    test('All 10 states resolve to valid penguin assets that exist on disk', () {
      final expectedAssets = {
        MascotState.morning: 'assets/mascots/penguin_morning.png',
        MascotState.workFocus: 'assets/mascots/penguin_work_focus.png',
        MascotState.lunch: 'assets/mascots/penguin_lunch.png',
        MascotState.afternoonSlump: 'assets/mascots/penguin_afternoon_slump.png',
        MascotState.workout: 'assets/mascots/penguin_workout.png',
        MascotState.evening: 'assets/mascots/penguin_evening.png',
        MascotState.bedtime: 'assets/mascots/penguin_bedtime.png',
        MascotState.goalReached: 'assets/mascots/penguin_goal_reached.png',
        MascotState.thirsty: 'assets/mascots/penguin_thirsty.png',
        MascotState.streakFire: 'assets/mascots/penguin_streak_fire.png',
      };

      for (final state in MascotState.values) {
        final expected = expectedAssets[state]!;
        final actual = 'assets/mascots/penguin_${state.assetSuffix}.png';
        expect(actual, expected);
        expect(File(actual).existsSync(), isTrue, reason: '$actual should exist on disk');
      }
    });
  });

  group('Bobo (Zen Panda) 10 States & Asset Tests', () {
    test('All 10 states resolve to valid panda assets that exist on disk', () {
      final expectedAssets = {
        MascotState.morning: 'assets/mascots/panda_morning.png',
        MascotState.workFocus: 'assets/mascots/panda_work_focus.png',
        MascotState.lunch: 'assets/mascots/panda_lunch.png',
        MascotState.afternoonSlump: 'assets/mascots/panda_afternoon_slump.png',
        MascotState.workout: 'assets/mascots/panda_workout.png',
        MascotState.evening: 'assets/mascots/panda_evening.png',
        MascotState.bedtime: 'assets/mascots/panda_bedtime.png',
        MascotState.goalReached: 'assets/mascots/panda_goal_reached.png',
        MascotState.thirsty: 'assets/mascots/panda_thirsty.png',
        MascotState.streakFire: 'assets/mascots/panda_streak_fire.png',
      };

      for (final state in MascotState.values) {
        final expected = expectedAssets[state]!;
        final actual = 'assets/mascots/panda_${state.assetSuffix}.png';
        expect(actual, expected);
        expect(File(actual).existsSync(), isTrue, reason: '$actual should exist on disk');
      }
    });
  });

  group('Nutty (Red Squirrel) 10 States & Asset Tests', () {
    test('All 10 states resolve to valid squirrel assets that exist on disk', () {
      final expectedAssets = {
        MascotState.morning: 'assets/mascots/squirrel_morning.png',
        MascotState.workFocus: 'assets/mascots/squirrel_work_focus.png',
        MascotState.lunch: 'assets/mascots/squirrel_lunch.png',
        MascotState.afternoonSlump: 'assets/mascots/squirrel_afternoon_slump.png',
        MascotState.workout: 'assets/mascots/squirrel_workout.png',
        MascotState.evening: 'assets/mascots/squirrel_evening.png',
        MascotState.bedtime: 'assets/mascots/squirrel_bedtime.png',
        MascotState.goalReached: 'assets/mascots/squirrel_goal_reached.png',
        MascotState.thirsty: 'assets/mascots/squirrel_thirsty.png',
        MascotState.streakFire: 'assets/mascots/squirrel_streak_fire.png',
      };

      for (final state in MascotState.values) {
        final expected = expectedAssets[state]!;
        final actual = 'assets/mascots/squirrel_${state.assetSuffix}.png';
        expect(actual, expected);
        expect(File(actual).existsSync(), isTrue, reason: '$actual should exist on disk');
      }
    });
  });

  group('Hydration Energy Ladder (Cat, Dog, Penguin, Panda & Squirrel 5 Tiers) Tests', () {
    test('All 5 Cat, Dog, Penguin, Panda and Squirrel energy ladder image assets exist on disk', () {
      final energyTiers = [0, 25, 50, 75, 100];
      for (final step in energyTiers) {
        final catAsset = 'assets/mascots/cat_energy_$step.png';
        expect(File(catAsset).existsSync(), isTrue, reason: '$catAsset must exist');

        final dogAsset = 'assets/mascots/dog_energy_$step.png';
        expect(File(dogAsset).existsSync(), isTrue, reason: '$dogAsset must exist');

        final penguinAsset = 'assets/mascots/penguin_energy_$step.png';
        expect(File(penguinAsset).existsSync(), isTrue, reason: '$penguinAsset must exist');

        final pandaAsset = 'assets/mascots/panda_energy_$step.png';
        expect(File(pandaAsset).existsSync(), isTrue, reason: '$pandaAsset must exist');

        final squirrelAsset = 'assets/mascots/squirrel_energy_$step.png';
        expect(File(squirrelAsset).existsSync(), isTrue, reason: '$squirrelAsset must exist');
      }
    });

    test('MascotEnergyLadder accurately resolves tiers and dialogues across 0-100%', () {
      expect(MascotEnergyLadder.getTier(0.0), MascotEnergyTier.energy0);
      expect(MascotEnergyLadder.getTier(0.20), MascotEnergyTier.energy25);
      expect(MascotEnergyLadder.getTier(0.50), MascotEnergyTier.energy50);
      expect(MascotEnergyLadder.getTier(0.75), MascotEnergyTier.energy75);
      expect(MascotEnergyLadder.getTier(1.00), MascotEnergyTier.energy100);

      final cat0 = MascotEnergyLadder.getDialogue(
        mascotId: 'cat',
        tier: MascotEnergyTier.energy0,
        isEn: false,
      );
      expect(cat0['title'], contains('Sıfır Enerji'));

      final dog100 = MascotEnergyLadder.getDialogue(
        mascotId: 'dog',
        tier: MascotEnergyTier.energy100,
        isEn: false,
      );
      expect(dog100['title'], contains('Tam Şarj'));

      final penguin0 = MascotEnergyLadder.getDialogue(
        mascotId: 'penguin',
        tier: MascotEnergyTier.energy0,
        isEn: false,
      );
      expect(penguin0['title'], contains('Buzlar Eridi'));

      final penguin100 = MascotEnergyLadder.getDialogue(
        mascotId: 'penguin',
        tier: MascotEnergyTier.energy100,
        isEn: false,
      );
      expect(penguin100['title'], contains('Kutup Şampiyonu'));

      final panda0 = MascotEnergyLadder.getDialogue(
        mascotId: 'panda',
        tier: MascotEnergyTier.energy0,
        isEn: false,
      );
      expect(panda0['title'], contains('Bambu Kurudu'));

      final panda100 = MascotEnergyLadder.getDialogue(
        mascotId: 'panda',
        tier: MascotEnergyTier.energy100,
        isEn: false,
      );
      expect(panda100['title'], contains('Zen Ustası'));

      final squirrel0 = MascotEnergyLadder.getDialogue(
        mascotId: 'squirrel',
        tier: MascotEnergyTier.energy0,
        isEn: false,
      );
      expect(squirrel0['title'], contains('Fındıklar Kurudu'));

      final squirrel100 = MascotEnergyLadder.getDialogue(
        mascotId: 'squirrel',
        tier: MascotEnergyTier.energy100,
        isEn: false,
      );
      expect(squirrel100['title'], contains('Orman Şampiyonu'));
    });

    test('Energy ladder has absolute priority on dashboard even during bedtime hours (22:00+)', () {
      final nightTime = DateTime(2026, 1, 1, 23, 15);

      // At 24% intake during bedtime hours (Cat)
      final status24 = WaterProvider.getHydrationStatus(
        0.24,
        mascotType: 'cat',
        now: nightTime,
      );
      expect(status24['imageAsset'], 'assets/mascots/cat_energy_25.png');
      expect(status24['routineImageAsset'], 'assets/mascots/cat_bedtime.png');
      expect(status24['title'], contains('İlk Yudum'));
      expect(status24['routineTitle'], 'Hadi son bir yudum!');

      // At 24% intake during bedtime hours (Penguin)
      final penguinStatus24 = WaterProvider.getHydrationStatus(
        0.24,
        mascotType: 'penguin',
        now: nightTime,
      );
      expect(penguinStatus24['imageAsset'], 'assets/mascots/penguin_energy_25.png');
      expect(penguinStatus24['routineImageAsset'], 'assets/mascots/penguin_bedtime.png');
      expect(penguinStatus24['title'], contains('İlk Yudum'));
      expect(penguinStatus24['routineTitle'], 'Hadi son bir yudum!');

      // At 24% intake during bedtime hours (Panda)
      final pandaStatus24 = WaterProvider.getHydrationStatus(
        0.24,
        mascotType: 'panda',
        now: nightTime,
      );
      expect(pandaStatus24['imageAsset'], 'assets/mascots/panda_energy_25.png');
      expect(pandaStatus24['routineImageAsset'], 'assets/mascots/panda_bedtime.png');
      expect(pandaStatus24['title'], contains('İlk Yudum'));
      expect(pandaStatus24['routineTitle'], 'Hadi son bir yudum!');

      // At 24% intake during bedtime hours (Squirrel)
      final squirrelStatus24 = WaterProvider.getHydrationStatus(
        0.24,
        mascotType: 'squirrel',
        now: nightTime,
      );
      expect(squirrelStatus24['imageAsset'], 'assets/mascots/squirrel_energy_25.png');
      expect(squirrelStatus24['routineImageAsset'], 'assets/mascots/squirrel_bedtime.png');
      expect(squirrelStatus24['title'], contains('İlk Yudum'));
      expect(squirrelStatus24['routineTitle'], 'Hadi son bir yudum!');

      // At 80% intake during bedtime hours (Energy 75)
      final status80 = WaterProvider.getHydrationStatus(
        0.80,
        mascotType: 'cat',
        now: nightTime,
      );
      expect(status80['imageAsset'], 'assets/mascots/cat_energy_75.png');
      expect(status80['routineImageAsset'], 'assets/mascots/cat_bedtime.png');
      expect(status80['title'], contains('Yüksek Canlılık'));
      expect(status80['routineTitle'], 'Hadi son bir yudum!');

      // At 95% intake during bedtime hours (Energy 100)
      final status95 = WaterProvider.getHydrationStatus(
        0.95,
        mascotType: 'cat',
        now: nightTime,
      );
      expect(status95['imageAsset'], 'assets/mascots/cat_energy_100.png');
      expect(status95['routineImageAsset'], 'assets/mascots/cat_bedtime.png');
      expect(status95['title'], contains('Tam Şarj'));
      expect(status95['routineTitle'], 'Hadi son bir yudum!');
    });
  });

  group('Mascot Preview & Zero-Duplicate State Verification Tests', () {
    test('All animal mascots have 10 distinct, non-repeating routine states and assets', () {
      final animalMascots = ['cat', 'dog', 'penguin', 'panda', 'squirrel'];

      for (final mascotId in animalMascots) {
        final dialogues = MascotState.values.map((state) {
          return MascotResolver.resolveDialogueForState(
            mascotType: mascotId,
            state: state,
            lang: 'tr',
          );
        }).toList();

        // 1. Exactly 10 items
        expect(dialogues.length, 10);

        // 2. All 10 images are distinct (Zero repeating illustrations)
        final imageAssets = dialogues.map((d) => d.imageAsset).toList();
        final uniqueImages = Set.from(imageAssets);
        expect(uniqueImages.length, 10, reason: '$mascotId must have 10 unique routine illustrations');

        // 3. All 10 image files exist on disk
        for (final img in imageAssets) {
          expect(File(img).existsSync(), isTrue, reason: 'Image asset $img must exist on disk');
        }

        // 4. All 10 messages are unique and tailored (Zero repeating text)
        final messages = dialogues.map((d) => d.message).toList();
        final uniqueMessages = Set.from(messages);
        expect(uniqueMessages.length, 10, reason: '$mascotId must have 10 unique messages');

        // 5. English versions are also all unique
        final enDialogues = MascotState.values.map((state) {
          return MascotResolver.resolveDialogueForState(
            mascotType: mascotId,
            state: state,
            lang: 'en',
          );
        }).toList();
        final enMessages = enDialogues.map((d) => d.message).toList();
        expect(Set.from(enMessages).length, 10, reason: '$mascotId must have 10 unique English messages');
      }
    });

    test('All 5 hydration energy tiers have distinct, non-repeating assets and copy', () {
      final animalMascots = ['cat', 'dog', 'penguin', 'panda', 'squirrel'];

      for (final mascotId in animalMascots) {
        final energyDialogues = MascotEnergyTier.values.map((tier) {
          return MascotResolver.resolveDialogueForEnergyTier(
            mascotType: mascotId,
            tier: tier,
            lang: 'tr',
          );
        }).toList();

        // 1. Exactly 5 items
        expect(energyDialogues.length, 5);

        // 2. All 5 images are distinct
        final imageAssets = energyDialogues.map((d) => d.imageAsset).toList();
        expect(Set.from(imageAssets).length, 5, reason: '$mascotId must have 5 unique energy images');

        for (final img in imageAssets) {
          expect(File(img).existsSync(), isTrue, reason: 'Energy asset $img must exist on disk');
        }

        // 3. All 5 titles and messages are distinct
        final titles = energyDialogues.map((d) => d.title).toList();
        expect(Set.from(titles).length, 5);
        final messages = energyDialogues.map((d) => d.message).toList();
        expect(Set.from(messages).length, 5);
      }
    });

    test('MascotResolver.getStateTag produces distinct, descriptive labels for all 10 states', () {
      final trTags = MascotState.values.map((s) => MascotResolver.getStateTag(s, false)).toList();
      expect(Set.from(trTags).length, 10);
      expect(trTags.contains('Sabah Uyanışı'), isTrue);
      expect(trTags.contains('Masa Başı Odaklanma'), isTrue);
      expect(trTags.contains('Öğle Yemeği Molası'), isTrue);
      expect(trTags.contains('Öğleden Sonra Rehaveti & Sitem'), isTrue);
      expect(trTags.contains('Spor & Hareket'), isTrue);
      expect(trTags.contains('Akşam Dinlenmesi'), isTrue);
      expect(trTags.contains('Gece Uykusu & Son Yudum'), isTrue);
      expect(trTags.contains('Günlük Hedef Şampiyonu'), isTrue);
      expect(trTags.contains('Kritik Susuzluk Uyarısı'), isTrue);
      expect(trTags.contains('Seri Ateşi & Süper Kahraman'), isTrue);

      final enTags = MascotState.values.map((s) => MascotResolver.getStateTag(s, true)).toList();
      expect(Set.from(enTags).length, 10);
    });
  });
}
