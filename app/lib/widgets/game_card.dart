import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class GameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;
  final Color? shadowColor;
  final double borderRadius;
  final double? width;

  const GameCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor = kBorder,
    this.shadowColor,
    this.borderRadius = AppRadius.lg,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: shadowColor != null
            ? [BoxShadow(color: shadowColor!, blurRadius: 20, offset: const Offset(0, 4))]
            : null,
      ),
      child: child,
    );
  }
}
