class UserProfile {
  final double? weight;
  final int? height;
  final int? age;
  final String? sex;
  final String? fitnessGoal;
  final int? workoutsPerWeek;
  final List<String> availableEquipment;
  final String? activityLevel;

  const UserProfile({
    this.weight,
    this.height,
    this.age,
    this.sex,
    this.fitnessGoal,
    this.workoutsPerWeek,
    this.availableEquipment = const <String>[],
    this.activityLevel,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      weight: json['weight']?.toDouble(),
      height: json['height']?.toInt(),
      age: json['age']?.toInt(),
      sex: json['sex'] as String?,
      fitnessGoal: json['fitness_goal'] as String?,
      workoutsPerWeek: json['workouts_per_week']?.toInt(),
      availableEquipment: (json['available_equipment'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      activityLevel: json['activity_level'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'weight': weight,
      'height': height,
      'age': age,
      'sex': sex,
      'fitness_goal': fitnessGoal,
      'workouts_per_week': workoutsPerWeek,
      'available_equipment': availableEquipment,
      'activity_level': activityLevel,
    };
  }

  UserProfile copyWith({
    double? weight,
    int? height,
    int? age,
    String? sex,
    String? fitnessGoal,
    int? workoutsPerWeek,
    List<String>? availableEquipment,
    String? activityLevel,
  }) {
    return UserProfile(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  bool get isComplete {
    return weight != null &&
        height != null &&
        age != null &&
        sex != null &&
        fitnessGoal != null &&
        workoutsPerWeek != null;
  }

  /// Convert fitness goals from UI format to API format
  String get apiGoal {
    switch (fitnessGoal?.toLowerCase()) {
      case 'weight management':
        return 'weight_loss';
      case 'fitness improvement':
        return 'bulking';
      case 'better sleep quality':
        return 'general_fitness';
      case 'stress reduction':
        return 'general_fitness';
      default:
        return 'general_fitness';
    }
  }

  /// Convert sex from UI format to API format
  String get apiSex {
    switch (sex?.toLowerCase()) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      default:
        return 'male';
    }
  }
}
