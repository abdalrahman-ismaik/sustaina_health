class RouteNames {
  // Authentication Routes
  static const String splash = '/';
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingAIFeatures = '/onboarding/ai-features';
  static const String onboardingSustainability = '/onboarding/sustainability';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Profile Setup Routes
  static const String profileSetup = '/profile-setup';
  static const String personalInfo = '/profile-setup/personal-info';
  static const String healthGoals = '/profile-setup/health-goals';
  static const String sustainabilityPrefs = '/profile-setup/sustainability-prefs';

  // Main App Routes
  static const String home = '/home';
  static const String exercise = '/exercise';
  static const String nutrition = '/nutrition';
  static const String sleep = '/sleep';
  static const String profile = '/profile';

  // Exercise Sub-routes
  static const String aiWorkoutGenerator = '/exercise/ai-generator';
  static const String workoutDetail = '/exercise/workout/:workoutId';
  static const String workoutSession = '/exercise/session/:sessionId';
  static const String exerciseHistory = '/exercise/history';

  // Nutrition Sub-routes
  static const String foodLogging = '/nutrition/food-logging';
  static const String aiFoodRecognition = '/nutrition/ai-recognition';
  static const String nutritionInsights = '/nutrition/insights';
  static const String mealHistory = '/nutrition/history';

  // Sleep Sub-routes
  static const String sleepTracking = '/sleep/tracking';
  static const String sleepAnalysis = '/sleep/analysis';
  static const String sleepImprovement = '/sleep/improvement';

  // Profile Sub-routes
  static const String settings = '/profile/settings';
  static const String achievements = '/profile/achievements';
  static const String sustainabilityDashboard = '/profile/sustainability';

  // Supporting Routes
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
}