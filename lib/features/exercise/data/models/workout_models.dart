class WorkoutGenerationRequest {
  final double weight;
  final int height;
  final int age;
  final String sex;
  final String goal;
  final int workoutsPerWeek;
  final List<String> equipment;

  const WorkoutGenerationRequest({
    required this.weight,
    required this.height,
    required this.age,
    required this.sex,
    required this.goal,
    required this.workoutsPerWeek,
    required this.equipment,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'sex': sex,
      'goal': goal,
      'workouts_per_week': workoutsPerWeek,
      'equipment': equipment,
    };
  }
}

class Exercise {
  final String name;
  final int sets;
  final String reps;
  final int rest;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as String,
      rest: json['rest'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
    };
  }
}

class WorkoutSession {
  final List<Exercise> exercises;

  const WorkoutSession({
    required this.exercises,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      exercises: (json['exercises'] as List<dynamic>)
          .map((dynamic e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutComponent {
  final String description;
  final int duration;

  const WorkoutComponent({
    required this.description,
    required this.duration,
  });

  factory WorkoutComponent.fromJson(Map<String, dynamic> json) {
    return WorkoutComponent(
      description: json['description'] as String,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'duration': duration,
    };
  }
}

class WorkoutPlan {
  final WorkoutComponent warmup;
  final WorkoutComponent cardio;
  final int sessionsPerWeek;
  final List<WorkoutSession> workoutSessions;
  final WorkoutComponent cooldown;

  const WorkoutPlan({
    required this.warmup,
    required this.cardio,
    required this.sessionsPerWeek,
    required this.workoutSessions,
    required this.cooldown,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      warmup: WorkoutComponent.fromJson(json['warmup'] as Map<String, dynamic>),
      cardio: WorkoutComponent.fromJson(json['cardio'] as Map<String, dynamic>),
      sessionsPerWeek: json['sessions_per_week'] as int,
      workoutSessions: (json['workout_sessions'] as List<dynamic>)
          .map(
              (dynamic e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      cooldown:
          WorkoutComponent.fromJson(json['cooldown'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warmup': warmup.toJson(),
      'cardio': cardio.toJson(),
      'sessions_per_week': sessionsPerWeek,
      'workout_sessions': workoutSessions.map((s) => s.toJson()).toList(),
      'cooldown': cooldown.toJson(),
    };
  }
}

class SavedWorkoutPlan {
  final String id;
  final String userId;
  final String name;
  final WorkoutPlan workoutPlan;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final bool isFavorite;

  const SavedWorkoutPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.workoutPlan,
    required this.createdAt,
    this.lastUsed,
    this.isFavorite = false,
  });

  factory SavedWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return SavedWorkoutPlan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      workoutPlan: WorkoutPlan.fromJson(json['workoutPlan'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'workoutPlan': workoutPlan.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  SavedWorkoutPlan copyWith({
    String? id,
    String? userId,
    String? name,
    WorkoutPlan? workoutPlan,
    DateTime? createdAt,
    DateTime? lastUsed,
    bool? isFavorite,
  }) {
    return SavedWorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      workoutPlan: workoutPlan ?? this.workoutPlan,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
