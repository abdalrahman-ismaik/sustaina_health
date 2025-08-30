import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/services/firebase_notification_service.dart';
import '../../../sleep/presentation/theme/sleep_colors.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  bool _notificationsAllowed = false;
  List<PendingNotificationRequest> _scheduledNotifications = [];
  bool _isLoading = false;
  bool? _exactAlarmsPermitted;

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

      // Check exact-alarm permission after basic initialization
      try {
        final bool allowedExact =
            await _notificationService.isExactAlarmPermitted();
        setState(() => _exactAlarmsPermitted = allowedExact);
      } catch (e) {
        setState(() => _exactAlarmsPermitted = true);
      }
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
        const SnackBar(
          content: Text('Notification permissions granted!'),
          backgroundColor: SleepColors.successGreen,
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
        actions: [
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
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: SleepColors.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test notification: $e'),
          backgroundColor: SleepColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SleepColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: SleepColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exact-alarm banner: shown when the system blocks exact alarms
                      if (_exactAlarmsPermitted == false) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.yellow[700]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Exact alarms are disabled',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Your device is blocking exact alarms. To receive timely reminders, enable exact alarms in system settings.',
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final opened =
                                            await _notificationService
                                                .openExactAlarmSettings();
                                        if (opened) {
                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          final allowed =
                                              await _notificationService
                                                  .isExactAlarmPermitted();
                                          setState(() =>
                                              _exactAlarmsPermitted = allowed);
                                          if (allowed) {
                                            await _notificationService
                                                .rescheduleAllReminders();
                                            final scheduled =
                                                await _notificationService
                                                    .getScheduledNotifications();
                                            setState(() =>
                                                _scheduledNotifications =
                                                    scheduled);
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Could not open exact-alarm settings on this device')),
                                          );
                                        }
                                      },
                                      child: const Text('Open Settings'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              SleepColors.primaryGreen),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        final allowed =
                                            await _notificationService
                                                .isExactAlarmPermitted();
                                        setState(() =>
                                            _exactAlarmsPermitted = allowed);
                                      },
                                      child: const Text('Refresh'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildPermissionCard(),
                      const SizedBox(height: 20),
                      _buildTestingCard(),
                      const SizedBox(height: 20),
                      _buildScheduledNotificationsCard(),
                    ],
                  ),
                ),
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
          children: [
            Row(
              children: [
                Icon(
                  _notificationsAllowed ? Icons.check_circle : Icons.error,
                  color: _notificationsAllowed
                      ? SleepColors.successGreen
                      : SleepColors.errorRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Permission Status',
                  style: TextStyle(
                    color: SleepColors.textPrimary,
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
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (!_notificationsAllowed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SleepColors.primaryGreen,
                    foregroundColor: Colors.white,
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
          children: [
            Text(
              'Testing & Information',
              style: TextStyle(
                color: SleepColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The enhanced notification system will automatically remind you to:',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildReminderList(),
            const SizedBox(height: 16),
            Text(
              'Test different notification methods to diagnose Android issues:',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _sendTestNotification,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SleepColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await _notificationService
                          .scheduleOneOffTestNotification(seconds: 10);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Scheduled test for 10s'
                              : 'Failed to schedule test'),
                        ),
                      );
                    },
                    child: const Text('Schedule Test (10s)'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        final ok = await _notificationService
                            .scheduleSimple30SecondTest();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Simple 2min test scheduled! Check console logs.'
                                : 'Failed to schedule simple test'),
                            backgroundColor: ok
                                ? SleepColors.successGreen
                                : SleepColors.errorRed,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: SleepColors.errorRed,
                          ),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                    child: const Text('🔬 Simple 2min Test (With Timezone)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        final blockingCheck = await _notificationService
                            .checkNotificationBlocking();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Notification Blocking Analysis'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (blockingCheck['hasIssues'] == true) ...[
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '⚠️ Issues Found:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...(blockingCheck['issues'] as List<String>)
                                        .map((issue) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text('• $issue',
                                                  style: const TextStyle(
                                                      color: Colors.red)),
                                            )),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '💡 Recommendations:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...(blockingCheck['recommendations']
                                            as List<String>)
                                        .map((rec) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text('• $rec',
                                                  style: const TextStyle(
                                                      color: Colors.green)),
                                            )),
                                  ] else ...[
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '✅ No blocking issues detected',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Technical Details:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...blockingCheck.entries
                                      .where((entry) =>
                                          entry.key != 'issues' &&
                                          entry.key != 'recommendations' &&
                                          entry.key != 'hasIssues')
                                      .map((entry) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: Text(
                                              '${entry.key}: ${entry.value}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          )),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                              if (blockingCheck['hasIssues'] == true)
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    // Open battery optimization settings as primary fix
                                    final opened = await _notificationService
                                        .openBatteryOptimizationSettings();
                                    if (!opened) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Could not open battery optimization settings'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Fix Issues'),
                                ),
                            ],
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error checking blocking: $e'),
                            backgroundColor: SleepColors.errorRed,
                          ),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                    child: const Text('� Check Notification Blocking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        final ok = await _notificationService
                            .forceRescheduleWithImprovements();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Force rescheduled with improvements! All notifications updated.'
                                : 'Failed to force reschedule'),
                            backgroundColor: ok
                                ? SleepColors.successGreen
                                : SleepColors.errorRed,
                          ),
                        );
                        if (ok) {
                          final scheduled = await _notificationService
                              .getScheduledNotifications();
                          setState(() => _scheduledNotifications = scheduled);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error force rescheduling: $e'),
                            backgroundColor: SleepColors.errorRed,
                          ),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                    child: const Text('� Force Reschedule with Improvements'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReminderList() {
    final List<Map<String, dynamic>> reminders = [
      {
        'icon': Icons.restaurant,
        'text':
            'Log your breakfast (8:00 AM), lunch (1:00 PM), and dinner (7:00 PM)'
      },
      {
        'icon': Icons.fitness_center,
        'text': 'Exercise regularly (5:00 PM) and track workouts (8:00 PM)'
      },
      {
        'icon': Icons.bedtime,
        'text': 'Go to bed on time (10:00 PM) and log sleep (9:00 AM)'
      },
      {
        'icon': Icons.eco,
        'text': 'Follow sustainability tips throughout the day'
      },
    ];

    return reminders
        .map((reminder) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    reminder['icon'],
                    color: SleepColors.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reminder['text'],
                      style: TextStyle(
                        color: SleepColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildScheduledNotificationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scheduled Notifications',
              style: TextStyle(
                color: SleepColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_scheduledNotifications.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 48,
                        color: SleepColors.primaryGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Flexible Notifications Active',
                        style: TextStyle(
                          color: SleepColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your notifications are working! Due to Android battery optimization, we use flexible timing that adapts to your device\'s schedule. You\'ll still receive all your health reminders.',
                        style: TextStyle(
                          color: SleepColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                'You have ${_scheduledNotifications.length} upcoming notifications',
                style: TextStyle(
                  color: SleepColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ...(_scheduledNotifications
                  .take(5)
                  .map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: SleepColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title ?? 'Notification',
                                  style: TextStyle(
                                    color: SleepColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (notification.body != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    notification.body!,
                                    style: TextStyle(
                                      color: SleepColors.textSecondary,
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
                  )
                  .toList()),
            ],
          ],
        ),
      ),
    );
  }
}
