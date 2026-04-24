import 'package:flutter/material.dart';

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
