import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/services/enhanced_notification_service.dart';
// Using global app theme color scheme

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final EnhancedNotificationService _notificationService = 
      EnhancedNotificationService();

  bool _notificationsAllowed = false;
  List<PendingNotificationRequest> _scheduledNotifications = <PendingNotificationRequest>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    setState(() => _isLoading = true);

    try {
      await _notificationService.initialize();
      
      // Check if notifications are allowed
      final bool allowed = await _notificationService.areNotificationsEnabled();
      
      // Get scheduled notifications
      final List<PendingNotificationRequest> scheduled = 
          await _notificationService.getScheduledNotifications();

      setState(() {
        _notificationsAllowed = allowed;
        _scheduledNotifications = scheduled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final bool granted = await _notificationService.requestPermissions();
    if (granted) {
      setState(() => _notificationsAllowed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification permissions granted!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text(
          'To receive meal, exercise, and sleep reminders, please enable notifications in your device settings.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Test notification sent!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test notification: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildPermissionCard(),
                  const SizedBox(height: 20),
                  _buildTestingCard(),
                  const SizedBox(height: 20),
                  _buildScheduledNotificationsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  _notificationsAllowed ? Icons.check_circle : Icons.error,
          color: _notificationsAllowed 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Permission Status',
                  style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _notificationsAllowed
                  ? 'Notifications are enabled. You will receive reminders for meals, exercise, and sleep tracking.'
                  : 'Notifications are disabled. Enable them to receive helpful reminders.',
              style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            if (!_notificationsAllowed) ...<Widget>[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Enable Notifications'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Testing & Information',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The enhanced notification system will automatically remind you to:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildReminderList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendTestNotification,
                icon: const Icon(Icons.send),
                label: const Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReminderList() {
    final List<Map<String, dynamic>> reminders = <Map<String, dynamic>>[
      <String, dynamic>{
        'icon': Icons.restaurant,
        'text': 'Log your breakfast (8:00 AM), lunch (1:00 PM), and dinner (7:00 PM)'
      },
      <String, dynamic>{
        'icon': Icons.fitness_center,
        'text': 'Exercise regularly (5:00 PM) and track workouts (8:00 PM)'
      },
      <String, dynamic>{
        'icon': Icons.bedtime,
        'text': 'Go to bed on time (10:00 PM) and log sleep (9:00 AM)'
      },
      <String, dynamic>{
        'icon': Icons.eco,
        'text': 'Follow sustainability tips throughout the day'
      },
    ];

    return reminders.map((Map<String, dynamic> reminder) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Icon(
            reminder['icon'],
      color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder['text'],
              style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildScheduledNotificationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Scheduled Notifications',
              style: TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_scheduledNotifications.isEmpty) ...<Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.schedule,
                        size: 48,
      color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Flexible Notifications Active',
                        style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your notifications are working! Due to Android battery optimization, we use flexible timing that adapts to your device\'s schedule. You\'ll still receive all your health reminders.',
                        style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...<Widget>[
              Text(
                'You have ${_scheduledNotifications.length} upcoming notifications',
                style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ...(_scheduledNotifications.take(5).map((PendingNotificationRequest notification) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              notification.title ?? 'Notification',
                              style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (notification.body != null) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                notification.body!,
                                style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList()),
            ],
          ],
        ),
      ),
    );
  }
}
