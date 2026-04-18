import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../models/room.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Adjify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a mode',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
              ).animate().fadeIn(),
              const Gap(8),
              Text(
                'Or join a friend\'s room',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ).animate().fadeIn(delay: 100.ms),
              const Gap(32),
              _ModeCard(
                emoji: '🧩',
                title: 'Fill & Reveal',
                subtitle: 'Fill hidden adjective blanks alone or with friends',
                color: const Color(0xFF6C63FF),
                mode: GameMode.fillReveal,
                minPlayers: '1+',
                delay: 0,
              ),
              const Gap(16),
              _ModeCard(
                emoji: '🔁',
                title: 'Rotating Chain',
                subtitle: 'Build a chaotic story step-by-step in secret',
                color: const Color(0xFF43AA8B),
                mode: GameMode.rotatingChain,
                minPlayers: '3–6',
                delay: 100,
              ),
              const Gap(16),
              _ModeCard(
                emoji: '⚔️',
                title: 'Adjective Battle',
                subtitle: 'Compete to make the funniest story from the same prompt',
                color: const Color(0xFFFF6B6B),
                mode: GameMode.battle,
                minPlayers: '3–8',
                delay: 200,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/join'),
                  icon: const Icon(Icons.group_add),
                  label: const Text('Join a Room'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final GameMode mode;
  final String minPlayers;
  final int delay;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.mode,
    required this.minPlayers,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/create', extra: mode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                        child: Text(minPlayers, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.4), size: 16),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1, end: 0);
  }
}
