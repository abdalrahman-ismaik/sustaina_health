// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'غراس';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get welcomeUser => 'أهلاً بك';

  @override
  String get sustainabilityChampion => 'بطل الاستدامة';

  @override
  String get noEmailProvided => 'لم يتم توفير بريد إلكتروني';

  @override
  String get yourImpact => 'تأثيرك';

  @override
  String get carbonSaved => 'الكربون المُوفر';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get workouts => 'التمارين';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get personalDetails => 'التفاصيل الشخصية';

  @override
  String get sync => 'مزامنة';

  @override
  String get syncing => 'جاري المزامنة...';

  @override
  String get edit => 'تعديل';

  @override
  String get weight => 'الوزن';

  @override
  String get height => 'الطول';

  @override
  String get age => 'العمر';

  @override
  String get gender => 'الجنس';

  @override
  String get notSet => 'غير محدد';

  @override
  String get quickActions => 'الإجراءات السريعة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get stayUpdatedWithPersonalizedTips =>
      'ابق على اطلاع بالنصائح المخصصة';

  @override
  String get enableForPersonalizedReminders => 'فعّل للحصول على تذكيرات مخصصة';

  @override
  String get enable => 'تفعيل';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get manageYourAlertsAndReminders => 'إدارة التنبيهات والتذكيرات';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get controlYourDataAndPrivacy => 'تحكم في بياناتك وخصوصيتك';

  @override
  String get completeProfileSetup => 'إكمال إعداد الملف الشخصي';

  @override
  String get updateYourPersonalInformation =>
      'تحديث المعلومات الشخصية والتفضيلات';

  @override
  String get appPreferences => 'تفضيلات التطبيق';

  @override
  String get customizeYourAppExperience => 'خصص تجربة التطبيق الخاصة بك';

  @override
  String get language => 'اللغة';

  @override
  String get selectYourPreferredLanguage => 'اختر اللغة المفضلة لديك';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get logoutFromYourAccount => 'تسجيل الخروج من حسابك';

  @override
  String get signOutConfirmTitle => 'تسجيل الخروج';

  @override
  String get signOutConfirmMessage =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get editPersonalInfo => 'تعديل المعلومات الشخصية';

  @override
  String get enterYourAge => 'أدخل عمرك';

  @override
  String get enterYourHeight => 'أدخل طولك';

  @override
  String get enterYourWeight => 'أدخل وزنك';

  @override
  String get sex => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'آخر';

  @override
  String get save => 'حفظ';

  @override
  String get personalInformationUpdated => 'تم تحديث المعلومات الشخصية بنجاح!';

  @override
  String errorSavingInformation(String error) {
    return 'خطأ في حفظ المعلومات: $error';
  }

  @override
  String get dataSyncedToCloud => 'تم مزامنة البيانات مع التخزين السحابي!';

  @override
  String syncFailed(String error) {
    return 'فشلت المزامنة: $error';
  }

  @override
  String failedToLogout(String error) {
    return 'فشل تسجيل الخروج: $error';
  }

  @override
  String get kgCO2 => 'كجم CO₂';

  @override
  String get days => 'أيام';

  @override
  String get total => 'إجمالي';

  @override
  String get unlocked => 'مفتوحة';

  @override
  String get kg => 'كجم';

  @override
  String get cm => 'سم';

  @override
  String get years => 'سنوات';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get home => 'الرئيسية';

  @override
  String get exercise => 'التمارين';

  @override
  String get nutrition => 'التغذية';

  @override
  String get sleep => 'النوم';

  @override
  String get todaysGoals => 'أهداف اليوم';

  @override
  String get todaysFocus => 'تركيز اليوم';

  @override
  String get workoutStreak => 'سلسلة التمارين';

  @override
  String get sleepQuality => 'جودة النوم';

  @override
  String get sustainabilityScore => 'نقاط الاستدامة';

  @override
  String get logMeal => 'تسجيل الوجبة';

  @override
  String get startWorkout => 'بدء التمرين';

  @override
  String get trackSleep => 'تتبع النوم';

  @override
  String get viewProgress => 'عرض التقدم';

  @override
  String greeting(String timeOfDay) {
    return '$timeOfDay خير';
  }

  @override
  String get morning => 'صباح';

  @override
  String get afternoon => 'ظهر';

  @override
  String get evening => 'مساء';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get sustainabilityTip =>
      'هل تعلم؟ المشي أو ركوب الدراجة لمدة 30 دقيقة فقط بدلاً من القيادة يمكن أن يوفر ما يصل إلى 2.6 كيلوغرام من انبعاثات ثاني أكسيد الكربون! 🚴‍♀️';

  @override
  String get nutritionHub => 'مركز التغذية الخاص بك';

  @override
  String get aiPoweredNutrition =>
      'تحليل ذكي للطعام باستخدام الذكاء الاصطناعي لخيارات صحية ومستدامة';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get myWorkouts => 'تماريني';

  @override
  String get workoutHistory => 'تاريخ التمارين';

  @override
  String get aiWorkoutGenerator => 'مولد التمارين بالذكاء الاصطناعي';

  @override
  String get foodLogging => 'تسجيل الطعام';

  @override
  String get mealPlans => 'خطط الوجبات';

  @override
  String get nutritionInsights => 'رؤى التغذية';

  @override
  String get sleepTracking => 'تتبع النوم';

  @override
  String get sleepAnalysis => 'تحليل النوم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get delete => 'حذف';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get welcomeBack => 'مرحباً بعودتك!';

  @override
  String get ecoWarrior => 'محارب البيئة';

  @override
  String get dailyProgress => 'التقدم اليومي';

  @override
  String get complete => 'مكتمل';

  @override
  String get dayStreak => 'سلسلة الأيام';

  @override
  String get calories => 'السعرات';

  @override
  String get quoteOfTheDay => 'اقتباس اليوم';

  @override
  String get aiWorkouts => 'تمارين ذكية';

  @override
  String get mealTracking => 'تتبع الوجبات';

  @override
  String get yourProgress => 'تقدمك';

  @override
  String get sustainabilityMission => 'مهمة الاستدامة';

  @override
  String get dailyEcoTip => 'نصيحة بيئية يومية';

  @override
  String get sampleNotificationsCreated =>
      'تم إنشاء إشعارات عينة! (وظيفة تجريبية)';

  @override
  String get readyToContinueWellnessJourney =>
      'مستعد لمواصلة رحلة الصحة والعافية؟';

  @override
  String get healthQuote => '\"أساس كل سعادة هو الصحة الجيدة.\"';

  @override
  String get sustainabilityMissionDescription =>
      'كل عمل صغير يخلق أثراً متموجاً. ابدأ رحلتك المستدامة اليوم وشاهد تأثيرك الإيجابي ينمو مع كل خيار صحي تتخذه.';
}
