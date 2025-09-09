import 'package:flutter/material.dart';

enum NotificationType {
  workout,
  nutrition,
  sleep,
  achievement,
  reminder,
  sustainability,
  system,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;
  final IconData? customIcon;
  final Color? customColor;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
    this.customIcon,
    this.customColor,
    this.metadata,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    String? actionRoute,
    IconData? customIcon,
    Color? customColor,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      customIcon: customIcon ?? this.customIcon,
      customColor: customColor ?? this.customColor,
      metadata: metadata ?? this.metadata,
    );
  }

  IconData get icon {
    if (customIcon != null) return customIcon!;
    
    switch (type) {
      case NotificationType.workout:
        return Icons.fitness_center;
      case NotificationType.nutrition:
        return Icons.restaurant;
      case NotificationType.sleep:
        return Icons.bedtime;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.sustainability:
        return Icons.eco;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color getColor(ColorScheme colorScheme) {
    if (customColor != null) return customColor!;
    
    switch (type) {
      case NotificationType.workout:
        return const Color(0xFF2196F3);
      case NotificationType.nutrition:
        return const Color(0xFF4CAF50);
      case NotificationType.sleep:
        return const Color(0xFF9C27B0);
      case NotificationType.achievement:
        return const Color(0xFFFF9800);
      case NotificationType.reminder:
        return colorScheme.primary;
      case NotificationType.sustainability:
        return const Color(0xFF009688);
      case NotificationType.system:
        return colorScheme.outline;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionRoute': actionRoute,
      'metadata': metadata,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      priority: NotificationPriority.values.firstWhere((e) => e.name == json['priority']),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      actionRoute: json['actionRoute'],
      metadata: json['metadata'],
    );
  }
}
