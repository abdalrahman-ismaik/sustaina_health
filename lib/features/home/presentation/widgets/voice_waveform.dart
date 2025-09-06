import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Simple voice waveform animation widget
class VoiceWaveform extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double height;
  final int barCount;

  const VoiceWaveform({
    Key? key,
    required this.isActive,
    this.color = Colors.blue,
    this.height = 40,
    this.barCount = 5,
  }) : super(key: key);

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 80)), // Faster, more visible animations
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
    
    // Start animations immediately if active
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimations();
      });
    }
  }

  @override
  void didUpdateWidget(VoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      print('VoiceWaveform: isActive changed from ${oldWidget.isActive} to ${widget.isActive}');
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    print('VoiceWaveform: Starting animations for ${_controllers.length} controllers');
    for (int i = 0; i < _controllers.length; i++) {
      // Add slight randomization to make it look more natural
      final delay = (i * 50) + (math.Random().nextInt(100));
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted && widget.isActive) {
          print('VoiceWaveform: Starting controller $i animation');
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (final controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 4, // Slightly wider for better visibility
                height: widget.isActive 
                  ? math.max(widget.height * 0.3, widget.height * _animations[index].value) // Ensure minimum height
                  : widget.height * 0.3, // Higher inactive height for visibility
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: widget.isActive ? 0.9 : 0.5, // Higher alpha for visibility
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
