import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../models/room.dart';

class EndButtons extends StatelessWidget {
  final GameMode mode;
  final Color accent;

  const EndButtons({super.key, required this.mode, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kTextSub,
              side: const BorderSide(color: kBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Go Home'),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.push('/create', extra: mode),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              elevation: 6,
              shadowColor: accent.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
