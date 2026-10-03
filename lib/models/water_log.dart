import 'beverage_type.dart';

class WaterLog {
  final String id;
  final DateTime timestamp;
  final int amountMl; // Effective water hydration amount (in ml)
  final int rawAmountMl; // Raw beverage volume logged (in ml)
  final String beverageId; // 'water', 'tea', 'coffee', etc.

  WaterLog({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    int? rawAmountMl,
    this.beverageId = 'water',
  }) : rawAmountMl = rawAmountMl ?? amountMl;

  BeverageType get beverage => BeverageType.fromId(beverageId);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'amountMl': amountMl,
      'rawAmountMl': rawAmountMl,
      'beverageId': beverageId,
    };
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    final amount = json['amountMl'] as int;
    return WaterLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      amountMl: amount,
      rawAmountMl: (json['rawAmountMl'] as int?) ?? amount,
      beverageId: (json['beverageId'] as String?) ?? 'water',
    );
  }
}
