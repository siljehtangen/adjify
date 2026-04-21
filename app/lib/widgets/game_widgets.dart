import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../config/app_colors.dart';

class GameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool autofocus;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  const GameTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.autofocus = false,
    this.borderRadius = 12,
    this.contentPadding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: expands ? null : maxLines,
        minLines: minLines,
        expands: expands,
        autofocus: autofocus,
        style: const TextStyle(color: kText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0x7F7DB9D8)),
          labelText: labelText,
          labelStyle: const TextStyle(color: kTextSub),
          filled: false,
          border: InputBorder.none,
          contentPadding: contentPadding,
        ),
      ),
    );
  }
}

class GameSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool loading;
  final Color accent;
  final double height;
  final double elevation;
  final double borderRadius;

  const GameSubmitButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.accent,
    this.loading = false,
    this.height = 52,
    this.elevation = 8,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          elevation: elevation,
          shadowColor: accent.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

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
