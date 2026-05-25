import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onEnter;
  const SplashScreen({super.key, required this.onEnter});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _breath;
  late final AnimationController _orbit;
  late final AnimationController _star;

  late final Animation<double> _fadeIn;
  late final Animation<double> _slideIn;
  late final Animation<double> _logoScale;

  bool _entering = false;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _star = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _slideIn = Tween<double>(begin: 28, end: 0).animate(
      CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entry, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _entry.dispose();
    _breath.dispose();
    _orbit.dispose();
    _star.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_entering) return;
    setState(() => _entering = true);
    await _entry.reverse();
    if (!mounted) return;
    widget.onEnter();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B2447),
                    Color(0xFF0F9488),
                    Color(0xFF14B8A6),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // Soft blurred orbs
            _BlurOrb(
              top: -size.width * 0.25,
              left: -size.width * 0.2,
              size: size.width * 0.9,
              color: const Color(0xFF5EEAD4).withValues(alpha: 0.22),
            ),
            _BlurOrb(
              bottom: -size.width * 0.3,
              right: -size.width * 0.25,
              size: size.width * 1.0,
              color: const Color(0xFFCCFBF1).withValues(alpha: 0.18),
            ),

            // Floating particles
            AnimatedBuilder(
              animation: _orbit,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _ParticlesPainter(progress: _orbit.value),
                );
              },
            ),

            // Main content
            SafeArea(
              child: AnimatedBuilder(
                animation: _entry,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideIn.value),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Top tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.32),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Color(0xFFBEF264),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'AI for Science',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Animated logo
                      AnimatedBuilder(
                        animation: Listenable.merge([_breath, _star, _entry]),
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: _LogoEmblem(
                              breath: _breath.value,
                              starPulse: _star.value,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 38),

                      // Title 拼研研
                      const Text(
                        '拼研研',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Color(0x551B3B5F),
                              blurRadius: 18,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Divider with dot
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFBEF264),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '让每一次实验，都被认真记录',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 15,
                          height: 1.5,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '想法 · 记录 · 结构化报告 · 一站完成',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          height: 1.5,
                          letterSpacing: 0.8,
                        ),
                      ),

                      const Spacer(),

                      // Feature row
                      Row(
                        children: const [
                          _FeaturePill(icon: Icons.lightbulb_outline, label: '灵感'),
                          SizedBox(width: 10),
                          _FeaturePill(icon: Icons.mic_none, label: '语音记录'),
                          SizedBox(width: 10),
                          _FeaturePill(
                              icon: Icons.summarize_outlined, label: '结构化报告'),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Tap hint
                      AnimatedBuilder(
                        animation: _breath,
                        builder: (context, _) {
                          final t = _breath.value;
                          return Opacity(
                            opacity: 0.55 + t * 0.45,
                            child: Column(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.55 + t * 0.35,
                                      ),
                                      width: 1.4,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.touch_app_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '点击任意位置进入',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  const _BlurOrb({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoEmblem extends StatelessWidget {
  final double breath; // 0..1
  final double starPulse; // 0..1
  const _LogoEmblem({required this.breath, required this.starPulse});

  @override
  Widget build(BuildContext context) {
    const baseSize = 168.0;
    return SizedBox(
      width: baseSize + 28,
      height: baseSize + 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer halo
          Container(
            width: baseSize + 24 + breath * 10,
            height: baseSize + 24 + breath * 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18 + breath * 0.18),
                width: 1.2,
              ),
            ),
          ),
          Container(
            width: baseSize + 8 + breath * 6,
            height: baseSize + 8 + breath * 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28 + breath * 0.22),
                width: 1.0,
              ),
            ),
          ),
          // White glass disc
          Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFE9FBF6).withValues(alpha: 0.92),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B2447).withValues(alpha: 0.45),
                  blurRadius: 38,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: CustomPaint(
              painter: _PinYanYanLogoPainter(starPulse: starPulse),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinYanYanLogoPainter extends CustomPainter {
  final double starPulse; // 0..1
  _PinYanYanLogoPainter({required this.starPulse});

  static const Color ringColor = Color(0xFF0B2447);
  static const Color line1 = Color(0xFF0B2447);
  static const Color line2 = Color(0xFF14B8A6);
  static const Color line3 = Color(0xFF5EEAD4);
  static const Color starColor = Color(0xFFB5D33A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final radius = math.min(w, h) / 2;

    // Outer ring
    final ringStroke = w * 0.045;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..color = ringColor;
    canvas.drawCircle(Offset(cx, cy), radius - ringStroke / 2, ringPaint);

    // Three flowing curves (left-anchored, drifting to the right)
    final lineStroke = w * 0.045;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Curve 1: dark blue, upper
    final p1 = Path()
      ..moveTo(w * 0.24, h * 0.42)
      ..cubicTo(
        w * 0.42, h * 0.34,
        w * 0.58, h * 0.66,
        w * 0.78, h * 0.50,
      );
    linePaint.color = line1;
    canvas.drawPath(p1, linePaint);

    // Curve 2: teal, middle
    final p2 = Path()
      ..moveTo(w * 0.22, h * 0.56)
      ..cubicTo(
        w * 0.42, h * 0.48,
        w * 0.62, h * 0.82,
        w * 0.84, h * 0.62,
      );
    linePaint.color = line2;
    canvas.drawPath(p2, linePaint);

    // Curve 3: mint, lower
    final p3 = Path()
      ..moveTo(w * 0.24, h * 0.70)
      ..cubicTo(
        w * 0.42, h * 0.62,
        w * 0.62, h * 0.94,
        w * 0.80, h * 0.80,
      );
    linePaint.color = line3;
    canvas.drawPath(p3, linePaint);

    // Origin dots
    final dotPaint = Paint();
    final dotR = w * 0.028;
    dotPaint.color = line1;
    canvas.drawCircle(Offset(w * 0.24, h * 0.42), dotR, dotPaint);
    dotPaint.color = line2;
    canvas.drawCircle(Offset(w * 0.22, h * 0.56), dotR, dotPaint);
    dotPaint.color = line3;
    canvas.drawCircle(Offset(w * 0.24, h * 0.70), dotR, dotPaint);

    // Star (4-point) — pulsates a touch
    final starScale = 0.92 + starPulse * 0.18;
    final starCenter = Offset(w * 0.72, h * 0.30);
    final outer = w * 0.085 * starScale;
    final inner = w * 0.028 * starScale;

    final star = Path();
    const points = 4;
    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? outer : inner;
      // start at top (-pi/2), step pi/4
      final angle = -math.pi / 2 + i * (math.pi / points);
      final dx = starCenter.dx + math.cos(angle) * r;
      final dy = starCenter.dy + math.sin(angle) * r;
      if (i == 0) {
        star.moveTo(dx, dy);
      } else {
        star.lineTo(dx, dy);
      }
    }
    star.close();

    // Star glow
    final glowPaint = Paint()
      ..color = starColor.withValues(alpha: 0.35 + starPulse * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(starCenter, outer * 1.2, glowPaint);

    // Star fill
    canvas.drawPath(star, Paint()..color = starColor);
  }

  @override
  bool shouldRepaint(covariant _PinYanYanLogoPainter old) =>
      old.starPulse != starPulse;
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 0.6,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  _ParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(11);
    const count = 26;
    for (int i = 0; i < count; i++) {
      final baseX = rand.nextDouble();
      final baseY = rand.nextDouble();
      final speed = 0.3 + rand.nextDouble() * 0.7;
      final radius = 1.0 + rand.nextDouble() * 2.4;
      final phase = rand.nextDouble();

      final t = (progress * speed + phase) % 1.0;
      final y = (baseY + t) % 1.0;
      final x = baseX + math.sin((t + i) * math.pi * 2) * 0.04;

      final alpha = (math.sin(t * math.pi) * 0.7).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.55);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter old) =>
      old.progress != progress;
}
