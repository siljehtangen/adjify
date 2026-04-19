import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';

const _kBg = Color(0xFF060F1E);
const _kSurface = Color(0xFF0B1D35);
const _kBorder = Color(0xFF1A3A5C);
const _kText = Color(0xFFEBF4FF);
const _kTextSub = Color(0xFF7DB9D8);
const _kAccent = Color(0xFF2DD4BF);

class RotatingChainScreen extends StatefulWidget {
  final String roomCode;
  const RotatingChainScreen({super.key, required this.roomCode});

  @override
  State<RotatingChainScreen> createState() => _RotatingChainScreenState();
}

class _RotatingChainScreenState extends State<RotatingChainScreen> {
  final _api = ApiService();
  final _socket = SocketService();
  final _controller = TextEditingController();

  Map<String, dynamic>? _turnInfo;
  bool _loading = true;
  bool _submitting = false;
  bool _submitted = false;

  String get _myId => Supabase.instance.client.auth.currentUser!.id;
  bool get _isMyTurn => _turnInfo?['isYourTurn'] == true;

  @override
  void initState() {
    super.initState();
    _loadTurn();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on('game:chain_submitted', (_) { setState(() => _submitted = false); _loadTurn(); });
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTurn() async {
    try {
      final info = await _api.getChainTurn(widget.roomCode);
      if (mounted) setState(() { _turnInfo = info; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final type = _turnInfo!['segmentType'] as String;
      await _api.submitChainSegment(widget.roomCode, type, content);
      _controller.clear();
      setState(() { _submitted = true; _submitting = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _submitting = false);
      }
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
        title: const Text('Rotating Chain', style: TextStyle(color: _kText)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: _isMyTurn && !_submitted
                  ? _buildMyTurn()
                  : _buildWaiting(),
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
              boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.15), blurRadius: 24, spreadRadius: 2)],
            ),
            child: const Center(child: Text('⏳', style: TextStyle(fontSize: 40))),
          ).animate().scale(),
          const Gap(20),
          const Text(
            'Waiting for your turn…',
            style: TextStyle(color: _kText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            'Round ${_turnInfo?['roundNumber'] ?? '?'}',
            style: const TextStyle(color: _kTextSub),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTurn() {
    final type = _turnInfo?['segmentType'] as String? ?? 'sentence';
    final previous = _turnInfo?['previousContent'] as String?;
    final isSentence = type == 'sentence';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kAccent.withValues(alpha: 0.35)),
            boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.1), blurRadius: 16)],
          ),
          child: Row(
            children: [
              Text(isSentence ? '✍️' : '🔤', style: const TextStyle(fontSize: 24)),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSentence ? 'Your turn: write a sentence' : 'Your turn: fill the adjective blank',
                    style: const TextStyle(color: _kText, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isSentence
                        ? 'Include [ADJ] as a placeholder'
                        : 'What adjective fits here?',
                    style: const TextStyle(color: _kTextSub, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (previous != null) ...[
          const Gap(16),
          const Text('Previous:', style: TextStyle(color: _kTextSub, fontSize: 12)),
          const Gap(4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: Text(previous, style: const TextStyle(color: _kTextSub, fontStyle: FontStyle.italic)),
          ),
        ],
        const Gap(20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              autofocus: true,
              style: const TextStyle(color: _kText),
              decoration: InputDecoration(
                hintText: isSentence
                    ? 'The [ADJ] wizard walked into the [ADJ] forest…'
                    : 'mysterious, ancient, fluffy…',
                hintStyle: TextStyle(color: _kTextSub.withValues(alpha: 0.5)),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),
        const Gap(16),
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
                : const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
