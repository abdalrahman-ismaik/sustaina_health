import 'package:flutter/material.dart';

class SleepSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Duration totalDuration;
  final double sleepQuality;
  final String mood;
  final SleepEnvironment environment;
  final SleepStages stages;
  final SleepSustainability sustainability;
  final DateTime createdAt;
  final String? notes;

  const SleepSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.sleepQuality,
    required this.mood,
    required this.environment,
    required this.stages,
    required this.sustainability,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalDuration': totalDuration.inMilliseconds,
      'sleepQuality': sleepQuality,
      'mood': mood,
      'environment': environment.toJson(),
      'stages': stages.toJson(),
      'sustainability': sustainability.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory SleepSession.fromJson(Map<String, dynamic> json) {
    return SleepSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalDuration: Duration(milliseconds: json['totalDuration'] as int),
      sleepQuality: json['sleepQuality'] as double,
      mood: json['mood'] as String,
      environment: SleepEnvironment.fromJson(json['environment'] as Map<String, dynamic>),
      stages: SleepStages.fromJson(json['stages'] as Map<String, dynamic>),
      sustainability: SleepSustainability.fromJson(json['sustainability'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }
}

class SleepEnvironment {
  final double roomTemperature;
  final String noiseLevel;
  final String lightExposure;
  final double screenTime;
  final bool naturalLight;
  final bool ecoFriendly;
  final bool energyEfficient;

  const SleepEnvironment({
    required this.roomTemperature,
    required this.noiseLevel,
    required this.lightExposure,
    required this.screenTime,
    required this.naturalLight,
    required this.ecoFriendly,
    required this.energyEfficient,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomTemperature': roomTemperature,
      'noiseLevel': noiseLevel,
      'lightExposure': lightExposure,
      'screenTime': screenTime,
      'naturalLight': naturalLight,
      'ecoFriendly': ecoFriendly,
      'energyEfficient': energyEfficient,
    };
  }

  factory SleepEnvironment.fromJson(Map<String, dynamic> json) {
    return SleepEnvironment(
      roomTemperature: json['roomTemperature'] as double,
      noiseLevel: json['noiseLevel'] as String,
      lightExposure: json['lightExposure'] as String,
      screenTime: json['screenTime'] as double,
      naturalLight: json['naturalLight'] as bool,
      ecoFriendly: json['ecoFriendly'] as bool,
      energyEfficient: json['energyEfficient'] as bool,
    );
  }
}

class SleepStages {
  final Duration lightSleep;
  final Duration deepSleep;
  final Duration remSleep;
  final Duration awakeTime;

  const SleepStages({
    required this.lightSleep,
    required this.deepSleep,
    required this.remSleep,
    required this.awakeTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'lightSleep': lightSleep.inMilliseconds,
      'deepSleep': deepSleep.inMilliseconds,
      'remSleep': remSleep.inMilliseconds,
      'awakeTime': awakeTime.inMilliseconds,
    };
  }

  factory SleepStages.fromJson(Map<String, dynamic> json) {
    return SleepStages(
      lightSleep: Duration(milliseconds: json['lightSleep'] as int),
      deepSleep: Duration(milliseconds: json['deepSleep'] as int),
      remSleep: Duration(milliseconds: json['remSleep'] as int),
      awakeTime: Duration(milliseconds: json['awakeTime'] as int),
    );
  }
}

class SleepSustainability {
  final double energySaved;
  final double carbonFootprintReduction;
  final bool usedEcoFriendlyBedding;
  final bool usedNaturalVentilation;
  final bool usedEnergyEfficientDevices;

  const SleepSustainability({
    required this.energySaved,
    required this.carbonFootprintReduction,
    required this.usedEcoFriendlyBedding,
    required this.usedNaturalVentilation,
    required this.usedEnergyEfficientDevices,
  });

  Map<String, dynamic> toJson() {
    return {
      'energySaved': energySaved,
      'carbonFootprintReduction': carbonFootprintReduction,
      'usedEcoFriendlyBedding': usedEcoFriendlyBedding,
      'usedNaturalVentilation': usedNaturalVentilation,
      'usedEnergyEfficientDevices': usedEnergyEfficientDevices,
    };
  }

  factory SleepSustainability.fromJson(Map<String, dynamic> json) {
    return SleepSustainability(
      energySaved: json['energySaved'] as double,
      carbonFootprintReduction: json['carbonFootprintReduction'] as double,
      usedEcoFriendlyBedding: json['usedEcoFriendlyBedding'] as bool,
      usedNaturalVentilation: json['usedNaturalVentilation'] as bool,
      usedEnergyEfficientDevices: json['usedEnergyEfficientDevices'] as bool,
    );
  }
}

class SleepGoal {
  final String id;
  final Duration targetDuration;
  final TimeOfDay targetBedtime;
  final TimeOfDay targetWakeTime;
  final double targetQuality;
  final bool reminderEnabled;
  final DateTime createdAt;

  const SleepGoal({
    required this.id,
    required this.targetDuration,
    required this.targetBedtime,
    required this.targetWakeTime,
    required this.targetQuality,
    required this.reminderEnabled,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetDuration': targetDuration.inMilliseconds,
      'targetBedtime': {'hour': targetBedtime.hour, 'minute': targetBedtime.minute},
      'targetWakeTime': {'hour': targetWakeTime.hour, 'minute': targetWakeTime.minute},
      'targetQuality': targetQuality,
      'reminderEnabled': reminderEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SleepGoal.fromJson(Map<String, dynamic> json) {
    final bedtimeJson = json['targetBedtime'] as Map<String, dynamic>;
    final wakeTimeJson = json['targetWakeTime'] as Map<String, dynamic>;
    
    return SleepGoal(
      id: json['id'] as String,
      targetDuration: Duration(milliseconds: json['targetDuration'] as int),
      targetBedtime: TimeOfDay(
        hour: bedtimeJson['hour'] as int,
        minute: bedtimeJson['minute'] as int,
      ),
      targetWakeTime: TimeOfDay(
        hour: wakeTimeJson['hour'] as int,
        minute: wakeTimeJson['minute'] as int,
      ),
      targetQuality: json['targetQuality'] as double,
      reminderEnabled: json['reminderEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SleepReminder {
  final String id;
  final TimeOfDay time;
  final bool enabled;
  final List<String> days;
  final String message;
  final DateTime createdAt;

  const SleepReminder({
    required this.id,
    required this.time,
    required this.enabled,
    required this.days,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': {'hour': time.hour, 'minute': time.minute},
      'enabled': enabled,
      'days': days,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SleepReminder.fromJson(Map<String, dynamic> json) {
    final timeJson = json['time'] as Map<String, dynamic>;
    
    return SleepReminder(
      id: json['id'] as String,
      time: TimeOfDay(
        hour: timeJson['hour'] as int,
        minute: timeJson['minute'] as int,
      ),
      enabled: json['enabled'] as bool,
      days: List<String>.from(json['days'] as List),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SleepInsight {
  final String id;
  final String title;
  final String description;
  final SleepInsightType type;
  final double impact;
  final List<String> recommendations;
  final DateTime createdAt;

  const SleepInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.recommendations,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'impact': impact,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SleepInsight.fromJson(Map<String, dynamic> json) {
    return SleepInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: SleepInsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SleepInsightType.quality,
      ),
      impact: json['impact'] as double,
      recommendations: List<String>.from(json['recommendations'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

enum SleepInsightType {
  quality,
  duration,
  consistency,
  environment,
  sustainability,
  lifestyle
}

class SleepStats {
  final Duration averageDuration;
  final double averageQuality;
  final Duration totalSleepTime;
  final int totalSessions;
  final Duration bestSleep;
  final Duration worstSleep;
  final double consistencyScore;
  final double sustainabilityScore;
  final Map<String, double> weeklyTrends;

  const SleepStats({
    required this.averageDuration,
    required this.averageQuality,
    required this.totalSleepTime,
    required this.totalSessions,
    required this.bestSleep,
    required this.worstSleep,
    required this.consistencyScore,
    required this.sustainabilityScore,
    required this.weeklyTrends,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageDuration': averageDuration.inMilliseconds,
      'averageQuality': averageQuality,
      'totalSleepTime': totalSleepTime.inMilliseconds,
      'totalSessions': totalSessions,
      'bestSleep': bestSleep.inMilliseconds,
      'worstSleep': worstSleep.inMilliseconds,
      'consistencyScore': consistencyScore,
      'sustainabilityScore': sustainabilityScore,
      'weeklyTrends': weeklyTrends,
    };
  }

  factory SleepStats.fromJson(Map<String, dynamic> json) {
    return SleepStats(
      averageDuration: Duration(milliseconds: json['averageDuration'] as int),
      averageQuality: json['averageQuality'] as double,
      totalSleepTime: Duration(milliseconds: json['totalSleepTime'] as int),
      totalSessions: json['totalSessions'] as int,
      bestSleep: Duration(milliseconds: json['bestSleep'] as int),
      worstSleep: Duration(milliseconds: json['worstSleep'] as int),
      consistencyScore: json['consistencyScore'] as double,
      sustainabilityScore: json['sustainabilityScore'] as double,
      weeklyTrends: Map<String, double>.from(json['weeklyTrends'] as Map),
    );
  }
}
