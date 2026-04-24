import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/battle_entry.dart';
import 'entry_card.dart';

class BattleVotingView extends StatelessWidget {
  final List<BattleEntry> results;
  final String myId;
  final String? votedEntryId;
  final void Function(String entryId) onVote;

  const BattleVotingView({
    super.key,
    required this.results,
    required this.myId,
    required this.votedEntryId,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Vote for the best story!',
          style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Gap(16),
        for (final entry in results)
          if (entry.playerId != myId) ...[
            EntryCard(
              entry: entry,
              voted: votedEntryId == entry.id,
              canVote: votedEntryId == null,
              onVote: () => onVote(entry.id),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            const Gap(12),
          ],
      ],
    );
  }
}
