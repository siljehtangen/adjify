enum SegmentType { sentence, blankFill }

extension SegmentTypeX on SegmentType {
  String get value => switch (this) {
        SegmentType.sentence => 'sentence',
        SegmentType.blankFill => 'blank_fill',
      };

  static SegmentType fromString(String s) => switch (s) {
        'blank_fill' => SegmentType.blankFill,
        _ => SegmentType.sentence,
      };
}

class ChainSegment {
  final String id;
  final String roomId;
  final int roundNumber;
  final SegmentType segmentType;
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
        segmentType: SegmentTypeX.fromString(json['segment_type'] as String),
        content: json['content'] as String?,
        authorId: json['author_id'] as String,
      );
}
