import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../auth/presentation/providers/auth_providers.dart';
import 'package:ghiraas/features/exercise/presentation/providers/workout_providers.dart';
import 'package:ghiraas/features/exercise/data/models/workout_models.dart';
import 'package:ghiraas/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:ghiraas/features/sleep/presentation/providers/sleep_providers.dart';
import 'package:ghiraas/features/nutrition/data/models/nutrition_models.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../widgets/mcp_command_chat.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _dailyGoalAnimationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _heroOpacityAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _floatingAnimation;
  
  // Dynamic GIF and Avatar cycle system
  bool _showGreeting = true;
  bool _showAvatar = false;
  bool _showRandomGif = false;
  String? _currentAvatar;
  String? _currentGif;
  
  final List<String> _avatars = <String>[
    'assets/images/avatars/avatar1.png',
    'assets/images/avatars/avatar2.png',
    'assets/images/avatars/avatar3.png',
  ];
  
  final List<String> _homeGifs = <String>[
    'assets/gif/home/heart.gif',
    'assets/gif/home/greeting.gif',
    'assets/gif/home/running.gif',
    'assets/gif/home/swinging.gif',
    'assets/gif/home/walking.gif',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _dailyGoalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000), // Slower for more natural floating
      vsync: this,
    );

    _heroScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.elasticOut,
    ));

    _heroOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOutSine, // More natural floating curve
    ));

    // Initialize GIF cycle system
    _initializeGifCycle();

    // Start animations
    _heroAnimationController.forward();
    _cardAnimationController.forward(from: 0.2);
    _dailyGoalAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
  }

  void _initializeGifCycle() {
    // Start with greeting GIF
    _selectRandomAvatar();
    _selectRandomHomeGif();
    
    // Start the cycle: greeting -> avatar -> random gif -> repeat 3 times
    _startGifCycleLoop();
  }
  
  void _selectRandomAvatar() {
    final math.Random random = math.Random();
    _currentAvatar = _avatars[random.nextInt(_avatars.length)];
  }
  
  void _selectRandomHomeGif() {
    final math.Random random = math.Random();
    _currentGif = _homeGifs[random.nextInt(_homeGifs.length)];
  }
  
  void _startGifCycleLoop() {
    _startGifSequence(0); // Start with cycle 0
  }
  
  void _startGifSequence(int cycleCount) {
    // Show greeting.gif for 6 seconds (slower)
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _showGreeting = false;
          _showAvatar = true;
        });
        
        // Show avatar for 5 seconds (increased duration)
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showAvatar = false;
              _showRandomGif = true;
            });
            
            // Show random GIF for 6 seconds (slower)
            Future.delayed(const Duration(seconds: 6), () {
              if (mounted) {
                // Check if we've completed 3 cycles
                if (cycleCount < 2) { // 0, 1, 2 = 3 cycles
                  // Continue with same GIFs for next cycle
                  setState(() {
                    _showRandomGif = false;
                    _showGreeting = true;
                  });
                  _startGifSequence(cycleCount + 1); // Next cycle with same GIFs
                } else {
                  // After 3 cycles, pick new GIFs and restart
                  setState(() {
                    _showRandomGif = false;
                    _showGreeting = true;
                  });
                  _selectRandomAvatar(); // Pick new random avatar
                  _selectRandomHomeGif(); // Pick new random GIF
                  _startGifSequence(0); // Restart with new GIFs
                }
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _cardAnimationController.dispose();
    _dailyGoalAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserEntity?> userAsyncValue =
        ref.watch(currentUserProvider);
    final UserEntity? user = userAsyncValue.value;

    final AsyncValue<List<ActiveWorkoutSession>> completedWorkoutsAsync =
        ref.watch(completedWorkoutsProvider);
    final List<ActiveWorkoutSession>? completedWorkouts =
        completedWorkoutsAsync.value;
    final int streak =
        completedWorkouts != null ? _calculateStreak(completedWorkouts) : 0;
    
    // Get real Firebase notifications count
    final int unreadNotificationsCount = ref.watch(unreadNotificationsCountProvider);
    
    // Nutrition & Sleep stats
    final AsyncValue<DailyNutritionSummary> dailySummaryAsync =
        ref.watch(dailyNutritionSummaryProvider);
    final int caloriesEaten = dailySummaryAsync.maybeWhen(
        data: (DailyNutritionSummary s) => s.totalNutrition.calories,
        orElse: () => 0);

    final AsyncValue<Duration> sleepDurationAsync =
        ref.watch(sleepDurationProvider);
    final Duration avgSleepDuration = sleepDurationAsync.maybeWhen(
        data: (Duration d) => d, orElse: () => Duration.zero);
    final String avgSleepStr = avgSleepDuration == Duration.zero
        ? '--'
        : '${avgSleepDuration.inHours}h ${avgSleepDuration.inMinutes % 60}m';

    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      // Modern App Bar with real Firebase notifications count
      appBar: _buildModernAppBar(context, cs, isDark, user, unreadNotificationsCount),
      body: Stack(
        children: <Widget>[
          // Enhanced 3D Background Animation
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _heroAnimationController,
                builder: (BuildContext context, Widget? child) {
                  return Transform.scale(
                    scale: 1.0 + (_heroAnimationController.value * 0.1),
                    child: Opacity(
                      opacity: isDark ? 0.15 : 0.08,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.5,
                            colors: <Color>[
                              cs.primary.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Main Content with Enhanced Animations
          SlideTransition(
            position: _cardSlideAnimation,
            child: FadeTransition(
              opacity: _heroOpacityAnimation,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 16),
                          
                          // Unified Professional Welcome Card
                          _buildUnifiedWelcomeCard(context, cs, isDark, user, streak, caloriesEaten, avgSleepStr),
                          const SizedBox(height: 28),

                          // Quick Actions with improved layout
                          _buildSectionHeader(context, cs, AppLocalizations.of(context)!.quickActions, Icons.dashboard_outlined),
                          const SizedBox(height: 20),
                          _buildEnhanced3DQuickActionsGrid(context, cs, isDark),
                          const SizedBox(height: 32),

                          // Today's Focus with Modern Design
                          _buildSectionHeader(context, cs, AppLocalizations.of(context)!.todaysFocus, Icons.eco_outlined),
                          const SizedBox(height: 20),
                          _buildModernFocusCard(context, cs, isDark),
                          const SizedBox(height: 28),

                          // Enhanced Sustainability Tips
                          _buildModernSustainabilityTips(context, cs, isDark),
                          const SizedBox(height: 100), // Space for bottom navigation
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // AI Assistant Floating Action Button
      floatingActionButton: _buildAIAssistantFAB(context, cs, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildModernAppBar(
      BuildContext context, ColorScheme cs, bool isDark, UserEntity? user, int unreadCount) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              cs.primaryContainer.withValues(alpha: 0.3),
              cs.surface,
            ],
          ),
        ),
      ),
      title: ScaleTransition(
        scale: _heroScaleAnimation,
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    cs.primary,
                    cs.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.eco,
                color: cs.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.appName,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_getGreeting()}, ${user?.displayName?.split(' ').first ?? AppLocalizations.of(context)!.sustainabilityChampion}!',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onLongPress: _createSampleNotifications, // Long press to create sample notifications
            child: IconButton(
              onPressed: () {
                context.go('/notifications');
              },
              icon: Stack(
                children: <Widget>[
                  Icon(
                    Icons.notifications_outlined,
                    color: cs.onSurface,
                    size: 24,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: cs.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: TextStyle(
                              color: cs.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Unified Professional Welcome Card - Clean Professional Design
  Widget _buildUnifiedWelcomeCard(
      BuildContext context, ColorScheme cs, bool isDark, UserEntity? user,
      int streak, int caloriesEaten, String avgSleepStr) {
    
    // Professional gradient colors
    final Color primaryColor = cs.primary;
    final Color secondaryColor = cs.secondary;

    return AnimatedBuilder(
      animation: _dailyGoalAnimationController,
      builder: (BuildContext context, Widget? child) {
        return Container(
          margin: EdgeInsets.zero, // Remove horizontal margin to match other widgets
          decoration: BoxDecoration(
            // Gradient border effect using container decoration
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.6),
                secondaryColor.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3), // Creates the gradient border
            padding: const EdgeInsets.all(20), // Reduced from 24
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(21),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.surfaceContainer,
                  cs.surfaceContainerHigh,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting (no duplicate logo - removed icon)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ).createShader(bounds),
                      child: Text(
                        user?.displayName ?? 'Welcome Back!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced from 8
                    Text(
                      AppLocalizations.of(context)!.readyToContinueWellnessJourney,
                      style: TextStyle(
                        fontSize: 15,
                        color: cs.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24), // Reduced from 32
                
                // Enhanced 3D Character Display with larger static frame and gradient border
                Container(
                  height: 180, // Reduced from 220
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // Gradient border effect for 3D frame
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        secondaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2), // Reduced from 3 to reduce border thickness
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.surfaceContainerHighest,
                          cs.surfaceContainerHigh,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18), // Adjusted to match reduced margin
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle background pattern
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18), // Adjusted to match
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.5,
                                colors: [
                                  primaryColor.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Floating 3D content inside the frame (reduced range) with minimal padding
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            final double floatOffset = math.sin(_floatingAnimation.value * 2 * math.pi) * 3; // Reduced range for lower floating
                            
                            return Transform.translate(
                              offset: Offset(0, floatOffset),
                              child: Container(
                                padding: const EdgeInsets.all(8), // Minimal padding for more realistic feel
                                child: _showGreeting
                                    ? Image.asset(
                                        'assets/gif/home/greeting.gif',
                                        height: 160, // Increased to fill more space
                                        fit: BoxFit.contain,
                                      )
                                    : _showAvatar && _currentAvatar != null
                                        ? Image.asset(
                                            _currentAvatar!,
                                            height: 160, // Increased to fill more space
                                            fit: BoxFit.contain,
                                          )
                                        : _showRandomGif && _currentGif != null
                                            ? Image.asset(
                                                _currentGif!,
                                                height: 160, // Increased to fill more space
                                                fit: BoxFit.contain,
                                              )
                                            : Container(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24), // Reduced from 32
                
                // Stats row with proper alignment
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedStatCard(
                        cs, isDark, '$streak', AppLocalizations.of(context)!.dayStreak, Icons.local_fire_department_outlined, 
                        const Color(0xFFFF6B35)
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedStatCard(
                        cs, isDark, '${caloriesEaten}cal', AppLocalizations.of(context)!.calories, Icons.restaurant_outlined,
                        const Color(0xFF4CAF50)
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedStatCard(
                        cs, isDark, avgSleepStr, AppLocalizations.of(context)!.sleep, Icons.bedtime_outlined,
                        const Color(0xFF9C27B0)
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24), // Reduced from 32
                
                // Enhanced Quote of the Day Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20), // Reduced from 24
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.08),
                        secondaryColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.format_quote_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ).createShader(bounds),
                            child: Text(
                              AppLocalizations.of(context)!.quoteOfTheDay,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14), // Reduced from 16
                      Text(
                        AppLocalizations.of(context)!.healthQuote,
                        style: TextStyle(
                          fontSize: 17, // Reduced from 18
                          fontStyle: FontStyle.italic,
                          color: cs.onSurface.withOpacity(0.9),
                          height: 1.4, // Reduced from 1.5
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6), // Reduced from 8
                      Text(
                        '— Leigh Hunt',
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedStatCard(ColorScheme cs, bool isDark, String value, String label, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14), // Reduced from 16
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest,
            cs.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced from 10
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.8),
                  accentColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18, // Reduced from 20
            ),
          ),
          const SizedBox(height: 10), // Reduced from 12
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 15, // Reduced from 16
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3), // Reduced from 4
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.7),
              fontSize: 11, // Reduced from 12
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, ColorScheme cs, String title, IconData icon) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhanced3DQuickActionsGrid(BuildContext context, ColorScheme cs, bool isDark) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Map<String, Object>> quickActions = <Map<String, Object>>[
      <String, Object>{
        'title': l10n.exercise,
        'subtitle': l10n.aiWorkouts,
        'icon': Icons.fitness_center_outlined,
        'route': '/exercise',
        'color': const Color(0xFF2196F3),
      },
      <String, Object>{
        'title': l10n.nutrition,
        'subtitle': l10n.mealTracking,
        'icon': Icons.restaurant_outlined,
        'route': '/nutrition',
        'color': const Color(0xFF4CAF50),
      },
      <String, Object>{
        'title': l10n.sleep,
        'subtitle': l10n.sleepTracking,
        'icon': Icons.bedtime_outlined,
        'route': '/sleep',
        'color': const Color(0xFF9C27B0),
      },
      <String, Object>{
        'title': l10n.profile,
        'subtitle': l10n.yourProgress,
        'icon': Icons.person_outline,
        'route': '/profile',
        'color': const Color(0xFFFF9800),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0, // Perfect square for equal sizing
      ),
      itemCount: quickActions.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, Object> action = quickActions[index];
        return _buildEnhanced3DQuickActionCard(context, cs, isDark, action, index);
      },
    );
  }

  Widget _buildEnhanced3DQuickActionCard(
      BuildContext context, ColorScheme cs, bool isDark, Map<String, dynamic> action, int index) {
    final Color actionColor = action['color'] as Color;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (BuildContext context, double animationValue, Widget? child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            height: 140, // Fixed height for equal sizing
            decoration: BoxDecoration(
              color: isDark 
                ? cs.surfaceContainer
                : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: actionColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.go(action['route'] as String),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          size: 28,
                          color: actionColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        action['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernFocusCard(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? <Color>[
            cs.tertiaryContainer.withValues(alpha: 0.5),
            cs.surfaceContainerHigh,
          ] : <Color>[
            cs.tertiaryContainer,
            cs.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.tertiary.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      cs.tertiary,
                      cs.tertiary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: cs.tertiary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.eco,
                  color: cs.onTertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.sustainabilityMission,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.sustainabilityMissionDescription,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: cs.onTertiaryContainer.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/exercise'),
                  icon: const Icon(Icons.fitness_center, size: 18),
                  label: Text(AppLocalizations.of(context)!.startWorkout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.tertiary,
                    foregroundColor: cs.onTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/nutrition'),
                  icon: const Icon(Icons.restaurant, size: 18),
                  label: Text(AppLocalizations.of(context)!.logMeal),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.tertiary,
                    side: BorderSide(color: cs.tertiary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSustainabilityTips(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            cs.surfaceContainerHigh,
            cs.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      cs.secondary.withValues(alpha: 0.2),
                      cs.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: cs.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.dailyEcoTip,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  cs.secondary.withValues(alpha: 0.1),
                  cs.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.secondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: cs.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.sustainabilityTip,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return AppLocalizations.of(context)!.goodMorning;
    } else if (hour < 17) {
      return AppLocalizations.of(context)!.goodAfternoon;
    } else {
      return AppLocalizations.of(context)!.goodEvening;
    }
  }

  Widget _buildAIAssistantFAB(BuildContext context, ColorScheme cs, bool isDark) {
    return AnimatedBuilder(
      animation: _floatingAnimationController,
      builder: (BuildContext context, Widget? child) {
        final double floatOffset = math.sin(_floatingAnimation.value * 2 * math.pi) * 2;
        
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  cs.primary,
                  cs.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showMCPCommandChat(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Main AI icon
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 28,
                        color: cs.onPrimary,
                      ),
                      // Simple active indicator
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMCPCommandChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (BuildContext context) => const MCPCommandChat(),
    );
  }

  // Demo function to create sample Firebase notifications
  void _createSampleNotifications() async {
    try {
      final firebaseActions = ref.read(firebaseNotificationActionsProvider);
      
      // Create sample notifications
      await firebaseActions.createWorkoutNotification(
        title: 'Workout Reminder',
        message: 'Time for your daily exercise! Keep up the great work!',
        actionRoute: '/exercise',
      );
      
      await firebaseActions.createNutritionNotification(
        title: 'Meal Logging',
        message: 'Don\'t forget to log your lunch for better nutrition tracking.',
        actionRoute: '/nutrition',
      );
      
      await firebaseActions.createSustainabilityNotification(
        title: 'Eco Tip',
        message: 'Try using a reusable water bottle today to reduce plastic waste!',
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sample Firebase notifications created!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Fallback to local message if Firebase fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sampleNotificationsCreated),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Calculate numeric streak (days) from completed workouts list
  int _calculateStreak(List<ActiveWorkoutSession> completedWorkouts) {
    if (completedWorkouts.isEmpty) return 0;

    final List<ActiveWorkoutSession> sortedWorkouts = completedWorkouts
        .where((ActiveWorkoutSession w) => w.isCompleted && w.endTime != null)
        .toList()
      ..sort((ActiveWorkoutSession a, ActiveWorkoutSession b) =>
          b.endTime!.compareTo(a.endTime!));

    if (sortedWorkouts.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final ActiveWorkoutSession workout in sortedWorkouts) {
      final DateTime workoutDate = workout.endTime!;
      final int daysDifference = currentDate.difference(workoutDate).inDays;

      if (daysDifference <= 1) {
        streak++;
        currentDate = workoutDate;
      } else {
        break;
      }
    }

    return streak;
  }
}
