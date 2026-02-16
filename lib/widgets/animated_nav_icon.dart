// Add this to your pubspec.yaml dependencies:
// flutter_animate: ^4.2.0

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color color;
  const AnimatedNavIcon({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: selected
          ? Icon(
                  selectedIcon,
                  key: ValueKey(selectedIcon),
                  color: color,
                  size: 30,
                )
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 200.ms)
          : Icon(icon, key: ValueKey(icon), color: Colors.black38, size: 26),
    );
  }
}
