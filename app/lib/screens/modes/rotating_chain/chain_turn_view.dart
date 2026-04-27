import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/chain_segment.dart';
import '../../../models/story.dart';
import '../../../widgets/game_widgets.dart';

class ChainTurnView extends StatelessWidget {
  final Map<String, dynamic> turnInfo;
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  const ChainTurnView({
    super.key,
    required this.turnInfo,
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final typeStr = turnInfo['segmentType'] as String? ?? 'sentence';
    final type = SegmentTypeX.fromString(typeStr);
    final previous = turnInfo['previousContent'] as String?;
    final isSentence = type == SegmentType.sentence;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kChain.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kChain.withValues(alpha: 0.35)),
            boxShadow: [BoxShadow(color: kChain.withValues(alpha: 0.1), blurRadius: 16)],
          ),
          child: Row(
            children: [
              Text(isSentence ? '✍️' : '🔤', style: const TextStyle(fontSize: 24)),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSentence ? 'Your turn: write a sentence' : 'Your turn: fill the adjective blank',
                    style: const TextStyle(color: kText, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isSentence ? 'Include $kAdjPlaceholder as a placeholder' : 'What adjective fits here?',
                    style: const TextStyle(color: kTextSub, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isSentence && previous != null) ...[
          const Gap(16),
          const Text('Previous:', style: TextStyle(color: kTextSub, fontSize: 12)),
          const Gap(4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: Text(previous, style: const TextStyle(color: kTextSub, fontStyle: FontStyle.italic)),
          ),
        ],
        const Gap(20),
        Expanded(
          child: GameTextField(
            controller: controller,
            expands: true,
            autofocus: true,
            borderRadius: 14,
            hintText: isSentence
                ? 'The $kAdjPlaceholder wizard walked into the $kAdjPlaceholder forest…'
                : 'mysterious, ancient, fluffy…',
          ),
        ),
        const Gap(16),
        GameSubmitButton(
          onPressed: submitting ? null : onSubmit,
          label: 'Submit',
          loading: submitting,
          accent: kChain,
        ),
      ],
    );
  }
}
