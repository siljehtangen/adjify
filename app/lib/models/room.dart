enum GameMode { fillReveal, rotatingChain, battle }

enum RoomStatus { waiting, inProgress, finished }

extension GameModeX on GameMode {
  String get value => switch (this) {
        GameMode.fillReveal => 'fill_reveal',
        GameMode.rotatingChain => 'rotating_chain',
        GameMode.battle => 'battle',
      };

  String get displayName => switch (this) {
        GameMode.fillReveal => 'Fill & Reveal',
        GameMode.rotatingChain => 'Rotating Chain',
        GameMode.battle => 'Adjective Battle',
      };

  static GameMode fromString(String s) => switch (s) {
        'fill_reveal' => GameMode.fillReveal,
        'rotating_chain' => GameMode.rotatingChain,
        'battle' => GameMode.battle,
        _ => GameMode.fillReveal,
      };
}

class Room {
  final String id;
  final String code;
  final GameMode mode;
  final RoomStatus status;
  final String hostId;
  final int maxPlayers;
  final List<RoomPlayer> players;

  const Room({
    required this.id,
    required this.code,
    required this.mode,
    required this.status,
    required this.hostId,
    required this.maxPlayers,
    this.players = const [],
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        code: json['code'] as String,
        mode: GameModeX.fromString(json['mode'] as String),
        status: _statusFromString(json['status'] as String),
        hostId: json['host_id'] as String,
        maxPlayers: json['max_players'] as int,
        players: (json['room_players'] as List<dynamic>? ?? [])
            .map((p) => RoomPlayer.fromJson(p as Map<String, dynamic>))
            .toList(),
      );

  static RoomStatus _statusFromString(String s) => switch (s) {
        'waiting' => RoomStatus.waiting,
        'in_progress' => RoomStatus.inProgress,
        'finished' => RoomStatus.finished,
        _ => RoomStatus.waiting,
      };
}

class RoomPlayer {
  final String id;
  final String playerId;
  final String role;
  final String? username;
  final String? avatarUrl;

  const RoomPlayer({
    required this.id,
    required this.playerId,
    required this.role,
    this.username,
    this.avatarUrl,
  });

  factory RoomPlayer.fromJson(Map<String, dynamic> json) => RoomPlayer(
        id: json['id'] as String,
        playerId: json['player_id'] as String,
        role: json['role'] as String,
        username: (json['profiles'] as Map<String, dynamic>?)?['username'] as String?,
        avatarUrl: (json['profiles'] as Map<String, dynamic>?)?['avatar_url'] as String?,
      );
}
