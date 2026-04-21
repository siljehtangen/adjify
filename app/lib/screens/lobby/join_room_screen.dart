import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/game_widgets.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _controller = TextEditingController();
  final _api = ApiService();
  bool _loading = false;

  Future<void> _join() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length < 4) return;

    setState(() => _loading = true);
    try {
      final room = await _api.joinRoom(code);
      if (mounted) context.push('/lobby/${room.code}', extra: room);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(color: kText),
        title: Text('Join a Room', style: GoogleFonts.lora(color: kText, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kAccent.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: kAccent.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kAccent.withValues(alpha: 0.3)),
                      ),
                      child: const Center(child: FaIcon(FontAwesomeIcons.doorOpen, color: kAccent, size: 22)),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter a room code',
                            style: GoogleFonts.lora(color: kText, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const Gap(3),
                          const Text(
                            'Ask your host for the 6-character code',
                            style: TextStyle(color: kTextSub, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideX(begin: 0.06, end: 0),
              const Gap(28),
              Text(
                'Room Code',
                style: GoogleFonts.lora(color: kText, fontSize: 17, fontWeight: FontWeight.w600),
              ).animate().fadeIn(delay: 100.ms),
              const Gap(10),
              Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder, width: 1.5),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 8,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(color: kText, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '· · · · · ·',
                    hintStyle: GoogleFonts.lora(color: kBorder, fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.w700),
                    filled: false,
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  ),
                  onSubmitted: (_) => _join(),
                  onChanged: (_) => setState(() {}),
                ),
              ).animate().fadeIn(delay: 150.ms),
              const Gap(10),
              Center(
                child: Text(
                  'Letters and numbers only',
                  style: TextStyle(color: kTextSub.withValues(alpha: 0.7), fontSize: 12),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_loading || _controller.text.trim().length < 4) ? null : _join,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    disabledBackgroundColor: kBorder,
                    foregroundColor: const Color(0xFF060F1E),
                    elevation: 8,
                    shadowColor: kAccent.withValues(alpha: 0.45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Color(0xFF060F1E), strokeWidth: 2.5),
                        )
                      : Text(
                          'Join Room',
                          style: GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFF060F1E)),
                        ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
