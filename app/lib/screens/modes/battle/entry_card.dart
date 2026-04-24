import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/story.dart';
import '../../../widgets/game_widgets.dart';

class EntryCard extends StatelessWidget {
  final BattleEntry entry;
  final bool voted;
  final bool canVote;
  final VoidCallback? onVote;
  final int? rank;

  const EntryCard({
    super.key,
    required this.entry,
    required this.voted,
    required this.canVote,
    this.onVote,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: voted ? kBattle.withValues(alpha: 0.12) : kCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: voted ? kBattle.withValues(alpha: 0.4) : kBorderDeep,
        ),
        boxShadow: voted
            ? [BoxShadow(color: kBattle.withValues(alpha: 0.15), blurRadius: 16)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rank != null)
                Text(
                  '#$rank ',
                  style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              Text(
                entry.username ?? 'Player',
                style: const TextStyle(color: kText, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (entry.voteCount > 0)
                Row(
                  children: [
                    const Icon(Icons.favorite, color: kBattle, size: 16),
                    const Gap(4),
                    Text('${entry.voteCount}', style: const TextStyle(color: kTextSub)),
                  ],
                ),
            ],
          ),
          const Gap(8),
          if (entry.story != null) ...[
            Text(entry.story!.rendered, style: const TextStyle(color: kText, height: 1.5)),
            const Gap(8),
          ],
          if (entry.continuation != null)
            Text(
              entry.continuation!,
              style: const TextStyle(color: kTextSub, fontStyle: FontStyle.italic, height: 1.4),
            ),
          if (canVote) ...[
            const Gap(12),
            GameSubmitButton(
              onPressed: onVote,
              label: 'Vote',
              accent: kBattle,
              height: 40,
              elevation: 6,
              borderRadius: 10,
            ),
          ],
        ],
      ),
    );
  }
}
