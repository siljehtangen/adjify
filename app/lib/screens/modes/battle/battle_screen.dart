import 'package:adjify/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_colors.dart';
import '../../../models/battle_entry.dart';
import '../../../models/room.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/game_widgets.dart';
import 'battle_filling_view.dart';
import 'battle_results_view.dart';
import 'battle_voting_view.dart';

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
    _socket.off(SocketEvent.battleReveal);
    _socket.off(SocketEvent.voteCast);
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
      for (final c in _adjectives.values) { c.dispose(); }
      _adjectives.clear();
      for (var i = 0; i < blanks; i++) {
        _adjectives[i] = TextEditingController();
      }
      if (mounted) setState(() { _prompt = prompt; _loading = false; });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() { _loading = false; _error = e is ApiException ? e.message : l10n.failedToLoadPrompt; });
      }
    }
  }

  Future<void> _loadResults() async {
    try {
      final results = await _api.getBattleResults(widget.roomCode);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      debugPrint('[BattleScreen] failed to load results: $e');
    }
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
        final l10n = AppLocalizations.of(context)!;
        showErrorToast(e is ApiException ? e.message : l10n.failedToSubmitEntry);
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
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showErrorToast(e is ApiException ? e.message : l10n.failedToCastVote);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(color: kText),
        title: Text(l10n.modeAdjectiveBattle, style: const TextStyle(color: kText)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kBattle))
          : _error != null
              ? ErrorRetry(error: _error!, onRetry: _loadPrompt, accentColor: kBattle)
          : switch (_phase) {
              BattlePhase.filling => BattleFillingView(
                  prompt: _prompt!,
                  adjectives: _adjectives,
                  continuationController: _continuationController,
                  submitting: _submitting,
                  onSubmit: _submit,
                ),
              BattlePhase.waiting => WaitingPlaceholder(
                  icon: const Text('✅', style: TextStyle(fontSize: 40)),
                  title: l10n.storySubmitted,
                  subtitle: l10n.waitingForOtherPlayers,
                  accent: kBattle,
                ),
              BattlePhase.voting => BattleVotingView(
                  results: _results,
                  myId: _myId,
                  votedEntryId: _votedEntryId,
                  onVote: _vote,
                ),
              BattlePhase.results => Column(
                  children: [
                    Expanded(child: BattleResultsView(results: _results)),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: EndButtons(mode: GameMode.battle, accent: kBattle),
                    ),
                  ],
                ),
            },
    );
  }
}
