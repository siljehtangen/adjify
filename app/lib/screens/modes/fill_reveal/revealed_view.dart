import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_colors.dart';
import '../../../models/story.dart';

class RevealedView extends StatelessWidget {
  final Story story;

  const RevealedView({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kFillReveal.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: kFillReveal.withValues(alpha: 0.15), blurRadius: 20)],
      ),
      child: Text(
        story.rendered,
        style: const TextStyle(color: kText, fontSize: 18, height: 1.7),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}
