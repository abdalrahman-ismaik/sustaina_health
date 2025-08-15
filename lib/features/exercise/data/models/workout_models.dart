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
      workoutPlan:
          WorkoutPlan.fromJson(json['workoutPlan'] as Map<String, dynamic>),
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

// Models for workout execution/tracking
class ExerciseSet {
  final int reps;
  final double? weight;
  final int? duration; // in seconds for time-based exercises
  final DateTime completedAt;
  final String? notes;

  const ExerciseSet({
    required this.reps,
    this.weight,
    this.duration,
    required this.completedAt,
    this.notes,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'] as int,
      weight: json['weight']?.toDouble(),
      duration: json['duration'] as int?,
      completedAt: DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
    };
  }

  ExerciseSet copyWith({
    int? reps,
    double? weight,
    int? duration,
    DateTime? completedAt,
    String? notes,
  }) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}

class CompletedExercise {
  final String name;
  final List<ExerciseSet> sets;
  final int restTime; // in seconds
  final bool isCompleted;

  const CompletedExercise({
    required this.name,
    required this.sets,
    required this.restTime,
    this.isCompleted = false,
  });

  factory CompletedExercise.fromExercise(Exercise exercise) {
    return CompletedExercise(
      name: exercise.name,
      sets: [],
      restTime: exercise.rest,
    );
  }

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      name: json['name'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      restTime: json['restTime'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toJson()).toList(),
      'restTime': restTime,
      'isCompleted': isCompleted,
    };
  }

  CompletedExercise copyWith({
    String? name,
    List<ExerciseSet>? sets,
    int? restTime,
    bool? isCompleted,
  }) {
    return CompletedExercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActiveWorkoutSession {
  final String id;
  final String workoutName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<CompletedExercise> exercises;
  final Duration totalDuration;
  final bool isCompleted;
  final String? notes;

  const ActiveWorkoutSession({
    required this.id,
    required this.workoutName,
    required this.startTime,
    this.endTime,
    required this.exercises,
    required this.totalDuration,
    this.isCompleted = false,
    this.notes,
  });

  factory ActiveWorkoutSession.fromWorkoutSession({
    required String id,
    required String workoutName,
    required WorkoutSession workoutSession,
  }) {
    print(
        'Creating ActiveWorkoutSession with ${workoutSession.exercises.length} exercises'); // Debug

    final exercises = workoutSession.exercises
        .map((e) => CompletedExercise.fromExercise(e))
        .toList();

    print('Created ${exercises.length} CompletedExercise objects'); // Debug

    return ActiveWorkoutSession(
      id: id,
      workoutName: workoutName,
      startTime: DateTime.now(),
      exercises: exercises,
      totalDuration: Duration.zero,
    );
  }

  factory ActiveWorkoutSession.fromJson(Map<String, dynamic> json) {
    return ActiveWorkoutSession(
      id: json['id'] as String,
      workoutName: json['workoutName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => CompletedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDuration: Duration(seconds: json['totalDurationSeconds'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutName': workoutName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'totalDurationSeconds': totalDuration.inSeconds,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  ActiveWorkoutSession copyWith({
    String? id,
    String? workoutName,
    DateTime? startTime,
    DateTime? endTime,
    List<CompletedExercise>? exercises,
    Duration? totalDuration,
    bool? isCompleted,
    String? notes,
  }) {
    return ActiveWorkoutSession(
      id: id ?? this.id,
      workoutName: workoutName ?? this.workoutName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exercises: exercises ?? this.exercises,
      totalDuration: totalDuration ?? this.totalDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  /// Validate the workout session data
  bool get isValid {
    return id.isNotEmpty &&
        workoutName.trim().isNotEmpty &&
        exercises.isNotEmpty;
  }

  /// Get a summary of the workout session
  String get summary {
    final completedSets =
        exercises.fold<int>(0, (sum, exercise) => sum + exercise.sets.length);
    return 'Workout: $workoutName, Exercises: ${exercises.length}, Sets: $completedSets';
  }
}
