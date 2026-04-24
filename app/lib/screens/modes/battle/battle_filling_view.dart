import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/story.dart';
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
    final content = prompt['content'] as String? ?? '';
    final blankCount = adjectives.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBattle.withValues(alpha: 0.35)),
              boxShadow: [BoxShadow(color: kBattle.withValues(alpha: 0.1), blurRadius: 16)],
            ),
            child: Text(
              content.replaceAll(kAdjPlaceholder, '______'),
              style: const TextStyle(color: kText, fontSize: 16, height: 1.6),
            ),
          ),
          const Gap(24),
          const Text('Fill in the adjectives', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(12),
          for (var i = 0; i < blankCount; i++) ...[
            GameTextField(controller: adjectives[i]!, labelText: 'Blank ${i + 1}'),
            const Gap(8),
          ],
          const Gap(16),
          const Text('Your continuation', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(8),
          GameTextField(
            controller: continuationController,
            maxLines: 4,
            hintText: 'Continue the story in your own words…',
          ),
          const Gap(20),
          GameSubmitButton(
            onPressed: submitting ? null : onSubmit,
            label: 'Submit Story',
            loading: submitting,
            accent: kBattle,
          ),
        ],
      ),
    );
  }
}
