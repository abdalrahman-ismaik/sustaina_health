import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A reusable background widget that provides consistent gradient backgrounds
/// with optional particle systems for different app modules
class AppBackground extends StatelessWidget {
  final Widget child;
  final BackgroundType type;
  final double? particleOpacity;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;

  const AppBackground({
    Key? key,
    required this.child,
    this.type = BackgroundType.general,
    this.particleOpacity,
    this.gradientBegin,
    this.gradientEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradient(),
      ),
      child: Stack(
        children: [
          // Particle system background (if applicable)
          if (_hasParticles()) _buildParticleSystem(),
          
          // Main content
          child,
        ],
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (type) {
      case BackgroundType.nutrition:
        return LinearGradient(
          begin: gradientBegin ?? Alignment.topLeft,
          end: gradientEnd ?? Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F9FA),
            const Color(0xFFE8F5E8),
            const Color(0xFFF1F8E9),
          ],
        );
      case BackgroundType.exercise:
        return LinearGradient(
          begin: gradientBegin ?? Alignment.topLeft,
          end: gradientEnd ?? Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F9FA),
            const Color(0xFFE3F2FD),
            const Color(0xFFF3E5F5),
          ],
        );
      case BackgroundType.sleep:
        return LinearGradient(
          begin: gradientBegin ?? Alignment.topCenter,
          end: gradientEnd ?? Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F0F23),
          ],
        );
      case BackgroundType.profile:
        return LinearGradient(
          begin: gradientBegin ?? Alignment.topLeft,
          end: gradientEnd ?? Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F9FA),
            const Color(0xFFEDE7F6),
            const Color(0xFFF3E5F5),
          ],
        );
      case BackgroundType.general:
        return LinearGradient(
          begin: gradientBegin ?? Alignment.topLeft,
          end: gradientEnd ?? Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F9FA),
            const Color(0xFFE8F5E8),
          ],
        );
    }
  }

  bool _hasParticles() {
    return type == BackgroundType.nutrition || 
           type == BackgroundType.sleep;
  }

  Widget _buildParticleSystem() {
    String assetPath;
    double opacity = particleOpacity ?? 0.08;

    switch (type) {
      case BackgroundType.nutrition:
        assetPath = 'assets/lottie/particles_green.json';
        break;
      case BackgroundType.sleep:
        assetPath = 'assets/lottie/stars_particles.json';
        opacity = particleOpacity ?? 0.12;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Opacity(
          opacity: opacity,
          child: Lottie.asset(
            assetPath,
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),
      ),
    );
  }
}

enum BackgroundType {
  general,
  nutrition,
  exercise,
  sleep,
  profile,
}

/// A modern card widget with consistent styling across the app
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final bool hasGlow;
  final List<BoxShadow>? customShadows;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.hasGlow = false,
    this.customShadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: customShadows ?? _buildShadows(),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  List<BoxShadow> _buildShadows() {
    if (hasGlow) {
      return [
        BoxShadow(
          color: const Color(0xFF2E7D32).withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFF2E7D32).withOpacity(0.04),
          blurRadius: 40,
          offset: const Offset(0, 16),
          spreadRadius: 4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
    }
  }
}

/// Modern button styles helper
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final IconData? icon;
  final double? width;
  final double? height;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 52,
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _getShadows(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: _getTextColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: _getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient? _getGradient() {
    switch (type) {
      case ModernButtonType.primary:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF43A047),
          ],
        );
      case ModernButtonType.secondary:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
        );
      case ModernButtonType.accent:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ModernButtonType.primary:
      case ModernButtonType.accent:
        return Colors.white;
      case ModernButtonType.secondary:
        return const Color(0xFF2E7D32);
    }
  }

  List<BoxShadow> _getShadows() {
    return [
      BoxShadow(
        color: _getGradient()!.colors.first.withOpacity(0.25),
        blurRadius: 12,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }
}

enum ModernButtonType {
  primary,
  secondary,
  accent,
}
