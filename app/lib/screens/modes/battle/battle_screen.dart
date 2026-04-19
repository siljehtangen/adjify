import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/story.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';

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
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        title: const Text('Adjective Battle', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
          // Story prompt (with blanks hidden)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
            ),
            child: Text(
              content.replaceAll('[ADJ]', '______'),
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
            ),
          ),
          const Gap(24),
          const Text('Fill in the adjectives', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(12),
          for (var i = 0; i < blankCount; i++) ...[
            TextField(
              controller: _adjectives[i],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Blank ${i + 1}',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const Gap(8),
          ],
          const Gap(16),
          const Text('Your continuation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(8),
          TextField(
            controller: _continuationController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Continue the story in your own words…',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✅', style: TextStyle(fontSize: 64)),
          Gap(16),
          Text('Story submitted!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Gap(8),
          Text('Waiting for other players…', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildVoting() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Vote for the best story!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
        const Text('🏆 Results', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
        color: voted ? const Color(0xFFFF6B6B).withOpacity(0.15) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: voted ? const Color(0xFFFF6B6B).withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rank != null)
                Text('#$rank ', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(entry.username ?? 'Player', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (entry.voteCount > 0)
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 16),
                    const Gap(4),
                    Text('${entry.voteCount}', style: const TextStyle(color: Colors.white54)),
                  ],
                ),
            ],
          ),
          const Gap(8),
          if (entry.story != null) ...[
            Text(entry.story!.rendered, style: const TextStyle(color: Colors.white, height: 1.5)),
            const Gap(8),
          ],
          if (entry.continuation != null)
            Text(entry.continuation!, style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic, height: 1.4)),
          if (canVote) ...[
            const Gap(12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Vote', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
