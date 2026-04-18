class Story {
  final String id;
  final String roomId;
  final String content;
  final String createdBy;
  final List<StoryBlank> blanks;

  const Story({
    required this.id,
    required this.roomId,
    required this.content,
    required this.createdBy,
    this.blanks = const [],
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        content: json['content'] as String,
        createdBy: json['created_by'] as String,
        blanks: (json['story_blanks'] as List<dynamic>? ?? [])
            .map((b) => StoryBlank.fromJson(b as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position)),
      );

  bool get isComplete => blanks.isNotEmpty && blanks.every((b) => b.isFilled);

  int get filledCount => blanks.where((b) => b.isFilled).length;

  String get rendered {
    var result = content;
    for (final blank in blanks) {
      result = result.replaceFirst('[ADJ]', blank.adjective ?? '___');
    }
    return result;
  }
}

class StoryBlank {
  final String id;
  final String storyId;
  final int position;
  final String? filledBy;
  final String? adjective;

  const StoryBlank({
    required this.id,
    required this.storyId,
    required this.position,
    this.filledBy,
    this.adjective,
  });

  bool get isFilled => filledBy != null && adjective != null;

  factory StoryBlank.fromJson(Map<String, dynamic> json) => StoryBlank(
        id: json['id'] as String,
        storyId: json['story_id'] as String,
        position: json['position'] as int,
        filledBy: json['filled_by'] as String?,
        adjective: json['adjective'] as String?,
      );
}

class ChainSegment {
  final String id;
  final String roomId;
  final int roundNumber;
  final String segmentType; // 'sentence' | 'blank_fill'
  final String? content;
  final String authorId;

  const ChainSegment({
    required this.id,
    required this.roomId,
    required this.roundNumber,
    required this.segmentType,
    this.content,
    required this.authorId,
  });

  factory ChainSegment.fromJson(Map<String, dynamic> json) => ChainSegment(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        roundNumber: json['round_number'] as int,
        segmentType: json['segment_type'] as String,
        content: json['content'] as String?,
        authorId: json['author_id'] as String,
      );
}

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
