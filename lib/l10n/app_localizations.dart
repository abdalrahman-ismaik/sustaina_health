import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Ghiraas'**
  String get appName;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Default welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome User'**
  String get welcomeUser;

  /// User title badge
  ///
  /// In en, this message translates to:
  /// **'Sustainability Champion'**
  String get sustainabilityChampion;

  /// Default message when user has no email
  ///
  /// In en, this message translates to:
  /// **'No email provided'**
  String get noEmailProvided;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Your Impact'**
  String get yourImpact;

  /// Carbon footprint reduction metric
  ///
  /// In en, this message translates to:
  /// **'Carbon Saved'**
  String get carbonSaved;

  /// Current activity streak
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Workouts section title
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// Achievement count
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// Sync button text
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Syncing in progress text
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Weight field label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Height field label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// Age field label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Default value when field is empty
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notifications enabled description
  ///
  /// In en, this message translates to:
  /// **'Stay updated with personalized tips'**
  String get stayUpdatedWithPersonalizedTips;

  /// Notifications disabled description
  ///
  /// In en, this message translates to:
  /// **'Enable for personalized reminders'**
  String get enableForPersonalizedReminders;

  /// Enable button text
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Notification settings page title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Notification settings description
  ///
  /// In en, this message translates to:
  /// **'Manage your alerts and reminders'**
  String get manageYourAlertsAndReminders;

  /// Privacy settings title
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// Privacy settings description
  ///
  /// In en, this message translates to:
  /// **'Control your data and privacy'**
  String get controlYourDataAndPrivacy;

  /// Profile setup title
  ///
  /// In en, this message translates to:
  /// **'Complete Profile Setup'**
  String get completeProfileSetup;

  /// Profile setup description
  ///
  /// In en, this message translates to:
  /// **'Update your personal information and preferences'**
  String get updateYourPersonalInformation;

  /// App preferences title
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// App preferences description
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get customizeYourAppExperience;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language setting description
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectYourPreferredLanguage;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out description
  ///
  /// In en, this message translates to:
  /// **'Logout from your account'**
  String get logoutFromYourAccount;

  /// Sign out confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// Sign out confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get signOutConfirmMessage;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Edit personal info dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Info'**
  String get editPersonalInfo;

  /// Age field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterYourAge;

  /// Height field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterYourHeight;

  /// Weight field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterYourWeight;

  /// Sex/Gender field label
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Success message for profile update
  ///
  /// In en, this message translates to:
  /// **'Personal information updated successfully!'**
  String get personalInformationUpdated;

  /// Error message for profile save failure
  ///
  /// In en, this message translates to:
  /// **'Error saving information: {error}'**
  String errorSavingInformation(String error);

  /// Success message for data sync
  ///
  /// In en, this message translates to:
  /// **'Data synced to cloud storage!'**
  String get dataSyncedToCloud;

  /// Error message for sync failure
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// Error message for logout failure
  ///
  /// In en, this message translates to:
  /// **'Failed to logout: {error}'**
  String failedToLogout(String error);

  /// Carbon dioxide unit
  ///
  /// In en, this message translates to:
  /// **'kg CO₂'**
  String get kgCO2;

  /// Days unit label
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Total count unit
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// Unlocked achievements unit
  ///
  /// In en, this message translates to:
  /// **'unlocked'**
  String get unlocked;

  /// Kilogram unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// Centimeter unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// Years unit
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Main dashboard title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Exercise tab label
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// Nutrition tab label
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// Sleep tab label
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// Today's goals section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goals'**
  String get todaysGoals;

  /// Today's focus section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Focus'**
  String get todaysFocus;

  /// Workout streak counter
  ///
  /// In en, this message translates to:
  /// **'Workout Streak'**
  String get workoutStreak;

  /// Sleep quality metric
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// Sustainability score metric
  ///
  /// In en, this message translates to:
  /// **'Sustainability Score'**
  String get sustainabilityScore;

  /// Log meal button text
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMeal;

  /// Start workout button text
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// Track sleep button text
  ///
  /// In en, this message translates to:
  /// **'Track Sleep'**
  String get trackSleep;

  /// View progress button text
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// Greeting message with time of day
  ///
  /// In en, this message translates to:
  /// **'Good {timeOfDay}'**
  String greeting(String timeOfDay);

  /// Morning time period
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// Afternoon time period
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// Evening time period
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Daily sustainability tip
  ///
  /// In en, this message translates to:
  /// **'Did you know? Walking or cycling for just 30 minutes instead of driving can save up to 2.6 kg of CO₂ emissions! 🚴‍♀️'**
  String get sustainabilityTip;

  /// Nutrition screen title
  ///
  /// In en, this message translates to:
  /// **'Your Nutrition Hub'**
  String get nutritionHub;

  /// Nutrition screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Smart food analysis powered by AI for healthier, sustainable choices'**
  String get aiPoweredNutrition;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// My workouts screen title
  ///
  /// In en, this message translates to:
  /// **'My Workouts'**
  String get myWorkouts;

  /// Workout history screen title
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// AI workout generator title
  ///
  /// In en, this message translates to:
  /// **'AI Workout Generator'**
  String get aiWorkoutGenerator;

  /// Food logging screen title
  ///
  /// In en, this message translates to:
  /// **'Food Logging'**
  String get foodLogging;

  /// Meal plans screen title
  ///
  /// In en, this message translates to:
  /// **'Meal Plans'**
  String get mealPlans;

  /// Nutrition insights screen title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Insights'**
  String get nutritionInsights;

  /// Sleep tracking screen title
  ///
  /// In en, this message translates to:
  /// **'Sleep Tracking'**
  String get sleepTracking;

  /// Sleep analysis screen title
  ///
  /// In en, this message translates to:
  /// **'Sleep Analysis'**
  String get sleepAnalysis;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Welcome back greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Default user title for eco-conscious users
  ///
  /// In en, this message translates to:
  /// **'Eco Warrior'**
  String get ecoWarrior;

  /// Daily progress label
  ///
  /// In en, this message translates to:
  /// **'Daily Progress'**
  String get dailyProgress;

  /// Progress completion label
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Day streak counter label
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// Calories label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// Daily quote section title
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get quoteOfTheDay;

  /// AI workout subtitle
  ///
  /// In en, this message translates to:
  /// **'AI Workouts'**
  String get aiWorkouts;

  /// Meal tracking subtitle
  ///
  /// In en, this message translates to:
  /// **'Meal Tracking'**
  String get mealTracking;

  /// Progress subtitle
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// Sustainability mission title
  ///
  /// In en, this message translates to:
  /// **'Sustainability Mission'**
  String get sustainabilityMission;

  /// Daily eco tip section title
  ///
  /// In en, this message translates to:
  /// **'Daily Eco Tip'**
  String get dailyEcoTip;

  /// Demo notification message
  ///
  /// In en, this message translates to:
  /// **'Sample notifications created! (Demo functionality)'**
  String get sampleNotificationsCreated;

  /// Wellness journey continuation message
  ///
  /// In en, this message translates to:
  /// **'Ready to continue your wellness journey?'**
  String get readyToContinueWellnessJourney;

  /// Daily health quote
  ///
  /// In en, this message translates to:
  /// **'\"The groundwork for all happiness is good health.\"'**
  String get healthQuote;

  /// Sustainability mission description text
  ///
  /// In en, this message translates to:
  /// **'Every small action creates a ripple effect. Start your sustainable journey today and watch your positive impact grow with each healthy choice you make.'**
  String get sustainabilityMissionDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
