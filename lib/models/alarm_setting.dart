class AlarmSetting {
  final String id;
  final int hour;
  final int minute;
  final bool isEnabled;
  final String label;
  final String soundName;
  final String soundPath;
  final bool isCustomSound;

  AlarmSetting({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.label = 'Su Zamanı',
    this.soundName = 'Çalar Saat & Melodi ⏰',
    this.soundPath = 'assets/sounds/sound_alarm_ring.wav',
    this.isCustomSound = false,
  });

  String get timeFormatted {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
      'label': label,
      'soundName': soundName,
      'soundPath': soundPath,
      'isCustomSound': isCustomSound,
    };
  }

  factory AlarmSetting.fromJson(Map<String, dynamic> json) {
    return AlarmSetting(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      isEnabled: json['isEnabled'] as bool,
      label: json['label'] as String? ?? 'Su Zamanı',
      soundName: json['soundName'] as String? ?? 'Çalar Saat & Melodi ⏰',
      soundPath: json['soundPath'] as String? ?? 'assets/sounds/sound_alarm_ring.wav',
      isCustomSound: json['isCustomSound'] as bool? ?? false,
    );
  }

  AlarmSetting copyWith({
    String? id,
    int? hour,
    int? minute,
    bool? isEnabled,
    String? label,
    String? soundName,
    String? soundPath,
    bool? isCustomSound,
  }) {
    return AlarmSetting(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
      soundName: soundName ?? this.soundName,
      soundPath: soundPath ?? this.soundPath,
      isCustomSound: isCustomSound ?? this.isCustomSound,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlarmSetting &&
        other.id == id &&
        other.hour == hour &&
        other.minute == minute &&
        other.isEnabled == isEnabled &&
        other.label == label &&
        other.soundName == soundName &&
        other.soundPath == soundPath &&
        other.isCustomSound == isCustomSound;
  }

  @override
  int get hashCode => Object.hash(
        id,
        hour,
        minute,
        isEnabled,
        label,
        soundName,
        soundPath,
        isCustomSound,
      );
}
