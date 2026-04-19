import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/room.dart';
import '../../services/api_service.dart';

const _kBg = Color(0xFFFDF8F0);
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE8DDD0);
const _kText = Color(0xFF2C1A0E);
const _kTextSub = Color(0xFF9B7B63);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _modeColor(widget.mode);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: const BackButton(color: _kText),
        title: Text(
          widget.mode.displayName,
          style: GoogleFonts.lora(color: _kText, fontWeight: FontWeight.w600),
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
              style: GoogleFonts.lora(
                color: _kText,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(6),
            Text(
              _playerHint(widget.mode),
              style: const TextStyle(color: _kTextSub, fontSize: 13),
            ),
            const Gap(16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _options.map((n) {
                final selected = _maxPlayers == n;
                return GestureDetector(
                  onTap: () => setState(() => _maxPlayers = n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: selected ? color : _kSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? color : _kBorder,
                        width: selected ? 2 : 1.5,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Center(
                      child: n == 1
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.user,
                                  size: 16,
                                  color: selected ? Colors.white : color,
                                ),
                                const Gap(2),
                                Text(
                                  'Solo',
                                  style: TextStyle(
                                    color: selected ? Colors.white : color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '$n',
                              style: TextStyle(
                                color: selected ? Colors.white : _kText,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        'Create Room',
                        style: GoogleFonts.lora(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  Color _modeColor(GameMode mode) => switch (mode) {
        GameMode.fillReveal => const Color(0xFF7B5EA7),
        GameMode.rotatingChain => const Color(0xFF3A8C6E),
        GameMode.battle => const Color(0xFFC94F3A),
      };
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
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: FaIcon(icon, color: color, size: 20)),
          ),
          const Gap(14),
          Expanded(
            child: Text(desc, style: const TextStyle(color: _kTextSub, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
