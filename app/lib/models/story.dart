const kAdjPlaceholder = '[ADJ]';

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
      result = result.replaceFirst(kAdjPlaceholder, blank.adjective ?? '___');
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

