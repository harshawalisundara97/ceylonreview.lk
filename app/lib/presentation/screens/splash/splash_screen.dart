import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n_ext.dart';

/// Animated brand splash: the map pin drops in with a bounce, the lotus
/// petals bloom one by one, the amber heart pulses in, then the wordmark
/// fades up. Calls [onFinished] after the sequence settles.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _deepGreen = Color(0xFF083F31);

  late final AnimationController _controller;

  // Sequence intervals (fractions of the 2.6s timeline).
  late final Animation<double> _pinDrop;
  late final Animation<double> _petals;
  late final Animation<double> _heart;
  late final Animation<double> _wordmark;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _pinDrop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.28, curve: Curves.bounceOut),
    );
    _petals = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.62),
    );
    _heart = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.72, curve: Curves.elasticOut),
    );
    _wordmark = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 0.92, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) widget.onFinished();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.ceylonGreen,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF178A6E), AppColors.ceylonGreen, _deepGreen],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SizedBox.expand(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final dropOffset = (1 - _pinDrop.value) * -media.size.height * 0.35;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, dropOffset),
                    child: CustomPaint(
                      size: const Size(150, 169),
                      painter: _PinLotusPainter(
                        petalProgress: _petals.value,
                        heartProgress: _heart.value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: _wordmark.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - _wordmark.value) * 16),
                      child: Column(
                        children: [
                          Text(
                            context.l10n.appTitle,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.discoverSriLanka,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4,
                              color: AppColors.goldenAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paints the brand mark in logo coordinates (64x72 viewBox, scaled to fit):
/// white pin, five green petals that bloom in staggered order, amber heart.
class _PinLotusPainter extends CustomPainter {
  _PinLotusPainter({required this.petalProgress, required this.heartProgress});

  final double petalProgress;
  final double heartProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 64;
    canvas.scale(scale, scale);

    // Map pin (path from assets/logo-icon.svg).
    final pin = Path()
      ..moveTo(32, 2)
      ..cubicTo(19.297, 2, 9, 12.297, 9, 25)
      ..cubicTo(9, 42.5, 32, 70, 32, 70)
      ..cubicTo(32, 70, 55, 42.5, 55, 25)
      ..cubicTo(55, 12.297, 44.703, 2, 32, 2)
      ..close();
    canvas.drawShadow(pin, Colors.black.withValues(alpha: 0.4), 6, false);
    canvas.drawPath(pin, Paint()..color = Colors.white);

    // Five lotus petals around (32, 26), bloom staggered.
    final petalPaint = Paint()
      ..color = AppColors.ceylonGreen.withValues(alpha: 0.88);
    for (var i = 0; i < 5; i++) {
      // Each petal gets a 0.33-wide window staggered across the timeline.
      final start = i * (1 - 0.33) / 4;
      final t = ((petalProgress - start) / 0.33).clamp(0.0, 1.0);
      if (t == 0) continue;
      final eased = Curves.easeOutBack.transform(t);

      canvas.save();
      canvas.translate(32, 26);
      canvas.rotate(i * 72 * math.pi / 180);
      canvas.scale(eased.clamp(0.0, 1.2));
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -6), width: 11, height: 18),
        petalPaint,
      );
      canvas.restore();
    }

    // Amber heart pops in last.
    if (heartProgress > 0) {
      canvas.drawCircle(
        const Offset(32, 26),
        5 * heartProgress.clamp(0.0, 1.3),
        Paint()..color = AppColors.goldenAmber,
      );
    }
  }

  @override
  bool shouldRepaint(_PinLotusPainter oldDelegate) =>
      oldDelegate.petalProgress != petalProgress ||
      oldDelegate.heartProgress != heartProgress;
}
