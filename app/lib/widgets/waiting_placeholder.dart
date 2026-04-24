import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../config/app_colors.dart';

class WaitingPlaceholder extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final double size;
  final bool animate;
  final EdgeInsetsGeometry? padding;

  const WaitingPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.size = 90,
    this.animate = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.15), blurRadius: 24)],
      ),
      child: Center(child: icon),
    );

    if (animate) circle = circle.animate().scale();

    Widget column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const Gap(20),
        Text(
          title,
          style: const TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const Gap(8),
          Text(subtitle!, style: const TextStyle(color: kTextSub, fontSize: 14), textAlign: TextAlign.center),
        ],
      ],
    );

    if (padding != null) column = Padding(padding: padding!, child: column);

    return Center(child: column);
  }
}
