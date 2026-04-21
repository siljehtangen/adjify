import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Sign in failed: $e');
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
            colors: [kBg, Color(0xFF172938), Color(0xFF1B3050)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: kAccent.withValues(alpha: 0.3), width: 2),
                      boxShadow: [
                        BoxShadow(color: kAccent.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 4),
                      ],
                    ),
                    child: const Center(child: Text('📖', style: TextStyle(fontSize: 42))),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const Gap(24),
                  const Text(
                    'Adjify',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                  const Gap(8),
                  Text(
                    'The adjective storytelling game',
                    style: TextStyle(fontSize: 16, color: kTextSub.withValues(alpha: 0.9)),
                  ).animate().fadeIn(delay: 400.ms),
                  const Gap(72),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _signIn,
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF060F1E)),
                            )
                          : Image.asset(
                              'assets/images/google_logo.png',
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(Icons.login, color: Color(0xFF060F1E)),
                            ),
                      label: Text(
                        _loading ? 'Signing in…' : 'Continue with Google',
                        style: const TextStyle(color: Color(0xFF060F1E), fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: const Color(0xFF060F1E),
                        elevation: 8,
                        shadowColor: kAccent.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
