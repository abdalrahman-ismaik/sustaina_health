import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/notification_service.dart';
import '../../../sleep/presentation/theme/sleep_colors.dart';

class NotificationTestWidget extends ConsumerWidget {
  const NotificationTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_active,
                  color: SleepColors.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Notification Testing',
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
              'Test the notification system with sustainability tips and health reminders',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final NotificationService notificationService = NotificationService();
                      await notificationService.sendTestNotification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Test notification sent!'),
                          backgroundColor: SleepColors.successGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SleepColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Send Test'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final NotificationService notificationService = NotificationService();
                      await notificationService.scheduleDailySustainabilityTips(
                        hour: DateTime.now().hour,
                        minute: DateTime.now().minute + 1, // 1 minute from now
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Daily tips scheduled!'),
                          backgroundColor: SleepColors.successGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SleepColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Schedule Tips'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final NotificationService notificationService = NotificationService();
                  await notificationService.scheduleHealthReminder(
                    title: 'Health Check-in 💚',
                    body:
                        'Time to log your health data and track your wellness!',
                    hour: DateTime.now().hour,
                    minute: DateTime.now().minute + 2, // 2 minutes from now
                    weekdays: <int>[DateTime.now().weekday],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Health reminder scheduled!'),
                      backgroundColor: SleepColors.successGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SleepColors.primaryGreenDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Schedule Health Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
