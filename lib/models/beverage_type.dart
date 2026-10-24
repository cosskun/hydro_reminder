class BeverageType {
  final String id;
  final String name;
  final String emoji;
  final double hydrationFactor; // e.g. 1.0 = 100%, 0.7 = 70%
  final String description;

  const BeverageType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.hydrationFactor,
    required this.description,
  });

  String get icon => emoji;

  String localizedName(String lang) {
    if (lang == 'en') {
      switch (id) {
        case 'water':
          return 'Water';
        case 'mineral_water':
          return 'Sparkling Water';
        case 'tea':
          return 'Tea & Herbal Tea';
        case 'coffee':
          return 'Coffee';
        case 'juice':
          return 'Fruit Juice';
        case 'milk':
          return 'Milk & Ayran';
        default:
          return name;
      }
    }
    return name;
  }

  String localizedDescription(String lang) {
    if (lang == 'en') {
      switch (id) {
        case 'water':
          return '100% Pure Hydration';
        case 'mineral_water':
          return '100% Mineral Water';
        case 'tea':
          return '85% Hydration';
        case 'coffee':
          return '70% Hydration';
        case 'juice':
          return '80% Hydration';
        case 'milk':
          return '90% Hydration';
        default:
          return description;
      }
    }
    return description;
  }

  static const List<BeverageType> all = [
    BeverageType(
      id: 'water',
      name: 'Su',
      emoji: '💧',
      hydrationFactor: 1.0,
      description: '%100 Saf Hidrasyon',
    ),
    BeverageType(
      id: 'mineral_water',
      name: 'Maden Suyu',
      emoji: '🧊',
      hydrationFactor: 1.0,
      description: '%100 Mineralli Su',
    ),
    BeverageType(
      id: 'tea',
      name: 'Çay & Bitki Çayı',
      emoji: '🍵',
      hydrationFactor: 0.85,
      description: '%85 Hidrasyon',
    ),
    BeverageType(
      id: 'coffee',
      name: 'Kahve',
      emoji: '☕',
      hydrationFactor: 0.70,
      description: '%70 Hidrasyon',
    ),
    BeverageType(
      id: 'juice',
      name: 'Meyve Suyu',
      emoji: '🥤',
      hydrationFactor: 0.80,
      description: '%80 Hidrasyon',
    ),
    BeverageType(
      id: 'milk',
      name: 'Süt & Ayran',
      emoji: '🥛',
      hydrationFactor: 0.90,
      description: '%90 Hidrasyon',
    ),
  ];

  static BeverageType fromId(String id) {
    return all.firstWhere(
      (b) => b.id == id,
      orElse: () => all.first, // default to water
    );
  }
}
