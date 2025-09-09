import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  static const String _workoutRemindersKey = 'workout_reminders';
  static const String _mealLoggingKey = 'meal_logging';
  static const String _sleepTrackingKey = 'sleep_tracking';
  static const String _achievementNotificationsKey = 'achievement_notifications';
  static const String _sustainabilityTipsKey = 'sustainability_tips';

  // Get workout reminders preference
  static Future<bool> getWorkoutReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_workoutRemindersKey) ?? true; // Default enabled
  }

  // Set workout reminders preference
  static Future<void> setWorkoutReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_workoutRemindersKey, enabled);
  }

  // Get meal logging preference
  static Future<bool> getMealLogging() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_mealLoggingKey) ?? true; // Default enabled
  }

  // Set meal logging preference
  static Future<void> setMealLogging(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mealLoggingKey, enabled);
  }

  // Get sleep tracking preference
  static Future<bool> getSleepTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sleepTrackingKey) ?? false; // Default disabled
  }

  // Set sleep tracking preference
  static Future<void> setSleepTracking(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sleepTrackingKey, enabled);
  }

  // Get achievement notifications preference
  static Future<bool> getAchievementNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_achievementNotificationsKey) ?? true; // Default enabled
  }

  // Set achievement notifications preference
  static Future<void> setAchievementNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_achievementNotificationsKey, enabled);
  }

  // Get sustainability tips preference
  static Future<bool> getSustainabilityTips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sustainabilityTipsKey) ?? true; // Default enabled
  }

  // Set sustainability tips preference
  static Future<void> setSustainabilityTips(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sustainabilityTipsKey, enabled);
  }

  // Get all preferences
  static Future<Map<String, bool>> getAllPreferences() async {
    return {
      'workoutReminders': await getWorkoutReminders(),
      'mealLogging': await getMealLogging(),
      'sleepTracking': await getSleepTracking(),
      'achievementNotifications': await getAchievementNotifications(),
      'sustainabilityTips': await getSustainabilityTips(),
    };
  }

  // Reset all preferences to defaults
  static Future<void> resetToDefaults() async {
    await setWorkoutReminders(true);
    await setMealLogging(true);
    await setSleepTracking(false);
    await setAchievementNotifications(true);
    await setSustainabilityTips(true);
  }
}
