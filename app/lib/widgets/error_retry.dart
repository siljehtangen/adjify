import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../config/app_colors.dart';

class ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final Color accentColor;

  const ErrorRetry({
    super.key,
    required this.error,
    required this.onRetry,
    this.accentColor = kAccent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error, style: const TextStyle(color: kTextSub)),
          const Gap(12),
          TextButton(
            onPressed: onRetry,
            child: Text(l10n.retry, style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }
}
