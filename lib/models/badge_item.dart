class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category; // 'streak' | 'time' | 'volume' | 'beverage' | 'general'
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double currentProgress; // 0.0 to 1.0
  final String progressLabel;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0.0,
    this.progressLabel = '',
  });

  BadgeItem copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? currentProgress,
    String? progressLabel,
  }) {
    return BadgeItem(
      id: id,
      title: title,
      description: description,
      icon: icon,
      category: category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      progressLabel: progressLabel ?? this.progressLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
      'progressLabel': progressLabel,
    };
  }

  factory BadgeItem.fromJson(Map<String, dynamic> json) {
    return BadgeItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '⭐',
      category: json['category'] as String? ?? 'general',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
      progressLabel: json['progressLabel'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BadgeItem &&
        other.id == id &&
        other.title == title &&
        other.isUnlocked == isUnlocked &&
        other.unlockedAt == unlockedAt &&
        other.currentProgress == currentProgress;
  }

  @override
  int get hashCode => Object.hash(id, title, isUnlocked, unlockedAt, currentProgress);

  String localizedTitle(String lang) {
    if (lang == 'en') {
      switch (id) {
        case 'first_drop':
          return 'First Drop';
        case 'streak_3':
          return 'Spark Starter';
        case 'streak_7':
          return 'Streak Master (1 Wk)';
        case 'streak_30':
          return 'Hydration Champion';
        case 'early_bird':
          return 'Early Bird';
        case 'night_shield':
          return 'Night Shield';
        case 'ocean_50l':
          return 'Ocean Explorer (50 L)';
        case 'ocean_100l':
          return 'Hydration Giant (100 L)';
        case 'beverage_guru':
          return 'Beverage Gourmet';
        default:
          return title;
      }
    }
    return title;
  }

  String localizedDescription(String lang) {
    if (lang == 'en') {
      switch (id) {
        case 'first_drop':
          return 'Log your first water intake in the app.';
        case 'streak_3':
          return 'Reach your daily goal 3 days in a row.';
        case 'streak_7':
          return 'Reach your daily goal for 7 consecutive days.';
        case 'streak_30':
          return 'Build a consistent hydration habit for 30 days.';
        case 'early_bird':
          return 'Log your first glass before 08:00 AM.';
        case 'night_shield':
          return 'Complete your hydration target before going to bed.';
        case 'ocean_50l':
          return 'Surpass 50 liters in total cumulative water intake.';
        case 'ocean_100l':
          return 'Reach 100 liters in total cumulative water intake.';
        case 'beverage_guru':
          return 'Log at least 3 different beverage types.';
        default:
          return description;
      }
    }
    return description;
  }

  static const List<BadgeItem> definitions = [
    BadgeItem(
      id: 'first_drop',
      title: 'İlk Yudum',
      description: 'Uygulamada ilk su kaydınızı oluşturun.',
      icon: '⭐',
      category: 'general',
    ),
    BadgeItem(
      id: 'streak_3',
      title: 'Alev Başlangıcı',
      description: '3 gün üst üste günlük hedefinizi tamamlayın.',
      icon: '🔥',
      category: 'streak',
    ),
    BadgeItem(
      id: 'streak_7',
      title: 'Seri Ustası (1 Hafta)',
      description: '7 gün boyunca su hedefinize kesintisiz ulaşın.',
      icon: '⚡',
      category: 'streak',
    ),
    BadgeItem(
      id: 'streak_30',
      title: 'Hidrasyon Şampiyonu',
      description: '30 gün boyunca düzenli su içme alışkanlığı kazanın.',
      icon: '👑',
      category: 'streak',
    ),
    BadgeItem(
      id: 'early_bird',
      title: 'Erkenci Kuş',
      description: 'Sabah 08:00\'den önce ilk bardağınızı kaydedin.',
      icon: '🌅',
      category: 'time',
    ),
    BadgeItem(
      id: 'night_shield',
      title: 'Gece Kalkanı',
      description: 'Uyumadan önce su ihtiyacınızı tamamlayın.',
      icon: '🌙',
      category: 'time',
    ),
    BadgeItem(
      id: 'ocean_50l',
      title: 'Okyanus Kaşifi (50 L)',
      description: 'Toplamda 50 litre su tüketim barajını aşın.',
      icon: '🌊',
      category: 'volume',
    ),
    BadgeItem(
      id: 'ocean_100l',
      title: 'Hidrasyon Devi (100 L)',
      description: 'Toplamda 100 litre kümülatif su tüketin.',
      icon: '🐋',
      category: 'volume',
    ),
    BadgeItem(
      id: 'beverage_guru',
      title: 'İçecek Gurmesi',
      description: 'En az 3 farklı içecek türünü kaydedin.',
      icon: '☕',
      category: 'beverage',
    ),
  ];
}
