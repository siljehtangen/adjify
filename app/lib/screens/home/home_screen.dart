import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/room.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: Text('Adjify', style: AppTextStyle.appBarLogo),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 18, color: kTextSub),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.chooseMode,
                style: AppTextStyle.screenHeading,
              ).animate().fadeIn(),
              const Gap(4),
              Text(
                l10n.joinFriendRoomSubtitle,
                style: const TextStyle(color: kTextSub, fontSize: 14),
              ).animate().fadeIn(delay: 80.ms),
              const Gap(28),
              _ModeCard(
                icon: FontAwesomeIcons.bookOpen,
                title: l10n.modeFillReveal,
                subtitle: l10n.modeFillRevealSubtitle,
                color: kFillReveal,
                mode: GameMode.fillReveal,
                playerLabel: l10n.fillRevealPlayerLabel,
                delay: 0,
              ),
              const Gap(14),
              _ModeCard(
                icon: FontAwesomeIcons.arrowsRotate,
                title: l10n.modeRotatingChain,
                subtitle: l10n.modeRotatingChainSubtitle,
                color: kChain,
                mode: GameMode.rotatingChain,
                playerLabel: l10n.rotatingChainPlayerLabel,
                delay: 100,
              ),
              const Gap(14),
              _ModeCard(
                icon: FontAwesomeIcons.trophy,
                title: l10n.modeAdjectiveBattle,
                subtitle: l10n.modeBattleSubtitle,
                color: kBattle,
                mode: GameMode.battle,
                playerLabel: l10n.battlePlayerLabel,
                delay: 200,
              ),
              const Spacer(),
              _JoinButton(label: l10n.joinARoom),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final GameMode mode;
  final String playerLabel;
  final int delay;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.mode,
    required this.playerLabel,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/create', extra: mode),
        child: GameCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 18,
          shadowColor: color.withValues(alpha: 0.15),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(child: FaIcon(icon, color: color, size: 22)),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.sectionTitle),
                    const Gap(3),
                    Text(subtitle, style: const TextStyle(color: kTextSub, fontSize: 13)),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        playerLabel,
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(FontAwesomeIcons.chevronRight, color: kBorder.withValues(alpha: 1.0), size: 14),
            ],
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.06, end: 0),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final String label;
  const _JoinButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => context.push('/join'),
          icon: const FaIcon(FontAwesomeIcons.userGroup, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: kAccent,
            side: const BorderSide(color: kAccent, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ).animate().fadeIn(delay: 350.ms),
    );
  }
}
