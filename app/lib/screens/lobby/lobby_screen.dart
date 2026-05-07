import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/room.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../../widgets/game_widgets.dart';
import 'room_code_card.dart';

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
  String? _error;

  String get _myId => Supabase.instance.client.auth.currentUser?.id ?? '';
  bool get _isHost => _room?.hostId == _myId;

  @override
  void initState() {
    super.initState();
    _loadRoom();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on(SocketEvent.playerJoined, (_) { if (mounted) _loadRoom(); });
    _socket.on(SocketEvent.playerLeft, (_) { if (mounted) _loadRoom(); });
    _socket.on(SocketEvent.gameStarted, (_) { if (mounted) _navigateToGame(); });
  }

  @override
  void dispose() {
    _socket.off(SocketEvent.playerJoined);
    _socket.off(SocketEvent.playerLeft);
    _socket.off(SocketEvent.gameStarted);
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    if (mounted) setState(() => _error = null);
    try {
      final room = await _api.getRoom(widget.roomCode);
      if (mounted) setState(() { _room = room; _loading = false; });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() { _loading = false; _error = e is ApiException ? e.message : l10n.failedToLoadRoom; });
      }
    }
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      await _api.startGame(widget.roomCode);
      // Navigation happens via the gameStarted socket event (emitted to all room members
      // including the host), so we don't navigate here to avoid a double-navigation.
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showErrorToast(e is ApiException ? e.message : l10n.failedToStartGame);
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

  Color get _modeColor => _room?.mode.color ?? kAccent;

  String _modeTitle(AppLocalizations l10n) {
    if (_room == null) return l10n.lobby;
    return switch (_room!.mode) {
      GameMode.fillReveal => l10n.modeFillReveal,
      GameMode.rotatingChain => l10n.modeRotatingChain,
      GameMode.battle => l10n.modeAdjectiveBattle,
    };
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
        title: Text(
          _modeTitle(l10n),
          style: AppTextStyle.appBarTitle,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _error != null
              ? ErrorRetry(error: _error!, onRetry: _loadRoom)
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoomCodeCard(roomCode: widget.roomCode),
                      const Gap(24),
                      _PlayersHeader(room: _room, modeColor: _modeColor, label: l10n.players),
                      const Gap(12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _room?.players.length ?? 0,
                          separatorBuilder: (_, __) => const Gap(8),
                          itemBuilder: (_, i) => _PlayerTile(
                            player: _room!.players[i],
                            modeColor: _modeColor,
                            hostBadge: l10n.hostBadge,
                            playerFallback: l10n.player,
                          ),
                        ),
                      ),
                      const Gap(16),
                      _LobbyFooter(
                        isHost: _isHost,
                        starting: _starting,
                        modeColor: _modeColor,
                        onStart: _start,
                        startLabel: l10n.startGame,
                        waitingLabel: l10n.waitingForHostToStart,
                      ),
                      const Gap(8),
                    ],
                  ),
                ),
    );
  }
}

class _PlayersHeader extends StatelessWidget {
  final Room? room;
  final Color modeColor;
  final String label;
  const _PlayersHeader({required this.room, required this.modeColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyle.sectionTitle,
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: modeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.badge),
            border: Border.all(color: modeColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            '${room?.players.length ?? 0} / ${room?.maxPlayers ?? '?'}',
            style: TextStyle(color: modeColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final RoomPlayer player;
  final Color modeColor;
  final String hostBadge;
  final String playerFallback;
  const _PlayerTile({
    required this.player,
    required this.modeColor,
    required this.hostBadge,
    required this.playerFallback,
  });

  @override
  Widget build(BuildContext context) {
    final isHost = player.role == 'host';
    return GameCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: modeColor.withValues(alpha: 0.15),
            child: Text(
              (player.username ?? '?')[0].toUpperCase(),
              style: TextStyle(color: modeColor, fontWeight: FontWeight.w700),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              player.username ?? playerFallback,
              style: const TextStyle(color: kText, fontWeight: FontWeight.w500),
            ),
          ),
          if (isHost) _HostBadge(label: hostBadge),
        ],
      ),
    );
  }
}

class _HostBadge extends StatelessWidget {
  final String label;
  const _HostBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: kGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(FontAwesomeIcons.crown, size: 10, color: kGold),
          const Gap(4),
          Text(label, style: const TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LobbyFooter extends StatelessWidget {
  final bool isHost;
  final bool starting;
  final Color modeColor;
  final VoidCallback onStart;
  final String startLabel;
  final String waitingLabel;
  const _LobbyFooter({
    required this.isHost,
    required this.starting,
    required this.modeColor,
    required this.onStart,
    required this.startLabel,
    required this.waitingLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (isHost) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: starting ? null : onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: modeColor,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: modeColor.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: starting
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(startLabel, style: AppTextStyle.buttonLabel),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.hourglassHalf, size: 14, color: kTextSub),
          const Gap(8),
          Text(
            waitingLabel,
            style: TextStyle(color: kTextSub.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
