import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_colors.dart';
import '../../../models/story.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/blank_input_sheet.dart';
import '../../../widgets/game_widgets.dart';
import 'filling_view.dart';
import 'revealed_view.dart';
import 'story_creator_view.dart';

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
  bool _loading = true;
  bool _revealed = false;
  String? _hostId;
  int? _maxPlayers;
  String? _error;

  final _storyController = TextEditingController();
  String get _myId => Supabase.instance.client.auth.currentUser?.id ?? '';
  bool get _isHost => _hostId == _myId;
  bool get _isSolo => (_maxPlayers ?? 2) == 1;
  int get _otherPlayerCount => (_maxPlayers ?? 1) - 1;

  @override
  void initState() {
    super.initState();
    _load();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on(SocketEvent.blankFilled, (_) { if (mounted) _load(); });
    _socket.on(SocketEvent.storyRevealed, (_) { if (mounted) { setState(() => _revealed = true); _load(); } });
    _socket.on(SocketEvent.storyCreated, (_) { if (mounted) _load(); });
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _error = null);
    try {
      final room = await _api.getRoom(widget.roomCode);
      final stories = await _api.getStories(widget.roomCode);
      if (mounted) {
        setState(() {
          _hostId = room.hostId;
          _maxPlayers = room.maxPlayers;
          _stories = stories;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e is ApiException ? e.message : 'Failed to load game'; });
    }
  }

  void _insertAdj() {
    final text = _storyController.text;
    final sel = _storyController.selection;
    final pos = sel.baseOffset < 0 ? text.length : sel.baseOffset;
    final newText = '${text.substring(0, pos)}$kAdjPlaceholder${text.substring(pos)}';
    _storyController.value = _storyController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + kAdjPlaceholder.length),
    );
  }

  Future<void> _createStory() async {
    final content = _storyController.text.trim();
    if (content.isEmpty || !content.contains(kAdjPlaceholder)) {
      showErrorSnackBar(context, 'Story must contain at least one $kAdjPlaceholder placeholder');
      return;
    }
    final blankCount = kAdjPlaceholder.allMatches(content).length;
    final minBlanks = _otherPlayerCount > 0 ? _otherPlayerCount : 1;
    if (blankCount < minBlanks) {
      showErrorSnackBar(context, 'Add at least $minBlanks $kAdjPlaceholder blank${minBlanks != 1 ? 's' : ''} — one per player');
      return;
    }
    try {
      await _api.createStory(widget.roomCode, content);
      _storyController.clear();
      await _load();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
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
      await _load();
      if (result['isComplete'] == true && mounted) setState(() => _revealed = true);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(color: kText),
        title: const Text('Fill & Reveal', style: TextStyle(color: kText)),
        actions: [
          if (_stories.isNotEmpty && _stories.first.isComplete)
            TextButton(
              onPressed: () => setState(() => _revealed = !_revealed),
              child: Text(
                _revealed ? 'Hide' : 'Reveal!',
                style: const TextStyle(color: kFillReveal, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kFillReveal))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: kTextSub)),
                  const Gap(12),
                  TextButton(onPressed: _load, child: const Text('Retry', style: TextStyle(color: kFillReveal))),
                ]))
          : _stories.isEmpty
              ? (_isHost ? _buildStoryCreator() : _buildWaitingForStory())
              : _buildGameView(),
    );
  }

  Widget _buildWaitingForStory() {
    return const WaitingPlaceholder(
      icon: Icon(Icons.edit_note, color: kFillReveal, size: 38),
      title: 'Waiting for the story writer…',
      subtitle: 'The host is writing a story. You\'ll fill in the adjectives once it\'s ready.',
      accent: kFillReveal,
      size: 80,
      padding: EdgeInsets.all(32),
    );
  }

  Widget _buildStoryCreator() {
    return StoryCreatorView(
      storyController: _storyController,
      isSolo: _isSolo,
      otherPlayerCount: _otherPlayerCount,
      onInsertAdj: _insertAdj,
      onCreateStory: _createStory,
    );
  }

  Widget _buildGameView() {
    final story = _stories.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_revealed)
            FillingView(story: story, isHost: _isHost, isSolo: _isSolo, onFillBlank: _fillBlank)
          else
            RevealedView(story: story),
        ],
      ),
    );
  }
}
