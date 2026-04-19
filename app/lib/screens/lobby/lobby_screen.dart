import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/room.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';

const _kBg = Color(0xFF101D2E);
const _kSurface = Color(0xFF192C44);
const _kBorder = Color(0xFF284D6E);
const _kText = Color(0xFFEBF4FF);
const _kTextSub = Color(0xFF7DB9D8);
const _kGold = Color(0xFFFBBF24);

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  const LobbyScreen({super.key, required this.roomCode});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _api = ApiService();
  final _socket = SocketService();
  Room? _room;
  bool _loading = true;
  bool _starting = false;

  String get _myId => Supabase.instance.client.auth.currentUser!.id;
  bool get _isHost => _room?.hostId == _myId;

  @override
  void initState() {
    super.initState();
    _loadRoom();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on('room:player_joined', (_) => _loadRoom());
    _socket.on('room:player_left', (_) => _loadRoom());
    _socket.on('room:game_started', (_) => _navigateToGame());
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    try {
      final room = await _api.getRoom(widget.roomCode);
      if (mounted) setState(() { _room = room; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      await _api.startGame(widget.roomCode);
      _navigateToGame();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFB7185),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() => _starting = false);
      }
    }
  }

  void _navigateToGame() {
    if (!mounted) return;
    final route = switch (_room?.mode) {
      GameMode.fillReveal => '/game/fill-reveal/${widget.roomCode}',
      GameMode.rotatingChain => '/game/chain/${widget.roomCode}',
      GameMode.battle => '/game/battle/${widget.roomCode}',
      null => null,
    };
    if (route != null) context.go(route);
  }

  Color get _modeColor => switch (_room?.mode) {
        GameMode.fillReveal => const Color(0xFF818CF8),
        GameMode.rotatingChain => const Color(0xFF2DD4BF),
        GameMode.battle => const Color(0xFFFB7185),
        null => const Color(0xFF38BDF8),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: const BackButton(color: _kText),
        title: Text(
          _room?.mode.displayName ?? 'Lobby',
          style: GoogleFonts.lora(color: _kText, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoomCodeCard(roomCode: widget.roomCode),
                  const Gap(24),
                  Row(
                    children: [
                      Text(
                        'Players',
                        style: GoogleFonts.lora(
                          color: _kText,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _modeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _modeColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '${_room?.players.length ?? 0} / ${_room?.maxPlayers ?? '?'}',
                          style: TextStyle(
                            color: _modeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _room?.players.length ?? 0,
                      separatorBuilder: (_, __) => const Gap(8),
                      itemBuilder: (ctx, i) {
                        final p = _room!.players[i];
                        final isHost = p.role == 'host';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _modeColor.withValues(alpha: 0.15),
                                child: Text(
                                  (p.username ?? '?')[0].toUpperCase(),
                                  style: TextStyle(
                                    color: _modeColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  p.username ?? 'Player',
                                  style: const TextStyle(color: _kText, fontWeight: FontWeight.w500),
                                ),
                              ),
                              if (isHost)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _kGold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _kGold.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FaIcon(FontAwesomeIcons.crown, size: 10, color: _kGold),
                                      Gap(4),
                                      Text(
                                        'HOST',
                                        style: TextStyle(
                                          color: _kGold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Gap(16),
                  if (_isHost)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _starting ? null : _start,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _modeColor,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: _modeColor.withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _starting
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(
                                'Start Game',
                                style: GoogleFonts.lora(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    )
                  else
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(FontAwesomeIcons.hourglassHalf, size: 14, color: _kTextSub),
                          const Gap(8),
                          Text(
                            'Waiting for host to start…',
                            style: TextStyle(color: _kTextSub.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  const Gap(8),
                ],
              ),
            ),
    );
  }
}

class _RoomCodeCard extends StatelessWidget {
  final String roomCode;
  const _RoomCodeCard({required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Room Code', style: TextStyle(color: _kTextSub, fontSize: 12)),
              const Gap(2),
              Text(
                roomCode,
                style: GoogleFonts.lora(
                  color: const Color(0xFF38BDF8),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: roomCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Code copied!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.copy, size: 16, color: Color(0xFF38BDF8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
