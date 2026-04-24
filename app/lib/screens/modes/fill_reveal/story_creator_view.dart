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
    final minBlanks = otherPlayerCount > 0 ? otherPlayerCount : 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write a story', style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold)),
          const Gap(8),
          Text(
            isSolo
                ? 'Add $kAdjPlaceholder placeholders — they\'ll be filled with random adjectives when you save.'
                : 'Use $kAdjPlaceholder as placeholders for adjectives.\n'
                    '${otherPlayerCount > 0 ? 'You need at least $minBlanks $kAdjPlaceholder blank${minBlanks != 1 ? 's' : ''} — one per player.' : 'Example: "The $kAdjPlaceholder cat sat on a $kAdjPlaceholder mat."'}',
            style: const TextStyle(color: kTextSub, fontSize: 14),
          ),
          const Gap(16),
          GameTextField(
            controller: storyController,
            minLines: 8,
            maxLines: 16,
            borderRadius: 14,
            hintText: 'Write your story here…',
          ),
          const Gap(10),
          GestureDetector(
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
          const Gap(12),
          GameSubmitButton(
            onPressed: onCreateStory,
            label: isSolo ? 'Save & Fill Randomly' : 'Save Story',
            accent: kFillReveal,
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
