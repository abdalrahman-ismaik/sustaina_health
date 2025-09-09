import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/notification_models.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _markAllAsRead() async {
    final actions = ref.read(firebaseNotificationActionsProvider);
    await actions.markAllAsRead();
  }

  Future<void> _markAsRead(String notificationId) async {
    final actions = ref.read(firebaseNotificationActionsProvider);
    await actions.markAsRead(notificationId);
  }

  Future<void> _deleteNotification(String notificationId) async {
    final actions = ref.read(firebaseNotificationActionsProvider);
    await actions.deleteNotification(notificationId);
  }

  Future<void> _clearAll() async {
    final actions = ref.read(firebaseNotificationActionsProvider);
    await actions.clearAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch Firebase notifications
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(color: cs.primary),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: cs.onSurface),
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: cs.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Important'),
          ],
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: cs.error),
              const SizedBox(height: 16),
              Text(
                'Error loading notifications',
                style: TextStyle(color: cs.error),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (notifications) => TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationsList(notifications, cs, isDark),
            _buildNotificationsList(
              notifications.where((n) => !n.isRead).toList(),
              cs,
              isDark,
            ),
            _buildNotificationsList(
              notifications.where((n) =>
                n.priority == NotificationPriority.high ||
                n.priority == NotificationPriority.urgent
              ).toList(),
              cs,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    List<AppNotification> notifications,
    ColorScheme cs,
    bool isDark,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: cs.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                color: cs.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification, cs, isDark);
      },
    );
  }

  Widget _buildNotificationCard(
    AppNotification notification,
    ColorScheme cs,
    bool isDark,
  ) {
    final isUnread = !notification.isRead;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 4 : 1,
      color: isUnread 
        ? cs.primaryContainer.withOpacity(0.1)
        : cs.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isUnread) {
            _markAsRead(notification.id);
          }
          if (notification.actionRoute != null) {
            context.go(notification.actionRoute!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type, cs),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                              color: cs.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (notification.priority == NotificationPriority.high ||
                            notification.priority == NotificationPriority.urgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'High Priority',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'mark_read' && isUnread) {
                    _markAsRead(notification.id);
                  } else if (value == 'delete') {
                    _deleteNotification(notification.id);
                  }
                },
                itemBuilder: (context) => [
                  if (isUnread)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Text('Mark as read'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type, ColorScheme cs) {
    switch (type) {
      case NotificationType.workout:
        return const Color(0xFF2196F3);
      case NotificationType.nutrition:
        return const Color(0xFF4CAF50);
      case NotificationType.sleep:
        return const Color(0xFF9C27B0);
      case NotificationType.achievement:
        return const Color(0xFFFF9800);
      case NotificationType.sustainability:
        return const Color(0xFF00BCD4);
      case NotificationType.reminder:
        return cs.primary;
      case NotificationType.system:
        return cs.secondary;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return Icons.fitness_center;
      case NotificationType.nutrition:
        return Icons.restaurant;
      case NotificationType.sleep:
        return Icons.bedtime;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.sustainability:
        return Icons.eco;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.system:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
