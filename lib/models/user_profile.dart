class UserProfile {
  final String gender;
  final int age;
  final double weight;
  final int dailyGoal;

  const UserProfile({
    required this.gender,
    required this.age,
    required this.weight,
    required this.dailyGoal,
  });

  UserProfile copyWith({
    String? gender,
    int? age,
    double? weight,
    int? dailyGoal,
  }) {
    return UserProfile(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'age': age,
      'weight': weight,
      'dailyGoal': dailyGoal,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      gender: json['gender'] as String? ?? 'Erkek',
      age: (json['age'] as num?)?.toInt() ?? 25,
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 2500,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.gender == gender &&
        other.age == age &&
        other.weight == weight &&
        other.dailyGoal == dailyGoal;
  }

  @override
  int get hashCode => Object.hash(gender, age, weight, dailyGoal);
}
