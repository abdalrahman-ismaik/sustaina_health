import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../services/notification_service.dart';
import '../../../sleep/presentation/theme/sleep_colors.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _sustainabilityTipsEnabled = false;
  bool _healthRemindersEnabled = false;
  bool _notificationsAllowed = false;

  TimeOfDay _sustainabilityTipTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _healthReminderTime = const TimeOfDay(hour: 8, minute: 0);

  List<bool> _selectedDays =
      List.filled(7, true); // All days selected by default
  final List<String> _dayNames = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  List<PendingNotificationRequest> _scheduledNotifications = <PendingNotificationRequest>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    setState(() => _isLoading = true);

    await _notificationService.initialize();

    // Check if notifications are allowed
    final bool allowed = await _notificationService.areNotificationsEnabled();

    // Get scheduled notifications
    final List<PendingNotificationRequest> scheduled = await _notificationService.getScheduledNotifications();

    setState(() {
      _notificationsAllowed = allowed;
      _scheduledNotifications = scheduled;
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    final bool granted = await _notificationService.requestPermissions();
    if (!granted) {
      // Show dialog to go to settings
      _showPermissionDialog();
    } else {
      setState(() => _notificationsAllowed = true);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text(
          'To receive sustainability tips and health reminders, please enable notifications in your device settings.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _notificationService.openNotificationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, bool isSustainabilityTip) async {
    final TimeOfDay initialTime =
        isSustainabilityTip ? _sustainabilityTipTime : _healthReminderTime;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SleepColors.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isSustainabilityTip) {
          _sustainabilityTipTime = picked;
        } else {
          _healthReminderTime = picked;
        }
      });
    }
  }

  Future<void> _scheduleSustainabilityTips() async {
    if (!_notificationsAllowed) {
      await _requestPermissions();
      return;
    }

    setState(() => _isLoading = true);

    if (_sustainabilityTipsEnabled) {
      await _notificationService.scheduleDailySustainabilityTips(
        hour: _sustainabilityTipTime.hour,
        minute: _sustainabilityTipTime.minute,
      );
      _showSuccessSnackBar('Sustainability tips scheduled successfully!');
    } else {
      await _notificationService
          .cancelNotificationsByChannel('sustainability_tips');
      _showSuccessSnackBar('Sustainability tips cancelled');
    }

    // Refresh scheduled notifications
    final List<PendingNotificationRequest> scheduled = await _notificationService.getScheduledNotifications();
    setState(() {
      _scheduledNotifications = scheduled;
      _isLoading = false;
    });
  }

  Future<void> _scheduleHealthReminders() async {
    if (!_notificationsAllowed) {
      await _requestPermissions();
      return;
    }

    setState(() => _isLoading = true);

    if (_healthRemindersEnabled) {
      // Convert selected days to weekday numbers (1=Monday, 7=Sunday)
      final List<int> selectedWeekdays = <int>[];
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) {
          selectedWeekdays.add(i + 1); // Convert to 1-based index
        }
      }

      await _notificationService.scheduleHealthReminder(
        title: 'Health Check-in 💚',
        body:
            'Time to log your health data and track your sustainable wellness journey!',
        hour: _healthReminderTime.hour,
        minute: _healthReminderTime.minute,
        weekdays: selectedWeekdays,
      );
      _showSuccessSnackBar('Health reminders scheduled successfully!');
    } else {
      await _notificationService
          .cancelNotificationsByChannel('health_reminders');
      _showSuccessSnackBar('Health reminders cancelled');
    }

    // Refresh scheduled notifications
    final List<PendingNotificationRequest> scheduled = await _notificationService.getScheduledNotifications();
    setState(() {
      _scheduledNotifications = scheduled;
      _isLoading = false;
    });
  }

  Future<void> _sendTestNotification() async {
    if (!_notificationsAllowed) {
      await _requestPermissions();
      return;
    }

    await _notificationService.sendTestNotification();
    _showSuccessSnackBar('Test notification sent!');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SleepColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SleepColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: SleepColors.textPrimary),
        ),
        backgroundColor: SleepColors.surfaceGrey,
        elevation: 0,
        iconTheme: const IconThemeData(color: SleepColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(SleepColors.primaryGreen),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Permission Status Card
                  _buildPermissionStatusCard(),
                  const SizedBox(height: 24),

                  // Sustainability Tips Section
                  _buildSustainabilityTipsSection(),
                  const SizedBox(height: 24),

                  // Health Reminders Section
                  _buildHealthRemindersSection(),
                  const SizedBox(height: 24),

                  // Test Notification Button
                  _buildTestSection(),
                  const SizedBox(height: 24),

                  // Scheduled Notifications
                  _buildScheduledNotificationsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsAllowed
              ? SleepColors.successGreen
              : SleepColors.errorRed,
          width: 2,
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            _notificationsAllowed
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: _notificationsAllowed
                ? SleepColors.successGreen
                : SleepColors.errorRed,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _notificationsAllowed
                ? 'Notifications Enabled'
                : 'Notifications Disabled',
            style: TextStyle(
              color: SleepColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _notificationsAllowed
                ? 'You will receive sustainability tips and health reminders'
                : 'Enable notifications to receive helpful tips and reminders',
            style: TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_notificationsAllowed) ...<Widget>[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: SleepColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Enable Notifications'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSustainabilityTipsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.eco,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Sustainability Tips',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Receive daily tips on living more sustainably and improving your health',
            style: TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Switch(
                value: _sustainabilityTipsEnabled,
                onChanged: (bool value) {
                  setState(() => _sustainabilityTipsEnabled = value);
                  _scheduleSustainabilityTips();
                },
                activeColor: SleepColors.primaryGreen,
              ),
              const SizedBox(width: 12),
              Text(
                'Enable daily tips',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (_sustainabilityTipsEnabled) ...<Widget>[
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectTime(context, true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SleepColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: SleepColors.textTertiary.withOpacity(0.3)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      color: SleepColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Time: ${_sustainabilityTipTime.format(context)}',
                      style: TextStyle(
                        color: SleepColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: SleepColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthRemindersSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.favorite,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Health Reminders',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Get reminded to log your health data and maintain your wellness routine',
            style: TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Switch(
                value: _healthRemindersEnabled,
                onChanged: (bool value) {
                  setState(() => _healthRemindersEnabled = value);
                  _scheduleHealthReminders();
                },
                activeColor: SleepColors.primaryGreen,
              ),
              const SizedBox(width: 12),
              Text(
                'Enable reminders',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (_healthRemindersEnabled) ...<Widget>[
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectTime(context, false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SleepColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: SleepColors.textTertiary.withOpacity(0.3)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      color: SleepColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Time: ${_healthReminderTime.format(context)}',
                      style: TextStyle(
                        color: SleepColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: SleepColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Days of the week:',
              style: TextStyle(
                color: SleepColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(7, (int index) {
                return FilterChip(
                  label: Text(_dayNames[index]),
                  selected: _selectedDays[index],
                  onSelected: (bool selected) {
                    setState(() => _selectedDays[index] = selected);
                    if (_healthRemindersEnabled) {
                      _scheduleHealthReminders();
                    }
                  },
                  backgroundColor: SleepColors.backgroundGrey,
                  selectedColor: SleepColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: _selectedDays[index]
                        ? Colors.white
                        : SleepColors.textPrimary,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.bug_report,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Test Notifications',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Send a test notification to make sure everything is working correctly',
            style: TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendTestNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: SleepColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Send Test Notification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledNotificationsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.schedule,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Scheduled Notifications',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_scheduledNotifications.isEmpty)
            Text(
              'No notifications scheduled',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
            )
          else
            Text(
              '${_scheduledNotifications.length} notifications scheduled',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
            ),
          if (_scheduledNotifications.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.cancelAllNotifications();
                final List<PendingNotificationRequest> scheduled =
                    await _notificationService.getScheduledNotifications();
                setState(() {
                  _scheduledNotifications = scheduled;
                  _sustainabilityTipsEnabled = false;
                  _healthRemindersEnabled = false;
                });
                _showSuccessSnackBar('All notifications cancelled');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SleepColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel All Notifications'),
            ),
          ],
        ],
      ),
    );
  }
}
