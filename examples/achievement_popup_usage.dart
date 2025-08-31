// Example usage of the Achievement Popup Widget
// Add this import wherever you want to use the achievement popup
import 'package:ghiraas/widgets/achievement_popup_widget.dart';

// Example 1: Show after completing an exercise
void onExerciseCompleted(BuildContext context, String exerciseName) {
  // Your exercise completion logic here...
  
  // Show celebration popup
  AchievementPopupWidget.showExerciseCompletion(context, exerciseName);
}

// Example 2: Show after logging nutrition
void onNutritionLogged(BuildContext context) {
  // Your nutrition logging logic here...
  
  // Show celebration popup
  AchievementPopupWidget.showNutritionLogged(context);
}

// Example 3: Show after sleep tracking
void onSleepLogged(BuildContext context, String hours) {
  // Your sleep logging logic here...
  
  // Show celebration popup
  AchievementPopupWidget.showSleepLogged(context, hours);
}

// Example 4: Custom achievement
void onCustomAchievement(BuildContext context) {
  AchievementPopupWidget.show(
    context,
    title: 'Streak Milestone! 🔥',
    message: 'You\'ve maintained your healthy habits for 7 days straight!',
  );
}

// You can call these methods from:
// - Exercise completion screens
// - Nutrition logging forms  
// - Sleep tracking forms
// - Any other achievement triggers in your app
