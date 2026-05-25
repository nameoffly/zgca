import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Animated vertical-bar equaliser used either side of the mic button.
class AnimatedWaveBars extends StatefulWidget {
  final int barCount;
  final double maxHeight;
  final double minHeight;
  final double barWidth;
  final double spacing;
  final Color color;
  final bool active;
  final int seed;

  const AnimatedWaveBars({
    super.key,
    this.barCount = 12,
    this.maxHeight = 38,
    this.minHeight = 4,
    this.barWidth = 3,
    this.spacing = 3,
    this.color = AppColors.primary,
    this.active = true,
    this.seed = 1,
  });

  @override
  State<AnimatedWaveBars> createState() => _AnimatedWaveBarsState();
}

class _AnimatedWaveBarsState extends State<AnimatedWaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<double> _phases;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.active) _ctrl.repeat();
    final rand = Random(widget.seed);
    _phases = List.generate(widget.barCount, (_) => rand.nextDouble() * pi * 2);
  }

  @override
  void didUpdateWidget(covariant AnimatedWaveBars old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (i) {
            final t = _ctrl.value * 2 * pi + _phases[i];
            final amp = (sin(t) + 1) / 2;
            final h = widget.active
                ? widget.minHeight + amp * (widget.maxHeight - widget.minHeight)
                : widget.minHeight;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Container(
                width: widget.barWidth,
                height: h,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.4 + amp * 0.55),
                  borderRadius: BorderRadius.circular(widget.barWidth / 2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Wide horizontal waveform with a bell-shaped envelope, animated.
class AnimatedCenteredWave extends StatefulWidget {
  final double height;
  final Color color;
  final bool active;
  const AnimatedCenteredWave({
    super.key,
    this.height = 60,
    this.color = AppColors.primary,
    this.active = true,
  });

  @override
  State<AnimatedCenteredWave> createState() => _AnimatedCenteredWaveState();
}

class _AnimatedCenteredWaveState extends State<AnimatedCenteredWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.active) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedCenteredWave old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => CustomPaint(
          size: Size.infinite,
          painter: _WavePainter(
            color: widget.color,
            phase: _ctrl.value * 2 * pi,
            active: widget.active,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double phase;
  final bool active;
  _WavePainter({
    required this.color,
    required this.phase,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(7);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const barWidth = 3.0;
    const spacing = 5.0;
    final totalCount = (size.width / spacing).floor();
    final center = size.height / 2;
    final midIndex = totalCount ~/ 2;

    for (int i = 0; i < totalCount; i++) {
      final distFromMid = (i - midIndex).abs();
      final envelope = max(0.18, 1.0 - distFromMid / midIndex);
      final base = 6 + rand.nextDouble() * (size.height - 12);
      final pulse = active ? (sin(phase + i * 0.45) + 1) / 2 : 0.25;
      final h = base * envelope * (0.4 + pulse * 0.6);
      final x = i * spacing + barWidth / 2;
      paint.strokeWidth = barWidth;
      paint.color = color.withValues(alpha: 0.3 + envelope * pulse * 0.6);
      canvas.drawLine(
        Offset(x, center - h / 2),
        Offset(x, center + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.phase != phase || old.active != active;
}
