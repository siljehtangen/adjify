import 'story.dart';

class BattleEntry {
  final String id;
  final String roomId;
  final String playerId;
  final String? continuation;
  final bool submitted;
  final int voteCount;
  final Story? story;
  final String? username;

  const BattleEntry({
    required this.id,
    required this.roomId,
    required this.playerId,
    this.continuation,
    required this.submitted,
    required this.voteCount,
    this.story,
    this.username,
  });

  factory BattleEntry.fromJson(Map<String, dynamic> json) => BattleEntry(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        playerId: json['player_id'] as String,
        continuation: json['continuation'] as String?,
        submitted: json['submitted_at'] != null,
        voteCount: json['vote_count'] as int? ?? 0,
        story: json['stories'] != null
            ? Story.fromJson(json['stories'] as Map<String, dynamic>)
            : null,
        username: (json['profiles'] as Map<String, dynamic>?)?['username'] as String?,
      );
}
