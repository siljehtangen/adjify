import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/room.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';

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
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        setState(() => _starting = false);
      }
    }
  }

  void _navigateToGame() {
    if (!mounted) return;
    final mode = _room?.mode;
    final route = switch (mode) {
      GameMode.fillReveal => '/game/fill-reveal/${widget.roomCode}',
      GameMode.rotatingChain => '/game/chain/${widget.roomCode}',
      GameMode.battle => '/game/battle/${widget.roomCode}',
      null => null,
    };
    if (route != null) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.white),
        title: Text(_room?.mode.displayName ?? 'Lobby', style: const TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room code
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Room Code', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                            Text(
                              widget.roomCode,
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.roomCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied!')),
                            );
                          },
                          icon: const Icon(Icons.copy, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  Text(
                    'Players (${_room?.players.length ?? 0}/${_room?.maxPlayers ?? '?'})',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _room?.players.length ?? 0,
                      separatorBuilder: (_, __) => const Gap(8),
                      itemBuilder: (ctx, i) {
                        final p = _room!.players[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: Text(
                                  (p.username ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(p.username ?? 'Player', style: const TextStyle(color: Colors.white)),
                              ),
                              if (p.role == 'host')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('HOST', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
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
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _starting
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text('Start Game', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  else
                    Center(
                      child: Text('Waiting for host to start…', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ),
                ],
              ),
            ),
    );
  }
}
