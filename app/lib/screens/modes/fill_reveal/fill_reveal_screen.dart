import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/room.dart';
import '../../../models/story.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/blank_input_sheet.dart';

const _kBg = Color(0xFF101D2E);
const _kSurface = Color(0xFF192C44);
const _kBorder = Color(0xFF284D6E);
const _kText = Color(0xFFEBF4FF);
const _kTextSub = Color(0xFF7DB9D8);
const _kAccent = Color(0xFF818CF8);


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
  bool get _isSolo => (_room?.maxPlayers ?? 2) == 1;
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

  void _insertAdj() {
    final text = _storyController.text;
    final sel = _storyController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final newText = text.substring(0, pos) + '[ADJ]' + text.substring(pos);
    _storyController.value = _storyController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + 5),
    );
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
      await _load();
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
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: const BackButton(color: _kText),
        title: const Text('Fill & Reveal', style: TextStyle(color: _kText)),
        actions: [
          if (_stories.isNotEmpty && _stories.first.isComplete)
            TextButton(
              onPressed: () => setState(() => _revealed = !_revealed),
              child: Text(
                _revealed ? 'Hide' : 'Reveal!',
                style: const TextStyle(color: _kAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
              ),
              child: const Center(child: Icon(Icons.edit_note, color: _kAccent, size: 38)),
            ),
            const Gap(20),
            const Text(
              'Waiting for the story writer…',
              style: TextStyle(color: _kText, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'The host is writing a story. You\'ll fill in the adjectives once it\'s ready.',
              style: TextStyle(color: _kTextSub.withValues(alpha: 0.8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCreator() {
    final minBlanks = _otherPlayerCount > 0 ? _otherPlayerCount : 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write a story', style: TextStyle(color: _kText, fontSize: 18, fontWeight: FontWeight.bold)),
          const Gap(8),
          Text(
            _isSolo
                ? 'Add [ADJ] placeholders — they\'ll be filled with random adjectives when you save.'
                : 'Use [ADJ] as placeholders for adjectives.\n'
                    '${_otherPlayerCount > 0 ? 'You need at least $minBlanks [ADJ] blank${minBlanks != 1 ? 's' : ''} — one per player.' : 'Example: "The [ADJ] cat sat on a [ADJ] mat."'}',
            style: const TextStyle(color: _kTextSub, fontSize: 14),
          ),
          const Gap(16),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              controller: _storyController,
              minLines: 8,
              maxLines: 16,
              style: const TextStyle(color: _kText),
              decoration: InputDecoration(
                hintText: 'Write your story here…',
                hintStyle: TextStyle(color: _kTextSub.withValues(alpha: 0.5)),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const Gap(10),
          GestureDetector(
            onTap: _insertAdj,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: _kAccent),
                  const Gap(4),
                  const Text(
                    '[ADJ]',
                    style: TextStyle(
                      color: _kAccent,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _createStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                elevation: 8,
                shadowColor: _kAccent.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _isSolo ? 'Save & Fill Randomly' : 'Save Story',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const Gap(24),
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
            if (_isHost && !_isSolo) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: _kAccent, size: 18),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'You wrote this story. Wait for the other players to fill in the blanks.',
                        style: TextStyle(color: _kText.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Text(
                story.rendered,
                style: const TextStyle(color: _kText, fontSize: 16, height: 1.6),
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Text(
                  '${story.filledCount}/${story.blanks.length} blanks filled',
                  style: const TextStyle(color: _kTextSub),
                ),
                const Gap(12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: story.blanks.isEmpty ? 0 : story.filledCount / story.blanks.length,
                      backgroundColor: _kBorder,
                      color: _kAccent,
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            if (!_isHost || _isSolo)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: story.blanks.map((blank) {
                  return GestureDetector(
                    onTap: () => _fillBlank(story, blank),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: blank.isFilled
                            ? _kAccent.withValues(alpha: 0.2)
                            : _kSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: blank.isFilled ? _kAccent : _kBorder,
                        ),
                        boxShadow: blank.isFilled
                            ? [BoxShadow(color: _kAccent.withValues(alpha: 0.25), blurRadius: 8)]
                            : [],
                      ),
                      child: Text(
                        blank.isFilled ? blank.adjective! : 'Blank ${blank.position + 1}',
                        style: TextStyle(
                          color: blank.isFilled ? _kAccent : _kTextSub,
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
                      color: blank.isFilled ? _kAccent.withValues(alpha: 0.15) : _kSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: blank.isFilled ? _kAccent.withValues(alpha: 0.5) : _kBorder,
                      ),
                    ),
                    child: Text(
                      blank.isFilled ? blank.adjective! : 'Blank ${blank.position + 1}',
                      style: TextStyle(
                        color: blank.isFilled ? _kAccent : _kTextSub.withValues(alpha: 0.4),
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
                color: _kSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kAccent.withValues(alpha: 0.4)),
                boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.15), blurRadius: 20)],
              ),
              child: Text(
                story.rendered,
                style: const TextStyle(color: _kText, fontSize: 18, height: 1.7),
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          ],
        ],
      ),
    );
  }
}
