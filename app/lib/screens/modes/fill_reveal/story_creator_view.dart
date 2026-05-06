import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/story.dart';
import '../../../widgets/game_widgets.dart';

class StoryCreatorView extends StatelessWidget {
  final TextEditingController storyController;
  final bool isSolo;
  final int otherPlayerCount;
  final VoidCallback onInsertAdj;
  final VoidCallback onCreateStory;

  const StoryCreatorView({
    super.key,
    required this.storyController,
    required this.isSolo,
    required this.otherPlayerCount,
    required this.onInsertAdj,
    required this.onCreateStory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final minBlanks = otherPlayerCount > 0 ? otherPlayerCount : 1;

    String hintText;
    if (isSolo) {
      hintText = l10n.soloStoryHint;
    } else if (otherPlayerCount > 0) {
      hintText = '${l10n.multiStoryHintBase}\n${l10n.multiStoryHintBlanks(minBlanks)}';
    } else {
      hintText = '${l10n.multiStoryHintBase}\n${l10n.storyExampleHint}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.writeAStory, style: const TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold)),
          const Gap(8),
          Text(hintText, style: const TextStyle(color: kTextSub, fontSize: 14)),
          const Gap(16),
          GameTextField(
            controller: storyController,
            minLines: 8,
            maxLines: 16,
            borderRadius: 14,
            hintText: l10n.writeStoryHere,
          ),
          const Gap(10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onInsertAdj,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: kFillReveal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kFillReveal.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: kFillReveal),
                    Gap(4),
                    Text(
                      kAdjPlaceholder,
                      style: TextStyle(
                        color: kFillReveal,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(12),
          GameSubmitButton(
            onPressed: onCreateStory,
            label: isSolo ? l10n.saveAndFillRandomly : l10n.saveStory,
            accent: kFillReveal,
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
