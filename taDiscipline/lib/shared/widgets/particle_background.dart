import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _particles = <_Particle>[];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  void _initializeParticles() {
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 1 + _random.nextDouble() * 2,
        speed: 0.002 + _random.nextDouble() * 0.004,
        opacity: 0.2 + _random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  time: _controller.value,
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _Particle {
  double x, y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;

  _ParticlePainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final y = (p.y + time * p.speed) % 1.0;
      final opacity = p.opacity * (1 - (y < 0.5 ? y * 2 : (1 - y) * 2));
      paint.color = AppColors.goldenParticle.withValues(alpha: opacity.clamp(0.0, 0.5));
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.time != time;
}
