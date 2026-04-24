import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/battle_entry.dart';
import 'entry_card.dart';

class BattleResultsView extends StatelessWidget {
  final List<BattleEntry> results;

  const BattleResultsView({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          '🏆 Results',
          style: TextStyle(color: kText, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Gap(16),
        for (var i = 0; i < results.length; i++) ...[
          EntryCard(entry: results[i], voted: false, canVote: false, rank: i + 1),
          const Gap(12),
        ],
      ],
    );
  }
}
