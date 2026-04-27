import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _auth = AuthService();
  bool _loading = false;

  late AnimationController _floatController;
  late AnimationController _pulseController;

  final List<String> _adjectives = ['creative', 'hilarious', 'ridiculous', 'epic', 'wild', 'chaotic', 'legendary'];
  int _wordIndex = 0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _startWordRotation();
  }

  Future<void> _startWordRotation() async {
    await Future.delayed(const Duration(seconds: 2));
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) break;
      setState(() => _wordIndex = (_wordIndex + 1) % _adjectives.length);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      if (mounted) showErrorToast('Sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBg, kGradMid, kGradEnd],
          ),
        ),
        child: Stack(
          children: [
            _FloatingIcon(icon: FontAwesomeIcons.bookOpen, color: kFillReveal, topFrac: 0.13, leftFrac: 0.07, phase: 0.0, controller: _floatController, iconSize: 26),
            _FloatingIcon(icon: FontAwesomeIcons.arrowsRotate, color: kChain, topFrac: 0.22, rightFrac: 0.08, phase: 0.3, controller: _floatController, iconSize: 22),
            _FloatingIcon(icon: FontAwesomeIcons.trophy, color: kBattle, topFrac: 0.67, leftFrac: 0.06, phase: 0.6, controller: _floatController, iconSize: 24),
            _FloatingIcon(icon: FontAwesomeIcons.star, color: kGold, topFrac: 0.74, rightFrac: 0.09, phase: 0.15, controller: _floatController, iconSize: 18),
            _FloatingIcon(icon: FontAwesomeIcons.pen, color: kAccent, topFrac: 0.09, rightFrac: 0.20, phase: 0.75, controller: _floatController, iconSize: 15),
            _FloatingIcon(icon: FontAwesomeIcons.userGroup, color: kChain, topFrac: 0.78, leftFrac: 0.26, phase: 0.45, controller: _floatController, iconSize: 16),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const Gap(28),
                      Text(
                        'Adjify',
                        style: GoogleFonts.lora(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: kText,
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                      const Gap(10),
                      _buildAnimatedSubtitle(),
                      const Gap(80),
                      _buildSignInButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final p = _pulseController.value;
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: kAccent.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: kAccent.withValues(alpha: 0.18 + p * 0.22), width: 2),
            boxShadow: [
              BoxShadow(color: kAccent.withValues(alpha: 0.12 + p * 0.18), blurRadius: 28 + p * 22, spreadRadius: 2 + p * 5),
            ],
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.bookOpen, color: kAccent, size: 38),
          ),
        );
      },
    ).animate().scale(duration: 700.ms, curve: Curves.elasticOut);
  }

  Widget _buildAnimatedSubtitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('The ', style: TextStyle(fontSize: 16, color: kTextSub.withValues(alpha: 0.9))),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _adjectives[_wordIndex],
            key: ValueKey(_wordIndex),
            style: const TextStyle(fontSize: 16, color: kAccent, fontWeight: FontWeight.w700),
          ),
        ),
        Text(' storytelling game', style: TextStyle(fontSize: 16, color: kTextSub.withValues(alpha: 0.9))),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _signIn,
        icon: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: kNight),
              )
            : Image.asset(
                'assets/images/google_logo.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => const Icon(Icons.login, color: kNight),
              ),
        label: Text(
          _loading ? 'Signing in…' : 'Continue with Google',
          style: const TextStyle(color: kNight, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: kNight,
          elevation: 14,
          shadowColor: kAccent.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0);
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double topFrac;
  final double? leftFrac;
  final double? rightFrac;
  final double phase;
  final AnimationController controller;
  final double iconSize;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.topFrac,
    this.leftFrac,
    this.rightFrac,
    required this.phase,
    required this.controller,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: size.height * topFrac,
      left: leftFrac != null ? size.width * leftFrac! : null,
      right: rightFrac != null ? size.width * rightFrac! : null,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = (controller.value + phase) % 1.0;
          final dy = sin(t * pi * 2) * 9.0;
          return Transform.translate(
            offset: Offset(0, dy),
            child: child,
          );
        },
        child: Container(
          width: iconSize + 26,
          height: iconSize + 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.11),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.22), width: 1.5),
          ),
          child: Center(child: FaIcon(icon, color: color.withValues(alpha: 0.65), size: iconSize)),
        )
            .animate()
            .fadeIn(delay: (300 + phase * 500).ms, duration: 700.ms),
      ),
    );
  }
}
