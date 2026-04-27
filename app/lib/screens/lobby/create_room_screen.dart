import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
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
      if (mounted) showErrorToast(e is ApiException ? e.message : 'Failed to create room');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.mode.color;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(color: kText),
        title: Text(
          widget.mode.displayName,
          style: GoogleFonts.lora(color: kText, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModeInfoBanner(mode: widget.mode, color: color),
            const Gap(28),
            Text(
              'Number of players',
              style: GoogleFonts.lora(color: kText, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const Gap(6),
            Text(_playerHint(widget.mode), style: const TextStyle(color: kTextSub, fontSize: 13)),
            const Gap(16),
            _PlayerCountPicker(
              options: _options,
              selected: _maxPlayers,
              color: color,
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
                        'Create Room',
                        style: GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  String _playerHint(GameMode mode) => switch (mode) {
        GameMode.fillReveal => 'Solo = just you. Multiplayer = you write the story, others fill the blanks. You need at least one [ADJ] blank per other player.',
        GameMode.rotatingChain => 'Min 2, max 6 — each player writes one step.',
        GameMode.battle => 'Min 2, max 8 — everyone fills the same story and votes.',
      };

}

class _PlayerCountPicker extends StatelessWidget {
  final List<int> options;
  final int selected;
  final Color color;
  final void Function(int) onSelect;

  const _PlayerCountPicker({
    required this.options,
    required this.selected,
    required this.color,
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
                            'Solo',
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

  const _ModeInfoBanner({required this.mode, required this.color});

  @override
  Widget build(BuildContext context) {
    final (icon, desc) = switch (mode) {
      GameMode.fillReveal => (
          FontAwesomeIcons.bookOpen,
          'Write a story with adjective blanks. Everyone fills them in — then the full story is revealed!'
        ),
      GameMode.rotatingChain => (
          FontAwesomeIcons.arrowsRotate,
          'Each player writes one part of the story in secret, passing it around the chain.'
        ),
      GameMode.battle => (
          FontAwesomeIcons.trophy,
          'All players fill the same story independently. The group votes for the funniest result!'
        ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))],
      ),
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
