import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An engaging, game-like loading widget for sustainability-focused health apps.
/// Features interactive mini-games, progress tracking, and educational content
/// to keep users engaged during AI operations.
class InteractiveLoading extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onCancel;
  final bool compact;
  final Color? color;

  const InteractiveLoading({
    super.key,
    required this.title,
    this.subtitle,
    this.onCancel,
    this.compact = false,
    this.color,
  });

  @override
  State<InteractiveLoading> createState() => _InteractiveLoadingState();
}

class _InteractiveLoadingState extends State<InteractiveLoading>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  Timer? _tipTimer;
  int _tipIndex = 0;
  int _score = 0;
  int _streak = 0;
  bool _isGameActive = false;
  double _carbonSaved = 0.0;
  int _treesPlanted = 0;
  // Game state (quiz-only)
  GameType _currentGameType = GameType.none;
  bool _gameCompleted = false;
  List<String> _currentChoices = <String>[];
  int _correctChoice = -1;
  // Per-game interaction state
  int _selectedChoice = -1;
  bool _choiceLocked = false;
  // store current challenge points so _endGame can award correctly
  int _currentChallengePoints = 0;
  int _currentChallengeIndex = -1;
  // quiz queue to avoid repeats until pool exhausted
  List<int> _remainingQuizIndexes = <int>[];

  static const List<SustainabilityTip> _tips = <SustainabilityTip>[
    SustainabilityTip(
      text: 'Eating 1 less burger per week saves 52 lbs of CO₂ annually!',
      carbonImpact: 2.3,
      icon: Icons.eco,
    ),
    SustainabilityTip(
      text: 'Walking 30 minutes daily burns calories AND reduces emissions!',
      carbonImpact: 1.8,
      icon: Icons.directions_walk,
    ),
    SustainabilityTip(
      text: 'Plant-based proteins use 90% less water than meat!',
      carbonImpact: 3.1,
      icon: Icons.water_drop,
    ),
    SustainabilityTip(
      text: 'Seasonal eating reduces food miles by up to 70%!',
      carbonImpact: 2.7,
      icon: Icons.local_florist,
    ),
    SustainabilityTip(
      text: 'Home workouts save transportation emissions!',
      carbonImpact: 1.5,
      icon: Icons.home,
    ),
    SustainabilityTip(
      text: 'Reducing food waste by 25% = planting 3 trees worth of CO₂!',
      carbonImpact: 4.2,
      icon: Icons.recycling,
    ),
  ];

  static const List<GameChallenge> _gameChallenges = <GameChallenge>[
    GameChallenge(
      type: GameType.quiz,
      question:
          'Which food has the lowest greenhouse gas emissions (carbon footprint)?',
      choices: <String>['Beef', 'Pork', 'Chicken', 'Lentils'],
      // Lentils are a low-impact plant protein
      correctAnswer: 3,
      points: 20,
    ),
    GameChallenge(
      type: GameType.quiz,
      question:
          'Which action typically reduces the most greenhouse gas emissions annually?',
      choices: <String>[
        'Eating less meat',
        'Shorter showers',
        'Turning off the tap while brushing',
        'Using energy-efficient bulbs'
      ],
      // Dietary shifts (less meat) generally have the largest impact per person
      correctAnswer: 0,
      points: 20,
    ),
    GameChallenge(
      type: GameType.quiz,
      question: 'Which of these is a plant-based protein?',
      choices: <String>['Tofu', 'Chicken', 'Cheese', 'Fish'],
      correctAnswer: 0,
      points: 15,
    ),
    GameChallenge(
      type: GameType.quiz,
      question: 'Which transport mode has the lowest emissions per km?',
      choices: <String>['Bike', 'Car', 'Bus', 'Plane'],
      correctAnswer: 0,
      points: 15,
    ),
    GameChallenge(
      type: GameType.quiz,
      question: 'Which food typically requires the least water to produce?',
      choices: <String>['Lentils', 'Rice', 'Almonds', 'Beef'],
      correctAnswer: 0,
      points: 15,
    ),
    GameChallenge(
      type: GameType.quiz,
      question:
          'What household change often reduces heating/cooling energy the most?',
      choices: <String>['Insulation', 'LED bulbs', 'Unplug devices', 'Shorter showers'],
      correctAnswer: 0,
      points: 15,
    ),
    GameChallenge(
      type: GameType.quiz,
      question: 'Which practice most directly reduces food waste?',
      choices: <String>[
        'Meal planning',
        'Buying in bulk',
        'Eating out',
        'Using plastic wrap'
      ],
      correctAnswer: 0,
      points: 10,
    ),
    GameChallenge(
      type: GameType.quiz,
      question: 'Which protein is generally most climate-friendly?',
      choices: <String>['Beans', 'Beef', 'Lamb', 'Pork'],
      correctAnswer: 0,
      points: 15,
    ),
    // removed non-quiz challenges; preserved only quiz entries
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTipRotation();
    _prepareQuizQueue();
    _startRandomQuiz();
  }

  void _prepareQuizQueue() {
    _remainingQuizIndexes = List<int>.generate(_gameChallenges.length, (int i) => i)
        .where((int i) => _gameChallenges[i].type == GameType.quiz)
        .toList();
    _remainingQuizIndexes.shuffle();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startTipRotation() {
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (!mounted) return;
      setState(() {
        _tipIndex = (_tipIndex + 1) % _tips.length;
        _carbonSaved += _tips[_tipIndex].carbonImpact;
        if (_carbonSaved >= 10) {
          _treesPlanted++;
          _carbonSaved = 0;
        }
      });
    });
  }

  // non-quiz game starters removed; quiz uses _startRandomQuiz

  void _startRandomQuiz() {
    if (_remainingQuizIndexes.isEmpty) {
      _prepareQuizQueue();
    }
    if (_remainingQuizIndexes.isEmpty) return; // nothing to show
    final int challengeIndex = _remainingQuizIndexes.removeLast();
    final GameChallenge challenge = _gameChallenges[challengeIndex];

    setState(() {
      _currentGameType = GameType.quiz;
      _isGameActive = true;
      _gameCompleted = false;
      _selectedChoice = -1;
      _choiceLocked = false;
      _currentChoices = List.from(challenge.choices);
      _correctChoice = challenge.correctAnswer;
      _currentChallengePoints = challenge.points;
      _currentChallengeIndex = challengeIndex;
    });

    // shuffle choices and update correct index
    final String correct = _currentChoices[_correctChoice];
    _currentChoices.shuffle();
    _correctChoice = _currentChoices.indexOf(correct);
  }

  // helper functions for removed mini-games were deleted

  // countdown removed for quiz-only flow

  void _endGame(bool won) {
    setState(() {
      _isGameActive = false;
      _gameCompleted = won;
      _choiceLocked = false;
      _selectedChoice = -1;
    });

    if (won) {
      setState(() {
        _score += _currentChallengePoints;
        _streak++;
        _carbonSaved += 1.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Awesome! +${_currentChallengePoints} points! Streak: $_streak 🌟'),
            duration: const Duration(seconds: 2),
            backgroundColor: widget.color ?? const Color(0xFF40916C),
          ),
        );
      }
    } else {
      setState(() {
        _streak = 0;
      });
    }

    // After showing result, automatically start the next quiz after a short delay
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // Start another quiz round
        _startRandomQuiz();
      }
    });
  }

  void _handleGameAction(action) {
    if (!_isGameActive || _gameCompleted) return;

    if (_currentGameType == GameType.quiz) {
      _handleQuizAnswer(action as int);
    }
  }

  void _handleQuizAnswer(int selectedIndex) {
    _endGame(selectedIndex == _correctChoice);
  }

  // non-quiz handlers removed (quiz-only)

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _tipTimer?.cancel();
    // quiz-only flow: no game timers to cancel
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme cs = theme.colorScheme;
  final Color accent = widget.color ?? cs.secondary;

    if (widget.compact) {
      return _buildCompactView(accent);
    }

    return _buildFullView(accent);
  }

  Widget _buildCompactView(Color accent) {
    return SizedBox(
      height: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (BuildContext context, Widget? child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Icon(Icons.eco, color: accent, size: 24),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Score: $_score | CO₂: ${_carbonSaved.toStringAsFixed(1)}kg',
                    style: TextStyle(
                      fontSize: 11,
                      color: accent,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (widget.onCancel != null) ...<Widget>[
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: TextButton(
                  onPressed: widget.onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
      child: Text(
        'Cancel',
        style: Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(fontSize: 12),
      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullView(Color accent) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          minHeight: 200,
        ),
        child: Card(
          elevation: 12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildHeader(accent),
                  const SizedBox(height: 20),
                  _buildProgressSection(accent),
                  const SizedBox(height: 16),
                  _buildTipSection(accent),
                  const SizedBox(height: 16),
                  _buildGameSection(accent),
                  const SizedBox(height: 20),
                  _buildActionButtons(accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedBuilder(
                animation: _pulseController,
                builder: (BuildContext context, Widget? child) {
                  final double pulseValue = _pulseController.value;
                  return Container(
                    width: 100 + (pulseValue * 20),
                    height: 100 + (pulseValue * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(
                          alpha: (0.10 + pulseValue * 0.10).clamp(0.0, 1.0)),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _rotationController,
                builder: (BuildContext context, Widget? child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accent.withValues(alpha: 0.30),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.eco,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (widget.subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildStatItem('Score', _score.toString(), Icons.star, accent),
            Container(
              width: 1,
              color:
                  Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.30),
            ),
            _buildStatItem('Streak', _streak.toString(),
                Icons.local_fire_department, Theme.of(context).colorScheme.tertiary),
            Container(
              width: 1,
              color:
                  Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.30),
            ),
            _buildStatItem(
                'Trees', _treesPlanted.toString(), Icons.park, Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection(Color accent) {
    final SustainabilityTip currentTip = _tips[_tipIndex];
    return Container(
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(_tipIndex),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.30)),
          ),
          child: Row(
            children: <Widget>[
        Icon(currentTip.icon,
          color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  currentTip.text,
          style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameSection(Color accent) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: SizedBox(
        width: double.infinity,
        child: _isGameActive
            ? _buildActiveGame(accent)
            : _buildWaitingGame(accent),
      ),
    );
  }

  Widget _buildActiveGame(Color accent) {
    if (_currentGameType == GameType.quiz) {
      return _buildQuizGame(accent);
    }
    return _buildWaitingGame(accent);
  }

  Widget _buildQuizGame(Color accent) {
    final GameChallenge challenge = (_currentChallengeIndex >= 0 &&
            _currentChallengeIndex < _gameChallenges.length)
        ? _gameChallenges[_currentChallengeIndex]
        : _gameChallenges.firstWhere((GameChallenge c) => c.type == GameType.quiz);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
    color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
    border: Border.all(color: accent, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _currentChallengePoints > 0
                    ? 'Quiz Challenge — +${_currentChallengePoints} pts'
                    : 'Quiz Challenge',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accent,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.question,
      style: Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            // Use Wrap so choices wrap to the next line instead of overflowing
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _currentChoices.asMap().entries.map((MapEntry<int, String> entry) {
                final int index = entry.key;
                final String choice = entry.value;
                final bool isSelected = _selectedChoice == index;
        Color bg = Theme.of(context).colorScheme.surface;
        Color borderC = accent.withValues(alpha: 0.30);
                if (_choiceLocked && _selectedChoice >= 0) {
                  if (index == _selectedChoice) {
                    bg = (index == _correctChoice)
            ? Theme.of(context)
              .colorScheme
              .secondary
              .withValues(alpha: 0.20)
            : Theme.of(context)
              .colorScheme
              .error
              .withValues(alpha: 0.12);
          borderC = (index == _correctChoice)
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.error;
                  } else if (index == _correctChoice) {
          bg = Theme.of(context)
            .colorScheme
            .secondary
            .withValues(alpha: 0.12);
          borderC = Theme.of(context).colorScheme.secondary;
                  }
                } else if (isSelected) {
          bg = accent.withValues(alpha: 0.08);
                }

                return SizedBox(
                  width: (constraints.maxWidth / 2) - 8, // two columns max
                  child: GestureDetector(
                    onTap: () {
                      if (_choiceLocked) return; // prevent rapid changes
                      if (index < 0 || index >= _currentChoices.length) return;
                      setState(() {
                        _selectedChoice = index;
                        _choiceLocked = true;
                      });
                      Future.delayed(const Duration(milliseconds: 450), () {
                        _handleGameAction(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderC),
                      ),
                      child: Text(
                        choice,
                        textAlign: TextAlign.center,
            style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // reaction game removed (quiz-only)

  // memory game removed (quiz-only)

  // sorting game removed (quiz-only)

  Widget _buildWaitingGame(Color accent) {
    String message = 'Next eco-challenge coming soon...';

    if (_gameCompleted && _currentGameType != GameType.none) {
      message = 'Well done! 🌟 Keep it up!';
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
    color: Theme.of(context)
      .colorScheme
      .surfaceContainerHighest
      .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            _gameCompleted ? Icons.check_circle : Icons.timer,
      color: _gameCompleted
        ? Theme.of(context).colorScheme.secondary
        : accent,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color accent) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (widget.onCancel != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close, size: 18),
          label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
          backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor:
            Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: widget.onCancel != null ? 8 : 0),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Tip shared! Keep spreading sustainability! 🌱'),
                        backgroundColor: accent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share Tip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SustainabilityTip {
  final String text;
  final double carbonImpact;
  final IconData icon;

  const SustainabilityTip({
    required this.text,
    required this.carbonImpact,
    required this.icon,
  });
}

enum GameType {
  none,
  quiz,
}

class GameChallenge {
  final GameType type;
  final String question;
  final List<String> choices;
  final int correctAnswer;
  final int points;

  const GameChallenge({
    required this.type,
    required this.question,
    required this.choices,
    required this.correctAnswer,
    required this.points,
  });
}
