import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.trigger = false,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.trigger) _controller.play();
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Color(0xFF7C3AED),
            Color(0xFFF59E0B),
            Color(0xFF10B981),
            Color(0xFF06B6D4),
            Color(0xFFD946EF),
          ],
          numberOfParticles: 30,
          maxBlastForce: 20,
          minBlastForce: 10,
          gravity: 0.1,
        ),
      ],
    );
  }
}
