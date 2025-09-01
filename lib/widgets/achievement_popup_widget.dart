import 'package:flutter/material.dart';
import 'dart:math' as math;

class AchievementPopupWidget extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const AchievementPopupWidget({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  });

  @override
  State<AchievementPopupWidget> createState() => _AchievementPopupWidgetState();

  /// Show the achievement popup
  static void show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    print('AchievementPopupWidget.show called with title: $title');
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => AchievementPopupWidget(
        title: title,
        message: message,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Convenience methods for different achievement types
  static void showExerciseCompletion(BuildContext context, String exerciseName) {
    print('AchievementPopupWidget.showExerciseCompletion called for: $exerciseName');
    show(
      context,
      title: 'Workout Complete! 💪',
      message: 'Great job finishing your $exerciseName workout!',
    );
  }

  static void showNutritionLogged(BuildContext context) {
    show(
      context,
      title: 'Nutrition Logged! 🥗',
      message: 'Keep track of your healthy eating habits!',
    );
  }

  static void showSleepLogged(BuildContext context, String hours) {
    show(
      context,
      title: 'Sleep Tracked! 😴',
      message: 'You slept for $hours hours. Rest well for better health!',
    );
  }
}

class _AchievementPopupWidgetState extends State<AchievementPopupWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  String? _randomGif;
  final List<String> _celebrationGifs = <String>[
    'assets/gif/widget/clapping.gif',
    'assets/gif/widget/good.gif',
    'assets/gif/widget/like.gif',
    'assets/gif/widget/perfect.gif',
    'assets/gif/widget/wow.gif',
    'assets/gif/widget/yes.gif',
    'assets/gif/widget/yesyes.gif',
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomGif();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _selectRandomGif() {
    final math.Random random = math.Random();
    _randomGif = _celebrationGifs[random.nextInt(_celebrationGifs.length)];
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimationSequence() {
    _animationController.forward();
    _scaleController.repeat(reverse: true);
    
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismissPopup();
      }
    });
  }

  void _dismissPopup() {
    _animationController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _opacityAnimation.value),
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark ? <Color>[
                        const Color(0xFF2C1810),
                        const Color(0xFF1A237E),
                      ] : <Color>[
                        const Color(0xFFFFF3E0),
                        const Color(0xFFE8EAF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Celebration GIF
                      if (_randomGif != null)
                        AnimatedBuilder(
                          animation: _scaleController,
                          builder: (BuildContext context, Widget? child) {
                            return Transform.scale(
                              scale: 1.0 + (_scaleController.value * 0.1),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    _randomGif!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Achievement Title
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Achievement Message
                      Text(
                        widget.message,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Close Button
                      TextButton(
                        onPressed: _dismissPopup,
                        style: TextButton.styleFrom(
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Awesome!',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
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
}