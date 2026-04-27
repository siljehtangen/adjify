import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_widgets.dart';

// Story fragments shown as faded background text
const _kFragments = [
  (text: 'Once upon a time, a ridiculous dragon decided to...', top: 0.06, left: 0.0, rot: -1.8),
  (text: 'She was the most magnificent creature in all the...', top: 0.15, left: 0.05, rot: 1.2),
  (text: 'The old wizard had a peculiar habit of collecting...', top: 0.24, left: -0.02, rot: -0.8),
  (text: 'Nobody expected the extraordinary letter that arrived...', top: 0.33, left: 0.03, rot: 1.5),
  (text: 'With a tremendous leap he soared over the...', top: 0.55, left: 0.0, rot: -1.2),
  (text: 'The mysterious village had a delightfully chaotic...', top: 0.64, left: 0.04, rot: 0.9),
  (text: 'She declared in the most dramatic voice that...', top: 0.73, left: -0.01, rot: -1.5),
  (text: 'It was a dark and stormy night when the peculiar...', top: 0.82, left: 0.02, rot: 1.0),
  (text: 'The legendary cat sat on the absolutely enormous...', top: 0.91, left: 0.0, rot: -0.7),
];

// The line that looks actively typed (positioned near the middle)
const _kTypingLine = 'The brave yet clumsy knight grabbed his';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _auth = AuthService();
  bool _loading = false;

  late AnimationController _pulseController;
  late AnimationController _cursorController;
  late AnimationController _typingController;

  int _typedChars = 0;

  final List<String> _adjectives = ['creative', 'hilarious', 'ridiculous', 'epic', 'wild', 'chaotic', 'legendary'];
  int _wordIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _cursorController = AnimationController(vsync: this, duration: const Duration(milliseconds: 530))..repeat(reverse: true);
    _typingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _startTyping();
    _startWordRotation();
  }

  Future<void> _startTyping() async {
    await Future.delayed(const Duration(milliseconds: 800));
    while (mounted && _typedChars < _kTypingLine.length) {
      await Future.delayed(const Duration(milliseconds: 70));
      if (!mounted) break;
      setState(() => _typedChars++);
    }
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
    _pulseController.dispose();
    _cursorController.dispose();
    _typingController.dispose();
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
            _buildStoryBackground(context),
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

  Widget _buildStoryBackground(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Static faded story lines
            for (var i = 0; i < _kFragments.length; i++)
              Positioned(
                top: MediaQuery.of(context).size.height * _kFragments[i].top,
                left: w * _kFragments[i].left,
                right: 0,
                child: Transform.rotate(
                  angle: _kFragments[i].rot * 0.0174533,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _kFragments[i].text,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: kText.withValues(alpha: 0.07 + (i % 3) * 0.02),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.2,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (400 + i * 150).ms, duration: 1200.ms),
              ),

            // Actively "typed" line with cursor in the middle of the screen
            Positioned(
              top: MediaQuery.of(context).size.height * 0.44,
              left: w * 0.02,
              right: 0,
              child: Transform.rotate(
                angle: -0.5 * 0.0174533,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _kTypingLine.substring(0, _typedChars),
                      style: GoogleFonts.lora(
                        fontSize: 13,
                        color: kAccent.withValues(alpha: 0.18),
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.2,
                      ),
                    ),
                    // Blinking cursor
                    AnimatedBuilder(
                      animation: _cursorController,
                      builder: (_, __) => Opacity(
                        opacity: _cursorController.value > 0.5 ? 1.0 : 0.0,
                        child: Container(
                          width: 1.5,
                          height: 13,
                          color: kAccent.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
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
              BoxShadow(
                color: kAccent.withValues(alpha: 0.12 + p * 0.18),
                blurRadius: 28 + p * 22,
                spreadRadius: 2 + p * 5,
              ),
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
