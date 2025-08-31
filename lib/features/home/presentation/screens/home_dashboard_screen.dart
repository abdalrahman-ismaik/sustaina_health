import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;
import '../../../auth/presentation/providers/auth_providers.dart';
import 'package:ghiraas/features/exercise/presentation/providers/workout_providers.dart';
import 'package:ghiraas/features/exercise/data/models/workout_models.dart';
import 'package:ghiraas/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:ghiraas/features/sleep/presentation/providers/sleep_providers.dart';
import 'package:ghiraas/features/nutrition/data/models/nutrition_models.dart';

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
  late Animation<double> _pulseAnimation;
  
  // Video player for greeting animation
  VideoPlayerController? _greetingVideoController;
  bool _showGreeting = true;
  bool _isVideoInitialized = false;

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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03, // More subtle pulse effect
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOutSine, // Smoother pulse
    ));

    // Initialize video controller for greeting animation
    _initializeVideo();

    // Start animations
    _heroAnimationController.forward();
    _cardAnimationController.forward(from: 0.2);
    _dailyGoalAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
  }

  Future<void> _initializeVideo() async {
    try {
      _greetingVideoController = VideoPlayerController.asset(
        'assets/videos/greeting_animation.gif.mp4'
      );
      
      await _greetingVideoController!.initialize();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        
        // Play the greeting video
        await _greetingVideoController!.play();
        
        // Listen for video completion
        _greetingVideoController!.addListener(() {
          if (_greetingVideoController!.value.position >= 
              _greetingVideoController!.value.duration) {
            // Video finished, switch to avatar
            if (mounted) {
              setState(() {
                _showGreeting = false;
              });
            }
          }
        });
      }
    } catch (e) {
      // If video fails to load, skip to avatar
      if (mounted) {
        setState(() {
          _showGreeting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _cardAnimationController.dispose();
    _dailyGoalAnimationController.dispose();
    _floatingAnimationController.dispose();
    _greetingVideoController?.dispose();
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
      // Modern App Bar
      appBar: _buildModernAppBar(context, cs, isDark, user),
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
                        child: Lottie.asset(
                          'assets/lottie/particles_green.json',
                          fit: BoxFit.cover,
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
                          
                          // 3D Daily Goal Section (New!)
                          _build3DDailyGoalSection(context, cs, isDark, streak, caloriesEaten, avgSleepStr),
                          const SizedBox(height: 24),
                          
                          // Enhanced Hero Welcome Section
                          _buildEnhancedHeroSection(
                            context, cs, isDark, user, streak, caloriesEaten, avgSleepStr),
                          const SizedBox(height: 32),

                          // Quick Actions with 3D Effects
                          _buildSectionHeader(context, cs, 'Quick Actions', Icons.dashboard_outlined),
                          const SizedBox(height: 16),
                          _buildEnhanced3DQuickActionsGrid(context, cs, isDark),
                          const SizedBox(height: 32),

                          // Today's Focus with Modern Design
                          _buildSectionHeader(context, cs, 'Today\'s Focus', Icons.eco_outlined),
                          const SizedBox(height: 16),
                          _buildModernFocusCard(context, cs, isDark),
                          const SizedBox(height: 24),

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
    );
  }

  PreferredSizeWidget _buildModernAppBar(
      BuildContext context, ColorScheme cs, bool isDark, UserEntity? user) {
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
                  'Sustaina Health',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_getGreeting()}, ${user?.displayName?.split(' ').first ?? 'Eco Warrior'}!',
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
          child: IconButton(
            onPressed: () {
              // Add notification functionality
            },
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.notifications_outlined,
                  color: cs.onSurface,
                  size: 24,
                ),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3DDailyGoalSection(
      BuildContext context, ColorScheme cs, bool isDark, 
      int streak, int caloriesEaten, String avgSleepStr) {
    
    // Calculate overall daily goal progress (example: combine different metrics)
    final double dailyProgress = (streak > 0 ? 0.3 : 0.0) + 
                               (caloriesEaten > 0 ? 0.4 : 0.0) + 
                               (avgSleepStr != '--' ? 0.3 : 0.0);
    final int progressPercentage = (dailyProgress.clamp(0.0, 1.0) * 100).round();

    return AnimatedBuilder(
      animation: _dailyGoalAnimationController,
      builder: (BuildContext context, Widget? child) {
        return Container(
          height: 320, // Increased height for larger elements
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? <Color>[
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ] : <Color>[
                const Color(0xFFF8F9FA),
                const Color(0xFFE3F2FD),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: cs.primary.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              if (isDark) BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, 0),
                spreadRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              // Left side - Stats and Title
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'DAILY GOAL',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: progressPercentage.toDouble(),
                          ),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          builder: (BuildContext context, double value, Widget? child) {
                            return Text(
                              value.round().toString(),
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            );
                          },
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mini stats
                    _build3DMiniStat(cs, Icons.local_fire_department, '$streak', 'streak', 
                        const Color(0xFFFF6B6B)),
                    const SizedBox(height: 8),
                    _build3DMiniStat(cs, Icons.restaurant_outlined, '$caloriesEaten', 'calories', 
                        const Color(0xFF4ECDC4)),
                    const SizedBox(height: 8),
                    _build3DMiniStat(cs, Icons.bedtime_outlined, avgSleepStr, 'sleep', 
                        const Color(0xFF45B7D1)),
                  ],
                ),
              ),
              
              // Right side - 3D Character with floating platform
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Floating platform with rainbow effect
                    Positioned(
                      bottom: 15,
                      child: AnimatedBuilder(
                        animation: _floatingAnimationController,
                        builder: (BuildContext context, Widget? child) {
                          // Smoother floating motion with sine and cosine combination
                          final double floatOffset = (math.sin(_floatingAnimation.value * 2 * math.pi) * 3) +
                                                   (math.cos(_floatingAnimation.value * 3 * math.pi) * 1);
                          return Transform.translate(
                            offset: Offset(0, floatOffset),
                            child: Container(
                              width: 160, // Increased platform size
                              height: 15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(75),
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    const Color(0xFF4ECDC4).withValues(alpha: 0.7),
                                    const Color(0xFF44A08D).withValues(alpha: 0.8),
                                    const Color(0xFF093637).withValues(alpha: 0.7),
                                    const Color(0xFF44A08D).withValues(alpha: 0.8),
                                    const Color(0xFF4ECDC4).withValues(alpha: 0.7),
                                  ],
                                  stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // 3D Character - Show greeting video first, then avatar
                    AnimatedBuilder(
                      animation: _floatingAnimationController,
                      builder: (BuildContext context, Widget? child) {
                        if (_showGreeting && _isVideoInitialized && _greetingVideoController != null) {
                          // Show greeting video with transparent background
                          return Container(
                            width: 160, // Increased size
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                color: Colors.transparent, // Remove black background
                                child: FittedBox(
                                  fit: BoxFit.cover, // Better video fitting
                                  child: SizedBox(
                                    width: _greetingVideoController!.value.size.width,
                                    height: _greetingVideoController!.value.size.height,
                                    child: VideoPlayer(_greetingVideoController!),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Show floating avatar after greeting with improved animation
                          final double floatOffset = (math.sin(_floatingAnimation.value * 2 * math.pi) * 4) +
                                                   (math.cos(_floatingAnimation.value * 1.5 * math.pi) * 2);
                          return Transform.translate(
                            offset: Offset(0, floatOffset),
                            child: Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  // Avatar image with improved size and animation
                                  Container(
                                    width: 160, // Increased size
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: const Color(0xFF667EEA).withValues(alpha: 0.5),
                                          blurRadius: 25,
                                          offset: const Offset(0, 12),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF764BA2).withValues(alpha: 0.3),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                      image: const DecorationImage(
                                        image: AssetImage('assets/videos/avatar.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  
                                  // Achievement badge
                                  if (progressPercentage > 50)
                                    Positioned(
                                      top: 10,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50),
                                          shape: BoxShape.circle,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DMiniStat(ColorScheme cs, IconData icon, String value, String label, Color accentColor) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedHeroSection(
      BuildContext context, ColorScheme cs, bool isDark, UserEntity? user, 
      int streak, int caloriesEaten, String avgSleepStr) {
    return ScaleTransition(
      scale: _heroScaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? <Color>[
              cs.primaryContainer.withValues(alpha: 0.8),
              cs.surfaceContainerHigh,
            ] : <Color>[
              cs.primaryContainer,
              cs.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        cs.primary,
                        cs.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 32,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.displayName?.split(' ').first ?? 'Eco Warrior',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready for another sustainable day? 🌱',
                        style: TextStyle(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Enhanced Stats Row with 3D Cards
            Row(
              children: <Widget>[
                Expanded(child: _build3DStatCard(cs, isDark, streak.toString(), 'Day Streak', Icons.local_fire_department, cs.error)),
                const SizedBox(width: 12),
                Expanded(child: _build3DStatCard(cs, isDark, '$caloriesEaten', 'Calories', Icons.restaurant_outlined, cs.tertiary)),
                const SizedBox(width: 12),
                Expanded(child: _build3DStatCard(cs, isDark, avgSleepStr, 'Sleep', Icons.bedtime_outlined, cs.secondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DStatCard(ColorScheme cs, bool isDark, String value, String label, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            cs.surfaceContainerHigh,
            cs.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          if (isDark) BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
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
            gradient: LinearGradient(
              colors: <Color>[
                cs.primary.withValues(alpha: 0.15),
                cs.primary.withValues(alpha: 0.05),
              ],
            ),
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
    final List<Map<String, Object>> quickActions = <Map<String, Object>>[
      <String, Object>{
        'title': 'Exercise',
        'subtitle': 'AI Workouts',
        'icon': Icons.fitness_center_outlined,
        'route': '/exercise',
        'color': const Color(0xFF2196F3),
      },
      <String, Object>{
        'title': 'Nutrition',
        'subtitle': 'Meal Tracking',
        'icon': Icons.restaurant_outlined,
        'route': '/nutrition',
        'color': const Color(0xFF4CAF50),
      },
      <String, Object>{
        'title': 'Sleep',
        'subtitle': 'Sleep Tracking',
        'icon': Icons.bedtime_outlined,
        'route': '/sleep',
        'color': const Color(0xFF9C27B0),
      },
      <String, Object>{
        'title': 'Profile',
        'subtitle': 'Your Progress',
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  cs.surfaceContainerHigh,
                  cs.surfaceContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: actionColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                if (isDark) BoxShadow(
                  color: actionColor.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 0),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.go(action['route'] as String),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              actionColor.withValues(alpha: 0.2),
                              actionColor.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: actionColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                'Sustainability Mission',
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
            'Every small action creates a ripple effect. Start your sustainable journey today and watch your positive impact grow with each healthy choice you make.',
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
                  label: const Text('Start Workout'),
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
                  label: const Text('Log Meal'),
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
                'Daily Eco Tip',
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
                    'Did you know? Walking or cycling for just 30 minutes instead of driving can save up to 2.6 kg of CO₂ emissions! 🚴‍♀️',
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
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
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
