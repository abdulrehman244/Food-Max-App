import 'package:flutter/material.dart';

class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  double scale = 1.0;

  void _tapDown() {
    setState(() => scale = 0.92); // instantly press animation
  }

  void _tapUp() {
    setState(() => scale = 1.0); // release animation
    widget.onTap();
  }

  void _tapCancel() {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _tapDown(),   // ← instantly on tap
      onPointerUp: (_) => _tapUp(),       // ← on release
      onPointerCancel: (_) => _tapCancel(),
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
