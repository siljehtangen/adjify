import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/room.dart';
import '../../../models/story.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/blank_input_sheet.dart';

class FillRevealScreen extends StatefulWidget {
  final String roomCode;
  const FillRevealScreen({super.key, required this.roomCode});

  @override
  State<FillRevealScreen> createState() => _FillRevealScreenState();
}

class _FillRevealScreenState extends State<FillRevealScreen> {
  final _api = ApiService();
  final _socket = SocketService();

  List<Story> _stories = [];
  Room? _room;
  bool _loading = true;
  bool _revealed = false;

  final _storyController = TextEditingController();
  String get _myId => Supabase.instance.client.auth.currentUser!.id;
  bool get _isHost => _room?.hostId == _myId;
  int get _otherPlayerCount => (_room?.players.length ?? 1) - 1;

  @override
  void initState() {
    super.initState();
    _load();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on('game:blank_filled', (_) => _load());
    _socket.on('game:story_revealed', (_) { setState(() => _revealed = true); _load(); });
    _socket.on('game:story_created', (_) => _load());
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final room = await _api.getRoom(widget.roomCode);
      final stories = await _api.getStories(widget.roomCode);
      if (mounted) setState(() { _room = room; _stories = stories; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createStory() async {
    final content = _storyController.text.trim();
    if (content.isEmpty || !content.contains('[ADJ]')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story must contain at least one [ADJ] placeholder')),
      );
      return;
    }
    final blankCount = '[ADJ]'.allMatches(content).length;
    final minBlanks = _otherPlayerCount > 0 ? _otherPlayerCount : 1;
    if (blankCount < minBlanks) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add at least $minBlanks [ADJ] blank${minBlanks != 1 ? 's' : ''} — one per player')),
      );
      return;
    }
    try {
      await _api.createStory(widget.roomCode, content);
      _storyController.clear();
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _fillBlank(Story story, StoryBlank blank) async {
    if (blank.isFilled) return;

    final adjective = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlankInputSheet(position: blank.position),
    );

    if (adjective == null || adjective.isEmpty) return;

    try {
      final result = await _api.fillBlank(widget.roomCode, story.id, blank.position, adjective);
      _load();
      if (result['isComplete'] == true) setState(() => _revealed = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        title: const Text('Fill & Reveal', style: TextStyle(color: Colors.white)),
        actions: [
          if (_stories.isNotEmpty && _stories.first.isComplete)
            TextButton(
              onPressed: () => setState(() => _revealed = !_revealed),
              child: Text(_revealed ? 'Hide' : 'Reveal!', style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? (_isHost ? _buildStoryCreator() : _buildWaitingForStory())
              : _buildGameView(),
    );
  }

  Widget _buildWaitingForStory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_note, color: Color(0xFF6C63FF), size: 56),
            const Gap(16),
            const Text(
              'Waiting for the story writer…',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'The host is writing a story. You\'ll fill in the adjectives once it\'s ready.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCreator() {
    final minBlanks = _otherPlayerCount > 0 ? _otherPlayerCount : 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write a story', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Gap(8),
          Text(
            'Use [ADJ] as placeholders for adjectives.\n'
            '${_otherPlayerCount > 0 ? 'You need at least $minBlanks [ADJ] blank${minBlanks != 1 ? 's' : ''} — one per player.' : 'Example: "The [ADJ] cat sat on a [ADJ] mat."'}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
          ),
          const Gap(16),
          Expanded(
            child: TextField(
              controller: _storyController,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your story here…',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _createStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    final story = _stories.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_revealed) ...[
            if (_isHost) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF6C63FF), size: 18),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'You wrote this story. Wait for the other players to fill in the blanks.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
            ],
            // Progress
            Row(
              children: [
                Text(
                  '${story.filledCount}/${story.blanks.length} blanks filled',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
                const Gap(12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: story.blanks.isEmpty ? 0 : story.filledCount / story.blanks.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            const Gap(24),
            // Blank buttons — host cannot fill
            if (!_isHost)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: story.blanks.map((blank) {
                  return GestureDetector(
                    onTap: () => _fillBlank(story, blank),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: blank.isFilled
                            ? const Color(0xFF6C63FF).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: blank.isFilled
                              ? const Color(0xFF6C63FF)
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        blank.isFilled ? blank.adjective! : 'Blank ${blank.position + 1}',
                        style: TextStyle(
                          color: blank.isFilled ? Colors.white : Colors.white.withValues(alpha: 0.6),
                          fontWeight: blank.isFilled ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: story.blanks.map((blank) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: blank.isFilled
                          ? const Color(0xFF6C63FF).withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: blank.isFilled
                            ? const Color(0xFF6C63FF)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      blank.isFilled ? blank.adjective! : 'Blank ${blank.position + 1}',
                      style: TextStyle(
                        color: blank.isFilled ? Colors.white : Colors.white.withValues(alpha: 0.3),
                        fontWeight: blank.isFilled ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
              ),
              child: Text(
                story.rendered,
                style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.7),
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          ],
        ],
      ),
    );
  }
}
