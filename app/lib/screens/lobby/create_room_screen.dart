import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/room.dart';
import '../../services/api_service.dart';
import '../../widgets/game_widgets.dart';

class CreateRoomScreen extends StatefulWidget {
  final GameMode mode;
  const CreateRoomScreen({super.key, required this.mode});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _api = ApiService();
  bool _loading = false;
  late int _maxPlayers;

  List<int> get _options => switch (widget.mode) {
        GameMode.fillReveal => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        GameMode.rotatingChain => [2, 3, 4, 5, 6],
        GameMode.battle => [2, 3, 4, 5, 6, 7, 8],
      };

  @override
  void initState() {
    super.initState();
    _maxPlayers = _options.first;
  }

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final room = await _api.createRoom(widget.mode, maxPlayers: _maxPlayers);
      if (mounted) context.push('/lobby/${room.code}', extra: room);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showErrorToast(e is ApiException ? e.message : l10n.failedToCreateRoom);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _modeDisplayName(AppLocalizations l10n) => switch (widget.mode) {
        GameMode.fillReveal => l10n.modeFillReveal,
        GameMode.rotatingChain => l10n.modeRotatingChain,
        GameMode.battle => l10n.modeAdjectiveBattle,
      };

  String _playerHint(AppLocalizations l10n) => switch (widget.mode) {
        GameMode.fillReveal => l10n.fillRevealPlayerHint,
        GameMode.rotatingChain => l10n.rotatingChainPlayerHint,
        GameMode.battle => l10n.battlePlayerHint,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = widget.mode.color;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(color: kText),
        title: Text(
          _modeDisplayName(l10n),
          style: AppTextStyle.appBarTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModeInfoBanner(mode: widget.mode, color: color, l10n: l10n),
            const Gap(28),
            Text(
              l10n.numberOfPlayers,
              style: AppTextStyle.sectionTitle,
            ),
            const Gap(6),
            Text(_playerHint(l10n), style: const TextStyle(color: kTextSub, fontSize: 13)),
            const Gap(16),
            _PlayerCountPicker(
              options: _options,
              selected: _maxPlayers,
              color: color,
              soloLabel: l10n.solo,
              onSelect: (n) => setState(() => _maxPlayers = n),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: color.withValues(alpha: 0.45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        l10n.createRoom,
                        style: AppTextStyle.buttonLabel,
                      ),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class _PlayerCountPicker extends StatelessWidget {
  final List<int> options;
  final int selected;
  final Color color;
  final String soloLabel;
  final void Function(int) onSelect;

  const _PlayerCountPicker({
    required this.options,
    required this.selected,
    required this.color,
    required this.soloLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((n) {
        final isSelected = selected == n;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onSelect(n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isSelected ? color : kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? color : kBorder, width: isSelected ? 2 : 1.5),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Center(
                child: n == 1
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.user, size: 16, color: isSelected ? Colors.white : color),
                          const Gap(2),
                          Text(
                            soloLabel,
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '$n',
                        style: TextStyle(
                          color: isSelected ? Colors.white : kText,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ModeInfoBanner extends StatelessWidget {
  final GameMode mode;
  final Color color;
  final AppLocalizations l10n;

  const _ModeInfoBanner({required this.mode, required this.color, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (icon, desc) = switch (mode) {
      GameMode.fillReveal => (FontAwesomeIcons.bookOpen, l10n.fillRevealBannerDesc),
      GameMode.rotatingChain => (FontAwesomeIcons.arrowsRotate, l10n.rotatingChainBannerDesc),
      GameMode.battle => (FontAwesomeIcons.trophy, l10n.battleBannerDesc),
    };

    return GameCard(
      padding: const EdgeInsets.all(18),
      borderColor: color.withValues(alpha: 0.3),
      shadowColor: color.withValues(alpha: 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(child: FaIcon(icon, color: color, size: 20)),
          ),
          const Gap(14),
          Expanded(child: Text(desc, style: const TextStyle(color: kTextSub, fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}
