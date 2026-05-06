import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/game_widgets.dart';

class BattleFillingView extends StatelessWidget {
  final Map<String, dynamic> prompt;
  final Map<int, TextEditingController> adjectives;
  final TextEditingController continuationController;
  final bool submitting;
  final VoidCallback onSubmit;

  const BattleFillingView({
    super.key,
    required this.prompt,
    required this.adjectives,
    required this.continuationController,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final blankCount = adjectives.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fillInAdjectives, style: const TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(12),
          for (var i = 0; i < blankCount; i++) ...[
            GameTextField(controller: adjectives[i]!, labelText: l10n.blankN(i + 1)),
            const Gap(8),
          ],
          const Gap(16),
          Text(l10n.yourContinuation, style: const TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(8),
          GameTextField(
            controller: continuationController,
            maxLines: 4,
            hintText: l10n.continueStoryHint,
          ),
          const Gap(20),
          GameSubmitButton(
            onPressed: submitting ? null : onSubmit,
            label: l10n.submitStory,
            loading: submitting,
            accent: kBattle,
          ),
        ],
      ),
    );
  }
}
