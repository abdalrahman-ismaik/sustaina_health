class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementType type;
  final int targetValue;
  final int rewardPoints;
  final int currentProgress;
  final bool isUnlocked;
  final AchievementRarity rarity;
  final DateTime? unlockedAt;
  final String? badgeImageUrl;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.type,
    required this.targetValue,
    required this.rewardPoints,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.rarity = AchievementRarity.common,
    this.unlockedAt,
    this.badgeImageUrl,
  });

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    AchievementCategory? category,
    AchievementType? type,
    int? targetValue,
    int? rewardPoints,
    int? currentProgress,
    bool? isUnlocked,
    AchievementRarity? rarity,
    DateTime? unlockedAt,
    String? badgeImageUrl,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      rarity: rarity ?? this.rarity,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      badgeImageUrl: badgeImageUrl ?? this.badgeImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.name,
      'type': type.name,
      'targetValue': targetValue,
      'rewardPoints': rewardPoints,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'rarity': rarity.name,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'badgeImageUrl': badgeImageUrl,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.sustainability,
      ),
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.milestone,
      ),
      targetValue: json['targetValue'] as int,
      rewardPoints: json['rewardPoints'] as int,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      badgeImageUrl: json['badgeImageUrl'] as String?,
    );
  }

  double get progressPercentage => 
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentProgress >= targetValue;
}

class SustainabilityReward {
  final String id;
  final String name;
  final String description;
  final String icon;
  final RewardType type;
  final int cost;
  final bool isRedeemed;
  final DateTime? redeemedAt;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const SustainabilityReward({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.cost,
    this.isRedeemed = false,
    this.redeemedAt,
    this.imageUrl,
    this.metadata,
  });

  SustainabilityReward copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    RewardType? type,
    int? cost,
    bool? isRedeemed,
    DateTime? redeemedAt,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return SustainabilityReward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type.name,
      'cost': cost,
      'isRedeemed': isRedeemed,
      'redeemedAt': redeemedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  factory SustainabilityReward.fromJson(Map<String, dynamic> json) {
    return SustainabilityReward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.badge,
      ),
      cost: json['cost'] as int,
      isRedeemed: json['isRedeemed'] as bool? ?? false,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.parse(json['redeemedAt'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class UserAchievementProgress {
  final String achievementId;
  final int currentProgress;
  final int targetValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> milestones;

  const UserAchievementProgress({
    required this.achievementId,
    required this.currentProgress,
    required this.targetValue,
    this.isCompleted = false,
    this.completedAt,
    this.milestones = const [],
  });

  UserAchievementProgress copyWith({
    String? achievementId,
    int? currentProgress,
    int? targetValue,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? milestones,
  }) {
    return UserAchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      targetValue: targetValue ?? this.targetValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      milestones: milestones ?? this.milestones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'targetValue': targetValue,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'milestones': milestones,
    };
  }

  factory UserAchievementProgress.fromJson(Map<String, dynamic> json) {
    return UserAchievementProgress(
      achievementId: json['achievementId'] as String,
      currentProgress: json['currentProgress'] as int,
      targetValue: json['targetValue'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      milestones: List<String>.from(json['milestones'] as List? ?? []),
    );
  }

  double get progressPercentage => 
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;
}

class SustainabilityStats {
  final int totalPoints;
  final double carbonSaved;
  final int sustainableActions;
  final int localBrandsSupported;
  final int consecutiveDays;
  final int totalAchievements;
  final Map<String, int> categoryProgress;
  final DateTime? lastActivity;

  const SustainabilityStats({
    this.totalPoints = 0,
    this.carbonSaved = 0.0,
    this.sustainableActions = 0,
    this.localBrandsSupported = 0,
    this.consecutiveDays = 0,
    this.totalAchievements = 0,
    this.categoryProgress = const {},
    this.lastActivity,
  });

  SustainabilityStats copyWith({
    int? totalPoints,
    double? carbonSaved,
    int? sustainableActions,
    int? localBrandsSupported,
    int? consecutiveDays,
    int? totalAchievements,
    Map<String, int>? categoryProgress,
    DateTime? lastActivity,
  }) {
    return SustainabilityStats(
      totalPoints: totalPoints ?? this.totalPoints,
      carbonSaved: carbonSaved ?? this.carbonSaved,
      sustainableActions: sustainableActions ?? this.sustainableActions,
      localBrandsSupported: localBrandsSupported ?? this.localBrandsSupported,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      totalAchievements: totalAchievements ?? this.totalAchievements,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'carbonSaved': carbonSaved,
      'sustainableActions': sustainableActions,
      'localBrandsSupported': localBrandsSupported,
      'consecutiveDays': consecutiveDays,
      'totalAchievements': totalAchievements,
      'categoryProgress': categoryProgress,
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }

  factory SustainabilityStats.fromJson(Map<String, dynamic> json) {
    return SustainabilityStats(
      totalPoints: json['totalPoints'] as int? ?? 0,
      carbonSaved: (json['carbonSaved'] as num?)?.toDouble() ?? 0.0,
      sustainableActions: json['sustainableActions'] as int? ?? 0,
      localBrandsSupported: json['localBrandsSupported'] as int? ?? 0,
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
      totalAchievements: json['totalAchievements'] as int? ?? 0,
      categoryProgress: Map<String, int>.from(json['categoryProgress'] as Map? ?? {}),
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
    );
  }
}

enum AchievementCategory {
  sustainability,
  health,
  fitness,
  nutrition,
  sleep,
  mindfulness,
  social,
  localSupport,
}

enum AchievementType {
  milestone,        // Reach X total points
  streak,          // Do X consecutive days
  accumulative,    // Complete X actions over time
  threshold,       // Reach X value in a metric
  specific,        // Complete a specific action
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

enum RewardType {
  badge,
  discount,
  featureUnlock,
  virtualItem,
  realReward,
  localBusinessOffer,
}
