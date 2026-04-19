import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/story.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';

const _kBg = Color(0xFF060F1E);
const _kSurface = Color(0xFF0B1D35);
const _kBorder = Color(0xFF1A3A5C);
const _kText = Color(0xFFEBF4FF);
const _kTextSub = Color(0xFF7DB9D8);
const _kAccent = Color(0xFFFB7185);

enum BattlePhase { filling, waiting, voting, results }

class BattleScreen extends StatefulWidget {
  final String roomCode;
  const BattleScreen({super.key, required this.roomCode});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final _api = ApiService();
  final _socket = SocketService();

  BattlePhase _phase = BattlePhase.filling;
  Map<String, dynamic>? _prompt;
  final _adjectives = <int, TextEditingController>{};
  final _continuationController = TextEditingController();
  List<BattleEntry> _results = [];
  bool _loading = true;
  bool _submitting = false;
  String? _votedEntryId;

  String get _myId => Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on('game:battle_submitted', (_) {});
    _socket.on('game:battle_reveal', (_) { setState(() => _phase = BattlePhase.voting); _loadResults(); });
    _socket.on('game:vote_cast', (_) => _loadResults());
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    _continuationController.dispose();
    for (final c in _adjectives.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadPrompt() async {
    try {
      final prompt = await _api.getBattlePrompt(widget.roomCode);
      final blanks = (prompt['story_blanks'] as List?)?.length ?? 0;
      for (var i = 0; i < blanks; i++) {
        _adjectives[i] = TextEditingController();
      }
      if (mounted) setState(() { _prompt = prompt; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadResults() async {
    try {
      final results = await _api.getBattleResults(widget.roomCode);
      if (mounted) setState(() => _results = results);
    } catch (_) {}
  }

  Future<void> _submit() async {
    final continuation = _continuationController.text.trim();
    if (continuation.isEmpty) return;

    final blanks = _adjectives.entries
        .map((e) => {'position': e.key, 'adjective': e.value.text.trim()})
        .where((b) => (b['adjective'] as String).isNotEmpty)
        .toList();

    setState(() => _submitting = true);
    try {
      final result = await _api.submitBattleEntry(
        widget.roomCode,
        _prompt!['id'] as String,
        blanks,
        continuation,
      );
      setState(() {
        _phase = result['allSubmitted'] == true ? BattlePhase.voting : BattlePhase.waiting;
        _submitting = false;
      });
      if (result['allSubmitted'] == true) _loadResults();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _vote(String entryId) async {
    if (_votedEntryId != null) return;
    try {
      await _api.castVote(widget.roomCode, entryId);
      setState(() => _votedEntryId = entryId);
      _loadResults();
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
        title: const Text('Adjective Battle', style: TextStyle(color: _kText)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : switch (_phase) {
              BattlePhase.filling => _buildFilling(),
              BattlePhase.waiting => _buildWaiting(),
              BattlePhase.voting => _buildVoting(),
              BattlePhase.results => _buildResults(),
            },
    );
  }

  Widget _buildFilling() {
    final content = _prompt?['content'] as String? ?? '';
    final blankCount = _adjectives.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kAccent.withValues(alpha: 0.35)),
              boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.1), blurRadius: 16)],
            ),
            child: Text(
              content.replaceAll('[ADJ]', '______'),
              style: const TextStyle(color: _kText, fontSize: 16, height: 1.6),
            ),
          ),
          const Gap(24),
          const Text('Fill in the adjectives', style: TextStyle(color: _kText, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(12),
          for (var i = 0; i < blankCount; i++) ...[
            Container(
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: TextField(
                controller: _adjectives[i],
                style: const TextStyle(color: _kText),
                decoration: InputDecoration(
                  labelText: 'Blank ${i + 1}',
                  labelStyle: const TextStyle(color: _kTextSub),
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const Gap(8),
          ],
          const Gap(16),
          const Text('Your continuation', style: TextStyle(color: _kText, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(8),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              controller: _continuationController,
              maxLines: 4,
              style: const TextStyle(color: _kText),
              decoration: InputDecoration(
                hintText: 'Continue the story in your own words…',
                hintStyle: TextStyle(color: _kTextSub.withValues(alpha: 0.5)),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                elevation: 8,
                shadowColor: _kAccent.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Submit Story', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
              boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.15), blurRadius: 24)],
            ),
            child: const Center(child: Text('✅', style: TextStyle(fontSize: 40))),
          ),
          const Gap(20),
          const Text('Story submitted!', style: TextStyle(color: _kText, fontSize: 22, fontWeight: FontWeight.bold)),
          const Gap(8),
          const Text('Waiting for other players…', style: TextStyle(color: _kTextSub)),
        ],
      ),
    );
  }

  Widget _buildVoting() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Vote for the best story!', style: TextStyle(color: _kText, fontSize: 20, fontWeight: FontWeight.bold)),
        const Gap(16),
        for (final entry in _results)
          if (entry.playerId != _myId) ...[
            _EntryCard(
              entry: entry,
              voted: _votedEntryId == entry.id,
              canVote: _votedEntryId == null,
              onVote: () => _vote(entry.id),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            const Gap(12),
          ],
      ],
    );
  }

  Widget _buildResults() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('🏆 Results', style: TextStyle(color: _kText, fontSize: 24, fontWeight: FontWeight.bold)),
        const Gap(16),
        for (var i = 0; i < _results.length; i++) ...[
          _EntryCard(entry: _results[i], voted: false, canVote: false, rank: i + 1),
          const Gap(12),
        ],
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final BattleEntry entry;
  final bool voted;
  final bool canVote;
  final VoidCallback? onVote;
  final int? rank;

  const _EntryCard({
    required this.entry,
    required this.voted,
    required this.canVote,
    this.onVote,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: voted ? const Color(0xFFFB7185).withValues(alpha: 0.12) : const Color(0xFF0B1D35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: voted ? const Color(0xFFFB7185).withValues(alpha: 0.4) : const Color(0xFF1A3A5C),
        ),
        boxShadow: voted
            ? [BoxShadow(color: const Color(0xFFFB7185).withValues(alpha: 0.15), blurRadius: 16)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rank != null)
                Text(
                  '#$rank ',
                  style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              Text(
                entry.username ?? 'Player',
                style: const TextStyle(color: Color(0xFFEBF4FF), fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (entry.voteCount > 0)
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFFB7185), size: 16),
                    const Gap(4),
                    Text('${entry.voteCount}', style: const TextStyle(color: Color(0xFF7DB9D8))),
                  ],
                ),
            ],
          ),
          const Gap(8),
          if (entry.story != null) ...[
            Text(entry.story!.rendered, style: const TextStyle(color: Color(0xFFEBF4FF), height: 1.5)),
            const Gap(8),
          ],
          if (entry.continuation != null)
            Text(
              entry.continuation!,
              style: const TextStyle(color: Color(0xFF7DB9D8), fontStyle: FontStyle.italic, height: 1.4),
            ),
          if (canVote) ...[
            const Gap(12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB7185),
                  elevation: 6,
                  shadowColor: const Color(0xFFFB7185).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Vote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
