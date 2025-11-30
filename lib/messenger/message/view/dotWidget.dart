import 'package:flutter/material.dart';

class TypingDots extends StatefulWidget {
  const TypingDots({Key? key}) : super(key: key);

  @override
  _TypingDotsState createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    final start = index * 0.16;
    final end = start + 0.6;
    final anim = CurvedAnimation(parent: _ctrl, curve: Interval(start.clamp(0.0,1.0), end.clamp(0.0,1.0), curve: Curves.easeInOut));
    return ScaleTransition(
      scale: Tween<double>(begin: 0.7, end: 1.0).animate(anim),
      child: FadeTransition(
        opacity: anim,
        child: Image.asset(
          'assets/images/dot_icon.png',
          width: 10,
          height: 10,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(0),
        const SizedBox(width: 6),
        _dot(1),
        const SizedBox(width: 6),
        _dot(2),
      ],
    );
  }
}