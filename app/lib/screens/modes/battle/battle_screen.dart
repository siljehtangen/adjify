import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_colors.dart';
import '../../../models/story.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/game_widgets.dart';
import 'battle_filling_view.dart';
import 'entry_card.dart';

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
  String? _error;

  String get _myId => Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadPrompt();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on(SocketEvent.battleReveal, (_) { if (mounted) { setState(() => _phase = BattlePhase.voting); _loadResults(); } });
    _socket.on(SocketEvent.voteCast, (_) { if (mounted) _loadResults(); });
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
    if (mounted) setState(() => _error = null);
    try {
      final prompt = await _api.getBattlePrompt(widget.roomCode);
      final blanks = (prompt['story_blanks'] as List?)?.length ?? 0;
      for (var i = 0; i < blanks; i++) {
        _adjectives[i] = TextEditingController();
      }
      if (mounted) setState(() { _prompt = prompt; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e is ApiException ? e.message : 'Failed to load prompt'; });
    }
  }

  Future<void> _loadResults() async {
    try {
      final results = await _api.getBattleResults(widget.roomCode);
      if (mounted) setState(() => _results = results);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_prompt == null) return;
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
        showErrorSnackBar(context, e.toString());
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
        title: const Text('Adjective Battle', style: TextStyle(color: kText)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kBattle))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: kTextSub)),
                  const Gap(12),
                  TextButton(onPressed: _loadPrompt, child: const Text('Retry', style: TextStyle(color: kBattle))),
                ]))
          : switch (_phase) {
              BattlePhase.filling => BattleFillingView(
                  prompt: _prompt!,
                  adjectives: _adjectives,
                  continuationController: _continuationController,
                  submitting: _submitting,
                  onSubmit: _submit,
                ),
              BattlePhase.waiting => const WaitingPlaceholder(
                  icon: Text('✅', style: TextStyle(fontSize: 40)),
                  title: 'Story submitted!',
                  subtitle: 'Waiting for other players…',
                  accent: kBattle,
                ),
              BattlePhase.voting => _buildVoting(),
              BattlePhase.results => _buildResults(),
            },
    );
  }

  Widget _buildVoting() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Vote for the best story!', style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.bold)),
        const Gap(16),
        for (final entry in _results)
          if (entry.playerId != _myId) ...[
            EntryCard(
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
        const Text('🏆 Results', style: TextStyle(color: kText, fontSize: 24, fontWeight: FontWeight.bold)),
        const Gap(16),
        for (var i = 0; i < _results.length; i++) ...[
          EntryCard(entry: _results[i], voted: false, canVote: false, rank: i + 1),
          const Gap(12),
        ],
      ],
    );
  }
}
