import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/story.dart';

class FillingView extends StatelessWidget {
  final Story story;
  final bool isHost;
  final bool isSolo;
  final void Function(Story, StoryBlank) onFillBlank;

  const FillingView({
    super.key,
    required this.story,
    required this.isHost,
    required this.isSolo,
    required this.onFillBlank,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isHost && !isSolo) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kFillReveal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kFillReveal.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: kFillReveal, size: 18),
                const Gap(10),
                Expanded(
                  child: Text(
                    'You wrote this story. Wait for the other players to fill in the blanks.',
                    style: TextStyle(color: kText.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
        ],
        const Gap(4),
        Row(
          children: [
            Text(
              '${story.filledCount}/${story.blanks.length} blanks filled',
              style: const TextStyle(color: kTextSub),
            ),
            const Gap(12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: story.blanks.isEmpty ? 0 : story.filledCount / story.blanks.length,
                  backgroundColor: kBorder,
                  color: kFillReveal,
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
        const Gap(16),
        _BlanksRow(story: story, isHost: isHost, isSolo: isSolo, onFillBlank: onFillBlank),
      ],
    );
  }
}

class _BlanksRow extends StatelessWidget {
  final Story story;
  final bool isHost;
  final bool isSolo;
  final void Function(Story, StoryBlank) onFillBlank;

  const _BlanksRow({
    required this.story,
    required this.isHost,
    required this.isSolo,
    required this.onFillBlank,
  });

  @override
  Widget build(BuildContext context) {
    if (!isHost || isSolo) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: story.blanks.map((blank) {
          return MouseRegion(
            cursor: blank.isFilled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onFillBlank(story, blank),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: blank.isFilled ? kFillReveal.withValues(alpha: 0.2) : kSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: blank.isFilled ? kFillReveal : kBorder),
                  boxShadow: blank.isFilled
                      ? [BoxShadow(color: kFillReveal.withValues(alpha: 0.25), blurRadius: 8)]
                      : [],
                ),
                child: Text(
                  blank.isFilled ? blank.adjective! : 'Blank ${blank.position + 1}',
                  style: TextStyle(
                    color: blank.isFilled ? kFillReveal : kTextSub,
                    fontWeight: blank.isFilled ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: story.blanks.map((blank) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: blank.isFilled ? kFillReveal.withValues(alpha: 0.15) : kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: blank.isFilled ? kFillReveal.withValues(alpha: 0.5) : kBorder,
            ),
          ),
          child: Text(
            blank.isFilled ? blank.adjective! : 'Blank ${blank.position + 1}',
            style: TextStyle(
              color: blank.isFilled ? kFillReveal : kTextSub.withValues(alpha: 0.4),
              fontWeight: blank.isFilled ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}
