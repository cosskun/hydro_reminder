import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_reminder/models/badge_item.dart';
import 'package:hydro_reminder/models/beverage_type.dart';
import 'package:hydro_reminder/models/water_log.dart';

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
}
