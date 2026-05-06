import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
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
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showErrorToast(e is ApiException ? e.message : l10n.roomNotFound);
      }
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(color: kText),
        title: Text(l10n.joinARoom, style: AppTextStyle.appBarTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameCard(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                borderColor: kAccent.withValues(alpha: 0.3),
                shadowColor: kAccent.withValues(alpha: 0.1),
                borderRadius: 18,
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
                            l10n.enterRoomCode,
                            style: AppTextStyle.cardTitle,
                          ),
                          const Gap(3),
                          Text(
                            l10n.askHostForCode,
                            style: const TextStyle(color: kTextSub, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideX(begin: 0.06, end: 0),
              const Gap(28),
              Text(
                l10n.roomCodeLabel,
                style: AppTextStyle.sectionTitle,
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
                  style: AppTextStyle.roomCodeInput,
                  decoration: InputDecoration(
                    hintText: '· · · · · ·',
                    hintStyle: AppTextStyle.roomCodeHint,
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
                  l10n.lettersAndNumbersOnly,
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
                    foregroundColor: kNight,
                    elevation: 8,
                    shadowColor: kAccent.withValues(alpha: 0.45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: kNight, strokeWidth: 2.5),
                        )
                      : Text(
                          l10n.joinRoom,
                          style: AppTextStyle.buttonLabelDark,
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
