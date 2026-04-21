import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../models/room.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: Text('Adjify', style: GoogleFonts.lora(color: kAccent, fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 18, color: kTextSub),
            onPressed: () async {
              await _auth.signOut();
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
                'Choose a mode',
                style: GoogleFonts.lora(fontSize: 26, fontWeight: FontWeight.w700, color: kText),
              ).animate().fadeIn(),
              const Gap(4),
              const Text(
                'Or join a friend\'s room below',
                style: TextStyle(color: kTextSub, fontSize: 14),
              ).animate().fadeIn(delay: 80.ms),
              const Gap(28),
              const _ModeCard(
                icon: FontAwesomeIcons.bookOpen,
                title: 'Fill & Reveal',
                subtitle: 'Fill hidden adjective blanks — solo or with friends',
                color: kFillReveal,
                mode: GameMode.fillReveal,
                playerLabel: '1 – ★ blanks',
                delay: 0,
              ),
              const Gap(14),
              const _ModeCard(
                icon: FontAwesomeIcons.arrowsRotate,
                title: 'Rotating Chain',
                subtitle: 'Build a chaotic story step-by-step in secret',
                color: kChain,
                mode: GameMode.rotatingChain,
                playerLabel: '2 – 6 players',
                delay: 100,
              ),
              const Gap(14),
              const _ModeCard(
                icon: FontAwesomeIcons.trophy,
                title: 'Adjective Battle',
                subtitle: 'Compete to make the funniest story from the same prompt',
                color: kBattle,
                mode: GameMode.battle,
                playerLabel: '2 – 8 players',
                delay: 200,
              ),
              const Spacer(),
              const _JoinButton(),
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
    return GestureDetector(
      onTap: () => context.push('/create', extra: mode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))],
        ),
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
                  Text(title, style: GoogleFonts.lora(color: kText, fontSize: 17, fontWeight: FontWeight.w600)),
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
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.06, end: 0);
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton();

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
          label: const Text('Join a Room'),
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
